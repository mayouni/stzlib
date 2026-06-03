# Narrative
# --------
# // Retest after adding ReplaceAllCharsW() in stzString
#
# Extracted from stzTtexttest.ring, block #4.

load "../../stzBase.ring"

pr()

? StzTextQ("مُسْتَحَقَّاتُُ").Scripts()
? StzTextQ("مُسْتَحَقَّاتُُ").Script()


? StzTextQ("مُسْتَحَقَّاتُُ").DiacriticsRemoved()

? StzTextQ("مُسْتَحَقَّاتُُ").RemoveDiacriticsQ().Content()

pf()
