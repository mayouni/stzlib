#------------------------------------------------------------#
#                                                            #
#   Class        : stzNumber                                 #
#   Description  : The class for managing softanza numbers   #
#   Version      : V0.9 (2019, 2025)                         #
#   Author       : Mansour Ayouni (kalidianow@gmail.com)     #
#                                                            #
#============================================================#

/*
	This class expects you to provide it with a normal number or a
	number hosted in a string (if you want to be specific about
	how the number is formatted).

	Internally, the class stores the number always in a string.

	The string must must contain a number in decimal form.

	If the string is NULL then the number is "0".

	Of course, the number must be calculable precisely by Ring 
	(read NOTE hereafter).

	If a type NUMBER is provided, then the class transforms it
	automatically to a string with the round that is active in
	the runtime by the current Ring code.

	This may generate a loss of precision like in the following example:

	o1 = new stzNumber(12.234)
	? o1.Content() #--> "12.23" # if the current round was left at its
				    # default Ring value or has been set
				    # explicitly to decimals(2)

	Therefore, if you want to force a precise round, (and that's why the
	class is made), you should provide a number in string like this:

	o1 = new stzNumber("12.234")
	? o1.Content() #--> "12.234"

	 NOTE
	------

	Double is a 64 bit IEEE 754 double precision Floating Point
	Number (1 bit for the sign, 11 bits for the exponent, and 52* bits
	for the value), _i_.e. double has 15 decimal digits of precision.
	
	Double range is '2.2250738585072014 E-308' to '1.7976931348623158 E+308'.
	Subsequently the size and length varies accordingly.
	It has nothing to do with the language one is using.
	
	<Ilir>
		+/-2.23 x 10-308 to +/-1.80 x 10 308
		
		Min and max numbers for a double type which Ring uses are
		+/-2.23 x 10-308 to +/-1.80 x 1030.
	
		Maximum of 15 digits are allowed.
		
		Of course, if you use a bignumber library, you are not
		limited, except numbers are only integers.
		
		Otherwise, max numbers without loosing precision are between
		2^53-1 = -4.503.599.627.370.496 to 4.503.599.627.370.495,
		numbers are exactly the integers , e.g. 2^52 (plus sign bit).
		
		From 2^53 to 2^54, everything is multiplied by 2, so numbers becomes even.
	</Ilir>

	GET INSPIRED:
	-------------
		- By Frink language (specialized in real world calculations):
		  --> https://frinklang.org/

*/

  ///////////////////
 ///   GLOBALS   ///
///////////////////
	
	_nDefaultRound = 2
	_nActiveRound = 2

	_nMaxRound = 14		# Ring says that the max round is 90. But actually
				# the most calculable number can't exceed 15 digits.
				# That's why, I will take 14 as a realistic maximum
				# round in Softanza.

				#TODO // Check this with Mahmoud and Ilir.

	StzDecimals(2)		# Softanza sets the number of round to 2 by default,
				# in confrmity with Ring defaults.

	_cMaxCalculableInteger = "999_999_999_999_999"
	_nMaxNumberOfDigitsInUnsignedInteger = 15
	
	_cMaxCalculableRealNumber = "9_999_999_999_999.9"
	_nMaxNumberOfDigitsInUnsignedRealNumber = 14
	
	_cMoneyNumberPrefix = "0m"

	_cNumberFractionalSeparator = "."

	_anDecimalDigits = 0:9

	_anOctalDigits = 0:7

	_anBinaryDigits = [0,1]


  //////////////////////
 ///    FUNCTIONS   ///
//////////////////////

func StzNumberQ(_cNumber_)
	return new stzNumber(_cNumber_)

func StzNamedNumber(paNamed)
	if CheckingParams()

	ok

	_oNumber_ = new stzNumber(paNamed[2])
	_oNumber_.SetName(paNamed[1])
	return _oNumber_

	func StzNamedNumberQ(paNamed)
		return StzNamedNumber(paNamed)

	func StzNamedNumberXTQ(paNamed)
		return StzNamedNumber(paNamed)

func Numberify(p)
	return Q(p).Numberified()

func StzNumberMethods()
	return Stz(:Number, :Methods)

func stzNumberAttributes()
	return Stz(:Number, :Attributes)

func StzNumberClass()
	return "stznumber"

	func StzNumberClassName()
		return StzNumberClass()

func Digits()
	return 0:9

func IsBoolean(n)
	if isNumber(n) and
	   (n = 0 or n = 1)

		return 1
	else
		return 0
	ok

	#< @FunctionAlternativeForms

	func IsBooleanNumber(n)
		return IsBoolean(n)

	func NumberIsBoolean(n)
		return IsBoolean(n)

	func IsABoolean(n)
		return IsBoolean(n)

	func IsABooleanNumber(n)
		return IsBoolean(n)

	func NumberIsABoolean(n)
		return IsBoolean(n)

	#--

	func @IsBoolean(n)
		return IsBoolean(n)

	func @IsBooleanNumber(n)
		return IsBoolean(n)

	func @NumberIsBoolean(n)
		return IsBoolean(n)

	func @IsABoolean(n)
		return IsBoolean(n)

	func @IsABooleanNumber(n)
		return IsBoolean(n)

	func @NumberIsABoolean(n)
		return IsBoolean(n)

	#--

	def IsLogical(n)
		return IsBoolean(n)
	#>

func MaxNumberOfDigitsInUnsignedInteger()
	return _nMaxNumberOfDigitsInUnsignedInteger
	
func MaxNumberOfDigitsInSignedInteger()
	return MaxNumberOfDigitsInUnsignedInteger() - 1
	
func MaxNumberOfDigitsInUnsignedRealNumber()
	return _nMaxNumberOfDigitsInUnsignedRealNumber
	
func MaxNumberOfDigitsInSignedRealNumber()
	return MaxNumberOfDigitsInUnsignedRealNumber() - 1
	
func MaxCalculableNumber()
	_oStr_ = new stzString(_cMaxCalculableInteger)
	_oStr_.Remove("_")
	_cMax_ = _oStr_.content()

	return 0+ _cMax_
	/*
	Be aware that if you use directly this:
	0+ _cMaxCalculableInteger
	
	then it returns 999, although _cMaxCalculableInteger "999_999_999_999_999"
	Guess why?!
	
	Yes: _cMaxCalculableInteger is a string containg the char "_",
	and the char separator "_" is responsible for that!
	*/
		
	func RingMaxNumber()
		return MaxCalculableNumber()

	func MaxRingNumber()
		return MaxCalculableNumber()

//	func MaxNumber()
//		return MaxCalculableNumber()

	func MaxNumberInRing()
		return MaxCalculableNumber()

	func GreatestNumber()
		return MaxCalculableNumber()

	func GreatestNumberInRing()
		return MaxCalculableNumber()

	func LargestNumber()
		return MaxCalculableNumber()

	func LargestNumberInRing()
		return MaxCalculableNumber()

	#--

	func MaxCalculableNumberXT()
		return _cMaxCalculableInteger

	func RingMaxNumberXT()
		return MaxCalculableNumberXT()

	func MaxRingNumberXT()
		return MaxCalculableNumberXT()

func MinCalculableNumber()
	return -1 * MaxCalculableNumber()
		
	func RingMinNumber()
		return MinCalculableNumber()

	func MinRingNumber()
		return MinCalculableNumber()

	func MinNumberInRing()
		return MinCalculableNumber()

	func SmallestRingNumber()
		return MinCalculableNumber()

	func RingSmallestNumber()
		return MinCalculableNumber()

	func SmallestNumberInRing()
		return MinCalculableNumber()

//	func MinNumber()
//		return MinCalculableNumber()

	func SmallestNumber()
		return MinCalculableNumber()

	#--

	func MinCalculableNumberXT()
		return "-" + _cMaxCalculableInteger

	func SmallestCalculableNumberXT()
		return "-" + _cMaxCalculableInteger

	func CalculableMinNumberXT()
		return "-" + _cMaxCalculableInteger

	func CalculableSmallestNumberXT()
		return "-" + _cMaxCalculableInteger

	func RingMinNumberXT()
		return MinCalculableNumberXT()

	func MinRingNumberXT()
		return MinCalculableNumberXT()

func MaxCalculableInteger()
	return MaxCalculableNumber()
		
	#< @FunctionAlternativeForms
 
	func RingMaxInteger()
		return MaxCalculableInteger()

	func MaxRingInteger()
		return MaxCalculableInteger()

	func RingLargestInteger()
		return MaxCalculableInteger()

	func RingGreatestInteger()
		return MaxCalculableInteger()

	func LargestRingInteger()
		return MaxCalculableInteger()

	func GreatestRingInteger()
		return MaxCalculableInteger()

	#--

	func MaxCalculableIntegerXT()
		return _cMaxCalculableInteger

	func RingMaxIntegerXT()
		return MaxCalculableIntegerXT()

	func MaxRingIntegerXT()
		return MaxCalculableIntegerXT()

	func RingLargestIntegerXT()
		return MaxCalculableIntegerXT()

	func RingGreatestIntegerXT()
		return MaxCalculableIntegerXT()

	func LargestRingIntegerXT()
		return MaxCalculableIntegerXT()

	func GreatestRingIntegerXT()
		return MaxCalculableIntegerXT()
	
	#>

func MinCalculableInteger()
	return MinCalculableNumber()
		
	#< @FunctionAlternativeForms

	func RingMinInteger()
		return MinCalculableInteger()

	func MinRingInteger()
		return MinCalculableInteger()

	func RingSmallestInteger()
		return MinCalculableInteger()

	func SmallestRingInteger()
		return MinCalculableInteger()

	#--

	func MinCalculableIntegerXT()
		return "-" + _cMaxCalculableInteger

	func RingMinIntegerXT()
		return MinCalculableIntegerXT()

	func MinRingIntegerXT()
		return MinCalculableIntegerXT()

	func RingSmallestIntegerXT()
		return MinCalculableIntegerXT()

	func SmallestRingIntegerXT()
		return MinCalculableIntegerXT()

	#>

func MaxCalculableRealNumber()
	_oStr_ = new stzString(_cMaxCalculableRealNumber)
	_cMax_ - "_"
	_cMax_ = _oStr_.Content()

	return 0+ _cMax_

	#< @FunctionAlternativeForms

	func GreatestCalculableRealNumber()
		return MaxCalculableRealNumber()

	func LargestCalculableRealNumber()
		return MaxCalculableRealNumber()

	func RingMaxRealNumber()
		return MaxCalculableRealNumber()

	func RingGreatestRealNumber()
		return MaxCalculableRealNumber()

	func RingLargestRealNumber()
		return MaxCalculableRealNumber()

	#--

	func MaxCalculableRealNumberXT()
		return _cMaxCalculableRealNumber

	func GreatestCalculableRealNumberXT()
		return MaxCalculableRealNumberXT()

	func LargestCalculableRealNumberXT()
		return MaxCalculableRealNumberXT()

	func RingMaxRealNumberXT()
		return MaxCalculableRealNumberXT()

	func RingGreatestRealNumberXT()
		return MaxCalculableRealNumberXT()

	func RingLargestRealNumberXT()
		return MaxCalculableRealNumberXT()

	#>
		
func MinCalculableRealNumber()
	return -1 * MaxCalculableRealNumber()
	
	#< @FunctionAlternativeForms

	func SmallestCalculableRealNumber()
		return MinCalculableRealNumber()

	func RingMinRealNumber()
		return MinCalculableRealNumber()

	#--

	func MinCalculableRealNumberXT()
		return "-" + _cMaxCalculableRealNumber

	func RingMinRealNumberXT()
		return MinCalculableRealNumberXT()

	func RingSmallestRealNumberXT()
		return MinCalculableRealNumberXT()

	#>

func MoneyNumberPrefix()
	return _cMoneyNumberPrefix

	#< @FunctionAlternativeForm

	func MoneyPrefix()
		return MoneyNumberPrefix()

	#>

func DefaultFractionalSeparator()
	return _cNumberFractionalSeparator

	func DefaultDecimalSeparator()
		return This.DefaultFractionalSeparator()
	
	#-- @Misspelled

	func DefaultFractionalSeperator()
		return DefaultFractionalSeparator()

	func DefaultDecimalSeperator()
		return This.DefaultFractionalSeparator()


func StringRepresentsInteger(_cNumber_)
	_oStr_ = new stzString(_cNumber_)
	return _oStr_.RepresentsInteger()

func StringRepresentsCalculableNumber(_cNumber_)
	_oStr_ = new stzString(_cNumber_)
	return _oStr_.RepresentsCalculableNumber()
			
func StringRepresentsRealNumber(_cNumber_)
	_oStr_ = new stzString(_cNumber_)
	return _oStr_.RepresentsRealNumber()

func StringRepresentsSignedNumber(_cNumber_)
	_oStr_ = new stzString(_cNumber_)
	return _oStr_.RepresentsSignedNumber()

/*func IsInteger(n)
	if isNumber(n) and Q(n).IsInteger()
		return 1
	else
		return 0
	ok

	#< @FunctionAlternativeForms

	func @IsInteger(n)
		return IsInteger(n)
*/
	func IsAnInteger(n)
		return IsInteger(n)

	func @IsAnInteger(n)
		return IsInteger(n)

	#>

func IsReal(n)
	if isNumber(n) and Q(n).IsReal()
		return 1
	else
		return 0
	ok

	#< @FunctionAlternativeForms

	func IsRealNumber(n)
		return IsReal(n)

	func @IsReal(n)
		return IsReal(n)

	func @IsRealNumber(n)
		return IsReal(n)

	#--

	func IsAReal(n)
		return IsReal(n)

	func IsARealNumber(n)
		return IsReal(n)

	func @IsAReal(n)
		return IsReal(n)

	func @IsARealNumber(n)
		return IsReal(n)

	#>

func IsBit(n)
	if NOT isNumber(n)
		StzRaise("Incorrect param! n must be a number!")
	ok

	if n = 0 or n = 1
		return 1
	else
		return 0

	ok

	#< @FunctionAlternativeForms

	func IsABit(n)
		return IsBit(n)

	func @IsBit(n)
		return IsBit(n)

	func @IsABit(n)
		return IsBit(n)

	#>

func IsRGBColor(anColor)
	if CheckParams() and NOT IsListOfNumbers(anColor)
		StzRaise("Incorrect param type! anColor must be a list of numbers")

	ok

	if len(anColor) != 3
		StzRaise("Incorrect param value! anColor must contain 3 numbers.")
	ok

	for _i_ = 1 to 3
		n = anColor[_i_]

		if n != floor(n)
			return 0
		ok

		if n < 0 or n > 255
			return false
		ok
	next

	return 1

	func @IsRGBColor(anColor)
		return IsRGBColor(anColor)

	func IsRGB(anColor)
		return IsRGBColor(anColor)

	func @IsRGB(anColor)
		return IsRGBColor(anColor)


func DecimalDigits()
	return _anDecimalDigits

func OctalDigits()
	return _anOctalDigits

func Double(n)
	if isList(n) and IsOfNamedParamList(n)
		n = n[2]
	ok
			
	return n * 2

	func DoubleOf(n)
		if isNumber(n)
			return Double(n)

		else
			StzRaise("Invalid param type! n must be a number.")

		ok

	/* TODO

	Allow providing n in a string to preserver round:

	Double("23.124") --> "46.248"

	*/

func Triple(n)
	if isList(n) and IsOfNamedParamList(n)
		n = n[2]
	ok
			
	return n * 3

	func TripleOf(n)		
		if isNumber(n)
			return Triple(n)

		else
			StzRaise("Invalid param type! n must be a number.")

		ok

func Quadruple(n)
	if isList(n) and IsOfNamedParamList(n)
		n = n[2]
	ok

	return n * 4

	func QuadrupleOf(n)
		if isNumber(n)
			return Quadruple(n)

		else
			StzRaise("Invalid param type! n must be a number.")

		ok

func Quintuple(n)
	if isList(n) and IsOfNamedParamList(n)
		n = n[2]
	ok

	return n * 5

	func QuintupleOf(n)
		if isNumber(n)
			return Quintuple(n)

		else
			StzRaise("Invalid param type! n must be a number.")

		ok

func Sextuple(n)
	if isList(n) and IsOfNamedParamList(n)
		n = n[2]
	ok

	return n * 6

	func SextupleOf(n)
		if isNumber(n)
			return Sextuple(n)

		else
			StzRaise("Invalid param type! n must be a number.")

		ok

func Septuple(n)
	if isList(n) and IsOfNamedParamList(n)
		n = n[2]
	ok

	return n * 7

	func SeptupleOf(n)
		if isNumber(n)
			return Septuple(n)

		else
			StzRaise("Invalid param type! n must be a number.")

		ok

func Octuple(n)
	if isList(n) and IsOfNamedParamList(n)
		n = n[2]
	ok

	return n * 8

	func OctupleOf(n)
		if isNumber(n)
			return Octuple(n)

		else
			StzRaise("Invalid param type! n must be a number.")

		ok

func Nonuple(n)
	if isList(n) and IsOfNamedParamList(n)
		n = n[2]
	ok

	return n * 9

	func NonupleOf(n)
		if isNumber(n)
			return Nonuple(n)

		else
			StzRaise("Invalid param type! n must be a number.")

		ok

func Decuple(n)
	if isList(n) and IsOfNamedParamList(n)
		n = n[2]
	ok

	return n * 10
	
	func DecoupleOf(n)
		if isNumber(n)
			return Decuple(n)

		else
			StzRaise("Invalid param type! n must be a number.")

		ok
	
//func Abs(n)
//	return fabs(n)

func OddOrEven(n)
	if isList(n)
		if ListIsOdd(n)
			return :Odd
		else
			return :Even
		ok
	ok

	if NOT isNumber(n)
		StzRaise("Incorrect param type! n must be a number.")
	ok

	if n % 2 = 0
		return :Even
	else
		return :Odd
	ok

/*func IsEven(n)
	if isList(n)
		return IsEvenList(n)
	ok

	return n % 2 = 0

	func @IsEven(n)
		return IsEven(n)
*/
	func IsZawji(n)
		return IsEven(n)

	func @IsZawji(n)
		return IsEven(n)

/*func IsOdd(n)
	if isList(n)
		return IsOddList(n)
	ok

	return n % 2 != 0

	func @IsOdd(n)
		return IsOdd(n)
*/
	func IsFardi(n)
		return IsOdd(n)

	func @IsFardi(n)
		return IsOdd(n)

#---- ROUNDS

func MaxRingRound()
	return _nMaxRound

	func RingMaxRound()
		 return MaxRingRound()

//	func MaxRound()
//		return MaxRingRound()

	func MaxRoundInRing()
		return MaxRingRound()

func DefaultRound()
	return _nDefaultRound

	func StzDefaultRound()
		return DefaultRound()

	func InitialRound()
		return DefaultRound()

	func StzInitialRound()
		return DefaultRound()

func StzResetRound()
	SetActiveRound(_nDefaultRound)

	func ResetRound()
		StzResetRound()

func SetActiveRound(n)
	if NOT isNumber(n)
			StzRaise("Incorrect param type! n must be a number.")
	ok

	if NOT ( n >= 0 and n <= MaxRoundInRing() )
		StzRaise("Incorrect value! n must be in the range 1 to " + MaxRoundInRing() + ".")
	ok

	_nActiveRound = n
	decimals(n)

	func StzDecimals(n)
		SetActiveRound(n)

	func SetStzRound(n)
		SetActiveRound(n)

	func SetRound(n)
		SetActiveRound(n)
	
func StzRound(p) # TODO use Round() from SoftanzaCore

	if isList(p) and IsPair(p)
		if isList(p[2]) and Q(p[2]).IsToNamedParam()
			p[2] = p[2][2]
		ok

		_nNumber_ = p[1]
		_nRound_ = p[2]
	else
		_nNumber_ = p
		_nRound_ = CurrentRound()
	ok


	return StzNumberQ(_nNumber_).RoundedTo(_nRound_)

func RoundN(_nNumber_, _nRound_)
	return StzNumberQ(_nNumber_).RoundedTo(_nRound_)

func StzRoundXT(p)
	if isList(p) and IsPair(p)
		if isList(p[2]) and Q(p[2]).IsToNamedParam()
			p[2] = p[2][2]
		ok

		_nNumber_ = p[1]
		_nRound_ = p[2]
	else
		_nNumber_ = p
		_nRound_ = CurrentRound()
	ok

	return StzNumberQ(_nNumber_).RoundedToXT(_nRound_)

	func RoundXT(p)
		return StzRoundXT(p)

# Getting the active round inforced by the last use of
# the ring StzDecimals() function in the program

func GetActiveRound()
	return _nActiveRound

	#< @FunctionAlternativeForms

	func ActiveRound()
		return GetActiveRound()

	func StzGetActiveRound()
		return GetActiveRound()

	func StzActiveRound()
		return GetActiveRound()

	#--

	func StzGetCurrentRound()
		return GetActiveRound()

	func StzCurrentRound()
		return GetActiveRound()

	#>
	
func NumberIsCalculable(_nNumber_)
	if CheckingParams()
		if NOT isString(_nNumber_)
			StzRaise("Incorrect param type! nNumber must be a number.")
		ok
	ok

	_oStr_ = new stzString(""+ _nNumber_)
	return _oStr_.RepresentsCalculableNumber()


func StringToNumber(_cNumber_) # TESTING IN PROGESS
	if isNumber(_cNumber_)
		return _cNumber_
	ok

	if NOt isString(_cNumber_)
		StzRaise("Incorrect param type! cNumber must be a string.")
	ok

	# Deletig unnecessary spaces

	_cNumber_ = Q(_cNumber_).Trimmed()
	if _cNumber_ = ""
		_cNumber_ = "0"
	ok

	# Setting the decimal number depending on the form provided

	if StringRepresentsNumberInDecimalForm(_cNumber_)

		_oNumber_ = new stzNumber(_cNumber_)
		return _oNumber_.NumericValue()
			
	but StringRepresentsNumberInBinaryForm(_cNumber_)

		_oBinNumber_ = new stzBinaryNumber(_cNumber_)
		return _oBinNumber_.ToStzNumber().NumericValue()

	but StringRepresentsNumberInHexForm(_cNumber_)
		_oHexNumber_ = new stzHexNumber(_cNumber_)
		return _oHexNumber_.ToStzNumber().NumericValue()

	but StringRepresentsNumberInOctalForm(_cNumber_)
		_oOctNumber_ = new stzOctalNumber(_cNumber_)
		return _oOctNumber_.ToStzNumber().NumericValue()

	but StringRepresentsNumberInScientificNotation(_cNumber_)
		// TODO
		StzRaise("Feature not implemented yet!")
	other
		StzRaise(stzNumberError(:UnsupportedNumberForm))
	ok

	#< @FunctionAlternativeForms

	func ToNumber(_cNumber_)
		return StringToNumber(_cNumber_)

	func @ToNumber(_cNumber_)
		return StringToNumber(_cNumber_)

	func String2Number(_cNumber_)
		return StringToNumber(_cNumber_)

	func StrToNbr(_cNumber_)
		return StringToNumber(_cNumber_)

	func Str2Nbr(_cNumber_)
		return StringToNumber(_cNumber_)

	#>

func NumberToString(n)
	if CheckingParams()
		if NOT isNumber(n)
			StzRaise("Incorrect param type! n must be a number.")
		ok
	ok

	return ""+ n

	#< @FunctionAlternativeForms

	func ToString(n)
		return NumberToString(n)

	func @ToString(n)
		return NumberToString(n)

	func Number2String(n)
		return NumberToString(n)

	func NbrToStr(n)
		return NumberToString(n)

	func Nbr2Str(n)
		return NumberToString(n)

	#>

# Decimal form

