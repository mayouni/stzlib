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


# Substitutes parts of a text: a substring, an occurrence, a position, the characters of a set, a pair of bounds or a regex match.
#
# It is the substitution helper behind many Replace methods of stzString, which builds one over
# itself and writes the result back; build one directly when you only need the replacements. Each
# verb changes the held text in place and returns nothing (the Q form returns the replacer so calls
# chain), and the form in the past tense (Replaced, Surrounded) returns the new text and leaves the
# replacer alone. Read the result with Content. Positions count characters, not bytes, so Hebrew,
# Arabic and emoji text is cut where you expect, except in ReplaceByMany. Pass a plain text, not a
# stzString object: apart from Replace, an edit through a replacer empties the stzString that was
# passed in. The ranks of ReplaceNth start at 1 but the default RemoveNth starts at 0, RemoveFirst
# removes the second occurrence and RemoveLast removes nothing, unless the case flag is given as 0.
#
#   receiver   o1 = new stzStringReplacer("hello world")
#   example    o1.Replace("world", "all")
#              ? o1.Content()
#              #--> hello all
#              o2 = new stzStringReplacer("שלום עולם")
#              o2.Surround("«", "»")
#              ? o2.Content()
#              #--> «שלום עולם»
#              o3 = new stzStringReplacer("a😀b😀c")
#              ? o3.Replaced("😀", "-")
#              #--> a-b-c
#   see        stzString, stzStringRemover, stzStringChecker
class stzStringReplacer from stzObject

	@oString

	  #===================#
	 #   INITIALIZATION  #
	#===================#

	# Builds a replacer over a text, given as a string or as a stzString object.
	#
	#   pStrOrStzStrObj   the text to edit, or a stzString whose content is edited
	#   returns           nothing; the object is built
	#   note              pass a plain text and read the result with Content; stzString does it
	#                     safely by writing the replacer result back with Update
	#   warning           with a stzString argument, Replace edits the stzString you passed in
	#                     place, but every other edit (ReplaceFirst, Surround, ReplaceNth...) leaves
	#                     the stzString you passed reading as an empty text; the replacer itself
	#                     keeps the right text
	#   see               Content, Replace
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

	# Returns the text as it stands now, after the replacements made so far.
	#
	#   returns    a text
	#   see        NumberOfChars, Replaced
	def Content()
		return @oString.Content()

	# Returns how many characters the text holds, counting an emoji or a Hebrew letter as one.
	#
	#   returns    a number
	#   see        Content, IsEmpty
	def NumberOfChars()
		return @oString.NumberOfChars()

	# TRUE if the text holds no character at all.
	#
	#   returns    TRUE or FALSE, as 1 or 0
	#   see        NumberOfChars, Content
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
				_cPN_ = StzCaseFold(pcNewSubStr[1])
				if _cPN_ = "with" or _cPN_ = "using" or _cPN_ = "by" or _cPN_ = "withmany" or _cPN_ = "usingmany" or _cPN_ = "bymany"
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
			_oCopy_ = new stzStringReplacer(This.Content())
			_oCopy_.ReplaceCS(pcSubStr, pcNewSubStr, pCaseSensitive)
			return _oCopy_.Content()

	# Substitutes every occurrence of a substring by a new one, in place.
	#
	#   returns    nothing; the text changes. ReplaceQ returns the replacer for chaining
	#   note       ReplaceCS("ONE", "1", 0) ignores case; ReplaceMany(["one", "two"], "X") puts one
	#              new text for several old ones; an empty old substring changes nothing
	#   warning    the old substring may be a list, which substitutes each member (same as
	#              ReplaceMany), and the new one a list, which hands the occurrences their own
	#              replacement (same as ReplaceByMany); a non-text old substring raises an error
	#   see        Replaced, ReplaceFirst, ReplaceNth, ReplaceByMany
	def Replace(pcSubStr, pcNewSubStr)
		This.ReplaceCS(pcSubStr, pcNewSubStr, 1)

		def ReplaceQ(pcSubStr, pcNewSubStr)
			This.Replace(pcSubStr, pcNewSubStr)
			return This

		# Returns the text with every occurrence of a substring substituted, leaving the replacer unchanged.
		#
		#   returns    a text
		#   note       ReplacedCS takes the case flag
		#   see        Replace, ReplaceFirst
		def Replaced(pcSubStr, pcNewSubStr)
			_oCopy_ = new stzStringReplacer(This.Content())
			_oCopy_.Replace(pcSubStr, pcNewSubStr)
			return _oCopy_.Content()

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

	# Gives the first occurrences of a substring their own replacement, the first one the first replacement and so on, in place.
	#
	#   pacNewSubStr   the list of replacements, in order of occurrence
	#   returns        nothing; the text changes. ReplaceByManyQ returns the replacer for chaining
	#   note           with ASCII text one two one two one and a, b gives a two b two one;
	#                  ReplaceByManyCS("ONE", [...], 0) ignores case
	#   warning        on any text that is not plain ASCII the result is wrong because positions are
	#                  counted in bytes: שלום עולם שלום with a pair of letters gives a garbled text,
	#                  a😀b😀c with 1 and 2 for the emoji gives a12 and loses the b and the c, and éa
	#                  éb gives 1 é2
	#   see            Replace, ReplaceNth
	def ReplaceByMany(pcSubStr, pacNewSubStr)
		This.ReplaceByManyCS(pcSubStr, pacNewSubStr, 1)

		def ReplaceByManyQ(pcSubStr, pacNewSubStr)
			This.ReplaceByMany(pcSubStr, pacNewSubStr)
			return This

	  #========================================#
	 #     REPLACE NTH OCCURRENCE            #
	#========================================#

	def ReplaceNthCS(_n_, pcSubStr, pcNewSubStr, pCaseSensitive)
		_bCase_ = @CaseSensitive(pCaseSensitive)
		_pH_ = @oString.Engine()
		_pR_ = StzEngineStringReplaceNthCS(_pH_, pcSubStr, pcNewSubStr, _n_, _bCase_)
		_c_ = StzEngineStringData(_pR_)
		StzEngineStringFree(_pR_)
		@oString.Update(_c_)
		@TraceObjectHistory(This)

		def ReplaceNthCSQ(_n_, pcSubStr, pcNewSubStr, pCaseSensitive)
			This.ReplaceNthCS(_n_, pcSubStr, pcNewSubStr, pCaseSensitive)
			return This

	# Substitutes one occurrence of a substring, chosen by its rank, in place.
	#
	#   _n_        the rank of the occurrence, counted from 1
	#   returns    nothing; the text changes. ReplaceNthQ returns the replacer for chaining
	#   note       ReplaceNthCS("ONE", "1", 0) ignores case; unlike RemoveNth, the rank starts at 1
	#   see        ReplaceFirst, ReplaceLast, RemoveNth
	def ReplaceNth(_n_, pcSubStr, pcNewSubStr)
		This.ReplaceNthCS(_n_, pcSubStr, pcNewSubStr, 1)

		def ReplaceNthQ(_n_, pcSubStr, pcNewSubStr)
			This.ReplaceNth(_n_, pcSubStr, pcNewSubStr)
			return This

	  #========================================#
	 #     REPLACE FIRST OCCURRENCE          #
	#========================================#

	def ReplaceFirstCS(pcSubStr, pcNewSubStr, pCaseSensitive)
		_bCase_ = @CaseSensitive(pCaseSensitive)
		_pH_ = @oString.Engine()
		_pR_ = StzEngineStringReplaceFirstCS(_pH_, pcSubStr, pcNewSubStr, _bCase_)
		_c_ = StzEngineStringData(_pR_)
		StzEngineStringFree(_pR_)
		@oString.Update(_c_)
		@TraceObjectHistory(This)

		def ReplaceFirstCSQ(pcSubStr, pcNewSubStr, pCaseSensitive)
			This.ReplaceFirstCS(pcSubStr, pcNewSubStr, pCaseSensitive)
			return This

	# Substitutes the first occurrence of a substring by a new one, in place.
	#
	#   returns    nothing; the text changes. ReplaceFirstQ returns the replacer for chaining
	#   note       ReplaceFirstCS("ONE", "1", 0) ignores case
	#   see        ReplaceLast, ReplaceNth, Replace
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
		_pH_ = @oString.Engine()
		_pR_ = StzEngineStringReplaceLastCS(_pH_, pcSubStr, pcNewSubStr, _bCase_)
		_c_ = StzEngineStringData(_pR_)
		StzEngineStringFree(_pR_)
		@oString.Update(_c_)
		@TraceObjectHistory(This)

		def ReplaceLastCSQ(pcSubStr, pcNewSubStr, pCaseSensitive)
			This.ReplaceLastCS(pcSubStr, pcNewSubStr, pCaseSensitive)
			return This

	# Substitutes the last occurrence of a substring by a new one, in place.
	#
	#   returns    nothing; the text changes. ReplaceLastQ returns the replacer for chaining
	#   note       ReplaceLastCS("ONE", "1", 0) ignores case
	#   see        ReplaceFirst, ReplaceNth, Replace
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

		_nLen_ = len(pacSubStrings)
		for i = 1 to _nLen_
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
				_oParam_ = new stzList(pSubStr)

				if _oParam_.IsListOfStrings()
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
			_oCopy_ = new stzStringReplacer(This.Content())
			_oCopy_.RemoveCS(pSubStr, pCaseSensitive)
			return _oCopy_.Content()

	# Deletes every occurrence of a substring, or of each member when a list of texts is given, in place.
	#
	#   returns    nothing; the text changes. RemoveQ returns the replacer for chaining
	#   note       RemoveCS("ONE", 0) ignores case; RemoveMany deletes several substrings
	#   see        Removed, RemoveFirst, RemoveNth, Replace
	def Remove(pcSubStr)
		This.RemoveCS(pcSubStr, 1)

		def RemoveQ(pcSubStr)
			This.Remove(pcSubStr)
			return This

		# Returns the text with every occurrence of a substring deleted, leaving the replacer unchanged.
		#
		#   returns    a text
		#   note       RemovedCS takes the case flag
		#   see        Remove, RemoveFirst
		def Removed(pcSubStr)
			_oCopy_ = new stzStringReplacer(This.Content())
			_oCopy_.Remove(pcSubStr)
			return _oCopy_.Content()

	  #===============================#
	 #     REMOVE MANY              #
	#===============================#

	def RemoveManyCS(pacSubStrings, pCaseSensitive)
		if NOT isList(pacSubStrings)
			StzRaise("Incorrect param type! pacSubStrings must be a list.")
		ok

		_nLen_ = len(pacSubStrings)
		for i = 1 to _nLen_
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

	def RemoveNthCS(_n_, pcSubStr, pCaseSensitive)
		if pCaseSensitive = 1
			_pH_ = @oString.Engine()
			_pR_ = StzEngineStringRemoveNth(_pH_, pcSubStr, _n_)
			_c_ = StzEngineStringData(_pR_)
			StzEngineStringFree(_pR_)
			@oString.Update(_c_)
		else
			This.ReplaceNthCS(_n_, pcSubStr, "", pCaseSensitive)
		ok

		def RemoveNthCSQ(_n_, pcSubStr, pCaseSensitive)
			This.RemoveNthCS(_n_, pcSubStr, pCaseSensitive)
			return This

	# Deletes one occurrence of a substring, chosen by its rank, in place.
	#
	#   _n_        the rank of the occurrence
	#   returns    nothing; the text changes. RemoveNthQ returns the replacer for chaining
	#   note       prefer RemoveNthCS(n, s, 0) for a 1-based rank until the two are aligned
	#   warning    the rank is not the same in the two calls: RemoveNth(1, "one") removes the second
	#              one of one two one two one, while RemoveNthCS(1, "ONE", 0) removes the first, and
	#              ReplaceNth counts from 1 as well; a rank past the last occurrence changes nothing
	#   see        RemoveFirst, RemoveLast, ReplaceNth
	def RemoveNth(_n_, pcSubStr)
		This.RemoveNthCS(_n_, pcSubStr, 1)

		def RemoveNthQ(_n_, pcSubStr)
			This.RemoveNth(_n_, pcSubStr)
			return This

		# Deletes one occurrence of a substring, chosen by its rank, in place.
		#
		#   _n_        the rank of the occurrence, counted from 0 in the default case-sensitive call
		#   returns    nothing; the text changes
		#   note       it is RemoveNth under a longer name
		#   warning    same rank problem as RemoveNth: RemoveNthOccurrence(2, "one") removes the
		#              third one of one two one two one
		#   see        RemoveNth, RemoveFirst
		#@ aka  Softanza universal naming: RemoveNthOccurrence{,CS} are the long-form aliases. The "Engine"-flavoured form that used to exist (RemoveNthOccurrenceEngine) has been folded into RemoveNthCS itself -- callers should never need to know whether the work lives in Ring or Zig.
		def RemoveNthOccurrence(_n_, pcSubStr)
			This.RemoveNth(_n_, pcSubStr)

		def RemoveNthOccurrenceCS(_n_, pcSubStr, pCaseSensitive)
			This.RemoveNthCS(_n_, pcSubStr, pCaseSensitive)

	def RemoveFirstCS(pcSubStr, pCaseSensitive)
		This.RemoveNthCS(1, pcSubStr, pCaseSensitive)

	# Deletes an occurrence of a substring, but the second one rather than the first, in place.
	#
	#   returns    nothing; the text changes. RemoveFirstQ returns the replacer for chaining
	#   note       on a text with one occurrence it changes nothing
	#   warning    it calls the nth removal with rank 1, which is counted from 0 in the default
	#              case-sensitive call: RemoveFirst("one") on one two one two one gives one two  two
	#              one, and Hebrew שלום עולם שלום loses its second שלום; with the case flag set to 0
	#              (RemoveFirstCS(..., 0)) the first occurrence goes
	#   see        RemoveLast, RemoveNth, ReplaceFirst
	def RemoveFirst(pcSubStr)
		This.RemoveFirstCS(pcSubStr, 1)

	def RemoveLastCS(pcSubStr, pCaseSensitive)
		_oFinder_ = new stzStringFinder(@oString)
		_n_ = _oFinder_.NumberOfOccurrenceCS(pcSubStr, pCaseSensitive)
		This.RemoveNthCS(_n_, pcSubStr, pCaseSensitive)

	# Leaves the text unchanged today, because the occurrence it aims at is one past the last, in place.
	#
	#   returns    nothing; the text does not change in the default call
	#   note       use RemoveLastCS(s, 0) or ReplaceLast(s, "") meanwhile
	#   warning    it asks the nth removal for a rank equal to the number of occurrences, and that
	#              rank counts from 0 in the default case-sensitive call, so nothing is removed: one
	#              two one two one, aaa bbb and its b stay as they are; RemoveLastCS(..., 0) does
	#              remove the last occurrence
	#   see        RemoveFirst, RemoveNth, ReplaceLast
	def RemoveLast(pcSubStr)
		This.RemoveLastCS(pcSubStr, 1)

	  #===============================#
	 #     INSERT BEFORE / AFTER    #
	#===============================#

	# Inserts a text just before the character at the given position, in place.
	#
	#   nPos       the position of the character the text goes before, counted from 1
	#   returns    nothing; the text changes. InsertBeforeQ returns the replacer for chaining
	#   note       works on characters, so an emoji or a Hebrew letter is one position
	#   warning    a position or text of the wrong type raises an error
	#   see        InsertAfter, ReplaceAt, Surround
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

		_nLen_ = @oString.NumberOfChars()
		_cBefore_ = ""
		_cAfter_ = ""
		if nPos > 1
			_cBefore_ = @oString.Section(1, nPos - 1)
		ok
		if nPos <= _nLen_
			_cAfter_ = @oString.Section(nPos, _nLen_)
		ok
		@oString.Update(_cBefore_ + pcSubStr + _cAfter_)

		def InsertBeforeQ(nPos, pcSubStr)
			This.InsertBefore(nPos, pcSubStr)
			return This

	# Inserts a text just after the character at the given position, in place.
	#
	#   nPos       the position of the character the text goes after, counted from 1
	#   returns    nothing; the text changes. InsertAfterQ returns the replacer for chaining
	#   note       hello world with 5 and a comma gives hello, world
	#   see        InsertBefore, ReplaceAt
	def InsertAfter(nPos, pcSubStr)
		This.InsertBefore(nPos + 1, pcSubStr)

		def InsertAfterQ(nPos, pcSubStr)
			This.InsertAfter(nPos, pcSubStr)
			return This

	  #===============================#
	 #     SURROUND                  #
	#===============================#

	# Wraps the whole text between a text added before it and a text added after it, in place.
	#
	#   pcBefore   the text put at the beginning
	#   pcAfter    the text put at the end, which may be empty
	#   returns    nothing; the text changes. SurroundQ returns the replacer for chaining
	#   note       hello world with [ and ] gives [hello world]
	#   see        Surrounded, InsertBefore
	def Surround(pcBefore, pcAfter)
		_pH_ = @oString.Engine()
		_pR_ = StzEngineStringSurround(_pH_, pcBefore, pcAfter)
		_c_ = StzEngineStringData(_pR_)
		StzEngineStringFree(_pR_)
		@oString.Update(_c_)

		def SurroundQ(pcBefore, pcAfter)
			This.Surround(pcBefore, pcAfter)
			return This

	# Returns the text wrapped between a text added before it and a text added after it, leaving the replacer unchanged.
	#
	#   pcBefore   the text put at the beginning
	#   pcAfter    the text put at the end
	#   returns    a text
	#   see        Surround, InsertAfter
	def Surrounded(pcBefore, pcAfter)
		_oCopy_ = new stzStringReplacer(@oString.Content())
		_oCopy_.SurroundQ(pcBefore, pcAfter)
		return _oCopy_.Content()

	  #===============================#
	 #     STRIP TAGS                #
	#===============================#

	# Deletes every markup tag written between < and >, keeping the text around them, in place.
	#
	#   returns    nothing; the text changes. StripTagsQ returns the replacer for chaining
	#   note       <p>Hello <b>big</b> world</p> gives Hello big world
	#   see        TagsStripped, ReplaceBetween
	def StripTags()
		_pH_ = @oString.Engine()
		_pR_ = StzEngineStringStripTags(_pH_)
		_c_ = StzEngineStringData(_pR_)
		StzEngineStringFree(_pR_)
		@oString.Update(_c_)

		def StripTagsQ()
			This.StripTags()
			return This

	# Returns the text without its markup tags, leaving the replacer unchanged.
	#
	#   returns    a text
	#   see        StripTags, WhitespaceRemoved
	def TagsStripped()
		_oCopy_ = new stzStringReplacer(@oString.Content())
		_oCopy_.StripTagsQ()
		return _oCopy_.Content()

	  #===============================#
	 #     REMOVE WHITESPACE         #
	#===============================#

	# Deletes every blank, tab and line break from the text, in place.
	#
	#   returns    nothing; the text changes. RemoveWhitespaceQ returns the replacer for chaining
	#   note       hello world gives helloworld
	#   see        WhitespaceRemoved, SqueezeChar, Remove
	def RemoveWhitespace()
		_pH_ = @oString.Engine()
		_pR_ = StzEngineStringRemoveWhitespace(_pH_)
		_c_ = StzEngineStringData(_pR_)
		StzEngineStringFree(_pR_)
		@oString.Update(_c_)

		def RemoveWhitespaceQ()
			This.RemoveWhitespace()
			return This

	# Returns the text without any blank, tab or line break, leaving the replacer unchanged.
	#
	#   returns    a text
	#   see        RemoveWhitespace, TagsStripped
	def WhitespaceRemoved()
		_oCopy_ = new stzStringReplacer(@oString.Content())
		_oCopy_.RemoveWhitespaceQ()
		return _oCopy_.Content()

	  #===============================#
	 #     SQUEEZE CHAR              #
	#===============================#

	# Collapses each run of the given character into a single one, in place.
	#
	#   pcChar     the character whose runs are collapsed
	#   returns    nothing; the text changes. SqueezeCharQ returns the replacer for chaining
	#   note       a  b   c with a blank gives a b c and hello with l gives helo; a character that
	#              never repeats changes nothing
	#   see        CharSqueezed, RemoveWhitespace
	def SqueezeChar(pcChar)
		_pH_ = @oString.Engine()
		# Convert char string to codepoint number for the engine
		pHChar = StzEngineString(pcChar)
		_nCp_ = StzEngineStringCharAt(pHChar, 1)
		StzEngineStringFree(pHChar)
		_pR_ = StzEngineStringSqueezeChar(_pH_, _nCp_)
		_c_ = StzEngineStringData(_pR_)
		StzEngineStringFree(_pR_)
		@oString.Update(_c_)

		def SqueezeCharQ(pcChar)
			This.SqueezeChar(pcChar)
			return This

	# Returns the text with each run of the given character collapsed into one, leaving the replacer unchanged.
	#
	#   pcChar     the character whose runs are collapsed
	#   returns    a text
	#   see        SqueezeChar, WhitespaceRemoved
	def CharSqueezed(pcChar)
		_oCopy_ = new stzStringReplacer(@oString.Content())
		_oCopy_.SqueezeCharQ(pcChar)
		return _oCopy_.Content()

	  #===============================#
	 #     REPLACE CHAR (codepoint)  #
	#===============================#

	# Substitutes every occurrence of one character by another, in place.
	#
	#   pcOldChar   the character to replace, one character
	#   pcNewChar   the character that takes its place
	#   returns     nothing; the text changes. ReplaceCharCPQ returns the replacer for chaining
	#   note        works on whole characters: the Hebrew letter ל or the emoji 😀 can be replaced;
	#               hello world with o and 0 gives hell0 w0rld
	#   see         CharReplacedCP, ReplaceAnyChar, Replace
	def ReplaceCharCP(pcOldChar, pcNewChar)
		_pH_ = @oString.Engine()
		pHOld = StzEngineString(pcOldChar)
		_nOldCp_ = StzEngineStringCharAt(pHOld, 1)
		StzEngineStringFree(pHOld)
		pHNew = StzEngineString(pcNewChar)
		_nNewCp_ = StzEngineStringCharAt(pHNew, 1)
		StzEngineStringFree(pHNew)
		_pR_ = StzEngineStringReplaceChar(_pH_, _nOldCp_, _nNewCp_)
		_c_ = StzEngineStringData(_pR_)
		StzEngineStringFree(_pR_)
		@oString.Update(_c_)

		def ReplaceCharCPQ(pcOldChar, pcNewChar)
			This.ReplaceCharCP(pcOldChar, pcNewChar)
			return This

	# Returns the text with every occurrence of one character substituted by another, leaving the replacer unchanged.
	#
	#   pcOldChar   the character to replace
	#   pcNewChar   the character that takes its place
	#   returns     a text
	#   see         ReplaceCharCP, AnyCharReplaced
	def CharReplacedCP(pcOldChar, pcNewChar)
		_oCopy_ = new stzStringReplacer(@oString.Content())
		_oCopy_.ReplaceCharCP(pcOldChar, pcNewChar)
		return _oCopy_.Content()

	  #===============================#
	 #     REPLACE ANY CHAR          #
	#===============================#

	# Substitutes each character of a given set by one replacement text, in place.
	#
	#   pcCharsToReplace   a text whose characters are the ones to replace
	#   pcReplacement      the text that replaces each of them
	#   returns            nothing; the text changes. ReplaceAnyCharQ returns the replacer for
	#                      chaining
	#   note               hello world with lo and a star gives he*** w*r*d: every matching
	#                      character gets its own star
	#   see                AnyCharReplaced, ReplaceCharCP
	def ReplaceAnyChar(pcCharsToReplace, pcReplacement)
		_pH_ = @oString.Engine()
		_pR_ = StzEngineStringReplaceAnyChar(_pH_, pcCharsToReplace, pcReplacement)
		_c_ = StzEngineStringData(_pR_)
		StzEngineStringFree(_pR_)
		@oString.Update(_c_)

		def ReplaceAnyCharQ(pcCharsToReplace, pcReplacement)
			This.ReplaceAnyChar(pcCharsToReplace, pcReplacement)
			return This

	# Returns the text with each character of a given set substituted by one replacement, leaving the replacer unchanged.
	#
	#   pcCharsToReplace   a text whose characters are the ones to replace
	#   pcReplacement      the text that replaces each of them
	#   returns            a text
	#   see                ReplaceAnyChar, CharReplacedCP
	def AnyCharReplaced(pcCharsToReplace, pcReplacement)
		_oCopy_ = new stzStringReplacer(@oString.Content())
		_oCopy_.ReplaceAnyChar(pcCharsToReplace, pcReplacement)
		return _oCopy_.Content()

	  #===============================#
	 #     REPLACE AT POSITION       #
	#===============================#

	# Substitutes a number of characters, from a given position, by a new text, in place.
	#
	#   nCpPos          the position of the first character to replace, counted from 1
	#   nCpCount        how many characters to replace, a count past the end being cut at the end
	#   pcReplacement   the text that takes their place
	#   returns         nothing; the text changes. ReplaceAtQ returns the replacer for chaining
	#   note            hello world with 1, 5 and HELLO gives HELLO world
	#   warning         a count of 0 changes nothing, so it cannot be used to insert; use
	#                   InsertBefore
	#   see             ReplaceSubstring, ReplaceCharAt, InsertBefore
	def ReplaceAt(nCpPos, nCpCount, pcReplacement)
		_pH_ = @oString.Engine()
		_pR_ = StzEngineStringReplaceAt(_pH_, nCpPos, nCpCount, pcReplacement)
		_c_ = StzEngineStringData(_pR_)
		StzEngineStringFree(_pR_)
		@oString.Update(_c_)

		def ReplaceAtQ(nCpPos, nCpCount, pcReplacement)
			This.ReplaceAt(nCpPos, nCpCount, pcReplacement)
			return This

	  #===============================#
	 #     REPLACE BETWEEN MARKERS   #
	#===============================#

	# Substitutes every pair made of an opening bound, what lies between and a closing bound, bounds included, by one text, in place.
	#
	#   pcOpen          the opening bound
	#   pcClose         the closing bound
	#   pcReplacement   the text put in place of each pair
	#   returns         nothing; the text changes. ReplaceBetweenQ returns the replacer for chaining
	#   note            hello world with l, o and an underscore gives he_ world; the bounds go with
	#                   the content
	#   see             BetweenReplaced, ReplaceFirstBetween, StripTags
	def ReplaceBetween(pcOpen, pcClose, pcReplacement)
		# Softanza semantics: replaces ALL open...close pairs
		_pH_ = @oString.Engine()
		_pR_ = StzEngineStringReplaceBetweenAll(_pH_, pcOpen, pcClose, pcReplacement)
		_cRbResult_ = StzEngineStringData(_pR_)
		StzEngineStringFree(_pR_)
		@oString.Update(_cRbResult_)

		def ReplaceBetweenQ(pcOpen, pcClose, pcReplacement)
			This.ReplaceBetween(pcOpen, pcClose, pcReplacement)
			return This

	# Returns the text with every opening bound, what lies between and the closing bound substituted by one text, leaving the replacer unchanged.
	#
	#   pcOpen          the opening bound
	#   pcClose         the closing bound
	#   pcReplacement   the text put in place of each pair
	#   returns         a text
	#   see             ReplaceBetween, FirstBetweenReplaced
	def BetweenReplaced(pcOpen, pcClose, pcReplacement)
		_oCopy_ = new stzStringReplacer(@oString.Content())
		_oCopy_.ReplaceBetween(pcOpen, pcClose, pcReplacement)
		return _oCopy_.Content()

	  #=======================================#
	 #     REPLACE FIRST BETWEEN MARKERS     #
	#=======================================#

	# Substitutes only the first pair made of an opening bound, what lies between and a closing bound, bounds included, in place.
	#
	#   pcOpen          the opening bound
	#   pcClose         the closing bound
	#   pcReplacement   the text put in place of the pair
	#   returns         nothing; the text changes. ReplaceFirstBetweenQ returns the replacer for
	#                   chaining
	#   note            <p>Hello <b>big</b> world</p> with < , > and # gives #Hello <b>big</b>
	#                   world</p>
	#   see             FirstBetweenReplaced, ReplaceBetween
	def ReplaceFirstBetween(pcOpen, pcClose, pcReplacement)
		# Replaces only the FIRST open...close pair
		_pH_ = @oString.Engine()
		_pR_ = StzEngineStringReplaceFirstBetween(_pH_, pcOpen, pcClose, pcReplacement)
		_cRfbResult_ = StzEngineStringData(_pR_)
		StzEngineStringFree(_pR_)
		@oString.Update(_cRfbResult_)

		def ReplaceFirstBetweenQ(pcOpen, pcClose, pcReplacement)
			This.ReplaceFirstBetween(pcOpen, pcClose, pcReplacement)
			return This

	# Returns the text with its first pair of bounds and what lies between substituted by one text, leaving the replacer unchanged.
	#
	#   pcOpen          the opening bound
	#   pcClose         the closing bound
	#   pcReplacement   the text put in place of the pair
	#   returns         a text
	#   see             ReplaceFirstBetween, BetweenReplaced
	def FirstBetweenReplaced(pcOpen, pcClose, pcReplacement)
		_oCopy_ = new stzStringReplacer(@oString.Content())
		_oCopy_.ReplaceFirstBetween(pcOpen, pcClose, pcReplacement)
		return _oCopy_.Content()

	  #===============================#
	 #     REPLACE SUBSTRING (range) #
	#===============================#

	# Substitutes the characters from one position to another, both included, by a new text, in place.
	#
	#   nFrom           the position of the first character to replace, counted from 1
	#   nTo             the position of the last character to replace
	#   pcReplacement   the text that takes their place
	#   returns         nothing; the text changes. ReplaceSubstringQ returns the replacer for
	#                   chaining
	#   note            hello world with 1, 5 and bye gives bye world
	#   see             ReplaceAt, ReplaceCharAt
	def ReplaceSubstring(nFrom, nTo, pcReplacement)
		_pH_ = @oString.Engine()
		_pR_ = StzEngineStringReplaceSubstring(_pH_, nFrom, nTo, pcReplacement)
		_c_ = StzEngineStringData(_pR_)
		StzEngineStringFree(_pR_)
		@oString.Update(_c_)

		def ReplaceSubstringQ(nFrom, nTo, pcReplacement)
			This.ReplaceSubstring(nFrom, nTo, pcReplacement)
			return This

	  #===============================#
	 #     REPLACE TWO PAIRS         #
	#===============================#

	# Substitutes two different substrings in one pass, so that the new texts are never searched again, in place.
	#
	#   pcOld1     the first substring to replace
	#   pcNew1     its replacement
	#   pcOld2     the second substring to replace
	#   pcNew2     its replacement
	#   returns    nothing; the text changes. Replace2Q returns the replacer for chaining
	#   note       swaps work: hello world with hello to world and world to hello gives world hello
	#   see        Replace, ReplaceAnyChar
	def Replace2(pcOld1, pcNew1, pcOld2, pcNew2)
		_pH_ = @oString.Engine()
		_pR_ = StzEngineStringReplace2(_pH_, pcOld1, pcNew1, pcOld2, pcNew2)
		_c_ = StzEngineStringData(_pR_)
		StzEngineStringFree(_pR_)
		@oString.Update(_c_)

		def Replace2Q(pcOld1, pcNew1, pcOld2, pcNew2)
			This.Replace2(pcOld1, pcNew1, pcOld2, pcNew2)
			return This

	  #===============================#
	 #     REPLACE CHAR AT POSITION  #
	#===============================#

	# Substitutes the single character at a given position by a text, in place.
	#
	#   nCpPos     the position of the character, counted from 1
	#   pcNewStr   the text put in its place, which may be longer than one character
	#   returns    nothing; the text changes. ReplaceCharAtQ returns the replacer for chaining
	#   note       hello world with 1 and J gives Jello world
	#   see        CharReplacedAt, ReplaceAt
	def ReplaceCharAt(nCpPos, pcNewStr)
		_pH_ = @oString.Engine()
		_pR_ = StzEngineStringReplaceCharAt(_pH_, nCpPos, pcNewStr)
		_c_ = StzEngineStringData(_pR_)
		StzEngineStringFree(_pR_)
		@oString.Update(_c_)

		def ReplaceCharAtQ(nCpPos, pcNewStr)
			This.ReplaceCharAt(nCpPos, pcNewStr)
			return This

	# Returns the text with the character at a given position substituted by a text, leaving the replacer unchanged.
	#
	#   nCpPos     the position of the character, counted from 1
	#   pcNewStr   the text put in its place
	#   returns    a text
	#   see        ReplaceCharAt, CharReplacedCP
	def CharReplacedAt(nCpPos, pcNewStr)
		_oCopy_ = new stzStringReplacer(@oString.Content())
		_oCopy_.ReplaceCharAt(nCpPos, pcNewStr)
		return _oCopy_.Content()

	  #===============================#
	 #     SPACIFY                    #
	#===============================#

	# Puts one blank between every two characters, in place.
	#
	#   returns    nothing; the text changes. SpacifyQ returns the replacer for chaining
	#   note       abc gives a b c and a😀b gives a 😀 b; an existing blank gets blanks around it too
	#   see        Spacified, Surround
	def Spacify()
		_pH_ = @oString.Engine()
		_pR_ = StzEngineStringSpacify(_pH_)
		_c_ = StzEngineStringData(_pR_)
		StzEngineStringFree(_pR_)
		@oString.Update(_c_)

		def SpacifyQ()
			This.Spacify()
			return This

	# Returns the text with one blank between every two characters, leaving the replacer unchanged.
	#
	#   returns    a text
	#   see        Spacify, CharSqueezed
	def Spacified()
		_pH_ = @oString.Engine()
		_pR_ = StzEngineStringSpacify(_pH_)
		_c_ = StzEngineStringData(_pR_)
		StzEngineStringFree(_pR_)
		return _c_

	  #===============================#
	 #     STRIP MARKS                #
	#===============================#

	# Deletes the combining marks, such as accents written as separate characters, in place.
	#
	#   returns    nothing; the text changes. StripMarksQ returns the replacer for chaining
	#   note       e followed by U+0301 and cole gives ecole; an accented letter written as one
	#              character is left as it is
	#   see        MarksStripped, ReplaceCharCP
	def StripMarks()
		_pH_ = @oString.Engine()
		_pR_ = StzEngineStringStripMarks(_pH_)
		_c_ = StzEngineStringData(_pR_)
		StzEngineStringFree(_pR_)
		@oString.Update(_c_)

		def StripMarksQ()
			This.StripMarks()
			return This

	# Returns the text without its combining marks, leaving the replacer unchanged.
	#
	#   returns    a text
	#   see        StripMarks, Spacified
	def MarksStripped()
		_pH_ = @oString.Engine()
		_pR_ = StzEngineStringStripMarks(_pH_)
		_c_ = StzEngineStringData(_pR_)
		StzEngineStringFree(_pR_)
		return _c_

		def StrippedOfMarks()
			return This.MarksStripped()

	  #===============================#
	 #     REGEX REPLACE ALL         #
	#===============================#

	# Substitutes every match of a regular expression by a replacement text, in place.
	#
	#   returns    nothing; the text changes. ReplaceAllRegexQ returns the replacer for chaining
	#   note       the replacement may use the groups of the pattern: (l+) and [$1] on hello world
	#              gives he[ll]o wor[l]d; ReplaceAllRegexCS(..., 0) ignores case; no match changes
	#              nothing
	#   see        AllRegexReplaced, ReplaceRegex, Replace
	def ReplaceAllRegex(pcPattern, pcReplacement)
		_pH_ = @oString.Engine()
		_pR_ = StzEngineStringRegexReplaceAll(_pH_, pcPattern, pcReplacement, 0)
		if _pR_ = "" return ok
		_c_ = StzEngineStringData(_pR_)
		StzEngineStringFree(_pR_)
		@oString.Update(_c_)

		def ReplaceAllRegexQ(pcPattern, pcReplacement)
			This.ReplaceAllRegex(pcPattern, pcReplacement)
			return This

		# Substitutes every match of a regular expression by a replacement text, in place.
		#
		#   returns    nothing; the text changes
		#   note       same effect as ReplaceAllRegex, under a shorter name
		#   see        ReplaceAllRegex, AllRegexReplaced
		def ReplaceRegex(pcPattern, pcReplacement)
			This.ReplaceAllRegex(pcPattern, pcReplacement)

	# Returns the text with every match of a regular expression substituted, leaving the replacer unchanged.
	#
	#   returns    a text
	#   see        ReplaceAllRegex, Replaced
	def AllRegexReplaced(pcPattern, pcReplacement)
		_pH_ = @oString.Engine()
		_pR_ = StzEngineStringRegexReplaceAll(_pH_, pcPattern, pcReplacement, 0)
		if _pR_ = "" return @oString.Content() ok
		_c_ = StzEngineStringData(_pR_)
		StzEngineStringFree(_pR_)
		return _c_

		def RegexReplaced(pcPattern, pcReplacement)
			return This.AllRegexReplaced(pcPattern, pcReplacement)

	def ReplaceAllRegexCS(pcPattern, pcReplacement, pCaseSensitive)
		_bCase_ = @CaseSensitive(pCaseSensitive)
		_nFlags_ = 0
		if _bCase_ = 0
			_nFlags_ = 1
		ok
		_pH_ = @oString.Engine()
		_pR_ = StzEngineStringRegexReplaceAll(_pH_, pcPattern, pcReplacement, _nFlags_)
		if _pR_ = "" return ok
		_c_ = StzEngineStringData(_pR_)
		StzEngineStringFree(_pR_)
		@oString.Update(_c_)

		def ReplaceAllRegexCSQ(pcPattern, pcReplacement, pCaseSensitive)
			This.ReplaceAllRegexCS(pcPattern, pcReplacement, pCaseSensitive)
			return This
