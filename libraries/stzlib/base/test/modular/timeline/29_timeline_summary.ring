# Narrative
# --------
# Timeline summary
#
# Extracted from stztimelinetest.ring, block #29.

load "../../../stzBase.ring"


pr()

oTimeLine = new stzTimeLine(
	:Start = "2024-01-01 00:00:00",
	:End = "2024-12-31 23:59:59"
)

oTimeLine {
	AddPoint("KICKOFF", "2024-02-01 10:00:00")
	AddPoint("REVIEW", "2024-06-15 14:00:00")
	AddSpan("DEVELOPMENT", "2024-03-01 00:00:00", "2024-05-31 23:59:59")
}

? @@NL( oTimeLine.Summary() )
#--> [
#     :Start = "2024-01-01 00:00:00",
#     :End = "2024-12-31 23:59:59",
#     :TotalDuration = "1 year",
#     :CountPoints = 2,
#     :CountSpans = 1,

#     :Points = [
#         [:Name = "KICKOFF", :DateTime = "2024-02-01 10:00:00"],
#         [:Name = "REVIEW", :DateTime = "2024-06-15 14:00:00"]
#     ],

#     :Spans = [
#         [:Name = "DEVELOPMENT",
#          :Start = "2024-03-01 00:00:00",
#          :End = "2024-05-31 23:59:59",
#          :Duration = "3 months"]
#     ]
# ]

pf()
# Executed in 0.02 second(s) in Ring 1.24
