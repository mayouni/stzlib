# Narrative
# --------
# Createing a date object from a hashlist in any order
#
# Extracted from stzdatetest.ring, block #5.

load "../../stzBase.ring"


pr()

o1 = new stzDate([ :Day = 12, :Month = 10, :Year = 2024 ])
? o1.Date()
#--> 12/10/2024

pf()
# Executed in almost 0 second(s) in Ring 1.24
