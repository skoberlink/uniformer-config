(function() {
  var uniformer;

  uniformer = require("../lib/uniformer-config");

  exports.basicTests = {
    setUp: function(done) {
      return done();
    },
    "library load test": function(test) {
      test.expect(1);
      test.doesNotThrow(require("../lib/uniformer-config"));
      return test.done();
    },
    "argv single/multi values test": function(test) {
      test.expect(2);
      test.deepEqual(uniformer({
        argv: ["-key", "value"]
      }), {
        key: "value"
      }, "check single value");
      test.deepEqual(uniformer({
        argv: ["-key", "value1", "value2"]
      }), {
        key: ["value1", "value2"]
      }, "check multi value");
      return test.done();
    },
    "argv key test": function(test) {
      var targv;
      targv = void 0;
      test.expect(6);
      targv = process.argv.concat(["-key", "val1", "val2", "val3"]);
      test.deepEqual(uniformer({
        argv: targv
      }), {
        key: ["val1", "val2", "val3"]
      }, "check -key");
      targv = process.argv.concat(["--key", "val1", "val2", "val3"]);
      test.deepEqual(uniformer({
        argv: targv
      }), {
        key: ["val1", "val2", "val3"]
      }, "check --key");
      targv = process.argv.concat(["-key", "val1", "val2", "val3", "-key2", "two1", "two2", "two3"]);
      test.deepEqual(uniformer({
        argv: targv
      }), {
        key: ["val1", "val2", "val3"],
        key2: ["two1", "two2", "two3"]
      }, "check multi -key");
      targv = process.argv.concat(["--key", "val1", "val2", "val3", "--key2", "two1", "two2", "two3"]);
      test.deepEqual(uniformer({
        argv: targv
      }), {
        key: ["val1", "val2", "val3"],
        key2: ["two1", "two2", "two3"]
      }, "check multi --key");
      targv = process.argv.concat(["--key", "val1", "val2", "val3", "-key2", "two1", "two2", "two3"]);
      test.deepEqual(uniformer({
        argv: targv
      }), {
        key: ["val1", "val2", "val3"],
        key2: ["two1", "two2", "two3"]
      }, "check mixed -(-)keys");
      targv = process.argv.concat(["-key", "val1", "val2", "val3", "--key2", "two1", "two2", "two3"]);
      test.deepEqual(uniformer({
        argv: targv
      }), {
        key: ["val1", "val2", "val3"],
        key2: ["two1", "two2", "two3"]
      }, "check mixed (-)-keys");
      return test.done();
    },
    "argv keyscope test": function(test) {
      var targv;
      targv = void 0;
      test.expect(3);
      targv = process.argv.concat(["-super.key", "val1", "val2", "val3"]);
      test.deepEqual(uniformer({
        argv: targv
      }), {
        "super": {
          key: ["val1", "val2", "val3"]
        }
      }, "check two level keys");
      targv = process.argv.concat(["-super.big.key", "val1", "val2", "val3"]);
      test.deepEqual(uniformer({
        argv: targv
      }), {
        "super": {
          big: {
            key: ["val1", "val2", "val3"]
          }
        }
      }, "check three level keys");
      targv = process.argv.concat(["-super.key", "val1", "val2", "val3", "--super.pie", "pie1", "pie2", "-cake", "yum", "i like"]);
      test.deepEqual(uniformer({
        argv: targv
      }), {
        cake: ["yum", "i like"],
        "super": {
          key: ["val1", "val2", "val3"],
          pie: ["pie1", "pie2"]
        }
      }, "varying levels");
      return test.done();
    },
    "json test": function(test) {
      test.expect(1);
      test.deepEqual(uniformer({
        file: "tests/test_config.json"
      }), {
        "super": {
          big: {
            tree: true,
            hill: false,
            cat: 12,
            turtle: "ahh"
          }
        }
      }, "simple json");
      return test.done();
    },
    "yaml test": function(test) {
      test.expect(1);
      test.deepEqual(uniformer({
        file: "tests/test_config.yaml"
      }), {
        "super": {
          big: {
            tree: true,
            hill: false,
            cat: 12,
            turtle: "ahh"
          }
        }
      }, "simple yaml");
      return test.done();
    },
    "json merge test": function(test) {
      test.expect(1);
      test.deepEqual(uniformer({
        file: "tests/test_config.json",
        argv: ["-super.man", "cool", "--super.big.tree", "false", "-super.big.hill", "true"]
      }), {
        "super": {
          man: "cool",
          big: {
            tree: false,
            hill: true,
            cat: 12,
            turtle: "ahh"
          }
        }
      }, "simple json merge");
      return test.done();
    },
    "yaml merge test": function(test) {
      test.expect(1);
      test.deepEqual(uniformer({
        file: "tests/test_config.yaml",
        argv: ["-super.man", "cool", "--super.big.tree", "false", "-super.big.hill", "true"]
      }), {
        "super": {
          man: "cool",
          big: {
            tree: false,
            hill: true,
            cat: 12,
            turtle: "ahh"
          }
        }
      }, "simple yaml merge");
      return test.done();
    },
    "config argument test": function(test) {
      test.expect(3);
      test.deepEqual(uniformer({
        argv: ["--config", "tests/test_config.yaml"]
      }), {
        "super": {
          big: {
            tree: true,
            hill: false,
            cat: 12,
            turtle: "ahh"
          }
        }
      }, "simple yaml via --config");
      test.deepEqual(uniformer({
        argv: ["-config", "tests/test_config.yaml"]
      }), {
        "super": {
          big: {
            tree: true,
            hill: false,
            cat: 12,
            turtle: "ahh"
          }
        }
      }, "simple yaml via -config");
      test.deepEqual(uniformer({
        argv: ["--config", "tests/test_config.yaml", "--extra", "big", "pie"]
      }), {
        "super": {
          big: {
            tree: true,
            hill: false,
            cat: 12,
            turtle: "ahh"
          }
        },
        extra: ["big", "pie"]
      }, "simple yaml via --config with extra mixin");
      return test.done();
    },
    "defaults test": function(test) {
      test.expect(1);
      test.deepEqual(uniformer({
        defaults: {
          given: true,
          override: false
        },
        argv: ["--override", "true", "--extra", "value"]
      }), {
        given: true,
        override: true,
        extra: "value"
      });
      return test.done();
    }
  };

}).call(this);
