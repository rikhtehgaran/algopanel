-- Store the process id of the cron run that started a cron job, so that a job which is still marked
-- as running after its cron run has died can be detected and started again.
ALTER TABLE `sys_cron` ADD COLUMN `pid` int(11) unsigned NULL DEFAULT NULL;

-- Release cron job locks that were left behind by an aborted cron run and that could not be
-- released automatically because no start time had been recorded for the job.
UPDATE `sys_cron` SET `running` = 0 WHERE `running` = 1 AND `last_run` IS NULL;
