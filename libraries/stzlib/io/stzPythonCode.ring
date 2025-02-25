func py()
	return new stzPythonCode

class stzPyCode from stzPythonCode
class stzPythonCode
	@oPyCode = new stzExtCodeXT(:python)

	def SetCode(pcPyCode)
		@oPyCode.setCode(pcPyCode)

		def @(pcPyCode)
			This.SetCode(pcPyCode)

	def Execute()
		@oPyCode.Execute()

		def Run()
			@oPyCode.Execute()

		def Exec()
			@oPyCode.Execute()

	def Result()
		return @oPyCode.Result()

	def Code()
		return @oPyCode.Code()
