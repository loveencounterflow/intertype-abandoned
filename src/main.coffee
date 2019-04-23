
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
#...........................................................................................................
{ inspect, }              = require 'util'
_xrpr                     = ( x ) -> inspect x, { colors: yes, breakLength: Infinity, maxArrayLength: Infinity, depth: Infinity, }
xrpr                      = ( x ) -> ( _xrpr x )[ .. 500 ]
@_js_type_of              = ( x ) -> return ( ( Object::toString.call x ).slice 8, -1 ).toLowerCase()
#...........................................................................................................
assign @, require './cataloguing'
assign @, require './sizing'



#-----------------------------------------------------------------------------------------------------------
@isa = ( type, xP... ) =>
  # debug 'µ33444', type, xP
  return true if ( @type_of xP... ) is type
  # check all constraints in spec
  throw new Error "µ2345 unknown type #{rpr type}" unless ( spec = @specs[ type ] )?
  for aspect, test of spec.tests
    return false unless test.apply @, xP
  return true

#-----------------------------------------------------------------------------------------------------------
@type_of = ( xP... ) =>
  switch R = @_js_type_of xP...
    when 'number'
      return 'infinity' if ( xP[ 0 ] is Infinity ) or ( xP[ 0 ] is -Infinity )
      return 'nan'      if Number.isNaN xP[ 0 ]
      return 'number'
    when 'regexp' then return 'regex'
    when 'string' then return 'text'
    when 'array'  then return 'list'
  return R

#-----------------------------------------------------------------------------------------------------------
@types_of = ( xP... ) =>
  R = []
  for type, spec of @specs
    ok = true
    for aspect, test of spec.tests
      # debug 'µ27722', "#{type}/#{aspect}", test.apply @, xP
      unless test.apply @, xP
        ok = false
        break
    R.push type if ok
  return R

#-----------------------------------------------------------------------------------------------------------
@_validate = ( type, xP... ) =>

#-----------------------------------------------------------------------------------------------------------
@validate = new Proxy @_validate,
  get: ( target, type ) => ( P... ) => target type, P...

