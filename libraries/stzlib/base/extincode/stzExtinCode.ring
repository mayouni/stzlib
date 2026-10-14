# Set of functions and classes made to make it easy porting code
# from external languages in Ring

# The idea is to find a solution to a problem on the internet in other language,
# paste the code in Ring, and do little changes to get a computable Ring code

# See examples in stzExtLang.ring file


  ///////////////////
 ///  VARIABLES  ///
///////////////////

None = ""
Nothing = ""

  ///////////////////
 ///  FUNCTIONS  ///
///////////////////

func iif(pCondition, pTrue, pFalse)

	if CheckParams()

		if NOT ( isNumber(pCondition) or isString(pCondition) or isList(pCondition) )
			StzRaise("Incorrect param type! pCondition must be a number, a string, or a list of strings.")
		ok

		# Was `IsItNamedParamList(pcondition)` -> R24 undefined
		# (typo for pCondition). And the unwrap then did
		# `cCondition = cCondition[2]` referencing two undefined
		# variables. Fixed both.
		if isList(pCondition) and IsItNamedParamList(pCondition)
			pCondition = pCondition[2]
		ok

		if isList(pTrue) and IsSayOrReturnNamedParamList(pTrue)
			pTrue = pTrue[2]
		ok

		if isList(pFalse) and IsElseOrOtherwiseNamedParamList(pFalse)
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

	# pCondition is a string -- was `cCondition` (undefined). The
	# whole eval was unreachable; iif("x = 1", ...) crashed.
	_cCode_ = '_bOk_ = (' + pCondition + ')'

	eval(_cCode_)

	if _bOk_
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

# Prints a value on its own line, so that C# console.log and Console.WriteLine calls port to Ring unchanged.
#
# It has two methods, log and WriteLine, which do the same. A list prints one item per line. Build
# it as new console.
#
#   receiver   o1 = new console
#   example    o1.log("hello")
#              #--> hello
#              o1.WriteLine(42)
#              #--> 42
#   see        IntObject, say
class console
	# Prints the value on its own line, as the C# call of the same name does.
	#
	#   str        the value to print
	#   returns    nothing; it prints
	#   see        WriteLine
	def log(str)
		? str

	# Prints the value on its own line, as the C# call of the same name does.
	#
	#   str        the value to print
	#   returns    nothing; it prints
	#   see        log
	def WriteLine(str)
		? str
