#---------------------------------------------------------------------------#
# 			SOFTANZA LIBRARY (V1.0)                             #
#---------------------------------------------------------------------------#
#									    #
# 	Description	: The class for managing softanza numbers           #
#	Version		: V1.1.0.6 (March, 2023)			    #
#	Author		: Mansour Ayouni (kalidianow@gmail.com)		    #
#									    #
#===========================================================================#

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
	for the value), i.e. double has 15 decimal digits of precision.
	
	Double range is '2.2250738585072014 E–308' to '1.7976931348623158 E+308'.
	Subsequently the size and length varies accordingly.
	It has nothing to do with the language one is using.
	
	<Ilir>
		±2.23 x 10-308 to ±1.80 x 10 308
		
		Min and max numbers for a double type which Ring uses are
		±2.23 x 10-308 to ±1.80 x 1030.
	
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

func StzNumberQ(cNumber)
	return new stzNumber(cNumber)

func StzNamedNumber(paNamed)
	if CheckParams()

	ok

	oNumber = new stzNumber(paNamed[2])
	oNumber.SetName(paNamed[1])
	return oNumber

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

		return TRUE
	else
		return FALSE
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
	oStr = new stzString(_cMaxCalculableInteger)
	oStr.Remove("_")
	cMax = oStr.content()

	return 0+ cMax
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
	oStr = new stzString(_cMaxCalculableRealNumber)
	cMax - "_"
	cMax = oStr.Content()

	return 0+ cMax

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

	def DefaultDecimalSeparator()
		return This.DefaultFractionalSeparator()
	
func StringRepresentsInteger(cNumber)
	oStr = new stzString(cNumber)
	return oStr.RepresentsInteger()

func StringRepresentsCalculableNumber(cNumber)
	oStr = new stzString(cNumber)
	return oStr.RepresentsCalculableNumber()
			
func StringRepresentsRealNumber(cNumber)
	oStr = new stzString(cNumber)
	return oStr.RepresentsRealNumber()

func StringRepresentsSignedNumber(cNumber)
	oStr = new stzString(cNumber)
	return oStr.RepresentsSignedNumber()

