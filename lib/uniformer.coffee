
require 'js-yaml'
fs = require 'fs'
extend = require 'extend'

# this way it extendable if need be
# note the order is significant here...
# longer identifiers first
argumentIdentifiers = ["--","-"]


# add better array type checking
typeIsArray = Array.isArray || ( value ) -> return {}.toString.call( value ) is '[object Array]'

_typeProc = (val) ->
  if typeof val == 'number'
    return new Number(val);
  else if val.toLowerCase() == 'false'
    return false;
  else if val.toLowerCase() == 'true'
    return true;
  else
    return val;

# process chunk string cI
_chunkProc = (resultant,cI,arg) ->
  parent = resultant
  chunks = cI.split '.'
  for chunk in chunks
    if _i < chunks.length-1
      if not parent[chunk]?
        parent[chunk] = {}
      parent = parent[chunk]
  key = chunks[chunks.length-1]
  if not parent[key]?
    parent[key] = _typeProc arg
  else
    if typeIsArray parent[key]
      parent[key].push _typeProc arg
    else
      oldArg = parent[key]
      parent[key] = new Array()
      parent[key].push oldArg,_typeProc arg
  return resultant

# create a processed object from an argv
_proc = (argv) ->
  cI = null
  resultant = {}
  for arg in argv
    isKey = false
    for identifier in argumentIdentifiers
      isKey = (arg.substr(0,identifier.length) == identifier)
      if isKey
        cI = arg.substr identifier.length,arg.length
        break
    if !isKey and cI
      resultant = _chunkProc resultant,cI,arg
  return resultant

# path fixer
# todo: this
_resolve = (path) ->
  return __dirname+"/"+path

# uniform takes a spec object
#
# {
#   file:'path/to/config.(json|yaml)',
#   supported:[['key1','-k'],'key2','key3']
# }
#
#
# and loads from a config.json
# a config.yaml or process.argv
# arguments, to return a key-value
# object that makes sense.
#
# argv values override config file values
# on the returned key-value object

uniformer = (spec = null) ->
  argv = spec?.argv || process.argv #this is useful for tests
  resultant = {}
  if spec?.file? and fs.existsSync _resolve(spec.file)
    resultant = extend true,resultant,require(spec.file)
  resultant = extend true,resultant,_proc argv


module.exports = uniformer