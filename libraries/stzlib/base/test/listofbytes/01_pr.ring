# Narrative
# --------
# pr()
#
# Extracted from stzlistofbytestest.ring, block #1.

load "../../stzBase.ring"


o1 = new stzListOfBytes("で")
? o1.ToHex() 
#--> e381a7

#TODO --> (\xE3 \x81 \xa7 in UTF-8)

pf()
#--> Executed in 0.05 second(s)
