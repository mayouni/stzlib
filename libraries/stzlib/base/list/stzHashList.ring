#-----------------------------------------------------------#
# 		    SOFTANZA LIBRARY (V0.9) - STZHASHLIST		    #
#		An accelerative library for Ring applications		#
#-----------------------------------------------------------#
#                                                           #
# 	Description	: The class for managing hash lists         #
#	Version		: V0.9 (2020-2024)				            #
#	Author		: Mansour Ayouni (kalidianow@gmail.com)	    #
#                                                           #
#-----------------------------------------------------------#

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
	if CheckingParams()
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

func IsHashList(paList)
 	if NOT isList(paList)
		return FALSE
	ok

	oTempList = new stzList(paList)
	return oTempList.IsHashList()

	#< @FunctionAlternativeForms

	func @IsHashList(paList)
		return IsHashList(paList)

	func IsAHashList(paList)
		return IsHashList(paList)

	func @IsAHashList(paList)
		return IsHashList(paList)

	func IsHash(paList)
		return IsHashList(paList)

	func @IsHash(paList)
		return IsHashList(paList)

	func IsAHash(paList)
		return IsHashList(paList)

	func @IsAHash(paList)
		return IsHashList(paList)

	#>

func Keys(paList)
	if NOT (isList(paList) and IsHashList(paList))
		StzRaise("Incorrect param type! paList must be a hashlist.")
	ok

	acResult = []
	nLen = len(paList)

	for i = 1 to nLen
		acResult + paList[i][1]
	next

	return acResult

	func @Keys(paList)
		return Keys(paList)


func HasPath(paList, pacKeys) #TODO // Generalise it to work on any list not only hashlists
			      #TODO // Move it to stzList.ring file
	if CheckParams()

		if NOT isList(paList)
			StzRaise("Incorrect param type! paList must be a list.")
		ok

		if not (isList(pacKeys) and IsListOfStrings(pacKeys))
			StzRaise("Incorrect param type! pacKeys must be a list of strings.")
		ok

	ok

	if not IsHashList(paList)
		return FALSE
	ok

	# Start with the top-level hash
	aCurrent = paList
	nLen = len(pacKeys)
	
	for i = 1 to nLen
		cKey = pacKeys[i]
		
		# Check if current level is a hash
		if not IsHashList(aCurrent)
			return FALSE
		ok
		
		# Build lowercase keys list for current level
		nCurrentLen = len(aCurrent)
		acCurrentKeys = []
		
		for j = 1 to nCurrentLen
			acCurrentKeys + lower(aCurrent[j][1])
		next
		
		# Find the key in current level
		nPos = ring_find(acCurrentKeys, lower(cKey))
		
		if nPos = 0
			return FALSE
		ok
		
		# Move to the next level (the value of the found key)
		# Only do this if we're not at the last key
		if i < nLen
			aCurrent = aCurrent[nPos][2]
		ok
	next

	return TRUE


func HasKey(paList, pcKey)
	if isList(pcKey)
		return HasKeys(paList, pcKey)
	ok

	if CheckParams()
		if NOT isString(pcKey)
			StzRaise("Incorrect param type! pcKey must be a string.")
		ok

		if NOT isList(paList)
			StzRaise("Incorrect param type! paList must be a list.")
		ok
	ok

	if not IsHashList(paList)
		return FALSE
	ok

	nLen = len(paList)
	acKeys = []

	for i = 1 to nLen
		acKeys + lower(paList[i][1])
	next

	return iff(ring_find(acKeys, lower(pcKey)) > 0, TRUE, FALSE)

	func @HasKey(paList, pcKey)
		return HasKey(paList, pcKey)

	def ContainsKey(paList, pcKey)
		return HasKey(paList, pcKey)

	def @ContainsKey(paList, pcKey)
		return HasKey(paList, pcKey)

func HasKeys(paList, pacKeys)
	if CheckParams()
		if NOT (isList(pacKeys) and IsListOfStrings(pacKeys))
			StzRaise("Incorrect param type! pacKeys must be a list of strings.")
		ok

		if NOT isList(paList)
			StzRaise("Incorrect param type! paList must be a list.")
		ok
	ok

	if not IsHashList(paList)
		return FALSE
	ok

	nLen = len(paList)
	acAllKeys = []

	for i = 1 to nLen
		acAllKeys + paList[i][1]
	next

	nLen = len(pacKeys)
	for i = 1 to nLen
		if find(acAllKeys, pacKeys[i]) = 0
			return 0
		ok
	next

	return 1


	func @HasKeys(paList, pacKeys)
		return HasKeys(paList, pacKeys)

	def ContainsKeys(paList, pacKeys)
		return HasKeys(paList, pacKeys)

	def @ContainsKeys(paList, pacKeys)
		return HasKey(paList, pacKeys)


func IsHashListOfNumbers(paList)
	if NOT isList(paList)
		return FALSE
	ok

	if NOT IsHashList(paList)
		return FALSE
	ok

	if NOT IsListOfListsOfNumbers(StzHashListQ(paList).Values())
		return FALSE
	ok

	return TRUE

func IsHashListOfStrings(paList)
	if NOT isList(paList)
		return FALSE
	ok

	if NOT IsHashList(paList)
		return FALSE
	ok

	if NOT IsListOfListsOfStrings(StzHashListQ(paList).Values())
		return FALSE
	ok

	return TRUE

func IsHashListOfLists(paList)
	if NOT isList(paList)
		return FALSE
	ok

	if NOT IsHashList(paList)
		return FALSE
	ok

	if NOT IsListOfListsOfLists(StzHashListQ(paList).Values())
		return FALSE
	ok

	return TRUE

func IsHashListOfHashLists(paList)
	if NOT isList(paList)
		return FALSE
	ok

	if NOT IsHashList(paList)
		return FALSE
	ok

	if NOT IsListOfListsOfHashLists(StzHashListQ(paList).Values())
		return FALSE
	ok

	return TRUE

func IsHashListOfPairs(paList)
	if NOT isList(paList)
		return FALSE
	ok

	if NOT IsHashList(paList)
		return FALSE
	ok

	if NOT IsListOfListsOfPairs(StzHashListQ(paList).Values())
		return FALSE
	ok

	return TRUE

func IsHashListOfPairsOfNumbers(paList)
	if NOT isList(paList)
		return FALSE
	ok

	if NOT IsHashList(paList)
		return FALSE
	ok

	if NOT IsListOfListsOfPairsOfNumbers(StzHashListQ(paList).Values())
		return FALSE
	ok

	return TRUE

func IsHashListOfObjects(paList)
	if NOT isList(paList)
		return FALSE
	ok

	if NOT IsHashList(paList)
		return FALSE
	ok

	if NOT IsListOfListsOfobjects(StzHashListQ(paList).Values())
		return FALSE
	ok

	return TRUE

