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
    getDefaultProps: -> onChange: ->
    changeHandler: (event) -> @props.onChange {value: @getValue()}
    getValue: -> @refs.select.getDOMNode().value
    getInitialState: ->
        unless @props.data?.options
            {options: [Option({data: {value:1, text: "opt1"}}), Option()]}
        else
            options = @props.data.options.map ([value, text]) ->
                Option {data: {value, text}}
            {options}
    render: ->
        select {
                ref:"select",
                onChange: @changeHandler
                }, @state.options


module.exports = {Dropdown}
