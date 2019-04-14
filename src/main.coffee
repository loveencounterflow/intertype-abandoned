
'use strict'

############################################################################################################
CND                       = require 'cnd'
rpr                       = CND.rpr
badge                     = 'INTERTYPE/MAIN'
debug                     = CND.get_logger 'debug',     badge
warn                      = CND.get_logger 'warn',      badge
info                      = CND.get_logger 'info',      badge
urge                      = CND.get_logger 'urge',      badge
help                      = CND.get_logger 'help',      badge
whisper                   = CND.get_logger 'whisper',   badge
echo                      = CND.echo.bind CND
#...........................................................................................................
{ assign
  jr }                    = CND
L                         = @
Ajv                       = require 'ajv'
@self                     = Symbol 'self'

#-----------------------------------------------------------------------------------------------------------
@_message_from_error = ( data, error ) ->
  R = []
  R.push "µ33892 property #{error.dataPath}: #{error.message} (got #{rpr error.data})"
  return R.join '\n'

#-----------------------------------------------------------------------------------------------------------
@_message_from_errors = ( data, errors ) ->
  R = []
  R.push @_message_from_error data, error for error in errors
  R.push ''
  R.push jr data
  R.push ''
  return R.join '\n'

#-----------------------------------------------------------------------------------------------------------
@new_validation_hub = ( settings = null ) ->
  defaults          =
    coerceTypes:        false ### must be false for nullable to work as expected, but check for defaults ###
    allErrors:          true
    verbose:            true
    nullable:           true ###  support keyword "nullable" from Open API 3 specification ###
    ### options to modify validated data: ###
    # removeAdditional:   false
    # useDefaults:        false
    # coerceTypes:        false
  #.........................................................................................................
  settings          = Object.assign {}, settings, defaults
  R                 = {}
  R[ @self ]        = new Ajv settings
  return R

#-----------------------------------------------------------------------------------------------------------
@add_schema_collection = ( me, schema_collection ) ->
  # delete schema.postprocess if ( postprocess = schema.postprocess )?
  # delete schema.copy        if ( copy        = schema.copy        )?
  # postprocess      ?= ( data ) -> data
  # validate_and_cast = me.add schema
  # return ( data ) =>
  #   R = if copy then CND.deep_copy data else data
  #   unless validate_and_cast R
  #     throw new Error @_message_from_errors R, validate_and_cast.errors
  #   return postprocess R
  # nr              = ( Object.keys me.keys ).length + 1
  # unless ( key = schema.$key )?
  #   throw new Error "µ62562 schema must have a `$key`, found none"
  # delet
  for typename, schema of schema_collection
    schema.$id ?= typename
    me[ @self ].addSchema schema, typename
  return null

# #-----------------------------------------------------------------------------------------------------------
# @compile = ( me ) ->
#   R = {}
#   for key, url in me.keys
#     R[ key ] = me[ @self ].compile url
#   debug 'µ38887', me
#   debug 'µ38887', R
#   return R

#-----------------------------------------------------------------------------------------------------------
@validate = ( me, key, x ) ->
  throw new Error ( @_message_from_errors x, me[ @self ].errors ) unless me[ @self ].validate key, x
  return x

