# Narrative
# --------
# StartProfiler()
#
# Extracted from stzlisttest.ring, block #478.

load "../../../stzBase.ring"


o1 = new stzList([ "A", "m", "n", "B", "A", "x", "C", "z", "B" ])

? o1.ItemsPositionsWXT('Q(@item).IsUppercase()') # Say also o1.FindItemsW(...) or .FindW(...)
#--> [ 1, 4, 5, 7, 9 ]

? @@( o1.ItemsAndTheirPositionsWXT('Q(@item).IsUppercase()') )
#--> [ [ "A", [ 1, 5 ] ], [ "B", [ 4, 9 ] ], [ "C", [ 7 ] ] ]

StopProfiler()
# Executed in 0.40 second(s).
