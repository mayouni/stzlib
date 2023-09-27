
#============= A GIVEN SUBSTRING SubStringBetween

	  #===========================================================================#
	 #  CHECKING IF THE STRING CONTAINS A SBISTRING BETWEEN TWO OTHER SubString  #
	#===========================================================================#

	def ContainsSubStringBetweenCS(pcSubStr, pcBound1, pcBound2, pCaseSensitive)
		/* ... */

		#< @FunctionAlternativeForms

		def ContainsSubStringBoundedByCS(pcSubStr, pacBounds, pCaseSensitive)
			if isString(pacBounds)
				return This.ContainsSubStringBetweenCS(pcSubStr, pacBounds, pacBounds, pCaseSensitive)

			but isList(pacBounds) and Q(pacBounds).IsPairOfStrings()
				return This.This.ContainsSubStringBetweenCS(pcSubStr, pacBounds[1], pacBounds[2], pCaseSensitive)

			else
				StzRaise("Incorrect param type! pacBounds must be string or a pair of strings.")
			ok

		def ContainsBetweenCS(pcSubStr, pcBound1, pcBound2, pCaseSensitive)
			return This.ContainsSubStringBetweenCS(pcSubStr, pcBound1, pcBound2, pCaseSensitive)

		def ContainsBoundedByCS(pcSubStr, pacBounds, pCaseSensitive)
			return This.ContainsSubStringBoundedByCS(pcSubStr, pacBounds, pCaseSensitive)

		#>

	#-- WITHOUT CASESENSITIVE

	def ContainsSubStringBetween(pcSubStr, pcBound1, pcBound2)
		return This.ContainsSubStringBetweenCS(pcSubStr, pcBound1, pcBound2, :CaseSensitive = TRUE)

		#< @FunctionAlternativeForms

		def ContainsSubStringBoundedBy(pcSubStr, pacBounds)
			return This.ContainsSubStringBetween(pcSubStr, pcBound1, pcBound2)

		def ContainsBetween(pcSubStr, pcBound1, pcBound2)
			return This.ContainsSubStringBetween(pcSubStr, pcBound1, pcBound2)

		def ContainsBoundedBy(pcSubStr, pacBounds)
			return This.ContainsBoundedByCS(pcSubStr, pcBound1, pcBound2, :CaseSensitive = TRUE)

		#>

	   #------------------------------------------------------------#
	  #  CHECKING IF THE STRING CONTAINS A SBISTRING BETWEEN TWO   #
	 #  OTHER SubString STARTING AT A GIVEN POSITION              #
	#------------------------------------------------------------#

	def ContainsSubStringBetweenSCS(pcSubStr, pcBound1, pcBound2, pnStartingAt, pCaseSensitive)
		/* ... */

		def ContainsSubStringBoundedBySCS(pcSubStr, pacBounds, pnStartingAt, pCaseSensitive)
			if isString(pacBounds)
				return This.ContainsSubStringBetweenSCS(pcSubStr, pacBounds, pacBounds, pnStartingAt, pCaseSensitive)

			but isList(pacBounds) and Q(pacBounds).IsPairOfStrings()
				return This.This.ContainsSubStringBetweenCSContainsSubStringBetweenSCS(pcSubStr, pacBounds[1], pacBounds[2], pnStartingAt, pCaseSensitive)

			else
				StzRaise("Incorrect param type! pacBounds must be string or a pair of strings.")
			ok

	#-- WITHOUT CASESENSITIVITY

	def ContainsSubStringBetweenS(pcSubStr, pcBound1, pcBound2, pnStartingAt)
		return This.ContainsSubStringBetweenSCS(pcSubStr, pcBound1, pcBound2, pnStartingAt, :CaseSensitive) = TRUE

		def ContainsSubStringBoundedByS(pcSubStr, pacBounds, pnStartingAt)
			return This.ContainsSubStringBoundedBySCS(pcSubStr, pacBounds, pnStartingAt, :CaseSensitive = TRUE)

	  #-----------------------------------------------------------------------------------#
	 #  GETTING THE NUMBER OF OCCURRENCES OF A SUBSTRING BOUBDED BY TWO OTHER SubString  #
	#-----------------------------------------------------------------------------------#

	def NumberOfOccurrenceBetweenCS(pcSubStr, pcBound1, pcBound2, pCaseSensitive)
		/* ... */

		#< @FunctionAlternativeForms

		def NumberOfOccurrenceBoundedByCS(pcSubStr, pacBounds, pCaseSensitive)
			if isString(pacBounds)
				return This.NumberOfOccurrenceBetweenCS(pcSubStr, pacBounds, pacBounds, pCaseSensitive)

			but isList(pacBounds) and Q(pacBounds).IsPairOfStrings()
				return This.NumberOfOccurrenceBetweenCS(pcSubStr, pacBounds[1], pacBounds[2], pCaseSensitive)

			else
				StzRaise("Incorrect param type! pacBounds must be a string or pair of strings.")
			ok

		def NumberOfOccurrenceOfSubStringBetweenCS(pcSubStr, pcBound1, pcBound2, pCaseSensitive)
			return This.NumberOfOccurrenceBetweenCS(pcSubStr, pcBound1, pcBound2, pCaseSensitive)

		def NumberOfOccurrenceOfSubStringBoundedByCS(pcSubStr, pacBounds, pCaseSensitive)
			return This.NumberOfOccurrenceBoundedByCS(pcSubStr, pacBounds, pCaseSensitive)

		#-- Occurrences (with s)
	
		def NumberOfOccurrencesBetweenCS(pcSubStr, pcBound1, pcBound2, pCaseSensitive)
			return This.NumberOfOccurrenceBetweenCS(pcSubStr, pcBound1, pcBound2, pCaseSensitive)

		def NumberOfOccurrencesBoundedByCS(pcSubStr, pacBounds, pCaseSensitive)
			return This.NumberOfOccurrenceBoundedByCS(pcSubStr, pacBounds, pCaseSensitive)

		def NumberOfOccurrencesOfSubStringBetweenCS(pcSubStr, pcBound1, pcBound2, pCaseSensitive)
			return This.NumberOfOccurrenceBetweenCS(pcSubStr, pcBound1, pcBound2, pCaseSensitive)

		def NumberOfOccurrencesOfSubStringBoundedByCS(pcSubStr, pacBounds, pCaseSensitive)
			return This.NumberOfOccurrenceBoundedByCS(pcSubStr, pacBounds, pCaseSensitive)

		#>

	#-- WITHOUT CASESENSITIVITY

	def NumberOfOccurrenceBetween(pcSubStr, pcBound1, pcBound2)
		return This.NumberOfOccurrenceBetweenCS(pcSubStr, pcBound1, pcBound2, :CaseSensitive = TRUE)

		#< @FunctionAlternativeForms

		def NumberOfOccurrenceBoundedBy(pcSubStr, pacBounds)
			return This.NumberOfOccurrenceBoundedByCS(pcSubStr, pacBounds, :CaseSensitive = TRUE)

		def NumberOfOccurrenceOfSubStringBetween(pcSubStr, pcBound1, pcBound2)
			return This.NumberOfOccurrenceBetween(pcSubStr, pcBound1, pcBound2)

		def NumberOfOccurrenceOfSubStringBoundedBy(pcSubStr, pacBounds)
			return This.NumberOfOccurrenceBoundedByCS(pcSubStr, pacBounds, :CaseSensitive = TRUE)

		#-- Occurrences (with s)
	
		def NumberOfOccurrencesBetween(pcSubStr, pcBound1, pcBound2)
			return This.NumberOfOccurrenceBetween(pcSubStr, pcBound1, pcBound2)

		def NumberOfOccurrencesBoundedBy(pcSubStr, pacBounds)
			return This.NumberOfOccurrenceBoundedByCS(pcSubStr, pacBounds, :CaseSensitive = TRUE)

		def NumberOfOccurrencesOfSubStringBetween(pcSubStr, pcBound1, pcBound2)
			return This.NumberOfOccurrenceBetween(pcSubStr, pcBound1, pcBound2)

		def NumberOfOccurrencesOfSubStringBoundedBy(pcSubStr, pacBounds)
			return This.NumberOfOccurrenceBoundedByCS(pcSubStr, pacBounds, :CaseSensitive = TRUE)

		#>

	   #---------------------------------------------------------------#
	  #  GETTING THE NUMBER OF OCCURRENCES OF A SUBSTRING BOUBDED BY  #
	 #  TWO OTHER SubString STARTING AT A GIVEN POSITION             #
	#---------------------------------------------------------------#

	def NumberOfSubStringBetweenSCS(pcSubStr, pcBound1, pcBound2, pnStartingAt)
		/* ... */

		#< @FunctionAlternativeForms

		def NumberOfOccurrenceBoundedBySCS(pcSubStr, pacBounds, pnStartingAt, pCaseSensitive)
			if isString(pacBounds)
				return This.NumberOfSubStringBetweenSCS(pcSubStr, pacBounds, pacBounds, pnStartingAt, pCaseSensitive)

			but isList(pacBounds) and Q(pacBounds).IsPairOfStrings()
				return This.NumberOfSubStringBetweenSCS(pcSubStr, pacBounds[1], pacBounds[2], pnStartingAt, pCaseSensitive)

			else
				StzRaise("Incorrect param type! pacBounds must be a string or pair of strings.")
			ok

		def NumberOfOccurrenceOfSubStringBetweenSCS(pcSubStr, pcBound1, pcBound2, pnStartingAt, pCaseSensitive)
			return This.NumberOfSubStringBetweenSCS(pcSubStr, pcBound1, pcBound2, pnStartingAt, pCaseSensitive)

		def NumberOfOccurrenceOfSubStringBoundedBySCS(pcSubStr, pacBounds, pnStartingAt, pCaseSensitive)
			return This.NumberOfOccurrenceBoundedBySCS(pcSubStr, pacBounds, pnStartingAt, pCaseSensitive)
	
		#-- Occurrences (with s)
	
		def NumberOfOccurrencesBetweenSCS(pcSubStr, pcBound1, pcBound2, pnStartingAt, pCaseSensitive)
			return This.NumberOfSubStringBetweenSCS(pcSubStr, pcBound1, pcBound2, pnStartingAt, pCaseSensitive)

		def NumberOfOccurrencesBoundedBySCS(pcSubStr, pacBounds, pnStartingAt, pCaseSensitive)
			return This.NumberOfOccurrenceBoundedBySCS(pcSubStr, pacBounds, pnStartingAt, pCaseSensitive)

		def NumberOfOccurrencesOfSubStringBetweenSCS(pcSubStr, pcBound1, pcBound2, pnStartingAt, pCaseSensitive)
			return This.NumberOfSubStringBetweenSCS(pcSubStr, pcBound1, pcBound2, pnStartingAt, pCaseSensitive)

		def NumberOfOccurrencesOfSubStringBoundedBySCS(pcSubStr, pacBounds, pnStartingAt, pCaseSensitive)
			return This.NumberOfOccurrenceBoundedBySCS(pcSubStr, pacBounds, pnStartingAt, pCaseSensitive)

		#>

	#-- WITHOUT CASESENSITIVITY

	def NumberOfSubStringBetweenS(pcSubStr, pcBound1, pcBound2, pnStartingAt)
		return This.NumberOfSubStringBetweenSCS(pcSubStr, pcBound1, pcBound2, pnStartingAt, :CaseSensitive = TRUE)

		#< @FunctionAlternativeForms

		def NumberOfOccurrenceBoundedByS(pcSubStr, pacBounds, pnStartingAt)
			return This.NumberOfOccurrenceBoundedBySCS(pcSubStr, pacBounds, pnStartingAt, :CaseSensitive = TRUE)

		def NumberOfOccurrenceOfSubStringBetweenS(pcSubStr, pcBound1, pcBound2, pnStartingAt)
			return This.NumberOfSubStringBetweenS(pcSubStr, pcBound1, pcBound2, pnStartingAt)

		def NumberOfOccurrenceOfSubStringBoundedByS(pcSubStr, pacBounds, pnStartingAt)
			return This.NumberOfOccurrenceBoundedBySCS(pcSubStr, pacBounds, pnStartingAt, :CaseSensitive = TRUE)
	
		#-- Occurrences (with s)
	
		def NumberOfOccurrencesBetweenS(pcSubStr, pcBound1, pcBound2, pnStartingAt)
			return This.NumberOfSubStringBetweenS(pcSubStr, pcBound1, pcBound2, pnStartingAt)

		def NumberOfOccurrencesBoundedByS(pcSubStr, pacBounds, pnStartingAt)
			return This.NumberOfOccurrenceBoundedBySCS(pcSubStr, pacBounds, pnStartingAt, :CaseSensitive = TRUE)

		def NumberOfOccurrencesOfSubStringBetweenS(pcSubStr, pcBound1, pcBound2, pnStartingAt)
			return This.NumberOfSubStringBetweenS(pcSubStr, pcBound1, pcBound2, pnStartingAt)

		def NumberOfOccurrencesOfSubStringBoundedByS(pcSubStr, pacBounds, pnStartingAt)
				return This.NumberOfOccurrenceBoundedBySCS(pcSubStr, pacBounds, pnStartingAt, :CaseSensitive = TRUE)

		#>

	   #----------------------------------------------------------------------#
	  #  CHECKING IF THE STRING CONTAINS N OCCURRENCES OF A GIVEN SUBSTRING  #
	 #  BOUNDED BY TWO OTHER SubString                                      #
	#----------------------------------------------------------------------#

	def ContainsNOccurrencesOfSubStringBetweenCS(n, pcBound1, pcBound2, pCaseSensitive)
		/* ... */

		def ContainsNOccurrencesOfSubStringBoundedByCS(n, pacBounds, pCaseSenstive, pCaseSensitive)
			if isString(pacBounds)
				return This.ContainsNOccurrencesOfSubStringBetweenCS(n, pcSubStr, pacBounds, pacBounds, pCaseSensitive)

			but isList(pacBounds) and Q(pacBounds).IsPairOfStrings()
				return This.ContainsNOccurrencesOfSubStringBetweenCS(n, pcSubStr, pacBounds[1], pacBounds[2], pCaseSensitive)

			else
				StzRaise("Incorrect param type! pacBounds must be a string or pair of strings.")
			ok

	#-- WITHOUT CASESENSITIVITY

	def ContainsNOccurrencesOfSubStringBetween(n, pcBound1, pcBound2)
		return This.ContainsNOccurrencesOfSubStringBetweenCS(n, pcBound1, pcBound2, :CaseSensitive = TRUE)

		def ContainsNOccurrencesOfSubStringBoundedBy(n, pacBounds)
			return This.ContainsNOccurrencesOfSubStringBoundedByCS(n, pacBounds, pCaseSenstive, :CaseSensitive = TRUE)

	   #-----------------------------------------------------------------------#
	  #  CHECKING IF THE STRING CONTAINS N OCCURRENCES OF A GIVEN SUBSTRING   #
	 #  BOUNDED BY TWO OTHER SubString STARTING AT A GIVEN POSITION          #
	#-----------------------------------------------------------------------#

	def ContainsNOccurrencesOfSubStringBetweenSCS(n, pcBound1, pcBound2, pnStartingAt, pCaseSensitive)
		/* ... */

		def ContainsNOccurrencesOfSubStringBoundedBySCS(n, pacBounds, pnStartingAt, pCaseSensitive)
			return This.ContainsNOccurrencesOfSubStringBetweenSCS(n, pcBound1, pcBound2, pnStartingAt, pCaseSensitive)

	#-- WITHOUT CASESENSITIVITY

	def ContainsNOccurrencesOfSubStringBetweenS(n, pcBound1, pcBound2, pnStartingAt)
		return This.ContainsNOccurrencesOfSubStringBetweenSCS(n, pcBound1, pcBound2, pnStartingAt, :CaseSensitive = TRUE)

		def ContainsNOccurrencesOfSubStringBoundedByS(n, pacBounds, pnStartingAt)
			return This.ContainsNOccurrencesOfSubStringBetweenS(n, pcBound1, pcBound2, pnStartingAt)

	  #=====================================================================#
	 #  FINDING OCCURRENCES OF A SUBSTRING BOUNDED BY TWO OTHER SubString  #
	#=====================================================================#

	def FindBetweenCS(pcSubStr, pcBound1, pcBound2, pCaseSensitive)
		/* ... */

		#< @FunctionAlternativeForms

		def FindSubStringBetweenCS(pcSubStr, pcBound1, pcBound2, pCaseSensitive)
			return This.FindBetween(pcSubStr, pcBound1, pcBound2, pCaseSensitive)

		def FindBoundedByCS(pcSubStr, pacBounds, pCaseSensitive, pCaseSensitive)
			if isString(pacBounds)
				return This.FindBetweenCS(pcSubStr, pacBounds, pacBounds, pCaseSensitive)

			but isList(pacBounds) and Q(pacBounds).IsPairOfStrings()
				return TThis.FindBetweenCS(pcSubStr, pacBounds[1], pacBounds[2], pCaseSensitive)

			else
				StzRaise("Incorrect param type! pacBounds must be a string or pair of strings.")
			ok

		def FindSubStringBoundedByCS(pcSubStr, pacBounds, pCaseSensitive)
			return This.FindBoundedByCS(pcSubStr, pacBounds, pCaseSensitive)

		#--
	
		def FindBetweenCSZ(pcSubStr, pcBound1, pcBound2, pCaseSensitive)
			return This.FindBetweenCS(pcSubStr, pcBound1, pcBound2, pCaseSensitive)

		def FindSubStringBetweenCSZ(pcSubStr, pcBound1, pcBound2, pCaseSensitive)
			return This.FindBetweenCS(pcSubStr, pcBound1, pcBound2, pCaseSensitive)

		def FindBoundedByCSZ(pcSubStr, pacBounds, pCaseSensitive)
			return This.FindBoundedByCS(pcSubStr, pacBounds, pCaseSensitive)

		def FindSubStringBoundedByCSZ(pcSubStr, pacBounds, pCaseSensitive)
			return This.FindBoundedByCS(pcSubStr, pacBound, pCaseSensitives)

		#==

		def SubStringBetweenCS(pcSubStr, pcBound1, pcBound2, pCaseSensitive)
			return This.FindBetweenCS(pcSubStr, pcBound1, pcBound2, pCaseSensitive)

		def SubstringBoundedByCS(pcSubStr, pacBounds, pCaseSensitive)
			return This.FindBoundedByCS(pcSubStr, pacBounds, pCaseSensitive)
	
		def SubStringBetweenCSZ(pcSubStr, pcBound1, pcBound2, pCaseSensitive)
			return This.FindBetweenCS(pcSubStr, pcBound1, pcBound2, pCaseSensitive)

		def SubStringBoundedByCSZ(pcSubStr, pacBounds, pCaseSensitive)
			return This.FindBoundedByCS(pcSubStr, pacBounds, pCaseSensitive)

		#>

	#-- WITHOUT CASESENSITIVE

	def FindBetween(pcSubStr, pcBound1, pcBound2)
		return This.FindBetweenCS(pcSubStr, pcBound1, pcBound1, :CaseSensitive = TRUE)

		#< @FunctionAlternativeForms

		def FindSubStringBetween(pcSubStr, pcBound1, pcBound2)
			return This.FindBetween(pcSubStr, pcBound1, pcBound2)

		def FindBoundedBy(pcSubStr, pacBounds)
			if isString(pacBounds)
				return This.FindBetween(pcSubStr, pacBounds, pacBounds)

			but isList(pacBounds) and Q(pacBounds).IsPairOfStrings()
				return TThis.FindBetween(pcSubStr, pacBounds[1], pacBounds[2])

			else
				StzRaise("Incorrect param type! pacBounds must be a string or pair of strings.")
			ok

		def FindSubStringBoundedBy(pcSubStr, pacBounds)
			return This.FindBoundedBy(pcSubStr, pacBounds)

		#--
	
		def FindBetweenZ(pcSubStr, pcBound1, pcBound2)
			return This.FindBetween(pcSubStr, pcBound1, pcBound2)

		def FindSubStringBetweenZ(pcSubStr, pcBound1, pcBound2)
			return This.FindBetween(pcSubStr, pcBound1, pcBound2)

		def FindBoundedByZ(pcSubStr, pacBounds)
			return This.FindBoundedBy(pcSubStr, pacBounds)

		def FindSubStringBoundedByZ(pcSubStr, pacBounds)
			return This.FindBoundedBy(pcSubStr, pacBounds)

		#==

		def SubStringBetween(pcSubStr, pcBound1, pcBound2)
			return This.FindBetween(pcSubStr, pcBound1, pcBound2)

		def SubstringBoundedBy(pcSubStr, pacBounds)
			return This.FindBoundedBy(pcSubStr, pacBounds)
	
		def SubStringBetweenZ(pcSubStr, pcBound1, pcBound2)
			return This.FindBetween(pcSubStr, pcBound1, pcBound2)

		def SubStringBoundedByZ(pcSubStr, pacBounds)
			return This.FindBoundedBy(pcSubStr, pacBounds)

		#>

	   #------------------------------------------------------#
	  #  FINDING A SUBSTRING BOUNDED BY TWO OTHER SubString  #
	 #  AND RETURNING THEM AS SECTIONS                      #
	#------------------------------------------------------#

	def FindBetweenCSZZ(pcSubStr, pcBound1, pcBound2, pCaseSensitive)
		/* ... */

		#< @FunctionAlternativeForms

		def FindSubStringBetweenCSZZ(pcSubStr, pcBound1, pcBound2, pCaseSensitive)
			return This.FindBetweenCSZZ(pcSubStr, pcBound1, pcBound2, pCaseSensitive)

		def FindBoundedByCSZZ(pcSubStr, pacBounds, pCaseSensitive)
			if isString(pacBounds)
				return This.FindBetweenCSZZ(pcSubStr, pcBounds, pcBounds, pCaseSensitive)

			but isList(pacBounds) and Q(pacBounds).IsPairOfStrings()
				return This.FindBetweenCSZZ(pcSubStr, pcBounds[1], pcBounds[2], pCaseSensitive)

			else
				StzRaise("Incorrect param type! pacBounds must be a string or pair of strings.")
			ok

		def FindSubStringBoundedByCSZZ(pcSubStr, pacBounds, pCaseSensitive)
			return This.FindBoundedByCSZZ(pcSubStr, pacBounds, pCaseSensitive)

		#--
	
		def FindBetweenAsSectionsCS(pcSubStr, pcBound1, pcBound2, pCaseSensitive)
			return This.FindBetweenCSZZ(pcSubStr, pcBound1, pcBound2, pCaseSensitive)

		def FindSubStringBetweenAsSectionsCS(pcSubStr, pcBound1, pcBound2, pCaseSensitive)
			return This.FindBetweenCSZZ(pcSubStr, pcBound1, pcBound2, pCaseSensitive)

		def FindBoundedByAsSectionsCS(pcSubStr, pacBounds, pCaseSensitive)
			return This.FindBoundedByCSZZ(pcSubStr, pacBounds, pCaseSensitive)

		def FindSubStringBoundedByAsSectionsCS(pcSubStr, pacBounds, pCaseSensitive)
			return This.FindBoundedByCSZZ(pcSubStr, pacBounds, pCaseSensitive)

		#==

		def SubStringBetweenCSZZ(pcSubStr, pcBound1, pcBound2, pCaseSensitive)
			return This.FindBetweenCSZZ(pcSubStr, pcBound1, pcBound2, pCaseSensitive)

		def SubStringBoundedByCSZZ(pcSubStr, pacBounds, pCaseSensitive)
			return This.FindBoundedByCSZZ(pcSubStr, pacBounds, pCaseSensitive)

		def SubStringBetweenAsSectionsCS(pcSubStr, pcBound1, pcBound2, pCaseSensitive)
			return This.FindBetweenCSZZ(pcSubStr, pcBound1, pcBound2, pCaseSensitive)

		def SubStringBoundedByAsSectionsCS(pcSubStr, pacBounds, pCaseSensitive)
			return This.FindBoundedByCSZZ(pcSubStr, pacBounds, pCaseSensitive)

		#>

	#-- WITHOUT CASESENSITIVITY

	def FindBetweenZZ(pcSubStr, pcBound1, pcBound2)
		return This.FindBetweenCSZZ(pcSubStr, pcBound1, pcBound2, :CaseSensitive = TRUE)

		#< @FunctionAlternativeForms

		def FindSubStringBetweenZZ(pcSubStr, pcBound1, pcBound2)
			return This.FindBetweenZZ(pcSubStr, pcBound1, pcBound2)

		def FindBoundedByZZ(pcSubStr, pacBounds)
			return This.FindBoundedByCSZZ(pcSubStr, pacBounds, :CaseSensitive = TRUE)

		def FindSubStringBoundedByZZ(pcSubStr, pacBounds)
			return This.FindBoundedByZZ(pcSubStr, pacBounds)

		#--
	
		def FindBetweenAsSections(pcSubStr, pcBound1, pcBound2)
			return This.FindBetweenZZ(pcSubStr, pcBound1, pcBound2)

		def FindSubStringBetweenAsSections(pcSubStr, pcBound1, pcBound2)
			return This.FindBetweenZZ(pcSubStr, pcBound1, pcBound2)

		def FindBoundedByAsSections(pcSubStr, pacBounds)
			return This.FindBoundedByZZ(pcSubStr, pacBounds)

		def FindSubStringBoundedByAsSections(pcSubStr, pacBounds)
			return This.FindBoundedByZZ(pcSubStr, pacBounds)

		#==

		def SubStringBetweenZZ(pcSubStr, pcBound1, pcBound2)
			return This.FindBetweenZZ(pcSubStr, pcBound1, pcBound2)

		def SubStringBoundedByZZ(pcSubStr, pacBounds)
			return This.FindBoundedByZZ(pcSubStr, pacBounds)

		def SubStringBetweenAsSections(pcSubStr, pcBound1, pcBound2)
			return This.FindBetweenZZ(pcSubStr, pcBound1, pcBound2)

		def SubStringBoundedByAsSections(pcSubStr, pacBounds)
			return This.FindBoundedByZZ(pcSubStr, pacBounds)

		#>

	  #-----------------------------------------------------------------------#
	 #  FINDING A SUBSTRING BOUNDED BY TWO OTHER SubString INCLUDING BOUNDS  #
	#-----------------------------------------------------------------------#

	def FindBetweenCSIB(pcSubStr, pcBound1, pcBound2, pCaseSensitive)
		/* ... */

		#< @FunctionAlternativeForms

		def FindSubStringBetweenCSIB(pcSubStr, pcBound1, pcBound2, pCaseSensitive)
			return This.FindBetweenIB(pcSubStr, pcBound1, pcBound2, pCaseSensitive)

		def FindBoundedByCSIB(pcSubStr, pacBounds, pCaseSensitive, pCaseSensitive)
			if isString(pacBounds)
				return This.FindBetweenCSIB(pcSubStr, pacBounds, pacBounds, pCaseSensitive)

			but isList(pacBounds) and Q(pacBounds).IsPairOfStrings()
				return TThis.FindBetweenCSIB(pcSubStr, pacBounds[1], pacBounds[2], pCaseSensitive)

			else
				StzRaise("Incorrect param type! pacBounds must be a string or pair of strings.")
			ok

		def FindSubStringBoundedByCSIB(pcSubStr, pacBounds, pCaseSensitive)
			return This.FindBoundedByCSIB(pcSubStr, pacBounds, pCaseSensitive)

		#--
	
		def FindBetweenCSZIB(pcSubStr, pcBound1, pcBound2, pCaseSensitive)
			return This.FindBetweenCSIB(pcSubStr, pcBound1, pcBound2, pCaseSensitive)

		def FindSubStringBetweenCSIBZ(pcSubStr, pcBound1, pcBound2, pCaseSensitive)
			return This.FindBetweenCSIB(pcSubStr, pcBound1, pcBound2, pCaseSensitive)

		def FindBoundedByCSIBZ(pcSubStr, pacBounds, pCaseSensitive)
			return This.FindBoundedByCSIB(pcSubStr, pacBounds, pCaseSensitive)

		def FindSubStringBoundedByCSIBZ(pcSubStr, pacBounds, pCaseSensitive)
			return This.FindBoundedByCSIB(pcSubStr, pacBound, pCaseSensitives)

		#==

		def SubStringBetweenCSIB(pcSubStr, pcBound1, pcBound2, pCaseSensitive)
			return This.FindBetweenCSIB(pcSubStr, pcBound1, pcBound2, pCaseSensitive)

		def SubstringBoundedByCSIB(pcSubStr, pacBounds, pCaseSensitive)
			return This.FindBoundedByCSIB(pcSubStr, pacBounds, pCaseSensitive)
	
		def SubStringBetweenCSIBZ(pcSubStr, pcBound1, pcBound2, pCaseSensitive)
			return This.FindBetweenCSIB(pcSubStr, pcBound1, pcBound2, pCaseSensitive)

		def SubStringBoundedByCSIBZ(pcSubStr, pacBounds, pCaseSensitive)
			return This.FindBoundedByCSIB(pcSubStr, pacBounds, pCaseSensitive)

		#>

	#-- WITHOUT CASESENSITIVE

	def FindBetweenIB(pcSubStr, pcBound1, pcBound2)
		return This.FindBetweenCSIB(pcSubStr, pcBound1, pcBound2, :CaseSensitive = TRUE)

		#< @FunctionAlternativeForms

		def FindSubStringBetweenIB(pcSubStr, pcBound1, pcBound2)
			return This.FindBetweenIB(pcSubStr, pcBound1, pcBound2)

		def FindBoundedByIB(pcSubStr, pacBounds)
			if isString(pacBounds)
				return This.FindBetweenIB(pcSubStr, pacBounds, pacBounds)

			but isList(pacBounds) and Q(pacBounds).IsPairOfStrings()
				return TThis.FindBetweenIB(pcSubStr, pacBounds[1], pacBounds[2])

			else
				StzRaise("Incorrect param type! pacBounds must be a string or pair of strings.")
			ok

		def FindSubStringBoundedByIB(pcSubStr, pacBounds)
			return This.FindBoundedByIB(pcSubStr, pacBounds)

		#--
	
		def FindBetweenZIB(pcSubStr, pcBound1, pcBound2)
			return This.FindBetweenIB(pcSubStr, pcBound1, pcBound2)

		def FindSubStringBetweenZIB(pcSubStr, pcBound1, pcBound2)
			return This.FindBetweenIB(pcSubStr, pcBound1, pcBound2)

		def FindBoundedByZIB(pcSubStr, pacBounds)
			return This.FindBoundedByIB(pcSubStr, pacBounds)

		def FindSubStringBoundedByZIB(pcSubStr, pacBounds)
			return This.FindBoundedByIB(pcSubStr, pacBounds)

		#==

		def SubStringBetweenIB(pcSubStr, pcBound1, pcBound2)
			return This.FindBetweenIB(pcSubStr, pcBound1, pcBound2)

		def SubstringBoundedByIB(pcSubStr, pacBounds)
			return This.FindBoundedByIB(pcSubStr, pacBounds)
	
		def SubStringBetweenZIB(pcSubStr, pcBound1, pcBound2)
			return This.FindBetweenIB(pcSubStr, pcBound1, pcBound2)

		def SubStringBoundedByZIB(pcSubStr, pacBounds)
			return This.FindBoundedByIB(pcSubStr, pacBounds)

		#>

	   #---------------------------------------------------------------#
	  #  FINDING A SUBSTRING BOUNDED BY TWO OTHER SubString          #
	 #  INCLUDING BOUNDS AND RETURNING THEIR POSITIONS AS SECTIONS   #                                    #
	#---------------------------------------------------------------#

	def FindBetweenCSIBZZ(pcSubStr, pcBound1, pcBound2, pCaseSensitive)
		/* ... */

		#< @FunctionAlternativeForms

		def FindSubStringBetweenCSIBZZ(pcSubStr, pcBound1, pcBound2, pCaseSensitive)
			return This.FindBetweenCSIBZZ(pcSubStr, pcBound1, pcBound2, pCaseSensitive)

		def FindBoundedByCSIBZZ(pcSubStr, pacBounds, pCaseSensitive)
			if isString(pacBounds)
				return This.FindBetweenCSIBZZ(pcSubStr, pcBounds, pcBounds, pCaseSensitive)

			but isList(pacBounds) and Q(pacBounds).IsPairOfStrings()
				return This.FindBetweenCSIBZZ(pcSubStr, pcBounds[1], pcBounds[2], pCaseSensitive)

			else
				StzRaise("Incorrect param type! pacBounds must be a string or pair of strings.")
			ok

		def FindSubStringBoundedByCSIBZZ(pcSubStr, pacBounds, pCaseSensitive)
			return This.FindBoundedByCSIBZZ(pcSubStr, pacBounds, pCaseSensitive)

		#--
	
		def FindBetweenAsSectionsCSIB(pcSubStr, pcBound1, pcBound2, pCaseSensitive)
			return This.FindBetweenCSIBZZ(pcSubStr, pcBound1, pcBound2, pCaseSensitive)

		def FindSubStringBetweenAsSectionsCSIB(pcSubStr, pcBound1, pcBound2, pCaseSensitive)
			return This.FindBetweenCSIBZZ(pcSubStr, pcBound1, pcBound2, pCaseSensitive)

		def FindBoundedByAsSectionsCSIB(pcSubStr, pacBounds, pCaseSensitive)
			return This.FindBoundedByCSIBZZ(pcSubStr, pacBounds, pCaseSensitive)

		def FindSubStringBoundedByAsSectionsCSIB(pcSubStr, pacBounds, pCaseSensitive)
			return This.FindBoundedByCSIBZZ(pcSubStr, pacBounds, pCaseSensitive)

		#==

		def SubStringBetweenCSIBZZ(pcSubStr, pcBound1, pcBound2, pCaseSensitive)
			return This.FindBetweenCSIBZZ(pcSubStr, pcBound1, pcBound2, pCaseSensitive)

		def SubStringBoundedByCSIBZZ(pcSubStr, pacBounds, pCaseSensitive)
			return This.FindBoundedByCSIBZZ(pcSubStr, pacBounds, pCaseSensitive)

		def SubStringBetweenAsSectionsCSIB(pcSubStr, pcBound1, pcBound2, pCaseSensitive)
			return This.FindBetweenCSIBZZ(pcSubStr, pcBound1, pcBound2, pCaseSensitive)

		def SubStringBoundedByAsSectionsCSIB(pcSubStr, pacBounds, pCaseSensitive)
			return This.FindBoundedByCSIBZZ(pcSubStr, pacBounds, pCaseSensitive)

		#>

	#-- WITHOUT CASESENSITIVITY

	def FindBetweenZZIB(pcSubStr, pcBound1, pcBound2)
		return This.FindBetweenCSIBZZ(pcSubStr, pcBound1, pcBound2, :CaseSensitive = TRUE)

		#< @FunctionAlternativeForms

		def FindSubStringBetweenIBZZ(pcSubStr, pcBound1, pcBound2)
			return This.FindBetweenIBZZ(pcSubStr, pcBound1, pcBound2)

		def FindBoundedByIBZZ(pcSubStr, pacBounds)
			return This.FindBoundedByCSIBZZ(pcSubStr, pacBounds, :CaseSensitive = TRUE)

		def FindSubStringBoundedByIBZZ(pcSubStr, pacBounds)
			return This.FindBoundedByIBZZ(pcSubStr, pacBounds)

		#--
	
		def FindBetweenAsSectionsIB(pcSubStr, pcBound1, pcBound2)
			return This.FindBetweenIBZZ(pcSubStr, pcBound1, pcBound2)

		def FindSubStringBetweenAsSectionsIB(pcSubStr, pcBound1, pcBound2)
			return This.FindBetweenIBZZ(pcSubStr, pcBound1, pcBound2)

		def FindBoundedByAsSectionsIB(pcSubStr, pacBounds)
			return This.FindBoundedByIBZZ(pcSubStr, pacBounds)

		def FindSubStringBoundedByAsSectionsIB(pcSubStr, pacBounds)
			return This.FindBoundedByIBZZ(pcSubStr, pacBounds)

		#==

		def SubStringBetweenIBZZ(pcSubStr, pcBound1, pcBound2)
			return This.FindBetweenIBZZ(pcSubStr, pcBound1, pcBound2)

		def SubStringBoundedByIBZZ(pcSubStr, pacBounds)
			return This.FindBoundedByIBZZ(pcSubStr, pacBounds)

		def SubStringBetweenAsSectionsIB(pcSubStr, pcBound1, pcBound2)
			return This.FindBetweenIBZZ(pcSubStr, pcBound1, pcBound2)

		def SubStringBoundedByAsSectionsIB(pcSubStr, pacBounds)
			return This.FindBoundedByIBZZ(pcSubStr, pacBounds)

		#>
		
	   #------------------------------------------------------#
	  #  FINDING A SUBSTRING BOUNDED BY TWO OTHER SubString  #
	 #  STARTING AT A GIVEN POSITION                        #
	#------------------------------------------------------#

	def FindBetweenSCS(pcSubStr, pcBound1, pcBound2, pnStartingAt, pCaseSensitive)
		/* ... */

		def FindSubStringBetweenSCS(pcSubStr, pcBound1, pcBound2, pnStartingAt, pCaseSensitive)
			return This.FindBetweenSCS(pcSubStr, pcBound1, pcBound2, pnStartingAt, pCaseSensitive)

		def FindBoundedBySCS(pcSubStr, pacBounds, pnStartingAt, pCaseSensitive)
			if isString(pacBounds)
				return This.FindBetweenSCS(pcSubStr, pacBounds, pacBounds, pnStartingAt, pCaseSensitive)

			but isList(pacBounds) and Q(pacBounds).IsPairOfStrings()
				return This.FindBetweenSCS(pcSubStr, pacBounds[1], pacBounds[2], pnStartingAt, pCaseSensitive)

			else
				StzRaise("Incorrect param type! pacBounds must be a string or pair of strings.")
			ok

		def FindSubStringBoundedBySCS(pcSubStr, pacBounds, pnStartingAt, pCaseSensitive)
			return This.FindBoundedBySCS(pcSubStr, pacBounds, pnStartingAt, pCaseSensitive)

		#--
	
		def FindBetweenSCSZ(pcSubStr, pcBound1, pcBound2, pnStartingAt, pCaseSensitive)
			return This.FindBetweenSCS(pcSubStr, pcBound1, pcBound2, pnStartingAt, pCaseSensitive)

		def FindSubStringBetweenSCSZ(pcSubStr, pcBound1, pcBound2, pnStartingAt, pCaseSensitive)
			return This.FindBetweenSCS(pcSubStr, pcBound1, pcBound2, pnStartingAt, pCaseSensitive)

		def FindBoundedBySCSZ(pcSubStr, pacBounds, pnStartingAt, pCaseSensitive)
			return This.FindBoundedBySCS(pcSubStr, pacBounds, pnStartingAt, pCaseSensitive)

		def FindSubStringBoundedBySCSZ(pcSubStr, pacBounds, pnStartingAt, pCaseSensitive)
			return This.FindBoundedBySCS(pcSubStr, pacBounds, pnStartingAt, pCaseSensitive)

		#==

		def SubStringBetweenSCS(pcSubStr, pcBound1, pcBound2, pnStartingAt, pCaseSensitive)
			return This.FindBetweenSCS(pcSubStr, pcBound1, pcBound2, pnStartingAt, pCaseSensitive)

		def SubStringBoundedBySCS(pcSubStr, pacBounds, pnStartingAt, pCaseSensitive)
			return This.FindBoundedBySCS(pcSubStr, pacBounds, pnStartingAt, pCaseSensitive)

		def SubStringBetweenSCSZ(pcSubStr, pcBound1, pcBound2, pnStartingAt, pCaseSensitive)
			return This.FindBetweenSCS(pcSubStr, pcBound1, pcBound2, pnStartingAt, pCaseSensitive)

		def SubStringBoundedBySCSZ(pcSubStr, pacBounds, pnStartingAt, pCaseSensitive)
			return This.FindBoundedBySCS(pcSubStr, pacBounds, pnStartingAt, pCaseSensitive)

		#>

	#-- WITHOUT CASESENSITIVITY

	def FindBetweenS(pcSubStr, pcBound1, pcBound2, pnStartingAt)
		return This.FindBetweenSCS(pcSubStr, pcBound1, pcBound2, pnStartingAt, :CaseSensitive = TRUE)

		def FindSubStringBetweenS(pcSubStr, pcBound1, pcBound2, pnStartingAt)
			return This.FindBetweenS(pcSubStr, pcBound1, pcBound2, pnStartingAt)

		def FindBoundedByS(pcSubStr, pacBounds, pnStartingAt)
			return This.FindBoundedBySCS(pcSubStr, pacBounds, pnStartingAt, pCaseSensitive)

		def FindSubStringBoundedByS(pcSubStr, pacBounds, pnStartingAt)
			return This.FindBoundedByS(pcSubStr, pacBounds, pnStartingAt)

		#--
	
		def FindBetweenSZ(pcSubStr, pcBound1, pcBound2, pnStartingAt)
			return This.FindBetweenS(pcSubStr, pcBound1, pcBound2, pnStartingAt)

		def FindSubStringBetweenSZ(pcSubStr, pcBound1, pcBound2, pnStartingAt)
			return This.FindBetweenS(pcSubStr, pcBound1, pcBound2, pnStartingAt)

		def FindBoundedBySZ(pcSubStr, pacBounds, pnStartingAt)
			return This.FindBoundedByS(pcSubStr, pacBounds, pnStartingAt)

		def FindSubStringBoundedBySZ(pcSubStr, pacBounds, pnStartingAt)
			return This.FindBoundedByS(pcSubStr, pacBounds, pnStartingAt)

		#==

		def SubStringBetweenS(pcSubStr, pcBound1, pcBound2, pnStartingAt)
			return This.FindBetweenS(pcSubStr, pcBound1, pcBound2, pnStartingAt)

		def SubStringBoundedByS(pcSubStr, pacBounds, pnStartingAt)
			return This.FindBoundedByS(pcSubStr, pacBounds, pnStartingAt)

		def SubStringBetweenSZ(pcSubStr, pcBound1, pcBound2, pnStartingAt)
			return This.FindBetweenS(pcSubStr, pcBound1, pcBound2, pnStartingAt)

		def SubStringBoundedBySZ(pcSubStr, pacBounds, pnStartingAt)
			return This.FindBoundedByS(pcSubStr, pacBounds, pnStartingAt)

		#>

	   #------------------------------------------------------------------#
	  #  FINDING A SUBSTRING BOUNDED BY TWO OTHER SubString STARTING AT  #
	 #  A GIVEN POSITION AND RETURNING POSITIONS AS SECTIONS            #
	#------------------------------------------------------------------#

	def FindBetweenSCSZZ(pcSubStr, pcBound1, pcBound2, pnStartingAt, pCaseSensitive)
		/* ... */

		#< @FunctionAlternativeForms

		def FindSubStringBetweenSCSZZ(pcSubStr, pcBound1, pcBound2, pnStartingAt, pCaseSensitive)
			return This.FindBetweenSCSZZ(pcSubStr, pcBound1, pcBound2, pnStartingAt, pCaseSensitive)

		def FindBoundedBySCSZZ(pcSubStr, pacBounds, pnStartingAt, pCaseSensitive)
			if isString(pacBounds)
				return This.FindBetweenSCSZZ(pcSubStr, pacBounds, pacBounds, pnStartingAt, pCaseSensitive)

			but isList(pacBounds) and Q(pacBounds).isPairOfStrings()
				return This.FindBetweenSCSZZ(pcSubStr, pacBounds[1], pacBounds[2], pnStartingAt, pCaseSensitive)

			else
				StzRaise("Incorrect param type! pacBounds must be a string or pair of strings.")
			ok

		def FindSubStringBoundedBySCSZZ(pcSubStr, pacBounds, pnStartingAt, pCaseSensitive)
			return This.FindBoundedBySCSZZ(pcSubStr, pacBounds, pnStartingAt, pCaseSensitive)

		#--
	
		def FindBetweenAsSectionsSCS(pcSubStr, pcBound1, pcBound2, pnStartingAt, pCaseSensitive)
			return This.FindBetweenSCSZZ(pcSubStr, pcBound1, pcBound2, pnStartingAt, pCaseSensitive)

		def FindSubStringBetweenAsSectionsSCS(pcSubStr, pcBound1, pcBound2, pnStartingAt, pCaseSensitive)
			return This.FindBetweenSCSZZ(pcSubStr, pcBound1, pcBound2, pnStartingAt, pCaseSensitive)

		def FindBoundedByAsSectionsSCS(pcSubStr, pacBounds, pnStartingAt, pCaseSensitive)
			return This.FindBoundedBySCSZZ(pcSubStr, pacBounds, pnStartingAt, pCaseSensitive)

		def FindSubStringBoundedByAsSectionsSCS(pcSubStr, pacBounds, pnStartingAt, pCaseSensitive)
			return This.FindBoundedBySCSZZ(pcSubStr, pacBounds, pnStartingAt, pCaseSensitive)

		#==

		def SubStringBetweenSCSZZ(pcSubStr, pcBound1, pcBound2, pnStartingAt, pCaseSensitive)
			return This.FindBetweenSCSZZ(pcSubStr, pcBound1, pcBound2, pnStartingAt, pCaseSensitive)

		def SubStringBoundedBySCSZZ(pcSubStr, pacBounds, pnStartingAt, pCaseSensitive)
			return This.FindBoundedBySCSZZ(pcSubStr, pacBounds, pnStartingAt, pCaseSensitive)

		def SubStringBetweenAsSectionsSCS(pcSubStr, pcBound1, pcBound2, pnStartingAt, pCaseSensitive)
			return This.FindBetweenSCSZZ(pcSubStr, pcBound1, pcBound2, pnStartingAt, pCaseSensitive)

		def SubStringBoundedByAsSectionsSCS(pcSubStr, pacBounds, pnStartingAt, pCaseSensitive)
			return This.FindBoundedBySCSZZ(pcSubStr, pacBounds, pnStartingAt, pCaseSensitive)

		#>

	#--

	def FindBetweenSZZ(pcSubStr, pcBound1, pcBound2, pnStartingAt)
		return This.FindBetweenSCSZZ(pcSubStr, pcBound1, pcBound2, pnStartingAt, :CaseSensitive = TRUE)

		#< @FunctionAlternativeForms

		def FindSubStringBetweenSZZ(pcSubStr, pcBound1, pcBound2, pnStartingAt)
			return This.FindBetweenSZZ(pcSubStr, pcBound1, pcBound2, pnStartingAt)

		def FindBoundedBySZZ(pcSubStr, pacBounds, pnStartingAt)
			return This.FindBoundedBySCSZZ(pcSubStr, pacBounds, pnStartingAt, :CaseSensitive = TRUE)

		def FindSubStringBoundedBySZZ(pcSubStr, pacBounds, pnStartingAt)
			return This.FindBoundedBySZZ(pcSubStr, pacBounds, pnStartingAt)

		#--
	
		def FindBetweenAsSectionsS(pcSubStr, pcBound1, pcBound2, pnStartingAt)
			return This.FindBetweenSZZ(pcSubStr, pcBound1, pcBound2, pnStartingAt)

		def FindSubStringBetweenAsSectionsS(pcSubStr, pcBound1, pcBound2, pnStartingAt)
			return This.FindBetweenSZZ(pcSubStr, pcBound1, pcBound2, pnStartingAt)

		def FindBoundedByAsSectionsS(pcSubStr, pacBounds, pnStartingAt)
			return This.FindBoundedBySZZ(pcSubStr, pacBounds, pnStartingAt)

		def FindSubStringBoundedByAsSectionsS(pcSubStr, pacBounds, pnStartingAt)
			return This.FindBoundedBySZZ(pcSubStr, pacBounds, pnStartingAt)

		#==

		def SubStringBetweenSZZ(pcSubStr, pcBound1, pcBound2, pnStartingAt)
			return This.FindBetweenSZZ(pcSubStr, pcBound1, pcBound2, pnStartingAt)

		def SubStringBoundedBySZZ(pcSubStr, pacBounds, pnStartingAt)
			return This.FindBoundedBySZZ(pcSubStr, pacBounds, pnStartingAt)

		def SubStringBetweenAsSectionsS(pcSubStr, pcBound1, pcBound2, pnStartingAt)
			return This.FindBetweenSZZ(pcSubStr, pcBound1, pcBound2, pnStartingAt)

		def SubStringBoundedByAsSectionsS(pcSubStr, pacBounds, pnStartingAt)
			return This.FindBoundedBySZZ(pcSubStr, pacBounds, pnStartingAt)

		#>

	   #-------------------------------------------------------#
	  #  FINDING A SUBSTRING BOUNDED BY TWO OTHER SubString   #
	 #  STARTING AT A GIVEN POSITION AND INCLUDING BOUNDS    #
	#-------------------------------------------------------#

	def FindBetweenSCSIB(pcSubStr, pcBound1, pcBound2, pnStartingAt, pCaseSensitive)
		/* ... */

		def FindSubStringBetweenSCSIB(pcSubStr, pcBound1, pcBound2, pnStartingAt, pCaseSensitive)
			return This.FindBetweenSCSOB(pcSubStr, pcBound1, pcBound2, pnStartingAt, pCaseSensitive)

		def FindBoundedBySCSIB(pcSubStr, pacBounds, pnStartingAt, pCaseSensitive)
			if isString(pacBounds)
				return This.FindBetweenSCSIB(pcSubStr, pacBounds, pacBounds, pnStartingAt, pCaseSensitive)

			but isList(pacBounds) and Q(pacBounds).IsPairOfStrings()
				return This.FindBetweenSCSIB(pcSubStr, pacBounds[1], pacBounds[2], pnStartingAt, pCaseSensitive)

			else
				StzRaise("Incorrect param type! pacBounds must be a string or pair of strings.")
			ok

		def FindSubStringBoundedBySCSIB(pcSubStr, pacBounds, pnStartingAt, pCaseSensitive)
			return This.FindBoundedBySCSIB(pcSubStr, pacBounds, pnStartingAt, pCaseSensitive)

		#--
	
		def FindBetweenSIBCSZ(pcSubStr, pcBound1, pcBound2, pnStartingAt, pCaseSensitive)
			return This.FindBetweenSIBCS(pcSubStr, pcBound1, pcBound2, pnStartingAt, pCaseSensitive)

		def FindSubStringBetweenSCSIBZ(pcSubStr, pcBound1, pcBound2, pnStartingAt, pCaseSensitive)
			return This.FindBetweenSCSIB(pcSubStr, pcBound1, pcBound2, pnStartingAt, pCaseSensitive)

		def FindBoundedBySCSIBZ(pcSubStr, pacBounds, pnStartingAt, pCaseSensitive)
			return This.FindBoundedBySCSIB(pcSubStr, pacBounds, pnStartingAt, pCaseSensitive)

		def FindSubStringBoundedBySCSIBZ(pcSubStr, pacBounds, pnStartingAt, pCaseSensitive)
			return This.FindBoundedBySCSIB(pcSubStr, pacBounds, pnStartingAt, pCaseSensitive)

		#==

		def SubStringBetweenSCSIB(pcSubStr, pcBound1, pcBound2, pnStartingAt, pCaseSensitive)
			return This.FindBetweenSCSIB(pcSubStr, pcBound1, pcBound2, pnStartingAt, pCaseSensitive)

		def SubStringBoundedBySCSIB(pcSubStr, pacBounds, pnStartingAt, pCaseSensitive)
			return This.FindBoundedBySCSIB(pcSubStr, pacBounds, pnStartingAt, pCaseSensitive)

		def SubStringBetweenSCSIBZ(pcSubStr, pcBound1, pcBound2, pnStartingAt, pCaseSensitive)
			return This.FindBetweenSCSIB(pcSubStr, pcBound1, pcBound2, pnStartingAt, pCaseSensitive)

		def SubStringBoundedBySCSIBZ(pcSubStr, pacBounds, pnStartingAt, pCaseSensitive)
			return This.FindBoundedBySCSIB(pcSubStr, pacBounds, pnStartingAt, pCaseSensitive)

		#>

	#-- WITHOUT CASESENSITIVITY

	def FindBetweenSIB(pcSubStr, pcBound1, pcBound2, pnStartingAt)
		return This.FindBetweenSCSIB(pcSubStr, pcBound1, pcBound2, pnStartingAt, :CaseSensitive = TRUE)

		def FindSubStringBetweenSIB(pcSubStr, pcBound1, pcBound2, pnStartingAt)
			return This.FindBetweenSIB(pcSubStr, pcBound1, pcBound2, pnStartingAt)

		def FindBoundedBySIB(pcSubStr, pacBounds, pnStartingAt)
			return This.FindBoundedBySCSIB(pcSubStr, pacBounds, pnStartingAt, pCaseSensitive)

		def FindSubStringBoundedBySIB(pcSubStr, pacBounds, pnStartingAt)
			return This.FindBoundedBySIB(pcSubStr, pacBounds, pnStartingAt)

		#--
	
		def FindBetweenSIBZ(pcSubStr, pcBound1, pcBound2, pnStartingAt)
			return This.FindBetweenSIB(pcSubStr, pcBound1, pcBound2, pnStartingAt)

		def FindSubStringBetweenSIBZ(pcSubStr, pcBound1, pcBound2, pnStartingAt)
			return This.FindBetweenSIB(pcSubStr, pcBound1, pcBound2, pnStartingAt)

		def FindBoundedBySIBZ(pcSubStr, pacBounds, pnStartingAt)
			return This.FindBoundedBySIB(pcSubStr, pacBounds, pnStartingAt)

		def FindSubStringBoundedBySIBZ(pcSubStr, pacBounds, pnStartingAt)
			return This.FindBoundedBySIB(pcSubStr, pacBounds, pnStartingAt)

		#==

		def SubStringBetweenSIB(pcSubStr, pcBound1, pcBound2, pnStartingAt)
			return This.FindBetweenSIB(pcSubStr, pcBound1, pcBound2, pnStartingAt)

		def SubStringBoundedBySIB(pcSubStr, pacBounds, pnStartingAt)
			return This.FindBoundedBySIB(pcSubStr, pacBounds, pnStartingAt)

		def SubStringBetweenSIBZ(pcSubStr, pcBound1, pcBound2, pnStartingAt)
			return This.FindBetweenSIB(pcSubStr, pcBound1, pcBound2, pnStartingAt)

		def SubStringBoundedBySIBZ(pcSubStr, pacBounds, pnStartingAt)
			return This.FindBoundedBySIB(pcSubStr, pacBounds, pnStartingAt)

		#>

	    #---------------------------------------------------------------------------#
	   #  FINDING A SUBSTRING BOUNDED BY TWO OTHER SubString STARTING AT A GIVEN   #
	  #  POSITION, INCLUDING BOUNDS, AND RETURNING THE POSITIONS AS SECTIONS      #                               #
	#----------------------------------------------------------------------------#

	def FindBetweenSCSIBZZ(pcSubStr, pcBound1, pcBound2, pnStartingAt, pCaseSensitive)
		/* ... */

		#< @FunctionAlternativeForms

		def FindSubStringBetweenSCSIBZZ(pcSubStr, pcBound1, pcBound2, pnStartingAt, pCaseSensitive)
			return This.FindBetweenSCSIBZZ(pcSubStr, pcBound1, pcBound2, pnStartingAt, pCaseSensitive)

		def FindBoundedBySCSIBZZ(pcSubStr, pacBounds, pnStartingAt, pCaseSensitive)
			if isString(pacBounds)
				return This.FindBetweenSCSIBZZ(pcSubStr, pacBounds, pacBounds, pnStartingAt, pCaseSensitive)

			but isList(pacBounds) and Q(pacBounds).IsPairOfStrings()
				return This.FindBetweenSCSIBZZ(pcSubStr, pacBounds[1], pacBounds[2], pnStartingAt, pCaseSensitive)

			else
				StzRaise("Incorrect param type! pacBounds must be string or pair of strings.")

			ok

		def FindSubStringBoundedBySCSIBZZ(pcSubStr, pacBounds, pnStartingAt, pCaseSensitive)
			return This.FindBoundedBySCSIBZZ(pcSubStr, pacBounds, pnStartingAt, pCaseSensitive)

		#--
	
		def FindBetweenAsSectionsSCSIB(pcSubStr, pcBound1, pcBound2, pnStartingAt, pCaseSensitive)
			return This.FindBetweenSCSIBZZ(pcSubStr, pcBound1, pcBound2, pnStartingAt, pCaseSensitive)

		def FindSubStringBetweenAsSectionsSCSIB(pcSubStr, pcBound1, pcBound2, pnStartingAt, pCaseSensitive)
			return This.FindBetweenSCSIBZZ(pcSubStr, pcBound1, pcBound2, pnStartingAt, pCaseSensitive)

		def FindBoundedByAsSectionsSCSIBZZ(pcSubStr, pacBounds, pnStartingAt, pCaseSensitive)
			return This.FindBoundedBySCSIBZZ(pcSubStr, pacBounds, pnStartingAt, pCaseSensitive)

		def FindSubStringBoundedByAsSectionsSCSIB(pcSubStr, pacBounds, pnStartingAt, pCaseSensitive)
			return This.FindBoundedBySCSIBZZ(pcSubStr, pacBounds, pnStartingAt, pCaseSensitive)

		#==

		def SubStringBetweenSCSIBZZ(pcSubStr, pcBound1, pcBound2, pnStartingAt, pCaseSensitive)
			return This.FindBetweenSCSIBZZ(pcSubStr, pcBound1, pcBound2, pnStartingAt, pCaseSensitive)

		def SubStringBoundedBySCSIBZZ(pcSubStr, pacBounds, pnStartingAt, pCaseSensitive)
			return This.FindBoundedBySCSIBZZ(pcSubStr, pacBounds, pnStartingAt, pCaseSensitive)

		def SubStringBetweenAsSectionsSCSIB(pcSubStr, pcBound1, pcBound2, pnStartingAt, pCaseSensitive)
			return This.FindBetweenSIBCSZZ(pcSubStr, pcBound1, pcBound2, pnStartingAt, pCaseSensitive)

		def SubStringBoundedByAsSectionsSCSIB(pcSubStr, pacBounds, pnStartingAt, pCaseSensitive)
			return This.FindBoundedBySCSIBZZ(pcSubStr, pacBounds, pnStartingAt, pCaseSensitive)

		#>

	#-- WITHOUT CASESENSITIVITY

	def FindBetweenSIBZZ(pcSubStr, pcBound1, pcBound2, pnStartingAt)
		return This.FindBetweenSIBCSZZ(pcSubStr, pcBound1, pcBound2, pnStartingAt, :CaseSensitive = TRUE)

		def FindSubStringBetweenSIBZZ(pcSubStr, pcBound1, pcBound2, pnStartingAt)
			return This.FindBetweenSIBZZ(pcSubStr, pcBound1, pcBound2, pnStartingAt)

		def FindBoundedBySIBZZ(pcSubStr, pacBounds, pnStartingAt)
			return This.FindBoundedBySIBCSZZ(pcSubStr, pacBounds, pnStartingAt, :CaseSensitive)

		def FindSubStringBoundedBySIBZZ(pcSubStr, pacBounds, pnStartingAt)
			return This.FindBoundedBySIBZZ(pcSubStr, pacBounds, pnStartingAt)

		#--
	
		def FindBetweenAsSectionsSIB(pcSubStr, pcBound1, pcBound2, pnStartingAt)
			return This.FindBetweenSIBZZ(pcSubStr, pcBound1, pcBound2, pnStartingAt)

		def FindSubStringBetweenAsSectionsSIB(pcSubStr, pcBound1, pcBound2, pnStartingAt)
			return This.FindBetweenSIBZZ(pcSubStr, pcBound1, pcBound2, pnStartingAt)

		def FindBoundedByAsSectionsSIBZZ(pcSubStr, pacBounds, pnStartingAt)
			return This.FindBoundedBySIBZZ(pcSubStr, pacBounds, pnStartingAt)

		def FindSubStringBoundedByAsSectionsSIB(pcSubStr, pacBounds, pnStartingAt)
			return This.FindBoundedBySIBZZ(pcSubStr, pacBounds, pnStartingAt)

		#==

		def SubStringBetweenSIBZZ(pcSubStr, pcBound1, pcBound2, pnStartingAt)
			return This.FindBetweenSIBZZ(pcSubStr, pcBound1, pcBound2, pnStartingAt)

		def SubStringBoundedBySIBZZ(pcSubStr, pacBounds, pnStartingAt)
			return This.FindBoundedBySIBZZ(pcSubStr, pacBounds, pnStartingAt)

		def SubStringBetweenAsSectionsSIB(pcSubStr, pcBound1, pcBound2, pnStartingAt)
			return This.FindBetweenSIBZZ(pcSubStr, pcBound1, pcBound2, pnStartingAt)

		def SubStringBoundedByAsSectionsSIB(pcSubStr, pacBounds, pnStartingAt)
			return This.FindBoundedBySIBZZ(pcSubStr, pacBounds, pnStartingAt)

		#>

	   #-------------------------------------------------------#
	  #  FINDING A SUBSTRING BOUNDED BY TWO OTHER SubString   #
	 #  GOING IN A GIVEN DIRECTION                           #
	#-------------------------------------------------------#

	def FindBetweenDCS(pcSubStr, pcBound1, pcBound2, pcDirection, pCaseSensitive)
		/* ... */

		#< @FunctionAlternativeForms

		def FindSubStringBetweenDCS(pcSubStr, pcBound1, pcBound2, pcDirection, pCaseSensitive)
			return This.FindBetweenDCS(pcSubStr, pcBound1, pcBound2, pcDirection, pCaseSensitive)

		def FindBoundedByDCS(pcSubStr, pacBounds, pcDirection, pCaseSensitive)
			if isString(pacBounds)
				return This.FindBetweenDCS(pcSubStr, pacBounds, pacBounds, pcDirection, pCaseSensitive)

			but isList(pacBounds) and Q(pacBounds).IsPairOfStrings()
				return This.FindBetweenDCS(pcSubStr, pacBounds[1], pacBounds[2], pcDirection, pCaseSensitive)

			else
				StzRaise("Incorrect param type! pacBounds must be a string or pair of strings.")
			ok

		def FindSubStringBoundedByDCS(pcSubStr, pacBounds, pcDirection, pCaseSensitive)
			return This.FindBoundedByDCS(pcSubStr, pacBounds, pcDirection, pCaseSensitive)

		#--
	
		def FindBetweenDCSZ(pcSubStr, pcBound1, pcBound2, pcDirection, pCaseSensitive)
			return This.FindBetweenDCS(pcSubStr, pcBound1, pcBound2, pcDirection, pCaseSensitive)

		def FindSubStringBetweenDCSZ(pcSubStr, pcBound1, pcBound2, pcDirection, pCaseSensitive)
			return This.FindBetweenDCS(pcSubStr, pcBound1, pcBound2, pcDirection, pCaseSensitive)

		def FindBoundedByDCSZ(pcSubStr, pacBounds, pcDirection, pCaseSensitive)
			return This.FindBoundedByDCS(pcSubStr, pacBounds, pcDirection, pCaseSensitive)

		def FindSubStringBoundedByDCSZ(pcSubStr, pacBounds, pcDirection, pCaseSensitive)
			return This.FindBoundedByDCS(pcSubStr, pacBounds, pcDirection, pCaseSensitive)

		#==

		def SubStringBetweenDCS(pcSubStr, pcBound1, pcBound2, pcDirection, pCaseSensitive)
			return This.FindBetweenDCS(pcSubStr, pcBound1, pcBound2, pcDirection, pCaseSensitive)

		def SubStringBoundedByDCS(pcSubStr, pacBounds, pcDirection, pCaseSensitive)
			return This.FindBoundedByDCS(pcSubStr, pacBounds, pcDirection, pCaseSensitive)

		def SubStringBetweenDCSZ(pcSubStr, pcBound1, pcBound2, pcDirection, pCaseSensitive)
			return This.FindBetweenDCS(pcSubStr, pcBound1, pcBound2, pcDirection, pCaseSensitive)

		def SubStringBoundedByDCSZ(pcSubStr, pacBounds, pcDirection, pCaseSensitive)
			return This.FindBoundedByDCS(pcSubStr, pacBounds, pcDirection, pCaseSensitive)

		#>

	#-- WITHOUT CASESENSITIVITY

	def FindBetweenD(pcSubStr, pcBound1, pcBound2, pcDirection)
		return This.FindBetweenDCS(pcSubStr, pcBound1, pcBound2, pcDirection, :CaseSensitive = TRUE)

		#< @FunctionAlternativeForms

		def FindSubStringBetweenD(pcSubStr, pcBound1, pcBound2, pcDirection)
			return This.FindBetweenD(pcSubStr, pcBound1, pcBound2, pcDirection)

		def FindBoundedByD(pcSubStr, pacBounds, pcDirection)
			return This.FindBoundedByDCS(pcSubStr, pacBounds, pcDirection, :CaseSensitive = TRUE)

		def FindSubStringBoundedByD(pcSubStr, pacBounds, pcDirection)
			return This.FindBoundedByD(pcSubStr, pacBounds, pcDirection)

		#--
	
		def FindBetweenDZ(pcSubStr, pcBound1, pcBound2, pcDirection)
			return This.FindBetweenD(pcSubStr, pcBound1, pcBound2, pcDirection)

		def FindSubStringBetweenDZ(pcSubStr, pcBound1, pcBound2, pcDirection)
			return This.FindBetweenD(pcSubStr, pcBound1, pcBound2, pcDirection)

		def FindBoundedByDZ(pcSubStr, pacBounds, pcDirection)
			return This.FindBoundedByD(pcSubStr, pacBounds, pcDirection)

		def FindSubStringBoundedByDZ(pcSubStr, pacBounds, pcDirection)
			return This.FindBoundedByD(pcSubStr, pacBounds, pcDirection)

		#==

		def SubStringBetweenD(pcSubStr, pcBound1, pcBound2, pcDirection)
			return This.FindBetweenD(pcSubStr, pcBound1, pcBound2, pcDirection)

		def SubStringBoundedByD(pcSubStr, pacBounds, pcDirection)
			return This.FindBoundedByD(pcSubStr, pacBounds, pcDirection)

		def SubStringBetweenDZ(pcSubStr, pcBound1, pcBound2, pcDirection)
			return This.FindBetweenD(pcSubStr, pcBound1, pcBound2, pcDirection)

		def SubStringBoundedByDZ(pcSubStr, pacBounds, pcDirection)
			return This.FindBoundedByD(pcSubStr, pacBounds, pcDirection)

		#>

	   #----------------------------------------------------------------#
	  #  FINDING A SUBSTRING BOUNDED BY TWO OTHER SubString GOING IN   #
	 #  A GIVEN DIRECTION AND RETURNING POSITIONS AS SECTIONS         #                       #
	#----------------------------------------------------------------#

	def FindBetweenDCSZZ(pcSubStr, pcBound1, pcBound2, pcDirection, pCaseSensitive)
		/* ... */

		#< @FunctionAlternativeForms

		def FindSubStringBetweenDCSZZ(pcSubStr, pcBound1, pcBound2, pcDirection, pCaseSensitive)
			return This.FindBetweenDZZ(pcSubStr, pcBound1, pcBound2, pcDirection)

		def FindBoundedByDCSZZ(pcSubStr, pacBounds, pcDirection, pCaseSensitive)
			if isString(pacBounds)
				return This.FindBetweenDCSZZ(pcSubStr, pacBounds, pacBounds, pcDirection, pCaseSensitive)

			but isList(pacBounds) and Q(pacBounds).IsPairOfNumbers()
				return This.FindBetweenDCSZZ(pcSubStr, pacBounds[1], pacBounds[2], pcDirection, pCaseSensitive)

			else
				StzRaise("Incorrect param type! pacBounds must be a string or pair of strings.")

			ok

		def FindSubStringBoundedByDCSZZ(pcSubStr, pacBounds, pcDirection, pCaseSensitive)
			return This.FindBoundedByDCSZZ(pcSubStr, pacBounds, pcDirection, pCaseSensitive)

		#--
	
		def FindBetweenAsSectionsDCS(pcSubStr, pcBound1, pcBound2, pcDirection, pCaseSensitive)
			return This.FindBetweenDCSZZ(pcSubStr, pcBound1, pcBound2, pcDirection, pCaseSensitive)

		def FindSubStringBetweenAsSectionsDCS(pcSubStr, pcBound1, pcBound2, pcDirection, pCaseSensitive)
			return This.FindBetweenDCSZZ(pcSubStr, pcBound1, pcBound2, pcDirection, pCaseSensitive)

		def FindBoundedByAsSectionsDCS(pcSubStr, pacBounds, pcDirection, pCaseSensitive)
			return This.FindBoundedByDCSZZ(pcSubStr, pacBounds, pcDirection, pCaseSensitive)

		def FindSubStringBoundedByAsSectionsDCS(pcSubStr, pacBounds, pcDirection, pCaseSensitive)
			return This.FindBoundedByDCSZZ(pcSubStr, pacBounds, pcDirection, pCaseSensitive)

		#==

		def SubStringBetweenDCSZZ(pcSubStr, pcBound1, pcBound2, pcDirection, pCaseSensitive)
			return This.FindBetweenDCSZZ(pcSubStr, pcBound1, pcBound2, pcDirection, pCaseSensitive)

		def SubStringBoundedByDCSZZ(pcSubStr, pacBounds, pcDirection, pCaseSensitive)
			return This.FindBoundedByDCSZZ(pcSubStr, pacBounds, pcDirection, pCaseSensitive)

		def SubStringBetweenAsSectionsDCS(pcSubStr, pcBound1, pcBound2, pcDirection, pCaseSensitive)
			return This.FindBetweenDCSZZ(pcSubStr, pcBound1, pcBound2, pcDirection, pCaseSensitive)

		def SubStringBoundedByAsSectionsDCS(pcSubStr, pacBounds, pcDirection, pCaseSensitive)
			return This.FindBoundedByDCSZZ(pcSubStr, pacBounds, pcDirection, pCaseSensitive)

		#>

	#-- WITHOUT CASESENSITIVITY

	def FindBetweenDZZ(pcSubStr, pcBound1, pcBound2, pcDirection)
		return This.FindBetweenDZZ(pcSubStr, pcBound1, pcBound2, pcDirection)

		#< @FunctionAlternativeForms

		def FindSubStringBetweenDZZ(pcSubStr, pcBound1, pcBound2, pcDirection)
			return This.FindBetweenDZZ(pcSubStr, pcBound1, pcBound2, pcDirection)

		def FindBoundedByDZZ(pcSubStr, pacBounds, pcDirection)
			return This.FindBoundedByDCSZZ(pcSubStr, pacBounds, pcDirection, :CaseSensitive = TRUE)

		def FindSubStringBoundedByDZZ(pcSubStr, pacBounds, pcDirection)
			return This.FindBoundedByDZZ(pcSubStr, pacBounds, pcDirection)

		#--
	
		def FindBetweenAsSectionsD(pcSubStr, pcBound1, pcBound2, pcDirection)
			return This.FindBetweenDZZ(pcSubStr, pcBound1, pcBound2, pcDirection)

		def FindSubStringBetweenAsSectionsD(pcSubStr, pcBound1, pcBound2, pcDirection)
			return This.FindBetweenDZZ(pcSubStr, pcBound1, pcBound2, pcDirection)

		def FindBoundedByAsSectionsD(pcSubStr, pacBounds, pcDirection)
			return This.FindBoundedByDZZ(pcSubStr, pacBounds, pcDirection)

		def FindSubStringBoundedByAsSectionsD(pcSubStr, pacBounds, pcDirection)
			return This.FindBoundedByDZZ(pcSubStr, pacBounds, pcDirection)

		#==

		def SubStringBetweenDZZ(pcSubStr, pcBound1, pcBound2, pcDirection)
			return This.FindBetweenDZZ(pcSubStr, pcBound1, pcBound2, pcDirection)

		def SubStringBoundedByDZZ(pcSubStr, pacBounds, pcDirection)
			return This.FindBoundedByDZZ(pcSubStr, pacBounds, pcDirection)

		def SubStringBetweenAsSectionsD(pcSubStr, pcBound1, pcBound2, pcDirection)
			return This.FindBetweenDZZ(pcSubStr, pcBound1, pcBound2, pcDirection)

		def SubStringBoundedByAsSectionsD(pcSubStr, pacBounds, pcDirection)
			return This.FindBoundedByDZZ(pcSubStr, pacBounds, pcDirection)

		#>

	   #-------------------------------------------------------#
	  #  FINDING A SUBSTRING BOUNDED BY TWO OTHER SubString  #
	 #  GOING IN A GIVEN DIRECTION AND INCLUDING BOUNDS      #
	#-------------------------------------------------------#

	def FindBetweenDCSIB(pcSubStr, pcBound1, pcBound2, pcDirection, pCaseSensitive)
		/* ... */

		#< @FunctionAlternativeForms

		def FindSubStringBetweenDCSIB(pcSubStr, pcBound1, pcBound2, pcDirection, pCaseSensitive)
			return This.FindBetweenDCSIB(pcSubStr, pcBound1, pcBound2, pcDirection, pCaseSensitive)

		def FindBoundedByDCSIB(pcSubStr, pacBounds, pcDirection, pCaseSensitive)
			if isString(pacBounds)
				return This.FindBetweenDCSIB(pcSubStr, pacBounds, pacBounds, pcDirection, pCaseSensitive)

			but isList(pacBounds) and Q(pacBounds).IsPairOfStrings()
				return This.FindBetweenDCSIB(pcSubStr, pacBounds[1], pacBounds[2], pcDirection, pCaseSensitive)

			else
				StzRaise("Incorrect param type! pacBounds must be a string or pair of strings.")
			ok

		def FindSubStringBoundedByDCSIB(pcSubStr, pacBounds, pcDirection, pCaseSensitive)
			return This.FindBoundedByDCSIB(pcSubStr, pacBounds, pcDirection, pCaseSensitive)

		#--
	
		def FindBetweenDCSIBZ(pcSubStr, pcBound1, pcBound2, pcDirection, pCaseSensitive)
			return This.FindBetweenDCSIB(pcSubStr, pcBound1, pcBound2, pcDirection, pCaseSensitive)

		def FindSubStringBetweenDCSIBZ(pcSubStr, pcBound1, pcBound2, pcDirection, pCaseSensitive)
			return This.FindBetweenDCSIB(pcSubStr, pcBound1, pcBound2, pcDirection, pCaseSensitive)

		def FindBoundedByDCSIBZ(pcSubStr, pacBounds, pcDirection, pCaseSensitive)
			return This.FindBoundedByDCSIB(pcSubStr, pacBounds, pcDirection, pCaseSensitive)

		def FindSubStringBoundedByDCSIBZ(pcSubStr, pacBounds, pcDirection, pCaseSensitive)
			return This.FindBoundedByDCSIB(pcSubStr, pacBounds, pcDirection, pCaseSensitive)

		#==

		def SubStringBetweenDCSIB(pcSubStr, pcBound1, pcBound2, pcDirection, pCaseSensitive)
			return This.FindBetweenDCSIB(pcSubStr, pcBound1, pcBound2, pcDirection, pCaseSensitive)

		def SubStringBoundedByDCSIB(pcSubStr, pacBounds, pcDirection, pCaseSensitive)
			return This.FindBoundedByDCSIB(pcSubStr, pacBounds, pcDirection, pCaseSensitive)

		def SubStringBetweenDCSIBZ(pcSubStr, pcBound1, pcBound2, pcDirection, pCaseSensitive)
			return This.FindBetweenDCSIB(pcSubStr, pcBound1, pcBound2, pcDirection, pCaseSensitive)

		def SubStringBoundedByDCSIBZ(pcSubStr, pacBounds, pcDirection, pCaseSensitive)
			return This.FindBoundedByDCSIB(pcSubStr, pacBounds, pcDirection, pCaseSensitive)

		#>

	#-- WITHOUT CASESENSITIVITY

	def FindBetweenDIB(pcSubStr, pcBound1, pcBound2, pcDirection)
		return This.FindBetweenDCSIB(pcSubStr, pcBound1, pcBound2, pcDirection, :CaseSensitive = TRUE)

		#< @FunctionAlternativeForms

		def FindSubStringBetweenDIB(pcSubStr, pcBound1, pcBound2, pcDirection)
			return This.FindBetweenDIB(pcSubStr, pcBound1, pcBound2, pcDirection)

		def FindBoundedByDIB(pcSubStr, pacBounds, pcDirection)
			return This.FindBoundedByDCSIB(pcSubStr, pacBounds, pcDirection, :CaseSensitive = TRUE)

		def FindSubStringBoundedByDIB(pcSubStr, pacBounds, pcDirection)
			return This.FindBoundedByDIB(pcSubStr, pacBounds, pcDirection)

		#--
	
		def FindBetweenDIBZ(pcSubStr, pcBound1, pcBound2, pcDirection)
			return This.FindBetweenDIB(pcSubStr, pcBound1, pcBound2, pcDirection)

		def FindSubStringBetweenDIBZ(pcSubStr, pcBound1, pcBound2, pcDirection)
			return This.FindBetweenDIB(pcSubStr, pcBound1, pcBound2, pcDirection)

		def FindBoundedByDIBZ(pcSubStr, pacBounds, pcDirection)
			return This.FindBoundedByDIB(pcSubStr, pacBounds, pcDirection)

		def FindSubStringBoundedByDIBZ(pcSubStr, pacBounds, pcDirection)
			return This.FindBoundedByDIB(pcSubStr, pacBounds, pcDirection)

		#==

		def SubStringBetweenDIB(pcSubStr, pcBound1, pcBound2, pcDirection)
			return This.FindBetweenDIB(pcSubStr, pcBound1, pcBound2, pcDirection)

		def SubStringBoundedByDIB(pcSubStr, pacBounds, pcDirection)
			return This.FindBoundedByDIB(pcSubStr, pacBounds, pcDirection)

		def SubStringBetweenDIBZ(pcSubStr, pcBound1, pcBound2, pcDirection)
			return This.FindBetweenDIB(pcSubStr, pcBound1, pcBound2, pcDirection)

		def SubStringBoundedByDIBZ(pcSubStr, pacBounds, pcDirection)
			return This.FindBoundedByDIB(pcSubStr, pacBounds, pcDirection)

		#>

	   #------------------------------------------------------------------------#
	  #  FINDING A SUBSTRING BOUNDED BY TWO OTHER SubString GOING IN A GIVEN  #
	 #  DIRECTION, INCLUDING BOUNDS, AND RETURNING POSITIONS AS SECTIONS      #                   #                       #
	#------------------------------------------------------------------------#

	def FindBetweenDCSIBZZ(pcSubStr, pcBound1, pcBound2, pcDirection, pCaseSensitive)
		/* ... */

		#< @FunctionAlternativeForms

		def FindSubStringBetweenDCSIBZZ(pcSubStr, pcBound1, pcBound2, pcDirection, pCaseSensitive)
			return This.FindBetweenDIBZZ(pcSubStr, pcBound1, pcBound2, pcDirection)

		def FindBoundedByDCSIBZZ(pcSubStr, pacBounds, pcDirection, pCaseSensitive)
			if isString(pacBounds)
				return This.FindBetweenDCSIBZZ(pcSubStr, pacBounds, pacBounds, pcDirection, pCaseSensitive)

			but isList(pacBounds) and Q(pacBounds).IsPairOfNumbers()
				return This.FindBetweenDCSIBZZ(pcSubStr, pacBounds[1], pacBounds[2], pcDirection, pCaseSensitive)

			else
				StzRaise("Incorrect param type! pacBounds must be a string or pair of strings.")

			ok

		def FindSubStringBoundedByDCSIBZZ(pcSubStr, pacBounds, pcDirection, pCaseSensitive)
			return This.FindBoundedByDCSIBZZ(pcSubStr, pacBounds, pcDirection, pCaseSensitive)

		#--
	
		def FindBetweenAsSectionsDCSIB(pcSubStr, pcBound1, pcBound2, pcDirection, pCaseSensitive)
			return This.FindBetweenDCSIBZZ(pcSubStr, pcBound1, pcBound2, pcDirection, pCaseSensitive)

		def FindSubStringBetweenAsSectionsDCSIB(pcSubStr, pcBound1, pcBound2, pcDirection, pCaseSensitive)
			return This.FindBetweenDCSIBZZ(pcSubStr, pcBound1, pcBound2, pcDirection, pCaseSensitive)

		def FindBoundedByAsSectionsDCSIB(pcSubStr, pacBounds, pcDirection, pCaseSensitive)
			return This.FindBoundedByDCSIBZZ(pcSubStr, pacBounds, pcDirection, pCaseSensitive)

		def FindSubStringBoundedByAsSectionsDCSIB(pcSubStr, pacBounds, pcDirection, pCaseSensitive)
			return This.FindBoundedByDCSIBZZ(pcSubStr, pacBounds, pcDirection, pCaseSensitive)

		#==

		def SubStringBetweenDCSIBZZ(pcSubStr, pcBound1, pcBound2, pcDirection, pCaseSensitive)
			return This.FindBetweenDCSIBZZ(pcSubStr, pcBound1, pcBound2, pcDirection, pCaseSensitive)

		def SubStringBoundedByDCSIBZZ(pcSubStr, pacBounds, pcDirection, pCaseSensitive)
			return This.FindBoundedByDCSIBZZ(pcSubStr, pacBounds, pcDirection, pCaseSensitive)

		def SubStringBetweenAsSectionsDCSIB(pcSubStr, pcBound1, pcBound2, pcDirection, pCaseSensitive)
			return This.FindBetweenDCIBSZZ(pcSubStr, pcBound1, pcBound2, pcDirection, pCaseSensitive)

		def SubStringBoundedByAsSectionsDCSIB(pcSubStr, pacBounds, pcDirection, pCaseSensitive)
			return This.FindBoundedByDCSIBZZ(pcSubStr, pacBounds, pcDirection, pCaseSensitive)

		#>

	#-- WITHOUT CASESENSITIVITY

	def FindBetweenDIBZZ(pcSubStr, pcBound1, pcBound2, pcDirection)
		return This.FindBetweenDIBZZ(pcSubStr, pcBound1, pcBound2, pcDirection)

		#< @FunctionAlternativeForms

		def FindSubStringBetweenDIBZZ(pcSubStr, pcBound1, pcBound2, pcDirection)
			return This.FindBetweenDIBZZ(pcSubStr, pcBound1, pcBound2, pcDirection)

		def FindBoundedByDIBZZ(pcSubStr, pacBounds, pcDirection)
			return This.FindBoundedByDCSIBZZ(pcSubStr, pacBounds, pcDirection, :CaseSensitive = TRUE)

		def FindSubStringBoundedByDIBZZ(pcSubStr, pacBounds, pcDirection)
			return This.FindBoundedByDIBZZ(pcSubStr, pacBounds, pcDirection)

		#--
	
		def FindBetweenAsSectionsDIB(pcSubStr, pcBound1, pcBound2, pcDirection)
			return This.FindBetweenDIBZZ(pcSubStr, pcBound1, pcBound2, pcDirection)

		def FindSubStringBetweenAsSectionsDIB(pcSubStr, pcBound1, pcBound2, pcDirection)
			return This.FindBetweenDIBZZ(pcSubStr, pcBound1, pcBound2, pcDirection)

		def FindBoundedByAsSectionsDIB(pcSubStr, pacBounds, pcDirection)
			return This.FindBoundedByDIBZZ(pcSubStr, pacBounds, pcDirection)

		def FindSubStringBoundedByAsSectionsDIB(pcSubStr, pacBounds, pcDirection)
			return This.FindBoundedByDIBZZ(pcSubStr, pacBounds, pcDirection)

		#==

		def SubStringBetweenDIBZZ(pcSubStr, pcBound1, pcBound2, pcDirection)
			return This.FindBetweenDIBZZ(pcSubStr, pcBound1, pcBound2, pcDirection)

		def SubStringBoundedByDIBZZ(pcSubStr, pacBounds, pcDirection)
			return This.FindBoundedByDIBZZ(pcSubStr, pacBounds, pcDirection)

		def SubStringBetweenAsSectionsDIB(pcSubStr, pcBound1, pcBound2, pcDirection)
			return This.FindBetweenDIBZZ(pcSubStr, pcBound1, pcBound2, pcDirection)

		def SubStringBoundedByAsSectionsDIB(pcSubStr, pacBounds, pcDirection)
			return This.FindBoundedByDIBZZ(pcSubStr, pacBounds, pcDirection)

		#>

	   #----------------------------------------------------------------#
	  #  FINDING A SUBSTRING BOUNDED BY TWO OTHER SubString STARTING  #
	 #  AT A GIVEN POSITION AND GOING IN A GIVEN DIRECTION            #
	#----------------------------------------------------------------#

	def FindBetweenSDCS(pcSubStr, pcBound1, pcBound2, pnStartingAt, pcDirection, pCaseSensitive)
		/* ... */

		#< @FunctionAlternativeForms

		def FindSubStringBetweenSDCS(pcSubStr, pcBound1, pcBound2, pnStartingAt, pcDirection, pCaseSensitive)
			return This.FindBetweenSDCS(pcSubStr, pcBound1, pcBound2, pnStartingAt, pcDirection, pCaseSensitive)

		def FindBoundedBySDCS(pcSubStr, pacBounds, pnStartingAt, pcDirection, pCaseSensitive)
			if isString(pacBounds)
				return This.FindBetweenSDCS(pcSubStr, pacBounds, pacBounds, pnStartingAt, pcDirection, pCaseSensitive)

			but isLsit(pacBounds) and Q(pacBounds).IsPairOfStrings()
				return This.FindBetweenSDCS(pcSubStr, pacBounds[1], pacBounds[2], pnStartingAt, pcDirection, pCaseSensitive)

			else
				StzRaise("Incorrect param type! pacBounds must be a string or pair of strings.")

			ok

		def FindSubStringBoundedBySDCS(pcSubStr, pacBounds, pnStartingAt, pcDirection, pCaseSensitive)
			return This.FindBoundedBySDCS(pcSubStr, pacBounds, pnStartingAt, pcDirection, pCaseSensitive)

		#--
	
		def FindBetweenSDCSZ(pcSubStr, pcBound1, pcBound2, pnStartingAt, pcDirection, pCaseSensitive)
			return This.FindBetweenSDCS(pcSubStr, pcBound1, pcBound2, pnStartingAt, pcDirection, pCaseSensitive)

		def FindSubStringBetweenSDCSZ(pcSubStr, pcBound1, pcBound2, pnStartingAt, pcDirection, pCaseSensitive)
			return This.FindBetweenSDCS(pcSubStr, pcBound1, pcBound2, pnStartingAt, pcDirection, pCaseSensitive)

		def FindBoundedBySDCSZ(pcSubStr, pacBounds, pnStartingAt, pcDirection, pCaseSensitive)
			return This.FindBoundedBySDCS(pcSubStr, pacBounds, pnStartingAt, pcDirection, pCaseSensitive)

		def FindSubStringBoundedBySDCSZ(pcSubStr, pacBounds, pnStartingAt, pcDirection, pCaseSensitive)
			return This.FindBoundedBySDCS(pcSubStr, pacBounds, pnStartingAt, pcDirection, pCaseSensitive)

		#==

		def SubStringBetweenSDCS(pcSubStr, pcBound1, pcBound2, pnStartingAt, pcDirection, pCaseSensitive)
			return This.FindBetweenSD(pcSubStr, pcBound1, pcBound2, pnStartingAt, pcDirection)

		def SubStringBoundedBySDCS(pcSubStr, pacBounds, pnStartingAt, pcDirection, pCaseSensitive)
			return This.FindBoundedBySDCS(pcSubStr, pacBounds, pnStartingAt, pcDirection, pCaseSensitive)

		def SubStringBetweenSDCSZ(pcSubStr, pcBound1, pcBound2, pnStartingAt, pcDirection, pCaseSensitive)
			return This.FindBetweenSDCS(pcSubStr, pcBound1, pcBound2, pnStartingAt, pcDirection, pCaseSensitive)

		def SubStringBoundedBySDCSZ(pcSubStr, pacBounds, pnStartingAt, pcDirection, pCaseSensitive)
			return This.FindBoundedBySDCS(pcSubStr, pacBounds, pnStartingAt, pcDirection, pCaseSensitive)

		#>

	#-- WITHOUT CASESENSITIVITY

	def FindBetweenSD(pcSubStr, pcBound1, pcBound2, pnStartingAt, pcDirection)
		return This.FindBetweenSDCS(pcSubStr, pcBound1, pcBound2,pnStartingAt, pcDirection, :CaseSensitive = TRUE)

		#< @FunctionAlternativeForms

		def FindSubStringBetweenSD(pcSubStr, pcBound1, pcBound2, pnStartingAt, pcDirection)
			return This.FindBetweenSD(pcSubStr, pcBound1, pcBound2, pnStartingAt, pcDirection)

		def FindBoundedBySD(pcSubStr, pacBounds, pnStartingAt, pcDirection)
			return This.FindBoundedBySDCS(pcSubStr, pacBounds, pnStartingAt, pcDirection, :CaseSensitive = TRUE)

		def FindSubStringBoundedBySD(pcSubStr, pacBounds, pnStartingAt, pcDirection)
			return This.FindBoundedBySD(pcSubStr, pacBounds, pnStartingAt, pcDirection)

		#--
	
		def FindBetweenSDZ(pcSubStr, pcBound1, pcBound2, pnStartingAt, pcDirection)
			return This.FindBetweenSD(pcSubStr, pcBound1, pcBound2, pnStartingAt, pcDirection)

		def FindSubStringBetweenSDZ(pcSubStr, pcBound1, pcBound2, pnStartingAt, pcDirection)
			return This.FindBetweenSD(pcSubStr, pcBound1, pcBound2, pnStartingAt, pcDirection)

		def FindBoundedBySDZ(pcSubStr, pacBounds, pnStartingAt, pcDirection)
			return This.FindBoundedBySD(pcSubStr, pacBounds, pnStartingAt, pcDirection)

		def FindSubStringBoundedBySDZ(pcSubStr, pacBounds, pnStartingAt, pcDirection)
			return This.FindBoundedBySD(pcSubStr, pacBounds, pnStartingAt, pcDirection)

		#==

		def SubStringBetweenSD(pcSubStr, pcBound1, pcBound2, pnStartingAt, pcDirection)
			return This.FindBetweenSD(pcSubStr, pcBound1, pcBound2, pnStartingAt, pcDirection)

		def SubStringBoundedBySD(pcSubStr, pacBounds, pnStartingAt, pcDirection)
			return This.FindBoundedBySD(pcSubStr, pacBounds, pnStartingAt, pcDirection)

		def SubStringBetweenSDZ(pcSubStr, pcBound1, pcBound2, pnStartingAt, pcDirection)
			return This.FindBetweenSD(pcSubStr, pcBound1, pcBound2, pnStartingAt, pcDirection)

		def SubStringBoundedBySDZ(pcSubStr, pacBounds, pnStartingAt, pcDirection)
			return This.FindBoundedBySD(pcSubStr, pacBounds, pnStartingAt, pcDirection)

		#>

	   #-------------------------------------------------------------------------------#
	  #  FINDING A SUBSTRING BOUNDED BY TWO OTHER SubString, STARTING AT A GIVEN     #
	 #  POSITION, GOING IN A GIVEN DIRECTION, AND RETURNING POSITIONS AS SECTIONS    #
	#-------------------------------------------------------------------------------#

	def FindBetweenSDZZ(pcSubStr, pcBound1, pcBound2)
		def FindSubStringBetweenSDZZ(pcSubStr, pcBound1, pcBound2, pnStartingAt, pcDirection)
		def FindBoundedBySDZZ(pcSubStr, pacBounds, pnStartingAt, pcDirection)
		def FindSubStringBoundedBySDZZ(pcSubStr, pacBounds, pnStartingAt, pcDirection)
	
		#--
	
		def FindSubStringBetweenAsSectionsSD(pcSubStr, pcBound1, pcBound2, pnStartingAt, pcDirection)
		def FindBoundedByAsSectionsSD(pcSubStr, pacBounds, pnStartingAt, pcDirection)
		def FindSubStringBoundedByAsSectionsSD(pcSubStr, pacBounds, pnStartingAt, pcDirection)
	
		#==

		def SubStringBetweenSDZZ(pcSubStr, pcBound1, pcBound2, pnStartingAt, pcDirection)
		def SubStringBoundedBySDZZ(pcSubStr, pacBounds, pnStartingAt, pcDirection)

		def SubStringBetweenAsSectionsSD(pcSubStr, pcBound1, pcBound2, pnStartingAt, pcDirection)
		def SubStringBoundedByAsSectionsSD(pcSubStr, pacBounds, pnStartingAt, pcDirection)

	   #-------------------------------------------------------------------------------#
	  #  FINDING A SUBSTRING BOUNDED BY TWO OTHER SubString, STARTING AT A GIVEN     #
	 #  POSITION, GOING IN A GIVEN DIRECTION, AND INCLUDING BOUNDS                   #
	#-------------------------------------------------------------------------------#

	def FindBetweenSDIB(pcSubStr, pcBound1, pcBound2)
		def FindSubStringBetweenSDIB(pcSubStr, pcBound1, pcBound2, pnStartingAt, pcDirection)
		def FindBoundedBySDIB(pcSubStr, pacBounds, pnStartingAt, pcDirection)
		def FindSubStringBoundedBySDIB(pcSubStr, pacBounds, pnStartingAt, pcDirection)
	
		#--
	
		def FindBetweenSDIBZ(pcSubStr, pcBound1, pcBound2, pnStartingAt, pcDirection)
		def FindSubStringBetweenSDIBZ(pcSubStr, pcBound1, pcBound2, pnStartingAt, pcDirection)
		def FindBoundedBySDIBZ(pcSubStr, pacBounds, pnStartingAt, pcDirection)
		def FindSubStringBoundedBySDIBZ(pcSubStr, pacBounds, pnStartingAt, pcDirection)

		#==

		def SubStringBetweenSDIB(pcSubStr, pcBound1, pcBound2, pnStartingAt, pcDirection)
		def SubStringBoundedBySDIB(pcSubStr, pacBounds, pnStartingAt, pcDirection)

		def SubStringBetweenSDIBZ(pcSubStr, pcBound1, pcBound2, pnStartingAt, pcDirection)
		def SubStringBoundedBySDIBZ(pcSubStr, pacBounds, pnStartingAt, pcDirection)

	   #--------------------------------------------------------------------------------------#
	  #  FINDING A SUBSTRING BOUNDED BY TWO OTHER SubString, STARTING AT A GIVEN POSITION,  #
	 #  GOING IN A GIVEN DIRECTION, INCLUDING BOUNDS, AND RETURNING POSITIONS AS SECTIONS   #
	#--------------------------------------------------------------------------------------#

	def FindBetweenSDIBZZ(pcSubStr, pcBound1, pcBound2)
		def FindSubStringBetweenSDIBZZ(pcSubStr, pcBound1, pcBound2, pnStartingAt, pcDirection)
		def FindBoundedBySDIBZZ(pcSubStr, pacBounds, pnStartingAt, pcDirection)
		def FindSubStringBoundedBySDIBZZ(pcSubStr, pacBounds, pnStartingAt, pcDirection)
	
		#--
	
		def FindSubStringBetweenAsSectionsSDIB(pcSubStr, pcBound1, pcBound2, pnStartingAt, pcDirection)
		def FindBoundedByAsSectionsSDIB(pcSubStr, pacBounds, pnStartingAt, pcDirection)
		def FindSubStringBoundedByAsSectionsSDIB(pcSubStr, pacBounds, pnStartingAt, pcDirection)
	
		#==

		def SubStringBetweenSDIBZZ(pcSubStr, pcBound1, pcBound2, pnStartingAt, pcDirection)
		def SubStringBoundedBySDIBZZ(pcSubStr, pacBounds, pnStartingAt, pcDirection)

		def SubStringBetweenAsSectionsSDIB(pcSubStr, pcBound1, pcBound2, pnStartingAt, pcDirection)
		def SubStringBoundedByAsSectionsSDIB(pcSubStr, pacBounds, pnStartingAt, pcDirection)
		
