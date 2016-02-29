'use strict';

module.exports = function(grunt) {

    // Project configuration.
    grunt.initConfig({    
        coffee: {
            compile: {
                files: {
                    'lib/uniformer-config.js': 'lib/uniformer-config.coffee'
                }
            },
            tests: {
                expand: true,
                flatten: true,
                cwd: 'tests/',
                src: ['*.coffee'],
                dest: 'tests/',
                ext: '.js'
            }
        },
        nodeunit: {
            files: ['tests/*_test.js'],
        },
        watch: {
            files: ['lib/*.coffee', 'tests/*.coffee'],
            tasks: ['coffee:compile', 'coffee:tests', 'nodeunit']
        }
    });

  // These plugins provide necessary tasks.
  grunt.loadNpmTasks('grunt-contrib-nodeunit');
  grunt.loadNpmTasks('grunt-contrib-watch');
  grunt.loadNpmTasks('grunt-contrib-coffee');

  // Default task.
  grunt.registerTask('default', ['coffee', 'nodeunit']);
  
  // Test task.
  grunt.registerTask('test', ['coffee', 'nodeunit']);

};