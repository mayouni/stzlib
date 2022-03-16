# Uses the data available here:
# https://github.com/Alir3z4/stop-words

### Stopwords

_cStopwordsStatus = :MustNotBeRemoved	# or :MustBeRemoved

func StopWordsStatus()
	return _cStopWordsStatus

func StopWordsMustBeRemoved()
	_cStopWordsStatus = :MustBeRemoved

func StopWordsMustNotBeRemoved()
	_cStopWordsStatus = :MustNotBeRemoved

func SetStopWordsStatusTo(pcStatus)
	if pcString = :MustBeRemoved
		StopWordsMustBeRemoved()

	but pcString = :MustNotBeRemoved
		StopWordsMustNotBeRemoved()
	ok

	func SetStopWordsStatus(pcStatus)
		SetStopWordsStatusTo(pcStatus)

func StopWords()
	cTemp = ""
	i = 0
	
	aLang = AvailbaleLanguagesForStopWords()
	for cLang in aLang
		i++
		cTemp += "StopWordsIn(:" + cLang + ")"
		if i < len(aLang)
			cTemp += ", "
		ok
	next

	cCode = 'aResult = ListsMerge([ ' + cTemp + ' ])'

	eval(cCode)
	return aResult

	#< @FunctionFluentForm

	func StopWordsQ()
		return StopWordsQR(:stzList)
	
	func StopWordsQR(pcReturnType)
		if isList(pcReturnType) and Q(pcReturnType).IsReturnedParamList()
			pcReturnType = pcReturnType[2]
		ok

		switch pcReturnType
		on :stzList
			return new stzList(StopWords())

		on :stzListOfStrings
			return new stzListOfStrings(StopWords())

		other
			stzRaise("Unsupported return type!")
		off

	#>

func StopWordsLanguages()
	return [
		:Arabic, :Bulgarian, :Catalan, :Czech, : Danish, :Dutch,
		:English, :Finnish, :French, :German, :Gujarati, :Hindi,
		:Hebrew, :Hungarian, :Indonesian, :Malaysian, :Italian,
		:Norwegian, :Polish, :Portuguese, :Romanian, :Russian,
		:Slovak, :Spanish, :Swedish, :Turkish, :Ukrainian,
		:Vietnamese, :Persian
	       ]
		
	#< @FunctionFluentForm

	func StopWordsLanguagesQ()
		return StopWordsLanguagesQR(:stzList)
	
	func StopWordsLanguagesQR(pcReturnType)
		if isList(pcReturnType) and Q(pcReturnType).IsReturnedParamList()
			pcReturnType = pcReturnType[2]
		ok

		switch pcReturnType
		on :stzList
			return new stzList(StopWordsLanguages())

		on :stzListOfStrings
			return new stzListOfStrings(StopWordsLanguages())

		other
			stzRaise("Unsupported return type!")
		off

	#>

	#< @FunctionAlternativeForms

	func StopWordsAvailableLanguages()
		return StopWordsLanguages()

		func StopWordsAvailableLanguagesQ()
			return StopWordsAvailableLanguagesQR(:stzList)
		
		func StopWordsAvailableLanguagesQR(pcReturnType)
			if isList(pcReturnType) and Q(pcReturnType).IsReturnedParamList()
				pcReturnType = pcReturnType[2]
			ok

			switch pcReturnType
			on :stzList
				return new stzList(StopWordsAvailableLanguages())
	
			on :stzListOfStrings
				return new stzListOfStrings(StopWordsAvailableLanguages())
	
			other
				stzRaise("Unsupported return type!")
			off

	func AvailbaleLanguagesForStopWords()
		return StopWordsLanguages()

		func AvailbaleLanguagesForStopWordsQ()
			return AvailbaleLanguagesForStopWordsQR(:stzList)
		
		func AvailbaleLanguagesForStopWordsQR(pcReturnType)
			if isList(pcReturnType) and Q(pcReturnType).IsReturnedParamList()
				pcReturnType = pcReturnType[2]
			ok

			switch pcReturnType
			on :stzList
				return new stzList(AvailbaleLanguagesForStopWords())
	
			on :stzListOfStrings
				return new stzListOfStrings(AvailbaleLanguagesForStopWords())
	
			other
				stzRaise("Unsupported return type!")
			off

	#>

