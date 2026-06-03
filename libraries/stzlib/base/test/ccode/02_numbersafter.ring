# Narrative
# --------
# pr()
#
# Extracted from stzccodetest.ring, block #2.

load "../../stzBase.ring"

pr()

? @@( Q("This[@i+1]").NumbersAfter("@i") )
#--> [ "1" ]

? @@( Q("@i-2@i+1]").NumbersAfter("@i") )
#--> [ "-2", "+1" ]

pf()
# Executed in 0.02 second(s) in Ring 1.22
