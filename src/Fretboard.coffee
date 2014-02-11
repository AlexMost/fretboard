React = require('react')
{div, li, ul} = React.DOM


Guitar = React.createClass
    displayName: "Guitar"
    pressStringFrets: (tabs) ->
        (@pressStringFret sNum, fNum) for [sNum, fNum] in tabs
    pressStringFret: (stringNum, fretNum) ->
        @state.data[stringNum-1].pressFret(fretNum)
    getInitialState: ->
        stringsNum = @props.data?.stringsNum or 6
        fretsNum = @props.data?.fretsNum or 16
        strings = [1..stringsNum].map (num) =>
            data = {num, fretsNum}
            GString {data}
        {data: strings}
    render: ->
        div {className: "guitar"}, @state.data


GString = React.createClass
    displayName: "GString"
    pressFret: (fretNum) ->
        @state.data[fretNum-1].press()
    getInitialState: ->
        frets = [1..@props.data.fretsNum].map (num) =>
            Fret {data: {checked: false, num, stringNum: @props.data.num}}
        {data: frets}
    render: ->
        ul {className: "string"}, @state.data


Fret = React.createClass
    displayName: "Fret"
    press: -> @setState {className: "on"}
    getInitialState: ->
        className = if @props.data.checked then "on" else "off"
        {className, fretNum: @props.data.num}
    render: ->
        li {className: "#{@state.className} fret", "data-fret-num": @state.fretNum}


guitar = Guitar()
React.renderComponent(
    guitar
    document.getElementById "container"
)

tabs = [
    [1, 2]
    [1, 4]
    [1, 6]
    [2, 3]
    [3, 4]
]

guitar.pressStringFrets tabs