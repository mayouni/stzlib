# Narrative
# --------
# pr()
#
# Extracted from stzStringTest.ring, block #701.

load "../../../stzBase.ring"


# In Softanza both n and N chars correspond to the letter "N"

o1 = new stzString("Adoption of the plan B")
? o1.ContainsTheLetters([ "N", "b" ])
#--> TRUE

pf()
# Executed in 0.02 second(s).
