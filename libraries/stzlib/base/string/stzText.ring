#-------------------------------------------------------------------------------#
# 		        SOFTANZA LIBRARY (V0.9) - stzText			#
#		    An accelerative library for Ring applications	      	#
#-------------------------------------------------------------------------------#
#										#
# 	Description	: The class for managing texts in Softanza		#
#	Version		: V0.9 (2020-2024)					#
#	Author		: Mansour Ayouni (kalidianow@gmail.com)		   	#
#										#
#-------------------------------------------------------------------------------#

#TODO // Replace all for/in loops by for loops

  ///////////////////
 ///   GLOBALS   ///
///////////////////

_cSentenceSeparator = "."
_cParagraphSeparator = NL
_cDefaultLanguage = :English

_cWordIdentificationMode = :Quick	# or :Strict

_acCharsAllowedInStartOfWord		= [ "_acCharsAllowedInStartOfWord" ]
_acCharsNotAllowedInStartOfWord 	= [ "_acCharsNotAllowedInStartOfWord" ]
_acSubStrAllowedInStartOfWord	= [ "_acSubStrAllowedInStartOfWord" ]
_acSubStrNotAllowedInStartOfWord	= [ "_acSubStrNotAllowedInStartOfWord" ]

_acCharsAllowedInsideWord		= [ "_acCharsAllowedInsideWord" ]
_acCharsNotAllowedInsideWord		= [ "_acCharsNotAllowedInsideWord" ]
_acSubStrAllowedInsideWord		= [ "_acSubStrAllowedInsideWord" ]
_acSubStrNotAllowedInsideWord	= [ "_acSubStrNotAllowedInsideWord" ]

_acCharsAllowedInEndOfWord		= [ "_acCharsAllowedInEndOfWord" ]
_acCharsNotAllowedInEndOfWord		= [ "_acCharsNotAllowedInEndOfWord" ]
_acSubStrAllowedInEndOfWord		= [ "_acSubStrAllowedInEndOfWord" ]
_acSubStrNotAllowedInEndOfWord	= [ "_acSubStrNotAllowedInEndOfWord" ]

  /////////////////////
 ///   FUNCTIONS   ///
/////////////////////

func SentenceSeparator()
	return _cSentenceSeparator

func ParagraphSeparator()
	return _cParagraphSeparator

func DefaultLanguage()
	return _cDefaultLanguage

func Language(cText)
	return StzTextQ(cText).Language()

	func @Language(cText)
		return Language(Text)

	#-- @Misspelled

	func Langauge(cText)
		return Language(cText)

	func @Langauge(cText)
		return Language(cText)

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

func IsStzText(p)
	return IsObject(p) and classname(p) = "stztext"

	func @IsStzText(p)
		return IsStzText(p)

