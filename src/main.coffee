
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
flatten                   = require 'lodash/flattenDeep'
isa_type                  = Symbol 'isa_type'
# @_current_errors = []
# @_start_validating = ->
#   @_is_validating         = true
#   @_current_errors.length = 0
# @_stop_validating = ->
#   @_is_validating         = false
#   if @_current_errors.length isnt 0
#     debug 'µ22822', @_current_errors
#   @_current_errors.length = 0
# @_push_validation_error = ( error ) ->
#   @_current_errors.push error.message

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
  # set:                  'set'
#                 jsarguments:          'jsarguments'
#                 jsctx:                'jsctx'
#                 jsdate:               'jsdate'
#                 jswindow:             'jswindow'
cnd_by_ity  = {}


#===========================================================================================================
#
#-----------------------------------------------------------------------------------------------------------
@type_of = ( x ) ->
  throw new Error "µ63000 expected 1 argument, got #{arity}" unless ( arity = arguments.length ) is 1
  return ity_by_cnd[ type = CND.type_of x ] ? type

#-----------------------------------------------------------------------------------------------------------
@validate = ( x, type, message = null ) ->
  throw new Error "µ63077 unknown type #{rpr type}" unless ( tester = @[ type ] )?
  # @_start_validating() unless @_is_validating
  result = tester x
  # @_stop_validating()
  unless result
    if message?
      message = message.replace /\$type/g,  type
      message = message.replace /\$value/g, rpr x
      throw new Error message
    else
      throw new Error "µ63154 expected a #{type}, got a #{CND.type_of x}"
  return null

#-----------------------------------------------------------------------------------------------------------
_size_of =
  list:       'length'
  # arguments:  'length'
  buffer:     'length'
  set:        'size'
  map:        'size'
  #.........................................................................................................
  global:     ( x ) => ( @all_keys_of x ).length
  pod:        ( x ) => ( @keys_of     x ).length
  #.........................................................................................................
  text:       ( x, selector = 'codeunits' ) ->
    switch selector
      when 'codepoints' then return ( Array.from x ).length
      when 'codeunits'  then return x.length
      when 'bytes'      then return Buffer.byteLength x, ( settings?[ 'encoding' ] ? 'utf-8' )
      else throw new Error "unknown counting selector #{rpr selector}"

#-----------------------------------------------------------------------------------------------------------
@add_type = ( type, settings, f ) ->
  switch ( arity = arguments.length )
    when 2 then [ type, settings, f, ] = [ type, null, settings, ]
    when 3 then null
    else throw new Error "µ29892 expected 2 or 3 arguments, got #{arity}"
  defaults = { overwrite: false, size_of: ( settings?.size_of ? _size_of[ type ] ? null ), }
  settings = if settings? then ( assign {}, settings, defaults ) else defaults
  #.........................................................................................................
  if ( not settings.overwrite ) and ( @[ type ] isnt undefined )
    throw new Error "name #{rpr type} already defined"
  f                     = f.bind @
  # f[ isa_type ]         = true
  @[ type ]             = ( x, P... ) => f x, P...
  # @[ type ]             = ( x, P... ) =>
  #   if @_is_validating
  #     whisper 'µ67777', ( rpr type ), f[ isa_type ] ? ''
  #   try
  #     R = f x, P...
  #   catch error
  #     if @_is_validating
  #       @_push_validation_error error
  #     throw error
  #   if ( not R ) and @_is_validating
  #     rpr_P = switch P.length
  #       when 0 then ''
  #       when 1 then rpr P[ 0 ]
  #       else rpr P
  #     throw new Error "µ09981 #{rpr x} is not a #{type} #{rpr_P}"
  #   return R
  @[ type ][ isa_type ] = true
  @validate[ type ]     = ( x, P... ) => @validate x, type, P...
  #.........................................................................................................
  do ( s = settings.size_of ) =>
    if s is null
      _size_of[ type ] = null
    else
      switch type_of_s = @type_of s
        when 'text'     then _size_of[ type ] = ( x ) -> x[ s ]
        when 'function' then _size_of[ type ] = s
        else throw new Error "µ30988 expected null, a text or a function for size_of, got a #{type_of_s}"
  #.........................................................................................................
  return null

