
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
# @boolean              = CND.isa_boolean
# @buffer               = CND.isa_buffer
# @function             = CND.isa_function
# @generator            = CND.isa_generator
# @generatorfunction    = CND.isa_generator_function
# @infinity             = CND.isa_infinity
# # @jsarguments          = CND.isa_jsarguments
# @arraybuffer        = CND.isa_jsarraybuffer
# @nodejs_buffer             = CND.isa_jsbuffer
# # @jsctx                = CND.isa_jsctx
# # @jsdate               = CND.isa_jsdate
# @error              = CND.isa_jserror
# @global             = CND.isa_jsglobal
# @nan         = CND.isa_jsnotanumber
# @regex              = CND.isa_jsregex
# @undefined          = CND.isa_jsundefined
# # @jswindow             = CND.isa_jswindow
# @list                 = CND.isa_list
# @null                 = CND.isa_null
# @nullorundefined      = CND.isa_nullorundefined
# @number               = CND.isa_number
# ### TAINT object/pod distinction? ###
# @object               = CND.isa_object
# @pod                  = CND.isa_pod
# @primitive            = CND.isa_primitive
# @symbol               = CND.isa_symbol
# @text                 = CND.isa_text



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
# function_types    = new Set [ 'generatorfunction', 'generator', 'asyncfunction', ]
# @function         = ( x ) -> function_types.has ( @isa x )
# @proper_function  = ( x ) -> @isa x )
#-----------------------------------------------------------------------------------------------------------
synonyms =
  string: 'text'

#-----------------------------------------------------------------------------------------------------------
@extensions =
  boundfunction:      'function'
  generator:          'function'
  generatorfunction:  'function'
  asyncfunction:      'function'

#-----------------------------------------------------------------------------------------------------------
@extends = ( subtype, supertype ) ->
  ### TAINT use validation functions with arguments ###
  throw new Error "µ63231 expected 2 arguments, got #{arity}" unless arity is 2
  throw new Error "µ63308 expected a text, got a #{type}"     unless ( type = @type_of subtype   ) is 'text'
  throw new Error "µ63385 expected a text, got a #{type}"     unless ( type = @type_of supertype ) is 'text'
  return true if subtype is supertype
  return @[ subtype ] is supertype


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
    ### TAINT should check for name clashes ###
    cnd_by_ity[ ity_type ] = cnd_type
    #.......................................................................................................
    ### Generate mappings from `isa.$type()` to CND.isa_$type()`: ###
    cnd_key = "isa_#{cnd_type}"
    # debug 'µ8498', cnd_type, ity_type, cnd_key, CND.type_of CND[ cnd_key ]
    unless ( type = CND.type_of ( cnd_method = CND[ cnd_key ] ) ) is 'function'
      throw new Error "µ63693 expected a function for `CND.#{cnd_key}`, found a #{type}"
    self[ ity_type ] = cnd_method.bind CND

  #---------------------------------------------------------------------------------------------------------
  ### Bind all functions to `module.exports`: ###
  for key, value of self
    ### TAINT use isa_callable ###
    if CND.isa_function value
      isa[ key ] = value.bind isa
    else
      isa[ key ] = value

  #---------------------------------------------------------------------------------------------------------
  return null








