# Narrative
# --------
# pr()
#
# Extracted from stzjsontest.ring, block #1.

load "../../stzBase.ring"

pr()

oByteArray = new QByteArray()
oByteArray.append("XYZ")

? QByteArrayToString(oByteArray)
#--> XYZ

pf()
# Executed in 0.03 second(s) in Ring 1.22
