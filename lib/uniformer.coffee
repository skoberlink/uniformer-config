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
isNested = (val,fillVal = true) ->
  if not isString val
    return false
  dotted = val.split '.'
  if dotted.length <= 0
    return false
  result = {nested:{},key:dotted[0]}
  it = result.nested
  for dot in dotted
    if _i > 1 and _i < _len-1
      it[dot] = {}
      it = it[dot]
  it[dotted[dotted.length-1]] = fillVal
  return result

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
procArgs = (argv) ->                            #<unsupported> nested and kv cannnot happen
  root = {uniformer:{}}                         #our root object, containing uniformer data and processed
  processed = {}                                #the result
  booleanKey = false                            #used to mark bool keys
  processedPtr = processedPtr                   #this is where we actually write values into
  for arg in argv                               #iterate
    if (key = isKey(arg)) != false              #key
      if (nest = isNested(key,true)) != false   #nest, return {key:'',nest:{}} and fill lowest with true
        if processed[nest.key]?                 # if the nest is already a key, merge wit it, overriding
          processed[nest.key] = extend true,processed[nest.key],nest.nest
        else
          processed[nest.key] = nest.nested     # else set nest = nested
        processedPtr = processed[nest.key]
        booleanKey = true
      else if (kv = isKv(key)) != false         #kv, return {key:'',value:''}
        processed[kv.key] = typeChange kv.value #set the kv key to typeChange'd value
        processedPtr = processedPtr             #reset our ptr to the root, there is no more values for this
        booleanKey = false                      #reset this flag too, as we're not usin it
      else
        processed[key] = true                   #default 
        processedPtr = processed[key]           #set our next
        booleanKey = true
    else
      if not processedPtr?                      # if we don't have a pointer, put it in the _root of root
        if not isArray root.uniformer['_root']
          root.uniformer['_root'] = []
        root.uniformer['_root'].push typeChange arg
      else                                      # otherwise do the ptr change
        if booleanKey
          processedPtr = typeChange arg
          booleanKey = false
        else if not isArray processedPtr
          processedPtr = []
          processedPtr.push typeChange arg
        else
          processedPtr.push typeChange arg
  root['processed'] = processed    


defaults = {
  argv: process.argv
}
uniformer = (opts = null) ->
  opts = extend true,defaults,opts
  processed = extend true,{},procArgs opts.argv
  if processed["config"]? and not isSupported("config",opts.supported || null)
    opts.file = processed["config"]
    delete processed["config"]
  if opts.file?
    processed = extend true,procFile(__dirname+"/"+opts.file),processed #<unsupported> non __dirname opts.file
  return processed




module.exports = uniformer