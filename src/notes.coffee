NOTES = [C,    Cd,   D,   Dd,   E,   F,   Fd,   G,   Gd,   A,   Ad,   B] = \
        ["C", "C#", "D", "D#", "E", "F", "F#", "G", "G#", "A", "A#", "B"]


TUNINGS =
    "Standart":
        name: "Standart E"
        notes:  [E, B, G, D, A, E]
        offset: [0, 0, 0, 0, 0, 0]

    "DropD":
        name: "Droped D"
        notes:  [E, B, G, D, A,  D]
        offset: [0, 0, 0, 0, 0, -2]

    "1StepDown":
        name: "1 step down"
        notes:  [Dd, Ad, Fd, Cd, Gd, Dd]
        offset: [-1, -1, -1, -1, -1, -1]

    "DropC":
        name: "Droped C"
        notes:  [D, A, F, C, G, C]
        offset: [-2, -2, -2, -2, -2, -4]


get_note_index = (note) ->
    for n, i in NOTES
        return i if note is n


get_new_index = (old_idx) ->
    if old_idx is NOTES.length-1
        0
    else
        old_idx + 1


getNoteGenerator = (note) ->
    idx = get_note_index note
    () ->
        ret_idx = idx
        idx = get_new_index idx
        NOTES[ret_idx]


generateNotes = (sCount, fCount, tuning) ->
    # Concatting because of consistency with tabs format
    # to make 1st element of array to be the 1st string
    [[]].concat (for sNum in [0..sCount-1]
        noteGen = getNoteGenerator tuning[sNum]
        (noteGen() for i in [0..fCount]))


module.exports = {
    getNoteGenerator
    NOTES
    generateNotes
    get_note_index
    get_new_index
    TUNINGS
}