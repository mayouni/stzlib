#--------------------------------------------------------------#
#        SOFTANZA LIBRARY (V0.9) - STZSTRINGTRIMMER            #
#   An accelerative library for Ring applications, and more!   #
#--------------------------------------------------------------#
#                                                              #
#   Description  : String trimmer subclass -- trimming         #
#                  whitespace and chars from strings.           #
#                  For aliases, use stzStringTrimmerXT.         #
#   Version      : V0.9 (2026)                                #
#   Author       : Mansour Ayouni (kalidianow@gmail.com)       #
#                                                              #
#--------------------------------------------------------------#


  /////////////////
 ///   CLASS   ///
/////////////////

class stzStringTrimmer from stzString

	  #======================================================#
	 #   TRIMMING BOTH SIDES                                #
	#======================================================#

	def Trim()
		This.Update(ring_trim(This.Content()))

		def TrimQ()
			This.Trim()
			return This

	def Trimmed()
		return ring_trim(This.Content())

	  #======================================================#
	 #   TRIMMING LEFT / RIGHT                              #
	#======================================================#

	def TrimLeft()
		This.Update(ring_ltrim(This.Content()))

		def TrimLeftQ()
			This.TrimLeft()
			return This

	def TrimmedLeft()
		return ring_ltrim(This.Content())

	def TrimRight()
		This.Update(ring_rtrim(This.Content()))

		def TrimRightQ()
			This.TrimRight()
			return This

	def TrimmedRight()
		return ring_rtrim(This.Content())

	  #======================================================#
	 #   TRIMMING START / END                               #
	#======================================================#

	def TrimStart()
		This.TrimLeft()

		def TrimStartQ()
			This.TrimStart()
			return This

	def TrimmedFromStart()
		return This.TrimmedLeft()

	def TrimEnd()
		This.TrimRight()

		def TrimEndQ()
			This.TrimEnd()
			return This

	def TrimmedFromEnd()
		return This.TrimmedRight()

	  #======================================================#
	 #   TRIMMING A SPECIFIC CHAR                           #
	#======================================================#

	def TrimCharCS(c, pCaseSensitive)
		This.TrimCharFromStartCS(c, pCaseSensitive)
		This.TrimCharFromEndCS(c, pCaseSensitive)

		def TrimCharCSQ(c, pCaseSensitive)
			This.TrimCharCS(c, pCaseSensitive)
			return This

	def CharTrimmedCS(c, pCaseSensitive)
		return This.Copy().TrimCharCSQ(c, pCaseSensitive).Content()

	def TrimChar(c)
		This.TrimCharCS(c, 1)

		def TrimCharQ(c)
			This.TrimChar(c)
			return This

	def CharTrimmed(c)
		return This.CharTrimmedCS(c, 1)

	  #======================================================#
	 #   TRIMMING CHAR FROM START / END                     #
	#======================================================#

	def TrimCharFromStartCS(c, pCaseSensitive)
		cStr = This.Content()
		nLen = len(cStr)
		nStart = 1
		for i = 1 to nLen
			if BothStringsAreEqualCS(cStr[i], c, pCaseSensitive)
				nStart = i + 1
			else
				exit
			ok
		next
		if nStart > nLen
			This.Update("")
		else
			This.Update(substr(cStr, nStart, nLen - nStart + 1))
		ok

		def TrimCharFromStartCSQ(c, pCaseSensitive)
			This.TrimCharFromStartCS(c, pCaseSensitive)
			return This

		def RemoveThisCharFromStartCS(c, pCaseSensitive)
			This.TrimCharFromStartCS(c, pCaseSensitive)

	def TrimCharFromStart(c)
		This.TrimCharFromStartCS(c, 1)

		def RemoveThisCharFromStart(c)
			This.TrimCharFromStart(c)

	#--

	def TrimCharFromEndCS(c, pCaseSensitive)
		cStr = This.Content()
		nLen = len(cStr)
		nEnd = nLen
		for i = nLen to 1 step -1
			if BothStringsAreEqualCS(cStr[i], c, pCaseSensitive)
				nEnd = i - 1
			else
				exit
			ok
		next
		if nEnd < 1
			This.Update("")
		else
			This.Update(substr(cStr, 1, nEnd))
		ok

		def TrimCharFromEndCSQ(c, pCaseSensitive)
			This.TrimCharFromEndCS(c, pCaseSensitive)
			return This

		def RemoveThisCharFromEndCS(c, pCaseSensitive)
			This.TrimCharFromEndCS(c, pCaseSensitive)

	def TrimCharFromEnd(c)
		This.TrimCharFromEndCS(c, 1)

		def RemoveThisCharFromEnd(c)
			This.TrimCharFromEnd(c)

	  #======================================================#
	 #   TRIMMING CHAR FROM LEFT / RIGHT                    #
	#======================================================#

	def TrimCharFromLeftCS(c, pCaseSensitive)
		if This.IsLeftToRight()
			This.TrimCharFromStartCS(c, pCaseSensitive)
		else
			This.TrimCharFromEndCS(c, pCaseSensitive)
		ok

	def TrimCharFromLeft(c)
		This.TrimCharFromLeftCS(c, 1)

	def TrimCharFromRightCS(c, pCaseSensitive)
		if This.IsLeftToRight()
			This.TrimCharFromEndCS(c, pCaseSensitive)
		else
			This.TrimCharFromStartCS(c, pCaseSensitive)
		ok

	def TrimCharFromRight(c)
		This.TrimCharFromRightCS(c, 1)
