

	  #============================================================================#
	 #  CHECKING IF THE STRING CONTAINS A SUBSTRING BETWEEN TWO OTHER SUBSTRINGS  #
	#============================================================================#

	def ContainsSubStringBetweenCS(pcSubStr, pcSubStr1, pcSubStr2, pCaseSensitive)

		anPos = This.FindSubStringBetweenCS(pcSubStr, pcSubStr1, pcSubStr2, pCaseSensitive)

		if len(anPos) > 0
			return TRUE
		else
			return FALSE
		ok

		def ContainsBetweenCS(pcSubStr, pcSubStr1, pcSubStr2, pCaseSensitive)
			return This.ContainsSubStringBetweenCS(pcSubStr, pcSubStr1, pcSubStr2, pCaseSensitive)

	#-- WITHOUT CASESENSITIVITY

	def ContainsSubStringBetween(pcSubStr, pcSubStr1, pcSubStr2)
		return This.ContainsSubStringBetweenCS(pcSubStr, pcSubStr1, pcSubStr2, TRUE)

		def ContainsBetween(pcSubStr, pcSubStr1, pcSubStr2)
			return This.ContainsSubStringBetween(pcSubStr, pcSubStr1, pcSubStr2)

	  #------------------------------------------------------------------------------#
	 #  CHECKING IF THE STRING CONTAINS A SUBSTRING BOUNDED BY TWO OTHER SUBSTRINGS #
	#------------------------------------------------------------------------------#

	def ContainsSubStringBoundedByCS(pcSubStr, pacBounds, pCaseSensitive)

		# Checking params

		if CheckParams()
			if NOT (isString(pacBounds) or (isList(pacBounds) and Q(pacBounds).IsPairOfStrings()) )
				StzRaise("Incorrect params types! pacBounds must be a string or pair of strings.")
			ok
		ok

		# Doing the job

		cBound1 = ""
		cBound2 = ""

		if isString(pacBounds)
			cBound1 = pacBounds
			cBound2 = pacBounds

		else // Q(pacBounds).IsPairOfStrings()
			cBound1 = pacBounds[1]
			cBound2 = pacBounds[2]
		ok

		aSections = This.FindSubStringAsSectionsCS(pcSubStr, pCaseSensitive)

		nLen = len(aSections)
		nLenBound1 = Q(cBound1).NumberOfChars()
		nLenBound2 = Q(cBound2).NumberOfChars()

		# Looping over the sections and checking wether their bounds
		# correspond to cBound1 and cBound2

		bResult = FALSE

		cBound1 = cBound1
		cBound2 = cBound2

		if IsCaseSensitive(pCaseSensitive)
			cBound1 = Q(pBound1).Lowercased()
			cBound2 = Q(pBound2).Lowercased()
		ok

		for i = 1 to nLen
			
			acBounds = This.SectionBounds(aSections[1], aSections[2], nLenBound1, nLenBound2)

			if acBounds[1] = cBound1 and acBounds[2] = cBound2

				bResult = TRUE
				exit

			ok

		next

		return bResult

		#< @FunctionAlternativeForm

		def ContainsBoundedByCS(pcSubStr, pacBounds, pCaseSensitive)
			return This.ContainsSubStringBoundedByCS(pcSubStr, pacBounds, pCaseSensitive)

		#>

	#-- WITHOUT CASESENSITIVE

	def ContainsSubStringBoundedBy(pcSubStr, pacBounds)
		return This.ContainsSubStringBoundedByCS(pcSubStr, pacBounds, TRUE)

		#< @FunctionAlternativeForm

		def ContainsBoundedBy(pcSubStr, pacBounds)
			return This.ContainsSubStringBoundedBy(pcSubStr, pacBounds)

		#>

	   #-----------------------------------------------------------#
	  #  CHECKING IF THE STRING CONTAINS A SUBSTRING BETWEEN TWO  #
	 #  OTHER SUBSTRINGS STARTING AT A GIVEN POSITION            #
	#===========================================================#

	def ContainsSubStringBetweenSCS(pcSubStr, pcSubStr1, pcSubStr2, pnStartingAt, pCaseSensitive)
		nLen = This.NumberOfChars()
		bResult = This.SectionQ(pnStartingAt, nLen).ContainsSubStringBetweenCS(pcSubStr, pcSubStr1, pcSubStr2, pnStartingAt, pCaseSensitive)

		return bResult

	#-- WITHOUT CASESENSITIVITY

	def ContainsSubStringBetweenS(pcSubStr, pcSubStr1, pcSubStr2, pnStartingAt)
		return This.ContainsSubStringBetweenSCS(pcSubStr, pcSubStr1, pcSubStr2, pnStartingAt, :CaseSensitive) = TRUE

	   #--------------------------------------------------------------#
	  #  CHECKING IF THE STRING CONTAINS A SUBSTRING BOUNDED BY TWO  #
	 #  OTHER SUBSTRINGS STARTING AT A GIVEN POSITION               #
	#--------------------------------------------------------------#

	def ContainsSubStringBoundedBySCS(pcSubStr, pacBounds, pnStartingAt, pCaseSensitive)
		nLen = This.NumberOfChars()
		bResult = This.SectionQ(pnStartingAt, nLen).ContainsSubStringBoundedByCS(pcSubStr, pacbounds, pnStartingAt, pCaseSensitive)

		return bResult

	#-- WITHOUT CASESENSITIVITY

	def ContainsSubStringBoundedByS(pcSubStr, pacBounds, pnStartingAt)
		return This.ContainsSubStringBoundedBySCS(pcSubStr, pacBounds, pnStartingAt, :CaseSensitive) = TRUE

	  #---------------------------------------------------------------------------------#
	 #  GETTING THE NUMBER OF OCCURRENCES OF A SUBSTRING BETWEEN TWO OTHER SUBSTRINGS  #
	#=================================================================================#

	def NumberOfOccurrenceBetweenCS(pcSubStr, pcSubStr1, pcSubStr2, pCaseSensitive)
		nResult = len( This.FindSubStringBetweenCS(pcSubStr, pcSubStr1, pcSubStr2, pCaseSensitive) )
		return nResult

		#< @FunctionAlternativeForms

		def NumberOfOccurrenceOfSubStringBetweenCS(pcSubStr, pcSubStr1, pcSubStr2, pCaseSensitive)
			return This.NumberOfOccurrenceBetweenCS(pcSubStr, pcSubStr1, pcSubStr2, pCaseSensitive)

		#-- Occurrences (with s)
	
		def NumberOfOccurrencesBetweenCS(pcSubStr, pcSubStr1, pcSubStr2, pCaseSensitive)
			return This.NumberOfOccurrenceBetweenCS(pcSubStr, pcSubStr1, pcSubStr2, pCaseSensitive)

		def NumberOfOccurrencesOfSubStringBetweenCS(pcSubStr, pcSubStr1, pcSubStr2, pCaseSensitive)
			return This.NumberOfOccurrenceBetweenCS(pcSubStr, pcSubStr1, pcSubStr2, pCaseSensitive)

		#>

	#-- WITHOUT CASESENSITIVITY

	def NumberOfOccurrenceBetween(pcSubStr, pcBound1, pcBound2)
		return This.NumberOfOccurrenceBetweenCS(pcSubStr, pcSubStr1, pcSubStr2, TRUE)

		#< @FunctionAlternativeForms

		def NumberOfOccurrenceOfSubStringBetween(pcSubStr, pcSubStr1, pcSubStr2)
			return This.NumberOfOccurrenceBetween(pcSubStr, pcSubStr1, pcSubStr2)

		#-- Occurrences (with s)
	
		def NumberOfOccurrencesBetween(pcSubStr, pcSubStr1, pcSubStr2)
			return This.NumberOfOccurrenceBetween(pcSubStr, pcSubStr1, pcSubStr2)

		def NumberOfOccurrencesOfSubStringBetween(pcSubStr, pcSubStr1, pcSubStr2)
			return This.NumberOfOccurrenceBetween(pcSubStr, pcSubStr1, pcSubStr2)

		#>

	  #------------------------------------------------------------------------------------#
	 #  GETTING THE NUMBER OF OCCURRENCES OF A SUBSTRING BOUBDED BY TWO OTHER SUBSTRINGS  #
	#------------------------------------------------------------------------------------#

	def NumberOfOccurrenceBoundedByCS(pcSubStr, pacBounds, pCaseSensitive)
		nResult = len( This.FindSubStringBoundedByCS(pcSubStr, pacBounds, pCaseSensitive) )
		return nResult

		#< @FunctionAlternativeForms

		def NumberOfOccurrenceOfSubStringBoundedByCS(pcSubStr, pacBounds, pCaseSensitive)
			return This.NumberOfOccurrenceBoundedByCS(pcSubStr, BoundedBy, pCaseSensitive)

		#-- Occurrences (with s)
	
		def NumberOfOccurrencesBoundedByCS(pcSubStr, pacBounds, pCaseSensitive)
			return This.NumberOfOccurrenceBoundedByCS(pcSubStr, pacBounds, pCaseSensitive)

		def NumberOfOccurrencesOfSubStringBoundedByCS(pcSubStr, pacBounds, pCaseSensitive)
			return This.NumberOfOccurrenceBoundedByCS(pcSubStr, pacBounds, pCaseSensitive)

		#>

	#-- WITHOUT CASESENSITIVITY

	def NumberOfOccurrenceBoundedBy(pcSubStr, pacBounds)
		return This.NumberOfOccurrenceBoundedByCS(pcSubStr, pacBounds, TRUE)

		#< @FunctionAlternativeForms

		def NumberOfOccurrenceOfSubStringBoundedBy(pcSubStr, pacBounds)
			return This.NumberOfOccurrenceBoundedBy(pcSubStr, pacBounds)

		#-- Occurrences (with s)
	
		def NumberOfOccurrencesBoundedBy(pcSubStr, pacBounds)
			return This.NumberOfOccurrenceBoundedBy(pcSubStr, pacBounds)

		def NumberOfOccurrencesOfSubStringBoundedBy(pcSubStr, pacBounds)
			return This.NumberOfOccurrenceBoundedBy(pcSubStr, pacBounds)

		#>

	   #------------------------------------------------------------#
	  #  GETTING THE NUMBER OF OCCURRENCES OF A SUBSTRING BETWEEN  #
	 #  TWO OTHER SUBSTRINGS STARTING AT A GIVEN POSITION         #
	#============================================================#

	def NumberOfSubStringBetweenSCS(pcSubStr, pcSubStr1, pcSubStr2, pnStartingAt, pCaseSensitive)
		nResult = len( This.FindSubStringBetweenSCS(pcSubStr, pcSubStr1, pcSubStr2, pnStartingAt, pCaseSensitive) )
		return nResult

		#< @FunctionAlternativeForms

		def NumberOfOccurrenceBetweenSCS(pcSubStr, pcSubStr1, pcSubStr2, pnStartingAt, pCaseSensitive)
			return This.NumberOfSubStringBetweenSCS(pcSubStr, pcSubStr1, pcSubStr2, pnStartingAt, pCaseSensitive)

		def NumberOfOccurrenceOfSubStringBetweenSCS(pcSubStr, pcSubStr1, pcSubStr2, pnStartingAt, pCaseSensitive)
			return This.NumberOfSubStringBetweenSCS(pcSubStr, pcSubStr1, pcSubStr2, pnStartingAt, pCaseSensitive)
	
		#-- Occurrences (with s)
	
		def NumberOfOccurrencesBetweenSCS(pcSubStr, pcSubStr1, pcSubStr2, pnStartingAt, pCaseSensitive)
			return This.NumberOfSubStringBetweenSCS(pcSubStr, pcSubStr1, pcSubStr2, pnStartingAt, pCaseSensitive)

		def NumberOfOccurrencesOfSubStringBetweenSCS(pcSubStr, pcSubStr1, pcSubStr2, pnStartingAt, pCaseSensitive)
			return This.NumberOfSubStringBetweenSCS(pcSubStr, pcSubStr1, pcSubStr2, pnStartingAt, pCaseSensitive)

		#>

	#-- WITHOUT CASESENSITIVITY

	def NumberOfSubStringBetweenS(pcSubStr, pcSubStr1, pcSubStr2, pnStartingAt)
		return This.NumberOfSubStringBetweenSCS(pcSubStr, pcSubStr1, pcSubStr2, pnStartingAt, TRUE)

		#< @FunctionAlternativeForms

		def NumberOfOccurrenceOfSubStringBetweenS(pcSubStr, pcSubStr1, pcSubStr2, pnStartingAt)
			return This.NumberOfSubStringBetweenS(pcSubStr, pcSubStr1, pcSubStr2, pnStartingAt)
	
		#-- Occurrences (with s)
	
		def NumberOfOccurrencesBetweenS(pcSubStr, pcSubStr1, pcSubStr2, pnStartingAt)
			return This.NumberOfSubStringBetweenS(pcSubStr, pcSubStr1, pcSubStr2, pnStartingAt)

		def NumberOfOccurrencesOfSubStringBetweenS(pcSubStr, pcSubStr1, pcSubStr2, pnStartingAt)
			return This.NumberOfSubStringBetweenS(pcSubStr, pcSubStr1, pcSubStr2, pnStartingAt)

		#>

	   #---------------------------------------------------------------#
	  #  GETTING THE NUMBER OF OCCURRENCES OF A SUBSTRING BOUNDED BY  #
	 #  TWO OTHER SUBSTRINGS STARTING AT A GIVEN POSITION            #
	#---------------------------------------------------------------#

	def NumberOfSubStringBoundedBySCS(pcSubStr, pacBounds, pnStartingAt, pCaseSensitive)
		nResult = len( This.FindSubStringBoundedBySCS(pcSubStr, pacBounds, pnStartingAt, pCaseSensitive) )
		return nResult

		#< @FunctionAlternativeForms

		def NumberOfOccurrenceBoundedBySCS(pcSubStr, pacBounds, pnStartingAt, pCaseSensitive)
			return This.NumberOfSubStringBoundedBySCS(pcSubStr, pacBounds, pnStartingAt, pCaseSensitive)

		def NumberOfOccurrenceOfSubStringBoundedBySCS(pcSubStr, pacBounds, pnStartingAt, pCaseSensitive)
			return This.NumberOfSubStringBoundedBySCS(pcSubStr, pacBounds, pnStartingAt, pCaseSensitive)
	
		#-- Occurrences (with s)
	
		def NumberOfOccurrencesBoundedBySCS(pcSubStr,pacBounds, pnStartingAt, pCaseSensitive)
			return This.NumberOfSubStringBoundedBySCS(pcSubStr, pacBounds, pnStartingAt, pCaseSensitive)

		def NumberOfOccurrencesOfSubStringBoundedBySCS(pcSubStr, pacBounds, pnStartingAt, pCaseSensitive)
			return This.NumberOfSubStringBoundedBySCS(pcSubStr, pacBounds, pnStartingAt, pCaseSensitive)

		#>

	#-- WITHOUT CASESENSITIVITY

	def NumberOfSubStringBoundedByS(pcSubStr, pacBounds, pnStartingAt)
		return This.NumberOfSubStringBoundedBySCS(pcSubStr, pacBounds, pnStartingAt, TRUE)

		#< @FunctionAlternativeForms

		def NumberOfOccurrenceOfSubStringBoundedByS(pcSubStr, pacBounds, pnStartingAt)
			return This.NumberOfSubStringBoundedByS(pcSubStr, pcBound1, pcBound2, pnStartingAt)
	
		#-- Occurrences (with s)
	
		def NumberOfOccurrencesBoundedByS(pcSubStr, pacBounds, pnStartingAt)
			return This.NumberOfSubStringBoundedByS(pcSubStr, pacBounds, pnStartingAt)

		def NumberOfOccurrencesOfSubStringBoundedByS(pcSubStr, pacBounds, pnStartingAt)
			return This.NumberOfSubStringBoundedByS(pcSubStr, pacBounds, pnStartingAt)

		#>

	  #---------------------------------------------------------------------------------------#
	 #  CHECKING IF THE STRING CONTAINS N OCCURRENCES OF A SUBSTRING BETWEEN TWO SUBSTRINGS  #
	#=======================================================================================#

	def ContainsNOccurrencesOfSubStringBetweenCS(n, pcSubStr, pcSubStr, pcSubStr1, pcSubStr2, pCaseSensitive)
		bResult = ( This.NumberOfOccurrenceBetweenCS(pcSubStr, pcSubStr, pcSubStr1, pcSubStr1, pCaseSensitive) = n )
		return bResult

	#-- WITHOUT CASESENSITIVITY

	def ContainsNOccurrencesOfSubStringBetween(n, pcSubStr, pcSubStr, pcSubStr1, pcSubStr2)
		return This.ContainsNOccurrencesOfSubStringBetweenCS(n, pcSubStr, pcSubStr1, pcSubStr2, TRUE)

	  #------------------------------------------------------------------------------------------#
	 #  CHECKING IF THE STRING CONTAINS N OCCURRENCES OF A SUBSTRING BOUNDED BY TWO SUBSTRINGS  #
	#------------------------------------------------------------------------------------------#

	def ContainsNOccurrencesOfSubStringBoudnedByCS(n, pcSubStr, pacBounds, pCaseSensitive)
		bResult = ( This.NumberOfOccurrenceBoudnedByCS(pcSubStr, pacBounds, pCaseSensitive) = n )
		return bResult

	#-- WITHOUT CASESENSITIVITY

	def ContainsNOccurrencesOfSubStringBoudnedBy(n, pcSubstr, pacBounds)
		return This.ContainsNOccurrencesOfSubStringBoudnedByCS(n, pcSubStr, pacBounds, TRUE)

	   #-----------------------------------------------------------------------#
	  #  CHECKING IF THE STRING CONTAINS N OCCURRENCES OF A GIVEN SUBSTRING   #
	 #  BOUNDED BY TWO OTHER SUBSTRINGS STARTING AT A GIVEN POSITION         #
	#=======================================================================#

	def ContainsNOccurrencesOfSubStringBetweenSCS(n, pcSubStr, pcSubStr1, pcSubStr2, pnStartingAt, pCaseSensitive)
		bResult = ( This.NumberOfSubStringBetweenSCS(pcSubStr, pcSubStr1, pcSubStr2, pnStartingAt) = n )
		return bResult

	#-- WITHOUT CASESENSITIVITY

	def ContainsNOccurrencesOfSubStringBetweenS(n, pcSubStr, pcSubStr1, pcSubStr2, pnStartingAt)
		return This.ContainsNOccurrencesOfSubStringBetweenSCS(n, pcSubStr, pcSubStr1, pcSubStr2, pnStartingAt, TRUE)

	   #-----------------------------------------------------------------------#
	  #  CHECKING IF THE STRING CONTAINS N OCCURRENCES OF A GIVEN SUBSTRING   #
	 #  BETWEEN TWO OTHER SUBSTRINGS STARTING AT A GIVEN POSITION            #
	#-----------------------------------------------------------------------#

	def ContainsNOccurrencesOfSubStringBoundedSCS(n, pcSubStr, pacBounds, pnStartingAt, pCaseSensitive)
		bResult = ( This.NumberOfSubStringBoundedBySCS(pcSubStr, pacBounds, pnStartingAt) = n )
		return bResult

	#-- WITHOUT CASESENSITIVITY

	def ContainsNOccurrencesOfSubStringBoundedByS(n, pcSubStr, pacBounds, pnStartingAt)
		return This.ContainsNOccurrencesOfSubStringBoundedBySCS(n, pcSubStr, pacBounds, pnStartingAt, TRUE)

	  #===================================================================#
	 #  FINDING OCCURRENCES OF A SUBSTRING BETWEEN TWO OTHER SUBSTRINGS  #
	#===================================================================#

	def FindSubStringBetweenCS(pcSubStr, pcSubStr1, pcSubStr2, pCaseSensitive)

		/* EXAMPLE 1:

		o1 = new stzString("bla bla <<word>> bla bla <<noword>> bla <<word>>")
		? o1.FindSubStringBetweenCS("word", "<<", ">>", :CaseSensitive = FALSE)
		#--> [ 9, 41 ]

		EXAMPLE 2:

		o1 = new stzString("12*A*67*A*")
		? o1.FindSubStringBetween("A", "*", "*")
		#--> [4, 9]

		*/

		# Checking params

			# Actually, we don't need to do any checking here because each of the
			# three used params will be checked by the two called functions used
			# in the solution (TODO: Check they actually do).
	
		# Doing the job

		aSections = This.FindAnyBetweenAsSectionsCS(pcSubStr1, pcSubStr2, pCaseSensitive)
		anResult = This.FindInSections(pcsubStr, aSections)

		return anResult

		#< @FunctionAlternativeForms

		def FindSubStringBetweenCSZ(pcSubStr, pcBound1, pcBound2, pCaseSensitive)
			return This.FindSubStringBetweenCS(pcSubStr, pcBound1, pcBound2, pCaseSensitive)

		def SubStringBetweenCS(pcSubStr, pcBound1, pcBound2, pCaseSensitive)
			return This.FindSubStringBetweenCS(pcSubStr, pcBound1, pcBound2, pCaseSensitive)

		#>

	#-- WITHOUT CASESENSITIVITY

	def FindSubStringBetween(pcSubStr, pcSubStr1, pcSubStr2)
		return This.FindSubStringBetweenCS(pcSubStr, pcSubStr1, pcSubStr2, TRUE)

		#< @FunctionAlternativeForms

		def FindSubStringBetweenZ(pcSubStr, pcBound1, pcBound2)
			return This.FindSubStringBetween(pcSubStr, pcBound1, pcBound2)

		def SubStringBetween(pcSubStr, pcBound1, pcBound2)
			return This.FindSubStringBetween(pcSubStr, pcBound1, pcBound2)

		#>

	  #----------------------------------------------------------------------#
	 #  FINDING OCCURRENCES OF A SUBSTRING BOUNDED BY TWO OTHER SUBSTRINGS  #
	#----------------------------------------------------------------------#

	def FindSubStringBoundedByCS(pcSubStr, pacBounds, pCaseSensitive)

		# Checking params

		if CheckParams()
			if NOT isString(pcSubStr)
				StzRaise("Incorrect param type! pcSubStr must be a string.")
			ok
	
			if NOT ( isString(pacBounds) or (isList(pacBounds) and Q(pacBounds).IsPairOfStrings()) )
				StzRaise("Incorrect param type! pacBounds must be a string or pair of strings.")
			ok
	
		ok

		# Doing the job

		cBound1 = ""
		cBound2 = ""

		if isString(pacBounds)
			cBound1 = pacBounds
			cBound2 = pacBounds

		else // Q(pacBounds).IsPairOfSrrings()
			cBound1 = pacBounds[1]
			cBound2 = pacBounds[2]
		ok

		nLenBound1 = Q(cBound1).NumberOfChars()

		anPos = This.FindAllCS( cBound1 + pcSubStr + cBound2, pCaseSensitive )

		anResult = []

		if len(anPos) > 0
			anResult = QR(anPos, :stzListOfNumbers).AddedToEach(nLenBound1)
		ok

		return anResult

		#< @FunctionAlternativeForms
	
		def FindSubStringBoundedByCSZ(pcSubStr, pacBounds, pCaseSensitive)
			return This.FindSubStringBoundedByCS(pcSubStr, pacBound, pCaseSensitives)
	
		def SubstringBoundedByCS(pcSubStr, pacBounds, pCaseSensitive)
			return This.FindSubStringBoundedByCS(pcSubStr, pacBounds, pCaseSensitive)

		#>

	#-- WITHOUT CASESENSITIVE

	def FindSubstringBoundedBy(pcSubStr, pacBounds)
		return This.FindSubStringSubStringBoundedByCS(pcSubStr, pacBounds, TRUE)

		#< @FunctionAlternativeForms
	
		def FindSubStringBoundedByZ(pcSubStr, pacBounds)
			return This.FindSubStringBoundedBy(pcSubStr, pacBound)
	
		def SubstringBoundedBy(pcSubStr, pacBounds)
			return This.FindSubStringBoundedBy(pcSubStr, pacBounds)

		#>

	  #------------------------------------------------------------------------#
	 #  GETTING THE SUBSTRING AND ITS POSITIONS BETWEEN TWO GIVEN SUBSTRINGS  #
	#========================================================================#

	def SubStringBetweenCSZ(pcSubStr, pcSubStr1, pcSubStr2, pCaseSensitive)
		aResult = [ pcSubStr, This.FindSubStringBetweenCS(pcSubStr, pcSubStr1, pcSubStr2, pCaseSensitive) ]
		return aResult

	#-- WITHOUT CASESENSITIVITY

	def SubStringBetweenZ(pcSubStr, pcSubStr1, pcSubStr2)
		return This.SubStringBetweenCSZ(pcSubStr, pcSubStr1, pcSubSt2, TRUE)

	  #---------------------------------------------------------------------------#
	 #  GETTING THE SUBSTRING AND ITS POSITIONS BOUNDED BY TWO GIVEN SUBSTRINGS  #
	#---------------------------------------------------------------------------#

	def SubStringBoundedByCSZ(pcSubStr, pacBounds, pCaseSensitive)
		aResult = [ pcSubStr, This.FindSubStringBoundedByCS(pcSubStr, pacBounds, pCaseSensitive) ]
		return aResult

	#-- WITHOUT CASESENSITIVITY

	def SubStringBoundedByZ(pcSubStr, pacBounds)
		return This.SubStringBoundedByCSZ(pcSubStr, pacBounds, TRUE)

	  #------------------------------------------------------------------#
	 #  FINDING (AS SECTIONS) A SUBSTRING BETWEEN TWO OTHER SUBSTRINGS  #
	#==================================================================#

	def FindSubStringBetweenCSZZ(pcSubStr, pcSubStr1, pcSubStr2, pCaseSensitive)

		anPos = This.FindSubStringBetweenCS(pcSubStr, pcSubStr1, pcSubStr2, pCaseSensitive)
		nLenStr = Q(pcSubStr).NumberOfChars()
		nLenPos = len(anPos)

		aResult = []

		for i = 1 to nLenPos
			aResult + [ anPos[i], anPos[i] + nLenStr - 1 ]
		next

		return aResult

		#< @FunctionAlternativeForm
	
		def FindSubStringBetweenAsSectionsCS(pcSubStr, pcSubStr1, pcSubStr2, pCaseSensitive)
			return This.FindSubStringBetweenCSZZ(pcSubStr, pcBound1, pcBound2, pCaseSensitive)

		#>

	#-- WITHOUT CASESENSITIVITY

	def FindSubStringBetweenZZ(pcSubStr, pcSubStr1, pcSubStr2, pcBound2)
		return This.FindSubStringBetweenCSZZ(pcSubStr, pcSubStr1, pcSubStr2, TRUE)

		#< @FunctionAlternativeForm

		def FindSubStringBetweenAsSections(pcSubStr, pcSubStr1, pcSubStr2)
			return This.FindSubStringBetweenZZ(pcSubStr, pcSubStr1, pcSubStr2)

		#>

	  #---------------------------------------------------------------------#
	 #  FINDING (AS SECTIONS) A SUBSTRING BOUNDED BY TWO OTHER SUBSTRINGS  #
	#---------------------------------------------------------------------#

	def FindSubStringBoundedByCSZZ(pcSubStr, pacBounds, pCaseSensitive)

		anPos = This.FindSubStringBoundedByCS(pcSubStr, pacBounds, pCaseSensitive)
		nLenStr = Q(pcSubStr).NumberOfChars()
		nLenPos = len(anPos)

		aResult = []

		for i = 1 to nLenPos
			aResult + [ anPos[i], anPos[i] + nLenStr - 1 ]
		next

		return aResult

		#< @FunctionAlternativeForm
	
		def FindSubStringBoundedByAsSectionsCS(pcSubStr, pacBounds, pCaseSensitive)
			return This.FindSubStringBoundedByCSZZ(pcSubStr, pacBounds, pCaseSensitive)

		#>

	#-- WITHOUT CASESENSITIVITY

	def FindSubStringBoundedByZZ(pcSubStr, pacBounds)
		return This.FindSubStringBoundedByCSZZ(pcSubStr, pacBounds, TRUE)

		#< @FunctionAlternativeForm

		def FindSubStringBoundedByAsSections(pcSubStr, pacBounds)
			return This.FindSubStringBoundedByZZ(pcSubStr, pacBounds)

		#>

	  #-----------------------------------------------------------------------#
	 #  GETTING THE SUBSTRING AND ITS SECTIONS BETWEEN TWO GIVEN SUBSTRINGS  #
	#=======================================================================#

	def SubStringBetweenCSZZ(pcSubStr, pcSubStr1, pcSubSt2, pCaseSensitive)
		aResult = [ pcSubStr, This.FindSubStringBetweenCSZZ(pcSubStr, pcSubStr1, pcSubStr2, pCaseSensitive) ]
		return aResult

		#< @FunctionAlternativeForm

		def SubStringBetweenAsSectionsCS(pcSubStr, pcSubStr1, pcSubSt2, pCaseSensitive)
			return This.SubStringBetweenCSZZ(pcSubStr, pcSubStr1, pcSubSt2, pCaseSensitive)

		#>

	#-- WITHOUT CASESENSITIVITY

	def SubStringBetweenZZ(pcSubStr, pcSubStr1, pcSubSt2)
		return This.SubStringBetweenCSZZ(pcSubStr, pcSubStr1, pcSubSt2, TRUE)

		#< @FunctionAlternativeForm

		def SubStringBetweenAsSections(pcSubStr, pcSubStr1, pcSubSt2)
			return This.SubStringBetweenZZ(pcSubStr, pcSubStr1, pcSubSt2)

		#>

	  #--------------------------------------------------------------------------#
	 #  GETTING THE SUBSTRING AND ITS SECTIONS BOUNDED BY TWO GIVEN SUBSTRINGS  #
	#--------------------------------------------------------------------------#

	def SubStringBoundedByCSZZ(pcSubStr, pacBounds, pCaseSensitive)
		aResult = [ pcSubStr, This.FindSubStringBoundedByCSZZ(pcSubStr, pacBounds, pCaseSensitive) ]
		return aResult

		#< @FunctionAlternativeForm

		def SubStringBoundedByAsSectionsCS(pcSubStr, pacBounds, pCaseSensitive)
			return This.SubStringBoundedByCSZZ(pcSubStr, pacBounds, pCaseSensitive)

		#>

	#-- WITHOUT CASESENSITIVITY

	def SubStringBoundedByZZ(pcSubStr, pacBounds)
		return This.SubStringBoundedByCSZZ(pcSubStr, pacBounds, TRUE)

		#< @FunctionAlternativeForm

		def SubStringBoundedByAsSections(pcSubStr, pacBounds)
			return This.SubStringBoundedByZZ(pcSubStr, pacBounds)

		#>

	  #---------------------------------------------------------------------#
	 #  FINDING A SUBSTRING BETWEEN TWO OTHER SUBSTRINGS INCLUDING BOUNDS  #
	#=====================================================================#

	def FindSubStringBetweenCSIB(pcSubStr, pcSubStr1, pcSubStr2, pCaseSensitive)
		anPos = This.FindSubStringBetweenCS(pcSubStr, pcSubStr1, pcSubStr2, pCaseSensitive)
		nLen = len(anPos)

		nLenSubStr1 = Q(pcSubStr1).NumberOfChars()

		anResult = []
		for i = 1 to nLen
			anResult = anPos[i] - nLenBound1
		next

		return anResult

		#< @FunctionAlternativeForms

		def FindSubStringBetweenCSIBZ(pcSubStr, pcSubStr1, pcSubStr2, pCaseSensitive)
			return This.FindSubStringBetweenCSIB(pcSubStr, pcSubStr1, pcSubStr2, pCaseSensitive)

		def SubStringBetweenCSIB(pcSubStr, pcSubStr1, pcSubStr2, pCaseSensitive)
			return This.FindSubStringBetweenCSIB(pcSubStr, pcSubStr1, pcSubStr2, pCaseSensitive)
	
		#>

	#-- WITHOUT CASESENSITIVE

	def FindSubStringBetweenIB(pcSubStr, pcSubStr1, pcSubStr2)
		return This.FindSubStringBetweenCSIB(pcSubStr, pcSubStr1, pcSubStr2, TRUE)

		#< @FunctionAlternativeForms

		def FindSubStringBetweenIBZ(pcSubStr, pcSubStr1, pcSubStr2)
			return This.FindSubStringBetweenIB(pcSubStr, pcSubStr1, pcSubStr2)

		def SubStringBetweenIB(pcSubStr, pcSubStr1, pcSubStr2)
			return This.FindSubStringBetweenIB(pcSubStr, pcSubStr1, pcSubStr2)
	
		#>

	  #------------------------------------------------------------------------#
	 #  FINDING A SUBSTRING BOUNDED BY TWO OTHER SUBSTRINGS INCLUDING BOUNDS  #
	#------------------------------------------------------------------------#

	def FindSubStringBoundedByCSIB(pcSubStr, pacBounds, pCaseSensitive)
		anPos = This.FindSubStringBoundedByCS(pcSubStr, pacBounds, pCaseSensitive)
		nLen = len(anPos)

		nLenBound1 = Q(pcBound1).NumberOfChars()

		anResult = []
		for i = 1 to nLen
			anResult = anPos[i] - nLenBound1
		next

		return anResult

		#< @FunctionAlternativeForms

		def FindSubStringBoundedByCSIBZ(pcSubStr, pacBounds, pCaseSensitive)
			return This.FindSubStringBoundedByCSIB(pcSubStr, pacBounds, pCaseSensitive)

		def SubStringBoundedByCSIB(pcSubStr, pacBounds, pCaseSensitive)
			return This.FindSubStringBoundedByCSIB(pcSubStr, pacBounds, pCaseSensitive)
	
		#>

	#-- WITHOUT CASESENSITIVE

	def FindSubStringBoundedByIB(pcSubStr, pacBounds)
		return This.FindSubStringBoundedByCSIB(pcSubStr, pacBounds, TRUE)

		#< @FunctionAlternativeForms

		def FindSubStringBoundedByIBZ(pcSubStr, pacBounds)
			return This.FindSubStringBoundedByIB(pcSubStr, pacBounds)

		def SubStringBoundedByIB(pcSubStr, pacBounds)
			return This.FindSubStringBoundedByIB(pcSubStr, pacBounds)
	
		#>

	  #-------------------------------------------------------------------------------------------#
	 #  GETTING THE SUBSTRING (AND ITS POSITIONS) BETWEEN TWO GIVEN SUBSTRINGS INCLUDING BOUNDS  #
	#===========================================================================================#

	def SubStringBetweenCSIBZ(pcSubStr, pcSubStr1, pcSubStr2, pCaseSensitive)
		aResult = [ pcSubStr, This.FindSubStringBetweenCSIBZ(pcSubStr, pcSubStr1, pcSubStr2, pCaseSensitive) ]
		return aResult

	#-- WITHOUT CASESENSITIVITY

	def SubStringBetweenIBZ(pcSubStr, pcSubStr1, pcSubStr2)
		return This.SubStringBetweenCSIBZ(pcSubStr, pcSubStr1, pcSubStr2, TRUE)

	  #----------------------------------------------------------------------------------------------#
	 #  GETTING THE SUBSTRING (AND ITS POSITIONS) BOUNDED BY TWO GIVEN SUBSTRINGS INCLUDING BOUNDS  #
	#----------------------------------------------------------------------------------------------#

	def SubStringBoundedByCSIBZ(pcSubStr, pacBounds, pCaseSensitive)
		aResult = [ pcSubStr, This.FindSubStringBoundedByCSIBZ(pcSubStr, pacBounds, pCaseSensitive) ]
		return aResult

	#-- WITHOUT CASESENSITIVITY

	def SubStringBoundedByIBZ(pcSubStr, pacBounds)
		return This.SubStringBoundedByCSIBZ(pcSubStr, pacBounds, TRUE)

	  #----------------------------------------------------------------------------------#
	 #  FINDING A SUBSTRING (AS SECTIONS) BETWEEN TWO OTHER SUBSTRINGS INCLUDING BOUNDS #
	#==================================================================================#

	def FindSubStringBetweenCSIBZZ(pcSubStr, pcSubStr1, pcSubStr2, pCaseSensitive)
		aSections = This.FindSubStringBetweenCSZZ(pcSubStr, pcSubStr1, pcSubStr2, pCaseSensitive)
		nLen = len(aSections)
		nLenSubStr1 = Q(pcSubStr1).NumberOfChars()
		nLenSubStr2 = Q(pcSubStr2).NumberOfChars()

		aResult = []

		for i = 1 to nLen
			n1 = aSections[i][1] - nLenSubStr1 + 1
			n2 = aSections[i][2] + nLenSubStr2
			aResult + [ n1, n2 ]
		next

		return aResult

		#< @FunctionAlternativeForm
	
		def FindSubStringBetweenAsSectionsCSIB(pcSubStr, pcSubStr1, pcSubStr2, pCaseSensitive)
			return This.FindSubStringBetweenCSIBZZ(pcSubStr, pcSubStr1, pcSubStr2, pCaseSensitive)

		#>

	#-- WITHOUT CASESENSITIVITY

	def FindSubStringBetweenIBZZ(pcSubStr, pcSubStr1, pcSubStr2)
		return This.FindSubStringBetweenCSIBZZ(pcSubStr, pcSubStr1, pcSubStr2, TRUE)

		#< @FunctionAlternativeForms

		def FindSubStringBetweenAsSectionsIB(pcSubStr, pcSubStr1, pcSubStr2)
			return This.FindSubStringBetweenIBZZ(pcSubStr, pcSubStr1, pcSubStr2)

		#>

	  #-------------------------------------------------------------------------------------#
	 #  FINDING A SUBSTRING (AS SECTIONS) BOUNDED BY TWO OTHER SUBSTRINGS INCLUDING BOUNDS #
	#-------------------------------------------------------------------------------------#

	def FindSubStringBoundedByCSIBZZ(pcSubStr, pacBounds, pCaseSensitive)
		aSections = This.FindSubStringBoundedByCSZZ(pcSubStr, pacBounds, pCaseSensitive)
		nLen = len(aSections)

		cBound1 = ""
		cBound2 = ""

		if isString(pacBounds)
			cBound1 = pacBounds
			cBound2 = pacBounds

		else // Q(pacBounds).IsPairOfStrings()
			cBound1 = pacBounds[1]
			cBound2 = pacBounds[2]
		ok

		nLenBound1 = Q(cBound1).NumberOfChars()
		nLenBound2 = Q(cBound2).NumberOfChars()

		aResult = []

		for i = 1 to nLen
			n1 = aSections[i][1] - nLenBound1 + 1
			n2 = aSections[i][2]  + nLenBound2
			aResult + [ n1, n2 ]
		next

		return aResult

		#< @FunctionAlternativeForm
	
		def FindSubStringBoundedByAsSectionsCSIB(pcSubStr, pacBounds, pCaseSensitive)
			return This.FindSubStringBoundedByCSIBZZ(pcSubStr, pacBounds, pCaseSensitive)

		#>

	#-- WITHOUT CASESENSITIVITY

	def FindSubStringBoundedByIBZZ(pcSubStr, pacBounds)
		return This.FindSubStringBouondedByCSIBZZ(pcSubStr, pacBounds, TRUE)

		#< @FunctionAlternativeForms

		def FindSubStringBooundedByAsSectionsIB(pcSubStr, pacBounds)
			return This.FindSubStringBoundedByIBZZ(pcSubStr, pacBounds)

		#>

	  #----------------------------------------------------------------------------------------#
	 #  GETTING THE SUBSTRING AND ITS SECTIONS BETWEEN TWO GIVEN SUBSTRINGS INCLUDING BOUNDS  #
	#========================================================================================#

	def SubStringBetweenCSIBZZ(pcSubStr, pcSubStr1, pcsubStr2, pCaseSensitive)
		aResult = [ pcSubStr, This.FindSubStringBetweenCSIBZZ(pcSubStr, pcSubStr1, pcSubStr2, pCaseSensitive) ]
		return aResult

		#< @FunctionAlternativeForm

		def SubStringBetweenAsSectionsCSIB(pcSubStr, pcSubStr1, pcsubStr2, pCaseSensitive)
			return This.SubStringBetweenCSIBZZ(pcSubStr, pcSubStr1, pcsubStr2, pCaseSensitive)

		#>

	#-- WITHOUT CASESENSITIVITY

	def SubStringBetweenIBZZ(pcSubStr, pcSubStr1, pcsubStr2, pcBound2)
		return This.SubStringBetweenCSIBZZ(pcSubStr, pcSubStr1, pcsubStr2, TRUE)

		#< @FunctionAlternativeForm

		def SubStringBetweenAsSectionsIB(pcSubStr, pcSubStr1, pcsubStr2)
			return This.SubStringBetweenIBZZ(pcSubStr, pcSubStr1, pcsubStr2)

		#>

	  #-------------------------------------------------------------------------------------------#
	 #  GETTING THE SUBSTRING AND ITS SECTIONS BOUNDED BY TWO GIVEN SUBSTRINGS INCLUDING BOUNDS  #
	#-------------------------------------------------------------------------------------------#

	def SubStringBoundedByCSIBZZ(pcSubStr, pacBounds, pCaseSensitive)
		aResult = [ pcSubStr, This.FindSubStringBoundedByCSIBZZ(pcSubStr, pacBounds, pCaseSensitive) ]
		return aResult

		#< @FunctionAlternativeForm

		def SubStringBoundedByAsSectionsCSIB(pcSubStr, pacBounds, pCaseSensitive)
			return This.SubStringBoundedByCSIBZZ(pcSubStr, pacBounds, pCaseSensitive)

		#>

	#-- WITHOUT CASESENSITIVITY

	def SubStringBoundedByIBZZ(pcSubStr, pacBounds, pcBound2)
		return This.SubStringBoundedByCSIBZZ(pcSubStr, pacBounds, TRUE)

		#< @FunctionAlternativeForm

		def SubStringBoundedByAsSectionsIB(pcSubStr, pacBounds)
			return This.SubStringBoundedByIBZZ(pcSubStr, pacBounds)

		#>

	  #---------------------------------------------------------------------------------#
	 #  FINDING A SUBSTRING BETWEEN TWO OTHER SUBSTRINGS STARTING AT A GIVEN POSITION  #
	#=================================================================================#

	def FindSubStringBetweenSCS(pcSubStr, pcSubStr1, pcSubStr2, pnStartingAt, pCaseSensitive)

		nLast = This.NumberOfChars()
		anPos = This.SectionQ(pnStartingAt, nLast).FindSubStringBetweenCS(pcSubStr, pcSubStr1, pcSubStr2, pCaseSensitive)
		nLen = len(anPos)

		anResult = []

		for i = 1 to nLen
			anResult + ( anPos[i] + pnStartingAt - 1 )
		next

		return anResult

		#< @FunctionalternativeForms
	
		def FindSubStringBetweenSCSZ(pcSubStr, pcSubStr1, pcSubStr2, pnStartingAt, pCaseSensitive)
			return This.FindSubStringBetweenSCS(pcSubStr, pcSubStr1, pcSubStr2, pnStartingAt, pCaseSensitive)

		def SubStringBetweenSCS(pcSubStr, pcSubStr1, pcSubStr2, pnStartingAt, pCaseSensitive)
			return This.FindSubStringBetweenSCS(pcSubStr, pcBound1, pcBound2, pnStartingAt, pCaseSensitive)

		#>

	#-- WITHOUT CASESENSITIVITY

	def FindSubStringBetweenS(pcSubStr, pcSubStr1, pcSubStr2, pnStartingAt)
		return This.FindSubStringBetweenSCS(pcSubStr, pcSubStr1, pcSubStr2, pnStartingAt, TRUE)

		#< @FunctionAlternativeForms
	
		def FindSubStringBetweenSZ(pcSubStr, pcSubStr1, pcSubStr2, pnStartingAt)
			return This.FindSubStringBetweenS(pcSubStr, pcSubStr1, pcSubStr2, pnStartingAt)

		def SubStringBetweenS(pcSubStr, pcSubStr1, pcSubStr2, pnStartingAt)
			return This.FindBetweenS(pcSubStr, pcSubStr1, pcSubStr2, pnStartingAt)

		#>

	  #-----------------------------------------------------------------------------------------------------#
	 #  GETTING THE SUBSTRING AND ITS POSITIONS BETWEEN TWO GIVEN SUBSTRINGS STARTING AT A GIVEN POSITION  #
	#=====================================================================================================#

	def SubStringBetweenSCSZ(pcSubStr, pcSubStr1, pcSubStr2, pnStartingAt, pCaseSensitive)
		aResult = [ pcSubStr, This.FindSubStringBetweenSCSZ(pcSubStr, pcSubStr1, pcSubStr2, pCaseSensitive) ]
		return aResult
		
	#-- WITHOUT CASESENSITIVITY

	def SubStringBetweenSZ(pcSubStr, pcSubStr1, pcSubStr2, pnStartingAt)
		aResult = [ pcSubStr, This.FindSubStringBetweenSZ(pcSubStr, pcSubStr1, pcSubStr2) ]
		return aResult

	  #--------------------------------------------------------------------------------------------------------#
	 #  GETTING THE SUBSTRING AND ITS POSITIONS BOUNDED BY TWO GIVEN SUBSTRINGS STARTING AT A GIVEN POSITION  #
	#--------------------------------------------------------------------------------------------------------#

	def SubStringBoundedBySCSZ(pcSubStr, pacBounds, pnStartingAt, pCaseSensitive)
		aResult = [ pcSubStr, This.FindSubStringBoundedBySCSZ(pcSubStr, pacBounds, pCaseSensitive) ]
		return aResult
		
	#-- WITHOUT CASESENSITIVITY

	def SubStringBoundedBySZ(pcSubStr, pacBounds, pnStartingAt)
		aResult = [ pcSubStr, This.FindSubStringBoundedBySZ(pcSubStr, pacBounds) ]
		return aResult

	  #-----------------------------------------------------------------------------------------------#
	 #  FINDING A SUBSTRING (AS SECTIONS) BETWEEN TWO OTHER SUBSTRINGS STARTING AT A GIVEN POSITION  #
	#===============================================================================================#

	def FindSubStringBetweenSCSZZ(pcSubStr, pcSubStr1, pSubStr2, pnStartingAt, pCaseSensitive)

		anPos = This.FindSubStringBetweenSCS(pcSubStr, pcSubStr1, pSubStr2, pnStartingAt, pCaseSensitive)
		nLen = len(anPos)
		nLenStr = Q(pcSubStr).NumberOfChars()

		aResult = []

		for i = 1 to nLen
			aResult + [ anPos[i], (anPos[i] + nLenStr - 1) ]
		next

		return aResult

		#< @FunctionAlternativeForms

		def FindSubStringBetweenAsSectionsSCS(pcSubStr, pcSubStr1, pSubStr2, pnStartingAt, pCaseSensitive)
			return This.FindSubStringBetweenSCSZZ(pcSubStr, pcSubStr1, pSubStr2, pnStartingAt, pCaseSensitive)

		def SubStringBetweenAsSectionsSCS(pcSubStr, pcSubStr1, pSubStr2, pnStartingAt, pCaseSensitive)
			return This.FindSubStringBetweenSCSZZ(pcSubStr, pcSubStr1, pSubStr2, pnStartingAt, pCaseSensitive)

		#>

	#-- WITHOUT CASESENSITIVITY

	def FindSubStringBetweenSZZ(pcSubStr, pcSubStr1, pSubStr2, pnStartingAt)
		return This.FindSubStringBetweenSCSZZ(pcSubStr, pcSubStr1, pSubStr2, pnStartingAt, TRUE)

		#< @FunctionAlternativeForms

		def FindSubStringBetweenAsSectionsS(pcSubStr, pcSubStr1, pSubStr2, pnStartingAt)
			return This.FindSubStringBetweenSZZ(pcSubStr, pcSubStr1, pSubStr2, pnStartingAt)

		def SubStringBetweenAsSectionsS(pcSubStr, pcSubStr1, pSubStr2, pnStartingAt)
			return This.FindSubStringBetweenSZZ(pcSubStr, pcSubStr1, pSubStr2, pnStartingAt)

		#>

	  #--------------------------------------------------------------------------------------------------#
	 #  FINDING A SUBSTRING (AS SECTIONS) BOUNDED BY TWO OTHER SUBSTRINGS STARTING AT A GIVEN POSITION  #
	#==================================================================================================#

	def FindSubStringBoundedBySCSZZ(pcSubStr, pacBounds, pnStartingAt, pCaseSensitive)

		anPos = This.FindSubStringBoundedBySCS(pcSubStr, pacBounds, pnStartingAt, pCaseSensitive)
		nLen = len(anPos)
		nLenStr = Q(pcSubStr).NumberOfChars()

		aResult = []

		for i = 1 to nLen
			aResult + [ anPos[i], (anPos[i] + nLenStr - 1) ]
		next

		return aResult

		#< @FunctionAlternativeForms

		def FindSubStringBoundedByAsSectionsSCS(pcSubStr, pacBounds, pnStartingAt, pCaseSensitive)
			return This.FindSubStringBoundedBySCSZZ(pcSubStr, pacBounded, pnStartingAt, pCaseSensitive)

		def SubStringBoundedByAsSectionsSCS(pcSubStr, pacBounds, pnStartingAt, pCaseSensitive)
			return This.FindSubStringBetweenSCSZZ(pcSubStr, pcSubStr1, pSubStr2, pnStartingAt, pCaseSensitive)

		#>

	#-- WITHOUT CASESENSITIVITY

	def FindSubStringBoundedBySZZ(pcSubStr, pacBounds, pnStartingAt)
		return This.FindSubStringBoundedBySCSZZ(pcSubStr, pacBounds, pnStartingAt, TRUE)

		#< @FunctionAlternativeForms

		def FindSubStringBoundedByAsSectionsS(pcSubStr, pacBounds, pnStartingAt)
			return This.FindSubStringBoundedBySZZ(pcSubStr, pacBounds, pnStartingAt)

		def SubStringBoundedByAsSectionsS(pcSubStr, pacBounds, pnStartingAt)
			return This.FindSubStringBoundedBySZZ(pcSubStr, pacBounds, pnStartingAt)

		#>

	  #----------------------------------------------------------------------------------------------------#
	 #  GETTING THE SUBSTRING AND ITS SECTIONS BETWEEN TWO GIVEN SUBSTRINGS STARTING AT A GIVEN POSITION  #
	#====================================================================================================#

	def SubStringBetweenSCSZZ(pcSubStr, pSubStr1, pcSubStr2, pnStartingAt, pCaseSensitive)
		aResult = [ pcSubStr, This.FindSubStringBetweenSCSZZ(pcSubStr, pSubStr1, pcSubStr2, pCaseSensitive) ]
		return aResult
		
		#< @FunctionAlternativeForm

		def SubStringBetweenAsSections_SCS(pcSubStr, pSubStr1, pcSubStr2, pnStartingAt, pCaseSensitive)
			return This.SubStringBetweenSCSZZ(pcSubStr, pSubStr1, pcSubStr2, pnStartingAt, pCaseSensitive)

		#>

	#-- WITHOUT CASESENSITIVITY

	def SubStringBetweenSZZ(pcSubStr, pSubStr1, pcSubStr2, pnStartingAt)
		return This.SubStringBetweenSCSZZ(pcSubStr, pSubStr1, pcSubStr2, pnStartingAt, TRUE)

		#< @FunctionAlternativeForm

		def SubStringBetweenAsSections_S(pcSubStr, pSubStr1, pcSubStr2, pnStartingAt)
			return This.SubStringBetweenSZZ(pcSubStr, pSubStr1, pcSubStr2, pnStartingAt)

		#>

	  #---------------------------------------------------------------------------------------------------------#
	 #  GETTING THE SUBSTRING AND ITS SECTIONS BOUNDEDED BY TWO GIVEN SUBSTRINGS STARTING AT A GIVEN POSITION  #
	#---------------------------------------------------------------------------------------------------------#

	def SubStringBoundedBySCSZZ(pcSubStr, pacBounds, pnStartingAt, pCaseSensitive)
		aResult = [ pcSubStr, This.FindSubStringBoundedBySCSZZ(pcSubStr, pacBounds, pCaseSensitive) ]
		return aResult
		
		#< @FunctionAlternativeForm

		def SubStringBoundedByAsSections_SCS(pcSubStr, pacBounds, pnStartingAt, pCaseSensitive)
			return This.SubStringBoundedBySCSZZ(pcSubStr, pacBounds, pnStartingAt, pCaseSensitive)

		#>

	#-- WITHOUT CASESENSITIVITY

	def SubStringBoundedBySZZ(pcSubStr, pacBounds, pnStartingAt)
		return This.SubStringBoundedBySCSZZ(pcSubStr, pacBounds, pnStartingAt, TRUE)

		#< @FunctionAlternativeForm

		def SubStringBoundedByAsSections_S(pcSubStr, pacBounds, pnStartingAt)
			return This.SubStringBoundedBySZZ(pcSubStr, pacBounds, pnStartingAt)

		#>

	  #-----------------------------------------------------------------------------------------------------#
	 #  FINDING A SUBSTRING BETWEEN TWO OTHER SUBSTRING STARTING AT A GIVEN POSITION AND INCLUDING BOUNDS  #
	#=====================================================================================================#

	def FindSubStringBetweenSCSIB(pcSubStr, pSubStr1, pcSubStr2, pnStartingAt, pCaseSensitive)
		anPos = This.FindSubStringBetweenSCS(pcSubStr, pSubStr1, pcSubStr2, pnStartingAt, pCaseSensitive)
		nLen = len(anPos)
		nLenStr = Q(pcSubStr).NumberOfChars()

		anResult = []

		for i = 1 to nLen
			anResult + ( anPos[i] - nLenStr + 1 )
		next

		return anResult

		#< @FunctionAlternativeForms
	
		def FindSubStringBetweenSCSIBZ(pcSubStr, pSubStr1, pcSubStr2, pnStartingAt, pCaseSensitive)
			return This.FindSubStringBetweenSCSIB(pcSubStr, pSubStr1, pcSubStr2, pnStartingAt, pCaseSensitive)

		def SubStringBetweenSCSIB(pcSubStr, pSubStr1, pcSubStr2, pnStartingAt, pCaseSensitive)
			return This.FindSubStringBetweenSCSIB(pcSubStr, pSubStr1, pcSubStr2, pnStartingAt, pCaseSensitive)

		#>

	#-- WITHOUT CASESENSITIVITY

	def FindSubStringBetweenSIB(pcSubStr, pSubStr1, pcSubStr2, pnStartingAt)
		return This.FindSubStringBetweenSCSIB(pcSubStr, pSubStr1, pcSubStr2, pnStartingAt, TRUE)

		#< @FunctionAlternativeForms
	
		def FindSubStringBetweenSIBZ(pcSubStr, pSubStr1, pcSubStr2, pnStartingAt)
			return This.FindSubStringBoundedBySIB(pcSubStr, pSubStr1, pcSubStr2, pnStartingAt)

		def SubStringBetweenSIB(pcSubStr, pSubStr1, pcSubStr2, pnStartingAt)
			return This.FindSubStringBetweenSIB(pcSubStr, pSubStr1, pcSubStr2, pnStartingAt)

		#>

	  #--------------------------------------------------------------------------------------------------------#
	 #  FINDING A SUBSTRING BOUNDED BY TWO OTHER SUBSTRING STARTING AT A GIVEN POSITION AND INCLUDING BOUNDS  #
	#--------------------------------------------------------------------------------------------------------#

	def FindSubStringBoundedBySCSIB(pcSubStr, pacBounds, pnStartingAt, pCaseSensitive)
		anPos = This.FindSubStringBoundedBySCS(pcSubStr, pacBounds, pnStartingAt, pCaseSensitive)
		nLen = len(anPos)
		nLenStr = Q(pcSubStr).NumberOfChars()

		anResult = []

		for i = 1 to nLen
			anResult + ( anPos[i] - nLenStr + 1 )
		next

		return anResult

		#< @FunctionAlternativeForms
	
		def FindSubStringBoundedBySCSIBZ(pcSubStr, pacBounds, pnStartingAt, pCaseSensitive)
			return This.FindSubStringBoundedBySCSIB(pcSubStr, pacBounds, pnStartingAt, pCaseSensitive)

		def SubStringBoundedBySCSIB(pcSubStr, pacBounds, pnStartingAt, pCaseSensitive)
			return This.FindSubStringBoundedBySCSIB(pcSubStr, pacBounds, pnStartingAt, pCaseSensitive)

		#>

	#-- WITHOUT CASESENSITIVITY

	def FindSubStringBoundedBySIB(pcSubStr, pacBounds, pnStartingAt)
		return This.FindSubStringBoundedBySCSIB(pcSubStr, pacBounds, pnStartingAt, TRUE)

		#< @FunctionAlternativeForms
	
		def FindSubStringBoundedBySIBZ(pcSubStr, pacBounds, pnStartingAt)
			return This.FindSubStringBoundedBySIB(pcSubStr, pacBounds, pnStartingAt)

		def SubStringBoundedBySIB(pcSubStr, pacBounds, pnStartingAt)
			return This.FindSubStringBoundedBySIB(pcSubStr, pacBounds, pnStartingAt)

		#>

	  #---------------------------------------------------------------------------------------------------------------------------#
	 #  GETTING THE SUBSTRING AND ITS PSOTITIONS BETWEEN TWO GIVEN SUBSTRINGS STARTING AT A GIVEN POSITION AND INCLUDING BOUNDS  #
	#===========================================================================================================================#

	def SubStringBetweenSCSIBZ(pcSubStr, pcSubStr1, pcsubStr2, pnStartingAt, pCaseSensitive)
		aResult = [ pcSubStr, This.FindSubStringBetweenSCSZ(pcSubStr, pcsubStr1, pcSubStr2, pCaseSensitive) ]
		return aResult

	#-- WITHOUT CASESENSITIVITY

	def SubStringBetweenSIBZ(pcSubStr, pcSubStr1, pcsubStr2, pnStartingAt)
		return This.SubStringBetweenSCSIBZ(pcSubStr, pcSubStr1, pcsubStr2, pnStartingAt, TRUE)

	  #------------------------------------------------------------------------------------------------------------------------------#
	 #  GETTING THE SUBSTRING AND ITS PSOTITIONS BOUNDED BY TWO GIVEN SUBSTRINGS STARTING AT A GIVEN POSITION AND INCLUDING BOUNDS  #
	#------------------------------------------------------------------------------------------------------------------------------#

	def SubStringBoundedBySCSIBZ(pcSubStr, pacBunds, pnStartingAt, pCaseSensitive)
		aResult = [ pcSubStr, This.FindSubStringBoundedBySCSZ(pcSubStr, pacBounds, pCaseSensitive) ]
		return aResult

	#-- WITHOUT CASESENSITIVITY

	def SubStringBoundedBySIBZ(pcSubStr, pacBounds, pnStartingAt)
		return This.SubStringBoundedBySCSIBZ(pcSubStr, pacBounds, pnStartingAt, TRUE)

	  #----------------------------------------------------------------------------------------------------------------#
	 #  FINDING A SUBSTRING (AS SECTIONS) BETWEEN TWO OTHER SUBSTRINGS STARTING AT A GIVEN POSITION INCLUDING BOUNDS  #
	#=================================================================================================================#

	def FindSubStringBetweenSCSIBZZ(pcSubStr, pcSubStr1, pcSubStr2, pnStartingAt, pCaseSensitive)
		aSections = This.FindSubStringBetweenSCSZZ(pcSubStr, pcSubStr1, pcSubStr2, pnStartingAt, pCaseSensitive)
		nLen = len(aSections)
		nLenSubStr1 = Q(pcSubStr1).NumberOfChars()
		nLenSubStr2 = Q(pcSubStr2).NumberOfChars()

		aResult = []

		for i = 1 to nLen
			n1 = aSections[i][1] - nLenSubStr1 + 1
			n2 = aSections[i][2] + nLenSubStr2
			aResult + [ n1, n2 ]
		next

		return aResult

		#< @FunctionAlternativeForms
	
		def FindSubStringBetweenAsSectionsSCSIB(pcSubStr, pcSubStr1, pcSubStr2, pnStartingAt, pCaseSensitive)
			return This.FindSubStringBetweenSCSIBZZ(pcSubStr, pcSubStr1, pcSubStr2, pnStartingAt, pCaseSensitive)

		def SubStringBetweenAsSectionsSCSIB(pcSubStr, pcSubStr1, pcSubStr2, pnStartingAt, pCaseSensitive)
			return This.FindSubStringBetweenSIBCSZZ(pcSubStr, pcSubStr1, pcSubStr2, pnStartingAt, pCaseSensitive)

		#>

	#-- WITHOUT CASESENSITIVITY

	def FindSubStringBetweenSIBZZ(pcSubStr, pcSubStr1, pcSubStr2, pnStartingAt)
		return This.FindSubStringBetweenSCSIBZZ(pcSubStr, pcSubStr1, pcSubStr2, pnStartingAt, TRUE)

		#< @FunctionAlternativeForms
	
		def FindSubStringBetweenAsSectionsSIB(pcSubStr, pcSubStr1, pcSubStr2, pnStartingAt)
			return This.FindSubStringBetweenSIBZZ(pcSubStr, pcSubStr1, pcSubStr2, pnStartingAt)

		def SubStringBetweenAsSectionsSIB(pcSubStr, pcSubStr1, pcSubStr2, pnStartingAt)
			return This.FindSubStringBetweenSIBZZ(pcSubStr, pcSubStr1, pcSubStr2, pnStartingAt)

		#>

	  #-------------------------------------------------------------------------------------------------------------------#
	 #  FINDING A SUBSTRING (AS SECTIONS) BOUNDED BY TWO OTHER SUBSTRINGS STARTING AT A GIVEN POSITION INCLUDING BOUNDS  #
	#===================================================================================================================#

	def FindSubStringBoundedBySCSIBZZ(pcSubStr, pacBounds, pnStartingAt, pCaseSensitive)
		aSections = This.FindSubStringBoundedBySCSZZ(pcSubStr, pacBounds, pnStartingAt, pCaseSensitive)
		nLen = len(aSections)

		cBound1 = ""
		cBound2 = ""

		if isString(pacBounds)
			cBound1 = pacBounds
			cBound2 = pacBounds

		else // Q(pacBounds).IsPairOfStrings()
			cBound1 = pacBounds[1]
			cBound2 = pacBounds[2]
		ok

		nLenBound1 = Q(cBound1).NumberOfChars()
		nLenBound2 = Q(cBound2).NumberOfChars()

		aResult = []

		for i = 1 to nLen
			n1 = aSections[i][1] - nLenBound1 + 1
			n2 = aSections[i][2] + nLenBound2
			aResult + [ n1, n2 ]
		next

		return aResult

		#< @FunctionAlternativeForms
	
		def FindSubStringBetweenAsSections_SCSIB(pcSubStr, pcSubStr1, pcSubStr2, pnStartingAt, pCaseSensitive)
			return This.FindSubStringBetweenSCSIBZZ(pcSubStr, pcSubStr1, pcSubStr2, pnStartingAt, pCaseSensitive)

		#>

	#-- WITHOUT CASESENSITIVITY

	def FindSubStringBoundedBySIBZZ(pcSubStr, pacBounds, pnStartingAt)
		return This.FindSubStringBoundedBySCSIBZZ(pcSubStr, pacBounds, pnStartingAt, TRUE)

		#< @FunctionAlternativeForms
	
		def FindSubStringBoundedByAsSections_SIB(pcSubStr, pacBounds, pnStartingAt)
			return This.FindSubStringBoundedBySIBZZ(pcSubStr, pacBounds, pnStartingAt)

		#>

	  #-------------------------------------------------------------------------------------------------------------------------#
	 #  GETTING THE SUBSTRING AND ITS SECTIONS BETWEEN TWO GIVEN SUBSTRINGS STARTING AT A GIVEN POSITION AND INCLUDING BOUNDS  #
	#=========================================================================================================================#

	def SubStringBetweenSCSIBZZ(pcSubStr, pcSubStr1, pcSubStr2, pnStartingAt, pCaseSensitive)
		aResult = [ pcSubStr, This.FindSubStringBetweenSCSZZ(pcSubStr, pcSubStr1, pcSubStr2, pCaseSensitive) ]
		return aResult
		
		#< @FunctionAlternativeForm

		def SubStringBetweenAsSections_SCSIB(pcSubStr, pcBound1, pcBound2, pnStartingAt, pCaseSensitive)
			return This.SubStringBetweenSCSIBZZ(pcSubStr, pcBound1, pcBound2, pnStartingAt, pCaseSensitive)

		#>

	#-- WITHOUT CASESENSITIVITY

	def SubStringBetweenSIBZZ(pcSubStr, pcSubStr1, pcSubStr2, pnStartingAt)
		return This.SubStringBetweenSCSIBZZ(pcSubStr, pcSubStr1, pcSubStr2, pnStartingAt, TRUE)

		#< @FunctionAlternativeForm

		def SubStringBetweenAsSections_SIB(pcSubStr, pcSubStr1, pcSubStr2, pnStartingAt)
			return This.SubStringBetweenSIBZZ(pcSubStr, pcSubStr1, pcSubStr2, pnStartingAt)

		#>

	  #----------------------------------------------------------------------------------------------------------------------------#
	 #  GETTING THE SUBSTRING AND ITS SECTIONS BOUNDED BY TWO GIVEN SUBSTRINGS STARTING AT A GIVEN POSITION AND INCLUDING BOUNDS  #
	#----------------------------------------------------------------------------------------------------------------------------#

	def SubStringBoundedBySCSIBZZ(pcSubStr, pacBounds, pnStartingAt, pCaseSensitive)
		aResult = [ pcSubStr, This.FindSubStringBoundedBySCSZZ(pcSubStr, pacBounds, pCaseSensitive) ]
		return aResult
		
		#< @FunctionAlternativeForm

		def SubStringBoundedByAsSections_SCSIB(pcSubStr, pacBounds, pnStartingAt, pCaseSensitive)
			return This.SubStringBetweenSCSIBZZ(pcSubStr, pacBounds, pnStartingAt, pCaseSensitive)

		#>

	#-- WITHOUT CASESENSITIVITY

	def SubStringBoundedBySIBZZ(pcSubStr, pacBounds, pnStartingAt)
		return This.SubStringBoundedBySCSIBZZ(pcSubStr, pacBounds, pnStartingAt, TRUE)

		#< @FunctionAlternativeForm

		def SubStringBoundedByAsSections_SIB(pcSubStr, pacBounds, pnStartingAt)
			return This.SubStringBoundedBySIBZZ(pcSubStr, pacBounds, pnStartingAt)

		#>

	  #===================================================================================================#
	 #  FINDING NTH NEXT OCCURRENCE OF A SUBSTRING BETWEEN TWO SUBSTRINGS  STARTING AT A GIVEN POSITION  #
	#===================================================================================================#

	def FindNextNthSubStringBetweenSCS(n, pcSubStr, pcSubStr1, pcSubStr2, pnStartingAt, pCaseSensitive)
		nLen = This.NumberOfChars()
		aSections = This.SectionQ(pnStartingAt, nLen).FindSubStringBetweenCSZZ(pcSubStr, pcSubStr1, pcSubStr2, pCaseSensitive)
		nResult = This.FindNthInSectionsCS(n, pcSubStr, Sections, pCaseSensitive)
		
		return nResult

		#< @FunctionAlternativeForms

		def FindNextNthSubStringBetweenCS(n, pcSubStr, pcSubStr1, pcSubStr2, pnStartingAt, pCaseSensitive)
			return This.FindNextNthSubStringBetweenSCS(n, pcSubStr, pcSubStr1, pcSubStr2, pnStartingAt, pCaseSensitive)

		def FindNthNextSubStringBetweenCS(n, pcSubStr, pcBound1, pcBound2, pnStartingAt, pCaseSensitive)
			return This.FindNextNthSubStringBetweenCS(n, pcSubStr, pcBound1, pcBound2, pnStartingAt, pCaseSensitive)

		def FindNthNextSubStringBetweenSCS(n, pcSubStr, pcBound1, pcBound2, pnStartingAt, pCaseSensitive)
			return This.FindNextNthSubStringBetweenCS(n, pcSubStr, pcBound1, pcBound2, pnStartingAt, pCaseSensitive)

		def FindNthNextSubStringBetweenCSZ(n, pcSubStr, pcBound1, pcBound2, pnStartingAt, pCaseSensitive)
			return This.FindNextNthSubStringBetweenCS(n, pcSubStr, pcBound1, pcBound2, pnStartingAt, pCaseSensitive)

		def FindNthNextSubStringBetweenSCSZ(n, pcSubStr, pcBound1, pcBound2, pnStartingAt, pCaseSensitive)
			return This.FindNextNthSubStringBetweenCS(n, pcSubStr, pcBound1, pcBound2, pnStartingAt, pCaseSensitive)

		def FindNextNthSubStringBetweenCSZ(n, pcSubStr, pcBound1, pcBound2, pnStartingAt, pCaseSensitive)
			return This.FindNextNthSubStringBetweenCS(n, pcSubStr, pcBound1, pcBound2, pnStartingAt, pCaseSensitive)

		def FindNextNthSubStringBetweenSCSZ(n, pcSubStr, pcBound1, pcBound2, pnStartingAt, pCaseSensitive)
			return This.FindNextNthSubStringBetweenCS(n, pcSubStr, pcBound1, pcBound2, pnStartingAt, pCaseSensitive)

		#>

	#-- WITHOUT CASESENSITIVITY

	def FindNextNthSubStringBetweenS(n, pcSubStr, pcSubStr1, pcSubStr2, pnStartingAt)
		return This.FindNextNthSubStringBetweenSCS(n, pcSubStr, pcSubStr1, pcSubStr2, pnStartingAt, pCaseSensitive)

		#< @FunctionAlternativeForms

		def FindNextNthSubStringBetween(n, pcSubStr, pcSubStr1, pcSubStr2, pnStartingAt)
			return This.FindNextNthSubStringBetweenS(n, pcSubStr, pcSubStr1, pcSubStr2, pnStartingAt)

		def FindNthNextSubStringBetween(n, pcSubStr, pcBound1, pcBound2, pnStartingAt)
			return This.FindNextNthSubStringBetween(n, pcSubStr, pcBound1, pcBound2, pnStartingAt)

		def FindNthNextSubStringBetweenS(n, pcSubStr, pcBound1, pcBound2, pnStartingAt)
			return This.FindNextNthSubStringBetween(n, pcSubStr, pcBound1, pcBound2, pnStartingAt)

		def FindNthNextSubStringBetweenZ(n, pcSubStr, pcBound1, pcBound2, pnStartingAt)
			return This.FindNextNthSubStringBetweenCS(n, pcSubStr, pcBound1, pcBound2, pnStartingAt)

		def FindNthNextSubStringBetweenSZ(n, pcSubStr, pcBound1, pcBound2, pnStartingAt)
			return This.FindNextNthSubStringBetweenCS(n, pcSubStr, pcBound1, pcBound2, pnStartingAt)

		def FindNextNthSubStringBetweenZ(n, pcSubStr, pcBound1, pcBound2, pnStartingAt)
			return This.FindNextNthSubStringBetweenCS(n, pcSubStr, pcBound1, pcBound2, pnStartingAt)

		def FindNextNthSubStringBetweenSZ(n, pcSubStr, pcBound1, pcBound2, pnStartingAt)
			return This.FindNextNthSubStringBetweenCS(n, pcSubStr, pcBound1, pcBound2, pnStartingAt)

		#>

	  #-----------------------------------------------------------------------------------------------------#
	 #  FINDING NTH NEXT OCCURRENCE OF A SUBSTRING BOUNDED BY TWO SUBSTRINGS STARTING AT A GIVEN POSITION  #
	#-----------------------------------------------------------------------------------------------------#

	def FindNextNthSubStringBoundedByCS(n, pcSubStr, pacBounds, pnStartingAt, pCaseSensitive)

		nLast = This.NumberOfChars()
		oSection = This.SectionQ(pnStartingAt, nLast)

		cBound1 = ""
		cBound2 = ""
		if isString(pacBounds)
			cBound1 = pacBounds
			cBound2 = pacBounds
		else
			cBound1 = pacBounds[1]
			cBound2 = pacBounds[2]
		ok

		cBounded = cBound1 + pcSubStr + cBound2
		nLenBounded = Q(cBounded).NumberOfChars()
		nStart = pnStartingAt
		bContinue = TRUE
		nTimes = 0

		while bContinue

			nPos = oSection.FindNeCSXT(cBounded, nStart, pCaseSensitive)

			if nPos != 0

				nTimes++

				if nTimes = n
					nResult = nPos
					bContinue = FALSE

				else
					nStart = nPos + nLenBounded
				ok

			else
				bContinue = FALSE
			ok
		end

		nResult = ( nPos + pnStartingAt - 1 )

		return nResult


		#--

		def FindNextNthSubStringBoundedBySCS(n, pcSubStr, pacBounds, pnStartingAt, pCaseSensitive)
			return This.FindNextNthSubStringBoundedByCS(n, pcSubStr, pacBounds, pnStartingAt, pCaseSensitive)

		def FindNthNextSubStringBoundedByCS(n, pcSubStr, pacBounds, pnStartingAt, pCaseSensitive)
			return This.FindNextNthSubStringBoundedByCS(n, pcSubStr, pacBounds, pnStartingAt, pCaseSensitive)

		def FindNthNextSubStringBoundedBySCS(n, pcSubStr, pacBounds, pnStartingAt, pCaseSensitive)
			return This.FindNextNthSubStringBoundedByCS(n, pcSubStr, pacBounds, pnStartingAt, pCaseSensitive)

		def FindNextNthSubStringBoundedByCSZ(n, pcSubStr, pacBounds, pnStartingAt, pCaseSensitive)
			return This.FindNextNthSubStringBoundedByCS(n, pcSubStr, pacBounds, pnStartingAt, pCaseSensitive)

		def FindNextNthSubStringBoundedBySCSZ(n, pcSubStr, pacBounds, pnStartingAt, pCaseSensitive)
			return This.FindNextNthSubStringBoundedByCS(n, pcSubStr, pacBounds, pnStartingAt, pCaseSensitive)

		def FindNthNextSubStringBoundedByCSZ(n, pcSubStr, pacBounds, pnStartingAt, pCaseSensitive)
			return This.FindNextNthSubStringBoundedByCS(n, pcSubStr, pacBounds, pnStartingAt, pCaseSensitive)

		def FindNthNextSubStringBoundedBySCSZ(n, pcSubStr, pacBounds, pnStartingAt, pCaseSensitive)
			return This.FindNextNthSubStringBoundedByCS(n, pcSubStr, pacBounds, pnStartingAt, pCaseSensitive)

		#>

	#-- WITHOUT CASESENSITIVITY

	def FindNextNthSubStringBoundedBy(n, pcSubStr, pacBounds, pnStartingAt)
		return This.FindNextNthSubStringBoundedByCS(n, pcSubStr, pacBounds, pnStartingAt, TRUE)

		#< @FunctionAlternativeForms

		def FindNextNthSubStringBoundedByS(n, pcSubStr, pacBounds, pnStartingAt)
			return This.FindNextNthSubStringBoundedBy(n, pcSubStr, pacBounds, pnStartingAt)

		def FindNthNextSubStringBoundedBy(n, pcSubStr, pacBounds, pnStartingAt)
			return This.FindNextNthSubStringBoundedBy(n, pcSubStr, pacBounds, pnStartingAt)

		def FindNthNextSubStringBoundedByS(n, pcSubStr, pacBounds, pnStartingAt)
			return This.FindNextNthSubStringBoundedBy(n, pcSubStr, pacBounds, pnStartingAt)

		def FindNextNthSubStringBoundedByZ(n, pcSubStr, pacBounds, pnStartingAt)
			return This.FindNextNthSubStringBoundedBy(n, pcSubStr, pacBounds, pnStartingAt)

		def FindNextNthSubStringBoundedBySZ(n, pcSubStr, pacBounds, pnStartingAt)
			return This.FindNextNthSubStringBoundedBy(n, pcSubStr, pacBounds, pnStartingAt)

		def FindNthNextSubStringBoundedByZ(n, pcSubStr, pacBounds, pnStartingAt)
			return This.FindNextNthSubStringBoundedBy(n, pcSubStr, pacBounds, pnStartingAt)

		def FindNthNextSubStringBoundedBySZ(n, pcSubStr, pacBounds, pnStartingAt)
			return This.FindNextNthSubStringBoundedBy(n, pcSubStr, pacBounds, pnStartingAt)
		#>

	  #----------------------------------------------------------------------------------#
	 #  GETTING THE SUBSTRING AND ITS NEXT NTH OCCURRENCE BETWEEN TWO GIVEN SUBSTRINGS  #
	#==================================================================================#

	def NextNthSubStringBetweenCSZ(n, pcSubStr, pcSubStr1, pcSubStr2, pnStartingAt, pCaseSensitive)
		aResult = [ pcSubStr, This.FindNextNthSubStringBetweenCS(n, pcSubStr, pcSubStr1, pcsubStr2, pnStartingAt, pCaseSensitive) ]
		return aResult

		#< @FunctionAlternativeForm

		def NthNextSubStringBetweenSCSZ(n, pcSubStr, pcSubStr1, pcSubStr2, pnStartingAt, pCaseSensitive)
			return This.NextNthSubStringBetweenCSZ(n, pcSubStr, pcSubStr1, pcSubStr2, pnStartingAt, pCaseSensitive)

		#>

	#-- WITHOUT CASESENSITIVITY

	def NextNthSubStringBetweenZ(n, pcSubStr, pcSubStr1, pcSubStr2, pnStartingAt)
		return This.NextNthSubStringBetweenCSZ(n, pcSubStr, pcSubStr1, pcSubStr2, pnStartingAt, TRUE)

		#< @FunctionAlternativeForm

		def NthNextSubStringBetweenSZ(n, pcSubStr, pcSubStr1, pcSubStr2, pnStartingAt)
			return This.NextNthSubStringBetweenZ(n, pcSubStr, pcSubStr1, pcSubStr2, pnStartingAt)

		#>

	  #-------------------------------------------------------------------------------------#
	 #  GETTING THE SUBSTRING AND ITS NEXT NTH OCCURRENCE BOUNDED BY TWO GIVEN SUBSTRINGS  #
	#-------------------------------------------------------------------------------------#

	def NextNthSubStringBoundedByCSZ(n, pcSubStr, pacBounds, pnStartingAt, pCaseSensitive)
		aResult = [ pcSubStr, This.FindNextNthSubStringBoundedByCS(n, pcSubStr, pacBounds, pnStartingAt, pCaseSensitive) ]
		return aResult

		#< @FunctionAlternativeForm

		def NthNextSubStringBoundedBySCSZ(n, pcSubStr, pacBounds, pnStartingAt, pCaseSensitive)
			return This.NextNthSubStringBoundedByCSZ(n, pcSubStr, pcBound1, pcBound2, pnStartingAt, pCaseSensitive)

		#>

	#-- WITHOUT CASESENSITIVITY

	def NextNthSubStringBoundedByZ(n, pcSubStr, pcBound1, pcBound2, pnStartingAt)
		return This.NextNthSubStringBoundedByCSZ(n, pcSubStr, pcBound1, pcBound2, pnStartingAt, TRUE)

		#< @FunctionAlternativeForm

		def NthNextSubStringBoundedBySZ(n, pcSubStr, pacBounds, pnStartingAt)
			return This.NextNthSubStringBoundedByZ(n, pcSubStr, pacBounds, pnStartingAt)

		#>

	  #----------------------------------------------------------------------------------------------#
	 #  FINDING NEXT OCCURRENCE OF A SUBSTRING BETWEEN TWO SUBSTRINGS STARTING AT A GIVEN POSITION  #
	#==============================================================================================#

	def FindNextSubStringBetweenCS(pcSubStr, pcSubStr1, pcSubStr2, pnStartingAt, pCaseSensitive)
		return This.FindNthSubStringBetweenCS(1, pcSubStr, pcSubStr1, pcSubStr2, pnStartingAt, pCaseSensitive)

		#< @FunctionAlternativeForms

		def FindNextSubStringBetweenSCS(pcSubStr, pcSubStr1, pcSubStr2, pnStartingAt, pCaseSensitive)
			return This.FindNextSubStringBetweenCS(pcSubStr, pcSubStr1, pcSubStr2, pnStartingAt, pCaseSensitive)

		def FindNextSubStringBetweenCSZ(pcSubStr, pcSubStr1, pcSubStr2, pnStartingAt, pCaseSensitive)
			return This.FindNextSubStringBetweenCS(pcSubStr, pcSubStr1, pcSubStr2, pnStartingAt, pCaseSensitive)

		def FindNextSubStringBetweenSCSZ(pcSubStr, pcSubStr1, pcSubStr2, pnStartingAt, pCaseSensitive)
			return This.FindNextSubStringBetweenCS(pcSubStr, pcSubStr1, pcSubStr2, pnStartingAt, pCaseSensitive)

		#>

	#-- WITHOUT CASESENSITIVITY

	def FindNextSubStringBetween(pcSubStr,pcSubStr1, pcSubStr2, pnStartingAt)
		return This.FindNextSubStringBetweenCS(pcSubStr, pcSubStr1, pcSubStr2, pnStartingAt, TRUE)

		#< @FunctionAlternativeForms

		def FindNextSubStringBetweenS(pcSubStr, pcSubStr1, pcSubStr2, pnStartingAt)
			return This.FindNextSubStringBetween(pcSubStr, pcSubStr1, pcSubStr2, pnStartingAt)

		def FindNextSubStringBetweenZ(pcSubStr, pcSubStr1, pcSubStr2, pnStartingAt)
			return This.FindNextSubStringBetween(pcSubStr, pcSubStr1, pcSubStr2, pnStartingAt)

		def FindNextSubStringBetweenSZ(pcSubStr, pcSubStr1, pcSubStr2, pnStartingAt)
			return This.FindNextSubStringBetween(pcSubStr, pcSubStr1, pcSubStr2, pnStartingAt)

		#>

	  #-------------------------------------------------------------------------------------------------#
	 #  FINDING NEXT OCCURRENCE OF A SUBSTRING BOUNDED BY TWO SUBSTRINGS STARTING AT A GIVEN POSITION  #
	#-------------------------------------------------------------------------------------------------#

	def FindNextSubStringBoundedByCS(pcSubStr, pacBounds, pnStartingAt, pCaseSensitive)
		return This.FindNextNthSubStringBoundedByCS(1, pcSubStr, pacBounds, pnStartingAt, pCaseSensitive)

		#< @FunctionAlternativeForms

		def FindNextSubStringBoundedBySCS(pcSubStr, pacBounds, pnStartingAt, pCaseSensitive)
			return This.FindNextSubStringBoundedByCS(pcSubStr, pacBounds, pnStartingAt, pCaseSensitive)

		def FindNextSubStringBoundedByCSZ(pcSubStr, pacBounds, pnStartingAt, pCaseSensitive)
			return This.FindNextSubStringBoundedByCS(pcSubStr, pacBounds, pnStartingAt, pCaseSensitive)

		def FindNextSubStringBoundedBySCSZ(pcSubStr, pacBounds, pnStartingAt, pCaseSensitive)
			return This.FindNextSubStringBoundedByCS(pcSubStr, pacBounds, pnStartingAt, pCaseSensitive)

		#>

	#-- WITHOUT CASESENSITIVITY

	def FindNextSubStringBoundedBy(pcSubStr, pacBounds, pnStartingAt)
		return This.FindNextSubStringBoundedByCS(pcSubStr, pacBounds, pnStartingAt, TRUE)

		#< @FunctionAlternativeForms

		def FindNextSubStringBoundedByS(pcSubStr, pacBounds, pnStartingAt)
			return This.FindNextSubStringBoundedBy(pcSubStr, pacBounds, pnStartingAt)

		def FindNextSubStringBoundedByZ(pcSubStr, pacBounds, pnStartingAt)
			return This.FindNextSubStringBoundedBy(pcSubStr, pacBounds, pnStartingAt)

		def FindNextSubStringBoundedBySZ(pcSubStr, pacBounds, pnStartingAt)
			return This.FindNextSubStringBoundedBy(pcSubStr, pacBounds, pnStartingAt)

		#>

	  #-----------------------------------------------------------------------------------------------------#
	 #  GETTING SUBSTRING AND ITS NEXT NTH OCCURRENCE BETWEEN TWO SUBSTRINGS STARTING AT A GIVEN POSITION  #
	#=====================================================================================================#

	def NextSubStringBetweenCSZ(pcSubStr, pcSubStr1, pcSubStr2, pnStartingAt, pCaseSensitive)
		aResult = [ pcSubStr, This.FindNextSubStringBetweenCS(pcSubStr, pcSubStr1, pcSubStr2, pnStartingAt, pCaseSensitive) ]
		return aResult

		#< @FunctionAlternativeForm

		def NextSubStringBetweenSCSZ(pcSubStr, pcSubStr1, pcSubStr2, pnStartingAt, pCaseSensitive)
			return This.NextSubStringBetweenCSZ(pcSubStr, pcSubStr1, pcSubStr2, pnStartingAt, pCaseSensitive)

		#>

	#-- WITHOUT CASESENSITIVITY

	def NextSubStringBetweenZ(pcSubStr, pcSubStr1, pcSubStr2, pnStartingAt)
		return This.NextNthSubStringBetweenCSZ(pcSubStr, pcSubStr1, pcSubStr2, pnStartingAt, TRUE)

		#< @FunctionAlternativeForm

		def NextSubStringBetweenSZ(pcSubStr, pcSubStr1, pcSubStr2, pnStartingAt)
			return This.NextSubStringBetweenZ(pcSubStr, pcBound1, pcBound2, pnStartingAt)

		#>

	  #--------------------------------------------------------------------------------------------------------#
	 #  GETTING SUBSTRING AND ITS NEXT NTH OCCURRENCE BOUNDED BY TWO SUBSTRINGS STARTING AT A GIVEN POSITION  #
	#--------------------------------------------------------------------------------------------------------#

	def NextSubStringBoundedByCSZ(pcSubStr, pacBounds, pnStartingAt, pCaseSensitive)
		aResult = [ pcSubStr, This.FindNextSubStringBoundedByCS(pcSubStr, pacBounds, pnStartingAt, pCaseSensitive) ]
		return aResult

		#< @FunctionAlternativeForm

		def NextSubStringBoundedBySCSZ(pcSubStr, pacBounds, pnStartingAt, pCaseSensitive)
			return This.NextSubStringBoundedByCSZ(pcSubStr, pacBounds, pnStartingAt, pCaseSensitive)

		#>

	#-- WITHOUT CASESENSITIVITY

	def NextSubStringBoundedByZ(pcSubStr, pacBounds, pnStartingAt)
		return This.NextNthSubStringBoundedByCSZ(pcSubStr, pacBounds, pnStartingAt, TRUE)

		#< @FunctionAlternativeForm

		def NextSubStringBoundedBySZ(pcSubStr, pacBounds, pnStartingAt)
			return This.NextSubStringBoundedByZ(pcSubStr, pacBounds, pnStartingAt)

		#>

	  #======================================================================================================#
	 #  FINDING NTH PREVIOUS OCCURRENCE OF A SUBSTRING BETWEEN TWO SUBSTRINGS STARTING AT A GIVEN POSITION  #
	#======================================================================================================#

ici	def FindPreviousNthSubStringBetweenCS(n, pcSubStr, pcSubStr1, pcSubStr2, pnStartingAt, pCaseSensitive)

		aSections = This.SectionQ(1, pnStartingAt).FindSubStringBetweenCSZZ(pcSubStr, pcSubStr1, pcSubStr2, pCaseSensitive)
		nLen = This.NumberOfOccurrenceInSectionsCS(pcSubStr, aSections)
		nResult = This.FindNthInSectionsCS(nLen - n + 1, pcSubStr, aSections, pCaseSensitive)
		
		return nResult

		#< @FunctionAlternativeForms

		def FindNthPreviousSubStringBetweenCS(n, pcSubStr, pcBound1, pcBound2, pnStartingAt, pCaseSensitive)
			return This.FindPreviousNthSubStringBetweenCS(n, pcSubStr, pcBound1, pcBound2, pnStartingAt, pCaseSensitive)

		def FindNthPreviousSubStringBetweenCSZ(n, pcSubStr, pcBound1, pcBound2, pnStartingAt, pCaseSensitive)
			return This.FindPreviousNthSubStringBetweenCS(n, pcSubStr, pcBound1, pcBound2, pnStartingAt, pCaseSensitive)

		def FindPreviousNthSubStringBetweenCSZ(n, pcSubStr, pcBound1, pcBound2, pnStartingAt, pCaseSensitive)
			return This.FindPreviousNthSubStringBetweenCS(n, pcSubStr, pcBound1, pcBound2, pnStartingAt, pCaseSensitive)

		#--

		def  FindPreviousNthSubStringBetweenSCS(n, pcSubStr, pcSubStr1, pcSubStr2, pnStartingAt, pCaseSensitive)
			return This. FindPreviousNthSubStringBetweenCS(n, pcSubStr, pcSubStr1, pcSubStr2, pnStartingAt, pCaseSensitive)

		def FindNthPreviousSubStringBetweenSCS(n, pcSubStr, pcBound1, pcBound2, pnStartingAt, pCaseSensitive)
			return This.FindPreviousNthSubStringBetweenCS(n, pcSubStr, pcBound1, pcBound2, pnStartingAt, pCaseSensitive)

		def FindNthPreviousSubStringBetweenSCSZ(n, pcSubStr, pcBound1, pcBound2, pnStartingAt, pCaseSensitive)
			return This.FindPreviousNthSubStringBetweenCS(n, pcSubStr, pcBound1, pcBound2, pnStartingAt, pCaseSensitive)

		def FindPreviousNthSubStringBetweenSCSZ(n, pcSubStr, pcBound1, pcBound2, pnStartingAt, pCaseSensitive)
			return This.FindPreviousNthSubStringBetweenCS(n, pcSubStr, pcBound1, pcBound2, pnStartingAt, pCaseSensitive)

		#>

	# WITHOUT CASESENSITIVITY



	  #---------------------------------------------------------------------------------------------------------#
	 #  FINDING NTH PREVIOUS OCCURRENCE OF A SUBSTRING BOUNDED BY TWO SUBSTRINGS STARTING AT A GIVEN POSITION  #
	#---------------------------------------------------------------------------------------------------------#

	def FindPreviousNthSubStringBoundedByCS(n, pcSubStr, pacBounds, pnStartingAt, pCaseSensitive)
		nLast = This.NumberOfChars()
		oSection = This.SectionQ(pnStartingAt, nLast).FindSubStringBetweenCS(pcSubStr, pcBound1, pcBound2, pCaseSensitive)

		cBound1 = ""
		cBound2 = ""
		if isString(pcSubStr)
			cBound1 = pacBounds
			cBound2 = pacBounds
		else // Q(pacBounds).IsPairOfStrings()
			cBound1 = pacBounds[1]
			cBound2 = pacBounds[2]
		ok

		cBounded = pcBound1 + pcSubStr + pcBound2
		nLenBounded = Q(cBounded).NumberOfChars()
		nStart = pnStartingAt
		bContinue = TRUE
		nTimes = 0

		while bContinue

			nPos = oSection.FindPreviousCS(cBounded, nStart, pCaseSensitive)

			if nPos != 0

				nTimes++

				if nTimes = n
					nResult = nPos
					bContinue = FALSE

				else
					nStart = nPos - 1
				ok

			else
				bContinue = FALSE
			ok
		end

		nResult = ( nPos + pnStartingAt - 1 )

		return nResult

		#< @FunctionAlternativeForms

		def FindNthPreviousSubStringBoundedByCS(n, pcSubStr, pacBounds, pnStartingAt, pCaseSensitive)
			return This.FindPreviousNthSubStringBoundedByCS(n, pcSubStr, pacBounds, pnStartingAt, pCaseSensitive)

		def FindPreviousNthSubStringBoundedByCSZ(n, pcSubStr, pacBounds, pnStartingAt, pCaseSensitive)
			return This.FindPreviousNthSubStringBoundedByCS(n, pcSubStr, pacBounds, pnStartingAt, pCaseSensitive)

		def FindNthPreviousSubStringBoundedByCSZ(n, pcSubStr, pacBounds, pnStartingAt, pCaseSensitive)
			return This.FindPreviousNthSubStringBoundedByCS(n, pcSubStr, pacBounds, pnStartingAt, pCaseSensitive)

		#>

	#-- WITHOUT CASESENSITIVITY

	def FindPreviousNthSubStringBoundedBy(n, pcSubStr, pcBound1, pcBound2, pnStartingAt)
		return This.FindPreviousNthSubStringBoundedByCS(n, pcSubStr, pcBound1, pcBound2, pnStartingAt, TRUE)

		#< @FunctionAlternativeForms

		#< @FunctionAlternativeForms

		def FindNthPreviousSubStringBoundedBy(n, pcSubStr, pacBounds, pnStartingAt)
			return This.FindPreviousNthSubStringBoundedBy(n, pcSubStr, pacBounds, pnStartingAt)

		def FindPreviousNthSubStringBoundedByZ(n, pcSubStr, pacBounds, pnStartingAt)
			return This.FindPreviousNthSubStringBoundedBy(n, pcSubStr, pacBounds, pnStartingAt)

		def FindNthPreviousSubStringBoundedByZ(n, pcSubStr, pacBounds, pnStartingAt)
			return This.FindPreviousNthSubStringBoundedBy(n, pcSubStr, pacBounds, pnStartingAt)

		#>

	   #----------------------------------------------------------------------#
	  #  GETTING THE SUBSTRING AND ITS NTH PREVIOUS OCCURRENCE BETWEEN TWO   #
	 #  GIVEN SUBSTRINGS STARTING AT A GIVEN POSITION                       #
	#----------------------------------------------------------------------#

	def PreviousNthSubStringBetweenSCSZ(n, pcSubStr, pcBound1, pcBound2, pnStartingAt, pCaseSensitive)
		aResult = [ pcSubStr, This.FindPreviousNthSubStringSCSZ(n, pcSubStr, pcBound1, pcBound2, pnStartingAt, pCaseSensitive) ]
		return aResult

		#< @FunctionAlternativeForms

		def NthPreviousSubStringSCSZ(n, pcSubStr, pcBound1, pcBound2, pnStartingAt, pCaseSensitive)
			return This.PreviousNthSubStringSCSZ(n, pcSubStr, pcBound1, pcBound2, pnStartingAt, pCaseSensitive)

		def NthPreviousSubStringBoundedBySCSZ(n, pcSubStr, pcBound1, pcBound2, pnStartingAt, pCaseSensitive)
			return This.PreviousNthSubStringBoundedBySCSZ(n, pcSubStr, pacBounds, pnStartingAt, pCaseSensitive)

		#>

	#--

	def PreviousNthSubStringBetwenSZ(n, pcSubStr, pcBound1, pcBound2, pnStartingAt)
		return This.PreviousNthSubStringBetweenSCSZ(n, pcSubStr, pcBound1, pcBound2, pnStartingAt, TRUE)

		#< @FunctionAlternativeForms

		def NthPreviousSubStringSZ(n, pcSubStr, pcBound1, pcBound2, pnStartingAt)
			return This.PreviousNthSubStringSZ(n, pcSubStr, pcBound1, pcBound2, pnStartingAt)

		def NthPreviousSubStringBoundedBySZ(n, pcSubStr, pcBound1, pcBound2, pnStartingAt)
			return This.PreviousNthSubStringBoundedBySZ(n, pcSubStr, pacBounds, pnStartingAt)

		#>

	  #------------------------------------------------------------------------------------------------------#
	 #  FINDING PREVIOUS OCCURRENCE OF A SUBSTRING BOUNDED BY TWO SUBSTRINGS  STARTING AT A GIVEN POSITION  #
	#======================================================================================================#

	def FindPreviousSubStringBetweenCS(pcSubStr, pcBound1, pcBound2, pnStartingAt, pCaseSensitive)
		return This.FindNthSubStringBetweenCS(1, pcSubStr, pcBound1, pcBound2, pnStartingAt, pCaseSensitive)

		#< @FunctionAlternativeForms

		def FindPreviousSubStringBetweenCSZ(pcSubStr, pcBound1, pcBound2, pnStartingAt, pCaseSensitive)
			return This.FindPreviousSubStringBetweenCS(pcSubStr, pcBound1, pcBound2, pnStartingAt, pCaseSensitive)

		#--

		def FindPreviousSubStringBoundedByCS(pcSubStr, pacBounds, pnStartingAt, pCaseSensitive)
			return This.FindPreviousNthSubStringBoundedByCS(1, pcSubStr, pacBounds, pnStartingAt, pCaseSensitive)

		def FindPreviousSubStringBoundedByCSZ(pcSubStr, pacBounds, pnStartingAt, pCaseSensitive)
			return This.FindPreviousSubStringBoundedByCS(pcSubStr, pacBounds, pnStartingAt, pCaseSensitive)

		#==

		def PreviousSubStringSCS(pcSubStr, pcBound1, pcBound2, pnStartingAt, pCaseSensitive)
			return This.FindPreviousSubStringBetweenCS(pcSubStr, pcBound1, pcBound2, pnStartingAt, pCaseSensitive)

		def PreviousSubStringBoundedBySCS(pcSubStr, pcBound1, pcBound2, pnStartingAt, pCaseSensitive)
			return This.FindPreviousSubStringBoundedByCS(pcSubStr, pacBounds, pnStartingAt, pCaseSensitive)


		#>

	#-- WITHOUT CASESENSITIVITY

	def FindPreviousSubStringBetween(pcSubStr, pcBound1, pcBound2, pnStartingAt)
		return This.FindPreviousSubStringBetweenCS(pcSubStr, pcBound1, pcBound2, pnStartingAt, TRUE)

		#< @FunctionAlternativeForms

		def FindPreviousSubStringBetweenZ(pcSubStr, pcBound1, pcBound2, pnStartingAt, pCaseSensitive)
			return This.FindPreviousSubStringBetween(pcSubStr, pcBound1, pcBound2, pnStartingAt)

		#--

		def FindPreviousSubStringBoundedBy(pcSubStr, pacBounds, pnStartingAt)
			return This.FindPreviousSubStringBoundedByCS(pcSubStr, pacBounds, pnStartingAt, TRUE)

		def FindPreviousSubStringBoundedByZ(pcSubStr, pacBounds, pnStartingAt, pCaseSensitive)
			return This.FindPreviousSubStringBoundedBy(pcSubStr, pacBounds, pnStartingAt)

		#==

		def PreviousSubStringS(pcSubStr, pcBound1, pcBound2, pnStartingAt, pCaseSensitive)
			return This.FindPreviousSubStringBetween(pcSubStr, pcBound1, pcBound2, pnStartingAt)

		def PreviousSubStringBoundedByS(pcSubStr, pcBound1, pcBound2, pnStartingAt, pCaseSensitive)
			return This.FindPreviousSubStringBoundedBy(pcSubStr, pacBounds, pnStartingAt)

		#>

	   #-------------------------------------------------------------#
	  #  GETTING THE SUBSTRING AND ITS PREVIOUS OCCURRENCE BETWEEN  #
	 #  TWO GIVEN SUBSTRINGS STARTING AT A GIVEN POSITION          #
	#-------------------------------------------------------------#

	def PreviousSubStringSCSZ(pcSubStr, pcBound1, pcBound2, pnStartingAt, pCaseSensitive)
		aResult = [ pcSubStr, This.PreviousSubStringSCSZ(pcSubStr, pcBound1, pcBound2, pnStartingAt, pCaseSensitive) ]
		return aResult

		#< @FunctionAlternativeForms

		def PreviousSubStringBoundedBySCSZ(pcSubStr, pcBound1, pcBound2, pnStartingAt, pCaseSensitive)
			return This.FindPreviousSubStringBoundedByCS(pcSubStr, pacBounds, pnStartingAt, pCaseSensitive)

		#--

		def PreviousSubStringAsSectionSCS(pcSubStr, pcBound1, pcBound2, pnStartingAt, pCaseSensitive)
			return This.PreviousSubStringSCSZ(pcSubStr, pcBound1, pcBound2, pnStartingAt, pCaseSensitive)

		def PreviousSubStringBoundedByAsSectionSCS(pcSubStr, pcBound1, pcBound2, pnStartingAt, pCaseSensitive)
			return This.PreviousSubStringBoundedBySCSZ(pcSubStr, pcBound1, pcBound2, pnStartingAt, pCaseSensitive)

		#>

	#-- WITHOUT CASESENSITIVITY

	def PreviousSubStringSZ(pcSubStr, pcBound1, pcBound2, pnStartingAt)
		return This.PreviousSubStringSCSZ(pcSubStr, pcBound1, pcBound2, pnStartingAt, pCaseSensitive)

		#< @FunctionAlternativeForms

		def PreviousSubStringBoundedBySZ(pcSubStr, pcBound1, pcBound2, pnStartingAt)
			return This.FindPreviousSubStringBoundedBy(pcSubStr, pacBounds, pnStartingAt)

		#--

		def PreviousSubStringAsSectionS(pcSubStr, pcBound1, pcBound2, pnStartingAt)
			return This.PreviousSubStringSZ(pcSubStr, pcBound1, pcBound2, pnStartingAt)

		def PreviousSubStringBoundedByAsSectionS(pcSubStr, pcBound1, pcBound2, pnStartingAt)
			return This.PreviousSubStringBoundedBySZ(pcSubStr, pcBound1, pcBound2, pnStartingAt)

		#>

	  #==========================================================================================================================#
	 #  FINDING NTH NEXT OCCURRENCE OF A SUBSTRING BOUNDED BY TWO SUBSTRINGS STARTING AT A GIVEN POSITION AND INCLUDING BOuNDS  #
	#==========================================================================================================================#

	def FindNextNthSubStringBetweenCSIB(n, pcSubStr, pcBound1, pcBound2, pnStartingAt, pCaseSensitive)

		nPos = This.FindNextNthSubStringCSIB(n, pcSubStr, pcBound1, pcBound2, pnStartingAt, pCaseSensitive)
		nResult = nPos + Q(pcBound1).NumberOfChars() - 1

		return nResult

		#< @FunctionAlternativeForms

		def FindNextNthSubStringBetweenSCSIB(n, pcSubStr, pcBound1, pcBound2, pnStartingAt, pCaseSensitive)
			return This.FindNextNthSubStringBetweenCSIB(n, pcSubStr, pcBound1, pcBound2, pnStartingAt, pCaseSensitive)

		def FindNthNextSubStringBetweenCSIB(n, pcSubStr, pcBound1, pcBound2, pnStartingAt, pCaseSensitive)
			return This.FindNextNthSubStringBetweenCSIB(n, pcSubStr, pcBound1, pcBound2, pnStartingAt, pCaseSensitive)

		def FindNthNextSubStringBetweenSCSIB(n, pcSubStr, pcBound1, pcBound2, pnStartingAt, pCaseSensitive)
			return This.FindNextNthSubStringBetweenCSIB(n, pcSubStr, pcBound1, pcBound2, pnStartingAt, pCaseSensitive)

		def FindNthNextSubStringBetweenCSIBZ(n, pcSubStr, pcBound1, pcBound2, pnStartingAt, pCaseSensitive)
			return This.FindNextNthSubStringBetweenCSIB(n, pcSubStr, pcBound1, pcBound2, pnStartingAt, pCaseSensitive)

		def FindNthNextSubStringBetweenSCSIBZ(n, pcSubStr, pcBound1, pcBound2, pnStartingAt, pCaseSensitive)
			return This.FindNextNthSubStringBetweenCSIB(n, pcSubStr, pcBound1, pcBound2, pnStartingAt, pCaseSensitive)

		def FindNextNthSubStringBetweenCSIBZ(n, pcSubStr, pcBound1, pcBound2, pnStartingAt, pCaseSensitive)
			return This.FindNextNthSubStringBetweenCSIB(n, pcSubStr, pcBound1, pcBound2, pnStartingAt, pCaseSensitive)

		def FindNextNthSubStringBetweenSCSIBZ(n, pcSubStr, pcBound1, pcBound2, pnStartingAt, pCaseSensitive)
			return This.FindNextNthSubStringBetweenCSIB(n, pcSubStr, pcBound1, pcBound2, pnStartingAt, pCaseSensitive)

		#--

		def FindNextNthSubStringBoundedByCSIB(n, pcSubStr, pacBounds, pnStartingAt, pCaseSensitive)
			if isString(pacBounds)
				return This.FindNextNthSubStringBetweenCSIB(n, pcSubStr, pacBounds, pacBounds, pnStartingAt, pCaseSensitive)

			but isList(pacBounds) and Q(pacBounds).IsPairOfStrings()
				return This.FindNextNthSubStringBetweenCSIB(n, pcSubStr, pacBounds, pacBounds, pnStartingAt, pCaseSensitive)

			else
				StzRaise("Incorrect param type! pacBounds must be a string or pair of strings.")
			ok

			return This.FindNextNthSubStringBetweenCSIB(n, pcSubStr, pcBound1, pcBound2, pnStartingAt, pCaseSensitive)

		def FindNextNthSubStringBoundedBySCSIB(n, pcSubStr, pacBounds, pnStartingAt, pCaseSensitive)
			return This.FindNextNthSubStringBoundedByCSIB(n, pcSubStr, pacBounds, pnStartingAt, pCaseSensitive)

		def FindNthNextSubStringBoundedByCSIB(n, pcSubStr, pacBounds, pnStartingAt, pCaseSensitive)
			return This.FindNextNthSubStringBoundedByCSIB(n, pcSubStr, pacBounds, pnStartingAt, pCaseSensitive)

		def FindNthNextSubStringBoundedBySCSIB(n, pcSubStr, pacBounds, pnStartingAt, pCaseSensitive)
			return This.FindNextNthSubStringBoundedByCSIB(n, pcSubStr, pacBounds, pnStartingAt, pCaseSensitive)

		def FindNextNthSubStringBoundedByCSIBZ(n, pcSubStr, pacBounds, pnStartingAt, pCaseSensitive)
			return This.FindNextNthSubStringBoundedByCSIB(n, pcSubStr, pacBounds, pnStartingAt, pCaseSensitive)

		def FindNextNthSubStringBoundedBySCSIBZ(n, pcSubStr, pacBounds, pnStartingAt, pCaseSensitive)
			return This.FindNextNthSubStringBoundedByCSIB(n, pcSubStr, pacBounds, pnStartingAt, pCaseSensitive)

		def FindNthNextSubStringBoundedByCSIBZ(n, pcSubStr, pacBounds, pnStartingAt, pCaseSensitive)
			return This.FindNextNthSubStringBoundedByCSIB(n, pcSubStr, pacBounds, pnStartingAt, pCaseSensitive)

		def FindNthNextSubStringBoundedBySCSIBZ(n, pcSubStr, pacBounds, pnStartingAt, pCaseSensitive)
			return This.FindNextNthSubStringBoundedByCSIB(n, pcSubStr, pacBounds, pnStartingAt, pCaseSensitive)

		#==

		def NextNthSubStringCSIB(n, pcSubStr, pcBound1, pcBound2, pnStartingAt, pCaseSensitive)
			return This.FindNextNthSubStringBetweenCSIB(n, pcSubStr, pcBound1, pcBound2, pnStartingAt, pCaseSensitive)

		def NextNthSubStringSCSIB(n, pcSubStr, pcBound1, pcBound2, pnStartingAt, pCaseSensitive)
			return This.FindNextNthSubStringBetweenCSIB(n, pcSubStr, pcBound1, pcBound2, pnStartingAt, pCaseSensitive)

		def NthNextSubStringCSIB(n, pcSubStr, pcBound1, pcBound2, pnStartingAt, pCaseSensitive)
			return This.FindNextNthSubStringBetweenCSIB(n, pcSubStr, pcBound1, pcBound2, pnStartingAt, pCaseSensitive)

		def NthNextSubStringSCSIB(n, pcSubStr, pcBound1, pcBound2, pnStartingAt, pCaseSensitive)
			return This.FindNextNthSubStringBetweenCSIB(n, pcSubStr, pcBound1, pcBound2, pnStartingAt, pCaseSensitive)

		#--

		def NextNthSubStringBoundedByCSIB(n, pcSubStr, pcBound1, pcBound2, pnStartingAt, pCaseSensitive)
			return This.FindNextNthSubStringBoundedByCSIB(n, pcSubStr, pacBounds, pnStartingAt, pCaseSensitive)

		def NextNthSubStringBoundedBySCSIB(n, pcSubStr, pcBound1, pcBound2, pnStartingAt, pCaseSensitive)
			return This.FindNextNthSubStringBoundedByCSIB(n, pcSubStr, pacBounds, pnStartingAt, pCaseSensitive)

		def NthNextSubStringBoundedByCSIB(n, pcSubStr, pcBound1, pcBound2, pnStartingAt, pCaseSensitive)
			return This.FindNextNthSubStringBoundedByCSIB(n, pcSubStr, pacBounds, pnStartingAt, pCaseSensitive)

		def NthNextSubStringBoundedBySCSIB(n, pcSubStr, pcBound1, pcBound2, pnStartingAt, pCaseSensitive)
			return This.FindNextNthSubStringBoundedByCSIB(n, pcSubStr, pacBounds, pnStartingAt, pCaseSensitive)

		#>

	#-- WITHOUT CASESENSITIVITY

	def FindNextNthSubStringBetweenIB(n, pcSubStr, pcBound1, pcBound2, pnStartingAt)
		return This.FindNextNthSubStringBetweenCSIB(n, pcSubStr, pcBound1, pcBound2, pnStartingAt, TRUE)

		#< @FunctionAlternativeForms

		def FindNextNthSubStringBetweenSIB(n, pcSubStr, pcBound1, pcBound2, pnStartingAt)
			return This.FindNextNthSubStringBetweenIB(n, pcSubStr, pcBound1, pcBound2, pnStartingAt)

		def FindNthNextSubStringBetweenIB(n, pcSubStr, pcBound1, pcBound2, pnStartingAt)
			return This.FindNextNthSubStringBetweenIB(n, pcSubStr, pcBound1, pcBound2, pnStartingAt)

		def FindNthNextSubStringBetweenSIB(n, pcSubStr, pcBound1, pcBound2, pnStartingAt)
			return This.FindNextNthSubStringBetweenIB(n, pcSubStr, pcBound1, pcBound2, pnStartingAt)

		def FindNthNextSubStringBetweenIBZ(n, pcSubStr, pcBound1, pcBound2, pnStartingAt)
			return This.FindNextNthSubStringBetweenIB(n, pcSubStr, pcBound1, pcBound2, pnStartingAt)

		def FindNthNextSubStringBetweenSIBZ(n, pcSubStr, pcBound1, pcBound2, pnStartingAt)
			return This.FindNextNthSubStringBetweenIB(n, pcSubStr, pcBound1, pcBound2, pnStartingAt)

		def FindNextNthSubStringBetweenIBZ(n, pcSubStr, pcBound1, pcBound2, pnStartingAt)
			return This.FindNextNthSubStringBetweenIB(n, pcSubStr, pcBound1, pcBound2, pnStartingAt)

		def FindNextNthSubStringBetweenSIBZ(n, pcSubStr, pcBound1, pcBound2, pnStartingAt)
			return This.FindNextNthSubStringBetweenIB(n, pcSubStr, pcBound1, pcBound2, pnStartingAt)

		#--

		def FindNextNthSubStringBoundedByIB(n, pcSubStr, pacBounds, pnStartingAt)
			return This.FindNextNthSubStringBoundedByCSIB(n, pcSubStr, pacBounds, pnStartingAt, TRUE)

		def FindNextNthSubStringBoundedBySIB(n, pcSubStr, pacBounds, pnStartingAt)
			return This.FindNextNthSubStringBoundedByIB(n, pcSubStr, pacBounds, pnStartingAt)

		def FindNthNextSubStringBoundedByIB(n, pcSubStr, pacBounds, pnStartingAt)
			return This.FindNextNthSubStringBoundedByIB(n, pcSubStr, pacBounds, pnStartingAt)

		def FindNthNextSubStringBoundedBySIB(n, pcSubStr, pacBounds, pnStartingAt)
			return This.FindNextNthSubStringBoundedByIB(n, pcSubStr, pacBounds, pnStartingAt)

		def FindNextNthSubStringBoundedByZIB(n, pcSubStr, pacBounds, pnStartingAt)
			return This.FindNextNthSubStringBoundedByIB(n, pcSubStr, pacBounds, pnStartingAt)

		def FindNextNthSubStringBoundedBySIBZ(n, pcSubStr, pacBounds, pnStartingAt)
			return This.FindNextNthSubStringBoundedByIB(n, pcSubStr, pacBounds, pnStartingAt)

		def FindNthNextSubStringBoundedByZIB(n, pcSubStr, pacBounds, pnStartingAt)
			return This.FindNextNthSubStringBoundedByIB(n, pcSubStr, pacBounds, pnStartingAt)

		def FindNthNextSubStringBoundedBySIBZ(n, pcSubStr, pacBounds, pnStartingAt)
			return This.FindNextNthSubStringBoundedByIB(n, pcSubStr, pacBounds, pnStartingAt)

		#==

		def NextNthSubStringIB(n, pcSubStr, pcBound1, pcBound2, pnStartingAt)
			return This.FindNextNthSubStringBetweenIB(n, pcSubStr, pcBound1, pcBound2, pnStartingAt)

		def NextNthSubStringSIB(n, pcSubStr, pcBound1, pcBound2, pnStartingAt)
			return This.FindNextNthSubStringBetweenIB(n, pcSubStr, pcBound1, pcBound2, pnStartingAt)

		def NthNextSubStringIB(n, pcSubStr, pcBound1, pcBound2, pnStartingAt)
			return This.FindNextNthSubStringBetweenIB(n, pcSubStr, pcBound1, pcBound2, pnStartingAt)

		def NthNextSubStringSIB(n, pcSubStr, pcBound1, pcBound2, pnStartingAt)
			return This.FindNextNthSubStringBetweenIB(n, pcSubStr, pcBound1, pcBound2, pnStartingAt)

		#--

		def NextNthSubStringBoundedByIB(n, pcSubStr, pcBound1, pcBound2, pnStartingAt)
			return This.FindNextNthSubStringBoundedByIB(n, pcSubStr, pacBounds, pnStartingAt)

		def NextNthSubStringBoundedBySIB(n, pcSubStr, pcBound1, pcBound2, pnStartingAt)
			return This.FindNextNthSubStringBoundedByIB(n, pcSubStr, pacBounds, pnStartingAt)

		def NthNextSubStringBoundedByIB(n, pcSubStr, pcBound1, pcBound2, pnStartingAt)
			return This.FindNextNthSubStringBoundedByIB(n, pcSubStr, pacBounds, pnStartingAt)

		def NthNextSubStringBoundedBySIB(n, pcSubStr, pcBound1, pcBound2, pnStartingAt)
			return This.FindNextNthSubStringBoundedByIB(n, pcSubStr, pacBounds, pnStartingAt)

		#>

	  #----------------------------------------------------------------------------------#
	 #  GETTING THE SUBSTRING AND ITS NEXT NTH OCCURRENCE BETWEEN TWO GIVEN SUBSTRINGS  #
	#----------------------------------------------------------------------------------#

	def NextNthSubStringBetweenCSIBZ(n, pcSubStr, pcBound1, pcBound2, pnStartingAt, pCaseSensitive)
		aResult = [ pcSubStr, This.FindNextNthSubStringBetweenCSIB(n, pcSubStr, pcBound1, pcBound2, pnStartingAt, pCaseSensitive) ]
		return aResult

		#< @FunctionAlternativeForms

		def NthNextSubStringBetweenSCSIBZ(n, pcSubStr, pcBound1, pcBound2, pnStartingAt, pCaseSensitive)
			return This.NextNthSubStringBetweenCSIBZ(n, pcSubStr, pcBound1, pcBound2, pnStartingAt, pCaseSensitive)

		def NextNthSubStringBoundedBySCSIBZ(n, pcSubStr, pacBounds, pnStartingAt, pCaseSensitive)
			if isString(pacBounds)
				return This.NextNthSubStringBetweenCSIBZ(n, pcSubStr, pacBounds, pacBounds, pnStartingAt, pCaseSensitive)

			but isList(pacBounds) and Q(pacBounds).IsPairOfStrings()
				return This.NextNthSubStringBetweenCSIBZ(n, pcSubStr, pacBounds[1], pacBounds[2], pnStartingAt, pCaseSensitive)

			else
				StzRaise("Incorrect param type! pacBounds must be a string or pair of strings.")
			ok

		def NthNextSubStringBoundedBySCSIBZ(n, pcSubStr, pcBound1, pcBound2, pnStartingAt, pCaseSensitive)
			return This.NextNthSubStringBoundedBySCSIBZ(n, pcSubStr, pacBounds, pnStartingAt, pCaseSensitive)

		#>

	#-- WITHOUT CASESENSITIVITY

	def NextNthSubStringBetweenIBZ(n, pcSubStr, pcBound1, pcBound2, pnStartingAt)
		return This.NextNthSubStringBetweenCSIBZ(n, pcSubStr, pcBound1, pcBound2, pnStartingAt, TRUE)

		#< @FunctionAlternativeForms

		def NthNextSubStringBetweenSIBZ(n, pcSubStr, pcBound1, pcBound2, pnStartingAt)
			return This.NextNthSubStringBetweenIBZ(n, pcSubStr, pcBound1, pcBound2, pnStartingAt)

		def NextNthSubStringBoundedBySIBZ(n, pcSubStr, pacBounds, pnStartingAt)
			return This.NextNthSubStringBoundedBySCSIBZ(n, pcSubStr, pacBounds, pnStartingAt, TRUE)

		def NthNextSubStringBoundedBySIBZ(n, pcSubStr, pcBound1, pcBound2, pnStartingAt)
			return This.NextNthSubStringBoundedBySIBZ(n, pcSubStr, pacBounds, pnStartingAt)

		#>

	  #--------------------------------------------------------------------------------------------------#
	 #  FINDING NEXT OCCURRENCE OF A SUBSTRING BOUNDED BY TWO SUBSTRINGS STARTING AT A GIVEN POSITION  #
	#==================================================================================================#

	def FindNextSubStringBetweenCSIB(pcSubStr, pcBound1, pcBound2, pnStartingAt, pCaseSensitive)
		return This.FindNthSubStringBetweenCSIB(1, pcSubStr, pcBound1, pcBound2, pnStartingAt, pCaseSensitive)

		#< @FunctionAlternativeForms

		def FindNextSubStringBetweenSCSIB(pcSubStr, pcBound1, pcBound2, pnStartingAt, pCaseSensitive)
			return This.FindNextSubStringBetweenCSIB(pcSubStr, pcBound1, pcBound2, pnStartingAt, pCaseSensitive)

		def FindNextSubStringBetweenCSIBZ(pcSubStr, pcBound1, pcBound2, pnStartingAt, pCaseSensitive)
			return This.FindNextSubStringBetweenCSIB(pcSubStr, pcBound1, pcBound2, pnStartingAt, pCaseSensitive)

		def FindNextSubStringBetweenSCSIBZ(pcSubStr, pcBound1, pcBound2, pnStartingAt, pCaseSensitive)
			return This.FindNextSubStringBetweenCSIB(pcSubStr, pcBound1, pcBound2, pnStartingAt, pCaseSensitive)

		#--

		def FindNextSubStringBoundedByCSIB(pcSubStr, pacBounds, pnStartingAt, pCaseSensitive)
			return This.FindNextNthSubStringBoundedByCSIB(1, pcSubStr, pacBounds, pnStartingAt, pCaseSensitive)

		def FindNextSubStringBoundedByCSIBZ(pcSubStr, pacBounds, pnStartingAt, pCaseSensitive)
			return This.FindNextSubStringBoundedByCSIB(pcSubStr, pacBounds, pnStartingAt, pCaseSensitive)

		def FindNextSubStringBoundedBySCSIB(pcSubStr, pacBounds, pnStartingAt, pCaseSensitive)
			return This.FindNextNthSubStringBoundedByCSIB(1, pcSubStr, pacBounds, pnStartingAt, pCaseSensitive)

		def FindNextSubStringBoundedBySCSIBZ(pcSubStr, pacBounds, pnStartingAt, pCaseSensitive)
			return This.FindNextSubStringBoundedByCSIB(pcSubStr, pacBounds, pnStartingAt, pCaseSensitive)

		#--

		def NextSubStringCSIB(pcSubStr, pcBound1, pcBound2, pnStartingAt, pCaseSensitive)
			return This.FindNextSubStringBetweenCSIB(pcSubStr, pcBound1, pcBound2, pnStartingAt, pCaseSensitive)

		def NextSubStringBoundedByCSIB(pcSubStr, pcBound1, pcBound2, pnStartingAt, pCaseSensitive)
			return This.FindNextSubStringBoundedByCSIB(pcSubStr, pacBounds, pnStartingAt, pCaseSensitive)

		def NextSubStringSCSIB(pcSubStr, pcBound1, pcBound2, pnStartingAt, pCaseSensitive)
			return This.FindNextSubStringBetweenCSIB(pcSubStr, pcBound1, pcBound2, pnStartingAt, pCaseSensitive)

		def NextSubStringBoundedBySCSIB(pcSubStr, pcBound1, pcBound2, pnStartingAt, pCaseSensitive)
			return This.FindNextSubStringBoundedByCSIB(pcSubStr, pacBounds, pnStartingAt, pCaseSensitive)

		#>

	#-- WITHOUT CASESENSITIVITY

	def FindNextSubStringBetweenIB(pcSubStr, pcBound1, pcBound2, pnStartingAt)
		return This.FindNextSubStringBetweenCSIB(pcSubStr, pcBound1, pcBound2, pnStartingAt, TRUE)

		#< @FunctionAlternativeForms

		def FindNextSubStringBetweenSIB(pcSubStr, pcBound1, pcBound2, pnStartingAt)
			return This.FindNextSubStringBetweenIB(pcSubStr, pcBound1, pcBound2, pnStartingAt)

		def FindNextSubStringBetweenIBZ(pcSubStr, pcBound1, pcBound2, pnStartingAt)
			return This.FindNextSubStringBetweenIB(pcSubStr, pcBound1, pcBound2, pnStartingAt)

		def FindNextSubStringBetweenSIBZ(pcSubStr, pcBound1, pcBound2, pnStartingAt)
			return This.FindNextSubStringBetweenIB(pcSubStr, pcBound1, pcBound2, pnStartingAt)

		#--

		def FindNextSubStringBoundedByIB(pcSubStr, pacBounds, pnStartingAt)
			return This.FindNextNthSubStringBoundedByIB(1, pcSubStr, pacBounds, pnStartingAt)

		def FindNextSubStringBoundedByZIB(pcSubStr, pacBounds, pnStartingAt)
			return This.FindNextSubStringBoundedByIB(pcSubStr, pacBounds, pnStartingAt)

		def FindNextSubStringBoundedBySIB(pcSubStr, pacBounds, pnStartingAt)
			return This.FindNextNthSubStringBoundedByIB(1, pcSubStr, pacBounds, pnStartingAt)

		def FindNextSubStringBoundedBySIBZ(pcSubStr, pacBounds, pnStartingAt)
			return This.FindNextSubStringBoundedByIB(pcSubStr, pacBounds, pnStartingAt)

		#--

		def NextSubStringIB(pcSubStr, pcBound1, pcBound2, pnStartingAt)
			return This.FindNextSubStringBetweenIB(pcSubStr, pcBound1, pcBound2, pnStartingAt)

		def NextSubStringBoundedByIB(pcSubStr, pcBound1, pcBound2, pnStartingAt)
			return This.FindNextSubStringBoundedByIB(pcSubStr, pacBounds, pnStartingAt)

		def NextSubStringSIB(pcSubStr, pcBound1, pcBound2, pnStartingAt)
			return This.FindNextSubStringBetweenIB(pcSubStr, pcBound1, pcBound2, pnStartingAt)

		def NextSubStringBoundedBySIB(pcSubStr, pcBound1, pcBound2, pnStartingAt)
			return This.FindNextSubStringBoundedByIB(pcSubStr, pacBounds, pnStartingAt)

		#>

	  #-----------------------------------------------------------------------------------------------------#
	 #  GETTING SUBSTRING AND ITS NEXT NTH OCCURRENCE BETWEEN TWO SUBSTRINGS STARTING AT A GIVEN POSITION  #
	#-----------------------------------------------------------------------------------------------------#

	def NextSubStringBetweenCSIBZ(pcSubStr, pcBound1, pcBound2, pnStartingAt, pCaseSensitive)
		aResult = [ pcSubStr, This.FindNextSubStringBetweenCSIB(pcSubStr, pcBound1, pcBound2, pnStartingAt, pCaseSensitive) ]
		return aResult

		#< @FunctionAlternativeForms

		def NextSubStringBetweenSCSIBZ(pcSubStr, pcBound1, pcBound2, pnStartingAt, pCaseSensitive)
			return This.NextSubStringBetweenCSIBZ(pcSubStr, pcBound1, pcBound2, pnStartingAt, pCaseSensitive)

		def NextSubStringBoundedByCSIBZ(pcSubStr, pacBounds, pnStartingAt, pCaseSensitive)
			if isString(pacBounds)
				return This.NextSubStringBetweenCSIBZ(pcSubStr, pacBounds, pacBounds, pnStartingAt, pCaseSensitive)

			but isList(pacBounds) and Q(pacBounds).IsPairOfStrings()
				return This.NextSubStringBetweenCSIBZ(pcSubStr, pacBounds[1], pacBounds[2], pnStartingAt, pCaseSensitive)

			else
				StzRaise("Incorrect param type! pacBounds must be a string or pair of strings.")
			ok

		def NextSubStringBoundedBySCSIBZ(pcSubStr, pacBounds, pnStartingAt, pCaseSensitive)
			return This.NextSubStringBoundedByCSIBZ(pcSubStr, pacBounds, pnStartingAt, pCaseSensitive)

		#>

	#-- WITHOUT CASESENSITIVITY

	def NextSubStringBetweenIBZ(pcSubStr, pcBound1, pcBound2, pnStartingAt)
		return This.NextNthSubStringBetweenCSIBZ(pcSubStr, pcBound1, pcBound2, pnStartingAt, TRUE)

		#< @FunctionAlternativeForms

		def NextSubStringBetweenSIBZ(pcSubStr, pcBound1, pcBound2, pnStartingAt)
			return This.NextSubStringBetweenIBZ(pcSubStr, pcBound1, pcBound2, pnStartingAt)

		def NextSubStringBoundedBySIBZ(pcSubStr, pacBounds, pnStartingAt)
			return This.NextSubStringBoundedBySCSIBZ(pcSubStr, pacBounds, pnStartingAt, TRUE)

		#>

	  #=========================================================================================================#
	 #  FINDING NTH PREVIOUS OCCURRENCE OF A SUBSTRING BOUNDED BY TWO SUBSTRINGS STARTING AT A GIVEN POSITION  #
	#=========================================================================================================#

	def FindPreviousNthSubStringBetweenCSIB(n, pcSubStr, pcBound1, pcBound2, pnStartingAt, pCaseSensitive)

		nPos = This.FindPreviousNthSubStringBetweenCS(n, pcSubStr, pcBound1, pcBound2, pnStartingAt, pCaseSensitive)
		nResult = nPos + Q(pcBound1).NumberOfChars()

		return nResult

		#< @FunctionAlternativeForms

		def FindNthPreviousSubStringBetweenCSIB(n, pcSubStr, pcBound1, pcBound2, pnStartingAt, pCaseSensitive)
			return This.FindPreviousNthSubStringBetweenCSIB(n, pcSubStr, pcBound1, pcBound2, pnStartingAt, pCaseSensitive)

		def FindNthPreviousSubStringBetweenCSIBZ(n, pcSubStr, pcBound1, pcBound2, pnStartingAt, pCaseSensitive)
			return This.FindPreviousNthSubStringBetweenCSIB(n, pcSubStr, pcBound1, pcBound2, pnStartingAt, pCaseSensitive)

		def FindPreviousNthSubStringBetweenCSIBZ(n, pcSubStr, pcBound1, pcBound2, pnStartingAt, pCaseSensitive)
			return This.FindPreviousNthSubStringBetweenCSIB(n, pcSubStr, pcBound1, pcBound2, pnStartingAt, pCaseSensitive)

		#--

		def FindPreviousNthSubStringBoundedByCSIB(n, pcSubStr, pacBounds, pnStartingAt, pCaseSensitive)
			if isString(pacBounds)
				return This.FindPreviousNthSubStringBetweenCSIB(n, pcSubStr, pacBounds, pacBounds, pnStartingAt, pCaseSensitive)

			but isList(pacBounds) and Q(pacBounds).IsPairOfStrings()
				return This.FindPreviousNthSubStringBetweenCSIB(n, pcSubStr, pacBounds, pacBounds, pnStartingAt, pCaseSensitive)

			else
				StzRaise("Incorrect param type! pacBounds must be a string or pair of strings.")
			ok

			return This.FindPreviousNthSubStringBetweenCSIB(n, pcSubStr, pcBound1, pcBound2, pnStartingAt, pCaseSensitive)

		def FindNthPreviousSubStringBoundedByCSIB(n, pcSubStr, pacBounds, pnStartingAt, pCaseSensitive)
			return This.FindPreviousNthSubStringBoundedByCSIB(n, pcSubStr, pacBounds, pnStartingAt, pCaseSensitive)

		def FindPreviousNthSubStringBoundedByCSIBZ(n, pcSubStr, pacBounds, pnStartingAt, pCaseSensitive)
			return This.FindPreviousNthSubStringBoundedByCSIB(n, pcSubStr, pacBounds, pnStartingAt, pCaseSensitive)

		def FindNthPreviousSubStringBoundedByCSIBZ(n, pcSubStr, pacBounds, pnStartingAt, pCaseSensitive)
			return This.FindPreviousNthSubStringBoundedByCSIB(n, pcSubStr, pacBounds, pnStartingAt, pCaseSensitive)

		#==

		def PreviousNthSubStringSCSIB(n, pcSubStr, pcBound1, pcBound2, pnStartingAt, pCaseSensitive)
			return This.FindPreviousNthSubStringBetweenCSIB(n, pcSubStr, pcBound1, pcBound2, pnStartingAt, pCaseSensitive)

		def NthPreviousSubStringSCSIB(n, pcSubStr, pcBound1, pcBound2, pnStartingAt, pCaseSensitive)
			return This.FindPreviousNthSubStringBetweenCSIB(n, pcSubStr, pcBound1, pcBound2, pnStartingAt, pCaseSensitive)

		def PreviousNthSubStringSCSIBZ(n, pcSubStr, pcBound1, pcBound2, pnStartingAt, pCaseSensitive)
			return This.FindPreviousNthSubStringBetweenCSIB(n, pcSubStr, pcBound1, pcBound2, pnStartingAt, pCaseSensitive)

		def NthPreviousSubStringSCSIBZ(n, pcSubStr, pcBound1, pcBound2, pnStartingAt, pCaseSensitive)
			return This.FindPreviousNthSubStringBetweenCSIB(n, pcSubStr, pcBound1, pcBound2, pnStartingAt, pCaseSensitive)

		#--

		def PreviousNthSubStringBoundedBySCSIB(n, pcSubStr, pcBound1, pcBound2, pnStartingAt, pCaseSensitive)
			return This.FindPreviousNthSubStringBoundedByCSIB(n, pcSubStr, pacBounds, pnStartingAt, pCaseSensitive)

		def NthPreviousSubStringBoundedBySCSIB(n, pcSubStr, pcBound1, pcBound2, pnStartingAt, pCaseSensitive)
			return This.FindPreviousNthSubStringBoundedByCSIB(n, pcSubStr, pacBounds, pnStartingAt, pCaseSensitive)

		def PreviousNthSubStringBoundedBySCSIBZ(n, pcSubStr, pcBound1, pcBound2, pnStartingAt, pCaseSensitive)
			return This.FindPreviousNthSubStringBoundedByCSIB(n, pcSubStr, pacBounds, pnStartingAt, pCaseSensitive)

		def NthPreviousSubStringBoundedBySCSIBZ(n, pcSubStr, pcBound1, pcBound2, pnStartingAt, pCaseSensitive)
			return This.FindPreviousNthSubStringBoundedByCSIB(n, pcSubStr, pacBounds, pnStartingAt, pCaseSensitive)

		#>

	#-- WITHOUT CASESENSITIVITY

	def FindPreviousNthSubStringBetweenIB(n, pcSubStr, pcBound1, pcBound2, pnStartingAt)
		return This.FindPreviousNthSubStringBetweenCSIB(n, pcSubStr, pcBound1, pcBound2, pnStartingAt, TRUE)

		#< @FunctionAlternativeForms

		def FindNthPreviousSubStringBetweenIB(n, pcSubStr, pcBound1, pcBound2, pnStartingAt)
			return This.FindPreviousNthSubStringBetweenIB(n, pcSubStr, pcBound1, pcBound2, pnStartingAt)

		def FindNthPreviousSubStringBetweenIBZ(n, pcSubStr, pcBound1, pcBound2, pnStartingAt, pCaseSensitive)
			return This.FindPreviousNthSubStringBetweenIB(n, pcSubStr, pcBound1, pcBound2, pnStartingAt)

		def FindPreviousNthSubStringBetweenIBZ(n, pcSubStr, pcBound1, pcBound2, pnStartingAt, pCaseSensitive)
			return This.FindPreviousNthSubStringBetweenIB(n, pcSubStr, pcBound1, pcBound2, pnStartingAt)

		#--

		def FindPreviousNthSubStringBoundedByIB(n, pcSubStr, pacBounds, pnStartingAt)
			return This.FindPreviousNthSubStringBoundedByCSIB(n, pcSubStr, pacBounds, pnStartingAt, TRUE)

		def FindNthPreviousSubStringBoundedByIB(n, pcSubStr, pacBounds, pnStartingAt, pCaseSensitive)
			return This.FindPreviousNthSubStringBoundedByIB(n, pcSubStr, pacBounds, pnStartingAt)

		def FindPreviousNthSubStringBoundedByZIB(n, pcSubStr, pacBounds, pnStartingAt, pCaseSensitive)
			return This.FindPreviousNthSubStringBoundedByIB(n, pcSubStr, pacBounds, pnStartingAt)

		def FindNthPreviousSubStringBoundedByZIB(n, pcSubStr, pacBounds, pnStartingAt, pCaseSensitive)
			return This.FindPreviousNthSubStringBoundedByIB(n, pcSubStr, pacBounds, pnStartingAt)

		#==

		def PreviousNthSubStringSIB(n, pcSubStr, pcBound1, pcBound2, pnStartingAt, pCaseSensitive)
			return This.FindPreviousNthSubStringBetweenIB(n, pcSubStr, pcBound1, pcBound2, pnStartingAt)

		def NthPreviousSubStringSIB(n, pcSubStr, pcBound1, pcBound2, pnStartingAt, pCaseSensitive)
			return This.FindPreviousNthSubStringBetweenIB(n, pcSubStr, pcBound1, pcBound2, pnStartingAt)

		def PreviousNthSubStringSZIB(n, pcSubStr, pcBound1, pcBound2, pnStartingAt, pCaseSensitive)
			return This.FindPreviousNthSubStringBetweenIB(n, pcSubStr, pcBound1, pcBound2, pnStartingAt)

		def NthPreviousSubStringSZIB(n, pcSubStr, pcBound1, pcBound2, pnStartingAt, pCaseSensitive)
			return This.FindPreviousNthSubStringBetweenIB(n, pcSubStr, pcBound1, pcBound2, pnStartingAt)

		#--

		def PreviousNthSubStringBoundedBySIB(n, pcSubStr, pcBound1, pcBound2, pnStartingAt, pCaseSensitive)
			return This.FindPreviousNthSubStringBoundedByIB(n, pcSubStr, pacBounds, pnStartingAt)

		def NthPreviousSubStringBoundedBySIB(n, pcSubStr, pcBound1, pcBound2, pnStartingAt, pCaseSensitive)
			return This.FindPreviousNthSubStringBoundedByIB(n, pcSubStr, pacBounds, pnStartingAt)

		def PreviousNthSubStringBoundedBySIBZ(n, pcSubStr, pcBound1, pcBound2, pnStartingAt, pCaseSensitive)
			return This.FindPreviousNthSubStringBoundedByIB(n, pcSubStr, pacBounds, pnStartingAt)

		def NthPreviousSubStringBoundedBySIBZ(n, pcSubStr, pcBound1, pcBound2, pnStartingAt, pCaseSensitive)
			return This.FindPreviousNthSubStringBoundedByIB(n, pcSubStr, pacBounds, pnStartingAt)

		#>

	  #------------------------------------------------------------------------------------------------------#
	 #  FINDING PREVIOUS OCCURRENCE OF A SUBSTRING BOUNDED BY TWO SUBSTRINGS  STARTING AT A GIVEN POSITION  #
	#======================================================================================================#

	def FindPreviousSubStringBetweenCSIB(pcSubStr, pcBound1, pcBound2, pnStartingAt, pCaseSensitive)
		return This.FindNthSubStringBetweenCSIB(1, pcSubStr, pcBound1, pcBound2, pnStartingAt, pCaseSensitive)

		#< @FunctionAlternativeForms

		def FindPreviousSubStringBetweenCSIBZ(pcSubStr, pcBound1, pcBound2, pnStartingAt, pCaseSensitive)
			return This.FindPreviousSubStringBetweenCSIB(pcSubStr, pcBound1, pcBound2, pnStartingAt, pCaseSensitive)

		#--

		def FindPreviousSubStringBoundedByCSIB(pcSubStr, pacBounds, pnStartingAt, pCaseSensitive)
			return This.FindPreviousNthSubStringBoundedByCSIB(1, pcSubStr, pacBounds, pnStartingAt, pCaseSensitive)

		def FindPreviousSubStringBoundedByCSIBZ(pcSubStr, pacBounds, pnStartingAt, pCaseSensitive)
			return This.FindPreviousSubStringBoundedByCSIB(pcSubStr, pacBounds, pnStartingAt, pCaseSensitive)

		#==

		def PreviousSubStringSCSIB(pcSubStr, pcBound1, pcBound2, pnStartingAt, pCaseSensitive)
			return This.FindPreviousSubStringBetweenCSIB(pcSubStr, pcBound1, pcBound2, pnStartingAt, pCaseSensitive)

		def PreviousSubStringBoundedBySCSIB(pcSubStr, pcBound1, pcBound2, pnStartingAt, pCaseSensitive)
			return This.FindPreviousSubStringBoundedByCSIB(pcSubStr, pacBounds, pnStartingAt, pCaseSensitive)

		#>

	#-- WITHOUT CASESENSITIVITY

	def FindPreviousSubStringBetweenIB(pcSubStr, pcBound1, pcBound2, pnStartingAt)
		return This.FindPreviousSubStringBetweenCSIB(pcSubStr, pcBound1, pcBound2, pnStartingAt, TRUE)

		#< @FunctionAlternativeForms

		def FindPreviousSubStringBetweenIBZ(pcSubStr, pcBound1, pcBound2, pnStartingAt, pCaseSensitive)
			return This.FindPreviousSubStringBetweenIB(pcSubStr, pcBound1, pcBound2, pnStartingAt)

		#--

		def FindPreviousSubStringBoundedByIB(pcSubStr, pacBounds, pnStartingAt)
			return This.FindPreviousSubStringBoundedByCSIB(pcSubStr, pacBounds, pnStartingAt, TRUE)

		def FindPreviousSubStringBoundedByZIB(pcSubStr, pacBounds, pnStartingAt, pCaseSensitive)
			return This.FindPreviousSubStringBoundedByIB(pcSubStr, pacBounds, pnStartingAt)

		#==

		def PreviousSubStringBetweenSIB(pcSubStr, pcBound1, pcBound2, pnStartingAt, pCaseSensitive)
			return This.FindPreviousSubStringBetweenIB(pcSubStr, pcBound1, pcBound2, pnStartingAt)

		def PreviousSubStringBoundedBySIB(pcSubStr, pcBound1, pcBound2, pnStartingAt, pCaseSensitive)
			return This.FindPreviousSubStringBoundedByIB(pcSubStr, pacBounds, pnStartingAt)

		#>

	   #----------------------------------------------------------------------------------#
	  #  GETTING THE SUBSTRING AND ITS PREVIOUS OCCURRENCE BETWEEN TWO GIVEN SUBSTRINGS  #
	 #  STARTING AT A GIVEN POSITION AND INCLUDING BOUNDS IN THE RESULT                 #
	#----------------------------------------------------------------------------------#

	def PreviousSubStringBetweenSCSIBZ(pcSubStr, pcBound1, pcBound2, pnStartingAt, pCaseSensitive)
		aResult = [ pcSubStr, This.FindPreviousSubStringBetweenSCSIBZ(pcSubStr, pcBound1, pcBound2, pnStartingAt, pCaseSensitive) ]
		return aResult

		def PreviousSubStringBoundedBySCSIBZ(pcSubStr, pcBound1, pcBound2, pnStartingAt, pCaseSensitive)
			if isString(pacBounds)
				return This.PreviousSubStringBetweenSCSIBZ(pcSubStr, pacBounds, pacBounds, pnStartingAt, pCaseSensitive)

			but isList(pacBounds) and Q(pacBounds).IsPairOfStrings()
				return This.PreviousSubStringBetweenSCSIBZ(pcSubStr, pacBounds[1], pacBounds[2], pnStartingAt, pCaseSensitive)

			else
				Raise("Incorrect param type! pacBounds must be a string or pair of strings.")
			ok

	#-- WITHOUT CASESENSITIVITY

	def PreviousSubStringBetweenSIBZ(pcSubStr, pcBound1, pcBound2, pnStartingAt, pCaseSensitive)
		return This.PreviousSubStringBetweenSCSIBZ(pcSubStr, pcBound1, pcBound2, pnStartingAt, TRUE)

		def PreviousSubStringBoundedBySIBZ(pcSubStr, pcBound1, pcBound2, pnStartingAt)
			return This.PreviousSubStringBoundedBySCSIBZ(pcSubStr, pcBound1, pcBound2, pnStartingAt, pCaseSensitive)

	  #===================================================================#
	 #  FINDING NTH OCCURRENCE OF A SUBSTRING BOUNDED BY TWO SUBSTRINGS  #
	#===================================================================#

	def FindNthSubStringBetweenCS(n, pcSubStr, pcBound1, pcBound2, pCaseSensitive)
		nResult = this.FindNthSubStringBetweenSCS(n, pcSubStr, pcBound1, pcBound2, 1, pCaseSensitive)
		return nResult

		#< @FunctionAlternativeForms

		def FindNthSubStringBoundedByCS(n, pcSubStr, pacBounds, pCaseSensitive)
			if isString(pacBounds)
				return This.FindNthSubStringBetweenCS(n, pcSubStr, pacBounds, pacBounds, pCaseSensitive)

			but isList(pacBounds) and Q(pacBounds).IsPairOfStrings()
				return TThis.FindNthSubStringBetweenCS(n, pcSubStr, pacBounds[1], pacBounds[2], pCaseSensitive)

			else
				StzRaise("Incorrect param type! pacBounds must be a string or pair of strings.")
			ok

		#--
	
		def FindNthSubStringBetweenCSZ(n, pcSubStr, pcBound1, pcBound2, pCaseSensitive)
			return This.FindNthSubStringBetweenCS(n, pcSubStr, pcBound1, pcBound2, pCaseSensitive)

		def FindNthSubStringBoundedByCSZ(n, pcSubStr, pacBounds, pCaseSensitive)
			return This.FindNthSubStringBoundedByCS(n, pcSubStr, pacBound, pCaseSensitives)

		#==

		def NthSubStringBetweenCS(n, pcSubStr, pcBound1, pcBound2, pCaseSensitive)
			return This.FindNthSubStringBetweenCS(n, pcSubStr, pcBound1, pcBound2, pCaseSensitive)

		def NthSubStringBoundedByCS(n, pcSubStr, pacBounds, pCaseSensitive)
			return This.FindNthSubStringBoundedByCS(n, pcSubStr, pacBounds, pCaseSensitive)
	
		#>

	#-- WITHOUT CASESENSITIVE

	def FindNthSubStringSubStringBetween(n, pcSubStr, pcBound1, pcBound2)
		return This.FindNthSubStringSubStringBetweenCS(n, pcSubStr, pcBound1, pcBound1, TRUE)

		#< @FunctionAlternativeForms

		def FindNthSubStringBoundedBy(n, pcSubStr, pacBounds)
			return This.FindNthSubStringBoundedByCS(n, pcSubStr, pacBounds, TRUE)

		#--
	
		def FindNthSubStringBetweenZ(n, pcSubStr, pcBound1, pcBound2)
			return This.FindNthSubStringBetween(n, pcSubStr, pcBound1, pcBound2)

		def FindNthSubStringBoundedByZ(n, pcSubStr, pacBounds)
			return This.FindNthSubStringBoundedBy(n, pcSubStr, pacBounds)

		#==

		def NthSubStringBetween(n, pcSubStr, pcBound1, pcBound2)
			return This.FindNthSubStringBetween(n, pcSubStr, pcBound1, pcBound2)

		def NthSubStringBoundedBy(n, pcSubStr, pacBounds)
			return This.FindNthSubStringBoundedBy(n, pcSubStr, pacBounds)

		#>

	  #----------------------------------------------------------------------------------------------#
	 #  GETTING THE SUBSTRING WITH THE POSITION OF ITS NTH OCCURRENCE BETWEEN TWO GIVEN SUBSTRINGS  #
	#----------------------------------------------------------------------------------------------#

	def NthSubStringBetweenCSZ(n, pcSubStr, pcBound1, pcBound2, pCaseSensitive)
		aResult = [ pcSubStr, This.FindNthSubStringBetweenCS(n, pcSubStr, pcBound1, pcBound2, pCaseSensitive) ]
		return aResult

		#< @FunctionAlternativeForm

		def NthSubStringBoundedByCSZ(n, pcSubStr, pacBounds, pCaseSensitive)
			if isString(pacBounds)
				return This.NthSubStringBetweenCSZ(n, pcSubStr, pacBounds, pacBounds, pCaseSensitive)

			but isList(pacBounds) and Q(pacBounds).IsPairOfStrings()
				return This.NthSubStringBetweenCSZ(n, pcSubStr, pacBounds[1], pacBounds[2], pCaseSensitive)
			else
				StzRaise("Incorrect param type! pacBounds must ba a string or pair of strings.")

			ok

		#>
				
	  #---------------------------------------------------------------------#
	 #  FINDING FIRST OCCURRENCE OF A SUBSTRING BOUNDED BY TWO SUBSTRINGS  #
	#=====================================================================#

	def FindFirstSubStringBetweenCS(pcSubStr, pcBound1, pcBound2, pCaseSensitive)
		return This.FindNthSubStringBetweenCS(1, pcSubStr, pcBound1, pcBound2, pCaseSensitive)

		#< @FunctionAlternativeForms

		def FindFirstSubStringBoundedByCS(pcSubStr, pacBounds, pCaseSensitive)
			return This.FindNthSubStringBoundedByCS(1, pcSubStr, pacBounds, pCaseSensitive)

		#--
	
		def FindFirstSubStringBetweenCSZ(pcSubStr, pcBound1, pcBound2, pCaseSensitive)
			return This.FindFirstSubStringBetweenCS(pcSubStr, pcBound1, pcBound2, pCaseSensitive)

		def FindFirstSubStringBoundedByCSZ(pcSubStr, pacBounds, pCaseSensitive)
			return This.FindFirstSubStringBoundedByCS(pcSubStr, pacBound, pCaseSensitives)

		#==

		def FirstSubStringBetweenCS(pcSubStr, pcBound1, pcBound2, pCaseSensitive)
			return This.FindFirstSubStringBetweenCS(pcSubStr, pcBound1, pcBound2, pCaseSensitive)

		def FirstSubStringBoundedByCS(pcSubStr, pacBounds, pCaseSensitive)
			return This.FindFirstSubStringBoundedByCS(pcSubStr, pacBounds, pCaseSensitive)
	
		#>

	#-- WITHOUT CASESENSITIVE

	def FindFirstSubStringSubStringBetween(pcSubStr, pcBound1, pcBound2)
		return This.FindFirstSubStringSubStringBetweenCS(pcSubStr, pcBound1, pcBound1, TRUE)

		#< @FunctionAlternativeForms

		def FindFirstSubStringBoundedBy(pcSubStr, pacBounds)
			return This.FindFirstSubStringBoundedByCS(pcSubStr, pacBounds, TRUE)

		#--
	
		def FindFirstSubStringBetweenZ(pcSubStr, pcBound1, pcBound2)
			return This.FindFirstSubStringBetween(pcSubStr, pcBound1, pcBound2)

		def FindFirstSubStringBoundedByZ(pcSubStr, pacBounds)
			return This.FindFirstSubStringBoundedBy(pcSubStr, pacBounds)

		#==

		def FirstSubStringBetween(pcSubStr, pcBound1, pcBound2)
			return This.FindFirstSubStringBetween(pcSubStr, pcBound1, pcBound2)

		def FirstSubStringBoundedBy(pcSubStr, pacBounds)
			return This.FindFirstSubStringBoundedBy(pcSubStr, pacBounds)
	
		#>

	  #------------------------------------------------------------------------------------------------#
	 #  GETTING THE SUBSTRING WITH THE POSITION OF ITS FIRST OCCURRENCE BETWEEN TWO GIVEN SUBSTRINGS  #
	#------------------------------------------------------------------------------------------------#

	def FirstSubStringBetweenCSZ(pcSubStr, pcBound1, pcBound2, pCaseSensitive)
		aResult = [ pcSubStr, This.FindFirstSubStringBetweenCS(pcSubStr, pcBound1, pcBound2, pCaseSensitive) ]
		return aResult

		#< @FunctionAlternativeForm

		def FirstSubStringBoundedByCSZ(pcSubStr, pacBounds, pCaseSensitive)
			if isString(pacBounds)
				return This.FirstSubStringBetweenCSZ(pcSubStr, pacBounds, pacBounds, pCaseSensitive)

			but isList(pacBounds) and Q(pacBounds).IsPairOfStrings()
				return This.FirstSubStringBetweenCSZ(pcSubStr, pacBounds[1], pacBounds[2], pCaseSensitive)
			else
				StzRaise("Incorrect param type! pacBounds must ba a string or pair of strings.")

			ok

		#>

	  #--------------------------------------------------------------------#
	 #  FINDING LAST OCCURRENCE OF A SUBSTRING BOUNDED BY TWO SUBSTRINGS  #
	#====================================================================#

	def FindLastSubStringBetweenCS(pcSubStr, pcBound1, pcBound2, pCaseSensitive) # TODO: check performance!
		nLast = This.NumberOfOccurrenceOfSubStringBetweenCS(pcSubStr, pcBound1, pcBound2, pCaseSensitive)
		return This.FindNthSubStringBetweenCS(nLast, pcSubStr, pcBound1, pcBound2, pCaseSensitive)

		#< @FunctionAlternativeForms

		def FindLastSubStringBoundedByCS(pcSubStr, pacBounds, pCaseSensitive)
			if isString(pacBounds)
				return This.FindLastSubStringBetweenCS(pcSubStr, pacBounds, pacBounds, pCaseSensitive)

			but isList(pacBounds) and Q(pacBounds).IsPairOfStrings()
				return TThis.FindLastSubStringBetweenCS(pcSubStr, pacBounds[1], pacBounds[2], pCaseSensitive)

			else
				StzRaise("Incorrect param type! pacBounds must be a string or pair of strings.")
			ok

		#--
	
		def FindLastSubStringBetweenCSZ(pcSubStr, pcBound1, pcBound2, pCaseSensitive)
			return This.FindLastSubStringBetweenCS(pcSubStr, pcBound1, pcBound2, pCaseSensitive)

		def FindLastSubStringBoundedByCSZ(pcSubStr, pacBounds, pCaseSensitive)
			return This.FindLastSubStringBoundedByCS(pcSubStr, pacBound, pCaseSensitives)

		#==

		def LastSubStringBetweenCS(pcSubStr, pcBound1, pcBound2, pCaseSensitive)
			return This.FindLastSubStringBetweenCS(pcSubStr, pcBound1, pcBound2, pCaseSensitive)

		def LastSubStringBoundedByCS(pcSubStr, pacBounds, pCaseSensitive)
			return This.FindLastSubStringBoundedByCS(pcSubStr, pacBounds, pCaseSensitive)
	
		#>

	#-- WITHOUT CASESENSITIVE

	def FindLastSubStringSubStringBetween(pcSubStr, pcBound1, pcBound2)
		return This.FindLastSubStringSubStringBetweenCS(pcSubStr, pcBound1, pcBound1, TRUE)

		#< @FunctionAlternativeForms

		def FindLastSubStringBoundedBy(pcSubStr, pacBounds)
			return This.FindLastSubStringBoundedByCS(pcSubStr, pacBounds, TRUE)

		#--
	
		def FindLastSubStringBetweenZ(pcSubStr, pcBound1, pcBound2)
			return This.FindLastSubStringBetween(pcSubStr, pcBound1, pcBound2)

		def FindLastSubStringBoundedByZ(pcSubStr, pacBounds)
			return This.FindLastSubStringBoundedBy(pcSubStr, pacBounds)

		#==

		def LastSubStringBetween(pcSubStr, pcBound1, pcBound2)
			return This.FindLastSubStringBetween(pcSubStr, pcBound1, pcBound2)

		def LastSubStringBoundedBy(pcSubStr, pacBounds)
			return This.FindLastSubStringBoundedBy(pcSubStr, pacBounds)
	
		#>

	  #------------------------------------------------------------------------------------------------#
	 #  GETTING THE SUBSTRING WITH THE POSITION OF ITS LAST OCCURRENCE BETWEEN TWO GIVEN SUBSTRINGS  #
	#------------------------------------------------------------------------------------------------#

	def LastSubStringBetweenCSZ(pcSubStr, pcBound1, pcBound2, pCaseSensitive)
		aResult = [ pcSubStr, This.FindLastSubStringBetweenCS(pcSubStr, pcBound1, pcBound2, pCaseSensitive) ]
		return aResult

		#< @FunctionAlternativeForm

		def LastSubStringBoundedByCSZ(pcSubStr, pacBounds, pCaseSensitive)
			if isString(pacBounds)
				return This.LastSubStringBetweenCSZ(pcSubStr, pacBounds, pacBounds, pCaseSensitive)

			but isList(pacBounds) and Q(pacBounds).IsPairOfStrings()
				return This.LastSubStringBetweenCSZ(pcSubStr, pacBounds[1], pacBounds[2], pCaseSensitive)
			else
				StzRaise("Incorrect param type! pacBounds must ba a string or pair of strings.")

			ok

		#>

	   #-------------------------------------------------------#
	  #  FINDING NTH OCCURRENCE OF A SUBSTRING BOUNDED BY     #
	 #  TWO OTHER SUBSTRINGS AND RETURNING THEM AS SECTIONS  #
	#=======================================================#

	def FindNthSubStringBetweenCSZZ(n, pcSubStr, pcBound1, pcBound2, pCaseSensitive)
		nPos = This.FindNthSubStringBetweenCS(n, pcSubStr, pcBound1, pcBound2, pCaseSensitive)
		nLenBound1 = Q(pcBound1).NumberOfChars()

		aResult = [ nPos, nPos + nLenBound1 - 1 ]

		return aResult

		#< @FunctionAlternativeForms

		def FindNthSubStringBoundedByCSZZ(n, pcSubStr, pacBounds, pCaseSensitive)
			if isString(pacBounds)
				return This.FindNthSubStringBetweenCSZZ(n, pcSubStr, pcBounds, pcBounds, pCaseSensitive)

			but isList(pacBounds) and Q(pacBounds).IsPairOfStrings()
				return This.FindNthSubStringBetweenCSZZ(n, pcSubStr, pcBounds[1], pcBounds[2], pCaseSensitive)

			else
				StzRaise("Incorrect param type! pacBounds must be a string or pair of strings.")
			ok

		#--
	
		def FindNthSubStringBetweenAsSectionCS(n, pcSubStr, pcBound1, pcBound2, pCaseSensitive)
			return This.FindNthSubStringBetweenCSZZ(n, pcSubStr, pcBound1, pcBound2, pCaseSensitive)

		def FindNthSubStringBoundedByAsSectionCS(n, pcSubStr, pacBounds, pCaseSensitive)
			return This.FindNthSubStringBoundedByCSZZ(n, pcSubStr, pacBounds, pCaseSensitive)

		#==

		def NthSubStringBetweenAsSectionCS(n, pcSubStr, pcBound1, pcBound2, pCaseSensitive)
			return This.FindNthSubStringBetweenCSZZ(n, pcSubStr, pcBound1, pcBound2, pCaseSensitive)

		def NthSubStringBoundedByAsSectionCS(n, pcSubStr, pacBounds, pCaseSensitive)
			return This.FindNthSubStringBoundedByCSZZ(n, pcSubStr, pacBounds, pCaseSensitive)

		#>

	#-- WITHOUT CASESENSITIVITY

	def FindNthSubStringBetweenZZ(n, pcSubStr, pcBound1, pcBound2)
		return This.FindNthSubStringBetweenCSZZ(n, pcSubStr, pcBound1, pcBound2, TRUE)

		#< @FunctionAlternativeForms

		def FindNthSubStringBoundedByZZ(n, pcSubStr, pacBounds)
			return This.FindNthSubStringBoundedByZZ(n, pcSubStr, pacBounds)

		#--
	
		def FindNthSubStringBetweenAsSection(n, pcSubStr, pcBound1, pcBound2)
			return This.FindNthSubStringBetweenZZ(n, pcSubStr, pcBound1, pcBound2)

		def FindNthSubStringBoundedByAsSection(n, pcSubStr, pacBounds)
			return This.FindNthSubStringBoundedByZZ(n, pcSubStr, pacBounds)

		#==

		def NthSubStringBetweenAsSection(n, pcSubStr, pcBound1, pcBound2)
			return This.FindNthSubStringBetweenZZ(n, pcSubStr, pcBound1, pcBound2)

		def NthSubStringBoundedByAsSection(n, pcSubStr, pacBounds)
			return This.FindNthSubStringBoundedByZZ(n, pcSubStr, pacBounds)

		#>

	  #-----------------------------------------------------------#
	 #  GETTING THE SUBSTRING AND ITS NTH OCCURRENCE AS SECTION  #
	#-----------------------------------------------------------#

	def NthSubStringBetweenCSZZ(n, pcSubStr, pcBound1, pcBound2, pCaseSensitive)
		aResult = [ pcSubStr, This.NthSubStringBetweenCSZZ(n, pcSubStr, pcBound1, pcBound2, pCaseSensitive) ]
		return aResult

		#< @FunctionAlternativeForm

		def NthSubStringBoundedByCSZZ(n, pcSubStr, pacBounds, pCaseSensitive)
			if isString(pacBounds)
				return This.NthSubStringBetweenCSZZ(n, pcSubStr, pacBounds, pacBounds, pCaseSensitive)

			but isList(pacBounds)
				return This.NthSubStringBetweenCSZZ(n, pcSubStr, pacBounds[1], pacBounds[2], pCaseSensitive)

			else
				StzRaise("Incorrect param type! pacBounds must be a string or pair of strings.")
			ok

		#--

		def NthSubStringBetweenAsSectionSCS(n, pcSubStr, pcBound1, pcBound2, pCaseSensitive)
			return This.NthSubStringBetweenCSZZ(n, pcSubStr, pcBound1, pcBound2, pCaseSensitive)

		def NthSubStringBoundedByAsSectionSCS(n, pcSubStr, pacBounds, pCaseSensitive)
			return This.NthSubStringBoundedByCSZZ(n, pcSubStr, pacBounds, pCaseSensitive)

		#>

	#-- WITHOUT CASESENSITIVITY

	def NthSubStringBetweenZZ(n, pcSubStr, pcBound1, pcBound2)
		return This.NthSubStringBetweenCSZZ(n, pcSubStr, pcBound1, pcBound2, TRUE)

		#< @FunctionAlternativeForm

		def NthSubStringBoundedByZZ(n, pcSubStr, pacBounds, pCaseSensitive)
			return This.NthSubStringBoundedByCSZZ(n, pcSubStr, pacBounds, TRUE)

		#--

		def NthSubStringBetweenAsSectionS(n, pcSubStr, pcBound1, pcBound2)
			return This.NthSubStringBetweenZZ(n, pcSubStr, pcBound1, pcBound2)

		def NthSubStringBoundedByAsSectionS(n, pcSubStr, pacBounds)
			return This.NthSubStringBoundedByZZ(n, pcSubStr, pacBounds)

		#>

	  #------------------------------------------------------------------------------------------#
	 #  FINDING NTH OCCURRENCE OF A SUBSTRING BOUNDED BY TWO OTHER SUBSTRINGS INCLUDING BOUNDS  #
	#==========================================================================================#

	def FindNthSubStringBetweenCSIB(n, pcSubStr, pcBound1, pcBound2, pCaseSensitive)
		nResult = This.FindNextNthSubStringBetweenCSIB(n, pcSubStr, pcBound1, pcBound2, 1, pCaseSensitive)
		return nResult

		#< @FunctionAlternativeForms

		def FindNthSubStringBoundedByCSIB(n, pcSubStr, pacBounds, pCaseSensitive)
			if isString(pacBounds)
				return This.FindNthSubStringBetweenCSIB(n, pcSubStr, pacBounds, pacBounds, pCaseSensitive)

			but isList(pacBounds) and Q(pacBounds).IsPairOfStrings()
				return TThis.FindNthSubStringBetweenCSIB(n, pcSubStr, pacBounds[1], pacBounds[2], pCaseSensitive)

			else
				StzRaise("Incorrect param type! pacBounds must be a string or pair of strings.")
			ok

		#--
	
		def FindNthSubStringBetweenCSIBZ(n, pcSubStr, pcBound1, pcBound2, pCaseSensitive)
			return This.FindNthSubStringBetweenCSIB(n, pcSubStr, pcBound1, pcBound2, pCaseSensitive)

		def FindNthSubStringBoundedByCSIBZ(n, pcSubStr, pacBounds, pCaseSensitive)
			return This.FindNthSubStringBoundedByCSIB(n, pcSubStr, pacBound, pCaseSensitives)

		#==

		def NthSubStringBetweenCSIB(n, pcSubStr, pcBound1, pcBound2, pCaseSensitive)
			return This.FindNthSubStringBetweenCSIB(n, pcSubStr, pcBound1, pcBound2, pCaseSensitive)

		def NthSubStringBoundedByCSIB(n, pcSubStr, pacBounds, pCaseSensitive)
			return This.FindNthSubStringBoundedByCSIB(n, pcSubStr, pacBounds, pCaseSensitive)
	
		#>

	#-- WITHOUT CASESENSITIVE

	def FindNthSubStringBetweenIB(n, pcSubStr, pcBound1, pcBound2)
		return This.FindNthSubStringBetweenCSIB(n, pcSubStr, pcBound1, pcBound2, TRUE)

		#< @FunctionAlternativeForms

		def FindNthSubStringBoundedByIB(n, pcSubStr, pacBounds)
			if isString(pacBounds)
				return This.FindNthSubStringBetweenIB(n, pcSubStr, pacBounds, pacBounds)

			but isList(pacBounds) and Q(pacBounds).IsPairOfStrings()
				return TThis.FindNthSubStringBetweenIB(n, pcSubStr, pacBounds[1], pacBounds[2])

			else
				StzRaise("Incorrect param type! pacBounds must be a string or pair of strings.")
			ok

		#--
	
		def FindNthSubStringBetweenZIB(n, pcSubStr, pcBound1, pcBound2)
			return This.FindNthSubStringBetweenIB(n, pcSubStr, pcBound1, pcBound2)

		def FindNthSubStringBoundedByZIB(n, pcSubStr, pacBounds)
			return This.FindNthSubStringBoundedByIB(n, pcSubStr, pacBounds)

		#==

		def NthSubStringBetweenIB(n, pcSubStr, pcBound1, pcBound2)
			return This.FindNthSubStringBetweenIB(n, pcSubStr, pcBound1, pcBound2)

		def NthSubStringBoundedByIB(n, pcSubStr, pacBounds)
			return This.FindNthSubStringBoundedByIB(n, pcSubStr, pacBounds)

		#>

	  #----------------------------------------------------------------------------------------------#
	 #  GETTING THE SUBSTRING AND ITS NTH OCCURRENCE BETWEEN TWO GIVEN SUBSTRINGS INCLUDING BOUNDS  #
	#----------------------------------------------------------------------------------------------#

	def NthSubStringBetweenCSIBZ(n, pcSubStr, pcBound1, pcBound2, pCaseSensitive)

		aResult = [ pcSubStr, This.NthSubStringBetweenCSIBZ(n, pcSubStr, pcBound1, pcBound2, pCaseSensitive) ]
		return aResult

		#< @FunctionAlternativeForm

		def NthSubStringBoundedByCSIBZ(n, pcSubStr, pacBounds, pCaseSensitive)
			if isString(pacBounds)
				return This.NthSubStringBetweenCSIBZ(n, pcSubStr, pacBounds, pacBounds, pCaseSensitive)

			but isList(pacBounds) and Q(pacBounds).IsPairOfStrings()
				return This.NthSubStringBetweenCSIBZ(n, pcSubStr, pacBounds[1], pacBounds[2], pCaseSensitive)

			else
				StzRaise("Incorrect param type! pacBounds must be a string or pair of strings.")
			ok

		#>

	#-- WITHOUT CASESENSITIVITY

	def NthSubStringBetweenIBZ(n, pcSubStr, pcBound1, pcBound2)
		return This.NthSubStringBetweenCSIBZ(n, pcSubStr, pcBound1, pcBound2, TRUE)

		#< @FunctionAlternativeForm

		def NthSubStringBoundedByIBZ(n, pcSubStr, pacBounds)
			return This.NthSubStringBoundedByCSIBZ(n, pcSubStr, pacBounds, TRUE)

		#>

	   #-------------------------------------------------------------------------#
	  #  FINDING NTH OCCURRENCE OF A SUBSTRING BOUNDED BY TWO OTHER             #
	 #  SUBSTRINGS INCLUDING BOUNDS AND RETURNING THEIR POSITIONS AS SECTIONS  #
	#=========================================================================#

	def FindNthSubStringBetweenCSIBZZ(n, pcSubStr, pcBound1, pcBound2, pCaseSensitive)
		nPos = This.FindNthSubStringBetweenCSIB(n, pcSubStr, pcBound1, pcBound2, pCaseSensitive)
		nLenBound1 = Q(pcBound1).NumberOfChars()

		aResult = [ pcSubStr, (nPos + nLenBound1 - 1) ]

		return aResult

		#< @FunctionAlternativeForms

		def FindNthSubStringBoundedByCSIBZZ(n, pcSubStr, pacBounds, pCaseSensitive)
			if isString(pacBounds)
				return This.FindNthSubStringBetweenCSIBZZ(n, pcSubStr, pcBounds, pcBounds, pCaseSensitive)

			but isList(pacBounds) and Q(pacBounds).IsPairOfStrings()
				return This.FindNthSubStringBetweenCSIBZZ(n, pcSubStr, pcBounds[1], pcBounds[2], pCaseSensitive)

			else
				StzRaise("Incorrect param type! pacBounds must be a string or pair of strings.")
			ok

		#--
	
		def FindNthSubStringBetweenAsSectionsCSIB(n, pcSubStr, pcBound1, pcBound2, pCaseSensitive)
			return This.FindNthSubStringBetweenCSIBZZ(n, pcSubStr, pcBound1, pcBound2, pCaseSensitive)

		def FindNthSubStringBoundedByAsSectionsCSIB(n, pcSubStr, pacBounds, pCaseSensitive)
			return This.FindNthSubStringBoundedByCSIBZZ(n, pcSubStr, pacBounds, pCaseSensitive)

		#==

		def NthSubStringBetweenAsSectionsCSIB(n, pcSubStr, pcBound1, pcBound2, pCaseSensitive)
			return This.FindNthSubStringBetweenCSIBZZ(n, pcSubStr, pcBound1, pcBound2, pCaseSensitive)

		def NthSubStringBoundedByAsSectionsCSIB(n, pcSubStr, pacBounds, pCaseSensitive)
			return This.FindNthSubStringBoundedByCSIBZZ(n, pcSubStr, pacBounds, pCaseSensitive)

		#>

	#-- WITHOUT CASESENSITIVITY

	def FindNthSubStringBetweenZZIB(n, pcSubStr, pcBound1, pcBound2)
		return This.FindNthSubStringBetweenCSIBZZ(n, pcSubStr, pcBound1, pcBound2, TRUE)

		#< @FunctionAlternativeForms

		def FindNthSubStringBetweenIBZZ(n, pcSubStr, pcBound1, pcBound2)
			return This.FindNthSubStringBetweenIBZZ(n, pcSubStr, pcBound1, pcBound2)

		def FindNthSubStringBoundedByIBZZ(n, pcSubStr, pacBounds)
			return This.FindNthSubStringBoundedByIBZZ(n, pcSubStr, pacBounds)

		#--
	
		def FindNthSubStringBetweenAsSectionsIB(n, pcSubStr, pcBound1, pcBound2)
			return This.FindNthSubStringBetweenIBZZ(n, pcSubStr, pcBound1, pcBound2)

		def FindNthSubStringBoundedByAsSectionsIB(n, pcSubStr, pacBounds)
			return This.FindNthSubStringBoundedByIBZZ(n, pcSubStr, pacBounds)

		#==

		def NthSubStringBetweenAsSectionsIB(n, pcSubStr, pcBound1, pcBound2)
			return This.FindNthSubStringBetweenIBZZ(n, pcSubStr, pcBound1, pcBound2)

		def NthSubStringBoundedByAsSectionsIB(n, pcSubStr, pacBounds)
			return This.FindNthSubStringBoundedByIBZZ(n, pcSubStr, pacBounds)

		#>
		
	  #----------------------------------------------------------------------------------------------------------#
	 #  GETTING THE SUBSSTRING AND ITS NTH OCCURRENCE AS SECTION BETWEEN TWO GIVEN SUBSTRINGS INCLUDING BOUNDS  #
	#----------------------------------------------------------------------------------------------------------#

	def NthSubStringBetweenCSIBZZ(n, pcSubStr, pcBound1, pcBound2, pCaseSensitive)
		aResult = [ pcSubStr, This.FindNthSubStringBetweenCSIBZZ(n, pcSubStr, pcBound1, pcBound2, pCaseSensitive) ]
		return aResult

		#< @FunctionAlternativeForms

		def NthSubStringBoundedByCSIBZZ(n, pcSubStr, pacBounds, pCaseSensitive)
			if isString(pacBounds)
				return This.NthSubStringBetweenCSIBZZ(n, pcSubStr, pacBounds, pacBounds, pCaseSensitive)

			but isList(pacBounds) and Q(pacBounds).IsPairOfStrings()
				return This.NthSubStringBetweenCSIBZZ(n, pcSubStr, pacBounds[1], pacBounds[2], pCaseSensitive)

			else
				StzRaise("Incorrect param type! pacBounds must be a string or pair of strings.")
			ok

		#--

		def NthSubStringBetweenAsSectionCSIB(n, pcSubStr, pcBound1, pcBound2, pCaseSensitive)
			return This.NthSubStringBetweenCSIBZZ(n, pcSubStr, pcBound1, pcBound2, pCaseSensitive)

		def NthSubStringBoundedByAsSectionCSIB(n, pcSubStr, pacBounds, pCaseSensitive)
			return This.NthSubStringBoundedByCSIBZZ(n, pcSubStr, pacBounds, pCaseSensitive)

		#>

	#-- WITHOUT CASESENSITIVITY

	def NthSubStringBetweenIBZZ(n, pcSubStr, pcBound1, pcBound2, pCaseSensitive)
		return This.NthSubStringBetweenCSIBZZ(n, pcSubStr, pcBound1, pcBound2, TRUE)

		#< @FunctionAlternativeForms

		def NthSubStringBoundedByIBZZ(n, pcSubStr, pacBounds)
			return This.NthSubStringBoundedByCSIBZZ(n, pcSubStr, pacBounds, TRUE)

		#--

		def NthSubStringBetweenAsSectionIB(n, pcSubStr, pcBound1, pcBound2)
			return This.NthSubStringBetweenIBZZ(n, pcSubStr, pcBound1, pcBound2)

		def NthSubStringBoundedByAsSectionIB(n, pcSubStr, pacBounds)
			return This.NthSubStringBoundedByIBZZ(n, pcSubStr, pacBounds)

		#>

	   #-----------------------------------------------------#
	  #  FINDING NTH OCCURRENCE OF A SUBSTRING BOUNDED BY   #
	 #  TWO OTHER SUBSTRINGS STARTING AT A GIVEN POSITION  #
	#=====================================================#

	def FindNthSubStringBetweenSCS(n, pcSubStr, pcBound1, pcBound2, pnStartingAt, pCaseSensitive)
		if isList(pnStaringAt) and Q(pnStaringAt).IsStartingAtNamedParam()
			pnStartingAt = pnStartingAt[2]
		ok

		nLast = This.NumberOfChars()
		nPos = This.SectionQ(pnStartingAt, nLast).FindNthSubStringBetweenCS(n, pcSubStr, pcBound1, pcBound2, pCaseSensitive)
		nResult = nPos + pnStartingAt

		return nResult

		#< @FunctionalternativeForms

		def FindNthSubStringBoundedBySCS(n, pcSubStr, pacBounds, pnStartingAt, pCaseSensitive)
			if isString(pacBounds)
				return This.FindNthSubStringBetweenSCS(n, pcSubStr, pacBounds, pacBounds, pnStartingAt, pCaseSensitive)

			but isList(pacBounds) and Q(pacBounds).IsPairOfStrings()
				return This.FindNthSubStringBetweenSCS(n, pcSubStr, pacBounds[1], pacBounds[2], pnStartingAt, pCaseSensitive)

			else
				StzRaise("Incorrect param type! pacBounds must be a string or pair of strings.")
			ok

		#--
	
		def FindNthSubStringBetweenSCSZ(n, pcSubStr, pcBound1, pcBound2, pnStartingAt, pCaseSensitive)
			return This.FindNthSubStringBetweenSCS(n, pcSubStr, pcBound1, pcBound2, pnStartingAt, pCaseSensitive)

		def FindNthSubStringBoundedBySCSZ(n, pcSubStr, pacBounds, pnStartingAt, pCaseSensitive)
			return This.FindNthSubStringBoundedBySCS(n, pcSubStr, pacBounds, pnStartingAt, pCaseSensitive)

		#==

		def NthSubStringBetweenSCS(n, pcSubStr, pcBound1, pcBound2, pnStartingAt, pCaseSensitive)
			return This.FindNthSubStringBetweenSCS(n, pcSubStr, pcBound1, pcBound2, pnStartingAt, pCaseSensitive)

		def NthSubStringBoundedBySCS(n, pcSubStr, pacBounds, pnStartingAt, pCaseSensitive)
			return This.FindNthSubStringBoundedBySCS(n, pcSubStr, pacBounds, pnStartingAt, pCaseSensitive)

		#>

	#-- WITHOUT CASESENSITIVITY

	def FindNthSubStringBetweenS(n, pcSubStr, pcBound1, pcBound2, pnStartingAt)
		return This.FindNthSubStringBetweenSCS(n, pcSubStr, pcBound1, pcBound2, pnStartingAt, TRUE)

		#< @FunctionAlternativeForms

		def FindNthSubStringBoundedByS(n, pcSubStr, pacBounds, pnStartingAt)
			return This.FindNthSubStringBoundedByS(n, pcSubStr, pacBounds, pnStartingAt)

		#--
	
		def FindNthSubStringBetweenSZ(n, pcSubStr, pcBound1, pcBound2, pnStartingAt)
			return This.FindNthSubStringBetweenS(n, pcSubStr, pcBound1, pcBound2, pnStartingAt)

		def FindNthSubStringBoundedBySZ(n, pcSubStr, pacBounds, pnStartingAt)
			return This.FindNthSubStringBoundedByS(n, pcSubStr, pacBounds, pnStartingAt)

		#==

		def NthSubStringBetweenS(n, pcSubStr, pcBound1, pcBound2, pnStartingAt)
			return This.FindBetweenS(n, pcSubStr, pcBound1, pcBound2, pnStartingAt)

		def NthSubStringBoundedByS(n, pcSubStr, pacBounds, pnStartingAt)
			return This.FindNthSubStringBoundedByS(n, pcSubStr, pacBounds, pnStartingAt)

		#>

	  #----------------------------------------------------------------------------------------------------------#
	 #  GETTING THE SUBSTRING AND ITS NTH OCCURRENCE BETWEEN TWO GIVEN SUBSTRINGS STARTING AT A GIVEN POSITION  #
	#----------------------------------------------------------------------------------------------------------#

	def NthSubStringBetweenSCSZ(n, pcSubStr, pcBound1, pcBound2, pnStartingAt, pCaseSensitive)
		aResult = [ pcSubStr, This.FindNthSubStringBetweenSCSZ(n, pcSubStr, pcBound1, pcBound2, pnStartingAt, pCaseSensitive) ]
		return aResult

		def NthSubStringBoundedBySCSZ(n, pcSubStr, pacBounds, pnStartingAt, pCaseSensitive)
			if isString(pacBounds)
				return This.NthSubStringBetweenSCSZ(n, pcSubStr, pacBounds, pacBounds, pnStartingAt, pCaseSensitive)

			but isList(pacBounds) and Q(pacBounds).IsPairOfStrings()
				return This.NthSubStringBetweenSCSZ(n, pcSubStr, pacBounds[1], pacBounds[2], pnStartingAt, pCaseSensitive)

			else
				StzRaise("Incorrect param type! pacBounds must be a string or pair of strings.")
			ok

	#-- WITHOUT CASESENSITIVITY

	def NthSubStringBetweenSZ(n, pcSubStr, pcBound1, pcBound2, pnStartingAt)
		return This.NthSubStringBetweenSCSZ(n, pcSubStr, pcBound1, pcBound2, pnStartingAt, TRUE)

		def NthSubStringBoundedBySZ(n, pcSubStr, pacBounds, pnStartingAt)
			return This.NthSubStringBoundedBySCSZ(n, pcSubStr, pacBounds, pnStartingAt, TRUE)

	   #-------------------------------------------------------------------------#
	  #  FINDING NTH OCCURRENCE OF A SUBSTRING BOUNDED BY TWO OTHER SUBSTRINGS  #
	 #  STARTING AT A GIVEN POSITION AND RETURNING POSITIONS AS SECTIONS       #
	#=========================================================================#

	def FindNthSubStringBetweenSCSZZ(n, pcSubStr, pcBound1, pcBound2, pnStartingAt, pCaseSensitive)
		nPos = This.FindNthSubStringBetweenSCS(n, pcSubStr, pcBound1, pcBound2, pnStartingAt, pCaseSensitive)
		nLenSubStr = Q(pcSubStr).NumberOfChars()

		aResult = [ pcSubStr, (nPos + nLenSubStr - 1) ]
		return aResult

		#< @FunctionAlternativeForms

		def FindNthSubStringBoundedBySCSZZ(n, pcSubStr, pacBounds, pnStartingAt, pCaseSensitive)
			if isString(pacBounds)
				return This.FindNthSubStringBetweenSCSZZ(n, pcSubStr, pacBounds, pacBounds, pnStartingAt, pCaseSensitive)

			but isList(pacBounds) and Q(pacBounds).isPairOfStrings()
				return This.FindNthSubStringBetweenSCSZZ(n, pcSubStr, pacBounds[1], pacBounds[2], pnStartingAt, pCaseSensitive)

			else
				StzRaise("Incorrect param type! pacBounds must be a string or pair of strings.")
			ok

		#--
	
		def FindNthSubStringBetweenAsSectionsSCS(n, pcSubStr, pcBound1, pcBound2, pnStartingAt, pCaseSensitive)
			return This.FindNthSubStringBetweenSCSZZ(n, pcSubStr, pcBound1, pcBound2, pnStartingAt, pCaseSensitive)

		def FindNthSubStringBoundedByAsSectionsSCS(n, pcSubStr, pacBounds, pnStartingAt, pCaseSensitive)
			return This.FindNthSubStringBoundedBySCSZZ(n, pcSubStr, pacBounds, pnStartingAt, pCaseSensitive)

		#>

	#--WITHOUT CASESENSITIVITY

	def FindNthSubStringBetweenSZZ(n, pcSubStr, pcBound1, pcBound2, pnStartingAt)
		return This.FindNthSubStringBetweenSCSZZ(n, pcSubStr, pcBound1, pcBound2, pnStartingAt, TRUE)

		#< @FunctionAlternativeForms

		def FindNthSubStringBoundedBySZZ(n, pcSubStr, pacBounds, pnStartingAt)
			return This.FindNthSubStringBoundedBySZZ(n, pcSubStr, pacBounds, pnStartingAt)

		#--
	
		def FindNthSubStringBetweenAsSectionsS(n, pcSubStr, pcBound1, pcBound2, pnStartingAt)
			return This.FindNthSubStringBetweenSZZ(n, pcSubStr, pcBound1, pcBound2, pnStartingAt)

		def FindNthSubStringBoundedByAsSectionsS(n, pcSubStr, pacBounds, pnStartingAt)
			return This.FindNthSubStringBoundedBySZZ(n, pcSubStr, pacBounds, pnStartingAt)

		#>

	  #----------------------------------------------------------------------------------------#
	 #  GETTING THE SUBSTRING AND ITS NTH OCCURRENCE AS SECTION BETWEEN TWO GIVEN SUBSTRINGS  #
	#----------------------------------------------------------------------------------------#

	def NthSubStringBetweenSCSZZ(n, pcSubStr, pcBound1, pcBound2, pnStartingAt, pCaseSensitive)
		aResult = [ pcSubStr, This.FindNthSubStringBetweenAsSectionsSCSZZ(n, pcSubStr, pcBound1, pcBound2, pnStartingAt, pCaseSensitive) ]
		return aResult

		#< @FunctionAlternativeForms

		def NthSubStringBoundedBySCSZZ(n, pcSubStr, pacBounds, pnStartingAt, pCaseSensitive)
			if isString(pacBounds)
				return This.NthSubStringBetweenSCSZZ(n, pcSubStr, pacBounds, pacBounds, pnStartingAt, pCaseSensitive)

			but isList(pacBounds) and Q(pacBounds).IsPairOfStrings()
				return This.NthSubStringBetweenSCSZZ(n, pcSubStr, pacBounds[1], pacBounds[2], pnStartingAt, pCaseSensitive)

			else
				StzRaise("Incorrect param type! pacBounds must be a string or pair of strings.")

			ok

		#--

		def NthSubStringBetweenAsSection_SCS(n, pcSubStr, pcBound1, pcBound2, pnStartingAt, pCaseSensitive)
			return This.NthSubStringBetweenSCSZZ(n, pcSubStr, pcBound1, pcBound2, pnStartingAt, pCaseSensitive)

		def NthSubStringBoundedByAsSection_SCS(n, pcSubStr, pacBounds, pnStartingAt, pCaseSensitive)
			return This.NthSubStringBoundedBySCSZZ(n, pcSubStr, pacBounds, pnStartingAt, pCaseSensitive)

		#>

	#-- WITHOUT CASESENSITIVITY

	def NthSubStringBetweenAsSectionsSZZ(n, pcSubStr, pcBound1, pcBound2, pnStartingAt)
		return This.NthSubStringBetweenAsSectionsSCSZZ(n, pcSubStr, pcBound1, pcBound2, pnStartingAt, TRUE)

		#< @FunctionAlternativeForms

		def NthSubStringBoundedByAsSectionsSZZ(n, pcSubStr, pacBounds, pnStartingAt)
			return This.NthSubStringBoundedByAsSectionsSCSZZ(n, pcSubStr, pacBounds, pnStartingAt, TRUE)

		#--

		def NthSubStringBetweenAsSection_S(n, pcSubStr, pcBound1, pcBound2, pnStartingAt)
			return This.NthSubStringBetweenSZZ(n, pcSubStr, pcBound1, pcBound2, pnStartingAt)

		def NthSubStringBoundedByAsSection_S(n, pcSubStr, pacBounds, pnStartingAt)
			return This.NthSubStringBoundedBySZZ(n, pcSubStr, pacBounds, pnStartingAt)

		#>

	   #---------------------------------------------------------------#
	  #  FINDING NTH OCCURRENCE OF A SUBSTRING BOUNDED BY TWO OTHER   #
	 #  SUBSTRINGSSTARTING AT A GIVEN POSITION AND INCLUDING BOUNDS  #
	#===============================================================#

	def FindNthSubStringBetweenSCSIB(n, pcSubStr, pcBound1, pcBound2, pnStartingAt, pCaseSensitive)
		nPos = This.FindNthSubStringBetweenSCS(n, pcSubStr, pcBound1, pcBound2, pnStaringAt, pCaseSensitive)
		nLenBound1 = Q(pcBound1).NumberOfChars()
		nResult = nPos - nLenBound1
		return nResult

		#< @FunctionAlternativeForms

		def FindNthSubStringBoundedBySCSIB(n, pcSubStr, pacBounds, pnStartingAt, pCaseSensitive)
			if isString(pacBounds)
				return This.FindNthSubStringBetweenSCSIB(n, pcSubStr, pacBounds, pacBounds, pnStartingAt, pCaseSensitive)

			but isList(pacBounds) and Q(pacBounds).IsPairOfStrings()
				return This.FindNthSubStringBetweenSCSIB(n, pcSubStr, pacBounds[1], pacBounds[2], pnStartingAt, pCaseSensitive)

			else
				StzRaise("Incorrect param type! pacBounds must be a string or pair of strings.")
			ok

		#--
	
		def FindNthSubStringBetweenSCSIBZ(n, pcSubStr, pcBound1, pcBound2, pnStartingAt, pCaseSensitive)
			return This.FindNthSubStringBetweenSCSIB(n, pcSubStr, pcBound1, pcBound2, pnStartingAt, pCaseSensitive)

		def FindNthSubStringBoundedBySCSIBZ(n, pcSubStr, pacBounds, pnStartingAt, pCaseSensitive)
			return This.FindNthSubStringBoundedBySCSIB(n, pcSubStr, pacBounds, pnStartingAt, pCaseSensitive)

		#==

		def NthSubStringBetweenSCSIB(n, pcSubStr, pcBound1, pcBound2, pnStartingAt, pCaseSensitive)
			return This.FindNthSubStringBetweenSCSIB(n, pcSubStr, pcBound1, pcBound2, pnStartingAt, pCaseSensitive)

		def NthSubStringBoundedBySCSIB(n, pcSubStr, pacBounds, pnStartingAt, pCaseSensitive)
			return This.FindNthSubStringBoundedBySCSIB(n, pcSubStr, pacBounds, pnStartingAt, pCaseSensitive)

		#>

	#-- WITHOUT CASESENSITIVITY

	def FindNthSubStringBetweenSIB(n, pcSubStr, pcBound1, pcBound2, pnStartingAt)
		return This.FindNthSubStringBetweenSCSIB(n, pcSubStr, pcBound1, pcBound2, pnStartingAt, TRUE)

		#< @FunctionAlternativeForms

		def FindNthSubStringBoundedBySIB(n, pcSubStr, pacBounds, pnStartingAt)
			return This.FindNthSubStringBoundedBySIB(n, pcSubStr, pacBounds, pnStartingAt)

		#--
	
		def FindNthSubStringBetweenSIBZ(n, pcSubStr, pcBound1, pcBound2, pnStartingAt)
			return This.FindNthSubStringBetweenSIB(n, pcSubStr, pcBound1, pcBound2, pnStartingAt)

		def FindNthSubStringBoundedBySIBZ(n, pcSubStr, pacBounds, pnStartingAt)
			return This.FindNthSubStringBoundedBySIB(n, pcSubStr, pacBounds, pnStartingAt)

		#==

		def NthSubStringBetweenSIB(n, pcSubStr, pcBound1, pcBound2, pnStartingAt)
			return This.FindNthSubStringBetweenSIB(n, pcSubStr, pcBound1, pcBound2, pnStartingAt)

		def NthSubStringBoundedBySIB(n, pcSubStr, pacBounds, pnStartingAt)
			return This.FindBoundedBySIB(n, pcSubStr, pacBounds, pnStartingAt)

		#>

	  #---------------------------------------------------------------------------------------------------------#
	 #  GETTING THE SUBSTRING AND ITS NTH OCCURRENCE AS SECTION BETWEEN TOW GIVEN SUBSTRINGS INCLUDING BOUNDS  #
	#---------------------------------------------------------------------------------------------------------#

	def NthSubStringBetweenSCSIBZ(n, pcSubStr, pcBound1, pcBound2, pnStartingAt, pCaseSensitive)
		aResult = [ pcSubStr, This.FindNthSubStringBetweenSCSIBZ(n, pcSubStr, pcBound1, pcBound2, pnStartingAt, pCaseSensitive) ]
		return aResult

		def NthSubStringBoundedBySCSIBZ(n, pcSubStr, pacBounds, pnStartingAt, pCaseSensitive)
			if isString(pacBounds)
				return This.NthSubStringBetweenSCSIBZ(n, pcSubStr, pacBounds, pacBounds, pnStartingAt, pCaseSensitive)

			but isList(pacBounds) and Q(pacBounds).IsPairOfStrings()
				return This.thSubStringBetweenSCSIBZ(n, pcSubStr, pacBounds[1], pacBounds[2], pnStartingAt, pCaseSensitive)

			else
				StzRaise("Incorrect param type! pacBounds must be a string or pair of string.")
			ok

	#-- WITHOUT CASESENSITIVITY

	def NthSubStringBetweenSIBZ(n, pcSubStr, pcBound1, pcBound2, pnStartingAt)
		return This.NthSubStringBetweenSCSIBZ(n, pcSubStr, pcBound1, pcBound2, pnStartingAt, TRUE)

		def NthSubStringBoundedBySIBZ(n, pcSubStr, pacBounds, pnStartingAt)
			return This.NthSubStringBoundedBySCSIBZ(n, pcSubStr, pacBounds, pnStartingAt, :CaseSensitive) = TRUE

	   #-----------------------------------------------------------------------------------#
	  #  FINDING NTH OCCURRENCE OF A SUBSTRING BOUNDED BY TWO OTHER SUBSTRINGS STARTING   #
	 #  AT A GIVEN POSITION, INCLUDING BOUNDS, AND RETURNING THE POSITIONS AS SECTIONS   #
	#===================================================================================#

	def FindNthSubStringBetweenSCSIBZZ(n, pcSubStr, pcBound1, pcBound2, pnStartingAt, pCaseSensitive)
		nPos = This.FindNthSubStringBetweenSCS(n, pcSubStr, pcBound1, pcBound2, pCaseSensitive)

		nLenSubStr = Q(pcSubStr).NumberOfChars()
		nLenBound1 = Q(pcBound1).NumberOfChars()
		nLenBound2 = Q(pcBound2).NumberOfChars()
		
		n1 = nPos - nLenBound1
		n2 = nPos + nLenBound2 - 1

		aResult = [ pcSubStr, [n1, n2] ]

		return aResult

		#< @FunctionAlternativeForms

		def FindNthSubStringBoundedBySCSIBZZ(n, pcSubStr, pacBounds, pnStartingAt, pCaseSensitive)
			if isString(pacBounds)
				return This.FindNthSubStringBetweenSCSIBZZ(n, pcSubStr, pacBounds, pacBounds, pnStartingAt, pCaseSensitive)

			but isList(pacBounds) and Q(pacBounds).IsPairOfStrings()
				return This.FindNthSubStringBetweenSCSIBZZ(n, pcSubStr, pacBounds[1], pacBounds[2], pnStartingAt, pCaseSensitive)

			else
				StzRaise("Incorrect param type! pacBounds must be string or pair of strings.")

			ok

		#--
	
		def FindNthSubStringBetweenAsSectionsSCSIB(n, pcSubStr, pcBound1, pcBound2, pnStartingAt, pCaseSensitive)
			return This.FindNthSubStringBetweenSCSIBZZ(n, pcSubStr, pcBound1, pcBound2, pnStartingAt, pCaseSensitive)

		def FindNthSubStringBoundedByAsSectionsSCSIB(n, pcSubStr, pacBounds, pnStartingAt, pCaseSensitive)
			return This.FindNthSubStringBoundedBySCSIBZZ(n, pcSubStr, pacBounds, pnStartingAt, pCaseSensitive)

		#==

		def NthSubStringBetweenAsSectionsSCSIB(n, pcSubStr, pcBound1, pcBound2, pnStartingAt, pCaseSensitive)
			return This.FindNthSubStringBetweenSIBCSZZ(n, pcSubStr, pcBound1, pcBound2, pnStartingAt, pCaseSensitive)

		def NthSubStringBoundedByAsSectionsSCSIB(n, pcSubStr, pacBounds, pnStartingAt, pCaseSensitive)
			return This.FindNthSubStringBoundedBySCSIBZZ(n, pcSubStr, pacBounds, pnStartingAt, pCaseSensitive)

		#>

	#-- WITHOUT CASESENSITIVITY

	def FindNthSubStringBetweenSIBZZ(n, pcSubStr, pcBound1, pcBound2, pnStartingAt)
		return This.FindNthSubStringBetweenSIBCSZZ(n, pcSubStr, pcBound1, pcBound2, pnStartingAt, TRUE)

		#< @FunctionAlternativeForms

		def FindNthSubStringBoundedBySIBZZ(n, pcSubStr, pacBounds, pnStartingAt)
			return This.FindNthSubStringBoundedBySIBZZ(n, pcSubStr, pacBounds, pnStartingAt)

		#--
	
		def FindNthSubStringBetweenAsSectionsSIB(n, pcSubStr, pcBound1, pcBound2, pnStartingAt)
			return This.FindNthSubStringBetweenSIBZZ(n, pcSubStr, pcBound1, pcBound2, pnStartingAt)

		def FindNthSubStringBoundedByAsSectionsSIB(n, pcSubStr, pacBounds, pnStartingAt)
			return This.FindNthSubStringBoundedBySIBZZ(n, pcSubStr, pacBounds, pnStartingAt)

		#==

		def NthSubStringBetweenAsSectionsSIB(n, pcSubStr, pcBound1, pcBound2, pnStartingAt)
			return This.FindNthSubStringBetweenSIBZZ(n, pcSubStr, pcBound1, pcBound2, pnStartingAt)

		def NthSubStringBoundedByAsSectionsSIB(n, pcSubStr, pacBounds, pnStartingAt)
			return This.FindNthSubStringBoundedBySIBZZ(n, pcSubStr, pacBounds, pnStartingAt)

		#>

	  #----------------------------------------------------------------------------------------------------------------------------------#
	 #  THE SUBSTRING AND ITS NTH OCCURRENCE AS SECTION BETWEEN TWO GIVEN SUBSTRINGS STARTING AT A GIVEN POSITION ABD INCLUDING BOUNDS  #
	#----------------------------------------------------------------------------------------------------------------------------------#

	def NthSubStringBetweenSCSIBZZ(n, pcSubStr, pcBound1, pcBound2, pnStartingAt, pCaseSensitive)
		aResult = [ pcSubStr, This.FindNthSubStringBetweenSCSIBZZ(n, pcSubStr, pcBound1, pcBound2, pnStartingAt, pCaseSensitive) ]
		return aResult

		#< @FunctionAlternativeForms

		def NthSubStringBoundedBySCSIBZZ(n, pcSubStr, pacBounds, pnStartingAt, pCaseSensitive)
			if isString(pacBounds)
				return This. NthSubStringBetweenSCSIBZZ(n, pcSubStr, pacBounds, pacBounds, pnStartingAt, pCaseSensitive)

			but isList(pacBounds) and Q(pacBounds).IsPairOfStrings()
				return This.NthSubStringBetweenSCSIBZZ(n, pcSubStr, pacBounds[1], pacBounds[2], pnStartingAt, pCaseSensitive)

			else
				StzRaise("Incorrect param type! pacBounds must be a string or pair of strings.")
			ok

		#--

		def NthSubStringBetweenAsSection_SCSIB(n, pcSubStr, pcBound1, pcBound2, pnStartingAt, pCaseSensitive)
			return This.NthSubStringBetweenSCSIBZZ(n, pcSubStr, pcBound1, pcBound2, pnStartingAt, pCaseSensitive)

		def NthSubStringBoundedByAsSection_SCSIB(n, pcSubStr, pacBounds, pnStartingAt, pCaseSensitive)
			return This.NthSubStringBoundedBySCSIBZZ(n, pcSubStr, pacBounds, pnStartingAt, pCaseSensitive)

		#>

	#-- WITHOUT CASESENSITIVITY

	def NthSubStringBetweenSIBZZ(n, pcSubStr, pcBound1, pcBound2, pnStartingAt)
		return This.NthSubStringBetweenSCSIBZZ(n, pcSubStr, pcBound1, pcBound2, pnStartingAt, pCaseSensitive)

		#< @FunctionAlternativeForms

		def NthSubStringBoundedBySIBZZ(n, pcSubStr, pacBounds, pnStartingAt)
			return This.NthSubStringBoundedBySCSIBZZ(n, pcSubStr, pacBounds, pnStartingAt, TRUE)

		#--

		def NthSubStringBetweenAsSection_SIB(n, pcSubStr, pcBound1, pcBound2, pnStartingAt)
			return This.NthSubStringBetweenSIBZZ(n, pcSubStr, pcBound1, pcBound2, pnStartingAt)

		def NthSubStringBoundedByAsSection_SIB(n, pcSubStr, pacBounds, pnStartingAt)
			return This.NthSubStringBoundedBySIBZZ(n, pcSubStr, pacBounds, pnStartingAt)

		#>

	   #----------------------------------------------------#
	  #  FINDING NTH OCCURRENCE OF A SUBSTRING BOUNDED BY  #
	 #  TWO OTHER SUBSTRINGS GOING IN A GIVEN DIRECTION   #
	#====================================================#

	def FindNthSubStringBetweenDCS(n, pcSubStr, pcBound1, pcBound2, pcDirection, pCaseSensitive)

		# Checking params

		if isList(pcDirection) and Q(pcDirection).IsOneOfTheseNamedParams([ :Going, :Direction ])
			pcDirection = pcDirection[2]
		ok

		if NOT isString(pcDirection) and (pcDirection = :Forward or pcDirection = :Backward)
			StzRaise("Incorrect param! pcDirection must be a string equal to :Forward or :Backward.")
		ok

		# Doing the job

		if pcDirection = :Forward
			return This.FindNextNthSubStringBetweenSCS(n, pcSubStr, pcBound1, pcBound2, 1, pCaseSensitive)

		else // pcDirection = :Backward
			nLast = This.NumberOfChars()
			return This.FindPreviousNthSubStringBetweenSCS(n, pcSubStr, pcBound1, pcBound2, nLast, pCaseSensitive)

		ok

		# TODO (future): Check if switch could be more performant then if/else when
		# this function (or any other function written with if/else) is used in large loops

		#< @FunctionAlternativeForms

		def FindNthSubStringBoundedByDCS(n, pcSubStr, pacBounds, pcDirection, pCaseSensitive)
			if isString(pacBounds)
				return This.FindNthSubStringBetweenDCS(n, pcSubStr, pacBounds, pacBounds, pcDirection, pCaseSensitive)

			but isList(pacBounds) and Q(pacBounds).IsPairOfStrings()
				return This.FindNthSubStringBetweenDCS(n, pcSubStr, pacBounds[1], pacBounds[2], pcDirection, pCaseSensitive)

			else
				StzRaise("Incorrect param type! pacBounds must be a string or pair of strings.")
			ok

		#--
	
		def FindNthSubStringBetweenDCSZ(n, pcSubStr, pcBound1, pcBound2, pcDirection, pCaseSensitive)
			return This.FindNthSubStringBetweenDCS(n, pcSubStr, pcBound1, pcBound2, pcDirection, pCaseSensitive)

		def FindNthSubStringBoundedByDCSZ(n, pcSubStr, pacBounds, pcDirection, pCaseSensitive)
			return This.FindNthSubStringBoundedByDCS(n, pcSubStr, pacBounds, pcDirection, pCaseSensitive)

		#==

		def NthSubStringBetweenDCS(n, pcSubStr, pcBound1, pcBound2, pcDirection, pCaseSensitive)
			return This.FindNthSubStringBetweenDCS(n, pcSubStr, pcBound1, pcBound2, pcDirection, pCaseSensitive)

		def NthSubStringBoundedByDCS(n, pcSubStr, pacBounds, pcDirection, pCaseSensitive)
			return This.FindNthSubStringBoundedByDCS(n, pcSubStr, pacBounds, pcDirection, pCaseSensitive)

		#>

	#-- WITHOUT CASESENSITIVITY

	def FindNthSubStringBetweenD(n, pcSubStr, pcBound1, pcBound2, pcDirection)
		return This.FindNthSubStringBetweenDCS(n, pcSubStr, pcBound1, pcBound2, pcDirection, TRUE)

		#< @FunctionAlternativeForms

		def FindNthSubStringBoundedByD(n, pcSubStr, pacBounds, pcDirection)
			return This.FindNthSubStringBoundedByD(n, pcSubStr, pacBounds, pcDirection)

		#--
	
		def FindNthSubStringBetweenDZ(n, pcSubStr, pcBound1, pcBound2, pcDirection)
			return This.FindNthSubStringBetweenD(n, pcSubStr, pcBound1, pcBound2, pcDirection)

		def FindNthSubStringBoundedByDZ(n, pcSubStr, pacBounds, pcDirection)
			return This.FindNthSubStringBoundedByD(n, pcSubStr, pacBounds, pcDirection)

		#==

		def NthSubStringBetweenD(n, pcSubStr, pcBound1, pcBound2, pcDirection)
			return This.FindNthSubStringBetweenD(n, pcSubStr, pcBound1, pcBound2, pcDirection)

		def NthSubStringBoundedByD(n, pcSubStr, pacBounds, pcDirection)
			return This.FindNthSubStringBoundedByD(n, pcSubStr, pacBounds, pcDirection)

		#>

	  #--------------------------------------------------------------------------------------------------------#
	 #  GETTING THE SUBSTRING AND ITS NTH OCCURRENCE BETWEEN TWO GIVEN SUBSTRINGS GOING IN A GIVEN DIRECTION  #
	#--------------------------------------------------------------------------------------------------------#

	def NthSubStringBetweenDCSZ(n, pcSubStr, pcBound1, pcBound2, pcDirection, pCaseSensitive)

		aResult = [ pcSubStr, This.FindNthSubStringBetweenDCSZ(n, pcSubStr, pcBound1, pcBound2, pcDirection, pCaseSensitive) ]
		return aResult

		def NthSubStringBoundedByDCSZ(n, pcSubStr, pacBounds, pcDirection, pCaseSensitive)
			if isString(pacBounds)
				return This.NthSubStringBetweenDCSZ(n, pcSubStr, pacBounds, pacBounds, pcDirection, pCaseSensitive)

			but isList(pacBounds) and Q(pacBounds).IsPairOfStrings()
				return This.NthSubStringBetweenDCSZ(n, pcSubStr, pacBounds[1], pacBounds[2], pcDirection, pCaseSensitive)
				
			else
				StzRaise("Incorrect param type! pacBounds must be a string or pair of strings.")

			ok

	#-- WITHOUT CASESENSITIVITY

	def NthSubStringBetweenDZ(n, pcSubStr, pcBound1, pcBound2, pcDirection)
		return This.NthSubStringBetweenDCSZ(n, pcSubStr, pcBound1, pcBound2, pcDirection, TRUE)

	   #-------------------------------------------------------------------------#
	  #  FINDING NTH OCCURRENCE OF A SUBSTRING BOUNDED BY TWO OTHER SUBSTRINGS  #
	 #  GOING INA GIVEN DIRECTION AND RETURNING POSITIONS AS SECTIONS          #
	#=========================================================================#

	def FindNthSubStringBetweenDCSZZ(n, pcSubStr, pcBound1, pcBound2, pcDirection, pCaseSensitive)

		nPos = This.FindNthSubStringBetweenDC(n, pcSubStr, pcBound1, pcBound2, pcDirection, pCaseSensitive)
		nLenBound1 = Q(pcBound1).NumberOfChars()

		nResult = nPos - nLenBound1 + 1

		return nResult

		#< @FunctionAlternativeForms

		def FindNthSubStringBoundedByDCSZZ(n, pcSubStr, pacBounds, pcDirection, pCaseSensitive)
			if isString(pacBounds)
				return This.FindNthSubStringBetweenDCSZZ(n, pcSubStr, pacBounds, pacBounds, pcDirection, pCaseSensitive)

			but isList(pacBounds) and Q(pacBounds).IsPairOfNumbers()
				return This.FindNthSubStringBetweenDCSZZ(n, pcSubStr, pacBounds[1], pacBounds[2], pcDirection, pCaseSensitive)

			else
				StzRaise("Incorrect param type! pacBounds must be a string or pair of strings.")

			ok

		#--
	
		def FindNthSubStringBetweenAsSectionsDCS(n, pcSubStr, pcBound1, pcBound2, pcDirection, pCaseSensitive)
			return This.FindNthSubStringBetweenDCSZZ(n, pcSubStr, pcBound1, pcBound2, pcDirection, pCaseSensitive)

		def FindNthSubStringBoundedByAsSectionsDCS(n, pcSubStr, pacBounds, pcDirection, pCaseSensitive)
			return This.FindNthSubStringBoundedByDCSZZ(n, pcSubStr, pacBounds, pcDirection, pCaseSensitive)

		#==

		def NthSubStringBetweenAsSectionsDCS(n, pcSubStr, pcBound1, pcBound2, pcDirection, pCaseSensitive)
			return This.FindNthSubStringBetweenDCSZZ(n, pcSubStr, pcBound1, pcBound2, pcDirection, pCaseSensitive)

		def NthSubStringBoundedByAsSectionsDCS(n, pcSubStr, pacBounds, pcDirection, pCaseSensitive)
			return This.FindNthSubStringBoundedByDCSZZ(n, pcSubStr, pacBounds, pcDirection, pCaseSensitive)

		#>

	#-- WITHOUT CASESENSITIVITY

	def FindNthSubStringBetweenDZZ(n, pcSubStr, pcBound1, pcBound2, pcDirection)
		return This.FindNthSubStringBetweenDZZ(n, pcSubStr, pcBound1, pcBound2, pcDirection)

		#< @FunctionAlternativeForms

		def FindNthSubStringBoundedByDZZ(n, pcSubStr, pacBounds, pcDirection)
			return This.FindNthSubStringBoundedByDZZ(n, pcSubStr, pacBounds, pcDirection)

		#--
	
		def FindNthSubStringBetweenAsSectionsD(n, pcSubStr, pcBound1, pcBound2, pcDirection)
			return This.FindNthSubStringBetweenDZZ(n, pcSubStr, pcBound1, pcBound2, pcDirection)

		def FindNthSubStringBoundedByAsSectionsD(n, pcSubStr, pacBounds, pcDirection)
			return This.FindNthSubStringBoundedByDZZ(n, pcSubStr, pacBounds, pcDirection)

		#==

		def NthSubStringBetweenAsSectionsD(n, pcSubStr, pcBound1, pcBound2, pcDirection)
			return This.FindNthSubStringBetweenDZZ(n, pcSubStr, pcBound1, pcBound2, pcDirection)

		def NthSubStringBoundedByAsSectionsD(n, pcSubStr, pacBounds, pcDirection)
			return This.FindNthSubStringBoundedByDZZ(n, pcSubStr, pacBounds, pcDirection)

		#>

	  #-----------------------------------------------------------------------------------------------------------------------#
	 #  GETTING THE SUBSTRING AND ITS NTH OCCURRENCE (AS SECTION) BETWEEN TWO OTHER SUBSTRINGS GOINING IN A GIVEN DIRECTION  #
	#-----------------------------------------------------------------------------------------------------------------------#

	def NthSubStringBetweenDCSZZ(n, pcSubStr, pcBound1, pcBound2, pcDirection, pCaseSensitive)
		aResult = [ pcSubStr, This.FindNthSubStringBetweenDCSZZ(n, pcSubStr, pcBound1, pcBound2, pcDirection, pCaseSensitive) ]
		return aResult

		#< @FunctionAlternativeForms

		def NthSubStringBoundedByDCSZZ(n, pcSubStr, pacBounds, pcDirection, pCaseSensitive)
			if isString(pacBounds)
				return This.NthSubStringBetweenDCSZZ(n, pcSubStr, pacBounds, pacBounds, pcDirection, pCaseSensitive)

			but isList(pacBounds) and Q(pacBounds).IsPairOfStrings()
				return This.NthSubStringBetweenDCSZZ(n, pcSubStr, pacBounds[1], pacBounds[2], pcDirection, pCaseSensitive)

			else
				StzRaise("Incorrect param type! pacBounds must be a string or pair of strings.")

			ok

		#--

		def NthSubStringBetweenAsSectionDCS(n, pcSubStr, pcBound1, pcBound2, pcDirection, pCaseSensitive)
			return This.NthSubStringBetweenDCSZZ(n, pcSubStr, pcBound1, pcBound2, pcDirection, pCaseSensitive)

		def NthSubStringBoundedByAsSectionDCS(n, pcSubStr, pacBounds, pcDirection, pCaseSensitive)
			return This.NthSubStringBoundedByDCSZZ(n, pcSubStr, pacBounds, pcDirection, pCaseSensitive)

		#>

	#-- WITHOUT CASESENSITIVITY

	def NthSubStringBetweenDZZ(n, pcSubStr, pcBound1, pcBound2, pcDirection)
		return This.NthSubStringBetweenDCSZZ(n, pcSubStr, pcBound1, pcBound2, pcDirection, TRUE)

		#< @FunctionAlternativeForms

		def NthSubStringBoundedByDZZ(n, pcSubStr, pacBounds, pcDirection)
			return This.NthSubStringBoundedByDCSZZ(n, pcSubStr, pacBounds, pcDirection, TRUE)

		#--

		def NthSubStringBetweenAsSectionD(n, pcSubStr, pcBound1, pcBound2, pcDirection)
			return This.NthSubStringBetweenDZZ(n, pcSubStr, pcBound1, pcBound2, pcDirection)

		def NthSubStringBoundedByAsSectionD(n, pcSubStr, pacBounds, pcDirection)
			return This.NthSubStringBoundedByDZZ(n, pcSubStr, pacBounds, pcDirection)

		#>

	   #--------------------------------------------------------------#
	  #  FINDING NTH OCCURRENCE OF A SUBSTRING BOUNDED BY TWO OTHER  #
	 #  SUBSTRINGS GOING IN A GIVEN DIRECTION AND INCLUDING BOUNDS  #
	#==============================================================#

	def FindNthSubStringBetweenDCSIB(n, pcSubStr, pcBound1, pcBound2, pcDirection, pCaseSensitive)

		nPos = This.FindNthSubStringBetweenDCS(n, pcSubStr, pcBound1, pcBound2, pcDirection, pCaseSensitive)
		nLenBound1 = Q(pcBound1).NumberOfChars()
		nResult = nPos - nLenBound1 + 1

		return nResult

		#< @FunctionAlternativeForms

		def FindNthSubStringBoundedByDCSIB(n, pcSubStr, pacBounds, pcDirection, pCaseSensitive)
			if isString(pacBounds)
				return This.FindNthSubStringBetweenDCSIB(n, pcSubStr, pacBounds, pacBounds, pcDirection, pCaseSensitive)

			but isList(pacBounds) and Q(pacBounds).IsPairOfStrings()
				return This.FindNthSubStringBetweenDCSIB(n, pcSubStr, pacBounds[1], pacBounds[2], pcDirection, pCaseSensitive)

			else
				StzRaise("Incorrect param type! pacBounds must be a string or pair of strings.")
			ok

		#--
	
		def FindNthSubStringBetweenDCSIBZ(n, pcSubStr, pcBound1, pcBound2, pcDirection, pCaseSensitive)
			return This.FindNthSubStringBetweenDCSIB(n, pcSubStr, pcBound1, pcBound2, pcDirection, pCaseSensitive)

		def FindNthSubStringBoundedByDCSIBZ(n, pcSubStr, pacBounds, pcDirection, pCaseSensitive)
			return This.FindNthSubStringBoundedByDCSIB(n, pcSubStr, pacBounds, pcDirection, pCaseSensitive)

		#==

		def NthSubStringBetweenDCSIB(n, pcSubStr, pcBound1, pcBound2, pcDirection, pCaseSensitive)
			return This.FindNthSubStringBetweenDCSIB(n, pcSubStr, pcBound1, pcBound2, pcDirection, pCaseSensitive)

		def NthSubStringBoundedByDCSIB(n, pcSubStr, pacBounds, pcDirection, pCaseSensitive)
			return This.FindNthSubStringBoundedByDCSIB(n, pcSubStr, pacBounds, pcDirection, pCaseSensitive)

		#>

	#-- WITHOUT CASESENSITIVITY

	def FindNthSubStringBetweenDIB(n, pcSubStr, pcBound1, pcBound2, pcDirection)
		return This.FindNthSubStringBetweenDCSIB(n, pcSubStr, pcBound1, pcBound2, pcDirection, TRUE)

		#< @FunctionAlternativeForms

		def FindNthSubStringBoundedByDIB(n, pcSubStr, pacBounds, pcDirection)
			return This.FindBoundedByDIB(n, pcSubStr, pacBounds, pcDirection)

		#--
	
		def FindNthSubStringBetweenDIBZ(n, pcSubStr, pcBound1, pcBound2, pcDirection)
			return This.FindNthSubStringBetweenDIB(n, pcSubStr, pcBound1, pcBound2, pcDirection)

		def FindNthSubStringBoundedByDIBZ(n, pcSubStr, pacBounds, pcDirection)
			return This.FindNthSubStringBoundedByDIB(n, pcSubStr, pacBounds, pcDirection)

		#==

		def NthSubStringBetweenDIB(n, pcSubStr, pcBound1, pcBound2, pcDirection)
			return This.FindNthSubStringBetweenDIB(n, pcSubStr, pcBound1, pcBound2, pcDirection)

		def NthSubStringBoundedByDIB(n, pcSubStr, pacBounds, pcDirection)
			return This.FindNthSubStringBoundedByDIB(n, pcSubStr, pacBounds, pcDirection)

		#>

	  #-----------------------------------------------------------------------------------------------------------------------------#
	 #  GETTING THE SUBSTRING AND ITS NTH OCCURRENCE BETWEEN TWO GIVEN SUBSTRINGS GOING IN A GIVEN DIRECTION AND INCLUDING BOUNDS  #
	#-----------------------------------------------------------------------------------------------------------------------------#

	def NthSubStringBetweenDCSIBZ(n, pcSubStr, pcBound1, pcBound2, pcDirection, pCaseSensitive)
		aResult = [ pcSubStr, This.FindNthSubStringBetweenDCSIBZ(n, pcSubStr, pcBound1, pcBound2, pcDirection, pCaseSensitive) ]
		return aResult

		def NthSubStringBoundedByDCSIBZ(n, pcSubStr, pacBounds, pcDirection, pCaseSensitive)
			if isString(pacBounds)
				return This.NthSubStringBetweenDCSIBZ(n, pcSubStr, pacBounds, pacBounds, pcDirection, pCaseSensitive)

			but isList(pacBounds) and Q(pacBounds).IsPairOfStrings()
				return This.NthSubStringBetweenDCSIBZ(n, pcSubStr, pacBounds[1], pacBounds[2], pcDirection, pCaseSensitive)

			else
				StzRaise("Incorrect param type! pacBounds must be a string or pair of strings.")
			ok

	#-- WITHOUT CASESENSITIVITY

	def NthSubStringBetweenDIBZ(n, pcSubStr, pcBound1, pcBound2, pcDirection)
		return This.NthSubStringBetweenDCSIBZ(n, pcSubStr, pcBound1, pcBound2, pcDirection, TRUE)

	   #-------------------------------------------------------------------------------#
	  #  FINDING NTH OCCURRENCE OF A SUBSTRING BOUNDED BY TWO OTHER SUBSTRINGS GOING  #
	 #  IN A GIVENDIRECTION, INCLUDING BOUNDS, AND RETURNING POSITIONS AS SECTIONS   # 
	#===============================================================================#

	def FindNthSubStringBetweenDCSIBZZ(n, pcSubStr, pcBound1, pcBound2, pcDirection, pCaseSensitive)

		n1 = This.FindNthSubStringBetweenDCSIBZ(n, pcSubStr, pcBound1, pcBound2, pcDirection, pCaseSensitive)
		nLenBound1 = Q(pcBound1).NumberOfChars()
		nLenBound2 = Q(pcBound2).NumberOfChars()
		nLenSubStr = Q(pcSubStr).NumberOfChars()

		n2 = n1 + nLenBound1 + nLenSubStr + nLenBound2 - 3
		aResult = [ n1, n2]

		return aResult

		#< @FunctionAlternativeForms

		def FindNthSubStringBoundedByDCSIBZZ(n, pcSubStr, pacBounds, pcDirection, pCaseSensitive)
			if isString(pacBounds)
				return This.FindNthSubStringBetweenDCSIBZZ(n, pcSubStr, pacBounds, pacBounds, pcDirection, pCaseSensitive)

			but isList(pacBounds) and Q(pacBounds).IsPairOfNumbers()
				return This.FindNthSubStringBetweenDCSIBZZ(n, pcSubStr, pacBounds[1], pacBounds[2], pcDirection, pCaseSensitive)

			else
				StzRaise("Incorrect param type! pacBounds must be a string or pair of strings.")

			ok

		#--
	
		def FindNthSubStringBetweenAsSectionsDCSIB(n, pcSubStr, pcBound1, pcBound2, pcDirection, pCaseSensitive)
			return This.FindNthSubStringBetweenDCSIBZZ(n, pcSubStr, pcBound1, pcBound2, pcDirection, pCaseSensitive)

		def FindNthSubStringBoundedByAsSectionsDCSIB(n, pcSubStr, pacBounds, pcDirection, pCaseSensitive)
			return This.FindBoundedByDCSIBZZ(n, pcSubStr, pacBounds, pcDirection, pCaseSensitive)

		#==

		def NthSubStringBetweenAsSectionsDCSIB(n, pcSubStr, pcBound1, pcBound2, pcDirection, pCaseSensitive)
			return This.FindNthSubStringBetweenDCIBSZZ(n, pcSubStr, pcBound1, pcBound2, pcDirection, pCaseSensitive)

		def NthSubStringBoundedByAsSectionsDCSIB(n, pcSubStr, pacBounds, pcDirection, pCaseSensitive)
			return This.FindNthSubStringBoundedByDCSIBZZ(n, pcSubStr, pacBounds, pcDirection, pCaseSensitive)

		#>

	#-- WITHOUT CASESENSITIVITY

	def FindNthSubStringBetweenDIBZZ(n, pcSubStr, pcBound1, pcBound2, pcDirection)
		return This.FindNthSubStringBetweenDIBZZ(n, pcSubStr, pcBound1, pcBound2, pcDirection)

		#< @FunctionAlternativeForms

		def FindNthSubStringBoundedByDIBZZ(n, pcSubStr, pacBounds, pcDirection)
			return This.FindNthSubStringBoundedByDIBZZ(n, pcSubStr, pacBounds, pcDirection)

		#--
	
		def FindNthSubStringBetweenAsSectionsDIB(n, pcSubStr, pcBound1, pcBound2, pcDirection)
			return This.FindNthSubStringBetweenDIBZZ(n, pcSubStr, pcBound1, pcBound2, pcDirection)

		def FindNthSubStringBoundedByAsSectionsDIB(n, pcSubStr, pacBounds, pcDirection)
			return This.FindNthSubStringBoundedByDIBZZ(n, pcSubStr, pacBounds, pcDirection)

		#==

		def NthSubStringBetweenAsSectionsDIB(n, pcSubStr, pcBound1, pcBound2, pcDirection)
			return This.FindNthSubStringBetweenDIBZZ(n, pcSubStr, pcBound1, pcBound2, pcDirection)

		def NthSubStringBoundedByAsSectionsDIB(n, pcSubStr, pacBounds, pcDirection)
			return This.FindNthSubStringBoundedByDIBZZ(n, pcSubStr, pacBounds, pcDirection)

		#>

	  #---------------------------------------------------------------------------------------------------------------------#
	 #  GETTING THE SUBSTRING AND ITS NTH OCCURRENCE (AS SECTION) BETWEEN TWO GIVEN SUBSTRINGS GOING IN A GIVEN DIRECTION  #
	#---------------------------------------------------------------------------------------------------------------------#

	def NthSubStringBetweenDCSIBZZ(n, pcSubStr, pcBound1, pcBound2, pcDirection, pCaseSensitive)
		aResult = [ pcSubStr, This.FindNthSubStringBetweenDCSIBZZ(n, pcSubStr, pcBound1, pcBound2, pcDirection, pCaseSensitive) ]
		return aResult

		#< @FunctionAlternativeForms

		def NthSubStringBoundedByDCSIBZZ(n, pcSubStr, pacBounds, pcDirection, pCaseSensitive)
			if isString(pacBounds)
				return This.NthSubStringBetweenDCSIBZZ(n, pcSubStr, pacBounds, pacBounds, pcDirection, pCaseSensitive)

			but isList(pacBounds) and Q(pacBounds).IsPairOfStrings()
				return This.NthSubStringBetweenDCSIBZZ(n, pcSubStr, pacBounds[1], pacBounds[2], pcDirection, pCaseSensitive)

			else
				StzRaise("Incorrect param type! pacBounds must be a string or pair of strings.")
			ok

		#--

		def NthSubStringBetweenAsSectionDCSIB(n, pcSubStr, pcBound1, pcBound2, pcDirection, pCaseSensitive)
			return This.NthSubStringBetweenDCSIBZZ(n, pcSubStr, pcBound1, pcBound2, pcDirection, pCaseSensitive)

		def NthSubStringBoundedByAsSectionDCSIB(n, pcSubStr, pacBounds, pcDirection, pCaseSensitive)
			return This.NthSubStringBoundedByDCSIBZZ(n, pcSubStr, pacBounds, pcDirection, pCaseSensitive)

		#>

	#-- WITHOUT CASESENSITIVITY

	def  NthSubStringBetweenDIBZZ(n, pcSubStr, pcBound1, pcBound2, pcDirection)
		return This. NthSubStringBetweenDCSIBZZ(n, pcSubStr, pcBound1, pcBound2, pcDirection, TRUE)

		#< @FunctionAlternativeForms

		def NthSubStringBoundedByDIBZZ(n, pcSubStr, pacBounds, pcDirection)
			return This.NthSubStringBoundedByDCSIBZZ(n, pcSubStr, pacBounds, pcDirection, TRUE)

		#--

		def NthSubStringBetweenAsSectionDIB(n, pcSubStr, pcBound1, pcBound2, pcDirection)
			return This.NthSubStringBetweenDIBZZ(n, pcSubStr, pcBound1, pcBound2, pcDirection)

		def NthSubStringBoundedByAsSectionDIB(n, pcSubStr, pacBounds, pcDirection)
			return This.NthSubStringBoundedByDIBZZ(n, pcSubStr, pacBounds, pcDirection)

		#>

	   #-------------------------------------------------------------------------#
	  #  FINDING NTH OCCURRENCE OF A SUBSTRING BOUNDED BY TWO OTHER SUBSTRINGS  #
	 #  STARTING AT A GIVEN POSITION AND GOING IN A GIVEN DIRECTION            #
	#=========================================================================#

	def FindNthSubStringBetweenSDCS(n, pcSubStr, pcBound1, pcBound2, pnStartingAt, pcDirection, pCaseSensitive)

		# Checking params

		if isList(pcDirection) and Q(pcDirection).IsOneOfTheseNamedParams([ :Going, :Direction ])
			pcDirection = pcDirection[2]
		ok

		if NOT ( isString(pcDirection) and Q(pcDirection).IsOneOfThese([ :Forward, :Backward ]) )
			StzRaise("Incorrect param type! pcDirection must be a string equal to :Forward or :Backward.")
		ok

		# Doing the job

		if pcDirection = :Forward
			return This.FindNextNthSubStringBetweenSCS(n, pcSubStr, pcBound1, pcBound2, pnStartingAt, pCaseSensitive)

		else // pcDirection = :Backward
			return This.FindPreviousNthSubStringBetweenSCS(n, pcSubStr, pcBound1, pcBound2, pnStartingAt, pCaseSensitive)

		ok

		#< @FunctionAlternativeForms

		def FindNthSubStringBoundedBySDCS(n, pcSubStr, pacBounds, pnStartingAt, pcDirection, pCaseSensitive)
			if isString(pacBounds)
				return This.FindNthSubStringBetweenSDCS(n, pcSubStr, pacBounds, pacBounds, pnStartingAt, pcDirection, pCaseSensitive)

			but isLsit(pacBounds) and Q(pacBounds).IsPairOfStrings()
				return This.FindNthSubStringBetweenSDCS(n, pcSubStr, pacBounds[1], pacBounds[2], pnStartingAt, pcDirection, pCaseSensitive)

			else
				StzRaise("Incorrect param type! pacBounds must be a string or pair of strings.")

			ok

		#--
	
		def FindNthSubStringBetweenSDCSZ(n, pcSubStr, pcBound1, pcBound2, pnStartingAt, pcDirection, pCaseSensitive)
			return This.FindNthSubStringBetweenSDCS(n, pcSubStr, pcBound1, pcBound2, pnStartingAt, pcDirection, pCaseSensitive)

		def FindNthSubStringBoundedBySDCSZ(n, pcSubStr, pacBounds, pnStartingAt, pcDirection, pCaseSensitive)
			return This.FindNthSubStringBoundedBySDCS(n, pcSubStr, pacBounds, pnStartingAt, pcDirection, pCaseSensitive)

		#==

		def NthSubStringBetweenSDCS(n, pcSubStr, pcBound1, pcBound2, pnStartingAt, pcDirection, pCaseSensitive)
			return This.FindNthSubStringBetweenSD(n, pcSubStr, pcBound1, pcBound2, pnStartingAt, pcDirection)

		def NthSubStringBoundedBySDCS(n, pcSubStr, pacBounds, pnStartingAt, pcDirection, pCaseSensitive)
			return This.FindNthSubStringBoundedBySDCS(n, pcSubStr, pacBounds, pnStartingAt, pcDirection, pCaseSensitive)

		#>

	#-- WITHOUT CASESENSITIVITY

	def FindNthSubStringBetweenSD(n, pcSubStr, pcBound1, pcBound2, pnStartingAt, pcDirection)
		return This.FindNthSubStringBetweenSDCS(n, pcSubStr, pcBound1, pcBound2,pnStartingAt, pcDirection, TRUE)

		#< @FunctionAlternativeForms

		def FindNthSubStringBoundedBySD(n, pcSubStr, pacBounds, pnStartingAt, pcDirection)
			return This.FindNthSubStringBoundedBySD(n, pcSubStr, pacBounds, pnStartingAt, pcDirection)

		#--
	
		def FindNthSubStringBetweenSDZ(n, pcSubStr, pcBound1, pcBound2, pnStartingAt, pcDirection)
			return This.FindNthSubStringBetweenSD(n, pcSubStr, pcBound1, pcBound2, pnStartingAt, pcDirection)

		def FindNthSubStringBoundedBySDZ(n, pcSubStr, pacBounds, pnStartingAt, pcDirection)
			return This.FindNthSubStringBoundedBySD(n, pcSubStr, pacBounds, pnStartingAt, pcDirection)

		#==

		def NthSubStringBetweenSD(n, pcSubStr, pcBound1, pcBound2, pnStartingAt, pcDirection)
			return This.FindNthSubStringBetweenSD(n, pcSubStr, pcBound1, pcBound2, pnStartingAt, pcDirection)

		def NthSubStringBoundedBySD(n, pcSubStr, pacBounds, pnStartingAt, pcDirection)
			return This.FindNthSubStringBoundedBySD(n, pcSubStr, pacBounds, pnStartingAt, pcDirection)

		#>

	  #-----------------------------------------------------------------------------------------------------------------------------------------#
	 #  GETTING THE SUBSTRING AND ITS NTH OCCURRENCE BETWEEN TWO GIVEN SUNSTRINGS STARTING AT A GIVEN POSITION AND GOING IN A GIVEN DIRECTION  #
	#-----------------------------------------------------------------------------------------------------------------------------------------#

	def NthSubStringBetweenSDCSZ(n, pcSubStr, pcBound1, pcBound2, pnStartingAt, pcDirection, pCaseSensitive)
		aResult = [ pcSubStr, This.FindNthSubStringBetweenSDCSZ(n, pcSubStr, pcBound1, pcBound2, pnStartingAt, pcDirection, pCaseSensitive) ]
		return aResult

		def NthSubStringBoundedBySDCSZ(n, pcSubStr, pacBounds, pnStartingAt, pcDirection, pCaseSensitive)
			if isString(pacBounds)
				return This.NthSubStringBetweenSDCSZ(n, pcSubStr, pacBounds, pacBounds, pnStartingAt, pcDirection, pCaseSensitive)

			but isList(pacBounds) and Q(pacBouds).IsPairOfStrings()
				return This.NthSubStringBetweenSDCSZ(n, pcSubStr, pacBounds[1], pacBounds[2], pnStartingAt, pcDirection, pCaseSensitive)

			else
				StzRaise("Incorrect param type! pacBounds must be a string or pair of strings.")
			ok

	#-- WITHOUT CASESENSIVITY

	def NthSubStringBetweenSDZ(n, pcSubStr, pcBound1, pcBound2, pnStartingAt, pcDirection)
		return This.NthSubStringBetweenSDCSZ(n, pcSubStr, pcBound1, pcBound2, pnStartingAt, pcDirection, TRUE)

		def NthSubStringBoundedBySDZ(n, pcSubStr, pacBounds, pnStartingAt, pcDirection)
			return This.NthSubStringBoundedBySDCSZ(n, pcSubStr, pacBounds, pnStartingAt, pcDirection, TRUE)

	   #----------------------------------------------------------------------------------------#
	  #  FINDING NTH OCCURRENCE OF A SUBSTRING BOUNDED BY TWO OTHER SUBSTRINGSS STARTING       #
	 #  AT A GIVEN POSITION, GOING IN A GIVEN DIRECTION, AND RETURNING POSITIONS AS SECTIONS  #
	#========================================================================================#

	def FindNthSubStringBetweenSDCSZZ(n, pcSubStr, pcBound1, pcBound2, pnStartingAt, pcDirection, pCaseSensitive)

		n1 = This.FindNthSubStringBetweenSDCSZ(n, pcSubStr, pcBound1, pcBound2, pnStartingAt, pcDirection, pCaseSensitive)
		nLenSubStr = Q(pcSubStr).NumberOfChars()
		n2 = n1 + nLenSubStr - 1
		aResult = [n1, n2]

		return aResult

		#< @FunctionAlternativeForms

		def FindNthSubStringBoundedBySDCSZZ(n, pcSubStr, pacBounds, pnStartingAt, pcDirection, pCaseSensitive)
			return This.FindBoundedBySDCSZZ(n, pcSubStr, pacBounds, pnStartingAt, pcDirection, pCaseSensitive)

		#--
	
		def FindNthSubStringBetweenAsSectionsSDCS(n, pcSubStr, pcBound1, pcBound2, pnStartingAt, pcDirection, pCaseSensitive)
			return This.FindNthSubStringBetweenSDCSZZ(n, pcSubStr, pcBound1, pcBound2, pnStartingAt, pcDirection, pCaseSensitive)

		def FindNthSubStringBoundedByAsSectionsSDCS(n, pcSubStr, pacBounds, pnStartingAt, pcDirection, pCaseSensitive)
			return This.FindNthSubStringBoundedBySDCSZZ(n, pcSubStr, pacBounds, pnStartingAt, pcDirection, pCaseSensitive)

		#==

		def NthSubStringBoundedByAsSectionsSDCS(n, pcSubStr, pacBounds, pnStartingAt, pcDirection, pCaseSensitive)
			return This.FindNthSubStringBoundedBySDCSZZ(n, pcSubStr, pacBounds, pnStartingAt, pcDirection, pCaseSensitive)

		#>

	#-- WITHOUT CASESENSITIVITY

	def FindNthSubStringBetweenSDZZ(n, pcSubStr, pcBound1, pcBound2, pnStartingAt, pcDirection)
		return This.FindNthSubStringBetweenSDCSZZ(n, pcSubStr, pcBound1, pcBound2, pnStartingAt, pcDirection, TRUE)

		#< @FunctionAlternativeForms

		def FindNthSubStringBoundedBySDZZ(n, pcSubStr, pacBounds, pnStartingAt, pcDirection)
			return This.FindBoundedBySDZZ(n, pcSubStr, pacBounds, pnStartingAt, pcDirection)

		#--
	
		def FindNthSubStringBetweenAsSectionsSD(n, pcSubStr, pcBound1, pcBound2, pnStartingAt, pcDirection)
			return This.FindNthSubStringBetweenSDZZ(n, pcSubStr, pcBound1, pcBound2, pnStartingAt, pcDirection)

		def FindNthSubStringBoundedByAsSectionsSD(n, pcSubStr, pacBounds, pnStartingAt, pcDirection)
			return This.FindNthSubStringBoundedBySDZZ(n, pcSubStr, pacBounds, pnStartingAt, pcDirection)

		#==

		def NthSubStringBetweenAsSectionsSD(n, pcSubStr, pcBound1, pcBound2, pnStartingAt, pcDirection)
			return This.FindNthSubStringBetweenSDZZ(n, pcSubStr, pcBound1, pcBound2, pnStartingAt, pcDirection)

		def NthSubStringBoundedByAsSectionsSD(n, pcSubStr, pacBounds, pnStartingAt, pcDirection)
			return This.FindNthSubStringBoundedBySDZZ(n, pcSubStr, pacBounds, pnStartingAt, pcDirection)

		#>

	   #-------------------------------------------------------------------------------#
	  #  GETTING THE SUBSTRING AND ITS NTH OCCURRENCE (AS SECTION) BETWEEN TWO GIVEN  #
	 #  SUBSTRINGS STARTING AT A GIVEN POSITION AND GOININ IN A GIVEN DIRECTION      #
	#-------------------------------------------------------------------------------#

	def NthSubStringBetweenSDCSZZ(n, pcSubStr, pcBound1, pcBound2, pnStartingAt, pcDirection, pCaseSensitive)
		aResult = [ pcSubStr, This.NthSubStringBetweenSDCSZZ(n, pcSubStr, pcBound1, pcBound2, pnStartingAt, pcDirection, pCaseSensitive) ]
		return aResult

		#< @FunctionAlternativeForms

		def NthSubStringBoundedBySDCSZZ(n, pcSubStr, pacBounds, pnStartingAt, pcDirection, pCaseSensitive)
			if isString(pacBounds)
				return This.NthSubStringBetweenSDCSZZ(n, pcSubStr, pacBounds, pacBunds, pnStartingAt, pcDirection, pCaseSensitive)

			but isList(pacBounds) and Q(pacBounds).IsPairOfStrings()
				return This.NthSubStringBetweenSDCSZZ(n, pcSubStr, pacBounds[1], pacBounds[2], pnStartingAt, pcDirection, pCaseSensitive)

			else
				Stzraise("Incorrect param type! pacBounds must be a string or pair of strings.")
			ok

		#--

		def NthSubStringBetweenAsSection_SDCS(n, pcSubStr, pcBound1, pcBound2, pnStartingAt, pcDirection, pCaseSensitive)
			return This.NthSubStringBetweenSDCSZZ(n, pcSubStr, pcBound1, pcBound2, pnStartingAt, pcDirection, pCaseSensitive)

		def NthSubStringBoundedByAsSection_SDCS(n, pcSubStr, pacBounds, pnStartingAt, pcDirection, pCaseSensitive)
			return This.NthSubStringBoundedBySDCSZZ(n, pcSubStr, pacBounds, pnStartingAt, pcDirection, pCaseSensitive)

		#>

	#-- WTIHOUT CASESENSITIVE

	def NthSubStringBetweenSDZZ(n, pcSubStr, pcBound1, pcBound2, pnStartingAt, pcDirection)
		return This.NthSubStringBetweenSDCSZZ(n, pcSubStr, pcBound1, pcBound2, pnStartingAt, pcDirection, TRUE)

		#< @FunctionAlternativeForms

		def NthSubStringBoundedBySDZZ(n, pcSubStr, pacBounds, pnStartingAt, pcDirection)
			return This.NthSubStringBoundedBySDCSZZ(n, pcSubStr, pacBounds, pnStartingAt, pcDirection, TRUE)

		#--

		def NthSubStringBetweenAsSection_SD(n, pcSubStr, pcBound1, pcBound2, pnStartingAt, pcDirection)
			return This.NthSubStringBetweenSDZZ(n, pcSubStr, pcBound1, pcBound2, pnStartingAt, pcDirection)

		def NthSubStringBoundedByAsSection_SD(n, pcSubStr, pacBounds, pnStartingAt, pcDirection)
			return This.NthSubStringBoundedBySDZZ(n, pcSubStr, pacBounds, pnStartingAt, pcDirection)

		#>

	   #-----------------------------------------------------------------------------------#
	  #  FINDING NTH OCCURRENCE OF A SUBSTRING BOUNDED BY TWO OTHER SUBSTRINGSS STARTING  #
	 #  AT A GIVEN POSITION, GOING IN A GIVEN DIRECTION, AND INCLUDING BOUNDS            #
	#===================================================================================#

	def FindNthSubStringBetweenSDCSIB(n, pcSubStr, pcBound1, pcBound2, pnStartingAt, pcDirection, pCaseSensitive)
		nPos = This.FindNthSubStringBetweenSDCS(n, pcSubStr, pcBound1, pcBound2, pnStartingAt, pcDirection, pCaseSensitive)
		nLenBound1 = Q(pcBound1).NumberOfChars()
		nResult = nPos - nLenBound1 + 1

		return nResult

		#< @FunctionAlternativeForms

		def FindNthSubStringBoundedBySDCSIB(n, pcSubStr, pacBounds, pnStartingAt, pcDirection, pCaseSensitive)
			if isString(pacBounds)
				return This.FindNthSubStringBetweenSDCSIB(n, pcSubStr, pacBounds, pacBounds, pnStartingAt, pcDirection, pCaseSensitive)

			but isLsit(pacBounds) and Q(pacBounds).IsPairOfStrings()
				return This.FindNthSubStringBetweenSDCSIB(n, pcSubStr, pacBounds[1], pacBounds[2], pnStartingAt, pcDirection, pCaseSensitive)

			else
				StzRaise("Incorrect param type! pacBounds must be a string or pair of strings.")

			ok

		#--
	
		def FindNthSubStringBetweenSDCSIBZ(n, pcSubStr, pcBound1, pcBound2, pnStartingAt, pcDirection, pCaseSensitive)
			return This.FindNthSubStringBetweenSDCSIB(n, pcSubStr, pcBound1, pcBound2, pnStartingAt, pcDirection, pCaseSensitive)

		def FindNthSubStringBoundedBySDCSIBZ(n, pcSubStr, pacBounds, pnStartingAt, pcDirection, pCaseSensitive)
			return This.FindNthSubStringBoundedBySDCSIB(n, pcSubStr, pacBounds, pnStartingAt, pcDirection, pCaseSensitive)

		#==

		def NthSubStringBetweenSDCSIB(n, pcSubStr, pcBound1, pcBound2, pnStartingAt, pcDirection, pCaseSensitive)
			return This.FindNthSubStringBetweenSDIB(n, pcSubStr, pcBound1, pcBound2, pnStartingAt, pcDirection)

		def NthSubStringBoundedBySDCSIB(n, pcSubStr, pacBounds, pnStartingAt, pcDirection, pCaseSensitive)
			return This.FindBoundedBySDCSIB(n, pcSubStr, pacBounds, pnStartingAt, pcDirection, pCaseSensitive)

		#>

	#-- WITHOUT CASESENSITIVITY

	def FindNthSubStringBetweenSDIB(n, pcSubStr, pcBound1, pcBound2, pnStartingAt, pcDirection)
		return This.FindNthSubStringBetweenSDCSIB(n, pcSubStr, pcBound1, pcBound2,pnStartingAt, pcDirection, TRUE)

		#< @FunctionAlternativeForms

		def FindNthSubStringBoundedBySDIB(n, pcSubStr, pacBounds, pnStartingAt, pcDirection)
			return This.FindNthSubStringBoundedBySDIB(n, pcSubStr, pacBounds, pnStartingAt, pcDirection)

		#--
	
		def FindNthSubStringBetweenSDIBZ(n, pcSubStr, pcBound1, pcBound2, pnStartingAt, pcDirection)
			return This.FindNthSubStringBetweenSDIB(n, pcSubStr, pcBound1, pcBound2, pnStartingAt, pcDirection)

		def FindNthSubStringBoundedBySDIBZ(n, pcSubStr, pacBounds, pnStartingAt, pcDirection)
			return This.FindNthSubStringBoundedBySDIB(n, pcSubStr, pacBounds, pnStartingAt, pcDirection)

		#==

		def NthSubStringBetweenSDIB(n, pcSubStr, pcBound1, pcBound2, pnStartingAt, pcDirection)
			return This.FindNthSubStringBetweenSDIB(n, pcSubStr, pcBound1, pcBound2, pnStartingAt, pcDirection)

		def NthSubStringBoundedBySDIB(n, pcSubStr, pacBounds, pnStartingAt, pcDirection)
			return This.FindNthSubStringBoundedBySDIB(n, pcSubStr, pacBounds, pnStartingAt, pcDirection)

		#>

	   #-----------------------------------------------------------------------------#
	  #  GETTING THE SUBSTRING AND ITS NTH OCCURRENCE BETWEEN TWO GIVEN SUBSTRINGS  #
	 #  GOING IN A GIVEN DIRECTION AND INCLUDING BOUNDS                            #
	#-----------------------------------------------------------------------------#

	def NthSubStringBetweenSDCSIBZ(n, pcSubStr, pcBound1, pcBound2, pnStartingAt, pcDirection, pCaseSensitive)
		aResult = [ pcSubStr, This.NthSubStringBetweenSDCSIBZ(n, pcSubStr, pcBound1, pcBound2, pnStartingAt, pcDirection, pCaseSensitive) ]
		return aResult

		def NthSubStringBoundedBySDCSIBZ(n, pcSubStr, pacBounds, pnStartingAt, pcDirection, pCaseSensitive)
			if isString(pacBounds)
				return This.NthSubStringBetweenSDCSIBZ(n, pcSubStr, pacBound, pacBound, pnStartingAt, pcDirection, pCaseSensitive)

			but isLsit(pacBounds) and Q(pacBounds).IsPairOfStrings()
				return This.NthSubStringBetweenSDCSIBZ(n, pcSubStr, pacBounds[1], pacBounds[2], pnStartingAt, pcDirection, pCaseSensitive)

			else
				StzRaise("Incorrect param type! pacBounds must be a string or pair of strings.")

			ok

	#-- WITHOUT CASESENSITIVE

	def NthSubStringBetweenSDIBZ(n, pcSubStr, pcBound1, pcBound2, pnStartingAt, pcDirection)
		return This.NthSubStringBetweenSDCSIBZ(n, pcSubStr, pcBound1, pcBound2, pnStartingAt, pcDirection, TRUE)

		def NthSubStringBoundedBySDIBZ(n, pcSubStr, pacBounds, pnStartingAt, pcDirection)
			return This.NthSubStringBoundedBySDCSIBZ(n, pcSubStr, pacBounds, pnStartingAt, pcDirection, TRUE)

	   #-----------------------------------------------------------------------------------------------#
	  #  FINDING NTH OCCURRENCE OF A SUBSTRING BOUNDED BY TWO OTHER SUBSTRINGSS STARTING AT A GIVEN   #
	 #  POSITION, GOING IN A GIVEN DIRECTION, INCLUDING BOUNDS, AND RETURNING POSITIONS AS SECTIONS  #
	#===============================================================================================#

	def FindNthSubStringBetweenSDCSIBZZ(n, pcSubStr, pcBound1, pcBound2, pnStartingAt, pcDirection, pCaseSensitive)
		n1 = This.FindNthSubStringBetweenSDCSIB(n, pcSubStr, pcBound1, pcBound2, pnStartingAt, pcDirection, pCaseSensitive)
		nLenBound2 = Q(pcBound2).NumberOfChars()
		nLenSubStr = Q(pcSubStr).NumberOfChars()

		n2 = n1 + nLenSubStr + nLenSubStr - 2

		#< @FunctionAlternativeForms

		def FindNthSubStringBoundedBySDCSIBZZ(n, pcSubStr, pacBounds, pnStartingAt, pcDirection, pCaseSensitive)
			return This.FindNthSubStringBoundedBySDCSIBZZ(n, pcSubStr, pacBounds, pnStartingAt, pcDirection, pCaseSensitive)

		#--
	
		def FindNthSubStringBetweenAsSectionsSDCSIB(n, pcSubStr, pcBound1, pcBound2, pnStartingAt, pcDirection, pCaseSensitive)
			return This.FindNthSubStringBetweenSDCSIBZZ(n, pcSubStr, pcBound1, pcBound2, pnStartingAt, pcDirection, pCaseSensitive)

		def FindNthSubStringBoundedByAsSectionsSDCSIB(n, pcSubStr, pacBounds, pnStartingAt, pcDirection, pCaseSensitive)
			return This.FindNthSubStringBoundedBySDCSIBZZ(n, pcSubStr, pacBounds, pnStartingAt, pcDirection, pCaseSensitive)

		#==

		def NthSubStringBetweenAsSectionsSDCSIB(n, pcSubStr, pcBound1, pcBound2, pnStartingAt, pcDirection, pCaseSensitive)
			return This.FindNthSubStringBetweenSDCSIBZZ(n, pcSubStr, pcBound1, pcBound2, pnStartingAt, pcDirection, pCaseSensitive)

		def NthSubStringBoundedByAsSectionsSDCSIB(n, pcSubStr, pacBounds, pnStartingAt, pcDirection, pCaseSensitive)
			return This.FindNthSubStringBoundedBySDCSIBZZ(n, pcSubStr, pacBounds, pnStartingAt, pcDirection, pCaseSensitive)

		#>

	#-- WITHOUT CASESENSITIVITY

	def FindNthSubStringBetweenSDIBZZ(n, pcSubStr, pcBound1, pcBound2, pnStartingAt, pcDirection)
		return This.FindNthSubStringBetweenSDCSIBZZ(n, pcSubStr, pcBound1, pcBound2, pnStartingAt, pcDirection, TRUE)

		#< @FunctionAlternativeForms

		def FindNthSubStringBoundedBySDIBZZ(n, pcSubStr, pacBounds, pnStartingAt, pcDirection)
			return This.FindNthSubStringBoundedBySDIBZZ(n, pcSubStr, pacBounds, pnStartingAt, pcDirection)

		#--
	
		def FindNthSubStringBetweenAsSectionsSDIB(n, pcSubStr, pcBound1, pcBound2, pnStartingAt, pcDirection)
			return This.FindNthSubStringBetweenSDIBZZ(n, pcSubStr, pcBound1, pcBound2, pnStartingAt, pcDirection)

		def FindNthSubStringBoundedByAsSectionsSDIB(n, pcSubStr, pacBounds, pnStartingAt, pcDirection)
			return This.FindNthSubStringBoundedBySDIBZZ(n, pcSubStr, pacBounds, pnStartingAt, pcDirection)

		#==

		def NthSubStringBetweenAsSectionsSDIB(n, pcSubStr, pcBound1, pcBound2, pnStartingAt, pcDirection)
			return This.FindNthSubStringBetweenSDIBZZ(n, pcSubStr, pcBound1, pcBound2, pnStartingAt, pcDirection)

		def NthSubStringBoundedByAsSectionsSDIB(n, pcSubStr, pacBounds, pnStartingAt, pcDirection)
			return This.FindNthSubStringBoundedBySDIBZZ(n, pcSubStr, pacBounds, pnStartingAt, pcDirection)

		#>

	    #-------------------------------------------------------------------------------#
	   #  GETTING THE NTH SUBSTRING AND ITS OCCURRENCE (AS SECTION) BETWEEN TWO GIVEN  #
	  #  SUBSTRINGS STARTING AT A GIVEN POSITION, GOING IN A GIVEN DIRECTION, AND     #
	 #  ICLCUDING BOUNDS                                                             #
	#-------------------------------------------------------------------------------#

	def NthSubStringBetweenSDCSIBZZ(n, pcSubStr, pcBound1, pcBound2, pnStartingAt, pcDirection, pCaseSensitive)
		aResult = [ pcSubStr, This.FindNthSubStringBetweenSDCSIBZZ(n, pcSubStr, pcBound1, pcBound2, pnStartingAt, pcDirection, pCaseSensitive) ]
		return aResult

		#< @FunctionAlternativeForms

		def NthSubStringBoundedBySDCSIBZZ(n, pcSubStr, pacBounds, pnStartingAt, pcDirection, pCaseSensitive)
			if isString(pacBounds)
				return This.NthSubStringBetweenSDCSIBZZ(n, pcSubStr, pacBounds, pacBounds, pnStartingAt, pcDirection, pCaseSensitive)

			but isList(pacBounds) and Q(pacBounds).IsPairOfStrings()
				return This.NthSubStringBetweenSDCSIBZZ(n, pcSubStr, pacBounds[1], pacBounds[2], pnStartingAt, pcDirection, pCaseSensitive)

			else
				StzRaise("Incorrect param type! pacBounds must be a string or pair of strings.")
			ok

		#--

		def NthSubStringBetweenAsSection_SDCSIB(n, pcSubStr, pcBound1, pcBound2, pnStartingAt, pcDirection, pCaseSensitive)
			return This.NthSubStringBetweenSDCSIBZZ(n, pcSubStr, pcBound1, pcBound2, pnStartingAt, pcDirection, pCaseSensitive)

		def NthSubStringBoundedByAsSection_SDCSIBZZ(n, pcSubStr, pacBounds, pnStartingAt, pcDirection, pCaseSensitive)
			return This.NthSubStringBoundedBySDCSIBZZ(n, pcSubStr, pacBounds, pnStartingAt, pcDirection, pCaseSensitive)

		#>

	#-- WITHOUT CASESENSITIVITY

	def NthSubStringBetweenSDIBZZ(n, pcSubStr, pcBound1, pcBound2, pnStartingAt, pcDirection)
		return This.NthSubStringBetweenSDCSIBZZ(n, pcSubStr, pcBound1, pcBound2, pnStartingAt, pcDirection, TRUE)

		#< @FunctionAlternativeForms

		def NthSubStringBoundedBySDIBZZ(n, pcSubStr, pacBounds, pnStartingAt, pcDirection)
			return This.NthSubStringBoundedBySDCSIBZZ(n, pcSubStr, pacBounds, pnStartingAt, pcDirection, TRUE)

		#--

		def NthSubStringBetweenAsSection_SDIB(n, pcSubStr, pcBound1, pcBound2, pnStartingAt, pcDirection)
			return This.NthSubStringBetweenSDIBZZ(n, pcSubStr, pcBound1, pcBound2, pnStartingAt, pcDirection)

		def NthSubStringBoundedByAsSection_SDIBZZ(n, pcSubStr, pacBounds, pnStartingAt, pcDirection)
			return This.NthSubStringBoundedBySDIBZZ(n, pcSubStr, pacBounds, pnStartingAt, pcDirection)

		#>

	   #-------------------------------------------------------#
	  #  FINDING FIRST OCCURRENCE OF A SUBSTRING BOUNDED BY   #
	 #  TWO OTHER SUBSTRINGS AND RETURNING THEM AS SECTIONS  #
	#=======================================================#

	def FindFirstSubStringBetweenCSZZ(pcSubStr, pcBound1, pcBound2, pCaseSensitive)
		return This.FindNthSubStringBetweenCSZZ(1, pcSubStr, pcBound1, pcBound2, pCaseSensitive)

		#< @FunctionAlternativeForms

		def FindFirstSubStringBoundedByCSZZ(pcSubStr, pacBounds, pCaseSensitive)
			return This.FindNthSubStringBoundedByCSZZ(1, pcSubStr, pacBounds, pCaseSensitive)

		#--
	
		def FindFirstSubStringBetweenAsSectionsCS(pcSubStr, pcBound1, pcBound2, pCaseSensitive)
			return This.FindFirstSubStringBetweenCSZZ(pcSubStr, pcBound1, pcBound2, pCaseSensitive)

		def FindFirstSubStringBoundedByAsSectionsCS(pcSubStr, pacBounds, pCaseSensitive)
			return This.FindFirstSubStringBoundedByCSZZ(pcSubStr, pacBounds, pCaseSensitive)

		#==

		def FirstSubStringBetweenAsSectionsCS(pcSubStr, pcBound1, pcBound2, pCaseSensitive)
			return This.FindFirstSubStringBetweenCSZZ(pcSubStr, pcBound1, pcBound2, pCaseSensitive)

		def FirstSubStringBoundedByAsSectionsCS(pcSubStr, pacBounds, pCaseSensitive)
			return This.FindFirstSubStringBoundedByCSZZ(pcSubStr, pacBounds, pCaseSensitive)

		#>

	#-- WITHOUT CASESENSITIVITY

	def FindFirstSubStringBetweenZZ(pcSubStr, pcBound1, pcBound2)
		return This.FindFirstSubStringBetweenCSZZ(pcSubStr, pcBound1, pcBound2, TRUE)

		#< @FunctionAlternativeForms

		def FindFirstSubStringBoundedByZZ(pcSubStr, pacBounds)
			return This.FindFirstSubStringBoundedByZZ(pcSubStr, pacBounds)

		#--
	
		def FindFirstSubStringBetweenAsSections(pcSubStr, pcBound1, pcBound2)
			return This.FindFirstSubStringBetweenZZ(pcSubStr, pcBound1, pcBound2)

		def FindFirstSubStringBoundedByAsSections(pcSubStr, pacBounds)
			return This.FindFirstSubStringBoundedByZZ(pcSubStr, pacBounds)

		#==

		def FirstSubStringBetweenAsSections(pcSubStr, pcBound1, pcBound2)
			return This.FindFirstSubStringBetweenZZ(pcSubStr, pcBound1, pcBound2)

		def FirstSubStringBoundedByAsSections(pcSubStr, pacBounds)
			return This.FindFirstSubStringBoundedByZZ(pcSubStr, pacBounds)

		#>

	  #--------------------------------------------------------------------------------------------#
	 #  GETTING THE SUBSTRING AND ITS FIRST OCCURRENCE (AS SECTION) BETWEEN TWO GIVEN SUBSTRINGS  #
	#--------------------------------------------------------------------------------------------#

	def FirstSubStringBetweenCSZZ(pcSubStr, pcBound1, pcBound2, pCaseSensitive)
		return This.NthSubStringBetweenCSZZ(1, pcSubStr, pcBound1, pcBound2, pCaseSensitive)

		#< @FunctionAlternativeForms

		def FirstSubStringBoundedByCSZZ(pcSubStr, pacBounds, pCaseSensitive)
			return This.NthSubStringBoundedByCSZZ(1, pcSubStr, pacBounds, pCaseSensitive)

		#--

		def FirstSubStringBetweenAsSectionCS(pcSubStr, pcBound1, pcBound2, pCaseSensitive)
			return This.FirstSubStringBetweenCSZZ(pcSubStr, pcBound1, pcBound2, pCaseSensitive)

		def FirstSubStringBoundedByAsSectionCS(pcSubStr, pacBounds, pCaseSensitive)
			return This.FirstSubStringBoundedByCSZZ(pcSubStr, pacBounds, pCaseSensitive)

		#>

	#-- WITHOUT CASESENSITIVITY

	def FirstSubStringBetweenZZ(pcSubStr, pcBound1, pcBound2)
		return This.FirstSubStringBetweenCSZZ(pcSubStr, pcBound1, pcBound2, TRUE)

		#< @FunctionAlternativeForms

		def FirstSubStringBoundedByZZ(pcSubStr, pacBounds)
			return This.FirstSubStringBoundedByCSZZ(pcSubStr, pacBounds, TRUE)

		#--

		def FirstSubStringBetweenAsSection(pcSubStr, pcBound1, pcBound2)
			return This.FirstSubStringBetweenZZ(pcSubStr, pcBound1, pcBound2)

		def FirstSubStringBoundedByAsSection(pcSubStr, pacBounds)
			return This.FirstSubStringBoundedByZZ(pcSubStr, pacBounds)

		#>

	  #--------------------------------------------------------------------------------------------#
	 #  FINDING FIRST OCCURRENCE OF A SUBSTRING BOUNDED BY TWO OTHER SUBSTRINGS INCLUDING BOUNDS  #
	#============================================================================================#

	def FindFirstSubStringBetweenCSIB(pcSubStr, pcBound1, pcBound2, pCaseSensitive)
		return This.FindNthSubStringBetweenCSIB(1, pcSubStr, pcBound1, pcBound2, pCaseSensitive)

		#< @FunctionAlternativeForms

		def FindFirstSubStringBoundedByCSIB(pcSubStr, pacBounds, pCaseSensitive)
			return This.FindNthSubStringBoundedByCSIB(1, pcSubStr, pacBounds, pCaseSensitive)

		#--
	
		def FindFirstSubStringBetweenCSIBZ(pcSubStr, pcBound1, pcBound2, pCaseSensitive)
			return This.FindFirstSubStringBetweenCSIB(pcSubStr, pcBound1, pcBound2, pCaseSensitive)

		def FindFirstSubStringBoundedByCSIBZ(pcSubStr, pacBounds, pCaseSensitive)
			return This.FindFirstSubStringBoundedByCSIB(pcSubStr, pacBound, pCaseSensitives)

		#==

		def FirstSubStringBetweenCSIB(pcSubStr, pcBound1, pcBound2, pCaseSensitive)
			return This.FindFirstSubStringBetweenCSIB(pcSubStr, pcBound1, pcBound2, pCaseSensitive)

		def FirstSubStringBoundedByCSIB(pcSubStr, pacBounds, pCaseSensitive)
			return This.FindFirstSubStringBoundedByCSIB(pcSubStr, pacBounds, pCaseSensitive)
	
		def FirstSubStringBetweenCSIBZ(pcSubStr, pcBound1, pcBound2, pCaseSensitive)
			return This.FindFirstSubStringBetweenCSIB(pcSubStr, pcBound1, pcBound2, pCaseSensitive)

		def FirstSubStringBoundedByCSIBZ(pcSubStr, pacBounds, pCaseSensitive)
			return This.FindFirstSubStringBoundedByCSIB(pcSubStr, pacBounds, pCaseSensitive)

		#>

	#-- WITHOUT CASESENSITIVE

	def FindFirstSubStringBetweenIB(pcSubStr, pcBound1, pcBound2)
		return This.FindFirstSubStringBetweenCSIB(pcSubStr, pcBound1, pcBound2, TRUE)

		#< @FunctionAlternativeForms

		def FindFirstSubStringBoundedByIB(pcSubStr, pacBounds)
			if isString(pacBounds)
				return This.FindFirstSubStringBetweenIB(pcSubStr, pacBounds, pacBounds)

			but isList(pacBounds) and Q(pacBounds).IsPairOfStrings()
				return TThis.FindFirstSubStringBetweenIB(pcSubStr, pacBounds[1], pacBounds[2])

			else
				StzRaise("Incorrect param type! pacBounds must be a string or pair of strings.")
			ok

		#--
	
		def FindFirstSubStringBetweenZIB(pcSubStr, pcBound1, pcBound2)
			return This.FindFirstSubStringBetweenIB(pcSubStr, pcBound1, pcBound2)

		def FindFirstSubStringBoundedByZIB(pcSubStr, pacBounds)
			return This.FindFirstSubStringBoundedByIB(pcSubStr, pacBounds)

		#==

		def FirstSubStringBetweenIB(pcSubStr, pcBound1, pcBound2)
			return This.FindFirstSubStringBetweenIB(pcSubStr, pcBound1, pcBound2)

		def FirstSubStringBoundedByIB(pcSubStr, pacBounds)
			return This.FindFirstSubStringBoundedByIB(pcSubStr, pacBounds)
	
		def FirstSubStringBetweenZIB(pcSubStr, pcBound1, pcBound2)
			return This.FindFirstSubStringBetweenIB(pcSubStr, pcBound1, pcBound2)

		def FirstSubStringBoundedByZIB(pcSubStr, pacBounds)
			return This.FindFirstSubStringBoundedByIB(pcSubStr, pacBounds)

		#>

	   #-------------------------------------------------------------------------#
	  #  FINDING FIRST OCCURRENCE OF A SUBSTRING BOUNDED BY TWO OTHER           #
	 #  SUBSTRINGS INCLUDING BOUNDS AND RETURNING THEIR POSITIONS AS SECTIONS  #
	#-------------------------------------------------------------------------#

	def FindFirstSubStringBetweenCSIBZZ(pcSubStr, pcBound1, pcBound2, pCaseSensitive)
		return This.FindNthSubStringBetweenCSIBZZ(1, pcSubStr, pcBound1, pcBound2, pCaseSensitive)

		#< @FunctionAlternativeForms

		def FindFirstSubStringBoundedByCSIBZZ(pcSubStr, pacBounds, pCaseSensitive)
			return This.FindNthSubStringBoundedByCSIBZZ(1, pcSubStr, pacBounds, pCaseSensitive)

		#--
	
		def FindFirstSubStringBetweenAsSectionsCSIB(pcSubStr, pcBound1, pcBound2, pCaseSensitive)
			return This.FindFirstSubStringBetweenCSIBZZ(pcSubStr, pcBound1, pcBound2, pCaseSensitive)

		def FindFirstSubStringBoundedByAsSectionsCSIB(pcSubStr, pacBounds, pCaseSensitive)
			return This.FindFirstSubStringBoundedByCSIBZZ(pcSubStr, pacBounds, pCaseSensitive)

		#==

		def FirstSubStringBetweenAsSectionsCSIB(pcSubStr, pcBound1, pcBound2, pCaseSensitive)
			return This.FindFirstSubStringBetweenCSIBZZ(pcSubStr, pcBound1, pcBound2, pCaseSensitive)

		def FirstSubStringBoundedByAsSectionsCSIB(pcSubStr, pacBounds, pCaseSensitive)
			return This.FindFirstSubStringBoundedByCSIBZZ(pcSubStr, pacBounds, pCaseSensitive)

		#>

	#-- WITHOUT CASESENSITIVITY

	def FindFirstSubStringBetweenZZIB(pcSubStr, pcBound1, pcBound2)
		return This.FindFirstSubStringBetweenCSIBZZ(pcSubStr, pcBound1, pcBound2, TRUE)

		#< @FunctionAlternativeForms

		def FindFirstSubStringBetweenIBZZ(pcSubStr, pcBound1, pcBound2)
			return This.FindFirstSubStringBetweenIBZZ(pcSubStr, pcBound1, pcBound2)

		def FindFirstSubStringBoundedByIBZZ(pcSubStr, pacBounds)
			return This.FindFirstSubStringBoundedByIBZZ(pcSubStr, pacBounds)

		#--
	
		def FindFirstSubStringBetweenAsSectionsIB(pcSubStr, pcBound1, pcBound2)
			return This.FindFirstSubStringBetweenIBZZ(pcSubStr, pcBound1, pcBound2)

		def FindFirstSubStringBoundedByAsSectionsIB(pcSubStr, pacBounds)
			return This.FindFirstSubStringBoundedByIBZZ(pcSubStr, pacBounds)

		#==

		def FirstSubStringBetweenAsSectionsIB(pcSubStr, pcBound1, pcBound2)
			return This.FindFirstSubStringBetweenIBZZ(pcSubStr, pcBound1, pcBound2)

		def FirstSubStringBoundedByAsSectionsIB(pcSubStr, pacBounds)
			return This.FindFirstSubStringBoundedByIBZZ(pcSubStr, pacBounds)

		#>

	  #-------------------------------------------------------------------------------------------------------------#
	 #  GETTING THE SUBSTRING AND ITS FIRST OCCURRENCE (AS SECTION) BETWEEN TWO GIVEN SUBSTRINGS INCLUDING BOUNDS  #
	#-------------------------------------------------------------------------------------------------------------#

	def FirstSubStringBetweenCSIBZZ(pcSubStr, pcBound1, pcBound2, pCaseSensitive)
		return This.NthSubStringBetweenCSIBZZ(1, pcSubStr, pcBound1, pcBound2, pCaseSensitive)

		#< @FunctionAlternativeForms

		def FirstSubStringBoundedByCSIBZZ(pcSubStr, pacBounds, pCaseSensitive)
			return This.NthFirstSubStringBoundedByCSIBZZ(1, pcSubStr, pacBounds, pCaseSensitive)

		#--

		def FirstSubStringBetweenAsSectionCSIB(pcSubStr, pcBound1, pcBound2, pCaseSensitive)
			return This.FirstSubStringBetweenCSIBZZ(pcSubStr, pcBound1, pcBound2, pCaseSensitive)

		def FirstSubStringBoundedByAsSectionCSIB(pcSubStr, pacBounds, pCaseSensitive)
			return This.FirstSubStringBoundedByCSIBZZ(pcSubStr, pacBounds, pCaseSensitive)

		#>

	#-- WITHOUT CASESENSITIVITY

	def FirstSubStringBetweenIBZZ(pcSubStr, pcBound1, pcBound2)
		return This.FirstSubStringBetweenCSIBZZ(pcSubStr, pcBound1, pcBound2, TRUE)

		#< @FunctionAlternativeForms

		def FirstSubStringBoundedByIBZZ(pcSubStr, pacBounds)
			return This.NthFirstSubStringBoundedByIBZZ(1, pcSubStr, pacBounds)

		#--

		def FirstSubStringBetweenAsSectionIB(pcSubStr, pcBound1, pcBound2)
			return This.FirstSubStringBetweenIBZZ(pcSubStr, pcBound1, pcBound2)

		def FirstSubStringBoundedByAsSectionIB(pcSubStr, pacBounds)
			return This.FirstSubStringBoundedByIBZZ(pcSubStr, pacBounds)

		#>

	   #------------------------------------------------------#
	  #  FINDING FIRST OCCURRENCE OF A SUBSTRING BOUNDED BY  #
	 #  TWO OTHER SUBSTRINGS STARTING AT A GIVEN POSITION   #
	#======================================================#

	def FindFirstSubStringBetweenSCS(pcSubStr, pcBound1, pcBound2, pnStartingAt, pCaseSensitive)
		return This.FindNthSubStringBetweenSCS(1, pcSubStr, pcBound1, pcBound2, pnStartingAt, pCaseSensitive)

		#< @FunctionalternativeForms

		def FindFirstSubStringBoundedBySCS(pcSubStr, pacBounds, pnStartingAt, pCaseSensitive)
			return This.FindNthSubStringBoundedBySCS(1, pcSubStr, pacBounds, pnStartingAt, pCaseSensitive)

		#--
	
		def FindFirstSubStringBetweenSCSZ(pcSubStr, pcBound1, pcBound2, pnStartingAt, pCaseSensitive)
			return This.FindFirstSubStringBetweenSCS(pcSubStr, pcBound1, pcBound2, pnStartingAt, pCaseSensitive)

		def FindFirstSubStringBoundedBySCSZ(pcSubStr, pacBounds, pnStartingAt, pCaseSensitive)
			return This.FindFirstSubStringBoundedBySCS(pcSubStr, pacBounds, pnStartingAt, pCaseSensitive)

		#==

		def FirstSubStringBetweenSCS(pcSubStr, pcBound1, pcBound2, pnStartingAt, pCaseSensitive)
			return This.FindFirstSubStringBetweenSCS(pcSubStr, pcBound1, pcBound2, pnStartingAt, pCaseSensitive)

		def FirstSubStringBoundedBySCS(pcSubStr, pacBounds, pnStartingAt, pCaseSensitive)
			return This.FindFirstSubStringBoundedBySCS(pcSubStr, pacBounds, pnStartingAt, pCaseSensitive)

		#>

	#-- WITHOUT CASESENSITIVITY

	def FindFirstSubStringBetweenS(pcSubStr, pcBound1, pcBound2, pnStartingAt)
		return This.FindFirstSubStringBetweenSCS(pcSubStr, pcBound1, pcBound2, pnStartingAt, TRUE)

		#< @FunctionAlternativeForms

		def FindFirstSubStringBoundedByS(pcSubStr, pacBounds, pnStartingAt)
			return This.FindFirstSubStringBoundedByS(pcSubStr, pacBounds, pnStartingAt)

		#--
	
		def FindFirstSubStringBetweenSZ(pcSubStr, pcBound1, pcBound2, pnStartingAt)
			return This.FindFirstSubStringBetweenS(pcSubStr, pcBound1, pcBound2, pnStartingAt)

		def FindFirstSubStringBoundedBySZ(pcSubStr, pacBounds, pnStartingAt)
			return This.FindFirstSubStringBoundedByS(pcSubStr, pacBounds, pnStartingAt)

		#==

		def FirstSubStringBetweenS(pcSubStr, pcBound1, pcBound2, pnStartingAt)
			return This.FindBetweenS(pcSubStr, pcBound1, pcBound2, pnStartingAt)

		def FirstSubStringBoundedByS(pcSubStr, pacBounds, pnStartingAt)
			return This.FindFirstSubStringBoundedByS(pcSubStr, pacBounds, pnStartingAt)

		#>

	  #-------------------------------------------------------------------------------#
	 #  GETTING THE SUBSTRING AND ITS FIRST OCCURRENCE STARTING AT A GIVEN POSITION  #
	#-------------------------------------------------------------------------------#

	def FirstSubStringBetweenSCSZ(pcSubStr, pcBound1, pcBound2, pnStartingAt, pCaseSensitive)
		return This.NthSubStringBetweenSCSZ(1, pcSubStr, pcBound1, pcBound2, pnStartingAt, pCaseSensitive)

		def FirstSubStringBoundedBySCSZ(pcSubStr, pacBounds, pnStartingAt, pCaseSensitive)
			return This.NthSubStringBoundedBySCSZ(1, pcSubStr, pacBounds, pnStartingAt, pCaseSensitive)

	#-- WITHOUT CASESENSITIVITY

	def FirstSubStringBetweenSZ(pcSubStr, pcBound1, pcBound2, pnStartingAt)
		return This.FirstSubStringBetweenSCSZ(pcSubStr, pcBound1, pcBound2, pnStartingAt, TRUE)

		def FirstSubStringBoundedBySZ(pcSubStr, pacBounds, pnStartingAt)
			return This.NthSubStringBoundedBySZ(1, pcSubStr, pacBounds, pnStartingAt)

	   #---------------------------------------------------------------------------#
	  #  FINDING FIRST OCCURRENCE OF A SUBSTRING BOUNDED BY TWO OTHER SUBSTRINGS  #
	 #  STARTING AT A GIVEN POSITION AND RETURNING POSITIONS AS SECTIONS         #
	#===========================================================================#

	def FindFirstSubStringBetweenSCSZZ(pcSubStr, pcBound1, pcBound2, pnStartingAt, pCaseSensitive)
		return This.FindNthSubStringBetweenSCSZZ(1, pcSubStr, pcBound1, pcBound2, pnStartingAt, pCaseSensitive)

		#< @FunctionAlternativeForms

		def FindFirstSubStringBoundedBySCSZZ(pcSubStr, pacBounds, pnStartingAt, pCaseSensitive)
			return This.FindNthSubStringBoundedBySCSZZ(1, pcSubStr, pacBounds, pnStartingAt, pCaseSensitive)

		#--
	
		def FindFirstSubStringBetweenAsSectionsSCS(pcSubStr, pcBound1, pcBound2, pnStartingAt, pCaseSensitive)
			return This.FindFirstSubStringBetweenSCSZZ(pcSubStr, pcBound1, pcBound2, pnStartingAt, pCaseSensitive)

		def FindFirstSubStringBoundedByAsSectionsSCS(pcSubStr, pacBounds, pnStartingAt, pCaseSensitive)
			return This.FindFirstSubStringBoundedBySCSZZ(pcSubStr, pacBounds, pnStartingAt, pCaseSensitive)

		#==

		def FirstSubStringBetweenAsSectionsSCS(pcSubStr, pcBound1, pcBound2, pnStartingAt, pCaseSensitive)
			return This.FindFirstSubStringBetweenSCSZZ(pcSubStr, pcBound1, pcBound2, pnStartingAt, pCaseSensitive)

		def FirstSubStringBoundedByAsSectionsSCS(pcSubStr, pacBounds, pnStartingAt, pCaseSensitive)
			return This.FindFirstSubStringBoundedBySCSZZ(pcSubStr, pacBounds, pnStartingAt, pCaseSensitive)

		#>

	#--

	def FindFirstSubStringBetweenSZZ(pcSubStr, pcBound1, pcBound2, pnStartingAt)
		return This.FindFirstSubStringBetweenSCSZZ(pcSubStr, pcBound1, pcBound2, pnStartingAt, TRUE)

		#< @FunctionAlternativeForms

		def FindFirstSubStringBoundedBySZZ(pcSubStr, pacBounds, pnStartingAt)
			return This.FindFirstSubStringBoundedBySZZ(pcSubStr, pacBounds, pnStartingAt)

		#--
	
		def FindFirstSubStringBetweenAsSectionsS(pcSubStr, pcBound1, pcBound2, pnStartingAt)
			return This.FindFirstSubStringBetweenSZZ(pcSubStr, pcBound1, pcBound2, pnStartingAt)

		def FindFirstSubStringBoundedByAsSectionsS(pcSubStr, pacBounds, pnStartingAt)
			return This.FindFirstSubStringBoundedBySZZ(pcSubStr, pacBounds, pnStartingAt)

		#==

		def FirstSubStringBetweenAsSectionsS(pcSubStr, pcBound1, pcBound2, pnStartingAt)
			return This.FindFirstSubStringBetweenSZZ(pcSubStr, pcBound1, pcBound2, pnStartingAt)

		def FirstSubStringBoundedByAsSectionsS(pcSubStr, pacBounds, pnStartingAt)
			return This.FindFirstSubStringBoundedBySZZ(pcSubStr, pacBounds, pnStartingAt)

		#>

	   #-----------------------------------------------------------------------#
	  #  GETTING THE SUBSTRING AND ITS FIRST OCCURRENCE (AS SECTION) BETWEEN  #
	 #  TWO GIVEN SUBSTRINGS STARTING AT A GIVEN POSITION                    #
	#-----------------------------------------------------------------------#

	def FirstSubStringBetweenSCSZZ(pcSubStr, pcBound1, pcBound2, pnStartingAt, pCaseSensitive)
		return This.NthSubStringBetweenSCSZZ(1, pcSubStr, pcBound1, pcBound2, pnStartingAt, pCaseSensitive)

		#< @FunctionAlternativeForms

		def FirstSubStringBoundedBySCSZZ(pcSubStr, pacBounds, pnStartingAt, pCaseSensitive)
			return This.NthSubStringBoundedBySCSZZ(1, pcSubStr, pacBounds, pnStartingAt, pCaseSensitive)

		#--

		def FirstSubStringBetweenAsSection_SCS(pcSubStr, pcBound1, pcBound2, pnStartingAt, pCaseSensitive)
			return This.FirstSubStringBetweenSCSZZ(pcSubStr, pcBound1, pcBound2, pnStartingAt, pCaseSensitive)

		def FirstSubStringBoundedByAsSection_SCS(pcSubStr, pacBounds, pnStartingAt, pCaseSensitive)
			return This.FirstSubStringBoundedBySCSZZ(pcSubStr, pacBounds, pnStartingAt, pCaseSensitive)

		#>

	#-- WITHOUT CASESENSITIVITY

	def FirstSubStringBetweenSZZ(pcSubStr, pcBound1, pcBound2, pnStartingAt)
		return This.FirstSubStringBetweenSCSZZ(pcSubStr, pcBound1, pcBound2, pnStartingAt, TRUE)

		#< @FunctionAlternativeForms

		def FirstSubStringBoundedBySZZ(pcSubStr, pacBounds, pnStartingAt)
			return This.NthSubStringBoundedBySZZ(1, pcSubStr, pacBounds, pnStartingAt)

		#--

		def FirstSubStringBetweenAsSection_S(pcSubStr, pcBound1, pcBound2, pnStartingAt)
			return This.FirstSubStringBetweenSZZ(pcSubStr, pcBound1, pcBound2, pnStartingAt)

		def FirstSubStringBoundedByAsSection_S(pcSubStr, pacBounds, pnStartingAt)
			return This.FirstSubStringBoundedBySZZ(pcSubStr, pacBounds, pnStartingAt)

		#>
	
	   #----------------------------------------------------------------#
	  #  FINDING FIRST OCCURRENCE OF A SUBSTRING BOUNDED BY TWO OTHER  #
	 #  SUBSTRINGSSTARTING AT A GIVEN POSITION AND INCLUDING BOUNDS   #
	#================================================================#

	def FindFirstSubStringBetweenSCSIB(pcSubStr, pcBound1, pcBound2, pnStartingAt, pCaseSensitive)
		return This.FindNthSubStringBetweenSCSIB(1, pcSubStr, pcBound1, pcBound2, pnStartingAt, pCaseSensitive)

		#< @FunctionAlternativeForms

		def FindFirstSubStringBoundedBySCSIB(pcSubStr, pacBounds, pnStartingAt, pCaseSensitive)
			return This.NthFirstSubStringBoundedBySCSIB(1, pcSubStr, pacBounds, pnStartingAt, pCaseSensitive)

		#--
	
		def FindFirstSubStringBetweenSCSIBZ(pcSubStr, pcBound1, pcBound2, pnStartingAt, pCaseSensitive)
			return This.FindFirstSubStringBetweenSCSIB(pcSubStr, pcBound1, pcBound2, pnStartingAt, pCaseSensitive)

		def FindFirstSubStringBoundedBySCSIBZ(pcSubStr, pacBounds, pnStartingAt, pCaseSensitive)
			return This.FindFirstSubStringBoundedBySCSIB(pcSubStr, pacBounds, pnStartingAt, pCaseSensitive)

		#==

		def FirstSubStringBetweenSCSIB(pcSubStr, pcBound1, pcBound2, pnStartingAt, pCaseSensitive)
			return This.FindFirstSubStringBetweenSCSIB(pcSubStr, pcBound1, pcBound2, pnStartingAt, pCaseSensitive)

		def FirstSubStringBoundedBySCSIB(pcSubStr, pacBounds, pnStartingAt, pCaseSensitive)
			return This.FindFirstSubStringBoundedBySCSIB(pcSubStr, pacBounds, pnStartingAt, pCaseSensitive)

		#>

	#-- WITHOUT CASESENSITIVITY

	def FindFirstSubStringBetweenSIB(pcSubStr, pcBound1, pcBound2, pnStartingAt)
		return This.FindFirstSubStringBetweenSCSIB(pcSubStr, pcBound1, pcBound2, pnStartingAt, TRUE)

		#< @FunctionAlternativeForms

		def FindFirstSubStringBoundedBySIB(pcSubStr, pacBounds, pnStartingAt)
			return This.FindFirstSubStringBoundedBySIB(pcSubStr, pacBounds, pnStartingAt)

		#--
	
		def FindFirstSubStringBetweenSIBZ(pcSubStr, pcBound1, pcBound2, pnStartingAt)
			return This.FindFirstSubStringBetweenSIB(pcSubStr, pcBound1, pcBound2, pnStartingAt)

		def FindFirstSubStringBoundedBySIBZ(pcSubStr, pacBounds, pnStartingAt)
			return This.FindFirstSubStringBoundedBySIB(pcSubStr, pacBounds, pnStartingAt)

		#==

		def FirstSubStringBetweenSIB(pcSubStr, pcBound1, pcBound2, pnStartingAt)
			return This.FindFirstSubStringBetweenSIB(pcSubStr, pcBound1, pcBound2, pnStartingAt)

		def FirstSubStringBoundedBySIB(pcSubStr, pacBounds, pnStartingAt)
			return This.FindBoundedBySIB(pcSubStr, pacBounds, pnStartingAt)

		#>

	   #-------------------------------------------------------------------------------#
	  #  GETTING THE SUBSTRING AND ITS FIRST OCCURRENCE BETWEEN TWO GIVEN SUBSTRINGS  #
	 #  STARTING AT A GIVEN POSITION AND INCLUDING BOUNDS                            #
	#-------------------------------------------------------------------------------#

	def FirstSubStringBetweenSCSIBZ(pcSubStr, pcBound1, pcBound2, pnStartingAt, pCaseSensitive)
		return This.NthSubStringBetweenSCSIBZ(1, pcSubStr, pcBound1, pcBound2, pnStartingAt, pCaseSensitive)

		def FirstSubStringBoundedBySCSIBZ(pcSubStr, pacBounds, pnStartingAt, pCaseSensitive)
			return This.NthSubStringBoundedBySCSIBZ(1, pcSubStr, pacBounds, pnStartingAt, pCaseSensitive)

	#-- WITHOUT CASESENSITIVITY

	def FirstSubStringBetweenSIBZ(pcSubStr, pcBound1, pcBound2, pnStartingAt)
		return This.FirstSubStringBetweenSCSIBZ(pcSubStr, pcBound1, pcBound2, pnStartingAt, TRUE)

		def FirstSubStringBoundedBySIBZ(pcSubStr, pacBounds, pnStartingAt)
			return This.FirstSubStringBoundedBySCSIBZ(pcSubStr, pacBounds, pnStartingAt, TRUE)

	   #-------------------------------------------------------------------------------------#
	  #  FINDING FIRST OCCURRENCE OF A SUBSTRING BOUNDED BY TWO OTHER SUBSTRINGS STARTING   #
	 #  AT A GIVEN POSITION, INCLUDING BOUNDS, AND RETURNING THE POSITIONS AS SECTIONS     #
	#=====================================================================================#

	def FindFirstSubStringBetweenSCSIBZZ(pcSubStr, pcBound1, pcBound2, pnStartingAt, pCaseSensitive)
		return This.FindNthSubStringBetweenSCSIBZZ(1, pcSubStr, pcBound1, pcBound2, pnStartingAt, pCaseSensitive)

		#< @FunctionAlternativeForms

		def FindFirstSubStringBoundedBySCSIBZZ(pcSubStr, pacBounds, pnStartingAt, pCaseSensitive)
			return This.FindNthSubStringBoundedBySCSIBZZ(1, pcSubStr, pacBounds, pnStartingAt, pCaseSensitive)

		#--
	
		def FindFirstSubStringBetweenAsSectionsSCSIB(pcSubStr, pcBound1, pcBound2, pnStartingAt, pCaseSensitive)
			return This.FindFirstSubStringBetweenSCSIBZZ(pcSubStr, pcBound1, pcBound2, pnStartingAt, pCaseSensitive)

		def FindFirstSubStringBoundedByAsSectionsSCSIB(pcSubStr, pacBounds, pnStartingAt, pCaseSensitive)
			return This.FindFirstSubStringBoundedBySCSIBZZ(pcSubStr, pacBounds, pnStartingAt, pCaseSensitive)

		#==

		def FirstSubStringBetweenAsSectionsSCSIB(pcSubStr, pcBound1, pcBound2, pnStartingAt, pCaseSensitive)
			return This.FindFirstSubStringBetweenSIBCSZZ(pcSubStr, pcBound1, pcBound2, pnStartingAt, pCaseSensitive)

		def FirstSubStringBoundedByAsSectionsSCSIB(pcSubStr, pacBounds, pnStartingAt, pCaseSensitive)
			return This.FindFirstSubStringBoundedBySCSIBZZ(pcSubStr, pacBounds, pnStartingAt, pCaseSensitive)

		#>

	#-- WITHOUT CASESENSITIVITY

	def FindFirstSubStringBetweenSIBZZ(pcSubStr, pcBound1, pcBound2, pnStartingAt)
		return This.FindFirstSubStringBetweenSIBCSZZ(pcSubStr, pcBound1, pcBound2, pnStartingAt, TRUE)

		#< @FunctionAlternativeForms

		def FindFirstSubStringBoundedBySIBZZ(pcSubStr, pacBounds, pnStartingAt)
			return This.FindFirstSubStringBoundedBySIBZZ(pcSubStr, pacBounds, pnStartingAt)

		#--
	
		def FindFirstSubStringBetweenAsSectionsSIB(pcSubStr, pcBound1, pcBound2, pnStartingAt)
			return This.FindFirstSubStringBetweenSIBZZ(pcSubStr, pcBound1, pcBound2, pnStartingAt)

		def FindFirstSubStringBoundedByAsSectionsSIB(pcSubStr, pacBounds, pnStartingAt)
			return This.FindFirstSubStringBoundedBySIBZZ(pcSubStr, pacBounds, pnStartingAt)

		#==

		def FirstSubStringBetweenAsSectionsSIB(pcSubStr, pcBound1, pcBound2, pnStartingAt)
			return This.FindFirstSubStringBetweenSIBZZ(pcSubStr, pcBound1, pcBound2, pnStartingAt)

		def FirstSubStringBoundedByAsSectionsSIB(pcSubStr, pacBounds, pnStartingAt)
			return This.FindFirstSubStringBoundedBySIBZZ(pcSubStr, pacBounds, pnStartingAt)

		#>

	   #-----------------------------------------------------------------------#
	  #  GETTING THE SUBSTRING AND ITS FIRST OCCURRENCE (AS SECTION) BETWEEN  #
	 #  TWO GIVEN SUBSTRINGS STARTING AT A GIVEN POSITION                    #
	#-----------------------------------------------------------------------#

	def FirstSubStringBetweenSCSIBZZ(pcSubStr, pcBound1, pcBound2, pnStartingAt, pCaseSensitive)
		return This.NthSubStringBetweenSCSIBZZ(1, pcSubStr, pcBound1, pcBound2, pnStartingAt, pCaseSensitive)

		#< @FunctionAlternativeForms

		def FirstSubStringBoundedBySCSIBZZ(pcSubStr, pacBounds, pnStartingAt, pCaseSensitive)
			return This.NthSubStringBoundedBySCSIBZZ(1, pcSubStr, pacBounds, pnStartingAt, pCaseSensitive)

		#--

		def FirstSubStringBetweenAsSection_SCSIB(pcSubStr, pcBound1, pcBound2, pnStartingAt, pCaseSensitive)
			return This.FirstSubStringBetweenSCSIBZZ(pcSubStr, pcBound1, pcBound2, pnStartingAt, pCaseSensitive)

		def FirstSubStringBoundedBy_SCSIB(pcSubStr, pacBounds, pnStartingAt, pCaseSensitive)
			return This.FirstSubStringBoundedBySCSIBZZ(pcSubStr, pacBounds, pnStartingAt, pCaseSensitive)

		#>

	#-- WITHOUT CASESENSITIVITY

	def FirstSubStringBetweenSIBZZ(pcSubStr, pcBound1, pcBound2, pnStartingAt)
		return This.FirstSubStringBetweenSCSIBZZ(pcSubStr, pcBound1, pcBound2, pnStartingAt, TRUE)

		#< @FunctionAlternativeForms

		def FirstSubStringBoundedBySIBZZ(pcSubStr, pacBounds, pnStartingAt)
			return This.FirstSubStringBoundedBySCSIBZZ(pcSubStr, pacBounds, pnStartingAt, TRUE)

		#--

		def FirstSubStringBetweenAsSection_SIB(pcSubStr, pcBound1, pcBound2, pnStartingAt, pCaseSensitive)
			return This.FirstSubStringBetweenSIBZZ(pcSubStr, pcBound1, pcBound2, pnStartingAt, pCaseSensitive)

		def FirstSubStringBoundedBy_SIB(pcSubStr, pacBounds, pnStartingAt, pCaseSensitive)
			return This.FirstSubStringBoundedBySIBZZ(pcSubStr, pacBounds, pnStartingAt, pCaseSensitive)

		#>

	   #------------------------------------------------------#
	  #  FINDING FIRST OCCURRENCE OF A SUBSTRING BOUNDED BY  #
	 #  TWO OTHER SUBSTRINGS GOING IN A GIVEN DIRECTION     #
	#======================================================#

	def FindFirstSubStringBetweenDCS(pcSubStr, pcBound1, pcBound2, pcDirection, pCaseSensitive)
		return This.FindNthSubStringBetweenDCS(1, pcSubStr, pcBound1, pcBound2, pcDirection, pCaseSensitive)

		#< @FunctionAlternativeForms

		def FindFirstSubStringBoundedByDCS(pcSubStr, pacBounds, pcDirection, pCaseSensitive)
			return This.FindNthSubStringBoundedByDCS(1, pcSubStr, pacBounds, pcDirection, pCaseSensitive)

		#--
	
		def FindFirstSubStringBetweenDCSZ(pcSubStr, pcBound1, pcBound2, pcDirection, pCaseSensitive)
			return This.FindFirstSubStringBetweenDCS(pcSubStr, pcBound1, pcBound2, pcDirection, pCaseSensitive)

		def FindFirstSubStringBoundedByDCSZ(pcSubStr, pacBounds, pcDirection, pCaseSensitive)
			return This.FindFirstSubStringBoundedByDCS(pcSubStr, pacBounds, pcDirection, pCaseSensitive)

		#==

		def FirstSubStringBetweenDCS(pcSubStr, pcBound1, pcBound2, pcDirection, pCaseSensitive)
			return This.FindFirstSubStringBetweenDCS(pcSubStr, pcBound1, pcBound2, pcDirection, pCaseSensitive)

		def FirstSubStringBoundedByDCS(pcSubStr, pacBounds, pcDirection, pCaseSensitive)
			return This.FindFirstSubStringBoundedByDCS(pcSubStr, pacBounds, pcDirection, pCaseSensitive)

		#>

	#-- WITHOUT CASESENSITIVITY

	def FindFirstSubStringBetweenD(pcSubStr, pcBound1, pcBound2, pcDirection)
		return This.FindFirstSubStringBetweenDCS(pcSubStr, pcBound1, pcBound2, pcDirection, TRUE)

		#< @FunctionAlternativeForms

		def FindFirstSubStringBoundedByD(pcSubStr, pacBounds, pcDirection)
			return This.FindFirstSubStringBoundedByD(pcSubStr, pacBounds, pcDirection)

		#--
	
		def FindFirstSubStringBetweenDZ(pcSubStr, pcBound1, pcBound2, pcDirection)
			return This.FindFirstSubStringBetweenD(pcSubStr, pcBound1, pcBound2, pcDirection)

		def FindFirstSubStringBoundedByDZ(pcSubStr, pacBounds, pcDirection)
			return This.FindFirstSubStringBoundedByD(pcSubStr, pacBounds, pcDirection)

		#==

		def FirstSubStringBetweenD(pcSubStr, pcBound1, pcBound2, pcDirection)
			return This.FindFirstSubStringBetweenD(pcSubStr, pcBound1, pcBound2, pcDirection)

		def FirstSubStringBoundedByD(pcSubStr, pacBounds, pcDirection)
			return This.FindFirstSubStringBoundedByD(pcSubStr, pacBounds, pcDirection)

		#>

	   #-------------------------------------------------------------------------------#
	  #  GETTING THE SUBSTRING AND ITS FIRST OCCURRENCE BETWEEN TWO GIVEN SUBSTRINGS  #
	 #  GOING IN A GIVEN DIRECTION (FORWARD OR BACKWARD)                             #
	#-------------------------------------------------------------------------------#

	def FirstSubStringBetweenDCSZ(pcSubStr, pcBound1, pcBound2, pcDirection, pCaseSensitive)
		return This.NthSubStringBetweenDCSZ(1, pcSubStr, pcBound1, pcBound2, pcDirection, pCaseSensitive)

		def FirstSubStringBoundedByDCSZ(pcSubStr, pacBounds, pcDirection, pCaseSensitive)
			return This.NthSubStringBoundedByDCSZ(1, pcSubStr, pacBounds, pcDirection, pCaseSensitive)

	#-- WITHOUT CASESENSITIVITY

	def FirstSubStringBetweenDZ(pcSubStr, pcBound1, pcBound2, pcDirection)
		return This.FirstSubStringBetweenDCSZ(pcSubStr, pcBound1, pcBound2, pcDirection, TRUE)

		def FirstSubStringBoundedByDZ(pcSubStr, pacBounds, pcDirection)
			return This.FirstSubStringBoundedByDCSZ(pcSubStr, pacBounds, pcDirection, TRUE)

	   #---------------------------------------------------------------------------#
	  #  FINDING FIRST OCCURRENCE OF A SUBSTRING BOUNDED BY TWO OTHER SUBSTRINGS  #
	 #  GOING INA GIVEN DIRECTION AND RETURNING POSITIONS AS SECTIONS            #
	#===========================================================================#

	def FindFirstSubStringBetweenDCSZZ(pcSubStr, pcBound1, pcBound2, pcDirection, pCaseSensitive)
		return This.FindNthSubStringBetweenDCSZZ(1, pcSubStr, pcBound1, pcBound2, pcDirection, pCaseSensitive)

		#< @FunctionAlternativeForms

		def FindFirstSubStringBoundedByDCSZZ(pcSubStr, pacBounds, pcDirection, pCaseSensitive)
			return This.FindNthSubStringBoundedByDCSZZ(1, pcSubStr, pacBounds, pcDirection, pCaseSensitive)

		#--
	
		def FindFirstSubStringBetweenAsSectionsDCS(pcSubStr, pcBound1, pcBound2, pcDirection, pCaseSensitive)
			return This.FindFirstSubStringBetweenDCSZZ(pcSubStr, pcBound1, pcBound2, pcDirection, pCaseSensitive)

		def FindFirstSubStringBoundedByAsSectionsDCS(pcSubStr, pacBounds, pcDirection, pCaseSensitive)
			return This.FindFirstSubStringBoundedByDCSZZ(pcSubStr, pacBounds, pcDirection, pCaseSensitive)

		#==

		def FirstSubStringBetweenAsSectionsDCS(pcSubStr, pcBound1, pcBound2, pcDirection, pCaseSensitive)
			return This.FindFirstSubStringBetweenDCSZZ(pcSubStr, pcBound1, pcBound2, pcDirection, pCaseSensitive)

		def FirstSubStringBoundedByAsSectionsDCS(pcSubStr, pacBounds, pcDirection, pCaseSensitive)
			return This.FindFirstSubStringBoundedByDCSZZ(pcSubStr, pacBounds, pcDirection, pCaseSensitive)

		#>

	#-- WITHOUT CASESENSITIVITY

	def FindFirstSubStringBetweenDZZ(pcSubStr, pcBound1, pcBound2, pcDirection)
		return This.FindFirstSubStringBetweenDZZ(pcSubStr, pcBound1, pcBound2, pcDirection)

		#< @FunctionAlternativeForms

		def FindFirstSubStringBoundedByDZZ(pcSubStr, pacBounds, pcDirection)
			return This.FindFirstSubStringBoundedByDZZ(pcSubStr, pacBounds, pcDirection)

		#--
	
		def FindFirstSubStringBetweenAsSectionsD(pcSubStr, pcBound1, pcBound2, pcDirection)
			return This.FindFirstSubStringBetweenDZZ(pcSubStr, pcBound1, pcBound2, pcDirection)

		def FindFirstSubStringBoundedByAsSectionsD(pcSubStr, pacBounds, pcDirection)
			return This.FindFirstSubStringBoundedByDZZ(pcSubStr, pacBounds, pcDirection)

		#==

		def FirstSubStringBetweenAsSectionsD(pcSubStr, pcBound1, pcBound2, pcDirection)
			return This.FindFirstSubStringBetweenDZZ(pcSubStr, pcBound1, pcBound2, pcDirection)

		def FirstSubStringBoundedByAsSectionsD(pcSubStr, pacBounds, pcDirection)
			return This.FindFirstSubStringBoundedByDZZ(pcSubStr, pacBounds, pcDirection)

		#>

	   #---------------------------------------------------------------------------#
	  #  GETTING THE SUBSTRING AND ITS FIRST OCCURRENCE (AS SECTION) BETWEEN TWO  #
	 #  GIVEN SUBSTRINGS GOING IN A GIVEN DIRECTION (FORWARD OR BACKWARD)        #
	#---------------------------------------------------------------------------#

	def FirstSubStringBetweenDCSZZ(pcSubStr, pcBound1, pcBound2, pcDirection, pCaseSensitive)
		return This.NthSubStringBetweenDCSZZ(1, pcSubStr, pcBound1, pcBound2, pcDirection, pCaseSensitive)

		#< @FunctionAlternativeForms

		def FirstSubStringBoundedByDCSZZ(pcSubStr, pacBounds, pcDirection, pCaseSensitive)
			return This.NthSubStringBoundedByDCSZZ(1, pcSubStr, pacBounds, pcDirection, pCaseSensitive)

		#--

		def FirstSubStringBetweenAsSectionDCS(pcSubStr, pcBound1, pcBound2, pcDirection, pCaseSensitive)
			return This.FirstSubStringBetweenDCSZZ(pcSubStr, pcBound1, pcBound2, pcDirection, pCaseSensitive)

		def FirstSubStringBoundedByAsSectionDCS(pcSubStr, pacBounds, pcDirection, pCaseSensitive)
			return This.FirstSubStringBoundedByDCSZZ(pcSubStr, pacBounds, pcDirection, pCaseSensitive)

		#>

	#-- WITHOUT CASESENSITIVITY

	def FirstSubStringBetweenDZZ(pcSubStr, pcBound1, pcBound2, pcDirection)
		return This.FirstSubStringBetweenDCSZZ(pcSubStr, pcBound1, pcBound2, pcDirection, TRUE)

		#< @FunctionAlternativeForms

		def FirstSubStringBoundedByDZZ(pcSubStr, pacBounds, pcDirection)
			return This.NthSubStringBoundedByDZZ(1, pcSubStr, pacBounds, pcDirection)

		#--

		def FirstSubStringBetweenAsSectionD(pcSubStr, pcBound1, pcBound2, pcDirection)
			return This.FirstSubStringBetweenDZZ(pcSubStr, pcBound1, pcBound2, pcDirection)

		def FirstSubStringBoundedByAsSectionD(pcSubStr, pacBounds, pcDirection)
			return This.FirstSubStringBoundedByDZZ(pcSubStr, pacBounds, pcDirection)

		#>

	   #----------------------------------------------------------------#
	  #  FINDING FIRST OCCURRENCE OF A SUBSTRING BOUNDED BY TWO OTHER  #
	 #  SUBSTRINGS GOING IN A GIVEN DIRECTION AND INCLUDING BOUNDS    #
	#================================================================#

	def FindFirstSubStringBetweenDCSIB(pcSubStr, pcBound1, pcBound2, pcDirection, pCaseSensitive)
		return This.FindNthSubStringBetweenDCSIB(1, pcSubStr, pcBound1, pcBound2, pcDirection, pCaseSensitive)

		#< @FunctionAlternativeForms

		def FindFirstSubStringBoundedByDCSIB(pcSubStr, pacBounds, pcDirection, pCaseSensitive)
			return This.FindNthSubStringBoundedByDCSIB(1, pcSubStr, pacBounds, pcDirection, pCaseSensitive)

		#--
	
		def FindFirstSubStringBetweenDCSIBZ(pcSubStr, pcBound1, pcBound2, pcDirection, pCaseSensitive)
			return This.FindFirstSubStringBetweenDCSIB(pcSubStr, pcBound1, pcBound2, pcDirection, pCaseSensitive)

		def FindFirstSubStringBoundedByDCSIBZ(pcSubStr, pacBounds, pcDirection, pCaseSensitive)
			return This.FindFirstSubStringBoundedByDCSIB(pcSubStr, pacBounds, pcDirection, pCaseSensitive)

		#==

		def FirstSubStringBetweenDCSIB(pcSubStr, pcBound1, pcBound2, pcDirection, pCaseSensitive)
			return This.FindFirstSubStringBetweenDCSIB(pcSubStr, pcBound1, pcBound2, pcDirection, pCaseSensitive)

		def FirstSubStringBoundedByDCSIB(pcSubStr, pacBounds, pcDirection, pCaseSensitive)
			return This.FindFirstSubStringBoundedByDCSIB(pcSubStr, pacBounds, pcDirection, pCaseSensitive)

		#>

	#-- WITHOUT CASESENSITIVITY

	def FindFirstSubStringBetweenDIB(pcSubStr, pcBound1, pcBound2, pcDirection)
		return This.FindFirstSubStringBetweenDCSIB(pcSubStr, pcBound1, pcBound2, pcDirection, TRUE)

		#< @FunctionAlternativeForms

		def FindFirstSubStringBoundedByDIB(pcSubStr, pacBounds, pcDirection)
			return This.FindBoundedByDIB(pcSubStr, pacBounds, pcDirection)

		#--
	
		def FindFirstSubStringBetweenDIBZ(pcSubStr, pcBound1, pcBound2, pcDirection)
			return This.FindFirstSubStringBetweenDIB(pcSubStr, pcBound1, pcBound2, pcDirection)

		def FindFirstSubStringBoundedByDIBZ(pcSubStr, pacBounds, pcDirection)
			return This.FindFirstSubStringBoundedByDIB(pcSubStr, pacBounds, pcDirection)

		#==

		def FirstSubStringBetweenDIB(pcSubStr, pcBound1, pcBound2, pcDirection)
			return This.FindFirstSubStringBetweenDIB(pcSubStr, pcBound1, pcBound2, pcDirection)

		def FirstSubStringBoundedByDIB(pcSubStr, pacBounds, pcDirection)
			return This.FindFirstSubStringBoundedByDIB(pcSubStr, pacBounds, pcDirection)

		#>

	   #-------------------------------------------------------------------------------#
	  #  GETTING THE SUBSTRING AND ITS FIRST OCCURRENCE BETWEEN TWO GIVEN SUBSTRINGS  #
	 #  GOING IN A GIVEN DIRECTION (FORWARD OR BACKWARD) AND INCLUDING BOUNDS        #
	#-------------------------------------------------------------------------------#

	def FirstSubStringBetweenDCSIBZ(pcSubStr, pcBound1, pcBound2, pcDirection, pCaseSensitive)
		return This.NthSubStringBetweenDCSIBZ(1, pcSubStr, pcBound1, pcBound2, pcDirection, pCaseSensitive)

		def FirstSubStringBoundedByDCSIBZ(pcSubStr, pacBounds, pcDirection, pCaseSensitive)
			return This.NthSubStringBoundedByDCSIBZ(1, pcSubStr, pacBounds, pcDirection, pCaseSensitive)

	#-- WITHOUT CASESENSITIVITY

	def FirstSubStringBetweenDIBZ(pcSubStr, pcBound1, pcBound2, pcDirection)
		return This.FirstSubStringBetweenDCSIBZ(pcSubStr, pcBound1, pcBound2, pcDirection, TRUE)

		def FirstSubStringBoundedByDIBZ(pcSubStr, pacBounds, pcDirection)
			return This.FirstSubStringBoundedByDCSIBZ(pcSubStr, pacBounds, pcDirection, TRUE)

	   #---------------------------------------------------------------------------------#
	  #  FINDING FIRST OCCURRENCE OF A SUBSTRING BOUNDED BY TWO OTHER SUBSTRINGS GOING  #
	 #  IN A GIVENDIRECTION, INCLUDING BOUNDS, AND RETURNING POSITIONS AS SECTIONS     # 
	#=================================================================================#

	def FindFirstSubStringBetweenDCSIBZZ(pcSubStr, pcBound1, pcBound2, pcDirection, pCaseSensitive)
		return This.FindNthSubStringBetweenDCSIBZZ(1, pcSubStr, pcBound1, pcBound2, pcDirection, pCaseSensitive)

		#< @FunctionAlternativeForms

		def FindFirstSubStringBoundedByDCSIBZZ(pcSubStr, pacBounds, pcDirection, pCaseSensitive)
			return This.FindNthSubStringBoundedByDCSIBZZ(1, pcSubStr, pacBounds, pcDirection, pCaseSensitive)

		#--
	
		def FindFirstSubStringBetweenAsSectionsDCSIB(pcSubStr, pcBound1, pcBound2, pcDirection, pCaseSensitive)
			return This.FindFirstSubStringBetweenDCSIBZZ(pcSubStr, pcBound1, pcBound2, pcDirection, pCaseSensitive)

		def FindFirstSubStringBoundedByAsSectionsDCSIB(pcSubStr, pacBounds, pcDirection, pCaseSensitive)
			return This.FindBoundedByDCSIBZZ(pcSubStr, pacBounds, pcDirection, pCaseSensitive)

		#==

		def FirstSubStringBetweenAsSectionsDCSIB(pcSubStr, pcBound1, pcBound2, pcDirection, pCaseSensitive)
			return This.FindFirstSubStringBetweenDCIBSZZ(pcSubStr, pcBound1, pcBound2, pcDirection, pCaseSensitive)

		def FirstSubStringBoundedByAsSectionsDCSIB(pcSubStr, pacBounds, pcDirection, pCaseSensitive)
			return This.FindFirstSubStringBoundedByDCSIBZZ(pcSubStr, pacBounds, pcDirection, pCaseSensitive)

		#>

	#-- WITHOUT CASESENSITIVITY

	def FindFirstSubStringBetweenDIBZZ(pcSubStr, pcBound1, pcBound2, pcDirection)
		return This.FindFirstSubStringBetweenDIBZZ(pcSubStr, pcBound1, pcBound2, pcDirection)

		#< @FunctionAlternativeForms

		def FindFirstSubStringBoundedByDIBZZ(pcSubStr, pacBounds, pcDirection)
			return This.FindFirstSubStringBoundedByDIBZZ(pcSubStr, pacBounds, pcDirection)

		#--
	
		def FindFirstSubStringBetweenAsSectionsDIB(pcSubStr, pcBound1, pcBound2, pcDirection)
			return This.FindFirstSubStringBetweenDIBZZ(pcSubStr, pcBound1, pcBound2, pcDirection)

		def FindFirstSubStringBoundedByAsSectionsDIB(pcSubStr, pacBounds, pcDirection)
			return This.FindFirstSubStringBoundedByDIBZZ(pcSubStr, pacBounds, pcDirection)

		#==

		def FirstSubStringBetweenAsSectionsDIB(pcSubStr, pcBound1, pcBound2, pcDirection)
			return This.FindFirstSubStringBetweenDIBZZ(pcSubStr, pcBound1, pcBound2, pcDirection)

		def FirstSubStringBoundedByAsSectionsDIB(pcSubStr, pacBounds, pcDirection)
			return This.FindFirstSubStringBoundedByDIBZZ(pcSubStr, pacBounds, pcDirection)

		#>

	   #----------------------------------------------------------------------------------#
	  #  GETTING THE SUBSTRING ANDT ITS FIRST OCCURRENCE (AS SECTION) BETWEEN TWO GIVEN  #
	 #  SUBSTRINGS GOININH IN A GIVEN DIRECTION AND INCLUDING BOUNDS                    #
	#----------------------------------------------------------------------------------#

	def FirstSubStringBetweenDCSIBZZ(pcSubStr, pcBound1, pcBound2, pcDirection, pCaseSensitive)
		return This.NthSubStringBetweenDCSIBZZ(1, pcSubStr, pcBound1, pcBound2, pcDirection, pCaseSensitive)

		#< @FunctionAlternativeForms

		def FirstSubStringBoundedByDCSIBZZ(pcSubStr, pacBounds, pcDirection, pCaseSensitive)
			return This.NthSubStringBoundedByDCSIBZZ(1, pcSubStr, pacBounds, pcDirection, pCaseSensitive)
	
		#--

		def FirstSubStringBetweenAsSectionDCSIB(pcSubStr, pcBound1, pcBound2, pcDirection, pCaseSensitive)
			return This.FirstSubStringBetweenDCSIBZZ(pcSubStr, pcBound1, pcBound2, pcDirection, pCaseSensitive)

		def FirstSubStringBoundedByAsSectionDCSIB(pcSubStr, pacBounds, pcDirection, pCaseSensitive)
			return This.FirstSubStringBoundedByDCSIBZZ(pcSubStr, pacBounds, pcDirection, pCaseSensitive)

		#>

	#-- WITHOUT CASESENSITIVITY

	def FirstSubStringBetweenDIBZZ(pcSubStr, pcBound1, pcBound2, pcDirection)
		return This.FirstSubStringBetweenDCSIBZZ(pcSubStr, pcBound1, pcBound2, pcDirection, TRUE)

		#< @FunctionAlternativeForms

		def FirstSubStringBoundedByDIBZZ(pcSubStr, pacBounds, pcDirection)
			return This.NthSubStringBoundedByDIBZZ(1, pcSubStr, pacBounds, pcDirection)
	
		#--

		def FirstSubStringBetweenAsSectionDIB(pcSubStr, pcBound1, pcBound2, pcDirection)
			return This.FirstSubStringBetweenDIBZZ(pcSubStr, pcBound1, pcBound2, pcDirection)

		def FirstSubStringBoundedByAsSectionDIB(pcSubStr, pacBounds, pcDirection)
			return This.FirstSubStringBoundedByDIBZZ(pcSubStr, pacBounds, pcDirection)

		#>

	   #---------------------------------------------------------------------------#
	  #  FINDING FIRST OCCURRENCE OF A SUBSTRING BOUNDED BY TWO OTHER SUBSTRINGS  #
	 #  STARTING AT A GIVEN POSITION AND GOING IN A GIVEN DIRECTION              #
	#===========================================================================#

	def FindFirstSubStringBetweenSDCS(pcSubStr, pcBound1, pcBound2, pnStartingAt, pcDirection, pCaseSensitive)
		return This.FindNthSubStringBetweenSDCS(1, pcSubStr, pcBound1, pcBound2, pnStartingAt, pcDirection, pCaseSensitive)

		#< @FunctionAlternativeForms

		def FindFirstSubStringBoundedBySDCS(pcSubStr, pacBounds, pnStartingAt, pcDirection, pCaseSensitive)
			return This.FindNthSubStringBoundedBySDCS(1, pcSubStr, pacBounds, pnStartingAt, pcDirection, pCaseSensitive)


		#--
	
		def FindFirstSubStringBetweenSDCSZ(pcSubStr, pcBound1, pcBound2, pnStartingAt, pcDirection, pCaseSensitive)
			return This.FindFirstSubStringBetweenSDCS(pcSubStr, pcBound1, pcBound2, pnStartingAt, pcDirection, pCaseSensitive)

		def FindFirstSubStringBoundedBySDCSZ(pcSubStr, pacBounds, pnStartingAt, pcDirection, pCaseSensitive)
			return This.FindFirstSubStringBoundedBySDCS(pcSubStr, pacBounds, pnStartingAt, pcDirection, pCaseSensitive)

		#==

		def FirstSubStringBetweenSDCS(pcSubStr, pcBound1, pcBound2, pnStartingAt, pcDirection, pCaseSensitive)
			return This.FindFirstSubStringBetweenSD(pcSubStr, pcBound1, pcBound2, pnStartingAt, pcDirection)

		def FirstSubStringBoundedBySDCS(pcSubStr, pacBounds, pnStartingAt, pcDirection, pCaseSensitive)
			return This.FindFirstSubStringBoundedBySDCS(pcSubStr, pacBounds, pnStartingAt, pcDirection, pCaseSensitive)

		#>

	#-- WITHOUT CASESENSITIVITY

	def FindFirstSubStringBetweenSD(pcSubStr, pcBound1, pcBound2, pnStartingAt, pcDirection)
		return This.FindFirstSubStringBetweenSDCS(pcSubStr, pcBound1, pcBound2,pnStartingAt, pcDirection, TRUE)

		#< @FunctionAlternativeForms

		def FindFirstSubStringBoundedBySD(pcSubStr, pacBounds, pnStartingAt, pcDirection)
			return This.FindFirstSubStringBoundedBySD(pcSubStr, pacBounds, pnStartingAt, pcDirection)

		#--
	
		def FindFirstSubStringBetweenSDZ(pcSubStr, pcBound1, pcBound2, pnStartingAt, pcDirection)
			return This.FindFirstSubStringBetweenSD(pcSubStr, pcBound1, pcBound2, pnStartingAt, pcDirection)

		def FindFirstSubStringBoundedBySDZ(pcSubStr, pacBounds, pnStartingAt, pcDirection)
			return This.FindFirstSubStringBoundedBySD(pcSubStr, pacBounds, pnStartingAt, pcDirection)

		#==

		def FirstSubStringBetweenSD(pcSubStr, pcBound1, pcBound2, pnStartingAt, pcDirection)
			return This.FindFirstSubStringBetweenSD(pcSubStr, pcBound1, pcBound2, pnStartingAt, pcDirection)

		def FirstSubStringBoundedBySD(pcSubStr, pacBounds, pnStartingAt, pcDirection)
			return This.FindFirstSubStringBoundedBySD(pcSubStr, pacBounds, pnStartingAt, pcDirection)

		#>

	   #----------------------------------------------------------------------------#
	  #  GETTING THE SUBSTRING AND ITS FIRST OCCURRENCE (AS SECTION) BETWEEN TWO   #
	 #  SUBSTRINGS STARTING AT A GIVEN POSITION AND GOINING IN A GIVEN DIRECTION  #
	#----------------------------------------------------------------------------#

	def FirstSubStringBetweenSDCSZ(pcSubStr, pcBound1, pcBound2, pnStartingAt, pcDirection, pCaseSensitive)
		return This.NthSubStringBetweenSDCSZ(1, pcSubStr, pcBound1, pcBound2, pnStartingAt, pcDirection, pCaseSensitive)

		#< @FunctionAlternativeForms

		def FirstSubStringBoundedBySDCSZ(pcSubStr, pacBounds, pnStartingAt, pcDirection, pCaseSensitive)
			return This.NthSubStringBoundedBySDCSZ(1, pcSubStr, pacBounds, pnStartingAt, pcDirection, pCaseSensitive)

		#>

	#-- WITHOUT CASESENSITIVITY

	def FirstSubStringBetweenSDZ(pcSubStr, pcBound1, pcBound2, pnStartingAt, pcDirection)
		return This.FirstSubStringBetweenSDCSZ(pcSubStr, pcBound1, pcBound2, pnStartingAt, pcDirection, TRUE)

		#< @FunctionAlternativeForms

		def FirstSubStringBoundedBySDZ(pcSubStr, pacBounds, pnStartingAt, pcDirection)
			return This.NthSubStringBoundedBySDCSZ(1, pcSubStr, pacBounds, pnStartingAt, pcDirection, pCaseSensitive)

		#>


	   #----------------------------------------------------------------------------------------#
	  #  FINDING FIRST OCCURRENCE OF A SUBSTRING BOUNDED BY TWO OTHER SUBSTRINGSS STARTING     #
	 #  AT A GIVEN POSITION, GOING IN A GIVEN DIRECTION, AND RETURNING POSITIONS AS SECTIONS  #
	#========================================================================================#

	def FindFirstSubStringBetweenSDCSZZ(pcSubStr, pcBound1, pcBound2, pnStartingAt, pcDirection, pCaseSensitive)
		return This.FindFirstSubStringBetweenSDCSZZ(pcSubStr, pcBound1, pcBound2, pnStartingAt, pcDirection, pCaseSensitive)


		#< @FunctionAlternativeForms

		def FindFirstSubStringBoundedBySDCSZZ(pcSubStr, pacBounds, pnStartingAt, pcDirection, pCaseSensitive)
			return This.FindBoundedBySDCSZZ(pcSubStr, pacBounds, pnStartingAt, pcDirection, pCaseSensitive)

		#--
	
		def FindFirstSubStringBetweenAsSection_SDCS(pcSubStr, pcBound1, pcBound2, pnStartingAt, pcDirection, pCaseSensitive)
			return This.FindFirstSubStringBetweenSDCSZZ(pcSubStr, pcBound1, pcBound2, pnStartingAt, pcDirection, pCaseSensitive)

		def FindFirstSubStringBoundedByAsSection_SDCS(pcSubStr, pacBounds, pnStartingAt, pcDirection, pCaseSensitive)
			return This.FindFirstSubStringBoundedBySDCSZZ(pcSubStr, pacBounds, pnStartingAt, pcDirection, pCaseSensitive)

		#>

	#-- WITHOUT CASESENSITIVITY

	def FindFirstSubStringBetweenSDZZ(pcSubStr, pcBound1, pcBound2, pnStartingAt, pcDirection)
		return This.FindFirstSubStringBetweenSDCSZZ(pcSubStr, pcBound1, pcBound2, pnStartingAt, pcDirection, TRUE)

		#< @FunctionAlternativeForms

		def FindFirstSubStringBoundedBySDZZ(pcSubStr, pacBounds, pnStartingAt, pcDirection)
			return This.FindBoundedBySDZZ(pcSubStr, pacBounds, pnStartingAt, pcDirection)

		#--
	
		def FindFirstSubStringBetweenAsSection_SD(pcSubStr, pcBound1, pcBound2, pnStartingAt, pcDirection)
			return This.FindFirstSubStringBetweenSDZZ(pcSubStr, pcBound1, pcBound2, pnStartingAt, pcDirection)

		def FindFirstSubStringBoundedByAsSection_SD(pcSubStr, pacBounds, pnStartingAt, pcDirection)
			return This.FindFirstSubStringBoundedBySDZZ(pcSubStr, pacBounds, pnStartingAt, pcDirection)

		#>

	   #---------------------------------------------------------------------------------#
	  #  GETTING THE SUBSTRING AND ITS FIRST OCCURRENCE (AS SECTION) BETWEEN TWO GIVEN  #
	 #  SUBSTRINGS STARTING AT A GIVEN POSITION AND GOINING IN A GIVEN DIRECTION       #
	#---------------------------------------------------------------------------------#

	def FirstSubStringBetweenSDCSZZ(pcSubStr, pcBound1, pcBound2, pnStartingAt, pcDirection, pCaseSensitive)
		return This.NthSubStringBetweenSDCSZZ(1, pcSubStr, pcBound1, pcBound2, pnStartingAt, pcDirection, pCaseSensitive)

		#< @FunctionAlternativeForms

		def FirstSubStringBoundedBySDCSZZ(pcSubStr, pacBounds, pnStartingAt, pcDirection, pCaseSensitive)
			return This.NthSubStringBoundedBySDCSZZ(1, pcSubStr, pacBounds, pnStartingAt, pcDirection, pCaseSensitive)

		#--

		def FirstSubStringBetweenAsSection_SDCS(pcSubStr, pcBound1, pcBound2, pnStartingAt, pcDirection, pCaseSensitive)
			return This.FirstSubStringBetweenSDCSZZ(pcSubStr, pcBound1, pcBound2, pnStartingAt, pcDirection, pCaseSensitive)

		def FirstSubStringBoundedByAsSection_SDCS(pcSubStr, pacBounds, pnStartingAt, pcDirection, pCaseSensitive)
			return This.FirstSubStringBoundedBySDCSZZ(pcSubStr, pacBounds, pnStartingAt, pcDirection, pCaseSensitive)

		#>

	#-- WITHOUT CASESENSITIVITY

	def FirstSubStringBetweenSDZZ(pcSubStr, pcBound1, pcBound2, pnStartingAt, pcDirection)
		return This.FirstSubStringBetweenSDCSZZ(pcSubStr, pcBound1, pcBound2, pnStartingAt, pcDirection, TRUE)

		#< @FunctionAlternativeForms

		def FirstSubStringBoundedBySDZZ(pcSubStr, pacBounds, pnStartingAt, pcDirection)
			return This.NthSubStringBoundedBySDZZ(1, pcSubStr, pacBounds, pnStartingAt, pcDirection)

		#--

		def FirstSubStringBetweenAsSection_SD(pcSubStr, pcBound1, pcBound2, pnStartingAt, pcDirection)
			return This.FirstSubStringBetweenSDZZ(pcSubStr, pcBound1, pcBound2, pnStartingAt, pcDirection)

		def FirstSubStringBoundedByAsSection_SD(pcSubStr, pacBounds, pnStartingAt, pcDirection)
			return This.FirstSubStringBoundedBySDZZ(pcSubStr, pacBounds, pnStartingAt, pcDirection)

		#>

	   #-------------------------------------------------------------------------------------#
	  #  FINDING FIRST OCCURRENCE OF A SUBSTRING BOUNDED BY TWO OTHER SUBSTRINGSS STARTING  #
	 #  AT A GIVEN POSITION, GOING IN A GIVEN DIRECTION, AND INCLUDING BOUNDS              #
	#=====================================================================================#

	def FindFirstSubStringBetweenSDCSIB(pcSubStr, pcBound1, pcBound2, pnStartingAt, pcDirection, pCaseSensitive)
		return This.FindNthSubStringBetweenSDCSIB(1, pcSubStr, pcBound1, pcBound2, pnStartingAt, pcDirection, pCaseSensitive)

		#< @FunctionAlternativeForms

		def FindFirstSubStringBoundedBySDCSIB(pcSubStr, pacBounds, pnStartingAt, pcDirection, pCaseSensitive)
			return This.FindNthSubStringBoundedBySDCSIB(1, pcSubStr, pacBounds, pnStartingAt, pcDirection, pCaseSensitive)

		#--
	
		def FindFirstSubStringBetweenSDCSIBZ(pcSubStr, pcBound1, pcBound2, pnStartingAt, pcDirection, pCaseSensitive)
			return This.FindFirstSubStringBetweenSDCSIB(pcSubStr, pcBound1, pcBound2, pnStartingAt, pcDirection, pCaseSensitive)

		def FindFirstSubStringBoundedBySDCSIBZ(pcSubStr, pacBounds, pnStartingAt, pcDirection, pCaseSensitive)
			return This.FindFirstSubStringBoundedBySDCSIB(pcSubStr, pacBounds, pnStartingAt, pcDirection, pCaseSensitive)

		#==

		def FirstSubStringBetweenSDCSIB(pcSubStr, pcBound1, pcBound2, pnStartingAt, pcDirection, pCaseSensitive)
			return This.FindFirstSubStringBetweenSDIB(pcSubStr, pcBound1, pcBound2, pnStartingAt, pcDirection)

		def FirstSubStringBoundedBySDCSIB(pcSubStr, pacBounds, pnStartingAt, pcDirection, pCaseSensitive)
			return This.FindBoundedBySDCSIB(pcSubStr, pacBounds, pnStartingAt, pcDirection, pCaseSensitive)

		#>

	#-- WITHOUT CASESENSITIVITY

	def FindFirstSubStringBetweenSDIB(pcSubStr, pcBound1, pcBound2, pnStartingAt, pcDirection)
		return This.FindFirstSubStringBetweenSDCSIB(pcSubStr, pcBound1, pcBound2,pnStartingAt, pcDirection, TRUE)

		#< @FunctionAlternativeForms

		def FindFirstSubStringBoundedBySDIB(pcSubStr, pacBounds, pnStartingAt, pcDirection)
			return This.FindFirstSubStringBoundedBySDIB(pcSubStr, pacBounds, pnStartingAt, pcDirection)

		#--
	
		def FindFirstSubStringBetweenSDIBZ(pcSubStr, pcBound1, pcBound2, pnStartingAt, pcDirection)
			return This.FindFirstSubStringBetweenSDIB(pcSubStr, pcBound1, pcBound2, pnStartingAt, pcDirection)

		def FindFirstSubStringBoundedBySDIBZ(pcSubStr, pacBounds, pnStartingAt, pcDirection)
			return This.FindFirstSubStringBoundedBySDIB(pcSubStr, pacBounds, pnStartingAt, pcDirection)

		#==

		def FirstSubStringBetweenSDIB(pcSubStr, pcBound1, pcBound2, pnStartingAt, pcDirection)
			return This.FindFirstSubStringBetweenSDIB(pcSubStr, pcBound1, pcBound2, pnStartingAt, pcDirection)

		def FirstSubStringBoundedBySDIB(pcSubStr, pacBounds, pnStartingAt, pcDirection)
			return This.FindFirstSubStringBoundedBySDIB(pcSubStr, pacBounds, pnStartingAt, pcDirection)

		#>

	   #-------------------------------------------------------------------------------------------#
	  #  GETTING THE SUBSTRING AND ITS FIRST OCCURRENCE BETWEEN TWO GIVEN SUBSTRINGS STARTING AT  #
	 #  A GIVEN POSITION AND GOINING IN A GIVEN DIRECTION AND INCLUDING BOUNDS                   #
	#-------------------------------------------------------------------------------------------#

	def FirstSubStringBetweenSDCSIBZ(pcSubStr, pcBound1, pcBound2, pnStartingAt, pcDirection, pCaseSensitive)
		return This.NthSubStringBetweenSDCSIBZ(1, pcSubStr, pcBound1, pcBound2, pnStartingAt, pcDirection, pCaseSensitive)

		def FirstSubStringBoundedBySDCSIBZ(pcSubStr, pacBounds, pnStartingAt, pcDirection, pCaseSensitive)
			return This.NthSubStringBoundedBySDCSIBZ(1, pcSubStr, pacBounds, pnStartingAt, pcDirection, pCaseSensitive)

	#-- WITHOUT CASESENSITIVITY

	def FirstSubStringBetweenSDIBZ(pcSubStr, pcBound1, pcBound2, pnStartingAt, pcDirection)
		return This.FirstSubStringBetweenSDCSIBZ(pcSubStr, pcBound1, pcBound2, pnStartingAt, pcDirection, TRUE)

		def FirstSubStringBoundedBySDIBZ(pcSubStr, pacBounds, pnStartingAt, pcDirection)
			return This.FirstSubStringBoundedBySDCSIBZ(pcSubStr, pacBounds, pnStartingAt, pcDirection, TRUE)

	   #------------------------------------------------------------------------------------------------#
	  #  FINDING FIRST OCCURRENCE OF A SUBSTRING BOUNDED BY TWO OTHER SUBSTRINGSS STARTING AT A GIVEN  #
	 #  POSITION, GOING IN A GIVEN DIRECTION, INCLUDING BOUNDS, AND RETURNING POSITIONS AS SECTIONS   #
	#================================================================================================#

	def FindFirstSubStringBetweenSDCSIBZZ(pcSubStr, pcBound1, pcBound2, pnStartingAt, pcDirection, pCaseSensitive)
		return This.FindNthSubStringBetweenSDCSIBZZ(1, pcSubStr, pcBound1, pcBound2, pnStartingAt, pcDirection, pCaseSensitive)

		#< @FunctionAlternativeForms

		def FindFirstSubStringBoundedBySDCSIBZZ(pcSubStr, pacBounds, pnStartingAt, pcDirection, pCaseSensitive)
			return This.FindFirstSubStringBoundedBySDCSIBZZ(pcSubStr, pacBounds, pnStartingAt, pcDirection, pCaseSensitive)

		#--
	
		def FindFirstSubStringBetweenAsSectionsSDCSIB(pcSubStr, pcBound1, pcBound2, pnStartingAt, pcDirection, pCaseSensitive)
			return This.FindFirstSubStringBetweenSDCSIBZZ(pcSubStr, pcBound1, pcBound2, pnStartingAt, pcDirection, pCaseSensitive)

		def FindFirstSubStringBoundedByAsSectionsSDCSIB(pcSubStr, pacBounds, pnStartingAt, pcDirection, pCaseSensitive)
			return This.FindFirstSubStringBoundedBySDCSIBZZ(pcSubStr, pacBounds, pnStartingAt, pcDirection, pCaseSensitive)

		#==

		def FirstSubStringBetweenAsSectionsSDCSIB(pcSubStr, pcBound1, pcBound2, pnStartingAt, pcDirection, pCaseSensitive)
			return This.FindFirstSubStringBetweenSDCSIBZZ(pcSubStr, pcBound1, pcBound2, pnStartingAt, pcDirection, pCaseSensitive)

		def FirstSubStringBoundedByAsSectionsSDCSIB(pcSubStr, pacBounds, pnStartingAt, pcDirection, pCaseSensitive)
			return This.FindFirstSubStringBoundedBySDCSIBZZ(pcSubStr, pacBounds, pnStartingAt, pcDirection, pCaseSensitive)

		#>

	#-- WITHOUT CASESENSITIVITY

	def FindFirstSubStringBetweenSDIBZZ(pcSubStr, pcBound1, pcBound2, pnStartingAt, pcDirection)
		return This.FindFirstSubStringBetweenSDCSIBZZ(pcSubStr, pcBound1, pcBound2, pnStartingAt, pcDirection, TRUE)

		#< @FunctionAlternativeForms

		def FindFirstSubStringBoundedBySDIBZZ(pcSubStr, pacBounds, pnStartingAt, pcDirection)
			return This.FindFirstSubStringBoundedBySDIBZZ(pcSubStr, pacBounds, pnStartingAt, pcDirection)

		#--
	
		def FindFirstSubStringBetweenAsSectionsSDIB(pcSubStr, pcBound1, pcBound2, pnStartingAt, pcDirection)
			return This.FindFirstSubStringBetweenSDIBZZ(pcSubStr, pcBound1, pcBound2, pnStartingAt, pcDirection)

		def FindFirstSubStringBoundedByAsSectionsSDIB(pcSubStr, pacBounds, pnStartingAt, pcDirection)
			return This.FindFirstSubStringBoundedBySDIBZZ(pcSubStr, pacBounds, pnStartingAt, pcDirection)

		#==

		def FirstSubStringBetweenAsSectionsSDIB(pcSubStr, pcBound1, pcBound2, pnStartingAt, pcDirection)
			return This.FindFirstSubStringBetweenSDIBZZ(pcSubStr, pcBound1, pcBound2, pnStartingAt, pcDirection)

		def FirstSubStringBoundedByAsSectionsSDIB(pcSubStr, pacBounds, pnStartingAt, pcDirection)
			return This.FindFirstSubStringBoundedBySDIBZZ(pcSubStr, pacBounds, pnStartingAt, pcDirection)

		#>

	    #--------------------------------------------------------------------------------#
	   #  GETTING THE SUBSTRING AND ITS LAST OCCURRENCE (AS SECTION) BETWEEN TWO GIVEN  #
	  #  SUBSTRINGS, STARTING AT A GIVEN POSITION, GOINING IN A GIVEN DIRECTION, AND   #
	 # INCLUDING BOUNDS IN THE RESULT                                                 #
	#--------------------------------------------------------------------------------#

	def FirstSubStringBetweenSDCSIBZZ(pcSubStr, pcBound1, pcBound2, pnStartingAt, pcDirection, pCaseSensitive)
		return This.NthSubStringBetweenSDCSIBZZ(1, pcSubStr, pcBound1, pcBound2, pnStartingAt, pcDirection, pCaseSensitive)

		#< @FunctionAlternativeForms

		def FirstSubStringBoundedBySDCSIBZZ(pcSubStr, pacBounds, pnStartingAt, pcDirection, pCaseSensitive)
			return This.NthSubStringBoundedBySDCSIBZZ(1, pcSubStr, pacBounds, pnStartingAt, pcDirection, pCaseSensitive)

		#--

		def FirstSubStringBetweenAsSection_SDCSIB(pcSubStr, pcBound1, pcBound2, pnStartingAt, pcDirection, pCaseSensitive)
			return This.FirstSubStringBetweenSDCSIBZZ(pcSubStr, pcBound1, pcBound2, pnStartingAt, pcDirection, pCaseSensitive)

		def FirstSubStringBoundedByAsSection_SDCSIB(pcSubStr, pacBounds, pnStartingAt, pcDirection, pCaseSensitive)
			return This.FirstSubStringBoundedBySDCSIBZZ(pcSubStr, pacBounds, pnStartingAt, pcDirection, pCaseSensitive)

		#>

	#-- WITHOUT CASESENSITIVITY

	def FirstSubStringBetweenSDIBZZ(pcSubStr, pcBound1, pcBound2, pnStartingAt, pcDirection)
		return This.FirstSubStringBetweenSDCSIBZZ(pcSubStr, pcBound1, pcBound2, pnStartingAt, pcDirection, TRUE)

		#< @FunctionAlternativeForms

		def FirstSubStringBoundedBySDIBZZ(pcSubStr, pacBounds, pnStartingAt, pcDirection)
			return This.NthSubStringBoundedBySDIBZZ(1, pcSubStr, pacBounds, pnStartingAt, pcDirection)

		#--

		def FirstSubStringBetweenAsSection_SDIB(pcSubStr, pcBound1, pcBound2, pnStartingAt, pcDirection)
			return This.FirstSubStringBetweenSDIBZZ(pcSubStr, pcBound1, pcBound2, pnStartingAt, pcDirection)

		def FirstSubStringBoundedByAsSection_SDIB(pcSubStr, pacBounds, pnStartingAt, pcDirection)
			return This.FirstSubStringBoundedBySDIBZZ(pcSubStr, pacBounds, pnStartingAt, pcDirection)

		#>

	   #-------------------------------------------------------#
	  #  FINDING LAST OCCURRENCE OF A SUBSTRING BOUNDED BY    #
	 #  TWO OTHER SUBSTRINGS AND RETURNING THEM AS SECTIONS  #
vvv	#=======================================================#

	def FindLastSubStringBetweenCSZZ(pcSubStr, pcBound1, pcBound2, pCaseSensitive)
		nLast = This.NumberOfOccurrenceBetweenCS(pcSubStr, pcBound1, pcBound2, pCaseSensitive)
		return This.FindNthSubStringBetweenCSZZ(nLast, pcSubStr, pcBound1, pcBound2, pCaseSensitive)

		#< @FunctionAlternativeForms

		def FindLastSubStringBoundedByCSZZ(pcSubStr, pacBounds, pCaseSensitive)
			return This.FindNthSubStringBoundedByCSZZ(nLast, pcSubStr, pacBounds, pCaseSensitive)

		#--
	
		def FindLastSubStringBetweenAsSectionsCS(pcSubStr, pcBound1, pcBound2, pCaseSensitive)
			return This.FindLastSubStringBetweenCSZZ(pcSubStr, pcBound1, pcBound2, pCaseSensitive)

		def FindLastSubStringBoundedByAsSectionsCS(pcSubStr, pacBounds, pCaseSensitive)
			return This.FindLastSubStringBoundedByCSZZ(pcSubStr, pacBounds, pCaseSensitive)

		#==

		def LastSubStringBetweenAsSectionsCS(pcSubStr, pcBound1, pcBound2, pCaseSensitive)
			return This.FindLastSubStringBetweenCSZZ(pcSubStr, pcBound1, pcBound2, pCaseSensitive)

		def LastSubStringBoundedByAsSectionsCS(pcSubStr, pacBounds, pCaseSensitive)
			return This.FindLastSubStringBoundedByCSZZ(pcSubStr, pacBounds, pCaseSensitive)

		#>

	#-- WITHOUT CASESENSITIVITY

	def FindLastSubStringBetweenZZ(pcSubStr, pcBound1, pcBound2)
		return This.FindLastSubStringBetweenCSZZ(pcSubStr, pcBound1, pcBound2, TRUE)

		#< @FunctionAlternativeForms

		def FindLastSubStringBoundedByZZ(pcSubStr, pacBounds)
			return This.FindLastSubStringBoundedByZZ(pcSubStr, pacBounds)

		#--
	
		def FindLastSubStringBetweenAsSections(pcSubStr, pcBound1, pcBound2)
			return This.FindLastSubStringBetweenZZ(pcSubStr, pcBound1, pcBound2)

		def FindLastSubStringBoundedByAsSections(pcSubStr, pacBounds)
			return This.FindLastSubStringBoundedByZZ(pcSubStr, pacBounds)

		#==

		def LastSubStringBetweenAsSections(pcSubStr, pcBound1, pcBound2)
			return This.FindLastSubStringBetweenZZ(pcSubStr, pcBound1, pcBound2)

		def LastSubStringBoundedByAsSections(pcSubStr, pacBounds)
			return This.FindLastSubStringBoundedByZZ(pcSubStr, pacBounds)

		#>

	  #--------------------------------------------------------------------------------------------#
	 #  GETTING THE SUBSTRING AND ITS LAST OCCURRENCE (AS SECTION) BETWEEN TWO GIVEN SUBSTRINGS  #
	#--------------------------------------------------------------------------------------------#

	def LastSubStringBetweenCSZZ(pcSubStr, pcBound1, pcBound2, pCaseSensitive)
		nLast = This.NumberOfOccurrenceBetweenCS(pcSubStr, pcBound1, pcBound2, pCaseSensitive)
		return This.NthSubStringBetweenCSZZ(nLast, pcSubStr, pcBound1, pcBound2, pCaseSensitive)

		#< @FunctionAlternativeForms

		def LastSubStringBoundedByCSZZ(pcSubStr, pacBounds, pCaseSensitive)
			return This.NthSubStringBoundedByCSZZ(nLast, pcSubStr, pacBounds, pCaseSensitive)

		#--

		def LastSubStringBetweenAsSectionCS(pcSubStr, pcBound1, pcBound2, pCaseSensitive)
			return This.LastSubStringBetweenCSZZ(pcSubStr, pcBound1, pcBound2, pCaseSensitive)

		def LastSubStringBoundedByAsSectionCS(pcSubStr, pacBounds, pCaseSensitive)
			return This.LastSubStringBoundedByCSZZ(pcSubStr, pacBounds, pCaseSensitive)

		#>

	#-- WITHOUT CASESENSITIVITY

	def LastSubStringBetweenZZ(pcSubStr, pcBound1, pcBound2)
		return This.LastSubStringBetweenCSZZ(pcSubStr, pcBound1, pcBound2, TRUE)

		#< @FunctionAlternativeForms

		def LastSubStringBoundedByZZ(pcSubStr, pacBounds)
			return This.LastSubStringBoundedByCSZZ(pcSubStr, pacBounds, TRUE)

		#--

		def LastSubStringBetweenAsSection(pcSubStr, pcBound1, pcBound2)
			return This.LastSubStringBetweenZZ(pcSubStr, pcBound1, pcBound2)

		def LastSubStringBoundedByAsSection(pcSubStr, pacBounds)
			return This.LastSubStringBoundedByZZ(pcSubStr, pacBounds)

		#>

	  #--------------------------------------------------------------------------------------------#
	 #  FINDING LAST OCCURRENCE OF A SUBSTRING BOUNDED BY TWO OTHER SUBSTRINGS INCLUDING BOUNDS  #
	#============================================================================================#

	def FindLastSubStringBetweenCSIB(pcSubStr, pcBound1, pcBound2, pCaseSensitive)
		nLast = This.NumberOfOccurrenceBetweenCS(pcSubStr, pcBound1, pcBound2, pCaseSensitive)
		return This.FindNthSubStringBetweenCSIB(nLast, pcSubStr, pcBound1, pcBound2, pCaseSensitive)

		#< @FunctionAlternativeForms

		def FindLastSubStringBoundedByCSIB(pcSubStr, pacBounds, pCaseSensitive)
			return This.FindNthSubStringBoundedByCSIB(nLast, pcSubStr, pacBounds, pCaseSensitive)

		#--
	
		def FindLastSubStringBetweenCSIBZ(pcSubStr, pcBound1, pcBound2, pCaseSensitive)
			return This.FindLastSubStringBetweenCSIB(pcSubStr, pcBound1, pcBound2, pCaseSensitive)

		def FindLastSubStringBoundedByCSIBZ(pcSubStr, pacBounds, pCaseSensitive)
			return This.FindLastSubStringBoundedByCSIB(pcSubStr, pacBound, pCaseSensitives)

		#==

		def LastSubStringBetweenCSIB(pcSubStr, pcBound1, pcBound2, pCaseSensitive)
			return This.FindLastSubStringBetweenCSIB(pcSubStr, pcBound1, pcBound2, pCaseSensitive)

		def LastSubStringBoundedByCSIB(pcSubStr, pacBounds, pCaseSensitive)
			return This.FindLastSubStringBoundedByCSIB(pcSubStr, pacBounds, pCaseSensitive)
	
		def LastSubStringBetweenCSIBZ(pcSubStr, pcBound1, pcBound2, pCaseSensitive)
			return This.FindLastSubStringBetweenCSIB(pcSubStr, pcBound1, pcBound2, pCaseSensitive)

		def LastSubStringBoundedByCSIBZ(pcSubStr, pacBounds, pCaseSensitive)
			return This.FindLastSubStringBoundedByCSIB(pcSubStr, pacBounds, pCaseSensitive)

		#>

	#-- WITHOUT CASESENSITIVE

	def FindLastSubStringBetweenIB(pcSubStr, pcBound1, pcBound2)
		return This.FindLastSubStringBetweenCSIB(pcSubStr, pcBound1, pcBound2, TRUE)

		#< @FunctionAlternativeForms

		def FindLastSubStringBoundedByIB(pcSubStr, pacBounds)
			if isString(pacBounds)
				return This.FindLastSubStringBetweenIB(pcSubStr, pacBounds, pacBounds)

			but isList(pacBounds) and Q(pacBounds).IsPairOfStrings()
				return TThis.FindLastSubStringBetweenIB(pcSubStr, pacBounds[1], pacBounds[2])

			else
				StzRaise("Incorrect param type! pacBounds must be a string or pair of strings.")
			ok

		#--
	
		def FindLastSubStringBetweenZIB(pcSubStr, pcBound1, pcBound2)
			return This.FindLastSubStringBetweenIB(pcSubStr, pcBound1, pcBound2)

		def FindLastSubStringBoundedByZIB(pcSubStr, pacBounds)
			return This.FindLastSubStringBoundedByIB(pcSubStr, pacBounds)

		#==

		def LastSubStringBetweenIB(pcSubStr, pcBound1, pcBound2)
			return This.FindLastSubStringBetweenIB(pcSubStr, pcBound1, pcBound2)

		def LastSubStringBoundedByIB(pcSubStr, pacBounds)
			return This.FindLastSubStringBoundedByIB(pcSubStr, pacBounds)
	
		def LastSubStringBetweenZIB(pcSubStr, pcBound1, pcBound2)
			return This.FindLastSubStringBetweenIB(pcSubStr, pcBound1, pcBound2)

		def LastSubStringBoundedByZIB(pcSubStr, pacBounds)
			return This.FindLastSubStringBoundedByIB(pcSubStr, pacBounds)

		#>

	   #-------------------------------------------------------------------------#
	  #  FINDING LAST OCCURRENCE OF A SUBSTRING BOUNDED BY TWO OTHER           #
	 #  SUBSTRINGS INCLUDING BOUNDS AND RETURNING THEIR POSITIONS AS SECTIONS  #
	#-------------------------------------------------------------------------#

	def FindLastSubStringBetweenCSIBZZ(pcSubStr, pcBound1, pcBound2, pCaseSensitive)
		nLast = This.NumberOfOccurrenceBetweenCS(pcSubStr, pcBound1, pcBound2, pCaseSensitive)
		return This.FindNthSubStringBetweenCSIBZZ(nLast, pcSubStr, pcBound1, pcBound2, pCaseSensitive)

		#< @FunctionAlternativeForms

		def FindLastSubStringBoundedByCSIBZZ(pcSubStr, pacBounds, pCaseSensitive)
			return This.FindNthSubStringBoundedByCSIBZZ(nLast, pcSubStr, pacBounds, pCaseSensitive)

		#--
	
		def FindLastSubStringBetweenAsSectionsCSIB(pcSubStr, pcBound1, pcBound2, pCaseSensitive)
			return This.FindLastSubStringBetweenCSIBZZ(pcSubStr, pcBound1, pcBound2, pCaseSensitive)

		def FindLastSubStringBoundedByAsSectionsCSIB(pcSubStr, pacBounds, pCaseSensitive)
			return This.FindLastSubStringBoundedByCSIBZZ(pcSubStr, pacBounds, pCaseSensitive)

		#==

		def LastSubStringBetweenAsSectionsCSIB(pcSubStr, pcBound1, pcBound2, pCaseSensitive)
			return This.FindLastSubStringBetweenCSIBZZ(pcSubStr, pcBound1, pcBound2, pCaseSensitive)

		def LastSubStringBoundedByAsSectionsCSIB(pcSubStr, pacBounds, pCaseSensitive)
			return This.FindLastSubStringBoundedByCSIBZZ(pcSubStr, pacBounds, pCaseSensitive)

		#>

	#-- WITHOUT CASESENSITIVITY

	def FindLastSubStringBetweenZZIB(pcSubStr, pcBound1, pcBound2)
		return This.FindLastSubStringBetweenCSIBZZ(pcSubStr, pcBound1, pcBound2, TRUE)

		#< @FunctionAlternativeForms

		def FindLastSubStringBetweenIBZZ(pcSubStr, pcBound1, pcBound2)
			return This.FindLastSubStringBetweenIBZZ(pcSubStr, pcBound1, pcBound2)

		def FindLastSubStringBoundedByIBZZ(pcSubStr, pacBounds)
			return This.FindLastSubStringBoundedByIBZZ(pcSubStr, pacBounds)

		#--
	
		def FindLastSubStringBetweenAsSectionsIB(pcSubStr, pcBound1, pcBound2)
			return This.FindLastSubStringBetweenIBZZ(pcSubStr, pcBound1, pcBound2)

		def FindLastSubStringBoundedByAsSectionsIB(pcSubStr, pacBounds)
			return This.FindLastSubStringBoundedByIBZZ(pcSubStr, pacBounds)

		#==

		def LastSubStringBetweenAsSectionsIB(pcSubStr, pcBound1, pcBound2)
			return This.FindLastSubStringBetweenIBZZ(pcSubStr, pcBound1, pcBound2)

		def LastSubStringBoundedByAsSectionsIB(pcSubStr, pacBounds)
			return This.FindLastSubStringBoundedByIBZZ(pcSubStr, pacBounds)

		#>

	  #-------------------------------------------------------------------------------------------------------------#
	 #  GETTING THE SUBSTRING AND ITS LAST OCCURRENCE (AS SECTION) BETWEEN TWO GIVEN SUBSTRINGS INCLUDING BOUNDS  #
	#-------------------------------------------------------------------------------------------------------------#

	def LastSubStringBetweenCSIBZZ(pcSubStr, pcBound1, pcBound2, pCaseSensitive)
		nLast = This.NumberOfOccurrenceBetweenCS(pcSubStr, pcBound1, pcBound2, pCaseSensitive)
		return This.NthSubStringBetweenCSIBZZ(nLast, pcSubStr, pcBound1, pcBound2, pCaseSensitive)

		#< @FunctionAlternativeForms

		def LastSubStringBoundedByCSIBZZ(pcSubStr, pacBounds, pCaseSensitive)
			return This.NthLastSubStringBoundedByCSIBZZ(nLast, pcSubStr, pacBounds, pCaseSensitive)

		#--

		def LastSubStringBetweenAsSectionCSIB(pcSubStr, pcBound1, pcBound2, pCaseSensitive)
			return This.LastSubStringBetweenCSIBZZ(pcSubStr, pcBound1, pcBound2, pCaseSensitive)

		def LastSubStringBoundedByAsSectionCSIB(pcSubStr, pacBounds, pCaseSensitive)
			return This.LastSubStringBoundedByCSIBZZ(pcSubStr, pacBounds, pCaseSensitive)

		#>

	#-- WITHOUT CASESENSITIVITY

	def LastSubStringBetweenIBZZ(pcSubStr, pcBound1, pcBound2)
		return This.LastSubStringBetweenCSIBZZ(pcSubStr, pcBound1, pcBound2, TRUE)

		#< @FunctionAlternativeForms

		def LastSubStringBoundedByIBZZ(pcSubStr, pacBounds)
			return This.NthLastSubStringBoundedByIBZZ(nLast, pcSubStr, pacBounds)

		#--

		def LastSubStringBetweenAsSectionIB(pcSubStr, pcBound1, pcBound2)
			return This.LastSubStringBetweenIBZZ(pcSubStr, pcBound1, pcBound2)

		def LastSubStringBoundedByAsSectionIB(pcSubStr, pacBounds)
			return This.LastSubStringBoundedByIBZZ(pcSubStr, pacBounds)

		#>

	   #------------------------------------------------------#
	  #  FINDING LAST OCCURRENCE OF A SUBSTRING BOUNDED BY  #
	 #  TWO OTHER SUBSTRINGS STARTING AT A GIVEN POSITION   #
	#======================================================#

	def FindLastSubStringBetweenSCS(pcSubStr, pcBound1, pcBound2, pnStartingAt, pCaseSensitive)
		nLast = This.NumberOfOccurrenceBetweenSCS(pcSubStr, pcBound1, pcBound2, pnStartingAt, pCaseSensitive)
		return This.FindNthSubStringBetweenSCS(nLast, pcSubStr, pcBound1, pcBound2, pnStartingAt, pCaseSensitive)

		#< @FunctionalternativeForms

		def FindLastSubStringBoundedBySCS(pcSubStr, pacBounds, pnStartingAt, pCaseSensitive)
			return This.FindNthSubStringBoundedBySCS(nLast, pcSubStr, pacBounds, pnStartingAt, pCaseSensitive)

		#--
	
		def FindLastSubStringBetweenSCSZ(pcSubStr, pcBound1, pcBound2, pnStartingAt, pCaseSensitive)
			return This.FindLastSubStringBetweenSCS(pcSubStr, pcBound1, pcBound2, pnStartingAt, pCaseSensitive)

		def FindLastSubStringBoundedBySCSZ(pcSubStr, pacBounds, pnStartingAt, pCaseSensitive)
			return This.FindLastSubStringBoundedBySCS(pcSubStr, pacBounds, pnStartingAt, pCaseSensitive)

		#==

		def LastSubStringBetweenSCS(pcSubStr, pcBound1, pcBound2, pnStartingAt, pCaseSensitive)
			return This.FindLastSubStringBetweenSCS(pcSubStr, pcBound1, pcBound2, pnStartingAt, pCaseSensitive)

		def LastSubStringBoundedBySCS(pcSubStr, pacBounds, pnStartingAt, pCaseSensitive)
			return This.FindLastSubStringBoundedBySCS(pcSubStr, pacBounds, pnStartingAt, pCaseSensitive)

		#>

	#-- WITHOUT CASESENSITIVITY

	def FindLastSubStringBetweenS(pcSubStr, pcBound1, pcBound2, pnStartingAt)
		return This.FindLastSubStringBetweenSCS(pcSubStr, pcBound1, pcBound2, pnStartingAt, TRUE)

		#< @FunctionAlternativeForms

		def FindLastSubStringBoundedByS(pcSubStr, pacBounds, pnStartingAt)
			return This.FindLastSubStringBoundedByS(pcSubStr, pacBounds, pnStartingAt)

		#--
	
		def FindLastSubStringBetweenSZ(pcSubStr, pcBound1, pcBound2, pnStartingAt)
			return This.FindLastSubStringBetweenS(pcSubStr, pcBound1, pcBound2, pnStartingAt)

		def FindLastSubStringBoundedBySZ(pcSubStr, pacBounds, pnStartingAt)
			return This.FindLastSubStringBoundedByS(pcSubStr, pacBounds, pnStartingAt)

		#==

		def LastSubStringBetweenS(pcSubStr, pcBound1, pcBound2, pnStartingAt)
			return This.FindBetweenS(pcSubStr, pcBound1, pcBound2, pnStartingAt)

		def LastSubStringBoundedByS(pcSubStr, pacBounds, pnStartingAt)
			return This.FindLastSubStringBoundedByS(pcSubStr, pacBounds, pnStartingAt)

		#>

	  #-------------------------------------------------------------------------------#
	 #  GETTING THE SUBSTRING AND ITS LAST OCCURRENCE STARTING AT A GIVEN POSITION  #
	#-------------------------------------------------------------------------------#

	def LastSubStringBetweenSCSZ(pcSubStr, pcBound1, pcBound2, pnStartingAt, pCaseSensitive)
		nLast = This.NumberOfOccurrenceBetweenSCS(pcSubStr, pcBound1, pcBound2, pnStartingAt, pCaseSensitive)
		return This.NthSubStringBetweenSCSZ(nLast, pcSubStr, pcBound1, pcBound2, pnStartingAt, pCaseSensitive)

		def LastSubStringBoundedBySCSZ(pcSubStr, pacBounds, pnStartingAt, pCaseSensitive)
			return This.NthSubStringBoundedBySCSZ(nLast, pcSubStr, pacBounds, pnStartingAt, pCaseSensitive)

	#-- WITHOUT CASESENSITIVITY

	def LastSubStringBetweenSZ(pcSubStr, pcBound1, pcBound2, pnStartingAt)
		return This.LastSubStringBetweenSCSZ(pcSubStr, pcBound1, pcBound2, pnStartingAt, TRUE)

		def LastSubStringBoundedBySZ(pcSubStr, pacBounds, pnStartingAt)
			return This.NthSubStringBoundedBySZ(nLast, pcSubStr, pacBounds, pnStartingAt)

	   #---------------------------------------------------------------------------#
	  #  FINDING LAST OCCURRENCE OF A SUBSTRING BOUNDED BY TWO OTHER SUBSTRINGS  #
	 #  STARTING AT A GIVEN POSITION AND RETURNING POSITIONS AS SECTIONS         #
	#===========================================================================#

	def FindLastSubStringBetweenSCSZZ(pcSubStr, pcBound1, pcBound2, pnStartingAt, pCaseSensitive)
		nLast = This.NumberOfOccurrenceBetweenSCS(pcSubStr, pcBound1, pcBound2, pnStartingAt, pCaseSensitive)
		return This.FindNthSubStringBetweenSCSZZ(nLast, pcSubStr, pcBound1, pcBound2, pnStartingAt, pCaseSensitive)

		#< @FunctionAlternativeForms

		def FindLastSubStringBoundedBySCSZZ(pcSubStr, pacBounds, pnStartingAt, pCaseSensitive)
			return This.FindNthSubStringBoundedBySCSZZ(nLast, pcSubStr, pacBounds, pnStartingAt, pCaseSensitive)

		#--
	
		def FindLastSubStringBetweenAsSectionsSCS(pcSubStr, pcBound1, pcBound2, pnStartingAt, pCaseSensitive)
			return This.FindLastSubStringBetweenSCSZZ(pcSubStr, pcBound1, pcBound2, pnStartingAt, pCaseSensitive)

		def FindLastSubStringBoundedByAsSectionsSCS(pcSubStr, pacBounds, pnStartingAt, pCaseSensitive)
			return This.FindLastSubStringBoundedBySCSZZ(pcSubStr, pacBounds, pnStartingAt, pCaseSensitive)

		#==

		def LastSubStringBetweenAsSectionsSCS(pcSubStr, pcBound1, pcBound2, pnStartingAt, pCaseSensitive)
			return This.FindLastSubStringBetweenSCSZZ(pcSubStr, pcBound1, pcBound2, pnStartingAt, pCaseSensitive)

		def LastSubStringBoundedByAsSectionsSCS(pcSubStr, pacBounds, pnStartingAt, pCaseSensitive)
			return This.FindLastSubStringBoundedBySCSZZ(pcSubStr, pacBounds, pnStartingAt, pCaseSensitive)

		#>

	#--

	def FindLastSubStringBetweenSZZ(pcSubStr, pcBound1, pcBound2, pnStartingAt)
		return This.FindLastSubStringBetweenSCSZZ(pcSubStr, pcBound1, pcBound2, pnStartingAt, TRUE)

		#< @FunctionAlternativeForms

		def FindLastSubStringBoundedBySZZ(pcSubStr, pacBounds, pnStartingAt)
			return This.FindLastSubStringBoundedBySZZ(pcSubStr, pacBounds, pnStartingAt)

		#--
	
		def FindLastSubStringBetweenAsSectionsS(pcSubStr, pcBound1, pcBound2, pnStartingAt)
			return This.FindLastSubStringBetweenSZZ(pcSubStr, pcBound1, pcBound2, pnStartingAt)

		def FindLastSubStringBoundedByAsSectionsS(pcSubStr, pacBounds, pnStartingAt)
			return This.FindLastSubStringBoundedBySZZ(pcSubStr, pacBounds, pnStartingAt)

		#==

		def LastSubStringBetweenAsSectionsS(pcSubStr, pcBound1, pcBound2, pnStartingAt)
			return This.FindLastSubStringBetweenSZZ(pcSubStr, pcBound1, pcBound2, pnStartingAt)

		def LastSubStringBoundedByAsSectionsS(pcSubStr, pacBounds, pnStartingAt)
			return This.FindLastSubStringBoundedBySZZ(pcSubStr, pacBounds, pnStartingAt)

		#>

	   #-----------------------------------------------------------------------#
	  #  GETTING THE SUBSTRING AND ITS LAST OCCURRENCE (AS SECTION) BETWEEN  #
	 #  TWO GIVEN SUBSTRINGS STARTING AT A GIVEN POSITION                    #
	#-----------------------------------------------------------------------#

	def LastSubStringBetweenSCSZZ(pcSubStr, pcBound1, pcBound2, pnStartingAt, pCaseSensitive)
		nLast = This.NumberOfOccurrenceBetweenSCS(pcSubStr, pcBound1, pcBound2, pnStartingAt, pCaseSensitive)
		return This.NthSubStringBetweenSCSZZ(nLast, pcSubStr, pcBound1, pcBound2, pnStartingAt, pCaseSensitive)

		#< @FunctionAlternativeForms

		def LastSubStringBoundedBySCSZZ(pcSubStr, pacBounds, pnStartingAt, pCaseSensitive)
			return This.NthSubStringBoundedBySCSZZ(nLast, pcSubStr, pacBounds, pnStartingAt, pCaseSensitive)

		#--

		def LastSubStringBetweenAsSection_SCS(pcSubStr, pcBound1, pcBound2, pnStartingAt, pCaseSensitive)
			return This.LastSubStringBetweenSCSZZ(pcSubStr, pcBound1, pcBound2, pnStartingAt, pCaseSensitive)

		def LastSubStringBoundedByAsSection_SCS(pcSubStr, pacBounds, pnStartingAt, pCaseSensitive)
			return This.LastSubStringBoundedBySCSZZ(pcSubStr, pacBounds, pnStartingAt, pCaseSensitive)

		#>

	#-- WITHOUT CASESENSITIVITY

	def LastSubStringBetweenSZZ(pcSubStr, pcBound1, pcBound2, pnStartingAt)
		return This.LastSubStringBetweenSCSZZ(pcSubStr, pcBound1, pcBound2, pnStartingAt, TRUE)

		#< @FunctionAlternativeForms

		def LastSubStringBoundedBySZZ(pcSubStr, pacBounds, pnStartingAt)
			return This.NthSubStringBoundedBySZZ(nLast, pcSubStr, pacBounds, pnStartingAt)

		#--

		def LastSubStringBetweenAsSection_S(pcSubStr, pcBound1, pcBound2, pnStartingAt)
			return This.LastSubStringBetweenSZZ(pcSubStr, pcBound1, pcBound2, pnStartingAt)

		def LastSubStringBoundedByAsSection_S(pcSubStr, pacBounds, pnStartingAt)
			return This.LastSubStringBoundedBySZZ(pcSubStr, pacBounds, pnStartingAt)

		#>
	
	   #----------------------------------------------------------------#
	  #  FINDING LAST OCCURRENCE OF A SUBSTRING BOUNDED BY TWO OTHER  #
	 #  SUBSTRINGSSTARTING AT A GIVEN POSITION AND INCLUDING BOUNDS   #
	#================================================================#

	def FindLastSubStringBetweenSCSIB(pcSubStr, pcBound1, pcBound2, pnStartingAt, pCaseSensitive)
		nLast = This.NumberOfOccurrenceBetweenSCS(pcSubStr, pcBound1, pcBound2, pnStartingAt, pCaseSensitive)
		return This.FindNthSubStringBetweenSCSIB(nLast, pcSubStr, pcBound1, pcBound2, pnStartingAt, pCaseSensitive)

		#< @FunctionAlternativeForms

		def FindLastSubStringBoundedBySCSIB(pcSubStr, pacBounds, pnStartingAt, pCaseSensitive)
			return This.NthLastSubStringBoundedBySCSIB(nLast, pcSubStr, pacBounds, pnStartingAt, pCaseSensitive)

		#--
	
		def FindLastSubStringBetweenSCSIBZ(pcSubStr, pcBound1, pcBound2, pnStartingAt, pCaseSensitive)
			return This.FindLastSubStringBetweenSCSIB(pcSubStr, pcBound1, pcBound2, pnStartingAt, pCaseSensitive)

		def FindLastSubStringBoundedBySCSIBZ(pcSubStr, pacBounds, pnStartingAt, pCaseSensitive)
			return This.FindLastSubStringBoundedBySCSIB(pcSubStr, pacBounds, pnStartingAt, pCaseSensitive)

		#==

		def LastSubStringBetweenSCSIB(pcSubStr, pcBound1, pcBound2, pnStartingAt, pCaseSensitive)
			return This.FindLastSubStringBetweenSCSIB(pcSubStr, pcBound1, pcBound2, pnStartingAt, pCaseSensitive)

		def LastSubStringBoundedBySCSIB(pcSubStr, pacBounds, pnStartingAt, pCaseSensitive)
			return This.FindLastSubStringBoundedBySCSIB(pcSubStr, pacBounds, pnStartingAt, pCaseSensitive)

		#>

	#-- WITHOUT CASESENSITIVITY

	def FindLastSubStringBetweenSIB(pcSubStr, pcBound1, pcBound2, pnStartingAt)
		return This.FindLastSubStringBetweenSCSIB(pcSubStr, pcBound1, pcBound2, pnStartingAt, TRUE)

		#< @FunctionAlternativeForms

		def FindLastSubStringBoundedBySIB(pcSubStr, pacBounds, pnStartingAt)
			return This.FindLastSubStringBoundedBySIB(pcSubStr, pacBounds, pnStartingAt)

		#--
	
		def FindLastSubStringBetweenSIBZ(pcSubStr, pcBound1, pcBound2, pnStartingAt)
			return This.FindLastSubStringBetweenSIB(pcSubStr, pcBound1, pcBound2, pnStartingAt)

		def FindLastSubStringBoundedBySIBZ(pcSubStr, pacBounds, pnStartingAt)
			return This.FindLastSubStringBoundedBySIB(pcSubStr, pacBounds, pnStartingAt)

		#==

		def LastSubStringBetweenSIB(pcSubStr, pcBound1, pcBound2, pnStartingAt)
			return This.FindLastSubStringBetweenSIB(pcSubStr, pcBound1, pcBound2, pnStartingAt)

		def LastSubStringBoundedBySIB(pcSubStr, pacBounds, pnStartingAt)
			return This.FindBoundedBySIB(pcSubStr, pacBounds, pnStartingAt)

		#>

	   #-------------------------------------------------------------------------------#
	  #  GETTING THE SUBSTRING AND ITS LAST OCCURRENCE BETWEEN TWO GIVEN SUBSTRINGS  #
	 #  STARTING AT A GIVEN POSITION AND INCLUDING BOUNDS                            #
	#-------------------------------------------------------------------------------#

	def LastSubStringBetweenSCSIBZ(pcSubStr, pcBound1, pcBound2, pnStartingAt, pCaseSensitive)
		nLast = This.NumberOfOccurrenceBetweenSCS(pcSubStr, pcBound1, pcBound2, pnStartingAt, pCaseSensitive)
		return This.NthSubStringBetweenSCSIBZ(nLast, pcSubStr, pcBound1, pcBound2, pnStartingAt, pCaseSensitive)

		def LastSubStringBoundedBySCSIBZ(pcSubStr, pacBounds, pnStartingAt, pCaseSensitive)
			return This.NthSubStringBoundedBySCSIBZ(nLast, pcSubStr, pacBounds, pnStartingAt, pCaseSensitive)

	#-- WITHOUT CASESENSITIVITY

	def LastSubStringBetweenSIBZ(pcSubStr, pcBound1, pcBound2, pnStartingAt)
		return This.LastSubStringBetweenSCSIBZ(pcSubStr, pcBound1, pcBound2, pnStartingAt, TRUE)

		def LastSubStringBoundedBySIBZ(pcSubStr, pacBounds, pnStartingAt)
			return This.LastSubStringBoundedBySCSIBZ(pcSubStr, pacBounds, pnStartingAt, TRUE)

	   #-------------------------------------------------------------------------------------#
	  #  FINDING LAST OCCURRENCE OF A SUBSTRING BOUNDED BY TWO OTHER SUBSTRINGS STARTING   #
	 #  AT A GIVEN POSITION, INCLUDING BOUNDS, AND RETURNING THE POSITIONS AS SECTIONS     #
	#=====================================================================================#

	def FindLastSubStringBetweenSCSIBZZ(pcSubStr, pcBound1, pcBound2, pnStartingAt, pCaseSensitive)
		nLast = This.NumberOfOccurrenceBetweenSCS(pcSubStr, pcBound1, pcBound2, pnStartingAt, pCaseSensitive)
		return This.FindNthSubStringBetweenSCSIBZZ(nLast, pcSubStr, pcBound1, pcBound2, pnStartingAt, pCaseSensitive)

		#< @FunctionAlternativeForms

		def FindLastSubStringBoundedBySCSIBZZ(pcSubStr, pacBounds, pnStartingAt, pCaseSensitive)
			return This.FindNthSubStringBoundedBySCSIBZZ(nLast, pcSubStr, pacBounds, pnStartingAt, pCaseSensitive)

		#--
	
		def FindLastSubStringBetweenAsSectionsSCSIB(pcSubStr, pcBound1, pcBound2, pnStartingAt, pCaseSensitive)
			return This.FindLastSubStringBetweenSCSIBZZ(pcSubStr, pcBound1, pcBound2, pnStartingAt, pCaseSensitive)

		def FindLastSubStringBoundedByAsSectionsSCSIB(pcSubStr, pacBounds, pnStartingAt, pCaseSensitive)
			return This.FindLastSubStringBoundedBySCSIBZZ(pcSubStr, pacBounds, pnStartingAt, pCaseSensitive)

		#==

		def LastSubStringBetweenAsSectionsSCSIB(pcSubStr, pcBound1, pcBound2, pnStartingAt, pCaseSensitive)
			return This.FindLastSubStringBetweenSIBCSZZ(pcSubStr, pcBound1, pcBound2, pnStartingAt, pCaseSensitive)

		def LastSubStringBoundedByAsSectionsSCSIB(pcSubStr, pacBounds, pnStartingAt, pCaseSensitive)
			return This.FindLastSubStringBoundedBySCSIBZZ(pcSubStr, pacBounds, pnStartingAt, pCaseSensitive)

		#>

	#-- WITHOUT CASESENSITIVITY

	def FindLastSubStringBetweenSIBZZ(pcSubStr, pcBound1, pcBound2, pnStartingAt)
		return This.FindLastSubStringBetweenSIBCSZZ(pcSubStr, pcBound1, pcBound2, pnStartingAt, TRUE)

		#< @FunctionAlternativeForms

		def FindLastSubStringBoundedBySIBZZ(pcSubStr, pacBounds, pnStartingAt)
			return This.FindLastSubStringBoundedBySIBZZ(pcSubStr, pacBounds, pnStartingAt)

		#--
	
		def FindLastSubStringBetweenAsSectionsSIB(pcSubStr, pcBound1, pcBound2, pnStartingAt)
			return This.FindLastSubStringBetweenSIBZZ(pcSubStr, pcBound1, pcBound2, pnStartingAt)

		def FindLastSubStringBoundedByAsSectionsSIB(pcSubStr, pacBounds, pnStartingAt)
			return This.FindLastSubStringBoundedBySIBZZ(pcSubStr, pacBounds, pnStartingAt)

		#==

		def LastSubStringBetweenAsSectionsSIB(pcSubStr, pcBound1, pcBound2, pnStartingAt)
			return This.FindLastSubStringBetweenSIBZZ(pcSubStr, pcBound1, pcBound2, pnStartingAt)

		def LastSubStringBoundedByAsSectionsSIB(pcSubStr, pacBounds, pnStartingAt)
			return This.FindLastSubStringBoundedBySIBZZ(pcSubStr, pacBounds, pnStartingAt)

		#>

	   #-----------------------------------------------------------------------#
	  #  GETTING THE SUBSTRING AND ITS LAST OCCURRENCE (AS SECTION) BETWEEN  #
	 #  TWO GIVEN SUBSTRINGS STARTING AT A GIVEN POSITION                    #
	#-----------------------------------------------------------------------#

	def LastSubStringBetweenSCSIBZZ(pcSubStr, pcBound1, pcBound2, pnStartingAt, pCaseSensitive)
		nLast = This.NumberOfOccurrenceBetweenSCS(pcSubStr, pcBound1, pcBound2, pnStartingAt, pCaseSensitive)
		return This.NthSubStringBetweenSCSIBZZ(nLast, pcSubStr, pcBound1, pcBound2, pnStartingAt, pCaseSensitive)

		#< @FunctionAlternativeForms

		def LastSubStringBoundedBySCSIBZZ(pcSubStr, pacBounds, pnStartingAt, pCaseSensitive)
			return This.NthSubStringBoundedBySCSIBZZ(nLast, pcSubStr, pacBounds, pnStartingAt, pCaseSensitive)

		#--

		def LastSubStringBetweenAsSection_SCSIB(pcSubStr, pcBound1, pcBound2, pnStartingAt, pCaseSensitive)
			return This.LastSubStringBetweenSCSIBZZ(pcSubStr, pcBound1, pcBound2, pnStartingAt, pCaseSensitive)

		def LastSubStringBoundedBy_SCSIB(pcSubStr, pacBounds, pnStartingAt, pCaseSensitive)
			return This.LastSubStringBoundedBySCSIBZZ(pcSubStr, pacBounds, pnStartingAt, pCaseSensitive)

		#>

	#-- WITHOUT CASESENSITIVITY

	def LastSubStringBetweenSIBZZ(pcSubStr, pcBound1, pcBound2, pnStartingAt)
		return This.LastSubStringBetweenSCSIBZZ(pcSubStr, pcBound1, pcBound2, pnStartingAt, TRUE)

		#< @FunctionAlternativeForms

		def LastSubStringBoundedBySIBZZ(pcSubStr, pacBounds, pnStartingAt)
			return This.LastSubStringBoundedBySCSIBZZ(pcSubStr, pacBounds, pnStartingAt, TRUE)

		#--

		def LastSubStringBetweenAsSection_SIB(pcSubStr, pcBound1, pcBound2, pnStartingAt, pCaseSensitive)
			return This.LastSubStringBetweenSIBZZ(pcSubStr, pcBound1, pcBound2, pnStartingAt, pCaseSensitive)

		def LastSubStringBoundedBy_SIB(pcSubStr, pacBounds, pnStartingAt, pCaseSensitive)
			return This.LastSubStringBoundedBySIBZZ(pcSubStr, pacBounds, pnStartingAt, pCaseSensitive)

		#>

	   #------------------------------------------------------#
	  #  FINDING LAST OCCURRENCE OF A SUBSTRING BOUNDED BY  #
	 #  TWO OTHER SUBSTRINGS GOING IN A GIVEN DIRECTION     #
	#======================================================#

	def FindLastSubStringBetweenDCS(pcSubStr, pcBound1, pcBound2, pcDirection, pCaseSensitive)
		nLast = This.NumberOfOccurrenceBetweenCS(pcSubStr, pcBound1, pcBound2, pCaseSensitive)
		return This.FindNthSubStringBetweenDCS(nLast, pcSubStr, pcBound1, pcBound2, pcDirection, pCaseSensitive)

		#< @FunctionAlternativeForms

		def FindLastSubStringBoundedByDCS(pcSubStr, pacBounds, pcDirection, pCaseSensitive)
			return This.FindNthSubStringBoundedByDCS(nLast, pcSubStr, pacBounds, pcDirection, pCaseSensitive)

		#--
	
		def FindLastSubStringBetweenDCSZ(pcSubStr, pcBound1, pcBound2, pcDirection, pCaseSensitive)
			return This.FindLastSubStringBetweenDCS(pcSubStr, pcBound1, pcBound2, pcDirection, pCaseSensitive)

		def FindLastSubStringBoundedByDCSZ(pcSubStr, pacBounds, pcDirection, pCaseSensitive)
			return This.FindLastSubStringBoundedByDCS(pcSubStr, pacBounds, pcDirection, pCaseSensitive)

		#==

		def LastSubStringBetweenDCS(pcSubStr, pcBound1, pcBound2, pcDirection, pCaseSensitive)
			return This.FindLastSubStringBetweenDCS(pcSubStr, pcBound1, pcBound2, pcDirection, pCaseSensitive)

		def LastSubStringBoundedByDCS(pcSubStr, pacBounds, pcDirection, pCaseSensitive)
			return This.FindLastSubStringBoundedByDCS(pcSubStr, pacBounds, pcDirection, pCaseSensitive)

		#>

	#-- WITHOUT CASESENSITIVITY

	def FindLastSubStringBetweenD(pcSubStr, pcBound1, pcBound2, pcDirection)
		return This.FindLastSubStringBetweenDCS(pcSubStr, pcBound1, pcBound2, pcDirection, TRUE)

		#< @FunctionAlternativeForms

		def FindLastSubStringBoundedByD(pcSubStr, pacBounds, pcDirection)
			return This.FindLastSubStringBoundedByD(pcSubStr, pacBounds, pcDirection)

		#--
	
		def FindLastSubStringBetweenDZ(pcSubStr, pcBound1, pcBound2, pcDirection)
			return This.FindLastSubStringBetweenD(pcSubStr, pcBound1, pcBound2, pcDirection)

		def FindLastSubStringBoundedByDZ(pcSubStr, pacBounds, pcDirection)
			return This.FindLastSubStringBoundedByD(pcSubStr, pacBounds, pcDirection)

		#==

		def LastSubStringBetweenD(pcSubStr, pcBound1, pcBound2, pcDirection)
			return This.FindLastSubStringBetweenD(pcSubStr, pcBound1, pcBound2, pcDirection)

		def LastSubStringBoundedByD(pcSubStr, pacBounds, pcDirection)
			return This.FindLastSubStringBoundedByD(pcSubStr, pacBounds, pcDirection)

		#>

	   #-------------------------------------------------------------------------------#
	  #  GETTING THE SUBSTRING AND ITS LAST OCCURRENCE BETWEEN TWO GIVEN SUBSTRINGS  #
	 #  GOING IN A GIVEN DIRECTION (FORWARD OR BACKWARD)                             #
	#-------------------------------------------------------------------------------#

	def LastSubStringBetweenDCSZ(pcSubStr, pcBound1, pcBound2, pcDirection, pCaseSensitive)
		nLast = This.NumberOfOccurrenceBetweenCS(pcSubStr, pcBound1, pcBound2, pCaseSensitive)
		return This.NthSubStringBetweenDCSZ(nLast, pcSubStr, pcBound1, pcBound2, pcDirection, pCaseSensitive)

		def LastSubStringBoundedByDCSZ(pcSubStr, pacBounds, pcDirection, pCaseSensitive)
			return This.NthSubStringBoundedByDCSZ(nLast, pcSubStr, pacBounds, pcDirection, pCaseSensitive)

	#-- WITHOUT CASESENSITIVITY

	def LastSubStringBetweenDZ(pcSubStr, pcBound1, pcBound2, pcDirection)
		return This.LastSubStringBetweenDCSZ(pcSubStr, pcBound1, pcBound2, pcDirection, TRUE)

		def LastSubStringBoundedByDZ(pcSubStr, pacBounds, pcDirection)
			return This.LastSubStringBoundedByDCSZ(pcSubStr, pacBounds, pcDirection, TRUE)

	   #---------------------------------------------------------------------------#
	  #  FINDING LAST OCCURRENCE OF A SUBSTRING BOUNDED BY TWO OTHER SUBSTRINGS  #
	 #  GOING INA GIVEN DIRECTION AND RETURNING POSITIONS AS SECTIONS            #
	#===========================================================================#

	def FindLastSubStringBetweenDCSZZ(pcSubStr, pcBound1, pcBound2, pcDirection, pCaseSensitive)
		nLast = This.NumberOfOccurrenceBetweenCS(pcSubStr, pcBound1, pcBound2, pCaseSensitive)
		return This.FindNthSubStringBetweenDCSZZ(nLast, pcSubStr, pcBound1, pcBound2, pcDirection, pCaseSensitive)

		#< @FunctionAlternativeForms

		def FindLastSubStringBoundedByDCSZZ(pcSubStr, pacBounds, pcDirection, pCaseSensitive)
			return This.FindNthSubStringBoundedByDCSZZ(nLast, pcSubStr, pacBounds, pcDirection, pCaseSensitive)

		#--
	
		def FindLastSubStringBetweenAsSectionsDCS(pcSubStr, pcBound1, pcBound2, pcDirection, pCaseSensitive)
			return This.FindLastSubStringBetweenDCSZZ(pcSubStr, pcBound1, pcBound2, pcDirection, pCaseSensitive)

		def FindLastSubStringBoundedByAsSectionsDCS(pcSubStr, pacBounds, pcDirection, pCaseSensitive)
			return This.FindLastSubStringBoundedByDCSZZ(pcSubStr, pacBounds, pcDirection, pCaseSensitive)

		#==

		def LastSubStringBetweenAsSectionsDCS(pcSubStr, pcBound1, pcBound2, pcDirection, pCaseSensitive)
			return This.FindLastSubStringBetweenDCSZZ(pcSubStr, pcBound1, pcBound2, pcDirection, pCaseSensitive)

		def LastSubStringBoundedByAsSectionsDCS(pcSubStr, pacBounds, pcDirection, pCaseSensitive)
			return This.FindLastSubStringBoundedByDCSZZ(pcSubStr, pacBounds, pcDirection, pCaseSensitive)

		#>

	#-- WITHOUT CASESENSITIVITY

	def FindLastSubStringBetweenDZZ(pcSubStr, pcBound1, pcBound2, pcDirection)
		return This.FindLastSubStringBetweenDZZ(pcSubStr, pcBound1, pcBound2, pcDirection)

		#< @FunctionAlternativeForms

		def FindLastSubStringBoundedByDZZ(pcSubStr, pacBounds, pcDirection)
			return This.FindLastSubStringBoundedByDZZ(pcSubStr, pacBounds, pcDirection)

		#--
	
		def FindLastSubStringBetweenAsSectionsD(pcSubStr, pcBound1, pcBound2, pcDirection)
			return This.FindLastSubStringBetweenDZZ(pcSubStr, pcBound1, pcBound2, pcDirection)

		def FindLastSubStringBoundedByAsSectionsD(pcSubStr, pacBounds, pcDirection)
			return This.FindLastSubStringBoundedByDZZ(pcSubStr, pacBounds, pcDirection)

		#==

		def LastSubStringBetweenAsSectionsD(pcSubStr, pcBound1, pcBound2, pcDirection)
			return This.FindLastSubStringBetweenDZZ(pcSubStr, pcBound1, pcBound2, pcDirection)

		def LastSubStringBoundedByAsSectionsD(pcSubStr, pacBounds, pcDirection)
			return This.FindLastSubStringBoundedByDZZ(pcSubStr, pacBounds, pcDirection)

		#>

	   #---------------------------------------------------------------------------#
	  #  GETTING THE SUBSTRING AND ITS LAST OCCURRENCE (AS SECTION) BETWEEN TWO  #
	 #  GIVEN SUBSTRINGS GOING IN A GIVEN DIRECTION (FORWARD OR BACKWARD)        #
	#---------------------------------------------------------------------------#

	def LastSubStringBetweenDCSZZ(pcSubStr, pcBound1, pcBound2, pcDirection, pCaseSensitive)
		nLast = This.NumberOfOccurrenceBetweenCS(pcSubStr, pcBound1, pcBound2, pCaseSensitive)
		return This.NthSubStringBetweenDCSZZ(nLast, pcSubStr, pcBound1, pcBound2, pcDirection, pCaseSensitive)

		#< @FunctionAlternativeForms

		def LastSubStringBoundedByDCSZZ(pcSubStr, pacBounds, pcDirection, pCaseSensitive)
			return This.NthSubStringBoundedByDCSZZ(nLast, pcSubStr, pacBounds, pcDirection, pCaseSensitive)

		#--

		def LastSubStringBetweenAsSectionDCS(pcSubStr, pcBound1, pcBound2, pcDirection, pCaseSensitive)
			return This.LastSubStringBetweenDCSZZ(pcSubStr, pcBound1, pcBound2, pcDirection, pCaseSensitive)

		def LastSubStringBoundedByAsSectionDCS(pcSubStr, pacBounds, pcDirection, pCaseSensitive)
			return This.LastSubStringBoundedByDCSZZ(pcSubStr, pacBounds, pcDirection, pCaseSensitive)

		#>

	#-- WITHOUT CASESENSITIVITY

	def LastSubStringBetweenDZZ(pcSubStr, pcBound1, pcBound2, pcDirection)
		return This.LastSubStringBetweenDCSZZ(pcSubStr, pcBound1, pcBound2, pcDirection, TRUE)

		#< @FunctionAlternativeForms

		def LastSubStringBoundedByDZZ(pcSubStr, pacBounds, pcDirection)
			return This.NthSubStringBoundedByDZZ(nLast, pcSubStr, pacBounds, pcDirection)

		#--

		def LastSubStringBetweenAsSectionD(pcSubStr, pcBound1, pcBound2, pcDirection)
			return This.LastSubStringBetweenDZZ(pcSubStr, pcBound1, pcBound2, pcDirection)

		def LastSubStringBoundedByAsSectionD(pcSubStr, pacBounds, pcDirection)
			return This.LastSubStringBoundedByDZZ(pcSubStr, pacBounds, pcDirection)

		#>

	   #----------------------------------------------------------------#
	  #  FINDING LAST OCCURRENCE OF A SUBSTRING BOUNDED BY TWO OTHER  #
	 #  SUBSTRINGS GOING IN A GIVEN DIRECTION AND INCLUDING BOUNDS    #
	#================================================================#

	def FindLastSubStringBetweenDCSIB(pcSubStr, pcBound1, pcBound2, pcDirection, pCaseSensitive)
		nLast = This.NumberOfOccurrenceBetweenCS(pcSubStr, pcBound1, pcBound2, pCaseSensitive)
		return This.FindNthSubStringBetweenDCSIB(nLast, pcSubStr, pcBound1, pcBound2, pcDirection, pCaseSensitive)

		#< @FunctionAlternativeForms

		def FindLastSubStringBoundedByDCSIB(pcSubStr, pacBounds, pcDirection, pCaseSensitive)
			return This.FindNthSubStringBoundedByDCSIB(nLast, pcSubStr, pacBounds, pcDirection, pCaseSensitive)

		#--
	
		def FindLastSubStringBetweenDCSIBZ(pcSubStr, pcBound1, pcBound2, pcDirection, pCaseSensitive)
			return This.FindLastSubStringBetweenDCSIB(pcSubStr, pcBound1, pcBound2, pcDirection, pCaseSensitive)

		def FindLastSubStringBoundedByDCSIBZ(pcSubStr, pacBounds, pcDirection, pCaseSensitive)
			return This.FindLastSubStringBoundedByDCSIB(pcSubStr, pacBounds, pcDirection, pCaseSensitive)

		#==

		def LastSubStringBetweenDCSIB(pcSubStr, pcBound1, pcBound2, pcDirection, pCaseSensitive)
			return This.FindLastSubStringBetweenDCSIB(pcSubStr, pcBound1, pcBound2, pcDirection, pCaseSensitive)

		def LastSubStringBoundedByDCSIB(pcSubStr, pacBounds, pcDirection, pCaseSensitive)
			return This.FindLastSubStringBoundedByDCSIB(pcSubStr, pacBounds, pcDirection, pCaseSensitive)

		#>

	#-- WITHOUT CASESENSITIVITY

	def FindLastSubStringBetweenDIB(pcSubStr, pcBound1, pcBound2, pcDirection)
		return This.FindLastSubStringBetweenDCSIB(pcSubStr, pcBound1, pcBound2, pcDirection, TRUE)

		#< @FunctionAlternativeForms

		def FindLastSubStringBoundedByDIB(pcSubStr, pacBounds, pcDirection)
			return This.FindBoundedByDIB(pcSubStr, pacBounds, pcDirection)

		#--
	
		def FindLastSubStringBetweenDIBZ(pcSubStr, pcBound1, pcBound2, pcDirection)
			return This.FindLastSubStringBetweenDIB(pcSubStr, pcBound1, pcBound2, pcDirection)

		def FindLastSubStringBoundedByDIBZ(pcSubStr, pacBounds, pcDirection)
			return This.FindLastSubStringBoundedByDIB(pcSubStr, pacBounds, pcDirection)

		#==

		def LastSubStringBetweenDIB(pcSubStr, pcBound1, pcBound2, pcDirection)
			return This.FindLastSubStringBetweenDIB(pcSubStr, pcBound1, pcBound2, pcDirection)

		def LastSubStringBoundedByDIB(pcSubStr, pacBounds, pcDirection)
			return This.FindLastSubStringBoundedByDIB(pcSubStr, pacBounds, pcDirection)

		#>

	   #-------------------------------------------------------------------------------#
	  #  GETTING THE SUBSTRING AND ITS LAST OCCURRENCE BETWEEN TWO GIVEN SUBSTRINGS  #
	 #  GOING IN A GIVEN DIRECTION (FORWARD OR BACKWARD) AND INCLUDING BOUNDS        #
	#-------------------------------------------------------------------------------#

	def LastSubStringBetweenDCSIBZ(pcSubStr, pcBound1, pcBound2, pcDirection, pCaseSensitive)
		nLast = This.NumberOfOccurrenceBetweenCS(pcSubStr, pcBound1, pcBound2, pCaseSensitive)
		return This.NthSubStringBetweenDCSIBZ(nLast, pcSubStr, pcBound1, pcBound2, pcDirection, pCaseSensitive)

		def LastSubStringBoundedByDCSIBZ(pcSubStr, pacBounds, pcDirection, pCaseSensitive)
			return This.NthSubStringBoundedByDCSIBZ(nLast, pcSubStr, pacBounds, pcDirection, pCaseSensitive)

	#-- WITHOUT CASESENSITIVITY

	def LastSubStringBetweenDIBZ(pcSubStr, pcBound1, pcBound2, pcDirection)
		return This.LastSubStringBetweenDCSIBZ(pcSubStr, pcBound1, pcBound2, pcDirection, TRUE)

		def LastSubStringBoundedByDIBZ(pcSubStr, pacBounds, pcDirection)
			return This.LastSubStringBoundedByDCSIBZ(pcSubStr, pacBounds, pcDirection, TRUE)

	   #---------------------------------------------------------------------------------#
	  #  FINDING LAST OCCURRENCE OF A SUBSTRING BOUNDED BY TWO OTHER SUBSTRINGS GOING  #
	 #  IN A GIVENDIRECTION, INCLUDING BOUNDS, AND RETURNING POSITIONS AS SECTIONS     # 
	#=================================================================================#

	def FindLastSubStringBetweenDCSIBZZ(pcSubStr, pcBound1, pcBound2, pcDirection, pCaseSensitive)
		nLast = This.NumberOfOccurrenceBetweenCS(pcSubStr, pcBound1, pcBound2, pCaseSensitive)
		return This.FindNthSubStringBetweenDCSIBZZ(nLast, pcSubStr, pcBound1, pcBound2, pcDirection, pCaseSensitive)

		#< @FunctionAlternativeForms

		def FindLastSubStringBoundedByDCSIBZZ(pcSubStr, pacBounds, pcDirection, pCaseSensitive)
			return This.FindNthSubStringBoundedByDCSIBZZ(nLast, pcSubStr, pacBounds, pcDirection, pCaseSensitive)

		#--
	
		def FindLastSubStringBetweenAsSectionsDCSIB(pcSubStr, pcBound1, pcBound2, pcDirection, pCaseSensitive)
			return This.FindLastSubStringBetweenDCSIBZZ(pcSubStr, pcBound1, pcBound2, pcDirection, pCaseSensitive)

		def FindLastSubStringBoundedByAsSectionsDCSIB(pcSubStr, pacBounds, pcDirection, pCaseSensitive)
			return This.FindBoundedByDCSIBZZ(pcSubStr, pacBounds, pcDirection, pCaseSensitive)

		#==

		def LastSubStringBetweenAsSectionsDCSIB(pcSubStr, pcBound1, pcBound2, pcDirection, pCaseSensitive)
			return This.FindLastSubStringBetweenDCIBSZZ(pcSubStr, pcBound1, pcBound2, pcDirection, pCaseSensitive)

		def LastSubStringBoundedByAsSectionsDCSIB(pcSubStr, pacBounds, pcDirection, pCaseSensitive)
			return This.FindLastSubStringBoundedByDCSIBZZ(pcSubStr, pacBounds, pcDirection, pCaseSensitive)

		#>

	#-- WITHOUT CASESENSITIVITY

	def FindLastSubStringBetweenDIBZZ(pcSubStr, pcBound1, pcBound2, pcDirection)
		return This.FindLastSubStringBetweenDIBZZ(pcSubStr, pcBound1, pcBound2, pcDirection)

		#< @FunctionAlternativeForms

		def FindLastSubStringBoundedByDIBZZ(pcSubStr, pacBounds, pcDirection)
			return This.FindLastSubStringBoundedByDIBZZ(pcSubStr, pacBounds, pcDirection)

		#--
	
		def FindLastSubStringBetweenAsSectionsDIB(pcSubStr, pcBound1, pcBound2, pcDirection)
			return This.FindLastSubStringBetweenDIBZZ(pcSubStr, pcBound1, pcBound2, pcDirection)

		def FindLastSubStringBoundedByAsSectionsDIB(pcSubStr, pacBounds, pcDirection)
			return This.FindLastSubStringBoundedByDIBZZ(pcSubStr, pacBounds, pcDirection)

		#==

		def LastSubStringBetweenAsSectionsDIB(pcSubStr, pcBound1, pcBound2, pcDirection)
			return This.FindLastSubStringBetweenDIBZZ(pcSubStr, pcBound1, pcBound2, pcDirection)

		def LastSubStringBoundedByAsSectionsDIB(pcSubStr, pacBounds, pcDirection)
			return This.FindLastSubStringBoundedByDIBZZ(pcSubStr, pacBounds, pcDirection)

		#>

	   #----------------------------------------------------------------------------------#
	  #  GETTING THE SUBSTRING ANDT ITS LAST OCCURRENCE (AS SECTION) BETWEEN TWO GIVEN  #
	 #  SUBSTRINGS GOININH IN A GIVEN DIRECTION AND INCLUDING BOUNDS                    #
	#----------------------------------------------------------------------------------#

	def LastSubStringBetweenDCSIBZZ(pcSubStr, pcBound1, pcBound2, pcDirection, pCaseSensitive)
		nLast = This.NumberOfOccurrenceBetweenCS(pcSubStr, pcBound1, pcBound2, pCaseSensitive)
		return This.NthSubStringBetweenDCSIBZZ(nLast, pcSubStr, pcBound1, pcBound2, pcDirection, pCaseSensitive)

		#< @FunctionAlternativeForms

		def LastSubStringBoundedByDCSIBZZ(pcSubStr, pacBounds, pcDirection, pCaseSensitive)
			return This.NthSubStringBoundedByDCSIBZZ(nLast, pcSubStr, pacBounds, pcDirection, pCaseSensitive)
	
		#--

		def LastSubStringBetweenAsSectionDCSIB(pcSubStr, pcBound1, pcBound2, pcDirection, pCaseSensitive)
			return This.LastSubStringBetweenDCSIBZZ(pcSubStr, pcBound1, pcBound2, pcDirection, pCaseSensitive)

		def LastSubStringBoundedByAsSectionDCSIB(pcSubStr, pacBounds, pcDirection, pCaseSensitive)
			return This.LastSubStringBoundedByDCSIBZZ(pcSubStr, pacBounds, pcDirection, pCaseSensitive)

		#>

	#-- WITHOUT CASESENSITIVITY

	def LastSubStringBetweenDIBZZ(pcSubStr, pcBound1, pcBound2, pcDirection)
		return This.LastSubStringBetweenDCSIBZZ(pcSubStr, pcBound1, pcBound2, pcDirection, TRUE)

		#< @FunctionAlternativeForms

		def LastSubStringBoundedByDIBZZ(pcSubStr, pacBounds, pcDirection)
			return This.NthSubStringBoundedByDIBZZ(nLast, pcSubStr, pacBounds, pcDirection)
	
		#--

		def LastSubStringBetweenAsSectionDIB(pcSubStr, pcBound1, pcBound2, pcDirection)
			return This.LastSubStringBetweenDIBZZ(pcSubStr, pcBound1, pcBound2, pcDirection)

		def LastSubStringBoundedByAsSectionDIB(pcSubStr, pacBounds, pcDirection)
			return This.LastSubStringBoundedByDIBZZ(pcSubStr, pacBounds, pcDirection)

		#>

	   #---------------------------------------------------------------------------#
	  #  FINDING LAST OCCURRENCE OF A SUBSTRING BOUNDED BY TWO OTHER SUBSTRINGS  #
	 #  STARTING AT A GIVEN POSITION AND GOING IN A GIVEN DIRECTION              #
	#===========================================================================#

	def FindLastSubStringBetweenSDCS(pcSubStr, pcBound1, pcBound2, pnStartingAt, pcDirection, pCaseSensitive)
		nLast = This.NumberOfOccurrenceBetweenSCS(pcSubStr, pcBound1, pcBound2, pnStartingAt, pCaseSensitive)
		return This.FindNthSubStringBetweenSDCS(nLast, pcSubStr, pcBound1, pcBound2, pnStartingAt, pcDirection, pCaseSensitive)

		#< @FunctionAlternativeForms

		def FindLastSubStringBoundedBySDCS(pcSubStr, pacBounds, pnStartingAt, pcDirection, pCaseSensitive)
			return This.FindNthSubStringBoundedBySDCS(nLast, pcSubStr, pacBounds, pnStartingAt, pcDirection, pCaseSensitive)


		#--
	
		def FindLastSubStringBetweenSDCSZ(pcSubStr, pcBound1, pcBound2, pnStartingAt, pcDirection, pCaseSensitive)
			return This.FindLastSubStringBetweenSDCS(pcSubStr, pcBound1, pcBound2, pnStartingAt, pcDirection, pCaseSensitive)

		def FindLastSubStringBoundedBySDCSZ(pcSubStr, pacBounds, pnStartingAt, pcDirection, pCaseSensitive)
			return This.FindLastSubStringBoundedBySDCS(pcSubStr, pacBounds, pnStartingAt, pcDirection, pCaseSensitive)

		#==

		def LastSubStringBetweenSDCS(pcSubStr, pcBound1, pcBound2, pnStartingAt, pcDirection, pCaseSensitive)
			return This.FindLastSubStringBetweenSD(pcSubStr, pcBound1, pcBound2, pnStartingAt, pcDirection)

		def LastSubStringBoundedBySDCS(pcSubStr, pacBounds, pnStartingAt, pcDirection, pCaseSensitive)
			return This.FindLastSubStringBoundedBySDCS(pcSubStr, pacBounds, pnStartingAt, pcDirection, pCaseSensitive)

		#>

	#-- WITHOUT CASESENSITIVITY

	def FindLastSubStringBetweenSD(pcSubStr, pcBound1, pcBound2, pnStartingAt, pcDirection)
		return This.FindLastSubStringBetweenSDCS(pcSubStr, pcBound1, pcBound2,pnStartingAt, pcDirection, TRUE)

		#< @FunctionAlternativeForms

		def FindLastSubStringBoundedBySD(pcSubStr, pacBounds, pnStartingAt, pcDirection)
			return This.FindLastSubStringBoundedBySD(pcSubStr, pacBounds, pnStartingAt, pcDirection)

		#--
	
		def FindLastSubStringBetweenSDZ(pcSubStr, pcBound1, pcBound2, pnStartingAt, pcDirection)
			return This.FindLastSubStringBetweenSD(pcSubStr, pcBound1, pcBound2, pnStartingAt, pcDirection)

		def FindLastSubStringBoundedBySDZ(pcSubStr, pacBounds, pnStartingAt, pcDirection)
			return This.FindLastSubStringBoundedBySD(pcSubStr, pacBounds, pnStartingAt, pcDirection)

		#==

		def LastSubStringBetweenSD(pcSubStr, pcBound1, pcBound2, pnStartingAt, pcDirection)
			return This.FindLastSubStringBetweenSD(pcSubStr, pcBound1, pcBound2, pnStartingAt, pcDirection)

		def LastSubStringBoundedBySD(pcSubStr, pacBounds, pnStartingAt, pcDirection)
			return This.FindLastSubStringBoundedBySD(pcSubStr, pacBounds, pnStartingAt, pcDirection)

		#>

	   #----------------------------------------------------------------------------#
	  #  GETTING THE SUBSTRING AND ITS LAST OCCURRENCE (AS SECTION) BETWEEN TWO   #
	 #  SUBSTRINGS STARTING AT A GIVEN POSITION AND GOINING IN A GIVEN DIRECTION  #
	#----------------------------------------------------------------------------#

	def LastSubStringBetweenSDCSZ(pcSubStr, pcBound1, pcBound2, pnStartingAt, pcDirection, pCaseSensitive)
		nLast = This.NumberOfOccurrenceBetweenSCS(pcSubStr, pcBound1, pcBound2, pnStartingAt, pCaseSensitive)
		return This.NthSubStringBetweenSDCSZ(nLast, pcSubStr, pcBound1, pcBound2, pnStartingAt, pcDirection, pCaseSensitive)

		#< @FunctionAlternativeForms

		def LastSubStringBoundedBySDCSZ(pcSubStr, pacBounds, pnStartingAt, pcDirection, pCaseSensitive)
			return This.NthSubStringBoundedBySDCSZ(nLast, pcSubStr, pacBounds, pnStartingAt, pcDirection, pCaseSensitive)

		#>

	#-- WITHOUT CASESENSITIVITY

	def LastSubStringBetweenSDZ(pcSubStr, pcBound1, pcBound2, pnStartingAt, pcDirection)
		return This.LastSubStringBetweenSDCSZ(pcSubStr, pcBound1, pcBound2, pnStartingAt, pcDirection, TRUE)

		#< @FunctionAlternativeForms

		def LastSubStringBoundedBySDZ(pcSubStr, pacBounds, pnStartingAt, pcDirection)
			return This.NthSubStringBoundedBySDCSZ(nLast, pcSubStr, pacBounds, pnStartingAt, pcDirection, pCaseSensitive)

		#>


	   #----------------------------------------------------------------------------------------#
	  #  FINDING LAST OCCURRENCE OF A SUBSTRING BOUNDED BY TWO OTHER SUBSTRINGSS STARTING     #
	 #  AT A GIVEN POSITION, GOING IN A GIVEN DIRECTION, AND RETURNING POSITIONS AS SECTIONS  #
	#========================================================================================#

	def FindLastSubStringBetweenSDCSZZ(pcSubStr, pcBound1, pcBound2, pnStartingAt, pcDirection, pCaseSensitive)
		nLast = This.NumberOfOccurrenceBetweenSCS(pcSubStr, pcBound1, pcBound2, pnStartingAt, pCaseSensitive)
		return This.FindLastSubStringBetweenSDCSZZ(pcSubStr, pcBound1, pcBound2, pnStartingAt, pcDirection, pCaseSensitive)


		#< @FunctionAlternativeForms

		def FindLastSubStringBoundedBySDCSZZ(pcSubStr, pacBounds, pnStartingAt, pcDirection, pCaseSensitive)
			return This.FindBoundedBySDCSZZ(pcSubStr, pacBounds, pnStartingAt, pcDirection, pCaseSensitive)

		#--
	
		def FindLastSubStringBetweenAsSection_SDCS(pcSubStr, pcBound1, pcBound2, pnStartingAt, pcDirection, pCaseSensitive)
			return This.FindLastSubStringBetweenSDCSZZ(pcSubStr, pcBound1, pcBound2, pnStartingAt, pcDirection, pCaseSensitive)

		def FindLastSubStringBoundedByAsSection_SDCS(pcSubStr, pacBounds, pnStartingAt, pcDirection, pCaseSensitive)
			return This.FindLastSubStringBoundedBySDCSZZ(pcSubStr, pacBounds, pnStartingAt, pcDirection, pCaseSensitive)

		#>

	#-- WITHOUT CASESENSITIVITY

	def FindLastSubStringBetweenSDZZ(pcSubStr, pcBound1, pcBound2, pnStartingAt, pcDirection)
		return This.FindLastSubStringBetweenSDCSZZ(pcSubStr, pcBound1, pcBound2, pnStartingAt, pcDirection, TRUE)

		#< @FunctionAlternativeForms

		def FindLastSubStringBoundedBySDZZ(pcSubStr, pacBounds, pnStartingAt, pcDirection)
			return This.FindBoundedBySDZZ(pcSubStr, pacBounds, pnStartingAt, pcDirection)

		#--
	
		def FindLastSubStringBetweenAsSection_SD(pcSubStr, pcBound1, pcBound2, pnStartingAt, pcDirection)
			return This.FindLastSubStringBetweenSDZZ(pcSubStr, pcBound1, pcBound2, pnStartingAt, pcDirection)

		def FindLastSubStringBoundedByAsSection_SD(pcSubStr, pacBounds, pnStartingAt, pcDirection)
			return This.FindLastSubStringBoundedBySDZZ(pcSubStr, pacBounds, pnStartingAt, pcDirection)

		#>

	   #---------------------------------------------------------------------------------#
	  #  GETTING THE SUBSTRING AND ITS LAST OCCURRENCE (AS SECTION) BETWEEN TWO GIVEN  #
	 #  SUBSTRINGS STARTING AT A GIVEN POSITION AND GOINING IN A GIVEN DIRECTION       #
	#---------------------------------------------------------------------------------#

	def LastSubStringBetweenSDCSZZ(pcSubStr, pcBound1, pcBound2, pnStartingAt, pcDirection, pCaseSensitive)
		nLast = This.NumberOfOccurrenceBetweenSCS(pcSubStr, pcBound1, pcBound2, pnStartingAt, pCaseSensitive)
		return This.NthSubStringBetweenSDCSZZ(nLast, pcSubStr, pcBound1, pcBound2, pnStartingAt, pcDirection, pCaseSensitive)

		#< @FunctionAlternativeForms

		def LastSubStringBoundedBySDCSZZ(pcSubStr, pacBounds, pnStartingAt, pcDirection, pCaseSensitive)
			return This.NthSubStringBoundedBySDCSZZ(nLast, pcSubStr, pacBounds, pnStartingAt, pcDirection, pCaseSensitive)

		#--

		def LastSubStringBetweenAsSection_SDCS(pcSubStr, pcBound1, pcBound2, pnStartingAt, pcDirection, pCaseSensitive)
			return This.LastSubStringBetweenSDCSZZ(pcSubStr, pcBound1, pcBound2, pnStartingAt, pcDirection, pCaseSensitive)

		def LastSubStringBoundedByAsSection_SDCS(pcSubStr, pacBounds, pnStartingAt, pcDirection, pCaseSensitive)
			return This.LastSubStringBoundedBySDCSZZ(pcSubStr, pacBounds, pnStartingAt, pcDirection, pCaseSensitive)

		#>

	#-- WITHOUT CASESENSITIVITY

	def LastSubStringBetweenSDZZ(pcSubStr, pcBound1, pcBound2, pnStartingAt, pcDirection)
		return This.LastSubStringBetweenSDCSZZ(pcSubStr, pcBound1, pcBound2, pnStartingAt, pcDirection, TRUE)

		#< @FunctionAlternativeForms

		def LastSubStringBoundedBySDZZ(pcSubStr, pacBounds, pnStartingAt, pcDirection)
			return This.NthSubStringBoundedBySDZZ(nLast, pcSubStr, pacBounds, pnStartingAt, pcDirection)

		#--

		def LastSubStringBetweenAsSection_SD(pcSubStr, pcBound1, pcBound2, pnStartingAt, pcDirection)
			return This.LastSubStringBetweenSDZZ(pcSubStr, pcBound1, pcBound2, pnStartingAt, pcDirection)

		def LastSubStringBoundedByAsSection_SD(pcSubStr, pacBounds, pnStartingAt, pcDirection)
			return This.LastSubStringBoundedBySDZZ(pcSubStr, pacBounds, pnStartingAt, pcDirection)

		#>

	   #-------------------------------------------------------------------------------------#
	  #  FINDING LAST OCCURRENCE OF A SUBSTRING BOUNDED BY TWO OTHER SUBSTRINGSS STARTING  #
	 #  AT A GIVEN POSITION, GOING IN A GIVEN DIRECTION, AND INCLUDING BOUNDS              #
	#=====================================================================================#

	def FindLastSubStringBetweenSDCSIB(pcSubStr, pcBound1, pcBound2, pnStartingAt, pcDirection, pCaseSensitive)
		nLast = This.NumberOfOccurrenceBetweenSCS(pcSubStr, pcBound1, pcBound2, pnStartingAt, pCaseSensitive)
		return This.FindNthSubStringBetweenSDCSIB(nLast, pcSubStr, pcBound1, pcBound2, pnStartingAt, pcDirection, pCaseSensitive)

		#< @FunctionAlternativeForms

		def FindLastSubStringBoundedBySDCSIB(pcSubStr, pacBounds, pnStartingAt, pcDirection, pCaseSensitive)
			return This.FindNthSubStringBoundedBySDCSIB(nLast, pcSubStr, pacBounds, pnStartingAt, pcDirection, pCaseSensitive)

		#--
	
		def FindLastSubStringBetweenSDCSIBZ(pcSubStr, pcBound1, pcBound2, pnStartingAt, pcDirection, pCaseSensitive)
			return This.FindLastSubStringBetweenSDCSIB(pcSubStr, pcBound1, pcBound2, pnStartingAt, pcDirection, pCaseSensitive)

		def FindLastSubStringBoundedBySDCSIBZ(pcSubStr, pacBounds, pnStartingAt, pcDirection, pCaseSensitive)
			return This.FindLastSubStringBoundedBySDCSIB(pcSubStr, pacBounds, pnStartingAt, pcDirection, pCaseSensitive)

		#==

		def LastSubStringBetweenSDCSIB(pcSubStr, pcBound1, pcBound2, pnStartingAt, pcDirection, pCaseSensitive)
			return This.FindLastSubStringBetweenSDIB(pcSubStr, pcBound1, pcBound2, pnStartingAt, pcDirection)

		def LastSubStringBoundedBySDCSIB(pcSubStr, pacBounds, pnStartingAt, pcDirection, pCaseSensitive)
			return This.FindBoundedBySDCSIB(pcSubStr, pacBounds, pnStartingAt, pcDirection, pCaseSensitive)

		#>

	#-- WITHOUT CASESENSITIVITY

	def FindLastSubStringBetweenSDIB(pcSubStr, pcBound1, pcBound2, pnStartingAt, pcDirection)
		return This.FindLastSubStringBetweenSDCSIB(pcSubStr, pcBound1, pcBound2,pnStartingAt, pcDirection, TRUE)

		#< @FunctionAlternativeForms

		def FindLastSubStringBoundedBySDIB(pcSubStr, pacBounds, pnStartingAt, pcDirection)
			return This.FindLastSubStringBoundedBySDIB(pcSubStr, pacBounds, pnStartingAt, pcDirection)

		#--
	
		def FindLastSubStringBetweenSDIBZ(pcSubStr, pcBound1, pcBound2, pnStartingAt, pcDirection)
			return This.FindLastSubStringBetweenSDIB(pcSubStr, pcBound1, pcBound2, pnStartingAt, pcDirection)

		def FindLastSubStringBoundedBySDIBZ(pcSubStr, pacBounds, pnStartingAt, pcDirection)
			return This.FindLastSubStringBoundedBySDIB(pcSubStr, pacBounds, pnStartingAt, pcDirection)

		#==

		def LastSubStringBetweenSDIB(pcSubStr, pcBound1, pcBound2, pnStartingAt, pcDirection)
			return This.FindLastSubStringBetweenSDIB(pcSubStr, pcBound1, pcBound2, pnStartingAt, pcDirection)

		def LastSubStringBoundedBySDIB(pcSubStr, pacBounds, pnStartingAt, pcDirection)
			return This.FindLastSubStringBoundedBySDIB(pcSubStr, pacBounds, pnStartingAt, pcDirection)

		#>

	   #-------------------------------------------------------------------------------------------#
	  #  GETTING THE SUBSTRING AND ITS LAST OCCURRENCE BETWEEN TWO GIVEN SUBSTRINGS STARTING AT  #
	 #  A GIVEN POSITION AND GOINING IN A GIVEN DIRECTION AND INCLUDING BOUNDS                   #
	#-------------------------------------------------------------------------------------------#

	def LastSubStringBetweenSDCSIBZ(pcSubStr, pcBound1, pcBound2, pnStartingAt, pcDirection, pCaseSensitive)
		nLast = This.NumberOfOccurrenceBetweenSCS(pcSubStr, pcBound1, pcBound2, pnStartingAt, pCaseSensitive)
		return This.NthSubStringBetweenSDCSIBZ(nLast, pcSubStr, pcBound1, pcBound2, pnStartingAt, pcDirection, pCaseSensitive)

		def LastSubStringBoundedBySDCSIBZ(pcSubStr, pacBounds, pnStartingAt, pcDirection, pCaseSensitive)
			return This.NthSubStringBoundedBySDCSIBZ(nLast, pcSubStr, pacBounds, pnStartingAt, pcDirection, pCaseSensitive)

	#-- WITHOUT CASESENSITIVITY

	def LastSubStringBetweenSDIBZ(pcSubStr, pcBound1, pcBound2, pnStartingAt, pcDirection)
		return This.LastSubStringBetweenSDCSIBZ(pcSubStr, pcBound1, pcBound2, pnStartingAt, pcDirection, TRUE)

		def LastSubStringBoundedBySDIBZ(pcSubStr, pacBounds, pnStartingAt, pcDirection)
			return This.LastSubStringBoundedBySDCSIBZ(pcSubStr, pacBounds, pnStartingAt, pcDirection, TRUE)

	   #------------------------------------------------------------------------------------------------#
	  #  FINDING LAST OCCURRENCE OF A SUBSTRING BOUNDED BY TWO OTHER SUBSTRINGSS STARTING AT A GIVEN  #
	 #  POSITION, GOING IN A GIVEN DIRECTION, INCLUDING BOUNDS, AND RETURNING POSITIONS AS SECTIONS   #
	#================================================================================================#

	def FindLastSubStringBetweenSDCSIBZZ(pcSubStr, pcBound1, pcBound2, pnStartingAt, pcDirection, pCaseSensitive)
		nLast = This.NumberOfOccurrenceBetweenSCS(pcSubStr, pcBound1, pcBound2, pnStartingAt, pCaseSensitive)
		return This.FindNthSubStringBetweenSDCSIBZZ(nLast, pcSubStr, pcBound1, pcBound2, pnStartingAt, pcDirection, pCaseSensitive)

		#< @FunctionAlternativeForms

		def FindLastSubStringBoundedBySDCSIBZZ(pcSubStr, pacBounds, pnStartingAt, pcDirection, pCaseSensitive)
			return This.FindLastSubStringBoundedBySDCSIBZZ(pcSubStr, pacBounds, pnStartingAt, pcDirection, pCaseSensitive)

		#--
	
		def FindLastSubStringBetweenAsSectionsSDCSIB(pcSubStr, pcBound1, pcBound2, pnStartingAt, pcDirection, pCaseSensitive)
			return This.FindLastSubStringBetweenSDCSIBZZ(pcSubStr, pcBound1, pcBound2, pnStartingAt, pcDirection, pCaseSensitive)

		def FindLastSubStringBoundedByAsSectionsSDCSIB(pcSubStr, pacBounds, pnStartingAt, pcDirection, pCaseSensitive)
			return This.FindLastSubStringBoundedBySDCSIBZZ(pcSubStr, pacBounds, pnStartingAt, pcDirection, pCaseSensitive)

		#==

		def LastSubStringBetweenAsSectionsSDCSIB(pcSubStr, pcBound1, pcBound2, pnStartingAt, pcDirection, pCaseSensitive)
			return This.FindLastSubStringBetweenSDCSIBZZ(pcSubStr, pcBound1, pcBound2, pnStartingAt, pcDirection, pCaseSensitive)

		def LastSubStringBoundedByAsSectionsSDCSIB(pcSubStr, pacBounds, pnStartingAt, pcDirection, pCaseSensitive)
			return This.FindLastSubStringBoundedBySDCSIBZZ(pcSubStr, pacBounds, pnStartingAt, pcDirection, pCaseSensitive)

		#>

	#-- WITHOUT CASESENSITIVITY

	def FindLastSubStringBetweenSDIBZZ(pcSubStr, pcBound1, pcBound2, pnStartingAt, pcDirection)
		nLast = This.NumberOfOccurrenceBetweenSCS(pcSubStr, pcBound1, pcBound2, pnStartingAt, pCaseSensitive)
		return This.FindLastSubStringBetweenSDCSIBZZ(pcSubStr, pcBound1, pcBound2, pnStartingAt, pcDirection, TRUE)

		#< @FunctionAlternativeForms

		def FindLastSubStringBoundedBySDIBZZ(pcSubStr, pacBounds, pnStartingAt, pcDirection)
			return This.FindLastSubStringBoundedBySDIBZZ(pcSubStr, pacBounds, pnStartingAt, pcDirection)

		#--
	
		def FindLastSubStringBetweenAsSectionsSDIB(pcSubStr, pcBound1, pcBound2, pnStartingAt, pcDirection)
			return This.FindLastSubStringBetweenSDIBZZ(pcSubStr, pcBound1, pcBound2, pnStartingAt, pcDirection)

		def FindLastSubStringBoundedByAsSectionsSDIB(pcSubStr, pacBounds, pnStartingAt, pcDirection)
			return This.FindLastSubStringBoundedBySDIBZZ(pcSubStr, pacBounds, pnStartingAt, pcDirection)

		#==

		def LastSubStringBetweenAsSectionsSDIB(pcSubStr, pcBound1, pcBound2, pnStartingAt, pcDirection)
			return This.FindLastSubStringBetweenSDIBZZ(pcSubStr, pcBound1, pcBound2, pnStartingAt, pcDirection)

		def LastSubStringBoundedByAsSectionsSDIB(pcSubStr, pacBounds, pnStartingAt, pcDirection)
			return This.FindLastSubStringBoundedBySDIBZZ(pcSubStr, pacBounds, pnStartingAt, pcDirection)

		#>

	    #--------------------------------------------------------------------------------#
	   #  GETTING THE SUBSTRING AND ITS LAST OCCURRENCE (AS SECTION) BETWEEN TWO GIVEN  #
	  #  SUBSTRINGS, STARTING AT A GIVEN POSITION, GOINING IN A GIVEN DIRECTION, AND   #
	 # INCLUDING BOUNDS IN THE RESULT                                                 #
	#--------------------------------------------------------------------------------#

	def LastSubStringBetweenSDCSIBZZ(pcSubStr, pcBound1, pcBound2, pnStartingAt, pcDirection, pCaseSensitive)
		nLast = This.NumberOfOccurrenceBetweenSCS(pcSubStr, pcBound1, pcBound2, pnStartingAt, pCaseSensitive)
		return This.NthSubStringBetweenSDCSIBZZ(nLast, pcSubStr, pcBound1, pcBound2, pnStartingAt, pcDirection, pCaseSensitive)

		#< @FunctionAlternativeForms

		def LastSubStringBoundedBySDCSIBZZ(pcSubStr, pacBounds, pnStartingAt, pcDirection, pCaseSensitive)
			return This.NthSubStringBoundedBySDCSIBZZ(nLast, pcSubStr, pacBounds, pnStartingAt, pcDirection, pCaseSensitive)

		#--

		def LastSubStringBetweenAsSection_SDCSIB(pcSubStr, pcBound1, pcBound2, pnStartingAt, pcDirection, pCaseSensitive)
			return This.LastSubStringBetweenSDCSIBZZ(pcSubStr, pcBound1, pcBound2, pnStartingAt, pcDirection, pCaseSensitive)

		def LastSubStringBoundedByAsSection_SDCSIB(pcSubStr, pacBounds, pnStartingAt, pcDirection, pCaseSensitive)
			return This.LastSubStringBoundedBySDCSIBZZ(pcSubStr, pacBounds, pnStartingAt, pcDirection, pCaseSensitive)

		#>

	#-- WITHOUT CASESENSITIVITY

	def LastSubStringBetweenSDIBZZ(pcSubStr, pcBound1, pcBound2, pnStartingAt, pcDirection)
		return This.LastSubStringBetweenSDCSIBZZ(pcSubStr, pcBound1, pcBound2, pnStartingAt, pcDirection, TRUE)

		#< @FunctionAlternativeForms

		def LastSubStringBoundedBySDIBZZ(pcSubStr, pacBounds, pnStartingAt, pcDirection)
			return This.NthSubStringBoundedBySDIBZZ(nLast, pcSubStr, pacBounds, pnStartingAt, pcDirection)

		#--

		def LastSubStringBetweenAsSection_SDIB(pcSubStr, pcBound1, pcBound2, pnStartingAt, pcDirection)
			return This.LastSubStringBetweenSDIBZZ(pcSubStr, pcBound1, pcBound2, pnStartingAt, pcDirection)

		def LastSubStringBoundedByAsSection_SDIB(pcSubStr, pacBounds, pnStartingAt, pcDirection)
			return This.LastSubStringBoundedBySDIBZZ(pcSubStr, pacBounds, pnStartingAt, pcDirection)

		#>
