load "../stzmax.ring"

/*-----------------------

# You can create a script object bu specifying its name, abbreviation, or code

o1 = new stzScript(:Arabic)	# :Arabic is the name of the arabic script
? o1.Name() #--> arabic

o1 = new stzScript(:Arab)	# :Arab is the abbreviation of the arabic script
? o1.Name() #--> arabic

o1 = new stzScript("1")		# "1" is the code of the script
? o1.Name() #--> arabic

/*-----------------------

# You can access to serveral data returned by the stzScript object like this:

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

