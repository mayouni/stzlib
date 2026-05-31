# Narrative
# --------
# #ring #bug?
#
# Extracted from stztabletest.ring, block #101.

load "../../../stzBase.ring"


pr()

aList = [ "Aaa", "Bbb", "Ccc" ]
? @@( aList["emm"] )
#--> ""

aList = [ :name = "Maiga", :job = "programmer" ]
? @@( aList[2]["emm"] )
#--> #--> ""

pf()
# Executed in 0.02 second(s)
