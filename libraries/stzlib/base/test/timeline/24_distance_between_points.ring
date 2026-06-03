# Narrative
# --------
# Distance between points
#
# Extracted from stztimelinetest.ring, block #24.

load "../../stzBase.ring"


pr()

oTimeLine = new stzTimeLine(
	:Start = "2024-01-01 00:00:00",
	:End = "2024-12-31 23:59:59"
)

oTimeLine {
	AddPoint("START", "2024-01-15 10:00:00")
	AddPoint("END", "2024-03-15 10:00:00")
}

? oTimeLine.Distance("START", "END")
#--> 5184000 (seconds)

? oTimeLine.DistanceQ("START", "END").ToHuman()
#--> 60 days

# Named parameter syntax
? oTimeLine.Distance(:From = "START", :To = "END")
#--> 5184000

pf()
# Executed in 0.01 second(s) in Ring 1.24
