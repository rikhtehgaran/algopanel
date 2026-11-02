<?php

class extension_installer {

	private $extension_basedir = '/usr/local/ispconfig/extensions';
	private $ispconfig_dir = '/usr/local/ispconfig';
	private $download_url = 'https://repo.ispconfig.com/packages/';
	private $repo_list_url = 'https://repo.ispconfig.com/api/v1/list/';
	private $repo_cache = [];

	public $errors = [];

	// get functions for properties
	public function getExtensionBasedir() {
		return $this->extension_basedir;
	}
	public function getIspconfigDir() {
		return $this->ispconfig_dir;
	}
	public function getDownloadUrl() {
		return $this->download_url;
	}
	public function getRepoListUrl() {
		if(file_exists($this->extension_basedir.'/devkey')) {
			$devkey = trim(file_get_contents($this->extension_basedir.'/devkey'));
			return $this->repo_list_url.'?devkey='.urlencode($devkey);
		}
		
		return $this->repo_list_url;
	}

	// get errors
	public function getErrors() {
		return $this->errors;
	}

	// add Error message
	public function addError($error) {
		$this->errors[] = $error;
	}

	/**
     * Check if the extension name is valid
     * @param string $extension_name
     * @return bool
     */
    public function checkExtensionName($extension_name, $version = null) {
        global $app;
        
        // Check empty extension name
        if(empty($extension_name)) {
            $this->addError('Extension name may not be empty.');
            return false;
        }

        // Check for invalid chars
        if(!preg_match('/^[a-zA-Z0-9_]{1,64}$/',$extension_name)) {
            $this->addError('Extension name contains invalid characters.');
            return false;
        }

        // check if extension exists in repository
		$repo_extensions = $this->getRepoExtensions();

		if(empty($repo_extensions)) {
			$this->addError('No extensions available in repository.');
            return false;
		}

		// Check if the extension exists in the repository
		$extension_found = false;
		foreach($repo_extensions as $extension) {
			if($extension['name'] == $extension_name) {
				if($version) {
					if($extension['version'] != $version) {
						$this->addError('Extension version not found in repository.');
						return false;
					}
				}
				$extension_found = true;
				break;
			}
		}

		if(!$extension_found) {
			$this->addError('Extension not found in repository.');
			return false;
		}

        return true;
    }

	/**
	 * Summary of enable_files
	 * @param mixed $name
	 * @return bool
	 */
	public function enable_files($name) {
		global $app, $conf;

		// check name validity
		if(!preg_match('/^[a-zA-Z0-9_]{1,64}$/',$name)) {
			$app->log('Invalid extension name: '.$name, LOGLEVEL_WARN);
			$this->addError('Invalid extension name: '.$name);
			return false;
		}

		$ext_dir = $this->extension_basedir.'/'.$name;

		// check name against regex
		if(!preg_match('/^[a-zA-Z0-9_]+$/', $name)) {
			$app->log('Enabling extension'.$name.'failed. Invalid name.',LOGLEVEL_WARN);
			$this->addError('Enabling extension'.$name.'failed. Invalid name.');
			return false;
		}

		// Check if the extension has already been downloaded
		if(!is_dir($ext_dir)) {
			$app->log('Enabling extension'.$name.'failed. No such directory.',LOGLEVEL_WARN);
			$this->addError('Enabling extension'.$name.'failed. No such directory.');
			return false;
		}

		// Check if we have a file.list
		$file_list_path = $ext_dir.'/install/file.list';
		if(!file_exists($file_list_path)) {
			$app->log('The extension '.$name.' has no file list.',LOGLEVEL_WARN);
			$this->addError('The extension '.$name.' has no file list.');
			return false;
		}

		// Read file list
		$files = file($file_list_path, FILE_IGNORE_NEW_LINES | FILE_SKIP_EMPTY_LINES);
		if(!empty($files) && is_array($files)) {
			foreach($files as $file) {
				// Skip comment lines
				if(substr(trim($file),0,1) == '#') continue;
				// skip empty lines
				if(empty(trim($file))) continue;

				// parse line
				$parts = explode(':', trim($file));
				if(count($parts) != 3) {
					$app->log('Invalid file list line: '.$file, LOGLEVEL_WARN);
					$this->addError('Invalid file list line: '.$file);
					return false;
				}
				list($action,$source,$target) = $parts;
				// echo 'Action: '.$action.' Source: '.$source.' Target: '.$target."\n";

				// Check action, must be c or s or d
				if($action != 'c' && $action != 's' && $action != 'd') {
					$app->log('Invalid file list action: '.$action, LOGLEVEL_WARN);
					$this->addError('Invalid file list action: '.$action);
					return false;
				}

				// Check source
				if(empty($source) || empty($action) || $source == '/' || $source == '.' || $source == '..') {
					$app->log('Invalid file list: '.$file_list_path, LOGLEVEL_WARN);
					$this->addError('Invalid file list: '.$file_list_path);
					return false;
				}
				// source file must be within /usr/local/ispconfig/extensions, check with realpath
				$source = realpath($ext_dir.'/'.$source);

				// check if empty after realpath or outside of the extension directory
				if(empty($source) || strpos($source, realpath($ext_dir).'/') !== 0) {
					$app->log('Invalid file list: '.$file_list_path, LOGLEVEL_WARN);
					$this->addError('Invalid file list: '.$file_list_path);
					return false;
				}

				// Check target
				if(empty($target) || empty($action) || $target == '/' || $target == '.' || strpos($target, '..') !== false) {
					$app->log('Invalid file list: '.$file_list_path, LOGLEVEL_WARN);
					$this->addError('Invalid file list: '.$file_list_path);
					return false;
				}
				
				// Copy
				if($action == 'c') {
					if(!empty($source) && !empty($target) && is_file($source)) {
						if(is_link($this->ispconfig_dir.'/'.$target)) unlink($this->ispconfig_dir.'/'.$target);
						copy($source, $this->ispconfig_dir.'/'.$target);
						// if target starts with 'interface'
						if (substr($target, 0, 9) == 'interface') {
							exec('chown -h ispconfig:ispconfig '.escapeshellarg($this->ispconfig_dir.'/'.$target));
						} else {
							exec('chown -h root:root '.escapeshellarg($this->ispconfig_dir.'/'.$target));
						}
						exec('chmod 640 '.escapeshellarg($this->ispconfig_dir.'/'.$target));
					}
					if(!empty($source) && !empty($target) && is_dir($source)) {
						if(is_link($this->ispconfig_dir.'/'.$target)) unlink($this->ispconfig_dir.'/'.$target);
						if(is_dir($this->ispconfig_dir.'/'.$target)) {
							// target exists (e.g. on update): copy the directory contents to avoid nesting
							exec('cp -prf '.escapeshellarg($source).'/. '.escapeshellarg($this->ispconfig_dir.'/'.$target));
						} else {
							exec('cp -prf '.escapeshellarg($source).' '.escapeshellarg($this->ispconfig_dir.'/'.$target));
						}
						// if target starts with 'interface'
						if (substr($target, 0, 9) == 'interface') {
							exec('chown -R ispconfig:ispconfig '.escapeshellarg($this->ispconfig_dir.'/'.$target));
						} else {
							exec('chown -R root:root '.escapeshellarg($this->ispconfig_dir.'/'.$target));
						}
					}
				}

				// Symlink
				if($action == 's') {
					if(!empty($source) && !empty($target) && file_exists($source)) {
						if(is_link($this->ispconfig_dir.'/'.$target)) unlink($this->ispconfig_dir.'/'.$target);
						symlink($source, $this->ispconfig_dir.'/'.$target);
						// if target starts with 'interface'
						if (substr($target, 0, 9) == 'interface') {
							exec('chown ispconfig:ispconfig '.escapeshellarg($this->ispconfig_dir.'/'.$target));
						} else {
							exec('chown root:root '.escapeshellarg($this->ispconfig_dir.'/'.$target));
						}
						// chmod follows the symlink; directories must keep the x bit to stay traversable
						if(is_file($source)) {
							exec('chmod 640 '.escapeshellarg($this->ispconfig_dir.'/'.$target));
						}
					}
				}

				// Directory "d"
				if($action == 'd') {
					if(!empty($target) && !is_dir($this->ispconfig_dir.'/'.$target)) {
						//exec('mkdir -p '.$this->ispconfig_dir.'/'.$target);
						$app->system->mkdir($this->ispconfig_dir.'/'.$target,false,0750);
						// if target starts with 'interface'
						if (substr($target, 0, 9) == 'interface') {
							exec('chown ispconfig:ispconfig '.escapeshellarg($this->ispconfig_dir.'/'.$target));
						} else {
							exec('chown root:root '.escapeshellarg($this->ispconfig_dir.'/'.$target));
						}
						// directories need the x bit to be traversable
						exec('chmod 750 '.escapeshellarg($this->ispconfig_dir.'/'.$target));
					}
				}
			}
		}

		// Create active file
		touch($ext_dir.'/active');

		return true;

	}

