# Narrative
# --------
# pr()
#
# Extracted from stzlisttest.ring, block #129.
#ERR Error (R14) : Calling Method without definition: noitemsareduplicated

load "../../stzBase.ring"

pr()

	o1 = new stzList([ "A", "B", "2", 1:3, "C", 2 ])
	? o1.NoItemsAreDuplicated()
	#--> TRUE

	o1 = new stzList("A":"E")
	? o1.NoItemsAreDuplicated()
	#--> TRUE

pf()
# Executed in almost 0 second(s) in Ring 1.21
# Executed in 0.03 second(s) in Ring 1.8
