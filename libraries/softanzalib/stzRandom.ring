
# Get inspiration from this great article:
# https://marketsplash.com/tutorials/python/cracking-the-code-of-randomness-pythons-secrets-revealed/

  ////////////////////////////
 ///   RANDOM FUNCTIONS   ///
////////////////////////////

func SeedRandom(n)
	if isList(n) and Q(n).IsWithOrByOrUsingNamedParam()
		n = n[2]
	ok
	
	srand(n)

	func SeedRandomWith(n)
		srand(n)

	func SRandomWith(n)
		srand(n)

#-- A RANDOM NUMBER AMONG THE NUMBERS IN A LIST

func RandomNumberIn(panNumbers)
	if NOT isList(panNumbers)
		StzRaise("Incorrect param type! panNumbers must be a list.")
	ok

	anNumbers = OnlyNumbers(panNumbers)
	nLen = len(anNumbers)
	nPos = ARandomNumber(1, nLen)
	nResult = anNumbers[nPos]

	return nResult

	func ARandomNumberIn(panNumbers)
		return RandomNumberIn(panNumbers)

#-- A RANDOM NUMBER BETWEEN TWO NUMBERS

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

	#--

	func ANumber(nMin, nMax)
		return StzRandom(nMin, nMax)

	func ANumberBetween(nMin, nMax)
		return StzRandom(nMin, nMax)

	func AnyNumber(nMin, nMax)
		return StzRandom(nMin, nMax)

	func AnyNumberBetween(nMin, nMax)
		return StzRandom(nMin, nMax)

	#>

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

	func ANumberXT(nMin, nMax)
		return StzRandomXT(nMin, nMax)

	func ANumberBetweenXT(nMin, nMax)
		return StzRandomXT(nMin, nMax)

	func AnyNumberXT(nMin, nMax)
		return StzRandomXT(nMin, nMax)

	func AnyNumberBetweenXT(nMin, nMax)
		return StzRandomXT(nMin, nMax)

	#==

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

	func ANumberIB(nMin, nMax)
		return StzRandomXT(nMin, nMax)

	func ANumberBetweenIB(nMin, nMax)
		return StzRandomXT(nMin, nMax)

	func AnyNumberIB(nMin, nMax)
		return StzRandomXT(nMin, nMax)

	func AnyNumberBetweenIB(nMin, nMax)
		return StzRandomXT(nMin, nMax)

	#>

#-- N RANDOM NUMBERS

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
		return NRandomNumbers(n, nMin, nMax)

	func AnyNRandomNumbersBetween(n, nMin, nMax)
		return NRandomNumbers(n, nMin, nMax)

	#--

	func NNumbers(n, nMin, nMax)
		return NRandomNumbers(n, nMin, nMax)

	func NNumberBetween(n, nMin, nMax)
		return NRandomNumbers(n, nMin, nMax)

	func AnyNNumbers(nMin, nMax)
		return NRandomNumbers(n, nMin, nMax)

	func AnyNNumbersBetween(n, nMin, nMax)
		return NRandomNumbers(n, nMin, nMax)

	#>


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

	func NRandomNumbersIB(n, nMin, nMax)
		return NRandomNumbersXT(n, nMin, nMax)

	func AnyNRandomNumbersIB(n, nMin, nMax)
		return NRandomNumbersXT(n, nMin, nMax)

	func NRandomNumbersBetweenXT(n, nMin, nMax)
		return NRandomNumbersXT(n, nMin, nMax)

	func AnyNRandomNumbersBetweenXT(n, nMin, nMax)
		return NRandomNumbersXT(n, nMin, nMax)

	func NRandomNumbersBetweenIB(n, nMin, nMax)
		return NRandomNumbersXT(n, nMin, nMax)

	func AnyNRandomNumbersBetweenIB(n, nMin, nMax)
		return NRandomNumbersXT(n, nMin, nMax)

	#--

	func NNumbersXT(n, nMin, nMax)
		return NRandomNumbersXT(n, nMin, nMax)

	func NNumberBetweenXT(n, nMin, nMax)
		return NRandomNumbersXT(n, nMin, nMax)

	func AnyNNumbersXT(n, nMin, nMax)
		return NRandomNumbersXT(n, nMin, nMax)

	func AnyNNumbersBetweenXT(n, nMin, nMax)
		return NRandomNumbersXT(n, nMin, nMax)

	func NNumbersIB(n, nMin, nMax)
		return NRandomNumbersXT(n, nMin, nMax)

	func NNumberBetweenIB(n, nMin, nMax)
		return NRandomNumbersXT(n, nMin, nMax)

	func AnyNNumbersIB(n, nMin, nMax)
		return NRandomNumbersXT(n, nMin, nMax)

	func AnyNNumbersBetweenIB(n, nMin, nMax)
		return NRandomNumbersXT(n, nMin, nMax)


func SomeNumbers(nMin, nMax)
	n = AnyNumberBetween(nMin, nMax)
	return NRandomNumbers(n, nMin, nMax)

	func SomeNumbersBetween(nMin, nMax)
		return SomeNumbers(nMin, nMax)

	func AnyNumbersBetween(nMin, nMax)
		return SomeNumbers(nMin, nMax)

	
