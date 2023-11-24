
func StzListOfEntitiesQ()
	return new stzListOfEntities()

class stzListOfEntities from stzList
	@aListOfEntities = []

	def init(paList)
		if isList(paList) and
		   ( Q(paList).IsEmpty() or Q(paList).IsListOfHashLists() )

			@aListOfEntities = paList
		else
			StzRaise("Can't create the stzListOfEntitities object! You must provide a list of hashlists.")
		ok

	def Content()
		return @aListOfEntities

		def Value()
			return Content()

	def ListOfEntities()
		return This.Content()

		def Entities()
			return This.ListOfEntities()

	def AddEntity(paEntity)

		if ListIsHashList(paEntity)
			if StzHashListQ(paEntity).ContainsKey(:name)

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

	def EntityN(n)
		return This.Entities()[n]

		def Entity(n)
			return This.EntityN(n)

	def NumberOfEntities()
		return len( This.Entities() )

	def RemoveEntity(pcName)
		n = FindEntityByName(pcName)
		del(@aoListOfEntities, n)

	def FindEntityByName(pcName)
		n = 0
		for aEntity in This.Entities()
			n++
			if aEntity[:name] = pcName
				return n
			ok
		next
		return 0

	def ContainsEntity(pcName)
		return This.FindEntityByName(pcName) > 0

	def ContainsName(pcName)
		bResult = FALSE

		for aEntity in This.Entities()
			if aEntity[:name] = StzStringQ(pcName).Lowercased()
				bResult = TRUE
				exit
			ok
		next

		return bResult

	def ContainsType(pcType)
		bResult = FALSE

		for aEntity in This.Entities()
			if aEntity[:type] = StzStringQ(pcType).Lowercased()
				bResult = TRUE
				exit
			ok
		next

		return bResult

	def Show()
		? StzListOfHashListsQ( This.Content() ).Show()
