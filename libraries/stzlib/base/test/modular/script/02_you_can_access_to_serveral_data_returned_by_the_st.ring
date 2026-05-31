# Narrative
# --------
# # You can access to serveral data returned by the stzScript object like this:
#
# Extracted from stzscripttest.ring, block #2.

load "../../../stzBase.ring"


StzScriptQ(:Arabic) {
	? Script()	#--> arabic
	? Content()	#--> arabic

	? Number()	# "1"
	
	? Name()	#--> arabic
	
	? Abbreviation() #--> Arab

	? DefaultLanguage() #--> arabic
	? DefaultLanguageName() #--> arabic
	
	? DefaultLanguageNumber() #--> "8"
	
	? DefaultCountry() #--> egypt
	? DefaultCountryName() #--> egypt
	? DefaultCountryNumber() #--> "64"

}
