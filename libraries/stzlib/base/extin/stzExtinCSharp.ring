# Functions and classes for porting C# code to Ring
int = new IntObject

func $(str)
	if isList(str) and ( Q(str).IsPair() or Q(str).IsHashList() )
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

class IntObject
	MinValue
	MaxValue
	
	def getMinValue()
		return RingMinIntegerXT()
	def getMaxValue()
		return RingMaxIntegerXT()
