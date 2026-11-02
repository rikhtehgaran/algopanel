-- Update default admin password to md5('admin')
UPDATE dbispconfig.sys_user SET passwort = MD5('admin') WHERE username = 'admin';

-- Ensure ispconfig user has full access
GRANT ALL PRIVILEGES ON dbispconfig.* TO 'ispconfig'@'%' IDENTIFIED BY 'ispconfig_password';
FLUSH PRIVILEGES;
