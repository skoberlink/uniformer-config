require 'js-yaml'
fs = require 'fs'
extend = require 'extend'

# some helpful type checkers
isArray = Array.isArray || ( value ) -> return {}.toString.call( value ) is '[object Array]'
isString = ( value ) -> return typeof value == 'string'
isBool = ( value ) -> return typeof value == 'boolean'
isObject = ( value ) -> return typeof value == 'object'

# determine if a value is a config 'key' value
isKey = (val,keyDefs = ['--','-']) ->
  if isString val
    for keyDef in keyDefs
      if val.substr(0,keyDef.length)==keyDef
        return val.substr(keyDef.length,val.length)
  return false

# determine if a value is a nested key value, and return a nest
isNested = (val) ->
  if not isString val
    return false
  dotted = val.split '.'
  if dotted.length <= 0
    return false
  else
    return dotted

#determine if kv, and return a kv
isKv = (val) ->
  if not isString val
    return false
  eq = val.split '='
  if eq.length <= 0
    return false
  result = {key:eq[0],value:eq[1]} #<unsupported> kv only supports one value


#determine if a config 'key' value is supported
isSupported = (key,supported = null) ->
  if not supported?
    return true
  for support in supported
    if key == support
      return true
  return false

# convert string types back to normal types
typeChange = (val) ->
  if typeof val == 'number'
    return new Number(val);
  else if val.toLowerCase() == 'false'
    return false;
  else if val.toLowerCase() == 'true'
    return true;
  else
    return val;

# process a file
procFile = (file) ->
  if fs.existsSync file
    return require file

# process an argv
procArgs = (argv) ->
  root = {}
  for arg,index in argv
    if (key = isKey arg) != false
      values = []
      if (kv = isKv arg) != false
        key = kv.key
        values.push typeChange kv.value
      for vindex in [index..argv.length-1] by 1
        if not isKey argv[vindex]
          values.push typeChange argv[vindex]
        else
          break
      if values.length == 1
        values = values[0]
      else if values.length == 0
        values = true
      # now we have the values for that key
      if (nested = isNested key) != false
        ptr = root
        for chunk,cindex in nested
          if cindex < nested.length-1
            if ptr[chunk]? and not isObject ptr[chunk]
              _debug "argv value tried to override existing structure "+ptr[chunk]
              break
            if not ptr[chunk]?
              ptr[chunk] = {}
            ptr = ptr[chunk]
          else
            if ptr[chunk]? and isArray ptr[chunk]
              if isArray values
                ptr[chunk] = ptr[chunk].join values
              else
                ptr[chunk].push values
            else if ptr[chunk]? and isObject ptr[chunk]
              _debug "argv value tried to override existing structure "+ptr[chunk]
              break
            else if not ptr[chunk]?
              ptr[chunk] = values
      else
        if root[key]? and isObject root[key]
          _debug "argv value tried to override existing structure "+root[key]
          continue 
        else if root[key]? and isArray root[key]
            if isArray values
              root[key] = root[key].join values
            else
              root[key].push values
        else if not root[key]?
          root[key] = values
  return root
         
  

defaults = {
  argv: process.argv
}
uniformer = (opts = null) ->
  if opts? and isObject opts
    opts = extend true,defaults,opts
  else if opts? and isString opts
    opts = extend true,defaults,{file:opts}
  processed = extend true,{},procArgs opts.argv
  if processed["config"]? and not isSupported("config",opts.supported || null)
    opts.file = processed["config"]
    delete processed["config"]
  if opts.file?
    processed = extend true,procFile(__dirname+"/"+opts.file),processed #<unsupported> non __dirname opts.file
  return processed


module.exports = uniformer