#-----------------------------------------------------------------------------------------------------------
@arity_of = ( x ) ->
  unless ( type = @supertype_of x ) is 'callable'
    throw new Error "µ88733 expected a callable, got a #{type}"
  return x.length



#===========================================================================================================
#
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
# OBJECT SIZES
#-----------------------------------------------------------------------------------------------------------
@size_of = ( x, P... ) ->
  # debug 'µ44744', [ x, P, ]
  type = CND.type_of x
  unless ( @function ( getter = _size_of[ type ] ) )
    throw new Error "µ88793 unable to get size of a #{type}"
  return getter x, P...

#-----------------------------------------------------------------------------------------------------------
@first_of   = ( collection ) -> collection[ 0 ]
@last_of    = ( collection ) -> collection[ collection.length - 1 ]


#===========================================================================================================
#
#-----------------------------------------------------------------------------------------------------------
@keys_of              = ( P... ) -> @values_of @walk_keys_of      P...
@all_keys_of          = ( P... ) -> @values_of @walk_all_keys_of  P...
@all_own_keys_of      = ( x    ) -> if x? then Object.getOwnPropertyNames x else []
@walk_all_own_keys_of = ( x    ) -> yield k for k in @all_own_keys_of x

#-----------------------------------------------------------------------------------------------------------
@walk_keys_of = ( x, settings ) ->
  defaults = { skip_undefined: true, }
  settings = if settings? then ( assign {}, settings, defaults ) else defaults
  for k of x
    ### TAINT should use property descriptors to avoid possible side effects ###
    continue if ( x[ k ] is undefined ) and settings.skip_undefined
    yield k

#-----------------------------------------------------------------------------------------------------------
@walk_all_keys_of = ( x, settings ) ->
  defaults = { skip_object: true, skip_undefined: true, }
  settings = if settings? then ( assign {}, settings, defaults ) else defaults
  return @_walk_all_keys_of x, new Set(), settings

#-----------------------------------------------------------------------------------------------------------
@_walk_all_keys_of = ( x, seen, settings ) ->
  if ( not settings.skip_object ) and x is Object::
    yield return
  #.........................................................................................................
  for k from @walk_all_own_keys_of x
    continue if seen.has k
    seen.add k
    ### TAINT should use property descriptors to avoid possible side effects ###
    ### TAINT trying to access `arguments` causes error ###
    try value = x[ k ] catch error then continue
    continue if ( value is undefined ) and settings.skip_undefined
    if settings.symbol?
      continue unless value?
      continue unless value[ settings.symbol ]
    yield k
  #.........................................................................................................
  if ( proto = Object.getPrototypeOf x )?
    yield from @_walk_all_keys_of proto, seen, settings

#-----------------------------------------------------------------------------------------------------------
@known_types = -> [ ( @walk_all_keys_of @, { symbol: isa_type } )... ]

#-----------------------------------------------------------------------------------------------------------
@values_of = ( x ) -> [ x... ]

#-----------------------------------------------------------------------------------------------------------
@has_keys = ( x, P... ) ->
  ### Observe that `has_keys()` always considers `undefined` as 'not set' ###
  return false unless x? ### TAINT or throw error ###
  for key in flatten P
    ### TAINT should use property descriptors to avoid possible side effects ###
    return false if x[ key ] is undefined
  return true

#-----------------------------------------------------------------------------------------------------------
@has_only_keys = ( x, P... ) ->
  probes  = ( flatten P ).sort()
  keys    = ( @values_of @keys_of x ).sort()
  return CND.equals probes, keys


