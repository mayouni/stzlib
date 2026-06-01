# Narrative
# --------
# pr()
#
# Extracted from stzStringTest.ring, block #472.

load "../../../stzBase.ring"


? QQ("ر").StzType()
#--> stzChar

? @@( QQ("ر").UnicodeDirectionNumber() )
#--> "13"

? QQ("ر").IsRightToLeft()
#--> TRUE

pf()
# Executed in 0.04 second(s).
