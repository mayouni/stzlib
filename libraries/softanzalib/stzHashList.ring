#---------------------------------------------------------------------------#
# 		    SOFTANZA LIBRARY (V1.0) - STZHASHLIST		    #
#		An accelerative library for Ring applications		    #
#---------------------------------------------------------------------------#
#									    #
# 	Description	: The core class for managing hash lists            #
#	Version		: V1.0 (2020-2023)				    #
#	Author		: Mansour Ayouni (kalidianow@gmail.com)		    #
#									    #
#---------------------------------------------------------------------------#

/*
	Example 1:
		o1 = new stzHashList(4)
		o1 { SetKeyValue[ :name = "mansour" ] Show() }

	Example 2:
 		o1 = new stzHashList([ :name = "mansour", :age = 44, :job = "programmer" ])
		o1 { Show() }
*/

func StzHashListQ(paList)
	return new stzHashList(paList)

func StzNamedHashList(paNamed)
	if CheckParams()
		if NOT (isList(paNamed) and Q(paNamed).IsPair() and isString(paNamed[1]) and Q(paNamed[2]).IsHashList())
			StzRaise("Incorrect param type! paNamed must be a pair of string and list of type stzHashList.")
		ok
	ok

	oStzHashList = StzHashListQ(paNamed[2])
	oStzHashList.SetName(paNamed[1])
	return oStzHashList

	func StzNamedHashListQ(paNamed)
		return StzNamedHashList(paNamed)

	func StzHashListXTQ(paNamed)
		return StzNamedHashList(paNamed)

func ListIsPairAndKeyIsString(paPair)
	if isList(paPair) and Q(paPair).IsPairAndKeyIsString()
		return TRUE
	else
		return FALSE
	ok

func StzAssociativeListQ(paList)
	return new stzAssociativeList(paList)

class stzAssociativeList from stzHashList

