

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
		if NOT (isList(paNamed) and Q(paNamed).IsPair() and isString(paNamed[1]) and @IsHashList(paNamed[2]))
			StzRaise("Incorrect param type! paNamed must be a pair of string and list of type stzHashList.")
		ok
	ok

	_oStzHashList_ = StzHashListQ(paNamed[2])
	_oStzHashList_.SetName(paNamed[1])
	return _oStzHashList_

	func StzNamedHashListQ(paNamed)
		return StzNamedHashList(paNamed)

	func StzHashListXTQ(paNamed)
		return StzNamedHashList(paNamed)

# Whole-value equality for the class statistics: text with text, number with number,
# a list with a list, and a list with its written form (what Classes answers for it).
func _HlSameValue(pA, pB)
	if isList(pA)
		if isList(pB)
			return @@(pA) = @@(pB)
		but isString(pB)
			return @@(pA) = pB
		ok
		return 0
	ok

	if isList(pB)
		if isString(pA)
			return pA = @@(pB)
		ok
		return 0
	ok

	if isObject(pA) or isObject(pB)
		return 0
	ok

	return pA = pB

func IsHashList(paList)
 	if NOT isList(paList)
		return 0
	ok

	# Shape check and key collection in ONE direct pass -- no stzList clone.
	# This is a validation predicate: it runs on every hashlist-shaped param
	# in the library, so it must not copy the payload it is only inspecting.

	_nLen_ = len(paList)
	_aKeys_ = []

	for _i_ = 1 to _nLen_
		_item_ = paList[_i_]

		if NOT ( isList(_item_) and len(_item_) = 2 and isString(_item_[1]) )
			return 0
		ok

		_aKeys_ + _item_[1]
	next

	if _nLen_ < 2
		return 1
	ok

	# Keys must be distinct. The pairwise Ring scan is O(n^2) and cliffs
	# past a few hundred keys; the engine hashes in O(n) but costs a
	# marshal, so each side is used where it actually wins.

	if _nLen_ <= 256
		for _i_ = 2 to _nLen_
			_cKey_ = _aKeys_[_i_]

			for _j_ = 1 to _i_ - 1
				if _aKeys_[_j_] = _cKey_
					return 0
				ok
			next
		next

		return 1
	ok

	_pEngKeys_ = StzEngineMarshalList(_aKeys_)
	_nAllUnique_ = StzEngineListAllUniqueCS(_pEngKeys_, 1)
	StzEngineListFree(_pEngKeys_)

	if _nAllUnique_ = 1
		return 1
	ok

	return 0

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
		_acKeysResult_ + paList[_iKeys_][1]
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

	# ONE pass: validate the shape as we go and remember whether the key was
	# seen. 594 live callers depend on this being cheap.
	#
	# It used to call IsHashList(paList) -- which validates the shape AND
	# checks every key for uniqueness, marshalling the whole list to the
	# engine to do it -- and THEN build the entire lowercased key list before
	# searching that. Measured, the guard alone was the whole cost of a hit:
	# 200 lookups over 600 keys spent 0.22s in IsHashList out of 0.22s total.
	# Callers that bump a counter in a loop pay it per bump, which is why
	# stzApriori took 1.75s on 40 transactions.
	#
	# It answers ONE question -- is this key present -- and stops as soon as
	# it knows. Validating the whole container is IsHashList's job, and
	# borrowing it here is what made this both slow and wrong: a list with
	# DUPLICATE keys used to answer FALSE for a key plainly present.
	#
	# Items that are not [string, value] pairs cannot match a string key, so
	# they are skipped rather than poisoning the answer. A list of non-pairs
	# therefore still answers FALSE, exactly as before.

	if NOT isList(paList)
		return 0
	ok

	_cHkProbe_ = StzLower(pcKey)
	_nHkLen_ = len(paList)

	for _iHk_ = 1 to _nHkLen_
		_aHkPair_ = paList[_iHk_]

		if isList(_aHkPair_) and len(_aHkPair_) = 2
			if isString(_aHkPair_[1])
				if StzLower(_aHkPair_[1]) = _cHkProbe_
					return 1
				ok
			ok
		ok
	next

	return 0

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
		return 0
	ok

	_nHksLen_ = len(paList)
	_acHksAllKeys_ = []

	for _iHks_ = 1 to _nHksLen_
		_acHksAllKeys_ + paList[_iHks_][1]
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
		return 0
	ok

	_nHkxLen_ = len(paList)
	_acHkxAllKeys_ = []

	for _iHkx_ = 1 to _nHkxLen_
		_acHkxAllKeys_ + StzLower(paList[_iHkx_][1])   # add() corrupts multibyte
	next

	_aHkxResult_ = []
	_nHkxKeysLen_ = len(pacKeys)

	for _jHkx_ = 1 to _nHkxKeysLen_
		if find(_acHkxAllKeys_, StzLower(pacKeys[_jHkx_])) > 0
			_aHkxResult_ + 1
		else
			_aHkxResult_ + 0
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
		return 0
	ok

	if NOT IsHashList(paList)
		return 0
	ok

	if NOT IsListOfListsOfNumbers(StzHashListQ(paList).Values())
		return 0
	ok

	return 1

func IsHashListOfStrings(paList)
	if NOT isList(paList)
		return 0
	ok

	if NOT IsHashList(paList)
		return 0
	ok

	if NOT IsListOfListsOfStrings(StzHashListQ(paList).Values())
		return 0
	ok

	return 1

func IsHashListOfLists(paList)
	if NOT isList(paList)
		return 0
	ok

	if NOT IsHashList(paList)
		return 0
	ok

	if NOT IsListOfListsOfLists(StzHashListQ(paList).Values())
		return 0
	ok

	return 1

func IsHashListOfHashLists(paList)
	if NOT isList(paList)
		return 0
	ok

	if NOT IsHashList(paList)
		return 0
	ok

	if NOT IsListOfListsOfHashLists(StzHashListQ(paList).Values())
		return 0
	ok

	return 1

func IsHashListOfPairs(paList)
	if NOT isList(paList)
		return 0
	ok

	if NOT IsHashList(paList)
		return 0
	ok

	if NOT IsListOfListsOfPairs(StzHashListQ(paList).Values())
		return 0
	ok

	return 1

func IsHashListOfPairsOfNumbers(paList)
	if NOT isList(paList)
		return 0
	ok

	if NOT IsHashList(paList)
		return 0
	ok

	if NOT IsListOfListsOfPairsOfNumbers(StzHashListQ(paList).Values())
		return 0
	ok

	return 1

func IsHashListOfObjects(paList)
	if NOT isList(paList)
		return 0
	ok

	if NOT IsHashList(paList)
		return 0
	ok

	if NOT IsListOfListsOfobjects(StzHashListQ(paList).Values())
		return 0
	ok

	return 1

func ShowHL(pValue)
	if NOT (isList(pValue) and @IsHashList(pValue))
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

func HashRemove(paHash, _cKey_)
	if CheckParams()
		if NOT (isList(paHash) and IsHashList(paHash))
			StzRaise("Incorrect param type! paHash must be a hashlist.")
		ok
		if NOT isString(_cKey_)
			StzRaise("Incorrect param type! cKey must be a string.")
		ok
	ok

	_nLen_ = len(paHash)
	_cKey_ = StzLower(_cKey_)
	_n_ = 0

	for i = 1 to _nLen_
		if paHash[i][1] = _cKey_
			_n_ = 1
			exit
		ok
	next

	if _n_ > 0
		del(paHash, _n_)
	ok

	return paHash

	func HashDel(paHash, _cKey_)
		return HashRemove(paHash, _cKey_)

	func HashDelete(paHash, _cKey_)
		return HashRemove(paHash, _cKey_)

func StzAssociativeListQ(paList)
	return new stzAssociativeList(paList)

class stzAssociativeList from stzHashList

