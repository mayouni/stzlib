
  ///////////////////
 ///   GLOBALS   ///
///////////////////

_cSentenceSeparator = "."
_cParagraphSeparator = NL
_cDefaultLanguage = :English

_cWordIdentificationMode = :Quick	# or :Strict

_acCharsAllowedInStartOfWord		= [ "_acCharsAllowedInStartOfWord" ]
_acCharsNotAllowedInStartOfWord 	= [ "_acCharsNotAllowedInStartOfWord" ]
_acSubstringsAllowedInStartOfWord	= [ "_acSubstringsAllowedInStartOfWord" ]
_acSubstringsNotAllowedInStartOfWord	= [ "_acSubstringsNotAllowedInStartOfWord" ]

_acCharsAllowedInsideWord		= [ "_acCharsAllowedInsideWord" ]
_acCharsNotAllowedInsideWord		= [ "_acCharsNotAllowedInsideWord" ]
_acSubstringsAllowedInsideWord		= [ "_acSubstringsAllowedInsideWord" ]
_acSubstringsNotAllowedInsideWord	= [ "_acSubstringsNotAllowedInsideWord" ]

_acCharsAllowedInEndOfWord		= [ "_acCharsAllowedInEndOfWord" ]
_acCharsNotAllowedInEndOfWord		= [ "_acCharsNotAllowedInEndOfWord" ]
_acSubstringsAllowedInEndOfWord		= [ "_acSubstringsAllowedInEndOfWord" ]
_acSubstringsNotAllowedInEndOfWord	= [ "_acSubstringsNotAllowedInEndOfWord" ]

  /////////////////////
 ///   FUNCTIONS   ///
/////////////////////

func SentenceSeparator()
	return _cSentenceSeparator

func ParagraphSeparator()
	return _cParagraphSeparator

func DefaultLanguage()
	return _cDefaultLanguage

func StzTextQ(pcStr)
	return new stzText(pcStr)

func T(p)
	if isString(p)
		return p

	but isNumber(p)
		return "" + p

	but isList(p)
		return Q(p).ToCode()

	but isObject(p)
		return Q(p).ObjectAttributesAndValuesQ().ToCode()

	ok

	func TQ(p)
		return new stzText( T(p) )

# Useful four finding instances of WORDS (an not substrings!) inside a string
func PossibleWordInstancesXT(pcWord, cWordPositionInSentence)
	
	/* REMINDER (from stzCharData.ring)

	# Word and sentence separators

	? WordSeparators()
	# --> gives [ " ", ".", ",", ";", ":", "!", "?", "؟", "،", "'", "’", "—"  ]

	? SentenceSeparators()
	# --> gives [ ".", "!", "?", "؟" ]

	? WordBoundingChars()
	# --> gives 
	# [
	# 	[ "(", ")" ], [ "[", "]" ], [ "{", "}" ], [ "'", "'" ], [ '"', '"' ]
	# ]

	? WordNonLetterChars()
	# --> gives ListsMerge([
	# 	[ "_", "-", "*", "/", "\", "+" ],
	# 	ArabicNumbers()
	# ]) # Sutch as: C++, Win32, ART*F, AS/400

	*/

	if NOT StzStringQ(pcWord).IsWord()
		StzRaise("Invalid word!")
	ok

	aResult = []
	acSeps = WordSeparators()

	switch cWordPositionInSentence
	on :InStartOfSentence
		#--> Word + Separator

		for cSep in acSeps
			aResult + ( pcWord + cSep + " " )
		next
	
	on :InEndOfSentence
		#--> Separator + Word

		for cSep in acSeps
			aResult + ( cSep + pcWord )
		next
	
	on :InMiddleOfSentence
		#--> Separator + Word + Separator

		for cSep in acSeps
			aResult + ( cSep + pcWord + cSep )
		next
	
	other
		StzRaise(:CanNotGeneratePossibleWordInstances)
		
	off

	return aResult

	def PossibleInstancesOfWordXT(pcWord, cWordPositionInSentence)
		return PossibleWordInstancesXT(pcWord, cWordPositionInSentence)
	
func PossibleWordInstances(pcWord)
	aResult = ListsMerge([
		PossibleWordInstancesXT(pcWord, :InStartOfSentence),
		PossibleWordInstancesXT(pcWord, :InMiddleOfSentence),
		PossibleWordInstancesXT(pcWord, :InEndOfSentence)
	])

	return aResult

	def PossibleInstancesOfWord(pcWord)
		return PossibleWordInstances(pcWord)

func ArabicWord(pcStr)
	if StzTextQ(pcStr).IsArabicWord()
		return pcStr
	ok

#---- 

func WordIdentificationMode()
	return _cWordIdentificationMode

	func WordsIdentificationMode()
		return WordIdentificationMode()

func IdentifiyWordsInQuickMode()
	_cWordIdentificationMode = :Quick

func IdentifyWordsInStrictMode()
	_cWordIdentificationMode = :Strict

#---

func TheseCharsCanBeInStartOfWord(pacChars)
	_acCharsAllowedInStartOfWord = pacChars

	func TheseCharsCanBeInStartOfAWord(pacChars)
		TheseCharsCanBeInStartOfWord(pacChars)

	func TheseCharsAreAllowedInStartOfWord(pacChars)
		TheseCharsCanBeInStartOfWord(pacChars)

	func TheseCharsAreAllowedInStartOfAWord(pacChars)
		TheseCharsCanBeInStartOfWord(pacChars)

	func AllowTheseCharsInStartOfWord(pacChars)
		TheseCharsCanBeInStartOfWord(pacChars)

	func AllowTheseCharsInStartOfAWord(pacChars)
		TheseCharsCanBeInStartOfWord(pacChars)

func TheseCharsCanNotBeInStartOfWord(pacChars)
	_acCharsNotAllowedInStartOfWord = pacChars

	func TheseCharsCanNotBeInStartOfAWord(pacChars)
		TheseCharsCanNotBeInStartOfWord(pacChars)

	func TheseCharsAreNotAllowedInStartOfWord(pacChars)
		TheseCharsCanNotBeInStartOfWord(pacChars)

	func TheseCharsAreNotAllowedInStartOfAWord(pacChars)
		TheseCharsCanNotBeInStartOfWord(pacChars)

	func DoNotAllowTheseCharsInStartOfWord(pacChars)
		TheseCharsCanNotBeInStartOfWord(pacChars)

	func DoNotAllowTheseCharsInStartOfAWord(pacChars)
		TheseCharsCanNotBeInStartOfWord(pacChars)

func CharsAllowedInStartOfWord()
	return _acCharsAllowedInStartOfWord

	func AllowedCharsInStartOfWord()
		return CharsAllowedInStartOfWord()

func CharsNotAllowedInStartOfWord()
	return _acCharsNotAllowedInStartOfWord

	func UnallowedCharsInStartOfWord()
		return CharsNotAllowedInStartOfWord()

#---

func TheseSubstringsCanBeInStartOfWord(pacSubstrings)
	_acSubstringsAllowedInStartOfWord = pacSubstrings

	func TheseSubstringsCanBeInStartOfAWord(pacSubstrings)
		TheseSubstringsCanBeInStartOfWord(pacSubstrings)

	func TheseSubstringsAreAllowedInStartOfWord(pacSubstrings)
		TheseSubstringsCanBeInStartOfWord(pacSubstrings)

	func TheseSubstringsAreAllowedInStartOfAWord(pacSubstrings)
		TheseSubstringsCanBeInStartOfWord(pacSubstrings)

	func AllowTheseSubstringsInStartOfWord(pacSubstrings)
		TheseSubstringsCanBeInStartOfWord(pacSubstrings)

	func AllowThesesubstringsInStartOfAWord(pacSubstrings)
		TheseSubstringsCanBeInStartOfWord(pacSubstrings)

func TheseSubstringsCanNotBeInStartOfWord(pacSubstrings)
	_acSusbstringsNotAllowedInStartOfWord = pacSubstrings

	func TheseSubstringsCanNotBeInStartOfAWord(pacSubstrings)
		TheseSubstringsCanNotBeInStartOfWord(pacSubstrings)

	func TheseSubstringsAreNotAllowedInStartOfWord(pacSubstrings)
		TheseSubstringsCanNotBeInStartOfWord(pacSubstrings)

	func TheseSubstringsAreNotAllowedInStartOfAWord(pacSubstrings)
		TheseSubstringsCanNotBeInStartOfWord(pacSubstrings)

	func DoNotAllowTheseSubstringsInStartOfWord(pacSubstrings)
		TheseSubstringsCanNotBeInStartOfWord(pacSubstrings)

	func DoNotAllowTheseSubstringsInStartOfAWord(pacSubstrings)
		TheseSubstringsCanNotBeInStartOfWord(pacSubstrings)

func SubstringsAllowedInStartOfWord()
	return _acSubstringsAllowedInStartOfWord

	func AllowedSubstringsInStartOfWord()
		return SubstringsAllowedInStartOfWord()

func SubstringsNotAllowedInStartOfWord()
	return _acSubstringsNotAllowedInStartOfWord

	func UnallowedSubstringsInStartOfWord()
		return CharsNotAllowedInStartOfWord()

#---

func TheseCharsCanBeInsideWord(pacChars)
	_acCharsAllowedInsideWord = pacChars

	func TheseCharsCanBeInsideAWord(pacChars)
		TheseCharsCanBeInsideWord(pacChars)

	func TheseCharsAreAllowedInsideWord(pacChars)
		TheseCharsCanBeInsideWord(pacChars)

	func TheseCharsAreAllowedInsideAWord(pacChars)
		TheseCharsCanBeInsideWord(pacChars)

	func AllowTheseCharsInsideWord(pacChars)
		TheseCharsCanBeInsideWord(pacChars)

	func AllowTheseCharsInsideAWord(pacChars)
		TheseCharsCanBeInsideWord(pacChars)

func TheseCharsCanNotBeInsideWord(pacChars)
	_acCharsNotAllowedInsideWord = pacChars

	func TheseCharsCanNotBeInsideAWord(pacChars)
		TheseCharsCanNotBeInsideWord(pacChars)

	func TheseCharsAreNotAllowedInsideWord(pacChars)
		TheseCharsCanNotBeInsideWord(pacChars)

	func TheseCharsAreNotAllowedInsideAWord(pacChars)
		TheseCharsCanNotBeInsideWord(pacChars)

	func DoNotAllowTheseCharsInsideWord(pacChars)
		TheseCharsCanNotBeInsideWord(pacChars)

	func DoNotAllowTheseCharsInsideAWord(pacChars)
		TheseCharsCanNotBeInsideWord(pacChars)

func CharsAllowedInsideWord()
	return _acCharsAllowedInsideWord

	func CharsAllowedInsideWords()
		return CharsAllowedInsidefWord()

	func AllowedCharsInsideWord()
		return CharsAllowedInsidefWord()

	func AllowedCharsInsideWords()
		return CharsAllowedInsidefWord()

func CharsNotAllowedInsideWord()
	return _acCharsNotAllowedInsideWord

	func CharsNotAllowedInsideWords()
		return CharsNotAllowedInsideWord()

	func UnallowedCharsInsideWord()
		return CharsNotAllowedInsideWord()

	func UnallowedCharsInsideWords()
		return CharsNotAllowedInsideWord()

#---

func TheseSubstringsCanBeInsideWord(pacChars)
	_acSubstringsAllowedInsideWord = pacChars

	func TheseSubstringsCanBeInsideAWord(pacSubstrings)
		TheseSubstringsCanBeInsideWord(pacSubstrings)

	func TheseSubstringsAreAllowedInsideWord(pacSubstrings)
		TheseSubstringsCanBeInsideWord(pacSubstrings)

	func TheseSubstringsAreAllowedInsideAWord(pacSubstrings)
		TheseSubstringsCanBeInsideWord(pacSubstrings)

	func AllowTheseSubstringsInsideWord(pacSubstrings)
		TheseSubstringsCanBeInsideWord(pacSubstrings)

	func AllowThesesubstringsInsideAWord(pacSubstrings)
		TheseSubstringsCanBeInsideWord(pacSubstrings)

func TheseSubstringsCanNotBeInsideWord(pacChars)
	_acCharsNotAllowedInsideWord = pacChars

	func TheseSubstringsCanNotBeInsideAWord(pacSubstrings)
		TheseSubstringsCanNotBeInStartOfWord(pacSubstrings)

	func TheseSubstringsAreNotAllowedInsideWord(pacSubstrings)
		TheseSubstringsCanNotBeInsideWord(pacSubstrings)

	func TheseSubstringsAreNotAllowedInsideAWord(pacSubstrings)
		TheseSubstringsCanNotBeInsideWord(pacSubstrings)

	func DoNotAllowTheseSubstringsInsideWord(pacSubstrings)
		TheseSubstringsCanNotBeInsideWord(pacSubstrings)

	func DoNotAllowTheseSubstringsInsideAWord(pacSubstrings)
		TheseSubstringsCanNotBeInsideWord(pacSubstrings)

func SubstringsAllowedInsideWord()
	return _acSubstringsAllowedInsideWord

	func SubstringsAllowedInsideWords()
		return SubstringsAllowedInsideWord()

	func AllowedSubstringsInsideWord()
		return SubstringsAllowedInsideWord()

	func AllowedSubstringsInsideWords()
		return SubstringsAllowedInsideWord()

func SubstringsNotAllowedInsideWord()
	return _acSubstringsNotAllowedInsideWord

	func SubstringsNotAllowedInsideWords()
		return CharsNotAllowedInsideWord()

	func UnallowedSubstringsInsideWord()
		return CharsNotAllowedInsideWord()

	func UnallowedSubstringsInsideWords()
		return CharsNotAllowedInsideWord()

#---

func TheseCharsCanBeInEndOfWord(pacChars)
	_acCharsAllowedInEndOfWord = pacChars

	func TheseCharsCanBeInEndOfAWord(pacChars)
		TheseCharsCanBeInEndOfWord(pacChars)

	func TheseCharsAreAllowedInEndOfWord(pacChars)
		TheseCharsCanBeInStartOfWord(pacChars)

	func TheseCharsAreAllowedInEndOfAWord(pacChars)
		TheseCharsCanBeInEndOfWord(pacChars)

	func AllowTheseCharsInEndOfWord(pacChars)
		TheseCharsCanBeInStartOfWord(pacChars)

	func AllowTheseCharsInEndOfAWord(pacChars)
		TheseCharsCanBeInEndOfWord(pacChars)

func TheseCharsCanNotBeInEndOfWord(pacChars)
	_acCharsNotAllowedInEndOfWord = pacChars

	func TheseCharsCanNotBeInEndOfAWord(pacChars)
		TheseCharsCanNotBeInEndOfWord(pacChars)

	func TheseCharsAreNotAllowedInEndOfWord(pacChars)
		TheseCharsCanNotBeInEndOfWord(pacChars)

	func TheseCharsAreNotAllowedInEndOfAWord(pacChars)
		TheseCharsCanNotBeInEndOfWord(pacChars)

	func DoNotAllowTheseCharsInEndOfWord(pacChars)
		TheseCharsCanNotBeInEndOfWord(pacChars)

	func DoNotAllowTheseCharsInEndOfAWord(pacChars)
		TheseCharsCanNotBeInEndOfWord(pacChars)

func CharsAllowedInEndOfWord()
	return _acCharsAllowedInEndOfWord

	func CharsAllowedInEndOfWords()
		return CharsAllowedInEndOfWord()

	func AllowedCharsInEndOfWord()
		return CharsAllowedInEndOfWord()

	func AllowedCharsInEndOfWords()
		return CharsAllowedInEndOfWord()

