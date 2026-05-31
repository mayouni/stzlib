# Narrative
# --------
# pr()
#
# Extracted from stzObjectTest.ring, block #17.

load "../../../stzBase.ring"


? Q(StzTypesXT()).IsHashList()
#--> TRUE

? StzHashListQ(StzTypesXT()).FindValue('stzchars')
#--> 17

pf()
#--> Executed in 0.06 second(s)
