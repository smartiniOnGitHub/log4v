module main

// import log
// import log { Level, Logger, level_from_tag }
import log { Level }
import log4v
// import log4v
import time
import vweb

const (
	app_name  = 'log4v_vweb_example'
	port      = 8000
)

struct App {
	vweb.Context
	port       int // http port
	started_at u64 // start timestamp
mut:
	state shared State   // app shared state
	// log   shared log4v.Log4v // logging with log4v // TODO: check if use this instead ... wip
	log          log4v.Log4v // logging with log4v // TODO: check if good enough ... I have a crash when something is logged with an high Level, check better ... wip
}

struct State {
mut:
	num int
}

// main entry point of the application
fn main() {
	// println("Server listening on 'http://${server}:${port}' ...")
	vweb.run(new_app(), port)
}

// new_app creates and returns a new app instance
fn new_app() &App {
	// create a new log4v instance
	// mutable because here (once created) I will change options like log level etc ...
	mut logger := log4v.new_log4v_full(app_name, log4v.format_message, Level.info)
	// start async management of logs output
	// TODO: remove the following commented block ... wip
	// logger_messages_processing := go logger.start()
	// logger.set_processing_thread_reference(logger_messages_processing) // future work
	// println(@FN + ' DEBUG - $logger_messages_processing.str()')
	_ := go logger.start()

	mut app := &App{
		log: logger
		port: port
		started_at: u64(time.now().unix)
	}

	// additional app initialization and configuration at startup time
	// log using the logger just initialized and started ...
	app.log_info('Server initialization at ${app.started_at}...')
	// additional config ...

	app.log_info('vweb app "$app_name" successfully configured')
	return app
}

// before_request initialization just before any route call
pub fn (mut app App) before_request() {
	// log something
	url := app.req.url
	msg := '${@FN}: url=$url'
	app.log_debug(msg) // call log wrapper, but with logger level info nothing will be shown
	app.log.debug(msg) // call log directly, but with logger level info nothing will be shown
	println('println: ' + msg) // temp
	// app.log_info('${@FN}: url=$url') // TODO: crash when enabled, check why ... wip
	// app.log.info('${@FN}: url=$url') // TODO: crash when enabled, check why ... wip
}

// log_debug log with verbosity debug, using application logger
fn (mut app App) log_debug(msg string) {
	/*
	// TODO: try, to check if useful here with a shared app logger ...
	rlock app.log {
		app.log.debug(msg)
	}
	 */
	app.log.debug(msg)
}

// TODO: update for log4v ... wip
// log_info log with verbosity info, using application logger
fn (mut app App) log_info(msg string) {
	/*
	// TODO: try, to check if useful here with a shared app logger ...
	rlock app.log {
		app.log.info(msg)
	}
	 */
	app.log.info(msg)
}

// inc_cnt increment and return counter value for page calls, from shared state
fn (mut app App) inc_cnt() int {
	data := lock app.state {
		app.state.num++
	}
	return data
}
// index serve some content on the root (index) route '/'
pub fn (mut app App) index() vweb.Result {
	now := time.now().format_ss_milli()
	mut msg := 'at $now, total number of requests is: '
	lock app.state {
		app.state.num++
		msg += '$app.state.num'
	}
	// log something
	app.log.debug(msg)
	println('println: ' + msg) // temp
	// app.log_info(msg) // TODO: crash when enabled, check why ... wip
	// app.log.info(msg) // TODO: crash when enabled, check why ... wip
	// TODO: check if log with rlock ... wip
	return app.text('Hello from vweb at $now')
}

// health sample health check route that exposes a fixed json reply at '/health'
pub fn (mut app App) health() vweb.Result {
	now := time.now().format_ss_milli()
	num := app.inc_cnt() // sample, increment count number // TODO: add utility method and enable here ... wip
	msg := 'at $now, total number of requests is: $num'
	// log something
	app.log.debug(msg)
	println('println: ' + msg) // temp
	// app.log_info(msg) // TODO: crash when enabled, check why ... wip
	// app.log.info(msg) // TODO: crash when enabled, check why ... wip
	// TODO: check if log with rlock ... wip
	return app.json('{"statusCode":200, "status":"ok"}')
}
