#--------------------------------------------------------------#
#        SOFTANZA LIBRARY (V0.9) - STZLISTTRIMMER             #
#   An accelerative library for Ring applications, and more!   #
#--------------------------------------------------------------#
#                                                              #
#   Description  : List trimmer subclass -- trim leading and  #
#                  trailing empty items. For aliases, use      #
#                  stzListTrimmerXT.                            #
#   Version      : V0.9 (2026)                                #
#   Author       : Mansour Ayouni (kalidianow@gmail.com)       #
#                                                              #
#--------------------------------------------------------------#


  /////////////////
 ///   CLASS   ///
/////////////////

class stzListTrimmer from stzList

	def TrimCS(pCaseSensitive)
		_oCopy_ = This.Copy()
		_oCopy_.TrimLeftCS(pCaseSensitive)
		_oCopy_.TrimRightCS(pCaseSensitive)
		This.UpdateWith(_oCopy_.Content())

		def TrimCSQ(pCaseSensitive)
			This.TrimCS(pCaseSensitive)
			return This

	def TrimmedCS(pCaseSensitive)
		aResult = This.Copy().TrimCSQ(pCaseSensitive).Content()
		return aResult

	def Trim()
		This.TrimCS(1)

		def TrimQ()
			return This.TrimCSQ(1)

	def Trimmed()
		return This.TrimmedCS(1)

	def TrimLeftCS(pCaseSensitive)
		aContent = This.Content()
		nLen = len(aContent)
		if nLen < 1
			return
		ok
		nStart = 0
		for i = 1 to nLen
			if isString(aContent[i]) and ring_trim(aContent[i]) = ""
				nStart = i
			else
				exit
			ok
		next
		if nStart > 0
			This.RemoveSection(1, nStart)
		ok

		def TrimLeftCSQ(pCaseSensitive)
			This.TrimLeftCS(pCaseSensitive)
			return This

	def TrimLeft()
		This.TrimLeftCS(1)

	def TrimmedLeft()
		return This.Copy().TrimLeftCSQ(1).Content()

	def TrimRightCS(pCaseSensitive)
		aContent = This.Content()
		nLen = len(aContent)
		if nLen < 1
			return
		ok
		nEnd = 0
		for i = nLen to 1 step -1
			if isString(aContent[i]) and ring_trim(aContent[i]) = ""
				nEnd = i
			else
				exit
			ok
		next
		if nEnd > 0
			This.RemoveSection(nEnd, nLen)
		ok

		def TrimRightCSQ(pCaseSensitive)
			This.TrimRightCS(pCaseSensitive)
			return This

	def TrimRight()
		This.TrimRightCS(1)

	def TrimmedRight()
		return This.Copy().TrimRightCSQ(1).Content()
