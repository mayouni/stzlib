
#~~~~~~~~~~~~~~~~~~~~#
#  GLOBAL CONSTANTS  #
#~~~~~~~~~~~~~~~~~~~~#

# Used by StartProfiler() and StopProfiler() functions
_time0 = 0

# Factors used for converting between memory units

MEMORY_UNITS = [
	:Bit,
	:Byte,
	:KiloByte,
	:MegaByte,
	:GigaByte,
	:TeraByte,
	:PetaByte,
	:ExaByte,
	:ZettaByte,
	:YottaByte
]

# CONVERSION FACTORS BETWEEN MEMORY UNITS

KILOBYTE_TO_BIT_FACTOR  = 8192 # 1024 * 8

MEGABYTE_TO_KILOBYTE_FACTOR = 1024 		# 1024
MEGABYTE_TO_BIT_FACTOR      = 8388608 		# (1024 ^ 2) * 8

GIGABYTE_TO_BYTE_FACTOR     = 1073741824 	# (1024 ^ 3)
GIGABYTE_TO_KILOBYTE_FACTOR = 1048576 		# (1024 ^ 2)
GIGABYTE_TO_BIT_FACTOR      = 8589934592 	# (1024 ^ 3) * 8

TERABYTE_TO_BYTE_FACTOR     = 1099511627776 	# (1024 ^ 4)
TERABYTE_TO_KILOBYTE_FACTOR = 1073741824 	# (1024 ^ 3)
TERABYTE_TO_BIT_FACTOR      = 8796093022208 	# (1024 ^ 4) * 8

PETABYTE_TO_BYTE_FACTOR     	= 1125899906842624 	# (1024 ^ 5)
PETABYTE_TO_KILOBYTE_FACTOR 	= 1099511627776 	# (1024 ^ 4)
PETABYTE_TO_BIT_FACTOR      	= 8881784197001216 	# (1024 ^ 5) * 8

EXABYTE_TO_BYTE_FACTOR     	= 1152921504606846976 	# (1024 ^ 6)
EXABYTE_TO_KILOBYTE_FACTOR 	= 1125899906842624 	# (1024 ^ 5)
EXABYTE_TO_BIT_FACTOR      	= 9223372036854775808 	# (1024 ^ 6) * 8

ZETTABYTE_TO_BYTE_FACTOR     	= 1180591620717411303424 	# (1024 ^ 7)
ZETTABYTE_TO_KILOBYTE_FACTOR 	= 1152921504606846976 		# (1024 ^ 6)
ZETTABYTE_TO_BIT_FACTOR      	= 9444732965739290426368 	# (1024 ^ 7) * 8

YOTTABYTE_TO_BYTE_FACTOR      	= 1208925819614629174706176 	# (1024 ^ 8)
YOTTABYTE_TO_KILOBYTE_FACTOR  	= 1180591620717411303424 	# (1024 ^ 7)
YOTTABYTE_TO_BIT_FACTOR       	= 95428956661160094070998016 	# (1024 ^ 8) * 8

# Global constants for 32-bit architecture
RING_32BIT_STRING_STRUCTURE_SIZE = 40
RING_32BIT_LIST_STRUCTURE_SIZE = 48
RING_32BIT_ITEM_STRUCTURE_SIZE = 16
RING_32BIT_ITEMS_STRUCTURE_SIZE = 16

# Global constants for 64-bit architecture
RING_64BIT_STRING_STRUCTURE_SIZE = 48
RING_64BIT_LIST_STRUCTURE_SIZE = 80
RING_64BIT_ITEM_STRUCTURE_SIZE = 24
RING_64BIT_ITEMS_STRUCTURE_SIZE = 32

RING_NUMBER_CONTENT_SIZE = 3

RING_STRING_ARRAYSIZE = 32

#~~~~~~~~~~~~~~~~~~#
#  PROFILING TIME  #
#~~~~~~~~~~~~~~~~~~#

func StartTimer()
	_time0 = clock()

func ResetTimer()
	_time0 = clock()

	func ResetProfiler()
		_time0 = clock()

func ElapsedTime()
	return ElapsedTimeXT(:In = :Seconds)

	func ElpasedTime()
		return ElapsedTime()
		#NOTE
		# This function name alternative contains a spelling error.
		# Despite that, I'll take it. Because I always make this
		#ERRor and don't want to be blocked for that.

