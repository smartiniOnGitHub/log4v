module main

import os
import flag
import log { Log, Logger }
import log4v { Log4v }
import runtime
import time

const app_name = 'log4v_benchmark_example'

const cpu_tot = runtime.nr_jobs()

const repeat_default = 1_000 // 1

const delay_in_sec_default = 1

fn logging_statements_example_for_v_log(name string, mut l Log, repeat int) {
	println('---- $name logging statements for v log (repeated $repeat times): begin ----')

	// repeat more times
	for i in 0 .. repeat {
		// call some log methods
		l.info('$name: info message $i')
		l.warn('$name: warning message $i')
		l.error('$name: error message $i')
		l.debug('$name: no output for debug $i') // no output for this here
		// l.set_level(.debug) // this requires logger instance to be mutable
		l.debug('$name: debug message now $i') // no output for this here because current level does not enable it
	}

	println('---- $name logging statements for v log (repeated $repeat times): end   ----')
}

fn logging_statements_example_for_logger(name string, l Logger, repeat int) {
	println('---- $name logging statements for logger (repeated $repeat times): begin ----')

	// repeat more times
	for i in 0 .. repeat {
		// call some log methods
		l.info('$name: info message $i')
		l.warn('$name: warning message $i')
		l.error('$name: error message $i')
		l.debug('$name: no output for debug $i') // no output for this here
		// l.set_level(.debug) // this requires logger instance to be mutable // disabled because not available in Logger
		l.debug('$name: debug message now $i') // no output for this here because current level does not enable it
		// l.trace('$name: trace message $i, available only when specifying compilation flag debug, so: `v -d debug ...`') // disabled because not available in Logger
	}

	println('---- $name logging statements for logger (repeated $repeat times): end   ----')
}

fn logging_statements_example_for_log4v(name string, mut l Log4v, repeat int) {
	println('---- $name logging statements for log4v (repeated $repeat times): begin ----')

	// repeat more times
	for i in 0 .. repeat {
		// call some log methods
		l.info('$name: info message $i')
		l.warn('$name: warning message $i')
		l.error('$name: error message $i')
		l.debug('$name: no output for debug $i') // no output for this here
		l.set_level(.debug) // this requires logger instance to be mutable
		l.debug('$name: debug message now $i')
		l.trace('$name: trace message $i, available only when specifying compilation flag debug, so: `v -d debug ...`') // by default not available
	}

	println('---- $name logging statements for log4v (repeated $repeat times): end   ----')
}

