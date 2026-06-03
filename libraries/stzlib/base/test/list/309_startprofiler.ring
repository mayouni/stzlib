# Narrative
# --------
# StartProfiler()
#
# Extracted from stzlisttest.ring, block #309.

load "../../stzBase.ring"


#                   1..4.6..9.1.34..7..0
o1 = new stzString("[••[•[••]•[•]]••[••]]")


? o1.DistanceTo("[", :StartingAt = 1)
#--> 2

? o1.DistanceTo( :Next = "[", :StartingAt = 1 )
#--> 2

? o1.DistanceTo( :NextNth = [ 2, "[" ], :StartingAt = 1 )
#--> 4

#~> XT form : bounds are counted in the distance

? NL + "--" + NL

? o1.DistanceToSTXT("[", :StartingAt = 1)
#--> 4

? o1.DistanceToSTXT( :Next = "[", :StartingAt = 1 )
#--> 4

? o1.DistanceToSTXT( :NextNth = [2, "["], :StartingAt = 1 )
#--> 6

? NL + "--" + NL

? o1.DistanceToSTXT( :Previous = "[", :StartingAt = 9 )
#--> 4

? o1.DistanceToSTXT( :PreviousNth = [2, "["], :StartingAt = 9 )
#--> 6

? o1.DistanceTo( :Previous = "[", :StartingAt = 9 )
#--> 2

? o1.DistanceTo( :PreviousNth = [2, "["], :StartingAt = 9 )
#--> 4

StopProfiler()
# Executed in 2.68 second(s) in Ring 1.22
