# Narrative
# --------
# pr()
#
# Extracted from stzchartest.ring, block #96.

load "../../stzBase.ring"

pr()

o1 = new stzChar("Σ")
? o1.IsLowercase() #--> FALSE
? o1.IsUPPERcase() #--> TRUE
? o1.CharCase() + NL #--> uppercase

o1 = new stzChar("σ")
? o1.IsLowercase() #--> TRUE
? o1.IsUppercase() #--> FALSE
? o1.CharCase() #--> lowercase

pf()
# Executed in 0.01 second(s) in Ring 1.23
