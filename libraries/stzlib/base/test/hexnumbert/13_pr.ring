# Narrative
# --------
# pr()
#
# Extracted from stzhexnumbertTest.ring, block #13.

load "../../stzBase.ring"


o1 = new stzHexNumber("")

o1.FromBinary("b10011")
? o1.Content()
#--> 0x13

? o1.ToOctal() # TODO check correctness

pf()
# Executed in 0.02 second(s).
