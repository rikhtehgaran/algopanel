<?php

if(!defined('INSTALLER_RUN')) die('Patch update file access violation.');

// Update system config to add new field server_sender_mail.

// Gets the current admin_mail value to preserve current behaviour.
// https://git.ispconfig.org/ispconfig/ispconfig3/-/work_items/7028

class upd_0104 extends installer_patch_update {

	public function onAfterSQL() {
		global $inst;

		$tmp = $inst->db->queryOneRecord('SELECT config FROM sys_ini WHERE sysini_id = 1');
		if($tmp && isset($tmp['config']) && $tmp['config'] !== '') {
			$global_config = ini_to_array(stripslashes($tmp['config']));
			if(isset($global_config['mail']) && !empty($global_config['mail']['admin_mail']) && (!isset($global_config['mail']['server_sender_mail']) || $global_config['mail']['server_sender_mail'] === '')) {
				$global_config['mail']['server_sender_mail'] = $global_config['mail']['admin_mail'];
				$server_config_str = array_to_ini($global_config);
				$inst->db->query('UPDATE sys_ini SET config = ? WHERE sysini_id = 1', $server_config_str);
				ilog('Migrated sys_ini mail.server_sender_mail from admin_mail');
			}
		}
	}
}
