# Narrative
# --------
# pr()
#
# Extracted from stzStringTest.ring, block #971.

load "../../stzBase.ring"


o1 = new stzString("ringringringring")

? o1.vizFind("ring") + NL
#-->
# ringringringring
# ^---^---^---^---

? o1.vizFindXT("ring", [ :Numbered = TRUE ])
#-->
# ringringringring
# ^---^---^---^---
# 1   5   9   13 

pf()
# Executed in 0.02 second(s).

pf()
