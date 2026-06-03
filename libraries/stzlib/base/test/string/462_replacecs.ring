# Narrative
# --------
# pr()
#
# Extracted from stzStringTest.ring, block #462.

load "../../stzBase.ring"

pr()

? @ReplaceCS("ruby RING python", "ring", "julia", TRUE)
#--> ruby RING python

? @ReplaceCS("ruby RING python", "ring", "julia", FALSE)
#--> ruby julia python

pf()
# Executed in almost 0 second(s) in Ring 1.22
