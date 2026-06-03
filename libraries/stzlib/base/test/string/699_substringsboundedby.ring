# Narrative
# --------
# pr()
#
# Extracted from stzStringTest.ring, block #699.

load "../../stzBase.ring"

pr()

o1 = new stzString("amd[bmi]kmc[ddi]kc")
? o1.SubStringsBoundedBy([ "[", "]" ])
#--> [ "bmi", "ddi" ]

pf()
# Executed in 0.01 second(s).
