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

# Holds one named thing as a hash-list of properties: it always has a name, a type and a creation stamp, and answers questions about them.
#
# Build it from a hash-list such as [ :name = "Ana", :type = "person", :age = 30 ]. A missing name
# becomes @noname and a missing type becomes undefined, and the created stamp is set to now.
# Properties are read and set by name without regard to case, so Property("AGE") and Property("age")
# are one property, and the @ method reads, sets one or sets several in a single door. Name and type
# are single words that keep their case, but HasName and IsOfType compare without regard to case, so
# Ana and ana are one name and Person and person are one type. IsEmpty is TRUE when nothing is held
# beyond the name, the type and the creation stamp. ContainsPropertyOrValue tests a text as a
# property name first and as a value second, and tests any other argument as a value only.
#
#   receiver   o1 = new stzEntity([ :name = "ana", :type = "person", :age = 30 ])
#   example    ? o1.Property("AGE")
#              #--> 30
#              o1.SetProperty("city", "Niamey")
#              ? o1.ContainsValue("Niamey")
#              #--> 1
#              ? o1.HasName("ANA")
#              #--> 1
#              ? @@(o1.Properties())
#              #--> [ "name", "type", "age", "created", "city" ]
#   see        stzHashList, stzObject
class stzEntity from stzObject
	@aEntity

	# Builds an entity from a hash-list of properties, adding the name, the type and a creation stamp when they are missing.
	#
	#   paEntity   a hash-list of properties, such as [ :name = "Ana", :type = "person", :age = 30 ]
	#   returns    nothing; the object is built
	#   note       name defaults to @noname and type to undefined; the list you pass is changed in
	#              place, and the created stamp is always set to now, even if you gave one
	#   warning    raises an error when the value is not a hash-list
	#   see        Content, Name
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
	
	
	# Returns the whole entity as its hash-list of properties, with name, type and created included.
	#
	#   returns    a hash-list
	#   see        Properties, Values
	def Content()
		return @aEntity

		# Returns the whole entity, as Content does.
		#
		#   returns    a hash-list
		#   see        Content
		def Value()
			return Content()

		def Entity()
			return This.Content()
	
	# Returns the entity name, in the case it was given.
	#
	#   returns    a text; @noname when none was given
	#   see        SetName, HasName
	def Name()
		return This.Content()[:name]

		# Sets the entity name to a single word, keeping its case.
		#
		#   pcName     the new name, one word
		#   returns    nothing
		#   warning    raises an error for a text of more than one word and for a value that is not
		#              text
		#   see        Name, HasName
		def SetName(pcName)
			if isString(pcName) and @IsWord(pcName)
				@aEntity[:name] = pcName
			else
				StzRaise("Invalid name! Must be a valid word.")
			ok

	# Returns the entity type, in the case it was given.
	#
	#   returns    a text; undefined when none was given
	#   see        SetType, IsOfType
	def Type()
		return This.Content()[:type]

		# Sets the entity type to a single word, keeping its case.
		#
		#   pcType     the new type, one word
		#   returns    nothing
		#   warning    raises an error for a text of more than one word and for a value that is not
		#              text
		#   see        Type, IsOfType
		def SetType(pcType)
			if isString(pcType) and @IsWord(pcType)
				@aEntity[:type] = pcType
			else
				StzRaise("Invalid type! Must be a valid word.")
			ok

	# Returns the creation stamp, a date and time text set at construction.
	#
	#   returns    a text such as 09/10/2026 13:28:08
	#   see        Copy
	def Created()
		return @aEntity[:created]

	# TRUE if the argument is a property name or a value of the entity.
	#
	#   pPropOrVal   a property name, or a value to look for
	#   returns      TRUE or FALSE
	#   note         a text is tested as a property name first, then as a value; any other argument
	#                is tested as a value only, since a property name is text, and never raises
	#   see          ContainsProperty, ContainsValue
	def ContainsPropertyOrValue(pPropOrVal)
		if isString(pPropOrVal)
			if This.ContainsProperty(pPropOrVal)
				return 1
			ok
		ok

		return This.ContainsValue(pPropOrVal)

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

	# TRUE if the entity has a property of that name.
	#
	#   pcProp     the property name, compared without regard to case
	#   returns    TRUE or FALSE
	#   warning    raises an error when the name is not a text
	#   see        ContainsValue, FindProperty
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

	# TRUE if any property holds that value, name, type and created included.
	#
	#   pValue     the value to look for, compared with its exact case
	#   returns    TRUE or FALSE
	#   see        ContainsProperty, Values
	def ContainsValue(pValue)
		_bResult_ = 0
		_aThisEntity3_ = This.Entity()
		_nThisEntity3Len_ = len(_aThisEntity3_)
		for _iLoopThisEntity3_ = 1 to _nThisEntity3Len_
			_aPair_ = _aThisEntity3_[_iLoopThisEntity3_]
			if @AreEqual([ _aPair_[2], pValue ])
				_bResult_ = 1
				exit
			ok
		next

		return _bResult_

	# Returns the value of a property.
	#
	#   pcProp     the property name, compared without regard to case
	#   returns    the value, of any type
	#   warning    raises an error for a property that does not exist and for a name that is not a
	#              text
	#   see        SetProperty, ContainsProperty
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

	# Reads or sets properties in one door: a text reads one, a pair sets one, a list of pairs sets several.
	#
	#   p          a property name to read, a [ name, value ] pair to set, or a list of such pairs
	#              to set
	#   returns    the value for a text; nothing for a pair or a list of pairs
	#   warning    raises an error for any other kind of argument, and for an unknown property name
	#   see        Property, SetProperty
	def @(p)
		if isString(p)
			return This.Property(p)

		but isList(p)
			if len(p) = 2 and isString(p[1])
				This.SetProperty(p[1], p[2])
				return

			but IsListOfPairs(p)
				_nLen_ = len(p)
				for i = 1 to _nLen_
					This.SetProperty(p[i][1], p[i][2])
				next
				return
			ok
		ok

		StzRaise("Incorrect param type! p must be a string or a pair of a string and on other value of any type.")


	# Sets a property, adding it at the end when it is new.
	#
	#   pcProp     the property name, lower-cased before use
	#   pValue     the value, of any type
	#   returns    nothing
	#   warning    raises an error when the name is not a text
	#   see        Property, RemoveProperty
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

		# Sets a property, as SetProperty does, under a shorter name.
		#
		#   pcProp     the property name
		#   pValue     the value
		#   returns    nothing
		#   see        SetProperty
		def SetProp(pcProp, pValue)
			This.SetProperty(pcProp, pValue)

		# Sets a property, as SetProperty does, in the symbol form.
		#
		#   pcProp     the property name
		#   pValue     the value
		#   returns    nothing
		#   see        SetProperty
		def Set@(pcProp, pValue)
			This.SetProperty(pcProp, pValue)

		# Sets a property, as SetProperty does, in the other symbol form.
		#
		#   pcProp     the property name
		#   pValue     the value
		#   returns    nothing
		#   see        SetProperty
		def @Set(pcProp, pValue)
			This.SetProperty(pcProp, pValue)

	# Returns the position of a property among the properties.
	#
	#   pcProp     the property name
	#   returns    a number, 1 for the first; 0 when absent
	#   note       name, type and created count too, so the position is not the position among your
	#              own properties
	#   warning    raises an error when the name is not a text
	#   see        Properties, ContainsProperty
	def FindProperty(pcProp)
		if NOT isString(pcProp)
			StzRaise("Incorrect param type! pcProp must be a string.")
		ok

		pcProp = StzLower(pcProp)
		if NOT HasKey(@aEntity, pcProp)
			return 0
		else
			_nLen_ = len(@aEntity)
			for i = 1 to _nLen_
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

	# Removes one property from the entity by its name.
	#
	#   pcProp     the property name
	#   returns    nothing
	#   warning    raises an error for a property that does not exist and for a name that is not a
	#              text
	#   see        SetProperty, FindProperty
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

		# Removes a property, as RemoveProperty does, under a shorter name.
		#
		#   pcProp     the property name
		#   returns    nothing
		#   see        RemoveProperty
		def RemoveProp(pcProp)
			This.RemoveProperty(pcProp)

		# Removes a property, as RemoveProperty does, in the symbol form.
		#
		#   pcProp     the property name
		#   returns    nothing
		#   see        RemoveProperty
		def Remove@(pcProp)
			This.RemoveProperty(pcProp)

		# Removes a property, as RemoveProperty does, in the other symbol form.
		#
		#   pcProp     the property name
		#   returns    nothing
		#   see        RemoveProperty
		def @Remove(pcProp)
			This.RemoveProperty(pcProp)

	# Returns the property names, in order.
	#
	#   returns    a list of text, starting with those of name and type
	#   see        Values, Size
	def Properties()
		_aResult_ = []
		_aThisEntity2_ = This.Entity()
		_nThisEntity2Len_ = len(_aThisEntity2_)
		for _iLoopThisEntity2_ = 1 to _nThisEntity2Len_
			_aProp_ = _aThisEntity2_[_iLoopThisEntity2_]
			_aResult_ + _aProp_[1]
		next
		return _aResult_

		# Returns the property names, as Properties does, under a shorter name.
		#
		#   returns    a list of text
		#   see        Properties
		def Props()
			return Properties()

	# Returns the property values, in the order of the property names.
	#
	#   returns    a list of values
	#   see        Properties, Content
	def Values()
		return StzHashListQ( This.Content() ).Values()

	# Tells whether the entity type is the given type, without regard to case.
	#
	#   pcType     the type to test; Person and person are one type, and so are accented capitals
	#              and their small forms
	#   returns    TRUE or FALSE; FALSE for a value that is not a text, and for a type that only
	#              starts like the stored one
	#   see        Type, SetType
	def IsOfType(pcType)
		if NOT isString(pcType)
			return 0
		ok

		_cStoredType_ = This.Type()
		if NOT isString(_cStoredType_)
			return 0
		ok

		if strcmp( StzLower(_cStoredType_), StzLower(pcType) ) = 0
			return 1
		else
			return 0
		ok

	# Tells whether the entity name is the given name, without regard to case.
	#
	#   pcName     the name to test; Ana and ana are one name, and so are accented capitals and
	#              their small forms
	#   returns    TRUE or FALSE; FALSE for a value that is not a text, and for a name that only
	#              starts like the stored one
	#   see        Name, SetName
	def HasName(pcName)
		if NOT isString(pcName)
			return 0
		ok

		_cStoredName_ = This.Name()
		if NOT isString(_cStoredName_)
			return 0
		ok

		if strcmp( StzLower(_cStoredName_), StzLower(pcName) ) = 0
			return 1
		else
			return 0
		ok

	# Returns a new entity with the same properties.
	#
	#   returns    a stzEntity
	#   note       the copy is independent of the original; its created stamp is set to now
	#   see        Content, Created
	def Copy()
		return new stzEntity( This.Content() )

	# Returns how many properties the entity holds, name, type and created included.
	#
	#   returns    a number; 3 at least
	#   see        Properties, IsEmpty
	def Size()
		return len( This.Properties() )

		def NumberOfProperties()
			return This.Size()

	# Tells whether the entity holds nothing beyond its name, its type and its creation stamp.
	#
	#   returns    TRUE or FALSE; TRUE for a fresh entity built with a name and a type only, FALSE
	#              once any other property is set, and TRUE again when that property is removed
	#   note       name, type and created are the bookkeeping the entity always carries, and they do
	#              not count, whatever the case of their keys
	#   see        Size, RemoveProperty
	def IsEmpty()
		_nEmptyLen_ = ring_len(@aEntity)
		for _iEmpty_ = 1 to _nEmptyLen_
			_cEmptyKey_ = StzLower( @aEntity[_iEmpty_][1] )
			if _cEmptyKey_ != "name" and _cEmptyKey_ != "type" and _cEmptyKey_ != "created"
				return 0
			ok
		next

		return 1

	# Prints the entity name and type, then one line for each other property.
	#
	#   returns    nothing; it prints
	#   see        Content, Properties
	def Show()
		? "Entity: " + This.Name() + " (Type: " + This.Type() + ")"
		_aThisEntity1_ = This.Entity()
		_nThisEntity1Len_ = len(_aThisEntity1_)
		for _iLoopThisEntity1_ = 1 to _nThisEntity1Len_
			_aProp_ = _aThisEntity1_[_iLoopThisEntity1_]
			if _aProp_[1] != "name" and _aProp_[1] != "type"
				? "  " + _aProp_[1] + ": " + _aProp_[2]
			ok
		next
