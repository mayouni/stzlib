# Narrative
# --------
# pr()
#
# Extracted from stznumbertest.ring, block #55.

load "../../../stzBase.ring"


o1 = new stzNumber("123")
? o1.Content()
#--> 123

o1 = new stzNumber("123.")
? o1.Content()
#--> 123.0

o1 = new stzNumber([ "123", 3 ])
? o1.Content()
#--> 123.000

pf()
