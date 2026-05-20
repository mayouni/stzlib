#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~#
#  CONVERTING BETWEEN BYTES, KILOBYTES, MEGABYTES, AND GIGABYTES  #
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~#

func StzBytesToBits(n)
	return n * BYTE_TO_BIT_FACTOR

	func BytesToBits(n)
		return StzBytesToBits(n)

func StzBitsToBytes(n)
	return n / BYTE_TO_BIT_FACTOR

	func BitsToBytes(n)
		return StzBitsToBytes(n)

#--

func StzKiloBytesToBytes(n)
	return n * KILOBYTE_TO_BYTE_FACTOR

	func KiloBytesToBytes(n)
		return StzKiloBytesToBytes(n)

func StzBytesToKiloBytes(n)
	return n / KILOBYTE_TO_BYTE_FACTOR

	func BytesToKiloBytes(n)
		return StzBytesToKiloBytes(n)

func StzKiloBytesToBits(n)
	return n * KILOBYTE_TO_BIT_FACTOR

	func KiloBytesToBits(n)
		return StzKiloBytesToBits(n)

func StzBitsToKiloBytes(n)
	return n / KILOBYTE_TO_BIT_FACTOR

	func BitsToKiloBytes(n)
		return StzBitsToKiloBytes(n)

#--

func StzMegaBytesToKiloBytes(n)
	return n * MEGABYTE_TO_KILOBYTE_FACTOR

	func MegaBytesToKiloBytes(n)
		return StzMegaBytesToKiloBytes(n)

func StzKiloBytesToMegaBytes(n)
	return n / MEGABYTE_TO_KILOBYTE_FACTOR

	func KiloBytesToMegaBytes(n)
		return StzKiloBytesToMegaBytes(n)

func StzMegaBytesToBytes(n)
	return n * MEGABYTE_TO_BYTE_FACTOR

	func MegaBytesToBytes(n)
		return StzMegaBytesToBytes(n)

func StzBytesToMegaBytes(n)
	return n / MEGABYTE_TO_BYTE_FACTOR

	func BytesToMegaBytes(n)
		return StzBytesToMegaBytes(n)

func StzMegaBytesToBits(n)
	return n * MEGABYTE_TO_BIT_FACTOR

	func MegaBytesToBits(n)
		return StzMegaBytesToBits(n)

func StzBitsToMegaBytes(n)
	return n / MEGABYTE_TO_BIT_FACTOR

	func BitsToMegaBytes(n)
		return StzBitsToMegaBytes(n)

#--

func StzGigaBytesToMegaBytes(n)
	return n * GIGABYTE_TO_MEGABYTE_FACTOR

	func GigaBytesToMegaBytes(n)
		return StzGigaBytesToMegaBytes(n)

func StzMegaBytesToGigaBytes(n)
	return n / GIGABYTE_TO_MEGABYTE_FACTOR

	func MegaBytesToGigaBytes(n)
		return StzMegaBytesToGigaBytes(n)

func StzGigaBytesToKiloBytes(n)
	return n * GIGABYTE_TO_KILOBYTE_FACTOR

	func GigaBytesToKiloBytes(n)
		return StzGigaBytesToKiloBytes(n)

func StzKiloBytesToGigaBytes(n)
	return n / GIGABYTE_TO_KILOBYTE_FACTOR

	func KiloBytesToGigaBytes(n)
		return StzKiloBytesToGigaBytes(n)

func StzGigaBytesToBytes(n)
	return n * GIGABYTE_TO_BYTE_FACTOR

	func GigaBytesToBytes(n)
		return StzGigaBytesToBytes(n)

func StzBytesToGigaBytes(n)
	return n / GIGABYTE_TO_BYTE_FACTOR

	func BytesToGigaBytes(n)
		return StzBytesToGigaBytes(n)

func StzGigaBytesToBits(n)
	return n * GIGABYTE_TO_BIT_FACTOR

	func GigaBytesToBits(n)
		return StzGigaBytesToBits(n)

