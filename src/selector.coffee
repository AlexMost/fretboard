React = require 'react'
Draggable = require 'draggable'
{div, span, img} = React.DOM
{emitter} = require 'ev_channel'

{
EVENT_SOUNDS_LOADING_START
EVENT_SOUNDS_LOADING_STOP
} = require 'defs'

Selector = React.createClass
    displayName: "Selector"
    mixins: [Draggable({useY:false, useX: true})]

    componentDidMount: ->
        emitter.sub EVENT_SOUNDS_LOADING_START, @turnOnLoader
        emitter.sub EVENT_SOUNDS_LOADING_STOP, @turnOfLoader

    getInitialState: ->
        pos: @props.initialPos
        dragging: false
        rel: null
        loader: !!(@props.loader)
        loaderFontSize: 20

    getDefaultProps: ->
        initialPos: {x: 270, y: 141}

    turnOnLoader: -> @setState {loader: true}

    turnOfLoader: -> @setState {loader: false}

    render: ->
        div
            className: "col-md-4 selector",
            style:
                height: @props.height
                width: @props.width
                left: "#{@state.pos.x}px"
                top: "#{@state.pos.y}px"
                position: 'absolute'
            onMouseDown: @onMouseDown,
            onMouseUp: @onMouseUp,

            div
                style:
                    width: "100%"
                    height: "100%"
                    background: "black"
                    'text-align': "center"
                    position: "relative"
                    opacity: 0.5
                    "padding-top": "#{(@props.height/2 - @state.loaderFontSize)}px"
                    display: if @state.loader then "block" else "none"

                span
                    style:
                        opacity: 1
                        color: "white"
                        "font-size": "#{@state.loaderFontSize}px"
                        "text-align:": "center"
                        "font-style": "italic"
                    "loading "
                img
                    src: "resources/ajax-loader.gif"

module.exports = Selector