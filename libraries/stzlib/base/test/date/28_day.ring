# Narrative
# --------
# pr()
#
# Extracted from stzdatetest.ring, block #28.
#ERR Error (C22) : Function redefinition, function is already defined!

load "../../stzBase.ring"

pr()

o1 = new stzDate("10/12/2024")

? o1.Day()
#--> Tuesday

? o1.Month()
#--> December

? o1.ToHuman()
#--> Tuesday, December 10th, 2024

pf()
# Executed in almost 0 second(s) in Ring 1.23
