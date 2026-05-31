# Narrative
# --------
# Getting current time with NowTime()
#
# Extracted from stztimetest.ring, block #1.

load "../../../stzBase.ring"


pr()

? Now()
#--> 30/09/2025 23:05:00

? NowTime() # Or simply Time()
#--> 23:05:39

oTime = StzTimeQ("")
? oTime.Time() # Or Content() or ToString()
#--> 23:05:39

pf()
# Executed in almost 0 second(s) in Ring 1.23
