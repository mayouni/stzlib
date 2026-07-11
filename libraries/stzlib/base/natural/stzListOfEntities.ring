# THE WORLD (NATURAL_VISION step 3) -- the single shared entity registry.
# Everything that NAMES a thing feeds it, everything that WONDERS about a
# thing queries it:
#   - Naturally() named objects  ("call it basket")   -> StzKnow, automatic
#   - stzText.RegisterNamedEntities()  (NER)          -> StzKnow, explicit
#   - stzChainOfTruth's _@ entity hook                -> AddEntity (legacy)
#   - WhatIs("basket")                                -> [ "list" ]
# Declared HERE (the world IS a list of entities); stzChainOfTruth used to
# own it, which put the knowledge floor inside one legacy surface.
$oWorldEntities = new stzListOfEntities
$aStzSuppositions = []   # the HYPOTHETICAL overlay (see SupposeQ below)

func WorldEntities()
	return $oWorldEntities

	func @WorldEntities()
		return $oWorldEntities

# Idempotent world registration: the same (name, type) pair registers ONCE
# and silently -- unlike AddEntity, which raises on duplicates. Returns 1
# when the entity was new, 0 when it was already known. Naturally() calls
# this on every code regeneration, so silence on repeats is the contract.

func StzKnow(pcName, pcType)
	return StzKnowXT(pcName, pcType, [])

	func @StzKnow(pcName, pcType)
		return StzKnowXT(pcName, pcType, [])

func StzKnowXT(pcName, pcType, paProps)
	if NOT ( isString(pcName) and isString(pcType) )
		return 0
	ok
	_cName_ = StzLower(trim(pcName))
	_cType_ = StzLower(trim(pcType))
	if _cName_ = ""
		return 0
	ok
	if _cType_ = ""
		_cType_ = "undefined"
	ok
	# exact (name, type) PAIR check -- AddEntity's own guard tests name and
	# type independently, which both over-fires and raises; the world wants
	# quiet idempotence
	_aAll_ = $oWorldEntities.Entities()
	_nAll_ = len(_aAll_)
	for _i_ = 1 to _nAll_
		if _aAll_[_i_][:name] = _cName_ and _aAll_[_i_][:type] = _cType_
			return 0
		ok
	next
	_aEnt_ = [ [ "name", _cName_ ], [ "type", _cType_ ] ]
	if isList(paProps)
		_nP_ = len(paProps)
		for _i_ = 1 to _nP_
			if isList(paProps[_i_]) and len(paProps[_i_]) = 2 and isString(paProps[_i_][1])
				_aEnt_ + [ StzLower(paProps[_i_][1]), paProps[_i_][2] ]
			ok
		next
	ok
	_oEnt_ = new stzEntity(_aEnt_)
	# AppendEntity bypasses AddEntity's raise-on-duplicate; the PAIR check
	# above already guaranteed uniqueness
	$oWorldEntities.AppendEntity(_oEnt_.Content())
	return 1

	func @StzKnowXT(pcName, pcType, paProps)
		return StzKnowXT(pcName, pcType, paProps)

# THE HYPOTHETICAL CONTEXT (the SupposeQ frontier): an assumption is an
# OVERLAY on the world, never a commitment -- the world stays clean while
# the discourse reasons "as if". The reasoning primitive of an agent:
#
#     SupposeQ("tomato").IsAQ(:Fruit)      # "Suppose tomato is a fruit"
#     ? WhatIs("tomato")                    #--> [ "fruit" ]  (while supposed)
#     ForgetSuppositions()                  # discard -- the world unchanged
#     CommitSuppositions()                  # ...or conclude: StzKnow each
#
# Suppose -> ask -> commit or forget: deterministic sandboxed reasoning.

func SupposeQ(pcName)
	return new stzSupposition(pcName)

func SuppositionsSoFar()
	return $aStzSuppositions

func ForgetSuppositions()
	$aStzSuppositions = []

func CommitSuppositions()
	_nSup_ = len($aStzSuppositions)
	for _iSup_ = 1 to _nSup_
		StzKnow($aStzSuppositions[_iSup_][1], $aStzSuppositions[_iSup_][2])
	next
	$aStzSuppositions = []
	return _nSup_

