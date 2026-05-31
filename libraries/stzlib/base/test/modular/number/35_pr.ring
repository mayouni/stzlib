# Narrative
# --------
# pr()
#
# Extracted from stznumbertest.ring, block #35.

load "../../../stzBase.ring"


o1 = new stzNumber(11)
? o1.RepeatedNTimes(3)
#--> [11, 11, 11]

# Don't confuse with:
? o1.Times(3)
#--> 33

? o1.Times([2, 3])
#--> 66

pf()
# Executed in 0.09 second(s) in Ring 1.19
# Executed in 0.13 second(s) in Ring 1.17
