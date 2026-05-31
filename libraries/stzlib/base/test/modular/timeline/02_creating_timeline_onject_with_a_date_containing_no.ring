# Narrative
# --------
# Creating timeline onject with a date containing no time
#
# Extracted from stztimelinetest.ring, block #2.

load "../../../stzBase.ring"


pr()

o1 = new stzTimeLine(:From = "2024-10-10", :To = "2024-10-22 16:40:00")

? @@NL(o1.Content()) # Time is added automatically to "2024-10-10"
#--> [
#	[ "start", "2024-10-10 00:00:00" ],
#	[ "end", "2024-10-22 16:40:00" ],
#	[ "points", [  ] ],
#	[ "spans", [  ] ]
# ]

pf()
# Executed in 0.01 second(s) in Ring 1.24
