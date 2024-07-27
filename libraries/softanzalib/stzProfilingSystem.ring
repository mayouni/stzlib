
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

BYTE_TO_BIT_FACTOR = 8

KILOBYTE_TO_BYTE_FACTOR = 1024
KILOBYTE_TO_BIT_FACTOR  = 1_048_576	// 1024 * 1024

MEGABYTE_TO_BYTE_FACTOR     = 1024
MEGABYTE_TO_KILOBYTE_FACTOR = 1_048_576
MEGABYTE_TO_BIT_FACTOR      = 1_073_741_824

GIGABYTE_TO_MEGABYTE_FACTOR = 1024
GIGABYTE_TO_BYTE_FACTOR     = 1_048_576
GIGABYTE_TO_KILOBYTE_FACTOR = 1_073_741_824
GIGABYTE_TO_BIT_FACTOR      = 1_099_511_627_776

TERABYTE_TO_GIGABYTE_FACTOR = 1024
TERABYTE_TO_MEGABYTE_FACTOR = 1_048_576
TERABYTE_TO_KILOBYTE_FACTOR = 1_073_741_824
TERABYTE_TO_BYTE_FACTOR     = 1_099_511_627_776
TERABYTE_TO_BIT_FACTOR      = 1_125_899_906_842_624

PETABYTE_TO_TERABYTE_FACTOR = 1024
PETABYTE_TO_GIGABYTE_FACTOR = 1_048_576
PETABYTE_TO_MEGABYTE_FACTOR = 1_073_741_824
PETABYTE_TO_KILOBYTE_FACTOR = 1_099_511_627_776
PETABYTE_TO_BYTE_FACTOR     = 1_125_899_906_842_624
PETABYTE_TO_BIT_FACTOR      = 11_52_921_504_606_846_976

EXABYTE_TO_PETABYTE_FACTOR = 1024
EXABYTE_TO_TERABYTE_FACTOR = 1_048_576
EXABYTE_TO_GIGABYTE_FACTOR = 1_073_741_824
EXABYTE_TO_MEGABYTE_FACTOR = 1_099_511_627_776
EXABYTE_TO_KILOBYTE_FACTOR = 1_125_899_906_842_624
EXABYTE_TO_BYTE_FACTOR     = 11_52_921_504_606_846_976
EXABYTE_TO_BIT_FACTOR      = 1_180_591_620_717_411_303_424

ZETTABYTE_TO_EXABYTE_FACTOR  = 1024
ZETTABYTE_TO_PETABYTE_FACTOR = 1_048_576
ZETTABYTE_TO_TERABYTE_FACTOR = 1_073_741_824
ZETTABYTE_TO_GIGABYTE_FACTOR = 1_099_511_627_776
ZETTABYTE_TO_MEGABYTE_FACTOR = 1_125_899_906_842_624
ZETTABYTE_TO_KILOBYTE_FACTOR = 11_52_921_504_606_846_976
ZETTABYTE_TO_BYTE_FACTOR     = 1_180_591_620_717_411_303_424
ZETTABYTE_TO_BIT_FACTOR      = 1_208_925_819_614_629_174_706_176

YOTTABYTE_TO_ZETTABYTE_FACTOR = 1024
YOTTABYTE_TO_EXABYTE_FACTOR   = 1_048_576
YOTTABYTE_TO_PETABYTE_FACTOR  = 1_073_741_824
YOTTABYTE_TO_TERABYTE_FACTOR  = 1_099_511_627_776
YOTTABYTE_TO_GIGABYTE_FACTOR  = 1_125_899_906_842_624
YOTTABYTE_TO_MEGABYTE_FACTOR  = 11_52_921_504_606_846_976
YOTTABYTE_TO_KILOBYTE_FACTOR  = 1_180_591_620_717_411_303_424
YOTTABYTE_TO_BYTE_FACTOR      = 1_208_925_819_614_629_174_706_176
YOTTABYTE_TO_BIT_FACTOR       = 1_237_940_039_285_380_274_899_124_224

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

#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~#
#  GETTING ARCHITECTURE TYPE  #
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~#

func Arch()
	return getArch()

func Is32Bit()
	cArch = Arch()
	if cArch = "x86" or cArch = "arm"
		return TRUE
	else
		return FALSE
	ok

func Is64Bit()
	cArch = Arch()
	if cArch = "x64" or cArch = "arm64"
		return TRUE
	else
		return FALSE
	ok

