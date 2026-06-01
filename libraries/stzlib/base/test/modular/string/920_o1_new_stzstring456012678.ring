# Narrative
# --------
# o1 = new stzString("...456...012...678..")
#
# Extracted from stzStringTest.ring, block #920.

load "../../../stzBase.ring"

o1.ReplaceSectionsByMany([ [ 4, 6], [10, 20], [16, 18] ], ["A", "BB", "CCC"])
? o1.Content()
#--> ERROR MSG: Incorrect param type!
# ~> paSections must be a list of pairs of numbers sorted in ascending.
