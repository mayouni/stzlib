# Narrative
# --------
# pr()
#
# Extracted from stztabletest.ring, block #18.

load "../../stzBase.ring"

pr()

# WAY 2 : Creating an empty table with 3 columns and 3 rows

o1 = new stzTable([3, 2])
o1.Show()
#-->
#   COL1   COL2   COL3
#     ""     ''     "'    
#     ""     ''     "'  

pf()
# Executed in 0.08 second(s)
