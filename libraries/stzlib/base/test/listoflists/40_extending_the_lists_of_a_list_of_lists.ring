# Narrative
# --------
# EXTENDING THE LISTS OF A LIST OF LISTS
#
# Extracted from stzlistofliststest.ring, block #40.

load "../../stzBase.ring"


pr()

o1 = new stzListOfLists([ # or stzLists()
	[ "A", "B" ],
	[ "C", "D", "E", "F"],
	[ "I" ]
])
 
? o1.IsHomolog() # or o1.IsHomologuous() or o1.ListsHaveSameSize()
#--> FALSE

? o1.SizeOfLargestList()
#--> 4

o1.Extend()

? @@( o1.Content() )
#--> [
#	[ "A", "B",  "",  "" ],
#	[ "C", "D", "E", "F" ],
#	[ "I",  "",  "",  "" ]
# ]

? o1.IsHomolog()
#--> TRUE

pf()
# Executed in 0.07 second(s)
