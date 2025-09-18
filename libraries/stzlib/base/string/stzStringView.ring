
class stzStringView from stzObject

	@oQString

	// Initializes the content of the softanza string object
	def init(pcStr)

		if CheckingParams()
			if NOT ( isString(pcStr) or @IsQString(pcStr) or
				 (isList(pcStr) and Q(pcStr).IsPairOfStrings()) )

				StzRaise("Can't create the stzString object! pcStr must be a string, a QString object, or a pair of strings.")
			ok

			if IsQString(pcStr)
				QStringObject() = pcStr
				return

			but isList(pcStr) and Q(pcStr).IsPairOfStrings() # Named string
				@cVarName = pcStr[1] # Inherited from stzObject
				QStringObject() = new QString2()
				QStringObject().append(pcStr[2])
				return
			ok

		ok

		@oQString = new QString2()
		@oQString.append(pcStr)

	  #=======================================#
	 #     GETTING CONTENT OF THE STRING     #
	#=======================================#

	def Content()

		return QStringObject().left(QStringObject().size())

		#< @FunctionFluentForm

		def ContentQ() # Same as Copy()
			return new stzString(This.Content())

		#>

	def QStringObject()
		return @oQString

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
