{Guitar} = require 'fretboard'
{Dropdown, Thumbler} = require 'toolbox'
React = require 'react'
{div, button} = React.DOM
{SCALES} = require 'scales'
{NOTES} = require 'notes'

notesOptions = ([note, note] for note in NOTES)
scalesOptions = ([scale, scale] for scale of SCALES)

Note = "C"
Scale = "Minor"

guitarInstance = Guitar {
    fretWidth: 50,
    fretHeight: 30,
    selectorFretsCount: 4}

React.renderComponent guitarInstance, document.getElementById "container"

handleChangeNote = ({value}) ->
    Note = value
    guitarInstance.pressNotes SCALES[Scale].get_notes Note

handleChangeScale = ({value}) ->
    Scale = value
    guitarInstance.pressNotes SCALES[Scale].get_notes Note

onDirectionChange = (direction) ->
    guitarInstance.setState {play_reverse: direction is "asc"}


React.renderComponent(
    (div {},
        (Dropdown {
            data: {options: notesOptions},
            onChange: handleChangeNote,
            selected: Note
        })
        (Dropdown {
            data: {options: scalesOptions},
            onChange: handleChangeScale,
            selected: Scale
        })
        (Thumbler {
            state1: "asc",
            state2: "desc",
            onChange: onDirectionChange
        })
    )
    document.getElementById "toolbar"
)

guitarInstance.pressNotes SCALES[Scale].get_notes Note