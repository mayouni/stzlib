# Narrative
# --------
# ListEx Type Patterns in Listexuter
#
# Extracted from stzlistexutertest.ring, block #1.

load "../../../stzBase.ring"


pr()

lxu() {
    # Using basic type patterns from ListEx
    AddTrigger(:ListOfNumbers = "[@N3]")    # One or more numbers
    
    AddCode(:ListOfNumbers, '{
        @list + [ :Sum = @Sum(@list), :Mean = @Mean(@list)  ]
    }')
    
    Process([
        [42, "hello"],
        [10, 20, 30],
        [99, "world"],
        [1, 2, 3, 4, 5]
    ])
    
    ? @@NL( Results() )
    #--> [
    #   [ [42, "hello"], [84, "HELLO"] ],
    #   [ [10, 20, 30], [10, 20, 30, "Sum = 60"] ],
    #   [ [99, "world"], [198, "WORLD"] ],
    #   [ [1, 2, 3, 4, 5], [1, 2, 3, 4, 5, "Sum = 15"] ]
    # ]
}

proff()
# Executed in 0.03 second(s) in Ring 1.22
