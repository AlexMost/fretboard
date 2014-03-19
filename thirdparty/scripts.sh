#!/bin/sh

# inliner for converting wav files to mp3
for file in *.wav; do lame -b 192 -h "$file" "${file%.wav}.mp3"; done && mkdir mp3 && mv *.mp3 mp3 && mkdir wav && mv *.wav wav