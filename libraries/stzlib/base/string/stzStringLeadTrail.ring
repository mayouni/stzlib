#--------------------------------------------------------------#
#        SOFTANZA LIBRARY (V0.9) - STZSTRINGLEADTRAIL          #
#   An accelerative library for Ring applications, and more!   #
#--------------------------------------------------------------#
#                                                              #
#   Description  : String lead/trail subclass -- repeated      #
#                  leading and trailing char operations.       #
#                  For aliases, use stzStringLeadTrailXT.      #
#   Version      : V0.9 (2026)                                 #
#   Author       : Mansour Ayouni (kalidianow@gmail.com)       #
#                                                              #
#--------------------------------------------------------------#


# Looks at the two ends of a text: runs of repeated characters, prefixes and suffixes to test, strip or make sure of.
#
# It is the helper behind the ends-of-a-string methods of stzString (RemoveRepeatedLeadingCharsCS,
# EnsurePrefixCS, RemoveFromStartCS...), which builds one over itself and writes the result back;
# reach for it directly with new stzStringLeadTrail(cText) when you only need the ends. The reads
# (RepeatedLeadingChars, StartsWith, LeadingChar...) answer a text, a number or TRUE or FALSE; the
# verbs (RemoveFromStart, EnsurePrefix, RemoveThisLeadingChar...) change the held text in place and
# return nothing, the Q form returning the helper so calls chain; the past-tense forms
# (RemovedFromStart, PrefixEnsured) return the new text and leave the helper alone. Read the result
# with Content. A run needs at least two identical characters: a single leading character is not
# repeated. Matching is case-sensitive by default; StartsWithCS, EndsWithCS, EnsurePrefixCS and
# EnsureSuffixCS honour a case flag, while RepeatedLeadingCharsCS, RepeatedTrailingCharsCS (and so
# the Has and Number forms built on them) ignore it, and RemoveFromStartCS and RemoveFromEndCS do
# nothing for a flag of 0 when the case differs. Positions count characters, not bytes, so Hebrew,
# Arabic and emoji runs are measured as you expect. Pass a plain text, not a stzString object: an
# in-place edit through the helper empties the stzString that was passed in.
#
#   receiver   o1 = new stzStringLeadTrail("aaabccc")
#   example    ? o1.RepeatedLeadingChars()
#              #--> aaa
#              ? o1.NumberOfRepeatedTrailingChars()
#              #--> 3
#              ? o1.RepeatedLeadingCharsRemoved()
#              #--> abccc
#              o2 = new stzStringLeadTrail("example.com")
#              o2.EnsurePrefix("https://")
#              ? o2.Content()
#              #--> https://example.com
#              o3 = new stzStringLeadTrail("םםםשלום!!")
#              ? o3.NumberOfRepeatedLeadingChars()
#              #--> 3
#              o4 = new stzStringLeadTrail("😀😀😀ok😀😀")
#              ? o4.RepeatedTrailingCharsRemoved() = "😀😀😀ok😀"
#              #--> 1
#   see        stzString, stzStringBounder, stzStringFormatter
class stzStringLeadTrail from stzObject

	@oString

	# Builds a lead-and-trail helper over a text, given as a string or as a stzString object.
	#
	#   pStrOrStzStrObj   the text to examine or edit, or a stzString whose content is used, any
	#                     other value raises an error
	#   returns           nothing; the object is built
	#   note              pass a plain text and read the result with Content; stzString does it
	#                     safely by writing the helper result back with Update
	#   warning           with a stzString argument, the first in-place edit
	#                     (RemoveRepeatedLeadingChars, RemoveFromStart, EnsurePrefix...) leaves the
	#                     stzString you passed reading as an empty text, while the reads and the
	#                     past-tense forms leave it alone; the helper itself keeps the right text
	#   see               Content, StartsWith
	def init(pStrOrStzStrObj)
		if isString(pStrOrStzStrObj)
			@oString = new stzString(pStrOrStzStrObj)
		but isObject(pStrOrStzStrObj)
			@oString = pStrOrStzStrObj
		else
			StzRaise("Can't create stzStringLeadTrail! Parameter must be a string or stzString object.")
		ok

	# Returns the text as it stands now, after the in-place edits made so far.
	#
	#   returns    a text
	#   see        NumberOfChars, LeadingChar
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
	 #   REPEATED LEADING CHARS                             #
	#======================================================#

	def HasRepeatedLeadingCharsCS(pCaseSensitive)
		return StzLen(This.RepeatedLeadingCharsCS(pCaseSensitive)) > 1

	# TRUE if the text starts with the same character at least twice in a row.
	#
	#   returns    TRUE or FALSE, as 1 or 0
	#   note       aab is TRUE, ab and a are FALSE
	#   warning    the HasRepeatedLeadingCharsCS form ignores its case flag, like
	#              RepeatedLeadingCharsCS
	#   see        RepeatedLeadingChars, HasRepeatedTrailingChars
	def HasRepeatedLeadingChars()
		return This.HasRepeatedLeadingCharsCS(1)

	def RepeatedLeadingCharsCS(pCaseSensitive)
		_acChars_ = @oString.Chars()
		_nLen_ = len(_acChars_)
		if _nLen_ < 2
			return ""
		ok
		_cFirst_ = _acChars_[1]
		_cResult_ = _cFirst_
		for i = 2 to _nLen_
			if _acChars_[i] = _cFirst_
				_cResult_ += _acChars_[i]
			else
				exit
			ok
		next
		_nResultChars_ = StzLen(_cResult_)
		if _nResultChars_ < 2
			return ""
		ok
		return _cResult_

	# Returns the run of identical characters the text starts with, or an empty text when the first character is not repeated.
	#
	#   returns    a text such as aaa; an empty text when the run is a single character
	#   note       the run is returned whole, aaabccc answers aaa
	#   warning    the RepeatedLeadingCharsCS form ignores its case flag: with the flag at 0, xXxy
	#              still answers an empty text, because the comparison is always case-sensitive
	#   see        RepeatedLeadingChar, NumberOfRepeatedLeadingChars, RepeatedTrailingChars
	def RepeatedLeadingChars()
		return This.RepeatedLeadingCharsCS(1)

	# Returns the character that the text starts with when it is repeated, or an empty text otherwise.
	#
	#   returns    a text of one character, or an empty text
	#   note       unlike LeadingChar it answers an empty text for ab, where LeadingChar answers a
	#   see        RepeatedLeadingChars, LeadingChar
	def RepeatedLeadingChar()
		_cLead_ = This.RepeatedLeadingChars()
		if StzLen(_cLead_) > 0
			return @oString.NthChar(1)
		else
			return ""
		ok

	# Returns the length of the run of identical characters at the start, 0 when the first character is not repeated.
	#
	#   returns    a number
	#   note       a single character is not a run, so ab answers 0 and aab answers 2
	#   see        RepeatedLeadingChars, NumberOfRepeatedTrailingChars
	def NumberOfRepeatedLeadingChars()
		return StzLen(This.RepeatedLeadingChars())

	# Returns the first character of the text, repeated or not.
	#
	#   returns    a text of one character; an empty text for an empty text
	#   see        RepeatedLeadingChar, TrailingChar
	def LeadingChar()
		if @oString.NumberOfChars() > 0
			return @oString.NthChar(1)
		ok
		return ""

	  #======================================================#
	 #   REPEATED TRAILING CHARS                            #
	#======================================================#

	def HasRepeatedTrailingCharsCS(pCaseSensitive)
		return StzLen(This.RepeatedTrailingCharsCS(pCaseSensitive)) > 1

	# TRUE if the text ends with the same character at least twice in a row.
	#
	#   returns    TRUE or FALSE, as 1 or 0
	#   warning    the HasRepeatedTrailingCharsCS form ignores its case flag, like
	#              RepeatedTrailingCharsCS
	#   see        RepeatedTrailingChars, HasRepeatedLeadingChars
	def HasRepeatedTrailingChars()
		return This.HasRepeatedTrailingCharsCS(1)

	def RepeatedTrailingCharsCS(pCaseSensitive)
		_acChars_ = @oString.Chars()
		_nLen_ = len(_acChars_)
		if _nLen_ < 2
			return ""
		ok
		_cLast_ = _acChars_[_nLen_]
		_cResult_ = _cLast_
		for i = _nLen_ - 1 to 1 step -1
			if _acChars_[i] = _cLast_
				_cResult_ = _acChars_[i] + _cResult_
			else
				exit
			ok
		next
		_nResultChars_ = StzLen(_cResult_)
		if _nResultChars_ < 2
			return ""
		ok
		return _cResult_

	# Returns the run of identical characters the text ends with, or an empty text when the last character is not repeated.
	#
	#   returns    a text such as ccc; an empty text when the run is a single character
	#   note       the run is returned whole, aaabccc answers ccc
	#   warning    the RepeatedTrailingCharsCS form ignores its case flag: with the flag at 0, yxXx
	#              still answers an empty text, because the comparison is always case-sensitive
	#   see        RepeatedTrailingChar, NumberOfRepeatedTrailingChars, RepeatedLeadingChars
	def RepeatedTrailingChars()
		return This.RepeatedTrailingCharsCS(1)

	# Returns the character that the text ends with when it is repeated, or an empty text otherwise.
	#
	#   returns    a text of one character, or an empty text
	#   see        RepeatedTrailingChars, TrailingChar
	def RepeatedTrailingChar()
		_cTrail_ = This.RepeatedTrailingChars()
		_nTrailLen_ = StzLen(_cTrail_)
		if _nTrailLen_ > 0
			return @oString.NthChar(@oString.NumberOfChars())
		else
			return ""
		ok

	# Returns the length of the run of identical characters at the end, 0 when the last character is not repeated.
	#
	#   returns    a number
	#   see        RepeatedTrailingChars, NumberOfRepeatedLeadingChars
	def NumberOfRepeatedTrailingChars()
		return StzLen(This.RepeatedTrailingChars())

	# Returns the last character of the text, repeated or not.
	#
	#   returns    a text of one character; an empty text for an empty text
	#   see        RepeatedTrailingChar, LeadingChar
	def TrailingChar()
		_nLen_ = @oString.NumberOfChars()
		if _nLen_ > 0
			return @oString.NthChar(_nLen_)
		ok
		return ""

	  #======================================================#
	 #   REMOVING REPEATED LEADING / TRAILING CHARS         #
	#======================================================#

	# Shortens the leading run of identical characters to one character, in place.
	#
	#   returns    nothing; the text changes. RemoveRepeatedLeadingCharsQ returns the helper for
	#              chaining
	#   note       aaabccc becomes abccc; a text without a repeated start is left alone
	#   warning    its CS form RemoveRepeatedLeadingCharsCS is a different call: it removes the
	#              whole run, leaving none, so aaabccc becomes bccc where this method leaves abccc
	#   see        RepeatedLeadingCharsRemoved, RemoveRepeatedTrailingChars, RemoveThisLeadingChar
	def RemoveRepeatedLeadingChars()
		_cLead_ = This.RepeatedLeadingChars()
		_nToRemove_ = StzLen(_cLead_) - 1
		if _nToRemove_ > 0
			@oString.RemoveSection(1, _nToRemove_)
		ok

		def RemoveRepeatedLeadingCharsQ()
			This.RemoveRepeatedLeadingChars()
			return This

	# Returns the text with its leading run of identical characters shortened to one, leaving the helper unchanged.
	#
	#   returns    a text
	#   see        RemoveRepeatedLeadingChars, RepeatedTrailingCharsRemoved
	def RepeatedLeadingCharsRemoved()
		_oCopy_ = new stzStringLeadTrail(@oString.Content())
		_oCopy_.RemoveRepeatedLeadingCharsQ()
		return _oCopy_.Content()

	# Shortens the trailing run of identical characters to one character, in place.
	#
	#   returns    nothing; the text changes. RemoveRepeatedTrailingCharsQ returns the helper for
	#              chaining
	#   note       aaabccc becomes aaabc; a text without a repeated end is left alone
	#   warning    its CS form RemoveRepeatedTrailingCharsCS is a different call: it removes the
	#              whole run, leaving none, so aaabccc becomes aaab where this method leaves aaabc
	#   see        RepeatedTrailingCharsRemoved, RemoveRepeatedLeadingChars, RemoveThisTrailingChar
	#@ aka  --
	def RemoveRepeatedTrailingChars()
		_cTrail_ = This.RepeatedTrailingChars()
		_nToRemove_ = StzLen(_cTrail_) - 1
		_nLen_ = @oString.NumberOfChars()
		if _nToRemove_ > 0
			@oString.RemoveSection(_nLen_ - _nToRemove_ + 1, _nLen_)
		ok

		def RemoveRepeatedTrailingCharsQ()
			This.RemoveRepeatedTrailingChars()
			return This

	# Returns the text with its trailing run of identical characters shortened to one, leaving the helper unchanged.
	#
	#   returns    a text
	#   see        RemoveRepeatedTrailingChars, RepeatedLeadingCharsRemoved
	def RepeatedTrailingCharsRemoved()
		_oCopy_ = new stzStringLeadTrail(@oString.Content())
		_oCopy_.RemoveRepeatedTrailingCharsQ()
		return _oCopy_.Content()

	  #======================================================#
	 #   REMOVING A SPECIFIC LEADING / TRAILING CHAR        #
	#======================================================#

	def RemoveThisLeadingCharCS(_c_, pCaseSensitive)
		_acChars_ = @oString.Chars()
		_nLen_ = len(_acChars_)
		_nStart_ = 1
		for i = 1 to _nLen_
			if BothStringsAreEqualCS(_acChars_[i], _c_, pCaseSensitive)
				_nStart_ = i + 1
			else
				exit
			ok
		next
		if _nStart_ > _nLen_
			@oString.Update("")
		else
			@oString.Update(@oString.Section(_nStart_, _nLen_))
		ok

		def RemoveThisLeadingCharCSQ(_c_, pCaseSensitive)
			This.RemoveThisLeadingCharCS(_c_, pCaseSensitive)
			return This

		def RemoveLeadingCharCS(_c_, pCaseSensitive)
			This.RemoveThisLeadingCharCS(_c_, pCaseSensitive)

	# Removes every copy of a given character from the start of the text, in place.
	#
	#   _c_        the character to strip, matched with case
	#   returns    nothing; the text changes. RemoveThisLeadingCharQ returns the helper for chaining
	#   note       xxabxx becomes abxx; the match is case-sensitive, so XxabxX is left alone by "x";
	#              the RemoveThisLeadingCharCS form takes the case flag; a text of that character
	#              alone becomes empty
	#   see        RemoveThisTrailingChar, RemoveThisLeadingAndTrailingChar, RemoveFromStart
	def RemoveThisLeadingChar(_c_)
		This.RemoveThisLeadingCharCS(_c_, 1)

		# Removes every copy of a given character from the start of the text, in place.
		#
		#   _c_        the character to strip, matched with case
		#   returns    nothing; the text changes
		#   note       the same call as RemoveThisLeadingChar
		#   see        RemoveThisLeadingChar, RemoveTrailingChar
		def RemoveLeadingChar(_c_)
			This.RemoveThisLeadingChar(_c_)

	#--

	def RemoveThisTrailingCharCS(_c_, pCaseSensitive)
		_acChars_ = @oString.Chars()
		_nLen_ = len(_acChars_)
		_nEnd_ = _nLen_
		for i = _nLen_ to 1 step -1
			if BothStringsAreEqualCS(_acChars_[i], _c_, pCaseSensitive)
				_nEnd_ = i - 1
			else
				exit
			ok
		next
		if _nEnd_ < 1
			@oString.Update("")
		else
			@oString.Update(@oString.Section(1, _nEnd_))
		ok

		def RemoveThisTrailingCharCSQ(_c_, pCaseSensitive)
			This.RemoveThisTrailingCharCS(_c_, pCaseSensitive)
			return This

		def RemoveTrailingCharCS(_c_, pCaseSensitive)
			This.RemoveThisTrailingCharCS(_c_, pCaseSensitive)

	# Removes every copy of a given character from the end of the text, in place.
	#
	#   _c_        the character to strip, matched with case
	#   returns    nothing; the text changes. RemoveThisTrailingCharQ returns the helper for
	#              chaining
	#   note       xxabxx becomes xxab; the RemoveThisTrailingCharCS form takes the case flag
	#   see        RemoveThisLeadingChar, RemoveThisLeadingAndTrailingChar, RemoveFromEnd
	def RemoveThisTrailingChar(_c_)
		This.RemoveThisTrailingCharCS(_c_, 1)

		# Removes every copy of a given character from the end of the text, in place.
		#
		#   _c_        the character to strip, matched with case
		#   returns    nothing; the text changes
		#   note       the same call as RemoveThisTrailingChar
		#   see        RemoveThisTrailingChar, RemoveLeadingChar
		def RemoveTrailingChar(_c_)
			This.RemoveThisTrailingChar(_c_)

	  #======================================================#
	 #   REMOVING LEADING AND TRAILING AT ONCE              #
	#======================================================#

	def RemoveThisLeadingAndTrailingCharCS(_c_, pCaseSensitive)
		This.RemoveThisLeadingCharCS(_c_, pCaseSensitive)
		This.RemoveThisTrailingCharCS(_c_, pCaseSensitive)

		def RemoveThisLeadingAndTrailingCharCSQ(_c_, pCaseSensitive)
			This.RemoveThisLeadingAndTrailingCharCS(_c_, pCaseSensitive)
			return This

	# Removes a given character from both ends of the text, in place.
	#
	#   _c_        the character to strip, matched with case
	#   returns    nothing; the text changes. RemoveThisLeadingAndTrailingCharQ returns the helper
	#              for chaining
	#   note       xxabxx becomes ab
	#   see        RemoveThisLeadingChar, RemoveThisTrailingChar
	def RemoveThisLeadingAndTrailingChar(_c_)
		This.RemoveThisLeadingAndTrailingCharCS(_c_, 1)

		def RemoveThisLeadingAndTrailingCharQ(_c_)
			This.RemoveThisLeadingAndTrailingChar(_c_)
			return This

	  #======================================================#
	 #   CHECKING STARTS WITH / ENDS WITH                   #
	#======================================================#

	def StartsWithCS(pcSubStr, pCaseSensitive)
		_nLen_ = StzLen(pcSubStr)
		if _nLen_ > @oString.NumberOfChars()
			return 0
		ok
		_cLeft_ = @oString.NLeftChars(_nLen_)
		return BothStringsAreEqualCS(_cLeft_, pcSubStr, pCaseSensitive)

	# TRUE if the text begins with a substring, matched with case.
	#
	#   pcSubStr   the text the beginning must equal
	#   returns    TRUE or FALSE, as 1 or 0
	#   note       an empty substring and a substring longer than the text both answer FALSE; the CS
	#              form takes the case flag and honours it
	#   see        EndsWith, RemoveFromStart, StartsWithCS
	def StartsWith(pcSubStr)
		return This.StartsWithCS(pcSubStr, 1)

	def EndsWithCS(pcSubStr, pCaseSensitive)
		_nLen_ = StzLen(pcSubStr)
		if _nLen_ > @oString.NumberOfChars()
			return 0
		ok
		_cRight_ = @oString.NRightChars(_nLen_)
		return BothStringsAreEqualCS(_cRight_, pcSubStr, pCaseSensitive)

	# TRUE if the text finishes with a substring, matched with case.
	#
	#   pcSubStr   the text the end must equal
	#   returns    TRUE or FALSE, as 1 or 0
	#   note       an empty substring and a substring longer than the text both answer FALSE; the CS
	#              form takes the case flag and honours it
	#   see        StartsWith, RemoveFromEnd, EndsWithCS
	def EndsWith(pcSubStr)
		return This.EndsWithCS(pcSubStr, 1)

	  #======================================================#
	 #   REMOVING FROM START / END                          #
	#======================================================#

	def RemoveFromStartCS(pcSubStr, pCaseSensitive)
		if This.StartsWithCS(pcSubStr, pCaseSensitive)
			_pH_ = @oString.Engine()
			_pR_ = StzEngineStringRemovePrefix(_pH_, pcSubStr)
			_c_ = StzEngineStringData(_pR_)
			StzEngineStringFree(_pR_)
			@oString.Update(_c_)
		ok

		def RemoveFromStartCSQ(pcSubStr, pCaseSensitive)
			This.RemoveFromStartCS(pcSubStr, pCaseSensitive)
			return This

	# Removes a substring from the start of the text when it begins with it, in place.
	#
	#   pcSubStr   the text to cut off the beginning
	#   returns    nothing; the text changes, or stays when the text does not begin with the
	#              substring. RemoveFromStartQ returns the helper for chaining
	#   note       with the default flag it removes only an exact match
	#   warning    the RemoveFromStartCS form does nothing when the case flag is 0 and the case
	#              differs: on Hello World, RemoveFromStartCS("HELLO ", 0) leaves the text whole,
	#              because StartsWithCS agrees and the removal itself compares with case
	#   see        RemovedFromStart, RemoveFromEnd, StartsWith
	def RemoveFromStart(pcSubStr)
		This.RemoveFromStartCS(pcSubStr, 1)

		def RemoveFromStartQ(pcSubStr)
			This.RemoveFromStart(pcSubStr)
			return This

	def RemovedFromStartCS(pcSubStr, pCaseSensitive)
		_oCopy_ = new stzStringLeadTrail(@oString.Content())
		_oCopy_.RemoveFromStartCSQ(pcSubStr, pCaseSensitive)
		return _oCopy_.Content()

	# Returns the text without the given beginning, or unchanged when it does not begin with it, leaving the helper unchanged.
	#
	#   pcSubStr   the text to cut off the beginning
	#   returns    a text
	#   note       Hello World with Hello gives World; hello does not match
	#   warning    the RemovedFromStartCS form does nothing when the case flag is 0 and the case
	#              differs, as RemoveFromStartCS
	#   see        RemoveFromStart, RemovedFromEnd
	def RemovedFromStart(pcSubStr)
		return This.RemovedFromStartCS(pcSubStr, 1)

	#--

	def RemoveFromEndCS(pcSubStr, pCaseSensitive)
		if This.EndsWithCS(pcSubStr, pCaseSensitive)
			_pH_ = @oString.Engine()
			_pR_ = StzEngineStringRemoveSuffix(_pH_, pcSubStr)
			_c_ = StzEngineStringData(_pR_)
			StzEngineStringFree(_pR_)
			@oString.Update(_c_)
		ok

		def RemoveFromEndCSQ(pcSubStr, pCaseSensitive)
			This.RemoveFromEndCS(pcSubStr, pCaseSensitive)
			return This

	# Removes a substring from the end of the text when it finishes with it, in place.
	#
	#   pcSubStr   the text to cut off the end
	#   returns    nothing; the text changes, or stays when the text does not finish with the
	#              substring. RemoveFromEndQ returns the helper for chaining
	#   note       with the default flag it removes only an exact match
	#   warning    the RemoveFromEndCS form does nothing when the case flag is 0 and the case
	#              differs: on Hello World, RemovedFromEndCS(" world", 0) answers the text whole
	#   see        RemovedFromEnd, RemoveFromStart, EndsWith
	def RemoveFromEnd(pcSubStr)
		This.RemoveFromEndCS(pcSubStr, 1)

		def RemoveFromEndQ(pcSubStr)
			This.RemoveFromEnd(pcSubStr)
			return This

	def RemovedFromEndCS(pcSubStr, pCaseSensitive)
		_oCopy_ = new stzStringLeadTrail(@oString.Content())
		_oCopy_.RemoveFromEndCSQ(pcSubStr, pCaseSensitive)
		return _oCopy_.Content()

	# Returns the text without the given ending, or unchanged when it does not finish with it, leaving the helper unchanged.
	#
	#   pcSubStr   the text to cut off the end
	#   returns    a text
	#   note       Hello World with World gives Hello, with an exact match only
	#   warning    the RemovedFromEndCS form does nothing when the case flag is 0 and the case
	#              differs, as RemoveFromEndCS
	#   see        RemoveFromEnd, RemovedFromStart
	def RemovedFromEnd(pcSubStr)
		return This.RemovedFromEndCS(pcSubStr, 1)

	  #======================================================#
	 #   ENSURE PREFIX / SUFFIX                             #
	#======================================================#

	def EnsurePrefixCS(pcPrefix, pCaseSensitive)
		_bCase_ = @CaseSensitive(pCaseSensitive)
		_pH_ = @oString.Engine()
		_pR_ = StzEngineStringEnsurePrefixCS(_pH_, pcPrefix, _bCase_)
		_c_ = StzEngineStringData(_pR_)
		StzEngineStringFree(_pR_)
		@oString.Update(_c_)

		def EnsurePrefixCSQ(pcPrefix, pCaseSensitive)
			This.EnsurePrefixCS(pcPrefix, pCaseSensitive)
			return This

	# Puts a prefix at the start of the text unless it is already there, in place.
	#
	#   pcPrefix   the text the beginning must carry
	#   returns    nothing; the text changes. EnsurePrefixQ returns the helper for chaining
	#   note       example.com with https:// becomes https://example.com, and asking again changes
	#              nothing; the EnsurePrefixCS form takes the case flag and honours it
	#   see        PrefixEnsured, EnsureSuffix, StartsWith
	def EnsurePrefix(pcPrefix)
		This.EnsurePrefixCS(pcPrefix, 1)

		def EnsurePrefixQ(pcPrefix)
			This.EnsurePrefix(pcPrefix)
			return This

	def PrefixEnsuredCS(pcPrefix, pCaseSensitive)
		_bCase_ = @CaseSensitive(pCaseSensitive)
		_pH_ = @oString.Engine()
		_pR_ = StzEngineStringEnsurePrefixCS(_pH_, pcPrefix, _bCase_)
		_c_ = StzEngineStringData(_pR_)
		StzEngineStringFree(_pR_)
		return _c_

	# Returns the text with the prefix put in front unless already there, leaving the helper unchanged.
	#
	#   pcPrefix   the text the beginning must carry
	#   returns    a text
	#   note       HTTPS://x with https:// gives https://HTTPS://x, because the match is case-
	#              sensitive
	#   see        EnsurePrefix, SuffixEnsured
	def PrefixEnsured(pcPrefix)
		return This.PrefixEnsuredCS(pcPrefix, 1)

	def EnsureSuffixCS(pcSuffix, pCaseSensitive)
		_bCase_ = @CaseSensitive(pCaseSensitive)
		_pH_ = @oString.Engine()
		_pR_ = StzEngineStringEnsureSuffixCS(_pH_, pcSuffix, _bCase_)
		_c_ = StzEngineStringData(_pR_)
		StzEngineStringFree(_pR_)
		@oString.Update(_c_)

		def EnsureSuffixCSQ(pcSuffix, pCaseSensitive)
			This.EnsureSuffixCS(pcSuffix, pCaseSensitive)
			return This

	# Puts a suffix at the end of the text unless it is already there, in place.
	#
	#   pcSuffix   the text the end must carry
	#   returns    nothing; the text changes. EnsureSuffixQ returns the helper for chaining
	#   note       a suffix that is only partly there is added whole; the EnsureSuffixCS form takes
	#              the case flag and honours it
	#   see        SuffixEnsured, EnsurePrefix, EndsWith
	def EnsureSuffix(pcSuffix)
		This.EnsureSuffixCS(pcSuffix, 1)

		def EnsureSuffixQ(pcSuffix)
			This.EnsureSuffix(pcSuffix)
			return This

	def SuffixEnsuredCS(pcSuffix, pCaseSensitive)
		_bCase_ = @CaseSensitive(pCaseSensitive)
		_pH_ = @oString.Engine()
		_pR_ = StzEngineStringEnsureSuffixCS(_pH_, pcSuffix, _bCase_)
		_c_ = StzEngineStringData(_pR_)
		StzEngineStringFree(_pR_)
		return _c_

	# Returns the text with the suffix added at the end unless already there, leaving the helper unchanged.
	#
	#   pcSuffix   the text the end must carry
	#   returns    a text
	#   see        EnsureSuffix, PrefixEnsured
	def SuffixEnsured(pcSuffix)
		return This.SuffixEnsuredCS(pcSuffix, 1)

	def RemoveRepeatedLeadingCharsCS(pCaseSensitive)
		@oString.RemoveLeadingChars()

	def RemoveRepeatedTrailingCharsCS(pCaseSensitive)
		@oString.RemoveTrailingChars()
