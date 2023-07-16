
  ////////////////////////////
 ///   RANDOM FUNCTIONS   ///
////////////////////////////

#-- A RANDOM NUMBER

func StzRandomXT(nMin, nMax) # XT --> bounds are included

	if isList(nMin) and StzListQ(nMin).IsBetweenNamedParam()
		nMin = nMin[2]
	ok

	if isList(nMax) and StzListQ(nMax).IsAndNamedParam()
		nMax = nMax[2]
	ok

	if NOT (isNumber(nMin) and isNumber(nMax))
		StzRaise("Incorrect param types! nMin and nMax must be both numbers.")
	ok

	if nMin > nMax
		nTemp = nMax
		nMax = nMin
		nMin = nMax
	ok

	nResult = random(nMin) + nMax - nMin	# random is a Ring function
	return nResult

	#< @FunctionAlternativeForms

	func StzRandomNumberXT(nMin, nMax)
		return StzRandomXT(nMin, nMax)

	func RandomNumberBetweenXT(nMin, nMax)
		return StzRandomXT(nMin, nMax)

	func AnyRandomNumberBetweenXT(nMin, nMax)
		return StzRandomXT(nMin, nMax)

	func ARandomNumberBetweenXT(nMin, nMax)
		return StzRandomXT(nMin, nMax)

	func ARandomNumberXT(nMin, nMax)
		return StzRandomXT(nMin, nMax)

	func AnyRandomNumberXT(nMin, nMax)
		return StzRandomXT(nMin, nMax)

	#--

	func StzRandomIB(nMin, nMax)
		return StzRandomXT(nMin, nMax)

	func StzRandomNumberIB(nMin, nMax)
		return StzRandomXT(nMin, nMax)

	func RandomNumberBetweenIB(nMin, nMax)
		return StzRandomXT(nMin, nMax)

	func AnyRandomNumberBetweenIB(nMin, nMax)
		return StzRandomXT(nMin, nMax)

	func ARandomNumberBetweenIB(nMin, nMax)
		return StzRandomXT(nMin, nMax)

	func ARandomNumberIB(nMin, nMax)
		return StzRandomXT(nMin, nMax)

	func AnyRandomNumberIB(nMin, nMax)
		return StzRandomXT(nMin, nMax)

	#--

	func AnyNumberXT(nMin, nMax)
		return StzRandomXT(nMin, nMax)

	func AnyNumberIB(nMin, nMax)
		return StzRandomXT(nMin, nMax)

	#>

func StzRandom(nMin, nMax) # Bound are not included. To include them add ...XT()

	if isList(nMin)
		oMin = StzListQ(nMin)
		if oMin.IsBetweenXTNamedParam()
			return StzRandomXT(nMin[2], nMax)
		
		but oMin.IsBetweenNamedParam()
			nMin = nMin[2]
		ok
	ok

	if isList(nMax) and StzListQ(nMax).IsAndNamedParam()
		nMax = nMax[2]
	ok

	if NOT (isNumber(nMin) and isNumber(nMax))
		StzRaise("Incorrect param types! nMin and nMax must be both numbers.")
	ok

	return StzRandomXT( nMin++, nMax-- )

	#< @FunctionAlternativeForms

	func StzRandomNumber(nMin, nMax)
		return StzRandom(nMin, nMax)

	func RandomNumberBetween(nMin, nMax)
		return StzRandom(nMin, nMax)

	func AnyRandomNumberBetween(nMin, nMax)
		return StzRandom(nMin, nMax)

	func ARandomNumberBetween(nMin, nMax)
		return StzRandom(nMin, nMax)

	func ARandomNumber(nMin, nMax)
		return StzRandom(nMin, nMax)

	func AnyRandomNumber(nMin, nMax)
		return StzRandom(nMin, nMax)

	func AnyNumber(nMin, nMax)
		return StzRandom(nMin, nMax)

	#>

#-- N RANDOM NUMBERS

func NRandomNumbersXT(n, nMin, nMax) # XT or IB --> bounds are included

	if NOT isNumber(n)
		StzRaise("Incorrect param type! n must be a number.")
	ok

	if isList(nMin) and StzListQ(nMin).IsBetweenNamedParam()
		nMin = nMin[2]
	ok

	if isList(nMax) and StzListQ(nMax).IsAndNamedParam()
		nMax = nMax[2]
	ok

	if NOT (isNumber(nMin) and isNumber(nMax))
		StzRaise("Incorrect param types! nMin and nMax must be both numbers.")
	ok

	if nMin > nMax
		nTemp = nMax
		nMax = nMin
		nMin = nMax
	ok

	anResult = []
	for i = 1 to n
		anResult + ( random(nMin) + nMax - nMin	 )# random is a Ring function
	next

	return anResult

	#< @FunctionAlternativeForm

	func AnyNRandomNumbersXT(n, nMin, nMax)
		return NRandomNumbersXT(n, nMin, nMax)

	func NRandomNumbersIB(nMin, nMax)
		return NRandomNumbersXT(nMin, nMax)

	func AnyNRandomNumbersIB(nMin, nMax)
		return NRandomNumbersXT(nMin, nMax)

	func NRandomNumbersBetweenXT(nMin, nMax)
		return NRandomNumbersXT(nMin, nMax)

	func AnyNRandomNumbersBetweenXT(nMin, nMax)
		return NRandomNumbersXT(nMin, nMax)

	func NRandomNumbersBetweenIB(nMin, nMax)
		return NRandomNumbersXT(nMin, nMax)

	func AnyNRandomNumbersBetweenIB(nMin, nMax)
		return NRandomNumbersXT(nMin, nMax)

	#--

	func AnyNumbersXT()
		return NRandomNumbersXT(nMin, nMax)

	func AnyNumbersIB()
		return NRandomNumbersXT(nMin, nMax)

	#>

func NRandomNumbers(n, nMin, nMax) # XT --> bounds are included

	if isList(nMin)
		oMin = StzListQ(nMin)
		if oMin.IsBetweenXTNamedParam()
			return StzNRandomNumbersXT(nMin[2], nMax)
		
		but oMin.IsBetweenNamedParam()
			nMin = nMin[2]
		ok
	ok

	if isList(nMin) and StzListQ(nMin).IsBetweenNamedParam()
		nMin = nMin[2]
	ok

	if isList(nMax) and StzListQ(nMax).IsAndNamedParam()
		nMax = nMax[2]
	ok

	if NOT (isNumber(nMin) and isNumber(nMax))
		StzRaise("Incorrect param types! nMin and nMax must be both numbers.")
	ok

	return NRandomNumbersXT( n, nMin++, nMax-- )

	#< @FunctionAlternativeForm

	func AnyNRandomNumbers(n, nMin, nMax)
		return NRandomNumbers(n, nMin, nMax)

	func NRandomNumbersBetween(n, nMin, nMax)
		return RandomNumbers(n, nMin, nMax)

	func AnyNRandomNumbersBetween(n, nMin, nMax)
		return RandomNumbers(n, nMin, nMax)

	func AnyNNumbersBetween(n, nMin, nMax)
		return RandomNumbers(n, nMin, nMax)

	func AnyNNumbers(n, nMin, nMax)
		return RandomNumbers(n, nMin, nMax)

	#>

