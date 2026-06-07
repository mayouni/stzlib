# Narrative
# --------
# pr()
#
# Extracted from stzStringTest.ring, block #704.
#ERR exit 1: Line 98 Bad parameters value, error in length!

load "../../stzBase.ring"

pr()

o1 = new stzString("__b和平س__a__و")
? o1.ToStzText().Scripts()
#--> [ "latin", "han", "arabic" ]

pf()
# Executed in 0.04 second(s).
