<?php
require_once "../../lib/config.inc.php";
require_once "../../lib/app.inc.php";

header("Content-Type: application/xml");

// ユーザーが入力したメールアドレスからドメインを取得
$email = (isset($_GET["emailaddress"])) ? $_GET["emailaddress"] : "";
$domain = (strpos($email, "@") !== false) ? explode("@", $email)[1] : "example.com";

// ISPConfigの設定（Company情報等）を取得
$company_config = $app->system_config->get_section("company");
$display_name = (!empty($company_config["company_name"])) ? $company_config["company_name"] . " Mail Service" : "ISPConfig Mail Service";
$short_name = (!empty($company_config["company_name"])) ? $company_config["company_name"] : "ISPConfig";

// サーバー名は現在の接続ホスト名をデフォルトとし、将来的に設定値から取得可能にする
$hostname = $_SERVER["SERVER_NAME"];

echo "<?xml version=\"1.0\" encoding=\"UTF-8\"?>
<clientConfig version=\"1.1\">
    <emailProvider id=\"$domain\">
        <domain>$domain</domain>
        <displayName>$display_name</displayName>
        <displayShortName>$short_name</displayShortName>

        <incomingServer type=\"pop3\">
            <hostname>$hostname</hostname>
            <port>995</port>
            <socketType>SSL</socketType>
            <authentication>password-cleartext</authentication>
            <username>%EMAILADDRESS%</username>
        </incomingServer>

        <incomingServer type=\"imap\">
            <hostname>$hostname</hostname>
            <port>993</port>
            <socketType>SSL</socketType>
            <authentication>password-cleartext</authentication>
            <username>%EMAILADDRESS%</username>
        </incomingServer>

        <outgoingServer type=\"smtp\">
            <hostname>$hostname</hostname>
            <port>465</port>
            <socketType>SSL</socketType>
            <authentication>password-cleartext</authentication>
            <username>%EMAILADDRESS%</username>
        </outgoingServer>
    </emailProvider>
</clientConfig>";