	/**
	 * Summary of disable_files
	 * @param mixed $name
	 * @return void
	 */
	public function disable_files($name) {
		global $app, $conf;

		// check name validity
		if(!preg_match('/^[a-zA-Z0-9_]{1,64}$/',$name)) {
			$app->log('Invalid extension name: '.$name, LOGLEVEL_WARN);
			$this->errors[] = 'Invalid extension name: '.$name;
			return false;
		}

		$ext_dir = $this->extension_basedir.'/'.$name;

		// Check if the extension has already been downloaded
		if(!is_dir($ext_dir)) {
			$app->log('Disabling extension'.$name.'failed. No such directory.',LOGLEVEL_WARN);
			$this->addError('No such directory: '.$ext_dir);
			return false;
		}

		// Check if we have a file.list
		$file_list_path = $ext_dir.'/install/file.list';
		if(!file_exists($file_list_path)) {
			$app->log('The extension '.$name.' has no file list.',LOGLEVEL_WARN);
			$this->addError('No file list: '.$file_list_path);
			return false;
		}

		// Read file list
		$files = file($file_list_path, FILE_IGNORE_NEW_LINES | FILE_SKIP_EMPTY_LINES);
		if(!empty($files) && is_array($files)) {
			foreach($files as $file) {
				// Skip comment lines
				if(substr(trim($file),0,1) == '#') continue;
				// skip empty lines
				if(empty(trim($file))) continue;

				// parse line
				$parts = explode(':', trim($file));
				if(count($parts) != 3) {
					$app->log('Invalid file list line: '.$file, LOGLEVEL_WARN);
					$this->addError('Invalid file list line: '.$file);
					return false;
				}
				list($action,$source,$target) = $parts;

				// Check action, must be c or s or d
				if($action != 'c' && $action != 's' && $action != 'd') {
					$app->log('Invalid file list action: '.$action, LOGLEVEL_WARN);
					$this->addError('Invalid file list action: '.$action);
					return false;
				}

				// Check target
				if(empty($target) || empty($action) || $target == '/' || $target == '.' || strpos($target, '..') !== false) {
					$app->log('Invalid target: '.$target, LOGLEVEL_WARN);
					$this->addError('Invalid target: '.$target);
					return false;
				}

				// target file must be within /usr/local/ispconfig
				$target = $this->ispconfig_dir.'/'.$target;

				// check if empty after realpath
				if(empty($target)) {
					$app->log('Invalid target after realpath: '.$target, LOGLEVEL_WARN);
					$this->addError('Invalid target after realpath: '.$target);
					return false;
				}

				// check if target is within /usr/local/ispconfig and exists
				if(strpos($target, $this->ispconfig_dir) !== 0) {
					$app->log('Target not within /usr/local/ispconfig: '.$target, LOGLEVEL_WARN);
					$this->addError('Target not within /usr/local/ispconfig: '.$target);
					return false;
				}

				// Remove Copy
				if($action == 'c') {
					if(!empty($target) && is_file($target)) {
						unlink($target);
					}
					if(!empty($target) && $target != '/' && $target != '.' && $target != '..' && is_dir($target)) {
						exec('rm -rf '.escapeshellarg($target));
					}
				}

				

				// Remove Symlink
				if($action == 's') {
					if(!empty($target) && is_link($target)) {
						unlink($target);
					}
				}

			}
		}

		// Delete active file
		if(file_exists($ext_dir.'/active')) {
			unlink($ext_dir.'/active');
		}

		return true;
	}

