React = require '../lib/react'
$ = require '../lib/jquery'

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
            newX
        else if newX <= minX
            minX
        else if newX >= maxX
            maxX

        @props.onXChange?(pos.x)

        @setState {pos}
        e.stopPropagation()
        e.preventDefault()

module.exports = Draggable
