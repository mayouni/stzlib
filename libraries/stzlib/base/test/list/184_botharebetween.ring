# Narrative
# --------
# pr()
#
# Extracted from stzlisttest.ring, block #184.

load "../../stzBase.ring"

pr()

o1 = new stzList([ 14, 10, 14, 14, 20 ])

? QRT([2, 4], :stzPairOfNumbers).BothAreBetween(1, o1.NumberOfItems())
#--> TRUE

? QRT([0, 4], :stzPairOfNumbers).BothAreBetween(1, o1.NumberOfItems())
#--> FALSE

pf()
# Executed in 0.05 second(s)
