# Narrative
# --------
# pr()
#
# Extracted from stzlisttest.ring, block #419.
#ERR Error (R13) : Object is required

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
# Executed in 0.02 second(s).
