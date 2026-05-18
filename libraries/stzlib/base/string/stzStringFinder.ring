#--------------------------------------------------------------#
#          SOFTANZA LIBRARY (V0.9) - STZSTRINGFINDER           #
#   An accelerative library for Ring applications, and more!   #
#--------------------------------------------------------------#
#                                                              #
#   Description  : String finder -- finding, containing,       #
#                  counting, and positioning operations.        #
#                  Wraps stzString via composition.             #
#                  For aliases, use stzStringFinderXT.          #
#   Version      : V0.9 (2026)                                 #
#   Author       : Mansour Ayouni (kalidianow@gmail.com)       #
#                                                              #
#--------------------------------------------------------------#


  /////////////////
 ///   CLASS   ///
/////////////////

class stzStringFinder

	@oString

	  #===================#
	 #   INITIALIZATION  #
	#===================#

	def init(pStrOrStzStrObj)
		if isString(pStrOrStzStrObj)
			@oString = new stzString(pStrOrStzStrObj)
		but isObject(pStrOrStzStrObj)
			@oString = pStrOrStzStrObj
		else
			StzRaise("Can't create stzStringFinder! Parameter must be a string or stzString object.")
		ok

	  #===============================#
	 #     CONTENT ACCESS            #
	#===============================#

	def Content()
		return @oString.Content()

	def NumberOfChars()
		return @oString.NumberOfChars()

	def IsEmpty()
		return @oString.IsEmpty()

	  #===============================#
	 #     CONTAINS                  #
	#===============================#

	def ContainsCS(pcSubStr, pCaseSensitive)

		if isList(pcSubStr)
			return This.ContainsTheseCS(pcSubStr, pCaseSensitive)
		ok

		if NOT isString(pcSubStr)
			stzRaise("Incorrect param type! pcSubStr must be a string.")
		ok

		if pcSubStr = ""
			return 0
		ok

		_bCase_ = @CaseSensitive(pCaseSensitive)

		if _bCase_
			return StzEngineStringContains(@oString.Engine(), pcSubStr)
		ok
		return StzEngineStringContainsCI(@oString.Engine(), pcSubStr)

	def Contains(pcSubStr)
		return This.ContainsCS(pcSubStr, 1)

	  #===============================#
	 #     CONTAINS THESE            #
	#===============================#

	def ContainsTheseCS(pacSubStrings, pCaseSensitive)

		if NOT isList(pacSubStrings)
			StzRaise("Incorrect param type! pacSubStrings must be a list.")
		ok

		nLen = len(pacSubStrings)
		for i = 1 to nLen
			if NOT This.ContainsCS(pacSubStrings[i], pCaseSensitive)
				return FALSE
			ok
		next
		return TRUE

	def ContainsThese(pacSubStrings)
		return This.ContainsTheseCS(pacSubStrings, 1)

	  #===============================#
	 #     FIND ALL                  #
	#===============================#

	def FindCS(pcSubStr, pCaseSensitive)

		if CheckingParams()

			if isList(pcSubStr) and @IsListOfStrings(pcSubStr)
				return This.FindManyCS(pcSubStr, pCaseSensitive)
			ok

			if isList(pcSubStr) and len(pcSubStr) = 2 and isString(pcSubStr[1])
				cPN = lower(pcSubStr[1])
				if cPN = "of" or cPN = "ofsubstring"
					pcSubStr = pcSubStr[2]
				ok
			ok

			if NOT isString(pcSubStr)
				stzRaise("Incorrect param type! pcSubStr must be a string.")
			ok

		ok

		if pcSubStr = ""
			return []
		ok

		_bCase_ = @CaseSensitive(pCaseSensitive)

		# Bulk find via Engine: one call returns all positions
		if _bCase_
			pResult = StzEngineStringFindAll(@oString.Engine(), pcSubStr)
		else
			pResult = StzEngineStringFindAllCI(@oString.Engine(), pcSubStr)
		ok

		nCount = StzEngineFindResultCount(pResult)
		if nCount = 0
			StzEngineFindResultFree(pResult)
			return []
		ok

		anResult = []
		for i = 0 to nCount - 1
			anResult + (StzEngineFindResultGet(pResult, i) + 1)
		next
		StzEngineFindResultFree(pResult)

		return anResult

	def Find(pcSubStr)
		return This.FindCS(pcSubStr, 1)

	  #===============================#
	 #     FIND NTH                  #
	#===============================#

	def FindNthCS(n, pcSubstr, pCaseSensitive)

		if isList(pcSubStr) and IsOfNamedParamList(pcSubStr)
			pcSubStr = pcSubStr[2]
		ok

		if NOT isString(pcSubStr)
			stzRaise("Incorrect param type! pcSubStr must be a string.")
		ok

		if isList(pCaseSensitive) and IsCaseSensitiveNamedParamList(pCaseSensitive)
			pCaseSensitive = pCaseSensitive[2]
		ok

		if NOT ( isNumber(pCaseSensitive) and (pCaseSensitive = 0 or pCaseSensitive = 1) )
			StzRaise("Incorrect param type! pCaseSensitive must be a boolean (1 or 0).")
		ok

		if NOT This.ContainsCS(pcSubStr, pCaseSensitive)
			return 0
		ok

		if isString(n)
			cNLowercased = lower(n)
			if cNLowercased = :First or cNLowercased = :FirstOccurrence
				n = 1

			but cNLowercased = :Last or cNLowercased = :LastOccurrence
				n = This.NumberOfOccurrenceCS(pcSubStr, pCaseSensitive)

			else
				n = 0
			ok
		ok

		nResult = 0

		nPos = 1
		for i = 1 to n

			nResult = @oString._FindSubStr(pcSubStr, nPos, pCaseSensitive)

			if nResult = 0
				exit
			ok

			nPos = nResult + 1
		next

		return nResult

	def FindNth(n, pcSubstr)
		return This.FindNthCS(n, pcSubstr, 1)

	  #===============================#
	 #     FIND FIRST                #
	#===============================#

	def FindFirstCS(pcSubStr, pCaseSensitive)

		if CheckParams()
			if NOT isString(pcSubStr)
				StzRaise("Incorrect param type! pcSubStr must be a string.")
			ok
		ok

		if pcSubStr = ""
			return 0
		ok

		_bCase_ = @CaseSensitive(pCaseSensitive)
		nResult = @oString._FindSubStr(pcSubStr, 1, _bCase_)

		return nResult

	def FindFirst(pcSubstr)
		return This.FindFirstCS(pcSubstr, 1)

	  #===============================#
	 #     FIND LAST                 #
	#===============================#

	def FindLastCS(pcSubStr, pCaseSensitive)

		if isList(pcSubStr) and IsOfNamedParamList(pcSubStr)
			pcSubStr = pcSubStr[2]
		ok

		_bCase_ = @CaseSensitive(pCaseSensitive)
		if _bCase_
			nResult = StzEngineStringLastIndexOf(@oString.Engine(), pcSubStr)
			if nResult >= 0
				return nResult + 1
			else
				return 0
			ok
		ok

		# Case-insensitive: use Engine CI function
		nResult = StzEngineStringLastIndexOfCI(@oString.Engine(), pcSubStr)
		if nResult >= 0
			return nResult + 1
		else
			return 0
		ok

	def FindLast(pcSubStr)
		return This.FindLastCS(pcSubStr, 1)

	  #===============================#
	 #     NUMBER OF OCCURRENCES     #
	#===============================#

	def NumberOfOccurrenceCS(pcSubStr, pCaseSensitive)
		_bCase_ = @CaseSensitive(pCaseSensitive)
		if _bCase_
			return StzEngineStringCountOf(@oString.Engine(), pcSubStr)
		ok
		# Case-insensitive: use Engine CI function
		return StzEngineStringCountOfCI(@oString.Engine(), pcSubStr)

	def NumberOfOccurrence(pcSubStr)
		return This.NumberOfOccurrenceCS(pcSubStr, 1)

	  #===============================#
	 #     FIND MANY                 #
	#===============================#

	def FindManyCS(pacSubStrings, pCaseSensitive)
		if NOT isList(pacSubStrings)
			StzRaise("Incorrect param type! pacSubStrings must be a list.")
		ok

		aResult = []
		nLen = len(pacSubStrings)
		for i = 1 to nLen
			anPositions = This.FindCS(pacSubStrings[i], pCaseSensitive)
			if len(anPositions) > 0
				aResult + [ pacSubStrings[i], anPositions ]
			ok
		next
		return aResult

	def FindMany(pacSubStrings)
		return This.FindManyCS(pacSubStrings, 1)

	  #===============================#
	 #     STARTS WITH / ENDS WITH   #
	#===============================#

	def StartsWithCS(pcSubStr, pCaseSensitive)
		if pcSubStr = ""
			return 0
		ok

		_bCase_ = @CaseSensitive(pCaseSensitive)
		if _bCase_
			return StzEngineStringStartsWith(@oString.Engine(), pcSubStr)
		ok

		# Case-insensitive: use Engine CI function
		return StzEngineStringStartsWithCI(@oString.Engine(), pcSubStr)

	def StartsWith(pcSubStr)
		return This.StartsWithCS(pcSubStr, 1)

	def EndsWithCS(pcSubStr, pCaseSensitive)
		if pcSubStr = ""
			return 0
		ok

		_bCase_ = @CaseSensitive(pCaseSensitive)
		if _bCase_
			return StzEngineStringEndsWith(@oString.Engine(), pcSubStr)
		ok

		# Case-insensitive: use Engine CI function
		return StzEngineStringEndsWithCI(@oString.Engine(), pcSubStr)

	def EndsWith(pcSubStr)
		return This.EndsWithCS(pcSubStr, 1)
