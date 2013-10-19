require 'js-yaml'
fs = require 'fs'
extend = require 'extend'

_debugState = 'console';
_debug = (msg...) ->
  switch _debugState
    when 'console'
      for m in msg 
        console.log m

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
  if dotted.length <= 1
    return false
  else
    return dotted

#determine if kv, and return a kv
isKv = (val) ->
  if not isString val
    return false
  eq = val.split '='
  if eq.length == 1
    return false
  result = {key:eq[0],value:eq[1]} #<unsupported> kv only supports one value

#allows us to validate key format
isKeyValid = ( key ) ->
  if not key?
    return false
  if not isString key
    return false
  return true
#determine if a config 'key' value is supported
_supported = null
isSupported = (key) ->
  if not _supported?
    return true
  for support in supported
    if key == support
      return true
  return false


#determine if we can make an object = value
canMake = (object,value) ->
  if not object?
    return value
  if isObject object
    return false # we don't override objects
  else if isArray object
    if isArray value
      return object.concat value #we merge into arrays
    else
      return object.push value #we merge into arrays
  else
    return value #we override literals


# convert string types back to normal types
typeChange = (val) ->
  if not val?
    return val
  else if not isNaN val
    _debug "typechange to number for "+val
    return parseInt val
  else if val.toLowerCase() == 'false'
    _debug "typechange to false for "+val
    return false;
  else if val.toLowerCase() == 'true'
    _debug "typechange to true for "+val
    return true;
  else
    _debug "no typechange needed for "+val
    return val;

# process a file
procFile = (file) ->
  if fs.existsSync file
    return require file

# process an argv
procArgs = (argv) ->
  root = {}
  for arg,aindex in argv
    if (key = isKey arg) != false
      if isSupported key and isKeyValid key

        _debug "key found "+key
        vals = []
        for vindex in [aindex+1..argv.length-1] by 1 #keep in mind, this wrecks speed
          if isKey(argv[vindex]) == false
            _debug "adding value "+argv[vindex]
            vals.push typeChange argv[vindex]
            delete argv[vindex] # this speeds up the outter loop
          else
            break
        #now we have our vals array populated
        if (kv = isKv key) != false
          _debug "kv parsed "+kv.key+"="+kv.value
          vals = typeChange kv.value #.splice 0,0,  #frontload this so it's vals[0]
          key = kv.key
        #corrected for kv
        if vals.length == 0
          _debug "no values found, setting to true"
          vals = true
        #corrected for boolean if only --key
        if (nest = isNested key) != false
          _debug "processing nest "+nest.toString()
          ptr = root
          for chunk,cindex in nest
            if cindex<nest.length-1
              if (entry = canMake(ptr[chunk],{})) != false
                ptr[chunk] = entry
              else
                _debug "cannot make entry under "+chunk
            else
              if (entry = canMake(ptr[chunk],vals))
                ptr[chunk] = entry
                _debug "made "+entry+" under "+chunk
              else
                _debug "cannot make entry under "+chunk
            ptr = ptr[chunk]
        #corrected and entered for nest
        else
          if (entry = canMake(root[key],vals)) != false
            root[key] = entry
          else
            _debug "cannot make entry "+root[key]
        #entered for non-nest
      else
        _debug key+" is not supported"
  return root

defaults = {
  argv: process.argv,
  debug: 'console'
}
uniformer = (opts = null) ->
  if opts? and isString opts
    opts = extend true,defaults,{file:opts}
  else
    opts = extend true,defaults,opts
  if opts['supported']?
    _supported = opts['supported']
  else
    _supported = null
  processed = extend true,{},procArgs opts.argv
  if processed["config"]? and not isSupported "config"
    opts.file = processed["config"]
    delete processed["config"]
  if opts.file?
    processed = extend true,procFile(__dirname+"/"+opts.file),processed #<unsupported> non __dirname opts.file
  return processed


module.exports = uniformer