module log4v

// reuse some standard definitions from V integrated log module
// note that many methods are similar (as much as possible) to those in V integrated log module
import log { Level, Logger, level_from_tag }

pub const (
	version = '0.1'
)

// Log4v represents a logging object
pub struct Log4v {
	ch chan string // unbuffered (sync)
	// ch chan string{cap: buf_len} // buffered (async)
mut:
	level         Level  = .info
	name          string = 'log4v'
	processed_log int // TODO: check if keep ...
	// TODO: add formatters, appenders, etc ...
}

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

// format_message format the given log message `s` and level `level` with the log format set in the logger
fn (l Log4v) format_message(s string, level Level) string {
	// TODO: check if use sprintf or similar ...
	return '$l.name - $level - $s'
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
			// l.processed_log++
			// println('$l.processed_log : $msg') // temp
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
		msg := l.format_message(s, .fatal)
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
	msg := l.format_message(s, .error)
	l.send_message(msg)
}

// warn logs the given message if `Log.level` is greater than or equal to the `Level.warn` category
pub fn (l Log4v) warn(s string) {
	if int(l.level) < int(Level.warn) {
		return
	}
	msg := l.format_message(s, .warn)
	l.send_message(msg)
}

// info logs the given message if `Log.level` is greater than or equal to the `Level.info` category
pub fn (l Log4v) info(s string) {
	if int(l.level) < int(Level.info) {
		return
	}
	// format the string and send to channel
	msg := l.format_message(s, .info)
	l.send_message(msg)
}

// debug logs the given message if `Log.level` is greater than or equal to the `Level.debug` category
pub fn (l Log4v) debug(s string) {
	if int(l.level) < int(Level.debug) {
		return
	}
	msg := l.format_message(s, .debug)
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
	msg := l.format_message(s, .debug)
	l.send_message(msg)
}
