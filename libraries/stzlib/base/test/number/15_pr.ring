# Narrative
# --------
# pr()
#
# Extracted from stznumbertest.ring, block #15.

load "../../stzBase.ring"


o1 = new stzNumber(12)

o1 * Q(5)
? o1.NumericValue()
#--> 60

#--

o1 = new stzNumber(12)
o1 * Q(5 * 4 * 2)
? o1.NumericValue()
#--> 480

#--

o1 = new stzNumber(12)
o1 * Q([ 5, 4, 2 ])
? o1.NumericValue()
 #--> 480

pf()
# Executed in 0.75 second(s) in Ring 1.17
