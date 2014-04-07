#!/bin/sh

# inliner for converting wav files to mp3
for i in {1..6}
do
    cd resources/${i}string/wav

    for file in *.wav
    do
        lame -b 192 -h "$file" "${file%.wav}.mp3"
    done

    mkdir -p ../mp3 && mv *.mp3 ../mp3
done