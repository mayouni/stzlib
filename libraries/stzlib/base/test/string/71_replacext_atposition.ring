# Narrative
# --------
# ReplaceXT(sub, :AtPosition = n): replace the sub starting at char POSITION n
# (not the n-th occurrence).
#
# Extracted from stzStringTest.ring, block #71.
#

load "../../stzBase.ring"

pr()

o1 = new stzString("ruby ring php")
o1.ReplaceXT("ring", :AtPosition = 6, :By = "♥♥♥")
? o1.Content() #--> ruby ♥♥♥ php

pf()
