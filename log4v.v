module log4v

// reuse some standard definitions from V integrated log module
// note that many methods are similar (as much as possible) to those in V integrated log module
import log { Level, Logger, level_from_tag }
import time

pub const (
	version = '0.1'
)

// Log4v represents a logging object
pub struct Log4v {
	ch chan string // unbuffered (sync)
	// ch chan string{cap: buf_len} // buffered (async)
	formatter LogFormatter = format_message
	// appender LogAppender[] TODO: ...
mut:
	level         Level  = .info
	name          string = 'log4v'
	processed_tot int // TODO: check if keep ...
}

// LogFormatter defines a generic log formatter function
pub type LogFormatter = fn (name string, text string, level Level) string

// TODO: add Config, etc .. wip

// new_log4v_as_logger create and return a new Log4v instance, as a generic Logger implementation
pub fn new_log4v_as_logger() Logger {
	return Log4v{}
}

// TODO: check if rename to 'new' only ... wip
// new_log4v create and return a new Log4v instance
pub fn new_log4v() &Log4v {
	return &Log4v{}
}

// TODO: add other constructor versions ... wip

// level_from_string returns the log level from the given string if matches
// This function calls 'level_from_tag' in log module, 
// for better compliance and reuse of code.
pub fn level_from_string(s string) ?Level {
	return log.level_from_tag(s)
}

// level_to_string returns a label for log level `l` as a string.
fn level_to_string(l Level) string {
	return match l {
		.disabled { '     ' }
		.fatal { 'FATAL' }
		.error { 'ERROR' }
		.warn { 'WARN ' }
		.info { 'INFO ' }
		.debug { 'DEBUG' }
	}
}

// format_message format the given log name/context `name`, message `s` and level `level` with the log format set in the logger
// This is default implementation of LogFormatter for Log4v formatter.
fn format_message(name string, s string, level Level) string {
	now := time.now().format_ss_milli()
	mut msg := if name.len > 0 { '$name | ' } else { '' }
	return msg + '${level_to_string(level)} | $now | $s'
	// TODO: later add variables in the format, then check if use sprintf or similar ...
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

// close closes the log file
pub fn (l Log4v) close() {
	// close the channel
	l.ch.close()
	// close all appenders (where needed)
	// TODO: ...
}

// send_message writes log message `s` to the log buffer
// to be consumed by all log appenders
// note that the log message must already be formatted
fn (l Log4v) send_message(s string) {
	l.ch <- s
}

// start get (process) log messages from logger channel and send to all log appenders
// It must be called asynchronously
fn (mut l Log4v) start() {
	for { // loop forever // TODO: later check for an exit condition ...
		msg := <-l.ch
		$if debug ? {
			// l.processed_tot++
			// println('$l.processed_tot : $msg') // temp
			println(msg) // temp // TODO: check with V guys for process stuck after first message even in this case ... wip
		} $else {
			println(msg) // temp
		}
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
