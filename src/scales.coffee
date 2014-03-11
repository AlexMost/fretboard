{get_note_index, get_new_index, NOTES} = require 'notes'

STEP = 2
hSTEP = 1

generate_scale = (Note, scale) ->
    scale_notes = [Note]
    idx = get_note_index Note
    scale_notes.concat(for s in scale.size
        if s is STEP
            idx = get_new_index idx
            idx = get_new_index idx
        else
            idx = get_new_index idx
        NOTES[idx])


SCALES =
    Minor:
        desc: "Minor scale"
        size: [STEP, hSTEP, STEP, STEP, hSTEP, STEP, STEP]
        get_notes: (Tonica) -> generate_scale Tonica, SCALES.Minor

    Major:
        desc: "Major scale"
        size: [STEP, STEP, hSTEP, STEP, STEP, STEP, hSTEP]
        get_notes: (Tonica) -> generate_scale Tonica, SCALES.Major


module.exports = {SCALES, generate_scale}
