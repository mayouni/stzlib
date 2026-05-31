# Narrative
# --------
# pr()
#
# Extracted from stzbaturalcodetest.ring, block #9.

load "../../../stzBase.ring"


# Two misspelled forms of InLowercase()

? Q("ring").IsAQ(:String).InLowarcase() #--> TRUE
? Q("ring").IsAQ(:String).InLowercase() #--> TRUE

pf()
# Executed in 0.03 second(s) in Ring 1.23
