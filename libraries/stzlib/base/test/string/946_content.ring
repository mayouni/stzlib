# Narrative
# --------
# pr()
#
# Extracted from stzStringTest.ring, block #946.
#ERR Error (R14) : Calling Method without definition: spacifycharsxt

load "../../stzBase.ring"

pr()

o1 = new stzString("SOFTANZA")
o1.SpacifyCharsXT("~", 3, :backward)
? o1.Content()
#--> SO~FTA~NZA

pf()
# Executed in almost 0 second(s) in Ring 1.24
# Executed in 0.01 second(s) in Ring 1.20
