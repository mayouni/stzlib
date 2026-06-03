# Narrative
# --------
# Test 7: Error Handling
#
# Extracted from stzRegexTest.ring, block #39.

load "../../stzBase.ring"


pr()

o1 = new stzRegex("(unclosed group")

# Pattern validity

? o1.IsValid()
#--> FALSE

? o1.LastError()
#--> missing closing parenthesis

pf()
# Executed in almost 0 second(s) in Ring 1.22
