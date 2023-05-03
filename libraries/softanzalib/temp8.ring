	  #====================================================#
	 #   CHECKING IF THE LIST CONTAINS DUPLICATED ITEMS   #
	#====================================================#

	def ContainsDuplicatedItemsCS(pCaseSensitive)
		bResult = FALSE
		nLen = This.NumberOfItems()

		for i = 1 to nLen
			n = This.NumberOfOccurrenceCS(This.Item(i), pCaseSensitive)

			if n > 1
				bResult = TRUE
				exit
			ok
		next

		return bResult

		def ContainsDuplicationsCS(pCaseSensitive)
			return This.ContainsDuplicatedItemsCS(pCaseSensitive)

		def ContainsDuplicatesCS(pCaseSensitive)
			return This.ContainsDuplicatedItemsCS(pCaseSensitive)

	#-- WITHOUT CASESENSITIVITY

	def ContainsDuplicatedStrings()
		return This.ContainsDuplicatedStringsCS(:CaseSensitive = TRUE)
	
		def ContainsDuplications()
			return This.ContainsDuplicatedItems()

		def ContainsDuplicates()
			return This.ContainsDuplicatedItems()

	  #---------------------------------------------#
	 #   CHECHKING IF A GIVEN ITEM IS DUPLICATED   #
	#---------------------------------------------#

	def ContainsDuplicatedCS(pItem, pCaseSensitive)
		if This.NumberOfOccurrencesCS(pItem, pCaseSensitive) > 1
			return TRUE
		else
			return FALSE
		ok

		def ContainsDuplicatedItemCS(pItem, pCaseSensitive)
			return This.ContainsDuplicatedCS(pItem, pCaseSensitive)

		def ContainsThisDuplicatedItemCS(pItem, pCaseSensitive)
			return This.ContainsDuplicatedCS(pItem, pCaseSensitive)

	#-- WITHOUT CASESENSITIVITY

	def ContainsDuplicated(pItem)
		return This.ContainsDuplicatedCS(pItem, :CaseSensitive = TRUE)

		def ContainsDuplicatedItem(pItem)
			return This.ContainsDuplicated(pItem)

		def ContainsThisDuplicatedItem(pItem)
			return This.ContainsDuplicated(pItem)

	  #-----------------------------------------------------#
	 #   CHECHKING IF A GIVEN ITEM IS DUPLICATED N-TIMES   #
	#-----------------------------------------------------#

	def ContainsDuplicatedNTimesCS(n, pItem, pCaseSensitive)
		if This.NumberOfDuplicatesOfItemCS(pItem, pCaseSensitive) = n
			return TRUE
		else
			return FALSE
		ok

		def ContainsThisDuplicatedItemNTimesCS(n, pItem, pCaseSensitive)
			return This.ContainsDuplicatedNTimesCS(n, pItezm, pCaseSensitive)

		def ItemIsDuplicatedNTimesCS(n, pItem, pCaseSensitive)
			return This.ContainsDuplicatedNTimesCS(n, pItem, pCaseSensitive)


	#-- WITHOUT CASESENSITIVITY

	def ContainsDuplicatedNTimes(n, pItem)
		return This.ContainsDuplicatedNTimesCS(n, pItem, :CaseSensitive = TRUE)

		def ContainsThisDuplicatedItemNTimes(n, pItem)
			return This.ContainsDuplicatedNTimes(n, pItem)

		def ItemIsDuplicatedNTimes(n, pItem)
			return This.ContainsDuplicatedNTimes(n, pItem, pItem)

	  #--------------------------------------------#
	 #   HOW MANY TIMES AN ITEM IS DUPLICATED ?   #
	#--------------------------------------------#

	def NumberOfTimesItemIsDuplicatedCS(pItem, pCaseSensitive)
		nResult = 0

		if This.NumberOfOccurrenceCS(pItem, pCaseSensitive) > 1
			nResult = This.NumberOfOccurrence(pItem) - 1
		ok
		
		return nResult

		#< @FunctionAlternativeForms

		def NumberOfTimesThisItemIsDuplicatedCS(pItem, pCaseSensitive)
			return This.NumberOfTimesItemIsDuplicatedCS(pItem, pCaseSensitive)

		#--

		def NumberOfDuplicatesOfItemCS(pItem, pCaseSensitive)
			return This.NumberOfTimesItemIsDuplicatedCS(pItem, pCaseSensitive)

		def NumberOfDuplicationsOfItemCS(pItem, pCaseSensitive)
			return This.NumberOfTimesItemIsDuplicatedCS(pItem, pCaseSensitive)

		def NumberOfDuplicationsOfCS(pItem, pCaseSensitive)
			return This.NumberOfTimesItemIsDuplicatedCS(pItem, pCaseSensitive)

		#>

	#-- WITHOUT CASESENSITIVITY

	def NumberOfTimesStringIsDuplicated(pItem)
		return This.NumberOfTimesStringIsDuplicatedCS(pItem, :CaseSensitive = TRUE)

		#< @FunctionAlternativeForms

		def NumberOfTimesThisItemIsDuplicated(pItem)
			return This.NumberOfTimesItemIsDuplicated(pItem)

		#--

		def NumberOfDuplicatesOfItem(pItem)
			return This.NumberOfTimesItemIsDuplicated(pItem)

		def NumberOfDuplicationsOfItem(pItem)
			return This.NumberOfTimesItemIsDuplicated(pItem)

		def NumberOfDuplicationsOf(pItem)
			return This.NumberOfTimesItemIsDuplicated(pItem)

		#>

	  #--------------------------------------------------#
	 #  CHECKING THE EXISTENCE OF NON DUPLICATED ITEMS  #
	#==================================================#

	def ContainsNonDuplicatedItemsCS(pCaseSensitive)
		bResult = FALSE

		nLen = This.NumberOfItems()
		for i = 1 to nLen
			anPos = This.FindCS(This.Item(i), pCaseSensitive)
			if len(anPos) = 1
				bResult = TRUE
				exit
			ok
		next

		return bResult

		def ContainsNoDuplicationsCS(pCaseSensitive)
			return This.ContainsNonDuplicatedItemsCS(pCaseSensitive)

	#-- WITHOUT CASESENSITIVITY

	def ContainsNonDuplicatedItems()
		return This.ContainsNonDuplicatedItemsCS(:CaseSensitive = TRUE)

		def ContainsNoDuplications()
			return This.ContainsNonDuplicatedItems()

	  #--------------------------------------------#
	 #  GETTING THE LIST OF NON DUPLICATED ITEMS  #
	#--------------------------------------------#

	def NonDuplicatedItemsCS(pCaseSensitive)
		aResult = This.Copy().RemoveDuplicatedItemsCSQ(pCaseSensitive).Content()
		return aResult

	#-- WITHOUT CASESENSITIVITY

	def NonDuplicatedItems()
		return This.NonDuplicatedItemsCS(:CaseSensitive = TRUE)

	  #----------------------------------#
	 #  NUMBER OF NON DUPLICATED ITEMS  #
	#----------------------------------#

	def NumberOfNonDuplicatedItemsCS(pCaseSensitive)
		nResult = len(This.NonDuplicatedItemsCS(pCaseSensitive))
		return nResult

	#-- WITHOUT CASESENSITIVITY

	def NumberOfNonDuplicatedItems()
		return This.NumberOfNonDuplicatedItemsCS(:CaseSensitive = TRUE)

	  #--------------------------------#
	 #  FINDING NON DUPLICATED ITEMS  #
	#--------------------------------#

	def FindNonDuplicatedItemsCS(pCaseSensitive)
		acNonDuplicated = This.NonDuplicatedItemsCS(pCaseSensitive)
		nLen = len(acNonDuplicated)
		anResult = []

		for i = 1 to nLen
			# By defintion, a non duplicated item apprears once
			nPos = This.FindFirstCS(acNonDuplicated[i], pCaseSensitive)
			anResult + nPos
		next

		anResult = Q(anResult).Sorted()
		return anResult

	#-- WITHOUT CASESENSITIVITY

	def FindNonDuplicatedItems()
		return This.FindNonDuplicatedItemsCS(:CaseSensitive = TRUE)

	  #--------------------------------------------#
	 #  NON DUPLICATED ITEMS AND THEIR POSITIONS  #
	#--------------------------------------------#

	def NonDuplicatedItemsAndTheirPositionsCS(pCaseSensitive)

		aNonDuplicated = This.NonDuplicatedItemsCS(pCaseSensitive)
		nLen = len(aNonDuplicated)

		aResult = []
		for i = 1 to nLen
			# By definition, a non duplicated items appears once
			nPos = This.FindFirstCS(aNonDuplicated[i], pCaseSensitive)
			aResult + [ aNonDuplicated[i], nPos ]
		next

		return aResult

		def NonDuplicatedItemsZCS(pCaseSensitive)
			return This.NonDuplicatedItemsAndTheirPositionsCS(pCaseSensitive)

	#-- WITHOUT CASESENSITIVITY

	def NonDuplicatedItemsAndTheirPositions()
		return This.NonDuplicatedItemsAndTheirPositionsCS(:CaseSensitive = TRUE)

		def NonDuplicatedItemsZ()
			return This.NonDuplicatedItemsAndTheirPositions()

	  #--------------------------#
	 #   NUMBER OF DUPLICATES   #
	#==========================#

	def NumberOfDuplicatesCS(pCaseSensitive)

		nResult = len( This.FindDuplicatesCS(pCaseSensitive) )
		return nResult

		def HowManuDuplicatesCS(pCaseSensitive)
			return This.NumberOfDuplicatesCS(pCaseSensitive)

	#-- WITHOUT CASESENSITIVITY

	def NumberOfDuplicates()
		return This.NumberOfDuplicatesCS(:CaseSensitive = TRUE)

		def HowManyDuplicates()
			return This.NumberOfDuplicates()

	  #----------------------#
	 #  FINDING DUPLICATES  #
	#----------------------#

	def FindDuplicatesCS(pCaseSensitive)
		nLen = This.NumberOfItems()
		aTemp = []

		anResult = []
		for i = 1 to nLen

			if NOT Q(aTemp).ContainsCS(This.Item(i), pCaseSensitive)
				aTemp + This.Item(i)
			else
				anResult + i
			ok

		next

		return anResult

	#-- WITHOUT CASESENSITIVITY

	def FindDuplicates()
		return This.FindDuplicatesCS(:CaseSensitive = TRUE)

	  #------------------------------------------------#
	 #  DUPLICATES AND THEIR POSITIONS -- Z/Extended  #
	#------------------------------------------------#

	def DuplicatesAndTheirPositionsCS(pCaseSensitive)
		aDuplicates = This.DuplicatesCS(pCaseSensitive)
		anPositions = This.FindDuplicatesCS(pCaseSensitive)

		aResult = Association([ aDuplicates, anPositions ])
		return aResult


		def DuplicatesZCS(pCaseSensitive)
			return This.DuplicatesAndTheirPositionsCS(pCaseSensitive)

	#-- WITHOUT CASESENSITIVITY

	def DuplicatesAndTheirPositions()
		return This.DuplicatesAndTheirPositionsCS(:CaseSensitive = TRUE)

		def DuplicatesZ()
			return This.DuplicatesAndTheirPositions()

	  #------------------------------------------------#
	 #  DUPLICATES AND THEIR POSITIONS -- UZ/Extended  #
	#------------------------------------------------#

	def DuplicatesAndTheirPositionsUCS(pCaseSensitive)
		aDuplicated = This.DuplicatedItemsCS(pCaseSensitive)
		nLen = len(aDuplicated)

		aResult = []
		for i = 1 to nLen
			anPos = This.FindCSQ(aDuplicated[i], pCaseSensitive).FirstItemRemoved()
			if len(anPos) > 0
				aResult + [ aDuplicated[i], anPos ]
			ok
		next

		return aResult

		def DuplicatesUZCS(pCaseSensitive)
			return This.DuplicatesAndTheirPositionsUCS(pCaseSensitive)

	#-- WITHOUT CASESENSITIVITY

	def DuplicatesAndTheirPositionsU()
		return This.DuplicatesAndTheirPositionsUCS(:CaseSensitive = TRUE)

		def DuplicatesUZ()
			return This.DuplicatesAndTheirPositionsU()

	  #--------------------------------#
	 #   NUMBER OF DUPLICATED ITEMS   #
	#================================#

	def NumberOfDuplicatedItemsCS(pCaseSensitive)
		nResult = len( This.DuplicatedItemsCS(pCaseSensitive) )
		return nResult

		def HowManyDuplicatedItemsCS(pCaseSensitive)
			return This.NumberOfDuplicatedItemsCS(pCaseSensitive)

	#-- WITHOUT CASESENSITIVITY

	def NumberOfDuplicatedItems()
		return This.NumberOfDuplicatedItemsCS(:CaseSensitive = TRUE)

		def HowManyDuplicatedItems()
			return This.NumberOfDuplicatedItems()

	  #----------------------#
	 #   DUPLICATED ITEMS   #
	#----------------------#

	def DuplicatedItemsCS(pCaseSensitive)
		nLen = This.NumberOfItems()
		aResult = []

		for i = 1 to nLen
			if This.NumberOfOccurrenceCS(This.Item(i), pCaseSensitive) > 1 and
			   (NOT Q(aResult).ContainsCS(This.Item(i), pCaseSensitive))

				aResult + This.Item(i)
			ok
		next
		
		return aResult		
		#< @FunctionFluentForm

		def DuplicatedItemsCSQ(pCaseSensitive)
			return This.DuplicatedItemsCSQR(pCaseSensitive, :stzList)

		def DuplicatedItemsCSQR(pCaseSensitive, pcReturntype)
			if isList(pcReturnType) and Q(pcReturnType).IsOneOfTheseNamedParams([ :ReturnedAs, :ReturnAs ])
				pcReturnType = pcReturnType[2]
			ok

			if NOT isString(pcReturnType)
				StzRaise("Incorrect param type! pcReturnType must be a string.")
			ok

			switch pcReturnType
			on :stzList
				return new stzList( This.DuplicatedItemsCS(pCaseSensitive) )

			on :stzListOfStrings
				return new stzListOfStrings( This.DuplicatedItemsCS(pCaseSensitive) )

			on :stzListOfNumbers
				return new stzListOfNumbers( This.DuplicatedItemsCS(pCaseSensitive) )

			on :stzListOfPairs
				return new stzListOfPairs( This.DuplicatedItemsCS(pCaseSensitive) )

			other
				StzRaise("Unsupported return type!")
			off
		#>

	#-- WITHOUT CASESENSITIVITY

	def DuplicatedItems()
		return This.DuplicatedItemsCS(:CaseSensitive = TRUE)
		
		#< @FunctionFluentForm

		def DuplicatedItemsQ()
			return This.DuplicatedItemsQR(:stzList)

		def DuplicatedItemsQR(pcReturntype)
			return This.DuplicatedItemsCSQR(:CaseSensitive = TRUE, pcReturntype)
		#>

	  #------------------------------#
	 #   FINDING DUPLICATED ITEMS   #
	#------------------------------#

	def FindDuplicatedItemsCS(pCaseSensitive)
		anResult = []

		aDuplicated = This.DuplicatedItemsCS(pCaseSensitive)

		nLen = len(aDuplicated)

		for i = 1 to nLen
			anPos = This.FindCS(aDuplicated[i], pCaseSensitive)
			nLenPos = len(anPos)
			for j = 1 to nLenPos
				anResult + anPos[j]
			next
		next

		anResult = Q(anResult).Sorted()
		return anResult

		
		#< @FunctionFluentForm

		def FindDuplicatedItemsCSQ(pCaseSensitive)
			return This.FindDuplicatedItemsCSQR(pCaseSensitive, :stzList)

		def FindDuplicatedItemsCSQR(pCaseSensitive, pcReturntype)
			if isList(pcReturnType) and Q(pcReturnType).IsOneOfTheseNamedParams([ :ReturnedAs, :ReturnAs ])
				pcReturnType = pcReturnType[2]
			ok

			if NOT isString(pcReturnType)
				StzRaise("Incorrect param type! pcReturnType must be a string.")
			ok

			switch pcReturnType
			on :stzList
				return new stzList( This.FindDuplicatedItemsCS(pCaseSensitive) )

			on :stzListOfStrings
				return new stzListOfStrings( This.FindDuplicatedItemsCS(pCaseSensitive) )

			on :stzListOfNumbers
				return new stzListOfNumbers( This.FindDuplicatedItemsCS(pCaseSensitive) )

			on :stzListOfPairs
				return new stzListOfPairs( This.FindDuplicatedItemsCS(pCaseSensitive) )

			other
				StzRaise("Unsupported return type!")
			off
		#>

		#< @FunctionAlternativeForms

		def PositionsOfDuplicatedItemsCS(pCaseSensitive)
			return This.FindDuplicatedItemsCS(pCaseSensitive)

			def PositionsOfDuplicatedItemsCSQ(pCaseSensitive)
				return This.PositionsOfDuplicatedItemsCSQR(pCaseSensitive, :stzList)

			def PositionsOfDuplicatedItemsCSQR(pCaseSensitive, pcReturntype)
				return This.FindDuplicatedItemsCSQR(pCaseSensitive, pcReturntype)

		def DuplicatedItemsPositionsCS(pCaseSensitive)
			return This.FindDuplicatedItemsCS(pCaseSensitive)

			def DuplicatedItemsPositionsCSQ(pCaseSensitive)
				return This.PositionsOfDuplicatedItemsCSQR(pCaseSensitive, :stzList)

			def DuplicatedItemsPositionsCSQR(pCaseSensitive, pcReturntype)
				return This.FindDuplicatedItemsCSQR(pCaseSensitive, pcReturntype)

		#>

	#-- WITHOUT CASESENSITIVITY

	def FindDuplicatedItems()
		return This.FindDuplicatedItemsCS(:CaseSensitive = TRUE)
		
		#< @FunctionFluentForm

		def FindDuplicatedItemsQ()
			return This.FindDuplicatedItemsQR(:stzList)

		def FindDuplicatedItemsQR(pcReturntype)
			if isList(pcReturnType) and Q(pcReturnType).IsOneOfTheseNamedParams([ :ReturnedAs, :ReturnAs ])
				pcReturnType = pcReturnType[2]
			ok

			if NOT isString(pcReturnType)
				StzRaise("Incorrect param type! pcReturnType must be a string.")
			ok

			switch pcReturnType
			on :stzList
				return new stzList( This.FindDuplicatedItems() )

			on :stzListOfNumbers
				return new stzListOfNumbers( This.FindDuplicatedItems() )

			on :stzListOfStrings
				return new stzListOfStrings( This.FindDuplicatedItems() )

			on :stzListOfPairs
				return new stzListOfPairs( This.FindDuplicatedItems() )

			other
				StzRaise("Unsupported return type!")
			off
		#>

		#< @FunctionAlternativeForms

		def PositionsOfDuplicatedItems()
			return This.FindDuplicatedItems()

			def PositionsOfDuplicatedItemsQ()
				return This.PositionsOfDuplicatedItemsQR(:stzList)

			def PositionsOfDuplicatedItemsQR(pcReturntype)
				return This.FindDuplicatedItemsQR(pcReturntype)

		def DuplicatedItemsPositions()
			return This.FindDuplicatedItems()

			def DuplicatedItemsPositionsQ()
				return This.PositionsOfDuplicatedItemsQR(:stzList)

			def DuplicatedItemsPositionsQR(pcReturntype)
				return This.FindDuplicatedItemsCSQR(pcReturntype)

		#>

	  #------------------------------------------#
	 #   DUPLICATED ITEMS AND THEIR POSITIONS   #
	#------------------------------------------#

	def DuplicatedItemsAndTheirPositionsCS(pCaseSensitive)
		aDuplicatedSItems = This.DuplicatedItemsCS(pCaseSensitive)
		nLen = len(aDuplicatedSItems)

		aResult = []
		for i = 1 to nLen
			str = aDuplicatedSItems[i]
			aResult + [ str, This.FindAllCS(str, pCaseSensitive) ]
		next

		return aResult

		#< @FunctionAlternativeForms

		def DuplicatedItemsZCS(pCaseSensitive)
			return This.DuplicatedItemsAndTheirPositionsCS(pCaseSensitive)

		#-- By nature, duplicated items are unique, so for convenience, we can add
		#-- the U extension as alternatives

		def DuplicatedItemsAndTheirPositionsUCS(pCaseSensitive)
			return This.DuplicatedItemsAndTheirPositionsCS(pCaseSensitive)

		def DuplicatedItemsUZCS(pCaseSensitive)
			return This.DuplicatedItemsAndTheirPositionsCS(pCaseSensitive)

		#>

	#-- WITHOUT CASESENSITIVITY

	def DuplicatedItemsAndTheirPositions()
		return This.DuplicatedItemsAndTheirPositionsCS(:CaseSensitive = TRUE)

		#< @FunctionAlternativeForms

		def DuplicatedItemsZ()
			return This.DuplicatedItemsAndTheirPositions()

		#-- By nature, duplicated items are unique, so for convenience, we can add
		#-- the U extension as alternatives

		def DuplicatedItemsAndTheirPositionsU()
			return This.DuplicatedItemsAndTheirPositions()

		def DuplicatedItemsUZ()
			return This.DuplicatedItemsAndTheirPositions()

		#>

	  #-------------------------------------#
	 #   FINDING A GIVEN DUPLICATED ITEM   #
	#-------------------------------------#

	def FindDuplicatedItemCS(pItem, pCaseSensitive)

		anPos = This.FindAllCS(pItem, pCaseSensitive)

		if len(anPos) > 1
			return anPos
		else
			return 0
		ok

		#< @FunctionFluentForm

		def FindDuplicatedItemCSQ(pItem, pCaseSensitive)
			return This.FindDuplicatedItemCSQR(pItem, pCaseSensitive, :stzList)

		def FindDuplicatedItemCSQR(pItem, pCaseSensitive, pcReturnType)
			if isList(pcReturnType) and Q(pcReturnType).IsOneOfTheseNamedParams([ :ReturnedAs, :ReturnAs ])
				pcReturnType = pcReturnType[2]
			ok

			if NOT isString(pcReturnType)
				StzRaise("Incorrect param type! pcReturnType must be a string.")
			ok

			switch pcReturnType
			on :stzList
				return new stzList( This.FindDuplicatedItemCS(pItem, pCaseSensitive) )

			on :stzListOfNumbers
				return new stzListOfNumbers( This.FindDuplicatedSItemCS(pItem, pCaseSensitive) )

			other
				StzRaise("Unsupported return type!")
			off
		#>

		#< @FunctionAlternativeForms

		def FindDuplicatedCS(pItem, pCaseSensitive)
			return This.FindDuplicatedSItemCS(pItem, pCaseSensitive)

			def FindDuplicatedCSQ(pItem, pCaseSensitive)
				return This.FindDuplicatedCSQR(pItem, pCaseSensitive, :stzList)
	
			def FindDuplicatedCSQR(pItem, pCaseSensitive, pcReturnType)
				return This.FindDuplicatedItemCSQR(pItem, :CaseSensitive = TRUE, pcReturnType)

		def PositionsOfDuplicatedItemCS(pItem, pCaseSensitive)
			return This.FindDuplicatedItemCS(pItem, pCaseSensitive)

			def PositionsOfDuplicatedItemCSQ(pItem, pCaseSensitive)
				return This.PositionsOfDuplicatedItemCSQR(pItem, pCaseSensitive, :stzList)

			def PositionsOfDuplicatedItemCSQR(pItem, pCaseSensitive, pcReturnType)
				return This.FindDuplicatedCSQR(pItem, pCaseSensitive, pcReturnType)

		def DuplicatedItemPositionsCS(pItem, pCaseSensitive)
			return This.FindDuplicatedItemCS(pItem, pCaseSensitive)

			def DuplicatedItemPositionsCSQ(pItem, pCaseSensitive)
				return This.PositionsOfDuplicatedItemCSQR(pItem, pCaseSensitive, :stzList)

			def DuplicatedItemPositionsCSQR(pItem, pCaseSensitive, pcReturnType)
				return This.FindDuplicatedCSQR(pItem, pCaseSensitive, pcReturnType)

		#>

	#-- WITHOUT CASESENSITIVITY

	def FindDuplicatedItem(pItem)

		return This.FindDuplicatedItemCS(pItem, :CaseSensitive = TRUE)

		#< @FunctionFluentForm

		def FindDuplicatedItemQ(pItem)
			return This.FindDuplicatedItemQR(pItem, :stzList)

		def FindDuplicatedItemQR(pItem, pcReturnType)
			return This.FindDuplicatedItemCSQR(pItem, :CaseSensitive = TRUE, pcReturnType)
		#>

		#< @FunctionAlternativeForms

		def FindDuplicated(pItem)
			return This.FindDuplicatedSItem(pItem)

			def FindDuplicatedQ(pItem)
				return This.FindDuplicatedQR(pItem, :stzList)
	
			def FindDuplicatedQR(pItem, pcReturnType)
				return This.FindDuplicatedItemQR(pItem, pcReturnType)

		def PositionsOfDuplicatedItem(pItem)
			return This.FindDuplicatedItem(pItem)

			def PositionsOfDuplicatedItemQ(pItem)
				return This.PositionsOfDuplicatedItemQR(pItem, :stzList)

			def PositionsOfDuplicatedItemQR(pItem, pcReturnType)
				return This.FindDuplicatedQR(pItem, pcReturnType)

		def DuplicatedItemPositions(pItem)
			return This.FindDuplicatedItem(pItem)

			def DuplicatedItemPositionsQ(pItem)
				return This.PositionsOfDuplicatedItemQR(pItem, :stzList)

			def DuplicatedItemPositionsQR(pItem, pcReturnType)
				return This.FindDuplicatedQR(pItem, pcReturnType)

		#>

	  #----------------------------------------#
	 #   FINDING DUPLICATES OF A GIVEN ITEM   #
	#----------------------------------------#

	def FindDuplicatesOfItemCS(pItem, pCaseSensitive)
		anPos = This.FindAllCS(pItem, pCaseSensitive)
		nLen = len(anPos)

		anResult = []

		if nLen > 1
			anResult = Q(anPos).FirstItemRemoved()
		ok

		return anResult
		

		def PositionsOfDuplicatesOfItemCS(pItem, pCaseSensitive)
			return This.FindDuplicatesOfItemCS(pItem, pCaseSensitive)

	#-- WITHOUT CASESENSITIVITY

	def FindDuplicatesOfItem(pItem)
		return This.FindDuplicatesOfItemCS(pItem, :CaseSensitive = TRUE)

		def PositionsOfDuplicatesOfItem(pItem)
			return This.FindDuplicatesOfItem(pItem)

	  #-----------------------------------------#
	 #   REMOVING ALL DUPLICATES IN THE LIST   #
	#-----------------------------------------#

	def RemoveDuplicatesCS(pCaseSensitive)

		if isList(pCaseSensitive) and Q(pCaseSensitive).IsCaseSensitiveNamedParam()
			pCaseSensitive = pCaseSensitive[2]
		ok

		if NOT ( isNumber(pCaseSensitive) and IsBoolean(pCaseSensitive) )
			StzRaise("Incorrect param! pCaseSensitive must be TRUE or FALSE.")
		ok

		# If we are lucky, we use directly a Qt-based solution
		if pCaseSensitive = TRUE and This.IsListOfStrings()
			
			aTemp = QStringListObject().removeDuplicates()
			This.Update(aTemp)
			return
		ok

		# Otherwise, we do it by ourselves
		anPos = This.FindDuplicatesCS(pCaseSensitive)
		This.RemoveItemsAtPositions(anPos)


		def RemoveDuplicatesCSQ(pCaseSensitive)
			This.RemoveDuplicatesCS(pCaseSensitive)
			return This

	def DuplicatesRemovedCS(pCaseSensitive)
		acResult = This.Copy().RemoveDuplicatesCSQ(pCaseSensitive).Content()
		return acResult

		#< @FunctionAlternativeForms

		def ToSetCS(pCaseSensitive)
			return This.DuplicatesRemovedCS(pCaseSensitive)

		def ToSetOfItemsCS(pCaseSensitive)
			return This.DuplicatesRemovedCS(pCaseSensitive)

		def UniqueItemsCS(pCaseSensitive)
			return This.DuplicatesRemovedCS(pCaseSensitive)

		def UniqueStringItemsCS(pCaseSensitive)
			return This.DuplicatesRemovedCS(pCaseSensitive)

		def ItemsUCS(pCaseSensitive)
			return This.DuplicatesRemovedCS(pCaseSensitive)

		#>

	#-- WITHOUT CASESENSITIVITY

	def RemoveDuplicates()
		This.RemoveDuplicatesCS(:CaseSensitive = TRUE)

		def RemoveDuplicatesQ()
			This.RemoveDuplicates()
			return This

	def DuplicatesRemoved()
		acResult = This.Copy().RemoveDuplicatesQ().Content()
		return acResult

		#< @FunctionAlternativeForms

		def ToSet()
			return This.DuplicatesRemoved()

		def ToSetOfItems()
			return This.DuplicatesRemoved()

		def UniqueItems()
			return This.DuplicatesRemoved()

		def UniqueStringItems()
			return This.DuplicatesRemoved()

		def ItemsU()
			return This.DuplicatesRemoved()

		#>

  	  #-----------------------------------------#
	 #   REMOVING DUPLICATES OF A GIVEN ITEM   #
	#-----------------------------------------#

	def RemoveDuplicatesOfItemCS(pItem, pCaseSensitive)
		anPositions = This.FindDuplicatesOfItemCS(pItem, pCaseSensitive)
		This.RemoveItemsAtPositions(anPositions)

		#< @FunctionFluentForm

		def RemoveDuplicatesOfItemCSQ(pItem, pCaseSensitive)
			This.RemoveDuplicatesOfItemCS(pItem, pCaseSensitive)
			return This

		#>

		#< @FunctionAlternativeForm

		def RemoveDuplicatesOfThisItemCS(pItem, pCaseSensitive)
			This.RemoveDuplicatesOfItemCS(pItem, pCaseSensitive)

			def RemoveDuplicatesOfThisItemCSQ(pItem, pCaseSensitive)
				This.RemoveDuplicatesOfThisItemCS(pItem, pCaseSensitive)
				return This

		#>

	def DuplicatesOfItemRemovedCS(pItem, pCaseSensitive)

		aResult = This.Copy().
				RemoveDuplicatesOfItemCSQ(pItem, pCaseSensitive).
				Content()

		return aResult

		#< @FunctionAlternativeForm

		def DuplicatesOfThisItemRemovedCS(pItem, pCaseSensitive)
			return This.DuplicatesOfItemRemovedCS(pItem, pCaseSensitive)

		#>

	#-- WITHOUT CASESENSITIVITY

	def RemoveDuplicatesOfString(pItem)
		This.RemoveDuplicatesOfStringCS(pItem, :CaseSensitive = TRUE)

		#< @FunctionFluentForm

		def RemoveDuplicatesOfItemQ(pItem)
			This.RemoveDuplicatesOfItem(pItem)
			return This

		#>

		#< @FunctionAlternativeForm

		def RemoveDuplicatesOfThisItem(pItem)
			This.RemoveDuplicatesOfItem(pItem)

			def RemoveDuplicatesOfThisItemQ(pItem)
				This.RemoveDuplicatesOfThisItem(pItem)
				return This

		#>

	def DuplicatesOfItemRemoved(pItem)
		return This.DuplicatesOfItemRemovedCS(pItem, :CaseSensitive = TRUE)

		#< @FunctionAlternativeForms

		def DuplicatesOfThisItemRemoved(pItem)
			return This.DuplicatesOfItemRemoved(pItem)

		#>

	  #---------------------------------------------#
	 #   REMOVING DUPLICATES OF MANY GIVEN ITEMS   #
	#---------------------------------------------#

	def RemoveDuplicatesOfItemsCS(paItems, pCaseSensitive)

		if NOT isList(paItems)
			StzRaise("Incorrect param! paItems must be a list.")
		ok

		nLen = len(paItems)

		for i = 1 to nLen
			This.RemoveDuplicatesOfItemCS(paItems[i], pCaseSensitive)
		next

		#< @FuntionFluentForm

		def RemoveDuplicatesOfItemsCSQ(paItems, pCaseSensitive)
			This.RemoveDuplicatesOfItemsCS(paItems, pCaseSensitive)
			return This

		#>

		#< @FunctionAlternativeForms

		def  RemoveDuplicatesOfTheseItemsCS(paItems, pCaseSensitive)
			This.RemoveDuplicatesOfItemsCS(paItems, pCaseSensitive)

			def RemoveDuplicatesOfTheseItemsCSQ(paItems, pCaseSensitive)
				This.RemoveDuplicatesOfTheseItemsCS(paItems, pCaseSensitive)
				return This

		#>
		
	#-- WITHOUT CASESENSITIVITY

	def RemoveDuplicatesOfItems(paItems)
		This.RemoveDuplicatesOfItemsCS(paItems, :CaseSensitive = TRUE)

		#< @FuntionFluentForm

		def RemoveDuplicatesOfItemsQ(paItems)
			This.RemoveDuplicatesOfItems(paItems)
			return This

		#>

		#< @FunctionAlternativeForms

		def RemoveDuplicatesOfTheseItems(paItems)
			This.RemoveDuplicatesOfItems(paItems)

			def RemoveDuplicatesOfTheseItemsQ(paItems)
				This.RemoveDuplicatesOfTheseItems(paItems)
				return This

		#>

	  #-----------------------------#
	 #  REMOVING DUPLICATED ITEMS  #
	#-----------------------------#

	def RemoveDuplicatedItemsCS(pCaseSensitive)
		anPos = This.FindDuplicatedItemsCS(pCaseSensitive)

		if len(anPos) > 0
			This.RemoveItemsAtPositions(anPos)
		ok

		#< @FunctionFluentForm

		def RemoveDuplicatedItemsCSQ(pCaseSensitive)
			This.RemoveDuplicatedItemsCS(pCaseSensitive)
			return This

		#>

	def DuplicatedItemsRemovedCS(pCaseSensitive)
		aResult = This.Copy().RemoveDuplicatedItemsCSQ(pCaseSensitive).Content()
		return aResult

	#-- WITHOUT CASESENSITIVITY

	def RemoveDuplicatedItems()
		return This.RemoveDuplicatedItemsCS(:CaseSensitive = TRUE)

		#< @FunctionFluentForm

		def RemoveDuplicatedItemsQ()
			This.RemoveDuplicatedItems()
			return This

		#>

	def DuplicatedItemssRemoved()
		acResult = This.Copy().RemoveDuplicatedItemsQ().Content()
		return acResult

