-- Master database rights that extensions declare for their own tables (install/master_grants.list
-- of the extension). Read by the updater when it rebuilds the rights of the ispcsrv users.
CREATE TABLE IF NOT EXISTS `sys_extension_grant` (
  `grant_id` int(11) unsigned NOT NULL AUTO_INCREMENT,
  `extension` varchar(64) NOT NULL DEFAULT '',
  `table_name` varchar(64) NOT NULL DEFAULT '',
  `privileges` varchar(64) NOT NULL DEFAULT '',
  PRIMARY KEY (`grant_id`),
  UNIQUE KEY `extension_table` (`extension`,`table_name`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 AUTO_INCREMENT=1;