#-----------------------------------------------------------------------------------------------------------
@declare = ( P... ### type, spec, test ### ) =>
  # debug 'µ10001', P
  switch arity = P.length
    #.......................................................................................................
    when 3
      [ type, spec, test, ] = P
      #.....................................................................................................
      unless ( type_of_spec = @_js_type_of spec ) is 'object'
        throw new Error "µ2468 expected an object for spec, got a #{type_of_spec}"
      #.....................................................................................................
      unless ( type_of_test = @_js_type_of test ) is 'function'
        throw new Error "µ2591 expected a function for test, got a #{type_of_test}"
      #.....................................................................................................
      if spec.tests?
        throw new Error "µ2714 spec cannot have tests when tests are passed as argument"
      #.....................................................................................................
      return @declare type, assign {}, spec, { tests: { main: test, }, }
    #.......................................................................................................
    when 2
      [ type, spec, ] = P
    #.......................................................................................................
    else throw new Error "µ2837 expected 2 or 3 arguments, got #{arity}"
  #:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
  ### TAINT make catalog of all 'deep JS' names that must never be used as types, b/c e.g a type 'bind'
  would shadow native `f.bind()` ###
  if type in [ 'bind', ] # toString, ...
    throw new Error "µ2292 #{rpr type} is not a legal type name"
  #:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
  switch type_of_spec = @_js_type_of spec
    #.......................................................................................................
    when 'function'
      return @declare type, { tests: { main: spec, }, }
    #.......................................................................................................
    when 'asyncfunction'
      throw "µ2960 asynchronous functions not yet supported"
    #.......................................................................................................
    when 'object'
      if ( @specs[ type ] )?
        throw new Error "µ3083 type #{rpr type} already declared"
      spec            = assign {}, spec
      @specs[ type ]  = spec
      @isa[ type ]    = ( P... ) => @isa type, P...
      # @validate[ type ]    = ( P... ) => @validate type, P...
      spec.size_of    = @_sizeof_method_from_spec type, spec
    #.......................................................................................................
    else
      throw "µ3206 expected (sync, async) function or object for spec, got a #{type_of_spec}"
  return null

#-----------------------------------------------------------------------------------------------------------
@specs = {}


#===========================================================================================================
# TYPE DECLARATIONS
#-----------------------------------------------------------------------------------------------------------
@declare 'null',                ( x ) => x is null
@declare 'undefined',           ( x ) => x is undefined
@declare 'boolean',             ( x ) => ( x is true ) or ( x is false )
@declare 'nan',                 ( x ) => Number.isNaN         x
@declare 'finite',              ( x ) => Number.isFinite      x
@declare 'integer',             ( x ) => Number.isInteger     x
@declare 'safeinteger',         ( x ) => Number.isSafeInteger x
@declare 'number',              ( x ) => Number.isFinite      x
@declare 'frozen',              ( x ) => Object.isFrozen      x
@declare 'sealed',              ( x ) => Object.isSealed      x
@declare 'extensible',          ( x ) => Object.isExtensible  x
#...........................................................................................................
@declare 'numeric',             ( x ) => ( @_js_type_of x ) is 'number'
@declare 'function',            ( x ) => ( @_js_type_of x ) is 'function'
@declare 'asyncfunction',       ( x ) => ( @_js_type_of x ) is 'asyncfunction'
@declare 'generatorfunction',   ( x ) => ( @_js_type_of x ) is 'generatorfunction'
@declare 'callable',            ( x ) => ( @type_of x ) in [ 'function', 'asyncfunction', 'generatorfunction', ]
#...........................................................................................................
@declare 'truthy',              ( x ) => not not x
@declare 'falsy',               ( x ) => not x
@declare 'unset',               ( x ) => not x?
@declare 'notunset',            ( x ) => x?
#...........................................................................................................
@declare 'even',                ( x ) => @isa.multiple_of x, 2
@declare 'odd',                 ( x ) => not @isa.even x
@declare 'count',               ( x ) -> ( @isa.safeinteger x ) and ( @isa.nonnegative x )
@declare 'nonnegative',         ( x ) => ( @isa.number x ) and ( x >= 0 )
@declare 'positive',            ( x ) => ( @isa.number x ) and ( x > 0 )
@declare 'zero',                ( x ) => x is 0
@declare 'nonpositive',         ( x ) => ( @isa.number x ) and ( x <= 0 )
@declare 'negative',            ( x ) => ( @isa.number x ) and ( x < 0 )
@declare 'multiple_of',         ( x, n ) => ( @isa.number x ) and ( x %% n ) is 0
#...........................................................................................................
@declare 'buffer',  { size: 'length', },  ( x ) => Buffer.isBuffer      x
@declare 'list',    { size: 'length', },  ( x ) => ( @_js_type_of x ) is 'array'
@declare 'object',  { size: 'length', },  ( x ) => ( @_js_type_of x ) is 'object'
@declare 'text',    { size: 'length', },  ( x ) => ( @_js_type_of x ) is 'string'
@declare 'set',     { size: 'size',   },  ( x ) -> ( @_js_type_of x ) is 'set'      # { size_of: 'size',  }
@declare 'map',     { size: 'size',   },  ( x ) -> ( @_js_type_of x ) is 'map'      # { size_of: 'size',  }
@declare 'weakmap',                       ( x ) -> ( @_js_type_of x ) is 'weakmap'
@declare 'weakset',                       ( x ) -> ( @_js_type_of x ) is 'weakset'

#-----------------------------------------------------------------------------------------------------------
  # list:       'length'
  # # arguments:  'length'
  # buffer:     'length'
  # set:        'size'
  # map:        'size'
  # #.........................................................................................................
  # global:     ( x ) => ( @all_keys_of x ).length
  # pod:        ( x ) => ( @keys_of     x ).length
  # #.........................................................................................................
  # text:       ( x, selector = 'codeunits' ) ->
  #   switch selector
  #     when 'codepoints' then return ( Array.from x ).length
  #     when 'codeunits'  then return x.length
  #     when 'bytes'      then return Buffer.byteLength x, ( settings?[ 'encoding' ] ? 'utf-8' )
  #     else throw new Error "unknown counting selector #{rpr selector}"



# @declare 'boundfunction', { supertype: 'callable', }, ( x ) => ( ( @supertype_of x ) is 'callable' ) and ( not Object.hasOwnProperty x, 'prototype' )
# @declare 'boundfunction',       ( x ) => ( @isa 'callable', x ) and ( not Object.hasOwnProperty x, 'prototype' )

# Array.isArray
# ArrayBuffer.isView
# Atomics.isLockFree
# Buffer.isBuffer
# Buffer.isEncoding
# constructor.is
# constructor.isExtensible
# constructor.isFrozen
# constructor.isSealed
# Number.isFinite
# Number.isInteger
# Number.isNaN
# Number.isSafeInteger
# Object.is
# Object.isExtensible
# Object.isFrozen
# Object.isSealed
# Reflect.isExtensible
# root.isFinite
# root.isNaN
# Symbol.isConcatSpreadable


# debug Object.getOwnPropertyDescriptors @
# process.exit 1

#-----------------------------------------------------------------------------------------------------------
@create = ->
  # R           = Object.create @
  # R.specs     = Object.create @specs
  # R.isa       = ( P... ) => @isa P...
  # R.validate  = Object.create @validate
  # for k, v of R
  #   debug 'µ5009', k, v
    # R[ k ] = if v.bind? then v.bind R else v
  R = assign {}, @
  # assign R.isa,       @isa
  # assign R.validate,  @validate
  debug 'µ2229', @isa.number
  debug 'µ2229', R.isa.number
  debug 'µ2229', R.isa.number 42
  debug 'µ2229', R.isa.number '42'
  return R

#-----------------------------------------------------------------------------------------------------------
@get_bound_functions = ->
  R = {}
  for k, v of @
    ### TAINT use proper check for callable ###
    continue unless v.bind?
    R[ k ] = v.bind @
  return R

unless module.parent?

  #=========================================================================================================
  class Animal
    constructor: (@name) ->
      @friends = {}

    move: (meters) ->
      info @name + " moved #{meters}m."


  sam = new Animal "Sammy the Python"
  tom = new Animal "Tommy the Palomino"

  sam.move 5
  tom.move 5

  debug sam.friends
  debug tom.friends
  debug sam.friends is tom.friends
  process.exit 1

############################################################################################################
unless module.parent?
  INTERTYPE = @
  intertype = INTERTYPE.create()
  { isa
    validate
    type_of
    types_of
    size_of
    declare   } = intertype.get_bound_functions()
  info 'µ01-1', isa 'number', 42
  info 'µ01-2', isa 'number', NaN
  info 'µ01-3', isa 'text', NaN
  info 'µ01-4', isa 'text', 'x'
  whisper '-'.repeat 108
  info 'µ01-5', @_js_type_of ( -> )
  info 'µ01-6', @_js_type_of ( -> ).bind @
  info 'µ01-7', @_js_type_of ( -> yield 42 )
  info 'µ01-8', @_js_type_of ( -> yield 42 )()
  info 'µ01-9', @_js_type_of ( -> await 42 )
  whisper '-'.repeat 108
  info 'µ01-10', type_of ( -> )
  info 'µ01-11', type_of ( -> ).bind @
  info 'µ01-12', type_of ( -> yield 42 )
  info 'µ01-13', type_of ( -> yield 42 )()
  info 'µ01-14', type_of ( -> await 42 )
  whisper '-'.repeat 108
  info 'µ01-15', isa 'callable', 'xxx'
  info 'µ01-16', isa 'callable', ( -> )
  info 'µ01-17', isa 'callable', ( -> ).bind @
  info 'µ01-18', isa 'callable', ( -> yield 42 )
  info 'µ01-19', isa 'callable', ( -> yield 42 )()
  info 'µ01-20', isa 'callable', ( -> await 42 )
  whisper '-'.repeat 108
  info 'µ01-21', isa 'date', new Date()
  info 'µ01-22', type_of new Date()
  info 'µ01-23', isa 'number',      123
  info 'µ01-24', isa 'integer',     123
  info 'µ01-25', isa 'finite',      123
  info 'µ01-26', isa 'safeinteger', 123
  info 'µ01-27', type_of            123
  info 'µ01-28', isa.number         123
  info 'µ01-29', isa.integer        123
  info 'µ01-30', isa.finite         123
  info 'µ01-31', isa.safeinteger    123
  info 'µ01-32', types_of           123
  info 'µ01-33', types_of           124
  info 'µ01-34', types_of           0
  info 'µ01-35', types_of           true
  info 'µ01-36', types_of           null
  info 'µ01-37', types_of           undefined
  info 'µ01-38', types_of           {}
  info 'µ01-39', type_of            {}
  info 'µ01-40', types_of           []
  info 'µ01-41', type_of            []
  info 'µ01-42', jr INTERTYPE.all_keys_of  [ null, ]
  info 'µ01-43', type_of            global
  info 'µ01-44', isa 'global', global
  info 'µ01-45', isa 'number', NaN
  info 'µ01-46', type_of 'xxx'
  # info 'µ01-47', size_of 'xxx'
  # info 'µ01-48', isa 'array',  []

  X                 = {}
  X.x               = true
  X.spec            = {}
  X.spec.spec_of_X  = true
  Y                 = Object.create X
  Y.y               = true
  Y.spec            = Object.create X.spec
  Y.spec.spec_of_Y  = true
  debug X,        jr ( k for k of X )
  debug X.spec,   jr ( k for k of X.spec )
  debug Y,        jr ( k for k of Y )
  debug Y.spec,   jr ( k for k of Y.spec )
  Y.spec.spec_of_X  = false
  info X.spec.spec_of_X
  info X.spec.spec_of_Y
  info Y.spec.spec_of_X
  info Y.spec.spec_of_Y

  # xxx = require '../../intertype-abandoned/lib/main'
  # for gk from xxx.walk_all_keys_of global
  #   continue if gk in [ 'global', 'GLOBAL', ]
  #   for lk from xxx.walk_all_keys_of global[ gk ]
  #     continue unless lk.startsWith 'is'
  #     continue if lk is 'isPrototypeOf'
  #     info 'µ28882', "#{gk}.#{lk}"


###
isa 'integer', 42
isa.integer 42
isa.multiple_of 42, 2
isa[ 'multiple_of' ] 42, 2
isa.even 42
type_of 42 # 'number'
###




#-----------------------------------------------------------------------------------------------------------
get_rprs_of_tprs = ( tprs ) ->
  ### `tprs: test parameters, i.e. additional arguments to type tester, as in `multiple_of x, 4` ###
  rpr_of_tprs = switch tprs.length
    when 0 then ''
    when 1 then "#{rpr tprs[ 0 ]}"
    else "#{rpr tprs}"
  srpr_of_tprs = switch rpr_of_tprs.length
    when 0 then ''
    else ' ' + rpr_of_tprs
  return { rpr_of_tprs, srpr_of_tprs, }







