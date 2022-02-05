module log4v

// reuse some standard definitions from V integrated log module
// note that many methods are similar (as much as possible) to those in V integrated log module
import log { Level, Logger, level_from_tag }
import time

// version library version
pub const version = '0.1'

pub const messages_buffer_default = 1000

// Log4v represents a logging object
pub struct Log4v {
	formatter   LogFormatter = format_message_default
	// appender LogAppender[] TODO: ...
mut:
	level         Level  = .info
	name          string
	ch            chan string
	processed_tot u64
}

// LogFormatter defines a generic log formatter function
pub type LogFormatter = fn (name string, text string, level Level) string

// TODO: add pub LogConfig and update factory functions ... wip

// new_log4v create and return a new Log4v instance
// start must be called manually to let the instance process log messages
pub fn new_log4v() &Log4v {
	return &Log4v{}
}

// new_log4v_full create and return a new Log4v instance by specifying some logger settings
// start must be called manually to let the instance process log messages
pub fn new_log4v_full(name string, level Level, formatter LogFormatter, messages_buffer_len int) &Log4v {
	ch := chan string{cap: messages_buffer_len}
	return &Log4v{
		name: name
		formatter: formatter
		level: level
		ch: ch
	}
}

// new_log4v_full_start create, start and return a new Log4v instance by specifying some logger settings
pub fn new_log4v_full_start(name string, level Level, formatter LogFormatter, messages_buffer_len int) (&Log4v, thread) {
	mut log := new_log4v_full(name, level, formatter, messages_buffer_len)
	t := go log.start()
	return log, t
}

// new_log4v_as_logger create, start and return a new Log4v instance, as a generic Logger implementation
pub fn new_log4v_as_logger() (&Logger, thread) {
	mut log := &Log4v{ name: 'logger' }
	t := go log.start()
	return log, t
}

// new_log4v_as_logger_full_start create, start and return a new Log4v instance, as a generic Logger implementation
pub fn new_log4v_as_logger_full_start(name string, level Level, formatter LogFormatter, messages_buffer_len int) (&Logger, thread) {
	mut log := new_log4v_full(name, level, formatter, messages_buffer_len)
	t := go log.start()
	return log, t
}

// TODO: add LogConfig and maybe another constructor version to set it ... wip

// level_from_string returns the log level from the given string if matches
// This function calls 'level_from_tag' in log module,
// for better compliance and reuse of code.
pub fn level_from_string(s string) ?Level {
	return level_from_tag(s)
}

// level_to_string returns a label for log level `l` as a string.
[inline] // reordered in inverse order and inlined for better performances
fn level_to_string(l Level) string {
	return match l {
		.disabled { '' }
		.debug { 'DEBUG' }
		.info { 'INFO' }
		.warn { 'WARN' }
		.error { 'ERROR' }
		.fatal { 'FATAL' }
	}
}

// format_message_default format the given log name/context `name`, message `s` and level `level` with the log format set in the logger
// This is default implementation of LogFormatter for Log4v formatter.
[inline] // inlined for better performances
pub fn format_message_default(name string, s string, level Level) string {
	now := time.now().format_ss_milli()
	mut msg := if name.len > 0 { '$name | ' } else { '' }
	return msg + '$now | ${level_to_string(level):-5s} | $s'
}

// get_level gets the internal logging level
pub fn (mut l Log4v) get_level() Level {
	return l.level
}

// set_level sets the internal logging to `level`
pub fn (mut l Log4v) set_level(level Level) {
	l.level = level
}

// flush writes the log file content to disk
pub fn (l Log4v) flush() {
	// TODO: check if it makes sense here, and if yes, how to flush the channel (and continue to send messages to it, later) ...
}

// close closes log channel and appenders resources
pub fn (l Log4v) close() {
	// close the channel
	l.ch.close()
	// close all appenders (where needed)
	// TODO: wait for all messages to flush ...
	// some closing info
	$if debug {
		now := time.now().format_ss_milli()
		println('Log4v instance stopped at $now , details: $l')
	}
	l.print_processed_log_messages() // in debug mode, print total number of messages logged
}

// close_stop closes log channel and appenders resources
// and stop processing messages thread and others (if any)
pub fn (l Log4v) close_stop(t thread) {
	l.close()
	// t.stop() // TODO: check if it's the right way ...
}

// send_message writes log message `s` to the log buffer
// to be consumed by all log appenders
// note that the log message must already be formatted
fn (l Log4v) send_message(s string) {
	l.ch <- s
}

// start get (process) log messages from logger channel and send to all log appenders
// It must be called asynchronously
pub fn (mut l Log4v) start() {
	$if debug {
		l.processed_tot = 0
		now := time.now().format_ss_milli()
		println('Log4v instance started at $now , details: $l')
	}
	for { // loop forever, until channel is closed
		msg := <-l.ch or { return }
		$if debug {
			l.processed_tot++
		}
		println(msg)
		// TODO: send to all log appenders ...
	}
}

// fatal logs the given message if `Log.level` is greater than or equal to the `Level.fatal` category
// Note that this method performs a panic at the end, even if log level is not enabled.
[noreturn]
pub fn (l Log4v) fatal(s string) {
	if int(l.level) >= int(Level.fatal) {
		msg := l.formatter(l.name, s, Level.fatal)
		l.send_message(msg)
	}
	panic('$l.name: $s')
}

// error logs the given message if `Log.level` is greater than or equal to the `Level.error` category
pub fn (l Log4v) error(s string) {
	// println('DEBUG: ' + @FN) // temp, only during development/debugging
	if int(l.level) < int(Level.error) {
		return
	}
	msg := l.formatter(l.name, s, Level.error)
	l.send_message(msg)
}

// warn logs the given message if `Log.level` is greater than or equal to the `Level.warn` category
pub fn (l Log4v) warn(s string) {
	if int(l.level) < int(Level.warn) {
		return
	}
	msg := l.formatter(l.name, s, Level.warn)
	l.send_message(msg)
}

// info logs the given message if `Log.level` is greater than or equal to the `Level.info` category
pub fn (l Log4v) info(s string) {
	if int(l.level) < int(Level.info) {
		return
	}
	// format the string and send to channel
	msg := l.formatter(l.name, s, Level.info)
	l.send_message(msg)
}

// debug logs the given message if `Log.level` is greater than or equal to the `Level.debug` category
pub fn (l Log4v) debug(s string) {
	if int(l.level) < int(Level.debug) {
		return
	}
	msg := l.formatter(l.name, s, Level.debug)
	l.send_message(msg)
}

// trace logs the given message if `Log.level` is greater than or equal to the `Level.debug` category
// logging level here is the same of debug (a new '.trace' level is not really needed)
// but note that this function is available only when compiling with the 'debug' flag
[if debug]
pub fn (l Log4v) trace(s string) {
	if int(l.level) < int(Level.debug) {
		return
	}
	msg := l.formatter(l.name, s, Level.debug)
	l.send_message(msg)
}

// processed_log_messages return the total number of log messages processed since started
// but note that this function is available only when compiling with the 'debug' flag
[if debug]
pub fn (l Log4v) print_processed_log_messages() {
	println('Log4v instance processed $l.processed_tot messages since started')
}
