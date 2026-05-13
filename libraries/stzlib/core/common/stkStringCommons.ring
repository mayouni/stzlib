#----------------------------------#
#  COMMON FOR ALL STRING CLASSES   #
#----------------------------------#

func IsLetter(c)
	if len(c) != 1
		return FALSE
	ok
	n = ascii(c)
	if (n >= 65 and n <= 90) or (n >= 97 and n <= 122)
		return TRUE
	ok
	return FALSE

	func @IsLetter(c)
		return IsLetter(c)

func IsDigit(c)
	if len(c) != 1
		return FALSE
	ok
	n = ascii(c)
	return (n >= 48 and n <= 57)

	func @IsDigit(c)
		return IsDigit(c)

func IsUpperCase(c)
	if len(c) != 1
		return FALSE
	ok
	n = ascii(c)
	return (n >= 65 and n <= 90)

	func @IsUpperCase(c)
		return IsUpperCase(c)

func IsLowerCase(c)
	if len(c) != 1
		return FALSE
	ok
	n = ascii(c)
	return (n >= 97 and n <= 122)

	func @IsLowerCase(c)
		return IsLowerCase(c)

func StringIsEmpty(str)
	return (len(str) = 0)

func StringRepeat(str, n)
	cResult = ""
	for i = 1 to n
		cResult += str
	next
	return cResult

	func @StringRepeat(str, n)
		return StringRepeat(str, n)

func StringReverse(str)
	cResult = ""
	for i = len(str) to 1 step -1
		cResult += str[i]
	next
	return cResult

	func @StringReverse(str)
		return StringReverse(str)
