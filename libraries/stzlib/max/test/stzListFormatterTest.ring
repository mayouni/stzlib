load "../stzbase.ring"

/*---
*/
pr()

? @@( [ 1 , 2, [ "A" ], 3 ] )
#--> '[ 1, 2, [ "A" ], 3 ]'

? @@NL( ([ 1 , 2, [ "A" ], 3 ]) )
#--> [
#	1,
#	2,
#	[ "A" ],
#	3
# ]

pf()
# Executed in almost 0 second(s) in Ring 1.22

/*---

pr()

# Let us make a list with complex structure like this

 aList = [ 1, [ [ "name", "Ali" ], [ "age", 52 ], [ "job", "programmer" ] ], [ "a", [ [ "key1", "b" ], [ "key2", "c" ], [ [ "key31", "e" ], [ "key32", "f" ], "g"  ], "h" ], "d" ], 2, 3 ]

# Printing the list in the console makes it difficult to obtain a readable
# representation because the output is displayed vertically, with all items
# listed sequentially and no visual indication of their nested levels:

? aList
#-->
# 1
# name
# Ali
# age
# 52
# job
# programmer
# a
# key1
# b
# key2
# c
# key31
# e
# key32
# f
# g
# h
# d
# 2
# 3

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

# Alternatively, Softanza's @@NL() function provides an intelligent
# balance by qualifying inner list complexity and applying
# indentation selectively and only when required:

? @@NL(aList)
#--> '[
#	1,
#	[
#		[ "name", "Ali" ],
#		[ "age", 52 ],
#		[ "job", "programmer" ]
#	],
#	[
#		"a",
#		[
#			[ "key1", "b" ],
#			[ "key2", "c" ],
#			[
#				[ "key31", "e" ],
#				[ "key32", "f" ],
#				"g"
#			],
#			"h"
#		],
#		"d"
#	],
#	2,
#	3
# ]'

#NOTE: Softanza @@NL() is also more performant on large list then Ring list2code()

pf()
# Executed in almost 0 second(s) in Ring 1.22

/*----

pr()

? @@(5)
#--> 5

? @@("Ring")
#--> "Ring"

? @@([ 1, 2, 3 ])
#--> '[ 1, 2, 3 ]'

? @@([ 1, 2, "Ring", "A":"C", 3 ])
#--> '[ 1, 2, "Ring", [ "A", "B", "C" ], 3 ]'

pf()
# Executed in almost 0 second(s) in Ring 1.22

/*---

pr()

? @@SF("ABCDEFGHIJKLMNOPQRSTUVWXYZ") # SF for Short Form
#--> 'ABC...XYZ'

? @@SF(1:12)
#--> '[ 1, 2, 3, "...", 10, 11, 12 ]'

? @@SFXT(1:12, 4)
#--> '[ 1, 2, 3, 4, "...", 9, 10, 11, 12 ]'

? @@SFXT("ABCDEFGHIJKLMNOPQRSTUVWXYZ", [ 2, 5 ])
#--> 'AB...VWXYZ'

? @@SFXT(1:12, [ 2, 3 ])
#--> '[ 1, 2, "...", 10, 11, 12 ]'

pf()
# Executed in almost 0 second(s) in Ring 1.22

/*---

pr()

# The fellowing list, made of 8 items, is not shortened by default:

? @@SF(1:8)
#--> '[ 1, 2, 3, 4, 5, 6, 7, 8 ]'

# That's because Softanza thinks this is not needed. It sets the
# minial size required to 10 items, and you can check it using:

? MinSF() # Minimum size of a list to be shortened
#--> 10

# Of course, you can set this at your will, just use:

SetMinSF(8) # List with 8 (and +) items are now shortened

# Let's check it:

? @@SF(1:8)
#--> [ 1, 2, 3, "...", 6, 7, 8 ]

pf()
# Executed in almost 0 second(s) in Ring 1.22

/*----

pr()

? @@([ 1:3, 4:6, 7:9 ]) + NL
#--> [ [ 1, 2, 3 ], [ 4, 5, 6 ], [ 7, 8, 9 ] ]

? @@NL([ 1:3, 4:6, 7:9 ]) + NL
#--> [
#	[ 1, 2, 3 ],
#	[ 4, 5, 6 ],
#	[ 7, 8, 9 ]
# ]

? @@XT([ 1:3, 4:6, 7:9 ], NL, TAB) + NL
#--> [
#	[ 1, 2, 3 ],
#	[ 4, 5, 6 ],
#	[ 7, 8, 9 ]
# ]

# Useful if you want to display an indented commented list

? "# " + @@XT([ 1:3, 4:6, 7:9 ], NL, "#" + TAB)
#--> '# [
#	[ 1, 2, 3 ],
#	[ 4, 5, 6 ],
#	[ 7, 8, 9 ]
# ]'

pf()
# Executed in almost 0 second(s) in Ring 1.22

/*====

pr()

? MinValueForComputableShortFormXT() # Or MinSF()
#--> 10

SetValueForComputableShortFormXT(12) # Or SetMinSF()

? MinValueForComputableShortFormXT() # Or MinSF()
#--> 12

pf()
# Executed in almost 0 second(s).

/*----

pr()

? Show(5) # Or ComputableForm(pValue) or @Show(pValue)
#--> 5

? Show("Ring")
#--> "Ring"

? Show([ 1, 2, 3 ])
#--> '[ 1, 2, 3 ]'

? Show([ 1, 2, "Ring", "A":"C", 3 ])
#--> [ 1, 2, "Ring", [ "A", "B", "C" ], 3 ]

pf()
# Executed in almost 0 second(s).

/*----

pr()

? ShowShort(1:8) # Or @@SF(paList) or @@S(paList) or ShortForm(paList)
#--> [ 1, 2, 3, 4, 5, 6, 7, 8 ]

SetMinShortForm(8) # Or SetMinSF(8)

? ComputableShortForm(1:8)
#--> [ 1, 2, 3, "...", 6, 7, 8 ]

pf()
# Executed in almost 0 second(s).

/*----

pr()

? ShowShort("A":"Z")
#--> [ "A", "B", "C", "...", "X", "Y", "Z" ]

? @@SN("A":"Z", 2) # Or @@SXT(paList, n)
#--> [ "A", "B", "...", "Y", "Z" ]

? ShowShortN("A":"Z", 2)
#--> [ "A", "B", "...", "Y", "Z" ]

? ComputableShortFormXT("A":"Z", 2) # OrShowShortXT(paList, p)
#--> [ "A", "B", "...", "Y", "Z" ]

pf()
# Executed in almost 0 second(s).

/*------

pr()

? ComputableForm([ 1:3, 4:6, 7:9 ]) + NL # OR CF() or @@()
#--> [ [ 1, 2, 3 ], [ 4, 5, 6 ], [ 7, 8, 9 ] ]

? ComputableFormNL([ 1:3, 4:6, 7:9 ])  + NL # Or @@NL() or @@SP()
#--> [
#	[ 1, 2, 3 ],
#	[ 4, 5, 6 ],
#	[ 7, 8, 9 ]
# ]

? ComputableFormXT([ 1:3, 4:6, 7:9 ], NL, TAB)
#--> [
#	[ 1, 2, 3 ],
#	[ 4, 5, 6 ],
#	[ 7, 8, 9 ]
# ]

pf()
# Executed in almost 0 second(s).
