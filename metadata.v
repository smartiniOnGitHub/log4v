module log4v

import v.vmod

const manifest = vmod.from_file('v.mod') or { panic(err) }

pub const (
	name        = manifest.name
	version     = manifest.version
	description = manifest.description
)
