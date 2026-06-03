# Narrative
# --------
# pr()
#
# Extracted from stzchartest.ring, block #118.

load "../../stzBase.ring"


o1 = new stzString("s㊱m")
? o1.NumberOfBytes() #--> 624
? o1.SizeInBytes() #--> 624

? @@(o1.Bytes())
#--> [ "s", "�", "�", "�", "m" ]

? @@(o1.NumberOfBytesPerChar())
#-->	[ [ "s", 33 ], [ "㊱", 35 ], [ "m", 33 ] ]

pf()
# Executed in 0.12 second(s) in Ring 1.23
