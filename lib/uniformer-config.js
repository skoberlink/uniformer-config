(function() {
  var _chunkProc, _proc, _typeProc, argumentIdentifiers, extend, fs, pathResolver, typeIsArray, uniformerConfig;

  require('js-yaml');

  fs = require('fs');

  extend = require('extend');

  pathResolver = require('path-resolver');

  argumentIdentifiers = ["--", "-"];

  typeIsArray = Array.isArray || function(value) {
    return {}.toString.call(value) === '[object Array]';
  };

  _typeProc = function(val) {
    if (typeof val === 'number' || !isNaN(val)) {
      return new Number(val).valueOf();
    } else if (val.toLowerCase() === 'false') {
      return false;
    } else if (val.toLowerCase() === 'true') {
      return true;
    } else {
      return val;
    }
  };

  _chunkProc = function(resultant, cI, arg) {
    var chunk, chunks, i, j, key, len, oldArg, parent;
    parent = resultant;
    chunks = cI.split('.');
    for (i = j = 0, len = chunks.length; j < len; i = ++j) {
      chunk = chunks[i];
      if (i < chunks.length - 1) {
        if (parent[chunk] == null) {
          parent[chunk] = {};
        }
        parent = parent[chunk];
      }
    }
    key = chunks[chunks.length - 1];
    if (parent[key] == null) {
      parent[key] = _typeProc(arg);
    } else {
      if (typeIsArray(parent[key])) {
        parent[key].push(_typeProc(arg));
      } else {
        oldArg = parent[key];
        parent[key] = new Array();
        parent[key].push(oldArg, _typeProc(arg));
      }
    }
    return resultant;
  };

  _proc = function(argv) {
    var arg, cI, identifier, isKey, j, k, len, len1, resultant;
    cI = null;
    resultant = {};
    for (j = 0, len = argv.length; j < len; j++) {
      arg = argv[j];
      isKey = false;
      for (k = 0, len1 = argumentIdentifiers.length; k < len1; k++) {
        identifier = argumentIdentifiers[k];
        isKey = arg.substr(0, identifier.length) === identifier;
        if (isKey) {
          cI = arg.substr(identifier.length, arg.length);
          break;
        }
      }
      if (!isKey && cI) {
        resultant = _chunkProc(resultant, cI, arg);
      }
    }
    return resultant;
  };

  uniformerConfig = function(spec) {
    var argv, argvProc, file, resultant;
    if (spec == null) {
      spec = null;
    }
    argv = (spec != null ? spec.argv : void 0) || process.argv;
    resultant = {};
    argvProc = _proc(argv);
    if (argvProc["config"] != null) {
      if (spec == null) {
        spec = {};
      }
      spec.file = argvProc["config"];
      delete argvProc["config"];
    }
    if ((spec != null ? spec.defaults : void 0) != null) {
      resultant = extend(true, resultant, spec.defaults);
    }
    if ((spec != null ? spec.file : void 0) != null) {
      if ((file = pathResolver.sync(spec.file)) !== false) {
        resultant = extend(true, resultant, require(file));
      }
    }
    return resultant = extend(true, resultant, argvProc);
  };

  module.exports = uniformerConfig;

}).call(this);
