# Narrative
# --------
# Named format configs
#
# Extracted from stzdatetimetest.ring, block #42.
#ERR Error (C22) : Function redefinition, function is already defined!

load "../../stzBase.ring"


pr()

oDateTime = StzDateTimeQ("2024-03-15 14:30:45")

? oDateTime.ToStringXT(:Standard)
#--> 2024-03-15 14:30:45

? oDateTime.ToStringXT(:European)
#--> 15/03/2024 14:30:45

? oDateTime.ToStringXT(:American)
#--> 03/15/2024 14:30:45

? oDateTime.ToStringXT(:ISO8601)
#--> 2024-03-15T14:30:45

? oDateTime.ToStringXT(:RFC2822) # Depends on your system locale language
#--> 15 Mar 2024 14:30:45

pf()
# # Executed in almost 0 second(s) in Ring 1.24
