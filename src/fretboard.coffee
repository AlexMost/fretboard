React = require 'react'
async = require 'async'
{STANDART_TUNING, generateNotes} = require 'notes'
{div, li, ul, span, button, input} = React.DOM
{play_fret, load_fret} = require 'notes_sound'
{Thumbler, Dropdown, DirectionDropdown} = require 'toolbox'
Selector = require 'selector'
$ = require 'jquery'
{emitter} = require 'ev_channel'

{
EVENT_SOUNDS_LOADING_START
EVENT_SOUNDS_LOADING_STOP
} = require 'defs'


blFret = (sNum, fNum, note, checked, playing, selected, root_note) ->
    checked or= false
    playing or= false
    selected or=false
    root_note or=false

    data: -> {sNum, fNum, note, checked, playing, selected, root_note}
    playStart: -> playing = true
    playStop: -> playing = false
    check: -> checked = true
    uncheck: -> checked = false
    select: -> selected = true
    unselect: -> selected = false
    set_root: -> root_note = true


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
        selctorWidth = @state.selectorFretsCount * @props.fretWidth
        selectorHeight = @state.stringsNum * @props.fretHeight
        minX = offset.left
        maxX = offset.left + jnode_width - selctorWidth
        @setState
            selector:
                initialPos:
                    x: offset.left
                    y: offset.top
                height: selectorHeight
                width: selctorWidth
                minX: minX
                maxX: maxX
                onXChange: self.onSelectorMove
            selectorX: offset.left
            -> self.onSelectorMove offset.left

    playScale: ->
        @setState {is_playing: true}

        self = @
        play_iterator = ([sNum, fNum], cb) ->
            self.startPlayFret [sNum, fNum]
            play_fret sNum, fNum, ->
                setTimeout(
                    ->
                        self.stopPlayFret [sNum, fNum]
                        if self.state.is_playing then cb?() else cb?("stop")
                    self.state.timeout)

        tabs_to_play = @get_checked_frets_tabs().filter ([sN, fN]) ->
            self.state.frets[sN][fN].data().selected

        load_iterator = ([sNum, fNum], cb) -> load_fret sNum, fNum, cb

        emitter.pub EVENT_SOUNDS_LOADING_START
        async.map tabs_to_play, load_iterator, ->
            emitter.pub EVENT_SOUNDS_LOADING_STOP
            async.mapSeries tabs_to_play, play_iterator, (err) ->
                return unless self.state.is_playing
                self.toggleDirection() if self.state.changeDirection

                if self.state.repeat
                    self.playScale()
                else
                    self.setState {is_playing: false}

    stopPlayScale: -> @setState {is_playing: false}

    toggleDirection: ->
        if @state.direction is "UP"
            @setState {direction: "DOWN"}
        else
            @setState {direction: "UP"}

    pressTabs: (tabs) ->
        self = @
        frets = getClearFrets @state.stringsNum, @state.fretsNum, @state.notesMap
        frets[sNum][fNum].check() for [sNum, fNum] in tabs
        @setState {frets}, ->
            self.onSelectorMove self.state.selectorX

    get_checked_frets_tabs: ->
        ret_tabs = []

        strings = ([string, sN] for sN, string of @state.frets)
        strings = strings.reverse() if @state.direction is "DOWN"

        for [string, sNum] in strings
            frets = ([fret, fN] for fN, fret of string)
            frets = frets.reverse() if @state.direction is "UP"

            for [fret, fNum] in frets
                if fret.data().checked
                    ret_tabs.push [sNum, fNum]
        ret_tabs

    pressNotes: (notes, rootNote) ->
        self = @
        frets = getClearFrets @state.stringsNum, @state.fretsNum, @state.notesMap
        for sN, string of frets
            for fN, fret of string
                if fret.data().note is rootNote
                    fret.set_root()
                if fret.data().note in notes
                    fret.check()
        @setState {frets}, ->
            self.onSelectorMove self.state.selectorX

    getInitialState: ->
        stringsNum = @props.data?.stringsNum or 6
        fretsNum = @props.data?.fretsNum or 16
        notesMap = generateNotes stringsNum, fretsNum, STANDART_TUNING
        selectorFretsCount = @props.selectorFretsCount or 4
        frets = getClearFrets stringsNum, fretsNum, notesMap
        timeout = 200
        selector = null
        play_reverse = true
        is_playing = false
        direction = "DOWN"
        repeat = false
        changeDirection = false
        {stringsNum, fretsNum, notesMap, frets, timeout, selector,
         play_reverse, is_playing, selectorFretsCount, direction, repeat,
         changeDirection}

    onSelectorMove: (x) ->
        @setState {selectorX: x, is_playing: false}
        frets = @state.frets
        selectorWidth = @state.selectorFretsCount * @props.fretWidth
        for sNum, string of frets
            for fNum, fret of string
                fret_offset = @state.selector.initialPos.x + fNum * @props.fretWidth
                if fret_offset > x and fret_offset < x + selectorWidth + @props.fretWidth
                    fret.select()
                else
                    fret.unselect()
        @setState {frets}

    render: ->
        StringsList = [0..@state.stringsNum].map (num) =>
            GString
                data:
                    frets: @state.frets[num]
                Fwidth: @props.fretWidth
                Fheight: @props.fretHeight

        SelectorComp = (Selector @state.selector) if @state.selector

        (div
            style:
                width: @state.fretsNum * @props.fretWidth
            (div {}, SelectorComp, StringsList)
            (div {},
                (button
                    onClick: if @state.is_playing then @stopPlayScale else @playScale
                    (if @state.is_playing then "stop" else "play"))
                (DirectionDropdown
                    current_dir: @state.direction
                    onChange: (direction) => @setState {direction})
                (div {},
                    (input
                        type: "checkbox"
                        onChange: (ev) => @setState {repeat: ev.target.checked}
                        "repeat"))
                (div {},
                    (input
                        type: "checkbox"
                        onChange: (ev) => @setState {changeDirection: ev.target.checked}
                        "change direction"))
            )
        )


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
        div {className: "row"}, frets


Fret = React.createClass
    displayName: "Fret"
    render: ->
        text = ''

        className = if @props.data.checked then "on shadow" else "off"
        if @props.data.checked and @props.data.selected
            className = "on-selected shadow"

        if @props.data.root_note
            className = "on-selected-root shadow"

        if @props.data.checked
            text = @props.data.note

        playClass = if @props.data.playing then "playing" else ''

        attrs =
            className: "col-md-1 fret padding0"
            style:
                width: @props.width
                height: @props.height

        (div attrs,
            (span {className: "string"}, ""),
            (span {className: "circleBase #{className} #{playClass}"}, text))

module.exports = {Guitar, GString, Fret}
