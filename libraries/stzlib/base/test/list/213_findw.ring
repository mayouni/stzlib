# Narrative
# --------
# Finds the positions in a list where a boolean predicate holds, using
# the W ("where") family of conditional searches on stzList.
#
# FindW evaluates a code-string condition against EVERY position. The
# predicate ' NOT isNumber(This[@i + 1]) ' selects every position whose
# NEXT neighbour is not a number: in [1,2,"*",4,5,6,"*",8,9] that is
# position 2 (next is "*"), position 6 (next is "*"), and position 9 --
# whose successor This[10] is out of range and so reads as non-numeric,
# so the trailing index is matched too.
#
# FindWXT is the EXTENDED variant: it understands the expressive cursor
# tokens like @NextItem and the Q(...).Method() predicate form. Here
# ' Q(@NextItem).IsNotANumber() ' is transpiled to the same basic
# This[@i + 1] navigation and lowered to engine DSL, then the scan is
# bounded to the "executable section" -- the range of positions where
# @NextItem actually exists. Because the last position has no successor,
# position 9 is excluded, so FindWXT returns [ 2, 6 ] (not [ 2, 6, 9 ]).
# This is the only difference between the two forms on this data.
#
# Extracted from stzlisttest.ring, block #213.

load "../../stzBase.ring"

pr()

o1 = new stzList([ 1, 2, "*", 4, 5, 6, "*", 8, 9 ])

? o1.FindW(' NOT isNumber(This[@i + 1]) ')      # scans all positions
#--> [ 2, 6, 9 ]

? o1.FindWXT(' Q(@NextItem).IsNotANumber() ')   # bounded to where @NextItem exists
#--> [ 2, 6 ]

# Narrated assertion: the @NextItem cursor resolves to the next item and
# the last position (no successor) is dropped, so the two forms differ
# only by that trailing index.

? StzListQ( o1.FindWXT(' Q(@NextItem).IsNotANumber() ') ).IsEqualTo([ 2, 6 ])
#--> TRUE

? StzListQ( o1.FindW(' NOT isNumber(This[@i + 1]) ') ).IsEqualTo([ 2, 6, 9 ])
#--> TRUE

pf()
# Executed in 0.14 second(s) in Ring 1.22
# Executed in 0.15 second(s) in Ring 1.21
# Executed in 0.59 second(s) in Ring 1.20
# Executed in 0.70 second(s) in Ring 1.17
