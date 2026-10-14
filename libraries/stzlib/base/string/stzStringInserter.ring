#--------------------------------------------------------------#
#        SOFTANZA LIBRARY (V0.9) - STZSTRINGINSERTER           #
#   An accelerative library for Ring applications, and more!   #
#--------------------------------------------------------------#
#                                                              #
#   Description  : String inserter subclass -- inserting       #
#                  substrings at positions or around matches.  #
#                  For aliases, use stzStringInserterXT.       #
#   Version      : V0.9 (2026)                                 #
#   Author       : Mansour Ayouni (kalidianow@gmail.com)       #
#                                                              #
#--------------------------------------------------------------#


# Inserts a fragment into a text: at a position, around the occurrences of another fragment, or at several positions.
#
# It is the insertion helper of stzString, which builds one over itself for its Insert methods;
# build one with StzStringInserterQ (or new stzStringInserter) when you only need to insert. Each
# verb changes the held text in place and returns nothing (the Q form returns the inserter so calls
# chain), and the Inserted form returns the new text and leaves the inserter alone. Read the result
# with Content. Positions count characters, not bytes, so Hebrew, Arabic and emoji text is cut where
# you expect. A position out of range changes nothing without any error. Found today:
# InsertAfterNth, InsertAfterFirst and InsertAfterLast put the new fragment in a wrong place when
# the fragment they look for is absent; InsertBetweenSubStrings replaces the text between the bounds
# instead of inserting; InsertSubStringBetweenPositions uses only the smaller position; and the two
# ManyPositions verbs raise R13 for every valid list.
#
#   receiver   o1 = StzStringInserterQ("banana")
#   example    o1.InsertAfterSubString("an", "-")
#              ? o1.Content()
#              #--> ban-an-a
#              o2 = StzStringInserterQ("שלום עולם")
#              o2.InsertBefore(6, "!")
#              ? o2.Content()
#              #--> שלום !עולם
#              o3 = StzStringInserterQ("a😀b")
#              ? o3.InsertedAfterFirst("😀", "-")
#              #--> a😀-b
#   see        stzString, stzStringRemover, stzStringReplacer
class stzStringInserter from stzObject

	@oString

	# Builds an inserter over a text, given as a string or as a stzString object.
	#
	#   pStrOrStzStrObj   the text to edit, or a stzString whose content is edited
	#   returns           nothing; the object is built
	#   note              the edit goes to the held text; read it with Content; stzString builds one
	#                     over itself for its insertions
	#   see               Content, InsertBefore
	def init(pStrOrStzStrObj)
		if isString(pStrOrStzStrObj)
			@oString = new stzString(pStrOrStzStrObj)
		but isObject(pStrOrStzStrObj)
			@oString = pStrOrStzStrObj
		else
			StzRaise("Can't create stzStringInserter! Parameter must be a string or stzString object.")
		ok

	# Returns the text as it stands now, after the insertions made so far.
	#
	#   returns    a text
	#   see        NumberOfChars, IsEmpty
	def Content()
		return @oString.Content()

	# Returns how many characters the text holds, counting a Hebrew letter or an emoji as one.
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
	 #   INSERTING BEFORE / AFTER A POSITION                #
	#======================================================#

	# Inserts a fragment in front of the character at a position, in place.
	#
	#   _n_        the 1-based position of the character the fragment goes in front of
	#   pcSubStr   the fragment to insert
	#   returns    nothing; the text changes. InsertBeforeQ returns the inserter for chaining
	#   note       banana with 4 and - gives ban-ana; positions count characters, so Hebrew, Arabic
	#              and emoji text is cut where you expect
	#   warning    a position below 1 or past the end plus one changes nothing and raises no error
	#   see        InsertAfter, InsertBeforePosition, InsertBeforeManyPositions
	def InsertBefore(_n_, pcSubStr)
		_nLen_ = @oString.NumberOfChars()
		if _n_ < 1 or _n_ > _nLen_ + 1
			return
		ok
		if _n_ = 1
			@oString.Update(pcSubStr + @oString.Content())
			return
		ok
		if _n_ = _nLen_ + 1
			@oString.Update(@oString.Content() + pcSubStr)
			return
		ok
		_cLeft_ = @oString.Section(1, _n_ - 1)
		_cRight_ = @oString.Section(_n_, _nLen_)
		@oString.Update(_cLeft_ + pcSubStr + _cRight_)

		def InsertBeforeQ(_n_, pcSubStr)
			This.InsertBefore(_n_, pcSubStr)
			return This

		# Inserts a fragment in front of the character at a position, in place.
		#
		#   _n_        the 1-based position of the character the fragment goes in front of
		#   pcSubStr   the fragment to insert
		#   returns    nothing; the text changes
		#   note       the same call as InsertBefore
		#   warning    a position below 1 or past the end plus one changes nothing and raises no
		#              error
		#   see        InsertBefore, InsertAfterPosition
		def InsertBeforePosition(_n_, pcSubStr)
			This.InsertBefore(_n_, pcSubStr)

	# Inserts a fragment right after the character at a position, in place.
	#
	#   _n_        the 1-based position of the character the fragment goes after
	#   pcSubStr   the fragment to insert
	#   returns    nothing; the text changes. InsertAfterQ returns the inserter for chaining
	#   note       banana with 3 and - gives ban-ana; with 0 it gives -banana
	#   warning    a position below 0 or past the last character changes nothing and raises no error
	#   see        InsertBefore, InsertAfterPosition, InsertAfterManyPositions
	def InsertAfter(_n_, pcSubStr)
		This.InsertBefore(_n_ + 1, pcSubStr)

		def InsertAfterQ(_n_, pcSubStr)
			This.InsertAfter(_n_, pcSubStr)
			return This

		# Inserts a fragment right after the character at a position, in place.
		#
		#   _n_        the 1-based position of the character the fragment goes after
		#   pcSubStr   the fragment to insert
		#   returns    nothing; the text changes
		#   note       the same call as InsertAfter
		#   warning    a position below 0 or past the last character changes nothing and raises no
		#              error
		#   see        InsertAfter, InsertBeforePosition
		def InsertAfterPosition(_n_, pcSubStr)
			This.InsertAfter(_n_, pcSubStr)

	  #======================================================#
	 #   INSERTING BEFORE / AFTER ALL OCCURRENCES           #
	#======================================================#

	def InsertBeforeSubStringCS(pcSubStr, pcNewSubStr, pCaseSensitive)
		_bCase_ = @CaseSensitive(pCaseSensitive)
		_pH_ = @oString.Engine()
		pResult = StzEngineStringInsertBeforeEachCS(_pH_, pcSubStr, pcNewSubStr, _bCase_)
		@oString.Update(StzEngineStringData(pResult))
		StzEngineStringFree(pResult)

		def InsertBeforeSubStringCSQ(pcSubStr, pcNewSubStr, pCaseSensitive)
			This.InsertBeforeSubStringCS(pcSubStr, pcNewSubStr, pCaseSensitive)
			return This

	# Inserts a new fragment in front of every occurrence of a fragment, in place.
	#
	#   pcSubStr      the fragment to look for
	#   pcNewSubStr   the fragment to insert in front of each occurrence
	#   returns       nothing; the text changes. InsertBeforeSubStringCSQ returns the inserter for
	#                 chaining
	#   note          banana with an and _ gives b_an_ana; the search is case-sensitive, and
	#                 InsertBeforeSubStringCS(sub, new, 0) ignores case; overlapping occurrences
	#                 count once
	#   see           InsertAfterSubString, InsertBeforeFirst
	def InsertBeforeSubString(pcSubStr, pcNewSubStr)
		This.InsertBeforeSubStringCS(pcSubStr, pcNewSubStr, 1)

	def InsertAfterSubStringCS(pcSubStr, pcNewSubStr, pCaseSensitive)
		_bCase_ = @CaseSensitive(pCaseSensitive)
		_pH_ = @oString.Engine()
		pResult = StzEngineStringInsertAfterEachCS(_pH_, pcSubStr, pcNewSubStr, _bCase_)
		@oString.Update(StzEngineStringData(pResult))
		StzEngineStringFree(pResult)

		def InsertAfterSubStringCSQ(pcSubStr, pcNewSubStr, pCaseSensitive)
			This.InsertAfterSubStringCS(pcSubStr, pcNewSubStr, pCaseSensitive)
			return This

	# Inserts a new fragment right after every occurrence of a fragment, in place.
	#
	#   pcSubStr      the fragment to look for
	#   pcNewSubStr   the fragment to insert after each occurrence
	#   returns       nothing; the text changes. InsertAfterSubStringCSQ returns the inserter for
	#                 chaining
	#   note          banana with an and _ gives ban_an_a; ana in banana gives bana_na, one
	#                 insertion, since the second ana overlaps the first;
	#                 InsertAfterSubStringCS(sub, new, 0) ignores case
	#   see           InsertBeforeSubString, InsertAfterFirst
	def InsertAfterSubString(pcSubStr, pcNewSubStr)
		This.InsertAfterSubStringCS(pcSubStr, pcNewSubStr, 1)

	  #======================================================#
	 #   INSERTING AFTER NTH OCCURRENCE                     #
	#======================================================#

	def InsertAfterNthCS(_n_, pcSubStr, pcNewSubStr, pCaseSensitive)
		_oFinder_ = new stzStringFinder(@oString)
		_nPos_ = _oFinder_.FindNthCS(_n_, pcSubStr, pCaseSensitive)
		This.InsertAfterPosition(_nPos_ + StzLen(pcSubStr) - 1, pcNewSubStr)

		def InsertAfterNthCSQ(_n_, pcSubStr, pcNewSubStr, pCaseSensitive)
			This.InsertAfterNthCS(_n_, pcSubStr, pcNewSubStr, pCaseSensitive)
			return This

	def InsertedAfterNthCS(_n_, pcSubStr, pcNewSubStr, pCaseSensitive)
		_oCopy_ = new stzStringInserter(@oString.Content())
		_oCopy_.InsertAfterNthCSQ(_n_, pcSubStr, pcNewSubStr, pCaseSensitive)
		return _oCopy_.Content()

	# Inserts a new fragment right after the nth occurrence of a fragment, in place.
	#
	#   _n_           the rank of the occurrence, 1 for the first
	#   pcSubStr      the fragment to look for
	#   pcNewSubStr   the fragment to insert
	#   returns       nothing; the text changes. InsertAfterNthQ returns the inserter for chaining
	#   note          banana with rank 2 of a and - gives bana-na; InsertAfterNthCS(n, sub, new, 0)
	#                 ignores case
	#   warning       when the occurrence does not exist (a fragment that is absent, or a rank past
	#                 the last one) the new fragment lands in a wrong place instead of nowhere:
	#                 after the character that is one short of the fragment's length, so at the very
	#                 start for a one-character fragment (banana with rank 9 of an gives -banana,
	#                 and zz absent gives b-anana)
	#   see           InsertedAfterNth, InsertBeforeNth, InsertAfterFirst
	def InsertAfterNth(_n_, pcSubStr, pcNewSubStr)
		This.InsertAfterNthCS(_n_, pcSubStr, pcNewSubStr, 1)

		def InsertAfterNthQ(_n_, pcSubStr, pcNewSubStr)
			This.InsertAfterNth(_n_, pcSubStr, pcNewSubStr)
			return This

	# Returns the text with a new fragment inserted right after the nth occurrence of a fragment, leaving the inserter unchanged.
	#
	#   _n_           the rank of the occurrence, 1 for the first
	#   pcSubStr      the fragment to look for
	#   pcNewSubStr   the fragment to insert
	#   returns       a text
	#   note          banana with rank 2 of a and - gives bana-na
	#   warning       an occurrence that does not exist puts the new fragment in a wrong place, as
	#                 InsertAfterNth does (zz absent in banana gives b-anana)
	#   see           InsertAfterNth, InsertedBeforeNth
	def InsertedAfterNth(_n_, pcSubStr, pcNewSubStr)
		_oCopy_ = new stzStringInserter(@oString.Content())
		_oCopy_.InsertAfterNthQ(_n_, pcSubStr, pcNewSubStr)
		return _oCopy_.Content()

	  #======================================================#
	 #   INSERTING AFTER FIRST / LAST OCCURRENCE            #
	#======================================================#

	def InsertAfterFirstCS(pcSubStr, pcNewSubStr, pCaseSensitive)
		_oFinder_ = new stzStringFinder(@oString)
		_nPos_ = _oFinder_.FindFirstCS(pcSubStr, pCaseSensitive)
		This.InsertAfterPosition(_nPos_ + StzLen(pcSubStr) - 1, pcNewSubStr)

		def InsertAfterFirstCSQ(pcSubStr, pcNewSubStr, pCaseSensitive)
			This.InsertAfterFirstCS(pcSubStr, pcNewSubStr, pCaseSensitive)
			return This

	# Inserts a new fragment right after the first occurrence of a fragment, in place.
	#
	#   pcSubStr      the fragment to look for
	#   pcNewSubStr   the fragment to insert
	#   returns       nothing; the text changes. InsertAfterFirstQ returns the inserter for chaining
	#   note          banana with an and - gives ban-ana; InsertAfterFirstCS(sub, new, 0) ignores
	#                 case
	#   warning       when the fragment is absent the new one lands in a wrong place instead of
	#                 nowhere: banana with zz gives b-anana and with z gives -banana
	#   see           InsertedAfterFirst, InsertAfterLast, InsertBeforeFirst
	def InsertAfterFirst(pcSubStr, pcNewSubStr)
		This.InsertAfterFirstCS(pcSubStr, pcNewSubStr, 1)

		def InsertAfterFirstQ(pcSubStr, pcNewSubStr)
			This.InsertAfterFirst(pcSubStr, pcNewSubStr)
			return This

	def InsertedAfterFirstCS(pcSubStr, pcNewSubStr, pCaseSensitive)
		_oCopy_ = new stzStringInserter(@oString.Content())
		_oCopy_.InsertAfterFirstCSQ(pcSubStr, pcNewSubStr, pCaseSensitive)
		return _oCopy_.Content()

	# Returns the text with a new fragment inserted right after the first occurrence of a fragment, leaving the inserter unchanged.
	#
	#   pcSubStr      the fragment to look for
	#   pcNewSubStr   the fragment to insert
	#   returns       a text
	#   note          banana with an and - gives ban-ana
	#   warning       an absent fragment puts the new one in a wrong place, as InsertAfterFirst does
	#   see           InsertAfterFirst, InsertedAfterLast
	def InsertedAfterFirst(pcSubStr, pcNewSubStr)
		return This.InsertedAfterFirstCS(pcSubStr, pcNewSubStr, 1)

	#--

	def InsertAfterLastCS(pcSubStr, pcNewSubStr, pCaseSensitive)
		_oFinder_ = new stzStringFinder(@oString)
		_nPos_ = _oFinder_.FindLastCS(pcSubStr, pCaseSensitive)
		This.InsertAfterPosition(_nPos_ + StzLen(pcSubStr) - 1, pcNewSubStr)

		def InsertAfterLastCSQ(pcSubStr, pcNewSubStr, pCaseSensitive)
			This.InsertAfterLastCS(pcSubStr, pcNewSubStr, pCaseSensitive)
			return This

	# Inserts a new fragment right after the last occurrence of a fragment, in place.
	#
	#   pcSubStr      the fragment to look for
	#   pcNewSubStr   the fragment to insert
	#   returns       nothing; the text changes. InsertAfterLastQ returns the inserter for chaining
	#   note          banana with an and - gives banan-a; InsertAfterLastCS(sub, new, 0) ignores
	#                 case
	#   warning       when the fragment is absent the new one lands in a wrong place instead of
	#                 nowhere: banana with zz gives b-anana
	#   see           InsertedAfterLast, InsertAfterFirst, InsertBeforeLast
	def InsertAfterLast(pcSubStr, pcNewSubStr)
		This.InsertAfterLastCS(pcSubStr, pcNewSubStr, 1)

		def InsertAfterLastQ(pcSubStr, pcNewSubStr)
			This.InsertAfterLast(pcSubStr, pcNewSubStr)
			return This

	def InsertedAfterLastCS(pcSubStr, pcNewSubStr, pCaseSensitive)
		_oCopy_ = new stzStringInserter(@oString.Content())
		_oCopy_.InsertAfterLastCSQ(pcSubStr, pcNewSubStr, pCaseSensitive)
		return _oCopy_.Content()

	# Returns the text with a new fragment inserted right after the last occurrence of a fragment, leaving the inserter unchanged.
	#
	#   pcSubStr      the fragment to look for
	#   pcNewSubStr   the fragment to insert
	#   returns       a text
	#   note          banana with an and - gives banan-a
	#   warning       an absent fragment puts the new one in a wrong place, as InsertAfterLast does
	#   see           InsertAfterLast, InsertedAfterFirst
	def InsertedAfterLast(pcSubStr, pcNewSubStr)
		return This.InsertedAfterLastCS(pcSubStr, pcNewSubStr, 1)

	  #======================================================#
	 #   INSERTING BEFORE NTH OCCURRENCE                    #
	#======================================================#

	def InsertBeforeNthCS(_n_, pcSubStr, pcNewSubStr, pCaseSensitive)
		_oFinder_ = new stzStringFinder(@oString)
		_nPos_ = _oFinder_.FindNthCS(_n_, pcSubStr, pCaseSensitive)
		This.InsertBefore(_nPos_, pcNewSubStr)

		def InsertBeforeNthCSQ(_n_, pcSubStr, pcNewSubStr, pCaseSensitive)
			This.InsertBeforeNthCS(_n_, pcSubStr, pcNewSubStr, pCaseSensitive)
			return This

	def InsertedBeforeNthCS(_n_, pcSubStr, pcNewSubStr, pCaseSensitive)
		_oCopy_ = new stzStringInserter(@oString.Content())
		_oCopy_.InsertBeforeNthCSQ(_n_, pcSubStr, pcNewSubStr, pCaseSensitive)
		return _oCopy_.Content()

	# Inserts a new fragment in front of the nth occurrence of a fragment, in place.
	#
	#   _n_           the rank of the occurrence, 1 for the first
	#   pcSubStr      the fragment to look for
	#   pcNewSubStr   the fragment to insert
	#   returns       nothing; the text changes. InsertBeforeNthQ returns the inserter for chaining
	#   note          banana with rank 2 of an and - gives ban-ana; an occurrence that does not
	#                 exist changes nothing; InsertBeforeNthCS(n, sub, new, 0) ignores case
	#   see           InsertedBeforeNth, InsertAfterNth, InsertBeforeFirst
	def InsertBeforeNth(_n_, pcSubStr, pcNewSubStr)
		This.InsertBeforeNthCS(_n_, pcSubStr, pcNewSubStr, 1)

		def InsertBeforeNthQ(_n_, pcSubStr, pcNewSubStr)
			This.InsertBeforeNth(_n_, pcSubStr, pcNewSubStr)
			return This

	# Returns the text with a new fragment inserted in front of the nth occurrence of a fragment, leaving the inserter unchanged.
	#
	#   _n_           the rank of the occurrence, 1 for the first
	#   pcSubStr      the fragment to look for
	#   pcNewSubStr   the fragment to insert
	#   returns       a text
	#   note          an occurrence that does not exist returns the text as it is
	#   see           InsertBeforeNth, InsertedAfterNth
	def InsertedBeforeNth(_n_, pcSubStr, pcNewSubStr)
		_oCopy_ = new stzStringInserter(@oString.Content())
		_oCopy_.InsertBeforeNthQ(_n_, pcSubStr, pcNewSubStr)
		return _oCopy_.Content()

	  #======================================================#
	 #   INSERTING BEFORE FIRST / LAST OCCURRENCE           #
	#======================================================#

	def InsertBeforeFirstCS(pcSubStr, pcNewSubStr, pCaseSensitive)
		_oFinder_ = new stzStringFinder(@oString)
		_nPos_ = _oFinder_.FindFirstCS(pcSubStr, pCaseSensitive)
		This.InsertBefore(_nPos_, pcNewSubStr)

		def InsertBeforeFirstCSQ(pcSubStr, pcNewSubStr, pCaseSensitive)
			This.InsertBeforeFirstCS(pcSubStr, pcNewSubStr, pCaseSensitive)
			return This

	# Inserts a new fragment in front of the first occurrence of a fragment, in place.
	#
	#   pcSubStr      the fragment to look for
	#   pcNewSubStr   the fragment to insert
	#   returns       nothing; the text changes. InsertBeforeFirstQ returns the inserter for
	#                 chaining
	#   note          banana with an and - gives b-anana; an absent fragment changes nothing;
	#                 InsertBeforeFirstCS(sub, new, 0) ignores case
	#   see           InsertedBeforeFirst, InsertBeforeLast, InsertAfterFirst
	def InsertBeforeFirst(pcSubStr, pcNewSubStr)
		This.InsertBeforeFirstCS(pcSubStr, pcNewSubStr, 1)

		def InsertBeforeFirstQ(pcSubStr, pcNewSubStr)
			This.InsertBeforeFirst(pcSubStr, pcNewSubStr)
			return This

	def InsertedBeforeFirstCS(pcSubStr, pcNewSubStr, pCaseSensitive)
		_oCopy_ = new stzStringInserter(@oString.Content())
		_oCopy_.InsertBeforeFirstCSQ(pcSubStr, pcNewSubStr, pCaseSensitive)
		return _oCopy_.Content()

	# Returns the text with a new fragment inserted in front of the first occurrence of a fragment, leaving the inserter unchanged.
	#
	#   pcSubStr      the fragment to look for
	#   pcNewSubStr   the fragment to insert
	#   returns       a text
	#   note          an absent fragment returns the text as it is
	#   see           InsertBeforeFirst, InsertedBeforeLast
	def InsertedBeforeFirst(pcSubStr, pcNewSubStr)
		return This.InsertedBeforeFirstCS(pcSubStr, pcNewSubStr, 1)

	#--

	def InsertBeforeLastCS(pcSubStr, pcNewSubStr, pCaseSensitive)
		_oFinder_ = new stzStringFinder(@oString)
		_nPos_ = _oFinder_.FindLastCS(pcSubStr, pCaseSensitive)
		This.InsertBefore(_nPos_, pcNewSubStr)

		def InsertBeforeLastCSQ(pcSubStr, pcNewSubStr, pCaseSensitive)
			This.InsertBeforeLastCS(pcSubStr, pcNewSubStr, pCaseSensitive)
			return This

	# Inserts a new fragment in front of the last occurrence of a fragment, in place.
	#
	#   pcSubStr      the fragment to look for
	#   pcNewSubStr   the fragment to insert
	#   returns       nothing; the text changes. InsertBeforeLastQ returns the inserter for chaining
	#   note          banana with an and - gives ban-ana; an absent fragment changes nothing;
	#                 InsertBeforeLastCS(sub, new, 0) ignores case
	#   see           InsertedBeforeLast, InsertBeforeFirst, InsertAfterLast
	def InsertBeforeLast(pcSubStr, pcNewSubStr)
		This.InsertBeforeLastCS(pcSubStr, pcNewSubStr, 1)

		def InsertBeforeLastQ(pcSubStr, pcNewSubStr)
			This.InsertBeforeLast(pcSubStr, pcNewSubStr)
			return This

	def InsertedBeforeLastCS(pcSubStr, pcNewSubStr, pCaseSensitive)
		_oCopy_ = new stzStringInserter(@oString.Content())
		_oCopy_.InsertBeforeLastCSQ(pcSubStr, pcNewSubStr, pCaseSensitive)
		return _oCopy_.Content()

	# Returns the text with a new fragment inserted in front of the last occurrence of a fragment, leaving the inserter unchanged.
	#
	#   pcSubStr      the fragment to look for
	#   pcNewSubStr   the fragment to insert
	#   returns       a text
	#   note          an absent fragment returns the text as it is
	#   see           InsertBeforeLast, InsertedBeforeFirst
	def InsertedBeforeLast(pcSubStr, pcNewSubStr)
		return This.InsertedBeforeLastCS(pcSubStr, pcNewSubStr, 1)

	  #======================================================#
	 #   INSERTING BETWEEN TWO POSITIONS                    #
	#======================================================#

	# Inserts a fragment right after the smaller of two positions, in place.
	#
	#   pcSubStr   the fragment to insert
	#   _n1_       the first position
	#   _n2_       the second position, which only orders the pair
	#   returns    nothing; the text changes
	#   note       meant for two neighbouring positions
	#   warning    the second position is never used to place the fragment: banana with 2 and 5
	#              gives ba-nana, and giving 5 then 2 gives the same text
	#   see        InsertAfter, InsertBetweenSubStrings
	def InsertSubStringBetweenPositions(pcSubStr, _n1_, _n2_)
		if CheckingParams()
			if NOT isString(pcSubStr)
				StzRaise("Incorrect param type! pcSubStr must be a string.")
			ok
			if isList(_n2_) and IsAndNamedParamList(_n2_)
				_n2_ = _n2_[2]
			ok
			if NOT (isNumber(_n1_) and isNumber(_n2_))
				StzRaise("Incorrect params types! n1 and n2 must be both numbers.")
			ok
		ok

		if _n1_ > _n2_
			_nTemp_ = _n1_
			_n1_ = _n2_
			_n2_ = _nTemp_
		ok

		This.InsertAfter(_n1_, pcSubStr)

		# Inserts a fragment right after the smaller of two positions, in place.
		#
		#   pcSubStr   the fragment to insert
		#   _n1_       the first position
		#   _n2_       the second position, which only orders the pair
		#   returns    nothing; the text changes
		#   note       the same call as InsertSubStringBetweenPositions
		#   warning    the second position is never used to place the fragment: banana with 1 and 6
		#              gives b-anana
		#   see        InsertSubStringBetweenPositions, InsertAfter
		def InsertBetween(pcSubStr, _n1_, _n2_)
			This.InsertSubStringBetweenPositions(pcSubStr, _n1_, _n2_)

		# Inserts a fragment right after the smaller of two positions, in place.
		#
		#   pcSubStr   the fragment to insert
		#   _n1_       the first position
		#   _n2_       the second position, which only orders the pair
		#   returns    nothing; the text changes
		#   note       the same call as InsertSubStringBetweenPositions
		#   warning    the second position is never used to place the fragment
		#   see        InsertSubStringBetweenPositions, InsertAfter
		def InsertBetweenPositions(pcSubStr, _n1_, _n2_)
			This.InsertSubStringBetweenPositions(pcSubStr, _n1_, _n2_)

	  #======================================================#
	 #   INSERTING BETWEEN TWO SUBSTRINGS                   #
	#======================================================#

	def InsertSubStringBetweenSubStringsCS(pcSubStr, pcSubStr1, pcSubStr2, pCaseSensitive)
		if CheckingParams()
			if NOT (isString(pcSubStr) and isString(pcSubStr1) and isString(pcSubStr2))
				StzRaise("Incorrect param types! pcSubStr, pcSubStr1, pcSubStr2 must be all strings.")
			ok
		ok

		if pcSubStr = "" or pcSubStr1 = "" or pcSubStr2 = ""
			return
		ok

		_oFinder_ = new stzStringFinder(@oString)
		_aSections_ = _oFinder_.FindAnyBoundedByAsSectionsCS([pcSubStr1, pcSubStr2], pCaseSensitive)
		@oString.ReplaceSections(_aSections_, pcSubStr)

		def InsertBetweenSubStringsCS(pcSubStr, pcSubStr1, pcSubStr2, pCaseSensitive)
			This.InsertSubStringBetweenSubStringsCS(pcSubStr, pcSubStr1, pcSubStr2, pCaseSensitive)

	# Replaces what lies between each opening and closing bound with a new fragment, in place.
	#
	#   pcSubStr    the fragment that takes the place of the text between the bounds
	#   pcSubStr1   the opening bound
	#   pcSubStr2   the closing bound
	#   returns     nothing; the text changes
	#   note        InsertSubStringBetweenSubStringsCS(new, open, close, 0) ignores case
	#   warning     it replaces and does not insert: the text that was between the bounds is lost
	#               (f(x) g(y) with - between ( and ) gives f(-) g(-)); an empty argument or absent
	#               bounds change nothing
	#   see         InsertAfterSubString, InsertBetweenSubStrings
	def InsertSubStringBetweenSubStrings(pcSubStr, pcSubStr1, pcSubStr2)
		This.InsertSubStringBetweenSubStringsCS(pcSubStr, pcSubStr1, pcSubStr2, 1)

		# Replaces what lies between each opening and closing bound with a new fragment, in place.
		#
		#   pcSubStr    the fragment that takes the place of the text between the bounds
		#   pcSubStr1   the opening bound
		#   pcSubStr2   the closing bound
		#   returns     nothing; the text changes
		#   note        the same call as InsertSubStringBetweenSubStrings
		#   warning     it replaces and does not insert: [a] [b] with - between [ and ] gives [-]
		#               [-]
		#   see         InsertSubStringBetweenSubStrings
		def InsertBetweenSubStrings(pcSubStr, pcSubStr1, pcSubStr2)
			This.InsertSubStringBetweenSubStrings(pcSubStr, pcSubStr1, pcSubStr2)

	  #======================================================#
	 #   INSERTING AT MANY POSITIONS                        #
	#======================================================#

	# Raises error R13 today instead of inserting a fragment after each of several positions.
	#
	#   pcSubStr   the fragment to insert
	#   panPos     the list of positions to insert after
	#   returns    nothing
	#   note       use InsertAfter once per position, from the last position to the first
	#   warning    raises Object is required (R13) for every valid list of numbers: [1,3,5] on
	#              banana and [2] on abc; probable cause the line that sorts the positions with new
	#              stzList(panPos).SortedInDescending(), since the same call made in two statements
	#              works; an empty or non-numeric list raises Incorrect param type instead
	#   see        InsertBeforeManyPositions, InsertAfter
	def InsertAfterManyPositions(pcSubStr, panPos)
		if CheckingParams()
			if NOT isString(pcSubStr)
				StzRaise("Incorrect param type! pcSubStr must be a string.")
			ok
			if NOT (isList(panPos) and @IsListOfNumbers(panPos))
				StzRaise("Incorrect param type! panPos must be a list of numbers.")
			ok
		ok

		_aSorted_ = new stzList(panPos).SortedInDescending()
		_nSorted2Len_ = len(_aSorted_)
		for _iLoopSorted2_ = 1 to _nSorted2Len_
			_n_ = _aSorted_[_iLoopSorted2_]
			This.InsertAfter(_n_, pcSubStr)
		next

		def InsertAfterManyPositionsQ(pcSubStr, panPos)
			This.InsertAfterManyPositions(pcSubStr, panPos)
			return This

	# Raises error R13 today instead of inserting a fragment in front of each of several positions.
	#
	#   pcSubStr   the fragment to insert
	#   panPos     the list of positions to insert in front of
	#   returns    nothing
	#   note       use InsertBefore once per position, from the last position to the first
	#   warning    raises Object is required (R13) for every valid list of numbers: [1,3,5] on
	#              banana; probable cause the line that sorts the positions with new
	#              stzList(panPos).SortedInDescending(); an empty or non-numeric list raises
	#              Incorrect param type instead
	#   see        InsertAfterManyPositions, InsertBefore
	def InsertBeforeManyPositions(pcSubStr, panPos)
		if CheckingParams()
			if NOT isString(pcSubStr)
				StzRaise("Incorrect param type! pcSubStr must be a string.")
			ok
			if NOT (isList(panPos) and @IsListOfNumbers(panPos))
				StzRaise("Incorrect param type! panPos must be a list of numbers.")
			ok
		ok

		_aSorted_ = new stzList(panPos).SortedInDescending()
		_nSorted1Len_ = len(_aSorted_)
		for _iLoopSorted1_ = 1 to _nSorted1Len_
			_n_ = _aSorted_[_iLoopSorted1_]
			This.InsertBefore(_n_, pcSubStr)
		next

		def InsertBeforeManyPositionsQ(pcSubStr, panPos)
			This.InsertBeforeManyPositions(pcSubStr, panPos)
			return This
