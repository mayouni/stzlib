# Narrative
# --------
# REFACTORED: FIXING IS IN PROGRESS
#
# Extracted from stzTtexttest.ring, block #36.

load "../../stzBase.ring"


//TODO >>> stzLocale

o1 = new stzText("this is my first experience with that company")
#o1 = new stzString("من عالمك إلى عالمي على مسؤوليّتي")
? o1.RemoveStopWordsInQ(:Latin).Content()
