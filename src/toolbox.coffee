React = require 'react'
{select, option, button} = React.DOM


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


Thumbler = React.createClass
    displayName: "Thumbler"
    getDefaultProps: ->
        state1: "On"
        state2: "Off"
        onChange: ->
    getInitialState: ->
        {value: @props.value or @props.state1}

    toggle: ->
        {state1, state2} = @props
        value = if @state.value is state1
            state2
        else
            state1
        @setState {value}, ->
            @props.onChange value

    render: ->
        button {onClick: @toggle}, @state.value


module.exports = {Dropdown, Thumbler}
