

func StzTestQ()
	return new stzTest()

class stzTest
	@Class
	@Function
	@Description
	@Code
	@MustReturn
	@Output

	def init()

	def Code()
		return @Code

	def MustReturn()
		return @MustReturn

	def Run()
		cCode = Q( This.Code() ).
			TrimQ().RemoveTheseBoundsQ("{","}").
			ReplaceQ("?", "@Output =").
			Content()

		eval(cCode)

	def Output()
		return @Output

	def Succeeded()
		if Q(This.Output()).IsEqualTo(This.MustReturn())
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

		cRes = ""
		if WithoutSapces(@Description) != NULL
			cRes = @Description + " : "
		ok

		if This.Succeeded()
			
			cRes += "Succeeded"

		else
			cRes += "Failed"
		ok

		? cRes

	def CheckxT()
		This.Run()

		cRes = ""

		if WithoutSapces(@Description) != NULL
		# NOTE: WithoutSapces() is misspelled but Softanza recognizes it!

			cRes = @Description + " : " + NL
		ok

		if This.Succeeded()

			cRes +=	( "~> Succeeded!" + NL +
				  "~~~~~~~~~~~~~" + NL +
				  "Correctly returned: " + @@(@Output) )


		else
			cRes += ( "~> Failed!" + NL +
				"~~~~~~~~~~" + NL +
				"Must return : " + @@(@MustReturn) + NL +
				"But returned: " + @@(@Output) )

		ok

		? cRes + NL

		def Explain()
			? CheckXT()
