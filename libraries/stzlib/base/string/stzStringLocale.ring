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


class stzStringLocale

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
		oLocale = new stzLocale(pcLocale)
		return oLocale.ToLowercase(@oString.Content())

	def UppercasedInLocale(pcLocale)
		oLocale = new stzLocale(pcLocale)
		return oLocale.ToUppercase(@oString.Content())

	  #===============================#
	 #     LANGUAGE DETECTION        #
	#===============================#

	def IsLatinScript()
		pH = @oString.Engine()
		return StzEngineStringIsLatin(pH)

	def ContainsLatinLetters()
		pH = @oString.Engine()
		return StzEngineStringContainsLatin(pH)

	def IsRightToLeft()
		if @oString.NumberOfChars() = 0
			return 0
		ok

		n = StzEngineStringCharUnicodeAt(@oString.Engine(), 1)
		if (n >= 0x0600 and n <= 0x06FF) or
		   (n >= 0x0590 and n <= 0x05FF) or
		   (n >= 0xFB50 and n <= 0xFDFF)
			return 1
		else
			return 0
		ok

		def IsRTL()
			return This.IsRightToLeft()

	def IsLeftToRight()
		return NOT This.IsRightToLeft()

		def IsLTR()
			return This.IsLeftToRight()

	  #===============================#
	 #     SCRIPT DETECTION          #
	#===============================#

	def Script()
		if This.IsRightToLeft()
			n = StzEngineStringCharUnicodeAt(@oString.Engine(), 1)
			if n >= 0x0600 and n <= 0x06FF
				return :Arabic
			but n >= 0x0590 and n <= 0x05FF
				return :Hebrew
			ok
		ok
		if This.ContainsLatinLetters()
			return :Latin
		ok
		return :Unknown

	  #===============================#
	 #     CHARACTER CLASS TESTS     #
	#===============================#

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
		# All chars must be whitespace: count of spaces = total codepoints
		pH = @oString.Engine()
		return StzEngineStringCountSpaces(pH) = @oString.NumberOfChars()

	def IsMixedScript()
		pH = @oString.Engine()
		bHasLatin = StzEngineStringContainsLatin(pH)
		bHasArabic = StzEngineStringContainsArabic(pH)
		if bHasLatin and bHasArabic
			return 1
		ok
		# Could extend to check Hebrew, Greek, CJK etc.
		return 0
