
# A great tool to learn from:
# https://www.regexmagic.com/patterns.html

func StzRegexMakerQ()
	return new stzRegexMaker

	func rxm()
		return new stzRegexMaker

func StzRecursiveRegexMakerQ()
	return new stzRecursiveRegexMaker

	func StzNestedRegexMakerQ()
		return new stzRecursiveRegexMaker

	func rrxm()
		return new stzRecursiveRegexMaker

	func NestedRegex()
		return new stzRecursiveRegexMaker

	func nrxm()
		return new stzRecursiveRegexMaker

func StzConditionalRegexMakerQ()
	return new stzConditionalRegexMaker

	func wrxm()
		return new stzConditionalRegexMaker

	func crxm()
		return new stzConditionalRegexMaker

func StzRegexLookaroundMakerQ()
	return new stzRegexLookaroundMaker

	func rxma()
		return new stzRegexLookaroundMaker

	func arxm()
		return new stzRegexLookaroundMaker

func StzRxp(pcPattName)
	_cResult_ = RegexPatterns()[pcPattName]
	if _cResult_ = ""
		StzRaise("The pattern name you provided does not exist in stzRegexData file.")
	ok

	return _cResult_

	func rxp(pcPattName)
		return StzRxp(pcPattName)

	func StzPat(pcPattName)
		return StzRxp(pcPattName)

	func pat(pcPattName)
		return StzRxp(pcPattName)

	func patt(pcPattName)
		return StzRxp(pcPattName)

	func StzPattern(pcPattName)
		return StzRxp(pcPattName)

	func Pattern(pcPattName)
		return StzRxp(pcPattName)

	func StzPatternByName(pcPattName)
		return StzRxp(pcPattName)

	func PatternByName(pcPattName)
		return StzRxp(pcPattName)

	func StzRegexPattern(pcPattName)
		return StzRxp(pcPattName)

	func RegexPattern(pcPattName)
		return StzRxp(pcPattName)


func 1Time()
	return 1

func 2Times()
	return 2

func 3Times()
	return 3

func NTimes(n)
	return n

#=====================#
#  REGEX MAKER CLASS  #
#=====================#

