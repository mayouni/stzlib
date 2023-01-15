# Set of functions and classes made to make it easy porting code
# from external languages in Ring

console = new console

func print(str)
	? str

	func echo(str)
		print(str)

class console
	def log(str)
		? str
