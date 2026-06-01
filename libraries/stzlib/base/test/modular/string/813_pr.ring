# Narrative
# --------
# pr()
#
# Extracted from stzStringTest.ring, block #813.

load "../../../stzBase.ring"


str = "منصوريّات"
? StringAlignXT(str, 30, ".", :Left)
? StringAlignXT(str, 30, ".", :Right)
? StringAlignXT(str, 30, ".", :Center)
? StringAlignXT(str, 30, ".", :Justified)

#-->
# ......................منصوريّات
# منصوريّات......................
# ...........منصوريّات...........
# م....ن...ص...و...ر...يّ...ا...ت

pf()
# Executed in 0.05 second(s).
