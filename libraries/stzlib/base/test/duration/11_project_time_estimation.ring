# Narrative
# --------
# Project Time Estimation
#
# Extracted from stzdurationtest.ring, block #11.

load "../../stzBase.ring"


pr()

aTasks = [
	[ "Design mockups", DurationQ("2 days") ],
	[ "Backend development", DurationQ("5 days") ],
	[ "Frontend development", DurationQ("4 days") ],
	[ "Testing", DurationQ("2 days") ],
	[ "Deployment", DurationQ("1 day") ]
]

oTotalProject = DurationQ(0)

? "Task breakdown:"
_nTasks1Len_ = ring_len(aTasks)
for _iLoopTasks1_ = 1 to _nTasks1Len_
	aTask = aTasks[_iLoopTasks1_]
	? "  " + aTask[1] + ": " + aTask[2].ToCompact()
	oTotalProject = oTotalProject + aTask[2]
next

? ""
? "Total project duration: " + oTotalProject.ToHuman()
? "Working days: " + oTotalProject.TotalDays()

# Add 20% buffer
oBuffer = oTotalProject * 0.20
oWithBuffer = oTotalProject + oBuffer

? "With 20% buffer: " + oWithBuffer.ToHuman()
? "Total days (with buffer): " + oWithBuffer.TotalDays()

#-->
# Task breakdown:
#   Design mockups: 2d
#   Backend development: 5d
#   Frontend development: 4d
#   Testing: 2d
#   Deployment: 1d
# 
# Total project duration: 14 days
# Working days: 14
# With 20% buffer: 16 days, 19 hours, and 12 minutes
# Total days (with buffer): 16

pf()
# Executed in 0.04 second(s) in Ring 1.24
