# Narrative
# --------
# pr()
#
# Extracted from stzhashlisttest.ring, block #27.

load "../../../stzBase.ring"


o1 = new stzHashList([ :name = "Hussein", :age = 1, :grandftaher = "Hussein" ])
o1.AddPair( :grandmother = "Arem" )
o1.Show()
#--> 'name': "Hussein"
#    'age': 1
#    'grandftaher': "Hussein"
#    'grandmother': "Arem"

pf()
