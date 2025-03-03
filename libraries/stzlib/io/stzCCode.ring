func XC()
	return new stzCCode

	func C()
		return new stzCCode

class stzCCode
	@oCCode = new stzExtCodeXT(:C)

	# Initializing the external code

	def SetCode(pcCCode)
		@oCCode.setCode(pcCCode)

		def @(pcCCode)
			This.SetCode(pcCCode)

	# Running the exteranl code

	def Execute()
		@oCCode.Execute()

		def Run()
			@oCCode.Execute()

		def Exec()
			@oCCode.Execute()

	# Reading the result of the computation

	def Result()
		return @oCCode.Result()

	# Debugging methods

	def Code()
		return @oCCode.Code()

	def Duration()
		return @oCCode.Duration()

	def Log()
		return @oCCode.Log()

	def Trace()
		return @oCCode.Trace()
