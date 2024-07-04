
/*
	Inside a conditional code you can use these keywords:
	@item
	@EachItem (...Char, ...String, ...List, ...Pair, ...Section, ...Number, ...Object)
	@CurrentItem
	@NextItem
	@PreviousItem
	
	@i
	@CurrentI
	@NextI
	@PreviousI
	
	This[ @i ] # Instead of ItemAt()
*/

func StzCCodeQ(cCode)
	return new stzCCode(cCode)

func StzConditionalCodeQ(cCode)
	return new stzConditionalCode(cCode)

class stzConditionalCode from stzCCode 

class stzCCode

	@cContent

	  #---------------------------------#
	 #  INITIALIZING THE CCODE OBJECT  #
	#---------------------------------#

	def init(cCode)

		if NOT isString(cCode)
			
			StzRaise([
				:Where = "stzCCode > Init()",
				:What  = "Can't create the stzConditionalCode object.",
				:Why   = "The parameter you provided is not in a correct type.",
				:Todo  = "Provide a conditional code as a Ring expression inside a string."
			])

		ok

		@cContent = cCode

	  #-------------------------------------------#
	 #  GETTING THE CONTENT OF THE CCODE OBJECT  #
	#-------------------------------------------#

	def Content()
		return @cContent

		def ContentQ()
			return new stzString( This.Content() )

		def CCode()
			return This.Content()

			def CCodeQ()
				return This.ContentQ()

			def Code()
				return This.Content()
	
			def CodeQ()
				return This.ContentQ()

	  #--------------------------------------#
	 #  GETTING A COPY OF THE CCODE OBJECT  #
	#--------------------------------------#

	def Update(cNewCode)
		if isList(cNewCode) and Q(cNewCode).IsWithOrByOrUsingNamedParam()
			cNewCode = cNewCode[2]
		ok

		@cContent = cNewCode

		#< @FunctionFluentForm

		def UpdateQ(cNewCode)
			This.Update(cNewCode)
			return This

		#>

		#< @FunctionAlternativeForms

		def UpdateWith(cNewCode)
			This.Update(cNewCode)

			def UpdateWithQ(cNewCode)
				return This.UpdateQ(cNewCode)
	
		def UpdateBy(cNewCode)
			This.Update(cNewCode)

			def UpdateByQ(cNewCode)
				return This.UpdateQ(cNewCode)

		def UpdateUsing(cNewCode)
			This.Update(cNewCode)

			def UpdateUsingQ(cNewCode)
				return This.UpdateQ(cNewCode)

		#>

	def Updated(cNewCode)
		return cNewCode

		#< @FunctionAlternativeForms

		def UpdatedWith(cNewCode)
			return This.Updated(cNewCode)

		def UpdatedBy(cNewCode)
			return This.Updated(cNewCode)

		def UpdatedUsing(cNewCode)
			return This.Updated(cNewCode)

		#>

	  #--------------------------------------#
	 #  GETTING A COPY OF THE CCODE OBJECT  #
	#--------------------------------------#

	def Copy()
		return new stzCCode( This.Content() )

	  #----------------------------------------------------------------------------#
	 #  TRANSPILING THE CODE BY TURNING SOPHISTICATED KEYWORDS TO BASIC KEYWORDS  #
	#============================================================================#

	def Transpile()

		#INFO
		# Transpiling is the process of translating the provided
		# conditional code by replacing sophisticated keywords
		# (like @CurrentItem, @NextItem, etc.) with their
		# basic equivalents using only @i and This[@i]. For example:
	
		# 	- @CurrentItem becomes This[@i]
		# 	- @NextItem becomes This[@i+1]
		# 	- @PreviousItem becomes This[@i-1]
	
		# By escence, Softanza uses it internaali with `..WXT()`
		# forms of conditiobal functions, enabling them to be more
		# expressive, but it also introduces a performance overhead.

		cCode = StzStringQ(This.Code()).
			TrimQ().
			RemoveTheseBoundsQ("{","}").

			ReplaceAllQ("(", :By = "( ").
			ReplaceAllQ(")", :By = " )").

			ReplaceAllQ("[", :By = "[ ").
			ReplaceAllQ("]", :By = " ]").

			Content()

		#TODO // Automate the addition of new keywords
		# Example : for @split", all the necessary variations
		# are generated as found in the fellowing list:
		# ~> we can also add Keywords()

		cCode = Q(cCode).TheseSubstringsSpacifiedCS([

				"@items", "@allItems", "@item",
			
				"@chars", "@allChars", "@char",

				"@strings", "@allStrings", "@string",
				"@strinItems", "@allStringItems", "@StringItem",
				"@SubStrings", "@allSubStrings", "@SubString",
				"@Lines", "@allLines", "@Line",
	
				"@numbers","@allNumbers", "@number",
				
				"@lists", "@allLists", "@list",
				"@pairs", "@allPairs", "@pair",

				"@splits", "@allSplits", "@split",

				"@objects", "@allObjects", "@object",

				"@positions", "@position", "@CurrentPosition",
				"@EachPosition",

				"-@Number",

				"@NextItem",
				"@NextChar", "@NextString", "@NextStringItem", "@NextSubString",
				"@NextLine",

				"@NextNumber",
				
				"@NextList","@NextPair",

				"@NextSplit",

				"@NextObject",

				"@PreviousPosition",

				"@PreviousItem",
				"@PreviousChar",
				"@PreviousString","@PreviousStringItem", "@PreviousSubString",
				"@PreviousLine",
				"@PreviousNumber",

				"@PreviousList","@PreviousPair",
				"@PreviousSplit",
				"@PreviousObject"
				
		], :CaseSensitive = FALSE)

		cResult = StzStringQ(" " + cCode + " ").

			ReplaceManyCSQ([
				" @items ","@allItems",
								
				" @chars ","@allChars",
				" @strings ","@allStrings",
				" @SubStrings ","@allSubStrings",
				" @Lines ",
				" @numbers ","@allNumbers",
				
				" @lists ","@allLists",
				" @Splits ", "@allSplits",
				" @pairs ","@allPairs",
				
				" @objects ","@allObjects" ],

				:By = " This.Content() ", :CS = FALSE).

			ReplaceManyCSQ([
				" @position ", " @CurrentPosition ",
				" @Current@i ", " @CurrentI ",
				" @EachPosition ", " @EachI " ],

				:By = " @i ", :CS = FALSE).

			ReplaceManyCSQ([				
				" @item ", " @EachItem ", " @CurrentItem ",
				" @char ", " @EachChar ", " @CurrentChar ",
				" @string", " @EachString ", " @CurrentString ",
				" @SubString", " @EachSubString ", " @CurrentSubString ",
				" @line", " @EachLine ", " @CurrentLine ",

				" @number ", " @EachNumber ", " @CurrentNumber ",

				" @list ", " @EachList ", " @CurrentList ",
				" @pair ", " @EachPair ", " @CurrentPair ",
				" @section ", " @EachSection ", " @CurrentSection ",

				" @Split ", " @EachSplit ", " @CurrentSplit ",

				" @object ", " @EachObject ", " @CurrentObject " ],

				:By = " This[@i] ", :CS = FALSE ).
				
			ReplaceCSQ(" -@Number ", :By = " - This[@i] ", :CS = FALSE).

			ReplaceManyCSQ([
				" @NextPosition ", " @NextI "],

				:By = " @i + 1 ", :CS = FALSE).
				
			ReplaceManyCSQ([
				" @NextItem ",
				" @NextChar ", " @NextString ", " @NextStringItem ", " @NextSubString ",
				" @NextLine ",
				" @NextNumber ",
				
				" @NextList ", " @NextPair ",
				" @NextSplit ",
				" @NextObject " ],

				:By = " This[@i + 1] ", :CS = FALSE).

			ReplaceManyCSQ([
				" @PreviousPosition ", " @PreviousI "],

				:By = " @i - 1 ", :CS = FALSE).

			ReplaceManyCSQ([
				" @PreviousItem ",
				" @PreviousChar ",
				" @PreviousString ", " @PreviousStringItem ", " @PreviousSubString ",
				" @PreviousLine ",
				" @PreviousNumber ",

				" @PreviousList ", " @PreviousPair ",
				" @PreviousSplit ",
				" @PreviousObject "
				],

				:By = " This[@i - 1] ", :CS = FALSE).

			Trimmed()

		@cContent = cResult

		def TranspileQ()
			This.Transpile()
			return This

	def Transpiled()
		cResult = This.Copy().TranspileQ().Content()
		return cResult

	  #-----------------------------------------------------#
	 #  IDENTIFIYING THE EXECUTABLE SECTION FROM THE CODE  #
	#=====================================================#

	def ExecutableSection()

		#WARNING

		# An important detail: In general, ExectuableSection, returnes a
		# section of the form [ 3, 12 ], for example, to say that the
		# conditional code can run from item 2 to item 12 without raising
		# the rather distrupting "Out of range access" error. But, if the
		# last item is envolved, and because stzCCode class does not know
		# it, then [ 3, :last ] is returned instead.

		# Therefore, it's the responsibility of the the code that called
		# stzCCode, to check that speciefic case, and replace :last the
		# the NumberOfItems() value applied to the calling object scope.

		oCode = new stzString( This.Code() )

		# The first check we must do, is that the consitional code must
		# contains the @i or This[@i] keywords

		#NOTE # If you include sphisticaed keywords like @CurrentItem,
		# @NextItem and so on, they will be ignored. To instruct Softanza
		# to understand them and apply them, you must use the ..XT()
		# alternative of this function instead (ExecutableSectionXT())

		if NOT oCode.Copy().RemoveSpacesQ().ContainsOneOfTheseCS([ "@i", "This[@i]" ], FALSE)
			StzRaise("Can't proceed! The conditional code provided does not contain @i or This[@i] keywords.")
		ok

		acSubStr = oCode.SubStringsBoundedBy([ "[","]" ])
		nLenSubStr = len(acSubStr)

		acNumbersAfter = []

		for i = 1 to nLenSubStr
			acNumbers = Q(acSubStr[i]).NumbersAfter("@i")
			if len(acNumbers) > 0
				acNumbersAfter + acNumbers[1]
			ok
		next

		nLenAfter = len(acNumbersAfter)

		if len(acNumbersAfter) = 0
			return [ 1, :Last ]
		ok

		anNumbers = []
		for i = 1 to nLenAfter
			cNumber = acNumbersAfter[i]
			if cNumber[1] = "+" or cNumber[1] = "-"
				anNumbers + (0+ cNumber)
			ok
		next
		oNumbers = new stzList(anNumbers)

		anResult = [ 1, :Last ]

		if nLenAfter = 1
			n =  anNumbers[1]

			if n > 0
				anResult = [ 1, -n ]

			but n < 0
				anResult = [ Abs(n) + 1, :Last ]

			ok
		else
			nMin = 0+ oNumbers.Smallest()
			nMax = 0+ oNumbers.Greatest()
	
			if BothAreNegative( nMin, nMax )
				nMin = Abs( nMin )
				nMax = :Last
	
			but BothArePositive( nMin, nMax )
				nMin = 1
				nMax = - nMax

			but nMin < 0 and nMax > 0
				nMin = Abs(nMin) + 1
				nMax = - nMax
	
			else
				nMin = 1
				nMax = :Last
			ok
	
			anResult = [ nMin, nMax ]
		ok

		return anResult

		#NOTE
		# A small but important detail: in WXT() you can bound
		# the conditional code by { and }, but in the normal W()
		# form, you can't. The rationale behind this is always
		# the same: expressiveness against performance.

