func XJl()
	return new stzJuliaCode

	func Jl()
		return new stzJuliaCode

class stzJuliaCode from stzExterCode
	@ojlCode = new stzExterCode(:Julia)

	# Initializing the external code

	def SetCode(pcJuliaCode)
		@ojlCode.setCode(pcJuliaCode)

		def @(pcJuliaCode)
			This.SetCode(pcJuliaCode)

	# Running the exteranl code

	def Execute()
		@ojlCode.Execute()

		def Run()
			@ojlCode.Execute()

		def Exec()
			@ojlCode.Execute()

	# Reading the result of the computation

	def Result()
		return @ojlCode.Result()

	# Debugging methods

	def Code()
		return @ojlCode.Code()

	def Duration()
		return @ojlCode.Duration()

	def Log()
		return @ojlCode.Log()

	def Trace()
		return @ojlCode.Trace()
