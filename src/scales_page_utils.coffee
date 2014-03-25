{STEP, hSTEP} = require 'scales'

print_size = (size) ->
    (for s in size
        if s is STEP
            "Step"
        else if s is hSTEP
            "hStep"
    ).join " - "

module.exports = {print_size}
