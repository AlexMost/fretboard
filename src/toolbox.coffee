React = require 'react'
{select, option} = React.DOM


Option = React.createClass
    getInitialState: ->
        text = @props.data?.text or "Undefined"
        value = @props.data?.value or "Undefined"
        {text, value}

    render: ->
        option {value: @state.value}, @state.text


Dropdown = React.createClass
    displayName: "Dropdown"
    changeHandler: (event) -> @props.onChange {value: @getValue()}
    getValue: -> @refs.select.getDOMNode().value
    getInitialState: ->
        {options: [Option({data: {value:1, text: "opt1"}}), Option()]}
    render: ->
        select {ref:"select", onChange: @changeHandler}, @state.options


module.exports = {Dropdown}
