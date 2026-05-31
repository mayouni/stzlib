# Narrative
# --------
# pr()
#
# Extracted from stzGlobalTest.ring, block #11.

load "../../../stzBase.ring"


for i = 1 to 1_000
	cCode = "str = ''+ i + ' '"
	eval(cCode)
next
# Executed in 0.88 second(s)

pf()
