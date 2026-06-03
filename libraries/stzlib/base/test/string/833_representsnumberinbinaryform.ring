# Narrative
# --------
# pr()
#
# Extracted from stzStringTest.ring, block #833.

load "../../stzBase.ring"

pr()

o1 = new stzString("0b110001.1001")
? o1.RepresentsNumberInBinaryForm()
#--> TRUE

o1 = new stzString("-0b110001.1001")
? o1.RepresentsNumberInBinaryForm()
#--> TRUE

o1 = new stzString("0b-110001.1001")
? o1.RepresentsNumberInBinaryForm()
#--> FALSE

pf()
# Executed in 0.03 second(s) in Ring 1.22