# WhatIs: the world query from the oldest Softanza vision --
#   ? WhatIs("apple")  #--> [ "fruit", "company" ]
# Returns the list of TYPES the world knows for that name; [] when the
# world has never heard of it.

func WhatIs(pcName)
	if NOT isString(pcName)
		return []
	ok
	_cName_ = StzLower(trim(pcName))
	_aOut_ = []
	_aAll_ = $oWorldEntities.Entities()
	_nAll_ = len(_aAll_)
	for _i_ = 1 to _nAll_
		if _aAll_[_i_][:name] = _cName_ and ring_find(_aOut_, _aAll_[_i_][:type]) = 0
			_aOut_ + _aAll_[_i_][:type]
		ok
	next
	# the hypothetical overlay answers too, while it stands
	_nSup_ = len($aStzSuppositions)
	for _i_ = 1 to _nSup_
		if $aStzSuppositions[_i_][1] = _cName_ and
		   ring_find(_aOut_, $aStzSuppositions[_i_][2]) = 0
			_aOut_ + $aStzSuppositions[_i_][2]
		ok
	next
	return _aOut_

	func @WhatIs(pcName)
		return WhatIs(pcName)

func StzListOfEntitiesQ(paList)
	return new stzListOfEntities(paList)

# Error-message dispatcher used by stzListOfEntities.AddEntity*.
# Codes map to the same human-readable messages the original
# (max-tier) module exposed -- keep wording terse but identifiable.
func stzListOfEntitiesError(pcCode)
	switch pcCode
	on :CanNotAddThisEntityTwice
		return "Can't add the same entity twice to a stzListOfEntities."
	on :CanNotAddEntityWithoutName
		return "Can't add an entity without a :name key."
	on :CanNotAddNotAHashList
		return "Can't add a non-hashlist value as an entity."
	other
		return "Unknown stzListOfEntities error: " + pcCode
	off

func IsListOfEntities(paList)
	if CheckingParams()
		if NOT isList(paList)
			StzRaise("Incorrect param type!")
		ok
	ok

	_bResult_ = 1
	_nLen_ = len(paList)

	for i = 1 to _nLen_
		if NOT IsEntity(paList[i])
			_bResult_ = 0
			exit
		ok
	next i

	return _bResult_

	#< @FunctionAlternativeForms

	func @IsListOfEntities(paList)
		return IsListOfEntities(paList)

	func IsAListOfEntities(paList)
		return IsListOfEntities(paList)

	func @IsAListOfEntities(paList)
		return IsListOfEntities(paList)

	#>

class stzEntities from stzListOfEntities

