# Narrative
# --------
# Test category-based queries
#
# Extracted from stzsingulartest.ring, block #8.

load "../../stzBase.ring"

pr()

? len(GetSingularRulesByCategory("irregular"))  #--> 8
? len(GetSingularRulesByCategory("morphology")) #--> 8

pf()
# Executed in almost 0 second(s) in Ring 1.22
