func SizeInBytes64(item)
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
			return nContentSize + RING_64BIT_STRING_STRUCTURE_SIZE
		ok

	on "LIST"
		nListAdditionalSize      = RING_64BIT_LIST_STRUCTURE_SIZE
		nItemTotalAdditionalSize = RING_64BIT_ITEM_STRUCTURE_SIZE + RING_64BIT_ITEMS_STRUCTURE_SIZE

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
		return SizeInBytes64(AttributesValues(item))

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

func SizeInBytes64XT(item)
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
			aResult + [ "RING_64BIT_STRING_STRUCTURE_SIZE", RING_64BIT_STRING_STRUCTURE_SIZE ]
			aResult + [ "RING_STRING_CONTENT_SIZE", nContentSize ]
		ok

		return aResult
	on "LIST"
		nLen = len(item)

		aResult + [ "RING_64BIT_LIST_STRUCTURE_SIZE", RING_64BIT_LIST_STRUCTURE_SIZE ]
		aResult + [ "RING_64BIT_ITEM_STRUCTURE_SIZE * " + nLen, RING_64BIT_ITEM_STRUCTURE_SIZE * nLen ]
		aResult + [ "RING_64BIT_ITEMS_STRUCTURE_SIZE * " + nLen, RING_64BIT_ITEMS_STRUCTURE_SIZE * nLen ]
		aResult + [ "RING_64BIT_ITEMS_CONTENT_SIZE", ContentSize(item) ]

		return aResult

        on "OBJECT"
		 return SizeInBytes64XT(AttributesValues(item))		
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

	acChars = U(pacChars)
	nLen = len(acChars)

	aResult = []

	for i = 1 to nLen
		aResult + [ acChars[i], SizeInBytes(acChars[i]) ]
	next

	return aResult

func SizeInBytesPerChar32(pacChars)
	if ChekcParams()
		if NOT (isList and IsListOfChars(pacChars))
			StzRaise("Incorrect param type! pacChars must be a list of chars.")
		ok
	ok

	acChars = U(pacChars)
	nLen = len(acChars)

	aResult = []

	for i = 1 to nLen
		aResult + [ acChars[i], SizeInBytes32(acChars[i]) ]
	next

	return aResult

func SizeInBytesPerChar64(pacChars)
	if ChekcParams()
		if NOT (isList and IsListOfChars(pacChars))
			StzRaise("Incorrect param type! pacChars must be a list of chars.")
		ok
	ok

	acChars = U(pacChars)
	nLen = len(acChars)

	aResult = []

	for i = 1 to nLen
		aResult + [ acChars[i], SizeInBytes64(acChars[i]) ]
	next

	return aResult

func SizeInBytesPerCharXT(pacChars)
	if ChekcParams()
		if NOT (isList and IsListOfChars(pacChars))
			StzRaise("Incorrect param type! pacChars must be a list of chars.")
		ok
	ok

	acChars = U(pacChars)
	nLen = len(acChars)

	aResult = []

	for i = 1 to nLen
		aResult + [ acChars[i], SizeInBytesXT(acChars[i]) ]
	next

	return aResult

func SizeInBytesPerChar32XT(pacChars)
	if ChekcParams()
		if NOT (isList and IsListOfChars(pacChars))
			StzRaise("Incorrect param type! pacChars must be a list of chars.")
		ok
	ok

	acChars = U(pacChars)
	nLen = len(acChars)

	aResult = []

	for i = 1 to nLen
		aResult + [ acChars[i], SizeInBytes32XT(acChars[i]) ]
	next

	return aResult

func SizeInBytesPerChar64XT(pacChars)
	if ChekcParams()
		if NOT (isList and IsListOfChars(pacChars))
			StzRaise("Incorrect param type! pacChars must be a list of chars.")
		ok
	ok

	acChars = U(pacChars)
	nLen = len(acChars)

	aResult = []

	for i = 1 to nLen
		aResult + [ acChars[i], SizeInBytes64XT(acChars[i]) ]
	next

	return aResult
