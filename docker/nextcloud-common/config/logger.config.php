<?php
	# Don't write logs to file shares; output the data to the Pod log.
	$CONFIG = array(
		'log_type' => 'syslog',
		"logfile" => '',
		"loglevel" => 2,
	);
