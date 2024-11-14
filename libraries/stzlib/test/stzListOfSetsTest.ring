load "../max/stzmax.ring"

/*---

pron()

o1 = new stzListOfSets([
	[ "a", "b", "c" ],
	[ "a", "b", "x", "c", "z" ],
	[ "a", "t", "c", "v" ]
])

? @@( o1.Intersection() )
#--> [ "a", "c" ]

proff()
# Executed in 0.03 second(s) in Ring 1.21

/*---
*/
pron()

o1 = new stzSet([ "a", "b", "b", "c", "c" ])
? o1.IntersectionWith([ "a", "t", "c", "v" ])
#--> [ "a", "c" ]

? o1.UniqueItems()
#--> [ "a", "b", "c" ]

proff()
# Executed in 0.03 second(s) in Ring 1.21


	
