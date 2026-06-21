# Narrative
# --------
# AreLanguageAbbreviations(): is every item a valid language abbreviation?
#
# A list-level predicate that holds when all items are strings AND each is
# a recognised language code -- here :ar, :en, :fr (Arabic, English,
# French). It delegates the per-item check to stzString's
# IsLanguageAbbreviation (a locale-table lookup).
#
# Extracted from stzlisttest.ring, block #626.

load "../../stzBase.ring"

pr()

? Q([ :ar, :en, :fr ]).AreLanguageAbbreviations()
#--> TRUE

pf()
# Executed in almost 0 second(s)
