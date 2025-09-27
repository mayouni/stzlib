func StzEntityQ(pcStr)
	return new stzEntity(pcStr)

func IsEntity(p)
	try
		new stzEntity(p)
		return 1
	catch
		return 0
	end

	#< @FunctionAlternativeForms

	func @IsEntity(p)
		return IsEntity(p)

	func IsAnEntity(p)
		return IsEntity(p)

	func @IsAnEntity(p)
		return IsEntity(p)

	#>

class stzEntity
	@aEntity

	def init(paEntity)
		if @IsHashList(paEntity)
			if paEntity[:name] != ""
				aEntity = paEntity

				# 'name' is compulsory and it must be a valid word
				if NOT ( isString(aEntity[:name]) and @IsWord(aEntity[:name]) )
					StzRaise(stzEntityError(:CanNotCreateEntityObjectWithIncorrectName))
				ok

				# if 'type' is not provided then it is automatically added
				# and set to 'undefined'
				if aEntity[:type] = ""
					insert(aEntity, 1, :type = 'undefined')
				else
					# but when it is provided, it must be a valid word
					# (if it is NULL string then it is set to 'undefined'
					if isString(aEntity[:type]) and aEntity[:type] = ""
						aEntity[:type] = 'undefined'
					else
						if NOT ( isString(aEntity[:type]) and @IsWord(aEntity[:type]) )
							StzRaise(stzEntityError(:CanNotCreateEntityObjectWithIncorrectType))
						ok
					ok
				ok

				# Auto-add creation timestamp if not present
				if aEntity[:created] = ""
					aEntity + [ "created", TimeStamp() ]
				ok

				@aEntity = aEntity
				
			else
				StzRaise(stzEntityError(:CanNotCreateEntityObjectWithoutName))
			ok
			
		else
			StzRaise(stzEntityError(:CanNotCreateEntityObject))
		ok	
	
	def Content()
		return @aEntity

		def Value()
			return Content()

		def Entity()
			return This.Content()
	
	def Name()
		return This.Content()[:name]

		def SetName(pcName)
			if isString(pcName) and @IsWord(pcName)
				@aEntity[:name] = pcName
			else
				StzRaise("Invalid name! Must be a valid word.")
			ok

	def Type()
		return This.Content()[:type]

		def SetType(pcType)
			if isString(pcType) and @IsWord(pcType)
				@aEntity[:type] = pcType
			else
				StzRaise("Invalid type! Must be a valid word.")
			ok

	def Created()
		if This.ContainsProperty(:created)
			return This.Property(:created)
		else
			return ""
		ok

	def ContainsProperty(pcProp)
		if NOT isString(pcProp)
			StzRaise("Incorrect param type! pcProp must be a string.")
		ok

		bResult = 0
		aPairs = This.Entity()
		nLen = len(aPairs)

		for i = 1 to nLen
			if aPairs[i][1] = ring_lower(pcProp)
				bResult = 1
				exit
			ok
		next

		return bResult

	def ContainsValue(pValue)
		bResult = 0
		for aPair in This.Entity()
			if AreEqual(aPair[2], pValue)  # Fixed: was aPair[1], should be aPair[2]
				bResult = 1
				exit
			ok
		next

		return bResult

	def Property(pcProp)
		if NOT isString(pcProp)
			StzRaise("Incorrect param type! pcProp must be a string.")
		ok

		if This.ContainsProperty(pcProp)
			pcProp = ring_lower(pcProp)
			return This.Content()[pcProp]
		else
			StzRaise("Inexistent property!")
		ok

		def Prop(pcProp)
			return Property(pcProp)

	def SetProperty(pcProp, pValue)
		if NOT isString(pcProp)
			StzRaise("Incorrect param type! pcProp must be a string.")
		ok

		pcProp = ring_lower(pcProp)
		@aEntity[pcProp] = pValue

		def SetProp(pcProp, pValue)
			This.SetProperty(pcProp, pValue)

	def RemoveProperty(pcProp)
		if NOT isString(pcProp)
			StzRaise("Incorrect param type! pcProp must be a string.")
		ok

		if This.ContainsProperty(pcProp)
			pcProp = ring_lower(pcProp)
			if pcProp != "name" and pcProp != "type"  # Protect core properties
? @@(@aEntity)
? pcProp
				del(@aEntity, pcProp)
			else
				StzRaise("Cannot remove core property: " + pcProp)
			ok
		else
			StzRaise("Property does not exist!")
		ok

	def Properties()
		aResult = []
		for aProp in This.Entity()
			aResult + aProp[1]
		next
		return aResult

		def Props()
			return Properties()

	def Values()
		return StzHashListQ( This.Content() ).Values()

	def IsOfType(pcType)
		return This.Type() = ring_lower(pcType)

	def HasName(pcName)
		return This.Name() = ring_lower(pcName)

	def Copy()
		return new stzEntity( This.Content() )

	def Size()
		return len( This.Properties() )

		def NumberOfProperties()
			return This.Size()

	def IsEmpty()
		return This.Size() = 2  # Only name and type

	def Show()
		? "Entity: " + This.Name() + " (Type: " + This.Type() + ")"
		for aProp in This.Entity()
			if aProp[1] != "name" and aProp[1] != "type"
				? "  " + aProp[1] + ": " + aProp[2]
			ok
		next