#--

func 2RandomNumbersXT(nMin, nMax)
	return NRandomNumbersXT(2, nMin, nMax)

	#< @FunctionAlternativeForms

	func 2RandomNumbersBetweenXT(nMin, nMax)
		return 2RandomNumbersXT(nMin, nMax)

	func TwoRandomNumbersXT(nMin, nMax)
		return 2RandomNumbersXT(nMin, nMax)

	func TwoRandomNumbersBetweenXT(nMin, nMax)
		return 2RandomNumbersXT(nMin, nMax)

	#--

	func 2RandomNumbersIB(nMin, nMax)
		return This.2RandomNumbersXT(nMin, nMax)

	func 2RandomNumbersBetweenIB(nMin, nMax)
		return 2RandomNumbersXT(nMin, nMax)

	func TwoRandomNumbersIB(nMin, nMax)
		return 2RandomNumbersXT(nMin, nMax)

	func TwoRandomNumbersBetweenIB(nMin, nMax)
		return 2RandomNumbersXT(nMin, nMax)

	#>

func 3RandomNumbersXT(nMin, nMax)
	return NRandomNumbersXT(3, nMin, nMax)

	#< @FunctionAlternativeForms

	func 3RandomNumbersBetweenXT(nMin, nMax)
		return 3RandomNumbersXT(nMin, nMax)

	func ThreeRandomNumbersXT(nMin, nMax)
		return 3RandomNumbersXT(nMin, nMax)

	func ThreeRandomNumbersBetweenXT(nMin, nMax)
		return 3RandomNumbersXT(nMin, nMax)

	#--

	func 3RandomNumbersIB(nMin, nMax)
		return 3RandomNumbersXT(nMin, nMax)

	func 3RandomNumbersBetweenIB(nMin, nMax)
		return 3RandomNumbersXT(nMin, nMax)

	func ThreeRandomNumbersIB(nMin, nMax)
		return 3RandomNumbersXT(nMin, nMax)

	func ThreeRandomNumbersBetweenIB(nMin, nMax)
		return 3RandomNumbersXT(nMin, nMax)

	#>

func 4RandomNumbersXT(nMin, nMax)
	return NRandomNumbersXT(4, nMin, nMax)

	#< @FunctionAlternativeForms

	func 4RandomNumbersBetweenXT(nMin, nMax)
		return 4RandomNumbersXT(nMin, nMax)

	func FourRandomNumbersXT(nMin, nMax)
		return 4RandomNumbersXT(nMin, nMax)

	func FourRandomNumbersBetweenXT(nMin, nMax)
		return 4RandomNumbersXT(nMin, nMax)

	#--

	func 4RandomNumbersIB(nMin, nMax)
		return 4RandomNumbersXT(nMin, nMax)

	func 4RandomNumbersBetweenIB(nMin, nMax)
		return 4RandomNumbersXT(nMin, nMax)

	func FourRandomNumbersIB(nMin, nMax)
		return 4RandomNumbersXT(nMin, nMax)

	func FourRandomNumbersBetweenIB(nMin, nMax)
		return 4RandomNumbersXT(nMin, nMax)

	#>

func 5RandomNumbersXT(nMin, nMax)
	return NRandomNumbersXT(5, nMin, nMax)

	#< @FunctionAlternativeForms

	func 5RandomNumbersBetweenXT(nMin, nMax)
		return 5RandomNumbersXT(nMin, nMax)

	func FiveRandomNumbersXT(nMin, nMax)
		return 5RandomNumbersXT(nMin, nMax)

	func FiveRandomNumbersBetweenXT(nMin, nMax)
		return 5RandomNumbersXT(nMin, nMax)

	#--

	func 5RandomNumbersIB(nMin, nMax)
		return 5RandomNumbersXT(nMin, nMax)

	func 5RandomNumbersBetweenIB(nMin, nMax)
		return 5RandomNumbersXT(nMin, nMax)

	func FiveRandomNumbersIB(nMin, nMax)
		return 5RandomNumbersXT(nMin, nMax)

	func FiveRandomNumbersBetweenIB(nMin, nMax)
		return 5RandomNumbersXT(nMin, nMax)

	#>

func 6RandomNumbersXT(nMin, nMax)
	return NRandomNumbersXT(6, nMin, nMax)

	#< @FunctionAlternativeForms

	func 6RandomNumbersBetweenXT(nMin, nMax)
		return 6RandomNumbersXT(nMin, nMax)

	func SixRandomNumbersXT(nMin, nMax)
		return 6RandomNumbersXT(nMin, nMax)

	func SixRandomNumbersBetweenXT(nMin, nMax)
		return 6RandomNumbersXT(nMin, nMax)

	#--

	func 6RandomNumbersIB(nMin, nMax)
		return 6RandomNumbersXT(nMin, nMax)

	func 6RandomNumbersBetweenIB(nMin, nMax)
		return 6RandomNumbersXT(nMin, nMax)

	func SixRandomNumbersIB(nMin, nMax)
		return 6RandomNumbersXT(nMin, nMax)

	func SixRandomNumbersBetweenIB(nMin, nMax)
		return 6RandomNumbersXT(nMin, nMax)

	#>

func 7RandomNumbersXT(nMin, nMax)
	return NRandomNumbersXT(7, nMin, nMax)

	#< @FunctionAlternativeForms

	func 7RandomNumbersBetweenXT(nMin, nMax)
		return 7RandomNumbersXT(nMin, nMax)

	func SevenRandomNumbersXT(nMin, nMax)
		return 7RandomNumbersXT(nMin, nMax)

	func SevenRandomNumbersBetweenXT(nMin, nMax)
		return 7RandomNumbersXT(nMin, nMax)

	#--

	func 7RandomNumbersIB(nMin, nMax)
		return 7RandomNumbersXT(nMin, nMax)

	func 7RandomNumbersBetweenIB(nMin, nMax)
		return 7RandomNumbersXT(nMin, nMax)

	func SevenRandomNumbersIB(nMin, nMax)
		return 7RandomNumbersXT(nMin, nMax)

	func SevenRandomNumbersBetweenIB(nMin, nMax)
		return 7RandomNumbersXT(nMin, nMax)

	#>

