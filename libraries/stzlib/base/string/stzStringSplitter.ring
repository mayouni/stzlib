#--------------------------------------------------------------#
#         SOFTANZA LIBRARY (V0.9) - STZSTRINGSPLITTER          #
#   An accelerative library for Ring applications, and more!   #
#--------------------------------------------------------------#
#                                                              #
#   Description  : String splitter subclass -- splitting       #
#                  operations at positions, substrings,         #
#                  sections, before/after/around.               #
#                  Canonical methods only. For full Softanza    #
#                  fluency (aliases), use stzStringSplitterXT.  #
#   Version      : V0.9 (2026)                                 #
#   Author       : Mansour Ayouni (kalidianow@gmail.com)       #
#                                                              #
#--------------------------------------------------------------#


  /////////////////
 ///   CLASS   ///
/////////////////

class stzStringSplitter from stzString

	  #====================================#
	 #     SPLIT -- MAIN ENTRY POINT      #
	#====================================#

	def SplitCS(pSubStrOrPos, pCaseSensitive)

		if isList(pSubStrOrPos)

			oParam = StzListQ(pSubStrOrPos)

			if oParam.IsWithOrByOrUsingNamedParam()
				return This.SplitAtCS(pSubStrOrPos[2], pCaseSensitive)

			but oParam.IsAtNamedParam()
				return This.SplitAtCS(pSubStrOrPos[2], pCaseSensitive)

			but oParam.IsAtPositionNamedParam()
				return This.SplitAtPosition(pSubStrOrPos[2])

			but oParam.IsAtPositionsNamedParam()
				return This.SplitAtPositions(pSubStrOrPos[2])

			but oParam.IsBeforeNamedParam()
				return This.SplitBeforeCS(pSubStrOrPos[2], pCaseSensitive)

			but oParam.IsAfterNamedParam()
				return This.SplitAfterCS(pSubStrOrPos[2], pCaseSensitive)

			but oParam.IsAroundNamedParam()
				return This.SplitAroundCS(pSubStrOrPos[2], pCaseSensitive)

			ok
		ok

		return This.SplitAtCS(pSubStrOrPos, pCaseSensitive)

	def SplittedCS(pSubStrOrPos, pCaseSensitive)
		return This.SplitCS(pSubStrOrPos, pCaseSensitive)

	def Split(pSubStrOrPos)
		return This.SplitCS(pSubStrOrPos, 1)

	def Splitted(pSubStrOrPos)
		return This.Split(pSubStrOrPos)

	  #================================#
	 #     SPLIT AT -- DISPATCHER     #
	#================================#

	def SplitAtCS(pSubStrOrPos, pCaseSensitive)
		if This.IsEmpty()
			return []
		ok

		if isString(pSubStrOrPos)
			return This.SplitAtSubStringCS(pSubStrOrPos, pCaseSensitive)

		but isNumber(pSubStrOrPos)
			return This.SplitAtPosition(pSubStrOrPos)

		but isList(pSubStrOrPos) and IsListOfNumbers(pSubStrOrPos)
			return This.SplitAtPositions(pSubStrOrPos)

		but isList(pSubStrOrPos) and IsListOfStrings(pSubStrOrPos)
			return This.SplitAtSubStringsCS(pSubStrOrPos, pCaseSensitive)

		else
			StzRaise("Incorrect param type! pSubStrOrPos must be position(s) or string(s).")
		ok

	def SplitAt(pSubStrOrPos)
		return This.SplitAtCS(pSubStrOrPos, 1)

	  #=================================#
	 #     SPLIT AT SUBSTRING          #
	#=================================#

	def SplitAtSubStringCS(pcSubStr, pCaseSensitive)
		if CheckingParams()

			if This.IsEmpty()
				return []
			ok

			if isList(pcSubStr) and IsListOfStrings(pcSubStr)
				return This.SplitAtSubStringsCS(pcSubStr, pCaseSensitive)
			ok

			if NOT isString(pcSubStr)
				StzRaise("Incorrect param type! pcSubStr must be a string.")
			ok

		ok

		if isList(pCaseSensitive) and IsCaseSensitiveNamedParamList(pCaseSensitive)
			pCaseSensitive = pCaseSensitive[2]
		ok

		return @SplitCS(This.Content(), pcSubStr, pCaseSensitive)

	def SplitAtSubString(pcSubStr)
		return This.SplitAtSubStringCS(pcSubStr, 1)

	  #===================================#
	 #     SPLIT AT MULTIPLE SUBSTRINGS  #
	#===================================#

	def SplitAtSubStringsCS(pacSubStrings, pCaseSensitive)
		if NOT isList(pacSubStrings)
			StzRaise("Incorrect param type! pacSubStrings must be a list.")
		ok

		cResult = This.Content()
		cSep = "<<<SEP>>>"

		nLen = len(pacSubStrings)
		for i = 1 to nLen
			cResult = @ReplaceCS(cResult, pacSubStrings[i], cSep, pCaseSensitive)
		next

		return @SplitCS(cResult, cSep, 1)

	def SplitAtSubStrings(pacSubStrings)
		return This.SplitAtSubStringsCS(pacSubStrings, 1)

	  #===============================#
	 #     SPLIT AT POSITION         #
	#===============================#

	def SplitAtPosition(n)

		if This.IsEmpty()
			return []
		ok

		if NOT isNumber(n)
			StzRaise("Incorrect param type! n must be a number.")
		ok

		if NOT ( n >= 1 and n <= This.NumberOfChars() )
			return [ This.Content() ]
		ok

		aSections = StzSplitterQ( This.NumberOfChars() ).SplitAtPosition(n)
		acResult = This.Sections(aSections)

		return acResult

	  #=================================#
	 #     SPLIT AT POSITIONS          #
	#=================================#

	def SplitAtPositions(anPos)

		if This.IsEmpty()
			return []
		ok

		if NOT ( isList(anPos) and IsListOfNumbers(anPos) )
			StzRaise("Incorrect param type! anPos must be a list of numbers.")
		ok

		aSections = StzSplitterQ( This.NumberOfChars() ).SplitAtPositions(anPos)
		acResult = This.Sections(aSections)

		return acResult

	  #===============================#
	 #     SPLIT BEFORE              #
	#===============================#

	def SplitBeforeCS(pSubStrOrPos, pCaseSensitive)

		if isNumber(pSubStrOrPos)
			return This.SplitBeforePosition(pSubStrOrPos)
		ok

		if isString(pSubStrOrPos)
			return This.SplitBeforeSubStringCS(pSubStrOrPos, pCaseSensitive)
		ok

		StzRaise("Incorrect param type!")

	def SplitBefore(pSubStrOrPos)
		return This.SplitBeforeCS(pSubStrOrPos, 1)

	def SplitBeforePosition(n)
		if This.IsEmpty()
			return []
		ok

		if n <= 1 or n > This.NumberOfChars()
			return [ This.Content() ]
		ok

		cPart1 = substr(This.Content(), 1, n - 1)
		cPart2 = substr(This.Content(), n)

		return [ cPart1, cPart2 ]

	def SplitBeforeSubStringCS(pcSubStr, pCaseSensitive)
		anPos = StzStringFinderQ(This.Content()).FindCS(pcSubStr, pCaseSensitive)
		if len(anPos) = 0
			return [ This.Content() ]
		ok
		return This.SplitBeforePositions(anPos)

	def SplitBeforeSubString(pcSubStr)
		return This.SplitBeforeSubStringCS(pcSubStr, 1)

	def SplitBeforePositions(anPos)
		if This.IsEmpty()
			return []
		ok

		aSections = StzSplitterQ( This.NumberOfChars() ).SplitBeforePositions(anPos)
		acResult = This.Sections(aSections)
		return acResult

	  #==============================#
	 #     SPLIT AFTER              #
	#==============================#

	def SplitAfterCS(pSubStrOrPos, pCaseSensitive)

		if isNumber(pSubStrOrPos)
			return This.SplitAfterPosition(pSubStrOrPos)
		ok

		if isString(pSubStrOrPos)
			return This.SplitAfterSubStringCS(pSubStrOrPos, pCaseSensitive)
		ok

		StzRaise("Incorrect param type!")

	def SplitAfter(pSubStrOrPos)
		return This.SplitAfterCS(pSubStrOrPos, 1)

	def SplitAfterPosition(n)
		if This.IsEmpty()
			return []
		ok

		if n < 1 or n >= This.NumberOfChars()
			return [ This.Content() ]
		ok

		cPart1 = substr(This.Content(), 1, n)
		cPart2 = substr(This.Content(), n + 1)

		return [ cPart1, cPart2 ]

	def SplitAfterSubStringCS(pcSubStr, pCaseSensitive)
		anPos = StzStringFinderQ(This.Content()).FindCS(pcSubStr, pCaseSensitive)
		if len(anPos) = 0
			return [ This.Content() ]
		ok

		nLenSub = Q(pcSubStr).NumberOfChars()
		anAfterPos = []
		for nPos in anPos
			anAfterPos + (nPos + nLenSub - 1)
		next

		return This.SplitAfterPositions(anAfterPos)

	def SplitAfterSubString(pcSubStr)
		return This.SplitAfterSubStringCS(pcSubStr, 1)

	def SplitAfterPositions(anPos)
		if This.IsEmpty()
			return []
		ok

		aSections = StzSplitterQ( This.NumberOfChars() ).SplitAfterPositions(anPos)
		acResult = This.Sections(aSections)
		return acResult

	  #===============================#
	 #     HELPER: SECTIONS          #
	#===============================#

	def Sections(aSections)
		acResult = []
		cContent = This.Content()
		nLen = len(aSections)
		for i = 1 to nLen
			n1 = aSections[i][1]
			n2 = aSections[i][2]
			if n1 >= 1 and n2 >= n1 and n2 <= len(cContent)
				acResult + substr(cContent, n1, n2 - n1 + 1)
			ok
		next
		return acResult