func StringRepresentsNumberInDecimalForm(pcNumber)
	if CheckingParams()
		if NOT isString(pcNumber)
			StzRaise("Incorrect param type! pcNumber must be a string.")
		ok
	ok

	_pH_ = StzEngineString(pcNumber)
	_nResult_ = StzEngineStringIsNumericString(_pH_)
	if _nResult_ = 0
		_nResult_ = StzEngineStringIsFloat(_pH_)
	ok
	StzEngineStringFree(_pH_)
	return _nResult_

func CharIsDigit(c)
	return isDigit(c) # It's a native ring function

# Binary form

func StringRepresentsNumberInBinaryform(pcNumber)
	if CheckingParams()
		if NOT isString(pcNumber)
			StzRaise("Incorrect param type! pcNumber must be a string.")
		ok
	ok

	_pH_ = StzEngineString(pcNumber)
	_nResult_ = StzEngineStringIsBinaryString(_pH_)
	StzEngineStringFree(_pH_)
	return _nResult_

# Hex form

func StringRepresentsNumberInHexForm(pcNumber)
	if CheckingParams()
		if NOT isString(pcNumber)
			StzRaise("Incorrect param type! pcNumber must be a string.")
		ok
	ok

	_pH_ = StzEngineString(pcNumber)
	_nResult_ = StzEngineStringIsHexString(_pH_)
	StzEngineStringFree(_pH_)
	return _nResult_

func StringRepresentsNumberInUnicodeHexForm(pcNumber)
	if CheckingParams()
		if NOT isString(pcNumber)
			StzRaise("Incorrect param type! pcNumber must be a string.")
		ok
	ok

	if StzLen(pcNumber) < 3
		return 0
	ok
	_cPrefix_ = StzUpper(StzLeft(pcNumber, 2))
	if _cPrefix_ != "U+"
		return 0
	ok
	_cHexPart_ = StzRight(pcNumber, StzLen(pcNumber) - 2)
	return StringRepresentsNumberInHexForm("0x" + _cHexPart_)

# Octal form

func StringRepresentsNumberInOctalForm(pcNumber)
	if CheckingParams()
		if NOT isString(pcNumber)
			StzRaise("Incorrect param type! pcNumber must be a string.")
		ok
	ok

	_pH_ = StzEngineString(pcNumber)
	_nResult_ = StzEngineStringIsOctalString(_pH_)
	StzEngineStringFree(_pH_)
	return _nResult_

# Scientific notation form

func StringRepresentsNumberInScientificNotation(pNumber)
	// TODO
	StzRaise("Feature not implemented yet!")

# Takes a number of 3 digits and returns the following hashlist:
# [ :Units = ..., :Dozens = ..., :Hundreds = ... ]
func GetUnitsDozensAndHundreds(pNumber)	// Or simplier : GetMicroStructure(pNumber)
	#WARNING: We rely on Ring native functions (len, right, left, substr)
	# In principle this is correct, since the number string contains only digits and some
	# other ascii symbols (like "." and "," separators, and "+" and "-" signs).

	pcNumber = "" + pNumber
		
	// Ensuring the number provided doesn't exceed 3 digits
	if StzLen(pcNumber) > 3
		// Considering the case where the number is preceeded by a + or - sign
		// --> In This case, the sign is simply ignored
		if StzLen(pcNumber)=4 and
		   ( StzLeft(pcNumber,1) = "+" or
		     StzLeft(pcNumber,1) = "-")

			pcNumber = pcNumber[2] + pcNumber[3] + pcNumber[4]
		else
			StzRaise("Can't proceed! The length of the number should not exceed 3.")
		ok
	ok

	// Constructing the microstructure of the number (units, dozens, and hundreds)
	_cUnits_ = "0"
	_cDozens_ = "0"
	_cHundreds_ = "0"
	
	switch StzLen(pcNumber)
	on 1
		_cUnits_ = pcNumber

	on 2
		_cUnits_ = StzRight(pcNumber,1)
		_cDozens_ = StzLeft(pcNumber,1)

	on 3
		_cUnits_ = StzRight(pcNumber,1)
		_cDozens_ = StzStringQ(pcNumber).Section(2, 1)
		_cHundreds_ = StzLeft(pcNumber,1)
	off

	return [ :Units = _cUnits_, :Dozens = _cDozens_, :Hundreds = _cHundreds_ ]

func GetMicroStructure(pNumber)
	return GetUnitsDozensAndHundreds(pNumber)

func ZeroIfEmpty(pcStr)
	if isEmpty(pcStr)
		return ""
	ok

func Derivative(pFunction)
	_nTemp_ = call pFunction(_n1_)
	return _nTemp_ * (1 - _nTemp_)
		
func NumberIsDividorOf(pNumber,pOf)
	_oStzNumber_ = new stzNumber(pNumber)
	return _oStzNumber_.IsDividorOf(pOf)

func NumberIsDividableBy(pNumber, pBy)
	_oStzNumber_ = new stzNumber(pNumber)
	return _oStzNumber_.IsDividableBy(pBy)

func NumberConvert(pNumber, pcFrom, pcTo)
	pcNumber = ""+ pNumber

	switch pcFrom
	on :FromDecimalForm
		if NOT StringRepresentsNumberInDecimalForm(pcNumber)
			StzRaise(stzNumberError(:CanNotConvertNumberFromDecimalInThisForm))
		ok

		_oStzNumber_ = new stzNumber(pcNumber)
		switch pcTo
		on :ToDecimalForm
			return pcNumber
		on :ToBinaryForm
			return _oStzNumber_.ToBinaryForm()
		on :ToHexform
			return _oStzNumber_.ToHexForm()

		on :ToUnicodeHexForm
			return _oStzNumber_.ToUnicodeHexForm()

		on :ToOctalForm
			return _oStzNumber_.ToOctalForm()
		other
			StzRaise(stzNumberError(:UnsupportedNumberConversionTargetForm1))
		off

	on :FromBinaryForm
		if NOT NumberIsInBinaryForm(pcNumber)
			StzRaise(stzNumberError(:CanNotConvertNumberFromBinaryInThisForm))
		ok

		_oBinNumber_ = new stzBinaryNumber(pcNumber)

		switch pcTo
		on :ToDecimalForm
			return _oBinNumber_.ToDecimalForm()
		on :ToBinaryForm
			return pcNumber
		on :ToHexForm
			return _oBinNumber_.ToHexForm()

		on :ToUnicodeHexForm
			return _oBinNumber_.ToUnicodeHexForm()

		on :ToOctalForm
			return _oBinNumber_.ToOctalForm()
		other
			StzRaise(stzNumberError(:UnsupportedNumberConversionTargetForm))
		off

	on :FromHexForm
		if NOT StringContainsNumberInHexForm(pcNumber)
			StzRaise(stzNumberError(:CanNotConvertNumberFromHexInThisForm))
		ok

		_oHexNumber_ = new stzHexNumber(pcNumber)
		switch pcTo
		on :ToDecimalForm
			return _oHexNumber_.ToDecimalForm()
		on :ToBinaryForm
			return _oHexNumber_.ToBinaryForm()
		on :ToHexForm
			return pcNumber

		on :ToUnicodeHexForm
			return _oHexNumber_.ToUnicodeHexNumber()

		on :ToOctalForm
			return _oHexNumber_.ToOctalForm()
		other
			StzRaise(stzNumberError(:UnsupportedNumberConversionTargetForm))
		off

	on :FromOctalForm
		if NOT NumberIsInOctalForm(pcNumber)
			StzRaise(stzNumberError(:CanNotConvertNumberFromOctalInThisForm))
		ok

		_oOctalNumber_ = new stzOctalNumber(pcNumber)

		switch pcTo
		on :ToDecimalForm
			return _oOctalNumber_.ToDecimalForm()

		on :ToBinaryForm
			return _oOctalNumber_.ToBinaryForm()

		on :ToHexForm
			return _oOctalNumber_.ToHexForm()

		on :ToUnicodeHexForm
			return _oOctalNumber_.ToUnicodeHexForm()

		on :ToOctalForm
			return pcNumber

		other
			StzRaise(stzNumberError(:UnsupportedNumberConversionTargetForm))
		off

	other
		StzRaise(stzNumberError(:UnsupportedNumberConversionSourceForm))
	off
		
func NumberIsEven(n)
	return StzNumberQ(n).IsEven()

func NumberIsOdd(n)
	return StzNumberQ(n).IsOdd()

func DecimalToHex(n)
	return NumberConvert(n, :FromDecimalForm, :ToHexForm)

func DecimalToHexUnicode(n)
	return NumberConvert(n, :FromDecimalForm, :ToHexUnicodeForm)

#--

func BothArePositive(_n1_, _n2_)
	if BothAreNumbers(_n1_, _n2_) and _n1_ > 0 and _n2_ > 0
		return 1
	else
		return 0
	ok

func BothAreNegative(_n1_, _n2_)
	if BothAreNumbers(_n1_, _n2_) and _n1_ < 0 and _n2_ < 0
		return 1
	else
		return 0
	ok

func BothAreZeros(_n1_, _n2_)
	if BothAreNumbers(_n1_, _n2_) and _n1_ = 0 and _n2_ = 0
		return 1
	else
		return 0
	ok

func IsDecimalNumber(n)
	return isNumber(n)

	func @IsDecimalNumber(n)
		return IsDecimalNumber(n)

	func IsADecimalNumber(n)
		return IsDecimalNumber(n)

	func @IsADecimalNumber(n)
		return IsDecimalNumber(n)

func IsStzNumber(pObject)
	if isObject(pObject) and classname(pObject) = "stznumber"
		return 1
	else
		return 0
	ok

	#< @FunctionAlternativeForms

	def @IsStzNumber(pObject)
		return IsStzNumber(pObject)

	def IsAStzNumber(pObject)
		return IsStzNumber(pObject)

	def @IsAStzNumber(pObject)
		return IsStzNumber(pObject)

	#--

	def IsStzDecimalNumber(pObject)
		return IsStzNumber(pObject)

	def @IsStzDecimalNumber(pObject)
		return IsStzNumber(pObject)

	def IsAStzDecimalNumber(pObject)
		return IsStzNumber(pObject)

	def @IsAStzDecimalNumber(pObject)
		return IsStzNumber(pObject)

	#>

#---

func Add(p, value)
	if isNumber(p) or isString(p)
		p += value
	but isList(p)
		p + value
	else
		raise("Incorrect param type! p must be a number, string, or list.")
	ok

	return p

	func @Add(p, value)
		return p

#-- Generated by ClaudeAI, used bu stzGrid
func MostSquareLikeFactors(n)
	if n <= 0 return [0, 0] ok

	_bestA_ = 1
	_bestB_ = n
	_bestRatio_ = n

	for a = 1 to floor(sqrt(n))
		_b_ = ceil(n / a)
		_ratio_ = ring_max([ _b_ / a, a / _b_ ])

		if _ratio_ < _bestRatio_
			_bestRatio_ = _ratio_
			_bestA_ = a
			_bestB_ = _b_
		ok
	next

	return [_bestA_, _bestB_]

	#< @FunctionAlternativeForms

	func MSLF(n)
		return MostSquareLikeFactors(n)

	#--

	func @MostSquareLikeFactors(n)
		return MostSquareLikeFactors(n)

	func @MSLF(n)
		return MostSquareLikeFactors(n)

	#>

#NOTE The isWeiferich() function has been contributed
# to Softanza by Gal Calmosoft in his RosettaCode
# solution to tje Weiferich primes case made here:
# https://rosettacode.org/wiki/Wieferich_primes#Ring

func StzIsWeiferich(p)
	if not isPrime(p)
		return 0
	ok

	q = 1
	p2 = pow(p,2)

	while p > 1
		q = (2 * q) % p2
		p -= 1
	end

	if q = 1
		return 1
	else
		return 0
	ok

	func isWeiferich(p)
		return StzIsWeiferich(p)

	func @isWeiferich(p)
		return StzIsWeiferich(p)

#-- Percent functions

func NPercentOf(n, p)
	if NOT IsNumberOrStringOrList(p)
		StzRaise("Incorrect param type! p must be number or string or list.")
	ok

	if isNumber(p)
		return p * n / 100

	but isList(p)
		_nItems_ = ceil( len(p) * n / 100 )
		return NRandomItemsIn(_nItems_, p)

	but isString(p)
		_oStr_ = new stzString(p)
		_nLen_ = ceil( _oStr_.Size() * n / 100 )
		return _oStr_.FirstNChars(_nLen_)

	ok

	func NPercent(n, p)
		return NPercentOf(n, p)

func 1PercentOf(p)
	return NPercentOf(1, p)

	def OnePercentOf(p)
		return 1PercentOf(p)

	func 1Percent(p)
		if isList(p) and Q(p).IsOfNamedParam()
			p = p[2]
		ok
		return 1PercentOf(p)

	def OnePercent(p)
		return 1Percent(p)

func 10PercentOf(p)
	return NPercentOf(10, p)

	func 10Percent(p)
		if isList(p) and Q(p).IsOfNamedParam()
			p = p[2]
		ok
		return 10PercentOf(p)

func 20PercentOf(p)
	return NPercentOf(20, p)

	func 20Percent(p)
		if isList(p) and Q(p).IsOfNamedParam()
			p = p[2]
		ok
		return 20PercentOf(p)

func 30PercentOf(p)
	return NPercentOf(30, p)

	func 30Percent(p)
		if isList(p) and Q(p).IsOfNamedParam()
			p = p[2]
		ok
		return 30PercentOf(p)

func 40PercentOf(p)
	return NPercentOf(40, p)

	func 40Percent(p)
		if isList(p) and Q(p).IsOfNamedParam()
			p = p[2]
		ok
		return 40PercentOf(p)

func 50PercentOf(p)
	return NPercentOf(50, p)

	func 50Percent(p)
		if isList(p) and Q(p).IsOfNamedParam()
			p = p[2]
		ok
		return 50PercentOf(p)

func 60PercentOf(p)
	return NPercentOf(60, p)

	func 60Percent(p)
		if isList(p) and Q(p).IsOfNamedParam()
			p = p[2]
		ok
		return 60PercentOf(p)

func 70PercentOf(p)
	return NPercentOf(70, p)

	func 70Percent(p)
		if isList(p) and Q(p).IsOfNamedParam()
			p = p[2]
		ok
		return 70PercentOf(p)

func 80PercentOf(p)
	return NPercentOf(80, p)

	func 80Percent(p)
		if isList(p) and Q(p).IsOfNamedParam()
			p = p[2]
		ok
		return 80PercentOf(p)

func 90PercentOf(p)
	return NPercentOf(90, p)

	func 90Percent(p)
		if isList(p) and Q(p).IsOfNamedParam()
			p = p[2]
		ok
		return 90PercentOf(p)

func 100PercentOf(p)
	return p

	func 100Percent(p)
		if isList(p) and Q(p).IsOfNamedParam()
			p = p[2]
		ok
		return 100PercentOf(p)


  #=============================================#
 #  ENGINE-BACKED GLOBAL NUMBER FUNCTIONS      #
#=============================================#

func StzIsPrime(n)
	return StzEngineNumberIsPrime(n)

func StzGCD(_n1_, _n2_)
	return StzEngineNumberGcd(_n1_, _n2_)

func StzLCM(_n1_, _n2_)
	return StzEngineNumberLcm(_n1_, _n2_)

func StzFactorial(n)
	pBigInt = StzEngineNumberFactorial(n)
	_cResult_ = StzEngineBigIntToString(pBigInt)
	StzEngineBigIntFree(pBigInt)
	return _cResult_

func StzFibonacci(n)
	pBigInt = StzEngineNumberFibonacci(n)
	_cResult_ = StzEngineBigIntToString(pBigInt)
	StzEngineBigIntFree(pBigInt)
	return _cResult_

func StzIsPerfectNumber(n)
	return StzEngineNumberIsPerfect(n)

func StzDigitCount(n)
	return StzEngineNumberDigitCount(n)

func StzDigitSum(n)
	return StzEngineNumberDigitSum(n)

func StzReverseDigits(n)
	return StzEngineNumberReverseDigits(n)

func StzIsDigitPalindrome(n)
	return StzEngineNumberIsPalindrome(n)

  ///////////////////////////
 ///   STZNUMBER CLASS   ///
///////////////////////////
	
class stzDecimalNumber from stzNumber

