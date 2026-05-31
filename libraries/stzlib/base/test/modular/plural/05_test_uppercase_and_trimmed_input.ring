# Narrative
# --------
# Test uppercase and trimmed input
#
# Extracted from stzpluraltest.ring, block #5.

load "../../../stzBase.ring"


pr()

? Plural("CAT")         #--> cats
? Plural("  dog  ")     #--> dogs

pf()
# Executed in 0.14 second(s) in Ring 1.22
