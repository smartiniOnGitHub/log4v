module log4v

// import log4v as log // when using from the repository
import time

fn test_empty() {
	println(@FN + ' ' + 'first tests on Log4v, to ensure it only compiles')
	assert true
}

fn test_new_defaults() {
	println(@FN + ' ' + 'test creation of a new Log4v instance using all defaults')

	log_struct := Log4v{} // direct instancing the struct
	assert typeof(log_struct).name == '.Log4v'

	// create using factory and no arguments, but it returns a generig Logger
	log_as_logger := new_log4v_as_logger()
	assert typeof(log_as_logger).name == 'log.Logger'

	// create using factory and no arguments
	log := new_log4v() // when using from the same (current) repository
	// log := log4v.new_log4v()// when using from the repository
	assert typeof(log).name == '&.Log4v'
}

// exit_after_timeout utility function (to execute async) that exits at the given timeout
fn exit_after_timeout(timeout_in_sec int) {
	time.sleep(timeout_in_sec * time.second)
	println('exiting due to timeout ($timeout_in_sec sec)...')
	exit(0)
}

// exit_logger_after_timeout utility function (to execute async)
// that wait for the given logger and exits at the given timeout
fn exit_logger_after_timeout(t thread, timeout_in_sec int) {
	go exit_after_timeout(timeout_in_sec)
	t.wait()
}

fn test_logger_flow_simple() {
	println(@FN + ' ' + 'test a minimal flow/usage of a new Log4v instance using all defaults')

	mut l := new_log4v()

	/*
	// start async management of logs output
	// TODO: check/fix ... wip
	lp := go l.process_logs()
	defer {
		l.close()
		lp.wait() // need to wait // TODO: find the right way, or with a timeout here ... wip
	}
	 */
	// exit at the given timeout, to avoid wait forever
	lp := go l.process_logs()
	println(@FN + ' DEBUG - $lp.str()') // temp
	// go exit_after_timeout(10)
	// exit_logger_after_timeout(lp, 10) // temp, logger seems to do nothing, but timeout works ...
	// go exit_logger_after_timeout(lp, 10)  // temp, logger works (partially) but exit before the timeout ...

	// call some log methods, but see output when run this source normally (not as a test)
	l.info('info message')
	l.warn('warning message')
	l.error('error message')
	l.debug('no output for debug')
	l.set_level(.debug) // this requires logger instance to be mutable
	l.debug('debug message now')
	// TODO: add others like level from tag string, panic, etc ... wip

	assert true
}
