# Narrative
# --------
# Test 5: Capture Values of Defined Groups
#
# Extracted from stzRegexTest.ring, block #37.

load "../../stzBase.ring"


pr()

txt = "Name: John, Age: 30"

o1 = new stzRegex("Name: (.*), Age: (\d+)")

# First we see if the text matchs the patterns

? o1.Match(txt)
#--> TRUE

# If the pattern includes some defined groups,
# those enclosed between "(" and ")", the we
# can capture them and return them!

? o1.HasGroups()
#--> TRUE

# Captured values

? @@( o1.Capture() )
#--> [ "John", "30" ]

pf()
# Executed in almost 0 second(s) in Ring 1.22
