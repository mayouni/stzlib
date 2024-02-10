
# Get inspiration from this great article:
# https://marketsplash.com/tutorials/python/cracking-the-code-of-randomness-pythons-secrets-revealed/

# TODO: Propose examples showing realword applications of randomness:
#	- Generating unique passwords
#	- Randomizing data
#	- Monte Carlo simulations
#	- Randomizing game scanrios
#	- etc

# TODO: Add titles to functions

  /////////////////////////////
 ///   GENERAL FUNCTIONS   ///
////////////////////////////

_nRingMaxRandom = 999_999_999 # Based on my testing of Ring random() function
			      # NOTE: if you seed the Ring random() function
			      # with a value greater than that, you will get NULL
			      # as a result! Example : random(9_999_999_999)

_nRingMaxSeed = 1_999_999_999 # Idem

_nRandomRound = 3	# Defines how many decimals are supported in random01()

func RingMaxRandom()
	return _nRingMaxRandom

	func MaxRingRandom()
		return RingMaxRandom()

func RingMaxSeed()
	return _nRingMaxSeed

	func MaxRingSeed()
		return RingMaxSeed()

func RandomRound()
	return _nRandomRound

	func RandomRoundXT()
		return pow(10, _nRandomRound)

	func SetRandomRound(n)
		if checkParams()
			if NOT isNumber(n)
				StzRaise("Incorrect param type! n must be a number.")
			ok
		ok

		_nRandomRound = n
				
func StzRandom(n)
	if CheckParams()
		if NOT isNumber(n)
			StzRaise("Incorrect param type! n must be a number.")
		ok
	ok

	if n > RingMaxRandom()
		StzRaise("Can't proceed. n must be less then " + MaxRingRandom() + ".")
	ok

	if n = 0
		return 0

	but n > 0
		return ARandomNumberIn(1:n)
	else
		return ARandomNumberIn(n:-1)
	ok

	#--

	func StzRandom01()
		nResult = ARandomNumberBetween(0, RandomRoundXT()) / RandomRoundXT()
		return nResult

	func Random01()
		return StzRandom01()

func StzSRandom(n)
	if CheckParams()
		if NOT isNumber(n)
			StzRaise("Incorrect param type! n must be a number.")
		ok
	ok

	if n > RingMaxSeed()
		StzRaise("Can't proceed. n must be less then " + RingMaxSeed() + ".")
	ok

	return srandom(n)

func StzRandomXT(n, nSeed)
	if CheckParams()
		if NOT isNumber(n)
			StzRaise("Incorrect param type! n must be a number.")
		ok

		if isList(nSeed) and Q(nSeed).IsSeedNamedParam()
			nSeed = nSeed[2]
		ok

		if NOT isNumber(nSeed)
			StzRaise("Incorrect param type! n must be a number.")
		ok
	ok

	SeedRandom(nSeed)
	return StzRandom(n)

	#--

	func StzRandom01XT(nSeed)
		nResult = ARandomNumberBetweenXT(0, RandomRoundXT(), nSeed) / RandomRoundXT()
		return nResult

	func Random01XT(nSeed)
		return StzRandom01XT(nSeed)

func SeedRandom(n)
	if CheckParams()
		if isList(n) and Q(n).IsWithOrByOrUsingNamedParam()
			n = n[2]
		ok
	ok

	if n > RingMaxSeed()
		StzRaise("Can't proceed. n must be less than " + RingMaxSeed() + ".")
	ok

	srandom(n)

#---

func RandomNumber()
	return ring_random( RingMaxRandom() )

	#< @FunctionAlternativeForms

	func ARandomNumber()
		return RandomNumber()

	func AnyRandomNumber()
		return RandomNumber()

	func AnyNumber()
		return RandomNumber()

	#==

	func RandomNumber01()
		return StzNumbers01()

	func ARandomNumber01()
		return StzNumbers01()

	func AnyRandomNumber01()
		return StzNumbers01()

	func AnyNumber01()
		return StzNumbers01()

	#>

func RandomNumberXT(nSeed)
	StzSRandom(nSeed)
	return RandomNumber()

	#< @FunctionAlternativeForms

	func ARandomNumberXT(nSeed)
		return RandomNumberXT(nSeed)

	func AnyRandomNumberXT(nSeed)
		return RandomNumberXT(nSeed)

	func AnyNumberXT(nSeed)
		return RandomNumberXT(nSeed)

	#==

	func RandomNumber01XT(nSeed)
		return StzNumbers01XT(nSeed)

	func ARandomNumber01XT(nSeed)
		return StzNumbers01XT(nSeed)

	func AnyRandomNumber01XT(nSeed)
		return StzNumbers01XT(nSeed)

	func AnyNumber01XT(nSeed)
		return StzNumbers01XT(nSeed)

	#>

#--

func RandomNumberLessThan(n)
	return RandomNumberIn(1 : n)

	#< @FunctionAlternativeForms

	func ARandomNumberLessThan(n)
		return RandomNumberLessThan(n)

	func RandomNumberSmallerThan(n)
		return RandomNumberLessThan(n)

	func ARandomNumberSmallerThan(n)
		return RandomNumberLessThan(n)

	func ANumberSmallerThan(n)
		return RandomNumberLessThan(n)

	func ANumberLessThan(n)
		return RandomNumberLessThan(n)

	func AnyNumberSmallerThan(n)
		return RandomNumberLessThan(n)

	func AnyNumberLessThan(n)
		return RandomNumberLessThan(n)

	#==

	func RandomNumberLessThan01(n)
		i = 0
		while TRUE
			i++
			nRandom = StzRandom01()
			if nRandom < n or i = 1000
				exit
			ok
		end

		nResult = nRandom

		return nResult

	func ARandomNumberLessThan01(n)
		return RandomNumberLessThan01(n)

	func RandomNumberSmallerThan01(n)
		return RandomNumberLessThan01(n)

	func ARandomNumberSmallerThan01(n)
		return RandomNumberLessThan01(n)

	func ANumberSmallerThan01(n)
		return RandomNumberLessThan01(n)

	func ANumberLessThan01(n)
		return RandomNumberLessThan01(n)

	func AnyNumberSmallerThan01(n)
		return RandomNumberLessThan01(n)

	func AnyNumberLessThan01(n)
		return RandomNumberLessThan01(n)

	#>

func RandomNumberLessThanXT(n, nSeed)
	StzSRandom(nSeed)
	return RandomNumberLessThan(n)

	#< @FunctionAlternativeForms

	func ARandomNumberLessThanXT(n, nSeed)
		return RandomNumberLessThanXT(n, nSeed)

	func RandomNumberSmallerThanXT(n, nSeed)
		return RandomNumberLessThanXT(n, nSeed)

	func ARandomNumberSmallerThanXT(n, nSeed)
		return RandomNumberLessThanXT(n, nSeed)

	func ANumberSmallerThanXT(n, nSeed)
		return RandomNumberLessThanXT(n, nSeed)

	func ANumberLessThanXT(n, nSeed)
		return RandomNumberLessThanXT(n, nSeed)

	func AnyNumberSmallerThanXT(n, nSeed)
		return RandomNumberLessThanXT(n, nSeed)

	func AnyNumberLessThanXT(n, nSeed)
		return RandomNumberLessThanXT(n, nSeed)

	#==

	func RandomNumberLessThan01XT(n, nSeed)
		i = 0
		while TRUE
			i++
			nRandom = StzRandom01XT(nSeed)
			if nRandom < n or i = 1000
				exit
			ok
		end

		nResult = nRandom

		return nResult

	func ARandomNumberLessThan01XT(n, nSeed)
		return RandomNumberLessThan01XT(n, nSeed)

	func RandomNumberSmallerThan01XT(n, nSeed)
		return RandomNumberLessThan01XT(n, nSeed)

	func ARandomNumberSmallerThan01XT(n, nSeed)
		return RandomNumberLessThan01XT(n, nSeed)

	func ANumberSmallerThan01XT(n, nSeed)
		return RandomNumberLessThan01XT(n, nSeed)

	func ANumberLessThan01XT(n, nSeed)
		return RandomNumberLessThan01XT(n, nSeed)

	func AnyNumberSmallerThan01XT(n, nSeed)
		return RandomNumberLessThan01XT(n, nSeed)

	func AnyNumberLessThan01XT(n, nSeed)
		return RandomNumberLessThan01XT(n, nSeed)

	#>

#--

func RandomNumberGreaterThan(n)
	return RandomNumberIn(n : MaxRingNumber())

	#< @FunctionAlternativeForms

	func ARandomNumberGreaterThan(n)
		return RandomNumberGreaterThan(n)

	func RandomNumberBiggerThan(n)
		return RandomNumberGreaterThan(n)

	func ARandomNumberBiggerThan(n)
		return RandomNumberGreaterThan(n)

	func ANumberGreaterThan(n)
		return RandomNumberGreaterThan(n)

	func ANumberBiggerThan(n)
		return RandomNumberGreaterThan(n)

	func ANumberLargerThan(n)
		return RandomNumberGreaterThan(n)

	func AnyRandomNumberGreaterThan(n)
		return RandomNumberGreaterThan(n)

	func AnyRandomNumberBiggerThan(n)
		return RandomNumberGreaterThan(n, nSeed)

	func AnyNumberGreaterThan(n)
		return RandomNumberGreaterThan(n)

	func AnyNumberBiggerThan(n)
		return RandomNumberGreaterThan(n)

	func AnyNumberLargerThan(n)
		return RandomNumberGreaterThan(n)

	#==

	func RandomNumberGreaterThan01(n)
		i = 0
		while TRUE
			i++
			nRandom = StzRandom01()
			if nRandom > n or i = 1000
				exit
			ok
		end

		nResult = nRandom

		return nResult

	func ARandomNumberGreaterThan01(n)
		return RandomNumberGreaterThan01(n)

	func RandomNumberBiggerThan01(n)
		return RandomNumberGreaterThan01(n)

	func ARandomNumberBiggerThan01(n)
		return RandomNumberGreaterThan01(n)

	func ANumberGreaterThan01(n)
		return RandomNumberGreaterThan01(n)

	func ANumberBiggerThan01(n)
		return RandomNumberGreaterThan01(n)

	func ANumberLargerThan01(n)
		return RandomNumberGreaterThan01(n)

	func AnyRandomNumberGreaterThan01(n)
		return RandomNumberGreaterThan01(n)

	func AnyRandomNumberBiggerThan01(n)
		return RandomNumberGreaterThan01(n, nSeed)

	func AnyNumberGreaterThan01(n)
		return RandomNumberGreaterThan01(n)

	func AnyNumberBiggerThan01(n)
		return RandomNumberGreaterThan01(n)

	func AnyNumberLargerThan01(n)
		return RandomNumberGreaterThan01(n)

	#>

