
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

func rxp(pcPattName)
	cResult = RegexPatterns()[pcPattName]
	if cResult = ""
		StzRaise("The pattern name you provided does not exist in stzRegexData file.")
	ok

	return cResult

	func pat(pcPattName)
		return rxp(pcPattName)

	func patt(pcPattName)
		return rxp(pcPattName)

	func Pattern(pcPattName)
		return rxp(pcPattName)

	func PatternByName(pcPattName)
		return rxp(pcPattName)

	func RegexPattern(pcPattName)
		return rxp(pcPattName)


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

class stzRegexMaker
	acFragments = []
	aSequences = []
	aGroups = []  	# List of [name, pattern] pairs

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

		but cQuant =  :repeatedSeveralTimes or cQuant = :repeatedSeveral
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

	  #----------------------------#
	 #  ADDING A LITTERAL STRING  #
	#----------------------------#

	def AddLiteral(pcStr)
		acFragments + pcStr

	  #------------------------------#
	 #     CHARACTER CLASS HELPER    #
	#------------------------------#
	
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
	
		def AddCharClass(pcClass)
			This.AddCharacterClass(pcClass)

		def AddClass(pcClass)
			This.AddCharacterClass(pcClass)

	  #------------------------------#
	 #     COMMON PATTERN HELPER    # 
	#------------------------------#
	
	def AddCommonPattern(pcType)
		# Example :
		# o1 = new stzRegexMaker
		# o1.AddCommonPattern(:email)  # Matches email addresses
		# o1.AddCommonPattern(:phone)  # Matches phone numbers
	
		acFragments + rxp(pcType)
	
	  #-------------------------------#
	 #     BACKREFERENCE HELPER      #
	#-------------------------------#
	
	def AddBackReference(pcGroupName)
		# Example usage:
		# o1 = new stzRegexMaker
		# o1.AddCapturingGroup("tag", "<([a-z]+)>.*?</\1>")
		# o1.AddBackreference("tag")  # Matches same tag again
	
		if isString(pcGroupName)
			acFragments + "(?P=" + pcGroupName + ")"
		but isNumber(pcGroupName)  
			acFragments + "\\" + pcGroupName
		ok
	
	  #-------------------------------#
	 #     UNICODE CATEGORY HELPER   #
	#-------------------------------#
	
	def AddUnicodeCategory(pcCategory)
		# Example usage:
		# o1 = new stzRegexMaker
		# o1.AddUnicodeCategory(:letter)      # Matches any letter
		# o1.AddUnicodeCategory(:punctuation) # Matches punctuation
	
		switch pcCategory
		on :letter
			acFragments + "\p{L}"
		on :number
			acFragments + "\p{N}" 
		on :punctuation 
			acFragments + "\p{P}"
		on :symbol
			acFragments + "\p{S}"
		off
	
	  #-------------------------------#
	 #     WORD BOUNDARY HELPER      #
	#-------------------------------#
	
	def AddWordBoundary(pcType)
		# Example : 
		# o1 = new stzRegexMaker
		# o1.AddWordBoundary(:start)
		# o1.AddAmongChars("test")   # Matches "test" at word start
		# o1.AddWordBoundary(:end)
	
		switch pcType
		on :start
			acFragments + "\b"
		on :end  
			acFragments + "\b"
		on :none
			acFragments + "\B"
		off
	
	  #--------------------------------#
	 #     CAPTURING GROUP HELPER     #
	#--------------------------------#
	
	def AddCapturingGroup(pcName, pcPattern) 
		# Example :
		# o1 = new stzRegexMaker
		# o1.AddCapturingGroup("number", "\d+")     	# Named group
		# o1.AddCapturingGroup(:nonCapturing, "\w+") 	# Non-capturing
		# o1.AddCapturingGroup(:atomic, "[aeiou]+")  	# Atomic group
	
		if pcName = :nonCapturing
			acFragments + "(?:" + pcPattern + ")"
		
		but pcName = :atomic
			acFragments + "(?>" + pcPattern + ")"
		
		but isString(pcName)
			acFragments + "(?P<" + pcName + ">" + pcPattern + ")"
		ok
	
	  #-----------------------------------------#
	 #     MATCH LENGTH BEHAVIOR HELPER        #
	#-----------------------------------------#
	
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
			acFragments + pcPattern + "+"
	
		on :shortest   # Takes shortest possible match (formerly 'lazy')
			acFragments + pcPattern + "+?"
	
		on :complete   # Matches everything at once without backtracking (formerly 'possessive')
			acFragments + pcPattern + "++"
		off
	
	  #--------------------------------#
	 #     VARIABLE LENGTH HELPER      #
	#--------------------------------#
	
	def AddVariableLength(pcPattern, pcQuantifier)
		# Example :
		# o1 = new stzRegexMaker  
		# o1.AddVariableLength("\w+", :lazy)     	# Lazy match
		# o1.AddVariableLength("[0-9]+", :greedy) 	# Greedy match
	
		switch pcQuantifier
		on :possessive
			acFragments + pcPattern + "++"
		on :lazy
			acFragments + pcPattern + "+?"
		on :greedy
			acFragments + pcPattern + "+"
		off
	
	  #----------------------#
	 #    COMMENT HELPER    #
	#----------------------#
	
	def AddComment(pcText)
		# Example :
		# o1 = new stzRegexMaker
		# o1.AddComment("Match emails") 
		# o1.AddCommonPattern(:email)
	
		acFragments + "(?#" + pcText + ")"
	
	  #--------------------------------#
	 #     CASE SENSITIVITY HELPER    #
	#--------------------------------#
	
	def SetCase(pcMode)
		This.SetCaseXT(pcMode, "")

	def SetCaseXT(pcMode, pcPattern)
		# Example :
		# o1 = new stzRegexMaker
		# o1.SetCaseXT(:insensitive, "Test")  # Matches test/TEST/Test
		# o1.SetCaseXT(:sensitive, "Test")    # Matches only "Test"
	
		switch pcMode
		on :insensitive
			acFragments + "(?i)" + pcPattern
		on :sensitive  
			acFragments + "(?-i)" + pcPattern
		on :mixed
			acFragments + "(?i:" + pcPattern + ")"
		off
	
	  #--------------------------------#
	 #     PATTERN COMPOSITION        #
	#--------------------------------#
	
	def ComposePatterns(paPatterns, pcMode)
		# Example :
		# o1 = new stzRegexMaker
		# patterns = ["\d+", "[A-Z]+"]
		# o1.ComposePatterns(patterns, :and)  # Must contain both
		# o1.ComposePatterns(patterns, :or)   # Contains either
	
		switch pcMode
		on :and
			cResult = ""
			for cPattern in paPatterns
				cResult += "(?=" + cPattern + ")"
			next
			acFragments + cResult
			
		on :or
			acFragments + "(" + join(paPatterns, "|") + ")"
			
		on :sequence
			acFragments + join(paPatterns, "")
		off

	  #----------------------------------------#
	 #     GROUP REFERENCE SYSTEM             #
	#----------------------------------------#

	def DefineGroup(pcName, pcPattern)
		# Defines a named capturing group that can be referenced later.
		# Returns group index for error checking.

		# Example:
		# o1.DefineGroup("tag", "<([a-z]+)>")
		# Now "tag" group can be referenced later

		if NOT isString(pcName)
			StzRaise("Group name must be a string")
		ok

		aGroups + [pcName, pcPattern]
		acFragments + "(?P<" + pcName + ">" + pcPattern + ")"
		return len(aGroups)

	def ReuseGroupPattern(pcGroupName)
		# Reuses the pattern of a previously defined group
		# without capturing or referencing any matched content.

		# Example:
		# o1.DefineGroup("word", "\w+")
		# o1.ReuseGroupPattern("word") # Uses same \w+ pattern

		nGroup = FindGroup(pcGroupName)
		if nGroup = 0
			StzRaise("No group named '" + pcGroupName + "' has been defined")
		ok

		acFragments + "(?:" + aGroups[nGroup][2] + ")"

		def ReuseGroup(pcGroupName)
			This.ReuseGroupPattern(pcGroupName)

	def MatchSameContentAs(pcGroupName)
		# Requires matching the exact same text that was matched
		# by the referenced group. The group must be defined earlier
		# in the pattern.

		# Example:
		# Match repeated words:
		# o1.DefineGroup("word", "\w+")
		# o1.AddCharacterClass(:space)
		# o1.MatchSameContentAs("word") # Must match same word

		nGroup = FindGroup(pcGroupName)
		if nGroup = 0
			StzRaise("No group named '" + pcGroupName + "' has been defined")
		ok

		acFragments + "</(?P=" + pcTagGroupName + ")>"

	def MatchOppositeTagAs(pcTagGroupName)
		# Special case for HTML/XML - matches the closing tag
		# for a previously captured opening tag. Group must contain
		# the tag name.

		# Example:
		# Match balanced HTML tags:
		# o1.DefineGroup("tag", "<([a-z]+)>")
		# o1.AddMatchLength(".*", :shortest) 	# Content
		# o1.MatchOppositeTagAs("tag")      	# Closing tag

		nGroup = FindGroup(pcTagGroupName)
		if nGroup = 0
			StzRaise("No tag group named '" + pcTagGroupName + "' has been defined")
		ok

		acFragments + "</(?P=" + pcTagGroupName + ")>"

	def IsBeforeGroup(pcGroupName)
		# Positive lookahead - checks if the referenced group pattern
		# appears ahead without consuming it.

		# Example:
		# Match word before number:
		# o1.DefineGroup("num", "\d+")
		# o1.AddCharacterClass(:word)
		# o1.IsBeforeGroup("num")

		nGroup = FindGroup(pcGroupName)
		if nGroup = 0
			StzRaise("No group named '" + pcGroupName + "' has been defined")
		ok

		acFragments + "(?=" + aGroups[nGroup][2] + ")"

	def FindGroup(pcName)
		# Returns index of named group or 0 if not found

		for i = 1 to len(aGroups)
			if aGroups[i][1] = pcName
				return i
			ok
		next
		return 0

	#-----------#
	   PRIVATE
	#-----------#

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

