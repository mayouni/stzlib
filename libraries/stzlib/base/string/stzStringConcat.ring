#--------------------------------------------------------------#
#        SOFTANZA LIBRARY (V0.9) - STZSTRINGCONCAT             #
#   An accelerative library for Ring applications, and more!   #
#--------------------------------------------------------------#
#                                                              #
#   Description  : String concat -- concatenation and          #
#                  repetition operations.                      #
#                  Wraps stzString via composition.            #
#                  For aliases, use stzStringConcatXT.         #
#   Version      : V0.9 (2026)                                 #
#   Author       : Mansour Ayouni (kalidianow@gmail.com)       #
#                                                              #
#--------------------------------------------------------------#


# Extends a text: adds at the end or in front, adds many, repeats it, or puts a separator between its characters.
#
# Build one with new stzStringConcat("abc"). Each in-place verb (Concat, Prepend, Append,
# ConcatMany, RepeatNTimes, JoinWith) changes the text it holds and has a passive twin that returns
# the new text (Concatenated, Prepended, Appended, ConcatenatedWithMany, RepeatedNTimes,
# JoinedWith). Characters are whole letters, so Hebrew, Arabic and emoji repeat and join without
# being cut. JoinWith joins the characters of the text itself, not a list of texts. Do not pass a
# stzString object you still need: the first in-place edit empties it.
#
#   receiver   o1 = new stzStringConcat("abc")
#   example    ? o1.Concatenated("def")
#              #--> abcdef
#              ? o1.RepeatedNTimes(2)
#              #--> abcabc
#              ? o1.JoinedWith("-")
#              #--> a-b-c
#              o2 = new stzStringConcat("שלום")
#              ? o2.JoinedWith("·")
#              #--> ש·ל·ו·ם
#   see        stzString, stzStringAligner
class stzStringConcat from stzObject

	@oString

	# Builds a concatenation helper over a text or over a stzString object.
	#
	#   pStrOrStzStrObj   a text, or a stzString object, to extend, repeat or join
	#   returns           nothing; the object is built
	#   note              any other kind of value raises "Can't create stzStringConcat! Parameter
	#                     must be a string or stzString object."
	#   warning           Given a stzString object, the first in-place edit (Concat, Prepend,
	#                     Append, ConcatMany, RepeatNTimes, JoinWith) leaves that stzString EMPTY
	#                     while the helper holds the result; the passive forms (Concatenated ...) do
	#                     not. Pass the text, os.Content(), to be safe
	#   see               Concat, Repeat
	def init(pStrOrStzStrObj)
		if isString(pStrOrStzStrObj)
			@oString = new stzString(pStrOrStzStrObj)
		but isObject(pStrOrStzStrObj)
			@oString = pStrOrStzStrObj
		else
			StzRaise("Can't create stzStringConcat! Parameter must be a string or stzString object.")
		ok

	# Returns the text the helper holds, after any in-place change made through it.
	#
	#   returns    a text
	#   see        Concatenated
	def Content()
		return @oString.Content()

	# Returns how many characters the text holds, counting letters and not bytes.
	#
	#   returns    a number
	#   see        Content
	def NumberOfChars()
		return @oString.NumberOfChars()

	# TRUE if the text is empty.
	#
	#   returns    TRUE or FALSE
	#   see        NumberOfChars
	def IsEmpty()
		return @oString.IsEmpty()

	  #======================================================#
	 #   CONCATENATION                                      #
	#======================================================#

	# Adds a text at the end of the text held, in place.
	#
	#   pcStr      the text to add at the end
	#   returns    nothing; use ConcatQ to chain
	#   note       Append is the same method
	#   see        Concatenated, Append, Prepend
	def Concat(pcStr)
		@oString.Update(@oString.Content() + pcStr)

		def ConcatQ(pcStr)
			This.Concat(pcStr)
			return This

	# Returns the text with another text added at its end, leaving the helper unchanged.
	#
	#   pcStr      the text to add at the end
	#   returns    a text
	#   note       a number is turned into its text: "x" with 5 gives "x5"
	#   see        Concat, Prepended
	def Concatenated(pcStr)
		return @oString.Content() + pcStr

	  #======================================================#
	 #   CONCATENATING MANY STRINGS                         #
	#======================================================#

	def ConcatMany(pacStrings)
		_cResult_ = @oString.Content()
		_nLen_ = len(pacStrings)
		for i = 1 to _nLen_
			_cResult_ += pacStrings[i]
		next
		@oString.Update(_cResult_)

		def ConcatManyQ(pacStrings)
			This.ConcatMany(pacStrings)
			return This

	# Returns the text with several texts added at its end, in order, leaving the helper unchanged.
	#
	#   pacStrings   the list of texts to add
	#   returns      a text
	#   note         "abc" with 1 2 3 gives "abc123"
	#   see          Concatenated
	def ConcatenatedWithMany(pacStrings)
		_oCopy_ = new stzStringConcat(@oString.Content())
		_oCopy_.ConcatMany(pacStrings)
		return _oCopy_.Content()

	  #======================================================#
	 #   PREPEND / APPEND                                   #
	#======================================================#

	# Adds a text at the start of the text held, in place.
	#
	#   pcStr      the text to put in front
	#   returns    nothing; use PrependQ to chain
	#   see        Prepended, Concat
	def Prepend(pcStr)
		@oString.Update(pcStr + @oString.Content())

		def PrependQ(pcStr)
			This.Prepend(pcStr)
			return This

	# Returns the text with another text put in front of it, leaving the helper unchanged.
	#
	#   pcStr      the text to put in front
	#   returns    a text
	#   note       ">>" before "abc" gives ">>abc"
	#   see        Prepend
	def Prepended(pcStr)
		return pcStr + @oString.Content()

	# Adds a text at the end of the text held, in place, exactly as Concat does.
	#
	#   pcStr      the text to add at the end
	#   returns    nothing; use AppendQ to chain
	#   see        Concat, Appended
	def Append(pcStr)
		This.Concat(pcStr)

		def AppendQ(pcStr)
			This.Append(pcStr)
			return This

	def Appended(pcStr)
		return This.Concatenated(pcStr)

	  #======================================================#
	 #   REPETITION                                         #
	#======================================================#

	# Replaces the text by itself written n times in a row, in place.
	#
	#   n          how many times the text appears in the result
	#   returns    nothing; use RepeatNTimesQ to chain
	#   note       0 or a negative n leaves an empty text without an error; Repeat is the same
	#              method
	#   see        RepeatedNTimes, Repeat
	def RepeatNTimes(n)
		_pH_ = @oString.Engine()
		_pR_ = StzEngineStringRepeat(_pH_, n)
		if _pR_ != 0
			@oString.Update(StzEngineStringData(_pR_))
			StzEngineStringFree(_pR_)
		ok

		def RepeatNTimesQ(n)
			This.RepeatNTimes(n)
			return This

		# Replaces the text by itself written n times in a row, in place, exactly as RepeatNTimes does.
		#
		#   n          how many times the text appears in the result
		#   returns    nothing
		#   see        RepeatNTimes
		def Repeat(n)
			This.RepeatNTimes(n)

	# Returns the text written n times in a row, leaving the helper unchanged.
	#
	#   n          how many times the text appears in the result
	#   returns    a text; empty for 0
	#   note       "abc" 3 times gives "abcabcabc"; Repeated is the same method
	#   see        RepeatNTimes
	def RepeatedNTimes(n)
		_oCopy_ = new stzStringConcat(@oString.Content())
		_oCopy_.RepeatNTimes(n)
		return _oCopy_.Content()

		def Repeated(n)
			return This.RepeatedNTimes(n)

	  #======================================================#
	 #   JOIN WITH SEPARATOR                                #
	#======================================================#

	# Puts a separator between every two characters of the text, in place.
	#
	#   pcSep      the separator text
	#   returns    nothing; use JoinWithQ to chain
	#   note       it joins the characters of THIS text, not a list: "abc" with "-" becomes "a-b-c"
	#   see        JoinedWith
	def JoinWith(pcSep)
		_aChars_ = @oString.Chars()
		_cResult_ = ""
		_nLen_ = len(_aChars_)
		for i = 1 to _nLen_
			_cResult_ += _aChars_[i]
			if i < _nLen_
				_cResult_ += pcSep
			ok
		next
		@oString.Update(_cResult_)

		def JoinWithQ(pcSep)
			This.JoinWith(pcSep)
			return This

	# Returns the text with a separator between every two characters, leaving the helper unchanged.
	#
	#   pcSep      the separator text
	#   returns    a text
	#   note       "שלום" with "·" gives "ש·ל·ו·ם"; an empty separator changes nothing
	#   see        JoinWith
	def JoinedWith(pcSep)
		_oCopy_ = new stzStringConcat(@oString.Content())
		_oCopy_.JoinWith(pcSep)
		return _oCopy_.Content()
