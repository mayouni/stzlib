#~~~~~~~~~~~~~~~~~~~~~~~~~~#
#  PROFILING MEMORY SPACE  #
#~~~~~~~~~~~~~~~~~~~~~~~~~~#

func SizeInChars(str)
	if NOT isString(str)
		StzRaise("Incorrect param type! str must be a string.")
	ok

	# Count Unicode codepoints (not bytes) in a UTF-8 string
	_nCount_ = 0
	_nBytes_ = len(str)
	_i_ = 1
	while _i_ <= _nBytes_
		_c_ = ascii(str[_i_])
		if (_c_ & 0x80) = 0        # 1-byte (ASCII)
			_i_++
		but (_c_ & 0xE0) = 0xC0    # 2-byte
			_i_ += 2
		but (_c_ & 0xF0) = 0xE0    # 3-byte
			_i_ += 3
		but (_c_ & 0xF8) = 0xF0    # 4-byte
			_i_ += 4
		else
			_i_++                   # invalid byte, skip
		ok
		_nCount_++
	end
	return _nCount_

	func @SizeInChars(str)
		return SizeInChars(str)


func ContentSizeInBytes(_item_)
	if isList(_item_) and len(_item_) = 2 and isString(_item_[1]) and _item_[1] = :Of
		_item_ = _item_[2]
	ok

	if isNumber(_item_)
		return RING_NUMBER_CONTENT_SIZE

	but isString(_item_)
		return len(_item_)

	but isList(_item_)
		_nResult_ = 0
		_nLen_ = len(_item_)

		for _i_ = 1 to _nLen_
			_nResult_ += ContentSizeInBytes(_item_[_i_])
		next

		return _nResult_

	but isObject(_item_)
		return ContentSizeInBytes( AttributesValues(_item_) )
	ok

	#< @FunctionAlternativeForms

	func ContentSize(_item_)
		return ContentSizeInBytes(_item_)

	func CSize(_item_)
		return ContentSizeInBytes(_item_)

	#--

	func @ContentSizeInBytes(_item_)
		return ContentSizeInBytes(_item_)

	func @ContentSize(_item_)
		return ContentSizeInBytes(_item_)

	func @CSize(_item_)
		return ContentSizeInBytes(_item_)

	#>


#INFO #CREDIT
# This function is made thanks to Mahmoud's explanation of the internal
# memory management mode implemented in Ring (see the Google forum)

func SizeInBytes(p)
	if Is64Bit()
		return SizeInBytes64(p)
	else
		return SizeInBytes32(p)
	ok

	#< @FunctionAlternativeForms

	func @SizeInBytes(p)
		return SizeInBytes(p)

	func NumberOfBytes(p)
		if isList(p) and len(p) = 2 and isString(p[1]) and 
		   (p[1] = :In or p[1] = :Of)

				p = p[2]
		ok

		return SizeInBytes(p)

	func @NumberOfBytes(p)
		return NumberOfBytes(p)

	func CountBytes(p)
		return NumberOfBytes(p)

	func @CountBytes(p)
		return NumberOfBytes(p)

	#--

	func Size(p)
		return SizeInBytes(p)

		func @Size(p)
			return SizeInBytes(p)

	func MSize(p)
		return SizeInBytes(p)

		func @MSize(p)
			return SizeInBytes(p)

	func MemorySize(p)
		return SizeInBytes(p)

		func @MemorySize(p)
			return SizeInBytes(p)

	func MemSize(p)
		return SizeInBytes(p)

		func @MemSize(p)
			return SizeInBytes(p)

	#==

	func MemorySizeInBytes(p)
		return SizeInBytes(p)

	func @MemorySizeInBytes(p)
		return SizeInBytes(p)

	func NumberOfMemoryBytes(p)
		if isList(p) and len(p) = 2 and isString(p[1]) and 
		   (p[1] = :In or p[1] = :Of)
				p = p[2]
		ok

		return SizeInBytes(p)

	func @NumberOfMemoryBytes(p)
		return NumberOfBytes(p)

	func CountMemoryBytes(p)
		return NumberOfBytes(p)

	func @CountMemoryBytes(p)
		return NumberOfBytes(p)

	#==

	func MemSizeInBytes(p)
		return SizeInBytes(p)

	func @MemSizeInBytes(p)
		return SizeInBytes(p)

	func NumberOfMemBytes(p)
		if isList(p) and len(p) = 2 and isString(p[1]) and
		   (p[1] = :In or p[1] = :Of)

				p = p[2]
		ok

		return SizeInBytes(p)

	func @NumberOfMemBytes(p)
		return SizeInBytes(p)

	func CountMemBytes(p)
		return SizeInBytes(p)

	func @CountMemBytes(p)
		return SizeInBytes(p)

	#>

func SizeInBytesXT(_item_)
	if Is64Bit()
		return SizeInBytes64XT(_item_)
	else
		return SizeInBytes32XT(_item_)
	ok

	#< @FunctionAlternativeForms

	func @SizeInBytesXT(p)
		return SizeInBytesXT(p)

	func NumberOfBytesXT(p)
		if isList(p) and len(p) = 2 and isString(p[1]) and
		   (p[1] = :In or p[1] = :Of)

				p = p[2]
		ok

		return SizeInBytesXT(p)

	func @NumberOfBytesXT(p)
		return NumberOfBytesXT(p)

	func CountBytesXT(p)
		return NumberOfBytesXT(p)

	func @CountBytesXT(p)
		return NumberOfBytesXT(p)

	#--

	func SizeXT(p)
		return SizeInBytesXT(p)

		func @SizeXT(p)
			return SizeInBytesXT(p)

	func MSizeXT(p)
		return SizeInBytesXT(p)

		func @MSizeXT(p)
			return SizeInBytesXT(n)

	func MemorySizeXT(p)
		return SizeInBytesXT(p)

		func @MemorySizeXT(p)
			return SizeInBytesXT(p)

	func MemSizeXT(p)
		return SizeInBytesXT(p)

		func @MemSizeXT(p)
			return SizeInBytesXT(p)

	#==

	func MemorySizeInBytesXT(p)
		return SizeInBytesXT(p)

	func @MemorySizeInBytesXT(p)
		return SizeInBytesXT(p)

	func NumberOfMemoryBytesXT(p)
		if isList(p) and len(p) = 2 and isString(p[1]) and 
		   (p[1] = :In or p[1] = :Of)
				p = p[2]
		ok

		return SizeInBytesXT(p)

	func @NumberOfMemoryBytesXT(p)
		return NumberOfBytesXT(p)

	func CountMemoryBytesXT(p)
		return NumberOfBytesXT(p)

	func @CountMemoryBytesXT(p)
		return NumberOfBytesXT(p)

	#==

	func MemSizeInBytesXT(p)
		return SizeInBytesXT(p)

	func @MemSizeInBytesXT(p)
		return SizeInBytesXT(p)

	func NumberOfMemBytesXT(p)
		if isList(p) and len(p) = 2 and isString(p[1]) and 
		   (p[1] = :In or p[1] = :Of)
				p = p[2]
		ok

		return SizeInBytesXT(p)

	func @NumberOfMemBytesXT(p)
		return SizeInBytesXT(p)

	func CountMemBytesXT(p)
		return SizeInBytesXT(p)

	func @CountMemBytesXT(p)
		return SizeInBytesXT(p)

	#>