func ElapsedTimeXT(pIn)

	if isList(pIn) and Q(pIn).IsInNamedParam()
		pIn = pIn[2]
	ok

	if NOT isString(pIn)
		StzRaise("Incorrect param type! pIn must be a string.")
	ok

	if NOT ring_find([ :Clocks, :Seconds, :Minutes, :Hours ], pIn)
		#TODO // Future: Add days, weeks, months, years...

		StzRaise("Incorrect value of pIn param! Allowed values are: " +
		":Clocks, :Seconds, :Minutes and :Hours.")
	ok

	switch pIn
	on :Clocks
		return clock() - _time0 + " clocks"

	on :Seconds
		nTime = ( clock() - _time0 ) / clockspersecond()
		cTime = "" + nTime
		return cTime + " second(s)"

	on :Minutes
		nTime = ( clock() - _time0 ) / clockspersecond() / 60
		cTime = "" + nTime
		return cTime + " minute(s)"

	on :Hours
		nTime = ( clock() - _time0 ) / clockspersecond() / 3600
		cTime = "" + nTime
		return cTime + " hour(s)"

	off
	
	func ElpasedTimeXT(pIn)
		return ElapsedTimeXT(pIn)

func Pron()
	_time0 = clock()

	func Profon()
		_time0 = clock()

	func StartProfiler()
		_time0 = clock()

	func ProfilerOn()
		_time0 = clock()

func Proff()

	cElapsed = "" + (clock() - _time0) / clockspersecond()
	if 0+ cElapsed = 0 
		cElapsed = "almost 0"
	ok

	? NL + "Executed in " + cElapsed + " second(s) in Ring " + ring_version()
	_time0 = 0
	STOP()

	func EndProfiler()
		Proff()

	func Profoff()
		Proff()

	func StopProfiler()
		Proff()

	func ProfilerOff()
		Proff()

func STOP()
	raise( NL + 
	    "----------------" + NL +
	    "    STOPPED!    " + NL +
	    "----------------"
	)

#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~#
#  CONVERTING BETWEEN BYTES, KILOBYTES, MEGABYTES, AND GIGABYTES  #
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~#

func MemoryUnits()
	return MEMORY_UNITS

#==

func BytesToBits(n)
	return n * BYTE_TO_BIT_FACTOR

	func BitsToBytes(n)
		return n / BYTE_TO_BIT_FACTOR

#--

func KiloBytesToBytes(n)
	return n * KILOBYTE_TO_BYTE_FACTOR

	func BytesToKiloBytes(n)
		return n / KILOBYTE_TO_BYTE_FACTOR

func KiloBytesToBits(n)
	return n * KILOBYTE_TO_BIT_FACTOR

	func BitsToKiloBytes(n)
		return n / KILOBYTE_TO_BIT_FACTOR

#--

func MegaBytesToKiloBytes(n)
	return n * MEGABYTE_TO_KILOBYTE_FACTOR

	func KiloBytesToMegaBytes()
		return  n / MEGABYTE_TO_KILOBYTE_FACTOR

func MegaBytesToBytes(n)
	return n * MEGABYTE_TO_BYTE_FACTOR

	func BytesToMegaBytes(n)
		return n / MEGABYTE_TO_BYTE_FACTOR

func MegaBytesToBits(n)
	return n * MEGABYTE_TO_BIT_FACTOR

	func BitsToMegaBytes(n)
		return n / MEGABYTE_TO_BIT_FACTOR

#--

func GigaBytesToMegaBytes(n)
	return n * GIGABYTE_TO_MEGABYTE_FACTOR

	func MegaBytesToGigaBytes(n)
		return n / GIGABYTE_TO_MEGABYTE_FACTOR

func GigaBytesToKiloBytes(n)
	return n * GIGABYTE_TO_KILOBYTE_FACTOR

	func KiloBytesToGigaBytes(n)
		return n / GIGABYTE_TO_KILOBYTE_FACTOR

func GigaBytesToBytes(n)
	return n * GIGABYTE_TO_BYTE_FACTOR

	func BytesToGigaBytes(n)
		return n / GIGABYTE_TO_BYTE_FACTOR

func GigaBytesToBits(n)
	return n * GIGABYTE_TO_BIT_FACTOR

	func BitsToGigaBytes(n)
		return n / GIGABYTE_TO_BIT_FACTOR

#--

func TeraBytesToGigaBytes(n)
	return n * TERABYTE_TO_GIGABYTE

	func GigaBytesToTeraBytes(n)
		return n / TERABYTE_TO_GIGABYTE

func TeraBytesToMegaBytes(n)
	return n * TERABYTE_TO_MEGABYTE_FACTOR

	func MegaBytesToTeraBytes(n)
		return n / TERABYTE_TO_MEGABYTE_FACTOR