# Builds a regular expression piece by piece from calls, then hands it over as one text with Pattern.
#
# Each Add call appends a fragment: a class such as [abc] or [a-z] with a repeat suffix (AddRange,
# AddAmongChars, AddCharsRange and their digit forms), a literal, a shorthand class, a group, a flag
# or an assertion. Pattern joins the fragments in order. The calls that add ranges also record a
# sequence, the same call in data form, so Sequences and Fragments are two views of one pattern;
# literals and groups add a fragment and no sequence, so the two lists have different lengths, and
# the maker remembers which fragment each sequence made (Sequence, SequenceXT and RepeatSequence
# follow that link, not the position). Groups made with DefineGroup are remembered and can be
# reused or referred back to. The text is not escaped or validated: a literal goes in as given.
# Quantifiers and QuantifiersCommands are placeholders that answer an empty text. For ready-made
# patterns by name use AddCommonPattern or StzRxp.
#
#   receiver   o1 = new stzRegexMaker
#   example    o1.AddAmongChars("abc", :repeatedExactly, 3, 0)
#              o1.AddLiteral("-")
#              o1.AddCharsRange("a-z", :repeatedAtLeast, 1, 0)
#              ? o1.Pattern()
#              #--> [abc]{3}-[a-z]{1,}
#              ? o1.NumberOfFragements()
#              #--> 3
#   see        stzRegex, StzRxp, stzNumbrex
class stzRegexMaker from stzObject
	@acFragments = []
	@aSequences = []
	@anSeqFrag = []	# For each sequence, the position of the fragment it made
	@aGroups = []  	# List of [name, pattern] pairs

	# Builds an empty maker, with no fragments, no sequences and no groups.
	#
	#   returns    nothing; the object is built
	#   see        Pattern, AddRange
	def init()

	  #--------------------#
	 #  ADDING SEQUENCES  #
	#--------------------#

	# Appends a bracketed character class with a repeat suffix to the pattern, and records the call as a sequence.
	#
	#   cType       among for [abc], notAmong for [^abc], anything else for a range like [a-z]
	#   _cRange_    the characters as a text or a list, where the word SPACE stands for a blank in
	#               among and notAmong
	#   cQuant      repeatedExactly for {n}, repeatedAtLeast for {n,}, repeatedAtMost for ? (one time)
	#               or {0,n}, repeatedBetween for {n,m}, repeatedSeveralTimes or repeatedSeveral for *
	#   nTimes1     the first count
	#   _nTimes2_   the second count for repeatedBetween, or a pair such as [ and, 5 ]
	#   returns     nothing; read the result with Pattern
	#   note        repeatedAtMost with 1 gives ?, with 3 gives {0,3}
	#   warning     a cQuant it does not know raises Unknown repeat kind and adds nothing
	#   see         AddAmongChars, AddCharsRange, Pattern
	def AddRange(cType, _cRange_, cQuant, nTimes1, _nTimes2_)

		# Checking params

		if isString(cType)
			cType = StzLower(cType)
		ok

		if isString(cQuant)
			cQuant = StzLower(cQuant)
		ok

		if isString(_nTimes2_) and (_nTimes2_ = :Time or _nTimes2_ = :Times)
			nTimes = 0

		# case of named param like :And = [3, :Times]

		but isList(_nTimes2_) and len(_nTimes2_) = 2 and isString(_nTimes2_[1]) and _nTimes2_[1] = "and"
			if isNumber(_nTimes2_[2])
				_nTimes2_ = _nTimes2_[2]

			but isList(_nTimes2_[2])

				if isNumber(_nTimes2_[2][1]) and
				   isString(_nTimes2_[2][2]) and
				   (_nTimes2_[2][2] = :Time or _nTimes2_[2][2] = :Times)

					_nTimes2_ = _nTimes2_[2][1]
				else
					StzRaise("Incorrect param type!")
				ok
			ok
		ok

		# Constrcuting the main pattern string

		_cPattern_ = ""

		if isList(_cRange_)
			_cRange_ = join(_cRange_)
		ok

		if cType = :among
			_cPattern_ = "[" + StzReplace(_cRange_, "SPACE", " ") + "]"

		but cType = :notAmong
			_cPattern_ = "[^" + StzReplace(_cRange_, "SPACE", " ") + "]"

		else
			_cPattern_ = "[" + _cRange_ + "]"
		ok

		# Constructing the quantifier part of the pattern

        	_cQuantifier_ = ""

		if cQuant = :repeatedExactly
			_cQuantifier_ = "{" + nTimes1 + "}"

		but cQuant = :repeatedAtLeast
			_cQuantifier_ = "{" + nTimes1 + ",}"

		but cQuant = :repeatedAtMost
			if nTimes1 = 1
				_cQuantifier_ = "?"
			else
				_cQuantifier_ = "{0," + nTimes1 + "}"
			ok

		but cQuant = :repeatedBetween
			_cQuantifier_ = "{" + nTimes1 + "," + _nTimes2_ + "}"

		but cQuant =  :repeatedSeveralTimes or cQuant = :repeatedSeveral
			_cQuantifier_ = "*"

		else
			StzRaise("Unknown repeat kind! Use repeatedExactly, repeatedAtLeast, repeatedAtMost, repeatedBetween, repeatedSeveralTimes or repeatedSeveral.")
		ok

		# Storing the complete pattern (main string + quantifier part)

        	@acFragments + (_cPattern_ + _cQuantifier_)

		# String the elements of the sequence applied, and the fragment it made

        	@aSequences + [ cType, _cRange_, cQuant, nTimes1, _nTimes2_ ]
        	@anSeqFrag + len(@acFragments)


	# Appends a class that matches any one of the given characters, repeated as asked.
	#
	#   _cChars_    the characters as a text or a list
	#   cQuant      the repeat kind, as in AddRange
	#   nTimes1     the first count
	#   _nTimes2_   the second count
	#   returns     nothing; read the result with Pattern
	#   note        AddAmongChars("abc", :repeatedExactly, 3, 0) gives [abc]{3}
	#   see         AddRange, AddNotAmongChars, AddAmongDigits
	def AddAmongChars(_cChars_, cQuant, nTimes1, _nTimes2_)

		if isString(_cChars_)
			_cChars_ = Chars(_cChars_)
		ok
        
		AddRange(:among, _cChars_, cQuant, nTimes1, _nTimes2_)

		# Appends a class that matches any one of the given digits, repeated as asked.
		#
		#   _cDigits_   the digits as a text or a list
		#   cQuant      the repeat kind, as in AddRange
		#   nTimes1     the first count
		#   _nTimes2_   the second count
		#   returns     nothing; read the result with Pattern
		#   note        no check that the characters are digits
		#   see         AddAmongChars, AddNotAmongDigits
		def AddAmongDigits(_cDigits_, cQuant, nTimes1, _nTimes2_)
			if isString(_cDigits_)
				_cDigits_ = Chars(_cDigits_)
			ok

			This.AddAmongChars(_cDigits_, cQuant, nTimes1, _nTimes2_)

	# Appends a class that matches any one character except the given ones, repeated as asked.
	#
	#   _cChars_    the characters to exclude, as a text or a list
	#   cQuant      the repeat kind, as in AddRange
	#   nTimes1     the first count
	#   _nTimes2_   the second count
	#   returns     nothing; read the result with Pattern
	#   note        gives [^abc]{3} for abc and a count of 3
	#   see         AddAmongChars, AddRange
	def AddNotAmongChars(_cChars_, cQuant, nTimes1, _nTimes2_)
		if isString(_cChars_)
			_cChars_ = Chars(_cChars_)
		ok
        
		AddRange(:NotAmong, _cChars_, cQuant, nTimes1, _nTimes2_)

		# Appends a class that matches any one character except the given digits, repeated as asked.
		#
		#   _cDigits_   the digits to exclude, as a text or a list
		#   cQuant      the repeat kind, as in AddRange
		#   nTimes1     the first count
		#   _nTimes2_   the second count
		#   returns     nothing; read the result with Pattern
		#   see         AddNotAmongChars, AddAmongDigits
		def AddNotAmongDigits(_cDigits_, cQuant, nTimes1, _nTimes2_)
			if isString(_cDigits_)
				_cDigits_ = Chars(_cDigits_)
			ok

			This.AddNotAmongChars(_cDigits_, cQuant, nTimes1, _nTimes2_)

	# Appends a range class such as [a-f], repeated as asked.
	#
	#   _cRange_    the range written with a dash, for example a-f
	#   cQuant      the repeat kind, as in AddRange
	#   nTimes1     the first count
	#   _nTimes2_   the second count
	#   returns     nothing; read the result with Pattern
	#   note        the range text is not checked: it goes between the brackets as written
	#   see         AddRange, AddDigitsRange
	def AddCharsRange(_cRange_, cQuant, nTimes1, _nTimes2_)
		This.AddRange(:Between, _cRange_, cQuant, nTimes1, _nTimes2_)
 
		# Appends a digit range class such as [0-9], repeated as asked.
		#
		#   _cDigits_   the range written with a dash, or its three characters as a list
		#   cQuant      the repeat kind, as in AddRange
		#   nTimes1     the first count
		#   _nTimes2_   the second count
		#   returns     nothing; read the result with Pattern
		#   see         AddCharsRange, AddAmongDigits
		def AddDigitsRange(_cDigits_, cQuant, nTimes1, _nTimes2_)
			if isString(_cDigits_)
				_cDigits_ = Chars(_cDigits_)
			ok

			This.AddCharsRange(_cDigits_, cQuant, nTimes1, _nTimes2_)

	  #------------------------------------------------#
	 #  GETTING THE STRING PATTERN ANT ITS FRAGMENTS  #
	#------------------------------------------------#

	# Returns the regular expression made so far, the fragments joined in order.
	#
	#   returns    a text; empty for a new maker
	#   see        Fragments, Fragment, Sequences
	def Pattern()
		_cResult_ = ""

		_nAcFragments1Len_ = len(@acFragments)
		for _iLoopAcFragments1_ = 1 to _nAcFragments1Len_
			_cFrag_ = @acFragments[_iLoopAcFragments1_]
			_cResult_ += _cFrag_
		next

		return _cResult_

	  #-----------------------------------------------#
	 #  GETTING THE FRAGMENTS OF THE PATTERN STRING  #
	#-----------------------------------------------#

	# Returns the pieces of the pattern in the order they were added.
	#
	#   returns    a list of texts
	#   note       Frags is the same call
	#   see        Pattern, Fragment, NumberOfFragements
	def Fragments()
		return @acFragments

		def Frags()
			return This.Fragments()

	# Returns how many pieces the pattern has so far.
	#
	#   returns    a number
	#   note       the original name is misspelled (Fragements) and is kept; NumberOfFragments,
	#              HowManyFragments, CountFragments, NumberOfFrags, HowManyFrags and CountFrags give
	#              the same answer
	#   see        Fragments, Fragment
	def NumberOfFragements()
		return len(@acFragments)

		#< @FunctionAlternativeForms

		def NumberOfFragments()
			return This.NumberOfFragements()

		def HowManyFragments()
			return This.NumberOfFragments()

		def CountFragments()
			return This.NumberOfFragments()

		#--

		def NumberOfFrags()
			return This.NumberOfFragments()

		def HowManyFrags()
			return This.NumberOfFragments()

		def CountFrags()
			return This.NumberOfFragments()

	# Returns the nth piece of the pattern.
	#
	#   n          the position of the piece, from 1
	#   returns    a text
	#   note       Frag is the same call; the pieces and the sequences are not numbered alike,
	#              because AddLiteral and the helpers that add text make a piece and no sequence
	#   warning    raises an error for a position past the last piece
	#   see        Fragments, Sequence
		#>
	def Fragment(n)
		return @acFragments[n]

		def Frag(n)
			return This.Fragment(n)

	# Returns the nth piece of the pattern together with the sequence that made it.
	#
	#   n          the position of the piece, from 1
	#   returns    a list of two items: the piece, and its sequence as [ type, range, repeat kind,
	#              count, count2 ] or an empty list when the piece was made by AddLiteral, a group or
	#              another helper that records no sequence
	#   note       FragXT, FragmentAndSequence, FragAndSeq, FragmentAndItsSequence, FragAndItsSeq and
	#              FragSeq are the same call
	#   warning    raises an error for a position past the last piece
	#   see        Fragment, SequenceXT
	def FragmentXT(n)
		_aSeq_ = []
		_nSeqs_ = len(@anSeqFrag)
		for _iSeq_ = 1 to _nSeqs_
			if @anSeqFrag[_iSeq_] = n
				_aSeq_ = @aSequences[_iSeq_]
				exit
			ok
		next

		return [ @acFragments[n], _aSeq_ ]

		#< @FunctionAlternativeForms

		def FragXT(n)
			return This.FragmentXT(n)

		def FragmentAndSequence(n)
			return This.FragmentXT(n)

		def FragAndSeq(n)
			return This.FragmentXT(n)

		def FragmentAndItsSequence(n)
			return This.FragmentXT(n)

		def FragAndItsSeq(n)
			return This.FragmentXT(n)

		def FragSeq(n)
			return This.FragmentXT(n)

		#>

	# Returns every piece of the pattern paired with the sequence that made it.
	#
	#   returns    a list of pairs, one per piece, each [ piece, sequence ] where the sequence is
	#              [ type, range, repeat kind, count, count2 ], or an empty list for a piece that was
	#              made by AddLiteral, a group or another helper that records no sequence
	#   note       FragsXT is the same call; the pairs follow the pieces, so a literal in front of a
	#              range does not shift the ranges that come after it
	#   see        FragmentXT, SequencesXT
	def FragmentsXT()
		_aResult_ = []
		_nFragments_ = len(@acFragments)
		for _iFragment_ = 1 to _nFragments_
			_aResult_ + This.FragmentXT(_iFragment_)
		next
		return _aResult_

		def FragsXT()
			return This.FragmentsXT()

	  #---------------------------#
	 #  GETTING THE QUANTIFIERS  #
	#---------------------------#

	# Reserves the name for the quantifiers added so far; it computes nothing yet and answers an empty text.
	#
	#   returns    an empty text, whatever was added
	#   warning    placeholder: no class header, block or test says what it should return, so it is
	#              kept as it was; the repeat kind and the counts of each range are in Sequences, items
	#              3 to 5 of every sequence
	#   see        QuantifiersCommands, Sequences
	def Quantifiers()
		#TODO

	# Reserves the name for the quantifiers of the recorded sequences; it computes nothing yet and answers an empty text.
	#
	#   returns    an empty text, whatever was added
	#   note       QuantifiersXT is the same placeholder
	#   warning    placeholder: nothing states what it should return, so it is kept as it was; read the
	#              repeat kinds and counts with Sequences
	#   see        Quantifiers, Sequences
	def QuantifiersCommands()
		#TODO

		def QuantifiersXT()

	  #-------------------------------------------------------------#
	 #  GETTING THE SEQUENCES (FRAGMENTS IN COMPUTABLE DATA FORM)  #
	#-------------------------------------------------------------#

	# Returns the calls that built the ranges, each as [ type, range, repeat kind, count, count2 ].
	#
	#   returns    a list of lists
	#   note       only AddRange and the methods that call it record a sequence; AddLiteral,
	#              AddCapturingGroup and the other fragment adders do not; Seqs and Commands are the
	#              same call
	#   see        Sequence, Fragments, SequencesXT
	def Sequences()
		return @aSequences

		def Seqs()
			return This.Sequences()

		def Commands()
			return This.Sequences()

	# Counts the sequences recorded by the range-adding calls.
	#
	#   returns    a number; 0 for a new maker or when only literals and groups were added
	#   note       HowManySequences, CountSequences, NumberOfSeqs, HowManySeqs, CountSeqs,
	#              NumberOfCommands, HowManyCommands and CountCommands give the same answer; the count
	#              of pieces is NumberOfFragements
	#   see        Sequences, NumberOfFragements
	def NumberOfSequences()
		return len(@aSequences)

		#< @FunctionAlternativeForms

		def HowManySequences()
			return This.NumberOfSequences()

		def CountSequences()
			return This.NumberOfSequences()

		#--

		def NumberOfSeqs()
			return This.NumberOfSequences()

		def HowManySeqs()
			return This.NumberOfSequences()

		def CountSeqs()
			return This.NumberOfSequences()

		#--

		def NumberOfCommands()
			return This.NumberOfSequences()

		def HowManyCommands()
			return This.NumberOfSequences()

		def CountCommands()
			return This.NumberOfSequences()

	# Returns the nth recorded sequence as [ type, range, repeat kind, count, count2 ].
	#
	#   n          the position of the sequence, from 1
	#   returns    a list
	#   note       Seq and Command are the same call; the sequences are numbered apart from the
	#              pieces, because AddLiteral and the helpers that add text make a piece and no
	#              sequence
	#   warning    raises No sequence n for a position that is not between 1 and the number of
	#              sequences, which includes position 1 when only literals were added
	#   see        Sequences, SequenceXT
		#>
	def Sequence(n)
		if NOT pvtHasSequence(n)
			StzRaise("No sequence " + @@(n) + ": the maker holds " + len(@aSequences) + " sequence(s).")
		ok

		return @aSequences[n]

		def Seq(n)
			return This.Sequence(n)

		def Command(n)
			return This.Sequence(n)

	# Returns the nth recorded sequence together with the piece of the pattern it made.
	#
	#   n          the position of the sequence, from 1
	#   returns    a list of two items: the sequence as [ type, range, repeat kind, count, count2 ],
	#              and its piece as a text
	#   note       SeqXT, SequenceAndFragment, SeqAndFrag, SequenceAndItsFragment, SeqAndItsFrag and
	#              SeqFrag are the same call; the piece is the one the sequence made, whatever
	#              literals were added around it
	#   warning    raises No sequence n for a position past the last sequence
	#   see        Sequence, FragmentXT
	def SequenceXT(n)
		_aSeq_ = This.Sequence(n)
		_nFrag_ = @anSeqFrag[n]
		return [ _aSeq_, @acFragments[_nFrag_] ]

		#< @FunctionAlternativeForms

		def SeqXT(n)
			return This.SequenceXT(n)

		def SequenceAndFragment(n)
			return This.SequenceXT(n)

		def SeqAndFrag(n)
			return This.SequenceXT(n)

		def SequenceAndItsFragment(n)
			return This.SequenceXT(n)

		def SeqAndItsFrag(n)
			return This.SequenceXT(n)

		def SeqFrag(n)
			return This.SequenceXT(n)

		#--

		# Pairs the nth recorded sequence with the piece it made, under the command name.
		#
		#   n          the position of the sequence, from 1
		#   returns    a list of the sequence and its piece
		#   note       the same call as SequenceXT
		#   warning    raises No sequence n for a position past the last sequence
		#   see        SequenceXT, Fragment
		def CommandXT(n)
			return This.SequenceXT(n)

		# Pairs the nth recorded sequence with the piece it made, in the long command form.
		#
		#   n          the position of the sequence, from 1
		#   returns    a list of the sequence and its piece
		#   note       the same call as SequenceXT
		#   warning    raises No sequence n for a position past the last sequence
		#   see        SequenceXT, Fragment
		def CommandAndFragment(n)
			return This.SequenceXT(n)

		# Pairs the nth recorded sequence with the piece it made, in the short command form.
		#
		#   n          the position of the sequence, from 1
		#   returns    a list of the sequence and its piece
		#   note       the same call as SequenceXT
		#   warning    raises No sequence n for a position past the last sequence
		#   see        CommandAndFragment, SequenceXT
		def CommandAndFrag(n)
			return This.SequenceXT(n)

		# Pairs the nth recorded sequence with the piece it made, saying that the piece is its own.
		#
		#   n          the position of the sequence, from 1
		#   returns    a list of the sequence and its piece
		#   note       the same call as SequenceXT
		#   warning    raises No sequence n for a position past the last sequence
		#   see        CommandAndFragment, SequenceXT
		def CommandAndItsFragment(n)
			return This.SequenceXT(n)

		# Pairs the nth recorded sequence with the piece it made, in the short possessive form.
		#
		#   n          the position of the sequence, from 1
		#   returns    a list of the sequence and its piece
		#   note       the same call as SequenceXT
		#   warning    raises No sequence n for a position past the last sequence
		#   see        CommandAndFragment, SequenceXT
		def CommandAndItsFrag(n)
			return This.SequenceXT(n)

		#>

	# Returns every recorded sequence paired with the piece it made.
	#
	#   returns    a list of pairs, one per sequence, each [ sequence, piece ]
	#   note       SeqsXT and CommandsXT are the same call; only the pieces made by a range call appear,
	#              so literals and groups do not shift the pairs
	#   see        SequenceXT, FragmentsXT
	def SequencesXT()
		_aResult_ = []
		_nSequences_ = len(@aSequences)
		for _iSequence_ = 1 to _nSequences_
			_aResult_ + This.SequenceXT(_iSequence_)
		next
		return _aResult_

		def SeqsXT()
			return This.SequencesXT()

		def CommandsXT()
			return This.SequencesXT()

	# Appends a copy of the nth recorded sequence and of the piece it made to the end of the pattern.
	#
	#   n          the position of the sequence to repeat, from 1
	#   returns    nothing; read the result with Pattern
	#   note       the piece copied is the one the sequence made, whatever literals were added
	#              around it; after AddCharsRange("a-f", :repeatedExactly, 2, 0) it gives
	#              [a-f]{2}[a-f]{2}; the copy is a sequence of its own, so it can be repeated again
	#   warning    raises No sequence n for a position that is not between 1 and the number of
	#              sequences, which includes position 1 when only literals were added
	#   see        RepeatCommand, Sequence
	def RepeatSequence(n)
		if NOT pvtHasSequence(n)
			StzRaise("No sequence " + @@(n) + ": the maker holds " + len(@aSequences) + " sequence(s).")
		ok

		_aSeq_ = @aSequences[n]
		_cFrag_ = @acFragments[ @anSeqFrag[n] ]

		@acFragments + _cFrag_
		@aSequences + _aSeq_
		@anSeqFrag + len(@acFragments)

		# Appends a copy of the nth recorded sequence and of its piece to the end of the pattern.
		#
		#   n          the position of the sequence to repeat, from 1
		#   returns    nothing; read the result with Pattern
		#   note       the same as RepeatSequence
		#   see        RepeatSequence
		def RepeatCommand(n)
			This.RepeatSequence(n)

	  #-----------------------------------------------#
	 #  DESIGING THE PATTERN IN A DECLARATIVE STYLE  #
	#-----------------------------------------------#

	# Appends a character class given as a named pair: between two chars, among some chars, or from one char to another.
	#
	#   p          the named pair: Between or From with the two end characters, or Among with the
	#              characters, for example [ between, [ A, [ and, Z ] ] ] or [ among, [ -, SPACE ] ]
	#   pRepeat    a number for that many times, or a repeat pair such as [ RepeatedExactly, 2 ]
	#   returns    nothing; read the result with Pattern
	#   note       :Between = [ "A", :And = "Z" ] with :RepeatedExactly = 2Times() gives [A-Z]{2};
	#              From takes the same shapes as Between; CanContaingChar is the same call
	#   warning    a p that is not a list raises Incorrect param type!, and a pair named otherwise
	#              than Between, Among or From raises Unknown class kind
	#   see        CanContainACharBetween, CanContainACharAmong
	def CanContainAChar(p, pRepeat)

		if NOT isList(p)
			StzRaise("Incorrect param type! p must be a list.")
		ok

		# Constructing the chars from the first param p

		_cKind_ = pvtKindOf(p)

		if _cKind_ = "between" or _cKind_ = "from"
		# CanContainAChar(:Between = [ "A", :And = "Z" ], :RepeatedExactly = 2Times())
		# CanContainAChar(:Between = "A-Z", :RepeatedExactly = 2)

			This.CanContainACharBetween(p[2], pRepeat)

		but _cKind_ = "among"
		# CanContainAChar(:Among = [ "-", " " ], :RepeatedAtMost = 1Time())
		# CanContainAChar(:Among = "- ", :RepeatedAtMost = 1Time())

			This.CanContainACharAmong(p[2], pRepeat)

		else
			StzRaise("Unknown class kind! p must be a pair named Between, Among or From.")
		ok

		# Appends a character class given as a named pair, under a misspelled name.
		#
		#   p          the named pair: Between, Among or From with their characters
		#   pRepeat    a number for that many times, or a repeat pair such as [ RepeatedExactly, 2 ]
		#   returns    nothing; read the result with Pattern
		#   note       the same call as CanContainAChar, kept under the misspelled name
		#   see        CanContainAChar
		def CanContaingChar(p, pRepeat)
			This.CanContainAChar(p, pRepeat)

	# Appends a class that matches one character from the first given char to the second, repeated as asked.
	#
	#   paChars    the two end characters as a list such as [ A, Z ] or [ A, [ and, Z ] ], or as a
	#              text such as A-Z
	#   pRepeat    a number for that many times, or a pair such as [ RepeatedBetween, [ 2, 4 ] ]
	#   returns    nothing; read the result with Pattern
	#   note       [ A, Z ] with 3 gives [A-Z]{3}, and so does A-Z; RepeatedAtMost with 1 writes ? and
	#              with n writes {0,n}; CanContainCharBetween is the same call
	#   warning    anything that is not two chars raises Can't proceed! You must provide two chars;
	#              a repeat name it does not know raises Unknown repeat kind
	#   see        CanContainACharAmong, AddCharsRange
	def CanContainACharBetween(paChars, pRepeat)
		# CanContainAChar(:Between = [ "A", :And = "Z" ], :RepeatedExactly = 2Times())
		# CanContainAChar(:Between = "A-Z", :RepeatedExactly = 2)

		# Resolving the chars param

		_between_ = paChars
		_c1_ = ""
		_c2_ = ""

		if isString(_between_)

			_acBetween_ = Chars(_between_)

			if len(_acBetween_) = 3 and _acBetween_[2] = "-"

				_c1_ = _acBetween_[1]
				_c2_ = _acBetween_[3]

			ok

		but isList(_between_)

			if len(_between_) = 2

				_c1_ = _between_[1]

				if pvtIsLinkedPair(_between_[2])

					_c2_ = _between_[2][2]

				else
					_c2_ = _between_[2]
				ok

			ok

		ok

		if NOT ( isString(_c1_) and isString(_c2_) and _c1_ != "" and _c2_ != "" )
			StzRaise("Can't proceed! You must provide two chars.")
		ok

		_cChars_ = _c1_ + "-" + _c2_

		# Resolving the repetition params

		_aRepeat_ = pvtGetRepeat(pRepeat)

		_cRepeat_ = _aRepeat_[1]
		_n1_ = _aRepeat_[2]
		_n2_ = _aRepeat_[3]

		This.AddCharsRange(_cChars_, _cRepeat_, _n1_, _n2_)


		#< @FunctionAlternativeForm

		def CanContainCharBetween(paChars, pRepeat)
			return This.CanContainACharBetween(paChars, pRepeat)

	# Appends a class that matches one of the given characters, repeated as asked.
	#
	#   pChars     the characters as a text or a list of chars
	#   pRepeat    a number for that many times, or a repeat pair such as [ RepeatedAtMost, 1 ]
	#   returns    nothing; read the result with Pattern
	#   note       abc with [ RepeatedAtMost, 1 ] gives [abc]?; CanContainCharAmong is the same call
	#   warning    a value that is neither a text nor a list of chars raises Incorrect param type!
	#   see        CanContainACharBetween, AddAmongChars
		#>
	def CanContainACharAmong(pChars, pRepeat)
		# CanContainACharAmong([ "A", "B", "C" ], :RepeatedAtMost = 1Time())
		# CanContainACharAmong("ABC", :RepeatedAtMost = 1Time())


		if NOT ( isString(pChars) or ( isList(pChars) and IsListOfChars(pChars) ) )
			StzRaise("Incorrect param type! pChars must be a string or list of chars.")
		ok

		if isString(pChars)
			_acChars_ = Chars(pChars)

		else // isListOfChars(pChars)
			_acChars_ = pChars
		ok

		# Resolving the repetition params

		_aRepeat_ = pvtGetRepeat(pRepeat)

		_cRepeat_ = _aRepeat_[1]
		_n1_ = _aRepeat_[2]
		_n2_ = _aRepeat_[3]

		This.AddAmongChars(_acChars_, _cRepeat_, _n1_, _n2_)


		def CanContainCharAmong(pChars, pRepeat)
			return This.CanContainACharAmong(pChars, pRepeat)

	# Appends a digit class given as a named pair: between two digits, among some digits, or from one digit to another.
	#
	#   p          the named pair: Between or From with the two end digits, or Among with the digits,
	#              for example [ from, [ 0, [ to, 9 ] ] ] or [ among, 135 ]
	#   pRepeat    a number for that many times, or a repeat pair such as [ RepeatedExactly, 3 ]
	#   returns    nothing; read the result with Pattern
	#   note       :From = [ "0", :To = "9" ] with :RepeatedExactly = 3Times() gives [0-9]{3}; Between
	#              takes the same shapes as From
	#   warning    a p that is not a list raises Incorrect param type!, and a pair named otherwise
	#              than Between, Among or From raises Unknown class kind
	#   see        CanContainADigitBetween, CanContainADigitAmong
	#@ aka  --
	def CanContainADigit(p, pRepeat)

		if NOT isList(p)
			StzRaise("Incorrect param type! p must be a list.")
		ok

		# Constructing the digits from the first param p

		_cKind_ = pvtKindOf(p)

		if _cKind_ = "between" or _cKind_ = "from"
			This.CanContainADigitBetween(p[2], pRepeat)

		but _cKind_ = "among"
			This.CanContainADigitAmong(p[2], pRepeat)

		else
			StzRaise("Unknown class kind! p must be a pair named Between, Among or From.")
		ok

		# Appends a digit class given as a named pair, under a misspelled name.
		#
		#   p          the named pair: Between, Among or From with their digits
		#   pRepeat    a number for that many times, or a repeat pair such as [ RepeatedExactly, 3 ]
		#   returns    nothing; read the result with Pattern
		#   note       the same call as CanContainADigit, kept under the misspelled name
		#   see        CanContainADigit
		def CanContaingdigit(p, pRepeat)
			This.CanContainADigit(p, pRepeat)

	# Appends a class that matches one digit from the first given digit to the second, repeated as asked.
	#
	#   paDigits   the two end digits as a list such as [ 0, 9 ] or [ 0, [ to, 9 ] ], or as a text
	#              such as 0-9
	#   pRepeat    a number for that many times, or a pair such as [ RepeatedExactly, 3 ]
	#   returns    nothing; read the result with Pattern
	#   note       [ 0, 9 ] with 3 gives [0-9]{3}, and so does 0-9; CanContainDigitBetween is the same
	#              call
	#   warning    an end that is not a digit raises Can't proceed! You must provide two digits as
	#              chars; a repeat name it does not know raises Unknown repeat kind
	#   see        CanContainADigitAmong, AddDigitsRange
	def CanContainADigitBetween(paDigits, pRepeat)

		# Resolving the digits param

		_between_ = paDigits
		_cDigit1_ = ""
		_cDigit2_ = ""

		if isString(_between_)

			_acBetween_ = Chars(_between_)

			if len(_acBetween_) = 3 and _acBetween_[2] = "-"

				_cDigit1_ = _acBetween_[1]
				_cDigit2_ = _acBetween_[3]

			ok

		but isList(_between_)

			if len(_between_) = 2

				_cDigit1_ = _between_[1]

				if pvtIsLinkedPair(_between_[2])

					_cDigit2_ = _between_[2][2]

				else
					_cDigit2_ = _between_[2]
				ok

			ok

		ok

		# A number such as 0 or 9 stands for its digit

		_cDigit1_ = pvtDigitText(_cDigit1_)
		_cDigit2_ = pvtDigitText(_cDigit2_)

		if _cDigit1_ = "" or _cDigit2_ = ""

			StzRaise("Can't proceed! You must provide two digits as chars.")
		ok

		_cDigits_ = _cDigit1_ + "-" + _cDigit2_

		# Resolving the repetition params

		_aRepeat_ = pvtGetRepeat(pRepeat)

		_cRepeat_ = _aRepeat_[1]
		_n1_ = _aRepeat_[2]
		_n2_ = _aRepeat_[3]

		This.AddCharsRange(_cDigits_, _cRepeat_, _n1_, _n2_)


		#< @FunctionAlternativeForm

		def CanContainDigitBetween(padigits, pRepeat)
			return This.CanContainADigitBetween(paDigits, pRepeat)

	# Appends a class that matches one of the given digits, repeated as asked.
	#
	#   pDigits    the digits as a text such as 135, or as a list of digits such as [ 1, 3 ] or
	#              [ "1", "3" ]
	#   pRepeat    a number for that many times, or a repeat pair such as [ RepeatedExactly, 3 ]
	#   returns    nothing; read the result with Pattern
	#   note       135 with 3 gives [135]{3}, and so does [ 1, 3, 5 ]; CanContainDigitAmong is the same
	#              call
	#   warning    anything that is not made of single digits raises Incorrect param type!
	#   see        CanContainADigitBetween, AddAmongDigits
		#>
	def CanContainADigitAmong(pDigits, pRepeat)

		_acItems_ = []

		if isString(pDigits)
			_acItems_ = Chars(pDigits)

		but isList(pDigits)
			_acItems_ = pDigits
		ok

		_acDigits_ = []
		_nItems_ = len(_acItems_)
		_bOk_ = ( _nItems_ > 0 )

		for _i_ = 1 to _nItems_
			_item_ = pvtDigitText(_acItems_[_i_])

			if _item_ != ""
				_acDigits_ + _item_
			else
				_bOk_ = 0
				exit
			ok
		next

		if NOT _bOk_
			StzRaise("Incorrect param type! pDigits must be digits in a list or string.")
		ok

		# Resolving the repetition params

		_aRepeat_ = pvtGetRepeat(pRepeat)

		_cRepeat_ = _aRepeat_[1]
		_n1_ = _aRepeat_[2]
		_n2_ = _aRepeat_[3]

		This.AddAmongChars(_acDigits_, _cRepeat_, _n1_, _n2_)


		def CanContainDigitAmong(pDigits, pRepeat)
			return This.CanContainADigitAmong(pDigits, pRepeat)

	  #----------------------------#
	 #  ADDING A LITTERAL STRING  #
	#----------------------------#

	# Appends a text to the pattern exactly as given, with nothing escaped.
	#
	#   pcStr      the text to append
	#   returns    nothing; read the result with Pattern
	#   note       a.b stays a.b, so the dot matches any character; it adds a piece and no sequence
	#   see        Pattern, AddRange
	def AddLiteral(pcStr)
		@acFragments + pcStr

	  #------------------------------#
	 #     CHARACTER CLASS HELPER    #
	#------------------------------#
	
	# Appends a shorthand class repeated any number of times, such as [\d]* for digit.
	#
	#   pcClass    word, nonWord, digit, nonDigit, space or nonSpace
	#   returns    nothing; read the result with Pattern
	#   note       any other name adds nothing and raises nothing; the suffix is always *, zero or
	#              more
	#   see        AddCharClass, AddRange
	def AddCharacterClass(pcClass)
		# Example usage:
		# o1 = new stzRegexMaker
		# o1.AddCharacterClass(:word)      # Matches word chars
		# o1.AddCharacterClass(:nonDigit)  # Matches non-digits
	
		switch pcClass
		on :word
			AddRange(:among, "\w", :RepeatedSeveralTimes, 0, 0)
	
		on :nonWord 
			AddRange(:among, "\W", :RepeatedSeveralTimes, 0, 0)
	
		on :digit
			AddRange(:among, "\d", :RepeatedSeveralTimes, 0, 0)
	
		on :nonDigit
			AddRange(:among, "\D", :RepeatedSeveralTimes, 0, 0)
	
		on :space  
			AddRange(:among, "\s", :RepeatedSeveralTimes, 0, 0)
	
		on :nonSpace
			AddRange(:among, "\S", :RepeatedSeveralTimes, 0, 0)
		off
	
		# Appends a shorthand class repeated any number of times.
		#
		#   pcClass    word, nonWord, digit, nonDigit, space or nonSpace
		#   returns    nothing; read the result with Pattern
		#   note       the same call as AddCharacterClass
		#   see        AddCharacterClass
		def AddCharClass(pcClass)
			This.AddCharacterClass(pcClass)

		# Appends a shorthand class repeated any number of times.
		#
		#   pcClass    word, nonWord, digit, nonDigit, space or nonSpace
		#   returns    nothing; read the result with Pattern
		#   note       the same call as AddCharacterClass
		#   see        AddCharacterClass
		def AddClass(pcClass)
			This.AddCharacterClass(pcClass)

	  #------------------------------#
	 #     COMMON PATTERN HELPER    # 
	#------------------------------#
	
	# Appends a ready-made pattern chosen by name from the library's pattern data.
	#
	#   pcType     the pattern name, for example email or integer
	#   returns    nothing; read the result with Pattern
	#   note       email gives [a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,} and integer gives
	#              ^-?\d+$
	#   warning    raises The pattern name you provided does not exist in stzRegexData file. for an
	#              unknown name
	#   see        AddLiteral, StzRxp
	def AddCommonPattern(pcType)
		# Example :
		# o1 = new stzRegexMaker
		# o1.AddCommonPattern(:email)  # Matches email addresses
		# o1.AddCommonPattern(:phone)  # Matches phone numbers
	
		@acFragments + rxp(pcType)
	
	  #-------------------------------#
	 #     BACKREFERENCE HELPER      #
	#-------------------------------#
	
	# Appends a reference to an earlier group, by name as (?P=name) or by number.
	#
	#   pcGroupName   the group name as a text, or the group number
	#   returns       nothing; read the result with Pattern
	#   note          a name gives (?P=w); the number 1 gives \1, with one backslash, and a number
	#                 above 9 gives \g{12} so that it is not read as an octal code
	#   warning       a value that is neither a text nor a number adds nothing and raises nothing; the
	#                 name or number is not checked against the groups added so far
	#   see           DefineGroup, AddCapturingGroup
	def AddBackReference(pcGroupName)
		# Example usage:
		# o1 = new stzRegexMaker
		# o1.AddCapturingGroup("tag", "<([a-z]+)>.*?</\1>")
		# o1.AddBackreference("tag")  # Matches same tag again
	
		if isString(pcGroupName)
			@acFragments + ("(?P=" + pcGroupName + ")")
		but isNumber(pcGroupName)  
			if pcGroupName > 9
				@acFragments + ("\g{" + pcGroupName + "}")
			else
				@acFragments + (char(92) + pcGroupName)
			ok
		ok
	
	  #-------------------------------#
	 #     UNICODE CATEGORY HELPER   #
	#-------------------------------#
	
	# Appends a Unicode category escape such as \p{L} for letter.
	#
	#   pcCategory   letter, number, punctuation or symbol
	#   returns      nothing; read the result with Pattern
	#   note         any other name adds nothing and raises nothing
	#   see          AddCharacterClass
	def AddUnicodeCategory(pcCategory)
		# Example usage:
		# o1 = new stzRegexMaker
		# o1.AddUnicodeCategory(:letter)      # Matches any letter
		# o1.AddUnicodeCategory(:punctuation) # Matches punctuation
	
		switch pcCategory
		on :letter
			@acFragments + "\p{L}"
		on :number
			@acFragments + "\p{N}" 
		on :punctuation 
			@acFragments + "\p{P}"
		on :symbol
			@acFragments + "\p{S}"
		off
	
	  #-------------------------------#
	 #     WORD BOUNDARY HELPER      #
	#-------------------------------#
	
	# Appends a word boundary assertion.
	#
	#   pcType     start or end for \b, none for \B
	#   returns    nothing; read the result with Pattern
	#   note       start and end write the same \b
	#   see        AddLiteral
	def AddWordBoundary(pcType)
		# Example : 
		# o1 = new stzRegexMaker
		# o1.AddWordBoundary(:start)
		# o1.AddAmongChars("test")   # Matches "test" at word start
		# o1.AddWordBoundary(:end)
	
		switch pcType
		on :start
			@acFragments + "\b"
		on :end  
			@acFragments + "\b"
		on :none
			@acFragments + "\B"
		off
	
	  #--------------------------------#
	 #     CAPTURING GROUP HELPER     #
	#--------------------------------#
	
	# Appends a group around a pattern: named, non-capturing or atomic.
	#
	#   pcName      a group name for (?P<name>...), nonCapturing for (?:...) or atomic for (?>...)
	#   pcPattern   the pattern inside the group
	#   returns     nothing; read the result with Pattern
	#   note        unlike DefineGroup it does not remember the group, so ReuseGroupPattern cannot
	#               find it
	#   see         DefineGroup, AddBackReference
	def AddCapturingGroup(pcName, pcPattern) 
		# Example :
		# o1 = new stzRegexMaker
		# o1.AddCapturingGroup("number", "\d+")     	# Named group
		# o1.AddCapturingGroup(:nonCapturing, "\w+") 	# Non-capturing
		# o1.AddCapturingGroup(:atomic, "[aeiou]+")  	# Atomic group
	
		if pcName = :nonCapturing
			@acFragments + ("(?:" + pcPattern + ")")
		
		but pcName = :atomic
			@acFragments + ("(?>" + pcPattern + ")")
		
		but isString(pcName)
			@acFragments + ("(?P<" + pcName + ">" + pcPattern + ")")
		ok
	
	  #-----------------------------------------#
	 #     MATCH LENGTH BEHAVIOR HELPER        #
	#-----------------------------------------#
	
	# Appends a pattern followed by a length behaviour: + for longest, +? for shortest, ++ for complete.
	#
	#   pcPattern    the pattern to repeat
	#   pcBehavior   longest, shortest or complete
	#   returns      nothing; read the result with Pattern
	#   note         any other behaviour adds nothing
	#   see          AddVariableLength
	def AddMatchLength(pcPattern, pcBehavior)
		# Example :
		# o1 = new stzRegexMaker  
		
		# Match shortest sequence of word chars:
		# o1.AddMatchLength("\w+", :shortest)   # In "abc def", matches "abc" then "def"
		
		# Match longest sequence of digits:
		# o1.AddMatchLength("[0-9]+", :longest) # In "12 345", matches "12345"
		
		# Match complete sequence without reconsidering matches:
		# o1.AddMatchLength(".+", :complete)    # In "<a>b</a>", matches entire string
	
		switch pcBehavior
		on :longest    # Takes longest possible match (formerly 'greedy')
			@acFragments + (pcPattern + "+")
	
		on :shortest   # Takes shortest possible match (formerly 'lazy')
			@acFragments + (pcPattern + "+?")
	
		on :complete   # Matches everything at once without backtracking (formerly 'possessive')
			@acFragments + (pcPattern + "++")
		off
	
	  #--------------------------------#
	 #     VARIABLE LENGTH HELPER      #
	#--------------------------------#
	
	# Appends a pattern followed by a quantifier style: + greedy, +? lazy, ++ possessive.
	#
	#   pcPattern      the pattern to repeat
	#   pcQuantifier   greedy, lazy or possessive
	#   returns        nothing; read the result with Pattern
	#   note           any other style adds nothing
	#   see            AddMatchLength
	def AddVariableLength(pcPattern, pcQuantifier)
		# Example :
		# o1 = new stzRegexMaker  
		# o1.AddVariableLength("\w+", :lazy)     	# Lazy match
		# o1.AddVariableLength("[0-9]+", :greedy) 	# Greedy match
	
		switch pcQuantifier
		on :possessive
			@acFragments + (pcPattern + "++")
		on :lazy
			@acFragments + (pcPattern + "+?")
		on :greedy
			@acFragments + (pcPattern + "+")
		off
	
	  #----------------------#
	 #    COMMENT HELPER    #
	#----------------------#
	
	# Appends an inline comment group that the matcher ignores.
	#
	#   pcText     the comment text
	#   returns    nothing; read the result with Pattern
	#   note       year gives (?#year)
	#   see        AddLiteral
	def AddComment(pcText)
		# Example :
		# o1 = new stzRegexMaker
		# o1.AddComment("Match emails") 
		# o1.AddCommonPattern(:email)
	
		@acFragments + ("(?#" + pcText + ")")
	
	  #--------------------------------#
	 #     CASE SENSITIVITY HELPER    #
	#--------------------------------#
	
	# Appends a case flag that applies from that point on.
	#
	#   pcMode     insensitive for (?i), sensitive for (?-i) or mixed for (?i:)
	#   returns    nothing; read the result with Pattern
	#   note       it is added as a piece, so it only affects what follows it
	#   see        SetCaseXT
	def SetCase(pcMode)
		This.SetCaseXT(pcMode, "")

	def SetCaseXT(pcMode, pcPattern)
		# Example :
		# o1 = new stzRegexMaker
		# o1.SetCaseXT(:insensitive, "Test")  # Matches test/TEST/Test
		# o1.SetCaseXT(:sensitive, "Test")    # Matches only "Test"
	
		switch pcMode
		on :insensitive
			@acFragments + ("(?i)" + pcPattern)
		on :sensitive  
			@acFragments + ("(?-i)" + pcPattern)
		on :mixed
			@acFragments + ("(?i:" + pcPattern + ")")
		off
	
	  #--------------------------------#
	 #     PATTERN COMPOSITION        #
	#--------------------------------#
	
	# Appends several patterns combined as all-must-match look-aheads, as alternatives, or one after the other.
	#
	#   paPatterns   the patterns as a list of texts
	#   pcMode       and for look-aheads that must all hold, or for alternatives, sequence for the
	#                patterns written one after the other
	#   returns      nothing; read the result with Pattern
	#   note         a and b give (?=a)(?=b) in and mode, (a|b) in or mode and ab in sequence mode;
	#                each call adds one piece
	#   warning      an unknown mode adds nothing and raises nothing; the patterns are not escaped
	#   see          DefineGroup, AddLiteral
	def ComposePatterns(paPatterns, pcMode)
		# Example :
		# o1 = new stzRegexMaker
		# patterns = ["\d+", "[A-Z]+"]
		# o1.ComposePatterns(patterns, :and)  # Must contain both
		# o1.ComposePatterns(patterns, :or)   # Contains either
	
		switch pcMode
		on :and
			_cResult_ = ""
			_nPatterns1Len_ = len(paPatterns)
			for _iLoopPatterns1_ = 1 to _nPatterns1Len_
				_cPattern_ = paPatterns[_iLoopPatterns1_]
				_cResult_ += "(?=" + _cPattern_ + ")"
			next
			@acFragments + _cResult_
			
		on :or
			_cResult_ = ""
			_nPatterns1Len_ = len(paPatterns)
			for _iLoopPatterns1_ = 1 to _nPatterns1Len_
				if _iLoopPatterns1_ > 1
					_cResult_ += "|"
				ok
				_cResult_ += paPatterns[_iLoopPatterns1_]
			next
			@acFragments + ("(" + _cResult_ + ")")
			
		on :sequence
			_cResult_ = ""
			_nPatterns1Len_ = len(paPatterns)
			for _iLoopPatterns1_ = 1 to _nPatterns1Len_
				_cResult_ += paPatterns[_iLoopPatterns1_]
			next
			@acFragments + _cResult_
		off

	  #----------------------------------------#
	 #     GROUP REFERENCE SYSTEM             #
	#----------------------------------------#

	# Appends a named group, remembers its pattern for later reuse, and returns how many groups are defined.
	#
	#   pcName      the group name
	#   pcPattern   the pattern inside the group
	#   returns     a number, the count of defined groups
	#   note        tag with [a-z]+ gives (?P<tag>[a-z]+) and 1
	#   warning     raises an error when the name is not a text
	#   see         ReuseGroupPattern, FindGroup, MatchOppositeTagAs
	def DefineGroup(pcName, pcPattern)
		# Defines a named capturing group that can be referenced later.
		# Returns group index for error checking.

		# Example:
		# o1.DefineGroup("tag", "<([a-z]+)>")
		# Now "tag" group can be referenced later

		if NOT isString(pcName)
			StzRaise("Group name must be a string")
		ok

		@aGroups + [pcName, pcPattern]
		@acFragments + ("(?P<" + pcName + ">" + pcPattern + ")")
		return len(@aGroups)

	# Appends the pattern of a defined group again, as a non-capturing group.
	#
	#   pcGroupName   the name of a group made with DefineGroup
	#   returns       nothing; read the result with Pattern
	#   note          a group made with AddCapturingGroup is not known to it
	#   warning       raises No group named ... has been defined for an unknown name
	#   see           ReuseGroup, DefineGroup
	def ReuseGroupPattern(pcGroupName)
		# Reuses the pattern of a previously defined group
		# without capturing or referencing any matched content.

		# Example:
		# o1.DefineGroup("word", "\w+")
		# o1.ReuseGroupPattern("word") # Uses same \w+ pattern

		_nGroup_ = FindGroup(pcGroupName)
		if _nGroup_ = 0
			StzRaise("No group named '" + pcGroupName + "' has been defined")
		ok

		@acFragments + ("(?:" + @aGroups[_nGroup_][2] + ")")

		# Appends the pattern of a defined group again, as a non-capturing group.
		#
		#   pcGroupName   the name of a group made with DefineGroup
		#   returns       nothing; read the result with Pattern
		#   note          the same call as ReuseGroupPattern
		#   see           ReuseGroupPattern
		def ReuseGroup(pcGroupName)
			This.ReuseGroupPattern(pcGroupName)

	# Appends a back reference that must match the same text as a defined group, as (?P=name).
	#
	#   pcGroupName   the name of a group made with DefineGroup
	#   returns       nothing; read the result with Pattern
	#   note          after DefineGroup("w", "\w+") a blank class and this call, the pattern matches a
	#                 word twice: the closing tag form is MatchOppositeTagAs
	#   warning       raises No group named ... has been defined for an unknown name
	#   see           MatchOppositeTagAs, DefineGroup
	def MatchSameContentAs(pcGroupName)
		# Requires matching the exact same text that was matched
		# by the referenced group. The group must be defined earlier
		# in the pattern.

		# Example:
		# Match repeated words:
		# o1.DefineGroup("word", "\w+")
		# o1.AddCharacterClass(:space)
		# o1.MatchSameContentAs("word") # Must match same word

		_nGroup_ = FindGroup(pcGroupName)
		if _nGroup_ = 0
			StzRaise("No group named '" + pcGroupName + "' has been defined")
		ok

		@acFragments + ("(?P=" + pcGroupName + ")")

	# Appends the closing tag that matches a defined group, as </(?P=name)>.
	#
	#   pcTagGroupName   the name of a group made with DefineGroup
	#   returns          nothing; read the result with Pattern
	#   note             tag gives </(?P=tag)>
	#   warning          raises No tag group named ... has been defined for an unknown name
	#   see              MatchSameContentAs, DefineGroup
	def MatchOppositeTagAs(pcTagGroupName)
		# Special case for HTML/XML - matches the closing tag
		# for a previously captured opening tag. Group must contain
		# the tag name.

		# Example:
		# Match balanced HTML tags:
		# o1.DefineGroup("tag", "<([a-z]+)>")
		# o1.AddMatchLength(".*", :shortest) 	# Content
		# o1.MatchOppositeTagAs("tag")      	# Closing tag

		_nGroup_ = FindGroup(pcTagGroupName)
		if _nGroup_ = 0
			StzRaise("No tag group named '" + pcTagGroupName + "' has been defined")
		ok

		@acFragments + ("</(?P=" + pcTagGroupName + ")>")

	# Appends a lookahead that requires the pattern of a defined group to come next.
	#
	#   pcGroupName   the name of a group made with DefineGroup
	#   returns       nothing; read the result with Pattern
	#   note          tag with [a-z]+ gives (?=[a-z]+)
	#   warning       raises No group named ... has been defined for an unknown name
	#   see           DefineGroup, ReuseGroupPattern
	def IsBeforeGroup(pcGroupName)
		# Positive lookahead - checks if the referenced group pattern
		# appears ahead without consuming it.

		# Example:
		# Match word before number:
		# o1.DefineGroup("num", "\d+")
		# o1.AddCharacterClass(:word)
		# o1.IsBeforeGroup("num")

		_nGroup_ = FindGroup(pcGroupName)
		if _nGroup_ = 0
			StzRaise("No group named '" + pcGroupName + "' has been defined")
		ok

		@acFragments + ("(?=" + @aGroups[_nGroup_][2] + ")")

	# Returns the position of a defined group by name, or 0.
	#
	#   pcName     the group name
	#   returns    a number
	#   note       only groups made with DefineGroup are known
	#   see        DefineGroup
	def FindGroup(pcName)
		# Returns index of named group or 0 if not found

		_nGroupsLen_ = len(@aGroups)
		for i = 1 to _nGroupsLen_
			if @aGroups[i][1] = pcName
				return i
			ok
		next
		return 0

	#-----------#
	   PRIVATE
	#-----------#

	# Turns a repeat argument into [ kind, first count, second count ]; private, used by the CanContain methods.
	#
	#   pRepeat    a number for exactly that many times, or a pair of a repeat name and a count or a
	#              pair of counts
	#   returns    a list of three values
	#   note       a number n gives RepeatedExactly, n; the names it accepts are RepeatedExactly,
	#              RepeatedAtLeast, RepeatedAtMost, RepeatedBetween, RepeatedSeveralTimes and
	#              RepeatedSeveral
	#   warning    private: calling it from outside raises R26, so it was read through
	#              CanContainACharBetween; anything that is not a pair raises Incorrect param type!,
	#              a name it does not know raises Unknown repeat kind, and RepeatedBetween with one
	#              count instead of two raises Incorrect param type!
	#   see        CanContainACharBetween
	def pvtGetRepeat(pRepeat)
		# [ :RepatedExactly, 3 ],
		# [ :RepeatedAtMost, 2 ],
		# [ :RepeatedBetween, [ 2, 3 ] ]
		# [ :RepeatedSeveral, 0 ]
	
		# Early check
	
		if isNumber(pRepeat)
			return [ :RepeatedExactly, pRepeat, 0 ]
		ok
	
		# Checking the repetition type
	
		if NOT ( isList(pRepeat) and len(pRepeat) = 2 and isString(pRepeat[1]) )
			StzRaise("Incorrect param type! pRepeat must be a pair starting by a string.")
		ok
	
		_aTempList_ = [
			:RepeatedExactly,
			:RepeatedAtLeast,
			:RepeatedAtMost,
			:RepeatedBetween,
			:RepeatedSeveralTimes,
			:RepeatedSeveral
		]
	
		_cRepeat_ = ""

		_nTempLen_ = len(_aTempList_)
		_cWanted_ = StzLower(pRepeat[1])
		for _i_ = 1 to _nTempLen_
			if _cWanted_ = _aTempList_[_i_]
				_cRepeat_ = _cWanted_
				exit
			ok
		next

		if _cRepeat_ = ""
			StzRaise("Unknown repeat kind! Use RepeatedExactly, RepeatedAtLeast, RepeatedAtMost, RepeatedBetween, RepeatedSeveralTimes or RepeatedSeveral.")
		ok
	
		# Checking the quantifier
	
		if NOT ( isNumber(pRepeat[2]) or ( isList(pRepeat[2]) and len(pRepeat[2]) = 2 and
			 isNumber(pRepeat[2][1]) and isNumber(pRepeat[2][2]) ) )
	
			StzRaise("Incorrect param type! pRepeat must be a pair of numbers.")
		ok

		if _cRepeat_ = :RepeatedBetween and NOT isList(pRepeat[2])
			StzRaise("Incorrect param type! RepeatedBetween needs a pair of counts.")
		ok
	
		_n1_ = 0
		_n2_ = 0
	
		if isNumber(pRepeat[2])
			_n1_ = pRepeat[2]
	
		else
			_n1_ = pRepeat[2][1]
			_n2_ = pRepeat[2][2]
		ok
	
		return [ _cRepeat_, _n1_, _n2_ ]

	# Returns the digit a value stands for as a one-char text, or an empty text when it is not a single digit; private.
	#
	#   pValue     a one-char text such as 7, or a whole number from 0 to 9
	#   returns    a text of one char, or an empty text
	#   warning    private: calling it from outside raises R26
	#   see        CanContainADigitBetween, CanContainADigitAmong
	def pvtDigitText(pValue)
		if isNumber(pValue)
			if pValue >= 0
				if pValue <= 9
					if pValue = floor(pValue)
						return "" + pValue
					ok
				ok
			ok
			return ""
		ok

		if isString(pValue)
			if len(pValue) = 1
				if StzFindFirst(pValue, "0123456789") > 0
					return pValue
				ok
			ok
		ok

		return ""

	# Returns the lower-case name of a named pair such as [ between, x ], or an empty text for any other value; private.
	#
	#   pPair      the value to read
	#   returns    a text
	#   warning    private: calling it from outside raises R26
	#   see        CanContainAChar, CanContainADigit
	def pvtKindOf(pPair)
		if isList(pPair)
			if len(pPair) = 2
				if isString(pPair[1])
					return StzLower(pPair[1])
				ok
			ok
		ok

		return ""

	# TRUE if a value is a pair that links two chars: [ and, x ] or [ to, x ], whatever the case of the link word; private.
	#
	#   pPair      the value to test
	#   returns    1 or 0
	#   warning    private: calling it from outside raises R26
	#   see        CanContainACharBetween, CanContainADigitBetween
	def pvtIsLinkedPair(pPair)
		if isList(pPair)
			if len(pPair) = 2
				if isString(pPair[1])
					_cLink_ = StzLower(pPair[1])
					if _cLink_ = "and" or _cLink_ = "to"
						return 1
					ok
				ok
			ok
		ok

		return 0

	# TRUE if a sequence exists at the position; private.
	#
	#   n          the position to test
	#   returns    1 or 0
	#   warning    private: calling it from outside raises R26
	#   see        Sequence, RepeatSequence
	def pvtHasSequence(n)
		if isNumber(n)
			if n >= 1
				if n <= len(@aSequences)
					return 1
				ok
			ok
		ok

		return 0

