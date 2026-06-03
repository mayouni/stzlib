# Narrative
# --------
# pr()
#
# Extracted from stzStringTest.ring, block #956.
#ERR Error (R14) : Calling Method without definition: spacifyq

load "../../stzBase.ring"

pr()

? Q("ABTCADNBBABEFACCC").SpacifyQ().vizFind("A")
#-->
# A B T C A D N B B A B E F A C C C
# ^-------^---------^-------^------   

pf()
# Executed in almost 0 second(s) in Ring 1.26
# Executed in 0.02 second(s) in Ring 1.22
