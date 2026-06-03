#--------------------------------------------------------------#
#        SOFTANZA LIBRARY (V0.9) - STZSTRINGCONCAT             #
#   An accelerative library for Ring applications, and more!   #
#--------------------------------------------------------------#
#                                                              #
#   Description  : String concat -- concatenation and          #
#                  repetition operations.                      #
#                  Wraps stzString via composition.            #
#                  For aliases, use stzStringConcatXT.         #
#   Version      : V0.9 (2026)                                 #
#   Author       : Mansour Ayouni (kalidianow@gmail.com)       #
#                                                              #
#--------------------------------------------------------------#


class stzStringConcat

	@oString

	def init(pStrOrStzStrObj)
		if isString(pStrOrStzStrObj)
			@oString = new stzString(pStrOrStzStrObj)
		but isObject(pStrOrStzStrObj)
			@oString = pStrOrStzStrObj
		else
			StzRaise("Can't create stzStringConcat! Parameter must be a string or stzString object.")
		ok

	def Content()
		return @oString.Content()

	def NumberOfChars()
		return @oString.NumberOfChars()

	def IsEmpty()
		return @oString.IsEmpty()

	  #======================================================#
	 #   CONCATENATION                                      #
	#======================================================#

	def Concat(pcStr)
		@oString.Update(@oString.Content() + pcStr)

		def ConcatQ(pcStr)
			This.Concat(pcStr)
			return This

	def Concatenated(pcStr)
		return @oString.Content() + pcStr

	  #======================================================#
	 #   CONCATENATING MANY STRINGS                         #
	#======================================================#

	def ConcatMany(pacStrings)
		cResult = @oString.Content()
		nLen = ring_len(pacStrings)
		for i = 1 to nLen
			cResult += pacStrings[i]
		next
		@oString.Update(cResult)

		def ConcatManyQ(pacStrings)
			This.ConcatMany(pacStrings)
			return This

	def ConcatenatedWithMany(pacStrings)
		oCopy = new stzStringConcat(@oString.Content())
		oCopy.ConcatMany(pacStrings)
		return oCopy.Content()

	  #======================================================#
	 #   PREPEND / APPEND                                   #
	#======================================================#

	def Prepend(pcStr)
		@oString.Update(pcStr + @oString.Content())

		def PrependQ(pcStr)
			This.Prepend(pcStr)
			return This

	def Prepended(pcStr)
		return pcStr + @oString.Content()

	def Append(pcStr)
		This.Concat(pcStr)

		def AppendQ(pcStr)
			This.Append(pcStr)
			return This

	def Appended(pcStr)
		return This.Concatenated(pcStr)

	  #======================================================#
	 #   REPETITION                                         #
	#======================================================#

	def RepeatNTimes(n)
		pH = @oString.Engine()
		pR = StzEngineStringRepeat(pH, n)
		if pR != 0
			@oString.Update(StzEngineStringData(pR))
			StzEngineStringFree(pR)
		ok

		def RepeatNTimesQ(n)
			This.RepeatNTimes(n)
			return This

		def Repeat(n)
			This.RepeatNTimes(n)

	def RepeatedNTimes(n)
		oCopy = new stzStringConcat(@oString.Content())
		oCopy.RepeatNTimes(n)
		return oCopy.Content()

		def Repeated(n)
			return This.RepeatedNTimes(n)

	  #======================================================#
	 #   JOIN WITH SEPARATOR                                #
	#======================================================#

	def JoinWith(pcSep)
		aChars = @oString.Chars()
		cResult = ""
		nLen = ring_len(aChars)
		for i = 1 to nLen
			cResult += aChars[i]
			if i < nLen
				cResult += pcSep
			ok
		next
		@oString.Update(cResult)

		def JoinWithQ(pcSep)
			This.JoinWith(pcSep)
			return This

	def JoinedWith(pcSep)
		oCopy = new stzStringConcat(@oString.Content())
		oCopy.JoinWith(pcSep)
		return oCopy.Content()
