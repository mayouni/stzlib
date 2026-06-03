# Narrative
# --------
# pr()
#
# Extracted from stznumbertest.ring, block #34.

load "../../stzBase.ring"

pr()

o1 = new stzNumber(11)
o1.MultiplyBy(3)
#--> 33

#--

o1 = new stzNumber(11)
o1.MultiplyBy([ 3, 2 ])
? o1.Content()
#--> 66

pf()
# Executed in 0.16 second(s)
