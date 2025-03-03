func XR()
	return new stzRCode

	func R()
		return new stzRCode

class stzRCode
	@oRCode = new stzExtCodeXT(:R)

	# Initializing the external code

	def SetCode(pcRCode)
		@oRCode.setCode(pcRCode)

		def @(pcRCode)
			This.SetCode(pcRCode)

	# Running the exteranl code

	def Execute()
		@oRCode.Execute()

		def Run()
			@oRCode.Execute()

		def Exec()
			@oRCode.Execute()

	# Reading the result of the computation

	def Result()
		return @oRCode.Result()

	# Debugging methods

	def Code()
		return @oRCode.Code()

	def Duration()
		return @oRCode.Duration()

	def Log()
		return @oRCode.Log()

	def Trace()
		return @oRCode.Trace()
