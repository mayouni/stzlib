# Narrative
# --------
# Test 5: Word boundaries
#
# Extracted from stzRegexTest.ring, block #32.

load "../../../stzBase.ring"


pr()

txt = "prefix preprocess present"

o = new stzRegex("\bpre\w+")

# Matching words starting with 'pre'

? o.MatchXT(txt, 1, :MatchEntireContent, [])
#--> TRUE

# Test that fails (no 'pre' words)

txt = "compress express"
? o.MatchXT(txt, 1, :MatchEntireContent, [])
#--> FALSE

prf()
# Executed in 0.01 second(s) in Ring 1.22
