module.exports = (grunt) ->
  #load package.json
  pkg = grunt.file.readJSON 'package.json'

  grunt.fileexpandMapping

  grunt.initConfig
      compassMultiple:
        options:
          sassDir:'sass'
        dev:
          options:
            config:'config.rb'
        dist:
          options:
            environment:'production'
            cssDir:'release/css'
      coffee:
        compile:
          expand:true
          cwd:'cs/'
          src:['**/*.coffee']
          dest:'js/'
          ext:'.js'
        options:
          bare:true
      uglify:
        options:
          sourceMap:true
        dist:
          expand:true
          cwd:'js/'
          src:'*.js'
          dest:'release/js/'
      imagemin:
        dist:
          options:
            optimizationLevel:3
          files:[
            expand:true
            src:'img/**/*.{png,jpg,jpeg}'
            dest:'release/'
          ]
      styleguide:
        styledocco:
          options:
            framework:
              name:'styledocco'
            name:'Style Guide'
          files:
            'docs':'docs/css/style.css'
      htmllint:
        all:[
          '**/*.html'
          '**/*.php'
        ]
      watch:
        sass:
          files:'sass/**/*.scss'
          tasks:['compassMultiple:dev','notify:sass']
        coffee:
          files:'cs/**/*.coffee'
          tasks:['coffee','notify:coffee']
      esteWatch:
        options:
          dirs:['*/','!node_modules/','*/**/','!node_modules/**/']
        'scss':
          (filepath)->
            console.log(filepath)
            grunt.config(['compassMultiple','dev','options','sassFiles'],filepath.split('/')[1])
            'compassMultiple:dev'
        'coffee':
          (filepath)->
            grunt.config(['coffee','compile','src'],[filepath])
            'coffee'
      notify:
        file:
          options:
            title:'Grunt Notify'
            message:'Change file'
        img:
          options:
            title:'Grunt Notify'
            message:'Change img'
        sass:
          options:
            title:'Grunt Notify'
            message:'Change Sass'
        coffee:
          options:
            title:'Grunt Notify'
            message:'Change Coffee Script'

  #load plugins
  for taskName of pkg.devDependencies when taskName.substring(0, 6) is 'grunt-'
    grunt.loadNpmTasks taskName

  #define 'default' task
  #grunt.registerTask 'default',['esteWatch']
  grunt.registerTask 'default',['watch']
  grunt.registerTask 'release',['compassMultiple:dist','uglify','imagemin']
