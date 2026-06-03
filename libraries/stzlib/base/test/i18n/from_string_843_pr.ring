# Narrative
# --------
# pr()
#
# Extracted from stzStringTest.ring, block #843.

load "../../stzBase.ring"

pr()

o1 = new stzString("105")
? o1.IsLanguageNumber()
#--> TRUE

? StzLanguageQ("105").Name()
#--> sindhi

? StzLanguageQ("105").DefaultCountry()
#--> pakistan

pf()
# Executed in 0.01 second(s).
