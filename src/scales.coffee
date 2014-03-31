{get_note_index, get_new_index, NOTES} = require 'notes'

BigSTEP = 3
STEP = 2
hSTEP = 1

generate_scale = (Note, scale) ->
    scale_notes = [Note]
    idx = get_note_index Note
    scale_notes.concat(for s in scale.size
        if s is BigSTEP
            idx = get_new_index idx
            idx = get_new_index idx
            idx = get_new_index idx
        else if  s is STEP  
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

    Arabic:
        desc: "Arabic scale"
        size: [hSTEP,BigSTEP,hSTEP,hSTEP,BigSTEP,hSTEP,STEP]
        get_notes: (Tonica) -> generate_scale Tonica, SCALES.Arabic

    Blues:
        desc: "Blues scale"
        size: [BigSTEP,STEP,hSTEP,hSTEP,BigSTEP,STEP]
        get_notes: (Tonica) -> generate_scale Tonica, SCALES.Blues


module.exports = {SCALES, generate_scale, STEP, hSTEP, BigSTEP}
