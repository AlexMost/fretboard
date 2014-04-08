React = require 'react'
{Guitar} = require './../fretboard'
{SimpleDropdown} = require './../toolbox'
{div, button, span, h2, p, strong} = React.DOM
{SCALES} = require './../scales'
{generateNotes, NOTES, TUNINGS} = require './../notes'
{print_size} = require './scales_page_utils'


notesOptions = ([note, note] for note in NOTES)
scalesOptions = ([scale, scale] for scale of SCALES)
tuningOptions = ([tuning, value.name] for tuning, value of TUNINGS)

ScalesPage = React.createClass
    displayName: "ScalesPage"

    getInitialState: ->
        Note: "C"
        Scale: "Minor"
        tuning: "Standart"

    render: ->
        tuningName = TUNINGS[@state.tuning].name
        (div {},
            (div {},
                (h2 {className: "text-center"}, "#{@state.Note} #{@state.Scale} (#{tuningName} tuning)")
                (p
                    className: "text-center text-muted text-bold"
                    "(#{print_size(SCALES[@state.Scale].size)})")
                (p
                    className: "text-center text-bold"
                    "#{SCALES[@state.Scale].get_notes(@state.Note).join ' '}"))
            (div
                style: {width: "850px", margin: "auto"}
                (div
                    className: "btn-group top-toolbar panel panel-default"
                    (SimpleDropdown {
                        options: notesOptions
                        onChange: (Note) => @setState {Note}
                        value: @state.Note
                    })

                    (SimpleDropdown {
                        options: scalesOptions
                        onChange: (Scale) => @setState {Scale}
                        value: @state.Scale
                    })

                    (SimpleDropdown {
                        options: tuningOptions
                        onChange: (tuning) => @setState {tuning}
                        value: @state.tuning
                    }))
            )
            (Guitar
                fretWidth: 50
                fretHeight: 30
                selectorFretsCount: 4
                Note: @state.Note
                Scale: @state.Scale,
                tuning: TUNINGS[@state.tuning].notes)
        )

module.exports = ScalesPage
