# Narrative
# --------
# pr()
#
# Extracted from stzchartest.ring, block #39.
#ERR Error (C22) : Function redefinition, function is already defined!

load "../../stzBase.ring"

pr()

? FirstCharOf("Sinus") #--> S
? LastCharOf("Sinus") #--> s

? FirstLetterOf("Sinus") #--> S
? FirstLetterOf("***Sinus") #--> S

? LastLetterOf("Sinus") #--> s
? LastLetterOf("Sinus***") #--> s

pf()
# Executed in 0.03 second(s) in Ring 1.23
