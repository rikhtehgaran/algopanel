/*
Copyright (c) 2007-2012, Till Brehm, projektfarm Gmbh
All rights reserved.

Redistribution and use in source and binary forms, with or without modification,
are permitted provided that the following conditions are met:

    * Redistributions of source code must retain the above copyright notice,
      this list of conditions and the following disclaimer.
    * Redistributions in binary form must reproduce the above copyright notice,
      this list of conditions and the following disclaimer in the documentation
      and/or other materials provided with the distribution.
    * Neither the name of ISPConfig nor the names of its contributors
      may be used to endorse or promote products derived from this software without
      specific prior written permission.

THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND
ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED.
IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT,
INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING,
BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE,
DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY
OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING
NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE,
EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
*/

-- Includes
--
-- iso_country_list.sql
--
-- This will create and then populate a MySQL table with a list of the names and
-- ISO 3166 codes for countries in existence as of the date below.
--
-- For updates to this file, see http://27.org/isocountrylist/
-- For more about ISO 3166, see http://www.iso.ch/iso/en/prods-services/iso3166ma/02iso-3166-code-lists/list-en1.html
--
-- Created by getisocountrylist.pl on Sun Nov  2 14:59:20 2003.
-- Wm. Rhodes <iso_country_list@27.org>
--

--
-- ISPConfig 3
-- DB-Version: 3.0.0.9
--

SET FOREIGN_KEY_CHECKS = 0;

-- --------------------------------------------------------
-- --------------------------------------------------------
-- DB-STRUCTURE
-- --------------------------------------------------------
-- --------------------------------------------------------

--
-- Table structure for table `aps_instances`
--

CREATE TABLE IF NOT EXISTS `aps_instances` (
  `id` int(4) NOT NULL AUTO_INCREMENT,
  `sys_userid` int(11) unsigned NOT NULL DEFAULT '0',
  `sys_groupid` int(11) unsigned NOT NULL DEFAULT '0',
  `sys_perm_user` varchar(5) DEFAULT NULL,
  `sys_perm_group` varchar(5) DEFAULT NULL,
  `sys_perm_other` varchar(5) DEFAULT NULL,
  `server_id` int(11) NOT NULL DEFAULT '0',
  `customer_id` int(4) NOT NULL DEFAULT '0',
  `package_id` int(4) NOT NULL DEFAULT '0',
  `instance_status` int(4) NOT NULL DEFAULT '0',
  PRIMARY KEY (`id`)
) DEFAULT CHARSET=utf8mb4 ;

-- --------------------------------------------------------

--
-- Table structure for table `aps_instances_settings`
--

CREATE TABLE IF NOT EXISTS `aps_instances_settings` (
  `id` int(4) NOT NULL AUTO_INCREMENT,
  `server_id` int(11) NOT NULL DEFAULT '0',
  `instance_id` int(4) NOT NULL DEFAULT '0',
  `name` varchar(255) NOT NULL DEFAULT '',
  `value` text,
  PRIMARY KEY (`id`)
) DEFAULT CHARSET=utf8mb4 ;

-- --------------------------------------------------------

--
-- Table structure for table `aps_packages`
--

CREATE TABLE IF NOT EXISTS `aps_packages` (
  `id` int(4) NOT NULL AUTO_INCREMENT,
  `path` varchar(255) NOT NULL DEFAULT '',
  `name` varchar(255) NOT NULL DEFAULT '',
  `category` varchar(255) NOT NULL DEFAULT '',
  `version` varchar(20) NOT NULL DEFAULT '',
  `release` int(4) NOT NULL DEFAULT '0',
  `package_url` TEXT,
  `package_status` int(1) NOT NULL DEFAULT '2',
  PRIMARY KEY (`id`)
) DEFAULT CHARSET=utf8mb4 ;

-- --------------------------------------------------------

--
-- Tabellenstruktur für Tabelle `aps_settings`
--

CREATE TABLE IF NOT EXISTS `aps_settings` (
  `id` int(4) NOT NULL AUTO_INCREMENT,
  `name` varchar(255) NOT NULL DEFAULT '',
  `value` text,
  PRIMARY KEY (`id`),
  UNIQUE KEY `name` (`name`)
) DEFAULT CHARSET=utf8mb4 ;

-- --------------------------------------------------------

--
-- Table structure for table `attempts_login`
--

CREATE TABLE `attempts_login` (
  `ip` varchar(39) NOT NULL DEFAULT '',
  `times` int(11) DEFAULT NULL,
  `login_time` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
) DEFAULT CHARSET=utf8mb4 ;

-- --------------------------------------------------------

--
-- Table structure for table `client`
--

CREATE TABLE `client` (
  `client_id` int(11) unsigned NOT NULL AUTO_INCREMENT,
  `sys_userid` int(11) unsigned NOT NULL DEFAULT '0',
  `sys_groupid` int(11) unsigned NOT NULL DEFAULT '0',
  `sys_perm_user` varchar(5) DEFAULT NULL,
  `sys_perm_group` varchar(5) DEFAULT NULL,
  `sys_perm_other` varchar(5) DEFAULT NULL,
  `company_name` varchar(64) DEFAULT NULL,
  `company_id` varchar(255) DEFAULT NULL,
  `gender` enum('','m','f') NOT NULL DEFAULT '',
  `contact_firstname` varchar( 64 ) NOT NULL DEFAULT '',
  `contact_name` varchar(64) DEFAULT NULL,
  `customer_no` varchar(64) DEFAULT NULL,
  `vat_id` varchar(64) DEFAULT NULL,
  `street` varchar(255) DEFAULT NULL,
  `zip` varchar(32) DEFAULT NULL,
  `city` varchar(64) DEFAULT NULL,
  `state` varchar(32) DEFAULT NULL,
  `country` char(2) DEFAULT NULL,
  `telephone` varchar(32) DEFAULT NULL,
  `mobile` varchar(32) DEFAULT NULL,
  `fax` varchar(32) DEFAULT NULL,
  `email` varchar(255) DEFAULT NULL,
  `internet` varchar(255) NOT NULL DEFAULT '',
  `icq` varchar(16) DEFAULT NULL,
  `notes` text,
  `bank_account_owner` varchar(255) DEFAULT NULL,
  `bank_account_number` varchar(255) DEFAULT NULL,
  `bank_code` varchar(255) DEFAULT NULL,
  `bank_name` varchar(255) DEFAULT NULL,
  `bank_account_iban` varchar(255) DEFAULT NULL,
  `bank_account_swift` varchar(255) DEFAULT NULL,
  `paypal_email` varchar(255) DEFAULT NULL,
  `default_mailserver` int(11) unsigned NOT NULL DEFAULT '1',
  `mail_servers` text,
  `limit_maildomain` int(11) NOT NULL DEFAULT '-1',
  `limit_mailbox` int(11) NOT NULL DEFAULT '-1',
  `limit_mailalias` int(11) NOT NULL DEFAULT '-1',
  `limit_mailaliasdomain` int(11) NOT NULL DEFAULT '-1',
  `limit_mailforward` int(11) NOT NULL DEFAULT '-1',
  `limit_mailcatchall` int(11) NOT NULL DEFAULT '-1',
  `limit_mailrouting` int(11) NOT NULL DEFAULT '0',
  `limit_mail_wblist` int(11) NOT NULL DEFAULT '0',
  `limit_mailfilter` int(11) NOT NULL DEFAULT '-1',
  `limit_fetchmail` int(11) NOT NULL DEFAULT '-1',
  `limit_mailquota` int(11) NOT NULL DEFAULT '-1',
  `limit_spamfilter_wblist` int(11) NOT NULL DEFAULT '0',
  `limit_spamfilter_user` int(11) NOT NULL DEFAULT '0',
  `limit_spamfilter_policy` int(11) NOT NULL DEFAULT '0',
  `limit_mail_backup` ENUM( 'n', 'y' ) NOT NULL DEFAULT 'y',
  `limit_relayhost` ENUM( 'n', 'y' ) NOT NULL DEFAULT 'n',
  `default_xmppserver` int(11) unsigned NOT NULL DEFAULT '1',
  `xmpp_servers` text,
  `limit_xmpp_domain` int(11) NOT NULL DEFAULT '-1',
  `limit_xmpp_user` int(11) NOT NULL DEFAULT '-1',
  `limit_xmpp_muc` ENUM( 'n', 'y' ) NOT NULL default 'n',
  `limit_xmpp_anon` ENUM( 'n', 'y' ) NOT NULL default 'n',
  `limit_xmpp_auth_options` varchar(255) NOT NULL DEFAULT 'plain,hashed,isp',
  `limit_xmpp_vjud` ENUM( 'n', 'y' ) NOT NULL default 'n',
  `limit_xmpp_proxy` ENUM( 'n', 'y' ) NOT NULL default 'n',
  `limit_xmpp_status` ENUM( 'n', 'y' ) NOT NULL default 'n',
  `limit_xmpp_pastebin` ENUM( 'n', 'y' ) NOT NULL default 'n',
  `limit_xmpp_httparchive` ENUM( 'n', 'y' ) NOT NULL default 'n',
  `default_webserver` int(11) unsigned NOT NULL DEFAULT '1',
  `web_servers` text,
  `limit_web_ip` text,
  `limit_web_domain` int(11) NOT NULL DEFAULT '-1',
  `limit_web_quota` int(11) NOT NULL DEFAULT '-1',
  `web_php_options` varchar(255) NOT NULL DEFAULT 'no,fast-cgi,cgi,mod,suphp,php-fpm,hhvm',
  `limit_cgi` enum('n','y') NOT NULL DEFAULT 'n',
  `limit_ssi` enum('n','y') NOT NULL DEFAULT 'n',
  `limit_perl` enum('n','y') NOT NULL DEFAULT 'n',
  `limit_ruby` enum('n','y') NOT NULL DEFAULT 'n',
  `limit_python` enum('n','y') NOT NULL DEFAULT 'n',
  `force_suexec` enum('n','y') NOT NULL DEFAULT 'y',
  `limit_hterror` enum('n','y') NOT NULL DEFAULT 'n',
  `limit_wildcard` enum('n','y') NOT NULL DEFAULT 'n',
  `limit_ssl` enum('n','y') NOT NULL DEFAULT 'n',
  `limit_ssl_letsencrypt` enum('n','y') NOT NULL DEFAULT 'n',
  `limit_web_subdomain` int(11) NOT NULL DEFAULT '-1',
  `limit_web_aliasdomain` int(11) NOT NULL DEFAULT '-1',
  `limit_ftp_user` int(11) NOT NULL DEFAULT '-1',
  `limit_shell_user` int(11) NOT NULL DEFAULT '0',
  `ssh_chroot` varchar(255) NOT NULL DEFAULT 'no,jailkit,ssh-chroot',
  `limit_webdav_user` int(11) NOT NULL DEFAULT '0',
  `limit_backup` ENUM( 'n', 'y' ) NOT NULL DEFAULT 'y',
  `limit_directive_snippets` ENUM( 'n', 'y' ) NOT NULL DEFAULT 'n',
  `limit_aps` int(11) NOT NULL DEFAULT '-1',
  `default_dnsserver` int(11) unsigned NOT NULL DEFAULT '1',
  `db_servers` text,
  `limit_dns_zone` int(11) NOT NULL DEFAULT '-1',
  `default_slave_dnsserver` int(11) unsigned NOT NULL DEFAULT '1',
  `limit_dns_slave_zone` int(11) NOT NULL DEFAULT '-1',
  `limit_dns_record` int(11) NOT NULL DEFAULT '-1',
  `default_dbserver` int(11) NOT NULL DEFAULT '1',
  `dns_servers` text,
  `limit_database` int(11) NOT NULL DEFAULT '-1',
  `limit_database_postgresql` int(11) NOT NULL default '-1',
  `limit_database_user` int(11) NOT NULL DEFAULT '-1',
  `limit_database_quota` int(11) NOT NULL default '-1',
  `limit_cron` int(11) NOT NULL DEFAULT '0',
  `limit_cron_type` enum('url','chrooted','full') NOT NULL DEFAULT 'url',
  `limit_cron_frequency` int(11) NOT NULL DEFAULT '5',
  `limit_traffic_quota` int(11) NOT NULL DEFAULT '-1',
  `limit_client` int(11) NOT NULL DEFAULT '0',
  `limit_domainmodule` int(11) NOT NULL DEFAULT '0',
  `limit_mailmailinglist` int(11) NOT NULL DEFAULT '-1',
  `limit_openvz_vm` int(11) NOT NULL DEFAULT '0',
  `limit_openvz_vm_template_id` int(11) NOT NULL DEFAULT '0',
  `parent_client_id` int(11) unsigned NOT NULL DEFAULT '0',
  `username` varchar(64) DEFAULT NULL,
  `password` varchar(200) DEFAULT NULL,
  `language` char(2) NOT NULL DEFAULT 'en',
  `usertheme` varchar(32) NOT NULL DEFAULT 'algopanel',
  `template_master` int(11) unsigned NOT NULL DEFAULT '0',
  `template_additional` text,
  `created_at` bigint(20) DEFAULT NULL,
  `locked` enum('n','y') NOT NULL DEFAULT 'n',
  `canceled` enum('n','y') NOT NULL DEFAULT 'n',
  `can_use_api` enum('n','y') NOT NULL DEFAULT 'n',
  `tmp_data` mediumblob,
  `id_rsa` text,
  `ssh_rsa` text,
  `customer_no_template` varchar(255) DEFAULT 'R[CLIENTID]C[CUSTOMER_NO]',
  `customer_no_start` int(11) NOT NULL DEFAULT '1',
  `customer_no_counter` int(11) NOT NULL DEFAULT '0',
  `added_date` date NULL DEFAULT NULL,
  `added_by` varchar(255) DEFAULT NULL,
  `validation_status` enum('accept','review','reject') NOT NULL DEFAULT 'accept',
  `risk_score` int(10) unsigned NOT NULL DEFAULT '0',
  `activation_code` varchar(10) NOT NULL DEFAULT '',
  PRIMARY KEY (`client_id`)
) DEFAULT CHARSET=utf8mb4 AUTO_INCREMENT=1 ;

-- --------------------------------------------------------

--
-- Table structure for table `client_circle`
--

CREATE TABLE `client_circle` (
  `circle_id` int(11) NOT NULL AUTO_INCREMENT,
  `sys_userid` int(11) NOT NULL DEFAULT '0',
  `sys_groupid` int(11) NOT NULL DEFAULT '0',
  `sys_perm_user` varchar(5) DEFAULT NULL,
  `sys_perm_group` varchar(5) DEFAULT NULL,
  `sys_perm_other` varchar(5) DEFAULT NULL,
  `circle_name` varchar(64) DEFAULT NULL,
  `client_ids` text,
  `description` text,
  `active` enum('n','y') NOT NULL default 'y',
  PRIMARY KEY (`circle_id`)
) DEFAULT CHARSET=utf8mb4 AUTO_INCREMENT=1 ;

-- --------------------------------------------------------

--
-- Table structure for table  `client_template`
--

CREATE TABLE `client_template` (
  `template_id` int(11) unsigned NOT NULL auto_increment,
  `sys_userid` int(11) unsigned NOT NULL default '0',
  `sys_groupid` int(11) unsigned NOT NULL default '0',
  `sys_perm_user` varchar(5) default NULL,
  `sys_perm_group` varchar(5) default NULL,
  `sys_perm_other` varchar(5) default NULL,
  `template_name` varchar(64) NOT NULL DEFAULT '',
  `template_type` varchar(1) NOT NULL default 'm',
  `mail_servers` text,
  `limit_maildomain` int(11) NOT NULL default '-1',
  `limit_mailbox` int(11) NOT NULL default '-1',
  `limit_mailalias` int(11) NOT NULL default '-1',
  `limit_mailaliasdomain` int(11) NOT NULL default '-1',
  `limit_mailforward` int(11) NOT NULL default '-1',
  `limit_mailcatchall` int(11) NOT NULL default '-1',
  `limit_mailrouting` int(11) NOT NULL default '0',
  `limit_mail_wblist` int(11) NOT NULL default '0',
  `limit_mailfilter` int(11) NOT NULL default '-1',
  `limit_fetchmail` int(11) NOT NULL default '-1',
  `limit_mailquota` int(11) NOT NULL default '-1',
  `limit_spamfilter_wblist` int(11) NOT NULL default '0',
  `limit_spamfilter_user` int(11) NOT NULL default '0',
  `limit_spamfilter_policy` int(11) NOT NULL default '0',
  `limit_mail_backup` ENUM( 'n', 'y' ) NOT NULL DEFAULT 'y',
  `limit_relayhost` ENUM( 'n', 'y' ) NOT NULL DEFAULT 'n',
  `default_xmppserver` int(11) unsigned NOT NULL DEFAULT '1',
  `xmpp_servers` text,
  `limit_xmpp_domain` int(11) NOT NULL DEFAULT '-1',
  `limit_xmpp_user` int(11) NOT NULL DEFAULT '-1',
  `limit_xmpp_muc` ENUM( 'n', 'y' ) NOT NULL default 'n',
  `limit_xmpp_anon` ENUM( 'n', 'y' ) NOT NULL default 'n',
  `limit_xmpp_vjud` ENUM( 'n', 'y' ) NOT NULL default 'n',
  `limit_xmpp_proxy` ENUM( 'n', 'y' ) NOT NULL default 'n',
  `limit_xmpp_status` ENUM( 'n', 'y' ) NOT NULL default 'n',
  `limit_xmpp_pastebin` ENUM( 'n', 'y' ) NOT NULL default 'n',
  `limit_xmpp_httparchive` ENUM( 'n', 'y' ) NOT NULL default 'n',
  `web_servers` text,
  `limit_web_ip` text,
  `limit_web_domain` int(11) NOT NULL default '-1',
  `limit_web_quota` int(11) NOT NULL default '-1',
  `web_php_options` varchar(255) NOT NULL DEFAULT '',
  `limit_cgi` enum('n','y') NOT NULL DEFAULT 'n',
  `limit_ssi` enum('n','y') NOT NULL DEFAULT 'n',
  `limit_perl` enum('n','y') NOT NULL DEFAULT 'n',
  `limit_ruby` enum('n','y') NOT NULL DEFAULT 'n',
  `limit_python` enum('n','y') NOT NULL DEFAULT 'n',
  `force_suexec` enum('n','y') NOT NULL DEFAULT 'y',
  `limit_hterror` enum('n','y') NOT NULL DEFAULT 'n',
  `limit_wildcard` enum('n','y') NOT NULL DEFAULT 'n',
  `limit_ssl` enum('n','y') NOT NULL DEFAULT 'n',
  `limit_ssl_letsencrypt` enum('n','y') NOT NULL DEFAULT 'n',
  `limit_web_subdomain` int(11) NOT NULL default '-1',
  `limit_web_aliasdomain` int(11) NOT NULL default '-1',
  `limit_ftp_user` int(11) NOT NULL default '-1',
  `limit_shell_user` int(11) NOT NULL default '0',
  `ssh_chroot` varchar(255) NOT NULL DEFAULT '',
  `limit_webdav_user` int(11) NOT NULL default '0',
  `limit_backup` ENUM( 'n', 'y' ) NOT NULL DEFAULT 'y',
  `limit_directive_snippets` ENUM( 'n', 'y' ) NOT NULL DEFAULT 'n',
  `limit_aps` int(11) NOT NULL DEFAULT '-1',
  `dns_servers` text,
  `limit_dns_zone` int(11) NOT NULL default '-1',
  `default_slave_dnsserver` int(11) NOT NULL DEFAULT '0',
  `limit_dns_slave_zone` int(11) NOT NULL default '-1',
  `limit_dns_record` int(11) NOT NULL default '-1',
  `db_servers` text,
  `limit_database` int(11) NOT NULL default '-1',
  `limit_database_postgresql` int(11) NOT NULL default '-1',
  `limit_database_user` int(11) NOT NULL DEFAULT '-1',
  `limit_database_quota` int(11) NOT NULL default '-1',
  `limit_cron` int(11) NOT NULL default '0',
  `limit_cron_type` enum('url','chrooted','full') NOT NULL default 'url',
  `limit_cron_frequency` int(11) NOT NULL default '5',
  `limit_traffic_quota` int(11) NOT NULL default '-1',
  `limit_client` int(11) NOT NULL default '0',
  `limit_domainmodule` int(11) NOT NULL DEFAULT '0',
  `limit_mailmailinglist` int(11) NOT NULL default '-1',
  `limit_openvz_vm` int(11) NOT NULL DEFAULT '0',
  `limit_openvz_vm_template_id` int(11) NOT NULL DEFAULT '0',
  PRIMARY KEY  (`template_id`)
) DEFAULT CHARSET=utf8mb4 AUTO_INCREMENT=1 ;

-- --------------------------------------------------------

--
-- Table structure for table  `client_template_assigned`
--

CREATE TABLE `client_template_assigned` (
  `assigned_template_id` bigint(20) NOT NULL auto_increment,
  `client_id` bigint(11) NOT NULL DEFAULT '0',
  `client_template_id` int(11) NOT NULL DEFAULT '0',
  PRIMARY KEY (`assigned_template_id`),
  KEY `client_id` (`client_id`)
) DEFAULT CHARSET=utf8mb4 AUTO_INCREMENT=1 ;
-- --------------------------------------------------------

--
-- Table structure for table `invoice_message_template`
--

CREATE TABLE `client_message_template` (
  `client_message_template_id` bigint(20) NOT NULL AUTO_INCREMENT,
  `sys_userid` int(11) NOT NULL DEFAULT '0',
  `sys_groupid` int(11) NOT NULL DEFAULT '0',
  `sys_perm_user` varchar(5) DEFAULT NULL,
  `sys_perm_group` varchar(5) DEFAULT NULL,
  `sys_perm_other` varchar(5) DEFAULT NULL,
  `template_type` varchar(255) DEFAULT NULL,
  `template_name` varchar(255) DEFAULT NULL,
  `subject` varchar(255) DEFAULT NULL,
  `message` text,
  PRIMARY KEY (`client_message_template_id`)
) DEFAULT CHARSET=utf8mb4 AUTO_INCREMENT=1 ;

--
-- Dumping data for table `invoice_message_template`
--

-- --------------------------------------------------------

--
-- Table structure for table `country`
--

CREATE TABLE `country` (
  `iso` char(2) NOT NULL DEFAULT '',
  `name` varchar(64) NOT NULL DEFAULT '',
  `printable_name` varchar(64) NOT NULL DEFAULT '',
  `iso3` char(3) DEFAULT NULL,
  `numcode` smallint(6) DEFAULT NULL,
  `eu` enum('n','y') NOT NULL DEFAULT 'n',
  PRIMARY KEY (`iso`)
) DEFAULT CHARSET=utf8mb4 ;

