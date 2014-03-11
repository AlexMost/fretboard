{Guitar} = require 'fretboard'
{Dropdown} = require 'toolbox'
React = require 'react'
{div, button} = React.DOM
{SCALES} = require 'scales'
{NOTES} = require 'notes'

notesOptions = ([note, note] for note in NOTES)
scalesOptions = ([scale, scale] for scale of SCALES)

Note = "C"
Scale = "Major"

guitarInstance = Guitar {fretWidth: 40, fretHeight: 30}
React.renderComponent guitarInstance, document.getElementById "container"

handleChangeNote = ({value}) ->
    Note = value
    guitarInstance.pressNotes SCALES[Scale].get_notes Note

handleChangeScale = ({value}) ->
    Scale = value
    guitarInstance.pressNotes SCALES[Scale].get_notes Note

React.renderComponent(
    (div {},
        (Dropdown {data: {options: notesOptions}, onChange: handleChangeNote})
        (Dropdown {data: {options: scalesOptions}, onChange: handleChangeScale})
        (button {value: "play", onClick: guitarInstance.playScale}, "play")
    )
    document.getElementById "toolbar"
)

guitarInstance.pressNotes SCALES[Scale].get_notes Note