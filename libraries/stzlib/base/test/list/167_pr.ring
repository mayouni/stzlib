# Narrative
# --------
# pr()
#
# Extracted from stzlisttest.ring, block #167.

load "../../stzBase.ring"


o1 = new stzList([
	"*", "*4", "*4*", "*4*3", "*4*34",
	"4", "4*", "4*3", "4*34", "*", "*3",
	"*34", "3", "34", "4"
])

? o1.NumberOfDuplicates()
#--> 2

? @@( o1.FindDuplicates() )
#--> [ 10, 15 ]

? @@( o1.Duplicates() )
#--> [ "*", 4 ]

? @@( o1.DuplicatesZ() )
#--> [ "*" = 10, "4" = 15 ]

pf()
# Executed in 0.90 second(s)
