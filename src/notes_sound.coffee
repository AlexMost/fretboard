{Howl} = require 'howler'

sounds_cache = {1:{}, 2:{}, 3:{}, 4:{}, 5:{}, 6:{}}


play_fret = (sNum, fNum, cb) ->
    cacheSound = sounds_cache[sNum][fNum]
    if cacheSound
        cacheSound.play cb
    else
        sound = get_sound sNum, fNum, -> sound.play cb
        sounds_cache[sNum][fNum] = sound


get_sound = (sNum, fNum, onload) ->
    audio_file = "./resources/#{sNum}string/#{fNum}.wav"
    new Howl {urls: [audio_file], onload}


module.exports = {get_sound, play_fret}