func RandomNumberGreaterThanXT(n, nSeed)
	StzSRandom(nSeed)
	return RandomNumberGreaterThan(n)

	#< @FunctionAlternativeForms

	func ARandomNumberGreaterThanXT(n, nSeed)
		return RandomNumberGreaterThanXT(n, nSeed)

	func RandomNumberBiggerThanXT(n, nSeed)
		return RandomNumberGreaterThanXT(n, nSeed)

	func ARandomNumberBiggerThanXT(n, nSeed)
		return RandomNumberGreaterThanXT(n, nSeed)

	func ANumberGreaterThanXT(n, nSeed)
		return RandomNumberGreaterThanXT(n, nSeed)

	func ANumberBiggerThanXT(n, nSeed)
		return RandomNumberGreaterThanXT(n, nSeed)

	func ANumberLargerThanXT(n, nSeed)
		return RandomNumberGreaterThanXT(n, nSeed)

	func AnyRandomNumberGreaterThanXT(n, nSeed)
		return RandomNumberGreaterThanXT(n, nSeed)

	func AnyRandomNumberBiggerThanXT(n, nSeed)
		return RandomNumberGreaterThanXT(n, nSeed)

	func AnyNumberGreaterThanXT(n, nSeed)
		return RandomNumberGreaterThanXT(n, nSeed)

	func AnyNumberBiggerThanXT(n, nSeed)
		return RandomNumberGreaterThanXT(n, nSeed)

	func AnyNumberLargerThanXT(n, nSeed)
		return RandomNumberGreaterThanXT(n, nSeed)

	#==

	func RandomNumberGreaterThan01XT(n)
		i = 0
		while TRUE
			i++
			nRandom = StzRandom01XT()
			if nRandom > n or i = 1000
				exit
			ok
		end

		nResult = nRandom

		return nResult

	func ARandomNumberGreaterThan01XT(n)
		return RandomNumberGreaterThan01XT(n)

	func RandomNumberBiggerThan01XT(n)
		return RandomNumberGreaterThan01XT(n)

	func ARandomNumberBiggerThan01XT(n)
		return RandomNumberGreaterThan01XT(n)

	func ANumberGreaterThan01XT(n)
		return RandomNumberGreaterThan01XT(n)

	func ANumberBiggerThan01XT(n)
		return RandomNumberGreaterThan01XT(n)

	func ANumberLargerThan01XT(n)
		return RandomNumberGreaterThan01XT(n)

	func AnyRandomNumberGreaterThan01XT(n)
		return RandomNumberGreaterThan01XT(n)

	func AnyRandomNumberBiggerThan01XT(n)
		return RandomNumberGreaterThan01XT(n, nSeed)

	func AnyNumberGreaterThan01XT(n)
		return RandomNumberGreaterThan01XT(n)

	func AnyNumberBiggerThan01XT(n)
		return RandomNumberGreaterThan01XT(n)

	func AnyNumberLargerThan01XT(n)
		return RandomNumberGreaterThan01XT(n)

	#>

#--

func RandomNumberOtherThan(n)
	nResult = RandomNumberIn(1 : MaxRingNumber())
	if nResult = n
		nResult = n - 1
		if nResult < 0
			nResult = 0
		ok
	ok
	return nResult

	#< @FunctionAlternativeForm

	func ARandomNumberOtherThan(n)
		return RandomNumberOtherThan(n)

	func AnyRandomNumberOtherThan(n)
		return RandomNumberOtherThan(n)

	func ANumberOtherThan(n)
		return RandomNumberOtherThan(n)

	func AnyNumberOtherThan(n)
		return RandomNumberOtherThan(n)

	func NumberOtherThan(n)
		return RandomNumberOtherThan(n)

	#--

	func ARandomNumberExcept(n)
		return RandomNumberOtherThan(n)

	func AnyRandomNumberExcept(n)
		return RandomNumberOtherThan(n)

	func ANumberExcept(n)
		return RandomNumberOtherThan(n)

	func AnyNumberExcept(n)
		return RandomNumberOtherThan(n)

	#==

	func ARandomNumberOtherThan01(n)
		if CheckParams()
			if NOT isNumber(n)
				StzRaise("Incorrect param type! n must be a number")
			ok

			if NOT ( n >= 0 and n <=1 )
				StzRaise("Incorrect value! n must be between 0 and 1.")
			ok
		ok

		while TRUE
			nRandom = ARandomNumbers01()
			if nRandom != n
				exit
			ok
		end

		nResult = nRandom
		return nResult

	func AnyRandomNumberOtherThan01(n)
		return RandomNumberOtherThan01(n)

	func ANumberOtherThan01(n)
		return RandomNumberOtherThan01(n)

	func AnyNumberOtherThan01(n)
		return RandomNumberOtherThan01(n)

	func NumberOtherThan01(n)
		return RandomNumberOtherThan01(n)

	#--

	func ARandomNumberExcept01(n)
		return RandomNumberOtherThan01(n)

	func AnyRandomNumberExcept01(n)
		return RandomNumberOtherThan01(n)

	func ANumberExcept01(n)
		return RandomNumberOtherThan01(n)

	func AnyNumberExcept01(n)
		return RandomNumberOtherThan01(n)

	#>

func RandomNumberOtherThanXT(n, nSeed)
	StzSRandom(nSeed)
	return RandomNumberOtherThan(n)

	#< @FunctionAlternativeForm

	func ARandomNumberOtherThanXT(n, nSeed)
		return RandomNumberOtherThanXT(n, nSeed)

	func AnyRandomNumberOtherThanXT(n, nSeed)
		return RandomNumberOtherThanXT(n, nSeed)

	func ANumberOtherThanXT(n, nSeed)
		return RandomNumberOtherThanXT(n, nSeed)

	func AnyNumberOtherThanXT(n, nSeed)
		return RandomNumberOtherThanXT(n, nSeed)

	func NumberOtherThanXT(n, nSeed)
		return RandomNumberOtherThanXT(n, nSeed)

	#--

	func ARandomNumberExceptXT(n, nSeed)
		return RandomNumberOtherThanXT(n, nSeed)

	func AnyRandomNumberExceptXT(n, nSeed)
		return RandomNumberOtherThanXT(n, nSeed)

	func ANumberExceptXT(n, nSeed)
		return RandomNumberOtherThanXT(n, nSeed)

	func AnyNumberExceptXT(n, nSeed)
		return RandomNumberOtherThanXT(n, nSeed)

	#==

	func ARandomNumberOtherThan01XT(n, nSeed)
		if CheckParams()
			if NOT isNumber(n)
				StzRaise("Incorrect param type! n must be a number")
			ok

			if NOT ( n >= 0 and n <=1 )
				StzRaise("Incorrect value! n must be between 0 and 1.")
			ok
		ok

		while TRUE
			nRandom = ARandomNumbers01XT(nSeed)
			if nRandom != n
				exit
			ok
		end

		nResult = nRandom
		return nResult

	func AnyRandomNumberOtherThan01XT(n, nSeed)
		return RandomNumberOtherThan01XT(n, nSeed)

	func ANumberOtherThan01XT(n, nSeed)
		return RandomNumberOtherThan01XT(n, nSeed)

	func AnyNumberOtherThan01XT(n, nSeed)
		return RandomNumberOtherThan01XT(n, nSeed)

	func NumberOtherThan01XT(n, nSeed)
		return RandomNumberOtherThan01XT(n, nSeed)

	#--

	func ARandomNumberExcept01XT(n, nSeed)
		return RandomNumberOtherThan01XT(n, nSeed)

	func AnyRandomNumberExcept01XT(n, nSeed)
		return RandomNumberOtherThan01XT(n, nSeed)

	func ANumberExcept01XT(n, nSeed)
		return RandomNumberOtherThan01XT(n, nSeed)

	func AnyNumberExcept01XT(n, nSeed)
		return RandomNumberOtherThan01XT(n, nSeed)

	#>

#==

func SomeRandomNumbersGreaterThan(n)
	nRandom = ARandomNumber()
	return NRandomNumbersGreaterThan(nRandom, n)

	#< @FunctionAlternativeForms

	func SomeNumbersGreaterThan(n)
		return SomeRandomNumbersGreaterThan(n)

	func AnyRandomNumbersGreaterThan(n)
		return SomeRandomNumbersGreaterThan(n)

	func AnyNumbersGreaterThan(n)
		return SomeRandomNumbersGreaterThan(n)

	#--

	func SomeRandomNumbersBiggerThan(n)
		return SomeRandomNumbersGreaterThan(n)

	func SomeNumbersBiggerThan(n)
		return SomeRandomNumbersGreaterThan(n)

	func AnyRandomNumbersBiggerThan(n)
		return SomeRandomNumbersGreaterThan(n)

	func AnyNumbersBiggerThan(n)
		return SomeRandomNumbersGreaterThan(n)

	#--

	func RandomNumbersGreaterThan(n)
		return SomeRandomNumbersGreaterThan(n)

	func RandomNumbersBiggerThan(n)
		return SomeRandomNumbersGreaterThan(n)

	#==

	func SomeRandomNumbersGreaterThan01(n)
		/* ... */

	#>

