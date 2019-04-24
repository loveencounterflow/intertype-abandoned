
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
INTERTYPE                 = require '../..'
{ Intertype, }            = INTERTYPE
{ assign
  jr
  flatten
  xrpr
  js_type_of }            = require '../helpers'


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
  T.eq ( isa.size_of '𣁬𡉜𠑹𠅁'                                         ), 2 * ( Array.from '𣁬𡉜𠑹𠅁' ).length
  T.eq ( isa.size_of '𣁬𡉜𠑹𠅁', 'codepoints'                           ), ( Array.from '𣁬𡉜𠑹𠅁' ).length
  T.eq ( isa.size_of '𣁬𡉜𠑹𠅁', 'codeunits'                            ), 2 * ( Array.from '𣁬𡉜𠑹𠅁' ).length
  T.eq ( isa.size_of '𣁬𡉜𠑹𠅁', 'bytes'                                ), ( new Buffer '𣁬𡉜𠑹𠅁', 'utf-8' ).length
  T.eq ( isa.size_of 'abcdefghijklmnopqrstuvwxyz'                       ), 26
  T.eq ( isa.size_of 'abcdefghijklmnopqrstuvwxyz', 'codepoints'         ), 26
  T.eq ( isa.size_of 'abcdefghijklmnopqrstuvwxyz', 'codeunits'          ), 26
  T.eq ( isa.size_of 'abcdefghijklmnopqrstuvwxyz', 'bytes'              ), 26
  T.eq ( isa.size_of 'ä'                                                ), 1
  T.eq ( isa.size_of 'ä', 'codepoints'                                  ), 1
  T.eq ( isa.size_of 'ä', 'codeunits'                                   ), 1
  T.eq ( isa.size_of 'ä', 'bytes'                                       ), 2
  T.eq ( isa.size_of new Map [ [ 'foo', 42, ], [ 'bar', 108, ], ]       ), 2
  T.eq ( isa.size_of new Set [ 'foo', 42, 'bar', 108, ]                 ), 4
  T.eq ( isa.size_of { 'foo': 42, 'bar': 108, 'baz': 3, }                           ), 3
  ### TAINT re-implement types object, pod ###
  # T.eq ( isa.size_of { '~isa': 'XYZ/yadda', 'foo': 42, 'bar': 108, 'baz': 3, }      ), 4

#-----------------------------------------------------------------------------------------------------------
@[ "_demo 1" ] = ( T ) ->
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


