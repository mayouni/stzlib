
func StzEntityQ(pcStr)
	return new stzEntity(pcStr)

func IsEntity(p)
	try
		new stzEntity(p)
		return _TRUE_
	catch
		return _FALSE_
	end
	#TODO : Replace this implementation
	# Use the code in the init() function inside the class

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
			if StzHashListQ(paEntity).ContainsKey(:name)
				#NOTE: All properties are lowercased by using stzHashList
				# In fact, stzHashList automatically lowercaseس all its keys

				aEntity =  StzHashListQ(paEntity).Content()

				# 'name' is compulsory and it must be a valid word
				if NOT ( isString(aEntity[:name]) and @IsWord(aEntity[:name]) )
					StzRaise(stzEntityError(:CanNotCreateEntityObjectWithIncorrectName))
				ok

				# if 'type' is not provided then it is automatically added
				# and set to 'undefined'

				if StzHashListQ(aEntity).FindKey(:type) = 0
					insert(aEntity, 1, :type = 'undefined')

				else
				# but when it is provided, it must be a valid word
				# (if it is _NULL_ string then it is set to 'undefined'

					if isString(aEntity[:type]) and aEntity[:type] = ""
						aEntity[:type] = 'undefined'

					else

						if NOT ( isString(aEntity[:type]) and @IsWord(aEntity[:type]) )
							StzRaise(stzEntityError(:CanNotCreateEntityObjectWithIncorrectType))
						ok
					ok
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

	def Type()
		return This.Content()[:type]

	def ContainsProperty(pcProp)

		if NOT isString(pcProp)
			StzRaise("Incorrect param type! pcProp must be a string.")
		ok

		bResult = _FALSE_

		aPairs = This.Entity()
		nLen = len(aPairs)

		for i = 1 to nLen
			if aPairs[i][1] = ring_lower(pcProp)
				bResult = _TRUE_
				exit
			ok
		next

		return bResult

	def ContainsValue(pValue)
		bResult = _FALSE_
		for aPair in This.Entity()
			if AreEqual(aPair[1], pValue)
				bResult = _TRUE_
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
			StzRaise("Inexistant property!")
		ok

		def Prop()
			return Property()

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
