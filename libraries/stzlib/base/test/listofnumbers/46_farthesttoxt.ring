# Narrative
# --------
# pr()
#
# Extracted from stzlistofnumberstest.ring, block #46.
#ERR Error (R14) : Calling Method without definition: tosetq

load "../../stzBase.ring"

pr()

o1 = new stzListOfNumbers([ 2, 4, 7, 10, 12, 15, 18, 25 ])

? o1.FarthestToXT(12, :Coming = :BeforeIt)
#--> 2

? @@( o1.FarthestToXT(12, :Coming = :AfterIt) )
#--> 25

? @@( o1.FarthestXT( :To = 2, :Before) )
#-->NULL

? @@( o1.FarthestToXT(17, :ComingAfterIt) )
#-->NULL

? @@( o1.FarthestToXT(25, :ComingAfterIt) )
#-->NULL

pf()
# Executed in 0.30 second(s)