#-----------------------------------------------------------------------------------------------------------
@[ "multiple tests" ] = ( T, done ) ->
  #.........................................................................................................
  probes_and_matchers = [
    ["isa.number( 42 )",true,null]
    ["isa.finite_number( 42 )",true,null]
    ["isa.infinity( Infinity )",true,null]
    ["isa.infinity( 42 )",false,null]
    ["isa.integer( 42 )",true,null]
    ["isa.integer( 42.1 )",false,null]
    ["isa.count( 42 )",true,null]
    ["isa.count( -42 )",false,null]
    ["isa.count( 42.1 )",false,null]
    ["isa.callable( 42.1 )",false,null]
    ["isa.extends( 'function', 'callable' )",true,null]
    ["isa.extends( 'safe_integer', 'integer' )",true,null]
    ["isa.extends( 'safe_integer', 'number' )",true,null]
    ["isa.type_of( 42 )","number",null]
    ["isa.type_of( 42.1 )","number",null]
    ["isa.supertype_of( 42 )","number",null]
    ["isa.supertype_of( 42.1 )","number",null]
    ["isa.multiple_of( 33, 3 )",true,null]
    ["isa.multiple_of( 33, 11 )",true,null]
    ["isa.multiple_of( 5, 2.5 )",true,null]
    ["isa.multiple_of( 5, 2.6 )",false,null]
    ["isa.even( Infinity )",false,null]
    ["isa.odd( Infinity )",false,null]
    ["isa.callable( () => {} )",true,null]
    ["isa.type_of( () => {} )","function",null]
    ["isa.type_of( async () => { return await f() } )","asyncfunction",null]
    ["isa.supertype_of( () => {} )","callable",null]
    ["isa.supertype_of( async () => { return await f(); } )","callable",null]
    ["isa.callable( function() {} )",true,null]
    ["isa.type_of( function() {} )","function",null]
    ["isa.type_of( async function() { return await f(); } )","asyncfunction",null]
    ["isa.supertype_of( function() {} )","callable",null]
    ["isa.supertype_of( async function() { return await f(); } )","callable",null]
    ["isa.keys_of( { line: 42, ch: 33, } )",["line","ch"],null]
    ["isa.keys_of( { line: 42, } )",["line"],null]
    ["isa.keys_of( { line: 42, ch: undefined, } )",["line"],null]
    ["isa.has_keys( { line: 42, ch: 33, }, [ 'line', ] )",true,null]
    ["isa.has_keys( { line: 42, ch: undefined, }, [ 'line', 'ch', ] )",false,null]
    ["isa.has_keys( { line: 42, ch: 33, }, [ 'line', 'ch', ] )",true,null]
    ["isa.has_keys( { line: 42, ch: 33, }, [ 'line', 'ch', 'other', ] )",false,null]
    ["isa.has_only_keys( { line: 42, ch: 33, }, [ 'line', ] )",false,null]
    ["isa.has_only_keys( { line: 42, ch: undefined, }, [ 'line', 'ch', ] )",false,null]
    ["isa.has_only_keys( { line: 42, ch: 33, }, [ 'line', 'ch', ] )",true,null]
    ["isa.has_only_keys( { line: 42, ch: 33, }, [ 'line', 'ch', 'other', ] )",false,null]
    ]
  #.........................................................................................................
  for [ probe, matcher, error, ] in probes_and_matchers
    await T.perform probe, matcher, error, -> return new Promise ( resolve, reject ) ->
      result = eval probe
      # log jr [ probe, result, ]
      # resolve result
      resolve result
      return null
  done()
  return null


#-----------------------------------------------------------------------------------------------------------
@[ "_demo 2" ] = ( T, done ) ->
  intertype = new Intertype
  { isa
    validate
    type_of
    types_of
    size_of
    declare
    all_keys_of } = intertype.export_methods()
  T.eq ( isa 'callable',      'xxx'              ), false
  T.eq ( isa 'callable',      ( -> )             ), true
  T.eq ( isa 'callable',      ( -> ).bind @      ), true
  T.eq ( isa 'callable',      ( -> await 42 )    ), true
  T.eq ( isa 'callable',      ( -> yield 42 )    ), true
  T.eq ( isa 'callable',      ( -> yield 42 )()  ), false
  T.eq ( isa 'date',          new Date()         ), true
  T.eq ( isa 'date',          Date.now()         ), false
  T.eq ( isa 'finite',        123                ), true
  T.eq ( isa 'global',        global             ), true
  T.eq ( isa 'integer',       123                ), true
  T.eq ( isa 'integer',       42                 ), true
  T.eq ( isa 'number',        123                ), true
  T.eq ( isa 'number',        42                 ), true
  T.eq ( isa 'number',        NaN                ), false
  T.eq ( isa 'number',        NaN                ), false
  T.eq ( isa 'safeinteger',   123                ), true
  T.eq ( isa 'text',          'x'                ), true
  T.eq ( isa 'text',          NaN                ), false
  T.eq ( isa.even             42                 ), true
  T.eq ( isa.finite           123                ), true
  T.eq ( isa.integer          123                ), true
  T.eq ( isa.integer          42                 ), true
  T.eq ( isa.multiple_of      42, 2              ), true
  T.eq ( isa.number           123                ), true
  T.eq ( isa.safeinteger      123                ), true
  T.eq ( isa[ 'multiple_of' ] 42, 2              ), true
  info 'µ01-27', xrpr type_of              'xxx'
  info 'µ01-28',  xrpr type_of              ( -> )
  info 'µ01-29',  xrpr type_of              ( -> ).bind @
  info 'µ01-30',  xrpr type_of              ( -> await 42 )
  info 'µ01-31',  xrpr type_of              ( -> yield 42 )
  info 'µ01-32',  xrpr type_of              ( -> yield 42 )()
  info 'µ01-33', xrpr type_of              123
  info 'µ01-34', xrpr type_of              42
  info 'µ01-35', xrpr type_of              []
  info 'µ01-36', xrpr type_of              global
  info 'µ01-37', xrpr type_of              new Date()
  info 'µ01-38', xrpr type_of              {}
  info 'µ01-39', xrpr types_of             123
  info 'µ01-40', xrpr types_of             124
  info 'µ01-41', xrpr types_of             0
  info 'µ01-42', xrpr types_of             true
  info 'µ01-43', xrpr types_of             null
  info 'µ01-44', xrpr types_of             undefined
  info 'µ01-45', xrpr types_of             {}
  info 'µ01-46', xrpr types_of             []
  info 'µ01-47', xrpr all_keys_of          [ null, ]
  done()




























  ###
  # info size_of 'xxx'
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
  ###



