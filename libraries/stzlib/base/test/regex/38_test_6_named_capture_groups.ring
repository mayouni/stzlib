# Narrative
# --------
# Test 6: Named Capture Groups
#
# Extracted from stzRegexTest.ring, block #38.

load "../../stzBase.ring"


pr()

txt = "Name: John, Age: 30"

o1 = new stzRegex("Name: (?<name>.*), Age: (?<age>\d+)")

# If the pattern includes named groups (between "<" and ">"),
# then we can capture them and return them

? o1.Match(txt)
#--> TRUE

? o1.HasNames() + NL
#--> TRUE

# Capturing names (just names)

? @@( o1.Names() ) + NL
#--> [ "name", "age" ]

# We can see the names and their values when we use
# the eXTended form of Cpature() function

? @@NL( o1.CaptureXT() )
#--> [
#	[ "name", "John" ],
#	[ "age", "30" ]
# ]

pf()
# Executed in almost 0 second(s) in Ring 1.22
