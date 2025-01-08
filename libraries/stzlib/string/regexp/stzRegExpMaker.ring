
class stzRegExpMaker
	acFragments = []
	aSequences = []
  

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
        
		if cType = :among and type(cRange) = "LIST"
			cPattern = "[" + join(cRange) + "]"

		but cType = :among
			cPattern = "[" + substr(cRange, "SPACE", " ") + "]"
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

        	add(acFragments, cPattern + cQuantifier)

		# String the elements of the sequence applied

        	add(aSequences, [cType, cRange, cQuant, nTimes1, nTimes2])
        

	def AddAmongChars(cChars, cQuant, nTimes1, nTimes2)
		if isString(cChars)
			cChars = Chars(cChars)
		ok
        
		AddRange(:among, cChars, cQuant, nTimes1, nTimes2)
    
	def AddCharsRange(cRange, cQuant, nTimes1, nTimes2)
		AddRange(:chars, cRange, cQuant, nTimes1, nTimes2)
    
	def AddDigitsRange(cRange, cQuant, nTimes1, nTimes2)
		AddRange(:digits, cRange, cQuant, nTimes1, nTimes2)

	  #------------------------------------------------#
	 #  GETTING THE STRING PATTERN ANT ITS FRAGMENTS  #
	#------------------------------------------------#

	def Pattern()
		cResult = ""

		for cFrag in acFragments
			cResult += cFrag
		next

		return cResult
	
	def Fragments() #TODO //Move to stzRegExpAnalyser
		return acFragments

		def Frags()
			return This.Fragments()

	def NumberOfFragements() #TODO //Move to stzRegExpAnalyser
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

	def Fragment(n) #TODO //Move to stzRegExpAnalyser
		return acFragments[n]

		def Frag(n)

	def FragmentXT(n) #TODO //Move to stzRegExpAnalyser
		return [ acFragments[n], aSequences[n] ]

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

	  #-------------------------------------------------------------#
	 #  GETTING THE SEQUENCES (FRAGMENTS IN COMPUTABLE DATA FORM)  #
	#-------------------------------------------------------------#

	def Sequences() #TODO //Move to stzRegExpAnalyser
		return aSequences

		def Seqs()
			return This.Sequences()

	def NumberOfSequences() #TODO //Move to stzRegExpAnalyser
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

		#>

	def Sequence(n) #TODO //Move to stzRegExpAnalyser
		return aSequences[n]

		def Seq(n)

	def SequenceXT(n) #TODO //Move to stzRegExpAnalyser
		return [ acSequences[n], acFragments[n] ]

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

	  #---------------------------------------#
	 #  GENERATING AN EXPLANATIVE NARRATION  #
	#---------------------------------------#

	def Narration()

		nMaxLen = 0

		for cPattern in acFragments
			if len(cPattern) > nMaxLen
				nMaxLen = len(cPattern)
			ok
		next

		nMaxLen++ # Add 1 for spacing
    
		cResult = "START" + NL + "│" + NL
    		_nLenSeq_ = len(aSequences)

		for i = 1 to _nLenSeq_

			aSeq = aSequences[i]
			cPattern = acFragments[i]
			cSpaces = copy(" ", nMaxLen - len(cPattern))
        
			# Calculate sequence number (0-9 repeating)
			nSeqNum = i % 10
        
        		cBase = ""

		switch aSeq[1]
 		case :chars
			cBase = "a char from " + left(aSeq[2], 1) + " to " + right(aSeq[2], 1)

		case :digits
			cBase = "a digit from " + left(aSeq[2], 1) + " to " + right(aSeq[2], 1)

		case :among

			if type(aSeq[2]) = "LIST"

				# Now correctly showing the hyphen and space as separate characters

				aChars = []

				for char in aSeq[2]
					add(aChars, char)
				next

				cBase = 'a char among [ "' +
					joinUsing(aChars, '", "') + '" ]'

			else
				# Handle the case where it's a string with "SPACE"

					cChars = substr(aSeq[2], "SPACE", " ")
					aChars = []

					for i = 1 to len(cChars)
						add(aChars, substr(cChars, i, 1))
					next

					cBase = 'a char among [ "' +
						join(aChars + '", "') + '" ]'
			ok
		off
        
		cRepeat = ""

		switch aSeq[3]
		case :repeatedExactly
			cRepeat = "repeated exactly " + aSeq[4] + " times"

		case :repeatedAtLeast
			cRepeat = "repeated at least " + aSeq[4] + " times"

		case :repeatedAtMost
			cRepeat = "repeated at most " + aSeq[4] + " time"

		case :repeatedBetween
			cRepeat = "repeated between " + aSeq[4] + " and " + aSeq[5] + " times"

		case :repeatedSeveral
			cRepeat = "repeated zero or more times"

		off
        
		cResult += ''+ nSeqNum + "─▶ " + cPattern + cSpaces + ": Can contain " + cBase + "," + NL
		cResult += "│   " + copy(" ", nMaxLen+2) + cRepeat + "." + nl + "│" + nl
	next
    
	cResult += "END"
	return cResult
   
  
   	def Explain()
		return Narration()
