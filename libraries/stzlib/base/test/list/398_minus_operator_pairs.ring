# Narrative
# --------
# The "-" operator on a stzList removes matching items and returns the trimmed list.
#
# Softanza overloads "-" for list subtraction. Subtracting the pair "A":"B"
# strips that single pair element, leaving the remaining flat items. Subtracting
# These([ "X", "Y", "Z" ]) removes every listed value at once, so the result
# keeps 1, the surviving pair (shown as [ "A", "B" ] under @@()), 2 and 3.
# These(...) is the idiomatic way to pass a batch of values to remove, and @@()
# renders the nested-pair structure in readable bracket form.
#
# Extracted from stzlisttest.ring, block #398.

load "../../stzBase.ring"

pr()

o1 = new stzList([ 1, "A":"B", 2, 3, "X", "Y", "Z" ])

? o1 - "A":"B"
#--> [ 1, 2, 3, "X", "Y", "Z" ]

? @@( o1 - These([ "X", "Y", "Z" ]) )
#--> [ 1, [ "A", "B" ], 2, 3 ]

pf()
# Executed in almost 0 second(s).
