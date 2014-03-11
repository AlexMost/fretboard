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
            frets[i][j] = blFret i, j, notesMap[i][j], false, false
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
        self = @
        jnode = $(@getDOMNode())
        offset = jnode.offset()
        jnode_width = jnode.width()
        jnode_height = jnode.height()
        minX = offset.left
        maxX = offset.left + jnode_width
        @setState
            selector:
                initialPos:
                    x: offset.left
                    y: offset.top
                height: jnode_height
                width: 160
                minX: minX
                maxX: maxX
            selectorX: offset.left
            ->
                self.onSelectorMove offset.left

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

        tabs_to_play = @get_checked_frets_tabs().filter ([sN, fN]) ->
            self.state.frets[sN][fN].data().selected

        async.mapSeries tabs_to_play, iterator, ->

    pressTabs: (tabs) ->
        self = @
        frets = getClearFrets @state.stringsNum, @state.fretsNum, @state.notesMap
        frets[sNum][fNum].check() for [sNum, fNum] in tabs
        @setState {frets}, ->
            self.onSelectorMove self.state.selectorX

    get_checked_frets_tabs: ->
        ret_tabs = []
        for sNum, string of @state.frets
            for fNum, fret of string
                if fret.data().checked
                    ret_tabs.push [sNum, fNum]
        ret_tabs

    pressNotes: (notes) ->
        self = @
        frets = getClearFrets @state.stringsNum, @state.fretsNum, @state.notesMap
        for sN, string of frets
            for fN, fret of string
                if fret.data().note in notes
                    fret.check()
        @setState {frets}, ->
            self.onSelectorMove self.state.selectorX

    getInitialState: ->
        stringsNum = @props.data?.stringsNum or 6
        fretsNum = @props.data?.fretsNum or 16
        notesMap = generateNotes stringsNum, fretsNum, STANDART_TUNING
        frets = getClearFrets stringsNum, fretsNum, notesMap
        timeout = 200
        selector = null
        {stringsNum, fretsNum, notesMap, frets, timeout, selector}

    onSelectorMove: (x) ->
        @setState {selectorX: x}
        frets = @state.frets
        for sNum, string of frets
            for fNum, fret of string
                fret_offset = @state.selector.initialPos.x + fNum * @props.fretWidth
                if fret_offset >= x and fret_offset <= x + 160
                    fret.select()
                else
                    fret.unselect()
        @setState {frets}

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
    render: ->
        text = ''

        className = if @props.data.checked then "on" else "off"
        if @props.data.checked and @props.data.selected
            className = "on-selected"

        if @props.data.checked
            text = @props.data.note
        playClass = if @props.data.playing then "playing" else ''

        attrs =
            className: "col-md-1 fret #{className} #{playClass}"
            style:
                width: @props.width
                height: @props.height

        div attrs, text

module.exports = {Guitar, GString, Fret}
