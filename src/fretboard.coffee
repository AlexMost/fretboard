React = require 'react'
{STANDART_TUNING, generateNotes} = require 'notes'
{div, li, ul} = React.DOM


Guitar = React.createClass
    displayName: "Guitar"
    pressStringFrets: (tabs) -> @setState {data: {tabs}}
    getInitialState: ->
        stringsNum = @props.data?.stringsNum or 6
        fretsNum = @props.data?.fretsNum or 16
        notesMap = generateNotes stringsNum, fretsNum, STANDART_TUNING
        {stringsNum, fretsNum, notesMap}

    render: ->
        tabs = @state.data?.tabs
        strings = [1..@state.stringsNum].map (num) =>
            frets = if tabs
                tabs.filter(([sN, fN]) -> sN is num).map ([sN, fN]) -> fN
            else
                []
            GString {data:{num, fretsNum: @state.fretsNum, frets, notesMap: @state.notesMap}}
        div {className: "guitar"}, strings


GString = React.createClass
    displayName: "GString"
    render: ->
        frets = [1..@props.data.fretsNum].map (num) =>
            checked = num in (@props.data.frets or [])
            note = if checked
                @props.data.notesMap[@props.data.num][num]
            else
                ""
            Fret {data: {checked, num, stringNum: @props.data.num, note}}

        ul {className: "string"}, frets


Fret = React.createClass
    displayName: "Fret"
    render: ->
        className = if @props.data.checked then "on" else "off"
        li {className: "#{className} fret"}, @props.data.note


module.exports = {Guitar, GString, Fret}