{Howl} = require 'howler'

sound = new Howl
    urls: ['./resources/output.mp3']
    sprite:
        E: [0, 1000]
        F: [4000, 4000]

module.exports = sound