# Narrative
# --------
# pr()
#
# Extracted from stzlisttest.ring, block #606.

load "../../stzBase.ring"

pr()

? AreEqual([ 1:3, 1:3, 1:3, 1:3 ])
#--> TRUE

? AreEqual([ ["A", 1:5], 1:3, 1:3, 1:3 ])
#--> FALSE

? AreEqual([ NullObject(), NullObject(), NullObject() ])
#--> TRUE

pf()
# Executed in 0.03 second(s) in Ring 1.22