func Is32Or54Bit()
	cArch = Arch()
	if cArch = "x86" or cArch = "arm"
		return :32
	but cArch = "x64" or cArch = "arm64"
		return :64
	else
		return :Unknown
	ok

#~~~~~~~~~~~~~~~~~~#
#  PROFILING TIME  #
#~~~~~~~~~~~~~~~~~~#

func StartTimer()
	_time0 = clock()

func ResetTimer()
	_time0 = 0

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

	if NOT Q(pIn).IsOneOfThese([ :Clocks, :Seconds, :Minutes, :Hours ])
		#TODO - Future: Add days, weeks, months, years...
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
	? NL + "Executed in " + cElapsed + " second(s)."
	_time0 = 0
	STOP()

	func EndProfiler()
		StopProfiler()

	func Profoff()
		StopProfiler()

	func StopProfiler()
		StopProfiler()

	func ProfilerOff()
		StopProfiler()

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

func SizeInBytes(item)
	is64bit = Is64Bit()
    
	switch type(item)
	on "NUMBER"
		if is64Bit
			return RING_64BIT_ITEM_STRUCTURE_SIZE + RING_64BIT_ITEMS_STRUCTURE_SIZE
		else
			return RING_32BIT_ITEM_STRUCTURE_SIZE + RING_32BIT_ITEMS_STRUCTURE_SIZE
		ok

        on "STRING"
		if is64Bit
			return Len(item) + RING_64BIT_STRING_STRUCTURE_SIZE
		else
			return Len(item) + RING_32BIT_STRING_STRUCTURE_SIZE
	    ok

	on "LIST"
		if is64Bit
			listSize = RING_64BIT_LIST_STRUCTURE_SIZE
			itemTotalSize = RING_64BIT_ITEM_STRUCTURE_SIZE + RING_64BIT_ITEMS_STRUCTURE_SIZE
		else
			listSize = RING_32BIT_LIST_STRUCTURE_SIZE
			itemTotalSize = RING_32BIT_ITEM_STRUCTURE_SIZE + RING_32BIT_ITEMS_STRUCTURE_SIZE
		ok

		return listSize + (Len(item) * itemTotalSize)

        on "OBJECT"
		aValues = []
		acAttributes = attributes(p)
		nLen = len(acAttributes)

		for i = 1 to nLen
			cCode = 'value = p.' + acAttributes[i]
			eval(cCode)
			aValues + value
		next

		return SizeInBytes(aValues)		
	off

	#< @FunctionAlternativeForms

	func @SizeInBytes(p)
		return SizeInBytes(p)

	func NumberOfBytes(p)
		if CheckParams()
			if isList(p) and StzListQ(p).IsInOrOfNamedParam()
				p = p[2]
			ok
		ok

		return SizeInBytes(p)

	func @NumberOfBytes(p)
		return NumberOfBytes(p)

	func CountBytes(p)
		return NumberOfBytes(p)

	func @CountBytes(p)
		return NumberOfBytes(p)

	#>

func SizeInKiloBytes(item)
	return BytesToKiloBytes( SizeInBytes(item) )

	#< @FunctionAlternativeForms

	func @SizeInKiloBytes(p)
		return SizeInKiloBytes(p)

	func NumberOfKiloBytes(p)
		if CheckParams()
			if isList(p) and StzListQ(p).IsInOrOfNamedParam()
				p = p[2]
			ok
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
		if CheckParams()
			if isList(p) and StzListQ(p).IsInOrOfNamedParam()
				p = p[2]
			ok
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
		if CheckParams()
			if isList(p) and StzListQ(p).IsInOrOfNamedParam()
				p = p[2]
			ok
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
		if CheckParams()
			if isList(p) and StzListQ(p).IsInOrOfNamedParam()
				p = p[2]
			ok
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
		if CheckParams()
			if isList(p) and StzListQ(p).IsInOrOfNamedParam()
				p = p[2]
			ok
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
		if CheckParams()
			if isList(p) and StzListQ(p).IsInOrOfNamedParam()
				p = p[2]
			ok
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
		if CheckParams()
			if isList(p) and StzListQ(p).IsInOrOfNamedParam()
				p = p[2]
			ok
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
		if CheckParams()
			if isList(p) and StzListQ(p).IsInOrOfNamedParam()
				p = p[2]
			ok
		ok

		return SizeInYottaBytes(p)

	func @NumberOfYottaBytes(p)
		return NumberOfYottaBytes(p)

	func CountYottaBytes(p)
		return NumberOfYottaBytes(p)

	func @CountYottaBytes(p)
		return NumberOfYottaBytes(p)

	#>

