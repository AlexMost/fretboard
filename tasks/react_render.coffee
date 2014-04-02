cheerio = require 'cheerio'
fs = require 'fs'
React = require 'react'
path = require 'path'

module.exports = (grunt) ->
    defaults = {}

    grunt.registerMultiTask(
        "react_render",
        "Prerenders react components on server side",
        ->
            options = @options defaults
            src = options.src
            basedir = options.basedir

            done = @async()
            fs.readFile src, (err, content) ->
                done(new Error err) if err
                $ = cheerio.load(content.toString())
                components = [$('*[data-rcomp]')]
                components.map (comp) ->
                    comp_path = path.resolve(basedir, comp.data().rcomp)
                    component = require comp_path
                    react_content_str = React.renderComponentToString component()
                    comp.html react_content_str
                fs.writeFile src, $.html(), ->
                    done()
    )