func SomeNumbersXT(nMin, nMax)
	n = AnyNumberBetweenXT(nMin, nMax)
	return NRandomNumbersXT(n, nMin, nMax)

	func SomeNumbersBetweenXT(nMin, nMax)
		return SomeNumbersXT(nMin, nMax)

	func SomeNumbersIB(nMin, nMax)
		return SomeNumbersXT(nMin, nMax)

	func SomeNumbersBetweenIB(nMin, nMax)
		return SomeNumbersXT(nMin, nMax)

	#--

	func AnyNumbersXT(nMin, nMax)
		return SomeNumbersXT(nMin, nMax)

	func AnyNumbersBetweenXT(nMin, nMax)
		return SomeNumbersXT(nMin, nMax)

	func AnyNumbersIB(nMin, nMax)
		return SomeNumbersXT(nMin, nMax)

	func AnyNumbersBetweenIB(nMin, nMax)
		return SomeNumbersXT(nMin, nMax)


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

	#--

	func TwoNumbersXT(nMin, nMax)
		return 2RandomNumbersXT(nMin, nMax)

	func TwoNumberBetweenXT(nMin, nMax)
		return 2RandomNumbersXT(nMin, nMax)

	func AnyTwoNumbersXT(nMin, nMax)
		return 2RandomNumbersXT(nMin, nMax)

	func AnyTwoNumbersBetweenXT(nMin, nMax)
		return 2RandomNumbersXT(nMin, nMax)

	func TwoNumbersIB(nMin, nMax)
		return 2RandomNumbersXT(nMin, nMax)

	func TwoNumberBetweenIB(nMin, nMax)
		return 2RandomNumbersXT(nMin, nMax)

	func AnyTwoNumbersIB(nMin, nMax)
		return 2RandomNumbersXT(nMin, nMax)

	func AnyTwoNumbersBetweenIB(nMin, nMax)
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

	#--

	func ThreeNumbersXT(nMin, nMax)
		return 3RandomNumbersXT(nMin, nMax)

	func ThreeNumberBetweenXT(nMin, nMax)
		return 3RandomNumbersXT(nMin, nMax)

	func AnyThreeNumbersXT(nMin, nMax)
		return 3RandomNumbersXT(nMin, nMax)

	func AnyThreeNumbersBetweenXT(nMin, nMax)
		return 3RandomNumbersXT(nMin, nMax)

	func ThreeNumbersIB(nMin, nMax)
		return 3RandomNumbersXT(nMin, nMax)

	func ThreeNumberBetweenIB(nMin, nMax)
		return 3RandomNumbersXT(nMin, nMax)

	func AnyThreeNumbersIB(nMin, nMax)
		return 3RandomNumbersXT(nMin, nMax)

	func AnyThreeNumbersBetweenIB(nMin, nMax)
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

	#--

	func FourNumbersXT(nMin, nMax)
		return 4RandomNumbersXT(nMin, nMax)

	func FourNumberBetweenXT(nMin, nMax)
		return 4RandomNumbersXT(nMin, nMax)

	func AnyFourNumbersXT(nMin, nMax)
		return 4RandomNumbersXT(nMin, nMax)

	func AnyFourNumbersBetweenXT(nMin, nMax)
		return 4RandomNumbersXT(nMin, nMax)

	func FourNumbersIB(nMin, nMax)
		return 4RandomNumbersXT(nMin, nMax)

	func FourNumberBetweenIB(nMin, nMax)
		return 4RandomNumbersXT(nMin, nMax)

	func AnyFourNumbersIB(nMin, nMax)
		return 4RandomNumbersXT(nMin, nMax)

	func AnyFourNumbersBetweenIB(nMin, nMax)
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

	#--

	func FiveNumbersXT(nMin, nMax)
		return 5RandomNumbersXT(nMin, nMax)

	func FiveNumberBetweenXT(nMin, nMax)
		return 5RandomNumbersXT(nMin, nMax)

	func AnyFiveNumbersXT(nMin, nMax)
		return 5RandomNumbersXT(nMin, nMax)

	func AnyFiveNumbersBetweenXT(nMin, nMax)
		return 5RandomNumbersXT(nMin, nMax)

	func FiveNumbersIB(nMin, nMax)
		return 5RandomNumbersXT(nMin, nMax)

	func FiveNumberBetweenIB(nMin, nMax)
		return 5RandomNumbersXT(nMin, nMax)

	func AnyFiveNumbersIB(nMin, nMax)
		return 5RandomNumbersXT(nMin, nMax)

	func AnyFiveNumbersBetweenIB(nMin, nMax)
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

	#--

	func SixNumbersXT(nMin, nMax)
		return 6RandomNumbersXT(nMin, nMax)

	func SixNumberBetweenXT(nMin, nMax)
		return 6RandomNumbersXT(nMin, nMax)

	func AnySixNumbersXT(nMin, nMax)
		return 6RandomNumbersXT(nMin, nMax)

	func AnySixNumbersBetweenXT(nMin, nMax)
		return 6RandomNumbersXT(nMin, nMax)

	func SixNumbersIB(nMin, nMax)
		return 6RandomNumbersXT(nMin, nMax)

	func SixNumberBetweenIB(nMin, nMax)
		return 6RandomNumbersXT(nMin, nMax)

	func AnySixNumbersIB(nMin, nMax)
		return 6RandomNumbersXT(nMin, nMax)

	func AnySixNumbersBetweenIB(nMin, nMax)
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

	#--

	func SevenNumbersXT(nMin, nMax)
		return 7RandomNumbersXT(nMin, nMax)

	func SevenNumberBetweenXT(nMin, nMax)
		return 7RandomNumbersXT(nMin, nMax)

	func AnySevenNumbersXT(nMin, nMax)
		return 7RandomNumbersXT(nMin, nMax)

	func AnySevenNumbersBetweenXT(nMin, nMax)
		return 7RandomNumbersXT(nMin, nMax)

	func SevenNumbersIB(nMin, nMax)
		return 7RandomNumbersXT(nMin, nMax)

	func SevenNumberBetweenIB(nMin, nMax)
		return 7RandomNumbersXT(nMin, nMax)

	func AnySevenNumbersIB(nMin, nMax)
		return 7RandomNumbersXT(nMin, nMax)

	func AnySevenNumbersBetweenIB(nMin, nMax)
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

	#--

	func EightNumbersXT(nMin, nMax)
		return 8RandomNumbersXT(nMin, nMax)

	func EightNumberBetweenXT(nMin, nMax)
		return 8RandomNumbersXT(nMin, nMax)

	func AnyEightNumbersXT(nMin, nMax)
		return 8RandomNumbersXT(nMin, nMax)

	func AnyEightNumbersBetweenXT(nMin, nMax)
		return 8RandomNumbersXT(nMin, nMax)

	func EightNumbersIB(nMin, nMax)
		return 8RandomNumbersXT(nMin, nMax)

	func EightNumberBetweenIB(nMin, nMax)
		return 8RandomNumbersXT(nMin, nMax)

	func AnyEightNumbersIB(nMin, nMax)
		return 8RandomNumbersXT(nMin, nMax)

	func AnyEightNumbersBetweenIB(nMin, nMax)
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

	#--

	func NineNumbersXT(nMin, nMax)
		return 9RandomNumbersXT(nMin, nMax)

	func NineNumberBetweenXT(nMin, nMax)
		return 9RandomNumbersXT(nMin, nMax)

	func AnyNineNumbersXT(nMin, nMax)
		return 9RandomNumbersXT(nMin, nMax)

	func AnyNineNumbersBetweenXT(nMin, nMax)
		return 9RandomNumbersXT(nMin, nMax)

	func NineNumbersIB(nMin, nMax)
		return 9RandomNumbersXT(nMin, nMax)

	func NineNumberBetweenIB(nMin, nMax)
		return 9RandomNumbersXT(nMin, nMax)

	func AnyNineNumbersIB(nMin, nMax)
		return 9RandomNumbersXT(nMin, nMax)

	func AnyNineNumbersBetweenIB(nMin, nMax)
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

	#--

	func TenNumbersXT(nMin, nMax)
		return 10RandomNumbersXT(nMin, nMax)

	func TenNumberBetweenXT(nMin, nMax)
		return 10RandomNumbersXT(nMin, nMax)

	func AnyTenNumbersXT(nMin, nMax)
		return 10RandomNumbersXT(nMin, nMax)

	func AnyTenNumbersBetweenXT(nMin, nMax)
		return 10RandomNumbersXT(nMin, nMax)

	func TenNumbersIB(nMin, nMax)
		return 10RandomNumbersXT(nMin, nMax)

	func TenNumberBetweenIB(nMin, nMax)
		return 10RandomNumbersXT(nMin, nMax)

	func AnyTenNumbersIB(nMin, nMax)
		return 10RandomNumbersXT(nMin, nMax)

	func AnyTenNumbersBetweenIB(nMin, nMax)
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

	#--

	func 2Numbers(nMin, nMax)
		return 2RandomNumbers(nMin, nMax)

	func 2NumbersBetween(nMin, nMax)
		return 2RandomNumbers(nMin, nMax)

	func TwoNumbers(nMin, nMax)
		return 2RandomNumbers(nMin, nMax)

	func TwoNumbersBetween(nMin, nMax)
		return 2RandomNumbers(nMin, nMax)

	func Any2Numbers(nMin, nMax)
		return 2RandomNumbers(nMin, nMax)

	func Any2NumbersBetween(nMin, nMax)
		return 2RandomNumbers(nMin, nMax)

	func AnyTwoNumbers(nMin, nMax)
		return 2RandomNumbers(nMin, nMax)

	func AnyTwoNumbersBetween(nMin, nMax)
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

	#--

	func 3Numbers(nMin, nMax)
		return 3RandomNumbers(nMin, nMax)

	func 3NumbersBetween(nMin, nMax)
		return 3RandomNumbers(nMin, nMax)

	func ThreeNumbers(nMin, nMax)
		return 3RandomNumbers(nMin, nMax)

	func ThreeNumbersBetween(nMin, nMax)
		return 3RandomNumbers(nMin, nMax)

	func Any3Numbers(nMin, nMax)
		return 3RandomNumbers(nMin, nMax)

	func Any3NumbersBetween(nMin, nMax)
		return 3RandomNumbers(nMin, nMax)

	func AnyThreeNumbers(nMin, nMax)
		return 3RandomNumbers(nMin, nMax)

	func AnyThreeNumbersBetween(nMin, nMax)
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

	#--

	func 4Numbers(nMin, nMax)
		return 4RandomNumbers(nMin, nMax)

	func 4NumbersBetween(nMin, nMax)
		return 4RandomNumbers(nMin, nMax)

	func FourNumbers(nMin, nMax)
		return 4RandomNumbers(nMin, nMax)

	func FourNumbersBetween(nMin, nMax)
		return 4RandomNumbers(nMin, nMax)

	func Any4Numbers(nMin, nMax)
		return 4RandomNumbers(nMin, nMax)

	func Any4NumbersBetween(nMin, nMax)
		return 4RandomNumbers(nMin, nMax)

	func AnyFourNumbers(nMin, nMax)
		return 4RandomNumbers(nMin, nMax)

	func AnyFourNumbersBetween(nMin, nMax)
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
	#--

	func 5Numbers(nMin, nMax)
		return 5RandomNumbers(nMin, nMax)

	func 5NumbersBetween(nMin, nMax)
		return 5RandomNumbers(nMin, nMax)

	func FiveNumbers(nMin, nMax)
		return 5RandomNumbers(nMin, nMax)

	func FiveNumbersBetween(nMin, nMax)
		return 5RandomNumbers(nMin, nMax)

	func Any5Numbers(nMin, nMax)
		return 5RandomNumbers(nMin, nMax)

	func Any5NumbersBetween(nMin, nMax)
		return 5RandomNumbers(nMin, nMax)

	func AnyFiveNumbers(nMin, nMax)
		return 5RandomNumbers(nMin, nMax)

	func AnyFiveNumbersBetween(nMin, nMax)
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

	#--

	func 6Numbers(nMin, nMax)
		return 6RandomNumbers(nMin, nMax)

	func 6NumbersBetween(nMin, nMax)
		return 6RandomNumbers(nMin, nMax)

	func SixNumbers(nMin, nMax)
		return 6RandomNumbers(nMin, nMax)

	func SixNumbersBetween(nMin, nMax)
		return 6RandomNumbers(nMin, nMax)

	func Any6Numbers(nMin, nMax)
		return 6RandomNumbers(nMin, nMax)

	func Any6NumbersBetween(nMin, nMax)
		return 6RandomNumbers(nMin, nMax)

	func AnySixNumbers(nMin, nMax)
		return 6RandomNumbers(nMin, nMax)

	func AnySixNumbersBetween(nMin, nMax)
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

	#--

	func 7Numbers(nMin, nMax)
		return 7RandomNumbers(nMin, nMax)

	func 7NumbersBetween(nMin, nMax)
		return 7RandomNumbers(nMin, nMax)

	func SevenNumbers(nMin, nMax)
		return 7RandomNumbers(nMin, nMax)

	func SevenNumbersBetween(nMin, nMax)
		return 7RandomNumbers(nMin, nMax)

	func Any7Numbers(nMin, nMax)
		return 7RandomNumbers(nMin, nMax)

	func Any7NumbersBetween(nMin, nMax)
		return 7RandomNumbers(nMin, nMax)

	func AnySevenNumbers(nMin, nMax)
		return 7RandomNumbers(nMin, nMax)

	func AnySevenNumbersBetween(nMin, nMax)
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

	#--

	func 8Numbers(nMin, nMax)
		return 8RandomNumbers(nMin, nMax)

	func 8NumbersBetween(nMin, nMax)
		return 8RandomNumbers(nMin, nMax)

	func EightNumbers(nMin, nMax)
		return 8RandomNumbers(nMin, nMax)

	func EightNumbersBetween(nMin, nMax)
		return 8RandomNumbers(nMin, nMax)

	func Any8Numbers(nMin, nMax)
		return 8RandomNumbers(nMin, nMax)

	func Any8NumbersBetween(nMin, nMax)
		return 8RandomNumbers(nMin, nMax)

	func AnyEightNumbers(nMin, nMax)
		return 8RandomNumbers(nMin, nMax)

	func AnyEightNumbersBetween(nMin, nMax)
		return 8RandomNumbers(nMin, nMax)

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

	#--

	func 9Numbers(nMin, nMax)
		return 9RandomNumbers(nMin, nMax)

	func 9NumbersBetween(nMin, nMax)
		return 9RandomNumbers(nMin, nMax)

	func NineNumbers(nMin, nMax)
		return 9RandomNumbers(nMin, nMax)

	func NineNumbersBetween(nMin, nMax)
		return 9RandomNumbers(nMin, nMax)

	func Any9Numbers(nMin, nMax)
		return 9RandomNumbers(nMin, nMax)

	func Any9NumbersBetween(nMin, nMax)
		return 9RandomNumbers(nMin, nMax)

	func AnyNineNumbers(nMin, nMax)
		return 9RandomNumbers(nMin, nMax)

	func AnyNineNumbersBetween(nMin, nMax)
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

	#--

	func 10Numbers(nMin, nMax)
		return 10RandomNumbers(nMin, nMax)

	func 10NumbersBetween(nMin, nMax)
		return 10RandomNumbers(nMin, nMax)

	func TenNumbers(nMin, nMax)
		return 10RandomNumbers(nMin, nMax)

	func TenNumbersBetween(nMin, nMax)
		return 10RandomNumbers(nMin, nMax)

	func Any10Numbers(nMin, nMax)
		return 10RandomNumbers(nMin, nMax)

	func Any10NumbersBetween(nMin, nMax)
		return 10RandomNumbers(nMin, nMax)

	func AnyTenNumbers(nMin, nMax)
		return 10RandomNumbers(nMin, nMax)

	func AnyTenNumbersBetween(nMin, nMax)
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

	func ANumberSmallerThan(n)
		return RandomNumberLessThan(n)

	func ANumberLessThan(n)
		return RandomNumberLessThan(n)

	func AnyNumberSmallerThan(n)
		return RandomNumberLessThan(n)

	func AnyNumberLessThan(n)
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

	func ANumberGreaterThan(n)
		return RandomNumberGreaterThan(n)

	func ANumberBiggerThan(n)
		return RandomNumberGreaterThan(n)

	func ANumberLargerThan(n)
		return RandomNumberGreaterThan(n)

	func AnyNumberGreaterThan(n)
		return RandomNumberGreaterThan(n)

	func AnyNumberBiggerThan(n)
		return RandomNumberGreaterThan(n)

	func AnyNumberLargerThan(n)
		return RandomNumberGreaterThan(n)

	#>