func 8RandomNumbersXT(nMin, nMax)
	return NRandomNumbersXT(8, nMin, nMax)

	#< @FunctionAlternativeForms

	func 8RandomNumbersBetweenXT(nMin, nMax)
		return 8RandomNumbersXT(nMin, nMax)

	func EightRandomNumbersXT(nMin, nMax)
		return 7RandomNumbersXT(nMin, nMax)

	func EightRandomNumbersBetweenXT(nMin, nMax)
		return 7RandomNumbersXT(nMin, nMax)

	#--

	func 8RandomNumbersIB(nMin, nMax)
		return 8RandomNumbersXT(nMin, nMax)

	func 8RandomNumbersBetweenIB(nMin, nMax)
		return 8RandomNumbersXT(nMin, nMax)

	func EightRandomNumbersIB(nMin, nMax)
		return 8RandomNumbersXT(nMin, nMax)

	func EightRandomNumbersBetweenIB(nMin, nMax)
		return 8RandomNumbersXT(nMin, nMax)

	#>

func 9RandomNumbersXT(nMin, nMax)
	return NRandomNumbersXT(9, nMin, nMax)

	#< @FunctionAlternativeForms

	func 9RandomNumbersBetweenXT(nMin, nMax)
		return 9RandomNumbersXT(nMin, nMax)

	func NineRandomNumbersXT(nMin, nMax)
		return 9RandomNumbersXT(nMin, nMax)

	func NineRandomNumbersBetweenXT(nMin, nMax)
		return 9RandomNumbersXT(nMin, nMax)

	#--

	func 9RandomNumbersIB(nMin, nMax)
		return 8RandomNumbersXT(nMin, nMax)

	func 9RandomNumbersBetweenIB(nMin, nMax)
		return 9RandomNumbersXT(nMin, nMax)

	func NineRandomNumbersIB(nMin, nMax)
		return 9RandomNumbersXT(nMin, nMax)

	func NineRandomNumbersBetweenIB(nMin, nMax)
		return 9RandomNumbersXT(nMin, nMax)

	#>

func 10RandomNumbersXT(nMin, nMax)
	return NRandomNumbersXT(10, nMin, nMax)

	#< @FunctionAlternativeForms

	func 10RandomNumbersBetweenXT(nMin, nMax)
		return 10RandomNumbersXT(nMin, nMax)

	func TenRandomNumbersXT(nMin, nMax)
		return 10RandomNumbersXT(nMin, nMax)

	func TenRandomNumbersBetweenXT(nMin, nMax)
		return 10RandomNumbersXT(nMin, nMax)

	#--

	func 10RandomNumbersIB(nMin, nMax)
		return 10RandomNumbersXT(nMin, nMax)

	func 10RandomNumbersBetweenIB(nMin, nMax)
		return 10RandomNumbersXT(nMin, nMax)

	func TenRandomNumbersIB(nMin, nMax)
		return 10RandomNumbersXT(nMin, nMax)

	func TenRandomNumbersBetweenIB(nMin, nMax)
		return 10RandomNumbersXT(nMin, nMax)

	#>

#--

func 2RandomNumbers(nMin, nMax)
	return NRandomNumbers(2, nMin, nMax)

	#< @FunctionAlternativeForms

	func 2RandomNumbersBetween(nMin, nMax)
		return 2RandomNumbers(nMin, nMax)

	func TwoRandomNumbers(nMin, nMax)
		return 2RandomNumbers(nMin, nMax)

	func TwoRandomNumbersBetween(nMin, nMax)
		return 2RandomNumbers(nMin, nMax)

	#>

func 3RandomNumbers(nMin, nMax)
	return NRandomNumbers(3, nMin, nMax)

	#< @FunctionAlternativeForms

	func 3RandomNumbersBetween(nMin, nMax)
		return 3RandomNumbers(nMin, nMax)

	func ThreeRandomNumbers(nMin, nMax)
		return 3RandomNumbers(nMin, nMax)

	func ThreeRandomNumbersBetween(nMin, nMax)
		return 3RandomNumbers(nMin, nMax)

	#>

func 4RandomNumbers(nMin, nMax)
	return NRandomNumbers(4, nMin, nMax)

	#< @FunctionAlternativeForms

	func 4RandomNumbersBetween(nMin, nMax)
		return 4RandomNumbers(nMin, nMax)

	func FourRandomNumbers(nMin, nMax)
		return 4RandomNumbers(nMin, nMax)

	func FourRandomNumbersBetween(nMin, nMax)
		return 4RandomNumbers(nMin, nMax)

	#>

func 5RandomNumbers(nMin, nMax)
	return NRandomNumbers(5, nMin, nMax)

	#< @FunctionAlternativeForms

	func 5RandomNumbersBetween(nMin, nMax)
		return 5RandomNumbers(nMin, nMax)

	func FiveRandomNumbers(nMin, nMax)
		return 5RandomNumbers(nMin, nMax)

	func FiveRandomNumbersBetween(nMin, nMax)
		return 5RandomNumbers(nMin, nMax)

	#>

func 6RandomNumbers(nMin, nMax)
	return NRandomNumbers(6, nMin, nMax)

	#< @FunctionAlternativeForms

	func 6RandomNumbersBetween(nMin, nMax)
		return 6RandomNumbers(nMin, nMax)

	func SixRandomNumbers(nMin, nMax)
		return 6RandomNumbers(nMin, nMax)

	func SixRandomNumbersBetween(nMin, nMax)
		return 6RandomNumbers(nMin, nMax)

	#>

func 7RandomNumbers(nMin, nMax)
	return NRandomNumbers(7, nMin, nMax)

	#< @FunctionAlternativeForms

	func 7RandomNumbersBetween(nMin, nMax)
		return 7RandomNumbers(nMin, nMax)

	func SevenRandomNumbers(nMin, nMax)
		return 7RandomNumbers(nMin, nMax)

	func SevenRandomNumbersBetween(nMin, nMax)
		return 7RandomNumbers(nMin, nMax)

	#>

func 8RandomNumbers(nMin, nMax)
	return NRandomNumbers(8, nMin, nMax)

	#< @FunctionAlternativeForms

	func 8RandomNumbersBetween(nMin, nMax)
		return 8RandomNumbers(nMin, nMax)

	func EightRandomNumbers(nMin, nMax)
		return 7RandomNumbers(nMin, nMax)

	func EightRandomNumbersBetween(nMin, nMax)
		return 7RandomNumbers(nMin, nMax)

	#>

func 9RandomNumbers(nMin, nMax)
	return NRandomNumbers(9, nMin, nMax)

	#< @FunctionAlternativeForms

	func 9RandomNumbersBetween(nMin, nMax)
		return 9RandomNumbers(nMin, nMax)

	func NineRandomNumbers(nMin, nMax)
		return 9RandomNumbers(nMin, nMax)

	func NineRandomNumbersBetween(nMin, nMax)
		return 9RandomNumbers(nMin, nMax)

	#>

func 10RandomNumbers(nMin, nMax)
	return NRandomNumbers(10, nMin, nMax)

	#< @FunctionAlternativeForms

	func 10RandomNumbersBetween(nMin, nMax)
		return 10RandomNumbers(nMin, nMax)

	func TenRandomNumbers(nMin, nMax)
		return 10RandomNumbers(nMin, nMax)

	func TenRandomNumbersBetween(nMin, nMax)
		return 10RandomNumbers(nMin, nMax)

	#>

