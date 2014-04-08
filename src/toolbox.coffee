React = require 'react'
{select, option, button, ul, li, span, div, a} = React.DOM


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
        @setState {value}, =>
            @props.onChange value

    render: ->
        button {onClick: @toggle}, @state.value


SimpleDropdown = React.createClass
    displayName: "SimpleDropdown"
    getDefaultProps: -> onChange: ->

    getInitialState: ->
        isOpen: false
        value: @props.value or ""

    toggle: -> @setState {isOpen: !@state.isOpen}

    itemClick: (ev) ->
        ev.preventDefault()
        value = (ev.target.getAttribute "value")
        @setState {value, isOpen: false}
        @props.onChange value

    render: ->
        self = @
        options = @props.options.map ([value, text]) ->
            (li {},
                (a {value, href: "#", onClick: self.itemClick}, text))

        openCls = if @state.isOpen then "open" else ""

        currentOption = (@props.options.filter ([value, text]) =>
            value.toString() is @state.value.toString())?[0]

        (div
            className: "btn-group #{openCls}"
            (button
                className: "btn btn-default"
                onClick: @toggle
                (span {className: "glyphicon"}, "")
                currentOption?[1]
                (span {className: "caret"}, ""))
            (ul
                className: "dropdown-menu"
                ref: "select"
                options))

ToggleButton = React.createClass
    getInitialState: ->
        active: @props.active or false

    getDefaultProps: ->
        onChange: ->

    toggle: ->
        @setState {active: not @state.active}, ->
            @props.onChange @state.active

    render: ->
        active = if @state.active then "active" else ""
        (button
            className: "btn btn-default my-btn #{active}"
            onClick: @toggle
            type: "button"
            @props.children
        )



DirectionDropdown = ({current_dir, onChange}) ->
    options = [
        ["DOWN", "DOWN"]
        ["UP", "UP"]
    ]

    SimpleDropdown
        options: options
        onChange: onChange
        value: current_dir


module.exports = {SimpleDropdown, Dropdown, Thumbler, DirectionDropdown, ToggleButton}
