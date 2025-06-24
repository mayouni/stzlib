#---- Memory profiling functions for 32BIT architecture

func SizeInBytes32(item)
	if isList(item) and len(item) = 2 and isString(item[1]) and item[1] = :Of
		item = item[2]
	ok
    
	switch type(item)
	on "NUMBER"
		return RING_NUMBER_CONTENT_SIZE

        on "STRING"
		nContentSize = len(item)
		if nContentSize <= RING_STRING_ARRAYSIZE
			return nContentSize + RING_STRING_ARRAYSIZE
		else
			return nContentSize + RING_32BIT_STRING_STRUCTURE_SIZE
		ok

	on "LIST"
		nListAdditionalSize      = RING_32BIT_LIST_STRUCTURE_SIZE
		nItemTotalAdditionalSize = RING_32BIT_ITEM_STRUCTURE_SIZE + RING_32BIT_ITEMS_STRUCTURE_SIZE

		nLen = len(item)
		nResult = nListAdditionalSize + (nLen * nItemTotalAdditionalSize)
		
		nNum = 0

		for i = 1 to nLen
			if isNumber(item[i])
				nNum++ 
			else
				nResult += ContentSizeInBytes(item[i])
			ok
		next

		nResult += RING_NUMBER_CONTENT_SIZE * nNum
		return nResult

        on "OBJECT"
		return SizeInBytes32(AttributesValues(item))

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

func SizeInBytes32XT(item)
    	aResult = []

	switch type(item)
	on "NUMBER"
		return [ "RING_NUMBER_CONTENT_SIZE", RING_NUMBER_CONTENT_SIZE ]

        on "STRING"
		nContentSize = len(item)

		if nContentSize <= RING_STRING_ARRAYSIZE
			aResult + [ "RING_STRING_ARRAYSIZE", RING_STRING_ARRAYSIZE ]
			aResult + [ "RING_STRING_CONTENT_SIZE", nContentSize ]
	
		else
			aResult + [ "RING_32BIT_STRING_STRUCTURE_SIZE", RING_32BIT_STRING_STRUCTURE_SIZE ]
			aResult + [ "RING_STRING_CONTENT_SIZE", nContentSize ]
		ok

		return aResult

	on "LIST"
		nLen = len(item)

		aResult + [ "RING_32BIT_LIST_STRUCTURE_SIZE", RING_32BIT_LIST_STRUCTURE_SIZE ]
		aResult + [ "RING_32BIT_ITEM_STRUCTURE_SIZE * " + nLen, RING_32BIT_ITEM_STRUCTURE_SIZE * nLen ]
		aResult + [ "RING_32BIT_ITEMS_STRUCTURE_SIZE * " + nLen, RING_32BIT_ITEMS_STRUCTURE_SIZE * nLen ]
		aResult + [ "RING_32BIT_ITEMS_CONTENT_SIZE", ContentSize(item) ]

		return aResult

        on "OBJECT"
		 return SizeInBytes32XT(AttributesValues(item))		
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