#===========================================================================================================
#
#-----------------------------------------------------------------------------------------------------------
isa = ( x, type ) ->
  return @type_of x if ( arity = arguments.length ) is 1
  throw new Error "µ63462 expected 2 arguments, got #{arity}" unless arity is 2
  throw new Error "µ63539 expected a text, got a #{type}"     unless ( type = @type_of type ) is 'text'
  throw new Error "µ63616 unknown type #{rpr type}"           unless ( tester = @[ type ] )?
  return tester x


############################################################################################################
self            = @
isa             = isa.bind @
module.exports  = isa

do ->
  #---------------------------------------------------------------------------------------------------------
  for cnd_type, ity_type of ity_by_cnd
    ### Generate entries to cnd_by_ity: ###
    if cnd_by_ity[ ity_type ]?
      throw new Error "µ49833 name collision in cnd_by_ity: #{rpr ity_type}"
    cnd_by_ity[ ity_type ] = cnd_type

  #---------------------------------------------------------------------------------------------------------
  ### Bind all functions to `module.exports`: ###
  for key, value of self
    ### TAINT use isa.callable ###
    if CND.isa_function value
      isa[ key ] = value.bind isa
    else
      isa[ key ] = value

  #---------------------------------------------------------------------------------------------------------
  for cnd_type, ity_type of ity_by_cnd
    ### Generate mappings from `isa.$type()` to CND.isa_$type()`: ###
    continue if self[ ity_type ]?
    cnd_key = "isa_#{cnd_type}"
    # debug 'µ8498', cnd_type, ity_type, cnd_key, CND.type_of CND[ cnd_key ]
    unless ( type = CND.type_of ( cnd_method = CND[ cnd_key ] ) ) is 'function'
      throw new Error "µ63693 expected a function for `CND.#{cnd_key}`, found a #{type}"
    size_of = _size_of[ ity_type ] ? null
    isa.add_type ity_type, { size_of, }, cnd_method.bind CND

  #---------------------------------------------------------------------------------------------------------
  return null

#-----------------------------------------------------------------------------------------------------------
isa.add_type 'set',     { size_of: 'size',  }, ( x ) -> ( Object::toString.call x ) is '[object Set]'
isa.add_type 'map',     { size_of: 'size',  }, ( x ) -> ( Object::toString.call x ) is '[object Map]'
isa.add_type 'weakmap', { size_of: null,    }, ( x ) -> ( Object::toString.call x ) is '[object WeakMap]'
isa.add_type 'weakset', { size_of: null,    }, ( x ) -> ( Object::toString.call x ) is '[object WeakSet]'
#-----------------------------------------------------------------------------------------------------------
isa.add_type 'integer',       Number.isInteger
isa.add_type 'finite_number', Number.isFinite
isa.add_type 'safe_integer',  Number.isSafeInteger
isa.add_type 'count',         ( x ) -> ( @safe_integer x ) and ( x >= 0 )
isa.add_type 'asyncfunction', ( x ) -> ( @type_of x ) is 'asyncfunction'
isa.add_type 'boundfunction', ( x ) -> ( ( @supertype_of x ) is 'callable' ) and ( not Object.hasOwnProperty x, 'prototype' )
isa.add_type 'callable',      ( x ) -> ( @type_of x ) in [ 'function', 'asyncfunction', 'generatorfunction', ]
isa.add_type 'positive',      ( x ) -> ( @number x ) and ( x >  0 )
isa.add_type 'nonnegative',   ( x ) -> ( @number x ) and ( x >= 0 )
isa.add_type 'negative',      ( x ) -> ( @number x ) and ( x <  0 )
isa.add_type 'even',          ( x ) -> ( @finite_number x ) and     @multiple_of x, 2
isa.add_type 'odd',           ( x ) -> ( @finite_number x ) and not @multiple_of x, 2
isa.add_type 'multiple_of',   ( x, d ) -> ( @finite_number x ) and ( x %% d ) is 0
isa.add_type 'empty',         ( x ) -> ( @size_of x ) is 0
isa.add_type 'nonempty',      ( x ) -> ( @size_of x ) > 0








