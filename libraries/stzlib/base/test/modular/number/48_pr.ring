# Narrative
# --------
# pr()
#
# Extracted from stznumbertest.ring, block #48.

load "../../../stzBase.ring"


? CurrentRound() # Currrent round on the program
#--> 2

o1 = new stzNumber("-12.4521")

? o1.Round() # Round of the object (infered here from the decimal part .4532)
#--> 4

? o1.Value() # Or NumericValue() ~> Sensitive to the currend round on the program (2)
#--> -12.45

? o1.StringValue() # Or Content() ~> Sensitive to the current round on the stzNumber object (4)
#--> "-12.4521"

pf()
# Executed in 0.05 second(s)
