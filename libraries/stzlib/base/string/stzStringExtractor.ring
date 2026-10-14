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


# Cuts pieces out of a text: a section, a run, a character or an occurrence of a substring, returning each piece and removing it.
#
# Build one with new stzStringExtractor("text"). Every Extract verb answers the piece and takes it
# out of the text the extractor holds, which Content shows. Positions count from 1 and are in
# characters, so Hebrew, Arabic and emoji are cut by letter. A section must have its start before
# its end: a reversed pair kills the process or removes nothing today. Extract(substr) returns the
# whole text before removal, not the part removed, and ExtractCharsW raises an error after removing;
# see their warnings. Do not pass a stzString object you still need: the first extraction empties
# it.
#
#   receiver   o1 = new stzStringExtractor("hello world, hello moon")
#   example    ? o1.ExtractSection(1, 5)
#              #--> hello
#              ? o1.NumberOfChars()
#              #--> 18
#              ? o1.ExtractLastChar()
#              #--> n
#              ? o1.ExtractLast("hello")
#              #--> hello
#   see        stzString, stzStringReplacer, stzStringSections
class stzStringExtractor from stzObject

	@oString

	# Builds an extractor over a text or over a stzString object; every Extract verb answers the piece and removes it from the text held.
	#
	#   pStrOrStzStrObj   a text, or a stzString object, to cut pieces out of
	#   returns           nothing; the object is built
	#   note              any other kind of value raises "Can't create stzStringExtractor! Parameter
	#                     must be a string or stzString object."
	#   warning           Given a stzString object, the first extraction leaves that stzString EMPTY
	#                     while the extractor holds the rest: after oe.ExtractSection(1, 5) on a
	#                     stzString "hello world", oe.Content() answers " world" and the stzString
	#                     answers "". Pass the text, os.Content(), to be safe
	#   see               ExtractSection, Content
	def init(pStrOrStzStrObj)
		if isString(pStrOrStzStrObj)
			@oString = new stzString(pStrOrStzStrObj)
		but isObject(pStrOrStzStrObj)
			@oString = pStrOrStzStrObj
		else
			StzRaise("Can't create stzStringExtractor! Parameter must be a string or stzString object.")
		ok

	# Returns the text that remains after the extractions made so far.
	#
	#   returns    a text
	#   see        ExtractAll
	def Content()
		return @oString.Content()

	# Returns how many characters the text holds now, counting letters and not bytes.
	#
	#   returns    a number
	#   see        Content
	def NumberOfChars()
		return @oString.NumberOfChars()

	# TRUE if nothing is left in the text.
	#
	#   returns    TRUE or FALSE
	#   see        ExtractAll
	def IsEmpty()
		return @oString.IsEmpty()

	  #======================================================#
	 #   EXTRACTING A SECTION                               #
	#======================================================#

	# Removes the characters from one position to another, both included, and returns them.
	#
	#   n1         the first position, from 1
	#   n2         the last position, from 1
	#   returns    the extracted text
	#   note       give n1 not larger than n2
	#   warning    A start after the end kills the process: ExtractSection(5, 2) and
	#              ExtractSection(6, 1) on "abcdef" stop it with a panic in stz_string.dll; with a
	#              gap of one, ExtractSection(2, 1), the text of the swapped section is returned and
	#              nothing is removed; a position outside the text raises "Indexes out of range!"
	#   see        ExtractRange, ExtractAt
	def ExtractSection(n1, n2)
		_cResult_ = @oString.Section(n1, n2)
		@oString.RemoveSection(n1, n2)
		return _cResult_

	  #======================================================#
	 #   EXTRACTING A RANGE                                 #
	#======================================================#

	# Removes a run of characters given by its start and its length, and returns them.
	#
	#   pnStart    the first position, from 1
	#   pnRange    how many characters
	#   returns    the extracted text
	#   note       the Hebrew "שלום עולם" cut at 1 for 3 gives "שלו"
	#   warning    A length of 0 gives the one-gap case of ExtractSection: ExtractRange(2, 0)
	#              returns "ab" and removes nothing; a negative length or a run past the end raises
	#              "Indexes out of range!"
	#   see        ExtractSection, ExtractAt
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

	# Removes every occurrence of a substring from the text held, case-sensitively, and returns the text as it was BEFORE the removal.
	#
	#   pcSubStr   the substring to remove
	#   returns    the whole text as it stood before, not the substring
	#   note       ExtractCS(pcSubStr, 0) ignores case
	#   warning    The answer is the full original text, not the part removed: Extract("one") on
	#              "one two one three one" answers that whole text and leaves " two  three "; use
	#              ExtractFirst, ExtractLast or ExtractNthOccurrence to get the piece
	#   see        ExtractFirst, ExtractNthOccurrence
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

	# Returns the whole text and leaves the text held empty.
	#
	#   returns    the whole text
	#   see        Content, IsEmpty
	def ExtractAll()
		_cResult_ = @oString.Content()
		@oString.Update("")
		return _cResult_

	  #======================================================#
	 #   EXTRACTING CHAR AT POSITION                        #
	#======================================================#

	# Removes the single character at a position and returns it.
	#
	#   _n_        the position, from 1
	#   returns    a one-character text
	#   note       a position outside the text raises "Indexes out of range!"; ExtractCharAt is the
	#              same method
	#   see        ExtractFirstChar, ExtractLastChar, ExtractSection
	def ExtractAt(_n_)
		return This.ExtractSection(_n_, _n_)

		def ExtractCharAt(_n_)
			return This.ExtractAt(_n_)

	  #======================================================#
	 #   EXTRACTING FIRST / LAST CHAR                       #
	#======================================================#

	# Removes the first character and returns it.
	#
	#   returns    a one-character text
	#   note       on an empty text it raises "Indexes out of range!"
	#   see        ExtractAt, ExtractLastChar
	def ExtractFirstChar()
		return This.ExtractAt(1)

	# Removes the last character and returns it.
	#
	#   returns    a one-character text
	#   note       "ب" is one character, not two bytes; an empty text raises "Indexes out of range!"
	#   see        ExtractAt, ExtractFirstChar
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

	# Removes the nth occurrence of a substring, case-sensitively, and returns that substring.
	#
	#   _n_        which occurrence, from 1
	#   pcSubStr   the substring to cut out
	#   returns    the substring; an empty text when it is absent
	#   note       ExtractNthOccurrenceCS(n, pcSubStr, 0) ignores case; "a-b-c-b-d", 2nd "b" leaves
	#              "a-b-c--d"
	#   warning    an n larger than the number of occurrences raises "Indexes out of range!" instead
	#              of answering an empty text
	#   see        ExtractFirst, ExtractLast
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

	# Removes the first occurrence of a substring, case-sensitively, and returns it.
	#
	#   pcSubStr   the substring to cut out
	#   returns    the substring; an empty text when it is absent
	#   note       "a-b-c-b" first "b" leaves "a--c-b"
	#   see        ExtractLast, ExtractNthOccurrence
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

	# Removes the last occurrence of a substring, case-sensitively, and returns it.
	#
	#   pcSubStr   the substring to cut out
	#   returns    the substring; an empty text when it is absent
	#   see        ExtractFirst, ExtractNthOccurrence
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

	# Removes every character that meets a W condition and is meant to return them in order.
	#
	#   pcCondition   the W condition as text, where @char stands for the character, such as
	#                 "isDigit(@char)"
	#   returns       nothing today: it raises error R3
	#   note          the removal is done and only the answer is lost
	#   warning       Raises error R3 "Calling Function without definition: listreversed" today
	#                 instead of returning the characters, and by then the characters are already
	#                 removed from the text: "a1b2" with "isDigit(@char)" is left as "ab"
	#   see           ExtractAt
	def ExtractCharsW(pcCondition)
		return This.ExtractCharsWCS(pcCondition, 1)
