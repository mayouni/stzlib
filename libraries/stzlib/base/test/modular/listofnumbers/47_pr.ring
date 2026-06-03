# Narrative
# --------
# pr()
#
# Extracted from stzlistofnumberstest.ring, block #47.

load "../../../stzBase.ring"


o1 = new stzListOfNumbers([ 2, 4, 7, 10, 12, 15, 18, 25 ])

? o1.NearestToXT(12, :Coming = :BeforeIt)
#--> 2

? @@( o1.NearestToXT(12, :Coming = :AfterIt) )
#--> 25

? @@( o1.NearestXT( :To = 2, :Before) )
#-->NULL

? @@( o1.NearestToXT(17, :ComingAfterIt) )
#-->NULL

? @@( o1.NearestToXT(25, :ComingAfterIt) )
#-->NULL

pf()
# Executed in 0.30 second(s)
