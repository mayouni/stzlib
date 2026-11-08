# Narrative
# --------
# Quantifiers and Ranges
#
# Extracted from stzlistexutertest.ring, block #2.

load "../../stzBase.ring"


pr()

lxu() {
    # Using quantifiers and ranges from ListEx
    AddTrigger(:OneTwoNumbers = "[@N1-2, @S]")  # 1-2 numbers followed by string
    AddTrigger(:OptionalString = "[@N, @S?]")   # Number with optional string
    
    AddCode(:OneTwoNumbers, func v {
        if len(v) = 3  # Two numbers and a string
            v = [ v[1] + v[2], v[3] ]
        else  # One number and a string
            v = [ v[1], v[2] ]
        ok
        return v
    })
    
    AddCode(:OptionalString, func v {
        if len(v) = 2  # Has optional string
            v = [ "WITH_STRING", v ]
        else  # Just a number
            v = [ "NUMBER_ONLY", v ]
        ok
        return v
    })
    
    Process([
        [10, "apple"],      # OneTwoNumbers with one number
        [20, 30, "banana"], # OneTwoNumbers with two numbers
        [42],               # OptionalString without string
        [99, "optional"]    # OptionalString with string
    ])
    
    ? @@NL( MatchesXT() )
    #--> [
    #   [ [10, "apple"], [10, "apple"] ],
    #   [ [20, 30, "banana"], [50, "banana"] ],
    #   [ [42], ["NUMBER_ONLY", [42]] ],
    #   [ [99, "optional"], ["WITH_STRING", [99, "optional"]] ]
    # ]
}

proff()

pf()
# Executed in 0.03 second(s) in Ring 1.22
