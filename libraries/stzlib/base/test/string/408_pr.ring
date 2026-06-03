# Narrative
# --------
# pr()
#
# Extracted from stzStringTest.ring, block #408.

load "../../stzBase.ring"


o1 = new stzString("-23.67 pounds")
? o1.StartsWithANumber() # Or BeginsWith...
#--> TRUE

? o1.StartingNumber()
#--> "-23.67"

? o1.StartsWithThisNumber("-23.67") # OR StartsWithNumberN(...)
#--? TRUE

pf()
# Executed in 0.04 second(s) in Ring 1.21
