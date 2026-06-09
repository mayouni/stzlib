# Narrative
# --------
# pr()
#
# Extracted from stzGlobalTest.ring, block #11.
#ERR Error (C22) : Function redefinition, function is already defined!

load "../../stzBase.ring"

pr()

for i = 1 to 1_000
	cCode = "str = ''+ i + ' '"
	eval(cCode)
next
# Executed in 0.88 second(s)

pf()
