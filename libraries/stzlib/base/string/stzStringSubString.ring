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

class stzStringSubStringCS from stzObject

	@cSubStr
	@cStr
	@bCaseSensitive

	def init(pcSubStr, pcStr, pCaseSensitive)
		if isList(pcStr) and len(pcStr) = 2 and isString(pcStr[1])
			_cPN_ = StzCaseFold(pcStr[1])
			if _cPN_ = "in" or _cPN_ = "instring"
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
		_oSub_ = new stzString(@cSubStr)
		return _oSub_.NumberOfChars()

	  #===============================#
	 #     FINDING                   #
	#===============================#

	def NumberOfOccurrence()
		_oStr_ = new stzString(@cStr)
		_oFinder_ = new stzStringFinder(_oStr_)
		return _oFinder_.NumberOfOccurrenceCS(@cSubStr, @bCaseSensitive)

	def Positions()
		_oStr_ = new stzString(@cStr)
		_oFinder_ = new stzStringFinder(_oStr_)
		return _oFinder_.FindAllCS(@cSubStr, @bCaseSensitive)

		def Occurrences()
			return This.Positions()

	def NthPosition(n)
		_oStr_ = new stzString(@cStr)
		_oFinder_ = new stzStringFinder(_oStr_)
		return _oFinder_.FindNthCS(n, @cSubStr, @bCaseSensitive)

	def FirstPosition()
		return This.NthPosition(1)

	def LastPosition()
		return This.NthPosition(This.NumberOfOccurrence())

	def Sections()
		_oStr_ = new stzString(@cStr)
		_oFinder_ = new stzStringFinder(_oStr_)
		return _oFinder_.FindAsSectionsCS(@cSubStr, @bCaseSensitive)

	  #===============================#
	 #     REPLACE / REMOVE          #
	#===============================#

	def ReplacedWith(pcNewSubStr)
		_oStr_ = new stzString(@cStr)
		_oReplacer_ = new stzStringReplacer(_oStr_)
		_oReplacer_.ReplaceCS(@cSubStr, pcNewSubStr, @bCaseSensitive)
		return _oReplacer_.Content()

		def Replaced(pcNewSubStr)
			return This.ReplacedWith(pcNewSubStr)

	def Removed()
		return This.ReplacedWith("")

	  #===============================#
	 #     CASE                      #
	#===============================#

	def IsLowercased()
		_oSub_ = new stzString(@cSubStr)
		return StzEngineStringIsLowercase(_oSub_.Engine())

	def IsUppercased()
		_oSub_ = new stzString(@cSubStr)
		return StzEngineStringIsUppercase(_oSub_.Engine())

	def Uppercased()
		_oStr_ = new stzString(@cStr)
		_oReplacer_ = new stzStringReplacer(_oStr_)
		_oReplacer_.ReplaceCS(@cSubStr, StzUpper(@cSubStr), @bCaseSensitive)
		return _oReplacer_.Content()

	def Lowercased()
		_oStr_ = new stzString(@cStr)
		_oReplacer_ = new stzStringReplacer(_oStr_)
		_oReplacer_.ReplaceCS(@cSubStr, StzLower(@cSubStr), @bCaseSensitive)
		return _oReplacer_.Content()

	  #===============================#
	 #     POSITION CHECKS           #
	#===============================#

	def IsBefore(pcOtherSubStr)
		_nMyPos_ = This.FirstPosition()
		_oStr_ = new stzString(@cStr)
		_oFinder_ = new stzStringFinder(_oStr_)
		_nOtherPos_ = _oFinder_.FindFirstCS(pcOtherSubStr, @bCaseSensitive)
		if _nMyPos_ = 0 or _nOtherPos_ = 0
			return 0
		ok
		return _nMyPos_ < _nOtherPos_

		def ComesBefore(pcOtherSubStr)
			return This.IsBefore(pcOtherSubStr)

	def IsAfter(pcOtherSubStr)
		_nMyPos_ = This.FirstPosition()
		_oStr_ = new stzString(@cStr)
		_oFinder_ = new stzStringFinder(_oStr_)
		_nOtherPos_ = _oFinder_.FindFirstCS(pcOtherSubStr, @bCaseSensitive)
		if _nMyPos_ = 0 or _nOtherPos_ = 0
			return 0
		ok
		return _nMyPos_ > _nOtherPos_

		def ComesAfter(pcOtherSubStr)
			return This.IsAfter(pcOtherSubStr)

	def IsBetween(pcBound1, pcBound2)
		_oStr_ = new stzString(@cStr)
		_oFinder_ = new stzStringFinder(_oStr_)
		_nPos1_ = _oFinder_.FindFirstCS(pcBound1, @bCaseSensitive)
		_nPos2_ = _oFinder_.FindFirstCS(pcBound2, @bCaseSensitive)
		_nMyPos_ = This.FirstPosition()
		if _nPos1_ = 0 or _nPos2_ = 0 or _nMyPos_ = 0
			return 0
		ok
		if _nPos1_ > _nPos2_
			_nTemp_ = _nPos1_
			_nPos1_ = _nPos2_
			_nPos2_ = _nTemp_
		ok
		return _nMyPos_ > _nPos1_ and _nMyPos_ < _nPos2_

		def ComesBetween(pcBound1, pcBound2)
			return This.IsBetween(pcBound1, pcBound2)

	  #===============================#
	 #     BOUNDED BY                #
	#===============================#

	def IsBoundedBy(pacBounds)
		if NOT (isList(pacBounds) and len(pacBounds) = 2)
			return 0
		ok
		_oStr_ = new stzString(@cStr)
		_oFinder_ = new stzStringFinder(_oStr_)
		_aSections_ = _oFinder_.FindAnyBoundedByAsSectionsCS(pacBounds, @bCaseSensitive)
		_nLen_ = len(_aSections_)
		for i = 1 to _nLen_
			_cFound_ = _oStr_.Section(_aSections_[i][1], _aSections_[i][2])
			if _cFound_ = @cSubStr
				return 1
			ok
		next
		return 0
