

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

	_acKeysResult_ = []
	_nKeysLen_ = len(paList)

	for _iKeys_ = 1 to _nKeysLen_
		add(_acKeysResult_, paList[_iKeys_][1])
	next

	return _acKeysResult_

	func @Keys(paList)
		return Keys(paList)


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

	_nHkLen_ = len(paList)
	_acHkKeys_ = []

	for _iHk_ = 1 to _nHkLen_
		add(_acHkKeys_, StzLower(paList[_iHk_][1]))
	next

	return iff(StzFind(_acHkKeys_, StzLower(pcKey)) > 0, TRUE, FALSE)

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

	_nHksLen_ = len(paList)
	_acHksAllKeys_ = []

	for _iHks_ = 1 to _nHksLen_
		add(_acHksAllKeys_, paList[_iHks_][1])
	next

	_nHksKeysLen_ = len(pacKeys)
	for _jHks_ = 1 to _nHksKeysLen_
		if find(_acHksAllKeys_, pacKeys[_jHks_]) = 0
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

func HasKeysXT(paList, pacKeys)
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

	_nHkxLen_ = len(paList)
	_acHkxAllKeys_ = []

	for _iHkx_ = 1 to _nHkxLen_
		add(_acHkxAllKeys_, StzLower(paList[_iHkx_][1]))
	next

	_aHkxResult_ = []
	_nHkxKeysLen_ = len(pacKeys)

	for _jHkx_ = 1 to _nHkxKeysLen_
		if find(_acHkxAllKeys_, StzLower(pacKeys[_jHkx_])) > 0
			add(_aHkxResult_, TRUE)
		else
			add(_aHkxResult_, FALSE)
		ok
	next

	return _aHkxResult_


	func @HasKeysXT(paList, pacKeys)
		return HasKeysXT(paList, pacKeys)

	def ContainsKeysXT(paList, pacKeys)
		return HasKeysXT(paList, pacKeys)

	def @ContainsKeysXT(paList, pacKeys)
		return HasKeysXT(paList, pacKeys)

