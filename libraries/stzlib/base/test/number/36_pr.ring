# Narrative
# --------
# pr()
#
# Extracted from stznumbertest.ring, block #36.

load "../../stzBase.ring"


o1 = new stzNumber(11)
o1.MultiplyByMany([2, 3])
? o1.Value()
#--> 66

pf()
# Executed in 0.10 second(s) in Ring 1.19
# Executed in 0.12 second(s) in Ring 1.17
