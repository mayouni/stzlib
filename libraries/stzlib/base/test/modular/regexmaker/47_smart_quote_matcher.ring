# Narrative
# --------
# Smart Quote Matcher
#
# Extracted from stzregexmakertest.ring, block #47.

load "../../../stzBase.ring"


pr()

o1 = new stzRegexMaker

o1.SetCase(:insensitive)
o1.AddCapturingGroup("quote", '[""].*?[""]')
o1.AddComment("Matches smart quotes and content")

? o1.Pattern()
#--> (?i)(?P<quote>[""].*?[""])(?#Matches smart quotes and content)

pf()
