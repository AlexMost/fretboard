notes = [C,    Cd,   D,   Dd,   E,   F,   Fd,   G,   Gd,   A,   Ad,   B] = \
        ["C", "C#", "D", "D#", "E", "F", "F#", "G", "G#", "A", "A#", "B"]


STANDART_TUNING = [E, B, G, D, A, E]


get_note_index = (note) ->
    for n, i in notes
        return i if note is n


get_new_index = (old_idx) ->
    if old_idx is notes.length-1
        0
    else
        old_idx + 1


getNoteGenerator = (note) ->
    idx = get_note_index note
    () ->
        ret_idx = idx
        idx = get_new_index idx
        notes[ret_idx]


generateNotes = (sCount, fCount, tuning) ->
    [[]].concat (for sNum in [0..sCount-1]
        noteGen = getNoteGenerator tuning[sNum]
        (noteGen() for i in [1..fCount]))


module.exports = {
    getNoteGenerator
    STANDART_TUNING
    generateNotes
}