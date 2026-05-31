# Narrative
# --------
# // Retest after adding ReplaceAllCharsW() in stzString
#
# Extracted from stzTtexttest.ring, block #3.

load "../../../stzBase.ring"


? StzTextQ("évènement").DiacriticsRemoved()
? StzTextQ("Zoölogy").DiacriticsRemoved()