	/**
	 * Summary of download_extension
	 * @param mixed $name
	 * @return void
	 */
	public function download_extension($name, $version = null, $force = false) {
		global $app, $conf;

		// check name validity
		if(!preg_match('/^[a-zA-Z0-9_]{1,64}$/',$name)) {
			$app->log('Invalid extension name: '.$name, LOGLEVEL_WARN);
			$this->addError('Invalid extension name: '.$name);
			return false;
		}

		// check if extension exists in repository
		$repo_extensions = $this->getRepoExtensions();

		if(empty($repo_extensions)) {
			$app->log('No extensions available in repository', LOGLEVEL_WARN);
			$this->addError('No extensions available in repository');
			return false;
		}

		// Check if the extension exists in the repository and remember its catalog entry
		$repo_extension = null;
		foreach($repo_extensions as $extension) {
			if($extension['name'] == $name) {
				if($version) {
					if($extension['version'] != $version) {
						$app->log('Extension version not found in repository', LOGLEVEL_WARN);
						$this->addError('Extension version not found in repository');
						return false;
					}
				}
				$repo_extension = $extension;
				break;
			}
		}

		if($repo_extension === null) {
			$app->log('Extension not found in repository', LOGLEVEL_WARN);
			$this->addError('Extension not found in repository');
			return false;
		}

		$ext_dir = $this->extension_basedir.'/'.$name;

		// Check if the extension has already been downloaded
		if($force == false && is_dir($ext_dir)) {
			return true;
		}

		// Create the directory if it does not exist
		if(!is_dir($ext_dir)) {
			mkdir($ext_dir, 0750, true);
			// change to user and group ispconfig
			exec('chown -R ispconfig:ispconfig '.escapeshellarg($ext_dir));
		}

		// Download the extension using php curl
		$curl = curl_init();
		if($version) {
			$package_url = $this->download_url.$name.'-'.$version.'.pkg';
		} else {
			$package_url = $this->download_url.$name.'.pkg';
		}
		$app->log('Downloading extension from: '.$package_url, LOGLEVEL_DEBUG);
		curl_setopt($curl, CURLOPT_URL, $package_url);
		// Remove CURLOPT_RETURNTRANSFER as it conflicts with CURLOPT_FILE
		// curl_setopt($curl, CURLOPT_RETURNTRANSFER, true);
		curl_setopt($curl, CURLOPT_FAILONERROR, true);
		curl_setopt($curl, CURLOPT_FOLLOWLOCATION, true);
		// TLS certificates are verified (curl default); allow https only, also for redirects
		curl_setopt($curl, CURLOPT_PROTOCOLS, CURLPROTO_HTTPS);
		curl_setopt($curl, CURLOPT_REDIR_PROTOCOLS, CURLPROTO_HTTPS);
		curl_setopt($curl, CURLOPT_CONNECTTIMEOUT, 10);
		curl_setopt($curl, CURLOPT_TIMEOUT, 300);
		
		// Write the file with .pkg extension
		$package_file = $ext_dir.'/'.$name.'.pkg';
		$fp = fopen($package_file, 'w');
		curl_setopt($curl, CURLOPT_FILE, $fp);
		$result = curl_exec($curl);
		
		// Check for cURL errors
		if($result === false) {
			$error = curl_error($curl);
			$app->log('cURL error when downloading extension '.$name.': '.$error, LOGLEVEL_WARN);
			$this->addError('Failed to download extension: '.$name.' - '.$error);
			fclose($fp);
			curl_close($curl);
			return false;
		}
		
		// Get HTTP status code
		$http_code = curl_getinfo($curl, CURLINFO_HTTP_CODE);
		curl_close($curl);
		fclose($fp);
		
		// Check if the file was downloaded successfully
		if($http_code != 200 || !file_exists($package_file) || filesize($package_file) == 0) {
			$app->log('Failed to download extension '.$name.'. HTTP status: '.$http_code, LOGLEVEL_WARN);
			$this->addError('Failed to download extension: '.$name.'. HTTP status: '.$http_code);
			// Remove empty file if it exists
			if(file_exists($package_file)) unlink($package_file);
			return false;
		}

		// Verify the package checksum when the repository provides one
		if(!empty($repo_extension['sha256'])) {
			$package_hash = hash_file('sha256', $package_file);
			if(!hash_equals(strtolower($repo_extension['sha256']), strtolower($package_hash))) {
				$app->log('Checksum mismatch for extension package '.$name, LOGLEVEL_WARN);
				$this->addError('Checksum mismatch for extension package: '.$name);
				unlink($package_file);
				return false;
			}
		}

		// unpack the zip archive
		// check if zip extension in PHP is enabled, if not, use unzip command on the shell
		if (!extension_loaded('zip')) {
			// Create a temporary directory for extraction to avoid nested folders
			$temp_dir = $ext_dir.'_temp';
			if(!is_dir($temp_dir)) {
				mkdir($temp_dir, 0750, true);
				exec('chown -R ispconfig:ispconfig '.escapeshellarg($temp_dir));
			}
			
			// Extract to temp directory
			exec('unzip -o '.escapeshellarg($package_file).' -d '.escapeshellarg($temp_dir));
			
			// Check if we have a nested directory with the same name
			if(is_dir($temp_dir.'/'.$name)) {
				// Copy the contents of the nested directory to the extension directory
				// ('/.' also covers dotfiles; a quoted '*' glob would not expand)
				exec('cp -rf '.escapeshellarg($temp_dir.'/'.$name).'/. '.escapeshellarg($ext_dir.'/'));
			} else {
				// No nested directory, just copy everything
				exec('cp -rf '.escapeshellarg($temp_dir).'/. '.escapeshellarg($ext_dir.'/'));
			}
			// Remove temporary directory and the downloaded package
			$this->remove_extension_dir($temp_dir);
			unlink($package_file);
		} else {
			$zip = new ZipArchive();
			if ($zip->open($package_file) === TRUE) {
				// Create a temporary directory for extraction to avoid nested folders
				$temp_dir = $ext_dir.'_temp';
				if(!is_dir($temp_dir)) {
					mkdir($temp_dir, 0750, true);
					exec('chown -R ispconfig:ispconfig '.escapeshellarg($temp_dir));
				}
				
				// Extract to temp directory
				$zip->extractTo($temp_dir);
				$zip->close();
				
				// Check if we have a nested directory with the same name
				if(is_dir($temp_dir.'/'.$name)) {
					// Get all files and directories in the nested directory
					$files = scandir($temp_dir.'/'.$name);
					foreach($files as $file) {
						if($file != '.' && $file != '..') {
							$source = $temp_dir.'/'.$name.'/'.$file;
							$target = $ext_dir.'/'.$file;
							
							if(is_dir($source)) {
								// For directories, use recursive copy
								$app->system->exec_safe('cp -rf ? ?', $source, $ext_dir);
							} else {
								// For files, just copy
								copy($source, $target);
							}
						}
					}
				} else {
					// No nested directory, just move everything
					$files = scandir($temp_dir);
					foreach($files as $file) {
						if($file != '.' && $file != '..') {
							$source = $temp_dir.'/'.$file;
							$target = $ext_dir.'/'.$file;
							
							if(is_dir($source)) {
								// For directories, use recursive copy
								$app->system->exec_safe('cp -rf ? ?', $source, $ext_dir);
							} else {
								// For files, just copy
								copy($source, $target);
							}
						}
					}
				}
				
				// Remove temporary directory
				$this->remove_extension_dir($temp_dir);
			} else {
				$app->log('Failed to extract extension '.$name, LOGLEVEL_WARN);
				$this->addError('Failed to extract extension: '.$name);
				return false;
			}
			unlink($package_file);
			unset($zip);
		}

		// Change all extension files to ispconfig:ispconfig
        exec('chown -R ispconfig:ispconfig '.escapeshellarg($ext_dir.'/'));
        // chmod
        exec('chmod -R 750 '.escapeshellarg($ext_dir.'/'));
		
		return true;
	}

