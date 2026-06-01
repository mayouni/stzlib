# Narrative
# --------
# LOGICAL ERROR IN QT: Revist after fixing stzLocale
#
# Extracted from stzStringTest.ring, block #659.

load "../../../stzBase.ring"


pr()

? Q("DER FLUSS").LowercasedInLocale("de-DE")
#--> der fluss

? Q("der fluß").IsLowercaseOfXT("DER FLUSS", :InLocale = "de-DE")
#--> FALSE (but should be TRUE!)

pf()
# Executed in 0.05 second(s)
