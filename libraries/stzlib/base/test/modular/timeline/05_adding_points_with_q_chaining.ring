# Narrative
# --------
# Adding points with Q() chaining
#
# Extracted from stztimelinetest.ring, block #5.

load "../../../stzBase.ring"


pr()

oTimeLine = new stzTimeLine(
	:Start = "2024-01-01 00:00:00",
	:End = "2024-12-31 23:59:59"
)

oTimeLine {
	AddPoint("EVENT1", "2024-03-15 10:00:00")
	AddPoint("EVENT2", "2024-03-16 14:30:00")
	AddPoint("EVENT3", "2024-03-17 09:00:00")
}

? oTimeLine.CountPoints()
#--> 3

pf()
# Executed in 0.01 second(s) in Ring 1.24
