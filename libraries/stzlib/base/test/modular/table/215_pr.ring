# Narrative
# --------
# pr()
#
# Extracted from stztabletest.ring, block #215.

load "../../../stzBase.ring"


? IsNumberInString("08/27/2015")
#--> FALSE

? rx(pat(:number)).match("08/27/2015")
#--> FALSE

pf()
# Executed in almost 0 second(s) in Ring 1.22
