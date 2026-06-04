# Narrative
# --------
# pr()
#
# Extracted from stznumbertest.ring, block #58.

load "../../stzBase.ring"

pr()

o1 = new stzNumber("23500.124")

? o1.Round()
#--> 3

? o1.MaxRound()
#--> 6

o1.RoundTo(:Max)
? o1.Content()
#--> 23500.12399999999980

pf()
# Executed in 0.06 second(s)