func SomeRandomNumbersGreaterThanXT(n, nSeed)
	StzSRandom(nSeed)
	return SomeRandomNumbersGreaterThan(n)

	#< @FunctionAlternativeForms

	func SomeNumbersGreaterThanXT(n, nSeed)
		return SomeRandomNumbersGreaterThanXT(n, nSeed)

	func AnyRandomNumbersGreaterThanXT(n, nSeed)
		return SomeRandomNumbersGreaterThanXT(n, nSeed)

	func AnyNumbersGreaterThanXT(n, nSeed)
		return SomeRandomNumbersGreaterThanXT(n, nSeed)

	#--

	func SomeRandomNumbersBiggerThanXT(n, nSeed)
		return SomeRandomNumbersGreaterThanXT(n, nSeed)

	func SomeNumbersBiggerThanXT(n, nSeed)
		return SomeRandomNumbersGreaterThanXT(n, nSeed)

	func AnyRandomNumbersBiggerThanXT(n, nSeed)
		return SomeRandomNumbersGreaterThanXT(n, nSeed)

	func AnyNumbersBiggerThanXT(n, nSeed)
		return SomeRandomNumbersGreaterThanXT(n, nSeed)

	#==

	func RandomNumbersGreaterThanXT(n, nSeed)
		return SomeRandomNumbersGreaterThanXT(n, nSeed)

	func RandomNumbersBiggerThanXT(n, nSeed)
		return SomeRandomNumbersGreaterThanXT(n, nSeed)

	#>

#--

func SomeRandomNumbersGreaterThanU(nValue)
	n = ARandomNumber()
	return NRandomNumbersGreaterThanU(n, nValue)

	#< @FunctionAlternativeForms

	func SomeNumbersGreaterThanU(nValue)
		return SomeRandomNumbersGreaterThanU(nValue)

	func AnyRandomNumbersGreaterThanU(nValue)
		return SomeRandomNumbersGreaterThanU(nValue)

	func AnyNumbersGreaterThanU(nValue)
		return SomeRandomNumbersGreaterThanU(nValue)

	#--

	func SomeRandomNumbersBiggerThanU(nValue)
		return SomeRandomNumbersGreaterThanU(nValue)

	func SomeNumbersBiggerThanU(nValue)
		return SomeRandomNumbersGreaterThanU(nValue)

	func AnyRandomNumbersBiggerThanU(nValue)
		return SomeRandomNumbersGreaterThanU(nValue)

	func AnyNumbersBiggerThanU(nValue)
		return SomeRandomNumbersGreaterThanU(nValue)

	#==

	func SomeUniqueRandomNumbersGreaterThanU(nValue)
		return SomeRandomNumbersGreaterThanU(nValue)

	func SomeUniqueNumbersGreaterThanU(nValue)
		return SomeRandomNumbersGreaterThanU(nValue)

	#--

	func SomeUniqueRandomNumbersBiggerThanU(nValue)
		return SomeRandomNumbersGreaterThanU(nValue)

	func SomeUniqueNumbersBiggerThanU(nValue)
		return SomeRandomNumbersGreaterThanU(nValue)

	#==

	func RandomNumbersGreaterThanU(nValue)
		return SomeRandomNumbersGreaterThanU(nValue)

	func RandomNumbersBiggerThanU(nValue)
		return SomeRandomNumbersGreaterThanU(nValue)

	func UniqueRandomNumbersGreaterThan(nValue)
		return SomeRandomNumbersGreaterThanU(nValue)

	func UniqueRandomNumbersBiggerThan(nValue)
		return SomeRandomNumbersGreaterThanU(nValue)

	#>

func SomeRandomNumbersGreaterThanXTU(n, nValue, nSeed)
	StzSRandom(nSeed)
	return NRandomNumbersGreaterThanU(n, nValue)

	#< @FunctionAlternativeForms

	func SomeNumbersGreaterThanXTU(nValue, nSeed)
		return SomeRandomNumbersGreaterThanXTU(nValue, nSeed)

	func AnyRandomNumbersGreaterThanXTU(nValue, nSeed)
		return SomeRandomNumbersGreaterThanXTU(nValue, nSeed)

	func AnyNumbersGreaterThanXTU(nValue, nSeed)
		return SomeRandomNumbersGreaterThanXTU(nValue, nSeed)

	#--

	func SomeRandomNumbersBiggerThanXTU(nValue, nSeed)
		return SomeRandomNumbersGreaterThanXTU(nValue, nSeed)

	func SomeNumbersBiggerThanXTU(nValue, nSeed)
		return SomeRandomNumbersGreaterThanXTU(nValue, nSeed)

	func AnyRandomNumbersBiggerThanXTU(nValue, nSeed)
		return SomeRandomNumbersGreaterThanXTU(nValue, nSeed)

	func AnyNumbersBiggerThanXTU(nValue, nSeed)
		return SomeRandomNumbersGreaterThanXTU(nValue, nSeed)

	#==

	func SomeUniqueRandomNumbersGreaterThanXTU(nValue, nSeed)
		return SomeRandomNumbersGreaterThanXTU(nValue, nSeed)

	func SomeUniqueNumbersGreaterThanXTU(nValue, nSeed)
		return SomeRandomNumbersGreaterThanXTU(nValue, nSeed)

	#--

	func SomeUniqueRandomNumbersBiggerThanXTU(nValue, nSeed)
		return SomeRandomNumbersGreaterThanXTU(nValue, nSeed)

	func SomeUniqueNumbersBiggerThanXTU(nValue, nSeed)
		return SomeRandomNumbersGreaterThanXTU(nValue, nSeed)

	#==

	func RandomNumbersGreaterThanXTU(nValue, nSeed)
		return SomeRandomNumbersGreaterThanXTU(nValue, nSeed)

	func RandomNumbersBiggerThanXTU(nValue, nSeed)
		return SomeRandomNumbersGreaterThanXTU(nValue, nSeed)

	func UniqueRandomNumbersGreaterThanXT(nValue, nSeed)
		return SomeRandomNumbersGreaterThanXT(nValue, nSeed)

	func UniqueRandomNumbersBiggerThanXT(nValue, nSeed)
		return SomeRandomNumbersGreaterThanXT(nValue, nSeed)

	#>


#==

func NRandomNumbersGreaterThan(n, nValue)
	if NOT (isNumber(n) and isNumber(nValue))
		StzRaise("Incorrect param type! n and nValue must be numbers.")
	ok

	anResult = []
	for i = 1 to n
		anResult + ARandomNumberGreaterThan(nValue)
	next

	anResult = ring_sort(anResult)

	return anResult

	#< @FunctionAlternativeForm

	func NRandomNumbersLargerThan(n, nValue)
		return NRandomNumbersGreaterThan(n, nValue)

	func NRandomNumbersBiggerThan(n, nValue)
		return NRandomNumbersGreaterThan(n, nValue)


	func NNumbersGreaterThan(n, nValue)
		return NRandomNumbersGreaterThan(n, nValue)

	func NNumbersLargerThan(n, nValue)
		return NRandomNumbersGreaterThan(n, nValue)

	func NNumbersBiggerThan(n, nValue)
		return NRandomNumbersGreaterThan(n, nValue)


	func AnyNNumbersGreaterThan(n, nValue)
		return NRandomNumbersGreaterThan(n, nValue)

	func AnyNNumbersLargerThan(n, nValue)
		return NRandomNumbersGreaterThan(n, nValue)

	func AnyNNumbersBiggerThan(n, nValue)
		return NRandomNumbersGreaterThan(n, nValue)

	#>

func NRandomNumbersGreaterThanXT(n, nValue, nSeed)
	StzSRandom(nSeed)
	return NRandomNumbersGreaterThan(n, nValue)

	#< @FunctionAlternativeForm

	func NRandomNumbersLargerThanXT(n, nValue, nSeed)
		return NRandomNumbersGreaterThanXT(n, nValue, nSeed)

	func NRandomNumbersBiggerThanXT(n, nValue, nSeed)
		return NRandomNumbersGreaterThanXT(n, nValue, nSeed)


	func NNumbersGreaterThanXT(n, nValue, nSeed)
		return NRandomNumbersGreaterThanXT(n, nValue, nSeed)

	func NNumbersLargerThanXT(n, nValue, nSeed)
		return NRandomNumbersGreaterThanXT(n, nValue, nSeed)

	func NNumbersBiggerThanXT(n, nValue, nSeed)
		return NRandomNumbersGreaterThanXT(n, nValue, nSeed)


	func AnyNNumbersGreaterThanXT(n, nValue, nSeed)
		return NRandomNumbersGreaterThanXT(n, nValue, nSeed)

	func AnyNNumbersLargerThanXT(n, nValue, nSeed)
		return NRandomNumbersGreaterThanXT(n, nValue, nSeed)

	func AnyNNumbersBiggerThanXT(n, nValue, nSeed)
		return NRandomNumbersGreaterThanXT(n, nValue, nSeed)

	#>

