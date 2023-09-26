
#============= A GIVEN SUBSTRING SubStringBetween

	  #============================================================================#
	 #  CHECKING IF THE STRING CONTAINS A SBISTRING BETWEEN TWO OTHER SubString  #
	#============================================================================#

	def ContainsSubStringBetweenCS(pcSubStr, pcBound1, pcBound2, pCaseSensitive)
		/* ... */

		#< @FunctionAlternativeForms

		def ContainsSubStringBoundedByCS(pcSubStr, pacBounds, pCaseSensitive)
			return This.ContainsSubStringBetweenCS(pcSubStr, pcBound1, pcBound2, pCaseSensitive)

		def ContainsBetweenCS(pcSubStr, pcBound1, pcBound2, pCaseSensitive)
			return This.ContainsSubStringBetweenCS(pcSubStr, pcBound1, pcBound2, pCaseSensitive)

		def ContainsBoundedByCS(pcSubStr, pacBounds, pCaseSensitive)
			return This.ContainsSubStringBetweenCS(pcSubStr, pcBound1, pcBound2, pCaseSensitive)

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
			return This.ContainsSubStringBetween(pcSubStr, pcBound1, pcBound2)

		#>

	   #------------------------------------------------------------#
	  #  CHECKING IF THE STRING CONTAINS A SBISTRING BETWEEN TWO   #
	 #  OTHER SubString STARTING AT A GIVEN POSITION             #
	#------------------------------------------------------------#

	def ContainsSubStringBetweenS(pcSubStr, pcBound1, pcBound2, pnStartingAt)
		def ContainsSubStringBoundedByS(pcSubStr, pacBounds, pnStartingAt)

	  #------------------------------------------------------------------------------------#
	 #  GETTING THE NUMBER OF OCCURRENCES OF A SUBSTRING BOUBDED BY TWO OTHER SubString  #
	#------------------------------------------------------------------------------------#

	def NumberOfOccurrenceBetween(pcSubStr, pcBound1, pcBound2)
		def NumberOfOccurrenceBoundedBy(pcSubStr, pacBounds)
	
		def NumberOfOccurrenceOfSubStringBetween(pcSubStr, pcBound1, pcBound2)
		def NumberOfOccurrenceOfSubStringBoundedBy(pcSubStr, pacBounds)
	
		#-- Occurrences (with s)
	
		def NumberOfOccurrencesBetween(pcSubStr, pcBound1, pcBound2)
		def NumberOfOccurrencesBoundedBy(pcSubStr, pacBounds)
		def NumberOfOccurrencesOfSubStringBetween(pcSubStr, pcBound1, pcBound2)
		def NumberOfOccurrencesOfSubStringBoundedBy(pcSubStr, pacBounds)

	   #---------------------------------------------------------------#
	  #  GETTING THE NUMBER OF OCCURRENCES OF A SUBSTRING BOUBDED BY  #
	 #  TWO OTHER SubString STARTING AT A GIVEN POSITION            #
	#---------------------------------------------------------------#

	def NumberOfSubStringBetweenS(pcSubStr, pcBound1, pcBound2, pnstartingAt)
		def NumberOfOccurrenceBoundedByS(pcSubStr, pacBounds, pnstartingAt)
	
		def NumberOfOccurrenceOfSubStringBetweenS(pcSubStr, pcBound1, pcBound2, pnstartingAt)
		def NumberOfOccurrenceOfSubStringBoundedByS(pcSubStr, pacBounds, pnstartingAt)
	
		#-- Occurrences (with s)
	
		def NumberOfOccurrencesBetweenS(pcSubStr, pcBound1, pcBound2, pnStartingAt)
		def NumberOfOccurrencesBoundedByS(pcSubStr, pacBounds, pnstartingAt)
		def NumberOfOccurrencesOfSubStringBetweenS(pcSubStr, pcBound1, pcBound2, pnstartingAt)
		def NumberOfOccurrencesOfSubStringBoundedByS(pcSubStr, pacBounds, pnstartingAt)
	
	   #----------------------------------------------------------------------#
	  #  CHECKING IF THE STRING CONTAINS N OCCURRENCES OF A GIVEN SUBSTRING  #
	 #  BOUNDED BY TWO OTHER SubString                                     #
	#----------------------------------------------------------------------#

	def ContainsNOccurrencesOfSubStringBetween(n, pcBound1, pcBound2)
		def ContainsNOccurrencesOfSubStringBoundedBy(n, pacBounds)

	   #-----------------------------------------------------------------------#
	  #  CHECKING IF THE STRING CONTAINS N OCCURRENCES OF A GIVEN SUBSTRING   #
	 #  BOUNDED BY TWO OTHER SubString STARTING AT A GIVEN POSITION         #
	#-----------------------------------------------------------------------#

	def ContainsNOccurrencesOfSubStringBetweenS(n, pcBound1, pcBound2, pnStartingAt)
		def ContainsNOccurrencesOfSubStringBoundedByS(n, pacBounds, pnStartingAt)
	
