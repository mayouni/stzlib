# Set of functions and classes made to make it easy porting code
# from external languages in Ring

# The idea is to find a solution to a problem on the internet in other langauge,
# paste the code in Ring, and do little changes to get a computable Ring code

# See examples in stzExtLang.ring file

console = new console

func print(str)
	? str

	func echo(str)
		print(str)

	func WriteLine(str)
		print(str)

func $(str) // C#
	return Interpoltate(str) // Ring (SoftanzaLib)
	# NOTE the method we used here is misspelled. Normally we
	# should write it correctly as "Interpolate(str)". But I left
	# as is to show how Softanza can be permissive to spelling
	# errors when you are under time pressure in writing code ;)

	func f(str) // Python
		return Interpoltate(str)

class IntObject
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
	
