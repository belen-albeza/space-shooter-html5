module.exports = (grunt) ->
  grunt.loadNpmTasks task for task in [
    'grunt-coffeelint',
    'grunt-contrib-clean',
    'grunt-contrib-coffee',
    'grunt-contrib-connect',
    'grunt-contrib-copy',
    'grunt-sed',
    'grunt-contrib-watch'
  ]

  grunt.initConfig
    clean:
      app: ['build', 'app/js']

    coffee:
      app:
        files:
          'app/js/game.js' : [
            'app/coffee/main.coffee'
          ]

    coffeelint:
      all: ['Gruntfile.coffee', 'app/coffee/**/*.coffee']
      options:
        no_throwing_strings:
          level: 'ignore'
        indentation:
          level: 'ignore'

    connect:
      server:
        options:
          port: 9000
          middleware: (connect) ->
            path = require 'path'
            [connect.static path.resolve 'app']

    copy:
      app:
        files: [{
          expand: true
          cwd: 'app'
          src: ['js/**/*.js', '!js/vendor/**/*.js', '**/*.html', 'images/*',
            'sounds/*']
          dest: 'build'
        }, {
          expand: true
          cwd: 'app'
          src: ['js/vendor/phaser.min.js']
          dest: 'build'
        }]
      bower:
        files: [
          {'app/js/vendor/phaser.js': 'bower_components/phaser/phaser.js'},
          {'app/js/vendor/phaser.min.js':
            'bower_components/phaser/phaser.min.js'}
        ]

    sed:
      minjs:
        path: 'build/index.html'
        pattern: /vendor\/(phaser)\.js/g
        replacement: 'vendor/$1.min.js'

    watch:
      coffeeApp:
        files: ['app/coffee/**/*.coffee']
        tasks: ['coffee:app']

    grunt.registerTask 'build', ['clean', 'coffeelint', 'coffee', 'copy:bower']
    grunt.registerTask 'release', ['build', 'copy:app', 'sed:minjs']
    grunt.registerTask 'server', ['build', 'connect:server', 'watch']
