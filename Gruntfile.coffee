module.exports = (grunt) ->
    grunt.config.init
        coffee:
            src:
                expand: true
                cwd: "src/"
                src: ["**/*.coffee"]
                dest: "lib-js/"
                ext: ".js"

        watch:
            files: "src/*.coffee"
            tasks: ["build"]

        stitch:
            options:
                paths: ['lib-js/', 'lib/']
                dest: 'public/app.js'

        uglify:
            options:
                banner: '<%= grunt.template.today("yyyy-mm-dd") %> */'
                mangle:
                    except: ["jQuery", "require"]
            build:
                files:
                    'public/min/app.js': ['public/app.js']

        copy:
            js: {expand: true, cwd: 'public/min', src:'app.js', dest: 'dist/public'}
            main: {expand: true, src: 'index.html', dest: 'dist'}
            css: {expand: true, src: 'css/*', dest: 'dist'}
            resources: {expand: true, src: 'resources/**', dest: 'dist'}

        'gh-pages':
            options:
                base: 'dist'
            src: ['**']


    grunt.loadNpmTasks "grunt-contrib-watch"
    grunt.loadNpmTasks "grunt-contrib-coffee"
    grunt.loadNpmTasks "grunt-contrib-uglify"
    grunt.loadNpmTasks "grunt-contrib-copy"
    grunt.loadNpmTasks "grunt-gh-pages"
    grunt.loadNpmTasks "grunt-stitch"

    grunt.registerTask "build", ["coffee:src", "stitch"]
    grunt.registerTask "deploy", ["build", "uglify", "copy"]
    grunt.registerTask "deploy-gh", ["deploy", "gh-pages"]