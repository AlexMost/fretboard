React = require('react')
{div, li, ul} = React.DOM


Guitar = React.createClass
    displayName: "Guitar"
    pressStringFrets: (tabs) ->
        stringsNum = @props.data?.stringsNum or 6
        fretsNum = @props.data?.fretsNum or 16
        strings = [1..stringsNum].map (num) =>
            frets = tabs.filter(([sN, fN]) -> sN is num).map ([sN, fN]) -> fN
            data = {num, fretsNum, frets}
            GString {data}
        @setState {data: strings}

    getInitialState: ->
        stringsNum = @props.data?.stringsNum or 6
        fretsNum = @props.data?.fretsNum or 16
        tabs = @props.data?.tabs
        strings = [1..stringsNum].map (num) =>
            frets = if tabs
                tabs.filter(([sN, fN]) -> sN is num).map ([sN, fN]) -> fN
            else
                []
            data = {num, fretsNum, frets}
            GString {data}
        {data: strings}

    render: ->
        div {className: "guitar"}, @state.data


GString = React.createClass
    displayName: "GString"
    render: ->
        frets = [1..@props.data.fretsNum].map (num) =>
            checked = num in (@props.data.frets or [])
            Fret {data: {checked, num, stringNum: @props.data.num}}

        ul {className: "string"}, frets


Fret = React.createClass
    displayName: "Fret"
    render: ->
        className = if @props.data.checked then "on" else "off"
        li {className: "#{className} fret"}


module.exports = {Guitar, GString, Fret}