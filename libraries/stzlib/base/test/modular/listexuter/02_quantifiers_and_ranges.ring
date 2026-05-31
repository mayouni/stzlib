# Narrative
# --------
# Quantifiers and Ranges
#
# Extracted from stzlistexutertest.ring, block #2.

load "../../../stzBase.ring"


pr()

lxu() {
    # Using quantifiers and ranges from ListEx
    AddTrigger(:OneTwoNumbers = "[@N1-2, @S]")  # 1-2 numbers followed by string
    AddTrigger(:OptionalString = "[@N, @S?]")   # Number with optional string
    
    AddCode(:OneTwoNumbers, '{
        if len(@list) = 3  # Two numbers and a string
            @list = [ @list[1] + @list[2], @list[3] ]
        else  # One number and a string
            @list = [ @list[1], @list[2] ]
        ok
    }')
    
    AddCode(:OptionalString, '{
        if len(@list) = 2  # Has optional string
            @list = [ "WITH_STRING", @list ]
        else  # Just a number
            @list = [ "NUMBER_ONLY", @list ]
        ok
    }')
    
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
# Executed in 0.03 second(s) in Ring 1.22
