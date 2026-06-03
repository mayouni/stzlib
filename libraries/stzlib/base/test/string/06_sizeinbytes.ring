# Narrative
# --------
# pr()
#
# Extracted from stzStringTest.ring, block #6.

load "../../stzBase.ring"

pr()

o1 = new stzString("Softanza")
? o1.SizeInBytes()
#--> 624

? o1.SizeInBytes64()
#--> 624

? o1.SizeInBytes32()
#--> 400

pf()
# Executed in 0.35 second(s) in Ring 1.22
