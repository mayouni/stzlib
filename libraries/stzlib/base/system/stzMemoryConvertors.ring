#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~#
#  CONVERTING BETWEEN BYTES, KILOBYTES, MEGABYTES, AND GIGABYTES  #
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~#

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

#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~#
#  CONVERTING BETWEEN BYTES, KILOBYTES, MEGABYTES, AND GIGABYTES  #
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~#

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
