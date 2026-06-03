# Narrative
# --------
# pr()
#
# Extracted from stzStringTest.ring, block #857.

load "../../stzBase.ring"

pr()

o1 = new stzString("12500")
? o1.RepresentsNumberInDecimalForm()
#--> TRUE

o1 = new stzString("b100011")
? o1.RepresentsNumberInBinaryForm()
#--> TRUE

o1 = new stzString("100011") # Without the b, it's rather a decimal not binary number!
? o1.RepresentsNumberInBinaryForm()
#--> FALSE

o1 = new stzString("100011")
? o1.RepresentsNumberInDecimalForm()
#--> TRUE

pf()
# Executed in 0.02 second(s).
