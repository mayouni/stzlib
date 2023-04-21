/*
...InBetween...
Add FindAnyInBetween
*/
	  #============================================================================#
	 #   FINDING ALL OCCURRENCES OF A SUBSTRING IN-BETWEEN TWO OTHER SUBSTRINGS   #
	#============================================================================#

	def FindInBetweenCS(pcSubStr, pcBound1, pcBound2, pCaseSensitive)

		/* EXAMPLE 1:

		o1 = new stzString("bla <<..word..>> bla bla <<..noword..>> bla <<word>>")
		? o1.FindInBetweenCS("word", "<<", ">>", :CaseSensitive = FALSE)
		#--> [ 9, 30, 45 ]

		*/



		#< @FunctionFluentForm

		def FindBetweenCSQ(pcSubStr, pcBound1, pcBound2, pCaseSensitive)
			return This.FindBetweenCSQR(pcSubStr, pcBound1, pcBound2, pCaseSensitive, :stzList)

			def FindBetweenCSQR(pcSubStr, pcBound1, pcBound2, pCaseSensitive, pcReturnType)
				if isList(pcReturnType) and Q(pcReturnType).IsOneOfTheseNamedParams([ :ReturnedAs, :ReturnAs ])
					pcReturnType = pcReturnType[2]
				ok
	
				switch pcReturnType
				on :stzList
					return new stzList( This.FindThisSubStringBetweenCS(pcSubStr, pcBound1, pcBound2, pCaseSensitive) )
	
				on :stzListOfStrings
					return new stzListOfStrings( This.FindThisSubStringBetweenCS(pcSubStr, pcBound1, pcBound2, pCaseSensitive) )
	
				other
					stzRaise("Unsupported return type!")
				off
	
		#>

		#< @FunctionAlternativeForms: SeeBottomOfFile #>

	#-- WITHOUT CASESENSITIVITY

	def FindBetween(pcSubStr, pcBound1, pcBound2)
		return This.FindBetweenCS(pcSubStr, pcBound1, pcBound2, :CaseSensitive = TRUE)

		#< @FunctionFluentForm

		def FindBetweenQ(pcSubStr, pcBound1, pcBound2)
			return This.FindBetweenQR(pcSubStr, pcBound1, pcBound2, :stzList)

			def FindBetweenQR(pcSubStr, pcBound1, pcBound2, pcReturnType)
				return This.FindBetweenCSQR(pcSubStr, pcBound1, pcBound2, :CaseSensitive = TRUE, pcReturnType)

		#>

		#< @FunctionAlternativeForms: SeeBottomOfFile #>

	  #---------------------------------------------------------------------#
	 #  FINDING A SUBSTRING BETWEEN TWO GIVEN SUBSTRINGS -- IB() EXTENDED  #
	#---------------------------------------------------------------------#

	def FindBetweenIBCS(pcSubStr, pcBound1, pcBound2, pCaseSensitive)
		anPos = This.FindBetweenCS(pcSubStr, pcBound1, pcBound2, pCaseSensitive)

		if isList(pcBound1)
			pcBound1 = pcBound1[2]
		ok
		nLenBound1 = Q(pcBound1).NumberOfChars()
		anResult = Q(anPos).AddedToEach( - nLenBound1 )

		return anResult

		#< @FunctionAlternativeForms

		def FindSubStringBetweenIBCS(cSubStr, pcBound1, pcBound2, pCaseSensitive)
			return This.FindBetweenIBCS(pcSubStr, pcBound1, pcBound2, pCaseSensitive)

		def FindBoundedByIBCS(pcSubStr, pacBounds, pCaseSensitive)
			if isString(pacBounds)
				return This.FindBetweenIBCS(pcSubStr, pacBounds, pacBounds, pCaseSensitive)

			but isLisy(pacBounds) and Q(pacBounds).IsPairOfStrings()
				return This.FindBetweenIBCS(pcSubStr, pacBounds[1], pacBounds[2], pCaseSensitive)

			else
				StzRaise("Incorrect param type! pacBounds must be a string or a pair of strings.")
			ok

		def FindSubStringBoundedByIBCS(pcSubStr, pacBounds, pCaseSensitive)
			return This.FindBoundedByIBCS(pcSubStr, pacBounds, pCaseSensitive)

		#>

	#-- WITHOUT CASESENSITIVITY

	def FindBetweenIB(pcSubStr, pcBound1, pcBound2)
		return This.FindBetweenIBCS(pcSubStr, pcBound1, pcBound2, :CaseSensitive = TRUE)

		#< @FunctionAlternativeForms

		def FindSubStringBetweenIB(cSubStr, pcBound1, pcBound2)
			return This.FindBetweenIB(pcSubStr, pcBound1, pcBound2)

		def FindBoundedByIB(pcSubStr, pacBounds)
			return This.FindBoundedByIBCS(pcSubStr, pacBounds, :CaseSensitive = TRUE)

		def FindSubStringBoundedByIB(pcSubStr, pacBounds)
			return FindBoundedByIB(pcSubStr, pacBounds)

	  #--------------------------------------------------------#
	 #   FINDING NTH SUBSTRING BETWEEN TWO GIVEN SUBSTRINGS   #
	#--------------------------------------------------------#

	def FindNthBetweenCS(n, pcSubStr, pcBound1, pcBound2, pCaseSensitive)
		if n = :First or n = :FirstSubString
			n = 1
		but n = :Last or n = :LastSubString
			n = This.NumberOfOccurrenceBetweenCS(pcSubStr, pcBound1, pcBound2, pCaseSensitive)
		ok

		anPositions = This.FindBetweenCS(pcSubStr, pcBound1, pcBound2, pCaseSensitive)
		nResult = anPositions[n]
		return nResult

		def FindNthSubStringBetweenCS(pcSubStr, pcBound1, pcBound2, pCaseSensitive)
			return This.FindNthBetweenCS(pcSubStr, pcBound1, pcBound2, pCaseSensitive)

	#-- WITHOUT CASESENSITIVITY

	def FindNthBetween(n, pcSubStr, pcBound1, pcBound2)
		return This.FindNthBetweenCS(n, pcSubStr, pcBound1, pcBound2, :CaseSensitive = TRUE)

		def FindNthSubStringBetween(n, pcSubStr, pcBound1, pcBound2)
			return This.FindNthBetween(n, pcSubStr, pcBound1, pcBound2)

	  #----------------------------------------------------------#
	 #   FINDING FIRST SUBSTRING BETWEEN TWO GIVEN SUBSTRINGS   #
	#----------------------------------------------------------#

	def FindFirstBetweenCS(pcSubStr, pcBound1, pcBound2, pCaseSensitive)
		nResult = This.FindNthBetweenCS(1, pcSubStr, pcBound1, pcBound2, pCaseSensitive)
		return nResult

		def FindFirstSubStringBetweenCS(pcSubStr, pcBound1, pcBound2, pCaseSensitive)
			return This.FindFirstBetweenCS(pcSubStr, pcBound1, pcBound2, pCaseSensitive)

	#-- WITHOUT CASESENSITIVITY

	def FindFirstBetween(pcSubStr, pcBound1, pcBound2)
		return This.FindFirstBetweenCS(pcSubStr, pcBound1, pcBound2, :CaseSensitive = TRUE)

		def FindFirstSubStringBetween(pcSubStr, pcBound1, pcBound2)
			return This.FindFirstBetween(pcSubStr, pcBound1, pcBound2)

	  #----------------------------------------------------------#
	 #   FINDING LAST SUBSTRING BETWEEN TWO GIVEN SUBSTRINGS   #
	#----------------------------------------------------------#

	def FindLastBetweenCS(pcSubStr, pcBound1, pcBound2, pCaseSensitive)
		nResult = This.FindNthBetweenCS(:Last, pcSubStr, pcBound1, pcBound2, pCaseSensitive)
		return nResult

		def FindLastSubStringBetweenCS(pcSubStr, pcBound1, pcBound2, pCaseSensitive)
			return This.FindLastBetweenCS(pcSubStr, pcBound1, pcBound2, pCaseSensitive)

	#-- WITHOUT CASESENSITIVITY

	def FindLastBetween(pcSubStr, pcBound1, pcBound2)
		return This.FindLastBetweenCS(pcSubStr, pcBound1, pcBound2, :CaseSensitive = TRUE)

		def FindLastSubStringBetween(pcSubStr, pcBound1, pcBound2)
			return This.FindLastBetween(pcSubStr, pcBound1, pcBound2)

	   #-------------------------------------------------------------#
	  #   FINDING ALL OCCURRENCES OF A SUBSTRING BETWEEN            #
	 #   TWO OTHER SUBSTRINGS AND RETURN THEIR RELATIVE SECTIONS   #
	#-------------------------------------------------------------#

	def FindBetweenAsSectionsCS(pcSubStr, pcBound1, pcbound2, pCaseSensitive)
		/* EXAMPLE

		o1 = new stzString("bla bla <<word>> bla bla <<noword>> bla <<word>>")
		? o1.FindSubStringBetweenAsSectionsCS("word", "<<", ">>", :CaseSensitive = FALSE)
		
		(we used here the simple form of the function)

		#--> [ [11, 14], [28, 31], [41, 44] ]
		*/

		# Getting all the occurrences of pcSubStr in the string

		aSections = This.FindAsSectionsCS(pcSubStr, pCaseSensitive)
		#--> [ [ 11, 14 ], [ 32, 35 ], [ 43, 47 ] ]
		nLenSections = len(aSections)

		# Checking the ones that are bounded by pcSubStr1 (<<) and pcSubStr2 (>>)

		nLen1 = StzStringQ(pcBound1).NumberOfChars()
		nLen2 = StzStringQ(pcBound2).NumberOfChars()

		anResult = []
		
		for i = 1 to nLenSections

			aPair = aSections[i]

			cStr = This.Section(aPair[1] - nLen1, aPair[2] + nLen2 )

			if StzStringQ(cStr).IsBoundedByCS([pcBound1, pcBound2], pCaseSensitive)
				anResult + aPair
			ok
		next

		return anResult

		#< @FunctionFluentForm

		def FindBetweenAsSectionsCSQ(pcSubStr, pcBound1, pcbound2, pCaseSensitive)
			return This.FindBetweenAsSectionsCSQR(pcSubStr, pcBound1, pcbound2, pCaseSensitive, :stzList)

			def FindBetweenAsSectionsCSQR(pcSubStr, pcBound1, pcbound2, pCaseSensitive, pcReturnType)
				if isList(pcReturnType) and Q(pcReturnType).IsOneOfTheseNamedParams([ :ReturnedAs, :ReturnAs ])
					pcReturnType = pcReturnType[2]
				ok
	
				switch pcReturnType
				on :stzList
					return new stzList( This.FindBetweenAsSectionsCS(pcSubStr, pcBound1, pcbound2, pCaseSensitive) )
	
				on :stzListOfStrings
					return new stzListOfStrings( This.FindBetweenAsSectionsCS(pcSubStr, pcBound1, pcbound2, pCaseSensitive) )
	
				other
					stzRaise("Unsupported return type!")
				off
		#>

		#< @FunctionAlternativeForm

		def FindSubStringBetweenAsSectionsCS(pcSubStr, pcBound1, pcbound2, pCaseSensitive)
			return This.FindBetweenAsSectionsCS(pcSubStr, pcBound1, pcbound2, pCaseSensitive)

			def FindSubStringBetweenAsSectionsCSQ(pcSubStr, pcBound1, pcbound2, pCaseSensitive)
				return This.FindBetweenAsSectionsCSQ(pcSubStr, pcBound1, pcbound2, pCaseSensitive)

			def FindSubStringBetweenAsSectionsCSQR(pcSubStr, pcBound1, pcbound2, pCaseSensitive, pcReturnType)
				return This.FindBetweenAsSectionsCSQR(pcSubStr, pcBound1, pcbound2, pCaseSensitive, pcReturnType)

		#>

	#-- WITHOUT CASESENSITIVITY

	def FindBetweenAsSections(pcSubStr, pcBound1, pcbound2)
		return This.FindBetweenAsSectionsCS(pcSubStr, pcBound1, pcbound2, :CaseSensitive = TRUE)

		#< @FunctionFluentForm

		def FindBetweenAsSectionsQ(pcSubStr, pcBound1, pcbound2)
			return This.FindBetweenAsSectionsQR(pcSubStr, pcBound1, pcbound2, :stzList)

			def FindBetweenAsSectionsQR(pcSubStr, pcBound1, pcbound2, pcReturnType)
				return This.FindSubStringBetweenAsSectionsCSQR(pcSubStr, pcBound1, pcbound2, :CaseSensitive = TRUE, pcReturnType)
		#>

		#< @FunctionAlternativeForm

		def FindSubStringBetweenAsSections(pcSubStr, pcBound1, pcbound2)
			return This.FindBetweenAsSections(pcSubStr, pcBound1, pcbound2)

			def FindSubStringBetweenAsSectionsQ(pcSubStr, pcBound1, pcbound2)
				return This.FindBetweenAsSectionsQ(pcSubStr, pcBound1, pcbound2)

			def FindSubStringBetweenAsSectionsQR(pcSubStr, pcBound1, pcbound2, pcReturnType)
				return This.FindBetweenAsSectionsQR(pcSubStr, pcBound1, pcbound2, pcReturnType)

		#>
