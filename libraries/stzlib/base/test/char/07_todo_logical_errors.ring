# Narrative
# --------
#
# Extracted from stzchartest.ring, block #7.

load "../../stzBase.ring"


pr()

? StzCharQ(dec("0x10481")).Content()
#--> 𐒁

? Q("Schöne Grüße").Length() # means "Kind Regards" in german
#--> 12

? StzUnicodeDataQ().CharByName("OSMANYA LETTER BA")
#--> 𐒁

? StzCharQ("ҁ").Name()
#--> CYRILLIC SMALL LETTER KOPPA

? StzCharQ("𐒁").Content()
#--> 𐒁

? Q("𐒁").CharName()
#--> OSMANYA LETTER BA

? StzCharQ("OSMANYA LETTER BA").Content()
#--> 𐒁

pf()
# Executed in 0.03 second(s) in Ring 1.27 (Backed by StzEngine)
# Executed in 0.28 second(s) in Ring 1.23
# Executed in 1.93 second(s) in Ring 1.20
