
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
{ jr }										= CND

#-----------------------------------------------------------------------------------------------------------
demo = ->
	info 'µ0101-1', """isa.number 42""",                          	CND.truth isa.number 42
	info 'µ0101-2', """isa.finite_number 42""",                   	CND.truth isa.finite_number 42
	info 'µ0101-3', """isa.infinity Infinity""",                  	CND.truth isa.infinity Infinity
	info 'µ0101-4', """isa.infinity 42""",                        	CND.truth isa.infinity 42
	info 'µ0101-5', """isa.integer 42""",                         	CND.truth isa.integer 42
	info 'µ0101-6', """isa.integer 42.1""",                       	CND.truth isa.integer 42.1
	info 'µ0101-7', """isa.count 42""",                           	CND.truth isa.count 42
	info 'µ0101-8', """isa.count -42""",                          	CND.truth isa.count -42
	info 'µ0101-9', """isa.count 42.1""",                         	CND.truth isa.count 42.1
	info 'µ0101-10', """isa.callable 42.1""",                     	CND.truth isa.callable 42.1
	info 'µ0101-11', """isa.callable ( -> )""",                   	CND.truth isa.callable ( -> )
	info 'µ0101-12', """isa.extends 'function', 'callable'""",    	CND.truth isa.extends 'function', 'callable'
	info 'µ0101-13', """isa.extends 'safe_integer', 'integer'""", 	CND.truth isa.extends 'safe_integer', 'integer'
	info 'µ0101-14', """isa.extends 'safe_integer', 'number'""",  	CND.truth isa.extends 'safe_integer', 'number'
	info 'µ0101-15', """isa.type_of ( -> )""",                    	CND.truth isa.type_of ( -> )
	info 'µ0101-16', """isa.type_of ( -> await f() )""",          	CND.truth isa.type_of ( -> await f() )
	info 'µ0101-17', """isa.supertype_of ( -> )""",               	CND.truth isa.supertype_of ( -> )
	info 'µ0101-18', """isa.supertype_of ( -> await f() )""",     	CND.truth isa.supertype_of ( -> await f() )
	info 'µ0101-19', """isa.type_of 42""",                        	CND.truth isa.type_of 42
	info 'µ0101-20', """isa.type_of 42.1""",                      	CND.truth isa.type_of 42.1
	info 'µ0101-21', """isa.supertype_of 42""",                   	CND.truth isa.supertype_of 42
	info 'µ0101-22', """isa.supertype_of 42.1""",                 	CND.truth isa.supertype_of 42.1
	info 'µ0101-23', """isa.multiple_of 33, 3""",                 	CND.truth isa.multiple_of 33, 3
	info 'µ0101-24', """isa.multiple_of 33, 11""",                	CND.truth isa.multiple_of 33, 11
	info 'µ0101-25', """isa.multiple_of 5, 2.5""",                	CND.truth isa.multiple_of 5, 2.5
	info 'µ0101-25', """isa.multiple_of 5, 2.6""",                	CND.truth isa.multiple_of 5, 2.6
	info 'µ0101-26', """isa.even Infinity""",                     	CND.truth isa.even Infinity
	info 'µ0101-27', """isa.odd Infinity""",                      	CND.truth isa.odd Infinity

	info 'µ0102-1', isa.values_of isa.keys_of { line: 42, ch: 33, }
	info 'µ0102-2', isa.values_of isa.keys_of { line: 42, }
	info 'µ0102-3', isa.values_of isa.keys_of { line: 42, ch: undefined, }
	info 'µ0102-4', isa.has_keys { line: 42, ch: 33, }, [ 'line', ]
	info 'µ0102-5', isa.has_keys { line: 42, ch: undefined, }, [ 'line', 'ch', ]
	info 'µ0102-6', isa.has_keys { line: 42, ch: 33, }, [ 'line', 'ch', ]
	info 'µ0102-7', isa.has_keys { line: 42, ch: 33, }, [ 'line', 'ch', 'other', ]
	info 'µ0102-8', isa.has_only_keys { line: 42, ch: 33, }, [ 'line', ]
	info 'µ0102-9', isa.has_only_keys { line: 42, ch: undefined, }, [ 'line', 'ch', ]
	info 'µ0102-10', isa.has_only_keys { line: 42, ch: 33, }, [ 'line', 'ch', ]
	info 'µ0102-11', isa.has_only_keys { line: 42, ch: 33, }, [ 'line', 'ch', 'other', ]



	# urge 'µ44433-1', ( isa.keys_of isa.validate )
	urge 'µ44433-2', isa.validate.integer 123
	try urge 'µ44433-3', isa.validate.integer 123, "that should've been an $type: $value" catch error then warn error.message
	try urge 'µ44433-4', isa.validate.integer 123.456, "that should've been an $type: $value" catch error then warn error.message
	try urge 'µ44433-5', isa.validate.has_keys {}, 'foo'
	# try urge 'µ44433-6', isa.validate.multiple_of 3, 6, "that should've been an $type: $value" catch error then warn error.message

#-----------------------------------------------------------------------------------------------------------
demo_object_shapes = ->
	# debug isa.known_types()
	isa.add_type 'nonempty_text', ( x ) -> ( @text x ) and ( @nonempty x )
	isa.add_type 'triple', ( x ) -> ( @count x ) and ( @multiple_of x, 3 ) and ( x < 10 )
	#.........................................................................................................
	for n in [ -3 .. 10 ]
		try
			info n, isa.triple n, isa.validate.triple n # , "this is not a triple: $value"
		catch error
			warn error.message
	#.........................................................................................................
	isa.add_type 'foobarcat', ( x ) ->
		return false unless @pod 						x
		return false unless @has_only_keys 	x, 'foo', 'bar', 'cat'
		return false unless @nonempty_text 	x.bar
		return false unless @nonempty_text 	x.cat
		return true
	#.........................................................................................................
	probes = [
		{ foo: 3, bar: 'a text', cat: 'cats!', }
		{ foo: 3, bar: 'a text', cat: '', }
		]
	for probe in probes
		try
			help ( jr probe ), isa.validate.foobarcat probe
		catch error
			warn error.message
	return null

############################################################################################################
demo_object_shapes()





