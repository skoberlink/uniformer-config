uniformer = require '../lib/uniformer'

exports.basicTests = {
  setUp: (done) ->
    done()
  'library load test': (test) ->
    test.expect 1

    # test loading the lib with require
    test.doesNotThrow require('../lib/uniformer')
    test.done()

  'argv single/multi values test': (test) ->
    test.expect 2

    # test one value vs multi value
    test.deepEqual uniformer({argv:['-key','value']}),{key:'value'},"check single value"
    test.deepEqual uniformer({argv:['-key','value1','value2']}),{key:['value1','value2']},"check multi value"
    test.done()

  'argv key test': (test) ->
    test.expect 6

    # test one level argv keys in the form of -(-)key value1 value2 ...
    targv = process.argv.concat ['-key','val1','val2','val3']
    test.deepEqual uniformer({argv:targv}),{key:['val1','val2','val3']},"check -key"
    targv = process.argv.concat ['--key','val1','val2','val3']
    test.deepEqual uniformer({argv:targv}),{key:['val1','val2','val3']},"check --key"
    targv = process.argv.concat ['-key','val1','val2','val3','-key2','two1','two2','two3']
    test.deepEqual uniformer({argv:targv}),{key:['val1','val2','val3'],key2:['two1','two2','two3']},"check multi -key"
    targv = process.argv.concat ['--key','val1','val2','val3','--key2','two1','two2','two3']
    test.deepEqual uniformer({argv:targv}),{key:['val1','val2','val3'],key2:['two1','two2','two3']},"check multi --key"
    targv = process.argv.concat ['--key','val1','val2','val3','-key2','two1','two2','two3']
    test.deepEqual uniformer({argv:targv}),{key:['val1','val2','val3'],key2:['two1','two2','two3']},"check mixed -(-)keys"
    targv = process.argv.concat ['-key','val1','val2','val3','--key2','two1','two2','two3']
    test.deepEqual uniformer({argv:targv}),{key:['val1','val2','val3'],key2:['two1','two2','two3']},"check mixed (-)-keys"
    test.done()

  'argv keyscope test': (test) ->
    test.expect 3

    # test multi level keys
    targv = process.argv.concat ['-super.key','val1','val2','val3']
    test.deepEqual uniformer({argv:targv}),{super:{key:['val1','val2','val3']}},"check two level keys"
    targv = process.argv.concat ['-super.big.key','val1','val2','val3']
    test.deepEqual uniformer({argv:targv}),{super:{big:{key:['val1','val2','val3']}}},"check three level keys"
    targv = process.argv.concat ['-super.key','val1','val2','val3','--super.pie','pie1','pie2','-cake','yum','i like']
    test.deepEqual uniformer({argv:targv}),{cake:['yum','i like'],super:{key:['val1','val2','val3'],pie:['pie1','pie2']}},"varying levels"
    test.done()
  
  'json test': (test) ->
    test.expect 1
    test.deepEqual uniformer({file:'../tests/test_config.json'}),{super:{big:{tree:true,hill:false,cat:12,turtle:"ahh"}}},"simple json"
    test.done()

  'yaml test': (test) ->
    test.expect 1
    test.deepEqual uniformer({file:'../tests/test_config.yaml'}),{super:{big:{tree:true,hill:false,cat:12,turtle:"ahh"}}},"simple yaml"
    test.done()

  'json merge test': (test) ->
    test.expect 1
    test.deepEqual uniformer({file:'../tests/test_config.json',argv:['-super.man','cool','--super.big.tree','false','-super.big.hill','true']}),{super:{man:'cool',big:{tree:false,hill:true,cat:12,turtle:"ahh"}}},"simple json merge"
    test.done()

  'yaml merge test': (test) ->
    test.expect 1
    test.deepEqual uniformer({file:'../tests/test_config.yaml',argv:['-super.man','cool','--super.big.tree','false','-super.big.hill','true']}),{super:{man:'cool',big:{tree:false,hill:true,cat:12,turtle:"ahh"}}},"simple yaml merge"
    test.done()


}