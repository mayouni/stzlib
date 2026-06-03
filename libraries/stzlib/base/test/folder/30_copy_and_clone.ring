# Narrative
# --------
# Copy and Clone
#
# Extracted from stzfoldertest.ring, block #30.

load "../../stzBase.ring"


pr()

o1 = new stzFolder("C:\Windows\System32")
o2 = o1.Copy() # Or Clone()

# Original path
? o1.Path()
#--> C:\Windows\System32

# Copy path
? o2.Path()
#--> C:\Windows\System32

pf()
# Executed in almost 0 second(s) in Ring 1.22
