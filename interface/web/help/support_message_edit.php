<?php

//* Set the path to the form definition file.
$tform_def_file = 'form/support_message.tform.php';

//* include the basic application and configuration files
require_once '../../lib/config.inc.php';
require_once '../../lib/app.inc.php';

//* Check permissions for module
$app->auth->check_module_permissions('help');

//* Loading the templating and form classes
$app->uses('tpl,tform,tform_actions');
$app->load('tform_actions');

//* Creating a class page_action that extends the tform_actions base class
class page_action extends tform_actions {

	//* Custom onSubmit Event handler
	function onSubmit()
	{
		global $app, $conf;

		//* If the current user is not the admin user
		if($_SESSION['s']['user']['typ'] != 'admin') {
			//* Set the admin as recipient
			$this->dataRecord['recipient_id'] = 1;
		}

		//* Set the sender_id field to the ID of the current user
		$this->dataRecord['sender_id'] = $_SESSION['s']['user']['userid'];

		//* Get recipient email address
		$recipient_sender_email = '';
		$recipient_reply_to = '';
		if($this->dataRecord['recipient_id'] > 1){
			$sql = "SELECT client.email FROM sys_user, client WHERE sys_user.userid = ? AND sys_user.client_id = client.client_id";
			$client = $app->db->queryOneRecord($sql, $this->dataRecord['recipient_id']);
			$recipient_email = $client['email'];
			$recipient_sender_email = $recipient_email;
		} else {
			$app->uses('ini_parser,getconf');
			$system_config_mail_settings = $app->getconf->get_global_config('mail');
			$recipient_email = $system_config_mail_settings['admin_mail'];
			//* Mails of the admin are sent from the server sender address, see #7028
			$recipient_sender_email = (!empty($system_config_mail_settings['server_sender_mail']) ? $system_config_mail_settings['server_sender_mail'] : $recipient_email);
			if($recipient_email != '' && $recipient_email != $recipient_sender_email) $recipient_reply_to = $recipient_email;
		}

		//* Get sender email address
		$sender_reply_to = '';
		if($this->dataRecord['sender_id'] > 1){
			$sql = "SELECT client.email FROM sys_user, client WHERE sys_user.userid = ? AND sys_user.client_id = client.client_id";
			$client = $app->db->queryOneRecord($sql, $this->dataRecord['sender_id']);
			$sender_email = $client['email'];
			$sender_contact_email = $sender_email;
		} else {
			$app->uses('ini_parser,getconf');
			$system_config_mail_settings = $app->getconf->get_global_config('mail');
			//* Messages of the admin are sent from the server sender address, the administrators
			//* contact address is used as reply address and stays the recipient of the
			//* confirmation mail, see #7028
			$sender_contact_email = $system_config_mail_settings['admin_mail'];
			$sender_email = (!empty($system_config_mail_settings['server_sender_mail']) ? $system_config_mail_settings['server_sender_mail'] : $sender_contact_email);
			if($sender_contact_email != '' && $sender_contact_email != $sender_email) $sender_reply_to = $sender_contact_email;
		}

		$email_regex = '/^(\w+[\w\.\-\+]*\w{0,}@\w+[\w.-]*\.[a-z\-]{2,10}){0,1}$/i';
		if(preg_match($email_regex, $sender_email, $match) && preg_match($email_regex, $recipient_email, $match)){
			$subject = $app->tform->lng('support_request_subject_txt').': '.$this->dataRecord['subject'];
			if($this->dataRecord['recipient_id'] == 1){
				$message = $app->tform->lng('support_request_txt');
			} else {
				$message = $app->tform->lng('answer_to_support_request_txt');
			}
			$message .= "\n\n".$app->tform->lng('message_txt').": \"".$this->dataRecord['message']."\"";
			$message .= "\n\nISPConfig: ".($_SERVER['HTTPS'] == 'on' ? 'https://' : 'http://').$_SERVER['HTTP_HOST'];
			$app->functions->mail($recipient_email, $subject, $message, $sender_email, '', 'application/pdf', '', '', '', '', $sender_reply_to);

			//* Send confirmation email to sender
			if($this->dataRecord['sender_id'] == 1){
				$confirmation_message = $app->tform->lng('answer_to_support_request_sent_txt');
			} else {
				$confirmation_message = $app->tform->lng('support_request_sent_txt');
			}
			$confirmation_message .= "\n\n".$app->tform->lng('message_txt').": \"".$this->dataRecord['message']."\"";
			$confirmation_message .= "\n\nISPConfig: ".($_SERVER['HTTPS'] == 'on' ? 'https://' : 'http://').$_SERVER['HTTP_HOST'];
			if ($this->dataRecord['subject'] != '' && $this->dataRecord['message'] != '') $app->functions->mail($sender_contact_email, $subject, $confirmation_message, $recipient_sender_email, '', 'application/pdf', '', '', '', '', $recipient_reply_to);
		} else {
			$app->tform->errorMessage .= $app->tform->lng("recipient_or_sender_email_address_not_valid_txt")."<br />";
		}

		//* call the onSubmit function of the parent class
		parent::onSubmit();
	}

	//* Custom onShow Event handler
	function onShow()
	{
		global $app, $conf;

		//* We do not want that messages get edited, so we switch to a
		//*  read only template  if a existing message is loaded
		if($this->id > 0) {
			$app->tform->formDef['tabs']['message']['template'] = 'templates/support_message_view.htm';
			$record = $app->db->queryOneRecord("SELECT * FROM support_message WHERE support_message_id = ?", $this->id);
			if ($record['tstamp'] > 0) {
				// is value int?
				if (preg_match("/^[0-9]+[\.]?[0-9]*$/", $record['tstamp'], $p)) {
					$record['tstamp'] = date($app->lng('conf_format_datetime'), $record['tstamp']);
				} else {
					$record['tstamp'] = date($app->lng('conf_format_datetime'), strtotime($record['tstamp']));
				}
			}
			$app->tpl->setVar("date", $record['tstamp']);
			//die(print_r($this->dataRecord));
		}

		//* call the onShow function of the parent class
		parent::onShow();
	}

	function onAfterInsert()
	{
		global $app, $conf;

		if($_SESSION['s']['user']['typ'] == 'admin') {
			$app->db->query("UPDATE support_message SET sys_userid = ? WHERE support_message_id = ?", $this->dataRecord['recipient_id'], $this->id);
		}

	}

}

//* Create the new page object
$page = new page_action();

//* Start the page rendering and action handling
$page->onLoad();

?>