func CharsNotAllowedInEndOfWord()
	return _acCharsNotAllowedInEndOfWord

	func CharsNotAllowedInEndOfWords()
		return CharsNotAllowedInEndOfWord()

	func UnallowedCharsInEndOfWord()
		return CharsNotAllowedInEndOfWord()

	func UnallowedCharsInEndOfWords()
		return CharsNotAllowedInEndOfWord()

#---

func TheseSubstringsCanBeInEndOfWord(pacChars)
	_acSubstringsAllowedInEndOfWord = pacChars

	func TheseSubstringsCanBeInEndOfAWord(pacSubstrings)
		TheseSubstringsCanBeInEndOfWord(pacSubstrings)

	func TheseSubstringsAreAllowedInEndOfWord(pacSubstrings)
		TheseSubstringsCanBeInEndOfWord(pacSubstrings)

	func TheseSubstringsAreAllowedInEndOfAWord(pacSubstrings)
		TheseSubstringsCanBeInEndOfWord(pacSubstrings)

	func AllowTheseSubstringsInEndOfWord(pacSubstrings)
		TheseSubstringsCanBeInEndOfWord(pacSubstrings)

	func AllowThesesubstringsInEndOfAWord(pacSubstrings)
		TheseSubstringsCanBeInEndOfWord(pacSubstrings)


func TheseSubstringsCanNotBeInEndOfWord(pacChars)
	_acCharsNotAllowedInEndOfWord = pacChars

	func TheseSubstringsCanNotBeInEndOfAWord(pacSubstrings)
		TheseSubstringsCanNotBeInEndOfWord(pacSubstrings)

	func TheseSubstringsAreNotAllowedInEndOfWord(pacSubstrings)
		TheseSubstringsCanNotBeInEndOfWord(pacSubstrings)

	func TheseSubstringsAreNotAllowedInEndOfAWord(pacSubstrings)
		TheseSubstringsCanNotBeInEndOfWord(pacSubstrings)

	func DoNotAllowTheseSubstringsInEndOfWord(pacSubstrings)
		TheseSubstringsCanNotBeInEndOfWord(pacSubstrings)

	func DoNotAllowTheseSubstringsInEndOfAWord(pacSubstrings)
		TheseSubstringsCanNotBeInEndOfWord(pacSubstrings)

func SubstringsAllowedInEndOfWord()
	return _acSubstringsAllowedInEndOfWord

	func AllowedSubstringsInEndOfWord()
		return SubstringsAllowedInEndOfWord()

func SubstringsNotAllowedInEndOfWord()
	return _acSubstringsNotAllowedInEndOfWord

	func UnallowedSubstringsInEndOfWord()
		return CharsNotAllowedInEndOfWord()


  /////////////////
 ///   CLASS   ///
/////////////////