-- --------------------------------------------------------

--
-- Table structure for table  `cron`
--
CREATE TABLE `cron` (
  `id` int(11) unsigned NOT NULL auto_increment,
  `sys_userid` int(11) unsigned NOT NULL default '0',
  `sys_groupid` int(11) unsigned NOT NULL default '0',
  `sys_perm_user` varchar(5) NULL default NULL,
  `sys_perm_group` varchar(5) NULL default NULL,
  `sys_perm_other` varchar(5) NULL default NULL,
  `server_id` int(11) unsigned NOT NULL default '0',
  `parent_domain_id` int(11) unsigned NOT NULL default '0',
  `type` enum('url','chrooted','full') NOT NULL default 'url',
  `command` TEXT,
  `run_min` varchar(100) NULL,
  `run_hour` varchar(100) NULL,
  `run_mday` varchar(100) NULL,
  `run_month` varchar(100) NULL,
  `run_wday` varchar(100) NULL,
  `log` enum('n','y') NOT NULL default 'n',
  `active` enum('n','y') NOT NULL default 'y',
  PRIMARY KEY  (`id`)
) DEFAULT CHARSET=utf8mb4 AUTO_INCREMENT=1 ;

-- --------------------------------------------------------

--
-- Table structure for table  `directive_snippets`
--

CREATE TABLE IF NOT EXISTS `directive_snippets` (
  `directive_snippets_id` int(11) unsigned NOT NULL AUTO_INCREMENT,
  `sys_userid` int(11) unsigned NOT NULL DEFAULT '0',
  `sys_groupid` int(11) unsigned NOT NULL DEFAULT '0',
  `sys_perm_user` varchar(5) DEFAULT NULL,
  `sys_perm_group` varchar(5) DEFAULT NULL,
  `sys_perm_other` varchar(5) DEFAULT NULL,
  `name` varchar(255) DEFAULT NULL,
  `type` varchar(255) DEFAULT NULL,
  `snippet` mediumtext,
  `customer_viewable` ENUM('n','y') NOT NULL DEFAULT 'n',
  `required_php_snippets` varchar(255) NOT NULL DEFAULT '',
  `active` enum('n','y') NOT NULL DEFAULT 'y',
  `master_directive_snippets_id` int(11) unsigned NOT NULL DEFAULT '0',
  `update_sites` ENUM('y','n') NOT NULL DEFAULT 'n',
  PRIMARY KEY (`directive_snippets_id`)
) DEFAULT CHARSET=utf8mb4 AUTO_INCREMENT=1 ;

INSERT INTO `directive_snippets` (`directive_snippets_id`, `sys_userid`, `sys_groupid`, `sys_perm_user`, `sys_perm_group`, `sys_perm_other`, `name`, `type`, `snippet`, `customer_viewable`, `required_php_snippets`, `active`, `master_directive_snippets_id`, `update_sites`) VALUES
(1, 1, 1, 'riud', 'riud', '', 'Wordpress', 'nginx', 'location / {\n    try_files $uri $uri/ /index.php?$args;\n}\n\nrewrite /wp-admin$ $scheme://$host$uri/ permanent;\n\nlocation ~* /wp-includes/.*\\.php$ {\n    deny all;\n    access_log off;\n    log_not_found off;\n}\n\nlocation ~* /wp-content/.*\\.php$ {\n    deny all;\n    access_log off;\n    log_not_found off;\n}\n\nlocation ~* /wp-content/uploads/.*\\.php$ {\n    deny all;\n    access_log off;\n    log_not_found off;\n}\n\nlocation = /xmlrpc.php {\n    deny all;\n    access_log off;\n    log_not_found off;\n}\n\nlocation /wp-content/uploads/ {\n    location ~* \\.(php|phtml)$ {\n        deny all;\n    }\n}\n\nlocation ~* \\.(js|css|png|jpg|jpeg|gif|ico|svg|woff|woff2)$ {\n    expires max;\n    log_not_found off;\n    access_log off;\n}', 'y', '', 'y', 0, 'n');

-- --------------------------------------------------------

--
-- Table structure for table  `dns_rr`
--
CREATE TABLE `dns_rr` (
  `id` int(11) unsigned NOT NULL auto_increment,
  `sys_userid` int(11) unsigned NOT NULL DEFAULT '0',
  `sys_groupid` int(11) unsigned NOT NULL DEFAULT '0',
  `sys_perm_user` varchar(5) NOT NULL DEFAULT '',
  `sys_perm_group` varchar(5) NOT NULL DEFAULT '',
  `sys_perm_other` varchar(5) NOT NULL DEFAULT '',
  `server_id` int(11) NOT NULL default '1',
  `zone` int(11) unsigned NOT NULL DEFAULT '0',
  `name` varchar(255) NOT NULL DEFAULT '',
  `type` enum('A','AAAA','ALIAS','CNAME','DNAME','CAA','DS','HINFO','LOC','MX','NAPTR','NS','PTR','RP','SRV','SSHFP','TXT','TLSA','DNSKEY') default NULL,
  `data` TEXT NOT NULL,
  `aux` int(11) unsigned NOT NULL default '0',
  `ttl` int(11) unsigned NOT NULL default '3600',
  `active` enum('N','Y') NOT NULL default 'Y',
  `stamp` timestamp NOT NULL default CURRENT_TIMESTAMP,
  `serial` int(10) unsigned default NULL,
  PRIMARY KEY  (`id`),
  KEY `rr` (`zone`,`type`,`name`)
) DEFAULT CHARSET=utf8mb4 AUTO_INCREMENT=1 ;

-- --------------------------------------------------------

--
-- Table structure for table  `dns_slave`
--

CREATE TABLE `dns_slave` (
  `id` int(10) unsigned NOT NULL auto_increment,
  `sys_userid` int(11) unsigned NOT NULL DEFAULT '0',
  `sys_groupid` int(11) unsigned NOT NULL DEFAULT '0',
  `sys_perm_user` varchar(5) NOT NULL DEFAULT '',
  `sys_perm_group` varchar(5) NOT NULL DEFAULT '',
  `sys_perm_other` varchar(5) NOT NULL DEFAULT '',
  `server_id` int(11) NOT NULL default '1',
  `origin` varchar(255) NOT NULL DEFAULT '',
  `ns` varchar(255) NOT NULL DEFAULT '',
  `active` enum('N','Y') NOT NULL DEFAULT 'N',
  `xfer` TEXT NULL,
  PRIMARY KEY  (`id`),
  UNIQUE KEY `slave` (`origin`,`server_id`),
  KEY `active` (`active`)
) DEFAULT CHARSET=utf8mb4 AUTO_INCREMENT=1 ;

-- --------------------------------------------------------

--
-- Table structure for table  `dns_ssl_ca`
--

CREATE TABLE IF NOT EXISTS `dns_ssl_ca` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `sys_userid` int(11) unsigned NOT NULL DEFAULT '0',
  `sys_groupid` int(11) unsigned NOT NULL DEFAULT '0',
  `sys_perm_user` varchar(5) NOT NULL DEFAULT '',
  `sys_perm_group` varchar(5) NOT NULL DEFAULT '',
  `sys_perm_other` varchar(5) NOT NULL DEFAULT '',
  `active` enum('N','Y') NOT NULL DEFAULT 'N',
  `ca_name` varchar(255) NOT NULL DEFAULT '',
  `ca_issue` varchar(255) NOT NULL DEFAULT '',
  `ca_wildcard` enum('Y','N') NOT NULL DEFAULT 'N',
  `ca_iodef` text NOT NULL,
  `ca_critical` tinyint(1) NOT NULL DEFAULT '0',
  PRIMARY KEY (`id`),
  UNIQUE KEY (`ca_issue`)
) DEFAULT CHARSET=utf8mb4 AUTO_INCREMENT=1 ;

ALTER TABLE `dns_ssl_ca` ADD UNIQUE(`ca_issue`);

INSERT INTO `dns_ssl_ca`
  (`id`, `sys_userid`, `sys_groupid`, `sys_perm_user`, `sys_perm_group`, `sys_perm_other`, `active`, `ca_name`, `ca_issue`, `ca_wildcard`, `ca_iodef`, `ca_critical`)
VALUES
  (NULL, 1, 1, 'riud', 'riud', '', 'Y', 'ACCV',                                    'accv.es',                 'Y', '', 0),
  (NULL, 1, 1, 'riud', 'riud', '', 'Y', 'Actalis',                                  'actalis.it',              'Y', '', 0),
  (NULL, 1, 1, 'riud', 'riud', '', 'Y', 'Amazon Trust Services',                    'amazon.com',              'Y', '', 0),
  (NULL, 1, 1, 'riud', 'riud', '', 'Y', 'ANF AC',                                   'anf.es',                  'Y', '', 0),
  (NULL, 1, 1, 'riud', 'riud', '', 'Y', 'Apple',                                    'pki.apple.com',           'Y', '', 0),
  (NULL, 1, 1, 'riud', 'riud', '', 'Y', 'BJCA',                                     'bjca.cn',                 'Y', '', 0),
  (NULL, 1, 1, 'riud', 'riud', '', 'Y', 'Buypass',                                  'buypass.com',             'Y', '', 0),
  (NULL, 1, 1, 'riud', 'riud', '', 'Y', 'CATCert',                                  'aoc.cat',                 'Y', '', 0),
  (NULL, 1, 1, 'riud', 'riud', '', 'Y', 'Certicámara',                              'certicamara.com',         'Y', '', 0),
  (NULL, 1, 1, 'riud', 'riud', '', 'Y', 'Certigna',                                 'certigna.fr',             'Y', '', 0),
  (NULL, 1, 1, 'riud', 'riud', '', 'Y', 'Certainly',                                'certainly.com',           'Y', '', 0),
  (NULL, 1, 1, 'riud', 'riud', '', 'Y', 'certSIGN',                                 'certsign.ro',             'Y', '', 0),
  (NULL, 1, 1, 'riud', 'riud', '', 'Y', 'Certinomis (Docaposte)',                   'www.certinomis.com',      'Y', '', 0),
  (NULL, 1, 1, 'riud', 'riud', '', 'Y', 'Certizen',                                 'ecert.gov.hk',            'Y', '', 0),
  (NULL, 1, 1, 'riud', 'riud', '', 'Y', 'Certum (Asseco Data Systems)',             'certum.pl',               'Y', '', 0),
  (NULL, 1, 1, 'riud', 'riud', '', 'Y', 'CFCA',                                     'cfca.com.cn',             'Y', '', 0),
  (NULL, 1, 1, 'riud', 'riud', '', 'Y', 'Chunghwa Telecom',                         'pki.hinet.net',           'Y', '', 0),
  (NULL, 1, 1, 'riud', 'riud', '', 'Y', 'Cybertrust Japan / JCSI',                  'cybertrust.co.jp',        'Y', '', 0),
  (NULL, 1, 1, 'riud', 'riud', '', 'Y', 'Deutsche Telekom Security (T-Systems)',    'telesec.de',              'Y', '', 0),
  (NULL, 1, 1, 'riud', 'riud', '', 'Y', 'DFN-PKI',                                  'pki.dfn.de',              'Y', '', 0),
  (NULL, 1, 1, 'riud', 'riud', '', 'Y', 'DigiCert (incl. Thawte, GeoTrust, RapidSSL)', 'digicert.com',        'Y', '', 0),
  (NULL, 1, 1, 'riud', 'riud', '', 'Y', 'D-TRUST',                                  'dtrust.de',               'Y', '', 0),
  (NULL, 1, 1, 'riud', 'riud', '', 'Y', 'EDICOM',                                   'edicomgroup.com',         'Y', '', 0),
  (NULL, 1, 1, 'riud', 'riud', '', 'Y', 'emSign (eMudhra)',                          'emsign.com',              'Y', '', 0),
  (NULL, 1, 1, 'riud', 'riud', '', 'Y', 'e-tugra',                                  'e-tugra.com',             'Y', '', 0),
  (NULL, 1, 1, 'riud', 'riud', '', 'Y', 'Eviden (Atos TrustedRoot)',                'atos.net',                'Y', '', 0),
  (NULL, 1, 1, 'riud', 'riud', '', 'Y', 'Firmaprofesional',                         'firmaprofesional.com',    'Y', '', 0),
  (NULL, 1, 1, 'riud', 'riud', '', 'Y', 'FNMT',                                     'fnmt.es',                 'Y', '', 0),
  (NULL, 1, 1, 'riud', 'riud', '', 'Y', 'GDCA',                                     'gdca.com.cn',             'Y', '', 0),
  (NULL, 1, 1, 'riud', 'riud', '', 'Y', 'GlobalSign',                               'globalsign.com',          'Y', '', 0),
  (NULL, 1, 1, 'riud', 'riud', '', 'Y', 'GLOBALTRUST',                              'globaltrust.eu',          'Y', '', 0),
  (NULL, 1, 1, 'riud', 'riud', '', 'Y', 'GoDaddy',                                  'godaddy.com',             'Y', '', 0),
  (NULL, 1, 1, 'riud', 'riud', '', 'Y', 'Google Trust Services',                    'pki.goog',                'Y', '', 0),
  (NULL, 1, 1, 'riud', 'riud', '', 'Y', 'GRCA',                                     'gca.nat.gov.tw',          'Y', '', 0),
  (NULL, 1, 1, 'riud', 'riud', '', 'Y', 'HARICA',                                   'harica.gr',               'Y', '', 0),
  (NULL, 1, 1, 'riud', 'riud', '', 'Y', 'IdenTrust',                                'identrust.com',           'Y', '', 0),
  (NULL, 1, 1, 'riud', 'riud', '', 'Y', 'iTrusChina',                               'itrus.cn',                'Y', '', 0),
  (NULL, 1, 1, 'riud', 'riud', '', 'Y', 'Izenpe',                                   'izenpe.com',              'Y', '', 0),
  (NULL, 1, 1, 'riud', 'riud', '', 'Y', 'Kamu SM',                                  'kamusm.gov.tr',           'Y', '', 0),
  (NULL, 1, 1, 'riud', 'riud', '', 'Y', 'KIR (Poland)',                             'elektronicznypodpis.pl',  'Y', '', 0),
  (NULL, 1, 1, 'riud', 'riud', '', 'Y', 'KPN',                                      'kpn.com',                 'Y', '', 0),
  (NULL, 1, 1, 'riud', 'riud', '', 'Y', 'Let''s Encrypt',                           'letsencrypt.org',         'Y', '', 0),
  (NULL, 1, 1, 'riud', 'riud', '', 'Y', 'Microsec (e-Szigno)',                      'e-szigno.hu',             'Y', '', 0),
  (NULL, 1, 1, 'riud', 'riud', '', 'Y', 'MULTICERT',                                'multicert.com',           'Y', '', 0),
  (NULL, 1, 1, 'riud', 'riud', '', 'Y', 'NAVER Cloud Trust Services',               'navercloudtrust.com',     'Y', '', 0),
  (NULL, 1, 1, 'riud', 'riud', '', 'Y', 'NetLock',                                  'netlock.hu',              'Y', '', 0),
  (NULL, 1, 1, 'riud', 'riud', '', 'Y', 'Network Solutions (Web.com)',               'web.com',                 'Y', '', 0),
  (NULL, 1, 1, 'riud', 'riud', '', 'Y', 'OISTE (WISeKey)',                           'wisekey.com',             'Y', '', 0),
  (NULL, 1, 1, 'riud', 'riud', '', 'Y', 'PKIoverheid',                              'pkioverheid.nl',          'Y', '', 0),
  (NULL, 1, 1, 'riud', 'riud', '', 'Y', 'PostSignum',                               'postsignum.cz',           'Y', '', 0),
  (NULL, 1, 1, 'riud', 'riud', '', 'Y', 'QuoVadis',                                 'quovadisglobal.com',      'Y', '', 0),
  (NULL, 1, 1, 'riud', 'riud', '', 'Y', 'SECOM',                                    'secomtrust.net',          'Y', '', 0),
  (NULL, 1, 1, 'riud', 'riud', '', 'Y', 'Sectigo',                                  'sectigo.com',             'Y', '', 0),
  (NULL, 1, 1, 'riud', 'riud', '', 'Y', 'SHECA',                                    'sheca.com',               'Y', '', 0),
  (NULL, 1, 1, 'riud', 'riud', '', 'Y', 'SK ID Solutions',                          'skidsolutions.eu',        'Y', '', 0),
  (NULL, 1, 1, 'riud', 'riud', '', 'Y', 'SSL.com',                                  'ssl.com',                 'Y', '', 0),
  (NULL, 1, 1, 'riud', 'riud', '', 'Y', 'SwissSign',                                'swisssign.com',           'Y', '', 0),
  (NULL, 1, 1, 'riud', 'riud', '', 'Y', 'Swiss Federal IT (FOITT)',                 'admin.ch',                'Y', '', 0),
  (NULL, 1, 1, 'riud', 'riud', '', 'Y', 'Telia',                                    'telia.com',               'Y', '', 0),
  (NULL, 1, 1, 'riud', 'riud', '', 'Y', 'TrustAsia',                                'trustasia.com',           'Y', '', 0),
  (NULL, 1, 1, 'riud', 'riud', '', 'Y', 'TunTrust (ANCE)',                          'tuntrust.tn',             'Y', '', 0),
  (NULL, 1, 1, 'riud', 'riud', '', 'Y', 'TWCA',                                     'twca.com.tw',             'Y', '', 0),
  (NULL, 1, 1, 'riud', 'riud', '', 'Y', 'Viking Cloud (Trustwave)',                  'trustwave.com',           'Y', '', 0);

-- --------------------------------------------------------

--
-- Table structure for table  `dns_soa`
--

CREATE TABLE `dns_soa` (
  `id` int(10) unsigned NOT NULL auto_increment,
  `sys_userid` int(11) unsigned NOT NULL DEFAULT '0',
  `sys_groupid` int(11) unsigned NOT NULL DEFAULT '0',
  `sys_perm_user` varchar(5) NOT NULL DEFAULT '',
  `sys_perm_group` varchar(5) NOT NULL DEFAULT '',
  `sys_perm_other` varchar(5) NOT NULL DEFAULT '',
  `server_id` int(11) NOT NULL default '1',
  `origin` varchar(255) NOT NULL DEFAULT '',
  `ns` varchar(255) NOT NULL DEFAULT '',
  `mbox` varchar(255) NOT NULL DEFAULT '',
  `serial` int(11) unsigned NOT NULL default '1',
  `refresh` int(11) unsigned NOT NULL default '28800',
  `retry` int(11) unsigned NOT NULL default '7200',
  `expire` int(11) unsigned NOT NULL default '604800',
  `minimum` int(11) unsigned NOT NULL default '3600',
  `ttl` int(11) unsigned NOT NULL default '3600',
  `active` enum('N','Y') NOT NULL DEFAULT 'N',
  `xfer` TEXT NULL,
  `also_notify` TEXT NULL,
  `update_acl` varchar(255) default NULL,
  `dnssec_initialized` ENUM('Y','N') NOT NULL DEFAULT 'N',
  `dnssec_wanted` ENUM('Y','N') NOT NULL DEFAULT 'N',
  `dnssec_algo` SET('NSEC3RSASHA1','ECDSAP256SHA256') NOT NULL DEFAULT 'ECDSAP256SHA256',
  `dnssec_last_signed` BIGINT NOT NULL DEFAULT '0',
  `dnssec_info` TEXT NULL,
  `rendered_zone` MEDIUMTEXT NULL,
  PRIMARY KEY  (`id`),
  UNIQUE KEY `origin` (`origin`),
  KEY `active` (`active`)
) DEFAULT CHARSET=utf8mb4 AUTO_INCREMENT=1 ;

-- --------------------------------------------------------

--
-- Table structure for table  `dns_template`
--

CREATE TABLE `dns_template` (
  `template_id` int(11) unsigned NOT NULL auto_increment,
  `sys_userid` int(11) unsigned NOT NULL default '0',
  `sys_groupid` int(11) unsigned NOT NULL default '0',
  `sys_perm_user` varchar(5) default NULL,
  `sys_perm_group` varchar(5) default NULL,
  `sys_perm_other` varchar(5) default NULL,
  `name` varchar(64) default NULL,
  `fields` varchar(255) default NULL,
  `template` text,
  `visible` enum('N','Y') NOT NULL default 'Y',
  PRIMARY KEY  (`template_id`)
) DEFAULT CHARSET=utf8mb4 AUTO_INCREMENT=1 ;

--
-- Table structure for table  `domain`
--

CREATE TABLE `domain` (
  `domain_id` int(11) unsigned NOT NULL auto_increment,
  `sys_userid` int(11) unsigned NOT NULL default '0',
  `sys_groupid` int(11) unsigned NOT NULL default '0',
  `sys_perm_user` varchar(5) NOT NULL default '',
  `sys_perm_group` varchar(5) NOT NULL default '',
  `sys_perm_other` varchar(5) NOT NULL default '',
  `domain` varchar(255) NOT NULL default '',
  PRIMARY KEY  (`domain_id`),
  UNIQUE KEY `domain` (`domain`)
) DEFAULT CHARSET=utf8mb4 ;

-- --------------------------------------------------------

--
-- Table structure for table  `firewall`
--

CREATE TABLE `firewall` (
  `firewall_id` int(11) unsigned NOT NULL auto_increment,
  `sys_userid` int(11) unsigned NOT NULL default '0',
  `sys_groupid` int(11) unsigned NOT NULL default '0',
  `sys_perm_user` varchar(5) default NULL,
  `sys_perm_group` varchar(5) default NULL,
  `sys_perm_other` varchar(5) default NULL,
  `server_id` int(11) unsigned NOT NULL default '0',
  `tcp_port` text,
  `udp_port` text,
  `active` enum('n','y') NOT NULL default 'y',
  PRIMARY KEY  (`firewall_id`)
) DEFAULT CHARSET=utf8mb4 AUTO_INCREMENT=1 ;

-- --------------------------------------------------------

--
-- Table structure for table  `ftp_user`
--

