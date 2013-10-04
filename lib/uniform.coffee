# uniform takes a spec object
#
# {
#   file:'path/to/config.(json|yaml)',
#   supported:['key1','key2','key3']
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
require 'js-yaml'
fs = require 'fs'

uniform = (spec = null) ->
  config
  if spec and spec.file and fs.existsSync(spec.file)
    config = require(spec.file)
  if config
    console.log "config found"



exports = uniform