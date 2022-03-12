
	  #=================================================#
	 #     FINDING A STRING IN THE LIST OF STRINGS     #
	#=================================================#

	def FindStringCS(pcStr, pCaseSensitive)

		if isList(pCaseSensitive) and StzListQ(pCaseSensitive).IsCaseSensitiveParamList()
			pCaseSensitive = pCaseSensitive[2]
		ok

		anResult = []

		if pCaseSensitive = TRUE

			anResult = This.ToStzList().FindAll(pcStr)

		else
			acList = This.Lowercased()
			cStr = StzStringQ(pcStr).Lowercased()

			anResult = StzListQ(acList).FindAll(cStr)
		ok


		return anResult

		#< @FunctionAlternativeForms

		def FindCS(pcStr)
			return This.FindStringCS(pcStr, pCaseSensitive)

		def FindAllCS(pcStr, pCaseSensitive)
			return This.FindStringCS(pcStr, pCaseSensitive)

		def FindAllOccurrencesOfStringCS(pcStr, pCaseSensitive)
			return This.FindStringCS(pcStr, pCaseSensitive)

		def PositionsOfCS(pcStr, pCaseSensitive)
			return This.FindStringCS(pcStr, pCaseSensitive)

		def PositionsOfStringCS(pcStr, pCaseSensitive)
			return This.FindStringCS(pcStr, pCaseSensitive)

		def AllPositionsOfStringCS(pcStr, pCaseSensitive)
			return This.FindStringCS(pcStr, pCaseSensitive)

		#>

	def FindString(pcStr)
		return This.FindStringCS(pcStr, :CaseSensitive = FALSE)

		#< @FunctionAlternativeForms

		def FindAll(pcStr)
			return This.FindString(pcStr)

		def FindAllOccurrencesOfString(pcStr)
			return This.FindString(pcStr)

		def PositionsOf(pcStr)
			return This.FindString(pcStr)

		def PositionsOfStringC(pcStr)
			return This.FindString(pcStr)

		def AllPositionsOfString(pcStr)
			return This.FindString(pcStr)

		#>

	   #----------------------------------------------------#
	  #    NUMBER OF OCCURRENCE OF A STRING (AS AN ITEM)   #
	 #    IN THE LIST OF STRINGS                          #
	#----------------------------------------------------#

	def NumberOfOccurrenceOfStringCS(pcStr, pCaseSensitive)
		return len( This.FindStringCS(pcStr, pCaseSensitive) )

	def NumberOfOccurrenceOfString(pcStr)
		return This.NumberOfOccurrenceOfStringCS(pcStr, :CaseSensitive = FALSE)

	   #--------------------------------------------------------#
	  #      CHECKING IF LIST OF STRINGS CONTAINS A GIVEN      #
	 #      STRING (AS AN ENTIRE ITEM OF THE LIST)            #
	#--------------------------------------------------------#

	def ContainsStringCS(pcStr, pCaseSensitive)
		if This.NumberOfOccurrenceOfStringCS(pcStr, pCaseSensitive) > 0
			return TRUE

		else
			return FALSE
		ok

		#< @FunctionAlternativeForm

		def ContainsCS(pcStr)
			return This.ContainsStringCS(pcStr, pCaseSensitive)

		#>

	def ContainsString(pcStr)
		return This.ContainsStringCS(pcStr, :CaseSensitive = TRUE)

		def Contains(pcStr)
			return This.ContainsString(pcStr)

	  #-----------------------------------------------------------------#
	 #    FINDING NTH OCCURRENCE OF A STRING IN THE LIST OF STRINGS    #
	#-----------------------------------------------------------------#
	
	def FindNthOccurrenceOfStringCS(n, pcStr, pCaseSensitive)

		if isString(n)
			if n = :first
				n = 1
			but n = :Last
				n = This.NumberOfOccurrenceCS(pcStr, pCaseSensitive)
			ok
		ok

		if isList(pCaseSensitive) and StzListQ(pCaseSensitive).IsCaseSensitiveParamList()
			pCaseSensitive = pCaseSensitive[2]
		ok

		nResult = 0

		anPos = This.FindStringCS(pcString, pCaseSensitive)
		return anPos[n]

		return nResult

		#< @FunctionAlternativeForms

		def FindNthStringCS(n, pcStr, pCaseSensitive)
			return This.FindNthOccurrenceOfStringCS(n, pcStr, pCaseSensitive)

		def FindNthOccurrenceCS(n, pcStr, pCaseSensitive)
			return This.FindNthOccurrenceOfStringCS(n, pcStr, pCaseSensitive)

		def FindNthOccurrenceOfThisStringCS(n, pcStr, pCaseSensitive)
			return This.FindNthOccurrenceOfStringCS(n, pcStr, pCaseSensitive)

		#>

	def FindNthOccurrenceOfString(n, pcStr)
		return This.FindNthOccurrenceOfStringCS(n, pcStr, :CaseSensitive = TRUE)

		def FindNthString(n, pcStr)
			return This.FindNthOccurrenceOfString(n, pcStr)

		def FindNthOccurrence(n, pcStr)
			return This.FindNthOccurrenceOfString(n, pcStr)

		def FindNthOccurrenceOfThisString(n, pcStr)
			return This.FindNthOccurrenceOfString(n, pcStr)

	def FindFirstOccurrenceOfStringCS(pcStr, pCaseSensitive)
		This.FindNthOccurrenceOfStringCS(1, pcStr, pCaseSensitive)

		def FindFirstStringCS(pcStr, pCaseSensitiveg)
			return This.FindFirstOccurrenceOfStringCS(pcStr, pCaseSensitive)

		def FindFirstOccurrenceCS(pcStr, pCaseSensitive)
			return This.FindFirstOccurrenceOfStringCS(pcStr, pCaseSensitive)

		def FindFirstOccurrenceOfThisStringCS(pcStr, pCaseSensitive)
			return This.FindFirstOccurrenceOfStringCS(pcStr, pCaseSensitive)

	def FindFirstOccurrenceOfString(pcStr)
		This.FindFirstOccurrenceOfStringCS(pcStr, :CaseSensitive = TRUE)

		def FindFirstString(pcStr)
			return This.FindFirstOccurrenceOfString(pcStr)

		def FindFirstOccurrence(pcStr)
			return This.FindFirstOccurrenceOfString(pcStr)

		def FindFirstOccurrenceOfThisString(pcStr)
			return This.FindFirstOccurrenceOfString(pcStr)

	def FindLastOccurrenceOfStringCS(pcStr, pCaseSensitive)
		This.FindNthOccurrenceOfStringCS(:Last, pcStr, pCaseSensitive)

		def FindLastStringCS(pcStr, pCaseSensitive)
			return This.FindLastOccurrenceOfStringCS(pcStr, pCaseSensitive)

		def FindLastOccurrenceCS(pcStr, pCaseSensitive)
			return This.FindLastOccurrenceOfStringCS(pcStr, pCaseSensitive)

		def FindLastOccurrenceOfThisStringCS(pcStr, pCaseSensitive)
			return This.FindLastOccurrenceOfStringCS(pcStr, pCaseSensitive)

	def FindLastOccurrenceOfString(pcStr)
		This.FindLastOccurrenceOfStringCS(pcStr, :CaseSensitive = TRUE)

		def FindLastString(pcStr)
			return This.FindLastOccurrenceOfString(pcStr)

		def FindLastOccurrence(pcStr)
			return This.FindLastOccurrenceOfString(pcStr)

		def FindLastOccurrenceOfThisString(pcStr)
			return This.FindLastOccurrenceOfString(pcStr)

	  #---------------------------------------------#
	 #   FINDING MANY STRINGS AT THE SAME TIME     #
	#---------------------------------------------#

	def FindStringsCS(pacStr, pCaseSensitive)
		
		/*
		o1 = new stzListOfStrings([
			"My name is Moudour. What's your name please?",
			"Your name and my name are not the same.",
			"Please feel free to call me with any name!"
		])

		? o1.FindManyStringsCS( [ "name", "your", "please" ], :CS = TRUE )

		# --> [ 4, 33, 28, 38 ]
		*/

		aResult = []

		for str in pacStrings
			aResult + This.FindStringCS(str, pCaseSensitive)
		next

		aResult = StzListQ(aResult).FlattenQ().SortInAscendingQ().Content()

		return aResult	

		#< @FunctionAlternativeForms

		def FindManyStringsCS(pacStr, pCaseSensitive)
			return This.FindStringsCS(pacStr, pCaseSensitive)

		def FindManyCS(pacStr, pCaseSensitive)
			return This.FindStringsCS(pacStr, pCaseSensitive)

		def FindTheseStringsCS(pacStr, pCaseSensitive)
			return This.FindStringsCS(pacStr, pCaseSensitive)

		def FindTheseCS(pacStr, pCaseSensitive)
			return This.FindStringsCS(pacStr, pCaseSensitive)

		#>

	def FindStrings(pacStr)
		return This.FindStringsCS(pacStr, :CaseSensitive = TRUE)

		def FindManyStrings(pacStr)
			return This.FindStrings(pacStr)

		def FindMany(pacStr)
			return This.FindStrings(pacStr)

		def FindTheseStrings(pacStr)
			return This.FindStrings(pacStr)

		def FindThese(pacStr)
			return This.FindStringsCS(pacStr)

	  #---------------------------------------------------#
	 #    FINDING STRINGS VERIYING A GIVEN CONDITION     #
	#---------------------------------------------------#

	def FindStringsWCS(pcCondition, pCaseSensitive)
		if isList(pCaseSensitive) and StzListQ(pCaseSensitive).IsCaseSensitiveParamList()
			pCaseSensitive = pCaseSensitive[2]
		ok

		acResult = []

		if pCaseSensitive = TRUE

			acResult = This.ToStzList().FindW(pcCondition)

		else
			acList = This.Lowercased()
			cStr = StzStringQ(pcStr).Lowercased()

			acResult = StzListQ(acList).FindW(cStr)
		ok

		return acResult
	
		#< @FunctionAlternativeForms

		def FindStringsCSW(pcCondition, pCaseSensitive)
			return This.FindStringsWCS(pcCondition, pCaseSensitive)

		def FindWCS(pcCondition, pCaseSensitive)
			return This.FindStringsWCS(pcCondition, pCaseSensitive)

			def FindCSW(pcCondition, pCaseSensitive)
				return This.FindStringsWCS(pcCondition, pCaseSensitive)

		def FindAllWCS(pcCondition, pCaseSensitive)
			return This.FindStringsWCS(pcCondition, pCaseSensitive)

			def FindAllCSW(pcCondition, pCaseSensitive)
				return This.FindStringsWCS(pcCondition, pCaseSensitive)

		def RemoveWhereCS(pcCondition, pCaseSensitive)
			return This.FindStringsWCS(pcCondition, pCaseSensitive)

		def RemoveAllWhereCS(pcCondition, pValue, pCaseSensitive)
			return This.FindStringsWCS(pcCondition, pCaseSensitive)

		#>

	def FindStringsW(pcCondition)
		return This.FindStringsWCS(pcCondition, :CaseSensitive = TRUE)
	
		#< @FunctionAlternativeForms

		def FindW(pcCondition)
			return This.FindStringsW(pcCondition)

		def FindAllW(pcCondition)
			return This.FindStringsW(pcCondition)

		def RemoveWhere(pcCondition)
			return This.FindStringsW(pcCondition)

		def RemoveAllWhere(pcCondition, pCaseSensitive)
			return This.FindStringsW(pcCondition)
		#>

	  #====================================================#
	 #     FINDING A SUBSTRING IN THE LIST OF STRINGS     #
	#====================================================#

	def FindSubStringCS(pcSubStr, pCaseSensitive)
		/* Example

		o1 = new stzListOfStrings([
			"What's your name please",
			"Mabrooka",
			"Your name and my name are not the same",
			"I see",
			"Nice to meet you",
			"Mabrooka"
		])

		o1.FindSubstringCS("name", :CaseSensitive = TRUE)
		#--> [ "1" = [ 13 ], "3" = [ 6, 21 ] ]
		*/

		aResult = []
		
		i = 0
		for str in This.ListOfStrings()
			i++
			
			anPos = StzStringQ(str).FindAllCS(pcSubStr, pCaseSensitive)
			if len(anPos) > 0
				aResult + [ ""+ i, anPos ]
			ok
		next

		return aResult

		#< @FunctionAlternativeForms

		def FindAllSubstringsCS(pcSubStr, pCaseSensitive)
			return FindSubStringCS(pcSubStr, pCaseSensitive)

		def FindAllOccurrencesOfSubStringCS(pcSubStr, pCaseSensitive)
			return FindSubStringCS(pcSubStr, pCaseSensitive)

		def PositionsOfSubstringCS(pcSubStr, pCaseSensitive)
			return FindSubStringCS(pcSubStr, pCaseSensitive)

		def AllPositionsOfSubStringCS(pcSubStr, pCaseSensitive)
			return FindSubStringCS(pcSubStr, pCaseSensitive)

		#>

	def FindSubString(pcSubStr)
		return This.FindSubStringCS(pcSubStr, :CaseSensitive = FALSE)

		#< @FunctionAlternativeForms

		def FindAllOccurrencesOfSubString(pcSubStr)
			return This.FindSubString(pcSubStr)

		def PositionsOfSubString(pcSubStr)
			return This.FindSubString(pcSubStr)

		def AllPositionsOfSubString(pcSubStr)
			return This.FindSubString(pcSubStr)

		#>

	   #-------------------------------------------------------#
	  #    NUMBER OF OCCURRENCE OF A SUBSTRING (AS AN ITEM)   #
	 #    INSIDE EACH STRING OF THE LIST OF STRINGS          #
	#-------------------------------------------------------#

	def NumberOfOccurrenceOfSubStringCS(pcStr, pCaseSensitive)
		return len( This.FindSubStringCS(pcStr, pCaseSensitive) )

	def NumberOfOccurrenceOfSubString(pcStr)
		return This.NumberOfOccurrenceOfSubStringCS(pcStr, :CaseSensitive = FALSE)

	  #-------------------------------------------------------------#
	 #  CHECKING IF STRINGS OF THE LIST CONTAIN A GIVEN SUSBTRING  #
	#-------------------------------------------------------------#

	def ContainsSubstringCS(pcSubStr, pCaseSensitive)
		if This.NumberOfOccurrenceOfSubStringCS(pcSubStr, pCaseSensitive) > 0
			return TRUE

		else
			return FALSE
		ok

	def ContainsSubString(pcSubStr)
		return This.ContainsSubStringCS(pcSubStr, :CaseSensitive = TRUE)

	  #-------------------------------------------------------------------#
	 #    FINDING NTH OCCURRENCE OF A SUBTRING IN THE LIST OF STRINGS    #
	#-------------------------------------------------------------------#
	
	def FindNthOccurrenceOfSubStringCS(n, pcSubStr, pCaseSensitive)

		/* Example

		o1 = new stzListOfStrings([
			"What's your name please",
			"Mabrooka",
			"Your name and my name are not the same",
			"I see",
			"Nice to meet you",
			"Mabrooka"
		])

		o1.FindSubstringCS("name", :CaseSensitive = TRUE)
		#--> [ "1" = [ 13 ], "3" = [ 6, 21 ] ]
		*/

		if isString(n)
			if n = :first
				n = 1
			but n = :Last
				n = This.NumberOfOccurrenceOfSubstringCS(pcSubStr, pCaseSensitive)
			ok
		ok

		if NOT (isNumber(n) and n <= This.NumberOfOccurrenceOfSubstringCS(pcSubStr, pCaseSensitive))
			raise("Incorrect param! n must be a number <= number of occurrences of the substring in all the strings.")
		ok

		aPositionsXT = This.FindSubStringCS(pcSubStr, pCaseSensitive)

		// The position to search for inside aPositionsXT

		anResult = []
		i = 0
		for aPair in aPositionsXT
			cLevel = aPair[1]
			anPositions = aPair[2]
			q = 0

			for nPos in anPositions
				i++
				q++
				if i = n
					anResult = [ cLevel, anPositions[q] ]
					exit 2
				ok
			next
		next

		return anResult

		def FindNthSubStringCS(n, pcSubStr, pCaseSensitive)
			return This.FindNthOccurrenceOfStringCS(n, pcSubStr, pCaseSensitive)

		def FindNthOccurrenceOfThisSubStringCS(n, pcSubStr, pCaseSensitive)
			return This.FindNthOccurrenceOfStringCS(n, pcSubStr, pCaseSensitive)

	def FindNthOccurrenceOfSubString(n, pcSubStr)
		return This.FindNthOccurrenceOfSubStringCS(n, pcSubStr, :CaseSensitive = TRUE)

		def FindNthSubString(n, pcSubStr)
			return This.FindNthOccurrenceOfSubString(n, pcSubStr)

		def FindNthOccurrenceOfThisSubString(n, pcSubStr)
			rreturn This.FindNthOccurrenceOfSubString(n, pcSubStr)
	#--

	def FindFirstOccurrenceOfSubStringCS(pcSubStr, pCaseSensitive)
		return This.FindNthOccurrenceOfSubStringCS(1, pcSubStr, :CaseSensitive = TRUE)

		def FindFirstSubStringCS(pcSubStr, pCaseSensitive)
			return This.FindFirstOccurrenceOfSubStringCS(pcSubStr, pCaseSensitive)

		def FindFirstOccurrenceOfThisSubStringCS(pcSubStr, pCaseSensitive)
			return This.FindFirstOccurrenceOfSubStringCS(pcSubStr, pCaseSensitive)

	def FindFirstOccurrenceOfSubString(pcSubStr)
		return This.FindFirstOccurrenceOfSubStringCS(pcSubStr, :CaseSensitive = TRUE)

		def FindFirstSubString(pcSubStr)
			return This.FindFirstOccurrenceOfSubString(pcSubStr)

		def FindFirstOccurrenceOfThisSubString(pcSubStr)
			return This.FindFirstOccurrenceOfSubString(pcSubStr)

	#--
	
	def FindLastOccurrenceOfSubStringCS(pcSubStr, pCaseSensitive)
		return This.FindNthOccurrenceOfSubStringCS(:Last, pcSubStr, :CaseSensitive = TRUE)

		def FindLastSubStringCS(pcSubStr, pCaseSensitive)
			return This.FindLastOccurrenceOfSubStringCS(pcSubStr, pCaseSensitive)

		def FindLastOccurrenceOfThisSubStringCS(pcSubStr, pCaseSensitive)
			return This.FindLastOccurrenceOfSubStringCS(pcSubStr, pCaseSensitive)

	def FindLastOccurrenceOfSubString(pcSubStr)
		return This.FindLastOccurrenceOfSubStringCS(pcSubStr, :CaseSensitive = TRUE)

		def FindLastSubString(pcSubStr)
			return This.FindLastOccurrenceOfSubString(pcSubStr)

		def FindLastOccurrenceOfThisSubString(pcSubStr)
			return This.FindLastOccurrenceOfSubString(pcSubStr)

	#----

	def PositionsOfSubstringAsFlatListCS(pcSubStr, pCaseSensitive)
		aPositionsXT = This.FindSubStringCS(pcSubStr, pCaseSensitive)

		aResult = []

		for aPair in aPositionsXT
			anPos = aPair[2]

			for n in anPos	
				aResult + n
			next
		next

		return aResult

	def PositionsOfSubstringAsFlatList(pcSubStr)
		return This.PositionsOfSubstringAsFlatListCS(pcSubStr, :CaseSensitive = TRUe)

	  #------------------------------------------------#
	 #   FINDING MANY SUBSTRINGS AT THE SAME TIME     #
	#------------------------------------------------#

	def FindSubStringsCS(pacStr, pCaseSensitive)
		/* Example

		o1 = new stzListOfStrings([
			"What's your name please",
			"Mabrooka",
			"Your name and my name are not the same",
			"I see",
			"Nice to meet you",
			"Mabrooka"
		])

		o1.FindSubStringsCS("name", :CaseSensitive = TRUE)
		#--> [ "1" = [ 13 ], "3" = [ 6, 16, 21 ] ]
		*/

		/* ... */

		def FindManySubtringsCS(pacStr, pCaseSensitive)
			return This.FindSubStringsCS(pacStr, pCaseSensitive)

		def FindTheseSubStringsCS(pacStr, pCaseSensitive)
			return This.FindSubStringsCS(pacStr, pCaseSensitive)

	def FindSubStrings(pacStr)
		return This.FindSubStringsCS(pacStr, :CaseSensitive = TRUE)

		def FindManySubStrings(pacStr)
			return This.FindSubStrings(pacStr)

		def FindTheseSubStrings(pacStr)
			return This.FindSubStrings(pacStr)

	def FindSubstringsCSXT(pacSubStr, pCaseSensitive)
		/* Example

		o1 = new stzListOfStrings([
			"What's your name please",
			"Mabrooka",
			"Your name and my name are not the same",
			"I see",
			"Nice to meet you",
			"Mabrooka"
		])

		o1.FindManySubstringsCSXT("name", :CaseSensitive = TRUE)
		#--> [
		#	:name = [ "1" = [ 13 ], "3" = [ 6, 21 ] ],
		#	:nice = [ "3" = [ 16 ]
		#    ]
		*/

		if NOT ( isList(pacSubStr) and Q(pacSubStr).IsListOfStrings() )
			raise("Incorrect param type! You must provide a list of strings.")
		ok

		if len(pacSubStr) = 0
			return []
		ok

		pacSubStr = StzListQ(pacSubStr).ToSet()
		aResult = []

		for cSubStr in pacSubStr
			anPos = This.FindSubstringCS(cSubStr, pCaseSensitive)
			if len(anPos) > 0
				aResult + [ cSubStr, anPos ]
			ok
		next

		return aResult

		#< @FunctionAlternativeForms

		def FindSubStringsXTCS(pacStr, pCaseSensitive)
			return This.FindSubStringsCSXT(pacStr, pCaseSensitive)

		def FindManySubStringsCSXT(pacStr, pCaseSensitive)
			return This.FindSubStringsCSXT(pacStr, pCaseSensitive)

			def FindManySubStringsXTCS(pacStr, pCaseSensitive)
				return This.FindSubStringsCSXT(pacStr, pCaseSensitive)

		def FindTheseSubStringsCSXT(pacStr, pCaseSensitive)
			return This.FindSubStringsCSXT(pacStr, pCaseSensitive)

			def FindTheseSubStringsXTCS(pacStr, pCaseSensitive)
				return This.FindSubStringsCSXT(pacStr, pCaseSensitive)

		#>

	  #-------------------------------------------------------#
	 #    FINDING SUBSSTRINGS VERIYING A GIVEN CONDITION     #
	#-------------------------------------------------------#

	def FindSubStringsWCS(pcCondition, pCaseSensitive)
		/* Exemple

		o1 = new stzListOfStrings([
			"How many roads must a man walk down",
			"Before you call him a man?",
			"How many seas must a white dove sail",
			"Before she sleeps in the sand?",
			"And how many times must the cannonballs fly",
			"Before they're forever banned?",
			"The answer, my friend, is blowin' in the wind",
			"The answer is blowin' in the wind"
		]

		o1.FindSubStringsWCS('@substr = many' , :CaseSensitive = FALSE)
		# --> [
		#	"1" = [ 5 ],
		#	"3" = [ 5 ],
		#	"5" = [ 9 ]
		#     ]

		 */

		// TODO

		return aResult
	
		#< @FunctionAlternativeForms

		def FindSubStringsCSW(pcCondition, pCaseSensitive)
			return This.FindSubStringsWCS(pcCondition, pCaseSensitive)

		def FindAllSubStringsWCS(pcCondition, pCaseSensitive)
			return This.FindSubStringsWCS(pcCondition, pCaseSensitive)

			def FindAllSubStringsCSW(pcCondition, pCaseSensitive)
				return This.FindSubStringsWCS(pcCondition, pCaseSensitive)

		def FindSubStringsWhereWCS(pcCondition, pCaseSensitive)
			return This.FindSubStringsWCS(pcCondition, pCaseSensitive)

			def FindSubStringsWhereCSW(pcCondition, pCaseSensitive)
				return This.FindSubStringsWCS(pcCondition, pCaseSensitive)

		def FindAllSubStringsWhereCS(pcCondition, pCaseSensitive)
			return This.FindSubStringsWCS(pcCondition, pCaseSensitive)

		#>

	def FindSubStringsW(pcCondition)
		return This.FindSubStringsWCS(pcCondition, :CaseSensitive = FALSE)
	
		#< @FunctionAlternativeForms

		def FindAllSubStringsW(pcCondition)
			return This.FindSubStringsW(pcCondition)

		def FindSubStringsWhere(pcCondition)
			return This.FindSubStringsW(pcCondition)

		def FindAllSubStringsWhere(pcCondition)
			return This.FindSubStringsW(pcCondition)

		#>
