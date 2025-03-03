func XPy()
	return new stzPythonCode

	func py()
		return return new stzPythonCode

class stzPyCode from stzPythonCode
class stzPythonCode
	@oPyCode = new stzExtCodeXT(:python)

	# Initializing the external code

	def SetCode(pcPyCode)
		@oPyCode.setCode(pcPyCode)

		def @(pcPyCode)
			This.SetCode(pcPyCode)

	# Running the exteranl code

	def Execute()
		@oPyCode.Execute()

		def Run()
			@oPyCode.Execute()

		def Exec()
			@oPyCode.Execute()

	# Reading the result of the computation

	def Result()
		return @oPyCode.Result()

	# Debugging methods

	def Code()
		return @oPyCode.Code()

	def Duration()
		return @oPyCode.Duration()

	def Log()
		return @oPyCode.Log()

	def Trace()
		return @oPyCode.Trace()
