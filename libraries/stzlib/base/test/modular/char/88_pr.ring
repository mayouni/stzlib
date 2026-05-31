# Narrative
# --------
# pr()
#
# Extracted from stzchartest.ring, block #88.

load "../../../stzBase.ring"


? StzCharQ(",").Name()	#--> COMMA
? StzCharQ("⅀").Name()	#--> DOUBLE-STRUCK N-ARY SUMMATION
? StzCharQ("ظ").Name()	#--> ARABIC LETTER ZAH
? StzCharQ("ܞ") .Name()	#--> SYRIAC LETTER YUDH HE

? StzCharQ("డ").Name()	#--> TELUGU LETTER DDA
? StzCharQ("ল").Name()	#--> BENGALI LETTER LA
? StzCharQ("Ϡ").Name()	#--> GREEK LETTER SAMPI
? StzCharQ("Ж").Name()	#--> CYRILLIC CAPITAL LETTER ZHE

//? StzCharQ("经").Name()
#--> Can't proceed! The name of this char does not
# exist in the local unicode database.

pf()
# Executed in 0.23 second(s) in Ring 1.23
