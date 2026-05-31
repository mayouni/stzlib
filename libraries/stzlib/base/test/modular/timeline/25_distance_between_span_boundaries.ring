# Narrative
# --------
# Distance between span boundaries
#
# Extracted from stztimelinetest.ring, block #25.

load "../../../stzBase.ring"


pr()

oTimeLine = new stzTimeLine(
	:Start = "2024-01-01 00:00:00",
	:End = "2024-12-31 23:59:59"
)

oTimeLine {
	AddSpan("PHASE1", "2024-01-01 00:00:00", "2024-02-28 23:59:59")
	AddSpan("PHASE2", "2024-04-01 00:00:00", "2024-05-31 23:59:59")
}

# Distance uses end of first span to start of second
? oTimeLine.Distance("PHASE1", "PHASE2")
#--> 2678401 (seconds)

pf()
# Executed in 0.01 second(s) in Ring 1.24