#------

func RandomNumberLessThan(n)
	return RandomNumberBetween(1, n)

	#< @FunctionAlternativeForms

	func ARandomNumberLessThan(n)
		return RandomNumberLessThan(n)

	func RandomNumberSmallerThan(n)
		return RandomNumberLessThan(n)

	func ARandomNumberSmallerThan(n)
		return RandomNumberLessThan(n)

	#>

func RandomNumberGreaterThan(n)
	return RandomNumberBetween(n, MaxRingNumber())

	#< @FunctionAlternativeForms

	func ARandomNumberGreaterThan(n)
		return RandomNumberGreaterThan(n)

	func RandomNumberBiggerThan(n)
		return RandomNumberGreaterThan(n)

	func ARandomNumberBiggerThan(n)
		return RandomNumberGreaterThan(n)

	#>

#-----

func NRandomNumbersGreaterThanIB(n, nValue)
	if NOT (isNumber(n) and isNumber(nValue))
		StzRaise("Incorrect param type! n and nValue must be numbers.")
	ok

	anResult = []
	for i = 1 to n
		anResult = ARandomNumberGreaterThanIB(nValue)
	next

	return anResult

	#< @FunctionAlternativeForms

	func NRandomNumbersGreaterThanXT(n, nValue)
		return NRandomNumbersGreaterThanIB(n, nValue)

	func NRandomNumbersLargerThanIB(n, nValue)
		return NRandomNumbersGreaterThanIB(n, nValue)

	func NRandomNumbersLargerThanXT(n, nValue)
		return NRandomNumbersGreaterThanIB(n, nValue)

	func NRandomNumbersBiggerThanXT(n, nValue)
		return NRandomNumbersGreaterThanIB(n, nValue)

	func NRandomNumbersBiggerThanIB(n, nValue)
		return NRandomNumbersGreaterThanIB(n, nValue)

	#>

func NRandomNumbersGreaterThan(n, nValue)
	if NOT (isNumber(n) and isNumber(nValue))
		StzRaise("Incorrect param type! n and nValue must be numbers.")
	ok

	anResult = []
	for i = 1 to n
		anResult + ARandomNumberGreaterThan(nValue)
	next

	return anResult

	#< @FunctionAlternativeForm

	func NRandomNumbersLargerThan(n, nValue)
		return NRandomNumbersGreaterThan(n, nValue)

	func NRandomNumbersBiggerThan(n, nValue)
		return NRandomNumbersGreaterThan(n, nValue)

	#>


#--

func NRandomNumbersLessThanIB(n, nValue)
	if NOT (isNumber(n) and isNumber(nValue))
		StzRaise("Incorrect param type! n and nValue must be numbers.")
	ok

	anResult = []
	for i = 1 to n
		anResult + ARandomNumberLessThanIB(nValue)
	next

	return anResult

	#< @FunctionAlternativeForms

	func NRandomNumbersLessThanXT(n, nValue)
		return NRandomNumbersLessThanIB(n, nValue)

	func NRandomNumbersSmallerThanIB(n, nValue)
		return NRandomNumbersLessThanIB(n, nValue)

	func NRandomNumbersSmallerThanXT(n, nValue)
		return NRandomNumbersGreaterThanIB(n, nValue)

	#>

func NRandomNumbersLessThan(n, nValue)
	if NOT (isNumber(n) and isNumber(nValue))
		StzRaise("Incorrect param type! n and nValue must be numbers.")
	ok

	anResult = []
	for i = 1 to n
		anResult + ARandomNumberLessThan(nValue)
	next

	return anResult

	#< @FunctionAlternativeForm

	func NRandomNumbersSmallerThan(n, nValue)
		return NRandomNumbersGreaterThan(n, nValue)

	#>

#------

func 2RandomNumbersGreaterThanIB(n)
	return NRandomNumbersGreaterThanIB(2, n)

	#< @FunctionAlternativeForms

	func 2RandomNumbersGreaterThanXT(n)
		return 2RandomNumbersGreaterThanIB(n)

	func 2RandomNumbersLargerThanIB(n)
		return 2RandomNumbersGreaterThanIB(n)

	func 2RandomNumbersLargerThanXT(n)
		return 2RandomNumbersGreaterThanIB(n)

	func TwoRandomNumbersGreaterThanIB(n)
		return 2RandomNumbersGreaterThanIB(n)

	func TwoRandomNumbersGreaterThanXT(n)
		return 2RandomNumbersGreaterThanIB(n)

	func TwoRandomNumbersLargerThanIB(n)
		return 2RandomNumbersGreaterThanIB(n)

	func TwoRandomNumbersLargerThanXT(n)
		return 2RandomNumbersGreaterThanIB(n)

	#>

func 2RandomNumbersGreaterThan(n)
	return NRandomNumbersGreaterThan(2, n)

	#< @FunctionAlternativeForm

	func 2RandomNumbersLargerThan(n)
		return 2RandomNumbersGreaterThan(n)

	func 2RandomNumbersBiggerThan(n)
		return 2RandomNumbersGreaterThan(n)

	func TwoRandomNumbersGreaterThan(n)
		return 2RandomNumbersGreaterThan(n)

	func TwoRandomNumbersLargerThan(n)
		return 2RandomNumbersGreaterThan(n)

	func TwoRandomNumbersBiggerThan(n)
		return 2RandomNumbersGreaterThan(n)

	#>

#--

func 3RandomNumbersGreaterThanIB(n)
	return NRandomNumbersGreaterThanIB(3, n)

	#< @FunctionAlternativeForms

	func 3RandomNumbersGreaterThanXT(n)
		return 3RandomNumbersGreaterThanIB(n)

	func 3RandomNumbersLargerThanIB(n)
		return 3RandomNumbersGreaterThanIB(n)

	func 3RandomNumbersLargerThanXT(n)
		return 3RandomNumbersGreaterThanIB(n)

	func ThreeRandomNumbersGreaterThanIB(n)
		return 3RandomNumbersGreaterThanIB(n)

	func ThreeRandomNumbersGreaterThanXT(n)
		return 3RandomNumbersGreaterThanIB(n)

	func ThreeRandomNumbersLargerThanIB(n)
		return 3RandomNumbersGreaterThanIB(n)

	func ThreeRandomNumbersLargerThanXT(n)
		return 3RandomNumbersGreaterThanIB(n)

	#>

func 3RandomNumbersGreaterThan(n)
	return NRandomNumbersGreaterThan(3, n)

	#< @FunctionAlternativeForm

	func 3RandomNumbersLargerThan(n)
		return 3RandomNumbersGreaterThan(n)

	func 3RandomNumbersBiggerThan(n)
		return 3RandomNumbersGreaterThan(n)

	func ThreeRandomNumbersGreaterThan(n)
		return 3RandomNumbersGreaterThan(n)

	func ThreeRandomNumbersLargerThan(n)
		return 3RandomNumbersGreaterThan(n)

	func ThreeRandomNumbersBiggerThan(n)
		return 3RandomNumbersGreaterThan(n)

	#>

