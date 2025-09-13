func XPg()
	return new stzPrologCode

	func Pg()
		return new stzPrologCode

class stzPrologCode
	@oPrlgCode = new stzExterCode(:Prolog)

	# Initializing the external code

	def SetCode(pcPrologCode)
		@oPrlgCode.setCode(pcPrologCode)

		def @(pcPrologCode)
			This.SetCode(pcPrologCode)

	# Running the exteranl code

	def Execute()
		@oPrlgCode.Execute()

		def Run()
			@oPrlgCode.Execute()

		def Exec()
			@oPrlgCode.Execute()

	# Reading the result of the computation

	def Result()
		return @oPrlgCode.Result()

	# Debugging methods

	def Code()
		return @oPrlgCode.Code()

	def Duration()
		return @oPrlgCode.Duration()

	def Log()
		return @oPrlgCode.Log()

	def Trace()
		return @oPrlgCode.Trace()
