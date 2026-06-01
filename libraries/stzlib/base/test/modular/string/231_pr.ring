# Narrative
# --------
# pr()
#
# Extracted from stzStringTest.ring, block #231.

load "../../../stzBase.ring"


o1 = new stzString("Math: 18, Geo: 16, :Physics: 17.80")
? @@( o1.ExtractNumbers() )
#--> [ "18", "16", "17.80" ]

? o1.Content()
#--> Math: , Geo: , :Physics: 

pf()
# Executed in 0.01 second(s) in Ring 1.21
# Executed in 0.17 second(s) in Ring 1.18
