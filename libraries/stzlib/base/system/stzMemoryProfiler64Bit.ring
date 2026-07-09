func SizeInBytes64(_item_)
	if isList(_item_) and len(_item_) = 2 and isString(_item_[1]) and _item_[1] = :Of
		_item_ = _item_[2]
	ok
    
	switch type(_item_)
	on "NUMBER"
		return RING_NUMBER_CONTENT_SIZE

        on "STRING"
		_nContentSize_ = len(_item_)
		if _nContentSize_ <= RING_STRING_ARRAYSIZE
			return _nContentSize_ + RING_STRING_ARRAYSIZE
		else
			return _nContentSize_ + RING_64BIT_STRING_STRUCTURE_SIZE
		ok

	on "LIST"
		_nListAdditionalSize_      = RING_64BIT_LIST_STRUCTURE_SIZE
		_nItemTotalAdditionalSize_ = RING_64BIT_ITEM_STRUCTURE_SIZE + RING_64BIT_ITEMS_STRUCTURE_SIZE

		_nLen_ = len(_item_)
		_nResult_ = _nListAdditionalSize_ + (_nLen_ * _nItemTotalAdditionalSize_)
		
		_nNum_ = 0

		for i = 1 to _nLen_
			if isNumber(_item_[i])
				_nNum_++ 
			else
				_nResult_ += ContentSizeInBytes(_item_[i])
			ok
		next

		_nResult_ += RING_NUMBER_CONTENT_SIZE * _nNum_

		return _nResult_

        on "OBJECT"
		return SizeInBytes64(AttributesValues(_item_))

	off

	#< @FunctionAlternativeForms

	func @SizeInBytes64(p)
		return SizeInBytes64(p)

	func NumberOfBytes64(p)
		if isList(p) and len(p) = 2 and isString(p[1]) and 
		   (p[1] = :In or p[1] = :Of)

				p = p[2]
		ok

		return SizeInBytes64(p)

	func @NumberOfBytes64(p)
		return NumberOfBytes64(p)

	func CountBytes64(p)
		return NumberOfBytes64(p)

	func @CountBytes64(p)
		return NumberOfBytes64(p)

	#--

	func Size64(p)
		return SizeInBytes64(p)

		func @Size64(p)
			return SizeInBytes64(p)

	func MSize64(p)
		return SizeInBytes64(p)

		func @MSize64(p)
			return SizeInBytes64(n)

	func MemorySize64(p)
		return SizeInBytes64(p)

		func @MemorySize64(p)
			return SizeInBytes64(p)

	func MemSize64(p)
		return SizeInBytes64(p)

		func @MemSize64(p)
			return SizeInBytes64(p)

	#==

	func MemorySizeInBytes64(p)
		return SizeInBytes64(p)

	func @MemorySizeInBytes64(p)
		return SizeInBytes64(p)

	func NumberOfMemoryBytes64(p)
		if isList(p) and len(p) = 2 and isString(p[1]) and 
		   (p[1] = :In or p[1] = :Of)
				p = p[2]
		ok

		return SizeInBytes64(p)

	func @NumberOfMemoryBytes64(p)
		return NumberOfBytes64(p)

	func CountMemoryBytes64(p)
		return NumberOfBytes64(p)

	func @CountMemoryBytes64(p)
		return NumberOfBytes64(p)

	#==

	func MemSizeInBytes64(p)
		return SizeInBytes64(p)

	func @MemSizeInBytes64(p)
		return SizeInBytes64(p)

	func NumberOfMemBytes64(p)
		if isList(p) and len(p) = 2 and isString(p[1]) and
		   (p[1] = :In or p[1] = :Of)

				p = p[2]
		ok

		return SizeInBytes64(p)

	func @NumberOfMemBytes64(p)
		return SizeInBytes64(p)

	func CountMemBytes64(p)
		return SizeInBytes64(p)

	func @CountMemBytes64(p)
		return SizeInBytes64(p)

	#>

