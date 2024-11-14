load "../stzmax.ring"

? StzStringQ(:Chinese).IsLanguageName()

/*-----------------------

StzLanguageQ("tn") {
	? Name()		#--> tswana
	? DefaultCountry()	#--> south_africa
}

/*-----------------------

? StzLanguageQ(:english).Scripts()
#--> [ "deseret", "latin", "shavian" ]

? StzLanguageQ(:english).ScriptsAbbreviations()
#--> [ "dsrt", "latn", "shaw" ]

/*-----------------------

? _("8").Q.IsLanguageCode()

/*-----------------------

# You can create a stzLanguage object by specifiying:
#	-> language name, abbreviation or ISO code
#	-> the name of a country for which the default language is returned

o1 = new stzLanguage(:Arabic)	# "arabic" is the name of :Arabic language
? o1.Language()

o1 = new stzLanguage(:ar)	# "ar" is the short abbreviation for :Arabic
? o1.Language()

o1 = new stzLanguage(:ara)	# "ara" is the long abbreviation for :Arabic
? o1.Language()

o1 = new stzLanguage("8")	# "8" is the ISO code of :Arabic language
? o1.Language()

o1 = new stzLanguage(:Egypt)	# Creates an :Arabic language object because
? o1.Language()			# this is the default language of country :Egypt

/*----------------------

o1 = new stzLanguage(:Arabic)

? o1.Name()

? o1.QtNumber()

? o1.Abbreviation()
? o1.ShortAbbreviation()
? o1.LongAbbreviation()

? o1.DefaultCountry()
? o1.DefaultCountryName()
? o1.DefaultCountryQtNumber()

? o1.DefaultScript()
? o1.DefaultScriptName()
? o1.DefaultScriptQtNumber()

/*----------------------

# You can access a stzLanguage object and get its data like this:

StzLanguageQ(:Persian) {
	? Name()

	?  QtNumber()

	?  Abbreviation()
	?  ShortAbbreviation()
	?  LongAbbreviation()

	?  DefaultCountry()
	?  DefaultCountryName()
	?  DefaultCountryQtNumber()

	?  DefaultScript()
	?  DefaultScriptName()
	?  DefaultScriptQtNumber()
}
