# Narrative
# --------
# pr()
#
# Extracted from stzlistofbytestest.ring, block #8.

load "../../../stzBase.ring"


o1 = new stzListOfBytes("mЖ丽")
? o1.Range(1, 1)
#--> m

? o1.Range(2, 2) # Same As o1.Section(2, 3)
#--> Ж

? o1.Section(4,:End)
#--> 丽

pf()
#--> Executed in 0.04 second(s)