CREATE TABLE `ftp_user` (
  `ftp_user_id` int(11) unsigned NOT NULL auto_increment,
  `sys_userid` int(11) unsigned NOT NULL default '0',
  `sys_groupid` int(11) unsigned NOT NULL default '0',
  `sys_perm_user` varchar(5) default NULL,
  `sys_perm_group` varchar(5) default NULL,
  `sys_perm_other` varchar(5) default NULL,
  `server_id` int(11) unsigned NOT NULL default '0',
  `parent_domain_id` int(11) unsigned NOT NULL default '0',
  `username` varchar(64) default NULL,
  `username_prefix` varchar(50) NOT NULL default '',
  `password` varchar(200) default NULL,
  `quota_size` bigint(20) NOT NULL default '-1',
  `active` enum('n','y') NOT NULL default 'y',
  `uid` varchar(64) default NULL,
  `gid` varchar(64) default NULL,
  `dir` varchar(255) default NULL,
  `quota_files` bigint(20) NOT NULL default '-1',
  `ul_ratio` int(11) NOT NULL default '-1',
  `dl_ratio` int(11) NOT NULL default '-1',
  `ul_bandwidth` int(11) NOT NULL default '-1',
  `dl_bandwidth` int(11) NOT NULL default '-1',
  `expires` datetime NULL DEFAULT NULL,
  `user_type` set('user','system') NOT NULL DEFAULT 'user',
  `user_config` text,
  PRIMARY KEY  (`ftp_user_id`),
  KEY `active` (`active`),
  KEY `server_id` (`server_id`),
  KEY `username` (`username`),
  KEY `quota_files` (`quota_files`)
) DEFAULT CHARSET=utf8mb4 AUTO_INCREMENT=1 ;

-- --------------------------------------------------------

--
-- Table structure for table  `ftp_traffic`
--

CREATE TABLE `ftp_traffic` (
  `hostname` varchar(255) NOT NULL,
  `traffic_date` date NOT NULL,
  `in_bytes` bigint(32) unsigned NOT NULL,
  `out_bytes` bigint(32) unsigned NOT NULL,
  UNIQUE KEY (`hostname`,`traffic_date`)
) DEFAULT CHARSET=utf8mb4 AUTO_INCREMENT=1 ;

-- --------------------------------------------------------

--
-- Table structure for table `help_faq`
--

CREATE TABLE `help_faq` (
  `hf_id` int(11) NOT NULL AUTO_INCREMENT,
  `hf_section` int(11) DEFAULT NULL,
  `hf_order` int(11) DEFAULT '0',
  `hf_question` text,
  `hf_answer` text,
  `sys_userid` int(11) DEFAULT NULL,
  `sys_groupid` int(11) DEFAULT NULL,
  `sys_perm_user` varchar(5) DEFAULT NULL,
  `sys_perm_group` varchar(5) DEFAULT NULL,
  `sys_perm_other` varchar(5) DEFAULT NULL,
  PRIMARY KEY (`hf_id`)
)  DEFAULT CHARSET=utf8mb4 AUTO_INCREMENT=1 ;

-- --------------------------------------------------------

--
-- Table structure for table `help_faq_sections`
--

CREATE TABLE `help_faq_sections` (
  `hfs_id` int(11) NOT NULL AUTO_INCREMENT,
  `hfs_name` varchar(255) DEFAULT NULL,
  `hfs_order` int(11) DEFAULT '0',
  `sys_userid` int(11) DEFAULT NULL,
  `sys_groupid` int(11) DEFAULT NULL,
  `sys_perm_user` varchar(5) DEFAULT NULL,
  `sys_perm_group` varchar(5) DEFAULT NULL,
  `sys_perm_other` varchar(5) DEFAULT NULL,
  PRIMARY KEY (`hfs_id`)
)  DEFAULT CHARSET=utf8mb4 AUTO_INCREMENT=1 ;

-- --------------------------------------------------------

-- Table structure for table `iptables`
--

DROP TABLE IF EXISTS `iptables`;
CREATE TABLE `iptables` (
  `iptables_id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `server_id` int(10) unsigned NOT NULL DEFAULT '0',
  `table` varchar(10) DEFAULT NULL COMMENT 'INPUT OUTPUT FORWARD',
  `source_ip` varchar(16) DEFAULT NULL,
  `destination_ip` varchar(16) DEFAULT NULL,
  `protocol` varchar(10) DEFAULT 'TCP' COMMENT 'TCP UDP GRE',
  `singleport` varchar(10) DEFAULT NULL,
  `multiport` varchar(40) DEFAULT NULL,
  `state` varchar(20) DEFAULT NULL COMMENT 'NEW ESTABLISHED RECNET etc',
  `target` varchar(10) DEFAULT NULL COMMENT 'ACCEPT DROP REJECT LOG',
  `active` enum('n','y') NOT NULL DEFAULT 'y',
  PRIMARY KEY (`iptables_id`)
) AUTO_INCREMENT=5 DEFAULT CHARSET=utf8;

-- --------------------------------------------------------

--
-- Table structure for table  `mail_access`
--

CREATE TABLE `mail_access` (
  `access_id` int(11) unsigned NOT NULL auto_increment,
  `sys_userid` int(11) unsigned NOT NULL default '0',
  `sys_groupid` int(11) unsigned NOT NULL default '0',
  `sys_perm_user` varchar(5) NOT NULL default '',
  `sys_perm_group` varchar(5) NOT NULL default '',
  `sys_perm_other` varchar(5) NOT NULL default '',
  `server_id` int(11) NOT NULL default '0',
  `source` varchar(255) NOT NULL DEFAULT '',
  `access` varchar(255) NOT NULL DEFAULT '',
  `type` set('recipient','sender','client') NOT NULL DEFAULT 'recipient',
  `active` enum('n','y') NOT NULL default 'y',
  PRIMARY KEY  (`access_id`),
  UNIQUE KEY `unique_source` (`server_id`,`source`,`type`)
) DEFAULT CHARSET=utf8mb4 AUTO_INCREMENT=1 ;

-- --------------------------------------------------------

--
-- Table structure for table  `mail_backup`
--

CREATE TABLE `mail_backup` (
  `backup_id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `server_id` int(10) unsigned NOT NULL DEFAULT '0',
  `parent_domain_id` int(10) unsigned NOT NULL DEFAULT '0',
  `mailuser_id` int(10) unsigned NOT NULL DEFAULT '0',
  `backup_mode` varchar(64) NOT NULL DEFAULT  '',
  `tstamp` int(10) unsigned NOT NULL DEFAULT '0',
  `filename` varchar(255) NOT NULL DEFAULT '',
  `filesize` VARCHAR(20) NOT NULL DEFAULT '',
  PRIMARY KEY (`backup_id`)
) DEFAULT CHARSET=utf8mb4 AUTO_INCREMENT=1 ;

-- --------------------------------------------------------

--
-- Table structure for table  `mail_content_filter`
--

CREATE TABLE `mail_content_filter` (
  `content_filter_id` int(11) unsigned NOT NULL auto_increment,
  `sys_userid` int(11) unsigned NOT NULL default '0',
  `sys_groupid` int(11) unsigned NOT NULL default '0',
  `sys_perm_user` varchar(5) default NULL,
  `sys_perm_group` varchar(5) default NULL,
  `sys_perm_other` varchar(5) default NULL,
  `server_id` int(11) NOT NULL default '0',
  `type` varchar(255) default NULL,
  `pattern` varchar(255) default NULL,
  `data` varchar(255) default NULL,
  `action` varchar(255) default NULL,
  `active` varchar(255) NOT NULL default 'y',
  PRIMARY KEY  (`content_filter_id`)
) DEFAULT CHARSET=utf8mb4 AUTO_INCREMENT=1 ;

-- --------------------------------------------------------

--
-- Table structure for table  `mail_domain`
--

CREATE TABLE `mail_domain` (
  `domain_id` int(11) unsigned NOT NULL auto_increment,
  `sys_userid` int(11) unsigned NOT NULL default '0',
  `sys_groupid` int(11) unsigned NOT NULL default '0',
  `sys_perm_user` varchar(5) NOT NULL default '',
  `sys_perm_group` varchar(5) NOT NULL default '',
  `sys_perm_other` varchar(5) NOT NULL default '',
  `server_id` int(11) unsigned NOT NULL default '0',
  `domain` varchar(255) NOT NULL default '',
  `dkim` ENUM( 'n', 'y' ) NOT NULL default 'n',
  `dkim_selector` varchar(63) NOT NULL DEFAULT 'default',
  `dkim_private` mediumtext NULL,
  `dkim_public` mediumtext NULL,
  `relay_host` varchar(255) NOT NULL DEFAULT '',
  `relay_user` varchar(255) NOT NULL DEFAULT '',
  `relay_pass` varchar(255) NOT NULL DEFAULT '',
  `active` enum('n','y') NOT NULL DEFAULT 'n',
  `local_delivery` enum('n','y') NOT NULL DEFAULT 'y',
  PRIMARY KEY  (`domain_id`),
  KEY `server_id` (`server_id`,`domain`),
  KEY `domain_active` (`domain`,`active`)
) DEFAULT CHARSET=utf8mb4 AUTO_INCREMENT=1 ;

-- --------------------------------------------------------

--
-- Table structure for table  `mail_forwarding`
--

CREATE TABLE `mail_forwarding` (
  `forwarding_id` int(11) unsigned NOT NULL auto_increment,
  `sys_userid` int(11) unsigned NOT NULL default '0',
  `sys_groupid` int(11) unsigned NOT NULL default '0',
  `sys_perm_user` varchar(5) NOT NULL default '',
  `sys_perm_group` varchar(5) NOT NULL default '',
  `sys_perm_other` varchar(5) NOT NULL default '',
  `server_id` int(11) unsigned NOT NULL default '0',
  `source` varchar(255) NOT NULL DEFAULT '',
  `destination` text,
  `type` enum('alias','aliasdomain','forward','catchall') NOT NULL default 'alias',
  `active` enum('n','y') NOT NULL DEFAULT 'n',
  `allow_send_as` ENUM('n','y') NOT NULL DEFAULT 'n',
  `greylisting` enum('n','y' ) NOT NULL DEFAULT 'n',
  PRIMARY KEY  (`forwarding_id`),
  KEY `server_id` (`server_id`, `source`),
  KEY `type` (`type`)
) DEFAULT CHARSET=utf8mb4 AUTO_INCREMENT=1 ;

-- --------------------------------------------------------

--
-- Table structure for table  `mail_get`
--

CREATE TABLE `mail_get` (
  `mailget_id` int(11) unsigned NOT NULL auto_increment,
  `sys_userid` int(11) unsigned NOT NULL default '0',
  `sys_groupid` int(11) unsigned NOT NULL default '0',
  `sys_perm_user` varchar(5) default NULL,
  `sys_perm_group` varchar(5) default NULL,
  `sys_perm_other` varchar(5) default NULL,
  `server_id` int(11) unsigned NOT NULL default '0',
  `type` varchar(255) default NULL,
  `source_server` varchar(255) default NULL,
  `source_username` varchar(255) default NULL,
  `source_password` varchar(64) default NULL,
  `source_delete` varchar(255) NOT NULL default 'y',
  `source_read_all` varchar(255) NOT NULL default 'y',
  `destination` varchar(255) default NULL,
  `active` varchar(255) NOT NULL default 'y',
  PRIMARY KEY  (`mailget_id`)
) DEFAULT CHARSET=utf8mb4 AUTO_INCREMENT=1 ;

-- --------------------------------------------------------

--
-- Tabellenstruktur für Tabelle `mail_mailinglist`
--

CREATE TABLE `mail_mailinglist` (
  `mailinglist_id` int(11) unsigned NOT NULL auto_increment,
  `sys_userid` int(11) unsigned NOT NULL default '0',
  `sys_groupid` int(11) unsigned NOT NULL default '0',
  `sys_perm_user` varchar(5) NOT NULL DEFAULT '',
  `sys_perm_group` varchar(5) NOT NULL DEFAULT '',
  `sys_perm_other` varchar(5) NOT NULL DEFAULT '',
  `server_id` int(11) unsigned NOT NULL default '0',
  `domain` varchar(255) NOT NULL DEFAULT '',
  `listname` varchar(255) NOT NULL DEFAULT '',
  `email` varchar(255) NOT NULL DEFAULT '',
  `password` varchar(255) NOT NULL DEFAULT '',
  PRIMARY KEY  (`mailinglist_id`)
) DEFAULT CHARSET=utf8mb4 AUTO_INCREMENT=1 ;

-- --------------------------------------------------------

--
-- Table structure for Table `mail_relay_domain`
--

CREATE TABLE IF NOT EXISTS `mail_relay_domain` (
  `relay_domain_id` bigint(20) NOT NULL AUTO_INCREMENT,
  `sys_userid` int(11) NOT NULL DEFAULT '0',
  `sys_groupid` int(11) NOT NULL DEFAULT '0',
  `sys_perm_user` varchar(5) DEFAULT NULL,
  `sys_perm_group` varchar(5) DEFAULT NULL,
  `sys_perm_other` varchar(5) DEFAULT NULL,
  `server_id` int(11) NOT NULL DEFAULT '0',
  `domain` varchar(255) DEFAULT NULL,
  `access` varchar(255) NOT NULL DEFAULT 'OK',
  `active` varchar(255) NOT NULL DEFAULT 'y',
  PRIMARY KEY (`relay_domain_id`),
  UNIQUE KEY `domain` (`domain`, `server_id`)
) DEFAULT CHARSET=utf8mb4 AUTO_INCREMENT=1 ;

-- --------------------------------------------------------

--
-- Table structure for Table `mail_relay_recipient`
--

CREATE TABLE IF NOT EXISTS `mail_relay_recipient` (
  `relay_recipient_id` bigint(20) NOT NULL AUTO_INCREMENT,
  `sys_userid` int(11) NOT NULL DEFAULT '0',
  `sys_groupid` int(11) NOT NULL DEFAULT '0',
  `sys_perm_user` varchar(5) DEFAULT NULL,
  `sys_perm_group` varchar(5) DEFAULT NULL,
  `sys_perm_other` varchar(5) DEFAULT NULL,
  `server_id` int(11) NOT NULL DEFAULT '0',
  `source` varchar(255) DEFAULT NULL,
  `access` varchar(255) NOT NULL DEFAULT 'OK',
  `active` varchar(255) NOT NULL DEFAULT 'y',
  PRIMARY KEY (`relay_recipient_id`)
) DEFAULT CHARSET=utf8mb4 AUTO_INCREMENT=1 ;

-- --------------------------------------------------------

--
-- Table structure for table  `mail_traffic`
--

CREATE TABLE `mail_traffic` (
  `traffic_id` int(11) unsigned NOT NULL auto_increment,
  `mailuser_id` int(11) unsigned NOT NULL DEFAULT '0',
  `month` char(7) NOT NULL DEFAULT '',
  `traffic` bigint(20) unsigned NOT NULL DEFAULT '0',
  PRIMARY KEY  (`traffic_id`),
  KEY `mailuser_id` (`mailuser_id`,`month`)
) DEFAULT CHARSET=utf8mb4 AUTO_INCREMENT=1 ;

-- --------------------------------------------------------

--
-- Table structure for table  `mail_transport`
--

CREATE TABLE `mail_transport` (
  `transport_id` int(11) unsigned NOT NULL auto_increment,
  `sys_userid` int(11) unsigned NOT NULL default '0',
  `sys_groupid` int(11) unsigned NOT NULL default '0',
  `sys_perm_user` varchar(5) NOT NULL default '',
  `sys_perm_group` varchar(5) NOT NULL default '',
  `sys_perm_other` varchar(5) NOT NULL default '',
  `server_id` int(11) unsigned NOT NULL default '0',
  `domain` varchar(255) NOT NULL default '',
  `transport` varchar(255) NOT NULL DEFAULT '',
  `sort_order` int(11) unsigned NOT NULL default '5',
  `active` enum('n','y') NOT NULL DEFAULT 'n',
  PRIMARY KEY  (`transport_id`),
  KEY `server_id` (`server_id`,`transport`),
  UNIQUE KEY `server_id_2` (`server_id`, `domain`)
) DEFAULT CHARSET=utf8mb4 AUTO_INCREMENT=1 ;

-- --------------------------------------------------------

--
-- Table structure for table  `mail_user`
--

CREATE TABLE `mail_user` (
  `mailuser_id` int(11) unsigned NOT NULL auto_increment,
  `sys_userid` int(11) unsigned NOT NULL default '0',
  `sys_groupid` int(11) unsigned NOT NULL default '0',
  `sys_perm_user` varchar(5) NOT NULL default '',
  `sys_perm_group` varchar(5) NOT NULL default '',
  `sys_perm_other` varchar(5) NOT NULL default '',
  `server_id` int(11) unsigned NOT NULL default '0',
  `email` varchar(255) NOT NULL default '',
  `login` varchar(255) NOT NULL default '',
  `password` varchar(255) NOT NULL default '',
  `name` varchar(255) NOT NULL default '',
  `uid` int(11) NOT NULL default '5000',
  `gid` int(11) NOT NULL default '5000',
  `maildir` varchar(255) NOT NULL default '',
  `maildir_format` varchar(255) NOT NULL default 'maildir',
  `quota` bigint(20) NOT NULL default '0',
  `cc` text,
  `forward_in_lda` enum('n','y') NOT NULL default 'n',
  `sender_cc` varchar(255) NOT NULL default '',
  `homedir` varchar(255) NOT NULL default '',
  `autoresponder` enum('n','y') NOT NULL default 'n',
  `autoresponder_start_date` datetime NULL default NULL,
  `autoresponder_end_date` datetime NULL default NULL,
  `autoresponder_subject` varchar(255) NOT NULL default 'Out of office reply',
  `autoresponder_text` mediumtext NULL,
  `move_junk` enum('y','a','n') NOT NULL default 'y',
  `purge_trash_days` INT NOT NULL DEFAULT '0',
  `purge_junk_days` INT NOT NULL DEFAULT '0',
  `custom_mailfilter` mediumtext,
  `postfix` enum('n','y') NOT NULL default 'y',
  `greylisting` enum('n','y' ) NOT NULL DEFAULT 'n',
  `access` enum('n','y') NOT NULL default 'y',
  `disableimap` enum('n','y') NOT NULL default 'n',
  `disablepop3` enum('n','y') NOT NULL default 'n',
  `disabledeliver` enum('n','y') NOT NULL default 'n',
  `disablesmtp` enum('n','y') NOT NULL default 'n',
  `disablesieve` enum('n','y') NOT NULL default 'n',
  `disablesieve-filter` enum('n','y') NOT NULL default 'n',
  `disablelda` enum('n','y') NOT NULL default 'n',
  `disablelmtp` enum('n','y') NOT NULL default 'n',
  `disabledoveadm` enum('n','y') NOT NULL default 'n',
  `last_access` int(11) NULL DEFAULT NULL,
  `disablequota-status` enum('n','y') NOT NULL default 'n',
  `disableindexer-worker` enum('n','y') NOT NULL default 'n',
  `disablereplicator` enum('n','y') NOT NULL default 'n',
  `last_quota_notification` date NULL default NULL,
  `backup_interval` VARCHAR( 255 ) NOT NULL default 'none',
  `backup_copies` INT NOT NULL DEFAULT '1',
  `imap_prefix` varchar(255) NULL default NULL,
  PRIMARY KEY  (`mailuser_id`),
  KEY `server_id` (`server_id`,`email`),
  KEY `email_access` (`email`,`access`)
) DEFAULT CHARSET=utf8mb4 AUTO_INCREMENT=1 ;

-- --------------------------------------------------------

--
-- Table structure for table  `mail_user_filter`
--

CREATE TABLE `mail_user_filter` (
  `filter_id` int(11) unsigned NOT NULL auto_increment,
  `sys_userid` int(11) unsigned NOT NULL default '0',
  `sys_groupid` int(11) unsigned NOT NULL default '0',
  `sys_perm_user` varchar(5) default NULL,
  `sys_perm_group` varchar(5) default NULL,
  `sys_perm_other` varchar(5) default NULL,
  `mailuser_id` int(11) unsigned NOT NULL default '0',
  `rulename` varchar(64) default NULL,
  `source` varchar(255) default NULL,
  `searchterm` varchar(255) default NULL,
  `op` varchar(255) default NULL,
  `action` varchar(255) default NULL,
  `target` varchar(255) default NULL,
  `active` enum('n','y') NOT NULL default 'y',
  PRIMARY KEY  (`filter_id`)
) DEFAULT CHARSET=utf8mb4 AUTO_INCREMENT=1 ;

-- --------------------------------------------------------

--
-- Table structure for table `monitor_data`
--

CREATE TABLE `monitor_data` (
  `server_id` int(11) unsigned NOT NULL default '0',
  `type` varchar(255) NOT NULL default '',
  `created` int(11) unsigned NOT NULL default '0',
  `data` mediumtext,
  `state` enum('no_state','unknown','ok','info','warning','critical','error') NOT NULL DEFAULT 'unknown',
  PRIMARY KEY (`server_id`,`type`,`created`)
) DEFAULT CHARSET=utf8mb4 ;

-- --------------------------------------------------------

--
-- Table structure for table `openvz_ip`
--

CREATE TABLE IF NOT EXISTS `openvz_ip` (
  `ip_address_id` bigint(20) NOT NULL AUTO_INCREMENT,
  `sys_userid` int(11) NOT NULL DEFAULT '0',
  `sys_groupid` int(11) NOT NULL DEFAULT '0',
  `sys_perm_user` varchar(5) DEFAULT NULL,
  `sys_perm_group` varchar(5) DEFAULT NULL,
  `sys_perm_other` varchar(5) DEFAULT NULL,
  `server_id` int(11) NOT NULL DEFAULT '0',
  `ip_address` varchar(39) DEFAULT NULL,
  `vm_id` int(11) NOT NULL DEFAULT '0',
  `reserved` varchar(255) NOT NULL DEFAULT 'n',
  `additional` varchar(255) NOT NULL DEFAULT 'n',
  PRIMARY KEY (`ip_address_id`)
)  DEFAULT CHARSET=utf8mb4 ;

--
-- Dumping data for table `openvz_ip`
--

-- --------------------------------------------------------

--
-- Table structure for table `openvz_ostemplate`
--

CREATE TABLE IF NOT EXISTS `openvz_ostemplate` (
  `ostemplate_id` bigint(20) NOT NULL AUTO_INCREMENT,
  `sys_userid` int(11) NOT NULL DEFAULT '0',
  `sys_groupid` int(11) NOT NULL DEFAULT '0',
  `sys_perm_user` varchar(5) DEFAULT NULL,
  `sys_perm_group` varchar(5) DEFAULT NULL,
  `sys_perm_other` varchar(5) DEFAULT NULL,
  `template_name` varchar(255) DEFAULT NULL,
  `template_file` varchar(255) NOT NULL DEFAULT '',
  `server_id` int(11) NOT NULL DEFAULT '0',
  `allservers` varchar(255) NOT NULL DEFAULT 'y',
  `active` varchar(255) NOT NULL DEFAULT 'y',
  `description` text,
  PRIMARY KEY (`ostemplate_id`)
)  DEFAULT CHARSET=utf8mb4 ;

--
-- Dumping data for table `openvz_ostemplate`
--

