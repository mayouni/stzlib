# Set of functions and classes made to make it easy porting code
# from external languages in Ring

# The idea is to find a solution to a problem on the internet in other language,
# paste the code in Ring, and do little changes to get a computable Ring code

# See examples in stzExtLang.ring file


  ///////////////////
 ///  VARIABLES  ///
///////////////////

None = ""

  ///////////////////
 ///  FUNCTIONS  ///
///////////////////

func iif(pCondition, pTrue, pFalse)

	if CheckParams()

		if NOT ( isNumber(pCondition) or isString(pCondition) or isList(pCondition) )
			StzRaise("Incorrect param type! pCondition must be a number, a string, or a list of strings.")
		ok

		if isList(pCondition) and StzListQ(pcondition).IsItNamedParam()
			cCondition = cCondition[2]
		ok

		if isList(pTrue) and StzListQ(pTrue).IsSayOrReturnNamedParam()
			pTrue = pTrue[2]
		ok

		if isList(pFalse) and StzListQ(pFalse).IsElseOrOtherwiseNamedParam()
			pFalse = pFalse[2]
		ok

	ok

	if isNumber(pCondition)

		if pCondition = 1
			return pTrue
		else
			return pFalse
		ok

	ok

	# pCondition is a string

	cCode = 'bOk = (' + cCondition + ')'

	eval(cCode)

	if bOk
		return pTrue
	else
		return pFalse
	ok

	func @if(cCondition, pTrue, pFalse)
		return iif(cCondition, pTrue, pFalse)

	func iff(cCondition, pTrue, pFalse)
		return iif(cCondition, pTrue, pFalse)

func Length(p)
	return len(p)

	func @Length(p)
		return len(p)

class console
	def log(str)
		? str

	def WriteLine(str)
		? str
