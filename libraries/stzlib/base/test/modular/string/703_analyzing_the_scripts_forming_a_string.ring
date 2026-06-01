# Narrative
# --------
# #narration ANALYZING THE SCRIPTS FORMING A STRING
#
# Extracted from stzStringTest.ring, block #703.

load "../../../stzBase.ring"


pr()

StzStringQ("__b和平س__a__و") {

	? ContainsLettersInScript(:Latin)
	#--> TRUE

	? CharsWXT( ' Q(@char).IsLatin() ')
	#--> [ "b", "a" ]

	? ContainsLettersInScript(:Arabic)
	#--> TRUE

	? CharsWXT( ' Q(@char).IsArabic() ')
	#o--> [ "س", "و" ]

	? ContainsLettersInScript(:Han)
	#--> TRUE

	? CharsWXT( ' StzCharQ(@char).IsHanScript() ')
	#--> [ "和", "平" ]

	? ContainsCharsInScript(:Common)
	#--> TRUE

	? CharsWXT( ' StzCharQ(@char).IsCommonScript() ')
	#--> [ "_", "_", "_", "_", "_", "_" ]

	#NOTE that if you say
	? ContainsLettersInScript(:Common)	# or
	? ContainsLettersInScript(:Unkowan)
	# you get FALSE because there is no sutch letter that has a script
	# 'common'. In other terms, any letter in the world has to belong
	# to a knowan script.
}

pf()
# Executed in 0.57 second(s) in Ring 1.22
# Executed in 0.61 second(s) in Ring 1.18
