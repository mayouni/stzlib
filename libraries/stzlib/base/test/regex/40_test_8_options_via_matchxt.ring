# Narrative
# --------
# Test 8: Options via MatchXT
#
# Extracted from stzRegexTest.ring, block #40.

load "../../stzBase.ring"


pr()

o1 = new stzRegex("hello world")

# Case sensitive (should fail)

? o1.MatchXT("HELLO world", 1, :MatchEntireContent, [])
#--> FALSE

# Case insensitive (should match)

? o1.MatchXT("HELLO world", 1, :MatchEntireContent, [ :CaseInsensitive ])
#--> TRUE

pf()
# Executed in almost 0 second(s) in Ring 1.22
