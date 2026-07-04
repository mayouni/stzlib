# Narrative
# --------
#
# NOTE (audit, 2026-07-04): DEFERRED -- stzLocale.Name() normalization ("ar-tn" -> ar_TN) -- stzLocale-domain; currently returns @noname. Goes with 650/664/839 to the locale pass.
# #qt
#
# Extracted from stzStringTest.ring, block #840.

load "../../stzBase.ring"


pr()

@oLocale = StzLocaleQ("ar-tn")
? @oLocale.Name()
#--> ar_TN

pf()
# Executed in almost 0 second(s).
