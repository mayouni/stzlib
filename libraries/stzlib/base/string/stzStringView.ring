
class stzStringView from stzObject

	@cContent

	// Initializes the content of the softanza string object
	def init(pcStr)

		if CheckingParams()
			if NOT ( isString(pcStr) or
				 (isList(pcStr) and Q(pcStr).IsPairOfStrings()) )

				StzRaise("Can't create the stzString object! pcStr must be a string or a pair of strings.")
			ok

			if isList(pcStr) and Q(pcStr).IsPairOfStrings() # Named string
				@cVarName = pcStr[1] # Inherited from stzObject
				@cContent = pcStr[2]
				return
			ok

		ok

		@cContent = pcStr

	  #=======================================#
	 #     GETTING CONTENT OF THE STRING     #
	#=======================================#

	def Content()

		return @cContent

		#< @FunctionFluentForm

		def ContentQ() # Same as Copy()
			return new stzString(This.Content())

		#>

	  #=======================================#
	 #  GETTING A COPY OF THE STRING OBJECT  #
	#=======================================#

	def Copy()
		return new stzString( This.String() )

	def ReversedCopy()
		return This.Copy().ReverseQ()

	  #==================================#
	 #  GETTING THE CASE OF THE STRING  #
	#==================================#

	def StringCase()
		if NOT This.ContainsLatinLetters()
			return ""

		ok

	  #---------------------------------------------------------------------#
	 #  CHECKING IF THE STRING HAS THE SAME CASE AS AN OTHER GIVEN STRING  #
	#---------------------------------------------------------------------#

	def HasSameCaseAs(pcOtherStr)
		return This.CharCase() = StzStringQ(pcOtherStr).CharCase()


	  #--------------------------------------------#
	 #  CHECKING IF THE STRING IS IN HYBRID CASE  #
	#--------------------------------------------#

	def IsHybridcase()
		if NOT This.ContainsLatinLetters()
			return ""

		ok

		bResult = Q( This.StringCase() ).IsNotOneOfThese([ StringCases() ])
		return bResult


	  #========================================#
	 #  CHECKING IF THE STRING IS PALINDROME  #
	#========================================#

	def IsPalindromeCS(pCaseSensitive)
		if This.NumberOfChars() < 2
			return 0
		ok

		cReversed = This.Reversed()
		if This.IsEqualtToCS( cReversed, pCaseSensitive) = 1
			return 1
		else
			return 0
		ok

	#-- WITHOUT CASESENSITIVITY

	def IsPalindrome()
		return This.IsPalindromeCS(1)
