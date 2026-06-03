# Narrative
# --------
# // Retest after adding ReplaceAllCharsW() in stzString
#
# Extracted from stzTtexttest.ring, block #4.
#ERR exit 1: Line 79 Bad parameters value, error in length!

load "../../stzBase.ring"

pr()

? StzTextQ("مُسْتَحَقَّاتُُ").Scripts()
? StzTextQ("مُسْتَحَقَّاتُُ").Script()


? StzTextQ("مُسْتَحَقَّاتُُ").DiacriticsRemoved()

? StzTextQ("مُسْتَحَقَّاتُُ").RemoveDiacriticsQ().Content()

pf()
