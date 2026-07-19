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


class stzStringLocale from stzObject

	@oString

	def init(pStrOrStzStrObj)
		if isString(pStrOrStzStrObj)
			@oString = new stzString(pStrOrStzStrObj)
		but isObject(pStrOrStzStrObj)
			@oString = pStrOrStzStrObj
		else
			StzRaise("Can't create stzStringLocale! Parameter must be a string or stzString object.")
		ok

	def Content()
		return @oString.Content()

	def NumberOfChars()
		return @oString.NumberOfChars()

	def IsEmpty()
		return @oString.IsEmpty()

	  #===============================#
	 #     LOCALE CASE CONVERSION    #
	#===============================#

	def LowercasedInLocale(pcLocale)
		_oLocale_ = new stzLocale(pcLocale)
		return _oLocale_.ToLowercase(@oString.Content())

	def UppercasedInLocale(pcLocale)
		_oLocale_ = new stzLocale(pcLocale)
		return _oLocale_.ToUppercase(@oString.Content())

	  #======================================#
	 #     SCRIPT DETECTION (Engine-backed) #
	#======================================#

	def DetectScript()
		pH = @oString.Engine()
		return StzEngineStringDetectScript(pH)

	def ScriptName()
		pH = @oString.Engine()
		pR = StzEngineStringScriptName(pH)
		_lcName_ = StzEngineStringData(pR)
		StzEngineStringFree(pR)
		return _lcName_

	def Script()
		return This.ScriptName()

	# How many scripts the string uses -- COMMON INCLUDED.
	#
	# Common is the bucket for digits, spaces and punctuation. Counting it is
	# the ruled definition, and it makes this agree with
	# stzStringText.Scripts(), which has always LISTED common as a script of
	# its own. The two used to disagree on ordinary text:
	#
	#   "hello 123"          Scripts() [latin, common]  = 2, here 1
	#   arabic + " latin"    [arabic, common, latin]    = 3, here 2
	#   "   "                [common]                   = 1, here 0
	#
	# Two methods answering "how many scripts" with different numbers is the
	# kind of split a caller only discovers by accident, so they now match.
	def ScriptCount()
		pH = @oString.Engine()
		return StzEngineStringScriptCountAll(pH)

	# Scripts EXCLUDING common -- the count of real writing systems.
	def ScriptCountExcludingCommon()
		pH = @oString.Engine()
		return StzEngineStringScriptCount(pH)

	# Deliberately NOT ScriptCount() > 1.
	#
	# "Mixed script" means mixing writing systems -- Latin with Cyrillic, the
	# shape of a homograph attack. Digits and spaces are not a second writing
	# system, so counting common here would make "hello 123", and every
	# invoice line ever written, mixed-script.
	def IsMixedScript()
		return This.ScriptCountExcludingCommon() > 1

	def IsLatinScript()
		return This.ScriptName() = "Latin"

	def IsArabicScript()
		return This.ScriptName() = "Arabic"

	def IsHebrewScript()
		return This.ScriptName() = "Hebrew"

	def IsCyrillicScript()
		return This.ScriptName() = "Cyrillic"

	def IsGreekScript()
		return This.ScriptName() = "Greek"

	def IsCJKScript()
		return This.ScriptName() = "CJK"

	def IsDevanagariScript()
		return This.ScriptName() = "Devanagari"

	def IsThaiScript()
		return This.ScriptName() = "Thai"

	  #========================================#
	 #     DIRECTION DETECTION (Engine-backed) #
	#========================================#

	def DetectDirection()
		pH = @oString.Engine()
		return StzEngineStringDetectDirection(pH)

	def DirectionName()
		pH = @oString.Engine()
		pR = StzEngineStringDirectionName(pH)
		_lcDir_ = StzEngineStringData(pR)
		StzEngineStringFree(pR)
		return _lcDir_

	def Direction()
		return This.DirectionName()

	def IsRightToLeft()
		pH = @oString.Engine()
		return StzEngineStringDetectDirection(pH) = 1

		def IsRTL()
			return This.IsRightToLeft()

	def IsLeftToRight()
		pH = @oString.Engine()
		return StzEngineStringDetectDirection(pH) = 0

		def IsLTR()
			return This.IsLeftToRight()

	def HasRTL()
		pH = @oString.Engine()
		return StzEngineStringHasRTL(pH) = 1

	def IsBidiMixed()
		pH = @oString.Engine()
		return StzEngineStringDetectDirection(pH) = 2

	def IsBidiNeutral()
		pH = @oString.Engine()
		return StzEngineStringDetectDirection(pH) = 3

	  #=============================================#
	 #     LOCALE COMPARISON (Engine-backed)        #
	#=============================================#

	def LocaleCompare(pcOther)
		pH1 = @oString.Engine()
		pH2 = StzEngineString(pcOther)
		_lcResult_ = StzEngineStringLocaleCompare(pH1, pH2)
		StzEngineStringFree(pH2)
		return _lcResult_

	def LocaleEquals(pcOther)
		return This.LocaleCompare(pcOther) = 0

	def LocaleLessThan(pcOther)
		return This.LocaleCompare(pcOther) = -1

	def LocaleGreaterThan(pcOther)
		return This.LocaleCompare(pcOther) = 1

	  #===============================#
	 #     CHARACTER CLASS TESTS     #
	#===============================#

	def ContainsLatinLetters()
		pH = @oString.Engine()
		return StzEngineStringContainsLatin(pH)

	def ContainsArabicLetters()
		pH = @oString.Engine()
		return StzEngineStringContainsArabic(pH)

	def ContainsDigits()
		pH = @oString.Engine()
		return StzEngineStringCountDigits(pH) > 0

	def ContainsOnlyDigits()
		pH = @oString.Engine()
		return StzEngineStringIsDigit(pH)

	def ContainsOnlyLetters()
		pH = @oString.Engine()
		return StzEngineStringIsAlphaOnly(pH)

	def ContainsOnlyLatinLetters()
		pH = @oString.Engine()
		return StzEngineStringIsLatinLetters(pH)

	def IsAscii()
		pH = @oString.Engine()
		return StzEngineStringIsAscii(pH)

	def ContainsPunctuation()
		pH = @oString.Engine()
		return StzEngineStringCountPunctuation(pH) > 0

	def ContainsWhitespace()
		pH = @oString.Engine()
		return StzEngineStringCountSpaces(pH) > 0

	def ContainsOnlyWhitespace()
		if @oString.IsEmpty()
			return 0
		ok
		pH = @oString.Engine()
		return StzEngineStringCountSpaces(pH) = @oString.NumberOfChars()
