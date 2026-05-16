#--------------------------------------------------------------#
#          SOFTANZA LIBRARY (V0.9) - STZSTRINGFINDER           #
#   An accelerative library for Ring applications, and more!   #
#--------------------------------------------------------------#
#                                                              #
#   Description  : String finder subclass -- finding,          #
#                  containing, counting, and positioning        #
#                  operations on strings.                       #
#                  Canonical methods only. For full Softanza    #
#                  fluency (aliases), use stzStringFinderXT.    #
#   Version      : V0.9 (2026)                                 #
#   Author       : Mansour Ayouni (kalidianow@gmail.com)       #
#                                                              #
#--------------------------------------------------------------#


  /////////////////
 ///   CLASS   ///
/////////////////

class stzStringFinder from stzString

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

		_nResult_ = This._FindSubStr(pcSubStr, 1, _bCase_)
		if _nResult_ > 0
			return TRUE
		else
			return FALSE
		ok

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

		if NOT This.ContainsCS(pcSubStr, pCaseSensitive)
			return []
		ok

		_bCase_ = @CaseSensitive(pCaseSensitive)

		nLenString = len(This.Content())
		nLenSubStr = len(pcSubStr)

		if nLenString < nLenSubStr
			return []
		ok

		anResult = []

		bContinue = 1
		_nPos_ = 1

		while bContinue

			_nPos_ = This._FindSubStr(pcSubStr, _nPos_, pCaseSensitive)

			if _nPos_ = 0
				bContinue = 0
			else
				anResult + _nPos_
				_nPos_ = _nPos_ + 1
			ok
		end

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

			nResult = This._FindSubStr(pcSubStr, nPos, pCaseSensitive)

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
		nResult = This._FindSubStr(pcSubStr, 1, _bCase_)

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
			nResult = StzEngineStringLastIndexOf(@pEngine, pcSubStr)
			if nResult >= 0
				return nResult + 1
			else
				return 0
			ok
		ok

		# Case-insensitive: use Engine CI function
		nResult = StzEngineStringLastIndexOfCI(@pEngine, pcSubStr)
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
			return StzEngineStringCountOf(@pEngine, pcSubStr)
		ok
		# Case-insensitive: use Engine CI function
		return StzEngineStringCountOfCI(@pEngine, pcSubStr)

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
			return StzEngineStringStartsWith(@pEngine, pcSubStr)
		ok

		# Case-insensitive: use Engine CI function
		return StzEngineStringStartsWithCI(@pEngine, pcSubStr)

	def StartsWith(pcSubStr)
		return This.StartsWithCS(pcSubStr, 1)

	def EndsWithCS(pcSubStr, pCaseSensitive)
		if pcSubStr = ""
			return 0
		ok

		_bCase_ = @CaseSensitive(pCaseSensitive)
		if _bCase_
			return StzEngineStringEndsWith(@pEngine, pcSubStr)
		ok

		# Case-insensitive: use Engine CI function
		return StzEngineStringEndsWithCI(@pEngine, pcSubStr)

	def EndsWith(pcSubStr)
		return This.EndsWithCS(pcSubStr, 1)

