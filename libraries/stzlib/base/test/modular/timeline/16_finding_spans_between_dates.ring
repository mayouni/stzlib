# Narrative
# --------
# Finding spans between dates
#
# Extracted from stztimelinetest.ring, block #16.

load "../../../stzBase.ring"


pr()

oTimeLine = new stzTimeLine(
	:From = "2024-01-01 00:00:00",
	:To = "2024-12-31 23:59:59"
)

oTimeLine {
	AddSpan("JAN_SPAN", "2024-01-01 00:00:00", "2024-01-31 23:59:59")
	AddSpan("FEB_SPAN", "2024-02-01 00:00:00", "2024-02-29 23:59:59")
	AddSpan("MAR_SPAN", "2024-03-01 00:00:00", "2024-03-31 23:59:59")
}

? @@( oTimeLine.SpansBetween("2024-01-15 00:00:00", "2024-02-15 23:59:59") )
#--> ["JAN_SPAN", "FEB_SPAN"]

pf()
# Executed in 0.02 second(s) in Ring 1.24
