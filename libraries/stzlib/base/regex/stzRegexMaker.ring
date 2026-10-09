
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
# literals and groups add a fragment and no sequence, so the two lists do not stay aligned. Groups
# made with DefineGroup are remembered and can be reused or referred back to. The text is not
# escaped or validated: a literal goes in as given. Several public names are broken today and raise
# errors: NumberOfSequences and its aliases, the CommandAndFragment family, ComposePatterns in the
# or and sequence modes, MatchSameContentAs, the named-parameter forms CanContainAChar and
# CanContainADigit, and the five names that forward to the misspelled NumberOfFragments; each is
# flagged in its own entry. For ready-made patterns by name use AddCommonPattern or StzRxp.
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
	#   cQuant      repeatedExactly for {n}, repeatedAtLeast for {n,}, repeatedAtMost for ?,
	#               repeatedBetween for {n,m}, repeatedSeveralTimes or repeatedSeveral for *
	#   nTimes1     the first count
	#   _nTimes2_   the second count for repeatedBetween, or a pair such as [ and, 5 ]
	#   returns     nothing; read the result with Pattern
	#   note        repeatedAtMost ignores the count and always writes ?, so 3 and 1 give the same
	#               pattern
	#   warning     a cQuant it does not know adds the class with no suffix and no complaint: :zzz
	#               gave [ab]
	#   see         AddAmongChars, AddCharsRange, Pattern
	def AddRange(cType, _cRange_, cQuant, nTimes1, _nTimes2_)

		# Checking params

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
			_cQuantifier_ = "?"

		but cQuant = :repeatedBetween
			_cQuantifier_ = "{" + nTimes1 + "," + _nTimes2_ + "}"

		but cQuant =  :repeatedSeveralTimes or cQuant = :repeatedSeveral
			_cQuantifier_ = "*"
		ok

		# Storing the complete pattern (main string + quantifier part)

        	@acFragments + (_cPattern_ + _cQuantifier_)

		# String the elements of the sequence applied

        	@aSequences + [ cType, _cRange_, cQuant, nTimes1, _nTimes2_ ]
        

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
	#   note       the name is misspelled (Fragements) and the five names that forward to the
	#              correctly spelled NumberOfFragments do not exist: HowManyFragments,
	#              CountFragments, NumberOfFrags, HowManyFrags and CountFrags raise R14
	#   see        Fragments, Fragment
	def NumberOfFragements()
		return len(@acFragments)

		#< @FunctionAlternativeForms

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

	def FragmentXT(n)
		return [ @acFragments[n], @aSequences[n] ]

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

	def FragmentsXT()
		_aResult_ = @Association([ This.Fragments(), This.Sequences() ])
		return _aResult_

		def FragsXT()
			return This.FragmentsXT()

	  #---------------------------#
	 #  GETTING THE QUANTIFIERS  #
	#---------------------------#

	# Returns an empty text today, because the method is an unwritten placeholder.
	#
	#   returns    an empty text
	#   warning    placeholder: the body is a TODO and nothing is computed
	#   see        QuantifiersCommands, Sequences
	def Quantifiers()
	# Returns an empty text today, because the method is an unwritten placeholder.
	#
	#   returns    an empty text
	#   note       QuantifiersXT is the same
	#   warning    placeholder: the body is a TODO and nothing is computed
	#   see        Quantifiers, Sequences
		#TODO
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

	# Raises error R24 today instead of returning how many sequences were recorded.
	#
	#   returns    a number, when it works
	#   note       the failure was seen with and without ranges added
	#   warning    Raises error R24 today: the body reads len(acSequences), a variable that is never
	#              set, where @aSequences is meant; HowManySequences, CountSequences, NumberOfSeqs,
	#              HowManySeqs, CountSeqs, NumberOfCommands, HowManyCommands and CountCommands
	#              forward to it and raise the same error
	#   see        Sequences, NumberOfFragements
	def NumberOfSequences()
		return len(acSequences)

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
	#   note       Seq and Command are the same call
	#   warning    raises an error for a position past the last sequence, which is also the case for
	#              position 1 when only literals were added
	#   see        Sequences, SequenceXT
		#>
	def Sequence(n)
		return @aSequences[n]

		def Seq(n)
			return This.Sequence(n)

		def Command(n)
			return This.Sequence(n)

	def SequenceXT(n)
		return [ @aSequences[n], @acFragments[n] ]

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

		def CommandXT()
			return This.SequenceXT(n)

		# Raises error R24 today instead of returning a sequence together with its fragment.
		#
		#   returns    a list of the sequence and the piece, when it works
		#   note       CommandXT, CommandAndFrag, CommandAndItsFragment and CommandAndItsFrag have
		#              the same defect
		#   warning    Raises error R24 today: the alias passes n to SequenceXT but declares no
		#              parameter, so n is an unset variable; SequenceXT(1) itself works and answers
		#              [ sequence, piece ]
		#   see        SequenceXT, Fragment
		def CommandAndFragment()
			return This.SequenceXT(n)

		# Raises error R24 today instead of returning a sequence together with its fragment.
		#
		#   returns    a list of the sequence and the piece, when it works
		#   note       same cause as CommandAndFragment
		#   warning    Raises error R24 today: the alias passes an unset n to SequenceXT
		#   see        CommandAndFragment, SequenceXT
		def CommandAndFrag()
			return This.SequenceXT(n)

		# Raises error R24 today instead of returning a sequence together with its fragment.
		#
		#   returns    a list of the sequence and the piece, when it works
		#   note       same cause as CommandAndFragment
		#   warning    Raises error R24 today: the alias passes an unset n to SequenceXT
		#   see        CommandAndFragment, SequenceXT
		def CommandAndItsFragment()
			return This.SequenceXT(n)

		# Raises error R24 today instead of returning a sequence together with its fragment.
		#
		#   returns    a list of the sequence and the piece, when it works
		#   note       same cause as CommandAndFragment
		#   warning    Raises error R24 today: the alias passes an unset n to SequenceXT
		#   see        CommandAndFragment, SequenceXT
		def CommandAndItsFrag()
			return This.SequenceXT(n)

		#>

	def SequencesXT()
		_aResult_ = @Association([ This.Sequences(), This.Fragments() ])
		return _aResult_

		def SeqsXT()
			return This.SequencesXT()

		def CommandsXT()
			return This.SequencesXT()

	# Appends a copy of the nth recorded sequence and of its piece to the end of the pattern.
	#
	#   n          the position of the sequence to repeat, from 1
	#   returns    nothing; read the result with Pattern
	#   note       the piece is taken at the same position n, which is the nth piece and not the
	#              piece of the nth sequence once literals are mixed in; after one [a-f]{2} it gives
	#              [a-f]{2}[a-f]{2}
	#   warning    raises an error when there is no sequence n, as when only literals were added
	#   see        RepeatCommand, Sequence
	def RepeatSequence(n)

		@aSequences + @aSequences[n]
		@acFragments + @acFragments[n]

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

	# Raises error R14 today instead of adding a character class given as a named parameter such as :Between = [ A, Z ].
	#
	#   p          the named pair: Between, Among or From with their characters
	#   pRepeat    the repeat pair such as [ RepeatedExactly, 2 ], or a number
	#   returns    nothing, when it works
	#   note       CanContainACharBetween and CanContainACharAmong, which it would call, work when
	#              called directly
	#   warning    Raises error R14 today: it calls IsBetweenOrFromNamedParam on a stzList, a method
	#              that does not exist; seen with the Between, Among and From forms, and a text
	#              instead of a list raises Incorrect param type!
	#   see        CanContainACharBetween, CanContainACharAmong
	def CanContainAChar(p, pRepeat)
	
		if NOT isList(p)
			StzRaise("Incorrect param type! p must be a list.")
		ok
	
		# Constructing the chars from the first param p
	
		if isList(p)
	
			_oTempList_ = new stzList(p)
	
			if _oTempList_.IsBetweenOrFromNamedParam()
			# CanContainAChar(:Between = [ "A", :And = "Z" ], :RepeatedExactly = 2Times())
			# CanContainAChar(:Between = "A-Z" ], :RepeatedExactly = [ 2 :Times() ])
	
				This.CanContainACharBetween(p[2], pRepeat)
	
			but _oTempList_.IsAmongNamedParam()
			# CanContainAChar(:Among = [ "-", " " ], :RepeatdAtMost = 1Time())
			# CanContainAChar(:Among = "- ", :RepeatdAtMost = 1Time())

				This.CanContainACharAmong(p[2], pRepeat)
	
	
			but _oTempList_.IsFromNamedParam()
			# CanContainADigit(:From = [ "0", :To = "9"], :RepeatedExactly = 3Times())
	
				This.CanContainACharFrom(p[2], pRepeat)
	
			ok
	
		ok

		# Raises error R14 today instead of adding a character class given as a named parameter.
		#
		#   p          the named pair: Between, Among or From with their characters
		#   pRepeat    the repeat pair such as [ RepeatedExactly, 2 ], or a number
		#   returns    nothing, when it works
		#   note       the name is a misspelling of CanContainChar
		#   warning    Raises error R14 today: it calls CanContainAChar, which calls the missing
		#              IsBetweenOrFromNamedParam
		#   see        CanContainAChar
		def CanContaingChar(p, pRepeat)
			This.CanContainAChar(p, pRepeat)

	# Appends a class that matches one character from the first given char to the second, repeated as asked.
	#
	#   paChars    the two end characters as a list such as [ A, Z ], or [ A, [ to, Z ] ]
	#   pRepeat    a number for that many times, or a pair such as [ RepeatedBetween, [ 2, 4 ] ]
	#   returns    nothing; read the result with Pattern
	#   note       [ A, Z ] with 3 gives [A-Z]{3}; RepeatedAtMost writes ? whatever the count
	#   warning    the text form A-Z raises error R14 today because it calls a Char function that
	#              does not exist; a repeat name it does not know, such as Zzz, drops the quantifier
	#              without a word
	#   see        CanContainACharAmong, AddCharsRange
	def CanContainACharBetween(paChars, pRepeat)
		# CanContainAChar(:Between = [ "A", :And = "Z" ], :RepeatedExactly = 2Times())
		# CanContainAChar(:Between = "A-Z" ], :RepeatedExactly = [ 2 :Times() ])

		# Resolving the chars param

		_between_ = paChars
		_c1_ = ""
		_c2_ = ""

		if isString(_between_)

			_oTempStr_ = new stzString(_between_)

			if _oTempStr_.NumberOfChars() = 3 and _oTempStr_.Char(2) = "-"

				_c1_ = _oTempStr_.Char(1)
				_c2_ = _oTempStr_.Char(2)

			ok

		but isList(_between_)

			if len(_between_) = 2

				_c1_ = _between_[1]

				if isList(_between_[2]) and len(_between_[2]) = 2 and
				   isString(_between_[2][1]) and
				   (_between_[2][1] = "and" or _between_[2][1] = "to")

					_c2_ = _between_[2][2]

				else
					_c2_ = _between_[2]
				ok

			ok

		ok

		if _c1_ = 1 or _c2_ = ""
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
	#   see        CanContainACharBetween, AddAmongChars
		#>
	def CanContainACharAmong(pChars, pRepeat)
		# CanContainACharAmong([ "A", "B", "C" ], :RepeatdAtMost = 1Time())
		# CanContainACharAmong("ABC", :RepeatdAtMost = 1Time())


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

	# Raises error R14 today instead of adding a digit class given as a named parameter such as :Between = [ 0, 9 ].
	#
	#   p          the named pair: Between, Among or From with their digits
	#   pRepeat    the repeat pair such as [ RepeatedExactly, 3 ], or a number
	#   returns    nothing, when it works
	#   note       CanContainADigitBetween and CanContainADigitAmong work when called directly
	#   warning    Raises error R14 today: it calls IsBetweenOrFromNamedParam on a stzList, a method
	#              that does not exist; seen with the Between, Among and From forms
	#   see        CanContainADigitBetween, CanContainADigitAmong
	#@ aka  --
	def CanContainADigit(p, pRepeat)
	
		if NOT isList(p)
			StzRaise("Incorrect param type! p must be a list.")
		ok
	
		# Constructing the chars from the first param p
	
		if isList(p)
	
			_oTempList_ = new stzList(p)
	
			if _oTempList_.IsBetweenOrFromNamedParam()	
				This.CanContainADigitBetween(p[2], pRepeat)
	
			but _oTempList_.IsAmongNamedParam()
				This.CanContainAdigitAmong(p[2], pRepeat)
	
	
			but _oTempList_.IsFromNamedParam()	
				This.CanContainAdigitFrom(p[2], pRepeat)
	
			ok
	
		ok

		# Raises error R14 today instead of adding a digit class given as a named parameter.
		#
		#   p          the named pair: Between, Among or From with their digits
		#   pRepeat    the repeat pair such as [ RepeatedExactly, 3 ], or a number
		#   returns    nothing, when it works
		#   note       the name is a misspelling of CanContainDigit
		#   warning    Raises error R14 today: it calls CanContainADigit, which calls the missing
		#              IsBetweenOrFromNamedParam
		#   see        CanContainADigit
		def CanContaingdigit(p, pRepeat)
			This.CanContainADigit(p, pRepeat)

	# Appends a class that matches one digit from the first given digit to the second, repeated as asked.
	#
	#   paDigits   the two end digits as a list such as [ 0, 9 ]
	#   pRepeat    a number for that many times, or a pair such as [ RepeatedExactly, 3 ]
	#   returns    nothing; read the result with Pattern
	#   note       [ 0, 9 ] with 3 gives [0-9]{3}; CanContainDigitBetween is the same call
	#   warning    the text form 0-9 raises error R14 today because it calls a Char function that
	#              does not exist; a non-digit end raises Can't proceed! You must provide two digits
	#              as chars.
	#   see        CanContainADigitAmong, AddDigitsRange
	def CanContainADigitBetween(paDigits, pRepeat)

		# Resolving the digits param

		_between_ = paDigits
		_cDigit1_ = ""
		_cDigit2_ = ""

		if isString(_between_)

			_oTempStr_ = new stzString(_between_)

			if _oTempStr_.NumberOfChars() = 3 and _oTempStr_.Char(2) = "-" and
			   _oTempStr_.CharQ(1).IsNumberInString() and
			   _oTempStr_.CharQ(3).IsNumberInString()

				_cDigit1_ = _oTempStr_.Char(1)
				_cDigit2_ = _oTempStr_.Char(2)

			ok

		but isList(_between_)

			if len(_between_) = 2

				_cDigit1_ = _between_[1]

				if isList(_between_[2]) and len(_between_[2]) = 2 and
				   isString(_between_[2][1]) and
				   (_between_[2][1] = "and" or _between_[2][1] = "to")

					_cDigit2_ = _between_[2][2]

				else
					_cDigit2_ = _between_[2]
				ok

			ok

		ok

		if NOT ( IsChar(_cDigit1_) and IsNumberInString(_cDigit1_) and
			 IsChar(_cDigit2_) and IsNumberInString(_cDigit2_) )

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
	#   pDigits    the digits as a text such as 135
	#   pRepeat    a number for that many times, or a repeat pair such as [ RepeatedExactly, 3 ]
	#   returns    nothing; read the result with Pattern
	#   note       135 with 3 gives [135]{3}; CanContainDigitAmong is the same call
	#   warning    a list of digits such as [ 1, 3 ] raises error R3 today, because IsListOfDigits
	#              does not exist; letters in a text raise Incorrect param type!
	#   see        CanContainADigitBetween, AddAmongDigits
		#>
	def CanContainADigitAmong(pDigits, pRepeat)

		if NOT ( (isString(pDigits) and IsNumberInString(pDigits) or
		         ( isList(pDigits) and IsListOfDigits(pDigits) ) ) )

			StzRaise("Incorrect param type! pDigits must be digits in a list or string.")
		ok

		if isString(pDigits)
			_acDigits_ = Chars(pDigits)

		else // isListOfChars(pChars)
			_acDigits_ = pDigits
		ok

		# Resolving the repetition params

		_aRepeat_ = pvtGetRepeat(pRepeat)

		_cRepeat_ = _aRepeat_[1]
		_n1_ = _aRepeat_[2]
		_n2_ = _aRepeat_[3]

		This.AddAmongChars(_acdigits_, _cRepeat_, _n1_, _n2_)


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
	#   note          a name gives (?P=w)
	#   warning       a number writes two backslashes before the digit, \\1 at 3 characters, where
	#                 one is meant: the pattern then matches a backslash followed by 1
	#   see           DefineGroup, AddCapturingGroup
	def AddBackReference(pcGroupName)
		# Example usage:
		# o1 = new stzRegexMaker
		# o1.AddCapturingGroup("tag", "<([a-z]+)>.*?</\1>")
		# o1.AddBackreference("tag")  # Matches same tag again
	
		if isString(pcGroupName)
			@acFragments + "(?P=" + pcGroupName + ")"
		but isNumber(pcGroupName)  
			@acFragments + "\\" + pcGroupName
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
			@acFragments + "(?:" + pcPattern + ")"
		
		but pcName = :atomic
			@acFragments + "(?>" + pcPattern + ")"
		
		but isString(pcName)
			@acFragments + "(?P<" + pcName + ">" + pcPattern + ")"
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
			@acFragments + pcPattern + "+"
	
		on :shortest   # Takes shortest possible match (formerly 'lazy')
			@acFragments + pcPattern + "+?"
	
		on :complete   # Matches everything at once without backtracking (formerly 'possessive')
			@acFragments + pcPattern + "++"
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
			@acFragments + pcPattern + "++"
		on :lazy
			@acFragments + pcPattern + "+?"
		on :greedy
			@acFragments + pcPattern + "+"
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
	
		@acFragments + "(?#" + pcText + ")"
	
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
			@acFragments + "(?i)" + pcPattern
		on :sensitive  
			@acFragments + "(?-i)" + pcPattern
		on :mixed
			@acFragments + "(?i:" + pcPattern + ")"
		off
	
	  #--------------------------------#
	 #     PATTERN COMPOSITION        #
	#--------------------------------#
	
	# Appends several patterns combined as all-must-match lookaheads, as alternatives or in sequence, but only the first works today.
	#
	#   paPatterns   the patterns as a list of texts
	#   pcMode       and, or or sequence
	#   returns      nothing; read the result with Pattern
	#   note         an unknown mode adds nothing
	#   warning      Raises error R20 today for the or and sequence modes: they call join with two
	#                arguments where it takes one; and works, a and b giving (?=a)(?=b)
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
			@acFragments + "(" + join(paPatterns, "|") + ")"
			
		on :sequence
			@acFragments + join(paPatterns, "")
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
		@acFragments + "(?P<" + pcName + ">" + pcPattern + ")"
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

		@acFragments + "(?:" + @aGroups[_nGroup_][2] + ")"

		# Appends the pattern of a defined group again, as a non-capturing group.
		#
		#   pcGroupName   the name of a group made with DefineGroup
		#   returns       nothing; read the result with Pattern
		#   note          the same call as ReuseGroupPattern
		#   see           ReuseGroupPattern
		def ReuseGroup(pcGroupName)
			This.ReuseGroupPattern(pcGroupName)

	# Raises error R24 today instead of appending a closing tag that repeats a defined group.
	#
	#   pcGroupName   the name of a group made with DefineGroup
	#   returns       nothing, when it works
	#   note          an unknown name raises No group named ... has been defined before that
	#   warning       Raises error R24 today: after finding the group it uses the variable
	#                 pcTagGroupName, which is not a parameter of this method; seen with two
	#                 different group names
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

		@acFragments + "</(?P=" + pcTagGroupName + ")>"

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

		@acFragments + "</(?P=" + pcTagGroupName + ")>"

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

		@acFragments + "(?=" + @aGroups[_nGroup_][2] + ")"

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
	#   note       a number n gives RepeatedExactly, n; a name that is not RepeatedExactly,
	#              RepeatedAtMost, RepeatedBetween or RepeatedSeveralTimes gives an empty kind,
	#              which is why the quantifier vanishes; anything that is not a pair raises
	#              Incorrect param type!
	#   warning    private: calling it from outside raises R26, so it was read through
	#              CanContainACharBetween
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
			:RepeatedAtMost,
			:RepeatedBetween,
			:RepeatedSeveralTimes
		]
	
		_cRepeat_ = ""

		if StzFindFirst(pRepeat[1], _aTempList_) > 0
			_cRepeat_ = pRepeat[1]
		ok
	
		# Checking the quantifier
	
		if NOT ( isNumber(pRepeat[2]) or ( isList(pRepeat[2]) and len(pRepeat[2]) = 2 and
			 isNumber(pRepeat[2][1]) and isNumber(pRepeat[2][2]) ) )
	
			StzRaise("Incorrect param type! pRepeat must be a pair of numbers.")
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

