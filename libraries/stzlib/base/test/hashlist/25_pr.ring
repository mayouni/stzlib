# Narrative
# --------
# pr()
#
# Extracted from stzhashlisttest.ring, block #25.

load "../../stzBase.ring"


o1 = new stzHashList([ :name = "mansour", :age = 45, :job = "programmer" ])

? o1.ContainsKeys([:name, :age, :job])
#--> TRUE

o1.RemoveByKey(:age)
? o1.Content()
#--> [ :name = "mansour", :job = "programmer" ]

? o1.RemovePairByKeyQ(:job).Content()
#--> [ :name = "mansour" ]

pf()
# Executed in 0.03 second(s)
