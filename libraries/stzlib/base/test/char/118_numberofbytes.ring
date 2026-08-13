# Narrative
# --------
# pr()
#
# Extracted from stzchartest.ring, block #118.
#ERR Error (C22) : Function redefinition, function is already defined!

load "../../stzBase.ring"

pr()

o1 = new stzString("s㊱m")
# "s㊱m" is 1 + 3 + 1 = 5 bytes. 624 was never a byte count.
? o1.NumberOfBytes() #--> 5
? o1.SizeInBytes() #--> 5

? @@(o1.Bytes())
#--> [ "s", "�", "�", "�", "m" ]

? @@(o1.NumberOfBytesPerChar())
#-->	[ [ "s", 1 ], [ "㊱", 3 ], [ "m", 1 ] ]

pf()
# Executed in 0.12 second(s) in Ring 1.23
