# Narrative
# --------
# pr()
#
# Extracted from stzStringTest.ring, block #945.

load "../../stzBase.ring"


o1 = new stzString("SOFTANZA")
o1.SpacifyCharsXT(:Separator = "~", :Step = 2, :Direction = :Default)
? o1.Content()
#--> SO~FT~AN~ZA

pf()
# Executed in 0.01 second(s) in Ring 1.24
# Executed in 0.01 second(s) in ring 1.20
