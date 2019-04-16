
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
test                      = require 'guy-test'
isa                       = require '../..'


#-----------------------------------------------------------------------------------------------------------
@[ "test type_of" ] = ( T ) ->
  T.eq ( isa new WeakMap()            ), 'weakmap'
  T.eq ( isa new Map()                ), 'map'
  T.eq ( isa new Set()                ), 'set'
  T.eq ( isa new Date()               ), 'date'
  T.eq ( isa new Error()              ), 'error'
  T.eq ( isa []                       ), 'list'
  T.eq ( isa true                     ), 'boolean'
  T.eq ( isa false                    ), 'boolean'
  T.eq ( isa ( -> )                   ), 'function'
  T.eq ( isa ( -> yield 123 )         ), 'generatorfunction'
  T.eq ( isa ( -> yield 123 )()       ), 'generator'
  T.eq ( isa ( -> await f() )         ), 'asyncfunction'
  T.eq ( isa null                     ), 'null'
  T.eq ( isa 'helo'                   ), 'text'
  T.eq ( isa undefined                ), 'undefined'
  T.eq ( isa arguments                ), 'arguments'
  T.eq ( isa global                   ), 'global'
  T.eq ( isa /^xxx$/g                 ), 'regex'
  T.eq ( isa {}                       ), 'pod'
  T.eq ( isa NaN                      ), 'nan'
  T.eq ( isa 1 / 0                    ), 'infinity'
  T.eq ( isa -1 / 0                   ), 'infinity'
  T.eq ( isa 12345                    ), 'number'
  T.eq ( isa new Buffer 'helo'        ), 'buffer'
  T.eq ( isa new ArrayBuffer 42       ), 'arraybuffer'
  #.........................................................................................................
  T.eq ( isa new Int8Array         5  ), 'int8array'
  T.eq ( isa new Uint8Array        5  ), 'uint8array'
  T.eq ( isa new Uint8ClampedArray 5  ), 'uint8clampedarray'
  T.eq ( isa new Int16Array        5  ), 'int16array'
  T.eq ( isa new Uint16Array       5  ), 'uint16array'
  T.eq ( isa new Int32Array        5  ), 'int32array'
  T.eq ( isa new Uint32Array       5  ), 'uint32array'
  T.eq ( isa new Float32Array      5  ), 'float32array'
  T.eq ( isa new Float64Array      5  ), 'float64array'
  #.........................................................................................................
  return null

#-----------------------------------------------------------------------------------------------------------
@[ "test size_of" ] = ( T ) ->
  # debug ( new Buffer '𣁬', ), ( '𣁬'.codePointAt 0 ).toString 16
  # debug ( new Buffer '𡉜', ), ( '𡉜'.codePointAt 0 ).toString 16
  # debug ( new Buffer '𠑹', ), ( '𠑹'.codePointAt 0 ).toString 16
  # debug ( new Buffer '𠅁', ), ( '𠅁'.codePointAt 0 ).toString 16
  T.eq ( isa.size_of [ 1, 2, 3, 4, ]                                    ), 4
  T.eq ( isa.size_of new Buffer [ 1, 2, 3, 4, ]                         ), 4
  T.eq ( isa.size_of '𣁬𡉜𠑹𠅁'                                             ), 2 * ( Array.from '𣁬𡉜𠑹𠅁' ).length
  T.eq ( isa.size_of '𣁬𡉜𠑹𠅁', count: 'codepoints'                        ), ( Array.from '𣁬𡉜𠑹𠅁' ).length
  T.eq ( isa.size_of '𣁬𡉜𠑹𠅁', count: 'codeunits'                         ), 2 * ( Array.from '𣁬𡉜𠑹𠅁' ).length
  T.eq ( isa.size_of '𣁬𡉜𠑹𠅁', count: 'bytes'                             ), ( new Buffer '𣁬𡉜𠑹𠅁', 'utf-8' ).length
  T.eq ( isa.size_of 'abcdefghijklmnopqrstuvwxyz'                       ), 26
  T.eq ( isa.size_of 'abcdefghijklmnopqrstuvwxyz', count: 'codepoints'  ), 26
  T.eq ( isa.size_of 'abcdefghijklmnopqrstuvwxyz', count: 'codeunits'   ), 26
  T.eq ( isa.size_of 'abcdefghijklmnopqrstuvwxyz', count: 'bytes'       ), 26
  T.eq ( isa.size_of 'ä'                                                ), 1
  T.eq ( isa.size_of 'ä', count: 'codepoints'                           ), 1
  T.eq ( isa.size_of 'ä', count: 'codeunits'                            ), 1
  T.eq ( isa.size_of 'ä', count: 'bytes'                                ), 2
  T.eq ( isa.size_of new Map [ [ 'foo', 42, ], [ 'bar', 108, ], ]       ), 2
  T.eq ( isa.size_of new Set [ 'foo', 42, 'bar', 108, ]                 ), 4
  T.eq ( isa.size_of { 'foo': 42, 'bar': 108, 'baz': 3, }                           ), 3
  T.eq ( isa.size_of { '~isa': 'XYZ/yadda', 'foo': 42, 'bar': 108, 'baz': 3, }      ), 4

#-----------------------------------------------------------------------------------------------------------
@[ "_demo" ] = ( T ) ->
  isa = @

  x =
    foo: 42
    bar: 108
  y = Object.create x
  y.bar = 'something'
  y.baz = 'other thing'

  ```
  const person = {
    isHuman: false,
    printIntroduction: function () {
      console.log(`My name is ${this.name}. Am I human? ${this.isHuman}`);
    }
  };

  const me = Object.create(person);
  me.name = "Matthew"; // "name" is a property set on "me", but not on "person"
  me.isHuman = true; // inherited properties can be overwritten

  me.printIntroduction();

  ```
  # urge me.prototype?
  # urge me.__proto__?

  info 'µ1', jr isa.generator_function isa.all_own_keys_of
  info 'µ2', jr isa.values_of isa.all_own_keys_of 'abc'
  info 'µ3', jr isa.values_of isa.all_keys_of 'abc'
  info 'µ4', jr isa.values_of isa.all_keys_of x
  info 'µ5', jr isa.values_of isa.all_keys_of y
  info 'µ5', jr isa.values_of isa.all_keys_of y, true
  info 'µ6', jr isa.values_of isa.all_keys_of me
  info 'µ7', jr isa.values_of isa.all_keys_of {}
  info 'µ8', jr isa.values_of isa.all_keys_of Object.create null
  info 'µ9', isa.keys_of me
  info 'µ9', jr isa.values_of isa.keys_of me
  # info 'µ10', jr ( k for k of me )
  # info 'µ11', jr Object.keys me
  # info 'µ12', isa.values_of isa.all_own_keys_of true
  # info 'µ13', isa.values_of isa.all_own_keys_of undefined
  # info 'µ14', isa.values_of isa.all_own_keys_of null

  # debug '' + rpr Object.create null
  # debug isa.values_of isa.all_keys_of Object::

  urge CND.type_of ( -> )
  urge CND.type_of ( -> yield 4 )
  urge CND.type_of ( -> yield 4 )()
  urge CND.type_of ( -> await f() )
  urge CND.isa ( -> ), 'function'
  urge CND.isa ( -> yield 4 ), 'function'
  urge CND.isa ( -> yield 4 )(), 'function'
  urge CND.isa ( -> await f() ), 'function'






############################################################################################################
unless module.parent?
  test @
