# Narrative
# --------
# pr()
#
# Extracted from stzchartest.ring, block #35.
#ERR Error (R14) : Calling Method without definition: charname

load "../../stzBase.ring"

pr()

? StzCharQ("O").Name()	#--> LATIN CAPITAL LETTER O
? StzCharQ("0").Name()	#--> DIGIT ZERO
? StzCharQ("Ⅲ").Name()	#--> ROMAN NUMERAL THREE
? StzCharQ("ↈ").Name()	#--> ROMAN NUMERAL ONE HUNDRED THOUSAND
? StzCharQ("⅜").Name()	#--> VULGAR FRACTION THREE EIGHTHS
? StzCharQ("☗").Name()	#--> BLACK SHOGI PIECE
? StzCharQ("꧌").Name()	#--> JAVANESE PADA PISELEH
? StzCharQ("س").Name()	#--> ARABIC LETTER SEEN

# And we have this fency syntax we can also use

? Q("◐").CharName()	#--> CIRCLE WITH LEFT HALF BLACK
? Q("◰").CharName()	#--> WHITE SQUARE WITH UPPER LEFT QUADRANT
? Q("☁").CharName()	#--> CLOUD

pf()
# Executed in 0.30 second(s) in Ring 1.23
