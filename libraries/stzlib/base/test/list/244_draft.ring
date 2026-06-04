# Narrative
# --------
# #ringqt draft
#
# Extracted from stzlisttest.ring, block #244.
#ERR Error (R11) : Error in class name, class not found: qstringlist

load "../../stzBase.ring"


pr()

aList = [ "Ab", "Im", "Ab", "Cf", "Fd", "Ab", "Cf" ]
o1 = new QStringList()
_nList1Len_ = ring_len(aList)
for _iLoopList1_ = 1 to _nList1Len_
	str = aList[_iLoopList1_]
	o1.append(str)
next

? o1.indexof("Ab", 2)
#--> 2

pf()
# Executed in almost 0 second(s).
