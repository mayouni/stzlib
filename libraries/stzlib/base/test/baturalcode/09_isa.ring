# Narrative
# --------
# pr()
#
# Extracted from stzbaturalcodetest.ring, block #9.
#ERR Error (R13) : Object is required

load "../../stzBase.ring"

pr()

# Two misspelled forms of InLowercase()

? Q("ring").IsAQ(:String).InLowarcase() #--> TRUE
? Q("ring").IsAQ(:String).InLowercase() #--> TRUE

pf()
# Executed in 0.03 second(s) in Ring 1.23
