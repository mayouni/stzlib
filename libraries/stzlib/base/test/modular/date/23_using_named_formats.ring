# Narrative
# --------
# Using named formats
#
# Extracted from stzdatetest.ring, block #23.

load "../../../stzBase.ring"


pr()

oDate = StzDateQ("25/12/2024")

? oDate.ToStringXT(:Long)
#--> Wednesday, December 25, 2024

? oDate.ToStringXT(:Compact)
#--> 25122024

pf()
# Executed in almost 0 second(s) in Ring 1.23
