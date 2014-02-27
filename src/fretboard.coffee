React = require 'react'
{STANDART_TUNING, generateNotes} = require 'notes'
{div, li, ul} = React.DOM
{play_fret} = require 'notes_sound'


blFret = (sNum, fNum, note, checked) ->
    data: -> {sNum, fNum, note, checked}
    check: -> checked = true
    uncheck: -> checked = false


blString = (sNum, frets) ->
    {sNum, frets}


getClearFrets = (sNum, fNum, notesMap) ->
    frets = {}
    for i in [1..sNum]
        frets[i] = {}
        for j in [1..fNum]
            frets[i][j] = blFret i, j, notesMap[i][j], false
    frets


Guitar = React.createClass
    displayName: "Guitar"
    pressStringFrets: (tabs) ->
        frets = getClearFrets @state.stringsNum, @state.fretsNum, @state.notesMap
        frets[sNum][fNum].check() for [sNum, fNum] in tabs
        @setState {frets}

    getInitialState: ->
        stringsNum = @props.data?.stringsNum or 6
        fretsNum = @props.data?.fretsNum or 16
        notesMap = generateNotes stringsNum, fretsNum, STANDART_TUNING
        frets = getClearFrets stringsNum, fretsNum, notesMap
        {stringsNum, fretsNum, notesMap, frets}

    render: ->
        strings = [0..@state.stringsNum].map (num) =>
            GString {data: {frets: @state.frets[num]}}
        div {className: "guitar"}, strings


GString = React.createClass
    displayName: "GString"
    render: ->
        frets = [Fret {data: fret.data()} for fNum, fret of @props.data.frets]
        div {className: "row string"}, frets


Fret = React.createClass
    displayName: "Fret"
    play: ->
        play_fret @props.data.stringNum, @props.data.num
    render: ->
        className = if @props.data.checked then "on" else "off"
        text = if @props.data.checked then @props.data.note else ''
        div {className: "col-md-1 fret #{className}"}, text


module.exports = {Guitar, GString, Fret}