# Narrative
# --------
# pr()
#
# Extracted from stznamedvarstest.ring, block #15.

load "../../stzBase.ring"


o1 = new stzString(:nation = "Niger") # A named object
? o1.VarName()
#--> nation

o1.RenameIt(:country) # Or SetVarName()
? o1.VarName()
#--> country

pf()
# Executed in 0.01 second(s).
