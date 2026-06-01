# Narrative
# --------
# pr()
#
# Extracted from stzStringTest.ring, block #403.

load "../../../stzBase.ring"


o1 = new stzString('{ This[ @i - 3 ] = This[ @i + 3 ] }')
? o1.NumbersComingAfter("@i")
#--> [ "-3", "3" ]

? o1.NumbersComingAfterQ("@i").NumbrifyQ().Smallest()
#--> -3

? o1.NumbersComingAfterQ("@i").NumberifyQ().Greatest()
#--> 3

pf()
# Executed in 0.23 second(s) in Ring 1.21