class stzHashList from stzList # Also called stzAssociativeList
	// Key-valye list where key is string
	@aContent = []

	  #--------------#
	 #     INIT     #
	#--------------#

	def init(p)

		switch ring_type(p)
		on "NUMBER"
			aResult = []
			for i = 1 to p
				aResult + [ "k" + i , NULL ]
			next
			@aContent = aResult

		on "LIST"
			
			if StzListQ(p).IsHashList()
				/*
				There is a bug in Ring 1.14 (4th, may. 2021)
				Read about it here: https://groups.google.com/g/ring-lang/c/fY6Lh-LDwJg

				The bug occurs when you privide a hashlist using the '=' syntax
				and you have the keys containing numbers, like this:

				aList = [
					"1" = [ "text 1", 100 ],
					"2" = [ "text 2", 200 ],
					"3" = [ "text 3", 300 ]
				]

				In this case, the keys dissapear completely from the list.

				So if you look for Content() or Keys() you don't find them.
				More interestingly, if you won't be able to access the list using them 

				UPDATE: This has been resolved in Ring 1.16 I think...
				--> Check it and if so, remove this comment!
				*/

				# Lowercasing all the keys of the hashlist
				nLen = len(p)
				for i = 1 to nLen
					p[i][1] = StzStringQ(p[i][1]).Lowercased()
				next

				@aContent = p

			else
				StzRaise("The list you provided is not a hash list!")
			ok

		other
			StzRaise("Unsupported form of the input of the hashlist!")
		off

	  #-------------#
	 #     GET     #
	#-------------#

	def Content()
		return @aContent

	def HashList()
		return This.Content()

	def NumberOfPairs()
		return len(This.Content())

		def NumberOfPairsQ()
			new stzNumber(This.NumberOfPairs())

		def NumberOfKeys()
			return This.NumberOfPairs()

		def NumberOfValues()
			return This.NumberOfPairs()

		def HowManyPairs()
			return This.NumberOfPairs()

		def HowManyPair()
			return This.NumberOfPairs()

		def HowManyKeys()
			return This.NumberOfPairs()

		def HowManyKey()
			return This.NumberOfPairs()

		def HowManyValues()
			return This.NumberOfPairs()

		def HowManyValue()
			return This.NumberOfPairs()

	def Pairs()
		return Content()

		def PairsQ()
			return This.PairsQR(:stzList)

		def PairsQR(pcReturnType)
			if isList(pcReturnType) and Q(pcReturnType).IsOneOfTheseNamedParams([ :ReturnedAs, :ReturnAs ])
				pcReturnType = pcReturnType[2]
			ok

			if NOT isString(pcReturnType)
				StzRaise("Incorrect param! pcReturnType must be a string.")
			ok

			switch pcReturnType

			on :stzList
				return new stzList( This.Pairs() )

			on :stzListOfPairs
				return new stzListOfPairs( This.Keys() )

			other
				StzRaise("Unsupported return type!")
			off


	def Keys()
		aResult = []
		for i = 1 to This.NumberOfPairs()
			aResult + This.Content()[i][1]
		next
		return aResult

		def KeysQ()
			return This.KeysQR(:stzList)

		def KeysQR(pcReturnType)
			if isList(pcReturnType) and Q(pcReturnType).IsOneOfTheseNamedParams([ :ReturnedAs, :ReturnAs ])
				pcReturnType = pcReturnType[2]
			ok

			if NOT isString(pcReturnType)
				StzRaise("Incorrect param! pcReturnType must be a string.")
			ok

			switch pcReturnType

			on :stzList
				return new stzList( This.Keys() )

			on :stzListOfStrings
				return new stzListOfStrings( This.Keys() )

			other
				StzRaise("Unsupported return type!")
			off

	def KeysForValue(pValue)
		aResult = []

		for aPair in This.HashList()
			if Q(aPair[2]).IsStrictlyEqualTo(pValue)
				aResult + aPair[1]
			ok
		next

		return aResult

		#< @FunctionFluentForms

		def KeysForValueQ()
			return This.KeysForValueQR(:stzList)

		def KeysForValueQR(pcReturnType)
			if isList(pcReturnType) and Q(pcReturnType).IsOneOfTheseNamedParams([ :ReturnedAs, :ReturnAs ])
				pcReturnType = pcReturnType[2]
			ok

			if NOT isString(pcReturnType)
				StzRaise("Incorrect param! pcReturnType must be a string.")
			ok

			switch pcReturnType

			on :stzList
				return new stzList( This.KeysForValue() )

			on :stzListOfStrings
				return new stzListOfStrings( This.KeysForValue() )

			other
				StzRaise("Unsupported return type!")
			off
			
		#>

		#< @FunctionAlternativeForms

		def KeysForThisValue(pValue)
			return This.KeysForValue(pValue)

			def KeysForThisValueQ(pValue)
				return This.KeysForValueQ(pValue)

			def KeysForThisValueQR(pValue, pcReturnType)
				return This.KeysForValueQ(pValue, pcReturnType)

		#>

	def Values()
		aResult = []
		for i = 1 to This.NumberOfPairs()
			aResult + This.Content()[i][2]
		next
		return aResult

		def ValuesQ()
			return This.ValuesQR(:stzList)

		def ValuesQR(pcReturnType)
			if isList(pcReturnType) and StzListQ(pcReturnType).IsOneOfTheseNamedParams([ :ReturnedAs, :ReturnAs ])
				pcReturnType = pcReturnType[2]
			ok

			switch pcReturnType
			on :stzList
				return new stzList( This.Values() )

			on :stzListOfNumbers
				return new stzListOfNumbers( This.Values() )

			on :stzListOfStrings
				return new stzListOfStrings( This.Values() )

			on :stzListOfLists
				return new stzListOfLists( This.Values() )

			on :stzListOfObjects
				return new stzListOfObjects( This.Values() )
			other
				StzRaise("Unsupported return type!")
			off

	def ValuesAreListsOfSameSize()
		bResult = TRUE
		for i = 2 to This.NumberOfValues()

		next

		return bResult

	def ValuesAndKeys()
		aResult = []

		i = 0
		for value in This.Values()
			i++
			aResult + [ value, This.NthKey(i) ]
		next

		return aResult

	def PerformOnKeys(pcCode) # TODO: Test and review using stzCCode interpolate()
		/*
		PerformOnKeys('@key += @i')
		*/

		cCode = StzStringQ(pcCode).TrimQ().BoundsRemoved(["{", "}"])

		for @i = 1 to This.NumberOfPairs()
			@key = This.NthKey(@i)		
			eval(cCode)

			if Q(@Key).ExistsIn( This.Keys() )
				StzRaise("Can't update a key with the value of an existant key!")

			else
				This.ReplaceNthKey(@i, :With = @key)
			ok
		next

		def PerformOnKeysQ(pcCode)
			This.PerformOnKeys(pcCode)
			return This


	def PerformOnValues(pcCode) #  # TODO: Test and review using stzCCode interpolate()
		/*
		PerformOnValues('@value += @i')
		*/

		cCode = StzStringQ(pcCode).TrimQ().BoundsRemoved(["{", "}"])

		for @i = 1 to This.NumberOfPairs()
			@value = This.NthValue(@i)
			eval(pcCode)
			This.ReplaceNthValue(@i, :With = @value)
		next

		def PerformOnValuesQ(pcCode)
			This.PerformOnValues(pcCode)
			return This


	def NthKey(n)
		if isString(n)
			if n = :First or n = :FirstKey
				n = 1

			but n = :Last or n = :LastKey
				n = This.NumberOfKeys()
			ok
		ok

		if NOT isNumber(n)
			StzRaise("Incorrect param type! n should be a number.")
		ok

		if n > 0
			return This.Content()[n][1]
		ok

		def NthKeyQ(n)
			return new stzString(This.NthKey())

	def Key(n)
		return This.NthKey(n)

		def KeyQ(n)
			return new stzString(This.Key(n))
	
	def NthValue(n)
		if isString(n)
			if n = :First or n = :FirstValue
				n = 1

			but n = :Last or n = :LastValue
				n = This.NumberOfValues()
			ok
		ok

		return This.Content()[n][2]

		def NthValueQ(n)
			return Q(This.NthValue())

		def Value(n)
			return This.NthValue(n)

			def ValueQ(n)
				return Q( This.Value(n) )

	def FirstValue()
		return This.NthValue(1)

		def FirstValueQ()
			return This.NthValueQ(1)
	
	def LastValue()
		return This.NthValue(This.NumberOfValues())

		def LastValueQ()
			return Q( This.LastValue() )
	
	def NthPair(n)
		if isString(n)
			if n = :First or n = :FirstPair
				n = 1

			but n = :Last or n = :LastPair
				n = This.NumberOfPairs()
			ok
		ok

		if NOT isNumber(n)
			StzRaise("Incorrect param type! n should be a number.")
		ok

		return This.Content()[n]

		#< @FunctionFluentForm

		def NthPairQ(n)
			return This.NthPairQR(n, :stzList)

		def NthPairQR(n, pcReturnType)
			if isList(pcReturnType) and Q(pcReturnType).IsReturnedAsNamedParam()
				pcReturnType = pcReturnType[2]
			ok

			if NOT ( isString(pcReturnType) and Q(pcReturnType).IsAStzClassName() )
				StzRaise("Incorrect param! pcReturnType must be a string containing the name of a Softanza class.")
			ok

			switch pcReturnType
			on :stzList
				return new stzList(This.NthPair(n))
			on :stzPair
				return new stzpair(This.NthPair(n))
			other
				StzRaise("Unsupported return type!")
			off

		#>

		#< @FunctionAlternativeForm
	
		def Pair(n)
			return This.NthPair(n)
	
			def PairQ(n)
				return This.NthPairQ(n)

			def PairQR(n, pcReturnType)
				return This.NthPairQR(n, pcReturnType)
	
		#>
	
	def FirstPair()
		return This.NthPair(n)

		def FirstPairQ()
			return This.NthPairQ(1)

	def LastPair()
		return This.LastPair(n)

		def LastPairQ()
			return This.NthPairQ(This.NumberOfPairs())

	def KeyInPair(paPair)
		if isList(paPair) and ListIsPairAndKeyIsString(paPair) and
		   This.ContainsPair(paPair)
			return paPair[1]

		else
			StzRaise("Invalid param type!")
		ok

		def KeyInPairQ(paPair)
			return new stzString( This.KeyInPair(paPair) )
	
		def KeyInThisPair(paPair)
			return This.KeyInPair(paPair)

			def KeyInThisPairQ(paPair)
				return This.KeyInPairQ(paPair)

	def ValueInPair(paPair)
		if isList(paPair) and ListIsPairAndKeyIsString(paPair) and
	           This.ContainsPair(paPair)
			return paPair[2]
		else
			StzRaise("Invalide param type!")
		ok

		def ValueInPairQ(paPair)
			return Q( This.ValueInPair(paPair) )

		def ValueInThisPair(paPair)
			return This.ValueInPair(paPair)

			def ValueInThisPairQ(paPair)
				return This.ValueInPairQ(paPair)

	def KeyInNthPair(n)
		return This.NthPair(n)[1]

		def KeyInNthPairQ(n)
			return new stzString( This.KeyInNthPair(n) )
	
	def ValueInInNthPair(n)
		return This.NthPair(n)[2]

	def ValueInNthPairQ(n)
		return Q( This.ValueInNthPair(n) )

	def ValueByKey(pcKey)
		return This.Content()[ pcKey ]

		#< @FunctionAlternativeForms

		def ValueRelatedToKey(pcKey)
			return This.ValueByKey(pcKey)

		def ValueRelatedToThisKey(pcKey)
			return This.ValueByKey(pcKey)

		def ValueCorrespondingToKey(pcKey)
			return This.ValueByKey(pcKey)

		def ValueCorrespondingToThisKey(pcKey)
			return This.ValueByKey(pcKey)

		def ValueOnKey(pcKey)
			return This.ValueByKey(pcKey)

		def ValueOnThisKey(pcKey)
			return This.ValueByKey(pcKey)

		def ValueOfKey(pcKey)
			return This.ValueByKey(pcKey)

		def ValueOfThisKey(pcKey)
			return This.ValueByKey(pcKey)

		def ValueInKey(pcKey)
			return This.ValueByKey(pcKey)

		def ValueInThisKey(pcKey)
			return This.ValueByKey(pcKey)

		#>

	def NumberOfOccurrenceOfValue(pValue)
		return len(This.FindValue(pValue))

		#< @FunctionAlternativeForms

		def NumberOfOccurrencesOfValue(pValue)
			return This.NumberOfOccurrenceOfValue(pValue)

			def NumberOfOccurrenceOfValueQ(pValue)
				return new stzNumber(This.NumberOfOccurrenceOfValue(pValue))
		
			def NumberOfOccurrencesOfValueQ(pValue)
				return NumberOfOccurrenceOfValueQ(pValue)

		def HowManyOccurrenceOfValue(pValue)
			return This.NumberOfOccurrenceOfValue(pValue)

		def HowManyOccurrencesOfValue(pValue)
			return This.NumberOfOccurrenceOfValue(pValue)

		#--

		def NumberOfOccurrenceOfThisValue(pValue)
			return This.NumberOfOccurrenceOfValue(pValue)

		def NumberOfOccurrencesOfThisValue(pValue)
			return This.NumberOfOccurrenceOfValue(pValue)

			def NumberOfOccurrenceOfThisValueQ(pValue)
				return new stzNumber(This.NumberOfOccurrenceOfValue(pValue))
		
			def NumberOfOccurrencesOfThisValueQ(pValue)
				return NumberOfOccurrenceOfValueQ(pValue)

		def HowManyOccurrenceOfThisValue(pValue)
			return This.NumberOfOccurrenceOfValue(pValue)

		def HowManyOccurrencesOfThisValue(pValue)
			return This.NumberOfOccurrenceOfValue(pValue)

		#>

	def UniqueValues()
		aResult = This.ValuesQ().DuplicatesRemoved()
		return aResult

		def ValuesU()
			return This.UniqueValues()

		def ValuesWithoutDuplication()
			return This.UniqueValues()

	def ValuesAtPositions(anPositions)
		aResult = This.ValuesQ().ItemsAtPositions(anPositions)
		return aResult

		def ValuesAtThesePositions(anPositions)
			return This.ValuesAtPositions(anPositions)

	  #---------------------------#
	 #   UPDATING THE HASHLIST   #
	#---------------------------#

	def Update(paNewHashList)
		if isList(paNewHashList) and Q(paNewHashList).IsWithOrByOrUsingNamedParam()
			paNewHashList = paNewHashList[2]
		ok

		if isList(paNewHashList) and StzListQ(paNewHashList).IsHashList()
			@aContent = paNewHashList
		ok

		#< @FunctionAlternativeForms

		def UpdateWith(paNewHashList)
			This.Update(paNewHashList)

			def UpdateWithQ(paNewHashList)
				return This.UpdateQ(paNewHashList)
	
		def UpdateBy(paNewHashList)
			This.Update(paNewHashList)

			def UpdateByQ(paNewHashList)
				return This.UpdateQ(paNewHashList)

		def UpdateUsing(paNewHashList)
			This.Update(paNewHashList)

			def UpdateUsingQ(paNewHashList)
				return This.UpdateQ(paNewHashList)

		#>

	def Updated(paNewHashList)
		return paNewHashList

		#< @FunctionAlternativeForms

		def UpdatedWith(paNewHashList)
			return This.Updated(paNewHashList)

		def UpdatedBy(paNewHashList)
			return This.Updated(paNewHashList)

		def UpdatedUsing(paNewHashList)
			return This.Updated(paNewHashList)

		#>

	#---

	def UpdateNthPair(n, paNewPair)

		if n = :First
			n = 1
		but n = :Last
			n = This.NumberOfPairs()
		ok

		if isList(paNewPair) and ListIsPairAndKeyIsString(paNewPair)

			This.UpdateNthKey(n, paNewPair[1])
			This.UpdateNthValue(n, paNewPair[2])
		else
			StzRaise("Key must be a string!")
		ok
	
	def UpdatePair(paPair, paNewPair)
		if isList(paPair) and ListIsPairAndKeyIsString(paNewPair) and
		   This.ContainsPair(paPair)
			n = This.FindPair(paPair)

			This.UpdateNthKey(n, paNewPair[1])
			This.UpdateNthValue(n, paNewPair[2])
		else
			StzRaise("Key must be a string!")
		ok
	
	def UpdateNthKey(n, pcValue)
		if isList(n) and isNumber(pcValue)
			temp = n
			n = pcValue
			pcValue = temp
		ok

		if n = :First
			n = 1
		but n = :Last
			n = This.NumberOfKeys()
		ok

		# Now, let's do the job

		@aContent[n][1] = pcValue

	def UpdateKey(pcKey, pcNewKey)
		if isString(pcKey) and This.ContainsKey(pcKey)
			n = This.FindKey(pcKey)
			@aContent[n][1] = pcNewKey
		ok
	
	def UpdateKeys(paKeys)
		oStzList = new stzList(paKeys)
		if oStzList.ItemsAreAllStrings()
			for i = 1 to Min([ len(paKeys), This.NumberOfPairs() ])
				This.UpdateNthKey(i, paKeys[i])
			next i
		ok
	
	def UpdateNthValue(n, pValue)

		if n = :First
			n = 1
		but n = :Last
			n = This.NumberOfValues()
		ok


		@aContent[n][2] = pValue
	
		def UpdateNthOccurrenceOfValue(pValue)
			This.UpdateNthValue( This.FindNthOccurrenceOfValue(pValue) )
	
	def UpdateValues(paValues)
		for i = 1 to Min([ len(paValues), This.NumberOfPairs() ])
			This.UpdateNthValue(i, paValues[i])
		next
	
	def UpdateValue(pValue, pNewValue)
		aTemp = This.FindValue(pValue)
		for n in aTemp
			This.UpdateNthValue(n, pNewValue)
		next
	
	def UpdateFirstOccurrenceOfValue(pValue, pNewValue)
		This.UpdateNthOccurrenceOfValue(1, pValue, pNewValue)

		def UpdateFirstValue(pValue, pNewValue)
			This.UpdateFirstOccurrenceOfValue(pValue, pNewValue)
		
	def UpdateLastValue(pValue, pNewValue)
		n = NumberOfOccurrenceOfValue(pValue)
		This.UpdateNthValue(n, pValue, pNewValue)

	def UpdateAllPairsWith(paPair)
		if isList(paPair) and ListIsPairAndKeyIsString(paPair)
			for aPair in This.Content()
				aPair = paPair
			next
		else
			StzRaise("Syntax error! The value you provided is not a string key pair.")
		ok

	  #-----------------------------#
	 #  REVERSING KEYS AND VALUES  #
	#-----------------------------#

	def ReverseKeysAndValues()
		aKeys = This.Keys()
		aValues = This.Values()
		for i=1 to This.NumberOfPairs()
			This.UpdateNthKey(i,""+ aValues[i] )
			This.UpdateNthValue(i, aKeys[i])
		next

		def ReverseKeysAndValuesQ()
			This.ReverseKeysAndValues()
			return This
	
	  #----------------------#
	 #     ADDING A PAIR    #
	#----------------------#

	def AddPair(paNewPair)

		if isList(paNewPair) and Q(paNewPair).IsPair() and isString(paNewPair[1])
			@aContent + paNewPair

		else
			StzRaise("Syntax error! The value you provided is not a pair with its key beeing a string.")
		ok

		def AddPairQ(paNewPair)
			This.AddPair(paNewPair)
			return This

	  #------------------#
	 #     INSERTING    #
	#------------------#

	def InsertBefore(n, paPair)
		if n > 1 and n <= This.NumberOfPairs()
			insert( This.HashList, n-1, paPair)
		ok

		def InsertBeforeQ(n, paPair)
			This.InsertBefore(n, paPair)
			return This
	
	def InsertAfter(n, paPair)
		insert( This.HashList, n, paPair)

		def InsertAfterQ(n, paPair)
			This.InsertAfter(n, paPair)
			return This

	  #------------------#
	 #     REMOVING     #
	#------------------#

	def RemoveNthPair(n)
		del( This.HashList(), n )

		def RemoveNthPairQ(n)
			This.RemovePair(n)
			return This

	def RemovePair(paPair)
		oList = new stzList( This.HashList() )
		aResult = oList.RemoveQ(paPair).Content()
		This.Update(aResult)

		def RemovePairQ(paPair)
			This.RemovePair(paPair)
			return This
		
	def RemovePairByKey(pcKey)
		n = This.FindKey(pcKey)
		if n > 0
			del( This.HashList(), n)
		ok

		def RemovePairByKeyQ(pcKey)
			This.RemovePairByKey(pcKey)
			return This

		def RemoveByKey(pcKey)
			This.RemovePairByKey(pcKey)
	
			def RemoveByKeyQ(pcKey)
				This.RemoveByKey(pcKey)
				return This

	def RemovePairsByKeys(pacKeys)
		for pcKey in pacKeys
			This.RemovePairByKey(pcKey)
		next

	def RemovePairsByValue(pValue)
		aPos = This.FindValue(pValue)

		aResult = StzListQ( This.HashList() ).RemoveItemsAtThesePositionsQ( aPos ).Content()
		This.Update(aResult)

		def RemovePairsByValueQ(pValue)
			This.RemovePairsByValue(pValue)
			return This

	def RemovePairsByValues(paValues)
		for value in paValues
			This.RemovePairsByValue(value)
		next

	  #--------------------#
	 #  REPLACING VALUES  #
	#--------------------#

	def ReplaceValueByKey(pcKey, pNewValue)
		n = This.FindKey(pckey)
		This.HashList()[n][2] = pNewValue

		def ReplaceValueByKeyQ(pcKey, pNewValue)
			This.ReplaceValueByKey(pcKey, pNewValue)
			return This

		def ReplaceByKey(pcKey, pNewValue)
			This.ReplaceValueByKey(pcKey, pNewValue)

			def ReplaceByKeyQ(pcKey, pNewValue)
				This.ReplaceByKey(pcKey, pNewValue)
				return This

	def ReplaceValue(pValue, pNewValue)
		anPos = This.FindAllOccurrencesOfValue(pValue)

		for n in anPos
			This.HashList()[n][2] = pNewValue
		next

		def ReplaceValueQ(pValue, pNewValue)
			This.ReplaceValue(pValue, pNewValue)
			return This

	  #------------------#
	 #  REPLACING KEYS  #
	#------------------#

	def ReplaceKey(pcKey, pcNewKey)
		n = This.FindKey(pcKey)
		This.ReplaceNthKey(n, pcNewKey)

		def ReplaceKeyQ(pcKey, pcNewKey)
			This.ReplaceKey(pcKey, pcNewKey)
			return this

	def ReplaceNthKey(n, pcNewKey)
		if isList(pcNewKey) and Q(pcNewKey).IsWithNamedParam()
			pcNewKey = pcNewKey[2]
		ok

		This.NthPair(n)[1] = pcNewKey

		def ReplaceNthKeyQ(n, pcNewKey)
			This.ReplaceNthKey(n, pcNewKey)
			return This

	def ReplaceFirstKey(pcNewKey)
		This.ReplaceNthKey(1, pcNewKey)

		def ReplaceFirstKeyQ(pcNewKey)
			This.ReplaceFirstKey(pcNewKey)
			return This

	def ReplaceLastKey(pcNewKey)
		This.ReplaceNthKey(This.NumberOfKeys(), pcNewKey)

		def ReplaceLastKeyQ(pcNewKey)
			This.ReplaceLastKey(pcNewKey)
			return This

	  #-------------------#
	 #  REPLACING PAIRS  #
	#-------------------#

	def ReplacePair(paPair, paNewPair)
		n = This.FindPair(paPair)
		This.ReplaceNthPair(n, paNewPair)

		def ReplacePairQ(paPair, paNewPair)
			This.ReplacePair(paPair, paNewPair)
			return This

	def ReplacePairByKey(pcKey, paNewPair)
		n = This.FindKey(pcKey)
		This.ReplaceNthPair(n, paNewPair)
	
		def ReplacePairByKeyQ(pcKey, paNewPair)
			This.ReplacePairByKey(pcKey, paNewPair)
			return This

	def ReplacePairsW(pcCondition) // TODO
		/* ... */
		StzRaise("Inexistant feature in this release!")

	  #---------------------#
	 #     FINDING KEYS    #
	#---------------------#

	def FindKeys(pacKeys)
		aResult = This.KeysQ().FindMany(pacKeys)
		return aResult

		def FindTheseKeys(pacKeys)
			return This.FindKeys(pacKeys)

	def FindKey(pcKey)
		if isString(pcKey)
			return ring_find( Keys(), pcKey)
		ok

		def FindThisKey(pcKey)
			return This.Key(pcKey)

	def HasKey(pcKey)
		if isString(pcKey) and This.FindKey(pcKey) > 0
			return TRUE
		else
			return FALSE
		ok

		def ContainsKey(pcKey)
			return This.HasKey(pcKey)
		
	def HasKeys(pacKeys)
		oKeys = new stzList(pacKeys)
		if oKeys.IsListOfStrings() and
		   oKeys.IsEqualTo(This.Keys())

			return TRUE
		else
			return FALSe
		ok

		def ContainsKeys(pacKeys)
			return This.HasKeys(pacKeys)

	  #-----------------#
	 #  FINDING PAIRS  #
	#-----------------#

	def FindPair(paPair)
		if isList(paPair) and ListIsPairAndKeyIsString(paPair)
			nResult = 0
			n = 0
			for aPair in Content()
				n++
				if Q(aPair[1]).IsEqualTo(paPair[1]) and
				   Q(aPair[2]).IsEqualTo(paPair[2])

					nResult = n
					exit
				ok	
			next
			return nResult
		else
			StzRaise("Can't search the list." + NL + "Because paPair is not a pair!")
		ok

	def ContainsPair(paPair)
		if FindPair(paPair) > 0
			return TRUE
		else
			return FALSE
		ok

	  #-----------------------------------------------------#
	 #  CHECKING IF THE HASHLIST CONTAINS THE GIVEN VALUE  #
	#-----------------------------------------------------#

	def ContainsValueCS(pValue, pCaseSensitive)
		if len( This.FindValueCS(pValue, pCaseSensitive) ) > 0
			return TRUE
		else
			return FALSE
		ok

		#< @FunctionAlternativeForms

		def ContainsThisValueCS(pValue, pCaseSensitive)
			return This.ContainsValueCS(pValue, pCaseSensitive)

		def ValueExistsCS(pValue, pCaseSensitive)
			return This.ContainsValueCS(pValue, pCaseSensitive)

		def ThisValueExistsCS(pValue, pCaseSensitive)
			return This.ContainsValueCS(pValue, pCaseSensitive)

		#>

	#-- WITHOUT CASESENSITIVE

	def ContainsValue(pValue)
		return This.ContainsValueCS(pValue, :CaseSensitive = TRUE)

		#< @FunctionAlternativeForms

		def ContainsThisValue(pValue)
			return This.ContainsValue(pValue)

		def ValueExists(pValue)
			return This.ContainsValue(pValue)

		def ThisValueExists(pValue)
			return This.ContainsValue(pValue)

		#>

	  #------------------------------------------------------#
	 #  CHECKING IF THE HASHLIST CONTAINS THE GIVEN VALUES  #
	#------------------------------------------------------#

	def ContainsValuesCS(paValues, pCaseSensitive)
		bResult = This.ValuesQ().ContainsManyCS(paValues, pCaseSensitive)
		return bResult

		#< @FunctionAlternativeForms

		def ContainsTheseValuesCS(paValues, pCaseSensitive)
			return This.ContainsValuesCS(pValue, pCaseSensitive)

		def ValuesExistCS(paValues, pCaseSensitive)
			return This.ContainsValuesCS(paValues, pCaseSensitive)

		def TheseValueExistCS(paValues, pCaseSensitive)
			return This.ContainsValuesCS(paValues, pCaseSensitive)

		#>

	#-- WITHOUT CASESENSITIVE

	def ContainsValues(paValues)
		return This.ContainsValuesCS(paValues, :CaseSensitive = TRUE)

		#< @FunctionAlternativeForms

		def ContainsTheseValues(paValues)
			return This.ContainsValues(pValue)

		def ValuesExist(paValues)
			return This.ContainsValues(paValues)

		def TheseValueExist(paValues)
			return This.ContainsValues(paValues)

		#>

	  #---------------------#
	 #   FINDING A VALUE   #
	#---------------------#

	def FindValueCS(pValue, pCaseSensitive)
		anResult = ValuesQ().FindAllCS(pValue, pCaseSensitive)
		return anResult

		#< @FunctionAlternativeForms

		def FindAllOccurrencesOfValueCS(pValue, pCaseSensitive)
			return This.FindValueCS(pValue, pCaseSensitive)

		def FindCS(pValue, pCaseSensitive)
			return This.FindValueCS(pValue, pCaseSensitive)

		#>

	#-- WITHOUT CASESENSITIVITY

	def FindValue(pValue)
		return This.FindValueCS(pValue, :CaseSensitive = TRUE)

		#< @FunctionAlternativeForms

		def FindAllOccurrencesOfValue(pValue)
			return This.FindValue(pValue)

		def Find(pValue)
			return This.FindValue(pValue)

		#>

	  #-------------------------#
	 #   FINDING MANY VALUES   #
	#-------------------------#

	def FindValuesCS(paValues, pCaseSensitive)

		anResult = This.ValuesQ().FindManyCS(paValues, pCaseSensitive)
		return anResult

		#< @FunctionAlternativeForms

		def FindManyCS(paValues, pCaseSensitive)
			return This.FindValuesCS(paValues, pCaseSensitive)

		def FindManyValuesCS(paValues, pCaseSensitive)
			return This.FindValuesCS(paValues, pCaseSensitive)

		def FindTheseValuesCS(paValues, pCaseSensitive)
			return This.FindValuesCS(paValues, pCaseSensitive)

		def FindTheseCS(paValues, pCaseSensitive)
			return This.FindValuesCS(paValues, pCaseSensitive)

		#>

	#-- WITHOUT CASESENSITIVITY

	def FindValues(paValues)
		return This.FindValuesCS(paValues, :CaseSensitive = TRUE)

		#< @FunctionAlternativeForms

		def FindMany(paValues)
			return This.FindValues(paValues)

		def FindManyValues(paValues)
			return This.FindValues(paValues)

		def FindTheseValues(paValues)
			return This.FindValues(paValues)

		def FindThese(paValues)
			return This.FindValues(paValues)

		#>

	  #-------------------------------------------#
	 #   FINDING THE NTH OCCURRENCE OF A VALUE   #
	#-------------------------------------------#

	def FindNthOccurrenceOfValueCS(n, pValue, pCaseSensitive)

		if CheckParams()

			if n = :First
				n = 1
			but n = :Last
				n = This.NumberOfOccurreceOfValueCS(pValue, pCaseSensitive)
			ok
	
			if NOT isNumber(n)
				StzRaise("Incorrect param type! n must be a number.")
			ok

		ok

		return This.FindValueCS(pValue, pCaseSensitive)[n]

		#< @FunctionAlternativeForms

		def FindNthValueCS(n, pValue, pCaseSensitive)
			return This.FindNthOccurrenceOfValueCS(n, pValue, pCaseSensitive)

		def FindNthCS(n, pValue, pCaseSensitive)
			return This.FindNthOccurrenceOfValueCS(n, pValue, pCaseSensitive)

		#>

	#-- WITHOUT CASESENSITIVITY

	def FindNthOccurrenceOfValue(n, pValue)
		return This.FindNthOccurrenceOfValueCS(n, pValue, :CaseSensitive = TRUE)

		#< @FunctionAlternativeForms

		def FindNthValue(n, pValue)
			return This.FindNthOccurrenceOfValue(n, pValue)

		def FindNth(n, pValue)
			return This.FindNthOccurrenceOfValue(n, pValue)

		#>

	  #---------------------------------------------#
	 #   FINDING THE FIRST OCCURRENCE OF A VALUE   # TODO: Add case sensitivity
	#---------------------------------------------#

	def FindFirstOccurrenceOfValue(pValue) 
		return This.FindNthValue(1, pValue)

		def FindFirstValue(pValue)
			return This.FindFirstOccurrenceOfValue(pValue) 

		def FindFirst(pValue)
			return This.FindFirstOccurrenceOfValue(pValue) 

	  #--------------------------------------------#
	 #   FINDING THE LAST OCCURRENCE OF A VALUE   # TODO: Add case sensitivity
	#--------------------------------------------#

	def FindLastOccurrenceOfValue(pValue)
		return This.FindNthOccurrenceOfValue(This.NumberOfValues(), pValue)

		def FindLastValue(pValue)
			return This.FindLastOccurrenceOfValue(pValue) 

		def FindLast(pValue)
			return This.FindLastOccurrenceOfValue(pValue) 

	  #---------------------------#
	 #   FINDING KEYS BY VALUE   # TODO: Add case sensitivity
	#---------------------------#

	def FindKeysByValue(pValue)

		aResult = []
		i = 0

		for value in This.Values()
			i++

			if Q(value).IsEqualTo(pValue)
				aResult + This.NthKey(i)
			ok
		next
		return aResult

	  #------------------------------#
	 #   FINDING NTH KEY BY VALUE   # TODO: Add case sensitivity
	#------------------------------#

	def FindNthKeyByValue(pValue)
		nResult = 0
		if This.ContainsValue(pValue)
			nResult = This.FindKeysByValue(pValue)[n]
		ok
		return nResult

	  #--------------------------------#
	 #   FINDING FIRST KEY BY VALUE   # TODO: Add case sensitivity
	#--------------------------------#

	def FindFirstKeyByValue(pValue)
		nResult = 0
		if This.ContainsValue(pValue)
			nResult = This.FindKeysByValue(pValue)[1]
		ok
		return nResult

		def FindKeyByValue(pValue)
			return This.FindFirstKeyByValue(pValue)

	  #-------------------------------#
	 #   FINDING LAST KEY BY VALUE   # TODO: Add case sensitivity
	#-------------------------------#

	def FindLastKeyByValue(pValue)
		cResult = ""
		for i = This.NumberOfPairs() to 1 step -1
			if Q(This.Value(i)).IsEqualTo(pValue)
				cResult = This.Key(i)
				exit
			ok
		next i
		return cResult

	  #----------------------------------------------------#
	 #   GETTING THE KEY CORRESPONDING TO A GIVEN VALUE   # TODO: Add case sensitivity
	#----------------------------------------------------#

	def KeyByValue(pValue)
		n = This.FindKeyByValue(pValue)
		return This.Key( n )

	# TODO: should the result be a list of positions?
	#       because a value can be hosted in more than one key...

	  #-----------------------------------------------------#
	 #   GETTING THE KEYS CORRESPONDING TO A GIVEN VALUE   # TODO: Add case sensitivity
	#-----------------------------------------------------#

	def KeysByValue(pValue)
		anPos = This.FindKeysByValue()
		aResult = []

		for n in anPos
			aResult + This.KeyByValue(n)
		next

		return aResult

	  #-----------------------------------------#
	 #  FINDING LISTS (VALUES THAT ARE LISTS)  #
	#=========================================#
	# TODO: Add case sensitivity

	def FindLists()
		aContent = This.Content()
		nLen = len(aContent)

		anResult = []

		for i = 1 to nLen
			if isList(aContent[i][2])
				anResult + i
			ok
		next

		return anResult

	def FindNonLists()
		anResult = Q( 1 : This.Size() ) - This.FindLists()
		return anResult

	def Lists()
		aContent = This.Content()
		nLen = len(aContent)

		aResult = []

		for i = 1 to nLen
			if isList(aContent[i][2])
				aResult + aContent[i][2]
			ok
		next

		return aResult

	def ListsZ()
		aListsU = U( This.Lists() )
		nLen = len(aListsU)

		aResult = []

		for i = 1 to nLen
			aResult + [ aListsU[i], This.FindList(aListsU[i]) ]
		next

		return aResult

	def FindList(paList) # Add case sensitivity

		if CheckParams()
			if NOT isList(paList)
				StzRaise("Incorrect param type! paList must be a list.")
			ok
		ok

		anPos = Q(This.Lists()).Find(paList)
		anResult = []
		if len(anPos) > 0 
			anResult = Q(This.FindLists()).ItemsAtPositions(anPos)
		ok

		return anResult

	def ListZ(paList)
		if CheckParams()
			if NOT isList(paList) 
				StzRaise("Incorrect param type! paList must be a list.")
			ok
		ok

		anPos = This.FindList(paList)
		aResult = [ paList, anPos ]	
		return aResult

	def FindTheseLists(paLists)
		if CheckParams()
			if NOT ( isList(paLists) and Q(paLists).IsListOfLists() )
				StzRaise("Incorrect param type! paLists must be a list of lists.")
			ok
		ok

		paLists = U(paLists) # Duplicates removed
		nLen = len(paLists)
		anResult = []

		for i = 1 to nLen
			anPos = This.FindList(paLists[i])
			nLenPos = len(anPos)

			for j = 1 to nLenPos
				anResult + anPos[j]
			next
		next

		anResult = ring_sort(anResult)
		return anResult

	def TheseListsZ(paLists)
		if CheckParams()
			if NOT ( isList(paLists) and Q(paLists).IsListOfLists() )
				StzRaise("Incorrect param type! paLists must be a list of lists.")
			ok
		ok

		nLen = len(paLists)
		aResult = []

		for i = 1 to nLen
			aResult + [ paLists[i], This.FindList(paLists[i]) ]
		next

		return aResult

	#--

	  #---------------------------------------------#
	 #  FINDING NUMBERS (VALUES THAT ARE NUMBERS)  #
	#=============================================#
	# TODO: Add case sensitivity

	def FindNumbers()
		aContent = This.Content()
		nLen = len(aContent)

		anResult = []

		for i = 1 to nLen
			if isNumber(aContent[i][2])
				anResult + i
			ok
		next

		return anResult

	def Numbers()
		aContent = This.Content()
		nLen = len(aContent)

		aResult = []

		for i = 1 to nLen
			if isNumber(aContent[i][2])
				aResult + aContent[i][2]
			ok
		next

		return aResult

	def NumbersZ()
		aNumbersU = U( This.Numbers() )
		nLen = len(aNumbersU)

		aResult = []

		for i = 1 to nLen
			aResult + [ aNumbersU[i], This.FindNumber(aNumbersU[i]) ]
		next

		return aResult

	def FindNumber(paNumber) # Add case sensitivity

		if CheckParams()
			if NOT isNumber(paNumber)
				StzRaise("Incorrect param type! paNumber must be a list.")
			ok
		ok

		anPos = Q(This.Numbers()).Find(paNumber)
		anResult = []
		if len(anPos) > 0 
			anResult = Q(This.FindNumbers()).ItemsAtPositions(anPos)
		ok

		return anResult

	def NumberZ(paNumber)
		if CheckParams()
			if NOT isNumber(paNumber) 
				StzRaise("Incorrect param type! paNumber must be a list.")
			ok
		ok

		anPos = This.FindNumber(paNumber)
		aResult = [ paNumber, anPos ]	
		return aResult

	def FindTheseNumbers(paNumbers)
		if CheckParams()
			if NOT ( isNumber(paNumbers) and Q(paNumbers).IsNumberOfNumbers() )
				StzRaise("Incorrect param type! paNumbers must be a list of lists.")
			ok
		ok

		paNumbers = U(paNumbers) # Duplicates removed
		nLen = len(paNumbers)
		anResult = []

		for i = 1 to nLen
			anPos = This.FindNumber(paNumbers[i])
			nLenPos = len(anPos)

			for j = 1 to nLenPos
				anResult + anPos[j]
			next
		next

		anResult = ring_sort(anResult)
		return anResult

	def TheseNumbersZ(paNumbers)
		if CheckParams()
			if NOT ( isNumber(paNumbers) and Q(paNumbers).IsNumberOfNumbers() )
				StzRaise("Incorrect param type! paNumbers must be a list of lists.")
			ok
		ok

		nLen = len(paNumbers)
		aResult = []

		for i = 1 to nLen
			aResult + [ paNumbers[i], This.FindNumber(paNumbers[i]) ]
		next

		return aResult

	  #--------------------------------------------#
	 #  FINDING STRINGS (VALUES THAT ARE STRING)  #
	#============================================#
	# TODO: Add case sensitivity

	def FindStrings()
		aContent = This.Content()
		nLen = len(aContent)

		anResult = []

		for i = 1 to nLen
			if isString(aContent[i][2])
				anResult + i
			ok
		next

		return anResult

	def Strings()
		aContent = This.Content()
		nLen = len(aContent)

		aResult = []

		for i = 1 to nLen
			if isString(aContent[i][2])
				aResult + aContent[i][2]
			ok
		next

		return aResult

	def StringsZ()
		aStringsU = U( This.Strings() )
		nLen = len(aStringsU)

		aResult = []

		for i = 1 to nLen
			aResult + [ aStringsU[i], This.FindString(aStringsU[i]) ]
		next

		return aResult

	def FindString(paString) # Add case sensitivity

		if CheckParams()
			if NOT isString(paString)
				StzRaise("Incorrect param type! paString must be a list.")
			ok
		ok

		anPos = Q(This.Strings()).Find(paString)
		anResult = []
		if len(anPos) > 0 
			anResult = Q(This.FindStrings()).ItemsAtPositions(anPos)
		ok

		return anResult

	def StringZ(paString)
		if CheckParams()
			if NOT isString(paString) 
				StzRaise("Incorrect param type! paString must be a list.")
			ok
		ok

		anPos = This.FindString(paString)
		aResult = [ paString, anPos ]	
		return aResult

	def FindTheseStrings(paStrings)
		if CheckParams()
			if NOT ( isString(paStrings) and Q(paStrings).IsStringOfStrings() )
				StzRaise("Incorrect param type! paStrings must be a list of lists.")
			ok
		ok

		paStrings = U(paStrings) # Duplicates removed
		nLen = len(paStrings)
		anResult = []

		for i = 1 to nLen
			anPos = This.FindString(paStrings[i])
			nLenPos = len(anPos)

			for j = 1 to nLenPos
				anResult + anPos[j]
			next
		next

		anResult = ring_sort(anResult)
		return anResult

	def TheseStringsZ(paStrings)
		if CheckParams()
			if NOT ( isString(paStrings) and Q(paStrings).IsStringOfStrings() )
				StzRaise("Incorrect param type! paStrings must be a list of lists.")
			ok
		ok

		nLen = len(paStrings)
		aResult = []

		for i = 1 to nLen
			aResult + [ paStrings[i], This.FindString(paStrings[i]) ]
		next

		return aResult

	  #---------------------------------------------#
	 #  FINDING OBJECTS (VALUES THAT ARE OBJECTS)  #
	#=============================================#
	# TODO: Add case sensitivity

	def FindObjects()
		aContent = This.Content()
		nLen = len(aContent)

		anResult = []

		for i = 1 to nLen
			if isObject(aContent[i][2])
				anResult + i
			ok
		next

		return anResult

	def Objects()
		aContent = This.Content()
		nLen = len(aContent)

		aResult = []

		for i = 1 to nLen
			if isObject(aContent[i][2])
				aResult + aContent[i][2]
			ok
		next

		return aResult

	  #------------------------------------------------------#
	 #  FINDING STZLISTS (VALUES THAT ARE STZLIST OBJECTS)  #
	#======================================================#
	# TODO: Add case sensitivity

	def FindStzLists()
		aContent = This.Content()
		nLen = len(aContent)

		anResult = []

		for i = 1 to nLen
			if @IsStzList(aContent[i][2])
				anResult + i
			ok
		next

		return anResult

	def StzLists()
		aContent = This.Content()
		nLen = len(aContent)

		aResult = []

		for i = 1 to nLen
			if @IsStzList(aContent[i][2])
				aResult + aContent[i][2]
			ok
		next

		return aResult

	  #-------------------------------------------------------#
	 #  FINDING STZHASHLISTS (VALUES THAT ARE STZHASHLISTS)  #
	#=======================================================#
	# TODO: Add case sensitivity

	def FindStzHashLists()
		aContent = This.Content()
		nLen = len(aContent)

		anResult = []

		for i = 1 to nLen
			if @IsStzHashList(aContent[i][2])
				anResult + i
			ok
		next

		return anResult

	def StzHashLists()
		aContent = This.Content()
		nLen = len(aContent)

		aResult = []

		for i = 1 to nLen
			if @IsStzHashList(aContent[i][2])
				aResult + aContent[i][2]
			ok
		next

		return aResult

	  #---------------------------------------------------#
	 #  FINDING STZNUMBERS (VALUES THAT ARE STZNUMBERS)  #
	#===================================================#
	# TODO: Add case sensitivity

	def FindStzNumbers()
		aContent = This.Content()
		nLen = len(aContent)

		anResult = []

		for i = 1 to nLen
			if @IsStzNumber(aContent[i][2])
				anResult + i
			ok
		next

		return anResult

	def StzNumbers()
		aContent = This.Content()
		nLen = len(aContent)

		aResult = []

		for i = 1 to nLen
			if @IsStzNumber(aContent[i][2])
				aResult + aContent[i][2]
			ok
		next

		return aResult

	  #---------------------------------------------------#
	 #  FINDING STZSTRINGS (VALUES THAT ARE STZSTRINGS)  #
	#===================================================#
	# TODO: Add case sensitivity

	def FindStzStrings()
		aContent = This.Content()
		nLen = len(aContent)

		anResult = []

		for i = 1 to nLen
			if @IsStzString(aContent[i][2])
				anResult + i
			ok
		next

		return anResult

	def StzStrings()
		aContent = This.Content()
		nLen = len(aContent)

		aResult = []

		for i = 1 to nLen
			if @IsStzString(aContent[i][2])
				aResult + aContent[i][2]
			ok
		next

		return aResult

	  #---------------------------------------------------#
	 #  FINDING STZOBJECTS (VALUES THAT ARE STZOBJECTS)  #
	#===================================================#
	# TODO: Add case sensitivity

	def FindStzObjects()
		aContent = This.Content()
		nLen = len(aContent)

		anResult = []

		for i = 1 to nLen
			if @IsStzObject(aContent[i][2])
				anResult + i
			ok
		next

		return anResult

	def StzObjects()
		aContent = This.Content()
		nLen = len(aContent)

		aResult = []

		for i = 1 to nLen
			if @IsStzObject(aContent[i][2])
				aResult + aContent[i][2]
			ok
		next

		return aResult

	  #---------------------------------------------------------------------------#
	 #   CHECHKING IF ONE VALUE (AT LEAST) IS A LIST CONTAINING THE GIVEN ITEM   #
	#===========================================================================#
	# TODO: Add case sensitivity

	# SEMANTIC NOTE: An "Item" in the context of stzHashList, refers to values that
	# are lists, and those lists contain the item. See examples hereafter.

	def ContainsItem(pItem) # TODO: Add case sensitivity
		/* EXAMPLE
	
		o1 = new stzHashList([
			:Positive	= :NONE,
			:Neutral  	= [ :is, :will, :can, :some ],
			:Negative	= :NONE
		])
	
		? o1.ContainsItem(:nice) #--> TRUE
		*/

		# See EXAMPLE in FindItemInList()

		aContent = This.Content()
		nLen = len(aContent)

		bResult = FALSE

		for i = 1 to nLen

			if isList(aContent[i][2])

				oStzList = new stzList(aContent[i][2])
				if oStzList.Contains(pItem)
					bResult = TRUE
					exit
				ok
			ok

		next

		return bResult

		def ContainsSubValue(pItem)
			return This.ContainsItem(pItem)

		def ContainsInnerValue(pItem)
			return This.ContainsItem(pItem)

	  #-----------------------------------------------------------------------#
	 #   WHEN THE VALUE IS A LIST, FINDING THE GIVEN ITEM INSIDE THAT TLIST  #
	#=======================================================================#
	# TODO: Add case sensitivity

	def FindItem(pItem)
		/* EXAMPLE

		o1 = new stzHashList([
			:One	= :NONE,
			:Two  	= [ :is, :will, :can, :some, :can ],
			:Three	= :NONE,
			:Four	= [ :can, :will ],
			:Five	= [ :will ]
		])

		? @@( o1.FindItem(:can) )
		#--> [ [ 2, [ 3, 5 ] ], [ 4, [ 1 ] ] ]
		*/

		aContent = This.Content()
		nLen = len(aContent)

		aResult = []

		for i = 1 to nLen

			if isList(aContent[i][2])

				oStzList = new stzList(aContent[i][2])
				if oStzList.Contains(pItem)
					aResult + [ i, oStzList.FindAll(pItem) ]
				ok
			ok

		next

		return aResult

		#< @FunctionAlternativeForms

		def FindInList(pItem)
			return This.FindItem(pItem)

		def FindInLists(pItem)
			return This.FindItem(pItem)

		def FindThisItem(pItem)
			return This.FindItem(pItem)

		def FindItemInList(pItem)
			return This.FindItem(pItem)

		def FindThisItemInList(pItem)
			return This.FindItem(pItem)

		def FindItemInLists(pItem)
			return This.FindItem(pItem)

		def FindThisItemInLists(pItem)
			return This.FindItem(pItem)

		#>

	def FindTheseItems(paItems)
		/* EXAMPLE

		o1 = new stzHashList([
			:One	= :NONE,
			:Two  	= [ :is, :will, :can, :some, :can ],
			:Three	= :NONE,
			:Four	= [ :can, :will ],
			:Five	= [ :will ]
		])

		? @@( o1.FindTheseItems([ :can, :will ]) )
		#--> [
		#	[ 2, [ 2, 3, 5 ] ],
		#	[ 4, [ 1, 2 ] ],
		#	[ 5, [ 1 ] ]
		# ]

		*/

		if CheckParams()
			if NOT isList(paItems)
				StzRaise("Incorrect param type! paItems must be a list.")
			ok
		ok

		aItemsZ = This.ItemsZ()
		nLen = len(aItemsZ)

		aResult = []

		for i = 1 to nLen
			if Q(aItemsZ[i][1]).IsOneOfThese(paItems)
				nLenPos = len(aItemsZ[i][2])
				for j = 1 to nLenPos
					aResult + aItemsZ[i][2][j]
				next
			ok
		next

		aResult = QR(aResult, :stzListOfPairs).Sorted()
		return aResult

		#< @FunctionAlternativeForms

		def FindTheseItemsInList(paItems)
			return This.FindTheseItems(paItems)

		def FindTheseItemsInLists(paItems)
			return This.FindTheseItems(paItems)

		def FindTheseInList(paItems)
			return This.FindTheseItems(paItems)

		def FindTheseInLists(paItems)
			return This.FindTheseItems(paItems)

		#>

	def TheseItemsZ(paItems)
		/* EXAMPLE

		o1 = new stzHashList([
			:One	= :NONE,
			:Two  	= [ :is, :will, :can, :some, :can ],
			:Three	= :NONE,
			:Four	= [ :can, :will ],
			:Five	= [ :will ]
		])

		? o1.TheseItemsZ([ :can, :will ])
		#--> [
		#	[ :can,  [ [2, [3,5] ], [ 4, [1] ]             ],
		#	[ :will, [ [2, [1]   ], [ 4, [2] ], [ 5, [1] ] ]
		# ]
		*/

		if CheckParams()
			if NOT isList(paItems)
				StzRaise("Incorrect param type! paItems must be a list.")
			ok
		ok

		paItems = U(paItems) # Duplicates removed

		nLen = len(paItems)
		aResult = []

		for i = 1 to nLen

			aResult + [ paItems[i], This.FindItem(paItems[i]) ]

		next

		return aResult

		def TheseItemsInListZ(paItems)
			return This.TheseItemsZ(paItems)

		def TheseItemsInListsZ(paItems)
			return This.TheseItemsZ(paItems)

	def Items()

		aResult = U( This.ValuesQ().OnlyListsQ().Merged() )
		return aResult

	def FindItems()
		
		aItems = This.Items()
		nLen = len(aItems)

		aIndex = This.Copy().ListifyQ().ValuesQR(:stzListOfLists).Index()

		aResult = []
		for i = 1 to nLen
			aResult + aIndex[aItems[i]]
		next

		aResult = Q(aResult).MergeQ().ToStzListOfPairs().Sorted()

		return aResult

	def ItemsZ()
		
		aIndex = This.Copy().ListifyQ().ValuesQR(:stzListOfLists).Index()

		aItems = This.Items()
		anPos = QR(aIndex, :stzHashList).FindTheseKeys(aItems)
		nLen = len(anPos)

		aResult = []
		for i = 1 to nLen
			aResult + aIndex[anPos[i]]
		next

		return aResult

	def NumberOfItems()
		return len(This.Items())

	def ItemZ(pItem)
		aResult = [ pItem, This.FindItem(pItem) ]
		return aResult

	  #-------------------------------------------------------------------------------------#
	 #   WHEN THE VALUE IS A LIST, FINDING THE NTH OCCURRENCE OF AN ITEM INSIDE THAT LIST  # 
	#-------------------------------------------------------------------------------------#
	# TODO: Add case sensitivity

	def FindNthItem(n, pItem)

		if n = :First
			n = 1
		but n = :Last
			n = This.NumberOfOccurreceOfItemInList(pItem)
		ok

		anPos = This.FindItel(pItem)
		nLen = len(anPos)

		nResult = 0
		if nLen > 0
			nResult = anPos[n]
		ok

		return nResult

		def FindNthOccurrenceOfItemInList(n, pItem)
			return This.FindNthItem(n, pItem)

	  #---------------------------------------------------------------------------------------#
	 #   WHEN THE VALUE IS A LIST, FINDING THE FIRST OCCURRENCE OF AN ITEM INSIDE THAT LIST  # 
	#---------------------------------------------------------------------------------------#
	# TODO: Add case sensitivity

	def FindFirstItem(pItem)
		return This.FindNthItem(1, pItem)

		#< @FunctionAlternativeForms

		def FindThisFirstItem(pItem)
			return This.FindFirstItem(pItem)

		def FindFirstOccurrenceOfThisItem(pItem)
			return This.FindFirstItem(pItem)

		def FindFirstOccurrenceOfItemInList(pItem)
			return This.FindFirstItem(pItem)

		def FindFirstOccurrenceOfThisItemInList(pItem)
			return This.FindFirstItem(pItem)

		#>

	  #--------------------------------------------------------------------------------------#
	 #   WHEN THE VALUE IS A LIST, FINDING THE LAST OCCURRENCE OF AN ITEM INSIDE THAT LIST  # 
	#--------------------------------------------------------------------------------------#
	# TODO: Add case sensitivity

	def FindLastItem(pItem)
		n = This.NumberOfOccurreceOfItemInList(pItem)
		return This.FindNthItem(n, pItem)

		#< @FunctionAlternativeForms

		def FindThislastItem(pItem)
			return This.FindLastItem(pItem)

		def FindLastOccurrenceOfThisItem(pItem)
			return This.FindLastItem(pItem)

		def FindLastOccurrenceOfItemInList(pItem)
			return This.FindLastItem(pItem)

		def FindLastOccurrenceOfThisItemInList(pItem)
			return This.FindLastItem(pItem)

		#>

	  #----------------------------------------------------------------------#
	 #  WHEN THE VALUES ARE LISTS, FINDING A GIVEN ITEM INSIDE THOSE LISTS  # 
	#----------------------------------------------------------------------#
	# TODO: Add case sensitivity

	def FindKeysByItem(pItem)
		anPos = This.FindItemInList(pItem)
		anResult = []
		for n in anPos
			anResult + n
		next
		return anResult

		def FindKeysByItemInList(pItem)
			return This.FindKeysByItem(pItem)

	def NumberOfKeysByItemInList() ###
		return len( This.FindKeysByItemInList(pValue) )

		#< @FunctionAlternativeForms

		def HowManyKeysByItemInList()
			return This.NumberOfKeysByItemInList()

		def HowManyKeyByItemInList()
			return This.NumberOfKeysByItemInList()

		def NumberOfKeysByItem()
			return This.NumberOfKeysByItemInList()

		def HowManyKeysByItem()
			return This.NumberOfKeysByItemInList()

		#>

	def FindFirstKeyByItemInList(pValue)

		if This.ContainsItemInList(pValue)
			return This.FindKeysByItemInList(pValue)[1]
		else
			return 0
		ok

		def FindFirstKeyByItem(pValue)
			return This.FindFirstKeyByItemInList(pValue)

	def FindKeyByItemInList(pValue)
		return This.FindFirstKeyByItemInList(pValue)

		def FindKeyByItem(pValue)
			return This.FindKeyByItemInList(pValue)

	def FindLastKeyByItemInList(pValue)
		n = This.NumberOfKeysByItemInList()

		if This.ContainsItemInList(pValue)
			return This.FindKeysByItemInList(pValue)[n]
		else
			return 0
		ok

		def FindLastKeyByItem(pValue)
			return This.FindLastKeyByItemInList(pValue)

	def KeyByItemInList(pValue)
		n = This.FindKeyByItemInList(pValue)

		return This.Key( n )

		def KeyByItem(pValue)
			return This.KeyByItemInList(pValue)

	def KeysByItemInList(pValue)
		anPos = This.FindKeysByItemInList()
		aResult = []

		for n in anPos
			aResult + This.Key(n)
		next

		return aResult

		def KeysByItem(pValue)
			return This.KeysByItem(pValue)

	  #------------------------------------------------#
	 #  LISTIFIYING (ALL THE VALUES IN) THE HASHLIST  #
	#------------------------------------------------#

	def Copy()
		oCopy = new stzHashList(This.content())
		return oCopy

	def Listify()

		nLen = len(@aContent)

		for i = 1 to nLen
			if NOT isList(@aContent[i][2])
				aTempList = []
				aTempList + @aContent[i][2]
				@aContent[i][2] = aTempList
			ok
		next

		def ListifyQ() # TODO: Ensure consistency in all library
			This.Listify()
			return This

	def Listified()
		aResult = This.Copy().ListifyQ().Content()
		return aResult

	  #===========================#
	 #     CLASSIFYING VALUES    #
	#===========================#

	def Classify()

		aResult = []
		aClasses = This.Classes()

		for cClass in aClasses
			aResult + [ cClass, This.KeysForValue(cClass) ]
		next

		return aResult

		#< @FunctionFluentForm

		def ClassifyQ()
			return This.ClassifyQR(pcReturnType)

		def ClassifyQR(pcReturnType)
			if isList(pcReturnType) and StzListQ(pcReturnType).IsOneOfTheseNamedParams([ :ReturnedAs, :ReturnAs ])
				pcReturnType = pcReturnType[2]
			ok
	
			switch pcReturnType
			on :stzList
				return new stzList( This.Classify() )

			on :stzHashList
				return new stzHashList( This.Classify() )
	
			other
				StzRaise("Unsupported return type!")
			off						
		#>

		#< @FunctionAlternativeForms

		def Categorise()
			return This.Classify()

			def CategoriseQ()
				return This.ClassifyQ()
	
			def CategoriseQR(pcReturnType)
				return This.ClassifyQR(pcReturnType)

		def Categorize()
			return This.Classify()

			def CategorizeQ()
				return This.ClassifyQ()

			def CategorizeQR(pcReturnType)
				return This.ClassifyQR(pcReturnType)
						
		#>

	  #---------------------------------------------------------#
	 #  GETTING THE NAMES OF KLASSES EXISTING IN THE HASHLIST  #
	#---------------------------------------------------------#

	def Classes()
		acResult = []
		aUniqueValues = This.UniqueValues()
		nLen = len(aUniqueValues)

		for i = 1 to nLen
			acResult + Q(aUniqueValues[i]).Stringified()
		next

		return acResult

		#< @FunctionFluentForm

		def ClassesQ()
			return This.ClassesQR(:stzList)

		def ClassesQR(pcReturnType)
			if isList(pcReturnType) and StzListQ(pcReturnType).IsOneOfTheseNamedParams([ :ReturnedAs, :ReturnAs ])
				pcReturnType = pcReturnType[2]
			ok

			switch pcReturnType
			on :stzList
				return new stzList( This.Classes() )

			on :stzListOfStrings
				return new stzListOfStrings( This.Classes() )

			other
				StzRaise("Unsupported return type!")
			off
		#>

		#< @FunctionAlternativeForms

		def Klasses()
			return This.Classes()

			def KlassesQ()
				return ClassesQ()

			def KlassesQR(pcReturnType)
				return ClassesQR(pcReturnType)

		def Categories()
			return This.Classes()

			def CategoriesQ()
				return ClassesQ()

			def CategoriesQR(pcReturnType)
				return ClassesQR(pcReturnType)
	
		#>

	  #-----------------------------------------------------#
	 #  CHECKING IF THE HASHLIST CONTAINS THE GIVEN CLASS  #
	#-----------------------------------------------------#

	def ContainsClass(pcClass)
		bResult = This.ContainsValueCS(pcClass, :CaseSensitive = FALSE)
		return bResult

		#< @FunctionAlternativeForms

		def ClassExists(pcClass)
			return This.ContainsClass(pcClass)

		def ContainsThisClass(pcClass)
			return This.ContainsClass(pcClass)

		def ThisClassExists(pcClass)
			return This.ContainsClass(pcClass)

		#--

		def ContainsKlass(pcClass)
			return This.ContainsClass(pcClass)

		def KlassExists(pcClass)
			return This.ContainsClass(pcClass)

		def ContainsThisKlass(pcClass)
			return This.ContainsClass(pcClass)

		def ThisKlassExists(pcClass)
			return This.ContainsClass(pcClass)

		#--

		def ContainsCategory(pcClass)
			return This.ContainsClass(pcClass)

		def CategoryExists(pcClass)
			return This.ContainsClass(pcClass)

		def ContainsThisCategory(pcClass)
			return This.ContainsClass(pcClass)

		def ThisCategoryExists(pcClass)
			return This.ContainsClass(pcClass)

		def ContainsCateg(pcClass)
			return This.ContainsClass(pcClass)

		def CategExists(pcClass)
			return This.ContainsClass(pcClass)

		def ContainsThisCateg(pcClass)
			return This.ContainsClass(pcClass)

		def ThisCategExists(pcClass)
			return This.ContainsClass(pcClass)
		#>

	  #-------------------------------------------------------#
	 #  CHECKING IF THE HASHLIST CONTAINS THE GIVEN CLASSES  #
	#-------------------------------------------------------#

	def ContainsClasses(pacClasses)
		bResult = This.ContainsValuesCS(pacClasses, :CaseSensitive = FALSE)
		return bResult

		#< @FunctionAlternativeForms

		def ClassesExist(pacClasses)
			return This.ContainsClasses(pacClasses)

		def ContainsTheseClasses(pacClasses)
			return This.ContainsClasses(pacClasses)

		def TheseClassesExist(pacClasses)
			return This.ContainsClasses(pacClasses)

		#--

		def ContainsKlasses(pacClasses)
			return This.ContainsClasses(pacClasses)

		def KlassesExist(pacClasses)
			return This.ContainsClasses(pacClasses)

		def ContainsTheseKlasses(pacClasses)
			return This.ContainsClasses(pacClasses)

		def TheseKlassesExist(pacClasses)
			return This.ContainsClasses(pacClasses)

		#--

		def ContainsCategories(pacClasses)
			return This.ContainsClasses(pacClasses)

		def CategoriesExist(pacClasses)
			return This.ContainsClasses(pacClasses)

		def ContainsTheseCategories(pacClasses)
			return This.ContainsClasses(pacClasses)

		def TheseCategoriesExist(pacClasses)
			return This.ContainsClasses(pacClasses)

		def ContainsCategs(pacClasses)
			return This.ContainsClass(pacClasses)

		def CategsExist(pacClasses)
			return This.ContainsClasses(pacClasses)

		def ContainsTheseCateg(pacClasses)
			return This.ContainsClasses(pacClasses)

		def ContainsTheseCategs(pacClasses)
			return This.ContainsClasses(pacClasses)

		def TheseCategExist(pacClasses)
			return This.ContainsClasses(pacClasses)

		def TheseCategsExist(pacClasses)
			return This.ContainsClasses(pacClasses)

		#>

	  #-------------------------------------------------------------#
	 #  GETTING NUMBER OF KLASSES (OR CATEGORIES) IN THE HASHLIST  #
	#-------------------------------------------------------------#

	def NumberOfClasses()
		return len( This.CLasses() )

		def NumberOfKlasses()
			return This.NumberOfClasses()

		def NumberOfCategories()
			return This.NumberOfClasses()

		def HowManyClasses()
			return This.NumberOfClasses()

		def HowManyKlasses()
			return This.NumberOfClasses()

		def HowManyClass()
			return This.NumberOfClasses()

		def HowManyKlass()
			return This.NumberOfClasses()

		def HowMayCategories()
			return This.NumberOfClasses()

		def HowManyCategory()
			return This.NumberOfClasses()

	  #-----------------------------------------------#
	 #  GETTING THE VALUES RELATED TO A GIVEN KLASS  #
	#-----------------------------------------------#

	def Klass(pcClass)
		# NOTE: We can't use Class (with C) --> reserved by Ring
		# --> To avoid any confusion, use Klass with K instead,
		# or if you prefer, use Category.

		aResult = This.KeysForValue(pcClass)
		return aResult

		#< @FunctionFluentForms

		def KlassQ(pcClass)
			return This.KlassQR(pClass, :stzList)

		def KlassQR(pcClass, pcReturnType)
			if isList(pcReturnType) and StzListQ(pcReturnType).IsOneOfTheseNamedParams([ :ReturnedAs, :ReturnAs ])
				pcReturnType = pcReturnType[2]
			ok

			switch pcReturnType
			on :stzString	
				return new stzString( This.Klass() )

			on :stzText
				return new stzText( This.Klass() )

			other
				StzRaise("Unsupported return type!")
			off

		#>

		#< @FunctionAlternativeForms

		def Category(pcClass)
			return This.Klass(pcClass)

			def CategoryQ(pcClass)
				return This.KlassQ(pcClass)

			def CategoryQR(pcClass, pcReturnType)
				return This.KlassQR(pcClass, pcREturnType)

		def Categ(pcClass)
			return This.Klass(pcClass)

			def CategQ(pcClass)
				return This.KlassQ(pcClass)

			def CategQR(pcClass, pcReturnType)
				return This.KlassQR(pcClass, pcREturnType)

		# We can't use Class() as an alternative, because it is reserved by Ring
		# But we can use it for the follwoing fluent forms:

			def ClassQ(pcClass)
				return This.KlassQ(pcClass)
	
			def ClassQR(pcClass, pcReturnType)
				return This.KlassQR(pcClass, pcReturnType)

		def ValuesInClass(pcClass)
			return This.Klass(pcClass)

		def ValuesInKlass(pcClass)
			return This.Klass(pcClass)

		def ClassValues(pcClass)
			return This.Klass(pcClass)

		def KlassValues(pcClass)
			return This.Klass(pcClass)

		def ContentOfClass(pcClass)
			return This.Klass(pcClass)

		def ContentOfKlass(pcClass)
			return This.Klass(pcClass)

		def ClassContent(pcClass)
			return This.Klass(pcClass)

		def KlassContent(pcClass)
			return This.Klass(pcClass)

		#>

	  #-------------------------------------------#
	 #  GETTING THE NUMBER OF VALUES IN A KLASS  #
	#-------------------------------------------#

	def NumberOfValuesInClass(pcClass)
		nResult = len( This.Klass(pcClass) )
		return nResult

		#< @FunctionAlternativeForms

		def HowManyValuesInClass(pcClass)
			return This.NumberOfValuesInClass(pcClass)

		def HowManyValueInClass(pcClass)
			return This.NumberOfValuesInClass(pcClass)

		def ClassSize(pcClass)
			return This.NumberOfValuesInClass(pcClass)

		def SizeOfClass(pcClass)
			return This.NumberOfValuesInClass(pcClass)

		def NumberOfValuesInKlass(pcClass)
			return This.NumberOfValuesInClass(pcClass)

		def HowManyValuesInKlass(pcClass)
			return This.NumberOfValuesInClass(pcClass)

		def HowManyValueInKlass(pcClass)
			return This.NumberOfValuesInClass(pcClass)

		def KlassSize(pcClass)
			return This.NumberOfValuesInClass(pcClass)

		def SizeOfKlass(pcClass)
			return This.NumberOfValuesInClass(pcClass)

		def NumberOfValuesInCategory(pcClass)
			return This.NumberOfValuesInClass(pcClass)

		def HowManyValuesInCategory(pcClass)
			return This.NumberOfValuesInClass(pcClass)

		def HowManyValueInCategory(pcClass)
			return This.NumberOfValuesInClass(pcClass)

		def CategorySize(pcClass)
			return This.NumberOfValuesInClass(pcClass)

		def SizeOfCategory(pcClass)
			return This.NumberOfValuesInClass(pcClass)

		def NumberOfValuesInCateg(pcClass)
			return This.NumberOfValuesInClass(pcClass)

		def HowManyValuesInCateg(pcClass)
			return This.NumberOfValuesInClass(pcClass)

		def HowManyValueInCateg(pcClass)
			return This.NumberOfValuesInClass(pcClass)

		def CategSize(pcClass)
			return This.NumberOfValuesInClass(pcClass)

		def SizeOfCateg(pcClass)
			return This.NumberOfValuesInClass(pcClass)

		#-- Adding ...This...() to the all the names above

		def HowManyValuesInThisClass(pcClass)
			return This.NumberOfValuesInClass(pcClass)

		def HowManyValueInThisClass(pcClass)
			return This.NumberOfValuesInClass(pcClass)

		def SizeOfThisClass(pcClass)
			return This.NumberOfValuesInClass(pcClass)

		def NumberOfValuesInThisKlass(pcClass)
			return This.NumberOfValuesInClass(pcClass)

		def HowManyValuesInThisKlass(pcClass)
			return This.NumberOfValuesInClass(pcClass)

		def HowManyValueInThisKlass(pcClass)
			return This.NumberOfValuesInClass(pcClass)

		def SizeOfThisKlass(pcClass)
			return This.NumberOfValuesInClass(pcClass)

		def NumberOfValuesInThisCategory(pcClass)
			return This.NumberOfValuesInClass(pcClass)

		def HowManyValuesInThisCategory(pcClass)
			return This.NumberOfValuesInClass(pcClass)

		def HowManyValueInThisCategory(pcClass)
			return This.NumberOfValuesInClass(pcClass)

		def SizeOfThisCategory(pcClass)
			return This.NumberOfValuesInClass(pcClass)

		def NumberOfValuesInThisCateg(pcClass)
			return This.NumberOfValuesInClass(pcClass)

		def HowManyValuesInThisCateg(pcClass)
			return This.NumberOfValuesInClass(pcClass)

		def HowManyValueInThisCateg(pcClass)
			return This.NumberOfValuesInClass(pcClass)

		def SizeOfThisCateg(pcClass)
			return This.NumberOfValuesInClass(pcClass)

		#>

	  #--------------------------------#
	 #  GETIING SIZES OF ALL CLASSES  #
	#--------------------------------#

	def ClassesSizes()
		acClasses = This.Classes()
		nLen = len(acClasses)

		anResult = []

		for i = 1 to nLen
			anResult + This.ClassSize(acClasses[i])
		next

		return anResult

		#< @FunctionAlternativeForms

		def KlassesSizes()
			return This.ClassesSizes()

		#--

		def CategoriesSizes()
			return This.ClassesSizes()

		def CategSizes()
			return This.ClassesSizes()

		def CategsSizes()
			return This.ClassesSizes()

		#--

		def NumberOfValuesInAllClasses()
			return This.ClassesSizes()

		def NumberOfValuesInAllKlasses()
			return This.ClassesSizes()

		#>

	def ClassesSizesXT()
		acClasses = This.Classes()
		nLen = len(acClasses)

		aResult = []

		for i = 1 to nLen
			aResult + [ acClasses[i], This.ClassSize(acClasses[i]) ]
		next

		return aResult

		def KlassesSizesXT()
			return This.ClassesSizesXT()

		#--

		def CategoriesSizesXT()
			return This.ClassesSizesXT()

		def CategSizesXT()
			return This.ClassesSizesXT()

		def CategsSizesXT()
			return This.ClassesSizesXT()

		#--

		def ClassesAndTheirSizes()
			return This.ClassesSizesXT()

		def KlassesAndTheirSizes()
			return This.ClassesSizesXT()

		#--

		def CategoriesAndTheirSizes()
			return This.ClassesSizesXT()

		def CategAndTheirSizes()
			return This.ClassesSizesXT()

		def CategsAndTheirSizes()
			return This.ClassesSizesXT()

		#--

		def NumberOfValuesInAllClassesXT()
			return This.ClassesSizesXT()

		def NumberOfValuesInAllKlassesXT()
			return This.ClassesSizesXT()

		#>

	  #--------------------------------------#
	 #  GETIING SIZES OF THE GIVEN CLASSES  #
	#--------------------------------------#

	def TheseClassesSizes(pacClasses)
		if CheckParams()
			if NOT (isList(pacClasses) and Q(pacClasses).IsListOfStrings())
				StzRaise("Incorrect param type! pcClasses must be a list of strings.")
			ok
		ok

		nLen = len(pacClasses)

		anResult = []

		for i = 1 to nLen
			anResult + This.ClassSize(pacClasses[i])
		next

		return anResult

		#< @FunctionAlternativeForms

		def TheseKlassesSizes(pacClasses)
			return This.TheseClassesSizes(pacClasses)

		def SizesOfTheseClasses(pacClasses)
			return This.TheseClassesSizes(pacClasses)

		def SizesOfTheseKlasses(pacClasses)
			return This.TheseClassesSizes(pacClasses)

		def SizesOfThesecategories(pacClasses)
			return This.TheseClassesSizes(pacClasses)

		def SizesOfTheseCategs(pacClasses)
			return This.TheseClassesSizes(pacClasses)

		def SizesOfTheseCateg(pacClasses)
			return This.TheseClassesSizes(pacClasses)

		#--

		def TheseCategoriesSizes(pacClasses)
			return This.TheseClassesSizes(pacClasses)

		def TheseCategsSizes(pacClasses)
			return This.TheseClassesSizes(pacClasses)

		#--

		def NumberOfValuesInTheseClasses(pacClasses)
			return This.TheseClassesSizes(pacClasses)

		def NumberOfValuesInTheseKlasses(pacClasses)
			return This.TheseClassesSizes(pacClasses)

		def NumbersOfValuesInTheseClasses(pacClasses)
			return This.TheseClassesSizes(pacClasses)

		def NumbersOfValuesInTheseKlasses(pacClasses)
			return This.TheseClassesSizes(pacClasses)

		def NumberOfValuesInTheseCategories(pacClasses)
			return This.TheseClassesSizes(pacClasses)

		def NumbersOfValuesInTheseCategories(pacClasses)
			return This.TheseClassesSizes(pacClasses)

		def NumberOfValuesInTheseCategs(pacClasses)
			return This.TheseClassesSizes(pacClasses)

		def NumbersOfValuesInTheseCategs(pacClasses)
			return This.TheseClassesSizes(pacClasses)

		def NumberOfValuesInTheseCateg(pacClasses)
			return This.TheseClassesSizes(pacClasses)

		def NumbersOfValuesInTheseCateg(pacClasses)
			return This.TheseClassesSizes(pacClasses)

		#>

	def TheseClassesSizesXT(pacClasses)
		if CheckParams()
			if NOT (isList(pacClasses) and Q(pacClasses).IsListOfStrings())
				StzRaise("Incorrect param type! pcClasses must be a list of strings.")
			ok
		ok

		nLen = len(pacClasses)

		aResult = []

		for i = 1 to nLen
			aResult + [ pacClasses[i], This.ClassSize(pacClasses[i]) ]
		next

		return aResult

		#< @FunctionAlternativeForms

		def TheseKlassesSizesXT(pacClasses)
			return This.TheseClassesSizesXT(pacClasses)

		def SizesOfTheseClassesXT(pacClasses)
			return This.TheseClassesSizesXT(pacClasses)

		def SizesOfTheseKlassesXT(pacClasses)
			return This.TheseClassesSizesXT(pacClasses)

		def SizesOfThesecategoriesXT(pacClasses)
			return This.TheseClassesSizesXT(pacClasses)

		def SizesOfTheseCategsXT(pacClasses)
			return This.TheseClassesSizesXT(pacClasses)

		def SizesOfTheseCategXT(pacClasses)
			return This.TheseClassesSizesXT(pacClasses)

		#--

		def TheseCategoriesSizesXT(pacClasses)
			return This.TheseClassesSizesXT(pacClasses)

		def TheseCategsSizesXT(pacClasses)
			return This.TheseClassesSizesXT(pacClasses)

		#--

		def NumberOfValuesInTheseClassesXT(pacClasses)
			return This.TheseClassesSizesXT(pacClasses)

		def NumberOfValuesInTheseKlassesXT(pacClasses)
			return This.TheseClassesSizesXT(pacClasses)

		def NumbersOfValuesInTheseClassesXT(pacClasses)
			return This.TheseClassesSizesXT(pacClasses)

		def NumbersOfValuesInTheseKlassesXT(pacClasses)
			return This.TheseClassesSizesXT(pacClasses)

		def NumberOfValuesInTheseCategoriesXT(pacClasses)
			return This.TheseClassesSizesXT(pacClasses)

		def NumbersOfValuesInTheseCategoriesXT(pacClasses)
			return This.TheseClassesSizesXT(pacClasses)

		def NumberOfValuesInTheseCategsXT(pacClasses)
			return This.TheseClassesSizesXT(pacClasses)

		def NumbersOfValuesInTheseCategsXT(pacClasses)
			return This.TheseClassesSizesXT(pacClasses)

		def NumberOfValuesInTheseCategXT(pacClasses)
			return This.TheseClassesSizesXT(pacClasses)

		def NumbersOfValuesInTheseCategXT(pacClasses)
			return This.TheseClassesSizesXT(pacClasses)

		#>

	  #--------------------------------------------#
	 #  GETTING THE FREQUENCY OF THE GIVEN CLASS  #
	#============================================#

	def KlassFreq(pcClass)
		nResult = This.NumberOfValuesInClass(pcClass) / This.NumberOfValues()
		return nResult

		#< @FunctionAlternativeForms

		def KlassFrequency(pcClass)
			return This.KlassFreq(pcClass)

		def ClassFreq(pcClass)
			return This.KlassFreq(pcClass)

		def ClassFrequency(pcClass)
			return This.KlassFreq(pcClass)

		def CategoryFrequency(pcClass)
			return This.KlassFreq(pcClass)

		def CategoryFreq(pcClass)
			return This.KlassFreq(pcClass)

		def CategFrequency(pcClass)
			return This.KlassFreq(pcClass)

		def CategFreq(pcClass)
			return This.KlassFreq(pcClass)

		#--

		def FrequencyOfThisClass(pcClass)
			return This.KlassFreq(pcClass)

		def FrequencyOfThisKlass(pcClass)
			return This.KlassFreq(pcClass)

		def FrequencyOfThisCategory(pcClass)
			return This.KlassFreq(pcClass)

		def FrequencyOfThisCateg(pcClass)
			return This.KlassFreq(pcClass)

		#--

		def FreqOfThisClass(pcClass)
			return This.KlassFreq(pcClass)

		def FreqOfThisKlass(pcClass)
			return This.KlassFreq(pcClass)

		def FreqOfThisCategory(pcClass)
			return This.KlassFreq(pcClass)

		def FreqOfThisCateg(pcClass)
			return This.KlassFreq(pcClass)

		#>

	def KlassFreqXT(pcClass)
		aResult = [ pcClass, This.ClassFreq(pcClass) ]
		return aResult

		#< @FunctionAlternativeForms

		def ClassAndItsFrequency(pcClass)
			return This.KlassFreqXT(pcClass)

		def KlassAndItsFrequency(pcClass)
			return This.KlassFreqXT(pcClass)

		def ClassAndItsFreq(pcClass)
			return This.KlassFreqXT(pcClass)

		def KlassAndItsFreq(pcClass)
			return This.KlassFreqXT(pcClass)

		def ClassFrequencyXT(pcClass)
			return This.KlassFreqXT(pcClass)

		def KlassFrequencyXT(pcClass)
			return This.KlassFreqXT(pcClass)

		def ClassFreqXT(pcClass)
			return This.KlassFreqXT(pcClass)


		#--

		def CategoryAndItsFrequency(pcClass)
			return This.KlassFreqXT(pcClass)

		def CategoryAndItsFreq(pcClass)
			return This.KlassFreqXT(pcClass)

		def CategAndItsFrequency(pcClass)
			return This.KlassFreqXT(pcClass)

		def CategAndItsFreq(pcClass)
			return This.KlassFreqXT(pcClass)

		def CategoryFrequencyXT(pcClass)
			return This.KlassFreqXT(pcClass)

		def CategoryFreqXT(pcClass)
			return This.KlassFreqXT(pcClass)

		def CategFrequencyXT(pcClass)
			return This.KlassFreqXT(pcClass)

		def CategFreqXT(pcClass)
			return This.KlassFreqXT(pcClass)

		#--

		def FrequencyOfThisClassXT(pcClass)
			return This.KlassFreqXT(pcClass)

		def FrequencyOfThisKlassXT(pcClass)
			return This.KlassFreq(pcClass)

		def FrequencyOfThisCategoryXT(pcClass)
			return This.KlassFreq(pcClass)

		def FrequencyOfThisCategXT(pcClass)
			return This.KlassFreqXT(pcClass)

		#--

		def FreqOfThisClassXT(pcClass)
			return This.KlassFreqXT(pcClass)

		def FreqOfThisKlassXT(pcClass)
			return This.KlassFreqXT(pcClass)

		def FreqOfThisCategoryXT(pcClass)
			return This.KlassFreqXT(pcClass)

		def FreqOfThisCategXT(pcClass)
			return This.KlassFreqXT(pcClass)

		#>

	  #------------------------------------------#
	 #  GETTING THE FREQUENCIES OF ALL CLASSES  #
	#------------------------------------------#

	def ClassesFrequencies()
		acClasses = This.Classes()
		nLen = len(acClasses)

		anResult = []

		for i = 1 to nLen
			anResult + This.ClassFrequency(acClasses[i])
		next

		return anResult

		def KlassesFrequencies()
			return This.ClassesFrequencies()

		def ClassesFreqs()
			return This.ClassesFrequencies()

		def ClassesFreq()
			return This.ClassesFrequencies()

		def KlassesFreqs()
			return This.ClassesFrequencies()

		def KlassesFreq()
			return This.ClassesFrequencies()

		#--

		def CategoriesFrequencies()
			return This.ClassesFrequencies()

		def CategFrequencies()
			return This.ClassesFrequencies()

		def CategoriesFreqs()
			return This.ClassesFrequencies()

		def CategoriesFreq()
			return This.ClassesFrequencies()

		def CategsFrequencies()
			return This.ClassesFrequencies()

		def CategsFreqs()
			return This.ClassesFrequencies()

		#>

	def ClassesFrequenciesXT()
		acClasses = This.Classes()
		nLen = len(acClasses)

		aResult = []

		for i = 1 to nLen
			aResult + [ acClasses[i], This.ClassFrequency(acClasses[i]) ]
		next

		return aResult

		def KlassesFrequenciesXT()
			return This.ClassesFrequenciesXT()

		def ClassesFreqsXT()
			return This.ClassesFrequenciesXT()

		def ClassesFreqXT()
			return This.ClassesFrequenciesXT()

		def KlassesFreqsXT()
			return This.ClassesFrequenciesXT()

		def KlassesFreqXT()
			return This.ClassesFrequenciesXT()

		#--

		def CategoriesFrequenciesXT()
			return This.ClassesFrequenciesXT()

		def CategFrequenciesXT()
			return This.ClassesFrequenciesXT()

		def CategoriesFreqsXT()
			return This.ClassesFrequenciesXT()

		def CategoriesFreqXT()
			return This.ClassesFrequenciesXT()

		def CategsFrequenciesXT()
			return This.ClassesFrequenciesXT()

		def CategsFreqsXT()
			return This.ClassesFrequenciesXT()

		#--

		def ClassesAndTheirFrequencies()
			return This.ClassesFrequenciesXT()

		def KlassesAndTheirFrequencies()
			return This.ClassesFrequenciesXT()

		def KlassesAndTheirFreq()
			return This.ClassesFrequenciesXT()

		def KlassesAndTheirFreqs()
			return This.ClassesFrequenciesXT()

		#--

		def CategoriesAndTheirFrequencies()
			return This.ClassesFrequenciesXT()

		def CategoriesAndTheirFreq()
			return This.ClassesFrequenciesXT()

		def CategoriesAndTheirFreqs()
			return This.ClassesFrequenciesXT()

		def CategAndTheirFrequencies()
			return This.ClassesFrequenciesXT()

		def CategsAndTheirFrequencies()
			return This.ClassesFrequenciesXT()

		def CategAndTheirFreqs()
			return This.ClassesFrequenciesXT()

		def CategsAndTheirFreqs()
			return This.ClassesFrequenciesXT()

		#>

	  #------------------------------------------------#
	 #  GETTING THE FREQUENCIES OF THE GIVEN CLASSES  #
	#------------------------------------------------#

	def TheseClassesFrequencies(pacClasses)
		if CheckParams()
			if NOT (isList(pacClasses) and Q(pacClasses).IsListOfStrings())
				StzRaise("Incorrect param type! pacClasses must be a list of strings.")
			ok
		ok

		nLen = len(pacClasses)

		anResult = []

		for i = 1 to nLen
			anResult + This.ClassFrequency(pacClasses[i])
		next

		return anResult

		#< @FunctionAlternativeForms

		def TheseKlassesFrequencies(pacClasses)
			return This.TheseClassesFrequencies(pacClasses)

		def TheseClassesFreqs(pacClasses)
			return This.TheseClassesFrequencies(pacClasses)

		def TheseClassesFreq(pacClasses)
			return This.TheseClassesFrequencies(pacClasses)

		def TheseKlassesFreqs(pacClasses)
			return This.TheseClassesFrequencies(pacClasses)

		def TheseKlassesFreq(pacClasses)
			return This.TheseClassesFrequencies(pacClasses)

		#--

		def TheseCategoriesFrequencies(pacClasses)
			return This.TheseClassesFrequencies(pacClasses)

		def TheseCategFrequencies(pacClasses)
			return This.TheseClassesFrequencies(pacClasses)

		def TheseCategoriesFreqs(pacClasses)
			return This.TheseClassesFrequencies(pacClasses)

		def TheseCategoriesFreq(pacClasses)
			return This.TheseClassesFrequencies(pacClasses)

		def TheseCategsFrequencies(pacClasses)
			return This.TheseClassesFrequencies(pacClasses)

		def TheseCategsFreqs(pacClasses)
			return This.TheseClassesFrequencies(pacClasses)

		#>

	def TheseClassesFrequenciesXT(pacClasses)
		if CheckParams()
			if NOT (isList(pacClasses) and Q(pacClasses).IsListOfStrings())
				StzRaise("Incorrect param type! pacClasses must be a list of strings.")
			ok
		ok

		nLen = len(pacClasses)

		aResult = []

		for i = 1 to nLen
			aResult + [ pacClasses[i], This.ClassFrequency(pacClasses[i]) ]
		next

		return aResult

		#< @FunctionAlternativeForms

		def TheseKlassesFrequenciesXT(pacClasses)
			return This.TheseClassesFrequenciesXT(pacClasses)

		def TheseClassesFreqsXT(pacClasses)
			return This.TheseClassesFrequenciesXT(pacClasses)

		def TheseClassesFreqXT(pacClasses)
			return This.TheseClassesFrequenciesXT(pacClasses)

		def TheseKlassesFreqsXT(pacClasses)
			return This.TheseClassesFrequenciesXT(pacClasses)

		def TheseKlassesFreqXT(pacClasses)
			return This.TheseClassesFrequenciesXT(pacClasses)

		#--

		def TheseCategoriesFrequenciesXT(pacClasses)
			return This.TheseClassesFrequenciesXT(pacClasses)

		def TheseCategFrequenciesXT(pacClasses)
			return This.TheseClassesFrequenciesXT(pacClasses)

		def TheseCategoriesFreqsXT(pacClasses)
			return This.TheseClassesFrequenciesXT(pacClasses)

		def TheseCategoriesFreqXT(pacClasses)
			return This.TheseClassesFrequenciesXT(pacClasses)

		def TheseCategsFrequenciesXT(pacClasses)
			return This.TheseClassesFrequenciesXT(pacClasses)

		def TheseCategsFreqsXT(pacClasses)
			return This.TheseClassesFrequenciesXT(pacClasses)

		#--

		def TheseClassesAndTheirFrequencies(pacClasses)
			return This.TheseClassesFrequenciesXT(pacClasses)

		def TheseKlassesAndTheirFrequencies(pacClasses)
			return This.TheseClassesFrequenciesXT(pacClasses)

		def TheseCategoriesAndTheirFrequencies(pacClasses)
			return This.TheseClassesFrequenciesXT(pacClasses)

		def TheseCategsAndTheirFrequencies(pacClasses)
			return This.TheseClassesFrequenciesXT(pacClasses)

		def TheseCategAndTheirFrequencies(pacClasses)
			return This.TheseClassesFrequenciesXT(pacClasses)

		#--

		def TheseClassesAndTheirFreqs(pacClasses)
			return This.TheseClassesFrequenciesXT(pacClasses)

		def TheseKlassesAndTheirFreqs(pacClasses)
			return This.TheseClassesFrequenciesXT(pacClasses)

		def TheseCategoriesAndTheirFreqs(pacClasses)
			return This.TheseClassesFrequenciesXT(pacClasses)

		def TheseCategsAndTheirFreqs(pacClasses)
			return This.TheseClassesFrequenciesXT(pacClasses)

		def TheseCategAndTheirFreqs(pacClasses)
			return This.TheseClassesFrequenciesXT(pacClasses)

		#--

		def TheseClassesAndTheirFreq(pacClasses)
			return This.TheseClassesFrequenciesXT(pacClasses)

		def TheseKlassesAndTheirFreq(pacClasses)
			return This.TheseClassesFrequenciesXT(pacClasses)

		def TheseCategoriesAndTheirFreq(pacClasses)
			return This.TheseClassesFrequenciesXT(pacClasses)

		def TheseCategsAndTheirFreq(pacClasses)
			return This.TheseClassesFrequenciesXT(pacClasses)

		def TheseCategAndTheirFreq(pacClasses)
			return This.TheseClassesFrequenciesXT(pacClasses)

		#>

	  #-------------------------------------#
	 #   GETTING THE N STRONGEST CLASSES   #
	#=====================================#

	def NStrongestClasses(n)
		anPos = QR(This.ClassesFrequencies(), :stzListOfNumbers).FindNGreatestNumbers(n)
		acResult = Q(This.Classes()).ItemsAtPositions(anPos)
		return acResult

		#< @FunctionAlternativeForms

		def NStrongestKlasses(n)
			return This.NStrongestClasses(n)

		def NStrongestCategories(n)
			return This.NStrongestClasses(n)

		def NStrongestCateg(n)
			return This.NStrongestClasses(n)

		def StrongestNClasses(n)
			return This.NStrongestClasses(n)

		def StrongestNKlasses(n)
			return This.NStrongestClasses(n)

		def StrongestNCategories(n)
			return This.NStrongestClasses(n)

		def StrongestNCateg(n)
			return This.NStrongestClasses(n)

		#>

	def NStrongestClassesXT(n)

