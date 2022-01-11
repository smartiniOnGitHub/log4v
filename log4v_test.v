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

	// create using constructor and no arguments
	log := new_log4v() // when using from the same (current) repository
	// log := log4v.new_log4v()// when using from the repository
	assert typeof(log).name == '.Log4v'
}