# Useful four finding instances of WORDS (and not substrings!) inside a string
func PossibleWordInstancesXT(pcWord, cWordPositionInSentence)
	#INFO # There is a Qt function that does this : QTextBoundaryFinder
	#TODO # Include it in RingQt and then use it to detect words, sentence, lines etc

	/* REMINDER (from stzCharData.ring)

	# Word and sentence separators

	? WordSeparators()
	#--> gives [ " ", ".", ",", ";", ":", "!", "?", "؟", "،", "'", "’", "—"  ]

	? SentenceSeparators()
	#--> gives [ ".", "!", "?", "؟" ]

	? WordBoundingChars()
	#--> gives 
	# [
	# 	[ "(", ")" ], [ "[", "]" ], [ "{", "}" ], [ "'", "'" ], [ '"', '"' ]
	# ]

	? WordNonLetterChars()
	#--> gives ListsMerge([
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

func TheseSubstringsCanBeInStartOfWord(pacSubStr)
	_acSubStrAllowedInStartOfWord = pacSubStr

	func TheseSubstringsCanBeInStartOfAWord(pacSubStr)
		TheseSubstringsCanBeInStartOfWord(pacSubStr)

	func TheseSubstringsAreAllowedInStartOfWord(pacSubStr)
		TheseSubstringsCanBeInStartOfWord(pacSubStr)

	func TheseSubstringsAreAllowedInStartOfAWord(pacSubStr)
		TheseSubstringsCanBeInStartOfWord(pacSubStr)

	func AllowTheseSubstringsInStartOfWord(pacSubStr)
		TheseSubstringsCanBeInStartOfWord(pacSubStr)

	func AllowThesesubstringsInStartOfAWord(pacSubStr)
		TheseSubstringsCanBeInStartOfWord(pacSubStr)

func TheseSubstringsCanNotBeInStartOfWord(pacSubStr)
	_acSusbstringsNotAllowedInStartOfWord = pacSubStr

	func TheseSubstringsCanNotBeInStartOfAWord(pacSubStr)
		TheseSubstringsCanNotBeInStartOfWord(pacSubStr)

	func TheseSubstringsAreNotAllowedInStartOfWord(pacSubStr)
		TheseSubstringsCanNotBeInStartOfWord(pacSubStr)

	func TheseSubstringsAreNotAllowedInStartOfAWord(pacSubStr)
		TheseSubstringsCanNotBeInStartOfWord(pacSubStr)

	func DoNotAllowTheseSubstringsInStartOfWord(pacSubStr)
		TheseSubstringsCanNotBeInStartOfWord(pacSubStr)

	func DoNotAllowTheseSubstringsInStartOfAWord(pacSubStr)
		TheseSubstringsCanNotBeInStartOfWord(pacSubStr)

func SubstringsAllowedInStartOfWord()
	return _acSubStrAllowedInStartOfWord

	func AllowedSubstringsInStartOfWord()
		return SubstringsAllowedInStartOfWord()

func SubstringsNotAllowedInStartOfWord()
	return _acSubStrNotAllowedInStartOfWord

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
	_acSubStrAllowedInsideWord = pacChars

	func TheseSubstringsCanBeInsideAWord(pacSubStr)
		TheseSubstringsCanBeInsideWord(pacSubStr)

	func TheseSubstringsAreAllowedInsideWord(pacSubStr)
		TheseSubstringsCanBeInsideWord(pacSubStr)

	func TheseSubstringsAreAllowedInsideAWord(pacSubStr)
		TheseSubstringsCanBeInsideWord(pacSubStr)

	func AllowTheseSubstringsInsideWord(pacSubStr)
		TheseSubstringsCanBeInsideWord(pacSubStr)

	func AllowThesesubstringsInsideAWord(pacSubStr)
		TheseSubstringsCanBeInsideWord(pacSubStr)

func TheseSubstringsCanNotBeInsideWord(pacChars)
	_acCharsNotAllowedInsideWord = pacChars

	func TheseSubstringsCanNotBeInsideAWord(pacSubStr)
		TheseSubstringsCanNotBeInStartOfWord(pacSubStr)

	func TheseSubstringsAreNotAllowedInsideWord(pacSubStr)
		TheseSubstringsCanNotBeInsideWord(pacSubStr)

	func TheseSubstringsAreNotAllowedInsideAWord(pacSubStr)
		TheseSubstringsCanNotBeInsideWord(pacSubStr)

	func DoNotAllowTheseSubstringsInsideWord(pacSubStr)
		TheseSubstringsCanNotBeInsideWord(pacSubStr)

	func DoNotAllowTheseSubstringsInsideAWord(pacSubStr)
		TheseSubstringsCanNotBeInsideWord(pacSubStr)

func SubstringsAllowedInsideWord()
	return _acSubStrAllowedInsideWord

	func SubstringsAllowedInsideWords()
		return SubstringsAllowedInsideWord()

	func AllowedSubstringsInsideWord()
		return SubstringsAllowedInsideWord()

	func AllowedSubstringsInsideWords()
		return SubstringsAllowedInsideWord()

func SubstringsNotAllowedInsideWord()
	return _acSubStrNotAllowedInsideWord

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
	_acSubStrAllowedInEndOfWord = pacChars

	func TheseSubstringsCanBeInEndOfAWord(pacSubStr)
		TheseSubstringsCanBeInEndOfWord(pacSubStr)

	func TheseSubstringsAreAllowedInEndOfWord(pacSubStr)
		TheseSubstringsCanBeInEndOfWord(pacSubStr)

	func TheseSubstringsAreAllowedInEndOfAWord(pacSubStr)
		TheseSubstringsCanBeInEndOfWord(pacSubStr)

	func AllowTheseSubstringsInEndOfWord(pacSubStr)
		TheseSubstringsCanBeInEndOfWord(pacSubStr)

	func AllowThesesubstringsInEndOfAWord(pacSubStr)
		TheseSubstringsCanBeInEndOfWord(pacSubStr)


func TheseSubstringsCanNotBeInEndOfWord(pacChars)
	_acCharsNotAllowedInEndOfWord = pacChars

	func TheseSubstringsCanNotBeInEndOfAWord(pacSubStr)
		TheseSubstringsCanNotBeInEndOfWord(pacSubStr)

	func TheseSubstringsAreNotAllowedInEndOfWord(pacSubStr)
		TheseSubstringsCanNotBeInEndOfWord(pacSubStr)

	func TheseSubstringsAreNotAllowedInEndOfAWord(pacSubStr)
		TheseSubstringsCanNotBeInEndOfWord(pacSubStr)

	func DoNotAllowTheseSubstringsInEndOfWord(pacSubStr)
		TheseSubstringsCanNotBeInEndOfWord(pacSubStr)

	func DoNotAllowTheseSubstringsInEndOfAWord(pacSubStr)
		TheseSubstringsCanNotBeInEndOfWord(pacSubStr)

func SubstringsAllowedInEndOfWord()
	return _acSubStrAllowedInEndOfWord

	func AllowedSubstringsInEndOfWord()
		return SubstringsAllowedInEndOfWord()

func SubstringsNotAllowedInEndOfWord()
	return _acSubStrNotAllowedInEndOfWord

	func UnallowedSubstringsInEndOfWord()
		return CharsNotAllowedInEndOfWord()


  /////////////////
 ///   CLASS   ///
/////////////////

class stzText from stzString
	@oQString
	@cLanguage

	def init(pcStr)
		if isString(pcStr)
			@cContent = pcStr
			@oQString = new QString2()
			@oQString.append(pcStr)

		but @IsStzString(pcStr)
			@oQString = pcStr.QStringObject()

		else
			StzRaise("Can't create stzText object! You must provide a string or a stzString object.")
		ok

	  #----------------#
	 #    GENERAL     #
	#----------------#

	def Content()
		return QStringToString( @oQString )

	def Text()
		return This.Content()

	def Copy()
		return new stzText(This.Content())

	def ToStzString()
		return new stzString( This.Content() )

	def UpdateWith(pcStr)
		if CheckingParams()
			if NOT isString(pcStr)
				StzRaise("Incorrect param type! pcStr must be a string.")
			ok
		ok

		@cContent = pcStr
		@oQString = new QString2()
		@oQString.append(pcStr)

		if KeepingHisto() = 1
			This.AddHistoricValue(This.Content())  # From the parent stzObject
		ok

		def Update(pcStr)
			This.UpdateWith(pcStr)

	  #--------------------#
	 #      LANGUAGE      #
	#--------------------#

	def SetLanguage(pcLanguage)
		@cLanguage = pcLanguage

		#-- @Misspelled

		def SetLangauge(pcLanguage)
			This.SetLanguage(pcLanguage)

	def Language()
		return @cLanguage

		#-- @Misspelled

		def Langauge()
			return This.Language()

	  #----------------#
	 #     SCRIPT     #
	#----------------#

	/* #INFO
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

			# This beeing explained, the following algorithm becomes obvious!

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

		acResult = []

		aoStzChars = This.ToListOfStzChars()
		nLen = len(aoStzChars)

		for i = 1 to nLen
			acResult + aoStzChars[i].Script()
		next

		acResult = U( acResult )

		return acResult

	def NumberOfScripts()
		return len(This.Scripts())

		def CountScripts()
			return len(This.Scripts())

		def HowManyScripts()
			return len(This.Scripts())

	def ScriptOfNthChar(n)
		return This.CharAtQRT(n, :stzChar).Script()

	def ScriptsPerChar()
		aResult = []

		for c in This.UniqueChars()
			aResult + StzCharQRT(c, :stzChar).Script()
		next

		return aResult

	def ScriptIs(cScript)
		/*
		Example: all these return 1:

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
		
	#TODO // Not optimised for large texts!
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

	  #---------------------------------#
	 #   GETTING THE NUMBER OF WORDS   #
	#---------------------------------#

	def NumberOfWords()
		return len( This.Words() )

		def HowManyWords()
			return This.NumberOfWords()

	  #--------------------------------------------------------#
	 #   GETTING THE NUMBER OF WORDS -- WIHTOUT DUPLICATION   #
	#--------------------------------------------------------#

	def NumberOfUniqueWords()
		return len( This.SetOfWords() )

		def HowManyUniqueWordsU()
			return This.NumberOfUniqueWords()

		def NumberOfWordsWithoutDuplication()
			return This.NumberOfUniqueWords()

	  #------------------------------------#
	 #   CHECKING IF THE TEXT IS A WORD   #
	#------------------------------------#

	def IsWord()
		bResult = This.ToStzString().IsWord()
		return bResult

		def IsAWord()
			return This.IsWord()

	  #--------------------------------------------#
	 #   CHECKING IF THE TEXT IS AN ARABIC WORD   #
	#--------------------------------------------#

	def IsArabicWord()
		if This.IsWord() and This.ScriptIs(:Arabic)
			return 1
		else
			return 0
		ok

		def IsAnArabicWord()
			return This.IsArabicWord()

	  #------------------------------------------#
	 #   CHECKING IF THE TEXT IS A LATIN WORD   #
	#------------------------------------------#

	def IsLatinWord()
		if This.IsWord() and This.ScriptIs(:Latin)
			return 1
		else
			return 0
		ok

		def IsALatinWord()
			return This.IsLatinWord()


	#TODO // Add other scripts supported by Unicode standard


	  #----------------------------------------------------------#
	 #   GETTING THE WORDS IN THE TEXT EXCEPT THE GIVEN WORDS   #
	#----------------------------------------------------------#

	def WordsExcept(pacWords)
		if NOT ( isList(pacWords) and IsListOfStrings(pacWords) )

			StzRaise("Incorrect param type!")
		ok

		acWords = StzListOfStringsQ(pacWords).Lowercased()

		oWords = This.WordsQ()

		oWords - acWords
		aResult = oWords.Content()

		return aResult

	  #-------------------------------------------#
	 #   GETTING THE LIST OF WORDS IN THE TEXT   #
	#-------------------------------------------#

	def Words()
		/* TODO
	
		Manage case of composed-words like (meta-programming)
		and some spcial english worlds like (i.e.)

		Add a section for Composed words:

			IsComposedWord()
			ComposedWords()
			NumberOfComposedWords()
			
		And to consider or not them in word processing, add:

			ComposedWordsMustBeSeparated()
			ComposedWordsMusNotBeSeparated()

		*/

		oCopy = This.LowercaseQ() # Words are managed in lowercase in Softanza

		# t0 = clock()

		acResult = []

		if WordsIdentificationMode() = :Strict

			oCopy.RemovePunctuationExcept( WordNonLetterChars() )
			oCopy.SimplifyQ()

			acResult = oCopy.Split(" ")

		but WordsIdentificationMode() = :Quick

			oCopy.RemovePunctuations()
			acResult = oCopy.Split(" ")

		else
			StzRaise("Unkowan word identification mode!")
		ok

		# ? (clock() - t0) / clockspersecond()

		if StopWordsStatus() = :MustBeRemoved
			acResult = Q(acResult) - StopWordsIn( This.Language() )
		ok

		return acResult
		
		#< @FunctionFluentForm

		def WordsQ()
			return This.WordsQRT(:stzList)
	
		def WordsQRT(pcReturnType)
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

	  #-------------------------------------------------------#
	 #   GETTING THE WORDS IN THE TEXT WITHOUT DUPLICATION   #
	#-------------------------------------------------------#

	def SetOfWords()
		acResult = StzListQ( This.Words() ).DuplicatesRemoved()
		return acResult

		#< @FunctionFluentForm

		def SetOfWordsQ()
			return This.SetOfWordsQRT(:stzList)
	
		def SetOfWordsQRT(pcReturnType)
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

			def UniqueWordsQ()
				return This.UniqueWordsQRT(:stzList)

			def UniqueWordsQRT(pcReturnType)
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

		def WordsU()
			return This.SetOfWords()

			def WordsUQ()
				return This.UniqueWordsQRT(:stzList)

			def WordsUQRT(pcReturnType)
				return This.UniqueWordsQRT(pcReturnType)

		def WordsWithoutDuplication()
			return This.SetOfWords()

			def WordsWithoutDuplicationQ(pcReturnType)
				return This.UniqueWordsQRT(pcReturnType)

		#>

	  #---------------------------------------------------------------#
	 #   GETTING THE LIST OF WORDS IN THE TEXT SORTED IN ASCENDING   #
	#---------------------------------------------------------------#

	def WordsSortedInAscending()
		acResult = StzListOfStringsQ( This.Words() ).SortedInAscending()
		return acResult

		#< @FunctionFluentForm

		def WordsSortedInAscendingQRT(pcReturnType)
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
			return This.WordsSortedInAscendingQRT(:stzList)

		#>

		#< @FunctionAlternativeForms

		def WordsInAscending()
			return This.WordsSortedInAscending()

			def WordsInAscendingQRT(pcReturnType)
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
				return This.WordsInAscendingQRT(:stzList)

		def WordsInAscendingOrder()
			return This.WordsSortedInAscending()

			def WordsInAscendingOrderQRT(pcReturnType)
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
				return This.WordsInAscendingOrderQRT(:stzList)

		#>

	  #----------------------------------------------------------------#
	 #   GETTING THE LIST OF WORDS IN THE TEXT SORTED IN DESCENDING   #
	#----------------------------------------------------------------#

	def WordsSortedInDescending()
		acWords = StzListOfStringsQ( This.Words() ).SortedInDescending()
		return acWords

		#< @FunctionFluentForm

		def WordsSortedInDescendingQRT(pcReturnType)
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
			return This.WordsSortedInDescendingQRT(:stzList)

		#>

		#< @FunctionAlternativeForms

		def WordsInDescendingOrder()
			return This.WordsSortedInDescending()

			def WordsInDescendingOrderQRT(pcReturnType)
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
				return This.WordsInDesscendingOrderQRT(:stzList)

		def WordsInDescending()
			return This.WordsSortedInDescending()

			def WordsInDescendingQRT(pcReturnType)
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
				return This.WordsInDescendingQRT(:stzList)

		#>

	  #-----------------------------------------------------------------------------------#
	 #   GETTING THE LIST OF WORDS IN THE TEXT WITHOUT DUPLICATION SORTED IN ASCENDING   #
	#-----------------------------------------------------------------------------------#

	def UniqueWordsSortedInAscending()
		aResult = StzListOfStringsQ( This.UniqueWords() ).SortedInAscending()
		return aResult

		#< @FunctionFluentForm

		def UniqueWordsSortedInAscendingQ()
			return This.UniqueWordsSortedInAscendingQRT(:stzList)

		def UniqueWordsSortedInAscendingQRT(pcReturnType)
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

		#>

		#< @FunctionAlternativeForms

		def WordsUSortedInAscending()
			return This.UniqueWordsSortedInAscending()
	
			def WordsUSortedInAscendingQ()
				return This.WordsUSortedInAscendingQRT(:stzList)
	
			def WordsUSortedInAscendingQRT(pcReturnType)
				return This.UniqueWordsSortedInAscendingQRT(pcReturnType)
	
		def WordsUSortedInAscendingOrder()
			return This.UniqueWordsSortedInAscending()
	
			def WordsUSortedInAscendingOrderQ()
				return This.WordsUSortedInAscendingOrderQRT(:stzList)
	
			def WordsUSortedInAscendingOrderQRT(pcReturnType)
				return This.UniqueWordsSortedInAscendingQRT(pcReturnType)
	
		def WordsWithoutDuplicationSortedInAscending()
			return This.UniqueWordsSortedInAscending()
	
			def WordsWithoutDuplicationSortedInAscendingQ()
				return This.WordsWithoutDuplicationSortedInAscendingQRT(:stzList)
	
			def WordsWithoutDuplicationSortedInAscendingQRT(pcReturnType)
				return This.UniqueWordsSortedInAscendingQRT(pcReturnType)
	
		def WordsWithoutDuplicationSortedInAscendingOrder()
			return This.UniqueWordsSortedInAscending()
	
			def UniqueWordsInAscendingOrder()
				return This.UniqueWordsSortedInAscending()
	
				def UniqueWordsInAscendingOrderQ()
					return This.UniqueWordsInAscendingOrderQRT(:stzList)
	
				def UniqueWordsInAscendingOrderQRT(pcReturnType)
					return This.UniqueWordsSortedInAscendingQRT(pcReturnType)

		def UniqueWordsInAscending()
			return This.UniqueWordsSortedInAscending()

			def UniqueWordsInAscendingQRT(pcReturnType)
				return This.UniqueWordsSortedInAscendingQRT(pcReturnType)
	
			def UniqueWordsInAscendingQ()
				return This.UniqueWordsInAscendingQRT(:stzList)

		def SetOfWordsSortedInAscending()
			return This.UniqueWordsSortedInAscending()

			def SetOfWordsSortedInAscendingQRT(pcReturnType)
				return This.UniqueWordsSortedInAscendingQRT(pcReturnType)
	
			def SetOfWordsSortedInAscendingQ()
				return This.SetOfWordsSortedInAscendingQRT(:stzList)

		def SetOfWordsInAscendingOrder()
			return This.SetOfWordsSortedInAscending()

			def SetOfWordsInAscendingOrderQRT(pcReturnType)
				return This.UniqueWordsSortedInAscendingQRT(pcReturnType)
	
			def SetOfWordsInAscendingOrderQ()
				return This.SetOfWordsInAscendingOrderQRT(:stzList)

		def SetOfWordsInAscending()
			return This.SetOfWordsSortedInAscending()

			def SetOfWordsInAscendingQRT(pcReturnType)
				return This.UniqueWordsSortedInAscendingQRT(pcReturnType)
	
			def SetOfWordsInAscendingQ()
				return This.SetOfWordsInAscendingQRT(:stzList)

		#>

	  #------------------------------------------------------------------------------------#
	 #   GETTING THE LIST OF WORDS IN THE TEXT WITHOUT DUPLICATION SORTED IN DESCENDING   #
	#------------------------------------------------------------------------------------#

	def UniqueWordsSortedInDescending()
		acResult = StzListOfStringsQ( This.UniqueWords() ).SortedInDescending()
		return acResult

		#< @FunctionFluentForm

		def UniqueWordsSortedInDescendingQRT(pcReturnType)
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
			return This.UniqueWordsSortedInDescendingQRT(:stzList)

		#>

		#< @FunctionAlternativeForms

		def WordsUSortedInDescending()
			return This.UniqueWordsSortedInDescending()
	
			def WordsUSortedInDescendingQ()
				return This.WordsUSortedInDescendingQRT(:stzList)
	
			def WordsUSortedInDescendingQRT(pcReturnType)
				return This.UniqueWordsSortedInDescendingQRT(pcReturnType)
	
		def WordsUSortedInDescendingOrder()
			return This.UniqueWordsSortedInDescending()
	
			def WordsUSortedInDescendingOrderQ()
				return This.WordsUSortedInDescendingOrderQRT(:stzList)
	
			def WordsUSortedInDescendingOrderQRT(pcReturnType)
				return This.UniqueWordsSortedInDescendingQRT(pcReturnType)
	
		def WordsWithoutDuplicationSortedInDescending()
			return This.UniqueWordsSortedInDescending()
	
			def WordsWithoutDuplicationSortedInDescendingQ()
				return This.WordsWithoutDuplicationSortedInDescendingQRT(:stzList)
	
			def WordsWithoutDuplicationSortedInDescendingQRT(pcReturnType)
				return This.UniqueWordsSortedInDescendingQRT(pcReturnType)
	
		def WordsWithoutDuplicationSortedInDescendingOrder()
			return This.UniqueWordsSortedInDescending()
	
			def UniqueWordsInDescendingOrder()
				return This.UniqueWordsSortedInDescending()
	
				def UniqueWordsInDescendingOrderQ()
					return This.UniqueWordsInDescendingOrderQRT(:stzList)
	
				def UniqueWordsInDescendingOrderQRT(pcReturnType)
					return This.UniqueWordsSortedInDescendingQRT(pcReturnType)

		def UniqueWordsInDescending()
			return This.UniqueWordsSortedInDescending()

			def UniqueWordsInDescendingQ()
				return This.UniqueWordsInDescendingQRT(:stzList)

			def UniqueWordsInDescendingQRT(pcReturnType)
				return This.UniqueWordsSortedInDescendingQRT(pcReturnType)

		def SetOfWordsSortedInDescending()
			return This.UniqueWordsSortedInDescending()

			def SetOfWordsSortedInDescendingQ()
				return This.SetOfWordsSortedInDescendingQRT(:stzList)

			def SetOfWordsSortedInDescendingQRT(pcReturnType)
				return This.UniqueWordsSortedInDescendingQRT(pcReturnType)

		def SetOfWordsInDescendingOrder()
			return This.SetOfWordsSortedInDescending()

			def SetOfWordsInDescendingOrderQ()
				return This.SetOfWordsInDescendingOrderQRT(:stzList)

			def SetOfWordsInDescendingOrderQRT(pcReturnType)
				return This.UniqueWordsSortedInDescendingQRT(pcReturnType)

		def SetOfWordsInDescending()
			return This.SetOfWordsSortedInDescending()

			def SetOfWordsInDescendingQ()
				return This.SetOfWordsInDescendingQRT(:stzList)

			def SetOfWordsInDescendingQRT(pcReturnType)
				return This.UniqueWordsSortedInDescendingQRT(pcReturnType)

		#>

	  #-------------------------------------------------------------#
	 #   GETTING THE LIST OF WORDS IN THE TEXT IN REVERSED ORDER   #
	#-------------------------------------------------------------#

	def WordsReversed() # Returned in a list
		return ListReverse( This.Words() )

	  #----------------------------------------------#
	 #   REVERSING THE ORDER OF WORDS IN THE TEXT   #
	#----------------------------------------------#

	def ReverseWords() #TODO
		/*
			1. ReplaceWordsWithMarquers()
			2. ReverseSortingOrderOfMarquers()
			3. ReplaceMarquersWithWords()
		*/

		StzRaise("Feature unavailable!")

		def ReversWordsQRT(pcReturnType)
			This.ReverseWords()
			return This

	def TextWithWordsReversed()
		return This.Copy().ReverseWordsQ().Content()

	  #------------------------------------------------#
	 #   FINDING THE POSITIONS OF WORDS IN THE TEXT   #
	#------------------------------------------------#

	def WordsPositions()
		/* Example:

		Q("mahmoud, ahmed, mohamed, Mahmoud, mahmoud, ahmed.") {
			? WordsPositions()
		}

		#--> [ 1, 10, 17, 26, 35, 44 ]

		*/

		acWordsU = This.UniqueWords()
		nLen = len(acWordsU)

		anResult = []

		oTempStr = new stzString(This.Content())
		oTempStr.Lowercased()
		anResult = oTempStr.FindMany(acWordsU)

		return anResult
