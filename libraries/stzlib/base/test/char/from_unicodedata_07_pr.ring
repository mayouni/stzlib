# Narrative
# --------
# pr()
#
# Extracted from stzunicodedatatest.ring, block #7.
#ERR Error (C22) : Function redefinition, function is already defined!

load "../../stzBase.ring"

pr()

? StzCharQ(610).Content()
#--> ɢ

? StzCharQ("0x0262").Content()
#--> ɢ

? StzCharQ("LATIN LETTER SMALL CAPITAL G").Content()
# #--> ɢ

? StzCharQ("0x2601").Content()
#--> ☁

? StzCharQ(12500).Content()
#--> ピ

pf()
# Executed in 0.07 second(s) in Ring 1.23
# Executed in 0.38 second(s) in Ring 1.20