#-----

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

	#--

	func NNumbersGreaterThanIB(n, nValue)
		return NRandomNumbersGreaterThanIB(n, nValue)

	func NNumbersLargerThanIB(n, nValue)
		return NRandomNumbersGreaterThanIB(n, nValue)

	func NNumbersBiggerThanIB(n, nValue)
		return NRandomNumbersGreaterThanIB(n, nValue)


	func AnyNNumbersGreaterThanIB(n, nValue)
		return NRandomNumbersGreaterThanIB(n, nValue)

	func AnyNNumbersLargerThanIB(n, nValue)
		return NRandomNumbersGreaterThanIB(n, nValue)

	func AnyNNumbersBiggerThanIB(n, nValue)
		return NRandomNumbersGreaterThanIB(n, nValue)

	#--

	func NNumbersGreaterThanXT(n, nValue)
		return NRandomNumbersGreaterThanIB(n, nValue)

	func NNumbersLargerThanXT(n, nValue)
		return NRandomNumbersGreaterThanIB(n, nValue)

	func NNumbersBiggerThanXT(n, nValue)
		return NRandomNumbersGreaterThanIB(n, nValue)


	func AnyNNumbersGreaterThanXT(n, nValue)
		return NRandomNumbersGreaterThanIB(n, nValue)

	func AnyNNumbersLargerThanXT(n, nValue)
		return NRandomNumbersGreaterThanIB(n, nValue)

	func AnyNNumbersBiggerThanXT(n, nValue)
		return NRandomNumbersGreaterThanIB(n, nValue)

	#>

#--

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


	func NNumbersLessThan(n, nValue)
		return NRandomNumbersLessThan(n, nValue)

	func NNumbersSmallerThan(n, nValue)
		return NRandomNumbersGreaterThan(n, nValue)

	func AnyNNumbersLessThan(n, nValue)
		return NRandomNumbersLessThan(n, nValue)

	func AnyNNumbersSmallerThan(n, nValue)
		return NRandomNumbersGreaterThan(n, nValue)

	#>

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

	func NRandomNumbersSmallerThanIB(n, nValue)
		return NRandomNumbersLessThanIB(n, nValue)

	func NNumbersLessThanIB(n, nValue)
		return NRandomNumbersLessThanIB(n, nValue)

	func NNumbersSmallerThanIB(n, nValue)
		return NRandomNumbersLessThanIB(n, nValue)

	func AnyNNumbersLessThanIB(n, nValue)
		return NRandomNumbersLessThanIB(n, nValue)

	func AnyNNumbersSmallerThanIB(n, nValue)
		return NRandomNumbersLessThanIB(n, nValue)

	#--

	func NRandomNumbersLessThanXT(n, nValue)
		return NRandomNumbersLessThanIB(n, nValue)

	func NRandomNumbersSmallerThanXT(n, nValue)
		return NRandomNumbersLessThanIB(n, nValue)

	func NNumbersLessThanXT(n, nValue)
		return NRandomNumbersLessThanIB(n, nValue)

	func NNumbersSmallerThanXT(n, nValue)
		return NRandomNumbersLessThanIB(n, nValue)

	func AnyNNumbersLessThanXT(n, nValue)
		return NRandomNumbersLessThanIB(n, nValue)

	func AnyNNumbersSmallerThanXT(n, nValue)
		return NRandomNumbersLessThanIB(n, nValue)

	#>

#====== TODO: Add all alternative as above

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

	# NOTE: The same number can appear more than once
	# To avoid this, use the function with the ...U() extension

	nLen = len(panNumbers)
	nRandom = ARandomNumberBetween(1, nLen)

	anResult = []

	for i = 1 to nRandom
		nPos = ARandomNumberBetween(1, nLen)
		anResult + panNumbers[nPos]
	next

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

	# Z/EXTENDED FORM (TODO)

func NRandomNumbersAmongZ(n, panNumbers)

	nLen = len(panNumbers)
	nRandom = ARandomNumberBetween(1, nLen)

	aResult = []

	for i = 1 to nRandom
		nPos = ARandomNumberBetween(1, nLen)
		aResult + [ panNumbers[nPos], nPos ]
	next

	return aResult

	#< @FunctionAlternativeForms

	func RandomNNumbersAmongZ(n, panNumbers)
		return NRandomNumbersAmongZ(n, panNumbers)

	func AnyNNumbersAmongZ(n, panNumbers)
		return NRandomNumbersAmongZ(n, panNumbers)

	func NNumbersAmongZ(n, panNumbers)
		return NRandomNumbersAmongZ(n, panNumbers)

	#--

	func NRandomNumbersInZ(n, panNumbers)
		return NRandomNumbersAmongZ(n, panNumbers)

	func RandomNNumbersInZ(n, panNumbers)
		return NRandomNumbersAmongZ(n, panNumbers)

	func AnyNNumbersInZ(n, panNumbers)
		return NRandomNumbersAmongZ(n, panNumbers)

	func NNumbersInZ(n, panNumbers)
		return NRandomNumbersAmongZ(n, panNumbers)

	#--

	func NRandomNumbersFromZ(n, panNumbers)
		return NRandomNumbersAmongZ(n, panNumbers)

	func RandomNNumbersFromZ(n, panNumbers)
		return NRandomNumbersAmongZ(n, panNumbers)

	func AnyNNumbersFromZ(n, panNumbers)
		return NRandomNumbersAmongZ(n, panNumbers)

	func NNumbersFromZ(n, panNumbers)
		return NRandomNumbersAmongZ(n, panNumbers)

	#--

	func NRandomNumbersInsideZ(n, panNumbers)
		return NRandomNumbersAmongZ(n, panNumbers)

	func RandomNNumbersInsideZ(n, panNumbers)
		return NRandomNumbersAmongZ(n, panNumbers)

	func AnyNNumbersInsideZ(n, panNumbers)
		return NRandomNumbersAmongZ(n, panNumbers)

	func NNumbersInsideZ(n, panNumbers)
		return NRandomNumbersAmongZ(n, panNumbers)

	#--

	func NRandomNumbersFromInsideZ(n, panNumbers)
		return NRandomNumbersAmongZ(n, panNumbers)

	func RandomNNumbersFromInsideZ(n, panNumbers)
		return NRandomNumbersAmongZ(n, panNumbers)

	func AnyNNumbersFromInsideZ(n, panNumbers)
		return NRandomNumbersAmongZ(n, panNumbers)

	func NNumbersFromInsideZ(n, panNumbers)
		return NRandomNumbersAmongZ(n, panNumbers)

	#>

	#-- UZ/EXTENDED FORM (TODO)

