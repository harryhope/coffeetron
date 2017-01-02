electron = require('electron-connect').server.create()

module.exports = (grunt) ->

  # Files to monitor.
  styleFiles = [
    'src/**/*.sass'
  ]
  rendererScripts = [
    'src/**/*.coffee'
  ]
  mainProcessScripts = [
    'app.coffee'
  ]
  auxScripts = [
    'Gruntfile.coffee'
    'test/**/*.coffee'
  ]
  allScripts = rendererScripts
    .concat mainProcessScripts
    .concat auxScripts

  # Grunt Config
  grunt.initConfig
    watch:
      options:
        nospawn: true
      mainProcess:
        files: mainProcessScripts
        tasks: ['coffeelint', 'restart-electron']
      rendererProcess:
        files: mainProcessScripts.concat('index.html')
        tasks: ['compile-render', 'reload-electron']
      auxScripts:
        files: auxScripts
        tasks: ['coffeelint']
      styles:
        files: styleFiles
        tasks: ['sass', 'reload-electron']

    mochaTest:
      all:
        options:
          reporter: 'spec'
          require: 'coffee-script/register'
        src: ['test/**/*.coffee']

    sass:
      options:
        sourceMap: true
        style: 'compressed'
      dist:
        files:
          './build/style.css': './src/styles/main.sass'

    coffeelint:
      all: allScripts
      options:
        arrow_spacing: {level: 'error'}
        ensure_comprehensions: {level: 'error'}
        no_unnecessary_double_quotes: {level: 'error'}
        no_trailing_whitespace: {level: 'error'}
        no_empty_param_list: {level: 'error'}
        spacing_after_comma: {level: 'error'}
        no_stand_alone_at: {level: 'error'}
        space_operators: {level: 'error'}
        indentation:
          value: 2
          level: 'error'
        cyclomatic_complexity:
          value: 8
          level: 'error'
        max_line_length:
          value: 120
          level: 'error'
          limitComments: yes

    webpack:
      main:
        cache: true
        entry: [
          './src/scripts/main.coffee'
        ]
        devtool: 'source-map'
        output:
          path: './build/'
          filename: 'main.js'
        resolve:
          extensions: ['', '.jsx', '.cjsx', '.coffee', '.js']
          modulesDirectories: ['public', 'node_modules']
        module:
          loaders: [
            {test: /\.jsx$/, loader: 'jsx-loader?insertPragma=React.DOM'}
            {test: /\.cjsx$/, loaders: ['coffee', 'cjsx']}
            {test: /\.coffee$/, loader: 'coffee'}
          ]

  # Npm Tasks
  grunt.loadNpmTasks 'grunt-webpack'
  grunt.loadNpmTasks 'grunt-contrib-watch'
  grunt.loadNpmTasks 'grunt-coffeelint-cjsx'
  grunt.loadNpmTasks 'grunt-mocha-test'
  grunt.loadNpmTasks 'grunt-sass'

  # Combo Tasks
  grunt.registerTask('compile-render', ['coffeelint', 'webpack'])
  grunt.registerTask('test', ['coffeelint', 'mochaTest'])

  # Tasks
  grunt.registerTask 'dev', (env) ->
    electron.start()
    grunt.task.run 'watch'

  grunt.registerTask 'restart-electron', ->
    electron.restart()

  grunt.registerTask 'reload-electron', ->
    electron.reload()
