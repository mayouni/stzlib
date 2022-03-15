load "stzlib.ring"

//? IsLanguageIdentificationList([ :language = "ar", :country = "TN", :script = "bb" ])
o1 = new stzString("JmC")
//? o1.IsValidLanguageAbbreviation()

? IsLanguageAbbreviation("JmC")
? IsCountryabbreviation("TuN")

for i = 1 to len(LocaleCountriesXT())
	? "" + LocaleCountriesXT()[i][1] + " --> " + LocaleCountriesXT()[i][2]
Next

