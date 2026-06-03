# Narrative
# --------
# pr()
#
# Extracted from stzlistofbytestest.ring, block #12.

load "../../stzBase.ring"


o1 = new QByteArray()
o1.append("で")
? o1.tohex().data()
#--> e381a7

# To get this format:  # \xE3 \x81 \xA7 (in UTF-8)
# use the ToHexUTF8() from stzListOfBytes() ~> See example below...

pf()
# Executed in almost 0 second(s).