	/**
	 * Load the install SQL of an extension into the database.
	 *
	 * Extensions are installed on every server, so the install SQL is split by scope:
	 *  - install/install_node.sql   runs on every server against the local ISPConfig database.
	 *                               install/install.sql is the legacy name with the same meaning.
	 *  - install/install_master.sql runs additionally on the server which holds the master
	 *                               database. Slaves never connect to the master database here.
	 * The install SQL always contains the full current schema, so afterwards the schema
	 * version of the extension is set to the latest shipped migration, see run_sql_migrations().
	 * @param string $name
	 * @return bool
	 */
	public function load_install_sql($name) {
		global $app;

		// check name validity
		if(!preg_match('/^[a-zA-Z0-9_]{1,64}$/',$name)) {
			$app->log('Invalid extension name: '.$name, LOGLEVEL_WARN);
			$this->addError('Invalid extension name: '.$name);
			return false;
		}

		$ext_dir = $this->extension_basedir.'/'.$name;

		// Check if the extension has already been downloaded
		if(!is_dir($ext_dir)) {
			$app->log('Loading install SQL for extension '.$name.' failed. No such directory.',LOGLEVEL_WARN);
			$this->addError('No such directory: '.$ext_dir);
			return false;
		}

		$node_sql = $this->find_sql_file($ext_dir, array('install_node.sql', 'install.sql'));
		$master_sql = $this->find_sql_file($ext_dir, array('install_master.sql'));

		if($node_sql === false && $master_sql === false) {
			$app->log('The extension '.$name.' has no install SQL.', LOGLEVEL_DEBUG);
		}

		if($node_sql !== false && !$this->run_scoped_sql_file($name, $node_sql, 'node')) {
			return false;
		}
		if($master_sql !== false && !$this->run_scoped_sql_file($name, $master_sql, 'master')) {
			return false;
		}

		// the install SQL contains the full schema, all shipped migrations count as applied
		$this->set_schema_version($ext_dir, $this->get_latest_migration_version($ext_dir));

		return true;
	}

	/**
	 * Run the uninstall SQL of an extension. Same split as for the install SQL:
	 * install/uninstall_node.sql (legacy name: install/uninstall.sql) runs on every server,
	 * install/uninstall_master.sql only where the master database is local.
	 * @param string $name
	 * @return bool
	 */
	public function run_uninstall_sql($name) {
		global $app;

		// check name validity
		if(!preg_match('/^[a-zA-Z0-9_]{1,64}$/',$name)) {
			$app->log('Invalid extension name: '.$name, LOGLEVEL_WARN);
			$this->addError('Invalid extension name: '.$name);
			return false;
		}

		$ext_dir = $this->extension_basedir.'/'.$name;

		// Check if the extension has already been downloaded
		if(!is_dir($ext_dir)) {
			$app->log('Running uninstall SQL for extension '.$name.' failed. No such directory.',LOGLEVEL_WARN);
			$this->addError('No such directory: '.$ext_dir);
			return false;
		}

		$node_sql = $this->find_sql_file($ext_dir, array('uninstall_node.sql', 'uninstall.sql'));
		$master_sql = $this->find_sql_file($ext_dir, array('uninstall_master.sql'));

		if($node_sql === false && $master_sql === false) {
			$app->log('The extension '.$name.' has no uninstall SQL.', LOGLEVEL_DEBUG);
		}

		$ok = true;
		if($node_sql !== false && !$this->run_scoped_sql_file($name, $node_sql, 'node')) {
			$ok = false;
		}
		if($master_sql !== false && !$this->run_scoped_sql_file($name, $master_sql, 'master')) {
			$ok = false;
		}

		return $ok;
	}

	/**
	 * Apply pending schema migrations of an extension (called on update).
	 *
	 * Migrations live in install/incremental/ and are numbered like the core ones:
	 *  - upd_0001_node.sql   runs on every server against the local database
	 *  - upd_0001_master.sql runs only on the server which holds the master database
	 * A step may ship one or both files, steps must be consecutive. The last applied step
	 * is stored in the file "dbversion" in the extension directory. A missing file counts
	 * as version 0 (extension installed before migrations existed), so migrations should
	 * be written re-runnable (CREATE TABLE IF NOT EXISTS, ADD COLUMN IF NOT EXISTS, ...).
	 * @param string $name
	 * @return bool false when a migration failed, later steps are then not applied
	 */
	public function run_sql_migrations($name) {
		global $app;

		// check name validity
		if(!preg_match('/^[a-zA-Z0-9_]{1,64}$/',$name)) {
			$app->log('Invalid extension name: '.$name, LOGLEVEL_WARN);
			$this->addError('Invalid extension name: '.$name);
			return false;
		}

		$ext_dir = $this->extension_basedir.'/'.$name;

		if(!is_dir($ext_dir)) {
			$app->log('Running migrations for extension '.$name.' failed. No such directory.',LOGLEVEL_WARN);
			$this->addError('No such directory: '.$ext_dir);
			return false;
		}

		$current_version = $this->get_schema_version($ext_dir);
		$latest_version = $this->get_latest_migration_version($ext_dir);

		if($current_version >= $latest_version) {
			$app->log('No pending schema migrations for extension '.$name.' (version '.$current_version.')', LOGLEVEL_DEBUG);
			return true;
		}

		for($version = $current_version + 1; $version <= $latest_version; $version++) {
			$prefix = $ext_dir.'/install/incremental/upd_'.str_pad($version, 4, '0', STR_PAD_LEFT);
			foreach(array('node', 'master') as $scope) {
				$sql_file = $prefix.'_'.$scope.'.sql';
				if(!is_file($sql_file)) continue;
				if(!$this->run_scoped_sql_file($name, $sql_file, $scope)) {
					// keep the version of the last complete step, so a fixed migration can be retried
					return false;
				}
			}
			$this->set_schema_version($ext_dir, $version);
		}

		$app->log('Schema of extension '.$name.' migrated from version '.$current_version.' to '.$latest_version, LOGLEVEL_INFO);

		return true;
	}

	/**
	 * Return the first existing file of the given names in the install dir of an extension.
	 * @param string $ext_dir
	 * @param array $names
	 * @return string|false
	 */
	private function find_sql_file($ext_dir, $names) {
		foreach($names as $file) {
			if(is_file($ext_dir.'/install/'.$file)) {
				return $ext_dir.'/install/'.$file;
			}
		}
		return false;
	}

	/**
	 * Run a SQL file of the given scope: 'node' files run on every server, 'master' files
	 * only on the server which holds the master database (skipped with success elsewhere).
	 * @param string $name extension name, for logging
	 * @param string $sql_file
	 * @param string $scope 'node' or 'master'
	 * @return bool
	 */
	private function run_scoped_sql_file($name, $sql_file, $scope) {
		global $app;

		if($scope == 'master' && !$this->is_master_db_local()) {
			$app->log('Skipping '.basename($sql_file).' of extension '.$name.', the master database is not on this server', LOGLEVEL_DEBUG);
			return true;
		}

		if(!$this->exec_sql_file($sql_file)) {
			$app->log('Failed to run '.basename($sql_file).' for extension '.$name, LOGLEVEL_WARN);
			$this->addError('Failed to run '.basename($sql_file).': '.$sql_file);
			return false;
		}

		$app->log('Loaded '.basename($sql_file).' for extension '.$name, LOGLEVEL_INFO);
		return true;
	}

