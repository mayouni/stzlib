# Narrative
# --------
# The (/) and (+) operators on a stzString -- with the same Q() elevator
# rule as lists.
#
# `Q("ABCDEFGHI") / 3` splits into 3 equal parts and returns a raw list;
# wrapping the divisor as Q(3) elevates the result to a chainable stzList
# (so .StzType() is "stzlist" and .Lowercased() works on it). Likewise
# `Q("ABC") + "D"` concatenates to a raw string, while `+ Q("D")` returns
# a chainable stzString.
#
# Extracted from stzlisttest.ring, block #418.

load "../../stzBase.ring"

pr()

? Q("ABCDEFGHI") / 3
#--> [ "ABC", "DEF", "GHI" ]

? ( Q("ABCDEFGHI") / Q(3) ).StzType() + NL
#--> stzlist

? ( Q("ABCDEFGHI") / Q(3) ).Lowercased()
#--> [ "abc", "def", "ghi" ]

? Q("ABC") + "D"
#--> "ABCD"

? ( Q("ABC") + Q("D") ).Lowercased()
#--> "abcd"

pf()
# Executed in 0.05 second(s)