//		anPos     = QR(This.ClassesFrequencies(), :stzListOfNumbers).FindNGreatestNumbers(n)

		anPos = Q(This.ClassesFrequencies()).SortQ().LastNItemsQ(3).SortedInDescending()

		acClasses = Q(This.Classes()).ItemsAtPositions(anPos)
		anFreqs   = Q(This.ClassesFrequencies()).ItemsAtPositions(anPos)

		aResult   = Association([ acClasses, anFreqs ])

		return aResult

		#< @FunctionAlternativeForms

		def NStrongestKlassesXT(n)
			return This.NStrongestClassesXT(n)

		def NStrongestCategoriesXT(n)
			return This.NStrongestClassesXT(n)

		def NStrongestCategXT(n)
			return This.NStrongestClassesXT(n)

		def StrongestNClassesXT(n)
			return This.NStrongestClassesXT(n)

		def StrongestNKlassesXT(n)
			return This.NStrongestClassesXT(n)

		def StrongestNCategoriesXT(n)
			return This.NStrongestClassesXT(n)

		def StrongestNCategXT(n)
			return This.NStrongestClassesXT(n)

		#--

		def NStrongestKlassesAndTheirFrequencies(n)
			return This.NStrongestClassesXT(n)

		def NStrongestCategoriesAndTheirFrequencies(n)
			return This.NStrongestClassesXT(n)

		def NStrongestCategAndTheirFrequencies(n)
			return This.NStrongestClassesXT(n)

		def StrongestNClassesAndTheirFrequencies(n)
			return This.NStrongestClassesXT(n)

		def StrongestNKlassesAndTheirFrequencies(n)
			return This.NStrongestClassesXT(n)

		def StrongestNCategoriesAndTheirFrequencies(n)
			return This.NStrongestClassesXT(n)

		def StrongestNCategAndTheirFrequencies(n)
			return This.NStrongestClassesXT(n)

		#>

	#--

	def StrongestClass()
		return This.StrongestNClasses(1)

		#< @FunctionAlternativeForms

		def StrongestKlass()
			return This.StrongestClass()

		def StrongestCategory()
			return This.StrongestClass()

		def StrongestCateg()
			return This.StrongestClass()

		def TopClass()
			return This.StrongestClass()

		def TopKlass()
			return This.StrongestClass()

		def TopCategory()
			return This.StrongestClass()

		def TopCateg()
			return This.StrongestClass()

		#>

	def StrongestClassXT()
		return This.StrongestNClassesXT(1)

		#< @FunctionAlternativeForms

		def StrongestKlassXT()
			return This.StrongestClassXT()

		def StrongestCategoryXT()
			return This.StrongestClassXT()

		def StrongestCategXT()
			return This.StrongestClassXT()

		def TopClassXT()
			return This.StrongestClassXT()

		def TopKlassXT()
			return This.StrongestClassXT()

		def TopCategoryXT()
			return This.StrongestClassXT()

		def TopCategXT()
			return This.StrongestClassXT()

		#--

		def StrongestClassAndTheirFrequencies()
			return This.StrongestClassXT()

		def StrongestKlassAndTheirFrequencies()
			return This.StrongestClassXT()

		def StrongestCategoryAndTheirFrequencies()
			return This.StrongestClassXT()

		def StrongestCategAndTheirFrequencies()
			return This.StrongestClassXT()

		def TopClassAndTheirFrequencies()
			return This.StrongestClassXT()

		def TopKlassAndTheirFrequencies()
			return This.StrongestClassXT()

		def TopCategoryAndTheirFrequencies()
			return This.StrongestClassXT()

		def TopCategAndTheirFrequencies()
			return This.StrongestClassXT()

		#>

	#--

	def Top3Classes()
		return This.StrongestNClasses(3)

		#< @FunctionAlternativeForms

		def 3StrongestKlasses(n)
			return This.Top3Classes(n)

		def 3StrongestCategories(n)
			return This.Top3Classes(n)

		def 3StrongestCateg(n)
			return This.Top3Classes(n)

		def Strongest3Classes()
			return This.Top3Classes(n)

		def Strongest3Klasses(n)
			return This.Top3Classes(n)

		def Strongest3Categories(n)
			return This.Top3Classes(n)

		def Strongest3Categ(n)
			return This.Top3Classes(n)

		#>

	def Top3ClassesXT()
		return This.StrongestNClassesXT(3)

		#< @FunctionAlternativeForms

		def 3StrongestKlassesXT(n)
			return This.Top3ClassesXT(n)

		def 3StrongestCategoriesXT(n)
			return This.Top3ClassesXT(n)

		def 3StrongestCategXT(n)
			return This.Top3ClassesXT(n)

		def Strongest3ClassesXT()
			return This.Top3ClassesXT(n)

		def Strongest3KlassesXT(n)
			return This.Top3ClassesXT(n)

		def Strongest3CategoriesXT(n)
			return This.Top3ClassesXT(n)

		def Strongest3CategXT(n)
			return This.Top3ClassesXT(n)

		#--

		def Top3ClassesAndTheirFrequencies(n)
			return This.Top3ClassesXT(n)

		def 3StrongestKlassesAndTheirFrequencies(n)
			return This.Top3ClassesXT(n)

		def 3StrongestCategoriesAndTheirFrequencies(n)
			return This.Top3ClassesXT(n)

		def 3StrongestCategAndTheirFrequencies(n)
			return This.Top3ClassesXT(n)

		def Strongest3ClassesAndTheirFrequencies()
			return This.Top3ClassesXT(n)

		def Strongest3KlassesAndTheirFrequencies(n)
			return This.Top3ClassesXT(n)

		def Strongest3CategoriesAndTheirFrequencies(n)
			return This.Top3ClassesXT(n)

		def Strongest3CategAndTheirFrequencies(n)
			return This.Top3ClassesXT(n)

		#>

	  #-----------------------------------#
	 #   GETTING THE N WEAKEST CLASSES   #
	#===================================#

	def NWeakestClasses(n)
		anPos = QR(This.ClassesFrequencies(), :stzListOfNumbers).FindNLowestNumbers(n)
		acResult = Q(This.Classes()).ItemsAtPositions(anPos)
		return acResult

		#< @FunctionAlternativeForms

		def NWeakestKlasses(n)
			return This.NWeakestClasses(n)

		def NWeakestCategories(n)
			return This.NWeakestClasses(n)

		def NWeakestCateg(n)
			return This.NWeakestClasses(n)

		def WeakestNClasses(n)
			return This.NWeakestClasses(n)

		def WeakestNKlasses(n)
			return This.NWeakestClasses(n)

		def WeakestNCategories(n)
			return This.NWeakestClasses(n)

		def WeakestNCateg(n)
			return This.NWeakestClasses(n)

		#>

	def NWeakestClassesXT(n)
		anPos     = QR(This.ClassesFrequencies(), :stzListOfNumbers).FindNSmallestNumbers(n)

		acClasses = Q(This.Classes()).ItemsAtPositions(anPos)
		anFreqs   = Q(This.ClassesFrequencies()).ItemsAtPositions(anPos)

		aResult   = Association([ acClasses, anFreqs ])

		return aResult

		#< @FunctionAlternativeForms

		def NWeakestKlassesXT(n)
			return This.NWeakestClassesXT(n)

		def NWeakestCategoriesXT(n)
			return This.NWeakestClassesXT(n)

		def NWeakestCategXT(n)
			return This.NWeakestClassesXT(n)

		def WeakestNClassesXT(n)
			return This.NWeakestClassesXT(n)

		def WeakestNKlassesXT(n)
			return This.NWeakestClassesXT(n)

		def WeakestNCategoriesXT(n)
			return This.NWeakestClassesXT(n)

		def WeakestNCategXT(n)
			return This.NWeakestClassesXT(n)

		#--

		def NWeakestClassesAndTheirFrequencies(n)
			return This.NWeakestClassesXT(n)

		def WeakestNClassesAndTheirFrequencies(n)
			return This.NWeakestClassesXT(n)

		def NWeakestKlassesAndTheirFrequencies(n)
			return This.NWeakestClassesXT(n)

		def WeakestNKlassesAndTheirFrequencies(n)
			return This.NWeakestClassesXT(n)

		def NWeakestCategoriesAndTheirFrequencies(n)
			return This.NWeakestClassesXT(n)

		def WeakestNCategoriesAndTheirFrequencies(n)
			return This.NWeakestClassesXT(n)

		def NWeakestCategsAndTheirFrequencies(n)
			return This.NWeakestClassesXT(n)

		def WeakestNCategAndTheirFrequencies(n)
			return This.NWeakestClassesXT(n)

		#>

	#--

	def WeakestClass()
		return This.WeakestNClasses(1)

		#< @FunctionAlternativeForms

		def WeakestKlass()
			return This.WeakestClass()

		def WeakestCategory()
			return This.WeakestClass()

		def WeakestCateg()
			return This.WeakestClass()

		def BottomClass()
			return This.WeakestClass()

		def BottomKlass()
			return This.WeakestClass()

		def BottomCategory()
			return This.WeakestClass()

		def BottomCateg()
			return This.WeakestClass()

		#>

	def WeakestClassXT()
		return This.WeakestNClassesXT(1)

		#< @FunctionAlternativeForms

		def WeakestKlassXT()
			return This.WeakestClassXT()

		def WeakestCategoryXT()
			return This.WeakestClassXT()

		def WeakestCategXT()
			return This.WeakestClassXT()

		def BottomClassXT()
			return This.WeakestClassXT()

		def BottomKlassXT()
			return This.WeakestClassXT()

		def BottomCategoryXT()
			return This.WeakestClassXT()

		def BottomCategXT()
			return This.WeakestClassXT()

		#--

		def WeakestClassAndItsFrequency(n)
			return This.WeakestClassXT(n)

		def WeakestKlassAndItsFrequency(n)
			return This.WeakestClassXT(n)

		def WeakestCategoryAndItsFrequency(n)
			return This.WeakestClassXT(n)

		def WeakestCategAndItsFrequency(n)
			return This.WeakestClassXT(n)

		#>

	#--

	def Bottom3Classes()
		return This.WeakestNClasses(3)

		#< @FunctionAlternativeForms

		def 3WeakestKlasses(n)
			return This.Bottom3Classes(n)

		def 3WeakestCategories(n)
			return This.Bottom3Classes(n)

		def 3WeakestCateg(n)
			return This.Bottom3Classes(n)

		def Weakest3Classes()
			return This.Bottom3Classes(n)

		def Weakest3Klasses(n)
			return This.Bottom3Classes(n)

		def Weakest3Categories(n)
			return This.Bottom3Classes(n)

		def Weakest3Categ(n)
			return This.Bottom3Classes(n)

		#>

	def Bottom3ClassesXT()
		return This.WeakestNClassesXT(3)

		#< @FunctionAlternativeForms

		def 3WeakestKlassesXT(n)
			return This.Bottom3ClassesXT(n)

		def 3WeakestCategoriesXT(n)
			return This.Bottom3ClassesXT(n)

		def 3WeakestCategXT(n)
			return This.Bottom3ClassesXT(n)

		def Weakest3ClassesXT()
			return This.Bottom3ClassesXT(n)

		def Weakest3KlassesXT(n)
			return This.Bottom3ClassesXT(n)

		def Weakest3CategoriesXT(n)
			return This.Bottom3ClassesXT(n)

		def Weakest3CategXT(n)
			return This.Bottom3ClassesXT(n)

		#--


		def 3WeakestKlassesAndTheirFrequencies(n)
			return This.Bottom3ClassesXT(n)

		def 3WeakestCategoriesAndTheirFrequencies(n)
			return This.Bottom3ClassesXT(n)

		def 3WeakestCategAndTheirFrequencies(n)
			return This.Bottom3ClassesXT(n)

		def Weakest3ClassesAndTheirFrequencies()
			return This.Bottom3ClassesXT(n)

		def Weakest3KlassesAndTheirFrequencies(n)
			return This.Bottom3ClassesXT(n)

		def Weakest3CategoriesAndTheirFrequencies(n)
			return This.Bottom3ClassesXT(n)

		def Weakest3CategAndTheirFrequencies(n)
			return This.Bottom3ClassesXT(n)

		#>

	  #-------------------------------------#
	 #   CLASSIFYING VALUES INSIDE LISTS   #
	#=====================================#

	def ClassesInList()
		acResult = []
		aUniqueValues = U( @Merge(This.Lists()) )
		nLen = len(aUniqueValues)

		for i = 1 to nLen
			acResult + Q(aUniqueValues[i]).Stringified()
		next

		return acResult

		#< @FunctionFluentForm

		def ClassesInListQ()
			return This.ClassesInListsQR(:stzList)

		def ClassesInListQR(pcReturnType)
			if isList(pcReturnType) and StzListQ(pcReturnType).IsOneOfTheseNamedParams([ :ReturnedAs, :ReturnAs ])
				pcReturnType = pcReturnType[2]
			ok

			switch pcReturnType
			on :stzList
				return new stzList( This.ClassesInList() )

			on :stzListOfStrings
				return new stzListOfStrings( This.ClassesInList() )

			other
				StzRaise("Unsupported return type!")
			off
		#>

		#< @FunctionAlternativeForms

		def KlassesInList()
			return This.ClassesInList()

			def KlassesInListQ()
				return This.ClassesInListQ()

			def KlassesInListQR(pcReturnType)
				return This.CategoriesInListQR(pcReturnType)

		def CategoriesInList()
			return This.ClassesInList()

			def CategoriesInListQ()
				return This.ClassesInListQ()

			def CategoriesInListQR(pcReturnType)
				return This.ClassesInListQR(pcReturnType)

		def CategsInList()
			return This.ClassesInList()

			def CategsInListQ()
				return This.ClassesInListQ()

			def CategsInListQR(pcReturnType)
				return This.ClassesInListQR(pcReturnType)

		#--

		def ClassesInLists()
			return This.ClassesInList()

		def KlassesInLists()
			return This.ClassesInList()

			def KlassesInListsQ()
				return This.ClassesInListQ()

			def KlassesInListsQR(pcReturnType)
				return This.CategoriesInListQR(pcReturnType)

		def CategoriesInLists()
			return This.ClassesInList()

			def CategoriesInListsQ()
				return This.ClassesInListQ()

			def CategoriesInListsQR(pcReturnType)
				return This.ClassesInListQR(pcReturnType)

		def CategsInLists()
			return This.ClassesInList()

			def CategsInListsQ()
				return This.ClassesInListQ()

			def CategsInListsQR(pcReturnType)
				return This.ClassesInListQR(pcReturnType)

		#>

	  #-----------------------------------------#
	 #  GETTING THE NUMBER OF KLASSES IN LIST  #
	#-----------------------------------------#

	def NumberOfClassesInList()
		return len( This.CLassesInList() )

		#< @FunctionAlternativeForms

		def NumberOfKlassesInList()
			return This.NumberOfClassesInList()

		def NumberOfCategoriesInList()
			return This.NumberOfClassesInList()

		def NumberOfCategInList()
			return This.NumberOfClassesInList()

		def HowManyCategoriesInList()
			return This.NumberOfClassesInList()

		def HowManyCategInList()
			return This.NumberOfClassesInList()

		def HowManyClassesInList()
			return This.NumberOfClassesInList()

		def HowManyClassInList()
			return This.NumberOfClassesInList()

		def HowManyKlassesInList()
			return This.NumberOfClassesInList()

		def HowManyKlassInList()
			return This.NumberOfClassesInList()

		#--

		def NumberOfClassesInLists()
			return This.NumberOfClassesInList()

		def NumberOfKlassesInLists()
			return This.NumberOfClassesInList()

		def NumberOfCategoriesInLists()
			return This.NumberOfClassesInList()

		def NumberOfCategInLists()
			return This.NumberOfClassesInList()

		def HowManyCategoriesInLists()
			return This.NumberOfClassesInList()

		def HowManyCategInLists()
			return This.NumberOfClassesInList()

		def HowManyClassesInLists()
			return This.NumberOfClassesInList()

		def HowManyClassInLists()
			return This.NumberOfClassesInList()

		def HowManyKlassesInLists()
			return This.NumberOfClassesInList()

		def HowManyKlassInLists()
			return This.NumberOfClassesInList()

		#>

	  #------------------------------#
	 #  CLASSIFYING VALUES IN LIST  # TODO: Test and clarify!
	#------------------------------#

	def ClassifyInList()

		aResult = []
		aClasses = This.ClassesInList()
		nLen = len(aClasses)

		for i = 1 to nLen
			aResult + [ aClasses[i], This.FindItem(aClasses[i]) ]
		next

		return aResult

		#< @FunctionFluentForm

		def ClassifyInListQ()
			return This.ClassifyInListQR(pcReturnType)

		def ClassifyInListQR(pcReturnType)
			if isList(pcReturnType) and StzListQ(pcReturnType).IsOneOfTheseNamedParams([ :ReturnedAs, :ReturnAs ])
				pcReturnType = pcReturnType[2]
			ok
	
			switch pcReturnType
			on :stzList
				return new stzList( This.ClassifyInList() )

			on :stzHashList
				return new stzHashList( This.ClassifyInList() )
	
			other
				StzRaise("Unsupported return type!")
			off						
		#>

		#< @FunctionAlternativeForms

		def CategoriseInList()
			return This.ClassifyInListQ()

			def CategoriseInListQ()
				return This.ClassifyInListQ()
	
			def CategoriseInListQR(pcReturnType)
				return This.ClassifyInListQR(pcReturnType)

		def CategorizeInList()
			return This.ClassifyInList()

			def CategorizeInListQ()
				return This.ClassifyInListQ()
	
			def CategorizeInListQR(pcReturnType)
				return This.ClassifyInListQR(pcReturnType)

		def KlassifyInList()
			return This.ClassifyInList()

			def KlassifyInListQ()
				return This.ClassifyInListQ()

			def KlassifyInListQR(pcReturnType)
				return This.ClassifyInListQR(pcReturnType)

		#--

		def ClassifyInLists()
			return This.ClassifyInList()

			def ClassifyInListsQ()
				return This.ClassifyInListQ()
	
			def ClassifyInListsQR(pcReturnType)
				return This.ClassifyInListQR(pcReturnType)

		def CategoriseInLists()
			return This.ClassifyInList()

			def CategoriseInListsQ()
				return This.ClassifyInListQ()
	
			def CategoriseInListsQR(pcReturnType)
				return This.ClassifyInListQR(pcReturnType)

		def CategorizeInLists()
			return This.ClassifyInLists()

			def CategorizeInListsQ()
				return This.ClassifyInListQ()
	
			def CategorizeInListsQR(pcReturnType)
				return This.ClassifyInListQR(pcReturnType)

		def KlassifyInLists()
			return This.ClassifyInList()

			def KlassifyInListsQ()
				return This.ClassifyInListQ()

			def KlassifyInListsQR(pcReturnType)
				return This.ClassifyInListQR(pcReturnType)

		#==

		def ClassifyItemsInList()
			return This.ClassifyInList()

			def ClassifyItemsInListQ()
				return This.ClassifyInList()

			def ClassifyItemsInListQR(pcReturnType)
				return This.ClassifyInListQT(pcReturnType)

		def CategoriseItemsInList()
			return This.ClassifyInListQ()

			def CategoriseItemsInListQ()
				return This.ClassifyInListQ()
	
			def CategoriseItemsInListQR(pcReturnType)
				return This.ClassifyInListQR(pcReturnType)

		def CategorizeItemsInList()
			return This.ClassifyInList()

			def CategorizeItemsInListQ()
				return This.ClassifyInListQ()
	
			def CategorizeItemsInListQR(pcReturnType)
				return This.ClassifyInListQR(pcReturnType)

		def KlassifyItemsInList()
			return This.ClassifyInList()

			def KlassifyItemsInListQ()
				return This.ClassifyInListQ()

			def KlassifyItemsInListQR(pcReturnType)
				return This.ClassifyInListQR(pcReturnType)

		#--

		def ClassifyItemsInLists()
			return This.ClassifyInList()

			def ClassifyItemsInListsQ()
				return This.ClassifyInListQ()
	
			def ClassifyItemsInListsQR(pcReturnType)
				return This.ClassifyInListQR(pcReturnType)

		def CategoriseItemsInLists()
			return This.ClassifyInList()

			def CategoriseItemsInListsQ()
				return This.ClassifyInListQ()
	
			def CategoriseItemsInListsQR(pcReturnType)
				return This.ClassifyInListQR(pcReturnType)

		def CategorizeItemsInLists()
			return This.ClassifyInLists()

			def CategorizeItemsInListsQ()
				return This.ClassifyInListQ()
	
			def CategorizeItemsInListsQR(pcReturnType)
				return This.ClassifyInListQR(pcReturnType)

		def KlassifyItemsInLists()
			return This.ClassifyInList()

			def KlassifyItemsInListsQ()
				return This.ClassifyInListQ()

			def KlassifyItemsInListsQR(pcReturnType)
				return This.ClassifyInListQR(pcReturnType)

		#>

	  #-------------------------------------------------#
	 #  GETTING THE VALUES RELATED TO A KLASS-IN-LIST  #
	#-------------------------------------------------#

	def KlassInList(pcClass)
		aResult = This.KeysForItemInList(pcClass)
		return aResult

		#< @FunctionFluentForms

		def KalssInListQ(pcClass)
			return This.KlassInListQR(pcClass, :stzList)

		def KlassInListQR(pcClass, pcReturnType)
			if isList(pcReturnType) and StzListQ(pcReturnType).IsOneOfTheseNamedParams([ :ReturnedAs, :ReturnAs ])
				pcReturnType = pcReturnType[2]
			ok

			switch pcReturnType
			on :stzString	
				return new stzString( This.KlassInList(pcClass) )

			on :stzText
				return new stzText( This.KlassInList(pcClass) )

			other
				StzRaise("Unsupported return type!")
			off

		#>

		#< @FunctionAlternativeForms

		def ClassInList(pcClass)
			return This.KlassInList(pcClass)

			def ClassInListQ(pcClass)
				return This.KalssInListQ(pcClass)

			def ClassInListQR(pcClass, pcReturnType)
				return This.KalssInListQR(pcClass)

		def CategoryInList(pcClass)
			return This.KlassInList(pcClass)

			def CategoryInListQ(pcClass)
				return This.KalssInListQ(pcClass)

			def CategoryInListQR(pcClass, pcReturnType)
				return This.KalssInListQR(pcClass)

		def CategInList(pcClass)
			return This.KlassInList(pcClass)

			def CategInListQ(pcClass)
				return This.KalssInListQ(pcClass)

			def CategInListQR(pcClass, pcReturnType)
				return This.KalssInListQR(pcClass)

		#--

		def KalssInLists(pcClass)
			return This.KlassInList(pcClass)

			def KalssInListsQ(pcClass)
				return This.KalssInListQ(pcClass)

			def KalssInListsQR(pcClass, pcReturnType)
				return This.KalssInListQR(pcClass)

		def ClassInLists(pcClass)
			return This.KlassInList(pcClass)

			def ClassInListsQ(pcClass)
				return This.KalssInListQ(pcClass)

			def ClassInListsQR(pcClass, pcReturnType)
				return This.KalssInListQR(pcClass)

		def CategoryInLists(pcClass)
			return This.KlassInList(pcClass)

			def CategoryInListsQ(pcClass)
				return This.KalssInListQ(pcClass)

			def CategoryInListsQR(pcClass, pcReturnType)
				return This.KalssInListQR(pcClass)

		def CategInLists(pcClass)
			return This.KlassInList(pcClass)

			def CategInListsQ(pcClass)
				return This.KalssInListQ(pcClass)

			def CategInListsQR(pcClass, pcReturnType)
				return This.KalssInListQR(pcClass)

		#>

	  #===============#
	 #     QUERY     #
	#===============#

	// TODO: FindWhere(cCondition) --> See how this was made in stzList

	  #==============#
	 #     SHOW     #
	#==============#

	def Show()
		cStr = ""
		for i = 1 to This.NumberOfPairs()
			cStr += "'" + This.NthKey(i) + "'" + ": " + @@(This.NthValue(i))
			if i < This.NumberOfPairs()
				cStr += NL
			ok
		next
		? cStr

		/* TODO
		if you try it for [ :same = :LefToRight, :كلام = :RightToleft, :other = :LefToRight ]
		then you get :

same: lefttoright
					كلام: righttoleft
this: lefttoright
*/
	  #-----------#
	 #   MISC.   #
	#-----------#

	def StzType()
		return :stzHashList

	def IsHashList() # required by stzChainOfTruth
		return TRUE

	def ToCode()
		aPairs = This.Content()
		nLen = len(aPairs)

		cResult = "[ "

		for i = 1 to nLen
			cKey = aPairs[i][1]
			cValue = Q(aPairs[i][2]).Stringified()

			cBound = '"'
			if Q(cValue).IsBoundedBy('"')
				cBound = "'"
			ok
			cValue = cBound + cValue + cBound

			cPair = ":" + cKey + " = " + cValue + ", "
			cResult += cPair
		next

		cResult = Q(cResult).RemovedFromEnd(", ") + " ]"
		return cResult

	  #-----------------------------#
	 #     Operator overloading    #
	#-----------------------------#

	def operator(pOp,pValue)

		if pOp = "[]"
			
			if ring_type(pValue) = "STRING"
				return This.ValueByKey(pValue)

			ok

		ok