func NRandomNumbersGreaterThanU(n, nValue)
	if NOT (isNumber(n) and isNumber(nValue))
		StzRaise("Incorrect param type! n and nValue must be numbers.")
	ok

	anResult = []

	while TRUE

		nRandom = ARandomNumberGreaterThan(nValue)

		if ring_find(anResult, nRandom) = 0
			anResult + nRandom
			if len(anResult) = n
				exit
			ok
		ok

	end

	anResult = ring_sort(anResult)

	return anResult

	#< @FunctionAlternativeForm

	func NRandomNumbersLargerThanU(n, nValue)
		return NRandomNumbersGreaterThanU(n, nValue)

	func NRandomNumbersBiggerThanU(n, nValue)
		return NRandomNumbersGreaterThanU(n, nValue)

	func NNumbersGreaterThanU(n, nValue)
		return NRandomNumbersGreaterThanU(n, nValue)

	func NNumbersLargerThanU(n, nValue)
		return NRandomNumbersGreaterThanU(n, nValue)

	func NNumbersBiggerThanU(n, nValue)
		return NRandomNumbersGreaterThanU(n, nValue)

	func AnyNNumbersGreaterThanU(n, nValue)
		return NRandomNumbersGreaterThanU(n, nValue)

	func AnyNNumbersLargerThanU(n, nValue)
		return NRandomNumbersGreaterThanU(n, nValue)

	func AnyNNumbersBiggerThanU(n, nValue)
		return NRandomNumbersGreaterThanU(n, nValue)

	#--

	func NUniqueRandomNumbersGreaterThan(n, nValue)
		return NRandomNumbersGreaterThanU(n, nValue)

	func NUniqueRandomNumbersLargerThan(n, nValue)
		return NRandomNumbersGreaterThanU(n, nValue)

	func NUniqueRandomNumbersBiggerThan(n, nValue)
		return NRandomNumbersGreaterThanU(n, nValue)

	func NUniqueNumbersGreaterThan(n, nValue)
		return NRandomNumbersGreaterThanU(n, nValue)

	func NUniqueNumbersLargerThan(n, nValue)
		return NRandomNumbersGreaterThanU(n, nValue)

	func NUniqueNumbersBiggerThan(n, nValue)
		return NRandomNumbersGreaterThanU(n, nValue)

	#>

func NRandomNumbersGreaterThanXTU(n, nValue, nSeed)
	StzSRandom(nSeed)
	return NRandomNumbersGreaterThanU(n, nValue)

	#< @FunctionAlternativeForm

	func NRandomNumbersLargerThanXTU(n, nValue, nSeed)
		return NRandomNumbersGreaterThanXTU(n, nValue, nSeed)

	func NRandomNumbersBiggerThanXTU(n, nValue, nSeed)
		return NRandomNumbersGreaterThanXTU(n, nValue, nSeed)


	func NNumbersGreaterThanXTU(n, nValue, nSeed)
		return NRandomNumbersGreaterThanXT(n, nValue, nSeed)

	func NNumbersLargerThanXTU(n, nValue, nSeed)
		return NRandomNumbersGreaterThanXTU(n, nValue, nSeed)

	func NNumbersBiggerThanXTU(n, nValue, nSeed)
		return NRandomNumbersGreaterThanXTU(n, nValue, nSeed)


	func AnyNNumbersGreaterThanXTU(n, nValue, nSeed)
		return NRandomNumbersGreaterThanXTU(n, nValue, nSeed)

	func AnyNNumbersLargerThanXTU(n, nValue, nSeed)
		return NRandomNumbersGreaterThanXTU(n, nValue, nSeed)

	func AnyNNumbersBiggerThanXTU(n, nValue, nSeed)
		return NRandomNumbersGreaterThanXTU(n, nValue, nSeed)

	#--

	func NUniqueRandomNumbersGreaterThanXT(n, nValue, nSeed)
		return NRandomNumbersGreaterThanXTU(n, nValue, nSeed)

	func NUniqueRandomNumbersLargerThanXT(n, nValue, nSeed)
		return NRandomNumbersGreaterThanXTU(n, nValue, nSeed)

	func NUniqueRandomNumbersBiggerThanXT(n, nValue, nSeed)
		return NRandomNumbersGreaterThanXTU(n, nValue, nSeed)

	func NUniqueNumbersGreaterThanXT(n, nValue, nSeed)
		return NRandomNumbersGreaterThanXTU(n, nValue, nSeed)

	func NUniqueNumbersLargerThanXT(n, nValue, nSeed)
		return NRandomNumbersGreaterThanXTU(n, nValue, nSeed)

	func NUniqueNumbersBiggerThanXT(n, nValue, nSeed)
		return NRandomNumbersGreaterThanXTU(n, nValue, nSeed)

	#>

#==

func NRandomNumbersLessThan(n, nValue)
	if NOT (isNumber(n) and isNumber(nValue))
		StzRaise("Incorrect param type! n and nValue must be numbers.")
	ok

	anResult = []
	for i = 1 to n
		anResult + ARandomNumberLessThan(nValue)
	next

	anResult = ring_sort(anResult)

	return anResult

	#< @FunctionAlternativeForm

	func NRandomNumbersSmallerThan(n, nValue)
		return NRandomNumbersGreaterThan(n, nValue)


	func NNumbersLessThan(n, nValue)
		return NRandomNumbersLessThan(n, nValue)

	func NNumbersSmallerThan(n, nValue)
		return NRandomNumbersGreaterThan(n, nValue)

	func AnyNNumbersLessThan(n, nValue)
		return NRandomNumbersLessThan(n, nValue)

	func AnyNNumbersSmallerThan(n, nValue)
		return NRandomNumbersGreaterThan(n, nValue)

	#>

func NRandomNumbersLessThanXT(n, nValue, nSeed)
	StzSRandom(nSeed)
	return NRandomNumbersLessThan(n, nValue)

	#< @FunctionAlternativeForm

	func NRandomNumbersSmallerThanXT(n, nValue, nSeed)
		return NRandomNumbersGreaterThanXT(n, nValue, nSeed)


	func NNumbersLessThanXT(n, nValue, nSeed)
		return NRandomNumbersLessThanXT(n, nValue, nSeed)

	func NNumbersSmallerThanXT(n, nValue, nSeed)
		return NRandomNumbersGreaterThanXT(n, nValue, nSeed)

	func AnyNNumbersLessThanXT(n, nValue, nSeed)
		return NRandomNumbersLessThanXT(n, nValue, nSeed)

	func AnyNNumbersSmallerThanXT(n, nValue, nSeed)
		return NRandomNumbersGreaterThanXT(n, nValue, nSeed)

	#>

func NRandomNumbersLessThanU(n, nValue)
	if NOT (isNumber(n) and isNumber(nValue))
		StzRaise("Incorrect param type! n and nValue must be numbers.")
	ok

	anResult = []

	while TRUE

		nRandom = ARandomNumberLessThan(nValue)

		if ring_find(anResult, nRandom) = 0
			anResult + nRandom
			if len(anResult) = n
				exit
			ok
		ok

	end

	anResult = ring_sort(anResult)

	return anResult

	#< @FunctionAlternativeForm

	func NNumbersLessThanU(n, nValue)
		return NRandomNumbersLessThanU(n, nValue)

	func NNumbersSmallerThanU(n, nValue)
		return NRandomNumbersLessThanU(n, nValue)

	func AnyNNumbersLessThanU(n, nValue)
		return NRandomNumbersLessThanU(n, nValue)

	func AnyNNumbersSmallerThanU(n, nValue)
		return NRandomNumbersLessThanU(n, nValue)

	#--

	func NUniqueRandomNumbersLessThan(n, nValue)
		return NRandomNumbersLessThanU(n, nValue)

	func NUniqueRandomNumbersSmallerThan(n, nValue)
		return NRandomNumbersLessThanU(n, nValue)


	func NUniqueNumbersLessThan(n, nValue)
		return NRandomNumbersLessThanU(n, nValue)

	func NUniqueNumbersSmallerThan(n, nValue)
		return NRandomNumbersLessThanU(n, nValue)

	#>

func NRandomNumbersLessThanXTU(n, nValue, nSeed)
	StzSRandom(nSeed)
	return NRandomNumbersLessThanU(n, nValue)

	#< @FunctionAlternativeForm

	func NNumbersLessThanXTU(n, nValue)
		return NRandomNumbersLessThanXTU(n, nValue)

	func NNumbersSmallerThanXTU(n, nValue)
		return NRandomNumbersLessThanXTU(n, nValue)

	func AnyNNumbersLessThanXTU(n, nValue)
		return NRandomNumbersLessThanXTU(n, nValue)

	func AnyNNumbersSmallerThanXTU(n, nValue)
		return NRandomNumbersLessThanXTU(n, nValue)

	#--

	func NUniqueRandomNumbersLessThanXT(n, nValue)
		return NRandomNumbersLessThanXTU(n, nValue)

	func NUniqueRandomNumbersSmallerThanXT(n, nValue)
		return NRandomNumbersLessThanXTU(n, nValue)


	func NUniqueNumbersLessThanXT(n, nValue)
		return NRandomNumbersLessThanXTU(n, nValue)

	func NUniqueNumbersSmallerThanXT(n, nValue)
		return NRandomNumbersLessThanXTU(n, nValue)

	#>
#==

#== A RANDOM NUMBER AMONG THE NUMBERS IN A LIST

func RandomNumberIn(panNumbers)
	if NOT isList(panNumbers)
		StzRaise("Incorrect param type! panNumbers must be a list.")
	ok

	nLen = len(panNumbers)
	anNumbers = []
	for i = 1 to nLen
		if isNumber(panNumbers[i])
			anNumbers + panNumbers[i]
		ok
	next

	nLen = len(anNumbers)
	nPos = ring_random(nLen)

	if nPos = 0
		nPos = 1
	ok

	nResult = anNumbers[nPos]

	return nResult

	#< @FunctionAlternativeForms

	func ARandomNumberIn(panNumbers)
		return RandomNumberIn(panNumbers)

	func ANumberIn(panNumbers)
		return RandomNumberIn(panNumbers)

	func AnyNumberIn(panNumbers)
		return RandomNumberIn(panNumbers)

	func AnyRandomNumberIn(panNumbers)
		return RandomNumberIn(panNumbers)

	#==

	func RandomNumberBetween(nMin, nMax)
		if CheckParams()
			if NOT BothAreNumbers(nMin, nMax)
				StzRaise("Incorrect params types! nMin and nMax must be numbers.")
			ok
		ok

		return RandomNumberIn(nMin:nMax)

	func ARandomNumberBetween(nMin, nMax)
		return RandomNumberBetween(nMin, nMax)

	func ANumberBetween(nMin, nMax)
		return RandomNumberBetween(nMin, nMax)

	func AnyNumberBetween(nMin, nMax)
		return RandomNumberBetween(nMin, nMax)

	func AnyRandomNumberBetween(nMin, nMax)
		return RandomNumberBetween(nMin, nMax)

	#>

