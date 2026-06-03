# Narrative
# --------
# pr()
#
# Extracted from stznumbertest.ring, block #60.
#ERR Error (R20) : Calling function with extra number of parameters

load "../../stzBase.ring"

pr()

o1 = new stzNumber("123.")
? o1.RoundedTo(:Max)
#--> "123.0000000000"

pf()
# Executed in 0.05 second(s)
