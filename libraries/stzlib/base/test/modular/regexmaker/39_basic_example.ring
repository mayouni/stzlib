# Narrative
# --------
# Basic example
#
# Extracted from stzregexmakertest.ring, block #39.

load "../../../stzBase.ring"


pr()

o1 = new stzRegexLookAroundMaker

# Looking around with Softanzified semantics

o1.MustBePrecededBy("Mr\.").ThenMatch("[A-Z][a-z]+")
o1.CantBeFollowedBy("px").ThenMatch("\d+")
o1.MustBeFollowedByWord("hello").ThenMatch("\w+")
? o1.Pattern()
#--> (?=\bhello\b)\w+

# Still works with original "looking" terminology

o1.LookingBehind("Mr\.").ThenMatch("[A-Z][a-z]+")
o1.NotLookingAhead("px").ThenMatch("\d+")
o1.LookingForWord("hello").ThenMatch("\w+")
? o1.Pattern()
#--> (?=\bhello\b)\w+

pf()
# Executed in almost 0 second(s) in Ring 1.22
