# Narrative
# --------
# pr()
#
# Extracted from stzlisttest.ring, block #626.
#ERR Error (R14) : Calling Method without definition: arelanguageabbreviations

load "../../stzBase.ring"

pr()

? Q([ :ar, :en, :fr ]).AreLanguageAbbreviations()
#--> TRUE

pf()
# Executed in 0.01 second(s).
