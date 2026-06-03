# Narrative
# --------
# #ringqt code draft
#
# Extracted from stzlisttest.ring, block #251.
#ERR Error (R11) : Error in class name, class not found: qstringlist

load "../../stzBase.ring"


pr()

aList = [ "A", "*", "B", "C", "D", "*", "E" ]

o1 = new QStringList()

for i = 1 to 7
    o1.append(aList[i])
next

? o1.indexof("*", 0) + 1 # To get and Ring-index.
#--> 2

? o1.indexof("*", 3) + 1
#!--> 6

pf()
