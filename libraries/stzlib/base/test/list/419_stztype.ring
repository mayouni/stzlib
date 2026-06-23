# Narrative
# --------
# The (*) operator on a stzString: repeat with a NUMBER, join with a
# STRING.
#
# `Q("ABC") * 3` repeats the string three times. `Q("ABC") * " -> "` uses
# the operand as a SEPARATOR placed after each character, giving
# "A -> B -> C -> ". As everywhere, a raw operand returns a raw string and
# a Q()-wrapped operand returns a chainable stzString (so .StzType() is
# "stzstring" and .Lowercased() chains).
#
# Extracted from stzlisttest.ring, block #419.

load "../../stzBase.ring"

pr()

? Q("ABC") * 3
#--> "ABCABCABC"

? ( Q("ABC") * Q(3) ).StzType() + NL
#--> stzstring

? ( Q("ABC") * Q(3) ).Lowercased()
#--> "abcabcabc"

? Q("ABC") * " -> "
#--> "A -> B -> C -> "

? ( Q("ABC") * Q(" -> ") ).Lowercased()
#--> "a -> b -> c -> "

pf()
# Executed in 0.02 second(s)
