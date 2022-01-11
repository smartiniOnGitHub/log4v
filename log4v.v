module log4v

// reuse some standard definitions from V integrated logger
import log { Logger, Level }

pub const (
	version = '0.1'
)

// Log4v represents a logging object
pub struct Log4v {
mut:
	level         Level
	name          string
	// TODO: add formatters, appenders, etc ...
}

// TODO: add Config, etc .. wip

// TODO: check if rename to 'new' only ... wip
// new create and return a new Log4v instance
pub fn new_log4v() Log4v {
	return Log4v {}
}

// TODO: add other constructor versions ... wip

// get_level gets the internal logging level.
pub fn (mut l Log4v) get_level() Level {
	return l.level
}
