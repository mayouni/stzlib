# Narrative
# --------
# Creating timeline with start and end boundaries
#
# Extracted from stztimelinetest.ring, block #1.

load "../../stzBase.ring"


pr()

oTimeLine = new stzTimeLine(
	:Start = "2024-01-01 00:00:00",
	:End = "2024-12-31 23:59:59"
)

oTimeLine {
	? Start()
	#--> 2024-01-01 00:00:00

	? End_()
	#--> 2024-12-31 23:59:59

	? Duration()
	#--> 31622399 (seconds)

	? DurationQ().ToHuman()
	#--> 1 year
}

pf()
# Executed in 0.01 second(s) in Ring 1.24
