# Narrative
# --------
# pr()
#
# Extracted from stzlisttest.ring, block #347.
#ERR Error (R11) : Error in class name, class not found: stztext

load "../../stzBase.ring"

pr()

? QQ("normal text").StzType()
#--> stztext

o1 = new stzString("normal text")

? o1.IsNumberInString()
#--> FALSE

? o1.IsListInString()
#--> FALSE

pf()
# Executed in 0.07 second(s) in Ring 1.22