#=====

	  #======================================================================#
	 #  FINDING OCCURRENCES OF A SUBSTRING BOUNDED BY TWO OTHER SubString  #
	#======================================================================#

	def FindBetween(pcSubStr, pcBound1, pcBound2)
		def FindSubStringBetween(pcSubStr, pcBound1, pcBound2)
		def FindBoundedBy(pcSubStr, pacBounds)
		def FindSubStringBoundedBy(pcSubStr, pacBounds)
	
		#--
	
		def FindBetweenZ(pcSubStr, pcBound1, pcBound2)
		def FindSubStringBetweenZ(pcSubStr, pcBound1, pcBound2)
		def FindBoundedByZ(pcSubStr, pacBounds)
		def FindSubStringBoundedByZ(pcSubStr, pacBounds)

		#==

		def SubStringBetween(pcSubStr, pcBound1, pcBound2)
		def SubstringBoundedBy(pcSubStr, pacBounds)
	
		def SubStringBetweenZ(pcSubStr, pcBound1, pcBound2)
		def SubStringBoundedByZ(pcSubStr, pacBounds)


	   #-------------------------------------------------------#
	  #  FINDING A SUBSTRING BOUNDED BY TWO OTHER SubString  #
	 #  AND RETURNING THEM AS SECTIONS                       #
	#-------------------------------------------------------#

	def FindBetweenZZ(pcSubStr, pcBound1, pcBound2)
		def FindSubStringBetweenZZ(pcSubStr, pcBound1, pcBound2)
		def FindBoundedByZZ(pcSubStr, pacBounds)
		def FindSubStringBoundedByZZ(pcSubStr, pacBounds)
	
		#--
	
		def FindBetweenAsSections(pcSubStr, pcBound1, pcBound2)
		def FindSubStringBetweenAsSections(pcSubStr, pcBound1, pcBound2)
		def FindBoundedByAsSections(pcSubStr, pacBounds)
		def FindSubStringBoundedByAsSections(pcSubStr, pacBounds)

		#==

		def SubStringBetweenZZ(pcSubStr, pcBound1, pcBound2)
		def SubStringBoundedByZZ(pcSubStr, pacBounds)

		def SubStringBetweenAsSections(pcSubStr, pcBound1, pcBound2)
		def SubStringBoundedByAsSections(pcSubStr, pacBounds)


	  #------------------------------------------------------------------------#
	 #  FINDING A SUBSTRING BOUNDED BY TWO OTHER SubString INCLUDING BOUNDS  #
	#------------------------------------------------------------------------#

	def FindBetweenIB(pcSubStr, pcBound1, pcBound2)
		def FindSubStringBetweenIB(pcSubStr, pcBound1, pcBound2)
		def FindBoundedByIB(pcSubStr, pacBounds)
		def FindSubStringBoundedByIB(pcSubStr, pacBounds)
	
		#--
	
		def FindBetweenIBZ(pcSubStr, pcBound1, pcBound2)
		def FindSubStringBetweenIBZ(pcSubStr, pcBound1, pcBound2)
		def FindBoundedByIBZ(pcSubStr, pacBounds)
		def FindSubStringBoundedByIBZ(pcSubStr, pacBounds)

		#==

		def SubStringBetweenIB(pcSubStr, pcBound1, pcBound2)
		def SubStringBoundedByIB(pcSubStr, pacBounds)

		def SubStringBetweenIBZ(pcSubStr, pcBound1, pcBound2)
		def SubStringBoundedByIBZ(pcSubStr, pacBounds)

	   #---------------------------------------------------------------#
	  #  FINDING A SUBSTRING BOUNDED BY TWO OTHER SubString          #
	 #  INCLUDING BOUNDS AND RETURNING THEIR POSITIONS AS SECTIONS   #                                    #
	#---------------------------------------------------------------#

	def FindBetweenIBZZ(pcSubStr, pcBound1, pcBound2)
		def FindSubStringBetweenIBZZ(pcSubStr, pcBound1, pcBound2)
		def FindBoundedByIBZZ(pcSubStr, pacBounds)
		def FindSubStringBoundedByIBZZ(pcSubStr, pacBounds)
	
		#--
	
		def FindBetweenAsSectionsIB(pcSubStr, pcBound1, pcBound2)
		def FindSubStringBetweenAsSectionsIB(pcSubStr, pcBound1, pcBound2)
		def FindBoundedByAsSectionsIB(pcSubStr, pacBounds)
		def FindSubStringBoundedByAsSectionsIB(pcSubStr, pacBounds)

		#==

		def SubStringBetweenIBZZ(pcSubStr, pcBound1, pcBound2)
		def SubStringBoundedByIBZZ(pcSubStr, pacBounds)

		def SubStringBetweenAsSectionsIB(pcSubStr, pcBound1, pcBound2)
		def SubStringBoundedByAsSectionsIB(pcSubStr, pacBounds)
		
	   #-------------------------------------------------------#
	  #  FINDING A SUBSTRING BOUNDED BY TWO OTHER SubString  #
	 #  STARTING AT A GIVEN POSITION                         #
	#-------------------------------------------------------#

	def FindBetweenS(pcSubStr, pcBound1, pcBound2, pnStartingAt)
		def FindSubStringBetweenS(pcSubStr, pcBound1, pcBound2, pnStartingAt)
		def FindBoundedByS(pcSubStr, pacBounds, pnStartingAt)
		def FindSubStringBoundedByS(pcSubStr, pacBounds, pnStartingAt)
	
		#--
	
		def FindBetweenSZ(pcSubStr, pcBound1, pcBound2, pnStartingAt)
		def FindSubStringBetweenSZ(pcSubStr, pcBound1, pcBound2, pnStartingAt)
		def FindBoundedBySZ(pcSubStr, pacBounds, pnStartingAt)
		def FindSubStringBoundedBySZ(pcSubStr, pacBounds, pnStartingAt)

		#==

		def SubStringBetweenS(pcSubStr, pcBound1, pcBound2, pnStartingAt)
		def SubStringBoundedByS(pcSubStr, pacBounds, pnStartingAt)

		def SubStringBetweenSZ(pcSubStr, pcBound1, pcBound2, pnStartingAt)
		def SubStringBoundedBySZ(pcSubStr, pacBounds, pnStartingAt)

	   #-------------------------------------------------------------------#
	  #  FINDING A SUBSTRING BOUNDED BY TWO OTHER SubString STARTING AT  #
	 #  A GIVEN POSITION AND RETURNING POSITIONS AS SECTIONS             #
	#-------------------------------------------------------------------#

	def FindBetweenSZZ(pcSubStr, pcBound1, pcBound2, pnStartingAt)
		def FindSubStringBetweenSZZ(pcSubStr, pcBound1, pcBound2, pnStartingAt)
		def FindBoundedBySZZ(pcSubStr, pacBounds, pnStartingAt)
		def FindSubStringBoundedBySZZ(pcSubStr, pacBounds, pnStartingAt)
	
		#--
	
		def FindBetweenAsSectionsS(pcSubStr, pcBound1, pcBound2, pnStartingAt)
		def FindSubStringBetweenAsSectionsS(pcSubStr, pcBound1, pcBound2, pnStartingAt)
		def FindBoundedByAsSectionsS(pcSubStr, pacBounds, pnStartingAt)
		def FindSubStringBoundedByAsSectionsS(pcSubStr, pacBounds, pnStartingAt)

		#==

		def SubStringBetweenSZZ(pcSubStr, pcBound1, pcBound2, pnStartingAt)
		def SubStringBoundedBySZZ(pcSubStr, pacBounds, pnStartingAt)

		def SubStringBetweenAsSectionsS(pcSubStr, pcBound1, pcBound2, pnStartingAt)
		def SubStringBoundedByAsSectionsS(pcSubStr, pacBounds, pnStartingAt)

	   #-------------------------------------------------------#
	  #  FINDING A SUBSTRING BOUNDED BY TWO OTHER SubString  #
	 #  STARTING AT A GIVEN POSITION AND INCLUDING BOUNDS    #
	#-------------------------------------------------------#

	def FindBetweenSIB(pcSubStr, pcBound1, pcBound2, pnStartingAt)
		def FindSubStringBetweenSIB(pcSubStr, pcBound1, pcBound2, pnStartingAt)
		def FindBoundedBySIB(pcSubStr, pacBounds, pnStartingAt)
		def FindSubStringBoundedBySIB(pcSubStr, pacBounds, pnStartingAt)
	
		#--
	
		def FindBetweenSIBZ(pcSubStr, pcBound1, pcBound2, pnStartingAt)
		def FindSubStringBetweenSIBZ(pcSubStr, pcBound1, pcBound2, pnStartingAt)
		def FindBoundedBySIBZ(pcSubStr, pacBounds, pnStartingAt)
		def FindSubStringBoundedBySIBZ(pcSubStr, pacBounds, pnStartingAt)

	    #---------------------------------------------------------------------------#
	   #  FINDING A SUBSTRING BOUNDED BY TWO OTHER SubString STARTING AT A GIVEN  #
	  #  POSITION, INCLUDING BOUNDS, AND RETURNING THE POSITIONS AS SECTIONS      #                               #
	#----------------------------------------------------------------------------#

	def FindBetweenSIBZZ(pcSubStr, pcBound1, pcBound2, pnStartingAt)
		def FindSubStringBetweenSIBZZ(pcSubStr, pcBound1, pcBound2, pnStartingAt)
		def FindBoundedBySIBZZ(pcSubStr, pacBounds, pnStartingAt)
		def FindSubStringBoundedBySIBZZ(pcSubStr, pacBounds, pnStartingAt)
	
		#--
	
		def FindBetweenAsSectionsSIB(pcSubStr, pcBound1, pcBound2, pnStartingAt)
		def FindSubStringBetweenAsSectionsSIB(pcSubStr, pcBound1, pcBound2, pnStartingAt)
		def FindBoundedByAsSectionsSIBZZ(pcSubStr, pacBounds, pnStartingAt)
		def FindSubStringBoundedByAsSectionsSIB(pcSubStr, pacBounds, pnStartingAt)

		#==

		def SubStringBetweenSIBZZ(pcSubStr, pcBound1, pcBound2, pnStartingAt)
		def SubStringBoundedBySIBZZ(pcSubStr, pacBounds, pnStartingAt)

		def SubStringBetweenAsSectionsSIB(pcSubStr, pcBound1, pcBound2, pnStartingAt)
		def SubStringBoundedByAsSectionsSIB(pcSubStr, pacBounds, pnStartingAt)

	   #-------------------------------------------------------#
	  #  FINDING A SUBSTRING BOUNDED BY TWO OTHER SubString  #
	 #  GOING IN A GIVEN DIRECTION                           #
	#-------------------------------------------------------#

	def FindBetweenD(pcSubStr, pcBound1, pcBound2)
		def FindSubStringBetweenD(pcSubStr, pcBound1, pcBound2, pcDirection)
		def FindBoundedByD(pcSubStr, pacBounds, pcDirection)
		def FindSubStringBoundedByD(pcSubStr, pacBounds, pcDirection)
	
		#--
	
		def FindBetweenDZ(pcSubStr, pcBound1, pcBound2, pcDirection)
		def FindSubStringBetweenDZ(pcSubStr, pcBound1, pcBound2, pcDirection)
		def FindBoundedByDZ(pcSubStr, pacBounds, pcDirection)
		def FindSubStringBoundedByDZ(pcSubStr, pacBounds, pcDirection)

		#==

		def SubStringBetweenD(pcSubStr, pcBound1, pcBound2, pcDirection)
		def SubStringBoundedByD(pcSubStr, pacBounds, pcDirection)

		def SubStringBetweenDZ(pcSubStr, pcBound1, pcBound2, pcDirection)
		def SubStringBoundedByDZ(pcSubStr, pacBounds, pcDirection)

	   #----------------------------------------------------------------#
	  #  FINDING A SUBSTRING BOUNDED BY TWO OTHER SubString GOING IN  #
	 #  A GIVEN DIRECTION AND RETURNING POSITIONS AS SECTIONS         #                       #
	#----------------------------------------------------------------#

	def FindBetweenDZZ(pcSubStr, pcBound1, pcBound2)
		def FindSubStringBetweenDZZ(pcSubStr, pcBound1, pcBound2, pcDirection)
		def FindBoundedByDZZ(pcSubStr, pacBounds, pcDirection)
		def FindSubStringBoundedByDZZ(pcSubStr, pacBounds, pcDirection)
	
		#--
	
		def FindBetweenAsSectionsD(pcSubStr, pcBound1, pcBound2)
		def FindSubStringBetweenAsSectionsD(pcSubStr, pcBound1, pcBound2, pcDirection)
		def FindBoundedByAsSectionsD(pcSubStr, pacBounds, pcDirection)
		def FindSubStringBoundedByAsSectionsD(pcSubStr, pacBounds, pcDirection)

		#==

		def SubStringBetweenDZZ(pcSubStr, pcBound1, pcBound2, pcDirection)
		def SubStringBoundedByDZZ(pcSubStr, pacBounds, pcDirection)

		def SubStringBetweenAsSectionsD(pcSubStr, pcBound1, pcBound2, pcDirection)
		def SubStringBoundedByAsSectionsD(pcSubStr, pacBounds, pcDirection)

	   #-------------------------------------------------------#
	  #  FINDING A SUBSTRING BOUNDED BY TWO OTHER SubString  #
	 #  GOING IN A GIVEN DIRECTION AND INCLUDING BOUNDS      #
	#-------------------------------------------------------#

	def FindBetweenDIB(pcSubStr, pcBound1, pcBound2)
		def FindSubStringBetweenDIB(pcSubStr, pcBound1, pcBound2, pcDirection)
		def FindBoundedByDIB(pcSubStr, pacBounds, pcDirection)
		def FindSubStringBoundedByDIB(pcSubStr, pacBounds, pcDirection)
	
		#--
	
		def FindBetweenDIBZ(pcSubStr, pcBound1, pcBound2, pcDirection)
		def FindSubStringBetweenDIBZ(pcSubStr, pcBound1, pcBound2, pcDirection)
		def FindBoundedByDIBZ(pcSubStr, pacBounds, pcDirection)
		def FindSubStringBoundedByDIBZ(pcSubStr, pacBounds, pcDirection)

		#==

		def SubStringBetweenDIB(pcSubStr, pcBound1, pcBound2, pcDirection)
		def SubStringBoundedByDIB(pcSubStr, pacBounds, pcDirection)

		def SubStringBetweenDIBZ(pcSubStr, pcBound1, pcBound2, pcDirection)
		def SubStringBoundedByDIBZ(pcSubStr, pacBounds, pcDirection)

	   #------------------------------------------------------------------------#
	  #  FINDING A SUBSTRING BOUNDED BY TWO OTHER SubString GOING IN A GIVEN  #
	 #  DIRECTION, INCLUDING BOUNDS, AND RETURNING POSITIONS AS SECTIONS      #                   #                       #
	#------------------------------------------------------------------------#

	def FindBetweenDIBZZ(pcSubStr, pcBound1, pcBound2)
		def FindSubStringBetweenDIBZZ(pcSubStr, pcBound1, pcBound2, pcDirection)
		def FindBoundedByDIBZZ(pcSubStr, pacBounds, pcDirection)
		def FindSubStringBoundedByDIBZZ(pcSubStr, pacBounds, pcDirection)
	
		#--
	
		def FindSubStringBetweenAsSectionsDIB(pcSubStr, pcBound1, pcBound2, pcDirection)
		def FindBoundedByAsSectionsDIB(pcSubStr, pacBounds, pcDirection)
		def FindSubStringBoundedByAsSectionsDIB(pcSubStr, pacBounds, pcDirection)

		#==

		def SubStringBetweenDIBZZ(pcSubStr, pcBound1, pcBound2, pcDirection)
		def SubStringBoundedByDIBZZ(pcSubStr, pacBounds, pcDirection)

		def SubStringBetweenAsSectionsDIB(pcSubStr, pcBound1, pcBound2, pcDirection)
		def SubStringBoundedAsSectionsByDIB(pcSubStr, pacBounds, pcDirection)

	   #----------------------------------------------------------------#
	  #  FINDING A SUBSTRING BOUNDED BY TWO OTHER SubString STARTING  #
	 #  AT A GIVEN POSITION AND GOING IN A GIVEN DIRECTION            #
	#----------------------------------------------------------------#

	def FindBetweenSD(pcSubStr, pcBound1, pcBound2)
		def FindSubStringBetweenSD(pcSubStr, pcBound1, pcBound2, pnStartingAt, pcDirection)
		def FindBoundedBySD(pcSubStr, pacBounds, pnStartingAt, pcDirection)
		def FindSubStringBoundedBySD(pcSubStr, pacBounds, pnStartingAt, pcDirection)
	
		#--
	
		def FindBetweenSDZ(pcSubStr, pcBound1, pcBound2, pnStartingAt, pcDirection)
		def FindSubStringBetweenSDZ(pcSubStr, pcBound1, pcBound2, pnStartingAt, pcDirection)
		def FindBoundedBySDZ(pcSubStr, pacBounds, pnStartingAt, pcDirection)
		def FindSubStringBoundedBySDZ(pcSubStr, pacBounds, pnStartingAt, pcDirection)

		#==

		def SubStringBetweenSD(pcSubStr, pcBound1, pcBound2, pnStartingAt, pcDirection)
		def SubStringBoundedBySD(pcSubStr, pacBounds, pnStartingAt, pcDirection)

		def SubStringBetweenSDZ(pcSubStr, pcBound1, pcBound2, pnStartingAt, pcDirection)
		def SubStringBoundedBySDZ(pcSubStr, pacBounds, pnStartingAt, pcDirection)
		
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