#--

func 4RandomNumbersGreaterThanIB(n)
	return NRandomNumbersGreaterThanIB(4, n)

	#< @FunctionAlternativeForms

	func 4RandomNumbersGreaterThanXT(n)
		return 4RandomNumbersGreaterThanIB(n)

	func 4RandomNumbersLargerThanIB(n)
		return 4RandomNumbersGreaterThanIB(n)

	func 4RandomNumbersLargerThanXT(n)
		return 4RandomNumbersGreaterThanIB(n)

	func FourRandomNumbersGreaterThanIB(n)
		return 4RandomNumbersGreaterThanIB(n)

	func FourRandomNumbersGreaterThanXT(n)
		return 4RandomNumbersGreaterThanIB(n)

	func FourRandomNumbersLargerThanIB(n)
		return 4RandomNumbersGreaterThanIB(n)

	func FourRandomNumbersLargerThanXT(n)
		return 4RandomNumbersGreaterThanIB(n)

	#>

func 4RandomNumbersGreaterThan(n)
	return NRandomNumbersGreaterThan(4, n)

	#< @FunctionAlternativeForm

	func 4RandomNumbersLargerThan(n)
		return 4RandomNumbersGreaterThan(n)

	func 4RandomNumbersBiggerThan(n)
		return 4RandomNumbersGreaterThan(n)

	func FourRandomNumbersGreaterThan(n)
		return 4RandomNumbersGreaterThan(n)

	func FourRandomNumbersLargerThan(n)
		return 4RandomNumbersGreaterThan(n)

	func FourRandomNumbersBiggerThan(n)
		return 4RandomNumbersGreaterThan(n)

	#>

#--

func 5RandomNumbersGreaterThanIB(n)
	return NRandomNumbersGreaterThanIB(5, n)

	#< @FunctionAlternativeForms

	func 5RandomNumbersGreaterThanXT(n)
		return 5RandomNumbersGreaterThanIB(n)

	func 5RandomNumbersLargerThanIB(n)
		return 5RandomNumbersGreaterThanIB(n)

	func 5RandomNumbersLargerThanXT(n)
		return 5RandomNumbersGreaterThanIB(n)

	func FiveRandomNumbersGreaterThanIB(n)
		return 5RandomNumbersGreaterThanIB(n)

	func FiveRandomNumbersGreaterThanXT(n)
		return 5RandomNumbersGreaterThanIB(n)

	func FiveRandomNumbersLargerThanIB(n)
		return 5RandomNumbersGreaterThanIB(n)

	func FiveRandomNumbersLargerThanXT(n)
		return 5RandomNumbersGreaterThanIB(n)

	#>

func 5RandomNumbersGreaterThan(n)
	return NRandomNumbersGreaterThan(5, n)

	#< @FunctionAlternativeForm

	func 5RandomNumbersLargerThan(n)
		return 5RandomNumbersGreaterThan(n)

	func 5RandomNumbersBiggerThan(n)
		return 5RandomNumbersGreaterThan(n)

	func FiveRandomNumbersGreaterThan(n)
		return 5RandomNumbersGreaterThan(n)

	func FiveRandomNumbersLargerThan(n)
		return 5RandomNumbersGreaterThan(n)

	func FiveRandomNumbersBiggerThan(n)
		return 5RandomNumbersGreaterThan(n)

	#>

#--

func 6RandomNumbersGreaterThanIB(n)
	return NRandomNumbersGreaterThanIB(6, n)

	#< @FunctionAlternativeForms

	func 6RandomNumbersGreaterThanXT(n)
		return 6RandomNumbersGreaterThanIB(n)

	func 6RandomNumbersLargerThanIB(n)
		return 6RandomNumbersGreaterThanIB(n)

	func SixRandomNumbersLargerThanXT(n)
		return 6RandomNumbersGreaterThanIB(n)

	func SixRandomNumbersGreaterThanXT(n)
		return 6RandomNumbersGreaterThanIB(n)

	func SixRandomNumbersLargerThanIB(n)
		return 6RandomNumbersGreaterThanIB(n)

	#>

func 6RandomNumbersGreaterThan(n)
	return NRandomNumbersGreaterThan(6, n)

	#< @FunctionAlternativeForm

	func 6RandomNumbersLargerThan(n)
		return 6RandomNumbersGreaterThan(n)

	func 6RandomNumbersBiggerThan(n)
		return 6RandomNumbersGreaterThan(n)

	func SixRandomNumbersGreaterThan(n)
		return 6RandomNumbersGreaterThan(n)

	func SixRandomNumbersLargerThan(n)
		return 6RandomNumbersGreaterThan(n)

	func SixRandomNumbersBiggerThan(n)
		return 6RandomNumbersGreaterThan(n)

	#>

#--

func 7RandomNumbersGreaterThanIB(n)
	return NRandomNumbersGreaterThanIB(7, n)

	#< @FunctionAlternativeForms

	func 7RandomNumbersGreaterThanXT(n)
		return 7RandomNumbersGreaterThanIB(n)

	func 7RandomNumbersLargerThanIB(n)
		return 7RandomNumbersGreaterThanIB(n)

	func 7RandomNumbersLargerThanXT(n)
		return 7RandomNumbersGreaterThanIB(n)

	func SevenRandomNumbersGreaterThanIB(n)
		return 7RandomNumbersGreaterThanIB(n)

	func SevenRandomNumbersGreaterThanXT(n)
		return 7RandomNumbersGreaterThanIB(n)

	func SevenRandomNumbersLargerThanIB(n)
		return 7RandomNumbersGreaterThanIB(n)

	func SevenRandomNumbersLargerThanXT(n)
		return 7RandomNumbersGreaterThanIB(n)

	#>

func 7RandomNumbersGreaterThan(n)
	return NRandomNumbersGreaterThan(7, n)

	#< @FunctionAlternativeForm

	func 7RandomNumbersLargerThan(n)
		return 7RandomNumbersGreaterThan(n)

	func 7RandomNumbersBiggerThan(n)
		return 7RandomNumbersGreaterThan(n)

	func SevenRandomNumbersGreaterThan(n)
		return 7RandomNumbersGreaterThan(n)

	func SevenRandomNumbersLargerThan(n)
		return 7RandomNumbersGreaterThan(n)

	func SevenRandomNumbersBiggerThan(n)
		return 7RandomNumbersGreaterThan(n)

	#>

#--

