{Guitar} = require 'fretboard'
{Dropdown} = require 'toolbox'
React = require 'react'
{div, button, span, h2, p, strong} = React.DOM
{SCALES} = require 'scales'
{print_size} = require 'scales_page_utils'

ScalesPage = React.createClass
    displayName: "ScalesPage"

    getInitialState: ->
        Note: "C"
        Scale: "Minor"

    render: ->

        (div {},
            (div {},
                (h2 {className: "text-center"}, "#{@state.Note} #{@state.Scale}")
                (p
                    className: "text-center text-muted text-bold"
                    "(#{print_size(SCALES[@state.Scale].size)})")
                (p
                    className: "text-center text-bold"
                    "#{SCALES[@state.Scale].get_notes(@state.Note).join ' '}"))
            (Guitar
                fretWidth: 50
                fretHeight: 30
                selectorFretsCount: 4
                Note: @state.Note
                Scale: @state.Scale,
                onNoteChange: (Note) => @setState {Note}
                onScaleChange: (Scale) => @setState {Scale}))

React.renderComponent(
    ScalesPage()
    document.getElementById "toolbar"
)