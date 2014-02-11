{Guitar} = require 'fretboard'
React = require 'react'

guitar = Guitar()
React.renderComponent(
    guitar
    document.getElementById "container"
)

tabs = [
    [1, 2]
    [1, 4]
    [1, 6]
    [2, 3]
    [3, 4]
]

guitar.pressStringFrets tabs