func 8RandomNumbersGreaterThanIB(n)
	return NRandomNumbersGreaterThanIB(8, n)

	#< @FunctionAlternativeForms

	func 8RandomNumbersGreaterThanXT(n)
		return 8RandomNumbersGreaterThanIB(n)

	func 8RandomNumbersLargerThanIB(n)
		return 8RandomNumbersGreaterThanIB(n)

	func 8RandomNumbersLargerThanXT(n)
		return 8RandomNumbersGreaterThanIB(n)

	func EightRandomNumbersGreaterThanIB(n)
		return 8RandomNumbersGreaterThanIB(n)

	func EightRandomNumbersGreaterThanXT(n)
		return 8RandomNumbersGreaterThanIB(n)

	func EightRandomNumbersLargerThanIB(n)
		return 8RandomNumbersGreaterThanIB(n)

	func EightRandomNumbersLargerThanXT(n)
		return 8RandomNumbersGreaterThanIB(n)

	#>

func 8RandomNumbersGreaterThan(n)
	return NRandomNumbersGreaterThan(8, n)

	#< @FunctionAlternativeForm

	func 8RandomNumbersLargerThan(n)
		return 8RandomNumbersGreaterThan(n)

	func 8RandomNumbersBiggerThan(n)
		return 8RandomNumbersGreaterThan(n)

	func EightRandomNumbersGreaterThan(n)
		return 8RandomNumbersGreaterThan(n)

	func EightRandomNumbersLargerThan(n)
		return 8RandomNumbersGreaterThan(n)

	func EightRandomNumbersBiggerThan(n)
		return 8RandomNumbersGreaterThan(n)

	#>

#--

func 9RandomNumbersGreaterThanIB(n)
	return NRandomNumbersGreaterThanIB(9, n)

	#< @FunctionAlternativeForms

	func 9RandomNumbersGreaterThanXT(n)
		return 9RandomNumbersGreaterThanIB(n)

	func 9RandomNumbersLargerThanIB(n)
		return 9RandomNumbersGreaterThanIB(n)

	func 9RandomNumbersLargerThanXT(n)
		return 9RandomNumbersGreaterThanIB(n)

	func NineRandomNumbersGreaterThanIB(n)
		return 9RandomNumbersGreaterThanIB(n)

	func NineRandomNumbersGreaterThanXT(n)
		return 9RandomNumbersGreaterThanIB(n)

	func NineRandomNumbersLargerThanIB(n)
		return 9RandomNumbersGreaterThanIB(n)

	func NineRandomNumbersLargerThanXT(n)
		return 9RandomNumbersGreaterThanIB(n)

	#>

func 9RandomNumbersGreaterThan(n)
	return NRandomNumbersGreaterThan(9, n)

	#< @FunctionAlternativeForm

	func 9RandomNumbersLargerThan(n)
		return 9RandomNumbersGreaterThan(n)

	func 9RandomNumbersBiggerThan(n)
		return 9RandomNumbersGreaterThan(n)

	func NineRandomNumbersGreaterThan(n)
		return 9RandomNumbersGreaterThan(n)

	func NineRandomNumbersLargerThan(n)
		return 9RandomNumbersGreaterThan(n)

	func NineRandomNumbersBiggerThan(n)
		return 9RandomNumbersGreaterThan(n)

	#>

#--

func 10RandomNumbersGreaterThanIB(n)
	return NRandomNumbersGreaterThanIB(10, n)

	#< @FunctionAlternativeForms

	func 10RandomNumbersGreaterThanXT(n)
		return 10RandomNumbersGreaterThanIB(n)

	func 10RandomNumbersLargerThanIB(n)
		return 10RandomNumbersGreaterThanIB(n)

	func 10RandomNumbersLargerThanXT(n)
		return 10RandomNumbersGreaterThanIB(n)

	#--

	func TenRandomNumbersGreaterThanIB(n)
		return TenRandomNumbersGreaterThanIB(n)

	func TenRandomNumbersGreaterThanXT(n)
		return TenRandomNumbersGreaterThanIB(n)

	func TenRandomNumbersLargerThanIB(n)
		return TenRandomNumbersGreaterThanIB(n)

	func TenRandomNumbersLargerThanXT(n)
		return TenRandomNumbersGreaterThanIB(n)

	#>

func 10RandomNumbersGreaterThan(n)
	return NRandomNumbersGreaterThan(10, n)

	#< @FunctionAlternativeForm

	func 10RandomNumbersLargerThan(n)
		return 10RandomNumbersGreaterThan(n)

	func 10RandomNumbersBiggerThan(n)
		return 10RandomNumbersGreaterThan(n)

	#--

	func TenRandomNumbersGreaterThan(n)
		return 10RandomNumbersGreaterThan(n)

	func TenRandomNumbersLargerThan(n)
		return 10RandomNumbersGreaterThan(n)

	func TenRandomNumbersBiggerThan(n)
		return 10RandomNumbersGreaterThan(n)

	#>

#------

func 2RandomNumbersLessThanIB(n)
	return NRandomNumbersLessThanIB(2, n)

	#< @FunctionAlternativeForms

	func 2RandomNumbersLessThanXT(n)
		return 2RandomNumbersLessThanIB(n)

	func 2RandomNumbersSmallerThanIB(n)
		return 2RandomNumbersGreaterThanIB(n)

	func 2RandomNumbersSmallerThanXT(n)
		return 2RandomNumbersGreaterThanIB(n)

	func TwoRandomNumbersLessThanXT(n)
		return 2RandomNumbersGreaterThanIB(n)

	func TwoRandomNumbersLessThanIB(n)
		return 2RandomNumbersGreaterThanIB(n)

	func TwoRandomNumbersSmallerThanIB(n)
		return 2RandomNumbersGreaterThanIB(n)

	func TwoRandomNumbersSmallerThanXT(n)
		return 2RandomNumbersGreaterThanIB(n)

	#>

func 2RandomNumbersLessThan(n)
	return NRandomNumbersLessThan(2, n)

	#< @FunctionAlternativeForm

	func 2RandomNumbersSmallerThan(n)
		return 2RandomNumbersLessThan(n)

	#>

#--

func 3RandomNumbersLessThanIB(n)
	return NRandomNumbersLessThanIB(3, n)

	#< @FunctionAlternativeForms

	func 3RandomNumbersLessThanXT(n)
		return 3RandomNumbersLessThanIB(n)

	func 3RandomNumbersSmallerThanIB(n)
		return 3RandomNumbersGreaterThanIB(n)

	func 3RandomNumbersSmallerThanXT(n)
		return 3RandomNumbersGreaterThanIB(n)

	func ThreeRandomNumbersLessThanXT(n)
		return 3RandomNumbersGreaterThanIB(n)

	func ThreeRandomNumbersLessThanIB(n)
		return 3RandomNumbersGreaterThanIB(n)

	func ThreeRandomNumbersSmallerThanIB(n)
		return 3RandomNumbersGreaterThanIB(n)

	func ThreeRandomNumbersSmallerThanXT(n)
		return 3RandomNumbersGreaterThanIB(n)

	#>