#--

func RandomNumberInZ(panNumbers)
	if NOT isList(panNumbers)
		StzRaise("Incorrect param type! panNumbers must be a list.")
	ok

	nLen = len(panNumbers)
	anNumbers = []

	for i = 1 to nLen
		if isNumber(panNumbers[i])
			anNumbers + panNumbers[i]
		ok
	next

	nLen = len(anNumbers)
	nPos = ring_random(nLen)

	if nPos = 0
		nPos = 1
	ok

	aResult = [ anNumbers[nPos], nPos ]

	return aResult

	#< @FunctionAlternativeForms

	func ARandomNumberInZ(panNumbers)
		return RandomNumberInZ(panNumbers)

	func ANumberInZ(panNumbers)
		return RandomNumberInZ(panNumbers)

	func AnyNumberInZ(panNumbers)
		return RandomNumberInZ(panNumbers)

	func AnyRandomNumberInZ(panNumbers)
		return RandomNumberIn(panNumbers)

	#==

	func RandomNumberBetweenZ(nMin, nMax)
		if CheckParams()
			if NOT BothAreNumbers(nMin, nMax)
				StzRaise("Incorrect params types! nMin and nMax must be numbers.")
			ok
		ok

		return RandomNumberInZ(nMin:nMax)

	func ARandomNumberBetweenZ(nMin, nMax)
		return RandomNumberBetweenZ(nMin, nMax)

	func ANumberBetweenZ(nMin, nMax)
		return RandomNumberBetweenZ(nMin, nMax)

	func AnyNumberBetweenZ(nMin, nMax)
		return RandomNumberBetweenZ(nMin, nMax)

	func AnyRandomNumberBetweenZ(nMin, nMax)
		return RandomNumberBetweenZ(nMin, nMax)

	#>

#==

func RandomNumberInXT(panNumbers, nSeed)
	StzSRandom(nSeed)
	nResult = StzRandomNumberIn(panNumbers)

	return nResult

	#< @FunctionAlternativeForms

	func ARandomNumberInXT(panNumbers, nSeed)
		return RandomNumberInXT(panNumbers, nSeed)

	func ANumberInXT(panNumbers, nSeed)
		return RandomNumberInXt(panNumbers, nSeed)

	func AnyNumberInXT(panNumbers, nSeed)
		return RandomNumberInXT(panNumbers, nSeed)

	func AnyRandomNumberInXT(panNumbers, nSeed)
		return RandomNumberInXT(panNumbers, nSeed)

	#==

	func RandomNumberBetweenXT(nMin, nMax, nSeed)
		if CheckParams()
			if NOT BothAreNumbers(nMin, nMax)
				StzRaise("Incorrect params types! nMin and nMax must be numbers.")
			ok
		ok

		return NRandomNumberInXT(nMin:nMax, nSeed)

	func ARandomNumberBetweenXT(nMin, nMax, nSeed)
		return RandomNumberBetweenXT(nMin, nMax, nSeed)

	func ANumberBetweenXT(nMin, nMax, nSeed)
		return RandomNumberBetweenXT(nMin, nMax, nSeed)

	func AnyNumberBetweenXT(nMin, nMax, nSeed)
		return RandomNumberBetweenXT(nMin, nMax, nSeed)

	func AnyRandomNumberBetweenXT(nMin, nMax, nSeed)
		return RandomNumberBetweenXT(nMin, nMax, nSeed)

	#>

func RandomNumberInXTZ(panNumbers, nSeed)
	if CheckParams()

		if NOT ( isList(panNumbers) and IsListOfNumbers(panNumbers) )
			StzRaise("Incorrect param type! panNumbers must be a list of numbers.")
		ok

	ok

	StzSRandom(nSeed)
	nPos = ARandomNumberIn(1:len(panNumbers))
	aResult = [ panNumbers[nPos], nPos ]
	return aResult

	#< @FunctionAlternativeForms

	func ARandomNumberInXTZ(panNumbers, nSeed)
		return RandomNumberInXTZ(panNumbers, nSeed)

	func ANumberInXTZ(panNumbers, nSeed)
		return RandomNumberInXTZ(panNumbers, nSeed)

	func AnyNumberInXTZ(panNumbers, nSeed)
		return RandomNumberInXTZ(panNumbers, nSeed)

	func AnyRandomNumberInXTZ(panNumbers, nSeed)
		return RandomNumberInXTZ(panNumbers, nSeed)

	#==

	func RandomNumberBetweenXTZ(nMin, nMax, nSeed)
		if CheckParams()
			if NOT BothAreNumbers(nMin, nMax)
				StzRaise("Incorrect params types! nMin and nMax must be numbers.")
			ok
		ok

		return NRandomNumberInXTZ(nMin:nMax, nSeed)

	func ARandomNumberBetweenXTZ(nMin, nMax, nSeed)
		return SomeRandomNumberBetweenXTZ(nMin, nMax, nSeed)

	func ANumberBetweenXTZ(nMin, nMax, nSeed)
		return ARandomNumberBetweenXTZ(nMin, nMax, nSeed)

	func AnyNumberBetweenXTZ(nMin, nMax, nSeed)
		return ARandomNumberBetweenXTZ(nMin, nMax, nSeed)

	func AnyRandomNumberBetweenXTZ(nMin, nMax, nSeed)
		return ARandomNumberBetweenXTZ(nMin, nMax, nSeed)

	#>

#==

func SomeRandomNumbersIn(panNumbers)
	if CheckParams()
		if NOT ( isList(panNumbers) and IsListOfNumbers(panNumbers) )
			StzRaise("Incorrect param type! panNumbers.")
		ok
	ok

	n = ARandomNumberIn(1:len(panNumbers))
	return NRandomNumbersIn(n, panNumbers)

	#< @FunctionAlternativeForms

	func SomeNumbersIn(panNumbers)
		return SomeRandomNumbersIn(panNumbers)

	func AnyRandomNumbersIn(panNumbers)
		return SomeRandomNumbersIn(panNumbers)

	func AnyNumbersIn(panNumbers)
		return SomeRandomNumbersIn(panNumbers)

	#--

	func RandomNumbersIn(panNumbers)
		return SomeRandomNumbersIn(panNumbers)

	#==

	func SomeRandomNumbersBetween(nMin, nMax)
		if CheckParams()
			if NOT BothAreNumbers(nMin, nMax)
				StzRaise("Incorrect params types! nMin and nMax must be numbers.")
			ok
		ok

		return SomeRandomNumbersIn(nMin : nMax)

	func SomeNumbersBetween(nMin, nMax)
		return SomeRandomNumbersBetween(nMin, nMax)

	func AnyRandomNumbersBetween(nMin, nMax)
		return SomeRandomNumbersBetween(nMin, nMax)

	func AnyNumbersBetween(nMin, nMax)
		return SomeRandomNumbersBetween(nMin, nMax)

	#--

	func RandomNumbersBetween(nMin, nMax)
		return SomeRandomNumbersBetween(nMin, nMax)

	#>

func SomeRandomNumbersInZ(panNumbers)
	if CheckParams()
		if NOT ( isList(panNumbers) and IsListOfNumbers(panNumbers) )
			StzRaise("Incorrect param type! panNumbers.")
		ok
	ok

	n = ARandomNumberIn(1:len(panNumbers))
	return NRandomNumbersInZ(n, panNumbers)

	#< @FunctionAlternativeForms

	func SomeNumbersInZ(panNumbers)
		return RandomNumbersInZ(panNumbers)

	func AnyRandomNumbersInZ(panNumbers)
		return RandomNumbersInZ(panNumbers)

	func AnyNumbersInZ(panNumbers)
		return RandomNumbersInZ(panNumbers)

	#--

	func RandomNumbersInZ(panNumbers)
		return RandomNumbersInZ(panNumbers)

	#==

	func SomeRandomNumbersBetweenZ(nMin, nMax)
		if CheckParams()
			if NOT BothAreNumbers(nMin, nMax)
				StzRaise("Incorrect params types! nMin and nMax must be numbers.")
			ok
		ok

		return SomeRandomNumbersInZ(nMin : nMax)

	func SomeNumbersBetweenZ(nMin, nMax)
		return RandomNumbersBetweenZ(nMin, nMax)

	func AnyRandomNumbersBetweenZ(nMin, nMax)
		return RandomNumbersBetweenZ(nMin, nMax)

	func AnyNumbersBetweenZ(nMin, nMax)
		return RandomNumbersBetweenZ(nMin, nMax)

	#--

	func RandomNumbersBetweenZ(nMin, nMax)
		return RandomNumbersBetweenZ(nMin, nMax)

	#>

#==

