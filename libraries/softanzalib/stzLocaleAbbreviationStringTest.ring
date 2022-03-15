load "stzlib.ring"

/*-----------------

? StzCountryQ(:Spain).Abbreviation()
? StzLanguageQ(:spanish).Abbreviation()

/*-----------------
*/
o1 = new Qlocale("ar-Latn_ESdjfdjfdjf")
//o1 = new QLocale("ES")
? o1.name()
? o1.country()

? "-------"
/*-----------------

? "--------------"

? StzLocaleQ([ :Language = :Spanish, :Country = :Spain, :Script = :Latn ]).Abbreviation()

/*-----------------

? _("arab").Q.IsScriptAbbreviation()
? _("TN").Q.IsCountryAbbreviation()

/*-----------------

o1 = new stzLocaleAbbreviationString("ar_arab_TN")
? o1.Abbreviation()

? o1.LanguageAbbreviation()
? o1.ScriptAbbreviation()
? o1.CountryAbbreviation()

/*-----------------

? "--------"

o1 = new stzLocaleAbbreviationString("ar_latin_ES")
? o1.Abbreviation()

? o1.LanguageAbbreviation()
? o1.ScriptAbbreviation()
? o1.CountryAbbreviation()