func StopWordsIn(pcLang)
	switch pcLang
	on :Arabic
		return ArabicStopWords()
	on :Bulgarian
		return BulgarianStopWords()

	on :Catalan
		return CatalanStopWords()

	on :Czech
		return CzechStopWords()

	on :Danish
		return DanishStopWords()

	on :Dutch
		return DutchStopWords()

	on :English
		return EnglishStopWords()

	on :Finnish
		return FinnishStopWords()

	on :French
		return FrenchStopWords()

	on :German
		return GermanStopWords()

	on :Gujarati
		return GujaratiStopWords()

	on :Hindi
		return HindiStopWords()

	on :Hebrew
		return HebrewStopWords()

	on :Hungarian
		return HungarianStopWords()

	on :Indonesian
		return IndonesianStopWords()

	on :Malaysian
		return MalaysianStopWords()

	on :Italian
		return ItalianStopWords()

	on :Norwegian
		return NorwegianStopWords()

	on :Polish
		return PolishStopWords()

	on :Portuguese
		return PortugueseStopWords()

	on :Romanian
		return RomanianStopWords()

	on :Russian
		return RussianStopWords()

	on :Slovak
		return SlovakStopWords()

	on :Spanish
		return SpanishStopWords()

	on :Swedish
		return SwedishStopWords()

	on :Turkish
		return TurkishStopWords()

	on :Ukrainian
		return UkrainianStopWords()

	on :Vietnamese
		return VietnameseStopWords()

	on :Persian or :Farsi
		return PersianStopWords()
	other
		stzRaise("Sorry! Stopwords are unavailable for this language.")
	off

	#< @FunctionFluentForm

	func StopWordsInQ(pcLang)
		return StopWordsInQR(pcLang, :stzList)
		
	func StopWordsInQR(pcLang, pcReturnType)
		if isList(pcReturnType) and Q(pcReturnType).IsReturnedParamList()
			pcReturnType = pcReturnType[2]
		ok

		switch pcReturnType
		on :stzList
			return new stzList(StopWordsIn(pcLang))
	
		on :stzListOfStrings
			return new stzListOfStrings(StopWordsIn(pcLang))
	
		other
			stzRaise("Unsupported return type!")
		off
	#>

	#< @FunctionAlternativeForm

	func StopWordsOf(pcLang)
		return StopWordsIn(pcLang)

		func StopWordsOfQ(pcLang)
			return StopWordsOfQR(pcLang, :stzList)
		
		func StopWordsOfQR(pcLang, pcReturnType)
			if isList(pcReturnType) and Q(pcReturnType).IsReturnedParamList()
				pcReturnType = pcReturnType[2]
			ok

			switch pcReturnType
			on :stzList
				return new stzList(StopWordsOf(pcLang))
		
			on :stzListOfStrings
				return new stzListOfStrings(StopWordsOf(pcLang))
		
			other
				stzRaise("Unsupported return type!")
			off

	#>

func ArabicStopWords()
	return _acArabicStopwords

	#< @FunctionFluentForms

	func ArabicStopWordsQ(pcLang)
		return ArabicStopWordsQR(pcLang, :stzList)
		
	func ArabicStopWordsQR(pcLang, pcReturnType)
		if isList(pcReturnType) and Q(pcReturnType).IsReturnedParamList()
			pcReturnType = pcReturnType[2]
		ok

		switch pcReturnType
		on :stzList
			return new stzList(ArabicStopWords(pcLang))
		
		on :stzListOfStrings
			return new stzListOfStrings(ArabicStopWords(pcLang))
		
		other
				stzRaise("Unsupported return type!")
		off

	#>


func EnglishStopWords()

	cEnglishStopWords = EnglishStopWordsInString()
	acResult = StzStringQ( cEnglishStopWords ).RemoveAllQ(TAB).SplitQ(:Using = NL).Content()

	return acResult

	#< @FunctionFluentForms

	func EnglishStopWordsQ(pcLang)
		return EnglishStopWordsQR(pcLang, :stzList)
		
	func EnglishStopWordsQR(pcLang, pcReturnType)
		if isList(pcReturnType) and Q(pcReturnType).IsReturnedParamList()
			pcReturnType = pcReturnType[2]
		ok

		switch pcReturnType
		on :stzList
			return new stzList(EnglishStopWords(pcLang))
		
		on :stzListOfStrings
			return new stzListOfStrings(EnglishStopWords(pcLang))
		
		other
				stzRaise("Unsupported return type!")
		off

	#>

func BulgarianStopWords()

func CatalanStopWords()

func CzechStopWords()

func DanishStopWords()

func DutchStopWords()

func FinnishStopWords()

func FrenchStopWords()

func GermanStopWords()

func GujaratiStopWords()

func HindiStopWords()

func HebrewStopWords()

func HungarianStopWords()

func IndonesianStopWords()

func MalaysianStopWords()

func ItalianStopWords()

func NorwegianStopWords()

func PolishStopWords()

func PortugueseStopWords()

func RomanianStopWords()

func RussianStopWords()

func SlovakStopWords()

func SpanishStopWords()

func SwedishStopWords()

func TurkishStopWords()

func UkrainianStopWords()

func VietnameseStopWords()

func PersianStopWords()

func StopWordLanguage(pcStopWord)
	for cLang in StopWordsLanguages()
		
		cCode = "bExists = StzListOfStringsQ(" + cLang + "StopWords()).ContainsCS(pcStopWord, :CS = FALSE)"
		eval(cCode)

		if bExists
			return cLang
		ok
	next
