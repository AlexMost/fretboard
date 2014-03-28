React = require 'react'
$ = require 'jquery'

Draggable = ({useX, useY, minX, maxX}) ->
    componentDidUpdate: (props, state) ->
        if @state.dragging and not state.dragging
            document.addEventListener 'mousemove', @onMouseMove
            document.addEventListener 'mouseup', @onMouseUp
        else unless @state.dragging and state.dragging
            document.removeEventListener 'mousemove', @onMouseMove
            document.removeEventListener 'mouseup', @onMouseUp

    onMouseDown: (e) ->
        return if e.button isnt 0
        {top, left} = $(@getDOMNode()).offset()
        relx = e.pageX - left
        @setState {dragging: true, relx}
        e.stopPropagation()
        e.preventDefault()

    onMouseUp: (e) ->
        @setState {dragging: false}
        e.stopPropagation()
        e.preventDefault()

    onMouseMove: (e) ->
        return unless @state.dragging

        pos = {}
        newX = e.pageX - @state.relx
        {minX, maxX} = @props

        pos.x = if useX and newX >= minX and newX <= maxX
            console.log "settings onmousemove", newX, minX, maxX
            newX
        else if newX <= minX
            console.log "on mouse move set min", newX, minX, maxX
            minX
        else if newX >= maxX
            console.log "on mouse move set max", newX, minX, maxX
            maxX

        @props.onXChange?(pos.x)

        @setState {pos}
        e.stopPropagation()
        e.preventDefault()

module.exports = Draggable
