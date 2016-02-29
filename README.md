uniformer-config
=======

Forked from [uniformer](https://github.com/b3ngr33ni3r/uniformer) at v0.0.5

[![Dependency Status](https://david-dm.org/skoberlink/uniformer-config.svg)](https://david-dm.org/skoberlink/uniformer-config)

[![Build Status](https://travis-ci.org/skoberlink/uniformer-config.svg?branch=master)](https://travis-ci.org/skoberlink/uniformer-config)

returns a key-value object from combined config file/argv values.

## Changelog
v0.0.5
+ Fixed bug with number parsing where you'd get a Number object, instead of a number literal.

v0.0.3

+ Added support for a passed object `defaults` that is overriden by both file and argv sources
+ fixed `file` and `config` path matching, to work cross platform abs/rel using [path-resolver](https://github.com/bengreenier/path-resolver)

v0.0.2

+ Added support for `--config` and `-config`.
+ This overrides the passed `file` parameter
+ If users are told to use `--config path/to/config.ext` you can pass no arguments

v0.0.1

+ Basic functionality
+ merge argv and config values
+ quick and easy

## How?

Just `npm install uniformer` and then call `require('uniformer')(opts);`

check out the examples below.



## options

__uniformer takes an options object__.  
  
```
{
  file:'path/to/config.(json|yaml)'
}
```
for instance:
```
{
  file:'config.json'
}
```
if you don't specify a file option, uniformer pulls its data from `process.argv`. If you specify both,
the config file values will be overriden by `process.argv` values.


## examples

it's super easy to use...__without config__:

```
var uniformer = require('uniformer');
var normalizedOptionsObject = uniformer();
```
will return `{machines:['server01','server02','localhost']}` when your application is called like this:
```
$ node application.js --machines server01 server02 localhost
```
or
```
$ node application.js -machines server01 server02 localhost
```    
  
  
or __with config__:
  
```
var uniformer = require('uniformer');
var normalizedOptionsObject = uniformer({file:'config.json'}); //this could be a json OR yaml file
//you call also just leave file: out (ie just call uniformer()), and if the user wants to use a config file they can specify --config path/to/file.ext
```
with a config.json that looks like:
```
{
  "machines":['server01','server02','localhost']
}
```
will return `{machines:['server01','server02','localhost']}` when your application is called like this:
```
$ node application.js
```
or will return `{machines:['server01','server02','localhost'],deploy:true}` when called like:
```
$ node application.js --deploy true
```    

  

you can [peruse the tests](https://github.com/b3ngr33ni3r/uniformer/blob/master/tests) to learn a bit more.


## More stuff?

You can read the [issues](https://github.com/b3ngr33ni3r/uniformer/issues) to see what I want [todo](https://github.com/b3ngr33ni3r/uniformer/issues?labels=todo).  
  
the [license](https://github.com/b3ngr33ni3r/uniformer/blob/master/LICENSE) is MIT.
