load "../stzmax.ring"

/*------

pr()

o1 = new stzListOfLists([
	[ 3, 6 ],
	[ 2, 1, 3 ],
	[ 2 ]
])

? @@NL( o1.AdjustedXT(3, 0) )
#--> [
#	[ 3, 6, 0 ],
#	[ 2, 1, 3 ],
#	[ 2, 0, 0 ]
# ]

pf()
# Executed in 0.02 second(s) in Ring 1.22

/*------
*/
ProfilerOn()

o1 = stzListOfListsOfNumbersQ([
	[ 3, 6, 3 ],
	[ 2, 1, 3 ],
	[ 2, 0, 1 ]
])

? o1.AddOneToOne()
#--> [ 7, 7, 7 ]

ProfilerOff()
