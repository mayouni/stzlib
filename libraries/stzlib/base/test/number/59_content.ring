# Narrative
# --------
# pr()
#
# Extracted from stznumbertest.ring, block #59.

load "../../stzBase.ring"

pr()

o1 = new stzNumber("123") 
o1.RoundTo(:Max)
? o1.Content()
#--> "123.00000000000000"

o1 = new stzNumber("123456789012345")
o1.RoundTo(:Max)
? o1.Content()
#--> "12345678912345"

pf()
