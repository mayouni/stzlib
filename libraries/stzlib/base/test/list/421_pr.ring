# Narrative
# --------
# pr()
#
# Extracted from stzlisttest.ring, block #421.
#ERR Error (R13) : Object is required

load "../../stzBase.ring"

pr()

? Q("A**BC***DE***") - 3	# Remove the last 3 chars
#--> "A**BC***DE"

? Q("A**BC***DE***") - "*"
#--> ABCDE

? ( Q("A**BC***DE***") - Q("*") ).StzType() + NL
#--> stzstring

? ( Q("A**BC***DE***") - Q("*")  ).Lowercased()
#--> abcde

pf()
# Executed in 0.02 second(s).
