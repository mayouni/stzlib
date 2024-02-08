
# Get inspiration from this great article:
# https://marketsplash.com/tutorials/python/cracking-the-code-of-randomness-pythons-secrets-revealed/

# TODO: Propose examples showing realword applications of randomness:
#	- Generating unique passwords
#	- Randomizing data
#	- Monte Carlo simulations
#	- Randomizing game mechanics
#	- etc

  ////////////////////////////
 ///   RANDOM FUNCTIONS   ///
////////////////////////////

_nRingMaxRandom = 999_999_999 # Based on my testing of Ring random() function
			      # NOTE: if you seed the Ring random() function
			      # with a value greater than that, you will get NULL
			      # as a result! Example : random(9_999_999_999)

_nRingMaxSeed = 1_999_999_999 # Idem

func RingMaxRandom()
	return _nRingMaxRandom

	func MaxRingRandom()
		return RingMaxRandom()

func RingMaxSeed()
	return _nRingMaxSeed

	func MaxRingSeed()
		return RingMaxSeed()

func StzRandom(n)
	if CheckParams()
		if NOT isNumber(n)
			StzRaise("Incorrect param type! n must be a number.")
		ok
	ok

	if n > RingMaxRandom()
		StzRaise("Can't proceed. n must be less then " + MaxRingRandom() + ".")
	ok

	return random(n)

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

	#>

#-- A RANDOM NUMBER AMONG THE NUMBERS IN A LIST

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

	#>

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
		return RandomNumberGreaterThanXT(n, nSeed)

	func AnyNumberGreaterThan(n)
		return RandomNumberGreaterThan(n)

	func AnyNumberBiggerThan(n)
		return RandomNumberGreaterThan(n)

	func AnyNumberLargerThan(n)
		return RandomNumberGreaterThan(n)

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

	#>

#==

func SomeRandomNumbersGreaterThan(nValue)
	n = ARandomNumber()
	return NRandomNumbersGreaterThan(n, nValue)

	#< @FunctionAlternativeForms

	func SomeNumbersGreaterThan(nValue)
		return SomeRandomNumbersGreaterThan(nValue)

	func AnyRandomNumbersGreaterThan(nValue)
		return SomeRandomNumbersGreaterThan(nValue)

	func AnyNumbersGreaterThan(nValue)
		return SomeRandomNumbersGreaterThan(nValue)

	#--

	func SomeRandomNumbersBiggerThan(nValue)
		return SomeRandomNumbersGreaterThan(nValue)

	func SomeNumbersBiggerThan(nValue)
		return SomeRandomNumbersGreaterThan(nValue)

	func AnyRandomNumbersBiggerThan(nValue)
		return SomeRandomNumbersGreaterThan(nValue)

	func AnyNumbersBiggerThan(nValue)
		return SomeRandomNumbersGreaterThan(nValue)

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

func SomeRandomNumbersIn(panNumbers)
	if CheckParams()
		if NOT ( isList(panNumbers) and IsListOfNumbers(panNumbers) )
			StzRaise("Incorrect param type! panNumbers.")
		ok
	ok

	n = ARandomNumberIn(1:len(panNumbers))
	return NRandomNumbersIn(n, panNumbers)

	#< @FunctionAlternativeForms

	func SomeNumbersIn(paNumbers)
		return RandomNumbersIn(panNumbers)

	func AnyRandomNumbersIn(paNumbers)
		return RandomNumbersIn(panNumbers)

	func AnyNumbersIn(paNumbers)
		return RandomNumbersIn(panNumbers)

	#>

func SomeRandomNumbersInXT(panNumbers, nSeed)
	StzSRandom(nSeed)
	return SomeRandomNumbersIn(panNumbers)

	#< @FunctionAlternativeForms

	func SomeNumbersInXT(paNumbers, nSeed)
		return RandomNumbersInXT(panNumbers, nSeed)

	func AnyRandomNumbersInXT(paNumbers, nSeed)
		return RandomNumbersInXT(panNumbers, nSeed)

	func AnyNumbersInXT(paNumbers, nSeed)
		return RandomNumbersInXT(panNumbers, nSeed)

	#>