#===============================#
#  RECURSIVE REGEX MAKER CLASS  #
#===============================#

class stzNestedRegexMaker from stzRecursiveRegexMaker

# Describes a pattern as named levels nested inside one another, each with its own piece of pattern and quantifier.
#
# A level has a name, a pattern text, a parent, children and a quantifier. AddLevel adds a top
# level, AddChildLevel adds one inside an existing level, and AddQuantifier gives a level its repeat
# suffix. The tree can be read back with LevelNames, LevelParent, LevelChildren and Info. With named
# recursion on, which is the state at birth, each level becomes a named capture group.
# Pattern joins the top levels into one regular expression, each level nesting its children inside
# its own group, and SubPattern does the same for one level. stzNestedRegexMaker is another name for
# this class.
#
#   receiver   o1 = new stzRecursiveRegexMaker()
#   example    o1.AddLevel("open", "\(")
#              o1.AddChildLevel("open", "inner", "[^()]*")
#              o1.AddLevel("close", "\)")
#              ? @@( o1.LevelNames() )
#              #--> [ "open", "inner", "close" ]
#              ? @@( o1.LevelChildren("open") )
#              #--> [ "inner" ]
#              ? o1.LevelParent("inner")
#              #--> open
#              ? o1.Pattern()
#              #--> (?P<open>\((?P<inner>[^()]*))\)
#              o1.AddQuantifier("inner", "+")
#              ? o1.Info()[2][:quantifier]
#              #--> +
#   see        stzRegexMaker, stzRegex, stzNestedRegexMaker
class stzRecursiveRegexMaker from stzObject

	@aLevels = []
	@bNamedRecursion = 1
	# Builds an empty maker of levelled patterns, with named recursion switched on.
	#
	#   returns    nothing; the object is built
	#   note       named recursion is on at birth and off after Reset
	#   see        AddLevel, Reset
	#@ aka  @aParentStack / @nParentIndex lived here to track parents during a declarative setup that was replaced: nothing ever pushed to the stack, so the index it derived was always 0, and nothing read it either. AddChildLevel() finds a parent BY NAME (pvtFindLevelByName).
	def init()
		This.EnableNamedRecursion()

	# Adds a top level, a named piece of pattern with no parent, after the levels already added.
	#
	#   cName        the level's name
	#   _cPattern_   the pattern text of the level
	#   returns      nothing
	#   warning      a name that already exists is added again; the name is matched with case, and
	#                the first one is found by the other calls
	#   see          AddChildLevel, AddQuantifier, LevelNames
	def AddLevel(cName, _cPattern_)
		@aLevels + [
			:name    = cName,
			:pattern = _cPattern_,
			:parent  = "",
			:children = [],
			:quant   = ""
		]


	# Adds a level inside an existing level, which becomes its parent.
	#
	#   cParentName   the name of an existing level
	#   cChildName    the name of the new level
	#   _cPattern_    the pattern text of the new level
	#   returns       nothing
	#   warning       an unknown parent raises Parent level 'name' not found!
	#   see           AddLevel, LevelChildren, LevelParent
	def AddChildLevel(cParentName, cChildName, _cPattern_)
		_nParent_ = pvtFindLevelByName(cParentName)
		
		if _nParent_ = 0
			StzRaise("Parent level '" + cParentName + "' not found!")
		ok

		AddLevel(cChildName, _cPattern_)
		
		_nChild_ = len(@aLevels)
		@aLevels[_nChild_][:parent] = _nParent_
		@aLevels[_nParent_][:children] + _nChild_

	# Sets the repeat suffix of a level, such as + or *, replacing the one it had.
	#
	#   cLevelName   the name of an existing level
	#   cQuant       the suffix text, such as + or {2,3}
	#   returns      nothing
	#   warning      an unknown level raises Level 'name' not found!
	#   see          AddLevel, Info
	def AddQuantifier(cLevelName, cQuant)
		_nLevel_ = pvtFindLevelByName(cLevelName)
		
		if _nLevel_ = 0
			StzRaise("Level '" + cLevelName + "' not found!")
		ok

		@aLevels[_nLevel_][:quant] = cQuant

	# Makes each level a named capture group when the pattern is built.
	#
	#   returns    nothing
	#   see        DisableNamedRecursion, Pattern
	def EnableNamedRecursion()
		@bNamedRecursion = 1
		
	# Stops wrapping each level in a named capture group when the pattern is built.
	#
	#   returns    nothing
	#   see        EnableNamedRecursion, Pattern
	def DisableNamedRecursion()
		@bNamedRecursion = 0

	# Returns the regular expression joined from the top levels, each with its children nested inside it.
	#
	#   returns    a text; empty when no level was added
	#   note       with named recursion on, which is the state at birth, each level becomes a named
	#              group (?P<name>pattern) holding its own pattern followed by its children, then its
	#              quantifier; a child is written inside the group of its parent, not after it; a
	#              level named close is the exception and is written as its bare pattern, with no
	#              group, no children and no quantifier; a pattern text can refer to a group with
	#              (?P>name), which is how a recursive pattern is made
	#   warning    levels added with the same name are all written, and the other calls find the first
	#   see        SubPattern, LevelNames, AddChildLevel
	def Pattern()
		if len(@aLevels) = 0
			return ""
		ok

		_cPattern_ = ""
		
		# Process all root levels (those without parents)

		_nLevelsLen_2 = len(@aLevels)
		for i = 1 to _nLevelsLen_2
			if @aLevels[i][:parent] = ""
				_cPattern_ += pvtBuildPattern(i)
			ok
		next

		return _cPattern_

	# Returns the regular expression of one level, with its children nested inside it; empty for an unknown level.
	#
	#   cLevelName   the name of a level, matched with case
	#   returns      a text
	#   note         it is the part of the Pattern text that the level writes, so a child level gives
	#                its own group and a level named close gives its bare pattern
	#   see          Pattern, LevelChildren
	def SubPattern(cLevelName)
		_nLevel_ = pvtFindLevelByName(cLevelName)
		
		if _nLevel_ = 0
			return ""
		ok

		return pvtBuildPattern(_nLevel_)

	# Returns the names of all the levels, in the order they were added.
	#
	#   returns    a list of text
	#   see        NumberOfLevels, HasLevel
	def LevelNames()
		_aResult_ = []
		_nLevels2Len_ = len(@aLevels)
		for _iLoopLevels2_ = 1 to _nLevels2Len_
			_level_ = @aLevels[_iLoopLevels2_]
			_aResult_ + _level_[:name]
		next
		return _aResult_

	# Returns how many levels were added.
	#
	#   returns    a number
	#   see        LevelNames
	def NumberOfLevels()
		return len(@aLevels)

	# TRUE if a level of that name exists.
	#
	#   cName      the level's name, matched with case
	#   returns    1 or 0
	#   see        LevelNames
	def HasLevel(cName)
		return pvtFindLevelByName(cName) > 0

	# Returns the name of the level a level sits inside; an empty text for a top level or an unknown level.
	#
	#   cName      the level's name
	#   returns    a text
	#   see        LevelChildren, AddChildLevel
	def LevelParent(cName)
		_nLevel_ = pvtFindLevelByName(cName)
		if _nLevel_ = 0
			return ""
		ok
		_nParent_ = @aLevels[_nLevel_][:parent]
		if _nParent_ = ""
			return ""
		ok
		return @aLevels[_nParent_][:name]

	# Returns the names of the levels added inside a level, in order; an empty list for an unknown or childless level.
	#
	#   cName      the level's name
	#   returns    a list of text
	#   see        LevelParent, AddChildLevel
	def LevelChildren(cName)

		_nLevel_ = pvtFindLevelByName(cName)

		if _nLevel_ = 0
			return []
		ok

		_aResult_ = []

		_aLevelsnLevelchildren1_ = @aLevels[_nLevel_][:children]
		_nLevelsnLevelchildren1Len_ = len(_aLevelsnLevelchildren1_)
		for _iLoopLevelsnLevelchildren1_ = 1 to _nLevelsnLevelchildren1Len_
			_nChild_ = _aLevelsnLevelchildren1_[_iLoopLevelsnLevelchildren1_]
			_aResult_ + @aLevels[_nChild_][:name]
		next

		return _aResult_

	# Returns one hashlist per level, with its name, pattern, parent, children and quantifier.
	#
	#   returns    a list of hashlists; the parent and the children are positions in the list, and
	#              the parent is an empty text for a top level
	#   note       the keys are lower case when listed
	#   see        LevelNames, AddQuantifier
	def Info()

		_aResult_ = []

		_nLevels1Len_ = len(@aLevels)
		for _iLoopLevels1_ = 1 to _nLevels1Len_
			_level_ = @aLevels[_iLoopLevels1_]
			_aInfo_ = [
				:name = _level_[:name],
				:pattern = _level_[:pattern],
				:parent = _level_[:parent],
				:children = _level_[:children],
				:quantifier = _level_[:quant]
			]

			_aResult_ + _aInfo_
		next

		return _aResult_

	# Removes every level and switches named recursion off.
	#
	#   returns    nothing
	#   note       after Reset the levels are no longer wrapped in named groups until
	#              EnableNamedRecursion is called
	#   see        init, AddLevel
	def Reset()
		@aLevels = []
		@bNamedRecursion = 0

	private

	# Returns the position of the first level with that name, or 0 when there is none.
	#
	#   cName      the level's name, matched with case
	#   returns    a number
	#   note       private
	#   see        HasLevel, AddChildLevel
	def pvtFindLevelByName(cName)

		_nLevelsLen_ = len(@aLevels)
		for i = 1 to _nLevelsLen_
			if @aLevels[i][:name] = cName
				return i
			ok
		next

		return 0

	# Returns the pattern of the level at a position, with its children nested inside it and its quantifier after it.
	#
	#   _nLevel_   the position of the level
	#   returns    a text; empty for a position out of range
	#   warning    private: calling it from outside raises R26
	#   see        Pattern, SubPattern
	def pvtBuildPattern(_nLevel_)

		if _nLevel_ < 1 or _nLevel_ > len(@aLevels)
			return ""
		ok

		_level_ = @aLevels[_nLevel_]
		_cPattern_ = _level_[:pattern]

		# Process children first to properly nest them

		_cChildrenPattern_ = ""

		_aLevelchildren1_ = _level_[:children]
		_nLevelchildren1Len_ = len(_aLevelchildren1_)
		for _iLoopLevelchildren1_ = 1 to _nLevelchildren1Len_
			_nChild_ = _aLevelchildren1_[_iLoopLevelchildren1_]
			_cChildPattern_ = pvtBuildPattern(_nChild_)
			_cChildrenPattern_ += _cChildPattern_
		next

		# Add children pattern to current level's pattern

		if _cChildrenPattern_ != ""
			_cPattern_ += _cChildrenPattern_
		ok

		# Add quantifier if present

		if _level_[:quant] != ""

			if @bNamedRecursion

				# For named recursion, wrap pattern + children in capture group before quantifier
				_cPattern_ = "(?P<" + _level_[:name] + ">" + _cPattern_ + ")" + _level_[:quant]
			else

				_cPattern_ += _level_[:quant]
			ok

		else
			if @bNamedRecursion

				# Wrap in capture group without quantifier
				_cPattern_ = "(?P<" + _level_[:name] + ">" + _cPattern_ + ")"
			ok
		ok

		# Special handling for close pattern

		if StzLower(_level_[:name]) = "close"
			return _level_[:pattern]
		ok

		return _cPattern_

