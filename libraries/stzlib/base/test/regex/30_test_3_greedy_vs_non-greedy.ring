# Narrative
# --------
# Test 3: Greedy vs Non-greedy
#
# Extracted from stzRegexTest.ring, block #30.

load "../../stzBase.ring"


pr()

txt = "<p>First</p><p>Second</p>"

o = new stzRegex("")
o.SetPattern("<p>.*</p>")

# Greedy (default): Matches entire string

? o.MatchXT(txt, 1, :MatchEntireContent, [ :DotMatchesAll ])
#--> TRUE

# Non-greedy: Matches first <p> only

? o.MatchXT(txt, 1, :MatchEntireContent, [ :DotMatchesAll, :NonGreedy ])
#--> TRUE

pf()
# Executed in almost 0 second(s) in Ring 1.22
