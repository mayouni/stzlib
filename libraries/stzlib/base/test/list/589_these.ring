# Narrative
# --------
# pr()
#
# Extracted from stzlisttest.ring, block #589.

load "../../stzBase.ring"

pr()

o1 = new stzList([ "poetry", "music", "theater", "stranger" ])
? o1 - These([ "poetry", "music" ])
#--> [ "theater", "stranger" ]
         
pf()
# Executed in almost 0 second(s).
