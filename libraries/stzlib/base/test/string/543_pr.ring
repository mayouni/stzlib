# Narrative
# --------
# pr()
#
# Extracted from stzStringTest.ring, block #543.

load "../../stzBase.ring"


o1 = new stzString("**word1***word2**word3***")
? o1.Ranges([ [1,2], [8, 3], [16, 2], [23, 3] ])
#--> [ "**", "***", "**", "***" ]

o1.RemoveRanges([ [1,2], [8, 3], [16, 2], [23, 3] ])
? o1.Content()
#--> "word1word2word3"

pf()
# Executed in 0.06 second(s) in Ring 1.22