func TeraBytesToKiloBytes(n)
	return n * TERABYTE_TO_KILOBYTE_FACTOR

	func KiloBytesToTeraBytes(n)
		return n / TERABYTE_TO_KILOBYTE_FACTOR

func TeraBytesToBytes(n)
	return n * TERABYTE_TO_BYTE_FACTOR

	func BytesToTeraBytes(n)
		return n / TERABYTE_TO_BYTE_FACTOR

func TeraBytesToBits(n)
	return n * TERABYTE_TO_BIT_FACTOR

	func BitsToTeraBytes(n)
		return n / TERABYTE_TO_BIT_FACTOR

#--

func PetaBytesToTeraBytes(n)
	return n * PETABYTE_TO_TERABYTE_FACTOR

	func TeraBytesToPetaBytes(n)
		return n / PETABYTE_TO_TERABYTE_FACTOR

func PetaBytesToGigaBytes(n)
	return n * PETABYTE_TO_GIGABYTE_FACTOR

	func GigaBytesToPetaBytes(n)
		return n / PETABYTE_TO_GIGABYTE_FACTOR

func PetaBytesToMegaBytes(n)
	return n * PETABYTE_TO_MEGABYTE_FACTOR

	func MegaBytesToPetaBytes(n)
		return n / PETABYTE_TO_MEGABYTE_FACTOR

func PetaBytesToKiloBytes(n)
	return n * PETABYTE_TO_KILOBYTE_FACTOR

	func KiloBytesToPetaBytes(n)
		return n / PETABYTE_TO_KILOBYTE_FACTOR

func PetaBytesToBytes(n)
	return n * PETABYTE_TOBYTE_FACTOR

	func BytesToPetaBytes(n)
		return n / PETABYTE_TOBYTE_FACTOR

func PetaBytesToBits(n)
	return n * PETABYTE_TO_BIT

	func BitsToPetaBytes(n)
		return n / PETABYTE_TO_BIT

#--

func ExaBytesToPetaBytes(n)
	return n * EXABYTE_TO_PETABYTE_FACTOR

	func PetaBytesToExaBytes(n)
		return n / EXABYTE_TO_PETABYTE_FACTOR

func ExaBytesToTeraBytes(n)
	return n * EXABYTE_TO_TERBYTE_FACTOR

	func TeraBytesToExaBytes(n)
		return n / EXABYTE_TO_PETABYTE_FACTOR

func ExaBytesToGigaBytes(n)
	return n * EXABYTE_TO_GIGABYTE_FACTOR

	func GigaBytesToExaBytes(n)
		return n / EXABYTE_TO_GIGABYTE_FACTOR

func ExaBytesToMegaBytes(n)
	return n * EXABYTE_TO_MEGABYTE_FACTOR

	func MegaBytesToExaBytes(n)
		return n / EXABYTE_TO_MEGABYTE_FACTOR

func ExaBytesToKiloBytes(n)
	return n * EXABYTE_TO_KILOBYTE_FACTOR

	func KiloBytesToExaBytes(n)
		return n / EXABYTE_TO_KILOBYTE_FACTOR

func ExaBytesToBytes(n)
	return n * EXABYTE_TO_BYTE_FACTOR

	func BytesToExaBytes(n)
		return n / EXABYTE_TO_BYTE_FACTOR

func ExaBytesToBits(n)
	return n * EXABYTE_TO_BIT_FACTOR

	func BitsToExaBytes(n)
		return n / EXABYTE_TO_BIT_FACTOR

#--

func ZettaBytesToExaBytes(n)
	return n * ZETTABYTE_TO_EXABYTE_FACTOR

	func ExaBytesToZettaBytes(n)
		return n / ZETTABYTE_TO_EXABYTE_FACTOR

func ZettaBytesToPetaBytes(n)
	return n * ZETTABYTE_TO_PETABYTE_FACTOR

	func PetaBytesToZettaBytes(n)
		return n / ZETTABYTE_TO_PETABYTE_FACTOR

func ZettaBytesToTeraBytes(n)
	return n * ZETTABYTE_TO_TERABYTE_FACTOR

	func TeraBytesToZettaBytes(n)
		return n / ZETTABYTE_TO_TERABYTE_FACTOR

func ZettaBytesToGigaBytes(n)
	return n * ZETTABYTE_TO_GIGABYTE_FACTOR

	func GigaBytesToZettaBytes(n)
		return n / ZETTABYTE_TO_GIGABYTE_FACTOR

func ZettaBytesToMegaBytes(n)
	return n * ZETTABYTE_TO_MEGABYTE_FACTOR

	func MegaBytesToZettaBytes(n)
		return n / ZETTABYTE_TO_MEGABYTE_FACTOR

