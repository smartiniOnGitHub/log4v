module log4v

import v.vmod

// TODO: check how to read log4v file, but always (even when another app is run from another folder); otherwise move to a function, but with the same problems of current version ... wip
const manifest = vmod.from_file('v.mod') or { panic(err) }

pub const (
	name        = manifest.name
	version     = manifest.version
	// description = manifest.description
)