INSERT INTO `openvz_ostemplate` (`ostemplate_id`, `sys_userid`, `sys_groupid`, `sys_perm_user`, `sys_perm_group`, `sys_perm_other`, `template_name`, `template_file`, `server_id`, `allservers`, `active`, `description`) VALUES(1, 1, 1, 'riud', 'riud', '', 'Debian minimal', 'debian-minimal-x86', 1, 'y', 'y', 'Debian minimal image.');

-- --------------------------------------------------------

--
-- Table structure for table `openvz_template`
--

CREATE TABLE IF NOT EXISTS `openvz_template` (
  `template_id` bigint(20) NOT NULL AUTO_INCREMENT,
  `sys_userid` int(11) NOT NULL DEFAULT '0',
  `sys_groupid` int(11) NOT NULL DEFAULT '0',
  `sys_perm_user` varchar(5) DEFAULT NULL,
  `sys_perm_group` varchar(5) DEFAULT NULL,
  `sys_perm_other` varchar(5) DEFAULT NULL,
  `template_name` varchar(255) DEFAULT NULL,
  `diskspace` int(11) NOT NULL DEFAULT '0',
  `traffic` int(11) NOT NULL DEFAULT '-1',
  `bandwidth` int(11) NOT NULL DEFAULT '-1',
  `ram` int(11) NOT NULL DEFAULT '0',
  `ram_burst` int(11) NOT NULL DEFAULT '0',
  `cpu_units` int(11) NOT NULL DEFAULT '1000',
  `cpu_num` int(11) NOT NULL DEFAULT '4',
  `cpu_limit` int(11) NOT NULL DEFAULT '400',
  `io_priority` int(11) NOT NULL DEFAULT '4',
  `active` varchar(255) NOT NULL DEFAULT 'y',
  `description` text,
  `numproc` varchar(255) DEFAULT NULL,
  `numtcpsock` varchar(255) DEFAULT NULL,
  `numothersock` varchar(255) DEFAULT NULL,
  `vmguarpages` varchar(255) DEFAULT NULL,
  `kmemsize` varchar(255) DEFAULT NULL,
  `tcpsndbuf` varchar(255) DEFAULT NULL,
  `tcprcvbuf` varchar(255) DEFAULT NULL,
  `othersockbuf` varchar(255) DEFAULT NULL,
  `dgramrcvbuf` varchar(255) DEFAULT NULL,
  `oomguarpages` varchar(255) DEFAULT NULL,
  `privvmpages` varchar(255) DEFAULT NULL,
  `lockedpages` varchar(255) DEFAULT NULL,
  `shmpages` varchar(255) DEFAULT NULL,
  `physpages` varchar(255) DEFAULT NULL,
  `numfile` varchar(255) DEFAULT NULL,
  `avnumproc` varchar(255) DEFAULT NULL,
  `numflock` varchar(255) DEFAULT NULL,
  `numpty` varchar(255) DEFAULT NULL,
  `numsiginfo` varchar(255) DEFAULT NULL,
  `dcachesize` varchar(255) DEFAULT NULL,
  `numiptent` varchar(255) DEFAULT NULL,
  `swappages` varchar(255) DEFAULT NULL,
  `hostname` varchar(255) DEFAULT NULL,
  `nameserver` varchar(255) DEFAULT NULL,
  `create_dns` varchar(1) NOT NULL DEFAULT 'n',
  `capability` varchar(255) DEFAULT NULL,
  `features` varchar(255) DEFAULT NULL,
  `iptables` varchar(255) DEFAULT NULL,
  `custom` text,
  PRIMARY KEY (`template_id`)
)  DEFAULT CHARSET=utf8mb4 ;

--
-- Dumping data for table `openvz_template`
--

INSERT INTO `openvz_template` (`template_id`, `sys_userid`, `sys_groupid`, `sys_perm_user`, `sys_perm_group`, `sys_perm_other`, `template_name`, `diskspace`, `traffic`, `bandwidth`, `ram`, `ram_burst`, `cpu_units`, `cpu_num`, `cpu_limit`, `io_priority`, `active`, `description`, `numproc`, `numtcpsock`, `numothersock`, `vmguarpages`, `kmemsize`, `tcpsndbuf`, `tcprcvbuf`, `othersockbuf`, `dgramrcvbuf`, `oomguarpages`, `privvmpages`, `lockedpages`, `shmpages`, `physpages`, `numfile`, `avnumproc`, `numflock`, `numpty`, `numsiginfo`, `dcachesize`, `numiptent`, `swappages`, `hostname`, `nameserver`, `create_dns`, `capability`, `features`, `iptables`, `custom`) VALUES(1, 1, 1, 'riud', 'riud', '', 'small', 10, -1, -1, 256, 512, 1000, 4, 400, 4, 'y', '', '999999:999999', '7999992:7999992', '7999992:7999992', '65536:unlimited', '2147483646:2147483646', '214748160:396774400', '214748160:396774400', '214748160:396774400', '214748160:396774400', '65536:65536', '131072:139264', '999999:999999', '65536:65536', '0:2147483647', '23999976:23999976', '180:180', '999999:999999', '500000:500000', '999999:999999', '2147483646:2147483646', '999999:999999', '256000:256000', 'v{VEID}.test.tld', '8.8.8.8 8.8.4.4', 'n', '', '', '', '');

-- --------------------------------------------------------

--
-- Table structure for table `openvz_traffic`
--

CREATE TABLE IF NOT EXISTS `openvz_traffic` (
  `veid` int(11) NOT NULL DEFAULT '0',
  `traffic_date` date NULL DEFAULT NULL,
  `traffic_bytes` bigint(32) unsigned NOT NULL DEFAULT '0',
  UNIQUE KEY (`veid`,`traffic_date`)
) DEFAULT CHARSET=utf8;

--
-- Dumping data for table `openvz_traffic`
--


-- --------------------------------------------------------

--
-- Table structure for table `openvz_vm`
--

CREATE TABLE IF NOT EXISTS `openvz_vm` (
  `vm_id` bigint(20) NOT NULL AUTO_INCREMENT,
  `sys_userid` int(11) NOT NULL DEFAULT '0',
  `sys_groupid` int(11) NOT NULL DEFAULT '0',
  `sys_perm_user` varchar(5) DEFAULT NULL,
  `sys_perm_group` varchar(5) DEFAULT NULL,
  `sys_perm_other` varchar(5) DEFAULT NULL,
  `server_id` int(11) NOT NULL DEFAULT '0',
  `veid` int(10) unsigned NOT NULL DEFAULT '0',
  `ostemplate_id` int(11) NOT NULL DEFAULT '0',
  `template_id` int(11) NOT NULL DEFAULT '0',
  `ip_address` varchar(255) NOT NULL DEFAULT '',
  `hostname` varchar(255) DEFAULT NULL,
  `vm_password` varchar(255) DEFAULT NULL,
  `start_boot` varchar(255) NOT NULL DEFAULT 'y',
  `bootorder` int(11) NOT NULL DEFAULT '1',
  `active` varchar(255) NOT NULL DEFAULT 'y',
  `active_until_date` date NULL DEFAULT NULL,
  `description` text,
  `diskspace` int(11) NOT NULL DEFAULT '0',
  `traffic` int(11) NOT NULL DEFAULT '-1',
  `bandwidth` int(11) NOT NULL DEFAULT '-1',
  `ram` int(11) NOT NULL DEFAULT '0',
  `ram_burst` int(11) NOT NULL DEFAULT '0',
  `cpu_units` int(11) NOT NULL DEFAULT '1000',
  `cpu_num` int(11) NOT NULL DEFAULT '4',
  `cpu_limit` int(11) NOT NULL DEFAULT '400',
  `io_priority` int(11) NOT NULL DEFAULT '4',
  `nameserver` varchar(255) NOT NULL DEFAULT '8.8.8.8 8.8.4.4',
  `create_dns` varchar(1) NOT NULL DEFAULT 'n',
  `capability` text,
  `features` text,
  `iptabless` text,
  `config` mediumtext,
  `custom` text,
  PRIMARY KEY (`vm_id`)
)  DEFAULT CHARSET=utf8mb4 ;

--
-- Dumping data for table `openvz_vm`
--

-- --------------------------------------------------------

--
-- Table structure for table  `remote_session`
--

CREATE TABLE `remote_session` (
  `remote_session` varchar(64) NOT NULL DEFAULT '',
  `remote_userid` int(11) unsigned NOT NULL DEFAULT '0',
  `remote_functions` text,
  `client_login` tinyint(1) unsigned NOT NULL default '0',
  `tstamp` int(10) unsigned NOT NULL DEFAULT '0',
  `remote_ip` varchar(39) NOT NULL DEFAULT '',
  PRIMARY KEY  (`remote_session`)
) DEFAULT CHARSET=utf8mb4 ;

-- --------------------------------------------------------

--
-- Table structure for table  `remote_user`
--

CREATE TABLE `remote_user` (
  `remote_userid` int(11) unsigned NOT NULL auto_increment,
  `sys_userid` int(11) unsigned NOT NULL default '0',
  `sys_groupid` int(11) unsigned NOT NULL default '0',
  `sys_perm_user` varchar(5) default NULL,
  `sys_perm_group` varchar(5) default NULL,
  `sys_perm_other` varchar(5) default NULL,
  `remote_username` varchar(64) NOT NULL DEFAULT '',
  `remote_password` varchar(200) NOT NULL DEFAULT '',
  `remote_access` enum('y','n') NOT NULL DEFAULT 'y',
  `remote_ips` TEXT,
  `remote_functions` text,
  PRIMARY KEY  (`remote_userid`)
) DEFAULT CHARSET=utf8mb4 AUTO_INCREMENT=1 ;

-- --------------------------------------------------------

--
-- Table structure for table  `server`
--

CREATE TABLE `server` (
  `server_id` int(11) unsigned NOT NULL auto_increment,
  `sys_userid` int(11) unsigned NOT NULL default '0',
  `sys_groupid` int(11) unsigned NOT NULL default '0',
  `sys_perm_user` varchar(5) NOT NULL default '',
  `sys_perm_group` varchar(5) NOT NULL default '',
  `sys_perm_other` varchar(5) NOT NULL default '',
  `server_name` varchar(255) NOT NULL default '',
  `mail_server` tinyint(1) NOT NULL default '0',
  `web_server` tinyint(1) NOT NULL default '0',
  `dns_server` tinyint(1) NOT NULL default '0',
  `file_server` tinyint(1) NOT NULL default '0',
  `db_server` tinyint(1) NOT NULL default '0',
  `vserver_server` tinyint(1) NOT NULL default '0',
  `proxy_server` tinyint(1) NOT NULL default '0',
  `firewall_server` tinyint(1) NOT NULL default '0',
  `xmpp_server` tinyint(1) NOT NULL default '0',
  `config` text,
  `updated` bigint(20) unsigned NOT NULL default '0',
  `mirror_server_id` int(11) unsigned NOT NULL default '0',
  `dbversion` int(11) unsigned NOT NULL default '1',
  `active` tinyint(1) NOT NULL default '1',
  PRIMARY KEY  (`server_id`)
) DEFAULT CHARSET=utf8mb4 AUTO_INCREMENT=1 ;

-- --------------------------------------------------------

--
-- Table structure for table  `server_ip`
--

CREATE TABLE `server_ip` (
  `server_ip_id` int(11) unsigned NOT NULL auto_increment,
  `sys_userid` int(11) unsigned NOT NULL default '0',
  `sys_groupid` int(11) unsigned NOT NULL default '0',
  `sys_perm_user` varchar(5) default NULL,
  `sys_perm_group` varchar(5) default NULL,
  `sys_perm_other` varchar(5) default NULL,
  `server_id` int(11) unsigned NOT NULL default '0',
  `client_id` int(11) unsigned NOT NULL default '0',
  `ip_type` enum(  'IPv4',  'IPv6' ) NOT NULL DEFAULT  'IPv4',
  `ip_address` varchar(39) default NULL,
  `virtualhost` enum('n','y') NOT NULL default 'y',
  `virtualhost_port` varchar(255) default '80,443',
  PRIMARY KEY  (`server_ip_id`)
) DEFAULT CHARSET=utf8mb4 AUTO_INCREMENT=1 ;

-- --------------------------------------------------------

--
-- Table structure for table  `server_ip_map`
--

CREATE TABLE `server_ip_map` (
  `server_ip_map_id` int(11) unsigned NOT NULL AUTO_INCREMENT,
  `sys_userid` int(11) unsigned NOT NULL DEFAULT '0',
  `sys_groupid` int(11) unsigned NOT NULL DEFAULT '0',
  `sys_perm_user` varchar(5) DEFAULT NULL,
  `sys_perm_group` varchar(5) DEFAULT NULL,
  `sys_perm_other` varchar(5) DEFAULT NULL,
  `server_id` int(11) unsigned NOT NULL DEFAULT '0',
  `source_ip` varchar(15) DEFAULT NULL,
  `destination_ip` varchar(35) DEFAULT '',
  `active` enum('n','y') NOT NULL DEFAULT 'y',
  PRIMARY KEY (`server_ip_map_id`)
) DEFAULT CHARSET=utf8mb4 AUTO_INCREMENT=1 ;

-- --------------------------------------------------------

--
-- Table structure for table  `server_php`
--

CREATE TABLE `server_php` (
  `server_php_id` int(11) unsigned NOT NULL AUTO_INCREMENT,
  `sys_userid` int(11) unsigned NOT NULL DEFAULT '0',
  `sys_groupid` int(11) unsigned NOT NULL DEFAULT '0',
  `sys_perm_user` varchar(5) DEFAULT NULL,
  `sys_perm_group` varchar(5) DEFAULT NULL,
  `sys_perm_other` varchar(5) DEFAULT NULL,
  `server_id` int(11) unsigned NOT NULL DEFAULT '0',
  `client_id` int(11) unsigned NOT NULL DEFAULT '0',
  `name` varchar(255) DEFAULT NULL,
  `php_fastcgi_binary` varchar(255) DEFAULT NULL,
  `php_fastcgi_ini_dir` varchar(255) DEFAULT NULL,
  `php_fpm_init_script` varchar(255) DEFAULT NULL,
  `php_fpm_ini_dir` varchar(255) DEFAULT NULL,
  `php_fpm_pool_dir` varchar(255) DEFAULT NULL,
  `php_fpm_socket_dir` varchar(255) DEFAULT NULL,
  `php_cli_binary` varchar(255) DEFAULT NULL,
  `php_jk_section` varchar(255) DEFAULT NULL,
  `active` enum('n','y') NOT NULL DEFAULT 'y',
  `sortprio` int(20) NOT NULL DEFAULT 100,
  PRIMARY KEY (`server_php_id`)
) DEFAULT CHARSET=utf8mb4 AUTO_INCREMENT=1 ;

-- --------------------------------------------------------

--
-- Table structure for table `shell_user`
--

CREATE TABLE `shell_user` (
  `shell_user_id` int(11) unsigned NOT NULL auto_increment,
  `sys_userid` int(11) unsigned NOT NULL default '0',
  `sys_groupid` int(11) unsigned NOT NULL default '0',
  `sys_perm_user` varchar(5) default NULL,
  `sys_perm_group` varchar(5) default NULL,
  `sys_perm_other` varchar(5) default NULL,
  `server_id` int(11) unsigned NOT NULL default '0',
  `parent_domain_id` int(11) unsigned NOT NULL default '0',
  `username` varchar(64) default NULL,
  `username_prefix` varchar(50) NOT NULL default '',
  `password` varchar(200) default NULL,
  `quota_size` bigint(20) NOT NULL default '-1',
  `active` enum('n','y') NOT NULL default 'y',
  `puser` varchar(255) default NULL,
  `pgroup` varchar(255) default NULL,
  `shell` varchar(255) NOT NULL default '/bin/bash',
  `dir` varchar(255) default NULL,
  `chroot` varchar(255) NOT NULL DEFAULT '',
  `ssh_rsa` text,
  PRIMARY KEY  (`shell_user_id`)
) DEFAULT CHARSET=utf8mb4 AUTO_INCREMENT=1 ;

-- --------------------------------------------------------

--
-- Table structure for table  `spamfilter_policy`
--

CREATE TABLE `spamfilter_policy` (
  `id` int(11) unsigned NOT NULL auto_increment,
  `sys_userid` int(11) unsigned NOT NULL DEFAULT '0',
  `sys_groupid` int(11) unsigned NOT NULL DEFAULT '0',
  `sys_perm_user` varchar(5) NOT NULL DEFAULT '',
  `sys_perm_group` varchar(5) NOT NULL DEFAULT '',
  `sys_perm_other` varchar(5) NOT NULL DEFAULT '',
  `policy_name` varchar(64) default NULL,
  `virus_lover` enum('N','Y') default 'N',
  `spam_lover` enum('N','Y') default 'N',
  `banned_files_lover` enum('N','Y') default 'N',
  `bad_header_lover` enum('N','Y') default 'N',
  `bypass_virus_checks` enum('N','Y') default 'N',
  `bypass_spam_checks` enum('N','Y') default 'N',
  `bypass_banned_checks` enum('N','Y') default 'N',
  `bypass_header_checks` enum('N','Y') default 'N',
  `spam_modifies_subj` enum('N','Y') default 'N',
  `virus_quarantine_to` varchar(255) default NULL,
  `spam_quarantine_to` varchar(255) default NULL,
  `banned_quarantine_to` varchar(255) default NULL,
  `bad_header_quarantine_to` varchar(255) default NULL,
  `clean_quarantine_to` varchar(255) default NULL,
  `other_quarantine_to` varchar(255) default NULL,
  `spam_tag_level` DECIMAL(5,2) default NULL,
  `spam_tag2_level` DECIMAL(5,2) default NULL,
  `spam_kill_level` DECIMAL(5,2) default NULL,
  `spam_dsn_cutoff_level` DECIMAL(5,2) default NULL,
  `spam_quarantine_cutoff_level` DECIMAL(5,2) default NULL,
  `addr_extension_virus` varchar(64) default NULL,
  `addr_extension_spam` varchar(64) default NULL,
  `addr_extension_banned` varchar(64) default NULL,
  `addr_extension_bad_header` varchar(64) default NULL,
  `warnvirusrecip` VARCHAR(1) NULL default 'N',
  `warnbannedrecip` VARCHAR(1) NULL default 'N',
  `warnbadhrecip` VARCHAR(1) NULL default 'N',
  `newvirus_admin` varchar(64) default NULL,
  `virus_admin` varchar(64) default NULL,
  `banned_admin` varchar(64) default NULL,
  `bad_header_admin` varchar(64) default NULL,
  `spam_admin` varchar(64) default NULL,
  `spam_subject_tag` varchar(64) default NULL,
  `spam_subject_tag2` varchar(64) default NULL,
  `message_size_limit` int(11) unsigned default NULL,
  `banned_rulenames` varchar(64) default NULL,
  `policyd_quota_in` int(11) NOT NULL DEFAULT  '-1',
  `policyd_quota_in_period` int(11) NOT NULL DEFAULT  '24',
  `policyd_quota_out` int(11) NOT NULL DEFAULT  '-1',
  `policyd_quota_out_period` int(11) NOT NULL DEFAULT  '24',
  `policyd_greylist` ENUM(  'Y',  'N' ) NOT NULL DEFAULT  'N',
  `rspamd_greylisting` enum('n','y') NOT NULL DEFAULT 'n',
  `rspamd_spam_greylisting_level` decimal(5,2) DEFAULT NULL,
  `rspamd_spam_tag_level` decimal(5,2) DEFAULT NULL,
  `rspamd_spam_tag_method` enum('add_header','rewrite_subject') NOT NULL DEFAULT 'rewrite_subject',
  `rspamd_spam_kill_level` decimal(5,2) DEFAULT NULL,
  PRIMARY KEY  (`id`)
) DEFAULT CHARSET=utf8mb4 AUTO_INCREMENT=1 ;

-- --------------------------------------------------------

--
-- Table structure for table  `spamfilter_users`
--

CREATE TABLE `spamfilter_users` (
  `id` int(11) unsigned NOT NULL auto_increment,
  `sys_userid` int(11) unsigned NOT NULL DEFAULT '0',
  `sys_groupid` int(11) unsigned NOT NULL DEFAULT '0',
  `sys_perm_user` varchar(5) NOT NULL DEFAULT '',
  `sys_perm_group` varchar(5) NOT NULL DEFAULT '',
  `sys_perm_other` varchar(5) NOT NULL DEFAULT '',
  `server_id` int(11) unsigned NOT NULL DEFAULT '0',
  `priority` tinyint(3) unsigned NOT NULL default '7',
  `policy_id` int(11) unsigned NOT NULL default '0',
  `email` varchar(255) NOT NULL DEFAULT '',
  `fullname` varchar(64) default NULL,
  `local` varchar(1) default NULL,
  PRIMARY KEY  (`id`),
  UNIQUE KEY `email` (`email`)
) DEFAULT CHARSET=utf8mb4 AUTO_INCREMENT=1 ;

-- --------------------------------------------------------

--
-- Table structure for table  `spamfilter_wblist`
--

CREATE TABLE `spamfilter_wblist` (
  `wblist_id` int(11) unsigned NOT NULL auto_increment,
  `sys_userid` int(11) unsigned NOT NULL DEFAULT '0',
  `sys_groupid` int(11) unsigned NOT NULL DEFAULT '0',
  `sys_perm_user` varchar(5) NOT NULL DEFAULT '',
  `sys_perm_group` varchar(5) NOT NULL DEFAULT '',
  `sys_perm_other` varchar(5) NOT NULL DEFAULT '',
  `server_id` int(11) unsigned NOT NULL DEFAULT '0',
  `wb` enum('W','B') NOT NULL default 'W',
  `rid` int(11) unsigned NOT NULL DEFAULT '0',
  `email` varchar(255) NOT NULL DEFAULT '',
  `priority` tinyint(3) unsigned NOT NULL DEFAULT '0',
  `active` enum('y','n') NOT NULL default 'y',
  PRIMARY KEY  (`wblist_id`)
) DEFAULT CHARSET=utf8mb4 AUTO_INCREMENT=1 ;

-- --------------------------------------------------------

--
-- Table structure for table  `support_message`
--

CREATE TABLE `support_message` (
  `support_message_id` int(11) unsigned NOT NULL auto_increment,
  `sys_userid` int(11) unsigned NOT NULL default '0',
  `sys_groupid` int(11) unsigned NOT NULL default '0',
  `sys_perm_user` varchar(5) default NULL,
  `sys_perm_group` varchar(5) default NULL,
  `sys_perm_other` varchar(5) default NULL,
  `recipient_id` int(11) unsigned NOT NULL default '0',
  `sender_id` int(11) unsigned NOT NULL default '0',
  `subject` varchar(255) default NULL,
  `message` text default NULL,
  `tstamp` int(11) NOT NULL default '0',
  PRIMARY KEY  (`support_message_id`)
) DEFAULT CHARSET=utf8mb4 AUTO_INCREMENT=1 ;