func ZettaBytesToKiloBytes(n)
	return n * ZETTABYTE_TO_KILOBYTE_FACTOR

	func KiloBytesToZettaBytes(n)
		return n / ZETTABYTE_TO_KILOBYTE_FACTOR

func ZettaBytesToBytes(n)
	return n * ZETTABYTE_TO_BYTE_FACTOR

	func BytesToZettaBytes(n)
		return n / ZETTABYTE_TO_BYTE_FACTOR

func ZettaBytesToBits(n)
	return n * ZETTABYTE_TO_BIT_FACTOR

	func BitsToZettaBytes(n)
		return n / ZETTABYTE_TO_BIT_FACTOR

#--

func YottaBytesToZettaBytes(n)
	return n * YOTTABYTE_TO_ZETTABYTE_FACTOR

	func ZettaBytesToYottaBytes(n)
		return n / YOTTABYTE_TO_ZETTABYTE_FACTOR

func YottaBytesToExaBytes(n)
	return n * YOTTABYTE_TO_EXABYTE_FACTOR

	func ExaBytesToYottaBytes(n)
		return 1 / YOTTABYTE_TO_EXABYTE_FACTOR

func YottaBytesToPetaBytes(n)
	return n * YOTTABYTE_TO_PETABYTE_FACTOR

	func PetaBytesToYottaBytes(n)
		return n / YOTTABYTE_TO_PETABYTE_FACTOR

func YottaBytesToTeraBytes(n)
	return n * YOTTABYTES_TO_TERABYTES_FACTOR

	func TeraBytesToYottaBytes(n)
		return n / YOTTABYTES_TO_TERABYTES_FACTOR

func YottaBytesToGigaBytes(n)
	return n * YOTTABYTE_TO_GIGABYTE_FACTOR

	func GigaBytesToYottaBytes(n)
		return n / YOTTABYTE_TO_GIGABYTE_FACTOR

func YottaBytesToMegaBytes(n)
	return n * YOTTABYTE_TO_MEGABYTE_FACTOR

	func MegaBytesToYottaBytes(n)
		return n / YOTTABYTE_TO_MEGABYTE_FACTOR

func YottaBytesToKiloBytes(n)
	return n * YOTTABYTE_TO_KILOBYTE_FACTOR

	func KiloBytesToYottaBytes(n)
		return n / YOTTABYTE_TO_KILOBYTE_FACTOR

func YottaBytesToBytes(n)
	return n * YOTTABYTE_TO_BYTE_FACTOR

	func BytesToYottaBytes(n)
		return n / YOTTABYTE_TO_BYTE_FACTOR

func YottaBytesToBits(n)
	return n * YOTTABYTE_TO_BIT_FACTOR

	func BitsToYottaBytes(n)
		return n / YOTTABYTE_TO_BIT_FACTOR

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

func Chars(str)
	if isList(str) and len(str) = 2 and isString(str[1]) and str[1] = :In
		str = str[2]
	ok

	oQString = new QString2()
	oQString.append(str)
	nLen = oQString.size()

	acResult = []

	for i = 1 to nLen
		n = i - 1
		acResult + oQString.mid(n, 1)
	next

	return acResult

	func @Chars(str)
		return Chars(str)


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

func SizeInBytes(item)
	if Is64Bit()
		return SizeInBytes64(item)
	else
		return SizeInBytes32(item)
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

#---- Same functions for 32BIT

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

#---- Same functions for 64BIT

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

#========== #TODO // add XT(), 32() and 64() prefixes

func SizeInKiloBytes(item)
	return BytesToKiloBytes( SizeInBytes(item) )

	#< @FunctionAlternativeForms

	func @SizeInKiloBytes(p)
		return SizeInKiloBytes(p)

	func NumberOfKiloBytes(p)
		if isList(p) and len(p) = 2 and isString(p[1]) and 
		   (p[1] = :In or p[1] = :Of)
				p = p[2]
		ok

		return SizeInKiloBytes(p)

	func @NumberOfKiloBytes(p)
		return NumberOfKiloBytes(p)

	func CountKiloBytes(p)
		return NumberOfKiloBytes(p)

	func @CountKiloBytes(p)
		return NumberOfKiloBytes(p)

	#>

func SizeInMegaBytes(item)
	return BytesToMegaBytes( SizeInBytes(item) )

	#< @FunctionAlternativeForms

	func @SizeInMegaBytes(p)
		return SizeInMegaBytes(p)

	func NumberOfMegaBytes(p)
		if isList(p) and len(p) = 2 and isString(p[1]) and 
		   (p[1] = :In or p[1] = :Of)
				p = p[2]
		ok

		return SizeInMegaBytes(p)

	func @NumberOfMegaBytes(p)
		return NumberOfMegaBytes(p)

	func CountMegaBytes(p)
		return NumberOfMegaBytes(p)

	func @CountMegaBytes(p)
		return NumberOfMegaBytes(p)

	#>

