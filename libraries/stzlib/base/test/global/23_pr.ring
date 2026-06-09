# Narrative
# --------
# pr()
#
# Extracted from stzGlobalTest.ring, block #23.
#ERR Error (C22) : Function redefinition, function is already defined!

load "../../stzBase.ring"

pr()

? @@("n")	#--> "n"
? @@('n')	#--> "n"
? @@("'n'")	#--> "'n'"
? @@('"n"')	#--> '"n"'

pf()
#--> Executed in 0.02 second(s)