#=================================#
#  CONDITIONAL REGEX MAKER CLASS  #
#=================================#

# Builds an if-then-else regular expression, a conditional pattern, from a condition, a then part and an optional else part.
#
# The condition is one of the If calls (IfMatch, IfNotMatch, IfStartsWith, IfEndsWith, IfContains,
# IfPrecededBy, IfFollowedBy); the last one called wins. ThenMatch and ElseMatch give the two
# branches, and Pattern joins them as (?(?=condition)then|else). The pattern stays empty until a
# condition is set. IfStartsWith, IfEndsWith and IfContains take literal text and escape it; the
# other calls take a pattern. IfCaptured does not build a conditional today, and the pair forms of
# IfCaptured and IfPrecededBy raise an error.
#
#   receiver   o1 = new stzConditionalRegexMaker
#   example    o1.IfMatch("\d").ThenMatch("\d+").ElseMatch("[a-z]+")
#              ? o1.Pattern()
#              #--> (?(?=\d)\d+|[a-z]+)
#              o2 = new stzRegex(o1.Pattern())
#              o2.MatchFirst("abc 123")
#              ? @@( o2.Matches() )
#              #--> [ "abc", "123" ]
#              o1.Reset()
#              ? o1.IfStartsWith("+").ThenMatch("\d+").Pattern()
#              #--> (?(?=^\+)\d+)
#   see        stzRegexMaker, stzRegex, stzRegexLookaroundMaker
class stzConditionalRegexMaker from stzObject

	@cCondition = ""    # Stores the if condition
	@cThenPart = ""     # Stores the then pattern
	@cElsePart = ""     # Stores the else pattern (optional)
	
	# Builds a conditional pattern maker with no condition, no then part and no else part.
	#
	#   returns    nothing; the object is built
	#   see        Reset, Pattern
	def init()
		Reset()

	# Empties the condition, the then part and the else part.
	#
	#   returns    nothing
	#   note       unlike the look-around maker's Reset, it does not return the maker
	#   see        init, Pattern
	def Reset()
		@cCondition = ""
		@cThenPart = ""
		@cElsePart = ""

	  #------------------#
	 #     IF PART      #
	#------------------#

	# Sets the condition to a look-ahead: the then part applies when pcPattern matches at the current position.
	#
	#   pcPattern   the pattern the text must match at this point, such as \d
	#   returns     the maker itself, so calls chain
	#   note        a second If call replaces the condition
	#   warning     a value that is not a text raises Incorrect param type! pcPattern must be a
	#               string
	#   see         IfNotMatch, ThenMatch, ElseMatch, Pattern
	def IfMatch(pcPattern)
		if isList(pcPattern) and len(pcPattern) = 2 and isString(pcPattern[1]) and pcPattern[1] = "pattern"
			pcPattern = pcPattern[2]
		ok

		if NOT isString(pcPattern)
			StzRaise("Incorrect param type! pcPattern must be a string.")
		ok

		@cCondition = "(?(?=" + pcPattern + ")"
		return This

	# Sets the condition to a negative look-ahead: the then part applies when pcPattern does not match at the current position.
	#
	#   pcPattern   the pattern the text must not match at this point
	#   returns     the maker itself, so calls chain
	#   note        a second If call replaces the condition
	#   warning     a value that is not a text raises Incorrect param type! pcPattern must be a
	#               string
	#   see         IfMatch, ThenMatch, ElseMatch
	def IfNotMatch(pcPattern)
		if isList(pcPattern) and len(pcPattern) = 2 and isString(pcPattern[1]) and pcPattern[1] = "pattern"
			pcPattern = pcPattern[2]
		ok

		if NOT isString(pcPattern)
			StzRaise("Incorrect param type! pcPattern must be a string.")
		ok

		@cCondition = "(?(?!" + pcPattern + ")"
		return This

	# Sets a condition on a capture group, but builds the text (?1 or (?<name> instead of a conditional, so the pattern is not a conditional.
	#
	#   pcGroupName   the group's number or name, as text
	#   returns       the maker itself, so calls chain
	#   note          b) for the group 1, where a conditional is written (?(1)a
	#   warning       with ThenMatch and ElseMatch it gave (?1a
	#   see           IfMatch, ThenMatch, Pattern
	def IfCaptured(pcGroupName)
		if isList(pcGroupName) and len(pcGroupName) = 2 and isString(pcGroupName[1]) and pcGroupName[1] = "group"
			_cGroupName_ = pGroupName[2]
		ok

		if NOT isString(pcGroupName)
			StzRaise("Incorrect param type! pcGroupName must be a string.")
		ok

		@cCondition = "(?" + pcGroupName
		return This

	  #------------------#
	 #    THEN PART     #
	#------------------#

	# Sets the pattern that applies when the condition holds.
	#
	#   pcPattern   the pattern for the then part
	#   returns     the maker itself, so calls chain
	#   note        without an If call, Pattern stays empty
	#   warning     a value that is not a text raises Incorrect param type! pcPattern must be a
	#               string
	#   see         IfMatch, ElseMatch, Pattern
	def ThenMatch(pcPattern)
		if isList(pcPattern) and len(pcPattern) = 2 and isString(pcPattern[1]) and pcPattern[1] = "pattern"
			pcPattern = pcPattern[2]
		ok

		if NOT isString(pcPattern)
			StzRaise("Incorrect param type! pcPattern must be a string.")
		ok

		@cThenPart = pcPattern
		return This

	  #------------------#
	 #    ELSE PART     #
	#------------------#

	# Sets the pattern that applies when the condition does not hold.
	#
	#   pcPattern   the pattern for the else part
	#   returns     the maker itself, so calls chain
	#   warning     a value that is not a text raises Incorrect param type! pcPattern must be a
	#               string
	#   see         IfMatch, ThenMatch, Pattern
	def ElseMatch(pcPattern)
		if isList(pcPattern) and len(pcPattern) = 2 and isString(pcPattern[1]) and pcPattern[1] = "pattern"
			pcPattern = pcPattern[2]
		ok

		if NOT isString(pcPattern)
			StzRaise("Incorrect param type! pcPattern must be a string.")
		ok

		@cElsePart = pcPattern
		return This

	  #------------------#
	 #  COMMON HELPERS  #
	#------------------#

	# Sets the condition to the text starting here, taking pcText as literal text whose special characters are escaped.
	#
	#   pcText     the literal text the subject must start with
	#   returns    the maker itself, so calls chain
	#   note       IfStartsWith("+") builds the condition (?=^\+)
	#   warning    a value that is not a text raises Incorrect param type! pcText must be a string
	#   see        IfEndsWith, IfContains, IfMatch
	#@ aka  Takes LITERAL TEXT, not a pattern. IfStartsWith("+") means a plus sign, and it used to build (?=^+) -- a quantifier applied to ^, which does not even compile. The argument is escaped, so metacharacters mean themselves.
	def IfStartsWith(pcText)
		if isList(pcText) and IsPatternNamedParamList(pcText)
			pcText = pcText[2]
		ok

		if NOT isString(pcText)
			StzRaise("Incorrect param type! pcText must be a string.")
		ok

		return This.IfMatch("^" + StzRegexEscape(pcText))

	# Sets the condition to the text ending here, taking pcText as literal text whose special characters are escaped.
	#
	#   pcText     the literal text the subject must end with
	#   returns    the maker itself, so calls chain
	#   note       IfEndsWith(".edu") builds the condition (?=\.edu$)
	#   warning    a value that is not a text raises Incorrect param type! pcText must be a string
	#   see        IfStartsWith, IfContains, IfMatch
	#@ aka  Literal text -- IfEndsWith(".edu") means the four characters ".edu", not "any character followed by edu", which is what it built before.
	def IfEndsWith(pcText)
		if isList(pcText) and IsPatternNamedParamList(pcText)
			pcText = pcText[2]
		ok

		if NOT isString(pcText)
			StzRaise("Incorrect param type! pcText must be a string.")
		ok

		return This.IfMatch(StzRegexEscape(pcText) + "$")

	# Sets the condition to the text appearing somewhere ahead, taking pcText as literal text whose special characters are escaped.
	#
	#   pcText     the literal text the subject must contain
	#   returns    the maker itself, so calls chain
	#   note       IfContains("a.b") builds the condition (?=.*a\.b.*)
	#   warning    a value that is not a text raises Incorrect param type! pcText must be a string
	#   see        IfStartsWith, IfEndsWith, IfMatch
	#@ aka  Literal text.
	def IfContains(pcText)
		if isList(pcText) and IsPatternNamedParamList(pcText)
			pcText = pcText[2]
		ok

		if NOT isString(pcText)
			StzRaise("Incorrect param type! pcText must be a string.")
		ok

		return This.IfMatch(".*" + StzRegexEscape(pcText) + ".*")

	# Sets the condition to a look-behind: the then part applies when pcPattern ends just before the current position.
	#
	#   pcPattern   the pattern that must come before this point
	#   returns     the maker itself, so calls chain
	#   note        the condition built is a look-ahead around a look-behind
	#   warning     the pair form [ :pattern, "x" ] raises error R24 Using uninitialized variable,
	#               because the code reads a name that is not the parameter; a value that is not a
	#               text raises Incorrect param type!
	#   see         IfFollowedBy, IfMatch
	def IfPrecededBy(pcPattern)
		if isList(pcPattern) and IsPatternNamedParamList(pcPattern)
			pPattern = pPattern[2]
		ok

		if NOT isString(pcPattern)
			StzRaise("Incorrect param type! pcPattern must be a string.")
		ok

		return This.IfMatch("(?<=" + pcPattern + ")")

	# Sets the condition to a look-ahead built from pcPattern, which is the same condition IfMatch builds with a nested look-ahead.
	#
	#   pcPattern   the pattern that must come after this point
	#   returns     the maker itself, so calls chain
	#   note        IfFollowedBy("x") builds (?(?=(?=x))
	#   warning     a value that is not a text raises Incorrect param type! pcPattern must be a
	#               string
	#   see         IfPrecededBy, IfMatch
	def IfFollowedBy(pcPattern)
		if isList(pcPattern) and IsPatternNamedParamList(pcPattern)
			pcPattern = pcPattern[2]
		ok

		if NOT isString(pcPattern)
			StzRaise("Incorrect param type! pcPattern must be a string.")
		ok

		return This.IfMatch("(?=" + pcPattern + ")")

	  #------------------#
	 #  PATTERN OUTPUT  #
	#------------------#

	# Returns the conditional pattern as one text: the condition, the then part, and the else part after a bar when there is one.
	#
	#   returns    a text such as (?(?=\d)\d+
	#   warning    Info, IfMatch, ThenMatch, ElseMatch
	def Pattern()
		if @cCondition = ""
			return ""
		ok

		_cResult_ = @cCondition + @cThenPart

		if @cElsePart != ""
			_cResult_ += "|" + @cElsePart
		ok

		return _cResult_ + ")"

	# Returns the condition, the then part, the else part and the finished pattern, as a hashlist.
	#
	#   returns    a hashlist with the keys condition, then, else and pattern
	#   note       the keys are lower case when listed
	#   see        Pattern
	def Info()
		_aResult_ = [
			:condition = @cCondition,
			:then = @cThenPart,
			:else = @cElsePart,
			:pattern = This.Pattern()
		]

		return _aResult_