func SomeRandomNumbersInXT(panNumbers, nSeed)
	StzSRandom(nSeed)
	return SomeRandomNumbersIn(panNumbers)

	#< @FunctionAlternativeForms

	func SomeNumbersInXT(panNumbers, nSeed)
		return SomeRandomNumbersInXT(panNumbers, nSeed)

	func AnyRandomNumbersInXT(panNumbers, nSeed)
		return SomeRandomNumbersInXT(panNumbers, nSeed)

	func AnyNumbersInXT(panNumbers, nSeed)
		return SomeRandomNumbersInXT(panNumbers, nSeed)

	#--

	func RandomNumbersInXT(panNumbers, nSeed)
		return SomeRandomNumbersInXT(panNumbers, nSeed)

	#==

	func SomeRandomNumbersBetweenXT(nMin, nMax, nSeed)
		if CheckParams()
			if NOT BothAreNumbers(nMin, nMax)
				StzRaise("Incorrect params types! nMin and nMax must be numbers.")
			ok
		ok

		return SomeRandomNumbersInXT(nMin : nMax, nSeed)

	func SomeNumbersBetweenXT(nMin, nMax, nSeed)
		return SomeRandomNumbersBetweenXT(nMin, nMax, nSeed)

	func AnyRandomNumbersBetweenXT(nMin, nMax, nSeed)
		return SomeRandomNumbersBetweenXT(nMin, nMax, nSeed)

	func AnyNumbersBetweenXT(nMin, nMax, nSeed)
		return SomeRandomNumbersBetweenXT(nMin, nMax, nSeed)

	#--

	func RandomNumbersBetweenXT(nMin, nMax, nSeed)
		return SomeRandomNumbersBetweenXT(nMin, nMax, nSeed)

	#>

func SomeRandomNumbersInXTZ(panNumbers, nSeed)
	StzSRandom(nSeed)
	return SomeRandomNumbersInZ(panNumbers)

	#< @FunctionAlternativeForms

	func SomeNumbersInXTZ(panNumbers, nSeed)
		return SomeRandomNumbersInXTZ(panNumbers, nSeed)

	func AnyRandomNumbersInXTZ(panNumbers, nSeed)
		return SomeRandomNumbersInXTZ(panNumbers, nSeed)

	func AnyNumbersInXTZ(panNumbers, nSeed)
		return SomeRandomNumbersInXTZ(panNumbers, nSeed)

	#--

	func RandomNumbersInXTZ(panNumbers, nSeed)
		return SomeRandomNumbersInXTZ(panNumbers, nSeed)

	#==

	func SomeRandomNumbersBetweenXTZ(nMin, nMax, nSeed)
		if CheckParams()
			if NOT BothAreNumbers(nMin, nMax)
				StzRaise("Incorrect params types! nMin and nMax must be numbers.")
			ok
		ok

		return SomeRandomNumbersInXTZ(nMin : nMax, nSeed)

	func SomeNumbersBetweenXTZ(nMin, nMax, nSeed)
		return SomeRandomNumbersBetweenXTZ(nMin, nMax, nSeed)

	func AnyRandomNumbersBetweenXTZ(nMin, nMax, nSeed)
		return SomeRandomNumbersBetweenXTZ(nMin, nMax, nSeed)

	func AnyNumbersBetweenXTZ(nMin, nMax, nSeed)
		return SomeRandomNumbersBetweenXTZ(nMin, nMax, nSeed)

	#--

	func RandomNumbersBetweenXTZ(nMin, nMax, nSeed)
		return SomeRandomNumbersBteweenXTZ(nMin, nMax, nSeed)

	#>

#==

func SomeRandomNumbersInU(panNumbers)
	if CheckParams()
		if NOT ( isList(panNumbers) and IsListOfNumbers(panNumbers) )
			StzRaise("Incorrect param type! panNumbers.")
		ok
	ok

	n = ARandomNumberIn( 1: len(panNumbers) )
	return NRandomNumbersInU(n, panNumbers)

	#< @FunctionAlternativeForms

	func SomeNumbersInU(panNumbers)
		return SomeRandomNumbersInU(panNumbers)

	func AnyRandomNumbersInU(panNumbers)
		return SomeRandomNumbersInU(panNumbers)

	func AnyNumbersInU(panNumbers)
		return SomeRandomNumbersInU(panNumbers)

	#--

	func UniqueRandomNumbersIn(panNumbers)
		return SomeRandomNumbersInU(panNumbers)

	func SomeUniqueNumbersIn(panNumbers)
		return SomeRandomNumbersInU(panNumbers)

	#--

	func RandomNumbersInU(panNumbers)
		return SomeRandomNumbersInU(panNumbers)

	#==

	func SomeRandomNumbersBetweenU(nMin, nMax)
		if CheckParams()
			if NOT BothAreNumbers(nMin, nMax)
				StzRaise("Incorrect params types! nMin and nMax must be numbers.")
			ok
		ok
		return SomeRandomNumbersInU(nMin : nMax)

	func SomeNumbersBetweenU(nMin, nMax)
		return SomeRandomNumbersBetweenU(nMin, nMax)

	func AnyRandomNumbersBetweenU(nMin, nMax)
		return SomeRandomNumbersBetweenU(nMin, nMax)

	func AnyNumbersBetweenU(nMin, nMax)
		return SomeRandomNumbersBetweenU(nMin, nMax)

	#--

	func UniqueRandomNumbersBetween(nMin, nMax)
		return SomeRandomNumbersBetweenU(nMin, nMax)

	func SomeUniqueNumbersBetween(nMin, nMax)
		return SomeRandomNumbersBetweenU(nMin, nMax)

	#--

	func RandomNumbersBetweenU(nMin, nMax)
		return SomeRandomNumbersBetweenU(nMin, nMax)

	#>

func SomeRandomNumbersInUZ(panNumbers)
	if CheckParams()
		if NOT ( isList(panNumbers) and IsListOfNumbers(panNumbers) )
			StzRaise("Incorrect param type! panNumbers.")
		ok
	ok

	n = ARandomNumberIn( 1: len(panNumbers) )
	return NRandomNumbersInUZ(n, panNumbers)

	#< @FunctionAlternativeForms

	func SomeNumbersInUZ(panNumbers)
		return SomeRandomNumbersInUZ(panNumbers)

	func AnyRandomNumbersInUZ(panNumbers)
		return SomeRandomNumbersInUZ(panNumbers)

	func AnyNumbersInUZ(panNumbers)
		return SomeRandomNumbersInUZ(panNumbers)

	#--

	func UniqueRandomNumbersInZ(panNumbers)
		return SomeRandomNumbersInUZ(panNumbers)

	func SomeUniqueNumbersInZ(panNumbers)
		return SomeRandomNumbersInUZ(panNumbers)

	#--

	func RandomNumbersInUZ(nMin, nMax)
		return SomeRandomNumbersInUZ(panNumbers)

	#==

	func SomeRandomNumbersBetweenUZ(nMin, nMax)
		if CheckParams()
			if NOT BothAreNumbers(nMin, nMax)
				StzRaise("Incorrect params types! nMin and nMax must be numbers.")
			ok
		ok
		return SomeRandomNumbersInUZ(nMin : nMax)

	func SomeNumbersBetweenUZ(nMin, nMax)
		return SomeRandomNumbersBetweenUZ(nMin, nMax)

	func AnyRandomNumbersBetweenUZ(nMin, nMax)
		return SomeRandomNumbersBetweenUZ(nMin, nMax)

	func AnyNumbersBetweenUZ(nMin, nMax)
		return SomeRandomNumbersBetweenUZ(nMin, nMax)

	#--

	func UniqueRandomNumbersBetweenZ(nMin, nMax)
		return SomeRandomNumbersBetweenUZ(nMin, nMax)

	func SomeUniqueNumbersBetweenZ(nMin, nMax)
		return SomeRandomNumbersBetweenUZ(nMin, nMax)

	#--

	func RandomNumbersBetweenUZ(nMin, nMax)
		return SomeRandomNumbersBetweenUZ(nMin, nMax)

	#>

#==

func SomeRandomNumbersInXTU(panNumbers, nSeed)
	StzSRandom(nSeed)
	return SomeRandomNumbersInU(panNumbers)

	#< @FunctionAlternativeForms

	func SomeNumbersInXTU(panNumbers, nSeed)
		return SomeRandomNumbersInXTU(panNumbers, nSeed)

	func AnyRandomNumbersInXTU(panNumbers, nSeed)
		return SomeRandomNumbersInXTU(panNumbers, nSeed)

	func AnyNumbersInXTU(panNumbers, nSeed)
		return SomeRandomNumbersInXTU(panNumbers, nSeed)

	#--

	func UniqueRandomNumbersInXT(panNumbers, nSeed)
		return SomeRandomNumbersInXTU(panNumbers, nSeed)

	func SomeUniqueNumbersInXT(panNumbers, nSeed)
		return SomeRandomNumbersInXTU(panNumbers, nSeed)

	#--

	func RandomNumbersInXTU(panNumbers, nSeed)
		return SomeRandomNumbersInXTU(panNumbers, nSeed)

	#==

	func SomeRandomNumbersBetweenXTU(nMin, nMax, nSeed)
		if CheckParams()
			if NOT BothAreNumbers(nMin, nMax)
				StzRaise("Incorrect params types! nMin and nMax must be numbers.")
			ok
		ok

		return SomeRandomNumbersInXTU(nMin : nMax)

	func SomeNumbersBetweenXTU(nMin, nMax, nSeed)
		return SomeRandomNumbersBetweenXTU(nMin, nMax, nSeed)

	func AnyRandomNumbersBetweenXTU(nMin, nMax, nSeed)
		return SomeRandomNumbersBetweenXTU(nMin, nMax, nSeed)

	func AnyNumbersBetweenXTU(nMin, nMax, nSeed)
		return SomeRandomNumbersBetweenXTU(nMin, nMax, nSeed)

	#--

	func UniqueRandomNumbersBetweenXT(nMin, nMax, nSeed)
		return SomeRandomNumbersBetweenXTU(nMin, nMax, nSeed)

	func SomeUniqueNumbersBetweenXT(nMin, nMax, nSeed)
		return SomeRandomNumbersBetweenXTU(nMin, nMax, nSeed)

	#--

	func RandomNumbersBetweenXTU(nMin, nMax, nSeed)
		return SomeRandomNumbersBetweenXTU(panNumbers, nSeed)

	#>

