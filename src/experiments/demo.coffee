
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
{ jr }                    = CND

#-----------------------------------------------------------------------------------------------------------
demo = ->
  info 'µ0101-1', """isa.number 42""",                            CND.truth isa.number 42
  info 'µ0101-2', """isa.finite_number 42""",                     CND.truth isa.finite_number 42
  info 'µ0101-3', """isa.infinity Infinity""",                    CND.truth isa.infinity Infinity
  info 'µ0101-4', """isa.infinity 42""",                          CND.truth isa.infinity 42
  info 'µ0101-5', """isa.integer 42""",                           CND.truth isa.integer 42
  info 'µ0101-6', """isa.integer 42.1""",                         CND.truth isa.integer 42.1
  info 'µ0101-7', """isa.count 42""",                             CND.truth isa.count 42
  info 'µ0101-8', """isa.count -42""",                            CND.truth isa.count -42
  info 'µ0101-9', """isa.count 42.1""",                           CND.truth isa.count 42.1
  info 'µ0101-10', """isa.callable 42.1""",                       CND.truth isa.callable 42.1
  info 'µ0101-11', """isa.callable ( -> )""",                     CND.truth isa.callable ( -> )
  info 'µ0101-12', """isa.extends 'function', 'callable'""",      CND.truth isa.extends 'function', 'callable'
  info 'µ0101-13', """isa.extends 'safe_integer', 'integer'""",   CND.truth isa.extends 'safe_integer', 'integer'
  info 'µ0101-14', """isa.extends 'safe_integer', 'number'""",    CND.truth isa.extends 'safe_integer', 'number'
  info 'µ0101-15', """isa.type_of ( -> )""",                      CND.truth isa.type_of ( -> )
  info 'µ0101-16', """isa.type_of ( -> await f() )""",            CND.truth isa.type_of ( -> await f() )
  info 'µ0101-17', """isa.supertype_of ( -> )""",                 CND.truth isa.supertype_of ( -> )
  info 'µ0101-18', """isa.supertype_of ( -> await f() )""",       CND.truth isa.supertype_of ( -> await f() )
  info 'µ0101-19', """isa.type_of 42""",                          CND.truth isa.type_of 42
  info 'µ0101-20', """isa.type_of 42.1""",                        CND.truth isa.type_of 42.1
  info 'µ0101-21', """isa.supertype_of 42""",                     CND.truth isa.supertype_of 42
  info 'µ0101-22', """isa.supertype_of 42.1""",                   CND.truth isa.supertype_of 42.1
  info 'µ0101-23', """isa.multiple_of 33, 3""",                   CND.truth isa.multiple_of 33, 3
  info 'µ0101-24', """isa.multiple_of 33, 11""",                  CND.truth isa.multiple_of 33, 11
  info 'µ0101-25', """isa.multiple_of 5, 2.5""",                  CND.truth isa.multiple_of 5, 2.5
  info 'µ0101-25', """isa.multiple_of 5, 2.6""",                  CND.truth isa.multiple_of 5, 2.6
  info 'µ0101-26', """isa.even Infinity""",                       CND.truth isa.even Infinity
  info 'µ0101-27', """isa.odd Infinity""",                        CND.truth isa.odd Infinity

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
  # urge 'µ44433-2', isa.validate.integer 123.4
  try urge 'µ44433-3', ( isa.validate 'integer', "that should've been an $type: $value" ) 123 catch error then warn error.message
  try urge 'µ44433-4', ( isa.validate 'integer', "that should've been an $type: $value" ) 123.456 catch error then warn error.message
  try urge 'µ44433-5', isa.validate.has_keys {}, 'foo'
  # try urge 'µ44433-6', isa.validate.multiple_of 3, 6, "that should've been an $type: $value" catch error then warn error.message

#-----------------------------------------------------------------------------------------------------------
demo_supertypes = ->
  # help 'µ44455-1', isa.supertypes
  help 'µ44455-1', isa.extends( 'odd', 'number' )
  help 'µ44455-2', isa.extends( 'odd', 'integer' )
  help 'µ44455-3', isa.extends( 'integer', 'number' )
  help 'µ44455-4', isa.extends( 'safe_integer', 'integer' )
  help 'µ44455-4', isa.extends( 'safe_integer', 'text' )

