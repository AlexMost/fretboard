#!/bin/sh

# inliner for converting wav files to mp3
function processMusic(){
    cd resources/$1string/wav

    for file in *.wav
        do lame -b 192 -h "./$file" "./${file%.wav}.mp3"
    done

    mkdir -p ../mp3 && mv ./*.mp3 ../mp3
}


processMusic $1

