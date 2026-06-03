# Narrative
# --------
# pr()
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
# Executed in 0.05 second(s).