-- --------------------------------------------------------

--
-- Table structure for table `sys_config`
--

CREATE TABLE `sys_config` (
  `group` varchar(64) NOT NULL DEFAULT '',
  `name` varchar(64) NOT NULL DEFAULT '',
  `value` varchar(255) NOT NULL DEFAULT '',
  PRIMARY KEY (`group`, `name`)
) DEFAULT CHARSET=utf8;


-- --------------------------------------------------------

--
-- Table structure for table `sys_cron`
--

CREATE TABLE IF NOT EXISTS `sys_cron` (
  `name` varchar(50) NOT NULL DEFAULT '',
  `last_run` datetime NULL DEFAULT NULL,
  `next_run` datetime NULL DEFAULT NULL,
  `running` tinyint(1) UNSIGNED NOT NULL DEFAULT '0',
  `pid` int(11) unsigned NULL DEFAULT NULL,
  PRIMARY KEY (`name`)
) DEFAULT CHARSET=utf8;


-- --------------------------------------------------------

--
-- Table structure for table  `sys_datalog`
--

CREATE TABLE `sys_datalog` (
  `datalog_id` int(11) unsigned NOT NULL auto_increment,
  `server_id` int(11) unsigned NOT NULL DEFAULT '0',
  `dbtable` varchar(255) NOT NULL default '',
  `dbidx` varchar(255) NOT NULL default '',
  `action` char(1) NOT NULL default '',
  `tstamp` int(11) NOT NULL default '0',
  `user` varchar(255) NOT NULL default '',
  `data` longtext,
  `status` set('pending','ok','warning','error') NOT NULL default 'ok',
  `error` mediumtext,
  `session_id` varchar(64) NOT NULL DEFAULT '',
  PRIMARY KEY  (`datalog_id`),
  KEY `server_id` (`server_id`,`status`)
) DEFAULT CHARSET=utf8mb4 AUTO_INCREMENT=1 ;

-- --------------------------------------------------------

--
-- Table structure for table  `sys_dbsync`
--

CREATE TABLE `sys_dbsync` (
  `id` int(11) unsigned NOT NULL auto_increment,
  `jobname` varchar(64) NOT NULL default '',
  `sync_interval_minutes` int(11) unsigned NOT NULL default '0',
  `db_type` varchar(16) NOT NULL default '',
  `db_host` varchar(255) NOT NULL default '',
  `db_name` varchar(64) NOT NULL default '',
  `db_username` varchar(64) NOT NULL default '',
  `db_password` varchar(64) NOT NULL default '',
  `db_tables` varchar(255) NOT NULL default 'admin,forms',
  `empty_datalog` int(11) unsigned NOT NULL default '0',
  `sync_datalog_external` int(11) unsigned NOT NULL default '0',
  `active` tinyint(1) NOT NULL default '1',
  `last_datalog_id` int(11) unsigned NOT NULL default '0',
  PRIMARY KEY  (`id`),
  KEY `last_datalog_id` (`last_datalog_id`)
) DEFAULT CHARSET=utf8mb4 AUTO_INCREMENT=1 ;

-- --------------------------------------------------------

--
-- Table structure for table `sys_extension_grant`
--