func StzBitsToGigaBytes(n)
	return n / GIGABYTE_TO_BIT_FACTOR

	func BitsToGigaBytes(n)
		return StzBitsToGigaBytes(n)

#--

func StzTeraBytesToGigaBytes(n)
	return n * TERABYTE_TO_GIGABYTE

	func TeraBytesToGigaBytes(n)
		return StzTeraBytesToGigaBytes(n)

func StzGigaBytesToTeraBytes(n)
	return n / TERABYTE_TO_GIGABYTE

	func GigaBytesToTeraBytes(n)
		return StzGigaBytesToTeraBytes(n)

func StzTeraBytesToMegaBytes(n)
	return n * TERABYTE_TO_MEGABYTE_FACTOR

	func TeraBytesToMegaBytes(n)
		return StzTeraBytesToMegaBytes(n)

func StzMegaBytesToTeraBytes(n)
	return n / TERABYTE_TO_MEGABYTE_FACTOR

	func MegaBytesToTeraBytes(n)
		return StzMegaBytesToTeraBytes(n)

func StzTeraBytesToKiloBytes(n)
	return n * TERABYTE_TO_KILOBYTE_FACTOR

	func TeraBytesToKiloBytes(n)
		return StzTeraBytesToKiloBytes(n)

func StzKiloBytesToTeraBytes(n)
	return n / TERABYTE_TO_KILOBYTE_FACTOR

	func KiloBytesToTeraBytes(n)
		return StzKiloBytesToTeraBytes(n)

func StzTeraBytesToBytes(n)
	return n * TERABYTE_TO_BYTE_FACTOR

	func TeraBytesToBytes(n)
		return StzTeraBytesToBytes(n)

func StzBytesToTeraBytes(n)
	return n / TERABYTE_TO_BYTE_FACTOR

	func BytesToTeraBytes(n)
		return StzBytesToTeraBytes(n)

func StzTeraBytesToBits(n)
	return n * TERABYTE_TO_BIT_FACTOR

	func TeraBytesToBits(n)
		return StzTeraBytesToBits(n)

func StzBitsToTeraBytes(n)
	return n / TERABYTE_TO_BIT_FACTOR

	func BitsToTeraBytes(n)
		return StzBitsToTeraBytes(n)

#--

func StzPetaBytesToTeraBytes(n)
	return n * PETABYTE_TO_TERABYTE_FACTOR

	func PetaBytesToTeraBytes(n)
		return StzPetaBytesToTeraBytes(n)

func StzTeraBytesToPetaBytes(n)
	return n / PETABYTE_TO_TERABYTE_FACTOR

	func TeraBytesToPetaBytes(n)
		return StzTeraBytesToPetaBytes(n)

func StzPetaBytesToGigaBytes(n)
	return n * PETABYTE_TO_GIGABYTE_FACTOR

	func PetaBytesToGigaBytes(n)
		return StzPetaBytesToGigaBytes(n)

func StzGigaBytesToPetaBytes(n)
	return n / PETABYTE_TO_GIGABYTE_FACTOR

	func GigaBytesToPetaBytes(n)
		return StzGigaBytesToPetaBytes(n)

func StzPetaBytesToMegaBytes(n)
	return n * PETABYTE_TO_MEGABYTE_FACTOR

	func PetaBytesToMegaBytes(n)
		return StzPetaBytesToMegaBytes(n)

func StzMegaBytesToPetaBytes(n)
	return n / PETABYTE_TO_MEGABYTE_FACTOR

	func MegaBytesToPetaBytes(n)
		return StzMegaBytesToPetaBytes(n)

func StzPetaBytesToKiloBytes(n)
	return n * PETABYTE_TO_KILOBYTE_FACTOR

	func PetaBytesToKiloBytes(n)
		return StzPetaBytesToKiloBytes(n)

