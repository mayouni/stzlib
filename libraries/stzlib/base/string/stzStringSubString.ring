#--------------------------------------------------------------#
#        SOFTANZA LIBRARY (V0.9) - STZSTRINGSUBSTRING          #
#   An accelerative library for Ring applications, and more!   #
#--------------------------------------------------------------#
#                                                              #
#   Description  : Substring-in-parent -- tracks a substring   #
#                  within a parent string for positional ops.   #
#                  Delegates to stzString (engine-backed).     #
#   Version      : V0.9 (2026)                                #
#   Author       : Mansour Ayouni (kalidianow@gmail.com)       #
#                                                              #
#--------------------------------------------------------------#


  /////////////////////
 ///   FUNCTIONS   ///
/////////////////////

func StzStringSubStringQ(pcSubStr, pcStr)
	return new stzStringSubString(pcSubStr, pcStr)

func StzStringSubStringCSQ(pcSubStr, pcStr, pCaseSensitive)
	return new stzStringSubStringCS(pcSubStr, pcStr, pCaseSensitive)


  /////////////////
 ///   CLASS   ///
/////////////////

class stzStringSubString from stzStringSubStringCS

	def init(pcSubStr, pcStr)
		super.init(pcSubStr, pcStr, 1)

class stzStringSubStringCS

	@cSubStr
	@cStr
	@bCaseSensitive

	def init(pcSubStr, pcStr, pCaseSensitive)
		if isList(pcStr) and ring_len(pcStr) = 2 and isString(pcStr[1])
			cPN = StzCaseFold(pcStr[1])
			if cPN = "in" or cPN = "instring"
				pcStr = pcStr[2]
			ok
		ok

		if NOT (isString(pcSubStr) and isString(pcStr))
			StzRaise("Can't create stzStringSubStringCS! Both parameters must be strings.")
		ok

		@cSubStr = pcSubStr
		@cStr = pcStr
		@bCaseSensitive = @CaseSensitive(pCaseSensitive)

	  #===============================#
	 #     CONTENT ACCESS            #
	#===============================#

	def SubString()
		return @cSubStr

		def Content()
			return @cSubStr

	def String()
		return @cStr

	def CaseSensitive()
		return @bCaseSensitive

	def NumberOfChars()
		oSub = new stzString(@cSubStr)
		return oSub.NumberOfChars()

	  #===============================#
	 #     FINDING                   #
	#===============================#

	def NumberOfOccurrence()
		oStr = new stzString(@cStr)
		oFinder = new stzStringFinder(oStr)
		return oFinder.NumberOfOccurrenceCS(@cSubStr, @bCaseSensitive)

	def Positions()
		oStr = new stzString(@cStr)
		oFinder = new stzStringFinder(oStr)
		return oFinder.FindAllCS(@cSubStr, @bCaseSensitive)

		def Occurrences()
			return This.Positions()

	def NthPosition(n)
		oStr = new stzString(@cStr)
		oFinder = new stzStringFinder(oStr)
		return oFinder.FindNthCS(n, @cSubStr, @bCaseSensitive)

	def FirstPosition()
		return This.NthPosition(1)

	def LastPosition()
		return This.NthPosition(This.NumberOfOccurrence())

	def Sections()
		oStr = new stzString(@cStr)
		oFinder = new stzStringFinder(oStr)
		return oFinder.FindAsSectionsCS(@cSubStr, @bCaseSensitive)

	  #===============================#
	 #     REPLACE / REMOVE          #
	#===============================#

	def ReplacedWith(pcNewSubStr)
		oStr = new stzString(@cStr)
		oReplacer = new stzStringReplacer(oStr)
		oReplacer.ReplaceCS(@cSubStr, pcNewSubStr, @bCaseSensitive)
		return oReplacer.Content()

		def Replaced(pcNewSubStr)
			return This.ReplacedWith(pcNewSubStr)

	def Removed()
		return This.ReplacedWith("")

	  #===============================#
	 #     CASE                      #
	#===============================#

	def IsLowercased()
		oSub = new stzString(@cSubStr)
		return StzEngineStringIsLowercase(oSub.Engine())

	def IsUppercased()
		oSub = new stzString(@cSubStr)
		return StzEngineStringIsUppercase(oSub.Engine())

	def Uppercased()
		oStr = new stzString(@cStr)
		oReplacer = new stzStringReplacer(oStr)
		oReplacer.ReplaceCS(@cSubStr, StzUpper(@cSubStr), @bCaseSensitive)
		return oReplacer.Content()

	def Lowercased()
		oStr = new stzString(@cStr)
		oReplacer = new stzStringReplacer(oStr)
		oReplacer.ReplaceCS(@cSubStr, StzLower(@cSubStr), @bCaseSensitive)
		return oReplacer.Content()

	  #===============================#
	 #     POSITION CHECKS           #
	#===============================#

	def IsBefore(pcOtherSubStr)
		nMyPos = This.FirstPosition()
		oStr = new stzString(@cStr)
		oFinder = new stzStringFinder(oStr)
		nOtherPos = oFinder.FindFirstCS(pcOtherSubStr, @bCaseSensitive)
		if nMyPos = 0 or nOtherPos = 0
			return 0
		ok
		return nMyPos < nOtherPos

		def ComesBefore(pcOtherSubStr)
			return This.IsBefore(pcOtherSubStr)

	def IsAfter(pcOtherSubStr)
		nMyPos = This.FirstPosition()
		oStr = new stzString(@cStr)
		oFinder = new stzStringFinder(oStr)
		nOtherPos = oFinder.FindFirstCS(pcOtherSubStr, @bCaseSensitive)
		if nMyPos = 0 or nOtherPos = 0
			return 0
		ok
		return nMyPos > nOtherPos

		def ComesAfter(pcOtherSubStr)
			return This.IsAfter(pcOtherSubStr)

	def IsBetween(pcBound1, pcBound2)
		oStr = new stzString(@cStr)
		oFinder = new stzStringFinder(oStr)
		nPos1 = oFinder.FindFirstCS(pcBound1, @bCaseSensitive)
		nPos2 = oFinder.FindFirstCS(pcBound2, @bCaseSensitive)
		nMyPos = This.FirstPosition()
		if nPos1 = 0 or nPos2 = 0 or nMyPos = 0
			return 0
		ok
		if nPos1 > nPos2
			nTemp = nPos1
			nPos1 = nPos2
			nPos2 = nTemp
		ok
		return nMyPos > nPos1 and nMyPos < nPos2

		def ComesBetween(pcBound1, pcBound2)
			return This.IsBetween(pcBound1, pcBound2)

	  #===============================#
	 #     BOUNDED BY                #
	#===============================#

	def IsBoundedBy(pacBounds)
		if NOT (isList(pacBounds) and ring_len(pacBounds) = 2)
			return 0
		ok
		oStr = new stzString(@cStr)
		oFinder = new stzStringFinder(oStr)
		aSections = oFinder.FindAnyBoundedByAsSectionsCS(pacBounds, @bCaseSensitive)
		nLen = ring_len(aSections)
		for i = 1 to nLen
			cFound = oStr.Section(aSections[i][1], aSections[i][2])
			if cFound = @cSubStr
				return 1
			ok
		next
		return 0