#--

func 2RandomNumbersAmong(panNumbers)
	return NRandomNumbersAmong(2, panNumbers)

	#< @FunctionAlternativeForms

	func TwoRandomNumbersAmong(panNumbers)
		return 2RandomNumbersAmong(panNumbers)

	func Random2NumbersAmong(panNumbers)
		return 2RandomNumbersAmong(panNumbers)

	func RandomTwoNumbersAmong(panNumbers)
		return 2RandomNumbersAmong(panNumbers)

	func Any2NumbersAmong(panNumbers)
		return 2RandomNumbersAmong(panNumbers)

	func AnyTwoNumbersAmong(panNumbers)
		return 2RandomNumbersAmong(panNumbers)

	func 2NumbersAmong(panNumbers)
		return 2RandomNumbersAmong(panNumbers)

	func TwoNumbersAmong(panNumbers)
		return 2RandomNumbersAmong(panNumbers)

	#--

	func 2RandomNumbersIn(panNumbers)
		return 2RandomNumbersAmong(panNumbers)

	func TwoRandomNumbersIn(panNumbers)
		return 2RandomNumbersAmong(panNumbers)

	func Random2NumbersIn(panNumbers)
		return 2RandomNumbersAmong(panNumbers)

	func RandomTwoNumbersIn(panNumbers)
		return 2RandomNumbersAmong(panNumbers)

	func Any2NumbersIn(panNumbers)
		return 2RandomNumbersAmong(panNumbers)

	func AnyTwoNumbersIn(panNumbers)
		return 2RandomNumbersAmong(panNumbers)

	func 2NumbersIn(panNumbers)
		return 2RandomNumbersAmong(panNumbers)

	func TwoNumbersIn(panNumbers)
		return 2RandomNumbersAmong(panNumbers)

	#--

	func 2RandomNumbersFrom(panNumbers)
		return 2RandomNumbersAmong(panNumbers)

	func TwoRandomNumbersFrom(panNumbers)
		return 2RandomNumbersAmong(panNumbers)

	func Random2NumbersFrom(panNumbers)
		return 2RandomNumbersAmong(panNumbers)

	func RandomTwoNumbersFrom(panNumbers)
		return 2RandomNumbersAmong(panNumbers)

	func Any2NumbersFrom(panNumbers)
		return 2RandomNumbersAmong(panNumbers)

	func AnyTwoNumbersFrom(panNumbers)
		return 2RandomNumbersAmong(panNumbers)

	func 2NumbersFrom(panNumbers)
		return 2RandomNumbersAmong(panNumbers)

	func TwoNumbersFrom(panNumbers)
		return 2RandomNumbersAmong(panNumbers)

	#--

	func 2RandomNumbersInside(panNumbers)
		return 2RandomNumbersAmong(panNumbers)

	func TwoRandomNumbersInside(panNumbers)
		return 2RandomNumbersAmong(panNumbers)

	func Random2NumbersInside(panNumbers)
		return 2RandomNumbersAmong(panNumbers)

	func RandomTwoNumbersInside(panNumbers)
		return 2RandomNumbersAmong(panNumbers)

	func Any2NumbersInside(panNumbers)
		return 2RandomNumbersAmong(panNumbers)

	func AnyTwoNumbersInside(panNumbers)
		return 2RandomNumbersAmong(panNumbers)

	func 2NumbersInside(panNumbers)
		return 2RandomNumbersAmong(panNumbers)

	func TwoNumbersInside(panNumbers)
		return 2RandomNumbersAmong(panNumbers)

	#--

	func 2RandomNumbersFromInside(panNumbers)
		return 2RandomNumbersAmong(panNumbers)

	func TwoRandomNumbersFromInside(panNumbers)
		return 2RandomNumbersAmong(panNumbers)

	func Random2NumbersFromInside(panNumbers)
		return 2RandomNumbersAmong(panNumbers)

	func RandomTwoNumbersFromInside(panNumbers)
		return 2RandomNumbersAmong(panNumbers)

	func Any2NumbersFromInside(panNumbers)
		return 2RandomNumbersAmong(panNumbers)

	func AnyTwoNumbersFromInside(panNumbers)
		return 2RandomNumbersAmong(panNumbers)

	func 2NumbersFromInside(panNumbers)
		return 2RandomNumbersAmong(panNumbers)

	func TwoNumbersFromInside(panNumbers)
		return 2RandomNumbersAmong(panNumbers)

	#>

#--

func 3RandomNumbersAmong(panNumbers)
	return NRandomNumbersAmong(3, panNumbers)

	#< @FunctionAlternativeForms

	func ThreeRandomNumbersAmong(panNumbers)
		return 3RandomNumbersAmong(panNumbers)

	func Random3NumbersAmong(panNumbers)
		return 3RandomNumbersAmong(panNumbers)

	func RandomThreeNumbersAmong(panNumbers)
		return 3RandomNumbersAmong(panNumbers)

	func Any3NumbersAmong(panNumbers)
		return 3RandomNumbersAmong(panNumbers)

	func AnyThreeNumbersAmong(panNumbers)
		return 3RandomNumbersAmong(panNumbers)

	func 3NumbersAmong(panNumbers)
		return 3RandomNumbersAmong(panNumbers)

	func ThreeNumbersAmong(panNumbers)
		return 3RandomNumbersAmong(panNumbers)

	#--

	func 3RandomNumbersIn(panNumbers)
		return 3RandomNumbersAmong(panNumbers)

	func ThreeRandomNumbersIn(panNumbers)
		return 3RandomNumbersAmong(panNumbers)

	func Random3NumbersIn(panNumbers)
		return 3RandomNumbersAmong(panNumbers)

	func RandomThreeNumbersIn(panNumbers)
		return 3RandomNumbersAmong(panNumbers)

	func Any3NumbersIn(panNumbers)
		return 3RandomNumbersAmong(panNumbers)

	func AnyThreeNumbersIn(panNumbers)
		return 3RandomNumbersAmong(panNumbers)

	func 3NumbersIn(panNumbers)
		return 3RandomNumbersAmong(panNumbers)

	func ThreeNumbersIn(panNumbers)
		return 3RandomNumbersAmong(panNumbers)

	#--

	func 3RandomNumbersFrom(panNumbers)
		return 3RandomNumbersAmong(panNumbers)

	func ThreeRandomNumbersFrom(panNumbers)
		return 3RandomNumbersAmong(panNumbers)

	func Random3NumbersFrom(panNumbers)
		return 3RandomNumbersAmong(panNumbers)

	func RandomThreeNumbersFrom(panNumbers)
		return 3RandomNumbersAmong(panNumbers)

	func Any3NumbersFrom(panNumbers)
		return 3RandomNumbersAmong(panNumbers)

	func AnyThreeNumbersFrom(panNumbers)
		return 3RandomNumbersAmong(panNumbers)

	func 3NumbersFrom(panNumbers)
		return 3RandomNumbersAmong(panNumbers)

	func ThreeNumbersFrom(panNumbers)
		return 3RandomNumbersAmong(panNumbers)

	#--

	func 3RandomNumbersInside(panNumbers)
		return 3RandomNumbersAmong(panNumbers)

	func ThreeRandomNumbersInside(panNumbers)
		return 3RandomNumbersAmong(panNumbers)

	func Random3NumbersInside(panNumbers)
		return 3RandomNumbersAmong(panNumbers)

	func RandomThreeNumbersInside(panNumbers)
		return 3RandomNumbersAmong(panNumbers)

	func Any3NumbersInside(panNumbers)
		return 3RandomNumbersAmong(panNumbers)

	func AnyThreeNumbersInside(panNumbers)
		return 3RandomNumbersAmong(panNumbers)

	func 3NumbersInside(panNumbers)
		return 3RandomNumbersAmong(panNumbers)

	func ThreeNumbersInside(panNumbers)
		return 3RandomNumbersAmong(panNumbers)

	#--

	func 3RandomNumbersFromInside(panNumbers)
		return 3RandomNumbersAmong(panNumbers)

	func ThreeRandomNumbersFromInside(panNumbers)
		return 3RandomNumbersAmong(panNumbers)

	func Random3NumbersFromInside(panNumbers)
		return 3RandomNumbersAmong(panNumbers)

	func RandomThreeNumbersFromInside(panNumbers)
		return 3RandomNumbersAmong(panNumbers)

	func Any3NumbersFromInside(panNumbers)
		return 3RandomNumbersAmong(panNumbers)

	func AnyThreeNumbersFromInside(panNumbers)
		return 3RandomNumbersAmong(panNumbers)

	func 3NumbersFromInside(panNumbers)
		return 3RandomNumbersAmong(panNumbers)

	func ThreeNumbersFromInside(panNumbers)
		return 3RandomNumbersAmong(panNumbers)

	#>

