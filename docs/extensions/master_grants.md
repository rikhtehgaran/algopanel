# Extension master database grants

How an extension gives the server processes of slave servers access to its own
tables in the master database. Audience: extension developers.

Read [sql_files.md](sql_files.md) first: it explains the node / master scope of
the SQL files and where the master database lives.

---

## 1. The problem

In a multiserver setup every slave server talks to the master database through
its own MySQL user `ispcsrv<server_id>`, created when the slave joins. That user
only has the rights the ISPConfig installer grants explicitly, table by table
(`grant_master_database_rights()` in `install/lib/installer_base.lib.php`).
The rights are rebuilt from scratch on every ISPConfig update and by
`install/setrights.php`: `REVOKE ALL`, then the fixed list of grants.

Tables an extension creates with `install_master.sql` are therefore not
reachable from the slaves' server processes (`$app->dbmaster`) until someone
grants access, and a manual grant is lost at the next update.

## 2. The declaration file

The extension declares the rights it needs in `install/master_grants.list`, one
table per line:

```
# <table>:<privilege>[,<privilege>...]
myext_findings:SELECT,INSERT,UPDATE,DELETE
myext_scan_run:SELECT,UPDATE
```

Rules, enforced by the framework:

- The table name must start with the extension name followed by an underscore
  (`<name>_`). An extension can only declare rights on its own tables, never on
  core tables or tables of other extensions.
- Allowed privileges: `SELECT`, `INSERT`, `UPDATE`, `DELETE`. Nothing else, no
  column lists. Extensions that need more than that on the master are outside
  the scope of this mechanism.
- Empty lines and lines starting with `#` are ignored. Privileges are case
  insensitive and deduplicated.
- One invalid line makes the whole install or update fail; the extension is
  left not enabled and the error is reported.

The grants apply to **all** `ispcsrv` users, so every slave gets the same
rights on the table. Row scoping is the extension's job: tables written by
servers carry a `server_id` column and a server only touches its own rows. A
compromised slave can still write other servers' rows; this is a known
limitation of MySQL grants that the planned REST API between nodes and master
will remove.

## 3. What the framework does

On the **master server** (the server where the master database is local; on a
single server setup as well, where it is a no-op because there are no `ispcsrv`
users):

1. On install, after the install SQL, and on update, after the migrations, the
   extension installer parses `master_grants.list` and stores the declarations
   in the core table `sys_extension_grant` (`extension`, `table_name`,
   `privileges`). Previous declarations of the extension are replaced, so
   removing a line from the file removes the stored declaration on the next
   update.
2. If the MySQL root credentials in
   `/usr/local/ispconfig/server/lib/mysql_clientdb.conf` are available (they
   are on a master that also hosts client databases), the grants are applied
   right away for every existing `ispcsrv` user. Otherwise the installer logs a
   hint and the grants are applied by the next step.
3. On uninstall, before the uninstall SQL drops the tables, the stored rights
   are revoked the same way and the declarations are deleted.

On **slave servers** nothing happens; they have no access to the master
database beyond their grants.

**ISPConfig update, `install/setrights.php` and slave join**: whenever the
master database rights of the `ispcsrv` users are rebuilt, the installer reads
`sys_extension_grant` and grants the declared rights after the core ones. This
covers a new slave joining an existing setup (it grants its own rights during
installation, with the master root credentials entered there), and it restores
the extension rights after the `REVOKE ALL` of an update.

When the grants could not be applied right away (no root credentials on the
master, or a MySQL error), run this on the master server from an unpacked
ISPConfig tarball to apply them:

```
cd install
php setrights.php
```

## 4. Checking

- Stored declarations: `SELECT * FROM sys_extension_grant;` in the master
  database.
- Effective rights of a slave: `SHOW GRANTS FOR 'ispcsrv2'@'slave-host';`
- Log lines in `/var/log/ispconfig/ispconfig.log` of the master server:
  `Registered N master database grant(s) for extension ...`, `Applied master
  database grants of extension ... for N server user(s)`, or the hint that the
  root credentials are missing.

## 5. Example

```
myext/
  install/
    install_master.sql        CREATE TABLE IF NOT EXISTS `myext_findings` (...)
    install_node.sql          (tables the server needs locally, if any)
    master_grants.list        myext_findings:SELECT,INSERT,UPDATE,DELETE
    uninstall_master.sql      DROP TABLE IF EXISTS `myext_findings`;
```

Server side code on any server then reads and writes the table through the
master connection:

```php
$app->dbmaster->query("INSERT INTO myext_findings (server_id, severity, message, created) VALUES (?, ?, ?, NOW())", $conf['server_id'], 'high', $message);
```
