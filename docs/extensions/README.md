# ISPConfig extension developer documentation

Documents for developers who write extensions for ISPConfig. Extensions are
packages that are installed from the ISPConfig extension repository into
`/usr/local/ispconfig/extensions/<name>/` on every server, through the panel
(System > Extension Installer) or the command line (`ispc extension ...`).

| Document | Content |
|----------|---------|
| [sql_files.md](sql_files.md) | Database tables of an extension: install and uninstall SQL, node vs. master scope, schema migrations on update, the `dbversion` file |
| [master_grants.md](master_grants.md) | Giving the server processes of slave servers access to the extension's own tables in the master database: `install/master_grants.list`, `sys_extension_grant`, when the rights are applied |
| [extension_limits.md](extension_limits.md) | Registering client, reseller and client-template limits from an extension without touching the core limit forms |

Related code:

- `server/lib/classes/extension_installer.inc.php`: download, install, update,
  uninstall, enable and disable of extensions on a server
- `server/lib/classes/extension_installer_base.inc.php`: base class of the
  `<name>_installer` class every extension ships in `install/installer.php`
- `server/cli/modules/extension.inc.php`: the `ispc extension` commands
- `interface/web/admin/extension_*.php`: the panel side