#--

func 4RandomNumbersAmong(panNumbers)
	return NRandomNumbersAmong(4, panNumbers)

	#< @FunctionAlternativeForms

	func FourRandomNumbersAmong(panNumbers)
		return 4RandomNumbersAmong(panNumbers)

	func Random4NumbersAmong(panNumbers)
		return 4RandomNumbersAmong(panNumbers)

	func RandomFourNumbersAmong(panNumbers)
		return 4RandomNumbersAmong(panNumbers)

	func Any4NumbersAmong(panNumbers)
		return 4RandomNumbersAmong(panNumbers)

	func AnyFourNumbersAmong(panNumbers)
		return 4RandomNumbersAmong(panNumbers)

	func 4NumbersAmong(panNumbers)
		return 4RandomNumbersAmong(panNumbers)

	func FourNumbersAmong(panNumbers)
		return 4RandomNumbersAmong(panNumbers)

	#--

	func 4RandomNumbersIn(panNumbers)
		return 4RandomNumbersAmong(panNumbers)

	func FourRandomNumbersIn(panNumbers)
		return 4RandomNumbersAmong(panNumbers)

	func Random4NumbersIn(panNumbers)
		return 4RandomNumbersAmong(panNumbers)

	func RandomFourNumbersIn(panNumbers)
		return 4RandomNumbersAmong(panNumbers)

	func Any4NumbersIn(panNumbers)
		return 4RandomNumbersAmong(panNumbers)

	func AnyFourNumbersIn(panNumbers)
		return 4RandomNumbersAmong(panNumbers)

	func 4NumbersIn(panNumbers)
		return 4RandomNumbersAmong(panNumbers)

	func FourNumbersIn(panNumbers)
		return 4RandomNumbersAmong(panNumbers)

	#--

	func 4RandomNumbersFrom(panNumbers)
		return 4RandomNumbersAmong(panNumbers)

	func FourRandomNumbersFrom(panNumbers)
		return 4RandomNumbersAmong(panNumbers)

	func Random4NumbersFrom(panNumbers)
		return 4RandomNumbersAmong(panNumbers)

	func RandomFourNumbersFrom(panNumbers)
		return 4RandomNumbersAmong(panNumbers)

	func Any4NumbersFrom(panNumbers)
		return 4RandomNumbersAmong(panNumbers)

	func AnyFourNumbersFrom(panNumbers)
		return 4RandomNumbersAmong(panNumbers)

	func 4NumbersFrom(panNumbers)
		return 4RandomNumbersAmong(panNumbers)

	func FourNumbersFrom(panNumbers)
		return 4RandomNumbersAmong(panNumbers)

	#--

	func 4RandomNumbersInside(panNumbers)
		return 4RandomNumbersAmong(panNumbers)

	func FourRandomNumbersInside(panNumbers)
		return 4RandomNumbersAmong(panNumbers)

	func Random4NumbersInside(panNumbers)
		return 4RandomNumbersAmong(panNumbers)

	func RandomFourNumbersInside(panNumbers)
		return 4RandomNumbersAmong(panNumbers)

	func Any4NumbersInside(panNumbers)
		return 4RandomNumbersAmong(panNumbers)

	func AnyFourNumbersInside(panNumbers)
		return 4RandomNumbersAmong(panNumbers)

	func 4NumbersInside(panNumbers)
		return 4RandomNumbersAmong(panNumbers)

	func FourNumbersInside(panNumbers)
		return 4RandomNumbersAmong(panNumbers)

	#--

	func 4RandomNumbersFromInside(panNumbers)
		return 4RandomNumbersAmong(panNumbers)

	func FourRandomNumbersFromInside(panNumbers)
		return 4RandomNumbersAmong(panNumbers)

	func Random4NumbersFromInside(panNumbers)
		return 4RandomNumbersAmong(panNumbers)

	func RandomFourNumbersFromInside(panNumbers)
		return 4RandomNumbersAmong(panNumbers)

	func Any4NumbersFromInside(panNumbers)
		return 4RandomNumbersAmong(panNumbers)

	func AnyFourNumbersFromInside(panNumbers)
		return 4RandomNumbersAmong(panNumbers)

	func 4NumbersFromInside(panNumbers)
		return 4RandomNumbersAmong(panNumbers)

	func FourNumbersFromInside(panNumbers)
		return 4RandomNumbersAmong(panNumbers)

	#>

#--

func 5RandomNumbersAmong(panNumbers)
	return NRandomNumbersAmong(5, panNumbers)

	#< @FunctionAlternativeForms

	func FiveRandomNumbersAmong(panNumbers)
		return 5RandomNumbersAmong(panNumbers)

	func Random5NumbersAmong(panNumbers)
		return 5RandomNumbersAmong(panNumbers)

	func RandomFiveNumbersAmong(panNumbers)
		return 5RandomNumbersAmong(panNumbers)

	func Any5NumbersAmong(panNumbers)
		return 5RandomNumbersAmong(panNumbers)

	func AnyFiveNumbersAmong(panNumbers)
		return 5RandomNumbersAmong(panNumbers)

	func 5NumbersAmong(panNumbers)
		return 5RandomNumbersAmong(panNumbers)

	func FiveNumbersAmong(panNumbers)
		return 5RandomNumbersAmong(panNumbers)

	#--

	func 5RandomNumbersIn(panNumbers)
		return 5RandomNumbersAmong(panNumbers)

	func FiveRandomNumbersIn(panNumbers)
		return 5RandomNumbersAmong(panNumbers)

	func Random5NumbersIn(panNumbers)
		return 5RandomNumbersAmong(panNumbers)

	func RandomFiveNumbersIn(panNumbers)
		return 5RandomNumbersAmong(panNumbers)

	func Any5NumbersIn(panNumbers)
		return 5RandomNumbersAmong(panNumbers)

	func AnyFiveNumbersIn(panNumbers)
		return 5RandomNumbersAmong(panNumbers)

	func 5NumbersIn(panNumbers)
		return 5RandomNumbersAmong(panNumbers)

	func FiveNumbersIn(panNumbers)
		return 5RandomNumbersAmong(panNumbers)

	#--

	func 5RandomNumbersFrom(panNumbers)
		return 5RandomNumbersAmong(panNumbers)

	func FiveRandomNumbersFrom(panNumbers)
		return 5RandomNumbersAmong(panNumbers)

	func Random5NumbersFrom(panNumbers)
		return 5RandomNumbersAmong(panNumbers)

	func RandomFiveNumbersFrom(panNumbers)
		return 5RandomNumbersAmong(panNumbers)

	func Any5NumbersFrom(panNumbers)
		return 5RandomNumbersAmong(panNumbers)

	func AnyFiveNumbersFrom(panNumbers)
		return 5RandomNumbersAmong(panNumbers)

	func 5NumbersFrom(panNumbers)
		return 5RandomNumbersAmong(panNumbers)

	func FiveNumbersFrom(panNumbers)
		return 5RandomNumbersAmong(panNumbers)

	#--

	func 5RandomNumbersInside(panNumbers)
		return 5RandomNumbersAmong(panNumbers)

	func FiveRandomNumbersInside(panNumbers)
		return 5RandomNumbersAmong(panNumbers)

	func Random5NumbersInside(panNumbers)
		return 5RandomNumbersAmong(panNumbers)

	func RandomFiveNumbersInside(panNumbers)
		return 5RandomNumbersAmong(panNumbers)

	func Any5NumbersInside(panNumbers)
		return 5RandomNumbersAmong(panNumbers)

	func AnyFiveNumbersInside(panNumbers)
		return 5RandomNumbersAmong(panNumbers)

	func 5NumbersInside(panNumbers)
		return 5RandomNumbersAmong(panNumbers)

	func FiveNumbersInside(panNumbers)
		return 5RandomNumbersAmong(panNumbers)

	#--

	func 5RandomNumbersFromInside(panNumbers)
		return 5RandomNumbersAmong(panNumbers)

	func FiveRandomNumbersFromInside(panNumbers)
		return 5RandomNumbersAmong(panNumbers)

	func Random5NumbersFromInside(panNumbers)
		return 5RandomNumbersAmong(panNumbers)

	func RandomFiveNumbersFromInside(panNumbers)
		return 5RandomNumbersAmong(panNumbers)

	func Any5NumbersFromInside(panNumbers)
		return 5RandomNumbersAmong(panNumbers)

	func AnyFiveNumbersFromInside(panNumbers)
		return 5RandomNumbersAmong(panNumbers)

	func 5NumbersFromInside(panNumbers)
		return 5RandomNumbersAmong(panNumbers)

	func FiveNumbersFromInside(panNumbers)
		return 5RandomNumbersAmong(panNumbers)

	#>

#--

