# Narrative
# --------
# #narration 5 ways to create a stzTable
#
# Extracted from stztabletest.ring, block #17.

load "../../../stzBase.ring"


pr()

# A table can be created in 6 different ways:

# WAY 1 : Creating an empty table with just a column and a row with just an empty cell
o1 = new stzTable([])

? @@( o1.Content() ) + NL
#--> [ [ "COL1", [ "" ] ] ]

o1.Show()
#--> COL1
#    ----
#     ""  

pf()
# Executed in 0.07 second(s)
