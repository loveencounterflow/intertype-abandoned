
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
#...........................................................................................................
Multimix                  = require 'multimix'
#...........................................................................................................
{ assign
  jr
  flatten
  xrpr
  js_type_of }            = require './helpers'
#...........................................................................................................
declarations              = require './declarations'


#-----------------------------------------------------------------------------------------------------------
isa = ( type, xP... ) ->
  # debug 'µ33444', type, xP
  # debug 'µ33444', ( k for k of @ )
  return true if ( @type_of xP... ) is type
  return @_check_spec type, xP...

#-----------------------------------------------------------------------------------------------------------
@_validate = ( type, xP... ) ->

#-----------------------------------------------------------------------------------------------------------
@validate = new Proxy @_validate,
  get: ( target, type ) -> ( P... ) => target type, P...


#===========================================================================================================
class @Intertype extends Multimix
  # @extend   object_with_class_properties
  @include require './cataloguing'
  @include require './sizing'
  @include require './declaring'

  #---------------------------------------------------------------------------------------------------------
  constructor: ( @instance_name ) ->
    super()
    @specs    = {}
    @isa      = Multimix.get_keymethod_proxy @, isa
    # @validate = Multimix.get_keymethod_proxy @, validate
    declarations.declare_types.apply @




