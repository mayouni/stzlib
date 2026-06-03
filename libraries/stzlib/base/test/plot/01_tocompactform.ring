# Narrative
# --------
# pr()
#
# Extracted from stzPlotTest.ring, block #1.
#ERR Error (R20) : Calling function with extra number of parameters

load "../../stzBase.ring"

pr()

# Basic compact form
oNum = new stzNumber(1_290_800_280)
? oNum.ToCompactForm()
#--> 1.3B

? oNum.ToKForm()
#--> 1290800.3K

? oNum.ToMForm()
#--> 1290.8M

? oNum.ToBForm()
#--> 1.3B

pf()
# Executed in 0.04 second(s) in Ring 1.23
# Executed in 0.07 second(s) in Ring 1.22