func SizeInBytes64XT(_item_)
    	_aResult_ = []

	switch type(_item_)
	on "NUMBER"
		return [ "RING_NUMBER_CONTENT_SIZE", RING_NUMBER_CONTENT_SIZE ]

        on "STRING"
		_nContentSize_ = len(_item_)

		if _nContentSize_ <= RING_STRING_ARRAYSIZE
			_aResult_ + [ "RING_STRING_ARRAYSIZE", RING_STRING_ARRAYSIZE ]
			_aResult_ + [ "RING_STRING_CONTENT_SIZE", _nContentSize_ ]
	
		else
			_aResult_ + [ "RING_64BIT_STRING_STRUCTURE_SIZE", RING_64BIT_STRING_STRUCTURE_SIZE ]
			_aResult_ + [ "RING_STRING_CONTENT_SIZE", _nContentSize_ ]
		ok

		return _aResult_
	on "LIST"
		_nLen_ = len(_item_)

		_aResult_ + [ "RING_64BIT_LIST_STRUCTURE_SIZE", RING_64BIT_LIST_STRUCTURE_SIZE ]
		_aResult_ + [ "RING_64BIT_ITEM_STRUCTURE_SIZE * " + _nLen_, RING_64BIT_ITEM_STRUCTURE_SIZE * _nLen_ ]
		_aResult_ + [ "RING_64BIT_ITEMS_STRUCTURE_SIZE * " + _nLen_, RING_64BIT_ITEMS_STRUCTURE_SIZE * _nLen_ ]
		_aResult_ + [ "RING_64BIT_ITEMS_CONTENT_SIZE", ContentSize(_item_) ]

		return _aResult_

        on "OBJECT"
		 return SizeInBytes64XT(AttributesValues(_item_))		
	off

	#< @FunctionAlternativeForms

	func @SizeInBytes64XT(p)
		return SizeInBytes64XT(p)

	func NumberOfBytes64XT(p)
		if isList(p) and len(p) = 2 and isString(p[1]) and
		   (p[1] = :In or p[1] = :Of)

				p = p[2]
		ok

		return SizeInBytes64XT(p)

	func @NumberOfBytes64XT(p)
		return NumberOfBytes64XT(p)

	func CountBytes64XT(p)
		return NumberOfBytes64XT(p)

	func @CountBytes64XT(p)
		return NumberOfBytes64XT(p)

	#--

	func Size64XT(p)
		return SizeInBytes64XT(p)

		func @Size64XT(p)
			return SizeInBytes64XT(p)

	func MSize64XT(p)
		return SizeInBytes64XT(p)

		func @MSize64XT(p)
			return SizeInBytes64XT(n)

	func MemorySize64XT(p)
		return SizeInBytes64XT(p)

		func @MemorySize64XT(p)
			return SizeInBytes64XT(p)

	func MemSize64XT(p)
		return SizeInBytes64XT(p)

		func @MemSize64XT(p)
			return SizeInBytes64XT(p)

	#==

	func MemorySizeInBytes64XT(p)
		return SizeInBytes64XT(p)

	func @MemorySizeInBytes64XT(p)
		return SizeInBytes64XT(p)

	func NumberOfMemoryBytes64XT(p)
		if isList(p) and len(p) = 2 and isString(p[1]) and 
		   (p[1] = :In or p[1] = :Of)
				p = p[2]
		ok

		return SizeInBytes64XT(p)

	func @NumberOfMemoryBytes64XT(p)
		return NumberOfBytes64XT(p)

	func CountMemoryBytes64XT(p)
		return NumberOfBytes64XT(p)

	func @CountMemoryBytes64XT(p)
		return NumberOfBytes64XT(p)

	#==

	func MemSizeInBytes64XT(p)
		return SizeInBytes64XT(p)

	func @MemSizeInBytes64XT(p)
		return SizeInBytes64XT(p)

	func NumberOfMemBytes64XT(p)
		if isList(p) and len(p) = 2 and isString(p[1]) and 
		   (p[1] = :In or p[1] = :Of)
				p = p[2]
		ok

		return SizeInBytes64XT(p)

	func @NumberOfMemBytes64XT(p)
		return SizeInBytes64XT(p)

	func CountMemBytes64XT(p)
		return SizeInBytes64XT(p)

	func @CountMemBytes64XT(p)
		return SizeInBytes64XT(p)

	#>

#----

func SizeInBytesPerChar(pacChars)
	if ChekcParams()
		if NOT (isList and IsListOfChars(pacChars))
			StzRaise("Incorrect param type! pacChars must be a list of chars.")
		ok
	ok

	_acChars_ = U(pacChars)
	_nLen_ = len(_acChars_)

	_aResult_ = []

	for i = 1 to _nLen_
		_aResult_ + [ _acChars_[i], SizeInBytes(_acChars_[i]) ]
	next

	return _aResult_

func SizeInBytesPerChar32(pacChars)
	if ChekcParams()
		if NOT (isList and IsListOfChars(pacChars))
			StzRaise("Incorrect param type! pacChars must be a list of chars.")
		ok
	ok

	_acChars_ = U(pacChars)
	_nLen_ = len(_acChars_)

	_aResult_ = []

	for i = 1 to _nLen_
		_aResult_ + [ _acChars_[i], SizeInBytes32(_acChars_[i]) ]
	next

	return _aResult_

func SizeInBytesPerChar64(pacChars)
	if ChekcParams()
		if NOT (isList and IsListOfChars(pacChars))
			StzRaise("Incorrect param type! pacChars must be a list of chars.")
		ok
	ok

	_acChars_ = U(pacChars)
	_nLen_ = len(_acChars_)

	_aResult_ = []

	for i = 1 to _nLen_
		_aResult_ + [ _acChars_[i], SizeInBytes64(_acChars_[i]) ]
	next

	return _aResult_

func SizeInBytesPerCharXT(pacChars)
	if ChekcParams()
		if NOT (isList and IsListOfChars(pacChars))
			StzRaise("Incorrect param type! pacChars must be a list of chars.")
		ok
	ok

	_acChars_ = U(pacChars)
	_nLen_ = len(_acChars_)

	_aResult_ = []

	for i = 1 to _nLen_
		_aResult_ + [ _acChars_[i], SizeInBytesXT(_acChars_[i]) ]
	next

	return _aResult_

func SizeInBytesPerChar32XT(pacChars)
	if ChekcParams()
		if NOT (isList and IsListOfChars(pacChars))
			StzRaise("Incorrect param type! pacChars must be a list of chars.")
		ok
	ok

	_acChars_ = U(pacChars)
	_nLen_ = len(_acChars_)

	_aResult_ = []

	for i = 1 to _nLen_
		_aResult_ + [ _acChars_[i], SizeInBytes32XT(_acChars_[i]) ]
	next

	return _aResult_

func SizeInBytesPerChar64XT(pacChars)
	if ChekcParams()
		if NOT (isList and IsListOfChars(pacChars))
			StzRaise("Incorrect param type! pacChars must be a list of chars.")
		ok
	ok

	_acChars_ = U(pacChars)
	_nLen_ = len(_acChars_)

	_aResult_ = []

	for i = 1 to _nLen_
		_aResult_ + [ _acChars_[i], SizeInBytes64XT(_acChars_[i]) ]
	next

	return _aResult_