func 3RandomNumbersLessThan(n)
	return NRandomNumbersLessThan(3, n)

	#< @FunctionAlternativeForm

	func 3RandomNumbersSmallerThan(n)
		return 3RandomNumbersLessThan(n)

	func ThreeRandomNumbersLessThan(n)
		return 3RandomNumbersLessThan(n)

	func ThreeRandomNumbersSmallerThan(n)
		return 3RandomNumbersLessThan(n)

	#>

#--

func 4RandomNumbersLessThanIB(n)
	return NRandomNumbersLessThanIB(4, n)

	#< @FunctionAlternativeForms

	func 4RandomNumbersLessThanXT(n)
		return 4RandomNumbersLessThanIB(n)

	func 4RandomNumbersSmallerThanIB(n)
		return 4RandomNumbersGreaterThanIB(n)

	func 4RandomNumbersSmallerThanXT(n)
		return 4RandomNumbersGreaterThanIB(n)

	func FourRandomNumbersLessThanXT(n)
		return 4RandomNumbersLessThanIB(n)

	func FourRandomNumbersLessThanIB(n)
		return 4RandomNumbersLessThanIB(n)

	func FourRandomNumbersSmallerThanIB(n)
		return 4RandomNumbersGreaterThanIB(n)

	func FourRandomNumbersSmallerThanXT(n)
		return 4RandomNumbersGreaterThanIB(n)

	#>

func 4RandomNumbersLessThan(n)
	return NRandomNumbersLessThan(4, n)

	#< @FunctionAlternativeForm

	func 4RandomNumbersSmallerThan(n)
		return 4RandomNumbersLessThan(n)

	func FourRandomNumbersLessThan(n)
		return 4RandomNumbersLessThan(n)

	func FourRandomNumbersSmallerThan(n)
		return 4RandomNumbersLessThan(n)

	#>

#--

func 5RandomNumbersLessThanIB(n)
	return NRandomNumbersLessThanIB(5, n)

	#< @FunctionAlternativeForms

	func 5RandomNumbersLessThanXT(n)
		return 5RandomNumbersLessThanIB(n)

	func 5RandomNumbersSmallerThanIB(n)
		return 5RandomNumbersGreaterThanIB(n)

	func 5RandomNumbersSmallerThanXT(n)
		return 5RandomNumbersGreaterThanIB(n)

	func FiveRandomNumbersLessThanXT(n)
		return 5RandomNumbersLessThanIB(n)

	func FiveRandomNumbersLessThanIB(n)
		return 5RandomNumbersLessThanIB(n)

	func FiveRandomNumbersSmallerThanIB(n)
		return 5RandomNumbersGreaterThanIB(n)

	func FiveRandomNumbersSmallerThanXT(n)
		return 5RandomNumbersGreaterThanIB(n)

	#>

func 5RandomNumbersLessThan(n)
	return NRandomNumbersLessThan(5, n)

	#< @FunctionAlternativeForm

	func 5RandomNumbersSmallerThan(n)
		return 5RandomNumbersLessThan(n)

	func FiveRandomNumbersLessThan(n)
		return 5RandomNumbersLessThan(n)

	func FiveRandomNumbersSmallerThan(n)
		return 5RandomNumbersLessThan(n)

	#>

#--

func 6RandomNumbersLessThanIB(n)
	return NRandomNumbersLessThanIB(6, n)

	#< @FunctionAlternativeForms

	func 6RandomNumbersLessThanXT(n)
		return 6RandomNumbersLessThanIB(n)

	func 6RandomNumbersSmallerThanIB(n)
		return 6RandomNumbersGreaterThanIB(n)

	func 6RandomNumbersSmallerThanXT(n)
		return 6RandomNumbersGreaterThanIB(n)

	func SixRandomNumbersLessThanXT(n)
		return 6RandomNumbersLessThanIB(n)

	func SixRandomNumbersLessThanIB(n)
		return 6RandomNumbersLessThanIB(n)

	func SixRandomNumbersSmallerThanIB(n)
		return 6RandomNumbersGreaterThanIB(n)

	func SixRandomNumbersSmallerThanXT(n)
		return 6RandomNumbersGreaterThanIB(n)

	#>

func 6RandomNumbersLessThan(n)
	return NRandomNumbersLessThan(6, n)

	#< @FunctionAlternativeForm

	func 6RandomNumbersSmallerThan(n)
		return 6RandomNumbersLessThan(n)

	func SixRandomNumbersLessThan(n)
		return 6RandomNumbersLessThan(n)

	func SixRandomNumbersSmallerThan(n)
		return 6RandomNumbersLessThan(n)

	#>

#--

func 7RandomNumbersLessThanIB(n)
	return NRandomNumbersLessThanIB(7, n)

	#< @FunctionAlternativeForms

	func 7RandomNumbersLessThanXT(n)
		return 7RandomNumbersLessThanIB(n)

	func 7RandomNumbersSmallerThanIB(n)
		return 7RandomNumbersGreaterThanIB(n)

	func 7RandomNumbersSmallerThanXT(n)
		return 7RandomNumbersGreaterThanIB(n)

	func SevenRandomNumbersLessThanXT(n)
		return 7RandomNumbersLessThanIB(n)

	func SevenRandomNumbersLessThanIB(n)
		return 7RandomNumbersLessThanIB(n)

	func SevenRandomNumbersSmallerThanIB(n)
		return 7RandomNumbersGreaterThanIB(n)

	func SevenRandomNumbersSmallerThanXT(n)
		return 7RandomNumbersGreaterThanIB(n)

	#>

func 7RandomNumbersLessThan(n)
	return NRandomNumbersLessThan(7, n)

	#< @FunctionAlternativeForm

	func 7RandomNumbersSmallerThan(n)
		return 7RandomNumbersLessThan(n)

	func SevenRandomNumbersLessThan(n)
		return 7RandomNumbersLessThan(n)

	func SevenRandomNumbersSmallerThan(n)
		return 7RandomNumbersLessThan(n)

	#>

#--

func 8RandomNumbersLessThanIB(n)
	return NRandomNumbersLessThanIB(8, n)

	#< @FunctionAlternativeForms

	func 8RandomNumbersLessThanXT(n)
		return 8RandomNumbersLessThanIB(n)

	func 8RandomNumbersSmallerThanIB(n)
		return 8RandomNumbersGreaterThanIB(n)

	func 8RandomNumbersSmallerThanXT(n)
		return 8RandomNumbersGreaterThanIB(n)

	func EightRandomNumbersLessThanXT(n)
		return 8RandomNumbersLessThanIB(n)

	func EightRandomNumbersLessThanIB(n)
		return 8RandomNumbersLessThanIB(n)

	func EightRandomNumbersSmallerThanIB(n)
		return 8RandomNumbersGreaterThanIB(n)

	func EightRandomNumbersSmallerThanXT(n)
		return 8RandomNumbersGreaterThanIB(n)

	#>

