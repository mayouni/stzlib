# Narrative
# --------
# pr()
#
# Extracted from stzchartest.ring, block #53.
#ERR Error (R14) : Calling Method without definition: inverted

load "../../stzBase.ring"

pr()

? StzCharQ("V").Inverted()	#--> "Ʌ"
? StzCharQ("X").Inverted()	#--> "X"
? ""
? StzCharQ("☗").Inverted()	#--> "⛊"
? StzCharQ("❝").Inverted()	#--> "❞"
? StzCharQ("&").Inverted()	#--> "⅋"
? ""
? StzCharQ("꧌").Inverted()		#--> "꧍"

pf()
# Executed in 0.06 second(s) in Ring 1.23
