module log4v

import semver

fn test_empty() {
	println(@FN + ' ' + 'first tests on metadata, to ensure it only compiles')
	assert true
}

fn test_values() {
	println(@FN + ' ' + 'tests on metadata values, to ensure they are read and good')
	assert name == 'log4v'
	assert description == 'Logging framework for V'
	version_semver := semver.from(version) or {
		println('Invalid version')
		assert false
		return
	}
	assert version != '0.0.0'
	assert version_semver.satisfies('>=0.0.1 <999.999.999')
}
