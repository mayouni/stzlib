# Narrative
# --------
# pr()
#
# Extracted from stzStringTest.ring, block #809.
#ERR Error (R14) : Calling Method without definition: removesectionq

load "../../stzBase.ring"

pr()

o1 = new stzString("extrasection")
o1.RemoveSectionQ(6, :LastChar)
? o1.Content()
#--> extra

pf()
# Executed in 0.01 second(s).
