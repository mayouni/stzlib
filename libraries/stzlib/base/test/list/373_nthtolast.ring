# Narrative
# --------
# Reaching into a list from its tail end with NthToLast(n).
#
# Where Nth(n) counts forward from the head, NthToLast(n) counts
# backward from the tail: the run shows NthToLast(2) on the 8-item
# list [S,O,F,T,A,N,Z,A] returning "N". This is the Softanza idiom
# for end-relative access without first computing len() and doing the
# (len - n + 1) arithmetic by hand -- the method does the reverse
# mapping for you, keeping intent ("the 2nd one back") explicit.
#
# Extracted from stzlisttest.ring, block #373.

load "../../stzBase.ring"

pr()

o1 = new stzList([ "S", "O", "F", "T", "A", "N", "Z", "A" ])
? o1.NthToLast(2)
#--> "N"

pf()
# Executed in almost 0 second(s).
