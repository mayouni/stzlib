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

	def PerformOnKeys(pcCode)
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

	def PerformOnValues(pcCode)
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
	
	def ValueInPair(paPair)
		if isList(paPair) and ListIsPairAndKeyIsString(paPair) and
	           This.ContainsPair(paPair)
			return paPair[2]
		else
			StzRaise("Invalide param type!")
		ok

		def ValueInPairQ(paPair)
			return Q( This.ValueInPair(paPair) )

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
	
	def NumberOfOccurrenceOfValue(pValue)
		return len(This.FindValue(pValue))

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

	#-- WITHOUT CASESENSITIVE

	def ContainsValue(pValue)
		return This.ContainsValueCS(pValue, :CaseSensitive = TRUE)

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

		def FindFirstOccurrenceOfItemInList(pItem)
			return This.FindFirstItem(pItem)

	  #--------------------------------------------------------------------------------------#
	 #   WHEN THE VALUE IS A LIST, FINDING THE LAST OCCURRENCE OF AN ITEM INSIDE THAT LIST  # 
	#--------------------------------------------------------------------------------------#
	# TODO: Add case sensitivity

	def FindLastItem(pItem)
		n = This.NumberOfOccurreceOfItemInList(pItem)
		return This.FindNthItem(n, pItem)

		def FindLastOccurrenceOfItemInList(pItem)
			return This.FindLastItem(pItem)

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

		def HowManyKeysByItemInList()
			return This.NumberOfKeysByItemInList()

		def HowManyKeyByItemInList()
			return This.NumberOfKeysByItemInList()

	def FindFirstKeyByItemInList(pValue)

		if This.ContainsItemInList(pValue)
			return This.FindKeysByItemInList(pValue)[1]
		else
			return 0
		ok

	def FindKeyByItemInList(pValue)
		return This.FindFirstKeyByItemInList(pValue)

	def FindLastKeyByItemInList(pValue)
		n = This.NumberOfKeysByItemInList()

		if This.ContainsItemInList(pValue)
			return This.FindKeysByItemInList(pValue)[n]
		else
			return 0
		ok


	def KeyByItemInList(pValue)
		n = This.FindKeyByItemInList(pValue)

		return This.Key( n )

	def KeysByItemInList(pValue)
		anPos = This.FindKeysByItemInList()
		aResult = []

		for n in anPos
			aResult + This.Key(n)
		next

		return aResult

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

	  #---------------------------#
	 #     CLASSIFYING VALUES    #
	#---------------------------#

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

		#< @FunctionAlternativeNames

		def Categories()
			return This.Classes()

			def CategoriesQ()
				return This.CategoriesQR(:stzList)

			def CategoriesQR(pcReturnType)
				if isList(pcReturnType) and StzListQ(pcReturnType).IsOneOfTheseNamedParams([ :ReturnedAs, :ReturnAs ])
					pcReturnType = pcReturnType[2]
				ok
	
				switch pcReturnType
				on :stzList
					return new stzList( This.Categories() )
	
				on :stzListOfStrings
					return new stzListOfStrings( This.Categories() )
	
				other
					StzRaise("Unsupported return type!")
				off
	
		#>

	def NumberOfClasses()
		return len( This.CLasses() )

		def NumberOfCategories()
			return This.NumberOfClasses()

		def HowManyClasses()
			return This.NumberOfClasses()

		def HowManyClasse()
			return This.NumberOfClasses()

		def HowMayCategories()
			return This.NumberOfClasses()

		def HowManyCategory()
			return This.NumberOfClasses()

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

		def CategoriseQ()
			return This.CategoriseQR(pcReturnType)

		def CategoriseQR(pcReturnType)
			if isList(pcReturnType) and StzListQ(pcReturnType).IsOneOfTheseNamedParams([ :ReturnedAs, :ReturnAs ])
				pcReturnType = pcReturnType[2]
			ok
	
			switch pcReturnType
			on :stzList
				return new stzList( This.Categorise() )

			on :stzHashList
				return new stzHashList( This.Categorise() )
	
			other
				StzRaise("Unsupported return type!")
			off

		def CategorizeQ()
			return This.CategorizeQR(pcReturnType)

		def CategorizeQR(pcReturnType)
			if isList(pcReturnType) and StzListQ(pcReturnType).IsOneOfTheseNamedParams([ :ReturnedAs, :ReturnAs ])
				pcReturnType = pcReturnType[2]
			ok
	
			switch pcReturnType
			on :stzList
				return new stzList( This.Categorize() )

			on :stzHashList
				return new stzHashList( This.Categorize() )
	
			other
				StzRaise("Unsupported return type!")
			off
						
		#>

	def Klass(pcClass)
		aResult = This.KeysForValue(pcClass)
		return aResult

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

		def Category(pcClass)
			return This.Klass(pcClass)

	  #---------------------------------------#
	 #     CLASSIFYING VALUES INSIDE LISTS   #
	#---------------------------------------#

	def ClassesInList()
		acResult = []
		aUniqueValues = This.UniqueValuesInList()
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

		#< @FunctionAlternativeNames

		def CategoriesInList()
			return This.ClassesInList()

			def CategoriesInListQ()
				return This.CategoriesInListQR(:stzList)

			def CategoriesInListQR(pcReturnType)
				if isList(pcReturnType) and StzListQ(pcReturnType).IsOneOfTheseNamedParams([ :ReturnedAs, :ReturnAs ])
					pcReturnType = pcReturnType[2]
				ok
	
				switch pcReturnType
				on :stzList
					return new stzList( This.CategoriesInList() )
	
				on :stzListOfStrings
					return new stzListOfStrings( This.CategoriesInList() )
	
				other
					StzRaise("Unsupported return type!")
				off
	
		#>

	def NumberOfClassesInList()
		return len( This.CLassesInList() )

		def NumberOfCategoriesInList()
			return This.NumberOfClassesInList()

		def HowManyClassesInList()
			return This.NumberOfClassesInList()

		def HowManyClassInList()
			return This.NumberOfClassesInList()

	def ClassifyInList()

		aResult = []
		aClasses = This.ClassesInList()

		for cClass in aClasses
			aResult + [ cClass, This.KeysForValue(value) ]
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

		def CategoriseInListQ()
			return This.CategoriseInListQR(pcReturnType)

		def CategoriseInListQR(pcReturnType)
			if isList(pcReturnType) and StzListQ(pcReturnType).IsOneOfTheseNamedParams([ :ReturnedAs, :ReturnAs ])
				pcReturnType = pcReturnType[2]
			ok
	
			switch pcReturnType
			on :stzList
				return new stzList( This.CategoriseInList() )

			on :stzHashList
				return new stzHashList( This.CategoriseInList() )
	
			other
				StzRaise("Unsupported return type!")
			off

		def CategorizeInListQ()
			return This.CategorizeInListQR(pcReturnType)

		def CategorizeInListQR(pcReturnType)
			if isList(pcReturnType) and StzListQ(pcReturnType).IsOneOfTheseNamedParams([ :ReturnedAs, :ReturnAs ])
				pcReturnType = pcReturnType[2]
			ok
	
			switch pcReturnType
			on :stzList
				return new stzList( This.CategorizeInList() )

			on :stzHashList
				return new stzHashList( This.CategorizeInList() )
	
			other
				StzRaise("Unsupported return type!")
			off
						
		#>

	def KlassInList(pcClass)
		aResult = This.KeysForItemInList(pcClass)
		return aResult

		def KlassInListQR(pcClass, pcReturnType)
			if isList(pcReturnType) and StzListQ(pcReturnType).IsOneOfTheseNamedParams([ :ReturnedAs, :ReturnAs ])
				pcReturnType = pcReturnType[2]
			ok

			switch pcReturnType
			on :stzString	
				return new stzString( This.KlassInList() )

			on :stzText
				return new stzText( This.KlassInList() )

			other
				StzRaise("Unsupported return type!")
			off

		def CategoryInList(pcClass)
			return This.KlassInList(pcClass)

	  #---------------#
	 #     QUERY     #
	#---------------#

	// TODO: FindWhere(cCondition) --> See how this was made in stzList

	  #--------------#
	 #     SHOW     #
	#--------------#

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
