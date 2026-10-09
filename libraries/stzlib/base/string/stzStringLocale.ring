#--------------------------------------------------------------#
#        SOFTANZA LIBRARY (V0.9) - STZSTRINGLOCALE             #
#   An accelerative library for Ring applications, and more!   #
#--------------------------------------------------------------#
#                                                              #
#   Description  : String locale -- Wraps stzString via        #
#                  composition. Locale-aware operations:       #
#                  language, country, script, currency         #
#                  detection and formatting.                   #
#   Version      : V0.9 (2026)                                 #
#   Author       : Mansour Ayouni (kalidianow@gmail.com)       #
#                                                              #
#--------------------------------------------------------------#


# Answers questions about a text that depend on its script, its reading direction and its locale.
#
# It wraps a stzString and asks the engine, which counts Unicode characters and not bytes. Case
# conversion takes a locale, so Turkish dotted and dotless i come out right. Script tests tell the
# writing system, and a text that mixes two of them, the shape of a homograph attack, is reported by
# IsMixedScript; digits and spaces never count as a script of their own there. Known limit today:
# Hebrew letters are not seen as right to left (see DetectDirection), and LocaleCompare orders by
# character with case ignored, not by the rules of a language.
#
#   receiver   o1 = new stzStringLocale("Hello, World 123")
#   example    ? o1.ScriptName()
#              #--> Latin
#              ? o1.ContainsDigits()
#              #--> 1
#   see        stzString, stzLocale
class stzStringLocale from stzObject

	@oString

	# Builds a locale-aware view of a text, given as plain text or as a stzString.
	#
	#   pStrOrStzStrObj   the text, or a stzString object whose content is used
	#   returns           nothing; the object is built
	#   see               Content, ScriptName
	def init(pStrOrStzStrObj)
		if isString(pStrOrStzStrObj)
			@oString = new stzString(pStrOrStzStrObj)
		but isObject(pStrOrStzStrObj)
			@oString = pStrOrStzStrObj
		else
			StzRaise("Can't create stzStringLocale! Parameter must be a string or stzString object.")
		ok

	# Returns the text the object holds.
	#
	#   returns    a text
	#   see        NumberOfChars, IsEmpty
	def Content()
		return @oString.Content()

	# Returns how many characters the text has, counted in Unicode characters and not in bytes.
	#
	#   returns    a number
	#   note       a text of Hebrew or Arabic letters counts one per letter
	#   see        Content, IsEmpty
	def NumberOfChars()
		return @oString.NumberOfChars()

	# TRUE if the text has no character at all.
	#
	#   returns    TRUE or FALSE
	#   see        NumberOfChars, ContainsOnlyWhitespace
	def IsEmpty()
		return @oString.IsEmpty()

	  #===============================#
	 #     LOCALE CASE CONVERSION    #
	#===============================#

	# Returns the text in lower case by the rules of a locale, so Turkish dotted and dotless i are handled.
	#
	#   pcLocale   a locale code such as tr_TR, en_US or de_DE
	#   returns    a text; the object itself is not changed
	#   note       in tr_TR the capital I becomes the dotless i, and in en_US the capital dotted I
	#              becomes i followed by a combining dot
	#   see        UppercasedInLocale, LocaleCompare
	def LowercasedInLocale(pcLocale)
		_oLocale_ = new stzLocale(pcLocale)
		return _oLocale_.ToLowercase(@oString.Content())

	# Returns the text in upper case by the rules of a locale, so Turkish dotted and dotless i are handled.
	#
	#   pcLocale   a locale code such as tr_TR, en_US or de_DE
	#   returns    a text; the object itself is not changed
	#   note       in tr_TR the small i becomes the dotted capital I; in en_US it becomes I
	#   see        LowercasedInLocale
	def UppercasedInLocale(pcLocale)
		_oLocale_ = new stzLocale(pcLocale)
		return _oLocale_.ToUppercase(@oString.Content())

	  #======================================#
	 #     SCRIPT DETECTION (Engine-backed) #
	#======================================#

	# Returns a number naming the writing system the text is written in.
	#
	#   returns    a number: 0 unknown, 1 Latin, 2 Arabic, 3 Hebrew, 4 Cyrillic, 5 Greek, 6 CJK, 7
	#              Devanagari, 8 Thai, 99 mixed
	#   note       digits, spaces and punctuation do not vote; a text made only of them answers 0
	#   see        ScriptName, ScriptCount
	def DetectScript()
		_pH_ = @oString.Engine()
		return StzEngineStringDetectScript(_pH_)

	# Returns the name of the writing system the text is written in.
	#
	#   returns    a text: Latin, Arabic, Hebrew, Cyrillic, Greek, CJK, Devanagari, Thai, Mixed or
	#              Unknown
	#   note       a text of digits, spaces or nothing answers Unknown
	#   see        DetectScript, IsMixedScript
	def ScriptName()
		_pH_ = @oString.Engine()
		_pR_ = StzEngineStringScriptName(_pH_)
		_lcName_ = StzEngineStringData(_pR_)
		StzEngineStringFree(_pR_)
		return _lcName_

	def Script()
		return This.ScriptName()

	# Returns how many scripts the text uses, counting the common one that holds digits, spaces and punctuation.
	#
	#   returns    a number
	#   note       hello 123 gives 2, because Latin and common are both counted; an empty text gives
	#              0
	#   see        ScriptCountExcludingCommon, IsMixedScript
	#@ aka  How many scripts the string uses -- COMMON INCLUDED.
	def ScriptCount()
		_pH_ = @oString.Engine()
		return StzEngineStringScriptCountAll(_pH_)

	# Returns how many real writing systems the text uses, leaving out digits, spaces and punctuation.
	#
	#   returns    a number
	#   note       a text of digits only gives 0
	#   see        ScriptCount, IsMixedScript
	#@ aka  Scripts EXCLUDING common -- the count of real writing systems.
	def ScriptCountExcludingCommon()
		_pH_ = @oString.Engine()
		return StzEngineStringScriptCount(_pH_)

	# TRUE if the text mixes two or more writing systems, such as Latin with Hebrew; digits and spaces do not count.
	#
	#   returns    TRUE or FALSE
	#   note       hello 123 is not mixed; a Latin word next to a Hebrew word is
	#   see        ScriptCountExcludingCommon, ScriptName
	#@ aka  Deliberately NOT ScriptCount() > 1.
	def IsMixedScript()
		return This.ScriptCountExcludingCommon() > 1

	# TRUE if the text is written in Latin letters.
	#
	#   returns    TRUE or FALSE
	#   note       hello 123 is Latin; a Latin word next to a Hebrew word is neither
	#   see        ScriptName, ContainsOnlyLatinLetters
	def IsLatinScript()
		return This.ScriptName() = "Latin"

	# TRUE if the text is written in Arabic letters.
	#
	#   returns    TRUE or FALSE
	#   see        ScriptName, ContainsArabicLetters
	def IsArabicScript()
		return This.ScriptName() = "Arabic"

	# TRUE if the text is written in Hebrew letters.
	#
	#   returns    TRUE or FALSE
	#   note       the script test is right for Hebrew, but the direction tests are not: see
	#              IsRightToLeft
	#   see        ScriptName, IsRightToLeft
	def IsHebrewScript()
		return This.ScriptName() = "Hebrew"

	# TRUE if the text is written in Cyrillic letters.
	#
	#   returns    TRUE or FALSE
	#   see        ScriptName, IsGreekScript
	def IsCyrillicScript()
		return This.ScriptName() = "Cyrillic"

	# TRUE if the text is written in Greek letters.
	#
	#   returns    TRUE or FALSE
	#   see        ScriptName, IsCyrillicScript
	def IsGreekScript()
		return This.ScriptName() = "Greek"

	# TRUE if the text is written in Chinese, Japanese or Korean ideographs.
	#
	#   returns    TRUE or FALSE
	#   see        ScriptName
	def IsCJKScript()
		return This.ScriptName() = "CJK"

	# TRUE if the text is written in the Devanagari script, used for Hindi and Sanskrit.
	#
	#   returns    TRUE or FALSE
	#   see        ScriptName
	def IsDevanagariScript()
		return This.ScriptName() = "Devanagari"

	# TRUE if the text is written in Thai letters.
	#
	#   returns    TRUE or FALSE
	#   see        ScriptName
	def IsThaiScript()
		return This.ScriptName() = "Thai"

	  #========================================#
	 #     DIRECTION DETECTION (Engine-backed) #
	#========================================#

	# Returns a number naming the reading direction of the text.
	#
	#   returns    a number: 0 left to right, 1 right to left, 2 mixed, 3 neutral
	#   note       digits and punctuation do not vote; a text of them answers 3
	#   warning    Hebrew letters are not seen as right to left: a Hebrew text answers 3, neutral,
	#              and a Hebrew word next to a Latin one answers 0; Arabic, Syriac and Thaana answer
	#              1
	#   see        DirectionName, IsRightToLeft
	def DetectDirection()
		_pH_ = @oString.Engine()
		return StzEngineStringDetectDirection(_pH_)

	# Returns the reading direction of the text as a name.
	#
	#   returns    a text: LTR, RTL, Mixed or Neutral
	#   note       a text with no letter answers Neutral
	#   warning    Hebrew letters are not seen as right to left: a Hebrew text answers Neutral
	#   see        DetectDirection, IsLeftToRight
	def DirectionName()
		_pH_ = @oString.Engine()
		_pR_ = StzEngineStringDirectionName(_pH_)
		_lcDir_ = StzEngineStringData(_pR_)
		StzEngineStringFree(_pR_)
		return _lcDir_

	def Direction()
		return This.DirectionName()

	# TRUE if the text reads from right to left, as Arabic does.
	#
	#   returns    TRUE or FALSE
	#   note       IsRTL is the same call
	#   warning    answers FALSE for Hebrew text today, as the direction is Neutral for it; it
	#              answers TRUE for Arabic, Syriac and Thaana; a text mixing Arabic and Latin is
	#              Mixed and answers FALSE
	#   see        DetectDirection, HasRTL
	def IsRightToLeft()
		_pH_ = @oString.Engine()
		return StzEngineStringDetectDirection(_pH_) = 1

		def IsRTL()
			return This.IsRightToLeft()

	# TRUE if the text reads from left to right, as Latin does.
	#
	#   returns    TRUE or FALSE
	#   note       IsLTR is the same call
	#   warning    a Hebrew text answers FALSE here because it is read as Neutral; a Hebrew word
	#              next to a Latin word answers TRUE
	#   see        DetectDirection, IsRightToLeft
	def IsLeftToRight()
		_pH_ = @oString.Engine()
		return StzEngineStringDetectDirection(_pH_) = 0

		def IsLTR()
			return This.IsLeftToRight()

	# TRUE if the text contains at least one right-to-left letter.
	#
	#   returns    TRUE or FALSE
	#   warning    answers FALSE for Hebrew text today; it answers TRUE for Arabic, Syriac and
	#              Thaana, alone or next to Latin letters
	#   see        IsRightToLeft, IsBidiMixed
	def HasRTL()
		_pH_ = @oString.Engine()
		return StzEngineStringHasRTL(_pH_) = 1

	# TRUE if the text mixes left-to-right and right-to-left letters, so a bidirectional display is needed.
	#
	#   returns    TRUE or FALSE
	#   note       digits and punctuation do not make a text mixed
	#   warning    Latin next to Hebrew answers FALSE, as the Hebrew is not counted; Latin next to
	#              Arabic answers TRUE
	#   see        DetectDirection, HasRTL
	def IsBidiMixed()
		_pH_ = @oString.Engine()
		return StzEngineStringDetectDirection(_pH_) = 2

	# TRUE if the text has no letter that gives it a direction, as a text of digits or punctuation.
	#
	#   returns    TRUE or FALSE
	#   note       an empty text is neutral
	#   warning    answers TRUE for a Hebrew text today, because Hebrew letters are not counted as
	#              directional
	#   see        DetectDirection, IsBidiMixed
	def IsBidiNeutral()
		_pH_ = @oString.Engine()
		return StzEngineStringDetectDirection(_pH_) = 3

	  #=============================================#
	 #     LOCALE COMPARISON (Engine-backed)        #
	#=============================================#

	# Compares the text with another, ignoring case, and returns -1, 0 or 1.
	#
	#   pcOther    the text to compare with
	#   returns    a number: -1 if the text comes first, 0 if equal, 1 if it comes after
	#   note       apple and Apple are equal; Hebrew letters follow their alphabet
	#   warning    behaves as an order of characters that ignores case, not as the collation of a
	#              language: a with a diaeresis, or an accented e, sorts after z; the digits compare
	#              as text, so 10 comes before 9
	#   see        LocaleEquals, LocaleLessThan, LocaleGreaterThan
	def LocaleCompare(pcOther)
		pH1 = @oString.Engine()
		pH2 = StzEngineString(pcOther)
		_lcResult_ = StzEngineStringLocaleCompare(pH1, pH2)
		StzEngineStringFree(pH2)
		return _lcResult_

	# TRUE if the text is equal to another when case is ignored.
	#
	#   pcOther    the text to compare with
	#   returns    TRUE or FALSE
	#   note       apple equals Apple; apple does not equal banana
	#   see        LocaleCompare
	def LocaleEquals(pcOther)
		return This.LocaleCompare(pcOther) = 0

	# TRUE if the text sorts before another, ignoring case.
	#
	#   pcOther    the text to compare with
	#   returns    TRUE or FALSE
	#   note       apple comes before banana
	#   see        LocaleCompare, LocaleGreaterThan
	def LocaleLessThan(pcOther)
		return This.LocaleCompare(pcOther) = -1

	# TRUE if the text sorts after another, ignoring case.
	#
	#   pcOther    the text to compare with
	#   returns    TRUE or FALSE
	#   note       apple comes after Aardvark
	#   see        LocaleCompare, LocaleLessThan
	def LocaleGreaterThan(pcOther)
		return This.LocaleCompare(pcOther) = 1

	  #===============================#
	 #     CHARACTER CLASS TESTS     #
	#===============================#

	# TRUE if the text has at least one Latin letter, accented or not.
	#
	#   returns    TRUE or FALSE
	#   see        ContainsArabicLetters, ContainsOnlyLatinLetters
	def ContainsLatinLetters()
		_pH_ = @oString.Engine()
		return StzEngineStringContainsLatin(_pH_)

	# TRUE if the text has at least one Arabic letter.
	#
	#   returns    TRUE or FALSE
	#   see        ContainsLatinLetters, IsArabicScript
	def ContainsArabicLetters()
		_pH_ = @oString.Engine()
		return StzEngineStringContainsArabic(_pH_)

	# TRUE if the text has at least one digit.
	#
	#   returns    TRUE or FALSE
	#   see        ContainsOnlyDigits
	def ContainsDigits()
		_pH_ = @oString.Engine()
		return StzEngineStringCountDigits(_pH_) > 0

	# TRUE if every character of the text is a digit; an empty text answers FALSE.
	#
	#   returns    TRUE or FALSE
	#   note       12.5 is not only digits, because of the point
	#   see        ContainsDigits
	def ContainsOnlyDigits()
		_pH_ = @oString.Engine()
		return StzEngineStringIsDigit(_pH_)

	# TRUE if every character is a letter of any script; digits, spaces and punctuation make it FALSE.
	#
	#   returns    TRUE or FALSE
	#   note       an empty text answers FALSE
	#   see        ContainsOnlyLatinLetters
	def ContainsOnlyLetters()
		_pH_ = @oString.Engine()
		return StzEngineStringIsAlphaOnly(_pH_)

	# TRUE if every character is a Latin letter, accented letters included.
	#
	#   returns    TRUE or FALSE
	#   note       an accented Latin word is TRUE; an Arabic word is FALSE
	#   see        ContainsOnlyLetters, IsAscii
	def ContainsOnlyLatinLetters()
		_pH_ = @oString.Engine()
		return StzEngineStringIsLatinLetters(_pH_)

	# TRUE if every character is in the 7-bit ASCII range; an empty text answers TRUE.
	#
	#   returns    TRUE or FALSE
	#   note       an accented letter makes it FALSE
	#   see        ContainsOnlyLatinLetters
	def IsAscii()
		_pH_ = @oString.Engine()
		return StzEngineStringIsAscii(_pH_)

	# TRUE if the text has at least one punctuation mark.
	#
	#   returns    TRUE or FALSE
	#   note       the point of 12.5 counts
	#   see        ContainsWhitespace
	def ContainsPunctuation()
		_pH_ = @oString.Engine()
		return StzEngineStringCountPunctuation(_pH_) > 0

	# TRUE if the text has at least one space.
	#
	#   returns    TRUE or FALSE
	#   see        ContainsOnlyWhitespace, ContainsPunctuation
	def ContainsWhitespace()
		_pH_ = @oString.Engine()
		return StzEngineStringCountSpaces(_pH_) > 0

	# TRUE if the text is made of spaces only; an empty text answers FALSE.
	#
	#   returns    TRUE or FALSE
	#   see        ContainsWhitespace, IsEmpty
	def ContainsOnlyWhitespace()
		if @oString.IsEmpty()
			return 0
		ok
		_pH_ = @oString.Engine()
		return StzEngineStringCountSpaces(_pH_) = @oString.NumberOfChars()
