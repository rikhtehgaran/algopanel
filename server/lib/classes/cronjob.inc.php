<?php

/*
Copyright (c) 2013, Marius Cramer, pixcept KG
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

class cronjob {

	// default is every 5 minutes
	protected $_schedule = '*/5 * * * *';

	// may a run be skipped?
	protected $_no_skip = false;

	// if true, this job is run when it is first recognized. If false, the next run is calculated from schedule on first run.
	protected $_run_at_new = false;

	// maximum expected run time of this job in seconds. It is used to release the lock of a job that is still
	// marked as running although the cron run that started it has died, but only when the process that started
	// the job is not known (e.g. for jobs that were started by a previous ISPConfig version). Jobs that may run
	// for an arbitrarily long time, like backups, should set this to 0 to disable the timeout.
	protected $_max_runtime = 3600;

	protected $_last_run = null;
	protected $_next_run = null;
	private $_running = false;
	private $_pid = null;

	// name of the job that is currently marked as running, used by the shutdown handler
	private static $_running_job = null;
	private static $_shutdown_registered = false;

	// services for delayed restart/reload
	private $_delayed_restart_services = array();

	/** return schedule */


	public function getSchedule() {
		global $app, $conf;
		
		$class = get_class($this);
		
		switch ($class) {
			case 'cronjob_backup':
				$app->uses('ini_parser,getconf');
				$server_id = $conf['server_id'];
				$server_conf = $app->getconf->get_server_config($server_id, 'server');
				if(isset($server_conf['backup_time']) && $server_conf['backup_time'] != ''){
					list($hour, $minute) = explode(':', $server_conf['backup_time']);
					$schedule = $minute.' '.$hour.' * * *';
				} else {
					$schedule = '0 0 * * *';
				}
				break;
			/*case 'cronjob_backup_mail':
				$schedule = '1 0 * * *';
				break;*/
			default:
				$schedule = $this->_schedule;
		}
		
		return $schedule;
	}



	/** run through cronjob sequence **/
	public function run($debug_mode = false) {
		global $conf;
		
		if($conf['log_priority'] <= LOGLEVEL_DEBUG) print "Called run() for class " . get_class($this) . "\n";
		if($conf['log_priority'] <= LOGLEVEL_DEBUG) print "Job has schedule: " . $this->getSchedule() . "\n";
		$this->onPrepare();
		$run_it = $this->onBeforeRun();
		if($run_it == true || $debug_mode === true) {
			$this->onRunJob();
			$this->onAfterRun();
			$this->onCompleted();
		}

		return;
	}

	/* this function prepares some data for the job and sets next run time if first executed */
	protected function onPrepare() {
		global $app, $conf;

		if($conf['log_priority'] <= LOGLEVEL_DEBUG) print "Called onPrepare() for class " . get_class($this) . "\n";
		// check the run time and values for this job

		// release the lock of a job that is still marked as running although the cron run that started it has died
		$this->_releaseStaleLock();

		// get previous run data
		$data = $app->db->queryOneRecord("SELECT `last_run`, `next_run`, `running`, `pid` FROM `sys_cron` WHERE `name` = ?", get_class($this));
		if($data) {
			if($data['last_run']) $this->_last_run = $data['last_run'];
			if($data['next_run']) $this->_next_run = $data['next_run'];
			if($data['running'] == 1) $this->_running = true;
			if($data['pid']) $this->_pid = $app->functions->intval($data['pid']);
		}
		if(!$this->_next_run) {
			if($this->_run_at_new == true) {
				$this->_next_run = ISPConfigDateTime::dbtime(); // run now.
			} else {
				$app->cron->parseCronLine($this->getSchedule());
				$next_run = $app->cron->getNextRun(ISPConfigDateTime::dbtime());
				$this->_next_run = $next_run;

				$app->db->query("REPLACE INTO `sys_cron` (`name`, `last_run`, `next_run`, `running`, `pid`) VALUES (?, ?, ?, ?, ?)", get_class($this), ($this->_last_run ? $this->_last_run : "#NULL#"), ($next_run === false ? "#NULL#" : $next_run), ($this->_running == true ? "1" : "0"), ($this->_running == true && $this->_pid ? $this->_pid : "#NULL#"));
			}
		}
	}

	/* this function releases the running lock of this job if it was left behind by an aborted cron run */
	private function _releaseStaleLock() {
		global $app, $conf;

		$max_runtime = $app->functions->intval($this->_max_runtime);
		$data = $app->db->queryOneRecord("SELECT `last_run`, `pid`, IF(`last_run` IS NOT NULL AND `last_run` < DATE_SUB(NOW(), INTERVAL " . $max_runtime . " SECOND), 1, 0) as `timed_out` FROM `sys_cron` WHERE `name` = ? AND `running` = 1", get_class($this));
		if(!$data) return;

		// check if the cron run that started the job is still alive, null means that we were not able to find out
		$process_alive = null;
		if($data['pid']) $process_alive = $this->_isCronProcessAlive($app->functions->intval($data['pid']));

		$reason = '';
		if($data['last_run'] === null) {
			// a job that is marked as running without a start time can never time out, so it has to be treated as stale
			$reason = 'no start time recorded';
		} elseif($process_alive === false) {
			// only one cron run is executed at a time, so the job cannot be running anymore if its process is gone
			$reason = 'process ' . $data['pid'] . ' is not running anymore';
		} elseif($process_alive !== true && $max_runtime > 0 && $data['timed_out'] == 1) {
			// we cannot tell if the job is still running, so we have to rely on the maximum run time
			$reason = 'started at ' . $data['last_run'] . ', maximum run time of ' . $max_runtime . ' seconds exceeded';
		}
		if($reason == '') return;

		$app->db->query("UPDATE `sys_cron` SET `running` = 0, `pid` = NULL WHERE `name` = ? AND `running` = 1", get_class($this));
		$app->log('Released stale cron lock of ' . get_class($this) . ' (' . $reason . ').', LOGLEVEL_WARN);
		if($conf['log_priority'] <= LOGLEVEL_WARN) print "Released stale cron lock of " . get_class($this) . " (" . $reason . ").\n";
	}

	/* this function checks if the given process id still belongs to a running cron script.
	   It returns null if that could not be determined. */
	private function _isCronProcessAlive($pid) {
		if($pid < 1) return false;

		// without proc filesystem we cannot check the process
		if(!is_dir('/proc')) return null;
		if(!is_dir('/proc/' . $pid)) return false;

		// without the command line we cannot tell if the process id has been reused by another process
		if(!is_file('/proc/' . $pid . '/cmdline')) return null;
		$cmdline = @file_get_contents('/proc/' . $pid . '/cmdline');
		if($cmdline === false) return null;

		return (strpos($cmdline, 'cron.php') !== false || strpos($cmdline, 'cron_debug.php') !== false);
	}

	/* this function releases the lock of the job that was running when the cron run was aborted */
	public static function releaseRunningJobOnShutdown() {
		global $app;

		if(self::$_running_job === null) return;
		$name = self::$_running_job;
		self::$_running_job = null;

		// the cron run may have been aborted because the database is not reachable, so do not try to reconnect here
		if(!isset($app) || !is_object($app->db) || !$app->db->testConnection()) return;

		$app->db->query("UPDATE `sys_cron` SET `running` = 0, `pid` = NULL WHERE `name` = ?", $name);
		$app->log('Cron run was aborted while ' . $name . ' was running, released its lock.', LOGLEVEL_WARN);
	}

	/* this function checks if a cron job's next runtime is reached and returns true or false */
	protected function onBeforeRun() {
		global $app, $conf;

		if($conf['log_priority'] <= LOGLEVEL_DEBUG) print "Called onBeforeRun() for class " . get_class($this) . "\n";

		if($this->_running == true) return false; // job is still marked as running!

		if($conf['log_priority'] <= LOGLEVEL_DEBUG) print "Jobs next run is " . $this->_next_run . "\n";
		$reached = ISPConfigDateTime::compare($this->_next_run, ISPConfigDateTime::dbtime());
		if($conf['log_priority'] <= LOGLEVEL_DEBUG) print "Date compare of " . ISPConfigDateTime::to_timestamp($this->_next_run) . " and " . ISPConfigDateTime::dbtime() . " is " . $reached . "\n";
		if($reached === false) return false; // error!

		if($reached === -1) {
			// next_run time not reached
			return false;
		}

		// next_run time reached (reached === 0 or -1)

		// calculate next run time based on last_run or current time
		$app->cron->parseCronLine($this->getSchedule());
		if($this->_no_skip == true) {
			// we need to calculate the next run based on the previous next_run, as we may not skip one.
			$next_run = $app->cron->getNextRun($this->_next_run);
			if($next_run === false) {
				// we could not calculate next run, try it with current time
				$next_run = $app->cron->getNextRun(ISPConfigDateTime::dbtime());
			}
		} else {
			// calculate next run based on current time
			$next_run = $app->cron->getNextRun(ISPConfigDateTime::dbtime());
		}

		if($conf['log_priority'] <= LOGLEVEL_DEBUG) print "Jobs next run is now " . $next_run . "\n";

		$this->_pid = getmypid();
		$app->db->query("REPLACE INTO `sys_cron` (`name`, `last_run`, `next_run`, `running`, `pid`) VALUES (?, NOW(), ?, 1, ?)", get_class($this), ($next_run === false ? "#NULL#" : $next_run), ($this->_pid === false ? "#NULL#" : $this->_pid));

		// make sure the job does not stay marked as running if this cron run is aborted before onCompleted() is reached
		self::$_running_job = get_class($this);
		if(self::$_shutdown_registered == false) {
			register_shutdown_function(array('cronjob', 'releaseRunningJobOnShutdown'));
			self::$_shutdown_registered = true;
		}

		return true;
	}

	// child classes should override this!
	protected function onRunJob() {
		global $app, $conf;

		if($conf['log_priority'] <= LOGLEVEL_DEBUG) print "Called onRun() for class " . get_class($this) . "\n";
	}

	// child classes may override this!
	protected function onAfterRun() {
		global $app, $conf;

		if($conf['log_priority'] <= LOGLEVEL_DEBUG) print "Called onAfterRun() for class " . get_class($this) . "\n";

		if(is_array($this->_delayed_restart_services)) {
			foreach ($this->_delayed_restart_services as $service => $mode) {
				$this->restartService($service, $mode);
			}
		}
	}

	// child classes may NOT override this!
	protected function onCompleted() {
		global $app, $conf;

		if($conf['log_priority'] <= LOGLEVEL_DEBUG) print "Called onCompleted() for class " . get_class($this) . "\n";
		$app->db->query("UPDATE `sys_cron` SET `running` = 0, `pid` = NULL WHERE `name` = ?", get_class($this));
		$this->_pid = null;
		if(self::$_running_job === get_class($this)) self::$_running_job = null;
	}

	// child classes may NOT override this!
	protected function restartService($service, $action='restart') {
		global $app;

		$app->uses('system');

		$retval = array('output' => '', 'retval' => 0);
		if($action == 'reload') {
			exec($app->system->getinitcommand($service, 'reload').' 2>&1', $retval['output'], $retval['retval']);
		} else {
			exec($app->system->getinitcommand($service, 'restart').' 2>&1', $retval['output'], $retval['retval']);
		}
		return $retval;
	}

	// child classes may NOT override this!
	protected function restartServiceDelayed($service, $action='restart') {
		$action = ($action == 'reload' ? 'reload' : 'restart');

		if (is_array($this->_delayed_restart_services)) {
			$this->_delayed_restart_services[$service] = $action;
		}
	}

}