#===============================#
#  RECURSIVE REGEX MAKER CLASS  #
#===============================#

class stzNestedRegexMaker from stzRecursiveRegexMaker

class stzRecursiveRegexMaker

	aLevels = []
	bNamedRecursion = FALSE
	aParentStack = []  # Tracks current parent levels during declarative setup
	nParentIndex = 0

	def init()
		This.EnableNamedRecursion()

	def AddLevel(cName, cPattern)
		aLevels + [
			:name    = cName,
			:pattern = cPattern,
			:parent  = NULL,
			:children = [],
			:quant   = ""
		]

		nParentIndex = len(aParentStack)

	def AddChildLevel(cParentName, cChildName, cPattern)
		nParent = pvtFindLevelByName(cParentName)
		
		if nParent = 0
			StzRaise("Parent level '" + cParentName + "' not found!")
		ok

		AddLevel(cChildName, cPattern)
		
		nChild = len(aLevels)
		aLevels[nChild][:parent] = nParent
		aLevels[nParent][:children] + nChild

	def AddQuantifier(cLevelName, cQuant)
		nLevel = pvtFindLevelByName(cLevelName)
		
		if nLevel = 0
			StzRaise("Level '" + cLevelName + "' not found!")
		ok

		aLevels[nLevel][:quant] = cQuant

	def EnableNamedRecursion()
		bNamedRecursion = TRUE
		
	def DisableNamedRecursion()
		bNamedRecursion = FALSE

	def Pattern()
		if len(aLevels) = 0
			return ""
		ok

		cPattern = ""
		
		# Process all root levels (those without parents)

		for i = 1 to len(aLevels)
			if aLevels[i][:parent] = NULL
				cPattern += pvtBuildPattern(i)
			ok
		next

		return cPattern

	def SubPattern(cLevelName)
		nLevel = pvtFindLevelByName(cLevelName)
		
		if nLevel = 0
			return ""
		ok

		return pvtBuildPattern(nLevel)

	def LevelNames()
		aResult = []
		for level in aLevels
			aResult + level[:name]
		next
		return aResult

	def NumberOfLevels()
		return len(aLevels)

	def HasLevel(cName)
		return pvtFindLevelByName(cName) > 0

	def LevelParent(cName)
		nLevel = pvtFindLevelByName(cName)
		if nLevel = 0
			return ""
		ok
		nParent = aLevels[nLevel][:parent]
		if nParent = NULL
			return ""
		ok
		return aLevels[nParent][:name]

	def LevelChildren(cName)

		nLevel = pvtFindLevelByName(cName)

		if nLevel = 0
			return []
		ok

		aResult = []

		for nChild in aLevels[nLevel][:children]
			aResult + aLevels[nChild][:name]
		next

		return aResult

	def Info()

		aResult = []

		for level in aLevels

			aInfo = [
				:name = level[:name],
				:pattern = level[:pattern],
				:parent = level[:parent],
				:children = level[:children],
				:quantifier = level[:quant]
			]

			aResult + aInfo
		next

		return aResult

	def Reset()
		aLevels = []
		bNamedRecursion = FALSE

	private

	def pvtFindLevelByName(cName)

		for i = 1 to len(aLevels)
			if aLevels[i][:name] = cName
				return i
			ok
		next

		return 0

	def pvtBuildPattern(nLevel)

		if nLevel < 1 or nLevel > len(aLevels)
			return ""
		ok

		level = aLevels[nLevel]
		cPattern = level[:pattern]

		# Process children first to properly nest them

		cChildrenPattern = ""

		for nChild in level[:children]
			cChildPattern = pvtBuildPattern(nChild)
			cChildrenPattern += cChildPattern
		next

		# Add children pattern to current level's pattern

		if cChildrenPattern != ""
			cPattern += cChildrenPattern
		ok

		# Add quantifier if present

		if level[:quant] != ""

			if bNamedRecursion

				# For named recursion, wrap pattern + children in capture group before quantifier
				cPattern = "(?P<" + level[:name] + ">" + cPattern + ")" + level[:quant]
			else

				cPattern += level[:quant]
			ok

		else
			if bNamedRecursion

				# Wrap in capture group without quantifier
				cPattern = "(?P<" + level[:name] + ">" + cPattern + ")"
			ok
		ok

		# Special handling for close pattern

		if lower(level[:name]) = "close"
			return level[:pattern]
		ok

		return cPattern

