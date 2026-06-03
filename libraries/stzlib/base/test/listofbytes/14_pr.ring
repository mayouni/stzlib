# Narrative
# --------
# pr()
#
# Extracted from stzlistofbytestest.ring, block #14.

load "../../stzBase.ring"


o1 = new stzListOfBytes("で")

? o1.ToHex()
#--> 0xe381a7

? o1.ToHexWithoutPrefix()
#--> e381a7

? o1.Hexcodes()
#--> [ "0xe3", "0x81", "0xa7" ]

? o1.HexcodesWithoutPrefix()
#--> [ "e3", "81", "a7" ]

? o1.ToHexUTF8()
#--> \xe3 \x81 \xa7

pf()
# Executed in 0.02 second(s) in Ring 1.21
# Executed in 0.05 second(s) in Ring 1.19
