# Narrative
# --------
# pr()
#
# Extracted from stzlistofnumberstest.ring, block #86.

load "../../../stzBase.ring"


# CLIPPING THE NUMBERS IN THE LIST
# Limits the values of the list by adjusting the numbers outside
# the provided range (nMin, nMax). Each number lesser then nMin
# becomes equal to nMin. And each number greater then nMax becomes
# equal to nMax.

o1 = new stzListOfNumbers(1:8)

o1.Clip(3, 5)
? @@( o1.Content() )
#--> [ 3, 3, 3, 4, 5, 5, 5, 5 ]

pf()
# Executed in 0.03 second(s)
