
require 'js-yaml'
fs = require 'fs'
extend = require 'extend'

# change this for the pipeline
# this way it extendable if need be
# note the order is significant here...
# longer identifiers first
argumentIdentifiers = ["--","-"]


# add better array type checking
typeIsArray = Array.isArray || ( value ) -> return {}.toString.call( value ) is '[object Array]'

# convert strings to native js types
_typeProc = (val) ->
  if typeof val == 'number'
    return new Number(val);
  else if val.toLowerCase() == 'false'
    return false;
  else if val.toLowerCase() == 'true'
    return true;
  else
    return val;


#
# BEGIN REWRITE 
# 
#    BELOW
#




#define the defaults options
defaults = {
  pipeline: false, # if true, we use emitter pipeline processing.
  argv: process.argv # allows an alternative argv source 
}


class Uniformer extends EventEmitter
  # i always forget if i can use this in a "method"
  test = () ->
    console.log "hi"

  constructor: (@opts = {}) ->
    extend true,defaults,@opts
    if not @opts.pipeline
      return inlineProcessor()

  # executes a chain of processors (file,argument)
  inlineProcessor: () ->
    processed = {}
    if @opts.file?
      processed = fileProcessor()
    processed = extend true,processed,argumentProcessor()
    return processed
  
  # there's really nothing to file parsing (sure we'll do some error handling here later)
  fileProcessor: () ->
    return require @opts.file

  #parse @opts.argv , no validation/typechecking, i'm not your mother
  argumentProcessor: () ->
    processed = {}
    for arg in @opts.argv
      if isSupported arg
        if isKey arg
          processed[arg] = getValues arg,@opts.argv
        else if isSwitch arg
          processed[arg] = true
        else
          if @opts.pipeline
            @emit 'error',new Uniformer.InvalidArgument arg




module.exports = Uniformer