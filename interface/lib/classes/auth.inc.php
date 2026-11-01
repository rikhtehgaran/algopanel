<?php

/*
Copyright (c) 2007, Till Brehm, projektfarm Gmbh
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

class auth {
	var $client_limits = null;

	public function get_user_id()
	{
		global $app;
		return $app->functions->intval($_SESSION['s']['user']['userid']);
	}

	public function is_admin() {
		if($_SESSION['s']['user']['typ'] == 'admin') {
			return true;
		} else {
			return false;
		}
	}

	public function is_superadmin() {
		if($_SESSION['s']['user']['typ'] == 'admin' && $_SESSION['s']['user']['userid'] == 1) {
			return true;
		} else {
			return false;
		}
	}

	public function is_reseller() {
		if($this->has_clients($_SESSION['s']['user']['userid'])) {
			return true;
		} else {
			return false;
		}
	}
	public function has_clients($userid) {
		global $app, $conf;

		$userid = $app->functions->intval($userid);
		$client = $app->db->queryOneRecord("SELECT client.limit_client FROM sys_user, client WHERE sys_user.userid = ? AND sys_user.client_id = client.client_id", $userid);
		if(is_array($client) && $client['limit_client'] != 0) {
			return true;
		} else {
			return false;
		}
	}

	// Function to check if a client belongs to a reseller
	public function is_client_of_reseller($userid = 0) {
		global $app, $conf;

		if($userid == 0) $userid = $_SESSION['s']['user']['userid'];

		$client = $app->db->queryOneRecord("SELECT client.sys_userid, client.sys_groupid FROM sys_user, client WHERE sys_user.userid = ? AND sys_user.client_id = client.client_id", $userid);
		if($client['sys_userid'] > 1 || $client['sys_groupid'] > 1) {
			return true;
		} else {
			return false;
		}
	}

	/**
	 * Check if the logged in user is allowed to assign a record to the given client group.
	 *
	 * Admins may use every client group, resellers may use their own group and the groups of
	 * their sub clients. Every other user may only use his own group.
	 *
	 * @param int $group_id id of the client group
	 * @return bool true if the group may be used by the logged in user
	 */
	public function is_allowed_client_group_id($group_id) {
		global $app;

		$group_id = $app->functions->intval($group_id);
		if($group_id < 1) return false;

		if($_SESSION['s']['user']['typ'] == 'admin') {
			$group = $app->db->queryOneRecord("SELECT groupid FROM sys_group WHERE groupid = ? AND client_id > 0", $group_id);
			return is_array($group);
		}

		//* A user without sub clients may only use his own group.
		if(!$this->has_clients($_SESSION['s']['user']['userid'])) {
			return ($group_id === $app->functions->intval($_SESSION['s']['user']['default_group']));
		}

		$reseller = $app->db->queryOneRecord("SELECT client_id FROM sys_group WHERE groupid = ?", $app->functions->intval($_SESSION['s']['user']['default_group']));
		if(!is_array($reseller) || $reseller['client_id'] < 1) return false;

		//* A reseller may keep a record for himself or hand it over to one of his sub clients.
		$group = $app->db->queryOneRecord("SELECT sys_group.groupid FROM sys_group, client WHERE sys_group.client_id = client.client_id AND sys_group.groupid = ? AND ? IN (client.client_id, client.parent_client_id)", $group_id, $reseller['client_id']);

		return is_array($group);
	}

	/**
	 * Get the client group that shall be preselected in the client select field of a form.
	 *
	 * The fields client_group_id and sys_groupid are not part of any form definition, so they
	 * are not contained in the dataRecord when a form is redisplayed after a validation error.
	 * Without a fallback no option of the select field is marked as selected and the browser
	 * preselects the first one, which silently changes the owner of the record when the form
	 * is saved again.
	 *
	 * @param array $data_record dataRecord of the form
	 * @param array $group_ids client group ids that the select field offers
	 * @param string $db_table table that stores the record
	 * @param string $db_index name of the index column of that table
	 * @param int $record_id id of the record, 0 for new records
	 * @return int client group id to preselect, 0 if the owner could not be determined
	 */
	public function get_selected_client_group_id($data_record, $group_ids, $db_table = '', $db_index = '', $record_id = 0) {
		global $app;

		$offered_group_ids = array();
		if(is_array($group_ids)) {
			foreach($group_ids as $group_id) $offered_group_ids[] = $app->functions->intval($group_id);
		}

		//* A client that has been chosen in the form has precedence, so that the choice is kept
		//* when the form is redisplayed after a validation error. client_group_id is not part of
		//* the form definition, so it has to be taken from the request in that case.
		$selected_group_id = 0;
		if(is_array($data_record) && isset($data_record['client_group_id'])) {
			$selected_group_id = $app->functions->intval($data_record['client_group_id']);
		} elseif(isset($_POST['client_group_id'])) {
			$selected_group_id = $app->functions->intval($_POST['client_group_id']);
		}
		if($selected_group_id > 0 && in_array($selected_group_id, $offered_group_ids, true)) return $selected_group_id;

		//* Otherwise fall back to the current owner of the record.
		if(is_array($data_record) && isset($data_record['sys_groupid']) && $app->functions->intval($data_record['sys_groupid']) > 0) {
			return $app->functions->intval($data_record['sys_groupid']);
		}

		$record_id = $app->functions->intval($record_id);
		if($record_id > 0 && $db_table != '' && $db_index != '') {
			$tmp = $app->db->queryOneRecord("SELECT sys_groupid FROM ?? WHERE ?? = ?", $db_table, $db_index, $record_id);
			if(is_array($tmp)) return $app->functions->intval($tmp['sys_groupid']);
		}

		return 0;
	}

	//** This function adds a given group id to a given user.
	public function add_group_to_user($userid, $groupid) {
		global $app;

		$userid = $app->functions->intval($userid);
		$groupid = $app->functions->intval($groupid);

		if($userid > 0 && $groupid > 0) {
			$user = $app->db->queryOneRecord("SELECT * FROM sys_user WHERE userid = ?", $userid);
			$groups = explode(',', $user['groups']);
			if(!in_array($groupid, $groups)) $groups[] = $groupid;
			$groups_string = implode(',', $groups);
			$sql = "UPDATE sys_user SET `groups` = ? WHERE userid = ?";
			$app->db->query($sql, $groups_string, $userid);
			return true;
		} else {
			return false;
		}
	}

	//** This function returns given client limit as integer, -1 means no limit
	public function get_client_limit($userid, $limitname)
	{
		global $app;

		$userid = $app->functions->intval($userid);
		if(!preg_match('/^[a-zA-Z0-9\-\_]{1,64}$/',$limitname)) $app->error('Invalid limit name '.$limitname);

		// simple query cache
		if($this->client_limits===null)
			$this->client_limits = $app->db->queryOneRecord("SELECT client.* FROM sys_user, client WHERE sys_user.userid = ? AND sys_user.client_id = client.client_id", $userid);

		// isn't client -> no limit
		if(!$this->client_limits)
			return -1;

		if(isset($this->client_limits['limit_'.$limitname])) {
			return $this->client_limits['limit_'.$limitname];
		}
	}

	//** This function removes a given group id from a given user.
	public function remove_group_from_user($userid, $groupid) {
		global $app;

		$userid = $app->functions->intval($userid);
		$groupid = $app->functions->intval($groupid);

		if($userid > 0 && $groupid > 0) {
			$user = $app->db->queryOneRecord("SELECT * FROM sys_user WHERE userid = ?", $userid);
			$groups = explode(',', $user['groups']);
			$key = array_search($groupid, $groups);
			unset($groups[$key]);
			$groups_string = implode(',', $groups);
			$sql = "UPDATE sys_user SET `groups` = ? WHERE userid = ?";
			$app->db->query($sql, $groups_string, $userid);
			return true;
		} else {
			return false;
		}
	}


       /**
        * Check that the user has access to the given module.
        *
        * @return boolean
        */
       public function verify_module_permissions($module)  {
		// Check if the current user has the permissions to access this module
		$module = trim(preg_replace('@\s+@', '', $module));
		$user_modules = explode(',',$_SESSION["s"]["user"]["modules"]);
               $can_use_module = false;
		if(strpos($module, ',') !== false){
			$tmp_modules = explode(',', $module);
			if(is_array($tmp_modules) && !empty($tmp_modules)){
				foreach($tmp_modules as $tmp_module){
					if($tmp_module != ''){
						if(in_array($tmp_module,$user_modules)) {
							$can_use_module = true;
							break;
						}
					}
				}
			}
               }
               elseif(in_array($module,$user_modules)) {
                       $can_use_module = true;
               }
               return $can_use_module;
       }

       /**
        * Check that the user has access to the given module, redirect and exit on failure.
        */
       public function check_module_permissions($module)  {
               if(!$this->verify_module_permissions($module)) {
                       // echo "LOGIN_REDIRECT:/index.php";
                       header("Location: /index.php");
                       exit;
		}
	}

	public function check_security_permissions($permission) {

		global $app;

		$app->uses('getconf');
		$security_config = $app->getconf->get_security_config('permissions');

		$security_check = false;
		if($security_config[$permission] == 'yes') $security_check = true;
		if($security_config[$permission] == 'superadmin' && $app->auth->is_superadmin()) $security_check = true;
		if($security_check !== true) {
			$app->error($app->lng('security_check1_txt').' '.$permission.' '.$app->lng('security_check2_txt'));
		}

	}

	/**
	 * Get the minimum password length.
	 */
	public function get_min_password_length() {
		global $app;
		$server_config_array = $app->getconf->get_global_config();
		$min_password_length = 8;
		if(isset($server_config_array['misc']['min_password_length'])) $min_password_length = $server_config_array['misc']['min_password_length'];
		return $min_password_length;
	}

	/**
	 * Get the minimum password strength.
	 */
	public function get_min_password_strength() {
		global $app;
		$server_config_array = $app->getconf->get_global_config();
		$min_password_strength = 0;
		if(isset($server_config_array['misc']['min_password_strength'])) $min_password_strength = $server_config_array['misc']['min_password_strength'];
		return $min_password_strength;
	}

	/**
	 * Generate a ranmdom password.
	 *
	 * @param int $minLength
	 *   Minimum number of characters.
	 * @param boolean $special
	 *   Include special characters, like # and !
	 */
	public function get_random_password($minLength = 8, $special = false) {
		if($minLength < 8) $minLength = 8;
		$maxLength = $minLength + 5;
		$length = random_int($minLength, $maxLength);

		$alphachars = "abcdefghijklmnopqrstuvwxyz";
		$upperchars = "ABCDEFGHIJKLMNOPQRSTUVWXYZ";
		$numchars = "1234567890";
		$specialchars = "!@#_";

		$num_special = 0;
		if($special == true) {
			$num_special = intval(random_int(0, round($length / 4))) + 1;
		}
		$numericlen = random_int(1, 2);
		$alphalen = $length - $num_special - $numericlen;
		$upperlen = intval($alphalen / 2);
		$alphalen = $alphalen - $upperlen;
		$password = '';

		for($i = 0; $i < $alphalen; $i++) {
			$password .= substr($alphachars, random_int(0, strlen($alphachars) - 1), 1);
		}

		for($i = 0; $i < $upperlen; $i++) {
			$password .= substr($upperchars, random_int(0, strlen($upperchars) - 1), 1);
		}

		for($i = 0; $i < $num_special; $i++) {
			$password .= substr($specialchars, random_int(0, strlen($specialchars) - 1), 1);
		}

		for($i = 0; $i < $numericlen; $i++) {
			$password .= substr($numchars, random_int(0, strlen($numchars) - 1), 1);
		}

		return str_shuffle($password);
	}

	public function crypt_password($cleartext_password, $charset = 'UTF-8') {
		if($charset != 'UTF-8') {
			$cleartext_password = mb_convert_encoding($cleartext_password, $charset, 'UTF-8');
		}

		if(defined('CRYPT_SHA512') && CRYPT_SHA512 == 1) {
			$salt = '$6$rounds=5000$';
			$salt_length = 16;
		} elseif(defined('CRYPT_SHA256') && CRYPT_SHA256 == 1) {
			$salt = '$5$rounds=5000$';
			$salt_length = 16;
		} else {
			$salt = '$1$';
			$salt_length = 12;
		}

		if(function_exists('openssl_random_pseudo_bytes')) {
			$salt .= substr(bin2hex(openssl_random_pseudo_bytes($salt_length)), 0, $salt_length);
		} else {
			$base64_alphabet = 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789./';
			for($n = 0; $n < $salt_length; $n++) {
				$salt .= $base64_alphabet[mt_rand(0, 63)];
			}
		}
		$salt .= "$";
		return crypt($cleartext_password, $salt);
	}

	public function csrf_token_get($form_name) {
		/* CSRF PROTECTION */
		// generate csrf protection id and key
		$_csrf_id = $form_name . '_' . bin2hex(random_bytes(12)); // form id
		$_csrf_key = sha1(random_bytes(20)); // the key
		if(!isset($_SESSION['_csrf'])) $_SESSION['_csrf'] = array();
		if(!isset($_SESSION['_csrf_timeout'])) $_SESSION['_csrf_timeout'] = array();
		$_SESSION['_csrf'][$_csrf_id] = $_csrf_key;
		$_SESSION['_csrf_timeout'][$_csrf_id] = time() + 3600; // timeout hash in 1 hour

		return array('csrf_id' => $_csrf_id,'csrf_key' => $_csrf_key);
	}

	public function csrf_token_check($method = 'POST') {
		global $app;

		if($method == 'POST') {
			$input_vars = $_POST;
		} elseif ($method == 'GET') {
			$input_vars = $_GET;
		} else {
			$app->error('Unknown CSRF verification method.');
		}

		//print_r($input_vars);
		//die(print_r($_SESSION['_csrf']));

		if(isset($input_vars) && is_array($input_vars)) {
			$_csrf_valid = false;
			if(isset($input_vars['_csrf_id']) && isset($input_vars['_csrf_key'])) {
				$_csrf_id = trim($input_vars['_csrf_id']);
				$_csrf_key = trim($input_vars['_csrf_key']);
				if(isset($_SESSION['_csrf']) && isset($_SESSION['_csrf'][$_csrf_id]) && isset($_SESSION['_csrf_timeout']) && isset($_SESSION['_csrf_timeout'][$_csrf_id])) {
					if(hash_equals($_SESSION['_csrf'][$_csrf_id], $_csrf_key) && $_SESSION['_csrf_timeout'][$_csrf_id] >= time()) $_csrf_valid = true;
				}
			}
			if($_csrf_valid !== true) {
				$app->log('CSRF attempt blocked. Referer: ' . (isset($_SERVER['HTTP_REFERER']) ? $_SERVER['HTTP_REFERER'] : 'unknown'), LOGLEVEL_WARN);
				$app->error($app->lng('err_csrf_attempt_blocked'));
			}
			$_SESSION['_csrf'][$_csrf_id] = null;
			$_SESSION['_csrf_timeout'][$_csrf_id] = null;
			unset($_SESSION['_csrf'][$_csrf_id]);
			unset($_SESSION['_csrf_timeout'][$_csrf_id]);

			if(isset($_SESSION['_csrf_timeout']) && is_array($_SESSION['_csrf_timeout'])) {
				$to_unset = array();
				foreach($_SESSION['_csrf_timeout'] as $_csrf_id => $timeout) {
					if($timeout < time()) $to_unset[] = $_csrf_id;
				}
				foreach($to_unset as $_csrf_id) {
					$_SESSION['_csrf'][$_csrf_id] = null;
					$_SESSION['_csrf_timeout'][$_csrf_id] = null;
					unset($_SESSION['_csrf'][$_csrf_id]);
					unset($_SESSION['_csrf_timeout'][$_csrf_id]);
				}
				unset($to_unset);
			}
		}
	}

}

?>
