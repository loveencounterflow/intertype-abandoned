
'use strict'

############################################################################################################
CND                       = require 'cnd'
rpr                       = CND.rpr
badge                     = 'INTERTYPE/MAIN'
debug                     = CND.get_logger 'debug',     badge
alert                     = CND.get_logger 'alert',     badge
whisper                   = CND.get_logger 'whisper',   badge
warn                      = CND.get_logger 'warn',      badge
help                      = CND.get_logger 'help',      badge
urge                      = CND.get_logger 'urge',      badge
info                      = CND.get_logger 'info',      badge
{ assign
  jr }                    = CND

#-----------------------------------------------------------------------------------------------------------
ity_by_cnd =
  ### ??? ###
  # nullorundefined:      'nullorundefined'
  # primitive:            'primitive'
  # symbol:               'symbol'
### TAINT object/pod distinction? ###
  # object:               'object'
  pod:                  'pod'
  boolean:              'boolean'
  buffer:               'buffer'
  function:             'function'
  generator:            'generator'
  # async_function:   'asyncfunction'
  generator_function:   'generatorfunction'
  infinity:             'infinity'
  jsarraybuffer:        'arraybuffer'
  jserror:              'error'
  jsglobal:             'global'
  jsnotanumber:         'nan'
  jsregex:              'regex'
  jsundefined:          'undefined'
  list:                 'list'
  null:                 'null'
  number:               'number'
  text:                 'text'
#                 jsarguments:          'jsarguments'
#                 jsctx:                'jsctx'
#                 jsdate:               'jsdate'
#                 jswindow:             'jswindow'
cnd_by_ity  = {}

#-----------------------------------------------------------------------------------------------------------
@integer          = Number.isInteger
@finite_number    = Number.isFinite
@safe_integer     = Number.isSafeInteger
@count            = ( x ) -> ( @safe_integer x ) and ( x >= 0 )
@asyncfunction    = ( x ) -> ( @type_of x ) is 'asyncfunction'
@boundfunction    = ( x ) -> ( ( @supertype_of x ) is 'callable' ) and ( not Object.hasOwnProperty x, 'prototype' )
@callable         = ( x ) -> ( @type_of x ) in [ 'function', 'asyncfunction', 'generatorfunction', ]
@positive         = ( x ) -> ( @number x ) and ( x >  0 )
@nonnegative      = ( x ) -> ( @number x ) and ( x >= 0 )
@negative         = ( x ) -> ( @number x ) and ( x <  0 )
@even             = ( x ) -> ( @finite_number x ) and     @multiple_of x, 2
@odd              = ( x ) -> ( @finite_number x ) and not @multiple_of x, 2
@multiple_of      = ( x, d ) -> ( @finite_number x ) and ( x %% d ) is 0

#-----------------------------------------------------------------------------------------------------------
@arity = ( x ) ->
  unless ( type = @supertype_of x ) is 'callable'
    throw new Error "µ88733 expected a callable, got a #{type}"
  return x.length


#===========================================================================================================
#
#-----------------------------------------------------------------------------------------------------------
@type_of = ( x ) ->
  throw new Error "µ63000 expected 1 argument, got #{arity}" unless ( arity = arguments.length ) is 1
  return ity_by_cnd[ type = CND.type_of x ] ? type

#-----------------------------------------------------------------------------------------------------------
@validate = ( x, type, message = null ) ->
  throw new Error "µ63077 unknown type #{rpr type}" unless ( tester = @[ type ] )?
  unless tester x
    throw new Error message ? "µ63154 expected a #{type}, got a #{CND.type_of x}"
  return null


#===========================================================================================================
#
#-----------------------------------------------------------------------------------------------------------
# synonyms =
#   string: 'text'

#-----------------------------------------------------------------------------------------------------------
@extensions =
  function:           'callable'
  boundfunction:      'callable'
  generatorfunction:  'callable'
  asyncfunction:      'callable'
  safe_integer:       'integer'
  integer:            'number'
  float:              'number'

#-----------------------------------------------------------------------------------------------------------
@extends = ( subtype, supertype ) ->
  ### TAINT use validation functions with arguments ###
  throw new Error "µ63231 expected 2 arguments, got #{arity}" unless ( arity = arguments.length  ) is 2
  throw new Error "µ63308 expected a text, got a #{type}"     unless ( type = @type_of subtype   ) is 'text'
  throw new Error "µ63385 expected a text, got a #{type}"     unless ( type = @type_of supertype ) is 'text'
  return true if subtype is supertype
  return ( @extensions[ subtype ] is supertype ) or ( @extends @extensions[ subtype ], supertype )

