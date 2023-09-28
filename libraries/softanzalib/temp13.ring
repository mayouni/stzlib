

	  #===========================================================================#
	 #  CHECKING IF THE STRING CONTAINS A SBISTRING BETWEEN TWO OTHER SUBSTRINGS  #
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
	 #  GETTING THE NUMBER OF OCCURRENCES OF A SUBSTRING BOUBDED BY TWO OTHER SUBSTRINGS  #
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
	 #  TWO OTHER SUBSTRINGS STARTING AT A GIVEN POSITION             #
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
	 #  BOUNDED BY TWO OTHER SUBSTRINGS                                      #
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
	 #  BOUNDED BY TWO OTHER SUBSTRINGS STARTING AT A GIVEN POSITION          #
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
	 #  FINDING OCCURRENCES OF A SUBSTRING BOUNDED BY TWO OTHER SUBSTRINGS  #
	#=====================================================================#

	def FindSubStringBetweenCS(pcSubStr, pcBound1, pcBound2, pCaseSensitive)
		/* ... */

		#< @FunctionAlternativeForms

		def FindSubStringBoundedByCS(pcSubStr, pacBounds, pCaseSensitive)
			if isString(pacBounds)
				return This.FindSubStringBetweenCS(pcSubStr, pacBounds, pacBounds, pCaseSensitive)

			but isList(pacBounds) and Q(pacBounds).IsPairOfStrings()
				return This.FindSubStringBetweenCS(pcSubStr, pacBounds[1], pacBounds[2], pCaseSensitive)

			else
				StzRaise("Incorrect param type! pacBounds must be a string or pair of strings.")
			ok

		#--
	
		def FindSubStringBetweenCSZ(pcSubStr, pcBound1, pcBound2, pCaseSensitive)
			return This.FindSubStringBetweenCS(pcSubStr, pcBound1, pcBound2, pCaseSensitive)

		def FindSubStringBoundedByCSZ(pcSubStr, pacBounds, pCaseSensitive)
			return This.FindSubStringBoundedByCS(pcSubStr, pacBound, pCaseSensitives)

		#==

		def SubStringBetweenCS(pcSubStr, pcBound1, pcBound2, pCaseSensitive)
			return This.FindSubStringBetweenCS(pcSubStr, pcBound1, pcBound2, pCaseSensitive)

		def SubstringBoundedByCS(pcSubStr, pacBounds, pCaseSensitive)
			return This.FindSubStringBoundedByCS(pcSubStr, pacBounds, pCaseSensitive)
	
		def SubStringBetweenCSZ(pcSubStr, pcBound1, pcBound2, pCaseSensitive)
			return This.FindSubStringBetweenCS(pcSubStr, pcBound1, pcBound2, pCaseSensitive)

		def SubStringBoundedByCSZ(pcSubStr, pacBounds, pCaseSensitive)
			return This.FindSubStringBoundedByCS(pcSubStr, pacBounds, pCaseSensitive)

		#>

	#-- WITHOUT CASESENSITIVE

	def FindSubstringBetween(pcSubStr, pcBound1, pcBound2)
		return This.FindSubStringSubStringBetweenCS(pcSubStr, pcBound1, pcBound1, :CaseSensitive = TRUE)

		#< @FunctionAlternativeForms

		def FindSubStringBoundedBy(pcSubStr, pacBounds)
			return This.FindSubStringBoundedByCS(pcSubStr, pacBounds, :CaseSensitive = TRUE)

		#--
	
		def FindSubStringBetweenZ(pcSubStr, pcBound1, pcBound2)
			return This.FindSubStringBetween(pcSubStr, pcBound1, pcBound2)

		def FindSubStringBoundedByZ(pcSubStr, pacBounds)
			return This.FindSubStringBoundedBy(pcSubStr, pacBounds)

		#==

		def SubStringBetween(pcSubStr, pcBound1, pcBound2)
			return This.FindSubStringBetween(pcSubStr, pcBound1, pcBound2)

		def SubstringBoundedBy(pcSubStr, pacBounds)
			return This.FindSubStringBoundedBy(pcSubStr, pacBounds)
	
		def SubStringBetweenZ(pcSubStr, pcBound1, pcBound2)
			return This.FindSubStringBetween(pcSubStr, pcBound1, pcBound2)

		def SubStringBoundedByZ(pcSubStr, pacBounds)
			return This.FindSubStringBoundedBy(pcSubStr, pacBounds)

		#>

	   #------------------------------------------------------#
	  #  FINDING A SUBSTRING BOUNDED BY TWO OTHER SUBSTRINGS  #
	 #  AND RETURNING THEM AS SECTIONS                      #
	#------------------------------------------------------#

	def FindSubStringBetweenCSZZ(pcSubStr, pcBound1, pcBound2, pCaseSensitive)
		/* ... */

		#< @FunctionAlternativeForms

		def FindSubStringBoundedByCSZZ(pcSubStr, pacBounds, pCaseSensitive)
			if isString(pacBounds)
				return This.FindSubStringBetweenCSZZ(pcSubStr, pcBounds, pcBounds, pCaseSensitive)

			but isList(pacBounds) and Q(pacBounds).IsPairOfStrings()
				return This.FindSubStringBetweenCSZZ(pcSubStr, pcBounds[1], pcBounds[2], pCaseSensitive)

			else
				StzRaise("Incorrect param type! pacBounds must be a string or pair of strings.")
			ok

		#--
	
		def FindSubStringBetweenAsSectionsCS(pcSubStr, pcBound1, pcBound2, pCaseSensitive)
			return This.FindSubStringBetweenCSZZ(pcSubStr, pcBound1, pcBound2, pCaseSensitive)

		def FindSubStringBoundedByAsSectionsCS(pcSubStr, pacBounds, pCaseSensitive)
			return This.FindSubStringBoundedByCSZZ(pcSubStr, pacBounds, pCaseSensitive)

		#==

		def SubStringBetweenCSZZ(pcSubStr, pcBound1, pcBound2, pCaseSensitive)
			return This.FindSubStringBetweenCSZZ(pcSubStr, pcBound1, pcBound2, pCaseSensitive)

		def SubStringBoundedByCSZZ(pcSubStr, pacBounds, pCaseSensitive)
			return This.FindSubStringBoundedByCSZZ(pcSubStr, pacBounds, pCaseSensitive)

		def SubStringBetweenAsSectionsCS(pcSubStr, pcBound1, pcBound2, pCaseSensitive)
			return This.FindSubStringBetweenCSZZ(pcSubStr, pcBound1, pcBound2, pCaseSensitive)

		def SubStringBoundedByAsSectionsCS(pcSubStr, pacBounds, pCaseSensitive)
			return This.FindSubStringBoundedByCSZZ(pcSubStr, pacBounds, pCaseSensitive)

		#>

	#-- WITHOUT CASESENSITIVITY

	def FindSubStringBetweenZZ(pcSubStr, pcBound1, pcBound2)
		return This.FindSubStringBetweenCSZZ(pcSubStr, pcBound1, pcBound2, :CaseSensitive = TRUE)

		#< @FunctionAlternativeForms

		def FindSubStringBoundedByZZ(pcSubStr, pacBounds)
			return This.FindSubStringBoundedByZZ(pcSubStr, pacBounds)

		#--
	
		def FindSubStringBetweenAsSections(pcSubStr, pcBound1, pcBound2)
			return This.FindSubStringBetweenZZ(pcSubStr, pcBound1, pcBound2)

		def FindSubStringBoundedByAsSections(pcSubStr, pacBounds)
			return This.FindSubStringBoundedByZZ(pcSubStr, pacBounds)

		#==

		def SubStringBetweenZZ(pcSubStr, pcBound1, pcBound2)
			return This.FindSubStringBetweenZZ(pcSubStr, pcBound1, pcBound2)

		def SubStringBoundedByZZ(pcSubStr, pacBounds)
			return This.FindSubStringBoundedByZZ(pcSubStr, pacBounds)

		def SubStringBetweenAsSections(pcSubStr, pcBound1, pcBound2)
			return This.FindSubStringBetweenZZ(pcSubStr, pcBound1, pcBound2)

		def SubStringBoundedByAsSections(pcSubStr, pacBounds)
			return This.FindSubStringBoundedByZZ(pcSubStr, pacBounds)

		#>

	  #-----------------------------------------------------------------------#
	 #  FINDING A SUBSTRING BOUNDED BY TWO OTHER SUBSTRINGS INCLUDING BOUNDS  #
	#-----------------------------------------------------------------------#

	def FindSubStringBetweenCSIB(pcSubStr, pcBound1, pcBound2, pCaseSensitive)
		/* ... */

		#< @FunctionAlternativeForms

		def FindSubStringBoundedByCSIB(pcSubStr, pacBounds, pCaseSensitive)
			if isString(pacBounds)
				return This.FindSubStringBetweenCSIB(pcSubStr, pacBounds, pacBounds, pCaseSensitive)

			but isList(pacBounds) and Q(pacBounds).IsPairOfStrings()
				return This.FindSubStringBetweenCSIB(pcSubStr, pacBounds[1], pacBounds[2], pCaseSensitive)

			else
				StzRaise("Incorrect param type! pacBounds must be a string or pair of strings.")
			ok

		#--
	
		def FindSubStringBetweenCSIBZ(pcSubStr, pcBound1, pcBound2, pCaseSensitive)
			return This.FindSubStringBetweenCSIB(pcSubStr, pcBound1, pcBound2, pCaseSensitive)

		def FindSubStringBoundedByCSIBZ(pcSubStr, pacBounds, pCaseSensitive)
			return This.FindSubStringBoundedByCSIB(pcSubStr, pacBound, pCaseSensitives)

		#==

		def SubStringBetweenCSIB(pcSubStr, pcBound1, pcBound2, pCaseSensitive)
			return This.FindSubStringBetweenCSIB(pcSubStr, pcBound1, pcBound2, pCaseSensitive)

		def SubstringBoundedByCSIB(pcSubStr, pacBounds, pCaseSensitive)
			return This.FindSubStringBoundedByCSIB(pcSubStr, pacBounds, pCaseSensitive)
	
		def SubStringBetweenCSIBZ(pcSubStr, pcBound1, pcBound2, pCaseSensitive)
			return This.FindSubStringBetweenCSIB(pcSubStr, pcBound1, pcBound2, pCaseSensitive)

		def SubStringBoundedByCSIBZ(pcSubStr, pacBounds, pCaseSensitive)
			return This.FindSubStringBoundedByCSIB(pcSubStr, pacBounds, pCaseSensitive)

		#>

	#-- WITHOUT CASESENSITIVE

	def FindSubStringBetweenIB(pcSubStr, pcBound1, pcBound2)
		return This.FindSubStringBetweenCSIB(pcSubStr, pcBound1, pcBound2, :CaseSensitive = TRUE)

		#< @FunctionAlternativeForms

		def FindSubStringBoundedByIB(pcSubStr, pacBounds)
			if isString(pacBounds)
				return This.FindSubStringBetweenIB(pcSubStr, pacBounds, pacBounds)

			but isList(pacBounds) and Q(pacBounds).IsPairOfStrings()
				return This.FindSubStringBetweenIB(pcSubStr, pacBounds[1], pacBounds[2])

			else
				StzRaise("Incorrect param type! pacBounds must be a string or pair of strings.")
			ok

		#--
	
		def FindSubStringBetweenZIB(pcSubStr, pcBound1, pcBound2)
			return This.FindSubStringBetweenIB(pcSubStr, pcBound1, pcBound2)

		def FindSubStringBoundedByZIB(pcSubStr, pacBounds)
			return This.FindSubStringBoundedByIB(pcSubStr, pacBounds)

		#==

		def SubStringBetweenIB(pcSubStr, pcBound1, pcBound2)
			return This.FindSubStringBetweenIB(pcSubStr, pcBound1, pcBound2)

		def SubstringBoundedByIB(pcSubStr, pacBounds)
			return This.FindSubStringBoundedByIB(pcSubStr, pacBounds)
	
		def SubStringBetweenZIB(pcSubStr, pcBound1, pcBound2)
			return This.FindSubStringBetweenIB(pcSubStr, pcBound1, pcBound2)

		def SubStringBoundedByZIB(pcSubStr, pacBounds)
			return This.FindSubStringBoundedByIB(pcSubStr, pacBounds)

		#>

	   #---------------------------------------------------------------#
	  #  FINDING A SUBSTRING BOUNDED BY TWO OTHER SUBSTRINGS          #
	 #  INCLUDING BOUNDS AND RETURNING THEIR POSITIONS AS SECTIONS   #                                    #
	#---------------------------------------------------------------#

	def FindSubStringBetweenCSIBZZ(pcSubStr, pcBound1, pcBound2, pCaseSensitive)
		/* ... */

		#< @FunctionAlternativeForms

		def FindSubStringBoundedByCSIBZZ(pcSubStr, pacBounds, pCaseSensitive)
			if isString(pacBounds)
				return This.FindSubStringBetweenCSIBZZ(pcSubStr, pcBounds, pcBounds, pCaseSensitive)

			but isList(pacBounds) and Q(pacBounds).IsPairOfStrings()
				return This.FindSubStringBetweenCSIBZZ(pcSubStr, pcBounds[1], pcBounds[2], pCaseSensitive)

			else
				StzRaise("Incorrect param type! pacBounds must be a string or pair of strings.")
			ok

		#--
	
		def FindSubStringBetweenAsSectionsCSIB(pcSubStr, pcBound1, pcBound2, pCaseSensitive)
			return This.FindSubStringBetweenCSIBZZ(pcSubStr, pcBound1, pcBound2, pCaseSensitive)

		def FindSubStringBoundedByAsSectionsCSIB(pcSubStr, pacBounds, pCaseSensitive)
			return This.FindSubStringBoundedByCSIBZZ(pcSubStr, pacBounds, pCaseSensitive)

		#==

		def SubStringBetweenCSIBZZ(pcSubStr, pcBound1, pcBound2, pCaseSensitive)
			return This.FindBetweenCSIBZZ(pcSubStr, pcBound1, pcBound2, pCaseSensitive)

		def SubStringBoundedByCSIBZZ(pcSubStr, pacBounds, pCaseSensitive)
			return This.FindSubStringBoundedByCSIBZZ(pcSubStr, pacBounds, pCaseSensitive)

		def SubStringBetweenAsSectionsCSIB(pcSubStr, pcBound1, pcBound2, pCaseSensitive)
			return This.FindSubStringBetweenCSIBZZ(pcSubStr, pcBound1, pcBound2, pCaseSensitive)

		def SubStringBoundedByAsSectionsCSIB(pcSubStr, pacBounds, pCaseSensitive)
			return This.FindSubStringBoundedByCSIBZZ(pcSubStr, pacBounds, pCaseSensitive)

		#>

	#-- WITHOUT CASESENSITIVITY

	def FindSubStringBetweenZZIB(pcSubStr, pcBound1, pcBound2)
		return This.FindSubStringBetweenCSIBZZ(pcSubStr, pcBound1, pcBound2, :CaseSensitive = TRUE)

		#< @FunctionAlternativeForms

		def FindSubStringBetweenIBZZ(pcSubStr, pcBound1, pcBound2)
			return This.FindSubStringBetweenIBZZ(pcSubStr, pcBound1, pcBound2)

		def FindSubStringBoundedByIBZZ(pcSubStr, pacBounds)
			return This.FindSubStringBoundedByIBZZ(pcSubStr, pacBounds)

		#--
	
		def FindSubStringBetweenAsSectionsIB(pcSubStr, pcBound1, pcBound2)
			return This.FindSubStringBetweenIBZZ(pcSubStr, pcBound1, pcBound2)

		def FindSubStringBoundedByAsSectionsIB(pcSubStr, pacBounds)
			return This.FindSubStringBoundedByIBZZ(pcSubStr, pacBounds)

		#==

		def SubStringBetweenIBZZ(pcSubStr, pcBound1, pcBound2)
			return This.FindSubStringBetweenIBZZ(pcSubStr, pcBound1, pcBound2)

		def SubStringBoundedByIBZZ(pcSubStr, pacBounds)
			return This.FindSubStringBoundedByIBZZ(pcSubStr, pacBounds)

		def SubStringBetweenAsSectionsIB(pcSubStr, pcBound1, pcBound2)
			return This.FindSubStringBetweenIBZZ(pcSubStr, pcBound1, pcBound2)

		def SubStringBoundedByAsSectionsIB(pcSubStr, pacBounds)
			return This.FindSubStringBoundedByIBZZ(pcSubStr, pacBounds)

		#>
		
	   #-------------------------------------------------------#
	  #  FINDING A SUBSTRING BOUNDED BY TWO OTHER SUBSTRINGS  #
	 #  STARTING AT A GIVEN POSITION                         #
	#-------------------------------------------------------#

	def FindSubStringBetweenSCS(pcSubStr, pcBound1, pcBound2, pnStartingAt, pCaseSensitive)
		/* ... */

		#< @FunctionalternativeForms

		def FindSubStringBoundedBySCS(pcSubStr, pacBounds, pnStartingAt, pCaseSensitive)
			if isString(pacBounds)
				return This.FindSubStringBetweenSCS(pcSubStr, pacBounds, pacBounds, pnStartingAt, pCaseSensitive)

			but isList(pacBounds) and Q(pacBounds).IsPairOfStrings()
				return This.FindSubStringBetweenSCS(pcSubStr, pacBounds[1], pacBounds[2], pnStartingAt, pCaseSensitive)

			else
				StzRaise("Incorrect param type! pacBounds must be a string or pair of strings.")
			ok

		#--
	
		def FindSubStringBetweenSCSZ(pcSubStr, pcBound1, pcBound2, pnStartingAt, pCaseSensitive)
			return This.FindSubStringBetweenSCS(pcSubStr, pcBound1, pcBound2, pnStartingAt, pCaseSensitive)

		def FindSubStringBoundedBySCSZ(pcSubStr, pacBounds, pnStartingAt, pCaseSensitive)
			return This.FindSubStringBoundedBySCS(pcSubStr, pacBounds, pnStartingAt, pCaseSensitive)

		#==

		def SubStringBetweenSCS(pcSubStr, pcBound1, pcBound2, pnStartingAt, pCaseSensitive)
			return This.FindSubStringBetweenSCS(pcSubStr, pcBound1, pcBound2, pnStartingAt, pCaseSensitive)

		def SubStringBoundedBySCS(pcSubStr, pacBounds, pnStartingAt, pCaseSensitive)
			return This.FindSubStringBoundedBySCS(pcSubStr, pacBounds, pnStartingAt, pCaseSensitive)

		def SubStringBetweenSCSZ(pcSubStr, pcBound1, pcBound2, pnStartingAt, pCaseSensitive)
			return This.FindSubStringBetweenSCS(pcSubStr, pcBound1, pcBound2, pnStartingAt, pCaseSensitive)

		def SubStringBoundedBySCSZ(pcSubStr, pacBounds, pnStartingAt, pCaseSensitive)
			return This.FindSubStringBoundedBySCS(pcSubStr, pacBounds, pnStartingAt, pCaseSensitive)

		#>

	#-- WITHOUT CASESENSITIVITY

	def FindSubStringBetweenS(pcSubStr, pcBound1, pcBound2, pnStartingAt)
		return This.FindSubStringBetweenSCS(pcSubStr, pcBound1, pcBound2, pnStartingAt, :CaseSensitive = TRUE)

		#< @FunctionAlternativeForms

		def FindSubStringBoundedByS(pcSubStr, pacBounds, pnStartingAt)
			return This.FindSubStringBoundedByS(pcSubStr, pacBounds, pnStartingAt)

		#--
	
		def FindSubStringBetweenSZ(pcSubStr, pcBound1, pcBound2, pnStartingAt)
			return This.FindSubStringBetweenS(pcSubStr, pcBound1, pcBound2, pnStartingAt)

		def FindSubStringBoundedBySZ(pcSubStr, pacBounds, pnStartingAt)
			return This.FindSubStringBoundedByS(pcSubStr, pacBounds, pnStartingAt)

		#==

		def SubStringBetweenS(pcSubStr, pcBound1, pcBound2, pnStartingAt)
			return This.FindBetweenS(pcSubStr, pcBound1, pcBound2, pnStartingAt)

		def SubStringBoundedByS(pcSubStr, pacBounds, pnStartingAt)
			return This.FindSubStringBoundedByS(pcSubStr, pacBounds, pnStartingAt)

		def SubStringBetweenSZ(pcSubStr, pcBound1, pcBound2, pnStartingAt)
			return This.FindSubStringBetweenS(pcSubStr, pcBound1, pcBound2, pnStartingAt)

		def SubStringBoundedBySZ(pcSubStr, pacBounds, pnStartingAt)
			return This.FindSubStringBoundedByS(pcSubStr, pacBounds, pnStartingAt)

		#>

	   #-------------------------------------------------------------------#
	  #  FINDING A SUBSTRING BOUNDED BY TWO OTHER SUBSTRINGS STARTING AT  #
	 #  A GIVEN POSITION AND RETURNING POSITIONS AS SECTIONS             #
	#-------------------------------------------------------------------#

	def FindSubStringBetweenSCSZZ(pcSubStr, pcBound1, pcBound2, pnStartingAt, pCaseSensitive)
		/* ... */

		#< @FunctionAlternativeForms

		def FindSubStringBoundedBySCSZZ(pcSubStr, pacBounds, pnStartingAt, pCaseSensitive)
			if isString(pacBounds)
				return This.FindSubStringBetweenSCSZZ(pcSubStr, pacBounds, pacBounds, pnStartingAt, pCaseSensitive)

			but isList(pacBounds) and Q(pacBounds).isPairOfStrings()
				return This.FindSubStringBetweenSCSZZ(pcSubStr, pacBounds[1], pacBounds[2], pnStartingAt, pCaseSensitive)

			else
				StzRaise("Incorrect param type! pacBounds must be a string or pair of strings.")
			ok

		#--
	
		def FindSubStringBetweenAsSectionsSCS(pcSubStr, pcBound1, pcBound2, pnStartingAt, pCaseSensitive)
			return This.FindSubStringBetweenSCSZZ(pcSubStr, pcBound1, pcBound2, pnStartingAt, pCaseSensitive)

		def FindSubStringBoundedByAsSectionsSCS(pcSubStr, pacBounds, pnStartingAt, pCaseSensitive)
			return This.FindSubStringBoundedBySCSZZ(pcSubStr, pacBounds, pnStartingAt, pCaseSensitive)

		#==

		def SubStringBetweenSCSZZ(pcSubStr, pcBound1, pcBound2, pnStartingAt, pCaseSensitive)
			return This.FindSubStringBetweenSCSZZ(pcSubStr, pcBound1, pcBound2, pnStartingAt, pCaseSensitive)

		def SubStringBoundedBySCSZZ(pcSubStr, pacBounds, pnStartingAt, pCaseSensitive)
			return This.FindSubStringBoundedBySCSZZ(pcSubStr, pacBounds, pnStartingAt, pCaseSensitive)

		def SubStringBetweenAsSectionsSCS(pcSubStr, pcBound1, pcBound2, pnStartingAt, pCaseSensitive)
			return This.FindSubStringBetweenSCSZZ(pcSubStr, pcBound1, pcBound2, pnStartingAt, pCaseSensitive)

		def SubStringBoundedByAsSectionsSCS(pcSubStr, pacBounds, pnStartingAt, pCaseSensitive)
			return This.FindSubStringBoundedBySCSZZ(pcSubStr, pacBounds, pnStartingAt, pCaseSensitive)

		#>

	#--

	def FindSubStringBetweenSZZ(pcSubStr, pcBound1, pcBound2, pnStartingAt)
		return This.FindSubStringBetweenSCSZZ(pcSubStr, pcBound1, pcBound2, pnStartingAt, :CaseSensitive = TRUE)

		#< @FunctionAlternativeForms

		def FindSubStringBoundedBySZZ(pcSubStr, pacBounds, pnStartingAt)
			return This.FindSubStringBoundedBySZZ(pcSubStr, pacBounds, pnStartingAt)

		#--
	
		def FindSubStringBetweenAsSectionsS(pcSubStr, pcBound1, pcBound2, pnStartingAt)
			return This.FindSubStringBetweenSZZ(pcSubStr, pcBound1, pcBound2, pnStartingAt)

		def FindSubStringBoundedByAsSectionsS(pcSubStr, pacBounds, pnStartingAt)
			return This.FindSubStringBoundedBySZZ(pcSubStr, pacBounds, pnStartingAt)

		#==

		def SubStringBetweenSZZ(pcSubStr, pcBound1, pcBound2, pnStartingAt)
			return This.FindSubStringBetweenSZZ(pcSubStr, pcBound1, pcBound2, pnStartingAt)

		def SubStringBoundedBySZZ(pcSubStr, pacBounds, pnStartingAt)
			return This.FindSubStringBoundedBySZZ(pcSubStr, pacBounds, pnStartingAt)

		def SubStringBetweenAsSectionsS(pcSubStr, pcBound1, pcBound2, pnStartingAt)
			return This.FindSubStringBetweenSZZ(pcSubStr, pcBound1, pcBound2, pnStartingAt)

		def SubStringBoundedByAsSectionsS(pcSubStr, pacBounds, pnStartingAt)
			return This.FindSubStringBoundedBySZZ(pcSubStr, pacBounds, pnStartingAt)

		#>

	   #-------------------------------------------------------#
	  #  FINDING A SUBSTRING BOUNDED BY TWO OTHER SUBSTRINGS  #
	 #  STARTING AT A GIVEN POSITION AND INCLUDING BOUNDS    #
	#-------------------------------------------------------#

	def FindSubStringBetweenSCSIB(pcSubStr, pcBound1, pcBound2, pnStartingAt, pCaseSensitive)
		/* ... */

		#< @FunctionAlternativeForms

		def FindSubStringBoundedBySCSIB(pcSubStr, pacBounds, pnStartingAt, pCaseSensitive)
			if isString(pacBounds)
				return This.FindSubStringBetweenSCSIB(pcSubStr, pacBounds, pacBounds, pnStartingAt, pCaseSensitive)

			but isList(pacBounds) and Q(pacBounds).IsPairOfStrings()
				return This.FindSubStringBetweenSCSIB(pcSubStr, pacBounds[1], pacBounds[2], pnStartingAt, pCaseSensitive)

			else
				StzRaise("Incorrect param type! pacBounds must be a string or pair of strings.")
			ok

		#--
	
		def FindSubStringBetweenSCSIBZ(pcSubStr, pcBound1, pcBound2, pnStartingAt, pCaseSensitive)
			return This.FindSubStringBetweenSCSIB(pcSubStr, pcBound1, pcBound2, pnStartingAt, pCaseSensitive)

		def FindSubStringBoundedBySCSIBZ(pcSubStr, pacBounds, pnStartingAt, pCaseSensitive)
			return This.FindSubStringBoundedBySCSIB(pcSubStr, pacBounds, pnStartingAt, pCaseSensitive)

		#==

		def SubStringBetweenSCSIB(pcSubStr, pcBound1, pcBound2, pnStartingAt, pCaseSensitive)
			return This.FindSubStringBetweenSCSIB(pcSubStr, pcBound1, pcBound2, pnStartingAt, pCaseSensitive)

		def SubStringBoundedBySCSIB(pcSubStr, pacBounds, pnStartingAt, pCaseSensitive)
			return This.FindSubStringBoundedBySCSIB(pcSubStr, pacBounds, pnStartingAt, pCaseSensitive)

		def SubStringBetweenSCSIBZ(pcSubStr, pcBound1, pcBound2, pnStartingAt, pCaseSensitive)
			return This.FindSubStringBetweenSCSIB(pcSubStr, pcBound1, pcBound2, pnStartingAt, pCaseSensitive)

		def SubStringBoundedBySCSIBZ(pcSubStr, pacBounds, pnStartingAt, pCaseSensitive)
			return This.FindSubStringBoundedBySCSIB(pcSubStr, pacBounds, pnStartingAt, pCaseSensitive)

		#>

	#-- WITHOUT CASESENSITIVITY

	def FindSubStringBetweenSIB(pcSubStr, pcBound1, pcBound2, pnStartingAt)
		return This.FindSubStringBetweenSCSIB(pcSubStr, pcBound1, pcBound2, pnStartingAt, :CaseSensitive = TRUE)

		#< @FunctionAlternativeForms

		def FindSubStringBoundedBySIB(pcSubStr, pacBounds, pnStartingAt)
			return This.FindSubStringBoundedBySIB(pcSubStr, pacBounds, pnStartingAt)

		#--
	
		def FindSubStringBetweenSIBZ(pcSubStr, pcBound1, pcBound2, pnStartingAt)
			return This.FindSubStringBetweenSIB(pcSubStr, pcBound1, pcBound2, pnStartingAt)

		def FindSubStringBoundedBySIBZ(pcSubStr, pacBounds, pnStartingAt)
			return This.FindSubStringBoundedBySIB(pcSubStr, pacBounds, pnStartingAt)

		#==

		def SubStringBetweenSIB(pcSubStr, pcBound1, pcBound2, pnStartingAt)
			return This.FindSubStringBetweenSIB(pcSubStr, pcBound1, pcBound2, pnStartingAt)

		def SubStringBoundedBySIB(pcSubStr, pacBounds, pnStartingAt)
			return This.FindBoundedBySIB(pcSubStr, pacBounds, pnStartingAt)

		def SubStringBetweenSIBZ(pcSubStr, pcBound1, pcBound2, pnStartingAt)
			return This.FindSubStringBetweenSIB(pcSubStr, pcBound1, pcBound2, pnStartingAt)

		def SubStringBoundedBySIBZ(pcSubStr, pacBounds, pnStartingAt)
			return This.FindSubStringBoundedBySIB(pcSubStr, pacBounds, pnStartingAt)

		#>

	   #---------------------------------------------------------------------------#
	  #  FINDING A SUBSTRING BOUNDED BY TWO OTHER SUBSTRINGS STARTING AT A GIVEN  #
	 #  POSITION, INCLUDING BOUNDS, AND RETURNING THE POSITIONS AS SECTIONS      #                               #
	#---------------------------------------------------------------------------#

	def FindSubStringBetweenSCSIBZZ(pcSubStr, pcBound1, pcBound2, pnStartingAt, pCaseSensitive)
		/* ... */

		#< @FunctionAlternativeForms

		def FindSubStringBoundedBySCSIBZZ(pcSubStr, pacBounds, pnStartingAt, pCaseSensitive)
			if isString(pacBounds)
				return This.FindSubStringBetweenSCSIBZZ(pcSubStr, pacBounds, pacBounds, pnStartingAt, pCaseSensitive)

			but isList(pacBounds) and Q(pacBounds).IsPairOfStrings()
				return This.FindSubStringBetweenSCSIBZZ(pcSubStr, pacBounds[1], pacBounds[2], pnStartingAt, pCaseSensitive)

			else
				StzRaise("Incorrect param type! pacBounds must be string or pair of strings.")

			ok

		#--
	
		def FindSubStringBetweenAsSectionsSCSIB(pcSubStr, pcBound1, pcBound2, pnStartingAt, pCaseSensitive)
			return This.FindSubStringBetweenSCSIBZZ(pcSubStr, pcBound1, pcBound2, pnStartingAt, pCaseSensitive)

		def FindSubStringBoundedByAsSectionsSCSIB(pcSubStr, pacBounds, pnStartingAt, pCaseSensitive)
			return This.FindSubStringBoundedBySCSIBZZ(pcSubStr, pacBounds, pnStartingAt, pCaseSensitive)

		#==

		def SubStringBetweenSCSIBZZ(pcSubStr, pcBound1, pcBound2, pnStartingAt, pCaseSensitive)
			return This.FindSubStringBetweenSCSIBZZ(pcSubStr, pcBound1, pcBound2, pnStartingAt, pCaseSensitive)

		def SubStringBoundedBySCSIBZZ(pcSubStr, pacBounds, pnStartingAt, pCaseSensitive)
			return This.FindSubStringBoundedBySCSIBZZ(pcSubStr, pacBounds, pnStartingAt, pCaseSensitive)

		def SubStringBetweenAsSectionsSCSIB(pcSubStr, pcBound1, pcBound2, pnStartingAt, pCaseSensitive)
			return This.FindSubStringBetweenSIBCSZZ(pcSubStr, pcBound1, pcBound2, pnStartingAt, pCaseSensitive)

		def SubStringBoundedByAsSectionsSCSIB(pcSubStr, pacBounds, pnStartingAt, pCaseSensitive)
			return This.FindSubStringBoundedBySCSIBZZ(pcSubStr, pacBounds, pnStartingAt, pCaseSensitive)

		#>

	#-- WITHOUT CASESENSITIVITY

	def FindSubStringBetweenSIBZZ(pcSubStr, pcBound1, pcBound2, pnStartingAt)
		return This.FindSubStringBetweenSIBCSZZ(pcSubStr, pcBound1, pcBound2, pnStartingAt, :CaseSensitive = TRUE)

		#< @FunctionAlternativeForms

		def FindSubStringBoundedBySIBZZ(pcSubStr, pacBounds, pnStartingAt)
			return This.FindSubStringBoundedBySIBZZ(pcSubStr, pacBounds, pnStartingAt)

		#--
	
		def FindSubStringBetweenAsSectionsSIB(pcSubStr, pcBound1, pcBound2, pnStartingAt)
			return This.FindSubStringBetweenSIBZZ(pcSubStr, pcBound1, pcBound2, pnStartingAt)

		def FindSubStringBoundedByAsSectionsSIB(pcSubStr, pacBounds, pnStartingAt)
			return This.FindSubStringBoundedBySIBZZ(pcSubStr, pacBounds, pnStartingAt)

		#==

		def SubStringBetweenSIBZZ(pcSubStr, pcBound1, pcBound2, pnStartingAt)
			return This.FindSubStringBetweenSIBZZ(pcSubStr, pcBound1, pcBound2, pnStartingAt)

		def SubStringBoundedBySIBZZ(pcSubStr, pacBounds, pnStartingAt)
			return This.FindSubStringBoundedBySIBZZ(pcSubStr, pacBounds, pnStartingAt)

		def SubStringBetweenAsSectionsSIB(pcSubStr, pcBound1, pcBound2, pnStartingAt)
			return This.FindSubStringBetweenSIBZZ(pcSubStr, pcBound1, pcBound2, pnStartingAt)

		def SubStringBoundedByAsSectionsSIB(pcSubStr, pacBounds, pnStartingAt)
			return This.FindSubStringBoundedBySIBZZ(pcSubStr, pacBounds, pnStartingAt)

		#>

	   #-------------------------------------------------------#
	  #  FINDING A SUBSTRING BOUNDED BY TWO OTHER SUBSTRINGS  #
	 #  GOING IN A GIVEN DIRECTION                           #
	#-------------------------------------------------------#

	def FindSubStringBetweenDCS(pcSubStr, pcBound1, pcBound2, pcDirection, pCaseSensitive)
		/* ... */

		#< @FunctionAlternativeForms

		def FindSubStringBoundedByDCS(pcSubStr, pacBounds, pcDirection, pCaseSensitive)
			if isString(pacBounds)
				return This.FindSubStringBetweenDCS(pcSubStr, pacBounds, pacBounds, pcDirection, pCaseSensitive)

			but isList(pacBounds) and Q(pacBounds).IsPairOfStrings()
				return This.FindSubStringBetweenDCS(pcSubStr, pacBounds[1], pacBounds[2], pcDirection, pCaseSensitive)

			else
				StzRaise("Incorrect param type! pacBounds must be a string or pair of strings.")
			ok

		#--
	
		def FindSubStringBetweenDCSZ(pcSubStr, pcBound1, pcBound2, pcDirection, pCaseSensitive)
			return This.FindSubStringBetweenDCS(pcSubStr, pcBound1, pcBound2, pcDirection, pCaseSensitive)

		def FindSubStringBoundedByDCSZ(pcSubStr, pacBounds, pcDirection, pCaseSensitive)
			return This.FindSubStringBoundedByDCS(pcSubStr, pacBounds, pcDirection, pCaseSensitive)

		#==

		def SubStringBetweenDCS(pcSubStr, pcBound1, pcBound2, pcDirection, pCaseSensitive)
			return This.FindSubStringBetweenDCS(pcSubStr, pcBound1, pcBound2, pcDirection, pCaseSensitive)

		def SubStringBoundedByDCS(pcSubStr, pacBounds, pcDirection, pCaseSensitive)
			return This.FindSubStringBoundedByDCS(pcSubStr, pacBounds, pcDirection, pCaseSensitive)

		def SubStringBetweenDCSZ(pcSubStr, pcBound1, pcBound2, pcDirection, pCaseSensitive)
			return This.FindSubStringBetweenDCS(pcSubStr, pcBound1, pcBound2, pcDirection, pCaseSensitive)

		def SubStringBoundedByDCSZ(pcSubStr, pacBounds, pcDirection, pCaseSensitive)
			return This.FindSubStringBoundedByDCS(pcSubStr, pacBounds, pcDirection, pCaseSensitive)

		#>

	#-- WITHOUT CASESENSITIVITY

	def FindSubStringBetweenD(pcSubStr, pcBound1, pcBound2, pcDirection)
		return This.FindSubStringBetweenDCS(pcSubStr, pcBound1, pcBound2, pcDirection, :CaseSensitive = TRUE)

		#< @FunctionAlternativeForms

		def FindSubStringBoundedByD(pcSubStr, pacBounds, pcDirection)
			return This.FindSubStringBoundedByD(pcSubStr, pacBounds, pcDirection)

		#--
	
		def FindSubStringBetweenDZ(pcSubStr, pcBound1, pcBound2, pcDirection)
			return This.FindSubStringBetweenD(pcSubStr, pcBound1, pcBound2, pcDirection)

		def FindSubStringBoundedByDZ(pcSubStr, pacBounds, pcDirection)
			return This.FindSubStringBoundedByD(pcSubStr, pacBounds, pcDirection)

		#==

		def SubStringBetweenD(pcSubStr, pcBound1, pcBound2, pcDirection)
			return This.FindSubStringBetweenD(pcSubStr, pcBound1, pcBound2, pcDirection)

		def SubStringBoundedByD(pcSubStr, pacBounds, pcDirection)
			return This.FindSubStringBoundedByD(pcSubStr, pacBounds, pcDirection)

		def SubStringBetweenDZ(pcSubStr, pcBound1, pcBound2, pcDirection)
			return This.FindSubStringBetweenD(pcSubStr, pcBound1, pcBound2, pcDirection)

		def SubStringBoundedByDZ(pcSubStr, pacBounds, pcDirection)
			return This.FindSubStringBoundedByD(pcSubStr, pacBounds, pcDirection)

		#>

	   #----------------------------------------------------------------#
	  #  FINDING A SUBSTRING BOUNDED BY TWO OTHER SUBSTRINGS GOING IN  #
	 #  A GIVEN DIRECTION AND RETURNING POSITIONS AS SECTIONS         #                       #
	#----------------------------------------------------------------#

	def FindSubStringBetweenDCSZZ(pcSubStr, pcBound1, pcBound2, pcDirection, pCaseSensitive)
		/* ... */

		#< @FunctionAlternativeForms

		def FindSubStringBoundedByDCSZZ(pcSubStr, pacBounds, pcDirection, pCaseSensitive)
			if isString(pacBounds)
				return This.FindSubStringBetweenDCSZZ(pcSubStr, pacBounds, pacBounds, pcDirection, pCaseSensitive)

			but isList(pacBounds) and Q(pacBounds).IsPairOfNumbers()
				return This.FindSubStringBetweenDCSZZ(pcSubStr, pacBounds[1], pacBounds[2], pcDirection, pCaseSensitive)

			else
				StzRaise("Incorrect param type! pacBounds must be a string or pair of strings.")

			ok

		#--
	
		def FindSubStringBetweenAsSectionsDCS(pcSubStr, pcBound1, pcBound2, pcDirection, pCaseSensitive)
			return This.FindSubStringBetweenDCSZZ(pcSubStr, pcBound1, pcBound2, pcDirection, pCaseSensitive)

		def FindSubStringBoundedByAsSectionsDCS(pcSubStr, pacBounds, pcDirection, pCaseSensitive)
			return This.FindSubStringBoundedByDCSZZ(pcSubStr, pacBounds, pcDirection, pCaseSensitive)

		#==

		def SubStringBetweenDCSZZ(pcSubStr, pcBound1, pcBound2, pcDirection, pCaseSensitive)
			return This.FindSubStringBetweenDCSZZ(pcSubStr, pcBound1, pcBound2, pcDirection, pCaseSensitive)

		def SubStringBoundedByDCSZZ(pcSubStr, pacBounds, pcDirection, pCaseSensitive)
			return This.FindSubStringBoundedByDCSZZ(pcSubStr, pacBounds, pcDirection, pCaseSensitive)

		def SubStringBetweenAsSectionsDCS(pcSubStr, pcBound1, pcBound2, pcDirection, pCaseSensitive)
			return This.FindSubStringBetweenDCSZZ(pcSubStr, pcBound1, pcBound2, pcDirection, pCaseSensitive)

		def SubStringBoundedByAsSectionsDCS(pcSubStr, pacBounds, pcDirection, pCaseSensitive)
			return This.FindSubStringBoundedByDCSZZ(pcSubStr, pacBounds, pcDirection, pCaseSensitive)

		#>

	#-- WITHOUT CASESENSITIVITY

	def FindSubStringBetweenDZZ(pcSubStr, pcBound1, pcBound2, pcDirection)
		return This.FindSubStringBetweenDZZ(pcSubStr, pcBound1, pcBound2, pcDirection)

		#< @FunctionAlternativeForms

		def FindSubStringBoundedByDZZ(pcSubStr, pacBounds, pcDirection)
			return This.FindSubStringBoundedByDZZ(pcSubStr, pacBounds, pcDirection)

		#--
	
		def FindSubStringBetweenAsSectionsD(pcSubStr, pcBound1, pcBound2, pcDirection)
			return This.FindSubStringBetweenDZZ(pcSubStr, pcBound1, pcBound2, pcDirection)

		def FindSubStringBoundedByAsSectionsD(pcSubStr, pacBounds, pcDirection)
			return This.FindSubStringBoundedByDZZ(pcSubStr, pacBounds, pcDirection)

		#==

		def SubStringBetweenDZZ(pcSubStr, pcBound1, pcBound2, pcDirection)
			return This.FindSubStringBetweenDZZ(pcSubStr, pcBound1, pcBound2, pcDirection)

		def SubStringBoundedByDZZ(pcSubStr, pacBounds, pcDirection)
			return This.FindSubStringBoundedByDZZ(pcSubStr, pacBounds, pcDirection)

		def SubStringBetweenAsSectionsD(pcSubStr, pcBound1, pcBound2, pcDirection)
			return This.FindSubStringBetweenDZZ(pcSubStr, pcBound1, pcBound2, pcDirection)

		def SubStringBoundedByAsSectionsD(pcSubStr, pacBounds, pcDirection)
			return This.FindSubStringBoundedByDZZ(pcSubStr, pacBounds, pcDirection)

		#>

	   #-------------------------------------------------------#
	  #  FINDING A SUBSTRING BOUNDED BY TWO OTHER SUBSTRINGS  #
	 #  GOING IN A GIVEN DIRECTION AND INCLUDING BOUNDS      #
	#-------------------------------------------------------#

	def FindSubStringBetweenDCSIB(pcSubStr, pcBound1, pcBound2, pcDirection, pCaseSensitive)
		/* ... */

		#< @FunctionAlternativeForms

		def FindSubStringBoundedByDCSIB(pcSubStr, pacBounds, pcDirection, pCaseSensitive)
			if isString(pacBounds)
				return This.FindSubStringBetweenDCSIB(pcSubStr, pacBounds, pacBounds, pcDirection, pCaseSensitive)

			but isList(pacBounds) and Q(pacBounds).IsPairOfStrings()
				return This.FindSubStringBetweenDCSIB(pcSubStr, pacBounds[1], pacBounds[2], pcDirection, pCaseSensitive)

			else
				StzRaise("Incorrect param type! pacBounds must be a string or pair of strings.")
			ok

		#--
	
		def FindSubStringBetweenDCSIBZ(pcSubStr, pcBound1, pcBound2, pcDirection, pCaseSensitive)
			return This.FindSubStringBetweenDCSIB(pcSubStr, pcBound1, pcBound2, pcDirection, pCaseSensitive)

		def FindSubStringBoundedByDCSIBZ(pcSubStr, pacBounds, pcDirection, pCaseSensitive)
			return This.FindSubStringBoundedByDCSIB(pcSubStr, pacBounds, pcDirection, pCaseSensitive)

		#==

		def SubStringBetweenDCSIB(pcSubStr, pcBound1, pcBound2, pcDirection, pCaseSensitive)
			return This.FindSubStringBetweenDCSIB(pcSubStr, pcBound1, pcBound2, pcDirection, pCaseSensitive)

		def SubStringBoundedByDCSIB(pcSubStr, pacBounds, pcDirection, pCaseSensitive)
			return This.FindSubStringBoundedByDCSIB(pcSubStr, pacBounds, pcDirection, pCaseSensitive)

		def SubStringBetweenDCSIBZ(pcSubStr, pcBound1, pcBound2, pcDirection, pCaseSensitive)
			return This.FindSubStringBetweenDCSIB(pcSubStr, pcBound1, pcBound2, pcDirection, pCaseSensitive)

		def SubStringBoundedByDCSIBZ(pcSubStr, pacBounds, pcDirection, pCaseSensitive)
			return This.FindSubStringBoundedByDCSIB(pcSubStr, pacBounds, pcDirection, pCaseSensitive)

		#>

	#-- WITHOUT CASESENSITIVITY

	def FindSubStringBetweenDIB(pcSubStr, pcBound1, pcBound2, pcDirection)
		return This.FindSubStringBetweenDCSIB(pcSubStr, pcBound1, pcBound2, pcDirection, :CaseSensitive = TRUE)

		#< @FunctionAlternativeForms

		def FindSubStringBoundedByDIB(pcSubStr, pacBounds, pcDirection)
			return This.FindBoundedByDIB(pcSubStr, pacBounds, pcDirection)

		#--
	
		def FindSubStringBetweenDIBZ(pcSubStr, pcBound1, pcBound2, pcDirection)
			return This.FindSubStringBetweenDIB(pcSubStr, pcBound1, pcBound2, pcDirection)

		def FindSubStringBoundedByDIBZ(pcSubStr, pacBounds, pcDirection)
			return This.FindSubStringBoundedByDIB(pcSubStr, pacBounds, pcDirection)

		#==

		def SubStringBetweenDIB(pcSubStr, pcBound1, pcBound2, pcDirection)
			return This.FindSubStringBetweenDIB(pcSubStr, pcBound1, pcBound2, pcDirection)

		def SubStringBoundedByDIB(pcSubStr, pacBounds, pcDirection)
			return This.FindSubStringBoundedByDIB(pcSubStr, pacBounds, pcDirection)

		def SubStringBetweenDIBZ(pcSubStr, pcBound1, pcBound2, pcDirection)
			return This.FindSubStringBetweenDIB(pcSubStr, pcBound1, pcBound2, pcDirection)

		def SubStringBoundedByDIBZ(pcSubStr, pacBounds, pcDirection)
			return This.FindSubStringBoundedByDIB(pcSubStr, pacBounds, pcDirection)

		#>

	   #------------------------------------------------------------------------#
	  #  FINDING A SUBSTRING BOUNDED BY TWO OTHER SUBSTRINGS GOING IN A GIVEN  #
	 #  DIRECTION, INCLUDING BOUNDS, AND RETURNING POSITIONS AS SECTIONS      #                   #                       #
	#------------------------------------------------------------------------#

	def FindSubStringBetweenDCSIBZZ(pcSubStr, pcBound1, pcBound2, pcDirection, pCaseSensitive)
		/* ... */

		#< @FunctionAlternativeForms

		def FindSubStringBoundedByDCSIBZZ(pcSubStr, pacBounds, pcDirection, pCaseSensitive)
			if isString(pacBounds)
				return This.FindSubStringBetweenDCSIBZZ(pcSubStr, pacBounds, pacBounds, pcDirection, pCaseSensitive)

			but isList(pacBounds) and Q(pacBounds).IsPairOfNumbers()
				return This.FindSubStringBetweenDCSIBZZ(pcSubStr, pacBounds[1], pacBounds[2], pcDirection, pCaseSensitive)

			else
				StzRaise("Incorrect param type! pacBounds must be a string or pair of strings.")

			ok

		#--
	
		def FindSubStringBetweenAsSectionsDCSIB(pcSubStr, pcBound1, pcBound2, pcDirection, pCaseSensitive)
			return This.FindSubStringBetweenDCSIBZZ(pcSubStr, pcBound1, pcBound2, pcDirection, pCaseSensitive)

		def FindSubStringBoundedByAsSectionsDCSIB(pcSubStr, pacBounds, pcDirection, pCaseSensitive)
			return This.FindBoundedByDCSIBZZ(pcSubStr, pacBounds, pcDirection, pCaseSensitive)

		#==

		def SubStringBetweenDCSIBZZ(pcSubStr, pcBound1, pcBound2, pcDirection, pCaseSensitive)
			return This.FindSubStringBetweenDCSIBZZ(pcSubStr, pcBound1, pcBound2, pcDirection, pCaseSensitive)

		def SubStringBoundedByDCSIBZZ(pcSubStr, pacBounds, pcDirection, pCaseSensitive)
			return This.FindSubStringBoundedByDCSIBZZ(pcSubStr, pacBounds, pcDirection, pCaseSensitive)

		def SubStringBetweenAsSectionsDCSIB(pcSubStr, pcBound1, pcBound2, pcDirection, pCaseSensitive)
			return This.FindSubStringBetweenDCIBSZZ(pcSubStr, pcBound1, pcBound2, pcDirection, pCaseSensitive)

		def SubStringBoundedByAsSectionsDCSIB(pcSubStr, pacBounds, pcDirection, pCaseSensitive)
			return This.FindSubStringBoundedByDCSIBZZ(pcSubStr, pacBounds, pcDirection, pCaseSensitive)

		#>

	#-- WITHOUT CASESENSITIVITY

	def FindSubStringBetweenDIBZZ(pcSubStr, pcBound1, pcBound2, pcDirection)
		return This.FindSubStringBetweenDIBZZ(pcSubStr, pcBound1, pcBound2, pcDirection)

		#< @FunctionAlternativeForms

		def FindSubStringBoundedByDIBZZ(pcSubStr, pacBounds, pcDirection)
			return This.FindSubStringBoundedByDIBZZ(pcSubStr, pacBounds, pcDirection)

		#--
	
		def FindSubStringBetweenAsSectionsDIB(pcSubStr, pcBound1, pcBound2, pcDirection)
			return This.FindSubStringBetweenDIBZZ(pcSubStr, pcBound1, pcBound2, pcDirection)

		def FindSubStringBoundedByAsSectionsDIB(pcSubStr, pacBounds, pcDirection)
			return This.FindSubStringBoundedByDIBZZ(pcSubStr, pacBounds, pcDirection)

		#==

		def SubStringBetweenDIBZZ(pcSubStr, pcBound1, pcBound2, pcDirection)
			return This.FindSubStringBetweenDIBZZ(pcSubStr, pcBound1, pcBound2, pcDirection)

		def SubStringBoundedByDIBZZ(pcSubStr, pacBounds, pcDirection)
			return This.FindSubStringBoundedByDIBZZ(pcSubStr, pacBounds, pcDirection)

		def SubStringBetweenAsSectionsDIB(pcSubStr, pcBound1, pcBound2, pcDirection)
			return This.FindSubStringBetweenDIBZZ(pcSubStr, pcBound1, pcBound2, pcDirection)

		def SubStringBoundedByAsSectionsDIB(pcSubStr, pacBounds, pcDirection)
			return This.FindSubStringBoundedByDIBZZ(pcSubStr, pacBounds, pcDirection)

		#>

	   #----------------------------------------------------------------#
	  #  FINDING A SUBSTRING BOUNDED BY TWO OTHER SUBSTRINGS STARTING  #
	 #  AT A GIVEN POSITION AND GOING IN A GIVEN DIRECTION            #
	#----------------------------------------------------------------#

	def FindSubStringBetweenSDCS(pcSubStr, pcBound1, pcBound2, pnStartingAt, pcDirection, pCaseSensitive)
		/* ... */

		#< @FunctionAlternativeForms

		def FindSubStringBoundedBySDCS(pcSubStr, pacBounds, pnStartingAt, pcDirection, pCaseSensitive)
			if isString(pacBounds)
				return This.FindSubStringBetweenSDCS(pcSubStr, pacBounds, pacBounds, pnStartingAt, pcDirection, pCaseSensitive)

			but isLsit(pacBounds) and Q(pacBounds).IsPairOfStrings()
				return This.FindSubStringBetweenSDCS(pcSubStr, pacBounds[1], pacBounds[2], pnStartingAt, pcDirection, pCaseSensitive)

			else
				StzRaise("Incorrect param type! pacBounds must be a string or pair of strings.")

			ok

		#--
	
		def FindSubStringBetweenSDCSZ(pcSubStr, pcBound1, pcBound2, pnStartingAt, pcDirection, pCaseSensitive)
			return This.FindSubStringBetweenSDCS(pcSubStr, pcBound1, pcBound2, pnStartingAt, pcDirection, pCaseSensitive)

		def FindSubStringBoundedBySDCSZ(pcSubStr, pacBounds, pnStartingAt, pcDirection, pCaseSensitive)
			return This.FindSubStringBoundedBySDCS(pcSubStr, pacBounds, pnStartingAt, pcDirection, pCaseSensitive)

		#==

		def SubStringBetweenSDCS(pcSubStr, pcBound1, pcBound2, pnStartingAt, pcDirection, pCaseSensitive)
			return This.FindSubStringBetweenSD(pcSubStr, pcBound1, pcBound2, pnStartingAt, pcDirection)

		def SubStringBoundedBySDCS(pcSubStr, pacBounds, pnStartingAt, pcDirection, pCaseSensitive)
			return This.FindSubStringBoundedBySDCS(pcSubStr, pacBounds, pnStartingAt, pcDirection, pCaseSensitive)

		def SubStringBetweenSDCSZ(pcSubStr, pcBound1, pcBound2, pnStartingAt, pcDirection, pCaseSensitive)
			return This.FindSubStringBetweenSDCS(pcSubStr, pcBound1, pcBound2, pnStartingAt, pcDirection, pCaseSensitive)

		def SubStringBoundedBySDCSZ(pcSubStr, pacBounds, pnStartingAt, pcDirection, pCaseSensitive)
			return This.FindSubStringBoundedBySDCS(pcSubStr, pacBounds, pnStartingAt, pcDirection, pCaseSensitive)

		#>

	#-- WITHOUT CASESENSITIVITY

	def FindSubStringBetweenSD(pcSubStr, pcBound1, pcBound2, pnStartingAt, pcDirection)
		return This.FindSubStringBetweenSDCS(pcSubStr, pcBound1, pcBound2,pnStartingAt, pcDirection, :CaseSensitive = TRUE)

		#< @FunctionAlternativeForms

		def FindSubStringBoundedBySD(pcSubStr, pacBounds, pnStartingAt, pcDirection)
			return This.FindSubStringBoundedBySD(pcSubStr, pacBounds, pnStartingAt, pcDirection)

		#--
	
		def FindSubStringBetweenSDZ(pcSubStr, pcBound1, pcBound2, pnStartingAt, pcDirection)
			return This.FindSubStringBetweenSD(pcSubStr, pcBound1, pcBound2, pnStartingAt, pcDirection)

		def FindSubStringBoundedBySDZ(pcSubStr, pacBounds, pnStartingAt, pcDirection)
			return This.FindSubStringBoundedBySD(pcSubStr, pacBounds, pnStartingAt, pcDirection)

		#==

		def SubStringBetweenSD(pcSubStr, pcBound1, pcBound2, pnStartingAt, pcDirection)
			return This.FindSubStringBetweenSD(pcSubStr, pcBound1, pcBound2, pnStartingAt, pcDirection)

		def SubStringBoundedBySD(pcSubStr, pacBounds, pnStartingAt, pcDirection)
			return This.FindSubStringBoundedBySD(pcSubStr, pacBounds, pnStartingAt, pcDirection)

		def SubStringBetweenSDZ(pcSubStr, pcBound1, pcBound2, pnStartingAt, pcDirection)
			return This.FindSubStringBetweenSD(pcSubStr, pcBound1, pcBound2, pnStartingAt, pcDirection)

		def SubStringBoundedBySDZ(pcSubStr, pacBounds, pnStartingAt, pcDirection)
			return This.FindSubStringBoundedBySD(pcSubStr, pacBounds, pnStartingAt, pcDirection)

		#>

	   #-------------------------------------------------------------------------------#
	  #  FINDING A SUBSTRING BOUNDED BY TWO OTHER SUBSTRINGSS STARTING AT A GIVEN      #
	 #  POSITION, GOING IN A GIVEN DIRECTION, AND RETURNING POSITIONS AS SECTIONS    #
	#-------------------------------------------------------------------------------#

	def FindSubStringBetweenSDCSZZ(pcSubStr, pcBound1, pcBound2, pnStartingAt, pcDirection, pCaseSensitive)
		/* ... */

		#< @FunctionAlternativeForms

		def FindSubStringBoundedBySDCSZZ(pcSubStr, pacBounds, pnStartingAt, pcDirection, pCaseSensitive)
			return This.FindBoundedBySDCSZZ(pcSubStr, pacBounds, pnStartingAt, pcDirection, pCaseSensitive)

		#--
	
		def FindSubStringBetweenAsSectionsSDCS(pcSubStr, pcBound1, pcBound2, pnStartingAt, pcDirection, pCaseSensitive)
			return This.FindSubStringBetweenSDCSZZ(pcSubStr, pcBound1, pcBound2, pnStartingAt, pcDirection, pCaseSensitive)

		def FindSubStringBoundedByAsSectionsSDCS(pcSubStr, pacBounds, pnStartingAt, pcDirection, pCaseSensitive)
			return This.FindSubStringBoundedBySDCSZZ(pcSubStr, pacBounds, pnStartingAt, pcDirection, pCaseSensitive)

		#==

		def SubStringBoundedBySDCSZZ(pcSubStr, pacBounds, pnStartingAt, pcDirection, pCaseSensitive)
			return This.FindSubStringBoundedBySDCSZZ(pcSubStr, pacBounds, pnStartingAt, pcDirection, pCaseSensitive)

		def SubStringBoundedByAsSectionsSDCS(pcSubStr, pacBounds, pnStartingAt, pcDirection, pCaseSensitive)
			return This.FindSubStringBoundedBySDCSZZ(pcSubStr, pacBounds, pnStartingAt, pcDirection, pCaseSensitive)

		#>

	#-- WITHOUT CASESENSITIVITY

	def FindSubStringBetweenSDZZ(pcSubStr, pcBound1, pcBound2, pnStartingAt, pcDirection)
		return This.FindSubStringBetweenSDCSZZ(pcSubStr, pcBound1, pcBound2, pnStartingAt, pcDirection, :CaseSensitive = TRUE)

		#< @FunctionAlternativeForms

		def FindSubStringBoundedBySDZZ(pcSubStr, pacBounds, pnStartingAt, pcDirection)
			return This.FindBoundedBySDZZ(pcSubStr, pacBounds, pnStartingAt, pcDirection)

		#--
	
		def FindSubStringBetweenAsSectionsSD(pcSubStr, pcBound1, pcBound2, pnStartingAt, pcDirection)
			return This.FindSubStringBetweenSDZZ(pcSubStr, pcBound1, pcBound2, pnStartingAt, pcDirection)

		def FindSubStringBoundedByAsSectionsSD(pcSubStr, pacBounds, pnStartingAt, pcDirection)
			return This.FindSubStringBoundedBySDZZ(pcSubStr, pacBounds, pnStartingAt, pcDirection)

		#==

		def SubStringBetweenSDZZ(pcSubStr, pcBound1, pcBound2, pnStartingAt, pcDirection)
			return This.FindSubStringBetweenSDZZ(pcSubStr, pcBound1, pcBound2, pnStartingAt, pcDirection)

		def SubStringBoundedBySDZZ(pcSubStr, pacBounds, pnStartingAt, pcDirection)
			return This.FindSubStringBoundedBySDZZ(pcSubStr, pacBounds, pnStartingAt, pcDirection)

		def SubStringBetweenAsSectionsSD(pcSubStr, pcBound1, pcBound2, pnStartingAt, pcDirection)
			return This.FindSubStringBetweenSDZZ(pcSubStr, pcBound1, pcBound2, pnStartingAt, pcDirection)

		def SubStringBoundedByAsSectionsSD(pcSubStr, pacBounds, pnStartingAt, pcDirection)
			return This.FindSubStringBoundedBySDZZ(pcSubStr, pacBounds, pnStartingAt, pcDirection)

		#>

	   #-----------------------------------------------------------------------------#
	  #  FINDING A SUBSTRING BOUNDED BY TWO OTHER SUBSTRINGSS STARTING AT A GIVEN    #
	 #  POSITION, GOING IN A GIVEN DIRECTION, AND INCLUDING BOUNDS                 #
	#-----------------------------------------------------------------------------#

	def FindSubStringBetweenSDCSIB(pcSubStr, pcBound1, pcBound2, pnStartingAt, pcDirection, pCaseSensitive)
		/* ... */

		#< @FunctionAlternativeForms

		def FindSubStringBoundedBySDCSIB(pcSubStr, pacBounds, pnStartingAt, pcDirection, pCaseSensitive)
			if isString(pacBounds)
				return This.FindSubStringBetweenSDCSIB(pcSubStr, pacBounds, pacBounds, pnStartingAt, pcDirection, pCaseSensitive)

			but isLsit(pacBounds) and Q(pacBounds).IsPairOfStrings()
				return This.FindSubStringBetweenSDCSIB(pcSubStr, pacBounds[1], pacBounds[2], pnStartingAt, pcDirection, pCaseSensitive)

			else
				StzRaise("Incorrect param type! pacBounds must be a string or pair of strings.")

			ok

		#--
	
		def FindSubStringBetweenSDCSIBZ(pcSubStr, pcBound1, pcBound2, pnStartingAt, pcDirection, pCaseSensitive)
			return This.FindSubStringBetweenSDCSIB(pcSubStr, pcBound1, pcBound2, pnStartingAt, pcDirection, pCaseSensitive)

		def FindSubStringBoundedBySDCSIBZ(pcSubStr, pacBounds, pnStartingAt, pcDirection, pCaseSensitive)
			return This.FindSubStringBoundedBySDCSIB(pcSubStr, pacBounds, pnStartingAt, pcDirection, pCaseSensitive)

		#==

		def SubStringBetweenSDCSIB(pcSubStr, pcBound1, pcBound2, pnStartingAt, pcDirection, pCaseSensitive)
			return This.FindSubStringBetweenSDIB(pcSubStr, pcBound1, pcBound2, pnStartingAt, pcDirection)

		def SubStringBoundedBySDCSIB(pcSubStr, pacBounds, pnStartingAt, pcDirection, pCaseSensitive)
			return This.FindBoundedBySDCSIB(pcSubStr, pacBounds, pnStartingAt, pcDirection, pCaseSensitive)

		def SubStringBetweenSDCSIBZ(pcSubStr, pcBound1, pcBound2, pnStartingAt, pcDirection, pCaseSensitive)
			return This.FindSubStringBetweenSDCSIB(pcSubStr, pcBound1, pcBound2, pnStartingAt, pcDirection, pCaseSensitive)

		def SubStringBoundedBySDCSIBZ(pcSubStr, pacBounds, pnStartingAt, pcDirection, pCaseSensitive)
			return This.FindSubStringBoundedBySDCSIB(pcSubStr, pacBounds, pnStartingAt, pcDirection, pCaseSensitive)

		#>

	#-- WITHOUT CASESENSITIVITY

	def FindSubStringBetweenSDIB(pcSubStr, pcBound1, pcBound2, pnStartingAt, pcDirection)
		return This.FindSubStringBetweenSDCSIB(pcSubStr, pcBound1, pcBound2,pnStartingAt, pcDirection, :CaseSensitive = TRUE)

		#< @FunctionAlternativeForms

		def FindSubStringBoundedBySDIB(pcSubStr, pacBounds, pnStartingAt, pcDirection)
			return This.FindSubStringBoundedBySDIB(pcSubStr, pacBounds, pnStartingAt, pcDirection)

		#--
	
		def FindSubStringBetweenSDIBZ(pcSubStr, pcBound1, pcBound2, pnStartingAt, pcDirection)
			return This.FindSubStringBetweenSDIB(pcSubStr, pcBound1, pcBound2, pnStartingAt, pcDirection)

		def FindSubStringBoundedBySDIBZ(pcSubStr, pacBounds, pnStartingAt, pcDirection)
			return This.FindSubStringBoundedBySDIB(pcSubStr, pacBounds, pnStartingAt, pcDirection)

		#==

		def SubStringBetweenSDIB(pcSubStr, pcBound1, pcBound2, pnStartingAt, pcDirection)
			return This.FindSubStringBetweenSDIB(pcSubStr, pcBound1, pcBound2, pnStartingAt, pcDirection)

		def SubStringBoundedBySDIB(pcSubStr, pacBounds, pnStartingAt, pcDirection)
			return This.FindSubStringBoundedBySDIB(pcSubStr, pacBounds, pnStartingAt, pcDirection)

		def SubStringBetweenSDIBZ(pcSubStr, pcBound1, pcBound2, pnStartingAt, pcDirection)
			return This.FindSubStringBetweenSDIB(pcSubStr, pcBound1, pcBound2, pnStartingAt, pcDirection)

		def SubStringBoundedBySDIBZ(pcSubStr, pacBounds, pnStartingAt, pcDirection)
			return This.FindSubStringBoundedBySDIB(pcSubStr, pacBounds, pnStartingAt, pcDirection)

		#>

	   #--------------------------------------------------------------------------------------#
	  #  FINDING A SUBSTRING BOUNDED BY TWO OTHER SUBSTRINGSS STARTING AT A GIVEN POSITION,   #
	 #  GOING IN A GIVEN DIRECTION, INCLUDING BOUNDS, AND RETURNING POSITIONS AS SECTIONS   #
	#--------------------------------------------------------------------------------------#

	def FindSubStringBetweenSDCSIBZZ(pcSubStr, pcBound1, pcBound2, pnStartingAt, pcDirection, pCaseSensitive)
		/* ... */

		#< @FunctionAlternativeForms

		def FindSubStringBoundedBySDCSIBZZ(pcSubStr, pacBounds, pnStartingAt, pcDirection, pCaseSensitive)
			return This.FindSubStringBoundedBySDCSIBZZ(pcSubStr, pacBounds, pnStartingAt, pcDirection, pCaseSensitive)

		#--
	
		def FindSubStringBetweenAsSectionsSDCSIB(pcSubStr, pcBound1, pcBound2, pnStartingAt, pcDirection, pCaseSensitive)
			return This.FindSubStringBetweenSDCSIBZZ(pcSubStr, pcBound1, pcBound2, pnStartingAt, pcDirection, pCaseSensitive)

		def FindSubStringBoundedByAsSectionsSDCSIB(pcSubStr, pacBounds, pnStartingAt, pcDirection, pCaseSensitive)
			return This.FindSubStringBoundedBySDCSIBZZ(pcSubStr, pacBounds, pnStartingAt, pcDirection, pCaseSensitive)

		#==

		def SubStringBetweenSDCSIBZZ(pcSubStr, pcBound1, pcBound2, pnStartingAt, pcDirection, pCaseSensitive)
			return This.FindSubStringBetweenSDCSIBZZ(pcSubStr, pcBound1, pcBound2, pnStartingAt, pcDirection, pCaseSensitive)

		def SubStringBoundedBySDCSIBZZ(pcSubStr, pacBounds, pnStartingAt, pcDirection, pCaseSensitive)
			return This.FindSubStringBoundedBySDCSIBZZ(pcSubStr, pacBounds, pnStartingAt, pcDirection, pCaseSensitive)

		def SubStringBetweenAsSectionsSDCSIB(pcSubStr, pcBound1, pcBound2, pnStartingAt, pcDirection, pCaseSensitive)
			return This.FindSubStringBetweenSDCSIBZZ(pcSubStr, pcBound1, pcBound2, pnStartingAt, pcDirection, pCaseSensitive)

		def SubStringBoundedByAsSectionsSDCSIB(pcSubStr, pacBounds, pnStartingAt, pcDirection, pCaseSensitive)
			return This.FindSubStringBoundedBySDCSIBZZ(pcSubStr, pacBounds, pnStartingAt, pcDirection, pCaseSensitive)

		#>

	#-- WITHOUT CASESENSITIVITY

	def FindSubStringBetweenSDIBZZ(pcSubStr, pcBound1, pcBound2, pnStartingAt, pcDirection)
		return This.FindSubStringBetweenSDCSIBZZ(pcSubStr, pcBound1, pcBound2, pnStartingAt, pcDirection, :CaseSensitive = TRUE)

		#< @FunctionAlternativeForms

		def FindSubStringBoundedBySDIBZZ(pcSubStr, pacBounds, pnStartingAt, pcDirection)
			return This.FindSubStringBoundedBySDIBZZ(pcSubStr, pacBounds, pnStartingAt, pcDirection)

		#--
	
		def FindSubStringBetweenAsSectionsSDIB(pcSubStr, pcBound1, pcBound2, pnStartingAt, pcDirection)
			return This.FindSubStringBetweenSDIBZZ(pcSubStr, pcBound1, pcBound2, pnStartingAt, pcDirection)

		def FindSubStringBoundedByAsSectionsSDIB(pcSubStr, pacBounds, pnStartingAt, pcDirection)
			return This.FindSubStringBoundedBySDIBZZ(pcSubStr, pacBounds, pnStartingAt, pcDirection)

		#==

		def SubStringBetweenSDIBZZ(pcSubStr, pcBound1, pcBound2, pnStartingAt, pcDirection)
			return This.FindSubStringBetweenSDIBZZ(pcSubStr, pcBound1, pcBound2, pnStartingAt, pcDirection)

		def SubStringBoundedBySDIBZZ(pcSubStr, pacBounds, pnStartingAt, pcDirection)
			return This.FindSubStringBoundedBySDIBZZ(pcSubStr, pacBounds, pnStartingAt, pcDirection)

		def SubStringBetweenAsSectionsSDIB(pcSubStr, pcBound1, pcBound2, pnStartingAt, pcDirection)
			return This.FindSubStringBetweenSDIBZZ(pcSubStr, pcBound1, pcBound2, pnStartingAt, pcDirection)

		def SubStringBoundedByAsSectionsSDIB(pcSubStr, pacBounds, pnStartingAt, pcDirection)
			return This.FindSubStringBoundedBySDIBZZ(pcSubStr, pacBounds, pnStartingAt, pcDirection)

		#>

	  #===================================================================#
	 #  FINDING NTH OCCURRENCE OF A SUBSTRING BOUNDED BY TWO SUBSTRINGS  #
	#===================================================================#

	def FindNthSubStringBetweenCS(n, pcSubStr, pcBound1, pcBound2, pCaseSensitive)
		/* ... */

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
	
		def NthSubStringBetweenCSZ(n, pcSubStr, pcBound1, pcBound2, pCaseSensitive)
			return This.FindNthSubStringBetweenCS(n, pcSubStr, pcBound1, pcBound2, pCaseSensitive)

		def NthSubStringBoundedByCSZ(n, pcSubStr, pacBounds, pCaseSensitive)
			return This.FindNthSubStringBoundedByCS(n, pcSubStr, pacBounds, pCaseSensitive)

		#>

	#-- WITHOUT CASESENSITIVE

	def FindNthSubStringSubStringBetween(n, pcSubStr, pcBound1, pcBound2)
		return This.FindNthSubStringSubStringBetweenCS(n, pcSubStr, pcBound1, pcBound1, :CaseSensitive = TRUE)

		#< @FunctionAlternativeForms

		def FindNthSubStringBoundedBy(n, pcSubStr, pacBounds)
			return This.FindNthSubStringBoundedByCS(n, pcSubStr, pacBounds, :CaseSensitive = TRUE)

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
	
		def NthSubStringBetweenZ(n, pcSubStr, pcBound1, pcBound2)
			return This.FindNthSubStringBetween(n, pcSubStr, pcBound1, pcBound2)

		def NthSubStringBoundedByZ(n, pcSubStr, pacBounds)
			return This.FindNthSubStringBoundedBy(n, pcSubStr, pacBounds)

		#>

	   #------------------------------------------------------#
	  #  FINDING NTH OCCURRENCE OF A SUBSTRING BOUNDED BY    #
	 #  TWO OTHER SUBSTRINGS AND RETURNING THEM AS SECTIONS  #
	#-------------------------------------------------------#

	def FindNthSubStringBetweenCSZZ(n, pcSubStr, pcBound1, pcBound2, pCaseSensitive)
		/* ... */

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
	
		def FindNthSubStringBetweenAsSectionsCS(n, pcSubStr, pcBound1, pcBound2, pCaseSensitive)
			return This.FindNthSubStringBetweenCSZZ(n, pcSubStr, pcBound1, pcBound2, pCaseSensitive)

		def FindNthSubStringBoundedByAsSectionsCS(n, pcSubStr, pacBounds, pCaseSensitive)
			return This.FindNthSubStringBoundedByCSZZ(n, pcSubStr, pacBounds, pCaseSensitive)

		#==

		def NthSubStringBetweenCSZZ(n, pcSubStr, pcBound1, pcBound2, pCaseSensitive)
			return This.FindNthSubStringBetweenCSZZ(n, pcSubStr, pcBound1, pcBound2, pCaseSensitive)

		def NthSubStringBoundedByCSZZ(n, pcSubStr, pacBounds, pCaseSensitive)
			return This.FindNthSubStringBoundedByCSZZ(n, pcSubStr, pacBounds, pCaseSensitive)

		def NthSubStringBetweenAsSectionsCS(n, pcSubStr, pcBound1, pcBound2, pCaseSensitive)
			return This.FindNthSubStringBetweenCSZZ(n, pcSubStr, pcBound1, pcBound2, pCaseSensitive)

		def NthSubStringBoundedByAsSectionsCS(n, pcSubStr, pacBounds, pCaseSensitive)
			return This.FindNthSubStringBoundedByCSZZ(n, pcSubStr, pacBounds, pCaseSensitive)

		#>

	#-- WITHOUT CASESENSITIVITY

	def FindNthSubStringBetweenZZ(n, pcSubStr, pcBound1, pcBound2)
		return This.FindNthSubStringBetweenCSZZ(n, pcSubStr, pcBound1, pcBound2, :CaseSensitive = TRUE)

		#< @FunctionAlternativeForms

		def FindNthSubStringBoundedByZZ(n, pcSubStr, pacBounds)
			return This.FindNthSubStringBoundedByZZ(n, pcSubStr, pacBounds)

		#--
	
		def FindNthSubStringBetweenAsSections(n, pcSubStr, pcBound1, pcBound2)
			return This.FindNthSubStringBetweenZZ(n, pcSubStr, pcBound1, pcBound2)

		def FindNthSubStringBoundedByAsSections(n, pcSubStr, pacBounds)
			return This.FindNthSubStringBoundedByZZ(n, pcSubStr, pacBounds)

		#==

		def NthSubStringBetweenZZ(n, pcSubStr, pcBound1, pcBound2)
			return This.FindNthSubStringBetweenZZ(n, pcSubStr, pcBound1, pcBound2)

		def NthSubStringBoundedByZZ(n, pcSubStr, pacBounds)
			return This.FindNthSubStringBoundedByZZ(n, pcSubStr, pacBounds)

		def NthSubStringBetweenAsSections(n, pcSubStr, pcBound1, pcBound2)
			return This.FindNthSubStringBetweenZZ(n, pcSubStr, pcBound1, pcBound2)

		def NthSubStringBoundedByAsSections(n, pcSubStr, pacBounds)
			return This.FindNthSubStringBoundedByZZ(n, pcSubStr, pacBounds)

		#>

	  #------------------------------------------------------------------------------------------#
	 #  FINDING NTH OCCURRENCE OF A SUBSTRING BOUNDED BY TWO OTHER SUBSTRINGS INCLUDING BOUNDS  #
	#------------------------------------------------------------------------------------------#

	def FindNthSubStringBetweenCSIB(n, pcSubStr, pcBound1, pcBound2, pCaseSensitive)
		/* ... */

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
	
		def NthSubStringBetweenCSIBZ(n, pcSubStr, pcBound1, pcBound2, pCaseSensitive)
			return This.FindNthSubStringBetweenCSIB(n, pcSubStr, pcBound1, pcBound2, pCaseSensitive)

		def NthSubStringBoundedByCSIBZ(n, pcSubStr, pacBounds, pCaseSensitive)
			return This.FindNthSubStringBoundedByCSIB(n, pcSubStr, pacBounds, pCaseSensitive)

		#>

	#-- WITHOUT CASESENSITIVE

	def FindNthSubStringBetweenIB(n, pcSubStr, pcBound1, pcBound2)
		return This.FindNthSubStringBetweenCSIB(n, pcSubStr, pcBound1, pcBound2, :CaseSensitive = TRUE)

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
	
		def NthSubStringBetweenZIB(n, pcSubStr, pcBound1, pcBound2)
			return This.FindNthSubStringBetweenIB(n, pcSubStr, pcBound1, pcBound2)

		def NthSubStringBoundedByZIB(n, pcSubStr, pacBounds)
			return This.FindNthSubStringBoundedByIB(n, pcSubStr, pacBounds)

		#>

	   #-------------------------------------------------------------------------#
	  #  FINDING NTH OCCURRENCE OF A SUBSTRING BOUNDED BY TWO OTHER             #
	 #  SUBSTRINGS INCLUDING BOUNDS AND RETURNING THEIR POSITIONS AS SECTIONS  #
	#-------------------------------------------------------------------------#

	def FindNthSubStringBetweenCSIBZZ(n, pcSubStr, pcBound1, pcBound2, pCaseSensitive)
		/* ... */

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

		def NthSubStringBetweenCSIBZZ(n, pcSubStr, pcBound1, pcBound2, pCaseSensitive)
			return This.FindBetweenCSIBZZ(n, pcSubStr, pcBound1, pcBound2, pCaseSensitive)

		def NthSubStringBoundedByCSIBZZ(n, pcSubStr, pacBounds, pCaseSensitive)
			return This.FindNthSubStringBoundedByCSIBZZ(n, pcSubStr, pacBounds, pCaseSensitive)

		def NthSubStringBetweenAsSectionsCSIB(n, pcSubStr, pcBound1, pcBound2, pCaseSensitive)
			return This.FindNthSubStringBetweenCSIBZZ(n, pcSubStr, pcBound1, pcBound2, pCaseSensitive)

		def NthSubStringBoundedByAsSectionsCSIB(n, pcSubStr, pacBounds, pCaseSensitive)
			return This.FindNthSubStringBoundedByCSIBZZ(n, pcSubStr, pacBounds, pCaseSensitive)

		#>

	#-- WITHOUT CASESENSITIVITY

	def FindNthSubStringBetweenZZIB(n, pcSubStr, pcBound1, pcBound2)
		return This.FindNthSubStringBetweenCSIBZZ(n, pcSubStr, pcBound1, pcBound2, :CaseSensitive = TRUE)

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

		def NthSubStringBetweenIBZZ(n, pcSubStr, pcBound1, pcBound2)
			return This.FindNthSubStringBetweenIBZZ(n, pcSubStr, pcBound1, pcBound2)

		def NthSubStringBoundedByIBZZ(n, pcSubStr, pacBounds)
			return This.FindNthSubStringBoundedByIBZZ(n, pcSubStr, pacBounds)

		def NthSubStringBetweenAsSectionsIB(n, pcSubStr, pcBound1, pcBound2)
			return This.FindNthSubStringBetweenIBZZ(n, pcSubStr, pcBound1, pcBound2)

		def NthSubStringBoundedByAsSectionsIB(n, pcSubStr, pacBounds)
			return This.FindNthSubStringBoundedByIBZZ(n, pcSubStr, pacBounds)

		#>
		
	   #-----------------------------------------------------#
	  #  FINDING NTH OCCURRENCE OF A SUBSTRING BOUNDED BY   #
	 #  TWO OTHER SUBSTRINGS STARTING AT A GIVEN POSITION  #
	#-----------------------------------------------------#

	def FindNthSubStringBetweenSCS(n, pcSubStr, pcBound1, pcBound2, pnStartingAt, pCaseSensitive)
		/* ... */

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

		def NthSubStringBetweenSCSZ(n, pcSubStr, pcBound1, pcBound2, pnStartingAt, pCaseSensitive)
			return This.FindNthSubStringBetweenSCS(n, pcSubStr, pcBound1, pcBound2, pnStartingAt, pCaseSensitive)

		def NthSubStringBoundedBySCSZ(n, pcSubStr, pacBounds, pnStartingAt, pCaseSensitive)
			return This.FindNthSubStringBoundedBySCS(n, pcSubStr, pacBounds, pnStartingAt, pCaseSensitive)

		#>

	#-- WITHOUT CASESENSITIVITY

	def FindNthSubStringBetweenS(n, pcSubStr, pcBound1, pcBound2, pnStartingAt)
		return This.FindNthSubStringBetweenSCS(n, pcSubStr, pcBound1, pcBound2, pnStartingAt, :CaseSensitive = TRUE)

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

		def NthSubStringBetweenSZ(n, pcSubStr, pcBound1, pcBound2, pnStartingAt)
			return This.FindNthSubStringBetweenS(n, pcSubStr, pcBound1, pcBound2, pnStartingAt)

		def NthSubStringBoundedBySZ(n, pcSubStr, pacBounds, pnStartingAt)
			return This.FindNthSubStringBoundedByS(n, pcSubStr, pacBounds, pnStartingAt)

		#>

	   #-------------------------------------------------------------------------#
	  #  FINDING NTH OCCURRENCE OF A SUBSTRING BOUNDED BY TWO OTHER SUBSTRINGS  #
	 #  STARTING AT A GIVEN POSITION AND RETURNING POSITIONS AS SECTIONS       #
	#-------------------------------------------------------------------------#

	def FindNthSubStringBetweenSCSZZ(n, pcSubStr, pcBound1, pcBound2, pnStartingAt, pCaseSensitive)
		/* ... */

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

		#==

		def NthSubStringBetweenSCSZZ(n, pcSubStr, pcBound1, pcBound2, pnStartingAt, pCaseSensitive)
			return This.FindNthSubStringBetweenSCSZZ(n, pcSubStr, pcBound1, pcBound2, pnStartingAt, pCaseSensitive)

		def NthSubStringBoundedBySCSZZ(n, pcSubStr, pacBounds, pnStartingAt, pCaseSensitive)
			return This.FindNthSubStringBoundedBySCSZZ(n, pcSubStr, pacBounds, pnStartingAt, pCaseSensitive)

		def NthSubStringBetweenAsSectionsSCS(n, pcSubStr, pcBound1, pcBound2, pnStartingAt, pCaseSensitive)
			return This.FindNthSubStringBetweenSCSZZ(n, pcSubStr, pcBound1, pcBound2, pnStartingAt, pCaseSensitive)

		def NthSubStringBoundedByAsSectionsSCS(n, pcSubStr, pacBounds, pnStartingAt, pCaseSensitive)
			return This.FindNthSubStringBoundedBySCSZZ(n, pcSubStr, pacBounds, pnStartingAt, pCaseSensitive)

		#>

	#--

	def FindNthSubStringBetweenSZZ(n, pcSubStr, pcBound1, pcBound2, pnStartingAt)
		return This.FindNthSubStringBetweenSCSZZ(n, pcSubStr, pcBound1, pcBound2, pnStartingAt, :CaseSensitive = TRUE)

		#< @FunctionAlternativeForms

		def FindNthSubStringBoundedBySZZ(n, pcSubStr, pacBounds, pnStartingAt)
			return This.FindNthSubStringBoundedBySZZ(n, pcSubStr, pacBounds, pnStartingAt)

		#--
	
		def FindNthSubStringBetweenAsSectionsS(n, pcSubStr, pcBound1, pcBound2, pnStartingAt)
			return This.FindNthSubStringBetweenSZZ(n, pcSubStr, pcBound1, pcBound2, pnStartingAt)

		def FindNthSubStringBoundedByAsSectionsS(n, pcSubStr, pacBounds, pnStartingAt)
			return This.FindNthSubStringBoundedBySZZ(n, pcSubStr, pacBounds, pnStartingAt)

		#==

		def NthSubStringBetweenSZZ(n, pcSubStr, pcBound1, pcBound2, pnStartingAt)
			return This.FindNthSubStringBetweenSZZ(n, pcSubStr, pcBound1, pcBound2, pnStartingAt)

		def NthSubStringBoundedBySZZ(n, pcSubStr, pacBounds, pnStartingAt)
			return This.FindNthSubStringBoundedBySZZ(n, pcSubStr, pacBounds, pnStartingAt)

		def NthSubStringBetweenAsSectionsS(n, pcSubStr, pcBound1, pcBound2, pnStartingAt)
			return This.FindNthSubStringBetweenSZZ(n, pcSubStr, pcBound1, pcBound2, pnStartingAt)

		def NthSubStringBoundedByAsSectionsS(n, pcSubStr, pacBounds, pnStartingAt)
			return This.FindNthSubStringBoundedBySZZ(n, pcSubStr, pacBounds, pnStartingAt)

		#>

	   #---------------------------------------------------------------#
	  #  FINDING NTH OCCURRENCE OF A SUBSTRING BOUNDED BY TWO OTHER   #
	 #  SUBSTRINGSSTARTING AT A GIVEN POSITION AND INCLUDING BOUNDS  #
	#---------------------------------------------------------------#

	def FindNthSubStringBetweenSCSIB(n, pcSubStr, pcBound1, pcBound2, pnStartingAt, pCaseSensitive)
		/* ... */

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

		def NthSubStringBetweenSCSIBZ(n, pcSubStr, pcBound1, pcBound2, pnStartingAt, pCaseSensitive)
			return This.FindNthSubStringBetweenSCSIB(n, pcSubStr, pcBound1, pcBound2, pnStartingAt, pCaseSensitive)

		def NthSubStringBoundedBySCSIBZ(n, pcSubStr, pacBounds, pnStartingAt, pCaseSensitive)
			return This.FindNthSubStringBoundedBySCSIB(n, pcSubStr, pacBounds, pnStartingAt, pCaseSensitive)

		#>

	#-- WITHOUT CASESENSITIVITY

	def FindNthSubStringBetweenSIB(n, pcSubStr, pcBound1, pcBound2, pnStartingAt)
		return This.FindNthSubStringBetweenSCSIB(n, pcSubStr, pcBound1, pcBound2, pnStartingAt, :CaseSensitive = TRUE)

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

		def NthSubStringBetweenSIBZ(n, pcSubStr, pcBound1, pcBound2, pnStartingAt)
			return This.FindNthSubStringBetweenSIB(n, pcSubStr, pcBound1, pcBound2, pnStartingAt)

		def NthSubStringBoundedBySIBZ(n, pcSubStr, pacBounds, pnStartingAt)
			return This.FindNthSubStringBoundedBySIB(n, pcSubStr, pacBounds, pnStartingAt)

		#>

	   #-----------------------------------------------------------------------------------#
	  #  FINDING NTH OCCURRENCE OF A SUBSTRING BOUNDED BY TWO OTHER SUBSTRINGS STARTING   #
	 #  AT A GIVEN POSITION, INCLUDING BOUNDS, AND RETURNING THE POSITIONS AS SECTIONS   #
	#-----------------------------------------------------------------------------------#

	def FindNthSubStringBetweenSCSIBZZ(n, pcSubStr, pcBound1, pcBound2, pnStartingAt, pCaseSensitive)
		/* ... */

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

		def NthSubStringBetweenSCSIBZZ(n, pcSubStr, pcBound1, pcBound2, pnStartingAt, pCaseSensitive)
			return This.FindNthSubStringBetweenSCSIBZZ(n, pcSubStr, pcBound1, pcBound2, pnStartingAt, pCaseSensitive)

		def NthSubStringBoundedBySCSIBZZ(n, pcSubStr, pacBounds, pnStartingAt, pCaseSensitive)
			return This.FindNthSubStringBoundedBySCSIBZZ(n, pcSubStr, pacBounds, pnStartingAt, pCaseSensitive)

		def NthSubStringBetweenAsSectionsSCSIB(n, pcSubStr, pcBound1, pcBound2, pnStartingAt, pCaseSensitive)
			return This.FindNthSubStringBetweenSIBCSZZ(n, pcSubStr, pcBound1, pcBound2, pnStartingAt, pCaseSensitive)

		def NthSubStringBoundedByAsSectionsSCSIB(n, pcSubStr, pacBounds, pnStartingAt, pCaseSensitive)
			return This.FindNthSubStringBoundedBySCSIBZZ(n, pcSubStr, pacBounds, pnStartingAt, pCaseSensitive)

		#>

	#-- WITHOUT CASESENSITIVITY

	def FindNthSubStringBetweenSIBZZ(n, pcSubStr, pcBound1, pcBound2, pnStartingAt)
		return This.FindNthSubStringBetweenSIBCSZZ(n, pcSubStr, pcBound1, pcBound2, pnStartingAt, :CaseSensitive = TRUE)

		#< @FunctionAlternativeForms

		def FindNthSubStringBoundedBySIBZZ(n, pcSubStr, pacBounds, pnStartingAt)
			return This.FindNthSubStringBoundedBySIBZZ(n, pcSubStr, pacBounds, pnStartingAt)

		#--
	
		def FindNthSubStringBetweenAsSectionsSIB(n, pcSubStr, pcBound1, pcBound2, pnStartingAt)
			return This.FindNthSubStringBetweenSIBZZ(n, pcSubStr, pcBound1, pcBound2, pnStartingAt)

		def FindNthSubStringBoundedByAsSectionsSIB(n, pcSubStr, pacBounds, pnStartingAt)
			return This.FindNthSubStringBoundedBySIBZZ(n, pcSubStr, pacBounds, pnStartingAt)

		#==

		def NthSubStringBetweenSIBZZ(n, pcSubStr, pcBound1, pcBound2, pnStartingAt)
			return This.FindNthSubStringBetweenSIBZZ(n, pcSubStr, pcBound1, pcBound2, pnStartingAt)

		def NthSubStringBoundedBySIBZZ(n, pcSubStr, pacBounds, pnStartingAt)
			return This.FindNthSubStringBoundedBySIBZZ(n, pcSubStr, pacBounds, pnStartingAt)

		def NthSubStringBetweenAsSectionsSIB(n, pcSubStr, pcBound1, pcBound2, pnStartingAt)
			return This.FindNthSubStringBetweenSIBZZ(n, pcSubStr, pcBound1, pcBound2, pnStartingAt)

		def NthSubStringBoundedByAsSectionsSIB(n, pcSubStr, pacBounds, pnStartingAt)
			return This.FindNthSubStringBoundedBySIBZZ(n, pcSubStr, pacBounds, pnStartingAt)

		#>

	   #----------------------------------------------------#
	  #  FINDING NTH OCCURRENCE OF A SUBSTRING BOUNDED BY  #
	 #  TWO OTHER SUBSTRINGS GOING IN A GIVEN DIRECTION   #
	#----------------------------------------------------#

	def FindNthSubStringBetweenDCS(n, pcSubStr, pcBound1, pcBound2, pcDirection, pCaseSensitive)
		/* ... */

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

		def NthSubStringBetweenDCSZ(n, pcSubStr, pcBound1, pcBound2, pcDirection, pCaseSensitive)
			return This.FindNthSubStringBetweenDCS(n, pcSubStr, pcBound1, pcBound2, pcDirection, pCaseSensitive)

		def NthSubStringBoundedByDCSZ(n, pcSubStr, pacBounds, pcDirection, pCaseSensitive)
			return This.FindNthSubStringBoundedByDCS(n, pcSubStr, pacBounds, pcDirection, pCaseSensitive)

		#>

	#-- WITHOUT CASESENSITIVITY

	def FindNthSubStringBetweenD(n, pcSubStr, pcBound1, pcBound2, pcDirection)
		return This.FindNthSubStringBetweenDCS(n, pcSubStr, pcBound1, pcBound2, pcDirection, :CaseSensitive = TRUE)

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

		def NthSubStringBetweenDZ(n, pcSubStr, pcBound1, pcBound2, pcDirection)
			return This.FindNthSubStringBetweenD(n, pcSubStr, pcBound1, pcBound2, pcDirection)

		def NthSubStringBoundedByDZ(n, pcSubStr, pacBounds, pcDirection)
			return This.FindNthSubStringBoundedByD(n, pcSubStr, pacBounds, pcDirection)

		#>

	   #-------------------------------------------------------------------------#
	  #  FINDING NTH OCCURRENCE OF A SUBSTRING BOUNDED BY TWO OTHER SUBSTRINGS  #
	 #  GOING INA GIVEN DIRECTION AND RETURNING POSITIONS AS SECTIONS          #
	#-------------------------------------------------------------------------#

	def FindNthSubStringBetweenDCSZZ(n, pcSubStr, pcBound1, pcBound2, pcDirection, pCaseSensitive)
		/* ... */

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

		def NthSubStringBetweenDCSZZ(n, pcSubStr, pcBound1, pcBound2, pcDirection, pCaseSensitive)
			return This.FindNthSubStringBetweenDCSZZ(n, pcSubStr, pcBound1, pcBound2, pcDirection, pCaseSensitive)

		def NthSubStringBoundedByDCSZZ(n, pcSubStr, pacBounds, pcDirection, pCaseSensitive)
			return This.FindNthSubStringBoundedByDCSZZ(n, pcSubStr, pacBounds, pcDirection, pCaseSensitive)

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

		def NthSubStringBetweenDZZ(n, pcSubStr, pcBound1, pcBound2, pcDirection)
			return This.FindNthSubStringBetweenDZZ(n, pcSubStr, pcBound1, pcBound2, pcDirection)

		def NthSubStringBoundedByDZZ(n, pcSubStr, pacBounds, pcDirection)
			return This.FindNthSubStringBoundedByDZZ(n, pcSubStr, pacBounds, pcDirection)

		def NthSubStringBetweenAsSectionsD(n, pcSubStr, pcBound1, pcBound2, pcDirection)
			return This.FindNthSubStringBetweenDZZ(n, pcSubStr, pcBound1, pcBound2, pcDirection)

		def NthSubStringBoundedByAsSectionsD(n, pcSubStr, pacBounds, pcDirection)
			return This.FindNthSubStringBoundedByDZZ(n, pcSubStr, pacBounds, pcDirection)

		#>

	   #--------------------------------------------------------------#
	  #  FINDING NTH OCCURRENCE OF A SUBSTRING BOUNDED BY TWO OTHER  #
	 #  SUBSTRINGS GOING IN A GIVEN DIRECTION AND INCLUDING BOUNDS  #
	#--------------------------------------------------------------#

	def FindNthSubStringBetweenDCSIB(n, pcSubStr, pcBound1, pcBound2, pcDirection, pCaseSensitive)
		/* ... */

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

		def NthSubStringBetweenDCSIBZ(n, pcSubStr, pcBound1, pcBound2, pcDirection, pCaseSensitive)
			return This.FindNthSubStringBetweenDCSIB(n, pcSubStr, pcBound1, pcBound2, pcDirection, pCaseSensitive)

		def NthSubStringBoundedByDCSIBZ(n, pcSubStr, pacBounds, pcDirection, pCaseSensitive)
			return This.FindNthSubStringBoundedByDCSIB(n, pcSubStr, pacBounds, pcDirection, pCaseSensitive)

		#>

	#-- WITHOUT CASESENSITIVITY

	def FindNthSubStringBetweenDIB(n, pcSubStr, pcBound1, pcBound2, pcDirection)
		return This.FindNthSubStringBetweenDCSIB(n, pcSubStr, pcBound1, pcBound2, pcDirection, :CaseSensitive = TRUE)

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

		def NthSubStringBetweenDIBZ(n, pcSubStr, pcBound1, pcBound2, pcDirection)
			return This.FindNthSubStringBetweenDIB(n, pcSubStr, pcBound1, pcBound2, pcDirection)

		def NthSubStringBoundedByDIBZ(n, pcSubStr, pacBounds, pcDirection)
			return This.FindNthSubStringBoundedByDIB(n, pcSubStr, pacBounds, pcDirection)

		#>

	   #-------------------------------------------------------------------------------#
	  #  FINDING NTH OCCURRENCE OF A SUBSTRING BOUNDED BY TWO OTHER SUBSTRINGS GOING  #
	 #  IN A GIVENDIRECTION, INCLUDING BOUNDS, AND RETURNING POSITIONS AS SECTIONS   # 
	#-------------------------------------------------------------------------------#

	def FindNthSubStringBetweenDCSIBZZ(n, pcSubStr, pcBound1, pcBound2, pcDirection, pCaseSensitive)
		/* ... */

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

		def NthSubStringBetweenDCSIBZZ(n, pcSubStr, pcBound1, pcBound2, pcDirection, pCaseSensitive)
			return This.FindNthSubStringBetweenDCSIBZZ(n, pcSubStr, pcBound1, pcBound2, pcDirection, pCaseSensitive)

		def NthSubStringBoundedByDCSIBZZ(n, pcSubStr, pacBounds, pcDirection, pCaseSensitive)
			return This.FindNthSubStringBoundedByDCSIBZZ(n, pcSubStr, pacBounds, pcDirection, pCaseSensitive)

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

		def NthSubStringBetweenDIBZZ(n, pcSubStr, pcBound1, pcBound2, pcDirection)
			return This.FindNthSubStringBetweenDIBZZ(n, pcSubStr, pcBound1, pcBound2, pcDirection)

		def NthSubStringBoundedByDIBZZ(n, pcSubStr, pacBounds, pcDirection)
			return This.FindNthSubStringBoundedByDIBZZ(n, pcSubStr, pacBounds, pcDirection)

		def NthSubStringBetweenAsSectionsDIB(n, pcSubStr, pcBound1, pcBound2, pcDirection)
			return This.FindNthSubStringBetweenDIBZZ(n, pcSubStr, pcBound1, pcBound2, pcDirection)

		def NthSubStringBoundedByAsSectionsDIB(n, pcSubStr, pacBounds, pcDirection)
			return This.FindNthSubStringBoundedByDIBZZ(n, pcSubStr, pacBounds, pcDirection)

		#>

	   #-------------------------------------------------------------------------#
	  #  FINDING NTH OCCURRENCE OF A SUBSTRING BOUNDED BY TWO OTHER SUBSTRINGS  #
	 #  STARTING AT A GIVEN POSITION AND GOING IN A GIVEN DIRECTION            #
	#-------------------------------------------------------------------------#

	def FindNthSubStringBetweenSDCS(n, pcSubStr, pcBound1, pcBound2, pnStartingAt, pcDirection, pCaseSensitive)
		/* ... */

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

		def NthSubStringBetweenSDCSZ(n, pcSubStr, pcBound1, pcBound2, pnStartingAt, pcDirection, pCaseSensitive)
			return This.FindNthSubStringBetweenSDCS(n, pcSubStr, pcBound1, pcBound2, pnStartingAt, pcDirection, pCaseSensitive)

		def NthSubStringBoundedBySDCSZ(n, pcSubStr, pacBounds, pnStartingAt, pcDirection, pCaseSensitive)
			return This.FindNthSubStringBoundedBySDCS(n, pcSubStr, pacBounds, pnStartingAt, pcDirection, pCaseSensitive)

		#>

	#-- WITHOUT CASESENSITIVITY

	def FindNthSubStringBetweenSD(n, pcSubStr, pcBound1, pcBound2, pnStartingAt, pcDirection)
		return This.FindNthSubStringBetweenSDCS(n, pcSubStr, pcBound1, pcBound2,pnStartingAt, pcDirection, :CaseSensitive = TRUE)

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

		def NthSubStringBetweenSDZ(n, pcSubStr, pcBound1, pcBound2, pnStartingAt, pcDirection)
			return This.FindNthSubStringBetweenSD(n, pcSubStr, pcBound1, pcBound2, pnStartingAt, pcDirection)

		def NthSubStringBoundedBySDZ(n, pcSubStr, pacBounds, pnStartingAt, pcDirection)
			return This.FindNthSubStringBoundedBySD(n, pcSubStr, pacBounds, pnStartingAt, pcDirection)

		#>

	   #----------------------------------------------------------------------------------------#
	  #  FINDING NTH OCCURRENCE OF A SUBSTRING BOUNDED BY TWO OTHER SUBSTRINGSS STARTING       #
	 #  AT A GIVEN POSITION, GOING IN A GIVEN DIRECTION, AND RETURNING POSITIONS AS SECTIONS  #
	#----------------------------------------------------------------------------------------#

	def FindNthSubStringBetweenSDCSZZ(n, pcSubStr, pcBound1, pcBound2, pnStartingAt, pcDirection, pCaseSensitive)
		/* ... */

		#< @FunctionAlternativeForms

		def FindNthSubStringBoundedBySDCSZZ(n, pcSubStr, pacBounds, pnStartingAt, pcDirection, pCaseSensitive)
			return This.FindBoundedBySDCSZZ(n, pcSubStr, pacBounds, pnStartingAt, pcDirection, pCaseSensitive)

		#--
	
		def FindNthSubStringBetweenAsSectionsSDCS(n, pcSubStr, pcBound1, pcBound2, pnStartingAt, pcDirection, pCaseSensitive)
			return This.FindNthSubStringBetweenSDCSZZ(n, pcSubStr, pcBound1, pcBound2, pnStartingAt, pcDirection, pCaseSensitive)

		def FindNthSubStringBoundedByAsSectionsSDCS(n, pcSubStr, pacBounds, pnStartingAt, pcDirection, pCaseSensitive)
			return This.FindNthSubStringBoundedBySDCSZZ(n, pcSubStr, pacBounds, pnStartingAt, pcDirection, pCaseSensitive)

		#==

		def NthSubStringBoundedBySDCSZZ(n, pcSubStr, pacBounds, pnStartingAt, pcDirection, pCaseSensitive)
			return This.FindNthSubStringBoundedBySDCSZZ(n, pcSubStr, pacBounds, pnStartingAt, pcDirection, pCaseSensitive)

		def NthSubStringBoundedByAsSectionsSDCS(n, pcSubStr, pacBounds, pnStartingAt, pcDirection, pCaseSensitive)
			return This.FindNthSubStringBoundedBySDCSZZ(n, pcSubStr, pacBounds, pnStartingAt, pcDirection, pCaseSensitive)

		#>

	#-- WITHOUT CASESENSITIVITY

	def FindNthSubStringBetweenSDZZ(n, pcSubStr, pcBound1, pcBound2, pnStartingAt, pcDirection)
		return This.FindNthSubStringBetweenSDCSZZ(n, pcSubStr, pcBound1, pcBound2, pnStartingAt, pcDirection, :CaseSensitive = TRUE)

		#< @FunctionAlternativeForms

		def FindNthSubStringBoundedBySDZZ(n, pcSubStr, pacBounds, pnStartingAt, pcDirection)
			return This.FindBoundedBySDZZ(n, pcSubStr, pacBounds, pnStartingAt, pcDirection)

		#--
	
		def FindNthSubStringBetweenAsSectionsSD(n, pcSubStr, pcBound1, pcBound2, pnStartingAt, pcDirection)
			return This.FindNthSubStringBetweenSDZZ(n, pcSubStr, pcBound1, pcBound2, pnStartingAt, pcDirection)

		def FindNthSubStringBoundedByAsSectionsSD(n, pcSubStr, pacBounds, pnStartingAt, pcDirection)
			return This.FindNthSubStringBoundedBySDZZ(n, pcSubStr, pacBounds, pnStartingAt, pcDirection)

		#==

		def NthSubStringBetweenSDZZ(n, pcSubStr, pcBound1, pcBound2, pnStartingAt, pcDirection)
			return This.FindNthSubStringBetweenSDZZ(n, pcSubStr, pcBound1, pcBound2, pnStartingAt, pcDirection)

		def NthSubStringBoundedBySDZZ(n, pcSubStr, pacBounds, pnStartingAt, pcDirection)
			return This.FindNthSubStringBoundedBySDZZ(n, pcSubStr, pacBounds, pnStartingAt, pcDirection)

		def NthSubStringBetweenAsSectionsSD(n, pcSubStr, pcBound1, pcBound2, pnStartingAt, pcDirection)
			return This.FindNthSubStringBetweenSDZZ(n, pcSubStr, pcBound1, pcBound2, pnStartingAt, pcDirection)

		def NthSubStringBoundedByAsSectionsSD(n, pcSubStr, pacBounds, pnStartingAt, pcDirection)
			return This.FindNthSubStringBoundedBySDZZ(n, pcSubStr, pacBounds, pnStartingAt, pcDirection)

		#>

	   #-----------------------------------------------------------------------------------#
	  #  FINDING NTH OCCURRENCE OF A SUBSTRING BOUNDED BY TWO OTHER SUBSTRINGSS STARTING  #
	 #  AT A GIVEN POSITION, GOING IN A GIVEN DIRECTION, AND INCLUDING BOUNDS            #
	#-----------------------------------------------------------------------------------#

	def FindNthSubStringBetweenSDCSIB(n, pcSubStr, pcBound1, pcBound2, pnStartingAt, pcDirection, pCaseSensitive)
		/* ... */

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

		def NthSubStringBetweenSDCSIBZ(n, pcSubStr, pcBound1, pcBound2, pnStartingAt, pcDirection, pCaseSensitive)
			return This.FindNthSubStringBetweenSDCSIB(n, pcSubStr, pcBound1, pcBound2, pnStartingAt, pcDirection, pCaseSensitive)

		def NthSubStringBoundedBySDCSIBZ(n, pcSubStr, pacBounds, pnStartingAt, pcDirection, pCaseSensitive)
			return This.FindNthSubStringBoundedBySDCSIB(n, pcSubStr, pacBounds, pnStartingAt, pcDirection, pCaseSensitive)

		#>

	#-- WITHOUT CASESENSITIVITY

	def FindNthSubStringBetweenSDIB(n, pcSubStr, pcBound1, pcBound2, pnStartingAt, pcDirection)
		return This.FindNthSubStringBetweenSDCSIB(n, pcSubStr, pcBound1, pcBound2,pnStartingAt, pcDirection, :CaseSensitive = TRUE)

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

		def NthSubStringBetweenSDIBZ(n, pcSubStr, pcBound1, pcBound2, pnStartingAt, pcDirection)
			return This.FindNthSubStringBetweenSDIB(n, pcSubStr, pcBound1, pcBound2, pnStartingAt, pcDirection)

		def NthSubStringBoundedBySDIBZ(n, pcSubStr, pacBounds, pnStartingAt, pcDirection)
			return This.FindNthSubStringBoundedBySDIB(n, pcSubStr, pacBounds, pnStartingAt, pcDirection)

		#>

	   #-----------------------------------------------------------------------------------------------#
	  #  FINDING NTH OCCURRENCE OF A SUBSTRING BOUNDED BY TWO OTHER SUBSTRINGSS STARTING AT A GIVEN   #
	 #  POSITION, GOING IN A GIVEN DIRECTION, INCLUDING BOUNDS, AND RETURNING POSITIONS AS SECTIONS  #
	#-----------------------------------------------------------------------------------------------#

	def FindNthSubStringBetweenSDCSIBZZ(n, pcSubStr, pcBound1, pcBound2, pnStartingAt, pcDirection, pCaseSensitive)
		/* ... */

		#< @FunctionAlternativeForms

		def FindNthSubStringBoundedBySDCSIBZZ(n, pcSubStr, pacBounds, pnStartingAt, pcDirection, pCaseSensitive)
			return This.FindNthSubStringBoundedBySDCSIBZZ(n, pcSubStr, pacBounds, pnStartingAt, pcDirection, pCaseSensitive)

		#--
	
		def FindNthSubStringBetweenAsSectionsSDCSIB(n, pcSubStr, pcBound1, pcBound2, pnStartingAt, pcDirection, pCaseSensitive)
			return This.FindNthSubStringBetweenSDCSIBZZ(n, pcSubStr, pcBound1, pcBound2, pnStartingAt, pcDirection, pCaseSensitive)

		def FindNthSubStringBoundedByAsSectionsSDCSIB(n, pcSubStr, pacBounds, pnStartingAt, pcDirection, pCaseSensitive)
			return This.FindNthSubStringBoundedBySDCSIBZZ(n, pcSubStr, pacBounds, pnStartingAt, pcDirection, pCaseSensitive)

		#==

		def NthSubStringBetweenSDCSIBZZ(n, pcSubStr, pcBound1, pcBound2, pnStartingAt, pcDirection, pCaseSensitive)
			return This.FindNthSubStringBetweenSDCSIBZZ(n, pcSubStr, pcBound1, pcBound2, pnStartingAt, pcDirection, pCaseSensitive)

		def NthSubStringBoundedBySDCSIBZZ(n, pcSubStr, pacBounds, pnStartingAt, pcDirection, pCaseSensitive)
			return This.FindNthSubStringBoundedBySDCSIBZZ(n, pcSubStr, pacBounds, pnStartingAt, pcDirection, pCaseSensitive)

		def NthSubStringBetweenAsSectionsSDCSIB(n, pcSubStr, pcBound1, pcBound2, pnStartingAt, pcDirection, pCaseSensitive)
			return This.FindNthSubStringBetweenSDCSIBZZ(n, pcSubStr, pcBound1, pcBound2, pnStartingAt, pcDirection, pCaseSensitive)

		def NthSubStringBoundedByAsSectionsSDCSIB(n, pcSubStr, pacBounds, pnStartingAt, pcDirection, pCaseSensitive)
			return This.FindNthSubStringBoundedBySDCSIBZZ(n, pcSubStr, pacBounds, pnStartingAt, pcDirection, pCaseSensitive)

		#>

	#-- WITHOUT CASESENSITIVITY

	def FindNthSubStringBetweenSDIBZZ(n, pcSubStr, pcBound1, pcBound2, pnStartingAt, pcDirection)
		return This.FindNthSubStringBetweenSDCSIBZZ(n, pcSubStr, pcBound1, pcBound2, pnStartingAt, pcDirection, :CaseSensitive = TRUE)

		#< @FunctionAlternativeForms

		def FindNthSubStringBoundedBySDIBZZ(n, pcSubStr, pacBounds, pnStartingAt, pcDirection)
			return This.FindNthSubStringBoundedBySDIBZZ(n, pcSubStr, pacBounds, pnStartingAt, pcDirection)

		#--
	
		def FindNthSubStringBetweenAsSectionsSDIB(n, pcSubStr, pcBound1, pcBound2, pnStartingAt, pcDirection)
			return This.FindNthSubStringBetweenSDIBZZ(n, pcSubStr, pcBound1, pcBound2, pnStartingAt, pcDirection)

		def FindNthSubStringBoundedByAsSectionsSDIB(n, pcSubStr, pacBounds, pnStartingAt, pcDirection)
			return This.FindNthSubStringBoundedBySDIBZZ(n, pcSubStr, pacBounds, pnStartingAt, pcDirection)

		#==

		def NthSubStringBetweenSDIBZZ(n, pcSubStr, pcBound1, pcBound2, pnStartingAt, pcDirection)
			return This.FindNthSubStringBetweenSDIBZZ(n, pcSubStr, pcBound1, pcBound2, pnStartingAt, pcDirection)

		def NthSubStringBoundedBySDIBZZ(n, pcSubStr, pacBounds, pnStartingAt, pcDirection)
			return This.FindNthSubStringBoundedBySDIBZZ(n, pcSubStr, pacBounds, pnStartingAt, pcDirection)

		def NthSubStringBetweenAsSectionsSDIB(n, pcSubStr, pcBound1, pcBound2, pnStartingAt, pcDirection)
			return This.FindNthSubStringBetweenSDIBZZ(n, pcSubStr, pcBound1, pcBound2, pnStartingAt, pcDirection)

		def NthSubStringBoundedByAsSectionsSDIB(n, pcSubStr, pacBounds, pnStartingAt, pcDirection)
			return This.FindNthSubStringBoundedBySDIBZZ(n, pcSubStr, pacBounds, pnStartingAt, pcDirection)

		#>

	  #=====================================================================#
	 #  FINDING FIRST OCCURRENCE OF A SUBSTRING BOUNDED BY TWO SUBSTRINGS  #
	#=====================================================================#


	def FindFirstSubStringBetweenCS(pcSubStr, pcBound1, pcBound2, pCaseSensitive)
		/* ... */

		#< @FunctionAlternativeForms

		def FindFirstSubStringBoundedByCS(pcSubStr, pacBounds, pCaseSensitive)
			if isString(pacBounds)
				return This.FindFirstSubStringBetweenCS(pcSubStr, pacBounds, pacBounds, pCaseSensitive)

			but isList(pacBounds) and Q(pacBounds).IsPairOfStrings()
				return TThis.FindFirstSubStringBetweenCS(pcSubStr, pacBounds[1], pacBounds[2], pCaseSensitive)

			else
				StzRaise("Incorrect param type! pacBounds must be a string or pair of strings.")
			ok

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
	
		def FirstSubStringBetweenCSZ(pcSubStr, pcBound1, pcBound2, pCaseSensitive)
			return This.FindFirstSubStringBetweenCS(pcSubStr, pcBound1, pcBound2, pCaseSensitive)

		def FirstSubStringBoundedByCSZ(pcSubStr, pacBounds, pCaseSensitive)
			return This.FindFirstSubStringBoundedByCS(pcSubStr, pacBounds, pCaseSensitive)

		#>

	#-- WITHOUT CASESENSITIVE

	def FindFirstSubStringSubStringBetween(pcSubStr, pcBound1, pcBound2)
		return This.FindFirstSubStringSubStringBetweenCS(pcSubStr, pcBound1, pcBound1, :CaseSensitive = TRUE)

		#< @FunctionAlternativeForms

		def FindFirstSubStringBoundedBy(pcSubStr, pacBounds)
			return This.FindFirstSubStringBoundedByCS(pcSubStr, pacBounds, :CaseSensitive = TRUE)

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
	
		def FirstSubStringBetweenZ(pcSubStr, pcBound1, pcBound2)
			return This.FindFirstSubStringBetween(pcSubStr, pcBound1, pcBound2)

		def FirstSubStringBoundedByZ(pcSubStr, pacBounds)
			return This.FindFirstSubStringBoundedBy(pcSubStr, pacBounds)

		#>

	   #-------------------------------------------------------#
	  #  FINDING FIRST OCCURRENCE OF A SUBSTRING BOUNDED BY   #
	 #  TWO OTHER SUBSTRINGS AND RETURNING THEM AS SECTIONS  #
	#-------------------------------------------------------#

	def FindFirstSubStringBetweenCSZZ(pcSubStr, pcBound1, pcBound2, pCaseSensitive)
		/* ... */

		#< @FunctionAlternativeForms

		def FindFirstSubStringBoundedByCSZZ(pcSubStr, pacBounds, pCaseSensitive)
			if isString(pacBounds)
				return This.FindFirstSubStringBetweenCSZZ(pcSubStr, pcBounds, pcBounds, pCaseSensitive)

			but isList(pacBounds) and Q(pacBounds).IsPairOfStrings()
				return This.FindFirstSubStringBetweenCSZZ(pcSubStr, pcBounds[1], pcBounds[2], pCaseSensitive)

			else
				StzRaise("Incorrect param type! pacBounds must be a string or pair of strings.")
			ok

		#--
	
		def FindFirstSubStringBetweenAsSectionsCS(pcSubStr, pcBound1, pcBound2, pCaseSensitive)
			return This.FindFirstSubStringBetweenCSZZ(pcSubStr, pcBound1, pcBound2, pCaseSensitive)

		def FindFirstSubStringBoundedByAsSectionsCS(pcSubStr, pacBounds, pCaseSensitive)
			return This.FindFirstSubStringBoundedByCSZZ(pcSubStr, pacBounds, pCaseSensitive)

		#==

		def FirstSubStringBetweenCSZZ(pcSubStr, pcBound1, pcBound2, pCaseSensitive)
			return This.FindFirstSubStringBetweenCSZZ(pcSubStr, pcBound1, pcBound2, pCaseSensitive)

		def FirstSubStringBoundedByCSZZ(pcSubStr, pacBounds, pCaseSensitive)
			return This.FindFirstSubStringBoundedByCSZZ(pcSubStr, pacBounds, pCaseSensitive)

		def FirstSubStringBetweenAsSectionsCS(pcSubStr, pcBound1, pcBound2, pCaseSensitive)
			return This.FindFirstSubStringBetweenCSZZ(pcSubStr, pcBound1, pcBound2, pCaseSensitive)

		def FirstSubStringBoundedByAsSectionsCS(pcSubStr, pacBounds, pCaseSensitive)
			return This.FindFirstSubStringBoundedByCSZZ(pcSubStr, pacBounds, pCaseSensitive)

		#>

	#-- WITHOUT CASESENSITIVITY

	def FindFirstSubStringBetweenZZ(pcSubStr, pcBound1, pcBound2)
		return This.FindFirstSubStringBetweenCSZZ(pcSubStr, pcBound1, pcBound2, :CaseSensitive = TRUE)

		#< @FunctionAlternativeForms

		def FindFirstSubStringBoundedByZZ(pcSubStr, pacBounds)
			return This.FindFirstSubStringBoundedByZZ(pcSubStr, pacBounds)

		#--
	
		def FindFirstSubStringBetweenAsSections(pcSubStr, pcBound1, pcBound2)
			return This.FindFirstSubStringBetweenZZ(pcSubStr, pcBound1, pcBound2)

		def FindFirstSubStringBoundedByAsSections(pcSubStr, pacBounds)
			return This.FindFirstSubStringBoundedByZZ(pcSubStr, pacBounds)

		#==

		def FirstSubStringBetweenZZ(pcSubStr, pcBound1, pcBound2)
			return This.FindFirstSubStringBetweenZZ(pcSubStr, pcBound1, pcBound2)

		def FirstSubStringBoundedByZZ(pcSubStr, pacBounds)
			return This.FindFirstSubStringBoundedByZZ(pcSubStr, pacBounds)

		def FirstSubStringBetweenAsSections(pcSubStr, pcBound1, pcBound2)
			return This.FindFirstSubStringBetweenZZ(pcSubStr, pcBound1, pcBound2)

		def FirstSubStringBoundedByAsSections(pcSubStr, pacBounds)
			return This.FindFirstSubStringBoundedByZZ(pcSubStr, pacBounds)

		#>

	  #--------------------------------------------------------------------------------------------#
	 #  FINDING FIRST OCCURRENCE OF A SUBSTRING BOUNDED BY TWO OTHER SUBSTRINGS INCLUDING BOUNDS  #
	#--------------------------------------------------------------------------------------------#

	def FindFirstSubStringBetweenCSIB(pcSubStr, pcBound1, pcBound2, pCaseSensitive)
		/* ... */

		#< @FunctionAlternativeForms

		def FindFirstSubStringBoundedByCSIB(pcSubStr, pacBounds, pCaseSensitive)
			if isString(pacBounds)
				return This.FindFirstSubStringBetweenCSIB(pcSubStr, pacBounds, pacBounds, pCaseSensitive)

			but isList(pacBounds) and Q(pacBounds).IsPairOfStrings()
				return TThis.FindFirstSubStringBetweenCSIB(pcSubStr, pacBounds[1], pacBounds[2], pCaseSensitive)

			else
				StzRaise("Incorrect param type! pacBounds must be a string or pair of strings.")
			ok

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
		return This.FindFirstSubStringBetweenCSIB(pcSubStr, pcBound1, pcBound2, :CaseSensitive = TRUE)

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
		/* ... */

		#< @FunctionAlternativeForms

		def FindFirstSubStringBoundedByCSIBZZ(pcSubStr, pacBounds, pCaseSensitive)
			if isString(pacBounds)
				return This.FindFirstSubStringBetweenCSIBZZ(pcSubStr, pcBounds, pcBounds, pCaseSensitive)

			but isList(pacBounds) and Q(pacBounds).IsPairOfStrings()
				return This.FindFirstSubStringBetweenCSIBZZ(pcSubStr, pcBounds[1], pcBounds[2], pCaseSensitive)

			else
				StzRaise("Incorrect param type! pacBounds must be a string or pair of strings.")
			ok

		#--
	
		def FindFirstSubStringBetweenAsSectionsCSIB(pcSubStr, pcBound1, pcBound2, pCaseSensitive)
			return This.FindFirstSubStringBetweenCSIBZZ(pcSubStr, pcBound1, pcBound2, pCaseSensitive)

		def FindFirstSubStringBoundedByAsSectionsCSIB(pcSubStr, pacBounds, pCaseSensitive)
			return This.FindFirstSubStringBoundedByCSIBZZ(pcSubStr, pacBounds, pCaseSensitive)

		#==

		def FirstSubStringBetweenCSIBZZ(pcSubStr, pcBound1, pcBound2, pCaseSensitive)
			return This.FindBetweenCSIBZZ(pcSubStr, pcBound1, pcBound2, pCaseSensitive)

		def FirstSubStringBoundedByCSIBZZ(pcSubStr, pacBounds, pCaseSensitive)
			return This.FindFirstSubStringBoundedByCSIBZZ(pcSubStr, pacBounds, pCaseSensitive)

		def FirstSubStringBetweenAsSectionsCSIB(pcSubStr, pcBound1, pcBound2, pCaseSensitive)
			return This.FindFirstSubStringBetweenCSIBZZ(pcSubStr, pcBound1, pcBound2, pCaseSensitive)

		def FirstSubStringBoundedByAsSectionsCSIB(pcSubStr, pacBounds, pCaseSensitive)
			return This.FindFirstSubStringBoundedByCSIBZZ(pcSubStr, pacBounds, pCaseSensitive)

		#>

	#-- WITHOUT CASESENSITIVITY

	def FindFirstSubStringBetweenZZIB(pcSubStr, pcBound1, pcBound2)
		return This.FindFirstSubStringBetweenCSIBZZ(pcSubStr, pcBound1, pcBound2, :CaseSensitive = TRUE)

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

		def FirstSubStringBetweenIBZZ(pcSubStr, pcBound1, pcBound2)
			return This.FindFirstSubStringBetweenIBZZ(pcSubStr, pcBound1, pcBound2)

		def FirstSubStringBoundedByIBZZ(pcSubStr, pacBounds)
			return This.FindFirstSubStringBoundedByIBZZ(pcSubStr, pacBounds)

		def FirstSubStringBetweenAsSectionsIB(pcSubStr, pcBound1, pcBound2)
			return This.FindFirstSubStringBetweenIBZZ(pcSubStr, pcBound1, pcBound2)

		def FirstSubStringBoundedByAsSectionsIB(pcSubStr, pacBounds)
			return This.FindFirstSubStringBoundedByIBZZ(pcSubStr, pacBounds)

		#>
		
	   #------------------------------------------------------#
	  #  FINDING FIRST OCCURRENCE OF A SUBSTRING BOUNDED BY  #
	 #  TWO OTHER SUBSTRINGS STARTING AT A GIVEN POSITION   #
	#------------------------------------------------------#

	def FindFirstSubStringBetweenSCS(pcSubStr, pcBound1, pcBound2, pnStartingAt, pCaseSensitive)
		/* ... */

		#< @FunctionalternativeForms

		def FindFirstSubStringBoundedBySCS(pcSubStr, pacBounds, pnStartingAt, pCaseSensitive)
			if isString(pacBounds)
				return This.FindFirstSubStringBetweenSCS(pcSubStr, pacBounds, pacBounds, pnStartingAt, pCaseSensitive)

			but isList(pacBounds) and Q(pacBounds).IsPairOfStrings()
				return This.FindFirstSubStringBetweenSCS(pcSubStr, pacBounds[1], pacBounds[2], pnStartingAt, pCaseSensitive)

			else
				StzRaise("Incorrect param type! pacBounds must be a string or pair of strings.")
			ok

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

		def FirstSubStringBetweenSCSZ(pcSubStr, pcBound1, pcBound2, pnStartingAt, pCaseSensitive)
			return This.FindFirstSubStringBetweenSCS(pcSubStr, pcBound1, pcBound2, pnStartingAt, pCaseSensitive)

		def FirstSubStringBoundedBySCSZ(pcSubStr, pacBounds, pnStartingAt, pCaseSensitive)
			return This.FindFirstSubStringBoundedBySCS(pcSubStr, pacBounds, pnStartingAt, pCaseSensitive)

		#>

	#-- WITHOUT CASESENSITIVITY

	def FindFirstSubStringBetweenS(pcSubStr, pcBound1, pcBound2, pnStartingAt)
		return This.FindFirstSubStringBetweenSCS(pcSubStr, pcBound1, pcBound2, pnStartingAt, :CaseSensitive = TRUE)

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

		def FirstSubStringBetweenSZ(pcSubStr, pcBound1, pcBound2, pnStartingAt)
			return This.FindFirstSubStringBetweenS(pcSubStr, pcBound1, pcBound2, pnStartingAt)

		def FirstSubStringBoundedBySZ(pcSubStr, pacBounds, pnStartingAt)
			return This.FindFirstSubStringBoundedByS(pcSubStr, pacBounds, pnStartingAt)

		#>

	   #---------------------------------------------------------------------------#
	  #  FINDING FIRST OCCURRENCE OF A SUBSTRING BOUNDED BY TWO OTHER SUBSTRINGS  #
	 #  STARTING AT A GIVEN POSITION AND RETURNING POSITIONS AS SECTIONS         #
	#---------------------------------------------------------------------------#

	def FindFirstSubStringBetweenSCSZZ(pcSubStr, pcBound1, pcBound2, pnStartingAt, pCaseSensitive)
		/* ... */

		#< @FunctionAlternativeForms

		def FindFirstSubStringBoundedBySCSZZ(pcSubStr, pacBounds, pnStartingAt, pCaseSensitive)
			if isString(pacBounds)
				return This.FindFirstSubStringBetweenSCSZZ(pcSubStr, pacBounds, pacBounds, pnStartingAt, pCaseSensitive)

			but isList(pacBounds) and Q(pacBounds).isPairOfStrings()
				return This.FindFirstSubStringBetweenSCSZZ(pcSubStr, pacBounds[1], pacBounds[2], pnStartingAt, pCaseSensitive)

			else
				StzRaise("Incorrect param type! pacBounds must be a string or pair of strings.")
			ok

		#--
	
		def FindFirstSubStringBetweenAsSectionsSCS(pcSubStr, pcBound1, pcBound2, pnStartingAt, pCaseSensitive)
			return This.FindFirstSubStringBetweenSCSZZ(pcSubStr, pcBound1, pcBound2, pnStartingAt, pCaseSensitive)

		def FindFirstSubStringBoundedByAsSectionsSCS(pcSubStr, pacBounds, pnStartingAt, pCaseSensitive)
			return This.FindFirstSubStringBoundedBySCSZZ(pcSubStr, pacBounds, pnStartingAt, pCaseSensitive)

		#==

		def FirstSubStringBetweenSCSZZ(pcSubStr, pcBound1, pcBound2, pnStartingAt, pCaseSensitive)
			return This.FindFirstSubStringBetweenSCSZZ(pcSubStr, pcBound1, pcBound2, pnStartingAt, pCaseSensitive)

		def FirstSubStringBoundedBySCSZZ(pcSubStr, pacBounds, pnStartingAt, pCaseSensitive)
			return This.FindFirstSubStringBoundedBySCSZZ(pcSubStr, pacBounds, pnStartingAt, pCaseSensitive)

		def FirstSubStringBetweenAsSectionsSCS(pcSubStr, pcBound1, pcBound2, pnStartingAt, pCaseSensitive)
			return This.FindFirstSubStringBetweenSCSZZ(pcSubStr, pcBound1, pcBound2, pnStartingAt, pCaseSensitive)

		def FirstSubStringBoundedByAsSectionsSCS(pcSubStr, pacBounds, pnStartingAt, pCaseSensitive)
			return This.FindFirstSubStringBoundedBySCSZZ(pcSubStr, pacBounds, pnStartingAt, pCaseSensitive)

		#>

	#--

	def FindFirstSubStringBetweenSZZ(pcSubStr, pcBound1, pcBound2, pnStartingAt)
		return This.FindFirstSubStringBetweenSCSZZ(pcSubStr, pcBound1, pcBound2, pnStartingAt, :CaseSensitive = TRUE)

		#< @FunctionAlternativeForms

		def FindFirstSubStringBoundedBySZZ(pcSubStr, pacBounds, pnStartingAt)
			return This.FindFirstSubStringBoundedBySZZ(pcSubStr, pacBounds, pnStartingAt)

		#--
	
		def FindFirstSubStringBetweenAsSectionsS(pcSubStr, pcBound1, pcBound2, pnStartingAt)
			return This.FindFirstSubStringBetweenSZZ(pcSubStr, pcBound1, pcBound2, pnStartingAt)

		def FindFirstSubStringBoundedByAsSectionsS(pcSubStr, pacBounds, pnStartingAt)
			return This.FindFirstSubStringBoundedBySZZ(pcSubStr, pacBounds, pnStartingAt)

		#==

		def FirstSubStringBetweenSZZ(pcSubStr, pcBound1, pcBound2, pnStartingAt)
			return This.FindFirstSubStringBetweenSZZ(pcSubStr, pcBound1, pcBound2, pnStartingAt)

		def FirstSubStringBoundedBySZZ(pcSubStr, pacBounds, pnStartingAt)
			return This.FindFirstSubStringBoundedBySZZ(pcSubStr, pacBounds, pnStartingAt)

		def FirstSubStringBetweenAsSectionsS(pcSubStr, pcBound1, pcBound2, pnStartingAt)
			return This.FindFirstSubStringBetweenSZZ(pcSubStr, pcBound1, pcBound2, pnStartingAt)

		def FirstSubStringBoundedByAsSectionsS(pcSubStr, pacBounds, pnStartingAt)
			return This.FindFirstSubStringBoundedBySZZ(pcSubStr, pacBounds, pnStartingAt)

		#>

	   #----------------------------------------------------------------#
	  #  FINDING FIRST OCCURRENCE OF A SUBSTRING BOUNDED BY TWO OTHER  #
	 #  SUBSTRINGSSTARTING AT A GIVEN POSITION AND INCLUDING BOUNDS   #
	#----------------------------------------------------------------#

	def FindFirstSubStringBetweenSCSIB(pcSubStr, pcBound1, pcBound2, pnStartingAt, pCaseSensitive)
		/* ... */

		#< @FunctionAlternativeForms

		def FindFirstSubStringBoundedBySCSIB(pcSubStr, pacBounds, pnStartingAt, pCaseSensitive)
			if isString(pacBounds)
				return This.FindFirstSubStringBetweenSCSIB(pcSubStr, pacBounds, pacBounds, pnStartingAt, pCaseSensitive)

			but isList(pacBounds) and Q(pacBounds).IsPairOfStrings()
				return This.FindFirstSubStringBetweenSCSIB(pcSubStr, pacBounds[1], pacBounds[2], pnStartingAt, pCaseSensitive)

			else
				StzRaise("Incorrect param type! pacBounds must be a string or pair of strings.")
			ok

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

		def FirstSubStringBetweenSCSIBZ(pcSubStr, pcBound1, pcBound2, pnStartingAt, pCaseSensitive)
			return This.FindFirstSubStringBetweenSCSIB(pcSubStr, pcBound1, pcBound2, pnStartingAt, pCaseSensitive)

		def FirstSubStringBoundedBySCSIBZ(pcSubStr, pacBounds, pnStartingAt, pCaseSensitive)
			return This.FindFirstSubStringBoundedBySCSIB(pcSubStr, pacBounds, pnStartingAt, pCaseSensitive)

		#>

	#-- WITHOUT CASESENSITIVITY

	def FindFirstSubStringBetweenSIB(pcSubStr, pcBound1, pcBound2, pnStartingAt)
		return This.FindFirstSubStringBetweenSCSIB(pcSubStr, pcBound1, pcBound2, pnStartingAt, :CaseSensitive = TRUE)

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

		def FirstSubStringBetweenSIBZ(pcSubStr, pcBound1, pcBound2, pnStartingAt)
			return This.FindFirstSubStringBetweenSIB(pcSubStr, pcBound1, pcBound2, pnStartingAt)

		def FirstSubStringBoundedBySIBZ(pcSubStr, pacBounds, pnStartingAt)
			return This.FindFirstSubStringBoundedBySIB(pcSubStr, pacBounds, pnStartingAt)

		#>

	   #-------------------------------------------------------------------------------------#
	  #  FINDING FIRST OCCURRENCE OF A SUBSTRING BOUNDED BY TWO OTHER SUBSTRINGS STARTING   #
	 #  AT A GIVEN POSITION, INCLUDING BOUNDS, AND RETURNING THE POSITIONS AS SECTIONS     #
	#-------------------------------------------------------------------------------------#

	def FindFirstSubStringBetweenSCSIBZZ(pcSubStr, pcBound1, pcBound2, pnStartingAt, pCaseSensitive)
		/* ... */

		#< @FunctionAlternativeForms

		def FindFirstSubStringBoundedBySCSIBZZ(pcSubStr, pacBounds, pnStartingAt, pCaseSensitive)
			if isString(pacBounds)
				return This.FindFirstSubStringBetweenSCSIBZZ(pcSubStr, pacBounds, pacBounds, pnStartingAt, pCaseSensitive)

			but isList(pacBounds) and Q(pacBounds).IsPairOfStrings()
				return This.FindFirstSubStringBetweenSCSIBZZ(pcSubStr, pacBounds[1], pacBounds[2], pnStartingAt, pCaseSensitive)

			else
				StzRaise("Incorrect param type! pacBounds must be string or pair of strings.")

			ok

		#--
	
		def FindFirstSubStringBetweenAsSectionsSCSIB(pcSubStr, pcBound1, pcBound2, pnStartingAt, pCaseSensitive)
			return This.FindFirstSubStringBetweenSCSIBZZ(pcSubStr, pcBound1, pcBound2, pnStartingAt, pCaseSensitive)

		def FindFirstSubStringBoundedByAsSectionsSCSIB(pcSubStr, pacBounds, pnStartingAt, pCaseSensitive)
			return This.FindFirstSubStringBoundedBySCSIBZZ(pcSubStr, pacBounds, pnStartingAt, pCaseSensitive)

		#==

		def FirstSubStringBetweenSCSIBZZ(pcSubStr, pcBound1, pcBound2, pnStartingAt, pCaseSensitive)
			return This.FindFirstSubStringBetweenSCSIBZZ(pcSubStr, pcBound1, pcBound2, pnStartingAt, pCaseSensitive)

		def FirstSubStringBoundedBySCSIBZZ(pcSubStr, pacBounds, pnStartingAt, pCaseSensitive)
			return This.FindFirstSubStringBoundedBySCSIBZZ(pcSubStr, pacBounds, pnStartingAt, pCaseSensitive)

		def FirstSubStringBetweenAsSectionsSCSIB(pcSubStr, pcBound1, pcBound2, pnStartingAt, pCaseSensitive)
			return This.FindFirstSubStringBetweenSIBCSZZ(pcSubStr, pcBound1, pcBound2, pnStartingAt, pCaseSensitive)

		def FirstSubStringBoundedByAsSectionsSCSIB(pcSubStr, pacBounds, pnStartingAt, pCaseSensitive)
			return This.FindFirstSubStringBoundedBySCSIBZZ(pcSubStr, pacBounds, pnStartingAt, pCaseSensitive)

		#>

	#-- WITHOUT CASESENSITIVITY

	def FindFirstSubStringBetweenSIBZZ(pcSubStr, pcBound1, pcBound2, pnStartingAt)
		return This.FindFirstSubStringBetweenSIBCSZZ(pcSubStr, pcBound1, pcBound2, pnStartingAt, :CaseSensitive = TRUE)

		#< @FunctionAlternativeForms

		def FindFirstSubStringBoundedBySIBZZ(pcSubStr, pacBounds, pnStartingAt)
			return This.FindFirstSubStringBoundedBySIBZZ(pcSubStr, pacBounds, pnStartingAt)

		#--
	
		def FindFirstSubStringBetweenAsSectionsSIB(pcSubStr, pcBound1, pcBound2, pnStartingAt)
			return This.FindFirstSubStringBetweenSIBZZ(pcSubStr, pcBound1, pcBound2, pnStartingAt)

		def FindFirstSubStringBoundedByAsSectionsSIB(pcSubStr, pacBounds, pnStartingAt)
			return This.FindFirstSubStringBoundedBySIBZZ(pcSubStr, pacBounds, pnStartingAt)

		#==

		def FirstSubStringBetweenSIBZZ(pcSubStr, pcBound1, pcBound2, pnStartingAt)
			return This.FindFirstSubStringBetweenSIBZZ(pcSubStr, pcBound1, pcBound2, pnStartingAt)

		def FirstSubStringBoundedBySIBZZ(pcSubStr, pacBounds, pnStartingAt)
			return This.FindFirstSubStringBoundedBySIBZZ(pcSubStr, pacBounds, pnStartingAt)

		def FirstSubStringBetweenAsSectionsSIB(pcSubStr, pcBound1, pcBound2, pnStartingAt)
			return This.FindFirstSubStringBetweenSIBZZ(pcSubStr, pcBound1, pcBound2, pnStartingAt)

		def FirstSubStringBoundedByAsSectionsSIB(pcSubStr, pacBounds, pnStartingAt)
			return This.FindFirstSubStringBoundedBySIBZZ(pcSubStr, pacBounds, pnStartingAt)

		#>

	   #------------------------------------------------------#
	  #  FINDING FIRST OCCURRENCE OF A SUBSTRING BOUNDED BY  #
	 #  TWO OTHER SUBSTRINGS GOING IN A GIVEN DIRECTION     #
	#------------------------------------------------------#

	def FindFirstSubStringBetweenDCS(pcSubStr, pcBound1, pcBound2, pcDirection, pCaseSensitive)
		/* ... */

		#< @FunctionAlternativeForms

		def FindFirstSubStringBoundedByDCS(pcSubStr, pacBounds, pcDirection, pCaseSensitive)
			if isString(pacBounds)
				return This.FindFirstSubStringBetweenDCS(pcSubStr, pacBounds, pacBounds, pcDirection, pCaseSensitive)

			but isList(pacBounds) and Q(pacBounds).IsPairOfStrings()
				return This.FindFirstSubStringBetweenDCS(pcSubStr, pacBounds[1], pacBounds[2], pcDirection, pCaseSensitive)

			else
				StzRaise("Incorrect param type! pacBounds must be a string or pair of strings.")
			ok

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

		def FirstSubStringBetweenDCSZ(pcSubStr, pcBound1, pcBound2, pcDirection, pCaseSensitive)
			return This.FindFirstSubStringBetweenDCS(pcSubStr, pcBound1, pcBound2, pcDirection, pCaseSensitive)

		def FirstSubStringBoundedByDCSZ(pcSubStr, pacBounds, pcDirection, pCaseSensitive)
			return This.FindFirstSubStringBoundedByDCS(pcSubStr, pacBounds, pcDirection, pCaseSensitive)

		#>

	#-- WITHOUT CASESENSITIVITY

	def FindFirstSubStringBetweenD(pcSubStr, pcBound1, pcBound2, pcDirection)
		return This.FindFirstSubStringBetweenDCS(pcSubStr, pcBound1, pcBound2, pcDirection, :CaseSensitive = TRUE)

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

		def FirstSubStringBetweenDZ(pcSubStr, pcBound1, pcBound2, pcDirection)
			return This.FindFirstSubStringBetweenD(pcSubStr, pcBound1, pcBound2, pcDirection)

		def FirstSubStringBoundedByDZ(pcSubStr, pacBounds, pcDirection)
			return This.FindFirstSubStringBoundedByD(pcSubStr, pacBounds, pcDirection)

		#>

	   #---------------------------------------------------------------------------#
	  #  FINDING FIRST OCCURRENCE OF A SUBSTRING BOUNDED BY TWO OTHER SUBSTRINGS  #
	 #  GOING INA GIVEN DIRECTION AND RETURNING POSITIONS AS SECTIONS            #
	#---------------------------------------------------------------------------#

	def FindFirstSubStringBetweenDCSZZ(pcSubStr, pcBound1, pcBound2, pcDirection, pCaseSensitive)
		/* ... */

		#< @FunctionAlternativeForms

		def FindFirstSubStringBoundedByDCSZZ(pcSubStr, pacBounds, pcDirection, pCaseSensitive)
			if isString(pacBounds)
				return This.FindFirstSubStringBetweenDCSZZ(pcSubStr, pacBounds, pacBounds, pcDirection, pCaseSensitive)

			but isList(pacBounds) and Q(pacBounds).IsPairOfNumbers()
				return This.FindFirstSubStringBetweenDCSZZ(pcSubStr, pacBounds[1], pacBounds[2], pcDirection, pCaseSensitive)

			else
				StzRaise("Incorrect param type! pacBounds must be a string or pair of strings.")

			ok

		#--
	
		def FindFirstSubStringBetweenAsSectionsDCS(pcSubStr, pcBound1, pcBound2, pcDirection, pCaseSensitive)
			return This.FindFirstSubStringBetweenDCSZZ(pcSubStr, pcBound1, pcBound2, pcDirection, pCaseSensitive)

		def FindFirstSubStringBoundedByAsSectionsDCS(pcSubStr, pacBounds, pcDirection, pCaseSensitive)
			return This.FindFirstSubStringBoundedByDCSZZ(pcSubStr, pacBounds, pcDirection, pCaseSensitive)

		#==

		def FirstSubStringBetweenDCSZZ(pcSubStr, pcBound1, pcBound2, pcDirection, pCaseSensitive)
			return This.FindFirstSubStringBetweenDCSZZ(pcSubStr, pcBound1, pcBound2, pcDirection, pCaseSensitive)

		def FirstSubStringBoundedByDCSZZ(pcSubStr, pacBounds, pcDirection, pCaseSensitive)
			return This.FindFirstSubStringBoundedByDCSZZ(pcSubStr, pacBounds, pcDirection, pCaseSensitive)

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

		def FirstSubStringBetweenDZZ(pcSubStr, pcBound1, pcBound2, pcDirection)
			return This.FindFirstSubStringBetweenDZZ(pcSubStr, pcBound1, pcBound2, pcDirection)

		def FirstSubStringBoundedByDZZ(pcSubStr, pacBounds, pcDirection)
			return This.FindFirstSubStringBoundedByDZZ(pcSubStr, pacBounds, pcDirection)

		def FirstSubStringBetweenAsSectionsD(pcSubStr, pcBound1, pcBound2, pcDirection)
			return This.FindFirstSubStringBetweenDZZ(pcSubStr, pcBound1, pcBound2, pcDirection)

		def FirstSubStringBoundedByAsSectionsD(pcSubStr, pacBounds, pcDirection)
			return This.FindFirstSubStringBoundedByDZZ(pcSubStr, pacBounds, pcDirection)

		#>

	   #----------------------------------------------------------------#
	  #  FINDING FIRST OCCURRENCE OF A SUBSTRING BOUNDED BY TWO OTHER  #
	 #  SUBSTRINGS GOING IN A GIVEN DIRECTION AND INCLUDING BOUNDS    #
	#----------------------------------------------------------------#

	def FindFirstSubStringBetweenDCSIB(pcSubStr, pcBound1, pcBound2, pcDirection, pCaseSensitive)
		/* ... */

		#< @FunctionAlternativeForms

		def FindFirstSubStringBoundedByDCSIB(pcSubStr, pacBounds, pcDirection, pCaseSensitive)
			if isString(pacBounds)
				return This.FindFirstSubStringBetweenDCSIB(pcSubStr, pacBounds, pacBounds, pcDirection, pCaseSensitive)

			but isList(pacBounds) and Q(pacBounds).IsPairOfStrings()
				return This.FindFirstSubStringBetweenDCSIB(pcSubStr, pacBounds[1], pacBounds[2], pcDirection, pCaseSensitive)

			else
				StzRaise("Incorrect param type! pacBounds must be a string or pair of strings.")
			ok

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

		def FirstSubStringBetweenDCSIBZ(pcSubStr, pcBound1, pcBound2, pcDirection, pCaseSensitive)
			return This.FindFirstSubStringBetweenDCSIB(pcSubStr, pcBound1, pcBound2, pcDirection, pCaseSensitive)

		def FirstSubStringBoundedByDCSIBZ(pcSubStr, pacBounds, pcDirection, pCaseSensitive)
			return This.FindFirstSubStringBoundedByDCSIB(pcSubStr, pacBounds, pcDirection, pCaseSensitive)

		#>

	#-- WITHOUT CASESENSITIVITY

	def FindFirstSubStringBetweenDIB(pcSubStr, pcBound1, pcBound2, pcDirection)
		return This.FindFirstSubStringBetweenDCSIB(pcSubStr, pcBound1, pcBound2, pcDirection, :CaseSensitive = TRUE)

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

		def FirstSubStringBetweenDIBZ(pcSubStr, pcBound1, pcBound2, pcDirection)
			return This.FindFirstSubStringBetweenDIB(pcSubStr, pcBound1, pcBound2, pcDirection)

		def FirstSubStringBoundedByDIBZ(pcSubStr, pacBounds, pcDirection)
			return This.FindFirstSubStringBoundedByDIB(pcSubStr, pacBounds, pcDirection)

		#>

	   #---------------------------------------------------------------------------------#
	  #  FINDING FIRST OCCURRENCE OF A SUBSTRING BOUNDED BY TWO OTHER SUBSTRINGS GOING  #
	 #  IN A GIVENDIRECTION, INCLUDING BOUNDS, AND RETURNING POSITIONS AS SECTIONS     # 
	#---------------------------------------------------------------------------------#

	def FindFirstSubStringBetweenDCSIBZZ(pcSubStr, pcBound1, pcBound2, pcDirection, pCaseSensitive)
		/* ... */

		#< @FunctionAlternativeForms

		def FindFirstSubStringBoundedByDCSIBZZ(pcSubStr, pacBounds, pcDirection, pCaseSensitive)
			if isString(pacBounds)
				return This.FindFirstSubStringBetweenDCSIBZZ(pcSubStr, pacBounds, pacBounds, pcDirection, pCaseSensitive)

			but isList(pacBounds) and Q(pacBounds).IsPairOfNumbers()
				return This.FindFirstSubStringBetweenDCSIBZZ(pcSubStr, pacBounds[1], pacBounds[2], pcDirection, pCaseSensitive)

			else
				StzRaise("Incorrect param type! pacBounds must be a string or pair of strings.")

			ok

		#--
	
		def FindFirstSubStringBetweenAsSectionsDCSIB(pcSubStr, pcBound1, pcBound2, pcDirection, pCaseSensitive)
			return This.FindFirstSubStringBetweenDCSIBZZ(pcSubStr, pcBound1, pcBound2, pcDirection, pCaseSensitive)

		def FindFirstSubStringBoundedByAsSectionsDCSIB(pcSubStr, pacBounds, pcDirection, pCaseSensitive)
			return This.FindBoundedByDCSIBZZ(pcSubStr, pacBounds, pcDirection, pCaseSensitive)

		#==

		def FirstSubStringBetweenDCSIBZZ(pcSubStr, pcBound1, pcBound2, pcDirection, pCaseSensitive)
			return This.FindFirstSubStringBetweenDCSIBZZ(pcSubStr, pcBound1, pcBound2, pcDirection, pCaseSensitive)

		def FirstSubStringBoundedByDCSIBZZ(pcSubStr, pacBounds, pcDirection, pCaseSensitive)
			return This.FindFirstSubStringBoundedByDCSIBZZ(pcSubStr, pacBounds, pcDirection, pCaseSensitive)

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

		def FirstSubStringBetweenDIBZZ(pcSubStr, pcBound1, pcBound2, pcDirection)
			return This.FindFirstSubStringBetweenDIBZZ(pcSubStr, pcBound1, pcBound2, pcDirection)

		def FirstSubStringBoundedByDIBZZ(pcSubStr, pacBounds, pcDirection)
			return This.FindFirstSubStringBoundedByDIBZZ(pcSubStr, pacBounds, pcDirection)

		def FirstSubStringBetweenAsSectionsDIB(pcSubStr, pcBound1, pcBound2, pcDirection)
			return This.FindFirstSubStringBetweenDIBZZ(pcSubStr, pcBound1, pcBound2, pcDirection)

		def FirstSubStringBoundedByAsSectionsDIB(pcSubStr, pacBounds, pcDirection)
			return This.FindFirstSubStringBoundedByDIBZZ(pcSubStr, pacBounds, pcDirection)

		#>

	   #---------------------------------------------------------------------------#
	  #  FINDING FIRST OCCURRENCE OF A SUBSTRING BOUNDED BY TWO OTHER SUBSTRINGS  #
	 #  STARTING AT A GIVEN POSITION AND GOING IN A GIVEN DIRECTION              #
	#---------------------------------------------------------------------------#

	def FindFirstSubStringBetweenSDCS(pcSubStr, pcBound1, pcBound2, pnStartingAt, pcDirection, pCaseSensitive)
		/* ... */

		#< @FunctionAlternativeForms

		def FindFirstSubStringBoundedBySDCS(pcSubStr, pacBounds, pnStartingAt, pcDirection, pCaseSensitive)
			if isString(pacBounds)
				return This.FindFirstSubStringBetweenSDCS(pcSubStr, pacBounds, pacBounds, pnStartingAt, pcDirection, pCaseSensitive)

			but isLsit(pacBounds) and Q(pacBounds).IsPairOfStrings()
				return This.FindFirstSubStringBetweenSDCS(pcSubStr, pacBounds[1], pacBounds[2], pnStartingAt, pcDirection, pCaseSensitive)

			else
				StzRaise("Incorrect param type! pacBounds must be a string or pair of strings.")

			ok

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

		def FirstSubStringBetweenSDCSZ(pcSubStr, pcBound1, pcBound2, pnStartingAt, pcDirection, pCaseSensitive)
			return This.FindFirstSubStringBetweenSDCS(pcSubStr, pcBound1, pcBound2, pnStartingAt, pcDirection, pCaseSensitive)

		def FirstSubStringBoundedBySDCSZ(pcSubStr, pacBounds, pnStartingAt, pcDirection, pCaseSensitive)
			return This.FindFirstSubStringBoundedBySDCS(pcSubStr, pacBounds, pnStartingAt, pcDirection, pCaseSensitive)

		#>

	#-- WITHOUT CASESENSITIVITY

	def FindFirstSubStringBetweenSD(pcSubStr, pcBound1, pcBound2, pnStartingAt, pcDirection)
		return This.FindFirstSubStringBetweenSDCS(pcSubStr, pcBound1, pcBound2,pnStartingAt, pcDirection, :CaseSensitive = TRUE)

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

		def FirstSubStringBetweenSDZ(pcSubStr, pcBound1, pcBound2, pnStartingAt, pcDirection)
			return This.FindFirstSubStringBetweenSD(pcSubStr, pcBound1, pcBound2, pnStartingAt, pcDirection)

		def FirstSubStringBoundedBySDZ(pcSubStr, pacBounds, pnStartingAt, pcDirection)
			return This.FindFirstSubStringBoundedBySD(pcSubStr, pacBounds, pnStartingAt, pcDirection)

		#>

	   #----------------------------------------------------------------------------------------#
	  #  FINDING FIRST OCCURRENCE OF A SUBSTRING BOUNDED BY TWO OTHER SUBSTRINGSS STARTING     #
	 #  AT A GIVEN POSITION, GOING IN A GIVEN DIRECTION, AND RETURNING POSITIONS AS SECTIONS  #
	#----------------------------------------------------------------------------------------#

	def FindFirstSubStringBetweenSDCSZZ(pcSubStr, pcBound1, pcBound2, pnStartingAt, pcDirection, pCaseSensitive)
		/* ... */

		#< @FunctionAlternativeForms

		def FindFirstSubStringBoundedBySDCSZZ(pcSubStr, pacBounds, pnStartingAt, pcDirection, pCaseSensitive)
			return This.FindBoundedBySDCSZZ(pcSubStr, pacBounds, pnStartingAt, pcDirection, pCaseSensitive)

		#--
	
		def FindFirstSubStringBetweenAsSectionsSDCS(pcSubStr, pcBound1, pcBound2, pnStartingAt, pcDirection, pCaseSensitive)
			return This.FindFirstSubStringBetweenSDCSZZ(pcSubStr, pcBound1, pcBound2, pnStartingAt, pcDirection, pCaseSensitive)

		def FindFirstSubStringBoundedByAsSectionsSDCS(pcSubStr, pacBounds, pnStartingAt, pcDirection, pCaseSensitive)
			return This.FindFirstSubStringBoundedBySDCSZZ(pcSubStr, pacBounds, pnStartingAt, pcDirection, pCaseSensitive)

		#==

		def FirstSubStringBoundedBySDCSZZ(pcSubStr, pacBounds, pnStartingAt, pcDirection, pCaseSensitive)
			return This.FindFirstSubStringBoundedBySDCSZZ(pcSubStr, pacBounds, pnStartingAt, pcDirection, pCaseSensitive)

		def FirstSubStringBoundedByAsSectionsSDCS(pcSubStr, pacBounds, pnStartingAt, pcDirection, pCaseSensitive)
			return This.FindFirstSubStringBoundedBySDCSZZ(pcSubStr, pacBounds, pnStartingAt, pcDirection, pCaseSensitive)

		#>

	#-- WITHOUT CASESENSITIVITY

	def FindFirstSubStringBetweenSDZZ(pcSubStr, pcBound1, pcBound2, pnStartingAt, pcDirection)
		return This.FindFirstSubStringBetweenSDCSZZ(pcSubStr, pcBound1, pcBound2, pnStartingAt, pcDirection, :CaseSensitive = TRUE)

		#< @FunctionAlternativeForms

		def FindFirstSubStringBoundedBySDZZ(pcSubStr, pacBounds, pnStartingAt, pcDirection)
			return This.FindBoundedBySDZZ(pcSubStr, pacBounds, pnStartingAt, pcDirection)

		#--
	
		def FindFirstSubStringBetweenAsSectionsSD(pcSubStr, pcBound1, pcBound2, pnStartingAt, pcDirection)
			return This.FindFirstSubStringBetweenSDZZ(pcSubStr, pcBound1, pcBound2, pnStartingAt, pcDirection)

		def FindFirstSubStringBoundedByAsSectionsSD(pcSubStr, pacBounds, pnStartingAt, pcDirection)
			return This.FindFirstSubStringBoundedBySDZZ(pcSubStr, pacBounds, pnStartingAt, pcDirection)

		#==

		def FirstSubStringBetweenSDZZ(pcSubStr, pcBound1, pcBound2, pnStartingAt, pcDirection)
			return This.FindFirstSubStringBetweenSDZZ(pcSubStr, pcBound1, pcBound2, pnStartingAt, pcDirection)

		def FirstSubStringBoundedBySDZZ(pcSubStr, pacBounds, pnStartingAt, pcDirection)
			return This.FindFirstSubStringBoundedBySDZZ(pcSubStr, pacBounds, pnStartingAt, pcDirection)

		def FirstSubStringBetweenAsSectionsSD(pcSubStr, pcBound1, pcBound2, pnStartingAt, pcDirection)
			return This.FindFirstSubStringBetweenSDZZ(pcSubStr, pcBound1, pcBound2, pnStartingAt, pcDirection)

		def FirstSubStringBoundedByAsSectionsSD(pcSubStr, pacBounds, pnStartingAt, pcDirection)
			return This.FindFirstSubStringBoundedBySDZZ(pcSubStr, pacBounds, pnStartingAt, pcDirection)

		#>

	   #-------------------------------------------------------------------------------------#
	  #  FINDING FIRST OCCURRENCE OF A SUBSTRING BOUNDED BY TWO OTHER SUBSTRINGSS STARTING  #
	 #  AT A GIVEN POSITION, GOING IN A GIVEN DIRECTION, AND INCLUDING BOUNDS              #
	#-------------------------------------------------------------------------------------#

	def FindFirstSubStringBetweenSDCSIB(pcSubStr, pcBound1, pcBound2, pnStartingAt, pcDirection, pCaseSensitive)
		/* ... */

		#< @FunctionAlternativeForms

		def FindFirstSubStringBoundedBySDCSIB(pcSubStr, pacBounds, pnStartingAt, pcDirection, pCaseSensitive)
			if isString(pacBounds)
				return This.FindFirstSubStringBetweenSDCSIB(pcSubStr, pacBounds, pacBounds, pnStartingAt, pcDirection, pCaseSensitive)

			but isLsit(pacBounds) and Q(pacBounds).IsPairOfStrings()
				return This.FindFirstSubStringBetweenSDCSIB(pcSubStr, pacBounds[1], pacBounds[2], pnStartingAt, pcDirection, pCaseSensitive)

			else
				StzRaise("Incorrect param type! pacBounds must be a string or pair of strings.")

			ok

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

		def FirstSubStringBetweenSDCSIBZ(pcSubStr, pcBound1, pcBound2, pnStartingAt, pcDirection, pCaseSensitive)
			return This.FindFirstSubStringBetweenSDCSIB(pcSubStr, pcBound1, pcBound2, pnStartingAt, pcDirection, pCaseSensitive)

		def FirstSubStringBoundedBySDCSIBZ(pcSubStr, pacBounds, pnStartingAt, pcDirection, pCaseSensitive)
			return This.FindFirstSubStringBoundedBySDCSIB(pcSubStr, pacBounds, pnStartingAt, pcDirection, pCaseSensitive)

		#>

	#-- WITHOUT CASESENSITIVITY

	def FindFirstSubStringBetweenSDIB(pcSubStr, pcBound1, pcBound2, pnStartingAt, pcDirection)
		return This.FindFirstSubStringBetweenSDCSIB(pcSubStr, pcBound1, pcBound2,pnStartingAt, pcDirection, :CaseSensitive = TRUE)

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

		def FirstSubStringBetweenSDIBZ(pcSubStr, pcBound1, pcBound2, pnStartingAt, pcDirection)
			return This.FindFirstSubStringBetweenSDIB(pcSubStr, pcBound1, pcBound2, pnStartingAt, pcDirection)

		def FirstSubStringBoundedBySDIBZ(pcSubStr, pacBounds, pnStartingAt, pcDirection)
			return This.FindFirstSubStringBoundedBySDIB(pcSubStr, pacBounds, pnStartingAt, pcDirection)

		#>

	   #------------------------------------------------------------------------------------------------#
	  #  FINDING FIRST OCCURRENCE OF A SUBSTRING BOUNDED BY TWO OTHER SUBSTRINGSS STARTING AT A GIVEN  #
	 #  POSITION, GOING IN A GIVEN DIRECTION, INCLUDING BOUNDS, AND RETURNING POSITIONS AS SECTIONS   #
	#------------------------------------------------------------------------------------------------#

	def FindFirstSubStringBetweenSDCSIBZZ(pcSubStr, pcBound1, pcBound2, pnStartingAt, pcDirection, pCaseSensitive)
		/* ... */

		#< @FunctionAlternativeForms

		def FindFirstSubStringBoundedBySDCSIBZZ(pcSubStr, pacBounds, pnStartingAt, pcDirection, pCaseSensitive)
			return This.FindFirstSubStringBoundedBySDCSIBZZ(pcSubStr, pacBounds, pnStartingAt, pcDirection, pCaseSensitive)

		#--
	
		def FindFirstSubStringBetweenAsSectionsSDCSIB(pcSubStr, pcBound1, pcBound2, pnStartingAt, pcDirection, pCaseSensitive)
			return This.FindFirstSubStringBetweenSDCSIBZZ(pcSubStr, pcBound1, pcBound2, pnStartingAt, pcDirection, pCaseSensitive)

		def FindFirstSubStringBoundedByAsSectionsSDCSIB(pcSubStr, pacBounds, pnStartingAt, pcDirection, pCaseSensitive)
			return This.FindFirstSubStringBoundedBySDCSIBZZ(pcSubStr, pacBounds, pnStartingAt, pcDirection, pCaseSensitive)

		#==

		def FirstSubStringBetweenSDCSIBZZ(pcSubStr, pcBound1, pcBound2, pnStartingAt, pcDirection, pCaseSensitive)
			return This.FindFirstSubStringBetweenSDCSIBZZ(pcSubStr, pcBound1, pcBound2, pnStartingAt, pcDirection, pCaseSensitive)

		def FirstSubStringBoundedBySDCSIBZZ(pcSubStr, pacBounds, pnStartingAt, pcDirection, pCaseSensitive)
			return This.FindFirstSubStringBoundedBySDCSIBZZ(pcSubStr, pacBounds, pnStartingAt, pcDirection, pCaseSensitive)

		def FirstSubStringBetweenAsSectionsSDCSIB(pcSubStr, pcBound1, pcBound2, pnStartingAt, pcDirection, pCaseSensitive)
			return This.FindFirstSubStringBetweenSDCSIBZZ(pcSubStr, pcBound1, pcBound2, pnStartingAt, pcDirection, pCaseSensitive)

		def FirstSubStringBoundedByAsSectionsSDCSIB(pcSubStr, pacBounds, pnStartingAt, pcDirection, pCaseSensitive)
			return This.FindFirstSubStringBoundedBySDCSIBZZ(pcSubStr, pacBounds, pnStartingAt, pcDirection, pCaseSensitive)

		#>

	#-- WITHOUT CASESENSITIVITY

	def FindFirstSubStringBetweenSDIBZZ(pcSubStr, pcBound1, pcBound2, pnStartingAt, pcDirection)
		return This.FindFirstSubStringBetweenSDCSIBZZ(pcSubStr, pcBound1, pcBound2, pnStartingAt, pcDirection, :CaseSensitive = TRUE)

		#< @FunctionAlternativeForms

		def FindFirstSubStringBoundedBySDIBZZ(pcSubStr, pacBounds, pnStartingAt, pcDirection)
			return This.FindFirstSubStringBoundedBySDIBZZ(pcSubStr, pacBounds, pnStartingAt, pcDirection)

		#--
	
		def FindFirstSubStringBetweenAsSectionsSDIB(pcSubStr, pcBound1, pcBound2, pnStartingAt, pcDirection)
			return This.FindFirstSubStringBetweenSDIBZZ(pcSubStr, pcBound1, pcBound2, pnStartingAt, pcDirection)

		def FindFirstSubStringBoundedByAsSectionsSDIB(pcSubStr, pacBounds, pnStartingAt, pcDirection)
			return This.FindFirstSubStringBoundedBySDIBZZ(pcSubStr, pacBounds, pnStartingAt, pcDirection)

		#==

		def FirstSubStringBetweenSDIBZZ(pcSubStr, pcBound1, pcBound2, pnStartingAt, pcDirection)
			return This.FindFirstSubStringBetweenSDIBZZ(pcSubStr, pcBound1, pcBound2, pnStartingAt, pcDirection)

		def FirstSubStringBoundedBySDIBZZ(pcSubStr, pacBounds, pnStartingAt, pcDirection)
			return This.FindFirstSubStringBoundedBySDIBZZ(pcSubStr, pacBounds, pnStartingAt, pcDirection)

		def FirstSubStringBetweenAsSectionsSDIB(pcSubStr, pcBound1, pcBound2, pnStartingAt, pcDirection)
			return This.FindFirstSubStringBetweenSDIBZZ(pcSubStr, pcBound1, pcBound2, pnStartingAt, pcDirection)

		def FirstSubStringBoundedByAsSectionsSDIB(pcSubStr, pacBounds, pnStartingAt, pcDirection)
			return This.FindFirstSubStringBoundedBySDIBZZ(pcSubStr, pacBounds, pnStartingAt, pcDirection)

		#>

	  #====================================================================#
	 #  FINDING LAST OCCURRENCE OF A SUBSTRING BOUNDED BY TWO SUBSTRINGS  #
	#====================================================================#


	def FindLastSubStringBetweenCS(pcSubStr, pcBound1, pcBound2, pCaseSensitive)
		/* ... */

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
	
		def LastSubStringBetweenCSZ(pcSubStr, pcBound1, pcBound2, pCaseSensitive)
			return This.FindLastSubStringBetweenCS(pcSubStr, pcBound1, pcBound2, pCaseSensitive)

		def LastSubStringBoundedByCSZ(pcSubStr, pacBounds, pCaseSensitive)
			return This.FindLastSubStringBoundedByCS(pcSubStr, pacBounds, pCaseSensitive)

		#>

	#-- WITHOUT CASESENSITIVE

	def FindLastSubStringSubStringBetween(pcSubStr, pcBound1, pcBound2)
		return This.FindLastSubStringSubStringBetweenCS(pcSubStr, pcBound1, pcBound1, :CaseSensitive = TRUE)

		#< @FunctionAlternativeForms

		def FindLastSubStringBoundedBy(pcSubStr, pacBounds)
			return This.FindLastSubStringBoundedByCS(pcSubStr, pacBounds, :CaseSensitive = TRUE)

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
	
		def LastSubStringBetweenZ(pcSubStr, pcBound1, pcBound2)
			return This.FindLastSubStringBetween(pcSubStr, pcBound1, pcBound2)

		def LastSubStringBoundedByZ(pcSubStr, pacBounds)
			return This.FindLastSubStringBoundedBy(pcSubStr, pacBounds)

		#>

	   #-------------------------------------------------------#
	  #  FINDING LAST OCCURRENCE OF A SUBSTRING BOUNDED BY    #
	 #  TWO OTHER SUBSTRINGS AND RETURNING THEM AS SECTIONS  #
	#-------------------------------------------------------#

	def FindLastSubStringBetweenCSZZ(pcSubStr, pcBound1, pcBound2, pCaseSensitive)
		/* ... */

		#< @FunctionAlternativeForms

		def FindLastSubStringBoundedByCSZZ(pcSubStr, pacBounds, pCaseSensitive)
			if isString(pacBounds)
				return This.FindLastSubStringBetweenCSZZ(pcSubStr, pcBounds, pcBounds, pCaseSensitive)

			but isList(pacBounds) and Q(pacBounds).IsPairOfStrings()
				return This.FindLastSubStringBetweenCSZZ(pcSubStr, pcBounds[1], pcBounds[2], pCaseSensitive)

			else
				StzRaise("Incorrect param type! pacBounds must be a string or pair of strings.")
			ok

		#--
	
		def FindLastSubStringBetweenAsSectionsCS(pcSubStr, pcBound1, pcBound2, pCaseSensitive)
			return This.FindLastSubStringBetweenCSZZ(pcSubStr, pcBound1, pcBound2, pCaseSensitive)

		def FindLastSubStringBoundedByAsSectionsCS(pcSubStr, pacBounds, pCaseSensitive)
			return This.FindLastSubStringBoundedByCSZZ(pcSubStr, pacBounds, pCaseSensitive)

		#==

		def LastSubStringBetweenCSZZ(pcSubStr, pcBound1, pcBound2, pCaseSensitive)
			return This.FindLastSubStringBetweenCSZZ(pcSubStr, pcBound1, pcBound2, pCaseSensitive)

		def LastSubStringBoundedByCSZZ(pcSubStr, pacBounds, pCaseSensitive)
			return This.FindLastSubStringBoundedByCSZZ(pcSubStr, pacBounds, pCaseSensitive)

		def LastSubStringBetweenAsSectionsCS(pcSubStr, pcBound1, pcBound2, pCaseSensitive)
			return This.FindLastSubStringBetweenCSZZ(pcSubStr, pcBound1, pcBound2, pCaseSensitive)

		def LastSubStringBoundedByAsSectionsCS(pcSubStr, pacBounds, pCaseSensitive)
			return This.FindLastSubStringBoundedByCSZZ(pcSubStr, pacBounds, pCaseSensitive)

		#>

	#-- WITHOUT CASESENSITIVITY

	def FindLastSubStringBetweenZZ(pcSubStr, pcBound1, pcBound2)
		return This.FindLastSubStringBetweenCSZZ(pcSubStr, pcBound1, pcBound2, :CaseSensitive = TRUE)

		#< @FunctionAlternativeForms

		def FindLastSubStringBoundedByZZ(pcSubStr, pacBounds)
			return This.FindLastSubStringBoundedByZZ(pcSubStr, pacBounds)

		#--
	
		def FindLastSubStringBetweenAsSections(pcSubStr, pcBound1, pcBound2)
			return This.FindLastSubStringBetweenZZ(pcSubStr, pcBound1, pcBound2)

		def FindLastSubStringBoundedByAsSections(pcSubStr, pacBounds)
			return This.FindLastSubStringBoundedByZZ(pcSubStr, pacBounds)

		#==

		def LastSubStringBetweenZZ(pcSubStr, pcBound1, pcBound2)
			return This.FindLastSubStringBetweenZZ(pcSubStr, pcBound1, pcBound2)

		def LastSubStringBoundedByZZ(pcSubStr, pacBounds)
			return This.FindLastSubStringBoundedByZZ(pcSubStr, pacBounds)

		def LastSubStringBetweenAsSections(pcSubStr, pcBound1, pcBound2)
			return This.FindLastSubStringBetweenZZ(pcSubStr, pcBound1, pcBound2)

		def LastSubStringBoundedByAsSections(pcSubStr, pacBounds)
			return This.FindLastSubStringBoundedByZZ(pcSubStr, pacBounds)

		#>

	  #-------------------------------------------------------------------------------------------#
	 #  FINDING LAST OCCURRENCE OF A SUBSTRING BOUNDED BY TWO OTHER SUBSTRINGS INCLUDING BOUNDS  #
	#-------------------------------------------------------------------------------------------#

	def FindLastSubStringBetweenCSIB(pcSubStr, pcBound1, pcBound2, pCaseSensitive)
		/* ... */

		#< @FunctionAlternativeForms

		def FindLastSubStringBoundedByCSIB(pcSubStr, pacBounds, pCaseSensitive)
			if isString(pacBounds)
				return This.FindLastSubStringBetweenCSIB(pcSubStr, pacBounds, pacBounds, pCaseSensitive)

			but isList(pacBounds) and Q(pacBounds).IsPairOfStrings()
				return TThis.FindLastSubStringBetweenCSIB(pcSubStr, pacBounds[1], pacBounds[2], pCaseSensitive)

			else
				StzRaise("Incorrect param type! pacBounds must be a string or pair of strings.")
			ok

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
		return This.FindLastSubStringBetweenCSIB(pcSubStr, pcBound1, pcBound2, :CaseSensitive = TRUE)

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
	  #  FINDING LAST OCCURRENCE OF A SUBSTRING BOUNDED BY TWO OTHER            #
	 #  SUBSTRINGS INCLUDING BOUNDS AND RETURNING THEIR POSITIONS AS SECTIONS  #
	#-------------------------------------------------------------------------#

	def FindLastSubStringBetweenCSIBZZ(pcSubStr, pcBound1, pcBound2, pCaseSensitive)
		/* ... */

		#< @FunctionAlternativeForms

		def FindLastSubStringBoundedByCSIBZZ(pcSubStr, pacBounds, pCaseSensitive)
			if isString(pacBounds)
				return This.FindLastSubStringBetweenCSIBZZ(pcSubStr, pcBounds, pcBounds, pCaseSensitive)

			but isList(pacBounds) and Q(pacBounds).IsPairOfStrings()
				return This.FindLastSubStringBetweenCSIBZZ(pcSubStr, pcBounds[1], pcBounds[2], pCaseSensitive)

			else
				StzRaise("Incorrect param type! pacBounds must be a string or pair of strings.")
			ok

		#--
	
		def FindLastSubStringBetweenAsSectionsCSIB(pcSubStr, pcBound1, pcBound2, pCaseSensitive)
			return This.FindLastSubStringBetweenCSIBZZ(pcSubStr, pcBound1, pcBound2, pCaseSensitive)

		def FindLastSubStringBoundedByAsSectionsCSIB(pcSubStr, pacBounds, pCaseSensitive)
			return This.FindLastSubStringBoundedByCSIBZZ(pcSubStr, pacBounds, pCaseSensitive)

		#==

		def LastSubStringBetweenCSIBZZ(pcSubStr, pcBound1, pcBound2, pCaseSensitive)
			return This.FindBetweenCSIBZZ(pcSubStr, pcBound1, pcBound2, pCaseSensitive)

		def LastSubStringBoundedByCSIBZZ(pcSubStr, pacBounds, pCaseSensitive)
			return This.FindLastSubStringBoundedByCSIBZZ(pcSubStr, pacBounds, pCaseSensitive)

		def LastSubStringBetweenAsSectionsCSIB(pcSubStr, pcBound1, pcBound2, pCaseSensitive)
			return This.FindLastSubStringBetweenCSIBZZ(pcSubStr, pcBound1, pcBound2, pCaseSensitive)

		def LastSubStringBoundedByAsSectionsCSIB(pcSubStr, pacBounds, pCaseSensitive)
			return This.FindLastSubStringBoundedByCSIBZZ(pcSubStr, pacBounds, pCaseSensitive)

		#>

	#-- WITHOUT CASESENSITIVITY

	def FindLastSubStringBetweenZZIB(pcSubStr, pcBound1, pcBound2)
		return This.FindLastSubStringBetweenCSIBZZ(pcSubStr, pcBound1, pcBound2, :CaseSensitive = TRUE)

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

		def LastSubStringBetweenIBZZ(pcSubStr, pcBound1, pcBound2)
			return This.FindLastSubStringBetweenIBZZ(pcSubStr, pcBound1, pcBound2)

		def LastSubStringBoundedByIBZZ(pcSubStr, pacBounds)
			return This.FindLastSubStringBoundedByIBZZ(pcSubStr, pacBounds)

		def LastSubStringBetweenAsSectionsIB(pcSubStr, pcBound1, pcBound2)
			return This.FindLastSubStringBetweenIBZZ(pcSubStr, pcBound1, pcBound2)

		def LastSubStringBoundedByAsSectionsIB(pcSubStr, pacBounds)
			return This.FindLastSubStringBoundedByIBZZ(pcSubStr, pacBounds)

		#>
		
	   #-----------------------------------------------------#
	  #  FINDING LAST OCCURRENCE OF A SUBSTRING BOUNDED BY  #
	 #  TWO OTHER SUBSTRINGS STARTING AT A GIVEN POSITION  #
	#-----------------------------------------------------#

	def FindLastSubStringBetweenSCS(pcSubStr, pcBound1, pcBound2, pnStartingAt, pCaseSensitive)
		/* ... */

		#< @FunctionalternativeForms

		def FindLastSubStringBoundedBySCS(pcSubStr, pacBounds, pnStartingAt, pCaseSensitive)
			if isString(pacBounds)
				return This.FindLastSubStringBetweenSCS(pcSubStr, pacBounds, pacBounds, pnStartingAt, pCaseSensitive)

			but isList(pacBounds) and Q(pacBounds).IsPairOfStrings()
				return This.FindLastSubStringBetweenSCS(pcSubStr, pacBounds[1], pacBounds[2], pnStartingAt, pCaseSensitive)

			else
				StzRaise("Incorrect param type! pacBounds must be a string or pair of strings.")
			ok

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

		def LastSubStringBetweenSCSZ(pcSubStr, pcBound1, pcBound2, pnStartingAt, pCaseSensitive)
			return This.FindLastSubStringBetweenSCS(pcSubStr, pcBound1, pcBound2, pnStartingAt, pCaseSensitive)

		def LastSubStringBoundedBySCSZ(pcSubStr, pacBounds, pnStartingAt, pCaseSensitive)
			return This.FindLastSubStringBoundedBySCS(pcSubStr, pacBounds, pnStartingAt, pCaseSensitive)

		#>

	#-- WITHOUT CASESENSITIVITY

	def FindLastSubStringBetweenS(pcSubStr, pcBound1, pcBound2, pnStartingAt)
		return This.FindLastSubStringBetweenSCS(pcSubStr, pcBound1, pcBound2, pnStartingAt, :CaseSensitive = TRUE)

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

		def LastSubStringBetweenSZ(pcSubStr, pcBound1, pcBound2, pnStartingAt)
			return This.FindLastSubStringBetweenS(pcSubStr, pcBound1, pcBound2, pnStartingAt)

		def LastSubStringBoundedBySZ(pcSubStr, pacBounds, pnStartingAt)
			return This.FindLastSubStringBoundedByS(pcSubStr, pacBounds, pnStartingAt)

		#>

	   #--------------------------------------------------------------------------#
	  #  FINDING LAST OCCURRENCE OF A SUBSTRING BOUNDED BY TWO OTHER SUBSTRINGS  #
	 #  STARTING AT A GIVEN POSITION AND RETURNING POSITIONS AS SECTIONS        #
	#--------------------------------------------------------------------------#

	def FindLastSubStringBetweenSCSZZ(pcSubStr, pcBound1, pcBound2, pnStartingAt, pCaseSensitive)
		/* ... */

		#< @FunctionAlternativeForms

		def FindLastSubStringBoundedBySCSZZ(pcSubStr, pacBounds, pnStartingAt, pCaseSensitive)
			if isString(pacBounds)
				return This.FindLastSubStringBetweenSCSZZ(pcSubStr, pacBounds, pacBounds, pnStartingAt, pCaseSensitive)

			but isList(pacBounds) and Q(pacBounds).isPairOfStrings()
				return This.FindLastSubStringBetweenSCSZZ(pcSubStr, pacBounds[1], pacBounds[2], pnStartingAt, pCaseSensitive)

			else
				StzRaise("Incorrect param type! pacBounds must be a string or pair of strings.")
			ok

		#--
	
		def FindLastSubStringBetweenAsSectionsSCS(pcSubStr, pcBound1, pcBound2, pnStartingAt, pCaseSensitive)
			return This.FindLastSubStringBetweenSCSZZ(pcSubStr, pcBound1, pcBound2, pnStartingAt, pCaseSensitive)

		def FindLastSubStringBoundedByAsSectionsSCS(pcSubStr, pacBounds, pnStartingAt, pCaseSensitive)
			return This.FindLastSubStringBoundedBySCSZZ(pcSubStr, pacBounds, pnStartingAt, pCaseSensitive)

		#==

		def LastSubStringBetweenSCSZZ(pcSubStr, pcBound1, pcBound2, pnStartingAt, pCaseSensitive)
			return This.FindLastSubStringBetweenSCSZZ(pcSubStr, pcBound1, pcBound2, pnStartingAt, pCaseSensitive)

		def LastSubStringBoundedBySCSZZ(pcSubStr, pacBounds, pnStartingAt, pCaseSensitive)
			return This.FindLastSubStringBoundedBySCSZZ(pcSubStr, pacBounds, pnStartingAt, pCaseSensitive)

		def LastSubStringBetweenAsSectionsSCS(pcSubStr, pcBound1, pcBound2, pnStartingAt, pCaseSensitive)
			return This.FindLastSubStringBetweenSCSZZ(pcSubStr, pcBound1, pcBound2, pnStartingAt, pCaseSensitive)

		def LastSubStringBoundedByAsSectionsSCS(pcSubStr, pacBounds, pnStartingAt, pCaseSensitive)
			return This.FindLastSubStringBoundedBySCSZZ(pcSubStr, pacBounds, pnStartingAt, pCaseSensitive)

		#>

	#--

	def FindLastSubStringBetweenSZZ(pcSubStr, pcBound1, pcBound2, pnStartingAt)
		return This.FindLastSubStringBetweenSCSZZ(pcSubStr, pcBound1, pcBound2, pnStartingAt, :CaseSensitive = TRUE)

		#< @FunctionAlternativeForms

		def FindLastSubStringBoundedBySZZ(pcSubStr, pacBounds, pnStartingAt)
			return This.FindLastSubStringBoundedBySZZ(pcSubStr, pacBounds, pnStartingAt)

		#--
	
		def FindLastSubStringBetweenAsSectionsS(pcSubStr, pcBound1, pcBound2, pnStartingAt)
			return This.FindLastSubStringBetweenSZZ(pcSubStr, pcBound1, pcBound2, pnStartingAt)

		def FindLastSubStringBoundedByAsSectionsS(pcSubStr, pacBounds, pnStartingAt)
			return This.FindLastSubStringBoundedBySZZ(pcSubStr, pacBounds, pnStartingAt)

		#==

		def LastSubStringBetweenSZZ(pcSubStr, pcBound1, pcBound2, pnStartingAt)
			return This.FindLastSubStringBetweenSZZ(pcSubStr, pcBound1, pcBound2, pnStartingAt)

		def LastSubStringBoundedBySZZ(pcSubStr, pacBounds, pnStartingAt)
			return This.FindLastSubStringBoundedBySZZ(pcSubStr, pacBounds, pnStartingAt)

		def LastSubStringBetweenAsSectionsS(pcSubStr, pcBound1, pcBound2, pnStartingAt)
			return This.FindLastSubStringBetweenSZZ(pcSubStr, pcBound1, pcBound2, pnStartingAt)

		def LastSubStringBoundedByAsSectionsS(pcSubStr, pacBounds, pnStartingAt)
			return This.FindLastSubStringBoundedBySZZ(pcSubStr, pacBounds, pnStartingAt)

		#>

	   #--------------------------------------------------------------#
	  #  FINDING LAST OCCURRENCE OF A SUBSTRING BOUNDED BY TWO OTHER  #
	 #  SUBSTRINGSSTARTING AT A GIVEN POSITION AND INCLUDING BOUNDS  #
	#---------------------------------------------------------------#

	def FindLastSubStringBetweenSCSIB(pcSubStr, pcBound1, pcBound2, pnStartingAt, pCaseSensitive)
		/* ... */

		#< @FunctionAlternativeForms

		def FindLastSubStringBoundedBySCSIB(pcSubStr, pacBounds, pnStartingAt, pCaseSensitive)
			if isString(pacBounds)
				return This.FindLastSubStringBetweenSCSIB(pcSubStr, pacBounds, pacBounds, pnStartingAt, pCaseSensitive)

			but isList(pacBounds) and Q(pacBounds).IsPairOfStrings()
				return This.FindLastSubStringBetweenSCSIB(pcSubStr, pacBounds[1], pacBounds[2], pnStartingAt, pCaseSensitive)

			else
				StzRaise("Incorrect param type! pacBounds must be a string or pair of strings.")
			ok

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

		def LastSubStringBetweenSCSIBZ(pcSubStr, pcBound1, pcBound2, pnStartingAt, pCaseSensitive)
			return This.FindLastSubStringBetweenSCSIB(pcSubStr, pcBound1, pcBound2, pnStartingAt, pCaseSensitive)

		def LastSubStringBoundedBySCSIBZ(pcSubStr, pacBounds, pnStartingAt, pCaseSensitive)
			return This.FindLastSubStringBoundedBySCSIB(pcSubStr, pacBounds, pnStartingAt, pCaseSensitive)

		#>

	#-- WITHOUT CASESENSITIVITY

	def FindLastSubStringBetweenSIB(pcSubStr, pcBound1, pcBound2, pnStartingAt)
		return This.FindLastSubStringBetweenSCSIB(pcSubStr, pcBound1, pcBound2, pnStartingAt, :CaseSensitive = TRUE)

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

		def LastSubStringBetweenSIBZ(pcSubStr, pcBound1, pcBound2, pnStartingAt)
			return This.FindLastSubStringBetweenSIB(pcSubStr, pcBound1, pcBound2, pnStartingAt)

		def LastSubStringBoundedBySIBZ(pcSubStr, pacBounds, pnStartingAt)
			return This.FindLastSubStringBoundedBySIB(pcSubStr, pacBounds, pnStartingAt)

		#>

	   #-----------------------------------------------------------------------------------#
	  #  FINDING LAST OCCURRENCE OF A SUBSTRING BOUNDED BY TWO OTHER SUBSTRINGS STARTING  #
	 #  AT A GIVEN POSITION, INCLUDING BOUNDS, AND RETURNING THE POSITIONS AS SECTIONS   #
	#-----------------------------------------------------------------------------------#

	def FindLastSubStringBetweenSCSIBZZ(pcSubStr, pcBound1, pcBound2, pnStartingAt, pCaseSensitive)
		/* ... */

		#< @FunctionAlternativeForms

		def FindLastSubStringBoundedBySCSIBZZ(pcSubStr, pacBounds, pnStartingAt, pCaseSensitive)
			if isString(pacBounds)
				return This.FindLastSubStringBetweenSCSIBZZ(pcSubStr, pacBounds, pacBounds, pnStartingAt, pCaseSensitive)

			but isList(pacBounds) and Q(pacBounds).IsPairOfStrings()
				return This.FindLastSubStringBetweenSCSIBZZ(pcSubStr, pacBounds[1], pacBounds[2], pnStartingAt, pCaseSensitive)

			else
				StzRaise("Incorrect param type! pacBounds must be string or pair of strings.")

			ok

		#--
	
		def FindLastSubStringBetweenAsSectionsSCSIB(pcSubStr, pcBound1, pcBound2, pnStartingAt, pCaseSensitive)
			return This.FindLastSubStringBetweenSCSIBZZ(pcSubStr, pcBound1, pcBound2, pnStartingAt, pCaseSensitive)

		def FindLastSubStringBoundedByAsSectionsSCSIB(pcSubStr, pacBounds, pnStartingAt, pCaseSensitive)
			return This.FindLastSubStringBoundedBySCSIBZZ(pcSubStr, pacBounds, pnStartingAt, pCaseSensitive)

		#==

		def LastSubStringBetweenSCSIBZZ(pcSubStr, pcBound1, pcBound2, pnStartingAt, pCaseSensitive)
			return This.FindLastSubStringBetweenSCSIBZZ(pcSubStr, pcBound1, pcBound2, pnStartingAt, pCaseSensitive)

		def LastSubStringBoundedBySCSIBZZ(pcSubStr, pacBounds, pnStartingAt, pCaseSensitive)
			return This.FindLastSubStringBoundedBySCSIBZZ(pcSubStr, pacBounds, pnStartingAt, pCaseSensitive)

		def LastSubStringBetweenAsSectionsSCSIB(pcSubStr, pcBound1, pcBound2, pnStartingAt, pCaseSensitive)
			return This.FindLastSubStringBetweenSIBCSZZ(pcSubStr, pcBound1, pcBound2, pnStartingAt, pCaseSensitive)

		def LastSubStringBoundedByAsSectionsSCSIB(pcSubStr, pacBounds, pnStartingAt, pCaseSensitive)
			return This.FindLastSubStringBoundedBySCSIBZZ(pcSubStr, pacBounds, pnStartingAt, pCaseSensitive)

		#>

	#-- WITHOUT CASESENSITIVITY

	def FindLastSubStringBetweenSIBZZ(pcSubStr, pcBound1, pcBound2, pnStartingAt)
		return This.FindLastSubStringBetweenSIBCSZZ(pcSubStr, pcBound1, pcBound2, pnStartingAt, :CaseSensitive = TRUE)

		#< @FunctionAlternativeForms

		def FindLastSubStringBoundedBySIBZZ(pcSubStr, pacBounds, pnStartingAt)
			return This.FindLastSubStringBoundedBySIBZZ(pcSubStr, pacBounds, pnStartingAt)

		#--
	
		def FindLastSubStringBetweenAsSectionsSIB(pcSubStr, pcBound1, pcBound2, pnStartingAt)
			return This.FindLastSubStringBetweenSIBZZ(pcSubStr, pcBound1, pcBound2, pnStartingAt)

		def FindLastSubStringBoundedByAsSectionsSIB(pcSubStr, pacBounds, pnStartingAt)
			return This.FindLastSubStringBoundedBySIBZZ(pcSubStr, pacBounds, pnStartingAt)

		#==

		def LastSubStringBetweenSIBZZ(pcSubStr, pcBound1, pcBound2, pnStartingAt)
			return This.FindLastSubStringBetweenSIBZZ(pcSubStr, pcBound1, pcBound2, pnStartingAt)

		def LastSubStringBoundedBySIBZZ(pcSubStr, pacBounds, pnStartingAt)
			return This.FindLastSubStringBoundedBySIBZZ(pcSubStr, pacBounds, pnStartingAt)

		def LastSubStringBetweenAsSectionsSIB(pcSubStr, pcBound1, pcBound2, pnStartingAt)
			return This.FindLastSubStringBetweenSIBZZ(pcSubStr, pcBound1, pcBound2, pnStartingAt)

		def LastSubStringBoundedByAsSectionsSIB(pcSubStr, pacBounds, pnStartingAt)
			return This.FindLastSubStringBoundedBySIBZZ(pcSubStr, pacBounds, pnStartingAt)

		#>

	   #-----------------------------------------------------#
	  #  FINDING LAST OCCURRENCE OF A SUBSTRING BOUNDED BY  #
	 #  TWO OTHER SUBSTRINGS GOING IN A GIVEN DIRECTION    #
	#-----------------------------------------------------#

	def FindLastSubStringBetweenDCS(pcSubStr, pcBound1, pcBound2, pcDirection, pCaseSensitive)
		/* ... */

		#< @FunctionAlternativeForms

		def FindLastSubStringBoundedByDCS(pcSubStr, pacBounds, pcDirection, pCaseSensitive)
			if isString(pacBounds)
				return This.FindLastSubStringBetweenDCS(pcSubStr, pacBounds, pacBounds, pcDirection, pCaseSensitive)

			but isList(pacBounds) and Q(pacBounds).IsPairOfStrings()
				return This.FindLastSubStringBetweenDCS(pcSubStr, pacBounds[1], pacBounds[2], pcDirection, pCaseSensitive)

			else
				StzRaise("Incorrect param type! pacBounds must be a string or pair of strings.")
			ok

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

		def LastSubStringBetweenDCSZ(pcSubStr, pcBound1, pcBound2, pcDirection, pCaseSensitive)
			return This.FindLastSubStringBetweenDCS(pcSubStr, pcBound1, pcBound2, pcDirection, pCaseSensitive)

		def LastSubStringBoundedByDCSZ(pcSubStr, pacBounds, pcDirection, pCaseSensitive)
			return This.FindLastSubStringBoundedByDCS(pcSubStr, pacBounds, pcDirection, pCaseSensitive)

		#>

	#-- WITHOUT CASESENSITIVITY

	def FindLastSubStringBetweenD(pcSubStr, pcBound1, pcBound2, pcDirection)
		return This.FindLastSubStringBetweenDCS(pcSubStr, pcBound1, pcBound2, pcDirection, :CaseSensitive = TRUE)

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

		def LastSubStringBetweenDZ(pcSubStr, pcBound1, pcBound2, pcDirection)
			return This.FindLastSubStringBetweenD(pcSubStr, pcBound1, pcBound2, pcDirection)

		def LastSubStringBoundedByDZ(pcSubStr, pacBounds, pcDirection)
			return This.FindLastSubStringBoundedByD(pcSubStr, pacBounds, pcDirection)

		#>

	   #--------------------------------------------------------------------------#
	  #  FINDING LAST OCCURRENCE OF A SUBSTRING BOUNDED BY TWO OTHER SUBSTRINGS  #
	 #  GOING INA GIVEN DIRECTION AND RETURNING POSITIONS AS SECTIONS           #
	#--------------------------------------------------------------------------#

	def FindLastSubStringBetweenDCSZZ(pcSubStr, pcBound1, pcBound2, pcDirection, pCaseSensitive)
		/* ... */

		#< @FunctionAlternativeForms

		def FindLastSubStringBoundedByDCSZZ(pcSubStr, pacBounds, pcDirection, pCaseSensitive)
			if isString(pacBounds)
				return This.FindLastSubStringBetweenDCSZZ(pcSubStr, pacBounds, pacBounds, pcDirection, pCaseSensitive)

			but isList(pacBounds) and Q(pacBounds).IsPairOfNumbers()
				return This.FindLastSubStringBetweenDCSZZ(pcSubStr, pacBounds[1], pacBounds[2], pcDirection, pCaseSensitive)

			else
				StzRaise("Incorrect param type! pacBounds must be a string or pair of strings.")

			ok

		#--
	
		def FindLastSubStringBetweenAsSectionsDCS(pcSubStr, pcBound1, pcBound2, pcDirection, pCaseSensitive)
			return This.FindLastSubStringBetweenDCSZZ(pcSubStr, pcBound1, pcBound2, pcDirection, pCaseSensitive)

		def FindLastSubStringBoundedByAsSectionsDCS(pcSubStr, pacBounds, pcDirection, pCaseSensitive)
			return This.FindLastSubStringBoundedByDCSZZ(pcSubStr, pacBounds, pcDirection, pCaseSensitive)

		#==

		def LastSubStringBetweenDCSZZ(pcSubStr, pcBound1, pcBound2, pcDirection, pCaseSensitive)
			return This.FindLastSubStringBetweenDCSZZ(pcSubStr, pcBound1, pcBound2, pcDirection, pCaseSensitive)

		def LastSubStringBoundedByDCSZZ(pcSubStr, pacBounds, pcDirection, pCaseSensitive)
			return This.FindLastSubStringBoundedByDCSZZ(pcSubStr, pacBounds, pcDirection, pCaseSensitive)

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

		def LastSubStringBetweenDZZ(pcSubStr, pcBound1, pcBound2, pcDirection)
			return This.FindLastSubStringBetweenDZZ(pcSubStr, pcBound1, pcBound2, pcDirection)

		def LastSubStringBoundedByDZZ(pcSubStr, pacBounds, pcDirection)
			return This.FindLastSubStringBoundedByDZZ(pcSubStr, pacBounds, pcDirection)

		def LastSubStringBetweenAsSectionsD(pcSubStr, pcBound1, pcBound2, pcDirection)
			return This.FindLastSubStringBetweenDZZ(pcSubStr, pcBound1, pcBound2, pcDirection)

		def LastSubStringBoundedByAsSectionsD(pcSubStr, pacBounds, pcDirection)
			return This.FindLastSubStringBoundedByDZZ(pcSubStr, pacBounds, pcDirection)

		#>

	   #---------------------------------------------------------------#
	  #  FINDING LAST OCCURRENCE OF A SUBSTRING BOUNDED BY TWO OTHER  #
	 #  SUBSTRINGS GOING IN A GIVEN DIRECTION AND INCLUDING BOUNDS   #
	#---------------------------------------------------------------#

	def FindLastSubStringBetweenDCSIB(pcSubStr, pcBound1, pcBound2, pcDirection, pCaseSensitive)
		/* ... */

		#< @FunctionAlternativeForms

		def FindLastSubStringBoundedByDCSIB(pcSubStr, pacBounds, pcDirection, pCaseSensitive)
			if isString(pacBounds)
				return This.FindLastSubStringBetweenDCSIB(pcSubStr, pacBounds, pacBounds, pcDirection, pCaseSensitive)

			but isList(pacBounds) and Q(pacBounds).IsPairOfStrings()
				return This.FindLastSubStringBetweenDCSIB(pcSubStr, pacBounds[1], pacBounds[2], pcDirection, pCaseSensitive)

			else
				StzRaise("Incorrect param type! pacBounds must be a string or pair of strings.")
			ok

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

		def LastSubStringBetweenDCSIBZ(pcSubStr, pcBound1, pcBound2, pcDirection, pCaseSensitive)
			return This.FindLastSubStringBetweenDCSIB(pcSubStr, pcBound1, pcBound2, pcDirection, pCaseSensitive)

		def LastSubStringBoundedByDCSIBZ(pcSubStr, pacBounds, pcDirection, pCaseSensitive)
			return This.FindLastSubStringBoundedByDCSIB(pcSubStr, pacBounds, pcDirection, pCaseSensitive)

		#>

	#-- WITHOUT CASESENSITIVITY

	def FindLastSubStringBetweenDIB(pcSubStr, pcBound1, pcBound2, pcDirection)
		return This.FindLastSubStringBetweenDCSIB(pcSubStr, pcBound1, pcBound2, pcDirection, :CaseSensitive = TRUE)

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

		def LastSubStringBetweenDIBZ(pcSubStr, pcBound1, pcBound2, pcDirection)
			return This.FindLastSubStringBetweenDIB(pcSubStr, pcBound1, pcBound2, pcDirection)

		def LastSubStringBoundedByDIBZ(pcSubStr, pacBounds, pcDirection)
			return This.FindLastSubStringBoundedByDIB(pcSubStr, pacBounds, pcDirection)

		#>

	   #--------------------------------------------------------------------------------#
	  #  FINDING LAST OCCURRENCE OF A SUBSTRING BOUNDED BY TWO OTHER SUBSTRINGS GOING  #
	 #  IN A GIVENDIRECTION, INCLUDING BOUNDS, AND RETURNING POSITIONS AS SECTIONS    # 
	#--------------------------------------------------------------------------------#

	def FindLastSubStringBetweenDCSIBZZ(pcSubStr, pcBound1, pcBound2, pcDirection, pCaseSensitive)
		/* ... */

		#< @FunctionAlternativeForms

		def FindLastSubStringBoundedByDCSIBZZ(pcSubStr, pacBounds, pcDirection, pCaseSensitive)
			if isString(pacBounds)
				return This.FindLastSubStringBetweenDCSIBZZ(pcSubStr, pacBounds, pacBounds, pcDirection, pCaseSensitive)

			but isList(pacBounds) and Q(pacBounds).IsPairOfNumbers()
				return This.FindLastSubStringBetweenDCSIBZZ(pcSubStr, pacBounds[1], pacBounds[2], pcDirection, pCaseSensitive)

			else
				StzRaise("Incorrect param type! pacBounds must be a string or pair of strings.")

			ok

		#--
	
		def FindLastSubStringBetweenAsSectionsDCSIB(pcSubStr, pcBound1, pcBound2, pcDirection, pCaseSensitive)
			return This.FindLastSubStringBetweenDCSIBZZ(pcSubStr, pcBound1, pcBound2, pcDirection, pCaseSensitive)

		def FindLastSubStringBoundedByAsSectionsDCSIB(pcSubStr, pacBounds, pcDirection, pCaseSensitive)
			return This.FindBoundedByDCSIBZZ(pcSubStr, pacBounds, pcDirection, pCaseSensitive)

		#==

		def LastSubStringBetweenDCSIBZZ(pcSubStr, pcBound1, pcBound2, pcDirection, pCaseSensitive)
			return This.FindLastSubStringBetweenDCSIBZZ(pcSubStr, pcBound1, pcBound2, pcDirection, pCaseSensitive)

		def LastSubStringBoundedByDCSIBZZ(pcSubStr, pacBounds, pcDirection, pCaseSensitive)
			return This.FindLastSubStringBoundedByDCSIBZZ(pcSubStr, pacBounds, pcDirection, pCaseSensitive)

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

		def LastSubStringBetweenDIBZZ(pcSubStr, pcBound1, pcBound2, pcDirection)
			return This.FindLastSubStringBetweenDIBZZ(pcSubStr, pcBound1, pcBound2, pcDirection)

		def LastSubStringBoundedByDIBZZ(pcSubStr, pacBounds, pcDirection)
			return This.FindLastSubStringBoundedByDIBZZ(pcSubStr, pacBounds, pcDirection)

		def LastSubStringBetweenAsSectionsDIB(pcSubStr, pcBound1, pcBound2, pcDirection)
			return This.FindLastSubStringBetweenDIBZZ(pcSubStr, pcBound1, pcBound2, pcDirection)

		def LastSubStringBoundedByAsSectionsDIB(pcSubStr, pacBounds, pcDirection)
			return This.FindLastSubStringBoundedByDIBZZ(pcSubStr, pacBounds, pcDirection)

		#>

	   #--------------------------------------------------------------------------#
	  #  FINDING LAST OCCURRENCE OF A SUBSTRING BOUNDED BY TWO OTHER SUBSTRINGS  #
	 #  STARTING AT A GIVEN POSITION AND GOING IN A GIVEN DIRECTION             #
	#--------------------------------------------------------------------------#

	def FindLastSubStringBetweenSDCS(pcSubStr, pcBound1, pcBound2, pnStartingAt, pcDirection, pCaseSensitive)
		/* ... */

		#< @FunctionAlternativeForms

		def FindLastSubStringBoundedBySDCS(pcSubStr, pacBounds, pnStartingAt, pcDirection, pCaseSensitive)
			if isString(pacBounds)
				return This.FindLastSubStringBetweenSDCS(pcSubStr, pacBounds, pacBounds, pnStartingAt, pcDirection, pCaseSensitive)

			but isLsit(pacBounds) and Q(pacBounds).IsPairOfStrings()
				return This.FindLastSubStringBetweenSDCS(pcSubStr, pacBounds[1], pacBounds[2], pnStartingAt, pcDirection, pCaseSensitive)

			else
				StzRaise("Incorrect param type! pacBounds must be a string or pair of strings.")

			ok

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

		def LastSubStringBetweenSDCSZ(pcSubStr, pcBound1, pcBound2, pnStartingAt, pcDirection, pCaseSensitive)
			return This.FindLastSubStringBetweenSDCS(pcSubStr, pcBound1, pcBound2, pnStartingAt, pcDirection, pCaseSensitive)

		def LastSubStringBoundedBySDCSZ(pcSubStr, pacBounds, pnStartingAt, pcDirection, pCaseSensitive)
			return This.FindLastSubStringBoundedBySDCS(pcSubStr, pacBounds, pnStartingAt, pcDirection, pCaseSensitive)

		#>

	#-- WITHOUT CASESENSITIVITY

	def FindLastSubStringBetweenSD(pcSubStr, pcBound1, pcBound2, pnStartingAt, pcDirection)
		return This.FindLastSubStringBetweenSDCS(pcSubStr, pcBound1, pcBound2,pnStartingAt, pcDirection, :CaseSensitive = TRUE)

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

		def LastSubStringBetweenSDZ(pcSubStr, pcBound1, pcBound2, pnStartingAt, pcDirection)
			return This.FindLastSubStringBetweenSD(pcSubStr, pcBound1, pcBound2, pnStartingAt, pcDirection)

		def LastSubStringBoundedBySDZ(pcSubStr, pacBounds, pnStartingAt, pcDirection)
			return This.FindLastSubStringBoundedBySD(pcSubStr, pacBounds, pnStartingAt, pcDirection)

		#>

	   #----------------------------------------------------------------------------------------#
	  #  FINDING LAST OCCURRENCE OF A SUBSTRING BOUNDED BY TWO OTHER SUBSTRINGSS STARTING      #
	 #  AT A GIVEN POSITION, GOING IN A GIVEN DIRECTION, AND RETURNING POSITIONS AS SECTIONS  #
	#----------------------------------------------------------------------------------------#

	def FindLastSubStringBetweenSDCSZZ(pcSubStr, pcBound1, pcBound2, pnStartingAt, pcDirection, pCaseSensitive)
		/* ... */

		#< @FunctionAlternativeForms

		def FindLastSubStringBoundedBySDCSZZ(pcSubStr, pacBounds, pnStartingAt, pcDirection, pCaseSensitive)
			return This.FindBoundedBySDCSZZ(pcSubStr, pacBounds, pnStartingAt, pcDirection, pCaseSensitive)

		#--
	
		def FindLastSubStringBetweenAsSectionsSDCS(pcSubStr, pcBound1, pcBound2, pnStartingAt, pcDirection, pCaseSensitive)
			return This.FindLastSubStringBetweenSDCSZZ(pcSubStr, pcBound1, pcBound2, pnStartingAt, pcDirection, pCaseSensitive)

		def FindLastSubStringBoundedByAsSectionsSDCS(pcSubStr, pacBounds, pnStartingAt, pcDirection, pCaseSensitive)
			return This.FindLastSubStringBoundedBySDCSZZ(pcSubStr, pacBounds, pnStartingAt, pcDirection, pCaseSensitive)

		#==

		def LastSubStringBoundedBySDCSZZ(pcSubStr, pacBounds, pnStartingAt, pcDirection, pCaseSensitive)
			return This.FindLastSubStringBoundedBySDCSZZ(pcSubStr, pacBounds, pnStartingAt, pcDirection, pCaseSensitive)

		def LastSubStringBoundedByAsSectionsSDCS(pcSubStr, pacBounds, pnStartingAt, pcDirection, pCaseSensitive)
			return This.FindLastSubStringBoundedBySDCSZZ(pcSubStr, pacBounds, pnStartingAt, pcDirection, pCaseSensitive)

		#>

	#-- WITHOUT CASESENSITIVITY

	def FindLastSubStringBetweenSDZZ(pcSubStr, pcBound1, pcBound2, pnStartingAt, pcDirection)
		return This.FindLastSubStringBetweenSDCSZZ(pcSubStr, pcBound1, pcBound2, pnStartingAt, pcDirection, :CaseSensitive = TRUE)

		#< @FunctionAlternativeForms

		def FindLastSubStringBoundedBySDZZ(pcSubStr, pacBounds, pnStartingAt, pcDirection)
			return This.FindBoundedBySDZZ(pcSubStr, pacBounds, pnStartingAt, pcDirection)

		#--
	
		def FindLastSubStringBetweenAsSectionsSD(pcSubStr, pcBound1, pcBound2, pnStartingAt, pcDirection)
			return This.FindLastSubStringBetweenSDZZ(pcSubStr, pcBound1, pcBound2, pnStartingAt, pcDirection)

		def FindLastSubStringBoundedByAsSectionsSD(pcSubStr, pacBounds, pnStartingAt, pcDirection)
			return This.FindLastSubStringBoundedBySDZZ(pcSubStr, pacBounds, pnStartingAt, pcDirection)

		#==

		def LastSubStringBetweenSDZZ(pcSubStr, pcBound1, pcBound2, pnStartingAt, pcDirection)
			return This.FindLastSubStringBetweenSDZZ(pcSubStr, pcBound1, pcBound2, pnStartingAt, pcDirection)

		def LastSubStringBoundedBySDZZ(pcSubStr, pacBounds, pnStartingAt, pcDirection)
			return This.FindLastSubStringBoundedBySDZZ(pcSubStr, pacBounds, pnStartingAt, pcDirection)

		def LastSubStringBetweenAsSectionsSD(pcSubStr, pcBound1, pcBound2, pnStartingAt, pcDirection)
			return This.FindLastSubStringBetweenSDZZ(pcSubStr, pcBound1, pcBound2, pnStartingAt, pcDirection)

		def LastSubStringBoundedByAsSectionsSD(pcSubStr, pacBounds, pnStartingAt, pcDirection)
			return This.FindLastSubStringBoundedBySDZZ(pcSubStr, pacBounds, pnStartingAt, pcDirection)

		#>

	   #-----------------------------------------------------------------------------------#
	  #  FINDING LAST OCCURRENCE OF A SUBSTRING BOUNDED BY TWO OTHER SUBSTRINGSS STARTING #
	 #  AT A GIVEN POSITION, GOING IN A GIVEN DIRECTION, AND INCLUDING BOUNDS            #
	#-----------------------------------------------------------------------------------#

	def FindLastSubStringBetweenSDCSIB(pcSubStr, pcBound1, pcBound2, pnStartingAt, pcDirection, pCaseSensitive)
		/* ... */

		#< @FunctionAlternativeForms

		def FindLastSubStringBoundedBySDCSIB(pcSubStr, pacBounds, pnStartingAt, pcDirection, pCaseSensitive)
			if isString(pacBounds)
				return This.FindLastSubStringBetweenSDCSIB(pcSubStr, pacBounds, pacBounds, pnStartingAt, pcDirection, pCaseSensitive)

			but isLsit(pacBounds) and Q(pacBounds).IsPairOfStrings()
				return This.FindLastSubStringBetweenSDCSIB(pcSubStr, pacBounds[1], pacBounds[2], pnStartingAt, pcDirection, pCaseSensitive)

			else
				StzRaise("Incorrect param type! pacBounds must be a string or pair of strings.")

			ok

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

		def LastSubStringBetweenSDCSIBZ(pcSubStr, pcBound1, pcBound2, pnStartingAt, pcDirection, pCaseSensitive)
			return This.FindLastSubStringBetweenSDCSIB(pcSubStr, pcBound1, pcBound2, pnStartingAt, pcDirection, pCaseSensitive)

		def LastSubStringBoundedBySDCSIBZ(pcSubStr, pacBounds, pnStartingAt, pcDirection, pCaseSensitive)
			return This.FindLastSubStringBoundedBySDCSIB(pcSubStr, pacBounds, pnStartingAt, pcDirection, pCaseSensitive)

		#>

	#-- WITHOUT CASESENSITIVITY

	def FindLastSubStringBetweenSDIB(pcSubStr, pcBound1, pcBound2, pnStartingAt, pcDirection)
		return This.FindLastSubStringBetweenSDCSIB(pcSubStr, pcBound1, pcBound2,pnStartingAt, pcDirection, :CaseSensitive = TRUE)

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

		def LastSubStringBetweenSDIBZ(pcSubStr, pcBound1, pcBound2, pnStartingAt, pcDirection)
			return This.FindLastSubStringBetweenSDIB(pcSubStr, pcBound1, pcBound2, pnStartingAt, pcDirection)

		def LastSubStringBoundedBySDIBZ(pcSubStr, pacBounds, pnStartingAt, pcDirection)
			return This.FindLastSubStringBoundedBySDIB(pcSubStr, pacBounds, pnStartingAt, pcDirection)

		#>

	   #-----------------------------------------------------------------------------------------------#
	  #  FINDING LAST OCCURRENCE OF A SUBSTRING BOUNDED BY TWO OTHER SUBSTRINGSS STARTING AT A GIVEN  #
	 #  POSITION, GOING IN A GIVEN DIRECTION, INCLUDING BOUNDS, AND RETURNING POSITIONS AS SECTIONS  #
	#-----------------------------------------------------------------------------------------------#

	def FindLastSubStringBetweenSDCSIBZZ(pcSubStr, pcBound1, pcBound2, pnStartingAt, pcDirection, pCaseSensitive)
		/* ... */

		#< @FunctionAlternativeForms

		def FindLastSubStringBoundedBySDCSIBZZ(pcSubStr, pacBounds, pnStartingAt, pcDirection, pCaseSensitive)
			return This.FindLastSubStringBoundedBySDCSIBZZ(pcSubStr, pacBounds, pnStartingAt, pcDirection, pCaseSensitive)

		#--
	
		def FindLastSubStringBetweenAsSectionsSDCSIB(pcSubStr, pcBound1, pcBound2, pnStartingAt, pcDirection, pCaseSensitive)
			return This.FindLastSubStringBetweenSDCSIBZZ(pcSubStr, pcBound1, pcBound2, pnStartingAt, pcDirection, pCaseSensitive)

		def FindLastSubStringBoundedByAsSectionsSDCSIB(pcSubStr, pacBounds, pnStartingAt, pcDirection, pCaseSensitive)
			return This.FindLastSubStringBoundedBySDCSIBZZ(pcSubStr, pacBounds, pnStartingAt, pcDirection, pCaseSensitive)

		#==

		def LastSubStringBetweenSDCSIBZZ(pcSubStr, pcBound1, pcBound2, pnStartingAt, pcDirection, pCaseSensitive)
			return This.FindLastSubStringBetweenSDCSIBZZ(pcSubStr, pcBound1, pcBound2, pnStartingAt, pcDirection, pCaseSensitive)

		def LastSubStringBoundedBySDCSIBZZ(pcSubStr, pacBounds, pnStartingAt, pcDirection, pCaseSensitive)
			return This.FindLastSubStringBoundedBySDCSIBZZ(pcSubStr, pacBounds, pnStartingAt, pcDirection, pCaseSensitive)

		def LastSubStringBetweenAsSectionsSDCSIB(pcSubStr, pcBound1, pcBound2, pnStartingAt, pcDirection, pCaseSensitive)
			return This.FindLastSubStringBetweenSDCSIBZZ(pcSubStr, pcBound1, pcBound2, pnStartingAt, pcDirection, pCaseSensitive)

		def LastSubStringBoundedByAsSectionsSDCSIB(pcSubStr, pacBounds, pnStartingAt, pcDirection, pCaseSensitive)
			return This.FindLastSubStringBoundedBySDCSIBZZ(pcSubStr, pacBounds, pnStartingAt, pcDirection, pCaseSensitive)

		#>

	#-- WITHOUT CASESENSITIVITY

	def FindLastSubStringBetweenSDIBZZ(pcSubStr, pcBound1, pcBound2, pnStartingAt, pcDirection)
		return This.FindLastSubStringBetweenSDCSIBZZ(pcSubStr, pcBound1, pcBound2, pnStartingAt, pcDirection, :CaseSensitive = TRUE)

		#< @FunctionAlternativeForms

		def FindLastSubStringBoundedBySDIBZZ(pcSubStr, pacBounds, pnStartingAt, pcDirection)
			return This.FindLastSubStringBoundedBySDIBZZ(pcSubStr, pacBounds, pnStartingAt, pcDirection)

		#--
	
		def FindLastSubStringBetweenAsSectionsSDIB(pcSubStr, pcBound1, pcBound2, pnStartingAt, pcDirection)
			return This.FindLastSubStringBetweenSDIBZZ(pcSubStr, pcBound1, pcBound2, pnStartingAt, pcDirection)

		def FindLastSubStringBoundedByAsSectionsSDIB(pcSubStr, pacBounds, pnStartingAt, pcDirection)
			return This.FindLastSubStringBoundedBySDIBZZ(pcSubStr, pacBounds, pnStartingAt, pcDirection)

		#==

		def LastSubStringBetweenSDIBZZ(pcSubStr, pcBound1, pcBound2, pnStartingAt, pcDirection)
			return This.FindLastSubStringBetweenSDIBZZ(pcSubStr, pcBound1, pcBound2, pnStartingAt, pcDirection)

		def LastSubStringBoundedBySDIBZZ(pcSubStr, pacBounds, pnStartingAt, pcDirection)
			return This.FindLastSubStringBoundedBySDIBZZ(pcSubStr, pacBounds, pnStartingAt, pcDirection)

		def LastSubStringBetweenAsSectionsSDIB(pcSubStr, pcBound1, pcBound2, pnStartingAt, pcDirection)
			return This.FindLastSubStringBetweenSDIBZZ(pcSubStr, pcBound1, pcBound2, pnStartingAt, pcDirection)

		def LastSubStringBoundedByAsSectionsSDIB(pcSubStr, pacBounds, pnStartingAt, pcDirection)
			return This.FindLastSubStringBoundedBySDIBZZ(pcSubStr, pacBounds, pnStartingAt, pcDirection)

		#>

