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
