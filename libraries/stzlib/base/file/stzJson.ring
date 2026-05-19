/*
	stzJson Class - Pure Ring Implementation
	Uses Ring lists internally with stzJsonFuncs for serialization
	Engine-backed utility functions (StzJsonIsValid, StzJsonPretty, etc.)
*/

load "stzjsonfuncs.ring"

func StzJsonQ(p)
	return new stzJson(p)

func StzJsonIsValid(cJson)
	pH = StzEngineJsonParse(cJson)
	if pH = NULL
		return FALSE
	ok
	nValid = StzEngineJsonIsValid(pH)
	StzEngineJsonFree(pH)
	return nValid = 1

func StzJsonPretty(cJson)
	pH = StzEngineJsonParse(cJson)
	if pH = NULL
		return ""
	ok
	cResult = StzEngineJsonToStringPretty(pH)
	StzEngineJsonFree(pH)
	return cResult

func StzJsonCompact(cJson)
	pH = StzEngineJsonParse(cJson)
	if pH = NULL
		return ""
	ok
	cResult = StzEngineJsonToString(pH)
	StzEngineJsonFree(pH)
	return cResult

func StzJsonGet(cJson, cKey)
	pH = StzEngineJsonParse(cJson)
	if pH = NULL
		return ""
	ok
	cResult = StzEngineJsonGetString(pH, cKey)
	StzEngineJsonFree(pH)
	return cResult

func StzJsonGetInt(cJson, cKey)
	pH = StzEngineJsonParse(cJson)
	if pH = NULL
		return 0
	ok
	nResult = StzEngineJsonGetInt(pH, cKey)
	StzEngineJsonFree(pH)
	return nResult

func StzJsonHasKey(cJson, cKey)
	pH = StzEngineJsonParse(cJson)
	if pH = NULL
		return FALSE
	ok
	nResult = StzEngineJsonHasKey(pH, cKey)
	StzEngineJsonFree(pH)
	return nResult = 1

func StzJsonKeys(cJson)
	pH = StzEngineJsonParse(cJson)
	if pH = NULL
		return []
	ok
	cKeys = StzEngineJsonKeys(pH)
	StzEngineJsonFree(pH)
	if StzLen(cKeys) = 0
		return []
	ok
	return split(cKeys, nl)

func StzJsonSize(cJson)
	pH = StzEngineJsonParse(cJson)
	if pH = NULL
		return 0
	ok
	nResult = StzEngineJsonSize(pH)
	StzEngineJsonFree(pH)
	return nResult

func StzJsonIsArray(cJson)
	pH = StzEngineJsonParse(cJson)
	if pH = NULL
		return FALSE
	ok
	nResult = StzEngineJsonIsArray(pH)
	StzEngineJsonFree(pH)
	return nResult = 1

Class stzJson from stzObject

	@aData = []
	@bIsArray = FALSE
	@cLastError = ""

