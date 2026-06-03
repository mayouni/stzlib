# Narrative
# --------
# Test 2: Case sensitivity
#
# Extracted from stzRegexTest.ring, block #29.

load "../../stzBase.ring"


pr()

txt = "Hello World"

o = new stzRegex("")
o.SetPattern("hello world")

# Case sensitive (default)

? o.MatchXT(txt, 1, :MatchEntireContent, [])  # Returns false - different case
#--> FALSE

# Case insensitive

? o.MatchXT(txt, 1, :MatchEntireContent, [ :CaseInsensitive ])  # Returns true - case ignored
#--> TRUE

pf()
# Executed in almost 0 second(s) in Ring 1.22
