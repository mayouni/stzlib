# Set of functions and classes made to make it easy porting code
# from external languages in Ring

# The idea is to find a solution to a problem on the internet in other langauge,
# paste the code in Ring, and do little changes to get a computable Ring code

# See examples in stzExtLang.ring file

# TODO: Organize this file by language

  ///////////////////
 ///  VARIABLES  ///
///////////////////

console = new console
_aTempVars = []
None = NULL

  ///////////////////
 ///  FUNCTIONS  ///
///////////////////


func Vr(pacVars)

	if NOT ( isList(pacVars) and Q(pacVars).IsListOfStrings() )
		StzRaise("Incorrect param type! pacVars must be a list of strings.")
	ok

	_aTempVars = []
	nLen = len(pacVars)

	for i = 1 to nLen

		_aTempVars + [ pacVars[i], NULL ]

		oHash = StzHashListQ(_aVars)
		n = oHash.FindKey(pacVars[i])
		if n = 0
			_aVars + [ pacVars[i], NULL ]

		else
			_aVars[n][2] = []
		ok
	next


func Vl(paVals)
	if len(_aTempVars) = 0
		return
	ok

	if isString(paVals)
		oHash = new stzHashList(_aTempVars)
		n = oHash.FindKey(paVals)
		if n > 0
			return _aTempVars[n][2]
		else
			return
		ok
	ok

	if NOT isList(paVals)
		StzRaise("Incorrect param type! pacVals must be a list of strings.")
	ok

	nLen = Min([ len(_aTempVars), len(paVals) ])

	oHash = new stzHashList(_aVars)

	for i = 1 to nLen

		_aTempVars[i][2] = paVals[i]
		n = oHash.FindKey(_aTempVars[i][1]) // ring_find(_aVars, _aTempVars[i][1])
		if n > 0
			_aVars[n][2] = paVals[i]
		else
			_aVars + [ _aTempVars[i][1], paVals[i] ]
		ok
	next


func range(p) # Python

	if isNumber(p)
		# Example: range(3) #--> [ 0, 1, 2 ]
		aResult = 0 : (p - 1)

	but isList(p)
		if Q(p).IsListOfNumbers() and len(p) = 3
			# Example: range(-3, 3+1, 2) #--> [ -3, -1, 1, 3 ]
			aResult = []

			for i = p[1] to p[2]-1 step p[3]
				aResult + i
			next
		ok

	else
		StzRaise("Unsupported syntax!")
	ok

	return aResult

func print(str)
	? str

	func echo(str)
		print(str)

	func WriteLine(str)
		print(str)

func $(str) // C#
	return Interpoltate(@@(str)) // Ring (SoftanzaLib)
	# NOTE the method we used here is misspelled. Normally we
	# should write it correctly as "Interpolate(str)". But I left
	# as is to show how Softanza can be permissive to spelling
	# errors when you are under time pressure in writing code ;)

	func f(str) // Python
		return Interpoltate(@@(str))


  /////////////////
 ///  CLASSES  ///
/////////////////

class IntObject // C#
	MinValue
	MaxValue
	
	def getMinValue()
		return RingMinIntegerXT()

	def getMaxValue()
		return RingMaxIntegerXT()

class console // JS, C#, Java
	def log(str)
		? str

	def WriteLine(str)
		? str
	
