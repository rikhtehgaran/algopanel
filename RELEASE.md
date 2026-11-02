## ISPConfig 3.3.2p1 Released

This is a patch release that fixes bugs discovered after the 3.3.2 release.

## What's new in ISPConfig 3.3.2p1?

### Bugfixes

- Fixed rspamd not starting after an update to ISPConfig 3.3.2 with reconfiguration of services. The update renames the no longer used /etc/rspamd/local.d/users.conf, but the include directive for that file was only removed from /etc/rspamd/rspamd.conf when it ended with a line break. Older ISPConfig versions appended the directive without one, so on most servers it stayed in place and pointed to a file that no longer exists. The directive is now removed regardless of how it was written. Servers that are already affected are repaired by this update, a manually restored users.conf can be removed afterwards (#7054)
- Fixed the hard disk quota monitoring reading the wrong column of the repquota output for a website whose disk soft limit is exceeded. repquota prints a grace time behind the block limits in that case, which shifts the number of files one column to the right. The monitoring stored the grace time instead of the number of files and, on servers with more than one quota enabled filesystem, aborted the whole ISPConfig cron run with "Unsupported operand types: string + string" on PHP 8 (#7053)
- Fixed the ISPConfig update not adding the pid column to the sys_cron table on MySQL and on MariaDB versions older than 10.0.2, as the SQL statement used ADD COLUMN IF NOT EXISTS, which only MariaDB supports (#7055)
- Fixed database users not being created on MariaDB older than 10.1.3 and MySQL older than 5.7.8, which do not support CREATE USER IF NOT EXISTS. These versions use the previous behaviour again. Changing the name or password of a database user is now only applied on the servers that host a database of that user (#7056)
- Fixed mailboxes, email aliases, email forwards and catchalls being created on the wrong server when the same mail domain exists on more than one mail server. The forms now identify the selected mail domain by its ID instead of its name and show the server name for domains that exist on several servers (#7057)

Please see changelog for a full list of features and bugfixes:

https://git.ispconfig.org/ispconfig/ispconfig3/-/milestones/101

---

## ISPConfig 3.3.2 Released

This release adds support for Ubuntu 26.04, an option to enforce inbound DMARC rules, a separate sender address for system mails, an interface for extensions to add their own client and reseller limits, and fixes a number of bugs reported after the 3.3.1p1 release.

A privilege escalation security vulnerability has been found in the Fetchmail function of the Email module. This issue has been fixed in ISPConfig 3.3.2. We thank Arvin Shivram of Brutecat Security for reporting the issue to us (#7052).

A SQL injection vulnerability has been found in the update and delete functions of the remote API, which allowed a remote API user to modify or delete records beyond their permissions. This issue has been fixed in ISPConfig 3.3.2. We thank Nguyen Chi Quang from MBBank for reporting the issue to us (#7051).

## What's new in ISPConfig 3.3.2?

### Ubuntu 26.04 Support

ISPConfig 3.3.2 adds support for Ubuntu 26.04 LTS, including the Dovecot 2.4 configuration syntax used by that release (#6996).

### Inbound DMARC Enforcement

A new option allows to enforce inbound DMARC rules in rspamd, so that incoming mail is rejected or quarantined according to the DMARC policy published by the sending domain (#6995).

### Separate Sender Address for System Mails

The e-mail address of the administrator was used as sender address and as recipient address for system mails at the same time. This caused problems with SPF when the mailbox of the administrator is hosted on a different server, as the ISPConfig server had to send mails using an address of a domain that it does not host.

The setting has been split into two fields in System > Main Config > Mail:

- **Administrator's contact e-mail** (`admin_mail`) is the recipient of system notifications and is used as reply address.
- **Server sender e-mail address** (`server_sender_mail`) is the address that system mails are sent from.

This affects notification mails like traffic and quota mails, monitoring notifications, OTP and password reset mails, the welcome mails for clients and resellers, and support messages. Custom mail templates in `conf-custom/mail/` that use their own sender address are not changed.

The update sets the new field to the current administrator e-mail address, so the behaviour of existing installations does not change until a different sender address is configured (#7028).

### Extensible Client and Reseller Limits

Extensions can now register additional client and reseller limits without patching core files. A new limits registry makes the limit fields available in the client and reseller forms and in the client templates (#7019).

### Updated CA List for CAA Records

The list of certificate authorities offered for CAA DNS records has been updated to reflect the current trust landscape. Former CAs were removed, CAs that merged or changed their name were updated and new CAs were added (#7017).

### Database Backups Without Table Locks

mysqldump locks all tables of a database while it dumps them, so a website can become unresponsive for as long as its database backup runs. A new setting in System > Server Config > Server controls whether the backup is made with `--single-transaction` instead, which does not lock the database.

The setting defaults to **Automatic**. In this mode ISPConfig looks at the storage engines of the database and dumps it without table locks when all of its tables use a transactional engine such as InnoDB. A database that contains MyISAM or MEMORY tables is still dumped with table locks, because a dump taken without locks is not consistent for those engines. **Yes** always dumps without table locks, which is the right choice for a mixed database whose availability matters more than the consistency of its non transactional tables. **No** keeps the behaviour of earlier releases (#7049).

### Custom Error Pages Disabled by Default

Custom error pages are now disabled by default for newly created websites. Existing websites are not changed by the update (#7021).

### Bugfixes

- Fixed the password reset link in the password reset e-mail being built from the Host header of the request, which allowed an attacker to send a reset link pointing to a host under their control to the user. The link is now built from the interface_base_url setting in interface/lib/config.inc.php if set, otherwise from the hostname of the server that runs the interface. If the panel is reached under a different hostname than the server hostname, set interface_base_url accordingly (#7044)
- Fixes from the code audit by siteguardian.io (#7044): the user type scope (any/user/admin) of entries in the IDS whitelist and htmlfield files is now enforced, it was ignored before. If you use a custom whitelist (security/ids.whitelist.custom), check that entries for fields that resellers can edit use the user scope. CSRF tokens are now required for backup actions, DNS zone import, extension installation and management, and the vpopmail import. TLS certificate verification is no longer disabled when downloading extensions and APS packages. The session ID is regenerated on login unless session_regenerate_id is set to no in security_settings.ini. Password hashes and CSRF tokens are compared in constant time, the CSRF token timeout is enforced for form submits, e-mail headers are protected against CRLF injection, shell arguments in the PowerDNS DNSSEC, certbot and PostgreSQL size commands are escaped, the APS package extraction rejects paths outside the target directory, and unserialize() calls no longer allow objects. The stale interface/web/remote/monitor.php file from versions before 3.2 is removed by the updater
- Fixed the client select field of the website, mail domain, mailing list, XMPP domain, DNS zone, secondary DNS zone, database user, client domain and OpenVZ virtual machine forms falling back to the first entry of the list when the form was redisplayed after a validation error. For a reseller the first entry is the reseller himself, so correcting the reported error and saving again handed the record over to the reseller and, in case of a website, moved the site to a different directory. The field now keeps the client that was selected, or the current owner of the record if the selection can not be determined. A reseller can now only assign a record to himself or to one of his sub clients, other client groups sent with the form are ignored and logged (#7048)
- Fixed resellers not being offered the additional PHP versions of the selected client in the website form, and the sort priority of PHP versions being ignored for resellers. PHP versions with the same sort priority are now listed with the most recently added version first, so that a new website defaults to the newest PHP version unless the sort priority says otherwise
- Fixed BIND not being able to write the zone files of secondary DNS zones on Ubuntu 24.04 and other systems with AppArmor, as the installer did not detect AppArmor when the apparmor_status command is not available and did not reload the BIND AppArmor profile after adding the rules for the slave zone directory. The rules now also allow file locking. The fix is applied by the ISPConfig update
- Fixed a privilege escalation vulnerability in the Fetchmail function of the Email module. The values of a Fetchmail account were written into the getmail configuration file without validation, which allowed a client to inject additional configuration sections through line breaks in the account fields. Line breaks and null bytes are now removed from the values, the destination has to be a valid e-mail address, and the getmail plugin refuses to write or delete a configuration file that is a symlink or resolves to a path outside the getmail configuration directory (#7052)
- Fixed a SQL injection vulnerability in the remote API. The record ID passed to the update and delete functions of the API was used in the SQL query without validation, which allowed a remote API user with permission for an update or delete function to modify or delete records beyond that permission and to read data from other tables. The ID is now required to be a positive integer and the affected queries use parameter placeholders (#7051)
- Fixed configuration values containing backslashes (e.g. the SMTP password in System > Main Config > Mail) losing one backslash each time an unrelated configuration tab was saved. The sections that are not being edited were unescaped when read and written back without re-escaping. Values set through the remote API system_config_set and server_config_set functions are now escaped in the same way as values saved through the interface (#7042)
- Fixed PHP warnings "Trying to access array offset on value of type bool" and invalid width/height CSS on the login and main pages when the custom panel logo is an SVG image or can not be parsed. The logo now falls back to the stylesheet dimensions (#7039)
- Fixed the "more" button of the donation dashlet reacting to every button on the dashboard, including the logout button and the close buttons of info messages. The dashlet now uses a plain HTML disclosure element without JavaScript (#7043)
- Fixed an internal cron job never being executed again when a cron run was aborted while the job was running. The job is now released as soon as the cron run that started it is gone, instead of staying marked as running for up to a day. Cron jobs can declare a maximum expected run time, which is used when the process that started the job is not known (#7034)
- Fixed the SSH key pair generation for a client failing with "Data too long for column ssh_rsa" when the domain or user name used in the key comment is long, as the public key of a 3072 bit RSA key with a long comment exceeds 600 characters. The column is now a text column. The database_password_sha2 column of database users, which was exactly as long as the generated hash, has been widened to 255 characters as pre-hashed values passed through the remote API can be longer (#7074)
- Fixed the owner of an existing .htaccess file being changed to root:root when a folder protection is deleted or set to inactive. The file now keeps the system user and group of the website (#7035)
- Fixed the rspamd settings file of a mailbox or forwarding not being regenerated when its greylisting setting is changed, so that disabling greylisting had no effect until the next resync (#7027)
- Fixed traffic quota not being enforced when the quota is set to 0, which could be used to bypass the client traffic limit and the automatic deactivation of overtraffic websites (#7024)
- Fixed uncaught DivisionByZeroError when opening the website traffic statistics on PHP 8.x (#7023)
- Fixed undefined $php_fpm_reload_mode in the nginx plugin, which aborted the PHP-FPM reload when a website was deleted (#7022)
- Fixed broken installation of the pureftpd_sni_plugin.inc.php plugin (#7020)
- Fixed false warning "PHP cli binary is not available in the jail" when PHP is provided by the global jailkit configuration (#7018)
- Fixed grant_master_database_rights silently failing on a master server (#7016). The fix in the development version aborted the update of a single server with "Unable to get the user rights" when the master database permissions were reconfigured, because a single server has no slave server users. An empty user list is now handled as the normal case and only a database error aborts the update
- Fixed PHP fatal error after a deb.sury.org PHP upgrade when the IDS temp folder became read-only (#7010)
- Fixed email routing error when adding routing for an email domain in multiserver setups (#7009)
- Removed the stale interface/lib/config.inc.php file from the repository (#7007)
- Fixed TypeError when sending a second mail from a cronjob (#7003)
- Fixed admin not receiving notifications for failed nightly backups (#7002)
- Fixed PHP fatal error (TypeError) in nginx_plugin.inc.php and apache2_plugin.inc.php (#7000)
- Fixed shell_user_update being triggered before the web_domain record was replicated, which resulted in an outdated configuration on secondary servers (#6997)
- Fixed invalid Sieve syntax when using Subject as source together with the domain or localpart operator (#7011)
- Migrated rspamd user settings to follow the rspamd configuration best practices (#7006)
- Fixed the sender address of the reseller welcome mail, which was empty because the mail section of the global config was not read (#7028)
- Fixed a malformed From header in notification mails that use a sender name in the mail template (#7028)

### Other Improvements

- Added a commandline option to ispconfig_update.sh to update to a specific branch beside develop
- Improved acme.sh handling for local loopback addresses, improved acme.sh logging in the installer and added a curl fallback to download acme.sh
- Added the systemd override for the ISPConfig temp dir to the Apache systemd unit as well
- Avoid errors when the ISPConfig log directory does not exist yet
- Improved getmail input field validation
- Mailbox soft-delete values are automatically converted from y/n to the numeric values used by the new configuration

Please see changelog for a full list of features and bugfixes:

https://git.ispconfig.org/ispconfig/ispconfig3/-/milestones/99

---

## ISPConfig 3.3.1p1 Released

This is a patch release that fixes several bugs discovered after the 3.3.1 release, including Debian 13 PHP socket issues, Rspamd spam header handling, MySQL 8.0.45 compatibility, and various other improvements.

## What's new in ISPConfig 3.3.1p1?

### Bugfixes

- Fixed Debian 13 PHP socket issue in apps vhost and PHP-FPM pools (#6983)
- Fixed Rspamd X-Spam-Status header not being added when using "Rewrite Subject" spam tag method, which caused spam to be forwarded via CC/redirect rules (#6979)
- Fixed Apache error.log rotation causing logs to not being written after rotation (#6992)
- Fixed phpMyAdmin link not showing in database list (#6981)
- Fixed SimplePie PHP 8 compatibility for RSS feeds (#6982)
- Fixed client creation via API failing with usertheme_syntax_incorrect error (#6990)
- Fixed mail user login field not being updated when renaming mailbox (#6989)
- Fixed Dovecot last_access log parsing pattern for Debian 13/Dovecot 2.4 (#6994)
- Fixed vmail user permissions to dovecot-sql.conf for Debian 13 (#6976)
- Fixed stale content.php file causing errors (#6974)
- Fixed system_update warning remaining after disabling the Check for Linux updates feature (#6896)
- Fixed harddisk storage monitoring trigger values (#6978)
- Cleaned up bouncing space in postfix config (#6985)
- Added missing disablereplicator column to mail_user table (#6993)

### New Features

- Added support for MySQL 8.0.45 (#6991)
- Added support for extended RBL syntax for Spamhaus RBL (#6977)
- Added support for per-domain mail relaying without username/password (#6877)
- Added support for RHEL 10 postfix without hash map type (#6980)

Please see changelog for a full list of features and bugfixes:

https://git.ispconfig.org/ispconfig/ispconfig3/-/milestones/100

---

## ISPConfig 3.3.1 Released

This version brings Debian 13 support with Dovecot 2.4 compatibility, RHEL 10 based distribution support (AlmaLinux 10, RockyLinux 10), PHP 8.5 compatibility, pgAdmin for PostgreSQL databases, improved DNS validation, and many bugfixes. It also fixes 3 security issues.

## What's new in ISPConfig 3.3.1?

### Debian 13 Support

ISPConfig 3.3.1 adds full support for Debian 13 (Trixie), including compatibility with Dovecot 2.4 which introduces an incompatible configuration language. The Dovecot configuration templates have been updated to work with the new 2.4 syntax.

### RHEL 10 Based Distribution Support

Support has been added for RHEL 10 based distributions including AlmaLinux 10 and RockyLinux 10.

### PHP 8.5 Compatibility

ISPConfig is now compatible with PHP 8.5. This includes fixes for deprecated functions like `mysqli_ping()` and non-canonical casts.

### pgAdmin for PostgreSQL Databases

A pgAdmin link has been added for PostgreSQL databases, similar to how phpMyAdmin works for MySQL/MariaDB databases. The phpMyAdmin link is now correctly hidden for PostgreSQL databases.

### DNS Record Validation Improvements

Improved validation for DNS records including better CNAME conflict detection, SRV record field validation, and DMARC record handling.

### Rspamd Greylisting Fixes

Fixed issues where rspamd greylisting settings from spamfilter policies were not being applied correctly to domain-level spam filter entries and user configurations.

### Let's Encrypt Improvements

- Removed OCSP stapling sections from vhosts as Let's Encrypt no longer supports OCSP
- Fixed default CA setting when acme.sh is installed from the Let's Encrypt class

### Extended CLI Resync Functionality

The Tools > Resync function has been extended in the ispc CLI command, allowing more flexible server synchronization from the command line.

### Improved Autoinstall Updates

Improved updating with autoinstall.conf.php including better documentation and the ability to pass --autoinstall option from ispconfig_update.sh and ispc update to update.php.

### Improved website logfile permissions

Website logfiles are now created with stricter permissions (640) and ownership (root:clientX).

### Security Fixes

This release addresses three security vulnerabilities that could allow privilege escalation under certain conditions. The issues affect theme handling, backup restoration, and backup download functionality. We strongly recommend all users to update to this version as soon as possible.

We would like to thank **SSD Secure Disclosure** for responsibly discovering and reporting these vulnerabilities.

### Backup System Changes

- Removed zip and rar archive formats from rootgz backup mode as they do not preserve file ownership. These formats will automatically fall back to tar_gzip when selected with rootgz mode. The zip and rar mode will stay available for userzip mode.

### Bugfixes & Minor Features

- Fixed DKIM config bug in amavis that could cause DKIM entries to be lost
- Fixed PowerDNS records not being created when domain is inactive
- Fixed PHP 8.3 compatibility issues
- Fixed false positive "Possible attack detected" for valid Nginx directive snippets
- Fixed trailing space in nginx vhost server_name property
- Fixed data cleanup when server is deleted (monitor_data and server_ip)
- Fixed sysdatalog processing with incorrect unixtime values
- Improved useragent for cronjobs (wget)
- Silenced z_php_fpm_incron_reload_plugin warnings when no PHP version is set
- Fixed CAA DNS entry name handling with TLD
- Improved email filter regex syntax validation
- Fixed stats/.htaccess file permissions
- Added more plugin events for interface plugins

Please see changelog for a full list of features and bugfixes:

https://git.ispconfig.org/ispconfig/ispconfig3/-/milestones/95

## Known issues

Please take a look at the bug tracker:

https://git.ispconfig.org/ispconfig/ispconfig3/-/issues?scope=all&utf8=%E2%9C%93&state=opened&label_name[]=Bug

You can report bugs at https://git.ispconfig.org/ispconfig/ispconfig3/issues

## Supported Linux distributions

- Debian 11 – 13 (recommended) and Debian testing
- Ubuntu 22.04 LTS – 26.04 LTS (recommended)
- AlmaLinux 8 – 10
- RockyLinux 8 – 10
- CentOS 8

## Download ISPConfig 3.3.2

https://www.ispconfig.org/downloads/ISPConfig-3.3.2.tar.gz

The installation instructions for ISPConfig can be found here:

https://www.ispconfig.org/ispconfig-3/documentation/

## How can I update to ISPConfig 3.3.2?

Run the following commands as root user on your ISPConfig server:

```
cd /tmp
wget https://www.ispconfig.org/downloads/ISPConfig-3.3.2.tar.gz
tar xvfz ISPConfig-3.3.2.tar.gz
cd ispconfig3_install/install
php -q update.php
```
