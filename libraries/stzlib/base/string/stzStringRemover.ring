#--------------------------------------------------------------#
#        SOFTANZA LIBRARY (V0.9) - STZSTRINGREMOVER            #
#   An accelerative library for Ring applications, and more!   #
#--------------------------------------------------------------#
#                                                              #
#   Description  : String remover subclass -- removing         #
#                  substrings by value, position, or section.  #
#                  For aliases, use stzStringRemoverXT.        #
#   Version      : V0.9 (2026)                                 #
#   Author       : Mansour Ayouni (kalidianow@gmail.com)       #
#                                                              #
#--------------------------------------------------------------#


  /////////////////
 ///   CLASS   ///
/////////////////

# Deletes parts of a text: a substring, an occurrence, a position or section, the spaces, the repeats or what lies between two bounds.
#
# It is the removal helper behind many Remove methods of stzString, which builds one over itself and
# writes the result back; build one directly when you only need the removals. Each verb changes the
# held text in place and returns nothing (the Q form returns the remover so calls chain), and the
# form that ends in -Removed returns the new text and leaves the remover alone. Read the result with
# Content. Positions count characters, not bytes, so Hebrew, Arabic and emoji text is cut where you
# expect. Pass a plain text, not a stzString object: editing through a remover empties the stzString
# that was passed in. The case-flag forms (CS) of the first, last, nth, from-left, from-right and
# between removals ignore their flag today, and the nth rank starts at 0 here. An end position
# before a start position, or a closing-bound removal (IB) that finds no pair, kills the Ring
# process.
#
#   receiver   o1 = new stzStringRemover("banana split")
#   example    o1.RemoveFirst("an")
#              ? o1.Content()
#              #--> bana split
#              o2 = new stzStringRemover("שלום עולם")
#              o2.RemoveSpaces()
#              ? o2.Content()
#              #--> שלוםעולם
#              o3 = new stzStringRemover("a😀b😀c")
#              ? o3.CharRemovedAt(2)
#              #--> ab😀c
#   see        stzString, stzStringReplacer, stzStringChecker
class stzStringRemover from stzObject

	@oString

	# Builds a remover over a text, given as a string or as a stzString object.
	#
	#   pStrOrStzStrObj   the text to edit, or a stzString whose content is edited
	#   returns           nothing; the object is built
	#   note              pass a plain text and read the result with Content; stzString does it
	#                     safely by writing the remover result back with Update
	#   warning           with a stzString argument, the first edit made through the remover leaves
	#                     the stzString you passed reading as an empty text (three datasets: keep
	#                     me, abc xyz, and abc xyz again with RemoveSpaces); the remover itself
	#                     keeps the right text
	#   see               Content, NumberOfChars
	def init(pStrOrStzStrObj)
		if isString(pStrOrStzStrObj)
			@oString = new stzString(pStrOrStzStrObj)
		but isObject(pStrOrStzStrObj)
			@oString = pStrOrStzStrObj
		else
			StzRaise("Can't create stzStringRemover! Parameter must be a string or stzString object.")
		ok

	# Returns the text as it stands now, after the removals made so far.
	#
	#   returns    a text
	#   see        NumberOfChars, Removed
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

	  #======================================================#
	 #   REMOVING ALL OCCURRENCES OF A GIVEN SUBSTRING      #
	#======================================================#

	def RemoveCS(pcSubStr, pCaseSensitive)
		_bCase_ = @CaseSensitive(pCaseSensitive)
		_pH_ = @oString.Engine()
		_pR_ = StzEngineStringRemoveCS(_pH_, pcSubStr, _bCase_)
		_c_ = StzEngineStringData(_pR_)
		StzEngineStringFree(_pR_)
		@oString.Update(_c_)

		def RemoveCSQ(pcSubStr, pCaseSensitive)
			This.RemoveCS(pcSubStr, pCaseSensitive)
			return This

		def RemoveAllCS(pcSubStr, pCaseSensitive)
			This.RemoveCS(pcSubStr, pCaseSensitive)

			def RemoveAllCSQ(pcSubStr, pCaseSensitive)
				return This.RemoveCSQ(pcSubStr, pCaseSensitive)

	# Deletes every occurrence of the given substring from the text, in place.
	#
	#   returns    nothing; the text changes. RemoveQ returns the remover for chaining
	#   note       RemoveW(pcCondition) deletes each character for which the condition holds:
	#              RemoveW("@char = 'a'") turns banana split into bnn split; RemoveCS(..., 0)
	#              ignores case
	#   warning    RemoveManyCS raises error R14 today (Calling Method without definition:
	#              updatewith) because it calls a method this class does not have; RemoveMany, the
	#              form without the case flag, works
	#   see        Removed, RemoveFirst, RemoveAll
	def Remove(pcSubStr)
		This.RemoveCS(pcSubStr, 1)

		def RemoveQ(pcSubStr)
			This.Remove(pcSubStr)
			return This

		# Deletes every occurrence of the given substring from the text, in place.
		#
		#   returns    nothing; the text changes. RemoveAllQ returns the remover for chaining
		#   note       same effect as Remove; RemoveAllCS("A", 0) ignores case
		#   see        Remove, RemoveFirst
		def RemoveAll(pcSubStr)
			This.Remove(pcSubStr)

			def RemoveAllQ(pcSubStr)
				return This.RemoveQ(pcSubStr)

	def RemovedCS(pcSubStr, pCaseSensitive)
		_oCopy_ = new stzStringRemover(@oString.Content())
		_oCopy_.RemoveCSQ(pcSubStr, pCaseSensitive)
		return _oCopy_.Content()

	# Returns the text with every occurrence of the given substring deleted, leaving the remover unchanged.
	#
	#   returns    a text
	#   note       RemovedW(pcCondition) does the same for each character that satisfies a condition
	#   see        Remove, FirstRemoved
	def Removed(pcSubStr)
		return This.RemovedCS(pcSubStr, 1)

	  #======================================================#
	 #   REMOVING NTH OCCURRENCE OF A GIVEN SUBSTRING       #
	#======================================================#

	def RemoveNthCS(_n_, pcSubStr, pCaseSensitive)
		_pH_ = @oString.Engine()
		_pR_ = StzEngineStringRemoveNth(_pH_, pcSubStr, _n_)
		_c_ = StzEngineStringData(_pR_)
		StzEngineStringFree(_pR_)
		@oString.Update(_c_)

		def RemoveNthCSQ(_n_, pcSubStr, pCaseSensitive)
			This.RemoveNthCS(_n_, pcSubStr, pCaseSensitive)
			return This

	# Deletes one occurrence of the given substring, chosen by its rank, in place.
	#
	#   _n_        the rank of the occurrence
	#   returns    nothing; the text changes. RemoveNthQ returns the remover for chaining
	#   note       RemoveNthCS("ONE", 0) does not match one
	#   warning    the rank starts at 0, while stzString.RemoveNth starts at 1: RemoveNth(2, "one")
	#              removes the third one of one two one two one here and the second one there; the
	#              case flag of RemoveNthCS is ignored
	#   see        NthRemoved, RemoveFirst, RemoveLast
	def RemoveNth(_n_, pcSubStr)
		This.RemoveNthCS(_n_, pcSubStr, 1)

		def RemoveNthQ(_n_, pcSubStr)
			This.RemoveNth(_n_, pcSubStr)
			return This

	def NthRemovedCS(_n_, pcSubStr, pCaseSensitive)
		_oCopy_ = new stzStringRemover(@oString.Content())
		_oCopy_.RemoveNthCSQ(_n_, pcSubStr, pCaseSensitive)
		return _oCopy_.Content()

	# Returns the text with one occurrence of the given substring deleted, chosen by its rank, leaving the remover unchanged.
	#
	#   _n_        the rank of the occurrence, counted from 0 as in RemoveNth
	#   returns    a text
	#   warning    the rank starts at 0, not at 1; the case flag of NthRemovedCS is ignored
	#   see        RemoveNth, FirstRemoved
	def NthRemoved(_n_, pcSubStr)
		return This.NthRemovedCS(_n_, pcSubStr, 1)

	  #======================================================#
	 #   REMOVING FIRST / LAST OCCURRENCE                   #
	#======================================================#

	def RemoveFirstCS(pcSubStr, pCaseSensitive)
		_pH_ = @oString.Engine()
		_pR_ = StzEngineStringRemoveFirst(_pH_, pcSubStr)
		_c_ = StzEngineStringData(_pR_)
		StzEngineStringFree(_pR_)
		@oString.Update(_c_)

		def RemoveFirstCSQ(pcSubStr, pCaseSensitive)
			This.RemoveFirstCS(pcSubStr, pCaseSensitive)
			return This

	# Deletes the first occurrence of the given substring, in place.
	#
	#   returns    nothing; the text changes. RemoveFirstQ returns the remover for chaining
	#   warning    the case flag of RemoveFirstCS is ignored: RemoveFirstCS("AN", 0) leaves banana
	#              split as it is
	#   see        FirstRemoved, RemoveLast, RemoveNth
	def RemoveFirst(pcSubStr)
		This.RemoveFirstCS(pcSubStr, 1)

		def RemoveFirstQ(pcSubStr)
			This.RemoveFirst(pcSubStr)
			return This

	def FirstRemovedCS(pcSubStr, pCaseSensitive)
		_oCopy_ = new stzStringRemover(@oString.Content())
		_oCopy_.RemoveFirstCSQ(pcSubStr, pCaseSensitive)
		return _oCopy_.Content()

	# Returns the text with the first occurrence of the given substring deleted, leaving the remover unchanged.
	#
	#   returns    a text
	#   warning    the case flag of FirstRemovedCS is ignored
	#   see        RemoveFirst, LastRemoved
	def FirstRemoved(pcSubStr)
		return This.FirstRemovedCS(pcSubStr, 1)

	#--

	def RemoveLastCS(pcSubStr, pCaseSensitive)
		_pH_ = @oString.Engine()
		_pR_ = StzEngineStringRemoveLast(_pH_, pcSubStr)
		_c_ = StzEngineStringData(_pR_)
		StzEngineStringFree(_pR_)
		@oString.Update(_c_)

		def RemoveLastCSQ(pcSubStr, pCaseSensitive)
			This.RemoveLastCS(pcSubStr, pCaseSensitive)
			return This

	# Deletes the last occurrence of the given substring, in place.
	#
	#   returns    nothing; the text changes. RemoveLastQ returns the remover for chaining
	#   warning    the case flag of RemoveLastCS is ignored: RemoveLastCS("AN", 0) leaves banana
	#              split as it is
	#   see        LastRemoved, RemoveFirst, RemoveNth
	def RemoveLast(pcSubStr)
		This.RemoveLastCS(pcSubStr, 1)

		def RemoveLastQ(pcSubStr)
			This.RemoveLast(pcSubStr)
			return This

	def LastRemovedCS(pcSubStr, pCaseSensitive)
		_oCopy_ = new stzStringRemover(@oString.Content())
		_oCopy_.RemoveLastCSQ(pcSubStr, pCaseSensitive)
		return _oCopy_.Content()

	# Returns the text with the last occurrence of the given substring deleted, leaving the remover unchanged.
	#
	#   returns    a text
	#   warning    the case flag of LastRemovedCS is ignored
	#   see        RemoveLast, FirstRemoved
	def LastRemoved(pcSubStr)
		return This.LastRemovedCS(pcSubStr, 1)

	  #======================================================#
	 #   REMOVING AT A GIVEN POSITION                       #
	#======================================================#

	def RemoveAtPositionCS(_n_, pcSubStr, pCaseSensitive)
		_nLen_ = StzLen(pcSubStr)
		This.RemoveSection(_n_, _n_ + _nLen_ - 1)

	# Deletes as many characters as the given substring has, starting at the given position, in place.
	#
	#   _n_        the position where the removal starts, counted from 1
	#   returns    nothing; the text changes
	#   note       only the length of pcSubStr matters
	#   warning    the substring is never compared with the text: RemoveAtPosition(2, "zz") removes
	#              the two characters at positions 2 and 3 of hello although zz is not there, and
	#              the case flag is not used
	#   see        RemoveSection, RemoveRange, RemoveCharAt
	def RemoveAtPosition(_n_, pcSubStr)
		This.RemoveAtPositionCS(_n_, pcSubStr, 1)

	  #======================================================#
	 #   REMOVING A SECTION                                 #
	#======================================================#

	# Deletes the characters from one position to another, both included, in place.
	#
	#   n1         the position of the first character to delete, counted from 1
	#   n2         the position of the last character to delete
	#   returns    nothing; the text changes. RemoveSectionQ returns the remover for chaining
	#   note       positions count characters, so a Hebrew letter or an emoji is one position
	#   warning    an end position before the start position kills the whole Ring process with an
	#              engine panic (integer part of floating point value out of bounds):
	#              RemoveSection(3, 1) on hello and RemoveSection(4, 2) on banana split both did
	#   see        SectionRemoved, RemoveRange, RemoveCharAt
	def RemoveSection(n1, n2)
		_pH_ = @oString.Engine()
		_pR_ = StzEngineStringRemoveRange(_pH_, n1, n2 - n1 + 1)
		_c_ = StzEngineStringData(_pR_)
		StzEngineStringFree(_pR_)
		@oString.Update(_c_)

		def RemoveSectionQ(n1, n2)
			This.RemoveSection(n1, n2)
			return This

	# Returns the text with the characters from one position to another deleted, leaving the remover unchanged.
	#
	#   n1         the position of the first character to delete, counted from 1
	#   n2         the position of the last character to delete
	#   returns    a text
	#   warning    an end position before the start position kills the whole Ring process with an
	#              engine panic, as RemoveSection does
	#   see        RemoveSection, RangeRemoved
	def SectionRemoved(n1, n2)
		_oCopy_ = new stzStringRemover(@oString.Content())
		_oCopy_.RemoveSectionQ(n1, n2)
		return _oCopy_.Content()

	  #======================================================#
	 #   REMOVING A RANGE (POSITION + N CHARS)              #
	#======================================================#

	# Deletes a number of characters from a given position, in place.
	#
	#   nStart     the position of the first character to delete, counted from 1
	#   nRange     how many characters to delete
	#   returns    nothing; the text changes. RemoveRangeQ returns the remover for chaining
	#   note       RemoveRange(2, 3) on banana split gives bna split
	#   warning    a negative count kills the whole Ring process with an engine panic:
	#              RemoveRange(2, -1) on plain text did; a count of 0 changes nothing
	#   see        RangeRemoved, RemoveSection
	def RemoveRange(nStart, nRange)
		This.RemoveSection(nStart, nStart + nRange - 1)

		def RemoveRangeQ(nStart, nRange)
			This.RemoveRange(nStart, nRange)
			return This

	# Returns the text with a number of characters deleted from a given position, leaving the remover unchanged.
	#
	#   nStart     the position of the first character to delete, counted from 1
	#   nRange     how many characters to delete
	#   returns    a text
	#   warning    a negative count kills the whole Ring process with an engine panic, as
	#              RemoveRange does
	#   see        RemoveRange, SectionRemoved
	def RangeRemoved(nStart, nRange)
		_oCopy_ = new stzStringRemover(@oString.Content())
		_oCopy_.RemoveRangeQ(nStart, nRange)
		return _oCopy_.Content()

	  #======================================================#
	 #   REMOVING WITH CONDITION                            #
	#======================================================#

	def RemoveW(pcCondition)
		_oFinder_ = new stzStringFinder(@oString)
		_anPos_ = _oFinder_.FindW(pcCondition)
		for i = len(_anPos_) to 1 step -1
			This.RemoveSection(_anPos_[i], _anPos_[i])
		next

		def RemoveWQ(pcCondition)
			This.RemoveW(pcCondition)
			return This

	def RemovedW(pcCondition)
		_oCopy_ = new stzStringRemover(@oString.Content())
		_oCopy_.RemoveWQ(pcCondition)
		return _oCopy_.Content()

	  #======================================================#
	 #   REMOVING MANY SUBSTRINGS AT ONCE                   #
	#======================================================#

	def RemoveManyCS(pacSubStr, pCaseSensitive)
		if CheckParams()
			if NOT (isList(pacSubStr) and @IsListOfStrings(pacSubStr))
				StzRaise("Incorrect param type! pacSubStr must be a list of strings.")
			ok
		ok

		_acSubStr_ = U(pacSubStr)
		_nLen_ = len(_acSubStr_)
		_oCopy_ = new stzStringRemover(@oString.Content())

		for @i = 1 to _nLen_
			_oCopy_.RemoveAllCS(_acSubstr_[@i], pCaseSensitive)
		next

		This.UpdateWith(_oCopy_.Content())

		def RemoveManyCSQ(pacSubStr, pCaseSensitive)
			This.RemoveManyCS(pacSubStr, pCaseSensitive)
			return This

		def RemoveAllOfTheseCS(pacSubStr, pCaseSensitive)
			This.RemoveManyCS(pacSubStr, pCaseSensitive)

		def RemoveTheseCS(pacSubStr, pCaseSensitive)
			This.RemoveManyCS(pacSubStr, pCaseSensitive)

	def ManyRemovedCS(pacSubStr, pCaseSensitive)
		_oCopy_ = new stzStringRemover(@oString.Content())
		_oCopy_.RemoveManyCSQ(pacSubStr, pCaseSensitive)
		return _oCopy_.Content()

	#--

	def RemoveMany(pacSubStr)
		_nPacSubstr1Len_ = len(pacSubstr)
		for _iLoopPacSubstr1_ = 1 to _nPacSubstr1Len_
			_cSubstr_ = pacSubstr[_iLoopPacSubstr1_]
			This.RemoveAll(_cSubstr_)
		next

		def RemoveManyQ(pacSubStr)
			This.RemoveMany(pacSubStr)
			return This

		# Deletes every occurrence of each of the given substrings, one after the other, in place.
		#
		#   pacSubStr   the list of substrings to delete
		#   returns     nothing; the text changes
		#   note        the substrings are removed in list order, so an earlier removal can create
		#               or destroy a later match
		#   warning     RemoveAllOfTheseCS raises error R14 today (Calling Method without
		#               definition: updatewith); the form without the case flag works
		#   see         RemoveThese, ManyRemoved, Remove
		def RemoveAllOfThese(pacSubStr)
			This.RemoveMany(pacSubStr)

		# Deletes every occurrence of each of the given substrings, one after the other, in place.
		#
		#   pacSubStr   the list of substrings to delete
		#   returns     nothing; the text changes
		#   note        same effect as RemoveAllOfThese
		#   warning     RemoveTheseCS raises error R14 today (Calling Method without definition:
		#               updatewith); the form without the case flag works
		#   see         RemoveAllOfThese, ManyRemoved
		def RemoveThese(pacSubStr)
			This.RemoveMany(pacSubStr)

	# Returns the text with every occurrence of each of the given substrings deleted, leaving the remover unchanged.
	#
	#   pacSubStr   the list of substrings to delete
	#   returns     a text
	#   note        ManyRemoved(["an", "pl"]) on banana split gives ba sit
	#   warning     ManyRemovedCS raises error R14 today (Calling Method without definition:
	#               updatewith); the form without the case flag works
	#   see         RemoveThese, Removed
	def ManyRemoved(pacSubStr)
		_oCopy_ = new stzStringRemover(@oString.Content())
		_oCopy_.RemoveManyQ(pacSubStr)
		return _oCopy_.Content()

		def TheseRemoved(pacSubStr)
			return This.ManyRemoved(pacSubStr)

	  #===========================================================#
	 #   REMOVING ALL SUBSTRINGS EXCEPT THOSE PROVIDED           #
	#===========================================================#

	def RemoveSubStringsExceptCS(pacSubStr, pCaseSensitive)
		_oFinder_ = new stzStringFinder(@oString)
		_acAll_ = _oFinder_.SubStringsCS(pCaseSensitive)
		_nLen_ = len(_acAll_)

		for @i = 1 to _nLen_
			_bFound_ = 0
			for @j = 1 to len(pacSubStr)
				if BothStringsAreEqualCS(_acAll_[@i], pacSubStr[@j], pCaseSensitive)
					_bFound_ = 1
					exit
				ok
			next
			if NOT _bFound_
				This.RemoveCS(_acAll_[@i], pCaseSensitive)
			ok
		next

		def RemoveAllExceptCS(pacSubStr, pCaseSensitive)
			This.RemoveSubStringsExceptCS(pacSubStr, pCaseSensitive)

		def RemoveAllButCS(pacSubStr, pCaseSensitive)
			This.RemoveSubStringsExceptCS(pacSubStr, pCaseSensitive)

	# Empties the text or nearly so today, where the listed pieces were meant to be the ones kept.
	#
	#   pacSubStr   the list of substrings to keep
	#   returns     nothing; the text changes
	#   note        do not rely on it; to keep a piece, remove what surrounds it with RemoveSection
	#               or RemoveFromLeft
	#   warning     the text came out empty for abc with [ "b" ], [ "abc" ] and [ "x" ], and for
	#               banana split with [ "a" ]; abc with [ "ab", "c" ] kept only c
	#   see         RemoveAllBut, RemoveAllExcept, Remove
	def RemoveSubStringsExcept(pacSubStr)
		This.RemoveSubStringsExceptCS(pacSubStr, 1)

		def RemoveAllExcept(pacSubStr)
			This.RemoveSubStringsExcept(pacSubStr)

		# Empties the text or nearly so today, where the listed pieces were meant to be the ones kept.
		#
		#   pacSubStr   the list of substrings to keep
		#   returns     nothing; the text changes
		#   note        same defect as RemoveSubStringsExcept
		#   warning     the text came out empty for banana split with [ "ba" ]: it is
		#               RemoveSubStringsExcept under another name
		#   see         RemoveSubStringsExcept, RemoveAllExcept
		def RemoveAllBut(pacSubStr)
			This.RemoveSubStringsExcept(pacSubStr)

	  #======================================================#
	 #   REMOVING BETWEEN TWO SUBSTRINGS                    #
	#======================================================#

	def RemoveAnyBetweenCS(pcBound1, pcBound2, pCaseSensitive)
		# Softanza semantics: removes ALL open...close pairs (engine-backed)
		_pH_ = @oString.Engine()
		_pR_ = StzEngineStringRemoveBetween(_pH_, pcBound1, pcBound2)
		_cRabResult_ = StzEngineStringData(_pR_)
		StzEngineStringFree(_pR_)
		@oString.Update(_cRabResult_)

		def RemoveAnyBetweenCSQ(pcBound1, pcBound2, pCaseSensitive)
			This.RemoveAnyBetweenCS(pcBound1, pcBound2, pCaseSensitive)
			return This

		def RemoveBetweenCS(pcBound1, pcBound2, pCaseSensitive)
			This.RemoveAnyBetweenCS(pcBound1, pcBound2, pCaseSensitive)

	def AnyBetweenRemovedCS(pcBound1, pcBound2, pCaseSensitive)
		_oCopy_ = new stzStringRemover(@oString.Content())
		_oCopy_.RemoveAnyBetweenCSQ(pcBound1, pcBound2, pCaseSensitive)
		return _oCopy_.Content()

	# Deletes every pair made of an opening bound, what lies between and a closing bound, bounds included, in place.
	#
	#   pcBound1   the opening bound
	#   pcBound2   the closing bound
	#   returns    nothing; the text changes. RemoveAnyBetweenQ returns the remover for chaining
	#   note       on f(x) g(y) with ( and ) it gives f g, and on a text with no pair it changes
	#              nothing; RemoveAnyBetweenIB removes one section from the first opening bound to
	#              the LAST closing bound (f for the same text) and kills the whole Ring process
	#              with an engine panic when no pair is found
	#   warning    the case flag of RemoveAnyBetweenCS is ignored: RemoveAnyBetweenCS("<B>", "</B>",
	#              0) leaves the lower-case pair in place; the IB forms (RemoveAnyBetweenIB) behave
	#              differently and can kill the Ring process, see the note
	#   see        AnyBetweenRemoved, RemoveFirstBetween, RemoveFromLeft
	#@ aka  --
	def RemoveAnyBetween(pcBound1, pcBound2)
		This.RemoveAnyBetweenCS(pcBound1, pcBound2, 1)

		def RemoveAnyBetweenQ(pcBound1, pcBound2)
			This.RemoveAnyBetween(pcBound1, pcBound2)
			return This

		# Deletes every pair made of an opening bound, what lies between and a closing bound, bounds included, in place.
		#
		#   pcBound1   the opening bound
		#   pcBound2   the closing bound
		#   returns    nothing; the text changes
		#   note       same effect as RemoveAnyBetween; the IB form has the problems described there
		#   warning    the case flag of RemoveBetweenCS is ignored
		#   see        RemoveAnyBetween, AnyBetweenRemoved
		def RemoveBetween(pcBound1, pcBound2)
			This.RemoveAnyBetween(pcBound1, pcBound2)

	# Returns the text with every opening bound, what lies between and the closing bound deleted, leaving the remover unchanged.
	#
	#   pcBound1   the opening bound
	#   pcBound2   the closing bound
	#   returns    a text
	#   note       [x] and [y] with [ and ] gives  and , one space on each side
	#   warning    the case flag of AnyBetweenRemovedCS is ignored; AnyBetweenRemovedIB can kill the
	#              Ring process when no pair is found
	#   see        RemoveAnyBetween, FirstBetweenRemoved
	def AnyBetweenRemoved(pcBound1, pcBound2)
		_oCopy_ = new stzStringRemover(@oString.Content())
		_oCopy_.RemoveAnyBetweenQ(pcBound1, pcBound2)
		return _oCopy_.Content()

		def BetweenRemoved(pcBound1, pcBound2)
			return This.AnyBetweenRemoved(pcBound1, pcBound2)

	  #=======================================#
	 #     REMOVE FIRST BETWEEN MARKERS      #
	#=======================================#

	# Deletes the first pair made of an opening bound, what lies between and a closing bound, bounds included, in place.
	#
	#   pcBound1   the opening bound
	#   pcBound2   the closing bound
	#   returns    nothing; the text changes. RemoveFirstBetweenQ returns the remover for chaining
	#   note       on f(x) g(y) with ( and ) it gives f g(y)
	#   see        FirstBetweenRemoved, RemoveAnyBetween
	def RemoveFirstBetween(pcBound1, pcBound2)
		# Removes only the FIRST open...close pair
		_pH_ = @oString.Engine()
		_pR_ = StzEngineStringRemoveFirstBetween(_pH_, pcBound1, pcBound2)
		_cRfbResult_ = StzEngineStringData(_pR_)
		StzEngineStringFree(_pR_)
		@oString.Update(_cRfbResult_)

		def RemoveFirstBetweenQ(pcBound1, pcBound2)
			This.RemoveFirstBetween(pcBound1, pcBound2)
			return This

	# Returns the text with the first opening bound, what lies between and the closing bound deleted, leaving the remover unchanged.
	#
	#   pcBound1   the opening bound
	#   pcBound2   the closing bound
	#   returns    a text
	#   see        RemoveFirstBetween, AnyBetweenRemoved
	def FirstBetweenRemoved(pcBound1, pcBound2)
		_oCopy_ = new stzStringRemover(@oString.Content())
		_oCopy_.RemoveFirstBetween(pcBound1, pcBound2)
		return _oCopy_.Content()

	  #-----------------------------------------------------------#
	 #   REMOVING BETWEEN TWO SUBSTRINGS -- INCLUDING BOUNDS     #
	#-----------------------------------------------------------#

	def RemoveAnyBetweenCSIB(pcBound1, pcBound2, pCaseSensitive)
		_oFinder_ = new stzStringFinder(@oString)
		_aSection_ = _oFinder_.FindAnyBetweenAsSectionCS(pcBound1, pcBound2, pCaseSensitive)

		if isList(pcBound2) and IsAndNamedParamList(pcBound2)
			pcBound2 = pcBound2[2]
		ok

		_nLen1_ = StzLen(pcBound1)
		_nLen2_ = StzLen(pcBound2)

		_aSection_[1] = _aSection_[1] - _nLen1_
		_aSection_[2] = _aSection_[2] + _nLen2_

		This.RemoveSection(_aSection_[1], _aSection_[2])

		def RemoveAnyBetweenCSIBQ(pcBound1, pcBound2, pCaseSensitive)
			This.RemoveAnyBetweenCSIB(pcBound1, pcBound2, pCaseSensitive)
			return This

		def RemoveBetweenCSIB(pcBound1, pcBound2, pCaseSensitive)
			This.RemoveAnyBetweenCSIB(pcBound1, pcBound2, pCaseSensitive)

	def AnyBetweenRemovedCSIB(pcBound1, pcBound2, pCaseSensitive)
		_oCopy_ = new stzStringRemover(@oString.Content())
		_oCopy_.RemoveAnyBetweenCSIBQ(pcBound1, pcBound2, pCaseSensitive)
		return _oCopy_.Content()

	#--

	def RemoveAnyBetweenIB(pcBound1, pcBound2)
		This.RemoveAnyBetweenCSIB(pcBound1, pcBound2, 1)

		def RemoveAnyBetweenIBQ(pcBound1, pcBound2)
			This.RemoveAnyBetweenIB(pcBound1, pcBound2)
			return This

		def RemoveBetweenIB(pcBound1, pcBound2)
			This.RemoveAnyBetweenIB(pcBound1, pcBound2)

	def AnyBetweenRemovedIB(pcBound1, pcBound2)
		_oCopy_ = new stzStringRemover(@oString.Content())
		_oCopy_.RemoveAnyBetweenIBQ(pcBound1, pcBound2)
		return _oCopy_.Content()

	  #======================================================#
	 #   REMOVING DUPLICATES                                #
	#======================================================#

	def RemoveDuplicatesCS(pCaseSensitive)
		_oFinder_ = new stzStringFinder(@oString)
		_aSections_ = _oFinder_.FindDuplicatesAsSectionsCS(pCaseSensitive)
		if len(_aSections_) > 0
			@oString.RemoveSections(_aSections_)
		ok

		def RemoveDuplicatesCSQ(pCaseSensitive)
			This.RemoveDuplicatesCS(pCaseSensitive)
			return This

	def DuplicatesRemovedCS(pCaseSensitive)
		_oCopy_ = new stzStringRemover(@oString.Content())
		_oCopy_.RemoveDuplicatesCSQ(pCaseSensitive)
		return _oCopy_.Content()

		def WithoutDuplicatesCS(pCaseSensitive)
			return This.DuplicatesRemovedCS(pCaseSensitive)

	# Deletes every character that already appeared earlier, keeping the first occurrence of each, in place.
	#
	#   returns    nothing; the text changes. RemoveDuplicatesQ returns the remover for chaining
	#   note       banana split gives ban split; RemoveDuplicatesCS(0) ignores case
	#   see        DuplicatesRemoved, Remove
	#@ aka  --
	def RemoveDuplicates()
		This.RemoveDuplicatesCS(1)

		def RemoveDuplicatesQ()
			This.RemoveDuplicates()
			return This

	# Returns the text with each repeated character kept once, leaving the remover unchanged.
	#
	#   returns    a text
	#   note       banana split gives ban split
	#   see        RemoveDuplicates, Removed
	def DuplicatesRemoved()
		_oCopy_ = new stzStringRemover(@oString.Content())
		_oCopy_.RemoveDuplicatesQ()
		return _oCopy_.Content()

		def WithoutDuplicates()
			return This.DuplicatesRemoved()

	  #======================================================#
	 #   REMOVING SUBSTRING FROM LEFT / RIGHT               #
	#======================================================#

	def RemoveFromLeftCS(pcSubStr, pCaseSensitive)
		if NOT isString(pcSubStr)
			StzRaise("Incorrect param type! pcSubStr must be a string.")
		ok

		_pH_ = @oString.Engine()
		_pR_ = StzEngineStringRemovePrefix(_pH_, pcSubStr)
		_c_ = StzEngineStringData(_pR_)
		StzEngineStringFree(_pR_)
		@oString.Update(_c_)

		def RemoveFromLeftCSQ(pcSubStr, pCaseSensitive)
			This.RemoveFromLeftCS(pcSubStr, pCaseSensitive)
			return This

	def RemovedFromLeftCS(pcSubStr, pCaseSensitive)
		_oCopy_ = new stzStringRemover(@oString.Content())
		_oCopy_.RemoveFromLeftCSQ(pcSubStr, pCaseSensitive)
		return _oCopy_.Content()

	# Deletes the given substring from the beginning of the text, when the text starts with it, in place.
	#
	#   returns    nothing; the text changes. RemoveFromLeftQ returns the remover for chaining
	#   note       a substring that is not at the beginning changes nothing
	#   warning    the case flag of RemoveFromLeftCS is ignored: RemoveFromLeftCS("BA", 0) leaves
	#              banana split as it is; a non-text argument raises an error
	#   see        RemovedFromLeft, RemoveFromRight
	#@ aka  --
	def RemoveFromLeft(pcSubStr)
		This.RemoveFromLeftCS(pcSubStr, 1)

		def RemoveFromLeftQ(pcSubStr)
			This.RemoveFromLeft(pcSubStr)
			return This

	# Returns the text without the given substring at its beginning, leaving the remover unchanged.
	#
	#   returns    a text
	#   warning    the case flag of RemovedFromLeftCS is ignored
	#   see        RemoveFromLeft, RemovedFromRight
	def RemovedFromLeft(pcSubStr)
		_oCopy_ = new stzStringRemover(@oString.Content())
		_oCopy_.RemoveFromLeftQ(pcSubStr)
		return _oCopy_.Content()

	#--

	def RemoveFromRightCS(pcSubStr, pCaseSensitive)
		if NOT isString(pcSubStr)
			StzRaise("Incorrect param type! pcSubStr must be a string.")
		ok

		_pH_ = @oString.Engine()
		_pR_ = StzEngineStringRemoveSuffix(_pH_, pcSubStr)
		_c_ = StzEngineStringData(_pR_)
		StzEngineStringFree(_pR_)
		@oString.Update(_c_)

		def RemoveFromRightCSQ(pcSubStr, pCaseSensitive)
			This.RemoveFromRightCS(pcSubStr, pCaseSensitive)
			return This

	def RemovedFromRightCS(pcSubStr, pCaseSensitive)
		_oCopy_ = new stzStringRemover(@oString.Content())
		_oCopy_.RemoveFromRightCSQ(pcSubStr, pCaseSensitive)
		return _oCopy_.Content()

	# Deletes the given substring from the end of the text, when the text ends with it, in place.
	#
	#   returns    nothing; the text changes. RemoveFromRightQ returns the remover for chaining
	#   note       a substring that is not at the end changes nothing
	#   warning    the case flag of RemoveFromRightCS is ignored: RemoveFromRightCS("LIT", 0) leaves
	#              banana split as it is; a non-text argument raises an error
	#   see        RemovedFromRight, RemoveFromLeft
	#@ aka  --
	def RemoveFromRight(pcSubStr)
		This.RemoveFromRightCS(pcSubStr, 1)

		def RemoveFromRightQ(pcSubStr)
			This.RemoveFromRight(pcSubStr)
			return This

	# Returns the text without the given substring at its end, leaving the remover unchanged.
	#
	#   returns    a text
	#   warning    the case flag of RemovedFromRightCS is ignored
	#   see        RemoveFromRight, RemovedFromLeft
	def RemovedFromRight(pcSubStr)
		_oCopy_ = new stzStringRemover(@oString.Content())
		_oCopy_.RemoveFromRightQ(pcSubStr)
		return _oCopy_.Content()

	  #======================================================#
	 #   REMOVING SPACES                                    #
	#======================================================#

	# Deletes every space from the text, in place.
	#
	#   returns    nothing; the text changes. RemoveSpacesQ returns the remover for chaining
	#   note       the spaces inside the text go too: padded text gives paddedtext
	#   see        SpacesRemoved, RemoveLeadingSpaces
	def RemoveSpaces()
		This.RemoveAll(" ")

		def RemoveSpacesQ()
			This.RemoveSpaces()
			return This

		# Deletes every space from the text, in place.
		#
		#   returns    nothing; the text changes
		#   note       same effect as RemoveSpaces
		#   see        RemoveSpaces, SpacesRemoved
		def RemoveAllSpaces()
			This.RemoveSpaces()

	# Returns the text without any space, leaving the remover unchanged.
	#
	#   returns    a text
	#   see        RemoveSpaces, LeadingSpacesRemoved
	def SpacesRemoved()
		_oCopy_ = new stzStringRemover(@oString.Content())
		_oCopy_.RemoveSpacesQ()
		return _oCopy_.Content()

	# Deletes the blanks at the beginning of the text, in place, and keeps the others.
	#
	#   returns    nothing; the text changes. RemoveLeadingSpacesQ returns the remover for chaining
	#   note       a text of two blanks, padded text and two blanks gives padded text and the two
	#              trailing blanks
	#   see        LeadingSpacesRemoved, RemoveLeftSpaces, RemoveSpaces
	#@ aka  --
	def RemoveLeadingSpaces()
		@oString.TrimStart()

		def RemoveLeadingSpacesQ()
			This.RemoveLeadingSpaces()
			return This

	# Returns the text without its beginning blanks, leaving the remover unchanged.
	#
	#   returns    a text
	#   see        RemoveLeadingSpaces, TrailingSpacesRemoved
	def LeadingSpacesRemoved()
		_oCopy_ = new stzStringRemover(@oString.Content())
		_oCopy_.RemoveLeadingSpacesQ()
		return _oCopy_.Content()

	# Deletes the blanks at the end of the text, in place, and keeps the others.
	#
	#   returns    nothing; the text changes. RemoveTrailingSpacesQ returns the remover for chaining
	#   see        TrailingSpacesRemoved, RemoveRightSpaces, RemoveSpaces
	#@ aka  --
	def RemoveTrailingSpaces()
		@oString.TrimEnd()

		def RemoveTrailingSpacesQ()
			This.RemoveTrailingSpaces()
			return This

	# Returns the text without its ending blanks, leaving the remover unchanged.
	#
	#   returns    a text
	#   see        RemoveTrailingSpaces, LeadingSpacesRemoved
	def TrailingSpacesRemoved()
		_oCopy_ = new stzStringRemover(@oString.Content())
		_oCopy_.RemoveTrailingSpacesQ()
		return _oCopy_.Content()

	# Deletes the blanks at the beginning of the text, in place, and keeps the others.
	#
	#   returns    nothing; the text changes. RemoveLeftSpacesQ returns the remover for chaining
	#   note       same effect as RemoveLeadingSpaces
	#   see        LeftSpacesRemoved, RemoveLeadingSpaces
	#@ aka  --
	def RemoveLeftSpaces()
		@oString.TrimLeft()

		def RemoveLeftSpacesQ()
			This.RemoveLeftSpaces()
			return This

	# Returns the text without its beginning blanks, leaving the remover unchanged.
	#
	#   returns    a text
	#   note       same answer as LeadingSpacesRemoved
	#   see        RemoveLeftSpaces, RightSpacesRemoved
	def LeftSpacesRemoved()
		_oCopy_ = new stzStringRemover(@oString.Content())
		_oCopy_.RemoveLeftSpacesQ()
		return _oCopy_.Content()

	# Deletes the blanks at the end of the text, in place, and keeps the others.
	#
	#   returns    nothing; the text changes. RemoveRightSpacesQ returns the remover for chaining
	#   note       same effect as RemoveTrailingSpaces
	#   see        RightSpacesRemoved, RemoveTrailingSpaces
	#@ aka  --
	def RemoveRightSpaces()
		@oString.TrimRight()

		def RemoveRightSpacesQ()
			This.RemoveRightSpaces()
			return This

	# Returns the text without its ending blanks, leaving the remover unchanged.
	#
	#   returns    a text
	#   note       same answer as TrailingSpacesRemoved
	#   see        RemoveRightSpaces, LeftSpacesRemoved
	def RightSpacesRemoved()
		_oCopy_ = new stzStringRemover(@oString.Content())
		_oCopy_.RemoveRightSpacesQ()
		return _oCopy_.Content()

	  #======================================================#
	 #   REMOVING N-FIRST / N-LAST OCCURRENCES              #
	#======================================================#

	def RemoveNFirstOccurrencesCS(_n_, pcSubStr, pCaseSensitive)
		_oFinder_ = new stzStringFinder(@oString)
		_anPos_ = _oFinder_.FindCS(pcSubStr, pCaseSensitive)
		if len(_anPos_) < _n_
			_n_ = len(_anPos_)
		ok
		_nLenSubStr_ = StzLen(pcSubStr)
		for i = _n_ to 1 step -1
			This.RemoveSection(_anPos_[i], _anPos_[i] + _nLenSubStr_ - 1)
		next

		def RemoveNFirstOccurrencesCSQ(_n_, pcSubStr, pCaseSensitive)
			This.RemoveNFirstOccurrencesCS(_n_, pcSubStr, pCaseSensitive)
			return This

	# Deletes the first occurrences of a substring, as many as asked, in place.
	#
	#   _n_        how many occurrences to delete, from the first one
	#   returns    nothing; the text changes. RemoveNFirstOccurrencesCSQ returns the remover for
	#              chaining
	#   note       with 2 and one on one two one two one the text becomes  two  two one, the blanks
	#              staying; RemoveNFirstOccurrencesCS(..., 0) ignores case
	#   see        RemoveNLastOccurrences, RemoveFirst, Remove
	def RemoveNFirstOccurrences(_n_, pcSubStr)
		This.RemoveNFirstOccurrencesCS(_n_, pcSubStr, 1)

	#--

	def RemoveNLastOccurrencesCS(_n_, pcSubStr, pCaseSensitive)
		_oFinder_ = new stzStringFinder(@oString)
		_anPos_ = _oFinder_.FindCS(pcSubStr, pCaseSensitive)
		_nLen_ = len(_anPos_)
		if _nLen_ < _n_
			_n_ = _nLen_
		ok
		_nLenSubStr_ = StzLen(pcSubStr)
		for i = _nLen_ to _nLen_ - _n_ + 1 step -1
			This.RemoveSection(_anPos_[i], _anPos_[i] + _nLenSubStr_ - 1)
		next

		def RemoveNLastOccurrencesCSQ(_n_, pcSubStr, pCaseSensitive)
			This.RemoveNLastOccurrencesCS(_n_, pcSubStr, pCaseSensitive)
			return This

	# Deletes the last occurrences of a substring, as many as asked, in place.
	#
	#   _n_        how many occurrences to delete, from the last one
	#   returns    nothing; the text changes. RemoveNLastOccurrencesCSQ returns the remover for
	#              chaining
	#   note       with 2 and one on one two one two one the text becomes one two  two , the blanks
	#              staying; RemoveNLastOccurrencesCS(..., 0) ignores case
	#   see        RemoveNFirstOccurrences, RemoveLast, Remove
	def RemoveNLastOccurrences(_n_, pcSubStr)
		This.RemoveNLastOccurrencesCS(_n_, pcSubStr, 1)

	  #======================================================#
	 #   REMOVING CHAR AT POSITION                          #
	#======================================================#

	# Deletes the single character at the given position, in place.
	#
	#   _n_        the position of the character, counted from 1
	#   returns    nothing; the text changes. RemoveCharAtQ returns the remover for chaining
	#   note       works on characters: the emoji of a😀b😀c goes whole
	#   see        CharRemovedAt, RemoveCharsAtPositions, RemoveSection
	def RemoveCharAt(_n_)
		_pH_ = @oString.Engine()
		_pR_ = StzEngineStringRemoveCharAt(_pH_, _n_)
		_c_ = StzEngineStringData(_pR_)
		StzEngineStringFree(_pR_)
		@oString.Update(_c_)

		def RemoveCharAtQ(_n_)
			This.RemoveCharAt(_n_)
			return This

	# Returns the text without the character at the given position, leaving the remover unchanged.
	#
	#   _n_        the position of the character, counted from 1
	#   returns    a text
	#   see        RemoveCharAt, CharsRemovedAtPositions
	def CharRemovedAt(_n_)
		_oCopy_ = new stzStringRemover(@oString.Content())
		_oCopy_.RemoveCharAtQ(_n_)
		return _oCopy_.Content()

	  #======================================================#
	 #   REMOVING CHARS AT MULTIPLE POSITIONS               #
	#======================================================#

	# Deletes the characters at all the given positions, in place.
	#
	#   panPos     the list of positions, counted from 1, in any order
	#   returns    nothing; the text changes. RemoveCharsAtPositionsQ returns the remover for
	#              chaining
	#   note       banana split with 1, 3 and 5 gives aaa split
	#   see        CharsRemovedAtPositions, RemoveCharAt
	def RemoveCharsAtPositions(panPos)
		_aSorted_ = sort(panPos)
		for i = len(_aSorted_) to 1 step -1
			This.RemoveCharAt(_aSorted_[i])
		next

		def RemoveCharsAtPositionsQ(panPos)
			This.RemoveCharsAtPositions(panPos)
			return This

	# Returns the text without the characters at all the given positions, leaving the remover unchanged.
	#
	#   panPos     the list of positions, counted from 1, in any order
	#   returns    a text
	#   see        RemoveCharsAtPositions, CharRemovedAt
	def CharsRemovedAtPositions(panPos)
		_oCopy_ = new stzStringRemover(@oString.Content())
		_oCopy_.RemoveCharsAtPositionsQ(panPos)
		return _oCopy_.Content()