# #-----------------------------------------------------------------------------------------------------------
# @[ "nasty error message, tamed" ] = ( T, done ) ->
#   try
#     isa.validate.text ```{ isa: 'disk', path: 'dsk0', size: 1000000, free: -5572, files: [ { path:
#     '/media/somewhere/foobar/lib/main.js', size: 11282 }, { path: '/media/somewhere/foobar/lib/main.js.map',
#     size: 18962 }, { path: '/media/somewhere/foobar/node_modules/unset-value/index.js', size: 756 }, { path:
#     '/media/somewhere/foobar/node_modules/unset-value/LICENSE', size: 1088 }, { path:
#     '/media/somewhere/foobar/node_modules/unset-value/node_modules/has-value/index.js', size: 426 }, { path:
#     '/media/somewhere/foobar/node_modules/unset-value/node_modules/has-value/LICENSE', size: 1088 }, { path:
#     '/media/somewhere/foobar/node_modules/unset-value/node_modules/has-value/node_modules/isobject/index.js',
#     size: 317 }, { path:
#     '/media/somewhere/foobar/node_modules/unset-value/node_modules/has-value/node_modules/isobject/LICENSE',
#     size: 1088 }, { path:
#     '/media/somewhere/foobar/node_modules/unset-value/node_modules/has-value/node_modules/isobject/package.json',
#     size: 2120 }, { path:
#     '/media/somewhere/foobar/node_modules/unset-value/node_modules/has-value/node_modules/isobject/README.md',
#     size: 2999 }, { path:
#     '/media/somewhere/foobar/node_modules/unset-value/node_modules/has-value/package.json', size: 2372 }, {
#     path: '/media/somewhere/foobar/node_modules/unset-value/node_modules/has-value/README.md', size: 3244 }, {
#     path: '/media/somewhere/foobar/node_modules/unset-value/node_modules/has-values/index.js', size: 615 }, {
#     path: '/media/somewhere/foobar/node_modules/unset-value/node_modules/has-values/LICENSE', size: 1088 }, {
#     path: '/media/somewhere/foobar/node_modules/unset-value/node_modules/has-values/package.json', size: 2294
#     }, { path: '/media/somewhere/foobar/node_modules/unset-value/node_modules/has-values/README.md', size:
#     2821 }, { path: '/media/somewhere/foobar/node_modules/unset-value/package.json', size: 2459 }, { path:
#     '/media/somewhere/foobar/node_modules/unset-value/README.md', size: 5239 }, { path:
#     '/media/somewhere/foobar/node_modules/fragment-cache/index.js', size: 3075 }, { path:
#     '/media/somewhere/foobar/node_modules/fragment-cache/LICENSE', size: 1087 }, { path:
#     '/media/somewhere/foobar/node_modules/fragment-cache/package.json', size: 2094 }, { path:
#     '/media/somewhere/foobar/node_modules/fragment-cache/README.md', size: 4585 }, { path:
#     '/media/somewhere/foobar/node_modules/map-visit/index.js', size: 967 }, { path:
#     '/media/somewhere/foobar/node_modules/map-visit/LICENSE', size: 1087 }, { path:
#     '/media/somewhere/foobar/node_modules/map-visit/package.json', size: 2446 }, { path:
#     '/media/somewhere/foobar/node_modules/map-visit/README.md', size: 4942 }, { path:
#     '/media/somewhere/foobar/node_modules/pull-tee/test/index.js', size: 983 }, { path:
#     '/media/somewhere/foobar/node_modules/pull-tee/index.js', size: 674 }, { path:
#     '/media/somewhere/foobar/node_modules/pull-tee/LICENSE', size: 1071 }, { path:
#     '/media/somewhere/foobar/node_modules/pull-tee/package.json', size: 1393 }, { path:
#     '/media/somewhere/foobar/node_modules/pull-tee/README.md', size: 29 }, { path:
#     '/media/somewhere/foobar/node_modules/pull-tee/.npmignore', size: 42 }, { path:
#     '/media/somewhere/foobar/node_modules/pull-tee/.travis.yml', size: 43 }, { path:
#     '/media/somewhere/foobar/node_modules/static-extend/index.js', size: 2271 }, { path:
#     '/media/somewhere/foobar/node_modules/static-extend/LICENSE', size: 1083 }, { path:
#     '/media/somewhere/foobar/node_modules/static-extend/node_modules/define-property/index.js', size: 753 }, {
#     path: '/media/somewhere/foobar/node_modules/static-extend/node_modules/define-property/LICENSE', size:
#     1083 }, { path:
#     '/media/somewhere/foobar/node_modules/static-extend/node_modules/define-property/package.json', size: 1936
#     }, { path: '/media/somewhere/foobar/node_modules/static-extend/node_modules/define-property/README.md',
#     size: 2413 }, { path: '/media/somewhere/foobar/node_modules/static-extend/package.json', size: 2265 }, {
#     path: '/media/somewhere/foobar/node_modules/inherits/inherits_browser.js', size: 672 }, { path:
#     '/media/somewhere/foobar/node_modules/inherits/LICENSE', size: 749 }, { path:
#     '/media/somewhere/foobar/node_modules/inherits/package.json', size: 1475 }, { path:
#     '/media/somewhere/foobar/node_modules/inherits/README.md', size: 1625 }, { path:
#     '/media/somewhere/foobar/node_modules/inherits/inherits.js', size: 192 }, { path:
#     '/media/somewhere/foobar/node_modules/object.pick/index.js', size: 630 }, { path:
#     '/media/somewhere/foobar/node_modules/object.pick/LICENSE', size: 1088 }, { path:
#     '/media/somewhere/foobar/node_modules/object.pick/package.json', size: 2102 }, { path:
#     '/media/somewhere/foobar/node_modules/object.pick/README.md', size: 3435 }, { path:
#     '/media/somewhere/foobar/node_modules/micromatch/index.js', size: 23853 }, { path:
#     '/media/somewhere/foobar/node_modules/micromatch/lib/compilers.js', size: 1827 }, { path:
#     '/media/somewhere/foobar/node_modules/micromatch/lib/parsers.js', size: 2027 }, { path:
#     '/media/somewhere/foobar/node_modules/micromatch/lib/.DS_Store', size: 6148 }, { path:
#     '/media/somewhere/foobar/node_modules/micromatch/lib/cache.js', size: 52 }, { path:
#     '/media/somewhere/foobar/node_modules/micromatch/lib/utils.js', size: 7258 }, { path:
#     '/media/somewhere/foobar/node_modules/micromatch/LICENSE', size: 1088 }, { path:
#     '/media/somewhere/foobar/node_modules/micromatch/CHANGELOG.md', size: 1129 }, { path:
#     '/media/somewhere/foobar/node_modules/micromatch/package.json', size: 4586 }, { path:
#     '/media/somewhere/foobar/node_modules/micromatch/README.md', size: 38227 }, { path:
#     '/media/somewhere/foobar/node_modules/nanomatch/index.js', size: 22642 }, { path:
#     '/media/somewhere/foobar/node_modules/nanomatch/lib/compilers.js', size: 8449 }, { path:
#     '/media/somewhere/foobar/node_modules/nanomatch/lib/parsers.js', size: 7627 }, { path:
#     '/media/somewhere/foobar/node_modules/nanomatch/lib/cache.js', size: 52 }, { path:
#     '/media/somewhere/foobar/node_modules/nanomatch/lib/utils.js', size: 8808 }, { path:
#     '/media/somewhere/foobar/node_modules/nanomatch/LICENSE', size: 1088 }, { path:
#     '/media/somewhere/foobar/node_modules/nanomatch/CHANGELOG.md', size: 1490 }, { path:
#     '/media/somewhere/foobar/node_modules/nanomatch/package.json', size: 3707 }, { path:
#     '/media/somewhere/foobar/node_modules/nanomatch/README.md', size: 33388 }, { path:
#     '/media/somewhere/foobar/node_modules/ret/lib/index.js', size: 6555 }, { path:
#     '/media/somewhere/foobar/node_modules/ret/lib/util.js', size: 2616 }, { path:
#     '/media/somewhere/foobar/node_modules/ret/lib/sets.js', size: 2230 }, { path:
#     '/media/somewhere/foobar/node_modules/ret/lib/positions.js', size: 367 }, { path:
#     '/media/somewhere/foobar/node_modules/ret/lib/types.js', size: 166 }, { path:
#     '/media/somewhere/foobar/node_modules/ret/LICENSE', size: 1061 }, { path:
#     '/media/somewhere/foobar/node_modules/ret/package.json', size: 1603 }, { path:
#     '/media/somewhere/foobar/node_modules/ret/README.md', size: 4241 }, { path:
#     '/media/somewhere/foobar/node_modules/pull-paramap/test/index.js', size: 4176 }, { path:
#     '/media/somewhere/foobar/node_modules/pull-paramap/test/order.js', size: 480 }, { path:
#     '/media/somewhere/foobar/node_modules/pull-paramap/index.js', size: 1534 }, { path:
#     '/media/somewhere/foobar/node_modules/pull-paramap/LICENSE', size: 1071 }, { path:
#     '/media/somewhere/foobar/node_modules/pull-paramap/package.json', size: 1543 }, { path:
#     '/media/somewhere/foobar/node_modules/pull-paramap/README.md', size: 951 }, { path:
#     '/media/somewhere/foobar/node_modules/pull-paramap/.travis.yml', size: 54 }, { path:
#     '/media/somewhere/foobar/node_modules/glob/glob.js', size: 19433 }, { path:
#     '/media/somewhere/foobar/node_modules/glob/changelog.md', size: 1430 }, { path:
#     '/media/somewhere/foobar/node_modules/glob/LICENSE', size: 765 }, { path:
#     '/media/somewhere/foobar/node_modules/glob/package.json', size: 1922 }, { path:
#     '/media/somewhere/foobar/node_modules/glob/README.md', size: 14664 }, { path:
#     '/media/somewhere/foobar/node_modules/glob/sync.js', size: 12002 }, { path:
#     '/media/somewhere/foobar/node_modules/glob/common.js', size: 6167 }, { path:
#     '/media/somewhere/foobar/node_modules/extglob/index.js', size: 8172 }, { path:
#     '/media/somewhere/foobar/node_modules/extglob/lib/compilers.js', size: 4001 }, { path:
#     '/media/somewhere/foobar/node_modules/extglob/lib/parsers.js', size: 3172 }, { path:
#     '/media/somewhere/foobar/node_modules/extglob/lib/.DS_Store', size: 6148 }, { path:
#     '/media/somewhere/foobar/node_modules/extglob/lib/utils.js', size: 1274 }, { path:
#     '/media/somewhere/foobar/node_modules/extglob/lib/extglob.js', size: 1735 }, { path:
#     '/media/somewhere/foobar/node_modules/extglob/changelog.md', size: 589 }, { path:
#     '/media/somewhere/foobar/node_modules/extglob/LICENSE', size: 1088 }, { path:
#     '/media/somewhere/foobar/node_modules/extglob/node_modules/extend-shallow/index.js', size: 576 }, { path:
#     '/media/somewhere/foobar/node_modules/extglob/node_modules/extend-shallow/LICENSE', size: 1088 }, ] }```
#   catch error
#     throw error
#     T.ok ( error.message.match /not a valid text:/ )?
#   T.fail "no error raised" unless error?
#   done()


############################################################################################################
unless module.parent?
  # test @
  # test @[ "multiple tests" ]
  # test @[ "nasty error message, tamed" ]
  test @[ "_demo 2" ]