#===============================#
#  RECURSIVE REGEX MAKER CLASS  #
#===============================#

class stzNestedRegexMaker from stzRecursiveRegexMaker

class stzRecursiveRegexMaker from stzObject

	@aLevels = []
	@bNamedRecursion = 0
	# @aParentStack / @nParentIndex lived here to track parents during a
	# declarative setup that was replaced: nothing ever pushed to the stack, so
	# the index it derived was always 0, and nothing read it either.
	# AddChildLevel() finds a parent BY NAME (pvtFindLevelByName).

	def init()
		This.EnableNamedRecursion()

	def AddLevel(cName, _cPattern_)
		@aLevels + [
			:name    = cName,
			:pattern = _cPattern_,
			:parent  = "",
			:children = [],
			:quant   = ""
		]


	def AddChildLevel(cParentName, cChildName, _cPattern_)
		_nParent_ = pvtFindLevelByName(cParentName)
		
		if _nParent_ = 0
			StzRaise("Parent level '" + cParentName + "' not found!")
		ok

		AddLevel(cChildName, _cPattern_)
		
		_nChild_ = len(@aLevels)
		@aLevels[_nChild_][:parent] = _nParent_
		@aLevels[_nParent_][:children] + _nChild_

	def AddQuantifier(cLevelName, cQuant)
		_nLevel_ = pvtFindLevelByName(cLevelName)
		
		if _nLevel_ = 0
			StzRaise("Level '" + cLevelName + "' not found!")
		ok

		@aLevels[_nLevel_][:quant] = cQuant

	def EnableNamedRecursion()
		@bNamedRecursion = 1
		
	def DisableNamedRecursion()
		@bNamedRecursion = 0

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

	def SubPattern(cLevelName)
		_nLevel_ = pvtFindLevelByName(cLevelName)
		
		if _nLevel_ = 0
			return ""
		ok

		return pvtBuildPattern(_nLevel_)

	def LevelNames()
		_aResult_ = []
		_nLevels2Len_ = len(@aLevels)
		for _iLoopLevels2_ = 1 to _nLevels2Len_
			_level_ = @aLevels[_iLoopLevels2_]
			_aResult_ + _level_[:name]
		next
		return _aResult_

	def NumberOfLevels()
		return len(@aLevels)

	def HasLevel(cName)
		return pvtFindLevelByName(cName) > 0

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

	def Reset()
		@aLevels = []
		@bNamedRecursion = 0

	private

	def pvtFindLevelByName(cName)

		_nLevelsLen_ = len(@aLevels)
		for i = 1 to _nLevelsLen_
			if @aLevels[i][:name] = cName
				return i
			ok
		next

		return 0

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

		if HasKey(_level_[:quant])

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