#--

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
	cKey = StzLower(cKey)
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
	@aContent = []
	@pEngineMap = NULL

	  #--------------#
	 #     INIT     #
	#--------------#

	def init(p)

		if CheckParams()
			if NOT ( isList(p) and @IsHashList(p) )
				StzRaise("Can't create the stzHashList object! You must provide a well formed hashlist.")
			ok
		ok

		_nInitLen_ = ring_len(p)
		for _iInit_ = 1 to _nInitLen_
			p[_iInit_][1] = StzLower(p[_iInit_][1])
		next

		@aContent = p

		if KeepingHistory() = 1
			This.AddHistoricValue(This.Content())
		ok

	  #===============================#
	 #   ENGINE HASHMAP HELPERS     #
	#===============================#

	def _EnsureEngineMap()
		if @pEngineMap != NULL
			return
		ok

		@pEngineMap = StzEngineHashMapNew()
		if @pEngineMap = NULL
			return
		ok

		_aEmContent_ = @aContent
		_nEmLen_ = ring_len(_aEmContent_)

		for _iEm_ = 1 to _nEmLen_
			_cEmKey_ = _aEmContent_[_iEm_][1]
			_vEmVal_ = _aEmContent_[_iEm_][2]

			if isString(_vEmVal_)
				StzEngineHashMapPutString(@pEngineMap, _cEmKey_, _vEmVal_)
			but isNumber(_vEmVal_)
				if isInteger(_vEmVal_)
					StzEngineHashMapPutInt(@pEngineMap, _cEmKey_, _vEmVal_)
				else
					StzEngineHashMapPutFloat(@pEngineMap, _cEmKey_, _vEmVal_)
				ok
			else
				StzEngineHashMapPutString(@pEngineMap, _cEmKey_, @@(_vEmVal_))
			ok
		next

	def _InvalidateEngineMap()
		if @pEngineMap != NULL
			StzEngineHashMapFree(@pEngineMap)
			@pEngineMap = NULL
		ok

	  #-------------#
	 #     GET     #
	#-------------#

	def Content()
		return @aContent

	def HashList()
		return This.Content()

	def NumberOfPairs()
		# Engine fast path: stz_hashmap_len is O(1) cached vs Ring ring_len() on a hashlist array
		This._EnsureEngineMap()
		if @pEngineMap != NULL
			return StzEngineHashMapLen(@pEngineMap)
		ok
		return ring_len(This.Content())

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
			if isList(pcReturnType) and IsOneOfTheseNamedParamsList(pcReturnType,[ :ReturnedAs, :ReturnAs ])
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
		_aHkContent_ = This.Content()
		_nHkLen_ = ring_len(_aHkContent_)

		_aHkResult_ = []

		for _iHk_ = 1 to _nHkLen_
			@AddItem(_aHkResult_, _aHkContent_[_iHk_][1])
		next

		return _aHkResult_

		def KeysQ()
			return This.KeysQRT(:stzList)

		def KeysQRT(pcReturnType)
			if isList(pcReturnType) and IsOneOfTheseNamedParamsList(pcReturnType,[ :ReturnedAs, :ReturnAs ])
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
		_aKfvContent_ = This.Content()
		_nKfvLen_ = ring_len(_aKfvContent_)

		_aKfvResult_ = []

		for _iKfv_ = 1 to _nKfvLen_
			_aKfvPair_ = _aKfvContent_[_iKfv_]
			if Q(_aKfvPair_[2]).IsStrictlyEqualTo(pValue)
				@AddItem(_aKfvResult_, _aKfvPair_[1])
			ok
		next

		return _aKfvResult_

		#< @FunctionFluentForms

		def KeysForValueQ()
			return This.KeysForValueQRT(:stzList)

		def KeysForValueQRT(pcReturnType)
			if isList(pcReturnType) and IsOneOfTheseNamedParamsList(pcReturnType,[ :ReturnedAs, :ReturnAs ])
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

		_aVlContent_ = This.Content()
		_aVlResult_ = []
		_nVlLen_ = This.NumberOfPairs()

		for _iVl_ = 1 to _nVlLen_
			@AddItem(_aVlResult_, _aVlContent_[_iVl_][2])
		next

		return _aVlResult_

		def ValuesQ()
			return This.ValuesQRT(:stzList)

		def ValuesQRT(pcReturnType)
			if isList(pcReturnType) and StzListIsOneOfTheseNamedParamsList(pcReturnType,[ :ReturnedAs, :ReturnAs ])
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

		_aValsContent_ = This.Content()
		_nValsLen_ = This.NumberOfValues()

		if _nValsLen_ = 1
			return 1
		ok

		_nValsSize_ = ring_len(_aValsContent_[1][2])
		_bValsResult_ = 1

		for _iVals_ = 2 to _nValsLen_
			if ring_len(_aValsContent_[_iVals_][2]) != _nValsSize_
				_bValsResult_ = 0
				exit
			ok
		next

		return _bValsResult_

	def ValuesAndKeys()
		_aVakValues_ = This.Values()
		_nVakLen_ = ring_len(_aVakValues_)

		_aVakResult_ = []

		for _iVak_ = 1 to _nVakLen_
			@AddItem(_aVakResult_, [ _aVakValues_[_iVak_], This.NthKey(_iVak_) ])
		next

		return _aVakResult_

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

		_nNvLen_ = ring_len(This.Content())
		if n > _nNvLen_ or n < 1
			StzRaise("Can't access item " + n + " in the hashlist! The hashlist contains only " + _nNvLen_ + "pairs.")
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
		# Ring's hashlist[key] indexer is the canonical fast path -- it does
		# a single C lookup on the underlying VM hash table. The engine
		# StzEngineHashMapGet* path is kept for type-coerced reads via
		# ValueIntByKey/ValueFloatByKey/ValueStringByKey helpers below.
		return This.Content()[ pcKey ]

	def ValueIntByKey(pcKey)
		This._EnsureEngineMap()
		if @pEngineMap != NULL
			return StzEngineHashMapGetInt(@pEngineMap, pcKey)
		ok
		return 0 + This.ValueByKey(pcKey)

	def ValueFloatByKey(pcKey)
		This._EnsureEngineMap()
		if @pEngineMap != NULL
			return StzEngineHashMapGetFloat(@pEngineMap, pcKey)
		ok
		return 0.0 + This.ValueByKey(pcKey)

	def ValueStringByKey(pcKey)
		This._EnsureEngineMap()
		if @pEngineMap != NULL
			return StzEngineHashMapGetString(@pEngineMap, pcKey)
		ok
		return "" + This.ValueByKey(pcKey)

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
		return ring_len(This.FindValue(pValue))

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
		_aUvResult_ = This.ValuesQ().DuplicatesRemoved()
		return _aUvResult_

		def ValuesU()
			return This.UniqueValues()

		def ValuesWithoutDuplication()
			return This.UniqueValues()

	def ValuesAtPositions(anPos)
		_aVapResult_ = This.ValuesQ().ItemsAtPositions(anPos)
		return _aVapResult_

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

			if NOT( isList(paNewHashList) and @IsHashList(paNewHashList) )
				StzRaise("Incorrect param type! paNewHashList must be a hashlist.")
			ok
		ok

		@aContent = paNewHashList
		This._InvalidateEngineMap()

		if KeepingHisto() = 1
			This.AddHistoricValue(This.Content())
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
			_nUpN_ = This.FindPair(paPair)

			This.UpdateNthKey(_nUpN_, paNewPair[1])
			This.UpdateNthValue(_nUpN_, paNewPair[2])
		else
			StzRaise("Key must be a string!")
		ok

	def UpdateNthKey(n, pcValue)
		if isList(n) and isNumber(pcValue)
			_unkTemp_ = n
			n = pcValue
			pcValue = _unkTemp_
		ok

		if n = :First
			n = 1
		but n = :Last
			n = This.NumberOfKeys()
		ok

		# Now, let's do the job

		_aUnkContent_ = This.Content()
		_aUnkContent_[n][1] = pcValue
		This.UpdateWith(_aUnkContent_)

	def UpdateKey(pcKey, pcNewKey)
		if isString(pcKey) and This.ContainsKey(pcKey)
			_aUkContent_ = This.Content()
			_nUkN_ = This.FindKey(pcKey)
			_aUkContent_[_nUkN_][1] = pcNewKey
			This.UpdateWith(_aUkContent_)
		ok

	def UpdateKeys(paKeys)
		_oUksList_ = new stzList(paKeys)
		if _oUksList_.ItemsAreAllStrings()
			for _iUks_ = 1 to @Min([ ring_len(paKeys), This.NumberOfPairs() ])
				This.UpdateNthKey(_iUks_, paKeys[_iUks_])
			next _iUks_
		ok

	def UpdateNthValue(n, pValue)

		if n = :First
			n = 1
		but n = :Last
			n = This.NumberOfValues()
		ok

		_aUnvContent_ = This.Content()
		_aUnvContent_[n][2] = pValue
		This.UpdateWith(_aUnvContent_)

		def UpdateNthOccurrenceOfValue(pValue)
			This.UpdateNthValue( This.FindNthOccurrenceOfValue(pValue) )

	def UpdateValues(paValues)
		for _iUvs_ = 1 to @Min([ ring_len(paValues), This.NumberOfPairs() ])
			This.UpdateNthValue(_iUvs_, paValues[_iUvs_])
		next

	def UpdateValue(pValue, pNewValue)
		_anUvPos_ = This.FindValue(pValue)
		_nUvLen_ = ring_len(_anUvPos_)

		for _iUv_ = 1 to _nUvLen_
			This.UpdateNthValue(_anUvPos_[_iUv_], pNewValue)
		next
	
	def UpdateFirstOccurrenceOfValue(pValue, pNewValue)
		This.UpdateNthOccurrenceOfValue(1, pValue, pNewValue)

		def UpdateFirstValue(pValue, pNewValue)
			This.UpdateFirstOccurrenceOfValue(pValue, pNewValue)
		
	def UpdateLastValue(pValue, pNewValue)
		_nUlvN_ = NumberOfOccurrenceOfValue(pValue)
		This.UpdateNthValue(_nUlvN_, pValue, pNewValue)

	def UpdateAllPairsWith(paPair)
		if CheckingParams()
			if not isList(paPair)
				StzRaise("Incorrect param type! paPair must be a list.")
			ok

			if Not @IsPairAndKeyIsString(paPair)
				StzRaise("Incorrect param type! paPair must be a pair and its first item must be a string.")
			ok
		ok

		_aUapContent_ = This.Content()
		_nUapLen_ = ring_len(_aUapContent_)

		for _iUap_ = 1 to _nUapLen_
			_aUapContent_[_iUap_] = paPair
		next

		This.UpdateWith(_aUapContent_)

	  #-----------------------------#
	 #  REVERSING KEYS AND VALUES  #
	#-----------------------------#

	def ReverseKeysAndValues()

		_aRkvKeys_ = This.Keys()
		_aRkvValues_ = This.Values()
		_nRkvLen_ = This.NumberOfPairs()

		_oRkvCopy_ = This.Copy()

		for _iRkv_ = 1 to _nRkvLen_
			_oRkvCopy_.UpdateNthKey( _iRkv_, "" + _aRkvValues_[_iRkv_] )
			_oRkvCopy_.UpdateNthValue( _iRkv_, _aRkvKeys_[_iRkv_] )
		next

		This.UpdateWith( _oRkvCopy_.Content() )

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

			_aApContent_ = This.Content()
			@AddItem(_aApContent_, paNewPair)

			This.UpdateWith(_aApContent_)

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
		_nApsLen_ = ring_len(paListOfPairs)
		for _iAps_ = 1 to _nApsLen_
			This.AddPair(paListOfPairs[_iAps_])
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
			This._InvalidateEngineMap()
		ok

		def InsertBeforeQ(n, paPair)
			This.InsertBefore(n, paPair)
			return This

	def InsertAfter(n, paPair)
		insert( This.HashList, n, paPair)
		This._InvalidateEngineMap()

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

		_aRnpContent_ = This.Content()
		del(_aRnpContent_, n)
		This.UpdateWith(_aRnpContent_)

		def RemoveNthPairQ(n)
			This.RemovePair(n)
			return This

	def RemovePair(paPair)
		_oRpList_ = new stzList( This.HashList() )
		_aRpResult_ = _oRpList_.RemoveQ(paPair).Content()
		This.Update(_aRpResult_)

		def RemovePairQ(paPair)
			This.RemovePair(paPair)
			return This
		
	def RemovePairByKey(pcKey)
		_nRpbkN_ = This.FindKey(pcKey)
		if _nRpbkN_ > 0
			del( This.HashList(), _nRpbkN_)
			This._InvalidateEngineMap()
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

		_nRpbksLen_ = ring_len(pacKeys)

		for _iRpbks_ = 1 to _nRpbksLen_
			This.RemovePairByKey(pacKeys[_iRpbks_])
		next

	def RemovePairsByValue(pValue)
		_anRpbvPos_ = This.FindValue(pValue)

		_aRpbvResult_ = StzListQ( This.HashList() ).RemoveItemsAtThesePositionsQ( _anRpbvPos_ ).Content()
		This.Update(_aRpbvResult_)

		def RemovePairsByValueQ(pValue)
			This.RemovePairsByValue(pValue)
			return This

	def RemovePairsByValues(paValues)
		if CheckingParams()
			if NOT isList(paValues)
				StzRaise("Incorrect param type! paValues must be a list.")
			ok
		ok

		_nRpbvsLen_ = ring_len(paValues)

		for _iRpbvs_ = 1 to _nRpbvsLen_
			This.RemovePairsByValue(paValues[_iRpbvs_])
		next

	  #------------------#
	 #  REPLACING KEYS  #
	#==================#

	def ReplaceKey(pcKey, pcNewKey)
		_nRkN_ = This.FindKey(pcKey)
		This.ReplaceNthKey(_nRkN_, pcNewKey)

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
		This._InvalidateEngineMap()

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
		_nRvN_ = This.FindValue(pValue)
		This.ReplaceNthValue(_nRvN_, pNewValue)

		def ReplaceValueQ(pValue, pNewValue)
			This.ReplaceValue(pValue, pNewValue)
			return this

	def ReplaceNthValue(n, pNewValue)

		if CheckingParam()
			if NOT isNumber(n) and isNumber(pNewValue)
				_rnvTemp_ = n
				n = pNewValue
				pNewValue = _rnvTemp_
			ok

			if isList(pNewValue) and Q(pNewValue).IsWithOrByNamedParam()
				pNewValue = pNewValue[2]
			ok
		ok

		if NOT isNumber(n)
			StzRaise("Incorrect param type! n must be a number.")
		ok

		This.NthPair(n)[2] = pNewValue
		This._InvalidateEngineMap()

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
		_nRvkN_ = This.FindKey(pcKey)
		This.HashList()[_nRvkN_][2] = pNewValue
		This._InvalidateEngineMap()

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
		_nRpN_ = This.FindPair(paPair)
		This.ReplaceNthPair(_nRpN_, paNewPair)

		def ReplacePairQ(paPair, paNewPair)
			This.ReplacePair(paPair, paNewPair)
			return This

	def ReplacePairByKey(pcKey, paNewPair)
		_nRpbkN_ = This.FindKey(pcKey)
		This.ReplaceNthPair(_nRpbkN_, paNewPair)
	
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
		_aFksResult_ = This.KeysQ().FindMany(pacKeys)
		return _aFksResult_

		def FindTheseKeys(pacKeys)
			return This.FindKeys(pacKeys)

	def FindKey(pcKey)

		if isString(pcKey)
			This._EnsureEngineMap()
			if @pEngineMap != NULL
				return StzEngineHashMapFindKey(@pEngineMap, pcKey)
			ok
			return StzFind( Keys(), pcKey)
		ok

		def FindThisKey(pcKey)
			return This.FindKey(pcKey)

	def HasKey(pcKey)

		if isString(pcKey)
			This._EnsureEngineMap()
			if @pEngineMap != NULL
				return StzEngineHashMapHasKey(@pEngineMap, pcKey)
			ok
			if This.FindKey(pcKey) > 0
				return 1
			ok
		ok
		return 0

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

		_aFpContent_ = This.Content()
		_nFpLen_ = ring_len(_aFpContent_)

		_nFpResult_ = 0

		for _iFp_ = 1 to _nFpLen_
			_aFpPair_ = _aFpContent_[_iFp_]
			if Q(_aFpPair_[1]).IsEqualTo(paPair[1]) and
			   Q(_aFpPair_[2]).IsEqualTo(paPair[2])

				_nFpResult_ = _iFp_
				exit
			ok
		next
		return _nFpResult_


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

		if ring_len( This.FindValueCS(pValue, pCaseSensitive) ) > 0
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
		_bCvsResult_ = This.ValuesQ().ContainsManyCS(paValues, pCaseSensitive)
		return _bCvsResult_

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
		_anFvcsResult_ = This.ValuesQ().FindAllCS(pValue, pCaseSensitive)
		return _anFvcsResult_

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

		def FindValueOrItem(pValue)
			# Match both: value == pValue, or value is a list that
			# contains pValue as one of its items. Returns the keys'
			# positions sorted ascending.
			_anFvoiResult_ = []
			_aVals_ = This.Values()
			_nLen_ = ring_len(_aVals_)
			for _iFvoi_ = 1 to _nLen_
				_xVal_ = _aVals_[_iFvoi_]
				if _xVal_ = pValue
					_anFvoiResult_ + _iFvoi_
				but isList(_xVal_) and ring_find(_xVal_, pValue) > 0
					_anFvoiResult_ + _iFvoi_
				ok
			next
			return _anFvoiResult_

		def FindVitem(pValue)
			return This.FindValueOrItem(pValue)

		#>

	  #-------------------------#
	 #   FINDING MANY VALUES   #
	#-------------------------#

	def FindValuesCS(paValues, pCaseSensitive)

		_anFvsResult_ = This.ValuesQ().FindManyCS(paValues, pCaseSensitive)
		return _anFvsResult_

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

		_aFkbvContent_ = This.HashList()
		_nFkbvLen_ = ring_len(_aFkbvContent_)

		_anFkbvResult_ = []

		for _iFkbv_ = 1 to _nFkbvLen_

			if Q(_aFkbvContent_[_iFkbv_][2]).Contains(pValue)
				@AddItem(_anFkbvResult_, _iFkbv_)
			ok
		next

		return _anFkbvResult_

	  #------------------------------#
	 #   FINDING NTH KEY BY VALUE   #TODO // Add case sensitivity
	#------------------------------#

	def FindNthKeyByValue(n, pValue)
		# FindKeysByValue searches INSIDE list-valued entries via .Contains,
		# but ContainsValue compares the whole value -- so guarding on
		# ContainsValue would always return 0 for sub-item lookups.
		# Guard directly on the result of FindKeysByValue instead.
		_nFnkbvResult_ = 0
		_anFnkbvPos_ = This.FindKeysByValue(pValue)
		if ring_len(_anFnkbvPos_) >= n
			_nFnkbvResult_ = _anFnkbvPos_[n]
		ok
		return _nFnkbvResult_

	  #--------------------------------#
	 #   FINDING FIRST KEY BY VALUE   #TODO // Add case sensitivity
	#--------------------------------#

	def FindFirstKeyByValue(pValue)
		_nFfkbvResult_ = 0
		_anFfkbvPos_ = This.FindKeysByValue(pValue)
		if ring_len(_anFfkbvPos_) > 0
			_nFfkbvResult_ = _anFfkbvPos_[1]
		ok
		return _nFfkbvResult_

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
		_cFlkbvResult_ = ""
		for _iFlkbv_ = This.NumberOfPairs() to 1 step -1
			if Q(This.Value(_iFlkbv_)).IsEqualTo(pValue)
				_cFlkbvResult_ = This.Key(_iFlkbv_)
				exit
			ok
		next _iFlkbv_
		return _cFlkbvResult_

	  #----------------------------------------------------#
	 #   GETTING THE KEY CORRESPONDING TO A GIVEN VALUE   #TODO // Add case sensitivity
	#----------------------------------------------------#

	def KeyByValue(pValue)
		_acKbvKeys_ = This.KeysByValue(pValue)
		_nKbvLen_ = ring_len(_acKbvKeys_)

		if _nKbvLen_ = 0
			return ""
		ok

		_cKbvResult_ = _acKbvKeys_[1]
		return _cKbvResult_
	
	  #-----------------------------------------------------#
	 #   GETTING THE KEYS CORRESPONDING TO A GIVEN VALUE   #TODO // Add case sensitivity
	#-----------------------------------------------------#

	def KeysByValue(pValue)
		_anKsbvPos_ = This.FindKeysByValue(pValue)
		_acKsbvResult_ = This.KeysAtPositions(_anKsbvPos_)

		return _acKsbvResult_

	  #---------------------------------------------------------#
	 #  GETTING THE KEYS CORRESPONDING TO THE PROVIDED VALUES  #
	#---------------------------------------------------------#

	def KeysByValues(paValues)
		_nKsbvsLen_ = ring_len(paValues)

		_acKsbvsKeys_ = []

		for _iKsbvs_ = 1 to _nKsbvsLen_
			@AddItem(_acKsbvsKeys_, This.KeysByValue(paValues[_iKsbvs_]))
		next

		_acKsbvsResult_ = StzListQ(_acKsbvsKeys_).MergeQ().WithoutDuplicates()

		return _acKsbvsResult_

	  #----------------------------------------------#
	 #  GETTING THE KEYS AT THE PROVIDED POSITIONS  #
	#==============================================#

	def KeysAtPositions(panPos)
		_acKapResult_ = This.KeysQ().ItemsAtPositions(panPos)
		return _acKapResult_

		def KeysAtThesePositions(panPos)
			return This.KeysAtPositions(panPos)

	  #-----------------------------------------#
	 #  FINDING LISTS (VALUES THAT ARE LISTS)  #
	#=========================================#
	#TODO // Add case sensitivity

	def FindLists()
		_aFlContent_ = This.Content()
		_nFlLen_ = ring_len(_aFlContent_)

		_anFlResult_ = []

		for _iFl_ = 1 to _nFlLen_
			if isList(_aFlContent_[_iFl_][2])
				@AddItem(_anFlResult_, _iFl_)
			ok
		next

		return _anFlResult_

	def FindNonLists()
		# Return the positions whose value is NOT a list.
		# (Previous impl used `Q(1:N) - These(...)` which depends on
		# a `-` operator overload that doesn't exist on stzList in
		# the modular build. Direct walk is both simpler and faster.)
		_anFnlListPos_ = This.FindLists()
		_aFnlContent_ = This.Content()
		_nFnlLen_ = ring_len(_aFnlContent_)
		_anFnlR_ = []
		for _iFnl_ = 1 to _nFnlLen_
			if ring_find(_anFnlListPos_, _iFnl_) = 0
				_anFnlR_ + _iFnl_
			ok
		next
		return _anFnlR_

	def Lists()
		_aLsContent_ = This.Content()
		_nLsLen_ = ring_len(_aLsContent_)

		_aLsResult_ = []

		for _iLs_ = 1 to _nLsLen_
			if isList(_aLsContent_[_iLs_][2])
				@AddItem(_aLsResult_, _aLsContent_[_iLs_][2])
			ok
		next

		return _aLsResult_

	def ListsZ()
		_aLszU_ = U( This.Lists() )
		_nLszLen_ = ring_len(_aLszU_)

		_aLszResult_ = []

		for _iLsz_ = 1 to _nLszLen_
			@AddItem(_aLszResult_, [ _aLszU_[_iLsz_], This.FindList(_aLszU_[_iLsz_]) ])
		next

		return _aLszResult_

	def FindList(paList) # Add case sensitivity

		if CheckingParams()
			if NOT isList(paList)
				StzRaise("Incorrect param type! paList must be a list.")
			ok
		ok

		_anFlsPos_ = Q(This.Lists()).Find(paList)
		_anFlsResult_ = []
		if ring_len(_anFlsPos_) > 0
			_anFlsResult_ = Q(This.FindLists()).ItemsAtPositions(_anFlsPos_)
		ok

		return _anFlsResult_

	def ListZ(paList)
		if CheckingParams()
			if NOT isList(paList)
				StzRaise("Incorrect param type! paList must be a list.")
			ok
		ok

		_anLzPos_ = This.FindList(paList)
		_aLzResult_ = [ paList, _anLzPos_ ]
		return _aLzResult_

	def FindTheseLists(paLists)
		if CheckingParams()
			if NOT ( isList(paLists) and Q(paLists).IsListOfLists() )
				StzRaise("Incorrect param type! paLists must be a list of lists.")
			ok
		ok

		paLists = U(paLists) # Duplicates removed
		_nFtlLen_ = ring_len(paLists)
		_anFtlResult_ = []

		for _iFtl_ = 1 to _nFtlLen_
			_anFtlPos_ = This.FindList(paLists[_iFtl_])
			_nFtlLenPos_ = ring_len(_anFtlPos_)

			for _jFtl_ = 1 to _nFtlLenPos_
				@AddItem(_anFtlResult_, _anFtlPos_[_jFtl_])
			next
		next

		_oTmpSort_ = new stzList(_anFtlResult_)
		_anFtlResult_ = _oTmpSort_.Sorted()
		return _anFtlResult_

	def TheseListsZ(paLists)
		if CheckingParams()
			if NOT ( isList(paLists) and Q(paLists).IsListOfLists() )
				StzRaise("Incorrect param type! paLists must be a list of lists.")
			ok
		ok

		_nTlzLen_ = ring_len(paLists)
		_aTlzResult_ = []

		for _iTlz_ = 1 to _nTlzLen_
			@AddItem(_aTlzResult_, [ paLists[_iTlz_], This.FindList(paLists[_iTlz_]) ])
		next

		return _aTlzResult_

	#--

	  #---------------------------------------------#
	 #  FINDING NUMBERS (VALUES THAT ARE NUMBERS)  #
	#=============================================#
	#TODO // Add case sensitivity

	def FindNumbers()
		_aFnContent_ = This.Content()
		_nFnLen_ = ring_len(_aFnContent_)

		_anFnResult_ = []

		for _iFn_ = 1 to _nFnLen_
			if isNumber(_aFnContent_[_iFn_][2])
				@AddItem(_anFnResult_, _iFn_)
			ok
		next

		return _anFnResult_

	def Numbers()
		_aNsContent_ = This.Content()
		_nNsLen_ = ring_len(_aNsContent_)

		_aNsResult_ = []

		for _iNs_ = 1 to _nNsLen_
			if isNumber(_aNsContent_[_iNs_][2])
				@AddItem(_aNsResult_, _aNsContent_[_iNs_][2])
			ok
		next

		return _aNsResult_

	def NumbersZ()
		_aNszU_ = U( This.Numbers() )
		_nNszLen_ = ring_len(_aNszU_)

		_aNszResult_ = []

		for _iNsz_ = 1 to _nNszLen_
			@AddItem(_aNszResult_, [ _aNszU_[_iNsz_], This.FindNumber(_aNszU_[_iNsz_]) ])
		next

		return _aNszResult_

	def FindNumber(paNumber) # Add case sensitivity

		if CheckingParams()
			if NOT isNumber(paNumber)
				StzRaise("Incorrect param type! paNumber must be a list.")
			ok
		ok

		_anFnbPos_ = Q(This.Numbers()).Find(paNumber)
		_anFnbResult_ = []
		if ring_len(_anFnbPos_) > 0
			_anFnbResult_ = Q(This.FindNumbers()).ItemsAtPositions(_anFnbPos_)
		ok

		return _anFnbResult_

	def NumberZ(paNumber)
		if CheckingParams()
			if NOT isNumber(paNumber)
				StzRaise("Incorrect param type! paNumber must be a list.")
			ok
		ok

		_anNzPos_ = This.FindNumber(paNumber)
		_aNzResult_ = [ paNumber, _anNzPos_ ]
		return _aNzResult_

	def FindTheseNumbers(paNumbers)
		if CheckingParams()
			if NOT ( isNumber(paNumbers) and Q(paNumbers).IsNumberOfNumbers() )
				StzRaise("Incorrect param type! paNumbers must be a list of lists.")
			ok
		ok

		paNumbers = U(paNumbers) # Duplicates removed
		_nFtnLen_ = ring_len(paNumbers)
		_anFtnResult_ = []

		for _iFtn_ = 1 to _nFtnLen_
			_anFtnPos_ = This.FindNumber(paNumbers[_iFtn_])
			_nFtnLenPos_ = ring_len(_anFtnPos_)

			for _jFtn_ = 1 to _nFtnLenPos_
				@AddItem(_anFtnResult_, _anFtnPos_[_jFtn_])
			next
		next

		_oTmpSort_ = new stzList(_anFtnResult_)
		_anFtnResult_ = _oTmpSort_.Sorted()
		return _anFtnResult_

	def TheseNumbersZ(paNumbers)
		if CheckingParams()
			if NOT ( isNumber(paNumbers) and Q(paNumbers).IsNumberOfNumbers() )
				StzRaise("Incorrect param type! paNumbers must be a list of lists.")
			ok
		ok

		_nTnzLen_ = ring_len(paNumbers)
		_aTnzResult_ = []

		for _iTnz_ = 1 to _nTnzLen_
			@AddItem(_aTnzResult_, [ paNumbers[_iTnz_], This.FindNumber(paNumbers[_iTnz_]) ])
		next

		return _aTnzResult_

	  #--------------------------------------------#
	 #  FINDING STRINGS (VALUES THAT ARE STRING)  #
	#============================================#
	#TODO // Add case sensitivity

	def FindStrings()
		_aFsContent_ = This.Content()
		_nFsLen_ = ring_len(_aFsContent_)

		_anFsResult_ = []

		for _iFs_ = 1 to _nFsLen_
			if isString(_aFsContent_[_iFs_][2])
				@AddItem(_anFsResult_, _iFs_)
			ok
		next

		return _anFsResult_

	def Strings()
		_aSsContent_ = This.Content()
		_nSsLen_ = ring_len(_aSsContent_)

		_aSsResult_ = []

		for _iSs_ = 1 to _nSsLen_
			if isString(_aSsContent_[_iSs_][2])
				@AddItem(_aSsResult_, _aSsContent_[_iSs_][2])
			ok
		next

		return _aSsResult_

	def StringsZ()
		_aSszU_ = U( This.Strings() )
		_nSszLen_ = ring_len(_aSszU_)

		_aSszResult_ = []

		for _iSsz_ = 1 to _nSszLen_
			@AddItem(_aSszResult_, [ _aSszU_[_iSsz_], This.FindString(_aSszU_[_iSsz_]) ])
		next

		return _aSszResult_

	def FindString(paString) # Add case sensitivity

		if CheckingParams()
			if NOT isString(paString)
				StzRaise("Incorrect param type! paString must be a list.")
			ok
		ok

		_anFsbPos_ = Q(This.Strings()).Find(paString)
		_anFsbResult_ = []
		if ring_len(_anFsbPos_) > 0
			_anFsbResult_ = Q(This.FindStrings()).ItemsAtPositions(_anFsbPos_)
		ok

		return _anFsbResult_

	def StringZ(paString)
		if CheckingParams()
			if NOT isString(paString)
				StzRaise("Incorrect param type! paString must be a list.")
			ok
		ok

		_anSzPos_ = This.FindString(paString)
		_aSzResult_ = [ paString, _anSzPos_ ]
		return _aSzResult_

	def FindTheseStrings(paStrings)
		if CheckingParams()
			if NOT ( isString(paStrings) and Q(paStrings).IsStringOfStrings() )
				StzRaise("Incorrect param type! paStrings must be a list of lists.")
			ok
		ok

		paStrings = U(paStrings) # Duplicates removed
		_nFtsLen_ = ring_len(paStrings)
		_anFtsResult_ = []

		for _iFts_ = 1 to _nFtsLen_
			_anFtsPos_ = This.FindString(paStrings[_iFts_])
			_nFtsLenPos_ = ring_len(_anFtsPos_)

			for _jFts_ = 1 to _nFtsLenPos_
				@AddItem(_anFtsResult_, _anFtsPos_[_jFts_])
			next
		next

		_oTmpSort_ = new stzList(_anFtsResult_)
		_anFtsResult_ = _oTmpSort_.Sorted()
		return _anFtsResult_

	def TheseStringsZ(paStrings)
		if CheckingParams()
			if NOT ( isString(paStrings) and Q(paStrings).IsStringOfStrings() )
				StzRaise("Incorrect param type! paStrings must be a list of lists.")
			ok
		ok

		_nTszLen_ = ring_len(paStrings)
		_aTszResult_ = []

		for _iTsz_ = 1 to _nTszLen_
			@AddItem(_aTszResult_, [ paStrings[_iTsz_], This.FindString(paStrings[_iTsz_]) ])
		next

		return _aTszResult_

	  #---------------------------------------------#
	 #  FINDING OBJECTS (VALUES THAT ARE OBJECTS)  #
	#=============================================#
	#TODO // Add case sensitivity

	def FindObjects()
		_aFoContent_ = This.Content()
		_nFoLen_ = ring_len(_aFoContent_)

		_anFoResult_ = []

		for _iFo_ = 1 to _nFoLen_
			if isObject(_aFoContent_[_iFo_][2])
				@AddItem(_anFoResult_, _iFo_)
			ok
		next

		return _anFoResult_

	def Objects()
		_aOsContent_ = This.Content()
		_nOsLen_ = ring_len(_aOsContent_)

		_aOsResult_ = []

		for _iOs_ = 1 to _nOsLen_
			if isObject(_aOsContent_[_iOs_][2])
				@AddItem(_aOsResult_, _aOsContent_[_iOs_][2])
			ok
		next

		return _aOsResult_

	  #------------------------------------------------------#
	 #  FINDING STZLISTS (VALUES THAT ARE STZLIST OBJECTS)  #
	#======================================================#
	#TODO // Add case sensitivity

	def FindStzLists()
		_aFszlContent_ = This.Content()
		_nFszlLen_ = ring_len(_aFszlContent_)

		_anFszlResult_ = []

		for _iFszl_ = 1 to _nFszlLen_
			if @IsStzList(_aFszlContent_[_iFszl_][2])
				@AddItem(_anFszlResult_, _iFszl_)
			ok
		next

		return _anFszlResult_

	def StzLists()
		_aSzlContent_ = This.Content()
		_nSzlLen_ = ring_len(_aSzlContent_)

		_aSzlResult_ = []

		for _iSzl_ = 1 to _nSzlLen_
			if @IsStzList(_aSzlContent_[_iSzl_][2])
				@AddItem(_aSzlResult_, _aSzlContent_[_iSzl_][2])
			ok
		next

		return _aSzlResult_

	  #-------------------------------------------------------#
	 #  FINDING STZHASHLISTS (VALUES THAT ARE STZHASHLISTS)  #
	#=======================================================#
	#TODO // Add case sensitivity

	def FindStzHashLists()
		_aFszhlContent_ = This.Content()
		_nFszhlLen_ = ring_len(_aFszhlContent_)

		_anFszhlResult_ = []

		for _iFszhl_ = 1 to _nFszhlLen_
			if @IsStzHashList(_aFszhlContent_[_iFszhl_][2])
				@AddItem(_anFszhlResult_, _iFszhl_)
			ok
		next

		return _anFszhlResult_

	def StzHashLists()
		_aSzhlContent_ = This.Content()
		_nSzhlLen_ = ring_len(_aSzhlContent_)

		_aSzhlResult_ = []

		for _iSzhl_ = 1 to _nSzhlLen_
			if @IsStzHashList(_aSzhlContent_[_iSzhl_][2])
				@AddItem(_aSzhlResult_, _aSzhlContent_[_iSzhl_][2])
			ok
		next

		return _aSzhlResult_

	  #---------------------------------------------------#
	 #  FINDING STZNUMBERS (VALUES THAT ARE STZNUMBERS)  #
	#===================================================#
	#TODO // Add case sensitivity

	def FindStzNumbers()
		_aFsznContent_ = This.Content()
		_nFsznLen_ = ring_len(_aFsznContent_)

		_anFsznResult_ = []

		for _iFszn_ = 1 to _nFsznLen_
			if @IsStzNumber(_aFsznContent_[_iFszn_][2])
				@AddItem(_anFsznResult_, _iFszn_)
			ok
		next

		return _anFsznResult_

	def StzNumbers()
		_aSznContent_ = This.Content()
		_nSznLen_ = ring_len(_aSznContent_)

		_aSznResult_ = []

		for _iSzn_ = 1 to _nSznLen_
			if @IsStzNumber(_aSznContent_[_iSzn_][2])
				@AddItem(_aSznResult_, _aSznContent_[_iSzn_][2])
			ok
		next

		return _aSznResult_

	  #---------------------------------------------------#
	 #  FINDING STZSTRINGS (VALUES THAT ARE STZSTRINGS)  #
	#===================================================#
	#TODO // Add case sensitivity

	def FindStzStrings()
		_aFszsContent_ = This.Content()
		_nFszsLen_ = ring_len(_aFszsContent_)

		_anFszsResult_ = []

		for _iFszs_ = 1 to _nFszsLen_
			if @IsStzString(_aFszsContent_[_iFszs_][2])
				@AddItem(_anFszsResult_, _iFszs_)
			ok
		next

		return _anFszsResult_

	def StzStrings()
		_aSzsContent_ = This.Content()
		_nSzsLen_ = ring_len(_aSzsContent_)

		_aSzsResult_ = []

		for _iSzs_ = 1 to _nSzsLen_
			if @IsStzString(_aSzsContent_[_iSzs_][2])
				@AddItem(_aSzsResult_, _aSzsContent_[_iSzs_][2])
			ok
		next

		return _aSzsResult_

	  #---------------------------------------------------#
	 #  FINDING STZOBJECTS (VALUES THAT ARE STZOBJECTS)  #
	#===================================================#
	#TODO // Add case sensitivity

	def FindStzObjects()
		_aFszoContent_ = This.Content()
		_nFszoLen_ = ring_len(_aFszoContent_)

		_anFszoResult_ = []

		for _iFszo_ = 1 to _nFszoLen_
			if @IsStzObject(_aFszoContent_[_iFszo_][2])
				@AddItem(_anFszoResult_, _iFszo_)
			ok
		next

		return _anFszoResult_

	def StzObjects()
		_aSzoContent_ = This.Content()
		_nSzoLen_ = ring_len(_aSzoContent_)

		_aSzoResult_ = []

		for _iSzo_ = 1 to _nSzoLen_
			if @IsStzObject(_aSzoContent_[_iSzo_][2])
				@AddItem(_aSzoResult_, _aSzoContent_[_iSzo_][2])
			ok
		next

		return _aSzoResult_

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

		_aCiContent_ = This.Content()
		_nCiLen_ = ring_len(_aCiContent_)

		_bCiResult_ = 0

		for _iCi_ = 1 to _nCiLen_

			if isList(_aCiContent_[_iCi_][2])

				_oCiList_ = new stzList(_aCiContent_[_iCi_][2])
				if _oCiList_.Contains(pItem)
					_bCiResult_ = 1
					exit
				ok
			ok

		next

		return _bCiResult_

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

		_aFiContent_ = This.Content()
		_nFiLen_ = ring_len(_aFiContent_)

		_aFiResult_ = []

		for _iFi_ = 1 to _nFiLen_

			if isList(_aFiContent_[_iFi_][2])

				_oFiList_ = new stzList(_aFiContent_[_iFi_][2])
				if _oFiList_.Contains(pItem)
					@AddItem(_aFiResult_, [ _iFi_, _oFiList_.FindAll(pItem) ])
				ok
			ok

		next

		return _aFiResult_

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

		_aFtiT1_ = This.TheseItemsZ(paItems)
		_nFtiLen1_ = ring_len(_aFtiT1_)

		# Step 2 : we  take the positions (pairs) and put them in a list

		_aFtiT2_ = []

		for _iFti1_ = 1 to _nFtiLen1_
			_aFtiPos1_ = _aFtiT1_[_iFti1_][2]
			_nFtiLenPos1_ = ring_len(_aFtiPos1_)

			for _jFti1_ = 1 to _nFtiLenPos1_
				@AddItem(_aFtiT2_, _aFtiPos1_[_jFti1_])
			next
		next

		# Step 2 : we factorise the obtained list to get the positions

		_nFtiLen2_ = ring_len(_aFtiT2_)
		_aFtiResult_ = []

		for _iFti2_ = 1 to _nFtiLen2_
			_nFtiLenPos2_ = ring_len(_aFtiT2_[_iFti2_][2])
			for _jFti2_ = 1 to _nFtiLenPos2_
				@AddItem(_aFtiResult_, [ _aFtiT2_[_iFti2_][1], _aFtiT2_[_iFti2_][2][_jFti2_] ])
			next
		next

		# Step 4 : we return the result

		return _aFtiResult_

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

		_nTizLen_ = ring_len(paItems)
		_aTizResult_ = []

		for _iTiz_ = 1 to _nTizLen_
			@AddItem(_aTizResult_, [ paItems[_iTiz_], This.FindItem(paItems[_iTiz_]) ])
		next

		return _aTizResult_

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

		_aItmResult_ = U( This.ValuesQ().OnlyListsQ().Merged() )
		return _aItmResult_

	def FindItems()

		_aFimIndex_ = This.Copy().ListifyQ().ValuesQRT(:stzListOfLists).IndexXT()

		_aFimItems_ = This.Items()
		_nFimLen_ = ring_len(_aFimIndex_)

		_aFimResult_ = []

		for _iFim_ = 1 to _nFimLen_
			_aFimPairs_ = _aFimIndex_[_iFim_][2]
			_nFimLenPairs_ = ring_len(_aFimPairs_)
			for _jFim_ = 1 to _nFimLenPairs_
				@AddItem(_aFimResult_, _aFimPairs_[_jFim_])
			next
		next

		return _aFimResult_

	def ItemsZ()

		_aItmzIndex_ = This.Copy().ListifyQ().ValuesQRT(:stzListOfLists).IndexXT()

		_aItmzItems_ = This.Items()
		_anItmzPos_ = QRT(_aItmzIndex_, :stzHashList).FindTheseKeys(_aItmzItems_)
		_nItmzLen_ = ring_len(_anItmzPos_)

		_aItmzResult_ = []
		for _iItmz_ = 1 to _nItmzLen_
			@AddItem(_aItmzResult_, _aItmzIndex_[_anItmzPos_[_iItmz_]])
		next

		return _aItmzResult_

	def NumberOfItems()
		return ring_len(This.Items())

	def ItemZ(pItem)
		_aItzResult_ = [ pItem, This.FindItem(pItem) ]
		return _aItzResult_

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

		_anFniPos_ = This.FindItem(pItem)
		_nFniLen_ = ring_len(_anFniPos_)

		_nFniResult_ = 0
		if _nFniLen_ > 0
			_nFniResult_ = _anFniPos_[n]
		ok

		return _nFniResult_

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
		_anFkbiPos_ = This.FindItemInList(pItem)
		_nFkbiLen_ = ring_len(_anFkbiPos_)

		_anFkbiResult_ = []

		for _iFkbi_ = 1 to _nFkbiLen_
			@AddItem(_anFkbiResult_, _anFkbiPos_[_iFkbi_])
		next

		return _anFkbiResult_

		def FindKeysByItemInList(pItem)
			return This.FindKeysByItem(pItem)

	def NumberOfKeysByItemInList(pValue) ### Fixed: was missing pValue param
		return ring_len( This.FindKeysByItemInList(pValue) )

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
		_nFlkbiN_ = This.NumberOfKeysByItemInList(pValue)

		if This.ContainsItemInList(pValue)
			return This.FindKeysByItemInList(pValue)[_nFlkbiN_]
		else
			return 0
		ok

		def FindLastKeyByItem(pValue)
			return This.FindLastKeyByItemInList(pValue)

	def KeyByItemInList(pValue)
		_nKbiN_ = This.FindKeyByItemInList(pValue)

		return This.Key( _nKbiN_ )

		def KeyByItem(pValue)
			return This.KeyByItemInList(pValue)

	def KeysByItemInList(pValue)
		_anKbiPos_ = This.FindKeysByItemInList(pValue) ### Fixed: was missing pValue arg
		_nKbiLen_ = ring_len(_anKbiPos_)

		_aKbiResult_ = []

		for _iKbi_ = 1 to _nKbiLen_
			@AddItem(_aKbiResult_, This.Key(_anKbiPos_[_iKbi_]))
		next

		return _aKbiResult_

		def KeysByItem(pValue)
			return This.KeysByItem(pValue)

	  #-----------------------------------------------#
	 #  LISTIFYING (ALL THE VALUES IN) THE HASHLIST  #
	#-----------------------------------------------#

	def Copy()
		_oCpCopy_ = new stzHashList(This.content())
		return _oCpCopy_

	def Listify()

		_aLfContent_ = This.Content()
		_nLfLen_ = ring_len(_aLfContent_)

		for _iLf_ = 1 to _nLfLen_
			if NOT isList(_aLfContent_[_iLf_][2])
				_aLfTemp_ = []
				@AddItem(_aLfTemp_, _aLfContent_[_iLf_][2])
				_aLfContent_[_iLf_][2] = _aLfTemp_
			ok
		next

		This.UpdateWith(_aLfContent_)


		def ListifyQ() #TODO // Ensure consistency in all library
			This.Listify()
			return This

	def Listified()
		_aLfdResult_ = This.Copy().ListifyQ().Content()
		return _aLfdResult_

	  #===========================#
	 #     CLASSIFYING VALUES    #
	#===========================#

	def Classify()

		_aCfResult_ = []
		_acCfClasses_ = This.Classes()
		_nCfLen_ = ring_len(_acCfClasses_)

		for _iCf_ = 1 to _nCfLen_
			@AddItem(_aCfResult_, [ _acCfClasses_[_iCf_], This.KeysForValue(_acCfClasses_[_iCf_]) ])
		next

		return _aCfResult_

		#< @FunctionFluentForm

		def ClassifyQ()
			return This.ClassifyQRT(pcReturnType)

		def ClassifyQRT(pcReturnType)
			if isList(pcReturnType) and StzListIsOneOfTheseNamedParamsList(pcReturnType,[ :ReturnedAs, :ReturnAs ])
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
		_acCsResult_ = []
		_aCsUnique_ = This.UniqueValues()
		_nCsLen_ = ring_len(_aCsUnique_)

		for _iCs_ = 1 to _nCsLen_
			@AddItem(_acCsResult_, Q(_aCsUnique_[_iCs_]).Stringified())
		next

		return _acCsResult_

		#< @FunctionFluentForm

		def ClassesQ()
			return This.ClassesQRT(:stzList)

		def ClassesQRT(pcReturnType)
			if isList(pcReturnType) and StzListIsOneOfTheseNamedParamsList(pcReturnType,[ :ReturnedAs, :ReturnAs ])
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
		_bCcResult_ = This.ContainsValueCS(pcClass, 0)
		return _bCcResult_

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
		_bCcsResult_ = This.ContainsValuesCS(pacClasses, 0)
		return _bCcsResult_

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
		return ring_len( This.CLasses() )

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

		_aKlResult_ = This.KeysForValue(pcClass)
		return _aKlResult_

		#< @FunctionFluentForms

		def KlassQ(pcClass)
			return This.KlassQRT(pClass, :stzList)

		def KlassQRT(pcClass, pcReturnType)
			if isList(pcReturnType) and StzListIsOneOfTheseNamedParamsList(pcReturnType,[ :ReturnedAs, :ReturnAs ])
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
		_nNvicResult_ = ring_len( This.Klass(pcClass) )
		return _nNvicResult_

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
		_acCssClasses_ = This.Classes()
		_nCssLen_ = ring_len(_acCssClasses_)

		_anCssResult_ = []

		for _iCss_ = 1 to _nCssLen_
			@AddItem(_anCssResult_, This.ClassSize(_acCssClasses_[_iCss_]))
		next

		return _anCssResult_

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
		_acCsxClasses_ = This.Classes()
		_nCsxLen_ = ring_len(_acCsxClasses_)

		_aCsxResult_ = []

		for _iCsx_ = 1 to _nCsxLen_
			@AddItem(_aCsxResult_, [ _acCsxClasses_[_iCsx_], This.ClassSize(_acCsxClasses_[_iCsx_]) ])
		next

		return _aCsxResult_

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

		_nTcsLen_ = ring_len(pacClasses)

		_anTcsResult_ = []

		for _iTcs_ = 1 to _nTcsLen_
			@AddItem(_anTcsResult_, This.ClassSize(pacClasses[_iTcs_]))
		next

		return _anTcsResult_

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

		_nTcsxLen_ = ring_len(pacClasses)

		_aTcsxResult_ = []

		for _iTcsx_ = 1 to _nTcsxLen_
			@AddItem(_aTcsxResult_, [ pacClasses[_iTcsx_], This.ClassSize(pacClasses[_iTcsx_]) ])
		next

		return _aTcsxResult_

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
		_nKfResult_ = This.NumberOfValuesInClass(pcClass) / This.NumberOfValues()
		return _nKfResult_

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
		_aKfxResult_ = [ pcClass, This.ClassFreq(pcClass) ]
		return _aKfxResult_

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
		_acCfsClasses_ = This.Classes()
		_nCfsLen_ = ring_len(_acCfsClasses_)

		_anCfsResult_ = []

		for _iCfs_ = 1 to _nCfsLen_
			@AddItem(_anCfsResult_, This.ClassFrequency(_acCfsClasses_[_iCfs_]))
		next

		return _anCfsResult_

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
		_acCfxClasses_ = This.Classes()
		_nCfxLen_ = ring_len(_acCfxClasses_)

		_aCfxResult_ = []

		for _iCfx_ = 1 to _nCfxLen_
			@AddItem(_aCfxResult_, [ _acCfxClasses_[_iCfx_], This.ClassFrequency(_acCfxClasses_[_iCfx_]) ])
		next

		return _aCfxResult_

		def KlassesFrequenciesXT()
			return This.ClassesFrequenciesXT()

		# ClassesXT (alias used by NStrongestClasses for `sort on freq`).
		# Returns [classname, frequency] pairs.
		def ClassesXT()
			return This.ClassesFreqsXT()

		def KlassesXT()
			return This.ClassesFreqsXT()

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

		_nTcfLen_ = ring_len(pacClasses)

		_anTcfResult_ = []

		for _iTcf_ = 1 to _nTcfLen_
			@AddItem(_anTcfResult_, This.ClassFrequency(pacClasses[_iTcf_]))
		next

		return _anTcfResult_

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

		_nTcfxLen_ = ring_len(pacClasses)

		_aTcfxResult_ = []

		for _iTcfx_ = 1 to _nTcfxLen_
			@AddItem(_aTcfxResult_, [ pacClasses[_iTcfx_], This.ClassFrequency(pacClasses[_iTcfx_]) ])
		next

		return _aTcfxResult_

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
		# Avoid `new stzList(...).Reversed()` chain (Ring 1.26 parses
		# the dot as binding to the arg expression, not the new
		# object, raising R13). Bind first.
		_oNscTmp_ = new stzList( SortListsOn( This.ClassesXT(), 2 ) )
		_aNscXT_ = _oNscTmp_.Reversed()
		_nNscLen_ = ring_len(_aNscXT_)

		n = @Min([ n, _nNscLen_ ])

		_aNscResult_ = []

		for _iNsc_ = 1 to n
			@AddItem(_aNscResult_, _aNscXT_[_iNsc_][1])
		next

		return _aNscResult_
		
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
		_oNscxTmp_ = new stzList( SortListsOn( This.ClassesXT(), 2 ) )
		_aNscxXT_ = _oNscxTmp_.Reversed()
		_nNscxLen_ = ring_len(_aNscxXT_)
		n = @Min([ n, _nNscxLen_ ])

		_aNscxResult_ = []

		for _iNscx_ = 1 to n
			@AddItem(_aNscxResult_, _aNscxXT_[_iNscx_])
		next

		return _aNscxResult_

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
		_aNwcXT_ = SortListsOn( ClassesXT(), 2 )
		_nNwcLen_ = ring_len(_aNwcXT_)
		n = @Min([ n, _nNwcLen_ ])

		_aNwcResult_ = []

		for _iNwc_ = 1 to n
			@AddItem(_aNwcResult_, _aNwcXT_[_iNwc_][1])
		next

		return _aNwcResult_

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
		_aNwcxXT_ = SortListsOn( ClassesXT(), 2 )
		_nNwcxLen_ = ring_len(_aNwcxXT_)
		n = @Min([ n, _nNwcxLen_ ])

		_aNwcxResult_ = []

		for _iNwcx_ = 1 to n
			@AddItem(_aNwcxResult_, _aNwcxXT_[_iNwcx_])
		next

		return _aNwcxResult_

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
		_acCilResult_ = []
		_aCilUnique_ = U( @Merge(This.Lists()) )
		_nCilLen_ = ring_len(_aCilUnique_)

		for _iCil_ = 1 to _nCilLen_
			@AddItem(_acCilResult_, Q(_aCilUnique_[_iCil_]).Stringified())
		next

		return _acCilResult_

		#< @FunctionFluentForm

		def ClassesInListQ()
			return This.ClassesInListsQRT(:stzList)

		def ClassesInListQRT(pcReturnType)
			if isList(pcReturnType) and StzListIsOneOfTheseNamedParamsList(pcReturnType,[ :ReturnedAs, :ReturnAs ])
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
		return ring_len( This.CLassesInList() )

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

		_aClilResult_ = []
		_aClilClasses_ = This.ClassesInList()
		_nClilLen_ = ring_len(_aClilClasses_)

		for _iClil_ = 1 to _nClilLen_
			@AddItem(_aClilResult_, [ _aClilClasses_[_iClil_], This.FindItem(_aClilClasses_[_iClil_]) ])
		next

		return _aClilResult_

		#< @FunctionFluentForm

		def ClassifyInListQ()
			return This.ClassifyInListQRT(pcReturnType)

		def ClassifyInListQRT(pcReturnType)
			if isList(pcReturnType) and StzListIsOneOfTheseNamedParamsList(pcReturnType,[ :ReturnedAs, :ReturnAs ])
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
		_aKlilResult_ = This.KeysForItemInList(pcClass)
		return _aKlilResult_

		#< @FunctionFluentForms

		def KalssInListQ(pcClass)
			return This.KlassInListQRT(pcClass, :stzList)

		def KlassInListQRT(pcClass, pcReturnType)
			if isList(pcReturnType) and StzListIsOneOfTheseNamedParamsList(pcReturnType,[ :ReturnedAs, :ReturnAs ])
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
		_aTcPairs_ = This.Content()
		_nTcLen_ = ring_len(_aTcPairs_)

		_cTcResult_ = "[ "

		for _iTc_ = 1 to _nTcLen_
			_cTcKey_ = _aTcPairs_[_iTc_][1]
			_cTcValue_ = Q(_aTcPairs_[_iTc_][2]).Stringified()

			_cTcBound_ = '"'
			if Q(_cTcValue_).IsBoundedBy('"')
				_cTcBound_ = "'"
			ok
			_cTcValue_ = _cTcBound_ + _cTcValue_ + _cTcBound_

			_cTcPair_ = ":" + _cTcKey_ + " = " + _cTcValue_ + ", "
			_cTcResult_ += _cTcPair_
		next

		_cTcResult_ = Q(_cTcResult_).RemovedFromEnd(", ") + " ]"
		return _cTcResult_

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
		_aTstContent_ = This.Content()
		_nTstLen_ = ring_len(_aTstContent_)

		_aTstTable_ = _aTstContent_

		for _iTst_ = 1 to _nTstLen_


		next

		_oTstResult_ = new stzTable(_aTstTable_)
		return _oTstResult_
