# Narrative
# --------
# pr()
#
# Extracted from stzchartest.ring, block #24.

load "../../../stzBase.ring"


? Q("✓").CharName() 			#--> CHECK MARK
? StzCharQ("CHECK MARK").Content() 	#--> ✓
? CQ("NOT CHECK MARK").Content()	#--> ⍻

? StzCharQ("Ã").IsLatinDiacritic() 	#--> TRUE
# To get the list of latin diacritics use LatinDiacritics()

? StzCharQ(" ").CharType() #--> separator_space

pf()
# Executed in 0.17 second(s) in Ring 1.23
