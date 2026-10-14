# Functions and classes for porting C# code to Ring
int = new IntObject

func $(str)
	if isList(str) and ( Q(str).IsPair() or @IsHashList(str) )
		VrVl(str)
	but isString(str) and Q(str).ContainsSubStringsBoundedBy([ "{", "}" ])
		return Interpolate(str)
	else
		return v(str)
	ok

func $$(cVarName)
	if isString(cVarName)
		return v(v(cVarName))
	else
		StzRaise("Syntax error!")
	ok
	func vv(cVarName)
		return v(v(cVarName))

# Holds the limits of a whole number the way C# int.MinValue and int.MaxValue name them, for porting C# code to Ring.
#
# The global int is one of these. The limits are the library's calculable-integer limits, 15 nines,
# and they come back as text with underscores, so they print well and do not compare. Build one
# without parentheses: new IntObject() raises R3.
#
#   receiver   o1 = new IntObject
#   example    ? o1.getMaxValue()
#              #--> 999_999_999_999_999
#              ? o1.getMinValue()
#              #--> -999_999_999_999_999
#   see        RingMaxIntegerXT, RingMinIntegerXT, console
class IntObject
	MinValue
	MaxValue
	
	# Returns the smallest whole number that Ring can compute with exactly, written with underscores.
	#
	#   returns    a text such as -999_999_999_999_999, not a number
	#   note       the value is the library's calculable limit, not the 32-bit limit of a C# int
	#   warning    the answer is a text: comparing it with a number or adding to it raises R41
	#              (Invalid numeric string) or joins text; convert it with number() after removing
	#              the underscores
	#   see        getMaxValue
	def getMinValue()
		return RingMinIntegerXT()
	# Returns the largest whole number that Ring can compute with exactly, written with underscores.
	#
	#   returns    a text such as 999_999_999_999_999, not a number
	#   note       the value is the library's calculable limit, not the 32-bit limit of a C# int
	#   warning    the answer is a text: comparing it with a number raises R41 (Invalid numeric
	#              string) and adding 1 joins text
	#   see        getMinValue
	def getMaxValue()
		return RingMaxIntegerXT()
