# Narrative
# --------
# Finds the positions in a list where a boolean predicate holds, using
# the W ("where") family of conditional searches on stzList.
#
# FindW evaluates a code-string condition against each position. The
# predicate ' NOT isNumber(This[@i + 1]) ' selects every position whose
# NEXT neighbour is not a number: in [1,2,"*",4,5,6,"*",8,9] that is
# position 2 (next is "*"), position 6 (next is "*"), and position 9 --
# whose successor This[10] is out of range and so reads as non-numeric,
# so the trailing index is matched too. FindWXT is the extended variant
# that exposes named cursors like @NextItem; here the @NextItem-based
# predicate matches nothing and returns the empty list, so the two forms
# are not equivalent on this data.
#
# Extracted from stzlisttest.ring, block #213.

load "../../stzBase.ring"

pr()

o1 = new stzList([ 1, 2, "*", 4, 5, 6, "*", 8, 9 ])

? o1.FindW(' NOT isNumber(This[@i + 1]) ')
#--> [ 2, 6, 9 ]
# Executed in 0.13 second(s)

? o1.FindWXT(' Q(@NextItem).IsNotANumber() ')
#--> [ ]

pf()
# Executed in 0.14 second(s) in Ring 1.22
# Executed in 0.15 second(s) in Ring 1.21
# Executed in 0.59 second(s) in Ring 1.20
# Executed in 0.70 second(s) in Ring 1.17