func StzKiloBytesToPetaBytes(n)
	return n / PETABYTE_TO_KILOBYTE_FACTOR

	func KiloBytesToPetaBytes(n)
		return StzKiloBytesToPetaBytes(n)

func StzPetaBytesToBytes(n)
	return n * PETABYTE_TOBYTE_FACTOR

	func PetaBytesToBytes(n)
		return StzPetaBytesToBytes(n)

func StzBytesToPetaBytes(n)
	return n / PETABYTE_TOBYTE_FACTOR

	func BytesToPetaBytes(n)
		return StzBytesToPetaBytes(n)

func StzPetaBytesToBits(n)
	return n * PETABYTE_TO_BIT

	func PetaBytesToBits(n)
		return StzPetaBytesToBits(n)

func StzBitsToPetaBytes(n)
	return n / PETABYTE_TO_BIT

	func BitsToPetaBytes(n)
		return StzBitsToPetaBytes(n)

#--

func StzExaBytesToPetaBytes(n)
	return n * EXABYTE_TO_PETABYTE_FACTOR

	func ExaBytesToPetaBytes(n)
		return StzExaBytesToPetaBytes(n)

func StzPetaBytesToExaBytes(n)
	return n / EXABYTE_TO_PETABYTE_FACTOR

	func PetaBytesToExaBytes(n)
		return StzPetaBytesToExaBytes(n)

func StzExaBytesToTeraBytes(n)
	return n * EXABYTE_TO_TERBYTE_FACTOR

	func ExaBytesToTeraBytes(n)
		return StzExaBytesToTeraBytes(n)

func StzTeraBytesToExaBytes(n)
	return n / EXABYTE_TO_PETABYTE_FACTOR

	func TeraBytesToExaBytes(n)
		return StzTeraBytesToExaBytes(n)

func StzExaBytesToGigaBytes(n)
	return n * EXABYTE_TO_GIGABYTE_FACTOR

	func ExaBytesToGigaBytes(n)
		return StzExaBytesToGigaBytes(n)

func StzGigaBytesToExaBytes(n)
	return n / EXABYTE_TO_GIGABYTE_FACTOR

	func GigaBytesToExaBytes(n)
		return StzGigaBytesToExaBytes(n)

func StzExaBytesToMegaBytes(n)
	return n * EXABYTE_TO_MEGABYTE_FACTOR

	func ExaBytesToMegaBytes(n)
		return StzExaBytesToMegaBytes(n)

func StzMegaBytesToExaBytes(n)
	return n / EXABYTE_TO_MEGABYTE_FACTOR

	func MegaBytesToExaBytes(n)
		return StzMegaBytesToExaBytes(n)

func StzExaBytesToKiloBytes(n)
	return n * EXABYTE_TO_KILOBYTE_FACTOR

	func ExaBytesToKiloBytes(n)
		return StzExaBytesToKiloBytes(n)

func StzKiloBytesToExaBytes(n)
	return n / EXABYTE_TO_KILOBYTE_FACTOR

	func KiloBytesToExaBytes(n)
		return StzKiloBytesToExaBytes(n)

func StzExaBytesToBytes(n)
	return n * EXABYTE_TO_BYTE_FACTOR

	func ExaBytesToBytes(n)
		return StzExaBytesToBytes(n)

func StzBytesToExaBytes(n)
	return n / EXABYTE_TO_BYTE_FACTOR

	func BytesToExaBytes(n)
		return StzBytesToExaBytes(n)

func StzExaBytesToBits(n)
	return n * EXABYTE_TO_BIT_FACTOR

	func ExaBytesToBits(n)
		return StzExaBytesToBits(n)

func StzBitsToExaBytes(n)
	return n / EXABYTE_TO_BIT_FACTOR

	func BitsToExaBytes(n)
		return StzBitsToExaBytes(n)

#--

