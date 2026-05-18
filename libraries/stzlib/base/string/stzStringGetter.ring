#--------------------------------------------------------------#
#        SOFTANZA LIBRARY (V0.9) - STZSTRINGGETTER             #
#   An accelerative library for Ring applications, and more!   #
#--------------------------------------------------------------#
#                                                              #
#   Description  : String getter subclass -- accessing         #
#                  individual chars and char groups.           #
#                  For aliases, use stzStringGetterXT.         #
#   Version      : V0.9 (2026)                                 #
#   Author       : Mansour Ayouni (kalidianow@gmail.com)       #
#                                                              #
#--------------------------------------------------------------#


  /////////////////
 ///   CLASS   ///
/////////////////

class stzStringGetter from stzString

	  #======================================================#
	 #   ACCESSING NTH CHAR                                 #
	#======================================================#

	def NthChar(n)
		return This.Content()[n]

		def CharAt(n)
			return This.NthChar(n)

		def CharAtPosition(n)
			return This.NthChar(n)

	  #======================================================#
	 #   FIRST / LAST / MIDDLE CHAR                         #
	#======================================================#

	def FirstChar()
		return This.NthChar(1)

	def LastChar()
		return This.NthChar(This.NumberOfChars())

	def MiddleChar()
		n = ceil(This.NumberOfChars() / 2)
		return This.NthChar(n)

	  #======================================================#
	 #   N FIRST / N LAST CHARS                             #
	#======================================================#

	def NFirstChars(n)
		return This.Section(1, n)

		def NFirstCharsQ(n)
			return StzStringQ(This.NFirstChars(n))

	def NLastChars(n)
		nLen = This.NumberOfChars()
		return This.Section(nLen - n + 1, nLen)

		def NLastCharsQ(n)
			return StzStringQ(This.NLastChars(n))

	  #======================================================#
	 #   N LEFT / N RIGHT CHARS                             #
	#======================================================#

	def NLeftChars(n)
		if This.IsLeftToRight()
			return This.NFirstChars(n)
		else
			return This.NLastChars(n)
		ok

		def NLeftCharsQ(n)
			return StzStringQ(This.NLeftChars(n))

		def NLeftCharsAsString(n)
			return This.NLeftChars(n)

		def NLeftCharsAsStringQ(n)
			return StzStringQ(This.NLeftChars(n))

	def NRightChars(n)
		if This.IsLeftToRight()
			return This.NLastChars(n)
		else
			return This.NFirstChars(n)
		ok

		def NRightCharsQ(n)
			return StzStringQ(This.NRightChars(n))

		def NRightCharsAsString(n)
			return This.NRightChars(n)

		def NRightCharsAsStringQ(n)
			return StzStringQ(This.NRightChars(n))

	  #======================================================#
	 #   ALL CHARS AS LIST                                  #
	#======================================================#

	def Chars()
		aResult = []
		cStr = This.Content()
		nLen = This.NumberOfChars()
		for i = 1 to nLen
			aResult + cStr[i]
		next
		return aResult

	  #======================================================#
	 #   UNIQUE CHARS                                       #
	#======================================================#

	def UniqueCharsCS(pCaseSensitive)
		aChars = This.Chars()
		return UCS(aChars, pCaseSensitive)

	def UniqueChars()
		return This.UniqueCharsCS(1)

	  #======================================================#
	 #   SECTION / RANGE ACCESS                             #
	#======================================================#

	def Section(n1, n2)
		nLen = This.NumberOfChars()
		if n1 < 1
			n1 = 1
		ok
		if n2 > nLen
			n2 = nLen
		ok
		if n1 > n2
			temp = n1
			n1 = n2
			n2 = temp
		ok
		return substr(This.Content(), n1, n2 - n1 + 1)

	def Range(nStart, nRange)
		return This.Section(nStart, nStart + nRange - 1)