CREATE TABLE `sys_extension_grant` (
  `grant_id` int(11) unsigned NOT NULL AUTO_INCREMENT,
  `extension` varchar(64) NOT NULL DEFAULT '',
  `table_name` varchar(64) NOT NULL DEFAULT '',
  `privileges` varchar(64) NOT NULL DEFAULT '',
  PRIMARY KEY (`grant_id`),
  UNIQUE KEY `extension_table` (`extension`,`table_name`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 AUTO_INCREMENT=1;

-- --------------------------------------------------------

--
-- Table structure for table  `sys_filesync`
--

CREATE TABLE `sys_filesync` (
  `id` int(11) unsigned NOT NULL auto_increment,
  `jobname` varchar(64) NOT NULL default '',
  `sync_interval_minutes` int(11) unsigned NOT NULL default '0',
  `ftp_host` varchar(255) NOT NULL default '',
  `ftp_path` varchar(255) NOT NULL default '',
  `ftp_username` varchar(64) NOT NULL default '',
  `ftp_password` varchar(64) NOT NULL default '',
  `local_path` varchar(255) NOT NULL default '',
  `wput_options` varchar(255) NOT NULL default '--timestamping --reupload --dont-continue',
  `active` tinyint(1) NOT NULL default '1',
  PRIMARY KEY  (`id`)
) DEFAULT CHARSET=utf8mb4 AUTO_INCREMENT=1 ;

-- --------------------------------------------------------

--
-- Table structure for table  `sys_group`
--

CREATE TABLE `sys_group` (
  `groupid` int(11) unsigned NOT NULL auto_increment,
  `name` varchar(64) NOT NULL default '',
  `description` text,
  `client_id` int(11) unsigned NOT NULL default '0',
  PRIMARY KEY  (`groupid`)
) DEFAULT CHARSET=utf8mb4 AUTO_INCREMENT=1 ;

-- --------------------------------------------------------

--
-- Table structure for table  `sys_ini`
--

CREATE TABLE `sys_ini` (
  `sysini_id` int(11) unsigned NOT NULL auto_increment,
  `config` longtext,
  `default_logo` mediumtext NULL,
  `custom_logo` mediumtext NULL,
  PRIMARY KEY  (`sysini_id`)
) DEFAULT CHARSET=utf8mb4 AUTO_INCREMENT=1 ;

-- --------------------------------------------------------

--
-- Table structure for table  `sys_log`
--

CREATE TABLE `sys_log` (
  `syslog_id` int(11) unsigned NOT NULL auto_increment,
  `server_id` int(11) unsigned NOT NULL default '0',
  `datalog_id` int(11) unsigned NOT NULL default '0',
  `loglevel` tinyint(4) NOT NULL default '0',
  `tstamp` int(11) unsigned NOT NULL DEFAULT '0',
  `message` text,
  PRIMARY KEY  (`syslog_id`)
) DEFAULT CHARSET=utf8mb4 AUTO_INCREMENT=1 ;

-- --------------------------------------------------------

--
-- Table structure for table `sys_message`
--

CREATE TABLE IF NOT EXISTS `sys_message` (
  `message_id` int(11) unsigned NOT NULL AUTO_INCREMENT,
  `sys_userid` int(11) unsigned NOT NULL DEFAULT 0,
  `sys_groupid` int(11) unsigned NOT NULL DEFAULT 0,
  `sys_perm_user` VARCHAR(5) DEFAULT 'r',
  `sys_perm_group` VARCHAR(5) DEFAULT 'r',
  `sys_perm_other` VARCHAR(5) DEFAULT '',
  `message_state` enum('info','warning','error') NOT NULL DEFAULT 'info',
  `message_date` datetime NULL DEFAULT NULL,
  `message_ack` enum('y','n') NOT NULL DEFAULT 'n',
  `relation` varchar(255) NULL DEFAULT NULL,
  `message` TEXT DEFAULT NULL,
  PRIMARY KEY (`message_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 AUTO_INCREMENT=1;

-- --------------------------------------------------------

--
-- Table structure for table `sys_remoteaction`
--

CREATE TABLE `sys_remoteaction` (
  `action_id` int(11) unsigned NOT NULL AUTO_INCREMENT,
  `server_id` int(11) unsigned NOT NULL DEFAULT '0',
  `tstamp` int(11) NOT NULL DEFAULT '0',
  `action_type` varchar(20) NOT NULL DEFAULT '',
  `action_param` mediumtext,
  `action_state` enum('pending','ok','warning','error') NOT NULL DEFAULT 'pending',
  `response` mediumtext,
  PRIMARY KEY (`action_id`),
  KEY `server_id` (`server_id`)
) DEFAULT CHARSET=utf8mb4 AUTO_INCREMENT=1 ;

-- --------------------------------------------------------

--
-- Table structure for table `sys_session`
--

CREATE TABLE `sys_session` (
  `session_id` varchar(64) NOT NULL DEFAULT '',
  `date_created` datetime NULL DEFAULT NULL,
  `last_updated` datetime NULL DEFAULT NULL,
  `permanent` enum('n','y') NOT NULL DEFAULT 'n',
  `session_data` longtext,
  PRIMARY KEY (`session_id`),
  KEY `last_updated` (`last_updated`)
) DEFAULT CHARSET=utf8mb4 ;

-- --------------------------------------------------------

--
-- Table structure for table `sys_theme`
--

CREATE TABLE IF NOT EXISTS `sys_theme` (
  `sys_userid` int(11) unsigned NOT NULL DEFAULT '0',
  `sys_groupid` int(11) unsigned NOT NULL DEFAULT '0',
  `sys_perm_user` varchar(5) DEFAULT NULL,
  `sys_perm_group` varchar(5) DEFAULT NULL,
  `sys_perm_other` varchar(5) DEFAULT NULL,
  `var_id` int(11) unsigned NOT NULL AUTO_INCREMENT,
  `tpl_name` varchar(32) NOT NULL DEFAULT '',
  `username` varchar(64) NOT NULL DEFAULT '',
  `logo_url` varchar(255) NOT NULL DEFAULT '',
  PRIMARY KEY (`var_id`)
) DEFAULT CHARSET=utf8mb4 ;

-- --------------------------------------------------------

--
-- Table structure for table  `sys_user`
--

CREATE TABLE `sys_user` (
  `userid` int(11) unsigned NOT NULL auto_increment,
  `sys_userid` int(11) unsigned NOT NULL default '1' COMMENT 'Created by userid',
  `sys_groupid` int(11) unsigned NOT NULL default '1' COMMENT 'Created by groupid',
  `sys_perm_user` varchar(5) NOT NULL default 'riud',
  `sys_perm_group` varchar(5) NOT NULL default 'riud',
  `sys_perm_other` varchar(5) NOT NULL default '',
  `username` varchar(64) NOT NULL default '',
  `passwort` varchar(200) NOT NULL default '',
  `modules` varchar(255) NOT NULL default '',
  `startmodule` varchar(255) NOT NULL default '',
  `app_theme` varchar(32) NOT NULL default 'algopanel',
  `typ` varchar(16) NOT NULL default 'user',
  `active` tinyint(1) NOT NULL default '1',
  `language` varchar(2) NOT NULL default 'en',
  `groups` TEXT,
  `default_group` int(11) unsigned NOT NULL default '0',
  `client_id` int(11) unsigned NOT NULL default '0',
  `id_rsa` text,
  `ssh_rsa` text,
  `lost_password_function` tinyint(1) NOT NULL default '1',
  `lost_password_hash` VARCHAR(50) NOT NULL default '',
  `lost_password_reqtime` DATETIME NULL default NULL,
  `otp_type` set('none', 'email') NOT NULL DEFAULT 'none',
  `otp_data` varchar(255) DEFAULT NULL,
  `otp_recovery` varchar(64) DEFAULT NULL,
  `otp_attempts` tinyint(4) NOT NULL DEFAULT 0,
  `last_password_change` DATE NULL DEFAULT (CURDATE()),
  PRIMARY KEY  (`userid`)
) DEFAULT CHARSET=utf8mb4 AUTO_INCREMENT=1 ;

-- --------------------------------------------------------

--
-- Table structure for table `webdav_user`
--

CREATE TABLE `webdav_user` (
  `webdav_user_id` int(11) unsigned NOT NULL AUTO_INCREMENT,
  `sys_userid` int(11) unsigned NOT NULL DEFAULT '0',
  `sys_groupid` int(11) unsigned NOT NULL DEFAULT '0',
  `sys_perm_user` varchar(5) DEFAULT NULL,
  `sys_perm_group` varchar(5) DEFAULT NULL,
  `sys_perm_other` varchar(5) DEFAULT NULL,
  `server_id` int(11) unsigned NOT NULL DEFAULT '0',
  `parent_domain_id` int(11) unsigned NOT NULL DEFAULT '0',
  `username` varchar(64) DEFAULT NULL,
  `username_prefix` varchar(50) NOT NULL default '',
  `password` varchar(200) DEFAULT NULL,
  `active` enum('n','y') NOT NULL DEFAULT 'y',
  `dir` varchar(255) DEFAULT NULL,
  PRIMARY KEY (`webdav_user_id`)
) DEFAULT CHARSET=utf8mb4 AUTO_INCREMENT=1 ;

-- --------------------------------------------------------

--
-- Table structure for table `web_backup`
--

CREATE TABLE `web_backup` (
  `backup_id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `server_id` int(10) unsigned NOT NULL DEFAULT '0',
  `parent_domain_id` int(10) unsigned NOT NULL DEFAULT '0',
  `backup_type` enum('web','mysql','mongodb') NOT NULL DEFAULT 'web',
  `backup_mode` varchar(64) NOT NULL DEFAULT  '',
  `backup_format` varchar(64) NOT NULL DEFAULT '',
  `tstamp` int(10) unsigned NOT NULL DEFAULT '0',
  `filename` varchar(255) NOT NULL DEFAULT '',
  `filesize` VARCHAR(20) NOT NULL DEFAULT '',
  `backup_password` VARCHAR(255) NOT NULL DEFAULT '',
  PRIMARY KEY (`backup_id`)
) DEFAULT CHARSET=utf8mb4 AUTO_INCREMENT=1 ;

-- --------------------------------------------------------

--
-- Table structure for table `web_database`
--

CREATE TABLE `web_database` (
  `database_id` int(11) unsigned NOT NULL AUTO_INCREMENT,
  `sys_userid` int(11) unsigned NOT NULL DEFAULT '0',
  `sys_groupid` int(11) unsigned NOT NULL DEFAULT '0',
  `sys_perm_user` varchar(5) DEFAULT NULL,
  `sys_perm_group` varchar(5) DEFAULT NULL,
  `sys_perm_other` varchar(5) DEFAULT NULL,
  `server_id` int(11) unsigned NOT NULL DEFAULT '0',
  `parent_domain_id` int(11) unsigned NOT NULL DEFAULT  '0',
  `type` varchar(16) NOT NULL DEFAULT 'mysql',
  `database_name` varchar(64) DEFAULT NULL,
  `database_name_prefix` varchar(50) NOT NULL default '',
  `database_quota` int(11) DEFAULT NULL,
  `quota_exceeded` enum('n','y') NOT NULL DEFAULT 'n',
  `last_quota_notification` date NULL default NULL,
  `database_user_id` int(11) unsigned DEFAULT NULL,
  `database_ro_user_id` int(11) unsigned DEFAULT NULL,
  `database_charset` varchar(64) DEFAULT NULL,
  `remote_access` enum('n','y') NOT NULL DEFAULT 'y',
  `remote_ips` text,
  `backup_interval` VARCHAR( 255 ) NOT NULL DEFAULT 'none',
  `backup_copies` INT NOT NULL DEFAULT '1',
  `active` enum('n','y') NOT NULL DEFAULT 'y',
  PRIMARY KEY (`database_id`),
  KEY `database_user_id` (`database_user_id`),
  KEY `database_ro_user_id` (`database_ro_user_id`)
) DEFAULT CHARSET=utf8mb4 AUTO_INCREMENT=1 ;

-- --------------------------------------------------------

--
-- Tabellenstruktur für Tabelle `web_database_user`
--

CREATE TABLE IF NOT EXISTS `web_database_user` (
  `database_user_id` int(11) unsigned NOT NULL AUTO_INCREMENT,
  `sys_userid` int(11) unsigned NOT NULL DEFAULT '0',
  `sys_groupid` int(11) unsigned NOT NULL DEFAULT '0',
  `sys_perm_user` varchar(5) DEFAULT NULL,
  `sys_perm_group` varchar(5) DEFAULT NULL,
  `sys_perm_other` varchar(5) DEFAULT NULL,
  `server_id` int(11) UNSIGNED NOT NULL DEFAULT '0',
  `database_user` varchar(64) DEFAULT NULL,
  `database_user_prefix` varchar(50) NOT NULL default '',
  `database_password` varchar(64) DEFAULT NULL,
  `database_password_sha2` varchar(255) DEFAULT NULL,
  `database_password_mongo` varchar(32) DEFAULT NULL,
  `database_password_postgres` varchar(255) DEFAULT NULL,
  PRIMARY KEY (`database_user_id`)
)  DEFAULT CHARSET=utf8mb4 AUTO_INCREMENT=1 ;

-- --------------------------------------------------------

--
-- Table structure for table  `web_domain`
--

CREATE TABLE `web_domain` (
  `domain_id` int(11) unsigned NOT NULL auto_increment,
  `sys_userid` int(11) unsigned NOT NULL default '0',
  `sys_groupid` int(11) unsigned NOT NULL default '0',
  `sys_perm_user` varchar(5) default NULL,
  `sys_perm_group` varchar(5) default NULL,
  `sys_perm_other` varchar(5) default NULL,
  `server_id` int(11) unsigned NOT NULL default '0',
  `ip_address` varchar(39) default NULL,
  `ipv6_address` VARCHAR( 255 ) default NULL,
  `domain` varchar(255) default NULL,
  `type` varchar(32) default NULL,
  `parent_domain_id` int(11) unsigned NOT NULL default '0',
  `vhost_type` varchar(32) default NULL,
  `document_root` varchar(255) default NULL,
  `web_folder` varchar(100) default NULL,
  `system_user` varchar(255) default NULL,
  `system_group` varchar(255) default NULL,
  `hd_quota` bigint(20) NOT NULL default '0',
  `traffic_quota` bigint(20) NOT NULL default '-1',
  `cgi` enum('n','y') NOT NULL default 'y',
  `ssi` enum('n','y') NOT NULL default 'y',
  `suexec` enum('n','y') NOT NULL default 'y',
  `errordocs` tinyint(1) NOT NULL default '1',
  `is_subdomainwww` tinyint(1) NOT NULL default '1',
  `subdomain` enum('none','www','*') NOT NULL default 'none',
  `php` varchar(32) NOT NULL default 'y',
  `ruby` enum('n','y') NOT NULL default 'n',
  `python` enum('n','y') NOT NULL default 'n',
  `perl` enum('n','y') NOT NULL default 'n',
  `redirect_type` varchar(255) default NULL,
  `redirect_path` varchar(255) default NULL,
  `seo_redirect` varchar(255) default NULL,
  `rewrite_to_https` ENUM('y','n') NOT NULL DEFAULT 'n',
  `ssl` enum('n','y') NOT NULL default 'n',
  `ssl_letsencrypt` enum('n','y') NOT NULL DEFAULT 'n',
  `ssl_letsencrypt_exclude` enum('n','y') NOT NULL DEFAULT 'n',
  `ssl_state` varchar(255) NULL,
  `ssl_locality` varchar(255) NULL,
  `ssl_organisation` varchar(255) NULL,
  `ssl_organisation_unit` varchar(255) NULL,
  `ssl_country` varchar(255) NULL,
  `ssl_domain` varchar(255) NULL,
  `ssl_request` mediumtext NULL,
  `ssl_cert` mediumtext NULL,
  `ssl_bundle` mediumtext NULL,
  `ssl_key` mediumtext NULL,
  `ssl_action` varchar(16) NULL,
  `stats_password` varchar(255) default NULL,
  `stats_type` varchar(255) default 'awstats',
  `allow_override` varchar(255) NOT NULL default 'All',
  `apache_directives` mediumtext NULL DEFAULT NULL,
  `nginx_directives` mediumtext NULL DEFAULT NULL,
  `php_fpm_use_socket` ENUM('n','y') NOT NULL DEFAULT 'y',
  `php_fpm_chroot` enum('n','y') NOT NULL DEFAULT 'n',
  `pm` enum('static','dynamic','ondemand') NOT NULL DEFAULT 'ondemand',
  `pm_max_children` int(11) NOT NULL DEFAULT '10',
  `pm_start_servers` int(11) NOT NULL DEFAULT '2',
  `pm_min_spare_servers` int(11) NOT NULL DEFAULT '1',
  `pm_max_spare_servers` int(11) NOT NULL DEFAULT '5',
  `pm_process_idle_timeout` int(11) NOT NULL DEFAULT '10',
  `pm_max_requests` int(11) NOT NULL DEFAULT '0',
  `php_open_basedir` mediumtext,
  `custom_php_ini` mediumtext,
  `backup_interval` VARCHAR( 255 ) NOT NULL DEFAULT 'none',
  `backup_copies` INT NOT NULL DEFAULT '1',
  `backup_format_web` VARCHAR( 255 ) NOT NULL default 'default',
  `backup_format_db` VARCHAR( 255 ) NOT NULL default 'gzip',
  `backup_encrypt` enum('n','y') NOT NULL DEFAULT 'n',
  `backup_password` VARCHAR( 255 ) NOT NULL DEFAULT '',
  `backup_excludes` mediumtext,
  `active` enum('n','y') NOT NULL default 'y',
  `traffic_quota_lock` enum('n','y') NOT NULL default 'n',
  `proxy_directives` mediumtext,
  `last_quota_notification` date NULL default NULL,
  `rewrite_rules` mediumtext,
  `added_date` date NULL DEFAULT NULL,
  `added_by` varchar(255) DEFAULT NULL,
  `directive_snippets_id` int(11) unsigned NOT NULL default '0',
  `enable_pagespeed` ENUM('y','n') NOT NULL DEFAULT 'n',
  `http_port` int(11) unsigned NOT NULL DEFAULT '80',
  `https_port` int(11) unsigned NOT NULL DEFAULT '443',
  `folder_directive_snippets` text,
  `log_retention` int(11) NOT NULL DEFAULT '10',
  `proxy_protocol` enum('n','y') NOT NULL default 'n',
  `server_php_id` INT(11) UNSIGNED NOT NULL DEFAULT 0,
  `jailkit_chroot_app_sections` mediumtext NULL DEFAULT NULL,
  `jailkit_chroot_app_programs` mediumtext NULL DEFAULT NULL,
  `delete_unused_jailkit` enum('n','y') NOT NULL default 'n',
  `last_jailkit_update` date NULL DEFAULT NULL,
  `last_jailkit_hash` varchar(255) DEFAULT NULL,
  `disable_symlinknotowner` enum('n','y') NOT NULL default 'n',
  PRIMARY KEY  (`domain_id`),
  UNIQUE KEY `serverdomain` (  `server_id` , `ip_address`,  `domain` )
) ENGINE=InnoDB ROW_FORMAT=DYNAMIC DEFAULT CHARSET=utf8mb4 AUTO_INCREMENT=1 ;

-- --------------------------------------------------------

--
-- Table structure for table `web_folder`
--

CREATE TABLE IF NOT EXISTS `web_folder` (
  `web_folder_id` bigint(20) NOT NULL AUTO_INCREMENT,
  `sys_userid` int(11) NOT NULL DEFAULT '0',
  `sys_groupid` int(11) NOT NULL DEFAULT '0',
  `sys_perm_user` varchar(5) DEFAULT NULL,
  `sys_perm_group` varchar(5) DEFAULT NULL,
  `sys_perm_other` varchar(5) DEFAULT NULL,
  `server_id` int(11) NOT NULL DEFAULT '0',
  `parent_domain_id` int(11) NOT NULL DEFAULT '0',
  `path` varchar(255) DEFAULT NULL,
  `active` varchar(255) NOT NULL DEFAULT 'y',
  PRIMARY KEY (`web_folder_id`)
) DEFAULT CHARSET=utf8mb4 AUTO_INCREMENT=1 ;

--
-- Dumping data for table `web_folder`
--


-- --------------------------------------------------------

--
-- Table structure for table `web_folder_user`
--

CREATE TABLE IF NOT EXISTS `web_folder_user` (
  `web_folder_user_id` bigint(20) NOT NULL AUTO_INCREMENT,
  `sys_userid` int(11) NOT NULL DEFAULT '0',
  `sys_groupid` int(11) NOT NULL DEFAULT '0',
  `sys_perm_user` varchar(5) DEFAULT NULL,
  `sys_perm_group` varchar(5) DEFAULT NULL,
  `sys_perm_other` varchar(5) DEFAULT NULL,
  `server_id` int(11) NOT NULL DEFAULT '0',
  `web_folder_id` int(11) NOT NULL DEFAULT '0',
  `username` varchar(255) DEFAULT NULL,
  `password` varchar(255) DEFAULT NULL,
  `active` varchar(255) NOT NULL DEFAULT 'y',
  PRIMARY KEY (`web_folder_user_id`)
) DEFAULT CHARSET=utf8mb4 AUTO_INCREMENT=1 ;

--
-- Dumping data for table `web_folder_user`
--

-- --------------------------------------------------------

--
-- Table structure for table  `web_traffic`
--

CREATE TABLE `web_traffic` (
  `hostname` varchar(255) NOT NULL DEFAULT '',
  `traffic_date` date NULL DEFAULT NULL,
  `traffic_bytes` bigint(32) unsigned NOT NULL default '0',
  UNIQUE KEY  (`hostname`,`traffic_date`)
) DEFAULT CHARSET=utf8mb4 ;

-- --------------------------------------------------------

--
-- Table structure for table `xmpp_domain`
--

CREATE TABLE `xmpp_domain` (
  `domain_id` int(11) unsigned NOT NULL auto_increment,
  `sys_userid` int(11) unsigned NOT NULL default '0',
  `sys_groupid` int(11) unsigned NOT NULL default '0',
  `sys_perm_user` varchar(5) NOT NULL default '',
  `sys_perm_group` varchar(5) NOT NULL default '',
  `sys_perm_other` varchar(5) NOT NULL default '',
  `server_id` int(11) unsigned NOT NULL default '0',
  `domain` varchar(255) NOT NULL default '',

  `management_method` ENUM( 'normal', 'maildomain' ) NOT NULL default 'normal',
  `public_registration` ENUM( 'n', 'y' ) NOT NULL default 'n',
  `registration_url` varchar(255) NOT NULL DEFAULT '',
  `registration_message` varchar(255) NOT NULL DEFAULT '',
  `domain_admins` text,

  `use_pubsub` enum('n','y') NOT NULL DEFAULT 'n',
  `use_proxy` enum('n','y') NOT NULL DEFAULT 'n',
  `use_anon_host` enum('n','y') NOT NULL DEFAULT 'n',

  `use_vjud` enum('n','y') NOT NULL DEFAULT 'n',
  `vjud_opt_mode` enum('in', 'out') NOT NULL DEFAULT 'in',

  `use_muc_host` enum('n','y') NOT NULL DEFAULT 'n',
  `muc_name` varchar(30) NOT NULL DEFAULT '',
  `muc_restrict_room_creation` enum('n', 'y', 'm') NOT NULL DEFAULT 'm',
  `muc_admins` text,
  `use_pastebin` enum('n','y') NOT NULL DEFAULT 'n',
  `pastebin_expire_after` int(3) NOT NULL DEFAULT 48,
  `pastebin_trigger` varchar(10) NOT NULL DEFAULT '!paste',
  `use_http_archive` enum('n','y') NOT NULL DEFAULT 'n',
  `http_archive_show_join` enum('n', 'y') NOT NULL DEFAULT 'n',
  `http_archive_show_status` enum('n', 'y') NOT NULL DEFAULT 'n',
  `use_status_host` enum('n','y') NOT NULL DEFAULT 'n',

  `ssl_state` varchar(255) NULL,
  `ssl_locality` varchar(255) NULL,
  `ssl_organisation` varchar(255) NULL,
  `ssl_organisation_unit` varchar(255) NULL,
  `ssl_country` varchar(255) NULL,
  `ssl_email` varchar(255) NULL,
  `ssl_request` mediumtext NULL,
  `ssl_cert` mediumtext NULL,
  `ssl_bundle` mediumtext NULL,
  `ssl_key` mediumtext NULL,
  `ssl_action` varchar(16) NULL,

  `active` enum('n','y') NOT NULL DEFAULT 'n',
  PRIMARY KEY  (`domain_id`),
  KEY `server_id` (`server_id`,`domain`),
  KEY `domain_active` (`domain`,`active`)
) DEFAULT CHARSET=utf8mb4 AUTO_INCREMENT=1 ;

-- --------------------------------------------------------

--
-- Table structure for table  `xmpp_user`
--

CREATE TABLE `xmpp_user` (
  `xmppuser_id` int(11) unsigned NOT NULL auto_increment,
  `sys_userid` int(11) unsigned NOT NULL default '0',
  `sys_groupid` int(11) unsigned NOT NULL default '0',
  `sys_perm_user` varchar(5) NOT NULL default '',
  `sys_perm_group` varchar(5) NOT NULL default '',
  `sys_perm_other` varchar(5) NOT NULL default '',
  `server_id` int(11) unsigned NOT NULL default '0',
  `jid` varchar(255) NOT NULL default '',
  `password` varchar(255) NOT NULL default '',
  `active` enum('n','y') NOT NULL DEFAULT 'n',
  PRIMARY KEY  (`xmppuser_id`),
  KEY `server_id` (`server_id`,`jid`),
  KEY `jid_active` (`jid`,`active`)
) DEFAULT CHARSET=utf8mb4 AUTO_INCREMENT=1 ;

-- --------------------------------------------------------

-- --------------------------------------------------------
-- --------------------------------------------------------
-- DB-DATA
-- --------------------------------------------------------
-- --------------------------------------------------------

--
-- Dumping data for table `aps_settings`
--

INSERT INTO `aps_settings` (`id`, `name`, `value`) VALUES(1, 'ignore-php-extension', '');
INSERT INTO `aps_settings` (`id`, `name`, `value`) VALUES(2, 'ignore-php-configuration', '');
INSERT INTO `aps_settings` (`id`, `name`, `value`) VALUES(3, 'ignore-webserver-module', '');

-- --------------------------------------------------------

--
-- Dumping data for table `country`
--

INSERT INTO `country` (`iso`, `name`, `printable_name`, `iso3`, `numcode`, `eu`) VALUES
('AF', 'AFGHANISTAN', 'Afghanistan', 'AFG', 4, 'n'),
('AL', 'ALBANIA', 'Albania', 'ALB', 8, 'n'),
('DZ', 'ALGERIA', 'Algeria', 'DZA', 12, 'n'),
('AS', 'AMERICAN SAMOA', 'American Samoa', 'ASM', 16, 'n'),
('AD', 'ANDORRA', 'Andorra', 'AND', 20, 'n'),
('AO', 'ANGOLA', 'Angola', 'AGO', 24, 'n'),
('AI', 'ANGUILLA', 'Anguilla', 'AIA', 660, 'n'),
('AQ', 'ANTARCTICA', 'Antarctica', NULL, NULL, 'n'),
('AG', 'ANTIGUA AND BARBUDA', 'Antigua and Barbuda', 'ATG', 28, 'n'),
('AR', 'ARGENTINA', 'Argentina', 'ARG', 32, 'n'),
('AM', 'ARMENIA', 'Armenia', 'ARM', 51, 'n'),
('AW', 'ARUBA', 'Aruba', 'ABW', 533, 'n'),
('AU', 'AUSTRALIA', 'Australia', 'AUS', 36, 'n'),
('AT', 'AUSTRIA', 'Austria', 'AUT', 40, 'y'),
('AZ', 'AZERBAIJAN', 'Azerbaijan', 'AZE', 31, 'n'),
('BS', 'BAHAMAS', 'Bahamas', 'BHS', 44, 'n'),
('BH', 'BAHRAIN', 'Bahrain', 'BHR', 48, 'n'),
('BD', 'BANGLADESH', 'Bangladesh', 'BGD', 50, 'n'),
('BB', 'BARBADOS', 'Barbados', 'BRB', 52, 'n'),
('BY', 'BELARUS', 'Belarus', 'BLR', 112, 'n'),
('BE', 'BELGIUM', 'Belgium', 'BEL', 56, 'y'),
('BZ', 'BELIZE', 'Belize', 'BLZ', 84, 'n'),
('BJ', 'BENIN', 'Benin', 'BEN', 204, 'n'),
('BM', 'BERMUDA', 'Bermuda', 'BMU', 60, 'n'),
('BT', 'BHUTAN', 'Bhutan', 'BTN', 64, 'n'),
('BO', 'BOLIVIA', 'Bolivia', 'BOL', 68, 'n'),
('BA', 'BOSNIA AND HERZEGOVINA', 'Bosnia and Herzegovina', 'BIH', 70, 'n'),
('BW', 'BOTSWANA', 'Botswana', 'BWA', 72, 'n'),
('BV', 'BOUVET ISLAND', 'Bouvet Island', NULL, NULL, 'n'),
('BR', 'BRAZIL', 'Brazil', 'BRA', 76, 'n'),
('IO', 'BRITISH INDIAN OCEAN TERRITORY', 'British Indian Ocean Territory', NULL, NULL, 'n'),
('BN', 'BRUNEI DARUSSALAM', 'Brunei Darussalam', 'BRN', 96, 'n'),
('BG', 'BULGARIA', 'Bulgaria', 'BGR', 100, 'y'),
('BF', 'BURKINA FASO', 'Burkina Faso', 'BFA', 854, 'n'),
('BI', 'BURUNDI', 'Burundi', 'BDI', 108, 'n'),
('KH', 'CAMBODIA', 'Cambodia', 'KHM', 116, 'n'),
('CM', 'CAMEROON', 'Cameroon', 'CMR', 120, 'n'),
('CA', 'CANADA', 'Canada', 'CAN', 124, 'n'),
('CV', 'CAPE VERDE', 'Cape Verde', 'CPV', 132, 'n'),
('KY', 'CAYMAN ISLANDS', 'Cayman Islands', 'CYM', 136, 'n'),
('CF', 'CENTRAL AFRICAN REPUBLIC', 'Central African Republic', 'CAF', 140, 'n'),
('TD', 'CHAD', 'Chad', 'TCD', 148, 'n'),
('CL', 'CHILE', 'Chile', 'CHL', 152, 'n'),
('CN', 'CHINA', 'China', 'CHN', 156, 'n'),
('CX', 'CHRISTMAS ISLAND', 'Christmas Island', NULL, NULL, 'n'),
('CC', 'COCOS (KEELING) ISLANDS', 'Cocos (Keeling) Islands', NULL, NULL, 'n'),
('CO', 'COLOMBIA', 'Colombia', 'COL', 170, 'n'),
('KM', 'COMOROS', 'Comoros', 'COM', 174, 'n'),
('CG', 'CONGO', 'Congo', 'COG', 178, 'n'),
('CD', 'CONGO, THE DEMOCRATIC REPUBLIC OF THE', 'Congo, the Democratic Republic of the', 'COD', 180, 'n'),
('CK', 'COOK ISLANDS', 'Cook Islands', 'COK', 184, 'n'),
('CR', 'COSTA RICA', 'Costa Rica', 'CRI', 188, 'n'),
('CI', 'COTE D''IVOIRE', 'Cote D''Ivoire', 'CIV', 384, 'n'),
('HR', 'CROATIA', 'Croatia', 'HRV', 191, 'y'),
('CU', 'CUBA', 'Cuba', 'CUB', 192, 'n'),
('CY', 'CYPRUS', 'Cyprus', 'CYP', 196, 'y'),
('CZ', 'CZECH REPUBLIC', 'Czech Republic', 'CZE', 203, 'y'),
('DK', 'DENMARK', 'Denmark', 'DNK', 208, 'y'),
('DJ', 'DJIBOUTI', 'Djibouti', 'DJI', 262, 'n'),
('DM', 'DOMINICA', 'Dominica', 'DMA', 212, 'n'),
('DO', 'DOMINICAN REPUBLIC', 'Dominican Republic', 'DOM', 214, 'n'),
('EC', 'ECUADOR', 'Ecuador', 'ECU', 218, 'n'),
('EG', 'EGYPT', 'Egypt', 'EGY', 818, 'n'),
('SV', 'EL SALVADOR', 'El Salvador', 'SLV', 222, 'n'),
('GQ', 'EQUATORIAL GUINEA', 'Equatorial Guinea', 'GNQ', 226, 'n'),
('ER', 'ERITREA', 'Eritrea', 'ERI', 232, 'n'),
('EE', 'ESTONIA', 'Estonia', 'EST', 233, 'y'),
('ET', 'ETHIOPIA', 'Ethiopia', 'ETH', 231, 'n'),
('FK', 'FALKLAND ISLANDS (MALVINAS)', 'Falkland Islands (Malvinas)', 'FLK', 238, 'n'),
('FO', 'FAROE ISLANDS', 'Faroe Islands', 'FRO', 234, 'n'),
('FJ', 'FIJI', 'Fiji', 'FJI', 242, 'n'),
('FI', 'FINLAND', 'Finland', 'FIN', 246, 'y'),
('FR', 'FRANCE', 'France', 'FRA', 250, 'y'),
('GF', 'FRENCH GUIANA', 'French Guiana', 'GUF', 254, 'n'),
('PF', 'FRENCH POLYNESIA', 'French Polynesia', 'PYF', 258, 'n'),
('TF', 'FRENCH SOUTHERN TERRITORIES', 'French Southern Territories', NULL, NULL, 'n'),
('GA', 'GABON', 'Gabon', 'GAB', 266, 'n'),
('GM', 'GAMBIA', 'Gambia', 'GMB', 270, 'n'),
('GE', 'GEORGIA', 'Georgia', 'GEO', 268, 'n'),
('DE', 'GERMANY', 'Germany', 'DEU', 276, 'y'),
('GH', 'GHANA', 'Ghana', 'GHA', 288, 'n'),
('GI', 'GIBRALTAR', 'Gibraltar', 'GIB', 292, 'n'),
('GR', 'GREECE', 'Greece', 'GRC', 300, 'y'),
('GL', 'GREENLAND', 'Greenland', 'GRL', 304, 'n'),
('GD', 'GRENADA', 'Grenada', 'GRD', 308, 'n'),
('GP', 'GUADELOUPE', 'Guadeloupe', 'GLP', 312, 'n'),
('GU', 'GUAM', 'Guam', 'GUM', 316, 'n'),
('GT', 'GUATEMALA', 'Guatemala', 'GTM', 320, 'n'),
('GN', 'GUINEA', 'Guinea', 'GIN', 324, 'n'),
('GW', 'GUINEA-BISSAU', 'Guinea-Bissau', 'GNB', 624, 'n'),
('GY', 'GUYANA', 'Guyana', 'GUY', 328, 'n'),
('HT', 'HAITI', 'Haiti', 'HTI', 332, 'n'),
('HM', 'HEARD ISLAND AND MCDONALD ISLANDS', 'Heard Island and Mcdonald Islands', NULL, NULL, 'n'),
('VA', 'HOLY SEE (VATICAN CITY STATE)', 'Holy See (Vatican City State)', 'VAT', 336, 'n'),
('HN', 'HONDURAS', 'Honduras', 'HND', 340, 'n'),
('HK', 'HONG KONG', 'Hong Kong', 'HKG', 344, 'n'),
('HU', 'HUNGARY', 'Hungary', 'HUN', 348, 'y'),
('IS', 'ICELAND', 'Iceland', 'ISL', 352, 'n'),
('IN', 'INDIA', 'India', 'IND', 356, 'n'),
('ID', 'INDONESIA', 'Indonesia', 'IDN', 360, 'n'),
('IR', 'IRAN, ISLAMIC REPUBLIC OF', 'Iran, Islamic Republic of', 'IRN', 364, 'n'),
('IQ', 'IRAQ', 'Iraq', 'IRQ', 368, 'n'),
('IE', 'IRELAND', 'Ireland', 'IRL', 372, 'y'),
('IL', 'ISRAEL', 'Israel', 'ISR', 376, 'n'),
('IT', 'ITALY', 'Italy', 'ITA', 380, 'y'),
('JM', 'JAMAICA', 'Jamaica', 'JAM', 388, 'n'),
('JP', 'JAPAN', 'Japan', 'JPN', 392, 'n'),
('JO', 'JORDAN', 'Jordan', 'JOR', 400, 'n'),
('KZ', 'KAZAKHSTAN', 'Kazakhstan', 'KAZ', 398, 'n'),
('KE', 'KENYA', 'Kenya', 'KEN', 404, 'n'),
('KI', 'KIRIBATI', 'Kiribati', 'KIR', 296, 'n'),
('KP', 'KOREA, DEMOCRATIC PEOPLE''S REPUBLIC OF', 'Korea, Democratic People''s Republic of', 'PRK', 408, 'n'),
('KR', 'KOREA, REPUBLIC OF', 'Korea, Republic of', 'KOR', 410, 'n'),
('KW', 'KUWAIT', 'Kuwait', 'KWT', 414, 'n'),
('KG', 'KYRGYZSTAN', 'Kyrgyzstan', 'KGZ', 417, 'n'),
('LA', 'LAO PEOPLE''S DEMOCRATIC REPUBLIC', 'Lao People''s Democratic Republic', 'LAO', 418, 'n'),
('LV', 'LATVIA', 'Latvia', 'LVA', 428, 'y'),
('LB', 'LEBANON', 'Lebanon', 'LBN', 422, 'n'),
('LS', 'LESOTHO', 'Lesotho', 'LSO', 426, 'n'),
('LR', 'LIBERIA', 'Liberia', 'LBR', 430, 'n'),
('LY', 'LIBYAN ARAB JAMAHIRIYA', 'Libyan Arab Jamahiriya', 'LBY', 434, 'n'),
('LI', 'LIECHTENSTEIN', 'Liechtenstein', 'LIE', 438, 'n'),
('LT', 'LITHUANIA', 'Lithuania', 'LTU', 440, 'y'),
('LU', 'LUXEMBOURG', 'Luxembourg', 'LUX', 442, 'y'),
('MO', 'MACAO', 'Macao', 'MAC', 446, 'n'),
('MK', 'MACEDONIA, THE FORMER YUGOSLAV REPUBLIC OF', 'Macedonia, the Former Yugoslav Republic of', 'MKD', 807, 'n'),
('MG', 'MADAGASCAR', 'Madagascar', 'MDG', 450, 'n'),
('MW', 'MALAWI', 'Malawi', 'MWI', 454, 'n'),
('MY', 'MALAYSIA', 'Malaysia', 'MYS', 458, 'n'),
('MV', 'MALDIVES', 'Maldives', 'MDV', 462, 'n'),
('ML', 'MALI', 'Mali', 'MLI', 466, 'n'),
('MT', 'MALTA', 'Malta', 'MLT', 470, 'y'),
('MH', 'MARSHALL ISLANDS', 'Marshall Islands', 'MHL', 584, 'n'),
('MQ', 'MARTINIQUE', 'Martinique', 'MTQ', 474, 'n'),
('MR', 'MAURITANIA', 'Mauritania', 'MRT', 478, 'n'),
('MU', 'MAURITIUS', 'Mauritius', 'MUS', 480, 'n'),
('YT', 'MAYOTTE', 'Mayotte', NULL, NULL, 'n'),
('MX', 'MEXICO', 'Mexico', 'MEX', 484, 'n'),
('FM', 'MICRONESIA, FEDERATED STATES OF', 'Micronesia, Federated States of', 'FSM', 583, 'n'),
('MD', 'MOLDOVA, REPUBLIC OF', 'Moldova, Republic of', 'MDA', 498, 'n'),
('MC', 'MONACO', 'Monaco', 'MCO', 492, 'n'),
('MN', 'MONGOLIA', 'Mongolia', 'MNG', 496, 'n'),
('MS', 'MONTSERRAT', 'Montserrat', 'MSR', 500, 'n'),
('MA', 'MOROCCO', 'Morocco', 'MAR', 504, 'n'),
('MZ', 'MOZAMBIQUE', 'Mozambique', 'MOZ', 508, 'n'),
('MM', 'MYANMAR', 'Myanmar', 'MMR', 104, 'n'),
('NA', 'NAMIBIA', 'Namibia', 'NAM', 516, 'n'),
('NR', 'NAURU', 'Nauru', 'NRU', 520, 'n'),
('NP', 'NEPAL', 'Nepal', 'NPL', 524, 'n'),
('NL', 'NETHERLANDS', 'Netherlands', 'NLD', 528, 'y'),
('AN', 'NETHERLANDS ANTILLES', 'Netherlands Antilles', 'ANT', 530, 'n'),
('NC', 'NEW CALEDONIA', 'New Caledonia', 'NCL', 540, 'n'),
('NZ', 'NEW ZEALAND', 'New Zealand', 'NZL', 554, 'n'),
('NI', 'NICARAGUA', 'Nicaragua', 'NIC', 558, 'n'),
('NE', 'NIGER', 'Niger', 'NER', 562, 'n'),
('NG', 'NIGERIA', 'Nigeria', 'NGA', 566, 'n'),
('NU', 'NIUE', 'Niue', 'NIU', 570, 'n'),
('NF', 'NORFOLK ISLAND', 'Norfolk Island', 'NFK', 574, 'n'),
('MP', 'NORTHERN MARIANA ISLANDS', 'Northern Mariana Islands', 'MNP', 580, 'n'),
('NO', 'NORWAY', 'Norway', 'NOR', 578, 'n'),
('OM', 'OMAN', 'Oman', 'OMN', 512, 'n'),
('PK', 'PAKISTAN', 'Pakistan', 'PAK', 586, 'n'),
('PW', 'PALAU', 'Palau', 'PLW', 585, 'n'),
('PS', 'PALESTINIAN TERRITORY, OCCUPIED', 'Palestinian Territory, Occupied', NULL, NULL, 'n'),
('PA', 'PANAMA', 'Panama', 'PAN', 591, 'n'),
('PG', 'PAPUA NEW GUINEA', 'Papua New Guinea', 'PNG', 598, 'n'),
('PY', 'PARAGUAY', 'Paraguay', 'PRY', 600, 'n'),
('PE', 'PERU', 'Peru', 'PER', 604, 'n'),
('PH', 'PHILIPPINES', 'Philippines', 'PHL', 608, 'n'),
('PN', 'PITCAIRN', 'Pitcairn', 'PCN', 612, 'n'),
('PL', 'POLAND', 'Poland', 'POL', 616, 'y'),
('PT', 'PORTUGAL', 'Portugal', 'PRT', 620, 'y'),
('PR', 'PUERTO RICO', 'Puerto Rico', 'PRI', 630, 'n'),
('QA', 'QATAR', 'Qatar', 'QAT', 634, 'n'),
('RE', 'REUNION', 'Reunion', 'REU', 638, 'n'),
('RO', 'ROMANIA', 'Romania', 'ROM', 642, 'y'),
('RU', 'RUSSIAN FEDERATION', 'Russian Federation', 'RUS', 643, 'n'),
('RW', 'RWANDA', 'Rwanda', 'RWA', 646, 'n'),
('SH', 'SAINT HELENA', 'Saint Helena', 'SHN', 654, 'n'),
('KN', 'SAINT KITTS AND NEVIS', 'Saint Kitts and Nevis', 'KNA', 659, 'n'),
('LC', 'SAINT LUCIA', 'Saint Lucia', 'LCA', 662, 'n'),
('PM', 'SAINT PIERRE AND MIQUELON', 'Saint Pierre and Miquelon', 'SPM', 666, 'n'),
('VC', 'SAINT VINCENT AND THE GRENADINES', 'Saint Vincent and the Grenadines', 'VCT', 670, 'n'),
('WS', 'SAMOA', 'Samoa', 'WSM', 882, 'n'),
('SM', 'SAN MARINO', 'San Marino', 'SMR', 674, 'n'),
('ST', 'SAO TOME AND PRINCIPE', 'Sao Tome and Principe', 'STP', 678, 'n'),
('SA', 'SAUDI ARABIA', 'Saudi Arabia', 'SAU', 682, 'n'),
('SN', 'SENEGAL', 'Senegal', 'SEN', 686, 'n'),
('RS', 'SERBIA', 'Serbia', 'SRB', 381, 'n'),
('SC', 'SEYCHELLES', 'Seychelles', 'SYC', 690, 'n'),
('SL', 'SIERRA LEONE', 'Sierra Leone', 'SLE', 694, 'n'),
('SG', 'SINGAPORE', 'Singapore', 'SGP', 702, 'n'),
('SK', 'SLOVAKIA', 'Slovakia', 'SVK', 703, 'y'),
('SI', 'SLOVENIA', 'Slovenia', 'SVN', 705, 'y'),
('SB', 'SOLOMON ISLANDS', 'Solomon Islands', 'SLB', 90, 'n'),
('SO', 'SOMALIA', 'Somalia', 'SOM', 706, 'n'),
('ZA', 'SOUTH AFRICA', 'South Africa', 'ZAF', 710, 'n'),
('GS', 'SOUTH GEORGIA AND THE SOUTH SANDWICH ISLANDS', 'South Georgia and the South Sandwich Islands', NULL, NULL, 'n'),
('ES', 'SPAIN', 'Spain', 'ESP', 724, 'y'),
('LK', 'SRI LANKA', 'Sri Lanka', 'LKA', 144, 'n'),
('SD', 'SUDAN', 'Sudan', 'SDN', 736, 'n'),
('SR', 'SURINAME', 'Suriname', 'SUR', 740, 'n'),
('SJ', 'SVALBARD AND JAN MAYEN', 'Svalbard and Jan Mayen', 'SJM', 744, 'n'),
('SZ', 'SWAZILAND', 'Swaziland', 'SWZ', 748, 'n'),
('SE', 'SWEDEN', 'Sweden', 'SWE', 752, 'y'),
('CH', 'SWITZERLAND', 'Switzerland', 'CHE', 756, 'n'),
('SY', 'SYRIAN ARAB REPUBLIC', 'Syrian Arab Republic', 'SYR', 760, 'n'),
('TW', 'TAIWAN, PROVINCE OF CHINA', 'Taiwan, Province of China', 'TWN', 158, 'n'),
('TJ', 'TAJIKISTAN', 'Tajikistan', 'TJK', 762, 'n'),
('TZ', 'TANZANIA, UNITED REPUBLIC OF', 'Tanzania, United Republic of', 'TZA', 834, 'n'),
('TH', 'THAILAND', 'Thailand', 'THA', 764, 'n'),
('TL', 'TIMOR-LESTE', 'Timor-Leste', NULL, NULL, 'n'),
('TG', 'TOGO', 'Togo', 'TGO', 768, 'n'),
('TK', 'TOKELAU', 'Tokelau', 'TKL', 772, 'n'),
('TO', 'TONGA', 'Tonga', 'TON', 776, 'n'),
('TT', 'TRINIDAD AND TOBAGO', 'Trinidad and Tobago', 'TTO', 780, 'n'),
('TN', 'TUNISIA', 'Tunisia', 'TUN', 788, 'n'),
('TR', 'TURKEY', 'Turkey', 'TUR', 792, 'n'),
('TM', 'TURKMENISTAN', 'Turkmenistan', 'TKM', 795, 'n'),
('TC', 'TURKS AND CAICOS ISLANDS', 'Turks and Caicos Islands', 'TCA', 796, 'n'),
('TV', 'TUVALU', 'Tuvalu', 'TUV', 798, 'n'),
('UG', 'UGANDA', 'Uganda', 'UGA', 800, 'n'),
('UA', 'UKRAINE', 'Ukraine', 'UKR', 804, 'n'),
('AE', 'UNITED ARAB EMIRATES', 'United Arab Emirates', 'ARE', 784, 'n'),
('GB', 'UNITED KINGDOM', 'United Kingdom', 'GBR', 826, 'n'),
('US', 'UNITED STATES', 'United States', 'USA', 840, 'n'),
('UM', 'UNITED STATES MINOR OUTLYING ISLANDS', 'United States Minor Outlying Islands', NULL, NULL, 'n'),
('UY', 'URUGUAY', 'Uruguay', 'URY', 858, 'n'),
('UZ', 'UZBEKISTAN', 'Uzbekistan', 'UZB', 860, 'n'),
('VU', 'VANUATU', 'Vanuatu', 'VUT', 548, 'n'),
('VE', 'VENEZUELA', 'Venezuela', 'VEN', 862, 'n'),
('VN', 'VIET NAM', 'Viet Nam', 'VNM', 704, 'n'),
('VG', 'VIRGIN ISLANDS, BRITISH', 'Virgin Islands, British', 'VGB', 92, 'n'),
('VI', 'VIRGIN ISLANDS, U.S.', 'Virgin Islands, U.s.', 'VIR', 850, 'n'),
('WF', 'WALLIS AND FUTUNA', 'Wallis and Futuna', 'WLF', 876, 'n'),
('EH', 'WESTERN SAHARA', 'Western Sahara', 'ESH', 732, 'n'),
('YE', 'YEMEN', 'Yemen', 'YEM', 887, 'n'),
('ZM', 'ZAMBIA', 'Zambia', 'ZMB', 894, 'n'),
('ZW', 'ZIMBABWE', 'Zimbabwe', 'ZWE', 716, 'n'),
('ME', 'MONTENEGRO', 'Montenegro', 'MNE', 382, 'n');

-- --------------------------------------------------------

--
-- Dumping data for table `dns_template`
--

INSERT INTO `dns_template` (`template_id`, `sys_userid`, `sys_groupid`, `sys_perm_user`, `sys_perm_group`, `sys_perm_other`, `name`, `fields`, `template`, `visible`) VALUES (1, 1, 1, 'riud', 'riud', '', 'Default', 'DOMAIN,IP,NS1,NS2,EMAIL,DKIM,DNSSEC', '[ZONE]\norigin={DOMAIN}.\nns={NS1}.\nmbox={EMAIL}.\nrefresh=7200\nretry=540\nexpire=604800\nminimum=3600\nttl=3600\nxfer=\nalso_notify=\ndnssec_wanted=N\ndnssec_algo=ECDSAP256SHA256\n\n[DNS_RECORDS]\nA|{DOMAIN}.|{IP}|0|3600\nA|www|{IP}|0|3600\nA|mail|{IP}|0|3600\nNS|{DOMAIN}.|{NS1}.|0|3600\nNS|{DOMAIN}.|{NS2}.|0|3600\nMX|{DOMAIN}.|mail.{DOMAIN}.|10|3600\nTXT|{DOMAIN}.|v=spf1 mx a ~all|0|3600', 'y');


-- --------------------------------------------------------

--
-- Dumping data for table `help_faq`
--

INSERT INTO `help_faq` VALUES (1,1,0,'I would like to know ...','Yes, of course.',1,1,'riud','riud','r');

-- --------------------------------------------------------

--
-- Dumping data for table `help_faq_sections`
--

INSERT INTO `help_faq_sections` VALUES (1,'General',0,NULL,NULL,NULL,NULL,NULL);

-- --------------------------------------------------------

--
-- Dumping data for table `spamfilter_policy`
--

INSERT INTO `spamfilter_policy` (`id`, `sys_userid`, `sys_groupid`, `sys_perm_user`, `sys_perm_group`, `sys_perm_other`, `policy_name`, `virus_lover`, `spam_lover`, `banned_files_lover`, `bad_header_lover`, `bypass_virus_checks`, `bypass_spam_checks`, `bypass_banned_checks`, `bypass_header_checks`, `spam_modifies_subj`, `virus_quarantine_to`, `spam_quarantine_to`, `banned_quarantine_to`, `bad_header_quarantine_to`, `clean_quarantine_to`, `other_quarantine_to`, `spam_tag_level`, `spam_tag2_level`, `spam_kill_level`, `spam_dsn_cutoff_level`, `spam_quarantine_cutoff_level`, `addr_extension_virus`, `addr_extension_spam`, `addr_extension_banned`, `addr_extension_bad_header`, `warnvirusrecip`, `warnbannedrecip`, `warnbadhrecip`, `newvirus_admin`, `virus_admin`, `banned_admin`, `bad_header_admin`, `spam_admin`, `spam_subject_tag`, `spam_subject_tag2`, `message_size_limit`, `banned_rulenames`, `rspamd_greylisting`, `rspamd_spam_greylisting_level`, `rspamd_spam_tag_level`, `rspamd_spam_tag_method`, `rspamd_spam_kill_level`) VALUES(1, 1, 0, 'riud', 'riud', 'r', 'Non-paying', 'N', 'N', 'N', 'N', 'Y', 'Y', 'Y', 'N', 'Y', '', '', '', '', '', '', 3, 7, 10, 0, 0, '', '', '', '', 'N', 'N', 'N', '', '', '', '', '', '', '', 0, '', 'n', 6.00, 8.00, 'rewrite_subject', 12.00);
INSERT INTO `spamfilter_policy` (`id`, `sys_userid`, `sys_groupid`, `sys_perm_user`, `sys_perm_group`, `sys_perm_other`, `policy_name`, `virus_lover`, `spam_lover`, `banned_files_lover`, `bad_header_lover`, `bypass_virus_checks`, `bypass_spam_checks`, `bypass_banned_checks`, `bypass_header_checks`, `spam_modifies_subj`, `virus_quarantine_to`, `spam_quarantine_to`, `banned_quarantine_to`, `bad_header_quarantine_to`, `clean_quarantine_to`, `other_quarantine_to`, `spam_tag_level`, `spam_tag2_level`, `spam_kill_level`, `spam_dsn_cutoff_level`, `spam_quarantine_cutoff_level`, `addr_extension_virus`, `addr_extension_spam`, `addr_extension_banned`, `addr_extension_bad_header`, `warnvirusrecip`, `warnbannedrecip`, `warnbadhrecip`, `newvirus_admin`, `virus_admin`, `banned_admin`, `bad_header_admin`, `spam_admin`, `spam_subject_tag`, `spam_subject_tag2`, `message_size_limit`, `banned_rulenames`, `rspamd_greylisting`, `rspamd_spam_greylisting_level`, `rspamd_spam_tag_level`, `rspamd_spam_tag_method`, `rspamd_spam_kill_level`) VALUES(2, 1, 0, 'riud', 'riud', 'r', 'Uncensored', 'Y', 'Y', 'Y', 'Y', 'N', 'N', 'N', 'N', 'N', NULL, NULL, NULL, NULL, NULL, NULL, 3, 999, 999, NULL, NULL, NULL, NULL, NULL, NULL, 'N', 'N', 'N', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 'n', 999.00, 999.00, 'rewrite_subject', 999.00);
INSERT INTO `spamfilter_policy` (`id`, `sys_userid`, `sys_groupid`, `sys_perm_user`, `sys_perm_group`, `sys_perm_other`, `policy_name`, `virus_lover`, `spam_lover`, `banned_files_lover`, `bad_header_lover`, `bypass_virus_checks`, `bypass_spam_checks`, `bypass_banned_checks`, `bypass_header_checks`, `spam_modifies_subj`, `virus_quarantine_to`, `spam_quarantine_to`, `banned_quarantine_to`, `bad_header_quarantine_to`, `clean_quarantine_to`, `other_quarantine_to`, `spam_tag_level`, `spam_tag2_level`, `spam_kill_level`, `spam_dsn_cutoff_level`, `spam_quarantine_cutoff_level`, `addr_extension_virus`, `addr_extension_spam`, `addr_extension_banned`, `addr_extension_bad_header`, `warnvirusrecip`, `warnbannedrecip`, `warnbadhrecip`, `newvirus_admin`, `virus_admin`, `banned_admin`, `bad_header_admin`, `spam_admin`, `spam_subject_tag`, `spam_subject_tag2`, `message_size_limit`, `banned_rulenames`, `rspamd_greylisting`, `rspamd_spam_greylisting_level`, `rspamd_spam_tag_level`, `rspamd_spam_tag_method`, `rspamd_spam_kill_level`) VALUES(3, 1, 0, 'riud', 'riud', 'r', 'Wants all spam', 'N', 'Y', 'N', 'N', 'N', 'N', 'N', 'N', 'Y', NULL, NULL, NULL, NULL, NULL, NULL, 3, 999, 999, NULL, NULL, NULL, NULL, NULL, NULL, 'N', 'N', 'N', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 'n', 999.00, 999.00, 'rewrite_subject', 999.00);
INSERT INTO `spamfilter_policy` (`id`, `sys_userid`, `sys_groupid`, `sys_perm_user`, `sys_perm_group`, `sys_perm_other`, `policy_name`, `virus_lover`, `spam_lover`, `banned_files_lover`, `bad_header_lover`, `bypass_virus_checks`, `bypass_spam_checks`, `bypass_banned_checks`, `bypass_header_checks`, `spam_modifies_subj`, `virus_quarantine_to`, `spam_quarantine_to`, `banned_quarantine_to`, `bad_header_quarantine_to`, `clean_quarantine_to`, `other_quarantine_to`, `spam_tag_level`, `spam_tag2_level`, `spam_kill_level`, `spam_dsn_cutoff_level`, `spam_quarantine_cutoff_level`, `addr_extension_virus`, `addr_extension_spam`, `addr_extension_banned`, `addr_extension_bad_header`, `warnvirusrecip`, `warnbannedrecip`, `warnbadhrecip`, `newvirus_admin`, `virus_admin`, `banned_admin`, `bad_header_admin`, `spam_admin`, `spam_subject_tag`, `spam_subject_tag2`, `message_size_limit`, `banned_rulenames`, `rspamd_greylisting`, `rspamd_spam_greylisting_level`, `rspamd_spam_tag_level`, `rspamd_spam_tag_method`, `rspamd_spam_kill_level`) VALUES(4, 1, 0, 'riud', 'riud', 'r', 'Wants viruses', 'Y', 'N', 'Y', 'Y', 'N', 'N', 'N', 'N', 'Y', NULL, NULL, NULL, NULL, NULL, NULL, 3, 6.9, 6.9, NULL, NULL, NULL, NULL, NULL, NULL, 'N', 'N', 'N', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 'y', 4.00, 6.00, 'rewrite_subject', 10.00);
INSERT INTO `spamfilter_policy` (`id`, `sys_userid`, `sys_groupid`, `sys_perm_user`, `sys_perm_group`, `sys_perm_other`, `policy_name`, `virus_lover`, `spam_lover`, `banned_files_lover`, `bad_header_lover`, `bypass_virus_checks`, `bypass_spam_checks`, `bypass_banned_checks`, `bypass_header_checks`, `spam_modifies_subj`, `virus_quarantine_to`, `spam_quarantine_to`, `banned_quarantine_to`, `bad_header_quarantine_to`, `clean_quarantine_to`, `other_quarantine_to`, `spam_tag_level`, `spam_tag2_level`, `spam_kill_level`, `spam_dsn_cutoff_level`, `spam_quarantine_cutoff_level`, `addr_extension_virus`, `addr_extension_spam`, `addr_extension_banned`, `addr_extension_bad_header`, `warnvirusrecip`, `warnbannedrecip`, `warnbadhrecip`, `newvirus_admin`, `virus_admin`, `banned_admin`, `bad_header_admin`, `spam_admin`, `spam_subject_tag`, `spam_subject_tag2`, `message_size_limit`, `banned_rulenames`, `rspamd_greylisting`, `rspamd_spam_greylisting_level`, `rspamd_spam_tag_level`, `rspamd_spam_tag_method`, `rspamd_spam_kill_level`) VALUES(5, 1, 0, 'riud', 'riud', 'r', 'Normal', 'N', 'N', 'N', 'N', 'N', 'N', 'N', 'N', 'Y', '', '', '', '', '', '', 1, 4.5, 50, 0, 0, NULL, NULL, NULL, NULL, 'N', 'N', 'N', NULL, NULL, NULL, NULL, NULL, '', '***SPAM***', NULL, NULL, 'y', 4.00, 6.00, 'rewrite_subject', 10.00);
INSERT INTO `spamfilter_policy` (`id`, `sys_userid`, `sys_groupid`, `sys_perm_user`, `sys_perm_group`, `sys_perm_other`, `policy_name`, `virus_lover`, `spam_lover`, `banned_files_lover`, `bad_header_lover`, `bypass_virus_checks`, `bypass_spam_checks`, `bypass_banned_checks`, `bypass_header_checks`, `spam_modifies_subj`, `virus_quarantine_to`, `spam_quarantine_to`, `banned_quarantine_to`, `bad_header_quarantine_to`, `clean_quarantine_to`, `other_quarantine_to`, `spam_tag_level`, `spam_tag2_level`, `spam_kill_level`, `spam_dsn_cutoff_level`, `spam_quarantine_cutoff_level`, `addr_extension_virus`, `addr_extension_spam`, `addr_extension_banned`, `addr_extension_bad_header`, `warnvirusrecip`, `warnbannedrecip`, `warnbadhrecip`, `newvirus_admin`, `virus_admin`, `banned_admin`, `bad_header_admin`, `spam_admin`, `spam_subject_tag`, `spam_subject_tag2`, `message_size_limit`, `banned_rulenames`, `rspamd_greylisting`, `rspamd_spam_greylisting_level`, `rspamd_spam_tag_level`, `rspamd_spam_tag_method`, `rspamd_spam_kill_level`) VALUES(6, 1, 0, 'riud', 'riud', 'r', 'Trigger happy', 'N', 'N', 'N', 'N', 'N', 'N', 'N', 'N', 'Y', NULL, NULL, NULL, NULL, NULL, NULL, 3, 5, 5, NULL, NULL, NULL, NULL, NULL, NULL, 'N', 'N', 'N', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 'y', 2.00, 4.00, 'rewrite_subject', 8.00);
INSERT INTO `spamfilter_policy` (`id`, `sys_userid`, `sys_groupid`, `sys_perm_user`, `sys_perm_group`, `sys_perm_other`, `policy_name`, `virus_lover`, `spam_lover`, `banned_files_lover`, `bad_header_lover`, `bypass_virus_checks`, `bypass_spam_checks`, `bypass_banned_checks`, `bypass_header_checks`, `spam_modifies_subj`, `virus_quarantine_to`, `spam_quarantine_to`, `banned_quarantine_to`, `bad_header_quarantine_to`, `clean_quarantine_to`, `other_quarantine_to`, `spam_tag_level`, `spam_tag2_level`, `spam_kill_level`, `spam_dsn_cutoff_level`, `spam_quarantine_cutoff_level`, `addr_extension_virus`, `addr_extension_spam`, `addr_extension_banned`, `addr_extension_bad_header`, `warnvirusrecip`, `warnbannedrecip`, `warnbadhrecip`, `newvirus_admin`, `virus_admin`, `banned_admin`, `bad_header_admin`, `spam_admin`, `spam_subject_tag`, `spam_subject_tag2`, `message_size_limit`, `banned_rulenames`, `rspamd_greylisting`, `rspamd_spam_greylisting_level`, `rspamd_spam_tag_level`, `rspamd_spam_tag_method`, `rspamd_spam_kill_level`) VALUES(7, 1, 0, 'riud', 'riud', 'r', 'Permissive', 'N', 'N', 'N', 'Y', 'N', 'N', 'N', 'N', 'Y', NULL, NULL, NULL, NULL, NULL, NULL, 3, 10, 20, NULL, NULL, NULL, NULL, NULL, NULL, 'N', 'N', 'N', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 'n', 7.00, 10.00, 'rewrite_subject', 20.00);

-- --------------------------------------------------------

--
-- Dumping data for table `sys_group`
--

INSERT INTO `sys_group` (`groupid`, `name`, `description`, `client_id`) VALUES (1, 'admin', 'Administrators group', 0);

-- --------------------------------------------------------

--
-- Dumping data for table `sys_ini`
--

INSERT INTO `sys_ini` (`sysini_id`, `config`, `default_logo`, `custom_logo`) VALUES (1, '', 'data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAABBUAAAD0CAYAAADE1h4zAAAAxnpUWHRSYXcgcHJvZmlsZSB0eXBlIGV4aWYAAHjabVDbDcMwCPxnio5gAyYwjvOSukHHLw6kSqIigeFOHBjYPu8dXsOwMnCbVEykuLGxYfdES1g/Yi18xCjaUY36hsPO2YQOkb8UpUo2nng2/AS7Z+0ipEsS852wHID6EMpBNDZCT9YUshQiDKKmQI9vFTGdrl+Yt3I3DYcR9gVtYG0O7lnz5Ndbm88hxI0qFY9EEgvQcAHqTlSPviwG3KmdSG7iB/l3p9PgC869Wn24OQpqAAABhWlDQ1BJQ0MgcHJvZmlsZQAAeJx9kb1Lw1AUxU9TRdGKiBlEHDJUQbCLijjWKhShQqgVWnUweekXNGlIUlwcBdeCgx+LVQcXZ10dXAVB8APEP0CcFF2kxPuSQotYLzzej/PuObx3HyDUSky3O6KAbjhWMh6T0plVqesVvQhgACLGFWabc7KcQNv6uqdeqrsIz2rf92f1aVmbAQGJOMpMyyHeIJ7ZdEzO+8QiKyga8TnxhEUXJH7kuurzG+e8xwLPFK1Ucp5YJJbyLay2MCtYOvE0cVjTDcoX0j5rnLc466UKa9yTvzCUNVaWuU5rBHEsYgkyJKiooIgSHERoN0ixkaTzWBv/sOeXyaWSqwhGjgWUoUPx/OB/8Hu2dm5q0k8KxYDOF9f9GAW6doF61XW/j123fgIEn4Ero+kv14DZT9KrTS18BPRvAxfXTU3dAy53gKEnU7EUTwrSEnI54P2MvikDDN4CPWv+3BrnOH0AUjSrxA1wcAiM5Sl7vc27u1vn9m9PY34/g3VyrabTP/sAAA5baVRYdFhNTDpjb20uYWRvYmUueG1wAAAAAAA8P3hwYWNrZXQgYmVnaW49Iu+7vyIgaWQ9Ilc1TTBNcENlaGlIenJlU3pOVGN6a2M5ZCI/Pgo8eDp4bXBtZXRhIHhtbG5zOng9ImFkb2JlOm5zOm1ldGEvIiB4OnhtcHRrPSJYTVAgQ29yZSA0LjQuMC1FeGl2MiI+CiA8cmRmOlJERiB4bWxuczpyZGY9Imh0dHA6Ly93d3cudzMub3JnLzE5OTkvMDIvMjItcmRmLXN5bnRheC1ucyMiPgogIDxyZGY6RGVzY3JpcHRpb24gcmRmOmFib3V0PSIiCiAgICB4bWxuczp4bXBNTT0iaHR0cDovL25zLmFkb2JlLmNvbS94YXAvMS4wL21tLyIKICAgIHhtbG5zOnN0RXZ0PSJodHRwOi8vbnMuYWRvYmUuY29tL3hhcC8xLjAvc1R5cGUvUmVzb3VyY2VFdmVudCMiCiAgICB4bWxuczpkYz0iaHR0cDovL3B1cmwub3JnL2RjL2VsZW1lbnRzLzEuMS8iCiAgICB4bWxuczpHSU1QPSJodHRwOi8vd3d3LmdpbXAub3JnL3htcC8iCiAgICB4bWxuczp0aWZmPSJodHRwOi8vbnMuYWRvYmUuY29tL3RpZmYvMS4wLyIKICAgIHhtbG5zOnhtcD0iaHR0cDovL25zLmFkb2JlLmNvbS94YXAvMS4wLyIKICAgeG1wTU06RG9jdW1lbnRJRD0iZ2ltcDpkb2NpZDpnaW1wOmM1YmQwM2Q3LTA0Y2ItNGYyNy1iODZjLThhYzZkNmFlM2IzNiIKICAgeG1wTU06SW5zdGFuY2VJRD0ieG1wLmlpZDoyY2E5MGMzMS1jZjc2LTRlZTQtYTdkMS1hMmJhN2M3ZjcwZGQiCiAgIHhtcE1NOk9yaWdpbmFsRG9jdW1lbnRJRD0ieG1wLmRpZDpmMGVkMTkxNC1mMDAyLTQxNDQtODgyNy1mZTk5OWFmYmQ5NzciCiAgIGRjOkZvcm1hdD0iaW1hZ2UvcG5nIgogICBHSU1QOkFQST0iMi4wIgogICBHSU1QOlBsYXRmb3JtPSJMaW51eCIKICAgR0lNUDpUaW1lU3RhbXA9IjE3OTM1NTM2NjI0NzY0NTciCiAgIEdJTVA6VmVyc2lvbj0iMi4xMC4zNiIKICAgdGlmZjpPcmllbnRhdGlvbj0iMSIKICAgeG1wOkNyZWF0b3JUb29sPSJHSU1QIDIuMTAiCiAgIHhtcDpNZXRhZGF0YURhdGU9IjIwMjY6MTE6MDFUMjA6NTE6MDErMDM6MzAiCiAgIHhtcDpNb2RpZnlEYXRlPSIyMDI2OjExOjAxVDIwOjUxOjAxKzAzOjMwIj4KICAgPHhtcE1NOkhpc3Rvcnk+CiAgICA8cmRmOlNlcT4KICAgICA8cmRmOmxpCiAgICAgIHN0RXZ0OmFjdGlvbj0ic2F2ZWQiCiAgICAgIHN0RXZ0OmNoYW5nZWQ9Ii8iCiAgICAgIHN0RXZ0Omluc3RhbmNlSUQ9InhtcC5paWQ6ZWQ5NTk4NmQtYzY0MC00ZjM5LWJkZDItMDNiMzU3ZjgxNTBjIgogICAgICBzdEV2dDpzb2Z0d2FyZUFnZW50PSJHaW1wIDIuMTAgKExpbnV4KSIKICAgICAgc3RFdnQ6d2hlbj0iMjAyNi0xMS0wMVQyMDo1MDoyMiswMzozMCIvPgogICAgIDxyZGY6bGkKICAgICAgc3RFdnQ6YWN0aW9uPSJzYXZlZCIKICAgICAgc3RFdnQ6Y2hhbmdlZD0iLyIKICAgICAgc3RFdnQ6aW5zdGFuY2VJRD0ieG1wLmlpZDoxZDc3YWZiNC03MTg1LTQ0NzAtYTAwYi0wOWY2YzdjNjJmODciCiAgICAgIHN0RXZ0OnNvZnR3YXJlQWdlbnQ9IkdpbXAgMi4xMCAoTGludXgpIgogICAgICBzdEV2dDp3aGVuPSIyMDI2LTExLTAxVDIwOjUxOjAyKzAzOjMwIi8+CiAgICA8L3JkZjpTZXE+CiAgIDwveG1wTU06SGlzdG9yeT4KICA8L3JkZjpEZXNjcmlwdGlvbj4KIDwvcmRmOlJERj4KPC94OnhtcG1ldGE+CiAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAKICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgIAogICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgCiAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAKICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgIAogICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgCiAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAKICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgIAogICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgCiAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAKICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgIAogICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgCiAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAKICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgIAogICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgCiAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAKICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgIAogICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgCiAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAKICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgIAogICAgICAgICAgICAgICAgICAgICAgICAgICAKPD94cGFja2V0IGVuZD0idyI/PnzbzNEAAAAGYktHRAD+AP4A/usY1IIAAAAJcEhZcwAALiMAAC4jAXilP3YAAAAHdElNRQfqCwERFQJwOIpPAAAgAElEQVR42uzdd5xcdb3/8dfnzOzubLIhjQQSCF06qICiggUXFEUssAXITMhMAEVRLCC9WEAFVAQBFZgJzASyBbn+LNe2luu1FxQQQVQiEEogfZOdLXO+vz9muQbITrK7Z3bnzLyfj8dAIGfPzvl8T/l+P+dbQEREREREREREREREREREREREREREREREREREREREREREREREREREREQAMIUgpAXXk48A0eFPA7ADMANoGv40AnXDn8jwj/nAEDAI9AObhj/rhz+bhv9+CBhyzTGnSIuIiIiIiMiIbVOFoGKTBjacLJgK7AHsBewJ7A7sCuwE7AjMAqYB3kvKc3vK1r3kz3lgLbAaeA5YCTwOrAAeA/4JPA/kXXOsoFISERERERFRUkEmP4HgUexdsBfwKuCVwEHD/72AYm+DyS4rN/xZTTHB8AhwP/AX4AFgrWuO9as0RUREREREaqg9qxBMQtB78vXAzsCRwBuA1wAHUhy+EMYyGaTYi+HPwK+BXwJ/B3o1hEJERERERKSK27cKwQQEuTj/wVzgaOBYiomE/SnOh1CtngX+APwE+DHwqGuO9elsEBERERERqaL2rkJQpsD25BuAA4B3AccDh1GcPLEWOYpDJn4KfAf4hWuOrdZZIiIiIiIiEvK2r0IQYDB78jGKcyK0ACcA+ynGW7UW+DlwD/AD1xx7TiEREREREREJYTtYIRhnAHvyUYo9Ek4BTkKJhNFaR3F4xDLgJ645tkEhERERERERCUmbWCEYY+B68nMoJhEWAa+luudHmCgrKfZeWArcr2UrRUREREREKrxtrBCMIljFCRdfDbwfeB8wW1EpiwLFVSRuBb7lmmPrFRIREREREZEKbCcrBNsRpJ78FOAdwIeBo1CvhIn0JHAHcKtrjv1b4RAREREREamg9rJCUCI4PfkZwELgHIpLQMrk2Qh0A9cbPOA3x5xCIiIiIiIiMsntZoVgK0Hpyc8GzgA+BCxQRCpKP/Bt4BrgD07JBRERERERkclrPysEWwSjJz8TOAv4CDBfEaloA8B3gKs9+FNByQUREREREZGJb0crBGA9+anAYuCTwG6KSKj0UxwW8VnXHHtY4RAREREREZnA9nRNH3xPPgq8B/gUcJBOh1DrpbhaxDWuOfaMwiEiIiIiIjIB7eqaPfCe/BHA54FjAE+nQtV4BrgKuN01x/oUDhERERERkTK2rWvugHvyc4DLgSVAo06BqvVH4HyDn2mlCBERERERkTK1sWvmQHvyEeAU4HNoRYdaMQBkgUs1JEJERERERKQMbe2aOMie/N7Al4ET0FCHWrSS4iScHa45VlA4REREREREAmpvV/XB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', 'data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAABBUAAAD0CAYAAADE1h4zAAAAxnpUWHRSYXcgcHJvZmlsZSB0eXBlIGV4aWYAAHjabVDbDcMwCPxnio5gAyYwjvOSukHHLw6kSqIigeFOHBjYPu8dXsOwMnCbVEykuLGxYfdES1g/Yi18xCjaUY36hsPO2YQOkb8UpUo2nng2/AS7Z+0ipEsS852wHID6EMpBNDZCT9YUshQiDKKmQI9vFTGdrl+Yt3I3DYcR9gVtYG0O7lnz5Ndbm88hxI0qFY9EEgvQcAHqTlSPviwG3KmdSG7iB/l3p9PgC869Wn24OQpqAAABhWlDQ1BJQ0MgcHJvZmlsZQAAeJx9kb1Lw1AUxU9TRdGKiBlEHDJUQbCLijjWKhShQqgVWnUweekXNGlIUlwcBdeCgx+LVQcXZ10dXAVB8APEP0CcFF2kxPuSQotYLzzej/PuObx3HyDUSky3O6KAbjhWMh6T0plVqesVvQhgACLGFWabc7KcQNv6uqdeqrsIz2rf92f1aVmbAQGJOMpMyyHeIJ7ZdEzO+8QiKyga8TnxhEUXJH7kuurzG+e8xwLPFK1Ucp5YJJbyLay2MCtYOvE0cVjTDcoX0j5rnLc466UKa9yTvzCUNVaWuU5rBHEsYgkyJKiooIgSHERoN0ixkaTzWBv/sOeXyaWSqwhGjgWUoUPx/OB/8Hu2dm5q0k8KxYDOF9f9GAW6doF61XW/j123fgIEn4Ero+kv14DZT9KrTS18BPRvAxfXTU3dAy53gKEnU7EUTwrSEnI54P2MvikDDN4CPWv+3BrnOH0AUjSrxA1wcAiM5Sl7vc27u1vn9m9PY34/g3VyrabTP/sAAA5baVRYdFhNTDpjb20uYWRvYmUueG1wAAAAAAA8P3hwYWNrZXQgYmVnaW49Iu+7vyIgaWQ9Ilc1TTBNcENlaGlIenJlU3pOVGN6a2M5ZCI/Pgo8eDp4bXBtZXRhIHhtbG5zOng9ImFkb2JlOm5zOm1ldGEvIiB4OnhtcHRrPSJYTVAgQ29yZSA0LjQuMC1FeGl2MiI+CiA8cmRmOlJERiB4bWxuczpyZGY9Imh0dHA6Ly93d3cudzMub3JnLzE5OTkvMDIvMjItcmRmLXN5bnRheC1ucyMiPgogIDxyZGY6RGVzY3JpcHRpb24gcmRmOmFib3V0PSIiCiAgICB4bWxuczp4bXBNTT0iaHR0cDovL25zLmFkb2JlLmNvbS94YXAvMS4wL21tLyIKICAgIHhtbG5zOnN0RXZ0PSJodHRwOi8vbnMuYWRvYmUuY29tL3hhcC8xLjAvc1R5cGUvUmVzb3VyY2VFdmVudCMiCiAgICB4bWxuczpkYz0iaHR0cDovL3B1cmwub3JnL2RjL2VsZW1lbnRzLzEuMS8iCiAgICB4bWxuczpHSU1QPSJodHRwOi8vd3d3LmdpbXAub3JnL3htcC8iCiAgICB4bWxuczp0aWZmPSJodHRwOi8vbnMuYWRvYmUuY29tL3RpZmYvMS4wLyIKICAgIHhtbG5zOnhtcD0iaHR0cDovL25zLmFkb2JlLmNvbS94YXAvMS4wLyIKICAgeG1wTU06RG9jdW1lbnRJRD0iZ2ltcDpkb2NpZDpnaW1wOmM1YmQwM2Q3LTA0Y2ItNGYyNy1iODZjLThhYzZkNmFlM2IzNiIKICAgeG1wTU06SW5zdGFuY2VJRD0ieG1wLmlpZDoyY2E5MGMzMS1jZjc2LTRlZTQtYTdkMS1hMmJhN2M3ZjcwZGQiCiAgIHhtcE1NOk9yaWdpbmFsRG9jdW1lbnRJRD0ieG1wLmRpZDpmMGVkMTkxNC1mMDAyLTQxNDQtODgyNy1mZTk5OWFmYmQ5NzciCiAgIGRjOkZvcm1hdD0iaW1hZ2UvcG5nIgogICBHSU1QOkFQST0iMi4wIgogICBHSU1QOlBsYXRmb3JtPSJMaW51eCIKICAgR0lNUDpUaW1lU3RhbXA9IjE3OTM1NTM2NjI0NzY0NTciCiAgIEdJTVA6VmVyc2lvbj0iMi4xMC4zNiIKICAgdGlmZjpPcmllbnRhdGlvbj0iMSIKICAgeG1wOkNyZWF0b3JUb29sPSJHSU1QIDIuMTAiCiAgIHhtcDpNZXRhZGF0YURhdGU9IjIwMjY6MTE6MDFUMjA6NTE6MDErMDM6MzAiCiAgIHhtcDpNb2RpZnlEYXRlPSIyMDI2OjExOjAxVDIwOjUxOjAxKzAzOjMwIj4KICAgPHhtcE1NOkhpc3Rvcnk+CiAgICA8cmRmOlNlcT4KICAgICA8cmRmOmxpCiAgICAgIHN0RXZ0OmFjdGlvbj0ic2F2ZWQiCiAgICAgIHN0RXZ0OmNoYW5nZWQ9Ii8iCiAgICAgIHN0RXZ0Omluc3RhbmNlSUQ9InhtcC5paWQ6ZWQ5NTk4NmQtYzY0MC00ZjM5LWJkZDItMDNiMzU3ZjgxNTBjIgogICAgICBzdEV2dDpzb2Z0d2FyZUFnZW50PSJHaW1wIDIuMTAgKExpbnV4KSIKICAgICAgc3RFdnQ6d2hlbj0iMjAyNi0xMS0wMVQyMDo1MDoyMiswMzozMCIvPgogICAgIDxyZGY6bGkKICAgICAgc3RFdnQ6YWN0aW9uPSJzYXZlZCIKICAgICAgc3RFdnQ6Y2hhbmdlZD0iLyIKICAgICAgc3RFdnQ6aW5zdGFuY2VJRD0ieG1wLmlpZDoxZDc3YWZiNC03MTg1LTQ0NzAtYTAwYi0wOWY2YzdjNjJmODciCiAgICAgIHN0RXZ0OnNvZnR3YXJlQWdlbnQ9IkdpbXAgMi4xMCAoTGludXgpIgogICAgICBzdEV2dDp3aGVuPSIyMDI2LTExLTAxVDIwOjUxOjAyKzAzOjMwIi8+CiAgICA8L3JkZjpTZXE+CiAgIDwveG1wTU06SGlzdG9yeT4KICA8L3JkZjpEZXNjcmlwdGlvbj4KIDwvcmRmOlJERj4KPC94OnhtcG1ldGE+CiAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAKICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgIAogICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgCiAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAKICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgIAogICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgCiAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAKICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgIAogICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgCiAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAKICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgIAogICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgCiAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAKICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgIAogICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgCiAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAKICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgIAogICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgCiAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAKICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgIAogICAgICAgICAgICAgICAgICAgICAgICAgICAKPD94cGFja2V0IGVuZD0idyI/PnzbzNEAAAAGYktHRAD+AP4A/usY1IIAAAAJcEhZcwAALiMAAC4jAXilP3YAAAAHdElNRQfqCwERFQJwOIpPAAAgAElEQVR42uzdd5xcdb3/8dfnzOzubLIhjQQSCF06qICiggUXFEUssAXITMhMAEVRLCC9WEAFVAQBFZgJzASyBbn+LNe2luu1FxQQQVQiEEogfZOdLXO+vz9muQbITrK7Z3bnzLyfj8dAIGfPzvl8T/l+P+dbQEREREREREREREREREREREREREREREREREREREREREREREREREREREQAMIUgpAXXk48A0eFPA7ADMANoGv40AnXDn8jwj/nAEDAI9AObhj/rhz+bhv9+CBhyzTGnSIuIiIiIiMiIbVOFoGKTBjacLJgK7AHsBewJ7A7sCuwE7AjMAqYB3kvKc3vK1r3kz3lgLbAaeA5YCTwOrAAeA/4JPA/kXXOsoFISERERERFRUkEmP4HgUexdsBfwKuCVwEHD/72AYm+DyS4rN/xZTTHB8AhwP/AX4AFgrWuO9as0RUREREREaqg9qxBMQtB78vXAzsCRwBuA1wAHUhy+EMYyGaTYi+HPwK+BXwJ/B3o1hEJERERERKSK27cKwQQEuTj/wVzgaOBYiomE/SnOh1CtngX+APwE+DHwqGuO9elsEBERERERqaL2rkJQpsD25BuAA4B3AccDh1GcPLEWOYpDJn4KfAf4hWuOrdZZIiIiIiIiEvK2r0IQYDB78jGKcyK0ACcA+ynGW7UW+DlwD/AD1xx7TiEREREREREJYTtYIRhnAHvyUYo9Ek4BTkKJhNFaR3F4xDLgJ645tkEhERERERERCUmbWCEYY+B68nMoJhEWAa+luudHmCgrKfZeWArcr2UrRUREREREKrxtrBCMIljFCRdfDbwfeB8wW1EpiwLFVSRuBb7lmmPrFRIREREREZEKbCcrBNsRpJ78FOAdwIeBo1CvhIn0JHAHcKtrjv1b4RAREREREamg9rJCUCI4PfkZwELgHIpLQMrk2Qh0A9cbPOA3x5xCIiIiIiIiMsntZoVgK0Hpyc8GzgA+BCxQRCpKP/Bt4BrgD07JBRERERERkclrPysEWwSjJz8TOAv4CDBfEaloA8B3gKs9+FNByQUREREREZGJb0crBGA9+anAYuCTwG6KSKj0UxwW8VnXHHtY4RAREREREZnA9nRNH3xPPgq8B/gUcJBOh1DrpbhaxDWuOfaMwiEiIiIiIjIB7eqaPfCe/BHA54FjAE+nQtV4BrgKuN01x/oUDhERERERkTK2rWvugHvyc4DLgSVAo06BqvVH4HyDn2mlCBERERERkTK1sWvmQHvyEeAU4HNoRYdaMQBkgUs1JEJERERERKQMbe2aOMie/N7Al4ET0FCHWrSS4iScHa45VlA4REREREREAmpvV/XB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');

-- --------------------------------------------------------

--
-- Dumping data for table `sys_user`
--

####################  Algo4Stock  ####################
### [ 1405-08-17 ⏰ 10:05 ]
### [Developer: Danial Rikhteh Garan]
INSERT INTO `sys_theme` (`var_id`, `tpl_name`, `username`, `logo_url`) VALUES (NULL, 'algopanel', 'global', 'themes/algopanel/assets/images/logo.png');
#--------------------  AlgoEnd  ---------------------#
INSERT INTO `sys_theme` (`var_id`, `tpl_name`, `username`, `logo_url`) VALUES (NULL, 'default', 'global', 'themes/default/images/header_logo.png');
INSERT INTO `sys_theme` (`var_id`, `tpl_name`, `username`, `logo_url`) VALUES (NULL, 'default-v2', 'global', 'themes/default-v2/images/header_logo.png');

-- --------------------------------------------------------

--
-- Dumping data for table `sys_user`
--

####################  Algo4Stock  ####################
### [ 1405-08-17 ⏰ 10:05 ]
### [Developer: Danial Rikhteh Garan]
INSERT INTO `sys_user` (`userid`, `sys_userid`, `sys_groupid`, `sys_perm_user`, `sys_perm_group`, `sys_perm_other`, `username`, `passwort`, `modules`, `startmodule`, `app_theme`, `typ`, `active`, `language`, `groups`, `default_group`, `client_id`) VALUES (1, 1, 0, 'riud', 'riud', '', 'admin', 'xxx', 'dashboard,admin,client,mail,monitor,sites,dns,vm,tools,help', 'dashboard', 'algopanel', 'admin', 1, 'en', '1,2', 1, 0);
#--------------------  AlgoEnd  ---------------------#

-- --------------------------------------------------------

--
-- Dumping data for table `sys_config`
--

INSERT INTO sys_config VALUES ('db','db_version','3.3dev');
INSERT INTO sys_config VALUES ('interface','session_timeout','0');

SET FOREIGN_KEY_CHECKS = 1;
