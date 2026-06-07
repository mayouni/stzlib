# Narrative
# --------
# pr()
#
# Extracted from stzStringTest.ring, block #684.

load "../../stzBase.ring"

pr()

o1 = new stzString("SOFTANZA IS AWSOME!")

? o1.IsEqualTo("softanza is awsome!")
#--> FALSE

? o1.IsEqualToCS("softanza is awsome!", :CS = FALSE)
#--> TRUE

? o1.IsUppercaseOf("softanza is awsome!")
#--> TRUE

pf()
# Executed in 0.01 second(s) in Ring 1.22
