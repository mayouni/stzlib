

func StzRegExpMakerQ()
	return new stzRegExpMaker

func rxp(pcPattName)
	return regExpPatterns()[pcPattName]

	func pat(pcPattName)
		return rxp(pcPattName)

	func patt(pcPattName)
		return rxp(pcPattName)

	func Pattern(pcPattName)
		return rxp(pcPattName)

	func PatternByName(pcPattName)
		return rxp(pcPattName)

	func RegExpPattern(pcPattName)
		return rxp(pcPattName)

func 1Time()
	return 1

func 2Times()
	return 2

func 3Times()
	return 3

func NTimes(n)
	return n

class stzRegExpMaker
	acFragments = []
	aSequences = []
  
	def init()

	  #--------------------#
	 #  ADDING SEQUENCES  #
	#--------------------#

	def AddRange(cType, cRange, cQuant, nTimes1, nTimes2)

		# Checking params

		if isString(nTimes2) and (nTimes2 = :Time or nTimes2 = :Times)
			nTimes = 0

		# case of named param like :And = [3, :Times]

		but isList(nTimes2) and stzListQ(nTimes2).IsAndNamedParam()
			if isNumber(nTimes2[2])
				nTimes2 = nTimes2[2]

			but isList(nTimes2[2])

				if isNumber(nTimes2[2][1]) and
				   isString(nTimes2[2][2]) and
				   (nTimes2[2][2] = :Time or nTimes2[2][2] = :Times)

					nTimes2 = nTimes2[2][1]
				else
					StzRaise("Incorrect param type!")
				ok
			ok
		ok

		# Constrcuting the main pattern string

		cPattern = ""

		if isList(cRange)
			cRange = join(cRange)
		ok

		if cType = :among
			cPattern = "[" + substr(cRange, "SPACE", " ") + "]"

		but cType = :notAmong
			cPattern = "[^" + substr(cRange, "SPACE", " ") + "]"

		else
			cPattern = "[" + cRange + "]"
		ok

		# Constructing the quantifier part of the pattern

        	cQuantifier = ""

		if cQuant = :repeatedExactly
			cQuantifier = "{" + nTimes1 + "}"

		but cQuant = :repeatedAtLeast
			cQuantifier = "{" + nTimes1 + ",}"

		but cQuant = :repeatedAtMost
			cQuantifier = "?"

		but cQuant = :repeatedBetween
			cQuantifier = "{" + nTimes1 + "," + nTimes2 + "}"

		but cQuant =  :repeatedSeveral
			cQuantifier = "*"
		ok

		# Storing the complete pattern (main string + quantifier part)

        	acFragments + (cPattern + cQuantifier)

		# String the elements of the sequence applied

        	aSequences + [ cType, cRange, cQuant, nTimes1, nTimes2 ]
        

	def AddAmongChars(cChars, cQuant, nTimes1, nTimes2)

		if isString(cChars)
			cChars = Chars(cChars)
		ok
        
		AddRange(:among, cChars, cQuant, nTimes1, nTimes2)

		def AddAmongDigits(cDigits, cQuant, nTimes1, nTimes2)
			if isString(cDigits)
				cDigits = Chars(cDigits)
			ok

			This.AddAmongChars(cDigits, cQuant, nTimes1, nTimes2)

	def AddNotAmongChars(cChars, cQuant, nTimes1, nTimes2)
		if isString(cChars)
			cChars = Chars(cChars)
		ok
        
		AddRange(:NotAmong, cChars, cQuant, nTimes1, nTimes2)

		def AddNotAmongDigits(cDigits, cQuant, nTimes1, nTimes2)
			if isString(cDigits)
				cDigits = Chars(cDigits)
			ok

			This.AddNotAmongChars(cDigits, cQuant, nTimes1, nTimes2)

	def AddCharsRange(cRange, cQuant, nTimes1, nTimes2)
		This.AddRange(:Between, cRange, cQuant, nTimes1, nTimes2)
 
		def AddDigitsRange(cDigits, cQuant, nTimes1, nTimes2)
			if isString(cDigits)
				cDigits = Chars(cDigits)
			ok

			This.AddCharsRange(cDigits, cQuant, nTimes1, nTimes2)

	  #------------------------------------------------#
	 #  GETTING THE STRING PATTERN ANT ITS FRAGMENTS  #
	#------------------------------------------------#

	def Pattern()
		cResult = ""

		for cFrag in acFragments
			cResult += cFrag
		next

		return cResult

	  #-----------------------------------------------#
	 #  GETTING THE FRAGMENTS OF THE PATTERN STRING  #
	#-----------------------------------------------#

	def Fragments()
		return acFragments

		def Frags()
			return This.Fragments()

	def NumberOfFragements()
		return len(acFragments)

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

		#>

	def Fragment(n)
		return acFragments[n]

		def Frag(n)
			return This.Fragment(n)

	def FragmentXT(n)
		return [ acFragments[n], aSequences[n] ]

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

	def Quantifiers()
		#TODO

	def QuantifiersCommands()
		#TODO

		def QuantifiersXT()

	  #-------------------------------------------------------------#
	 #  GETTING THE SEQUENCES (FRAGMENTS IN COMPUTABLE DATA FORM)  #
	#-------------------------------------------------------------#

	def Sequences()
		return aSequences

		def Seqs()
			return This.Sequences()

		def Commands()
			return This.Sequences()

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

		#>

	def Sequence(n)
		return aSequences[n]

		def Seq(n)
			return This.Sequence(n)

		def Command(n)
			return This.Sequence(n)

	def SequenceXT(n)
		return [ aSequences[n], acFragments[n] ]

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

		def CommandAndFragment()
			return This.SequenceXT(n)

		def CommandAndFrag()
			return This.SequenceXT(n)

		def CommandAndItsFragment()
			return This.SequenceXT(n)

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

	def RepeatSequence(n)

		aSequences + aSequences[n]
		acFragments + acFragments[n]

		def RepeatCommand(n)
			This.RepeatSequence(n)

	  #-----------------------------------------------#
	 #  DESIGING THE PATTERN IN A DECLARATIVE STYLE  #
	#-----------------------------------------------#

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

		def CanContaingChar(p, pRepeat)
			This.CanContainAChar(p, pRepeat)

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

	#--

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

		def CanContaingdigit(p, pRepeat)
			This.CanContainADigit(p, pRepeat)

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

	#------
	PRIVATE
	#------

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

		if ring_find(_aTempList_, pRepeat[1]) > 0
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
