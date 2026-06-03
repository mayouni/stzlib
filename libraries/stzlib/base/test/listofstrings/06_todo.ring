# Narrative
# --------
# TODO
#
# Extracted from stzlistofstringstest.ring, block #6.

load "../../stzBase.ring"


StartProfiler()

o1 = new stzListOfStrings([ "_", "ONE", "_", "_", "TWO", "_", "THREE", "*", "*" ])
? @@( o1.FindDuplicates() )


StopProfiler()
