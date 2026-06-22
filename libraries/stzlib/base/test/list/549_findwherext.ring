# Narrative
# --------
# FindWhere with a neighbour cursor and with raw index math.
#
# FindWhere is a readable alias of FindW -- the single performant + expressive
# conditional-search form (the old WhereXT/WXT extended forms are retired). It
# returns the POSITIONS where the condition holds. The list mixes strings,
# numbers, TRUE/FALSE objects and sub-lists. Three scans:
#   1) items whose successor is "*"                    -> [ 5, 11 ]  (@NextItem
#      cursor; the engine auto-bounds to where a successor exists)
#   2) numbers whose 3rd-next item is their double     -> [ 2, 5 ]   (raw
#      This[@i+3] index math, self-guarded with an explicit @i range check)
#   3) numbers whose 3rd-next item is NOT their double -> [ 8 ]
#
# The predicate vocabulary is the engine W-DSL: @item, @NextItem, @i, the raw
# This[@i+k] index form, isNumber(), arithmetic (2 * @item). For richer Ring
# logic inside the predicate, use the WF family instead.
#
# Extracted from stzlisttest.ring, block #549.

load "../../stzBase.ring"

pr()

o1 = new stzList([
	"_", 3, "_" , TRUEObject(), 6, "*",
	[ "L1", "L1" ], 12, FALSEObject(),
	[ "L2", "L2" ], 25, "*"
])

? o1.FindWhere(' @NextItem = "*" ')
#--> [ 5, 11 ]

? o1.FindWhere('{
	isNumber(@item) and @i <= 9 and
	isNumber(This[@i+3]) and This[@i+3] = 2 * @item
}')
#--> [ 2, 5 ]

? o1.FindWhere('{
	isNumber(@item) and @i <= 9 and
	isNumber(This[@i+3]) and This[@i+3] != 2 * @item
}')
#--> [ 8 ]

pf()
# Executed in 0.35 second(s).
