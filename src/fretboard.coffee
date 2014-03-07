React = require 'react'
async = require 'async'

{STANDART_TUNING, generateNotes} = require 'notes'
{div, li, ul} = React.DOM
{play_fret} = require 'notes_sound'
Draggable = require 'draggable'
$ = require 'jquery'


blFret = (sNum, fNum, note, checked, playing) ->
    checked or= false
    playing or= false

    data: -> {sNum, fNum, note, checked, playing}
    playStart: -> playing = true
    playStop: -> playing = false
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

Selector = React.createClass
    displayName: "Selector"
    mixins: [Draggable({useY:false, useX: true})]
    render: ->
        div
            className: "col-md-4 selector",
            style:
                height: 187
                left: @state.pos.x + 'px'
                top: @state.pos.y + 'px'
                position: 'absolute'
            onMouseDown: @onMouseDown,
            onMouseUp: @onMouseUp,
            onClick: @click


Guitar = React.createClass
    displayName: "Guitar"
    startPlayFret: ([sNum, fNum]) ->
        frets = @state.frets
        frets[sNum][fNum].playStart()
        @setState {frets}

    stopPlayFret: ([sNum, fNum]) ->
        frets = @state.frets
        frets[sNum][fNum].playStop()
        @setState {frets}

    componentDidMount: ->
        offset = $(@getDOMNode()).offset()
        @setState {selector: {initialPos: {x: offset.left, y: offset.top}}}

    playScale: ->
        self = @
        iterator = ([sNum, fNum], cb) ->
            self.startPlayFret [sNum, fNum]
            play_fret sNum, fNum, ->
                setTimeout(
                    ->
                        self.stopPlayFret [sNum, fNum]
                        cb?()
                    self.state.timeout)
        async.mapSeries @state.tabs, iterator, ->

    pressStringFrets: (tabs) ->
        frets = getClearFrets @state.stringsNum, @state.fretsNum, @state.notesMap
        frets[sNum][fNum].check() for [sNum, fNum] in tabs
        @setState {frets, tabs}

    getInitialState: ->
        stringsNum = @props.data?.stringsNum or 6
        fretsNum = @props.data?.fretsNum or 16
        notesMap = generateNotes stringsNum, fretsNum, STANDART_TUNING
        frets = getClearFrets stringsNum, fretsNum, notesMap
        timeout = 500
        selector = null
        {stringsNum, fretsNum, notesMap, frets, timeout, selector}

    render: ->
        strings = [0..@state.stringsNum].map (num) =>
            GString {data: {frets: @state.frets[num]}}

        selector = if @state.selector then Selector @state.selector else null

        div {className: "guitar"}, [selector, strings]


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
        playClass = if @props.data.playing then "playing" else ''
        div {className: "col-md-1 fret #{className} #{playClass}"}, text


module.exports = {Guitar, GString, Fret}