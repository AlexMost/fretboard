React = require 'react'
$ = require 'jquery'

Draggable = ({useX, useY, bounds}) ->
    getDefaultProps: ->
        initialPos: {x: 270, y: 141}

    getInitialState: ->
        pos: @props.initialPos
        dragging: false
        rel: null

    componentDidUpdate: (props, state) ->
        if @state.dragging and not state.dragging
            document.addEventListener 'mousemove', @onMouseMove
            document.addEventListener 'mouseup', @onMouseUp
        else unless @state.dragging and state.dragging
            document.removeEventListener 'mousemove', @onMouseMove
            document.removeEventListener 'mouseup', @onMouseUp

    onMouseDown: (e) ->
        return if e.button isnt 0
        pos = $(@getDOMNode()).offset()

        rel = {}
        if useX
            rel.x = e.pageX - pos.left
        if useY
            rel.y = e.pageY - pos.top

        @setState {dragging: true, rel}
        e.stopPropagation()
        e.preventDefault()

    onMouseUp: (e) ->
        @setState {dragging: false}
        e.stopPropagation()
        e.preventDefault()

    onMouseMove: (e) ->
        return unless @state.dragging

        pos = {}
        if useX
            pos.x = e.pageX - @state.rel.x
        if useY
            pos.y = e.pageY - @state.rel.y

        @setState {pos}
        e.stopPropagation()
        e.preventDefault()

module.exports = Draggable
