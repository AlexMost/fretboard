{STEP, hSTEP, BigSTEP} = require './scales'

print_size = (size) ->
    (for s in size
        if s is STEP
            "Step"
        else if s is hSTEP
            "hStep"
        else if s is BigSTEP
        	"BigSTEP"
    ).join " - "

module.exports = {print_size}