#-----------------------------------------------------------------------------------------------------------
@supertype_of = ( x ) -> @supertype_of_type @type_of x

#-----------------------------------------------------------------------------------------------------------
@supertype_of_type = ( type ) ->
  return type unless ( supertype = @extensions[ type ] )?
  return @supertype_of_type supertype

#===========================================================================================================
# LISTS
#-----------------------------------------------------------------------------------------------------------
@first_of   = ( collection ) -> collection[ 0 ]
@last_of    = ( collection ) -> collection[ collection.length - 1 ]

#===========================================================================================================
# OBJECT SIZES
#-----------------------------------------------------------------------------------------------------------
@size_of = ( x, settings ) ->
  switch type = CND.type_of x
    when 'list', 'arguments', 'buffer' then return x.length
    when 'text'
      switch selector = settings?[ 'count' ] ? 'codeunits'
        when 'codepoints' then return ( Array.from x ).length
        when 'codeunits'  then return x.length
        when 'bytes'      then return Buffer.byteLength x, ( settings?[ 'encoding' ] ? 'utf-8' )
        else throw new Error "unknown counting selector #{rpr selector}"
    when 'set', 'map'     then return x.size
  if CND.isa_pod x then return ( Object.keys x ).length
  throw new Error "unable to get size of a #{type}"


#===========================================================================================================
#
#-----------------------------------------------------------------------------------------------------------
@all_own_keys_of = ( x ) ->
  unless x?
    yield return
  yield k for k in Object.getOwnPropertyNames x

#-----------------------------------------------------------------------------------------------------------
@all_keys_of = ( x, include_object = false ) -> @_all_keys_of x, new Set(), include_object

#-----------------------------------------------------------------------------------------------------------
@_all_keys_of = ( x, seen, include_object = false ) ->
  if ( not include_object ) and x is Object::
    yield return
  # debug 'µ23773', ( rpr x ), ( x:: )
  for k from @all_own_keys_of x
    continue if seen.has k
    seen.add k
    yield k
  if ( proto = Object.getPrototypeOf x )?
    yield from @_all_keys_of proto, seen, include_object

#-----------------------------------------------------------------------------------------------------------
@keys_of    = ( x ) -> yield k for k of x
@values_of  = ( x ) -> [ x... ]

#-----------------------------------------------------------------------------------------------------------
isa = ( x, type ) ->
  return @type_of x if ( arity = arguments.length ) is 1
  throw new Error "µ63462 expected 2 arguments, got #{arity}" unless arity is 2
  throw new Error "µ63539 expected a text, got a #{type}"     unless ( type = @type_of type ) is 'text'
  throw new Error "µ63616 unknown type #{rpr type}"           unless ( tester = @[ type ] )?
  return tester x
#-----------------------------------------------------------------------------------------------------------
# debug 'µ38873', @
# debug 'µ38873', @isa
# return @

############################################################################################################

self            = @
isa             = isa.bind @
module.exports  = isa

do ->
  #---------------------------------------------------------------------------------------------------------
  for cnd_type, ity_type of ity_by_cnd
    #.......................................................................................................
    ### Generate entries to cnd_by_ity: ###
    if cnd_by_ity[ ity_type ]?
      throw new Error "µ49833 name collision in cnd_by_ity: #{rpr ity_type}"
    cnd_by_ity[ ity_type ] = cnd_type
    #.......................................................................................................
    ### Generate mappings from `isa.$type()` to CND.isa_$type()`: ###
    cnd_key = "isa_#{cnd_type}"
    # debug 'µ8498', cnd_type, ity_type, cnd_key, CND.type_of CND[ cnd_key ]
    unless ( type = CND.type_of ( cnd_method = CND[ cnd_key ] ) ) is 'function'
      throw new Error "µ63693 expected a function for `CND.#{cnd_key}`, found a #{type}"
    self[ ity_type ] ?= cnd_method.bind CND ### avoid to overwrite existing methods ###

  #---------------------------------------------------------------------------------------------------------
  ### Bind all functions to `module.exports`: ###
  for key, value of self
    ### TAINT use isa.callable ###
    if CND.isa_function value
      isa[ key ] = value.bind isa
    else
      isa[ key ] = value

  #---------------------------------------------------------------------------------------------------------
  return null








