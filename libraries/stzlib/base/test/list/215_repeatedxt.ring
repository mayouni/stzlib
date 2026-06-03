# Narrative
# --------
# StartProfiler()
#
# Extracted from stzlisttest.ring, block #215.
#ERR Error (R20) : Calling function with extra number of parameters

load "../../stzBase.ring"

pr()

? Q("A").RepeatedXT(:InAString, :OfSize = 3)
#--> "AAA"

? Q("A").RepeatedXT(:InAList, :OfSize = 3)
#--> ["A", "A", "A"]

? Q("A").RepeatedXT( :NTimes = 3, :InAList )
? Q("A").RepeatedXT([ 3, :Times ], :InAList )

? Q("A").RepeatedXT( :NTimes = 3, :InAString )
? Q("A").RepeatedXT([ 3, :Times ], :InString ) + NL

StopProfiler()

pf()
# Executed in 0.11 second(s) in Ring 1.21
