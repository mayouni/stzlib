# Narrative
# --------
# StartProfiler()
#
# Extracted from stzlisttest.ring, block #486.

load "../../stzBase.ring"


# Finding positions where current item is equal to next item

o1 = new stzList([ "A", "B", "B", "C", "D", "D", "D", "E" ])
? o1.FindW( '{ This[@i] = This[@i+1] }' )
#--> [ 2, 5, 6 ]

StopProfiler()
#--> Executed in 0.10 second(s)
