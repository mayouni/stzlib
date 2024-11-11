/* TODO

A MultiString is an imaginary string with more then one value.

It's used in many practical situations, like for example:
	
	1. Finding a word, despite miss-spellings

	2. Finding words with the same meaning

	3. Finding antonyms

	4. Translating strings in many languages (see stzMultiLangString)

	4. And many other advanced scenarios in natural language processing

*/

#TODO: Review this class on the light of the changes made in stzLocale,
# stzLanguage, stzScript, and stzCountry classes

/*
List of languages by alphabets and nations to implement in SoftanzaLib:
shorturl.at/beDY1

Lists of the charsets supported:
shorturl.at/fBKNO

*/

func StzMultilingualStringQ(paString)
	return new stzMultiLangString(paString)

	func StzMultiStringQ(paString)
		return StzMultilingualStringQ(paString)

func IsMultingualString(paString)
	oStzList = new stzList(paString)
	return oStzList.IsMultilingualString()

	func @IsMultingualString(paString)
		return IsMultingualString(paString)

	func IsMultiString(paString)
		return IsMultingualString(paString)

	func @IsMultiString(paString)
		return IsMultingualString(paString)

class stzMultilingualString from stzMultiString

class stzMultiString
		aContent = []
		oHashList

		def init(paMultilingualString)

			if isList(paMultilingualString) and
			   @IsMultingualString(paMultilingualString)

				# All abbreviations or names used should be transformed
				# to short abbreviations. This enables using whatever
				# alternative you want in describing the Multilingual string

				for aTrans in paMultilingualString
					aTrans[1] = StzLanguageQ(aTrans[1]).ShortAbbreviation()
				next

				aContent = paMultilingualString
				oHashList = new stzHashList(aContent)	
			ok

		def Content()
			return aContent

		def Value()
			return Content()

		def Show()
			oHashList.Show()

			#< @FuntionMisspelledForm
	
			def Shwo()
				This.Show()
	
			#>

		def Languages()
			return oHashList.Keys()

		def Strings()
			return oHashList.Values()

		def tr(pcLang)
			# Check that pcLang corresponds to a supported language name or abbreviation
			if NOT ( StringIsLanguageName(pcLang) or
			         StringIsLanguageAbbreviation(pcLang) )
	
				StzRaise(stzMultilingualStringError(:UnsupportedLanguageNameOrAbbreviation))
			ok

			# Transform the language name or abbreviation to the form
			# supported internally in the class in describing languages
			# (the short abbreviation form)
			pcLang = StzLanguageQ(pcLang).ShortAbbreviation()

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

