#--------------------------------------------------------------#
#         SOFTANZA LIBRARY (V0.9) - STZSTRINGREPLACER          #
#   An accelerative library for Ring applications, and more!   #
#--------------------------------------------------------------#
#                                                              #
#   Description  : String replacer subclass -- replacing,      #
#                  removing, and inserting operations.          #
#                  Canonical methods only. For full Softanza    #
#                  fluency (aliases), use stzStringReplacerXT.  #
#   Version      : V0.9 (2026)                                 #
#   Author       : Mansour Ayouni (kalidianow@gmail.com)       #
#                                                              #
#--------------------------------------------------------------#


  /////////////////
 ///   CLASS   ///
/////////////////

class stzStringReplacer from stzString

	  #========================================#
	 #     REPLACE -- ALL OCCURRENCES         #
	#========================================#

	def ReplaceCS(pcSubStr, pcNewSubStr, pCaseSensitive)

		if CheckingParams()

			if isList(pcSubStr)
				This.ReplaceManyCS(pcSubStr, pcNewSubStr, pCaseSensitive)
				return
			ok

			if NOT isString(pcSubstr)
				stzRaise("Incorrect param type! pcSubstr must be a string.")
			ok

			if isList(pcNewSubStr)
				_oList_ = StzListQ(pcNewSubStr)

				if _oList_.IsWithOrUsingOrByNamedParam() or
				   _oList_.IsWithManyOrUsingManyOrByManyNamedParam()

					pcNewSubStr = pcNewSubStr[2]
				ok
			ok

			if isList(pcNewSubStr)
				return This.ReplaceByManyCS(pcSubStr, pcNewSubStr, pCaseSensitive)
			ok

		ok

		_bCase_ = @CaseSensitive(pCaseSensitive)
		_cResult_ = This.Content()

		_cResult_ = @ReplaceCS(_cResult_, pcSubStr, pcNewSubStr, _bCase_)
		This.Update(_cResult_)

		def ReplaceCSQ(pcSubStr, pcNewSubStr, pCaseSensitive)
			This.ReplaceCS(pcSubStr, pcNewSubStr, pCaseSensitive)
			return This

		def ReplacedCS(pcSubStr, pcNewSubStr, pCaseSensitive)
			oCopy = new stzStringReplacer(This.Content())
			oCopy.ReplaceCS(pcSubStr, pcNewSubStr, pCaseSensitive)
			return oCopy.Content()

	def Replace(pcSubStr, pcNewSubStr)
		This.ReplaceCS(pcSubStr, pcNewSubStr, 1)

		def ReplaceQ(pcSubStr, pcNewSubStr)
			This.Replace(pcSubStr, pcNewSubStr)
			return This

		def Replaced(pcSubStr, pcNewSubStr)
			oCopy = new stzStringReplacer(This.Content())
			oCopy.Replace(pcSubStr, pcNewSubStr)
			return oCopy.Content()

	  #========================================#
	 #     REPLACE NTH OCCURRENCE            #
	#========================================#

	def ReplaceNthCS(n, pcSubStr, pcNewSubStr, pCaseSensitive)

		nPos = StzStringFinderQ(This.Content()).FindNthCS(n, pcSubStr, pCaseSensitive)

		if nPos = 0
			return
		ok

		nLenOld = Q(pcSubStr).NumberOfChars()
		cResult = This._ReplaceRange(nPos, nLenOld, pcNewSubStr)
		This.Update(cResult)

		def ReplaceNthCSQ(n, pcSubStr, pcNewSubStr, pCaseSensitive)
			This.ReplaceNthCS(n, pcSubStr, pcNewSubStr, pCaseSensitive)
			return This

	def ReplaceNth(n, pcSubStr, pcNewSubStr)
		This.ReplaceNthCS(n, pcSubStr, pcNewSubStr, 1)

		def ReplaceNthQ(n, pcSubStr, pcNewSubStr)
			This.ReplaceNth(n, pcSubStr, pcNewSubStr)
			return This

	  #========================================#
	 #     REPLACE FIRST OCCURRENCE          #
	#========================================#

	def ReplaceFirstCS(pcSubStr, pcNewSubStr, pCaseSensitive)
		This.ReplaceNthCS(1, pcSubStr, pcNewSubStr, pCaseSensitive)

		def ReplaceFirstCSQ(pcSubStr, pcNewSubStr, pCaseSensitive)
			This.ReplaceFirstCS(pcSubStr, pcNewSubStr, pCaseSensitive)
			return This

	def ReplaceFirst(pcSubStr, pcNewSubStr)
		This.ReplaceFirstCS(pcSubStr, pcNewSubStr, 1)

		def ReplaceFirstQ(pcSubStr, pcNewSubStr)
			This.ReplaceFirst(pcSubStr, pcNewSubStr)
			return This

	  #========================================#
	 #     REPLACE LAST OCCURRENCE           #
	#========================================#

	def ReplaceLastCS(pcSubStr, pcNewSubStr, pCaseSensitive)
		n = StzStringFinderQ(This.Content()).NumberOfOccurrenceCS(pcSubStr, pCaseSensitive)
		This.ReplaceNthCS(n, pcSubStr, pcNewSubStr, pCaseSensitive)

		def ReplaceLastCSQ(pcSubStr, pcNewSubStr, pCaseSensitive)
			This.ReplaceLastCS(pcSubStr, pcNewSubStr, pCaseSensitive)
			return This

	def ReplaceLast(pcSubStr, pcNewSubStr)
		This.ReplaceLastCS(pcSubStr, pcNewSubStr, 1)

		def ReplaceLastQ(pcSubStr, pcNewSubStr)
			This.ReplaceLast(pcSubStr, pcNewSubStr)
			return This

	  #========================================#
	 #     REPLACE MANY SUBSTRINGS           #
	#========================================#

	def ReplaceManyCS(pacSubStrings, pcNewSubStr, pCaseSensitive)
		if NOT isList(pacSubStrings)
			StzRaise("Incorrect param type! pacSubStrings must be a list.")
		ok

		nLen = len(pacSubStrings)
		for i = 1 to nLen
			This.ReplaceCS(pacSubStrings[i], pcNewSubStr, pCaseSensitive)
		next

		def ReplaceManyCSQ(pacSubStrings, pcNewSubStr, pCaseSensitive)
			This.ReplaceManyCS(pacSubStrings, pcNewSubStr, pCaseSensitive)
			return This

	def ReplaceMany(pacSubStrings, pcNewSubStr)
		This.ReplaceManyCS(pacSubStrings, pcNewSubStr, 1)

		def ReplaceManyQ(pacSubStrings, pcNewSubStr)
			This.ReplaceMany(pacSubStrings, pcNewSubStr)
			return This

	  #===============================#
	 #     REMOVE -- ALL            #
	#===============================#

	def RemoveCS(pSubStr, pCaseSensitive)
		if CheckingParams()
			if isList(pSubStr)
				oParam = new stzList(pSubStr)

				if oParam.IsListOfStrings()
					This.RemoveManyCS(pSubStr, pCaseSensitive)
				ok
				return
			ok
		ok

		This.ReplaceCS(pSubstr, "", pCaseSensitive)

		def RemoveCSQ(pSubStr, pCaseSensitive)
			This.RemoveCS(pSubStr, pCaseSensitive)
			return This

		def RemovedCS(pSubStr, pCaseSensitive)
			oCopy = new stzStringReplacer(This.Content())
			oCopy.RemoveCS(pSubStr, pCaseSensitive)
			return oCopy.Content()

	def Remove(pcSubStr)
		This.RemoveCS(pcSubStr, 1)

		def RemoveQ(pcSubStr)
			This.Remove(pcSubStr)
			return This

		def Removed(pcSubStr)
			oCopy = new stzStringReplacer(This.Content())
			oCopy.Remove(pcSubStr)
			return oCopy.Content()

	  #===============================#
	 #     REMOVE MANY              #
	#===============================#

	def RemoveManyCS(pacSubStrings, pCaseSensitive)
		if NOT isList(pacSubStrings)
			StzRaise("Incorrect param type! pacSubStrings must be a list.")
		ok

		nLen = len(pacSubStrings)
		for i = 1 to nLen
			This.RemoveCS(pacSubStrings[i], pCaseSensitive)
		next

		def RemoveManyCSQ(pacSubStrings, pCaseSensitive)
			This.RemoveManyCS(pacSubStrings, pCaseSensitive)
			return This

	def RemoveMany(pacSubStrings)
		This.RemoveManyCS(pacSubStrings, 1)

		def RemoveManyQ(pacSubStrings)
			This.RemoveMany(pacSubStrings)
			return This

	  #===============================#
	 #     REMOVE NTH/FIRST/LAST    #
	#===============================#

	def RemoveNthCS(n, pcSubStr, pCaseSensitive)
		This.ReplaceNthCS(n, pcSubStr, "", pCaseSensitive)

		def RemoveNthCSQ(n, pcSubStr, pCaseSensitive)
			This.RemoveNthCS(n, pcSubStr, pCaseSensitive)
			return This

	def RemoveNth(n, pcSubStr)
		This.RemoveNthCS(n, pcSubStr, 1)

	def RemoveFirstCS(pcSubStr, pCaseSensitive)
		This.RemoveNthCS(1, pcSubStr, pCaseSensitive)

	def RemoveFirst(pcSubStr)
		This.RemoveFirstCS(pcSubStr, 1)

	def RemoveLastCS(pcSubStr, pCaseSensitive)
		n = StzStringFinderQ(This.Content()).NumberOfOccurrenceCS(pcSubStr, pCaseSensitive)
		This.RemoveNthCS(n, pcSubStr, pCaseSensitive)

	def RemoveLast(pcSubStr)
		This.RemoveLastCS(pcSubStr, 1)

	  #===============================#
	 #     INSERT BEFORE / AFTER    #
	#===============================#

	def InsertBefore(nPos, pcSubStr)
		if NOT isNumber(nPos)
			StzRaise("Incorrect param type! nPos must be a number.")
		ok

		if NOT isString(pcSubStr)
			StzRaise("Incorrect param type! pcSubStr must be a string.")
		ok

		if nPos < 1 or nPos > This.NumberOfChars() + 1
			return
		ok

		cContent = This.Content()
		cResult = substr(cContent, 1, nPos - 1) + pcSubStr + substr(cContent, nPos)
		This.Update(cResult)

		def InsertBeforeQ(nPos, pcSubStr)
			This.InsertBefore(nPos, pcSubStr)
			return This

	def InsertAfter(nPos, pcSubStr)
		This.InsertBefore(nPos + 1, pcSubStr)

		def InsertAfterQ(nPos, pcSubStr)
			This.InsertAfter(nPos, pcSubStr)
			return This