func ShowHL(pValue)
	if NOT (isList(pValue) and Q(pValue).IsHashList())
		stzRaise("Incorrect param type! pValue must be a hashlist.")
	ok

	? StzHashListQ(pValue).ToCode()

	#< @FunctionAlternativeForms

	func ShowHashList(pValue)
		ShowHL(pValue)

	func ShowAsHashList(pValue)
		ShowHL(pValue)

	func ShowHList(pValue)
		ShowHL(pValue)

	func ShowAsHList(pValue)
		ShowHL(pValue)

	func ShowAsHL(pValue)
		ShowHL(pValue)

	#>

	#< @FunctionMisspelledForms

	func ShwoHashList(pValue)
		ShwoHL(pValue)

	func ShwoAsHashList(pValue)
		ShwoHL(pValue)

	func ShwoHList(pValue)
		ShwoHL(pValue)

	func ShwoAsHList(pValue)
		ShwoHL(pValue)

	func ShwoAsHL(pValue)
		ShwoHL(pValue)

	#>

func HashRemove(paHash, cKey)
	if CheckParams()
		if NOT (isList(paHash) and IsHashList(paHash))
			StzRaise("Incorrect param type! paHash must be a hashlist.")
		ok
		if NOT isString(cKey)
			StzRaise("Incorrect param type! cKey must be a string.")
		ok
	ok

	nLen = len(paHash)
	cKey = lower(cKey)
	n = 0

	for i = 1 to nLen
		if paHash[i][1] = cKey
			n = 1
			exit
		ok
	next

	if n > 0
		del(paHash, n)
	ok

	return paHash

	func HashDel(paHash, cKey)
		return HashRemove(paHash, cKey)

	func HashDelete(paHash, cKey)
		return HashRemove(paHash, cKey)

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

		if CheckParams()
			if NOT ( isList(p) and @IsHashList(p) )
				StzRaise("Can't create the stzHashList object! You must provide a well formed hashlist.")
			ok
		ok

		/*
		There is a bug in Ring 1.14 (4th, may. 2021)
		Read about it here: https://groups.google.com/g/ring-lang/c/fY6Lh-LDwJg

		The bug occurs when you provide a hashlist using the '=' syntax
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
		#TODO // Is this really necessary?

		nLen = len(p)
		for i = 1 to nLen
			p[i][1] = ring_lower(p[i][1])
		next

		@aContent = p



		if KeepingHistory() = 1
			This.AddHistoricValue(This.Content())
		ok

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
			return This.PairsQRT(:stzList)

		def PairsQRT(pcReturnType)
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
		aContent = This.Content()
		nLen = len(aContent)

		aResult = []
		
		for i = 1 to nLen
			aResult + aContent[i][1]
		next

		return aResult

		def KeysQ()
			return This.KeysQRT(:stzList)

		def KeysQRT(pcReturnType)
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
		aContent = This.Content()
		nLen = len(aContent)

		aResult = []

		for i = 1 to nLen
			aPair = aContent[i]
			if Q(aPair[2]).IsStrictlyEqualTo(pValue)
				aResult + aPair[1]
			ok
		next

		return aResult

		#< @FunctionFluentForms

		def KeysForValueQ()
			return This.KeysForValueQRT(:stzList)

		def KeysForValueQRT(pcReturnType)
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

			def KeysForThisValueQRT(pValue, pcReturnType)
				return This.KeysForValueQ(pValue, pcReturnType)

		#>

	def Values()

		_aContent_ = This.Content()
		_aResult_ = []
		_nLen_ = This.NumberOfPairs()

		for @i = 1 to _nLen_
			_aResult_ + _aContent_[@i][2]
		next

		return _aResult_

		def ValuesQ()
			return This.ValuesQRT(:stzList)

		def ValuesQRT(pcReturnType)
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

		_aContent_ = This.Content()
		_nLen_ = This.NumberOfValues()

		if _nLen_ = 1
			return 1
		ok

		_nSize_ = len(_aContent_[1][2])
		_bResult_ = 1

		for @i = 2 to _nLen_
			if len(_aContent_[@i][2]) != _nSize_
				_bResult_ = 0
				exit
			ok
		next

		return _bResult_

	def ValuesAndKeys()
		aValues = This.Values()
		nLen = len(aValues)

		aResult = []

		for i = 1 to nLen
			aResult + [ value, This.NthKey(i) ]
		next

		return aResults

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
	
		def KeyAtPosition(n)
			return This.Key(n)
	
	def NthValue(n)

		if checkParams()

			if isString(n)
				if n = :First or n = :FirstValue
					n = 1
	
				but n = :Last or n = :LastValue
					n = This.NumberOfValues()
				ok
			ok
	
			if NOT isNumber(n)
				StzRaise("Incorrect param type! n must be a number.")
			ok

		ok

		nLen = len(This.Content())
		if n > nLen or n < 1
			StzRaise("Can't access item " + n + " in the hashlist! The hashlist contains only " + nLen + "pairs.")
		ok

		return This.Content()[n][2]

		def NthValueQ(n)
			return Q(This.NthValue())

		def Value(n)
			return This.NthValue(n)

			def ValueQ(n)
				return Q( This.Value(n) )

		def ValueAtPosition(n)
			return This.Value(n)

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
			return This.NthPairQRT(n, :stzList)

		def NthPairQRT(n, pcReturnType)
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

			def PairQRT(n, pcReturnType)
				return This.NthPairQRT(n, pcReturnType)
	
		#>
	
	def FirstPair()
		return This.NthPair(n)

		def FirstPairQ()
			return This.NthPairQ(1)

		#-- MISSPELLED

		def FristPair()
			return This.FirstPair()

	def LastPair()
		return This.LastPair(n)

		def LastPairQ()
			return This.NthPairQ(This.NumberOfPairs())

	def KeyInPair(paPair)
		if isList(paPair) and @IsPairAndKeyIsString(paPair) and
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
		if isList(paPair) and @IsPairAndKeyIsString(paPair) and
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

	def ValuesAtPositions(anPos)
		aResult = This.ValuesQ().ItemsAtPositions(anPos)
		return aResult

		def ValuesAtThesePositions(anPos)
			return This.ValuesAtPositions(anPos)

	  #---------------------------#
	 #   UPDATING THE HASHLIST   #
	#---------------------------#

	def Update(paNewHashList)
		if CheckingParams() = 1
			if isList(paNewHashList) and Q(paNewHashList).IsWithOrByOrUsingNamedParam()
				paNewHashList = paNewHashList[2]
			ok

			if NOT( isList(paNewHashList) and StzListQ(paNewHashList).IsHashList() )
				StzRaise("Incorrect param type! paNewHashList must be a hashlist.")
			ok
		ok

		@aContent = paNewHashList

		if KeepingHisto() = 1
			This.AddHistoricValue(This.Content())  # From the parent stzObject
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

		if isList(paNewPair) and @IsPairAndKeyIsString(paNewPair)

			This.UpdateNthKey(n, paNewPair[1])
			This.UpdateNthValue(n, paNewPair[2])
		else
			StzRaise("Key must be a string!")
		ok
	
	def UpdatePair(paPair, paNewPair)
		if isList(paPair) and @IsPairAndKeyIsString(paNewPair) and
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

		aContent = This.Content()
		aContent[n][1] = pcValue
		This.UpdateWith(aContent)

	def UpdateKey(pcKey, pcNewKey)
		if isString(pcKey) and This.ContainsKey(pcKey)
			aContent = This.Content()
			n = This.FindKey(pcKey)
			aContent[n][1] = pcNewKey
			This.UpdateWith(aContent)
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

		aContent = This.Content()
		aContent[n][2] = pValue
		This.UpdateWith(aContent)

		def UpdateNthOccurrenceOfValue(pValue)
			This.UpdateNthValue( This.FindNthOccurrenceOfValue(pValue) )
	
	def UpdateValues(paValues)
		for i = 1 to Min([ len(paValues), This.NumberOfPairs() ])
			This.UpdateNthValue(i, paValues[i])
		next
	
	def UpdateValue(pValue, pNewValue)
		anPos = This.FindValue(pValue)
		nLen = len(anPos)

		for i = 1 to nLen
			This.UpdateNthValue(anPos[i], pNewValue)
		next
	
	def UpdateFirstOccurrenceOfValue(pValue, pNewValue)
		This.UpdateNthOccurrenceOfValue(1, pValue, pNewValue)

		def UpdateFirstValue(pValue, pNewValue)
			This.UpdateFirstOccurrenceOfValue(pValue, pNewValue)
		
	def UpdateLastValue(pValue, pNewValue)
		n = NumberOfOccurrenceOfValue(pValue)
		This.UpdateNthValue(n, pValue, pNewValue)

	def UpdateAllPairsWith(paPair)
		if CheckingParams()
			if not isList(paPair)
				StzRaise("Incorrect param type! paPair must be a list.")
			ok

			if Not @IsPairAndKeyIsString(paPair)
				StzRaise("Incorrect param type! paPair must be a pair and its first item must be a string.")
			ok
		ok

		aContent = This.Content()
		nLen = len(aContent)

		for i = 1 to nLen
			aContent[i] = paPair
		next

	  #-----------------------------#
	 #  REVERSING KEYS AND VALUES  #
	#-----------------------------#

	def ReverseKeysAndValues()

		_aKeys_ = This.Keys()
		_aValues_ = This.Values()
		_nLen_ = This.NumberOfPairs()

		_oCopy_ = This.Copy()

		for @i = 1 to _nLen_
			_oCopy_.UpdatenthKey( @i, ""+ _aValues_[@i] )
			_ocopy_.UpdateNthValue( @i, _aKeys[@i] )
		next

		This.UpdateWith( _oCopy_.Content() )

		def ReverseKeysAndValuesQ()
			This.ReverseKeysAndValues()
			return This
	
	  #---------------------#
	 #     ADDING PAIRS    #
	#---------------------#

	def AddPair(paNewPair)

		if isList(paNewPair) and @IsPair(paNewPair) and isString(paNewPair[1])

			if This.HasKey(paNewPair[1])
				StzRaise("Can't add the pair! the key you provided already exists.")
			ok

			aContent = This.Content()
			aContent + paNewPair

			This.UpdateWith(aContent)

		else
			StzRaise("Syntax error! The value you provided is not a pair with its key beeing a string.")
		ok

		def AddPairQ(paNewPair)
			This.AddPair(paNewPair)
			return This

		def Add(paNewPair)
			This.AddPair(paNewPair)

			def AddQ(paNewPair)
				return This.AddPairQ(paNewPair)


	def AddPairs(paListOfPairs)
		nLen = len(paListOfPairs)
		for i = 1 to nLen
			This.AddPair(paListOfPairs[i])
		next

		def AddPairsQ(paListOfPairs)
			This.AddPairs(paListOfPairs)
			return This

		def AddManyPairs(paListOfPairs)
			This.AddPairs(paListOfPairs)

			def AddManyPairsQ(paListOfPairs)
				return This.AddPairsQ(paListOfPairs)

		def AddMany(paListOfPairs)
			This.AddPairs(paListOfPairs)

			def AddManyQ(paListOfPairs)
				return This.AddPairsQ(paListOfPairs)

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

		#NOTE // As a general guideline, and after introducing the
		# object history feature through QH() small function, we
		# should never update objects content direcly like this:

		// del( This.Content(), n )

		# Instead, we use a copy of the content, change it, and then
		# call the UpdateWith() method on our object with the result.

		# This way, the UpdateWith() can form a single update-point
		# of all Softanza manipulations and enables QH() and its
		# related functions to track the history of updates.

		#LINK // To get an idea of the use of QH() read this
		# narration on the library documentation:
		# https://github.com/mayouni/stzlib/blob/main/libraries/stzlib/doc/narrations/stz-narration-keeping-object-history.md

		#TODO // Review all the library according to this.

		aContent = This.Content()
		del(aContent, n)
		This.UpdateWith(aContent)

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
		if CheckingParams()
			if NOT (isList(pacKeys) and @IsListOStrings(pacKeys))
				StzRaise("Incorrect param type! pacKeys must be a list of strings.")
			ok
		ok

		nLen = len(pacKeys)

		for i = 1 to nLen
			This.RemovePairByKey(pacKeys[i])
		next

	def RemovePairsByValue(pValue)
		aPos = This.FindValue(pValue)

		aResult = StzListQ( This.HashList() ).RemoveItemsAtThesePositionsQ( aPos ).Content()
		This.Update(aResult)

		def RemovePairsByValueQ(pValue)
			This.RemovePairsByValue(pValue)
			return This

	def RemovePairsByValues(paValues)
		if CheckingParams()
			if NOT isList(paValues)
				StzRaise("Incorrect param type! paValues must be a list.")
			ok
		ok

		nLen = len(paValues)

		for i = 1 to nLen
			This.RemovePairsByValue(paValues[i])
		next

	  #------------------#
	 #  REPLACING KEYS  #
	#==================#

	def ReplaceKey(pcKey, pcNewKey)
		n = This.FindKey(pcKey)
		This.ReplaceNthKey(n, pcNewKey)

		def ReplaceKeyQ(pcKey, pcNewKey)
			This.ReplaceKey(pcKey, pcNewKey)
			return this

	def ReplaceNthKey(n, pcNewKey)
		if CheckingParam()
			if isList(pcNewKey) and Q(pcNewKey).IsWithOrByNamedParam()
				pcNewKey = pcNewKey[2]
			ok
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

	  #--------------------#
	 #  REPLACING VALUES  #
	#====================#

	def ReplaceValue(pValue, pNewValue)
		n = This.FindValue(pValue)
		This.ReplaceNthValue(n, pNewValue)

		def ReplaceValueQ(pValue, pNewValue)
			This.ReplaceValue(pValue, pNewValue)
			return this

	def ReplaceNthValue(n, pNewValue)

		if CheckingParam()
			if NOT isNumber(n) and isNumber(pNewValue)
				temp = n
				n = pNewValue
				pNewValue = temp
			ok

			if isList(pNewValue) and Q(pNewValue).IsWithOrByNamedParam()
				pNewValue = pNewValue[2]
			ok
		ok

		if NOT isNumber(n)
			StzRaise("Incorrect param type! n must be a number.")
		ok

		This.NthPair(n)[2] = pNewValue

		#NOTE // Normally Set... does not belong to Softanza semantics,
		# we use Replace instead. Here I use to cope with AI-generated
		# code which tend to be alligned with the Set keyword
		def SetValueAt(n, pNewValue)
			This.ReplaceNthValue(n, pNewValue)

		def ReplaceNthValueQ(n, pNewValue)
			This.ReplaceNthValue(n, pNewValue)
			return This

		def SetValueAtQ(n, pNewValue)
			return This.ReplaceNthValueQ(n, pNewValue)


	def ReplaceFirstValue(pNewValue)
		This.ReplaceNthValue(1, pNewValue)

		def ReplaceFirstValueQ(pNewValue)
			This.ReplaceFirstValue(pNewValue)
			return This

	def ReplaceLastValue(pNewValue)
		This.ReplaceNthValue(This.NumberOfValues(), pNewValue)

		def ReplaceLastValueQ(pNewValue)
			This.ReplaceLastValue(pNewValue)
			return This

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

	  #-------------------#
	 #  REPLACING PAIRS  #
	#===================#

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
			return 1
		else
			return 0
		ok

		def ContainsKey(pcKey)
			return This.HasKey(pcKey)
		
	def HasKeys(pacKeys)

		oKeys = new stzList(pacKeys)
		if oKeys.IsListOfStrings() and
		   oKeys.IsEqualTo(This.Keys())

			return 1
		else
			return 0
		ok

		def ContainsKeys(pacKeys)
			return This.HasKeys(pacKeys)

	  #-----------------#
	 #  FINDING PAIRS  #
	#-----------------#

	def FindPair(paPair)
		if NOT isList(paPair)
			StzRaise("Incorrect param type! paPair must be a list.")
		ok

		if NOT @IsPairAndKeyIsString(paPair)
			StzRaise("Can't search the list." + NL + "Because paPair is not a pair!")
		ok 

		aContent = This.Content()
		nLen = len(aContent)

		nResult = 0

		for i = 1 to nLen
			aPair = aContent[i]
			if Q(aPair[1]).IsEqualTo(paPair[1]) and
			   Q(aPair[2]).IsEqualTo(paPair[2])

				nResult = i
				exit
			ok	
		next
		return nResult


	def ContainsPair(paPair)

		if FindPair(paPair) > 0
			return 1
		else
			return 0
		ok

	  #-----------------------------------------------------#
	 #  CHECKING IF THE HASHLIST CONTAINS THE GIVEN VALUE  #
	#-----------------------------------------------------#

	def ContainsValueCS(pValue, pCaseSensitive)

		if len( This.FindValueCS(pValue, pCaseSensitive) ) > 0
			return 1
		else
			return 0
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
		return This.ContainsValueCS(pValue, 1)

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
		return This.ContainsValuesCS(paValues, 1)

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
		anResult = This.ValuesQ().FindAllCS(pValue, pCaseSensitive)
		return anResult

		#< @FunctionAlternativeForms

		def FindAllOccurrencesOfValueCS(pValue, pCaseSensitive)
			return This.FindValueCS(pValue, pCaseSensitive)

		def FindCS(pValue, pCaseSensitive)
			return This.FindValueCS(pValue, pCaseSensitive)

		#>

	#-- WITHOUT CASESENSITIVITY

	def FindValue(pValue)
		return This.FindValueCS(pValue, 1)

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
		return This.FindValuesCS(paValues, 1)

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

		if CheckingParams()

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
		return This.FindNthOccurrenceOfValueCS(n, pValue, 1)

		#< @FunctionAlternativeForms

		def FindNthValue(n, pValue)
			return This.FindNthOccurrenceOfValue(n, pValue)

		def FindNth(n, pValue)
			return This.FindNthOccurrenceOfValue(n, pValue)

		#>

	  #---------------------------------------------#
	 #   FINDING THE FIRST OCCURRENCE OF A VALUE   #TODO // Add case sensitivity
	#---------------------------------------------#

	def FindFirstOccurrenceOfValue(pValue)
		return This.FindNthValue(1, pValue)

		#< @FunctionAlternativeForms

		def FindFirstValue(pValue)
			return This.FindFirstOccurrenceOfValue(pValue)

		def FindFirst(pValue)
			return This.FindFirstOccurrenceOfValue(pValue)

		#>

		#< @FunctionMisspelledForms

		def FindFristOccurrenceOfValue(pValue) 
			return This.FindFirstOccurrenceOfValue(pValue)

		def FindFristValue(pValue)
			return This.FindFirstOccurrenceOfValue(pValue)

		def FindFrist(pValue)
			return This.FindFirstOccurrenceOfValue(pValue)

		#>

	  #--------------------------------------------#
	 #   FINDING THE LAST OCCURRENCE OF A VALUE   #TODO // Add case sensitivity
	#--------------------------------------------#

	def FindLastOccurrenceOfValue(pValue)
		return This.FindNthOccurrenceOfValue(This.NumberOfValues(), pValue)

		def FindLastValue(pValue)
			return This.FindLastOccurrenceOfValue(pValue) 

		def FindLast(pValue)
			return This.FindLastOccurrenceOfValue(pValue) 

	  #---------------------------#
	 #   FINDING KEYS BY VALUE   #TODO // Add case sensitivity
	#---------------------------#

	def FindKeysByValue(pValue)

		aContent = This.HashList()
		nLen = len(aContent)

		anResult = []
		
		for i = 1 to nLen

			if Q(aContent[i][2]).Contains(pValue)
				anResult + i
			ok
		next

		return anResult

	  #------------------------------#
	 #   FINDING NTH KEY BY VALUE   #TODO // Add case sensitivity
	#------------------------------#

	def FindNthKeyByValue(pValue)
		nResult = 0
		if This.ContainsValue(pValue)
			nResult = This.FindKeysByValue(pValue)[n]
		ok
		return nResult

	  #--------------------------------#
	 #   FINDING FIRST KEY BY VALUE   #TODO // Add case sensitivity
	#--------------------------------#

	def FindFirstKeyByValue(pValue)
		nResult = 0
		if This.ContainsValue(pValue)
			nResult = This.FindKeysByValue(pValue)[1]
		ok
		return nResult

		#< @FunctionAlternativeForm

		def FindKeyByValue(pValue)
			return This.FindFirstKeyByValue(pValue)

		#>

		#< @FunctionMisspelledForm

		def FindFristKeyByValue(pValue)
			return This.FindFirstKeyByValue(pValue)

		#>
	  #-------------------------------#
	 #   FINDING LAST KEY BY VALUE   #TODO // Add case sensitivity
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
	 #   GETTING THE KEY CORRESPONDING TO A GIVEN VALUE   #TODO // Add case sensitivity
	#----------------------------------------------------#

	def KeyByValue(pValue)
		acKeys = This.KeysByValue(pValue)
		nLen = len(acKeys)

		if nLen = 0
			return ""
		ok

		cResult = acKeys[1]
		return cResult
	
	  #-----------------------------------------------------#
	 #   GETTING THE KEYS CORRESPONDING TO A GIVEN VALUE   #TODO // Add case sensitivity
	#-----------------------------------------------------#

	def KeysByValue(pValue)
		anPos = This.FindKeysByValue(pValue)
		acResult = This.KeysAtPositions(anPos)

		return acResult

	  #---------------------------------------------------------#
	 #  GETTING THE KEYS CORRESPONDING TO THE PROVIDED VALUES  #
	#---------------------------------------------------------#

	def KeysByValues(paValues)
		nLen = len(paValues)

		acKeys = []

		for i = 1 to nLen
			acKeys + This.KeysByValue(paValues[i])
		next

		acResult = StzListQ(acKeys).MergeQ().WithoutDuplicates()

		return acResult

	  #----------------------------------------------#
	 #  GETTING THE KEYS AT THE PROVIDED POSITIONS  #
	#==============================================#

	def KeysAtPositions(panPos)
		acResult = This.KeysQ().ItemsAtPositions(panPos)
		return acResult

		def KeysAtThesePositions(panPos)
			return This.KeysAtPositions(panPos)

	  #-----------------------------------------#
	 #  FINDING LISTS (VALUES THAT ARE LISTS)  #
	#=========================================#
	#TODO // Add case sensitivity

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

	def FindNonLists() // #TODO Make a more performant solution
		anResult = Q( 1 : This.Size() ) - These( This.FindLists() )
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

		if CheckingParams()
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
		if CheckingParams()
			if NOT isList(paList) 
				StzRaise("Incorrect param type! paList must be a list.")
			ok
		ok

		anPos = This.FindList(paList)
		aResult = [ paList, anPos ]	
		return aResult

	def FindTheseLists(paLists)
		if CheckingParams()
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
		if CheckingParams()
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
	#TODO // Add case sensitivity

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

		if CheckingParams()
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
		if CheckingParams()
			if NOT isNumber(paNumber) 
				StzRaise("Incorrect param type! paNumber must be a list.")
			ok
		ok

		anPos = This.FindNumber(paNumber)
		aResult = [ paNumber, anPos ]	
		return aResult

	def FindTheseNumbers(paNumbers)
		if CheckingParams()
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
		if CheckingParams()
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
	#TODO // Add case sensitivity

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

		if CheckingParams()
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
		if CheckingParams()
			if NOT isString(paString) 
				StzRaise("Incorrect param type! paString must be a list.")
			ok
		ok

		anPos = This.FindString(paString)
		aResult = [ paString, anPos ]	
		return aResult

	def FindTheseStrings(paStrings)
		if CheckingParams()
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
		if CheckingParams()
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
	#TODO // Add case sensitivity

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
	#TODO // Add case sensitivity

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
	#TODO // Add case sensitivity

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
	#TODO // Add case sensitivity

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
	#TODO // Add case sensitivity

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
	#TODO // Add case sensitivity

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
	#TODO // Add case sensitivity

	# SEMANTIC NOTE: An "Item" in the context of stzHashList, refers to values that
	# are lists, and those lists contain the item. See examples hereafter.

	def ContainsItem(pItem) #TODO // Add case sensitivity
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

		bResult = 0

		for i = 1 to nLen

			if isList(aContent[i][2])

				oStzList = new stzList(aContent[i][2])
				if oStzList.Contains(pItem)
					bResult = 1
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
	#TODO // Add case sensitivity

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

		def FindInValues(pItem)
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

		if CheckingParams()
			if NOT isList(paItems)
				StzRaise("Incorrect param type! paItems must be a list.")
			ok
		ok

		# step 1 : we get the items and their positions (see format
		# the example in TheseItemsZ() function

		aTemp1 = This.TheseItemsZ(paItems)
		nLen = len(aTemp1)

		# Step 2 : we  take the positions (pairs) and put them in a list

		aTemp2 = []

		for i = 1 to nLen
			aPos = aTemp1[i][2]
			nLenPos = len(aPos)

			for j = 1 to nLenPos
				aTemp2 + aPos[j]
			next
		next

		# Step 2 : we factorise the obtained list to get the positions

		nLen = len(aTemp2)
		aResult = []

		for i = 1 to nLen
			nLenPos = len(aTemp2[i][2])
			for j = 1 to nLenPos
				aResult + [ aTemp2[i][1], aTemp2[i][2][j] ]
			next
		next

		# Step 4 : we return the result

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

		if CheckingParams()
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

		#< @FunctionFluentForms

		def TheseItemsZQ(paItems)
			return This.TheseItemsZQRT(:stzList)

		def TheseItemsZQRT(paItems, pcReturnType)
			switch pcReturnType
			on :stzList
				return new stzList(This.TheseItemsZ(paItems))
			on :stzHashList
				return new stzHashList(This.TheseItemsZ(paItems))
			other
				StzRaise("Unsupported return type!")
			off

		#>

		#< @FunctionAlternativeForms

		def TheseItemsInListZ(paItems)
			return This.TheseItemsZ(paItems)

		def TheseItemsInListsZ(paItems)
			return This.TheseItemsZ(paItems)

		#<

	def Items()

		aResult = U( This.ValuesQ().OnlyListsQ().Merged() )
		return aResult

	def FindItems()
	
		aIndex = This.Copy().ListifyQ().ValuesQRT(:stzListOfLists).IndexXT()

		aItems = This.Items()
		nLen = len(aIndex)

		aResult = []

		for i = 1 to nLen
			aPairs = aIndex[i][2]
			nLenPairs = len(aPairs)
			for j = 1 to nLenPairs
				aResult + aPairs[j]
			next
		next

		return aResult

	def ItemsZ()
		
		aIndex = This.Copy().ListifyQ().ValuesQRT(:stzListOfLists).IndexXT()

		aItems = This.Items()
		anPos = QRT(aIndex, :stzHashList).FindTheseKeys(aItems)
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
	#TODO // Add case sensitivity

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
	#TODO // Add case sensitivity

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

		#< @FunctionMisspelledForms

		def FindFristItem(pItem)
			return This.FindFirstItem(pItem)

		def FindThisFristItem(pItem)
			return This.FindFirstItem(pItem)

		def FindFristOccurrenceOfThisItem(pItem)
			return This.FindFirstItem(pItem)

		def FindFristOccurrenceOfItemInList(pItem)
			return This.FindFirstItem(pItem)

		def FindFristOccurrenceOfThisItemInList(pItem)
			return This.FindFirstItem(pItem)

		#>

	  #--------------------------------------------------------------------------------------#
	 #   WHEN THE VALUE IS A LIST, FINDING THE LAST OCCURRENCE OF AN ITEM INSIDE THAT LIST  # 
	#--------------------------------------------------------------------------------------#
	#TODO // Add case sensitivity

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
	#TODO // Add case sensitivity

	def FindKeysByItem(pItem)
		anPos = This.FindItemInList(pItem)
		nLen = len(anPos)

		anResult = []

		for i = 1 to nLen
			anResult + anPos[i]
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

		#< @FunctionAlternativeForm

		def FindFirstKeyByItem(pValue)
			return This.FindFirstKeyByItemInList(pValue)

		#>

		#< @FunctionMisspelledForm

		def FindFristKeyByItemInList(pValue)
			return This.FindFirstKeyByItemInList(pValue)

		#>

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
		nLen = len(anPos)

		aResult = []

		for i = 1 to nLen
			aResult + This.Key(anPos[i])
		next

		return aResult

		def KeysByItem(pValue)
			return This.KeysByItem(pValue)

	  #-----------------------------------------------#
	 #  LISTIFYING (ALL THE VALUES IN) THE HASHLIST  #
	#-----------------------------------------------#

	def Copy()
		oCopy = new stzHashList(This.content())
		return oCopy

	def Listify()

		aContent = This.Content()
		nLen = len(aContent)

		for i = 1 to nLen
			if NOT isList(aContent[i][2])
				aTempList = []
				aTempList + aContent[i][2]
				aContent[i][2] = aTempList
			ok
		next

		This.UpdateWith(aContent)


		def ListifyQ() #TODO // Ensure consistency in all library
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
		acClasses = This.Classes()
		nlen = len(acClasses)

		for i = 1 to nLen
			aResult + [ acClasses[i], This.KeysForValue(acClasses[i]) ]
		next

		return aResult

		#< @FunctionFluentForm

		def ClassifyQ()
			return This.ClassifyQRT(pcReturnType)

		def ClassifyQRT(pcReturnType)
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
			return This.ClassesQRT(:stzList)

		def ClassesQRT(pcReturnType)
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

			def KlassesQRT(pcReturnType)
				return ClassesQRT(pcReturnType)
	
		#>

	  #-----------------------------------------------------#
	 #  CHECKING IF THE HASHLIST CONTAINS THE GIVEN CLASS  #
	#-----------------------------------------------------#

	def ContainsClass(pcClass)
		bResult = This.ContainsValueCS(pcClass, 0)
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

		#>

	  #-------------------------------------------------------#
	 #  CHECKING IF THE HASHLIST CONTAINS THE GIVEN CLASSES  #
	#-------------------------------------------------------#

	def ContainsClasses(pacClasses)
		bResult = This.ContainsValuesCS(pacClasses, 0)
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

	  #-----------------------------------------------#
	 #  GETTING THE VALUES RELATED TO A GIVEN KLASS  #
	#-----------------------------------------------#

	def Klass(pcClass)
		#NOTE: We can't use Class (with C) --> reserved by Ring
		# --> To avoid any confusion, use Klass with K instead,
		# or if you prefer, use Category.

		aResult = This.KeysForValue(pcClass)
		return aResult

		#< @FunctionFluentForms

		def KlassQ(pcClass)
			return This.KlassQRT(pClass, :stzList)

		def KlassQRT(pcClass, pcReturnType)
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

		# We can't use Class() as an alternative, because it is reserved by Ring
		# But we can use it for the follwoing fluent forms:

			def ClassQ(pcClass)
				return This.KlassQ(pcClass)
	
			def ClassQRT(pcClass, pcReturnType)
				return This.KlassQRT(pcClass, pcReturnType)

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

		def ClassesAndTheirSizes()
			return This.ClassesSizesXT()

		def KlassesAndTheirSizes()
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
		if CheckingParams()
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

		#--

		def NumberOfValuesInTheseClasses(pacClasses)
			return This.TheseClassesSizes(pacClasses)

		def NumberOfValuesInTheseKlasses(pacClasses)
			return This.TheseClassesSizes(pacClasses)

		def NumbersOfValuesInTheseClasses(pacClasses)
			return This.TheseClassesSizes(pacClasses)

		def NumbersOfValuesInTheseKlasses(pacClasses)
			return This.TheseClassesSizes(pacClasses)

		#>

	def TheseClassesSizesXT(pacClasses)
		if CheckingParams()
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

		#--

		def NumberOfValuesInTheseClassesXT(pacClasses)
			return This.TheseClassesSizesXT(pacClasses)

		def NumberOfValuesInTheseKlassesXT(pacClasses)
			return This.TheseClassesSizesXT(pacClasses)

		def NumbersOfValuesInTheseClassesXT(pacClasses)
			return This.TheseClassesSizesXT(pacClasses)

		def NumbersOfValuesInTheseKlassesXT(pacClasses)
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

		#--

		def FrequencyOfThisClass(pcClass)
			return This.KlassFreq(pcClass)

		def FrequencyOfThisKlass(pcClass)
			return This.KlassFreq(pcClass)

		#--

		def FreqOfThisClass(pcClass)
			return This.KlassFreq(pcClass)

		def FreqOfThisKlass(pcClass)
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

		def FrequencyOfThisClassXT(pcClass)
			return This.KlassFreqXT(pcClass)

		def FrequencyOfThisKlassXT(pcClass)
			return This.KlassFreq(pcClass)

		#--

		def FreqOfThisClassXT(pcClass)
			return This.KlassFreqXT(pcClass)

		def FreqOfThisKlassXT(pcClass)
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

		def ClassesAndTheirFrequencies()
			return This.ClassesFrequenciesXT()

		def KlassesAndTheirFrequencies()
			return This.ClassesFrequenciesXT()

		def KlassesAndTheirFreq()
			return This.ClassesFrequenciesXT()

		def KlassesAndTheirFreqs()
			return This.ClassesFrequenciesXT()

		#>

	  #------------------------------------------------#
	 #  GETTING THE FREQUENCIES OF THE GIVEN CLASSES  #
	#------------------------------------------------#

	def TheseClassesFrequencies(pacClasses)
		if CheckingParams()
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

		#>

	def TheseClassesFrequenciesXT(pacClasses)
		if CheckingParams()
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

		def TheseClassesAndTheirFrequencies(pacClasses)
			return This.TheseClassesFrequenciesXT(pacClasses)

		def TheseKlassesAndTheirFrequencies(pacClasses)
			return This.TheseClassesFrequenciesXT(pacClasses)

		#--

		def TheseClassesAndTheirFreqs(pacClasses)
			return This.TheseClassesFrequenciesXT(pacClasses)

		def TheseKlassesAndTheirFreqs(pacClasses)
			return This.TheseClassesFrequenciesXT(pacClasses)

		#--

		def TheseClassesAndTheirFreq(pacClasses)
			return This.TheseClassesFrequenciesXT(pacClasses)

		def TheseKlassesAndTheirFreq(pacClasses)
			return This.TheseClassesFrequenciesXT(pacClasses)

		#>

	  #-------------------------------------#
	 #   GETTING THE N STRONGEST CLASSES   #
	#=====================================#

	def NStrongestClasses(n)
		aClassesXT = ring_reverse( ring_sort2( ClassesXT(), 2 ) )
		nLen = len(aClassesXT)

		n = @Min([ n, nLen ])

		aResult = []

		for i = 1 to n
			aResult + aClassesXT[i][1]
		next

		return aResult
		
		#< @FunctionAlternativeForms

		def NStrongestKlasses(n)
			return This.NStrongestClasses(n)

		def StrongestNClasses(n)
			return This.NStrongestClasses(n)

		def StrongestNKlasses(n)
			return This.NStrongestClasses(n)

		#--

		def TopNClasses(n)
			return This.NStrongestClasses(n)

		def NTopClasses(n)
			return This.NStrongestClasses(n)

		#>

	def NStrongestClassesXT(n)
		aClassesXT = ring_reverse( ring_sort2( ClassesXT(), 2 ) )
		nLen = len(aClassesXT)
		n = Min([ n, nLen ])

		aResult = []

		for i = 1 to n
			aResult + aClassesXT[i]
		next

		return aResult

		#< @FunctionAlternativeForms

		def NStrongestKlassesXT(n)
			return This.NStrongestClassesXT(n)

		def StrongestNClassesXT(n)
			return This.NStrongestClassesXT(n)

		def StrongestNKlassesXT(n)
			return This.NStrongestClassesXT(n)

		#--

		def NStrongestKlassesAndTheirFrequencies(n)
			return This.NStrongestClassesXT(n)

		def StrongestNClassesAndTheirFrequencies(n)
			return This.NStrongestClassesXT(n)

		def StrongestNKlassesAndTheirFrequencies(n)
			return This.NStrongestClassesXT(n)

		#--

		def TopNClassesXT(n)
			return This.NStrongestClassesXT(n)

		def NTopClassesXT(n)
			return This.NStrongestClassesXT(n)

		def TopNClassesAndTheirFrequencies(n)
			return This.NStrongestClassesXT(n)

		def NTopClassesAndTheirFrequencies(n)
			return This.NStrongestClassesXT(n)

		#>

	#--

	def StrongestClass()
		return This.StrongestNClasses(1)[1]

		#< @FunctionAlternativeForms

		def StrongestKlass()
			return This.StrongestClass()

		def TopClass()
			return This.StrongestClass()

		def TopKlass()
			return This.StrongestClass()

		#>

	def StrongestClassXT()
		return This.StrongestNClassesXT(1)[1]

		#< @FunctionAlternativeForms

		def StrongestKlassXT()
			return This.StrongestClassXT()

		def TopClassXT()
			return This.StrongestClassXT()

		def TopKlassXT()
			return This.StrongestClassXT()

		#--

		def StrongestClassAndTheirFrequencies()
			return This.StrongestClassXT()

		def StrongestKlassAndTheirFrequencies()
			return This.StrongestClassXT()

		def TopClassAndTheirFrequencies()
			return This.StrongestClassXT()

		def TopKlassAndTheirFrequencies()
			return This.StrongestClassXT()

		#>

	#--

	def Top3Classes()
		return This.StrongestNClasses(3)

		#< @FunctionAlternativeForms

		def 3StrongestKlasses(n)
			return This.Top3Classes(n)

		def Strongest3Classes()
			return This.Top3Classes(n)

		def Strongest3Klasses(n)
			return This.Top3Classes(n)

		#>

	def Top3ClassesXT()
		return This.StrongestNClassesXT(3)

		#< @FunctionAlternativeForms

		def 3StrongestKlassesXT(n)
			return This.Top3ClassesXT(n)

		def Strongest3ClassesXT()
			return This.Top3ClassesXT(n)

		def Strongest3KlassesXT(n)
			return This.Top3ClassesXT(n)

		#--

		def Top3ClassesAndTheirFrequencies(n)
			return This.Top3ClassesXT(n)

		def 3StrongestKlassesAndTheirFrequencies(n)
			return This.Top3ClassesXT(n)

		def Strongest3ClassesAndTheirFrequencies()
			return This.Top3ClassesXT(n)

		def Strongest3KlassesAndTheirFrequencies(n)
			return This.Top3ClassesXT(n)

		#>

	  #-----------------------------------#
	 #   GETTING THE N WEAKEST CLASSES   #
	#===================================#

	def NWeakestClasses(n)
		aClassesXT = ring_sort2( ClassesXT(), 2 )
		nLen = len(aClassesXT)
		n = Min([ n, nLen ])

		aResult = []

		for i = 1 to n
			aResult + aClassesXT[i][1]
		next

		return aResult

		#< @FunctionAlternativeForms

		def NWeakestKlasses(n)
			return This.NWeakestClasses(n)

		def WeakestNClasses(n)
			return This.NWeakestClasses(n)

		def WeakestNKlasses(n)
			return This.NWeakestClasses(n)

		#--

		def BottomNClasses(n)
			return This.NWeakestClasses(n)

		def NBottomClasses(n)
			return This.NWeakestClasses(n)

		#>

	def NWeakestClassesXT(n)
		aClassesXT = ring_sort2( ClassesXT(), 2 )
		nLen = len(aClassesXT)
		n = Min([ n, nLen ])

		aResult = []

		for i = 1 to n
			aResult + aClassesXT[i]
		next

		return aResult

		#< @FunctionAlternativeForms

		def NWeakestKlassesXT(n)
			return This.NWeakestClassesXT(n)

		def WeakestNClassesXT(n)
			return This.NWeakestClassesXT(n)

		def WeakestNKlassesXT(n)
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

		#--

		def BottomNClassesXT(n)
			return This.NWeakestClassesXT(n)

		def NBottomClassesXT(n)
			return This.NWeakestClassesXT(n)

		def BottomNClassesAndTheirFrequencies(n)
			return This.NWeakestClassesXT(n)

		def NBottomClassesAndTheirFrequencies(n)
			return This.NWeakestClassesXT(n)

		#>

	#--

	def WeakestClass()
		return This.WeakestNClasses(1)[1]

		#< @FunctionAlternativeForms

		def WeakestKlass()
			return This.WeakestClass()

		def BottomClass()
			return This.WeakestClass()

		def BottomKlass()
			return This.WeakestClass()

		#>

	def WeakestClassXT()
		return This.WeakestNClassesXT(1)[1]

		#< @FunctionAlternativeForms

		def WeakestKlassXT()
			return This.WeakestClassXT()

		def BottomClassXT()
			return This.WeakestClassXT()

		def BottomKlassXT()
			return This.WeakestClassXT()

		#--

		def WeakestClassAndItsFrequency(n)
			return This.WeakestClassXT(n)

		def WeakestKlassAndItsFrequency(n)
			return This.WeakestClassXT(n)

		#>

	#--

	def Bottom3Classes()
		return This.WeakestNClasses(3)

		#< @FunctionAlternativeForms

		def 3WeakestKlasses(n)
			return This.Bottom3Classes(n)

		def Weakest3Classes()
			return This.Bottom3Classes(n)

		def Weakest3Klasses(n)
			return This.Bottom3Classes(n)
		#>

	def Bottom3ClassesXT()
		return This.WeakestNClassesXT(3)

		#< @FunctionAlternativeForms

		def 3WeakestKlassesXT(n)
			return This.Bottom3ClassesXT(n)

		def Weakest3ClassesXT()
			return This.Bottom3ClassesXT(n)

		def Weakest3KlassesXT(n)
			return This.Bottom3ClassesXT(n)

		#--

		def 3WeakestKlassesAndTheirFrequencies(n)
			return This.Bottom3ClassesXT(n)

		def Weakest3ClassesAndTheirFrequencies()
			return This.Bottom3ClassesXT(n)

		def Weakest3KlassesAndTheirFrequencies(n)
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
			return This.ClassesInListsQRT(:stzList)

		def ClassesInListQRT(pcReturnType)
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

			def KlassesInListQRT(pcReturnType)
				return This.CategoriesInListQRT(pcReturnType)

		#--

		def ClassesInLists()
			return This.ClassesInList()

		def KlassesInLists()
			return This.ClassesInList()

			def KlassesInListsQ()
				return This.ClassesInListQ()

			def KlassesInListsQRT(pcReturnType)
				return This.CategoriesInListQRT(pcReturnType)

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
	 #  CLASSIFYING VALUES IN LIST  #TODO // Test and clarify!
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
			return This.ClassifyInListQRT(pcReturnType)

		def ClassifyInListQRT(pcReturnType)
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

		def KlassifyInList()
			return This.ClassifyInList()

			def KlassifyInListQ()
				return This.ClassifyInListQ()

			def KlassifyInListQRT(pcReturnType)
				return This.ClassifyInListQRT(pcReturnType)

		#--

		def ClassifyInLists()
			return This.ClassifyInList()

			def ClassifyInListsQ()
				return This.ClassifyInListQ()
	
			def ClassifyInListsQRT(pcReturnType)
				return This.ClassifyInListQRT(pcReturnType)

		def KlassifyInLists()
			return This.ClassifyInList()

			def KlassifyInListsQ()
				return This.ClassifyInListQ()

			def KlassifyInListsQRT(pcReturnType)
				return This.ClassifyInListQRT(pcReturnType)

		#==

		def ClassifyItemsInList()
			return This.ClassifyInList()

			def ClassifyItemsInListQ()
				return This.ClassifyInList()

			def ClassifyItemsInListQRT(pcReturnType)
				return This.ClassifyInListQT(pcReturnType)

		def KlassifyItemsInList()
			return This.ClassifyInList()

			def KlassifyItemsInListQ()
				return This.ClassifyInListQ()

			def KlassifyItemsInListQRT(pcReturnType)
				return This.ClassifyInListQRT(pcReturnType)

		#--

		def ClassifyItemsInLists()
			return This.ClassifyInList()

			def ClassifyItemsInListsQ()
				return This.ClassifyInListQ()
	
			def ClassifyItemsInListsQRT(pcReturnType)
				return This.ClassifyInListQRT(pcReturnType)

		def KlassifyItemsInLists()
			return This.ClassifyInList()

			def KlassifyItemsInListsQ()
				return This.ClassifyInListQ()

			def KlassifyItemsInListsQRT(pcReturnType)
				return This.ClassifyInListQRT(pcReturnType)

		#>

	  #-------------------------------------------------#
	 #  GETTING THE VALUES RELATED TO A KLASS-IN-LIST  #
	#-------------------------------------------------#

	def KlassInList(pcClass)
		aResult = This.KeysForItemInList(pcClass)
		return aResult

		#< @FunctionFluentForms

		def KalssInListQ(pcClass)
			return This.KlassInListQRT(pcClass, :stzList)

		def KlassInListQRT(pcClass, pcReturnType)
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

			def ClassInListQRT(pcClass, pcReturnType)
				return This.KalssInListQRT(pcClass)

		#--

		def KalssInLists(pcClass)
			return This.KlassInList(pcClass)

			def KalssInListsQ(pcClass)
				return This.KalssInListQ(pcClass)

			def KalssInListsQRT(pcClass, pcReturnType)
				return This.KalssInListQRT(pcClass)

		def ClassInLists(pcClass)
			return This.KlassInList(pcClass)

			def ClassInListsQ(pcClass)
				return This.KalssInListQ(pcClass)

			def ClassInListsQRT(pcClass, pcReturnType)
				return This.KalssInListQRT(pcClass)

		#>

	  #===============#
	 #     QUERY     #
	#===============#

	// TODO: FindWhere(cCondition) --> See how this was made in stzList
	// TODO: Support SQL semantics and functions (see steExtCode)

	  #==============#
	 #     SHOW     #
	#==============#

	def Show()
		This.ToStzTable().Show()

		#< @FuntionMisspelledForm

		def Shwo()
			This.Show()

		#>

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
		return 1

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

	  #---------------------------------------------#
	 #  TRANSFORMING THE HASHLIST INTO A STZTABLE  #
	#---------------------------------------------#

	def ToStzTable()
		aContent = This.Content()
		nLen = len(aContent)

		aTable = aContent

		for i = 1 to nLen


		next

		oResult = new stzTable(aTable)
		return oResult
