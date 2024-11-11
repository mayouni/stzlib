load "../max/systems/stzShowSys.ring"
load "../max/systems/stzProfSys.ring"

/*----

pron()

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

pron()

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

pron()

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

pron()

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

pron()

? MinValueForComputableShortFormXT() # Or MinSF()
#--> 10

SetValueForComputableShortFormXT(12) # Or SetMinSF()

? MinValueForComputableShortFormXT() # Or MinSF()
#--> 12

proff()
# Executed in almost 0 second(s).

/*----

pron()

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

pron()

? ShowShort(1:8) # Or @@SF(paList) or @@S(paList) or ShortForm(paList)
#--> [ 1, 2, 3, 4, 5, 6, 7, 8 ]

SetMinShortForm(8) # Or SetMinSF(8)

? ComputableShortForm(1:8)
#--> [ 1, 2, 3, "...", 6, 7, 8 ]

proff()
# Executed in almost 0 second(s).

/*----

pron()

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
pron()

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
