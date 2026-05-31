# Narrative
# --------
# pr()
#
# Extracted from stztabletest.ring, block #158.

load "../../../stzBase.ring"


o1 = new stzTable([
	:COL1 = [ "to", "be", "removed" ]
])
? o1.Show()
#-->   COL1
#   -------
#        to
#        be
#   removed

o1.RemoveCol(1)

? @@( o1.Content() )
#--> [ [ "col1", [ "" ] ] ]

? @@( o1.Cell(1, 1) )
#--> ""

? o1.NumberOfCells()
#--> 1

? @@( o1.Cells() )
#--> [ "" ]

? o1.IsEmpty()
#--> TRUE

o1.Show()
#--> COL1
#    ----
#    ""

pf()
# Executed in 0.10 second(s)