# Holds a list of [ key, value ] pairs and finds, reads and groups them by key or by value.
#
# A hash list is the Ring list [ :name = "Ali", :age = 30 ] made into an object: keys are looked up
# without regard to case, values can be of any type and repeat, and the pairs keep their order.
# Reach for it when you read the pairs by position or by value as often as by key.
#
#   receiver   o1 = new stzHashList([ :one = "a", :two = "b", :three = "a", :four = 4 ])
#   example    ? @@( o1.FindValue("a") )
#              #--> [ 1, 3 ]
#   see        stzList, stzTable
class stzHashList from stzList # Also called stzAssociativeList
	@aContent = []
	@pEngineMap = ""

	  #--------------#
	 #     INIT     #
	#--------------#

	# Builds the hash list from [ key, value ] pairs; a plain list of pairs is normalised.
	#
	#   p          the pairs, as a list
	#   returns    the new stzHashList
	#@ aka  Build the hash list from [key, value] pairs (a list of pairs is auto-normalized).
	def init(p)

		# Auto-normalize: a list of pairs is also accepted as a
		# hashlist with stringified keys (used by tests piping
		# section lists into QRT(:stzHashList)).
		if isList(p) and NOT @IsHashList(p)
			_nL_ = len(p)
			_bPairs_ = (_nL_ > 0)
			for _iC_ = 1 to _nL_
				if NOT (isList(p[_iC_]) and len(p[_iC_]) = 2)
					_bPairs_ = 0
					exit
				ok
			next
			if _bPairs_
				for _iC_ = 1 to _nL_
					_k_ = p[_iC_][1]
					if NOT isString(_k_) p[_iC_][1] = "" + _k_ ok
				next
			ok
		ok

		if CheckParams()
			if NOT ( isList(p) and @IsHashList(p) )
				StzRaise("Can't create the stzHashList object! You must provide a well formed hashlist.")
			ok
		ok

		# Normalise the keys into a FRESH list. Assigning p[i][1] in place
		# corrupts the container: on a hash-indexed Ring list that write
		# INSERTS the new key instead of replacing the pair's first item, so
		# a two-pair hash list came back with THREE keys -- the lowercased
		# one and the original both present, with the pair structure broken.
		#
		# It only showed on CASED NON-ASCII keys. For ASCII, lowering changes
		# nothing the case-insensitive indexer can see, so the damage stayed
		# invisible; a Greek key stored as capital alpha-theta and read back
		# as small alpha-theta made ContainsKey, HasKey and ValueByKey all
		# answer "no such key" for a key that was demonstrably there.

		_aInitNorm_ = []
		_nInitLen_ = len(p)

		for _iInit_ = 1 to _nInitLen_
			_aInitNorm_ + [ StzLower(p[_iInit_][1]), p[_iInit_][2] ]
		next

		@aContent = _aInitNorm_

		if KeepingHistory() = 1
			This.AddHistoricValue(This.Content())
		ok

	  #===============================#
	 #   ENGINE HASHMAP HELPERS     #
	#===============================#

	def _EnsureEngineMap()
		if @pEngineMap != ""
			return
		ok

		@pEngineMap = StzEngineHashMapNew()
		if @pEngineMap = ""
			return
		ok

		_aEmContent_ = @aContent
		_nEmLen_ = len(_aEmContent_)

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
		if @pEngineMap != ""
			StzEngineHashMapFree(@pEngineMap)
			@pEngineMap = ""
		ok

	  #-------------#
	 #     GET     #
	#-------------#

	# Returns the pairs as they are held, a list of [ key, value ] pairs.
	#
	#   returns    a list of [ key, value ] pairs, in order
	#   see        Keys, Values
	#   example    ? @@( o1.Content() )
	#              #--> [ [ "one", "a" ], [ "two", "b" ], [ "three", "a" ], [ "four", 4 ] ]
	#@ aka  The raw hash list: the [key, value] pairs.
	def Content()
		return @aContent

	# Same as Content: the [key, value] pairs.
	def HashList()
		return This.Content()

	# Returns how many [ key, value ] pairs the hash list holds.
	#
	#   returns    a number
	#   example    ? o1.NumberOfPairs()
	#              #--> 4
	#@ aka  How many [key, value] pairs the hash list holds.
	def NumberOfPairs()
		# Engine fast path: stz_hashmap_len is O(1) cached vs Ring len() on a hashlist array
		This._EnsureEngineMap()
		if @pEngineMap != ""
			return StzEngineHashMapLen(@pEngineMap)
		ok
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

	# Returns the [ key, value ] pairs, as Content does.
	#
	#   returns    a list of [ key, value ] pairs
	#   see        Content, Keys, Values
	#@ aka  The [key, value] pairs (same as Content).
	def Pairs()
		return Content()

		def PairsQ()
			return This.PairsQRT(:stzList)

		# The pairs, in the requested return type (QRT).
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


	# Returns the keys of the hash list, in order.
	#
	#   returns    a list of the keys, which are held in lower case
	#   see        Values, HasKey
	#   example    ? @@( o1.Keys() )
	#              #--> [ "one", "two", "three", "four" ]
	#@ aka  The keys of the hash list, as a list.
	def Keys()
		_aHkContent_ = This.Content()
		_nHkLen_ = len(_aHkContent_)

		_aHkResult_ = []

		for _iHk_ = 1 to _nHkLen_
			@AddItem(_aHkResult_, _aHkContent_[_iHk_][1])
		next

		return _aHkResult_

		def KeysQ()
			return This.KeysQRT(:stzList)

		# The keys, in the requested return type (QRT).
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

	# Returns the keys of every pair whose value equals the given one, in order.
	#
	#   pValue     the value to look for: text, a number, or a list when the values are lists
	#   returns    a list of the keys
	#   note       the whole value must match, unlike KeysByValue which also finds it inside a value;
	#              a class name as given by Classes, such as "4" or "[ 1, 2 ]", matches too
	#   see        KeysByValue
	#@ aka  The keys whose value equals the given value.
	def KeysForValue(pValue)
		_aKfvContent_ = This.Content()
		_nKfvLen_ = len(_aKfvContent_)

		_aKfvResult_ = []

		for _iKfv_ = 1 to _nKfvLen_
			if _HlSameValue(_aKfvContent_[_iKfv_][2], pValue)
				@AddItem(_aKfvResult_, _aKfvContent_[_iKfv_][1])
			ok
		next

		return _aKfvResult_

		#< @FunctionFluentForms

		def KeysForValueQ()
			return This.KeysForValueQRT(:stzList)

		# The keys holding the value, in the requested return type.
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

	# Returns the values of the hash list, in order.
	#
	#   returns    a list of the values
	#   see        Keys, Numbers
	#   example    ? @@( o1.Values() )
	#              #--> [ "a", "b", "a", 4 ]
		#>
	#@ aka  The values of the hash list, as a list.
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

		# The values, in the requested return type (QRT).
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

	# TRUE if every value is a list and all the lists have the same size.
	#
	#   returns    TRUE or FALSE
	#   see        Lists
	#@ aka  TRUE if every value is a list and all have the same size.
	def ValuesAreListsOfSameSize()

		_aValsContent_ = This.Content()
		_nValsLen_ = This.NumberOfValues()

		if _nValsLen_ = 1
			return 1
		ok

		_nValsSize_ = len(_aValsContent_[1][2])
		_bValsResult_ = 1

		for _iVals_ = 2 to _nValsLen_
			if len(_aValsContent_[_iVals_][2]) != _nValsSize_
				_bValsResult_ = 0
				exit
			ok
		next

		return _bValsResult_

	# Returns the pairs turned round: [ value, key ] for each pair.
	#
	#   returns    a list of [ value, key ] pairs
	#   see        Pairs
	#@ aka  The pairs INVERTED: [value, key] for each pair.
	def ValuesAndKeys()
		_aVakValues_ = This.Values()
		_nVakLen_ = len(_aVakValues_)

		_aVakResult_ = []

		for _iVak_ = 1 to _nVakLen_
			@AddItem(_aVakResult_, [ _aVakValues_[_iVak_], This.NthKey(_iVak_) ])
		next

		return _aVakResult_

	# Returns the key of the pair at position n.
	#
	#   _n_        the position, from 1
	#   returns    a string
	#   see        NthPair, NthValue
	#@ aka  The key of the nth pair.
	def NthKey(_n_)
		if isString(_n_)
			if _n_ = :First or _n_ = :FirstKey
				_n_ = 1

			but _n_ = :Last or _n_ = :LastKey
				_n_ = This.NumberOfKeys()
			ok
		ok

		if NOT isNumber(_n_)
			StzRaise("Incorrect param type! n should be a number.")
		ok

		if _n_ > 0
			return This.Content()[_n_][1]
		ok

		def NthKeyQ(_n_)
			return new stzString(This.NthKey())

	def Key(_n_)
		return This.NthKey(_n_)

		def KeyQ(_n_)
			return new stzString(This.Key(_n_))
	
		def KeyAtPosition(_n_)
			return This.Key(_n_)
	
	# Returns the value of the pair at position n.
	#
	#   _n_        a position from 1 to the number of pairs, or :First or :Last
	#   returns    the value of that pair, of any type
	#   warning    a position outside the hash list raises an error
	#   see        Values, FindNthOccurrenceOfValue
	#   example    ? o1.NthValue(2)
	#              #--> b
	#              ? o1.NthValue(:Last)
	#              #--> 4
	#@ aka  The value of the nth pair.
	def NthValue(_n_)

		if checkParams()

			if isString(_n_)
				if _n_ = :First or _n_ = :FirstValue
					_n_ = 1
	
				but _n_ = :Last or _n_ = :LastValue
					_n_ = This.NumberOfValues()
				ok
			ok
	
			if NOT isNumber(_n_)
				StzRaise("Incorrect param type! n must be a number.")
			ok

		ok

		_nNvLen_ = len(This.Content())
		if _n_ > _nNvLen_ or _n_ < 1
			StzRaise("Can't access item " + _n_ + " in the hashlist! The hashlist contains only " + _nNvLen_ + "pairs.")
		ok

		return This.Content()[_n_][2]

		def NthValueQ(_n_)
			return Q(This.NthValue())

		def Value(_n_)
			return This.NthValue(_n_)

			def ValueQ(_n_)
				return Q( This.Value(_n_) )

		def ValueAtPosition(_n_)
			return This.Value(_n_)

	# Returns the value of the first pair.
	#
	#   returns    the value
	#   see        LastValue, NthValue
	#@ aka  The value of the first pair.
	def FirstValue()
		return This.NthValue(1)

		def FirstValueQ()
			return This.NthValueQ(1)
	
	# Returns the value of the last pair.
	#
	#   returns    the value
	#   see        FirstValue, NthValue
	#@ aka  The value of the last pair.
	def LastValue()
		return This.NthValue(This.NumberOfValues())

		def LastValueQ()
			return Q( This.LastValue() )
	
	# Returns the [ key, value ] pair at position n.
	#
	#   _n_        the position, from 1
	#   returns    a pair [ key, value ]
	#   see        NthKey, NthValue
	#@ aka  The nth [key, value] pair.
	def NthPair(_n_)
		if isString(_n_)
			if _n_ = :First or _n_ = :FirstPair
				_n_ = 1

			but _n_ = :Last or _n_ = :LastPair
				_n_ = This.NumberOfPairs()
			ok
		ok

		if NOT isNumber(_n_)
			StzRaise("Incorrect param type! n should be a number.")
		ok

		return This.Content()[_n_]

		#< @FunctionFluentForm

		def NthPairQ(_n_)
			return This.NthPairQRT(_n_, :stzList)

		# The nth pair, in the requested return type (QRT).
		def NthPairQRT(_n_, pcReturnType)
			if isList(pcReturnType) and Q(pcReturnType).IsReturnedAsNamedParam()
				pcReturnType = pcReturnType[2]
			ok

			if NOT ( isString(pcReturnType) and Q(pcReturnType).IsAStzClassName() )
				StzRaise("Incorrect param! pcReturnType must be a string containing the name of a Softanza class.")
			ok

			switch pcReturnType
			on :stzList
				return new stzList(This.NthPair(_n_))
			on :stzPair
				return new stzpair(This.NthPair(_n_))
			other
				StzRaise("Unsupported return type!")
			off

		#>

		#< @FunctionAlternativeForm
	
		def Pair(_n_)
			return This.NthPair(_n_)
	
			def PairQ(_n_)
				return This.NthPairQ(_n_)

			# The pair, in the requested return type (QRT).
			def PairQRT(_n_, pcReturnType)
				return This.NthPairQRT(_n_, pcReturnType)
	
	# Returns the first [ key, value ] pair.
	#
	#   returns    a pair, [ key, value ]
	#   see        NthPair
		#>
	#@ aka  The first [key, value] pair.
	def FirstPair()
		return This.NthPair(1)

		def FirstPairQ()
			return This.NthPairQ(1)


		# Misspelled-but-kept alias of FirstPair.
		def FristPair()
			return This.FirstPair()

	# Returns the last [ key, value ] pair.
	#
	#   returns    a pair, [ key, value ]
	#   see        NthPair
	#@ aka  The last [key, value] pair.
	def LastPair()
		return This.NthPair(This.NumberOfPairs())

		def LastPairQ()
			return This.NthPairQ(This.NumberOfPairs())

	# Returns the key part of a [ key, value ] pair held by the hash list.
	#
	#   paPair     the pair, [ key, value ]
	#   returns    a string
	#   note       a pair the hash list does not hold raises an error
	#   see        NthKey
	#@ aka  The key part of the given [key, value] pair.
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

	# Returns the value part of a [ key, value ] pair held by the hash list.
	#
	#   paPair     the pair, [ key, value ]
	#   returns    the value, of any type
	#   note       a pair the hash list does not hold raises an error
	#   see        NthValue
	#@ aka  The value part of the given [key, value] pair.
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

	# Returns the key of the pair at position n, as NthKey does.
	#
	#   _n_        the position, from 1
	#   returns    a string
	#   see        NthKey
	#@ aka  The key of the nth pair.
	def KeyInNthPair(_n_)
		return This.NthPair(_n_)[1]

		def KeyInNthPairQ(_n_)
			return new stzString( This.KeyInNthPair(_n_) )
	
	# Returns the value of the pair at position n, as NthValue does.
	#
	#   _n_        the position, from 1
	#   returns    the value
	#   see        NthValue
	#@ aka  The value of the nth pair.
	def ValueInInNthPair(_n_)
		return This.NthPair(_n_)[2]

	# Returns the value of the pair at position n, wrapped as a Q object.
	#
	#   _n_        the position, from 1
	#   returns    a Q object
	#   see        NthValue
	#@ aka  The value of the nth pair, wrapped as a Q object.
	def ValueInNthPairQ(_n_)
		return Q( This.NthPair(_n_)[2] )

	# Returns the value stored under the given key, whatever the key's case.
	#
	#   pcKey      the key, as text
	#   returns    the value
	#   see        KeyByValue, HasKey
	#@ aka  The value stored under the given key.
	def ValueByKey(pcKey)
		# Resolve through the ENGINE map, which compares keys byte for byte.
		#
		# Ring's hashlist[key] indexer cannot be trusted once the list lives
		# in an object attribute: 100 of 600 keys built on Greek/CJK prefixes
		# silently resolved to "" -- SILENTLY, the registry simply reported
		# no such key -- while the identical lookups on the identical bytes
		# succeeded on the free-standing list both before AND after the
		# object was constructed. Indexing @aContent directly instead of
		# This.Content() does not help either, so the fault is in the VM's
		# hash index, not in the copy Content() returns.
		#
		# The engine map keeps insertion order, so its 1-based key position
		# is also the position in @aContent -- and reading the value from
		# there preserves its TYPE, which a get_string coercion would not.
		#
		# Falling back to Ring's indexer on a miss is deliberate: it matches
		# ASCII keys case-INSENSITIVELY, which is long-standing behaviour
		# here. Exact keys of every script now resolve first, and that
		# looser ASCII match still resolves after.

		# Lower the PROBE, because the constructor stores keys lowercased --
		# exactly as HasKey/ContainsKey already do. Without it those three
		# disagreed: ContainsKey(k) said TRUE while ValueByKey(k) returned ""
		# for the same k, for every key holding a CASED non-ASCII letter
		# (Greek, Cyrillic, Armenian).
		_cVbkKey_ = StzLower(pcKey)

		This._EnsureEngineMap()

		if @pEngineMap != ""
			_nVbkPos_ = StzEngineHashMapFindKey(@pEngineMap, _cVbkKey_)

			if _nVbkPos_ > 0
				return @aContent[_nVbkPos_][2]
			ok
		ok

		return @aContent[ _cVbkKey_ ]

	# Returns the value stored under the given key, as an integer.
	#
	#   pcKey      the key, as text
	#   returns    a number
	#   see        ValueByKey, ValueFloatByKey
	#@ aka  The value under the given key, as an integer (engine map).
	def ValueIntByKey(pcKey)
		This._EnsureEngineMap()
		if @pEngineMap != ""
			return StzEngineHashMapGetInt(@pEngineMap, pcKey)
		ok
		return 0 + This.ValueByKey(pcKey)

	# Returns the value stored under the given key, as a decimal number.
	#
	#   pcKey      the key, as text
	#   returns    a number
	#   see        ValueByKey, ValueIntByKey
	#@ aka  The value under the given key, as a float (engine map).
	def ValueFloatByKey(pcKey)
		This._EnsureEngineMap()
		if @pEngineMap != ""
			return StzEngineHashMapGetFloat(@pEngineMap, pcKey)
		ok
		return 0.0 + This.ValueByKey(pcKey)

	# Returns the value stored under the given key, as a string.
	#
	#   pcKey      the key, as text
	#   returns    a string
	#   see        ValueByKey
	#@ aka  The value under the given key, as a string (engine map).
	def ValueStringByKey(pcKey)
		This._EnsureEngineMap()
		if @pEngineMap != ""
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

	# Returns how many pairs hold the given value.
	#
	#   pValue     the value to count
	#   returns    a number
	#   see        FindValue
		#>
	#@ aka  How many pairs hold the given value.
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

	# Returns the distinct values of the hash list, in order of first appearance.
	#
	#   returns    a list of values
	#   see        Values, Classes
		#>
	#@ aka  The distinct values of the hash list.
	def UniqueValues()
		_aUvResult_ = This.ValuesQ().DuplicatesRemoved()
		return _aUvResult_

		def ValuesU()
			return This.UniqueValues()

		def ValuesWithoutDuplication()
			return This.UniqueValues()

	# Returns the values of the pairs at the given positions.
	#
	#   anPos      the positions
	#   returns    a list of values
	#   see        KeysAtPositions
	#@ aka  The values of the pairs at the given positions.
	def ValuesAtPositions(anPos)
		_aVapResult_ = This.ValuesQ().ItemsAtPositions(anPos)
		return _aVapResult_

		def ValuesAtThesePositions(anPos)
			return This.ValuesAtPositions(anPos)

	  #---------------------------#
	 #   UPDATING THE HASHLIST   #
	#---------------------------#

	# Replaces the whole content by the given hash list, in place.
	#
	#   paNewHashList   the new pairs, as a hash list
	#   returns         nothing; the hash list changes
	#   warning         a value that is not a hash list raises an error
	#   see             Updated, UpdateWith
	#@ aka  Replace the whole content with the given hash list (mutating; the single update point).
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
	

		# Replaces the whole content by the given hash list, in place, as Update does.
		#
		#   paNewHashList   the new pairs, as a hash list
		#   returns         nothing; the hash list changes
		#   see             Update
		#< @FunctionAlternativeForms
		#@ aka  Same as Update: replace the whole content (mutating).
		def UpdateWith(paNewHashList)
			This.Update(paNewHashList)

			def UpdateWithQ(paNewHashList)
				return This.UpdateQ(paNewHashList)
	
		# Replaces the whole content by the given hash list, in place, as Update does.
		#
		#   paNewHashList   the new pairs, as a hash list
		#   returns         nothing; the hash list changes
		#   see             Update
		#@ aka  Same as Update: replace the whole content (mutating).
		def UpdateBy(paNewHashList)
			This.Update(paNewHashList)

			def UpdateByQ(paNewHashList)
				return This.UpdateQ(paNewHashList)

		# Replaces the whole content by the given hash list, in place, as Update does.
		#
		#   paNewHashList   the new pairs, as a hash list
		#   returns         nothing; the hash list changes
		#   see             Update
		#@ aka  Same as Update: replace the whole content (mutating).
		def UpdateUsing(paNewHashList)
			This.Update(paNewHashList)

			def UpdateUsingQ(paNewHashList)
				return This.UpdateQ(paNewHashList)

	# Returns the hash list the object would become with Update; the hash list is unchanged.
	#
	#   paNewHashList   the new pairs, as a hash list
	#   returns         a hash list, as [ [ key, value ], ... ]
	#   see             Update
		#>
	#@ aka  The value the hash list would be updated to (passive twin of Update).
	def Updated(paNewHashList)
		return paNewHashList

		#< @FunctionAlternativeForms

		def UpdatedWith(paNewHashList)
			return This.Updated(paNewHashList)

		def UpdatedBy(paNewHashList)
			return This.Updated(paNewHashList)

		def UpdatedUsing(paNewHashList)
			return This.Updated(paNewHashList)

	# Replaces the pair at position n by a new [ key, value ] pair, in place.
	#
	#   _n_         the position, from 1
	#   paNewPair   the new pair
	#   returns     nothing; the hash list changes
	#   see         UpdatePair
		#>
	#---
	#@ aka  Replace the nth pair with the given [key, value] pair (mutating).
	def UpdateNthPair(_n_, paNewPair)

		if _n_ = :First
			_n_ = 1
		but _n_ = :Last
			_n_ = This.NumberOfPairs()
		ok

		if isList(paNewPair) and @IsPairAndKeyIsString(paNewPair)

			This.UpdateNthKey(_n_, paNewPair[1])
			This.UpdateNthValue(_n_, paNewPair[2])
		else
			StzRaise("Key must be a string!")
		ok
	
	# Replaces the given pair by a new one, in place.
	#
	#   paPair      the pair to replace, [ key, value ]
	#   paNewPair   the new pair
	#   returns     nothing; the hash list changes
	#   warning     a pair that is not in the hash list raises an error
	#   see         UpdateNthPair
	#@ aka  Replace the given pair with the new one (mutating).
	def UpdatePair(paPair, paNewPair)
		if isList(paPair) and @IsPairAndKeyIsString(paNewPair) and
		   This.ContainsPair(paPair)
			_nUpN_ = This.FindPair(paPair)

			This.UpdateNthKey(_nUpN_, paNewPair[1])
			This.UpdateNthValue(_nUpN_, paNewPair[2])
		else
			StzRaise("Key must be a string!")
		ok

	# Replaces the key of the pair at position n, in place.
	#
	#   _n_        the position, from 1
	#   pcValue    the new key
	#   returns    nothing; the hash list changes
	#   see        ReplaceNthKey
	#@ aka  Replace the KEY of the nth pair (mutating).
	def UpdateNthKey(_n_, pcValue)
		if isList(_n_) and isNumber(pcValue)
			_unkTemp_ = _n_
			_n_ = pcValue
			pcValue = _unkTemp_
		ok

		if _n_ = :First
			_n_ = 1
		but _n_ = :Last
			_n_ = This.NumberOfKeys()
		ok

		# Now, let's do the job

		_aUnkContent_ = This.Content()
		_aUnkContent_[_n_][1] = pcValue
		This.UpdateWith(_aUnkContent_)

	# Renames the given key, in place.
	#
	#   pcKey      the key to rename
	#   pcNewKey   the new key
	#   returns    nothing; the hash list changes
	#   see        ReplaceKey
	#@ aka  Rename the given key (mutating).
	def UpdateKey(pcKey, pcNewKey)
		if isString(pcKey) and This.ContainsKey(pcKey)
			_aUkContent_ = This.Content()
			_nUkN_ = This.FindKey(pcKey)
			_aUkContent_[_nUkN_][1] = pcNewKey
			This.UpdateWith(_aUkContent_)
		ok

	# Replaces the keys by the given ones, in order, in place.
	#
	#   paKeys     the new keys, one per pair, which must stay distinct
	#   returns    nothing; the hash list changes
	#   see        ReplaceNthKey
	#@ aka  Replace the keys with the given ones, in order (mutating).
	def UpdateKeys(paKeys)
		if NOT ( isList(paKeys) and @IsListOfStrings(paKeys) )
			StzRaise("Incorrect param type! paKeys must be a list of strings.")
		ok

		# all the keys change in one step, so a swap of two keys is not seen as a clash
		_aUksContent_ = This.Content()
		for _iUks_ = 1 to @Min([ len(paKeys), This.NumberOfPairs() ])
			_aUksContent_[_iUks_][1] = paKeys[_iUks_]
		next _iUks_
		This.UpdateWith(_aUksContent_)

	# Replaces the value of the pair at position n, in place.
	#
	#   _n_        the position, from 1
	#   pValue     the new value
	#   returns    nothing; the hash list changes
	#   see        ReplaceNthValue
	#@ aka  Replace the VALUE of the nth pair (mutating).
	def UpdateNthValue(_n_, pValue)

		if _n_ = :First
			_n_ = 1
		but _n_ = :Last
			_n_ = This.NumberOfValues()
		ok

		# Write the one cell IN PLACE.
		#
		# Changing a VALUE cannot break hashlist-ness -- the keys are
		# untouched -- so there is nothing to re-validate. The old path
		# copied the entire hashlist out with Content(), changed one cell,
		# and pushed the whole thing back through Update(), which wraps the
		# list in a stz object to test for a named param and then revalidates
		# every pair. That is several full passes over the list to write one
		# value, so any loop of updates was quadratic: 200 updates against a
		# 4000-pair list took 17.85s.

		@aContent[_n_][2] = pValue
		This._InvalidateEngineMap()

		if KeepingHisto() = 1
			This.AddHistoricValue(This.Content())
		ok

		# Replaces the nth occurrence of a value by a new one, in place; nothing changes when there are fewer.
		#
		#   _n_        which occurrence, from 1
		#   pValue     the value to replace
		#   pNewValue  the new value
		#   returns    nothing; the hash list changes
		#@ aka  Replace the nth occurrence of the value with the new one (mutating).
		def UpdateNthOccurrenceOfValue(_n_, pValue, pNewValue)
			_anUnovPos_ = This.FindValue(pValue)
			if _n_ >= 1 and _n_ <= len(_anUnovPos_)
				This.UpdateNthValue(_anUnovPos_[_n_], pNewValue)
			ok

	# Replaces the values by the given ones, in order, in place.
	#
	#   paValues   the new values, one per pair
	#   returns    nothing; the hash list changes
	#   see        UpdateValue
	#@ aka  Replace the values with the given ones, in order (mutating).
	def UpdateValues(paValues)
		for _iUvs_ = 1 to @Min([ len(paValues), This.NumberOfPairs() ])
			This.UpdateNthValue(_iUvs_, paValues[_iUvs_])
		next

	# Replaces every occurrence of the given value by a new one, in place.
	#
	#   pValue      the value to replace
	#   pNewValue   the new value
	#   returns     nothing; the hash list changes
	#   see         ReplaceValue
	#@ aka  Replace every occurrence of the given value with the new one (mutating).
	def UpdateValue(pValue, pNewValue)
		_anUvPos_ = This.FindValue(pValue)
		_nUvLen_ = len(_anUvPos_)

		for _iUv_ = 1 to _nUvLen_
			This.UpdateNthValue(_anUvPos_[_iUv_], pNewValue)
		next
	
	# Replaces the first occurrence of a value by a new one, in place.
	#
	#   pValue      the value to replace
	#   pNewValue   the new value
	#   returns    nothing; the hash list changes
	#@ aka  Replace only the FIRST occurrence of the value (mutating).
	def UpdateFirstOccurrenceOfValue(pValue, pNewValue)
		This.UpdateNthOccurrenceOfValue(1, pValue, pNewValue)

		# Replaces the first occurrence of a value by a new one, in place.
		#
		#   pValue      the value to replace
		#   pNewValue   the new value
		#   returns    nothing; the hash list changes
		def UpdateFirstValue(pValue, pNewValue)
			This.UpdateFirstOccurrenceOfValue(pValue, pNewValue)
		
	# Replaces the last occurrence of a value by a new one, in place.
	#
	#   pValue      the value to replace
	#   pNewValue   the new value
	#   returns    nothing; the hash list changes
	#@ aka  Replace only the LAST occurrence of the value (mutating).
	def UpdateLastValue(pValue, pNewValue)
		_nUlvN_ = This.NumberOfOccurrenceOfValue(pValue)
		This.UpdateNthOccurrenceOfValue(_nUlvN_, pValue, pNewValue)

	# Puts the given pair in place of the only pair of a one-pair hash list; more pairs raise, as keys must stay distinct.
	#
	#   paPair     the pair to put in place, [ key, value ]
	#   returns    nothing; the hash list changes
	#   see        Update
	#@ aka  Replace every pair with the given [key, value] pair (mutating).
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
		_nUapLen_ = len(_aUapContent_)

		if _nUapLen_ > 1
			StzRaise("Can't update all pairs with one pair! Keys must stay distinct, so only a hash list of one pair can take it.")
		ok

		for _iUap_ = 1 to _nUapLen_
			_aUapContent_[_iUap_] = paPair
		next

		This.UpdateWith(_aUapContent_)

	  #-----------------------------#
	 #  REVERSING KEYS AND VALUES  #
	#-----------------------------#

	# Swaps the keys and the values, in place; the values must be distinct text or numbers.
	#
	#   returns    nothing; the hash list changes
	#   see        ValuesAndKeys
	def ReverseKeysAndValues()

		_aRkvKeys_ = This.Keys()
		_aRkvValues_ = This.Values()
		_nRkvLen_ = This.NumberOfPairs()

		_aRkvPairs_ = []
		for _iRkv_ = 1 to _nRkvLen_
			if isList(_aRkvValues_[_iRkv_]) or isObject(_aRkvValues_[_iRkv_])
				StzRaise("Can't reverse keys and values! Every value must be text or a number, to become a key.")
			ok
			_aRkvPairs_ + [ "" + _aRkvValues_[_iRkv_], _aRkvKeys_[_iRkv_] ]
		next

		if NOT @IsHashList(_aRkvPairs_)
			StzRaise("Can't reverse keys and values! The values must be distinct, to become distinct keys.")
		ok

		This.UpdateWith(_aRkvPairs_)

		def ReverseKeysAndValuesQ()
			This.ReverseKeysAndValues()
			return This
	
	  #---------------------#
	 #     ADDING PAIRS    #
	#---------------------#

	# Adds a [ key, value ] pair at the end, in place.
	#
	#   paNewPair   the pair, [ key, value ]
	#   returns     nothing; the hash list changes
	#   see         AddPairs, Add
	#@ aka  Add the given [key, value] pair at the end (mutating).
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

		# Adds a pair at the end of the hash list, in place.
		#
		#   paNewPair   the pair to add, as [ key, value ]
		#   returns     nothing; the hash list changes. AddQ returns the object for chaining
		#   see         InsertBefore
		#   example     o1.Add([ "five", "e" ])
		#               ? o1.NumberOfPairs()
		#               #--> 5
		#               ? o1.NthValue(5)
		#               #--> e
		def Add(paNewPair)
			This.AddPair(paNewPair)

			def AddQ(paNewPair)
				return This.AddPairQ(paNewPair)


	# Adds several [ key, value ] pairs at the end, in place.
	#
	#   paListOfPairs   the pairs, as a list of [ key, value ]
	#   returns         nothing; the hash list changes
	#   see             AddPair
	#@ aka  Add each of the given pairs at the end (mutating).
	def AddPairs(paListOfPairs)
		_nApsLen_ = len(paListOfPairs)
		for _iAps_ = 1 to _nApsLen_
			This.AddPair(paListOfPairs[_iAps_])
		next

		def AddPairsQ(paListOfPairs)
			This.AddPairs(paListOfPairs)
			return This

		# Adds several [ key, value ] pairs at the end, in place, as AddPairs does.
		#
		#   paListOfPairs   the pairs, as a list of [ key, value ]
		#   returns         nothing; the hash list changes
		#   see             AddPairs
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

	# Inserts a pair before position n, in place.
	#
	#   _n_        the position to insert before, from 1 to the number of pairs
	#   paPair     the pair to insert, as [ key, value ]
	#   returns    nothing; the hash list changes
	#   see        Add
	#@ aka  Insert the given pair BEFORE position n (mutating).
	def InsertBefore(_n_, paPair)
		if _n_ >= 1 and _n_ <= This.NumberOfPairs()
			_aIbContent_ = This.Content()
			_aIbContent_ = ring_insert(_aIbContent_, _n_, paPair)
			This.UpdateWith(_aIbContent_)
		ok

		def InsertBeforeQ(_n_, paPair)
			This.InsertBefore(_n_, paPair)
			return This

	# Inserts a pair after position n, in place.
	#
	#   _n_        the position to insert after, from 0 to the number of pairs
	#   paPair     the pair to insert, [ key, value ]
	#   returns    nothing; the hash list changes
	#   see        Add
	#@ aka  Insert the given pair AFTER position n (mutating).
	def InsertAfter(_n_, paPair)
		if _n_ >= 0 and _n_ <= This.NumberOfPairs()
			_aIaContent_ = This.Content()
			_aIaContent_ = ring_insert(_aIaContent_, _n_ + 1, paPair)
			This.UpdateWith(_aIaContent_)
		ok

		def InsertAfterQ(_n_, paPair)
			This.InsertAfter(_n_, paPair)
			return This

	  #------------------#
	 #     REMOVING     #
	#------------------#

	# Removes the pair at position n, in place.
	#
	#   _n_        the position, from 1
	#   returns    nothing; the hash list changes
	#   see        RemovePairByKey
	#@ aka  Remove the nth pair (mutating).
	def RemoveNthPair(_n_)

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
		del(_aRnpContent_, _n_)
		This.UpdateWith(_aRnpContent_)

		def RemoveNthPairQ(_n_)
			This.RemovePair(_n_)
			return This

	# Removes the given [ key, value ] pair, in place; a pair that is absent changes nothing.
	#
	#   paPair     the pair, [ key, value ]
	#   returns    nothing; the hash list changes
	#   see        RemoveNthPair
	#@ aka  Remove the given [key, value] pair (mutating).
	def RemovePair(paPair)
		_nRpPos_ = This.FindPair(paPair)
		if _nRpPos_ > 0
			This.RemoveNthPair(_nRpPos_)
		ok

		def RemovePairQ(paPair)
			This.RemovePair(paPair)
			return This
		
	# Removes the pair that holds the given key, in place.
	#
	#   pcKey      the key, as text
	#   returns    nothing; the hash list changes
	#   see        RemoveByKey
	#@ aka  Remove the pair holding the given key (mutating).
	def RemovePairByKey(pcKey)
		_nRpbkN_ = This.FindKey(pcKey)
		if _nRpbkN_ > 0
			del( This.HashList(), _nRpbkN_)
			This._InvalidateEngineMap()
		ok

		def RemovePairByKeyQ(pcKey)
			This.RemovePairByKey(pcKey)
			return This

		# Removes the pair that holds the given key, in place.
		#
		#   pcKey      the key, as text
		#   returns    nothing; the hash list changes
		#   see        RemovePairByKey
		def RemoveByKey(pcKey)
			This.RemovePairByKey(pcKey)
	
			def RemoveByKeyQ(pcKey)
				This.RemoveByKey(pcKey)
				return This

	# Removes the pairs that hold any of the given keys, in place.
	#
	#   pacKeys    the keys, as a list of text
	#   returns    nothing; the hash list changes
	#   see        RemovePairByKey
	#@ aka  Remove the pairs holding any of the given keys (mutating).
	def RemovePairsByKeys(pacKeys)
		if CheckingParams()
			if NOT (isList(pacKeys) and @IsListOfStrings(pacKeys))
				StzRaise("Incorrect param type! pacKeys must be a list of strings.")
			ok
		ok

		_nRpbksLen_ = len(pacKeys)

		for _iRpbks_ = 1 to _nRpbksLen_
			This.RemovePairByKey(pacKeys[_iRpbks_])
		next

	# Removes every pair that holds the given value, in place.
	#
	#   pValue     the value to remove
	#   returns    nothing; the hash list changes
	#   see        RemovePairsByValues
	#@ aka  Remove every pair holding the given value (mutating).
	def RemovePairsByValue(pValue)
		_anRpbvPos_ = This.FindValue(pValue)

		_aRpbvResult_ = StzListQ( This.HashList() ).RemoveItemsAtThesePositionsQ( _anRpbvPos_ ).Content()
		This.Update(_aRpbvResult_)

		def RemovePairsByValueQ(pValue)
			This.RemovePairsByValue(pValue)
			return This

	# Removes every pair that holds any of the given values, in place.
	#
	#   paValues   the values to remove
	#   returns    nothing; the hash list changes
	#   see        RemovePairsByValue
	#@ aka  Remove every pair holding any of the given values (mutating).
	def RemovePairsByValues(paValues)
		if CheckingParams()
			if NOT isList(paValues)
				StzRaise("Incorrect param type! paValues must be a list.")
			ok
		ok

		_nRpbvsLen_ = len(paValues)

		for _iRpbvs_ = 1 to _nRpbvsLen_
			This.RemovePairsByValue(paValues[_iRpbvs_])
		next

	  #------------------#
	 #  REPLACING KEYS  #
	#==================#

	# Renames the given key, in place.
	#
	#   pcKey      the key to rename
	#   pcNewKey   the new key
	#   returns    nothing; the hash list changes
	#   warning    a key that is absent raises an index error
	#   see        UpdateKey
	#@ aka  Same as UpdateKey: rename the given key (mutating).
	def ReplaceKey(pcKey, pcNewKey)
		_nRkN_ = This.FindKey(pcKey)
		This.ReplaceNthKey(_nRkN_, pcNewKey)

		def ReplaceKeyQ(pcKey, pcNewKey)
			This.ReplaceKey(pcKey, pcNewKey)
			return this

	# Replaces the key of the pair at position n, in place.
	#
	#   _n_        the position, from 1
	#   pcNewKey   the new key
	#   returns    nothing; the hash list changes
	#   see        ReplaceFirstKey
	#@ aka  Replace the key of the nth pair (mutating).
	def ReplaceNthKey(_n_, pcNewKey)
		if CheckingParam()
			if isList(pcNewKey) and Q(pcNewKey).IsWithOrByNamedParam()
				pcNewKey = pcNewKey[2]
			ok
		ok

		This.NthPair(_n_)[1] = pcNewKey
		This._InvalidateEngineMap()

		def ReplaceNthKeyQ(_n_, pcNewKey)
			This.ReplaceNthKey(_n_, pcNewKey)
			return This

	# Replaces the key of the first pair, in place.
	#
	#   pcNewKey   the new key
	#   returns    nothing; the hash list changes
	#   see        ReplaceLastKey, ReplaceNthKey
	#@ aka  Replace the key of the first pair (mutating).
	def ReplaceFirstKey(pcNewKey)
		This.ReplaceNthKey(1, pcNewKey)

		def ReplaceFirstKeyQ(pcNewKey)
			This.ReplaceFirstKey(pcNewKey)
			return This

	# Replaces the key of the last pair, in place.
	#
	#   pcNewKey   the new key
	#   returns    nothing; the hash list changes
	#   see        ReplaceFirstKey
	#@ aka  Replace the key of the last pair (mutating).
	def ReplaceLastKey(pcNewKey)
		This.ReplaceNthKey(This.NumberOfKeys(), pcNewKey)

		def ReplaceLastKeyQ(pcNewKey)
			This.ReplaceLastKey(pcNewKey)
			return This

	  #--------------------#
	 #  REPLACING VALUES  #
	#====================#

	# Replaces the first occurrence of the given value by a new one, in place.
	#
	#   pValue      the value to replace
	#   pNewValue   the new value
	#   returns    nothing; the hash list changes
	#   see         UpdateValue
	#@ aka  Replace the first occurrence of the given value (mutating).
	def ReplaceValue(pValue, pNewValue)
		_anRvPos_ = This.FindValue(pValue)
		if len(_anRvPos_) > 0
			This.UpdateNthValue(_anRvPos_[1], pNewValue)
		ok

		def ReplaceValueQ(pValue, pNewValue)
			This.ReplaceValue(pValue, pNewValue)
			return this

	# Replaces the value of the pair at position n, in place.
	#
	#   _n_         the position, from 1
	#   pNewValue   the new value
	#   returns     nothing; the hash list changes
	#   see         ReplaceFirstValue
	#@ aka  Replace the value of the nth pair (mutating).
	def ReplaceNthValue(_n_, pNewValue)

		if CheckingParam()
			if NOT isNumber(_n_) and isNumber(pNewValue)
				_rnvTemp_ = _n_
				_n_ = pNewValue
				pNewValue = _rnvTemp_
			ok

			if isList(pNewValue) and Q(pNewValue).IsWithOrByNamedParam()
				pNewValue = pNewValue[2]
			ok
		ok

		if NOT isNumber(_n_)
			StzRaise("Incorrect param type! n must be a number.")
		ok

		This.NthPair(_n_)[2] = pNewValue
		This._InvalidateEngineMap()

		# Replaces the value of the pair at position n, in place; ReplaceNthValue is the Softanza spelling.
		#
		#   _n_         the position, from 1
		#   pNewValue   the new value
		#   returns     nothing; the hash list changes
		#   see         ReplaceNthValue
		#@ aka  NOTE // Normally Set... does not belong to Softanza semantics, we use Replace instead. Here I use to cope with AI-generated code which tend to be alligned with the Set keyword
		def SetValueAt(_n_, pNewValue)
			This.ReplaceNthValue(_n_, pNewValue)

		def ReplaceNthValueQ(_n_, pNewValue)
			This.ReplaceNthValue(_n_, pNewValue)
			return This

		def SetValueAtQ(_n_, pNewValue)
			return This.ReplaceNthValueQ(_n_, pNewValue)


	# Replaces the value of the first pair, in place.
	#
	#   pNewValue   the new value
	#   returns     nothing; the hash list changes
	#   see         ReplaceLastValue, ReplaceNthValue
	#@ aka  Replace the value of the first pair (mutating).
	def ReplaceFirstValue(pNewValue)
		This.ReplaceNthValue(1, pNewValue)

		def ReplaceFirstValueQ(pNewValue)
			This.ReplaceFirstValue(pNewValue)
			return This

	# Replaces the value of the last pair, in place.
	#
	#   pNewValue   the new value
	#   returns     nothing; the hash list changes
	#   see         ReplaceFirstValue
	#@ aka  Replace the value of the last pair (mutating).
	def ReplaceLastValue(pNewValue)
		This.ReplaceNthValue(This.NumberOfValues(), pNewValue)

		def ReplaceLastValueQ(pNewValue)
			This.ReplaceLastValue(pNewValue)
			return This

	  #--------------------#
	 #  REPLACING VALUES  #
	#--------------------#

	# Replaces the value stored under the given key, in place.
	#
	#   pcKey       the key, as text
	#   pNewValue   the new value
	#   returns     nothing; the hash list changes
	#   warning     a key that is absent raises an index error
	#   see         ReplaceByKey
	#@ aka  Replace the value stored under the given key (mutating).
	def ReplaceValueByKey(pcKey, pNewValue)
		_nRvkN_ = This.FindKey(pcKey)
		This.HashList()[_nRvkN_][2] = pNewValue
		This._InvalidateEngineMap()

		def ReplaceValueByKeyQ(pcKey, pNewValue)
			This.ReplaceValueByKey(pcKey, pNewValue)
			return This

		# Replaces the value stored under the given key, in place.
		#
		#   pcKey       the key, as text
		#   pNewValue   the new value
		#   returns     nothing; the hash list changes
		#   warning     a key that is absent raises an index error
		#   see         ReplaceValueByKey
		def ReplaceByKey(pcKey, pNewValue)
			This.ReplaceValueByKey(pcKey, pNewValue)

			def ReplaceByKeyQ(pcKey, pNewValue)
				This.ReplaceByKey(pcKey, pNewValue)
				return This

	  #-------------------#
	 #  REPLACING PAIRS  #
	#===================#

	# Replaces the given pair by a new one, in place; a pair that is absent changes nothing.
	#
	#   paPair      the pair to replace
	#   paNewPair   the new pair
	#   returns    nothing; the hash list changes
	#   see         UpdateNthPair
	#@ aka  Replace the given pair with the new one (mutating).
	def ReplacePair(paPair, paNewPair)
		_nRpN_ = This.FindPair(paPair)
		if _nRpN_ > 0
			This.UpdateNthPair(_nRpN_, paNewPair)
		ok

		def ReplacePairQ(paPair, paNewPair)
			This.ReplacePair(paPair, paNewPair)
			return This

	# Replaces the pair that holds the given key by a new one, in place.
	#
	#   pcKey       the key
	#   paNewPair   the new pair
	#   returns    nothing; the hash list changes
	#   see         UpdateNthPair
	#@ aka  Replace the whole pair holding the given key (mutating).
	def ReplacePairByKey(pcKey, paNewPair)
		_nRpbkN_ = This.FindKey(pcKey)
		if _nRpbkN_ > 0
			This.UpdateNthPair(_nRpbkN_, paNewPair)
		ok
	
		def ReplacePairByKeyQ(pcKey, paNewPair)
			This.ReplacePairByKey(pcKey, paNewPair)
			return This

	# Raises an error: replacing the pairs that meet a condition is reserved and not built yet.
	#
	#   pcCondition   the condition, as W code
	#   returns       nothing; the call raises "Inexistant feature in this release!"
	#   status        reserved
	#@ aka  Conditional pair replacement (reserved: not yet implemented).
	def ReplacePairsW(pcCondition) // TODO
		/* ... */
		StzRaise("Inexistant feature in this release!")

	  #---------------------#
	 #     FINDING KEYS    #
	#---------------------#

	# Returns the positions of the given keys.
	#
	#   pacKeys    the keys, as a list of text
	#   returns    a list of numbers
	#   see        FindKey
	#@ aka  The positions of the given keys.
	def FindKeys(pacKeys)
		_aFksResult_ = This.KeysQ().FindMany(pacKeys)
		return _aFksResult_

		def FindTheseKeys(pacKeys)
			return This.FindKeys(pacKeys)

	# Returns the position of the given key.
	#
	#   pcKey      the key, as text
	#   returns    a number; 0 when the key is absent
	#   see        FindKeys, HasKey
	#@ aka  The position of the given key (0 if none).
	def FindKey(pcKey)

		if isString(pcKey)
			This._EnsureEngineMap()
			if @pEngineMap != ""
				return StzEngineHashMapFindKey(@pEngineMap, pcKey)
			ok
			return StzFindFirst(pcKey, Keys())
		ok

		def FindThisKey(pcKey)
			return This.FindKey(pcKey)

	# TRUE if the hash list holds the given key, whatever its case.
	#
	#   pcKey      the key to look for, as text
	#   returns    TRUE or FALSE
	#   see        Keys
	#   example    ? o1.HasKey("two")
	#              #--> TRUE
	#              ? o1.HasKey("TWO")
	#              #--> TRUE
	#              ? o1.HasKey("six")
	#              #--> FALSE
	#@ aka  TRUE if the hash list holds the given key.
	def HasKey(pcKey)

		if isString(pcKey)
			# Lower the PROBE: keys are stored lowercased, so asking the
			# engine map for the raw key missed every key whose case the
			# constructor had changed. That made HasKey case-SENSITIVE while
			# ValueByKey was case-insensitive, and made both answer "no" for
			# Greek/Cyrillic keys that were demonstrably present. The global
			# HasKey(paList, pcKey) has always lowered its probe; this is the
			# method agreeing with it.
			_cHkKey_ = StzLower(pcKey)

			This._EnsureEngineMap()
			if @pEngineMap != ""
				return StzEngineHashMapHasKey(@pEngineMap, _cHkKey_)
			ok
			if This.FindKey(_cHkKey_) > 0
				return 1
			ok
		ok
		return 0

		def ContainsKey(pcKey)
			return This.HasKey(pcKey)
		
	# TRUE if the hash list holds every one of the given keys.
	#
	#   pacKeys    the keys, as a list of text
	#   returns    TRUE or FALSE
	#   see        HasKey
	#@ aka  TRUE if the hash list holds ALL the given keys.
	def HasKeys(pacKeys)

		_oKeys_ = new stzList(pacKeys)
		if _oKeys_.IsListOfStrings() and
		   _oKeys_.IsEqualTo(This.Keys())

			return 1
		else
			return 0
		ok

		def ContainsKeys(pacKeys)
			return This.HasKeys(pacKeys)

	  #-----------------#
	 #  FINDING PAIRS  #
	#-----------------#

	# Returns the position of the given [ key, value ] pair.
	#
	#   paPair     the pair, [ key, value ]
	#   returns    a number; 0 when the pair is absent
	#   see        ContainsPair
	#@ aka  The position of the given [key, value] pair (0 if none).
	def FindPair(paPair)
		if NOT isList(paPair)
			StzRaise("Incorrect param type! paPair must be a list.")
		ok

		if NOT @IsPairAndKeyIsString(paPair)
			StzRaise("Can't search the list." + char(10) + "Because paPair is not a pair!")
		ok

		_aFpContent_ = This.Content()
		_nFpLen_ = len(_aFpContent_)

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


	# TRUE if the hash list holds the given [ key, value ] pair.
	#
	#   paPair     the pair, [ key, value ]
	#   returns    TRUE or FALSE
	#   see        FindPair
	#@ aka  TRUE if the hash list holds the given pair.
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

	# TRUE if some pair holds the given value, ignoring case.
	#
	#   pValue     the value to look for
	#   returns    TRUE or FALSE
	#   see        ContainsValues, FindValue
		#>
	#@ aka  -- WITHOUT CASESENSITIVE
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

	# TRUE if every one of the given values occurs, ignoring case.
	#
	#   paValues   the values to look for
	#   returns    TRUE or FALSE
	#   see        ContainsValue
		#>
	#@ aka  -- WITHOUT CASESENSITIVE
	def ContainsValues(paValues)
		return This.ContainsValuesCS(paValues, 1)

		# Tells whether every one of the given values occurs among the values.
		#
		#   paValues   the values to look for
		#   returns    TRUE or FALSE
		#   see        ContainsValues
		#< @FunctionAlternativeForms
		def ContainsTheseValues(paValues)
			return This.ContainsValues(paValues)

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

	# Returns the positions of the pairs that hold the given value, ignoring case.
	#
	#   pValue     the value to look for
	#   returns    a list of numbers; [ ] when no pair holds the value
	#   note       FindValueCS takes a case-sensitivity flag
	#   see        FindFirstOccurrenceOfValue, FindNthOccurrenceOfValue, HasKey
	#   example    ? @@( o1.FindValue("a") )
	#              #--> [ 1, 3 ]
	#              ? @@( o1.FindValue("z") )
	#              #--> [ ]
		#>
	#@ aka  -- WITHOUT CASESENSITIVITY
	def FindValue(pValue)
		return This.FindValueCS(pValue, 1)

		#< @FunctionAlternativeForms

		def FindAllOccurrencesOfValue(pValue)
			return This.FindValue(pValue)

		def Find(pValue)
			return This.FindValue(pValue)

		# Returns the positions of the pairs that hold the given value, as FindValue does.
		#
		#   pValue     the value to look for
		#   returns    a list of numbers
		#   see        FindValue
		#@ aka  The positions of the given value (works for item-style lookups too).
		def FindValueOrItem(pValue)
			# Match both: value == pValue, or value is a list that
			# contains pValue as one of its items. Returns the keys'
			# positions sorted ascending.
			_anFvoiResult_ = []
			_aVals_ = This.Values()
			_nLen_ = len(_aVals_)
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

	# Returns the positions of the pairs that hold any of the given values, ignoring case.
	#
	#   paValues   the values to look for
	#   returns    a list of numbers
	#   see        FindValue
		#>
	#@ aka  -- WITHOUT CASESENSITIVITY
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

	def FindNthOccurrenceOfValueCS(_n_, pValue, pCaseSensitive)

		if CheckingParams()

			if _n_ = :First
				_n_ = 1
			but _n_ = :Last
				_n_ = This.NumberOfOccurreceOfValueCS(pValue, pCaseSensitive)
			ok
	
			if NOT isNumber(_n_)
				StzRaise("Incorrect param type! n must be a number.")
			ok

		ok

		return This.FindValueCS(pValue, pCaseSensitive)[_n_]

		#< @FunctionAlternativeForms

		def FindNthValueCS(_n_, pValue, pCaseSensitive)
			return This.FindNthOccurrenceOfValueCS(_n_, pValue, pCaseSensitive)

		def FindNthCS(_n_, pValue, pCaseSensitive)
			return This.FindNthOccurrenceOfValueCS(_n_, pValue, pCaseSensitive)

	# Returns the position of the pair that holds the given value for the nth time, ignoring case.
	#
	#   _n_        which occurrence, counting from 1
	#   pValue     the value to look for
	#   returns    a number, the position of that pair
	#   warning    when there are fewer than n occurrences the call raises an error (index out of
	#              range) instead of answering 0
	#   see        FindValue, FindFirstOccurrenceOfValue
	#   example    ? o1.FindNthOccurrenceOfValue(2, "a")
	#              #--> 3
		#>
	#@ aka  -- WITHOUT CASESENSITIVITY
	def FindNthOccurrenceOfValue(_n_, pValue)
		return This.FindNthOccurrenceOfValueCS(_n_, pValue, 1)

		#< @FunctionAlternativeForms

		def FindNthValue(_n_, pValue)
			return This.FindNthOccurrenceOfValue(_n_, pValue)

		def FindNth(_n_, pValue)
			return This.FindNthOccurrenceOfValue(_n_, pValue)

		#>

	  #---------------------------------------------#
	 #   FINDING THE FIRST OCCURRENCE OF A VALUE   #TODO // Add case sensitivity
	#---------------------------------------------#

	# Returns the position of the first pair that holds the given value.
	#
	#   pValue     the value to look for
	#   returns    a number, the position of the first pair holding the value
	#   warning    when no pair holds the value the call raises an error (index out of range)
	#              instead of answering 0
	#   see        FindValue, FindLastOccurrenceOfValue, FindNthOccurrenceOfValue
	#   example    ? o1.FindFirstOccurrenceOfValue("a")
	#              #--> 1
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

	# Returns the position of the last pair that holds the given value, 0 when none does.
	#
	#   pValue     the value to look for
	#   returns    a number
	#   see        FindValue, FindFirstOccurrenceOfValue
	def FindLastOccurrenceOfValue(pValue)
		_anFlovPos_ = This.FindValue(pValue)
		if len(_anFlovPos_) > 0
			return _anFlovPos_[ len(_anFlovPos_) ]
		ok
		return 0

		def FindLastValue(pValue)
			return This.FindLastOccurrenceOfValue(pValue) 

		def FindLast(pValue)
			return This.FindLastOccurrenceOfValue(pValue) 

	  #---------------------------#
	 #   FINDING KEYS BY VALUE   #TODO // Add case sensitivity
	#---------------------------#

	# Returns the positions of the pairs that hold the given value.
	#
	#   pValue     the value to look for
	#   returns    a list of numbers
	#   see        FindValue, KeysByValue
	def FindKeysByValue(pValue)

		_aFkbvContent_ = This.HashList()
		_nFkbvLen_ = len(_aFkbvContent_)

		_anFkbvResult_ = []

		# Q(value).Contains(...) built a whole stz OBJECT for EVERY pair just
		# to ask a containment question -- n object constructions per call,
		# which is why one KeysByValue over 8000 pairs took 1.75s. The two
		# shapes that actually occur are answered directly; anything else
		# still goes through Q(), so no semantics move.

		for _iFkbv_ = 1 to _nFkbvLen_
			_vFkbvVal_ = _aFkbvContent_[_iFkbv_][2]
			_bFkbvHit_ = 0

			if isString(_vFkbvVal_)
				# A string value CONTAINS a substring. A NON-string needle
				# cannot be inside a string, and it is answered here rather
				# than passed on because Q(string).Contains(number) takes
				# Ring down hard -- exit 1, no message, no output at all.
				if isString(pValue)
					if StzFindFirst(pValue, _vFkbvVal_) > 0
						_bFkbvHit_ = 1
					ok
				ok

			but isList(_vFkbvVal_)
				# a list value CONTAINS an item
				if ring_find(_vFkbvVal_, pValue) > 0
					_bFkbvHit_ = 1
				ok

			but isNumber(_vFkbvVal_)
				# a number holds nothing but itself (Q(number).Contains
				# answered 0 even for the number itself)
				if isNumber(pValue) and _vFkbvVal_ = pValue
					_bFkbvHit_ = 1
				ok

			else
				if Q(_vFkbvVal_).Contains(pValue)
					_bFkbvHit_ = 1
				ok
			ok

			if _bFkbvHit_
				@AddItem(_anFkbvResult_, _iFkbv_)
			ok
		next

		return _anFkbvResult_

	  #------------------------------#
	 #   FINDING NTH KEY BY VALUE   #TODO // Add case sensitivity
	#------------------------------#

	# Returns the position of the nth pair that holds the given value.
	#
	#   _n_        which occurrence, from 1
	#   pValue     the value to look for
	#   returns    a number
	#   see        FindNthOccurrenceOfValue
	def FindNthKeyByValue(_n_, pValue)
		# FindKeysByValue searches INSIDE list-valued entries via .Contains,
		# but ContainsValue compares the whole value -- so guarding on
		# ContainsValue would always return 0 for sub-item lookups.
		# Guard directly on the result of FindKeysByValue instead.
		_nFnkbvResult_ = 0
		_anFnkbvPos_ = This.FindKeysByValue(pValue)
		if len(_anFnkbvPos_) >= _n_
			_nFnkbvResult_ = _anFnkbvPos_[_n_]
		ok
		return _nFnkbvResult_

	  #--------------------------------#
	 #   FINDING FIRST KEY BY VALUE   #TODO // Add case sensitivity
	#--------------------------------#

	# Returns the position of the first pair that holds the given value.
	#
	#   pValue     the value to look for
	#   returns    a number
	#   see        FindFirstOccurrenceOfValue
	def FindFirstKeyByValue(pValue)
		_nFfkbvResult_ = 0
		_anFfkbvPos_ = This.FindKeysByValue(pValue)
		if len(_anFfkbvPos_) > 0
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

	# Returns the key of the last pair that holds the given value.
	#
	#   pValue     the value to look for
	#   returns    a string
	#   note       unlike FindFirstKeyByValue, which answers a position, it answers the key
	#   see        FindFirstKeyByValue
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

	# Returns the key of the first pair that holds the given value.
	#
	#   pValue     the value to look for
	#   returns    a string
	#   see        KeysByValue, FindKeysByValue
	def KeyByValue(pValue)
		_acKbvKeys_ = This.KeysByValue(pValue)
		_nKbvLen_ = len(_acKbvKeys_)

		if _nKbvLen_ = 0
			return ""
		ok

		_cKbvResult_ = _acKbvKeys_[1]
		return _cKbvResult_
	
	  #-----------------------------------------------------#
	 #   GETTING THE KEYS CORRESPONDING TO A GIVEN VALUE   #TODO // Add case sensitivity
	#-----------------------------------------------------#

	# Returns the keys of every pair that holds the given value.
	#
	#   pValue     the value to look for
	#   returns    a list of strings
	#   see        KeyByValue, FindKeysByValue
	def KeysByValue(pValue)
		_anKsbvPos_ = This.FindKeysByValue(pValue)
		_acKsbvResult_ = This.KeysAtPositions(_anKsbvPos_)

		return _acKsbvResult_

	  #---------------------------------------------------------#
	 #  GETTING THE KEYS CORRESPONDING TO THE PROVIDED VALUES  #
	#---------------------------------------------------------#

	# Returns the keys of the pairs holding any of the given values, once each, in order.
	#
	#   paValues   the values to look for
	#   returns    a list of the keys
	#   note       a text is found inside a longer text value too, as KeysByValue finds it
	#   see        KeysByValue
	def KeysByValues(paValues)
		_nKsbvsLen_ = len(paValues)

		# the positions of every pair that holds any of the values, once each, in order
		_anKsbvsPos_ = []
		for _iKsbvs_ = 1 to _nKsbvsLen_
			_anKsbvsOne_ = This.FindKeysByValue(paValues[_iKsbvs_])
			_nKsbvsOne_ = len(_anKsbvsOne_)
			for _jKsbvs_ = 1 to _nKsbvsOne_
				if ring_find(_anKsbvsPos_, _anKsbvsOne_[_jKsbvs_]) = 0
					@AddItem(_anKsbvsPos_, _anKsbvsOne_[_jKsbvs_])
				ok
			next
		next

		_oKsbvsSort_ = new stzList(_anKsbvsPos_)
		_anKsbvsPos_ = _oKsbvsSort_.Sorted()

		return This.KeysAtPositions(_anKsbvsPos_)

	  #----------------------------------------------#
	 #  GETTING THE KEYS AT THE PROVIDED POSITIONS  #
	#==============================================#

	# Returns the keys of the pairs at the given positions.
	#
	#   panPos     the positions
	#   returns    a list of strings
	#   see        ValuesAtPositions
	def KeysAtPositions(panPos)
		_acKapResult_ = This.KeysQ().ItemsAtPositions(panPos)
		return _acKapResult_

		def KeysAtThesePositions(panPos)
			return This.KeysAtPositions(panPos)

	  #-----------------------------------------#
	 #  FINDING LISTS (VALUES THAT ARE LISTS)  #
	#=========================================#
	# Returns the positions of the pairs whose value is a list.
	#
	#   returns    a list of numbers
	#   see        Lists
	#TODO // Add case sensitivity
	def FindLists()
		_aFlContent_ = This.Content()
		_nFlLen_ = len(_aFlContent_)

		_anFlResult_ = []

		for _iFl_ = 1 to _nFlLen_
			if isList(_aFlContent_[_iFl_][2])
				@AddItem(_anFlResult_, _iFl_)
			ok
		next

		return _anFlResult_

	# Returns the positions of the pairs whose value is not a list.
	#
	#   returns    a list of numbers
	#   see        FindLists
	def FindNonLists()
		# Return the positions whose value is NOT a list.
		# (Previous impl used `Q(1:N) - These(...)` which depends on
		# a `-` operator overload that doesn't exist on stzList in
		# the modular build. Direct walk is both simpler and faster.)
		_anFnlListPos_ = This.FindLists()
		_aFnlContent_ = This.Content()
		_nFnlLen_ = len(_aFnlContent_)
		_anFnlR_ = []
		for _iFnl_ = 1 to _nFnlLen_
			if ring_find(_anFnlListPos_, _iFnl_) = 0
				_anFnlR_ + _iFnl_
			ok
		next
		return _anFnlR_

	# Returns the values that are lists.
	#
	#   returns    a list of lists
	#   see        FindLists
	def Lists()
		_aLsContent_ = This.Content()
		_nLsLen_ = len(_aLsContent_)

		_aLsResult_ = []

		for _iLs_ = 1 to _nLsLen_
			if isList(_aLsContent_[_iLs_][2])
				@AddItem(_aLsResult_, _aLsContent_[_iLs_][2])
			ok
		next

		return _aLsResult_

	def ListsZ()
		_aLszU_ = U( This.Lists() )
		_nLszLen_ = len(_aLszU_)

		_aLszResult_ = []

		for _iLsz_ = 1 to _nLszLen_
			@AddItem(_aLszResult_, [ _aLszU_[_iLsz_], This.FindList(_aLszU_[_iLsz_]) ])
		next

		return _aLszResult_

	# Returns the positions of the pairs whose value is the given list.
	#
	#   paList     the list to look for
	#   returns    a list of numbers
	#   see        FindTheseLists
	def FindList(paList) # Add case sensitivity

		if CheckingParams()
			if NOT isList(paList)
				StzRaise("Incorrect param type! paList must be a list.")
			ok
		ok

		_anFlsPos_ = Q(This.Lists()).Find(paList)
		_anFlsResult_ = []
		if len(_anFlsPos_) > 0
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

	# Returns the positions of the pairs whose value is one of the given lists.
	#
	#   paLists    the lists, as a list of lists
	#   returns    a list of numbers
	#   see        FindList
	def FindTheseLists(paLists)
		if CheckingParams()
			if NOT ( isList(paLists) and @IsListOfLists(paLists) )
				StzRaise("Incorrect param type! paLists must be a list of lists.")
			ok
		ok

		paLists = U(paLists) # Duplicates removed
		_nFtlLen_ = len(paLists)
		_anFtlResult_ = []

		for _iFtl_ = 1 to _nFtlLen_
			_anFtlPos_ = This.FindList(paLists[_iFtl_])
			_nFtlLenPos_ = len(_anFtlPos_)

			for _jFtl_ = 1 to _nFtlLenPos_
				@AddItem(_anFtlResult_, _anFtlPos_[_jFtl_])
			next
		next

		_oTmpSort_ = new stzList(_anFtlResult_)
		_anFtlResult_ = _oTmpSort_.Sorted()
		return _anFtlResult_

	# Returns each given list with the positions of the pairs whose value is that list.
	#
	#   paLists    the lists, as a list of lists
	#   returns    a list of [ list, positions ] pairs
	#   see        FindTheseLists
	def TheseListsZ(paLists)
		if CheckingParams()
			if NOT ( isList(paLists) and @IsListOfLists(paLists) )
				StzRaise("Incorrect param type! paLists must be a list of lists.")
			ok
		ok

		_nTlzLen_ = len(paLists)
		_aTlzResult_ = []

		for _iTlz_ = 1 to _nTlzLen_
			@AddItem(_aTlzResult_, [ paLists[_iTlz_], This.FindList(paLists[_iTlz_]) ])
		next

		return _aTlzResult_

	#--

	  #---------------------------------------------#
	 #  FINDING NUMBERS (VALUES THAT ARE NUMBERS)  #
	#=============================================#
	# Returns the positions of the pairs whose value is a number.
	#
	#   returns    a list of numbers
	#   see        Numbers
	#TODO // Add case sensitivity
	def FindNumbers()
		_aFnContent_ = This.Content()
		_nFnLen_ = len(_aFnContent_)

		_anFnResult_ = []

		for _iFn_ = 1 to _nFnLen_
			if isNumber(_aFnContent_[_iFn_][2])
				@AddItem(_anFnResult_, _iFn_)
			ok
		next

		return _anFnResult_

	# Returns the values that are numbers, in order.
	#
	#   returns    a list of numbers
	#   see        Values
	#   example    ? @@( o1.Numbers() )
	#              #--> [ 4 ]
	def Numbers()
		_aNsContent_ = This.Content()
		_nNsLen_ = len(_aNsContent_)

		_aNsResult_ = []

		for _iNs_ = 1 to _nNsLen_
			if isNumber(_aNsContent_[_iNs_][2])
				@AddItem(_aNsResult_, _aNsContent_[_iNs_][2])
			ok
		next

		return _aNsResult_

	def NumbersZ()
		_aNszU_ = U( This.Numbers() )
		_nNszLen_ = len(_aNszU_)

		_aNszResult_ = []

		for _iNsz_ = 1 to _nNszLen_
			@AddItem(_aNszResult_, [ _aNszU_[_iNsz_], This.FindNumber(_aNszU_[_iNsz_]) ])
		next

		return _aNszResult_

	# Returns the positions of the pairs whose value is the given number.
	#
	#   paNumber   the number to look for
	#   returns    a list of numbers
	#   see        FindValue
	def FindNumber(paNumber) # Add case sensitivity

		if CheckingParams()
			if NOT isNumber(paNumber)
				StzRaise("Incorrect param type! paNumber must be a number.")
			ok
		ok

		_anFnbPos_ = Q(This.Numbers()).Find(paNumber)
		_anFnbResult_ = []
		if len(_anFnbPos_) > 0
			_anFnbResult_ = Q(This.FindNumbers()).ItemsAtPositions(_anFnbPos_)
		ok

		return _anFnbResult_

	# Returns the given number with the positions of the pairs that hold it.
	#
	#   paNumber   the number to look for
	#   returns    a pair, [ number, positions ]
	#   see        FindValue
	def NumberZ(paNumber)
		if CheckingParams()
			if NOT isNumber(paNumber)
				StzRaise("Incorrect param type! paNumber must be a number.")
			ok
		ok

		_anNzPos_ = This.FindNumber(paNumber)
		_aNzResult_ = [ paNumber, _anNzPos_ ]
		return _aNzResult_

	# Returns the positions of the pairs whose value is any of the given numbers, in order.
	#
	#   paNumbers  the numbers to look for, as a list
	#   returns    a list of numbers
	#   see         FindValue
	def FindTheseNumbers(paNumbers)
		if CheckingParams()
			if NOT ( isList(paNumbers) and @IsListOfNumbers(paNumbers) )
				StzRaise("Incorrect param type! paNumbers must be a list of numbers.")
			ok
		ok

		paNumbers = U(paNumbers) # Duplicates removed
		_nFtnLen_ = len(paNumbers)
		_anFtnResult_ = []

		for _iFtn_ = 1 to _nFtnLen_
			_anFtnPos_ = This.FindNumber(paNumbers[_iFtn_])
			_nFtnLenPos_ = len(_anFtnPos_)

			for _jFtn_ = 1 to _nFtnLenPos_
				@AddItem(_anFtnResult_, _anFtnPos_[_jFtn_])
			next
		next

		_oTmpSort_ = new stzList(_anFtnResult_)
		_anFtnResult_ = _oTmpSort_.Sorted()
		return _anFtnResult_

	# Returns each given number with the positions of the pairs that hold it.
	#
	#   paNumbers  the numbers to look for, as a list
	#   returns    a list of [ number, positions ] pairs
	#   see         FindValue
	def TheseNumbersZ(paNumbers)
		if CheckingParams()
			if NOT ( isList(paNumbers) and @IsListOfNumbers(paNumbers) )
				StzRaise("Incorrect param type! paNumbers must be a list of numbers.")
			ok
		ok

		_nTnzLen_ = len(paNumbers)
		_aTnzResult_ = []

		for _iTnz_ = 1 to _nTnzLen_
			@AddItem(_aTnzResult_, [ paNumbers[_iTnz_], This.FindNumber(paNumbers[_iTnz_]) ])
		next

		return _aTnzResult_

	  #--------------------------------------------#
	 #  FINDING STRINGS (VALUES THAT ARE STRING)  #
	#============================================#
	# Returns the positions of the pairs whose value is text.
	#
	#   returns    a list of numbers
	#   see        Strings
	#TODO // Add case sensitivity
	def FindStrings()
		_aFsContent_ = This.Content()
		_nFsLen_ = len(_aFsContent_)

		_anFsResult_ = []

		for _iFs_ = 1 to _nFsLen_
			if isString(_aFsContent_[_iFs_][2])
				@AddItem(_anFsResult_, _iFs_)
			ok
		next

		return _anFsResult_

	# Returns the values that are text.
	#
	#   returns    a list of strings
	#   see        Numbers, FindStrings
	def Strings()
		_aSsContent_ = This.Content()
		_nSsLen_ = len(_aSsContent_)

		_aSsResult_ = []

		for _iSs_ = 1 to _nSsLen_
			if isString(_aSsContent_[_iSs_][2])
				@AddItem(_aSsResult_, _aSsContent_[_iSs_][2])
			ok
		next

		return _aSsResult_

	def StringsZ()
		_aSszU_ = U( This.Strings() )
		_nSszLen_ = len(_aSszU_)

		_aSszResult_ = []

		for _iSsz_ = 1 to _nSszLen_
			@AddItem(_aSszResult_, [ _aSszU_[_iSsz_], This.FindString(_aSszU_[_iSsz_]) ])
		next

		return _aSszResult_

	# Returns the positions of the pairs whose value is the given text.
	#
	#   paString   the text to look for
	#   returns    a list of numbers
	#   see        FindValue
	def FindString(paString) # Add case sensitivity

		if CheckingParams()
			if NOT isString(paString)
				StzRaise("Incorrect param type! paString must be a string.")
			ok
		ok

		_anFsbPos_ = Q(This.Strings()).Find(paString)
		_anFsbResult_ = []
		if len(_anFsbPos_) > 0
			_anFsbResult_ = Q(This.FindStrings()).ItemsAtPositions(_anFsbPos_)
		ok

		return _anFsbResult_

	# Returns the given text with the positions of the pairs that hold it.
	#
	#   paString   the text to look for
	#   returns    a pair, [ text, positions ]
	#   see        FindValue
	def StringZ(paString)
		if CheckingParams()
			if NOT isString(paString)
				StzRaise("Incorrect param type! paString must be a string.")
			ok
		ok

		_anSzPos_ = This.FindString(paString)
		_aSzResult_ = [ paString, _anSzPos_ ]
		return _aSzResult_

	# Returns the positions of the pairs whose value is any of the given texts, in order.
	#
	#   paStrings  the texts to look for, as a list
	#   returns    a list of numbers
	#   see         FindValue
	def FindTheseStrings(paStrings)
		if CheckingParams()
			if NOT ( isList(paStrings) and @IsListOfStrings(paStrings) )
				StzRaise("Incorrect param type! paStrings must be a list of strings.")
			ok
		ok

		paStrings = U(paStrings) # Duplicates removed
		_nFtsLen_ = len(paStrings)
		_anFtsResult_ = []

		for _iFts_ = 1 to _nFtsLen_
			_anFtsPos_ = This.FindString(paStrings[_iFts_])
			_nFtsLenPos_ = len(_anFtsPos_)

			for _jFts_ = 1 to _nFtsLenPos_
				@AddItem(_anFtsResult_, _anFtsPos_[_jFts_])
			next
		next

		_oTmpSort_ = new stzList(_anFtsResult_)
		_anFtsResult_ = _oTmpSort_.Sorted()
		return _anFtsResult_

	# Returns each given text with the positions of the pairs that hold it.
	#
	#   paStrings  the texts to look for, as a list
	#   returns    a list of [ text, positions ] pairs
	#   see         FindValue
	def TheseStringsZ(paStrings)
		if CheckingParams()
			if NOT ( isList(paStrings) and @IsListOfStrings(paStrings) )
				StzRaise("Incorrect param type! paStrings must be a list of strings.")
			ok
		ok

		_nTszLen_ = len(paStrings)
		_aTszResult_ = []

		for _iTsz_ = 1 to _nTszLen_
			@AddItem(_aTszResult_, [ paStrings[_iTsz_], This.FindString(paStrings[_iTsz_]) ])
		next

		return _aTszResult_

	  #---------------------------------------------#
	 #  FINDING OBJECTS (VALUES THAT ARE OBJECTS)  #
	#=============================================#
	# Returns the positions of the pairs whose value is an object.
	#
	#   returns    a list of numbers
	#   see        Objects
	#TODO // Add case sensitivity
	def FindObjects()
		_aFoContent_ = This.Content()
		_nFoLen_ = len(_aFoContent_)

		_anFoResult_ = []

		for _iFo_ = 1 to _nFoLen_
			if isObject(_aFoContent_[_iFo_][2])
				@AddItem(_anFoResult_, _iFo_)
			ok
		next

		return _anFoResult_

	# Returns the values that are objects.
	#
	#   returns    a list of objects
	#   see        FindObjects
	def Objects()
		_aOsContent_ = This.Content()
		_nOsLen_ = len(_aOsContent_)

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
	# Returns the positions of the pairs whose value is a stzList.
	#
	#   returns    a list of numbers
	#   see        StzLists
	#TODO // Add case sensitivity
	def FindStzLists()
		_aFszlContent_ = This.Content()
		_nFszlLen_ = len(_aFszlContent_)

		_anFszlResult_ = []

		for _iFszl_ = 1 to _nFszlLen_
			if @IsStzList(_aFszlContent_[_iFszl_][2])
				@AddItem(_anFszlResult_, _iFszl_)
			ok
		next

		return _anFszlResult_

	# Returns the values that are stzList objects.
	#
	#   returns    a list of objects
	#   see        FindStzLists
	def StzLists()
		_aSzlContent_ = This.Content()
		_nSzlLen_ = len(_aSzlContent_)

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
	# Returns the positions of the pairs whose value is a stzHashList.
	#
	#   returns    a list of numbers
	#   see        StzHashLists
	#TODO // Add case sensitivity
	def FindStzHashLists()
		_aFszhlContent_ = This.Content()
		_nFszhlLen_ = len(_aFszhlContent_)

		_anFszhlResult_ = []

		for _iFszhl_ = 1 to _nFszhlLen_
			if @IsStzHashList(_aFszhlContent_[_iFszhl_][2])
				@AddItem(_anFszhlResult_, _iFszhl_)
			ok
		next

		return _anFszhlResult_

	# Returns the values that are stzHashList objects.
	#
	#   returns    a list of objects
	#   see        FindStzHashLists
	def StzHashLists()
		_aSzhlContent_ = This.Content()
		_nSzhlLen_ = len(_aSzhlContent_)

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
	# Returns the positions of the pairs whose value is a stzNumber.
	#
	#   returns    a list of numbers
	#   see        StzNumbers
	#TODO // Add case sensitivity
	def FindStzNumbers()
		_aFsznContent_ = This.Content()
		_nFsznLen_ = len(_aFsznContent_)

		_anFsznResult_ = []

		for _iFszn_ = 1 to _nFsznLen_
			if @IsStzNumber(_aFsznContent_[_iFszn_][2])
				@AddItem(_anFsznResult_, _iFszn_)
			ok
		next

		return _anFsznResult_

	# Returns the values that are stzNumber objects.
	#
	#   returns    a list of objects
	#   see        FindStzNumbers
	def StzNumbers()
		_aSznContent_ = This.Content()
		_nSznLen_ = len(_aSznContent_)

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
	# Returns the positions of the pairs whose value is a stzString.
	#
	#   returns    a list of numbers
	#   see        StzStrings
	#TODO // Add case sensitivity
	def FindStzStrings()
		_aFszsContent_ = This.Content()
		_nFszsLen_ = len(_aFszsContent_)

		_anFszsResult_ = []

		for _iFszs_ = 1 to _nFszsLen_
			if @IsStzString(_aFszsContent_[_iFszs_][2])
				@AddItem(_anFszsResult_, _iFszs_)
			ok
		next

		return _anFszsResult_

	# Returns the values that are stzString objects.
	#
	#   returns    a list of objects
	#   see        FindStzStrings
	def StzStrings()
		_aSzsContent_ = This.Content()
		_nSzsLen_ = len(_aSzsContent_)

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
	# Returns the positions of the pairs whose value is a Softanza object.
	#
	#   returns    a list of numbers
	#   see        StzObjects
	#TODO // Add case sensitivity
	def FindStzObjects()
		_aFszoContent_ = This.Content()
		_nFszoLen_ = len(_aFszoContent_)

		_anFszoResult_ = []

		for _iFszo_ = 1 to _nFszoLen_
			if @IsStzObject(_aFszoContent_[_iFszo_][2])
				@AddItem(_anFszoResult_, _iFszo_)
			ok
		next

		return _anFszoResult_

	# Returns the values that are Softanza objects.
	#
	#   returns    a list of objects
	#   see        FindStzObjects
	def StzObjects()
		_aSzoContent_ = This.Content()
		_nSzoLen_ = len(_aSzoContent_)

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
	# TRUE if some list value holds the given item.
	#
	#   pItem      the item to look for inside the list values
	#   returns    TRUE or FALSE
	#   see        FindItem
	#TODO // Add case sensitivity
	#@ aka  SEMANTIC NOTE: An "Item" in the context of stzHashList, refers to values that are lists, and those lists contain the item. See examples hereafter.
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
		_nCiLen_ = len(_aCiContent_)

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
	# Returns, for each list value holding the item, the pair's position and the item's positions inside that list.
	#
	#   pItem      the item to look for inside the list values
	#   returns    a list of [ position of the pair, list of positions of the item ] pairs
	#   see        Items, NumberOfItems
	#   example    o1 = new stzHashList([ :one = :NONE, :two = [ :is, :will, :can ], :three = [ :can, :will ] ])
	#              ? @@( o1.FindItem(:can) )
	#              #--> [ [ 2, [ 3 ] ], [ 3, [ 1 ] ] ]
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
		_nFiLen_ = len(_aFiContent_)

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

	# Returns the places of the given items, as [ pair position, position in the value ] pairs.
	#
	#   paItems    the items to look for
	#   returns    a list of pairs
	#   see        FindItem
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
		_nFtiLen1_ = len(_aFtiT1_)

		# Step 2 : we  take the positions (pairs) and put them in a list

		_aFtiT2_ = []

		for _iFti1_ = 1 to _nFtiLen1_
			_aFtiPos1_ = _aFtiT1_[_iFti1_][2]
			_nFtiLenPos1_ = len(_aFtiPos1_)

			for _jFti1_ = 1 to _nFtiLenPos1_
				@AddItem(_aFtiT2_, _aFtiPos1_[_jFti1_])
			next
		next

		# Step 2 : we factorise the obtained list to get the positions

		_nFtiLen2_ = len(_aFtiT2_)
		_aFtiResult_ = []

		for _iFti2_ = 1 to _nFtiLen2_
			_nFtiLenPos2_ = len(_aFtiT2_[_iFti2_][2])
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

	# Returns each given item with its places, as [ item, [ [ pair position, [ positions ] ], ... ] ] pairs.
	#
	#   paItems    the items to look for
	#   returns    a list of pairs
	#   see        FindTheseItems
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

		_nTizLen_ = len(paItems)
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

	# Returns the items of all the list values, merged, each item once.
	#
	#   returns    a list of the distinct items
	#   see        NumberOfItems, FindItem
	#   example    o1 = new stzHashList([ :one = :NONE, :two = [ :is, :will, :can ], :three = [ :can, :will ] ])
	#              ? @@( o1.Items() )
	#              #--> [ "is", "will", "can" ]
		#<
	def Items()

		_aItmResult_ = U( This.ValuesQ().OnlyListsQ().Merged() )
		return _aItmResult_

	# Returns the place of every item of the list values, as [ pair position, position in the value ] pairs.
	#
	#   returns    a list of pairs
	#   see        FindItem, Items
	def FindItems()

		_aFimIndex_ = This.Copy().ListifyQ().ValuesQRT(:stzListOfLists).IndexXT()

		_aFimItems_ = This.Items()
		_nFimLen_ = len(_aFimIndex_)

		_aFimResult_ = []

		for _iFim_ = 1 to _nFimLen_
			_aFimPairs_ = _aFimIndex_[_iFim_][2]
			_nFimLenPairs_ = len(_aFimPairs_)
			for _jFim_ = 1 to _nFimLenPairs_
				@AddItem(_aFimResult_, _aFimPairs_[_jFim_])
			next
		next

		return _aFimResult_

	def ItemsZ()

		_aItmzIndex_ = This.Copy().ListifyQ().ValuesQRT(:stzListOfLists).IndexXT()

		_aItmzItems_ = This.Items()
		_anItmzPos_ = QRT(_aItmzIndex_, :stzHashList).FindTheseKeys(_aItmzItems_)
		_nItmzLen_ = len(_anItmzPos_)

		_aItmzResult_ = []
		for _iItmz_ = 1 to _nItmzLen_
			@AddItem(_aItmzResult_, _aItmzIndex_[_anItmzPos_[_iItmz_]])
		next

		return _aItmzResult_

	# Returns how many different items the list values hold, counting each item once.
	#
	#   returns    a number
	#   note       only the values that are lists are looked into; the items of two lists that share
	#              one are counted once
	#   see        Items, FindItem
	#   example    o1 = new stzHashList([ :one = :NONE, :two = [ :is, :will, :can ], :three = [ :can, :will ] ])
	#              ? o1.NumberOfItems()
	#              #--> 3
	def NumberOfItems()
		return len(This.Items())

	def ItemZ(pItem)
		_aItzResult_ = [ pItem, This.FindItem(pItem) ]
		return _aItzResult_

	  #-------------------------------------------------------------------------------------#
	 #   WHEN THE VALUE IS A LIST, FINDING THE NTH OCCURRENCE OF AN ITEM INSIDE THAT LIST  # 
	#-------------------------------------------------------------------------------------#
	# Tells where the item occurs for the nth time among the list values, as a pair and places inside it.
	#
	#   _n_        which occurrence, from 1, or :First or :Last
	#   pItem      the item to look for
	#   returns    a pair, [ pair position, positions inside its value ], or 0 when absent
	#   see        FindFirstItem
	#TODO // Add case sensitivity
	def FindNthItem(_n_, pItem)

		if _n_ = :First
			_n_ = 1
		but _n_ = :Last
			_n_ = len( This.FindItem(pItem) )
		ok

		_anFniPos_= This.FindItem(pItem)
		_nFniLen_ = len(_anFniPos_)

		_nFniResult_ = 0
		if _n_ >= 1 and _n_ <= _nFniLen_
			_nFniResult_ = _anFniPos_[_n_]
		ok

		return _nFniResult_

		def FindNthOccurrenceOfItemInList(_n_, pItem)
			return This.FindNthItem(_n_, pItem)

	  #---------------------------------------------------------------------------------------#
	 #   WHEN THE VALUE IS A LIST, FINDING THE FIRST OCCURRENCE OF AN ITEM INSIDE THAT LIST  # 
	#---------------------------------------------------------------------------------------#
	# Tells where the item first occurs among the list values, as a pair and places inside it.
	#
	#   pItem      the item to look for
	#   returns    a pair, [ pair position, positions inside its value ], or 0 when absent
	#   see        FindItem
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
	# Tells where the item last occurs among the list values, as a pair and places inside it.
	#
	#   pItem      the item to look for
	#   returns    a pair, [ pair position, positions inside its value ], or 0 when absent
	#   see        FindFirstItem
	#TODO // Add case sensitivity
	def FindLastItem(pItem)
		_aFliHits_ = This.FindItem(pItem)
		if len(_aFliHits_) > 0
			return _aFliHits_[ len(_aFliHits_) ]
		ok
		return 0

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
	# Returns where the item occurs, as [ pair position, [ positions in the value ] ] pairs.
	#
	#   pItem      the item to look for
	#   returns    a list of pairs
	#   see        FindItem
	#TODO // Add case sensitivity
	def FindKeysByItem(pItem)
		_anFkbiPos_ = This.FindItemInList(pItem)
		_nFkbiLen_ = len(_anFkbiPos_)

		_anFkbiResult_ = []

		for _iFkbi_ = 1 to _nFkbiLen_
			@AddItem(_anFkbiResult_, _anFkbiPos_[_iFkbi_])
		next

		return _anFkbiResult_

		def FindKeysByItemInList(pItem)
			return This.FindKeysByItem(pItem)

	# Returns how many pairs have a list value that holds the item.
	#
	#   pValue     the item to look for
	#   returns    a number
	#   see        KeysByItemInList
	def NumberOfKeysByItemInList(pValue) ### Fixed: was missing pValue param
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

	# Returns the position of the first pair whose list value holds the item, 0 when none.
	#
	#   pValue     the item to look for
	#   returns    a number
	#   see        KeysByItemInList
		#>
	def FindFirstKeyByItemInList(pValue)

		_aFfkbiHits_ = This.FindKeysByItemInList(pValue)
		if len(_aFfkbiHits_) > 0
			return _aFfkbiHits_[1][1]
		ok
		return 0

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

	# Returns the position of the last pair whose list value holds the item, 0 when none.
	#
	#   pValue     the item to look for
	#   returns    a number
	#   see        KeysByItemInList
	def FindLastKeyByItemInList(pValue)
		_aFlkbiHits_ = This.FindKeysByItemInList(pValue)
		if len(_aFlkbiHits_) > 0
			return _aFlkbiHits_[ len(_aFlkbiHits_) ][1]
		ok
		return 0

		def FindLastKeyByItem(pValue)
			return This.FindLastKeyByItemInList(pValue)

	# Returns the key of the first pair whose list value holds the item, an empty text when none.
	#
	#   pValue     the item to look for
	#   returns    a string
	#   see        KeysByItemInList
	def KeyByItemInList(pValue)
		_nKbiN_ = This.FindKeyByItemInList(pValue)

		if _nKbiN_ = 0
			return ""
		ok

		return This.Key( _nKbiN_ )

		def KeyByItem(pValue)
			return This.KeyByItemInList(pValue)

	# Returns the keys of the pairs whose list value holds the item, in order.
	#
	#   pValue     the item to look for
	#   returns    a list of the keys
	#   see        FindKeysByItem
	def KeysByItemInList(pValue)
		_aKbiHits_ = This.FindKeysByItemInList(pValue)
		_nKbiLen_ = len(_aKbiHits_)

		_aKbiResult_ = []

		for _iKbi_ = 1 to _nKbiLen_
			@AddItem(_aKbiResult_, This.Key(_aKbiHits_[_iKbi_][1]))
		next

		return _aKbiResult_

		# Returns the keys of the pairs whose list value holds the item, in order.
		#
		#   pValue     the item to look for
		#   returns    a list of the keys
		#   see        FindKeysByItem
		def KeysByItem(pValue)
			return This.KeysByItemInList(pValue)

	  #-----------------------------------------------#
	 #  LISTIFYING (ALL THE VALUES IN) THE HASHLIST  #
	#-----------------------------------------------#

	# Returns a new hash list with the same pairs, so the copy can change without touching this one.
	#
	#   returns    a new stzHashList
	#   example    o2 = o1.Copy()
	#              o2.Add([ "five", "e" ])
	#              ? o1.NumberOfPairs()
	#              #--> 4
	#              ? o2.NumberOfPairs()
	#              #--> 5
	def Copy()
		_oCpCopy_ = new stzHashList(This.content())
		return _oCpCopy_

	# Turns every value into a one-item list, in place.
	#
	#   returns    nothing; the hash list changes
	#   see        Listified
	def Listify()

		_aLfContent_ = This.Content()
		_nLfLen_ = len(_aLfContent_)

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

	# Returns a copy where every value is a one-item list; the hash list is unchanged.
	#
	#   returns    a hash list, as [ [ key, value ], ... ]
	#   see        Listify
	def Listified()
		_aLfdResult_ = This.Copy().ListifyQ().Content()
		return _aLfdResult_

	  #===========================#
	 #     CLASSIFYING VALUES    #
	#===========================#

	# Groups the keys by the value they hold, one [ class, keys ] pair per distinct value.
	#
	#   returns    a list of [ value as text, list of keys ] pairs, in order of first appearance
	#   see        Classes, NumberOfClasses
	#@ aka  Group the pairs into classes by value.
	def Classify()

		_aCfResult_ = []
		_acCfClasses_ = This.Classes()
		_nCfLen_ = len(_acCfClasses_)

		for _iCf_ = 1 to _nCfLen_
			@AddItem(_aCfResult_, [ _acCfClasses_[_iCf_], This.KeysForValue(_acCfClasses_[_iCf_]) ])
		next

		return _aCfResult_

		#< @FunctionFluentForm

		def ClassifyQ()
			return This.ClassifyQRT(:stzList)

		# The classification, in the requested return type (QRT).
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

	# Returns the distinct values of the hash list, each as text.
	#
	#   returns    a list of text, in order of first appearance
	#   see        Classify, NumberOfClasses
	#   example    ? @@( o1.Classes() )
	#              #--> [ "a", "b", "4" ]
	def Classes()
		_acCsResult_ = []
		_aCsUnique_ = This.UniqueValues()
		_nCsLen_ = len(_aCsUnique_)

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

	# TRUE if the given class occurs among the values.
	#
	#   pcClass    the class, as text
	#   returns    TRUE or FALSE
	#   see        ContainsClasses, Classes
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

	# TRUE if every one of the given classes occurs among the values.
	#
	#   pacClasses   the classes, as a list of text
	#   returns      TRUE or FALSE
	#   see          ContainsClass
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

	# Returns how many different values the hash list holds.
	#
	#   returns    a number
	#   see        Classes, Classify
	#   example    ? o1.NumberOfClasses()
	#              #--> 3
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

	# Returns the keys whose value is the given class, matched as a whole value.
	#
	#   pcClass    the class: a value, a list when the values are lists, or its text form as Classes gives it
	#   returns    a list of the keys; empty when no value is of that class
	#   see        Classes
	def Klass(pcClass)
		#NOTE: We can't use Class (with C) --> reserved by Ring
		# --> To avoid any confusion, use Klass with K instead,
		# or if you prefer, use Category.

		_aKlResult_ = This.KeysForValue(pcClass)
		return _aKlResult_

		#< @FunctionFluentForms

		def KlassQ(pcClass)
			return This.KlassQRT(pcClass, :stzList)

		def KlassQRT(pcClass, pcReturnType)
			if isList(pcReturnType) and StzListIsOneOfTheseNamedParamsList(pcReturnType,[ :ReturnedAs, :ReturnAs ])
				pcReturnType = pcReturnType[2]
			ok

			switch pcReturnType
			on :stzList
				return new stzList( This.Klass(pcClass) )

			on :stzListOfStrings
				return new stzListOfStrings( This.Klass(pcClass) )

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

	# Counts the pairs whose value is the given class.
	#
	#   pcClass    the class: a value, or its text form as Classes gives it
	#   returns    a number; 0 for a class that is absent
	#   see        Classes
	def NumberOfValuesInClass(pcClass)
		_nNvicResult_ = len( This.Klass(pcClass) )
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

	# Counts the pairs of each class, in the order Classes gives them.
	#
	#   returns    a list of numbers
	#   see        Classes
	def ClassesSizes()
		_acCssClasses_ = This.Classes()
		_nCssLen_ = len(_acCssClasses_)

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
		_nCsxLen_ = len(_acCsxClasses_)

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

	# Returns how many pairs each of the given classes holds.
	#
	#   pacClasses   the classes, as a list of text
	#   returns      a list of numbers
	#   see          ClassesSizes
	def TheseClassesSizes(pacClasses)
		if CheckingParams()
			if NOT (isList(pacClasses) and @IsListOfStrings(pacClasses))
				StzRaise("Incorrect param type! pcClasses must be a list of strings.")
			ok
		ok

		_nTcsLen_ = len(pacClasses)

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
			if NOT (isList(pacClasses) and @IsListOfStrings(pacClasses))
				StzRaise("Incorrect param type! pcClasses must be a list of strings.")
			ok
		ok

		_nTcsxLen_ = len(pacClasses)

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

	# Returns the share of the pairs whose value is the given class.
	#
	#   pcClass    the class: a value, or its text form as Classes gives it
	#   returns    a number from 0 to 1
	#   see        Classes
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

	# Returns the share of the pairs in each class, in the order Classes gives them.
	#
	#   returns    a list of numbers from 0 to 1, summing to 1
	#   see        Classes
	def ClassesFrequencies()
		_acCfsClasses_ = This.Classes()
		_nCfsLen_ = len(_acCfsClasses_)

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
		_nCfxLen_ = len(_acCfxClasses_)

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

	# Returns the share of the pairs in each of the given classes.
	#
	#   pacClasses   the classes, as a list of text
	#   returns      a list of numbers
	#   see          ClassesFrequencies
	def TheseClassesFrequencies(pacClasses)
		if CheckingParams()
			if NOT (isList(pacClasses) and @IsListOfStrings(pacClasses))
				StzRaise("Incorrect param type! pacClasses must be a list of strings.")
			ok
		ok

		_nTcfLen_ = len(pacClasses)

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
			if NOT (isList(pacClasses) and @IsListOfStrings(pacClasses))
				StzRaise("Incorrect param type! pacClasses must be a list of strings.")
			ok
		ok

		_nTcfxLen_ = len(pacClasses)

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

	# Returns the n classes that hold the most pairs, the biggest first.
	#
	#   _n_        how many classes; more than there are gives them all
	#   returns    a list of classes, as text
	#   see        Classes
	def NStrongestClasses(_n_)
		# Avoid `new stzList(...).Reversed()` chain (Ring 1.26 parses
		# the dot as binding to the arg expression, not the new
		# object, raising R13). Bind first.
		_oNscTmp_ = new stzList( SortListsOn( This.ClassesXT(), 2 ) )
		_aNscXT_ = _oNscTmp_.Reversed()
		_nNscLen_ = len(_aNscXT_)

		_n_ = @Min([ _n_, _nNscLen_ ])

		_aNscResult_ = []

		for _iNsc_ = 1 to _n_
			@AddItem(_aNscResult_, _aNscXT_[_iNsc_][1])
		next

		return _aNscResult_
		
		#< @FunctionAlternativeForms

		def NStrongestKlasses(_n_)
			return This.NStrongestClasses(_n_)

		def StrongestNClasses(_n_)
			return This.NStrongestClasses(_n_)

		def StrongestNKlasses(_n_)
			return This.NStrongestClasses(_n_)

		#--

		def TopNClasses(_n_)
			return This.NStrongestClasses(_n_)

		def NTopClasses(_n_)
			return This.NStrongestClasses(_n_)

		#>

	def NStrongestClassesXT(_n_)
		_oNscxTmp_ = new stzList( SortListsOn( This.ClassesXT(), 2 ) )
		_aNscxXT_ = _oNscxTmp_.Reversed()
		_nNscxLen_ = len(_aNscxXT_)
		_n_ = @Min([ _n_, _nNscxLen_ ])

		_aNscxResult_ = []

		for _iNscx_ = 1 to _n_
			@AddItem(_aNscxResult_, _aNscxXT_[_iNscx_])
		next

		return _aNscxResult_

		#< @FunctionAlternativeForms

		def NStrongestKlassesXT(_n_)
			return This.NStrongestClassesXT(_n_)

		def StrongestNClassesXT(_n_)
			return This.NStrongestClassesXT(_n_)

		def StrongestNKlassesXT(_n_)
			return This.NStrongestClassesXT(_n_)

		#--

		def NStrongestKlassesAndTheirFrequencies(_n_)
			return This.NStrongestClassesXT(_n_)

		def StrongestNClassesAndTheirFrequencies(_n_)
			return This.NStrongestClassesXT(_n_)

		def StrongestNKlassesAndTheirFrequencies(_n_)
			return This.NStrongestClassesXT(_n_)

		#--

		def TopNClassesXT(_n_)
			return This.NStrongestClassesXT(_n_)

		def NTopClassesXT(_n_)
			return This.NStrongestClassesXT(_n_)

		def TopNClassesAndTheirFrequencies(_n_)
			return This.NStrongestClassesXT(_n_)

		def NTopClassesAndTheirFrequencies(_n_)
			return This.NStrongestClassesXT(_n_)

	# Returns the class that holds the most pairs.
	#
	#   returns    a class, as text
	#   see        Classes
		#>
	#@ aka  --
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

	# Returns the three classes that hold the most pairs, the biggest first.
	#
	#   returns    a list of up to three classes, as text
	#   see        Classes
		#>
	#@ aka  --
	def Top3Classes()
		return This.StrongestNClasses(3)

		#< @FunctionAlternativeForms

		def 3StrongestKlasses()
			return This.Top3Classes()

		# Returns the three classes that hold the most pairs, the biggest first, as Top3Classes does.
		#
		#   returns    a list of up to three classes, as text
		#   see        Top3Classes
		def Strongest3Classes()
			return This.Top3Classes()

		def Strongest3Klasses()
			return This.Top3Classes()

		#>

	def Top3ClassesXT()
		return This.StrongestNClassesXT(3)

		#< @FunctionAlternativeForms

		def 3StrongestKlassesXT()
			return This.Top3ClassesXT()

		def Strongest3ClassesXT()
			return This.Top3ClassesXT()

		def Strongest3KlassesXT()
			return This.Top3ClassesXT()

		#--

		def Top3ClassesAndTheirFrequencies()
			return This.Top3ClassesXT()

		def 3StrongestKlassesAndTheirFrequencies()
			return This.Top3ClassesXT()

		# Returns the three biggest classes, each with its share of the pairs.
		#
		#   returns    a list of [ class, share ] pairs, the biggest first
		def Strongest3ClassesAndTheirFrequencies()
			return This.Top3ClassesXT()

		def Strongest3KlassesAndTheirFrequencies()
			return This.Top3ClassesXT()

		#>

	  #-----------------------------------#
	 #   GETTING THE N WEAKEST CLASSES   #
	#===================================#

	# Returns the n classes that hold the fewest pairs, the smallest first.
	#
	#   _n_        how many classes; more than there are gives them all
	#   returns    a list of classes, as text
	#   see        Classes
	def NWeakestClasses(_n_)
		_aNwcXT_ = SortListsOn( ClassesXT(), 2 )
		_nNwcLen_ = len(_aNwcXT_)
		_n_ = @Min([ _n_, _nNwcLen_ ])

		_aNwcResult_ = []

		for _iNwc_ = 1 to _n_
			@AddItem(_aNwcResult_, _aNwcXT_[_iNwc_][1])
		next

		return _aNwcResult_

		#< @FunctionAlternativeForms

		def NWeakestKlasses(_n_)
			return This.NWeakestClasses(_n_)

		def WeakestNClasses(_n_)
			return This.NWeakestClasses(_n_)

		def WeakestNKlasses(_n_)
			return This.NWeakestClasses(_n_)

		#--

		def BottomNClasses(_n_)
			return This.NWeakestClasses(_n_)

		def NBottomClasses(_n_)
			return This.NWeakestClasses(_n_)

		#>

	def NWeakestClassesXT(_n_)
		_aNwcxXT_ = SortListsOn( ClassesXT(), 2 )
		_nNwcxLen_ = len(_aNwcxXT_)
		_n_ = @Min([ _n_, _nNwcxLen_ ])

		_aNwcxResult_ = []

		for _iNwcx_ = 1 to _n_
			@AddItem(_aNwcxResult_, _aNwcxXT_[_iNwcx_])
		next

		return _aNwcxResult_

		#< @FunctionAlternativeForms

		def NWeakestKlassesXT(_n_)
			return This.NWeakestClassesXT(_n_)

		def WeakestNClassesXT(_n_)
			return This.NWeakestClassesXT(_n_)

		def WeakestNKlassesXT(_n_)
			return This.NWeakestClassesXT(_n_)

		#--

		def NWeakestClassesAndTheirFrequencies(_n_)
			return This.NWeakestClassesXT(_n_)

		def WeakestNClassesAndTheirFrequencies(_n_)
			return This.NWeakestClassesXT(_n_)

		def NWeakestKlassesAndTheirFrequencies(_n_)
			return This.NWeakestClassesXT(_n_)

		def WeakestNKlassesAndTheirFrequencies(_n_)
			return This.NWeakestClassesXT(_n_)

		#--

		def BottomNClassesXT(_n_)
			return This.NWeakestClassesXT(_n_)

		def NBottomClassesXT(_n_)
			return This.NWeakestClassesXT(_n_)

		def BottomNClassesAndTheirFrequencies(_n_)
			return This.NWeakestClassesXT(_n_)

		def NBottomClassesAndTheirFrequencies(_n_)
			return This.NWeakestClassesXT(_n_)

	# Returns the class that holds the fewest pairs.
	#
	#   returns    a class, as text
	#   see        Classes
		#>
	#@ aka  --
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

		def WeakestClassAndItsFrequency(_n_)
			return This.WeakestClassXT(_n_)

		def WeakestKlassAndItsFrequency(_n_)
			return This.WeakestClassXT(_n_)

	# Returns the three classes that hold the fewest pairs, the smallest first.
	#
	#   returns    a list of up to three classes, as text
	#   see        Classes
		#>
	#@ aka  --
	def Bottom3Classes()
		return This.WeakestNClasses(3)

		#< @FunctionAlternativeForms

		def 3WeakestKlasses()
			return This.Bottom3Classes()

		# Returns the three classes that hold the fewest pairs, the smallest first, as Bottom3Classes does.
		#
		#   returns    a list of up to three classes, as text
		#   see        Bottom3Classes
		def Weakest3Classes()
			return This.Bottom3Classes()

		def Weakest3Klasses()
			return This.Bottom3Classes()
		#>

	def Bottom3ClassesXT()
		return This.WeakestNClassesXT(3)

		#< @FunctionAlternativeForms

		def 3WeakestKlassesXT()
			return This.Bottom3ClassesXT()

		def Weakest3ClassesXT()
			return This.Bottom3ClassesXT()

		def Weakest3KlassesXT()
			return This.Bottom3ClassesXT()

		#--

		def 3WeakestKlassesAndTheirFrequencies()
			return This.Bottom3ClassesXT()

		# Returns the three smallest classes, each with its share of the pairs.
		#
		#   returns    a list of [ class, share ] pairs, the smallest first
		def Weakest3ClassesAndTheirFrequencies()
			return This.Bottom3ClassesXT()

		def Weakest3KlassesAndTheirFrequencies()
			return This.Bottom3ClassesXT()

		#>

	  #-------------------------------------#
	 #   CLASSIFYING VALUES INSIDE LISTS   #
	#=====================================#

	# Returns the distinct items found inside the list values.
	#
	#   returns    a list of items
	#   see        ClassifyInList, Items
	def ClassesInList()
		_acCilResult_ = []
		_aCilUnique_ = U( @Merge(This.Lists()) )
		_nCilLen_ = len(_aCilUnique_)

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

	# Returns how many distinct items the list values hold.
	#
	#   returns    a number
	#   see        ClassesInList
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

	# Groups the keys by the items inside the list values.
	#
	#   returns    a list of [ item, keys ] pairs
	#   see        Classify
	def ClassifyInList()

		_aClilResult_ = []
		_aClilClasses_ = This.ClassesInList()
		_nClilLen_ = len(_aClilClasses_)

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

		# Same as ClassifyInList.
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

	# Returns the keys of the pairs whose list value holds the class, in order.
	#
	#   pcClass    the class, as text
	#   returns    a list of the keys
	#   see        Klass
	def KlassInList(pcClass)
		_aKlilResult_ = This.KeysByItemInList(pcClass)
		return _aKlilResult_

		# Returns the keys of the pairs whose list value holds the class, as a stzList; a misspelling of KlassInListQ.
		#
		#   pcClass    the class, as text
		#   returns    a stzList
		#   see        KlassInList
		#   status     deprecated
		#< @FunctionFluentForms
		def KalssInListQ(pcClass)
			return This.KlassInListQRT(pcClass, :stzList)

		def KlassInListQRT(pcClass, pcReturnType)
			if isList(pcReturnType) and StzListIsOneOfTheseNamedParamsList(pcReturnType,[ :ReturnedAs, :ReturnAs ])
				pcReturnType = pcReturnType[2]
			ok

			switch pcReturnType
			on :stzList
				return new stzList( This.KlassInList(pcClass) )

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

	# Prints the hash list as a boxed table, one row per pair.
	#
	#   returns    nothing; the table is printed
	#   see        Content
	#@ aka  Print the hash list as a boxed table.
	def Show()
		This.ToStzTable().Show()

		# Prints the hash list as a boxed table: a misspelling of Show, kept so old calls still work.
		#
		#   returns    nothing; the table is printed
		#   see        Show
		#   status     deprecated
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

	# Returns the Softanza type symbol of the object, always :stzHashList.
	#
	#   returns    the symbol :stzHashList, which prints as stzhashlist
	#   example    ? o1.StzType()
	#              #--> stzhashlist
	#@ aka  The Softanza type symbol: :stzHashList.
	def StzType()
		return :stzHashList

	# Answers TRUE: the object is a hash list.
	#
	#   returns    TRUE
	#@ aka  Always TRUE: the object IS a hash list.
	def IsHashList() # required by stzChainOfTruth
		return 1

	# Returns the hash list as Ring code that rebuilds it.
	#
	#   returns    a string
	#   note       every value is written as text, so the number 4 comes out as "4"
	#   example    ? o1.ToCode()
	#              #--> [ :one = "a", :two = "b", :three = "a", :four = "4" ]
	#@ aka  The hash list as runnable Ring code, as a string.
	def ToCode()
		_aTcPairs_ = This.Content()
		_nTcLen_ = len(_aTcPairs_)

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

	# Applies an operator to the hash list and a value, such as the bracket form that reads a value by key.
	#
	#   pOp        the operator
	#   pValue     the right-hand value
	#   returns    the result of the operator
	#@ aka  The operator overloads of the hash list ([] = value by key, ...).
	def operator(pOp,pValue)

		if pOp = "[]"
			
			if ring_type(pValue) = "STRING"
				return This.ValueByKey(pValue)

			ok

		ok

	  #---------------------------------------------#
	 #  TRANSFORMING THE HASHLIST INTO A STZTABLE  #
	#---------------------------------------------#

	# Returns the hash list as a stzTable, one row per pair.
	#
	#   returns    a stzTable
	#   see        Show
	def ToStzTable()
		_aTstContent_ = This.Content()
		_nTstLen_ = len(_aTstContent_)

		_aTstTable_ = _aTstContent_

		for _iTst_ = 1 to _nTstLen_


		next

		_oTstResult_ = new stzTable(_aTstTable_)
		return _oTstResult_