/*
		for i = 1 to nLen

			anPos = oTempStr.Find(acWordsU[i])
			nLenPos = len(anPos)

			for j = 1 to nLenPos
				anResult + anPos[j]
			next

		next

		anResult = ring_sort(anResult)
		return anResult
*/
		#< @FunctionFluentForm

			def WordsPositionsQRT(pcReturnType)
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
				return This.WordsPositionsQRT(:stzList)

		#>

		#< @FunctionAlternativeForm

		def WordsOccurrences()
			return This.WordsPositions()

			def WordsOccurrencesQ()
				return This.WordsOccurrencesQRT(:stzList)

			def WordsOccurrencesQRT(pcReturnType)
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

		def FindWords()
			return This.WordsPositions()

		#>

	  #-----------------------------------------------#
	 #   FINDING THE SECTIONS OF WORDS IN THE TEXT   #
	#-----------------------------------------------#

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

		def FindWordsAsSections()
			return This.WordSections()

	  #----------------------------------------------------------------------#
	 #   GETTING THE LIST OF WORDS IN THE TEXT ALONG WITH THEIR POSITIONS   #
	#----------------------------------------------------------------------#

	def WordsAndTheirPositions()
		/* Example
		Q("mahmoud, ahmed, mohamed, mahmoud, mahmoud, ahmed.") {
			? WordsAndTheirPositions()
		}

		#--> [
			:mahmoud = [ 1, 26, 35 ],
			:ahmed   = [ 10, 44 ],
			:mohamed = [ 17 ]
		      ]
		*/

		aResult = []

		for cWord in This.UniqueWords()
			aResult + [ cWord, This.FindAllCS(cWord, 0) ]
		next

		return aResult

		def WordsAndTheirOccurrences()
			return This.WordsAndTheirPositions()

		def WordsZ()
			return This.WordsAndTheirPositions()

	  #---------------------------------------------------------------------#
	 #   GETTING THE LIST OF WORDS IN THE TEXT ALONG WITH THEIR SECTIONS   #
	#---------------------------------------------------------------------#

	def WordsAndTheirSections()
		/* Example:

		Q("mahmoud, ahmed, mohamed, Mahmoud, mahmoud, ahmed.") {
			? WordsAndTheirPositionsXT()
			#--> [
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
		
		#TODO // replace for/in with normal for loop --> better performance

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

		def WordsZZ()
			return This.WordsAndTheirSections()

	  #---------------------------------------------------------------------------------#
	 #   GETTING THE LIST OF WORDS IN THE TEXT ALONG THE NUMBER OF THEIR OCCURRENCES   #
	#---------------------------------------------------------------------------------#

	def WordsAndNumbersOfTheirOccurrences()
		/* Example:

		Q("mahmoud, ahmed, mohamed, Mahmoud, mahmoud, ahmed.") {
			? WordsAndNumbersOfTheirOccurrences()
		}

		#--> [
			:mahmoud = 3,
			:ahmed   = 2,
			:mohamed = 1
		*/

		aResult = []

		for cWord in This.UniqueWords()
			aResult + [ cWord, This.NumberOfOccurrencesCS(cWord, 0) ]
		next

		return aResult

		def WordsAndTheirNumbersOfOccurrences()
			return This.WordsAndNumbersOfTheirOccurrences()

	  #-----------------------------------------------------------#
	 #  GETTING THE NUMBER OF OCCURRENCE OF A WORD IN THE TEXT   #
	#-----------------------------------------------------------#
	
	def NumberOfOccurrenceOfWord(pcWord)

		if NOT ( isString(pcWord) and @IsWord(pcWord) )

			StzRaise(stzStringError(:CanNotComputeNumberOfOccurrenceOfWord))
		ok

		# This solution (the line hereafter) takes 2.53s, a lot!
		# aResult = StzListOfStringsQ( This.Words() ).NumberOfOccurrenceOfString(pcWord)

		# The following is a better alternative taking almost 0s:

		# t0 = clock()

		oCopy = This.LowercaseQ().SimplifyQ()
		cWord = ring_lower(pcWord)

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

		#TODO // When Regex is implemented, use it instead.

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

	  #------------------------------------------------#
	 #  GETTING THE FREQUENCY OF A WORD IN THE TEXT   #
	#------------------------------------------------#

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

	  #---------------------------------------------------#
	 #  GETTING THE WORD AND ITS FREQUENCY IN THE TEXT   #
	#---------------------------------------------------#

	def WordAndItsFrequency(pcWord)
		aResult = [ pcWord, This.WordFrequency(pcWord) ]
		return aResult
	
	  #---------------------------------------------------------#
	 #   GETTING THE REQUENCIES OF ALL THE WORDS IN THE TEXT   #
	#---------------------------------------------------------#
	
	def WordsFrequencies()

		acWords = This.WordsU()
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
			return This.WordsFrequenciesQRT(:stzList)

		def WordsFrequenciesQRT(pcReturnType)
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

	  #-------------------------------------------------------------------#
	 #   GETTING ALL THE WORDS IN THE TEXT ALONG WITH THEIR REQUENCIES   #
	#-------------------------------------------------------------------#

	def WordsAndTheirFrequencies()
		aResult = []

		acWords     = This.UniqueWords()
		anWordFreqs = This.WordsFrequencies()

		aResult = StzListQ( acWords ).AssociatedWith( anWordFreqs )

		return aResult

	  #-------------------------------------------------------------------#
	 #   GETTING THE FREQUENCIES OF THE PROVIDED WORDS INSIDE THE TEXT   #
	#-------------------------------------------------------------------#

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

	  #-------------------------------------------------------------------------#
	 #   GETTING THE PROVIDED WORDS ALONG WITH THEIR FREQUENCIES IN THE TEXT   #
	#-------------------------------------------------------------------------#

	def TheseWordsAndTheirFrequencies(pacWords)
		aResult = []

		acWords = StzListQ(pacWords).DuplicatesRemoved()
		anWordFreqs = This.TheseWordsFrequencies(acWords)
		aResult = StzListQ( acWords ).AssociatedWith( anWordFreqs )

		return aResult

	  #------------------------------------------------#
	 #   GETTING THE MOST FREQUENT WORD IN THE TEXT   #
	#------------------------------------------------#

	def MostFrequentWord()

		aWordsFreqs = This.WordsAndTheirFrequencies()

		oHashList = StzHashListQ( aWordsFreqs )
		n = oHashList.ValuesQRT(:stzListOfNumbers).FindMax()

		cResult = aWordsFreqs[n][1]
		return cResult

		def TopOneFrequentWord()
			return This.MostFrequentWord()

	  #-------------------------------------------------------------------------#
	 #   GETTING THE MOST FREQUENT WORD IN THE TEXT AMONG THE PROVIDED WORDS   #
	#-------------------------------------------------------------------------#

	def MostFrequentWordAmongTheseWords(pacWords)
		aWordsFreqs = This.TheseWordsAndTheirFrequencies(pacWords)

		oHashList = StzHashListQ( aWordsFreqs )
		n = oHashList.ValuesQRT(:stzListOfNumbers).FindMax()

		return aWordsFreqs[n][1]

		#< @FunctionAlternativeForms

		def MostFrequentWordAmong(pacWords)
			return This.MostFrequentWordAmongTheseWords(pacWords)

		def TopOneFrequentWordAmongTheseWords(pacWords)
			return This.MostFrequentWordAmongTheseWords(pacWords)

		def TopOneFrequentWordAmong(pacWords)
			return This.MostFrequentWordAmongTheseWords(pacWords)

		#--

		def MostFrequentWordIn(pacWords)
			return This.MostFrequentWordAmongTheseWords(pacWords)

		def TopOneFrequentWordIn(pacWords)
			return This.MostFrequentWordAmongTheseWords(pacWords)

		#>

	  #-------------------------------------------------------#
	 #   GETTING THE N MAX FREQUENIES OF WORDS IN THE TEXT   #
	#-------------------------------------------------------#

	def NMaxFrequencies(n)
		aWordsFreqs = This.WordsAndTheirFrequencies()

		oHashList = StzHashListQ( aWordsFreqs )
		anMaxFreq = oHashList.ValuesQRT(:stzList).RemoveDuplicatesQ().ToStzListOfNumbers().MaxNumbers(n)

		return anMaxFreq

		#< @FunctionAlternativeForms

		def NMaxWordsFrequencies(n)
			return This.NMaxFrequencies(n)

		def MaxNFrequencies(n)
			return This.NMaxFrequencies(n)

		def MaxNWordsFrequencies(n)
			return This.NMaxFrequencies(n)

		#>

	  #----------------------------------------------------------------#
	 #   GETTING THE WORDS HAVING THE PROVIDED FREQUENCY IN THE TEXT  #
	#----------------------------------------------------------------#

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

		#< @FunctionAlternativeForms

		def WordsWithFrequency(pnFreq)
			return This.WordsHavingThisFrequency(pnFreq)

		def WordsWithThisFrequency(pnFreq)
			return This.WordsHavingThisFrequency(pnFreq)
			
		def WordsHavingFrequency(pnFreq)
			return This.WordsHavingThisFrequency(pnFreq)

		#>

	  #------------------------------------------------------------------#
	 #   GETTING THE WORDS HAVING THE PROVIDED FREQUENCIES IN THE TEXT  #
	#------------------------------------------------------------------#

	def WordsHavingTheseFrequencies(panFreq)
		panFreq = StzListQ(panFreq).DuplicatesRemoved()

		aResult = []

		for nFreq in panFreq
			aResult + This.WordsWithFrequency(nFreq)
		next

		return aResult
		
		#< FunctionAlternativeForms

		def WordsWithFrequencies(panFreq)
			return This.WordsHavingTheseFrequencies(panFreq)

		def WordsWithTheseFrequencies(panFreq)
			return This.WordsHavingThisFrequencies(panFreq)

		def WordsHavingFrequencies(panFreq)
			return This.WordsHavingThisFrequencies(panFreq)
			
		#>

	  #--------------------------------------------------------------------------#
	 #   GETTING THE PROVIDED FREQUENCIES AND THEIR RELATIVE WORDS IN THE TEXT  #
	#--------------------------------------------------------------------------#

	def FequenciesAndTheirWords(panFreq)
		panFreq = StzListQ(panFreq).DuplicatesRemoved()

		aResult = []

		for nFreq in panFreq
			aResult + [ "" + nFreq, This.WordsWithFrequency(nFreq) ]
			#NOTE: we stringify nFreq to be able to use the list as a hashlist
		next

		return aResult

	  #---------------------------------------------------#
	 #   GETTING THE N MOST FREQUENT WORDS IN THE TEXT   #
	#---------------------------------------------------#

	def NMostFrequentWords(n)
		/* Example

		cText = "John is the son of John second. 
		Second son of John second is William second."

		o1 = stzText(cText)
		? o1.NMostFrequentWords(3)

		#--> [ "william", "john", "second" ]

		Look to the intermediate results hereafter...
		*/

		# STEP 1: Getting the max frequencies

		anMaxFreqs = This.NMaxFrequencies(n)
		#--> [ 0.27, 0.20, 0.13 ]

		# STEP 2 : Sorting those max frequencies in descending
		# and then getting them and their relative words

		aFreqsWords = This.FequenciesAndTheirWords( reverse(sort(anMaxFreqs)) )
		#--> [
		# 	[ "0.27", [ "william" ] ],
		# 	[ "0.20", [ "john", "second" ] ],
		# 	[ "0.13", [ "is", "son", "of" ] ]
		#     ]

		# STEP 3: As you see, it's a beatifull sorted hashlist in descending
		# So let's get all the words from that HashlList

		aResult = []

		oHashList = new stzHashList( aFreqsWords )
		acWords = ListsMerge( oHashList.Values() )

		#--> [  "william", "john", "second", "is", "son", "of" ]

		# STEP 4: Finally, we take the first n words of it

		aResult = StzListQ(acWords).Section(1, n)

		return aResult

		#< @FunctionAlternativeForms

		def MostNFrequentWords(n)
			return This.NMostFrequentWords(n)

		def TopNFrequentWords(n)
			return This.NMostFrequentWords(n)

		def NTopFrequentWords(n)
			return This.NMostFrequentWords(n)

		#>

	  #--------------------------------------------------------------------------------#
	 #   GETTING THE N MOST FREQUENT WORDS IN THE TEXT َALONG WITH THEIR FREQUENCIES   #
	#--------------------------------------------------------------------------------#

	def NMostFrequentWordsAndTheirFrequencies(n)
		/* Example

		cText = "John is the son of John second. 
		Second son of John second is William second."

		o1 = stzText(cText)
		? o1.NMostFrequentWords(3)

		#--> [ "william", "john", "second" ]

		Look to the intermediate results hereafter...
		*/

		anMaxFreqs = This.NMaxFrequencies(n)
		#--> [ 0.27, 0.20, 0.13 ]

		aFreqsWords = This.FequenciesAndTheirWords( reverse(sort(anMaxFreqs)) )
		#--> [
		# 	[ "0.27", [ "william" ] ],
		# 	[ "0.20", [ "john", "second" ] ],
		# 	[ "0.13", [ "is", "son", "of" ] ]
		#     ]

		oHashList = new stzHashList( aFreqsWords )
		acWords = ListsMerge( oHashList.Values() )
		#--> [  "william", "john", "second", "is", "son", "of" ]

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

	  #---------------------------------------------------------------------------#
	 #   GETTING THE N MOST FREQUENT WORDS IN THE TEXT َAMONG THE PROVIDED ONES   #
	#---------------------------------------------------------------------------#

	def NMostFrequentWordsAmongTheseWords(n, pacWords)
		aWordsFreqs = This.TheseWordsAndTheirFrequencies(pacWords)

		oHashList = StzHashListQ( aWordsFreqs )
		anPos = oHashList.ValuesQRT(:stzListOfNumbers).FindFirstNMaxNumbers(n)

		aResult = []

		for n in anPos
			aResult + aWordsFreq[n][1]
		next

		return aResult

		def NMostFrequentWordsAmong(n, pacWords)
			return This.NMostFrequentWordsAmongTheseWords(n, pacWords)

	  #---------------------------------------#
	 #   GETTING THE TOP 10 FREQUENT WORDS   #
	#---------------------------------------#

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

	  #--------------------------------------------------------------#
	 #   GETTING THE TOP 10 FREQUENT WORDS AMONG THE PROVIDED ONES  #
	#--------------------------------------------------------------#

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

		def TopTenFrequentWordsIn(pacWords)
			return This.TopThreeFrequentWordsAmongTheseWords(pacWords)

		def Top10WordsIn(pacWords)
			return This.TopThreeFrequentWordsAmongTheseWords(pacWords)

		#>

	  #--------------------------------------#
	 #   GETTING THE TOP 5 FREQUENT WORDS   #
	#--------------------------------------#

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

	  #-------------------------------------------------------------#
	 #   GETTING THE TOP 3 FREQUENT WORDS AMONG THE PROVIDED ONES  #
	#-------------------------------------------------------------#

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

		def TopFiveFrequentWordsIn(pacWords)
			return This.TopThreeFrequentWordsAmongTheseWords(pacWords)

		def TopTWordsIn(pacWords)
			return This.TopThreeFrequentWordsAmongTheseWords(pacWords)

		#>

	  #--------------------------------------#
	 #   GETTING THE TOP 3 FREQUENT WORDS   #
	#--------------------------------------#

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

	  #-------------------------------------------------------------#
	 #   GETTING THE TOP 3 FREQUENT WORDS AMONG THE PROVIDED ONES  #
	#-------------------------------------------------------------#

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

		def TopThreeFrequentWordsIn(pacWords)
			return This.TopThreeFrequentWordsAmongTheseWords(pacWords)

		def Top3WordsIn(pacWords)
			return This.TopThreeFrequentWordsAmongTheseWords(pacWords)

		#>

	  #------------------------------------------------#
	 #   GETTING THE LESS FREQUENT WORD IN THE TEXT   #
	#------------------------------------------------#

	def LessFrequentWord()
		aWordsFreqs = This.WordsAndTheirFrequencies()

		oHashList = StzHashListQ( aWordsFreqs )
		n = oHashList.ValuesQRT(:stzListOfNumbers).FindMin()

		return aWordsFreqs[n][1]

	  #------------------------------------------------------------------------#
	 #   GETTING THE LESS FREQUENT WORD IN THE TEXT AMONG THE PROVIDED ONES   #
	#------------------------------------------------------------------------#

	def LessFrequentWordAmongTheseWords(pacWords)
		aWordsFreqs = This.TheseWordsAndTheirFrequencies(pacWords)

		oHashList = StzHashListQ( aWordsFreqs )
		n = oHashList.ValuesQRT(:stzListOfNumbers).FindMin()

		cResult = aWordsFreqs[n][1]
		return cResult

		#< @FunctionAlternativeForms

		def LessFrequentWordAmong(pacWords)
			return This.LessFrequentWordAmongTheseWords(pacWords)

		def LessFrequentWordIn(pacWords)
			return This.LessFrequentWordAmongTheseWords(pacWords)

		#>

	  #---------------------------------------------------#
	 #   GETTING THE N LESS FREQUENT WORDS IN THE TEXT   #
	#---------------------------------------------------#

	def NLessFrequentWords(n)
		aWordsFreqs = This.WordsAndTheirFrequencies()

		oHashList = StzHashListQ( aWordsFreqs )
		anPos = oHashList.ValuesQRT(:stzListOfNumbers).ReverseQ().FindTop(n)

		aResult = []

		for nPos in anPos
			aResult + aWordsFreq[nPos][1]
		next

		return aResult

		def LessNFrequentWords(n)
			return This.NLessFrequentWords(n)

	  #---------------------------------------------------------------------------#
	 #   GETTING THE N LESS FREQUENT WORDS IN THE TEXT AMONG THE PROVIDED ONES   #
	#---------------------------------------------------------------------------#

	def NLessFrequentWordsAmongTheseWords(n, pacWords)
		aWordsFreqs = This.TheseWordsAndTheirFrequencies(pacWords)

		oHashList = StzHashListQ( aWordsFreqs )
		anPos = oHashList.ValuesQRT(:stzListOfNumbers).FindMinNumbers(n)

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

	  #------------------------------------#
	 #   REMOVING THE WORDS OF THE TEXT   #
	#------------------------------------#
			
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

	  #-----------------------------------------------#
	 #   REPLACING WORDS IN THE TEXT WITH MARQUERS   #
	#-----------------------------------------------#

	def ReplaceWordsWithMarquers()
		This.ReplaceWordsWithMarquersXT([ :By = :OrderOfOccurrenceOfWords ])

		def ReplaceWordsWithMarquersQ()
			This.ReplaceWordsWithMarquers()
			return This

	  #-------------------------------------------------------------------#
	 #   REPLACING WORDS IN THE TEXT WITH MARQUERS -- EXTENDED VERSION   #
	#-------------------------------------------------------------------#

	def ReplaceWordsWithMarquersXT(paOptions)

		/* Example

		StzTextQ("mahmoud, ahmed, mohamed, Mahmoud, mahmoud, ahmed.") {
			ReplaceWordsWithMarquersXT([
				:By = :OrderOfOccurrenceOfWords,
				:Except = [],
				:StopWords = :MustNotBeRemoved
			])
			#--> "#1, #2, #3, #4, #5, #6."
		}
		*/

		#NOTE: Generalize the way ooptions are managed here all over
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
			if NOT ( isString(pByValue) and ring_find([
				:OrderOfOccurrence, :OrderOfOccurrenceOfWords,
				:AscendingOrder, :AscendingOrderOfWords,
				:DescendingOrder, :DescendingOrderOfWords ], pByValue) > 0 )
	
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

			         ring_find([ :MustBeRemoved,
					:MustNotBeRemoved
				 	], pStopWordsValue) > 0 )

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

		def ReplaceWordsWithMarquersXTQ(paOptions)
			This.ReplaceWordsWithMarquersXT(paOptions)
			return This
		
	  #-----------------------------------------------------#
	 #   CHECKING IF THE TEXT CONTAINS THE PROVIDED WORD   #
	#-----------------------------------------------------#
	
	def ContainsWord(pcWord)
		if NOT isString(pcWord)
			StzRaise("Incorrect param type! pcWord must be a string.")
		ok

		if This.SetOfWordsQ().Contains( ring_lower(pcWord) )
			return 1
		else
			return 0
		ok

		#< @FunctionNegativeForm

		def ContainsNoWord(pcWord)
			return NOT This.ContainsWord(pcWord)

		#>

	  #------------------------------------------------------------------#
	 #   CHECKING IF THE TEXT CONTAINS EACH ONE OF THE PROVIDED WORDS   #
	#------------------------------------------------------------------#

	def ContainsEachWord(pacWords)
		bResult = 1
	
		for cWord in pacWords
			if This.ContainsNoWord(cWord)
				bResult = 0
				exit
			ok
		next

		return bResult

	  #-------------------------------------------------------------#
	 #   CHECKING IF THE TEXT CONTAINS N TIMES THE PROVIDED WORD   #
	#-------------------------------------------------------------#

	def ContainsNTimesTheWord(n, pcWord)
		
		if This.WordsQ().FindAll(pcWord) = n
			return 1
		else
			return 0
		ok

		def ContainsNOccurrencesOfTheWord(n, pcWord)
			return This.ContainsNTimesTheWord(n, pcWord)

		def ContainsNOccurrenceOfTheWord(n, pcWord)
			return This.ContainsNTimesTheWord(n, pcWord)

	  #-----------------------------------------------------------------------#
	 #   CHECKING IF THE TEXT CONTAINS ONE OCCURRENCE OF THE PROVIDED WORD   #
	#-----------------------------------------------------------------------#

	def ContainsOneOccurrenceOfWord(pcWord)
			return This.ContainsNTimesTheWord(1, pcWord)

	  #---------------------------------------------------------------------------------#
	 #   CHECKING IF THE TEXT CONTAINS MORE THAN ONE OCCURRENCE OF THE PROVIDED WORD   #
	#---------------------------------------------------------------------------------#

	def ContainsMoreThanOneOccurrenceOfWord(pcWord)
		return This.NumberOfOccurrenceOfWord(pcWord) > 1

	  #--------------------------------------------------------------#
	 #  GETTING THE WORDS SORTING ORDER AS THEY APPEAR IN THE TEXT  #
	#--------------------------------------------------------------#

	def WordsSortingOrder()
		cResult = :Unsorted

		if This.WordsAreSortedInAscending()
			cResult = :Ascending

		but This.WordsAreSortedInDescending()
			cResult = :Descending

		ok

		return cResult

	  #------------------------------------------------------------------------------------------#
	 #  CHECHKING IF THE WORDS IN THE TEXT HAVE SAME SORTING ORDER AS WORDS IN AN OTHER STRING  #
	#------------------------------------------------------------------------------------------#

	def HasSameWordsSortingOrderAs(pcOtherStr)

		oOtherWord = new stzWord(pcOtherStr)
		if oOtherWord.WordsSortingOrder() = This.WordsSortingOrder()
			return 1
		else
			return 0
		ok

		def HasSameWordsOrderAs(pcOtherStr)
			return This.HasSameWordsSortingOrderAs(pcOtherStr)

	  #------------------------------------------------#
	 #  CHECKING IF THE WORDS IN THE TEXT ARE SORTED  #
	#------------------------------------------------#

	def WordsAreSorted()
		if This.WordsAreSortedInAscending() or
		   This.WordsAreSortedInDescending()
			return 1
		else
			return 0
		ok

	  #-------------------------------------------------------------#
	 #  CHECKING IF THE WORDS IN THE TEXT ARE SORTED IN ASCENDING  #
	#-------------------------------------------------------------#

	def WordsAreSortedInAscending()
		/*
		The idea is to sort a copy of the words list in ascending order
		and then compare the copy to the original words list...

		If they are identical, then words are sorted in ascending order!

		Note: we pass here through stzList inorder to use
		its IsStrictlyEqualTo() feature...
		*/

		oSortedCopy = This.WordsQRT(:stzList).SortInAscendingQ()

		if oSortedCopy.IsStrictlyEqualTo( This.Words() )
			return 1

		else
			return 0
		ok

	  #--------------------------------------------------------------#
	 #  CHECKING IF THE WORDS IN THE TEXT ARE SORTED IN DESCENDING  #
	#--------------------------------------------------------------#

	def WordsAreSortedInDescending()
		oSortedCopy = This.WordsQRT(:stzList).SortInDescendingQ()

		if oSortedCopy.IsStrictlyEqualTo( This.Words() )
			return 1

		else
			return 0
		ok

	  #------------------------------------------#
	 #  SORTING WORDS IN THE TEXT IN ASCENDING  #
	#------------------------------------------#

	def SortWordsInAscending() #TODO
		/*
			1. Replace words with marquers
			2. Sort the marquers in ascending (inside the text string)
			2. Replace marquers by words

		*/
		
		StzRaise("Unavailable feature!")

		def SortWordsInAscendingQ()
			This.SortWordsInAscending()
			return This
			
	def StringWithWordsSortedInAscending()
		cResult = This.Copy().SortWordsInAscendingQ().Content()
		return cResult

	  #-------------------------------------------#
	 #  SORTING WORDS IN THE TEXT IN DESCENDING  #
	#-------------------------------------------#

	def SortWordsInDescending() #TODO
		/*
			1. Replace words with marquers
			2. Sort the marquers in descending (inside the text string)
			2. Replace marquers by words

		*/

		StzRaise("Unavailable feature!")

		def SortWordsInDescendingQ()
			This.SortWordsInDescending()
			return This
			
	def StringWithWordsSortedInDescending()
		cResult = This.Copy().SortWordsInDescendingQ().Content()
		return cResult

	  #----------------------------#
	 #    REPLACING MANY WORDS    #
	#----------------------------#

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
		
		def AllOccurrencesOfWordsReplacedCS(pacWords, pacNewWords, pCaseSensitive)
			return This.WordsReplacedCS(pacWords, pacNewWords, pCaseSensitive)
		

	#-- WITHOUT CASESENSITIVITY

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
		
		def AllOccurrencesOfWordsReplaced(pacWords, pacNewWords)
			return This.WordsReplaced(pacWords, pacNewWords)
		
	  #--------------------------------#
	 #    REPLACING ONE GIVEN WORD    #
	#--------------------------------#

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

	#-- WITHOUT CASESENSITIVITY

	def ReplaceWord(pcWord, pcNewWord)
		This.ReplaceWordsCS(pcWord, pcNewWord, 1)

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

	  #-----------------------------------------#
	 #    REPLACING NTH OCCURRENCE OF A WORD   #TODO
	#-----------------------------------------#
	
	def ReplaceNthWordCS(n, pcWord, pcNewSubStr, pCaseSensitive)
		StzRaise("Unavailable feature!")

		def ReplaceNthWordCSQ(n, pcWord, pcNewSubStr, pCaseSensitive)
			This.ReplaceNthWordCS(n, pcWord, pcNewSubStr, pCaseSensitive)
			return This

	def NthWordReplacedCS(n, pcWord, pcNewSubStr, pCaseSensitive)
		cResult = This.Copy().ReplaceNthWordCSQ(n, pcWord, pcNewSubStr, pCaseSensitive).Content()
		return cResult

	#-- WITHOUT CASESENSITIVITY

	def ReplaceNthWord(n, pcWord, pcNewSubStr)
		StzRaise("Unavailable feature!")

		def ReplaceNthWordQ(n, pcWord, pcNewSubStr)
			This.ReplaceNthWord(n, pcWord, pcNewSubStr)
			return This

	def NthWordReplaced(n, pcWord, pcNewSubStr)
		cResult = This.Copy().ReplaceNthWordQ(n, pcWord, pcNewSubStr).Content()
		return cResult

	  #------------------------------------------#
	 #    REPLACING FIRST OCCURRENCE OF WORD    # 
	#------------------------------------------#

	def ReplaceFirstWordCS(pcWord, pcNewSubStr, pCaseSensitive)
		This.ReplaceNthWordCS(1, pcWord, pcNewSubStr, pCaseSensitive)

		def ReplaceFirstWordCSQ(pcWord, pcNewsubStr, pCaseSensitive)
			This.ReplaceFirstWordCS(pcWord, pcNewSubStr, pCaseSensitive)
			return This

	def FirstWordReplacedCS(pcWord, pcNewSubStr, pCaseSensitive)
		cResult = This.Copy().ReplaceFirstWordCSQ(pcWord, pcNewsubStr, pCaseSensitive).Content()
		return This

	#-- WITHOUT CASESENSITIVITY

	def ReplaceFirstWord(pcWord, pcNewSubStr)
		This.ReplaceNthWord(1, pcWord, pcNewSubStr)

		def ReplaceFirstWordQ(pcWord, pcNewsubStr)
			This.ReplaceFirstWord(pcWord, pcNewSubStr)
			return This

	def FirstWordReplaced(pcWord, pcNewSubStr)
		cResult = This.Copy().ReplaceFirstWordQ(pcWord, pcNewsubStr).Content()
		return This

	  #------------------------------------------#
	 #    REPLACING LAST OCCURRENCE OF WORD     # 
	#------------------------------------------#

	def ReplaceLastWordCS(pcWord, pcNewSubStr, pCaseSensitive)
		This.ReplaceNthWordCS(:Last, pcWord, pcNewSubStr, pCaseSensitive)

		def ReplaceLastWordCSQ(pcWord, pcNewSubStr, pCaseSensitive)
			This.ReplaceLastWordCS(pcWord, pcNewSubStr, pCaseSensitive)
			return This

	def LastWordReplacedCS(pcWord, pcNewSubStr, pCaseSensitive)
		cResult = This.Copy().ReplaceLastWordCSQ(pcWord, pcNewSubStr, pCaseSensitive).Content()
		return cResult

	#-- WITHOUT CASESENSITIVITY

	def ReplaceLastWord(pcWord, pcNewSubStr)
		This.ReplaceNthWord(:Last, pcWord, pcNewSubStr)

		def ReplaceLastWordQ(pcWord, pcNewSubStr)
			This.ReplaceLastWord(pcWord, pcNewSubStr)
			return This

	def LastWordReplaced(pcWord, pcNewSubStr)
		cResult = This.Copy().ReplaceLastWordQ(pcWord, pcNewSubStr).Content()
		return cResult

	  #----------------------------------#
	 #  GETTING THE NUMBER OF LETTERS   #
        #----------------------------------#

	def NumberOfLetters()
		nResult = This.NumberOfLetters()
		return nResult

	  #-----------------------------------------------------------------------------------#
	 #  GOING FORWARAD IN THE TEXT STARTING AT A GIVEN POSITION UNTIL THEN END OF WORD   #
        #-----------------------------------------------------------------------------------#

	def ForwardToEndOfWord(nStart) # Starting at position n
		/* Example:
	
			o1 = new stzString( "Mohammed Ali Ben Salah" )
			? o1.ForwardToEndOfWord( 14 ) #--> Ben
			? o1.ForwardToEndOfWord( :StartingAt = 14 ) #--> Ben
			
		*/

		# Enabling the :StartingAt syntax

		if isList(nStart) and len(nStart) = 2 and
		   nStart[1] = :StartingAt and isNumber(nStart[2])

			nStart = nStart[2]

		ok

		# Checking the range of possible values for nStart param

		if nStart < 1 or nStart > This.NumberOfChars()
			return ""
		ok

		# Computing the rest of the word

		bInside = 1
		cResult = ""
		i = nStart - 1

		while bInside
			i++
						 
			if i = This.NumberOfChars() or
			   This.CharAtQ(i).IsWordSeparator()

				bInside = 0
			
			else
				cResult += This.NthChar(i)
			ok
				
		end

		return cResult

		#< @FunctionFluentForm

		def ForwardToEndOfWordQ(nStart)
			return new stzString( This.ForwardToEndOfWord(nStart))

		#>
	
	  #------------------------------------------------------------#
	 #   REMOVING ALL OCCURRENCES OF A GIVEN WORD FROM THE TEXT   #  TODO
	#------------------------------------------------------------#

	def RemoveAllWordCS(pcWord, pCaseSensitive)
		StzRaise("Feaure unavailable!")

		#< @FunctionFluentForm

		def RemoveAllWordCSQ(pcWord, pCaseSensitive)
			This.RemoveAllWordCS(pcWord, pCaseSensitive)
			return This

		#>

		#< @FunctionAlternativeforms

		def RemoveWordCS(pcWord, pCaseSensitive)
			This.RemoveAllWordCS(pcWord, pCaseSensitive)

			def RemoveWordCSQ(pcWord, pCaseSensitive)
				This.RemoveWordCS(pcWord, pCaseSensitive)
				return This

		def RemoveAllOccurrencesOfWordCS(pcWord, pCaseSensitive)
			This.RemoveAllWordCS(pcWord, pCaseSensitive)

			def RemoveAllOccurrencesOfWordCSQ(pcWord, pCaseSensitive)
				This.RemoveAllOccurrencesOfWord(pcWord, pCaseSensitive)
				return This

		def RemoveOccurrencesOfWordCS(pcWord, pCaseSensitive)
			This.RemoveAllWordCS(pcWord, pCaseSensitive)

			def RemoveOccurrencesOfWordCSQ(pcWord, pCaseSensitive)
				This.RemoveOccurrencesOfWordCS(pcWord, pCaseSensitive)
				return This

		#>

	#-- WITHOUT CASESENSITIVITY

	def RemoveAllWord(pcWord)
		This.RemoveAllWordCS(pcWord, 1)

		#< @FunctionFluentForm

		def RemoveAllWordQ(pcWord)
			This.RemoveAllWord(pcWord)
			return This

		#>

		#< @FunctionAlternativeforms

		def RemoveWord(pcWord)
			This.RemoveAllWord(pcWord)

			def RemoveWordQ(pcWord)
				This.RemoveWord(pcWord)
				return This

		def RemoveAllOccurrencesOfWord(pcWord)
			This.RemoveAllWord(pcWord)

			def RemoveAllOccurrencesOfWordQ(pcWord)
				This.RemoveAllOccurrencesOfWord(pcWord)
				return This

		def RemoveOccurrencesOfWord(pcWord)
			This.RemoveAllWordCS(pcWord)

			def RemoveOccurrencesOfWordQ(pcWord)
				This.RemoveOccurrencesOfWord(pcWord)
				return This

		#>

	  #---------------------------------------#
	 #  REMOVING THE FIRST WORD IN THE TEXT  #
	#---------------------------------------#

	def RemoveFirstWordCS(pcWord, pCaseSensitive)
		// TODO

	#-- WITHOUT CASESENSITIVITY

	def RemoveFirstWord(pcWord)
		// TODO

	  #--------------------------------------#
	 #  REMOVING THE LAST WORD IN THE TEXT  #
	#--------------------------------------#

	def RemoveLastWordCS(pcWord, pCaseSensitive)
		// TODO

	#-- WITHOUT CASESENSITIVITY

	def RemoveLastWord(pcWord)
		// TODO

	  #-------------------------------------#
	 #  REMOVING THE NTH WORD IN THE TEXT  #
	#-------------------------------------#

	def RemoveNthWordCS(pcWord, pCaseSensitive)
		// TODO	

	#-- WITHOUT CASESENSITIVITY

	def RemoveNthWord(pcWord)
		// TODO

	  #------------------------------------------#
	 #  REMOVING THE GIVEN WORDS FROM THE TEXT  #
	#------------------------------------------#

	def RemoveManyWordsCS(pacWords)
		// TODO

	#-- WITHOUT CASESENSITIVITY

	def RemoveManyWords(pacWords)
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
			? o1.BackwardToStartOfWord( 12 ) #--> Ali
			? o1.BackwardToStartOfWord( :StartingAt = 12 ) #--> Ali
			
		*/

		# Enabling the :StartingAt syntax

		if isList(nStart) and len(nStart) = 2 and
		   nStart[1] = :StartingAt and isNumber(nStart[2])

			nStart = nStart[2]

		ok

		# Checking the range of possible values for nStart param

		if nStart < 1 or nStart > This.NumberOfChars()
			return ""
		ok

		# Computing the rest of the word

		bInside = 1
		cResult = ""
		i = nStart + 1

		while bInside
			i--
					 
			if i = 0 or This.CharAtQ(i).IsWordSeparator()

				bInside = 0
			
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
	 #      FINDING ALL OCCURRENCES OF WORD     #TODO
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
		return This.FindAllOccurrencesOfWordCS(pcWord, 1)
	
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
	 #      FINDING NTH OCCURRENCE OF WORD     #TODO // Test it
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
		nResult = This.FindNthOccurrenceOfWordCS(n, pcWord, 0)

		#< @FunctionAlternativeForm

		def FindNthWord(n, pcWord)
			return This.FindNthOccurrenceOfWord(n, pcWord)

		#>

		def PositionOfNthOccurrenceOfWord(n, pcWord, pCaseSensitive)
			return This.FindNthOccurrenceOfWordCS(n, pcWord, pCaseSensitive)

	  #-------------------------------------------#
	 #      FINDING FIRST OCCURRENCE OF WORD     #TODO // Test it!
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
		return This.FindFirstOccurrenceOfWordCS(pcWord, 0)

		#< @FunctionAlternativeForms

		def FindFirstWord(pcWord)
			return This.FindFirstOccurrenceOfWord(pcWord)

		def FirstWordPosition(pcWord)
			return This.FindFirstOccurrenceOfWord(pcWord)

		def FirstPositionOfWord(pcword)
			return This.FindFirstOccurrenceOfWord(pcWord)

		#>

	  #------------------------------------------#
	 #      FINDING LAST OCCURRENCE OF WORD     #TODO // test it!
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
		return This.FindLastOccurrenceOfWordCS(pcWord, 0)

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
			return ""
		ok

		bInside = 1
		cResult = ""
		i = nStart - 1

		while bInside
			i++
						 
			if i = This.NumberOfChars() or
			   This.CharAtQ(i).IsSentenceSeparator()
			   
				bInside = 0

			else
				cResult += This.NthChar(i)
			ok	
		end

		if cResult != ""
			return cResult + This.NthChar(i)
		else
			return ""
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
			return ""
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

		bInside = 1
		cResult = ""
		i = nStart + 1

		while bInside
			i--
					 
			if i = 0 or This.CharAtQ(i).IsSentenceSeparator()
				bInside = 0
		
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
			return This.LettersQRT(:stzList)

		def LettersQRT(pcReturnType)
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

		if paOptions[ :ManageArabicShaddah ] = 1

			# MANAGING THE SPECIAL CASE OF ARABIC SHADDAH ("ّ ")
	
			# In fact, arabic shaddah is a letter (and so isLetter()
			# should return 1), but the shaddah should'nt appear in
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
			return This.LettersXTQRT(paOptions, :stzList)

		def LettersXTQRT(paOptions, pcReturnType)
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
		return This.LettersQRT(:stzListOfStrings).DuplicatesRemoved()

		def LettersU()
			return This.UniqueLetters()

		def LettersWithoutDuplication()
			return This.UniqueLetters()

	def UniqueLettersXT(paOptions)
		return This.LettersXTQRT(paOptions, :stzListOfStrings).DuplicatesRemoved()

		def UniqueLettersXTQ(paOptions)
			return This.UniqueLettersXTQRT(paOptions, :stzList)

		def UniqueLettersXTQRT(paOptions, pcReturnType)
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
				return This.ToSetOfLettersXTQRT(paOptions, :stzList)
	
			def ToSetOfLettersXTQRT(paOptions, pcReturnType)
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

		def LettersXTU()
			return This.UniqueLettersXT()

		def LettersWithoutDuplicationXT()
			return This.UniqueLettersXT()

	  #--------------------#
	 #    PSEUDO-WORDS    #
	#--------------------#

	/* NOTE
	
	PseudoWords are an effective alternative of Words. It's a quick-win
	that you can use in many cases, but the result is not as accurate as
	Words() provides where many controls are made to better identify words.

	In fact, pseudo-words are just substrings separated by spaces, no more.

	If they suit for your case, then use them. Otherwise, use Words() and
	expect yourself to pay for performance.

	TODO: Use QTextBoundaryFinder class when added to RingQt


	*/

	  #-------------------------------------------------------------#
	 #    CHECKING IF THE TEXT IS A STOPWOD IN A GIVEN LANGUAGE    #
	#-------------------------------------------------------------#

	def IsStopWordIn(pcLang)
		cCode = 'bResult = StopWordsInQ(:' + pcLang + ').Contains(This.Lowercased())'
		eval(cCode)
		return bResult

	  #-------------------------------------------------------------------#
	 #   GETTING THE LANGUAGE OF THE TEXT IF THE CONTENT IS A STOPWORD   #
	#-------------------------------------------------------------------#

	def LanguageIfStopWord()
		if This.IsStopWord()
			return StopWordLanguage(This.String())
		ok

	  #------------------------------------------#
	 #   REMOVING STOPWORDS IN A GIVEN SCRIPT   #
	#------------------------------------------#

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
			This.RemoveStopWordsInScriptQRT(pcScript)
			return This

		def RemoveStopWordsIn(pcScript)
			This.RemoveStopWordsInScript(pcScript)

			def RemoveStopWordsInQ(pcScript)
				This.RemoveStopWordsIn(pcScript)
				return This

	  #-------------------------------------#
	 #   GETTING THE NUMBER OF SENTENCES   #
	#-------------------------------------#

	def NumberOfSentences()
		return len( This.Sentences() )

		def HowManySentences()
			return This.NumberOfSentences()

		def HowManySentence()
			return This.NumberOfSentences()

	  #------------------------------------#
	 #   GETTING THE LIST OF SENTENCES   #
	#-----------------------------------#

	def Sentences()
		cSep = SentenceSeparator()
		return This.Split(cSep)

		#< @FunctionFluentForm

		def SentencesQ()
			return This.SentencesQRT(:stzList)

		def SentencesQRT(pcReturnType)
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

	  #--------------------------------------------#
	 #   GETTING THE NUMBER OF UNIQUE SENTENCES   #
	#--------------------------------------------#

	def NumberOfUniqueSentences()
		return len( This.UniqueSentences() )

		def HowManyUniqueSentences()
			return This.NumberOfUniqueSentences()

		def HowManyUniqueSentence()
			return This.NumberOfUniqueSentences()

	  #------------------------------------------#
	 #   GETTING THE LIST OF UNIQUE SENTENCES   #
	#------------------------------------------#

	def UniqueSentences()
		cSep = SentenceSeparator()
		acResult = This.SplitQ(cSep).DuplicatesRemoved()
		return acResult

		#< @FunctionFluentForm

		def UniqueSentencesQ()
			return This.UniqueSentencesQRT(:stzList)

		def UniqueSentencesQRT(pcReturnType)
			if isList(pcReturnType) and Q(pcReturnType).IsReturnedNamedParam()
				pcReturnType = pcReturnType[2]
			ok

			switch pcReturnType
			on :stzList
				return new stzList( This.UniqueSentences() )
			on :stzListOfStrings
				return new stzListOfStrings( This.UniqueSentences() )
			other
				StzRaise("Unsupported return type!")
			off
	
		#>

	  #---------------------------------------------#
	 #   GETTING THE NUMBER OF UNIQUE PARAGRAPHS   #
	#---------------------------------------------#

	def NumberOfUniqueParagraphs()
		return len( This.UniqueParagraphs() )

		def HowManyUniqueParagraphs()
			return This.NumberOfUniqueParagraphs()

		def HowManyUniqueParagraph()
			return This.NumberOfUniqueParagraphs()

	  #-------------------------------------------#
	 #   GETTING THE LIST OF UNIQUE PARAGRAPHS   #
	#-------------------------------------------#

	def UniqueParagraphs()
		cSep = ParagraphSeparator()
		acResult = This.SplitQ( cSep ).DuplicatesRemoved()
		return acResult

		#< @FunctionFluentForm

		def UniqueParagraphsQ()
			return This.UniqueParagraphsQRT(:stzList)

		def UniqueParagraphsQRT(pcReturnType)
			if isList(pcReturnType) and Q(pcReturnType).IsReturnedNamedParam()
				pcReturnType = pcReturnType[2]
			ok

			switch pcReturnType
			on :stzList
				return new stzList( This.UniqueParagraphs() )
			on :stzListOfStrings
				return new stzListOfStrings( This.UniqueParagraphs() )
			other
				StzRaise("Unsupported return type!")
			off
	
		#>

	  #--------------------------------------#
	 #   GETTING THE NUMBER OF PARAGRAPHS   #
	#--------------------------------------#

	def NumberOfParagraphs()
		return len( This.Paragraphs() )

		def HowManyParagraphs()
			return This.NumberOfParagraphs()

		def HowManyParagraph()
			return This.NumberOfParagraphs()

	  #------------------------------------#
	 #   GETTING THE LIST OF PARAGRAPHS   #
	#------------------------------------#

	def Paragraphs()
		cSep = ParagraphSeparator()
		acResult = This.Split( cSep )
		return acResult

		#< @FunctionFluentForm

		def ParagraphsQ()
			return This.ParagraphsQRT(:stzList)

		def ParagraphsQRT(pcReturnType)
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

	  #----------------------------------------#
	 #   GETTING THE NUMBER OF PUNCTUATIONS   # 
	#----------------------------------------#

	def NumberOfPunctuations()
		nResult = 0

		acStzChars = This.ToListOfStzChars()

		for oChar in acStzChars
			if oChar.IsPunctuation()
				nResult++
			ok
		next

		return nResult

		def HowManyPunctions()
			return This.NumberOfPunctuations()

		def HowManyPunction()
			return This.NumberOfPunctuations()

	  #--------------------------------------#
	 #   GETTING THE LIST OF PUNCTUATIONS   # 
	#--------------------------------------#

	def Punctuations()
		aResult = []

		acStzChars = This.ToListOfStzChars()

		for oChar in acStzChars
			if oChar.IsPunctuation()
				aResult + oChar.Content()
			ok
		next

		return aResult

	  #-----------------------------------------------#
	 #    GETTING THE NUMBER OF UNIQUE PUNCTUATIONS  # 
	#-----------------------------------------------#

	def NumberOfUniquePunctuations()
		return len( This.UniquePunctuations() )

		return nResult

		def HowManyUniquePunctions()
			return This.NumberOfUniquePunctuations()

		def HowManyUniquePunction()
			return This.NumberOfUniquePunctuations()

	  #----------------------------------------------#
	 #    GETTING THE LISTS OF UNIQUE PUNCTUATIONS  # 
	#----------------------------------------------#

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

		def PunctuationsU()
			return This.UniquePunctuations()

		def PunctuationsWithoutDuplication()
			return This.UniquePunctuations()

	  #------------------------------------------------#
	 #    GETTING THE NUMBER OF GENERAL PUNCTUATIONS  # 
	#------------------------------------------------#

	def NumberOfGeneralPunctuations()
		nResult = 0

		acStzChars = This.ToListOfStzChars()

		for oChar in acStzChars
			if oChar.IsGeneralPunctuation()
				nResult++
			ok
		next

		return nResult

		def HowManyGeneralPunctuations()
			return This.NumberOfGeneralPunctuations()

		def HowManyGeneralPunctuation()
			return This.NumberOfGeneralPunctuations()

	  #----------------------------------------------#
	 #    GETTING THE LIST OF GENERAL PUNCTUATIONS  # 
	#----------------------------------------------#

	def GeneralPunctuations()
		aResult = []

		acStzChars = This.ToListOfStzChars()

		for oChar in acStzChars
			if oChar.IsGeneralPunctuation()
				aResult + oChar.Content()
			ok
		next

		return aResult

	  #-----------------------------------------------------------------------#
	 #    GETTING THE NUMBER OF GENERAL PUNCTUATIONS -- WITHOUT DUPLICATION  # 
	#-----------------------------------------------------------------------#

	def NumberOfUniqueGeneralPunctuations()
		return len( This.UniqueGeneralPunctuations() )

		def HowManyUniqueGeneralPunctuations()
			return This.NumberOfUniqueGeneralPunctuations()

		def HowManyUniqueGeneralPunctuation()
			return This.NumberOfUniqueGeneralPunctuations()

	  #---------------------------------------------------------------------#
	 #    GETTING THE LIST OF GENERAL PUNCTUATIONS -- WITHOUT DUPLICATION  # 
	#---------------------------------------------------------------------#

	def UniqueGeneralPunctuations()
		aResult = []

		acStzChars = This.ToListOfStzChars()

		for oChar in acStzChars
			cChar = oChar.Content()

			if oChar.IsGeneralPunctuation() and ring_find(aResult, cChar)
				aResult + cChar
			ok
		next

		def GeneralPunctuationsU()
			return This.UniqueGeneralPunctuations()

		def GeneralPunctuationsWithoutDuplication()
			return This.UniqueGeneralPunctuations()

	  #------------------------------------------------------#
	 #    GETTING THE NUMBER OF SUPLEMENTAL PUNCTUATIONS    # 
	#------------------------------------------------------#

	def NumberOfSupplementalPunctuations()
		nResult = 0

		acStzChars = This.ToListOfStzChars()

		for oChar in acStzChars
			if oChar.IsSupplementalPunctuation()
				nResult++
			ok
		next

		return nResult

		def HowManySupplementalPunctuations()
			return This.NumberOfSupplementalPunctuations()

		def HowManySupplementalPunctuation()
			return This.NumberOfSupplementalPunctuations()
 
	  #----------------------------------------------------#
	 #    GETTING THE LIST OF SUPLEMENTAL PUNCTUATIONS    # 
	#----------------------------------------------------#

	def SupplementalPunctuations()
		aResult = []

		acStzChars = This.ToListOfStzChars()

		for oChar in acStzChars
			if oChar.IsSupplementalPunctuation()
				aResult + oChar.Content()
			ok
		next

		return aResult

	  #---------------------------------------------------------------------------#
	 #    GETTING THE NUMBER OF SUPLEMENTAL PUNCTUATIONS -- WITHOUT DUPLICATION  # 
	#---------------------------------------------------------------------------#

	def NumberOfUniqueSupplementalPunctuations()
		return len( This.UniqueSupplementalPunctuations() )

		def HowManyUniqueSupplementalPunctions()
			return This.NumberOfUniqueSupplementalPunctuations()

		def HowManyUniqueSupplementalPunction()
			return This.NumberOfUniqueSupplementalPunctuations()

	  #---------------------------------------------------------------------------#
	 #    GESTTING THE LIST OF SUPLEMENTAL DUPLICATIONS -- WITHOUT DUPLICATION   # 
	#---------------------------------------------------------------------------#

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

		def SupplementalPunctuationsU()
			return This.UniqueSupplementalPunctuations()

		def SupplementalPunctuationsWithoutDuplication()
			return This.UniqueSupplementalPunctuations()

	  #---------------------------#
	 #    REMOVING PUNCTUATION   # 
	#===========================#

	def RemovePunctuation()
		anPos = This.FindPunctuations()
		cResult = This.ToStzString().RemoveCharsAtPositionsQ(anPos).Content()
		This.Update(cResult)

		#< @FunctionAlternativeForm

		def RemovePunctuationQ()
			This.RemovePunctuation()
			return This

		def RemovePunctuations()
			This.RemovePunctuation()
	
			def RemovePunctuationsQ()
				This.RemovePunctuations()
				return This

		#>

	#-- @PassiveForm
	def PunctuationRemoved()
		cResult = This.Copy().RemovePunctuationQ().Content()
		return cResult

		def PunctuationsRemoved()
			return This.PunctuationRemoved()

	  #-----------------------------------------------#
	 #    REMOVING PUNCTUATION  -- EXCEPT/Extension  # 
	#-----------------------------------------------#

	def RemovePunctuationExcept(paChars)
		#TODO // Replace it with a more performant pure Ring implementation
		This.RemoveCharsWhere('StzCharQ(@char).isPunctuation() and NOT Q(@char).IsOneOfThese(' + @@(paChars) + ')')

		def RemovePunctuationExceptQ(paChars)
			This.RemovePunctuationExcept(paChars)
			return This
	
	  #--------------------------#
	 #    REMOVING DIACRITICS   # 
	#--------------------------#

	def IsDiacritics()

		aoStzChars = This.ToListOfStzChars()
		nLen = len(aoStzChars)

		bResult = 1

		for i = 1 to nLen
			if NOT aoStzChars[i].IsDiacritic()
				bResult = 0
				exit
			ok
		next

		return bResult

	def ContainsDiacritics()

		aoStzChars = This.ToListOfStzChars()
		nLen = len(aoStzChars)

		bResult = 0

		for i = 1 to nLen
			if aoStzChars[i].IsDiacritic() or aoStzChars[i].IsDiacricised()
				bResult = 1
				exit
			ok
		next

		return bResult

	def FindDiacritics()

		aoStzChars = This.ToListOfStzChars()
		nLen = len(aoStzChars)

		anResult = []

		for i = 1 to nLen
			if aoStzChars[i].IsDiacritic() or aoStzChars[i].IsDiacricised()
				anResult + i
			ok
		next

		return anResult

	def RemoveDiacritics() #TODO // test this!

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

		anPos = This.FindDiacritics()
		nLen = len(anPos)

		aoStzChars = This.ToListOfStzChars()
		_oCopy_ = This.Copy()

		for i = 1 to nLen
			nPos = anPos[i]
			_oCopy_.QStringObject().replace(nPos-1, 1, aoStzChars[nPos].DiacriticRemoved())			
		next

		This.UpdateWith(_oCopy_.Content())


		def RemoveDiacriticsQ()
			This.RemoveDiacritics()
			return This