#--

	  #==================================================================#
	 #  FINDING NTH OCCURRENCE OF A SUBSTRING BOUNDED BY TWO SubString  #
	#==================================================================#

	def FindNthSubStringBetween(n, pcSubStr, pcBound1, pcBound2)
		def FindNthSubStringBetweenZ(n, pcSubStr, pcBound1, pcBound2)
	
		def FindNthSubStringBoundedBy(n, pcSubStr, pacBounds)
		def FindNthSubStringBoundedByZ(n, pcSubStr, pacBounds)

		#--

		def NthSubStringBetween(n, pcSubStr, pcBound1, pcBound2)
		def NthSubStringBetweenZ(n, pcSubStr, pcBound1, pcBound2)
		def NthSubStringBoundedBy(n, pcSubStr, pacBounds)
		def NthSubStringBoundedByZ(n, pcSubStr, pacBounds)

	   #-------------------------------------------------------------------#
	  #  FINDING NTH OCCURRENCE OF A SUBSTRING BOUNDED BY TWO SubString  #
	 #  AND RETURNING ITS POSITION AS SECTION                            #
	#-------------------------------------------------------------------#

	def FindNthSubStringBetweenZZ(n, pcSubStr, pcBound1, pcBound2)
		def FindNthSubStringBetweenAsSection(n, pcSubStr, pcBound1, pcBound2)
	
		def FindNthSubStringBoundedByZZ(n, pcSubStr, pacBounds)
		def FindNthSubStringBoundedByAsSection(n, pcSubStr, pacBounds)
	
		#--

		def NthSubStringBetweenZZ(n, pcSubStr, pcBound1, pcBound2)
		def NthSubStringBetweenAsSection(n, pcSubStr, pcBound1, pcBound2)
		def NthSubStringBoundedByZZ(n, pcSubStr, pacBounds)
		def NthSubStringBoundedByAsSection(n, pcSubStr, pacBounds)

	   #-------------------------------------------------------------------#
	  #  FINDING NTH OCCURRENCE OF A SUBSTRING BOUNDED BY TWO SubString  #
	 #  INCLUDING BOUNDS                                                 #
	#-------------------------------------------------------------------#

	def FindNthSubStringBetweenIB(n, pcSubStr, pcBound1, pcBound2)
		def FindNthSubStringBetweenIBZ(n, pcSubStr, pcBound1, pcBound2)
	
		def FindNthSubStringBoundedByIB(n, pcSubStr, pacBounds)
		def FindNthSubStringBoundedByIBZ(n, pcSubStr, pacBounds)

		#--

		def NthSubStringBetweenIB(n, pcSubStr, pcBound1, pcBound2)
		def NthSubStringBetweenIBZ(n, pcSubStr, pcBound1, pcBound2)
		def NthSubStringBoundedByIB(n, pcSubStr, pacBounds)
		def NthSubStringBoundedByIBZ(n, pcSubStr, pacBounds)

	   #-------------------------------------------------------------------------#
	  #  FINDING NTH OCCURRENCE OF A SUBSTRING BOUNDED BY TWO SubString        #
	 #  INCLUDING BOUNDS AND RETURNING POSITIONS AS SECTIONS                   #                             #
	#-------------------------------------------------------------------------#

	def FindNthSubStringBetweenIBZZ(n, pcSubStr, pcBound1, pcBound2)
		def FindNthSubStringBetweenAsSectionIB(n, pcSubStr, pcBound1, pcBound2)
	
		def FindNthSubStringBoundedByIBZZ(n, pcSubStr, pacBounds)
		def FindNthSubStringBoundedByAsSectionIB(n, pcSubStr, pacBounds)

		#--

		def NthSubStringBetweenIBZZ(n, pcSubStr, pcBound1, pcBound2)
		def NthSubStringBetweenAsSectionIB(n, pcSubStr, pcBound1, pcBound2)
		def NthSubStringBoundedByIBZZ(n, pcSubStr, pacBounds)
		def NthSubStringBoundedByAsSectionIB(n, pcSubStr, pacBounds)

	   #-------------------------------------------------------------------#
	  #  FINDING NTH OCCURRENCE OF A SUBSTRING BOUNDED BY TWO SubString  #
	 #  STARTING AT A GIVEN POSITION                                     #
	#-------------------------------------------------------------------#

	def FindNthSubStringBetweenS(n, pcSubStr, pcBound1, pcBound2, pnStartingAt)
		def FindNthSubStringBetweenSZ(n, pcSubStr, pcBound1, pcBound2, pnStartingAt)
	
		def FindNthSubStringBoundedByS(n, pcSubStr, pacBounds, pnStartingAt)
		def FindNthSubStringBoundedBySZ(n, pcSubStr, pacBounds, pnStartingAt)

		#--

		def NthSubStringBetweenS(n, pcSubStr, pcBound1, pcBound2, pnStartingAt)
		def NthSubStringBetweenSZ(n, pcSubStr, pcBound1, pcBound2, pnStartingAt)
		def NthSubStringBoundedByS(n, pcSubStr, pacBounds, pnStartingAt)
		def NthSubStringBoundedBySZ(n, pcSubStr, pacBounds, pnStartingAt)

	   #---------------------------------------------------------------------#
	  #  FINDING NTH OCCURRENCE OF A SUBSTRING BOUNDED BY TWO SubString,   #
	 #  STARTING AT A GIVEN POSITION, AT A RETURNIN POSITIONS AS SECTIONS  #                      #
	#---------------------------------------------------------------------#

	def FindNthSubStringBetweenSZZ(n, pcSubStr, pcBound1, pcBound2, pnStartingAt)
		def FindNthSubStringBetweenAsSectionS(n, pcSubStr, pcBound1, pcBound2, pnStartingAt)
	
		def FindNthSubstringBoundedBySZZ(n, pcSubStr, pacBounds, pnStartingAt)
		def FindNthSubstringBoundedByAsSectionS(n, pcSubStr, pacBounds, pnStartingAt)

		#--

		def NthSubStringBetweenSZZ(n, pcSubStr, pcBound1, pcBound2, pnStartingAt)
		def NthSubStringBetweenAsSectionS(n, pcSubStr, pcBound1, pcBound2, pnStartingAt)
	
		def NthSubstringBoundedBySZZ(n, pcSubStr, pacBounds, pnStartingAt)
		def NthSubstringBoundedByAsSectionS(n, pcSubStr, pacBounds, pnStartingAt)
		
	   #-------------------------------------------------------------------#
	  #  FINDING NTH OCCURRENCE OF A SUBSTRING BOUNDED BY TWO SubString,  #
	 #  STARTING AT A GIVEN POSITION, AND INCLUDING BOUNDS               # 
	#-------------------------------------------------------------------#

	def FindNthSubStringBetweenSIB(n, pcSubStr, pcBound1, pcBound2, pnStartingAt)
		def FindNthSubStringBetweenSIBZ(n, pcSubStr, pcBound1, pcBound2, pnStartingAt)
	
		def FindNthSubStringBoundedBySIB(n, pcSubStr, pacBounds, pnStartingAt)
		def FindNthSubStringBoundedBySIBZ(n, pcSubStr, pacBounds, pnStartingAt)

		#--

		def NthSubStringBetweenSIB(n, pcSubStr, pcBound1, pcBound2, pnStartingAt)
		def NthSubStringBetweenSIBZ(n, pcSubStr, pcBound1, pcBound2, pnStartingAt)
	
		def NthSubStringBoundedBySIB(n, pcSubStr, pacBounds, pnStartingAt)
		def NthSubStringBoundedBySIBZ(n, pcSubStr, pacBounds, pnStartingAt)

	   #--------------------------------------------------------------------------------#
	  #  FINDING NTH OCCURRENCE OF A SUBSTRING BOUNDED BY TWO SubString, STARTING     #
	 #  AT A GIVEN POSITION, INCLUDING BOUNDS, AND RETURINIG THE POSITION AS SECTION  #                     #
	#--------------------------------------------------------------------------------#

	def FindNthSubStringBetweenSIBZZ(n, pcSubStr, pcBound1, pcBound2, pnStartingAt)
		def FindNthSubStringBetweenAsSectionSIB(n, pcSubStr, pacBounds, pnStartingAt)
	
		def FindNthSubStringBoundedBySIBZZ(n, pcSubStr, pacBounds, pnStartingAt)
		def FindNthSubStringBoundedByAsSectionSIB(n, pcSubStr, pacBounds, pnStartingAt)

		#--

		def NthSubStringBetweenSIBZZ(n, pcSubStr, pcBound1, pcBound2, pnStartingAt)
		def NthSubStringBetweenAsSectionSIB(n, pcSubStr, pacBounds, pnStartingAt)
	
		def NthSubStringBoundedBySIBZZ(n, pcSubStr, pacBounds, pnStartingAt)
		def NthSubStringBoundedByAsSectionSIB(n, pcSubStr, pacBounds, pnStartingAt)

	   #-------------------------------------------------------------------#
	  #  FINDING NTH OCCURRENCE OF A SUBSTRING BOUNDED BY TWO SubString  #
	 #  STARTING GOING IN A GIVEN DIRECTION                              #
	#-------------------------------------------------------------------#

	def FindNthSubStringBetweenD(n, pcSubStr, pcBound1, pcBound2, pcDirection)
		def FindNthSubStringBetweenDZ(n, pcSubStr, pcBound1, pcBound2, pcDirection)
	
		def FindNthSubStringBoundedByD(n, pcSubStr, pacBounds, pnStartingAt)
		def FindNthSubStringBoundedByDZ(n, pcSubStr, pacBounds, pnStartingAt)

		#--

		def NthSubStringBetweenD(n, pcSubStr, pcBound1, pcBound2, pcDirection)
		def NthSubStringBetweenDZ(n, pcSubStr, pcBound1, pcBound2, pcDirection)
	
		def NthSubStringBoundedByD(n, pcSubStr, pacBounds, pnStartingAt)
		def NthSubStringBoundedByDZ(n, pcSubStr, pacBounds, pnStartingAt)

	   #--------------------------------------------------------------------#
	  #  FINDING NTH OCCURRENCE OF A SUBSTRING BOUNDED BY TWO SubString   #
	 #  GOING IN A GIVEN DIRECTION AND RETURNING THE POSTIION AS SECTION  #
	#--------------------------------------------------------------------#

	def FindNthSubStringBetweenDZZ(n, pcSubStr, pcBound1, pcBound2, pcDirection)
		def FindNthSubStringBetweenAsSectionD(n, pcSubStr, pcBound1, pcBound2, pcDirection)
	
		def FindNthSubstringBoundedByDZZ(n, pcSubStr, pacBounds, pnStartingAt)
		def FindNthSubstringBoundedByAsSectionD(n, pcSubStr, pacBounds, pnStartingAt)

		#--

		def NthSubStringBetweenDZZ(n, pcSubStr, pcBound1, pcBound2, pcDirection)
		def NthSubStringBetweenAsSectionD(n, pcSubStr, pcBound1, pcBound2, pcDirection)
	
		def NthSubstringBoundedByDZZ(n, pcSubStr, pacBounds, pnStartingAt)
		def NthSubstringBoundedByAsSectionD(n, pcSubStr, pacBounds, pnStartingAt)

	   #-------------------------------------------------------------------#
	  #  FINDING NTH OCCURRENCE OF A SUBSTRING BOUNDED BY TWO SubString  #
	 #  GOING IN A GIVEN DIRECTION AND INCLUDING BOUNDS                  #
	#-------------------------------------------------------------------#

	def FindNthSubStringBetweenDIB(n, pcSubStr, pcBound1, pcBound2, pcDirection)
		def FindNthSubStringBetweenDIBZ(n, pcSubStr, pcBound1, pcBound2, pcDirection)
	
		def FindNthSubStringBoundedByDIB(n, pcSubStr, pacBounds, pcDirection)
		def FindNthSubStringBoundedByDIBZ(n, pcSubStr, pacBounds, pcDirection)

		#--

		def NthSubStringBetweenDIB(n, pcSubStr, pcBound1, pcBound2, pcDirection)
		def NthSubStringBetweenDIBZ(n, pcSubStr, pcBound1, pcBound2, pcDirection)
	
		def NthSubStringBoundedByDIB(n, pcSubStr, pacBounds, pcDirection)
		def NthSubStringBoundedByDIBZ(n, pcSubStr, pacBounds, pcDirection)

	   #-----------------------------------------------------------------------------#
	  #  FINDING NTH OCCURRENCE OF A SUBSTRING BOUNDED BY TWO SubString GOING      #
	 #  IN A GIVEN DIRECTION, INCLUDING BOUNDS, AND RETURNING POSITION AS SECTION  #                  #                   #
	#-----------------------------------------------------------------------------#

	def FindNthSubStringBetweenDIBZZ(n, pcSubStr, pcBound1, pcBound2, pcDirection)
		def FindNthSubStringBetweenAsSectionDIB(n, pcSubStr, pcBound1, pcBound2, pcDirection)
	
		def FindNthSubstringBoundedByDIBZZ(n, pcSubStr, pacBounds, pnStartingAt)
		def FindNthSubstringBoundedByAsSectionDIB(n, pcSubStr, pacBounds, pnStartingAt)

		#--

		def NthSubStringBetweenDIBZZ(n, pcSubStr, pcBound1, pcBound2, pcDirection)
		def NthSubStringBetweenAsSectionDIB(n, pcSubStr, pcBound1, pcBound2, pcDirection)
	
		def NthSubstringBoundedByDIBZZ(n, pcSubStr, pacBounds, pnStartingAt)
		def NthSubstringBoundedByAsSectionDIB(n, pcSubStr, pacBounds, pnStartingAt)

	   #-------------------------------------------------------------------#
	  #  FINDING NTH OCCURRENCE OF A SUBSTRING BOUNDED BY TWO SubString  #
	 #  STARTING AT A GIVEN POSITION AND GOING IN A GIVEN DIRECTION      #
	#-------------------------------------------------------------------#

	def FindNthSubStringBetweenSD(n, pcSubStr, pcBound1, pcBound2, pnStartingAt, pcDirection)
		def FindNthSubStringBetweenSDZ(n, pcSubStr, pcBound1, pcBound2, pnStartingAt, pcDirection)
	
		def FindNthSubStringBoundedBySD(n, pcSubStr, pacBounds, pnStartingAt, pcDirection)
		def FindNthSubStringBoundedBySDZ(n, pcSubStr, pacBounds, pnStartingAt, pcDirection)

		#--

		def NthSubStringBetweenSD(n, pcSubStr, pcBound1, pcBound2, pnStartingAt, pcDirection)
		def NthSubStringBetweenSDZ(n, pcSubStr, pcBound1, pcBound2, pnStartingAt, pcDirection)
	
		def NthSubStringBoundedBySD(n, pcSubStr, pacBounds, pnStartingAt, pcDirection)
		def NthSubStringBoundedBySDZ(n, pcSubStr, pacBounds, pnStartingAt, pcDirection)

	   #----------------------------------------------------------------------------------#
	  #  FINDING NTH OCCURRENCE OF A SUBSTRING BOUNDED BY TWO SubString STARTING AT     #
	 #  A GIVEN POSITION, GOING IN A GIVEN DIRECTION AND RETURNING POSITION AS SECTION  #                  #
	#----------------------------------------------------------------------------------#

	def FindNthSubStringBetweenSDZZ(n, pcSubStr, pcBound1, pcBound2, pnStartingAt, pcDirection)
		def FindNthSubStringBetweenAsSectionSD(n, pcSubStr, pcBound1, pcBound2, pnStartingAt, pcDirection)
	
		def FindNthSubstringBoundedBySDZZ(n, pcSubStr, pacBounds, pnStartingAt, pcDirection)
		def FindNthSubstringBoundedByAsSectionSD(n, pcSubStr, pacBounds, pnStartingAt, pcDirection)
	
		#--

		def NthSubStringBetweenSDZZ(n, pcSubStr, pcBound1, pcBound2, pnStartingAt, pcDirection)
		def NthSubStringBetweenAsSectionSD(n, pcSubStr, pcBound1, pcBound2, pnStartingAt, pcDirection)
	
		def NthSubstringBoundedBySDZZ(n, pcSubStr, pacBounds, pnStartingAt, pcDirection)
		def NthSubstringBoundedByAsSectionSD(n, pcSubStr, pacBounds, pnStartingAt, pcDirection)

	   #-----------------------------------------------------------------------------#
	  #  FINDING NTH OCCURRENCE OF A SUBSTRING BOUNDED BY TWO SubString STARTING   #
	 #  AT A GIVEN POSITION, GOING IN A GIVEN DIRECTION AND INCLUDING BOUNDS       #
	#-----------------------------------------------------------------------------#

	def FindNthSubStringBetweenSDIB(n, pcSubStr, pcBound1, pcBound2, pnStartingAt, pcDirection)
		def FindNthSubStringBetweenSDIBZ(n, pcSubStr, pcBound1, pcBound2, pnStartingAt, pcDirection)
	
		def FindNthSubStringBoundedBySDIB(n, pcSubStr, pacBounds, pnStartingAt, pcDirection)
		def FindNthSubStringBoundedBySDIBZ(n, pcSubStr, pacBounds, pnStartingAt, pcDirection)

		#--

		def NthSubStringBetweenSDIB(n, pcSubStr, pcBound1, pcBound2, pnStartingAt, pcDirection)
		def NthSubStringBetweenSDIBZ(n, pcSubStr, pcBound1, pcBound2, pnStartingAt, pcDirection)
	
		def NthSubStringBoundedBySDIB(n, pcSubStr, pacBounds, pnStartingAt, pcDirection)
		def NthSubStringBoundedBySDIBZ(n, pcSubStr, pacBounds, pnStartingAt, pcDirection)

	   #----------------------------------------------------------------------------------------------------#
	  #  FINDING NTH OCCURRENCE OF A SUBSTRING BOUNDED BY TWO SubString STARTING AT A GIVEN POSITION,     #
	 #  GOING IN A GIVEN DIRECTION, INCLUDING BOUNDS, AND RETURNING POSITION AS SECTION                   #
	#----------------------------------------------------------------------------------------------------#

	def FindNthSubStringBetweenSDIBZZ(n, pcSubStr, pcBound1, pcBound2, pnStartingAt, pcDirection)
		def FindNthSubStringBetweenAsSectionSDIB(n, pcSubStr, pcBound1, pcBound2, pnStartingAt, pcDirection)
	
		def FindNthSubstringBoundedBySDIBZZ(n, pcSubStr, pacBounds, pnStartingAt)
		def FindNthSubstringBoundedByAsSectionSDIB(n, pcSubStr, pacBounds, pnStartingAt)

		#--

		def NthSubStringBetweenSDIBZZ(n, pcSubStr, pcBound1, pcBound2, pnStartingAt, pcDirection)
		def NthSubStringBetweenAsSectionSDIB(n, pcSubStr, pcBound1, pcBound2, pnStartingAt, pcDirection)
	
		def NthSubstringBoundedBySDIBZZ(n, pcSubStr, pacBounds, pnStartingAt)
		def NthSubstringBoundedByAsSectionSDIB(n, pcSubStr, pacBounds, pnStartingAt)

	  #--------------------------------------------------------------#
	 #  FINDING FIRST OCCURRENCE OF A SUBSTRING BETWEEN TWO BOUNDS  #
	#--------------------------------------------------------------#

	def FindFirstSubStringBetween(pcSubStr, pcBound1, pcBound2)
		def FindFirstSubStringBetweenZ(pcSubStr, pcBound1, pcBound2)
	
		def FindFirstSubStringBoundedBy(pcSubStr, pacBounds)
		def FindFirstSubStringBoundedByZ(pcSubStr, pacBounds)

		#--

		def FirstSubStringBetween(pcSubStr, pcBound1, pcBound2)
		def FirstSubStringBetweenZ(pcSubStr, pcBound1, pcBound2)
	
		def FirstSubStringBoundedBy(pcSubStr, pacBounds)
		def FirstSubStringBoundedByZ(pcSubStr, pacBounds)

	   #--------------------------------------------------------------#
	  #  FINDING FIRST OCCURRENCE OF A SUBSTRING BETWEEN TWO BOUNDS  #
	 #  AND RETURNING ITS POSITION AS A SECTION                     #
	#--------------------------------------------------------------#

	def FindFirstSubStringBetweenZZ(pcSubStr, pcBound1, pcBound2)
		def FindFirstSubStringBetweenAsSection(pcSubStr, pcBound1, pcBound2)
	
		def FindFirstSubStringBoundedByZZ(pcSubStr, pacBounds)
		def FindFirstSubStringBoundedByAsSection(pcSubStr, pacBounds)

		#--

		def FirstSubStringBetweenZZ(pcSubStr, pcBound1, pcBound2)
		def FirstSubStringBetweenAsSection(pcSubStr, pcBound1, pcBound2)
	
		def FirstSubStringBoundedByZZ(pcSubStr, pacBounds)
		def FirstSubStringBoundedByAsSection(pcSubStr, pacBounds)

	   #--------------------------------------------------------------#
	  #  FINDING FIRST OCCURRENCE OF A SUBSTRING BETWEEN TWO BOUNDS  #
	 #  INCLUDING BOUNDS                                            #
	#--------------------------------------------------------------#

	def FindFirstSubStringBetweenIB(pcSubStr, pcBound1, pcBound2)
		def FindFirstSubStringBetweenIBZ(pcSubStr, pcBound1, pcBound2)
	
		def FindFirstSubStringBoundedByIB(pcSubStr, pacBounds)
		def FindFirstSubStringBoundedByIBZ(pcSubStr, pacBounds)

		#--

		def FirstSubStringBetweenIB(pcSubStr, pcBound1, pcBound2)
		def FirstSubStringBetweenIBZ(pcSubStr, pcBound1, pcBound2)
	
		def FirstSubStringBoundedByIB(pcSubStr, pacBounds)
		def FirstSubStringBoundedByIBZ(pcSubStr, pacBounds)

	   #---------------------------------------------------------------#
	  #  FINDING FIRST OCCURRENCE OF A SUBSTRING BETWEEN TWO BOUNDS   #
	 #  INCLUDING BOUNDS AND RETURNING IT AS SECTION                 #
	#---------------------------------------------------------------#

	def FindFirstSubStringBetweenIBZZ(pcSubStr, pcBound1, pcBound2)
		def FindFirstSubStringBetweenAsSectionIB(pcSubStr, pcBound1, pcBound2)
	
		def FindFirstSubStringBoundedByIBZZ(pcSubStr, pacBounds)
		def FindFirstSubStringBoundedByAsSectionIB(pcSubStr, pacBounds)

		#--

		def FirstSubStringBetweenIBZZ(pcSubStr, pcBound1, pcBound2)
		def FirstSubStringBetweenAsSectionIB(pcSubStr, pcBound1, pcBound2)
	
		def FirstSubStringBoundedByIBZZ(pcSubStr, pacBounds)
		def FirstSubStringBoundedByAsSectionIB(pcSubStr, pacBounds)

	   #---------------------------------------------------------------#
	  #  FINDING FIRST OCCURRENCE OF A SUBSTRING BETWEEN TWO BOUNDS   #
	 #  STARTING AT A GIVEN POSITION                                 #
	#---------------------------------------------------------------#

	def FindFirstSubStringBetweenS(pcSubStr, pcBound1, pcBound2, pnStartingAt)
		def FindFirstSubStringBetweenSZ(pcSubStr, pcBound1, pcBound2, pnStartingAt)
	
		def FindFirstSubStringBoundedByS(pcSubStr, pacBounds, pnStartingAt)
		def FindFirstSubStringBoundedBySZ(pcSubStr, pacBounds, pnStartingAt)

		#--

		def FirstSubStringBetweenS(pcSubStr, pcBound1, pcBound2, pnStartingAt)
		def FirstSubStringBetweenSZ(pcSubStr, pcBound1, pcBound2, pnStartingAt)
	
		def FirstSubStringBoundedByS(pcSubStr, pacBounds, pnStartingAt)
		def FirstSubStringBoundedBySZ(pcSubStr, pacBounds, pnStartingAt)

	   #-----------------------------------------------------------------------#
	  #  FINDING FIRST OCCURRENCE OF A SUBSTRING BETWEEN TWO BOUNDS STARTING  #
	 #  AT A GIVEN POSITION AND RETURNING POSITION AS SECTION                #
	#-----------------------------------------------------------------------#

	def FindFirstSubStringBetweenSZZ(pcSubStr, pcBound1, pcBound2, pnStartingAt)
		def FindFirstSubStringBetweenAsSectionS(pcSubStr, pcBound1, pcBound2, pnStartingAt)
	
		def FindFirstSubstringBoundedBySZZ(pcSubStr, pacBounds, pnStartingAt)
		def FindFirstSubstringBoundedByAsSectionS(pcSubStr, pacBounds, pnStartingAt)

		#--

		def FirstSubStringBetweenSZZ(pcSubStr, pcBound1, pcBound2, pnStartingAt)
		def FirstSubStringBetweenAsSectionS(pcSubStr, pcBound1, pcBound2, pnStartingAt)
	
		def FirstSubstringBoundedBySZZ(pcSubStr, pacBounds, pnStartingAt)
		def FirstSubstringBoundedByAsSectionS(pcSubStr, pacBounds, pnStartingAt)

	   #-----------------------------------------------------------------------#
	  #  FINDING FIRST OCCURRENCE OF A SUBSTRING BETWEEN TWO BOUNDS STARTING  #
	 #  AT A GIVEN POSITION AND INCLUDING BOUNDS                             #
	#-----------------------------------------------------------------------#

	def FindFirstSubStringBetweenSIB(pcSubStr, pcBound1, pcBound2, pnStartingAt)
		def FindFirstSubStringBetweenSIBZ(pcSubStr, pcBound1, pcBound2, pnStartingAt)
	
		def FindFirstSubStringBoundedBySIB(pcSubStr, pacBounds, pnStartingAt)
		def FindFirstSubStringBoundedBySIBZ(pcSubStr, pacBounds, pnStartingAt)

		#--

		def FirstSubStringBetweenSIB(pcSubStr, pcBound1, pcBound2, pnStartingAt)
		def FirstSubStringBetweenSIBZ(pcSubStr, pcBound1, pcBound2, pnStartingAt)
	
		def FirstSubStringBoundedBySIB(pcSubStr, pacBounds, pnStartingAt)
		def FirstSubStringBoundedBySIBZ(pcSubStr, pacBounds, pnStartingAt)

	   #----------------------------------------------------------------------------------#
	  #  FINDING FIRST OCCURRENCE OF A SUBSTRING BETWEEN TWO BOUNDS STARTING AT A GIVEN  #
	 #  POSITION, INCLUDING BOUNDS, AND RETURNING POSITION AS SECTION                   #
	#----------------------------------------------------------------------------------#

	def FindFirstSubStringBetweenSIBZZ(pcSubStr, pcBound1, pcBound2, pnStartingAt)
		def FindFirstSubStringBetweenAsSectionSIB(pcSubStr, pacBounds, pnStartingAt)
	
		def FindFirstSubStringBoundedBySIBZZ(pcSubStr, pacBounds, pnStartingAt)
		def FindFirstSubStringBoundedByAsSectionSIB(pcSubStr, pacBounds, pnStartingAt)

	   #--------------------------------------------------------------#
	  #  FINDING FIRST OCCURRENCE OF A SUBSTRING BETWEEN TWO BOUNDS  #
	 #  GOING IN A GIVEN DIRECTION                                  #
	#--------------------------------------------------------------#

	def FindFirstSubStringBetweenD(pcSubStr, pcBound1, pcBound2, pcDirection)
		def FindFirstSubStringBetweenDZ(pcSubStr, pcBound1, pcBound2, pcDirection)
	
		def FindFirstSubStringBoundedByD(pcSubStr, pacBounds, pnStartingAt)
		def FindFirstSubStringBoundedByDZ(pcSubStr, pacBounds, pnStartingAt)

		#--

		def FirstSubStringBetweenD(pcSubStr, pcBound1, pcBound2, pcDirection)
		def FirstSubStringBetweenDZ(pcSubStr, pcBound1, pcBound2, pcDirection)
	
		def FirstSubStringBoundedByD(pcSubStr, pacBounds, pnStartingAt)
		def FirstSubStringBoundedByDZ(pcSubStr, pacBounds, pnStartingAt)

	   #------------------------------------------------------------------------#
	  #  FINDING FIRST OCCURRENCE OF A SUBSTRING BETWEEN TWO BOUNDS GOING IN   #
	 #  A GIVEN DIRECTION, AND RETURNING POSITION AS SECTION                  #
	#------------------------------------------------------------------------#

	def FindFirstSubStringBetweenDZZ(pcSubStr, pcBound1, pcBound2, pcDirection)
		def FindFirstSubStringBetweenAsSectionD(pcSubStr, pcBound1, pcBound2, pcDirection)
	
		def FindFirstSubstringBoundedByDZZ(pcSubStr, pacBounds, pnStartingAt)
		def FindFirstSubstringBoundedByAsSectionD(pcSubStr, pacBounds, pnStartingAt)

		#--

		def FirstSubStringBetweenDZZ(pcSubStr, pcBound1, pcBound2, pcDirection)
		def FirstSubStringBetweenAsSectionD(pcSubStr, pcBound1, pcBound2, pcDirection)
	
		def FirstSubstringBoundedByDZZ(pcSubStr, pacBounds, pnStartingAt)
		def FirstSubstringBoundedByAsSectionD(pcSubStr, pacBounds, pnStartingAt)

	   #------------------------------------------------------------------------#
	  #  FINDING FIRST OCCURRENCE OF A SUBSTRING BETWEEN TWO BOUNDS GOING IN   #
	 #  A GIVEN DIRECTION, AND INCLUDING BOUNDS                               #
	#------------------------------------------------------------------------#

	def FindFirstSubStringBetweenDIB(pcSubStr, pcBound1, pcBound2, pcDirection)
		def FindFirstSubStringBetweenDIBZ(pcSubStr, pcBound1, pcBound2, pcDirection)
	
		def FindFirstSubStringBoundedByDIB(pcSubStr, pacBounds, pcDirection)
		def FindFirstSubStringBoundedByDIBZ(pcSubStr, pacBounds, pcDirection)

		#--

		def FirstSubStringBetweenDIB(pcSubStr, pcBound1, pcBound2, pcDirection)
		def FirstSubStringBetweenDIBZ(pcSubStr, pcBound1, pcBound2, pcDirection)
	
		def FirstSubStringBoundedByDIB(pcSubStr, pacBounds, pcDirection)
		def FirstSubStringBoundedByDIBZ(pcSubStr, pacBounds, pcDirection)

	   #-----------------------------------------------------------------------------------#
	  #  FINDING FIRST OCCURRENCE OF A SUBSTRING BETWEEN TWO BOUNDS GOING IN A GIVEN      #
	 #  DIRECTION, INCLUDING BOUNDS, AND RETURNING POSITION AS SECTION                   #
	#-----------------------------------------------------------------------------------#

	def FindFirstSubStringBetweenDIBZZ(pcSubStr, pcBound1, pcBound2, pcDirection)
		def FindFirstSubStringBetweenAsSectionDIB(pcSubStr, pcBound1, pcBound2, pcDirection)
	
		def FindFirstSubstringBoundedByDIBZZ(pcSubStr, pacBounds, pnStartingAt)
		def FindFirstSubstringBoundedByAsSectionDIB(pcSubStr, pacBounds, pnStartingAt)

		#--

		def FirstSubStringBetweenDIBZZ(pcSubStr, pcBound1, pcBound2, pcDirection)
		def FirstSubStringBetweenAsSectionDIB(pcSubStr, pcBound1, pcBound2, pcDirection)
	
		def FirstSubstringBoundedByDIBZZ(pcSubStr, pacBounds, pnStartingAt)
		def FirstSubstringBoundedByAsSectionDIB(pcSubStr, pacBounds, pnStartingAt)

	   #-------------------------------------------------------------------------#
	  #  FINDING FIRST OCCURRENCE OF A SUBSTRING BETWEEN TWO BOUNDS SARTING AT  #
	 #  A GIVEN POSITION, AND GOING IN A GIVEN DIRECTION                       #
	#-------------------------------------------------------------------------#

	def FindFirstSubStringBetweenSD(pcSubStr, pcBound1, pcBound2, pnStartingAt, pcDirection)
		def FindFirstSubStringBetweenSDZ(pcSubStr, pcBound1, pcBound2, pnStartingAt, pcDirection)
	
		def FindFirstSubStringBoundedBySD(pcSubStr, pacBounds, pnStartingAt, pcDirection)
		def FindFirstSubStringBoundedBySDZ(pcSubStr, pacBounds, pnStartingAt, pcDirection)
	
		#--

		def FirstSubStringBetweenSD(pcSubStr, pcBound1, pcBound2, pnStartingAt, pcDirection)
		def FirstSubStringBetweenSDZ(pcSubStr, pcBound1, pcBound2, pnStartingAt, pcDirection)
	
		def FirstSubStringBoundedBySD(pcSubStr, pacBounds, pnStartingAt, pcDirection)
		def FirstSubStringBoundedBySDZ(pcSubStr, pacBounds, pnStartingAt, pcDirection)

	   #---------------------------------------------------------------------------------#
	  #  FINDING FIRST OCCURRENCE OF A SUBSTRING BETWEEN TWO BOUNDS SARTING AT A GIVEN  #
	 #  POSITION, GOING IN A GIVEN DIRECTION, AND RETURNING POSITION AS SECTION        #
	#---------------------------------------------------------------------------------#

	def FindFirstSubStringBetweenSDZZ(pcSubStr, pcBound1, pcBound2, pnStartingAt, pcDirection)
		def FindFirstSubStringBetweenAsSectionSD(pcSubStr, pcBound1, pcBound2, pnStartingAt, pcDirection)
	
		def FindFirstSubstringBoundedBySDZZ(pcSubStr, pacBounds, pnStartingAt, pcDirection)
		def FindFirstSubstringBoundedByAsSectionSD(pcSubStr, pacBounds, pnStartingAt, pcDirection)

		#--

		def FirstSubStringBetweenSDZZ(pcSubStr, pcBound1, pcBound2, pnStartingAt, pcDirection)
		def FirstSubStringBetweenAsSectionSD(pcSubStr, pcBound1, pcBound2, pnStartingAt, pcDirection)
	
		def FirstSubstringBoundedBySDZZ(pcSubStr, pacBounds, pnStartingAt, pcDirection)
		def FirstSubstringBoundedByAsSectionSD(pcSubStr, pacBounds, pnStartingAt, pcDirection)

	   #-------------------------------------------------------------------------#
	  #  FINDING FIRST OCCURRENCE OF A SUBSTRING BETWEEN TWO BOUNDS SARTING     #
	 #  AT A GIVEN POSITION, GOING IN A GIVEN DIRECTION, AND INCLUDING BOUNDS  #
	#-------------------------------------------------------------------------#

	def FindFirstSubStringBetweenSDIB(pcSubStr, pcBound1, pcBound2, pnStartingAt, pcDirection)
		def FindFirstSubStringBetweenSDIBZ(pcSubStr, pcBound1, pcBound2, pnStartingAt, pcDirection)
	
		def FindFirstSubStringBoundedBySDIB(pcSubStr, pacBounds, pnStartingAt, pcDirection)
		def FindFirstSubStringBoundedBySDIBZ(pcSubStr, pacBounds, pnStartingAt, pcDirection)

		#--

		def FirstSubStringBetweenSDIB(pcSubStr, pcBound1, pcBound2, pnStartingAt, pcDirection)
		def FirstSubStringBetweenSDIBZ(pcSubStr, pcBound1, pcBound2, pnStartingAt, pcDirection)
	
		def FirstSubStringBoundedBySDIB(pcSubStr, pacBounds, pnStartingAt, pcDirection)
		def FirstSubStringBoundedBySDIBZ(pcSubStr, pacBounds, pnStartingAt, pcDirection)

	   #-------------------------------------------------------------------------------------------#
	  #  FINDING FIRST OCCURRENCE OF A SUBSTRING BETWEEN TWO BOUNDS SARTING AT A GIVEN POSITION,  #
	 #  GOING IN A GIVEN DIRECTION, INCLUDING BOUNDS, AND RETURNING POSITION AS SECTION          #
	#-------------------------------------------------------------------------------------------#

	def FindFirstSubStringBetweenSDIBZZ(pcSubStr, pcBound1, pcBound2, pnStartingAt, pcDirection)
		def FindFirstSubStringBetweenAsSectionSDIB(pcSubStr, pcBound1, pcBound2, pnStartingAt, pcDirection)
	
		def FindFirstSubstringBoundedBySDIBZZ(pcSubStr, pacBounds, pnStartingAt)
		def FindFirstSubstringBoundedByAsSectionSDIB(pcSubStr, pacBounds, pnStartingAt)

		#--

		def FirstSubStringBetweenSDIBZZ(pcSubStr, pcBound1, pcBound2, pnStartingAt, pcDirection)
		def FirstSubStringBetweenAsSectionSDIB(pcSubStr, pcBound1, pcBound2, pnStartingAt, pcDirection)
	
		def FirstSubstringBoundedBySDIBZZ(pcSubStr, pacBounds, pnStartingAt)
		def FirstSubstringBoundedByAsSectionSDIB(pcSubStr, pacBounds, pnStartingAt)

	  #-------------------------------------------------------------#
	 #  FINDING LAST OCCURRENCE OF A SUBSTRING BETWEEN TWO BOUNDS  #
	#-------------------------------------------------------------#

	def FindLastSubStringBetween(pcSubStr, pcBound1, pcBound2)
		def FindLastSubStringBetweenZ(pcSubStr, pcBound1, pcBound2)
	
		def FindLastSubStringBoundedBy(pcSubStr, pacBounds)
		def FindLastSubStringBoundedByZ(pcSubStr, pacBounds)

		#--

		def LastSubStringBetween(pcSubStr, pcBound1, pcBound2)
		def LastSubStringBetweenZ(pcSubStr, pcBound1, pcBound2)
	
		def LastSubStringBoundedBy(pcSubStr, pacBounds)
		def LastSubStringBoundedByZ(pcSubStr, pacBounds)

	   #-------------------------------------------------------------#
	  #  FINDING LAST OCCURRENCE OF A SUBSTRING BETWEEN TWO BOUNDS  #
	 #  AND RETURNING ITS POSITION AS A SECTION                    #
	#-------------------------------------------------------------#

	def FindLastSubStringBetweenZZ(pcSubStr, pcBound1, pcBound2)
		def FindLastSubStringBetweenAsSection(pcSubStr, pcBound1, pcBound2)
	
		def FindLastSubStringBoundedByZZ(pcSubStr, pacBounds)
		def FindLastSubStringBoundedByAsSection(pcSubStr, pacBounds)

		#--

		def LastSubStringBetweenZZ(pcSubStr, pcBound1, pcBound2)
		def LastSubStringBetweenAsSection(pcSubStr, pcBound1, pcBound2)
	
		def LastSubStringBoundedByZZ(pcSubStr, pacBounds)
		def LastSubStringBoundedByAsSection(pcSubStr, pacBounds)

	   #-------------------------------------------------------------#
	  #  FINDING LAST OCCURRENCE OF A SUBSTRING BETWEEN TWO BOUNDS  #
	 #  INCLUDING BOUNDS                                           #
	#-------------------------------------------------------------#

	def FindLastSubStringBetweenIB(pcSubStr, pcBound1, pcBound2)
		def FindLastSubStringBetweenIBZ(pcSubStr, pcBound1, pcBound2)
	
		def FindLastSubStringBoundedByIB(pcSubStr, pacBounds)
		def FindLastSubStringBoundedByIBZ(pcSubStr, pacBounds)

		#--

		def LastSubStringBetweenIB(pcSubStr, pcBound1, pcBound2)
		def LastSubStringBetweenIBZ(pcSubStr, pcBound1, pcBound2)
	
		def LastSubStringBoundedByIB(pcSubStr, pacBounds)
		def LastSubStringBoundedByIBZ(pcSubStr, pacBounds)

	   #--------------------------------------------------------------#
	  #  FINDING LAST OCCURRENCE OF A SUBSTRING BETWEEN TWO BOUNDS   #
	 #  INCLUDING BOUNDS AND RETURNING IT AS SECTION                #
	#--------------------------------------------------------------#

	def FindLastSubStringBetweenIBZZ(pcSubStr, pcBound1, pcBound2)
		def FindLastSubStringBetweenAsSectionIB(pcSubStr, pcBound1, pcBound2)
	
		def FindLastSubStringBoundedByIBZZ(pcSubStr, pacBounds)
		def FindLastSubStringBoundedByAsSectionIB(pcSubStr, pacBounds)

		#--

		def LastSubStringBetweenIBZZ(pcSubStr, pcBound1, pcBound2)
		def LastSubStringBetweenAsSectionIB(pcSubStr, pcBound1, pcBound2)
	
		def LastSubStringBoundedByIBZZ(pcSubStr, pacBounds)
		def LastSubStringBoundedByAsSectionIB(pcSubStr, pacBounds)

	   #--------------------------------------------------------------#
	  #  FINDING LAST OCCURRENCE OF A SUBSTRING BETWEEN TWO BOUNDS   #
	 #  STARTING AT A GIVEN POSITION                                #
	#--------------------------------------------------------------#

	def FindLastSubStringBetweenS(pcSubStr, pcBound1, pcBound2, pnStartingAt)
		def FindLastSubStringBetweenSZ(pcSubStr, pcBound1, pcBound2, pnStartingAt)
	
		def FindLastSubStringBoundedByS(pcSubStr, pacBounds, pnStartingAt)
		def FindLastSubStringBoundedBySZ(pcSubStr, pacBounds, pnStartingAt)

		#--

		def LastSubStringBetweenS(pcSubStr, pcBound1, pcBound2, pnStartingAt)
		def LastSubStringBetweenSZ(pcSubStr, pcBound1, pcBound2, pnStartingAt)
	
		def LastSubStringBoundedByS(pcSubStr, pacBounds, pnStartingAt)
		def LastSubStringBoundedBySZ(pcSubStr, pacBounds, pnStartingAt)

	   #----------------------------------------------------------------------#
	  #  FINDING LAST OCCURRENCE OF A SUBSTRING BETWEEN TWO BOUNDS STARTING  #
	 #  AT A GIVEN POSITION AND RETURNING POSITION AS SECTION               #
	#----------------------------------------------------------------------#

	def FindLastSubStringBetweenSZZ(pcSubStr, pcBound1, pcBound2, pnStartingAt)
		def FindLastSubStringBetweenAsSectionS(pcSubStr, pcBound1, pcBound2, pnStartingAt)
	
		def FindLastSubstringBoundedBySZZ(pcSubStr, pacBounds, pnStartingAt)
		def FindLastSubstringBoundedByAsSectionS(pcSubStr, pacBounds, pnStartingAt)

		#--

		def LastSubStringBetweenSZZ(pcSubStr, pcBound1, pcBound2, pnStartingAt)
		def LastSubStringBetweenAsSectionS(pcSubStr, pcBound1, pcBound2, pnStartingAt)
	
		def LastSubstringBoundedBySZZ(pcSubStr, pacBounds, pnStartingAt)
		def LastSubstringBoundedByAsSectionS(pcSubStr, pacBounds, pnStartingAt)

	   #----------------------------------------------------------------------#
	  #  FINDING LAST OCCURRENCE OF A SUBSTRING BETWEEN TWO BOUNDS STARTING  #
	 #  AT A GIVEN POSITION AND INCLUDING BOUNDS                            #
	#----------------------------------------------------------------------#

	def FindLastSubStringBetweenSIB(pcSubStr, pcBound1, pcBound2, pnStartingAt)
		def FindLastSubStringBetweenSIBZ(pcSubStr, pcBound1, pcBound2, pnStartingAt)
	
		def FindLastSubStringBoundedBySIB(pcSubStr, pacBounds, pnStartingAt)
		def FindLastSubStringBoundedBySIBZ(pcSubStr, pacBounds, pnStartingAt)

		#--

		def LastSubStringBetweenSIB(pcSubStr, pcBound1, pcBound2, pnStartingAt)
		def LastSubStringBetweenSIBZ(pcSubStr, pcBound1, pcBound2, pnStartingAt)
	
		def LastSubStringBoundedBySIB(pcSubStr, pacBounds, pnStartingAt)
		defLastSubStringBoundedBySIBZ(pcSubStr, pacBounds, pnStartingAt)

	   #---------------------------------------------------------------------------------#
	  #  FINDING LAST OCCURRENCE OF A SUBSTRING BETWEEN TWO BOUNDS STARTING AT A GIVEN  #
	 #  POSITION, INCLUDING BOUNDS, AND RETURNING POSITION AS SECTION                  #
	#---------------------------------------------------------------------------------#

	def FindLastSubStringBetweenSIBZZ(pcSubStr, pcBound1, pcBound2, pnStartingAt)
		def FindLastSubStringBetweenAsSectionSIB(pcSubStr, pacBounds, pnStartingAt)
	
		def FindLastSubStringBoundedBySIBZZ(pcSubStr, pacBounds, pnStartingAt)
		def FindLastSubStringBoundedByAsSectionSIB(pcSubStr, pacBounds, pnStartingAt)

		#--

		def LastSubStringBetweenSIBZZ(pcSubStr, pcBound1, pcBound2, pnStartingAt)
		def LastSubStringBetweenAsSectionSIB(pcSubStr, pacBounds, pnStartingAt)
	
		def LastSubStringBoundedBySIBZZ(pcSubStr, pacBounds, pnStartingAt)
		def LastSubStringBoundedByAsSectionSIB(pcSubStr, pacBounds, pnStartingAt)


	   #--------------------------------------------------------------#
	  #  FINDING LAST OCCURRENCE OF A SUBSTRING BETWEEN TWO BOUNDS  #
	 #  GOING IN A GIVEN DIRECTION                                  #
	#--------------------------------------------------------------#

	def FindLastSubStringBetweenD(pcSubStr, pcBound1, pcBound2, pcDirection)
		def FindLastSubStringBetweenDZ(pcSubStr, pcBound1, pcBound2, pcDirection)
	
		def FindLastSubStringBoundedByD(pcSubStr, pacBounds, pnStartingAt)
		def FindLastSubStringBoundedByDZ(pcSubStr, pacBounds, pnStartingAt)

	   #-----------------------------------------------------------------------#
	  #  FINDING LAST OCCURRENCE OF A SUBSTRING BETWEEN TWO BOUNDS GOING IN   #
	 #  A GIVEN DIRECTION, AND RETURNING POSITION AS SECTION                 #
	#-----------------------------------------------------------------------#

	def FindLastSubStringBetweenDZZ(pcSubStr, pcBound1, pcBound2, pcDirection)
		def FindLastSubStringBetweenAsSectionD(pcSubStr, pcBound1, pcBound2, pcDirection)
	
		def FindLastSubstringBoundedByDZZ(pcSubStr, pacBounds, pnStartingAt)
		def FindLastSubstringBoundedByAsSectionD(pcSubStr, pacBounds, pnStartingAt)

		#--

		def LastSubStringBetweenDZZ(pcSubStr, pcBound1, pcBound2, pcDirection)
		def LastSubStringBetweenAsSectionD(pcSubStr, pcBound1, pcBound2, pcDirection)
	
		def LastSubstringBoundedByDZZ(pcSubStr, pacBounds, pnStartingAt)
		def LastSubstringBoundedByAsSectionD(pcSubStr, pacBounds, pnStartingAt)

	   #-----------------------------------------------------------------------#
	  #  FINDING LAST OCCURRENCE OF A SUBSTRING BETWEEN TWO BOUNDS GOING IN   #
	 #  A GIVEN DIRECTION, AND INCLUDING BOUNDS                              #
	#-----------------------------------------------------------------------#

	def FindLastSubStringBetweenDIB(pcSubStr, pcBound1, pcBound2, pcDirection)
		def FindLastSubStringBetweenDIBZ(pcSubStr, pcBound1, pcBound2, pcDirection)
	
		def FindLastSubStringBoundedByDIB(pcSubStr, pacBounds, pcDirection)
		def FindLastSubStringBoundedByDIBZ(pcSubStr, pacBounds, pcDirection)

		#--

		def LastSubStringBetweenDIB(pcSubStr, pcBound1, pcBound2, pcDirection)
		def LastSubStringBetweenDIBZ(pcSubStr, pcBound1, pcBound2, pcDirection)
	
		def LastSubStringBoundedByDIB(pcSubStr, pacBounds, pcDirection)
		def LastSubStringBoundedByDIBZ(pcSubStr, pacBounds, pcDirection)

	   #--------------------------------------------------------------------------------#
	  #  FINDING LAST OCCURRENCE OF A SUBSTRING BETWEEN TWO BOUNDS GOING IN A GIVEN    #
	 #  DIRECTION, INCLUDING BOUNDS, AND RETURNING POSITION AS SECTION                #
	#--------------------------------------------------------------------------------#

	def FindLastSubStringBetweenDIBZZ(pcSubStr, pcBound1, pcBound2, pcDirection)
		def FindLastSubStringBetweenAsSectionDIB(pcSubStr, pcBound1, pcBound2, pcDirection)
	
		def FindLastSubstringBoundedByDIBZZ(pcSubStr, pacBounds, pnStartingAt)
		def FindLastSubstringBoundedByAsSectionDIB(pcSubStr, pacBounds, pnStartingAt)

		#--

		def LastSubStringBetweenDIBZZ(pcSubStr, pcBound1, pcBound2, pcDirection)
		def LastSubStringBetweenAsSectionDIB(pcSubStr, pcBound1, pcBound2, pcDirection)
	
		def LastSubstringBoundedByDIBZZ(pcSubStr, pacBounds, pnStartingAt)
		def LastSubstringBoundedByAsSectionDIB(pcSubStr, pacBounds, pnStartingAt)

	   #------------------------------------------------------------------------#
	  #  FINDING LAST OCCURRENCE OF A SUBSTRING BETWEEN TWO BOUNDS SARTING AT  #
	 #  A GIVEN POSITION, AND GOING IN A GIVEN DIRECTION                      #
	#------------------------------------------------------------------------#

	def FindLastSubStringBetweenSD(pcSubStr, pcBound1, pcBound2, pnStartingAt, pcDirection)
		def FindLastSubStringBetweenSDZ(pcSubStr, pcBound1, pcBound2, pnStartingAt, pcDirection)
	
		def FindLastSubStringBoundedBySD(pcSubStr, pacBounds, pnStartingAt, pcDirection)
		def FindLastSubStringBoundedBySDZ(pcSubStr, pacBounds, pnStartingAt, pcDirection)

		#--

		def LastSubStringBetweenSD(pcSubStr, pcBound1, pcBound2, pnStartingAt, pcDirection)
		def LastSubStringBetweenSDZ(pcSubStr, pcBound1, pcBound2, pnStartingAt, pcDirection)
	
		def LastSubStringBoundedBySD(pcSubStr, pacBounds, pnStartingAt, pcDirection)
		def LastSubStringBoundedBySDZ(pcSubStr, pacBounds, pnStartingAt, pcDirection)

	   #--------------------------------------------------------------------------------#
	  #  FINDING LAST OCCURRENCE OF A SUBSTRING BETWEEN TWO BOUNDS SARTING AT A GIVEN  #
	 #  POSITION, GOING IN A GIVEN DIRECTION, AND RETURNING POSITION AS SECTION       #
	#--------------------------------------------------------------------------------#

	def FindLastSubStringBetweenSDZZ(pcSubStr, pcBound1, pcBound2, pnStartingAt, pcDirection)
		def FindLastSubStringBetweenAsSectionSD(pcSubStr, pcBound1, pcBound2, pnStartingAt, pcDirection)
	
		def FindLastSubstringBoundedBySDZZ(pcSubStr, pacBounds, pnStartingAt, pcDirection)
		def FindLastSubstringBoundedByAsSectionSD(pcSubStr, pacBounds, pnStartingAt, pcDirection)

		#--

		def LastSubStringBetweenSDZZ(pcSubStr, pcBound1, pcBound2, pnStartingAt, pcDirection)
		def LastSubStringBetweenAsSectionSD(pcSubStr, pcBound1, pcBound2, pnStartingAt, pcDirection)
	
		def LastSubstringBoundedBySDZZ(pcSubStr, pacBounds, pnStartingAt, pcDirection)
		def LastSubstringBoundedByAsSectionSD(pcSubStr, pacBounds, pnStartingAt, pcDirection)

	   #-------------------------------------------------------------------------#
	  #  FINDING LAST OCCURRENCE OF A SUBSTRING BETWEEN TWO BOUNDS SARTING      #
	 #  AT A GIVEN POSITION, GOING IN A GIVEN DIRECTION, AND INCLUDING BOUNDS  #
	#-------------------------------------------------------------------------#

	def FindLastSubStringBetweenSDIB(pcSubStr, pcBound1, pcBound2, pnStartingAt, pcDirection)
		def FindLastSubStringBetweenSDIBZ(pcSubStr, pcBound1, pcBound2, pnStartingAt, pcDirection)
	
		def FindLastSubStringBoundedBySDIB(pcSubStr, pacBounds, pnStartingAt, pcDirection)
		def FindLastSubStringBoundedBySDIBZ(pcSubStr, pacBounds, pnStartingAt, pcDirection)

		#--

		def LastSubStringBetweenSDIB(pcSubStr, pcBound1, pcBound2, pnStartingAt, pcDirection)
		def LastSubStringBetweenSDIBZ(pcSubStr, pcBound1, pcBound2, pnStartingAt, pcDirection)
	
		def LastSubStringBoundedBySDIB(pcSubStr, pacBounds, pnStartingAt, pcDirection)
		def LastSubStringBoundedBySDIBZ(pcSubStr, pacBounds, pnStartingAt, pcDirection)

	   #------------------------------------------------------------------------------------------#
	  #  FINDING LAST OCCURRENCE OF A SUBSTRING BETWEEN TWO BOUNDS SARTING AT A GIVEN POSITION,  #
	 #  GOING IN A GIVEN DIRECTION, INCLUDING BOUNDS, AND RETURNING POSITION AS SECTION         #
	#------------------------------------------------------------------------------------------#

	def FindLastSubStringBetweenSDIBZZ(pcSubStr, pcBound1, pcBound2, pnStartingAt, pcDirection)
		def FindLastSubStringBetweenAsSectionSDIB(pcSubStr, pcBound1, pcBound2, pnStartingAt, pcDirection)
	
		def FindLastSubstringBoundedBySDIBZZ(pcSubStr, pacBounds, pnStartingAt)
		def FindLastSubstringBoundedByAsSectionSDIB(pcSubStr, pacBounds, pnStartingAt)

		#--

		def LastSubStringBetweenSDIBZZ(pcSubStr, pcBound1, pcBound2, pnStartingAt, pcDirection)
		def LastSubStringBetweenAsSectionSDIB(pcSubStr, pcBound1, pcBound2, pnStartingAt, pcDirection)
	
		def LastSubstringBoundedBySDIBZZ(pcSubStr, pacBounds, pnStartingAt)
		def LastSubstringBoundedByAsSectionSDIB(pcSubStr, pacBounds, pnStartingAt)

#=====

