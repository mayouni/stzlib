load "../max/stzmax.ring"

/*---
*/
pr()

# Let us make a list with complex structure like this

 aList = [ 1, [ [ "name", "Ali" ], [ "age", 52 ], [ "job", "programmer" ] ], [ "a", [ [ "key1", "b" ], [ "key2", "c" ], [ [ "key31", "e" ], [ "key32", "f" ], "g"  ], "h" ], "d" ], 2, 3 ]

# Printing the list in the console makes it difficult to obtain a readable
# representation because the output is displayed vertically, with all items
# listed sequentially and no visual indication of their nested levels

//? aList
#-->
/*
1
name
Ali
age
52
job
programmer
a
key1
b
key2
c
key31
e
key32
f
g
h
d
2
3
*/

# Ring list2code() does a good job to solve this problem, let's see:

? list2code(aList)
#--> [
#	1,
#	[
#		[
#			"name",
#			"Ali"
#		],
#		[
#			"age",
#			52
#		],
#		[
#			"job",
#			"programmer"
#		]
#	],
#	[
#		"a",
#		[
#			[
#				"key1",
#				"b"
#			],
#			[
#				"key2",
#				"c"
#			],
#			[
#				[
#					"key31",
#					"e"
#				],
#				[
#					"key32",
#					"f"
#				],
#				"g"
#			],
#			"h"
#		],
#		"d"
#	],
#	2,
#	3
# ]'

# Still, Softanza's @@NL() function provides an intelligent
# balance by qualifying inner list complexity and applying
# indentation selectively

//? @@NL(aList)
#--> [
#	1,
#	[ [ "name", "Ali" ], [ "age", 52 ], [ "job", "programmer" ] ],
#	[
#		"a",
#		[
#			[ "key1", "b" ],
#			[ "key2", "c" ],
#			[ [ "key31", "e" ], [ "key32", "f" ], "g" ],
#			"h"
#		],
#		"d"
#	],
#	2,
#	3
# ]

proff()
# Executed in 0.01 second(s) in Ring 1.22

/*----

profon()

? @@(5)
#--> 5

? @@("Ring")
#--> "Ring"

? @@([ 1, 2, 3 ])
#--> '[ 1, 2, 3 ]'

? @@([ 1, 2, "Ring", "A":"C", 3 ])
#--> [ 1, 2, "Ring", [ "A", "B", "C" ], 3 ]

proff()
# Executed in almost 0 second(s).

/*---

profon()

? @@SF("ABCDEFGHIJKLMNOPQRSTUVWXYZ")
#--> ABC...XYZ

? @@SF(1:12)
#--> [ 1, 2, 3, "...", 10, 11, 12 ]

? @@SFXT("ABCDEFGHIJKLMNOPQRSTUVWXYZ", [ 2, 5 ])
#--> AB...VWXYZ

? @@SFXT(1:12, [ 2, 3 ])
#--> [ 1, 2, "...", 10, 11, 12 ]

proff()
# Executed in almost 0 second(s).

/*---

profon()

? @@SF(1:8)
#--> [ 1, 2, 3, 4, 5, 6, 7, 8 ]

? MinSF()
#--> 10

SetMinSF(8)

? @@SF(1:8)
#--> [ 1, 2, 3, "...", 6, 7, 8 ]

proff()
# Executed in almost 0 second(s).

/*----

profon()

? @@([ 1:3, 4:6, 7:9 ]) + NL
#--> [ [ 1, 2, 3 ], [ 4, 5, 6 ], [ 7, 8, 9 ] ]

? @@NL([ 1:3, 4:6, 7:9 ]) + NL
#--> [
#	[ 1, 2, 3 ],
#	[ 4, 5, 6 ],
#	[ 7, 8, 9 ]
# ]

? @@XT([ 1:3, 4:6, 7:9 ], NL, TAB)
#--> [
#	[ 1, 2, 3 ],
#	[ 4, 5, 6 ],
#	[ 7, 8, 9 ]
# ]

proff()
# Executed in almost 0 second(s).

/*====

profon()

? MinValueForComputableShortFormXT() # Or MinSF()
#--> 10

SetValueForComputableShortFormXT(12) # Or SetMinSF()

? MinValueForComputableShortFormXT() # Or MinSF()
#--> 12

proff()
# Executed in almost 0 second(s).

/*----

profon()

? Show(5) # Or ComputableForm(pValue) or @Show(pValue)
#--> 5

? Show("Ring")
#--> "Ring"

? Show([ 1, 2, 3 ])
#--> '[ 1, 2, 3 ]'

? Show([ 1, 2, "Ring", "A":"C", 3 ])
#--> [ 1, 2, "Ring", [ "A", "B", "C" ], 3 ]

proff()
# Executed in almost 0 second(s).

/*----

profon()

? ShowShort(1:8) # Or @@SF(paList) or @@S(paList) or ShortForm(paList)
#--> [ 1, 2, 3, 4, 5, 6, 7, 8 ]

SetMinShortForm(8) # Or SetMinSF(8)

? ComputableShortForm(1:8)
#--> [ 1, 2, 3, "...", 6, 7, 8 ]

proff()
# Executed in almost 0 second(s).

/*----

profon()

? ShowShort("A":"Z")
#--> [ "A", "B", "C", "...", "X", "Y", "Z" ]

? @@SN("A":"Z", 2) # Or @@SXT(paList, n)
#--> [ "A", "B", "...", "Y", "Z" ]

? ShowShortN("A":"Z", 2)
#--> [ "A", "B", "...", "Y", "Z" ]

? ComputableShortFormXT("A":"Z", 2) # OrShowShortXT(paList, p)
#--> [ "A", "B", "...", "Y", "Z" ]

proff()
# Executed in almost 0 second(s).

/*------
*/
profon()

? ComputableForm([ 1:3, 4:6, 7:9 ]) + NL # OR CF() or @@()
#--> [ [ 1, 2, 3 ], [ 4, 5, 6 ], [ 7, 8, 9 ] ]

? ComputableFormNL([ 1:3, 4:6, 7:9 ])  + NL # Or @@NL() or @@SP()
#--> [
#	[ 1, 2, 3 ],
#	[ 4, 5, 6 ],
#	[ 7, 8, 9 ]
# ]

? ComputableFormXT([ 1:3, 4:6, 7:9 ], NL, TAB) + NL
#--> [
#	[ 1, 2, 3 ],
#	[ 4, 5, 6 ],
#	[ 7, 8, 9 ]
# ]

proff()
# Executed in almost 0 second(s).
