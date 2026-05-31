# Narrative
# --------
# pr()
#
# Extracted from stzlisttest.ring, block #512.

load "../../../stzBase.ring"


obj = NullObject()

o1 = new stzList([ 10, "A":"E", 12, obj, 10, "A":"E", obj, "Ring" ])

? @@( o1.FindAll(10) )
#--> [ 1, 5 ]

? o1.FindAll("Ring")
#--> [ 8 ]

? o1.FindAll("A":"E")
#--> [ 2, 6 ]

? o1.FindAll(obj)
#--> [ 4, 7 ]

#TODO // this won't work corretcly if we add other objects different from
# obj in the list. We should think of an an algorithm other then relying
# on the empty spaces generated, for objects, by list2code() function of Ring!

	#UPDATE It's done, and object findability is now managed using named object.
	#~> If an object is named (created using new stzString(:mystr = "Ring") for
	# example, then it becomes findable!

o1.RemoveMany([ "A":"E", obj ])
? @@( o1.Content() )
#--> [ 10, 12, 10, "Ring" ]

pf()
# Executed in 0.08 second(s).
