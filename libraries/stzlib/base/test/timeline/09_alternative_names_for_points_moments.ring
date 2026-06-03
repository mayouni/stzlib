# Narrative
# --------
# Alternative names for points (Moments)
#
# Extracted from stztimelinetest.ring, block #9.

load "../../stzBase.ring"


pr()

oTimeLine = new stzTimeLine(
	:Start = "2024-01-01 00:00:00",
	:End = "2024-12-31 23:59:59"
)

oTimeLine.AddMoment("MILESTONE", "2024-06-15 12:00:00")

? oTimeLine.Moments()
#--> [
# 	[ "MILESTONE", "2024-06-15 12:00:00" ]
# ]

? oTimeLine.CountPoints()
#--> 1

pf()
# Executed in 0.01 second(s) in Ring 1.24

#-----------------------#
#  TimeSpan Management  #
#-----------------------#
