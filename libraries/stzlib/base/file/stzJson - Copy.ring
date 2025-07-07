/*
	stzJson Class - Professional Grade JSON Library for Softanza
	Built on Qt's high-performance JSON framework via RingQt
*/

load "stzJsonFuncs.ring"
load "jsonlib.ring"

Class stzJson from stzObject
	
	@oQJsonDoc
	@oQJsonObj
	@oQJsonArray
	@bIsArray = FALSE
	@cLastError = ""
	
def init(p)
    @oQJsonDoc = new QJsonDocument()
    
    if isString(p)
        # Parse JSON string
        oByteArray = StringToQByteArray(p)
        oError = new QJsonParseError()
        @oQJsonDoc = @oQJsonDoc.fromJson(oByteArray, oError)
        if @oQJsonDoc.isNull()
            @cLastError = "Invalid JSON string: " + oError.errorString()
            return
        ok
        
    but isList(p)
        # Convert list to JSON string using char(34) and char(44)
        cJson = ListToJson(p)

        if @cLastError != ""
            return
        ok
        oByteArray = StringToQByteArray(cJson)
        oError = new QJsonParseError()
        @oQJsonDoc = @oQJsonDoc.fromJson(oByteArray, oError)
        if @oQJsonDoc.isNull()
            @cLastError = "Invalid JSON string generated from list: " + oError.errorString()
            return
        ok
        
    but isObject(p) and ClassOfObject(p) = "QJsonDocument"
        @oQJsonDoc = p
        
    ok
    
    _UpdateInternalRefs()
	
	# Core Properties
	def IsArray()
		return @oQJsonDoc.isArray()
	
	def IsObject()
		return @oQJsonDoc.isObject()
	
	def IsEmpty()
		return @oQJsonDoc.isEmpty()
	
	def IsNull()
		return @oQJsonDoc.isNull()
	
	def Size()
		if @bIsArray
			return @oQJsonArray.size()
		else
			return @oQJsonObj.size()
		ok
	
		def Count()
			return @Size()
	
	# JSON String Operations
	def ToStringXT()
		oByteArray = @oQJsonDoc.toJson(0) # QJsonDocument::Indented
		cResult = QByteArrayToString(oByteArray)
		return cResult
	
	def ToString()
		oByteArray = @oQJsonDoc.toJson(1) # QJsonDocument::Compact
		return QByteArrayToString(oByteArray)
	
	# Object Operations
	def HasKey(cKey)
		if @bIsArray
			@SetError("Cannot check key on array")
			return FALSE
		ok
		return @oQJsonObj.contains(cKey)
	
	def Keys()
		if @bIsArray
			@SetError("Cannot get keys from array")
			return []
		ok
		return @oQJsonObj.keys()
	
	def Value(cKey)
		if @bIsArray
			@SetError("Cannot get value by key from array")
			return NULL
		ok
		oJsonValue = @oQJsonObj.value(cKey)
		return oJsonValue.toVariant()
	
	def SetValue(cKey, value)
		if @bIsArray
			_SetError("Cannot set value by key on array")

		ok
		
		oJsonValue = new QJsonValue()
		oJsonValue = oJsonValue.fromVariant(value)
		# Note: QJsonObject doesn't have insert() in the provided API
		# We'll need to rebuild the object
		_RebuildObjectWithNewValue(cKey, oJsonValue)

	
	def RemoveKey(cKey)
		if @bIsArray
			_SetError("Cannot remove key from array")
			return This
		ok
		@oQJsonObj.remove(cKey)
		_UpdateDocument()

	
	def TakeKey(cKey)
		if @bIsArray
			_SetError("Cannot take key from array")
			return NULL
		ok
		oJsonValue = @oQJsonObj.take(cKey)
		_UpdateDocument()
		return oJsonValue.toVariant()
	
	# Array Operations
	def At(nIndex)
		if not @bIsArray
			_SetError("Cannot get index from object")
			return NULL
		ok
		if nIndex < 1 or nIndex > @oQJsonArray.size()
			_SetError("Index out of range")
			return NULL
		ok
		oJsonValue = @oQJsonArray.at(nIndex - 1)
		return oJsonValue.toVariant()
	
	def First()
		if not @bIsArray
			_SetError("Cannot get first from object")
			return NULL
		ok
		if @oQJsonArray.isEmpty()
			_SetError("Array is empty")
			return NULL
		ok
		oJsonValue = @oQJsonArray.first()
		return oJsonValue.toVariant()
	
	def Last()
		if not @bIsArray
			_SetError("Cannot get last from object")
			return NULL
		ok
		if @oQJsonArray.isEmpty()
			_SetError("Array is empty")
			return NULL
		ok
		oJsonValue = @oQJsonArray.last()
		return oJsonValue.toVariant()
	
	def Add(value)
		if not @bIsArray
			_SetError("Cannot add to object")

		ok
		oJsonValue = new QJsonValue()
		oJsonValue = oJsonValue.fromVariant(value)
		@oQJsonArray.append(oJsonValue)
		_UpdateDocument()

	
	def Prepend(value)
		if not @bIsArray
			_SetError("Cannot prepend to object")
			return This
		ok
		oJsonValue = new QJsonValue()
		oJsonValue = oJsonValue.fromVariant(value)
		@oQJsonArray.prepend(oJsonValue)
		_UpdateDocument()

	
	def Insert(nIndex, value)
		if not @bIsArray
			_SetError("Cannot insert into object")

		ok
		if nIndex < 1 or nIndex > @oQJsonArray.size() + 1
			_SetError("Index out of range")

		ok
		oJsonValue = new QJsonValue()
		oJsonValue = oJsonValue.fromVariant(value)
		@oQJsonArray.insert(nIndex - 1, oJsonValue)
		_UpdateDocument()

	
	def RemoveAt(nIndex)
		if not @bIsArray
			_SetError("Cannot remove from object by index")

		ok
		if nIndex < 1 or nIndex > @oQJsonArray.size()
			_SetError("Index out of range")

		ok
		@oQJsonArray.removeAt(nIndex - 1)
		_UpdateDocument()

	
	def RemoveFirst()
		if not @bIsArray
			_SetError("Cannot remove first from object")

		ok
		if @oQJsonArray.isEmpty()
			_SetError("Array is empty")

		ok
		@oQJsonArray.removeFirst()
		_UpdateDocument()
	
	def RemoveLast()
		if not @bIsArray
			_SetError("Cannot remove last from object")
			
		ok
		if @oQJsonArray.isEmpty()
			_SetError("Array is empty")
			
		ok
		@oQJsonArray.removeLast()
		_UpdateDocument()
		
	
	def TakeAt(nIndex)
		if not @bIsArray
			_SetError("Cannot take from object by index")
			return NULL
		ok
		if nIndex < 1 or nIndex > @oQJsonArray.size()
			_SetError("Index out of range")
			return NULL
		ok
		oJsonValue = @oQJsonArray.takeAt(nIndex - 1)
		_UpdateDocument()
		return oJsonValue.toVariant()
	
	def Contains(value)
		if not @bIsArray
			_SetError("Cannot check contains on object")
			return FALSE
		ok
		oJsonValue = new QJsonValue()
		oJsonValue = oJsonValue.fromVariant(value)
		return @oQJsonArray.contains(oJsonValue)
	
	def Replace(nIndex, value)
		if not @bIsArray
			_SetError("Cannot replace in object by index")
			
		ok

		if nIndex < 1 or nIndex > @oQJsonArray.size()
			_SetError("Index out of range")
			
		ok

		oJsonValue = new QJsonValue()
		oJsonValue = oJsonValue.fromVariant(value)
		@oQJsonArray.replace(nIndex - 1, oJsonValue)

		_UpdateDocument()
		
	
	# Conversion Methods
	def ToVariant()
		return @oQJsonDoc.toVariant()
	
	def ToList()

		if @bIsArray
			return @oQJsonArray.toVariantList()

		else
			# For objects, we need to manually build the list
			acKeys = @oQJsonObj.keys()
			aResult = []
			nLen = len(acKeys)

			for i = 1 to nLen
				oValue = @oQJsonObj.value(acKeys[i])
				aResult + [acKeys[i], oValue.toVariant()]
			next

			return aResult
		ok
	
	def Copy()
		return new stzJson(@oQJsonDoc)
	
	# Utility Methods
	def Clear()

		if @bIsArray

			@oQJsonArray = new QJsonArray()
			@oQJsonDoc.setArray(@oQJsonArray)

		else
			@oQJsonObj = new QJsonObject()
			@oQJsonDoc.setObject(@oQJsonObj)
		ok
		
	
	def Valid()
		return not @oQJsonDoc.isNull()
	
	# Error Handling
	def LastError()
		return @cLastError
	
	def HasError()
		return @cLastError != ""
	
	def ClearError()
		@cLastError = ""
		
	
	# Static Factory Methods
	def FromString(cJson)
		return new stzJson(cJson)
	
	def FromList(aList)
		return new stzJson(aList)
	
	def EmptyObject()
		return new stzJson("{}")
	
	def EmptyArray()
		return new stzJson("[]")
	
	# Display
	def Show()
		? _ToStringFormatted()
	
	def Print()
		? _ToString()
	
	# Private Methods
	private
	
	def _UpdateInternalRefs()
		if @oQJsonDoc.isArray()
			@oQJsonArray = @oQJsonDoc.array()
			@bIsArray = TRUE
		else
			@oQJsonObj = @oQJsonDoc.object()
			@bIsArray = FALSE
		ok
	
	def _UpdateDocument()
		if @bIsArray
			@oQJsonDoc.setArray(@oQJsonArray)
		else
			@oQJsonDoc.setObject(@oQJsonObj)
		ok
	
	def _SetError(cError)
		@cLastError = cError
	
	def _RebuildObjectWithNewValue(cKey, oJsonValue)
		# Since QJsonObject doesn't have insert in the API,
		# we need to rebuild using variant map
		acKeys = @oQJsonObj.keys()
		nLen = len(acKeys)
		aMap = []

		# Add existing keys

		for i = 1 to nLen
			if acKeys[i] != cKey
				oExistingValue = @oQJsonObj.value(acKeys[i])
				aMap + [acKeys[i], oExistingValue.toVariant()]
			ok
		next
		
		# Add new/updated key
		aMap + [cKey, oJsonValue.toVariant()]
		
		# Rebuild object
		@oQJsonObj = new QJsonObject()
		@oQJsonObj = @oQJsonObj.fromVariantMap(aMap)
		_UpdateDocument()
	

	def _ValueToJsonString(vValue)

	    if isString(vValue)
	        return vValue + char(34)

	    but isNumber(vValue)
	        return "" + vValue

	    but isNULL(vValue)
	        return "null"

	    but vValue = TRUE
	        return "true"

	    but vValue = FALSE
	        return "false"

	    but isList(vValue)
	        return @ListToJsonString(vValue)

	    else
	        @cLastError = "Unsupported value type: " + type(vValue)
	        return ""
	    ok
