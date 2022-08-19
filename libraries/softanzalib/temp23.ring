	  #====================================================#
	 #    SPLITTING THE STRING USING A GIVEN SUBSTRING    #
	#====================================================#

	def SplitCS(pSubStr, pCaseSensitive)
		if isList(pcSubStr) and Q(pcSubStr).IsUsingNamedParam()
			pcSubStr = pcSubStr[2]
		ok

		if NOT isString(pcSubStr)
			StzRaise("Incorrect param type! pcSubStr must be a string.")
		ok

		aResult = QStringListToList( This.QStringObject().split(pcSubStr, 0, pCaseSensitive[2]) )
		return aResult

	def 
	  #=======================#
	 #    SPLITTING USING    #
	#=======================#

	def SplitUsingCS(pcSubStr, pCaseSensitive)

		anPositions = This.FindAllCS(pcSubStr, pCaseSensitive)
		aResult = This.SplitAtPositions(anPositions)

		return aResult

	  #--------------------#
	 #    SPLITTING AT    #
	#--------------------#

	def SplitAtCS(pcSubStr, pCaseSensitive)

		anPositions = This.FindAllCS(pcSubStr, pCaseSensitive)
		aResult = This.SplitAtPositions(anPositions)

		return aResult

		#< @FunctionAlternativeForm

		def SplitAtPosition(n)
			return This.SplitAt(n)

		#>

	  #---------------------------------#
	 #   SPLITTING AT MANY POSITIONS   #
	#---------------------------------#

	def SplitAtPositions(panPositions)

		aPairs = This.GetPairsFromPositions(panPositions)

		for i = 1 to len(aPairs) - 1
			aPairs[i][2]--
			aPairs[i+1][1]++
		next

		return aPairs

	  #========================#
	 #    SPLITTING BEFORE    #
	#========================#

	def SplitBefore(n)
		if isList(n)
			if Q(n).IsWhereNamedParam()
				return This.SplitBeforeW(n)

			else
				return This.SplitBeforePositions(n)
			ok
		ok

		nLen = This.NumberOfPositions()

		if n > 1 and n < nLen
			aResult = [ [ 1, n-1], [n, nLen ] ]
		else
			aResult = This.Content()
		ok

		return aResult

		def SplitBeforePosition(n)
			return This.SplitBefore(n)

	def SplitBeforePositions(panPositions)

		aPairs = This.GetPairsFromPositions(panPositions)
		/*
		Main list 	 --> 1:10
		panPositions	 --> [ 3, 6, 8 ]
		List of pairs	 --> [ [ 1, 3 ], [ 3, 6 ], [ 6, 8 ], [ 8, 10 ] ]
		Eexpected result --> [ [ 1, 2 ], [ 3, 5 ], [ 6, 7 ], [ 8, 10 ] ]

		- We should leave the last pair as is
		- For all the others, just retrived 1 from aPair[2]
		*/

		nLen = len(aPairs)
		aResult = []

		for i = 1 to nLen - 1
			n1 = aPairs[i][1]
			n2 = aPairs[i][2] - 1

			aResult + [ n1, n2 ]
		next

		aLastPair = aPairs[nLen]
		aResult + [ aLastPair[1], aLastPair[2] ]

		return aResult

	  #=======================#
	 #    SPLITTING AFTER    #
	#=======================#

	def SplitAfter(n)
		if isList(n)
			if Q(n).IsWhereNamedParam()
				return This.SplitAfterW(n)

			else
				return This.SplitAfterPositions(n)
			ok
		ok

		nLen = This.NumberOfPositions()

		if n > 1 and n < nLen
			aResult = [ [ 1, n], [n+1, nLen ] ]
		else
			aResult = This.Content()
		ok

		return aResult

		def SplitAfterPosition(n)
			return This.SplitAfter(n)

	def SplitAfterPositions(panPositions)

		aPairs = This.GetPairsFromPositions(panPositions)
		/*
		Main list 	 --> 1:10
		panPositions	 --> [ 3, 6, 8 ]
		List of pairs	 --> [ [ 1, 3 ], [ 3, 6 ], [ 6, 8 ], [ 8, 10 ] ]
		Eexpected result --> [ [ 1, 3 ], [ 4, 6 ], [ 7, 9 ], [ 9, 10 ] ]

		- We should leave the first pair as is
		- For all the others, just retrived 1 to aPair[1]
		*/

		nLen = len(aPairs)
		
		aFirstPair = aPairs[1]
		aResult = [ [ aFirstPair[1], aFirstPair[2] ] ]

		for i = 2 to nLen
			n1 = aPairs[i][1] + 1
			n2 = aPairs[i][2]

			aResult + [ n1, n2 ]
		next

		return aResult

	  #=======================================#
	 #    SPLITTING UNDER A GIVEN CONDTION   #
	#=======================================#

	def SplitW(pcCondition)
		/*
		? StzSplitterQ(1:5).SplitW('Q(@item).IsMultipleOf(2)')
		*/

		if isList(pcCondition)

			if Q(pcCondition).IsWhereNamedParam()
				return This.SplitAtW(pcCondition[2])

			but Q(pcCondition).IsAtNamedParam()
				return This.SplitAtW(pcCondition[2])

			but Q(pcCondition).IsBeforeNamedParam()
				return This.SplitBeforeW(pcCondition[2])

			but Q(pcCondition).IsAfterNamedParam()
				return This.SplitAfterW(pcCondition[2])

			ok
		
		else
			return This.SplitAtW(pcCondition)
		ok

	  #------------------------------------#
	 #    SPLITTING AT A GIVEN CONDTION   #
	#------------------------------------#

	def SplitAtW(pcCondition)
		cCondition = ""

		if isString(pcCondition)
			cCondition = pcCondition

		but isList(pcCondition)
			cCondition = pcCondition[2]
		ok

		cCondition = Q(cCondition).ReplaceCSQ("@position", :By = "@item", :CS = FALSE).Content()

		anPositions = StzListQ(This.Content()).ItemsW(cCondition)
		return This.SplitAtPositions(anPositions)

	  #----------------------------------------#
	 #    SPLITTING BEFORE A GIVEN CONDTION   #
	#----------------------------------------#

	def SplitBeforeW(pcCondition)
		if isList(pcCondition) and Q(pcCondition).IsBeforeNamedParam()
			pcCondition = pcCondition[2]
		ok

		anPositions = StzListQ(This.Content()).ItemsW(pcCondition)
		return This.SplitBeforePositions(anPositions)

	  #---------------------------------------#
	 #    SPLITTING AFTER A GIVEN CONDTION   #
	#---------------------------------------#

	def SplitAfterW(pcCondition)
		if isList(pcCondition) and Q(pcCondition).IsBeforeNamedParam()
			pcCondition = pcCondition[2]
		ok

		anPositions = StzListQ(This.Content()).ItemsW(pcCondition)
		return This.SplitAfterPositions(anPositions)

	  #===================================#
	 #   SPLITTING TO PARTS OF N ITEMS   #
	#===================================#

	def SplitToPartsOfNItems(n)

		nLen = This.NumberOfPositions()

		if NOT ( ( isNumber(n) ) and Q(n).IsBetween(1, nLen ) )
			return [ [] ]

		else
			aResult = []

			for i = 1 to nLen step n
				nTemp = i + n-1

				if nTemp > nLen
					nTemp = nLen
				ok

				aResult + [ i, nTemp ]
			next
	
			return aResult
		ok

		#< @FunctionAlternativeForm

		def SplitToPartsOfN(n)
			This.SplitToPartsOfNItems(n)

		def SplitToPartsOf(n)
			This.SplitToPartsOfNItems(n)

		#>

	  #-------------------------------------------------#
	 #    SPLITTING TO PARTS OF N ITEMS -- EXTENDED    #
	#-------------------------------------------------#

	def SplitToPartsOfNItemsXT(n, bExcludeRemainingPart)
		aSections = This.SplitToNParts(n)
		
		if len(aSections) > 2
			anLast = aSections[ len(aSections) ]
	
			if anLast[1] = anLast[2]
				del(aSections, len(aSections))
			ok
		ok

		return aSections

		def SplitToPartsOfExactlyNItems(n)
			return This.SplitToPartsOfNItemsXT(n, :ExcludeRemainingPart = TRUE)

	  #----------------------------#
	 #    SPLITTING TO N PARTS    #
	#----------------------------#

	def SplitToNParts(n)

		nNumberOfPositions = This.NumberOfPositions()

		if NOT Q(n).IsBetween(1, nNumberOfPositions )
			return [ [] ]
		ok

		nLen =  ( nNumberOfPositions - ( nNumberOfPositions % n ) ) / n
		# Replace with the following when ready:
		# nLen = 0+ Q( This.NumberOfItems() / n ).IntegerPart()

		aResult = []

		for i = 1 to n*nLen step nLen
			aResult + [ i, i + nLen-1 ]
		next

		if aResult[ len(aResult) ][2] != nNumberOfPositions
			aResult[ len(aResult) ][2] = nNumberOfPositions
		ok

		return aResult

