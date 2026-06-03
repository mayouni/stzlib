# Narrative
# --------
# Test edge cases
#
# Extracted from stzpluraltest.ring, block #6.

load "../../stzBase.ring"


pr()

? Plural("xyz")         #--> xyzs
? Plural("b")           #--> bs
? Plural("")            #--> s

pf()
# Executed in 0.14 second(s) in Ring 1.22
