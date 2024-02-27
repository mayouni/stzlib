//load "stzlib.ring"


/*====

pron()

? Q(1:7) - These(3:5) # Or AllThese() or EachIn()
#--> [ 1, 2, 6, 7 ]

? Q(1:7) - These(3:5)
proff()

/*---

pron()

? Intersection([
	[ "A", "A", "X", "B", "C" ],
	[ "B", "A", "C", "B", "A", "X" ],
	[ "C", "X", "Z", "A" ]
])
#--> [ "A", "X", "C" ]

proff()
# Executed in 0.04 second(s)

/*----

pron()

	a1 = [ "A", "A", "B", "C" ]
	a2 = [ "B", "A", "C", "B", "A", "X" ]

	o1 = new stzListOfLists([ a1, a2 ])
	? @@( o1.IndexBy(:Position) )

proff()
