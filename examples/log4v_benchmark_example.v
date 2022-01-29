module main

import log { Log, Logger }
import time
import log4v { Log4v }
import runtime

const cpu_tot = runtime.nr_jobs()

const repeat = 1000

// TODO: add a constant with some long text (but single line) ... wip

fn logging_statements_example_for_v_log(name string, mut l Log, repeat int) {
	println('---- $name logging statements for v log (repeated $repeat times): begin ----')

	// repeat more times
	for i in 0 .. repeat {
		// call some log methods
		l.info('info message $i')
		l.warn('warning message $i')
		l.error('error message $i')
		l.debug('no output for debug $i') // not output for this here
		// l.set_level(.debug) // this requires logger instance to be mutable
		l.debug('debug message now $i') // not output for this here because current level does not enable it
	}

	println('---- $name logging statements for v log (repeated $repeat times): end   ----')
}

fn logging_statements_example_for_logger(name string, l Logger, repeat int) {
	println('---- $name logging statements for logger (repeated $repeat times): begin ----')

	// repeat more times
	for i in 0 .. repeat {
		// call some log methods
		l.info('info message $i')
		l.warn('warning message $i')
		l.error('error message $i')
		l.debug('no output for debug $i') // not output for this here
		// l.set_level(.debug) // this requires logger instance to be mutable // disabled because not available in Logger
		l.debug('debug message now $i') // not output for this here because current level does not enable it
		// l.trace('trace message, available only when specifying compilation flag debug, so: `v -d debug ...`') // disabled because not available in Logger
	}

	println('---- $name logging statements for logger (repeated $repeat times): end   ----')
}

fn logging_statements_example_for_log4v(name string, mut l Log4v, repeat int) {
	println('---- $name logging statements for log4v (repeated $repeat times): begin ----')

	// repeat more times
	for i in 0 .. repeat {
		// call some log methods
		l.info('info message $i')
		l.warn('warning message $i')
		l.error('error message $i')
		l.debug('no output for debug $i') // not output for this here
		l.set_level(.debug) // this requires logger instance to be mutable
		l.debug('debug message now $i')
		l.trace('trace message, available only when specifying compilation flag debug, so: `v -d debug ...`')
	}

	println('---- $name logging statements for log4v (repeated $repeat times): end   ----')
}

fn run_v_log_benchmark() time.Duration {
	mut threads := []thread{}
	mut sw := time.new_stopwatch()

	// create and return a new Log instance, but as a generic Logger implementation
	// mut logger := log.Log{}
	// logger.set_level(.info) // set here level and not in constructor only to have it mutable here, but it's not really needed ...
	// update: to have Log as generic Logger is must be not mutable (per current definition), but to use directly as Log it must be mutable
	mut logger := &Log{
		level: .info
	} // reference needed for its parallel usage

	// test in multi-thread, one per available cpu
	for i in 0 .. cpu_tot + 1 {
		// logging_statements_example_for_logger('v log as logger on cpu#$i', logger, repeat)
		// threads << go logging_statements_example_for_logger('v log as logger on cpu#$i', logger, repeat)
		// TODO: check with V guys if update Logger definitions to be for mutable instances, or if update logger methods to not require mutable instance ... wip

		// in the meantime use this
		// logging_statements_example_for_v_log('v log on cpu#$i', mut logger, repeat)
		threads << go logging_statements_example_for_v_log('v log on cpu#$i', mut logger,
			repeat)
		// later comment this block
	}
	threads.wait()
	// println(@FN + ' DEBUG - All jobs finished!')
	// benchmark summary
	elapsed := sw.elapsed()
	println('Time took: ${elapsed.nanoseconds()}ns, or ${elapsed.milliseconds()}ms, or ${elapsed.seconds():1.3f}sec')
	println('----')

	// sw.restart()
	// do other tests ...

	return elapsed
}

fn run_log4v_as_logger_benchmark() time.Duration {
	mut threads := []thread{}
	mut sw := time.new_stopwatch()

	// create and return a new Log4v instance, as a generic Logger implementation
	mut logger, logger_thread := log4v.new_log4v_as_logger()
	println(@FN + ' DEBUG - $logger_thread.str()') // log processing thread is a thread(void)

	// test in multi-thread, one per available cpu
	for i in 0 .. cpu_tot + 1 {
		logging_statements_example_for_logger('log4v as logger on cpu#$i', logger, repeat)
		// TODO: compilation error (C error on generated sources) on the following line (`error: cannot convert 'struct log__Logger *' to 'struct log__Logger'`), check with V guys ... wip
		// threads << go logging_statements_example_for_logger('log4v as logger on cpu#$i', logger, repeat)
	}
	threads.wait()
	// println(@FN + ' DEBUG - All jobs finished!')
	// benchmark summary
	elapsed := sw.elapsed()
	println('Time took: ${elapsed.nanoseconds()}ns, or ${elapsed.milliseconds()}ms, or ${elapsed.seconds():1.3f}sec')
	println('----')

	// TODO: to close current benchmark test, check how to let the logger stop its thread (as argument to its method close) ... wip

	// sw.restart()
	// do other tests ...

	return elapsed
}

// TODO: add a benchmark even to both loggers when level is set to disabled ... wip

fn main() {
	// log benchmark in a multi-threaded console app
	v_log_elapsed := run_v_log_benchmark() // define a baseline
	log4v_elapsed := run_log4v_as_logger_benchmark() // verify to be similar, or at least not too slow

	// TODO: add other log4v benchmarks (not as logger, etc) ... wip

	println(@FN + ' Benchmark - results')
	println(@FN + ' Benchmark - num cpu: ${cpu_tot + 1}') // because it starts from 0 for first cpu
	println(@FN +
		' Benchmark - each test is repeated $repeat times, and spread across all available cpu')
	println(@FN + ' elapsed time for v log: ${v_log_elapsed.milliseconds()}ms')
	println(@FN + ' elapsed time for log4v: ${log4v_elapsed.milliseconds()}ms')

	println(@FN + ' Benchmark - end')
}