func 8RandomNumbersLessThan(n)
	return NRandomNumbersLessThan(8, n)

	#< @FunctionAlternativeForm

	func 8RandomNumbersSmallerThan(n)
		return 8RandomNumbersLessThan(n)

	func EightRandomNumbersLessThan(n)
		return 8RandomNumbersLessThan(n)

	func EightRandomNumbersSmallerThan(n)
		return 8RandomNumbersLessThan(n)

	#>

#--

func 9RandomNumbersLessThanIB(n)
	return NRandomNumbersLessThanIB(9, n)

	#< @FunctionAlternativeForms

	func 9RandomNumbersLessThanXT(n)
		return 9RandomNumbersLessThanIB(n)

	func 9RandomNumbersSmallerThanIB(n)
		return 9RandomNumbersGreaterThanIB(n)

	func 9RandomNumbersSmallerThanXT(n)
		return 9RandomNumbersGreaterThanIB(n)

	func NineRandomNumbersLessThanIB(n)
		return 9RandomNumbersLessThanIB(n)

	func NineRandomNumbersLessThanXT(n)
		return 9RandomNumbersLessThanIB(n)

	func NineRandomNumbersSmallerThanIB(n)
		return 9RandomNumbersGreaterThanIB(n)

	func NineRandomNumbersSmallerThanXT(n)
		return 9RandomNumbersGreaterThanIB(n)

	#>

func 9RandomNumbersLessThan(n)
	return NRandomNumbersLessThan(9, n)

	#< @FunctionAlternativeForm

	func 9RandomNumbersSmallerThan(n)
		return 9RandomNumbersLessThan(n)

	func NineRandomNumbersLessThan(n)
		return 9RandomNumbersLessThan(n)

	func NineRandomNumbersSmallerThan(n)
		return 9RandomNumbersLessThan(n)

	#>

#--

func 10RandomNumbersLessThanIB(n)
	return NRandomNumbersLessThanIB(10, n)

	#< @FunctionAlternativeForms

	func 10RandomNumbersLessThanXT(n)
		return 10RandomNumbersLessThanIB(n)

	func 10RandomNumbersSmallerThanIB(n)
		return 10RandomNumbersGreaterThanIB(n)

	func 10RandomNumbersSmallerThanXT(n)
		return 10RandomNumbersGreaterThanIB(n)

	func TenRandomNumbersLessThanIB(n)
		return 10RandomNumbersLessThanIB(n)

	func TenRandomNumbersLessThanXT(n)
		return 10RandomNumbersLessThanIB(n)

	func TenRandomNumbersSmallerThanIB(n)
		return 10RandomNumbersGreaterThanIB(n)

	func TenRandomNumbersSmallerThanXT(n)
		return 10RandomNumbersGreaterThanIB(n)

	#>

func 10RandomNumbersLessThan(n)
	return NRandomNumbersLessThan(10, n)

	#< @FunctionAlternativeForm

	func 10RandomNumbersSmallerThan(n)
		return 10RandomNumbersLessThan(n)

	func TenRandomNumbersLessThan(n)
		return 10RandomNumbersLessThan(n)

	func TenRandomNumbersSmallerThan(n)
		return 10RandomNumbersLessThan(n)


	#>

#--

func RandomNumberOtherThan(n)
	nResult = RandomNumberBetween(1, MaxRingNumber())
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

	func RandomNumberDifferentThan(n)
		return RandomNumberOtherThan(n)

	func ARandomNumberDifferentThan(n)
		return RandomNumberOtherThan(n)

	func AnyRandomNumberDifferentThan(n)
		return RandomNumberOtherThan(n)

	func ANumberDifferentThan(n)
		return RandomNumberOtherThan(n)

	func AnyNumberDifferentThan(n)
		return RandomNumberOtherThan(n)

	func NumberDifferentThan(n)
		return RandomNumberOtherThan(n)

	#--

	func RandomNumberDifferentFrom(n)
		return RandomNumberOtherThan(n)

	func ARandomNumberDifferentFrom(n)
		return RandomNumberOtherThan(n)

	func AnyRandomNumberDifferentFrom(n)
		return RandomNumberOtherThan(n)

	func ANumberDifferentFrom(n)
		return RandomNumberOtherThan(n)

	func AnyNumberDifferentFrom(n)
		return RandomNumberOtherThan(n)

	func NumberDifferentFrom(n)
		return RandomNumberOtherThan(n)

	#>

#-- N RANDOM NUMBERS FROM A LIST OF NUMBERS

func NRandomNumbersAmong(n, panNumbers)
	anResult = StzListNumbersQ(paNumbers).NRandomNumbers(n)
	return anResult

	#< @FunctionAlternativeForms

	func RandomNNumbersAmong(n, panNumbers)
		return NRandomNumbersAmong(n, panNumbers)

	func AnyNNumbersAmong(n, panNumbers)
		return NRandomNumbersAmong(n, panNumbers)

	func NNumbersAmong(n, panNumbers)
		return NRandomNumbersAmong(n, panNumbers)

	#--

	func NRandomNumbersIn(n, panNumbers)
		return NRandomNumbersAmong(n, panNumbers)

	func RandomNNumbersIn(n, panNumbers)
		return NRandomNumbersAmong(n, panNumbers)

	func AnyNNumbersIn(n, panNumbers)
		return NRandomNumbersAmong(n, panNumbers)

	func NNumbersIn(n, panNumbers)
		return NRandomNumbersAmong(n, panNumbers)

	#--

	func NRandomNumbersFrom(n, panNumbers)
		return NRandomNumbersAmong(n, panNumbers)

	func RandomNNumbersFrom(n, panNumbers)
		return NRandomNumbersAmong(n, panNumbers)

	func AnyNNumbersFrom(n, panNumbers)
		return NRandomNumbersAmong(n, panNumbers)

	func NNumbersFrom(n, panNumbers)
		return NRandomNumbersAmong(n, panNumbers)

	#--

	func NRandomNumbersInside(n, panNumbers)
		return NRandomNumbersAmong(n, panNumbers)

	func RandomNNumbersInside(n, panNumbers)
		return NRandomNumbersAmong(n, panNumbers)

	func AnyNNumbersInside(n, panNumbers)
		return NRandomNumbersAmong(n, panNumbers)

	func NNumbersInside(n, panNumbers)
		return NRandomNumbersAmong(n, panNumbers)

	#--

	func NRandomNumbersFromInside(n, panNumbers)
		return NRandomNumbersAmong(n, panNumbers)

	func RandomNNumbersFromInside(n, panNumbers)
		return NRandomNumbersAmong(n, panNumbers)

	func AnyNNumbersFromInside(n, panNumbers)
		return NRandomNumbersAmong(n, panNumbers)

	func NNumbersFromInside(n, panNumbers)
		return NRandomNumbersAmong(n, panNumbers)

	#>
