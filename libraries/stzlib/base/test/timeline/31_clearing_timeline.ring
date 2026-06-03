# Narrative
# --------
# Clearing timeline
#
# Extracted from stztimelinetest.ring, block #31.

load "../../stzBase.ring"


pr()

oTimeLine = new stzTimeLine(
	:Start = "2024-01-01 00:00:00",
	:End = "2024-12-31 23:59:59"
)

oTimeLine {
	AddPoint("EVENT1", "2024-03-15 10:00:00")
	AddPoint("EVENT2", "2024-04-15 10:00:00")
	AddSpan("PERIOD", "2024-05-01 00:00:00", "2024-05-31 23:59:59")
}

? oTimeLine.CountPoints()
#--> 2

? oTimeLine.CountSpans()
#--> 1

oTimeLine.Clear()

? oTimeLine.CountPoints()
#--> 0

? oTimeLine.CountSpans()
#--> 0

pf()
# Executed in 0.01 second(s) in Ring 1.24

#---------------------------#
#  Displaying the TimeLine  #
#---------------------------#
