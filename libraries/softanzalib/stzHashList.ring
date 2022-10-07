# 		    SOFTANZA LIBRARY (V1.0) - STZSTRING			    #
#		An accelerative library for Ring applications		    #
#---------------------------------------------------------------------------#
#									    #
# 	Description	: The core class for managing hash lists            #
#	Version		: V1.0 (2020-2022)				    #
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

func ListIsPairAndKeyIsString(paPair)
	if isList(paPair) and Q(paPair).IsPairAndKeyIsString()
		return TRUE
	else
		return FALSE
	ok

class stzHashList from stzObject # Also called stzAssociativeList
	// Key-valye list where key is string
	@aContent = []

	  #--------------#
	 #     INIT     #
	#--------------#

	def init(p)

		switch type(p)
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
				for aItem in p
					aItem[1] = StzStringQ(aItem[1]).Lowercased()
				next

				@aContent = p

			else
				stzRaise("The list you provided is not a hash list!")
			ok

		other
			stzRaise("Unsupported form of the input of the hashlist!")
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

	def Pairs()
		return Content()

		def PairsQ()
			return This.PairsQR(:stzList)

		def PairsQR(pcReturnType)
			if isList(pcReturnType) and Q(pcReturnType).IsReturnedAsNamedParam()
				pcReturnType = pcReturnType[2]
			ok

			if NOT isString(pcReturnType)
				stzRaise("Incorrect param! pcReturnType must be a string.")
			ok

			switch pcReturnType

			on :stzList
				return new stzList( This.Pairs() )

			on :stzListOfPairs
				return new stzListOfPairs( This.Keys() )

			other
				stzRaise("Unsupported return type!")
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
			if isList(pcReturnType) and Q(pcReturnType).IsReturnedAsNamedParam()
				pcReturnType = pcReturnType[2]
			ok

			if NOT isString(pcReturnType)
				stzRaise("Incorrect param! pcReturnType must be a string.")
			ok

			switch pcReturnType

			on :stzList
				return new stzList( This.Keys() )

			on :stzListOfStrings
				return new stzListOfStrings( This.Keys() )

			other
				stzRaise("Unsupported return type!")
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
			if isList(pcReturnType) and Q(pcReturnType).IsReturnedAsNamedParam()
				pcReturnType = pcReturnType[2]
			ok

			if NOT isString(pcReturnType)
				stzRaise("Incorrect param! pcReturnType must be a string.")
			ok

			switch pcReturnType

			on :stzList
				return new stzList( This.KeysForValue() )

			on :stzListOfStrings
				return new stzListOfStrings( This.KeysForValue() )

			other
				stzRaise("Unsupported return type!")
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
			if isList(pcReturnType) and StzListQ(pcReturnType).IsReturnedAsNamedParam()
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

			//on :stzListOfObjects # TODO
				//return new stzListOfObjects( This.Values() )
			other
				stzRaise("Unsupported return type!")
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
				stzRaise("Can't update a key with the value of an existant key!")

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
			stzRaise("Incorrect param type! n should be a number.")
		ok

		if n > 0
			return This.Content()[n][1]
		ok

		def NthKeyQ(n)
			return new stzNumber(This.NthKey())

	def Key(n)
		return This.NthKey(n)

	def KeyQ(n)
		return new stzNumber(This.Key(n))

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
		return new stzNumber(This.NthValueQ())

	def Value(n)
		if NOT isNumber(n)
			stzRaise("Incorrect param type! n should be a number.")
		ok

		return This.NthValue(n)

	def ValueQ(n)
		return new stzNumber(This.Value(n))

	def NthPair(n)
		if isString(n)
			if n = :First or n = :FirstPair
				n = 1

			but n = :Last or n = :LastPair
				n = This.NumberOfPairs()
			ok
		ok

		if NOT isNumber(n)
			stzRaise("Incorrect param type! n should be a number.")
		ok

		return This.Content()[n]

	def NthPairQ(n)
		return new stzNumber(This.NthPair(n))

	def PairAt(n)
		return This.NthPair(n)

	def PairQ(n)
		return new stzNumber(This.PairAt(n))

	def KeyInPair(paPair)
		if isList(paPair) and ListIsPairAndKeyIsString(paPair) and
		   This.ContainsPair(paPair)
			return paPair[1]

		else
			stzRaise("Invalid param type!")
		ok

	def KeyInPairQ(paPair)
		return new stzString( This.KeyInPair(paPair) )

	def ValueInPair(paPair)
		if isList(paPair) and ListIsPairAndKeyIsString(paPair) and
	           This.ContainsPair(paPair)
			return paPair[2]
		else
			stzRaise("Invalide param type!")
		ok

	def ValueInPairQ(paPair)
		switch type( This.ValueInPair(paPair) )
		on 'NUMBER'
			return new stzNumber(This.ValueInPair(paPair))

		on 'STRING'
			return new stzString(""+ This.ValueInPair(paPair))

		on 'LIST'
			return new stzList( This.ValueInPair(paPair))

		on 'OBJECT'
			return new stzObject( This.ValueInPair(paPair) )

		off

	def KeyInNthPair(n)
		return This.NthPair(n)[1]

	def KeyInNthPairQ(n)
		return new stzString( This.KeyInNthPair(n) )

	def ValueInInNthPair(n)
		return This.NthPair(n)[2]

	def ValueInNthPairQ(n)
		switch type(This.ValueInNthPairQ(n))
		on 'NUMBER'
			return new stzNumber(This.ValueInNthPairQ(n))

		on 'STRING'
			return new stzString(''+ This.ValueInNthPairQ(n))

		on 'LIST'
			return new stzList( This.ValueInNthPairQ(n))

		on 'OBJECT'
			return new stzObject( This.ValueInNthPairQ(n))

		off

	def ValueByKey(pcKey)
		return This.Content()[ pcKey ]
	
	def NumberOfOccurrenceOfValue(pValue)
		return len(This.FindValue(pValue))

		def NumberOfOccurrencesOfValue(pValue)
			return NumberOfOccurrenceOfValue(pValue)

	def NumberOfOccurrenceOfValueQ(pValue)
		return new stzNumber(This.NumberOfOccurrenceOfValue(pValue))

		def NumberOfOccurrencesOfValueQ(pValue)
			return NumberOfOccurrenceOfValueQ(pValue)

	def UniqueValues()
		aResult = This.ValuesQ().DuplicatesRemoved()
		return aResult

	def ValuesAtPositions(anPositions)
		aResult = This.ValuesQ().ItemsAtPositions(anPositions)
		return aResult
	  #------------------#
	 #     UPDATING     #
	#------------------#

	def Update( paNewHashList )
		if isList(paNewHashList) and
		   ( StzListQ(paNewHashList).IsWithNamedParam() or StzListQ(paNewHashList).IsUsingNamedParam() )

			paNewHashList = paNewHashList[2]

		ok

		if isList(paNewHashList) and StzListQ(paNewHashList).IsHashList()
			@aContent = paNewHashList
		ok

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
			stzRaise("Key must be a string!")
		ok

	def UpdateNthPairQ(n, paNewPair)
		This.UpdateNthPair(n, paNewPair)
		return This

	def UpdatePair(paPair, paNewPair)
		if isList(paPair) and ListIsPairAndKeyIsString(paNewPair) and
		   This.ContainsPair(paPair)
			n = This.FindPair(paPair)

			This.UpdateNthKey(n, paNewPair[1])
			This.UpdateNthValue(n, paNewPair[2])
		else
			stzRaise("Key must be a string!")
		ok

	def UpdatePairQ(paPair, paNewPair)
		This.UpdatePair(paPair, paNewPair)
		return This

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

	def UpdateNthKeyQ(n, pcValue)
		This.UpdateNthKey(n, pcValue)
		return This

	def UpdateKey(pcKey, pcNewKey)
		if isString(pcKey) and This.ContainsKey(pcKey)
			n = This.FindKey(pcKey)
			@aContent[n][1] = pcNewKey
		ok

	def UpdateKeyQ(pcKey, pcNewKey)
		This.UpdateKey(pcKey, pcNewKey)
		return This

	def UpdateKeys(paKeys)
		oStzList = new stzList(paKeys)
		if oStzList.ItemsAreAllStrings()
			for i = 1 to Min( len(paKeys), This.NumberOfPairs() )
				This.UpdateNthKey(i, paKeys[i])
			next i
		ok

	def UpdateKeysQ(paKeys)
		This.UpdateKeys(paKeys)
		return This

	def UpdateNthValue(n, pValue)

		if n = :First
			n = 1
		but n = :Last
			n = This.NumberOfValues()
		ok


		@aContent[n][2] = pValue

	def UpdateNthValueQ(n, pValue)
		This.UpdateNthValue(n, pValue)
		return This

	def UpdateNthOccurrenceOfValue(pValue)
		This.UpdateNthValue( This.FindNthOccurrenceOfValue(pValue) )

	def UpdateValues(paValues)
		for i = 1 to Min( len(paValues), This.NumberOfPairs() )
			This.UpdateNthValue(i, paValues[i])
		next

	def UpdateValuesQ(paValues)
		This.UpdateValues(paValues)
		return This

	def UpdateValue(pValue, pNewValue)
		aTemp = This.FindValue(pValue)
		for n in aTemp
			This.UpdateNthValue(n, pNewValue)
		next

	def UpdateValueQ(pValue, pNewValue)
		This.UpdateValue(pValue, pNewValue)
		return This

	def UpdateFirstOccurrenceOfValue(pValue, pNewValue)
		return This.UpdateNthOccurrenceOfValue(1, pValue, pNewValue)

	def UpdateFirstValueQ(pValue, pNewValue)
		return This.UpdateFirstValue(pValue, pNewValue)

	def UpdateLastValue(pValue, pNewValue)
		n = NumberOfOccurrenceOfValue(pValue)
		return UpdateNthValue(n, pValue, pNewValue)

	def UpdateLastValueQ(pValue, pNewValue)
		This.UpdateLastValue(pValue, pNewValue)
		return This

	def UpdateAllPairsWith(paPair)
		if isList(paPair) and ListIsPairAndKeyIsString(paPair)
			for aPair in This.Content()
				aPair = paPair
			next
		else
			stzRaise("Syntax error! The value you provided is not a string key pair.")
		ok

	def UpdateAllPairsWithQ(paPair)
		This.UpdateAllPairsWithQ(paPair)
		return This

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
		if isList(paNewPair) and ListIsPairAndKeyIsString(paNewPair)

			@aContent + paNewPair
		else
			stzRaise("Syntax error! The value you provided is not a pair with its key beeing a string.")
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
		aPos = This.FindAllValue(pValue)

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
		This.ReplaceNthKey(:Last, pcNewKey)

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

	  #-----------------#
	 #     FINDING     #
	#-----------------#

	def FindKey(pcKey)
		if isString(pcKey)
			return find( Keys(), pcKey)
		ok

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
			stzRaise("Can't search the list." + NL + "Because paPair is not a pair!")
		ok

	def ContainsPair(paPair)
		if FindPair(paPair) > 0
			return TRUE
		else
			return FALSE
		ok

	  #---------------------#
	 #    FINDING VALUE    #
	#---------------------#

	def ContainsValue(pValue)
		if len( This.FindValue(pValue) ) > 0
			return TRUE
		else
			return FALSE
		ok

	def FindValue(pValue)
		aResult = ValuesQ().FindAll(pValue)
		return aResult

		#< @FunctionAlternativeForms

		def FindAllOccurrencesOfValue(pValue)
			return This.FindValue(pValue)

		#>

	def FindNthOccurrenceOfValue(n, pValue)

		if n = :First
			n = 1
		but n = :Last
			n = This.NumberOfOccurreceOfValue(pValue)
		ok

		return This.FindValue(pValue)[n]

	def FindFirstOccurrenceOfValue(pValue) 
		return This.FindNthValue(1, pValue)

	def FindLastOccurrenceOfValue(pValue)
		return This.FindNthOccurrenceOfValue(:Last, pValue)

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

	def FindFirstKeyByValue(pValue)
		nResult = 0
		if This.ContainsValue(pValue)
			nResult = This.FindKeysByValue(pValue)[1]
		ok
		return nResult

	def FindKeyByValue(pValue)
		return This.FindFirstKeyByValue(pValue)

	def FindLastKeyByValue(pValue)
		cResult = ""
		for i = This.NumberOfPairs() to 1 step -1
			if Q(This.Value(i)).IsEqualTo(pValue)
				cResult = This.Key(i)
				exit
			ok
		next i
		return cResult

	def KeyByValue(pValue)
		n = This.FindKeyByValue(pValue)
		return This.Key( n )

	def KeysByValue(pValue)
		anPos = This.FindKeysByValue()
		aResult = []

		for n in anPos
			aResult + This.KeyByValue(n)
		next

		return aResult

	  #----------------------------------#
	 #   FINDING VALUE HOSTED IN LIST   #
	#----------------------------------#
	/* EXAMPLE

	o1 = new stzHashList([
		:Positive	= [ :happy, :nice, :glad, :can, :beatiful, :wanderful ],
		:Neutral  	= [ :is, :will, :can, :some ],
		:Negative	= [ :no, :not, :must, :difficult, :problem ]
	])

	? o1.FindValueInList(:nice) #--> [ 1 ]
	? o1.FindValueInList(:can)  #--> [ 1, 2 ]
	*/

	def ContainsValueInList(pValue)
		if len( This.FindValueInList(pValue) ) > 0
			return TRUE
		else
			return FALSE
		ok

	def FindValueInList(pValue)

		aResult = []
		n = 0
		for aPair in This.Content()
			n++
			if isList(aPair[2])

				oStzList = new stzList(aPair[2])
				if oStzList.Contains(pValue)
					aResult + n
				ok
			ok

		next
		return aResult

		#< @FunctionAlternativeForms

		def FindAllOccurrencesOfValueInList(pValue)
			return This.FindValueInList(pValue)

		#>

	def FindNthOccurrenceOfValueInList(n, pValue)

		if n = :First
			n = 1
		but n = :Last
			n = This.NumberOfOccurreceOfValueInList(pValue)
		ok


		return This.FindValueInList(pValue)[n]

	def FindFirstOccurrenceOfValueInList(pValue) 
		return This.FindNthValueInList(1, pValue)

	def FindLastOccurrenceOfValueInList(pValue)
		return This.FindNthOccurrenceOfValueInList(:Last, pValue)

	def FindKeysByValueInList(pValue)
		anPos = This.FindValueInList(pValue)
		anResult = []
		for n in anPos
			anResult + n
		next
		return anResult

	def NumberOfKeysByValueInList() ###
		return len( This.FindKeysByValueInList(pValue) )

	def FindFirstKeyByValueInList(pValue)

		if This.ContainsValueInList(pValue)
			return This.FindKeysByValueInList(pValue)[1]
		else
			return 0
		ok

	def FindKeyByValueInList(pValue)
		return This.FindFirstKeyByValueInList(pValue)

	def FindLastKeyByValueInlist(pValue)
		n = This.NumberOfKeysByValueInList()

		if This.ContainsValueInList(pValue)
			return This.FindKeysByValueInList(pValue)[n]
		else
			return 0
		ok


	def KeyByValueInList(pValue)
		n = This.FindKeyByValueInList(pValue)

		return This.Key( n )

	def KeysByValueInList(pValue)
		anPos = This.FindKeysByValueInList()
		aResult = []

		for n in anPos
			aResult + This.Key(n)
		next

		return aResult

	  #---------------------------#
	 #     CLASSIFYING VALUES    #
	#---------------------------#

	def Classes()
		acResult = []

		for value in This.UniqueValues()
			acResult + Q(value).Stringified()
		next

		return acResult

		#< @FunctionFluentForm

		def ClassesQ()
			return This.ClassesQR(:stzList)

		def ClassesQR(pcReturnType)
			if isList(pcReturnType) and StzListQ(pcReturnType).IsReturnedAsNamedParam()
				pcReturnType = pcReturnType[2]
			ok

			switch pcReturnType
			on :stzList
				return new stzList( This.Classes() )

			on :stzListOfStrings
				return new stzListOfStrings( This.Classes() )

			other
				stzRaise("Unsupported return type!")
			off
		#>

		#< @FunctionAlternativeNames

		def Categories()
			return This.Classes()

			def CategoriesQ()
				return This.CategoriesQR(:stzList)

			def CategoriesQR(pcReturnType)
				if isList(pcReturnType) and StzListQ(pcReturnType).IsReturnedAsNamedParam()
					pcReturnType = pcReturnType[2]
				ok
	
				switch pcReturnType
				on :stzList
					return new stzList( This.Categories() )
	
				on :stzListOfStrings
					return new stzListOfStrings( This.Categories() )
	
				other
					stzRaise("Unsupported return type!")
				off
	
		#>

	def NumberOfClasses()
		return len( This.CLasses() )

		def NumberOfCategories()
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
			if isList(pcReturnType) and StzListQ(pcReturnType).IsReturnedAsNamedParam()
				pcReturnType = pcReturnType[2]
			ok
	
			switch pcReturnType
			on :stzList
				return new stzList( This.Classify() )

			on :stzHashList
				return new stzHashList( This.Classify() )
	
			other
				stzRaise("Unsupported return type!")
			off						
		#>

		#< @FunctionAlternativeForms

		def CategoriseQ()
			return This.CategoriseQR(pcReturnType)

		def CategoriseQR(pcReturnType)
			if isList(pcReturnType) and StzListQ(pcReturnType).IsReturnedAsNamedParam()
				pcReturnType = pcReturnType[2]
			ok
	
			switch pcReturnType
			on :stzList
				return new stzList( This.Categorise() )

			on :stzHashList
				return new stzHashList( This.Categorise() )
	
			other
				stzRaise("Unsupported return type!")
			off

		def CategorizeQ()
			return This.CategorizeQR(pcReturnType)

		def CategorizeQR(pcReturnType)
			if isList(pcReturnType) and StzListQ(pcReturnType).IsReturnedAsNamedParam()
				pcReturnType = pcReturnType[2]
			ok
	
			switch pcReturnType
			on :stzList
				return new stzList( This.Categorize() )

			on :stzHashList
				return new stzHashList( This.Categorize() )
	
			other
				stzRaise("Unsupported return type!")
			off
						
		#>

	def Klass(pcClass)
		aResult = This.KeysForValue(pcClass)
		return aResult

		def KlassQR(pcClass, pcReturnType)
			if isList(pcReturnType) and StzListQ(pcReturnType).IsReturnedAsNamedParam()
				pcReturnType = pcReturnType[2]
			ok

			switch pcReturnType
			on :stzString	
				return new stzString( This.Klass() )

			on :stzText
				return new stzText( This.Klass() )

			other
				stzRaise("Unsupported return type!")
			off

		def Category(pcClass)
			return This.Klass(pcClass)

	  #---------------------------------------#
	 #     CLASSIFYING VALUES INSIDE LISTS   #
	#---------------------------------------#

	def ClassesInList()
		acResult = []

		for value in This.UniqueValuesInList()
			acResult + Q(value).Stringified()
		next

		return acResult

		#< @FunctionFluentForm

		def ClassesInListQ()
			return This.ClassesInListsQR(:stzList)

		def ClassesInListQR(pcReturnType)
			if isList(pcReturnType) and StzListQ(pcReturnType).IsReturnedAsNamedParam()
				pcReturnType = pcReturnType[2]
			ok

			switch pcReturnType
			on :stzList
				return new stzList( This.ClassesInList() )

			on :stzListOfStrings
				return new stzListOfStrings( This.ClassesInList() )

			other
				stzRaise("Unsupported return type!")
			off
		#>

		#< @FunctionAlternativeNames

		def CategoriesInList()
			return This.ClassesInList()

			def CategoriesInListQ()
				return This.CategoriesInListQR(:stzList)

			def CategoriesInListQR(pcReturnType)
				if isList(pcReturnType) and StzListQ(pcReturnType).IsReturnedAsNamedParam()
					pcReturnType = pcReturnType[2]
				ok
	
				switch pcReturnType
				on :stzList
					return new stzList( This.CategoriesInList() )
	
				on :stzListOfStrings
					return new stzListOfStrings( This.CategoriesInList() )
	
				other
					stzRaise("Unsupported return type!")
				off
	
		#>

	def NumberOfClassesInList()
		return len( This.CLassesInList() )

		def NumberOfCategoriesInList()
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
			if isList(pcReturnType) and StzListQ(pcReturnType).IsReturnedAsNamedParam()
				pcReturnType = pcReturnType[2]
			ok
	
			switch pcReturnType
			on :stzList
				return new stzList( This.ClassifyInList() )

			on :stzHashList
				return new stzHashList( This.ClassifyInList() )
	
			other
				stzRaise("Unsupported return type!")
			off						
		#>

		#< @FunctionAlternativeForms

		def CategoriseInListQ()
			return This.CategoriseInListQR(pcReturnType)

		def CategoriseInListQR(pcReturnType)
			if isList(pcReturnType) and StzListQ(pcReturnType).IsReturnedAsNamedParam()
				pcReturnType = pcReturnType[2]
			ok
	
			switch pcReturnType
			on :stzList
				return new stzList( This.CategoriseInList() )

			on :stzHashList
				return new stzHashList( This.CategoriseInList() )
	
			other
				stzRaise("Unsupported return type!")
			off

		def CategorizeInListQ()
			return This.CategorizeInListQR(pcReturnType)

		def CategorizeInListQR(pcReturnType)
			if isList(pcReturnType) and StzListQ(pcReturnType).IsReturnedAsNamedParam()
				pcReturnType = pcReturnType[2]
			ok
	
			switch pcReturnType
			on :stzList
				return new stzList( This.CategorizeInList() )

			on :stzHashList
				return new stzHashList( This.CategorizeInList() )
	
			other
				stzRaise("Unsupported return type!")
			off
						
		#>

	def KlassInList(pcClass)
		aResult = This.KeysForValueInList(pcClass)
		return aResult

		def KlassInListQR(pcClass, pcReturnType)
			if isList(pcReturnType) and StzListQ(pcReturnType).IsReturnedAsNamedParam()
				pcReturnType = pcReturnType[2]
			ok

			switch pcReturnType
			on :stzString	
				return new stzString( This.KlassInList() )

			on :stzText
				return new stzText( This.KlassInList() )

			other
				stzRaise("Unsupported return type!")
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
			cStr += "'" + This.NthKey(i) + "'" + ": " + @@S(This.NthValue(i))
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

	def IsHashList() # required by stzChainOfTruth
		return TRUE

	  #-----------------------------#
	 #     Operator overloading    #
	#-----------------------------#

	def operator(pOp,pValue)

		if pOp = "[]"
			
			if type(pValue) = "STRING"
				return This.ValueByKey(pValue)
			ok
		ok