	/**
	 * Check whether the master database is the local ISPConfig database of this server,
	 * i.e. single server setup or the master server of a multiserver setup.
	 * Same test as used for $app->dbmaster in server/lib/app.inc.php.
	 * @return bool
	 */
	private function is_master_db_local() {
		global $conf;

		if(empty($conf['dbmaster_host'])) {
			return true;
		}
		return ($conf['dbmaster_host'] == $conf['db_host']
			&& $conf['dbmaster_database'] == $conf['db_database']
			&& $conf['dbmaster_port'] == $conf['db_port']);
	}

	/**
	 * Read the applied schema version of an extension from the file "dbversion" in the
	 * extension directory. Missing file = 0.
	 * @param string $ext_dir
	 * @return int
	 */
	private function get_schema_version($ext_dir) {
		if(is_file($ext_dir.'/dbversion')) {
			return intval(trim(file_get_contents($ext_dir.'/dbversion')));
		}
		return 0;
	}

	/**
	 * Store the applied schema version of an extension.
	 * @param string $ext_dir
	 * @param int $version
	 */
	private function set_schema_version($ext_dir, $version) {
		file_put_contents($ext_dir.'/dbversion', intval($version)."\n");
	}

	/**
	 * Highest migration step number shipped in install/incremental/ of an extension, 0 if none.
	 * @param string $ext_dir
	 * @return int
	 */
	private function get_latest_migration_version($ext_dir) {
		$latest = 0;
		$files = glob($ext_dir.'/install/incremental/upd_*.sql');
		if(is_array($files)) {
			foreach($files as $file) {
				if(preg_match('/^upd_(\d{4})_(node|master)\.sql$/', basename($file), $matches)) {
					$latest = max($latest, intval($matches[1]));
				}
			}
		}
		return $latest;
	}

	/**
	 * Safely remove a directory below the extensions base directory.
	 * Safeguard for the rm -rf call: refuses empty paths, symlinks and anything
	 * that does not resolve to a strict subdirectory of the extensions dir.
	 * @param string $dir
	 * @return bool
	 */
	private function remove_extension_dir($dir) {
		global $app;

		if(empty($dir) || is_link($dir) || !is_dir($dir)) {
			return false;
		}
		$realdir = realpath($dir);
		$basedir = realpath($this->extension_basedir);
		if($realdir === false || $basedir === false || $basedir == '/' || strpos($realdir, $basedir.'/') !== 0) {
			$app->log('Refusing to remove directory outside of the extensions dir: '.$dir, LOGLEVEL_WARN);
			return false;
		}
		exec('rm -rf '.escapeshellarg($realdir));
		return true;
	}

	/**
	 * Execute an SQL file in the local ISPConfig database. The credentials are
	 * passed via a temporary defaults file instead of command line arguments,
	 * so the password does not show up in the process list.
	 * @param string $sql_file
	 * @return bool
	 */
	private function exec_sql_file($sql_file) {
		global $conf;

		$defaults_file = tempnam(sys_get_temp_dir(), 'ispcext');
		if($defaults_file === false) {
			return false;
		}
		chmod($defaults_file, 0600);
		// double quoted values in a mysql options file: backslash and double quote need escaping
		$quote = function($value) {
			return '"'.str_replace(array('\\', '"'), array('\\\\', '\\"'), $value).'"';
		};
		$options = "[client]\n";
		$options .= 'user='.$quote($conf['db_user'])."\n";
		$options .= 'password='.$quote($conf['db_password'])."\n";
		if(!empty($conf['db_host'])) $options .= 'host='.$quote($conf['db_host'])."\n";
		if(!empty($conf['db_port'])) $options .= 'port='.intval($conf['db_port'])."\n";
		if(!empty($conf['db_charset'])) $options .= 'default-character-set='.$quote($conf['db_charset'])."\n";
		file_put_contents($defaults_file, $options);

		exec('mysql --defaults-extra-file='.escapeshellarg($defaults_file).' -D '.escapeshellarg($conf['db_database']).' < '.escapeshellarg($sql_file), $output, $return_var);

		unlink($defaults_file);

		return $return_var == 0;
	}

	/**
	 * Validate one line of install/master_grants.list: the table must belong to the
	 * extension (prefix "<extension>_") and only SELECT, INSERT, UPDATE and DELETE may be
	 * granted. Same rules as installer_base::validate_extension_grant() in the updater.
	 * @param string $name extension name
	 * @param string $table
	 * @param string $privileges comma separated
	 * @return string|false normalized privilege list or false
	 */
	private function validate_master_grant($name, $table, $privileges) {
		if(!preg_match('/^[a-zA-Z0-9_]{1,64}$/', $name)) return false;
		if(!preg_match('/^[a-zA-Z0-9_]{1,64}$/', $table)) return false;
		if(strpos($table, $name.'_') !== 0) return false;

		$allowed = array('SELECT', 'INSERT', 'UPDATE', 'DELETE');
		$result = array();
		foreach(explode(',', $privileges) as $privilege) {
			$privilege = strtoupper(trim($privilege));
			if($privilege == '') continue;
			if(!in_array($privilege, $allowed)) return false;
			if(!in_array($privilege, $result)) $result[] = $privilege;
		}
		if(empty($result)) return false;

		return implode(', ', $result);
	}

	/**
	 * Parse install/master_grants.list of an extension. One declaration per line:
	 *   <table>:<privilege>[,<privilege>...]
	 * Empty lines and lines starting with # are ignored.
	 * @param string $name
	 * @return array|false list of array('table' => ..., 'privileges' => ...), false on an invalid line
	 */
	private function parse_master_grants($name) {
		global $app;

		$list_file = $this->extension_basedir.'/'.$name.'/install/master_grants.list';
		if(!is_file($list_file)) {
			return array();
		}

		$grants = array();
		foreach(file($list_file, FILE_IGNORE_NEW_LINES | FILE_SKIP_EMPTY_LINES) as $line) {
			$line = trim($line);
			if($line == '' || $line[0] == '#') continue;

			$parts = explode(':', $line);
			if(count($parts) != 2) {
				$app->log('Invalid master grant line in extension '.$name.': '.$line, LOGLEVEL_WARN);
				$this->addError('Invalid master grant line: '.$line);
				return false;
			}
			$table = trim($parts[0]);
			$privileges = $this->validate_master_grant($name, $table, $parts[1]);
			if($privileges === false) {
				$app->log('Invalid master grant in extension '.$name.': '.$line, LOGLEVEL_WARN);
				$this->addError('Invalid master grant (table must be prefixed with "'.$name.'_", allowed privileges: SELECT, INSERT, UPDATE, DELETE): '.$line);
				return false;
			}
			$grants[$table] = array('table' => $table, 'privileges' => $privileges);
		}

		return array_values($grants);
	}

