React = require 'react'
Draggable = require 'draggable'
{div} = React.DOM

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

module.exports = Selector