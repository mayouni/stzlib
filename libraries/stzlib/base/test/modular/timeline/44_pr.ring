# Narrative
# --------
# pr()
#
# Extracted from stztimelinetest.ring, block #44.

load "../../../stzBase.ring"


o1 = new stzTimeLine(
	:Start = "2024-03-01 00:00:00",
	:End   = "2024-03-30 00:00:00"
)

//o1.AddPoint("ONE", "10:12:25")
#--> ERROR MESSAGE: Invalid input! Time specified without a date.
 
# When only a date is provide, Softanza extends it with a " 00:00:00" time
o1.AddPoint("ONE", "2024-03-12")
? @@(o1.Points())
#--> [ [ "ONE", "2024-03-12 00:00:00" ] ]

pf()
# Executed in 0.01 second(s) in Ring 1.24
