module.exports = (grunt) ->
  #load package.json
  pkg = grunt.file.readJSON 'package.json'

  grunt.fileexpandMapping

  grunt.initConfig
      dir:
        releaseDir:'release'
      compassMultiple:
        options:
          sassDir:'sass'
        dev:
          options:
            config:'config.rb'
        dist:
          options:
            environment:'production'
            sassDir:'<%= dir.releaseDir %>/sass'
            cssDir:'<%= dir.releaseDir %>/css'
      concat:
        dist:
          files:
            '<%= dir.releaseDir %>/cs/index.coffee':['cs/base.coffee','cs/index.coffee']
      coffee:
        dev:
          #expand:true
          #cwd:'cs/'
          #src:['**/*.coffee']
          #dest:'js/'
          #ext:'.js'
          files:
            'js/index.js':['cs/base.coffee','cs/index.coffee']
          options:
            bare:true
            sourceMap:true
        dist:
          expand:true
          cwd:'<%= dir.releaseDir %>/cs/'
          src:['**/*.coffee']
          dest:'<%= dir.releaseDir %>/js/'
          ext:'.js'
          options:
            bare:true
            sourceMap:true
      uglify:
        options:
          expand:true
          sourceMap:true
          sourceMapIncludeSources:true
          sourceMapIn:
            (e)->
              return e+'.map'
        files:
          expand:true
          cwd:'<%= dir.releaseDir %>/js'
          src:['*.js','!{exchecker-ja,exvalidation,holder,html5shiv,jquery-1.9.1.min,jquery.ah-placeholder,jquery.cookie,jquery.pseudo,jquery.ui.datepicker-ja,PIE_IE9,PIE_IE678,selectivizr}.js']

          dest:'<%= dir.releaseDir %>/js'
      image:
        dist:
          options:
            optimizationLevel:3
          files:[
            expand:true
            src:'img/**/*.{png,gif,jpg,jpeg}'
            dest:'<%= dir.releaseDir %>/'
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
      validation:
        options:
          relaxerror:
            "Saw <?. Probable cause: Attempt to use an XML processing instruction in HTML. (XML processing instructions are not supported in HTML.)"
        target:[
          '*.php'
        ]
      copy:
        dist:
          files:[
            expand:true
            src:'sass/**'
            dest:'<%= dir.releaseDir %>/'
          #,
          #  expand:true
          #  flatten:true
          #  src:'cs/*'
          #  dest:'release/cs/'
          #  filter:'isFile'
          ]
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
  grunt.registerTask 'default',['esteWatch']
  grunt.registerTask 'release',['compassMultiple:dist','uglify','image']
