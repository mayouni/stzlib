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
		if NOT ( isList(paEntity) and IsHashList(paentity) )
			StzRaise("Incorrect param type! paEntity mus tbe a hashlist.")
		ok

		if NOT HasKey(paEntity, "name")
			paEntity + [ "name", "@noname" ]
		ok

		if NOT HasKey(paEntity, "type")
			paEntity + [ "type", "undefined" ]
		ok

		# Auto-add creation timestamp
		if NOT HasKey(paEntity, "created")
			paEntity + [ "created", TimeStamp() ]
		else
			paEntity[:created] = TimeStamp()
		ok

		@aEntity = aEntity
	
	
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
		return @aEntity[:created]

	def ContainsProperty(pcProp)
		if NOT isString(pcProp)
			StzRaise("Incorrect param type! pcProp must be a string.")
		ok

		if @aEntity[pcProp] != ""
			return 1
		else
			return 0
		ok

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

		pcProp = ring_lower(pcProp)

		if HasKey(@aEntity, pcProp)
			return @aEntity[pcProp]
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
		if HasKey(@aEntity, pcProp)
			@aEntity[pcProp] = pValue
		else
			@aEntity + [ pcProp, pValue ]
		ok

		def SetProp(pcProp, pValue)
			This.SetProperty(pcProp, pValue)

	def FindPropert(pcProp)
		if NOT isString(pcProp)
			StzRaise("Incorrect param type! pcProp must be a string.")
		ok

		pcProp = ring_lower(pcProp)
		if NOT HasKey(@aEnity, pcProp)
			return 0
		else
			nLen = len(@aEntity)
			for i = 1 to nLen
				if @aEntity[i][1] = pcProp
					return i
				ok
			next
		ok

	def RemoveProperty(pcProp)
		if NOT isString(pcProp)
			StzRaise("Incorrect param type! pcProp must be a string.")
		ok

		pcProp = ring_lower(pcProp)
		if HasKey(@aEntity, pcProp)
			del(@aEntity, this.FindProperty(pcProp))
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
