# Narrative
# --------
# Validate monetary amounts
#
# Extracted from stzregexmakertest.ring, block #40.

load "../../../stzBase.ring"


pr()

o1 = new stzRegexLookAroundMaker
o1.MustBePrecededBy("\$").
   ThenMatch("\d+(\.\d{2})?")
? o1.Pattern()
#--> (?<=\$)\d+(\.\d{2})?

pf()
c