fn run_v_log_benchmark(repeat int, num_threads int) time.Duration {
	mut threads := []thread{}
	mut sw := time.new_stopwatch()

	// create and return a new Log instance, but as a generic Logger implementation
	// mut logger := log.Log{}
	// logger.set_level(.info) // set here level and not in constructor only to have it mutable here, but it's not really needed ...
	// update: to have Log as generic Logger is must be not mutable (per current definition), but to use directly as Log it must be mutable
	mut logger := &Log{
		level: .info
	} // reference needed for its parallel usage

	// test in multi-thread
	for i in 0 .. num_threads {
		// logging_statements_example_for_logger('v log as logger on thread#$i', logger, repeat)
		// threads << go logging_statements_example_for_logger('v log as logger on thread#$i', logger, repeat)
		// TODO: check with V guys if update Logger definitions to be for mutable instances, or if update logger methods to not require mutable instance ... wip

		// in the meantime use this
		// logging_statements_example_for_v_log('v log on thread#$i', mut logger, repeat)
		threads << go logging_statements_example_for_v_log('v log on thread#$i', mut logger,
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

fn run_log4v_as_logger_benchmark(repeat int, num_threads int) time.Duration {
	mut threads := []thread{}
	mut sw := time.new_stopwatch()

	// create and return a new Log4v instance, as a generic Logger implementation
	mut logger, logger_thread := log4v.new_log4v_as_logger()
	println(@FN + ' DEBUG - $logger_thread.str()') // log processing thread is a thread(void)

	// test in multi-thread
	for i in 0 .. num_threads {
		logging_statements_example_for_logger('log4v as logger on thread#$i', logger, repeat)
		// TODO: compilation error (C error on generated sources) on the following line (`error: cannot convert 'struct log__Logger *' to 'struct log__Logger'`), check with V guys ... wip
		// threads << go logging_statements_example_for_logger('log4v as logger on thread#$i', logger, repeat)
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

fn run_log4v_benchmark(repeat int, num_threads int) time.Duration {
	mut threads := []thread{}
	mut sw := time.new_stopwatch()

	// create and return a new Log4v instance
	mut log4v, log4v_thread := log4v.new_log4v_full_start('log4v full options', .info, log4v.format_message_default, log4v.messages_buffer_default)
	println(@FN + ' DEBUG - $log4v_thread.str()') // log processing thread is a thread(void)

	// test in multi-thread
	for i in 0 .. num_threads {
		// logging_statements_example_for_log4v('log4v on thread#$i', mut log4v, repeat)
		threads << go logging_statements_example_for_log4v('log4v on thread#$i', mut log4v,
			repeat)
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

// relative_performance_percentage utility function to calculate relative performance percentage of given value and reference (baseline)
fn relative_performance_percentage(value i64, reference i64) f32 {
	mut res := f32(0.0)
	// dump(value)
	// dump(reference)
	if reference == 0 { res = 100 }
	else {
		res = f32(value) / f32(reference) * f32(100.0)
	}

	return res
}

fn main() {
	// parse command-line flags
	mut fp := flag.new_flag_parser(os.args)
	fp.application(app_name)
	fp.version('1.0.0')
	fp.description('A sample CLI application that show usage of log4v and get some benchmarks.')
	fp.skip_executable()
	repeat := fp.int('repeat', `r`, repeat_default, 'The number of times to repeat messages output.')
	num_threads := fp.int('threads', `t`, cpu_tot + 1, 'The number of threads to use (found ${cpu_tot + 1} core).')
	delay := fp.int('delay', `d`, delay_in_sec_default, 'The number of seconds to wait after all tests, to let output flush.')
	additional_args := fp.finalize() ?
	if additional_args.len > 0 {
		println('Unprocessed arguments:\n$additional_args.join_lines()')
	}

	// log benchmark in a multi-threaded console app
	v_log_elapsed := run_v_log_benchmark(repeat, num_threads) // define a baseline
	// verify log4v performances to be similar, or at least not too slow
	log4v_as_logger_elapsed := run_log4v_as_logger_benchmark(repeat, num_threads)
	log4v_elapsed := run_log4v_benchmark(repeat, num_threads)

	time.sleep(delay * time.second)
	println(@FN + 'Add a little delay ($delay sec), to let ouput completes...')

	println(@FN + ' Benchmark - results')
	println(@FN + ' Benchmark - num cpu: ${cpu_tot + 1}') // because it starts from 0 for the first
	println(@FN +
		' Benchmark - each test is repeated $repeat times, and executed on $num_threads parallel threads')
	println(@FN + ' elapsed time for v log: ${v_log_elapsed.milliseconds()}ms, relative performance: 100% (use as baseline)')
	println(@FN + ' elapsed time for log4v as logger: ${log4v_as_logger_elapsed.milliseconds()}ms, relative performance: ${relative_performance_percentage(log4v_as_logger_elapsed.milliseconds(), v_log_elapsed.milliseconds()):-4.2}%')
	println(@FN + ' elapsed time for log4v: ${log4v_elapsed.milliseconds()}ms, relative performance: ${relative_performance_percentage(log4v_elapsed.milliseconds(), v_log_elapsed.milliseconds()):-4.2}%')

	println(@FN + ' Benchmark - end')
}
