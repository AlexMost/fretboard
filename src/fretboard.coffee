React = require 'react'
async = require 'async'

{STANDART_TUNING, generateNotes} = require 'notes'
{div, li, ul} = React.DOM
{play_fret} = require 'notes_sound'
Selector = require 'selector'
$ = require 'jquery'


blFret = (sNum, fNum, note, checked, playing, selected) ->
    checked or= false
    playing or= false
    selected or=false

    data: -> {sNum, fNum, note, checked, playing, selected}
    playStart: -> playing = true
    playStop: -> playing = false
    check: -> checked = true
    uncheck: -> checked = false
    select: -> selected = true
    unselect: -> selected = false


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
    startPlayFret: ([sNum, fNum]) ->
        frets = @state.frets
        frets[sNum][fNum].playStart()
        @setState {frets}

    stopPlayFret: ([sNum, fNum]) ->
        frets = @state.frets
        frets[sNum][fNum].playStop()
        @setState {frets}

    componentDidMount: ->
        jnode = $(@getDOMNode())
        offset = jnode.offset()
        jnode_width = jnode.width()
        jnode_height = jnode.height()
        minX = offset.left
        maxX = offset.left + jnode_width
        @setState {selector: {
            initialPos: {x: offset.left, y: offset.top}
            height: jnode_height
            width: 160
            minX
            maxX}
        }

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

    onSelectorMove: (x) ->

    render: ->
        strings = [0..@state.stringsNum].map (num) =>
            GString
                data:
                    frets: @state.frets[num]
                Fwidth: @props.fretWidth
                Fheight: @props.fretHeight

        selector = if @state.selector
            selector_data = @state.selector
            selector_data["onXChange"] = @onSelectorMove
            Selector selector_data

        div {className: "guitar"}, [selector, strings]


GString = React.createClass
    displayName: "GString"
    render: ->
        self = @
        make_fret = (fret) ->
            Fret
                data: fret.data()
                width: self.props.Fwidth
                height: self.props.Fheight

        frets = [make_fret(fret)for fNum, fret of @props.data.frets]
        div {className: "row string"}, frets


Fret = React.createClass
    displayName: "Fret"
    play: ->
        play_fret @props.data.stringNum, @props.data.num
    render: ->
        className = if @props.data.checked then "on" else "off"
        text = if @props.data.checked then @props.data.note else ''
        playClass = if @props.data.playing then "playing" else ''

        attrs =
            className: "col-md-1 fret #{className} #{playClass}"
            style:
                width: @props.width
                height: @props.height

        div attrs, text

module.exports = {Guitar, GString, Fret}
