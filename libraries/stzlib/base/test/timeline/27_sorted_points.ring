# Narrative
# --------
# Sorted points
#
# Extracted from stztimelinetest.ring, block #27.

load "../../stzBase.ring"


pr()

oTimeLine = new stzTimeLine(
	:Start = "2024-01-01 00:00:00",
	:End = "2024-12-31 23:59:59"
)

oTimeLine {
	AddPoint("THIRD", "2024-09-15 10:00:00")
	AddPoint("FIRST", "2024-01-15 10:00:00")
	AddPoint("SECOND", "2024-05-15 10:00:00")
}

? @@NL( oTimeLine.SortedPoints() )
#--> [
#     ["FIRST", "2024-01-15 10:00:00"],
#     ["SECOND", "2024-05-15 10:00:00"],
#     ["THIRD", "2024-09-15 10:00:00"]
# ]

pf()
# Executed in 0.02 second(s) in Ring 1.24
