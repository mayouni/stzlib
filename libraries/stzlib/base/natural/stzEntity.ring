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

class stzEntity from stzObject
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
			paEntity + [ "created", StzTimeStamp() ]
		else
			paEntity[:created] = StzTimeStamp()
		ok

		@aEntity = paEntity
	
	
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

	def ContainsPropertyOrValue(pPropOrVal)
		if This.ContainsProperty(pPropOrVal) or This.ContainsValue(pPropOrVal)
			return 1
		else
			return 0
		ok

		#< @FunctionAlternativeForms

		def Contains@(pPropOrVal)
			return This.ContainsPropertyOrValue(pPropOrVal)

		def @Contains(pPropOrVal)
			return This.ContainsPropertyOrValue(pPropOrVal)

		def ContainsValueOrProperty(pPropOrVal)
			return This.ContainsPropertyOrValue(pPropOrVal)

		def ContainsPropOrVal(pPropOrVal)
			return This.ContainsPropertyOrValue(pPropOrVal)

		def ContainsValOrPrep(pPropOrVal)
			return This.ContainsPropertyOrValue(pPropOrVal)

		#>

	def ContainsProperty(pcProp)
		if NOT isString(pcProp)
			StzRaise("Incorrect param type! pcProp must be a string.")
		ok

		if HasKey(@aEntity, pcProp)
			return 1
		else
			return 0
		ok

	def ContainsValue(pValue)
		bResult = 0
		_aThisEntity3_ = This.Entity()
		_nThisEntity3Len_ = len(_aThisEntity3_)
		for _iLoopThisEntity3_ = 1 to _nThisEntity3Len_
			aPair = _aThisEntity3_[_iLoopThisEntity3_]
			if @AreEqual([ aPair[2], pValue ])
				bResult = 1
				exit
			ok
		next

		return bResult

	def Property(pcProp)
		if NOT isString(pcProp)
			StzRaise("Incorrect param type! pcProp must be a string.")
		ok

		pcProp = StzLower(pcProp)

		if HasKey(@aEntity, pcProp)
			return @aEntity[pcProp]
		else
			StzRaise("Inexistent property!")
		ok

		def Prop(pcProp)
			return This.Property(pcProp)

	def @(p)
		if isString(p)
			return This.Property(p)

		but isList(p)
			if len(p) = 2 and isString(p[1])
				This.SetProperty(p[1], p[2])
				return

			but IsListOfPairs(p)
				nLen = len(p)
				for i = 1 to nLen
					This.SetProperty(p[i][1], p[i][2])
				next
				return
			ok
		ok

		StzRaise("Incorrect param type! p must be a string or a pair of a string and on other value of any type.")


	def SetProperty(pcProp, pValue)
		if NOT isString(pcProp)
			StzRaise("Incorrect param type! pcProp must be a string.")
		ok

		pcProp = StzLower(pcProp)
		if HasKey(@aEntity, pcProp)
			@aEntity[pcProp] = pValue
		else
			@aEntity + [ pcProp, pValue ]
		ok

		def SetProp(pcProp, pValue)
			This.SetProperty(pcProp, pValue)

		def Set@(pcProp, pValue)
			This.SetProperty(pcProp, pValue)

		def @Set(pcProp, pValue)
			This.SetProperty(pcProp, pValue)

	def FindProperty(pcProp)
		if NOT isString(pcProp)
			StzRaise("Incorrect param type! pcProp must be a string.")
		ok

		pcProp = StzLower(pcProp)
		if NOT HasKey(@aEntity, pcProp)
			return 0
		else
			nLen = len(@aEntity)
			for i = 1 to nLen
				if @aEntity[i][1] = pcProp
					return i
				ok
			next
		ok

		def FindProp(pcProp)
			return This.FindProperty(pcProp)

		def Find@(pcProp)
			return This.FindProperty(pcProp)

		def @Find(pcProp)
			return This.FindProperty(pcProp)

	def RemoveProperty(pcProp)
		if NOT isString(pcProp)
			StzRaise("Incorrect param type! pcProp must be a string.")
		ok

		pcProp = StzLower(pcProp)
		if HasKey(@aEntity, pcProp)
			del(@aEntity, this.FindProperty(pcProp))
		else
			StzRaise("Property does not exist!")
		ok

		def RemoveProp(pcProp)
			This.RemoveProperty(pcProp)

		def Remove@(pcProp)
			This.RemoveProperty(pcProp)

		def @Remove(pcProp)
			This.RemoveProperty(pcProp)

	def Properties()
		aResult = []
		_aThisEntity2_ = This.Entity()
		_nThisEntity2Len_ = len(_aThisEntity2_)
		for _iLoopThisEntity2_ = 1 to _nThisEntity2Len_
			aProp = _aThisEntity2_[_iLoopThisEntity2_]
			aResult + aProp[1]
		next
		return aResult

		def Props()
			return Properties()

	def Values()
		return StzHashListQ( This.Content() ).Values()

	def IsOfType(pcType)
		return This.Type() = StzLower(pcType)

	def HasName(pcName)
		return This.Name() = StzLower(pcName)

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
		_aThisEntity1_ = This.Entity()
		_nThisEntity1Len_ = len(_aThisEntity1_)
		for _iLoopThisEntity1_ = 1 to _nThisEntity1Len_
			aProp = _aThisEntity1_[_iLoopThisEntity1_]
			if aProp[1] != "name" and aProp[1] != "type"
				? "  " + aProp[1] + ": " + aProp[2]
			ok
		next
