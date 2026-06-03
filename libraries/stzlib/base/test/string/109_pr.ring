# Narrative
# --------
# pr()
#
# Extracted from stzStringTest.ring, block #109.

load "../../stzBase.ring"


? Q('U+0649').IsHexUnicode() 	#--> TRUE
? StzCharQ("ڢ").HexUnicode() 	#--> U+06A2
? QQ('U+0649').Content() 	#--> ى
? QQ('U+06A2').Content() 	#--> ڢ
? HexUnicodeToUnicode('U+06A2')	#--> 1698
? UnicodeToHexUnicode(1698)	#--> U+06A2

pf()
# Executed in 1.20 second(s)
