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
            tasks: ["coffee"]

    grunt.loadNpmTasks "grunt-contrib-watch"
    grunt.loadNpmTasks "grunt-contrib-coffee"
    grunt.registerTask "build", ["coffee:src"]