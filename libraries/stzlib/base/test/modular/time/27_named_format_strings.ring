# Narrative
# --------
# Named format strings
#
# Extracted from stztimetest.ring, block #27.

load "../../../stzBase.ring"


pr()

oTime = new stzTime("14:30:45")

? oTime.ToStringXT(:Standard)
#--> 14:30:45

? oTime.ToStringXT(:Short)
#--> 14:30

? oTime.ToStringXT(:Long)
#--> 14:30:45.000

? oTime.ToStringXT(:AmPm)
#--> 2:30:45 PM

pf()
# Executed in almost 0 second(s) in Ring 1.23
