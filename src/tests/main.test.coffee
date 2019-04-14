


'use strict'


############################################################################################################
CND                       = require 'cnd'
rpr                       = CND.rpr
badge                     = 'INTERTYPE/TESTS/MAIN'
debug                     = CND.get_logger 'debug',     badge
alert                     = CND.get_logger 'alert',     badge
whisper                   = CND.get_logger 'whisper',   badge
warn                      = CND.get_logger 'warn',      badge
help                      = CND.get_logger 'help',      badge
urge                      = CND.get_logger 'urge',      badge
info                      = CND.get_logger 'info',      badge
jr                        = JSON.stringify
ITYPE                     = require '../..'
test                      = require 'guy-test'

#-----------------------------------------------------------------------------------------------------------
get_schema_A = ->
  R =
    #.........................................................................................................
    position:
      # $id:      'http://codemirror.net/types/position'
      type:     'object'
      properties:
        line:   { type: 'number', not: { 'type': 'null', }, }
        ch:     { type: 'number', not: { 'type': 'null', }, }
      required: [ 'line', 'ch', ]
    #.........................................................................................................
    range:
      # $id:      'http://codemirror.net/types/range'
      type:     'object'
      properties:
        from:       { $ref: 'position', }
        to:         { $ref: 'position', }
      required: [ 'from', 'to', ]
      #.......................................................................................................
  return R


#   schema =
#     # properties:
#     #   foo:  { type: 'integer', }
#     #   bar:  { type: 'boolean', }
#     # required: [ 'foo', 'bar', ]
#     # additionalProperties: false
#     $id: 'foobar'
#     properties:
#       abs:    { type: 'number', }
#       rel:    { type: 'number', }
#       lines:  { type: [ 'boolean', 'string', ], }
#     # required:             [ 'foo', 'bar', ]
#     additionalProperties: false

#   hub       = ITYPE.new_validation_hub()
#   ITYPE.add_schema hub, schema

#   probes = [
#     { abs: '0.8', }
#     { abs: '0.8', lines: '', }
#     { rel: '0.8', }
#     { rel: '0.8', lines: '', }
#     { foo: '1', bar: 'true', baz: 'true' }
#     # { foo: '1.1', bar: 'f', baz: 'true' }
#     # {}
#     # { foo: '1', bar: 'true', }
#     ]
#   for probe in probes
#     echo()
#     try
#       ITYPE.validate hub, 'foobar', probe
#     catch error
#       warn error.message
#       continue
#     help probe



#-----------------------------------------------------------------------------------------------------------
@[ "basic" ] = ( T, done ) ->
  hub = ITYPE.new_validation_hub()
  for typename, schema of get_schema_A()
    schema.$id = typename
    ITYPE.add_schema hub, schema
  #.........................................................................................................
  probes_and_matchers = [
    [['position', { line: 42, ch: 21, },                                            ], true, null, ]
    [['range',    { from: { line: 42, ch: 21, },    to: { line: 10, ch: 11, }, },   ], true, null, ]
    #.......................................................................................................
    [['position', { line: 42, },                                                    ], null, 'µ66533', ]
    [['position', { line: 42, ch: null, },                                          ], null, 'µ66533', ]
    [['position', { line: 42, ch: 'x', },                                           ], null, 'µ66533', ]
    [['range',    { from: { line: 42, },            to: { line: 10, ch: 11, }, },   ], null, 'µ66533', ]
    [['range',    { from: { line: 42, ch: 21, },    to: { line: 10, ch: null, }, }, ], null, 'µ66533', ]
    [['range',    { from: { line: 42, ch: null, },  to: { line: 10, ch: 11, }, },   ], null, 'µ66533', ]
    [['range',    { from: { line: 42, ch: 'x', },   to: { line: 10, ch: 11, }, },   ], null, 'µ66533', ]
    ]
  #.........................................................................................................
  for [ probe, matcher, error, ] in probes_and_matchers
    # matcher = CND.deep_copy probe
    [ typename, data, ] = probe
    matcher = data if matcher is true
    await T.perform probe, matcher, error, -> return new Promise ( resolve, reject ) ->
      result = ITYPE.validate hub, typename, data
      throw new Error "expected same object, got another one" unless result is data
      resolve result
      return null
  done()
  return null


############################################################################################################
unless module.parent?
  test @
  # test @[ "basic" ]

