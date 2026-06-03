# Narrative
# --------
# o1 = new stzListOfStrings(["12-120-0", "100-10-76", "87-458-20"])
#
# Extracted from stzlistofstringstest.ring, block #111.

load "../../stzBase.ring"

pr()

o1.ReplaceSubString("-", :With = "_")
? o1.Content()
#--> [ "12_120_0", "100_10_76", "87_458_20" ]

pf()
