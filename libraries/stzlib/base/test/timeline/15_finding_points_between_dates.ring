# Narrative
# --------
# Finding points between dates
#
# Extracted from stztimelinetest.ring, block #15.

load "../../stzBase.ring"


pr()

oTimeLine = new stzTimeLine(
	:Start = "2024-01-01 00:00:00",
	:End = "2024-12-31 23:59:59"
)

oTimeLine {
	AddPoint("JAN_EVENT", "2024-01-15 10:00:00")
	AddPoint("FEB_EVENT", "2024-02-15 10:00:00")
	AddPoint("MAR_EVENT", "2024-03-15 10:00:00")
	AddPoint("APR_EVENT", "2024-04-15 10:00:00")
}

? @@( oTimeLine.PointsBetween("2024-02-01 00:00:00", "2024-03-31 23:59:59") )
#--> ["FEB_EVENT", "MAR_EVENT"]

# More expressive (Moment alternative and named parameter syntax, looks like poetry;)
? oTimeLine.MomentsBetween("2024-02-01 00:00:00", :And = "2024-03-31 23:59:59")
#--> ["FEB_EVENT", "MAR_EVENT"]

pf()
# Executed in 0.02 second(s) in Ring 1.24
