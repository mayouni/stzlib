#--------------------------------------------------------------#
#      SOFTANZA LIBRARY (V0.9) - STZSTRINGDUPLICATES           #
#   An accelerative library for Ring applications, and more!   #
#--------------------------------------------------------------#
#                                                              #
#   Description  : String duplicates -- Wraps stzString via    #
#                composition. Duplicate detection, consecutive #
#                char management, deduplication operations.    #
#   Version      : V0.9 (2026)                                 #
#   Author       : Mansour Ayouni (kalidianow@gmail.com)       #
#                                                              #
#--------------------------------------------------------------#


# Finds and removes repeated characters or repeated substrings in a text.
#
# Build one with new stzStringDuplicates("banana"). DuplicatedChars, UniqueChars and their counts
# look at single characters, whole letters, not bytes, so Hebrew, Arabic and emoji work; comparisons
# are case-sensitive. The Remove verbs change the text held (RemoveConsecutiveDuplicateChars
# collapses runs, RemoveAllDuplicateChars keeps the first of each character,
# RemoveDuplicateSubString keeps the first occurrence of a substring) and each has a passive twin
# that returns the result. Do not pass a stzString object you still need: the first in-place edit
# empties it. RemoveDuplicateSubString mishandles overlapping matches.
#
#   receiver   o1 = new stzStringDuplicates("banana")
#   example    ? @@( o1.DuplicatedChars() )
#              #--> [ "a", "n" ]
#              ? o1.AllDuplicateCharsRemoved()
#              #--> ban
#              ? o1.DuplicateSubStringRemoved("an")
#              #--> bana
#              o2 = new stzStringDuplicates("שלומשלום😀😀")
#              ? o2.NumberOfUniqueChars()
#              #--> 6
#   see        stzString, stzStringSections
class stzStringDuplicates from stzObject

	@oString

	# Builds a duplicates helper over a text or over a stzString object.
	#
	#   pStrOrStzStrObj   a text, or a stzString object, whose repeated characters or substrings are
	#                     examined
	#   returns           nothing; the object is built
	#   note              any other kind of value raises "Can't create stzStringDuplicates!
	#                     Parameter must be a string or stzString object."
	#   warning           Given a stzString object, the first in-place edit
	#                     (RemoveConsecutiveDuplicateChars, RemoveAllDuplicateChars,
	#                     RemoveDuplicateSubString) leaves that stzString EMPTY while the helper
	#                     holds the result; the passive forms and the questions do not. Pass the
	#                     text, os.Content(), to be safe
	#   see               DuplicatedChars, UniqueChars
	def init(pStrOrStzStrObj)
		if isString(pStrOrStzStrObj)
			@oString = new stzString(pStrOrStzStrObj)
		but isObject(pStrOrStzStrObj)
			@oString = pStrOrStzStrObj
		else
			StzRaise("Can't create stzStringDuplicates! Parameter must be a string or stzString object.")
		ok

	# Returns the text the helper holds, after any in-place removal made through it.
	#
	#   returns    a text
	#   see        NumberOfChars
	def Content()
		return @oString.Content()

	# Returns how many characters the text holds, counting letters and not bytes.
	#
	#   returns    a number
	#   see        NumberOfUniqueChars
	def NumberOfChars()
		return @oString.NumberOfChars()

	# TRUE if the text is empty.
	#
	#   returns    TRUE or FALSE
	#   see        NumberOfChars
	def IsEmpty()
		return @oString.IsEmpty()

	  #===============================#
	 #     DUPLICATE CHARS           #
	#===============================#

	# Returns the characters that occur more than once in the text, each listed once, in the order of their first appearance.
	#
	#   returns    a list of characters
	#   note       "banana" gives a and n; the comparison is case-sensitive, so "Aa" has none
	#   see        HasDuplicatedChars, UniqueChars
	def DuplicatedChars()
		_pH_ = @oString.Engine()
		_pR_ = StzEngineStringDuplicatedChars(_pH_)
		_cDups_ = StzEngineStringData(_pR_)
		StzEngineStringFree(_pR_)
		return _SplitNullDelimited(_cDups_)

	# TRUE if at least one character occurs more than once in the text.
	#
	#   returns    TRUE or FALSE
	#   see        DuplicatedChars
	def HasDuplicatedChars()
		return len(This.DuplicatedChars()) > 0

	# Returns how many different characters occur more than once.
	#
	#   returns    a number
	#   note       "banana" gives 2, not the 3 extra letters
	#   see        DuplicatedChars
	def NumberOfDuplicatedChars()
		return len(This.DuplicatedChars())

	  #===============================#
	 #     UNIQUE CHARS              #
	#===============================#

	# Returns the different characters of the text, each once, in the order of their first appearance.
	#
	#   returns    a list of characters
	#   note       "banana" gives b, a, n; Hebrew, Arabic and emoji are single characters, and the
	#              final form ם differs from מ
	#   see        NumberOfUniqueChars, DuplicatedChars
	def UniqueChars()
		_pH_ = @oString.Engine()
		_pR_ = StzEngineStringUniqueChars(_pH_)
		_cUnique_ = StzEngineStringData(_pR_)
		StzEngineStringFree(_pR_)
		if _cUnique_ = ""
			return []
		ok
		# Split unique chars string into individual characters
		pU = StzEngineString(_cUnique_)
		pSplit = StzEngineStringCharsSplit(pU)
		_cJoined_ = StzEngineStringData(pSplit)
		StzEngineStringFree(pSplit)
		StzEngineStringFree(pU)
		return _SplitNullDelimited(_cJoined_)

	# Returns how many different characters the text holds.
	#
	#   returns    a number
	#   see        UniqueChars
	def NumberOfUniqueChars()
		_pH_ = @oString.Engine()
		return StzEngineStringCountUniqueChars(_pH_)

	  #===============================#
	 #     CONSECUTIVE CHARS         #
	#===============================#

	# TRUE if two equal characters stand side by side somewhere in the text.
	#
	#   returns    TRUE or FALSE
	#   note       "banana" is FALSE although it repeats letters, "aabbcc" is TRUE
	#   see        RemoveConsecutiveDuplicateChars
	def HasConsecutiveDuplicates()
		_acChars_ = @oString.Chars()
		_nLen_ = len(_acChars_)
		if _nLen_ < 2
			return 0
		ok

		for i = 2 to _nLen_
			if _acChars_[i] = _acChars_[i - 1]
				return 1
			ok
		next

		return 0

	# Collapses each run of the same character to one, in place.
	#
	#   returns    nothing; use RemoveConsecutiveDuplicateCharsQ to chain
	#   note       "aabbcc" becomes "abc" and "banana" is unchanged
	#   see        ConsecutiveDuplicateCharsRemoved, RemoveAllDuplicateChars
	def RemoveConsecutiveDuplicateChars()
		_pH_ = @oString.Engine()
		_pR_ = StzEngineStringRemoveConsecutiveDuplicates(_pH_)
		_c_ = StzEngineStringData(_pR_)
		StzEngineStringFree(_pR_)
		@oString.Update(_c_)

		def RemoveConsecutiveDuplicateCharsQ()
			This.RemoveConsecutiveDuplicateChars()
			return This

	# Returns the text with each run of the same character reduced to one, leaving the helper unchanged.
	#
	#   returns    a text
	#   see        RemoveConsecutiveDuplicateChars
	def ConsecutiveDuplicateCharsRemoved()
		_pH_ = @oString.Engine()
		_pR_ = StzEngineStringRemoveConsecutiveDuplicates(_pH_)
		_c_ = StzEngineStringData(_pR_)
		StzEngineStringFree(_pR_)
		return _c_

	  #===============================#
	 #     REMOVE ALL DUPLICATES     #
	#===============================#

	# Keeps only the first occurrence of each character, wherever the repeats stand, in place.
	#
	#   returns    nothing; use RemoveAllDuplicateCharsQ to chain
	#   note       "banana" becomes "ban"
	#   see        AllDuplicateCharsRemoved, RemoveConsecutiveDuplicateChars
	def RemoveAllDuplicateChars()
		_pH_ = @oString.Engine()
		_pR_ = StzEngineStringUniqueChars(_pH_)
		_c_ = StzEngineStringData(_pR_)
		StzEngineStringFree(_pR_)
		@oString.Update(_c_)

		def RemoveAllDuplicateCharsQ()
			This.RemoveAllDuplicateChars()
			return This

	# Returns the text with only the first occurrence of each character kept, leaving the helper unchanged.
	#
	#   returns    a text
	#   see        RemoveAllDuplicateChars
	def AllDuplicateCharsRemoved()
		_pH_ = @oString.Engine()
		_pR_ = StzEngineStringUniqueChars(_pH_)
		_c_ = StzEngineStringData(_pR_)
		StzEngineStringFree(_pR_)
		return _c_

	  #===============================#
	 #     DEDUPLICATE SUBSTRINGS    #
	#===============================#

	def RemoveDuplicateSubStringCS(pcSubStr, pCaseSensitive)
		_oFinder_ = new stzStringFinder(@oString)
		_anPos_ = _oFinder_.FindCS(pcSubStr, pCaseSensitive)
		if len(_anPos_) <= 1
			return
		ok

		_nLenSub_ = StzLen(pcSubStr)

		# Remove from end to start to preserve earlier positions
		for i = len(_anPos_) to 2 step -1
			_nPos_ = _anPos_[i]
			@oString.RemoveSection(_nPos_, _nPos_ + _nLenSub_ - 1)
		next

		def RemoveDuplicateSubStringCSQ(pcSubStr, pCaseSensitive)
			This.RemoveDuplicateSubStringCS(pcSubStr, pCaseSensitive)
			return This

	# Keeps the first occurrence of a substring and removes the later ones, case-sensitively, in place.
	#
	#   pcSubStr   the substring whose repeats are removed
	#   returns    nothing; use RemoveDuplicateSubStringQ to chain
	#   note       RemoveDuplicateSubStringCS(pcSubStr, 0) ignores case
	#   warning    Occurrences that overlap are all counted, so the removal can eat more than the
	#              repeats: "aaa" with "aa" becomes "a", and "xaaaax" with "aa" becomes "xa", losing
	#              the final x; a substring that occurs once or not at all changes nothing
	#   see        DuplicateSubStringRemoved
	def RemoveDuplicateSubString(pcSubStr)
		This.RemoveDuplicateSubStringCS(pcSubStr, 1)

		def RemoveDuplicateSubStringQ(pcSubStr)
			This.RemoveDuplicateSubString(pcSubStr)
			return This

	def DuplicateSubStringRemovedCS(pcSubStr, pCaseSensitive)
		_oCopy_ = new stzStringDuplicates(@oString.Content())
		_oCopy_.RemoveDuplicateSubStringCS(pcSubStr, pCaseSensitive)
		return _oCopy_.Content()

	# Returns the text with the later occurrences of a substring removed, leaving the helper unchanged.
	#
	#   pcSubStr   the substring whose repeats are removed
	#   returns    a text
	#   note       "banana" with "an" gives "bana"
	#   warning    the same overlap defect
	#   see        RemoveDuplicateSubString
	def DuplicateSubStringRemoved(pcSubStr)
		return This.DuplicateSubStringRemovedCS(pcSubStr, 1)
