
func StzEntityQ(pcStr)
	return new stzEntity(pcStr)

class stzEntity
	@aEntity

	def init(paEntity)
		if ListIsHashList(paEntity)
			if StzHashListQ(paEntity).ContainsKey(:name)
				# NOTE: All properties are lowercased by using stzHashList
				# In fact, stzHashList automatically lowercaseس all its keys

				aEntity =  StzHashListQ(paEntity).Content()

				# 'name' is compulsory and it must be a valid word
				if NOT ( isString(aEntity[:name]) and StringIsWord(aEntity[:name]) )
					StzRaise(stzEntityError(:CanNotCreateEntityObjectWithIncorrectName))
				ok

				# if 'type' is not provided then it is automatically added
				# and set to 'undefined'

				if StzHashListQ(aEntity).FindKey(:type) = 0
					insert(aEntity, 1, :type = 'undefined')

				else
				# but when it is provided, it must be a valid word
				# (if it is NULL string then it is set to 'undefined'

					if isString(aEntity[:type]) and aEntity[:type] = ""
						aEntity[:type] = 'undefined'

					else

						if NOT ( isString(aEntity[:type]) and StringIsWord(aEntity[:type]) )
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
		bResult = FALSE
		for aPair in This.Entity()
			if aPair[1] = StzStringQ(pcProp).Lowercased()
				bResult = TRUE
				exit
			ok
		next

		return bResult

	def ContainsValue(pValue)
		bResult = FALSE
		for aPair in This.Entity()
			if AreEqual(aPair[1], pValue)
				bResult = TRUE
				exit
			ok
		next

		return bResult

	def Property(pcProp)
		if This.ContainsProperty(pcProp)
			pcProp = StzStringQ(pcProp).Lowercased()
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
