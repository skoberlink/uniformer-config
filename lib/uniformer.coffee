
require 'js-yaml'
fs = require 'fs'
extend = require 'extend'
pr = require 'path-resolver'

# the defaults that opts
# extends when you call
# uniformer
defaults = {
  argv: process.argv,
  debug: false,
  identifiers: ['--','-'],
  seperators: [' ',','],
  allowEscaped: true,
  defaults:{}
}

# type checking 'shortcuts'
isArr = Array.isArray || ( value ) -> return {}.toString.call( value ) is '[object Array]'
isBool = (value)->return typeof value == 'boolean'
isNum = (value)->return typeof value == 'number'
isStr = (value)->return typeof value == 'string'

# casts values to their appropriate javascript type
cast = (value) ->
  if typeof value == 'number' || not isNaN(value)
    return new Number(value);
  else if value.toLowerCase() == 'false'
    return false;
  else if value.toLowerCase() == 'true'
    return true;
  else
    return value;

#TODO write this
# escapes as per https://github.com/b3ngr33ni3r/uniformer/issues/10
escapedReplace = (haystack,needle,replace)->


module.exports = (opts = null) ->
  opts = extend true,defaults,opts
  res = {}
  # if defaults, load it into our res
  if opts.defaults?
    res = extend true,res,opts.defaults
  # require file if opts.config
  if opts.config? and (path = pr.sync(opts.config)) != false
    res = extend true,res,require path
  # process argv entries
  res = extend true,res,((lopts)->
    #localize the argv,res for ease
    largv = lopts.argv
    lres = {}
    #sort the seperators and identifiers such that longer elems are first
    seps = lopts.seperators.sort (a,b)->
      return b.length - a.length;
    ids = lopts.identifiers.sort (a,b)->
      return b.length - a.length;
    # ptr to lres entry we're currently filling
    ptr = null
    #iterate the args
    for arg,i in largv
      #if the arg is a key, it will begin with an ids entry
      key = null
      for id in ids
        if arg.substr(0,id.length) == id
          key = arg.substr(id.length,arg.length)
          break
      if key?
        #make the boolean entry, and set the ptr
        lres[key] = true
        ptr = key #TODO this doesn't allow nesting. AWFUL
      else
        # if we get a val, and ptr isn't set, set it to _root
        if not ptr?
          lres["_root"] = []
          ptr = "_root"
        #if it's not a key, it must be a value
        #however, values need to be broken by seps as well
        #so, arg could technically be multiple values atm
        values = arg
        #split arg into values by seps
        for sep,j in seps
          if j+1<seps.length
            values = if lopts.allowEscaped then escapedReplace(values,sep,seps[seps.length-1]) else values.replace(sep,seps[seps.length-1])
          else
            values = values.split sep
        if not isArr values
          values = [values]
        #iterate values and cast and store them to ptr
        for val,j in values
          tmp = lres[ptr]
          if isObj lres[ptr]
            #if _root is defined as an object
            #override it with the new val
            if not lres[ptr]["_root"]?
              lres[ptr]["_root"] = true
            tmp = lres[ptr]["_root"]
          # process off tmp if we're not an object,
          # or if we're a root of an object (above) 
          if isArr tmp
            tmp.push val
          else if isBool tmp
            # if it's a bool, we need to check
            # if it's cause we just made the key
            # entry, or if it's cause we actually
            # got a true as a value
            # if we got it as a val, we array
            # if not, we override
            # TODO this ^^ logic
          else 
            # just a value, that we array-ify
            # and then push to
            tmp = [tmp]
            tmp.push val


          


  )(opts)
  # and we're good, return the populated object 'res'
  return res