/*
		switch This.Script()
	
		on :Latin

			This.ToStzString().ReplaceCharsWXT(
				:Where = '{ StzCharQ(@char).IsLatinDiacritic() }',
				:With  = '{ StzCharQ(@char).LatinDiacriticRemoved() }'
			)
	
		on :Arabic
			This.ToStzString().RemoveCharsWXT('{ StzCharQ(@char).IsArabicDiacritic() }')
	
		on :Greek
			This.ToStzString().ReplaceCharsWXT(
				:Where = '{ StzCharQ(@char).IsGreekDiacritic() }',
				:With  = 'StzCharQ(@char).RemoveGreekDiacritic()'
			)
			#TODO // I assumed that greek works like latin for diacritics,
			# but check this!
	
		on :Hebrew
			This.ToStzString().RemoveCharsWXT('{ StzCharQ(@char).IsHebrewDiacritic() }')
			#TODO // I assumed that hebrew works like arabic for diacritics,
			# but check this!
	
		other
			StzRaise("Can't remove diacritics for that script!")
		off
	
		def RemoveDiacriticsQ()
			This.RemoveDiacritics()
			return This
*/
	def DiacriticsRemoved()
		cResult = This.Copy().RemoveDiacriticsQ().Content()
		return cResult

	# Latin diacritics

	def RemoveLatinDiacritics()
		// TODO
		
	# Arabic diacritics

	def IsArabicDiacritic()
		bResult = 1

		for oStzChar in This.ToListOfStzChars()
			if NOT oStzChar.IsArabicDiacritic()
				bResult = 0
				exit
			ok
		next

		return bResult

	def ContainsArabicDiacritics()
		bResult = 0

		for oStzChar in This.ToListOfStzChars()
			if oStzChar.IsArabicDiacritic()
				bResult = 1
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
		#TODO // add more speciefic languages (only german is managed here)
		# and special cases as documented in the Unicode standard here:
		#--> http://unicode.org/Public/UNIDATA/SpecialCasing.txt

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
		aResult = This.SplitQRT(:Using = " ", :stzListOfStrings).
			       Yield('Q(@str).FirstChar()')

		return aResult

		def InitialsQ()
			return This.InitialsQRT(:stzList)

		def InitialsQRT(pcReturnType)
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
				return new stzString( This.InitialsQRT(:stzListOfStrings).Concatenated() )

			on :stzText
				return new stzText( This.InitialsQRT(:stzListOfStrings).Concatenated() )

			other
				StzRaise("Unsupported return type!")
			off

	def InitialsAsString()
		return This.InitialsQRT(:stzString).Content()

	def InitialsAsText()
		return This.InitialsQRT(:stzText).Content()

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
			return 1
		else
			return 0
		ok

	def IsText()
		return 1

	def StzType()
		return :stzText
