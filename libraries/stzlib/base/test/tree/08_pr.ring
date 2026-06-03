# Narrative
# --------
# pr()
#
# Extracted from stzTreeTest.ring, block #8.

load "../../stzBase.ring"


? IsValidNodePath('[:root][:node2][2]')
#--> FALSE

? IsValidNodePath('[:root][:node2][:node21]')
#--> TRUE

? IsValidItemPath('[:root][:node2][2]')
#--> TRUE

? IsValidItemPath('[:root][:node2][:node21]')
#--> FALSE

pf()
# Executed in 0.02 second(s) in Ring 1.22
