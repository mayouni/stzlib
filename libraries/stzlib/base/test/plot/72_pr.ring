# Narrative
# --------
# pr()
#
# Extracted from stzPlotTest.ring, block #72.

load "../../stzBase.ring"
load "../_expect.ring"

pr()

str = "    ╰┬──┬─────┬──────┬─────┬───────┬►     "
? @trimEnd(str)
Same(@trimEnd(str), "    ╰┬──┬─────┬──────┬─────┬───────┬►")
#--> "    ╰┬──┬─────┬──────┬─────┬───────┬►"

pf()
# Executed in almost 0 second(s) in Ring 1.23
