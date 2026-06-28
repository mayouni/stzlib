# Narrative
# --------
# RemoveXT(sub, :AtPosition = n / :AtPositions = [...]): remove the sub at exact
# codepoint position(s) -- multibyte-correct (the heart is 1 char, not 3 bytes).
#
# Extracted from stzStringTest.ring, block #67.
#

load "../../stzBase.ring"

pr()

o1 = new stzString("ring ♥♥♥ruby php")
o1.RemoveXT("♥♥♥", :AtPosition = 6)
? o1.Content() #--> ring ruby php

pf()
