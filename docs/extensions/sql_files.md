# Extension SQL files: install, uninstall and schema migrations

How an ISPConfig extension creates, updates and removes its database tables.
Audience: extension developers.

Everything described here is handled by the server side extension installer
(`server/lib/classes/extension_installer.inc.php`). The extension only ships the
SQL files in the right place; the framework runs them.

---

## 1. Where the SQL runs

An extension is installed **locally on every server** of an ISPConfig setup
(single server, master and every slave). Each server has its own local ISPConfig
database (`dbispconfig`), and the master server additionally holds the master
database that the panel works on. On a single server or on the master server,
the local database and the master database are the same database.

Slave servers never connect to the master database during install, update or
uninstall. They only hold the credentials of their local database. Therefore the
SQL of an extension is split into two scopes:

| Scope    | Runs on                                              | Typical content                                            |
|----------|------------------------------------------------------|------------------------------------------------------------|
| `node`   | every server, against the local database             | tables the server processes need locally                   |
| `master` | only the server that holds the master database       | tables the panel (interface) reads and writes              |

A table that a server writes and the panel reads (for example scan results) is a
`master` table: the server process writes it through `$app->dbmaster`. The
rights the slave servers need for that are declared in
`install/master_grants.list`, see [master_grants.md](master_grants.md).

All SQL files run as the local ISPConfig database user (`$conf['db_user']`)
through the `mysql` command line client against `$conf['db_database']`. That user
has all privileges on the local ISPConfig database, so `CREATE TABLE`, `ALTER
TABLE` and `DROP TABLE` work. Do not put `USE` or `CREATE DATABASE` statements
into the files.

## 2. File layout

All SQL files live in the `install/` directory of the extension:

```
<extension>/
  install/
    installer.php                 required, <name>_installer class
    file.list                     files to copy / symlink into /usr/local/ispconfig
    install_node.sql              full schema, node scope (optional)
    install_master.sql            full schema, master scope (optional)
    uninstall_node.sql            drops the node scope tables (optional)
    uninstall_master.sql          drops the master scope tables (optional)
    master_grants.list            rights of the slave servers on the master tables (optional)
    incremental/
      upd_0001_node.sql           migration step 1, node scope
      upd_0001_master.sql         migration step 1, master scope
      upd_0002_master.sql         migration step 2, master scope only
      ...
```

Legacy names: `install/install.sql` and `install/uninstall.sql` are still
accepted and mean the same as `install_node.sql` / `uninstall_node.sql`. If both
the new and the legacy name exist, the new name wins and the legacy file is
ignored. New extensions should use the `_node` / `_master` names.

Every file is optional. An extension without database tables ships none of them.

## 3. Install

`install_extension()` runs, in this order:

1. `installer->install()` of the extension's installer class
2. `install_node.sql` (or legacy `install.sql`) on every server
3. `install_master.sql`, only where the master database is local
4. the schema version file `dbversion` is written (see section 5)
5. the master database grants of `master_grants.list` are registered and
   applied, only where the master database is local (see
   [master_grants.md](master_grants.md))
6. `installer->enable()`

If one of the SQL files fails, the install stops with an error. The extension is
left downloaded but **not enabled**, and the error is reported to the caller
(panel or `ispc extension install`). Fix the SQL, then run the install again.

The install SQL always contains the **full current schema**. When you add a
migration step (section 5), also update `install_node.sql` / `install_master.sql`
so that a fresh install ends up with the same schema as an updated install.

## 4. Uninstall

`uninstall_extension()` runs, in this order:

1. `installer->disable()`
2. `installer->uninstall()`
3. the master database grants are revoked, only where the master database is
   local
4. `uninstall_node.sql` (or legacy `uninstall.sql`) on every server
5. `uninstall_master.sql`, only where the master database is local
6. the extension directory is removed

A failing uninstall SQL is logged and reported, but the uninstall continues and
the extension directory is removed anyway. Write uninstall files so they cannot
fail on a half installed extension: `DROP TABLE IF EXISTS`.

## 5. Schema migrations on update

`update_extension()` runs no install SQL. Instead it applies the pending
migration steps from `install/incremental/` after `installer->update()` and
before `installer->enable()`. After the migrations the master database grants
are registered again, so `master_grants.list` may change with an update.

Steps are numbered consecutively, starting at 1, four digits zero padded, with
the scope as suffix:

