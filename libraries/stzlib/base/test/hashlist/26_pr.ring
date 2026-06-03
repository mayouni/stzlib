# Narrative
# --------
# pr()
#
# Extracted from stzhashlisttest.ring, block #26.

load "../../stzBase.ring"


o1 = new stzHashList([ :name = "Hussein", :age = 1, :grandftaher = "Hussein" ])
o1.RemovePairsByValue("Hussein")
? o1.Content() #--> [ :age = 1 ]

pf()
# Executed in 0.04 second(s)
