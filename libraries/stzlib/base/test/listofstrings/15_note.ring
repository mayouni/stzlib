# Narrative
# --------
# /* NOTE :
#
# Extracted from stzlistofstringstest.ring, block #15.
#ERR Error (C8) : Parentheses ')' is missing

load "../../stzBase.ring"

pr()

	- RemoveNthItem(n) : Remove item at position n

	- RemoveNthXT(n, pItem) : Remove nth occurrence of pItem
  	  (you can also use RemoveNthOccurrence(n, pItem)

	- RemoveThisNthItem(n, pItem) : remove nth item only if it
	  is equal to pItem
*/
/*
StartProfiler()

o1 = new stzListOfStrings([ "_", "A", "B", "C", "_", "D", "E", "_" ])

o1.RemoveFirstItem()
? @@( o1.Content() )
#--> [ "A", "B", "C", "_", "D", "E", "_" ]

o1.RemoveThisNthItem(1, "A")
? @@( o1.Content() )
#--> [ "B", "C", "_", "D", "E", "_" ]

o1.RemoveNth(2, "_")
? @@( o1.Content() )
#--> [ "B", "C", "_", "D", "E" ]

o1.RemoveFirstXT("_")
? @@( o1.Content() )
#--> [ "B", "C", "D", "E" ]

o1.RemoveThisFirstItemCS("b", :CS = FALSE)
? @@( o1.Content() )
#--> [ "C", "D", "E" ]

o1.RemoveNthItem(:Last) # ChekParams() should be turned ON for :Last to be recognised
			# Otherwise, use o1.RemoveNthItem(o1.NumberOfItems())
? @@( o1.Content() )
#--> [ "C", "D" ]

StopProfiler()
#--> Executed in 0.07 second(s)

pf()
