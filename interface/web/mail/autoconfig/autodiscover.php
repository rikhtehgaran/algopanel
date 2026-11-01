<?php
require_once "../../lib/config.inc.php";
require_once "../../lib/app.inc.php";

header("Content-Type: application/xml");

$data = file_get_contents("php://input");
preg_match("/<EMailAddress>(.*)<\/EMailAddress>/", $data, $matches);
$email = (isset($matches[1])) ? $matches[1] : "user@example.com";
$hostname = $_SERVER["SERVER_NAME"];

echo "<?xml version=\"1.0\" encoding=\"utf-8\" ?>
<Autodiscover xmlns=\"http://schemas.microsoft.com/exchange/autodiscover/responseschema/2006\">
    <Response xmlns=\"http://schemas.microsoft.com/exchange/autodiscover/outlook/responseschema/2006a\">
        <Account>
            <AccountType>email</AccountType>
            <Action>settings</Action>

            <Protocol>
                <Type>POP3</Type>
                <Server>$hostname</Server>
                <Port>995</Port>
                <SSL>on</SSL>
                <AuthRequired>on</AuthRequired>
                <LoginName>$email</LoginName>
            </Protocol>

            <Protocol>
                <Type>SMTP</Type>
                <Server>$hostname</Server>
                <Port>465</Port>
                <SSL>on</SSL>
                <AuthRequired>on</AuthRequired>
                <LoginName>$email</LoginName>
            </Protocol>

            <Protocol>
                <Type>IMAP</Type>
                <Server>$hostname</Server>
                <Port>993</Port>
                <SSL>on</SSL>
                <AuthRequired>on</AuthRequired>
                <LoginName>$email</LoginName>
            </Protocol>
        </Account>
    </Response>
</Autodiscover>";
