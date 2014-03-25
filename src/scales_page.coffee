{Guitar} = require 'fretboard'
{Dropdown} = require 'toolbox'
React = require 'react'
{div, button, span, h2, p} = React.DOM
{SCALES} = require 'scales'
{NOTES} = require 'notes'
{print_size} = require 'scales_page_utils'

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
                (h2 {}, "#{@state.Note} #{@state.Scale}")
                (p {}, print_size(SCALES[@state.Scale].size))
                (p {}, "#{SCALES[@state.Scale].get_notes(@state.Note).join ' '}"))
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