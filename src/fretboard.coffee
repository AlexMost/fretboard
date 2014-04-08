async = require '../lib/async'
React = require 'react'
$ = require '../lib/jquery'
{emitter} = require '../lib/ev_channel'

{generateNotes} = require './notes'
{div, li, ul, span, button, input} = React.DOM
{play_fret, load_fret} = require './notes_sound'
{Thumbler, SimpleDropdown, DirectionDropdown, ToggleButton} = require './toolbox'
Selector = require './selector'
{SCALES} = require './scales'


{
EVENT_SOUNDS_LOADING_START
EVENT_SOUNDS_LOADING_STOP
} = require './defs'


blFret = (sNum, fNum, note, checked, playing,
          selected, root_note, is_open) ->
    checked or= false
    playing or= false
    selected or=false
    root_note or=false
    is_open or=false

    data: -> {sNum, fNum, note, checked, playing, selected, root_note, is_open}
    playStart: -> playing = true
    playStop: -> playing = false
    check: -> checked = true
    uncheck: -> checked = false
    select: -> selected = true
    unselect: -> selected = false
    set_root: -> root_note = true
    set_open: -> is_open = true


blString = (sNum, frets) ->
    {sNum, frets}


getClearFrets = (sNum, fNum, notesMap) ->
    frets = {}
    for i in [1..sNum]
        frets[i] = {}
        for j in [0..fNum]
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
            tuningOffset = self.props.tuning.offset[sNum-1]
            play_fret sNum, (parseInt(fNum) + tuningOffset), ->
                setTimeout(
                    ->
                        self.setState {playing_fret: null}
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

    componentDidMount: ->
        jnode = $(@getDOMNode())
        offset = jnode.find(".js-guitar").offset()
        selectorWidth = @state.selectorFretsCount * @props.fretWidth
        selector = @state.selector
        selectorX = offset.left
        selector.initialPos = {x: selectorX, y: offset.top}
        selector.minX = offset.left
        selector.maxX = offset.left + ((@state.fretsNum+1) * @props.fretWidth) - selectorWidth
        @setState {selector, selectorX}

    getInitialState: ->
        stringsNum = @props.data?.stringsNum or 6
        fretsNum = @props.data?.fretsNum or 16
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
            height: stringsNum * @props.fretHeight
            width: selectorWidth
            onXChange: @onSelectorMove

        {stringsNum, fretsNum, timeout, selector,
         play_reverse, is_playing, selectorFretsCount, direction, repeat,
         changeDirection, selector, playing_fret}

    onSelectorMove: (x) -> @setState {selectorX: x, is_playing: false}

    get_frets: ->
        notesMap = generateNotes @state.stringsNum, @state.fretsNum, @props.tuning.notes
        notes = (SCALES[@props.Scale].get_notes @props.Note)
        frets = getClearFrets @state.stringsNum, @state.fretsNum, notesMap
        selectorWidth = @state.selectorFretsCount * @props.fretWidth

        return frets unless @state.selector.initialPos

        x = @state.selectorX

        for sN, string of frets
            for fN, fret of string
                fret_offset = @state.selector.initialPos.x + fN * @props.fretWidth

                if fret_offset >= x and fret_offset < x + selectorWidth
                    fret.select()

                if fret.data().note is @props.Note
                    fret.set_root()

                if @state.playing_fret and @state.is_playing
                    [_sN, _fN] = @state.playing_fret
                    if _sN is sN and _fN is fN
                        fret.playStart()

                if fret.data().note in notes
                    fret.check()

                fret.set_open() if fN is "0"

        frets


    render: ->
        frets = @get_frets()

        StringsList = [0..@state.stringsNum].map (num) =>
            GString
                key: "string_item_#{num}"
                data:
                    frets: frets[num]
                Fwidth: @props.fretWidth
                Fheight: @props.fretHeight


        SelectorComp = if @state.selector.initialPos
            (Selector @state.selector) if @state.selector
        else
            div()

        FretNumbers =
            (div {className: "row", style: {marign: 0}},
                [0..@state.fretsNum].map (num) =>
                    active = ""
                    x = @state.selectorX
                    if x
                        selectorWidth = @state.selectorFretsCount * @props.fretWidth
                        fret_offset = @state.selector.initialPos.x + num * @props.fretWidth
                        if fret_offset >= x and fret_offset < x + selectorWidth
                            active = "active-num"
                    (div
                        key: "fret_num_#{num}"
                        className: "col-md-1 fretnum #{active}"
                        style: {width: "#{@props.fretWidth}px"}
                        num)
            )

        (div
            style:
                width: (@state.fretsNum+1) * @props.fretWidth
                margin: "auto"
            (div
                className: "js-guitar"
                SelectorComp
                StringsList)
            FretNumbers
            (div {className: "text-center"},
                (div
                    className: "btn-group bot-toolbar panel panel-default"
                    (button
                        className: "btn btn-default"
                        onClick: if @state.is_playing then @stopPlayScale else @playScale
                        if @state.is_playing
                            (span {className: "glyphicon glyphicon-stop"}, "")
                        else
                            (span {className: "glyphicon glyphicon-play"}, "")
                    )
                    (ToggleButton
                        onChange: => @toggleDirection()
                        if @state.direction is "UP"
                            (span {className: "glyphicon glyphicon-arrow-down"})
                        else
                            (span {className: "glyphicon glyphicon-arrow-up"})
                    )
                    (ToggleButton
                        onChange: (repeat) => @setState {repeat}
                        (span {className: "glyphicon glyphicon-repeat"}))
                    (ToggleButton
                        onChange: (changeDirection) => @setState {changeDirection}
                        (span {className: "glyphicon glyphicon-random"})))
            )
        )


GString = React.createClass
    displayName: "GString"
    render: ->
        self = @
        make_fret = (fret) ->
            Fret
                key: "fret_#{fret.data().sNum}#{fret.data().fNum}"
                data: fret.data()
                width: self.props.Fwidth
                height: self.props.Fheight

        frets = [make_fret(fret)for fNum, fret of @props.data.frets]
        div {className: "row"}, frets


Fret = React.createClass
    displayName: "Fret"
    render: ->
        text = ''
        fretClass = "fret"

        className = if @props.data.checked then "on shadow" else "off"
        if @props.data.checked and @props.data.selected
            className = "on-selected shadow"

        if @props.data.root_note
            className = "on-selected-root shadow"

        if @props.data.checked
            text = @props.data.note

        playClass = if @props.data.playing then "playing" else ''

        if @props.data.is_open
            unless @props.data.checked
                className = "#{className} open shadow"
            text = @props.data.note
            fretClass = ""

        attrs =
            className: "col-md-1 #{fretClass} padding0"
            style:
                width: @props.width
                height: @props.height

        (div attrs,
            (span {className: "string"}, ""),
            (span {className: "circleBase #{className} #{playClass}"}, text))

module.exports = {Guitar, GString, Fret}
