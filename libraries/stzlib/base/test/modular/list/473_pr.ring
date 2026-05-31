# Narrative
# --------
# pr()
#
# Extracted from stzlisttest.ring, block #473.

load "../../../stzBase.ring"


# finding positions where current item is equal or bigger than 8

o1 = new stzList([ 2, 8, 2, 11, 2, 11, 1, 4, 2, 1, 3, 2, 10, 8, 3, 6, 8 ])
? o1.ItemsWXT( '{ @item >= 8 }' )
#--> [ 8, 11, 11, 10, 8, 8 ]

pf()
# Executed in 0.15 second(s).
