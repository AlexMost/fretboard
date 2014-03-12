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
                mangle:
                    except: ["jQuery", "require"]
            build:
                files:
                    'public/app-min.js': ['public/app.js']


    grunt.loadNpmTasks "grunt-contrib-watch"
    grunt.loadNpmTasks "grunt-contrib-coffee"
    grunt.loadNpmTasks "grunt-contrib-uglify"
    grunt.loadNpmTasks "grunt-stitch"

    grunt.registerTask "build", ["coffee:src", "stitch"]