func 6RandomNumbersAmong(panNumbers)
	return NRandomNumbersAmong(6, panNumbers)

	#< @FunctionAlternativeForms

	func SixRandomNumbersAmong(panNumbers)
		return 6RandomNumbersAmong(panNumbers)

	func Random6NumbersAmong(panNumbers)
		return 6RandomNumbersAmong(panNumbers)

	func RandomSixNumbersAmong(panNumbers)
		return 6RandomNumbersAmong(panNumbers)

	func Any6NumbersAmong(panNumbers)
		return 6RandomNumbersAmong(panNumbers)

	func AnySixNumbersAmong(panNumbers)
		return 6RandomNumbersAmong(panNumbers)

	func 6NumbersAmong(panNumbers)
		return 6RandomNumbersAmong(panNumbers)

	func SixNumbersAmong(panNumbers)
		return 6RandomNumbersAmong(panNumbers)

	#--

	func 6RandomNumbersIn(panNumbers)
		return 6RandomNumbersAmong(panNumbers)

	func SixRandomNumbersIn(panNumbers)
		return 6RandomNumbersAmong(panNumbers)

	func Random6NumbersIn(panNumbers)
		return 6RandomNumbersAmong(panNumbers)

	func RandomSixNumbersIn(panNumbers)
		return 6RandomNumbersAmong(panNumbers)

	func Any6NumbersIn(panNumbers)
		return 6RandomNumbersAmong(panNumbers)

	func AnySixNumbersIn(panNumbers)
		return 6RandomNumbersAmong(panNumbers)

	func 6NumbersIn(panNumbers)
		return 6RandomNumbersAmong(panNumbers)

	func SixNumbersIn(panNumbers)
		return 6RandomNumbersAmong(panNumbers)

	#--

	func 6RandomNumbersFrom(panNumbers)
		return 6RandomNumbersAmong(panNumbers)

	func SixRandomNumbersFrom(panNumbers)
		return 6RandomNumbersAmong(panNumbers)

	func Random6NumbersFrom(panNumbers)
		return 6RandomNumbersAmong(panNumbers)

	func RandomSixNumbersFrom(panNumbers)
		return 6RandomNumbersAmong(panNumbers)

	func Any6NumbersFrom(panNumbers)
		return 6RandomNumbersAmong(panNumbers)

	func AnySixNumbersFrom(panNumbers)
		return 6RandomNumbersAmong(panNumbers)

	func 6NumbersFrom(panNumbers)
		return 6RandomNumbersAmong(panNumbers)

	func SixNumbersFrom(panNumbers)
		return 6RandomNumbersAmong(panNumbers)

	#--

	func 6RandomNumbersInside(panNumbers)
		return 6RandomNumbersAmong(panNumbers)

	func SixRandomNumbersInside(panNumbers)
		return 6RandomNumbersAmong(panNumbers)

	func Random6NumbersInside(panNumbers)
		return 6RandomNumbersAmong(panNumbers)

	func RandomSixNumbersInside(panNumbers)
		return 6RandomNumbersAmong(panNumbers)

	func Any6NumbersInside(panNumbers)
		return 6RandomNumbersAmong(panNumbers)

	func AnySixNumbersInside(panNumbers)
		return 6RandomNumbersAmong(panNumbers)

	func 6NumbersInside(panNumbers)
		return 6RandomNumbersAmong(panNumbers)

	func SixNumbersInside(panNumbers)
		return 6RandomNumbersAmong(panNumbers)

	#--

	func 6RandomNumbersFromInside(panNumbers)
		return 6RandomNumbersAmong(panNumbers)

	func SixRandomNumbersFromInside(panNumbers)
		return 6RandomNumbersAmong(panNumbers)

	func Random6NumbersFromInside(panNumbers)
		return 6RandomNumbersAmong(panNumbers)

	func RandomSixNumbersFromInside(panNumbers)
		return 6RandomNumbersAmong(panNumbers)

	func Any6NumbersFromInside(panNumbers)
		return 6RandomNumbersAmong(panNumbers)

	func AnySixNumbersFromInside(panNumbers)
		return 6RandomNumbersAmong(panNumbers)

	func 6NumbersFromInside(panNumbers)
		return 6RandomNumbersAmong(panNumbers)

	func SixNumbersFromInside(panNumbers)
		return 6RandomNumbersAmong(panNumbers)

	#>

#--

func 7RandomNumbersAmong(panNumbers)
	return NRandomNumbersAmong(7, panNumbers)

	#< @FunctionAlternativeForms

	func SevenRandomNumbersAmong(panNumbers)
		return 7RandomNumbersAmong(panNumbers)

	func Random7NumbersAmong(panNumbers)
		return 7RandomNumbersAmong(panNumbers)

	func RandomSevenNumbersAmong(panNumbers)
		return 7RandomNumbersAmong(panNumbers)

	func Any7NumbersAmong(panNumbers)
		return 7RandomNumbersAmong(panNumbers)

	func AnySevenNumbersAmong(panNumbers)
		return 7RandomNumbersAmong(panNumbers)

	func 7NumbersAmong(panNumbers)
		return 7RandomNumbersAmong(panNumbers)

	func SevenNumbersAmong(panNumbers)
		return 7RandomNumbersAmong(panNumbers)

	#--

	func 7RandomNumbersIn(panNumbers)
		return 7RandomNumbersAmong(panNumbers)

	func SevenRandomNumbersIn(panNumbers)
		return 7RandomNumbersAmong(panNumbers)

	func Random7NumbersIn(panNumbers)
		return 7RandomNumbersAmong(panNumbers)

	func RandomSevenNumbersIn(panNumbers)
		return 7RandomNumbersAmong(panNumbers)

	func Any7NumbersIn(panNumbers)
		return 7RandomNumbersAmong(panNumbers)

	func AnySevenNumbersIn(panNumbers)
		return 7RandomNumbersAmong(panNumbers)

	func 7NumbersIn(panNumbers)
		return 7RandomNumbersAmong(panNumbers)

	func SevenNumbersIn(panNumbers)
		return 7RandomNumbersAmong(panNumbers)

	#--

	func 7RandomNumbersFrom(panNumbers)
		return 7RandomNumbersAmong(panNumbers)

	func SevenRandomNumbersFrom(panNumbers)
		return 7RandomNumbersAmong(panNumbers)

	func Random7NumbersFrom(panNumbers)
		return 7RandomNumbersAmong(panNumbers)

	func RandomSevenNumbersFrom(panNumbers)
		return 7RandomNumbersAmong(panNumbers)

	func Any7NumbersFrom(panNumbers)
		return 7RandomNumbersAmong(panNumbers)

	func AnySevenNumbersFrom(panNumbers)
		return 7RandomNumbersAmong(panNumbers)

	func 7NumbersFrom(panNumbers)
		return 7RandomNumbersAmong(panNumbers)

	func SevenNumbersFrom(panNumbers)
		return 7RandomNumbersAmong(panNumbers)

	#--

	func 7RandomNumbersInside(panNumbers)
		return 7RandomNumbersAmong(panNumbers)

	func SevenRandomNumbersInside(panNumbers)
		return 7RandomNumbersAmong(panNumbers)

	func Random7NumbersInside(panNumbers)
		return 7RandomNumbersAmong(panNumbers)

	func RandomSevenNumbersInside(panNumbers)
		return 7RandomNumbersAmong(panNumbers)

	func Any7NumbersInside(panNumbers)
		return 7RandomNumbersAmong(panNumbers)

	func AnySevenNumbersInside(panNumbers)
		return 7RandomNumbersAmong(panNumbers)

	func 7NumbersInside(panNumbers)
		return 7RandomNumbersAmong(panNumbers)

	func SevenNumbersInside(panNumbers)
		return 7RandomNumbersAmong(panNumbers)

	#--

	func 7RandomNumbersFromInside(panNumbers)
		return 7RandomNumbersAmong(panNumbers)

	func SevenRandomNumbersFromInside(panNumbers)
		return 7RandomNumbersAmong(panNumbers)

	func Random7NumbersFromInside(panNumbers)
		return 7RandomNumbersAmong(panNumbers)

	func RandomSevenNumbersFromInside(panNumbers)
		return 7RandomNumbersAmong(panNumbers)

	func Any7NumbersFromInside(panNumbers)
		return 7RandomNumbersAmong(panNumbers)

	func AnySevenNumbersFromInside(panNumbers)
		return 7RandomNumbersAmong(panNumbers)

	func 7NumbersFromInside(panNumbers)
		return 7RandomNumbersAmong(panNumbers)

	func SevenNumbersFromInside(panNumbers)
		return 7RandomNumbersAmong(panNumbers)

	#>

#--