#=================================#
#  CONDITIONAL REGEX MAKER CLASS  #
#=================================#

class stzConditionalRegexMaker

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
		if isList(pcPattern) and stzListQ(pcPattern).IsPatternNamedParam()
			pcPattern = pcPattern[2]
		ok

		if NOT isString(pcPattern)
			StzRaise("Incorrect param type! pcPattern must be a string.")
		ok

		@cCondition = "(?(?=" + pcPattern + ")"
		return This

	def IfNotMatch(pcPattern)
		if isList(pcPattern) and stzListQ(pcPattern).IsPatternNamedParam()
			pcPattern = pcPattern[2]
		ok

		if NOT isString(pcPattern)
			StzRaise("Incorrect param type! pcPattern must be a string.")
		ok

		@cCondition = "(?(?!" + pcPattern + ")"
		return This

	def IfCaptured(pcGroupName)
		if isList(pcGroupName) and stzListQ(pcGroupName).IsGroupNamedParam()
			cGroupName = pGroupName[2]
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
		if isList(pcPattern) and stzListQ(pcPattern).IsPatternNamedParam()
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
		if isList(pcPattern) and stzListQ(pcPattern).IsPatternNamedParam()
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

	def IfStartsWith(pcPattern)
		if isList(pcPattern) and StzListQ(pcPattern).IsPatternNamedParam()
			pcPattern = pcPattern[2]
		ok

		if NOT isString(pcPattern)
			StzRaise("Incorrect param type! pcPattern must be a string.")
		ok

		return This.IfMatch("^" + pcPattern)

	def IfEndsWith(pcPattern)
		if isList(pcPattern) and StzListQ(pcPattern).IsPatternNamedParam()
			pcPattern = pcPattern[2]
		ok

		if NOT isString(pcPattern)
			StzRaise("Incorrect param type! pcPattern must be a string.")
		ok

		return This.IfMatch(pcPattern + "$")

	def IfContains(pcPattern)
		if isList(pcPattern) and StzListQ(pcPattern).IsPatternNamedParam()
			pcPattern = pcPattern[2]
		ok

		if NOT isString(pcPattern)
			StzRaise("Incorrect param type! pcPattern must be a string.")
		ok

		return This.IfMatch(".*" + pcPattern + ".*")

	def IfPrecededBy(pcPattern)
		if isList(pcPattern) and StzListQ(pcPattern).IsPatternNamedParam()
			pPattern = pPattern[2]
		ok

		if NOT isString(pcPattern)
			StzRaise("Incorrect param type! pcPattern must be a string.")
		ok

		return This.IfMatch("(?<=" + pcPattern + ")")

	def IfFollowedBy(pcPattern)
		if isList(pcPattern) and StzListQ(pcPattern).IsPatternNamedParam()
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

		cResult = @cCondition + @cThenPart

		if @cElsePart != ""
			cResult += "|" + @cElsePart
		ok

		return cResult + ")"

	def Info()
		aResult = [
			:condition = @cCondition,
			:then = @cThenPart,
			:else = @cElsePart,
			:pattern = This.Pattern()
		]

		return aResult

