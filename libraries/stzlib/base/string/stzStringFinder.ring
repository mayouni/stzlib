#--------------------------------------------------------------#
#          SOFTANZA LIBRARY (V0.9) - STZSTRINGFINDER           #
#   An accelerative library for Ring applications, and more!   #
#--------------------------------------------------------------#
#                                                              #
#   Description  : String finder subclass -- finding,          #
#                  containing, counting, and positioning        #
#                  operations on strings.                       #
#   Version      : V0.9 (2026)                                 #
#   Author       : Mansour Ayouni (kalidianow@gmail.com)       #
#                                                              #
#--------------------------------------------------------------#


  /////////////////////
 ///   FUNCTIONS   ///
/////////////////////

func StzStringFinderQ(str)
	return new stzStringFinder(str)


  /////////////////
 ///   CLASS   ///
/////////////////

class stzStringFinder from stzString

	  #===============================#
	 #     CONTAINS -- CORE CHECK    #
	#===============================#

	def ContainsCS(pcSubStr, pCaseSensitive)

		if isList(pcSubStr)
			return This.ContainsTheseSubStringsCS(pcSubStr, pCaseSensitive)
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

		#< @FunctionAlternativeForm

		def ContainsSubStringCS(pcSubStr, pCaseSensitive)
			return This.ContainsCS(pcSubStr, pCaseSensitive)

		def ContainingCS(pcSubStr, pCaseSensitive)
			return This.ContainsCS(pcSubStr, pCaseSensitive)

		#>

		#< @FunctionNegativeForm

		def ContainsNoCS(pcSubStr, pCaseSensitive)
			return NOT This.ContainsCS(pcSubStr, pCaseSensitive)

		def DoesNotContainCS(pcSubStr, pCaseSensitive)
			return NOT This.ContainsCS(pcSubStr, pCaseSensitive)

		#>

	#-- WITHOUT CASESENSITIVITY

	def Contains(pcSubStr)
		return This.ContainsCS(pcSubStr, 1)

		def ContainsSubString(pcSubStr)
			return This.Contains(pcSubStr)

		def Containing(pcSubStr)
			return This.Contains(pcSubStr)

		def ContainsNo(pcSubStr)
			return NOT This.Contains(pcSubStr)

		def DoesNotContain(pcSubStr)
			return NOT This.Contains(pcSubStr)

	  #==========================================#
	 #     CONTAINS THESE -- MULTIPLE CHECK     #
	#==========================================#

	def ContainsTheseSubStringsCS(pacSubStrings, pCaseSensitive)

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

		def ContainsTheseCS(pacSubStrings, pCaseSensitive)
			return This.ContainsTheseSubStringsCS(pacSubStrings, pCaseSensitive)

	def ContainsTheseSubStrings(pacSubStrings)
		return This.ContainsTheseSubStringsCS(pacSubStrings, 1)

		def ContainsThese(pacSubStrings)
			return This.ContainsTheseSubStrings(pacSubStrings)

	  #==========================================#
	 #     FIND ALL -- RETURNS ALL POSITIONS    #
	#==========================================#

	def FindCS(pcSubStr, pCaseSensitive)

		if CheckingParams()

			if isList(pcSubStr) and @IsListOfStrings(pcSubStr)
				return This.FindManyCS(pcSubStr, pCaseSensitive)
			ok

			if isList(pcSubStr) and
				( Q(pcSubStr).IsOfNamedParam() or
				  Q(pcSubStr).IsOfSubStringNamedParam() )

				pcSubStr = pcSubStr[2]
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

		nLenString = This.NumberOfChars()
		nLenSubStr = Q(pcSubStr).NumberOfChars()

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

		#< @FunctionAlternativeForm

		def FindAllCS(pcSubStr, pCaseSensitive)
			return This.FindCS(pcSubStr, pCaseSensitive)

		def FindSubStringCS(pcSubStr, pCaseSensitive)
			return This.FindCS(pcSubStr, pCaseSensitive)

		def OccurrencesCS(pcSubStr, pCaseSensitive)
			return This.FindCS(pcSubStr, pCaseSensitive)

		def PositionsCS(pcSubStr, pCaseSensitive)
			return This.FindCS(pcSubStr, pCaseSensitive)

		def PositionsOfSubStringCS(pcSubStr, pCaseSensitive)
			return This.FindCS(pcSubStr, pCaseSensitive)

		#>

	#-- WITHOUT CASESENSITIVITY

	def Find(pcSubStr)
		return This.FindCS(pcSubStr, 1)

		def FindAll(pcSubStr)
			return This.Find(pcSubStr)

		def FindSubString(pcSubStr)
			return This.Find(pcSubStr)

		def Occurrences(pcSubStr)
			return This.Find(pcSubStr)

		def Positions(pcSubStr)
			return This.Find(pcSubStr)

		def PositionsOfSubString(pcSubStr)
			return This.Find(pcSubStr)

	  #==================================#
	 #     FIND NTH -- NTH POSITION    #
	#==================================#

	def FindNthCS(n, pcSubstr, pCaseSensitive)

		if isList(pcSubStr) and StzListQ(pcSubStr).IsOfNamedParam()
			pcSubStr = pcSubStr[2]
		ok

		if NOT isString(pcSubStr)
			stzRaise("Incorrect param type! pcSubStr must be a string.")
		ok

		if isList(pCaseSensitive) and StzListQ(pCaseSensitive).IsCaseSensitiveNamedParam()
			pCaseSensitive = pCaseSensitive[2]
		ok

		if NOT ( isNumber(pCaseSensitive) and (pCaseSensitive = 0 or pCaseSensitive = 1) )
			StzRaise("Incorrect param type! pCaseSensitive must be a boolean (1 or 0).")
		ok

		if NOT This.ContainsCS(pcSubStr, pCaseSensitive)
			return 0
		ok

		if isString(n)
			cNLowercased = Q(n).Lowercased()
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

		#< @FunctionAlternativeForm

		def FindNthOccurrenceCS(n, pcSubStr, pCaseSensitive)
			return This.FindNthCS(n, pcSubStr, pCaseSensitive)

		def FindNthSubStringCS(n, pcSubStr, pCaseSensitive)
			return This.FindNthCS(n, pcSubStr, pCaseSensitive)

		def NthOccurrenceCS(n, pcSubStr, pCaseSensitive)
			return This.FindNthCS(n, pcSubStr, pCaseSensitive)

		def PositionOfNthCS(n, pcSubStr, pCaseSensitive)
			return This.FindNthCS(n, pcSubStr, pCaseSensitive)

		#>

	#-- WITHOUT CASESENSITIVITY

	def FindNth(n, pcSubstr)
		return This.FindNthCS(n, pcSubstr, 1)

		def FindNthOccurrence(n, pcSubStr)
			return This.FindNth(n, pcSubStr)

		def FindNthSubString(n, pcSubStr)
			return This.FindNth(n, pcSubStr)

		def NthOccurrence(n, pcSubStr)
			return This.FindNth(n, pcSubStr)

		def PositionOfNth(n, pcSubStr)
			return This.FindNth(n, pcSubStr)

	  #================================#
	 #     FIND FIRST -- POSITION     #
	#================================#

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

		#< @FunctionAlternativeForm

		def FindFirstOccurrenceCS(pcSubStr, pCaseSensitive)
			return This.FindFirstCS(pcSubStr, pCaseSensitive)

		def FirstOccurrenceCS(pcSubStr, pCaseSensitive)
			return This.FindFirstCS(pcSubStr, pCaseSensitive)

		def FindFirstSubStringCS(pcSubStr, pCaseSensitive)
			return This.FindFirstCS(pcSubStr, pCaseSensitive)

		def FirstPositionCS(pcSubStr, pCaseSensitive)
			return This.FindFirstCS(pcSubStr, pCaseSensitive)

		def PositionOfFirstCS(pcSubStr, pCaseSensitive)
			return This.FindFirstCS(pcSubStr, pCaseSensitive)

		#>

	#-- WITHOUT CASESENSITIVITY

	def FindFirst(pcSubstr)
		return This.FindFirstCS(pcSubstr, 1)

		def FindFirstOccurrence(pcSubStr)
			return This.FindFirst(pcSubStr)

		def FirstOccurrence(pcSubStr)
			return This.FindFirst(pcSubStr)

		def FindFirstSubString(pcSubStr)
			return This.FindFirst(pcSubStr)

		def FirstPosition(pcSubStr)
			return This.FindFirst(pcSubStr)

		def PositionOfFirst(pcSubStr)
			return This.FindFirst(pcSubStr)

	  #===============================#
	 #     FIND LAST -- POSITION     #
	#===============================#

	def FindLastCS(pcSubStr, pCaseSensitive)

		if isList(pcSubStr) and StzListQ(pcSubStr).IsOfNamedParam()
			pcSubStr = pcSubStr[2]
		ok

		if NOT This.ContainsCS(pcSubstr, pCaseSensitive)
			return 0
		ok

		n = This.NumberOfOccurrenceCS(pcSubstr, pCaseSensitive)
		nResult = This.FindNthCS(n, pcsubStr, pCaseSensitive)
		return nResult

		#< @FunctionAlternativeForm

		def FindLastOccurrenceCS(pcSubstr, pCaseSensitive)
			return This.FindLastCS(pcSubStr, pCaseSensitive)

		def FindLastSubStringCS(pcSubStr, pCaseSensitive)
			return This.FindLastCS(pcSubStr, pCaseSensitive)

		def LastOccurrenceCS(pcSubStr, pCaseSensitive)
			return This.FindLastCS(pcSubStr, pCaseSensitive)

		def PositionOfLastCS(pcSubStr, pCaseSensitive)
			return This.FindLastCS(pcSubStr, pCaseSensitive)

		def LastPositionCS(pcSubStr, pCaseSensitive)
			return This.FindLastCS(pcSubStr, pCaseSensitive)

		#>

	#-- WITHOUT CASESENSITIVITY

	def FindLast(pcSubStr)
		return This.FindLastCS(pcSubStr, 1)

		def FindLastOccurrence(pcSubstr)
			return This.FindLast(pcSubStr)

		def FindLastSubString(pcSubStr)
			return This.FindLast(pcSubStr)

		def LastOccurrence(pcSubStr)
			return This.FindLast(pcSubStr)

		def PositionOfLast(pcSubStr)
			return This.FindLast(pcSubStr)

		def LastPosition(pcSubStr)
			return This.FindLast(pcSubStr)

	  #=====================================#
	 #     NUMBER OF OCCURRENCES           #
	#=====================================#

	def NumberOfOccurrenceCS(pcSubStr, pCaseSensitive)
		nResult = StringCountCS(This.Content(), pcSubStr, pCaseSensitive)
		return nResult

		#< @FunctionAlternativeForm

		def NumberOfOccurrencesCS(pcSubStr, pCaseSensitive)
			return This.NumberOfOccurrenceCS(pcSubStr, pCaseSensitive)

		def NumberOfOccurrencesOfCS(pcSubStr, pCaseSensitive)
			return This.NumberOfOccurrenceCS(pcSubStr, pCaseSensitive)

		def NumberOfOccurrenceOfCS(pcSubStr, pCaseSensitive)
			return This.NumberOfOccurrenceCS(pcSubStr, pCaseSensitive)

		def HowManyCS(pcSubStr, pCaseSensitive)
			return This.NumberOfOccurrenceCS(pcSubStr, pCaseSensitive)

		def NumberOfCS(pcSubStr, pCaseSensitive)
			return This.NumberOfOccurrenceCS(pcSubStr, pCaseSensitive)

		def CountCS(pcSubStr, pCaseSensitive)
			return This.NumberOfOccurrenceCS(pcSubStr, pCaseSensitive)

		def CountOfCS(pcSubStr, pCaseSensitive)
			return This.NumberOfOccurrenceCS(pcSubStr, pCaseSensitive)

		#>

	#-- WITHOUT CASESENSITIVITY

	def NumberOfOccurrence(pcSubStr)
		return This.NumberOfOccurrenceCS(pcSubStr, 1)

		def NumberOfOccurrences(pcSubStr)
			return This.NumberOfOccurrence(pcSubStr)

		def NumberOfOccurrencesOf(pcSubStr)
			return This.NumberOfOccurrence(pcSubStr)

		def HowMany(pcSubStr)
			return This.NumberOfOccurrence(pcSubStr)

		def NumberOf(pcSubStr)
			return This.NumberOfOccurrence(pcSubStr)

		def Count(pcSubStr)
			return This.NumberOfOccurrence(pcSubStr)

		def CountOf(pcSubStr)
			return This.NumberOfOccurrence(pcSubStr)

	  #======================================#
	 #     FIND MANY -- MULTIPLE SEARCH     #
	#======================================#

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

		def FindManySubStringsCS(pacSubStrings, pCaseSensitive)
			return This.FindManyCS(pacSubStrings, pCaseSensitive)

	def FindMany(pacSubStrings)
		return This.FindManyCS(pacSubStrings, 1)

		def FindManySubStrings(pacSubStrings)
			return This.FindMany(pacSubStrings)

	  #============================================#
	 #     STARTS WITH / ENDS WITH               #
	#============================================#

	def StartsWithCS(pcSubStr, pCaseSensitive)
		if pcSubStr = ""
			return 0
		ok

		nResult = This.FindFirstCS(pcSubStr, pCaseSensitive)
		return nResult = 1

		def BeginsWithCS(pcSubStr, pCaseSensitive)
			return This.StartsWithCS(pcSubStr, pCaseSensitive)

	def StartsWith(pcSubStr)
		return This.StartsWithCS(pcSubStr, 1)

		def BeginsWith(pcSubStr)
			return This.StartsWith(pcSubStr)

	def EndsWithCS(pcSubStr, pCaseSensitive)
		if pcSubStr = ""
			return 0
		ok

		nLen = Q(pcSubStr).NumberOfChars()
		nStart = This.NumberOfChars() - nLen + 1

		if nStart < 1
			return 0
		ok

		cEnd = substr(This.Content(), nStart, nLen)

		if pCaseSensitive = 1
			return cEnd = pcSubStr
		else
			return ring_lower(cEnd) = ring_lower(pcSubStr)
		ok

		def FinishesWithCS(pcSubStr, pCaseSensitive)
			return This.EndsWithCS(pcSubStr, pCaseSensitive)

	def EndsWith(pcSubStr)
		return This.EndsWithCS(pcSubStr, 1)

		def FinishesWith(pcSubStr)
			return This.EndsWith(pcSubStr)
