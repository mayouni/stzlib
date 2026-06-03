# Narrative
# --------
# # Now, let's experiment with an other construction, using Until():
#
# Extracted from stzchainofvaluetest.ring, block #6.
#ERR Error (R24) : Using uninitialized variable: v

load "../../stzBase.ring"

pr()

Until(:v).Is("12000").DoThis('{ v += "0" ? v }') #--> [ "120", "1200", "12000" ]

pf()