#==================================#
#  STZ REGEX LOOKING AROUND CLASS  #
#==================================#

class stzRegexLookaroundMaker
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
		if isList(pcPattern) and stzListQ(pcPattern).IsPatternNamedParam()
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
		if isList(pcPattern) and stzListQ(pcPattern).IsPatternNamedParam()
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
		if isList(pcPattern) and stzListQ(pcPattern).IsPatternNamedParam()
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
		if isList(pcPattern) and stzListQ(pcPattern).IsPatternNamedParam()
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
		if isList(pcPattern) and stzListQ(pcPattern).IsPatternNamedParam()
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
		if isList(pcWord) and stzListQ(pcWord).IsPatternNamedParam()
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
		if isList(pcWord) and stzListQ(pcWord).IsPatternNamedParam()
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
		if isList(pcWord) and stzListQ(pcWord).IsPatternNamedParam()
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
		if isList(pcWord) and stzListQ(pcWord).IsPatternNamedParam()
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

		cResult = ""

		switch @cDirection
		on "ahead"
			if @cType = "positive"
				cResult = "(?=" + @cPattern + ")"
			else
				cResult = "(?!" + @cPattern + ")"
			ok

		on "behind"
			if @cType = "positive"
				cResult = "(?<=" + @cPattern + ")"
			else
				cResult = "(?<!" + @cPattern + ")"
			ok
		off

		if @cMainPattern != ""
			cResult += @cMainPattern
		ok

		return cResult

	def Info()
		aResult = [
			:direction = @cDirection,
			:type = @cType,
			:lookPattern = @cPattern,
			:mainPattern = @cMainPattern,
			:pattern = This.Pattern()
		]

		return aResult