#-----------------------------------------------------------------------------------------------------------
demo_object_shapes = ->
  isa.add_type 'nonempty_text', ( x ) -> ( @text x  ) and ( @nonempty x )
  isa.add_type 'triple',        ( x ) -> ( @count x ) and ( @multiple_of x, 3 ) and ( x < 10 )
  # debug isa.known_types()
  #.........................................................................................................
  for n in [ -4 .. 10 ]
    try
      info n, ( isa.triple n ), ( isa.validate.triple n ) # , "this is not a triple: $value"
    catch error
      warn error.message
  #.........................................................................................................
  isa.add_type 'foobarcat', { supertype: 'pod', }, ( x ) ->
    return false unless @pod            x
    return false unless @has_keys       x, 'foo', 'bar', 'cat'
    return false unless @nonempty_text  x.bar
    return false unless @nonempty_text  x.cat
    return true
  #.........................................................................................................
  isa.add_type 'foobarflapcat', { supertype: 'foobarcat', }, ( x ) ->
    ### TAINT shouldn't have to check manually for supertype ###
    return false unless @foobarcat  x
    return false unless @has_keys   x, 'flap'
    # return false unless @count      x.flap
  #.........................................................................................................
  probes = [
    { foo: 3, bar: 'a text', }
    { foo: 3, bar: 'a text', cat: '', }
    { foo: 3, bar: 'a text', cat: 'cats!', }
    { foo: 3, bar: 'a text', cat: 'cats!', flap: 3, }
    { foo: 3, bar: 'a text', cat: 'cats!', flap: -3, }
    ]
  #.........................................................................................................
  for probe in probes
    for type in [ 'foobarcat', 'foobarflapcat', ]
      help ( jr probe ), ( type )
      try
        isa.validate[ type ] probe
        urge 'ok'
      catch error
        warn error.message
  #.........................................................................................................
  info isa.supertype_of_type 'safe_integer'
  info isa.supertype_of_type 'foobarcat'
  info isa.supertype_of_type 'foobarflapcat'
  return null

#-----------------------------------------------------------------------------------------------------------
demo_object_shapes_ng = ->
  isa.add_type 'nonempty_text', ( x ) -> ( @text x  ) and ( @nonempty x )
  isa.add_type 'triple',        ( x ) -> ( @count x ) and ( @multiple_of x, 3 ) and ( x < 10 )
  # debug isa.known_types()
  #.........................................................................................................
  for n in [ -4 .. 10 ]
    try
      info n, ( isa.triple n ), ( isa.validate.triple n ) # , "this is not a triple: $value"
    catch error
      warn error.message
  #.........................................................................................................
  isa.add_type 'foobarcat',
    supertype: 'pod'
    tests:
      isa_pod:                ( x ) -> @pod            x
      has_keys:               ( x ) -> @has_keys       x, 'foo', 'bar', 'cat'
      x_bar_is_nonempty_text: ( x ) -> @nonempty_text  x.bar
      x_cat_is_nonempty_text: ( x ) -> @nonempty_text  x.cat
  #.........................................................................................................
  isa.add_type 'foobarflapcat',
    supertype: 'foobarcat'
    tests:
      isa_foobarcat:          ( x ) -> @foobarcat  x
      has_keys:               ( x ) -> @has_keys   x, 'flap'
      # return false unless @count      x.flap
  #.........................................................................................................
  probes = [
    { foo: 3, bar: 'a text', }
    { foo: 3, bar: 'a text', cat: '', }
    { foo: 3, bar: 'a text', cat: 'cats!', }
    { foo: 3, bar: 'a text', cat: 'cats!', flap: 3, }
    { foo: 3, bar: 'a text', cat: 'cats!', flap: -3, }
    ]
  #.........................................................................................................
  for probe in probes
    for type in [ 'foobarcat', 'foobarflapcat', ]
      help ( jr probe ), ( type )
      try
        isa.validate[ type ] probe
        urge 'ok'
      catch error
        throw error
        warn error.message
  #.........................................................................................................
  info isa.supertype_of_type 'safe_integer'
  info isa.supertype_of_type 'foobarcat'
  info isa.supertype_of_type 'foobarflapcat'
  return null

#-----------------------------------------------------------------------------------------------------------
demo_nested_errors = ->
  # validate_isa_number   = ( x ) -> throw new Error "µ1 not a number: #{rpr x}"  unless isa.number x
  # validate_isa_positive = ( x ) -> throw new Error "µ2 not positive: #{rpr x}"  unless x > 0
  # validate_isa_even     = ( x ) -> throw new Error "µ3 not even: #{rpr x}"      unless x %% 2 is 0
  # validate_isa_positive_even_number = ( x ) ->
  #   validate_isa_number   x
  #   validate_isa_positive x
  #   validate_isa_even     x
  # validate_isa_positive_even_number 42
  # validate_isa_positive_even_number 42.3
  # isa.add_type 'positive_even_number', ( x )

############################################################################################################
# demo()
# demo_supertypes()
# demo_object_shapes()
demo_object_shapes_ng()
# demo_nested_errors()





