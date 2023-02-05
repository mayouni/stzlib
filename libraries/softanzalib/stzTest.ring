

func StzTestQ()
	return new stzTest()

class stzTest
	@Class
	@Function
	@Description
	@Code
	@Result
	@Output

	def init()
		
	def Code()
		return @Code

	def Result()
		return @Result

	def Run()
		cCode = Q( This.Code() ).
			TrimQ().RemoveBoundsQ(["{","}"]).
			ReplaceQ("?", "@Output = ").
			Content()

		eval(cCode)

	def Output()
		return @Output

	def Succeeded()
		if Q(This.Output()).IsEqualTo(This.Result())
			return TRUE
		else
			return FALSE
		ok

		def Success()
			return Succeeded()

	def Failed()
		return NOT This.Succeeded()

		def Failure()
			return Failed()

	def Check()
		This.Run()

		if This.Succeeded()
			? :Succeeded

		else
			? :Failed
		ok

	def CheckxT()
		This.Run()

		if This.Succeeded()

			cRes =  "Succeeded!" + NL +
				"~~~~~~~~~~" + NL +
				"Correcly returned: " + @@S(@Output)


		else
			cRes =  "Failed!" + NL +
				"~~~~~~~" + NL +
				"Must return : " + @@S(@Result) + NL +
				"But returned: " + @@S(@Output)

		ok

		? cRes

		def Explain()
			? CheckXT()
