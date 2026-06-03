# Narrative
# --------
# pr()
#
# Extracted from stzStringTest.ring, block #801.

load "../../stzBase.ring"


o1 = new stzString("ring language is nice language")

? o1.NLastCharsRemoved(9)
#--> ring language is nice

? o1.SectionQ(1,4).CharsReversed()
#--> ɹᴉnᵷ

pf()
# Executed in 0.06 second(s).
