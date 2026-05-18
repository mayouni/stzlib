#--------------------------------------------------------------#
#        SOFTANZA LIBRARY (V0.9) - STZSTRINGEXTRACTOR          #
#   An accelerative library for Ring applications, and more!   #
#--------------------------------------------------------------#
#                                                              #
#   Description  : String extractor subclass -- extract        #
#                  (remove and return) sections and matches.    #
#                  For aliases, use stzStringExtractorXT.       #
#   Version      : V0.9 (2026)                                #
#   Author       : Mansour Ayouni (kalidianow@gmail.com)       #
#                                                              #
#--------------------------------------------------------------#


  /////////////////
 ///   CLASS   ///
/////////////////

class stzStringExtractor

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
		cResult = @oString.Section(n1, n2)
		@oString.RemoveSection(n1, n2)
		return cResult

	  #======================================================#
	 #   EXTRACTING A RANGE                                 #
	#======================================================#

	def ExtractRange(pnStart, pnRange)
		return This.ExtractSection(pnStart, pnStart + pnRange - 1)

	  #======================================================#
	 #   EXTRACTING ALL OCCURRENCES OF A SUBSTRING          #
	#======================================================#

	def ExtractCS(pcSubStr, pCaseSensitive)
		cResult = @oString.Content()
		_oReplacer_ = new stzStringReplacer(@oString)
		_oReplacer_.ReplaceCS(pcSubStr, "", pCaseSensitive)
		return cResult

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

		acResult = []
		nLen = len(paSubStr)
		for i = 1 to nLen
			acResult + paSubStr[i]
			_oReplacer_ = new stzStringReplacer(@oString)
			_oReplacer_.ReplaceCS(paSubStr[i], "", pCaseSensitive)
		next
		return acResult

	def ExtractMany(paSubStr)
		return This.ExtractManyCS(paSubStr, 1)

	  #======================================================#
	 #   EXTRACTING ALL CONTENT                             #
	#======================================================#

	def ExtractAll()
		cResult = @oString.Content()
		@oString.Update("")
		return cResult

	  #======================================================#
	 #   EXTRACTING CHAR AT POSITION                        #
	#======================================================#

	def ExtractAt(n)
		return This.ExtractSection(n, n)

		def ExtractCharAt(n)
			return This.ExtractAt(n)

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

	def ExtractNthOccurrenceCS(n, pcSubStr, pCaseSensitive)
		_oFinder_ = new stzStringFinder(@oString)
		nPos = _oFinder_.FindNthCS(n, pcSubStr, pCaseSensitive)
		if nPos = 0
			return ""
		ok
		nLen = len(pcSubStr)
		return This.ExtractSection(nPos, nPos + nLen - 1)

	def ExtractNthOccurrence(n, pcSubStr)
		return This.ExtractNthOccurrenceCS(n, pcSubStr, 1)

	  #======================================================#
	 #   EXTRACTING FIRST / LAST OCCURRENCE                 #
	#======================================================#

	def ExtractFirstCS(pcSubStr, pCaseSensitive)
		_oFinder_ = new stzStringFinder(@oString)
		n = _oFinder_.FindFirstCS(pcSubStr, pCaseSensitive)
		if n = 0
			return ""
		ok
		nLen = len(pcSubStr)
		return This.ExtractSection(n, n + nLen - 1)

	def ExtractFirst(pcSubStr)
		return This.ExtractFirstCS(pcSubStr, 1)

	def ExtractLastCS(pcSubStr, pCaseSensitive)
		_oFinder_ = new stzStringFinder(@oString)
		n = _oFinder_.FindLastCS(pcSubStr, pCaseSensitive)
		if n = 0
			return ""
		ok
		nLen = len(pcSubStr)
		return This.ExtractSection(n, n + nLen - 1)

	def ExtractLast(pcSubStr)
		return This.ExtractLastCS(pcSubStr, 1)

	  #======================================================#
	 #   EXTRACTING CHARS WITH CONDITION                    #
	#======================================================#

	def ExtractCharsWCS(pcCondition, pCaseSensitive)
		# TODO: requires monolith method extraction
		# anPos = This.FindCharsWCS(pcCondition, pCaseSensitive)
		anPos = @oString.FindCharsWCS(pcCondition, pCaseSensitive)
		acResult = []
		for i = len(anPos) to 1 step -1
			acResult + This.ExtractAt(anPos[i])
		next
		return ListReversed(acResult)

	def ExtractCharsW(pcCondition)
		return This.ExtractCharsWCS(pcCondition, 1)
