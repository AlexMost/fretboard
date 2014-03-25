{Guitar} = require 'fretboard'
{Dropdown} = require 'toolbox'
React = require 'react'
{div, button, span, h2} = React.DOM
{SCALES} = require 'scales'
{NOTES} = require 'notes'

notesOptions = ([note, note] for note in NOTES)
scalesOptions = ([scale, scale] for scale of SCALES)

ScalesPage = React.createClass
    displayName: "ScalesPage"
    getInitialState: ->
        Note: "C"
        Scale: "Minor"

    render: ->
        (div {},
            (div {},
                (h2 {}, "#{@state.Note} #{@state.Scale}"))
            (Guitar
                fretWidth: 50
                fretHeight: 30
                selectorFretsCount: 4
                Note: @state.Note
                Scale: @state.Scale)
            (Dropdown {
                data: {options: notesOptions},
                onChange: ({value: Note}) => @setState {Note}
                selected: @state.Note
            })
            (Dropdown {
                data: {options: scalesOptions},
                onChange: ({value: Scale}) => @setState {Scale}
                selected: @state.Scale
            }))

React.renderComponent(
    ScalesPage()
    document.getElementById "toolbar"
)