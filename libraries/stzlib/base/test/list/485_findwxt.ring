# Narrative
# --------
# StartProfiler()
#
# Extracted from stzlisttest.ring, block #485.

load "../../stzBase.ring"

pr()

# Finding positions where current item is equal to next item
o1 = new stzList([ 2, 8, 2, 2, 11, 2, 11, 7, 7, 4, 2, 1, 3, 2, 10, 8, 3, 3, 3, 6, 8 ])

? o1.FindWXT( '{ @Number = @NextNumber }' )
#--> [ 3, 8, 17, 18 ]

? ElapsedTime()
#--> Takes 0.20s

? o1.FindW( '{ This[@i] = This[@i+1] }' )
#--> [ 3, 8, 17, 18 ]

#--> Takes as little as 0.05s!

StopProfiler()

pf()
# Executed in 0.29 second(s).
