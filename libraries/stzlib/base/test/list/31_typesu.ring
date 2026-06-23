# Narrative
# --------
# Inspecting the TYPES present in a heterogeneous list.
#
# Softanza classifies every item by its Ring type ("NUMBER", "STRING",
# "LIST", "OBJECT"). Three views:
#   * TypesU()                -- the DISTINCT types present, in order of
#                                first appearance.
#   * ItemsAndTheirTypes()    -- each item paired with its type name.
#   * TypesAndTheirSections() -- per distinct type, the [start,end] position
#                                ranges of its maximal same-type runs
#                                (alias TypesZZ).
# @@XT(list, separator, prefix) is the extended computable-form printer: like
# @@NL but with a caller-chosen line separator and per-row prefix, so each
# top-level row prints compactly on its own indented line.
#
# Extracted from stzlisttest.ring, block #31.

load "../../stzBase.ring"

pr()

o1 = new stzList([
	1, 2, 3,
	"A", "B", "C",
	7, 8,
	1:3, 4:8, 9:12,
	"D", "E",
	4:8,
	11, 12,
	NullObject(),
	TrueObject(),
	FalseObject()
])

? o1.TypesU()
#--> [ "NUMBER", "STRING", "LIST", "OBJECT" ]

? @@XT( o1.ItemsAndTheirTypes(), NL, TAB )
#--> [
#	[ 1, "NUMBER" ],
#	[ 2, "NUMBER" ],
#	[ 3, "NUMBER" ],
#	[ "A", "STRING" ],
#	[ "B", "STRING" ],
#	[ "C", "STRING" ],
#	[ 7, "NUMBER" ],
#	[ 8, "NUMBER" ],
#	[ [ 1, 2, 3 ], "LIST" ],
#	[ [ 4, 5, 6, 7, 8 ], "LIST" ],
#	[ [ 9, 10, 11, 12 ], "LIST" ],
#	[ "D", "STRING" ],
#	[ "E", "STRING" ],
#	[ [ 4, 5, 6, 7, 8 ], "LIST" ],
#	[ 11, "NUMBER" ],
#	[ 12, "NUMBER" ],
#	[ @nullobject, "OBJECT" ],
#	[ @trueobject, "OBJECT" ],
#	[ @falseobject, "OBJECT" ]
#	]

? @@XT( o1.TypesAndTheirSections(), NL, TAB ) # same as TypesZZ()
#--> [
#	[ "NUMBER", [ [ 1, 3 ], [ 7, 8 ], [ 15, 16 ] ] ],
#	[ "STRING", [ [ 4, 6 ], [ 12, 13 ] ] ],
#	[ "LIST", [ [ 9, 11 ], [ 14, 14 ] ] ],
#	[ "OBJECT", [ [ 17, 19 ] ] ]
#	]

pf()
# Executed in 0.02 second(s)
