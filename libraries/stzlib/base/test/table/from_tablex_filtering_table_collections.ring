# Narrative
# --------
# Filtering table collections
#
# Extracted from stztablextest.ring, block #37.

load "../../stzBase.ring"


pr()

aTables = [
	new stzTable([[:A,:B],[1,2]]),
	new stzTable([[:A,:B,:C],[1,2,3]]),
	new stzTable([[:A,:B,:C,:D],[1,2,3,4]])
]

oTx = new stzTablex("{cols(>2)}")
aFiltered = oTx.MatchingTablesIn(aTables) #ERR

? len(aFiltered)
#--> 2 (tables with 3 and 4 columns)

pf()