	/**
	 * Register the master database rights an extension declares for its own tables and
	 * apply them to the existing server users. Runs only where the master database is
	 * local (the master server); slaves have nothing to do here.
	 *
	 * The declarations are stored in the table sys_extension_grant, from where the
	 * ISPConfig updater and the setrights script re-apply them for every ispcsrv user
	 * whenever the master database rights are rebuilt (which starts with REVOKE ALL) and
	 * when a new slave joins. Additionally they are applied right away when the MySQL root
	 * credentials of mysql_clientdb.conf are available on this server.
	 * @param string $name
	 * @return bool
	 */
	public function register_master_grants($name) {
		global $app;

		if(!$this->is_master_db_local()) {
			return true;
		}

		$grants = $this->parse_master_grants($name);
		if($grants === false) {
			return false;
		}

		// replace the stored declarations of this extension
		$app->db->query("DELETE FROM sys_extension_grant WHERE extension = ?", $name);
		foreach($grants as $grant) {
			$app->db->query("INSERT INTO sys_extension_grant (extension, table_name, privileges) VALUES (?, ?, ?)", $name, $grant['table'], $grant['privileges']);
		}

		if(empty($grants)) {
			return true;
		}
		$app->log('Registered '.count($grants).' master database grant(s) for extension '.$name, LOGLEVEL_INFO);

		return $this->apply_master_grants($name, $grants, 'GRANT');
	}

	/**
	 * Revoke and forget the master database rights an extension declared. Runs only
	 * where the master database is local. Must run before the uninstall SQL drops the
	 * tables.
	 * @param string $name
	 * @return bool
	 */
	public function unregister_master_grants($name) {
		global $app;

		if(!$this->is_master_db_local()) {
			return true;
		}

		$grants = array();
		$records = $app->db->queryAllRecords("SELECT table_name, privileges FROM sys_extension_grant WHERE extension = ?", $name);
		if(is_array($records)) {
			foreach($records as $record) {
				$privileges = $this->validate_master_grant($name, $record['table_name'], $record['privileges']);
				if($privileges === false) continue;
				$grants[] = array('table' => $record['table_name'], 'privileges' => $privileges);
			}
		}

		$app->db->query("DELETE FROM sys_extension_grant WHERE extension = ?", $name);

		if(empty($grants)) {
			return true;
		}

		return $this->apply_master_grants($name, $grants, 'REVOKE');
	}

	/**
	 * GRANT or REVOKE the declared rights of an extension for all ispcsrv users of the
	 * master database, using the MySQL root credentials from mysql_clientdb.conf. When
	 * those are not available the rights are applied by the next run of the ISPConfig
	 * updater or of install/setrights.php instead, which is logged.
	 * @param string $name extension name, for logging
	 * @param array $grants list of array('table' => ..., 'privileges' => ...), already validated
	 * @param string $mode 'GRANT' or 'REVOKE'
	 * @return bool
	 */
	private function apply_master_grants($name, $grants, $mode) {
		global $app, $conf;

		$hint = 'Run install/setrights.php from the ISPConfig tarball on the master server or update ISPConfig to apply them.';

		$clientdb_host = '';
		$clientdb_user = '';
		$clientdb_password = '';
		if(!is_readable(ISPC_LIB_PATH.'/mysql_clientdb.conf') || !include(ISPC_LIB_PATH.'/mysql_clientdb.conf') || $clientdb_user == '') {
			$app->log('No MySQL root credentials in '.ISPC_LIB_PATH.'/mysql_clientdb.conf, master database grants of extension '.$name.' not applied. '.$hint, LOGLEVEL_INFO);
			return true;
		}

		mysqli_report(MYSQLI_REPORT_OFF);
		$link = new mysqli($clientdb_host, $clientdb_user, $clientdb_password);
		if($link->connect_error) {
			$app->log('Unable to connect to MySQL as '.$clientdb_user.' to apply the master database grants of extension '.$name.': '.$link->connect_error.' '.$hint, LOGLEVEL_WARN);
			$this->addError('Master database grants of extension '.$name.' not applied. '.$hint);
			return false;
		}

		// the users of the slave servers; a single server setup has none
		$users = array();
		$result = $link->query("SELECT User, Host FROM mysql.user WHERE User LIKE 'ispcsrv%' ORDER BY User, Host");
		if($result) {
			while($row = $result->fetch_assoc()) {
				$users[] = $row;
			}
			$result->free();
		}

		$ok = true;
		$db = $conf['db_database'];
		foreach($users as $user) {
			foreach($grants as $grant) {
				$target = '`'.str_replace('`', '``', $db).'`.`'.$grant['table'].'`';
				$account = "'".$link->real_escape_string($user['User'])."'@'".$link->real_escape_string($user['Host'])."'";
				if($mode == 'REVOKE') {
					$query = 'REVOKE '.$grant['privileges'].' ON '.$target.' FROM '.$account;
				} else {
					$query = 'GRANT '.$grant['privileges'].' ON '.$target.' TO '.$account;
				}
				if(!$link->query($query)) {
					$app->log('Failed: '.$query.' Error: '.$link->error, LOGLEVEL_WARN);
					$ok = false;
				}
			}
		}
		$link->close();

		if($ok) {
			$app->log(($mode == 'REVOKE' ? 'Revoked' : 'Applied').' master database grants of extension '.$name.' for '.count($users).' server user(s)', LOGLEVEL_INFO);
		} else {
			$this->addError('Some master database grants of extension '.$name.' could not be '.($mode == 'REVOKE' ? 'revoked' : 'applied').'. '.$hint);
		}

		return $ok;
	}

