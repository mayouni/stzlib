# Narrative
# --------
# pr()
#
# Extracted from stzGlobalTest.ring, block #10.

load "../../stzBase.ring"

pr()

for i = 1 to 10_000
	cCode = "str = ''+ i + ' '"
	eval(cCode)
next
# Executed in 8.25 second(s)

pf()
