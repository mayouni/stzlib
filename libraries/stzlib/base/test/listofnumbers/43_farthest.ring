# Narrative
# --------
# pr()
#
# Extracted from stzlistofnumberstest.ring, block #43.
#ERR Error (R14) : Calling Method without definition: tosetq

load "../../stzBase.ring"

pr()

o1 = new stzListOfNumbers([ 4, 8, 10, 16, 18 ])

? o1.Farthest(88)
#--> 4

? o1.Farthest(17) 
#--> 4

? o1.FarthestTo(10)
#--> 18

? o1.Farthest( :To = 12 )
#--> 4

? o1.Farthest(2)
#--> 18

? o1.Farthest(1)
#--> 18

pf()
# Executed in 0.13 second(s)
