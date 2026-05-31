# Narrative
# --------
# pr()
#
# Extracted from stzObjectTest.ring, block #30.

load "../../../stzBase.ring"


o1 = new stzGrid([ [1,2,3], [4,5,6], [7,8,9] ])
? o1.Is(:StzGrid) # from stzObject based on the name of the class
? o1.IsAGrid() # used by natural code in stzChainOfTruth

pf()
# Executed in 0.03 second(s)
