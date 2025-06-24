#~~~~~~~~~~~~~~~~~~~~~~~~~~#
#  PROFILING MEMORY SPACE  #
#~~~~~~~~~~~~~~~~~~~~~~~~~~#

func SizeInChars(str)
	if NOT isString(str)
		StzRaise("Incorrect param type! str must be a string.")
	ok

	oQString = new QString2()
	oQString.append(str)

	return oQString.size()

	func @SizeInChars(str)
		return SizeInChars(str)


func ContentSizeInBytes(item)
	if isList(item) and len(item) = 2 and isString(item[1]) and item[1] = :Of
		item = item[2]
	ok

	if isNumber(item)
		return RING_NUMBER_CONTENT_SIZE

	but isString(item)
		return len(item)

	but isList(item)
		nResult = 0
		nLen = len(item)

		for i = 1 to nLen
			nResult += ContentSizeInBytes(item[i])
		next

		return nResult

	but isObject(item)
		return ContentSizeInBytes( AttributesValues(item) )
	ok

	#< @FunctionAlternativeForms

	func ContentSize(item)
		return ContentSizeInBytes(item)

	func CSize(item)
		return ContentSizeInBytes(item)

	#--

	func @ContentSizeInBytes(item)
		return ContentSizeInBytes(item)

	func @ContentSize(item)
		return ContentSizeInBytes(item)

	func @CSize(item)
		return ContentSizeInBytes(item)

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

func SizeInBytesXT(item)
	if Is64Bit()
		return SizeInBytes64XT(item)
	else
		return SizeInBytes32XT(item)
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