func SizeInGigaBytes(item)
	return BytesToGigaBytes( SizeInBytes(item) )

	#< @FunctionAlternativeForms

	func @SizeInGigaBytes(p)
		return SizeInGigaBytes(p)

	func NumberOfGigaBytes(p)
		if isList(p) and len(p) = 2 and isString(p[1]) and 
		   (p[1] = :In or p[1] = :Of)

			p = p[2]
		ok

		return SizeInGigaBytes(p)

	func @NumberOfGigaBytes(p)
		return NumberOfGigaBytes(p)

	func CountGigaBytes(p)
		return NumberOfGigaBytes(p)

	func @CountGigaBytes(p)
		return NumberOfGigaBytes(p)

	#>

func SizeInTeraBytes(item)
	return BytesToTeraBytes( SizeInBytes(item) )

	#< @FunctionAlternativeForms

	func @SizeInTeraBytes(p)
		return SizeInTeraBytes(p)

	func NumberOfTeraBytes(p)
		if isList(p) and len(p) = 2 and isString(p[1]) and
		   (p[1] = :In or p[1] = :Of)

				p = p[2]
		ok

		return SizeInTeraBytes(p)

	func @NumberOfTeraBytes(p)
		return NumberOfTeraBytes(p)

	func CountTeraBytes(p)
		return NumberOfTeraBytes(p)

	func @CountTeraBytes(p)
		return NumberOfTeraBytes(p)

	#>

func SizeInPetaBytes(item)
	return BytesToPetaBytes( SizeInBytes(item) )

	#< @FunctionAlternativeForms

	func @SizeInPetaBytes(p)
		return SizeInPetaBytes(p)

	func NumberOfPetaBytes(p)
		if isList(p) and len(p) = 2 and isString(p[1]) and
		   (p[1] = :In or p[1] = :Of)

			p = p[2]
		ok

		return SizeInPetaBytes(p)

	func @NumberOfPetaBytes(p)
		return NumberOfPetaBytes(p)

	func CountPetaBytes(p)
		return NumberOfPetaBytes(p)

	func @CountPetaBytes(p)
		return NumberOfPetaBytes(p)

	#>

func SizeInExaBytes(item)
	return BytesToExaBytes( SizeInBytes(item) )

	#< @FunctionAlternativeForms

	func @SizeInExaBytes(p)
		return SizeInExaBytes(p)

	func NumberOfExaBytes(p)
		if isList(p) and len(p) = 2 and isString(p[1]) and
		   (p[1] = :In or p[1] = :Of)

			p = p[2]
		ok

		return SizeInExaBytes(p)

	func @NumberOfExaBytes(p)
		return NumberOfExaBytes(p)

	func CountExaBytes(p)
		return NumberOfExaBytes(p)

	func @CountExaBytes(p)
		return NumberOfExaBytes(p)

	#>

func SizeInZettaBytes(item)
	return BytesToZettaBytes( SizeInBytes(item) )

	#< @FunctionAlternativeForms

	func @SizeInZettaBytes(p)
		return SizeInZettaBytes(p)

	func NumberOfZettaBytes(p)
		if isList(p) and len(p) = 2 and isString(p[1]) and
		   (p[1] = :In or p[1] = :Of)

			p = p[2]
		ok

		return SizeInZettaBytes(p)

	func @NumberOfZettaBytes(p)
		return NumberOfZettaBytes(p)

	func CountZettaBytes(p)
		return NumberOfZettaBytes(p)

	func @CountZettaBytes(p)
		return NumberOfZettaBytes(p)

	#>

func SizeInYottaBytes(item)
	return BytesToYottaBytes( SizeInBytes(item) )

	#< @FunctionAlternativeForms

	func @SizeInYottaBytes(p)
		return SizeInYottaBytes(p)

	func NumberOfYottaBytes(p)
		if isList(p) and len(p) = 2 and isString(p[1]) and
		   (p[1] = :In or p[1] = :Of)

			p = p[2]
		ok

		return SizeInYottaBytes(p)

	func @NumberOfYottaBytes(p)
		return NumberOfYottaBytes(p)

	func CountYottaBytes(p)
		return NumberOfYottaBytes(p)

	func @CountYottaBytes(p)
		return NumberOfYottaBytes(p)

	#>