	public function scan_extensions() {
        global $app, $conf;

        $app->log('Scanning extensions', LOGLEVEL_DEBUG);

		$extensions = [];

        // scan extensions directory
        $extension_directories = glob($this->extension_basedir.'/*', GLOB_ONLYDIR);
        if(!empty($extension_directories) && is_array($extension_directories)) {
            foreach($extension_directories as $extension_directory) {
                $app->log('Scanning extension '.$extension_directory, LOGLEVEL_DEBUG);
				
				// check if active
				if(file_exists($extension_directory.'/active')) {
					$active = true;
				} else {
					$active = false;
				}
				
				// check version
				if(file_exists($extension_directory.'/version')) {
					$version = file_get_contents($extension_directory.'/version');
				} else {
					$version = 'Unknown';
				}

				// check license
				if(file_exists($extension_directory.'/license')) {
					$license = file_get_contents($extension_directory.'/license');
				} else {
					$license = '';
				}
				
				$extensions[] = [
					'name' => basename($extension_directory),
					'active' => $active,
					'version' => $version,
					'license' => $license,
					'dbversion' => $this->get_schema_version($extension_directory)
				];
				$app->log('Found extension: '.basename($extension_directory), LOGLEVEL_DEBUG);
            }
        }

		if(!empty($extensions)) {
			//$app->log('Found extensions: '.print_r($extensions, true), LOGLEVEL_DEBUG);
			// store in monitor_data table

			// check if we have this type in monitor_data
			$sql = 'SELECT * FROM `monitor_data` WHERE `type` = ? and `server_id` = ?';
			$rec = $app->dbmaster->queryOneRecord($sql, 'extensions', $conf['server_id']);
			if(!empty($rec)) {
				// update
				$sql = 'UPDATE `monitor_data` SET `data` = ?, `created` = ? WHERE `type` = ? and `server_id` = ?';
				$app->dbmaster->query($sql, json_encode($extensions), time(), 'extensions', $conf['server_id']);
			} else {
				// insert
				$sql = 'INSERT INTO `monitor_data` (`server_id`, `type`, `created`, `data`, `state`) ' .
				'VALUES (' .
				$conf['server_id'] . ', ' .
				"'" . $app->dbmaster->quote('extensions') . "', " .
				'UNIX_TIMESTAMP(), ' .
				"'" . $app->dbmaster->quote(json_encode($extensions)) . "', " .
				"'" . 'ok' . "'" .
				')';
				$app->dbmaster->query($sql);
			} 
		} else {
			// Delete monitor_data record
			$sql = 'DELETE FROM `monitor_data` WHERE `type` = ? and `server_id` = ?';
			$app->dbmaster->query($sql, 'extensions', $conf['server_id']);
		}

        return $extensions;
    }

	/**
	 * Install an extension
	 * @param string $name
	 * @param string $version
	 * @return bool
	 */

	 public function install_extension($name, $version = null, $install_dependencies = true) {
		global $app;

		// Check if the extension has dependencies
		if($install_dependencies) {
			$repo_extension = $this->getRepoExtension($name);
			if(!empty($repo_extension['dependencies'])) {
				// split dependencies by ","
				$dependencies = explode(',', $repo_extension['dependencies']);
				foreach($dependencies as $dependency) {
					$dependency = trim($dependency);
					if($dependency == $name) {
						continue;
					}
					if($this->isExtensionInstalled($dependency)) {
						$app->log("Dependency {$dependency} already installed", LOGLEVEL_DEBUG);
						continue;
					}
					if(!$this->install_extension($dependency, null, $install_dependencies)) {
						$this->addError("Failed to install dependency {$dependency}");
						return false;
					} else {
						$app->log("Installed dependency {$dependency}", LOGLEVEL_DEBUG);
					}
				}
			}
		}

		// download extension if not already downloaded
        if(!is_dir($this->extension_basedir.'/'.$name)) {
            if(!$this->download_extension($name,$version)) {
                $this->addError("Failed to download extension {$name}");
                return false;
            }
        }

		// check if installer.php exists
        if(!file_exists($this->extension_basedir.'/'.$name.'/install/installer.php')) {
            $this->addError('Extension installer class not found.');
            return false;
        }
        
        // Include extension class from install directory
        require_once($this->extension_basedir.'/'.$name.'/install/installer.php');
        $classname = $name.'_installer';
        $installer = new $classname();

        if(!is_object($installer)) {
            $this->addError('Extension installer class not found or not an instance of installer.');
            return false;
        }

        // Install extension
        $installer->install($name);

        // Load install SQL (node part on every server, master part only where the master database is local)
        if(!$this->load_install_sql($name)) {
            $app->log('Extension '.$name.' not enabled because loading its install SQL failed', LOGLEVEL_WARN);
            return false;
        }

        // Register the master database rights the extension declares for its tables (master server only)
        if(!$this->register_master_grants($name)) {
            $app->log('Extension '.$name.' not enabled because registering its master database grants failed', LOGLEVEL_WARN);
            return false;
        }

        // enable extension
        $installer->enable($name);

		return true;
	}

	public function update_extension($name, $version = null) {
		global $app;

		// download extension
        if(!$this->download_extension($name,$version,true)) {
            if(empty($version)) {
                $this->errors[] = 'Error: Failed to download extension '.$name;
            } else {
                $this->errors[] = 'Error: Failed to download extension '.$name.' version '.$version;
            }
            return false;
        }

        // check if installer.php exists
        if(!file_exists($this->extension_basedir.'/'.$name.'/install/installer.php')) {
            $this->addError('Extension installer class not found.');
            return false;
        }
        
        // Include extension class from install directory
        require_once($this->extension_basedir.'/'.$name.'/install/installer.php');
        $classname = $name.'_installer';
        $installer = new $classname();

        if(!is_object($installer)) {
            $this->addError('Extension installer class not found or not an instance of installer.');
            return false;
        }

        // Update extension
        $installer->update($name);

        // Apply pending schema migrations
        if(!$this->run_sql_migrations($name)) {
            $app->log('Extension '.$name.' not enabled because a schema migration failed', LOGLEVEL_WARN);
            return false;
        }

        // Re-register the master database rights, the declarations may have changed (master server only)
        if(!$this->register_master_grants($name)) {
            $app->log('Extension '.$name.' not enabled because registering its master database grants failed', LOGLEVEL_WARN);
            return false;
        }

        // enable extension
        $installer->enable($name);
		
		return true;
	}

	/**
	 * Uninstall an extension
	 * @param string $name
	 * @return bool
	 */
	public function uninstall_extension($name) {
		global $app;

		// check if extension is installed
		if(!is_dir($this->extension_basedir.'/'.$name)) {
			$this->addError('Extension - '.$name.' - is not installed.');
			return false;
		}

		// check if installer.php exists
		if(!file_exists($this->extension_basedir.'/'.$name.'/install/installer.php')) {
			$this->addError('Extension installer class not found.');
			return false;
		}

		// include extension class from install directory
		require_once($this->extension_basedir.'/'.$name.'/install/installer.php');
		$classname = $name.'_installer';
		$installer = new $classname();

		if(!is_object($installer)) {
			$this->addError('Extension installer class not found or not an instance of installer.');
			return false;
		}

		// disable extension
		$installer->disable($name);

		// Uninstall extension
		$installer->uninstall($name);

		// Revoke and forget the declared master database rights (master server only)
		$this->unregister_master_grants($name);

		// Run uninstall SQL
		$this->run_uninstall_sql($name);

		// Remove extension directory
        $this->remove_extension_dir($this->extension_basedir.'/'.$name);

		return true;
	}

