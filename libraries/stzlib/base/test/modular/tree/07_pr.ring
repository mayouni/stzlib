# Narrative
# --------
# pr()
#
# Extracted from stzTreeTest.ring, block #7.

load "../../../stzBase.ring"


? IsValidNodePath('[:root][:node3]')
#--> TRUE

? IsValidItemPath('[:root][:node3][1]')
#--> TRUE

? IsListOfValidNodesPaths([ '[:root][:node3]', '[:root][:node3][:node31]' ])
#--> TRUE

? IsListOfValidItemsPaths([ '[:root][:node3][1]', '[:root][:node2][3]' ])
#--> TRUE

pf()
# Executed in 0.03 second(s) in Ring 1.22
