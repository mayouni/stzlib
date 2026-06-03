# Narrative
# --------
# Mixed distance calculations
#
# Extracted from stztimelinetest.ring, block #26.

load "../../stzBase.ring"


pr()

oTimeLine = new stzTimeLine(
	:Start = "2024-01-01 00:00:00",
	:End = "2024-12-31 23:59:59"
)

oTimeLine {
	AddPoint("KICKOFF", "2024-01-15 10:00:00")
	AddSpan("WORK", "2024-02-01 00:00:00", "2024-04-30 23:59:59")
}

? oTimeLine.Distance("KICKOFF", "WORK") # Or TimeBetween
#--> 1432800 (seconds)

? oTimeLine.TimeBetween("KICKOFF", "WORK")
#--> 1432800

pf()
# Executed in 0.01 second(s) in Ring 1.24

#----------------------#
#  Sorting & Utility   #
#----------------------#
