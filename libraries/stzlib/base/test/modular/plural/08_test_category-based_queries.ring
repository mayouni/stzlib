# Narrative
# --------
# Test category-based queries
#
# Extracted from stzpluraltest.ring, block #8.

load "../../../stzBase.ring"

pr()

? len(GetPluralRulesByCategory("irregular"))  #--> 8
? len(GetPluralRulesByCategory("morphology")) #--> 9

pf()
# Executed in almost 0 second(s) in Ring 1.22
