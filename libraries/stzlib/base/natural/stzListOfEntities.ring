func StzListOfEntitiesQ(paList)
	return new stzListOfEntities(paList)

func IsListOfEntities(paList)
	if CheckingParams()
		if NOT isList(paList)
			StzRaise("Incorrect param type!")
		ok
	ok

	bResult = 1
	nLen = len(paList)

	for i = 1 to nLen
		if NOT IsEntity(paList[i])
			bResult = 0
			exit
		ok
	next i

	return bResult

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
					paEntity[:name] = StzStringQ(paEntity[:name]).Lowercased()
					paEntity[:type] = StzStringQ(paEntity[:type]).Lowercased()
					@aListOfEntities + paEntity
				ok

			else
				StzRaise(stzListOfEntitiesError(:CanNotAddEntityWithoutName))
			ok
		else
			StzRaise(stzListOfEntitiesError(:CanNotAddNotAHashList))
		ok

		def AddEntities(paEntities)
			for aEntity in paEntities
				This.AddEntity(aEntity)
			next

	def EntitiesNames()
		aResult = []
		for aEntity in This.Entities()
			aResult + aEntity[:name]
		next
		return aResult

		def Names()
			return This.EntitiesNames()

	def EntitiesTypes()
		aResult = []
		for aEntity in This.Entities()
			aResult + aEntity[:type]
		next
		return aResult

		def Types()
			return This.EntitiesTypes()

	def UniqueTypes()
		return StzListQ( This.Types() ).Duplicates()

	def EntityN(n)
		if n > 0 and n <= This.NumberOfEntities()
			return This.Entities()[n]
		else
			StzRaise("Index out of range!")
		ok

		def Entity(n)
			return This.EntityN(n)

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
		n = This.FindEntityByName(pcName)
		if n > 0
			del(@aListOfEntities, n)
		else
			StzRaise("Entity not found!")
		ok

		def RemoveEntityN(n)
			if n > 0 and n <= This.NumberOfEntities()
				del(@aListOfEntities, n)
			else
				StzRaise("Index out of range!")
			ok

	def FindEntityByName(pcName)
		n = 0
		for aEntity in This.Entities()
			n++
			if aEntity[:name] = StzStringQ(pcName).Lowercased()
				return n
			ok
		next
		return 0

	def FindEntitiesByType(pcType)
		aResult = []
		n = 0
		for aEntity in This.Entities()
			n++
			if aEntity[:type] = StzStringQ(pcType).Lowercased()
				aResult + n
			ok
		next
		return aResult

	def EntitiesOfType(pcType)
		aResult = []
		for aEntity in This.Entities()
			if aEntity[:type] = StzStringQ(pcType).Lowercased()
				aResult + aEntity
			ok
		next
		return aResult

	def ContainsEntity(pcName)
		return This.FindEntityByName(pcName) > 0

		def HasEntity(pcName)
			return This.ContainsEntity(pcName)

	def ContainsName(pcName)
		bResult = 0
		for aEntity in This.Entities()
			if aEntity[:name] = StzStringQ(pcName).Lowercased()
				bResult = 1
				exit
			ok
		next
		return bResult

		def HasName(pcName)
			return This.ContainsName(pcName)

	def ContainsType(pcType)
		bResult = 0
		for aEntity in This.Entities()
			if aEntity[:type] = StzStringQ(pcType).Lowercased()
				bResult = 1
				exit
			ok
		next
		return bResult

		def HasType(pcType)
			return This.ContainsType(pcType)

	def CountByType(pcType)
		nCount = 0
		for aEntity in This.Entities()
			if aEntity[:type] = StzStringQ(pcType).Lowercased()
				nCount++
			ok
		next
		return nCount

	def Clear()
		@aListOfEntities = []

	def SortByName()
		@aListOfEntities = StzListQ(@aListOfEntities).SortedBy(:name)

	def SortByType()
		@aListOfEntities = StzListQ(@aListOfEntities).SortedBy(:type)

	def FilterByType(pcType)
		return new stzListOfEntities( This.EntitiesOfType(pcType) )

	def Show()
		? "List of Entities (" + This.NumberOfEntities() + " entities):"
		? "================================================"
		
		if This.IsEmpty()
			? "(empty)"
		else
			n = 0
			for aEntity in This.Entities()
				n++
				oEntity = new stzEntity(aEntity)
				? "" + n + ". " + oEntity.Name() + " (" + oEntity.Type() + ")"
			next
		ok
