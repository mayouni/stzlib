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
    
    AddCode(:NotNumber, '{
        @list = [ "NOT_NUMBER", @list ]
    }')
    
    AddCode(:NumberOrString, '{
        if isNumber(@list)
            @list = @list * 2
        else
            @list = upper(@list)
        ok
    }')
    
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
# Executed in 0.04 second(s) in Ring 1.22
