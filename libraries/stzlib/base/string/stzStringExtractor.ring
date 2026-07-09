#--------------------------------------------------------------#
#        SOFTANZA LIBRARY (V0.9) - STZSTRINGEXTRACTOR          #
#   An accelerative library for Ring applications, and more!   #
#--------------------------------------------------------------#
#                                                              #
#   Description  : String extractor subclass -- extract        #
#                  (remove and return) sections and matches.   #
#                  For aliases, use stzStringExtractorXT.      #
#   Version      : V0.9 (2026)                                 #
#   Author       : Mansour Ayouni (kalidianow@gmail.com)       #
#                                                              #
#--------------------------------------------------------------#


class stzStringExtractor from stzObject

	@oString

	def init(pStrOrStzStrObj)
		if isString(pStrOrStzStrObj)
			@oString = new stzString(pStrOrStzStrObj)
		but isObject(pStrOrStzStrObj)
			@oString = pStrOrStzStrObj
		else
			StzRaise("Can't create stzStringExtractor! Parameter must be a string or stzString object.")
		ok

	def Content()
		return @oString.Content()

	def NumberOfChars()
		return @oString.NumberOfChars()

	def IsEmpty()
		return @oString.IsEmpty()

	  #======================================================#
	 #   EXTRACTING A SECTION                               #
	#======================================================#

	def ExtractSection(n1, n2)
		_cResult_ = @oString.Section(n1, n2)
		@oString.RemoveSection(n1, n2)
		return _cResult_

	  #======================================================#
	 #   EXTRACTING A RANGE                                 #
	#======================================================#

	def ExtractRange(pnStart, pnRange)
		return This.ExtractSection(pnStart, pnStart + pnRange - 1)

	  #======================================================#
	 #   EXTRACTING ALL OCCURRENCES OF A SUBSTRING          #
	#======================================================#

	def ExtractCS(pcSubStr, pCaseSensitive)
		_cResult_ = @oString.Content()
		_oReplacer_ = new stzStringReplacer(@oString)
		_oReplacer_.ReplaceCS(pcSubStr, "", pCaseSensitive)
		return _cResult_

		def ExtractCSQ(pcSubStr, pCaseSensitive)
			This.ExtractCS(pcSubStr, pCaseSensitive)
			return This

	def Extract(pcSubStr)
		return This.ExtractCS(pcSubStr, 1)

		def ExtractQ(pcSubStr)
			This.Extract(pcSubStr)
			return This

	  #======================================================#
	 #   EXTRACTING MANY SUBSTRINGS                         #
	#======================================================#

	def ExtractManyCS(paSubStr, pCaseSensitive)
		if CheckParams()
			if NOT (isList(paSubStr) and @IsListOfStrings(paSubStr))
				StzRaise("Incorrect param type! paSubStr must be a list of strings.")
			ok
		ok

		_acResult_ = []
		_nLen_ = len(paSubStr)
		for i = 1 to _nLen_
			_acResult_ + paSubStr[i]
			_oReplacer_ = new stzStringReplacer(@oString)
			_oReplacer_.ReplaceCS(paSubStr[i], "", pCaseSensitive)
		next
		return _acResult_

	def ExtractMany(paSubStr)
		return This.ExtractManyCS(paSubStr, 1)

	  #======================================================#
	 #   EXTRACTING ALL CONTENT                             #
	#======================================================#

	def ExtractAll()
		_cResult_ = @oString.Content()
		@oString.Update("")
		return _cResult_

	  #======================================================#
	 #   EXTRACTING CHAR AT POSITION                        #
	#======================================================#

	def ExtractAt(_n_)
		return This.ExtractSection(_n_, _n_)

		def ExtractCharAt(_n_)
			return This.ExtractAt(_n_)

	  #======================================================#
	 #   EXTRACTING FIRST / LAST CHAR                       #
	#======================================================#

	def ExtractFirstChar()
		return This.ExtractAt(1)

	def ExtractLastChar()
		return This.ExtractAt(@oString.NumberOfChars())

	  #======================================================#
	 #   EXTRACTING NTH OCCURRENCE                          #
	#======================================================#

	def ExtractNthOccurrenceCS(_n_, pcSubStr, pCaseSensitive)
		_oFinder_ = new stzStringFinder(@oString)
		_nPos_ = _oFinder_.FindNthCS(_n_, pcSubStr, pCaseSensitive)
		if _nPos_ = 0
			return ""
		ok
		_nLen_ = StzLen(pcSubStr)
		return This.ExtractSection(_nPos_, _nPos_ + _nLen_ - 1)

	def ExtractNthOccurrence(_n_, pcSubStr)
		return This.ExtractNthOccurrenceCS(_n_, pcSubStr, 1)

	  #======================================================#
	 #   EXTRACTING FIRST / LAST OCCURRENCE                 #
	#======================================================#

	def ExtractFirstCS(pcSubStr, pCaseSensitive)
		_oFinder_ = new stzStringFinder(@oString)
		_n_ = _oFinder_.FindFirstCS(pcSubStr, pCaseSensitive)
		if _n_ = 0
			return ""
		ok
		_nLen_ = StzLen(pcSubStr)
		return This.ExtractSection(_n_, _n_ + _nLen_ - 1)

	def ExtractFirst(pcSubStr)
		return This.ExtractFirstCS(pcSubStr, 1)

	def ExtractLastCS(pcSubStr, pCaseSensitive)
		_oFinder_ = new stzStringFinder(@oString)
		_n_ = _oFinder_.FindLastCS(pcSubStr, pCaseSensitive)
		if _n_ = 0
			return ""
		ok
		_nLen_ = StzLen(pcSubStr)
		return This.ExtractSection(_n_, _n_ + _nLen_ - 1)

	def ExtractLast(pcSubStr)
		return This.ExtractLastCS(pcSubStr, 1)

	  #======================================================#
	 #   EXTRACTING CHARS WITH CONDITION                    #
	#======================================================#

	def ExtractCharsWCS(pcCondition, pCaseSensitive)
		_oFinder_ = new stzStringFinder(@oString)
		_anPos_ = _oFinder_.FindCharsWCS(pcCondition, pCaseSensitive)
		_acResult_ = []
		for i = len(_anPos_) to 1 step -1
			_acResult_ + This.ExtractAt(_anPos_[i])
		next
		return ListReversed(_acResult_)

	def ExtractCharsW(pcCondition)
		return This.ExtractCharsWCS(pcCondition, 1)
