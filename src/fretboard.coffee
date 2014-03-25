React = require 'react'
async = require 'async'
{STANDART_TUNING, generateNotes} = require 'notes'
{div, li, ul, span, button, input} = React.DOM
{play_fret, load_fret} = require 'notes_sound'
{Thumbler, Dropdown, DirectionDropdown} = require 'toolbox'
Selector = require 'selector'
$ = require 'jquery'
{emitter} = require 'ev_channel'
{SCALES} = require 'scales'

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
    startPlayFret: (fret) -> @setState {playing_fret: fret}

    playScale: ->
        @setState {is_playing: true}

        self = @
        play_iterator = ([sNum, fNum], cb) ->
            self.startPlayFret [sNum, fNum]
            play_fret sNum, fNum, ->
                setTimeout(
                    ->
                        if self.state.is_playing then cb?() else cb?("stop")
                    self.state.timeout)

        tabs_to_play = @get_selected_frets()

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

    get_selected_frets: ->
        ret_tabs = []

        strings = ([string, sN] for sN, string of @get_frets())
        strings = strings.reverse() if @state.direction is "DOWN"

        for [string, sNum] in strings
            frets = ([fret, fN] for fN, fret of string)
            frets = frets.reverse() if @state.direction is "UP"

            for [fret, fNum] in frets
                if fret.data().selected and fret.data().checked
                    ret_tabs.push [sNum, fNum]
        ret_tabs

    getInitialState: ->
        stringsNum = @props.data?.stringsNum or 6
        fretsNum = @props.data?.fretsNum or 16
        notesMap = generateNotes stringsNum, fretsNum, STANDART_TUNING
        selectorFretsCount = @props.selectorFretsCount or 4
        timeout = 400
        selector = null
        play_reverse = true
        is_playing = false
        direction = "DOWN"
        repeat = false
        changeDirection = false
        selectorWidth = selectorFretsCount * @props.fretWidth
        playing_fret = null
        selector =
            initialPos: {x: 0, y: 0}
            height: stringsNum * @props.fretHeight
            width: selectorWidth
            minX: 0
            maxX: fretsNum * @props.fretWidth - selectorWidth
            onXChange: @onSelectorMove

        selectorX = 0

        {stringsNum, fretsNum, notesMap, timeout, selector,
         play_reverse, is_playing, selectorFretsCount, direction, repeat,
         changeDirection, selector, selectorX, playing_fret}

    onSelectorMove: (x) -> @setState {selectorX: x, is_playing: false}

    get_frets: ->
        notes = (SCALES[@props.Scale].get_notes @props.Note)

        frets = getClearFrets @state.stringsNum, @state.fretsNum, @state.notesMap

        selectorWidth = @state.selectorFretsCount * @props.fretWidth
        x = @state.selectorX

        for sN, string of frets
            for fN, fret of string
                fret_offset = @state.selector.initialPos.x + fN * @props.fretWidth

                if fret_offset > x and fret_offset < x + selectorWidth + @props.fretWidth
                    fret.select()

                if fret.data().note is @props.Note
                    fret.set_root()

                if @state.playing_fret and @state.is_playing
                    [_sN, _fN] = @state.playing_fret
                    if _sN is sN and _fN is fN
                        fret.playStart()

                if fret.data().note in notes
                    fret.check()
        frets

    render: ->
        frets = @get_frets()
        StringsList = [0..@state.stringsNum].map (num) =>
            GString
                data:
                    frets: frets[num]
                Fwidth: @props.fretWidth
                Fheight: @props.fretHeight

        SelectorComp = (Selector @state.selector) if @state.selector

        (div
            style:
                width: @state.fretsNum * @props.fretWidth
            (DirectionDropdown
                    current_dir: @state.direction
                    onChange: (direction) => @setState {direction})
            (input
                type: "checkbox"
                onChange: (ev) => @setState {repeat: ev.target.checked}
                "repeat")
            (input
                type: "checkbox"
                onChange: (ev) => @setState {changeDirection: ev.target.checked}
                "change direction")
            (div
                style:
                    position: "relative"
                SelectorComp
                StringsList)
            (div {},
                (button
                    onClick: if @state.is_playing then @stopPlayScale else @playScale
                    (if @state.is_playing then "stop" else "play"))
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