class stzListOfEntities from stzList
	@aListOfEntities = []

	def init(paList)
		if isList(paList) and
		   ( Q(paList).IsEmpty() or Q(paList).IsListOfHashLists() )
			@aListOfEntities = paList
		else
			StzRaise("Can't create the stzListOfEntities object! You must provide a list of hashlists.")
		ok

	def Content()
		return @aListOfEntities

		def Value()
			return Content()

	def Copy()
		return new stzListOfEntities(This.Content())

	def ListOfEntities()
		return This.Content()

		def Entities()
			return This.ListOfEntities()

	def AddEntity(paEntity)
		if @IsHashList(paEntity)
			if HasKey(paEntity, :name)

				if This.ContainsName(paEntity[:name]) and
				   This.ContainsType(paEntity[:type])
					StzRaise(stzListOfEntitiesError(:CanNotAddThisEntityTwice))
				else
					paEntity[:name] = StzLower(paEntity[:name])
					paEntity[:type] = StzLower(paEntity[:type])
					@aListOfEntities + paEntity
				ok

			else
				StzRaise(stzListOfEntitiesError(:CanNotAddEntityWithoutName))
			ok
		else
			StzRaise(stzListOfEntitiesError(:CanNotAddNotAHashList))
		ok

		def AppendEntity(paEntity)
		@aListOfEntities + paEntity

	def AddEntities(paEntities)
			_nEntities1Len_ = len(paEntities)
			for _iLoopEntities1_ = 1 to _nEntities1Len_
				_aEntity_ = paEntities[_iLoopEntities1_]
				This.AddEntity(_aEntity_)
			next

	def EntitiesNames()
		_aResult_ = []
		_aThisEntities9_ = This.Entities()
		_nThisEntities9Len_ = len(_aThisEntities9_)
		for _iLoopThisEntities9_ = 1 to _nThisEntities9Len_
			_aEntity_ = _aThisEntities9_[_iLoopThisEntities9_]
			_aResult_ + _aEntity_[:name]
		next
		return _aResult_

		def Names()
			return This.EntitiesNames()

	def EntitiesTypes()
		_aResult_ = []
		_aThisEntities8_ = This.Entities()
		_nThisEntities8Len_ = len(_aThisEntities8_)
		for _iLoopThisEntities8_ = 1 to _nThisEntities8Len_
			_aEntity_ = _aThisEntities8_[_iLoopThisEntities8_]
			_aResult_ + _aEntity_[:type]
		next
		return _aResult_

		def Types()
			return This.EntitiesTypes()

	def UniqueTypes()
		# Was `StzListQ(...).Duplicates()` -- double bug:
		# (1) Duplicates() only exists in the monolithic archive,
		#     never ported to modular stzList -> R14 unreachable.
		# (2) Even if it existed, Duplicates would return the DUPED
		#     items, not the uniques -- inverted semantics relative
		#     to the method name.
		return StzListQ( This.Types() ).Unique()

	def EntityN(_n_)
		if _n_ > 0 and _n_ <= This.NumberOfEntities()
			return This.Entities()[_n_]
		else
			StzRaise("Index out of range!")
		ok

		def Entity(_n_)
			return This.EntityN(_n_)

	def FirstEntity()
		if This.NumberOfEntities() > 0
			return This.EntityN(1)
		else
			StzRaise("List is empty!")
		ok

	def LastEntity()
		if This.NumberOfEntities() > 0
			return This.EntityN( This.NumberOfEntities() )
		else
			StzRaise("List is empty!")
		ok

	def NumberOfEntities()
		return len( This.Entities() )

		def Size()
			return This.NumberOfEntities()

		def Count()
			return This.NumberOfEntities()

	def IsEmpty()
		return This.NumberOfEntities() = 0

	def RemoveEntity(pcName)
		_n_ = This.FindEntityByName(pcName)
		if _n_ > 0
			del(@aListOfEntities, _n_)
		else
			StzRaise("Entity not found!")
		ok

		def RemoveEntityN(_n_)
			if _n_ > 0 and _n_ <= This.NumberOfEntities()
				del(@aListOfEntities, _n_)
			else
				StzRaise("Index out of range!")
			ok

	def FindEntityByName(pcName)
		_n_ = 0
		_aThisEntities7_ = This.Entities()
		_nThisEntities7Len_ = len(_aThisEntities7_)
		for _iLoopThisEntities7_ = 1 to _nThisEntities7Len_
			_aEntity_ = _aThisEntities7_[_iLoopThisEntities7_]
			_n_++
			if _aEntity_[:name] = StzLower(pcName)
				return _n_
			ok
		next
		return 0

	def FindEntitiesByType(pcType)
		_aResult_ = []
		_n_ = 0
		_aThisEntities6_ = This.Entities()
		_nThisEntities6Len_ = len(_aThisEntities6_)
		for _iLoopThisEntities6_ = 1 to _nThisEntities6Len_
			_aEntity_ = _aThisEntities6_[_iLoopThisEntities6_]
			_n_++
			if _aEntity_[:type] = StzLower(pcType)
				_aResult_ + _n_
			ok
		next
		return _aResult_

	def EntitiesOfType(pcType)
		_aResult_ = []
		_aThisEntities5_ = This.Entities()
		_nThisEntities5Len_ = len(_aThisEntities5_)
		for _iLoopThisEntities5_ = 1 to _nThisEntities5Len_
			_aEntity_ = _aThisEntities5_[_iLoopThisEntities5_]
			if _aEntity_[:type] = StzLower(pcType)
				_aResult_ + _aEntity_
			ok
		next
		return _aResult_

	def ContainsEntity(pcName)
		return This.FindEntityByName(pcName) > 0

		def HasEntity(pcName)
			return This.ContainsEntity(pcName)

	def ContainsName(pcName)
		_bResult_ = 0
		_aThisEntities4_ = This.Entities()
		_nThisEntities4Len_ = len(_aThisEntities4_)
		for _iLoopThisEntities4_ = 1 to _nThisEntities4Len_
			_aEntity_ = _aThisEntities4_[_iLoopThisEntities4_]
			if _aEntity_[:name] = StzLower(pcName)
				_bResult_ = 1
				exit
			ok
		next
		return _bResult_

		def HasName(pcName)
			return This.ContainsName(pcName)

	def ContainsType(pcType)
		_bResult_ = 0
		_aThisEntities3_ = This.Entities()
		_nThisEntities3Len_ = len(_aThisEntities3_)
		for _iLoopThisEntities3_ = 1 to _nThisEntities3Len_
			_aEntity_ = _aThisEntities3_[_iLoopThisEntities3_]
			if _aEntity_[:type] = StzLower(pcType)
				_bResult_ = 1
				exit
			ok
		next
		return _bResult_

		def HasType(pcType)
			return This.ContainsType(pcType)

	def CountByType(pcType)
		_nCount_ = 0
		_aThisEntities2_ = This.Entities()
		_nThisEntities2Len_ = len(_aThisEntities2_)
		for _iLoopThisEntities2_ = 1 to _nThisEntities2Len_
			_aEntity_ = _aThisEntities2_[_iLoopThisEntities2_]
			if _aEntity_[:type] = StzLower(pcType)
				_nCount_++
			ok
		next
		return _nCount_

	def Clear()
		@aListOfEntities = []

	def SortByName()
		# Sort hashlists by the :name key value. No stzList SortedBy --
		# do it inline with a hoisted-length pass + insertion sort over
		# the small entity list (usually < a few hundred items).
		_aData_ = @aListOfEntities
		_nLen_ = len(_aData_)
		for _i_ = 2 to _nLen_
			_oCur_ = _aData_[_i_]
			_j_ = _i_ - 1
			while _j_ >= 1 and strcmp(_aData_[_j_][:name], _oCur_[:name]) > 0
				_aData_[_j_ + 1] = _aData_[_j_]
				_j_--
			end
			_aData_[_j_ + 1] = _oCur_
		next
		@aListOfEntities = _aData_

	def SortByType()
		_aData_ = @aListOfEntities
		_nLen_ = len(_aData_)
		for _i_ = 2 to _nLen_
			_oCur_ = _aData_[_i_]
			_j_ = _i_ - 1
			while _j_ >= 1 and strcmp(_aData_[_j_][:type], _oCur_[:type]) > 0
				_aData_[_j_ + 1] = _aData_[_j_]
				_j_--
			end
			_aData_[_j_ + 1] = _oCur_
		next
		@aListOfEntities = _aData_

	def FilterByType(pcType)
		return new stzListOfEntities( This.EntitiesOfType(pcType) )

	def Show()
		? "List of Entities (" + This.NumberOfEntities() + " entities):"
		? "================================================"
		
		if This.IsEmpty()
			? "(empty)"
		else
			_n_ = 0
			_aThisEntities1_ = This.Entities()
			_nThisEntities1Len_ = len(_aThisEntities1_)
			for _iLoopThisEntities1_ = 1 to _nThisEntities1Len_
				_aEntity_ = _aThisEntities1_[_iLoopThisEntities1_]
				_n_++
				_oEntity_ = new stzEntity(_aEntity_)
				? "" + _n_ + ". " + _oEntity_.Name() + " (" + _oEntity_.Type() + ")"
			next
		ok

class stzSupposition
	@cName = ""

	def init(pcName)
		@cName = StzLower(trim(pcName))

	# "Suppose X IS A fruit" -- records the assumption in the overlay
	def IsAQ(pcType)
		_cT_ = StzLower(trim("" + pcType))
		_nSp_ = len($aStzSuppositions)
		for _iSp_ = 1 to _nSp_
			if $aStzSuppositions[_iSp_][1] = @cName and
			   $aStzSuppositions[_iSp_][2] = _cT_
				return This
			ok
		next
		$aStzSuppositions + [ @cName, _cT_ ]
		return This

	# "...and (is) a company" -- the conjunction keeps supposing
	def AndQ()
		return This

	def Name()
		return @cName
