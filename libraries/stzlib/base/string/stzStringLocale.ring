#--------------------------------------------------------------#
#        SOFTANZA LIBRARY (V0.9) - STZSTRINGLOCALE             #
#   An accelerative library for Ring applications, and more!   #
#--------------------------------------------------------------#
#                                                              #
#   Description  : String locale -- Wraps stzString via         #
#                  composition. Locale-aware operations:         #
#                  language, country, script, currency           #
#                  detection and formatting.                     #
#   Version      : V0.9 (2026)                                 #
#   Author       : Mansour Ayouni (kalidianow@gmail.com)       #
#                                                              #
#--------------------------------------------------------------#


  /////////////////
 ///   CLASS   ///
/////////////////

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
		cContent = @oString.Content()
		nLen = len(cContent)

		for i = 1 to nLen
			c = substr(cContent, i, 1)
			n = ascii(c)
			if n >= 65 and n <= 122
				return 1
			ok
		next
		return 0

	def ContainsLatinLetters()
		cContent = @oString.Content()
		nLen = len(cContent)

		for i = 1 to nLen
			c = substr(cContent, i, 1)
			n = ascii(c)
			if (n >= 65 and n <= 90) or (n >= 97 and n <= 122)
				return 1
			ok
		next
		return 0

	def IsRightToLeft()
		cContent = @oString.Content()
		if len(cContent) = 0
			return 0
		ok

		n = ascii(substr(cContent, 1, 1))
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
			n = ascii(substr(@oString.Content(), 1, 1))
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
		cContent = @oString.Content()
		nLen = len(cContent)

		for i = 1 to nLen
			c = substr(cContent, i, 1)
			n = ascii(c)
			if n >= 0x0600 and n <= 0x06FF
				return 1
			ok
		next
		return 0

	def ContainsDigits()
		cContent = @oString.Content()
		nLen = len(cContent)

		for i = 1 to nLen
			c = substr(cContent, i, 1)
			n = ascii(c)
			if n >= 48 and n <= 57
				return 1
			ok
		next
		return 0

	def ContainsOnlyDigits()
		cContent = @oString.Content()
		nLen = len(cContent)
		if nLen = 0
			return 0
		ok

		for i = 1 to nLen
			c = substr(cContent, i, 1)
			n = ascii(c)
			if n < 48 or n > 57
				return 0
			ok
		next
		return 1

	def ContainsOnlyLetters()
		cContent = @oString.Content()
		nLen = len(cContent)
		if nLen = 0
			return 0
		ok

		for i = 1 to nLen
			c = substr(cContent, i, 1)
			n = ascii(c)
			if NOT ((n >= 65 and n <= 90) or (n >= 97 and n <= 122))
				return 0
			ok
		next
		return 1

	def ContainsOnlyLatinLetters()
		cContent = @oString.Content()
		nLen = len(cContent)
		if nLen = 0
			return 0
		ok

		for i = 1 to nLen
			c = substr(cContent, i, 1)
			n = ascii(c)
			if NOT ((n >= 65 and n <= 90) or (n >= 97 and n <= 122) or n = 32)
				return 0
			ok
		next
		return 1

	def IsAscii()
		cContent = @oString.Content()
		nLen = len(cContent)
		if nLen = 0
			return 1
		ok

		for i = 1 to nLen
			c = substr(cContent, i, 1)
			n = ascii(c)
			if n >= 128
				return 0
			ok
		next
		return 1

	def ContainsPunctuation()
		cContent = @oString.Content()
		cPunct = ".,;:!?-()[]{}'" + '"'
		nLen = len(cContent)

		for i = 1 to nLen
			c = substr(cContent, i, 1)
			nPLen = len(cPunct)
			for j = 1 to nPLen
				if c = substr(cPunct, j, 1)
					return 1
				ok
			next
		next
		return 0

	def ContainsWhitespace()
		cContent = @oString.Content()
		nLen = len(cContent)

		for i = 1 to nLen
			c = substr(cContent, i, 1)
			if c = " " or c = char(9) or c = char(10) or c = char(13)
				return 1
			ok
		next
		return 0

	def ContainsOnlyWhitespace()
		cContent = @oString.Content()
		nLen = len(cContent)
		if nLen = 0
			return 0
		ok

		for i = 1 to nLen
			c = substr(cContent, i, 1)
			if NOT (c = " " or c = char(9) or c = char(10) or c = char(13))
				return 0
			ok
		next
		return 1

	def IsMixedScript()
		bHasLatin = This.ContainsLatinLetters()
		bHasNonLatin = 0

		cContent = @oString.Content()
		nLen = len(cContent)

		for i = 1 to nLen
			c = substr(cContent, i, 1)
			n = ascii(c)
			# Skip whitespace and punctuation
			if c = " " or c = char(9) or c = char(10) or c = char(13)
				loop
			ok
			if (n >= 48 and n <= 57)
				loop
			ok
			# If it's not a Latin letter and not a digit/whitespace, it's non-Latin
			if NOT ((n >= 65 and n <= 90) or (n >= 97 and n <= 122))
				bHasNonLatin = 1
				exit
			ok
		next

		if bHasLatin and bHasNonLatin
			return 1
		else
			return 0
		ok
