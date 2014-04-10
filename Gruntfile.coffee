react_render_task = require './tasks/react_render'

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
            src:
                options:
                    atBegin: true
                files: "src/**/*.coffee"
                tasks: ["build:src"]

        browserify:
            scales_page:
                src: ['lib-js/pages/scales_page.js']
                dest: 'public/app.js'
            options:
                browserifyOptions:
                    noParse: [
                        'lib/ev_channel.js'
                        'lib/jquery.js'
                        'lib/howler.js'
                        'lib/async.js'
                    ]

        uglify:
            options:
                banner: '/* <%= grunt.template.today("yyyy-mm-dd h:MM:ss") %> */'
                mangle:
                    except: ["jQuery", "require"]
            build:
                files:
                    'public/min/app.js': ['public/app.js']

        copy:
            js: {expand: true, cwd: 'public/min', src:'app.js', dest: 'dist/public'}
            css: {expand: true, cwd: 'public/min', src:'fretsmap.css', dest: 'dist/public'}
            main: {expand: true, src: 'index.html', dest: 'dist'}
            about: {expand: true, src: 'about.html', dest: 'dist'}
            feedback: {expand: true, src: 'feedback.html', dest: 'dist'}
            resources: {expand: true, src: 'resources/**', dest: 'dist'}
            fonts: {expand: true, src: 'fonts/*', dest: 'dist'}

        'gh-pages':
            options:
                base: 'dist'
            src: ['**']

        notify:
            build:
                options:
                    title: 'Build'
                    message: 'Build is done'
            deploy:
                options:
                    title: 'Deploy'
                    message: 'Deployed to gh pages'

        react_render:
            options:
                basedir: __dirname
            index:
                options:
                    src: "./dist/index.html"

        cssmin:
            combine:
                files:
                    'public/min/fretsmap.css': ['public/fretsmap.css']

        concat:
            css:
                src: ['css/bootstrap.css', 'css/style.css']
                dest: 'public/fretsmap.css'


    grunt.loadNpmTasks "grunt-contrib-watch"
    grunt.loadNpmTasks "grunt-contrib-coffee"
    grunt.loadNpmTasks "grunt-contrib-uglify"
    grunt.loadNpmTasks "grunt-contrib-copy"
    grunt.loadNpmTasks "grunt-contrib-cssmin"
    grunt.loadNpmTasks "grunt-contrib-concat"
    grunt.loadNpmTasks "grunt-gh-pages"
    grunt.loadNpmTasks "grunt-browserify"
    grunt.loadNpmTasks "grunt-notify"
    react_render_task(grunt)

    grunt.registerTask "build", ["coffee", "browserify", "notify:build", "concat"]
    grunt.registerTask "deploy", ["build", "uglify", "cssmin", "copy", "react_render"]
    grunt.registerTask "deploy-gh", ["deploy", "gh-pages", "notify:deploy"]