class stzNumber from stzObject

	@cContent = ""
	#--> Holds the number WITHOUT eventual
	# underscores introduced by the user!

	@nRound = DefaultRound()

	@cReturnType = :Number # Or :String depending on the type of the input

	_These_
	_Those_

	  #------------#
	 #    INIT    #
	#------------#

	# Build the number from a number, a number-in-string, or another
	# stzNumber.
	def init(pNumber)

		# A stzNumber object can be initiated in 3 ways:

		# 1- By providing a number, in this case the current round is taken.
		#    ~> Example : new stzNumber(12)

		# 2- By provising a number in string. In this case, if the number
		#   contains decimals, then the round is the number of decimals.
		#   Otherwise, the current round is taken.
		#   ~> Example : new stzNumber("12.375")

		# 3- By providing a pair containing the number itself (as a number
		#    or as a number in string), and the round to be taken.
		#    ~> Example : new stzNumber([ 12.275865, :Round = 3 ])

		if CheckingParams()
			if NOT (isNumber(pNumber) or isString(pNumber) or @IsPair(pNumber))
				StzRaise(stzNumberError(:CanNotCreateStzNumberObject))
			ok
		ok

		# CASE 1
		if isNumber(pNumber)

			@cContent = "" + pNumber 
			@nRound = StzCurrentRound()
			@cReturnType = :Number

		# CASE 2
		but isString(pNumber)

			@cReturnType = :String

			# Case where a char is provided in the form
			# of Unicode circled numbers
			# ~> Example : new stzNumber(char(226) + char(145) + char(166))
			if StzStringQ(pNumber).IsAChar() and
			   StzCharQ(pNumber).IsCircledNumber()

				@cContent = ""+ StzCharQ(pNumber).NumericValue()
				@nRound = StzCurrentRound()

				return
			ok

			# Case where the string provided is empty
			if pNumber = ""
				@cContent = "0"
				@nRound = StzCurrentRound()

			# Case where the user provides a number in string
			# with a dot "." at the end (a "0" is then added)
			but StzRight(pNumber, 1) = "." and
			   StringRepresentsNumberInDecimalForm(StzMid(pNumber, 1, StzLen(pNumber) - 1))

				pNumber += "0"
	
			# Case where pNumber is a non null string
			else
				if StringRepresentsNumberInDecimalForm(pNumber)
		
					if StringRepresentsCalculableNumber(pNumber)
						_oString_ = new stzString(pNumber)
						if _oString_.Contains("_")
							@cContent = _oString_.RemoveQ("_").Content()
						else
							@cContent = pNumber
						ok

						if _oString_.Contains(".")
							@nRound = _oString_.Size() - _oString_.FindFirst(".")
						else
							@nRound = StzCurrentRound()
						ok
					else
						StzRaise(stzNumberError(:CanNotCreateDecimalNumber2))
					ok
		
				else
					StzRaise(stzNumberError(:CanNotCreateDecimalNumber1))
				ok
			ok

		# Case 3 where a pair is provided
		but isPair(pNumber)

			if NOT @IsNumberOrString(pNumber[1])
				StzRaise("Incorrect param type! The first item in the pair must be a number or string.")
			ok

			# Reading the round (from the second item in the pair)

			if isNumber(pNumber[2])
				@nRound = pNumber[2]
				@cReturnType = :Number

			but @IsPair(pNumber[2]) and isString(pNumber[2][1]) and
			   ( pNumber[2][1] = :Round or pNumber[2][1] = :RoundedTo ) and
			   isNumber(pNumber[2][2])

				@nRound = pNumber[2][2]	
				@cReturnType = :Number

			else
				StzRaise("Incorrect param type! The second item of the pair must be a number or" + 
					 " a named param of the form :Round = n.")
			ok

			# Reading the number (from the first item in the pair)

			if isNumber(pNumber[1])

				@cReturnType = :Number

				_nCurrentRound_ = StzCurrentRound()
				StzDecimals(@nRound)
				@cContent = "" + pNumber[1]
				StzDecimals(_nCurrentRound_)

			but isString(pNumber[1])
				@cContent = pNumber[1]
				@cReturnType = :String

			ok

		ok

		_These_ = This
		_Those_ = This

	  #-------------------------#
	 #    CONTENT AND VALUE    #
	#-------------------------#

	# The number as it is held: a STRING (use NumericValue for the number).
	def Content()
		return @cContent

		def ContentQ()
			return new stzNumber(This.Content())

	# Same as NumericValue: the number as a Ring number.
	def Number()
		return This.NumericValue()

		def NumberQ() # Same as Copy()
			return new stzNumber( This.Content() )

	# The value the number was created with.
	def InitialContent()
		return pNumber		 

	# A new stzNumber with the same content.
	def Copy()
		_oCopy_ = new stzNumber( This.Content() )
		return _oCopy_

	# Whether values are returned as :Number or :String.
	def ReturnType()
		return @cReturnType

	# Choose whether values are returned as :Number or :String.
	def SetReturnType(_cType_)
		if CheckingParams()
			if isList(_cType_) and Q(_cType_).IsToOrAsNamedParams()
				_cType_ = _cType_[2]
			ok

			if NOT isString(_cType_)
				StzRaise("Incorrect param type! cType must be a string.")
			ok
		ok

		if NOT ( _cType_ = :Number or _cType_ = :String )
			StzRaise("Incorrect value! cType must be equal to :Number or :String.")
		ok

		@cReturnType = _cType_

		#< @FunctionAlternativeForms

		# Choose whether values come back as :Number or :String.
		def SetReturnTypeTo(_cType_)
			if CheckingParams()
				if NOT isString(_cType_)
					StzRaise("Incorrect param type! cType must be a string.")
				ok
			ok

			This.SetReturnType(_cType_)

		# Choose whether values come back as :Number or :String.
		def SetReturnTypeAs(_cType_)
			SetReturnTypeTo(_cType_)

		#>

	# Make values come back as :Number (the return-type dial).
	def ReturnNumber()
		SetReturnType(:Number)
		
	# The number as a string with its explicit sign (+ or -).
	def NumberWithSign()
		If This.IsPositive()
			return "+" + This.Content()

		else
			return This.Content()
		ok

	# The number as a Ring number.
	def NumericValue()
		# number() not 0+ : Ring's 0+str coercion returns 0 on the first
		# use after ANY caught raise (VM quirk); number() is immune
		return ring_number(@cContent)

		# The numeric value of the number.
		def Value()
			return This.NumericValue()
	

		# Misspelled-but-kept alias of NumericValue.
		def NumbericValue()
			return This.NumericValue()

	# The number as a string (rendered with its round).
	def StringValue()

		# Memorizing the current round (to reset it before leaving)

		_nCurrentRound_ = StzCurrentRound()

		# Activating the round of the number as saved in the object

		StzDecimals(This.Round())

		# Casting the number in a string using the round above

		@cContent = "" + This.NumbericValue()

		# Resetting the round active in the program

		StzDecimals(_nCurrentRound_)

		# Returning the string form of the number

		return @cContent

		def StringValueQ()
			return new stzString( This.StringValue() )

	  #------------------------------------#
	 #  CHECKING IF THE NUMBER IS A CHAR  #
	#------------------------------------#

	def IsChar()

		if This.IsInteger()
			_nTemp_ = This.NumericValue()
			if _nTemp_ >= 0 and _nTemp_ <= 9
				return 1
			ok
		ok

		return 1

		def IsAChar()
			return This.IsChar()

	  #-------------------------#
	 #   UPDATING THE NUMBER   #
	#-------------------------#

	# Replace the content with the given number (mutating; the single
	# update point).
	def Update(pNumber)
		if CheckingParams() = 1

			if isList(pNumber) and Q(pNumber).IsWithOrByOrUsingNamedParam()
				pNumber = pNumber[2]
			ok

			if NOT ( isNumber(pNumber) or ( isString(pNumber) and Q(pNumber).IsNumberInString() ) )
				StzRaise("Incorrect param type! pNumber must be a number or a string containing a number.")
			ok

		ok

		# Enforced per-object constraints guard the single update point
		# (typed: the guard sees the NUMBER, not its string form)
		if isString(pNumber)
			This._NNLGuardUpdate(ring_number(StzReplace(pNumber, "_", "")))
		else
			This._NNLGuardUpdate(pNumber)
		ok

		if isString(pNumber)

			@cReturnType = :String

			_oStr_ = new stzString(pNumber)
			@cContent = _oStr_.RemoveQ("_").Content()

			@nRound = StzCurrentRound()

			if _oStr_.Contains(".")
				@nRound = _oStr_.NumberOfChars() - _oStr_.FindFirst(".") + 1
			ok

		else # isNumber(pNumber)

			@cReturnType = :Number

			@cContent = ""+ pNumber
			@nRound = StzCurrentRound()
		ok

	    # Tracing the history of updates (only if not already in history update)
	    if _bInHistoryUpdate = 0
	        @TraceObjectHistory(This)
	    ok

		# Object constraints: DONE -- the enforcement guard at the top of this method

		#< ... >


		#< @FunctionFluentForm

		def UpdateQ(pNumber)
			This.Update(pNumber)
			return This

		#>

		#< @FunctionAlternativeForms

		# Same as Update: replace the content with the given number
		# (mutating).
		def UpdateWith(pNumber)
			This.Update(pNumber)

			def UpdateWithQ(pNumber)
				return This.UpdateQ(pNumber)
	
		# Same as Update: replace the content with the given number
		# (mutating).
		def UpdateBy(pNumber)
			This.Update(pNumber)

			def UpdateByQ(pNumber)
				return This.UpdateQ(pNumber)

		# Same as Update: replace the content with the given number
		# (mutating).
		def UpdateUsing(pNumber)
			This.Update(pNumber)

			def UpdateUsingQ(pNumber)
				return This.UpdateQ(pNumber)

		#>

	# The value the number would be updated to (passive twin of Update).
	def Updated(pNumber)
		return pNumber

		#< @FunctionAlternativeForms

		def UpdatedWith(pNumber)
			return This.Updated(pNumber)

		def UpdatedBy(pNumber)
			return This.Updated(pNumber)

		def UpdatedUsing(pNumber)
			return This.Updated(pNumber)

		#>

	  #--------------------------------------------------#
	 #  GETTING THE UNICODE (CODE POINT) OF THE NUMBER  #
	#--------------------------------------------------#

	def Unicode()
		n = This.NumericValue()
		if 0 <= n and n <= 9
			return StzCharQ(This.Number()).Unicode()

		else
			return This.Unicodes()

		ok

	def Unicodes()
		_acChars_ = This.StringValueQ().ToChars()
		_anResult_ = StzListOfCharsQ(_acChars_).Unicodes()
		return _anResult_

	  #-----------------------------------#
	 #  CHECKING IF THE NUMBER IS DIGIT  #
	#-----------------------------------#

	def IsADigit()
		n = This.NumericValue()
		if 0 <= n and n <= 9
			return 1
		else
			return 0
		ok

		def IsDigit()
			return This.IsADigit()

	  #---------------------------------------------------------#
	 #   CHECKING IF THE NUMBER IS MULTIPLE OF A GIVEN NUMBER  #
	#---------------------------------------------------------#

	def IsMultipleOf(n)

		if CheckingParams()
			if NOT @IsStringOrNumber(n)
				StzRaise("Incorrect param type! n must be a number or string.")
			ok

			if isString(n) and NOT Q(n).IsDecimalNumberInString()
				StzRaise("Incorrect value! The string n must contain a decimal number.")
			ok

		ok

		if isString(n)
			n = StzNumberQ(n).NumericValue()
		ok

		if This.NumericValue() = 0
			return 0
		ok

		if This.NumericValue() % n = 0
			return 1
		else
			return 0
		ok

		def IsAMultipleOf(n)
			return This.IsMultipleOf(n)

		def IsTheMultipleOf(n)
			return This.IsMultipleOf(n)

	def IsDoubleOf(n)
		if CheckingParams()
			if NOT @IsStringOrNumber(n)
				StzRaise("Incorrect param type! n must be a number or string.")
			ok

			if isString(n) and NOT Q(n).IsDecimalNumberInString()
				StzRaise("Incorrect value! The string n must contain a decimal number.")
			ok

		ok

		if isString(n)
			n = StzNumberQ(n).NumericValue()
		ok

		If This.NumericValue() = DoubleOf(n)
			return 1
		else
			return 0
		ok

		def IsADoubleOf(n)
			return This.IsDoubleOf(n)

		def IsTheDoubleOf(n)
			return This.IsDoubleOf(n)

	def IsTripleOf(n)
		if CheckingParams()
			if NOT @IsStringOrNumber(n)
				StzRaise("Incorrect param type! n must be a number or string.")
			ok

			if isString(n) and NOT Q(n).IsDecimalNumberInString()
				StzRaise("Incorrect value! The string n must contain a decimal number.")
			ok

		ok

		if isString(n)
			n = StzNumberQ(n).NumericValue()
		ok

		If This.NumericValue() = TripleOf(n)
			return 1
		else
			return 0
		ok

		def IsAtripleOf(n)
			return This.IsTripleOf(n)

		def IsTheTripleOf(n)
			return This.IsTripleOf(n)

	def IsQuadrupleOf(n)
		if CheckingParams()
			if NOT @IsStringOrNumber(n)
				StzRaise("Incorrect param type! n must be a number or string.")
			ok

			if isString(n) and NOT Q(n).IsDecimalNumberInString()
				StzRaise("Incorrect value! The string n must contain a decimal number.")
			ok

		ok

		if isString(n)
			n = StzNumberQ(n).NumericValue()
		ok

		If This.NumericValue() = QuadrupleOf(n)
			return 1
		else
			return 0
		ok

		def IsAQuadrupleOf(n)
			return This.IsQuadrupleOf(n)

		def IsTheQuadrupleOf(n)
			return This.IsQuadrupleOf(n)

	def IsQuintupleOf(n)
		if CheckingParams()
			if NOT @IsStringOrNumber(n)
				StzRaise("Incorrect param type! n must be a number or string.")
			ok

			if isString(n) and NOT Q(n).IsDecimalNumberInString()
				StzRaise("Incorrect value! The string n must contain a decimal number.")
			ok

		ok

		if isString(n)
			n = StzNumberQ(n).NumericValue()
		ok

		If This.NumericValue() = QuintupleOf(n)
			return 1
		else
			return 0
		ok

		def IsAQuintupleOf(n)
			return This.IsQuintupleOf(n)

		def IsTheQuintupleOf(n)
			return This.IsQuintupleOf(n)

	def IsSextupleOf(n)
		if CheckingParams()
			if NOT @IsStringOrNumber(n)
				StzRaise("Incorrect param type! n must be a number or string.")
			ok

			if isString(n) and NOT Q(n).IsDecimalNumberInString()
				StzRaise("Incorrect value! The string n must contain a decimal number.")
			ok

		ok

		if isString(n)
			n = StzNumberQ(n).NumericValue()
		ok

		If This.NumericValue() = SextupleOf(n)
			return 1
		else
			return 0
		ok

		def IsASextupleOf(n)
			return This.IsSextupleOf(n)

		def IsTheSextupleOf(n)
			return This.IsSextupleOf(n)


	def IsOctupleOf(n)
		if CheckingParams()
			if NOT @IsStringOrNumber(n)
				StzRaise("Incorrect param type! n must be a number or string.")
			ok

			if isString(n) and NOT Q(n).IsDecimalNumberInString()
				StzRaise("Incorrect value! The string n must contain a decimal number.")
			ok

		ok

		if isString(n)
			n = StzNumberQ(n).NumericValue()
		ok

		If This.NumericValue() = OctupleOf(n)
			return 1
		else
			return 0
		ok

		def IsAnOctupleOf(n)
			return This.IsOctupleOf(n)

		def IsTheOctupleOf(n)
			return This.IsOctupleOf(n)

	def IsNonupleOf(n)
		if CheckingParams()
			if NOT @IsStringOrNumber(n)
				StzRaise("Incorrect param type! n must be a number or string.")
			ok

			if isString(n) and NOT Q(n).IsDecimalNumberInString()
				StzRaise("Incorrect value! The string n must contain a decimal number.")
			ok

		ok

		if isString(n)
			n = StzNumberQ(n).NumericValue()
		ok

		If This.NumericValue() = Nonuple(n)
			return 1
		else
			return 0
		ok

		def IsANonupleOf(n)
			return This.IsNonupleOf(n)

		def IsTheNonupleOf(n)
			return This.IsNonupleOf(n)

	def IsDecupleOf(n)
		if CheckingParams()
			if NOT @IsStringOrNumber(n)
				StzRaise("Incorrect param type! n must be a number or string.")
			ok

			if isString(n) and NOT Q(n).IsDecimalNumberInString()
				StzRaise("Incorrect value! The string n must contain a decimal number.")
			ok

		ok

		if isString(n)
			n = StzNumberQ(n).NumericValue()
		ok

		If This.NumericValue() = Decuple(n)
			return 1
		else
			return 0
		ok

		def IsADecupleOf(n)
			return This.IsDecupleOf(n)

		def IsTheDecupleOf(n)
			return This.IsDecupleOf(n)

	  #-----------------#
	 #    BOUNDNESS    #
	#-----------------#

	# TRUE if the number lies between n1 and n2.
	def IsBoundedBy(_n1_, _n2_)
		if CheckingParams()
			if NOT ( @IsStringOrNumber(_n1_) and @IsStringOrNumber(_n2_) )
				StzRaise("Incorrect param type! n1 and n2 must be numbers or strings.")
			ok

			if isString(_n1_) and NOT Q(_n1_).IsDecimalNumberInString()
				StzRaise("Incorrect value! The string n1 must contain a decimal number.")
			ok

			if isString(_n2_) and NOT Q(_n2_).IsDecimalNumberInString()
				StzRaise("Incorrect value! The string n2 must contain a decimal number.")
			ok

		ok

		if isString(_n1_)
			_n1_ = StzNumberQ(_n1_).NumericValue()
		ok

		if isString(_n2_)
			_n2_ = StzNumberQ(_n2_).NumericValue()
		ok

		if _n1_ > _n2_
			_nTemp_ = _n1_
			_n1_ = _n2_
			_n2_ = _nTemp_
		ok
 
		if This.NumericValue() >= _n1_ and This.NumericValue() <= _n2_
			return 1
		else
			return 0
		ok

	  #------------#
	 #    TYPE    #
        #------------#

	# TRUE if the number has no fractional part.
	def IsInteger()
		if NOT This.HasFractionalPart()
			return 1
		else
			return 0
		ok

	# TRUE if the number is an integer greater than zero.
	def IsPositiveInteger()
		if This.IsInteger() and This.IsPositive()
			return 1
		else
			return 0
		ok

	# TRUE if the number is an integer less than zero.
	def IsNegativeInteger()
		if This.IsInteger() and This.IsNegative()
			return 1
		else
			return 0
		ok

	# TRUE if the number has a fractional part.
	def IsReal()
		if This.HasFractionalPart()
			return 1
		else
			return 0
		ok

		def IsRealNumber()
			return This.IsReal()

	# TRUE if the number has more digits than the configured maximum.
	def IsBigNumber()
		if This.NumberOfDigits() > This.MaxNumberOfDigits()
			return 1
		else
			return 0
		ok

	# TRUE if the number is a single-digit integer.
	def IsOneDigit()
		if This.IsInteger() and len(This.Content()) = 1
			return 1
		else
			return 0
		ok

	# TRUE if the number is odd.
	#@ aka  not divisible by two, odd number
	def IsOdd()
		return StzEngineNumberIsOdd(This.NumericValue())

		#< @FunctionAlternativeForm

		def IsFardi() # Added because I have a confusion between odd() and even()
			return This.IsOdd()

		ded IsNotMultipleOf2()
			return This.IsOdd()

		#>

		#< @FunctionNegativeForm

		# TRUE if the number is even.
		def IsNotOdd()
			return NOT This.IsOdd()

		#>

	# TRUE if the number is even.
	#@ aka  divisible by two, even number
	def IsEven()
		return StzEngineNumberIsEven(This.NumericValue())

		#< @FunctionAlternativeForm

		def IsZawji() # Added because I have a confusion between odd() and even()
			return This.IsEven()

		ded IsMultipleOf2()
			return This.IsEven()

		#>

		#< @FunctionNegativeForm

		# TRUE if the number is odd.
		def IsNotEven()
			return NOT This.IsEven()

		#>

	# :Odd or :Even, whichever the number is.
	def IsOddOrEven()
		If This.IsOdd()
			return :Odd
		else
			return :Even
		ok

		def IsEvenOrOdd()
			return This.IsOddOrEven()

		# Two alternatives (in arabic) made
		# because I always get confused in
		# distniguishing Odd fro Even!
		#--> PX, or Programmer Experience

		def IsZawjiOrFardi()
			If This.IsZawji()
				return :Zawji
			else
				return :Fardi
			ok

		def IsFardiOrZawji()
			return This.IsZawjiOrFardi()

	# TRUE if the number is prime.
	#@ aka  prime number, only divisible by one and itself
	def IsPrime()
		if This.IsInteger() and This.IsGreaterThan(1)
			return StzEngineNumberIsPrime( This.NumericValue() )
		else
			return 0
		ok

		def IsAPrimeNumber()
			return This.IsPrime()

		def IsAPrime()
			return This.IsPrime()

		def IsPrimeNumber()
			return This.IsPrime()

	# TRUE if the number is a Wieferich prime.
	def isWeiferich(s)
		_bResult_ = @isWeiferich(This.NumericValue())

	# TRUE if the number is 0 or 1.
	def IsBoolean()
		if This.Number() = 1 or This.Number() = 0
			return 1
		else
			return 0
		ok

	# TRUE if the number is 1.
	def IsTrue()
		if This.Number() = 1
			return 1
		else
			return 0
		ok

	# TRUE if the number is 0.
	def IsFalse()
		if This.Number() = 0
			return 1
		else
			return 0
		ok
		
	  #----------------------------------#
	 #    NULL, POSITIVE OR NEGATIVE    #
	#----------------------------------#

	def IsZero()
		if This.Content() = "0"
			return 1
		else
			return 0
		ok

	#@ aka  below zero, less than zero, minus, negative sign
	def IsNegative()
		if This.Sign() = "-"
			return 1
		else
			return 0
		ok	
		 
	def IsStrictlyNegative()
		if This.IsNegative() or This.IsZero()
			return 1

		else
			return 0
		ok

	#@ aka  above zero, greater than zero, plus, positive sign
	def IsPositive()
		if This.IsNotSigned() or This.Sign() = "+"
			return 1
		else
			return 0
		ok

	def IsStrictlyPositive()
		if This.IsPositive() or This.IsZero()
			return 1

		else
			return 0
		ok

	  #------------#
	 #    SIGN    #
	#------------#
	
	# The sign of the number: "+", "-" or "" for zero.
	def Sign()

		_oStr_ = new stzString(This.Content())
		_cLeft_ = _oStr_.LeftChar()

		if _cLeft_ = "+"
			return "+"

		but _cLeft_ = "-"
			return "-"

		ok

	# Drop the sign from the number (mutating).
	def RemoveSign()
		_cNumber_ = This.Content()
		_nLenNumber_ = len(_cNumber_)

		_cSign_ = This.Sign()

		if _cSign_ = "+" or _cSign_ = "-"

			This.Update( StzReplace(_cNumber_, 2, _nLenNumber_ -2 ) )
		ok

		def RemoveSignQ()
				This.RemoveSign()
				return This

	# A copy without the sign; the original is unchanged.
	def SignRemoved()
		_cResult_ = This.Copy().RemoveSignQ().Content()
		return _cResult_

	# TRUE if the number carries an explicit sign.
	def IsSigned()
		if This.Sign() != ""
			return 1
		else
			return 0
		ok

		# TRUE if the number carries no explicit sign.
		def IsNotSigned()
			return NOT IsSigned()

	# TRUE if the number carries no explicit sign.
	def IsUnsigned()
		if This.IsSigned() = 1
			return 0
		else
			return 1
		ok

	# Same as IsSigned.
	def HasSign()
		return This.IsSigned()

		def HasASign()
			return This.HasSign()

		def ContainsSign()
			return This.HasSign()

		def ContainsASign()
			return This.HasSign()

	  #-------------------#
	 #    COMPARAISON    #
        #-------------------#
	
	def IsEqualTo(pOtherNumber)

		if NOT @IsNumberOrNumberInString(pOtherNumber)
			return FALSE
		ok

		_nCurrentRound_ = StzCurrentRound()

		StzDecimals(This.Round())

		_bResult_ = (This.NumericValue() = 0+ pOtherNumber)
		StzDecimals(_nCurrentRound_)

		return _bResult_

		#< @FunctionAlternativeForms

		def IsEqual(pOtherNumber)
			if isList(pOtherNumber) and Q(pOtherNumber).IsToNamedParam()
				pOtherNumber = pOtherNumber[2]
			ok

			return This.IsEqualTo(pOtherNumber)

		# TRUE if the number equals the given one.
		def EqualTo(pOtherNumber)
			return This.IsEqual(pOtherNumber)

		def Equals(pOtherNumber)
			return This.IsEqual(pOtherNumber)


		# TRUE if the number equals the given one (case dial for string
		# forms).
		def IsEqualToCS(pOtherNumber, pCaseSensitive)
			return This.IsEqualTo(pOtherNumber)

		def IsEqualCS(pOtherNumber, pCaseSensitive)
			return This.IsEqualTo(pOtherNumber)

		def EqualsCS(pOtherNumber, pCaseSensitive)
			return This.IsEqualTo(pOtherNumber)

		#>

		#< @FunctionNegativeForm

		# TRUE if the number differs from the given one.
		def IsNotEqualTo(pOtherNumber)
			return NOT This.IsEqualTo(pOtherNumber)
	
			#< @FunctionAlternativeForm

			# TRUE if the number differs from the given one.
			def IsDifferentFrom(pOtherNumber)
				return This.IsNotEqualTo(pOtherNumber)

			# TRUE if the number differs from the given one.
			def IsDifferentTo(pOtherNumber)
				return This.IsNotEqualTo(pOtherNumber)

			# TRUE if the number differs from the given one.
			def IsDifferentOf(pOtherNumber)
				return This.IsNotEqualTo(pOtherNumber)

			#>

		#--

		def IsNotEqualToCS(pOtherNumber, pCaseSensitive)
			return This.IsNotEqualTo(pOtherNumber)
	
			#< @FunctionAlternativeForm

			def IsDifferentFromCS(pOtherNumber, pCaseSensitive)
				return This.IsNotEqualTo(pOtherNumber)

			def IsDifferentToCS(pOtherNumber, pCaseSensitive)
				return This.IsNotEqualTo(pOtherNumber)

			def IsDifferentOfCS(pOtherNumber, pCaseSensitive)
				return This.IsNotEqualTo(pOtherNumber)

			#>

		#>

		#< @FunctionMisspelledForm

		def IsEqualtTo(pcOtherNumber)
			return This.IsEqualTo(pcOtherNumber)

			def IsEqualtToCS(pcOtherNumber, pCaseSensitive)
				return This.IsEqualTo(pcOtherNumber)

		#>

	#=====

	# TRUE if the number equals NEITHER of the two given numbers.
	def IsNeither(_n1_, _n2_)
		if CheckingParams()
			if isList(_n1_) and Q(_n1_).IsEqualToNamedParam()
				_n1_ = _n1_[2]
			ok

			if isList(_n2_) and Q(_n2_).IsNorNamedParam()
				_n2_ = _n2_[2]
			ok

			if @BothAreStrings(_n1_, _n2_) and
			   NOT @BothAreNumbersInStrings(_n1_, _n2_)

				return This.@IsNeither(_n1_, _n2_)
			ok

			if NOT ( @BothAreNumbers(_n1_, _n2_) or @BothAreNumbersInStrings(_n1_, _n2_) )
				StzRaise("Incorrect param type! n1 and n2 must both be numbers or numbers in strings.")
			ok
		ok

		_bEqualToN1_ = This.IsEqualTo(_n1_)
		_bEqualToN2_ = This.IsEqualTo(_n2_)

		if NOT _bEqualToN1_ and NOT _bEqualToN2_
			return 1
		else
			return 0
		ok

		def IsNeitherEqualTo(_n1_, _n2_)
			return This.IsNeither(_n1_, _n2_)

	# TRUE if the number is less than or equal to the given one.
	def IsLess(pOtherNumber)
		if CheckingParams()
			if NOT Q(pOtherNumber).IsNumberOrString()
				StzRaise("Incorrect param types! pNumber1 and pNumber2 must be numbers or strings.")
			ok
		ok

		_nCurrentRound_ = StzCurrentRound()

		StzDecimals(This.Round())
		_bResult_ = (This.NumericValue() <= 0+ pOtherNumber)
		StzDecimals(_nCurrentRound_)

		return _bResult_

		#< @FunctionAlternativeForms

		def IsLessThan(pOtherNumber)
			return This.IsLess(pOtherNumber)

		def IsLessOrEqualTo(pOtherNumber)
			return This.IsLess(pOtherNumber)

		def IsSmallerOrEqualTo(pOtherNumber)
			return This.IsLess(pOtherNumber)

		def IsEqualOrLessThan(pOtherNumber)
			return This.IsLess(pOtherNumber)

		def IsEqualOrSmallerThan(pOtherNumber)
			return This.IsLess(pOtherNumber)

		def IsSmallerThqn(pOtherNumber)
			return This.IsLess(pOtherNumber)

		#>
	
	# TRUE if the number is strictly less than the given one.
	def IsStriclyLess(pOtherNumber)
		if CheckingParams()
			if NOT Q(pOtherNumber).IsNumberOrString()
				StzRaise("Incorrect param types! pNumber1 and pNumber2 must be numbers or strings.")
			ok
		ok

		_nCurrentRound_ = StzCurrentRound()

		StzDecimals(This.Round())
		_bResult_ = (This.NumericValue() < 0+ pOtherNumber)
		StzDecimals(_nCurrentRound_)

		return _bResult_

		#< @FunctionAlternativeForms

		# TRUE if the number is strictly less than the given one.
		def IsStrictlyLessThan(pOtherNumber)
			return This.IsStrictlyLess(pOtherNumber)

		# TRUE if the number is less than or equal to the given one.
		def IsStrictlyLessOrEqualTo(pOtherNumber)
			return This.IsStrictlyLess(pOtherNumber)

		# TRUE if the number is less than or equal to the given one.
		def IsStrictlySmallerOrEqualTo(pOtherNumber)
			return This.IsStrictlyLess(pOtherNumber)

		# TRUE if the number is less than or equal to the given one.
		def IsStrictlyEqualOrLessThan(pOtherNumber)
			return This.IsStrictlyLess(pOtherNumber)

		# TRUE if the number is less than or equal to the given one.
		def IsStrictlyEqualOrSmallerThan(pOtherNumber)
			return This.IsStrictlyLess(pOtherNumber)

		# Misspelled-but-kept alias of IsStrictlyLessThan.
		def IsStrictlySmallerThqn(pOtherNumber)
			return This.IsStrictlyLess(pOtherNumber)

		#>

	# TRUE if the number is greater than or equal to the given one.
	def IsGreater(pOtherNumber)
		if CheckingParams()
			if NOT Q(pOtherNumber).IsNumberOrString()
				StzRaise("Incorrect param types! pNumber1 and pNumber2 must be numbers or strings.")
			ok
		ok

		_nCurrentRound_ = StzCurrentRound()

		StzDecimals(This.Round())
		_bResult_ = (This.NumericValue() >= 0+ pOtherNumber)
		StzDecimals(_nCurrentRound_)

		return _bResult_

		#< @FunctionAlternativeForms

		def IsGreaterThan(pOtherNumber)
			return This.IsGreater(pOtherNumber)

		def IsEqualOrGreater(pOtherNumber)
			return This.IsGreater(pOtherNumber)

		def IsEqualOrGreaterThan(pOtherNumber)
			return This.IsGreater(pOtherNumber)

		def IsBigger(pOtherNumber)
			return This.IsGreater(pOtherNumber)

		def IsBiggerThan(pOtherNumber)
			return This.IsGreater(pOtherNumber)

		def IsEqualOrBigger(pOtherNumber)
			return This.IsGreater(pOtherNumber)

		def IsEqualOrBiggerThan(pOtherNumber)
			return This.IsGreater(pOtherNumber)

		#>

	# TRUE if the number is strictly greater than the given one.
	def IsStrictlyGreater(pOtherNumber)
		if CheckingParams()
			if NOT Q(pOtherNumber).IsNumberOrString()
				StzRaise("Incorrect param types! pNumber1 and pNumber2 must be numbers or strings.")
			ok
		ok

		_nCurrentRound_ = StzCurrentRound()

		StzDecimals(This.Round())
		_bResult_ = (This.NumericValue() > 0+ pOtherNumber)
		StzDecimals(_nCurrentRound_)

		return _bResult_

		#< @FunctionAlternativeForms

		def IsStrictlyGreaterThan(pOtherNumber)
			return This.IsStrictlyGreater(pOtherNumber)

		def IsStrictlyEqualOrGreater(pOtherNumber)
			return This.IsStrictlyGreater(pOtherNumber)

		def IsStrictlyEqualOrGreaterThan(pOtherNumber)
			return This.IsGreater(pOtherNumber)

		def IsStrictlyBigger(pOtherNumber)
			return This.IsStrictlyGreater(pOtherNumber)

		def IsStrictlyBiggerThan(pOtherNumber)
			return This.IsStrictlyGreater(pOtherNumber)

		def IsStrictlyEqualOrBigger(pOtherNumber)
			return This.IsStrictlyGreater(pOtherNumber)

		def IsStrictlyEqualOrBiggerThan(pOtherNumber)
			return This.IsStrictlyGreater(pOtherNumber)

		#>

	# TRUE if the number lies between the two given numbers (bounds
	# included).
	def IsBetween(pNumber1, pNumber2)

		if CheckingParams()
			if isList(pNumber2) and Q(pNumber2).IsAndNamedParam()
				pNumber2 = pNumber2[2]
			ok
	
			if NOT ( Q(pNumber1).IsNumberOrString() and Q(pNumber2).IsNumberOrString() )
				StzRaise("Incorrect param types! pNumber1 and pNumber2 must be numbers or strings.")
			ok
		ok

		_n1_ = 0+ pNumber1
		_n2_ = 0+ pNumber2

		n = This.NumericValue()

		_bResult_ = 1

		if NOT ( _n1_ < n and n < _n2_ )
			_bResult_  = 0
		ok

		return _bResult_

	# TRUE if the number lies between the two given numbers, bounds
	# INCLUDED (IB).
	def IsBetweenIB(pNumber1, pNumber2)

		if CheckingParams()
			if isList(pNumber2) and Q(pNumber2).IsAndNamedParam()
				pNumber2 = pNumber2[2]
			ok
	
			if NOT ( Q(pNumber1).IsNumberOrString() and Q(pNumber2).IsNumberOrString() )
				StzRaise("Incorrect param types! pNumber1 and pNumber2 must be numbers or strings.")
			ok
		ok

		_n1_ = 0+ pNumber1
		_n2_ = 0+ pNumber2

		n = This.NumericValue()

		_bResult_ = 1

		if NOT ( _n1_ <= n and n <= _n2_ )
			_bResult_  = 0
		ok

		return _bResult_

		def IsBetweenXT(pNumber1, pNumber2)
			return This.IsBetweenIB(pNumber1, pNumber2)

	# TRUE if the number lies strictly between the two given numbers
	# (bounds excluded).
	def IsStrictlyBetween(pNumber1, pNumber2)
		if CheckingParams()
			if isList(pNumber2) and Q(pNumber2).IsAndNamedParam()
				pNumber2 = pNumber2[2]
			ok
	
			if NOT ( Q(pNumber1).IsNumberOrString() and Q(pNumber2).IsNumberOrString() )
				StzRaise("Incorrect param types! pNumber1 and pNumber2 must be numbers or strings.")
			ok
		ok

		_nCurrentRound_ = StzCurrentRound()
		StzDecimals(This.Round())

		_bResult_ = ( This.NumericValue() > 0+ pNumber1 and
			    This.NumericValue() < 0+ pNumber2 )

		StzDecimals(_nCurrentRound_)

		return _bResult_

	# Quiet equality: TRUE if the values match, tolerating
	# number/string form.
	def IsQuietEqualTo(pOtherNumber)

		if NOT Q(pOtherNumber).IsNumberOrString()
			StzRaise("Incorrect param types! pNumber1 and pNumber2 must be numbers or strings.")
		ok

		_nCurrentRound_ = StzCurrentRound()

		StzDecimals(This.Round())
		_bResult_ = ( fabs( (This - pOtherNumber).NumericValue() ) <= QuietEqualityRatio() )
		StzDecimals(_nCurrentRound_)

		return _bResult_

		def IsQuietEqual(pOtherNumber)
			return This.IsQuietEqualTo(pOtherNumber)

		def IsApproximativelyEqual(pOtherNumber)
			return This.IsQuietEqualTo(pOtherNumber)

		def IsApproximativelyEqualTo(pOtherNumber)
			return This.IsQuietEqualTo(pOtherNumber)

	  #-------------------------------------------------------------#
	 #    INTEGER & FRACTIONAL PARTS (CALLED ALSO DECIMAL PARTS)   #
	#-------------------------------------------------------------#

	def NumberOfDigits()
		return This.NumberOfDigitsInIntegerPart() + This.NumberOfDigitsInFractionalPart()

		#< @FunctionAlternativeForm

		def NumberOfDigitsTheNumberActuallyContains()
			return This.NumberOfDigits()

		#>

	def IntegerPart()
		if This.HasFractionalPart()
			return This.ToStzString().Split(".")[1]
		else
			return This.Content()
		ok

		#< @FunctionFluentForms

		def IntegrPartQ()
			return new stzString(This.InterPart())

		def IntegerPartStringValue()
			return This.IntegerPart()

			def IntegerPartStringValueQ()
				return This.IntegrPartQ()

		#>

		#< @FunctionMisspelledForms

		def IntergerPart()
			return This.IntegerPart()

			def IntergerPartQ()
				return This.IntegerPartQ()

		def IntergerPartStringValue()
			return This.IntegerPart()

			def IntergerPartStringValueQ()
				return This.IntegrPartQ()

		#>

	def IntegerPartWithoutSign()
		if NOT This.IsSigned()
			return This.IntegerPart()
		else
			return StzReplace( This.IntegerPart(), 2, len(This.IntegerPart())-1 )
		ok

		def IntegerPartWithoutSignQ()
			return new stzString(This.IntegerPartWithoutSign())

		def IntegerPartStringValueWithoutSign()
			return This.IntegerPartWithoutSign()

			def IntegerPartStringValueWithoutSignQ()
				return This.IntegerPartWithoutSignQ()

	def NumberOfDigitsInIntegerPart()
		if This.Sign() = ""
			return len(This.IntegerPart())
		else
			return len(This.IntegerPart()) - 1
		ok

		def NumberOfIntegers()
			return This.NumberOfDigitsInIntegerPart()

	def HasFractionalPart()
		if This.ToStzString().Contains(".")
			return 1
		else
			return 0
		ok

		#< @FunctionAlternativeForms

		def HasDecimalPart()
			return This.HasFractionalPart()

		def ContainsFractionalPart()
			return This.HasFractionalPart()

		def ContainsDecimalPart()
			return This.HasFractionalPart()

		#--

		def HasAFractionalPart()
			return This.HasFractionalPart()

		def HasADecimalPart()
			return This.HasFractionalPart()

		def ContainsAFractionalPart()
			return This.HasFractionalPart()

		def ContainsADecimalPart()
			return This.HasFractionalPart()

		#>

	// Returns the fraction part of the number (with a leading "0.")
	def FractionalPart()
		if This.HasFractionalPart()
			if This.IsNegative()
				return "-0." + This.FractionalPartWithoutZeroDot()
			else
				return "0." + This.FractionalPartWithoutZeroDot()
			ok
		ok

		def FractionalPartQ()
			return new stzString(This.FractionalPart())

		def DecimalPart()
			return This.FractionalPart()

			def DecimalPartQ()
				return This.FractionalPartQ()

		def FractionalPartStringValue()
			return This.FractionalPart()

			def FractionalPartStringValueQ()
				return This.FractionalPartQ()

		def DecimalPartStringValue()
			return This.FractionalPart()

			def DecimalPartStringValueQ()
				return This.FractionalPartQ()

	// Returninig only the digits of the fractional part without the "0."
	def FractionalPartWithoutZeroDot()
		if This.HasFractionalPart()
			return This.ToStzString().Split(".")[2]
		else
			return ""
		ok

		#< @FunctionFluentForm

		def FractionalPartWithoutZeroDotQ()
			return new stzString(This.FractionalPartWithoutZeroDot())

		#>

		#< @FunctionAlternativeForms


		def DecimalPartWithoutZeroDot()
			return This.FractionalPartWithoutZeroDot()

			def DecimalPartWithoutZeroDotQ()
				return This.FractionalPartWithoutZeroDotQ()

		def FractionalPartWithoutDot()
			return This.FractionalPartWithoutZeroDot()

			def FractionalPartWithoutDotQ()
				return This.FractionalPartWithoutZeroDotQ()

		def DecimalPartWithoutDot()
			return This.FractionalPartWithoutZeroDot()

			def DecimalPartWithoutDotQ()
				return This.FractionalPartWithoutZeroDotQ()

		#>

		#< @FunctionMisspelledForms # without -> wihtout

		def FractionalPartwihtoutZeroDot()
			return This.FractionalPartWithoutZeroDot()

			def FractionalPartwihtoutZeroDotQ()
				return This.FractionalPartWithoutZeroDotQ()

		def DecimalPartwihtoutZeroDot()
			return This.FractionalPartWithoutZeroDot()

			def DecimalPartwihtoutZeroDotQ()
				return This.FractionalPartWithoutZeroDotQ()

		def FractionalPartwihtoutDot()
			return This.FractionalPartWithoutZeroDot()

			def FractionalPartwihtoutDotQ()
				return This.FractionalPartWithoutZeroDotQ()

		def DecimalPartwihtoutDot()
			return This.FractionalPartWithoutZeroDot()

			def DecimalPartwihtoutDotQ()
				return This.FractionalPartWithoutZeroDotQ()

		#>

	def NumberOfDecimals()
		return len(This.FractionalPartWithoutZeroDot())

	def NumberOfDigitsInFractionalPart()
		if NOT This.HasFractionalPart()
			return 0
		else
			return len(This.FractionalPartWithoutZeroDot())
		end

		def NumberOfDigitsInDecimalPart()
			return This.NumberOfDigitsInFractionalPart()

	def MaxNumberOfDigits() # Maximum number of digits the number can contain
		_nMaxDigits_ = 0
		switch This.IsIntegerOrReal()
		on "INTEGER"
			if This.IsSigned()
				_nMaxDigits_ = MaxNumberOfDigitsInSignedInteger()
			else
				_nMaxDigits_ = MaxNumberOfDigitsInUnsignedInteger()
			ok
		
		on "REAL"
			if This.IsSigned()
				_nMaxDigits_ = MaxNumberOfDigitsInSignedRealNumber()
			else
				_nMaxDigits_ = MaxNumberOfDigitsInUnsignedRealNumber()
			ok
		off
		
		return _nMaxDigits_

		#< @FunctionAlternativeForm

		def MaxNumberOfDigitsTheNumberCanContain()
			return This.MaxNumberOfDigits()

		#>

	def IsIntegerOrReal()
		if This.IsInteger()
			return "INTEGER"
		but This.IsReal()
			return "REAL"
		ok
		
		#< @FunctionMisspelledForm

		def IsIntergerOrReal()
			return This.IsIntegerOrReal()

		#>

	def Integers()
		_anResult_ = This.IntegerPartWithoutSignQ().CharsQ().Numberified()
		return _anResult_

		#< @FunctionFluentFroms

		def IntegersQ()
			return This.IntegersQRT(:stzList)

		def IntegersQRT(pcReturnType)
			switch pcReturnType
			on :stzList
				return new stzList( This.Integers() )

			on :stzListOfNumbers
				return new stzListOfNumbers( This.Integers() )

			other
				StzRaise("Unsupported return type!")
			off

		#>

		#< @FunctionMisspelledForms

		def Intergers()
			return This.Integers()

			def IntergersQ()
				return This.IntegersQ()

			def IntergersQRT(pcReturnType)
				return This.IntegersQRT(pcReturnType)

		#>

	def Decimals()
		_anResult_ = This.DecimalPartWihtoutDotQ().CharsQ().Numberified()
		#NOTE // This is a misspelled form in Wihtout (sould be Without)
		# But Softanza recognises it understands what you meant!

		return _anResult_

		#< @FunctionFluentFroms

		def DecimalsQ()
			return This.DecimalsQRT(:stzList)

		def DecimalsQRT(pcReturnType)
			switch pcReturnType
			on :stzList
				return new stzList( This.Decimals() )

			on :stzListOfNumbers
				return new stzListOfNumbers( This.Decimals() )

			other
				StzRaise("Unsupported return type!")
			off

		#>

	def SumOfIntegers()
		_nResult_ = This.IntegersQRT(:stzListOfNumbers).Sum()
		return _nResult_

	def SumOfDecimals()
		_nResult_ = This.DecimalsQRT(:stzListOfNumbers).Sum()
		return _nResult_

	  #--------------#
	 #    ROUNDS    #
	#--------------#

	/*
	TODO: Actually, softanza rounds numbers using the native rounding service
	      provided by Ring decimals() standard function.

	      In the future, Study and reflect on enabling _Those_ rounding modes:
	      	- RoundCeiling: see if it is same as RoundUp()?
	       	- RoundFloor: see if it is same as RoundDown()?
	       	- RoundDown,
	       	- RoundUp,
	       	- RoundHalfEven,
	       	- RoundHalfDown,
	       	- RoundHalfUp,
	       	- RoundUnnecessary
	*/

	# The largest round (decimals) this number can still carry.
	def MaxRound()
		_nResult_ = len( ""+ MaxNumberInRing() ) - This.NumberOfIntegers()

		if This.ContainsDecimalPart()
			_nResult_ -= (1 + This.NumberOfDecimals())
		ok

		return _nResult_

	# How many more decimals can be added before the max round.
	def NumberOfRoundsWeCanAddBeforeMaxRoundIsReached()

		_nResult_ =  This.MaxNumberOfDigitsTheNumberCanContain() -
		      	   This.NumberOfDigitsTheNumberActuallyContains()

		return _nResult_

	#@ aka  round to nearest, nearest whole number, round off
	# Round the number to the nearest integer (mutating).
	def Round()
		return @nRound

		#< @FunctionAlternativeForms

		# These alternatives are provided to the user if
		# he wants to avoid semantic confustion the global
		# function Round(). This function is made to enable
		# external code in other languages.

		def GetRound()
			return This.Round()

		# The current round (decimals) of the number.
		def NumberRound()
			return This.Round()

		#>

	def RoundToXT(_nRound_)
		if CheckingParams()
			if isString(_nRound_) and _nRound_ = :Max
				_nRound_ = MaxRoundInRing()
			ok

			if NOT isNumber(_nRound_)
				StzRaise("Incorrect param type! nRound must be a number.")
			ok
		ok

		if _nRound_ > MaxRoundInRing()
			StzRaise("Incorrect round! nRound can't exceed the maxround in Ring, " + MaxRound() + ".")
		ok

		@nRound = _nRound_

		_nCurrentRound_ = StzCurrentRound()
		StzDecimals(_nRound_)
		@cContent = ""+ This.NumericValue()

		if This.IsInteger() and _nRound_ > 0
			@cContent += "."
			for _i_ = 1 to _nRound_
				@cContent += "0"
			next
		ok

		StzDecimals(_nCurrentRound_)

		#< @FunctionFluentForm

		def RoundToXTQ(pRound)
			This.RoundToXT(pRound)
			return This

		#>

		#< @FunctionAlternativeForm

		def SetRoundXT(_nRound_)
			This.RoundToXT(_nRound_)

			def SetRoundXTQ(_nRound_)
				return This.RoundToXTQ(_nRound_)

		#>

	def RoundedToXT(pRound)
		_cResult_ = This.Copy().RoundToXTQ(pRound).Content()
		return _cResult_

	#--

	def RoundToMaxXT()
		This.RoundToXT(:Max)


	def RoundedToMaxXT()
		return This.RoundedTo(MaxRoundXT())

	#---

	# Round the number to the given number of decimals (mutating).
	#@ aka  decimals, precision, digits after the point
	def RoundTo(_nRound_)
		_cResult_ = This.RoundToXTQ(_nRound_).
			       ToStzString().
			       RemoveThisTrailingCharQ("0"). # XT ~> All 0s are removed
			       RemovedFromEnd(".")

		This.Update(_cResult_)

		#< @FunctionFluentForm

		def RoundToQ(pRound)
			This.RoundTo(pRound)
			return This

		#>

		#< @FunctionAlternativeForm

		# Set how many decimals (the round) this number renders with.
		def SetRound(_nRound_)
			This.RoundTo(_nRound_)

			def SetRoundQ(_nRound_)
				return This.RoundToQ(_nRound_)

		#>

	# A copy rounded to the given number of decimals; the original
	# is unchanged.
	def RoundedTo(pRound)
		_cResult_ = This.Copy().RoundToQ(pRound).Content()
		return _cResult_

	#--

	# Round to the maximum round available (mutating).
	def RoundToMax()
		This.RoundTo(:Max)

	# A copy rounded to the maximum round available.
	def RoundedToMax()
		return This.RoundedTo(MaxRound())

	#---

	# The number rounded UP (toward the next integer).
	def RoundUp()
		return This.pvtCalculate( "floor", "" )

	# The number rounded DOWN (toward the previous integer).
	def RoundDown()
		return This.pvtCalculate( "ceil", "" )
			
	# Round to the same number of decimals as the given number
	# (mutating).
	def RoundToSameRoundAs(pOtherNumber)
		_oOtherNumber_ = new stzNumber(pOtherNumber)
		_nRoundOtherNumber_ = _oOtherNumber_.Round()

		This.RoundTo(_nRoundOtherNumber_)

	# TRUE if this number carries more decimals than the given one.
	def RoundIsGreaterThanRoundOf(pOtherNumber)

		_nRound_ = This.Round()

		_oOtherNumber_ = new stzNumber(pOtherNumber)
		_nOtherRound_ = _oOtherNumber_.NumberOfDigits()

		if _nRound_ > _nOtherRound_
			return 1
		else
			return 0
		ok

	# TRUE if this number carries fewer decimals than the given one.
	def RoundIsLessThanRoundOf(pOtherNumber)
		_nRound_ = This.Round()

		_oOtherNumber_ = new stzNumber(pOtherNumber)
		_nOtherRound_ = _oOtherNumber_.NumberOfDigits()

		if _nRound_ < _nOtherRound_
			return 1
		else
			return 0
		ok
	
	# TRUE if both numbers carry the same number of decimals.
	def RoundIsSameAsRoundOf(pOtherNumber)
		_nRound_ = This.Round()

		_oOtherNumber_ = new stzNumber(pOtherNumber)
		_nOtherRound_ = _oOtherNumber_.NumberOfDigits()

		if _nRound_ = _nOtherRound_
			return 1
		else
			return 0
		ok

	# Compare the rounds: :Greater, :Less or :Same.
	def CompareRoundsWith(pOtherNumber)
		if  This.IsRoundSameAs(pOtherNumber)
			return :Equal

		but This.IsRoundGreaterThanRoundOf(pOtherNumber)
			return :Greater

		but This.IsRoundLessThanRoundOf(pOtherNumber)
			return :Less
		ok

	  #----------------#
	 #    ADDITION    #
	#----------------#

	# Add the given number to this one (mutating). For a copy, use
	# Added.
	#@ aka  plus, sum, increase, increment
	def Add(pOtherNumber)
		_StzHistoOpen(0 + This.Content())
		This.Update( pvtCalculate("+", pOtherNumber ) )
		_StzHistoAdd(0 + This.Content())

		#< @FunctionFluentForm

		def AddQ(pOtherNumber)
			This.Add(pOtherNumber)
			return This

		#>

	#-- @FunctionPassiveForm

	# The sum with the given number, as data; the original is
	# unchanged.
	def Added(pOtherNumber)
		_nResult_ = This.Copy().AddQ(pOtherNumber).NumericValue()
		return _nResult_


	# Add each of the given numbers to this number (mutating).
	def AddMany(paOtherNumbers)
		This.AddManyXT(paOtherNumbers, :ReturnIntermediateResults = 0)

		#< @FunctionFluentForm

		def AddManyQ(paOtherNumbers)
			This.AddMany(paOtherNumbers)
			return This

		#>

		#< @FunctionAlternativeForm

		# Same as AddMany.
		def AddThese(paOtherNumbers)
			This.AddMany(paOtherNumbers)

			def AddTheseQ(paOtherNumbers)
				This.AddThese(paOtherNumbers)
				return This

		#>

	#-- @FunctionPassiveForm

	# The sum with all the given numbers, as data; the original is
	# unchanged.
	def AddedMany(pOtherNumbers)
		_nResult_ = This.Copy().AddManyQ(pOtherNumbers).NumbericValue()
		return _nResult_


		def ManyAdded(pOtherNumbers)
			return This.AddedMany(pOtherNumbers)

			def TheseAdded(pOtherNumbers)
				return This.ManyAdded(pOtherNumbers)

		#>
	
	# AddMany returning every intermediate sum along the way.
	def AddManyWithIntermediateResults(paOtherNumbers)
		return This.AddManyXT(paOtherNumbers, :ReturnIntermediateResults = 1)

		#< @FunctionFluentForm

		def AddManyWithIntermediateResultsQ(paOtherNumbers)
			return new stzListOfNumbers( This.AddManyWithIntermediateResults(paOtherNumbers) )
	
		#>

		#< @FunctionAlternativeForm

		def AddTheseWithIntermediateResults(paOtherNumbers)
			This.AddManyWithIntermediateResults(paOtherNumbers)

			def AddTheseWithIntermediateResultsQ(paOtherNumbers)
				This.AddTheseWithIntermediateResults(paOtherNumbers)
				return This

		#>

	def AddManyXT(paOtherNumbers, paReturnIntermediateResults)
		if CheckingParams()
			if NOT ( isList(paOtherNumbers) and @IsListOfNumbersOrStrings(paOtherNumbers) )
				StzRaise("Incorrect param type! paOtherNumbers must be a list of numbers or strings.")
			ok
		ok

		_bReturnIntermediateResults_ = 0

		if paReturnIntermediateResults[1] = :ReturnIntermediateResults and
		   paReturnIntermediateResults[2] = 1

			_bReturnIntermediateResults_ = 1
		ok

		_nLen_ = len(paOtherNumbers)
		_aIntermediateResults_ = []

		for _i_ = 1 to _nLen_
			This.Add(paOtherNumbers[_i_])
			_aIntermediateResults_ + This.Content()
		next

		if _bReturnIntermediateResults_
			return _aIntermediateResults_
		ok

		#< @FunctionFluentForm

		def AddManyXTQ(paOtherNumbers, paReturnIntermediateResults)
			return new stzListOfNumbers( This.AddManyXT(paOtherNumbers, paReturnIntermediateResults) )
	
		#>

		#< @FunctionAlternativeForm

		def AddTheseXT(paOtherNumbers, paReturnIntermediateResults)
			This.AddManyXT(paOtherNumbers, paReturnIntermediateResults)

			def AddTheseXTQ(paOtherNumbers, paReturnIntermediateResults)
				This.AddTheseXT(paOtherNumbers, paReturnIntermediateResults)
				return This

		#>

	  #--------------------#
	 #    SubStructION    #
	#--------------------#

	# Subtract the given number from this one (mutating).
	#@ aka  subtract, minus, decrease, take away
	def SubStruct(pOtherNumber)

		_StzHistoOpen(0 + This.Content())
		This.Update( pvtCalculate("-", pOtherNumber ) )
		_StzHistoAdd(0 + This.Content())

		#< @FunctionFluentForm

		def SubStructQ(pOtherNumber)
			This.SubStruct(pOtherNumber)
			return This
	
		#>

		#< @FunctionAlternativeForms

		# Subtract the given number from this one (same as SubStruct).
		def Retrieve(pOtherNumber)
			This.SubStruct(pOtherNumber)

			def RetrieveQ(pOtherNumber)
				This.Retrieve(pOtherNumber)
				return This

		def Substract(pOtherNumber)
			This.SubStruct(pOtherNumber)

			def SubstractQ(pOtherNumber)
				return This.RetrieveQ(pOtherNumber)

		def Subtract(pOtherNumber)
			This.SubStruct(pOtherNumber)

			def SubtractQ(pOtherNumber)
				return This.RetrieveQ(pOtherNumber)

		def Subtruct(pOtherNumber)
			This.SubStruct(pOtherNumber)

			def SubtructQ(pOtherNumber)
				return This.RetrieveQ(pOtherNumber)

		#>

		#< @FunctionPassiveForm

		# The difference after subtracting the given number, as data.
		def Substructed(pOtherNumber)
			_nResult_ = This.Copy().SubstructQ(pOtherNumber).NumericValue()
			return _nResult_

			# The difference after subtracting the given number, as data.
			def Retrieved(pOtherNumber)
				return This.Substructed(pOtherNumber)

		# The difference after subtracting the given number, as data.
		def Substracted(pOtherNumber)
			return This.SubStructed(pOtherNumber)

		# The difference after subtracting the given number, as data.
		def Subtracted(pOtherNumber)
			return This.SubStructed(pOtherNumber)

		# The difference after subtracting the given number, as data.
		def Subtructed(pOtherNumber)
			return This.SubStructed(pOtherNumber)

		#>

	# Subtract each of the given numbers from this number (mutating).
	def SubStructMany(paOtherNumbers)
		#TODO // Add "These" as alternative of "Many"

		This.SubStructManyXT(paOtherNumbers, :ReturnIntermediateResults = 0)

		#< @FunctionFluentForm

		def SubStructManyQ(paOtherNumbers)
			This.SubStructMany(paOtherNumbers)
			return This

		#>

		#< @FunctionAlternativeForms

		def SubstractMany(pOtherNumbers)
			This.SubStructMany(pOtherNumbers)

		def SubtractMany(pOtherNumbers)
			This.SubStructMany(pOtherNumbers)

		def SubtructMany(pOtherNumbers)
			This.SubStructMany(pOtherNumbers)

		#>

		#< @FunctionPassiveForms

		# The value after subtracting all the given numbers, as data.
		def SubstructedMany(pOtherNumbers)
			_nResult_ = This.Copy().SubStructManyQ(pOtherNumbers).Content()
			return _nResult_

		# The value after subtracting all the given numbers, as data.
		def SubstractedMany(pOtherNumber)
			return This.SubStructedMany(pOtherNumbers)

		# The value after subtracting all the given numbers, as data.
		def SubtractedMany(pOtherNumbers)
			return This.SubStructedMany(pOtherNumbers)

		# The value after subtracting all the given numbers, as data.
		def SubtructedMany(pOtherNumbers)
			return This.SubStructedMany(pOtherNumbers)

		#>


	#--

	def SubStructManyXT(paOtherNumbers, paReturnIntermediateResults)
		#TODO // Add "These" as alternative of "Many"

		if CheckingParams()
			if NOT ( isList(paOtherNumbers) and @IsListOfNumbersOrStrings(paOtherNumbers) )
				StzRaise("Incorrect param type! paOtherNumbers must be a list of numbers or strings.")
			ok
		ok
	
		_bReturnIntermediateResults_ = 0
		if paReturnIntermediateResults[1] = :ReturnIntermediateResults and
		   paReturnIntermediateResults[2] = 1

			_bReturnIntermediateResults_ = 1
		ok
	
		_nLen_ = len(paOtherNumbers)
		_aIntermediateResults_ = []

		for _i_ = 1 to _nLen_
			This.SubStruct(paOtherNumbers[_i_])
			_aIntermediateResults_ + This.Content()
		next
	
		if _bReturnIntermediateResults_
			return _aIntermediateResults_
		ok

		#< @FunctionFluentForm

		def SubStructManyXTQ(paOtherNumbers, paReturnIntermediateResults)
			if paReturnIntermediateResults[1] = 0
				This.SubStructManyXT(paOtherNumbers, paReturnIntermediateResults)
				return This

			else
				return stzListOfNumbers( This.SubStructManyXT(paOtherNumbers, paReturnIntermediateResults) )
			ok

		#>

						
	# Subtract each of the given numbers (same as SubStructMany).
	def RetrieveMany(paOtherNumbers)
		#TODO // Add "These" as alternative of "Many"

		This.SubStructMany(paOtherNumbers)

		def RetrieveManyQ(paOtherNumbers)
			This.RetrieveMany(paOtherNumbers)
			return This
	
		def RetrieveManyXT(paOtherNumbers, paReturnIntermediateResults)
			return This.SubStructManyXT(paOtherNumbers, paReturnIntermediateResults)
			
			def RetrieveManyXTQ(paOtherNumbers, paReturnIntermediateResults)
				return This.SubStructManyXTQ(paOtherNumbers, paReturnIntermediateResults)
  	
	  #-------------------------------------------#
	 #  INCRMENET / DECREMENT THE NUMBER (BY 1)  #
	#-------------------------------------------#

	def Increment()
		This.Add(1)

		def IncrementQ()
			This.Add(1)
			return This

	def Incremented()
		_nResult_ = This.NumericValue() + 1

	#--

	def Decrement()
		This.Substract(1)

		def DecrementQ()
			This.Subtract(1)
			return This

	def Decremented()
		_nResult_ = This.NumericValue() - 1

	  #-------------------------------------------------#
	 #    MULTIPLYING THE NUMBER BY AN OTHER NUMBER    #
	#-------------------------------------------------#

	def MultiplyBy(pOtherNumber)

		if CheckingParams()
			if isList(pOtherNumber)
				This.MultiplyByMany(pOtherNumber)
				return
			ok
		ok

		_StzHistoOpen(0 + This.Content())
		This.Update( pvtCalculate("*", pOtherNumber ) )
		_StzHistoAdd(0 + This.Content())

		#< @FunctionAlternativeForm

		def MultiplyByQ(pOtherNumber)
			This.MultiplyBy(pOtherNumber)
			return This
	
		#>

		#< @FunctionAlternativeForm

		def Multiply(pOtherNumber)
			if CheckingParams()
				if isList(pOtherNumber) and Q(pOtherNumber).IsByOrWithOrUsingNamedParam()
					pOtherNumber = pOtherNumber[2]
				ok
			ok

			This.MultiplyBy(pOtherNumber)

		#>

	def MultipliedBy(pOtherNumber)
		_nResult_ = This.Copy().MultiplyByQ(pOtherNumber).NumericValue()
		return _nResult_

		def Multiplied(pOtherNumber)
			return This.MultipliedBy(pOtherNumber)

		def Times(pOtherNumber)
			return This.MultipliedBy(pOtherNumber)

	  #----------------------------------------------------#
	 #    MULTIPLYING THE NUMBER BY MANY OTHER NUMBERS    #
	#----------------------------------------------------#

	def MultiplyByMany(paOtherNumbers)
		#TODO // Add "These" as alternative of "Many"

		This.MultiplyByManyXT(paOtherNumbers, :ReturnIntermediateResults = 0)

		#< @FunctionFluentForm

		def MultiplyByManyQ(paOtherNumbers)
			This.MultiplyByMany(paOtherNumbers)
			return This
	
		#>
	
		def MultipliedByMany(paOtherNumbers)
			_nResult_ = This.Copy().MultiplyByManyQ(paOtherNumbers).NumericValue()
			return _nResult_

	def MultiplyByManyXT(paOtherNumbers, paReturnIntermediateResults)
		#TODO // Add "These" as alternative of "Many"

		if CheckingParams()
			if NOT ( isList(paOtherNumbers) and @IsListOfNumbersOrStrings(paOtherNumbers) )
				StzRaise("Incorrect param type! paOtherNumbers must be a list of numbers or strings.")
			ok
		ok

		_aIntermediateResults_ = []
	
		_bReturnIntermediateResults_ = 0
	
		if paReturnIntermediateResults[1] = :ReturnIntermediateResults and
		   paReturnIntermediateResults[2] = 1
	
			_bReturnIntermediateResults_ = 1
		ok
	
		_nLen_ = len(paOtherNumbers)
		_aIntermediateResults_ = []

		for _i_ = 1 to _nLen_
			This.MultiplyBy(paOtherNumbers[_i_])
			_aIntermediateResults_ + This.Content()
		next
	
		if _bReturnIntermediateResults_
			return _aIntermediateResults_
		ok		

	  #----------------#
	 #    DIVISION    #
	#----------------#

	# Divide this number by the given one (mutating).
	def Divide(pOtherNumber)
		if CheckingParams()

			if isList(pOtherNumber) and Q(pOtherNumber).IsByNamedParam()
				paByDividor = paByDividor[2]
			ok
	
		ok

		This.DivideBy(pOtherNumber)

		#< @FunctionFluentForm

		def DivideQ(pOtherNumber)
			This.Divide(pOtherNumber)
			return This

		#>

		#< @FunctionPassiveForm

		# The quotient by the given number, as data; the original is
		# unchanged.
		def Divided(pOtherNumber)
			_nResult_ = This.Copy().DivideQ(pOtherNumber).NumericValue()
			return _nResult_

		#>

	# Divide this number by the given one (mutating).
	#@ aka  over, quotient, split by, divided
	def DivideBy(pOtherNumber)
		_StzHistoOpen(0 + This.Content())
		This.Update( pvtCalculate("/", pOtherNumber ) )
		_StzHistoAdd(0 + This.Content())

		#< @FunctionFluentForm

		def DivideByQ(pOtherNumber)
			This.DivideBy(pOtherNumber)
			return This

		#>

		#< @FunctionPassiveForm

		# The quotient by the given number, as data.
		def DividedBy(pOtherNumber)
			_nResult_ = This.Copy().DivideByQ(pOtherNumber).NumericValue()
			return _nResult_

		#>
	
	# Divide this number by each of the given numbers in turn
	# (mutating).
	def DivideByMany(paOtherNumbers)
		#TODO // Add "These" as alternative of "Many"

		This.DivideByManyXT(paOtherNumbers, :ReturnIntermediateResults = 0)

		#< @FunctionFluentForm

		def DivideByManyQ(paOtherNumbers)
			This.DivideByMany(paOtherNumbers)
			return This
	
		#>

		# A copy divided by each of the given numbers.
		def DividedByMany(paOtherNumbers)
			_nResult_ = This.Copy().DivideByManyQ(paOtherNumbers).NumericValue()
			return _nResult_

	def DivideByManyXT(paOtherNumbers, paReturnIntermediateResults)
		#TODO // Add "These" as alternative of "Many"

		if CheckingParams()
			if NOT ( isList(paOtherNumbers) and @IsListOfNumbersOrStrings(paOtherNumbers) )
				StzRaise("Incorrect param type! paOtherNumbers must be a list of numbers or strings.")
			ok
		ok

		_aIntermediateResults_ = []
	
		_bReturnIntermediateResults_ = 0
	
		if paReturnIntermediateResults[1] = :ReturnIntermediateResults and
		   paReturnIntermediateResults[2] = 1
	
			_bReturnIntermediateResults_ = 1
		ok
	
		_nLen_ = len(paOtherNumbers)
		_aIntermediateResults_ = []

		for _i_ = 1 to _nLen_
			This.DivideBy(paOtherNumbers[_i_])
			_aIntermediateResults_ + This.Content()
		next
	
		if _bReturnIntermediateResults_
			return _aIntermediateResults_
		ok
	
	  #-------------#
	 #    MATHS    #
	#-------------#

	# MODULO

	#@ aka  remainder, mod, leftover of division
	# The remainder of the division by the given number.
	def Modulo(pOtherNumber)
		return This.pvtCalculate("%", pOtherNumber)

		def ModuloQ(pOtherNumber)
			return new stzNumber(This.Modulo(pOtherNumber))
	
	# POWER

	#@ aka  to the power of, exponent, raised to, power
	# Raise the number to the given power (mutating).
	def Power(pOtherNumber)
		return This.pvtCalculate("^", pOtherNumber)

		def PowerQ(pOtherNumber)
			return new stzNumber(This.Power(pOtherNumber))
	
	# SINE

	# The sine of the number (mutating: the number becomes it).
	def Sine()
		return This.pvtCalculate( "sin", "" )

		def SineQ()
			return new stzNumber(This.Sine())
	
	# COSINE

	# The cosine of the number (mutating).
	def Cosine()
		return This.pvtCalculate( "cos", "" )

		def CosineQ()
			return new stzNumber(This.Cosine())
	
	# TANGENT

	# The tangent of the number (mutating).
	def Tangent()
		return This.pvtCalculate( "tan", "" )
		
		def TangentQ()
			return new stzNumber(This.Tangent())
	
	# COTANGENT

	# The cotangent of the number (mutating).
	def Cotangent()
		return This.pvtCalculate( "cotan", "" )

		def CotangentQ()
			return new stzNumber(This.Cotangent())
	
	# ARCSINE

	# The arc sine of the number (mutating).
	def ArcSine()
		return This.pvtCalculate( "asin", "" )
	
		def ArcSineQ()
			return new stzNumber(This.ArcSine())
	
	# ARCCOSINE

	# The arc cosine of the number (mutating).
	def ArcCosine()
		return This.pvtCalculate( "acos", "" )

		def ArcCosineQ()
			return new stzNumber(This.ArcCosine())
	
	# ARCTANGENT

	# The arc tangent of the number (mutating).
	def ArcTangent()
		return This.pvtCalculate( "atan", "" )

		def ArcTangentQ()
			return new stzNumber(This.ArcTangent())
	
	# ARCTANGENT2

	# The two-argument arc tangent (atan2) of the number (mutating).
	def ArcTangent2()
		return This.pvtCalculate( "atan2", "" )

		def ArcTangent2Q()
			return new stzNumber(This.ArcTangent2())
	
	# SINH

	# The hyperbolic sine of the number (mutating).
	def HyperbolicSine()
		return This.pvtCalculate( "sinh", "" )

		def HyperbolicSineQ()
			return new stzNumber(This.HyperbolicSine())
	
	# COSH

	# The hyperbolic cosine of the number (mutating).
	def HyperbolicCosine()
		return This.pvtCalculate( "cosh", "" )

		def HyperbolicCosineQ()
			return new stzNumber(This.HyperbolicCosine())
	
	# TANH

	# The hyperbolic tangent of the number (mutating).
	def HyperbolicTangent()
		return This.pvtCalculate( "tanh", "" )

		def HyperbolicTangentQ()
				return new stzNumber(This.HyperbolicTangent())
	
	# EXP

	# e raised to the number (mutating).
	def Exponential()
		return This.pvtCalculate( "exp", "" )

		def ExponentialQ()
			return new stzNumber(This.Exponential())
	
	# LOG

	# The natural logarithm (base e) of the number (mutating).
	def NaturalLogarithm()
		return This.pvtCalculate( "log", "" )

		def NaturalLogarithmQ()
			return new stzNumber(This.NaturalLogarithmQ())
	
	# LOG10

	# The common logarithm (base 10) of the number (mutating).
	def CommonLogarithm()
		return This.pvtCalculate( "log10", "" )

		def CommonLogarithmQ()
			return new stzNumber(This.CommonLogarithm())
	
	# ABS

	# The absolute value of the number (mutating).
	#@ aka  abs, magnitude, positive value, without sign
	def Absolute()
		if This.IsInteger()
			n = This.NumericValue()
			if n < 0
				return -n
			else
				return n
			ok
		else
			_oStrNumber_ = new stzString(This.Content())
			if _oStrNumber_.FirstChar() = "-"
				return _oStrNumber_.FirstCharRemoved()
			else
				return _oStrNumber_.Content()
			ok
		ok

		def AbsoluteQ()
			return new stzNumber(This.AbsoluteQ())

		#@ aka  absolute value, magnitude, without the sign, distance from zero
		def Abs()
			return This.Absolute()

			def AbsQ()
				return This.AbsoluteQ()
	
	# SQRT

	#@ aka  square root, sqrt, root of the number
	# The square root of the number (mutating).
	def SquareRoot()
		return This.pvtCalculate( "sqrt", "" )

		def SquareRootQ()
			return new stzNumber(This.SquareRoot())
	
	# FACT

	# The factorial of the (integer) number (mutating).
	#@ aka  factorial of, n bang, product of integers up to
	def Factorial()
		if NOT This.IsInteger()
			StzRaise("Can't compute factorial of a non-integer!")
		ok
		n = This.NumericValue()
		if n < 0
			StzRaise("Can't compute factorial of a negative number!")
		ok
		pBigInt = StzEngineNumberFactorial(n)
		_cResult_ = StzEngineBigIntToString(pBigInt)
		StzEngineBigIntFree(pBigInt)
		return _cResult_

		def FactorialQ()
				return new stzNumber(This.Factorial())
	
	# PERCENT

	# The number as a percentage string.
	def InPercentage()
		return This.pvtCalculate( "/", 10 ) + "%"

	# SIGMOID

	# The sigmoid of the number (mutating).
	def Sigmoid()
		return This.pvtCalculate( "sigmoid", "" )

		def SigmoidQ()
			return new stzNumber(This.Sigmoid())
	

	# The derivative via the engine calculator (reserved form).
	def Derivative(pcFunc)
		return This.pvtCalculate( "derivative", pcdef ) 

		def DerivativeQ(pcFunc)
				return new stzNumber(This.Derivative(pcFunc))
	
	# DERIVATIVE SIGMOID

	# The sigmoid derivative of the number (mutating).
	def DerivativeSigmoid()
		return This.pvtCalculate( "DerivativeSigmoid", "" )

		def DerivativeSigmoidQ()
			return new stzNumber(This.DerivativeSigmoid())
	

	# The least common multiple with the given number.
	def LeastCommonMultiple(pOtherNumber)

		if isList(pOtherNumber) and Q(pOtherNumber).IsWithNamedParam()
			pOtherNumber = pOtherNumber[2]
		ok

		if isList(pOtherNumber) and
			( Q(pOtherNumber).IsListOfNumbers() or
			  Q(pOtherNumber).IsListOfNumbersInStrings() )

			return This.LeastCommonMultipleOfManyNumbers(pOtherNumber)

		but isNumber(pOtherNumber) or 
		    ( isString(pOtherNumber) and (pOtherNumbe).IsNumberInString() )
			return pvtCalculate( "LCM", pOtherNumber)
		
		else
			StzRaise("Incorrect param type! pOtherNumber must be a number in string or a list of numbers (or numbers in strings).")

		ok

		def LeastCommonMultipleQ(pOtherNumber)
			return new stzNumber(This.LeastCommonMultiple(pOtherNumber))


	# The greatest common divisor with the given number.
	def GreatestCommonDividor(pOtherNumber)
		return This.pvtCalculate( "GCD", pOtherNumber)

		def GreatestCommonDividorQ(n)
			return new stzNumber(This.GreatCommonDividor())

		def CommonGreatestDividor(pOtherNumber)
			return This.GreatestCommonDividor(pOtherNumber)
	
	# INVERSE

	# The multiplicative inverse (1/n) of the number (mutating).
	def Inverse()
		return This.pvtCalculate( "inverse", "" )

		def InverseQ()
			return new stzNumber(This.Inverse())
	
	# FACTORS

	# The factors (divisors) of the integer number, as a list.
	def Factors()
		if NOT This.IsInteger()
			StzRaise("Factors can't be computed for a non integer!")
		ok

		// Returns the factors of just the integer part!
		if This.NumericValue() > 0
			return ring_factors(This.IntegerPartValue())
		else
			StzRaise("For factors(n), n must must be positive!")
		ok

		#< @FunctionFluentForm

		def FactorsQ()
			return This.FactorsQRT(:stzList)

		# The factors, in the requested return type (QRT).
		def FactorsQRT(pcReturnType)
			switch pcReturnType
			on :stzList
				return new stzList( This.Factors() )
			on :stzListOfNumbers
				return new stzListOfNumbers( This.Factors() )
			other
				StzRaise("Unsupported return type!")
			off

		#>

		#< @FunctionAlternativeForm

		def Dividors()
			return This.Factors()

		def Divisors()
			return This.Factors()

		#>

		#< @FunctionMisspelledForm

		def Divirdos()
			return This.Factors()

		#>

	def FactorsXT()
		_anFactors_ = This.Factors()
		_nLen_ = len(_anFactors_)

		_aResult_ = []
		for _i_ = 1 to _nLen_
			_aResult_ + [ _anFactors_[_i_], This.IntegerPartValue() / _anFactors_[_i_] ]
		next

		return _aResult_

		#< @FunctionFluentForm

		# The factors, in the requested return type (variant form).
		def FactorsXRQ()
			return This.FactorsXTQRT(:stzList)

		# The factors with options, in the requested return type.
		def FactorsXTQRT(pcReturnType)
			switch pcReturnType
			on :stzList
				return new stzList( This.FactorsXT() )
			on :stzListOfNumbers
				return new stzListOfNumbers( This.FactorsXT() )
			other
				StzRaise("Unsupported return type!")
			off

		#>

		#< @FunctionAlternativeForm

		def DividorsXT()
			return This.FactorsXT()

		def DivisorsXT()
			return This.FactorsXT()

		#>

		#< @FunctionMisspelledForm

		def DivirdosXT()
			return This.Factors()

		#>

	# The prime factors of the number, as a list.
	def PrimeFactors()
		_aResult_ = []

		_aThisFactors1_ = This.Factors()
		_nThisFactors1Len_ = len(_aThisFactors1_)
		for _iLoopThisFactors1_ = 1 to _nThisFactors1Len_
			n = _aThisFactors1_[_iLoopThisFactors1_]
			_oTempNumber_ = new stzNumber(n)

			if _oTempNumber_.IsPrimeNumber()
				_aResult_ + n
			ok
		next

		return _aResult_


		#< @FunctionFluentForm

		def PrimeFactorsQ()
			return This.PrimeFactorsQRT(:stzList)

		# The prime factors, in the requested return type (QRT).
		def PrimeFactorsQRT(pcReturnType)
			switch pcReturnType
			on :stzList
				return new stzList( This.Factors() )
			on :stzListOfNumbers
				return new stzListOfNumbers( This.Factors() )
			other
				StzRaise("Unsupported return type!")
			off

		#>

		#< @FunctionAlternativeForm

		def PrimeDividors()
			return This.PrimeFactors()

		def PrimeDivisors()
			return This.PrimeFactors()

		#>

		#< @FunctionMisspelledForm

		def PrimeDivirdos()
			return This.PrimeFactors()

		#>

	def PrimeFactorsXT()
		_aResult_ = []
		_aThisPrimeFactors1_ = This.PrimeFactors()
		_nThisPrimeFactors1Len_ = len(_aThisPrimeFactors1_)
		for _iLoopThisPrimeFactors1_ = 1 to _nThisPrimeFactors1Len_
			n = _aThisPrimeFactors1_[_iLoopThisPrimeFactors1_]
			_aResult_ + [ n, This.IntegerPartValue() / n ]
		next
		return _aResult_

		#< @FunctionFluentForm

		# The prime factors, in the requested return type (variant
		# form).
		def PrimeFactorsXRQ()
			return This.PrimeFactorsXTQRT(:stzList)

		# The prime factors with options, in the requested return type.
		def PrimeFactorsXTQRT(pcReturnType)
			switch pcReturnType
			on :stzList
				return new stzList( This.PrimeFactorsXT() )
			on :stzListOfNumbers
				return new stzListOfNumbers( This.PrimeFactorsXT() )
			other
				StzRaise("Unsupported return type!")
			off

		#>

		#< @FunctionAlternativeForm

		def PrimeDividorsXT()
			return This.PrimeFactorsXT()

		def PrimeDivisorsXT()
			return This.PrimeFactorsXT()

		#>

		#< @FunctionMisspelledForm

		def PrimeDivirdosXT()
			return This.PrimeFactors()

		#>

	# The factor pair closest to a square (rows x cols).
	def MostSquareLikeFactors()
		return @MostSquareLikeFactors(This.Content())

		def MSLF()
			return This.MostSquareLikeFactors()

	# MULTIPLES UNTIL

	# How many multiples of the given number divide into this one.
	def NumberOfMultiples(pOtherNumber)
		return len( This.Multiples(pOtherNumber) )

	# How many multiples fit up to the given limit.
	def NumberOfMultiplesUntil(pOtherNumber)
		return len( This.MultiplesUntil(pOtherNumber) )

		def NumberOfMultiplesUpTo(pOtherNumber)
			return This.NumberOfMultiplesUntil(pOtherNumber)

	# The multiples of the number up to the given count.
	def Multiples(pOtherNumber)
		if isList(pOtherNumber) and
		   IsOneOfTheseNamedParamsList(pOtherNumber, [ :Until, :UpTo, :Under ])
			pOtherNumber = pOtherNumber[2]
		ok

		return This.MultiplesUntil(pOtherNumber)

	# The multiples of the number up to the given limit.
	def MultiplesUntil(pOtherNumber)

		if CheckingParams()

			if NOT (isNumber(pOtherNumber) or isString(pOtherNumber))
				StzRaise("Incorrect param type! pOtherNumber must be a number or a string.")
			ok
	
			if isString(pOtherNumber) and
			   NOT Q(pOtherNumber).IsNumberInString()
				StzRaise("Incorrect value! pOtherNumber must be a number in string.")
			ok
		ok

		_nOtherNumber_ = StzNumberQ(pOtherNumber).NumericValue()
		if _nOtherNumber_ <= This.NumericValue()
			StzRaise("Can't proceed! pOtherNumber must be >= your main number.")
		ok

		# Memorizing the current round in the program
		# (actuated by StzDecimals() that you should
		# use instead of the standard Ring decimals()

		_nCurrentRound_ = StzCurrentRound()

		# Getting the round of the other number

		_nOtherRound_ = _nCurrentRound_
		if isString(pOtherNumber)
			_nOtherRound_ = StzNumberQ(n).Round()
		ok

		# Applying the max between the two rounds
		# (becausse we want the calculation to be
		# as precise as possiblle)

		StzDecimals( @Max([ This.Round(), _nOtherRound_ ]) )

		# Doing the job under that round

		_bInteger_ = 0
		if This.IsInteger() and Q(pOtherNumber).IsInteger()
			_bInteger_ = 1
		ok

		_aResult_ = []
		_bContinue_ = 1
		_i_ = 0
		while _bContinue_
			_i_++
			n = This.MultipliedBy(_i_)
			if _bInteger_
				n = 0+ n
			ok

			if n <= _nOtherNumber_
				_aResult_ + n
			else
				_bContinue_ = 0
			ok
		end

		return _aResult_

		# Resetting the current round

		StzDecimals( _nCurrentRound_ )

		def MultiplesUntilQ(pOtherNumber)
			return This.MultiplesUntilQRT(pOtherNumber, :stzList)

		# The multiples up to the limit, in the requested return type.
		def MultiplesUntilQRT(pOtherNumber, pcReturnType)

			if isList(pcReturnType) and Q(pcReturnType).IsReturnedAsNamedParam()
				pcReturnType = pcReturnType[2]
			ok

			if NOT ( isString(pcReturnType) and Q(pcReturnType).IsStzType() )
				StzRaise("Incorrect param! pcReturnType must be a string containing the name of a Softanza class.")
			ok

			switch pcReturnType
			on :stzList
				return new stzList( This.MultiplesUntil(pOtherNumber) )

			on :stzListOfNumbers

				_anMultiples_ = This.MultiplesUntil(pOtherNumber)

				_anNumbers_ = []
				_nAnMultiples1Len_ = len(_anMultiples_)
				for _iLoopAnMultiples1_ = 1 to _nAnMultiples1Len_
					n = _anMultiples_[_iLoopAnMultiples1_]
					if isString(n)
						_anNumbers_ + ( 0+ n )
					else
						_anNumbers_ + n
					ok
				next

				return new stzListOfNumbers( _anNumbers_ )

			on :stzListOfStrings
				_acNumbers_ = []
				_aThisMultiplesUntilpOther1_ = This.MultiplesUntil(pOtherNumber)
				_nThisMultiplesUntilpOther1Len_ = len(_aThisMultiplesUntilpOther1_)
				for _iLoopThisMultiplesUntilpOther1_ = 1 to _nThisMultiplesUntilpOther1Len_
					n = _aThisMultiplesUntilpOther1_[_iLoopThisMultiplesUntilpOther1_]
					if isNumber(n)
						_acNumbers_ + ( ""+ n )
					else
						_acNumbers_ + n
					ok
				next

				return new stzListOfNumbers( _anNumbers_ )

			other
				StzRaise("Unssupported return type!")
			off


		def MultiplesUpTo(pOtherNumber)
			return This.MultiplesUntil(pOtherNumber)

		def MultiplesUnder(pOtherNumber)
			return This.MultiplesUntil(pOtherNumber)

	# DIVIDABILITY

	# TRUE if the number divides evenly by n.
	def IsDividableBy(n)
		if CheckingParams()
			if NOT @IsNumberOrString(n)
				StzRaise("Incorrect param type! n must be a number or string.")
			ok

			if isString(n) and NOT Q(n).IsDecimalNumberInString()
				StzRaise("Incorrect value! n must be a decimal number in string.")
			ok
		ok

		# Memorizing the current round in the program
		# (actuated by StzDecimals() that you should
		# use instead of the standard Ring decimals()

		_nCurrentRound_ = StzCurrentRound()

		# Getting the round of the other number

		_nOtherRound_ = _nCurrentRound_
		if isString(n)
			_nOtherRound_ = StzNumberQ(n).Round()
		ok

		# Applying the max between the two rounds
		# (becausse we want the calculation to be
		# as precise as possiblle)

		StzDecimals( @Max([ This.Round(), _nOtherRound_ ]) )

		# Doing the job under that round

		n = StzNumberQ(n).NumericValue()

		_oTempList_ = new stzList( This.Factors() )
		_bResult_ = 0

		if _oTempList_.Contains(n)
			_bResult_ = 1
		ok

		# Resetting the current round

		StzDecimals(_nCurrentRound_)

		# Returning the result

		return _bResult_

		def IsDivisibleBy(n)
			return This.IsDividableBy(n)

		def CanBeDividedBy(n)
			return This.IsDividableBy(n)
			
	# TRUE if the number divides evenly INTO n.
	def IsDividorOf(n)	// Main Number and n must be integers!
		_oNumber_ = new stzNumber(n)

		return _oNumber_.IsDividableBy(This.IntegerPartValue())

	# The integer part, as a number.
	def IntegerPartValue()
		return 0+ This.IntegerPart()

		def IntegerPartNumericValue()
			return This.IntegerPartValue()

	# The fractional part, as a number.
	def FractionalPartValue()
		return 0+ This.FractionalPart()

		def DecimalPartValue()
			return This.FractionalPartValue()

		def FractionalPartNumericValue()
			return This.FractionalPartValue()

		def DecimalPartNumericValue()
			return This.FractionalPartValue()

	  #-------------------#
	 #     CONVERSION    #
	#-------------------#

	# The number wrapped as a stzString object.
	def ToStzString()
		return new stzString(This.Content())
	
	# Converting decimal to hex form
	
	def ToHexForm()
		_cResult_ = HexNumberPrefix() + This.ToHexFormWithoutPrefix()
		return _cResult_

		#< @FunctionFluentForm

		def ToHexFormQ()
			return new stzHexNumber( This.ToHexForm() )

		#>

		#< @FunctionAlternativeForm

		#@ aka  hexadecimal, hex, base 16
		# The number in hexadecimal form.
		def ToHex()
			return ToHexForm()

			def ToHexQ()
				return new stzHexNumber( This.ToHex() )

		#>

	# The number wrapped as a stzHexNumber object.
	def ToHexNumber()
		return new stzHexNumber( This.ToHex() )

	# The number in Unicode hex form (U+0041).
	def ToUnicodeHexForm()
		return "U+" + This.ToHexFormWithoutPrefix()
	
		#< @FunctionAlternativeForms

		# The number in Unicode hex form (U+0041).
		def ToUnicodeHex()
			return ToUnicodeHexForm()

		# The number in Unicode hex form (U+0041).
		def ToHexUnicode()
			return ToUnicodeHexForm()

		#>

	# The hexadecimal form without the 0x prefix.
	def ToHexFormWithoutPrefix()
		_cResult_ = This.IntegerPartToHexForm()

		if This.HasFractionalPart()
			_cResult_ += "." + This.FractionalPartToHexForm()
		ok

		return _cResult_

		#< @FunctionAlternativeForms

		def ToHexWithoutPrefix()
			return This.ToHexFormWithoutPrefix()

		#>
			
	# The integer part in hexadecimal form.
	def IntegerPartToHexForm()
		return StzUpper(StzEngineNumberToBase(This.IntegerPartValue(), 16))

	# The fractional part in hexadecimal form.
	def FractionalPartToHexForm()
		_cFraction_ = This.FractionalPart()

		def DecimalPartToHexForm()
			return This.FractionalPartToHexForm()
  
	# Converting decimal to binary form

	def ToBinaryForm()
		_oConversion_ = new stzDecimalToBinary(This.Content())
		return _oConversion_.ToBinaryForm()

		#@ aka  binary, base 2, bits, binary representation
		def ToBinary()
			return This.ToBinaryForm()

		def ToBinaryQ()
			return new stzBinaryNumber( This.ToBinaryForm() )

		# The number wrapped as a stzBinaryNumber object.
		def ToBinaryNumber()
			return new stzBinaryNumber( This.ToBinaryForm() )

	# Variant that strips the "0b" prefix from the binary form, for
	# callers that just want the raw bit-string.
	def ToBinaryFormWithoutPrefix()
		_cBin_ = This.ToBinaryForm()
		if isString(_cBin_) and len(_cBin_) >= 2 and StzMid(_cBin_, 1, 2) = "0b"
			return StzMidToEnd(_cBin_, 3)
		ok
		return _cBin_

		def ToBinaryWithoutPrefix()
			return This.ToBinaryFormWithoutPrefix()

		def ToBinaryFormNoPrefix()
			return This.ToBinaryFormWithoutPrefix()

		def ToBinaryNoPrefix()
			return This.ToBinaryFormWithoutPrefix()
	
	# Converting decimal to octal form

	def IntegerPartToOctalForm()
		# Use fabs -- bare abs() resolves case-insensitively to this
		# class's own Abs() method (0 params) and raises R20 on the
		# argument. Same family as the Insert/Swap/Add shadows.
		return This.Sign() + StzEngineNumberToBase(fabs(This.IntegerPartValue()), 8)

	# The number in octal form (with prefix).
	def ToOctalForm()
		return OctalNumberPrefix() + This.ToOctalFormWithoutPrefix()

		def ToOctal()
			return This.ToOctalForm()

		def ToOctalQ()
			return new stzOctalNumber( This.ToOctalForm() ) 

		# The number wrapped as a stzOctalNumber object.
		def ToOctalNumber()
			return new stzOctalNumber( This.ToOctalForm() )
	
	# The octal form without the prefix.
	def ToOctalFormWithoutPrefix()
		_cResult_ = This.IntegerPartToOctalForm()

		if This.FractionalPart() != ""
			_cResult_ += "." + This.FractionalPartToOctalForm()
		ok

		return _cResult_

	// Returns a string containing the equivalent of the interger part
	// in the specified base n (between 2 and 36)
	# The integer part written in base n (2..36).
	def IntegerPartToBaseNForm(n)
		if n >= 2 and n <= 36
			_nVal_ = This.IntegerValue()
			if _nVal_ = 0
				return "0"
			ok
			_cPrefix_ = ""
			if _nVal_ < 0
				_cPrefix_ = "-"
				_nVal_ = -_nVal_
			ok
			return _cPrefix_ + StzEngineNumberToBase(_nVal_, n)
		else
			StzRaise(stzNumberError(:CanNotConvertNumberToSpecifiedBase))
		ok

	# Converting decimal number to bytes

	def ToBytes()
		return double2bytes( This.Content() )
		# Because Ring uses double C type to represent numbers internally

	def FromBinaryForm(cBinary)
		This.Update( StzBinaryNumberQ(cBinary).ToDecimalForm() )

		def FromBinary(cBinary)
			This.FromBinaryForm(cBinary)

	# Set the number from the given octal form (mutating).
	def FromOctalForm(cOctal)
		This.Update( StzOctalNumberQ(cOctal).ToDecimalForm() )

		def FromOctal(cOctal)
			This.FromOctalForm(cOctal)

	# Set the number from the given hex form (mutating).
	def FromHexForm(cHex)
		This.Update( StzHexNumberQ(cHex).ToDecimalForm() )

		def FromHex(cHex)
			This.FromHexForm(cHex)

	  #-----------------------------------------------------------#
	 #    UNITS, HUNDREDS, THOUSANDS, MILLIONS, AND BILLIONS     #
	#-----------------------------------------------------------#
	/*
	TODO: Refactor StructureXT() and Structure() to avoid duplicated code.
	*/

	def StructureXT()
	/*
		Given a number, the method returns its structure in a hashlist
		taking the following form:
			 
			_aStructure_ = [ :aHundreds , :aThousands , :aMillions , :aBillions , :aTrillions ]
			where each inner list takes the form :
				       [ :Units, :Dozens, :Hundreds ]
			
		The following visual representation better illustrates the point:
			 
			+/-    999   999   999    999    999  . 999 999 999 999 9
			 |      |     |     |      |      |     |_______ _______|
	       		 |      V     V     V      V      V             V
			 |    Trill. Bill. Mill. Thous. Hund.           |
			 |    |______________ ______________|           |
		 	 |                   V                          |
			 |                   |                          |
		  	 |                   |                          |
		 	 V                   V                          V
			Sign             IntegerPart              FractionalPart
			                                     (called also DecimalPart)
		And for each block of 3 digits we have:

			9 9 9
			| | |__ Units
			| |____ Dozens
			|______ Hundreds

		*/

		_oStzIntegerPart_ = new stzString(This.IntegerPart())
		_oStzFractionalPart_ = new stzString(This.FractionalPart())

		// Initializing the structure containers and the required variables
		_aHundreds_  = [ :Units = 0, :Dozens = 0, :Hundreds = 0 ]	_cHundreds_ = ""
		_aThousands_ = [ :Units = 0, :Dozens = 0, :Hundreds = 0 ]	_cThousands_ = ""
		_aMillions_  = [ :Units = 0, :Dozens = 0, :Hundreds = 0 ]	_cMillions_ = ""
		_aBillions_  = [ :Units = 0, :Dozens = 0, :Hundreds = 0 ] _cBillions_ = ""
		_aTrillions_ = [ :Units = 0, :Dozens = 0, :Hundreds = 0 ] _cTrillions_ = ""
			
		_aStructure_ = [ :aHundreds = [], :aThousands = [], :aMillions = [], :aBillions = [], :aTrillions = [] ]

		_aTemp_ = _oStzIntegerPart_.SplitToNPartsQ(3).Reversed()

		switch len(_aTemp_)
		on 0
			// Nothing

		on 1
			_cHundreds_  = _aTemp_[1]

		on 2
			_cHundreds_  = _aTemp_[1]
			_cThousands_ = _aTemp_[2]

		on 3
			_cHundreds_  = _aTemp_[1]
			_cThousands_ = _aTemp_[2]
			_cMillions_  = _aTemp_[3]

		on 4
			_cHundreds_  = _aTemp_[1]
			_cThousands_ = _aTemp_[2]
			_cMillions_  = _aTemp_[3]
			_cBillions_  = _aTemp_[4]

		on 5
			_cHundreds_  = _aTemp_[1]
			_cThousands_ = _aTemp_[2]
			_cMillions_  = _aTemp_[3]
			_cBillions_  = _aTemp_[4]
			_cTrillions_ = _aTemp_[5]

		off

		_aStructure_ = [ 	
			:aTrillions = GetMicroStructure(_cTrillions_),
			:aBillions  = GetMicroStructure(_cBillions_),
			:aMillions  = GetMicroStructure(_cMillions_),
			:aThousands = GetMicroStructure(_cThousands_),
			:aHundreds  = GetMicroStructure(_cHundreds_)
		]

		return _aStructure_

	def Structure()
		# Given a number, the function returns its structure in a hashlist
		# taking the following form:
		# 
		# 	aStructure = [ :cHundreds , :cThousands , :cMillions , :cBillions , :cTrillions ]
		# 	where each key contains a string with the relevant number hosted in it.
		#NOTE that the sign is not included in the analysis, but we have it in This.Sign()

		_oStzIntegerPart_ = new stzString(This.IntegerPartWithoutSign())
		_oStzFractionalPart_ = new stzString(This.FractionalPart())

		// Initializing the structure containers and the required variables
		_aHundreds_  = [ :Units = 0, :Dozens = 0, :Hundreds = 0 ]	_cHundreds_ = ""
		_aThousands_ = [ :Units = 0, :Dozens = 0, :Hundreds = 0 ]	_cThousands_ = ""
		_aMillions_  = [ :Units = 0, :Dozens = 0, :Hundreds = 0 ]	_cMillions_ = ""
		_aBillions_  = [ :Units = 0, :Dozens = 0, :Hundreds = 0 ] _cBillions_ = ""
		_aTrillions_ = [ :Units = 0, :Dozens = 0, :Hundreds = 0 ] _cTrillions_ = ""
			
		_aStructure_ = [ :aHundreds = [], :aThousands = [], :aMillions = [], :aBillions = [], :aTrillions = [] ]

		_aTemp_ = _oStzIntegerPart_.SplitToNPartsQ(3).Reversed()

		switch len(_aTemp_)
		on 0
			// Nothing

		on 1
			_cHundreds_  = _aTemp_[1]

		on 2
			_cHundreds_  = _aTemp_[1]
			_cThousands_ = _aTemp_[2]

		on 3
			_cHundreds_  = _aTemp_[1]
			_cThousands_ = _aTemp_[2]
			_cMillions_  = _aTemp_[3]

		on 4
			_cHundreds_  = _aTemp_[1]
			_cThousands_ = _aTemp_[2]
			_cMillions_  = _aTemp_[3]
			_cBillions_  = _aTemp_[4]

		on 5
			_cHundreds_  = _aTemp_[1]
			_cThousands_ = _aTemp_[2]
			_cMillions_  = _aTemp_[3]
			_cBillions_  = _aTemp_[4]
			_cTrillions_ = _aTemp_[5]
		off
					
		_cNumber_ = _cTrillions_ + _cBillions_ + _cMillions_ + _cThousands_ + _cHundreds_

		// Removing zeros from the left	
		_oNumber_ = new stzNumber(_cNumber_)
		_cNumber_ = _oNumber_.RemoveZeros()

		_aStructure_ = [ 	
			:cTrillions = _cTrillions_,
			:cBillions  = _cBillions_,
			:cMillions  = _cMillions_,
			:cThousands = _cThousands_,
			:cHundreds  = _cHundreds_
		]

		return _aStructure_

	#-- HUNDREDS --#
	# The hundreds part of the number's structure.
	def Hundreds()
		return This.Structure()[ :cHundreds ]		

	# The hundreds part of the structure, in detailed (XT) form.
	def HundredsXT()
		return This.StructureXT()[ :aHundreds ]

	# The units digit inside the number's hundreds.
	def UnitsInHundreds()
		return This.HundredsXT()[ :Units ]

		def Units()
			return This.UnitsInHundreds()

	# The dozens digit inside the number's hundreds.
	def DozensInHundreds()
		return This.HundredsXT()[ :Dozens ]

		def Dozens()
			return This.DozensInHundreds()

	# The hundreds digit inside the number's hundreds.
	def HundredsInHundreds()
		return This.HundredsXT()[ :Hundreds ]

	# TRUE if the number reaches the hundreds.
	def HasHundreds()
		_oNumber_ = new stzNumber(This.Content())
			
		if len(_oNumber_.IntegerPart()) > 0 and
		   _oNumber_.NumericValue() != 0

				return 1
		else
				return 0
		ok

		def ContainsHundreds()
			return This.HasHundreds()

	#-- TOUHSANDS --#
	# The thousands part of the number's structure.
	def Thousands()
		return This.Structure()[ :cThousands ]

	# The thousands part of the structure, in detailed (XT) form.
	def ThousandsXT()
		return This.StructureXT()[ :aThousands ]

	# The units digit inside the number's thousands.
	def UnitsInThousands()
		return This.ThousandsXT()[ :Units ]

	# The dozens digit inside the number's thousands.
	def DozensInThousands()
		return This.ThousandsXT()[ :Dozens ]

	# The hundreds digit inside the number's thousands.
	def HundredsInThousands()
		return This.ThousandsXT()[ :Hundreds ]

	# TRUE if the number reaches the thousands.
	def HasThousands()
		_oNumber_ = new stzNumber(This.Content())
			
		if len(_oNumber_.IntegerPart()) > 3
			return 1

		else
			return 0
		ok

		def ContainsThousands()
			return This.HasThousands()

	#-- MILLIONS --#
	# The millions part of the number's structure.
	def Millions()
		return This.Structure()[ :cMillions ]

	# The millions part of the structure, in detailed (XT) form.
	def MillionsXT()
		return This.StructureXT()[ :aMillions ]

	# The units digit inside the number's millions.
	def UnitsInMillions()
		return This.MillionsXT()[ :Units ]

	# The dozens digit inside the number's millions.
	def DozensInMillions()
		return This.MillionsXT()[ :Dozens ]

	# The hundreds digit inside the number's millions.
	def HundredsInMillions()
		return This.MillionsXT()[ :Hundreds ]

	# TRUE if the number reaches the millions.
	def HasMillions()
		_oNumber_ = new stzNumber(This.Content())
			
		if len(_oNumber_.IntegerPart()) > 6
			return 1

		else
			return 0
		ok

		def ContainsMillions()
			return This.HasMillions()

	#-- BILLIONS --#
	# The billions part of the number's structure.
	def Billions()
		return This.Structure()[ :cBillions ]

	# The billions part of the structure, in detailed (XT) form.
	def BillionsXT()
		return This.StructureXT()[ :aBillions ]
			
	# The units digit inside the number's billions.
	def UnitsInBillions()
		return This.BillionsXT()[ :Units ]

	# The dozens digit inside the number's billions.
	def DozensInBillions()
		return This.BillionsXT()[ :Dozens ]

	# The hundreds digit inside the number's billions.
	def HundredsInBillions()
		return This.BillionsXT()[ :Hundreds ]

	# TRUE if the number reaches the billions.
	def HasBillions()
		_oNumber_ = new stzNumber(This.Content())
			
		if len(_oNumber_.IntegerPart()) > 9
			return 1
		else
			return 0
		ok

		def ContainsBillions()
			return This.HasBillions()

	#-- TRILLIONS --#
	# The trillions part of the number's structure.
	def Trillions()
		return This.Structure()[ :cTrillions ]

	# The trillions part of the structure, in detailed (XT) form.
	def TrillionsXT()
		return This.StructureXT()[ :aTrillions ]

	# The units digit inside the number's trillions.
	def UnitsInTrillions()
		return This.TrillionsXT()[ :Units ]

	# The dozens digit inside the number's trillions.
	def DozensInTrillions()
		return This.TrillionsXT()[ :Dozens ]

	# The hundreds digit inside the number's trillions.
	def HundredsInTrillions()
		return This.TrillionsXT()[ :Hundreds ]

	# TRUE if the number reaches the trillions.
	def HasTrillions()
		_oNumber_ = new stzNumber(This.Content())
			
		if len(_oNumber_.IntegerPart()) > 12
			return 1

		else
			return 0
		ok

		def ContainsTrillions()
			return This.HasTrillions()

	#-- ALL IN ONCE --#
	# The units digit at every scale level, as a hash.
	def AllUnits()
		return 	[ :InHundreds  = This.UnitsInHundreds(),
			  :InThousands = This.UnitsInThousands(),
			  :InMillions  = This.UnitsInMillions(),
			  :InBillions  = This.UnitsInBillions(),
			  :InTrillions = This.UnitsInTrillions()
			]

	# The dozens digit at every scale level, as a hash.
	def AllDozens()
		return 	[ :InHundreds  = This.DozensInHundreds(),
			  :InThousands = This.DozensInThousands(),
			  :InMillions  = This.DozensInMillions(),
			  :InBillions  = This.DozensInBillions(),
			  :InTrillions = This.DozensInTrillions()
			]

	# The hundreds digit at every scale level, as a hash.
	def AllHundreds()
		return 	[ :InHundreds  = This.HundredsInHundreds(),
			  :InThousands = This.HundredsInThousands(),
			  :InMillions  = This.HundredsInMillions(),
			  :InBillions  = This.HundredsInBillions(),
			  :InTrillions = This.HundredsInTrillions()
			]

	  #-----------------------#
	 #    CONTAINABILITY     #
	#-----------------------#

	# Always TRUE: a number is made of digits.
	def ContainsDigits()
		return 1

	# TRUE if the number contains the given digit.
	def Contains(pcDigit)
		return StzFindFirst(pcDigit, This.Content()) > 0

	# TRUE if the number occurs in the given list.
	def ExistsIn(paList)
		return ListContains(paList, This.NumericValue())

		# Same as ExistsIn: TRUE if the number occurs in the given list.
		def Inn(paList)
			return ExistsIn(paList)

	# TRUE if the number contains the digit 0.
	def ContainsZeros()
		return This.Contains("0")

		def HasZeros()
			return This.ContainsZeros()

	# TRUE if the number contains the digit 1.
	def ContainsOnes()
		return This.Contains("1")

		def HasOnes()
			return This.ContainsOnes()

	# TRUE if the given digit occurs more than once.
	def ContainsSeveral(pcDigit)
		return StringNumberOfOccurrence(This.Content(), pcDigit) > 1

		def ContainsMany(pcDigit)
			return This.ContainsSeveral(pcDigit)

		def HasSeveral(pcDigit)
			return This.ContainsSeveral(pcDigit)

		def HasMany(pcDigit)
			return This.ContainsSeveral(pcDigit)

	# TRUE if the digit 0 occurs more than once.
	def ContainsSeveralZeros()
		return This.ContainsSeveral("0")

		def ContainsManyZeros()
			return This.ContainsSeveralZeros()

		def HasSeveralZeros()
			return This.ContainsSeveralZeros()

		def HasManyZeros()
			return This.ContainsSeveralZeros()

	# TRUE if the digit 1 occurs more than once.
	def ContainsSeveralOnes()
		return This.ContainsSeveral("1")

		def ContainsManyOnes()
			return This.ContainsSeveralOnes()

		def HasSeveralOnes()
			return This.ContainsSeveralOnes()

		def HasManyOnes()
			return This.ContainsSeveralOnes()

	# TRUE if the number is at least 10.
	def ContainsDozens()
		return This.NumericValue() >= 10

		def ContainsSeveralDozens()
			return This.ContainsDozens()

		def ContainsManyDozens()
			return This.ContainsDozens()

	# TRUE if the number is at least 200 (several hundreds).
	def ContainsSeveralHundreds()
		return This.NumericValue() >= 200

		def ContainsManyHundreds()
			return This.ContainsSeveralHundreds()

		def HasSeveralHundreds()
			return This.ContainsSeveralHundreds()

		def HasManyHundreds()
			return This.ContainsSeveralHundreds()

	# TRUE if the number is at least 2000 (several thousands).
	def ContainsSeveralThousands()
		return This.NumericValue() >= 2000

		def ContainsManyThousands()
			return This.ContainsSeveralThousands()

		def HasSeveralThousands()
			return This.ContainsSeveralThousands()

		def HasManyThousands()
			return This.ContainsSeveralThousands()

	# TRUE if the number is at least 10 000.
	def ContainsTensOfThousands()
		return This.NumericValue() >= 10_000

		def ContainsSeveralTensOfThousands()
			return This.ContainsTensOfThousands()

		def ContainsManyTensOfThousands()
			return This.ContainsTensOfThousands()

		def HasTensOfThousands()
			return This.ContainsTensOfThousands()

		def HasSeveralTensOfThousands()
			return This.ContainsSeveralTensOfThousands()

		def HasManyTensOfThousands()
			return This.ContainsSeveralTensOfThousands()

	# TRUE if the number is at least 100 000.
	def ContainsHundredsOfThousands()
		return This.NumericValue() >= 100_000

		def ContainsSeveralHundredsOfThousands()
			return This.ContainsHundredsOfThousands()

		def ContainsManyHundredsOfThousands()
			return This.ContainsHundredsOfThousands()

		def HasHundredsOfThousands()
			return This.ContainsHundredsOfThousands()

		def HasSeveralHundredsOfThousands()
			return This.ContainsHundredsOfThousands()

		def HasManyHundredsOfThousands()
			return This.ContainsHundredsOfThousands()

	# TRUE if the number is at least 2 000 000.
	def ContainsSeveralMillions()
		return This.NumericValue() >= 2_000_000

		def ContainsManyMillions()
			return This.ContainsSeveralMillions()

		def ContainsThousandsOfThousands()
			return This.ContainsMillions()

		def ContainsSeveralThousandsOfThousands()
			return This.ContainsSeveralMillions()

		def ContainsManyThousandsOfThousands()
			return This.ContainsSeveralMillions()

		#--

		def HasSeveralMilllions()
			return This.ContainsSeveralMillions()

		def HsManyMillions()
			return This.ContainsSeveralMillions()

		def HasThousandsOfThousands()
			return This.ContainsMillions()

		def HasSeveralThousandsOfThousands()
			return This.ContainsSeveralMillions()

		def HasManyThousandsOfThousands()
			return This.ContainsSeveralMillions()

	# TRUE if the number is at least 10 000 000.
	def ContainsTensOfMillions()
		return This.NumericValue() >= 10_000_000

		def ContainsSeveralTensOfMillions()
			return This.ContainsTensOfMillions()

		def ContainsManyTensOfMillions()
			return This.ContainsTensOfMillions()

		#--

		def HasTensOfMillions()
			return This.ContainsTensOfMillions()

		def HasSeveralTensOfMillions()
			return This.ContainsTensOfMillions()

		def HasMayTensOfMillions()
			return This.ContainsTensOfMillions()

	# TRUE if the number is at least 100 000 000.
	def ContainsHundredsOfMillions()
		return This.NumericValue() >= 100_000_000

		def ContainsSeveralHundredsOfMillions()
			return This.ContainsHundredsOfMillions()

		def ContainsManyHundredsOfMillions()
			return This.ContainsHundredsOfMillions()

		#--

		def HasHundredsOfMillions()
			return This.ContainsHundredsOfMillions()

		def HasSeveralHundredsOfMillions()
			return This.ContainsHundredsOfMillions()

		def HasManyHundredsOfMillions()
			return This.ContainsHundredsOfMillions()

	# TRUE if the number is at least 2 000 000 000.
	def ContainsSeveralBillions()
			return This.NumericValue() >= 2_000_000_000

		# TRUE if the number is at least 2 billion.
		def ContainsManyBillions()
			return This.ontainsSeveralBillions()

		# TRUE if the number reaches the billions (thousands of
		# millions).
		def ContainsThousandsOfMillions()
			return This.ontainsSeveralBillions()

		# TRUE if the number is at least 2 billion.
		def ContainsSeveralThousandsOfMillions()
			return This.ontainsSeveralBillions()

		# TRUE if the number is at least 2 billion.
		def ContainsManyThousandsOfMillions()
			return This.ontainsSeveralBillions()	

		#--

		def HasSeveralBillions()
			return This.ContainsSeveralBillions()

		# TRUE if the number is at least 2 billion.
		def HasManyBillions()
			return This.ontainsSeveralBillions()

		def HasThousandsOfMillions()
			return This.ContainsBillions()

		# TRUE if the number is at least 2 billion.
		def HasSeveralThousandsOfMillions()
			return This.ontainsSeveralBillions()

		# TRUE if the number is at least 2 billion.
		def HasManyThousandsOfMillions()
			return This.ontainsSeveralBillions()

	# TRUE if the number is at least 10 billion.
	def ContainsTensOfBillions()
		return This.NumericValue() >= 10_000_000_000

		def ContainsSeveralTensOfBillions()
			return This.ContainsTensOfBillions()

		def ContainsManyTensOfBillions()
			return This.ContainsTensOfBillions()

		#--

		def HasTensOfBillions()
			return This.ContainsTensOfBillions()

		# TRUE if the number is at least 20 billion.
		def HasSeveralTensOfBillions()
			return This.HasManyTensOfBillions()

		# TRUE if the number is at least 20 billion.
		def HasManyTensOfBillions()
			return This.HasManyTensOfBillions()

	# TRUE if the number is at least 100 billion.
	def ContainsHundredsOfBillions()
		return This.NumericValue() >= 100_000_000_000

		def ContainsSeveralHundredsOfBillions()
			return This.ContainsHundredsOfBillions()

		def ContainsManyHundredsOfBillions()
			return This.ContainsHundredsOfBillions()

		#--

		def HasHundredsOfBillions()
			return This.ContainsHundredsOfBillions()

		def HasSeveralHundredsOfBillions()
			return This.ContainsHundredsOfBillions()

		def HasManyHundredsOfBillions()
			return This.ContainsHundredsOfBillions()

	# TRUE if the number is at least 2 trillion.
	def ContainsSeveralTrillions()
		return This.NumericValue() >= 2_000_000_000_000

		def ContainsManyTrillions()
			return This.ContainsSeveralTrillions()

		#--

		def HasSeveralTrillions()
			return This.ContainsSeveralTrillions()

		def HasManyTrillions()
			return This.ContainsSeveralTrillions()


	# TRUE if the number is at least 10 trillion.
	def ContainsTensOfTrillions()
		return This.NumericValue() >= 10_000_000_000_000

		def ContainsSeveralTensOfTrillions()
			return This.ContainsTensOfTrillions()

		def ContainsManyTensOfTrillions()
			return This.ContainsTensOfTrillions()

		#--

		def HasTensOfTrillions()
			return This.ContainsTensOfTrillions()

		def HasSeveralTensOfTrillions()
			return This.ContainsTensOfTrillions()

		def HasManyTensOfTrillions()
			return This.ContainsTensOfTrillions()

	# TRUE if the number is at least 100 trillion.
	def ContainsHundredsOfTrillions()
		return This.NumericValue() >= 100_000_000_000_000

		def ContainsSeveralHundredsOfTrillions()
			return This.HasHundredsOfTrillions()

		def ContainsManyHundredsOfTrillions()
			return This.HasHundredsOfTrillions()

		#--

		def HasHundredsOfTrillions()
			return This.ContainsHundredsOfTrillions()

		def HasSeveralHundredsOfTrillions()
			return This.HasHundredsOfTrillions()

		def HasManyHundredsOfTrillions()
			return This.HasHundredsOfTrillions()

	  #----------------------------------#
	 #    REMOVING SPACES FROM NUMBER   #
	#----------------------------------#

	def RemoveSpaces()
		This.Update( This.ToStzString().SpacesRemoved() )

	def RemoveSpacesQ()
		This.RemoveSpaces()
		return This

	def SpacesRemoved()
		_cResult_ = This.Copy().RemoveSpacesQ().Content()
		return _cResult_

	def RemoveLeadingSpaces()
		This.Update( This.ToStzString().LeadingSpacesRemoved() )

		def RemoveLeadingSpacesQ()
			This.RemoveLeadingSpaces()
			return This

	def LeadingSpacesRemoved()
		_cResult_ = This.Copy().RemoveLeadingSpacesQ().Content()
		return _cResult_

	def RemoveTrailingSpaces()
		This.Update( This.ToStzString().TrailingSpacesRemoved() )

		def RemoveTrailingSpacesQ()
			This.RemoveTrailingSpaces()
			return This

	def TrailingSpacesRemoved()
		_cResult_ = This.Copy().RemoveTrailingSpacesQ().Content()
		return _cResult_

	  #---------------------------------#
	 #    REMOVING ZEROS FROM NUMBER   #
	#---------------------------------#

	def RemoveZerosFromLeft()
		_oStzStr_ = This.ToStzString()

		if _oStzStr_.RepeatedLeadingcharIs("0")
			This.Update( _oStzStr_.RemoveThisRepeatedLeadingCharQ("0").Content() )
		ok

		if This.IsReal()
			if _oStzStr_.RepeatedTrailingCharIs("0")
				This.Update( _oStzStr_.RemoveRepeatedTrailingCharQ("0").Content() )
			ok
		ok

	def RemoveZerosFromRight()
		_oStzStr_ = This.ToStzString()

		if _oStzStr_.RepeatedTrailingcharIs("0") and This.IsReal()
			This.Update( _oStzStr_.RemoveThisRepeatedtrailingCharQ("0").Content() )
		ok

	def RemoveZeros()
		_oStzStr_ = This.ToStzString()

		if _oStzStr_.RepeatedTrailingcharIs("0")
			This.Update( _oStzStr_.RemoveThisRepeatedtrailingCharQ("0").Content() )
		ok

		if This.IsReal()
			if _oStzStr_.RepeatedTrailingCharIs("0")
				This.Update( _oStzStr_.RemoveRepeatedTrailingCharQ("0").Content() )
			ok
		ok
		

	def ZerosRemoved()
		_cResult_ = This.Copy().RemoveZerosQ().Content()
		return _cResult_

	  #------------------#
	 #    FORMATTING    #
	#------------------#

	# Apply the default number format (mutating).
	def ApplyFormat()
		return This.ApplyFormatXT([])

		# Format the number with the default options (mutating).
		def Format()
			return This.ApplyFormatXT([])

	# Format the number with the given options (mutating).
	def FormatXT(paFormat)
		return This.ApplyFormatXT(paFormat)

	# Apply the given format options to the number (mutating).
	def ApplyFormatXT(paFormat)
	#TODO// Add formatting strings like +99 999.99%
	#TODO// Support Compact form (K, B, M) see methods below
	#TODO// Review the overall accuracy of the formatting logic

		# Setting default configs

			# Precision
			_bRestrictFractionalPart_ = 0
			_nNumberOfDigitsInFractionalPart_ = 0
			_bRoundItWhenRestricted_ = 0
			
			# Round
			_bRounded_ = 0
			_nRoundTo_ = 0
			
			# Alignment
			_bApplyAlignment_ = 0

			_nWidth_ = 0
			_cFillBlanksWith_ = " "
			
			_cAlignTo_ = :Left
			_bFixPrefixToLeft_ = 0
			_bFixSuffixToRight_ = 0
				
			# Sign
			_bShowSign_ = 1
			_bPutNegativeBetweenParentheses_ = 0
			
			# Prefix, separators, and suffix
			_cPrefix_ = ""
			
			_cThousandsSeparator_ = "."

			_cFractionalSeparator_ = ","
			
			_cSuffix_ = ""
			
			# Conversion
			_bToPercentage_ = 0
			_bToScientificNotation_ = 0
			
			_bToHex_ = 0
			_bToBinary_ = 0
			_bToOctal_ = 0
			_nToBase_ = 10
			
			_bToIndian_ = 0
			_bToRoman_ = 0

		# Reading provided configs

			# Precision

			if HasKey(paFormat, :RestrictFractionalPart)
				_bRestrictFractionalPart_ = paFormat[ :RestrictFractionalPart ]
			ok

			if HasKey(paFormat, :NumberOfDigitsInFractionalPart)
				_nNumberOfDigitsInFractionalPart_ = paFormat[ :NumberOfDigitsInFractionalPart ]
			ok

			if HasKey(paFormat, :RoundItWhenRestricted)
				_bRoundItWhenRestricted_ = paFormat[ :RoundItWhenRestricted ]
			ok
		
			# Round

			if HasKey(paFormat, :ApplyRound)
				_bRounded_ = paFormat[ :ApplyRound ]
			ok

			if HasKey(paFormat, :RoundTo)
				_nRoundTo_ = paFormat[ :RoundTo ]
			ok
			
			# Alignment
				
			if HasKey(paFormat, :ApplyAlignment)
				_bApplyAlignment_ = paFormat[ :ApplyAlignment ]
			ok

			if HasKey(paFormat, :Width)
				_nWidth_ = paFormat[ :Width ]
			ok

			if HasKey(paFormat, :FillBlanksWith)
				_cFillBlanksWith_ = paFormat[ :FillBlanksWith ]
			ok

			if HasKey(paFormat, :AlignTo)		
				_cAlignTo_ = paFormat[ :AlignTo ]
			ok

			if HasKey(paFormat, :FixPrefixToLeft)
				_bFixPrefixToLeft_ = paFormat[ :FixPrefixToLeft ]
			ok

			if HasKey(paFormat, :FixSuffixToRight)
				_bFixSuffixToRight_ = paFormat[ :FixSuffixToRight ]
			ok
				
			# Sign

			if HasKey(paFormat, :ShowSign)
				_bShowSign_ = paFormat[ :ShowSign ]
			ok

			if HasKey(paFormat, :PutNegativeBetweenParentheses)
				_bPutNegativeBetweenParentheses_ = paFormat[ :PutNegativeBetweenParentheses ]
			ok
			
			# Prefix, separators, and suffix

			if HasKey(paFormat, :Prefix)
				_cPrefix_ = paFormat[ :Prefix ]
			ok
			
			if HasKey(paFormat, :ThousandsSeparator)
				_cThousandsSeparator_ = paFormat[ :ThousandsSeparator ]
			ok

			if HasKey(paFormat, :FractionalSeparator)
				_cFractionalSeparator_ = paFormat[ :FractionalSeparator ]
			ok
			
			if HasKey(paFormat, :Suffix)
				_cSuffix_ = paFormat[ :Suffix ]
			ok
			
			# Conversion

			if HasKey(paFormat, :ToPercentage)
				_bToPercentage_ = paFormat[ :ToPercentage ]
			ok

			if HasKey(paFormat, :ToScientificNotation)
				_bToScientificNotation_ = paFormat[ :ToScientificNotation ]
			ok

			if HasKey(paFormat, :ToHex)
				_bToHex_ = paFormat[ :ToHex ]
			ok

			if HasKey(paFormat, :ToBinary)
				_bToBinary_ = paFormat[ :ToBinary ]
			ok

			if HasKey(paFormat, :ToOctal)
				_bToOctal_ = paFormat[ :ToOctal ]
			ok

			if HasKey(paFormat, :ToBase)
				_nToBase_ = paFormat[ :ToBase ]
			ok
			
			if HasKey(paFormat, :ToIndian)
				_bToIndian_ = paFormat[ :ToIndian ]
			ok

			if HasKey(paFormat, :ToRoman)
				_bToRoman_ = paFormat[ :ToRoman ]
			ok

		# Computing the required formatting
	
		_cFormattedNumber_ = ""
		_cIntegerPart_ = This.IntegerPartWithoutSign()
		_cFractionalPart_ = ""

		# Managing precision by computing the fractional part

		if _bRestrictFractionalPart_ = 0
			_cFractionalPart_ = This.FractionalPartWithoutZerodot()
		else
			_cCurrentFractionalPart_ = This.FractionalPartWithoutZerodot()
				
			_cFractionalPart_ = ""
			for _i_ = 1 to _nNumberOfDigitsInFractionalPart_
				_cFractionalPart_ += _cCurrentFractionalPart_[_i_]
			next

			if _bRoundItWhenRestricted_ = 1

				# Memorise the active round
				_nCurrentRound_ = GetActiveRound()

				# Setting the rounding system to the number of restricted digits
				decimals(_nNumberOfDigitsInFractionalPart_)

				# Composing a dummy number with the restricted fraction part
				_cTempNumber_ = "0." + _cFractionalPart_

				# Rounding that number
				_nTempNumber_ = 0+ _cTempNumber_
				# Saving the rounded number in a string
				_cTempNumber_ = ""+ _nTempNumber_

				# Reading the rounded fraction part
				_cFractionalPart_ = ""
				_nTempNumberLen_ = len(_cTempNumber_)
				for _i_ = StzFindFirst(".", _cTempNumber_) + 1 to _nTempNumberLen_
					_cFractionalPart_ += _cTempNumber_[_i_]
				next
			ok
		ok

		# Managing Sign
			
		if _bShowSign_ and This.Sign() = ""
			_cFormattedNumber_ += "+"
		ok

		if This.Sign() = "-"
				
			if NOT _bPutNegativeBetweenParentheses_
				_cFormattedNumber_ += "-"
			else
				_cFormattedNumber_ += "("
			ok	
		ok

		# Managing prefix

		if _cPrefix_ != ""
			_cFormattedNumber_ += _cPrefix_
		ok

		# Managing separators

		if This.Trillions() != ""
			_cFormattedNumber_ += This.Trillions() + _cThousandsSeparator_
		ok

		if This.Billions() != ""
			_cFormattedNumber_ += This.Billions() + _cThousandsSeparator_
		ok

		if This.Millions() != ""
			_cFormattedNumber_ += This.Millions() + _cThousandsSeparator_
		ok

		if This.Thousands() != ""
			_cFormattedNumber_ += This.Thousands() + _cThousandsSeparator_
		ok

		if This.Hundreds() != ""
			_cFormattedNumber_ += This.Hundreds()
		ok

		# Defining fractional part

		_cCurrentFractionalPart_ = This.FractionalPartWithoutZeroDot()
		_nCurrentNumberOfDigitsInFractionalPart_ = len(_cCurrentFractionalPart_)

		_cNewFractionalPart_ = ""

		if _nNumberOfDigitsInFractionalPart_ <= _nCurrentNumberOfDigitsInFractionalPart_
			for _i_ = 1 to _nNumberOfDigitsInFractionalPart_
				_cNewFractionalPart_ += _cCurrentFractionalPart_[_i_]
			next

		else
			_nDiff_ = _nNumberOfDigitsInFractionalPart_ - _nCurrentNumberOfDigitsInFractionalPart_

			for _i_ = 1 to _nDiff_
				_cNewFractionalPart_ += "0"
			next
		ok

		# Managing round

		_cFractionalPart_ = _cNewFractionalPart_

		if NOT _bRounded_ #TODO // review the round() mechanism! #DONE
			if _cFractionalPart_ != ""
				_cFormattedNumber_ += (cFractionalSep + _cFractionalPart_)
			ok
		else
			_oTempNumber_ = new stzNumber(This.RoundTo(_nRoundTo_))

			if _oTempNumber_.FractionalPartWithoutZerodot() != ""

				_cFormattedNumber_ += cFractionalSep

				if _nNumberOfDigitsInFractionalPart_ <= len(_oTempNumber_.FractionalPartWithoutZerodot())
					for _i_ = 1 to _nNumberOfDigitsInFractionalPart_
						_cFormattedNumber_ += _oTempNumber_.FractionalPartWithoutZerodot()[_i_]
					next

				else 
					_nDiff_ = _nNumberOfDigitsInFractionalPart_ - len(_oTempNumber_.FractionalPartWithoutZerodot())
		
					for _i_ = 1 to _nDiff_
						_cFormattedNumber_ += "0"
					next
				ok				
					
			ok
		ok

		# Managing suffix

		if _cSuffix_ != ""
			_cFormattedNumber_ += _cSuffix_
		ok

		# Adding the closing parenthese if required
		if _bPutNegativeBetweenParentheses_
			_cFormattedNumber_ += ")"
		ok

		return _cFormattedNumber_

		_oNumber_ = This
		if bPercent = 1
			_cNumber_ = _oNumber_.InPercentage()
			_oNumber_ = new stzNumber(_cNumber_)
		ok
	
		_cNumber_ = _cPrefix_
		if _bShowSign_
			_cSign_ = ""

			if This.IsPositive()
				_cSign_ = "+"

			but This.IsNegative()
					_cSign_ = "-"

			but This.IsZero()
					_cSign_ = ""
			ok

			_cNumber_ += _cSign_
		ok

		if _oNumber_.Trillions() != ""
			_cNumber_ += _oNumber_.Trillions() + cThousandsSep
		ok

		if _oNumber_.Billions() != ""
			_cNumber_ += _oNumber_.Billions() + cThousandsSep
		ok

		if _oNumber_.Millions() != ""
			_cNumber_ += _oNumber_.Millions() + cThousandsSep
		ok

		if _oNumber_.Thousands() != ""
			_cNumber_ += _oNumber_.Thousands() + cThousandsSep
		ok

		if _oNumber_.Hundreds() != ""
			_cNumber_ += _oNumber_.Hundreds()
		ok

		if _oNumber_.FractionalPart() != ""
			_cNumber_ += cFractionalSep + _oNumber_.FractionalPartWithoutZerodot()
		ok

		if bPercent = 1
			_cNumber_ += "%"
		ok

		return _cNumber_


	# The number in compact form (1.2K / 3.4M style).
	def CompactForm()
		_nNumber_ = This.Value()
	    if _nNumber_ >= 1000 and _nNumber_ < 1_000_000
			return '' + RoundN(_nNumber_/1000, 1) + "K"

		but _nNumber_ >= 1_000_000 and _nNumber_ < 1_000_000_000
			return '' + RoundN(_nNumber_/1_000_000, 1) + "M"

		but _nNumber_ > 1_000_000_000
			return '' + RoundN(_nNumber_/1000_000_000, 1) + "B"
		ok

		def ToCompactForm()
			return This.CompactForm()


	# The number in K (thousands) form.
	def KForm()
		_nNumber_ = This.Value()
	    if _nNumber_ >= 1000
	        return '' + RoundN(_nNumber_/1000, 1) + "K"
	    else
	        return This.Content()
	    ok

		def ToKForm()
			return This.KForm()


	# The number in M (millions) form.
	def MForm()
		_nNumber_ = This.Value()
	    if _nNumber_ >= 1_000_000
	        return '' + RoundN(_nNumber_/1_000_000, 1) + "M"
	    else
	        return This.Content()
	    ok

		def ToMForm()
			return This.MForm()

	# The number in B (billions) form.
	def BForm()
		_nNumber_ = This.Value()
	    if _nNumber_ >= 1000_000_000
	        return '' + RoundN(_nNumber_/1000_000_000, 1) + "B"
	    else
	        return This.Content()
	    ok

		def ToBForm()
			return This.BForm()


	# Default-format setting (unsupported in this version: raises).
	def SetDefaultFormat() // TODO
		StzRaise("Unsupported feature in this version!")

	# Locale application (unsupported in this version: raises).
	def ApplyLocale(pcLocale) // TODO
		StzRaise("Unsupported feature in this version!")

	  #------------------------------------------------------------------------#
	 #  Generating a compact form of the number using K letter for thousands  #
	#------------------------------------------------------------------------#



	  #-----------------------------#
	 #     OPERATORS OVERLOADING   #
	#-----------------------------#

	#TODO // Operators should carry same semantics in all classes...
	#TODO // Make a request to Mahmoud to enable multichar operators in Ring

	#WARNING // DON'T ADD = OPERATOR
	# Because it causes semantic conflict with
	# feature in stzExtCode (see CREATE_TABLE sql function)

	def operator (pOp, pValue)

		#WARNING // DON'T ADD = OPERATOR
		# Because it causes semantic conflict with
		# feature in stzExtCode (see CREATE_TABLE sql function)

		if  pOp = "+"
			if isString(pValue)
				return This.Added(pValue)

			but @IsStzString(pValue)
				This.Add(pValue.Content())
				return This

			but isNumber(pValue)
				return This.Added(""+pValue)

			but @IsStzNumber(pValue)
				This.Add(pValue.Content())
				return This

			but isList(pValue)
				return This.AddedMany(pValue)

			but @IsStzList(pValue)
				This.AddMany(pValue.Content())
				return This
		
			ok

		but pOp = "-"
			if isString(pValue)
				return This.SubStructed(pValue)

			but @IsStzString(pValue)
				This.SubStruct(pValue.Content())
				return This

			but isNumber(pValue)
				return This.SubStructed(""+pValue)

			but @IsStzNumber(pValue)
				This.SubStruct(pValue.Content())
				return This

			but isList(pValue)
				return This.SubStructedMany(pValue)

			but @IsStzList(pValue)
				This.SubStructMany(pValue.Content())
				return This
		
			ok

		but pOp = "*"
			if isString(pValue)
				return This.MultipliedBy(pValue)

			but @IsStzString(pValue)
				This.MultiplyBy(pValue.Content())
				return This

			but isNumber(pValue)
				return This.MultipliedBy(""+pValue)

			but @IsStzNumber(pValue)
				This.MultiplyBy(pValue.Content())
				return This

			but isList(pValue)
				return This.MultipliedByMany(pValue)

			but @IsStzList(pValue)
				This.MultiplyByMany(pValue.Content())
				return This
		
			ok

		but pOp = "/"
			if isString(pValue)
				return This.DividedBy(pValue)

			but @IsStzString(pValue)
				This.DivideBy(pValue.Content())
				return This

			but isNumber(pValue)
				return This.DividedBy(""+pValue)

			but @IsStzNumber(pValue)
				This.DivideBy(pValue.Content())
				return This

			but isList(pValue)
				return This.dividedByMany(pValue)

			but @IsStzList(pValue)
				_aResult_ = Q( This.DivideByMany(pValue.Content()) )
				return _aResult_
		
			ok

		but pOp = "^" or pOp = "^^"
			if @IsStzNumber(pValue) or
			   (@IsStzString(pValue) and Q(pValue).IsNumberInString())

				
				_cPower_ = This.Power()
				This.UpdateWith(_cPower_)

			else

				return This.Power(pValue)
			ok

		but pOp = "%"
			return This.Modulo(pValue)

		but pOp = ">"
			return This.IsStrictlyGreaterThan(pValue)

		but pOp = ">="
			return This.IsGreaterThanOrEqualTo(pValue)

		but pOp = "<"
			return This.IsStrictlyLessThan(pValue)

		but pOp = "<="
			return This.IsLessThanOrEqualTo(pValue)

		but pOp = "<>" or pOp = "!"
			return This.IsDifferentFrom(pValue)

		but pOp = "++" #TODO // check if it works! (++ is reserved by Ring)
			return This.NextNumber()

		but pOp = "--" #TODO // check if it works! (-- is reserved by Ring)
			return This.PreviousNumber()

		but pOp = "[]"
			# Supporting external Python syntax:
				# In Pyhton: 345 // 100 #--> 3
				# In Ring with Softanza:
				# ? Q(345)['// 100'] #--> 3

			if isString(pValue) and Q(pValue).StartsWith("//") 
				_oStr_ = new stzString(pValue)
				_nLen_ = _oStr_.NumberOfChars()
				_cRemainingPart_ = _oStr_.SectionQ(3, _nLen_).Trimmed()

				if Q(_cRemainingPart_).IsNumberInString()
					n = 0+ _cRemainingPart_
					_nResult_ = floor( This.NumbericValue() / n )
					#NOTE this a misspelled form of NumericValue()!

					return _nResult_
				ok

			ok

			return This.Content()[pValue]

		ok

	  #--------------------------------#
	 #    USUED FOR NATURAL-CODING    #
	#--------------------------------#

	# Always TRUE: the object IS a stzNumber.
	def IsStzNumber()
		return 1

	# The Softanza type symbol: :stzNumber.
	def stzType()
		return :stzNumber

	#--- ITEM
	
	# Always TRUE: a number can be a list item.
	def IsItem()
		return 1
	
	# TRUE if the number occurs in the given list.
	def IsItemOf(paList)
		return ListContains(paList, This.NumericValue())
		
		def AsAnItemOf(paList)
			return This.IsItemOf(paList)
		
	def IsItemIn(paList)
		return This.IsItemOf(paList)
		
		def IsAnItemIn(paList)
			return This.IsItemOf(paList)

	#--- MEMEBER

	# Always TRUE: a number can be a member.
	def IsMember()
		return 1
	
	# TRUE if the number (as held) occurs in the given list.
	def IsMemberOf(paList)
		return ListContains(paList, This.Content())
		
		def AsAMemberOf(paList)
			return This.IsMemberOf(paList)
		
	def IsMemberIn(paList)
		return This.IsMemberOf(paList)
		
			def IsAMemberIn(paList)
				return This.IsMemberOf(paList)
	
	#--- NUMBER
	
	# Always TRUE: the object holds a number.
	def IsANumber()
		return 1

		# Always FALSE: it IS a number.
		def IsNotANumber()
			return 0

	# Always FALSE: a number is not a string.
	def IsAString()
		return 0

		# Always TRUE: a number is not a string.
		def IsNotAString()
			return 1

	# Always FALSE: a number is not a list.
	def IsAList()
		return 0

		# Always TRUE: a number is not a list.
		def IsNotAList()
			return 1

	# Always TRUE: the wrapper is an object.
	def IsAnObject()
		return 1

		# Always TRUE: the wrapper is an object.
		def IsAObject()
			return 1

		# Always FALSE: the wrapper is an object.
		def IsNotAnObject()
			return 1

	# TRUE if the number occurs in the given list.
	def IsNumberOf(paList)
		return This.IsItemOf(paList)
	
		def IsANumberOf(paList)
			return This.IsNumberOf(paList)
		
	def IsNumberIn(paList)
		return This.IsNumberOf(paList)
	
		def IsANumberIn(paList)
			return This.IsNumberOf(paList)

	# TRUE if the number occurs in the given list.
	def IsOneOfThese(paList)
		return This.IsItemOf(paList)

		# TRUE if the number occurs in NONE of the given values.
		def IsNotOneOfThese(paList)
			return NOT This.IsOneOfThese(paList)
	
	#--- STRING
	
	# Always FALSE: a number is not a letter.
	def IsLetter()
		return 0
	
	# Always FALSE: a number is not a letter.
	def IsALetter()
		return 0
	
	# Always FALSE: a number is not a letter.
	def IsLetterOf(pStrOrListOfChars)
		return 0
	
		# Always FALSE: a number is not a letter.
		def IsALetterOf(pcStr)
			return 0
		
	# Always FALSE: a number is not a letter.
	def IsLetterIn(pcStr)
		return 0
	
		# Always FALSE: a number is not a letter.
		def IsALetterIn(pcStr)
			return 0
	
	# Always FALSE: a number is not a char.
	def IsCharOf(pStrOrListOfChars)
		return 0
	
		# Always FALSE: a number is not a char.
		def IsACharOf(pcStr)
			return 0
	
	# Always FALSE: a number is not a char.
	def IsCharIn(pcStr)
		return 0
	
		# Always FALSE: a number is not a char.
		def IsACharIn(pcStr)
			return 0
	
	  #------------------------------------------#
	 #   STRINGIFY(), TOSTRING(), AND TOCODE()  #
	#------------------------------------------#

	def Stringify()
		# Do nothing, the object is naturally stringified
		# becauses it contains its value always as a string

		def StringifyQ()
			return new stzString( This.StringValue() )

		def DeepStringifiy()
			// Nothing

			def DeepStringfyQ()
				return This.StringifyQ()

	def Stringified()
		return This.StringValue()

		def DeepStringified()
			return This.Stringified()

	def ToString()
		return This.StringValue()

		def ToStringQ()
			return new stzString( This.ToString() )
	
	def ToCode()
		return This.StringValue()

		def ToCodeQ()
			return new stzString( This.ToCode() )

	  #-------------#
	 #    MISC.    #
	#-------------#

	# TRUE if the number is a valid RGB color value.
	def IsRGBColor()
		return @IsRGBColor(This.Content())

		# TRUE if the number is a valid RGB color value.
		def IsAnRGBColor()
			return @IsRGBColor(This.Content())

	# TRUE if the given value is a number too.
	def HasSameTypeAs(p)
		return isNumber(p)

	# The numbers from this one UP TO n, as a list.
	def UpTo(pnOtherNumber)
		if pnOtherNumber > This.Value()
			_anResult_ = This.Value() : pnOtherNumber
			return _anResult_
		ok
	
	# The numbers from this one DOWN TO n, as a list.
	def DownTo(pnOtherNumber)
		if This.Value() > pnOtherNumber
			_anResult_ = This.Value() : pnOtherNumber
			return _anResult_
		ok

	# Swapping the content of the stzNumber with an other stzNumber

	def SwapWith(pOtherStzNumber)

		if CheckingParams()

			if NOT @IsStzNumber(pOtherStzNumber)
				StzRaise("Incorrect param type! pOtherStzNumber must be a stzNumber object.")
			ok
	
		ok

		_nThis_ = This.Content()
		_nOther_ = pOtherStzNumber.Content()

		This.UpdateWith(_nOther_)
		pOtherStzNumber.UpdateWith(_nThis_)


		def SwapWithQ(pOtherStzNumber)
			This.SwapWith(pOtherStzNumber)
			return This

		def SwapContentWith(pOtherStzNumber)
			This.SwapWith(pOtherStzNumber)

			def SwapContentWithQ(pOtherStzNumber)
				return This.SwapWithQ(pOtherStzNumber)

	# The least common multiple with the given number.
	def LCM(pOtherNumber)
		if isString(pOtherNumber)
			pOtherNumber = 0+ pOtherNumber
		ok
		return StzEngineNumberLcm(This.NumericValue(), pOtherNumber)

	# The greatest common divisor with the given number.
	def GCD(pOtherNumber)
		if isString(pOtherNumber)
			pOtherNumber = 0+ pOtherNumber
		ok
		return StzEngineNumberGcd(This.NumericValue(), pOtherNumber)

	  #=========================================#
	 #  ENGINE-BACKED NUMBER OPERATIONS        #
	#=========================================#

	# TRUE if the integer is a perfect number (equals the sum of its
	# divisors).
	def IsPerfect()
		if NOT This.IsInteger()
			return 0
		ok
		return StzEngineNumberIsPerfect(This.NumericValue())

		def IsPerfectNumber()
			return This.IsPerfect()

	# How many digits the integer has.
	def DigitCount()
		if NOT This.IsInteger()
			return len(This.IntegerPartValue())
		ok
		return StzEngineNumberDigitCount(This.NumericValue())

		def HowManyDigits()
			return This.DigitCount()

	# The sum of the digits of the integer.
	#@ aka  sum of the digits, add the digits together
	def DigitSum()
		if NOT This.IsInteger()
			StzRaise("Can't compute digit sum of a non-integer!")
		ok
		return StzEngineNumberDigitSum(This.NumericValue())

		def SumOfDigits()
			return This.DigitSum()

	# The digits of the integer, reversed.
	def ReverseDigits()
		if NOT This.IsInteger()
			StzRaise("Can't reverse digits of a non-integer!")
		ok
		return StzEngineNumberReverseDigits(This.NumericValue())

		def ReversedDigits()
			return This.ReverseDigits()

	# TRUE if the digits read the same backward.
	def IsDigitPalindrome()
		if NOT This.IsInteger()
			return 0
		ok
		return StzEngineNumberIsPalindrome(This.NumericValue())

		def IsPalindromeNumber()
			return This.IsDigitPalindrome()

	# The Fibonacci value for this integer.
	def Fibonacci()
		if NOT This.IsInteger()
			StzRaise("Can't compute Fibonacci of a non-integer!")
		ok
		n = This.NumericValue()
		if n < 0
			StzRaise("Can't compute Fibonacci of a negative number!")
		ok
		pBigInt = StzEngineNumberFibonacci(n)
		_cResult_ = StzEngineBigIntToString(pBigInt)
		StzEngineBigIntFree(pBigInt)
		return _cResult_

		def FibonacciQ()
			return new stzNumber(This.Fibonacci())

	# The methods of the object (Ring reflection).
	def Methods()
		return ring_methods(This)

	# The attributes of the object (Ring reflection).
	def Attributes()
		return ring_attributes(This)

	# The lowercase class name: "stznumber".
	def ClassName()
		return "stznumber"

		def StzClassName()
			return This.ClassName()

		def StzClass()
			return This.ClassName()

	# Always FALSE: plain numbers carry no name.
	def IsNamedObject()
		return 0

	# How many times the given digit occurs in the number.
	def HowMany(n)
		if isNumber(n)
			n = "" + n
		ok

		if NOT isString(n)
			StzRaise("Incorrect param type! n must be a number or string.")
		ok
		
		_nResult_ = This.ToStzString().HowMany(n)
		return _nResult_

	# The digits of the number, as a list.
	def Digits()
		_acChars_ = This.StringValueQ().RemoveManyQ([ "+", "-", "." ]).Chars()
		_nLen_ = len(_acChars_)

		_anResult_ = []

		for _i_ = 1 to _nLen_
			_anResult_ + (0+ _acChars_[_i_])

		next

		return _anResult_

		def DigitsQ()
			return new stzList( This.Digits() )

		# The digits, in the requested return type (QRT).
		def DigitsQRT(pcReturnType)
			switch pcReturnType
			on :stzList
				return new stzList( This.Digits() )
			on :stzListOfNumbers
				return new stzListOfNumbers( This.Digits() )
			other
				StzRaise("Unsupported return type!")
			off

	  #-------------------#
	 # PERCENTAGE FORMS  #
	#-------------------#

	# The number as a percentage string.
	def Percent()
		return This.NumericValue() / 100

	# What percentage this number is OF the given one.
	def PercentOf(n)
		return This.NumbericValue() * (n/100)

	  #=====================================#
	 #    INTERNAL KITCHEN OF THE CLASS    #
	#=====================================#

	Private

	def pvtCalculate(pcOperation, pOtherNumber)

		# Makes basic arithmetic operations (+, -, *, and /) and
		# other mathematical operations (sin, cos, tan, log...) in
		# a round-independent way:

		#--> Whatever the active round defined by decimals() is,
		# the result is always returned in a string containing the
		# effective number of the decimals.
	
		# First, string values are converted to number values
		_n1_ = This.NumericValue()
		if isString(pOtherNumber)
			_n2_ = StringToNumber(pOtherNumber)
		else
			_n2_ = pOtherNumber
		ok
	

		# Then, calculation is made and result is hosted inside
		# the nResult variable
		switch pcOperation
		on "+"
			_nResult_ = _n1_ + _n2_

		on "-"
			_nResult_ = _n1_ - _n2_
	
		on "*"
			_nResult_ = _n1_ * _n2_
	
		on "/"
			_nResult_ = _n1_ / _n2_
	
		on "%"
			_oTemp1_ = new stzNumber(_n1_)
			_oTemp2_ = new stzNumber(_n2_)

			if _oTemp1_.IsInteger() and _oTemp2_.IsInteger()
				_nResult_ = _n1_ % _n2_
			else
				StzRaise("Can't calculate the modulo. The two numbers must be integers!")
			ok
	
		on "^"
			_nResult_ = ring_pow(_n1_, _n2_)
	
		on "sin"
			_nResult_ = ring_sin(_n1_)
	
		on "cos"
			_nResult_ = ring_cos(_n1_)
	
		on "tan"
			_nResult_ = ring_tan(_n1_)
	
		on "cotan"
			_nResult_ = 1 / ring_tan(_n1_)
	
		on "asin"
			_nResult_ = ring_asin(_n1_)
	
		on "acos"
			_nResult_ = ring_acos(_n1_)
	
		on "atan2"
			_nResult_ = ring_atan2(_n1_)
	
		on "sinh"
			_nResult_ = ring_sinh(_n1_)
	
		on "cosh"
			_nResult_ = ring_cosh(_n1_)
	
		on "tanh"
			_nResult_ = ring_tanhh(_n1_)
	
		on "exp"
			_nResult_ = ring_exp(_n1_)
	
		on "log"
			_nResult_ = ring_log(_n1_)
	
		on "log10"
			_nResult_ = ring_log10(_n1_)
	
		on "fabs"
			_nResult_ = fabs(_n1_)

		on "sigmoid"
			_nResult_ = 1 / (1 + ring_exp(-_n1_))
	
		on "DerivativeSigmoid"
			_nSigmoid_ = 1 / (1 + ring_exp(-_n1_))
			_nResult_ = _nSigmoid_ * ( 1 - _nSigmoid_)

		on "LCM"
			_nResult_ = StzEngineNumberLcm(_n1_, _n2_)

		on "GCD"
			_nResult_ = StzEngineNumberGcd(_n1_, _n2_)

		on "inverse"
			_nResult_ = 1 / _n1_

		on "sqrt"
			_nResult_ = sqrt(_n1_)

		# Special case: the result is a list of integers!
		#--> Nothing to round: return the list of factors directly
		on "factors"
			return ring_factors(_n1_)		

		off

		/*
		Now, and before it is returned back, _nResult_ must be put in
		a string to preserve the round expressed in its effective
		round and hosted in a whatever the active round is in
		the program (made using decimals())
		*/

		_nCurrentRound_ = StzCurrentRound()
		StzDecimals(This.Round())
		_cResult_ = ""+ _nResult_
		StzDecimals(_nCurrentRound_)

		return _cResult_
