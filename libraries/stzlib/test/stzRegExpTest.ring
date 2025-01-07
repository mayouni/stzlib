load "../max/stzmax.ring"


# Example usage with correct function signatures
profon()
 
    # Example 1: Several Times (including 0)
    o1 = new stzRegExpMaker
    o1.addCharsRange("A-Z", :several, 0, 0)  # Second 0 is unused but required for signature
    ? "1. Match letters zero or more times:"
    ? o1.textGraph()
    ? ""
    
    # Example 2: At Least
    o2 = new stzRegExpMaker
    o2.addDigitsRange("0-9", :atLeast, 3, 0)  # Last parameter unused but required
    ? "2. Match at least 3 digits:"
    ? o2.textGraph()
    ? ""
    
    # Example 3: At Most
    o3 = new stzRegExpMaker
    o3.addCharsRange("A-Z", :atMost, 5, 0)  # Last parameter unused but required
    ? "3. Match at most 5 letters:"
    ? o3.textGraph()
    ? ""

    # Example 4: Between Range
    o4 = new stzRegExpMaker
    o4.addDigitsRange("0-9", :between, 2, 4)  # Both numbers used for range
    ? "4. Match between 2 and 4 digits:" + NL
    ? o4.textGraph()
    ? ""
    
    # Example 5: Complex Pattern
    o5 = new stzRegExpMaker
    o5.addCharsRange("A-Z", :exactly, 2, 0)
     o5.addDigitsRange("0-9", :between, 2, 4)
     o5.addCharsRange("A-Z", :atLeast, 1, 0)
    ? "5. Complex pattern example:" + NL
    ? o5.textGraph()

proff()
# Executed in almost 0 second(s) in Ring 1.22

/*=====


o1 = new stzRegExp("[-.a-z0-9]+[@][-.a-z0-9]+[.][a-z]{2,4}")

? o1.IsValid()
#--> TRUE

? o1.Match("kalidianow@gmail.com")
#--> TRUE


proff()

/*----

profon()

o1 = new stzRegExp("^(\d\d)/(\d\d)/(\d\d\d\d)$")

? o1.IsValid()
#--> TRUE

? o1.Match("07/01/2025") + NL
#--> TRUE

? o1.Capture()
#--> [ "07", "01", "2025" ]

proff()
# Executed in almost 0 second(s) in Ring 1.22
