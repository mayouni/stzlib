# Narrative
# --------
# pr()
#
# Extracted from stzlistofnumberstest.ring, block #42.

load "../../stzBase.ring"

pr()

o1 = new stzListOfNumbers([ 2, 7, 18, 18, 10, 12, 25, 4 ])

? o1.Nearest(88)
#--> 25

? o1.Nearst(17) #NOTE this is a misspelled form of Nearest()
#--> 18

? o1.NearestTo(10)
#--> 12

? o1.Nearest( :To = 12 )
#--> 10

? o1.Nearest(2)
#--> 4

? o1.Nearest(1)
#--> 2

pf()
# Executed in 0.18 second(s)
