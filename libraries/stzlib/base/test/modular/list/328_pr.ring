# Narrative
# --------
# pr()
#
# Extracted from stzlisttest.ring, block #328.

load "../../../stzBase.ring"


o1 = new stzList([ "_", "A", "B", "C", "_", "D", "E", "_" ])

o1.RemoveFirstItem()
? @@( o1.Content() )
#--> [ "A", "B", "C", "_", "D", "E", "_" ]

o1.RemoveThisNthItem(1, "A")
? @@( o1.Content() )
#--> [ "B", "C", "_", "D", "E", "_" ]

o1.RemoveNth(2, "_")
? @@( o1.Content() )
#--> [ "B", "C", "_", "D", "E" ]

o1.RemoveFirst("_")
? @@( o1.Content() )
#--> [ "B", "C", "D", "E" ]

o1.RemoveThisFirstItemCS("b", :CS = FALSE)
? @@( o1.Content() )
#--> [ "C", "D", "E" ]

o1.RemoveNthItem(:Last) # CheckParams() should be TRUE, otherwise :Last raises an error
			# You can use o1.RemoveNthItem(o1.NumberOfItems()) or
			# o1.RemoveLastItem() instead
? @@( o1.Content() )
#--> [ "C", "D" ]

pf()
# Executed in 0.02 second(s)
