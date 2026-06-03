# Narrative
# --------
# pr()
#
# Extracted from stzStringTest.ring, block #157.

load "../../stzBase.ring"

pr()

o1 = new stzString("*4*34")

? o1.NumberOfDuplicates()
#--> 2

? @@( o1.Duplicates() )
#--> [ "*", "4" ]

pf()
# Executed in 0.17 second(s)
