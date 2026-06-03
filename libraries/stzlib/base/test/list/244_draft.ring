# Narrative
# --------
# #ringqt draft
#
# Extracted from stzlisttest.ring, block #244.

load "../../stzBase.ring"


pr()

aList = [ "Ab", "Im", "Ab", "Cf", "Fd", "Ab", "Cf" ]
o1 = new QStringList()
for str in aList
	o1.append(str)
next

? o1.indexof("Ab", 2)
#--> 2

pf()
# Executed in almost 0 second(s).