class stzConditionalRegexMaker from stzObject

	@cCondition = ""    # Stores the if condition
	@cThenPart = ""     # Stores the then pattern
	@cElsePart = ""     # Stores the else pattern (optional)
	
	def init()
		Reset()

	def Reset()
		@cCondition = ""
		@cThenPart = ""
		@cElsePart = ""

	  #------------------#
	 #     IF PART      #
	#------------------#

	def IfMatch(pcPattern)
		if isList(pcPattern) and len(pcPattern) = 2 and isString(pcPattern[1]) and pcPattern[1] = "pattern"
			pcPattern = pcPattern[2]
		ok

		if NOT isString(pcPattern)
			StzRaise("Incorrect param type! pcPattern must be a string.")
		ok

		@cCondition = "(?(?=" + pcPattern + ")"
		return This

	def IfNotMatch(pcPattern)
		if isList(pcPattern) and len(pcPattern) = 2 and isString(pcPattern[1]) and pcPattern[1] = "pattern"
			pcPattern = pcPattern[2]
		ok

		if NOT isString(pcPattern)
			StzRaise("Incorrect param type! pcPattern must be a string.")
		ok

		@cCondition = "(?(?!" + pcPattern + ")"
		return This

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

	# Takes LITERAL TEXT, not a pattern. IfStartsWith("+") means a plus
	# sign, and it used to build (?=^+) -- a quantifier applied to ^, which
	# does not even compile. The argument is escaped, so metacharacters mean
	# themselves.
	#
	# IfMatch()/IfNotMatch() are the pattern-taking pair, and IfPrecededBy()/
	# IfFollowedBy() build look-arounds, which are patterns by nature. The
	# three text predicates here are the literal ones.
	def IfStartsWith(pcText)
		if isList(pcText) and IsPatternNamedParamList(pcText)
			pcText = pcText[2]
		ok

		if NOT isString(pcText)
			StzRaise("Incorrect param type! pcText must be a string.")
		ok

		return This.IfMatch("^" + StzRegexEscape(pcText))

	# Literal text -- IfEndsWith(".edu") means the four characters ".edu",
	# not "any character followed by edu", which is what it built before.
	def IfEndsWith(pcText)
		if isList(pcText) and IsPatternNamedParamList(pcText)
			pcText = pcText[2]
		ok

		if NOT isString(pcText)
			StzRaise("Incorrect param type! pcText must be a string.")
		ok

		return This.IfMatch(StzRegexEscape(pcText) + "$")

	# Literal text.
	def IfContains(pcText)
		if isList(pcText) and IsPatternNamedParamList(pcText)
			pcText = pcText[2]
		ok

		if NOT isString(pcText)
			StzRaise("Incorrect param type! pcText must be a string.")
		ok

		return This.IfMatch(".*" + StzRegexEscape(pcText) + ".*")

	def IfPrecededBy(pcPattern)
		if isList(pcPattern) and IsPatternNamedParamList(pcPattern)
			pPattern = pPattern[2]
		ok

		if NOT isString(pcPattern)
			StzRaise("Incorrect param type! pcPattern must be a string.")
		ok

		return This.IfMatch("(?<=" + pcPattern + ")")

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

	def Pattern()
		if @cCondition = ""
			return ""
		ok

		_cResult_ = @cCondition + @cThenPart

		if @cElsePart != ""
			_cResult_ += "|" + @cElsePart
		ok

		return _cResult_ + ")"

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

