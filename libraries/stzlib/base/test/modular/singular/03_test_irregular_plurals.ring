# Narrative
# --------
# Test irregular plurals
#
# Extracted from stzsingulartest.ring, block #3.

load "../../../stzBase.ring"


pr()

? Singular("children")   #--> child
? Singular("men")        #--> man
? Singular("mice")       #--> mouse

pf()
# Executed in 0.17 second(s) in Ring 1.22
