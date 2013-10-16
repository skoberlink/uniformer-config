uniformer = require '../lib/uniformer'

exports.advanced = {
  setUp: (done) -> done()
  'full-config':(test) ->
    test.expect 1

    # call uniformer with an object w/ file property
    test.deepEqual uniformer({file:'full-config.json'}),{
      _uniformer: {
        _config: {
          supported: ['config'],
          debug: 'console'
        }
      },
      super: {
        parent: {
          key: 'value',
          arr: ['entry','entry','entry'],
          num: 1
        }
      }
    }
    test.done()

  'full-config str':(test) ->
    test.expect 1

    # all that changes here is the way we call uniformer
    test.deepEqual uniformer('full-config.json'),{
      _uniformer: {
        _config: {
          supported: ['config'],
          debug: 'console'
        }
      },
      super: {
        parent: {
          key: 'value',
          arr: ['entry','entry','entry'],
          num: 1
        }
      }
    }
    test.done()
}