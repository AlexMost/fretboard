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
            options:
                atBegin: true
            files: "src/*.coffee"
            tasks: ["build"]

        browserify:
            scales_page:
                src: ['lib-js/scales_page.js']
                dest: 'public/app.js'
            options:
                browserifyOptions:
                    noParse: [
                        'lib/ev_channel.js'
                        'lib/jquery.js'
                        'lib/howler.js'
                        'lib/react.js'
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
            main: {expand: true, src: 'index.html', dest: 'dist'}
            css: {expand: true, src: 'css/*', dest: 'dist'}
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

    grunt.loadNpmTasks "grunt-contrib-watch"
    grunt.loadNpmTasks "grunt-contrib-coffee"
    grunt.loadNpmTasks "grunt-contrib-uglify"
    grunt.loadNpmTasks "grunt-contrib-copy"
    grunt.loadNpmTasks "grunt-gh-pages"
    grunt.loadNpmTasks "grunt-browserify"
    grunt.loadNpmTasks "grunt-notify"

    grunt.registerTask "build", ["coffee:src", "browserify", "notify:build"]
    grunt.registerTask "deploy", ["build", "uglify", "copy"]
    grunt.registerTask "deploy-gh", ["deploy", "gh-pages", "notify:deploy"]