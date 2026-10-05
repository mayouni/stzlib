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

# Holds a JSON document as a Ring list, as an object of keys or an array of items, and records its mistakes instead of raising them.
#
# Built from a JSON text or from a Ring list. An object is read and changed by key (HasKey, Value,
# SetValue, RemoveKey, TakeKey) and an array by position (At, Add, Insert, RemoveAt, TakeAt ...). A
# call that does not fit the kind of JSON held, or an index outside the array, leaves the object
# unchanged and records a message in LastError. Writing an array that holds anything back to text
# fails today (ToString, Copy, Show, Print): see their warnings.
#
#   receiver   o1 = new stzJson('{"name": "John", "age": 30}')
#   example    ? o1.Value("name")
#              #--> John
#              ? o1.ToString()
#              #--> {"name":"John","age":30}
#   see        stzHashList
Class stzJson from stzObject

	@aData = []
	@bIsArray = 0
	@cLastError = ""

# Builds the object from a JSON text or from a Ring list; an empty or invalid text leaves it empty and records an error.
#
#   p          a JSON text, or a Ring list (a list of [ key, value ] pairs gives an object, any
#              other list gives an array)
#   returns    nothing; the object is built
#   note       a text that is not valid JSON never raises: read LastError; an argument that is
#              neither text nor list builds an empty object with no error
#   see        FromString, FromList, LastError
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

	# TRUE if the JSON held is an array, FALSE if it is an object.
	#
	#   note       a list given to the constructor counts as an array unless it is a list of [ key,
	#              value ] pairs
	#   see        IsEmpty, Keys
	#@ aka  Core Properties
	def IsArray()
		return @bIsArray

	# TRUE if the object holds no key and no item, as after Clear or after a text that failed to parse.
	#
	#   note       an empty object and an empty array are both empty
	#   see        IsNull, Size
	def IsEmpty()
		return len(@aData) = 0

	# TRUE if the object is empty and an error has been recorded, as after a text that is not valid JSON.
	#
	#   note       an empty object built from a valid text is not null
	#   see        IsEmpty, HasError
	def IsNull()
		return len(@aData) = 0 and @cLastError != ""

	# Returns how many keys the object holds, or how many items the array holds.
	#
	#   returns    a number
	#   note       Count gives the same answer
	#   see        IsEmpty
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

	# Returns the content as JSON text on one line, without spaces after the colons and commas.
	#
	#   returns    a text
	#   note       an empty object, like an empty array, comes out as [ ]; ToStringXT gives the
	#              indented form and fails the same way
	#   warning    Raises error "aList must be a well-formatted JSON list" today for an array that
	#              holds anything, because the serializer accepts only lists of pairs and an empty
	#              list
	#   see        ToList, Print, Show
	def ToString()
		if @bIsArray
			return ListToJson(@aData)
		else
			return ListToJson(@aData)
		ok

	# TRUE if the object has the key; on an array it answers FALSE and records an error.
	#
	#   cKey       the key to look for, as text
	#   note       the answer is FALSE and LastError reads "Cannot check key on array" when the JSON
	#              is an array
	#   see        Keys, Value
	#@ aka  Object Operations
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

	# Returns the keys of the object, in the order they have in the JSON text.
	#
	#   returns    a list of text; [ ] for an array, with an error recorded
	#   see        HasKey, Value
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

	# Returns the value stored under the key, or an empty text when the key is absent.
	#
	#   cKey       the key to read, as text
	#   returns    the value: a text, a number, or a list of [ key, value ] pairs for a nested
	#              object
	#   note       true and false in the JSON come back as 1 and 0; an absent key records no error;
	#              an array answers an empty text and records an error
	#   see        SetValue, TakeKey, HasKey
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

	# Sets the key to the value, replacing the old value or adding the key at the end; returns the object itself.
	#
	#   cKey       the key to set, as text
	#   value      the value to store: a text, a number or a list
	#   returns    the stzJson itself, so calls chain
	#   note       on an array nothing changes and LastError reads "Cannot set value by key on
	#              array"
	#   see        Value, RemoveKey
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

	# Removes the key and its value from the object, in place; returns the object itself.
	#
	#   cKey       the key to remove, as text
	#   returns    the stzJson itself, so calls chain
	#   note       an absent key changes nothing and records no error; an array records an error and
	#              changes nothing
	#   see        TakeKey, SetValue
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

	# Removes the key from the object, in place, and returns the value it held.
	#
	#   cKey       the key to take, as text
	#   returns    the value that was stored; an empty text when the key is absent
	#   note       an array answers an empty text and records an error
	#   see        RemoveKey, Value
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

	# Returns the item at position nIndex of the array, 1 being the first.
	#
	#   nIndex     the position of the item, from 1
	#   returns    the item; an empty text when nIndex is outside the array, with an error recorded
	#   note       an object answers an empty text and records the error "Cannot get index from
	#              object"
	#   see        First, Last, TakeAt
	#@ aka  Array Operations
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

	# Returns the first item of the array.
	#
	#   returns    the item; an empty text for an empty array, with an error recorded
	#   note       an object answers an empty text and records an error
	#   see        Last, At
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

	# Returns the last item of the array.
	#
	#   returns    the item; an empty text for an empty array, with an error recorded
	#   note       an object answers an empty text and records an error
	#   see        First, At
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

	# Appends the value after the last item of the array, in place; returns the object itself.
	#
	#   value      the item to append
	#   returns    the stzJson itself, so calls chain
	#   note       on an object nothing changes and LastError reads "Cannot add to object"
	#   see        Prepend, Insert
	def Add(value)
		if not @bIsArray
			_SetError("Cannot add to object")
			return This
		ok
		@aData + value
		return This

	# Puts the value before the first item of the array, in place; returns the object itself.
	#
	#   value      the item to put first
	#   returns    the stzJson itself, so calls chain
	#   note       on an object nothing changes and an error is recorded
	#   see        Add, Insert
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

	# Inserts the value at position nIndex of the array, in place, pushing the later items one place on; returns the object itself.
	#
	#   nIndex     the position the new item takes, from 1 to one past the last
	#   value      the item to insert
	#   returns    the stzJson itself, so calls chain
	#   note       a position outside that range changes nothing and records "Index out of range";
	#              an object records an error
	#   see        Add, Prepend, RemoveAt
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

	# Removes the item at position nIndex of the array, in place; returns the object itself.
	#
	#   nIndex     the position of the item to remove, from 1
	#   returns    the stzJson itself, so calls chain
	#   note       a position outside the array changes nothing and records "Index out of range"
	#   see        TakeAt, RemoveFirst
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

	# Removes the first item of the array, in place; returns the object itself.
	#
	#   returns    the stzJson itself, so calls chain
	#   note       an empty array records the error "Array is empty"
	#   see        RemoveLast, RemoveAt
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

	# Removes the last item of the array, in place; returns the object itself.
	#
	#   returns    the stzJson itself, so calls chain
	#   note       an empty array records the error "Array is empty"
	#   see        RemoveFirst, RemoveAt
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

	# Removes the item at position nIndex of the array, in place, and returns it.
	#
	#   nIndex     the position of the item to take, from 1
	#   returns    the item that was removed; an empty text when nIndex is outside the array
	#   note       a position outside the array records "Index out of range"
	#   see        RemoveAt, At
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

	# TRUE if some item of the array equals the value.
	#
	#   value      the item to look for
	#   returns    TRUE or FALSE
	#   note       the comparison is Ring's loose equality, so 30 and "30" match; an object answers
	#              FALSE and records an error
	#   see        At
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

	# Puts the value in place of the item at position nIndex of the array, in place; returns the object itself.
	#
	#   nIndex     the position of the item to replace, from 1
	#   value      the new item
	#   returns    the stzJson itself, so calls chain
	#   note       a position outside the array changes nothing and records "Index out of range"
	#   see        At, Insert
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

	# Returns the content as a Ring list: [ key, value ] pairs for an object, the items for an array.
	#
	#   returns    a list
	#   note       it is the held list itself, so it reads what the other methods changed
	#   see        ToString
	#@ aka  Conversion Methods
	def ToList()
		return @aData

	# Returns a new stzJson built from the text of this one, so changing the copy leaves the original alone.
	#
	#   returns    a stzJson
	#   note       an object and an empty array copy well
	#   warning    Raises error "aList must be a well-formatted JSON list" today when the array is
	#              not empty, because the copy goes through the text and the text cannot be built
	#              for an array; the recorded error is not copied
	#   see        FromString
	def Copy()
		_oCopy_ = new stzJson(This.ToString())
		return _oCopy_

	# Removes every key or item, in place; returns the object itself.
	#
	#   returns    the stzJson itself, so calls chain
	#   note       the object stays an array or an object; an emptied object writes as [ ]; the
	#              recorded error is kept
	#   see        RemoveKey, IsEmpty
	#@ aka  Utility Methods
	def Clear()
		@aData = []
		return This

	# TRUE if no error has been recorded since the object was built or since the last ClearError.
	#
	#   note       misusing a method, for example At on an object, makes it FALSE
	#   see        HasError, LastError, ClearError
	def IsValid()
		return @cLastError = ""

	# Returns the message of the last error recorded, or an empty text when there is none.
	#
	#   returns    a text
	#   note       errors are recorded, never raised: a failed call returns an empty text or leaves
	#              the object unchanged
	#   see        HasError, ClearError
	#@ aka  Error Handling
	def LastError()
		return @cLastError

	# TRUE if an error has been recorded and not cleared.
	#
	#   note       it is the opposite of IsValid
	#   see        LastError, ClearError, IsValid
	def HasError()
		return @cLastError != ""

	# Forgets the recorded error, in place; returns the object itself.
	#
	#   returns    the stzJson itself, so calls chain
	#   see        HasError, LastError
	def ClearError()
		@cLastError = ""
		return This

	# Returns a new stzJson built from the JSON text; the receiver is not changed.
	#
	#   cJson      the JSON text to parse
	#   returns    a stzJson
	#   note       an invalid text gives an empty object with LastError set
	#   see        FromList, EmptyObject
	#@ aka  Static Factory Methods
	def FromString(cJson)
		return new stzJson(cJson)

	# Returns a new stzJson built from the Ring list; the receiver is not changed.
	#
	#   aList      the Ring list to hold, as [ key, value ] pairs or as items
	#   returns    a stzJson
	#   see        FromString, ToList
	def FromList(aList)
		return new stzJson(aList)

	# Returns a new stzJson holding an empty object.
	#
	#   returns    a stzJson
	#   note       it writes as [ ] and IsArray answers FALSE
	#   see        EmptyArray, FromString
	def EmptyObject()
		return new stzJson("{}")

	# Returns a new stzJson holding an empty array.
	#
	#   returns    a stzJson
	#   note       it writes as [ ] and IsArray answers TRUE
	#   see        EmptyObject, FromString
	def EmptyArray()
		return new stzJson("[]")

	# Prints the content to the console as indented JSON.
	#
	#   returns    nothing; the text is printed
	#   note       the indented text of an object uses tabs
	#   warning    Raises error "aList must be a well-formatted JSON list" today for an array that
	#              holds anything, because the serializer cannot write a plain list
	#   see        Print, ToString
	#@ aka  Display
	def Show()
		? This.ToStringXT()

	# Prints the content to the console as JSON on one line.
	#
	#   returns    nothing; the text is printed
	#   warning    Raises error "aList must be a well-formatted JSON list" today for an array that
	#              holds anything, because the serializer cannot write a plain list
	#   see        Show, ToString
	def Print()
		? This.ToString()

	# Private Methods
	private

	def _SetError(cError)
		@cLastError = cError