#--

func SomeRandomNumbersInU(panNumbers)
	if CheckParams()
		if NOT ( isList(panNumbers) and IsListOfNumbers(panNumbers) )
			StzRaise("Incorrect param type! panNumbers.")
		ok
	ok

	n = ARandomNumberIn( 1: len(panNumbers) )
	return NRandomNumbersInU(n, panNumbers)

	#< @FunctionAlternativeForms

	func SomeNumbersInU(paNumbers)
		return RandomNumbersInU(panNumbers)

	func AnyRandomNumbersInU(paNumbers)
		return RandomNumbersInU(panNumbers)

	func AnyNumbersInU(paNumbers)
		return RandomNumbersInU(panNumbers)

	#--

	func UniqueRandomNumbersIn(panNumbers)
		return RandomNumbersInU(panNumbers)

	func SomeUniqueNumbersIn(paNumbers)
		return RandomNumbersInU(panNumbers)

	#>

func SomeRandomNumbersInXTU(panNumbers, nSeed)
	StzSRandom(nSeed)
	return SomeRandomNumbersInU(panNumbers)

	#< @FunctionAlternativeForms

	func SomeNumbersInXTU(paNumbers, nSeed)
		return RandomNumbersInXTU(panNumbers, nSeed)

	func AnyRandomNumbersInXTU(paNumbers, nSeed)
		return RandomNumbersInXTU(panNumbers, nSeed)

	func AnyNumbersInXTU(paNumbers, nSeed)
		return RandomNumbersInXTU(panNumbers, nSeed)

	#--

	func UniqueRandomNumbersInXT(panNumbers, nSeed)
		return RandomNumbersInXTU(panNumbers, nSeed)

	func SomeUniqueNumbersInXT(paNumbers, nSeed)
		return RandomNumbersInXTU(panNumbers, nSeed)

	#>

#== N RANDOM NUMBERS FROM A LIST OF NUMBERS

func NRandomNumbersIn(n, panNumbers)

	# NOTE: The same number can appear more than once
	# To avoid this, use the function with the ...U() extension

	nLen = len(panNumbers)

	anResult = []

	for i = 1 to n
		nPos = ARandomNumberIn(1 : nLen)
		anResult + panNumbers[nPos]
	next

	anResult = ring_sort(anResult)

	return anResult

	#< @FunctionAlternativeForms

	func RandomNNumbersIn(n, panNumbers)
		return NRandomNumbersIn(n, panNumbers)

	func AnyNNumbersIn(n, panNumbers)
		return NRandomNumbersIn(n, panNumbers)

	func NNumbersIn(n, panNumbers)
		return NRandomNumbersIn(n, panNumbers)

	#>

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

	#>

func NRandomNumbersInZ(n, panNumbers)

	nLen = len(panNumbers)
	nRandom = ARandomNumberIn(1 : nLen)

	aResult = []

	for i = 1 to nRandom
		nPos = ARandomNumberIn(1 : nLen)
		aResult + [ panNumbers[nPos], nPos ]
	next

	anResult = ring_sort(anResult)

	return aResult

	#< @FunctionAlternativeForms

	func RandomNNumbersInZ(n, panNumbers)
		return NRandomNumbersAmongZ(n, panNumbers)

	func AnyNNumbersInZ(n, panNumbers)
		return NRandomNumbersAmongZ(n, panNumbers)

	func NNumbersInZ(n, panNumbers)
		return NRandomNumbersAmongZ(n, panNumbers)

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

	#>

func NRandomNumbersInUZ(n, panNumbers)

	anNumbers = []
	anPos = []

	while TRUE

		anRandomZ = ARandomNumberInZ(panNumbers)
		
		if ring_find(anNumbers, anRandomZ[1]) = 0
			anNumbers + anRandomZ[1]
			anPos + anRandomZ[2]

			if len(anResult) = n
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

	#>
