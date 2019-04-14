


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
schemas =
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


############################################################################################################
hub = ITYPE.new_validation_hub()
do ->
  for typename, schema of schemas
    schema.$id = typename
    ITYPE.add_schema hub, schema


############################################################################################################
unless module.parent?
  probes = [
    { line: 42, }
    { line: 42, ch: 21, }
    { line: 42, ch: null, }
    { line: 42, ch: 'x', }
    ]
  for probe in probes
    error = null
    try
      ITYPE.validate hub, 'position', probe
    catch error
      warn ( jr probe ), error.message
    unless error?
      help ( jr probe ), 'ok'

  probes = [
    { from: { line: 42, },            to: { line: 10, ch: 11, }, }
    { from: { line: 42, ch: 21, },    to: { line: 10, ch: 11, }, }
    { from: { line: 42, ch: 21, },    to: { line: 10, ch: null, }, }
    { from: { line: 42, ch: null, },  to: { line: 10, ch: 11, }, }
    { from: { line: 42, ch: 'x', },   to: { line: 10, ch: 11, }, }
    ]
  for probe in probes
    error = null
    try
      ITYPE.validate hub, 'range', probe
    catch error
      warn ( jr probe ), error.message
    unless error?
      help ( jr probe ), 'ok'





#   ITYPE = @

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



# #-----------------------------------------------------------------------------------------------------------
# @[ "basic" ] = ( T, done ) ->
#   triode = TRIODE.new()
#   triode.set 'aluminum',  { word: 'aluminum', text: 'a metal', }
#   triode.set 'aluminium', { word: 'aluminium', text: 'a metal', }
#   triode.set 'alumni',    { word: 'alumni', text: 'a former student', }
#   triode.set 'alphabet',  { word: 'alphabet', text: 'a kind of writing system', }
#   triode.set 'abacus',    { word: 'abacus', text: 'a manual calculator', }
#   #.........................................................................................................
#   probes_and_matchers = [
#     ["a",[["abacus",{"word":"abacus","text":"a manual calculator"}],["alphabet",{"word":"alphabet","text":"a kind of writing system"}],["alumni",{"word":"alumni","text":"a former student"}],["aluminium",{"word":"aluminium","text":"a metal"}],["aluminum",{"word":"aluminum","text":"a metal"}]],null]
#     ["alu",[["alumni",{"word":"alumni","text":"a former student"}],["aluminium",{"word":"aluminium","text":"a metal"}],["aluminum",{"word":"aluminum","text":"a metal"}]],null]
#     ["alp",[["alphabet",{"word":"alphabet","text":"a kind of writing system"}]],null]
#     ["b",[],null]
#     ]
#   #.........................................................................................................
#   for [ probe, matcher, error, ] in probes_and_matchers
#     await T.perform probe, matcher, error, -> return new Promise ( resolve, reject ) ->
#       result = triode.find probe
#       # urge jr [ probe, result, null, ]
#       resolve result
#       return null
#   done()
#   return null


# ############################################################################################################
# unless module.parent?
#   test @
#   # test @[ "basic" ]

