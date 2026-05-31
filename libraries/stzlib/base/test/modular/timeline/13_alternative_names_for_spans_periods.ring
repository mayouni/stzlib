# Narrative
# --------
# Alternative names for spans (Periods)
#
# Extracted from stztimelinetest.ring, block #13.

load "../../../stzBase.ring"


pr()

oTimeLine = new stzTimeLine(
	:Start = "2024-01-01 00:00:00",
	:End = "2024-12-31 23:59:59"
)

oTimeLine.AddPeriod("VACATION", "2024-07-01 00:00:00", "2024-07-15 23:59:59")

? oTimeLine.Periods()
#--> [["VACATION", "2024-07-01 00:00:00", "2024-07-15 23:59:59"]]

? oTimeLine.CountPeriods()
#--> 1

pf()
# Executed in 0.01 second(s) in Ring 1.24

#----------------------#
#  Temporal Queries    #
#----------------------#
