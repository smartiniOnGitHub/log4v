module log4v

// import log4v as log // when using from the repository

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
	assert typeof(log).name == '.Log4v'
}

fn test_logger_flow_simple() {
	println(@FN + ' ' + 'test a minimal flow/usage of a new Log4v instance using all defaults')

	mut l := new_log4v()
	lp := go l.process_logs() // start async management of logs output
	defer { l.close() }
	// call some log methods, but see output when run this source normally (not as a test)
	l.info('info message')
	l.warn('warning message')
	l.error('error message')
	l.debug('no output for debug')
	l.set_level(.debug) // this requires logger instance to be mutable
	l.debug('debug message now')
	// TODO: add others like level from tag string, panic, etc ... wip

	// lp.wait() // need to wait // TODO: find the right way, or with a timeout here ... wip
	assert true
}