func SomeRandomNumbersInXTUZ(panNumbers, nSeed)
	StzSRandom(nSeed)
	return SomeRandomNumbersInUZ(panNumbers)

	#< @FunctionAlternativeForms

	func SomeNumbersInXTUZ(panNumbers, nSeed)
		return RandomNumbersInXTUZ(panNumbers, nSeed)

	func AnyRandomNumbersInXTUZ(panNumbers, nSeed)
		return RandomNumbersInXTUZ(panNumbers, nSeed)

	func AnyNumbersInXTUZ(panNumbers, nSeed)
		return RandomNumbersInXTUZ(panNumbers, nSeed)

	#--

	func UniqueRandomNumbersInXTZ(panNumbers, nSeed)
		return RandomNumbersInXTUZ(panNumbers, nSeed)

	func SomeUniqueNumbersInXTZ(panNumbers, nSeed)
		return RandomNumbersInXTUZ(panNumbers, nSeed)

	#--

	func RandomNumbersInUXTZ(panNumbers, nSeed)
		return RandomNumbersInXTUZ(panNumbers, nSeed)

	#==

	func SomeRandomNumbersBetweenXTUZ(nMin, nMax, nSeed)
		if CheckParams()
			if NOT BothAreNumbers(nMin, nMax)
				StzRaise("Incorrect params types! nMin and nMax must be numbers.")
			ok
		ok

		return RandomNumbersInXTUZ(nMin : nMax)

	func SomeNumbersBetweenXTUZ(nMin, nMax, nSeed)
		return RandomNumbersBetweenXTUZ(nMin, nMax, nSeed)

	func AnyRandomNumbersBetweenXTUZ(nMin, nMax, nSeed)
		return RandomNumbersBetweenXTUZ(nMin, nMax, nSeed)

	func AnyNumbersBetweenXTUZ(nMin, nMax, nSeed)
		return RandomNumbersBetweenXTUZ(nMin, nMax, nSeed)

	#--

	func UniqueRandomNumbersBetweenXTZ(nMin, nMax, nSeed)
		return RandomNumbersBetweenXTUZ(nMin, nMax, nSeed)

	func SomeUniqueNumbersBetweenXTZ(nMin, nMax, nSeed)
		return RandomNumbersBetweenXTUZ(nMin, nMax, nSeed)

	#--

	func RandomNumbersBetweenUXTZ(nMin, nMax, nSeed)
		return RandomNumbersBetweenXTUZ(nMin, nMax, nSeed)

	#>

#== N RANDOM NUMBERS FROM A LIST OF NUMBERS

func NRandomNumbersIn(n, panNumbers)

	# NOTE: The same number can appear more than once
	# To avoid this, use the function with the ...U() extension

	nLen = len(panNumbers)

	anResult = []

	while TRUE
		nPos = ARandomNumberIn(1 : nLen)
		anResult + panNumbers[nPos]
		if len(anResult) = n
			exit
		ok
	end

	anResult = ring_sort(anResult)

	return anResult

	#< @FunctionAlternativeForms

	func RandomNNumbersIn(n, panNumbers)
		return NRandomNumbersIn(n, panNumbers)

	func AnyNNumbersIn(n, panNumbers)
		return NRandomNumbersIn(n, panNumbers)

	func NNumbersIn(n, panNumbers)
		return NRandomNumbersIn(n, panNumbers)

	#==

	func NRandomNumbersBetween(n, nMin, nMax)
		if CheckParams()
			if NOT BothAreNumbers(nMin, nMax)
				StzRaise("Incorrect params types! nMin and nMax must be numbers.")
			ok
		ok

		return NRandomNumbersIn(n, nMin:nMax)

	func RandomNNumbersBetween(n, nMin, nMax)
		return NRandomNumbersBetween(n, nMin, nMax)

	func AnyNNumbersBetween(n, nMin, nMax)
		return NRandomNumbersBetween(n, nMin, nMax)

	func NNumbersBetween(n, nMin, nMax)
		return NRandomNumbersBetween(n, nMin, nMax)

	#>

func NRandomNumbersInZ(n, panNumbers)

	nLen = len(panNumbers)
	nRandom = ARandomNumberIn(1 : nLen)

	anNumbers = []
	anPos = []

	while TRUE
		nPos = ARandomNumberIn(1 : nLen)
		anNumbers + panNumbers[nPos]
		anPos + nPos
		if len(anNumbers) = n
			exit
		ok
	end

	anNumbers = ring_sort(anNumbers)
	anPos = ring_sort(anPos)

	aResult = Association([ anNumbers, anPos ])

	return aResult

	#< @FunctionAlternativeForms

	func RandomNNumbersInZ(n, panNumbers)
		return NRandomNumbersInZ(n, panNumbers)

	func AnyNNumbersInZ(n, panNumbers)
		return NRandomNumbersInZ(n, panNumbers)

	func NNumbersInZ(n, panNumbers)
		return NRandomNumbersInZ(n, panNumbers)

	#==

	func NRandomNumbersBetweenZ(n, nMin, nMax)
		if CheckParams()
			if NOT BothAreNumbers(nMin, nMax)
				StzRaise("Incorrect params types! nMin and nMax must be numbers.")
			ok
		ok

		return NRandomNumbersInZ(n, nMin:nMax)

	func RandomNNumbersBetweenZ(n, nMin, nMax)
		return NRandomNumbersBetweenZ(n, nMin, nMax)

	func AnyNNumbersBetweenZ(n, nMin, nMax)
		return NRandomNumbersBetweenZ(n, nMin, nMax)

	func NNumbersBetweenZ(n, nMin, nMax)
		return NRandomNumbersBetweenZ(n, nMin, nMax)

	#>

#--

func NRandomNumbersInXT(n, panNumbers, nSeed)
	StzSRandom(nSeed)
	return NRandomNumbersIn(n, panNumbers)

	#< @FunctionAlternativeForms

	func RandomNNumbersInXT(n, panNumbers, nSeed)
		return NRandomNumbersInXT(n, panNumbers, nSeed)

	func AnyNNumbersInXT(n, panNumbers, nSeed)
		return NRandomNumbersInXT(n, panNumbers, nSeed)

	func NNumbersInXT(n, panNumbers, nSeed)
		return NRandomNumbersInXT(n, panNumbers, nSeed)

	#==

	func NRandomNumbersBetweenXT(n, nMin, nMax, nSeed)
		if CheckParams()
			if NOT BothAreNumbers(nMin, nMax)
				StzRaise("Incorrect params types! nMin and nMax must be numbers.")
			ok
		ok

		return NRandomNumbersInXT(n, nMin:nMax, nSeed)

	func RandomNNumbersBetwwenXT(n, nMin, nMax, nSeed)
		return NRandomNumbersBetweenXT(n, nMin, nMax, nSeed)

	func AnyNNumbersBetweenXT(n, nMin, nMax, nSeed)
		return NRandomNumbersBetweenXT(n, nMin, nMax, nSeed)

	func NNumbersBetweenXT(n, nMin, nMax, nSeed)
		return NRandomNumbersBetweenXT(n, nMin, nMax, nSeed)

	#>

func NRandomNumbersInXTZ(n, panNumbers, nSeed)
	StzSRandom(nSeed)
	return NRandomNumbersInZ(n, panNumbers)

	#< @FunctionAlternativeForms

	func RandomNNumbersInXTZ(n, panNumbers, nSeed)
		return NRandomNumbersInXTZ(n, panNumbers, nSeed)

	func AnyNNumbersInXTZ(n, panNumbers, nSeed)
		return NRandomNumbersInXTZ(n, panNumbers, nSeed)

	func NNumbersInXTZ(n, panNumbers, nSeed)
		return NRandomNumbersInXTZ(n, panNumbers, nSeed)

	#==

	func NRandomNumbersBetweenXTZ(n, nMin, nMax, nSeed)
		if CheckParams()
			if NOT BothAreNumbers(nMin, nMax)
				StzRaise("Incorrect params types! nMin and nMax must be numbers.")
			ok
		ok

		return NRandomNumbersInXTZ(n, nMin:nMax, nSeed)

	func RandomNNumbersBetweenXTZ(n, nMin, nMax, nSeed)
		return NRandomNumbersBetweenXTZ(n, nMin, nMax, nSeed)

	func AnyNNumbersBetweenXTZ(n, nMin, nMax, nSeed)
		return NRandomNumbersBetweenXTZ(n, nMin, nMax, nSeed)

	func NNumbersBetweenXTZ(n, nMin, nMax, nSeed)
		return NRandomNumbersBetweenXTZ(n, nMin, nMax, nSeed)

	#>

#==

