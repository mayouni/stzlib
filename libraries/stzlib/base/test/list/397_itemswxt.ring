# Narrative
# --------
# ItemsW() selects every item satisfying a Softanza condition expression.
#
# Given a mixed list of strings and numbers, the W ("where") form takes a
# code-string predicate '{ not isNumber(@item) }' where @item is bound to
# each element in turn. Here it keeps only the non-numeric entries, so the
# four string items "A", "B", "C", "D" survive while the numbers 1..5 are
# dropped. The W-suffix is Softanza's compact, eval-free filtering idiom:
# the brace block is the condition, @item the per-element placeholder.
#
# Extracted from stzlisttest.ring, block #397.

load "../../stzBase.ring"

pr()

o1 = new stzList([ "A", "B", 1, "C", 2, 3, "D", 4, 5 ])
? o1.ItemsW('{ not isNumber(@item) }')
#--> [ "A", "B", "C", "D" ]

pf()
# Executed in 0.10 second(s).