func 8RandomNumbersAmong(panNumbers)
	return NRandomNumbersAmong(8, panNumbers)

	#< @FunctionAlternativeForms

	func EightRandomNumbersAmong(panNumbers)
		return 8RandomNumbersAmong(panNumbers)

	func Random8NumbersAmong(panNumbers)
		return 8RandomNumbersAmong(panNumbers)

	func RandomEightNumbersAmong(panNumbers)
		return 8RandomNumbersAmong(panNumbers)

	func Any8NumbersAmong(panNumbers)
		return 8RandomNumbersAmong(panNumbers)

	func AnyEightNumbersAmong(panNumbers)
		return 8RandomNumbersAmong(panNumbers)

	func 8NumbersAmong(panNumbers)
		return 8RandomNumbersAmong(panNumbers)

	func EightNumbersAmong(panNumbers)
		return 8RandomNumbersAmong(panNumbers)

	#--

	func 8RandomNumbersIn(panNumbers)
		return 8RandomNumbersAmong(panNumbers)

	func EightRandomNumbersIn(panNumbers)
		return 8RandomNumbersAmong(panNumbers)

	func Random8NumbersIn(panNumbers)
		return 8RandomNumbersAmong(panNumbers)

	func RandomEightNumbersIn(panNumbers)
		return 8RandomNumbersAmong(panNumbers)

	func Any8NumbersIn(panNumbers)
		return 8RandomNumbersAmong(panNumbers)

	func AnyEightNumbersIn(panNumbers)
		return 8RandomNumbersAmong(panNumbers)

	func 8NumbersIn(panNumbers)
		return 8RandomNumbersAmong(panNumbers)

	func EightNumbersIn(panNumbers)
		return 8RandomNumbersAmong(panNumbers)

	#--

	func 8RandomNumbersFrom(panNumbers)
		return 8RandomNumbersAmong(panNumbers)

	func EightRandomNumbersFrom(panNumbers)
		return 8RandomNumbersAmong(panNumbers)

	func Random8NumbersFrom(panNumbers)
		return 8RandomNumbersAmong(panNumbers)

	func RandomEightNumbersFrom(panNumbers)
		return 8RandomNumbersAmong(panNumbers)

	func Any8NumbersFrom(panNumbers)
		return 8RandomNumbersAmong(panNumbers)

	func AnyEightNumbersFrom(panNumbers)
		return 8RandomNumbersAmong(panNumbers)

	func 8NumbersFrom(panNumbers)
		return 8RandomNumbersAmong(panNumbers)

	func EightNumbersFrom(panNumbers)
		return 8RandomNumbersAmong(panNumbers)

	#--

	func 8RandomNumbersInside(panNumbers)
		return 8RandomNumbersAmong(panNumbers)

	func EightRandomNumbersInside(panNumbers)
		return 8RandomNumbersAmong(panNumbers)

	func Random8NumbersInside(panNumbers)
		return 8RandomNumbersAmong(panNumbers)

	func RandomEightNumbersInside(panNumbers)
		return 8RandomNumbersAmong(panNumbers)

	func Any8NumbersInside(panNumbers)
		return 8RandomNumbersAmong(panNumbers)

	func AnyEightNumbersInside(panNumbers)
		return 8RandomNumbersAmong(panNumbers)

	func 8NumbersInside(panNumbers)
		return 8RandomNumbersAmong(panNumbers)

	func EightNumbersInside(panNumbers)
		return 8RandomNumbersAmong(panNumbers)

	#--

	func 8RandomNumbersFromInside(panNumbers)
		return 8RandomNumbersAmong(panNumbers)

	func EightRandomNumbersFromInside(panNumbers)
		return 8RandomNumbersAmong(panNumbers)

	func Random8NumbersFromInside(panNumbers)
		return 8RandomNumbersAmong(panNumbers)

	func RandomEightNumbersFromInside(panNumbers)
		return 8RandomNumbersAmong(panNumbers)

	func Any8NumbersFromInside(panNumbers)
		return 8RandomNumbersAmong(panNumbers)

	func AnyEightNumbersFromInside(panNumbers)
		return 8RandomNumbersAmong(panNumbers)

	func 8NumbersFromInside(panNumbers)
		return 8RandomNumbersAmong(panNumbers)

	func EightNumbersFromInside(panNumbers)
		return 8RandomNumbersAmong(panNumbers)

	#>

#--

func 9RandomNumbersAmong(panNumbers)
	return NRandomNumbersAmong(9, panNumbers)

	#< @FunctionAlternativeForms

	func NineRandomNumbersAmong(panNumbers)
		return 9RandomNumbersAmong(panNumbers)

	func Random9NumbersAmong(panNumbers)
		return 9RandomNumbersAmong(panNumbers)

	func RandomNineNumbersAmong(panNumbers)
		return 9RandomNumbersAmong(panNumbers)

	func Any9NumbersAmong(panNumbers)
		return 9RandomNumbersAmong(panNumbers)

	func AnyNineNumbersAmong(panNumbers)
		return 9RandomNumbersAmong(panNumbers)

	func 9NumbersAmong(panNumbers)
		return 9RandomNumbersAmong(panNumbers)

	func NineNumbersAmong(panNumbers)
		return 9RandomNumbersAmong(panNumbers)

	#--

	func 9RandomNumbersIn(panNumbers)
		return 9RandomNumbersAmong(panNumbers)

	func NineRandomNumbersIn(panNumbers)
		return 9RandomNumbersAmong(panNumbers)

	func Random9NumbersIn(panNumbers)
		return 9RandomNumbersAmong(panNumbers)

	func RandomNineNumbersIn(panNumbers)
		return 9RandomNumbersAmong(panNumbers)

	func Any9NumbersIn(panNumbers)
		return 9RandomNumbersAmong(panNumbers)

	func AnyNineNumbersIn(panNumbers)
		return 9RandomNumbersAmong(panNumbers)

	func 9NumbersIn(panNumbers)
		return 9RandomNumbersAmong(panNumbers)

	func NineNumbersIn(panNumbers)
		return 9RandomNumbersAmong(panNumbers)

	#--

	func 9RandomNumbersFrom(panNumbers)
		return 9RandomNumbersAmong(panNumbers)

	func NineRandomNumbersFrom(panNumbers)
		return 9RandomNumbersAmong(panNumbers)

	func Random9NumbersFrom(panNumbers)
		return 9RandomNumbersAmong(panNumbers)

	func RandomNineNumbersFrom(panNumbers)
		return 9RandomNumbersAmong(panNumbers)

	func Any9NumbersFrom(panNumbers)
		return 9RandomNumbersAmong(panNumbers)

	func AnyNineNumbersFrom(panNumbers)
		return 9RandomNumbersAmong(panNumbers)

	func 9NumbersFrom(panNumbers)
		return 9RandomNumbersAmong(panNumbers)

	func NineNumbersFrom(panNumbers)
		return 9RandomNumbersAmong(panNumbers)

	#--

	func 9RandomNumbersInside(panNumbers)
		return 9RandomNumbersAmong(panNumbers)

	func NineRandomNumbersInside(panNumbers)
		return 9RandomNumbersAmong(panNumbers)

	func Random9NumbersInside(panNumbers)
		return 9RandomNumbersAmong(panNumbers)

	func RandomNineNumbersInside(panNumbers)
		return 9RandomNumbersAmong(panNumbers)

	func Any9NumbersInside(panNumbers)
		return 9RandomNumbersAmong(panNumbers)

	func AnyNineNumbersInside(panNumbers)
		return 9RandomNumbersAmong(panNumbers)

	func 9NumbersInside(panNumbers)
		return 9RandomNumbersAmong(panNumbers)

	func NineNumbersInside(panNumbers)
		return 9RandomNumbersAmong(panNumbers)

	#--

	func 9RandomNumbersFromInside(panNumbers)
		return 9RandomNumbersAmong(panNumbers)

	func NineRandomNumbersFromInside(panNumbers)
		return 9RandomNumbersAmong(panNumbers)

	func Random9NumbersFromInside(panNumbers)
		return 9RandomNumbersAmong(panNumbers)

	func RandomNineNumbersFromInside(panNumbers)
		return 9RandomNumbersAmong(panNumbers)

	func Any9NumbersFromInside(panNumbers)
		return 9RandomNumbersAmong(panNumbers)

	func AnyNineNumbersFromInside(panNumbers)
		return 9RandomNumbersAmong(panNumbers)

	func 9NumbersFromInside(panNumbers)
		return 9RandomNumbersAmong(panNumbers)

	func NineNumbersFromInside(panNumbers)
		return 9RandomNumbersAmong(panNumbers)

	#>

#--

