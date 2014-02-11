{Guitar} = require 'fretboard'
{Dropdown} = require 'toolbox'
React = require 'react'
{div} = React.DOM


React.renderComponent Guitar(), document.getElementById "container"


handleDropdownChange = (args) ->
    console.log "Value changed #{args.value}"


React.renderComponent(
    (div {},
        (Dropdown {onChange: handleDropdownChange}),
        (Dropdown {}))

    document.getElementById "toolbar"
)