/*func IsInteger(n)
	if isNumber(n) and Q(n).IsInteger()
		return TRUE
	else
		return FALSE
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
		return TRUE
	else
		return FALSE
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
		return TRUE
	else
		return FALSE

	ok

	#< @FunctionAlternativeForms

	func IsABit(n)
		return IsBit(n)

	func @IsBit(n)
		return IsBit(n)

	func @IsABit(n)
		return IsBit(n)

	#>

func DecimalDigits()
	return _anDecimalDigits

func OctalDigits()
	return _anOctalDigits

func Double(n)
	if isList(n) and StzListQ(n).IsOfNamedParam()
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
	if isList(n) and StzListQ(n).IsOfNamedParam()
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
	if isList(n) and StzListQ(n).IsOfNamedParam()
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
	if isList(n) and StzListQ(n).IsOfNamedParam()
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
	if isList(n) and StzListQ(n).IsOfNamedParam()
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
	if isList(n) and StzListQ(n).IsOfNamedParam()
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
	if isList(n) and StzListQ(n).IsOfNamedParam()
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
	if isList(n) and StzListQ(n).IsOfNamedParam()
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
	if isList(n) and StzListQ(n).IsOfNamedParam()
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

		nNumber = p[1]
		nRound = p[2]
	else
		nNumber = p
		nRound = CurrentRound()
	ok


	return StzNumberQ(nNumber).RoundedTo(nRound)

func StzRoundXT(p)
	if isList(p) and IsPair(p)
		if isList(p[2]) and Q(p[2]).IsToNamedParam()
			p[2] = p[2][2]
		ok

		nNumber = p[1]
		nRound = p[2]
	else
		nNumber = p
		nRound = CurrentRound()
	ok

	return StzNumberQ(nNumber).RoundedToXT(nRound)

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
	
func NumberIsCalculable(nNumber)
	if CheckParams()
		if NOT isString(nNumber)
			StzRaise("Incorrect param type! nNumber must be a number.")
		ok
	ok

	oStr = new stzString(""+ nNumber)
	return oStr.RepresentsCalculableNumber()


func StringToNumber(cNumber) # TESTING IN PROGESS
	if isNumber(cNumber)
		return cNumber
	ok

	if NOt isString(cNumber)
		StzRaise("Incorrect param type! cNumber must be a string.")
	ok

	# Deletig unnecessary spaces

	cNumber = Q(cNumber).Trimmed()
	if cNumber = ""
		cNumber = "0"
	ok

	# Setting the decimal number depending on the form provided

	if StringRepresentsNumberInDecimalForm(cNumber)

		oNumber = new stzNumber(cNumber)
		return oNumber.NumericValue()
			
	but StringRepresentsNumberInBinaryForm(cNumber)

		oBinNumber = new stzBinaryNumber(cNumber)
		return oBinNumber.ToStzNumber().NumericValue()

	but StringRepresentsNumberInHexForm(cNumber)
		oHexNumber = new stzHexNumber(cNumber)
		return oHexNumber.ToStzNumber().NumericValue()

	but StringRepresentsNumberInOctalForm(cNumber)
		oOctNumber = new stzOctalNumber(cNumber)
		return oOctNumber.ToStzNumber().NumericValue()

	but StringRepresentsNumberInScientificNotation(cNumber)
		// TODO
		StzRaise("Feature not implemented yet!")
	other
		StzRaise(stzNumberError(:UnsupportedNumberForm))
	ok

	#< @FunctionAlternativeForms

	func ToNumber(cNumber)
		return StringToNumber(cNumber)

	func @ToNumber(cNumber)
		return StringToNumber(cNumber)

	func String2Number(cNumber)
		return StringToNumber(cNumber)

	func StrToNbr(cNumber)
		return StringToNumber(cNumber)

	func Str2Nbr(cNumber)
		return StringToNumber(cNumber)

	#>

func NumberToString(n)
	if CheckParams()
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
	if CheckParams()
		if NOT isString(pcNumber)
			StzRaise("Incorrect param type! pcNumber must be a string.")
		ok
	ok

	oStr = new stzString(pcNumber)
	return oStr.RepresentsNumberInDecimalForm()		

func CharIsDigit(c)
	return isDigit(c) # It's a native ring function

# Binary form

func StringRepresentsNumberInBinaryform(pcNumber)
	if CheckParams()
		if NOT isString(pcNumber)
			StzRaise("Incorrect param type! pcNumber must be a string.")
		ok
	ok

	oTempStr = new stzString(pcNumber)
	return oTempStr.RepresentsNumberInBinaryForm()

# Hex form

func StringRepresentsNumberInHexForm(pcNumber)
	if CheckParams()
		if NOT isString(pcNumber)
			StzRaise("Incorrect param type! pcNumber must be a string.")
		ok
	ok

	oTempStr = new stzString(pcNumber)
	return oTempStr.RepresentsNumberInHexForm()

func StringRepresentsNumberInUnicodeHexForm(pcNumber)
	if CheckParams()
		if NOT isString(pcNumber)
			StzRaise("Incorrect param type! pcNumber must be a string.")
		ok
	ok

	return StzStringQ(pcNumber).RepresentsNumberInUnicodeHexForm()

# Octal form

func StringRepresentsNumberInOctalForm(pcNumber)
	if CheckParams()
		if NOT isString(pcNumber)
			StzRaise("Incorrect param type! pcNumber must be a string.")
		ok
	ok

	oTempStr = new stzString(pcNumber)
	return oTempStr.RepresentsNumberInOctalForm()

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
	if len(pcNumber) > 3
		// Considering the case where the number is preceeded by a + or - sign
		// --> In This case, the sign is simply ignored
		if len(pcNumber)=4 and
		   ( left(pcNumber,1) = "+" or
		     left(pcNumber,1) = "-")

			pcNumber = pcNumber[2] + pcNumber[3] + pcNumber[4]
		else
			StzRaise("Can't proceed! The lenght of the number should not exceed 3.")
		ok
	ok

	// Constructing the microstructure of the number (units, dozens, and hundreds)
	cUnits = "0"
	cDozens = "0"
	cHundreds = "0"
	
	switch len(pcNumber)
	on 1
		cUnits = pcNumber
			
	on 2
		cUnits = right(pcNumber,1)
		cDozens = left(pcNumber,1)
			
	on 3
		cUnits = right(pcNumber,1)
		cDozens = substr(pcNumber,2,1)
		cHundreds = left(pcNumber,1)
	off

	return [ :Units = cUnits, :Dozens = cDozens, :Hundreds = cHundreds ]

func GetMicroStructure(pNumber)
	return GetUnitsDozensAndHundreds(pNumber)

func ZeroIfEmpty(pcStr)
	if isEmpty(pcStr)
		return NULL
	ok

func Derivative(pFunction)
	nTemp = call pFunction(n1)
	return nTemp * (1 - nTemp)
		
func NumberIsDividorOf(pNumber,pOf)
	oStzNumber = new stzNumber(pNumber)
	return oStzNumber.IsDividorOf(pOf)

func NumberIsDividableBy(pNumber, pBy)
	oStzNumber = new stzNumber(pNumber)
	return oStzNumber.IsDividableBy(pBy)

func NumberConvert(pNumber, pcFrom, pcTo)
	pcNumber = ""+ pNumber

	switch pcFrom
	on :FromDecimalForm
		if NOT StringRepresentsNumberInDecimalForm(pcNumber)
			StzRaise(stzNumberError(:CanNotConvertNumberFromDecimalInThisForm))
		ok

		oStzNumber = new stzNumber(pcNumber)
		switch pcTo
		on :ToDecimalForm
			return pcNumber
		on :ToBinaryForm
			return oStzNumber.ToBinaryForm()
		on :ToHexform
			return oStzNumber.ToHexForm()

		on :ToUnicodeHexForm
			return oStzNumber.ToUnicodeHexForm()

		on :ToOctalForm
			return oStzNumber.ToOctalForm()
		other
			StzRaise(stzNumberError(:UnsupportedNumberConversionTargetForm1))
		off

	on :FromBinaryForm
		if NOT NumberIsInBinaryForm(pcNumber)
			StzRaise(stzNumberError(:CanNotConvertNumberFromBinaryInThisForm))
		ok

		oBinNumber = new stzBinaryNumber(pcNumber)

		switch pcTo
		on :ToDecimalForm
			return oBinNumber.ToDecimalForm()
		on :ToBinaryForm
			return pcNumber
		on :ToHexForm
			return oBinNumber.ToHexForm()

		on :ToUnicodeHexForm
			return oBinNumber.ToUnicodeHexForm()

		on :ToOctalForm
			return oBinNumber.ToOctalForm()
		other
			StzRaise(stzNumberError(:UnsupportedNumberConversionTargetForm))
		off

	on :FromHexForm
		if NOT StringContainsNumberInHexForm(pcNumber)
			StzRaise(stzNumberError(:CanNotConvertNumberFromHexInThisForm))
		ok

		oHexNumber = new stzHexNumber(pcNumber)
		switch pcTo
		on :ToDecimalForm
			return oHexNumber.ToDecimalForm()
		on :ToBinaryForm
			return oHexNumber.ToBinaryForm()
		on :ToHexForm
			return pcNumber

		on :ToUnicodeHexForm
			return oHexNumber.ToUnicodeHexNumber()

		on :ToOctalForm
			return oHexNumber.ToOctalForm()
		other
			StzRaise(stzNumberError(:UnsupportedNumberConversionTargetForm))
		off

	on :FromOctalForm
		if NOT NumberIsInOctalForm(pcNumber)
			StzRaise(stzNumberError(:CanNotConvertNumberFromOctalInThisForm))
		ok

		oOctalNumber = new stzOctalNumber(pcNumber)

		switch pcTo
		on :ToDecimalForm
			return oOctalNumber.ToDecimalForm()

		on :ToBinaryForm
			return oOctalNumber.ToBinaryForm()

		on :ToHexForm
			return oOctalNumber.ToHexForm()

		on :ToUnicodeHexForm
			return oOctalNumber.ToUnicodeHexForm()

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

func BothArePositive(n1, n2)
	if BothAreNumbers(n1, n2) and n1 > 0 and n2 > 0
		return TRUE
	else
		return FALSE
	ok

func BothAreNegative(n1, n2)
	if BothAreNumbers(n1, n2) and n1 < 0 and n2 < 0
		return TRUE
	else
		return FALSE
	ok

func BothAreZeros(n1, n2)
	if BothAreNumbers(n1, n2) and n1 = 0 and n2 = 0
		return TRUE
	else
		return FALSE
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
		return TRUE
	else
		return FALSE
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

	bestA = 1
	bestB = n
	bestRatio = n

	for a = 1 to floor(sqrt(n))
		b = ceil(n / a)
		ratio = ring_max([ b / a, a / b ])

		if ratio < bestRatio
			bestRatio = ratio
			bestA = a
			bestB = b
		ok
	next

	return [bestA, bestB]

	#< @FunctionAlternativeForms

	func MSLF(n)
		return MostSquareLikeFactors(n)

	#--

	func @MostSquareLikeFactors(n)
		return MostSquareLikeFactors(n)

	func @MSLF(n)
		return MostSquareLikeFactors(n)

	#>

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

	  #------------#
	 #    INIT    #
	#------------#

	def init(pNumber)

		# A stzNumber object can be initiated in 3 ways:

		# 1- By providing a number, in this case the current round is taken.
		#    ~> Example : new stzNumber(12)

		# 2- By provising a number in string. In this case, if the number
		#   contains decimals, then the round is the number of decimals.
		#   Otherwise, the current round is taken.
		#   ~> Example : new stzNumber("12.375")

		# 3- By providing a pair conataining the number itself (as a number
		#    or as a number in string), and the round to be taken.
		#    ~> Example : new stzNumber([ 12.275865, :Round = 3 ])

		if CheckParams()
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
			# ~> Example : new stzNumber("⑦")
			if StzStringQ(pNumber).IsAChar() and
			   StzCharQ(pNumber).IsCircledNumber()

				@cContent = ""+ StzCharQ(pNumber).NumericValue()
				@nRound = StzCurrentRound()

				return
			ok

			# Case where the string provided is empty
			if pNumber = NULL
				@cContent = "0"
				@nRound = StzCurrentRound()

			# Case where the user provides a number in string
			# with a dot "." at the end (a "0" is then added)
			but StzStringQ(pNumber).LastChar() = "." and
			   StzStringQ(pNumber).RemoveLastCharQ().RepresentsNumberInDecimalForm()

				pNumber += "0"
	
			# Case where pNumber is a non null string
			else
				if StringRepresentsNumberInDecimalForm(pNumber)
		
					if StringRepresentsCalculableNumber(pNumber)
						oString = new stzString(pNumber)
						if oString.Contains("_")
							@cContent = oString.RemoveQ("_").Content()
						else
							@cContent = pNumber
						ok

						if oString.Contains(".")
							@nRound = oString.Size() - oString.FindFirst(".")
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

				nCurrentRound = StzCurrentRound()
				StzDecimals(@nRound)
				@cContent = "" + pNumber[1]
				StzDecimals(nCurrentRound)

			but isString(pNumber[1])
				@cContent = pNumber[1]
				@cReturnType = :String

			ok

		ok

	  #-------------------------#
	 #    CONTENT AND VALUE    #
	#-------------------------#

	def Content()
		return @cContent

		def ContentQ()
			return new stzNumber(This.Content())

	def Number()
		return This.NumericValue()

		def NumberQ() # Same as Copy()
			return new stzNumber( This.Content() )

	def InitialContent()
		return pNumber		 

	def Copy()
		oCopy = new stzNumber( This.Content() )
		return oCopy

	def ReturnType()
		return @cReturnType

	def SetReturnType(cType)
		if CheckParams()
			if isList(cType) and Q(cType).IsToOrAsNamedParams()
				cType = cType[2]
			ok

			if NOT isString(cType)
				StzRaise("Incorrect param type! cType must be a string.")
			ok
		ok

		if NOT ( cType = :Number or cType = :String )
			StzRaise("Incorrect value! cType must be equal to :Number or :String.")
		ok

		@cReturnType = cType

		#< @FunctionAlternativeForms

		def SetReturnTypeTo(cType)
			if CheckParams()
				if NOT isString(cType)
					StzRaise("Incorrect param type! cType must be a string.")
				ok
			ok

			This.SetReturnType(cType)

		def SetReturnTypeAs(cType)
			SetReturnTypeTo(cType)

		#>

	def ReturnNumber()
		SetReturnType(:Number)
		
	def NumberWithSign()
		If This.IsPositive()
			return "+" + This.Content()

		else
			return This.Content()
		ok

	def NumericValue()
		return 0+ @cContent

		def Value()
			return This.NumericValue()
	
		# Misspelled Form

		def NumbericValue()
			return This.NumericValue()

	def StringValue()

		# Memorizing the current round (to reset it before leaving)

		nCurrentRound = StzCurrentRound()

		# Activating the round of the number as saved in the object

		StzDecimals(This.Round())

		# Casting the number in a string using the round above

		@cContent = "" + This.NumbericValue()

		# Resetting the round active in the program

		StzDecimals(nCurrentRound)

		# Returning the string form of the number

		return @cContent

		def StringValueQ()
			return new stzString( This.StringValue() )

	  #------------------------------------#
	 #  CHECKING IF THE NUMBER IS A CHAR  #
	#------------------------------------#

	def IsChar()

		if This.IsInteger()
			nTemp = This.NumericValue()
			if nTemp >= 0 and nTemp <= 9
				return TRUE
			ok
		ok

		return TRUE

		def IsAChar()
			return This.IsChar()

	  #-------------------------#
	 #   UPDATING THE NUMBER   #
	#-------------------------#

	def Update(pNumber)
		if CheckParams()

			if isList(pNumber) and Q(pNumber).IsWithOrByOrUsingNamedParam()
				pNumber = pNumber[2]
			ok

			if NOT ( isNumber(pNumber) or ( isString(pNumber) and Q(pNumber).IsNumberInString() ) )
				StzRaise("Incorrect param type! pNumber must be a number or a string containing a number.")
			ok

		ok

		if isString(pNumber)

			@cReturnType = :String

			oStr = new stzString(pNumber)
			@cContent = oStr.RemoveQ("_").Content()

			@nRound = StzCurrentRound()

			if oStr.Contains(".")
				@nRound = oStr.NumberOfChars() - oStr.FindFirst(".") + 1
			ok

		else # isNumber(pNumber)

			@cReturnType = :Number

			@cContent = ""+ pNumber
			@nRound = StzCurrentRound()
		ok

		#< @FunctionFluentForm

		def UpdateQ(pNumber)
			This.Update(pNumber)
			return This

		#>

		#< @FunctionAlternativeForms

		def UpdateWith(pNumber)
			This.Update(pNumber)

			def UpdateWithQ(pNumber)
				return This.UpdateQ(pNumber)
	
		def UpdateBy(pNumber)
			This.Update(pNumber)

			def UpdateByQ(pNumber)
				return This.UpdateQ(pNumber)

		def UpdateUsing(pNumber)
			This.Update(pNumber)

			def UpdateUsingQ(pNumber)
				return This.UpdateQ(pNumber)

		#>

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
		acChars = This.StringValueQ().ToChars()
		anResult = StzListOfCharsQ(acChars).Unicodes()
		return anResult

	  #-----------------------------------#
	 #  CHECKING IF THE NUMBER IS DIGIT  #
	#-----------------------------------#

	def IsADigit()
		n = This.NumericValue()
		if 0 <= n and n <= 9
			return TRUE
		else
			return FALSE
		ok

		def IsDigit()
			return This.IsADigit()

	  #---------------------------------------------------------#
	 #   CHECKING IF THE NUMBER IS MULTIPLE OF A GIVEN NUMBER  #
	#---------------------------------------------------------#

	def IsMultipleOf(n)

		if CheckParams()
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
			return FALSE
		ok

		if This.NumericValue() % n = 0
			return TRUE
		else
			return FALSE
		ok

		def IsAMultipleOf(n)
			return This.IsMultipleOf(n)

		def IsTheMultipleOf(n)
			return This.IsMultipleOf(n)

	def IsDoubleOf(n)
		if CheckParams()
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
			return TRUE
		else
			return FALSE
		ok

		def IsADoubleOf(n)
			return This.IsDoubleOf(n)

		def IsTheDoubleOf(n)
			return This.IsDoubleOf(n)

	def IsTripleOf(n)
		if CheckParams()
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
			return TRUE
		else
			return FALSE
		ok

		def IsAtripleOf(n)
			return This.IsTripleOf(n)

		def IsTheTripleOf(n)
			return This.IsTripleOf(n)

	def IsQuadrupleOf(n)
		if CheckParams()
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
			return TRUE
		else
			return FALSE
		ok

		def IsAQuadrupleOf(n)
			return This.IsQuadrupleOf(n)

		def IsTheQuadrupleOf(n)
			return This.IsQuadrupleOf(n)

	def IsQuintupleOf(n)
		if CheckParams()
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
			return TRUE
		else
			return FALSE
		ok

		def IsAQuintupleOf(n)
			return This.IsQuintupleOf(n)

		def IsTheQuintupleOf(n)
			return This.IsQuintupleOf(n)

	def IsSextupleOf(n)
		if CheckParams()
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
			return TRUE
		else
			return FALSE
		ok

		def IsASextupleOf(n)
			return This.IsSextupleOf(n)

		def IsTheSextupleOf(n)
			return This.IsSextupleOf(n)


	def IsOctupleOf(n)
		if CheckParams()
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
			return TRUE
		else
			return FALSE
		ok

		def IsAnOctupleOf(n)
			return This.IsOctupleOf(n)

		def IsTheOctupleOf(n)
			return This.IsOctupleOf(n)

	def IsNonupleOf(n)
		if CheckParams()
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
			return TRUE
		else
			return FALSE
		ok

		def IsANonupleOf(n)
			return This.IsNonupleOf(n)

		def IsTheNonupleOf(n)
			return This.IsNonupleOf(n)

	def IsDecupleOf(n)
		if CheckParams()
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
			return TRUE
		else
			return FALSE
		ok

		def IsADecupleOf(n)
			return This.IsDecupleOf(n)

		def IsTheDecupleOf(n)
			return This.IsDecupleOf(n)

	  #-----------------#
	 #    BOUNDNESS    #
	#-----------------#

	def IsBoundedBy(n1, n2)
		if CheckParams()
			if NOT ( @IsStringOrNumber(n1) and @IsStringOrNumber(n2) )
				StzRaise("Incorrect param type! n1 and n2 must be numbers or strings.")
			ok

			if isString(n1) and NOT Q(n1).IsDecimalNumberInString()
				StzRaise("Incorrect value! The string n1 must contain a decimal number.")
			ok

			if isString(n2) and NOT Q(n2).IsDecimalNumberInString()
				StzRaise("Incorrect value! The string n2 must contain a decimal number.")
			ok

		ok

		if isString(n1)
			n1 = StzNumberQ(n1).NumericValue()
		ok

		if isString(n2)
			n2 = StzNumberQ(n2).NumericValue()
		ok

		if n1 > n2
			nTemp = n1
			n1 = n2
			n2 = nTemp
		ok
 
		if This.NumericValue() >= n1 and This.NumericValue() <= n2
			return TRUE
		else
			return FALSE
		ok

	  #------------#
	 #    TYPE    #
        #------------#

	def IsInteger()
		if NOT This.HasFractionalPart()
			return TRUE
		else
			return FALSE
		ok

	def IsPositiveInteger()
		if This.IsInteger() and This.IsPositive()
			return TRUE
		else
			return FALSE
		ok

	def IsNegativeInteger()
		if This.IsInteger() and This.IsNegative()
			return TRUE
		else
			return FALSE
		ok

	def IsReal()
		if This.HasFractionalPart()
			return TRUE
		else
			return FALSE
		ok

		def IsRealNumber()
			return This.IsReal()

	def IsBigNumber()
		if This.NumberOfDigits() > This.MaxNumberOfDigits()
			return TRUE
		else
			return FALSE
		ok

	def IsOneDigit()
		if This.IsInteger() and len(This.Content()) = 1
			return TRUE
		else
			return FALSE
		ok

	def IsOdd()
		if OddOrEven(This.NumericValue()) = :Odd
			return TRUE
		else
			return FALSE
		ok

		#< @FunctionAlternativeForm

		def IsFardi() # Added because I have a confusion between odd() and even()
			return This.IsOdd()

		ded IsNotMultipleOf2()
			return This.IsOdd()

		#>

		#< @FunctionPassiveForm

		def IsNotOdd()
			return NOT This.IsOdd()

		#>

	def IsEven()
		if OddOrEven(This.NumericValue()) = :Even
			return TRUE
		else
			return FALSE
		ok

		#< @FunctionAlternativeForm

		def IsZawji() # Added because I have a confusion between odd() and even()
			return This.IsEven()

		ded IsMultipleOf2()
			return This.IsEven()

		#>

		#< @FunctionPassiveForm

		def IsNotEven()
			return NOT This.IsEven()

		#>

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

	def IsPrime()
		if This.IsInteger() and This.IsGreaterThan(1)
			return ring_isPrime( This.NumericValue() )
		else
			return FALSE
		ok

		def IsAPrimeNumber()
			return This.IsPrime()

		def IsAPrime()
			return This.IsPrime()

		def IsPrimeNumber()
			return This.IsPrime()

	def IsBoolean()
		if This.Number() = 1 or This.Number() = 0
			return TRUE
		else
			return FALSE
		ok

	def IsTrue()
		if This.Number() = 1
			return TRUE
		else
			return FALSE
		ok

	def IsFalse()
		if This.Number() = 0
			return TRUE
		else
			return FALSE
		ok
		
	  #----------------------------------#
	 #    NULL, POSITIVE OR NEGATIVE    #
	#----------------------------------#

	def IsZero()
		if This.Content() = "0"
			return TRUE
		else
			return FALSE
		ok

	def IsNegative()
		if This.Sign() = "-"
			return TRUE
		else
			return FALSE
		ok	
		 
	def IsStrictlyNegative()
		if This.IsNegative() or This.IsZero()
			return TRUE

		else
			return FALSE
		ok

	def IsPositive()
		if This.IsNotSigned() or This.Sign() = "+"
			return TRUE
		else
			return FALSE
		ok

	def IsStrictlyPositive()
		if This.IsPositive() or This.IsZero()
			return TRUE

		else
			return FALSE
		ok

	  #------------#
	 #    SIGN    #
	#------------#
	
	def Sign()

		oStr = new stzString(This.Content())
		cLeft = oStr.LeftChar()

		if cLeft = "+"
			return "+"

		but cLeft = "-"
			return "-"

		ok

	def RemoveSign()
		cNumber = This.Content()
		nLenNumber = len(cNumber)

		cSign = This.Sign()

		if cSign = "+" or cSign = "-"

			This.Update( Substr(cNumber, 2, nLenNumber -2 ) )
		ok

		def RemoveSignQ()
				This.RemoveSign()
				return This

	def SignRemoved()
		cResult = This.Copy().RemoveSignQ().Content()
		return cResult

	def IsSigned()
		if This.Sign() != NULL
			return TRUE
		else
			return FALSE
		ok

		def IsNotSigned()
			return NOT IsSigned()

	def IsUnsigned()
		if This.IsSigned() = TRUE
			return FALSE
		else
			return TRUE
		ok

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
		if CheckParams()
			if NOT @IsNumberOrNumberInString(pOtherNumber)
				StzRaise("Incorrect param type! pOtherNumber must be a number or number in string.")
			ok
		ok

		nCurrentRound = StzCurrentRound()

		StzDecimals(This.Round())

		bResult = (This.NumericValue() = 0+ pOtherNumber)
		StzDecimals(nCurrentRound)

		return bResult

		#< @FunctionAlternativeForms

		def IsEqual(pOtherNumber)
			if isList(pOtherNumber) and Q(pOtherNumber).IsToNamedParam()
				pOtherNumber = pOtherNumber[2]
			ok

			return This.IsEqualTo(pOtherNumber)

		def EqualTo(pOtherNumber)
			return This.IsEqual(pOtherNumber)

		def Equals(pOtherNumber)
			return This.IsEqual(pOtherNumber)

		#-- CS

		def IsEqualToCS(pOtherNumber, pCaseSensitive)
			return This.IsEqualTo(pOtherNumber)

		def IsEqualCS(pOtherNumber, pCaseSensitive)
			return This.IsEqualTo(pOtherNumber)

		def EqualsCS(pOtherNumber, pCaseSensitive)
			return This.IsEqualTo(pOtherNumber)

		#>

		#< @FunctionPassiveForm

		def IsNotEqualTo(pOtherNumber)
			return NOT This.IsEqualTo(pOtherNumber)
	
			#< @FunctionAlternativeForm

			def IsDifferentFrom(pOtherNumber)
				return This.IsNotEqualTo(pOtherNumber)

			def IsDifferentTo(pOtherNumber)
				return This.IsNotEqualTo(pOtherNumber)

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

	def IsNeither(n1, n2)
		if CheckParams()
			if isList(n1) and Q(n1).IsEqualToNamedParam()
				n1 = n1[2]
			ok

			if isList(n2) and Q(n2).IsNorNamedParam()
				n2 = n2[2]
			ok

			if @BothAreStrings(n1, n2) and
			   NOT @BothAreNumbersInStrings(n1, n2)

				return This.@IsNeither(n1, n2)
			ok

			if NOT ( @BothAreNumbers(n1, n2) or @BothAreNumbersInStrings(n1, n2) )
				StzRaise("Incorrect param type! n1 and n2 must both be numbers or numbers in strings.")
			ok
		ok

		bEqualToN1 = This.IsEqualTo(n1)
		bEqualToN2 = This.IsEqualTo(n2)

		if NOT bEqualToN1 and NOT bEqualToN2
			return TRUE
		else
			return FALSE
		ok

		def IsNeitherEqualTo(n1, n2)
			return This.IsNeither(n1, n2)

	def IsLess(pOtherNumber)
		if CheckParams()
			if NOT Q(pOtherNumber).IsNumberOrString()
				StzRaise("Incorrect param types! pNumber1 and pNumber2 must be numbers or strings.")
			ok
		ok

		nCurrentRound = StzCurrentRound()

		StzDecimals(This.Round())
		bResult = (This.NumericValue() <= 0+ pOtherNumber)
		StzDecimals(nCurrentRound)

		return bResult

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
	
	def IsStriclyLess(pOtherNumber)
		if CheckParams()
			if NOT Q(pOtherNumber).IsNumberOrString()
				StzRaise("Incorrect param types! pNumber1 and pNumber2 must be numbers or strings.")
			ok
		ok

		nCurrentRound = StzCurrentRound()

		StzDecimals(This.Round())
		bResult = (This.NumericValue() < 0+ pOtherNumber)
		StzDecimals(nCurrentRound)

		return bResult

		#< @FunctionAlternativeForms

		def IsStrictlyLessThan(pOtherNumber)
			return This.IsStrictlyLess(pOtherNumber)

		def IsStrictlyLessOrEqualTo(pOtherNumber)
			return This.IsStrictlyLess(pOtherNumber)

		def IsStrictlySmallerOrEqualTo(pOtherNumber)
			return This.IsStrictlyLess(pOtherNumber)

		def IsStrictlyEqualOrLessThan(pOtherNumber)
			return This.IsStrictlyLess(pOtherNumber)

		def IsStrictlyEqualOrSmallerThan(pOtherNumber)
			return This.IsStrictlyLess(pOtherNumber)

		def IsStrictlySmallerThqn(pOtherNumber)
			return This.IsStrictlyLess(pOtherNumber)

		#>

	def IsGreater(pOtherNumber)
		if CheckParams()
			if NOT Q(pOtherNumber).IsNumberOrString()
				StzRaise("Incorrect param types! pNumber1 and pNumber2 must be numbers or strings.")
			ok
		ok

		nCurrentRound = StzCurrentRound()

		StzDecimals(This.Round())
		bResult = (This.NumericValue() >= 0+ pOtherNumber)
		StzDecimals(nCurrentRound)

		return bResult

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

	def IsStrictlyGreater(pOtherNumber)
		if CheckParams()
			if NOT Q(pOtherNumber).IsNumberOrString()
				StzRaise("Incorrect param types! pNumber1 and pNumber2 must be numbers or strings.")
			ok
		ok

		nCurrentRound = StzCurrentRound()

		StzDecimals(This.Round())
		bResult = (This.NumericValue() > 0+ pOtherNumber)
		StzDecimals(nCurrentRound)

		return bResult

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

	def IsBetween(pNumber1, pNumber2)

		if CheckParams()
			if isList(pNumber2) and Q(pNumber2).IsAndNamedParam()
				pNumber2 = pNumber2[2]
			ok
	
			if NOT ( Q(pNumber1).IsNumberOrString() and Q(pNumber2).IsNumberOrString() )
				StzRaise("Incorrect param types! pNumber1 and pNumber2 must be numbers or strings.")
			ok
		ok

		n1 = 0+ pNumber1
		n2 = 0+ pNumber2

		n = This.NumericValue()

		bResult = TRUE

		if NOT ( n1 < n and n < n2 )
			bResult  = FALSE
		ok

		return bResult

	def IsBetweenIB(pNumber1, pNumber2)

		if CheckParams()
			if isList(pNumber2) and Q(pNumber2).IsAndNamedParam()
				pNumber2 = pNumber2[2]
			ok
	
			if NOT ( Q(pNumber1).IsNumberOrString() and Q(pNumber2).IsNumberOrString() )
				StzRaise("Incorrect param types! pNumber1 and pNumber2 must be numbers or strings.")
			ok
		ok

		n1 = 0+ pNumber1
		n2 = 0+ pNumber2

		n = This.NumericValue()

		bResult = TRUE

		if NOT ( n1 <= n and n <= n2 )
			bResult  = FALSE
		ok

		return bResult

		def IsBetweenXT(pNumber1, pNumber2)
			return This.IsBetweenIB(pNumber1, pNumber2)

	def IsStrictlyBetween(pNumber1, pNumber2)
		if CheckParams()
			if isList(pNumber2) and Q(pNumber2).IsAndNamedParam()
				pNumber2 = pNumber2[2]
			ok
	
			if NOT ( Q(pNumber1).IsNumberOrString() and Q(pNumber2).IsNumberOrString() )
				StzRaise("Incorrect param types! pNumber1 and pNumber2 must be numbers or strings.")
			ok
		ok

		nCurrentRound = StzCurrentRound()
		StzDecimals(This.Round())

		bResult = ( This.NumericValue() > 0+ pNumber1 and
			    This.NumericValue() < 0+ pNumber2 )

		StzDecimals(nCurrentRound)

		return bResult

	def IsQuietEqualTo(pOtherNumber)

		if NOT Q(pOtherNumber).IsNumberOrString()
			StzRaise("Incorrect param types! pNumber1 and pNumber2 must be numbers or strings.")
		ok

		nCurrentRound = StzCurrentRound()

		StzDecimals(This.Round())
		bResult = ( fabs( (This - pOtherNumber).NumericValue() ) <= QuietEqualityRatio() )
		StzDecimals(nCurrentRound)

		return bResult

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
			return substr( This.IntegerPart(), 2, len(This.IntegerPart())-1 )
		ok

		def IntegerPartWithoutSignQ()
			return new stzString(This.IntegerPartWithoutSign())

		def IntegerPartStringValueWithoutSign()
			return This.IntegerPartWithoutSign()

			def IntegerPartStringValueWithoutSignQ()
				return This.IntegerPartWithoutSignQ()

	def NumberOfDigitsInIntegerPart()
		if This.Sign() = NULL
			return len(This.IntegerPart())
		else
			return len(This.IntegerPart()) - 1
		ok

		def NumberOfIntegers()
			return This.NumberOfDigitsInIntegerPart()

	def HasFractionalPart()
		if This.ToStzString().Contains(".")
			return TRUE
		else
			return FALSE
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
		nMaxDigits = 0
		switch This.IsIntegerOrReal()
		on "INTEGER"
			if This.IsSigned()
				nMaxDigits = MaxNumberOfDigitsInSignedInteger()
			else
				nMaxDigits = MaxNumberOfDigitsInUnsignedInteger()
			ok
		
		on "REAL"
			if This.IsSigned()
				nMaxDigits = MaxNumberOfDigitsInSignedRealNumber()
			else
				nMaxDigits = MaxNumberOfDigitsInUnsignedRealNumber()
			ok
		off
		
		return nMaxDigits

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
		anResult = This.IntegerPartWithoutSignQ().CharsQ().Numberified()
		return anResult

		#< @FunctionFluentFroms

		def IntegersQ()
			return This.IntegersQR(:stzList)

		def IntegersQR(pcReturnType)
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

			def IntergersQR(pcReturnType)
				return This.IntegersQR(pcReturnType)

		#>

	def Decimals()
		anResult = This.DecimalPartWihtoutDotQ().CharsQ().Numberified()
		#NOTE // This is a misspelled form in Wihtout (sould be Without)
		# But Softanza recognises it understands what you meant!

		return anResult

		#< @FunctionFluentFroms

		def DecimalsQ()
			return This.DecimalsQR(:stzList)

		def DecimalsQR(pcReturnType)
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
		nResult = This.IntegersQR(:stzListOfNumbers).Sum()
		return nResult

	def SumOfDecimals()
		nResult = This.DecimalsQR(:stzListOfNumbers).Sum()
		return nResult

	  #--------------#
	 #    ROUNDS    #
	#--------------#

	/*
	TODO: Actually, softanza rounds numbers using the native rounding service
	      provided by Ring decimals() standard function.

	      In the future, Study and reflect on enabling those rounding modes:
	      	- RoundCeiling: see if it is same as RoundUp()?
	       	- RoundFloor: see if it is same as RoundDown()?
	       	- RoundDown,
	       	- RoundUp,
	       	- RoundHalfEven,
	       	- RoundHalfDown,
	       	- RoundHalfUp,
	       	- RoundUnnecessary
	*/

	def MaxRound()
		nResult = len( ""+ MaxNumberInRing() ) - This.NumberOfIntegers()

		if This.ContainsDecimalPart()
			nResult -= (1 + This.NumberOfDecimals())
		ok

		return nResult

	def NumberOfRoundsWeCanAddBeforeMaxRoundIsReached()

		nResult =  This.MaxNumberOfDigitsTheNumberCanContain() -
		      	   This.NumberOfDigitsTheNumberActuallyContains()

		return nResult

	def Round()
		return @nRound

		#< @FunctionAlternativeForms

		# These alternatives are provided to the user if
		# he wants to avoid semantic confustion the global
		# function Round(). This function is made to enable
		# external code in other languages.

		def GetRound()
			return This.Round()

		def NumberRound()
			return This.Round()

		#>

	def RoundToXT(nRound)
		if CheckParams()
			if isString(nRound) and nRound = :Max
				nRound = MaxRoundInRing()
			ok

			if NOT isNumber(nRound)
				StzRaise("Incorrect param type! nRound must be a number.")
			ok
		ok

		if nRound > MaxRoundInRing()
			StzRaise("Incorrect round! nRound can't exceed the maxround in Ring, " + MaxRound() + ".")
		ok

		@nRound = nRound

		nCurrentRound = StzCurrentRound()
		StzDecimals(nRound)
		@cContent = ""+ This.NumericValue()

		if This.IsInteger() and nRound > 0
			@cContent += "."
			for i = 1 to nRound
				@cContent += "0"
			next
		ok

		StzDecimals(nCurrentRound)

		#< @FunctionFluentForm

		def RoundToXTQ(pRound)
			This.RoundToXT(pRound)
			return This

		#>

		#< @FunctionAlternativeForm

		def SetRoundXT(nRound)
			This.RoundToXT(nRound)

			def SetRoundXTQ(nRound)
				return This.RoundToXTQ(nRound)

		#>

	def RoundedToXT(pRound)
		cResult = This.Copy().RoundToXTQ(pRound).Content()
		return cResult

	#--

	def RoundToMaxXT()
		This.RoundToXT(:Max)


	def RoundedToMaxXT()
		return This.RoundedTo(MaxRoundXT())

	#---

	def RoundTo(nRound)
		cResult = This.RoundToXTQ(nRound).
			       ToStzString().
			       RemoveThisTrailingCharQ("0"). # XT ~> All 0s are removed
			       RemovedFromEnd(".")

		This.Update(cResult)

		#< @FunctionFluentForm

		def RoundToQ(pRound)
			This.RoundTo(pRound)
			return This

		#>

		#< @FunctionAlternativeForm

		def SetRound(nRound)
			This.RoundTo(nRound)

			def SetRoundQ(nRound)
				return This.RoundToQ(nRound)

		#>

	def RoundedTo(pRound)
		cResult = This.Copy().RoundToQ(pRound).Content()
		return cResult

	#--

	def RoundToMax()
		This.RoundTo(:Max)

	def RoundedToMax()
		return This.RoundedTo(MaxRound())

	#---

	def RoundUp()
		return This.pvtCalculate( "floor", NULL )

	def RoundDown()
		return This.pvtCalculate( "ceil", NULL )
			
	def RoundToSameRoundAs(pOtherNumber)
		oOtherNumber = new stzNumber(pOtherNumber)
		nRoundOtherNumber = oOtherNumber.Round()

		This.RoundTo(nRoundOtherNumber)

	def RoundIsGreaterThanRoundOf(pOtherNumber)

		nRound = This.Round()

		oOtherNumber = new stzNumber(pOtherNumber)
		nOtherRound = oOtherNumber.NumberOfDigits()

		if nRound > nOtherRound
			return TRUE
		else
			return FALSE
		ok

	def RoundIsLessThanRoundOf(pOtherNumber)
		nRound = This.Round()

		oOtherNumber = new stzNumber(pOtherNumber)
		nOtherRound = oOtherNumber.NumberOfDigits()

		if nRound < nOtherRound
			return TRUE
		else
			return FALSE
		ok
	
	def RoundIsSameAsRoundOf(pOtherNumber)
		nRound = This.Round()

		oOtherNumber = new stzNumber(pOtherNumber)
		nOtherRound = oOtherNumber.NumberOfDigits()

		if nRound = nOtherRound
			return TRUE
		else
			return FALSE
		ok

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

	def Add(pOtherNumber)
		This.Update( pvtCalculate("+", pOtherNumber ) )

		#< @FunctionFluentForm

		def AddQ(pOtherNumber)
			This.Add(pOtherNumber)
			return This

		#>

		#< @FunctionPassiveForm

		def Added(pOtherNumber)
			nResult = This.Copy().AddQ(pOtherNumber).NumericValue()
			return nResult

		#>

	def AddMany(paOtherNumbers)
		This.AddManyXT(paOtherNumbers, :ReturnIntermediateResults = FALSE)

		#< @FunctionFluentForm

		def AddManyQ(paOtherNumbers)
			This.AddMany(paOtherNumbers)
			return This

		#>

		#< @FunctionAlternativeForm

		def AddThese(paOtherNumbers)
			This.AddMany(paOtherNumbers)

			def AddTheseQ(paOtherNumbers)
				This.AddThese(paOtherNumbers)
				return This

		#>

		#< @FunctionPassiveForm

		def AddedMany(pOtherNumbers)
			nResult = This.Copy().AddManyQ(pOtherNumbers).NumbericValue()
			return nResult

			def AddedThese(pOtherNumbers)
				return This.AddedMany(pOtherNumbers)

		def ManyAdded(pOtherNumbers)
			return This.AddedMany(pOtherNumbers)

			def TheseAdded(pOtherNumbers)
				return This.ManyAdded(pOtherNumbers)

		#>
	
	def AddManyWithIntermediateResults(paOtherNumbers)
		return This.AddManyXT(paOtherNumbers, :ReturnIntermediateResults = TRUE)

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
		if CheckParams()
			if NOT ( isList(paOtherNumbers) and @IsListOfNumbersOrStrings(paOtherNumbers) )
				StzRaise("Incorrect param type! paOtherNumbers must be a list of numbers or strings.")
			ok
		ok

		bReturnIntermediateResults = FALSE

		if paReturnIntermediateResults[1] = :ReturnIntermediateResults and
		   paReturnIntermediateResults[2] = TRUE

			bReturnIntermediateResults = TRUE
		ok

		nLen = len(paOtherNumbers)
		aIntermediateResults = []

		for i = 1 to nLen
			This.Add(paOtherNumbers[i])
			aIntermediateResults + This.Content()
		next

		if bReturnIntermediateResults
			return aIntermediateResults
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

	def SubStruct(pOtherNumber)

		This.Update( pvtCalculate("-", pOtherNumber ) )

		#< @FunctionFluentForm

		def SubStructQ(pOtherNumber)
			This.SubStruct(pOtherNumber)
			return This
	
		#>

		#< @FunctionAlternativeForms // TODO: Add them anywhere in the library

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

		def Substructed(pOtherNumber)
			nResult = This.Copy().SubstructQ(pOtherNumber).NumericValue()
			return nResult

			def Retrieved(pOtherNumber)
				return This.Substructed(pOtherNumber)

		def Substracted(pOtherNumber)
			return This.SubStructed(pOtherNumber)

		def Subtracted(pOtherNumber)
			return This.SubStructed(pOtherNumber)

		def Subtructed(pOtherNumber)
			return This.SubStructed(pOtherNumber)

		#>

	def SubStructMany(paOtherNumbers)
		#TODO // Add "These" as alternative of "Many"

		This.SubStructManyXT(paOtherNumbers, :ReturnIntermediateResults = FALSE)

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

		def SubstructedMany(pOtherNumbers)
			nResult = This.Copy().SubStructManyQ(pOtherNumbers).Content()
			return nResult

		def SubstractedMany(pOtherNumber)
			return This.SubStructedMany(pOtherNumbers)

		def SubtractedMany(pOtherNumbers)
			return This.SubStructedMany(pOtherNumbers)

		def SubtructedMany(pOtherNumbers)
			return This.SubStructedMany(pOtherNumbers)

		#>


	#--

	def SubStructManyXT(paOtherNumbers, paReturnIntermediateResults)
		#TODO // Add "These" as alternative of "Many"

		if CheckParams()
			if NOT ( isList(paOtherNumbers) and @IsListOfNumbersOrStrings(paOtherNumbers) )
				StzRaise("Incorrect param type! paOtherNumbers must be a list of numbers or strings.")
			ok
		ok
	
		bReturnIntermediateResults = FALSE
		if paReturnIntermediateResults[1] = :ReturnIntermediateResults and
		   paReturnIntermediateResults[2] = TRUE

			bReturnIntermediateResults = TRUE
		ok
	
		nLen = len(paOtherNumbers)
		aIntermediateResults = []

		for i = 1 to nLen
			This.SubStruct(paOtherNumbers[i])
			aIntermediateResults + This.Content()
		next
	
		if bReturnIntermediateResults
			return aIntermediateResults
		ok

		#< @FunctionFluentForm

		def SubStructManyXTQ(paOtherNumbers, paReturnIntermediateResults)
			if paReturnIntermediateResults[1] = FALSE
				This.SubStructManyXT(paOtherNumbers, paReturnIntermediateResults)
				return This

			else
				return stzListOfNumbers( This.SubStructManyXT(paOtherNumbers, paReturnIntermediateResults) )
			ok

		#>

						
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
  	
	  #-------------------------------------------------#
	 #    MULTIPLYING THE NUMBER BY AN OTHER NUMBER    #
	#-------------------------------------------------#

	def MultiplyBy(pOtherNumber)

		if CheckParams()
			if isList(pOtherNumber)
				This.MultiplyByMany(pOtherNumber)
				return
			ok
		ok

		This.Update( pvtCalculate("*", pOtherNumber ) )

		#< @FunctionAlternativeForm

		def MultiplyByQ(pOtherNumber)
			This.MultiplyBy(pOtherNumber)
			return This
	
		#>

		#< @FunctionAlternativeForm

		def Multiply(pOtherNumber)
			if CheckParams()
				if isList(pOtherNumber) and Q(pOtherNumber).IsByOrWithOrUsingNamedParam()
					pOtherNumber = pOtherNumber[2]
				ok
			ok

			This.MultiplyBy(pOtherNumber)

		#>

	def MultipliedBy(pOtherNumber)
		nResult = This.Copy().MultiplyByQ(pOtherNumber).NumericValue()
		return nResult

		def Multiplied(pOtherNumber)
			return This.MultipliedBy(pOtherNumber)

		def Times(pOtherNumber)
			return This.MultipliedBy(pOtherNumber)

	  #----------------------------------------------------#
	 #    MULTIPLYING THE NUMBER BY MANY OTHER NUMBERS    #
	#----------------------------------------------------#

	def MultiplyByMany(paOtherNumbers)
		#TODO: Add "These" as alternative of "Many"

		This.MultiplyByManyXT(paOtherNumbers, :ReturnIntermediateResults = FALSE)

		#< @FunctionFluentForm

		def MultiplyByManyQ(paOtherNumbers)
			This.MultiplyByMany(paOtherNumbers)
			return This
	
		#>
	
		def MultipliedByMany(paOtherNumbers)
			nResult = This.Copy().MultiplyByManyQ(paOtherNumbers).NumericValue()
			return nResult

	def MultiplyByManyXT(paOtherNumbers, paReturnIntermediateResults)
		#TODO // Add "These" as alternative of "Many"

		if CheckParams()
			if NOT ( isList(paOtherNumbers) and @IsListOfNumbersOrStrings(paOtherNumbers) )
				StzRaise("Incorrect param type! paOtherNumbers must be a list of numbers or strings.")
			ok
		ok

		aIntermediateResults = []
	
		bReturnIntermediateResults = FALSE
	
		if paReturnIntermediateResults[1] = :ReturnIntermediateResults and
		   paReturnIntermediateResults[2] = TRUE
	
			bReturnIntermediateResults = TRUE
		ok
	
		nLen = len(paOtherNumbers)
		aIntermediateResults = []

		for i = 1 to nLen
			This.MultiplyBy(paOtherNumbers[i])
			aIntermediateResults + This.Content()
		next
	
		if bReturnIntermediateResults
			return aIntermediateResults
		ok		

	  #----------------#
	 #    DIVISION    #
	#----------------#

	def Divide(pOtherNumber)
		if CheckParams()

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

		def Divided(pOtherNumber)
			nResult = This.Copy().DivideQ(pOtherNumber).NumericValue()
			return nResult

		#>

	def DivideBy(pOtherNumber)
		This.Update( pvtCalculate("/", pOtherNumber ) )

		#< @FunctionFluentForm

		def DivideByQ(pOtherNumber)
			This.DivideBy(pOtherNumber)
			return This

		#>

		#< @FunctionPassiveForm

		def DividedBy(pOtherNumber)
			nResult = This.Copy().DivideByQ(pOtherNumber).NumericValue()
			return nResult

		#>
	
	def DivideByMany(paOtherNumbers)
		#TODO: Add "These" as alternative of "Many"

		This.DivideByManyXT(paOtherNumbers, :ReturnIntermediateResults = FALSE)

		#< @FunctionFluentForm

		def DivideByManyQ(paOtherNumbers)
			This.DivideByMany(paOtherNumbers)
			return This
	
		#>

		def DividedByMany(paOtherNumbers)
			nResult = This.Copy().DivideByManyQ(paOtherNumbers).NumericValue()
			return nResult

	def DivideByManyXT(paOtherNumbers, paReturnIntermediateResults)
		#TODO // Add "These" as alternative of "Many"

		if CheckParams()
			if NOT ( isList(paOtherNumbers) and @IsListOfNumbersOrStrings(paOtherNumbers) )
				StzRaise("Incorrect param type! paOtherNumbers must be a list of numbers or strings.")
			ok
		ok

		aIntermediateResults = []
	
		bReturnIntermediateResults = FALSE
	
		if paReturnIntermediateResults[1] = :ReturnIntermediateResults and
		   paReturnIntermediateResults[2] = TRUE
	
			bReturnIntermediateResults = TRUE
		ok
	
		nLen = len(paOtherNumbers)
		aIntermediateResults = []

		for i = 1 to nLen
			This.DivideBy(paOtherNumbers[i])
			aIntermediateResults + This.Content()
		next
	
		if bReturnIntermediateResults
			return aIntermediateResults
		ok
	
	  #-------------#
	 #    MATHS    #
	#-------------#

	# MODULO

	def Modulo(pOtherNumber)
		return This.pvtCalculate("%", pOtherNumber)

		def ModuloQ(pOtherNumber)
			return new stzNumber(This.Modulo(pOtherNumber))
	
	# POWER

	def Power(pOtherNumber)
		return This.pvtCalculate("^", pOtherNumber)

		def PowerQ(pOtherNumber)
			return new stzNumber(This.Power(pOtherNumber))
	
	# SINE

	def Sine()
		return This.pvtCalculate( "sin", NULL )

		def SineQ()
			return new stzNumber(This.Sine())
	
	# COSINE

	def Cosine()
		return This.pvtCalculate( "cos", NULL )

		def CosineQ()
			return new stzNumber(This.Cosine())
	
	# TANGENT

	def Tangent()
		return This.pvtCalculate( "tan", NULL )
		
		def TangentQ()
			return new stzNumber(This.Tangent())
	
	# COTANGENT

	def Cotangent()
		return This.pvtCalculate( "cotan", NULL )

		def CotangentQ()
			return new stzNumber(This.Cotangent())
	
	# ARCSINE

	def ArcSine()
		return This.pvtCalculate( "asin", NULL )
	
		def ArcSineQ()
			return new stzNumber(This.ArcSine())
	
	# ARCCOSINE

	def ArcCosine()
		return This.pvtCalculate( "acos", NULL )

		def ArcCosineQ()
			return new stzNumber(This.ArcCosine())
	
	# ARCTANGENT

	def ArcTangent()
		return This.pvtCalculate( "atan", NULL )

		def ArcTangentQ()
			return new stzNumber(This.ArcTangent())
	
	# ARCTANGENT2

	def ArcTangent2()
		return This.pvtCalculate( "atan2", NULL )

		def ArcTangent2Q()
			return new stzNumber(This.ArcTangent2())
	
	# SINH

	def HyperbolicSine()
		return This.pvtCalculate( "sinh", NULL )

		def HyperbolicSineQ()
			return new stzNumber(This.HyperbolicSine())
	
	# COSH

	def HyperbolicCosine()
		return This.pvtCalculate( "cosh", NULL )

		def HyperbolicCosineQ()
			return new stzNumber(This.HyperbolicCosine())
	
	# TANH

	def HyperbolicTangent()
		return This.pvtCalculate( "tanh", NULL )

		def HyperbolicTangentQ()
				return new stzNumber(This.HyperbolicTangent())
	
	# EXP

	def Exponential()
		return This.pvtCalculate( "exp", NULL )

		def ExponentialQ()
			return new stzNumber(This.Exponential())
	
	# LOG

	def NaturalLogarithm()
		return This.pvtCalculate( "log", NULL )

		def NaturalLogarithmQ()
			return new stzNumber(This.NaturalLogarithmQ())
	
	# LOG10

	def CommonLogarithm()
		return This.pvtCalculate( "log10", NULL )

		def CommonLogarithmQ()
			return new stzNumber(This.CommonLogarithm())
	
	# ABS

	def Absolute()
		if This.IsInteger()
			n = This.NumericValue()
			if n < 0
				return -n
			else
				return n
			ok
		else
			oStrNumber = new stzString(This.Content())
			if oStrNumber.FirstChar() = "-"
				return oStrNumber.FirstCharRemoved()
			else
				return oStrNumber.Content()
			ok
		ok

		def AbsoluteQ()
			return new stzNumber(This.AbsoluteQ())

		def Abs()
			return This.Absolute()

			def AbsQ()
				return This.AbsoluteQ()
	
	# SQRT

	def SquareRoot()
		return This.pvtCalculate( "sqrt", NULL )

		def SquareRootQ()
			return new stzNumber(This.SquareRoot())
	
	# FACT

	def Factorial()
		return This.pvtCalculate( "fact", NULL )

		def FactorialQ()
				return new stzNumber(This.Factorial())
	
	# PERCENT

	def InPercentage()
		return This.pvtCalculate( "/", 10 ) + "%"

	# SIGMOID

	def Sigmoid()
		return This.pvtCalculate( "sigmoid", NULL )

		def SigmoidQ()
			return new stzNumber(This.Sigmoid())
	
	# DERIVATIVE

	def Derivative(pcFunc)
		return This.pvtCalculate( "derivative", pcdef ) 

		def DerivativeQ(pcFunc)
				return new stzNumber(This.Derivative(pcFunc))
	
	# DERIVATIVE SIGMOID

	def DerivativeSigmoid()
		return This.pvtCalculate( "DerivativeSigmoid", NULL )

		def DerivativeSigmoidQ()
			return new stzNumber(This.DerivativeSigmoid())
	
	# LEAST COMMON MULTIPLE

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

	# GREATEST COMMON DIVIDOR

	def GreatestCommonDividor(pOtherNumber)
		return This.pvtCalculate( "GCD", pOtherNumber)

		def GreatestCommonDividorQ(n)
			return new stzNumber(This.GreatCommonDividor())

		def CommonGreatestDividor(pOtherNumber)
			return This.GreatestCommonDividor(pOtherNumber)
	
	# INVERSE

	def Inverse()
		return This.pvtCalculate( "inverse", NULL )

		def InverseQ()
			return new stzNumber(This.Inverse())
	
	# FACTORS

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
			return This.FactorsQR(:stzList)

		def FactorsQR(pcReturnType)
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
		anFactors = This.Factors()
		nLen = len(anFactors)

		aResult = []
		for i = 1 to nLen
			aResult + [ anFactors[i], This.IntegerPartValue() / anFactors[i] ]
		next

		return aResult

		#< @FunctionFluentForm

		def FactorsXRQ()
			return This.FactorsXTQR(:stzList)

		def FactorsXTQR(pcReturnType)
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

	def PrimeFactors()
		aResult = []

		for n in This.Factors()

			oTempNumber = new stzNumber(n)

			if oTempNumber.IsPrimeNumber()
				aResult + n
			ok
		next

		return aResult


		#< @FunctionFluentForm

		def PrimeFactorsQ()
			return This.PrimeFactorsQR(:stzList)

		def PrimeFactorsQR(pcReturnType)
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
		aResult = []
		for n in This.PrimeFactors()
			aResult + [ n, This.IntegerPartValue() / n ]
		next
		return aResult

		#< @FunctionFluentForm

		def PrimeFactorsXRQ()
			return This.PrimeFactorsXTQR(:stzList)

		def PrimeFactorsXTQR(pcReturnType)
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

	def MostSquareLikeFactors()
		return @MostSquareLikeFactors(This.Content())

		def MSLF()
			return This.MostSquareLikeFactors()

	# MULTIPLES UNTIL

	def NumberOfMultiples(pOtherNumber)
		return len( This.Multiples(pOtherNumber) )

	def NumberOfMultiplesUntil(pOtherNumber)
		return len( This.MultiplesUntil(pOtherNumber) )

		def NumberOfMultiplesUpTo(pOtherNumber)
			return This.NumberOfMultiplesUntil(pOtherNumber)

	def Multiples(pOtherNumber)
		if isList(pOtherNumber) and
		   Q(pOtherNumber).IsOneOfTheseNamedParams([ :Until, :UpTo, :Under ])
			pOtherNumber = pOtherNumber[2]
		ok

		return This.MultiplesUntil(pOtherNumber)

	def MultiplesUntil(pOtherNumber)

		if CheckParams()

			if NOT (isNumber(pOtherNumber) or isString(pOtherNumber))
				StzRaise("Incorrect param type! pOtherNumber must be a number or a string.")
			ok
	
			if isString(pOtherNumber) and
			   NOT Q(pOtherNumber).IsNumberInString()
				StzRaise("Incorrect value! pOtherNumber must be a number in string.")
			ok
		ok

		nOtherNumber = StzNumberQ(pOtherNumber).NumericValue()
		if nOtherNumber <= This.NumericValue()
			StzRaise("Can't proceed! pOtherNumber must be >= your main number.")
		ok

		# Memorizing the current round in the program
		# (actuated by StzDecimals() that you should
		# use instead of the standard Ring decimals()

		nCurrentRound = StzCurrentRound()

		# Getting the round of the other number

		nOtherRound = nCurrentRound
		if isString(pOtherNumber)
			nOtherRound = StzNumberQ(n).Round()
		ok

		# Applying the max between the two rounds
		# (becausse we want the calculation to be
		# as precise as possiblle)

		StzDecimals( Max([ This.Round(), nOtherRound ]) )

		# Doing the job under that round

		bInteger = FALSE
		if This.IsInteger() and Q(pOtherNumber).IsInteger()
			bInteger = TRUE
		ok

		aResult = []
		bContinue = TRUE
		i = 0
		while bContinue
			i++
			n = This.MultipliedBy(i)
			if bInteger
				n = 0+ n
			ok

			if n <= nOtherNumber
				aResult + n
			else
				bContinue = FALSE
			ok
		end

		return aResult

		# Resetting the current round

		StzDecimals( nCurrentRound )

		def MultiplesUntilQ(pOtherNumber)
			return This.MultiplesUntilQR(pOtherNumber, :stzList)

		def MultiplesUntilQR(pOtherNumber, pcReturnType)

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

				anMultiples = This.MultiplesUntil(pOtherNumber)

				anNumbers = []
				for n in anMultiples
					if isString(n)
						anNumbers + ( 0+ n )
					else
						anNumbers + n
					ok
				next

				return new stzListOfNumbers( anNumbers )

			on :stzListOfStrings
				acNumbers = []
				for n in  This.MultiplesUntil(pOtherNumber)
					if isNumber(n)
						acNumbers + ( ""+ n )
					else
						acNumbers + n
					ok
				next

				return new stzListOfNumbers( anNumbers )

			other
				StzRaise("Unssupported return type!")
			off


		def MultiplesUpTo(pOtherNumber)
			return This.MultiplesUntil(pOtherNumber)

		def MultiplesUnder(pOtherNumber)
			return This.MultiplesUntil(pOtherNumber)

	# DIVIDABILITY

	def IsDividableBy(n)
		if CheckParams()
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

		nCurrentRound = StzCurrentRound()

		# Getting the round of the other number

		nOtherRound = nCurrentRound
		if isString(n)
			nOtherRound = StzNumberQ(n).Round()
		ok

		# Applying the max between the two rounds
		# (becausse we want the calculation to be
		# as precise as possiblle)

		StzDecimals( Max([ This.Round(), nOtherRound ]) )

		# Doing the job under that round

		n = StzNumberQ(n).NumericValue()

		oTempList = new stzList( This.Factors() )
		bResult = FALSE

		if oTempList.Contains(n)
			bResult = TRUE
		ok

		# Resetting the current round

		StzDecimals(nCurrentRound)

		# Returning the result

		return bResult

		def IsDivisibleBy(n)
			return This.IsDividableBy(n)

		def CanBeDividedBy(n)
			return This.IsDividableBy(n)
			
	def IsDividorOf(n)	// Main Number and n must be integers!
		oNumber = new stzNumber(n)

		return oNumber.IsDividableBy(This.IntegerPartValue())

	def IntegerPartValue()
		return 0+ This.IntegerPart()

		def IntegerPartNumericValue()
			return This.IntegerPartValue()

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

	def ToStzString()
		return new stzString(This.Content())
	
	# Converting decimal to hex form
	
	def ToHexForm()
		cResult = HexNumberPrefix() + This.ToHexFormWithoutPrefix()
		return cResult

		#< @FunctionFluentForm

		def ToHexFormQ()
			return new stzHexNumber( This.ToHexForm() )

		#>

		#< @FunctionAlternativeForm

		def ToHex()
			return ToHexForm()

			def ToHexQ()
				return new stzHexNumber( This.ToHex() )

		#>

	def ToHexNumber()
		return new stzHexNumber( This.ToHex() )

	def ToUnicodeHexForm()
		return "U+" + This.ToHexFormWithoutPrefix()
	
		#< @FunctionAlternativeForms

		def ToUnicodeHex()
			return ToUnicodeHexForm()

		def ToHexUnicode()
			return ToUnicodeHexForm()

		#>

	def ToHexFormWithoutPrefix()
		cResult = This.IntegerPartToHexForm()

		if This.HasFractionalPart()
			cResult += "." + This.FractionalPartToHexForm()
		ok

		return cResult

		#< @FunctionAlternativeForms

		def ToHexWithoutPrefix()
			return This.ToHexFormWithoutPrefix()

		#>
			
	def IntegerPartToHexForm()
		return UPPER( hex(This.IntegerPartValue()) )

	def FractionalPartToHexForm()
		cFraction = This.FractionalPart()

		def DecimalPartToHexForm()
			return This.FractionalPartToHexForm()
  
	# Converting decimal to binary form

	def ToBinaryForm()
		oConversion = new stzDecimalToBinary(This.Content())
		return oConversion.ToBinaryForm()

		def ToBinary()
			return This.ToBinaryForm()

		def ToBinaryQ()
			return new stzBinaryNumber( This.ToBinaryForm() )

		def ToBinaryNumber()
			return new stzBinaryNumber( This.ToBinaryForm() )
	
	# Converting decimal to octal form

	def IntegerPartToOctalForm()
		aTemp = []
		cOctal = ""
		n = This.IntegerPartValue()

		bAgain = TRUE
		while bAgain
			if floor(n / 8) = 0 bAgain = FALSE ok
			aTemp + (n % 8)
			
			n = floor(n/8)
		end
			
		for i = len(aTemp) to 1 step -1
			cOctal += aTemp[i]
		next

		return This.Sign() + cOctal

	def ToOctalForm()
		return OctalNumberPrefix() + This.ToOctalFormWithoutPrefix()

		def ToOctal()
			return This.ToOctalForm()

		def ToOctalQ()
			return new stzOctalNumber( This.ToOctalForm() ) 

		def ToOctalNumber()
			return new stzOctalNumber( This.ToOctalForm() )
	
	def ToOctalFormWithoutPrefix()
		cResult = This.IntegerPartToOctalForm()

		if This.FractionalPart() != ""
			cResult += "." + This.FractionalPartToOctalForm()
		ok

		return cResult

	// Returns a string containing the equivalent of the interger part
	// in the specified base n (between 2 and 36)
	def IntegerPartToBaseNForm(n)
		if n >= 2 and n <= 36
			oQString = new QString2()
			return oQString.number(This.IntegerValue(),n)

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

	def FromOctalForm(cOctal)
		This.Update( StzOctalNumberQ(cOctal).ToDecimalForm() )

		def FromOctal(cOctal)
			This.FromOctalForm(cOctal)

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
			 
			aStructure = [ :aHundreds , :aThousands , :aMillions , :aBillions , :aTrillions ]
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

		oStzIntegerPart = new stzString(This.IntegerPart())
		oStzFractionalPart = new stzString(This.FractionalPart())

		// Initializing the structure containers and the required variables
		aHundreds  = [ :Units = 0, :Dozens = 0, :Hundreds = 0 ]	cHundreds = ""
		aThousands = [ :Units = 0, :Dozens = 0, :Hundreds = 0 ]	cThousands = ""
		aMillions  = [ :Units = 0, :Dozens = 0, :Hundreds = 0 ]	cMillions = ""
		aBillions  = [ :Units = 0, :Dozens = 0, :Hundreds = 0 ] cBillions = ""
		aTrillions = [ :Units = 0, :Dozens = 0, :Hundreds = 0 ] cTrillions = ""
			
		aStructure = [ :aHundreds = [], :aThousands = [], :aMillions = [], :aBillions = [], :aTrillions = [] ]

		aTemp = oStzIntegerPart.SplitToNPartsQ(3).Reversed()

		switch len(aTemp)
		on 0
			// Nothing

		on 1
			cHundreds  = aTemp[1]

		on 2
			cHundreds  = aTemp[1]
			cThousands = aTemp[2]

		on 3
			cHundreds  = aTemp[1]
			cThousands = aTemp[2]
			cMillions  = aTemp[3]

		on 4
			cHundreds  = aTemp[1]
			cThousands = aTemp[2]
			cMillions  = aTemp[3]
			cBillions  = aTemp[4]

		on 5
			cHundreds  = aTemp[1]
			cThousands = aTemp[2]
			cMillions  = aTemp[3]
			cBillions  = aTemp[4]
			cTrillions = aTemp[5]

		off

		aStructure = [ 	
			:aTrillions = GetMicroStructure(cTrillions),
			:aBillions  = GetMicroStructure(cBillions),
			:aMillions  = GetMicroStructure(cMillions),
			:aThousands = GetMicroStructure(cThousands),
			:aHundreds  = GetMicroStructure(cHundreds)
		]

		return aStructure

	def Structure()
		# Given a number, the function returns its structure in a hashlist
		# taking the following form:
		# 
		# 	aStructure = [ :cHundreds , :cThousands , :cMillions , :cBillions , :cTrillions ]
		# 	where each key contains a string with the relevant number hosted in it.
		#NOTE that the sign is not included in the analysis, but we have it in This.Sign()

		oStzIntegerPart = new stzString(This.IntegerPartWithoutSign())
		oStzFractionalPart = new stzString(This.FractionalPart())

		// Initializing the structure containers and the required variables
		aHundreds  = [ :Units = 0, :Dozens = 0, :Hundreds = 0 ]	cHundreds = ""
		aThousands = [ :Units = 0, :Dozens = 0, :Hundreds = 0 ]	cThousands = ""
		aMillions  = [ :Units = 0, :Dozens = 0, :Hundreds = 0 ]	cMillions = ""
		aBillions  = [ :Units = 0, :Dozens = 0, :Hundreds = 0 ] cBillions = ""
		aTrillions = [ :Units = 0, :Dozens = 0, :Hundreds = 0 ] cTrillions = ""
			
		aStructure = [ :aHundreds = [], :aThousands = [], :aMillions = [], :aBillions = [], :aTrillions = [] ]

		aTemp = oStzIntegerPart.SplitToNPartsQ(3).Reversed()

		switch len(aTemp)
		on 0
			// Nothing

		on 1
			cHundreds  = aTemp[1]

		on 2
			cHundreds  = aTemp[1]
			cThousands = aTemp[2]

		on 3
			cHundreds  = aTemp[1]
			cThousands = aTemp[2]
			cMillions  = aTemp[3]

		on 4
			cHundreds  = aTemp[1]
			cThousands = aTemp[2]
			cMillions  = aTemp[3]
			cBillions  = aTemp[4]

		on 5
			cHundreds  = aTemp[1]
			cThousands = aTemp[2]
			cMillions  = aTemp[3]
			cBillions  = aTemp[4]
			cTrillions = aTemp[5]
		off
					
		cNumber = cTrillions + cBillions + cMillions + cThousands + cHundreds

		// Removing zeros from the left	
		oNumber = new stzNumber(cNumber)
		cNumber = oNumber.RemoveZeros()

		astructure = [ 	
			:cTrillions = cTrillions,
			:cBillions  = cBillions,
			:cMillions  = cMillions,
			:cThousands = cThousands,
			:cHundreds  = cHundreds
		]

		return aStructure

	#-- HUNDREDS --#
	def Hundreds()
		return This.Structure()[ :cHundreds ]		

	def HundredsXT()
		return This.StructureXT()[ :aHundreds ]

	def UnitsInHundreds()
		return This.HundredsXT()[ :Units ]

		def Units()
			return This.UnitsInHundreds()

	def DozensInHundreds()
		return This.HundredsXT()[ :Dozens ]

		def Dozens()
			return This.DozensInHundreds()

	def HundredsInHundreds()
		return This.HundredsXT()[ :Hundreds ]

	def HasHundreds()
		oNumber = new stzNumber(This.Content())
			
		if len(oNumber.IntegerPart()) > 0 and
		   oNumber.NumericValue() != 0

				return TRUE
		else
				return FALSE
		ok

		def ContainsHundreds()
			return This.HasHundreds()

	#-- TOUHSANDS --#
	def Thousands()
		return This.Structure()[ :cThousands ]

	def ThousandsXT()
		return This.StructureXT()[ :aThousands ]

	def UnitsInThousands()
		return This.ThousandsXT()[ :Units ]

	def DozensInThousands()
		return This.ThousandsXT()[ :Dozens ]

	def HundredsInThousands()
		return This.ThousandsXT()[ :Hundreds ]

	def HasThousands()
		oNumber = new stzNumber(This.Content())
			
		if len(oNumber.IntegerPart()) > 3
			return TRUE

		else
			return FALSE
		ok

		def ContainsThousands()
			return This.HasThousands()

	#-- MILLIONS --#
	def Millions()
		return This.Structure()[ :cMillions ]

	def MillionsXT()
		return This.StructureXT()[ :aMillions ]

	def UnitsInMillions()
		return This.MillionsXT()[ :Units ]

	def DozensInMillions()
		return This.MillionsXT()[ :Dozens ]

	def HundredsInMillions()
		return This.MillionsXT()[ :Hundreds ]

	def HasMillions()
		oNumber = new stzNumber(This.Content())
			
		if len(oNumber.IntegerPart()) > 6
			return TRUE

		else
			return FALSE
		ok

		def ContainsMillions()
			return This.HasMillions()

	#-- BILLIONS --#
	def Billions()
		return This.Structure()[ :cBillions ]

	def BillionsXT()
		return This.StructureXT()[ :aBillions ]
			
	def UnitsInBillions()
		return This.BillionsXT()[ :Units ]

	def DozensInBillions()
		return This.BillionsXT()[ :Dozens ]

	def HundredsInBillions()
		return This.BillionsXT()[ :Hundreds ]

	def HasBillions()
		oNumber = new stzNumber(This.Content())
			
		if len(oNumber.IntegerPart()) > 9
			return TRUE
		else
			return FALSE
		ok

		def ContainsBillions()
			return This.HasBillions()

	#-- TRILLIONS --#
	def Trillions()
		return This.Structure()[ :cTrillions ]

	def TrillionsXT()
		return This.StructureXT()[ :aTrillions ]

	def UnitsInTrillions()
		return This.TrillionsXT()[ :Units ]

	def DozensInTrillions()
		return This.TrillionsXT()[ :Dozens ]

	def HundredsInTrillions()
		return This.TrillionsXT()[ :Hundreds ]

	def HasTrillions()
		oNumber = new stzNumber(This.Content())
			
		if len(oNumber.IntegerPart()) > 12
			return TRUE

		else
			return FALSE
		ok

		def ContainsTrillions()
			return This.HasTrillions()

	#-- ALL IN ONCE --#
	def AllUnits()
		return 	[ :InHundreds  = This.UnitsInHundreds(),
			  :InThousands = This.UnitsInThousands(),
			  :InMillions  = This.UnitsInMillions(),
			  :InBillions  = This.UnitsInBillions(),
			  :InTrillions = This.UnitsInTrillions()
			]

	def AllDozens()
		return 	[ :InHundreds  = This.DozensInHundreds(),
			  :InThousands = This.DozensInThousands(),
			  :InMillions  = This.DozensInMillions(),
			  :InBillions  = This.DozensInBillions(),
			  :InTrillions = This.DozensInTrillions()
			]

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

	def ContainsDigits()
		return TRUE

	def Contains(pcDigit)
		return StzStringQ(This.Content()).Contains(pcDigit)

	def ExistsIn(paList)
		return StzListQ(paList).Contains(This.NumericValue())

	def ContainsZeros()
		return This.Contains("0")

		def HasZeros()
			return This.ContainsZeros()

	def ContainsOnes()
		return This.Contains("1")

		def HasOnes()
			return This.ContainsOnes()

	def ContainsSeveral(pcDigit)
		return StzStringQ(This.Content()).NumberOfOccurrence(pcDigit) > 1

		def ContainsMany(pcDigit)
			return This.ContainsSeveral(pcDigit)

		def HasSeveral(pcDigit)
			return This.ContainsSeveral(pcDigit)

		def HasMany(pcDigit)
			return This.ContainsSeveral(pcDigit)

	def ContainsSeveralZeros()
		return This.ContainsSeveral("0")

		def ContainsManyZeros()
			return This.ContainsSeveralZeros()

		def HasSeveralZeros()
			return This.ContainsSeveralZeros()

		def HasManyZeros()
			return This.ContainsSeveralZeros()

	def ContainsSeveralOnes()
		return This.ContainsSeveral("1")

		def ContainsManyOnes()
			return This.ContainsSeveralOnes()

		def HasSeveralOnes()
			return This.ContainsSeveralOnes()

		def HasManyOnes()
			return This.ContainsSeveralOnes()

	def ContainsDozens()
		return This.NumericValue() >= 10

		def ContainsSeveralDozens()
			return This.ContainsDozens()

		def ContainsManyDozens()
			return This.ContainsDozens()

	def ContainsSeveralHundreds()
		return This.NumericValue() >= 200

		def ContainsManyHundreds()
			return This.ContainsSeveralHundreds()

		def HasSeveralHundreds()
			return This.ContainsSeveralHundreds()

		def HasManyHundreds()
			return This.ContainsSeveralHundreds()

	def ContainsSeveralThousands()
		return This.NumericValue() >= 2000

		def ContainsManyThousands()
			return This.ContainsSeveralThousands()

		def HasSeveralThousands()
			return This.ContainsSeveralThousands()

		def HasManyThousands()
			return This.ContainsSeveralThousands()

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

	def ContainsSeveralBillions()
			return This.NumericValue() >= 2_000_000_000

		def ContainsManyBillions()
			return This.ontainsSeveralBillions()

		def ContainsThousandsOfMillions()
			return This.ontainsSeveralBillions()

		def ContainsSeveralThousandsOfMillions()
			return This.ontainsSeveralBillions()

		def ContainsManyThousandsOfMillions()
			return This.ontainsSeveralBillions()	

		#--

		def HasSeveralBillions()
			return This.ContainsSeveralBillions()

		def HasManyBillions()
			return This.ontainsSeveralBillions()

		def HasThousandsOfMillions()
			return This.ContainsBillions()

		def HasSeveralThousandsOfMillions()
			return This.ontainsSeveralBillions()

		def HasManyThousandsOfMillions()
			return This.ontainsSeveralBillions()

	def ContainsTensOfBillions()
		return This.NumericValue() >= 10_000_000_000

		def ContainsSeveralTensOfBillions()
			return This.ContainsTensOfBillions()

		def ContainsManyTensOfBillions()
			return This.ContainsTensOfBillions()

		#--

		def HasTensOfBillions()
			return This.ContainsTensOfBillions()

		def HasSeveralTensOfBillions()
			return This.HasManyTensOfBillions()

		def HasManyTensOfBillions()
			return This.HasManyTensOfBillions()

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

	def ContainsSeveralTrillions()
		return This.NumericValue() >= 2_000_000_000_000

		def ContainsManyTrillions()
			return This.ContainsSeveralTrillions()

		#--

		def HasSeveralTrillions()
			return This.ContainsSeveralTrillions()

		def HasManyTrillions()
			return This.ContainsSeveralTrillions()


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
		cResult = This.Copy().RemoveSpacesQ().Content()
		return cResult

	def RemoveLeadingSpaces()
		This.Update( This.ToStzString().LeadingSpacesRemoved() )

		def RemoveLeadingSpacesQ()
			This.RemoveLeadingSpaces()
			return This

	def LeadingSpacesRemoved()
		cResult = This.Copy().RemoveLeadingSpacesQ().Content()
		return cResult

	def RemoveTrailingSpaces()
		This.Update( This.ToStzString().TrailingSpacesRemoved() )

		def RemoveTrailingSpacesQ()
			This.RemoveTrailingSpaces()
			return This

	def TrailingSpacesRemoved()
		cResult = This.Copy().RemoveTrailingSpacesQ().Content()
		return cResult

	  #---------------------------------#
	 #    REMOVING ZEROS FROM NUMBER   #
	#---------------------------------#

	def RemoveZerosFromLeft()
		oStzStr = This.ToStzString()

		if oStzStr.RepeatedLeadingcharIs("0")
			This.Update( oStzStr.RemoveThisRepeatedLeadingCharQ("0").Content() )
		ok

		if This.IsReal()
			if oStzStr.RepeatedTrailingCharIs("0")
				This.Update( oStzStr.RemoveRepeatedTrailingCharQ("0").Content() )
			ok
		ok

	def RemoveZerosFromRight()
		oStzStr = This.ToStzString()

		if oStzStr.RepeatedTrailingcharIs("0") and This.IsReal()
			This.Update( oStzStr.RemoveThisRepeatedtrailingCharQ("0").Content() )
		ok

	def RemoveZeros()
		oStzStr = This.ToStzString()

		if oStzStr.RepeatedTrailingcharIs("0")
			This.Update( oStzStr.RemoveThisRepeatedtrailingCharQ("0").Content() )
		ok

		if This.IsReal()
			if oStzStr.RepeatedTrailingCharIs("0")
				This.Update( oStzStr.RemoveRepeatedTrailingCharQ("0").Content() )
			ok
		ok
		

	def ZerosRemoved()
		cResult = This.Copy().RemoveZerosQ().Content()
		return cResult

	  #------------------#
	 #    FORMATTING    #
	#------------------#

	def ApplyFormatXT(paFormat)	# TODO: Add formatting strings like +99 999.99%

		# Setting default configs

			# Precision
			bRestrictFractionalPart = FALSE
			nNumberOfDigitsInFractionalPart = 0
			bRoundItWhenRestricted = FALSE
			
			# Round
			bApplyRound = FALSE
			nRoundTo = 0
			
			# Alignment
			bApplyAlignment = FALSE

			nWidth = 0
			cFillBlanksWith = " "
			
			cAlignTo = :Left
			bFixPrefixToLeft = FALSE
			bFixSuffixToRight = FALSE
				
			# Sign
			bShowSign = TRUE
			bPutNegativeBetweenParentheses = FALSE
			
			# Prefix, separators, and suffix
			cPrefix = ""
			
			cThousandsSeparator = "."

			cFractionalSeparator = ","
			
			cSuffix = NULL
			
			# Conversion
			bToPercentage = FALSE
			bToScientificNotation = FALSE
			
			bToHex = FALSE
			bToBinary = FALSE
			bToOctal = FALSE
			nToBase = 10
			
			bToIndian = FALSE
			bToRoman = FALSE

		# Reading provided configs

			# Precision

			if paFormat[ :RestrictFractionalPart ] != NULL
				bRestrictFractionalPart = paFormat[ :RestrictFractionalPart ]
			ok

			if paFormat[ :NumberOfDigitsInFractionalPart ] != NULL
				nNumberOfDigitsInFractionalPart = paFormat[ :NumberOfDigitsInFractionalPart ]
			ok

			if paFormat[ :RoundItWhenRestricted ] != NULL
				bRoundItWhenRestricted = paFormat[ :RoundItWhenRestricted ]
			ok
		
			# Round

			if paFormat[ :ApplyRound ] != NULL
				bApplyRound = paFormat[ :ApplyRound ]
			ok

			if paFormat[ :RoundTo ] != NULL
				nRoundTo = paFormat[ :RoundTo ]
			ok
			
			# Alignment
				
			if paFormat[ :ApplyAlignment ] != NULL
				bApplyAlignment = paFormat[ :ApplyAlignment ]
			ok

			if paFormat[ :Width ] != NULL
				nWidth = paFormat[ :Width ]
			ok

			if paFormat[ :FillBlanksWith ]
				cFillBlanksWith = paFormat[ :FillBlanksWith ]
			ok

			if paFormat[ :AlignTo ]			
				cAlignTo = paFormat[ :AlignTo ]
			ok

			if paFormat[ :FixPrefixToLeft ]
				bFixPrefixToLeft = paFormat[ :FixPrefixToLeft ]
			ok

			if paFormat[ :FixSuffixToRight ]
				bFixSuffixToRight = paFormat[ :FixSuffixToRight ]
			ok
				
			# Sign

			if paFormat[ :ShowSign ]
				bShowSign = paFormat[ :ShowSign ]
			ok

			if paFormat[ :PutNegativeBetweenParentheses ]
				bPutNegativeBetweenParentheses = paFormat[ :PutNegativeBetweenParentheses ]
			ok
			
			# Prefix, separators, and suffix

			if paFormat[ :Prefix ]
				cPrefix = paFormat[ :Prefix ]
			ok
			
			if paFormat[ :ThousandsSeparator ]
				cThousandsSeparator = paFormat[ :ThousandsSeparator ]
			ok

			if paFormat[ :FractionalSeparator ]
				cFractionalSeparator = paFormat[ :FractionalSeparator ]
			ok
			
			if paFormat[ :Suffix ]
				cSuffix = paFormat[ :Suffix ]
			ok
			
			# Conversion

			if paFormat[ :ToPercentage ]
				bToPercentage = paFormat[ :ToPercentage ]
			ok

			if paFormat[ :ToScientificNotation ]
				bToScientificNotation = paFormat[ :ToScientificNotation ]
			ok

			if paFormat[ :ToHex ]
				bToHex = paFormat[ :ToHex ]
			ok

			if paFormat[ :ToBinary ]
				bToBinary = paFormat[ :ToBinary ]
			ok

			if paFormat[ :ToOctal ]
				bToOctal = paFormat[ :ToOctal ]
			ok

			if paFormat[ :ToBase ]
				nToBase = paFormat[ :ToBase ]
			ok
			
			if paFormat[ :ToIndian ]
				bToIndian = paFormat[ :ToIndian ]
			ok

			if paFormat[ :ToRoman ]
				bToRoman = paFormat[ :ToRoman ]
			ok

		# Computing the required formatting
	
		cFormattedNumber = ""
		cIntegerPart = This.IntegerPartWithoutSign()
		cFractionalPart = ""

		# Managing precision by computing the fractional part

		if bRestrictFractionalPart = FALSE
			cFractionalPart = This.FractionalPartWithoutDotZero()
		else
			cCurrentFractionalPart = This.FractionalPartWithoutDotZero()
				
			cFractionalPart = ""
			for i = 1 to nNumberOfDigitsInFractionalPart
				cFractionalPart += cCurrentFractionalPart[i]
			next

			if bRoundItWhenRestricted = TRUE

				# Memorise the active round
				nCurrentRound = GetActiveRound()

				# Setting the rounding system to the number of restricted digits
				decimals(nNumberOfDigitsInFractionalPart)

				# Composing a dummy number with the restricted fraction part
				cTempNumber = "0." + cFractionalPart

				# Rounding that number
				nTempNumber = 0+ cTempNumber
				# Saving the rounded number in a string
				cTempNumber = ""+ nTempNumber

				# Reading the rounded fraction part
				cFractionalPart = ""
				for i = ring_find(cTemNumber, ".") + 1 to len(cTempNumber)
					cFractionalPart += cTempNumber[i]
				next
			ok
		ok

		# Managing Sign
			
		if bShowSign and This.Sign() = NULL
			cFormattedNumber += "+"
		ok

		if This.Sign() = "-"
				
			if NOT bPutNegativeBetweenParentheses
				cFormattedNumber += "-"
			else
				cFormattedNumber += "("
			ok	
		ok

		# Managing prefix

		if cPrefix != NULL
			cFormattedNumber += cPrefix
		ok

		# Managing separators

		if This.Trillions() != ""
			cFormattedNumber += This.Trillions() + cThousandsSeparator
		ok

		if This.Billions() != ""
			cFormattedNumber += This.Billions() + cThousandsSeparator
		ok

		if This.Millions() != ""
			cFormattedNumber += This.Millions() + cThousandsSeparator
		ok

		if This.Thousands() != ""
			cFormattedNumber += This.Thousands() + cThousandsSeparator
		ok

		if This.Hundreds() != ""
			cFormattedNumber += This.Hundreds()
		ok

		# Defining fractional part

		cCurrentFractionalPart = This.FractionalPartWithoutZeroDot()
		nCurrentNumberOfDigitsInFractionalPart = len(cCurrentFractionalPart)

		cNewFractionalPart = ""

		if nNumberOfDigitsInFractionalPart <= nCurrentNumberOfDigitsInFractionalPart
			for i = 1 to nNumberOfDigitsInFractionalPart
				cNewFractionalPart += cCurrentFractionalPart[i]
			next

		else
			nDiff = nNumberOfDigitsInFractionalPart - nCurrentNumberOfDigitsInFractionalPart

			for i = 1 to nDiff
				cNewFractionalPart += "0"
			next
		ok

		# Managing round

		cFractionalPart = cNewFractionalPart

		if NOT bRounded #TODO // review the round() mechanism! #DONE
			if cFractionalPart != ""
				cFormattedNumber += (cFractionalSep + cFractionalPart)
			ok
		else
			oTempNumber = new stzNumber(This.RoundTo(nRound))

			if oTempNumber.FractionalPartWithoutDotZero() != NULL

				cFormattedNumber += cFractionalSep

				if nNumberOfDigitsInFractionalPart <= len(oTempNumber.FractionalPartWithoutDotZero())
					for i = 1 to nNumberOfDigitsInFractionalPart
						cFormattedNumber += oTempNumber.FractionalPartWithoutDotZero()[i]
					next

				else 
					nDiff = nNumberOfDigitsInFractionalPart - len(oTempNumber.FractionalPartWithoutDotZero())
		
					for i = 1 to nDiff
						cFormattedNumber += "0"
					next
				ok				
					
			ok
		ok

		# Managing suffix

		if cSuffix != NULL
			cFormattedNumber += cSuffix
		ok

		# Adding the closing parenthese if required
		if bPutNegativeBetweenParentheses
			cFormattedNumber += ")"
		ok

		return cFormattedNumber

		oNumber = This
		if bPercent = TRUE
			cNumber = oNumber.InPercentage()
			oNumber = new stzNumber(cNumber)
		ok
	
		cNumber = cPrefix
		if bShowSign
			cSign = ""

			if This.IsPositive()
				cSign = "+"

			but This.IsNegative()
					cSign = "-"

			but This.IsZero()
					cSign = ""
			ok

			cNumber += cSign
		ok

		if oNumber.Trillions() != ""
			cNumber += oNumber.Trillions() + cThousandsSep
		ok

		if oNumber.Billions() != ""
			cNumber += oNumber.Billions() + cThousandsSep
		ok

		if oNumber.Millions() != ""
			cNumber += oNumber.Millions() + cThousandsSep
		ok

		if oNumber.Thousands() != ""
			cNumber += oNumber.Thousands() + cThousandsSep
		ok

		if oNumber.Hundreds() != ""
			cNumber += oNumber.Hundreds()
		ok

		if oNumber.FractionalPart() != ""
			cNumber += cFractionalSep + oNumber.FractionalPartWithoutDotZero()
		ok

		if bPercent = TRUE
			cNumber += "%"
		ok

		return cNumber
			
	def SetDefaultFormat() // TODO
		StzRaise("Unsupported feature in this version!")

	def ApplyLocale(pcLocale) // TODO
		StzRaise("Unsupported feature in this version!")

	  #-----------------------------#
	 #     OPERATORS OVERLOADING   #
	#-----------------------------#

	#TODO // Operators should carry same semantics in all classes...
	#TODO // Make a request to Mahmoud to enable multichar operators in Ring

	def operator (pOp, pValue)

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
				aResult = Q( This.DivideByMany(pValue.Content()) )
				return aResult
		
			ok

		but pOp = "^" or pOp = "^^"
			if @IsStzNumber(pValue) or
			   (@IsStzString(pValue) and Q(pValue).IsNumberInString())

				
				cPower = This.Power()
				This.UpdateWith(cPower)

			else

				return This.Power(pValue)
			ok

		but pOp = "%"
			return This.Modulo(pValue)

		but pOp = "="
			if @IsStzObject(pValue)
				return pValue
			else
				return This.IsEqualTo(pValue)
			ok

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

		but pOp = "++" #TODO: check if it works! (++ is reserved by Ring)
			return This.NextNumber()

		but pOp = "--" #TODO: check if it works! (-- is reserved by Ring)
			return This.PreviousNumber()

		but pOp = "[]"
			# Supporting external Python syntax:
				# In Pyhton: 345 // 100 #--> 3
				# In Ring with Softanza:
				# ? Q(345)['// 100'] #--> 3

			if isString(pValue) and Q(pValue).StartsWith("//") 
				oStr = new stzString(pValue)
				nLen = oStr.NumberOfChars()
				cRemainingPart = oStr.SectionQ(3, nLen).Trimmed()

				if Q(cRemainingPart).IsNumberInString()
					n = 0+ cRemainingPart
					nResult = floor( This.NumbericValue() / n )
					#NOTE this a misspelled form of NumericValue()!

					return nResult
				ok

			ok

			return This.Content()[pValue]

		ok

	  #--------------------------------#
	 #    USUED FOR NATURAL-CODING    #
	#--------------------------------#

	def IsStzNumber()
		return TRUE

	def stzType()
		return :stzNumber

	#--- ITEM
	
	def IsItem()
		return TRUE
	
	def IsItemOf(paList)
		return StzListQ(paList).Contains(This.NumericValue())
		
		def AsAnItemOf(paList)
			return This.IsItemOf(paList)
		
	def IsItemIn(paList)
		return This.IsItemOf(paList)
		
		def IsAnItemIn(paList)
			return This.IsItemOf(paList)

	#--- MEMEBER

	def IsMember()
		return TRUE
	
	def IsMemberOf(paList)
		return StzListQ(paList).Contains(This.Content())
		
		def AsAMemberOf(paList)
			return This.IsMemberOf(paList)
		
	def IsMemberIn(paList)
		return This.IsMemberOf(paList)
		
			def IsAMemberIn(paList)
				return This.IsMemberOf(paList)
	
	#--- NUMBER
	
	def IsANumber()
		return TRUE

		def IsNotANumber()
			return FALSE

	def IsAString()
		return FALSE

		def IsNotAString()
			return TRUE

	def IsAList()
		return FALSE

		def IsNotAList()
			return TRUE

	def IsAnObject()
		return TRUE

		def IsAObject()
			return TRUE

		def IsNotAnObject()
			return TRUE

	def IsNumberOf(paList)
		return This.IsItemOf(paList)
	
		def IsANumberOf(paList)
			return This.IsNumberOf(paList)
		
	def IsNumberIn(paList)
		return This.IsNumberOf(paList)
	
		def IsANumberIn(paList)
			return This.IsNumberOf(paList)

	def IsOneOfThese(paList)
		return This.IsItemOf(paList)

		def IsNotOneOfThese(paList)
			return NOT This.IsOneOfThese(paList)
	
	#--- STRING
	
	def IsLetter()
		return FALSE
	
	def IsALetter()
		return FALSE
	
	def IsLetterOf(pStrOrListOfChars)
		return FALSE
	
		def IsALetterOf(pcStr)
			return FALSE
		
	def IsLetterIn(pcStr)
		return FALSE
	
		def IsALetterIn(pcStr)
			return FALSE
	
	def IsCharOf(pStrOrListOfChars)
		return FALSE
	
		def IsACharOf(pcStr)
			return FALSE
	
	def IsCharIn(pcStr)
		return FALSE
	
		def IsACharIn(pcStr)
			return FALSE
	
	  #------------------------------------------#
	 #   STRINGIFY(), TOSTRING(), AND TOCODE()  #
	#------------------------------------------#

	def Stringify()
		# Do nithing, the object is naturally stringified
		# becauses it contains its value always as a string

		def StringifyQ()
			return new stzString( This.StringValue() )

	def Stringified()
		return This.StringValue()

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

	def HasSameTypeAs(p)
		return isNumber(p)

	def UpTo(pnOtherNumber)
		if pnOtherNumber > This.Value()
			anResult = This.Value() : pnOtherNumber
			return anResult
		ok
	
	def DownTo(pnOtherNumber)
		if This.Value() > pnOtherNumber
			anResult = This.Value() : pnOtherNumber
			return anResult
		ok

	# Swapping the content of the stzNumber with an other stzNumber

	def SwapWith(pOtherStzNumber)

		if CheckParams()

			if NOT @IsStzNumber(pOtherStzNumber)
				StzRaise("Incorrect param type! pOtherStzNumber must be a stzNumber object.")
			ok
	
		ok

		nThis = This.Content()
		nOther = pOtherStzNumber.Content()

		This.UpdateWith(nOther)
		pOtherStzNumber.UpdateWith(nThis)


		def SwapWithQ(pOtherStzNumber)
			This.SwapWith(pOtherStzNumber)
			return This

		def SwapContentWith(pOtherStzNumber)
			This.SwapWith(pOtherStzNumber)

			def SwapContentWithQ(pOtherStzNumber)
				return This.SwapWithQ(pOtherStzNumber)

	def LCM(pOtherNumber)
		return pvtCalculate("LCM", pOtherNumber)


	def Methods()
		return ring_methods(This)

	def Attributes()
		return ring_attributes(This)

	def ClassName()
		return "stznumber"

		def StzClassName()
			return This.ClassName()

		def StzClass()
			return This.ClassName()

	def IsNamedObject()
		return FALSE

	def HowMany(n)
		if isNumber(n)
			n = "" + n
		ok

		if NOT isString(n)
			StzRaise("Incorrect param type! n must be a number or string.")
		ok
		
		nResult = This.ToStzString().HowMany(n)
		return nResult

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
		n1 = This.NumericValue()
		if isString(pOtherNumber)
			n2 = StringToNumber(pOtherNumber)
		else
			n2 = pOtherNumber
		ok
	

		# Then, calculation is made and result is hosted inside
		# the nResult variable
		switch pcOperation
		on "+"
			nResult = n1 + n2

		on "-"
			nResult = n1 - n2
	
		on "*"
			nResult = n1 * n2
	
		on "/"
			nResult = n1 / n2
	
		on "%"
			oTemp1 = new stzNumber(n1)
			oTemp2 = new stzNumber(n2)

			if oTemp1.IsInteger() and oTemp2.IsInteger()
				nResult = n1 % n2
			else
				StzRaise("Can't calculate the modulo. The two numbers must be integers!")
			ok
	
		on "^"
			nResult = ring_pow(n1, n2)
	
		on "sin"
			nResult = ring_sin(n1)
	
		on "cos"
			nResult = ring_cos(n1)
	
		on "tan"
			nResult = ring_tan(n1)
	
		on "cotan"
			nResult = 1 / ring_tan(n1)
	
		on "asin"
			nResult = ring_asin(n1)
	
		on "acos"
			nResult = ring_acos(n1)
	
		on "atan2"
			nResult = ring_atan2(n1)
	
		on "sinh"
			nResult = ring_sinh(n1)
	
		on "cosh"
			nResult = ring_cosh(n1)
	
		on "tanh"
			nResult = ring_tanhh(n1)
	
		on "exp"
			nResult = ring_exp(n1)
	
		on "log"
			nResult = ring_log(n1)
	
		on "log10"
			nResult = ring_log10(n1)
	
		on "fabs"
			nResult = fabs(n1)

		on "sigmoid"
			nResult = 1 / (1 + ring_exp(-n1))
	
		on "DerivativeSigmoid"
			nSigmoid = 1 / (1 + ring_exp(-n1))
			nResult = nSigmoid * ( 1 - nSigmoid)

		on "LCM"
			nResult = ring_LCM(n1, n2)

		on "GCD"
			nResult = ring_GCD(n1, n2)

		on "inverse"
			nResult = 1 / n1

		# Special case: the result is a list of integers!
		#--> Nothing to round: return the list of factors directly
		on "factors"
			return ring_factors(n1)		

		off

		/*
		Now, and before it is returned back, nResult must be put in
		a string to preserve the round expressed in its effective
		round and hosted in a whatever the active round is in
		the program (made using decimals())
		*/

		nCurrentRound = StzCurrentRound()
		StzDecimals(This.Round())
		cResult = ""+ nResult
		StzDecimals(nCurrentRound)

		return cResult