class stzText from stzString
	@oQString

	@cLanguage = DefaultLanguage()

	def init(pcStr)
		if isString(pcStr)
			@oQString = new QString2()
			@oQString.append(pcStr)

		but IsStzString(pcStr)
			@oQString = pcStr.QStringObject()

		else
			StzRaise("Can't create stzText object! You must provide a string or a stzString object.")
		ok

	  #----------------#
	 #    GENERAL     #
	#----------------#

	def Text()
		return This.Content()

	def Copy()
		return new stzText(This.Content())

	def ToStzString()
		return new stzString( This.Content() )

	  #--------------------#
	 #      LANGUAGE      #
	#--------------------#

	def SetLanguage(pcLanguage)
		@cLanguage = pcLanguage

	def Language()
		return @cLanguage

	  #----------------#
	 #     SCRIPT     #
	#----------------#

	/*
	From: https://bit.ly/3lnjMoV

	"Code for Inherited Script" does not refer to a particular script
	in the conventional sense of the word. Rather, in the Unicode
	Standard, "inherited" is a property that applies to an individual
	character which inherits its script from the preceding characters.

	These include nonspacing marks, enclosing marks, and the zero width
	joiner/non-joiner characters. These can be used with multiple scripts.

	These are not to be confused with characters classified under the
	ISO tag "Code for Undetermined Script" ("Common" in Unicode), which
	are also common to more than one formal natural script, but which
	do not identify themselves with the script of the preceding
	character. These include musical notation, and many punctuation marks.
	*/

	def Script()
		/*
		Example:

		? StzStringQ("和平").Script()
		--> Returns "Han"

		? StzStringQ("和平 is 'peace' in chineese!").Script()
		--> Returns "Hybrid"
		*/

		if This.NumberOfScripts() = 0
			StzRaise("Information about script is unavilable!")

		but This.NumberOfScripts() = 1
			return This.Scripts()[1]

		but This.NumberOfScripts() = 2 and StzStringQ(:Common).ExistsIn( This.Scripts() )
			cResult = StzListQ( This.Scripts() ).AllItemsExcept(:Common)[1]
			return cResult

		but This.NumberOfScripts() > 1

			cResult = :Hybrid

			# Managing the case of an diacriticized string
			# like "سَلَامُُ", for which Qt says that it is a :Hybrid script,
			# while we consider it to be an :Arabic script.

			# In fact, Qt returns [ :Arabic, :Inherited ] scripts for that
			# word, and if we add any spaces ("سَلَامُُ عَلَيْكُمْ" for example),
			# it identifies a 3rd script [ :Arabic, :Inherited, :Common ],
			# because space is a common char in Unicode.

			# Softanza has a different opinion: if one script (say arabic
			# for example), is identified by Qt with :Inherited and :Common
			# scripts, then the main script we should return to the user
			# is :Arabic itself.

			# This beeing explainde, the following algorithm becomes obvious!

			if This.NumberOfScripts() <= 3
				oScripts = StzListQ( This.Scripts() )
				oScripts - [ :Common, :Inherited ]
				cScript = oScripts[1]
			
			  	if StzListQ(This.Scripts()).EachItemExistsIn([ cScript, :Common, :Inherited ])
					cResult = cScript
				ok
			
			ok

			return cResult
		ok
		
	def Scripts()
		aResult = []

		for i = 1 to This.NumberOfChars()
			aResult + This.CharAtQR(i, :stzChar).Script()
		next

		aResult = StzListQ(aResult).ToSet()

		return aResult

	def NumberOfScripts()
		return len(This.Scripts())

	def ScriptOfNthChar(n)
		return This.CharAtQR(n, :stzChar).Script()

	def ScriptsPerChar()
		aResult = []

		for c in This.UniqueChars()
			aResult + StzCharQR(c, :stzChar).Script()
		next

		return aResult

	def ScriptIs(cScript)
		/*
		Example: all these return TRUE:

		StzTextQ("سلام").ScriptIs(:Arabic)
		StzTextgQ("Peace").ScriptIs(:Latin)
		StzTextQ("和平").ScriptIs(:Han) # China
		StzTextQ("શાંતિ").ScriptIs(:Gujarati) # India, Pakistan
		*/

		return This.Script() = cScript

	def ContainsScript(cScript)
		return StzStringQ(cScript).ExistsIn( This.Scripts() )

	def ContainsArabicScript()
		return This.ContainsScript(:Arabic)

	def ContainsLatinScript()
		return This.ContainsScript(:Latin)

	def IsUnknownScript()
		return This.ScriptIs(:Unkonown)

	def IsInheritedScript()
		return This.ScriptIs(:Inherited)

	def IsHybridScript()
		return This.ScriptIs(:Hybrid)

	def IsCommonScript()
		return This.ScriptIs(:Common)

	def IsLatinScript()
		return This.ScriptIs(:Latin)

	def IsGreekScript()
		return This.ScriptIs(:Greek)

	def IsCyrillicScript()
		return This.ScriptIs()

	def IsArmenianScript()
		return This.ScriptIs(:Armenian)

	def IsHebrewScript()
		return This.ScriptIs(:Hebrew)

	def IsArabicScript()
		return This.ScriptIs(:Arabic)

	def IsSyriacScript()
		return This.ScriptIs(:Syriac)

	def IsThaanaScript()
		return This.ScriptIs(:Thaana)

	def IsDevanagariScript()
		return This.ScriptIs(:Devanagari)

	def IsBengaliScript()
		return This.ScriptIs(:Bengali)

	def IsGurmukhiScript()
		return This.ScriptIs(:Gurmukhi)

	def IsGujaratiScript()
		return This.ScriptIs(:Gujarati)

	def IsOriyaScript()
		return This.ScriptIs(:Oriya)

	def IsTamilScript()
		return This.ScriptIs(:Tamil)

	def IsTeluguScript()
		return This.ScriptIs(:Telugu)

	def IsKannadaScript()
		return This.ScriptIs(:Kannada)

	def IsMalayalamScript()
		return This.ScriptIs(:Malayalam)

	def IsSinhalaScript()
		return This.ScriptIs(:Sinhala)

	def IsThaiScript()
		return This.ScriptIs(:Thai)

	def IsLaoScript()
		return This.ScriptIs(:Lao)

	def IsTibetanScript()
		return This.ScriptIs(:Tibetan)

	def IsMyanmarScript()
		return This.ScriptIs(:Myanmar)

	def IsGeorgianScript()
		return This.ScriptIs(:Georgian)

	def IsHangulScript()
		return This.ScriptIs(:Hangul)

	def IsEthiopicScript()
		return This.ScriptIs(:Ethiopic)

	def IsCherokeeScript()
		return This.ScriptIs(:Cherokee)

	def IsCanadianAboriginalScript()
		return This.ScriptIs(:CanadianAboriginal)

	def IsOghamScript()
		return This.ScriptIs(:Ogham)

	def IsRunicScript()
		return This.ScriptIs(:Runic)

	def IsKhmerScript()
		return This.ScriptIs(:Khmer)

	def IsMongolianScript()
		return This.ScriptIs(:Mongolian)

	def IsHiraganaScript()
		return This.ScriptIs(:Hiragana)

	def IsKatakanaScript()
		return This.ScriptIs(:Katakana)

	def IsBopomofoScript()
		return This.ScriptIs(:Bopomofo)

	def IsHanScript()
		return This.ScriptIs(:Han)

	def IsYiScript()
		return This.ScriptIs(:Yi)

	def IsOldItalicScript()
		return This.ScriptIs(:OldItalic)

	def IsGothicScript()
		return This.ScriptIs(:Gothic)

	def IsDeseretScript()
		return This.ScriptIs(:Deseret)

	def IsTagalogScript()
		return This.ScriptIs(:Tagalog)

	def IsHanunooScript()
		return This.ScriptIs(:Hanunoo)

	def IsBuhidScript()
		return This.ScriptIs(:Buhid)

	def IsTagbanwaScript()
		return This.ScriptIs(:Tagbanwa)

	def IsCopticScript()
		return This.ScriptIs(:Coptic)

	def IsLimbuScript()
		return This.ScriptIs(:Limbu)

	def IsTaiLeScript()
		return This.ScriptIs(:TaiLe)

	def IsLinearBScript()
		return This.ScriptIs(:LinearB)

	def IsUgariticScript()
		return This.ScriptIs(:Ugaritic)

	def IsShavianScript()
		return This.ScriptIs(:Shavian)

	def IsOsmanyaScript()
		return This.ScriptIs(:Osmanya)

	def IsCypriotScript()
		return This.ScriptIs(:Cypriot)

	def IsBrailleScript()
		return This.ScriptIs(:Braille)

	def IsBugineseScript()
		return This.ScriptIs(:Buginese)

	def IsNewTaiLueScript()
		return This.ScriptIs(:NewTaiLue)

	def IsGlagoliticScript()
		return This.ScriptIs(:Glagolitic)

	def IsTifinaghScript()
		return This.ScriptIs(:Tifinagh)

	def IsSylotiNagriScript()
		return This.ScriptIs(:SylotiNagri)

	def IsOldPersianScript()
		return This.ScriptIs(:OldPersian)

	def IsKharoshthiScript()
		return This.ScriptIs(:Kharoshthi)

	def IsBalineseScript()
		return This.ScriptIs(:Balinese)

	def IsCuneiformScript()
		return This.ScriptIs(:Cuneiform)

	def IsPhoenicianScript()
		return This.ScriptIs()

	def IsPhagsPaScript()
		return This.ScriptIs(:Phoenician)

	def IsNkoScript()
		return This.ScriptIs(:Nko)

	def IsSundaneseScript()
		return This.ScriptIs(:Sundanese)

	def IsLepchaScript()
		return This.ScriptIs(:Lepcha)

	def IsOlChikiScript()
		return This.ScriptIs(:OlChiki)

	def IsVaiScript()
		return This.ScriptIs(:Vai)

	def IsSaurashtraScript()
		return This.ScriptIs(:Saurashtra)

	def IsKayahLiScript()
		return This.ScriptIs(:Kayah)

	def IsRejangScript()
		return This.ScriptIs(:Rejang)

	def IsLycianScript()
		return This.ScriptIs(:Lycian)

	def IsCarianScript()
		return This.ScriptIs(:Carian)

	def IsLydianScript()
		return This.ScriptIs(:Lydian)

	def IsChamScript()
		return This.ScriptIs(:Cham)

	def TaiThamScript()
		return This.ScriptIs(:TaiTham)

	def IsTaiVietScript()
		return This.ScriptIs(:TaiViet)

	def IsAvestanScript()
		return This.ScriptIs(:Avestan)

	def IsEgyptianHieroglyphsScript()
		return This.ScriptIs(:EgyptianHieroglyphs)

	def IsSamaritanScript()
		return This.ScriptIs(:Samaritan)

	def IsLisuScript()
		return This.ScriptIs(:Lisu)

	def IsBamumScript()
		return This.ScriptIs(:Bamum)

	def IsJavaneseScript()
		return This.ScriptIs(:Javanese)

	def IsMeeteiMayekScript()
		return This.ScriptIs(:MeeteiMayek)

	def IsImperialAramaicScript()
		return This.ScriptIs(:ImperialAramaic)

	def IsOldSouthArabianScript()
		return This.ScriptIs(:OldSouthArabian)

	def IsInscriptionalParthianScript()
		return This.ScriptIs(:InscriptionalParthian)

	def IsInscriptionalPahlaviScript()
		return This.ScriptIs(:InscriptionalPahlavi)

	def IsOldTurkicScript()
		return This.ScriptIs(:OldTurkic)

	def IsKaithiScript()
		return This.ScriptIs(:Kaithi)

	def IsBatakScript()
		return This.ScriptIs(:Batak)

	def IsBrahmiScript()
		return This.ScriptIs(:Brahmi)

	def IsMandaicScript()
		return This.ScriptIs(:Mandaic)

	def IsChakmaScript()
		return This.ScriptIs(:Chakma)

	def IsMeroiticCursiveScript()
		return This.ScriptIs(:MeroiticCursive)

	def IsMeroiticHieroglyphsScript()
		return This.ScriptIs(:MeroiticHieroglyphs)

	def IsMiaoScript()
		return This.ScriptIs(:Miao)

	def IsSharadaScript()
		return This.ScriptIs(:Sharada)

	def IsSoraSompengScript()
		return This.ScriptIs(:SoraSompeng)

	def IsTakriScript()
		return This.ScriptIs(:Takri)

	def IsCaucasianAlbanianScript()
		return This.ScriptIs(:CaucasianAlbanian)

	def IsBassaVahScript()
		return This.ScriptIs(:BassaVah)

	def IsDuployanScript()
		return This.ScriptIs(:Duployan)

	def IsElbasanScript()
		return This.ScriptIs(:Elbasan)

	def IsGranthaScript()
		return This.ScriptIs(:Grantha)

	def IsPahawhHmongScript()
		return This.ScriptIs(:PahawhHmong)

	def IsKhojkiScript()
		return This.ScriptIs(:Khojki)

	def IsLinearAScript()
		return This.ScriptIs(:LinearA)

	def IsMahajaniScript()
		return This.ScriptIs(:Mahajani)

	def IsManichaeanScript()
		return This.ScriptIs(:Manichaean)

	def IsMendeKikakuiScript()
		return This.ScriptIs(:MendeKikakui)

	def IsModiScript()
		return This.ScriptIs(:Modi)

	def IsMroScript()
		return This.ScriptIs(:Mro)

	def IsOldNorthArabianScript()
		return This.ScriptIs(:OldNorthArabic)

	def IsNabataeanScript()
		return This.ScriptIs(:Nabataen)

	def IsPalmyreneScript()
		return This.ScriptIs(:Palmyrene)

	def IsPauCinHauScript()
		return This.ScriptIs(:PauCinHau)

	def IsOldPermicScript()
		return This.ScriptIs(:OldPermic)

	def IsPsalterPahlaviScript()
		return This.ScriptIs(:PasalterPahlavi)

	def IsSiddhamScript()
		return This.ScriptIs(:Siddham)

	def IsKhudawadiScript()
		return This.ScriptIs(:Khudawadi)

	def IsTirhutaScript()
		return This.ScriptIs(:Tirhuta)

	def IsWarangCitiScript()
		return This.ScriptIs(:WarangCiti)

	def IsAhomScript()
		return This.IsScript(:Ahom)

	def IsAnatolianHieroglyphsScript()
		return This.ScriptIs(:AnatolianHieroglyphs)

	def IsHatranScript()
		return This.ScriptIs(:Hatran)

	def IsMultaniScript()
		return This.ScriptIs(:Multani)

	def IsOldHungarianScript()
		return This.ScriptIs(:OldHungarian)

	def IsSignWritingScript()
		return This.IsScript(:SignWriting)

	def IsAdlamScript()
		return This.ScriptIs(:Adlam)

	def IsBhaiksukiScript()
		return This.ScriptIs(:Bhaiksuki)

	def IsMarchenScript()
		return This.ScriptIs(:MarchenScript)

	def IsNewaScript()
		return This.ScriptIs(:Newa)

	def IsOsageScript()
		return This.ScriptIs(:Osage)

	def IsTangutScript()
		return This.ScriptIs(:Tangut)

	def IsMasaramGondiScript()
		return This.ScriptIs(:MasaramGondi)

	def IsNushuScript()
		return This.ScriptIs(:Nushu)

	def IsSoyomboScript()
		return This.ScriptIs(:Soyombo)

	def IsZanabazarSquareScript()
		return This.ScriptIs(:ZanabazarSquare)

	def IsDograScript()
		return This.ScriptIs(:Dogra)

	def IsGunjalaGondiScript()
		return This.ScriptIs(:GunjalaGondi)

	def IsHanifiRohingyaScript()
		return This.ScriptIs(:HanifiRohingya)

	def IsMakasarScript()
		return This.ScriptIs(:Makasar)

	def IsMedefaidrinScript()
		return This.ScriptIs(:Medefaidrin)

	def IsOldSogdianScript()
		return This.ScriptIs(:OldSogdian)

	def IsSogdianScript()
		return This.ScriptIs(:Sogdian)

	def IsElymaicScript()
		return This.ScriptIs(:Elymaic)

	def IsNandinagariScript()
		return This.ScriptIs(:Nandinagari)

	def IsNyiakengPuachueHmongScript()
		return This.ScriptIs(:NyiakengPuachueHmong)

	def IsWanchoScript()
		return This.ScriptIs(:Wancho)

	def IsChorasmianScript()
		return This.ScriptIs(:Chorasmian)

	def IsDivesAkuruScript()
		return This.ScriptIs(:DivesAkuru)

	def IsKhitanSmallScriptScript()
		return This.ScriptIs(:Khitan)

	def IsYezidiScript()
		return This.ScriptIs(:Yezidi)

	  #---------------------------------------------#
	 #     GETTING ONLY TEXT IN A GIVEN SCRIPT     #
	#---------------------------------------------#

	def OnlyScript(pcScript)
		acListOfChars = StzListQ( This.ToListOfChars() ).CharsW('
			StzCharQ(@item).Script() = pcScript
		')

		cResult = StzListOfStringsQ( acListOfChars ).ConcatenateQ().SimplifyQ().Content()
		return cResult
		
	# TODO: Not optimised for large texts!
	def OnlyArabic()
		acListOfChars = StzListQ( This.ToListOfChars() ).ItemsW('
			StzCharQ(@item).IsNeutral() or
			StzCharQ(@item).IsSpace() or
			StzCharQ(@item).IsArabic()
		')

		cResult = StzListOfStringsQ( acListOfChars ).ConcatenateQ().SimplifyQ().Content()
		return cResult

	def OnlyLatin()
		acListOfChars = StzListQ( This.ToListOfChars() ).ItemsW('
			StzCharQ(@item).IsNeutral() or
			StzCharQ(@item).IsSpace() or
			StzCharQ(@item).IsLatin()
		')

		cResult = StzListOfStringsQ( acListOfChars ).ConcatenateQ().SimplifyQ().Content()
		return cResult

	  #-----------------#
	 #      WORDS      #
	#-----------------#

	#--- 

	def NumberOfWords()
		return len( This.Words() )

	#--- 

	def NumberOfUniqueWords()
		return len( This.SetOfWords() )

	#--- 

	def IsWord()
		bResult = This.ToStzString().IsWord()
		return bResult

	def IsArabicWord()
		if This.IsWord() and This.ScriptIs(:Arabic)
			return TRUE
		else
			return FALSE
		ok

	def IsLatinWord()
		if This.IsWord() and This.ScriptIs(:Latin)
			return TRUE
		else
			return FALSE
		ok

	/*
	TODO: Add other scripts supported by Unicode standard
	*/

	def WordsExcept(pacWords)
		if NOT ( isList(pacWords) and IsListOfStrings(pacWords) )

			StzRaise("Incorrect param type!")
		ok

		acWords = StzListOfStringsQ(pacWords).Lowercased()

		oWords = This.WordsQ()

		oWords - acWords
		aResult = oWords.Content()

		return aResult

	def Words()
		/* TODO
	
		Manage case of composed-words like (meta-programming)
		and some spcial english worlds like (i.e.)

		Add a section for Composed words:

			IsComposedWord()
			ComposedWords()
			NumberOfCo^mposedWords()
			
		And to consider or not them in word processing, add:

			ComposedWordsMustBeSeparated()
			ComposedWordsMusNotBeSeparated()

		*/

		oCopy = This.LowercaseQ() # Words are managed in lowercase in Softanza

		# t0 = clock()

		if WordsIdentificationMode() = :Strict
			oWords = This.RemovePunctuationExceptQ( WordNonLetterChars() ).SimplifyQ().SplitQ(" ")

		but WordsIdentificationMode() = :Quick
			oWords = This.RemovePunctuationsQ().SplitQ(" ")
		else
			StzRaise("Unkowan word identification mode!")
		ok

		# ? (clock() - t0) / clockspersecond()

		if StopWordsStatus() = :MustBeRemoved
			oWords - StopWordsIn( This.Language() )
		ok

		aResult = oWords.Content()

		return aResult
		
		#< @FunctionFluentForm

		def WordsQ()
			return This.WordsQR(:stzList)
	
		def WordsQR(pcReturnType)
			if isList(pcReturnType) and StzListQ(pcReturnType).IsOneOfTheseNamedParams([ :ReturnedAs, :ReturnAs ])
				pcReturnType = pcReturnType[2]
			ok

			if isList(pcReturnType) and Q(pcReturnType).IsReturnedNamedParam()
				pcReturnType = pcReturnType[2]
			ok

			switch pcReturnType
	
			on :stzList
				return new stzList( This.Words() )
	
			on :stzListOfStrings
				return new stzListOfStrings( This.Words() )
	
			off
		#>

	#--- 

	def SetOfWords()
		return This.WordsQR(:stzList).DuplicatesRemoved()

		#< @FunctionFluentForm

		def SetOfWordsQ()
			return This.SetOfWordsQR(:stzList)
	
		def SetOfWordsQR(pcReturnType)
			if isList(pcReturnType) and Q(pcReturnType).IsReturnedNamedParam()
				pcReturnType = pcReturnType[2]
			ok

			switch pcReturnType
			on :stzList
				return new stzList( This.SetOfWords() )
	
			on :stzListOfStrings
				return new stzListOfStrings( This.SetOfWords() )
	
			off

		#>

		#< @FunctionAlternaiveForm

		def UniqueWords()
			return This.SetOfWords()

			def UniqueWordsQR(pcReturnType)
				if isList(pcReturnType) and Q(pcReturnType).IsReturnedNamedParam()
					pcReturnType = pcReturnType[2]
				ok

				switch pcReturnType
				on :stzListOfStrings
					return new stzListOfStrings(This.UniqueWords())

				on :stzList
					return new stzList(This.UniqueWords())
				other
					StzRaise("Unsupported returned type!")
				off

			def UniqueWordsQ()
				return This.UniqueWordsQR(:stzList)

		#>

	#--- 

	def WordsSortedInAscending()
		acResult = StzListOfStringsQ( This.Words() ).SortedInAscending()
		return acResult

		#< @FunctionFluentForm

		def WordsSortedInAscendingQR(pcReturnType)
			if isList(pcReturnType) and Q(pcReturnType).IsReturnedNamedParam()
				pcReturnType = pcReturnType[2]
			ok

			switch pcReturnType
			on :stzListOfStrings
				return new stzListOfStrings(This.WordsSortedInAscending())

			on :stzList
				return new stzList(This.WordsSortedInAscending())
			other
				StzRaise("Unsupported returned type!")
			off

		def WordsSortedInAscendingQ()
			return This.WordsSortedInAscendingQR(:stzList)

		#>

		#< @FunctionAlternativeForms

		def WordsInAscending()
			return This.WordsSortedInAscending()

			def WordsInAscendingQR(pcReturnType)
			if isList(pcReturnType) and Q(pcReturnType).IsReturnedNamedParam()
				pcReturnType = pcReturnType[2]
			ok

				switch pcReturnType
				on :stzListOfStrings
					return new stzListOfStrings(This.WordsInAscending())
	
				on :stzList
					return new stzList(This.WordsInAscending())
				other
					StzRaise("Unsupported returned type!")
				off
	
			def WordsInAscendingQ()
				return This.WordsInAscendingQR(:stzList)

		def WordsInAscendingOrder()
			return This.WordsSortedInAscending()

			def WordsInAscendingOrderQR(pcReturnType)
				if isList(pcReturnType) and Q(pcReturnType).IsReturnedNamedParam()
					pcReturnType = pcReturnType[2]
				ok

				switch pcReturnType
				on :stzListOfStrings
					return new stzListOfStrings(This.WordsInAscendingOrder())
	
				on :stzList
					return new stzList(This.WordsInAscendingOrder())
				other
					StzRaise("Unsupported returned type!")
				off
	
			def WordsInAscendingOrderQ()
				return This.WordsInAscendingOrderQR(:stzList)

		#>

	#--- 

	def WordsSortedInDescending()
		acWords = StzListOfStringsQ( This.Words() ).SortedInDescending()
		return acWords

		#< @FunctionFluentForm

		def WordsSortedInDescendingQR(pcReturnType)
			if isList(pcReturnType) and Q(pcReturnType).IsReturnedNamedParam()
				pcReturnType = pcReturnType[2]
			ok

			switch pcReturnType
			on :stzListOfStrings
				return new stzListOfStrings(This.WordsSortedInDescending())

			on :stzList
				return new stzList(This.WordsSortedInDescending())
			other
				StzRaise("Unsupported returned type!")
			off

		def WordsSortedInDescendingQ()
			return This.WordsSortedInDescendingQR(:stzList)

		#>

		#< @FunctionAlternativeForms

		def WordsInDescendingOrder()
			return This.WordsSortedInDescending()

			def WordsInDescendingOrderQR(pcReturnType)
				if isList(pcReturnType) and StzListQ(pcReturnType).IsOneOfTheseNamedParams([ :ReturnedAs, :ReturnAs ])
					pcReturnType = pcReturnType[2]
				ok

				switch pcReturnType
				on :stzListOfStrings
					return new stzListOfStrings(This.WordsInDescendingOrder())
	
				on :stzList
					return new stzList(This.WordsInDescendingOrder())
				other
					StzRaise("Unsupported returned type!")
				off
	
			def WordsInDesscendingOrderQ()
				return This.WordsInDesscendingOrderQR(:stzList)

		def WordsInDescending()
			return This.WordsSortedInDescending()

			def WordsInDescendingQR(pcReturnType)
				if isList(pcReturnType) and Q(pcReturnType).IsReturnedNamedParam()
					pcReturnType = pcReturnType[2]
				ok

				switch pcReturnType
				on :stzListOfStrings
					return new stzListOfStrings(This.WordsInDescending())
	
				on :stzList
					return new stzList(This.WordsInDescending())
				other
					StzRaise("Unsupported returned type!")
				off
	
			def WordsInDescendingQ()
				return This.WordsInDescendingQR(:stzList)

		#>

	#--- 

	def UniqueWordsSortedInAscending()
		aResult = StzListOfStringsQ( This.UniqueWords() ).SortedInAscending()
		return aResult

		#< @FunctionFluentForm

		def UniqueWordsSortedInAscendingQR(pcReturnType)
			if isList(pcReturnType) and Q(pcReturnType).IsReturnedNamedParam()
				pcReturnType = pcReturnType[2]
			ok

			switch pcReturnType
			on :stzListOfStrings
				return new stzListOfStrings(This.UniqueWordsSortedInAscending())

			on :stzList
				return new stzList(This.UniqueWordsSortedInAscending())
			other
				StzRaise("Unsupported returned type!")
			off

		def UniqueWordsSortedInAscendingQ()
			return This.UniqueWordsSortedInAscendingQR(:stzList)

		#>

		#< @FunctionAlternativeForms

		def UniqueWordsInAscendingOrder()
			return This.UniqueWordsSortedInAscending()

			def UniqueWordsInAscendingOrderQR(pcReturnType)
				if isList(pcReturnType) and StzListQ(pcReturnType).IsOneOfTheseNamedParams([ :ReturnedAs, :ReturnAs ])
					pcReturnType = pcReturnType[2]
				ok

				switch pcReturnType
				on :stzListOfStrings
					return new stzListOfStrings(This.UniqueWordsInAscendingOrder())
	
				on :stzList
					return new stzList(This.UniqueWordsInAscendingOrder())
				other
					StzRaise("Unsupported returned type!")
				off
	
			def UniqueWordsInAscendingOrderQ()
				return This.UniqueWordsInAscendingOrderQR(:stzList)

		def UniqueWordsInAscending()
			return This.UniqueWordsSortedInAscending()

			def UniqueWordsInAscendingQR(pcReturnType)
				if isList(pcReturnType) and Q(pcReturnType).IsReturnedNamedParam()
					pcReturnType = pcReturnType[2]
				ok

				switch pcReturnType
				on :stzListOfStrings
					return new stzListOfStrings(This.UniqueWordsInAscending())
	
				on :stzList
					return new stzList(This.UniqueWordsInAscending())
				other
					StzRaise("Unsupported returned type!")
				off
	
			def UniqueWordsInAscendingQ()
				return This.UniqueWordsInAscendingQR(:stzList)

		def SetOfWordsSortedInAscending()
			return This.UniqueWordsSortedInAscending()

			def SetOfWordsSortedInAscendingQR(pcReturnType)
				if isList(pcReturnType) and StzListQ(pcReturnType).IsOneOfTheseNamedParams([ :ReturnedAs, :ReturnAs ])
					pcReturnType = pcReturnType[2]
				ok

				switch pcReturnType
				on :stzListOfStrings
					return new stzListOfStrings(This.SetOfWordsSortedInAscending())
	
				on :stzList
					return new stzList(This.SetOfWordsSortedInAscending())
				other
					StzRaise("Unsupported returned type!")
				off
	
			def SetOfWordsSortedInAscendingQ()
				return This.SetOfWordsSortedInAscendingQR(:stzList)

		def SetOfWordsInAscendingOrder()
			return This.SetOfWordsSortedInAscending()

			def SetOfWordsInAscendingOrderQR(pcReturnType)
				if isList(pcReturnType) and StzListQ(pcReturnType).IsOneOfTheseNamedParams([ :ReturnedAs, :ReturnAs ])
					pcReturnType = pcReturnType[2]
				ok

				switch pcReturnType
				on :stzListOfStrings
					return new stzListOfStrings(This.SetOfWordsInAscendingOrder())
	
				on :stzList
					return new stzList(This.SetOfWordsInAscendingOrder())
				other
					StzRaise("Unsupported returned type!")
				off
	
			def SetOfWordsInAscendingOrderQ()
				return This.SetOfWordsInAscendingOrderQR(:stzList)

		def SetOfWordsInAscending()
			return This.SetOfWordsSortedInAscending()

			def SetOfWordsInAscendingQR(pcReturnType)
				if isList(pcReturnType) and Q(pcReturnType).IsReturnedNamedParam()
					pcReturnType = pcReturnType[2]
				ok

				switch pcReturnType
				on :stzListOfStrings
					return new stzListOfStrings(This.SetOfWordsInAscending())
	
				on :stzList
					return new stzList(This.SetOfWordsInAscending())
				other
					StzRaise("Unsupported returned type!")
				off
	
			def SetOfWordsInAscendingQ()
				return This.SetOfWordsInAscendingQR(:stzList)

		#>

	#--- 

	def UniqueWordsSortedInDescending()
		acResult = StzListOfStringsQ( This.UniqueWords() ).SortedInDescending()
		return acResult

		#< @FunctionFluentForm

		def UniqueWordsSortedInDescendingQR(pcReturnType)
			if isList(pcReturnType) and Q(pcReturnType).IsReturnedNamedParam()
				pcReturnType = pcReturnType[2]
			ok

			switch pcReturnType
			on :stzListOfStrings
				return new stzListOfStrings(This.UniqueWordsSortedInDescending())

			on :stzList
				return new stzList(This.UniqueWordsSortedInDescending())
			other
				StzRaise("Unsupported returned type!")
			off

		def UniqueWordsSortedInDescendingQ()
			return This.UniqueWordsSortedInDescendingQR(:stzList)

		#>

		#< @FunctionAlternativeForms

		def UniqueWordsInDescendingOrder()
			return This.UniqueWordsSortedInDescending()

			def UniqueWordsInDescendingOrderQR(pcReturnType)
				if isList(pcReturnType) and StzListQ(pcReturnType).IsOneOfTheseNamedParams([ :ReturnedAs, :ReturnAs ])
					pcReturnType = pcReturnType[2]
				ok

				switch pcReturnType
				on :stzListOfStrings
					return new stzListOfStrings(This.UniqueWordsInDescendingOrder())
	
				on :stzList
					return new stzList(This.UniqueWordsInDescendingOrder())
				other
					StzRaise("Unsupported returned type!")
				off
	
			def UniqueWordsInDescendingOrderQ()
				return This.UniqueWordsInDescendingOrderQR(:stzList)

		def UniqueWordsInDescending()
			return This.UniqueWordsSortedInDescending()

			def UniqueWordsInDescendingQR(pcReturnType)
				if isList(pcReturnType) and Q(pcReturnType).IsReturnedNamedParam()
					pcReturnType = pcReturnType[2]
				ok
		
				switch pcReturnType
				on :stzListOfStrings
					return new stzListOfStrings(This.UniqueWordsInDescending())
	
				on :stzList
					return new stzList(This.UniqueWordsInDescending())
				other
					StzRaise("Unsupported returned type!")
				off
	
			def UniqueWordsInDescendingQ()
				return This.UniqueWordsInDescendingQR(:stzList)

		def SetOfWordsSortedInDescending()
			return This.UniqueWordsSortedInDescending()

			def SetOfWordsSortedInDescendingQR(pcReturnType)
				if isList(pcReturnType) and Q(pcReturnType).IsReturnedNamedParam()
					pcReturnType = pcReturnType[2]
				ok

				switch pcReturnType
				on :stzListOfStrings
					return new stzListOfStrings(This.SetOfWordsSortedInDescending())
	
				on :stzList
					return new stzList(This.SetOfWordsSortedInDescending())
				other
					StzRaise("Unsupported returned type!")
				off
	
			def SetOfWordsSortedInDescendingQ()
				return This.SetOfWordsSortedInDescendingQR(:stzList)

		def SetOfWordsInDescendingOrder()
			return This.SetOfWordsSortedInDescending()

			def SetOfWordsInDescendingOrderQR(pcReturnType)
				if isList(pcReturnType) and Q(pcReturnType).IsReturnedNamedParam()
					pcReturnType = pcReturnType[2]
				ok

				switch pcReturnType
				on :stzListOfStrings
					return new stzListOfStrings(This.SetOfWordsInDescendingOrder())
	
				on :stzList
					return new stzList(This.SetOfWordsInDescendingOrder())
				other
					StzRaise("Unsupported returned type!")
				off
	
			def SetOfWordsInDescendingOrderQ()
				return This.SetOfWordsInDescendingOrderQR(:stzList)

		def SetOfWordsInDescending()
			return This.SetOfWordsSortedInDescending()

			def SetOfWordsInDescendingQR(pcReturnType)
				if isList(pcReturnType) and Q(pcReturnType).IsReturnedNamedParam()
					pcReturnType = pcReturnType[2]
				ok

				switch pcReturnType
				on :stzListOfStrings
					return new stzListOfStrings(This.SetOfWordsInDescending())
	
				on :stzList
					return new stzList(This.SetOfWordsInDescending())
				other
					StzRaise("Unsupported returned type!")
				off
	
			def SetOfWordsInDescendingQ()
				return This.SetOfWordsInDescendingQR(:stzList)

		#>

	#--- 

	def WordsReversed() # Returned in a list
		return ListReverse( This.Words() )

	#  Reversing the order of words inside the text
	def ReverseWords() # TODO
		/*
			1. ReplaceWordsWithMarquers()
			2. ReverseSortingOrderOfMarquers()
			3. ReplaceMarquersWithWords()
		*/

		def ReversWordsQR(pcReturnType)
			This.ReverseWords()
			return This

	def TextWithWordsReversed()
		return This.Copy().ReverseWordsQ().Content()

	#---

	def WordsPositions()
		/* Example:

		Q("mahmoud, ahmed, mohamed, Mahmoud, mahmoud, ahmed.") {
			? WordsPositions()
		}

		# --> [ 1, 10, 17, 26, 35, 44 ]
		*/

		aResult = []

		for cWord in This.UniqueWords()
			aResult + [ cWord, This.FindAllCS(cWord, :CS = FALSE) ]
		next

		aResult = StzHashListQ( aResult ).ValuesQ().MergeQ().SortedInAscending()

		return aResult

		#< @FunctionFluentForm

			def WordsPositionsQR(pcReturnType)
				if isList(pcReturnType) and Q(pcReturnType).IsReturnedNamedParam()
					pcReturnType = pcReturnType[2]
				ok

				switch pcReturnType
				on :stzListOfNumbers
					return new stzListOfNumbers( This.WordsPositions() )

				on :stzList
					return new stzList( This.WordsPositions() )

				other
					StzRaise("Unsupported return type!")
				off

			def WordsPositionsQ()
				return This.WordsPositionsQR(:stzList)

		#>

		#< @FunctionAlternativeForm

		def WordsOccurrences()
			return This.WordsPositions()

			def WordsOccurrencesQR(pcReturnType)
				if isList(pcReturnType) and Q(pcReturnType).IsReturnedNamedParam()
					pcReturnType = pcReturnType[2]
				ok

				switch pcReturnType
				on :stzListOfNumbers
					return new stzListOfNumbers( This.WordsPositions() )

				on :stzList
					return new stzList( This.WordsPositions() )

				other
					StzRaise("Unsupported return type!")
				off

			def WordsOccurrencesQ()
				return This.WordsOccurrencesQR(:stzList)

		#>

	#---

	def WordsSections()
		aWords = This.Words()
		aPositions = This.WordsPositions()
		/* Reminder: aPositions takes this form
			[ 1, 10, 17, 26, 35, 44 ]
		*/

		aResult = []
		i = 0

		for n in aPositions
			i++
			aResult + [ n, n + StzStringQ(aWords[i]).NumberOfChars() - 1 ]
		next

		return aResult

	#---

	def WordsAndTheirPositions()
		/* Example
		Q("mahmoud, ahmed, mohamed, mahmoud, mahmoud, ahmed.") {
			? WordsAndTheirPositions()
		}

		# --> [
			:mahmoud = [ 1, 26, 35 ],
			:ahmed   = [ 10, 44 ],
			:mohamed = [ 17 ]
		      ]
		*/

		aResult = []

		for cWord in This.UniqueWords()
			aResult + [ cWord, This.FindAllCS(cWord, :CS = FALSE) ]
		next

		return aResult

		def WordsAndTheirOccurrences()
			return This.WordsAndTheirPositions()

	#---

	def WordsAndTheirSections()
		/* Example:

		Q("mahmoud, ahmed, mohamed, Mahmoud, mahmoud, ahmed.") {
			? WordsAndTheirPositionsXT()
			# --> [
			# 	:mahmoud = [ 1:7, 26:32, 35:41 ],
			# 	:ahmed   = [ 10:14, 44:48 ],
			# 	:mohamed = [ 17:23 ]
			#     ]
		}
		*/

		aResult = []

		aTemp = This.WordsAndTheirPositions()
		/* Reminder: aTemp has this form
			[
			:mahmoud = [ 1, 26, 35 ],
			:ahmed   = [ 10, 44 ],
			:mohamed = [ 17 ]
		      	]
		*/
		
		cWord = ""
		

		for aLine in aTemp
			cWord = aLine[1]
			aPos = []

			for nPos in aLine[2]
				n1 = nPos
				n2 = n1 + StzStringQ(cWord).NumberOfChars() - 1

				aPos + [n1, n2]
			next

			aResult + [ cWord, aPos ]
		next

		return aResult

	#---

	def WordsAndNumbersOfTheirOccurrences()
		/* Example:

		Q("mahmoud, ahmed, mohamed, Mahmoud, mahmoud, ahmed.") {
			? WordsAndNumbersOfTheirOccurrences()
		}

		# --> [
			:mahmoud = 3,
			:ahmed   = 2,
			:mohamed = 1
		*/

		aResult = []

		for cWord in This.UniqueWords()
			aResult + [ cWord, This.NumberOfOccurrencesCS(cWord, :CS = FALSE) ]
		next

		return aResult

		def WordsAndTheirNumbersOfOccurrences()
			return This.WordsAndNumbersOfTheirOccurrences()
	
	def NumberOfOccurrenceOfWord(pcWord)

		if NOT ( isString(pcWord) and StringIsWord(pcWord) )

			StzRaise(stzStringError(:CanNotComputeNumberOfOccurrenceOfWord))
		ok

		# This solution (the line hereafter) takes 2.53s, a lot!
		# aResult = StzListOfStringsQ( This.Words() ).NumberOfOccurrenceOfString(pcWord)

		# The following is a better alternative taking almost 0s:

		# t0 = clock()

		oCopy = This.LowercaseQ().SimplifyQ()
		cWord = StzStringQ(pcWord).Lowercased()

		acSeps = WordSeparators()
		# Reminder:
		# _acWordSeparators = [ " ", ".", ",", ";", ":", "!", "?", "؟", "،", "'", "’", "—"  ]

		# Counting words at the start or end of the string

		nResult = 0

		for cSep in acSeps
			nResult += oCopy.BeginsWith(pcWord + cSep)
			nResult += oCopy.EndsWith(cSep + pcWord)
		next

		# Counting words inside the string

		for cSep in acSeps
			nResult += oCopy.NumberOfOccurrence(" " + pcWord + cSep)
		next

		# Counting words bounded by special signs: (), [], "", and ''
		
		acWordBounds = WordBoundingChars()

		for aPairOfBounds in acWordBounds
			cLeftBound  = aPairOfBounds[1]
			cRightBound = aPairOfBounds[2]

			nResult += oCopy.NumberOfOccurrence(cLeftBound + pcWord + cRightBound)
			nResult += oCopy.NumberOfOccurrence(cLeftBound + " " + pcWord + " " + cRightBound)
			nResult += oCopy.NumberOfOccurrence(cLeftBound + pcWord + " " + cRightBound)
			nResult += oCopy.NumberOfOccurrence(cLeftBound + " " + pcWord + cRightBound)

		next

		# TODO: When RegExp is implemented, use it instead.

		# ? ( clock() - t0 ) / clockspersecond()

		return nResult

		#< @FunctionCasesensitiveForm

		def NumberOfOccurrenceOfWordCS(pcWord, pCaseSensitive)
			return StzListOfStringsQ( This.Words() ).NumberOfOccurrenceOfStringCS(pcWord, pCaseSensitive)
	
			def NumberOfOccurrencesOfWordCS(pcWord, pCaseSensitive)
				return This.NumberOfOccurrenceOfWordCS(pcWord, pCaseSensitive)
		#>

		#< @FunctionAlternativeForm

		def NumberOfOccurrencesOfWord(pcWord)
			return This.NumberOfOccurrenceOfWord(pcWord)

	#---

	def WordFrequency(pcWord)

		if This.IsEmpty()
			StzRaise("Can't compute WordFrequency()! String is empty.")
		ok

		n = This.NumberOfWords()

		if n = 0
			StzRaise("Can't compute WordFrequency()! String contains nos words.")
		ok

		n = This.NumberOfOccurrenceOfWord(pcWord) / This.NumberOfWords()
		return n

		def FrequencyOfWord(pcWord)
			return This.WordFrequency(pcWord)

		def FrequencyOfThisWord(pcWord)
			return This.WordFrequency(pcWord)

	def WordAndItsFrequency(pcWord)
		aResult = [ pcWord, This.WordFrequency(pcWord) ]
		return aResult
		
	def WordsFrequencies()

		acWords = This.Words()
		aResult = []

		for cWord in acWords

			aResult + This.WordFrequency(cWord)
			/* TODO
			Should be optimised to avoid computing WordFrequency()
			for the same word many times!
			*/
		next

		return aResult

		def WordsFrequenciesQ()
			return This.WordsFrequenciesQR(:stzList)

		def WordsFrequenciesQR(pcReturnType)
			if isList(pcReturnType) and Q(pcReturnType).IsReturnedNamedParam()
				pcReturnType = pcReturnType[2]
			ok

			switch pcReturnType
			on :stzList
				return new stzList( This.WordsFrequencies() )

			on :stzListOfNumbers
				return new stzListOfNumbers( This.WordsFrequencies() )

			other
				StzRaise("Unsupported return type!")
			off

	def UniqueWordsFrequencies()

		acWords = This.UniqueWords()
		aResult = []

		for cWord in acWords
			aResult + This.WordFrequency(cWord)
		next

		return aResult

		def UniqueWordsFrequenciesQ()
			return This.UniqueWordsFrequenciesQR(:stzList)

		def UniqueWordsFrequenciesQR(pcReturnType)
			if isList(pcReturnType) and Q(pcReturnType).IsReturnedNamedParam()
				pcReturnType = pcReturnType[2]
			ok

			switch pcReturnType
			on :stzList
				return new stzList( This.UniqueWordsFrequencies() )

			on :stzListOfNumbers
				return new stzListOfNumbers( This.UniqueWordsFrequencies() )

			other
				StzRaise("Unsupported return type!")
			off

	def WordsAndTheirFrequencies()
		aResult = []

		acWords     = This.UniqueWords()
		anWordFreqs = This.WordsFrequencies()

		aResult = StzListQ( acWords ).AssociatedWith( anWordFreqs )

		return aResult

	#---

	def TheseWordsFrequencies(pacWords)
		aResult = []

		for cWord in pacWords
			aResult + This.WordFrequency(cWord)
		next

		return aResult

		def FrequenciesOfWords(pacWords)
			return This.TheseWordsFrequencies(pacWords)

		def FrequenciesOfTheseWords(pacWords)
			return This.TheseWordsFrequencies(pacWords)

	def TheseWordsAndTheirFrequencies(pacWords)
		aResult = []

		acWords = StzListQ(pacWords).DuplicatesRemoved()

		anWordFreqs = This.TheseWordsFrequencies(acWords)

		aResult = StzListQ( acWords ).AssociatedWith( anWordFreqs )

		return aResult

	#---

	def MostFrequentWord()

		aWordsFreqs = This.WordsAndTheirFrequencies()

		oHashList = StzHashListQ( aWordsFreqs )
		n = oHashList.ValuesQR(:stzListOfNumbers).FindMax()

		return aWordsFreqs[n][1]

		def TopOneFrequentWord()
			return This.MostFrequentWord()

	def MostFrequentWordAmongTheseWords(pacWords)
		aWordsFreqs = This.TheseWordsAndTheirFrequencies(pacWords)

		oHashList = StzHashListQ( aWordsFreqs )
		n = oHashList.ValuesQR(:stzListOfNumbers).FindMax()

		return aWordsFreqs[n][1]

		def MostFrequentWordAmong(pacWords)
			return This.MostFrequentWordAmongTheseWords(pacWords)

		def TopOneFrequentWordAmongTheseWords(pacWords)
			return This.MostFrequentWordAmongTheseWords(pacWords)

		def TopOneFrequentWordAmong(pacWords)
			return This.MostFrequentWordAmongTheseWords(pacWords)

	#---

	def NMaxFrequencies(n)
		aWordsFreqs = This.WordsAndTheirFrequencies()

		oHashList = StzHashListQ( aWordsFreqs )
		anMaxFreq = oHashList.ValuesQR(:stzList).RemoveDuplicatesQ().ToStzListOfNumbers().MaxNumbers(n)

		return anMaxFreq

	def WordsHavingThisFrequency(pnFreq)
		aWordsFreqs = This.WordsAndTheirFrequencies()

		acResult = []

		for aPair in aWordsFreqs
			cWord = aPair[1]
			nFreq = aPair[2]

		if StzNumberQ(nFreq).Content() = StzNumberQ(pnFreq).Content() and
		   ring_find(acResult, cWord) = 0

				acResult + cWord
			ok

		next

		acResult = StzListQ(acResult).DuplicatesRemoved()
		return acResult

		def WordsWithFrequency(pnFreq)
			return This.WordsHavingThisFrequency(pnFreq)

		def WordsWithThisFrequency(pnFreq)
			return This.WordsHavingThisFrequency(pnFreq)
			
	def WordsHavingTheseFrequencies(panFreq)
		panFreq = StzListQ(panFreq).DuplicatesRemoved()

		aResult = []

		for nFreq in panFreq
			aResult + This.WordsWithFrequency(nFreq)
		next

		return aResult
		

		def WordsWithFrequencies(panFreq)
			return This.WordsHavingTheseFrequencies(panFreq)

		def WordsWithTheseFrequencies(panFreq)
			return This.WordsHavingThisFrequencies(panFreq)
			
	def FequenciesAndTheirWords(panFreq)
		panFreq = StzListQ(panFreq).DuplicatesRemoved()

		aResult = []

		for nFreq in panFreq
			aResult + [ "" + nFreq, This.WordsWithFrequency(nFreq) ]
			# NOTE: we stringify nFreq to be able to use the list as a hashlist
		next

		return aResult

	def NMostFrequentWords(n)
		/* Example

		cText = "John is the son of John second. 
		Second son of John second is William second."

		o1 = stzText(cText)
		? o1.NMostFrequentWords(3)

		# --> [ "william", "john", "second" ]

		Look to the intermediate results hereafter...
		*/

		# STEP 1: Getting the max frequencies

		anMaxFreqs = This.NMaxFrequencies(n)
		# --> [ 0.27, 0.20, 0.13 ]

		# STEP 2 : Sorting those max frequencies in descending
		# and then getting them and their relative words

		aFreqsWords = This.FequenciesAndTheirWords( reverse(sort(anMaxFreqs)) )
		# --> [
		# 	[ "0.27", [ "william" ] ],
		# 	[ "0.20", [ "john", "second" ] ],
		# 	[ "0.13", [ "is", "son", "of" ] ]
		#     ]

		# STEP 3: As you see, it's a beatifull sorted hashlist in descending
		# So let's get all the words from that HashlList

		aResult = []

		oHashList = new stzHashList( aFreqsWords )
		acWords = ListsMerge( oHashList.Values() )

		# --> [  "william", "john", "second", "is", "son", "of" ]

		# STEP 4: Finally, we take the first n words of it

		aResult = StzListQ(acWords).Section(1, n)

		return aResult

		def TopNFrequentWords(n)
			return This.NMostFrequentWords(n)

	def NMostFrequentWordsAndTheirFrequencies(n)
		/* Example

		cText = "John is the son of John second. 
		Second son of John second is William second."

		o1 = stzText(cText)
		? o1.NMostFrequentWords(3)

		# --> [ "william", "john", "second" ]

		Look to the intermediate results hereafter...
		*/

		anMaxFreqs = This.NMaxFrequencies(n)
		# --> [ 0.27, 0.20, 0.13 ]

		aFreqsWords = This.FequenciesAndTheirWords( reverse(sort(anMaxFreqs)) )
		# --> [
		# 	[ "0.27", [ "william" ] ],
		# 	[ "0.20", [ "john", "second" ] ],
		# 	[ "0.13", [ "is", "son", "of" ] ]
		#     ]

		oHashList = new stzHashList( aFreqsWords )
		acWords = ListsMerge( oHashList.Values() )
		# --> [  "william", "john", "second", "is", "son", "of" ]

		# For the first n words of that list, looking for their frequencies

		aResult = []

		i = 0
		for cWord in acWords
			i++
			if i <= n

				# Finding the freq of cWord in aFreqsWords
				# (to better understand , see its content above)

				for aPair in aFreqsWords
					
					aListOfWords = aPair[2]
					cFreq = aPair[1]

					if ring_find( aListOfWords, cWord ) > 0
						# We've find it here! Take it an exit
						nFreq = 0+ cFreq
						aResult + [ cWord, nFreq ]
						exit
					ok
				next
			else
				exit
			ok
		next

		return aResult

	def NMostFrequentWordsAmongTheseWords(n, pacWords)
		aWordsFreqs = This.TheseWordsAndTheirFrequencies(pacWords)

		oHashList = StzHashListQ( aWordsFreqs )
		anPos = oHashList.ValuesQR(:stzListOfNumbers).FindFirstNMaxNumbers(n)

		aResult = []

		for n in anPos
			aResult + aWordsFreq[n][1]
		next

		return aResult

		def NMostFrequentWordsAmong(n, pacWords)
			return This.NMostFrequentWordsAmongTheseWords(n, pacWords)

	#---

	def TopTenFrequentWords()
		return This.NMostFrequentWords(10)

		#< @functionAlternativeForms

		def Top10FrequentWords()
			return This.TopTenFrequentWords()

		def TopTenWords()
			return This.TopTenFrequentWords()

		def Top10Words()
			return This.TopTenFrequentWords()

		#>

	def TopTenFrequentWordsAmongTheseWords(pacWords)
		if len(pacWords) < 10
			StzRaise("Number of words in pacWords must be greater then 10!")
		ok

		return This.NMostFrequentWordsAmong(10, pacWords)

		#< @FunctionAlternativeForms

		def TopTenFrequentWordsAmong(pacWords)
			return This.TopTenFrequentWordsAmongTheseWords(pacWords)

		def Top10FrequentWordsAmongTheseWords(pacWords)
			return This.TopTenFrequentWordsAmongTheseWords(pacWords)

		def Top10FrequentWordsAmong(pacWords)
			return This.TopTenFrequentWordsAmongTheseWords(pacWords)

		def TopTenWordsAmongTheseWords(pacWords)
			return This.TopTenFrequentWordsAmongTheseWords(pacWords)

		def TopTenWordsAmong(pacWords)
			return This.TopTenFrequentWordsAmongTheseWords(pacWords)

		def Top10WordsAmongTheseWords(pacWords)
			return This.TopTenFrequentWordsAmongTheseWords(pacWords)

		def Top10WordsAmong(pacWords)
			return This.TopTenFrequentWordsAmongTheseWords(pacWords)

		#>

	def TopFiveFrequentWords()
		return This.NMostFrequentWords(5)


		#< @functionAlternativeForms

		def Top5FrequentWords()
			return This.TopFiveFrequentWords()

		def TopFivenWords()
			return This.TopFiveFrequentWords()

		def Top5Words()
			return This.TopFiveFrequentWords()

		#>

	def TopFiveFrequentWordsAmongTheseWords(pacWords)
		if len(pacWords) < 5
			StzRaise("Number of words in pacWords must be greater then 5!")
		ok

		return This.NMostFrequentWordsAmong(5, pacWords)

		#< @FunctionAlternativeForms

		def TopFiveFrequentWordsAmong(pacWords)
			return This.TopFiveFrequentWordsAmongTheseWords(pacWords)

		def Top5FrequentWordsAmongTheseWords(pacWords)
			return This.TopFiveFrequentWordsAmongTheseWords(pacWords)

		def Top5FrequentWordsAmong(pacWords)
			return This.TopFiveFrequentWordsAmongTheseWords(pacWords)

		def TopFiveWordsAmongTheseWords(pacWords)
			return This.TopFiveFrequentWordsAmongTheseWords(pacWords)

		def TopFiveWordsAmong(pacWords)
			return This.TopFiveFrequentWordsAmongTheseWords(pacWords)

		def Top5WordsAmongTheseWords(pacWords)
			return This.TopFiveFrequentWordsAmongTheseWords(pacWords)

		def Top5WordsAmong(pacWords)
			return This.TopFiveFrequentWordsAmongTheseWords(pacWords)

		#>

	def TopThreeFrequentWords()
		return This.NMostFrequentWords(3)

		#< @functionAlternativeForms

		def Top3FrequentWords()
			return This.TopThreeFrequentWords()

		def TopThreeWords()
			return This.TopThreeFrequentWords()

		def Top3Words()
			return This.TopThreeFrequentWords()

		#>

	def TopThreeFrequentWordsAmongTheseWords(pacWords)
		if len(pacWords) < 3
			StzRaise("Number of words in pacWords must be greater then 3!")
		ok

		return This.NMostFrequentWordsAmong(3, pacWords)

		#< @FunctionAlternativeForms

		def TopThreeFrequentWordsAmong(pacWords)
			return This.TopThreeFrequentWordsAmongTheseWords(pacWords)

		def Top3FrequentWordsAmongTheseWords(pacWords)
			return This.TopThreeFrequentWordsAmongTheseWords(pacWords)

		def Top30FrequentWordsAmong(pacWords)
			return This.TopThreeFrequentWordsAmongTheseWords(pacWords)

		def TopThreeWordsAmongTheseWords(pacWords)
			return This.TopThreeFrequentWordsAmongTheseWords(pacWords)

		def TopThreeWordsAmong(pacWords)
			return This.TopThreeFrequentWordsAmongTheseWords(pacWords)

		def Top3WordsAmongTheseWords(pacWords)
			return This.TopThreeFrequentWordsAmongTheseWords(pacWords)

		def Top3WordsAmong(pacWords)
			return This.TopThreeFrequentWordsAmongTheseWords(pacWords)

		#>

	#---

	def LessFrequentWord()
		aWordsFreqs = This.WordsAndTheirFrequencies()

		oHashList = StzHashListQ( aWordsFreqs )
		n = oHashList.ValuesQR(:stzListOfNumbers).FindMin()

		return aWordsFreqs[n][1]

	def LessFrequentWordAmongTheseWords(pacWords)
		aWordsFreqs = This.TheseWordsAndTheirFrequencies(pacWords)

		oHashList = StzHashListQ( aWordsFreqs )
		n = oHashList.ValuesQR(:stzListOfNumbers).FindMin()

		return aWordsFreqs[n][1]

		def LessFrequentWordAmong(pacWords)
			return This.LessFrequentWordAmongTheseWords(pacWords)

	#---

	def NLessFrequentWords(n)
		aWordsFreqs = This.WordsAndTheirFrequencies()

		oHashList = StzHashListQ( aWordsFreqs )
		anPos = oHashList.ValuesQR(:stzListOfNumbers).ReverseQ().FindTop(n)

		aResult = []

		for nPos in anPos
			aResult + aWordsFreq[nPos][1]
		next

		return aResult

		def LessNFrequentWords(n)
			return This.NLessFrequentWords(n)

	def NLessFrequentWordsAmongTheseWords(n, pacWords)
		aWordsFreqs = This.TheseWordsAndTheirFrequencies(pacWords)

		oHashList = StzHashListQ( aWordsFreqs )
		anPos = oHashList.ValuesQR(:stzListOfNumbers).FindMinNumbers(n)

		aResult = []

		for n in anPos
			aResult + aWordsFreq[n][1]
		next

		return aResult

		#< @FunctionAlternativeForms

		def LessNFrequentWordsAmongTheseWords(n, pacWords)
			return This.NLessFrequentWordsAmongTheseWords(n, pacWords)

		def NLessFrequentWordsAmong(n, pacWords)
			return This.NLessFrequentWordsAmongTheseWords(n, pacWords)

		def LessNFrequentWordsAmong(n, pacWords)
			return This.NLessFrequentWordsAmongTheseWords(n, pacWords)

	#---
			
	def RemoveWords()

		for cWord in This.Words()
			This - cWord
		next

		def RemoveWordsQ()
			This.RemoveWords()
			return This

	def WordsRemoved()
		cResult = This.Copy().RemoveWordsQ().Content()
		return cResult

	def ReplaceWordsWithMarquers()
		This.ReplaceWordsWithMarquersXT([ :By = :OrderOfOccurrenceOfWords ])

	def ReplaceWordsWithMarquersXT(paOptions)

		/* Example

		StzTextQ("mahmoud, ahmed, mohamed, Mahmoud, mahmoud, ahmed.") {
			ReplaceWordsWithMarquersXT([
				:By = :OrderOfOccurrenceOfWords,
				:Except = [],
				:StopWords = :MustNotBeRemoved
			])
			# --> "#1, #2, #3, #4, #5, #6."
		}
		*/

		# NOTE: Generalize the way ooptions are managed here all over
		# the library. Features: Options can be added or not. If not,
		# a default value is considered ==> Flexiblity Objective

		# Controlling the type of the options list

		if NOT ( isList(paOptions) and StzListQ(paOptions).IsHashList() )

			StzRaise("Incorrect type of the option list!")
		ok

		# We are sure sofar we provided a hashlist. Let's analyze it.

		oHashList = StzHashListQ(paOptions)

		# Three options must be provided

	        if NOT oHashList.KeysQ().IsMadeOfOneOrMoreOfThese([ :By, :Except, :StopWords ])
			StzRaise("Incorrect options!")
		ok

		# We are sure sofar options are provided, let's retrieve them

		# Set a default value for the option :By

		pByValue = :OrderOfOccurrenceOfWords

		# Read its value if it exists

		if oHashList.ContainsKey(:pByValue)
			pByValue = oHashList.ValueByKey(:By)
			# If the option is not provided, then reinforce its default value 
			if isNull(pByValue) { pByValue = :OrderOfOccurrenceOfWords }

			# It an incorrect value is provided, raise an error
			if NOT ( isString(pByValue) and StzStringQ(pByValue).IsOneOfThese([
				:OrderOfOccurrence, :OrderOfOccurrenceOfWords,
				:AscendingOrder, :AscendingOrderOfWords,
				:DescendingOrder, :DescendingOrderOfWords ]) )
	
				StzRaise("Incorrect param format!")
			ok
		ok

		# Idem for the :Except option

		pExceptValue = [ ]
		if oHashList.ContainsKey(:Except)
			pExceptValue = oHashList.ValueByKey(:Except)
			if isNull(pExceptValue) { pExceptValue = [] }

			if NOT 	( isString(pExceptValue) or
				  ( isList(pExceptValue)) and
				    ( IsListOfStrings(pExceptValue) or len(pExceptValue) = 0 ) )

				StzRaise("Incorrect param format!")
			ok		
		ok

		# Idem for the :StopWords option

          	pStopWordsValue = :MustNotBeRemoved

		if oHashList.ContainsKey(:StopWords)
			pStopWordsValue = oHashList.ValueByKey(:StopWords)
			if isNull(pStopWordsValue) { pStopWordsValue = :MustNotBeRemoved }

			if NOT ( isString(pStopWordsValue) and

			         StzStringQ(pStopWordsValue).IsOneOfThese([
					:MustBeRemoved, :MustNotBeRemoved
				 	]) )

				StzRaise("Incorrect param format!")
			ok
		ok

		oWords = This.WordsQ()

		oWords - pExceptValue

		i = 0
		for cWord in aWords
			i++
			cMarquer = "#" + i
			
			
		next
		
	#-----
	
	def ContainsWord(pcWord)

		if This.SetOfWordsQ().Contains( StzStringQ(pcWord).Lowercased() )
			return  TRUE
		else
			return FALSE
		ok

	def ContainsNoWord(pcWord)
		return NOT This.ContainsWord(pcWord)

	#-----

	def ContainsEachWord(pacWords)
		bResult = TRUE
	
		for cWord in pacWords
			if This.ContainsNoWord(cWord)
				bResult = FALSE
				exit
			ok
		next

		return bResult

	#-----

	def ContainsNTimesTheWord(n, pcWord)
		
		if This.WordsQ().FindAll(pcWord) = n
			return TRUE
		else
			return FALSE
		ok

	def ContainsOneOccurrenceOfWord(pcWord)
			return This.ContainsNTimesTheWord(1, pcWord)

	def ContainsMoreThanOneOccurrenceOfWord(pcWord)
		return This.NumberOfOccurrenceOfWord(pcWord) > 1

	  #-------------------#
	 #   SORTING WORDS   #
	#-------------------#

	def WordsSortingOrder()
		cResult = :Unsorted

		if This.WordsAreSortedInAscending()
			cResult = :Ascending

		but This.WordsAreSortedInDescending()
			cResult = :Descending

		ok

		return cResult

	def HasSameWordsSortingOrderAs(pcOtherStr)

		oOtherWord = new stzWord(pcOtherStr)
		if oOtherWord.WordsSortingOrder() = This.WordsSortingOrder()
			return TRUE
		else
			return FALSE
		ok

		def HasSameWordsOrderAs(pcOtherStr)
			return This.HasSameWordsSortingOrderAs(pcOtherStr)

	def WordsAreSorted()
		if This.WordsAreSortedInAscending() or
		   This.WordsAreSortedInDescending()
			return TRUE
		else
			return FALSE
		ok

	def WordsAreSortedInAscending()
		/*
		The idea is to sort a copy of the words list in ascending order
		and then compare the copy to the original words list...

		If they are identical, then words are sorted in ascending order!

		Note: we pass here through stzList inorder to use
		its IsStrictlyEqualTo() feature...
		*/

		oSortedCopy = This.WordsQR(:stzList).SortInAscendingQ()

		if oSortedCopy.IsStrictlyEqualTo( This.Words() )
			return TRUE

		else
			return FALSE
		ok

	def WordsAreSortedInDescending()
		oSortedCopy = This.WordsQR(:stzList).SortInDescendingQ()

		if oSortedCopy.IsStrictlyEqualTo( This.Words() )
			return TRUE

		else
			return FALSE
		ok

	def SortWordsInAscending() # TODO
		/*
			1. Replace words with marquers
			2. Sort the marquers in ascending (inside the text string)
			2. Replace marquers by words

		*/
		
		def SortWordsInAscendingQ()
			This.SortWordsInAscending()
			return This
			
	def StringWithWordsSortedInAscending()
		cResult = This.Copy().SortWordsInAscendingQ().Content()
		return cResult

	def SortWordsInDescending() # TODO
		/*
			1. Replace words with marquers
			2. Sort the marquers in descending (inside the text string)
			2. Replace marquers by words

		*/

		def SortWordsInDescendingQ()
			This.SortWordsInDescending()
			return This
			
	def StringWithWordsSortedInDescending()
		cResult = This.Copy().SortWordsInDescendingQ().Content()
		return cResult

	  #----------------------------#
	 #    REPLACING MANY WORDS    #
	#----------------------------#

	#==> With CaseSensitive

	def ReplaceWordsCS(pacWords, pacNewWords, pCaseSensitive)
		This.ReplaceWordsWithMarquers()
		This.ReplaceMarquersWithWordsCS(pacNewWords, pCaseSensitive)

		#< @FunctionFluentForm

		def ReplaceWordsCSQ(pacWords, pacNewWords, pCaseSensitive)
			This.ReplaceWordsCS(pacWords, pacNewWords, pCaseSensitive)
			return This

		#>

		#< @FunctionAlternativeForms

		def ReplaceTheseWordsCS(pacWords, pacNewWords, pCaseSensitive)
			This.ReplaceWordsCS(pacWords, pacNewWords, pCaseSensitive)

			def ReplaceTheseWordsCSQ(pacWords, pacNewWords, pCaseSensitive)
				This.ReplaceTheseWordsCS(pacWords, pacNewWords, pCaseSensitive)
				return This

		def ReplaceManyWordsCS(pacWords, pacNewWords, pCaseSensitive)
			This.ReplaceWordsCS(pacWords, pacNewWords, pCaseSensitive)

			def ReplaceManyWordsCSQ(pacWords, pacNewWords, pCaseSensitive)
				This.ReplaceManyWordsCS(pacWords, pacNewWords, pCaseSensitive)
				return This

		def ReplaceEachWordCS(pacWords, pacNewWords, pCaseSensitive)
			This.ReplaceWordsCS(pacWords, pacNewWords, pCaseSensitive)

			def ReplaceEachWordCSQ(pacWords, pacNewWords, pCaseSensitive)
				This.ReplaceEachWordCS(pacWords, pacNewWords, pCaseSensitive)
				return This

		def ReplaceAllOccurrencesOfWordsCS(pacWords, pacNewWords, pCaseSensitive)
			This.ReplaceWordsCS(pacWords, pacNewWords, pCaseSensitive)

			def ReplaceAllOccurrencesOfWordsCSQ(pacWords, pacNewWords, pCaseSensitive)
				This.ReplaceAllOccurrencesOfWordCS(pacWords, pacNewWords, pCaseSensitive)
				return This

		#>

	def WordsReplacedCS(pacWords, pacNewWords, pCaseSensitive)
		cResult = This.Copy().ReplaceWordsCSQ(pacWords, pacNewWords, pCaseSensitive).Content()
		return cResult

		def TheseWordsReplacedCS(pacWords, pacNewWords, pCaseSensitive)
			return This.WordsReplacedCS(pacWords, pacNewWords, pCaseSensitive)

		def ManyWordsReplacedCS(pacWords, pacNewWords, pCaseSensitive)
			return This.WordsReplacedCS(pacWords, pacNewWords, pCaseSensitive)

		def EachWordReplacedCS(pacWords, pacNewWords, pCaseSensitive)
			return This.WordsReplacedCS(pacWords, pacNewWords, pCaseSensitive)
		
		def AllOccurrrencesOfWordsReplacedCS(pacWords, pacNewWords, pCaseSensitive)
			return This.WordsReplacedCS(pacWords, pacNewWords, pCaseSensitive)
		

	#==> WITHOUT CASESENSITIVITY

	def ReplaceWords(pacWords, pacNewWords)
		This.ReplaceWordsWithMarquers()
		This.ReplaceMarquersWithWords(pacNewWords)

		#< @FunctionFluentForm

		def ReplaceWordsQ(pacWords, pacNewWords)
			This.ReplaceWords(pacWords, pacNewWords)
			return This

		#>

		#< @FunctionAlternativeForms

		def ReplaceTheseWords(pacWords, pacNewWords)
			This.ReplaceWords(pacWords, pacNewWords)

			def ReplaceTheseWordsQ(pacWords, pacNewWords)
				This.ReplaceManyWordsCS(pacWords, pacNewWords)
				return This

		def ReplaceManyWords(pacWords, pacNewWords)
			This.ReplaceWords(pacWords, pacNewWords)

			def ReplaceManyWordsQ(pacWords, pacNewWords)
				This.ReplaceManyWordsCS(pacWords, pacNewWords)
				return This

		def ReplaceEachWord(pacWords, pacNewWords)
			This.ReplaceWords(pacWords, pacNewWords)

			def ReplaceEachWordQ(pacWords, pacNewWords)
				This.ReplaceEachWord(pacWords, pacNewWords)
				return This

		def ReplaceAllOccurrencesOfWords(pacWords, pacNewWords)
			This.ReplaceWordsCS(pacWords, pacNewWords)

			def ReplaceAllOccurrencesOfWordsQ(pacWords, pacNewWords)
				This.ReplaceAllOccurrencesOfWord(pacWords, pacNewWords)
				return This

		#>

	def WordsReplaced(pacWords, pacNewWords)
		cResult = This.Copy().ReplaceWordsQ(pacWords, pacNewWords).Content()
		return cResult

		def TheseWordsReplaced(pacWords, pacNewWords)
			return This.WordsReplaced(pacWords, pacNewWords)

		def ManyWordsReplaced(pacWords, pacNewWords)
			return This.WordsReplaced(pacWords, pacNewWords)

		def EachWordReplaced(pacWords, pacNewWords)
			return This.WordsReplaced(pacWords, pacNewWords)
		
		def AllOccurrrencesOfWordsReplaced(pacWords, pacNewWords)
			return This.WordsReplaced(pacWords, pacNewWords)
		
	  #--------------------------------#
	 #    REPLACING ONE GIVEN WORD    #
	#--------------------------------#

	#==> With CaseSensitive

	def ReplaceWordCS(pcWord, pcNewWord, pCaseSensitive)
		This.ReplaceWordsCS([ pcWord ], [ pcNewWord ], pCaseSensitive)

		#< @FunctionFluentForm

		def ReplaceWordCSQ(pcWord, pcNewWord, pCaseSensitive)
			This.ReplaceWordCS(pcWord, pcNewWord, pCaseSensitive)
			return This

		#>

		#< @FunctionAlternativeForms

		def ReplacThisWordCS(pcWord, pcNewWord, pCaseSensitive)
			This.ReplaceWordsCS(pcWord, pcNewWord, pCaseSensitive)

			def ReplaceThisWordsCSQ(pcWord, pcNewWord, pCaseSensitive)
				This.ReplacThisWordCS(pcWord, pcNewWord, pCaseSensitive)
				return This

		def ReplaceAllOccurrencesOfWordCS(pcWord, pcNewWord, pCaseSensitive)
			This.ReplaceWordCS(pcWord, pcNewWord, pCaseSensitive)

			def ReplaceAllOccurrencesOfWordCSQ(pcWord, pcNewWord, pCaseSensitive)
				This.ReplaceAllOccurrencesOfWordCS(pcWord, pcNewWord, pCaseSensitive)
				return This

		#>

	def WordReplacedCS(pcWord, pcNewWord, pCaseSensitive)
		cResult = This.Copy().ReplaceWordCSQ(pcWord, pcNewWord, pCaseSensitive).Content()
		return cResult

	#==> WITHOUT CASESENSITIVITY

	def ReplaceWord(pcWord, pcNewWord)
		This.ReplaceWordsCS(pcWord, pcNewWord, :CaseSensitive = TRUE)

		#< @FunctionFluentForm

		def ReplaceWordQ(pcWord, pcNewWord)
			This.ReplaceWord(pcWord, pcNewWord)
			return This

		#>

		#< @FunctionAlternativeForms

		def ReplacThisWord(pcWord, pcNewWord)
			This.ReplaceWords(pcWord, pcNewWord)

			def ReplaceThisWordsQ(pcWord, pcNewWord)
				This.ReplacThisWord(pcWord, pcNewWord)
				return This

		def ReplaceAllOccurrencesOfWord(pcWord, pcNewWord)
			This.ReplaceWord(pcWord, pcNewWord)

			def ReplaceAllOccurrencesOfWordQ(pcWord, pcNewWord)
				This.ReplaceAllOccurrencesOfWord(pcWord, pcNewWord)
				return This

		#>

	def WordReplaced(pcWord, pcNewWord)
		cResult = This.Copy().ReplaceWordQ(pcWord, pcNewWord).Content()
		return cResult

	  #----------------------------------------#
	 #    REPLACING NTH OCCURRENCE OF WORD    # TODO
	#----------------------------------------#
	
	def ReplaceNthWordCS(n, pcWord, pcNewSubStr, pCaseSensitive)
		// TODO

	def ReplaceNthWord(n, pcWord, pcNewSubStr)
		// TODO

	  #------------------------------------------#
	 #    REPLACING FIRST OCCURRENCE OF WORD    # 
	#------------------------------------------#

	def ReplaceFirstWordCS(pcWord, pcNewSubStr, pCaseSensitive)
		This.ReplaceNthWordCS(1, pcWord, pcNewSubStr, pCaseSensitive)

	def ReplaceFirstWord(pcWord, pcNewSubStr)
		This.ReplaceNthWord(1, pcWord, pcNewSubStr)

	  #------------------------------------------#
	 #    REPLACING LAST OCCURRENCE OF WORD     # 
	#------------------------------------------#

	def ReplaceLastWordCS(pcWord,vpcNewSubStr, pCaseSensitive)
			This.ReplaceNthWordCS(:Last, pcWord, pcNewSubStr, pCaseSensitive)
			
	def ReplaceLastWord(pcWord, pcNewSubStr)
		This.ReplaceNthWord(:Last, pcWord, pcNewSubStr)

	  #--------------------------------#
	 #     FORWARD TO END OF WORD     #
        #--------------------------------#

	def NumberOfLetters()
		nResult = This.NumberOfLetters()
		return nResult

	def ForwardToEndOfWord(nStart) # Starting at position n
		/* Example:
	
			o1 = new stzString( "Mohammed Ali Ben Salah" )
			? o1.ForwardToEndOfWord( 14 ) # --> Ben
			? o1.ForwardToEndOfWord( :StartingAt = 14 ) # --> Ben
			
		*/

		# Enabling the :StartingAt syntax

		if isList(nStart) and len(nStart) = 2 and
		   nStart[1] = :StartingAt and isNumber(nStart[2])

			nStart = nStart[2]

		ok

		# Checking the range of possible values for nStart param

		if nStart < 1 or nStart > This.NumberOfChars()
			return NULL
		ok

		# Computing the rest of the word

		bInside = TRUE
		cResult = ""
		i = nStart - 1

		while bInside
			i++
						 
			if i = This.NumberOfChars() or
			   This.CharAtQ(i).IsWordSeparator()

				bInside = FALSE
			
			else
				cResult += This.NthChar(i)
			ok
				
		end

		return cResult

		#< @FunctionFluentForm

		def ForwardToEndOfWordQ(nStart)
			return new stzString( This.ForwardToEndOfWord(nStart))

		#>
	
	  #---------------------#
	 #    REMOVING WORD    # 
	#---------------------#

	def RemoveAllWord(pcWord)
		// TODO

	def RemoveAllOccurrencesOfWord(pcWord)
		return This.FindAllWord(pcWord)

	def RemoveAllWordCS(pcWord, pCaseSensitive)
		// TODO

	def RemoveAllOccurrencesOfWordCS(pcWord, pCaseSensitive)
		return This.FindAllWordCS(pcWord, pCaseSensitive)
		
	def RemoveFirstWord(pcWord)
		// TODO

	def RemoveFirstWordCS(pcWord, pCaseSensitive)
		// TODO

	def RemoveLastWord(pcWord)
		// TODO

	def RemoveLastWordCS(pcWord, pCaseSensitive)
		// TODO

	def RemoveNthWord(pcWord)
		// TODO

	def RemoveNthWordCS(pcWord, pCaseSensitive)
		// TODO	

	def RemoveManyWords(pacWords)
		// TODO

	def RemoveManyWordsCS(pacWords)
		// TODO

	  #--------------------------------------#
	 #     FORWARD TO START OF NTH WORD     #
        #--------------------------------------#

	def ForwardToStartOfNthWord(n, nStart)

		aWordsAndPositions = This.WordsAndPositions()
		// TODO

	  #----------------------------------#
	 #     BACKWARD TO START OF WORD    #
        #----------------------------------#

	def BackwardToStartOfWord( nStart )

		/* Example:
	
			o1 = new stzString( "Mohammed Ali Ben Salah" )
			? o1.BackwardToStartOfWord( 12 ) # --> Ali
			? o1.BackwardToStartOfWord( :StartingAt = 12 ) # --> Ali
			
		*/

		# Enabling the :StartingAt syntax

		if isList(nStart) and len(nStart) = 2 and
		   nStart[1] = :StartingAt and isNumber(nStart[2])

			nStart = nStart[2]

		ok

		# Checking the range of possible values for nStart param

		if nStart < 1 or nStart > This.NumberOfChars()
			return NULL
		ok

		# Computing the rest of the word

		bInside = TRUE
		cResult = ""
		i = nStart + 1

		while bInside
			i--
					 
			if i = 0 or This.CharAtQ(i).IsWordSeparator()

				bInside = FALSE
			
			else
				cResult += This.NthChar(i)
			ok
				
		end

		return StringReverse(cResult)

		#< @FunctionFluentForm

		def BackwardToStartOfWordQ( nStart )
			return new stzString( This.BackwardToStartOfWord( nStart ) )
	
		#>

	  #------------------------------------------#
	 #      FINDING ALL OCCURRENCES OF WORD     # TODO
	#------------------------------------------#

	def FindAllOccurrencesOfWordCS(pcWord, pCaseSensitive)
		acPossibleWords = PossibleInstancesOfWord(pcWord)

		/* ... */


		#< @FunctionAlternativeForms

		def FindAllWordCS(pcWord, pCaseSensitive)
			return This.FindAllOccurrencesOfWordCS(pcWord, pCaseSensitive)

		def FindWordCS(pcWord, pCaseSensitive)
			return This.FindAllOccurrencesOfWordCS(pcWord, pCaseSensitive)

		def FindOccurrencesOfWordCS(pcWord, pCaseSensitive)
			return This.FindAllOccurrencesOfWordCS(pcWord, pCaseSensitive)

		#>

	def FindAllOccurrencesOfWord(pcWord)
		return This.FindAllOccurrencesOfWordCS(pcWord, :CaseSensitive = TRUE)
	
		#< @FunctionAlternativeForms

		def FindAllWord(pcWord)
			return This.FindAllOccurrencesOfWord(pcWord)

		def FindWord(pcWord)
			return This.FindAllOccurrencesOfWord(pcWord)

		def FindOccurrencesOfWord(pcWord)
			return This.FindAllOccurrencesOfWord(pcWord)

		def FindOccurrenceOfWord(pcWord)
			return This.FindAllOccurrencesOfWord(pcWord)

		def OccurrenceOfWord(pcWord)
			return This.FindAllOccurrencesOfWord(pcWord)
		
		def PositionsOfWord(pcWord)
			return This.FindAllOccurrencesOfWord(pcWord)

		def WordPosition(pcWord)
			return This.FindAllOccurrencesOfWord(pcWord)

		#>
	
	  #-----------------------------------------#
	 #      FINDING NTH OCCURRENCE OF WORD     # TODO: Test it
	#-----------------------------------------#
	
	# In principal, words are managed in lowercase (and this is what
	# Softanza does internally). But the user would may be needs
	# the case sensitivity feature for words, so here it is

	def FindNthOccurrenceOfWordCS(n, pcWord, pCaseSensitive)
		// TODO: Manage extreme cases

		if isString(n)
			if n = :First
				n = 1

			but n = :Last
				n = This.NumberOfWords()
			ok
		ok

		aWordsAndTheirPositions = This.WordsAndTheirPositions()
		nResult = aWordsAndTheirPositions[:pcWord][n]

		return nResult

		#< @FunctionAlternativeForm

		def FindNthWordCS(n, pcWord, pCaseSensitive)
			return This.FindNthOccurrenceOfWordCS(n, pcWord, pCaseSensitive)

		#>

		def PositionOfNthOccurrenceOfWordCS(n, pcWord, pCaseSensitive)
			return This.FindNthOccurrenceOfWordCS(n, pcWord, pCaseSensitive)

	def FindNthOccurrenceOfWord(n, pcWord)
		nResult = This.FindNthOccurrenceOfWordCS(n, pcWord, :CaseSensitive = FALSE)

		#< @FunctionAlternativeForm

		def FindNthWord(n, pcWord)
			return This.FindNthOccurrenceOfWord(n, pcWord)

		#>

		def PositionOfNthOccurrenceOfWord(n, pcWord, pCaseSensitive)
			return This.FindNthOccurrenceOfWordCS(n, pcWord, pCaseSensitive)

	  #-------------------------------------------#
	 #      FINDING FIRST OCCURRENCE OF WORD     # TODO: Test it!
	#-------------------------------------------#
	
	def FindFirstOccurrenceOfWordCS(pcWord, pCaseSensitive)
		return This.FindNthOccurrenceOfWordCS(1, pcWord, pCaseSensitive)

		#< @FunctionAlternativeForm

		def FindFirstWordCS(pcWord, pCaseSensitive)
			return This.FindFirstOccurrenceOfWordCS(pcWord, pCaseSensitive)

		#>

		def FindFirstWordsCS(pcWord, pCaseSensitive)
			return This.FindFirstOccurrenceOfWordCS(pcWord, pCaseSensitive)

		def FirstWordPositionCS(pcWord, pCaseSensitive)
			return This.FindFirstOccurrenceOfWordCS(pcWord, pCaseSensitive)

		def FirstPositionOfWordCS(pcWord, pCaseSensitive)
			return This.FindFirstOccurrenceOfWordCS(pcWord, pCaseSensitive)

	def FindFirstOccurrenceOfWord(pcWord)
		return This.FindFirstOccurrenceOfWordCS(pcWord, :CaseSensitive = FALSE)

		#< @FunctionAlternativeForms

		def FindFirstWord(pcWord)
			return This.FindFirstOccurrenceOfWord(pcWord)

		def FirstWordPosition(pcWord)
			return This.FindFirstOccurrenceOfWord(pcWord)

		def FirstPositionOfWord(pcword)
			return This.FindFirstOccurrenceOfWord(pcWord)

		#>

	  #------------------------------------------#
	 #      FINDING LAST OCCURRENCE OF WORD     # TODO: test it!
	#------------------------------------------#

	def FindLastOccurrenceOfWordCS(pcWord, pCaseSensitive)
		return This.FindNthOccurrenceOfWordCS(:Last, pcWord, pCaseSensitive)

		#< @FunctionAlternativeForm

		def FindLastWordCS(pcWord, pCaseSensitive)
			return This.FindLastOccurrenceOfWordCS(pcWord, pCaseSensitive)

		#>

		def FindLastWordsCS(pcWord, pCaseSensitive)
			return This.FindLastOccurrenceOfWordCS(pcWord, pCaseSensitive)

		def LastWordPositionCS(pcWord, pCaseSensitive)
			return This.FindLastOccurrenceOfWordCS(pcWord, pCaseSensitive)

		def LastPositionOfWordCS(pcWord, pCaseSensitive)
			return This.FindLastOccurrenceOfWordCS(pcWord, pCaseSensitive)


	def FindLastOccurrenceOfWord(pcWord)
		return This.FindLastOccurrenceOfWordCS(pcWord, :CaseSensitive = FALSE)

		#< @FunctionAlternativeForms

		def FindLastWord(pcWord)
			return This.FindLastOccurrenceOfWord(pcWord)

		def LastWordPosition(pcWord)
			return This.FindLastOccurrenceOfWord(pcWord)

		def LastPositionOfWord(pcword)
			return This.FindLastOccurrenceOfWord(pcWord)

		#>

	  #-----------------------------------#
	 #     FORWARD TO END OF SENTENCE    #
        #-----------------------------------#

	def ForwardToEndOfSentence(nStart)

		if isList(nStart) and len(nStart) = 2 and
		   nStart[1] = :StartingAt and isNumber(nStart[2])

			nStart = nStart[2]

		ok

		if nStart < 1 or nStart > This.ToStzString().NumberOfChars()
			return NULL
		ok

		bInside = TRUE
		cResult = ""
		i = nStart - 1

		while bInside
			i++
						 
			if i = This.NumberOfChars() or
			   This.CharAtQ(i).IsSentenceSeparator()
			   
				bInside = FALSE

			else
				cResult += This.NthChar(i)
			ok	
		end

		if cResult != NULL
			return cResult + This.NthChar(i)
		else
			return NULL
		ok

		#< @FunctionFluentForm

		def ForwardToEndOfSentenceQ(nStart)
			return new stzString( This.ForwardToEndOfSentence(nStart) )
	
		#>

	  #-----------------------------------------#
	 #     FORWARD TO START OF NTH SENTENCE    #
        #-----------------------------------------#

	def ForwardToStartOfNthSentence(n)
		// TODO

	def BackwardToStartOfSentence( nStart )

		/* Example:

		o1 = new stzString( "Sentence one.  Sentence two!" )
		? o1.BackwardToStartOfSentence( :StartingAt = 28 )

		--> Gives: Sentence two!
		*/

		# Manage the :StartingAt syntax

		if isList(nStart) and len(nStart) = 2 and
		   nStart[1] = :StartingAt and isNumber(nStart[2])

			nStart = nStart[2]

		ok

		# Check out of range value of nStart

		if nStart < 1 or nStart > This.NumberOfChars()
			return NULL
		ok

		# If the counting starts at a sentence separator
		# then let's save it to add to the final result

		cSentenceSep = ""

		if This.CharAtQ(nStart).IsSentenceSeparator()
			cSentenceSep = This[ nStart ]
			nStart--
		ok

		# Now, we start parsing from the nStart position
		# back to the start of sentence

		bInside = TRUE
		cResult = ""
		i = nStart + 1

		while bInside
			i--
					 
			if i = 0 or This.CharAtQ(i).IsSentenceSeparator()
				bInside = FALSE
		
			else
				cResult += oStringCopy.NthChar(i)

			ok
				
		end

		# We've got the result but it is reversed!
		# And it may contain some spaces at the
		# start of the sentence..

		cResult = StringReverse( cResult ) + cSentenceSep
		cResult = StzStringQ( cResult ).TrimmedFromStart()

		return cResult

		#< @FunctionFluentForm

		def BackwardToStartOfSentenceQ( nStart )
			return new stzString( This.BackwardToStartOfSentence() )	

		#>

	  #===================#
	 #      LETTERS      #
	#===================#

	// Returns the letters contained in the text
	def Letters()
		# t0 = clock()

		acResult = This.CharsW('StzCharQ(@char).IsLetter()') # Inherited from stzString

		# ? ( clock() - t0 ) / clockspersecond()

		return acResult

		def LettersQ()
			return This.LettersQR(:stzList)

		def LettersQR(pcReturnType)
			if isList(pcReturnType) and Q(pcReturnType).IsOneOfTheseNamedParams([ :ReturnedAs, :ReturnAs ])
				pcReturnType = pcReturnType[2]
			ok

			if NOT isString(pcReturnType)
				StzRaise("Icorrect param! pcReturnType must be a string.")
			ok

			switch pcReturnType
			on :stzList
				return new stzList( This.Letters() )

			on :stzListOfStrings
				return new stzListOfStrings( This.Letters() )

			on :stzListOfChars
				return new stzListOfChars( This.Letters() )

			other
				StzRaise("Unsupported return type!")
			off

	def LettersXT(paOptions)
		if NOT isList(paOptions)
			StzRaise("Incorrect param type! paOptions must be a list.")
		ok

		if len(paOptions) = 0
			return This.Letters()
		ok

		if paOptions[ :ManageArabicShaddah ] = TRUE

			# MANAGING THE SPECIAL CASE OF ARABIC SHADDAH ("ّ ")
	
			# In fact, arabic shaddah is a letter (and so isLetter()
			# should return TRUE), but the shaddah should'nt appear in
			# the list of letters as sutch ("ّ ") but as the letter that
			# comes right before it!
	
			acResult = This.Letters()

			if This.Contains(ArabicShaddah()) # Inherited from stzString
				anPos = StzListOfStringsQ(acResult).FindAll(ArabicShaddah())

				for n in anPos
					if n > 1
						acResult[n] = acResult[n-1]
					ok
				next
	
			ok
		ok

		return acResult

		def LettersXTQ(paOptions)
			return This.LettersXTQR(paOptions, :stzList)

		def LettersXTQR(paOptions, pcReturnType)
			if isList(pcReturnType) and Q(pcReturnType).IsOneOfTheseNamedParams([ :ReturnedAs, :ReturnAs ])
				pcReturnType = pcReturnType[2]
			ok

			if NOT isString(pcReturnType)
				StzRaise("Icorrect param! pcReturnType must be a string.")
			ok

			switch pcReturnType
			on :stzList
				return new stzList( This.LettersXT(paOptions) )

			on :stzListOfStrings
				return new stzListOfStrings( This.LettersXT(paOptions) )

			on :stzListOfChars
				return new stzListOfChars( This.LettersXT(paOptions) )

			other
				StzRaise("Unsupported return type!")
			off

	def UniqueLetters()
		return This.LettersQR(:stzListOfStrings).DuplicatesRemoved()

	def UniqueLettersXT(paOptions)
		return This.LettersXTQR(paOptions, :stzListOfStrings).DuplicatesRemoved()

		def UniqueLettersXTQ(paOptions)
			return This.UniqueLettersXTQR(paOptions, :stzList)

		def UniqueLettersXTQR(paOptions, pcReturnType)
			if isList(pcReturnType) and Q(pcReturnType).IsOneOfTheseNamedParams([ :ReturnedAs, :ReturnAs ])
				pcReturnType = pcReturnType[2]
			ok

			if NOT isString(pcReturnType)
				StzRaise("Icorrect param! pcReturnType must be a string.")
			ok

			switch pcReturnType
			on :stzList
				return new stzList( This.UniqueLettersXT(paOptions) )

			on :stzListOfStrings
				return new stzListOfStrings( This.UniqueLettersXT(paOptions) )

			on :stzListOfChars
				return new stzListOfChars( This.UniqueLettersXT(paOptions) )

			other
				StzRaise("Unsupported return type!")
			off

		def ToSetOfLettersXT(paOptions)
			return This.UniqueLettersXT(paOptions)

			def ToSetOfLettersXTQ(paOptions)
				return This.ToSetOfLettersXTQR(paOptions, :stzList)
	
			def ToSetOfLettersXTQR(paOptions, pcReturnType)
				if isList(pcReturnType) and Q(pcReturnType).IsOneOfTheseNamedParams([ :ReturnedAs, :ReturnAs ])
					pcReturnType = pcReturnType[2]
				ok
	
				if NOT isString(pcReturnType)
					StzRaise("Icorrect param! pcReturnType must be a string.")
				ok
	
				switch pcReturnType
				on :stzList
					return new stzList( This.ToSetOfLettersXT(paOptions) )
	
				on :stzListOfStrings
					return new stzListOfStrings( This.ToSetOfLettersXT(paOptions) )
	
				on :stzListOfChars
					return new stzListOfChars( This.ToSetOfLettersXT(paOptions) )
	
				other
					StzRaise("Unsupported return type!")
				off

	  #--------------------#
	 #    PSEUDO-WORDS    #
	#--------------------#

	/* NOTE
	
	PseudoWords are an effective alternative of Words. It's a quick-win
	that you can use in many cases, but the result is not as accurate as
	Words() provides where many controls are made to better identify words.

	In fact, pseudo-words are just substrings separated by spaces, no more.

	If they suit for your case, then use them. Otherwise, use Words() and
	expect yoursel to pay for performance.



	*/

	  #---------------------#
	 #      STOPWORDS      #
	#---------------------#

	def IsStopWordIn(pcLang)
		cCode = 'bResult = StopWordsInQ(:' + pcLang + ').Contains(This.Lowercased())'
		eval(cCode)
		return bResult

	def LanguageIfStopWord()
		if This.IsStopWord()
			return StopWordLanguage(This.String())
		ok

	def RemoveStopWordsInScript(pcScript)

		cCode =
			"for str in StopWordsIn(:" + pcScript + ")" + NL +
				tab + "This.RemoveAll(str)" + NL +
			"next"
	
		eval(cCode)

		/* Example of generated code:
		
			for str in ArabicStopWords()
				This.RemoveAll(str)
			next
		*/

		def RemoveStopWordsInScriptQ(pcScript)
			This.RemoveStopWordsInScriptQR(pcScript)
			return This

		def RemoveStopWordsIn(pcScript)
			This.RemoveStopWordsInScript(pcScript)

			def RemoveStopWordsInQ(pcScript)
				This.RemoveStopWordsIn(pcScript)
				return This

	  #---------------------#
	 #      SENTENCES      #
	#---------------------#

	def Sentences()
		cSep = SentenceSeparator()
		return This.Split(cSep)

		#< @FunctionFluentForm

		def SentencesQ()
			return This.SentencesQR(:stzList)

		def SentencesQR(pcReturnType)
			if isList(pcReturnType) and Q(pcReturnType).IsReturnedNamedParam()
				pcReturnType = pcReturnType[2]
			ok

			switch pcReturnType
			on :stzList
				return new stzList( This.Sentences() )
			on :stzListOfStrings
				return new stzListOfStrings( This.Sentences() )
			other
				StzRaise("Unsupported return type!")
			off
	
		#>

	  #----------------------#
	 #      PARAGRAPHS      #
	#----------------------#

	def Paragraphs()
		cSep = ParagraphSeparator()
		return This.Split( cSep )

		#< @FunctionFluentForm

		def ParagraphsQ()
			return This.ParagraphsQR(:stzList)

		def ParagraphsQR(pcReturnType)
			if isList(pcReturnType) and Q(pcReturnType).IsReturnedNamedParam()
				pcReturnType = pcReturnType[2]
			ok

			switch pcReturnType
			on :stzList
				return new stzList( This.Paragraphs() )
			on :stzListOfStrings
				return new stzListOfStrings( This.Paragraphs() )
			other
				StzRaise("Unsupported return type!")
			off
	
		#>

	  #----------------------#
	 #     PUNCTUATION      #
	#----------------------#

	def NumberOfPunctuations()
		nResult = 0

		acStzChars = This.ToListOfStzChars()

		for oChar in acStzChars
			if oChar.IsPunctuation()
				nResult++
			ok
		next

		return nResult

	def Punctuations()
		aResult = []

		acStzChars = This.ToListOfStzChars()

		for oChar in acStzChars
			if oChar.IsPunctuation()
				aResult + oChar.Content()
			ok
		next

		return aResult

	def NumberOfUniquePunctuations()
		return len( This.UniquePunctuations() )

		return nResult

	def UniquePunctuations()
		aResult = []

		acStzChars = This.ToListOfStzChars()

		for oChar in acStzChars
			cChar = oChar.Content()

			if oChar.IsPunctuation() and ring_find(aResult, cChar) = 0
				aResult + cChar
			ok
		next

		return aResult

	#---

	def NumberOfGeneralPunctuations()
		nResult = 0

		acStzChars = This.ToListOfStzChars()

		for oChar in acStzChars
			if oChar.IsGeneralPunctuation()
				nResult++
			ok
		next

		return nResult

	def GeneralPunctuations()
		aResult = []

		acStzChars = This.ToListOfStzChars()

		for oChar in acStzChars
			if oChar.IsGeneralPunctuation()
				aResult + oChar.Content()
			ok
		next

		return aResult

	def NumberOfUniqueGeneralPunctuations()
		return len( This.UniqueGeneralPunctuations() )

	def UniqueGeneralPunctuations()
		aResult = []

		acStzChars = This.ToListOfStzChars()

		for oChar in acStzChars
			cChar = oChar.Content()

			if oChar.IsGeneralPunctuation() and ring_find(aResult, cChar)
				aResult + cChar
			ok
		next

	#---

	def NumberOfSupplementalPunctuations()
		nResult = 0

		acStzChars = This.ToListOfStzChars()

		for oChar in acStzChars
			if oChar.IsSupplementalPunctuation()
				nResult++
			ok
		next

		return nResult

	def SupplementalPunctuations()
		aResult = []

		acStzChars = This.ToListOfStzChars()

		for oChar in acStzChars
			if oChar.IsSupplementalPunctuation()
				aResult + oChar.Content()
			ok
		next

		return aResult

	def NumberOfUniqueSupplementalPunctuations()
		return len( This.UniqueSupplementalPunctuations() )

	def UniqueSupplementalPunctuations()
		aResult = []

		acStzChars = This.ToListOfStzChars()

		for oChar in acStzChars
			cChar = oChar.Content()
			if oChar.IsSupplementalPunctuation() and ring_find(aResult, cChar)
				nResult + cChar
			ok
		next

		return aResult

#------------------------

	def RemovePunctuation()
		This.RemoveCharsWhere('{ StzCharQ(@char).IsPunctuation() }')

		def RemovePunctuationQ()
			This.RemovePunctuation()
			return This

		def RemovePunctuations()
			This.RemovePunctuation()
	
			def RemovePunctuationsQ()
				This.RemovePunctuations()
				return This
	
	def RemovePunctuationExcept(paChars)
		This.RemoveCharsWhere('StzCharQ(@char).isPunctuation() and NOT Q(@char).IsOneOfThese(' + @@(paChars) + ')')

		def RemovePunctuationExceptQ(paChars)
			This.RemovePunctuationExcept(paChars)
			return This
	
	  #--------------------------#
	 #    REMOVING DIACRITICS   # 
	#--------------------------#

	def IsDiacritics()
		bResult = TRUE

		for oStzChar in This.ToListOfStzChars()
			if NOT oStzChar.IsDiacritic()
				bResult = FALSE
				exit
			ok
		next

		return bResult

	def ContainsDiacritics()
		bResult = FALSE


		for oStzChar in This.ToListOfStzChars()
			if oStzChar.IsDiacritic() or oStzChar.IsDiacricised()
				bResult = TRUE
				exit
			ok
		next

		return bResult


	def RemoveDiacritics() # TODO: test this!

		/*
		Diacritics are marks placed above or below (or sometimes next to)
		a letter in a word to indicate a particular pronunciation—in
		regard to accent, tone, or stress—as well as meaning (Wikipedia).

		This function removes them from the string.

		Works differently depending of scripts.

		For latin, a word like "énoncé" is parsed and the two letters "é"
		(that are diacricized letters) are REPLACED with their original form "e".

		So we get "enonce".

		While for arabic, a word like "سُلَّمُُ" is parsed and the chars:
			 "ُ ", "ّ ", "َ ", "ُ ", and "ُ " are REMOVED from the string.

		So we get "سلم".

		Here I assume that Greek works like Latin, and Hebrew like Arabic.
		But we need to check this (TODO).

		*/

		switch This.Script()
	
		on :Latin
			This.ToStzString().ReplaceCharsW(
				:Where = '{ StzCharQ(@char).IsLatinDiacritic() }',
				:With  = '{ StzCharQ(@char).LatinDiacriticRemoved() }'
			)
	
		on :Arabic
			This.ToStzString().RemoveCharsW('{ StzCharQ(@char).IsArabicDiacritic() }')
	
		on :Greek
			This.ToStzString().ReplaceCharsW(
				:Where = '{ StzCharQ(@char).IsGreekDiacritic() }',
				:With  = 'StzCharQ(@char).RemoveGreekDiacritic()'
			)
			# TODO: I assumed that greek works like latin for diacritics,
			# but check this!
	
		on :Hebrew
			This.ToStzString().RemoveCharsWhere('{ StzCharQ(@char).IsHebrewDiacritic() }')
			# TODO: I assumed that hebrew works like arabic for diacritics,
			# but check this!
	
		other
			StzRaise("Can't remove diacritics for that script!")
		off
	
		def RemoveDiacriticsQ()
			This.RemoveDiacritics()
			return This

	def DiacriticsRemoved()
		cResult = This.Copy().RemoveDiacriticsQ().Content()
		return This

	# Latin diacritics

	def RemoveLatinDiacritics()
		// TODO
		
	# Arabic diacritics

	def IsArabicDiacritic()
		bResult = TRUE

		for oStzChar in This.ToListOfStzChars()
			if NOT oStzChar.IsArabicDiacritic()
				bResult = FALSE
				exit
			ok
		next

		return bResult

	def ContainsArabicDiacritics()
		bResult = FALSE

		for oStzChar in This.ToListOfStzChars()
			if oStzChar.IsArabicDiacritic()
				bResult = TRUE
				exit
			ok
		next

		return bResult

	def RemoveArabicDiacritics()
		// TODO

		def RemoveArabicDiacriticsQ()
			This.RemoveArabicDiacritics()
			return This

	def ArabicDiacriticsRemoved()
		cResult = This.Copy().RemoveArabicDiacriticsQ().Content()
		return cResult

/////////////////////////////////////

	# Greek diacritics

	def IsGreekDiacritic()
		// TODO

	def ContainsGreekDiacritics()
		// TODO

	def RemoveGreekDiacritics()
		// TODO

	# Hebrew diacritics

	def IsHebrewDiacritic()
		// TODO

	def ContainsHebrewDiacritics()
		// TODO

	def RemoveHebrewDiacritics()
		// TODO

	  #---------------------------------------------#
	 #    REMOVING DIACRITICS IN A GIVEN LOCALE    #  TODO
	#---------------------------------------------#

	/* Useful to do the undiacritization operation in a locale-specific
	   manner. Like in this example:

	? StzStringQ("München").DiacriticsRemovedInLocale([ :Language = :German ])

	!--> "Muenchen"

	Note that an "e" is added after the "u" that replaced "ü".
	*/

	def RemoveDiacriticsInLocale(pLocale)
		# TODO: add more speciefic languages (only german is managed here)
		# and special cases as documented in the Unicode standard here:
		# --> http://unicode.org/Public/UNIDATA/SpecialCasing.txt

		cLang = StzLocaleQ(pLocale).Language()

		switch cLang
		on :German
			# München -> Muenchen:
			# 	- ü is replaced with u 
			# 	- e is added after u
			This.ReplaceCharsW(
				:Where = '{ StzCharQ(@char).IsLatinDiacritic() }',
				:With  = '{ StzCharQ(@char).LatinDiacriticRemoved() + "e" }'
			)

		
		other
			This.RemoveDiacritics()

		off

		def RemoveDiacriticsInLocaleQ(pLocale)
			This.RemoveDiacriticsInrLocale(pLocale)
			return This

	def DiacriticsRemovedInLocale(pLocale)
		cResult = This.Copy().RemoveDiacriticsInLocaleQ(pLocale).Content()
		return This

	  #---------------#
	 #   INTITIALS   #
	#---------------#

	def Initials()
		aResult = This.SplitQR(:Using = " ", :stzListOfStrings).
			       Yield('Q(@str).FirstChar()')

		return aResult

		def InitialsQ()
			return This.InitialsQR(:stzList)

		def InitialsQR(pcReturnType)
			if isList(pcReturnType) and Q(pcReturnType).IsOneOfTheseNamedParams([ :ReturnedAs, :ReturnAs ])
				pcReturnType = pcReturnType[2]
			ok

			switch pcReturnType
			on :stzList
				return new stzList( This.Initials() )

			on :stzListOfStrings
				return new stzListOfStrings( This.Initials() )

			on :stzListOfChars
				return new stzListOfChars( This.Initials() )

			on :stzString
				return new stzString( This.InitialsQR(:stzListOfStrings).Concatenated() )

			on :stzText
				return new stzText( This.InitialsQR(:stzListOfStrings).Concatenated() )

			other
				StzRaise("Unsupported return type!")
			off

	def InitialsAsString()
		return This.InitialsQR(:stzString).Content()

	def InitialsAsText()
		return This.InitialsQR(:stzText).Content()

	  #------------------------#
	 #      CONTRACTIONS      #
	#------------------------#

	def Expand()
		// TODO

		/*
		don't	--> do not
		we've	--> we have
		did'nt	--> did not
		*/

	def Abbreviate()
		// TODO: inverse of Expand()

	#-----------#
	#   MISC.   #
	#-----------#

	def IsEmpty()
		if This.ContainsOnlySpaces()
			return TRUE
		else
			return FALSE
		ok

	def IsText()
		return TRUE
