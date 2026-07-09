#---- Memory profiling functions for 32BIT architecture

func SizeInBytes32(_item_)
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
			return _nContentSize_ + RING_32BIT_STRING_STRUCTURE_SIZE
		ok

	on "LIST"
		_nListAdditionalSize_      = RING_32BIT_LIST_STRUCTURE_SIZE
		_nItemTotalAdditionalSize_ = RING_32BIT_ITEM_STRUCTURE_SIZE + RING_32BIT_ITEMS_STRUCTURE_SIZE

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
		return SizeInBytes32(AttributesValues(_item_))

	off

	#< @FunctionAlternativeForms

	func @SizeInBytes32(p)
		return SizeInBytes32(p)

	func NumberOfBytes32(p)
		if isList(p) and len(p) = 2 and isString(p[1]) and 
		   (p[1] = :In or p[1] = :Of)

				p = p[2]
		ok

		return SizeInBytes32(p)

	func @NumberOfBytes32(p)
		return NumberOfBytes32(p)

	func CountBytes32(p)
		return NumberOfBytes32(p)

	func @CountBytes32(p)
		return NumberOfBytes32(p)

	#--

	func Size32(p)
		return SizeInBytes32(p)

		func @Size32(p)
			return SizeInBytes32(p)

	func MSize32(p)
		return SizeInBytes32(p)

		func @MSize32(p)
			return SizeInBytes32(n)

	func MemorySize32(p)
		return SizeInBytes32(p)

		func @MemorySize32(p)
			return SizeInBytes32(p)

	func MemSize32(p)
		return SizeInBytes32(p)

		func @MemSize32(p)
			return SizeInBytes32(p)

	#==

	func MemorySizeInBytes32(p)
		return SizeInBytes32(p)

	func @MemorySizeInBytes32(p)
		return SizeInBytes32(p)

	func NumberOfMemoryBytes32(p)
		if isList(p) and len(p) = 2 and isString(p[1]) and 
		   (p[1] = :In or p[1] = :Of)
				p = p[2]
		ok

		return SizeInBytes32(p)

	func @NumberOfMemoryBytes32(p)
		return NumberOfBytes32(p)

	func CountMemoryBytes32(p)
		return NumberOfBytes32(p)

	func @CountMemoryBytes32(p)
		return NumberOfBytes32(p)

	#==

	func MemSizeInBytes32(p)
		return SizeInBytes32(p)

	func @MemSizeInBytes32(p)
		return SizeInBytes32(p)

	func NumberOfMemBytes32(p)
		if isList(p) and len(p) = 2 and isString(p[1]) and
		   (p[1] = :In or p[1] = :Of)

				p = p[2]
		ok

		return SizeInBytes32(p)

	func @NumberOfMemBytes32(p)
		return SizeInBytes32(p)

	func CountMemBytes32(p)
		return SizeInBytes32(p)

	func @CountMemBytes32(p)
		return SizeInBytes32(p)

	#>

func SizeInBytes32XT(_item_)
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
			_aResult_ + [ "RING_32BIT_STRING_STRUCTURE_SIZE", RING_32BIT_STRING_STRUCTURE_SIZE ]
			_aResult_ + [ "RING_STRING_CONTENT_SIZE", _nContentSize_ ]
		ok

		return _aResult_

	on "LIST"
		_nLen_ = len(_item_)

		_aResult_ + [ "RING_32BIT_LIST_STRUCTURE_SIZE", RING_32BIT_LIST_STRUCTURE_SIZE ]
		_aResult_ + [ "RING_32BIT_ITEM_STRUCTURE_SIZE * " + _nLen_, RING_32BIT_ITEM_STRUCTURE_SIZE * _nLen_ ]
		_aResult_ + [ "RING_32BIT_ITEMS_STRUCTURE_SIZE * " + _nLen_, RING_32BIT_ITEMS_STRUCTURE_SIZE * _nLen_ ]
		_aResult_ + [ "RING_32BIT_ITEMS_CONTENT_SIZE", ContentSize(_item_) ]

		return _aResult_

        on "OBJECT"
		 return SizeInBytes32XT(AttributesValues(_item_))		
	off

	#< @FunctionAlternativeForms

	func @SizeInBytes32XT(p)
		return SizeInBytes32XT(p)

	func NumberOfBytes32XT(p)
		if isList(p) and len(p) = 2 and isString(p[1]) and
		   (p[1] = :In or p[1] = :Of)

				p = p[2]
		ok

		return SizeInBytes32XT(p)

	func @NumberOfBytes32XT(p)
		return NumberOfBytes32XT(p)

	func CountBytes32XT(p)
		return NumberOfBytes32XT(p)

	func @CountBytes32XT(p)
		return NumberOfBytes32XT(p)

	#--

	func Size32XT(p)
		return SizeInBytes32XT(p)

		func @Size32XT(p)
			return SizeInBytes32XT(p)

	func MSize32XT(p)
		return SizeInBytes32XT(p)

		func @MSize32XT(p)
			return SizeInBytes32XT(n)

	func MemorySize32XT(p)
		return SizeInBytes32XT(p)

		func @MemorySize32XT(p)
			return SizeInBytes32XT(p)

	func MemSize32XT(p)
		return SizeInBytes32XT(p)

		func @MemSize32XT(p)
			return SizeInBytes32XT(p)

	#==

	func MemorySizeInBytes32XT(p)
		return SizeInBytes32XT(p)

	func @MemorySizeInBytes32XT(p)
		return SizeInBytes32XT(p)

	func NumberOfMemoryBytes32XT(p)
		if isList(p) and len(p) = 2 and isString(p[1]) and 
		   (p[1] = :In or p[1] = :Of)
				p = p[2]
		ok

		return SizeInBytes32XT(p)

	func @NumberOfMemoryBytes32XT(p)
		return NumberOfBytes32XT(p)

	func CountMemoryBytes32XT(p)
		return NumberOfBytes32XT(p)

	func @CountMemoryBytes32XT(p)
		return NumberOfBytes32XT(p)

	#==

	func MemSizeInBytes32XT(p)
		return SizeInBytes32XT(p)

	func @MemSizeInBytes32XT(p)
		return SizeInBytes32XT(p)

	func NumberOfMemBytes32XT(p)
		if isList(p) and len(p) = 2 and isString(p[1]) and 
		   (p[1] = :In or p[1] = :Of)
				p = p[2]
		ok

		return SizeInBytes32XT(p)

	func @NumberOfMemBytes32XT(p)
		return SizeInBytes32XT(p)

	func CountMemBytes32XT(p)
		return SizeInBytes32XT(p)

	func @CountMemBytes32XT(p)
		return SizeInBytes32XT(p)

	#>
