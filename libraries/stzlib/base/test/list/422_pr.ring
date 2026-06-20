# Narrative
# --------
# pr()
#
# Extracted from stzlisttest.ring, block #422.
#ERR Error (R13) : Object is required

load "../../stzBase.ring"

pr()

? Q("ABCABCABC") / 3	# Remove the last 3 chars
#--> [ "ABC", "ABC", "ABC" ]

? Q("ABC-ABC-ABC") / "-"
#--> [ "ABC", "ABC", "ABC" ]

? ( Q("ABC-ABC-ABC") / Q("-") ).StzType() + NL
#--> stzlist

? ( Q("ABC-ABC-ABC") / Q("-")  ).Lowercased()
#--> [ "abc", "abc", "abc" ]

pf()
# Executed in 0.04 second(s).
