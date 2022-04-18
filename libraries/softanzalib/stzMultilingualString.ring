# TODO: Review this class on the light of the changes made in stzLocale,
# stzLanguage, stzScript, and stzCountry classes

/*
List of languages by alphabets and nations to implement in SoftanzaLib:
shorturl.at/beDY1

Lists of the charsets supported:
shorturl.at/fBKNO

*/

func ListIsMultingualString(paString)
	oStzList = new stzList(paString)
	return oStzList.IsMultilingualString()

class stzMultilingualString from StzMultiString
		aContent = []
		oHashList

		def init(paMultilingualString)
			if IsList(paMultilingualString) and
			   ListIsMultingualString(paMultilingualString)

				# All abbreviations or names used should be transformed
				# to short abbreviations. This enables using whatever
				# alternative you want in describing the Multilingual string

				for aTrans in paMultilingualString
					if StringIsLongLanguageAbbreviation(aTrans[1])
						aTrans[1] = LongToShortLanguageAbbreviation(aTrans[1])

					but StringIsLanguageName(aTrans[1])
						aTrans[1] = NameToShortLanguageAbbreviation(aTrans[1])
					ok
				next

				aContent = paMultilingualString
				oHashList = new stzHashList(aContent)	
			ok

		def Content()
			return aContent

		def Show()
			oHashList.Show()

		def Languages()
			return oHashList.Keys()

		def Strings()
			return oHashList.Values()

		def tr(pcLang)
			# Check that pcLang corresponds to a supported language name or abbreviation
			if NOT (StringIsLanguageName(pcLang) or
				StringIsLanguageAbbreviation(pcLang))
	
				stzRaise(stzMultilingualStringError(:UnsupportedLanguageNameOrAbbreviation))
			ok

			# Transform the language name or abbreviation to the form
			# supported internally in the class in describing languages
			# (the short abbreviation form)
			if StringIsLongLanguageAbbreviation(pcLang)
				pcLang = LongToShortLanguageAbbreviation(pcLang)

			but StringIsLanguageName(pcLang)
				pcLang = NameToShortLanguageAbbreviation(pcLang)
			ok

			# If the translation has been provided then it is returned
			# otherwise NULL is returned
			return This.Content()[pcLang]

		def en()
			return This.Content()[:en]

		def fr()
			return This.Content()[:fr]

		def ar()
			return This.Content()[:ar]

		def fr_ar()
			cFr = fr()
			cAr = ar()
			return [ cFr, cAr ]

		def ar_fr()
			cAr = ar()
			cFr = fr()
			return [ cAr, cFr ]

		def fr_en()
			cFr = fr()
			cEn = en()
			return [ cFr, cEn ]

		def en_fr()
			cEn = en()
			cFr = fr()
			return [ cEn, cFr ]

		def ar_en()
			cAr = ar()
			cEn = en() 
			return [ cAr, cEn ]

		def en_ar()
			cEn = en()
			cAr = ar()
			return [ cEn, cAr ]