class stzRegexLookaroundMaker from stzObject
	@cDirection = ""	# 'ahead' or 'behind'
	@cType = ""    		# 'positive' or 'negative' 
	@cPattern = ""		# The actual pattern to look for
	@cMainPattern = ""	# The main pattern to match (optional)

	def init()
		# Do nothing

	def Reset()
		@cDirection = ""
		@cType = ""
		@cPattern = ""
		@cMainPattern = ""
		return This

	  #--------------------------#
	 #    POSITIVE PATTERNS     #
	#--------------------------#

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

		#>

	def MustBeFollowedByNumber()
		return This.MustBeFollowedBy("\d+")

		#< @FunctionAlternativeForms

		def LookingForNumber()
			return This.MustBeFollowedByNumber()

		#>

	def MustBePrecededByNumber()
		return This.MustBePrecededBy("\d+")

		#< @FunctionAlternativeForms

		def LookingBehindNumber()
			return This.MustBePrecededByNumber()

		#>

	def MustBeFollowedBySpace()
		return This.MustBeFollowedBy("\s+")

		#< @FunctionAlternativeForms

		def LookingForSpace()
			return This.MustBeFollowedBySpace()

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

	def Info()
		_aResult_ = [
			:direction = @cDirection,
			:type = @cType,
			:lookPattern = @cPattern,
			:mainPattern = @cMainPattern,
			:pattern = This.Pattern()
		]

		return _aResult_
