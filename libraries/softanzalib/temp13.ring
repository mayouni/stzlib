
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
		return This.ContainsSubStringBoundedBySCS(pcSubStr, pacBounds, pnStartingAt, TRUE)

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
			return This.NumberOfOccurrenceBoundedByCS(pcSubStr, pacBounds, pCaseSensitive)

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

	def ContainsNOccurrencesOfSubStringboundedByCS(n, pcSubStr, pacBounds, pCaseSensitive)
		bResult = ( This.NumberOfOccurrenceboundedByCS(pcSubStr, pacBounds, pCaseSensitive) = n )
		return bResult

	#-- WITHOUT CASESENSITIVITY

	def ContainsNOccurrencesOfSubStringboundedBy(n, pcSubstr, pacBounds)
		return This.ContainsNOccurrencesOfSubStringboundedByCS(n, pcSubStr, pacBounds, TRUE)

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

		n1 = This.FindFirstCS(pcSubStr1, pCaseSensitive)
		n2 = This.FindLastCS(pcSubStr2, pCaseSensitive)

		anResult = This.FindInSectionCS(pcSubStr, n1, n2, pCaseSensitive)
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
		return This.FindSubStringBoundedByCS(pcSubStr, pacBounds, TRUE)

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
		return This.SubStringBetweenCSZ(pcSubStr, pcSubStr1, pcSubStr2, TRUE)

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

	def SubStringBetweenCSZZ(pcSubStr, pcSubStr1, pcSubStr2, pCaseSensitive)
		aResult = [ pcSubStr, This.FindSubStringBetweenCSZZ(pcSubStr, pcSubStr1, pcSubStr2, pCaseSensitive) ]
		return aResult

		#< @FunctionAlternativeForm

		def SubStringBetweenAsSectionsCS(pcSubStr, pcSubStr1, pcSubStr2, pCaseSensitive)
			return This.SubStringBetweenCSZZ(pcSubStr, pcSubStr1, pcSubStr2, pCaseSensitive)

		#>

	#-- WITHOUT CASESENSITIVITY

	def SubStringBetweenZZ(pcSubStr, pcSubStr1, pcSubStr2)
		return This.SubStringBetweenCSZZ(pcSubStr, pcSubStr1, pcSubStr2, TRUE)

		#< @FunctionAlternativeForm

		def SubStringBetweenAsSections(pcSubStr, pcSubStr1, pcSubStr2)
			return This.SubStringBetweenZZ(pcSubStr, pcSubStr1, pcSubStr2)

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

			nPos = oSection.FindNextSCS(cBounded, nStart, pCaseSensitive)

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

		#--

		def FindPreviousNthSubStringBoundedBySCS(n, pcSubStr, pacBounds, pnStartingAt, pCaseSensitive)
			return This.FindPreviousNthSubStringBoundedByCS(n, pcSubStr, pacBounds, pnStartingAt, pCaseSensitive)

		def FindNthPreviousSubStringBoundedBySCS(n, pcSubStr, pacBounds, pnStartingAt, pCaseSensitive)
			return This.FindPreviousNthSubStringBoundedByCS(n, pcSubStr, pacBounds, pnStartingAt, pCaseSensitive)

		def FindPreviousNthSubStringBoundedBySCSZ(n, pcSubStr, pacBounds, pnStartingAt, pCaseSensitive)
			return This.FindPreviousNthSubStringBoundedByCS(n, pcSubStr, pacBounds, pnStartingAt, pCaseSensitive)

		def FindNthPreviousSubStringBoundedBySCSZ(n, pcSubStr, pacBounds, pnStartingAt, pCaseSensitive)
			return This.FindPreviousNthSubStringBoundedByCS(n, pcSubStr, pacBounds, pnStartingAt, pCaseSensitive)

		#>

	#-- WITHOUT CASESENSITIVITY

	def FindPreviousNthSubStringBoundedBy(n, pcSubStr, pcBound1, pcBound2, pnStartingAt)
		return This.FindPreviousNthSubStringBoundedByCS(n, pcSubStr, pcBound1, pcBound2, pnStartingAt, TRUE)

		#< @FunctionAlternativeForms

		def FindNthPreviousSubStringBoundedBy(n, pcSubStr, pacBounds, pnStartingAt)
			return This.FindPreviousNthSubStringBoundedBy(n, pcSubStr, pacBounds, pnStartingAt)

		def FindPreviousNthSubStringBoundedByZ(n, pcSubStr, pacBounds, pnStartingAt)
			return This.FindPreviousNthSubStringBoundedBy(n, pcSubStr, pacBounds, pnStartingAt)

		def FindNthPreviousSubStringBoundedByZ(n, pcSubStr, pacBounds, pnStartingAt)
			return This.FindPreviousNthSubStringBoundedBy(n, pcSubStr, pacBounds, pnStartingAt)

		#--

		def FindPreviousNthSubStringBoundedByS(n, pcSubStr, pacBounds, pnStartingAt)
			return This.FindPreviousNthSubStringBoundedBy(n, pcSubStr, pacBounds, pnStartingAt)

		def FindNthPreviousSubStringBoundedByS(n, pcSubStr, pacBounds, pnStartingAt)
			return This.FindPreviousNthSubStringBoundedBy(n, pcSubStr, pacBounds, pnStartingAt)

		def FindPreviousNthSubStringBoundedBySZ(n, pcSubStr, pacBounds, pnStartingAt)
			return This.FindPreviousNthSubStringBoundedBy(n, pcSubStr, pacBounds, pnStartingAt)

		def FindNthPreviousSubStringBoundedBySZ(n, pcSubStr, pacBounds, pnStartingAt)
			return This.FindPreviousNthSubStringBoundedBy(n, pcSubStr, pacBounds, pnStartingAt)

		#>


	  #-----------------------------------------------------------------------------------------------------#
	 #  FINDING PREVIOUS OCCURRENCE OF A SUBSTRING BOUNDED BY TWO SUBSTRINGS STARTING AT A GIVEN POSITION  #
	#-----------------------------------------------------------------------------------------------------#

	def FindPreviousSubStringBoundedByCS(pcSubStr, pacBounds, pnStartingAt, pCaseSensitive)
		nResult = This.FindPreviousNthSubStringBoundedByCS(1, pcSubStr, pacBounds, pnStartingAt, pCaseSensitive)
		return nResult

		#< @FunctionAlternativeForms

		def FindPreviousSubStringBoundedByCSZ(pcSubStr, pacBounds, pnStartingAt, pCaseSensitive)
			return This.FindPreviousSubStringBoundedByCS(pcSubStr, pacBounds, pnStartingAt, pCaseSensitive)

		#--

		def FindPreviousSubStringBoundedBySCS(pcSubStr, pacBounds, pnStartingAt, pCaseSensitive)
			return This.FindPreviousSubStringBoundedByCS(n, pcSubStr, pacBounds, pnStartingAt, pCaseSensitive)

		def FindPreviousSubStringBoundedBySCSZ(pcSubStr, pacBounds, pnStartingAt, pCaseSensitive)
			return This.FindPreviousSubStringBoundedByCS(pcSubStr, pacBounds, pnStartingAt, pCaseSensitive)

		#>

	#-- WITHOUT CASESENSITIVITY

	def FindPreviousSubStringBoundedBy(pcSubStr, pcBound1, pcBound2, pnStartingAt)
		return This.FindPreviousSubStringBoundedByCS(pcSubStr, pcBound1, pcBound2, pnStartingAt, TRUE)

		#< @FunctionAlternativeForms

		def FindPreviousSubStringBoundedByZ(pcSubStr, pacBounds, pnStartingAt)
			return This.FindPreviousSubStringBoundedBy(pcSubStr, pacBounds, pnStartingAt)

		#--

		def FindPreviousSubStringBoundedByS(pcSubStr, pacBounds, pnStartingAt)
			return This.FindPreviousSubStringBoundedBy(n, pcSubStr, pacBounds, pnStartingAt)

		def FindPreviousSubStringBoundedBySZ(pcSubStr, pacBounds, pnStartingAt)
			return This.FindPreviousSubStringBoundedBy(pcSubStr, pacBounds, pnStartingAt)

		#>

	  #=======================================================================================================================#
	 #  FINDING NTH NEXT OCCURRENCE OF A SUBSTRING BETWEEN TWO SUBSTRINGS STARTING AT A GIVEN POSITION AND INCLUDING BOuNDS  #
	#=======================================================================================================================#

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

	  #--------------------------------------------------------------------------------------------------------------------------#
	 #  FINDING NTH NEXT OCCURRENCE OF A SUBSTRING BOUNDED BY TWO SUBSTRINGS STARTING AT A GIVEN POSITION AND INCLUDING BOUNDS  #
	#--------------------------------------------------------------------------------------------------------------------------#

	def FindNextNthSubStringBoundedByCSIB(n, pcSubStr, pacBounds, pnStartingAt, pCaseSensitive)
		if isString(pacBounds)
			return This.FindNextNthSubStringBetweenCSIB(n, pcSubStr, pacBounds, pacBounds, pnStartingAt, pCaseSensitive)

		but isList(pacBounds) and Q(pacBounds).IsPairOfStrings()
			return This.FindNextNthSubStringBetweenCSIB(n, pcSubStr, pacBounds, pacBounds, pnStartingAt, pCaseSensitive)

		else
			StzRaise("Incorrect param type! pacBounds must be a string or pair of strings.")
		ok

		return This.FindNextNthSubStringBetweenCSIB(n, pcSubStr, pcBound1, pcBound2, pnStartingAt, pCaseSensitive)

		#< @FunctionAlternativeForms

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

		#>

	#-- WITHOUT CASESENSITIVITY

	def FindNextNthSubStringBoundedByIB(n, pcSubStr, pacBounds, pnStartingAt)
		return This.FindNextNthSubStringBoundedByCSIB(n, pcSubStr, pacBounds, pnStartingAt, TRUE)

		#< @FunctionAlternativeForms

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

		#>

	  #-------------------------------------------------------------------------------------------------#
	 #  FINDING NEXT OCCURRENCE OF A SUBSTRING BOUNDED BY TWO SUBSTRINGS STARTING AT A GIVEN POSITION  #
	#=================================================================================================#

	def FindNextSubStringBetweenCSIB(pcSubStr, pcBound1, pcBound2, pnStartingAt, pCaseSensitive)
		return This.FindNthSubStringBetweenCSIB(1, pcSubStr, pcBound1, pcBound2, pnStartingAt, pCaseSensitive)

		#< @FunctionAlternativeForms

		def FindNextSubStringBetweenSCSIB(pcSubStr, pcBound1, pcBound2, pnStartingAt, pCaseSensitive)
			return This.FindNextSubStringBetweenCSIB(pcSubStr, pcBound1, pcBound2, pnStartingAt, pCaseSensitive)

		def FindNextSubStringBetweenCSIBZ(pcSubStr, pcBound1, pcBound2, pnStartingAt, pCaseSensitive)
			return This.FindNextSubStringBetweenCSIB(pcSubStr, pcBound1, pcBound2, pnStartingAt, pCaseSensitive)

		def FindNextSubStringBetweenSCSIBZ(pcSubStr, pcBound1, pcBound2, pnStartingAt, pCaseSensitive)
			return This.FindNextSubStringBetweenCSIB(pcSubStr, pcBound1, pcBound2, pnStartingAt, pCaseSensitive)
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
		#>

	  #-------------------------------------------------------------------------------------------------#
	 #  FINDING NEXT OCCURRENCE OF A SUBSTRING BOUNDED BY TWO SUBSTRINGS STARTING AT A GIVEN POSITION  #
	#-------------------------------------------------------------------------------------------------#

	def FindNextSubStringBoundedByCSIB(pcSubStr, pacBounds, pnStartingAt, pCaseSensitive)
		return This.FindNextNthSubStringBoundedByCSIB(1, pcSubStr, pacBounds, pnStartingAt, pCaseSensitive)

		#< @FunctionAlternativeFroms

		def FindNextSubStringBoundedByCSIBZ(pcSubStr, pacBounds, pnStartingAt, pCaseSensitive)
			return This.FindNextSubStringBoundedByCSIB(pcSubStr, pacBounds, pnStartingAt, pCaseSensitive)

		def FindNextSubStringBoundedBySCSIB(pcSubStr, pacBounds, pnStartingAt, pCaseSensitive)
			return This.FindNextNthSubStringBoundedByCSIB(1, pcSubStr, pacBounds, pnStartingAt, pCaseSensitive)

		def FindNextSubStringBoundedBySCSIBZ(pcSubStr, pacBounds, pnStartingAt, pCaseSensitive)
			return This.FindNextSubStringBoundedByCSIB(pcSubStr, pacBounds, pnStartingAt, pCaseSensitive)

		#>

	#-- WITHOUT CASESENSITIVITY

	def FindNextSubStringBoundedByIB(pcSubStr, pacBounds, pnStartingAt)
		return This.FindNextNthSubStringBoundedByIB(1, pcSubStr, pacBounds, pnStartingAt)

		#< @FunctionAlternativeForms

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

		#>

	  #---------------------------------------------------------------------------------------------------------#
	 #  FINDING NTH PREVIOUS OCCURRENCE OF A SUBSTRING BOUNDED BY TWO SUBSTRINGS STARTING AT A GIVEN POSITION  #
	#---------------------------------------------------------------------------------------------------------#

	def FindPreviousNthSubStringBoundedByCSIB(n, pcSubStr, pacBounds, pnStartingAt, pCaseSensitive)
		if isString(pacBounds)
			return This.FindPreviousNthSubStringBetweenCSIB(n, pcSubStr, pacBounds, pacBounds, pnStartingAt, pCaseSensitive)

		but isList(pacBounds) and Q(pacBounds).IsPairOfStrings()
			return This.FindPreviousNthSubStringBetweenCSIB(n, pcSubStr, pacBounds, pacBounds, pnStartingAt, pCaseSensitive)

		else
			StzRaise("Incorrect param type! pacBounds must be a string or pair of strings.")
		ok

		return This.FindPreviousNthSubStringBetweenCSIB(n, pcSubStr, pcBound1, pcBound2, pnStartingAt, pCaseSensitive)

		#< @FunctionAlternativeForms

		def FindNthPreviousSubStringBoundedByCSIB(n, pcSubStr, pacBounds, pnStartingAt, pCaseSensitive)
			return This.FindPreviousNthSubStringBoundedByCSIB(n, pcSubStr, pacBounds, pnStartingAt, pCaseSensitive)

		def FindPreviousNthSubStringBoundedByCSIBZ(n, pcSubStr, pacBounds, pnStartingAt, pCaseSensitive)
			return This.FindPreviousNthSubStringBoundedByCSIB(n, pcSubStr, pacBounds, pnStartingAt, pCaseSensitive)

		def FindNthPreviousSubStringBoundedByCSIBZ(n, pcSubStr, pacBounds, pnStartingAt, pCaseSensitive)
			return This.FindPreviousNthSubStringBoundedByCSIB(n, pcSubStr, pacBounds, pnStartingAt, pCaseSensitive)

		#>

	#-- WITHOUT CASESENSITIVITY

	def FindPreviousNthSubStringBoundedByIB(n, pcSubStr, pacBounds, pnStartingAt)
		return This.FindPreviousNthSubStringBoundedByCSIB(n, pcSubStr, pacBounds, pnStartingAt, TRUE)

		#< @FunctionAlternativeForms

		def FindNthPreviousSubStringBoundedByIB(n, pcSubStr, pacBounds, pnStartingAt)
			return This.FindPreviousNthSubStringBoundedByIB(n, pcSubStr, pacBounds, pnStartingAt)

		def FindPreviousNthSubStringBoundedByIBZ(n, pcSubStr, pacBounds, pnStartingAt)
			return This.FindPreviousNthSubStringBoundedByIB(n, pcSubStr, pacBounds, pnStartingAt)

		def FindNthPreviousSubStringBoundedByIBZ(n, pcSubStr, pacBounds, pnStartingAt)
			return This.FindPreviousNthSubStringBoundedByIB(n, pcSubStr, pacBounds, pnStartingAt)

		#>

	  #---------------------------------------------------------------------------------------------------#
	 #  FINDING PREVIOUS OCCURRENCE OF A SUBSTRING BETWEEB TWO SUBSTRINGS  STARTING AT A GIVEN POSITION  #
	#===================================================================================================#

	def FindPreviousSubStringBetweenCSIB(pcSubStr, pcBound1, pcBound2, pnStartingAt, pCaseSensitive)
		return This.FindNthSubStringBetweenCSIB(1, pcSubStr, pcBound1, pcBound2, pnStartingAt, pCaseSensitive)

		#< @FunctionAlternativeForm

		def FindPreviousSubStringBetweenCSIBZ(pcSubStr, pcBound1, pcBound2, pnStartingAt, pCaseSensitive)
			return This.FindPreviousSubStringBetweenCSIB(pcSubStr, pcBound1, pcBound2, pnStartingAt, pCaseSensitive)

		#>

	#-- WITHOUT CASESENSITIVITY

	def FindPreviousSubStringBetweenIB(pcSubStr, pcBound1, pcBound2, pnStartingAt)
		return This.FindPreviousSubStringBetweenCSIB(pcSubStr, pcBound1, pcBound2, pnStartingAt, TRUE)

		#< @FunctionAlternativeForm

		def FindPreviousSubStringBetweenIBZ(pcSubStr, pcBound1, pcBound2, pnStartingAt, pCaseSensitive)
			return This.FindPreviousSubStringBetweenIB(pcSubStr, pcBound1, pcBound2, pnStartingAt)

		#>

	  #------------------------------------------------------------------------------------------------------#
	 #  FINDING PREVIOUS OCCURRENCE OF A SUBSTRING BOUNDED BY TWO SUBSTRINGS  STARTING AT A GIVEN POSITION  #
	#------------------------------------------------------------------------------------------------------#

	def FindPreviousSubStringBoundedByCSIB(pcSubStr, pacBounds, pnStartingAt, pCaseSensitive)
		return This.FindPreviousNthSubStringBoundedByCSIB(1, pcSubStr, pacBounds, pnStartingAt, pCaseSensitive)

		def FindPreviousSubStringBoundedByCSIBZ(pcSubStr, pacBounds, pnStartingAt, pCaseSensitive)
			return This.FindPreviousSubStringBoundedByCSIB(pcSubStr, pacBounds, pnStartingAt, pCaseSensitive)

	#-- WITHOUT CASESENSITIVITY

	def FindPreviousSubStringBoundedByIB(pcSubStr, pacBounds, pnStartingAt)
		return This.FindPreviousSubStringBoundedByCSIB(pcSubStr, pacBounds, pnStartingAt, TRUE)

		def FindPreviousSubStringBoundedByZIB(pcSubStr, pacBounds, pnStartingAt, pCaseSensitive)
			return This.FindPreviousSubStringBoundedByIB(pcSubStr, pacBounds, pnStartingAt)

	  #================================================================#
	 #  FINDING NTH OCCURRENCE OF A SUBSTRING BETWEEN TWO SUBSTRINGS  #
	#================================================================#

	def FindNthSubStringBetweenCS(n, pcSubStr, pcBound1, pcBound2, pCaseSensitive)
		nResult = this.FindNthSubStringBetweenSCS(n, pcSubStr, pcBound1, pcBound2, 1, pCaseSensitive)
		return nResult

		#< @FunctionAlternativeForm
	
		def FindNthSubStringBetweenCSZ(n, pcSubStr, pcBound1, pcBound2, pCaseSensitive)
			return This.FindNthSubStringBetweenCS(n, pcSubStr, pcBound1, pcBound2, pCaseSensitive)

		#>

	#-- WITHOUT CASESENSITIVE

	def FindNthSubStringBetween(n, pcSubStr, pcBound1, pcBound2)
		return This.FindNthSubStringBetweenCS(n, pcSubStr, pcBound1, pcBound2, TRUE)

		#< @FunctionAlternativeForm
	
		def FindNthSubStringBetweenZ(n, pcSubStr, pcBound1, pcBound2)
			return This.FindNthSubStringBetween(n, pcSubStr, pcBound1, pcBound2)

		#>

	  #-------------------------------------------------------------------#
	 #  FINDING NTH OCCURRENCE OF A SUBSTRING BOUNDED BY TWO SUBSTRINGS  #
	#-------------------------------------------------------------------#

	def FindNthSubStringBoundedByCS(n, pcSubStr, pacBounds, pCaseSensitive)
		if isString(pacBounds)
			return This.FindNthSubStringBetweenCS(n, pcSubStr, pacBounds, pacBounds, pCaseSensitive)

		but isList(pacBounds) and Q(pacBounds).IsPairOfStrings()
			return This.FindNthSubStringBetweenCS(n, pcSubStr, pacBounds[1], pacBounds[2], pCaseSensitive)

		else
			StzRaise("Incorrect param type! pacBounds must be a string or pair of strings.")
		ok

		#< @FunctionAlternativeForm

		def FindNthSubStringBoundedByCSZ(n, pcSubStr, pacBounds, pCaseSensitive)
			return This.FindNthSubStringBoundedByCS(n, pcSubStr, pacBound, pCaseSensitives)

		#>

	#-- WITHOUT CASESENSITIVITY

	def FindNthSubStringBoundedBy(n, pcSubStr, pacBounds)
		return This.FindNthSubStringBoundedByCS(n, pcSubStr, pacBounds, TRUE)

		#< @FunctionAlternativeForm

		def FindNthSubStringBoundedByZ(n, pcSubStr, pacBounds)
			return This.FindNthSubStringBoundedBy(n, pcSubStr, pacBound)

		#>

	  #---------------------------------------------------------------------#
	 #  FINDING FIRST OCCURRENCE OF A SUBSTRING BOUNDED BY TWO SUBSTRINGS  #
	#=====================================================================#

	def FindFirstSubStringBetweenCS(pcSubStr, pcBound1, pcBound2, pCaseSensitive)
		return This.FindNthSubStringBetweenCS(1, pcSubStr, pcBound1, pcBound2, pCaseSensitive)

		#< @FunctionAlternativeForm

		def FindFirstSubStringBetweenCSZ(pcSubStr, pcBound1, pcBound2, pCaseSensitive)
			return This.FindFirstSubStringBetweenCS(pcSubStr, pcBound1, pcBound2, pCaseSensitive)
	
		#>

	#-- WITHOUT CASESENSITIVE

	def FindFirstSubStringBetween(pcSubStr, pcBound1, pcBound2)
		return This.FindFirstSubStringBetweenCS(pcSubStr, pcBound1, pcBound2, TRUE)

		#< @FunctionAlternativeForm

		def FindFirstSubStringBetweenZ(pcSubStr, pcBound1, pcBound2)
			return This.FindFirstSubStringBetween(pcSubStr, pcBound1, pcBound2)
	
		#>

	  #---------------------------------------------------------------------#
	 #  FINDING FIRST OCCURRENCE OF A SUBSTRING BOUNDED BY TWO SUBSTRINGS  #
	#---------------------------------------------------------------------#

	def FindFirstSubStringBoundedByCS(pcSubStr, pacBounds, pCaseSensitive)
		return This.FindNthSubStringBoundedByCS(1, pcSubStr, pacBounds, pCaseSensitive)

		#< @FunctionAlternativeForm

		def FindFirstSubStringBoundedByCSZ(pcSubStr, pacBounds, pCaseSensitive)
			return This.FindFirstSubStringBoundedByCS(pcSubStr, pacBound, pCaseSensitives)

		#>

	#-- WITHOUT CASESENSITIVITY

	def FindFirstSubStringBoundedBy(pcSubStr, pacBounds)
		return This.FindFirstSubStringBoundedByCS(pcSubStr, pacBounds, TRUE)

		#< @FunctionAlternativeForm

		def FindFirstSubStringBoundedByZ(pcSubStr, pacBounds)
			return This.FindFirstSubStringBoundedBy(pcSubStr, pacBound)

		#>

	  #-----------------------------------------------------------------#
	 #  FINDING LAST OCCURRENCE OF A SUBSTRING BETWEEN TWO SUBSTRINGS  #
	#=================================================================#

	#TODO: check performance!

	def FindLastSubStringBetweenCS(pcSubStr, pcBound1, pcBound2, pCaseSensitive)
		nLast = This.NumberOfOccurrenceOfSubStringBetweenCS(pcSubStr, pcBound1, pcBound2, pCaseSensitive)
		return This.FindNthSubStringBetweenCS(nLast, pcSubStr, pcBound1, pcBound2, pCaseSensitive)

		#< @FunctionAlternativeForm

		def FindLastSubStringBetweenCSZ(pcSubStr, pcBound1, pcBound2, pCaseSensitive)
			return This.FindLastSubStringBetweenCS(pcSubStr, pcBound1, pcBound2, pCaseSensitive)
	
		#>

	#-- WITHOUT CASESENSITIVE

	def FindLastSubStringBetween(pcSubStr, pcBound1, pcBound2)
		return This.FindLastSubStringBetweenCS(pcSubStr, pcBound1, pcBound2, TRUE)

		#< @FunctionAlternativeForm

		def FindLastSubStringBetweenZ(pcSubStr, pcBound1, pcBound2)
			return This.FindLastSubStringBetween(pcSubStr, pcBound1, pcBound2)
	
		#>

	  #--------------------------------------------------------------------#
	 #  FINDING LAST OCCURRENCE OF A SUBSTRING BOUNDED BY TWO SUBSTRINGS  #
	#--------------------------------------------------------------------#

	def FindLastSubStringBoundedByCS(pcSubStr, pacBounds, pCaseSensitive)
		if isString(pacBounds)
			return This.FindLastSubStringBetweenCS(pcSubStr, pacBounds, pacBounds, pCaseSensitive)

		but isList(pacBounds) and Q(pacBounds).IsPairOfStrings()
			return This.FindLastSubStringBetweenCS(pcSubStr, pacBounds[1], pacBounds[2], pCaseSensitive)

		else
			StzRaise("Incorrect param type! pacBounds must be a string or pair of strings.")
		ok

		#< @FunctionAlternativeForm

		def FindLastSubStringBoundedByCSZ(pcSubStr, pacBounds, pCaseSensitive)
			return This.FindLastSubStringBoundedByCS(pcSubStr, pacBound, pCaseSensitives)

		#>

	#-- WITHOUT CASESENSITIVE

	def FindLastSubStringBoundedBy(pcSubStr, pacBounds)
		return This.FindLastSubStringBoundedByCS(pcSubStr, pacBounds, TRUE)

		#< @FunctionAlternativeForm

		def FindLastSubStringBoundedByZ(pcSubStr, pacBounds)
			return This.FindLastSubStringBoundedBy(pcSubStr, pacBound)

		#>

	   #-------------------------------------------------------#
	  #   FINDING NTH OCCURRENCE OF A SUBSTRING BETWEEN TWO   #
	 #   OTHER SUBSTRINGS AND RETURNING THEM AS SECTIONS     #
	#=======================================================#

	def FindNthSubStringBetweenCSZZ(n, pcSubStr, pcBound1, pcBound2, pCaseSensitive)
		nPos = This.FindNthSubStringBetweenCS(n, pcSubStr, pcBound1, pcBound2, pCaseSensitive)
		nLenBound1 = Q(pcBound1).NumberOfChars()

		aResult = [ nPos, nPos + nLenBound1 - 1 ]

		return aResult

		#< @FunctionAlternativeForms
	
		def FindNthSubStringBetweenAsSectionCS(n, pcSubStr, pcBound1, pcBound2, pCaseSensitive)
			return This.FindNthSubStringBetweenCSZZ(n, pcSubStr, pcBound1, pcBound2, pCaseSensitive)

		#>

	#-- WITHOUT CASESENSITIVITY

	def FindNthSubStringBetweenZZ(n, pcSubStr, pcBound1, pcBound2)
		return This.FindNthSubStringBetweenCSZZ(n, pcSubStr, pcBound1, pcBound2, TRUE)

		#< @FunctionAlternativeForms
	
		def FindNthSubStringBetweenAsSection(n, pcSubStr, pcBound1, pcBound2)
			return This.FindNthSubStringBetweenZZ(n, pcSubStr, pcBound1, pcBound2)

		#>

	   #--------------------------------------------------------#
	  #   FINDING NTH OCCURRENCE OF A SUBSTRING BOUNDED BY     #
	 #   TWO OTHER SUBSTRINGS AND RETURNING THEM AS SECTIONS  #
	#=======================================================#

	def FindNthSubStringBoundedByCSZZ(n, pcSubStr, pacBounds, pCaseSensitive)
		if isString(pacBounds)
			return This.FindNthSubStringBetweenCSZZ(n, pcSubStr, pcBounds, pcBounds, pCaseSensitive)

		but isList(pacBounds) and Q(pacBounds).IsPairOfStrings()
			return This.FindNthSubStringBetweenCSZZ(n, pcSubStr, pacBounds[1], pacBounds[2], pCaseSensitive)

		else
			StzRaise("Incorrect param type! pacBounds must be a string or pair of strings.")
		ok

		#< @FunctionAlternativeForm

		def FindNthSubStringBoundedByAsSectionCS(n, pcSubStr, pacBounds, pCaseSensitive)
			return This.FindNthSubStringBoundedByCSZZ(n, pcSubStr, pacBounds, pCaseSensitive)

		#>

	#-- WITHOUT CASESENSITIVITY

	def FindNthSubStringBoundedByZZ(n, pcSubStr, pacBounds)
		return This.FindNthSubStringBoundedByCSZZ(n, pcSubStr, pacBounds, TRUE)

		#< @FunctionAlternativeForm

		def FindNthSubStringBoundedByAsSection(n, pcSubStr, pacBounds)
			return This.FindNthSubStringBoundedByZZ(n, pcSubStr, pacBounds)

		#>

	  #---------------------------------------------------------------------------------------#
	 #  FINDING NTH OCCURRENCE OF A SUBSTRING BETWEEN TWO OTHER SUBSTRINGS INCLUDING BOUNDS  #
	#=======================================================================================#

	def FindNthSubStringBetweenCSIB(n, pcSubStr, pcBound1, pcBound2, pCaseSensitive)
		nResult = This.FindNextNthSubStringBetweenCSIB(n, pcSubStr, pcBound1, pcBound2, 1, pCaseSensitive)
		return nResult

		#< @FunctionAlternativeForm

		def FindNthSubStringBetweenCSIBZ(n, pcSubStr, pcBound1, pcBound2, pCaseSensitive)
			return This.FindNthSubStringBetweenCSIB(n, pcSubStr, pcBound1, pcBound2, pCaseSensitive)

		#>

	#-- WITHOUT CASESENSITIVE

	def FindNthSubStringBetweenIB(n, pcSubStr, pcBound1, pcBound2)
		return This.FindNthSubStringBetweenCSIB(n, pcSubStr, pcBound1, pcBound2, TRUE)

		#< @FunctionAlternativeForm

		def FindNthSubStringBetweenIBZ(n, pcSubStr, pcBound1, pcBound2)
			return This.FindNthSubStringBetweenIB(n, pcSubStr, pcBound1, pcBound2)

		#>

	  #---------------------------------------------------------------------------------------#
	 #  FINDING NTH OCCURRENCE OF A SUBSTRING BETWEEN TWO OTHER SUBSTRINGS INCLUDING BOUNDS  #
	#---------------------------------------------------------------------------------------#

	def FindNthSubStringBoundedByCSIB(n, pcSubStr, pacBounds, pCaseSensitive)
		if isString(pacBounds)
			return This.FindNthSubStringBetweenCSIB(n, pcSubStr, pacBounds, pacBounds, pCaseSensitive)

		but isList(pacBounds) and Q(pacBounds).IsPairOfStrings()
			return This.FindNthSubStringBetweenCSIB(n, pcSubStr, pacBounds[1], pacBounds[2], pCaseSensitive)

		else
			StzRaise("Incorrect param type! pacBounds must be a string or pair of strings.")
		ok

		#< @FunctionAlternativeForm

		def FindNthSubStringBoundedByCSIBZ(n, pcSubStr, pacBounds, pCaseSensitive)
			return This.FindNthSubStringBoundedByCSIB(n, pcSubStr, pacBound, pCaseSensitives)

		#>

	#--

	def FindNthSubStringBoundedByIB(n, pcSubStr, pacBounds)
		return This.FindNthSubStringBoundedByCSIB(n, pcSubStr, pacBounds, TRUE)

		#< @FunctionAlternativeForm

		def FindNthSubStringBoundedByIBZ(n, pcSubStr, pacBounds)
			return This.FindNthSubStringBoundedByIB(n, pcSubStr, pacBound)

		#>

	   #-----------------------------------------------------------------------#
	  #  FINDING NTH OCCURRENCE OF A SUBSTRING BETWEEN TWO OTHER SUBSTRINGS   #
	 #  INCLUDING BOUNDS AND RETURNING THEIR POSITIONS AS SECTIONS           #
	#=======================================================================#

	def FindNthSubStringBetweenCSIBZZ(n, pcSubStr, pcBound1, pcBound2, pCaseSensitive)
		nPos = This.FindNthSubStringBetweenCSIB(n, pcSubStr, pcBound1, pcBound2, pCaseSensitive)
		nLenBound1 = Q(pcBound1).NumberOfChars()

		aResult = [ pcSubStr, (nPos + nLenBound1 - 1) ]

		return aResult

		#< @FunctionAlternativeForm
	
		def FindNthSubStringBetweenAsSectionsCSIB(n, pcSubStr, pcBound1, pcBound2, pCaseSensitive)
			return This.FindNthSubStringBetweenCSIBZZ(n, pcSubStr, pcBound1, pcBound2, pCaseSensitive)

		#>

	#-- WITHOUT CASESENSITIVITY

	def FindNthSubStringBetweenIBZZ(n, pcSubStr, pcBound1, pcBound2)
		return This.FindNthSubStringBetweenCSIBZZ(n, pcSubStr, pcBound1, pcBound2, TRUE)

		#< @FunctionAlternativeForm
	
		def FindNthSubStringBetweenAsSectionsIB(n, pcSubStr, pcBound1, pcBound2)
			return This.FindNthSubStringBetweenIBZZ(n, pcSubStr, pcBound1, pcBound2)

		#>

	   #-------------------------------------------------------------------------#
	  #  FINDING NTH OCCURRENCE OF A SUBSTRING BOUNDED BY TWO OTHER             #
	 #  SUBSTRINGS INCLUDING BOUNDS AND RETURNING THEIR POSITIONS AS SECTIONS  #          #
	#-------------------------------------------------------------------------#

	def FindNthSubStringBoundedByCSIBZZ(n, pcSubStr, pacBounds, pCaseSensitive)
		if isString(pacBounds)
			return This.FindNthSubStringBetweenCSIBZZ(n, pcSubStr, pcBounds, pcBounds, pCaseSensitive)

		but isList(pacBounds) and Q(pacBounds).IsPairOfStrings()
			return This.FindNthSubStringBetweenCSIBZZ(n, pcSubStr, pacBounds[1], pacBounds[2], pCaseSensitive)

		else
			StzRaise("Incorrect param type! pacBounds must be a string or pair of strings.")
		ok

		#< @FunctionAlternativeForm

		def FindNthSubStringBoundedByAsSectionsCSIB(n, pcSubStr, pacBounds, pCaseSensitive)
			return This.FindNthSubStringBoundedByCSIBZZ(n, pcSubStr, pacBounds, pCaseSensitive)

		#>

	#-- WITHOUT CASESENSITIVITY

	def FindNthSubStringBoundedByIBZZ(n, pcSubStr, pacBounds)
		return This.FindNthSubStringBoundedByCSIBZZ(n, pcSubStr, pacBounds, TRUE)

		#< @FunctionAlternativeForm

		def FindNthSubStringBoundedByAsSectionsIB(n, pcSubStr, pacBounds)
			return This.FindNthSubStringBoundedByIBZZ(n, pcSubStr, pacBounds)

		#>

	   #----------------------------------------------------#
	  #  FINDING NTH OCCURRENCE OF A SUBSTRING BOUNDED BY  #
	 #  OTHER SUBSTRINGS STARTING AT A GIVEN POSITION     #
	#====================================================#

	def FindNthSubStringBoundedBySCS(n, pcSubStr, pacBounds, pnStartingAt, pCaseSensitive)
		if isString(pacBounds)
			return This.FindNthSubStringBetweenSCS(n, pcSubStr, pacBounds, pacBounds, pnStartingAt, pCaseSensitive)

		but isList(pacBounds) and Q(pacBounds).IsPairOfStrings()
			return This.FindNthSubStringBetweenSCS(n, pcSubStr, pacBounds[1], pacBounds[2], pnStartingAt, pCaseSensitive)

		else
			StzRaise("Incorrect param type! pacBounds must be a string or pair of strings.")
		ok

		#< @FunctionAlternativeForm

		def FindNthSubStringBoundedBySCSZ(n, pcSubStr, pacBounds, pnStartingAt, pCaseSensitive)
			return This.FindNthSubStringBoundedBySCS(n, pcSubStr, pacBounds, pnStartingAt, pCaseSensitive)

		#>

	#-- WITHOUT CASESENSIVITY

	def FindNthSubStringBoundedByS(n, pcSubStr, pacBounds, pnStartingAt)
		return This.FindNthSubStringBoundedBySCS(n, pcSubStr, pacBounds, pnStartingAt, TRUE)

		#< @FunctionAlternativeForm

		def FindNthSubStringBoundedBySZ(n, pcSubStr, pacBounds, pnStartingAt)
			return This.FindNthSubStringBoundedByS(n, pcSubStr, pacBounds, pnStartingAt)

		#>

	   #----------------------------------------------------------------------#
	  #  FINDING NTH OCCURRENCE OF A SUBSTRING BETWEEN TWO OTHER SUBSTRINGS  #
	 #  STARTING AT A GIVEN POSITION AND RETURNING POSITIONS AS SECTIONS    #
	#======================================================================#

	def FindNthSubStringBetweenSCSZZ(n, pcSubStr, pcBound1, pcBound2, pnStartingAt, pCaseSensitive)

		nPos = This.FindNthSubStringBetweenSCS(n, pcSubStr, pcBound1, pcBound2, pnStartingAt, pCaseSensitive)
		nLenSubStr = Q(pcSubStr).NumberOfChars()

		aResult = [ pcSubStr, (nPos + nLenSubStr - 1) ]
		return aResult

		#< @FunctionAlternativeForm
	
		def FindNthSubStringBetweenAsSectionsSCS(n, pcSubStr, pcBound1, pcBound2, pnStartingAt, pCaseSensitive)
			return This.FindNthSubStringBetweenSCSZZ(n, pcSubStr, pcBound1, pcBound2, pnStartingAt, pCaseSensitive)

		#>

	#--WITHOUT CASESENSITIVITY

	def FindNthSubStringBetweenSZZ(n, pcSubStr, pcBound1, pcBound2, pnStartingAt)
		return This.FindNthSubStringBetweenSCSZZ(n, pcSubStr, pcBound1, pcBound2, pnStartingAt, TRUE)

		#< @FunctionAlternativeForm
	
		def FindNthSubStringBetweenAsSectionsS(n, pcSubStr, pcBound1, pcBound2, pnStartingAt)
			return This.FindNthSubStringBetweenSZZ(n, pcSubStr, pcBound1, pcBound2, pnStartingAt)

		#>

	   #-------------------------------------------------------------------------#
	  #  FINDING NTH OCCURRENCE OF A SUBSTRING BOUNDED BY TWO OTHER SUBSTRINGS  #
	 #  STARTING AT A GIVEN POSITION AND RETURNING POSITIONS AS SECTIONS       #
	#-------------------------------------------------------------------------#

	def FindNthSubStringBoundedBySCSZZ(n, pcSubStr, pacBounds, pnStartingAt, pCaseSensitive)
		if isString(pacBounds)
			return This.FindNthSubStringBetweenSCSZZ(n, pcSubStr, pacBounds, pacBounds, pnStartingAt, pCaseSensitive)

		but isList(pacBounds) and Q(pacBounds).isPairOfStrings()
			return This.FindNthSubStringBetweenSCSZZ(n, pcSubStr, pacBounds[1], pacBounds[2], pnStartingAt, pCaseSensitive)

		else
			StzRaise("Incorrect param type! pacBounds must be a string or pair of strings.")
		ok

		#< @FunctionAlternativeForm

		def FindNthSubStringBoundedByAsSectionsSCS(n, pcSubStr, pacBounds, pnStartingAt, pCaseSensitive)
			return This.FindNthSubStringBoundedBySCSZZ(n, pcSubStr, pacBounds, pnStartingAt, pCaseSensitive)

		#>

	#-- WITHOUT CASESENSITIVE

	def FindNthSubStringBoundedBySZZ(n, pcSubStr, pacBounds, pnStartingAt)
		return This.FindNthSubStringBoundedBySCSZZ(n, pcSubStr, pacBounds, pnStartingAt, TRUE)

		#< @FunctionAlternativeForm

		def FindNthSubStringBoundedByAsSectionsS(n, pcSubStr, pacBounds, pnStartingAt)
			return This.FindNthSubStringBoundedBySZZ(n, pcSubStr, pacBounds, pnStartingAt)

		#>

	   #---------------------------------------------------------------#
	  #  FINDING NTH OCCURRENCE OF A SUBSTRING BETWEEN TWO OTHER      #
	 #  SUBSTRINGSSTARTING AT A GIVEN POSITION AND INCLUDING BOUNDS  #
	#===============================================================#

	def FindNthSubStringBetweenSCSIB(n, pcSubStr, pcBound1, pcBound2, pnStartingAt, pCaseSensitive)

		nPos = This.FindNthSubStringBetweenSCS(n, pcSubStr, pcBound1, pcBound2, pnStaringAt, pCaseSensitive)
		nLenBound1 = Q(pcBound1).NumberOfChars()
		nResult = nPos - nLenBound1
		return nResult

		#< @FunctionAlternativeForm
	
		def FindNthSubStringBetweenSCSIBZ(n, pcSubStr, pcBound1, pcBound2, pnStartingAt, pCaseSensitive)
			return This.FindNthSubStringBetweenSCSIB(n, pcSubStr, pcBound1, pcBound2, pnStartingAt, pCaseSensitive)

		#>

	#-- WITHOUT CASESENSITIVITY

	def FindNthSubStringBetweenSIB(n, pcSubStr, pcBound1, pcBound2, pnStartingAt)
		return This.FindNthSubStringBetweenSCSIB(n, pcSubStr, pcBound1, pcBound2, pnStartingAt, TRUE)

		#< @FunctionAlternativeForm
	
		def FindNthSubStringBetweenSIBZ(n, pcSubStr, pcBound1, pcBound2, pnStartingAt)
			return This.FindNthSubStringBetweenSIB(n, pcSubStr, pcBound1, pcBound2, pnStartingAt)

		#>

	   #---------------------------------------------------------------#
	  #  FINDING NTH OCCURRENCE OF A SUBSTRING BOUNDED BY TWO OTHER   #
	 #  SUBSTRINGSSTARTING AT A GIVEN POSITION AND INCLUDING BOUNDS  #
	#---------------------------------------------------------------#

	def FindNthSubStringBoundedBySCSIB(n, pcSubStr, pacBounds, pnStartingAt, pCaseSensitive)
		if isString(pacBounds)
			return This.FindNthSubStringBetweenSCSIB(n, pcSubStr, pacBounds, pacBounds, pnStartingAt, pCaseSensitive)

		but isList(pacBounds) and Q(pacBounds).IsPairOfStrings()
			return This.FindNthSubStringBetweenSCSIB(n, pcSubStr, pacBounds[1], pacBounds[2], pnStartingAt, pCaseSensitive)

		else
			StzRaise("Incorrect param type! pacBounds must be a string or pair of strings.")
		ok

		#< @FunctionAlternativeForm

		def FindNthSubStringBoundedBySCSIBZ(n, pcSubStr, pacBounds, pnStartingAt, pCaseSensitive)
			return This.FindNthSubStringBoundedBySCSIB(n, pcSubStr, pacBounds, pnStartingAt, pCaseSensitive)

		#>

	#-- WITHOUT CASESENSITIVITY

	def FindNthSubStringBoundedBySIB(n, pcSubStr, pacBounds, pnStartingAt)
		return This.FindNthSubStringBoundedBySCSIB(n, pcSubStr, pacBounds, pnStartingAt, TRUE)

		#< @FunctionAlternativeForm

		def FindNthSubStringBoundedBySIBZ(n, pcSubStr, pacBounds, pnStartingAt)
			return This.FindNthSubStringBoundedBySIB(n, pcSubStr, pacBounds, pnStartingAt)

		#>

	   #-----------------------------------------------------------------------------------#
	  #  FINDING NTH OCCURRENCE OF A SUBSTRING BETWEEN TWO OTHER SUBSTRINGS STARTING      #
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

		#< @FunctionAlternativeForm
	
		def FindNthSubStringBetweenAsSectionsSCSIB(n, pcSubStr, pcBound1, pcBound2, pnStartingAt, pCaseSensitive)
			return This.FindNthSubStringBetweenSCSIBZZ(n, pcSubStr, pcBound1, pcBound2, pnStartingAt, pCaseSensitive)

		#>

	#-- WITHOUT CASESENSITIVITY

	def FindNthSubStringBetweenSIBZZ(n, pcSubStr, pcBound1, pcBound2, pnStartingAt)
		return This.FindNthSubStringBetweenSCSIBZZ(n, pcSubStr, pcBound1, pcBound2, pnStartingAt, TRUE)

		#< @FunctionAlternativeForm
	
		def FindNthSubStringBetweenAsSectionsSIB(n, pcSubStr, pcBound1, pcBound2, pnStartingAt)
			return This.FindNthSubStringBetweenSIBZZ(n, pcSubStr, pcBound1, pcBound2, pnStartingAt)

		#>

	   #-----------------------------------------------------------------------------------#
	  #  FINDING NTH OCCURRENCE OF A SUBSTRING BOUNDED BY TWO OTHER SUBSTRINGS STARTING   #
	 #  AT A GIVEN POSITION, INCLUDING BOUNDS, AND RETURNING THE POSITIONS AS SECTIONS   #
	#-----------------------------------------------------------------------------------#

	def FindNthSubStringBoundedBySCSIBZZ(n, pcSubStr, pacBounds, pnStartingAt, pCaseSensitive)
		if isString(pacBounds)
			return This.FindNthSubStringBetweenSCSIBZZ(n, pcSubStr, pacBounds, pacBounds, pnStartingAt, pCaseSensitive)

		but isList(pacBounds) and Q(pacBounds).IsPairOfStrings()
			return This.FindNthSubStringBetweenSCSIBZZ(n, pcSubStr, pacBounds[1], pacBounds[2], pnStartingAt, pCaseSensitive)

		else
			StzRaise("Incorrect param type! pacBounds must be string or pair of strings.")

		ok

		#< @FunctionAlternativeForm

		def FindNthSubStringBoundedByAsSectionsSCSIB(n, pcSubStr, pacBounds, pnStartingAt, pCaseSensitive)
			return This.FindNthSubStringBoundedBySCSIBZZ(n, pcSubStr, pacBounds, pnStartingAt, pCaseSensitive)

		#>

	#-- WITHOUT CASESENSITIVITY

	def FindNthSubStringBoundedBySIBZZ(n, pcSubStr, pacBounds, pnStartingAt)
		return This.FindNthSubStringBoundedBySCSIBZZ(n, pcSubStr, pacBounds, pnStartingAt, TRUE)

		#< @FunctionAlternativeForm

		def FindNthSubStringBoundedByAsSectionsSIB(n, pcSubStr, pacBounds, pnStartingAt)
			return This.FindNthSubStringBoundedBySIBZZ(n, pcSubStr, pacBounds, pnStartingAt)

		#>

	//// ADDING DIRECTION AS A PARAMETER (D) /////

	   #----------------------------------------------------#
	  #  FINDING NTH OCCURRENCE OF A SUBSTRING BETWEEN     #
	 #  TWO OTHER SUBSTRINGS GOING IN A GIVEN DIRECTION   #
	#====================================================#

	def FindNthSubStringBetweenDCS(n, pcSubStr, pcBound1, pcBound2, pcDirection, pCaseSensitive)

		# Checking params

		if isList(pcDirection) and Q(pcDirection).IsOneOfTheseNamedParams([ :Going, :Direction ])
			pcDirection = pcDirection[2]
		ok

		if NOT ( isString(pcDirection) and (pcDirection = :Forward or pcDirection = :Backward) )
			StzRaise("Incorrect param! pcDirection must be a string equal to :Forward or :Backward.")
		ok

		# Doing the job

		if pcDirection = :Forward
			return This.FindNextNthSubStringBetweenCS(n, pcSubStr, pcBound1, pcBound2, pCaseSensitive)

		else // pcDirection = :Backward
			nLast = This.NumberOfChars()
			return This.FindPreviousNthSubStringBetweenSCS(n, pcSubStr, pcBound1, pcBound2, nLast, pCaseSensitive)

		ok

		# #TODO (future): Check if switch could be more performant then if/else when
		# this function (or any other function written with if/else) is used in large loops

		#< @FunctionAlternativeForm
	
		def FindNthSubStringBetweenDCSZ(n, pcSubStr, pcBound1, pcBound2, pcDirection, pCaseSensitive)
			return This.FindNthSubStringBetweenDCS(n, pcSubStr, pcBound1, pcBound2, pcDirection, pCaseSensitive)

		#>

	#-- WITHOUT CASESENSITIVITY

	def FindNthSubStringBetweenD(n, pcSubStr, pcBound1, pcBound2, pcDirection)
		return This.FindNthSubStringBetweenDCS(n, pcSubStr, pcBound1, pcBound2, pcDirection, TRUE)

		#< @FunctionAlternativeForm
	
		def FindNthSubStringBetweenDZ(n, pcSubStr, pcBound1, pcBound2, pcDirection)
			return This.FindNthSubStringBetweenD(n, pcSubStr, pcBound1, pcBound2, pcDirection)

		#>

	   #----------------------------------------------------#
	  #  FINDING NTH OCCURRENCE OF A SUBSTRING BOUNDED BY  #
	 #  TWO OTHER SUBSTRINGS GOING IN A GIVEN DIRECTION   #
	#----------------------------------------------------#

	def FindNthSubStringBoundedByDCS(n, pcSubStr, pacBounds, pcDirection, pCaseSensitive)
		# Checking params

		if isList(pcDirection) and Q(pcDirection).IsOneOfTheseNamedParams([ :Going, :Direction ])
			pcDirection = pcDirection[2]
		ok

		if NOT ( isString(pcDirection) and (pcDirection = :Forward or pcDirection = :Backward) )
			StzRaise("Incorrect param! pcDirection must be a string equal to :Forward or :Backward.")
		ok

		# Doing the job

		if pcDirection = :Forward
			return This.FindNextNthSubStringBoundedByCS(n, pcSubStr, pacBounds, pcDirection, pCaseSensitive)

		else // pcDirection = :Backward
			nLast = This.NumberOfChars()
			return This.This.FindNextNthSubStringBoundedBySCS(n, pcSubStr, pacBounds, nLast, pCaseSensitive)


		ok

		#< @FunctionAlternativeForm

		def FindNthSubStringBoundedByDCSZ(n, pcSubStr, pacBounds, pcDirection, pCaseSensitive)
			return This.FindNthSubStringBoundedByDCS(n, pcSubStr, pacBounds, pcDirection, pCaseSensitive)

		#>

	#-- WITHOUT CASESENSITIVITY

	def FindNthSubStringBoundedByD(n, pcSubStr, pacBounds, pcDirection)
		return This.FindNthSubStringBoundedByDCS(n, pcSubStr, pacBounds, pcDirection, TRUE)

		#< @FunctionAlternativeForm

		def FindNthSubStringBoundedByDZ(n, pcSubStr, pacBounds, pcDirection)
			return This.FindNthSubStringBoundedByD(n, pcSubStr, pacBounds, pcDirection)

		#>

	   #-------------------------------------------------------------------------#
	  #  FINDING NTH OCCURRENCE OF A SUBSTRING BOUNDED BY TWO OTHER SUBSTRINGS  #
	 #  GOING INA GIVEN DIRECTION AND RETURNING POSITIONS AS SECTIONS          #
	#=========================================================================#

	def FindNthSubStringBetweenDCSZZ(n, pcSubStr, pcBound1, pcBound2, pcDirection, pCaseSensitive)

		nPos = This.FindNthSubStringBetweenDCS(n, pcSubStr, pcBound1, pcBound2, pcDirection, pCaseSensitive)
		nLenSubStr = Q(pcSubStr).NumberOfChars()

		anResult = [ nPos, (nPos + nLenSubStr-1) ]

		return anResult

		#< @FunctionAlternativeForm
	
		def FindNthSubStringBetweenAsSectionsDCS(n, pcSubStr, pcBound1, pcBound2, pcDirection, pCaseSensitive)
			return This.FindNthSubStringBetweenDCSZZ(n, pcSubStr, pcBound1, pcBound2, pcDirection, pCaseSensitive)


		#>

	#-- WITHOUT CASESENSITIVITY

	def FindNthSubStringBetweenDZZ(n, pcSubStr, pcBound1, pcBound2, pcDirection)
		return This.FindNthSubStringBetweenDZZ(n, pcSubStr, pcBound1, pcBound2, pcDirection)

		#< @FunctionAlternativeForm
	
		def FindNthSubStringBetweenAsSectionsD(n, pcSubStr, pcBound1, pcBound2, pcDirection)
			return This.FindNthSubStringBetweenDZZ(n, pcSubStr, pcBound1, pcBound2, pcDirection)

		#>

	   #----------------------------------------------------------------------#
	  #  FINDING NTH OCCURRENCE OF A SUBSTRING BETWEEN TWO OTHER SUBSTRINGS  #
	 #  GOING INA GIVEN DIRECTION AND RETURNING POSITIONS AS SECTIONS       #
	#----------------------------------------------------------------------#

	def FindNthSubStringBoundedByDCSZZ(n, pcSubStr, pacBounds, pcDirection, pCaseSensitive)

		nPos = This.FindNthSubStringBoundedByDCS(n, pcSubStr, pacBounds, pcDirection, pCaseSensitive)
		nLenSubStr = Q(pcSubStr).NumberOfChars()

		anResult = [ nPos, (nPos + nLenSubStr-1) ]

		return anResult

		#< @FunctionAlternativeForm

		def FindNthSubStringBoundedByAsSectionsDCS(n, pcSubStr, pacBounds, pcDirection, pCaseSensitive)
			return This.FindNthSubStringBoundedByDCSZZ(n, pcSubStr, pacBounds, pcDirection, pCaseSensitive)

		#>

	#-- WITHOUT CASESENSITIVITY

	def FindNthSubStringBoundedByDZZ(n, pcSubStr, pacBounds, pcDirection)
		return This.FindNthSubStringBoundedByDCSZZ(n, pcSubStr, pacBounds, pcDirection, TRUE)

		#< @FunctionAlternativeForm

		def FindNthSubStringBoundedByAsSectionsD(n, pcSubStr, pacBounds, pcDirection)
			return This.FindNthSubStringBoundedByDZZ(n, pcSubStr, pacBounds, pcDirection)

		#>
	
	   #--------------------------------------------------------------#
	  #  FINDING NTH OCCURRENCE OF A SUBSTRING BETWEEN TWO OTHER     #
	 #  SUBSTRINGS GOING IN A GIVEN DIRECTION AND INCLUDING BOUNDS  #
	#==============================================================#

	def FindNthSubStringBetweenDCSIB(n, pcSubStr, pcBound1, pcBound2, pcDirection, pCaseSensitive)

		nPos = This.FindNthSubStringBetweenDCS(n, pcSubStr, pcBound1, pcBound2, pcDirection, pCaseSensitive)
		nLenBound1 = Q(pcBound1).NumberOfChars()
		nResult = nPos - nLenBound1 + 1

		return nResult

		#< @FunctionAlternativeForm
	
		def FindNthSubStringBetweenDCSIBZ(n, pcSubStr, pcBound1, pcBound2, pcDirection, pCaseSensitive)
			return This.FindNthSubStringBetweenDCSIB(n, pcSubStr, pcBound1, pcBound2, pcDirection, pCaseSensitive)
		#>

	#-- WITHOUT CASESENSITIVITY

	def FindNthSubStringBetweenDIB(n, pcSubStr, pcBound1, pcBound2, pcDirection)
		return This.FindNthSubStringBetweenDCSIB(n, pcSubStr, pcBound1, pcBound2, pcDirection, TRUE)

		#< @FunctionAlternativeForm
	
		def FindNthSubStringBetweenDIBZ(n, pcSubStr, pcBound1, pcBound2, pcDirection)
			return This.FindNthSubStringBetweenDIB(n, pcSubStr, pcBound1, pcBound2, pcDirection)

		#>

	   #--------------------------------------------------------------#
	  #  FINDING NTH OCCURRENCE OF A SUBSTRING BETWEEN TWO OTHER     #
	 #  SUBSTRINGS GOING IN A GIVEN DIRECTION AND INCLUDING BOUNDS  #
	#--------------------------------------------------------------#

	def FindNthSubStringBoundedByDCSIB(n, pcSubStr, pacBounds, pcDirection, pCaseSensitive)
		if isString(pacBounds)
			return This.FindNthSubStringBetweenDCSIB(n, pcSubStr, pacBounds, pacBounds, pcDirection, pCaseSensitive)

		but isList(pacBounds) and Q(pacBounds).IsPairOfStrings()
			return This.FindNthSubStringBetweenDCSIB(n, pcSubStr, pacBounds[1], pacBounds[2], pcDirection, pCaseSensitive)

		else
			StzRaise("Incorrect param type! pacBounds must be a string or pair of strings.")
		ok

		#< @FunctionAlternativeForm

		def FindNthSubStringBoundedByDCSIBZ(n, pcSubStr, pacBounds, pcDirection, pCaseSensitive)
			return This.FindNthSubStringBoundedByDCSIB(n, pcSubStr, pacBounds, pcDirection, pCaseSensitive)

		#>

	#-- WITHOUT CASESENSITIVITY

	def FindNthSubStringBoundedByDIB(n, pcSubStr, pacBounds, pcDirection)
		return This.FindNthSubStringBoundedByDCSIB(n, pcSubStr, pacBounds, pcDirection, TRUE)

		#< @FunctionAlternativeForm

		def FindNthSubStringBoundedByDIBZ(n, pcSubStr, pacBounds, pcDirection)
			return This.FindNthSubStringBoundedByDIB(n, pcSubStr, pacBounds, pcDirection)

		#>

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

		#< @FunctionAlternativeForm
	
		def FindNthSubStringBetweenAsSectionsDCSIB(n, pcSubStr, pcBound1, pcBound2, pcDirection, pCaseSensitive)
			return This.FindNthSubStringBetweenDCSIBZZ(n, pcSubStr, pcBound1, pcBound2, pcDirection, pCaseSensitive)

		#>

	#-- WITHOUT CASESENSITIVITY

	def FindNthSubStringBetweenDIBZZ(n, pcSubStr, pcBound1, pcBound2, pcDirection)
		return This.FindNthSubStringBetweenDCSIBZZ(n, pcSubStr, pcBound1, pcBound2, pcDirection, TRUE)

		#< @FunctionAlternativeForm
	
		def FindNthSubStringBetweenAsSectionsDIB(n, pcSubStr, pcBound1, pcBound2, pcDirection)
			return This.FindNthSubStringBetweenDIBZZ(n, pcSubStr, pcBound1, pcBound2, pcDirection)

		#>

	   #-------------------------------------------------------------------------------#
	  #  FINDING NTH OCCURRENCE OF A SUBSTRING BETWEEN TWO OTHER SUBSTRINGS GOING     #
	 #  IN A GIVENDIRECTION, INCLUDING BOUNDS, AND RETURNING POSITIONS AS SECTIONS   # 
	#-------------------------------------------------------------------------------#

	def FindNthSubStringBoundedByDCSIBZZ(n, pcSubStr, pacBounds, pcDirection, pCaseSensitive)
		if isString(pacBounds)
			return This.FindNthSubStringBetweenDCSIBZZ(n, pcSubStr, pacBounds, pacBounds, pcDirection, pCaseSensitive)

		but isList(pacBounds) and Q(pacBounds).IsPairOfNumbers()
			return This.FindNthSubStringBetweenDCSIBZZ(n, pcSubStr, pacBounds[1], pacBounds[2], pcDirection, pCaseSensitive)

		else
			StzRaise("Incorrect param type! pacBounds must be a string or pair of strings.")

		ok

		#< @FunctionAlternativeForm

		def FindNthSubStringBoundedByAsSectionsDCSIB(n, pcSubStr, pacBounds, pcDirection, pCaseSensitive)
			return This.FindBoundedByDCSIBZZ(n, pcSubStr, pacBounds, pcDirection, pCaseSensitive)

		#>

	#-- WITHOUT CASESENSITIVITY

	def FindNthSubStringBoundedByDIBZZ(n, pcSubStr, pacBounds, pcDirection)
		return This.FindNthSubStringBoundedByDCSIBZZ(n, pcSubStr, pacBounds, pcDirection, TRUE)

		#< @FunctionAlternativeForm

		def FindNthSubStringBoundedByAsSectionsDIB(n, pcSubStr, pacBounds, pcDirection)
			return This.FindBoundedByDIBZZ(n, pcSubStr, pacBounds, pcDirection)

		#>

	   #-------------------------------------------------------------------------#
	  #  FINDING NTH OCCURRENCE OF A SUBSTRING BOUNDED BY TWO OTHER SUBSTRINGS  #
	 #  STARTING AT A GIVEN POSITION AND GOING IN A GIVEN DIRECTION            #
	#-------------------------------------------------------------------------#

	def FindNthSubStringBoundedBySDCS(n, pcSubStr, pacBounds, pnStartingAt, pcDirection, pCaseSensitive)
		if isString(pacBounds)
			return This.FindNthSubStringBetweenSDCS(n, pcSubStr, pacBounds, pacBounds, pnStartingAt, pcDirection, pCaseSensitive)

		but isLsit(pacBounds) and Q(pacBounds).IsPairOfStrings()
			return This.FindNthSubStringBetweenSDCS(n, pcSubStr, pacBounds[1], pacBounds[2], pnStartingAt, pcDirection, pCaseSensitive)

		else
			StzRaise("Incorrect param type! pacBounds must be a string or pair of strings.")

		ok

		#< @FunctionAlternativeForm

		def FindNthSubStringBoundedBySDCSZ(n, pcSubStr, pacBounds, pnStartingAt, pcDirection, pCaseSensitive)
			return This.FindNthSubStringBoundedBySDCS(n, pcSubStr, pacBounds, pnStartingAt, pcDirection, pCaseSensitive)

		#>

	#-- WITHOUT CASESENSITIVITY

	def FindNthSubStringBoundedBySD(n, pcSubStr, pacBounds, pnStartingAt, pcDirection)
		return This.FindNthSubStringBoundedBySDCS(n, pcSubStr, pacBounds, pnStartingAt, pcDirection, TRUE)

		#< @FunctionAlternativeForm

		def FindNthSubStringBoundedBySDZ(n, pcSubStr, pacBounds, pnStartingAt, pcDirection)
			return This.FindNthSubStringBoundedBySD(n, pcSubStr, pacBounds, pnStartingAt, pcDirection)

		#>

	   #----------------------------------------------------------------------------------------#
	  #  FINDING NTH OCCURRENCE OF A SUBSTRING BETWEEN TWO OTHER SUBSTRINGSS STARTING          #
	 #  AT A GIVEN POSITION, GOING IN A GIVEN DIRECTION, AND RETURNING POSITIONS AS SECTIONS  #
	#========================================================================================#

	def FindNthSubStringBetweenSDCSZZ(n, pcSubStr, pcBound1, pcBound2, pnStartingAt, pcDirection, pCaseSensitive)

		n1 = This.FindNthSubStringBetweenSDCSZ(n, pcSubStr, pcBound1, pcBound2, pnStartingAt, pcDirection, pCaseSensitive)
		nLenSubStr = Q(pcSubStr).NumberOfChars()
		n2 = n1 + nLenSubStr - 1
		aResult = [n1, n2]

		return aResult

		#< @FunctionAlternativeForm
	
		def FindNthSubStringBetweenAsSectionsSDCS(n, pcSubStr, pcBound1, pcBound2, pnStartingAt, pcDirection, pCaseSensitive)
			return This.FindNthSubStringBetweenSDCSZZ(n, pcSubStr, pcBound1, pcBound2, pnStartingAt, pcDirection, pCaseSensitive)

		#>

	#-- WITHOUT CASESENSITIVITY

	def FindNthSubStringBetweenSDZZ(n, pcSubStr, pcBound1, pcBound2, pnStartingAt, pcDirection)
		return This.FindNthSubStringBetweenSDCSZZ(n, pcSubStr, pcBound1, pcBound2, pnStartingAt, pcDirection, TRUE)

		#< @FunctionAlternativeForm
	
		def FindNthSubStringBetweenAsSectionsSD(n, pcSubStr, pcBound1, pcBound2, pnStartingAt, pcDirection)
			return This.FindNthSubStringBetweenSDZZ(n, pcSubStr, pcBound1, pcBound2, pnStartingAt, pcDirection)

		#>

	   #----------------------------------------------------------------------------------------#
	  #  FINDING NTH OCCURRENCE OF A SUBSTRING BOUNDED BY TWO OTHER SUBSTRINGSS STARTING       #
	 #  AT A GIVEN POSITION, GOING IN A GIVEN DIRECTION, AND RETURNING POSITIONS AS SECTIONS  #
	#----------------------------------------------------------------------------------------#

	def FindNthSubStringBoundedBySDCSZZ(n, pcSubStr, pacBounds, pnStartingAt, pcDirection, pCaseSensitive)
		return This.FindBoundedBySDCSZZ(n, pcSubStr, pacBounds, pnStartingAt, pcDirection, pCaseSensitive)

		#< @FunctionAlternativeForm

		def FindNthSubStringBoundedByAsSectionsSDCS(n, pcSubStr, pacBounds, pnStartingAt, pcDirection, pCaseSensitive)
			return This.FindNthSubStringBoundedBySDCSZZ(n, pcSubStr, pacBounds, pnStartingAt, pcDirection, pCaseSensitive)

		#>

	#-- WITHOUT CASESENSITIVITY

	def FindNthSubStringBoundedBySDZZ(n, pcSubStr, pacBounds, pnStartingAt, pcDirection)
		return This.FindNthSubStringBoundedBySDCSZZ(n, pcSubStr, pacBounds, pnStartingAt, pcDirection, TRUE)

	   #-----------------------------------------------------------------------------------#
	  #  FINDING NTH OCCURRENCE OF A SUBSTRING BOUNDED BY TWO OTHER SUBSTRINGSS STARTING  #
	 #  AT A GIVEN POSITION, GOING IN A GIVEN DIRECTION, AND INCLUDING BOUNDS            #
	#===================================================================================#

	def FindNthSubStringBetweenSDCSIB(n, pcSubStr, pcBound1, pcBound2, pnStartingAt, pcDirection, pCaseSensitive)
		nPos = This.FindNthSubStringBetweenSDCS(n, pcSubStr, pcBound1, pcBound2, pnStartingAt, pcDirection, pCaseSensitive)
		nLenBound1 = Q(pcBound1).NumberOfChars()
		nResult = nPos - nLenBound1 + 1

		return nResult

		#< @FunctionAlternativeForm
	
		def FindNthSubStringBetweenSDCSIBZ(n, pcSubStr, pcBound1, pcBound2, pnStartingAt, pcDirection, pCaseSensitive)
			return This.FindNthSubStringBetweenSDCSIB(n, pcSubStr, pcBound1, pcBound2, pnStartingAt, pcDirection, pCaseSensitive)

		#>

	#-- WITHOUT CASESENSITIVITY

	def FindNthSubStringBetweenSDIB(n, pcSubStr, pcBound1, pcBound2, pnStartingAt, pcDirection)
		return This.FindNthSubStringBetweenSDCSIB(n, pcSubStr, pcBound1, pcBound2, pnStartingAt, pcDirection, TRUE)

		#< @FunctionAlternativeForm
	
		def FindNthSubStringBetweenSDIBZ(n, pcSubStr, pcBound1, pcBound2, pnStartingAt, pcDirection)
			return This.FindNthSubStringBetweenSDIB(n, pcSubStr, pcBound1, pcBound2, pnStartingAt, pcDirection)

		#>

	   #--------------------------------------------------------------------------------#
	  #  FINDING NTH OCCURRENCE OF A SUBSTRING BETWEEN TWO OTHER SUBSTRINGSS STARTING  #
	 #  AT A GIVEN POSITION, GOING IN A GIVEN DIRECTION, AND INCLUDING BOUNDS         #
	#--------------------------------------------------------------------------------#

	def FindNthSubStringBoundedBySDCSIB(n, pcSubStr, pacBounds, pnStartingAt, pcDirection, pCaseSensitive)
		if isString(pacBounds)
			return This.FindNthSubStringBetweenSDCSIB(n, pcSubStr, pacBounds, pacBounds, pnStartingAt, pcDirection, pCaseSensitive)

		but isLsit(pacBounds) and Q(pacBounds).IsPairOfStrings()
			return This.FindNthSubStringBetweenSDCSIB(n, pcSubStr, pacBounds[1], pacBounds[2], pnStartingAt, pcDirection, pCaseSensitive)

		else
			StzRaise("Incorrect param type! pacBounds must be a string or pair of strings.")

		ok

		#< @FunctionAlternativeForm

		def FindNthSubStringBoundedBySDCSIBZ(n, pcSubStr, pacBounds, pnStartingAt, pcDirection, pCaseSensitive)
			return This.FindNthSubStringBoundedBySDCSIB(n, pcSubStr, pacBounds, pnStartingAt, pcDirection, pCaseSensitive)

		#>

	#-- WITHOUT CASESENSITIVITY

	def FindNthSubStringBoundedBySDIB(n, pcSubStr, pacBounds, pnStartingAt, pcDirection)
		return This.FindNthSubStringBoundedBySDCSIB(n, pcSubStr, pacBounds, pnStartingAt, pcDirection, TRUE)

		#< @FunctionAlternativeForm

		def FindNthSubStringBoundedBySDIBZ(n, pcSubStr, pacBounds, pnStartingAt, pcDirection)
			return This.FindNthSubStringBoundedBySDIB(n, pcSubStr, pacBounds, pnStartingAt, pcDirection, pCaseSensitive)

		#>

	   #-----------------------------------------------------------------------------------------------#
	  #  FINDING NTH OCCURRENCE OF A SUBSTRING BETWEEN TWO OTHER SUBSTRINGSS STARTING AT A GIVEN      #
	 #  POSITION, GOING IN A GIVEN DIRECTION, INCLUDING BOUNDS, AND RETURNING POSITIONS AS SECTIONS  #
	#===============================================================================================#

	def FindNthSubStringBetweenSDCSIBZZ(n, pcSubStr, pcBound1, pcBound2, pnStartingAt, pcDirection, pCaseSensitive)
		n1 = This.FindNthSubStringBetweenSDCSIB(n, pcSubStr, pcBound1, pcBound2, pnStartingAt, pcDirection, pCaseSensitive)
		nLenBound2 = Q(pcBound2).NumberOfChars()
		nLenSubStr = Q(pcSubStr).NumberOfChars()

		n2 = n1 + nLenSubStr + nLenSubStr - 2

		#< @FunctionAlternativeForm
	
		def FindNthSubStringBetweenAsSectionsSDCSIB(n, pcSubStr, pcBound1, pcBound2, pnStartingAt, pcDirection, pCaseSensitive)
			return This.FindNthSubStringBetweenSDCSIBZZ(n, pcSubStr, pcBound1, pcBound2, pnStartingAt, pcDirection, pCaseSensitive)

		#>

	#-- WITHOUT CASESENSITIVITY

	def FindNthSubStringBetweenSDIBZZ(n, pcSubStr, pcBound1, pcBound2, pnStartingAt, pcDirection)
		return This.FindNthSubStringBetweenSDCSIBZZ(n, pcSubStr, pcBound1, pcBound2, pnStartingAt, pcDirection, TRUE)

		#< @FunctionAlternativeForm
	
		def FindNthSubStringBetweenAsSectionsSDIB(n, pcSubStr, pcBound1, pcBound2, pnStartingAt, pcDirection)
			return This.FindNthSubStringBetweenSDIBZZ(n, pcSubStr, pcBound1, pcBound2, pnStartingAt, pcDirection)

		#>

	   #-----------------------------------------------------------------------------------------------#
	  #  FINDING NTH OCCURRENCE OF A SUBSTRING BOUNDED BY TWO OTHER SUBSTRINGSS STARTING AT A GIVEN   #
	 #  POSITION, GOING IN A GIVEN DIRECTION, INCLUDING BOUNDS, AND RETURNING POSITIONS AS SECTIONS  #
	#-----------------------------------------------------------------------------------------------#

	def FindNthSubStringBoundedBySDCSIBZZ(n, pcSubStr, pacBounds, pnStartingAt, pcDirection, pCaseSensitive)
		return This.FindNthSubStringBoundedBySDCSIBZZ(n, pcSubStr, pacBounds, pnStartingAt, pcDirection, pCaseSensitive)

		#< @FunctionAlternativeForm

		def FindNthSubStringBoundedByAsSectionsSDCSIB(n, pcSubStr, pacBounds, pnStartingAt, pcDirection, pCaseSensitive)
			return This.FindNthSubStringBoundedBySDCSIBZZ(n, pcSubStr, pacBounds, pnStartingAt, pcDirection, pCaseSensitive)

		#>

	#-- WITHOUT CASESENSITIVTY

	def FindNthSubStringBoundedBySDIBZZ(n, pcSubStr, pacBounds, pnStartingAt, pcDirection)
		return This.FindNthSubStringBoundedBySDCSIBZZ(n, pcSubStr, pacBounds, pnStartingAt, pcDirection, TRUE)

		#< @FunctionAlternativeForm

		def FindNthSubStringBoundedByAsSectionsSDIB(n, pcSubStr, pacBounds, pnStartingAt, pcDirection)
			return This.FindNthSubStringBoundedBySDIBZZ(n, pcSubStr, pacBounds, pnStartingAt, pcDirection)

		#>

	   #-------------------------------------------------------#
	  #  FINDING FIRST OCCURRENCE OF A SUBSTRING BOUNDED BY   #
	 #  TWO OTHER SUBSTRINGS AND RETURNING THEM AS SECTIONS  #
	#=======================================================#

	def FindFirstSubStringBetweenCSZZ(pcSubStr, pcBound1, pcBound2, pCaseSensitive)
		return This.FindNthSubStringBetweenCSZZ(1, pcSubStr, pcBound1, pcBound2, pCaseSensitive)

		#< @FunctionAlternativeForm
	
		def FindFirstSubStringBetweenAsSectionsCS(pcSubStr, pcBound1, pcBound2, pCaseSensitive)
			return This.FindFirstSubStringBetweenCSZZ(pcSubStr, pcBound1, pcBound2, pCaseSensitive)

		#>

	#-- WITHOUT CASESENSITIVITY

	def FindFirstSubStringBetweenZZ(pcSubStr, pcBound1, pcBound2)
		return This.FindFirstSubStringBetweenCSZZ(pcSubStr, pcBound1, pcBound2, TRUE)

		#< @FunctionAlternativeForm
	
		def FindFirstSubStringBetweenAsSections(pcSubStr, pcBound1, pcBound2)
			return This.FindFirstSubStringBetweenZZ(pcSubStr, pcBound1, pcBound2)

		#>

	   #-------------------------------------------------------#
	  #  FINDING FIRST OCCURRENCE OF A SUBSTRING BOUNDED BY   #
	 #  TWO OTHER SUBSTRINGS AND RETURNING THEM AS SECTIONS  #
	#-------------------------------------------------------#

	def FindFirstSubStringBoundedByCSZZ(pcSubStr, pacBounds, pCaseSensitive)
		return This.FindNthSubStringBoundedByCSZZ(1, pcSubStr, pacBounds, pCaseSensitive)

		#< @FunctionAlternativeForm

		def FindFirstSubStringBoundedByAsSectionsCS(pcSubStr, pacBounds, pCaseSensitive)
			return This.FindFirstSubStringBoundedByCSZZ(pcSubStr, pacBounds, pCaseSensitive)

		#>

	#-- WITHOUT CASESENSITIVITY

	def FindFirstSubStringBoundedByZZ(pcSubStr, pacBounds)
		return This.FindFirstSubStringBoundedByCSZZ(pcSubStr, pacBounds, TRUE)

		#< @FunctionAlternativeForm

		def FindFirstSubStringBoundedByAsSections(pcSubStr, pacBounds)
			return This.FindFirstSubStringBoundedByCSZZ(pcSubStr, pacBounds)

		#>

	  #-----------------------------------------------------------------------------------------#
	 #  FINDING FIRST OCCURRENCE OF A SUBSTRING BETWEEN TWO OTHER SUBSTRINGS INCLUDING BOUNDS  #
	#=========================================================================================#

	def FindFirstSubStringBetweenCSIB(pcSubStr, pcBound1, pcBound2, pCaseSensitive)
		return This.FindNthSubStringBetweenCSIB(1, pcSubStr, pcBound1, pcBound2, pCaseSensitive)

		#< @FunctionAlternativeForms
	
		def FindFirstSubStringBetweenCSIBZ(pcSubStr, pcBound1, pcBound2, pCaseSensitive)
			return This.FindFirstSubStringBetweenCSIB(pcSubStr, pcBound1, pcBound2, pCaseSensitive)

		#>

	#-- WITHOUT CASESENSITIVE

	def FindFirstSubStringBetweenIB(pcSubStr, pcBound1, pcBound2)
		return This.FindFirstSubStringBetweenCSIB(pcSubStr, pcBound1, pcBound2, TRUE)

		#< @FunctionAlternativeForms
	
		def FindFirstSubStringBetweenIBZ(pcSubStr, pcBound1, pcBound2)
			return This.FindFirstSubStringBetweenIB(pcSubStr, pcBound1, pcBound2)

		#>

	  #--------------------------------------------------------------------------------------------#
	 #  FINDING FIRST OCCURRENCE OF A SUBSTRING BOUNDED BY TWO OTHER SUBSTRINGS INCLUDING BOUNDS  #
	#--------------------------------------------------------------------------------------------#

	def FindFirstSubStringBoundedByCSIB(pcSubStr, pacBounds, pCaseSensitive)
		return This.FindNthSubStringBoundedByCSIB(1, pcSubStr, pacBounds, pCaseSensitive)

		#< @FunctionAlternativeForms

		def FindFirstSubStringBoundedByCSIBZ(pcSubStr, pacBounds, pCaseSensitive)
			return This.FindFirstSubStringBoundedByCSIB(pcSubStr, pacBound, pCaseSensitives)

		#>

	#-- WITHOUT CASESENSITIVE

	def FindFirstSubStringBoundedByIB(pcSubStr, pacBounds)
		return This.FindFirstSubStringBoundedByCSIB(pcSubStr, pacBounds, pCaseSensitive)

		#< @FunctionAlternativeForms

		def FindFirstSubStringBoundedByIBZ(pcSubStr, pacBounds)
			return This.FindFirstSubStringBoundedByIB(pcSubStr, pacBound)

		#>

	   #-------------------------------------------------------------------------#
	  #  FINDING FIRST OCCURRENCE OF A SUBSTRING BETWEEN TWO OTHER SUBSTRINGS   #
	 #  INCLUDING BOUNDS AND RETURNING THEIR POSITIONS AS SECTIONS             #
	#=========================================================================#

	def FindFirstSubStringBetweenCSIBZZ(pcSubStr, pcBound1, pcBound2, pCaseSensitive)
		return This.FindNthSubStringBetweenCSIBZZ(1, pcSubStr, pcBound1, pcBound2, pCaseSensitive)

		#< @FunctionAlternativeForm
	
		def FindFirstSubStringBetweenAsSectionsCSIB(pcSubStr, pcBound1, pcBound2, pCaseSensitive)
			return This.FindFirstSubStringBetweenCSIBZZ(pcSubStr, pcBound1, pcBound2, pCaseSensitive)

		#>

	#-- WITHOUT CASESENSITIVITY

	def FindFirstSubStringBetweenIBZZ(pcSubStr, pcBound1, pcBound2)
		return This.FindFirstSubStringBetweenCSIBZZ(pcSubStr, pcBound1, pcBound2, TRUE)

		#< @FunctionAlternativeForm
	
		def FindFirstSubStringBetweenAsSectionsIB(pcSubStr, pcBound1, pcBound2)
			return This.FindFirstSubStringBetweenIBZZ(pcSubStr, pcBound1, pcBound2)

		#>

	   #-------------------------------------------------------------------------#
	  #  FINDING FIRST OCCURRENCE OF A SUBSTRING BOUNDED BY TWO OTHER           #
	 #  SUBSTRINGS INCLUDING BOUNDS AND RETURNING THEIR POSITIONS AS SECTIONS  #
	#-------------------------------------------------------------------------#

	def FindFirstSubStringBoundedByCSIBZZ(pcSubStr, pacBounds, pCaseSensitive)
		return This.FindNthSubStringBoundedByCSIBZZ(1, pcSubStr, pacBounds, pCaseSensitive)

		#< @FunctionAlternativeForm

		def FindFirstSubStringBoundedByAsSectionsCSIB(pcSubStr, pacBounds, pCaseSensitive)
			return This.FindFirstSubStringBoundedByCSIBZZ(pcSubStr, pacBounds, pCaseSensitive)

		#>

	#-- WITHOUT CASESENSITIVITY

	def FindFirstSubStringBoundedByIBZZ(pcSubStr, pacBounds)
		return This.FindFirstSubStringBoundedByCSIBZZ(pcSubStr, pacBounds, TRUE)

		#< @FunctionAlternativeForm

		def FindFirstSubStringBoundedByAsSectionsIB(pcSubStr, pacBounds)
			return This.FindFirstSubStringBoundedByIBZZ(pcSubStr, pacBounds)

		#>

	   #------------------------------------------------------#
	  #  FINDING FIRST OCCURRENCE OF A SUBSTRING BOUNDED BY  #
	 #  TWO OTHER SUBSTRINGS STARTING AT A GIVEN POSITION   #
	#------------------------------------------------------#

	def FindFirstSubStringBoundedBySCS(pcSubStr, pacBounds, pnStartingAt, pCaseSensitive)
		return This.FindNthSubStringBoundedBySCS(1, pcSubStr, pacBounds, pnStartingAt, pCaseSensitive)

		#< @FunctionAlternativeForm

		def FindFirstSubStringBoundedBySCSZ(pcSubStr, pacBounds, pnStartingAt, pCaseSensitive)
			return This.FindFirstSubStringBoundedBySCS(pcSubStr, pacBounds, pnStartingAt, pCaseSensitive)

		#>

	#-- WITHOUT CASESENSITIVITY

	def FindFirstSubStringBoundedByS(pcSubStr, pacBounds, pnStartingAt)
		return This.FindFirstSubStringBoundedBySCS(pcSubStr, pacBounds, pnStartingAt, TRUE)

		#< @FunctionAlternativeForm

		def FindFirstSubStringBoundedBySZ(pcSubStr, pacBounds, pnStartingAt)
			return This.FindFirstSubStringBoundedByS(pcSubStr, pacBounds, pnStartingAt)

		#>

	   #------------------------------------------------------------------------#
	  #  FINDING FIRST OCCURRENCE OF A SUBSTRING BETWEEN TWO OTHER SUBSTRINGS  #
	 #  STARTING AT A GIVEN POSITION AND RETURNING POSITIONS AS SECTIONS      #
	#========================================================================#

	def FindFirstSubStringBetweenSCSZZ(pcSubStr, pcBound1, pcBound2, pnStartingAt, pCaseSensitive)
		return This.FindNthSubStringBetweenSCSZZ(1, pcSubStr, pcBound1, pcBound2, pnStartingAt, pCaseSensitive)

		#< @FunctionAlternativeForm
	
		def FindFirstSubStringBetweenAsSectionsSCS(pcSubStr, pcBound1, pcBound2, pnStartingAt, pCaseSensitive)
			return This.FindFirstSubStringBetweenSCSZZ(pcSubStr, pcBound1, pcBound2, pnStartingAt, pCaseSensitive)

		#>

	#-- WITHOUT CASESENSIVITY

	def FindFirstSubStringBetweenSZZ(pcSubStr, pcBound1, pcBound2, pnStartingAt)
		return This.FindFirstSubStringBetweenSCSZZ(pcSubStr, pcBound1, pcBound2, pnStartingAt, TRUE)

		#< @FunctionAlternativeForm
	
		def FindFirstSubStringBetweenAsSectionsS(pcSubStr, pcBound1, pcBound2, pnStartingAt)
			return This.FindFirstSubStringBetweenSZZ(pcSubStr, pcBound1, pcBound2, pnStartingAt)

		#>

	   #---------------------------------------------------------------------------#
	  #  FINDING FIRST OCCURRENCE OF A SUBSTRING BOUNDED BY TWO OTHER SUBSTRINGS  #
	 #  STARTING AT A GIVEN POSITION AND RETURNING POSITIONS AS SECTIONS         #
	#---------------------------------------------------------------------------#

	def FindFirstSubStringBoundedBySCSZZ(pcSubStr, pacBounds, pnStartingAt, pCaseSensitive)
		return This.FindNthSubStringBoundedBySCSZZ(1, pcSubStr, pacBounds, pnStartingAt, pCaseSensitive)

		#< @FunctionAlternativeForm

		def FindFirstSubStringBoundedByAsSectionsSCS(pcSubStr, pacBounds, pnStartingAt, pCaseSensitive)
			return This.FindFirstSubStringBoundedBySCSZZ(pcSubStr, pacBounds, pnStartingAt, pCaseSensitive)

		#>

	#-- WITHOUT CASESENSITIVITY

	def FindFirstSubStringBoundedBySZZ(pcSubStr, pacBounds, pnStartingAt)
		return This.FindFirstSubStringBoundedBySCSZZ(pcSubStr, pacBounds, pnStartingAt, TRUE)
	
		#< @FunctionAlternativeForm

		def FindFirstSubStringBoundedByAsSectionsS(pcSubStr, pacBounds, pnStartingAt)
			return This.FindFirstSubStringBoundedBySZZ(pcSubStr, pacBounds, pnStartingAt)

		#>

	   #---------------------------------------------------------------#
	  #  FINDING FIRST OCCURRENCE OF A SUBSTRING BETWEEN TWO OTHER    #
	 #  SUBSTRINGSSTARTING AT A GIVEN POSITION AND INCLUDING BOUNDS  #
	#===============================================================#

	def FindFirstSubStringBetweenSCSIB(pcSubStr, pcBound1, pcBound2, pnStartingAt, pCaseSensitive)
		return This.FindNthSubStringBetweenSCSIB(1, pcSubStr, pcBound1, pcBound2, pnStartingAt, pCaseSensitive)

		#< @FunctionAlternativeForm
	
		def FindFirstSubStringBetweenSCSIBZ(pcSubStr, pcBound1, pcBound2, pnStartingAt, pCaseSensitive)
			return This.FindFirstSubStringBetweenSCSIB(pcSubStr, pcBound1, pcBound2, pnStartingAt, pCaseSensitive)

		#>

	#-- WITHOUT CASESENSITIVITY

	def FindFirstSubStringBetweenSIB(pcSubStr, pcBound1, pcBound2, pnStartingAt)
		return This.FindFirstSubStringBetweenSCSIB(pcSubStr, pcBound1, pcBound2, pnStartingAt, pCaseSensitive)

		#< @FunctionAlternativeForm
	
		def FindFirstSubStringBetweenSIBZ(pcSubStr, pcBound1, pcBound2, pnStartingAt)
			return This.FindFirstSubStringBetweenSIB(pcSubStr, pcBound1, pcBound2, pnStartingAt)

		#>

	   #----------------------------------------------------------------#
	  #  FINDING FIRST OCCURRENCE OF A SUBSTRING BOUNDED BY TWO OTHER  #
	 #  SUBSTRINGSSTARTING AT A GIVEN POSITION AND INCLUDING BOUNDS   #
	#----------------------------------------------------------------#

	def FindFirstSubStringBoundedBySCSIB(pcSubStr, pacBounds, pnStartingAt, pCaseSensitive)
		return This.NthFirstSubStringBoundedBySCSIB(1, pcSubStr, pacBounds, pnStartingAt, pCaseSensitive)

		#< @FunctionAlternativeForm

		def FindFirstSubStringBoundedBySCSIBZ(pcSubStr, pacBounds, pnStartingAt, pCaseSensitive)
			return This.FindFirstSubStringBoundedBySCSIB(pcSubStr, pacBounds, pnStartingAt, pCaseSensitive)

		#>

	#-- WITHOUT CASESENSITIVITY

	def FindFirstSubStringBoundedBySIB(pcSubStr, pacBounds, pnStartingAt)
		return This.FindFirstSubStringBoundedBySCSIB(pcSubStr, pacBounds, pnStartingAt, TRUE)

		#< @FunctionAlternativeForm

		def FindFirstSubStringBoundedBySIBZ(pcSubStr, pacBounds, pnStartingAt)
			return This.FindFirstSubStringBoundedBySIB(pcSubStr, pacBounds, pnStartingAt)

		#>

	   #-----------------------------------------------------------------------------------#
	  #  FINDING FIRST OCCURRENCE OF A SUBSTRING BETWEEN TWO OTHER SUBSTRINGS STARTING    #
	 #  AT A GIVEN POSITION, INCLUDING BOUNDS, AND RETURNING THE POSITIONS AS SECTIONS   #
	#===================================================================================#

	def FindFirstSubStringBetweenSCSIBZZ(pcSubStr, pcBound1, pcBound2, pnStartingAt, pCaseSensitive)
		return This.FindNthSubStringBetweenSCSIBZZ(1, pcSubStr, pcBound1, pcBound2, pnStartingAt, pCaseSensitive)

		#< @FunctionAlternativeForm

		def FindFirstSubStringBetweenAsSectionsSCSIB(pcSubStr, pcBound1, pcBound2, pnStartingAt, pCaseSensitive)
			return This.FindFirstSubStringBetweenSCSIBZZ(pcSubStr, pcBound1, pcBound2, pnStartingAt, pCaseSensitive)

		#>

	#-- WITHOUT CASESENSITIVITY

	def FindFirstSubStringBetweenSIBZZ(pcSubStr, pcBound1, pcBound2, pnStartingAt)
		return This.FindFirstSubStringBetweenSCSIBZZ(pcSubStr, pcBound1, pcBound2, pnStartingAt, TRUE)

		#< @FunctionAlternativeForm

		def FindFirstSubStringBetweenAsSectionsSIB(pcSubStr, pcBound1, pcBound2, pnStartingAt)
			return This.FindFirstSubStringBetweenSIBZZ(pcSubStr, pcBound1, pcBound2, pnStartingAt)

		#>

	   #-------------------------------------------------------------------------------------#
	  #  FINDING FIRST OCCURRENCE OF A SUBSTRING BOUNDED BY TWO OTHER SUBSTRINGS STARTING   #
	 #  AT A GIVEN POSITION, INCLUDING BOUNDS, AND RETURNING THE POSITIONS AS SECTIONS     #
	#-------------------------------------------------------------------------------------#

	def FindFirstSubStringBoundedBySCSIBZZ(pcSubStr, pacBounds, pnStartingAt, pCaseSensitive)
		return This.FindNthSubStringBoundedBySCSIBZZ(1, pcSubStr, pacBounds, pnStartingAt, pCaseSensitive)

		def FindFirstSubStringBoundedByAsSectionsSCSIB(pcSubStr, pacBounds, pnStartingAt, pCaseSensitive)
			return This.FindFirstSubStringBoundedBySCSIBZZ(pcSubStr, pacBounds, pnStartingAt, pCaseSensitive)

	#-- WITHOUT CASESENSITIVITY

	def FindFirstSubStringBoundedBySIBZZ(pcSubStr, pacBounds, pnStartingAt)
		return This.FindNthSubStringBoundedBySCSIBZZ(1, pcSubStr, pacBounds, pnStartingAt, TRUE)

		def FindFirstSubStringBoundedByAsSectionsSIB(pcSubStr, pacBounds, pnStartingAt)
			return This.FindFirstSubStringBoundedBySIBZZ(pcSubStr, pacBounds, pnStartingAt)


	   #----------------------------------------------------#
	  #  FINDING FIRST OCCURRENCE OF A SUBSTRING BETWEEN   #
	 #  TWO OTHER SUBSTRINGS GOING IN A GIVEN DIRECTION   #
	#====================================================#

	def FindFirstSubStringBetweenDCS(pcSubStr, pcBound1, pcBound2, pcDirection, pCaseSensitive)
		return This.FindNthSubStringBetweenDCS(1, pcSubStr, pcBound1, pcBound2, pcDirection, pCaseSensitive)

		#< @FunctionAlternativeForm
	
		def FindFirstSubStringBetweenDCSZ(pcSubStr, pcBound1, pcBound2, pcDirection, pCaseSensitive)
			return This.FindFirstSubStringBetweenDCS(pcSubStr, pcBound1, pcBound2, pcDirection, pCaseSensitive)

		#>

	#-- WITHOUT CASESENSITIVITY

	def FindFirstSubStringBetweenD(pcSubStr, pcBound1, pcBound2, pcDirection)
		return This.FindFirstSubStringBetweenDCS(pcSubStr, pcBound1, pcBound2, pcDirection, TRUE)

		#< @FunctionAlternativeForm
	
		def FindFirstSubStringBetweenDZ(pcSubStr, pcBound1, pcBound2, pcDirection)
			return This.FindFirstSubStringBetweenD(pcSubStr, pcBound1, pcBound2, pcDirection)

		#>

	   #------------------------------------------------------#
	  #  FINDING FIRST OCCURRENCE OF A SUBSTRING BOUNDED BY  #
	 #  TWO OTHER SUBSTRINGS GOING IN A GIVEN DIRECTION     #
	#------------------------------------------------------#

	def FindFirstSubStringBoundedByDCS(pcSubStr, pacBounds, pcDirection, pCaseSensitive)
		return This.FindNthSubStringBoundedByDCS(1, pcSubStr, pacBounds, pcDirection, pCaseSensitive)

		def FindFirstSubStringBoundedByDCSZ(pcSubStr, pacBounds, pcDirection, pCaseSensitive)
			return This.FindFirstSubStringBoundedByDCS(pcSubStr, pacBounds, pcDirection, pCaseSensitive)

	#-- WITHOUT CASESENSITIVITY

	def FindFirstSubStringBoundedByD(pcSubStr, pacBounds, pcDirection)
		return This.FindFirstSubStringBoundedByDCS(pcSubStr, pacBounds, pcDirection, TRUE)

		def FindFirstSubStringBoundedByDZ(pcSubStr, pacBounds, pcDirection)
			return This.FindFirstSubStringBoundedByD(pcSubStr, pacBounds, pcDirection)

	   #------------------------------------------------------------------------#
	  #  FINDING FIRST OCCURRENCE OF A SUBSTRING BETWEEB TWO OTHER SUBSTRINGS  #
	 #  GOING INA GIVEN DIRECTION AND RETURNING POSITIONS AS SECTIONS         #
	#========================================================================#

	def FindFirstSubStringBetweenDCSZZ(pcSubStr, pcBound1, pcBound2, pcDirection, pCaseSensitive)
		return This.FindNthSubStringBetweenDCSZZ(1, pcSubStr, pcBound1, pcBound2, pcDirection, pCaseSensitive)

		#< @FunctionAlternativeForm
	
		def FindFirstSubStringBetweenAsSectionsDCS(pcSubStr, pcBound1, pcBound2, pcDirection, pCaseSensitive)
			return This.FindFirstSubStringBetweenDCSZZ(pcSubStr, pcBound1, pcBound2, pcDirection, pCaseSensitive)

		#>

	#-- WITHOUT CASESENSITIVITY

	def FindFirstSubStringBetweenDZZ(pcSubStr, pcBound1, pcBound2, pcDirection)
		return This.FindFirstSubStringBetweenDCSZZ(pcSubStr, pcBound1, pcBound2, pcDirection, TRUE)

		#< @FunctionAlternativeForm
	
		def FindFirstSubStringBetweenAsSectionsD(pcSubStr, pcBound1, pcBound2, pcDirection)
			return This.FindFirstSubStringBetweenDZZ(pcSubStr, pcBound1, pcBound2, pcDirection)

		#>

	   #---------------------------------------------------------------------------#
	  #  FINDING FIRST OCCURRENCE OF A SUBSTRING BOUNDED BY TWO OTHER SUBSTRINGS  #
	 #  GOING INA GIVEN DIRECTION AND RETURNING POSITIONS AS SECTIONS            #
	#---------------------------------------------------------------------------#

	def FindFirstSubStringBoundedByDCSZZ(pcSubStr, pacBounds, pcDirection, pCaseSensitive)
		return This.FindNthSubStringBoundedByDCSZZ(1, pcSubStr, pacBounds, pcDirection, pCaseSensitive)

		def FindFirstSubStringBoundedByAsSectionsDCS(pcSubStr, pacBounds, pcDirection, pCaseSensitive)
			return This.FindFirstSubStringBoundedByDCSZZ(pcSubStr, pacBounds, pcDirection, pCaseSensitive)

	#-- WITHOUT CASESENSITIVITY

	def FindFirstSubStringBoundedByDZZ(pcSubStr, pacBounds, pcDirection)
		return This.FindFirstSubStringBoundedByDCSZZ(pcSubStr, pacBounds, pcDirection, TRUE)

		def FindFirstSubStringBoundedByAsSectionsD(pcSubStr, pacBounds, pcDirection)
			return This.FindFirstSubStringBoundedByDZZ(pcSubStr, pacBounds, pcDirection)

	   #--------------------------------------------------------------#
	  #  FINDING FIRST OCCURRENCE OF A SUBSTRING BETWEEN TWO OTHER   #
	 #  SUBSTRINGS GOING IN A GIVEN DIRECTION AND INCLUDING BOUNDS  #
	#==============================================================#

	def FindFirstSubStringBetweenDCSIB(pcSubStr, pcBound1, pcBound2, pcDirection, pCaseSensitive)
		return This.FindNthSubStringBetweenDCSIB(1, pcSubStr, pcBound1, pcBound2, pcDirection, pCaseSensitive)

		#< @FunctionAlternativeForm
	
		def FindFirstSubStringBetweenDCSIBZ(pcSubStr, pcBound1, pcBound2, pcDirection, pCaseSensitive)
			return This.FindFirstSubStringBetweenDCSIB(pcSubStr, pcBound1, pcBound2, pcDirection, pCaseSensitive)

		#>

	#-- WITHOUT CASESENSITIVITY

	def FindFirstSubStringBetweenDIB(pcSubStr, pcBound1, pcBound2, pcDirection)
		return Ths.FindFirstSubStringBetweenDCSIB(pcSubStr, pcBound1, pcBound2, pcDirection, TRUE)

		#< @FunctionAlternativeForm
	
		def FindFirstSubStringBetweenDIBZ(pcSubStr, pcBound1, pcBound2, pcDirection)
			return This.FindFirstSubStringBetweenDIB(pcSubStr, pcBound1, pcBound2, pcDirection)

		#>

	   #----------------------------------------------------------------#
	  #  FINDING FIRST OCCURRENCE OF A SUBSTRING BOUNDED BY TWO OTHER  #
	 #  SUBSTRINGS GOING IN A GIVEN DIRECTION AND INCLUDING BOUNDS    #
	#----------------------------------------------------------------#

	def FindFirstSubStringBoundedByDCSIB(pcSubStr, pacBounds, pcDirection, pCaseSensitive)
		return This.FindNthSubStringBoundedByDCSIB(1, pcSubStr, pacBounds, pcDirection, pCaseSensitive)

		def FindFirstSubStringBoundedByDCSIBZ(pcSubStr, pacBounds, pcDirection, pCaseSensitive)
			return This.FindFirstSubStringBoundedByDCSIB(pcSubStr, pacBounds, pcDirection, pCaseSensitive)

	#-- WITHOUT CASESENSITIVITY

	def FindFirstSubStringBoundedByDIB(pcSubStr, pacBounds, pcDirection)
		return This.FindFirstSubStringBoundedByDCSIB(pcSubStr, pacBounds, pcDirection, TRUE)

		def FindFirstSubStringBoundedByDIBZ(pcSubStr, pacBounds, pcDirection)
			return This.FindFirstSubStringBoundedByDIB(pcSubStr, pacBounds, pcDirection)

	   #------------------------------------------------------------------------------#
	  #  FINDING FIRST OCCURRENCE OF A SUBSTRING BETWEEN TWO OTHER SUBSTRINGS GOING  #
	 #  IN A GIVENDIRECTION, INCLUDING BOUNDS, AND RETURNING POSITIONS AS SECTIONS  # 
	#==============================================================================#

	def FindFirstSubStringBetweenDCSIBZZ(pcSubStr, pcBound1, pcBound2, pcDirection, pCaseSensitive)
		return This.FindNthSubStringBetweenDCSIBZZ(1, pcSubStr, pcBound1, pcBound2, pcDirection, pCaseSensitive)

		#< @FunctionAlternativeForm

		def FindFirstSubStringBetweenAsSectionsDCSIB(pcSubStr, pcBound1, pcBound2, pcDirection, pCaseSensitive)
			return This.FindFirstSubStringBetweenDCSIBZZ(pcSubStr, pcBound1, pcBound2, pcDirection, pCaseSensitive)

		#>

	#-- WITHOUT CASESENSITIVITY

	def FindFirstSubStringBetweenDIBZZ(pcSubStr, pcBound1, pcBound2, pcDirection)
		return This.FindFirstSubStringBetweenDCSIBZZ(pcSubStr, pcBound1, pcBound2, pcDirection, pCaseSensitive)

		#< @FunctionAlternativeForm

		def FindFirstSubStringBetweenAsSectionsDIB(pcSubStr, pcBound1, pcBound2, pcDirection)
			return This.FindFirstSubStringBetweenDIBZZ(pcSubStr, pcBound1, pcBound2, pcDirection)

		#>
 
	   #---------------------------------------------------------------------------------#
	  #  FINDING FIRST OCCURRENCE OF A SUBSTRING BOUNDED BY TWO OTHER SUBSTRINGS GOING  #
	 #  IN A GIVENDIRECTION, INCLUDING BOUNDS, AND RETURNING POSITIONS AS SECTIONS     # 
	#---------------------------------------------------------------------------------#

	def FindFirstSubStringBoundedByDCSIBZZ(pcSubStr, pacBounds, pcDirection, pCaseSensitive)
		return This.FindNthSubStringBoundedByDCSIBZZ(1, pcSubStr, pacBounds, pcDirection, pCaseSensitive)

		def FindFirstSubStringBoundedByAsSectionsDCSIB(pcSubStr, pacBounds, pcDirection, pCaseSensitive)
			return This.FindBoundedByDCSIBZZ(pcSubStr, pacBounds, pcDirection, pCaseSensitive)

	#-- WITHOUT CASESENSITIVITY

	def FindFirstSubStringBoundedByDIBZZ(pcSubStr, pacBounds, pcDirection)
		return This.FindNthSubStringBoundedByDCSIBZZ(1, pcSubStr, pacBounds, pcDirection, TRUE)

		def FindFirstSubStringBoundedByAsSectionsDIB(pcSubStr, pacBounds, pcDirection)
			return This.FindBoundedByDIBZZ(pcSubStr, pacBounds, pcDirection)

	   #------------------------------------------------------------------------#
	  #  FINDING FIRST OCCURRENCE OF A SUBSTRING BETWEEB TWO OTHER SUBSTRINGS  #
	 #  STARTING AT A GIVEN POSITION AND GOING IN A GIVEN DIRECTION           #
	#========================================================================#

	def FindFirstSubStringBetweenSDCS(pcSubStr, pcBound1, pcBound2, pnStartingAt, pcDirection, pCaseSensitive)
		return This.FindNthSubStringBetweenSDCS(1, pcSubStr, pcBound1, pcBound2, pnStartingAt, pcDirection, pCaseSensitive)

		#< @FunctionAlternativeForm
	
		def FindFirstSubStringBetweenSDCSZ(pcSubStr, pcBound1, pcBound2, pnStartingAt, pcDirection, pCaseSensitive)
			return This.FindFirstSubStringBetweenSDCS(pcSubStr, pcBound1, pcBound2, pnStartingAt, pcDirection, pCaseSensitive)

		#>

	#-- WITHOUT CASESENSITIVITY

	def FindFirstSubStringBetweenSD(pcSubStr, pcBound1, pcBound2, pnStartingAt, pcDirection)
		return This.FindFirstSubStringBetweenSDCS(pcSubStr, pcBound1, pcBound2, pnStartingAt, pcDirection, TRUE)

		#< @FunctionAlternativeForm
	
		def FindFirstSubStringBetweenSDZ(pcSubStr, pcBound1, pcBound2, pnStartingAt, pcDirection)
			return This.FindFirstSubStringBetweenSD(pcSubStr, pcBound1, pcBound2, pnStartingAt, pcDirection)

		#>

	   #---------------------------------------------------------------------------#
	  #  FINDING FIRST OCCURRENCE OF A SUBSTRING BOUNDED BY TWO OTHER SUBSTRINGS  #
	 #  STARTING AT A GIVEN POSITION AND GOING IN A GIVEN DIRECTION              #
	#---------------------------------------------------------------------------#

	def FindFirstSubStringBoundedBySDCS(pcSubStr, pacBounds, pnStartingAt, pcDirection, pCaseSensitive)
		return This.FindNthSubStringBoundedBySDCS(1, pcSubStr, pacBounds, pnStartingAt, pcDirection, pCaseSensitive)

		def FindFirstSubStringBoundedBySDCSZ(pcSubStr, pacBounds, pnStartingAt, pcDirection, pCaseSensitive)
			return This.FindFirstSubStringBoundedBySDCS(pcSubStr, pacBounds, pnStartingAt, pcDirection, pCaseSensitive)

	#-- WITHOUT CASESENSITIVITY

	def FindFirstSubStringBoundedBySD(pcSubStr, pacBounds, pnStartingAt, pcDirection)
		return This.FindFirstSubStringBoundedBySDCS(pcSubStr, pacBounds, pnStartingAt, pcDirection, TRUE)

		def FindFirstSubStringBoundedBySDZ(pcSubStr, pacBounds, pnStartingAt, pcDirection)
			return This.FindFirstSubStringBoundedBySD(pcSubStr, pacBounds, pnStartingAt, pcDirection)

	   #----------------------------------------------------------------------------------------#
	  #  FINDING FIRST OCCURRENCE OF A SUBSTRING BETWEEN TWO OTHER SUBSTRINGSS STARTING        #
	 #  AT A GIVEN POSITION, GOING IN A GIVEN DIRECTION, AND RETURNING POSITIONS AS SECTIONS  #
	#========================================================================================#

	def FindFirstSubStringBetweenSDCSZZ(pcSubStr, pcBound1, pcBound2, pnStartingAt, pcDirection, pCaseSensitive)
		return This.FindFirstSubStringBetweenSDCSZZ(pcSubStr, pcBound1, pcBound2, pnStartingAt, pcDirection, pCaseSensitive)


		#< @FunctionAlternativeForms
	
		def FindFirstSubStringBetweenAsSection_SDCS(pcSubStr, pcBound1, pcBound2, pnStartingAt, pcDirection, pCaseSensitive)
			return This.FindFirstSubStringBetweenSDCSZZ(pcSubStr, pcBound1, pcBound2, pnStartingAt, pcDirection, pCaseSensitive)

		#>

	#-- WITHOUT CASESENSITIVITY

	def FindFirstSubStringBetweenSDZZ(pcSubStr, pcBound1, pcBound2, pnStartingAt, pcDirection)
		return This.FindFirstSubStringBetweenSDCSZZ(pcSubStr, pcBound1, pcBound2, pnStartingAt, pcDirection, TRUE)

		#< @FunctionAlternativeForms
	
		def FindFirstSubStringBetweenAsSection_SD(pcSubStr, pcBound1, pcBound2, pnStartingAt, pcDirection)
			return This.FindFirstSubStringBetweenSDZZ(pcSubStr, pcBound1, pcBound2, pnStartingAt, pcDirection)

		#>

	   #----------------------------------------------------------------------------------------#
	  #  FINDING FIRST OCCURRENCE OF A SUBSTRING BOUNDED BY TWO OTHER SUBSTRINGSS STARTING     #
	 #  AT A GIVEN POSITION, GOING IN A GIVEN DIRECTION, AND RETURNING POSITIONS AS SECTIONS  #
	#----------------------------------------------------------------------------------------#

	def FindFirstSubStringBoundedBySDCSZZ(pcSubStr, pacBounds, pnStartingAt, pcDirection, pCaseSensitive)
		return This.FindBoundedBySDCSZZ(pcSubStr, pacBounds, pnStartingAt, pcDirection, pCaseSensitive)

		def FindFirstSubStringBoundedByAsSection_SDCS(pcSubStr, pacBounds, pnStartingAt, pcDirection, pCaseSensitive)
			return This.FindFirstSubStringBoundedBySDCSZZ(pcSubStr, pacBounds, pnStartingAt, pcDirection, pCaseSensitive)

	#-- WITHOUT CASESENSITIVITY

	def FindFirstSubStringBoundedBySDZZ(pcSubStr, pacBounds, pnStartingAt, pcDirection)
		return This.FindFirstSubStringBoundedBySDCSZZ(pcSubStr, pacBounds, pnStartingAt, pcDirection, TRUE)

		def FindFirstSubStringBoundedByAsSection_SD(pcSubStr, pacBounds, pnStartingAt, pcDirection)
			return This.FindFirstSubStringBoundedBySDZZ(pcSubStr, pacBounds, pnStartingAt, pcDirection)

	   #----------------------------------------------------------------------------------#
	  #  FINDING FIRST OCCURRENCE OF A SUBSTRING BETWEEN TWO OTHER SUBSTRINGSS STARTING  #
	 #  AT A GIVEN POSITION, GOING IN A GIVEN DIRECTION, AND INCLUDING BOUNDS           #
	#==================================================================================#

	def FindFirstSubStringBetweenSDCSIB(pcSubStr, pcBound1, pcBound2, pnStartingAt, pcDirection, pCaseSensitive)
		return This.FindNthSubStringBetweenSDCSIB(1, pcSubStr, pcBound1, pcBound2, pnStartingAt, pcDirection, pCaseSensitive)

		#< @FunctionAlternativeForm
	
		def FindFirstSubStringBoundedBySDCSIBZ(pcSubStr, pacBounds, pnStartingAt, pcDirection, pCaseSensitive)
			return This.FindFirstSubStringBoundedBySDCSIB(pcSubStr, pacBounds, pnStartingAt, pcDirection, pCaseSensitive)

		#>

	#-- WITHOUT CASESENSITIVITY

	def FindFirstSubStringBetweenSDIB(pcSubStr, pcBound1, pcBound2, pnStartingAt, pcDirection)
		return This.FindFirstSubStringBetweenSDCSIB(pcSubStr, pcBound1, pcBound2, pnStartingAt, pcDirection, TRUE)

		#< @FunctionAlternativeForm

		def FindFirstSubStringBoundedBySDIBZ(pcSubStr, pacBounds, pnStartingAt, pcDirection)
			return This.FindFirstSubStringBoundedBySDIB(pcSubStr, pacBounds, pnStartingAt, pcDirection)

		#>

	   #-------------------------------------------------------------------------------------#
	  #  FINDING FIRST OCCURRENCE OF A SUBSTRING BOUNDED BY TWO OTHER SUBSTRINGSS STARTING  #
	 #  AT A GIVEN POSITION, GOING IN A GIVEN DIRECTION, AND INCLUDING BOUNDS              #
	#-------------------------------------------------------------------------------------#

	def FindFirstSubStringBoundedBySDCSIB(pcSubStr, pacBounds, pnStartingAt, pcDirection, pCaseSensitive)
		return This.FindNthSubStringBoundedBySDCSIB(1, pcSubStr, pacBounds, pnStartingAt, pcDirection, pCaseSensitive)

		def FindFirstSubStringBetweenSDCSIBZ(pcSubStr, pcBound1, pcBound2, pnStartingAt, pcDirection, pCaseSensitive)
			return This.FindFirstSubStringBetweenSDCSIB(pcSubStr, pcBound1, pcBound2, pnStartingAt, pcDirection, pCaseSensitive)

	#-- WITHOUT CASESENSITIVITY

	def FindFirstSubStringBoundedBySDIB(pcSubStr, pacBounds, pnStartingAt, pcDirection)
		return This.FindFirstSubStringBoundedBySDIB(pcSubStr, pacBounds, pnStartingAt, pcDirection)

		def FindFirstSubStringBetweenSDIBZ(pcSubStr, pcBound1, pcBound2, pnStartingAt, pcDirection)
			return This.FindFirstSubStringBetweenSDCSIB(pcSubStr, pcBound1, pcBound2, pnStartingAt, pcDirection)

	   #-----------------------------------------------------------------------------------------------#
	  #  FINDING FIRST OCCURRENCE OF A SUBSTRING BETWEEN TWO OTHER SUBSTRINGSS STARTING AT A GIVEN    #
	 #  POSITION, GOING IN A GIVEN DIRECTION, INCLUDING BOUNDS, AND RETURNING POSITIONS AS SECTIONS  #
	#===============================================================================================#

	def FindFirstSubStringBetweenSDCSIBZZ(pcSubStr, pcBound1, pcBound2, pnStartingAt, pcDirection, pCaseSensitive)
		return This.FindNthSubStringBetweenSDCSIBZZ(1, pcSubStr, pcBound1, pcBound2, pnStartingAt, pcDirection, pCaseSensitive)

		#< @FunctionAlternativeForm
	
		def FindFirstSubStringBetweenAsSectionsSDCSIB(pcSubStr, pcBound1, pcBound2, pnStartingAt, pcDirection, pCaseSensitive)
			return This.FindFirstSubStringBetweenSDCSIBZZ(pcSubStr, pcBound1, pcBound2, pnStartingAt, pcDirection, pCaseSensitive)

		#>

	#-- WITHOUT CASESENSITIVITY

	def FindFirstSubStringBetweenSDIBZZ(pcSubStr, pcBound1, pcBound2, pnStartingAt, pcDirection)
		return This.FindFirstSubStringBetweenSDCSIBZZ(pcSubStr, pcBound1, pcBound2, pnStartingAt, pcDirection, TRUE)

		#< @FunctionAlternativeForm
	
		def FindFirstSubStringBetweenAsSectionsSDIB(pcSubStr, pcBound1, pcBound2, pnStartingAt, pcDirection)
			return This.FindFirstSubStringBetweenSDIBZZ(pcSubStr, pcBound1, pcBound2, pnStartingAt, pcDirection)

		#>

	   #------------------------------------------------------------------------------------------------#
	  #  FINDING FIRST OCCURRENCE OF A SUBSTRING BOUNDED BY TWO OTHER SUBSTRINGSS STARTING AT A GIVEN  #
	 #  POSITION, GOING IN A GIVEN DIRECTION, INCLUDING BOUNDS, AND RETURNING POSITIONS AS SECTIONS   #
	#------------------------------------------------------------------------------------------------#

	def FindFirstSubStringBoundedBySDCSIBZZ(pcSubStr, pacBounds, pnStartingAt, pcDirection, pCaseSensitive)
		return This.FindFirstSubStringBoundedBySDCSIBZZ(pcSubStr, pacBounds, pnStartingAt, pcDirection, pCaseSensitive)

		def FindFirstSubStringBoundedByAsSectionsSDCSIB(pcSubStr, pacBounds, pnStartingAt, pcDirection, pCaseSensitive)
			return This.FindFirstSubStringBoundedBySDCSIBZZ(pcSubStr, pacBounds, pnStartingAt, pcDirection, pCaseSensitive)

	#-- WITHOUT CASESENSITIVITY

	def FindFirstSubStringBoundedBySDIBZZ(pcSubStr, pacBounds, pnStartingAt, pcDirection)
		return This.FindFirstSubStringBoundedBySDCSIBZZ(pcSubStr, pacBounds, pnStartingAt, pcDirection, TRUE)

		def FindFirstSubStringBoundedByAsSectionsSDIB(pcSubStr, pacBounds, pnStartingAt, pcDirection)
			return This.FindFirstSubStringBoundedBySDIBZZ(pcSubStr, pacBounds, pnStartingAt, pcDirection)

	   #------------------------------------------------------#
	  #  FINDING LAST OCCURRENCE OF A SUBSTRING BETWEEN TWO  #
	 #  OTHER SUBSTRINGS AND RETURNING THEM AS SECTIONS     #
	#======================================================#

	def FindLastSubStringBetweenCSZZ(pcSubStr, pcBound1, pcBound2, pCaseSensitive)
		nLast = This.NumberOfOccurrenceBetweenCS(pcSubStr, pcBound1, pcBound2, pCaseSensitive)
		return This.FindNthSubStringBetweenCSZZ(nLast, pcSubStr, pcBound1, pcBound2, pCaseSensitive)

		#< @FunctionAlternativeForm
	
		def FindLastSubStringBetweenAsSectionsCS(pcSubStr, pcBound1, pcBound2, pCaseSensitive)
			return This.FindLastSubStringBetweenCSZZ(pcSubStr, pcBound1, pcBound2, pCaseSensitive)

		#>

	#-- WITHOUT CASESENSITIVITY

	def FindLastSubStringBetweenZZ(pcSubStr, pcBound1, pcBound2)
		return This.FindLastSubStringBetweenCSZZ(pcSubStr, pcBound1, pcBound2, TRUE)

		#< @FunctionAlternativeForm
	
		def FindLastSubStringBetweenAsSections(pcSubStr, pcBound1, pcBound2)
			return This.FindLastSubStringBetweenZZ(pcSubStr, pcBound1, pcBound2)

		#>

	   #-------------------------------------------------------#
	  #  FINDING LAST OCCURRENCE OF A SUBSTRING BOUNDED BY    #
	 #  TWO OTHER SUBSTRINGS AND RETURNING THEM AS SECTIONS  #
	#-------------------------------------------------------#

	def FindLastSubStringBoundedByCSZZ(pcSubStr, pacBounds, pCaseSensitive)
		return This.FindNthSubStringBoundedByCSZZ(nLast, pcSubStr, pacBounds, pCaseSensitive)

		def FindLastSubStringBoundedByAsSectionsCS(pcSubStr, pacBounds, pCaseSensitive)
			return This.FindLastSubStringBoundedByCSZZ(pcSubStr, pacBounds, pCaseSensitive)

	#-- WITHOUT CASESENSITIVITY

	def FindLastSubStringBoundedByZZ(pcSubStr, pacBounds)
		return This.FindLastSubStringBoundedByCSZZ(pcSubStr, pacBounds, TRUE)

		def FindLastSubStringBoundedByAsSections(pcSubStr, pacBounds)
			return This.FindLastSubStringBoundedByZZ(pcSubStr, pacBounds)

	  #----------------------------------------------------------------------------------------#
	 #  FINDING LAST OCCURRENCE OF A SUBSTRING BETWEEN TWO OTHER SUBSTRINGS INCLUDING BOUNDS  #
	#========================================================================================#

	def FindLastSubStringBetweenCSIB(pcSubStr, pcBound1, pcBound2, pCaseSensitive)
		nLast = This.NumberOfOccurrenceBetweenCS(pcSubStr, pcBound1, pcBound2, pCaseSensitive)
		return This.FindNthSubStringBetweenCSIB(nLast, pcSubStr, pcBound1, pcBound2, pCaseSensitive)

		#< @FunctionAlternativeForm
	
		def FindLastSubStringBetweenCSIBZ(pcSubStr, pcBound1, pcBound2, pCaseSensitive)
			return This.FindLastSubStringBetweenCSIB(pcSubStr, pcBound1, pcBound2, pCaseSensitive)

		#>

	#-- WITHOUT CASESENSITIVE

	def FindLastSubStringBetweenIB(pcSubStr, pcBound1, pcBound2)
		return This.FindLastSubStringBetweenCSIB(pcSubStr, pcBound1, pcBound2, TRUE)

		#< @FunctionAlternativeForm
	
		def FindLastSubStringBetweenIBZ(pcSubStr, pcBound1, pcBound2)
			return This.FindLastSubStringBetweenIB(pcSubStr, pcBound1, pcBound2)

		#>

	  #-------------------------------------------------------------------------------------------#
	 #  FINDING LAST OCCURRENCE OF A SUBSTRING BOUNDED BY TWO OTHER SUBSTRINGS INCLUDING BOUNDS  #
	#-------------------------------------------------------------------------------------------#

	def FindLastSubStringBoundedByCSIB(pcSubStr, pacBounds, pCaseSensitive)
		return This.FindNthSubStringBoundedByCSIB(nLast, pcSubStr, pacBounds, pCaseSensitive)

		def FindLastSubStringBoundedByCSIBZ(pcSubStr, pacBounds, pCaseSensitive)
			return This.FindLastSubStringBoundedByCSIB(pcSubStr, pacBound, pCaseSensitives)

	#-- WITHOUT CASESENSITIVE

	def FindLastSubStringBoundedByIB(pcSubStr, pacBounds)
		return This.FindLastSubStringBoundedByCSIB(pcSubStr, pacBounds, TRUE)

		def FindLastSubStringBoundedByIBZ(pcSubStr, pacBounds)
			return This.FindLastSubStringBoundedByIB(pcSubStr, pacBound)

	   #-------------------------------------------------------------------------#
	  #  FINDING LAST OCCURRENCE OF A SUBSTRING BETWEEN TWO OTHER SUBSTRINGS    #
	 #  INCLUDING BOUNDS AND RETURNING THEIR POSITIONS AS SECTIONS             #
	#=========================================================================#

	def FindLastSubStringBetweenCSIBZZ(pcSubStr, pcBound1, pcBound2, pCaseSensitive)
		nLast = This.NumberOfOccurrenceBetweenCS(pcSubStr, pcBound1, pcBound2, pCaseSensitive)
		return This.FindNthSubStringBetweenCSIBZZ(nLast, pcSubStr, pcBound1, pcBound2, pCaseSensitive)

		#< @FunctionAlternativeForm
	
		def FindLastSubStringBetweenAsSectionsCSIB(pcSubStr, pcBound1, pcBound2, pCaseSensitive)
			return This.FindLastSubStringBetweenCSIBZZ(pcSubStr, pcBound1, pcBound2, pCaseSensitive)

		#>

	#-- WITHOUT CASESENSITIVITY

	def FindLastSubStringBetweenIBZZ(pcSubStr, pcBound1, pcBound2)
		return This.FindLastSubStringBetweenCSIBZZ(pcSubStr, pcBound1, pcBound2, TRUE)

		#< @FunctionAlternativeForm
	
		def FindLastSubStringBetweenAsSectionsIB(pcSubStr, pcBound1, pcBound2)
			return This.FindLastSubStringBetweenIBZZ(pcSubStr, pcBound1, pcBound2)

		#>

	   #-------------------------------------------------------------------------#
	  #  FINDING LAST OCCURRENCE OF A SUBSTRING BOUNDED BY TWO OTHER            #
	 #  SUBSTRINGS INCLUDING BOUNDS AND RETURNING THEIR POSITIONS AS SECTIONS  #
	#-------------------------------------------------------------------------#

	def FindLastSubStringBoundedByCSIBZZ(pcSubStr, pacBounds, pCaseSensitive)
		return This.FindNthSubStringBoundedByCSIBZZ(nLast, pcSubStr, pacBounds, pCaseSensitive)

		def FindLastSubStringBoundedByAsSectionsCSIB(pcSubStr, pacBounds, pCaseSensitive)
			return This.FindLastSubStringBoundedByCSIBZZ(pcSubStr, pacBounds, pCaseSensitive)

	#-- WITHOUT CASESENSITIVITY

	def FindLastSubStringBoundedByIBZZ(pcSubStr, pacBounds)
		return This.FindLastSubStringBoundedByCSIBZZ(pcSubStr, pacBounds, TRUE)

		def FindLastSubStringBoundedByAsSectionsIB(pcSubStr, pacBounds)
			return This.FindLastSubStringBoundedByIBZZ(pcSubStr, pacBounds)

	   #------------------------------------------------------#
	  #  FINDING LAST OCCURRENCE OF A SUBSTRING BOUNDED BY   #
	 #  TWO OTHER SUBSTRINGS STARTING AT A GIVEN POSITION   #
	#------------------------------------------------------#

	def FindLastSubStringBoundedBySCS(pcSubStr, pacBounds, pnStartingAt, pCaseSensitive)
		return This.FindNthSubStringBoundedBySCS(nLast, pcSubStr, pacBounds, pnStartingAt, pCaseSensitive)

		def FindLastSubStringBoundedBySCSZ(pcSubStr, pacBounds, pnStartingAt, pCaseSensitive)
			return This.FindLastSubStringBoundedBySCS(pcSubStr, pacBounds, pnStartingAt, pCaseSensitive)

	#-- WITHOUT CASESENSITIVITY

	def FindLastSubStringBoundedByS(pcSubStr, pacBounds, pnStartingAt)
		return This.FindLastSubStringBoundedBySCS(pcSubStr, pacBounds, pnStartingAt, TRUE)

		def FindLastSubStringBoundedBySZ(pcSubStr, pacBounds, pnStartingAt)
			return This.FindLastSubStringBoundedByS(pcSubStr, pacBounds, pnStartingAt)

	   #-----------------------------------------------------------------------#
	  #  FINDING LAST OCCURRENCE OF A SUBSTRING BETWEEN TWO OTHER SUBSTRINGS  #
	 #  STARTING AT A GIVEN POSITION AND RETURNING POSITIONS AS SECTIONS     #
	#=======================================================================#

	def FindLastSubStringBetweenSCSZZ(pcSubStr, pcBound1, pcBound2, pnStartingAt, pCaseSensitive)
		nLast = This.NumberOfOccurrenceBetweenSCS(pcSubStr, pcBound1, pcBound2, pnStartingAt, pCaseSensitive)
		return This.FindNthSubStringBetweenSCSZZ(nLast, pcSubStr, pcBound1, pcBound2, pnStartingAt, pCaseSensitive)

		#< @FunctionAlternativeForm
	
		def FindLastSubStringBetweenAsSectionsSCS(pcSubStr, pcBound1, pcBound2, pnStartingAt, pCaseSensitive)
			return This.FindLastSubStringBetweenSCSZZ(pcSubStr, pcBound1, pcBound2, pnStartingAt, pCaseSensitive)

		#>

	#-- WITHOUT CASESENSITIVITY

	def FindLastSubStringBetweenSZZ(pcSubStr, pcBound1, pcBound2, pnStartingAt)
		return This.FindLastSubStringBetweenSCSZZ(pcSubStr, pcBound1, pcBound2, pnStartingAt, TRUE)

		#< @FunctionAlternativeForm
	
		def FindLastSubStringBetweenAsSectionsS(pcSubStr, pcBound1, pcBound2, pnStartingAt)
			return This.FindLastSubStringBetweenSZZ(pcSubStr, pcBound1, pcBound2, pnStartingAt)

		#>

	   #--------------------------------------------------------------------------#
	  #  FINDING LAST OCCURRENCE OF A SUBSTRING BOUNDED BY TWO OTHER SUBSTRINGS  #
	 #  STARTING AT A GIVEN POSITION AND RETURNING POSITIONS AS SECTIONS        #
	#--------------------------------------------------------------------------#

	def FindLastSubStringBoundedBySCSZZ(pcSubStr, pacBounds, pnStartingAt, pCaseSensitive)
		return This.FindNthSubStringBoundedBySCSZZ(nLast, pcSubStr, pacBounds, pnStartingAt, pCaseSensitive)

		def FindLastSubStringBoundedByAsSectionsSCS(pcSubStr, pacBounds, pnStartingAt, pCaseSensitive)
			return This.FindLastSubStringBoundedBySCSZZ(pcSubStr, pacBounds, pnStartingAt, pCaseSensitive)

	#-- WITHOUT CASESENSITIVITY

	def FindLastSubStringBoundedBySZZ(pcSubStr, pacBounds, pnStartingAt)
		return This.FindLastSubStringBoundedBySCSZZ(pcSubStr, pacBounds, pnStartingAt, TRUE)

		def FindLastSubStringBoundedByAsSectionsS(pcSubStr, pacBounds, pnStartingAt)
			return This.FindLastSubStringBoundedBySZZ(pcSubStr, pacBounds, pnStartingAt)

	   #-----------------------------------------------------------------#
	  #  FINDING LAST OCCURRENCE OF A SUBSTRING BETWEEN TWO OTHER       #
	 #  SUBSTRINGS STARTING AT A GIVEN POSITION AND INCLUDING BOUNDS   #
	#=================================================================#

	def FindLastSubStringBetweenSCSIB(pcSubStr, pcBound1, pcBound2, pnStartingAt, pCaseSensitive)
		nLast = This.NumberOfOccurrenceBetweenSCS(pcSubStr, pcBound1, pcBound2, pnStartingAt, pCaseSensitive)
		return This.FindNthSubStringBetweenSCSIB(nLast, pcSubStr, pcBound1, pcBound2, pnStartingAt, pCaseSensitive)

		#< @FunctionAlternativeForm
	
		def FindLastSubStringBetweenSCSIBZ(pcSubStr, pcBound1, pcBound2, pnStartingAt, pCaseSensitive)
			return This.FindLastSubStringBetweenSCSIB(pcSubStr, pcBound1, pcBound2, pnStartingAt, pCaseSensitive)

		#>

	#-- WITHOUT CASESENSITIVITY

	def FindLastSubStringBetweenSIB(pcSubStr, pcBound1, pcBound2, pnStartingAt)
		return This.FindLastSubStringBetweenSCSIB(pcSubStr, pcBound1, pcBound2, pnStartingAt, TRUE)

		#< @FunctionAlternativeForm
	
		def FindLastSubStringBetweenSIBZ(pcSubStr, pcBound1, pcBound2, pnStartingAt)
			return This.FindLastSubStringBetweenSIB(pcSubStr, pcBound1, pcBound2, pnStartingAt)

		#>

	   #----------------------------------------------------------------#
	  #  FINDING LAST OCCURRENCE OF A SUBSTRING BOUNDED BY TWO OTHER   #
	 #  SUBSTRINGSSTARTING AT A GIVEN POSITION AND INCLUDING BOUNDS   #
	#----------------------------------------------------------------#

	def FindLastSubStringBoundedBySCSIB(pcSubStr, pacBounds, pnStartingAt, pCaseSensitive)
		return This.NthLastSubStringBoundedBySCSIB(nLast, pcSubStr, pacBounds, pnStartingAt, pCaseSensitive)

		def FindLastSubStringBoundedBySCSIBZ(pcSubStr, pacBounds, pnStartingAt, pCaseSensitive)
			return This.FindLastSubStringBoundedBySCSIB(pcSubStr, pacBounds, pnStartingAt, pCaseSensitive)

	#-- WITHOUT CASESENSITIVITY

	def FindLastSubStringBoundedBySIB(pcSubStr, pacBounds, pnStartingAt)
		return This.FindLastSubStringBoundedBySCSIB(pcSubStr, pacBounds, pnStartingAt, TRUE)

		def FindLastSubStringBoundedBySIBZ(pcSubStr, pacBounds, pnStartingAt)
			return This.FindLastSubStringBoundedBySIB(pcSubStr, pacBounds, pnStartingAt)

	   #----------------------------------------------------------------------------------#
	  #  FINDING LAST OCCURRENCE OF A SUBSTRING BETWEEN TWO OTHER SUBSTRINGS STARTING    #
	 #  AT A GIVEN POSITION, INCLUDING BOUNDS, AND RETURNING THE POSITIONS AS SECTIONS  #
	#==================================================================================#

	def FindLastSubStringBetweenSCSIBZZ(pcSubStr, pcBound1, pcBound2, pnStartingAt, pCaseSensitive)
		nLast = This.NumberOfOccurrenceBetweenSCS(pcSubStr, pcBound1, pcBound2, pnStartingAt, pCaseSensitive)
		return This.FindNthSubStringBetweenSCSIBZZ(nLast, pcSubStr, pcBound1, pcBound2, pnStartingAt, pCaseSensitive)

		#< @FunctionAlternativeForm
	
		def FindLastSubStringBetweenAsSectionsSCSIB(pcSubStr, pcBound1, pcBound2, pnStartingAt, pCaseSensitive)
			return This.FindLastSubStringBetweenSCSIBZZ(pcSubStr, pcBound1, pcBound2, pnStartingAt, pCaseSensitive)

		#>

	#-- WITHOUT CASESENSITIVITY

	def FindLastSubStringBetweenSIBZZ(pcSubStr, pcBound1, pcBound2, pnStartingAt)
		return This.FindLastSubStringBetweenSCSIBZZ(pcSubStr, pcBound1, pcBound2, pnStartingAt, TRUE)

		#< @FunctionAlternativeForm
	
		def FindLastSubStringBetweenAsSectionsSIB(pcSubStr, pcBound1, pcBound2, pnStartingAt)
			return This.FindLastSubStringBetweenSIBZZ(pcSubStr, pcBound1, pcBound2, pnStartingAt)

		#>

	   #------------------------------------------------------------------------------------#
	  #  FINDING LAST OCCURRENCE OF A SUBSTRING BOUNDED BY TWO OTHER SUBSTRINGS STARTING   #
	 #  AT A GIVEN POSITION, INCLUDING BOUNDS, AND RETURNING THE POSITIONS AS SECTIONS    #
	#------------------------------------------------------------------------------------#

	def FindLastSubStringBoundedBySCSIBZZ(pcSubStr, pacBounds, pnStartingAt, pCaseSensitive)
		return This.FindNthSubStringBoundedBySCSIBZZ(nLast, pcSubStr, pacBounds, pnStartingAt, pCaseSensitive)

		def FindLastSubStringBoundedByAsSectionsSCSIB(pcSubStr, pacBounds, pnStartingAt, pCaseSensitive)
			return This.FindLastSubStringBoundedBySCSIBZZ(pcSubStr, pacBounds, pnStartingAt, pCaseSensitive)

	#-- WITHOUT CASESENSITIVITY

	def FindLastSubStringBoundedBySIBZZ(pcSubStr, pacBounds, pnStartingAt)
		return This.FindLastSubStringBoundedBySCSIBZZ(pcSubStr, pacBounds, pnStartingAt, TRUE)

		def FindLastSubStringBoundedByAsSectionsSIB(pcSubStr, pacBounds, pnStartingAt)
			return This.FindLastSubStringBoundedBySIBZZ(pcSubStr, pacBounds, pnStartingAt)

	   #---------------------------------------------------#
	  #  FINDING LAST OCCURRENCE OF A SUBSTRING BETWEEN   #
	 #  TWO OTHER SUBSTRINGS GOING IN A GIVEN DIRECTION  #
	#===================================================#

	def FindLastSubStringBetweenDCS(pcSubStr, pcBound1, pcBound2, pcDirection, pCaseSensitive)
		nLast = This.NumberOfOccurrenceBetweenCS(pcSubStr, pcBound1, pcBound2, pCaseSensitive)
		return This.FindNthSubStringBetweenDCS(nLast, pcSubStr, pcBound1, pcBound2, pcDirection, pCaseSensitive)

		#< @FunctionAlternativeForm
	
		def FindLastSubStringBetweenDCSZ(pcSubStr, pcBound1, pcBound2, pcDirection, pCaseSensitive)
			return This.FindLastSubStringBetweenDCS(pcSubStr, pcBound1, pcBound2, pcDirection, pCaseSensitive)

		#>

	#-- WITHOUT CASESENSITIVITY

	def FindLastSubStringBetweenD(pcSubStr, pcBound1, pcBound2, pcDirection)
		return This.FindLastSubStringBetweenDCS(pcSubStr, pcBound1, pcBound2, pcDirection, TRUE)

		#< @FunctionAlternativeForm
	
		def FindLastSubStringBetweenDZ(pcSubStr, pcBound1, pcBound2, pcDirection)
			return This.FindLastSubStringBetweenD(pcSubStr, pcBound1, pcBound2, pcDirection)

		#>

	   #-----------------------------------------------------#
	  #  FINDING LAST OCCURRENCE OF A SUBSTRING BOUNDED BY  #
	 #  TWO OTHER SUBSTRINGS GOING IN A GIVEN DIRECTION    #
	#-----------------------------------------------------#

	def FindLastSubStringBoundedByDCS(pcSubStr, pacBounds, pcDirection, pCaseSensitive)
		return This.FindNthSubStringBoundedByDCS(nLast, pcSubStr, pacBounds, pcDirection, pCaseSensitive)

		def FindLastSubStringBoundedByDCSZ(pcSubStr, pacBounds, pcDirection, pCaseSensitive)
			return This.FindLastSubStringBoundedByDCS(pcSubStr, pacBounds, pcDirection, pCaseSensitive)

	#-- WITHOUT CASESENSITIVITY

	def FindLastSubStringBoundedByD(pcSubStr, pacBounds, pcDirection)
		return This.FindLastSubStringBoundedByDCS(pcSubStr, pacBounds, pcDirection, TRUE)

		def FindLastSubStringBoundedByDZ(pcSubStr, pacBounds, pcDirection)
			return This.FindLastSubStringBoundedByD(pcSubStr, pacBounds, pcDirection)

	   #-----------------------------------------------------------------------#
	  #  FINDING LAST OCCURRENCE OF A SUBSTRING BETWEEN TWO OTHER SUBSTRINGS  #
	 #  GOING INA GIVEN DIRECTION AND RETURNING POSITIONS AS SECTIONS        #
	#=======================================================================#

	def FindLastSubStringBetweenDCSZZ(pcSubStr, pcBound1, pcBound2, pcDirection, pCaseSensitive)
		nLast = This.NumberOfOccurrenceBetweenCS(pcSubStr, pcBound1, pcBound2, pCaseSensitive)
		return This.FindNthSubStringBetweenDCSZZ(nLast, pcSubStr, pcBound1, pcBound2, pcDirection, pCaseSensitive)

		#< @FunctionAlternativeForm
	
		def FindLastSubStringBetweenAsSectionsDCS(pcSubStr, pcBound1, pcBound2, pcDirection, pCaseSensitive)
			return This.FindLastSubStringBetweenDCSZZ(pcSubStr, pcBound1, pcBound2, pcDirection, pCaseSensitive)

		#>

	#-- WITHOUT CASESENSITIVITY

	def FindLastSubStringBetweenDZZ(pcSubStr, pcBound1, pcBound2, pcDirection)
		return This.FindLastSubStringBetweenDCSZZ(pcSubStr, pcBound1, pcBound2, pcDirection, TRUE)

		#< @FunctionAlternativeForm
	
		def FindLastSubStringBetweenAsSectionsD(pcSubStr, pcBound1, pcBound2, pcDirection)
			return This.FindLastSubStringBetweenDZZ(pcSubStr, pcBound1, pcBound2, pcDirection)

		#>

	   #--------------------------------------------------------------------------#
	  #  FINDING LAST OCCURRENCE OF A SUBSTRING BOUNDED BY TWO OTHER SUBSTRINGS  #
	 #  GOING INA GIVEN DIRECTION AND RETURNING POSITIONS AS SECTIONS           #
	#--------------------------------------------------------------------------#

	def FindLastSubStringBoundedByDCSZZ(pcSubStr, pacBounds, pcDirection, pCaseSensitive)
		return This.FindNthSubStringBoundedByDCSZZ(nLast, pcSubStr, pacBounds, pcDirection, pCaseSensitive)

		def FindLastSubStringBoundedByAsSectionsDCS(pcSubStr, pacBounds, pcDirection, pCaseSensitive)
			return This.FindLastSubStringBoundedByDCSZZ(pcSubStr, pacBounds, pcDirection, pCaseSensitive)

	#-- WITHOUT CASESENSITIVITY

	def FindLastSubStringBoundedByDZZ(pcSubStr, pacBounds, pcDirection)
		return This.FindLastSubStringBoundedByDCSZZ(pcSubStr, pacBounds, pcDirection, TRUE)

		def FindLastSubStringBoundedByAsSectionsD(pcSubStr, pacBounds, pcDirection)
			return This.FindLastSubStringBoundedByDZZ(pcSubStr, pacBounds, pcDirection)

	   #--------------------------------------------------------------#
	  #  FINDING LAST OCCURRENCE OF A SUBSTRING BETWEEN TWO OTHER    #
	 #  SUBSTRINGS GOING IN A GIVEN DIRECTION AND INCLUDING BOUNDS  #
	#==============================================================#

	def FindLastSubStringBetweenDCSIB(pcSubStr, pcBound1, pcBound2, pcDirection, pCaseSensitive)
		nLast = This.NumberOfOccurrenceBetweenCS(pcSubStr, pcBound1, pcBound2, pCaseSensitive)
		return This.FindNthSubStringBetweenDCSIB(nLast, pcSubStr, pcBound1, pcBound2, pcDirection, pCaseSensitive)

		#< @FunctionAlternativeForm
	
		def FindLastSubStringBetweenDCSIBZ(pcSubStr, pcBound1, pcBound2, pcDirection, pCaseSensitive)
			return This.FindLastSubStringBetweenDCSIB(pcSubStr, pcBound1, pcBound2, pcDirection, pCaseSensitive)

		#>

	#-- WITHOUT CASESENSITIVITY

	def FindLastSubStringBetweenDIB(pcSubStr, pcBound1, pcBound2, pcDirection)
		return This.FindLastSubStringBetweenDCSIB(pcSubStr, pcBound1, pcBound2, pcDirection, TRUE)

		#< @FunctionAlternativeForm
	
		def FindLastSubStringBetweenDIBZ(pcSubStr, pcBound1, pcBound2, pcDirection)
			return This.FindLastSubStringBetweenDIB(pcSubStr, pcBound1, pcBound2, pcDirection)

		#>

	   #----------------------------------------------------------------#
	  #  FINDING LAST OCCURRENCE OF A SUBSTRING BOUNDED BY TWO OTHER   #
	 #  SUBSTRINGS GOING IN A GIVEN DIRECTION AND INCLUDING BOUNDS    #
	#----------------------------------------------------------------#

	def FindLastSubStringBoundedByDCSIB(pcSubStr, pacBounds, pcDirection, pCaseSensitive)
		return This.FindNthSubStringBoundedByDCSIB(nLast, pcSubStr, pacBounds, pcDirection, pCaseSensitive)

		def FindLastSubStringBoundedByDCSIBZ(pcSubStr, pacBounds, pcDirection, pCaseSensitive)
			return This.FindLastSubStringBoundedByDCSIB(pcSubStr, pacBounds, pcDirection, pCaseSensitive)

	#-- WITHOUT CASESENSITIVITY

	def FindLastSubStringBoundedByDIB(pcSubStr, pacBounds, pcDirection)
		return This.FindLastSubStringBoundedByDCSIB(pcSubStr, pacBounds, pcDirection, TRUE)

		def FindLastSubStringBoundedByDIBZ(pcSubStr, pacBounds, pcDirection)
			return This.FindLastSubStringBoundedByDIB(pcSubStr, pacBounds, pcDirection)

	   #------------------------------------------------------------------------------#
	  #  FINDING LAST OCCURRENCE OF A SUBSTRING BETWEEN TWO OTHER SUBSTRINGS GOING   #
	 #  IN A GIVENDIRECTION, INCLUDING BOUNDS, AND RETURNING POSITIONS AS SECTIONS  # 
	#==============================================================================#

	def FindLastSubStringBetweenDCSIBZZ(pcSubStr, pcBound1, pcBound2, pcDirection, pCaseSensitive)
		nLast = This.NumberOfOccurrenceBetweenCS(pcSubStr, pcBound1, pcBound2, pCaseSensitive)
		return This.FindNthSubStringBetweenDCSIBZZ(nLast, pcSubStr, pcBound1, pcBound2, pcDirection, pCaseSensitive)

		#< @FunctionAlternativeForm
	
		def FindLastSubStringBetweenAsSectionsDCSIB(pcSubStr, pcBound1, pcBound2, pcDirection, pCaseSensitive)
			return This.FindLastSubStringBetweenDCSIBZZ(pcSubStr, pcBound1, pcBound2, pcDirection, pCaseSensitive)

		#>

	#-- WITHOUT CASESENSITIVITY

	def FindLastSubStringBetweenDIBZZ(pcSubStr, pcBound1, pcBound2, pcDirection)
		return This.FindLastSubStringBetweenDCSIBZZ(pcSubStr, pcBound1, pcBound2, pcDirection, TRUE)

		#< @FunctionAlternativeForm
	
		def FindLastSubStringBetweenAsSectionsDIB(pcSubStr, pcBound1, pcBound2, pcDirection)
			return This.FindLastSubStringBetweenDIBZZ(pcSubStr, pcBound1, pcBound2, pcDirection)

		#>

	   #---------------------------------------------------------------------------------#
	  #  FINDING LAST OCCURRENCE OF A SUBSTRING BOUNDED BY TWO OTHER SUBSTRINGS GOING   #
	 #  IN A GIVENDIRECTION, INCLUDING BOUNDS, AND RETURNING POSITIONS AS SECTIONS     # 
	#---------------------------------------------------------------------------------#

	def FindLastSubStringBoundedByDCSIBZZ(pcSubStr, pacBounds, pcDirection, pCaseSensitive)
		return This.FindNthSubStringBoundedByDCSIBZZ(nLast, pcSubStr, pacBounds, pcDirection, pCaseSensitive)

		def FindLastSubStringBoundedByAsSectionsDCSIB(pcSubStr, pacBounds, pcDirection, pCaseSensitive)
			return This.FindBoundedByDCSIBZZ(pcSubStr, pacBounds, pcDirection, pCaseSensitive)

	#-- WITHOUT CASESENSITIVITY

	def FindLastSubStringBoundedByDIBZZ(pcSubStr, pacBounds, pcDirection)
		return This.FindLastSubStringBoundedByDCSIBZZ(pcSubStr, pacBounds, pcDirection, pCaseSensitive)

		def FindLastSubStringBoundedByAsSectionsDIB(pcSubStr, pacBounds, pcDirection)
			return This.FindBoundedByDIBZZ(pcSubStr, pacBounds, pcDirection)

	   #------------------------------------------------------------------------#
	  #  FINDING LAST OCCURRENCE OF A SUBSTRING BETWEEN TWO OTHER SUBSTRINGS   #
	 #  STARTING AT A GIVEN POSITION AND GOING IN A GIVEN DIRECTION           #
	#------------------------------------------------------------------------#

	def FindLastSubStringBetweenSDCS(pcSubStr, pcBound1, pcBound2, pnStartingAt, pcDirection, pCaseSensitive)
		nLast = This.NumberOfOccurrenceBetweenSCS(pcSubStr, pcBound1, pcBound2, pnStartingAt, pCaseSensitive)
		return This.FindNthSubStringBetweenSDCS(nLast, pcSubStr, pcBound1, pcBound2, pnStartingAt, pcDirection, pCaseSensitive)

		#< @FunctionAlternativeForm
	
		def FindLastSubStringBetweenSDCSZ(pcSubStr, pcBound1, pcBound2, pnStartingAt, pcDirection, pCaseSensitive)
			return This.FindLastSubStringBetweenSDCS(pcSubStr, pcBound1, pcBound2, pnStartingAt, pcDirection, pCaseSensitive)

		#>

	#-- WITHOUT CASESENSITIVITY

	def FindLastSubStringBetweenSD(pcSubStr, pcBound1, pcBound2, pnStartingAt, pcDirection)
		return This.FindLastSubStringBetweenSDCS(pcSubStr, pcBound1, pcBound2, pnStartingAt, pcDirection, TRUE)

		#< @FunctionAlternativeForm
	
		def FindLastSubStringBetweenSDZ(pcSubStr, pcBound1, pcBound2, pnStartingAt, pcDirection)
			return This.FindLastSubStringBetweenSD(pcSubStr, pcBound1, pcBound2, pnStartingAt, pcDirection)

		#>

	   #---------------------------------------------------------------------------#
	  #  FINDING LAST OCCURRENCE OF A SUBSTRING BOUNDED BY TWO OTHER SUBSTRINGS   #
	 #  STARTING AT A GIVEN POSITION AND GOING IN A GIVEN DIRECTION              #
	#---------------------------------------------------------------------------#

	def FindLastSubStringBoundedBySDCS(pcSubStr, pacBounds, pnStartingAt, pcDirection, pCaseSensitive)
		return This.FindNthSubStringBoundedBySDCS(nLast, pcSubStr, pacBounds, pnStartingAt, pcDirection, pCaseSensitive)

		def FindLastSubStringBoundedBySDCSZ(pcSubStr, pacBounds, pnStartingAt, pcDirection, pCaseSensitive)
			return This.FindLastSubStringBoundedBySDCS(pcSubStr, pacBounds, pnStartingAt, pcDirection, pCaseSensitive)

	#-- WITHOUT CASESENSITIVITY

	def FindLastSubStringBoundedBySD(pcSubStr, pacBounds, pnStartingAt, pcDirection)
		return This.FindLastSubStringBoundedBySDCS(pcSubStr, pacBounds, pnStartingAt, pcDirection, TRUE)

		def FindLastSubStringBoundedBySDZ(pcSubStr, pacBounds, pnStartingAt, pcDirection)
			return This.FindLastSubStringBoundedBySD(pcSubStr, pacBounds, pnStartingAt, pcDirection)

	   #----------------------------------------------------------------------------------------#
	  #  FINDING LAST OCCURRENCE OF A SUBSTRING BETWEEN TWO OTHER SUBSTRINGSS STARTING         #
	 #  AT A GIVEN POSITION, GOING IN A GIVEN DIRECTION, AND RETURNING POSITIONS AS SECTIONS  #
	#========================================================================================#

	def FindLastSubStringBetweenSDCSZZ(pcSubStr, pcBound1, pcBound2, pnStartingAt, pcDirection, pCaseSensitive)
		nLast = This.NumberOfOccurrenceBetweenSCS(pcSubStr, pcBound1, pcBound2, pnStartingAt, pCaseSensitive)
		return This.FindLastSubStringBetweenSDCSZZ(pcSubStr, pcBound1, pcBound2, pnStartingAt, pcDirection, pCaseSensitive)

		#< @FunctionAlternativeForm
	
		def FindLastSubStringBetweenAsSection_SDCS(pcSubStr, pcBound1, pcBound2, pnStartingAt, pcDirection, pCaseSensitive)
			return This.FindLastSubStringBetweenSDCSZZ(pcSubStr, pcBound1, pcBound2, pnStartingAt, pcDirection, pCaseSensitive)

		#>

	#-- WITHOUT CASESENSITIVITY

	def FindLastSubStringBetweenSDZZ(pcSubStr, pcBound1, pcBound2, pnStartingAt, pcDirection)
		return This.FindLastSubStringBetweenSDCSZZ(pcSubStr, pcBound1, pcBound2, pnStartingAt, pcDirection, TRUE)

		#< @FunctionAlternativeForm
	
		def FindLastSubStringBetweenAsSection_SD(pcSubStr, pcBound1, pcBound2, pnStartingAt, pcDirection)
			return This.FindLastSubStringBetweenSDZZ(pcSubStr, pcBound1, pcBound2, pnStartingAt, pcDirection)

		#>

	   #----------------------------------------------------------------------------------------#
	  #  FINDING LAST OCCURRENCE OF A SUBSTRING BOUNDED BY TWO OTHER SUBSTRINGSS STARTING      #
	 #  AT A GIVEN POSITION, GOING IN A GIVEN DIRECTION, AND RETURNING POSITIONS AS SECTIONS  #
	#----------------------------------------------------------------------------------------#

	def FindLastSubStringBoundedBySDCSZZ(pcSubStr, pacBounds, pnStartingAt, pcDirection, pCaseSensitive)
		return This.FindBoundedBySDCSZZ(pcSubStr, pacBounds, pnStartingAt, pcDirection, pCaseSensitive)

		def FindLastSubStringBoundedByAsSection_SDCS(pcSubStr, pacBounds, pnStartingAt, pcDirection, pCaseSensitive)
			return This.FindLastSubStringBoundedBySDCSZZ(pcSubStr, pacBounds, pnStartingAt, pcDirection, pCaseSensitive)

	#-- WITHOUT CASESENSITIVITY

	def FindLastSubStringBoundedBySDZZ(pcSubStr, pacBounds, pnStartingAt, pcDirection)
		return This.FindLastSubStringBoundedBySDZZ(pcSubStr, pacBounds, pnStartingAt, pcDirection)

		def FindLastSubStringBoundedByAsSection_SD(pcSubStr, pacBounds, pnStartingAt, pcDirection)
			return This.FindLastSubStringBoundedBySDZZ(pcSubStr, pacBounds, pnStartingAt, pcDirection)

	   #----------------------------------------------------------------------------------#
	  #  FINDING LAST OCCURRENCE OF A SUBSTRING BETWEEN TWO OTHER SUBSTRINGSS STARTING   #
	 #  AT A GIVEN POSITION, GOING IN A GIVEN DIRECTION, AND INCLUDING BOUNDS           #
	#==================================================================================#

	def FindLastSubStringBetweenSDCSIB(pcSubStr, pcBound1, pcBound2, pnStartingAt, pcDirection, pCaseSensitive)
		nLast = This.NumberOfOccurrenceBetweenSCS(pcSubStr, pcBound1, pcBound2, pnStartingAt, pCaseSensitive)
		return This.FindNthSubStringBetweenSDCSIB(nLast, pcSubStr, pcBound1, pcBound2, pnStartingAt, pcDirection, pCaseSensitive)

		#< @FunctionAlternativeForm
	
		def FindLastSubStringBetweenSDCSIBZ(pcSubStr, pcBound1, pcBound2, pnStartingAt, pcDirection, pCaseSensitive)
			return This.FindLastSubStringBetweenSDCSIB(pcSubStr, pcBound1, pcBound2, pnStartingAt, pcDirection, pCaseSensitive)

		#>

	#-- WITHOUT CASESENSITIVITY

	def FindLastSubStringBetweenSDIB(pcSubStr, pcBound1, pcBound2, pnStartingAt, pcDirection)
		return This.FindLastSubStringBetweenSDCSIB(pcSubStr, pcBound1, pcBound2, pnStartingAt, pcDirection, TRUE)

		#< @FunctionAlternativeForm
	
		def FindLastSubStringBetweenSDIBZ(pcSubStr, pcBound1, pcBound2, pnStartingAt, pcDirection)
			return This.FindLastSubStringBetweenSDIB(pcSubStr, pcBound1, pcBound2, pnStartingAt, pcDirection)

		#>	

	   #-------------------------------------------------------------------------------------#
	  #  FINDING LAST OCCURRENCE OF A SUBSTRING BOUNDED BY TWO OTHER SUBSTRINGSS STARTING   #
	 #  AT A GIVEN POSITION, GOING IN A GIVEN DIRECTION, AND INCLUDING BOUNDS              #
	#-------------------------------------------------------------------------------------#

	def FindLastSubStringBoundedBySDCSIB(pcSubStr, pacBounds, pnStartingAt, pcDirection, pCaseSensitive)
		return This.FindNthSubStringBoundedBySDCSIB(nLast, pcSubStr, pacBounds, pnStartingAt, pcDirection, pCaseSensitive)

		def FindLastSubStringBoundedBySDCSIBZ(pcSubStr, pacBounds, pnStartingAt, pcDirection, pCaseSensitive)
			return This.FindLastSubStringBoundedBySDCSIB(pcSubStr, pacBounds, pnStartingAt, pcDirection, pCaseSensitive)

	#-- WITHOUT CASESENSITIVITY

	def FindLastSubStringBoundedBySDIB(pcSubStr, pacBounds, pnStartingAt, pcDirection, pCaseSensitive)
		return This.FindLastSubStringBoundedBySDCSIB(pcSubStr, pacBounds, pnStartingAt, pcDirection, TRUE)

		def FindLastSubStringBoundedBySDIBZ(pcSubStr, pacBounds, pnStartingAt, pcDirection)
			return This.FindLastSubStringBoundedBySDIB(pcSubStr, pacBounds, pnStartingAt, pcDirection)

	   #-----------------------------------------------------------------------------------------------#
	  #  FINDING LAST OCCURRENCE OF A SUBSTRING BETWEEN TWO OTHER SUBSTRINGSS STARTING AT A GIVEN     #
	 #  POSITION, GOING IN A GIVEN DIRECTION, INCLUDING BOUNDS, AND RETURNING POSITIONS AS SECTIONS  #
	#===============================================================================================#

	def FindLastSubStringBetweenSDCSIBZZ(pcSubStr, pcBound1, pcBound2, pnStartingAt, pcDirection, pCaseSensitive)
		nLast = This.NumberOfOccurrenceBetweenSCS(pcSubStr, pcBound1, pcBound2, pnStartingAt, pCaseSensitive)
		return This.FindNthSubStringBetweenSDCSIBZZ(nLast, pcSubStr, pcBound1, pcBound2, pnStartingAt, pcDirection, pCaseSensitive)

		#< @FunctionAlternativeForm
	
		def FindLastSubStringBetweenAsSectionsSDCSIB(pcSubStr, pcBound1, pcBound2, pnStartingAt, pcDirection, pCaseSensitive)
			return This.FindLastSubStringBetweenSDCSIBZZ(pcSubStr, pcBound1, pcBound2, pnStartingAt, pcDirection, pCaseSensitive)

		#>

	#-- WITHOUT CASESENSITIVITY

	def FindLastSubStringBetweenSDIBZZ(pcSubStr, pcBound1, pcBound2, pnStartingAt, pcDirection)
		return This.FindLastSubStringBetweenSDCSIBZZ(pcSubStr, pcBound1, pcBound2, pnStartingAt, pcDirection, TRUE)

		#< @FunctionAlternativeForm
	
		def FindLastSubStringBetweenAsSectionsSDIB(pcSubStr, pcBound1, pcBound2, pnStartingAt, pcDirection)
			return This.FindLastSubStringBetweenSDIBZZ(pcSubStr, pcBound1, pcBound2, pnStartingAt, pcDirection)

		#>

	   #------------------------------------------------------------------------------------------------#
	  #  FINDING LAST OCCURRENCE OF A SUBSTRING BOUNDED BY TWO OTHER SUBSTRINGSS STARTING AT A GIVEN   #
	 #  POSITION, GOING IN A GIVEN DIRECTION, INCLUDING BOUNDS, AND RETURNING POSITIONS AS SECTIONS   #
	#================================================================================================#

	def FindLastSubStringBoundedBySDCSIBZZ(pcSubStr, pacBounds, pnStartingAt, pcDirection, pCaseSensitive)
		return This.FindLastSubStringBoundedBySDCSIBZZ(pcSubStr, pacBounds, pnStartingAt, pcDirection, pCaseSensitive)

		def FindLastSubStringBoundedByAsSectionsSDCSIB(pcSubStr, pacBounds, pnStartingAt, pcDirection, pCaseSensitive)
			return This.FindLastSubStringBoundedBySDCSIBZZ(pcSubStr, pacBounds, pnStartingAt, pcDirection, pCaseSensitive)

	#-- WITHOUT CASESENSITIVITY

	def FindLastSubStringBoundedBySDIBZZ(pcSubStr, pacBounds, pnStartingAt, pcDirection)
		return This.FindLastSubStringBoundedBySDCSIBZZ(pcSubStr, pacBounds, pnStartingAt, pcDirection, TRUE)

		def FindLastSubStringBoundedByAsSectionsSDIB(pcSubStr, pacBounds, pnStartingAt, pcDirection)
			return This.FindLastSubStringBoundedBySDIBZZ(pcSubStr, pacBounds, pnStartingAt, pcDirection)
