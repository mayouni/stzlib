# Narrative
# --------
# Copying timeline
#
# Extracted from stztimelinetest.ring, block #30.

load "../../../stzBase.ring"


pr()

oTimeLine = new stzTimeLine(
	:Start = "2024-01-01 00:00:00",
	:End = "2024-12-31 23:59:59"
)

oTimeLine {
	AddPoint("EVENT", "2024-03-15 10:00:00")
	AddSpan("PERIOD", "2024-04-01 00:00:00", "2024-04-30 23:59:59")
}

oCopy = oTimeLine.Copy()

? oCopy.CountPoints()
#--> 1

? oCopy.CountSpans()
#--> 1

? oCopy.Start()
#--> 2024-01-01 00:00:00

pf()
