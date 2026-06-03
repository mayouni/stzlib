# Narrative
# --------
# o1 = new stzText("Ring is not the Ring you ware but the Ring you program with!")
#
# Extracted from stzTtexttest.ring, block #26.

load "../../stzBase.ring"

pr()

o1.ReplaceWordsCS( [ :ring ], [ :Watch ], 0 )
? o1.Content()

/*
ReplaceManyWordsCS(pacWords, pacNewWords, pCaseSensitive)
ReplaceEachWordCS(pacWords, pacNewWords, pCaseSensitive)
ReplaceAllOccurrencesOfWordsCS(pacWords, pacNewWords, pCaseSensitive)

pf()
