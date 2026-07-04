# Narrative
# --------
#
# NOTE (audit, 2026-07-04): DEFERRED -- SEMANTIC locale validation ("ar-tn" TRUE but "ar-fr"/"tn-fr" FALSE needs the language-country compatibility data); goes with 650/664 to the stzLocale pass. The structural IsLocaleAbbreviation (649) stays.
# pr()
#
# Extracted from stzStringTest.ring, block #839.

load "../../stzBase.ring"

pr()

o1 = new stzString("ar-tn")
? o1.IsLocaleAbbreviation()
#--> TRUE

o1 = new stzString("ar-fr")
? o1.IsLocaleAbbreviation()
#--> FALSE

o1 = new stzString("tn-fr")
? o1.IsLocaleAbbreviation()
#--> FALSE

pf()
# Executed in 0.01 second(s) in Ring 1.22
