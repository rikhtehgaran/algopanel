<?php
/*
Copyright (c) 2026, Yasunori Matsuki (Dazoo Network)
All rights reserved.
*/

class pureftpd_sni_plugin {

	var $plugin_name = 'pureftpd_sni_plugin';
	var $class_name = 'pureftpd_sni_plugin';

	/**
	 * This function is called when the plugin is loaded
	 */
	function onLoad() {
		global $app;

		$app->plugins->registerEvent('web_domain_insert', $this->plugin_name, 'ssl');
		$app->plugins->registerEvent('web_domain_update', $this->plugin_name, 'ssl');
	}

	/**
	 * This function is called during ispconfig installation to determine
	 * if a symlink shall be created for this plugin.
	 */
	function onInstall() {
		global $conf;

		if($conf['services']['web'] == true) {
			return true;
		} else {
			return false;
		}
	}

	/**
	 * Main logic executed on SSL update
	 */
	function ssl($event_name, $data) {
		global $app, $conf;

		if(!isset($data['new']['ssl']) || $data['new']['ssl'] != 'y' || empty($data['new']['domain'])) {
			return;
		}

		$domain = $data['new']['domain'];
		$ssl_dir = $data['new']['document_root'].'/ssl';
		$key_file = $ssl_dir.'/'.$domain.'.key';
		$crt_file = $ssl_dir.'/'.$domain.'.crt';
		$pem_file = '/etc/ssl/private/'.$domain.'.pem';

		if(@file_exists($key_file) && @file_exists($crt_file)) {
			$content = file_get_contents($crt_file) . "\n" . file_get_contents($key_file);
			
			if(!empty($content)) {
				file_put_contents($pem_file, $content);
				chmod($pem_file, 0600);
				chown($pem_file, 'root');
				chgrp($pem_file, 'root');
				
				$app->services->restartService('pure-ftpd-mysql', 'restart');
				$app->log("Pure-FTPd SNI PEM created and service restart queued for $domain", LOGLEVEL_DEBUG);
			}
		}
	}
}
?>
