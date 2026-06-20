# Narrative
# --------
# Removing items vs removing OBJECTS: the O()/Obj()/AsObject() elevator.
#
# This list holds a named list (oNamedList, rendered as "mylist" by @@).
# Three subtractions show the distinction:
#   - `o1 - [ "X","Y","Z" ]` removes that sublist by content (raw result).
#   - `o1 - oNamedList` (bare) tries to remove the object's CONTENT, which
#     isn't present as a plain item, so nothing is removed.
#   - `o1 - O(oNamedList)` removes the OBJECT ITSELF -- O() (alias Obj /
#     AsObject) says "treat the operand as the object, not its content".
# (Basmalah() just prints the U+FDFD ligature; v(:MyList) recalls the
# named list created with StzNamedListQ.)
#
# Extracted from stzlisttest.ring, block #423.

load "../../stzBase.ring"

pr()

? Basmalah() + NL
#o--> ﷽

oNamedList = StzNamedListQ(:MyList = [ "A", "B", "C" ])

o1 = new stzList([ 1, 2, 3, [ "X", "Y", "Z" ], 4, oNamedList, 5 ])

? @@( o1 - [ "X", "Y", "Z" ] ) + NL
#--> [ 1, 2, 3, 4, mylist, 5 ]
#		      |
#	The name list called mylist
# You can check it using the small function
	 ? v(:MyList).Content()
#	 #--> [ "A", "B", "C" ]

# NOTE: o1 initial content stays as is.

# Let's try to remove the oNamedList

? @@( ( o1 - oNamedList ).Content() ) + NL
#      \_______ _______/
#              V
#       A stzList object

#--> [ 1, 2, 3, [ "X", "Y", "Z" ], 4, mylist, 5 ]

# If you need to return the output in a normal list,
# use the Obj() small function like this:

? @@( o1 - O(oNamedList) ) # Or Obj() of AsObject()
#--> [ 1, 2, 3, [ "X", "Y", "Z" ], 4, 5 ]

pf()
# Executed in 0.05 second(s)
