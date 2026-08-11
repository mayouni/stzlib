/*
	stzJson Class - Pure Ring Implementation
	Uses Ring lists internally with stzJsonFuncs for serialization
	Engine-backed utility functions (StzJsonIsValid, StzJsonPretty, etc.)
*/

load "stzjsonfuncs.ring"

func StzJsonQ(p)
	return new stzJson(p)

func StzJsonIsValid(cJson)
	_pH_ = StzEngineJsonParse(cJson)
	if _pH_ = ""
		return 0
	ok
	_nValid_ = StzEngineJsonIsValid(_pH_)
	StzEngineJsonFree(_pH_)
	return _nValid_ = 1

func StzJsonPretty(cJson)
	_pH_ = StzEngineJsonParse(cJson)
	if _pH_ = ""
		return ""
	ok
	_cResult_ = StzEngineJsonToStringPretty(_pH_)
	StzEngineJsonFree(_pH_)
	return _cResult_

func StzJsonCompact(cJson)
	_pH_ = StzEngineJsonParse(cJson)
	if _pH_ = ""
		return ""
	ok
	_cResult_ = StzEngineJsonToString(_pH_)
	StzEngineJsonFree(_pH_)
	return _cResult_

func StzJsonGet(cJson, cKey)
	_pH_ = StzEngineJsonParse(cJson)
	if _pH_ = ""
		return ""
	ok
	_cResult_ = StzEngineJsonGetString(_pH_, cKey)
	StzEngineJsonFree(_pH_)
	return _cResult_

func StzJsonGetInt(cJson, cKey)
	_pH_ = StzEngineJsonParse(cJson)
	if _pH_ = ""
		return 0
	ok
	_nResult_ = StzEngineJsonGetInt(_pH_, cKey)
	StzEngineJsonFree(_pH_)
	return _nResult_

func StzJsonHasKey(cJson, cKey)
	_pH_ = StzEngineJsonParse(cJson)
	if _pH_ = ""
		return 0
	ok
	_nResult_ = StzEngineJsonHasKey(_pH_, cKey)
	StzEngineJsonFree(_pH_)
	return _nResult_ = 1

func StzJsonKeys(cJson)
	_pH_ = StzEngineJsonParse(cJson)
	if _pH_ = ""
		return []
	ok
	_cKeys_ = StzEngineJsonKeys(_pH_)
	StzEngineJsonFree(_pH_)
	if StzLen(_cKeys_) = 0
		return []
	ok
	return split(_cKeys_, nl)

func StzJsonSize(cJson)
	_pH_ = StzEngineJsonParse(cJson)
	if _pH_ = ""
		return 0
	ok
	_nResult_ = StzEngineJsonSize(_pH_)
	StzEngineJsonFree(_pH_)
	return _nResult_

func StzJsonIsArray(cJson)
	_pH_ = StzEngineJsonParse(cJson)
	if _pH_ = ""
		return 0
	ok
	_nResult_ = StzEngineJsonIsArray(_pH_)
	StzEngineJsonFree(_pH_)
	return _nResult_ = 1

Class stzJson from stzObject

	@aData = []
	@bIsArray = 0
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
			return 0
		ok
		_nLen_ = len(@aData)
		for i = 1 to _nLen_
			if isList(@aData[i]) and len(@aData[i]) = 2 and @aData[i][1] = cKey
				return 1
			ok
		next
		return 0

	def Keys()
		if @bIsArray
			_SetError("Cannot get keys from array")
			return []
		ok
		_acKeys_ = []
		_nLen_ = len(@aData)
		for i = 1 to _nLen_
			if isList(@aData[i]) and len(@aData[i]) >= 1
				_acKeys_ + @aData[i][1]
			ok
		next
		return _acKeys_

	def Value(cKey)
		if @bIsArray
			_SetError("Cannot get value by key from array")
			return ""
		ok
		_nLen_ = len(@aData)
		for i = 1 to _nLen_
			if isList(@aData[i]) and len(@aData[i]) = 2 and @aData[i][1] = cKey
				return @aData[i][2]
			ok
		next
		return ""

	def SetValue(cKey, value)
		if @bIsArray
			_SetError("Cannot set value by key on array")
			return This
		ok
		_nLen_ = len(@aData)
		for i = 1 to _nLen_
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
		_aNew_ = []
		_nLen_ = len(@aData)
		for i = 1 to _nLen_
			if isList(@aData[i]) and len(@aData[i]) = 2 and @aData[i][1] = cKey
				loop
			ok
			_aNew_ + @aData[i]
		next
		@aData = _aNew_
		return This

	def TakeKey(cKey)
		if @bIsArray
			_SetError("Cannot take key from array")
			return ""
		ok
		_result_ = ""
		_aNew_ = []
		_nLen_ = len(@aData)
		for i = 1 to _nLen_
			if isList(@aData[i]) and len(@aData[i]) = 2 and @aData[i][1] = cKey
				_result_ = @aData[i][2]
				loop
			ok
			_aNew_ + @aData[i]
		next
		@aData = _aNew_
		return _result_

	# Array Operations
	def At(nIndex)
		if not @bIsArray
			_SetError("Cannot get index from object")
			return ""
		ok
		if nIndex < 1 or nIndex > len(@aData)
			_SetError("Index out of range")
			return ""
		ok
		return @aData[nIndex]

	def First()
		if not @bIsArray
			_SetError("Cannot get first from object")
			return ""
		ok
		if len(@aData) = 0
			_SetError("Array is empty")
			return ""
		ok
		return @aData[1]

	def Last()
		if not @bIsArray
			_SetError("Cannot get last from object")
			return ""
		ok
		if len(@aData) = 0
			_SetError("Array is empty")
			return ""
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
		# Use ring_insert (1-based softanza wrapper) -- bare `insert`
		# resolves case-insensitively to this class's own
		# Insert(nIndex, value) method (2 params) and raises R20.
		ring_insert(@aData, 1, value)
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
		ring_insert(@aData, nIndex, value)
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
			return ""
		ok
		if nIndex < 1 or nIndex > len(@aData)
			_SetError("Index out of range")
			return ""
		ok
		_result_ = @aData[nIndex]
		del(@aData, nIndex)
		return _result_

	def Contains(value)
		if not @bIsArray
			_SetError("Cannot check contains on object")
			return 0
		ok
		_nLen_ = len(@aData)
		for i = 1 to _nLen_
			if @aData[i] = value
				return 1
			ok
		next
		return 0

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
		_oCopy_ = new stzJson(This.ToString())
		return _oCopy_

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