#==================================#
#  STZ REGEX LOOKING AROUND CLASS  #
#==================================#

# Builds a look-around regular expression: a main pattern that must, or must not, come before or after another pattern.
#
# One look-around is held at a time: MustBeFollowedBy and CantBeFollowedBy build a look-ahead,
# MustBePrecededBy and CantBePrecededBy a look-behind, and the Word, Number and Space forms fill in
# the common patterns. A second call replaces the first. ThenMatch sets the main pattern, which
# Pattern writes after the look-around, so a look-behind reads correctly: (?<=\$)\d+ finds the
# digits that follow a dollar sign. A look-ahead followed by a main pattern does not read as the
# name says: (?=ing)[a-z]+ tests what the main pattern starts on, so it finds ing in walking and not
# walk. A look-behind of variable length, such as the Number and Space forms, finds nothing in the
# engine.
#
#   receiver   o1 = new stzRegexLookaroundMaker
#   example    o1.MustBePrecededBy("\$").ThenMatch("\d+")
#              ? o1.Pattern()
#              #--> (?<=\$)\d+
#              o2 = new stzRegex(o1.Pattern())
#              o2.MatchFirst("cost $42 now")
#              ? @@( o2.Matches() )
#              #--> [ "42" ]
#   see        stzRegexMaker, stzRegex, stzConditionalRegexMaker
class stzRegexLookaroundMaker from stzObject
	@cDirection = ""	# 'ahead' or 'behind'
	@cType = ""    		# 'positive' or 'negative' 
	@cPattern = ""		# The actual pattern to look for
	@cMainPattern = ""	# The main pattern to match (optional)

	# Builds a look-around maker with no pattern, no direction and no main pattern.
	#
	#   returns    nothing; the object is built
	#   see        Reset, Pattern
	def init()
	# Forgets the look-around and the main pattern, and returns the maker.
	#
	#   returns    the maker itself, so calls chain
	#   see        init, Pattern
	#@ aka  Do nothing
	def Reset()
		@cDirection = ""
		@cType = ""
		@cPattern = ""
		@cMainPattern = ""
		return This

	  #--------------------------#
	 #    POSITIVE PATTERNS     #
	#--------------------------#

	# Sets a positive look-ahead: the match must be followed by pcPattern, which is not part of it.
	#
	#   pcPattern   the pattern that must come next
	#   returns     the maker itself, so calls chain
	#   note        a second look-around call replaces the first; LookingAhead is the same call
	#   warning     a value that is not a text raises Incorrect param type! pcPattern must be a
	#               string; with a main pattern the look-ahead is written BEFORE it, so it tests
	#               what the main pattern starts on, not what follows it:
	#               MustBeFollowedBy("ing").ThenMatch("[a-z]+") finds ing in walking, where
	#               [a-z]+(?=ing) finds walk
	#   see         MustBePrecededBy, CantBeFollowedBy, ThenMatch, Pattern
	def MustBeFollowedBy(pcPattern)
		if isList(pcPattern) and len(pcPattern) = 2 and isString(pcPattern[1]) and pcPattern[1] = "pattern"
			pcPattern = pcPattern[2]
		ok

		if NOT isString(pcPattern)
			StzRaise("Incorrect param type! pcPattern must be a string.")
		ok

		@cDirection = "ahead"
		@cType = "positive"
		@cPattern = pcPattern
		return This

		#< @FunctionAlternativeForms

		def LookingAhead(pcPattern)
			return This.MustBeFollowedBy(pcPattern)

	# Sets a positive look-behind: the match must be preceded by pcPattern, which is not part of it.
	#
	#   pcPattern   the pattern that must come before
	#   returns     the maker itself, so calls chain
	#   note        a second look-around call replaces the first; LookingBehind is the same call
	#   warning     a value that is not a text raises Incorrect param type! pcPattern must be a
	#               string
	#   see         MustBeFollowedBy, CantBePrecededBy, ThenMatch, Pattern
		#>
	def MustBePrecededBy(pcPattern)
		if isList(pcPattern) and len(pcPattern) = 2 and isString(pcPattern[1]) and pcPattern[1] = "pattern"
			pcPattern = pcPattern[2]
		ok

		if NOT isString(pcPattern)
			StzRaise("Incorrect param type! pcPattern must be a string.")
		ok

		@cDirection = "behind"
		@cType = "positive"
		@cPattern = pcPattern
		return This

		#< @FunctionAlternativeForms

		def LookingBehind(pcPattern)
			return This.MustBePrecededBy(pcPattern)

		#>

	  #--------------------------#
	 #    NEGATIVE PATTERNS     #
	#--------------------------#

	# Sets a negative look-ahead: the match must not be followed by pcPattern.
	#
	#   pcPattern   the pattern that must not come next
	#   returns     the maker itself, so calls chain
	#   note        NotLookingAhead is the same call
	#   warning     a value that is not a text raises Incorrect param type! pcPattern must be a
	#               string; with a main pattern the look-ahead is written BEFORE it, so it tests
	#               what the main pattern starts on, not what follows it:
	#               MustBeFollowedBy("ing").ThenMatch("[a-z]+") finds ing in walking, where
	#               [a-z]+(?=ing) finds walk
	#   see         MustBeFollowedBy, CantBePrecededBy, ThenMatch, Pattern
	def CantBeFollowedBy(pcPattern)
		if isList(pcPattern) and len(pcPattern) = 2 and isString(pcPattern[1]) and pcPattern[1] = "pattern"
			pcPattern = pcPattern[2]
		ok

		if NOT isString(pcPattern)
			StzRaise("Incorrect param type! pcPattern must be a string.")
		ok

		@cDirection = "ahead"
		@cType = "negative"
		@cPattern = pcPattern
		return This

		#< @FunctionAlternativeForms

		def NotLookingAhead(pcPattern)
			return This.CantBeFollowedBy(pcPattern)

	# Sets a negative look-behind: the match must not be preceded by pcPattern.
	#
	#   pcPattern   the pattern that must not come before
	#   returns     the maker itself, so calls chain
	#   note        NotLookingBehind is the same call
	#   warning     a value that is not a text raises Incorrect param type! pcPattern must be a
	#               string
	#   see         MustBePrecededBy, CantBeFollowedBy, ThenMatch, Pattern
		#>
	def CantBePrecededBy(pcPattern)
		if isList(pcPattern) and len(pcPattern) = 2 and isString(pcPattern[1]) and pcPattern[1] = "pattern"
			pcPattern = pcPattern[2]
		ok

		if NOT isString(pcPattern)
			StzRaise("Incorrect param type! pcPattern must be a string.")
		ok

		@cDirection = "behind"
		@cType = "negative"
		@cPattern = pcPattern
		return This

		#< @FunctionAlternativeForms

		def NotLookingBehind(pcPattern)
			return This.CantBePrecededBy(pcPattern)

		#>

	  #------------------#
	 #   MAIN PATTERN   #
	#------------------#

	# Sets the main pattern that the look-around is attached to.
	#
	#   pcPattern   the pattern to match
	#   returns     the maker itself, so calls chain
	#   note        the main pattern is written after the look-around, so a look-behind belongs
	#               before it
	#   warning     a value that is not a text raises Incorrect param type! pcPattern must be a
	#               string; without a look-around call the pattern stays empty
	#   see         MustBeFollowedBy, MustBePrecededBy, Pattern
	def ThenMatch(pcPattern)
		if isList(pcPattern) and len(pcPattern) = 2 and isString(pcPattern[1]) and pcPattern[1] = "pattern"
			pcPattern = pcPattern[2]
		ok

		if NOT isString(pcPattern)
			StzRaise("Incorrect param type! pcPattern must be a string.")
		ok

		@cMainPattern = pcPattern
		return This

	  #------------------#
	 #  COMMON HELPERS  #
	#------------------#

	# Sets a positive look-ahead on a whole word, written with word boundaries.
	#
	#   pcWord     the word that must come next
	#   returns    the maker itself, so calls chain
	#   note       the look-ahead is (?=\bword\b); LookingForWord is the same call
	#   warning    a value that is not a text raises Incorrect param type! pcWord must be a string;
	#              with a main pattern the look-ahead is written BEFORE it, so it tests what the
	#              main pattern starts on, not what follows it:
	#              MustBeFollowedBy("ing").ThenMatch("[a-z]+") finds ing in walking, where
	#              [a-z]+(?=ing) finds walk
	#   see        MustBeFollowedBy, CantBeFollowedByWord
	def MustBeFollowedByWord(pcWord)
		if isList(pcWord) and len(pcWord) = 2 and isString(pcWord[1]) and pcWord[1] = "pattern"
			pcWord = pcWord[2]
		ok

		if NOT isString(pcWord)
			StzRaise("Incorrect param type! pcWord must be a string.")
		ok

		return This.MustBeFollowedBy("\b" + pcWord + "\b")

		#< @FunctionAlternativeForms

		def LookingForWord(pcWord)
			return This.MustBeFollowedByWord(pcWord)

	# Sets a positive look-behind on a whole word, written with word boundaries.
	#
	#   pcWord     the word that must come before
	#   returns    the maker itself, so calls chain
	#   note       the look-behind is (?<=\bword\b); LookingBehindWord is the same call
	#   warning    a value that is not a text raises Incorrect param type! pcWord must be a string
	#   see        MustBePrecededBy, CantBePrecededByWord
		#>
	def MustBePrecededByWord(pcWord)
		if isList(pcWord) and len(pcWord) = 2 and isString(pcWord[1]) and pcWord[1] = "pattern"
			pcWord = pcWord[2]
		ok

		if NOT isString(pcWord)
			StzRaise("Incorrect param type! pcWord must be a string.")
		ok

		return This.MustBePrecededBy("\b" + pcWord + "\b")

		#< @FunctionAlternativeForms

		def LookingBehindWord(pcWord)
			return This.MustBePrecededByWord(pcWord)

	# Sets a negative look-ahead on a whole word, written with word boundaries.
	#
	#   pcWord     the word that must not come next
	#   returns    the maker itself, so calls chain
	#   note       the look-ahead is (?!\bword\b); NotFollowedByWord is the same call
	#   warning    a value that is not a text raises Incorrect param type! pcWord must be a string;
	#              with a main pattern the look-ahead is written BEFORE it, so it tests what the
	#              main pattern starts on, not what follows it:
	#              MustBeFollowedBy("ing").ThenMatch("[a-z]+") finds ing in walking, where
	#              [a-z]+(?=ing) finds walk
	#   see        CantBeFollowedBy, MustBeFollowedByWord
		#>
	def CantBeFollowedByWord(pcWord)
		if isList(pcWord) and len(pcWord) = 2 and isString(pcWord[1]) and pcWord[1] = "pattern"
			pcWord = pcWord[2]
		ok

		if NOT isString(pcWord)
			StzRaise("Incorrect param type! pcWord must be a string.")
		ok

		return This.CantBeFollowedBy("\b" + pcWord + "\b")

		#< @FunctionAlternativeForms

		def NotFollowedByWord(pcWord)
			return This.CantBeFollowedByWord(pcWord)

	# Sets a negative look-behind on a whole word, written with word boundaries.
	#
	#   pcWord     the word that must not come before
	#   returns    the maker itself, so calls chain
	#   note       the look-behind is (?<!\bword\b); NotPrecededByWord is the same call
	#   warning    a value that is not a text raises Incorrect param type! pcWord must be a string
	#   see        CantBePrecededBy, MustBePrecededByWord
		#>
	def CantBePrecededByWord(pcWord)
		if isList(pcWord) and len(pcWord) = 2 and isString(pcWord[1]) and pcWord[1] = "pattern"
			pcWord = pcWord[2]
		ok

		if NOT isString(pcWord)
			StzRaise("Incorrect param type! pcWord must be a string.")
		ok

		return This.CantBePrecededBy("\b" + pcWord + "\b")

		#< @FunctionAlternativeForms

		def NotPrecededByWord(pcWord)
			return This.CantBePrecededByWord(pcWord)

	# Sets a positive look-ahead on one or more digits.
	#
	#   returns    the maker itself, so calls chain
	#   note       the look-ahead is (?=\d+); LookingForNumber is the same call
	#   warning    with a main pattern the look-ahead is written BEFORE it, so it tests what the
	#              main pattern starts on, not what follows it:
	#              MustBeFollowedBy("ing").ThenMatch("[a-z]+") finds ing in walking, where
	#              [a-z]+(?=ing) finds walk
	#   see        MustBePrecededByNumber, MustBeFollowedBy
		#>
	def MustBeFollowedByNumber()
		return This.MustBeFollowedBy("\d+")

		#< @FunctionAlternativeForms

		def LookingForNumber()
			return This.MustBeFollowedByNumber()

	# Sets a positive look-behind on one or more digits.
	#
	#   returns    the maker itself, so calls chain
	#   note       the look-behind is (?<=\d+); LookingBehindNumber is the same call
	#   warning    tested with a main pattern on a text with digits or spaces before it, and the
	#              engine found nothing, because it does not take a look-behind of variable length
	#              such as \d+ or \s+: (?<=\d+)a on 12a gives no match
	#   see        MustBeFollowedByNumber, MustBePrecededBy
		#>
	def MustBePrecededByNumber()
		return This.MustBePrecededBy("\d+")

		#< @FunctionAlternativeForms

		def LookingBehindNumber()
			return This.MustBePrecededByNumber()

	# Sets a positive look-ahead on one or more white-space characters.
	#
	#   returns    the maker itself, so calls chain
	#   note       the look-ahead is (?=\s+); LookingForSpace is the same call
	#   warning    with a main pattern the look-ahead is written BEFORE it, so it tests what the
	#              main pattern starts on, not what follows it:
	#              MustBeFollowedBy("ing").ThenMatch("[a-z]+") finds ing in walking, where
	#              [a-z]+(?=ing) finds walk
	#   see        MustBePrecededBySpace, MustBeFollowedBy
		#>
	def MustBeFollowedBySpace()
		return This.MustBeFollowedBy("\s+")

		#< @FunctionAlternativeForms

		def LookingForSpace()
			return This.MustBeFollowedBySpace()

	# Sets a positive look-behind on one or more white-space characters.
	#
	#   returns    the maker itself, so calls chain
	#   note       the look-behind is (?<=\s+); LookingBehindSpace is the same call
	#   warning    tested with a main pattern on a text with digits or spaces before it, and the
	#              engine found nothing, because it does not take a look-behind of variable length
	#              such as \d+ or \s+: (?<=\d+)a on 12a gives no match
	#   see        MustBeFollowedBySpace, MustBePrecededBy
		#>
	def MustBePrecededBySpace()
		return This.MustBePrecededBy("\s+")

		#< @FunctionAlternativeForms

		def LookingBehindSpace()
			return This.MustBePrecededBySpace()

		#>

	  #------------------#
	 #  PATTERN OUTPUT  #
	#------------------#

	# Returns the look-around group followed by the main pattern as one text; empty when no look-around was set.
	#
	#   returns    a text such as (?<=\$)\d+
	#   note       a main pattern set without a look-around gives an empty text
	#   warning    with a main pattern the look-ahead is written BEFORE it, so it tests what the
	#              main pattern starts on, not what follows it:
	#              MustBeFollowedBy("ing").ThenMatch("[a-z]+") finds ing in walking, where
	#              [a-z]+(?=ing) finds walk
	#   see        Info, ThenMatch
	def Pattern()
		if @cPattern = "" 
			return ""
		ok

		_cResult_ = ""

		switch @cDirection
		on "ahead"
			if @cType = "positive"
				_cResult_ = "(?=" + @cPattern + ")"
			else
				_cResult_ = "(?!" + @cPattern + ")"
			ok

		on "behind"
			if @cType = "positive"
				_cResult_ = "(?<=" + @cPattern + ")"
			else
				_cResult_ = "(?<!" + @cPattern + ")"
			ok
		off

		if @cMainPattern != ""
			_cResult_ += @cMainPattern
		ok

		return _cResult_

	# Returns the direction, the type, the look-around pattern, the main pattern and the finished pattern, as a hashlist.
	#
	#   returns    a hashlist with the keys direction, type, lookPattern, mainPattern and pattern
	#   note       the keys are lower case when listed
	#   see        Pattern
	def Info()
		_aResult_ = [
			:direction = @cDirection,
			:type = @cType,
			:lookPattern = @cPattern,
			:mainPattern = @cMainPattern,
			:pattern = This.Pattern()
		]

		return _aResult_