func StzZettaBytesToExaBytes(n)
	return n * ZETTABYTE_TO_EXABYTE_FACTOR

	func ZettaBytesToExaBytes(n)
		return StzZettaBytesToExaBytes(n)

func StzExaBytesToZettaBytes(n)
	return n / ZETTABYTE_TO_EXABYTE_FACTOR

	func ExaBytesToZettaBytes(n)
		return StzExaBytesToZettaBytes(n)

func StzZettaBytesToPetaBytes(n)
	return n * ZETTABYTE_TO_PETABYTE_FACTOR

	func ZettaBytesToPetaBytes(n)
		return StzZettaBytesToPetaBytes(n)

func StzPetaBytesToZettaBytes(n)
	return n / ZETTABYTE_TO_PETABYTE_FACTOR

	func PetaBytesToZettaBytes(n)
		return StzPetaBytesToZettaBytes(n)

func StzZettaBytesToTeraBytes(n)
	return n * ZETTABYTE_TO_TERABYTE_FACTOR

	func ZettaBytesToTeraBytes(n)
		return StzZettaBytesToTeraBytes(n)

func StzTeraBytesToZettaBytes(n)
	return n / ZETTABYTE_TO_TERABYTE_FACTOR

	func TeraBytesToZettaBytes(n)
		return StzTeraBytesToZettaBytes(n)

func StzZettaBytesToGigaBytes(n)
	return n * ZETTABYTE_TO_GIGABYTE_FACTOR

	func ZettaBytesToGigaBytes(n)
		return StzZettaBytesToGigaBytes(n)

func StzGigaBytesToZettaBytes(n)
	return n / ZETTABYTE_TO_GIGABYTE_FACTOR

	func GigaBytesToZettaBytes(n)
		return StzGigaBytesToZettaBytes(n)

func StzZettaBytesToMegaBytes(n)
	return n * ZETTABYTE_TO_MEGABYTE_FACTOR

	func ZettaBytesToMegaBytes(n)
		return StzZettaBytesToMegaBytes(n)

func StzMegaBytesToZettaBytes(n)
	return n / ZETTABYTE_TO_MEGABYTE_FACTOR

	func MegaBytesToZettaBytes(n)
		return StzMegaBytesToZettaBytes(n)

func StzZettaBytesToKiloBytes(n)
	return n * ZETTABYTE_TO_KILOBYTE_FACTOR

	func ZettaBytesToKiloBytes(n)
		return StzZettaBytesToKiloBytes(n)

func StzKiloBytesToZettaBytes(n)
	return n / ZETTABYTE_TO_KILOBYTE_FACTOR

	func KiloBytesToZettaBytes(n)
		return StzKiloBytesToZettaBytes(n)

func StzZettaBytesToBytes(n)
	return n * ZETTABYTE_TO_BYTE_FACTOR

	func ZettaBytesToBytes(n)
		return StzZettaBytesToBytes(n)

func StzBytesToZettaBytes(n)
	return n / ZETTABYTE_TO_BYTE_FACTOR

	func BytesToZettaBytes(n)
		return StzBytesToZettaBytes(n)

func StzZettaBytesToBits(n)
	return n * ZETTABYTE_TO_BIT_FACTOR

	func ZettaBytesToBits(n)
		return StzZettaBytesToBits(n)

func StzBitsToZettaBytes(n)
	return n / ZETTABYTE_TO_BIT_FACTOR

	func BitsToZettaBytes(n)
		return StzBitsToZettaBytes(n)

#--

func StzYottaBytesToZettaBytes(n)
	return n * YOTTABYTE_TO_ZETTABYTE_FACTOR

	func YottaBytesToZettaBytes(n)
		return StzYottaBytesToZettaBytes(n)

func StzZettaBytesToYottaBytes(n)
	return n / YOTTABYTE_TO_ZETTABYTE_FACTOR

	func ZettaBytesToYottaBytes(n)
		return StzZettaBytesToYottaBytes(n)

