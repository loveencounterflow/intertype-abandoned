
'use strict'


############################################################################################################
# njs_util                  = require 'util'
njs_path                  = require 'path'
# njs_fs                    = require 'fs'
#...........................................................................................................
CND                       = require 'cnd'
rpr                       = CND.rpr.bind CND
badge                     = 'INTERTYPE/tests/main'
log                       = CND.get_logger 'plain',     badge
info                      = CND.get_logger 'info',      badge
whisper                   = CND.get_logger 'whisper',   badge
alert                     = CND.get_logger 'alert',     badge
debug                     = CND.get_logger 'debug',     badge
warn                      = CND.get_logger 'warn',      badge
help                      = CND.get_logger 'help',      badge
urge                      = CND.get_logger 'urge',      badge
praise                    = CND.get_logger 'praise',    badge
echo                      = CND.echo.bind CND
#...........................................................................................................
# test                      = require 'guy-test'
isa                       = require '../..'



	"""isa.number 42"""
	"""isa.finite_number 42"""
	"""isa.infinity Infinity"""
	"""isa.infinity 42"""
	"""isa.integer 42"""
	"""isa.integer 42.1"""
	"""isa.count 42"""
	"""isa.count -42"""
	"""isa.count 42.1"""
	"""isa.callable 42.1"""
	"""isa.callable ( -> )"""
	"""isa.extends 'function', 'callable'"""
	"""isa.extends 'safe_integer', 'integer'"""
	"""isa.extends 'safe_integer', 'number'"""
	"""isa.type_of ( -> )"""
	"""isa.type_of ( -> await f() )"""
	"""isa.supertype_of ( -> )"""
	"""isa.supertype_of ( -> await f() )"""
	"""isa.type_of 42"""
	"""isa.type_of 42.1"""
	"""isa.supertype_of 42"""
	"""isa.supertype_of 42.1"""
	"""isa.multiple_of 33, 3"""
	"""isa.multiple_of 33, 11"""
	"""isa.multiple_of 5, 2.5"""
	"""isa.multiple_of 5, 2.6"""
	"""isa.even Infinity"""
	"""isa.odd Infinity"""



g = ->
	yield 2
	yield 3

urge isa g
urge isa g()
urge isa ( -> await f() )











