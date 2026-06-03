# Narrative
# --------
# pr()
#
# Extracted from stznumbertest.ring, block #50.

load "../../stzBase.ring"

pr()

o1 = new stzNumber([ 55993400908134, :Round = 5 ])
? o1.Round()
#--> 5

? o1.Sine()
#--> "-0.99986"

? o1.Cosine()
#--> "-0.01644"

? o1.Tangent()
#--> "60.82558"

? o1.Cotangent()
#--> "0.01644"

pf()
# Executed in 0.08 second(s)
