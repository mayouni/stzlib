# Narrative
# --------
# StartProfiler()
#
# Extracted from stzlisttest.ring, block #216.

load "../../stzBase.ring"


? Q(5).RepeatedXT(:InAString, :OfSize = 3)
#--> "555"

? Q(5).RepeatedXT(:InAList, :OfSize = 3)
#--> [5, 5, 5]

? Q(5).RepeatedXT( :NTimes = 3, :InAList )
#--> [5, 5, 5]

? Q(5).RepeatedXT([ 3, :Times ], :InAList )
#--> [5, 5, 5]

? Q(5).RepeatedXT( :NTimes = 3, :InAString )
#--> "555"

? Q(5).RepeatedXT([ 3, :Times ], :InString ) + NL
#--> [5, 5, 5]

StopProfiler()
# Executed in 0.10 second(s) in Ring 1.21
