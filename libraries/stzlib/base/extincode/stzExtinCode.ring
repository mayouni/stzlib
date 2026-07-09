# Set of functions and classes made to make it easy porting code
# from external languages in Ring

# The idea is to find a solution to a problem on the internet in other language,
# paste the code in Ring, and do little changes to get a computable Ring code

# See examples in stzExtLang.ring file


  ///////////////////
 ///  VARIABLES  ///
///////////////////

_None_ = ""
_Nothing_ = ""

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

class console
	def log(str)
		? str

	def WriteLine(str)
		? str
