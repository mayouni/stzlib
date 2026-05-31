# Narrative
# --------
# pr()
#
# Extracted from stzlocaletest.ring, block #68.

load "../../../stzBase.ring"


# Defining a locale from two or three parameters
o1 = new stzLocale([ :Language = "french", :Country = "Mali" ])
? o1.Country() 		#--> mali
? o1.Langauge()		#--> french
? o1.Script() + NL	#--> latin

o1 = new stzLocale([ :Language = "ara", :Script = "arabic" ])
? o1.Country()		#--> egypt
? o1.Langauge()		#--> arabic
? o1.Script() + NL	#--> arabic

o1 = new stzLocale([ :Country = "brazil", :Script = "latin" ])
? o1.Country()		#--> brazil
? o1.Langauge()		#--> portuguese
? o1.Script() + NL	#--> latin

o1 = new stzLocale([ :Country = "Spain", :Language = "Spanish", :Script = "latin" ])
? o1.Country()		#--> spain
? o1.Langauge()		#--> spanish
? o1.Script()		#--> latin

pf()
# Executed in 0.12 second(s) in Ring 1.23
