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
            imagesDir:'<%= dir.releaseDir %>/img'
      concat:
        dev:
          files:
            'cs/index.coffee':['cs/core/common.coffee','cs/pages/index.coffee']
      coffee:
        dev:
          expand:true
          cwd:'cs/'
          src:['*.coffee']
          dest:'js/'
          ext:'.js'
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
          compress:
            drop_console:true
          expand:true
          sourceMap:true
          sourceMapIncludeSources:true
          sourceMapIn:
            (e)->
              return e+'.map'
          sourceMapName:
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
          '**/*.php'
        ]
      copy:
        dist:
          files:[
            expand:true
            src:'img/**'
            dest:'<%= dir.releaseDir %>/'
          ,
            expand:true
            src:'sass/**'
            dest:'<%= dir.releaseDir %>/'
          ,
            expand:true
            flatten:true
            src:'cs/*'
            dest:'<%= dir.releaseDir %>/cs/'
            filter:'isFile'
          ]
      clean:
        dist:['<%= dir.releaseDir %>/sass/','<%= dir.releaseDir %>/cs/']
      esteWatch:
        options:
          dirs:['./','*/','!{node_modules,<%= dir.releaseDir %>}/','*/**/','!{node_modules,<%= dir.releaseDir %>}/**/']
          livereload:
            enabled: true
            extensions:['html', 'php', 'css', 'js', 'gif', 'jpg', 'png']
        scss:
          (filepath)->
            ['compassMultiple:dev','notify:sass']
        coffee:
          (filepath)->
            target = filepath.split('/').reverse()[0]
            for key of grunt.config(['concat','dev','files'])
              if key.indexOf(target) isnt -1 and key isnt filepath
                concat = {}
                concat[key] = grunt.config(['concat','dev','files'])[key]

                grunt.config(['notify','coffee','options','message'],'Change '+filepath)
                grunt.config(['coffee','dev','src'],[target])

                if Object.keys(concat).length isnt 0
                  grunt.config(['concat','now','files'],concat)

            if grunt.config(['concat','now','files'],concat) isnt undefined
              ['concat:now','coffee:dev','notify:coffee']
            else
              ['concat:dev','coffee:dev','notify:coffee']
        php:
          (filepath)->
            grunt.config(['notify','file','options','message'],'Change '+filepath)
            'notify:file'
        gif:
          (filepath)->
            grunt.config(['notify','img','options','message'],'Change '+filepath.split('/').reverse()[0])
            'notify:img'
        jpg:
          (filepath)->
            grunt.config(['notify','img','options','message'],'Change '+filepath.split('/').reverse()[0])
            'notify:img'
        png:
          (filepath)->
            grunt.config(['notify','img','options','message'],'Change '+filepath.split('/').reverse()[0])
            'notify:img'
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
  grunt.registerTask 'release',['copy','compassMultiple:dist','coffee:dist','uglify','clean','image']
