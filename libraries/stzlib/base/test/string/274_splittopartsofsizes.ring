# Narrative
# --------
# pr()
#
# Extracted from stzStringTest.ring, block #274.

load "../../stzBase.ring"

pr()

o1 = new stzString("123456789")

? o1.SplitToPartsOfSizes([ 3, 4, 2 ])
#--> [ "123", "4567", "89" ]

# Or simply

? o1 / [ 3, 4, 2 ]
#--> #--> [ "123", "4567", "89" ]

pf()
# Executed in 0.01 second(s).
