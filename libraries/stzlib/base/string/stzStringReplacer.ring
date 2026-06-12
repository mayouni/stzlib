#--------------------------------------------------------------#
#         SOFTANZA LIBRARY (V0.9) - STZSTRINGREPLACER          #
#   An accelerative library for Ring applications, and more!   #
#--------------------------------------------------------------#
#                                                              #
#   Description  : String replacer -- replacing, removing,     #
#                  and inserting operations.                   #
#                  Wraps stzString via composition.            #
#                  For aliases, use stzStringReplacerXT.       #
#   Version      : V0.9 (2026)                                 #
#   Author       : Mansour Ayouni (kalidianow@gmail.com)       #
#                                                              #
#--------------------------------------------------------------#


class stzStringReplacer

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
			StzRaise("Can't create stzStringReplacer! Parameter must be a string or stzString object.")
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

			if isList(pcNewSubStr) and len(pcNewSubStr) = 2 and isString(pcNewSubStr[1])
				cPN = StzCaseFold(pcNewSubStr[1])
				if cPN = "with" or cPN = "using" or cPN = "by" or cPN = "withmany" or cPN = "usingmany" or cPN = "bymany"
					pcNewSubStr = pcNewSubStr[2]
				ok
			ok

			if isList(pcNewSubStr)
				return This.ReplaceByManyCS(pcSubStr, pcNewSubStr, pCaseSensitive)
			ok

		ok

		_bCase_ = @CaseSensitive(pCaseSensitive)
		StzEngineStringReplaceCS(@oString.Engine(), pcSubStr, pcNewSubStr, _bCase_)
		@TraceObjectHistory(This)

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

	#-- ReplaceByMany: replace successive occurrences of pcSubStr
	#   with a list of distinct replacements; the i-th occurrence is
	#   replaced by the i-th entry in pacNewSubStr. If there are
	#   more occurrences than replacements the extras are left
	#   untouched. Ported from archive line 41947; uses This.FindCS
	#   to get positions and a tail-first replace so earlier offsets
	#   stay valid.

	def ReplaceByManyCS(pcSubStr, pacNewSubStr, pCaseSensitive)
		# Accept :By/:With/... named-param wrapping
		if isList(pacNewSubStr) and len(pacNewSubStr) = 2 and isString(pacNewSubStr[1])
			_cPn_ = lower(pacNewSubStr[1])
			if _cPn_ = "by" or _cPn_ = "with" or _cPn_ = "using" or _cPn_ = "bymany" or _cPn_ = "withmany" or _cPn_ = "usingmany"
				pacNewSubStr = pacNewSubStr[2]
			ok
		ok
		if NOT (isList(pacNewSubStr) and @IsListOfStrings(pacNewSubStr))
			stzRaise("ReplaceByManyCS: pacNewSubStr must be a list of strings.")
		ok
		if pcSubStr = ""
			return
		ok

		_cContent_ = @oString.Content()
		_nSubLen_ = len(pcSubStr)
		_nContentLen_ = len(_cContent_)

		_cHay_ = _cContent_
		_cNeedle_ = pcSubStr
		if NOT @CaseSensitive(pCaseSensitive)
			_cHay_ = lower(_cHay_)
			_cNeedle_ = lower(_cNeedle_)
		ok

		# Walk forward, collect positions
		_anPos_ = []
		_iScan_ = 1
		while _iScan_ <= _nContentLen_ - _nSubLen_ + 1
			if substr(_cHay_, _iScan_, _nSubLen_) = _cNeedle_
				_anPos_ + _iScan_
				_iScan_ += _nSubLen_
			else
				_iScan_++
			ok
		end

		_nReplCount_ = len(pacNewSubStr)
		_nApply_ = _nReplCount_
		if len(_anPos_) < _nApply_
			_nApply_ = len(_anPos_)
		ok

		# Apply replacements tail-first so earlier offsets stay valid
		for _iApp_ = _nApply_ to 1 step -1
			_nP_ = _anPos_[_iApp_]
			_cNew_ = pacNewSubStr[_iApp_]
			_cBefore_ = ""
			if _nP_ > 1
				_cBefore_ = StzMid(_cContent_, 1, _nP_ - 1)
			ok
			_cAfter_ = ""
			_nAfter_ = _nP_ + _nSubLen_
			if _nAfter_ <= _nContentLen_
				_cAfter_ = StzMidToEnd(_cContent_, _nAfter_)
			ok
			_cContent_ = _cBefore_ + _cNew_ + _cAfter_
			_nContentLen_ = len(_cContent_)
		next

		@oString.Update(_cContent_)

		def ReplaceByManyCSQ(pcSubStr, pacNewSubStr, pCaseSensitive)
			This.ReplaceByManyCS(pcSubStr, pacNewSubStr, pCaseSensitive)
			return This

	def ReplaceByMany(pcSubStr, pacNewSubStr)
		This.ReplaceByManyCS(pcSubStr, pacNewSubStr, 1)

		def ReplaceByManyQ(pcSubStr, pacNewSubStr)
			This.ReplaceByMany(pcSubStr, pacNewSubStr)
			return This

	  #========================================#
	 #     REPLACE NTH OCCURRENCE            #
	#========================================#

	def ReplaceNthCS(n, pcSubStr, pcNewSubStr, pCaseSensitive)
		_bCase_ = @CaseSensitive(pCaseSensitive)
		pH = @oString.Engine()
		pR = StzEngineStringReplaceNthCS(pH, pcSubStr, pcNewSubStr, n, _bCase_)
		c = StzEngineStringData(pR)
		StzEngineStringFree(pR)
		@oString.Update(c)
		@TraceObjectHistory(This)

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
		_bCase_ = @CaseSensitive(pCaseSensitive)
		pH = @oString.Engine()
		pR = StzEngineStringReplaceFirstCS(pH, pcSubStr, pcNewSubStr, _bCase_)
		c = StzEngineStringData(pR)
		StzEngineStringFree(pR)
		@oString.Update(c)
		@TraceObjectHistory(This)

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
		_bCase_ = @CaseSensitive(pCaseSensitive)
		pH = @oString.Engine()
		pR = StzEngineStringReplaceLastCS(pH, pcSubStr, pcNewSubStr, _bCase_)
		c = StzEngineStringData(pR)
		StzEngineStringFree(pR)
		@oString.Update(c)
		@TraceObjectHistory(This)

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

	# RemoveNthCS: engine-backed. The Zig implementation walks the
	# byte stream in one pass and rebuilds the string without the
	# Nth match -- no intermediate ReplaceNthCS allocation, no
	# Ring-side loop. Case-sensitive only at present; the CS
	# variant exists for naming consistency with the rest of the
	# Remove* family. (Insensitive matching will route through
	# StzEngineStringRemoveNthCI once it lands on the engine side;
	# until then it falls back to ReplaceNthCS for pCaseSensitive=0.)

	def RemoveNthCS(n, pcSubStr, pCaseSensitive)
		if pCaseSensitive = 1
			pH = @oString.Engine()
			pR = StzEngineStringRemoveNth(pH, pcSubStr, n)
			c = StzEngineStringData(pR)
			StzEngineStringFree(pR)
			@oString.Update(c)
		else
			This.ReplaceNthCS(n, pcSubStr, "", pCaseSensitive)
		ok

		def RemoveNthCSQ(n, pcSubStr, pCaseSensitive)
			This.RemoveNthCS(n, pcSubStr, pCaseSensitive)
			return This

	def RemoveNth(n, pcSubStr)
		This.RemoveNthCS(n, pcSubStr, 1)

		def RemoveNthQ(n, pcSubStr)
			This.RemoveNth(n, pcSubStr)
			return This

		# Softanza universal naming: RemoveNthOccurrence{,CS} are
		# the long-form aliases. The "Engine"-flavoured form that
		# used to exist (RemoveNthOccurrenceEngine) has been
		# folded into RemoveNthCS itself -- callers should never
		# need to know whether the work lives in Ring or Zig.
		def RemoveNthOccurrence(n, pcSubStr)
			This.RemoveNth(n, pcSubStr)

		def RemoveNthOccurrenceCS(n, pcSubStr, pCaseSensitive)
			This.RemoveNthCS(n, pcSubStr, pCaseSensitive)

	def RemoveFirstCS(pcSubStr, pCaseSensitive)
		This.RemoveNthCS(1, pcSubStr, pCaseSensitive)

	def RemoveFirst(pcSubStr)
		This.RemoveFirstCS(pcSubStr, 1)

	def RemoveLastCS(pcSubStr, pCaseSensitive)
		oFinder = new stzStringFinder(@oString)
		n = oFinder.NumberOfOccurrenceCS(pcSubStr, pCaseSensitive)
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

		nLen = @oString.NumberOfChars()
		cBefore = ""
		cAfter = ""
		if nPos > 1
			cBefore = @oString.Section(1, nPos - 1)
		ok
		if nPos <= nLen
			cAfter = @oString.Section(nPos, nLen)
		ok
		@oString.Update(cBefore + pcSubStr + cAfter)

		def InsertBeforeQ(nPos, pcSubStr)
			This.InsertBefore(nPos, pcSubStr)
			return This

	def InsertAfter(nPos, pcSubStr)
		This.InsertBefore(nPos + 1, pcSubStr)

		def InsertAfterQ(nPos, pcSubStr)
			This.InsertAfter(nPos, pcSubStr)
			return This

	  #===============================#
	 #     SURROUND                  #
	#===============================#

	def Surround(pcBefore, pcAfter)
		pH = @oString.Engine()
		pR = StzEngineStringSurround(pH, pcBefore, pcAfter)
		c = StzEngineStringData(pR)
		StzEngineStringFree(pR)
		@oString.Update(c)

		def SurroundQ(pcBefore, pcAfter)
			This.Surround(pcBefore, pcAfter)
			return This

	def Surrounded(pcBefore, pcAfter)
		_oCopy_ = new stzStringReplacer(@oString.Content())
		_oCopy_.SurroundQ(pcBefore, pcAfter)
		return _oCopy_.Content()

	  #===============================#
	 #     STRIP TAGS                #
	#===============================#

	def StripTags()
		pH = @oString.Engine()
		pR = StzEngineStringStripTags(pH)
		c = StzEngineStringData(pR)
		StzEngineStringFree(pR)
		@oString.Update(c)

		def StripTagsQ()
			This.StripTags()
			return This

	def TagsStripped()
		_oCopy_ = new stzStringReplacer(@oString.Content())
		_oCopy_.StripTagsQ()
		return _oCopy_.Content()

	  #===============================#
	 #     REMOVE WHITESPACE         #
	#===============================#

	def RemoveWhitespace()
		pH = @oString.Engine()
		pR = StzEngineStringRemoveWhitespace(pH)
		c = StzEngineStringData(pR)
		StzEngineStringFree(pR)
		@oString.Update(c)

		def RemoveWhitespaceQ()
			This.RemoveWhitespace()
			return This

	def WhitespaceRemoved()
		_oCopy_ = new stzStringReplacer(@oString.Content())
		_oCopy_.RemoveWhitespaceQ()
		return _oCopy_.Content()

	  #===============================#
	 #     SQUEEZE CHAR              #
	#===============================#

	def SqueezeChar(pcChar)
		pH = @oString.Engine()
		# Convert char string to codepoint number for the engine
		pHChar = StzEngineString(pcChar)
		nCp = StzEngineStringCharAt(pHChar, 1)
		StzEngineStringFree(pHChar)
		pR = StzEngineStringSqueezeChar(pH, nCp)
		c = StzEngineStringData(pR)
		StzEngineStringFree(pR)
		@oString.Update(c)

		def SqueezeCharQ(pcChar)
			This.SqueezeChar(pcChar)
			return This

	def CharSqueezed(pcChar)
		_oCopy_ = new stzStringReplacer(@oString.Content())
		_oCopy_.SqueezeCharQ(pcChar)
		return _oCopy_.Content()

	  #===============================#
	 #     REPLACE CHAR (codepoint)  #
	#===============================#

	def ReplaceCharCP(pcOldChar, pcNewChar)
		pH = @oString.Engine()
		pHOld = StzEngineString(pcOldChar)
		nOldCp = StzEngineStringCharAt(pHOld, 1)
		StzEngineStringFree(pHOld)
		pHNew = StzEngineString(pcNewChar)
		nNewCp = StzEngineStringCharAt(pHNew, 1)
		StzEngineStringFree(pHNew)
		pR = StzEngineStringReplaceChar(pH, nOldCp, nNewCp)
		c = StzEngineStringData(pR)
		StzEngineStringFree(pR)
		@oString.Update(c)

		def ReplaceCharCPQ(pcOldChar, pcNewChar)
			This.ReplaceCharCP(pcOldChar, pcNewChar)
			return This

	def CharReplacedCP(pcOldChar, pcNewChar)
		_oCopy_ = new stzStringReplacer(@oString.Content())
		_oCopy_.ReplaceCharCP(pcOldChar, pcNewChar)
		return _oCopy_.Content()

	  #===============================#
	 #     REPLACE ANY CHAR          #
	#===============================#

	def ReplaceAnyChar(pcCharsToReplace, pcReplacement)
		pH = @oString.Engine()
		pR = StzEngineStringReplaceAnyChar(pH, pcCharsToReplace, pcReplacement)
		c = StzEngineStringData(pR)
		StzEngineStringFree(pR)
		@oString.Update(c)

		def ReplaceAnyCharQ(pcCharsToReplace, pcReplacement)
			This.ReplaceAnyChar(pcCharsToReplace, pcReplacement)
			return This

	def AnyCharReplaced(pcCharsToReplace, pcReplacement)
		_oCopy_ = new stzStringReplacer(@oString.Content())
		_oCopy_.ReplaceAnyChar(pcCharsToReplace, pcReplacement)
		return _oCopy_.Content()

	  #===============================#
	 #     REPLACE AT POSITION       #
	#===============================#

	def ReplaceAt(nCpPos, nCpCount, pcReplacement)
		pH = @oString.Engine()
		pR = StzEngineStringReplaceAt(pH, nCpPos, nCpCount, pcReplacement)
		c = StzEngineStringData(pR)
		StzEngineStringFree(pR)
		@oString.Update(c)

		def ReplaceAtQ(nCpPos, nCpCount, pcReplacement)
			This.ReplaceAt(nCpPos, nCpCount, pcReplacement)
			return This

	  #===============================#
	 #     REPLACE BETWEEN MARKERS   #
	#===============================#

	def ReplaceBetween(pcOpen, pcClose, pcReplacement)
		# Softanza semantics: replaces ALL open...close pairs
		pH = @oString.Engine()
		pR = StzEngineStringReplaceBetweenAll(pH, pcOpen, pcClose, pcReplacement)
		_cRbResult_ = StzEngineStringData(pR)
		StzEngineStringFree(pR)
		@oString.Update(_cRbResult_)

		def ReplaceBetweenQ(pcOpen, pcClose, pcReplacement)
			This.ReplaceBetween(pcOpen, pcClose, pcReplacement)
			return This

	def BetweenReplaced(pcOpen, pcClose, pcReplacement)
		_oCopy_ = new stzStringReplacer(@oString.Content())
		_oCopy_.ReplaceBetween(pcOpen, pcClose, pcReplacement)
		return _oCopy_.Content()

	  #=======================================#
	 #     REPLACE FIRST BETWEEN MARKERS     #
	#=======================================#

	def ReplaceFirstBetween(pcOpen, pcClose, pcReplacement)
		# Replaces only the FIRST open...close pair
		pH = @oString.Engine()
		pR = StzEngineStringReplaceFirstBetween(pH, pcOpen, pcClose, pcReplacement)
		_cRfbResult_ = StzEngineStringData(pR)
		StzEngineStringFree(pR)
		@oString.Update(_cRfbResult_)

		def ReplaceFirstBetweenQ(pcOpen, pcClose, pcReplacement)
			This.ReplaceFirstBetween(pcOpen, pcClose, pcReplacement)
			return This

	def FirstBetweenReplaced(pcOpen, pcClose, pcReplacement)
		_oCopy_ = new stzStringReplacer(@oString.Content())
		_oCopy_.ReplaceFirstBetween(pcOpen, pcClose, pcReplacement)
		return _oCopy_.Content()

	  #===============================#
	 #     REPLACE SUBSTRING (range) #
	#===============================#

	def ReplaceSubstring(nFrom, nTo, pcReplacement)
		pH = @oString.Engine()
		pR = StzEngineStringReplaceSubstring(pH, nFrom, nTo, pcReplacement)
		c = StzEngineStringData(pR)
		StzEngineStringFree(pR)
		@oString.Update(c)

		def ReplaceSubstringQ(nFrom, nTo, pcReplacement)
			This.ReplaceSubstring(nFrom, nTo, pcReplacement)
			return This

	  #===============================#
	 #     REPLACE TWO PAIRS         #
	#===============================#

	def Replace2(pcOld1, pcNew1, pcOld2, pcNew2)
		pH = @oString.Engine()
		pR = StzEngineStringReplace2(pH, pcOld1, pcNew1, pcOld2, pcNew2)
		c = StzEngineStringData(pR)
		StzEngineStringFree(pR)
		@oString.Update(c)

		def Replace2Q(pcOld1, pcNew1, pcOld2, pcNew2)
			This.Replace2(pcOld1, pcNew1, pcOld2, pcNew2)
			return This

	  #===============================#
	 #     REPLACE CHAR AT POSITION  #
	#===============================#

	def ReplaceCharAt(nCpPos, pcNewStr)
		pH = @oString.Engine()
		pR = StzEngineStringReplaceCharAt(pH, nCpPos, pcNewStr)
		c = StzEngineStringData(pR)
		StzEngineStringFree(pR)
		@oString.Update(c)

		def ReplaceCharAtQ(nCpPos, pcNewStr)
			This.ReplaceCharAt(nCpPos, pcNewStr)
			return This

	def CharReplacedAt(nCpPos, pcNewStr)
		_oCopy_ = new stzStringReplacer(@oString.Content())
		_oCopy_.ReplaceCharAt(nCpPos, pcNewStr)
		return _oCopy_.Content()

	  #===============================#
	 #     SPACIFY                    #
	#===============================#

	def Spacify()
		pH = @oString.Engine()
		pR = StzEngineStringSpacify(pH)
		c = StzEngineStringData(pR)
		StzEngineStringFree(pR)
		@oString.Update(c)

		def SpacifyQ()
			This.Spacify()
			return This

	def Spacified()
		pH = @oString.Engine()
		pR = StzEngineStringSpacify(pH)
		c = StzEngineStringData(pR)
		StzEngineStringFree(pR)
		return c

	  #===============================#
	 #     STRIP MARKS                #
	#===============================#

	def StripMarks()
		pH = @oString.Engine()
		pR = StzEngineStringStripMarks(pH)
		c = StzEngineStringData(pR)
		StzEngineStringFree(pR)
		@oString.Update(c)

		def StripMarksQ()
			This.StripMarks()
			return This

	def MarksStripped()
		pH = @oString.Engine()
		pR = StzEngineStringStripMarks(pH)
		c = StzEngineStringData(pR)
		StzEngineStringFree(pR)
		return c

		def StrippedOfMarks()
			return This.MarksStripped()

	  #===============================#
	 #     REGEX REPLACE ALL         #
	#===============================#

	def ReplaceAllRegex(pcPattern, pcReplacement)
		pH = @oString.Engine()
		pR = StzEngineStringRegexReplaceAll(pH, pcPattern, pcReplacement, 0)
		if pR = NULL return ok
		c = StzEngineStringData(pR)
		StzEngineStringFree(pR)
		@oString.Update(c)

		def ReplaceAllRegexQ(pcPattern, pcReplacement)
			This.ReplaceAllRegex(pcPattern, pcReplacement)
			return This

		def ReplaceRegex(pcPattern, pcReplacement)
			This.ReplaceAllRegex(pcPattern, pcReplacement)

	def AllRegexReplaced(pcPattern, pcReplacement)
		pH = @oString.Engine()
		pR = StzEngineStringRegexReplaceAll(pH, pcPattern, pcReplacement, 0)
		if pR = NULL return @oString.Content() ok
		c = StzEngineStringData(pR)
		StzEngineStringFree(pR)
		return c

		def RegexReplaced(pcPattern, pcReplacement)
			return This.AllRegexReplaced(pcPattern, pcReplacement)

	def ReplaceAllRegexCS(pcPattern, pcReplacement, pCaseSensitive)
		_bCase_ = @CaseSensitive(pCaseSensitive)
		_nFlags_ = 0
		if _bCase_ = 0
			_nFlags_ = 1
		ok
		pH = @oString.Engine()
		pR = StzEngineStringRegexReplaceAll(pH, pcPattern, pcReplacement, _nFlags_)
		if pR = NULL return ok
		c = StzEngineStringData(pR)
		StzEngineStringFree(pR)
		@oString.Update(c)

		def ReplaceAllRegexCSQ(pcPattern, pcReplacement, pCaseSensitive)
			This.ReplaceAllRegexCS(pcPattern, pcReplacement, pCaseSensitive)
			return This
