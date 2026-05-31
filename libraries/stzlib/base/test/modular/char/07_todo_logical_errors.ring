# Narrative
# --------
# TODO : LOGICAL ERRORS
#
# Extracted from stzchartest.ring, block #7.

load "../../../stzBase.ring"


pr()

? StzCharQ("0x10481").Content() #--> TODO: ERR, should be "𐒁"
#--> ҁ

? Q("Schöne Grüße").Length() # means "Kind Regards" in german
#--> 12

? StzUnicodeDataQ().CharByName("OSMANYA LETTER BA") #ERRor! Should be 𐒁
#--> ҁ

? StzCharQ("ҁ").Name()
#--> CYRILLIC SMALL LETTER KOPPA

//? StzCharQ("𐒁") #TODO-ERROR
#--> Can't create char object!

? Q("𐒁").CharName() #TODO-ERROR: correct it to be OSMANYA LETTER BA
#--> QUESTION MARK

? StzCharQ("OSMANYA LETTER BA").Content()
#--> ҁ

pf()
# Executed in 0.28 second(s) in Ring 1.23
# Executed in 1.93 second(s) in Ring 1.20