func 10RandomNumbersAmong(panNumbers)
	return NRandomNumbersAmong(10, panNumbers)

	#< @FunctionAlternativeForms

	func TenRandomNumbersAmong(panNumbers)
		return 10RandomNumbersAmong(panNumbers)

	func Random10NumbersAmong(panNumbers)
		return 10RandomNumbersAmong(panNumbers)

	func RandomTenNumbersAmong(panNumbers)
		return 10RandomNumbersAmong(panNumbers)

	func Any10NumbersAmong(panNumbers)
		return 10RandomNumbersAmong(panNumbers)

	func AnyTenNumbersAmong(panNumbers)
		return 10RandomNumbersAmong(panNumbers)

	func 10NumbersAmong(panNumbers)
		return 10RandomNumbersAmong(panNumbers)

	func TenNumbersAmong(panNumbers)
		return 10RandomNumbersAmong(panNumbers)

	#--

	func 10RandomNumbersIn(panNumbers)
		return 10RandomNumbersAmong(panNumbers)

	func TenRandomNumbersIn(panNumbers)
		return 10RandomNumbersAmong(panNumbers)

	func Random10NumbersIn(panNumbers)
		return 10RandomNumbersAmong(panNumbers)

	func RandomTenNumbersIn(panNumbers)
		return 10RandomNumbersAmong(panNumbers)

	func Any10NumbersIn(panNumbers)
		return 10RandomNumbersAmong(panNumbers)

	func AnyTenNumbersIn(panNumbers)
		return 10RandomNumbersAmong(panNumbers)

	func 10NumbersIn(panNumbers)
		return 10RandomNumbersAmong(panNumbers)

	func TenNumbersIn(panNumbers)
		return 10RandomNumbersAmong(panNumbers)

	#--

	func 10RandomNumbersFrom(panNumbers)
		return 10RandomNumbersAmong(panNumbers)

	func TenRandomNumbersFrom(panNumbers)
		return 10RandomNumbersAmong(panNumbers)

	func Random10NumbersFrom(panNumbers)
		return 10RandomNumbersAmong(panNumbers)

	func RandomTenNumbersFrom(panNumbers)
		return 10RandomNumbersAmong(panNumbers)

	func Any10NumbersFrom(panNumbers)
		return 10RandomNumbersAmong(panNumbers)

	func AnyTenNumbersFrom(panNumbers)
		return 10RandomNumbersAmong(panNumbers)

	func 10NumbersFrom(panNumbers)
		return 10RandomNumbersAmong(panNumbers)

	func TenNumbersFrom(panNumbers)
		return 10RandomNumbersAmong(panNumbers)

	#--

	func 10RandomNumbersInside(panNumbers)
		return 10RandomNumbersAmong(panNumbers)

	func TenRandomNumbersInside(panNumbers)
		return 10RandomNumbersAmong(panNumbers)

	func Random10NumbersInside(panNumbers)
		return 10RandomNumbersAmong(panNumbers)

	func RandomTenNumbersInside(panNumbers)
		return 10RandomNumbersAmong(panNumbers)

	func Any10NumbersInside(panNumbers)
		return 10RandomNumbersAmong(panNumbers)

	func AnyTenNumbersInside(panNumbers)
		return 10RandomNumbersAmong(panNumbers)

	func 10NumbersInside(panNumbers)
		return 10RandomNumbersAmong(panNumbers)

	func TenNumbersInside(panNumbers)
		return 10RandomNumbersAmong(panNumbers)

	#--

	func 10RandomNumbersFromInside(panNumbers)
		return 10RandomNumbersAmong(panNumbers)

	func TenRandomNumbersFromInside(panNumbers)
		return 10RandomNumbersAmong(panNumbers)

	func Random10NumbersFromInside(panNumbers)
		return 10RandomNumbersAmong(panNumbers)

	func RandomTenNumbersFromInside(panNumbers)
		return 10RandomNumbersAmong(panNumbers)

	func Any10NumbersFromInside(panNumbers)
		return 10RandomNumbersAmong(panNumbers)

	func AnyTenNumbersFromInside(panNumbers)
		return 10RandomNumbersAmong(panNumbers)

	func 10NumbersFromInside(panNumbers)
		return 10RandomNumbersAmong(panNumbers)

	func TenNumbersFromInside(panNumbers)
		return 10RandomNumbersAmong(panNumbers)

	#>

#--

func NRandomNumbersAmongU(n, panNumbers)

	# NOTE: The generated numbers are guranteed to be unique

	nLen = len(panNumbers)
	nRandom = ARandomNumberBetween(1, nLen)

	anResult = []
	anSeen = []

	nTrials = 0

	for i = 1 to nRandom
		nPos = ARandomNumberBetween(1, nLen)
		
		if NOT ring_find(anSeen, nPos)
			anResult + panNumbers[nPos]
			anSeen + nPos
		else
			i--

			# A risky implementation. If the engine tries +1000 times
			# without generating a unique random number than abort the process!

			nTrials++
			if nTrials > 1000
				StzRaise("Can't generate a unique random number!")
			ok
		ok
	next

	return anResult

	#< @FunctionAlternativeForms

	func RandomNNumbersAmongU(n, panNumbers)
		return NRandomNumbersAmongU(n, panNumbers)

	func AnyNNumbersAmongU(n, panNumbers)
		return NRandomNumbersAmongU(n, panNumbers)

	func NNumbersAmongU(n, panNumbers)
		return NRandomNumbersAmongU(n, panNumbers)

	#--

	func NRandomNumbersInU(n, panNumbers)
		return NRandomNumbersAmongU(n, panNumbers)

	func RandomNNumbersInU(n, panNumbers)
		return NRandomNumbersAmongU(n, panNumbers)

	func AnyNNumbersInU(n, panNumbers)
		return NRandomNumbersAmongU(n, panNumbers)

	func NNumbersInU(n, panNumbers)
		return NRandomNumbersAmongU(n, panNumbers)

	#--

	func NRandomNumbersFromU(n, panNumbers)
		return NRandomNumbersAmongU(n, panNumbers)

	func RandomNNumbersFromU(n, panNumbers)
		return NRandomNumbersAmongU(n, panNumbers)

	func AnyNNumbersFromU(n, panNumbers)
		return NRandomNumbersAmongU(n, panNumbers)

	func NNumbersFromU(n, panNumbers)
		return NRandomNumbersAmongU(n, panNumbers)

	#--

	func NRandomNumbersInsideU(n, panNumbers)
		return NRandomNumbersAmongU(n, panNumbers)

	func RandomNNumbersInsideU(n, panNumbers)
		return NRandomNumbersAmongU(n, panNumbers)

	func AnyNNumbersInsideU(n, panNumbers)
		return NRandomNumbersAmongU(n, panNumbers)

	func NNumbersInsideU(n, panNumbers)
		return NRandomNumbersAmongU(n, panNumbers)

	#--

	func NRandomNumbersFromInsideU(n, panNumbers)
		return NRandomNumbersAmongU(n, panNumbers)

	func RandomNNumbersFromInsideU(n, panNumbers)
		return NRandomNumbersAmongU(n, panNumbers)

	func AnyNNumbersFromInsideU(n, panNumbers)
		return NRandomNumbersAmongU(n, panNumbers)

	func NNumbersFromInsideU(n, panNumbers)
		return NRandomNumbersAmongU(n, panNumbers)

	#>

func NRandomNumbersAmongUZ(n, panNumbers)

	nLen = len(panNumbers)
	nRandom = ARandomNumberBetween(1, nLen)

	aResult = []
	anSeen = []

	nTrials = 0

	for i = 1 to nRandom
		nPos = ARandomNumberBetween(1, nLen)
		
		if NOT ring_find(anSeen, nPos)
			aResult + [ panNumbers[nPos], nPos ]
			anSeen + nPos
		else
			i--

			# A risky implementation. If the engine tries +1000 times
			# without generating a unique random number than abort the process!

			nTrials++
			if nTrials > 1000
				StzRaise("Can't generate a unique random number!")
			ok
		ok
	next

	return aResult

	#< @FunctionAlternativeForms

	func RandomNNumbersAmongUZ(n, panNumbers)
		return NRandomNumbersAmongUZ(n, panNumbers)

	func AnyNNumbersAmongUZ(n, panNumbers)
		return NRandomNumbersAmongUZ(n, panNumbers)

	func NNumbersAmongUZ(n, panNumbers)
		return NRandomNumbersAmongUZ(n, panNumbers)

	#--

	func NRandomNumbersInUZ(n, panNumbers)
		return NRandomNumbersAmongUZ(n, panNumbers)

	func RandomNNumbersInUZ(n, panNumbers)
		return NRandomNumbersAmongUZ(n, panNumbers)

	func AnyNNumbersInUZ(n, panNumbers)
		return NRandomNumbersAmongUZ(n, panNumbers)

	func NNumbersInUZ(n, panNumbers)
		return NRandomNumbersAmongUZ(n, panNumbers)

	#--

	func NRandomNumbersFromUZ(n, panNumbers)
		return NRandomNumbersAmongUZ(n, panNumbers)

	func RandomNNumbersFromUZ(n, panNumbers)
		return NRandomNumbersAmongUZ(n, panNumbers)

	func AnyNNumbersFromUZ(n, panNumbers)
		return NRandomNumbersAmongUZ(n, panNumbers)

	func NNumbersFromUZ(n, panNumbers)
		return NRandomNumbersAmongUZ(n, panNumbers)

	#--

	func NRandomNumbersInsideUZ(n, panNumbers)
		return NRandomNumbersAmongUZ(n, panNumbers)

	func RandomNNumbersInsideUZ(n, panNumbers)
		return NRandomNumbersAmongUZ(n, panNumbers)

	func AnyNNumbersInsideUZ(n, panNumbers)
		return NRandomNumbersAmongUZ(n, panNumbers)

	func NNumbersInsideUZ(n, panNumbers)
		return NRandomNumbersAmongUZ(n, panNumbers)

	#--

	func NRandomNumbersFromInsideUZ(n, panNumbers)
		return NRandomNumbersAmongUZ(n, panNumbers)

	func RandomNNumbersFromInsideUZ(n, panNumbers)
		return NRandomNumbersAmongUZ(n, panNumbers)

	func AnyNNumbersFromInsideUZ(n, panNumbers)
		return NRandomNumbersAmongUZ(n, panNumbers)

	func NNumbersFromInsideUZ(n, panNumbers)
		return NRandomNumbersAmongUZ(n, panNumbers)

	#>
