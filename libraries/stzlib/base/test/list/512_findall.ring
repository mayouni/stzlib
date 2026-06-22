# Narrative
# --------
# FindAll() returns the list of ALL positions where a given item occurs.
#
# The list mixes numbers, a key:value pair, a NullObject(), and strings.
# FindAll() handles each kind uniformly: a scalar (10) yields [ 1, 5 ],
# a string ("Ring") yields [ 8 ], a pair ("A":"E") yields [ 2, 6 ], and
# even a repeated object reference (obj) is found at [ 4, 7 ]. Objects are
# findable because Softanza tracks them as named objects rather than the
# old approach of relying on the empty slots produced by Ring's list2code().
# RemoveMany() then deletes every occurrence of the pair and the object,
# collapsing the list to [ 10, 12, 10, "Ring" ].
#
# Extracted from stzlisttest.ring, block #512.

load "../../stzBase.ring"

pr()

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