func StzYottaBytesToExaBytes(n)
	return n * YOTTABYTE_TO_EXABYTE_FACTOR

	func YottaBytesToExaBytes(n)
		return StzYottaBytesToExaBytes(n)

func StzExaBytesToYottaBytes(n)
	return 1 / YOTTABYTE_TO_EXABYTE_FACTOR

	func ExaBytesToYottaBytes(n)
		return StzExaBytesToYottaBytes(n)

func StzYottaBytesToPetaBytes(n)
	return n * YOTTABYTE_TO_PETABYTE_FACTOR

	func YottaBytesToPetaBytes(n)
		return StzYottaBytesToPetaBytes(n)

func StzPetaBytesToYottaBytes(n)
	return n / YOTTABYTE_TO_PETABYTE_FACTOR

	func PetaBytesToYottaBytes(n)
		return StzPetaBytesToYottaBytes(n)

func StzYottaBytesToTeraBytes(n)
	return n * YOTTABYTES_TO_TERABYTES_FACTOR

	func YottaBytesToTeraBytes(n)
		return StzYottaBytesToTeraBytes(n)

func StzTeraBytesToYottaBytes(n)
	return n / YOTTABYTES_TO_TERABYTES_FACTOR

	func TeraBytesToYottaBytes(n)
		return StzTeraBytesToYottaBytes(n)

func StzYottaBytesToGigaBytes(n)
	return n * YOTTABYTE_TO_GIGABYTE_FACTOR

	func YottaBytesToGigaBytes(n)
		return StzYottaBytesToGigaBytes(n)

func StzGigaBytesToYottaBytes(n)
	return n / YOTTABYTE_TO_GIGABYTE_FACTOR

	func GigaBytesToYottaBytes(n)
		return StzGigaBytesToYottaBytes(n)

func StzYottaBytesToMegaBytes(n)
	return n * YOTTABYTE_TO_MEGABYTE_FACTOR

	func YottaBytesToMegaBytes(n)
		return StzYottaBytesToMegaBytes(n)

func StzMegaBytesToYottaBytes(n)
	return n / YOTTABYTE_TO_MEGABYTE_FACTOR

	func MegaBytesToYottaBytes(n)
		return StzMegaBytesToYottaBytes(n)

func StzYottaBytesToKiloBytes(n)
	return n * YOTTABYTE_TO_KILOBYTE_FACTOR

	func YottaBytesToKiloBytes(n)
		return StzYottaBytesToKiloBytes(n)

func StzKiloBytesToYottaBytes(n)
	return n / YOTTABYTE_TO_KILOBYTE_FACTOR

	func KiloBytesToYottaBytes(n)
		return StzKiloBytesToYottaBytes(n)

func StzYottaBytesToBytes(n)
	return n * YOTTABYTE_TO_BYTE_FACTOR

	func YottaBytesToBytes(n)
		return StzYottaBytesToBytes(n)

func StzBytesToYottaBytes(n)
	return n / YOTTABYTE_TO_BYTE_FACTOR

	func BytesToYottaBytes(n)
		return StzBytesToYottaBytes(n)

func StzYottaBytesToBits(n)
	return n * YOTTABYTE_TO_BIT_FACTOR

	func YottaBytesToBits(n)
		return StzYottaBytesToBits(n)

func StzBitsToYottaBytes(n)
	return n / YOTTABYTE_TO_BIT_FACTOR

	func BitsToYottaBytes(n)
		return StzBitsToYottaBytes(n)

#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~#
#  CONVERTING BETWEEN BYTES, KILOBYTES, MEGABYTES, AND GIGABYTES  #
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~#

