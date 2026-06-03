# Narrative
# --------
# Test irregular plurals
#
# Extracted from stzpluraltest.ring, block #3.

load "../../stzBase.ring"


pr()

? Plural("child")       #--> children
? Plural("man")         #--> men
? Plural("mouse")       #--> mice

pf()
# Executed in 0.02 second(s) in Ring 1.22
