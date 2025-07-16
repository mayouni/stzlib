/*
	stzJson Class - Performance Optimized Version
	Built on Qt's high-performance JSON framework via RingQt
*/

load "stzJsonFuncs.ring"

Class stzJson from stzObject
	
	@oQJsonDoc
	@oQJsonObj
	@oQJsonArray
	@bIsArray = FALSE
	@cLastError = ""

	@aStringBuilder = []  # For efficient string concatenation
	
def init(p)
    @oQJsonDoc = new QJsonDocument()

    @aStringBuilder = []
    
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
        #NOTE #TODO
		# Normally we should use Qt's built-in conversion like this:

         # 	@oQJsonDoc = @oQJsonDoc.fromVariant(obj2ptr(p))
	    #   if @oQJsonDoc.isNull()
	    #       @cLastError = "Invalid list structure"
	    #      return
	    #   ok
    
		# But this does not return anything!

		# As an alternative solution, I'll transform the p list into
		# a json string using ListToJson() from stzJsonFuncs file,
		# and reuse the "if isString(p)" section of this code.

		cJson = ListToJson(p)
		This.Init(cJson)

    but isObject(p) and ClassOfObject(p) = "QJsonDocument"
        @oQJsonDoc = p
        
    ok
    
    _UpdateInternalRefs()
	
	# Core Properties
	def IsArray()
		return @bIsArray

	
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
			return This.Size()
	
	# Optimized JSON String Operations
	def ToStringXT()
		oByteArray = @oQJsonDoc.toJson(0) # QJsonDocument::Indented
		return QByteArrayToString(oByteArray)
	
	def ToString()
		oByteArray = @oQJsonDoc.toJson(1) # QJsonDocument::Compact
		return QByteArrayToString(oByteArray)
	
	# Object Operations - Optimized
	def HasKey(cKey)
		if @bIsArray
			_SetError("Cannot check key on array")
			return FALSE
		ok
		return @oQJsonObj.contains(cKey)
	
	def Keys()
		if @bIsArray
			_SetError("Cannot get keys from array")
			return []
		ok

		return QStringListToList( @oQJsonObj.keys() )
	
	def Value(cKey)
		if @bIsArray
			_SetError("Cannot get value by key from array")
			return NULL
		ok

		result = QVariantContent( @oQJsonObj.value(cKey).toVariant() )
		return result
	
	def SetValue(cKey, value)
		if @bIsArray
			_SetError("Cannot set value by key on array")
			return This
		ok
		
		# Use direct Qt method instead of rebuilding
		oJsonValue = _ToJsonValue(value)
		@oQJsonObj.insert(cKey, oJsonValue)
		_UpdateDocument()
		return This
	
	def RemoveKey(cKey)
		if @bIsArray
			_SetError("Cannot remove key from array")
			return This
		ok
		
		@oQJsonObj.remove(cKey)
		_UpdateDocument()
		return This
	
	def TakeKey(cKey)
		if @bIsArray
			_SetError("Cannot take key from array")
			return NULL
		ok
		
		result = QVariantContent( @oQJsonObj.take(cKey).toVariant() )
		_UpdateDocument()
		return result
	
	# Array Operations - Optimized
	def At(nIndex)
		if not @bIsArray
			_SetError("Cannot get index from object")
			return NULL
		ok
		if nIndex < 1 or nIndex > @oQJsonArray.size()
			_SetError("Index out of range")
			return NULL
		ok
		result = QVariantContent( @oQJsonArray.at(nIndex - 1).toVariant() )
		return result
	
	def First()
		if not @bIsArray
			_SetError("Cannot get first from object")
			return NULL
		ok
		if @oQJsonArray.isEmpty()
			_SetError("Array is empty")
			return NULL
		ok
		result = QVAriantContent( @oQJsonArray.first() .toVariant() )
		return result
	
	def Last()
		if not @bIsArray
			_SetError("Cannot get last from object")
			return NULL
		ok
		if @oQJsonArray.isEmpty()
			_SetError("Array is empty")
			return NULL
		ok
		result = QVariantContent( @oQJsonArray.last().toVariant() )
		return result
	
	def Add(value)
		if not @bIsArray
			_SetError("Cannot add to object")
			return This
		ok
		oJsonValue = _ToVariant(value)
		@oQJsonArray.append(oJsonValue)
		_UpdateDocument()
		return This
	
	def Prepend(value)
		if not @bIsArray
			_SetError("Cannot prepend to object")
			return This
		ok
		oJsonValue = _ToVariant(value)
		@oQJsonArray.prepend(oJsonValue)
		_UpdateDocument()
		return This
	
	def Insert(nIndex, value)
		if not @bIsArray
			_SetError("Cannot insert into object")
			return This
		ok
		if nIndex < 1 or nIndex > @oQJsonArray.size() + 1
			_SetError("Index out of range")
			return This
		ok
		oJsonValue = _ToVariant(value)
		@oQJsonArray.insert(nIndex - 1, oJsonValue)
		_UpdateDocument()
		return This
	
	def RemoveAt(nIndex)
		if not @bIsArray
			_SetError("Cannot remove from object by index")
			return This
		ok
		if nIndex < 1 or nIndex > @oQJsonArray.size()
			_SetError("Index out of range")
			return This
		ok
		@oQJsonArray.removeAt(nIndex - 1)
		_UpdateDocument()
		return This
	
	def RemoveFirst()
		if not @bIsArray
			_SetError("Cannot remove first from object")
			return This
		ok
		if @oQJsonArray.isEmpty()
			_SetError("Array is empty")
			return This
		ok
		@oQJsonArray.removeFirst()
		_UpdateDocument()
		return This
	
	def RemoveLast()
		if not @bIsArray
			_SetError("Cannot remove last from object")
			return This
		ok
		if @oQJsonArray.isEmpty()
			_SetError("Array is empty")
			return This
		ok
		@oQJsonArray.removeLast()
		_UpdateDocument()
		return This
	
	def TakeAt(nIndex)
		if not @bIsArray
			_SetError("Cannot take from object by index")
			return NULL
		ok
		if nIndex < 1 or nIndex > @oQJsonArray.size()
			_SetError("Index out of range")
			return NULL
		ok
		result = QVariantContent( @oQJsonArray.takeAt(nIndex - 1).toVariant() )
		_UpdateDocument()
		return result
	
	def Contains(value)
		if not @bIsArray
			_SetError("Cannot check contains on object")
			return FALSE
		ok
		oJsonValue = _ToVariant(value)
		return @oQJsonArray.contains(oJsonValue)
	
	def Replace(nIndex, value)
		if not @bIsArray
			_SetError("Cannot replace in object by index")
			return This
		ok
		if nIndex < 1 or nIndex > @oQJsonArray.size()
			_SetError("Index out of range")
			return This
		ok
		oJsonValue = _ToVariant(value)
		@oQJsonArray.replace(nIndex - 1, oJsonValue)
		_UpdateDocument()
		return This
	
	# Conversion Methods - User-Friendly Names

	def ToList()
		return JsonToList(This.toString())

	def Copy()
		oCopy = new stzJson(@oQJsonDoc)
		return oCopy
	
	# Utility Methods
	def Clear()

		if @bIsArray
			@oQJsonArray = new QJsonArray()
			@oQJsonDoc.setArray(@oQJsonArray)
		else
			@oQJsonObj = new QJsonObject()
			@oQJsonDoc.setObject(@oQJsonObj)
		ok
		return This
	
	def IsValid()
		return not @oQJsonDoc.isNull()
	
	# Error Handling
	def LastError()
		return @cLastError
	
	def HasError()
		return @cLastError != ""
	
	def ClearError()
		@cLastError = ""
		return This
	
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
		? This.ToStringXT()
	
	def Print()
		? This.ToString()
	
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
	
	def _DirectSetValue(cKey, oJsonValue)
		# Use Qt's internal method directly - more efficient than rebuilding
		acKeys = QStringListToList( @oQJsonObj.keys() )
		nLen = len(acKeys)
		aMap = []
		
		# Build variant map efficiently
		for i = 1 to nLen
			if acKeys[i] != cKey
				oExistingValue = @oQJsonObj.value(acKeys[i])
				aMap + [acKeys[i], QVariantContent(oExistingValue.toVariant())]
			ok
		next
		
		# Add new/updated key
		aMap + [cKey, QVariantContent(oJsonValue.toVariant())]
		
		# Rebuild from map
		@oQJsonObj = new QJsonObject()
		@oQJsonObj = @oQJsonObj.fromVariantMap(aMap)
		_UpdateDocument()
	
	# Qt Variant Conversion (Hidden from users)

	def _ToVariant(value)

		oJsonValue = new QJsonValue()
		return oJsonValue.fromVariant(value)
	
	
	def _FromVariantList(oJsonArray)
		return oJsonArray.toVariantList()
	
	def _ToVariantFromDoc(oJsonDoc)
		return oJsonDoc.toVariant()
