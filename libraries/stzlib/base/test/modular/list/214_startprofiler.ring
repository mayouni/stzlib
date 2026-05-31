# Narrative
# --------
# StartProfiler()
#
# Extracted from stzlisttest.ring, block #214.

load "../../../stzBase.ring"


? Q(5).Repeated(3)
#--> [ 5, 5, 5 ]

? Q(5).Repeated([ 3, :Times ])
#--> [ 5, 5, 5 ]

#--

? Q(1:2).Repeated(3)
#--> [ 1:2, 1:2, 1:2 ]

? Q(1:2).Repeated([ 3, :Times ])
#--> [ 1:2, 1:2, 1:2 ]

#--

? Q("A").Repeated(3)
#--> AAA

? Q("A").Repeated([ :NTimes, 3 ])
#--> AAA

? Q("A").Repeated([ 3, :Times ])
#--> AAA

StopProfiler()
# Executed in 0.07 second(s) in Ring 1.21
