<?php
/*
Copyright (c) 2005, Till Brehm, projektfarm Gmbh
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


/******************************************
* Begin Form configuration
******************************************/

$tform_def_file = "form/mail_domain_catchall.tform.php";

/******************************************
* End Form configuration
******************************************/

require_once '../../lib/config.inc.php';
require_once '../../lib/app.inc.php';

//* Check permissions for module
$app->auth->check_module_permissions('mail');

// Loading classes
$app->uses('tpl,tform,tform_actions');
$app->load('tform_actions');

class page_action extends tform_actions {

	function onShowNew() {
		global $app, $conf;

		// we will check only users, not admins
		if($_SESSION["s"]["user"]["typ"] == 'user') {
			if(!$app->tform->checkClientLimit('limit_mailcatchall', "type = 'catchall'")) {
				$app->error($app->tform->wordbook["limit_mailcatchall_txt"]);
			}
			if(!$app->tform->checkResellerLimit('limit_mailcatchall', "type = 'catchall'")) {
				$app->error('Reseller: '.$app->tform->wordbook["limit_mailcatchall_txt"]);
			}
		}

		parent::onShowNew();
	}

	function onShowEnd() {
		global $app, $conf;

		$email = $this->dataRecord["source"];
		$email_parts = explode("@", $email);
		$app->tpl->setVar("email_local_part", $email_parts[0], true);
		$email_parts[1] = $app->functions->idn_decode($email_parts[1]);

		// Getting Domains of the user
		$sql = "SELECT domain_id, domain, server_id, (SELECT server_name FROM server WHERE server.server_id = mail_domain.server_id) AS server_name FROM mail_domain WHERE ".$app->tform->getAuthSQL('r')." ORDER BY domain, server_id";
		$domains = $app->db->queryAllRecords($sql);
		$domain_servers = array();
		$domain_select = "<option value=''></option>";
		if(is_array($domains)) {
			// Prefer the domain on the server of the record, fall back to the first domain with a matching name
			$name_match_id = 0;
			$server_match_id = 0;
			foreach( $domains as $domain) {
				$domain_servers[$domain['domain']][$domain['server_id']] = true;
				if(isset($email_parts[1]) && $app->functions->idn_decode($domain['domain']) == $email_parts[1]) {
					if($name_match_id == 0) $name_match_id = $domain['domain_id'];
					if($server_match_id == 0 && $domain['server_id'] == @$this->dataRecord["server_id"]) $server_match_id = $domain['domain_id'];
				}
			}
			$selected_domain_id = ($server_match_id > 0 ? $server_match_id : $name_match_id);
			foreach( $domains as $domain) {
				$domain_ascii = $domain['domain'];
				$domain['domain'] = $app->functions->idn_decode($domain['domain']);
				$selected = ($domain['domain_id'] == $selected_domain_id)?'SELECTED':'';
				$server_name = (count($domain_servers[$domain_ascii]) > 1 ? ' (' . $app->functions->htmlentities($domain['server_name']) . ')' : '');
				$domain_select .= "<option value='" . $app->functions->intval($domain['domain_id']) . "' $selected>" . $app->functions->htmlentities($domain['domain']) . $server_name . "</option>\r\n";
			}
		}
		$app->tpl->setVar("email_domain", $domain_select);

		parent::onShowEnd();
	}

	function onSubmit() {
		global $app, $conf;

		// Check if Domain belongs to user
		$domain = $app->db->queryOneRecord("SELECT server_id, domain FROM mail_domain WHERE domain_id = ? AND ".$app->tform->getAuthSQL('r'), $app->functions->intval($_POST["email_domain"]));
		if(empty($domain["domain"])) $app->tform->errorMessage .= $app->tform->wordbook["no_domain_perm"];

		// Check the client limits, if user is not the admin
		if($_SESSION["s"]["user"]["typ"] != 'admin') { // if user is not admin
			// Get the limits of the client
			$client_group_id = $app->functions->intval($_SESSION["s"]["user"]["default_group"]);
			$client = $app->db->queryOneRecord("SELECT limit_mailcatchall FROM sys_group, client WHERE sys_group.client_id = client.client_id and sys_group.groupid = ?", $client_group_id);

			// Check if the user may add another catchall
			if($this->id == 0 && $client["limit_mailcatchall"] >= 0) {
				$tmp = $app->db->queryOneRecord("SELECT count(forwarding_id) as number FROM mail_forwarding WHERE sys_groupid = ? AND type = 'catchall'", $client_group_id);
				if($tmp["number"] >= $client["limit_mailcatchall"]) {
					$app->tform->errorMessage .= $app->tform->wordbook["limit_mailcatchall_txt"]."<br>";
				}
				unset($tmp);
			}
		} // end if user is not admin

		// compose the email field
		$this->dataRecord["source"] = "@".$domain["domain"];
		// Set the server id of the mailbox = server ID of mail domain.
		$this->dataRecord["server_id"] = $domain["server_id"];

		//unset($this->dataRecord["email_local_part"]);
		unset($this->dataRecord["email_domain"]);

		parent::onSubmit();
	}

	function onAfterInsert() {
		global $app;

		$domain = $app->db->queryOneRecord("SELECT sys_groupid FROM mail_domain WHERE domain_id = ? AND ".$app->tform->getAuthSQL('r'), $app->functions->intval($_POST["email_domain"]));
		$app->db->query("update mail_forwarding SET sys_groupid = ? WHERE forwarding_id = ?", $domain['sys_groupid'], $this->id);

	}

}

$page = new page_action;
$page->onLoad();

?>
