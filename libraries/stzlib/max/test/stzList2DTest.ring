load "../max/stzmax.ring"

/*---

pr()

o1 = new stzList2D([
	[ "A", "B", "C" ],
	[  10,  20,  30 ]
])

? @@NL( o1.Content() )
#--> [
#	[ "A", "B", "C" ],
#	[ 10, 20, 30 ]
# ]

pf()
# Executed in 0.03 second(s) in Ring 1.22

/*---

pr()

o1 = new stzList2D([
	[ "A", "B" ],
	[  10,  20,  30 ]
])

#--> ERROR: Can't create the stz2DList object! All the lists must have same size.
