
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

	def Pairs()
		return Content()

	def PairsList()
		return This.Pairs()

	def PairsQ()
		return new stzList( This.Pairs() )

	def PairsListQ()
		return This.PairsQ()

	def Keys()
		aResult = []
		for i = 1 to This.NumberOfPairs()
			aResult + This.Content()[i][1]
		next
		return aResult

	def KeysQ()
		return new stzList( This.Keys() )

	def KeysList()
		return This.Keys()

	def KeysListQ()
		return This.KeysQ()

	def KeysForValue(pValue)
		aResult = []

		for aPair in This.HashList()
			if Q(aPair[2]).IsStrictlyEqualTo(pValue)
				aResult + aPair[1]
			ok
		next

		return aResult
			
	def Values()
		aResult = []
		for i = 1 to This.NumberOfPairs()
			aResult + This.Content()[i][2]
		next
		return aResult

		def ValuesQ()
			return This.ValuesQR(:stzList)

		def ValuesQR(pcReturnType)
			if isList(pcReturnType) and StzListQ(pcReturnType).IsReturnedAsParamList()
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

	def NthKey(n)
		if NOT isNumber(n)
			stzRaise("Incorrect param type! n should be a number.")
		ok

		return This.Content()[n][1]

	def NthKeyQ(n)
		return new stzNumber(This.NthKey())

	def Key(n)
		return This.NthKey(n)

	def KeyQ(n)
		return new stzNumber(This.Key(n))

	def NthValue(n)
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
		if NOT isNumber(n)
			stzRaise("Incorrect param type! n should be a number.")
		ok

		return This.Content()[n]

	def NthPairQ(n)
		return new stzNumber(This.NthPair(n))

	def Pair(n)
		return This.NthPair(n)

	def PairQ(n)
		return new stzNumber(This.Pair(n))

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

	  #----------------#
	 #     UPDATE     #
	#----------------#

	def Update( paNewHashList )
		if isList(paNewHashList) and
		   ( StzListQ(paNewHashList).IsWithParamList() or StzListQ(paNewHashList).IsUsingParamList() )

			paNewHashList = paNewHashList[2]

		ok

		if isList(paNewHashList) and StzListQ(paNewHashList).IsHashList()
			@aContent = paNewHashList
		ok

	def UpdateNthPair(n, paNewPair)
		/*
		Let's be permissive: if the user misses the correct order of parmas
		( --> enters the string before the number ) then fix it silently

		*/

		if isList(n) and isNumber(paNewPair)
			temp = n
			n = paNewPair
			paNewPair = temp
		ok

		# Also, let's facilitate the syntax a bit further

		if n = :First
			n = 1
		but n = :Last
			n = This.NumberOfPairs()
		ok

		# Now, let's do the job

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
		/*
		Let's be permissive: if the user misses the correct order of parmas
		( --> enters the string before the number ) then fix it silently

		*/

		if isList(n) and isNumber(pcValue)
			temp = n
			n = pcValue
			pcValue = temp
		ok

		# Also, let's facilitate the syntax a bit further

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
		/*
		Let's be permissive: if the user misses the correct order of parmas
		( --> enters the string before the number ) then fix it silently

		*/

		if isNumber(pValue) and (NOT isNumber(n))
			temp = n
			n = pValue
			pcValue = temp
		ok

		# Also, let's facilitate the syntax a bit further

		if n = :First
			n = 1
		but n = :Last
			n = This.NumberOfValues()
		ok

		# Now, let's do the job

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
	def RemoveAllPairsWithValue(pValue)
		aPos = This.FindAllValue(pValue)

		aResult = StzListQ( This.HashList() ).RemoveItemsAtThesePositionsQ( aPos ).Content()
		This.Update(aResult)

		def RemoveAllPairsWithValueQ(pValue)
			This.RemoveAllPairsWithValue(pValue)
			return This
	
	  #-----------------#
	 #     FINDING     #
	#-----------------#

	def FindKey(pcKey)
		if isString(pcKey)
			return find( Keys(), pcKey)
		ok

	def ContainsKey(pcKey)
		if isString(pcKey) and This.FindKey(pcKey) > 0
			return TRUE
		else
			return FALSE
		ok

	def ContainsKeys(paKeys)
		oKeys = new stzList(paKeys)
		if oKeys.IsListOfStrings() and
		   oKeys.IsEqualTo(This.Keys())

			return TRUE
		else
			return FALSe
		ok

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

	def ContainsValue(pValue)
		if len( This.FindValue(pValue) ) > 0
			return TRUE
		else
			return FALSE
		ok

	def FindValue(pValue)

		aResult = []
		n = 0
		for aPair in This.Content()
			n++
			if IsNumberOrString(pValue)
				if ValueInPair(aPair) = pValue
					aResult + n
				ok

			but isList(pValue)

			oStzList = new stzList(aPair)
				if oStzList.IsStrictlyEqualTo(pValue)
					aResult + n
				ok

			but isObject(pvalue)
				// TODO
				stzRaise("Uncovered case!")
			ok
		next
		return aResult

		#< @FunctionAlternativeForms

		def FindAllOccurrencesOfValue(pValue)
			return This.FindValue(pValue)

		def FindAllValue(pValue)
			return This.FindValue(pValue)

		#>

	def FindNthOccurrenceOfValue(n, pValue)
		/*
		Let's be permissive: if the user misses the correct order of parmas
		( --> enters the string before the number ) then fix it silently
		*/

		if isNumber(pValue) and (NOT isNumber(n))
			temp = n
			n = pValue
			pValue = temp
		ok

		# Also, let's facilitate the syntax a bit further

		if n = :First
			n = 1
		but n = :Last
			n = This.NumberOfOccurreceOfValue(pValue)
		ok

		# Now, let's do the job

		return This.FindValue(pValue)[n]

	def FindFirstOccurrenceOfValue(pValue) 
		return This.FindNthValue(1, pValue)

	def FindLastOccurrenceOfValue(pValue)
		return This.FindNthOccurrenceOfValue(:Last, pValue)

	def FindKeysByValue(pValue)
		aResult = []
		for v in This.Values()
			if v = pValue
				aResult + v
			ok
		next
		return aResult

	def FindFirstKeyByValue(pValue)
		cResult = ""
		for i = 1 to This.NumberOfPairs()
			if Q(This.Value(i)).IsEqualTo(pValue)
				cResult = This.Key(i)
				exit
			ok
		next i
		return cResult

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

	  #---------------------#
	 #     CLASSIFYING     #
	#---------------------#

	def UniqueValues()
		aResult = This.ValuesQ().DuplicatesRemoved()
		return aResult

	def ValuesAtPositions(anPositions)
		aResult = This.ValuesQ().ItemsAtPositions(anPositions)
		return aResult

	def Classify()
		aResult = []
		aValues = This.UniqueValues()

		for value in aValues
			aResult + [ value, This.KeysForValue(value) ]
		next

		return aResult

	def Klass(pcClass)
		aResult = This.KeysForValue(pcClass)
		return aResult

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
			cStr += This.NthKey(i) + ": " + ComputableForm(This.NthValue(i))
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
