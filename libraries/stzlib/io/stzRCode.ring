func R()
	return new stzRCode

class stzRCode
	@oPyCode = new stzExtCodeXT(:R)

	def SetCode(pcPyCode)
		@oPyCode.setCode(pcPyCode)

		def @(pcPyCode)
			This.SetCode(pcPyCode)

	def Execute()
		@oPyCode.Execute()

		def Exec()
			@oPyCode.Execute()

		def Run()
			@oPyCode.Execute()

	def Result()
		return @oPyCode.Result()
