# Narrative
# --------
# Negation and Alternation
#
# Extracted from stzlistexutertest.ring, block #3.

load "../../stzBase.ring"


pr()

lxu() {
    # Using negation and alternation from ListEx
    AddTrigger(:NotNumber = "[@!N]")       # Anything but a number
    AddTrigger(:NumberOrString = "[@N|@S]") # Either number or string
    
    AddCode(:NotNumber, func v {
        v = [ "NOT_NUMBER", v ]
        return v
    })
    
    AddCode(:NumberOrString, func v {
        if isNumber(v)
            v = v * 2
        else
            v = upper(v)
        ok
        return v
    })
    
    Process([
        "text",      # NotNumber and NumberOrString
        42,          # NumberOrString but not NotNumber
        [1, 2, 3],   # NotNumber but not NumberOrString
        ["a", "b"]   # NotNumber but not NumberOrString
    ])
    
    ? @@NL( MatchesXT() )
    #--> [
    #   [ "text", ["NOT_NUMBER", "text"] ],
    #   [ "text", "TEXT" ],
    #   [ 42, 84 ],
    #   [ [1, 2, 3], ["NOT_NUMBER", [1, 2, 3]] ],
    #   [ ["a", "b"], ["NOT_NUMBER", ["a", "b"]] ]
    # ]
}

proff()

pf()
# Executed in 0.04 second(s) in Ring 1.22
