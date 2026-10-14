
func StzOccurrenceQ(panOccurr, pcSubStr, pcStr)
	return new stzOccurrences(panOccurr, pcSubStr, pcStr)

# Carries the positions where a substring occurs in a string, as a small value object that is meant to act on them.
#
# Only the list of positions works today. SubString and String answer an empty text (the constructor
# and the readers use different field names), Removed raises R14 for a missing stzString method, and
# ReplacedWithCS, Uppercased and Lowercased are empty stubs. Reach for Occurrences, or for the Find
# methods of stzString, to get the positions.
#
#   receiver   o1 = new stzOccurrences([ 2, 4 ], "an", "banana")
#   example    ? @@( o1.Occurrences() )
#              #--> [ 2, 4 ]
#   see        stzString, stzItem
class stzOccurrences from stzObject
	@anOccurrences
	@cSubStr
	@cStr

	# Stores the positions where a substring occurs in a string, together with the substring and the string.
	#
	#   panOccurr   the positions found, as a list of numbers
	#   pcSubStr    the substring that was searched, or [ :Of = '...' ]
	#   pcStr       the string that was searched, or [ :In = '...' ]
	#   returns     nothing; the object is built
	#   note        checked with plain texts and with the :Of and :In named forms
	#   warning     SubString and String answer an empty text afterwards: the constructor stores the
	#               two texts in fields (@pcSubStr, @pcStr) that those methods do not read
	#   see         Occurrences
	def init(panOccurr, pcSubStr, pcStr)
		if isList(pcSubStr) and Q(pcSubStr).IsOfOrOfSubStringNamedParam()
			pcSubStr = pcSubStr[2]
		ok

		if isList(pcStr) and Q(pcStr).IsInOrInStringNamedParam()
			pcStr = pcStr[2]
		ok

		@anOccurrences = panOccurr
		@pcSubStr = pcSubStr
		@pcStr = pcStr

	# Returns the list of positions given at construction, unchanged.
	#
	#   returns    a list of numbers
	#   see        SubString, String
	def Occurrences()
		return @anOccurrences

		def Content()
			return This.Occurrences()

		# Returns the list of positions given at construction, as the call with the other name does.
		#
		#   returns    a list of numbers
		#   see        Occurrences
		def Value()
			return Content()

	# Returns an empty text today instead of the substring that was searched.
	#
	#   returns    an empty text
	#   warning    the constructor stores the substring in @pcSubStr while this method reads
	#              @cSubStr, so the answer is always empty; checked with plain texts and with the
	#              :Of form
	#   see        String, init
	def SubString()
		return @cSubStr

		def SubStringQ()
			return new stzString(This.SubString())

	# Returns an empty text today instead of the string that was searched.
	#
	#   returns    an empty text
	#   warning    the constructor stores the string in @pcStr while this method reads @cStr, so the
	#              answer is always empty; checked with plain texts and with the :In form
	#   see        SubString, init
	def String()
		return @cStr

		def StringQ()
			return new stzString(This.String())

	#--

	def RemovedCS(pCaseSensitive)
		_cResult_ = This.StringQ().
				RemoveSubStringAtPositionsCSQ(
					This.Occurrences, This.SubString(), pCaseSensitive).
				Content()

		return _cResult_

	# Raises error R14 today instead of returning the string with the substring cut out at every occurrence.
	#
	#   returns    nothing; it raises
	#   note       checked on two objects with different positions and case
	#   warning    calls RemoveSubStringAtPositionsCSQ, a method stzString does not have; the stored
	#              string is also empty, see String
	#   see        RemovedCS
	def Removed()
		return This.RemovedCS(1)


	# Does nothing today: the body is empty.
	#
	#   returns    nothing
	#   warning    an unfinished stub with no parameters and no code; it answers an empty value
	#   see        Removed
	#@ aka  --
	def ReplacedWithCS()

	# Does nothing today: the body is empty.
	#
	#   returns    nothing
	#   warning    an unfinished stub with no code; it answers an empty value
	#   see        Lowercased
	def Uppercased()

	# Does nothing today: the body is empty.
	#
	#   returns    nothing
	#   warning    an unfinished stub with no code; it answers an empty value
	#   see        Uppercased
	def Lowercased()