func StzSizeInKiloBytes(item)
	return StzBytesToKiloBytes( SizeInBytes(item) )

	#< @FunctionAlternativeForms

	func SizeInKiloBytes(item)
		return StzSizeInKiloBytes(item)

	func @SizeInKiloBytes(p)
		return StzSizeInKiloBytes(p)

	func StzNumberOfKiloBytes(p)
		if isList(p) and len(p) = 2 and isString(p[1]) and
		   (p[1] = :In or p[1] = :Of)
				p = p[2]
		ok

		return StzSizeInKiloBytes(p)

	func NumberOfKiloBytes(p)
		return StzNumberOfKiloBytes(p)

	func @NumberOfKiloBytes(p)
		return StzNumberOfKiloBytes(p)

	func StzCountKiloBytes(p)
		return StzNumberOfKiloBytes(p)

	func CountKiloBytes(p)
		return StzNumberOfKiloBytes(p)

	func @CountKiloBytes(p)
		return StzNumberOfKiloBytes(p)

	#>

func StzSizeInMegaBytes(item)
	return StzBytesToMegaBytes( SizeInBytes(item) )

	#< @FunctionAlternativeForms

	func SizeInMegaBytes(item)
		return StzSizeInMegaBytes(item)

	func @SizeInMegaBytes(p)
		return StzSizeInMegaBytes(p)

	func StzNumberOfMegaBytes(p)
		if isList(p) and len(p) = 2 and isString(p[1]) and
		   (p[1] = :In or p[1] = :Of)
				p = p[2]
		ok

		return StzSizeInMegaBytes(p)

	func NumberOfMegaBytes(p)
		return StzNumberOfMegaBytes(p)

	func @NumberOfMegaBytes(p)
		return StzNumberOfMegaBytes(p)

	func StzCountMegaBytes(p)
		return StzNumberOfMegaBytes(p)

	func CountMegaBytes(p)
		return StzNumberOfMegaBytes(p)

	func @CountMegaBytes(p)
		return StzNumberOfMegaBytes(p)

	#>

func StzSizeInGigaBytes(item)
	return StzBytesToGigaBytes( SizeInBytes(item) )

	#< @FunctionAlternativeForms

	func SizeInGigaBytes(item)
		return StzSizeInGigaBytes(item)

	func @SizeInGigaBytes(p)
		return StzSizeInGigaBytes(p)

	func StzNumberOfGigaBytes(p)
		if isList(p) and len(p) = 2 and isString(p[1]) and
		   (p[1] = :In or p[1] = :Of)

			p = p[2]
		ok

		return StzSizeInGigaBytes(p)

	func NumberOfGigaBytes(p)
		return StzNumberOfGigaBytes(p)

	func @NumberOfGigaBytes(p)
		return StzNumberOfGigaBytes(p)

	func StzCountGigaBytes(p)
		return StzNumberOfGigaBytes(p)

	func CountGigaBytes(p)
		return StzNumberOfGigaBytes(p)

	func @CountGigaBytes(p)
		return StzNumberOfGigaBytes(p)

	#>

func StzSizeInTeraBytes(item)
	return StzBytesToTeraBytes( SizeInBytes(item) )

	#< @FunctionAlternativeForms

	func SizeInTeraBytes(item)
		return StzSizeInTeraBytes(item)

	func @SizeInTeraBytes(p)
		return StzSizeInTeraBytes(p)

	func StzNumberOfTeraBytes(p)
		if isList(p) and len(p) = 2 and isString(p[1]) and
		   (p[1] = :In or p[1] = :Of)

				p = p[2]
		ok

		return StzSizeInTeraBytes(p)

	func NumberOfTeraBytes(p)
		return StzNumberOfTeraBytes(p)

	func @NumberOfTeraBytes(p)
		return StzNumberOfTeraBytes(p)

	func StzCountTeraBytes(p)
		return StzNumberOfTeraBytes(p)

	func CountTeraBytes(p)
		return StzNumberOfTeraBytes(p)

	func @CountTeraBytes(p)
		return StzNumberOfTeraBytes(p)

	#>

