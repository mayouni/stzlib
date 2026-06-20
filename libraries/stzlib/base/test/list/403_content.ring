# Narrative
# --------
# MultiplyBy with a LIST: pair every item with that list.
#
# MultiplyBy is polymorphic on its argument's type. Given a list, it does
# NOT repeat -- it pairs each item with the whole argument list, producing
# [ item, [argument] ] entries. (With a number it repeats the list; with a
# string it appends that string to each string item.) Mutates in place.
#
# Extracted from stzlisttest.ring, block #403.

load "../../stzBase.ring"

pr()

o1 = new stzList([ "VALUE1", "VALUE2", "VALUE3" ])
o1.MultiplyBy([ 1001, 1002, 1003 ])
? @@SP( o1.Content() )
#--> [
#	[  "VALUE1", [ 1001, 1002, 1003 ] ],
#	[  "VALUE2", [ 1001, 1002, 1003 ] ],
#	[  "VALUE3", [ 1001, 1002, 1003 ] ]
# ]

pf()
# Executed in almost 0 second(s)
