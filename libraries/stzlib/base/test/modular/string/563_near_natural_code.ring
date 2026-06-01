# Narrative
# --------
# Near Natural Code
#
# Extracted from stzStringTest.ring, block #563.

load "../../../stzBase.ring"


pr()

o1 = new stzString("my <<word>> and your <<word>>")
? @@( o1.FindXT("word", :StartingAt = 12) )
#--> [ 24 ]

? @@( o1.FindXT("word", :InSection = [3, 10]) )
#--> [ 6 ]

pf()
# Executed in 0.03 second(s) in Ring 1.22
# Executed in 0.08 second(s) in Ring 1.19
