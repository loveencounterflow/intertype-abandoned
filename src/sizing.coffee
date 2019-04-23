
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
# _xrpr                     = ( x ) -> inspect x, { colors: yes, breakLength: Infinity, maxArrayLength: Infinity, depth: Infinity, }
# xrpr                      = ( x ) -> ( _xrpr x )[ .. 500 ]


#===========================================================================================================
# OBJECT SIZES
#-----------------------------------------------------------------------------------------------------------
@_sizeof_method_from_spec = ( type, spec ) ->
  do ( s = spec.size ) =>
    return null unless s?
    switch type_of_s = @type_of s
      when 'text'     then return ( x ) -> x[ s ]
      when 'function' then return s
      when 'number'   then return -> s
    throw new Error "µ30988 expected null, a text or a function for size of #{type}, got a #{type_of_s}"

#-----------------------------------------------------------------------------------------------------------
@size_of = ( x, P... ) ->
  ### The `size_of()` method uses a per-type configurable methodology to return the size of a given value;
  such methodology may permit or necessitate passing additional arguments (such as `size_of text`, which
  comes in several flavors depending on whether bytes or codepoints are to be counted). As such, it is a
  model for how to implement Go-like method dispatching. ###
  # debug 'µ44744', [ x, P, ]
  type = @type_of x
  unless ( @isa.function ( getter = @specs[ type ]?.size ) )
    throw new Error "µ88793 unable to get size of a #{type}"
  return getter x, P...

#-----------------------------------------------------------------------------------------------------------
@first_of   = ( collection ) -> collection[ 0 ]
@last_of    = ( collection ) -> collection[ collection.length - 1 ]

#-----------------------------------------------------------------------------------------------------------
@arity_of = ( x ) ->
  unless ( type = @supertype_of x ) is 'callable'
    throw new Error "µ88733 expected a callable, got a #{type}"
  return x.length


