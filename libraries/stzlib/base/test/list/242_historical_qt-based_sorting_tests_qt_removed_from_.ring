# Narrative
# --------
# HISTORICAL: Qt-based sorting tests (Qt removed from Softanza)
#
# Extracted from stzlisttest.ring, block #242.

load "../../stzBase.ring"


pr()

aList = [ "5", "7", "5", "5", "4", "7" ]

o1 = new QStringList()
for i = 1 to len(aList)
	o1.append(aList[i])
next

o1.sort()
? QStringListContent(o1)
#--> [ "4", "5", "5", "5", "7", "7" ]

pf()
# Executed in almost 0 second(s) in Ring 1.21
# Executed in 0.03 second(s) in Ring 1.17
