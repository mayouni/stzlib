# Narrative
# --------
# pr()
#
# Extracted from stzStringTest.ring, block #653.
#ERR Error (R3) : Calling Function without definition: tq

load "../../stzBase.ring"

pr()

# Here we take an example of a greek word

? TQ("Σίσυφος").Script()
#--> greek

? Q("Σίσυφος").StringCase()
#--> capitalcase

? Q("ΣΊΣΥΦΟΣ").StringCase()
#--> uppercase

? Q("ΣΊΣΥΦΟΣ").Lowercased()
#--> σίσυφοσ

? Q("σίσυφοσ").Uppercased()
#--> ΣΊΣΥΦΟΣ

? Q("σίσυφοσ").Capitalcased()
#--> Σίσυφοσ

? Q("σίσυφοσ").IsEqualToCS("ΣΊΣΥΦΟΣ", :CS = FALSE)
#--> TRUE

? Q("σίσυφοσ").IsEqualToCS("ΣΊΣΥΦΟΣ", TRUE)
#--> FALSE

pf()
# Executed in 0.12 second(s) in Ring 1.22
# Executed in 0.11 second(s) in Ring 1.18
# Executed in 0.21 second(s) in Ring 1.17
