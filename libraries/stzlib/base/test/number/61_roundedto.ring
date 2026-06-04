# Narrative
# --------
# pr()
#
# Extracted from stznumbertest.ring, block #61.
#ERR Error (R14) : Calling Method without definition: removedfromend

load "../../stzBase.ring"

pr()

o1 = new stzNumber("12.456")

? o1.RoundedTo(:Max)
#--> 12.456

? o1.RoundedTo(0)
# --> "12"

? o1.RoundedTo(1)
#--> "12.5"

? o1.RoundedTo(2)
#--> "12.46"

? o1.RoundedTo(3)
#--> "12.456"

? o1.RoundedTo(4)
#--> "12.456"

? o1.RoundedTo(5)
#--> "12.456"

pf()
# Executed in 0.19 second(s)
