# Set of functions and classes made to make it easy porting code
# from external languages in Ring

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

class console // JS, C#, Java
	def log(str)
		? str

	def WriteLine(str)
		? str
