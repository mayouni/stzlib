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
		_pH_ = @oString.Engine()
		return StzEngineStringDetectScript(_pH_)

	def ScriptName()
		_pH_ = @oString.Engine()
		_pR_ = StzEngineStringScriptName(_pH_)
		_lcName_ = StzEngineStringData(_pR_)
		StzEngineStringFree(_pR_)
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
		_pH_ = @oString.Engine()
		return StzEngineStringScriptCountAll(_pH_)

	# Scripts EXCLUDING common -- the count of real writing systems.
	def ScriptCountExcludingCommon()
		_pH_ = @oString.Engine()
		return StzEngineStringScriptCount(_pH_)

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
		_pH_ = @oString.Engine()
		return StzEngineStringDetectDirection(_pH_)

	def DirectionName()
		_pH_ = @oString.Engine()
		_pR_ = StzEngineStringDirectionName(_pH_)
		_lcDir_ = StzEngineStringData(_pR_)
		StzEngineStringFree(_pR_)
		return _lcDir_

	def Direction()
		return This.DirectionName()

	def IsRightToLeft()
		_pH_ = @oString.Engine()
		return StzEngineStringDetectDirection(_pH_) = 1

		def IsRTL()
			return This.IsRightToLeft()

	def IsLeftToRight()
		_pH_ = @oString.Engine()
		return StzEngineStringDetectDirection(_pH_) = 0

		def IsLTR()
			return This.IsLeftToRight()

	def HasRTL()
		_pH_ = @oString.Engine()
		return StzEngineStringHasRTL(_pH_) = 1

	def IsBidiMixed()
		_pH_ = @oString.Engine()
		return StzEngineStringDetectDirection(_pH_) = 2

	def IsBidiNeutral()
		_pH_ = @oString.Engine()
		return StzEngineStringDetectDirection(_pH_) = 3

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
		_pH_ = @oString.Engine()
		return StzEngineStringContainsLatin(_pH_)

	def ContainsArabicLetters()
		_pH_ = @oString.Engine()
		return StzEngineStringContainsArabic(_pH_)

	def ContainsDigits()
		_pH_ = @oString.Engine()
		return StzEngineStringCountDigits(_pH_) > 0

	def ContainsOnlyDigits()
		_pH_ = @oString.Engine()
		return StzEngineStringIsDigit(_pH_)

	def ContainsOnlyLetters()
		_pH_ = @oString.Engine()
		return StzEngineStringIsAlphaOnly(_pH_)

	def ContainsOnlyLatinLetters()
		_pH_ = @oString.Engine()
		return StzEngineStringIsLatinLetters(_pH_)

	def IsAscii()
		_pH_ = @oString.Engine()
		return StzEngineStringIsAscii(_pH_)

	def ContainsPunctuation()
		_pH_ = @oString.Engine()
		return StzEngineStringCountPunctuation(_pH_) > 0

	def ContainsWhitespace()
		_pH_ = @oString.Engine()
		return StzEngineStringCountSpaces(_pH_) > 0

	def ContainsOnlyWhitespace()
		if @oString.IsEmpty()
			return 0
		ok
		_pH_ = @oString.Engine()
		return StzEngineStringCountSpaces(_pH_) = @oString.NumberOfChars()