	public function enable_extension($name) {
		global $app;

		// check if extension is installed
		if(!is_dir($this->extension_basedir.'/'.$name)) {
			$this->addError('Extension - '.$name.' - is not installed.');
			return false;
		}

		// check if installer.php exists
		if(!file_exists($this->extension_basedir.'/'.$name.'/install/installer.php')) {
			$this->addError('Extension installer class not found.');
			return false;
		}

		// include extension class from install directory
		require_once($this->extension_basedir.'/'.$name.'/install/installer.php');
		$classname = $name.'_installer';
		$installer = new $classname();

		if(!is_object($installer)) {
			$this->addError('Extension installer class not found or not an instance of installer.');
			return false;
		}

		// enable extension
		$installer->enable($name);

		return true;
	}

	public function disable_extension($name) {
		global $app;

		// check if extension is installed
		if(!is_dir($this->extension_basedir.'/'.$name)) {
			$this->addError('Extension - '.$name.' - is not installed.');
			return false;
		}

		// check if installer.php exists
		if(!file_exists($this->extension_basedir.'/'.$name.'/install/installer.php')) {
			$this->addError('Extension installer class not found.');
			return false;
		}

		// include extension class from install directory
		require_once($this->extension_basedir.'/'.$name.'/install/installer.php');
		$classname = $name.'_installer';
		$installer = new $classname();

		if(!is_object($installer)) {
			$this->addError('Extension installer class not found or not an instance of installer.');
			return false;
		}

		// disable extension
		$installer->disable($name);

		return true;
	}

	/**
	 * Apply owner and permissions to a file or directory
	 * @param string $source
	 * @param string $target
	 * @throws \Exception
	 * @return bool
	 */
	private function applyOwnerAndPermissions($source, $target) {
		// Check if the source file exists
		if (!file_exists($source)) {
			throw new Exception("Source file does not exist: $source");
		}
	
		// Check if the target file exists
		if (!file_exists($target)) {
			throw new Exception("Target file does not exist: $target");
		}
	
		// Get the permissions of the source file
		$sourcePermissions = fileperms($source);
		if ($sourcePermissions === false) {
			throw new Exception("Failed to retrieve permissions for source file: $source");
		}
	
		// Get the owner and group of the source file
		$sourceOwner = fileowner($source);
		$sourceGroup = filegroup($source);
		if ($sourceOwner === false || $sourceGroup === false) {
			throw new Exception("Failed to retrieve owner or group for source file: $source");
		}
	
		// Apply the permissions to the target file
		if (!chmod($target, $sourcePermissions & 0777)) {
			throw new Exception("Failed to apply permissions to target file: $target");
		}
	
		// Apply the owner to the target file
		if (!chown($target, $sourceOwner)) {
			throw new Exception("Failed to change owner of target file: $target");
		}
	
		// Apply the group to the target file
		if (!chgrp($target, $sourceGroup)) {
			throw new Exception("Failed to change group of target file: $target");
		}
	
		return true;
	}

	/**
	 * Update the license
	 * @param string $name
	 * @param int $server_id
	 * @param string $license
	 * @return bool
	 */
	public function updateLicense($name, $server_id, $license) {
		global $app;

		// check name with regex
		if (!preg_match('/^[a-zA-Z0-9\-]+$/', $name)) {
			$this->addError('Invalid extension name.');
			return false;
		}

		// check license
		if (!empty($license) && !preg_match('/^[a-zA-Z0-9\-]+$/', $license)) {
			$this->addError('Invalid license.');
			return false;
		}

		// check if extension is installed
		if(!is_dir($this->extension_basedir.'/'.$name)) {
			$this->addError('Extension - '.$name.' - is not installed.');
			return false;
		}

		// write license file
		$license_file = $this->extension_basedir.'/'.$name.'/license';
		file_put_contents($license_file, $license);
		chmod($license_file, 0640);
		chown($license_file, 'ispconfig');
		chgrp($license_file, 'ispconfig');

		$app->log('License updated for extension - '.$name.' - on server - '.$server_id.' -', LOGLEVEL_DEBUG);

		// scan extension directory
		$this->scan_extensions();

		return true;
	}

	/**
	 * Get the license
	 * @param string $name
	 * @param int $server_id
	 * @return string
	 */
	public function getLicense($name, $server_id) {
		global $app;

		// check name with regex
		if (!preg_match('/^[a-zA-Z0-9\-]+$/', $name)) {
			$this->addError('Invalid extension name.');
			return false;
		}

		// check if extension is installed
		if(!is_dir($this->extension_basedir.'/'.$name)) {
			$this->addError('Extension - '.$name.' - is not installed.');
			return false;
		}

		// read license file
		$license_file = $this->extension_basedir.'/'.$name.'/license';
		if (!file_exists($license_file)) {
			$this->addError('License file - '.$license_file.' - does not exist.');
			return false;
		}

		$app->log('License read for extension - '.$name.' - on server - '.$server_id.' -', LOGLEVEL_DEBUG);

		return file_get_contents($license_file);
	}

	/**
	 * Delete the license
	 * @param string $name
	 * @param int $server_id
	 * @return bool
	 */
	public function deleteLicense($name, $server_id) {
		global $app;

		// check name with regex
		if (!preg_match('/^[a-zA-Z0-9\-]+$/', $name)) {
			$this->addError('Invalid extension name.');
			return false;
		}

		// check if extension is installed
		if(!is_dir($this->extension_basedir.'/'.$name)) {
			$this->addError('Extension - '.$name.' - is not installed.');
			return false;
		}

		// delete license file
		$license_file = $this->extension_basedir.'/'.$name.'/license';
		if (!file_exists($license_file)) {
			$this->addError('License file - '.$license_file.' - does not exist.');
			return false;
		}

		unlink($license_file);
		
		$app->log('License deleted for extension - '.$name.' - on server - '.$server_id.' -', LOGLEVEL_DEBUG);

		// scan extension directory
		$this->scan_extensions();

		return true;
	}

	/**
	 * Get the list of available extensions from the repository
	 * @return array
	 */
	public function getRepoExtensions() {
		if(empty($this->repo_cache)) {
			$context = stream_context_create(array('http' => array('timeout' => 30)));
			$response = @file_get_contents($this->getRepoListUrl(), false, $context);
			if (empty($response)) {
				return [];
			} else {
				$this->repo_cache = json_decode($response, true);
			}
		}
		
		return $this->repo_cache;
	}

	/**
	 * Get the repository extension
	 * @param string $name
	 * @return array|null
	 */
	public function getRepoExtension($name) {
		$repo_extensions = $this->getRepoExtensions();
		
		$repo_extension = array_filter($repo_extensions, function($ext) use ($name) {
			return $ext['name'] === $name;
		});

		if(!empty($repo_extension)) {
			return reset($repo_extension);
		} else {
			return null;
		}
	}

	/**
	 * Check if the extension is installed
	 * @param string $name
	 * @return bool
	 */
	public function isExtensionInstalled($name) {
		if(!is_dir($this->extension_basedir.'/'.$name)) {
			return false;
		}
		return true;
	}

}