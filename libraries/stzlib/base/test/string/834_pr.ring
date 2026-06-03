# Narrative
# --------
# pr()
#
# Extracted from stzStringTest.ring, block #834.

load "../../stzBase.ring"


o1 = new stzString("0x12_5AB34.123F")

? o1.RepresentsNumber()
#--> TRUE

? o1.NumberForm()
#--> :Hex

? o1.RepresentsNumberInHexForm() + NL
#--> TRUE

#--

o1 = new stzString("0o2304.307")

? o1.RepresentsNumber()
#--> TRUE

? o1.NumberForm()
#--> :Octal

? o1.RepresentsNumberInOctalForm()
#--> TRUE

pf()
# Executed in 0.08 second(s) in Ring 1.22