def init(p)

    if isString(p)
        p = _TrimJson(p)
        if StzLen(p) = 0
            @cLastError = "Empty JSON string"
            return
        ok
        if NOT _IsValidJsonStructure(p)
            @cLastError = "Invalid JSON string"
            return
        ok
        @aData = JsonToList(p)
        @bIsArray = (StzLeft(p, 1) = "[")

    but isList(p)
        @aData = p
        @bIsArray = NOT IsHashList(p)

    ok

	# Core Properties
	def IsArray()
		return @bIsArray

	def IsEmpty()
		return len(@aData) = 0

	def IsNull()
		return len(@aData) = 0 and @cLastError != ""

	def Size()
		return len(@aData)

		def Count()
			return This.Size()

	# JSON String Operations
	def ToStringXT()
		if @bIsArray
			return ListToJsonXT(@aData)
		else
			return ListToJsonXT(@aData)
		ok

	def ToString()
		if @bIsArray
			return ListToJson(@aData)
		else
			return ListToJson(@aData)
		ok

	# Object Operations
	def HasKey(cKey)
		if @bIsArray
			_SetError("Cannot check key on array")
			return FALSE
		ok
		nLen = len(@aData)
		for i = 1 to nLen
			if isList(@aData[i]) and len(@aData[i]) = 2 and @aData[i][1] = cKey
				return TRUE
			ok
		next
		return FALSE

	def Keys()
		if @bIsArray
			_SetError("Cannot get keys from array")
			return []
		ok
		acKeys = []
		nLen = len(@aData)
		for i = 1 to nLen
			if isList(@aData[i]) and len(@aData[i]) >= 1
				acKeys + @aData[i][1]
			ok
		next
		return acKeys

	def Value(cKey)
		if @bIsArray
			_SetError("Cannot get value by key from array")
			return NULL
		ok
		nLen = len(@aData)
		for i = 1 to nLen
			if isList(@aData[i]) and len(@aData[i]) = 2 and @aData[i][1] = cKey
				return @aData[i][2]
			ok
		next
		return NULL

	def SetValue(cKey, value)
		if @bIsArray
			_SetError("Cannot set value by key on array")
			return This
		ok
		nLen = len(@aData)
		for i = 1 to nLen
			if isList(@aData[i]) and len(@aData[i]) = 2 and @aData[i][1] = cKey
				@aData[i][2] = value
				return This
			ok
		next
		@aData + [cKey, value]
		return This

	def RemoveKey(cKey)
		if @bIsArray
			_SetError("Cannot remove key from array")
			return This
		ok
		aNew = []
		nLen = len(@aData)
		for i = 1 to nLen
			if isList(@aData[i]) and len(@aData[i]) = 2 and @aData[i][1] = cKey
				loop
			ok
			aNew + @aData[i]
		next
		@aData = aNew
		return This

	def TakeKey(cKey)
		if @bIsArray
			_SetError("Cannot take key from array")
			return NULL
		ok
		result = NULL
		aNew = []
		nLen = len(@aData)
		for i = 1 to nLen
			if isList(@aData[i]) and len(@aData[i]) = 2 and @aData[i][1] = cKey
				result = @aData[i][2]
				loop
			ok
			aNew + @aData[i]
		next
		@aData = aNew
		return result

	# Array Operations
	def At(nIndex)
		if not @bIsArray
			_SetError("Cannot get index from object")
			return NULL
		ok
		if nIndex < 1 or nIndex > len(@aData)
			_SetError("Index out of range")
			return NULL
		ok
		return @aData[nIndex]

	def First()
		if not @bIsArray
			_SetError("Cannot get first from object")
			return NULL
		ok
		if len(@aData) = 0
			_SetError("Array is empty")
			return NULL
		ok
		return @aData[1]

	def Last()
		if not @bIsArray
			_SetError("Cannot get last from object")
			return NULL
		ok
		if len(@aData) = 0
			_SetError("Array is empty")
			return NULL
		ok
		return @aData[len(@aData)]

	def Add(value)
		if not @bIsArray
			_SetError("Cannot add to object")
			return This
		ok
		@aData + value
		return This

	def Prepend(value)
		if not @bIsArray
			_SetError("Cannot prepend to object")
			return This
		ok
		insert(@aData, 0, value)
		return This

	def Insert(nIndex, value)
		if not @bIsArray
			_SetError("Cannot insert into object")
			return This
		ok
		if nIndex < 1 or nIndex > len(@aData) + 1
			_SetError("Index out of range")
			return This
		ok
		insert(@aData, nIndex - 1, value)
		return This

	def RemoveAt(nIndex)
		if not @bIsArray
			_SetError("Cannot remove from object by index")
			return This
		ok
		if nIndex < 1 or nIndex > len(@aData)
			_SetError("Index out of range")
			return This
		ok
		del(@aData, nIndex)
		return This

	def RemoveFirst()
		if not @bIsArray
			_SetError("Cannot remove first from object")
			return This
		ok
		if len(@aData) = 0
			_SetError("Array is empty")
			return This
		ok
		del(@aData, 1)
		return This

	def RemoveLast()
		if not @bIsArray
			_SetError("Cannot remove last from object")
			return This
		ok
		if len(@aData) = 0
			_SetError("Array is empty")
			return This
		ok
		del(@aData, len(@aData))
		return This

	def TakeAt(nIndex)
		if not @bIsArray
			_SetError("Cannot take from object by index")
			return NULL
		ok
		if nIndex < 1 or nIndex > len(@aData)
			_SetError("Index out of range")
			return NULL
		ok
		result = @aData[nIndex]
		del(@aData, nIndex)
		return result

	def Contains(value)
		if not @bIsArray
			_SetError("Cannot check contains on object")
			return FALSE
		ok
		nLen = len(@aData)
		for i = 1 to nLen
			if @aData[i] = value
				return TRUE
			ok
		next
		return FALSE

	def Replace(nIndex, value)
		if not @bIsArray
			_SetError("Cannot replace in object by index")
			return This
		ok
		if nIndex < 1 or nIndex > len(@aData)
			_SetError("Index out of range")
			return This
		ok
		@aData[nIndex] = value
		return This

	# Conversion Methods

	def ToList()
		return @aData

	def Copy()
		oCopy = new stzJson(This.ToString())
		return oCopy

	# Utility Methods
	def Clear()
		@aData = []
		return This

	def IsValid()
		return @cLastError = ""

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

	def _SetError(cError)
		@cLastError = cError