func NRandomNumbersInU(n, panNumbers)

	# NOTE: The generated numbers are guranteed to be unique

	anResult = []

	while TRUE

		nRandom = ARandomNumberIn(panNumbers)
		
		if ring_find(anResult, nRandom) = 0
			anResult + nRandom

			if len(anResult) = n
				exit
			ok
		ok
	end

	anResult = ring_sort(anResult)

	return anResult

	#< @FunctionAlternativeForms

	func RandomNNumbersInU(n, panNumbers)
		return NRandomNumbersInU(n, panNumbers)

	func AnyNNumbersInU(n, panNumbers)
		return NRandomNumbersInU(n, panNumbers)

	func NNumbersInU(n, panNumbers)
		return NRandomNumbersInU(n, panNumbers)

	#--

	func NUniqueRandomNumbersIn(n, panNumbers)
		return NRandomNumbersInU(n, panNumbers)

	func UniqueNRandomNumbersIn(n, panNumbers)
		return NRandomNumbersInU(n, panNumbers)

	func NUniqueNumbersIn(n, panNumbers)
		return NRandomNumbersInU(n, panNumbers)

	func UniqueNNumbersIn(n, panNumbers)
		return NRandomNumbersInU(n, panNumbers)

	#==

	func NRandomNumbersBetweenU(n, nMin, nMax)
		if CheckParams()
			if NOT BothAreNumbers(nMin, nMax)
				StzRaise("Incorrect params types! nMin and nMax must be numbers.")
			ok
		ok

		return NRandomNumbersInU(n, nMin:nMax)

	func RandomNNumbersBetweenU(n, nMin, nMax)
		return NRandomNumbersBetweenU(n, nMin, nMax)

	func AnyNNumbersBetweenU(n, nMin, nMax)
		return NRandomNumbersBetweenU(n, nMin, nMax)

	func NNumbersBetweenU(n, nMin, nMax)
		return NRandomNumbersBetweenU(n, nMin, nMax)

	#--

	func NUniqueRandomNumbersBetween(n, nMin, nMax)
		return NRandomNumbersBetweenU(n, nMin, nMax)

	func UniqueNRandomNumbersBetween(n, nMin, nMax)
		return NRandomNumbersBetweenU(n, nMin, nMax)

	func NUniqueNumbersBetween(n, nMin, nMax)
		return NRandomNumbersBetweenU(n, nMin, nMax)

	func UniqueNNumbersBetween(n, nMin, nMax)
		return NRandomNumbersBetweenU(n, nMin, nMax)

	#>

func NRandomNumbersInUZ(n, panNumbers)

	anNumbers = []
	anPos = []

	while TRUE

		anRandomZ = ARandomNumberInZ(panNumbers)
		
		if ring_find(anNumbers, anRandomZ[1]) = 0
			anNumbers + anRandomZ[1]
			anPos + anRandomZ[2]

			if len(anNumbers) = n
				exit
			ok
		ok
	end

	anNumbers = ring_sort(anNumbers)
	anPos = ring_sort(anPos)

	aResult = Association([ anNumbers, anPos ])

	return aResult

	#< @FunctionAlternativeForms

	func RandomNNumbersInUZ(n, panNumbers)
		return NRandomNumbersInUZ(n, panNumbers)

	func AnyNNumbersInUZ(n, panNumbers)
		return NRandomNumbersInUZ(n, panNumbers)

	func NNumbersInUZ(n, panNumbers)
		return NRandomNumbersInUZ(n, panNumbers)

	#--

	func NUniqueRandomNumbersInZ(n, panNumbers)
		return NRandomNumbersInUZ(n, panNumbers)

	func UniqueNRandomNumbersInZ(n, panNumbers)
		return NRandomNumbersInUZ(n, panNumbers)

	func NUniqueNumbersInZ(n, panNumbers)
		return NRandomNumbersInUZ(n, panNumbers)

	func UniqueNNumbersInZ(n, panNumbers)
		return NRandomNumbersInUZ(n, panNumbers)

	#==

	func NRandomNumbersBetweenUZ(n, nMin, nMax)
		if CheckParams()
			if NOT BothAreNumbers(nMin, nMax)
				StzRaise("Incorrect params types! nMin and nMax must be numbers.")
			ok
		ok

		return NRandomNumbersInUZ(n, nMin:nMax)

	func RandomNNumbersBetweenUZ(n, nMin, nMax)
		return NRandomNumbersBetweenUZ(n, nMin, nMax)

	func AnyNNumbersBetweenUZ(n, nMin, nMax)
		return NRandomNumbersBetweenUZ(n, nMin, nMax)

	func NNumbersBetweenUZ(n, nMin, nMax)
		return NRandomNumbersBetweenUZ(n, nMin, nMax)

	#--

	func NUniqueRandomNumbersBetweenZ(n, nMin, nMax)
		return NRandomNumbersBetweenUZ(n, nMin, nMax)

	func UniqueNRandomNumbersBetweenZ(n, nMin, nMax)
		return NRandomNumbersBetweenUZ(n, nMin, nMax)

	func NUniqueNumbersBetweenZ(n, nMin, nMax)
		return NRandomNumbersBetweenUZ(n, nMin, nMax)

	func UniqueNNumbersBetweenZ(n, nMin, nMax)
		return NRandomNumbersBetweenUZ(n, nMin, nMax)

	#>

#--

func NRandomNumbersInXTU(n, panNumbers, nSeed)
	StzSRandom(nSeed)
	return NRandomNumbersInXTU(n, panNumbers)

	#< @FunctionAlternativeForms

	func RandomNNumbersInXTU(n, panNumbers, nSeed)
		return NRandomNumbersInXTU(n, panNumbers, nSeed)

	func AnyNNumbersInXTU(n, panNumbers, nSeed)
		return NRandomNumbersInXTU(n, panNumbers, nSeed)

	func NNumbersInXTU(n, panNumbers, nSeed)
		return NRandomNumbersInXTU(n, panNumbers, nSeed)

	#--

	func NUniqueRandomNumbersInXT(n, panNumbers, nSeed)
		return NRandomNumbersInXTU(n, panNumbers, nSeed)

	func UniqueNRandomNumbersInXT(n, panNumbers, nSeed)
		return NRandomNumbersInXTU(n, panNumbers, nSeed)

	func NUniqueNumbersInXT(n, panNumbers, nSeed)
		return NRandomNumbersInXTU(n, panNumbers, nSeed)

	func UniqueNNumbersInXT(n, panNumbers, nSeed)
		return NRandomNumbersInXTU(n, panNumbers, nSeed)

	#==

	func NRandomNumbersBetweenXTU(n, nMin, nMax, nSeed)
		if CheckParams()
			if NOT BothAreNumbers(nMin, nMax)
				StzRaise("Incorrect params types! nMin and nMax must be numbers.")
			ok
		ok

		return NRandomNumbersInXTU(n, nMin:nMax, nSeed)

	func RandomNNumbersBetweenXTU(n, nMin, nMax, nSeed)
		return NRandomNumbersBetweenXTU(n, nMin, nMax, nSeed)

	func AnyNNumbersBetweenXTU(n, nMin, nMax, nSeed)
		return NRandomNumbersBetweenXTU(n, nMin, nMax, nSeed)

	func NNumbersBetweenXTU(n, nMin, nMax, nSeed)
		return NRandomNumbersBetweenXTU(n, nMin, nMax, nSeed)

	#--

	func NUniqueRandomNumbersBetweenXT(n, nMin, nMax, nSeed)
		returnNRandomNumbersBetweenXTU(n, nMin, nMax, nSeed)

	func UniqueNRandomNumbersBetweenXT(n, nMin, nMax, nSeed)
		return NRandomNumbersBetweenXTU(n, nMin, nMax, nSeed)

	func NUniqueNumbersBetweenXT(n, nMin, nMax, nSeed)
		return NRandomNumbersBetweenXTU(n, nMin, nMax, nSeed)

	func UniqueNNumbersBetweenXT(n, nMin, nMax, nSeed)
		return NRandomNumbersBetweenXTU(n, nMin, nMax, nSeed)

	#>

func NRandomNumbersInXTUZ(n, panNumbers, nSeed)
	StzSRandom(nSeed)
	return NRandomNumbersInUZ(n, panNumbers)

	#< @FunctionAlternativeForms

	func RandomNNumbersInXTUZ(n, panNumbers, nSeed)
		return NRandomNumbersInXTUZ(n, panNumbers, nSeed)

	func AnyNNumbersInXTUZ(n, panNumbers, nSeed)
		return NRandomNumbersInXTUZ(n, panNumbers, nSeed)

	func NNumbersInXTUZ(n, panNumbers, nSeed)
		return NRandomNumbersInXTUZ(n, panNumbers, nSeed)

	#--

	func NUniqueRandomNumbersInXTZ(n, panNumbers, nSeed)
		return NRandomNumbersInXTUZ(n, panNumbers, nSeed)

	func UniqueNRandomNumbersInXTZ(n, panNumbers, nSeed)
		return NRandomNumbersInXTUZ(n, panNumbers, nSeed)

	func NUniqueNumbersInXTZ(n, panNumbers, nSeed)
		return NRandomNumbersInXTUZ(n, panNumbers, nSeed)

	func UniqueNNumbersInXTZ(n, panNumbers, nSeed)
		return NRandomNumbersInXTUZ(n, panNumbers, nSeed)

	#==

	func NRandomNumbersBetweenXTUZ(n, nMin, nMax, nSeed)
		if CheckParams()
			if NOT BothAreNumbers(nMin, nMax)
				StzRaise("Incorrect params types! nMin and nMax must be numbers.")
			ok
		ok

		return NRandomNumbersInXTUZ(n, nMin:nMax, nSeed)

	func RandomNNumbersBetweenXTUZ(n, nMin, nMax, nSeed)
		return NRandomNumbersBetweenXTUZ(n, nMin, nMax, nSeed)

	func AnyNNumbersBetweenXTUZ(n, nMin, nMax, nSeed)
		return NRandomNumbersBetweenXTUZ(n, nMin, nMax, nSeed)

	func NNumbersBetweenXTUZ(n, nMin, nMax, nSeed)
		return NRandomNumbersBetweenXTUZ(n, nMin, nMax, nSeed)

	#--

	func NUniqueRandomNumbersBetweenXTZ(n, nMin, nMax, nSeed)
		return NRandomNumbersBetweenXTUZ(n, nMin, nMax, nSeed)

	func UniqueNRandomNumbersBetweenXTZ(n, nMin, nMax, nSeed)
		return NRandomNumbersBetweenXTUZ(n, nMin, nMax, nSeed)

	func NUniqueNumbersBetweenXTZ(n, nMin, nMax, nSeed)
		return NRandomNumbersBetweenXTUZ(n, nMin, nMax, nSeed)

	func UniqueNNumbersBetweenXTZ(n, nMin, nMax, nSeed)
		return NRandomNumbersBetweenXTUZ(n, nMin, nMax, nSeed)

	#>
