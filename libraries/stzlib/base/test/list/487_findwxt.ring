# Narrative
# --------
# StartProfiler()
#
# Extracted from stzlisttest.ring, block #487.

load "../../stzBase.ring"

pr()

# Finding positions where previous 3rd item is equal to next 3rd item

o1 = new stzList( [ 0, 8, 0, 0, 1, 8, 0, 0 ] )

? @@( o1.FindWXT('{ This[ @i - 3 ] = This[ @i + 3 ] }') )
#--> [ 4 ]

? ElapsedTime()
#--> 0.15 second(s)

? @@( o1.FindW('{ This[ @i - 3 ] = This[ @i + 3 ] }') )
#--> [ 4 ]

StopProfiler()
#--> Executed in 0.23 second(s) in Ring 1.21
#--> Executed in 0.74 second(s) in Ring 1.18

pf()
