module log4v

// import log4v as log // when using from the repository
import log { level_from_tag } // for testing some interoperability with it
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
	log_as_logger, log_processing_thread := new_log4v_as_logger()
	assert typeof(log_as_logger).name == '&log.Logger'
	assert typeof(log_processing_thread).name == 'thread' // or thread(void)

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

fn logging_statements_example(name string, mut l Log4v) {
	println('---- $name common logging statements begin ----')

	// call some log methods, but see output when run this source normally (not as a test)
	l.info('info message')
	l.warn('warning message')
	l.error('error message')
	l.debug('no output for debug')
	l.set_level(.debug) // this requires logger instance to be mutable
	l.debug('debug message now')
	l.trace('trace message, available only when specifying compilation flag debug, so: `v -d debug ...`')
	assert true

	// testing some interoperability with V log module
	l.set_level(level_from_tag('INFO') or { log.Level.disabled }) // set level from string, sample
	l.info('info message again, decode level from log')
	l.set_level(level_from_tag('') or { log.Level.disabled }) // set level from string, sample
	l.error('no output anymore, decode level from log')
	assert true

	// testing same features but from log4v module
	l.set_level(level_from_string('INFO') or { log.Level.disabled }) // set level from string, sample
	l.info('info message again, decode level from current module')
	l.set_level(level_from_string('') or { log.Level.disabled }) // set level from string, sample
	l.error('no output anymore, decode level from current module')
	assert true

	// as a sample, add a call even to panic, so keep commented
	// l.fatal('fatal') // panic, next statements won't be executed
	// next lines must be commented, to avoid compilatio error (after panic no statements won't be executed)
	// l.set_level(.info)
	// l.warn('warn message')

	println('---- $name common logging statements end   ----')
}

fn test_logger_flow_simple() {
	println(@FN + ' ' + 'test a minimal flow/usage of a new Log4v instance using all defaults')

	// create a new log4v instance
	// mutable because here (once created) I will change options like log level etc ...
	mut l := new_log4v()
	// start async management of logs output
	lp := go l.start()
	// l.set_processing_thread_reference(lp) // future work
	println(@FN + ' DEBUG - $lp.str()') // log processing thread is a thread(void)
	// exit at the given timeout, to avoid wait forever
	// go exit_after_timeout(10)
	// exit_logger_after_timeout(lp, 10) // temp, logger seems to do nothing, but timeout works ...
	// go exit_logger_after_timeout(lp, 10)  // temp, logger works (partially) but exit before the timeout ...

	// log statements, moved in its own utility function for better reuse across tests
	logging_statements_example(@FN, mut l)
	assert true
}


fn test_logger_flow_full() {
	println(@FN + ' ' + 'test a minimal flow/usage of a new Log4v instance')

	// create a new log4v instance
	// mutable because here (once created) I will change options like log level etc ...
	// note the debug level set here (more output expected respect to previous test case)
	mut l := new_log4v_full('log4v full options', .debug, format_message_default, messages_buffer_default)
	// start async management of logs output
	lp := go l.start()
	// l.set_processing_thread_reference(lp) // future work
	println(@FN + ' DEBUG - $lp.str()') // log processing thread is a thread(void)

	logging_statements_example(@FN, mut l)
	assert true
}

fn test_logger_flow_full_and_start() {
	println(@FN + ' ' + 'test a minimal flow/usage of a new Log4v instance, with async log processing automatically started')

	// create a new log4v instance, with async log processing automatically started
	// mutable because here (once created) I will change options like log level etc ...
	// note the debug level set here (more output expected respect to previous test case)
	mut l, lp := new_log4v_full_start('log4v full options', .debug, format_message_default, messages_buffer_default)
	// l.set_processing_thread_reference(lp) // future work
	println(@FN + ' DEBUG - $lp.str()') // log processing thread is a thread(void)

	logging_statements_example(@FN, mut l)
	assert true
}

// TODO: test logger by providing a custom LogFormatter ...

// TODO: more tests ...
