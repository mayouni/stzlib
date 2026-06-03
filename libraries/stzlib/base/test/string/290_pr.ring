# Narrative
# --------
# pr()
#
# Extracted from stzStringTest.ring, block #290.

load "../../stzBase.ring"


o1 = new stzString("PhpRingRingRingPythonRubyRuby")

aSections = [ [ 8, 11 ], [ 9, 12 ], [ 10, 13 ], [ 11, 14 ], [ 12, 15 ], [ 26, 29 ] ]

o1.RemoveSections(aSections)
? o1.Content()

pf()
