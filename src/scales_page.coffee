{Guitar} = require 'fretboard'
{SimpleDropdown} = require 'toolbox'
React = require 'react'
{div, button, span, h2, p, strong} = React.DOM
{SCALES} = require 'scales'
{STANDART_TUNING, DROP_D_TUNING, DROP_C_TUNING,
ONE_STEP_DOWN, generateNotes, NOTES} = require 'notes'
{print_size} = require 'scales_page_utils'


notesOptions = ([note, note] for note in NOTES)
scalesOptions = ([scale, scale] for scale of SCALES)

tuningMap =
    Standart: STANDART_TUNING
    DropD: DROP_D_TUNING
    OneStepDown: ONE_STEP_DOWN
    DropC: DROP_C_TUNING

tuningOptions = [
    ["Standart", "Standart"]
    ["DropD", "DropD"]
    ["DropC", "DropC"]
    ["OneStepDown", "OneStepDown"]
]

ScalesPage = React.createClass
    displayName: "ScalesPage"

    getInitialState: ->
        Note: "C"
        Scale: "Minor"
        tuning: "Standart"

    render: ->
        (div {},
            (div {},
                (h2 {className: "text-center"}, "#{@state.Note} #{@state.Scale} (#{@state.tuning} tuning)")
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
                tuning: tuningMap[@state.tuning])
        )


React.renderComponent(
    ScalesPage()
    document.getElementById "container"
)