```
install/incremental/upd_0001_node.sql
install/incremental/upd_0001_master.sql
install/incremental/upd_0002_node.sql
```

A step may ship a node file, a master file, or both. The step number is one
counter for the whole extension, regardless of scope. Numbers must not have
gaps: the framework applies the steps from the current version plus one up to
the highest number found, and treats a missing file of a scope as "nothing to do
for this scope in this step".

The applied schema version is stored in the file `dbversion` in the extension
directory (`/usr/local/ispconfig/extensions/<name>/dbversion`), as a plain
integer:

- The framework owns this file. Do not ship a file with this name in the
  package.
- After a fresh install it contains the highest step number shipped in
  `install/incremental/`, because the install SQL already contains the full
  schema. Without any migration files it contains `0`.
- On update, all steps above the stored number are applied, then the number is
  raised. The number is raised after every complete step, so a failing step
  keeps the version of the last complete step. The update stops, the extension
  is **not enabled**, and the error is reported. After fixing the SQL, running
  the update again continues with the failed step.
- A missing file counts as version `0`. This is the case for extensions that
  were installed before schema migrations existed. All steps are then applied
  on the next update, so migration files must be written **re-runnable**, see
  section 6.
- Removing the file by hand forces all steps to run again on the next update.
  Useful for support cases, harmless when the migrations are re-runnable.

The current schema version of every extension is also reported per server in
the extension list that `scan_extensions()` stores in `monitor_data`
(`dbversion` field).

## 6. Writing the SQL

- Make migrations re-runnable. MariaDB and MySQL 8 support
  `CREATE TABLE IF NOT EXISTS`, `DROP TABLE IF EXISTS`, and MariaDB also
  supports `ALTER TABLE ... ADD COLUMN IF NOT EXISTS` /
  `DROP COLUMN IF EXISTS` / `ADD INDEX IF NOT EXISTS`.
- One statement per line or terminated by `;` as usual, the file is piped
  into the `mysql` client. Comments with `--` and `/* */` are fine.
- Tables that servers write and the panel reads carry a `server_id` column, so
  the panel can filter per server and a server only touches its own rows.
- Prefix table names with the extension name (`<name>_...`) to avoid clashes
  with core tables and other extensions.
- Use `utf8mb4` and the `InnoDB` engine like the core tables.
- Keep master scope tables out of node files and vice versa. On a single
  server both scopes run against the same database, so a mistake is not
  visible there; it shows up on a multiserver setup as a missing table on the
  slaves or on the master.

Example `install_master.sql`:

```sql
CREATE TABLE IF NOT EXISTS `myext_findings` (
  `finding_id` int(11) unsigned NOT NULL AUTO_INCREMENT,
  `sys_userid` int(11) unsigned NOT NULL DEFAULT 0,
  `sys_groupid` int(11) unsigned NOT NULL DEFAULT 0,
  `sys_perm_user` varchar(5) NOT NULL DEFAULT '',
  `sys_perm_group` varchar(5) NOT NULL DEFAULT '',
  `sys_perm_other` varchar(5) NOT NULL DEFAULT '',
  `server_id` int(11) unsigned NOT NULL DEFAULT 0,
  `severity` enum('info','low','medium','high') NOT NULL DEFAULT 'info',
  `message` text,
  `created` datetime DEFAULT NULL,
  PRIMARY KEY (`finding_id`),
  KEY `server_id` (`server_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;
```

Example `incremental/upd_0001_master.sql` adding a column later on:

```sql
ALTER TABLE `myext_findings` ADD COLUMN IF NOT EXISTS `resolved` tinyint(1) NOT NULL DEFAULT 0;
```

Example `uninstall_master.sql`:

```sql
DROP TABLE IF EXISTS `myext_findings`;
```

## 7. Checking what happened

- The applied version: `cat /usr/local/ispconfig/extensions/<name>/dbversion`
- Log lines: the installer logs every SQL file it runs, skips or fails to
  `/var/log/ispconfig/ispconfig.log` (`Loaded install_node.sql for extension
  ...`, `Skipping install_master.sql of extension ..., the master database is not
  on this server`, `Failed to run upd_0002_node.sql for extension ...`). Set the
  server log level to debug to see the skip and "no pending migrations"
  messages.
- Command line: `ispc extension install <name>`, `ispc extension update <name>`
  and `ispc extension uninstall <name>` print the errors of the extension
  installer directly.