/*
	def ExecutableSectionXT()
		# A less performant version with more chekcs.

		# Use it when you want to be more expressive
		# in your conditional code and use @NextItem,
		# @PreviousItem, @EachItem, @EachItemQ, and
		# alike keywords, instead beeing restricted
		# to using only This[@i+1], This[@i-1], etc.

		# In this case, there is a performance tax
		# you should pay for. Hence, if you need to
		# be efficient, then you should use
		# ExecutableSection(), without ...XT(), instead.

		/* EXAMPLE

		o1 = new stzCCode('{ @CurrentItem = This[ @i + 3 ] }')
		? o1.ExecutableSection()
		#--> [ 1, -4 ]

		*/

		#NOTE # The fellowing line is the sole difference between
		# ExectuableSection() and ExecutablesSectionXT() alternatives.

		# Transpiling the condisonal code provided to turn any
		# sophisticaed keyword (like @CurrentItem, @NextItem, etc)
		# to their basic alternatives (This[@i], This[@+i], etc)

		oCode = new stzString( This.Transpiled() )
	
		# Doing the job to get the borners of the executable section

		acSubStr = oCode.SubStringsBoundedBy([ "[","]" ])
		nLenSubStr = len(acSubStr)

		acNumbersAfter = []
		for i = 1 to nLenSubStr
			acNumbers = Q(acSubStr[i]).NumbersAfter("@i")
			if len(acNumbers) > 0
				acNumbersAfter + acNumbers[1]
			ok
		next

		nLenAfter = len(acNumbersAfter)

		if len(acNumbersAfter) = 0
			return [ 1, :Last ]
		ok

		anNumbers = []
		for i = 1 to nLenAfter
			cNumber = acNumbersAfter[i]
			if cNumber[1] = "+" or cNumber[1] = "-"
				anNumbers + (0+ cNumber)
			ok
		next
		oNumbers = new stzList(anNumbers)

		anResult = [ 1, :Last ]

		if nLenAfter = 1
			n =  anNumbers[1]

			if n > 0
				anResult = [ 1, -n ]

			but n < 0
				anResult = [ Abs(n) + 1, :Last ]

			ok
		else
			nMin = 0+ oNumbers.Smallest()
			nMax = 0+ oNumbers.Greatest()
	
			if BothAreNegative( nMin, nMax )
				nMin = Abs( nMin )
				nMax = :Last
	
			but BothArePositive( nMin, nMax )
				nMin = 1
				nMax = - nMax
	
			but nMin < 0 and nMax > 0
				nMin = Abs(nMin) + 1
				nMax = - nMax
	
			else
				nMin = 1
				nMax = :Last
			ok
	
			anResult = [ nMin, nMax ]
		ok

		return anResult