func StzSizeInPetaBytes(item)
	return StzBytesToPetaBytes( SizeInBytes(item) )

	#< @FunctionAlternativeForms

	func SizeInPetaBytes(item)
		return StzSizeInPetaBytes(item)

	func @SizeInPetaBytes(p)
		return StzSizeInPetaBytes(p)

	func StzNumberOfPetaBytes(p)
		if isList(p) and len(p) = 2 and isString(p[1]) and
		   (p[1] = :In or p[1] = :Of)

			p = p[2]
		ok

		return StzSizeInPetaBytes(p)

	func NumberOfPetaBytes(p)
		return StzNumberOfPetaBytes(p)

	func @NumberOfPetaBytes(p)
		return StzNumberOfPetaBytes(p)

	func StzCountPetaBytes(p)
		return StzNumberOfPetaBytes(p)

	func CountPetaBytes(p)
		return StzNumberOfPetaBytes(p)

	func @CountPetaBytes(p)
		return StzNumberOfPetaBytes(p)

	#>

func StzSizeInExaBytes(item)
	return StzBytesToExaBytes( SizeInBytes(item) )

	#< @FunctionAlternativeForms

	func SizeInExaBytes(item)
		return StzSizeInExaBytes(item)

	func @SizeInExaBytes(p)
		return StzSizeInExaBytes(p)

	func StzNumberOfExaBytes(p)
		if isList(p) and len(p) = 2 and isString(p[1]) and
		   (p[1] = :In or p[1] = :Of)

			p = p[2]
		ok

		return StzSizeInExaBytes(p)

	func NumberOfExaBytes(p)
		return StzNumberOfExaBytes(p)

	func @NumberOfExaBytes(p)
		return StzNumberOfExaBytes(p)

	func StzCountExaBytes(p)
		return StzNumberOfExaBytes(p)

	func CountExaBytes(p)
		return StzNumberOfExaBytes(p)

	func @CountExaBytes(p)
		return StzNumberOfExaBytes(p)

	#>

func StzSizeInZettaBytes(item)
	return StzBytesToZettaBytes( SizeInBytes(item) )

	#< @FunctionAlternativeForms

	func SizeInZettaBytes(item)
		return StzSizeInZettaBytes(item)

	func @SizeInZettaBytes(p)
		return StzSizeInZettaBytes(p)

	func StzNumberOfZettaBytes(p)
		if isList(p) and len(p) = 2 and isString(p[1]) and
		   (p[1] = :In or p[1] = :Of)

			p = p[2]
		ok

		return StzSizeInZettaBytes(p)

	func NumberOfZettaBytes(p)
		return StzNumberOfZettaBytes(p)

	func @NumberOfZettaBytes(p)
		return StzNumberOfZettaBytes(p)

	func StzCountZettaBytes(p)
		return StzNumberOfZettaBytes(p)

	func CountZettaBytes(p)
		return StzNumberOfZettaBytes(p)

	func @CountZettaBytes(p)
		return StzNumberOfZettaBytes(p)

	#>

func StzSizeInYottaBytes(item)
	return StzBytesToYottaBytes( SizeInBytes(item) )

	#< @FunctionAlternativeForms

	func SizeInYottaBytes(item)
		return StzSizeInYottaBytes(item)

	func @SizeInYottaBytes(p)
		return StzSizeInYottaBytes(p)

	func StzNumberOfYottaBytes(p)
		if isList(p) and len(p) = 2 and isString(p[1]) and
		   (p[1] = :In or p[1] = :Of)

			p = p[2]
		ok

		return StzSizeInYottaBytes(p)

	func NumberOfYottaBytes(p)
		return StzNumberOfYottaBytes(p)

	func @NumberOfYottaBytes(p)
		return StzNumberOfYottaBytes(p)

	func StzCountYottaBytes(p)
		return StzNumberOfYottaBytes(p)

	func CountYottaBytes(p)
		return StzNumberOfYottaBytes(p)

	func @CountYottaBytes(p)
		return StzNumberOfYottaBytes(p)

	#>
