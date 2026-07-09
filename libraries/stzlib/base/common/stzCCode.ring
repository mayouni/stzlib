
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

class stzCCode from stzObject

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

		@cContent = StzStringQ(cCode).
			SimplifyQ().
			RemoveTheseBoundsQ("{", "}").
			Content()

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

	def Update(_cNewCode_)
		if CheckingParams() = 1
			if isList(_cNewCode_) and Q(_cNewCode_).IsWithOrByOrUsingNamedParam()
				_cNewCode_ = _cNewCode_[2]
			ok

			if NOT isString(_cNewCode_)
				StzRaise("Incorrect param type! cNewCode must be a string.")
			ok
		ok

		@cContent = _cNewCode_

		#< @FunctionFluentForm

		def UpdateQ(_cNewCode_)
			This.Update(_cNewCode_)
			return This

		#>

		#< @FunctionAlternativeForms

		def UpdateWith(_cNewCode_)
			This.Update(_cNewCode_)

			def UpdateWithQ(_cNewCode_)
				return This.UpdateQ(_cNewCode_)
	
		def UpdateBy(_cNewCode_)
			This.Update(_cNewCode_)

			def UpdateByQ(_cNewCode_)
				return This.UpdateQ(_cNewCode_)

		def UpdateUsing(_cNewCode_)
			This.Update(_cNewCode_)

			def UpdateUsingQ(_cNewCode_)
				return This.UpdateQ(_cNewCode_)

		#>

	def Updated(_cNewCode_)
		return _cNewCode_

		#< @FunctionAlternativeForms

		def UpdatedWith(_cNewCode_)
			return This.Updated(_cNewCode_)

		def UpdatedBy(_cNewCode_)
			return This.Updated(_cNewCode_)

		def UpdatedUsing(_cNewCode_)
			return This.Updated(_cNewCode_)

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
		# Example : for "@split", all the necessary variations
		# are generated as found in the fellowing list:
		# ~> we can also add Keywords()

		cCode = Q(cCode).TheseSubstringsSpacifiedCS([
			"@items", "@allItems", "@item",
		
			"@chars", "@allChars", "@char",

			"@strings", "@allStrings", "@string",
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
			"@NextChar", "@NextString", "@NextSubString",
			"@NextLine",

			"@NextNumber",
			
			"@NextList","@NextPair",

			"@NextSplit",

			"@NextObject",

			"@PreviousPosition",

			"@PreviousItem",
			"@PreviousChar",
			"@PreviousString", "@PreviousSubString",
			"@PreviousLine",
			"@PreviousNumber",

			"@PreviousList","@PreviousPair",
			"@PreviousSplit",
			"@PreviousObject"
			
		], 0)

		_oResult_ = StzStringQ(" " + cCode + " ")

		_oResult_.ReplaceManyCS([
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

			" This.Content() ", 0)

		_oResult_.ReplaceManyCS([
			" @position ", " @CurrentPosition ",
			" @Current@i ", " @CurrentI ",
			" @EachPosition ", " @EachI " ],

			" @i ", 0)

		_oResult_.ReplaceManyCS([				
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

			" This[@i] ", 0 )
			
		_oResult_.ReplaceCS(" -@Number ", " - This[@i] ", 0)

		_oResult_.ReplaceManyCS([
			" @NextPosition ", " @NextI "],

			" @i + 1 ", 0)
			
		_oResult_.ReplaceManyCS([
			" @NextItem ",
			" @NextChar ", " @NextString ", " @NextSubString ",
			" @NextLine ",
			" @NextNumber ",
			
			" @NextList ", " @NextPair ",
			" @NextSplit ",
			" @NextObject " ],

			" This[@i + 1] ", 0)

		_oResult_.ReplaceManyCS([
			" @PreviousPosition ", " @PreviousI "],

			" @i - 1 ", 0)

		_oResult_.ReplaceManyCS([
			" @PreviousItem ",
			" @PreviousChar ",
			" @PreviousString ", " @PreviousSubString ",
			" @PreviousLine ",
			" @PreviousNumber ",

			" @PreviousList ", " @PreviousPair ",
			" @PreviousSplit ",
			" @PreviousObject "
			],

			" This[@i - 1] ", 0)

		# Undo the "( " / " )" / "[ " / " ]" padding the normalization added (and
		# collapse the double-spaces left where a keyword was expanded next to a
		# bracket), so the transpiled code reads cleanly: Q(This[@i + 1]).Foo().
		_oResult_.ReplaceCS("  ", " ", 1)
		_oResult_.ReplaceCS("  ", " ", 1)
		_oResult_.ReplaceCS("( ", "(", 1)
		_oResult_.ReplaceCS(" )", ")", 1)
		_oResult_.ReplaceCS("[ ", "[", 1)
		_oResult_.ReplaceCS(" ]", "]", 1)

		_cResult_ = _oResult_.Trimmed()

		@cContent = _cResult_

		def TranspileQ()
			This.Transpile()
			return This

	def Transpiled()
		_cResult_ = This.Copy().TranspileQ().Content()
		return _cResult_

	  #-----------------------------------------------------#
	 #  IDENTIFIYING THE EXECUTABLE SECTION FROM THE CODE  #
	#=====================================================#

	def ExecutableSection()

		#WARNING

		# An important detail: In general, ExectuableSection, returnes a
		# section of the form [ 3, 12 ], for example, to say that the
		# conditional code can run from item 3 to item 12 without raising
		# the rather distrupting "Out of range access" error. But, if the
		# last item is envolved, and because stzCCode class does not know
		# it, then [ 3, :last ] is returned instead.

		# Therefore, it's the responsibility of the the code that called
		# stzCCode, to check that speciefic case, and replace :last with
		# the NumberOfItems() value applied to the calling object scope.

		_oCode_ = new stzString( This.Code() )

		# The first check we must do, is that the conditional code must
		# contain the @i or This[@i] keywords

		#NOTE # If you include sophisticated keywords like @CurrentItem,
		# @NextItem and so on, they will be ignored. To instruct Softanza
		# to understand them and apply them, you must use the ..XT()
		# alternative of this function instead (ExecutableSectionXT())

		if NOT _oCode_.Copy().RemoveSpacesQ().ContainsOneOfTheseCS([ "@i", "This[@i]" ], 0)
			StzRaise("Can't proceed! The conditional code provided does not contain @i or This[@i] keywords.")
		ok

		_acSubStr_ = _oCode_.WithoutSpacesQ().SubStringsBoundedBy([ "[","]" ])

		# Getting the indexs after the @i

		_rx_ = new stzRegex("(?<=@i)([+-]\d+)")
		_rx_.Match(Join(_acSubStr_))

		_acNumbersAfter_ = _rx_.Matches()
		_nLenAfter_ = len(_acNumbersAfter_)

		if _nLenAfter_ = 0
			return [ 1, :Last ]
		ok

		_anNumbers_ = []
		for i = 1 to _nLenAfter_
			_anNumbers_ + (0+ _acNumbersAfter_[i])
		next

		_oNumbers_ = new stzList(_anNumbers_)

		_anResult_ = [ 1, :Last ]

		if _nLenAfter_ = 1
			_n_ =  _anNumbers_[1]

			if _n_ > 0
				_anResult_ = [ 1, -_n_ ]

			but _n_ < 0
				_anResult_ = [ Abs(_n_) + 1, :Last ]

			ok
		else
			_nMin_ = 0+ _oNumbers_.Smallest()
			_nMax_ = 0+ _oNumbers_.Greatest()
	
			if BothAreNegative( _nMin_, _nMax_ )
				_nMin_ = Abs( _nMin_ )
				_nMax_ = :Last
	
			but BothArePositive( _nMin_, _nMax_ )
				_nMin_ = 1
				_nMax_ = - _nMax_

			but _nMin_ < 0 and _nMax_ > 0
				_nMin_ = Abs(_nMin_) + 1
				_nMax_ = - _nMax_
	
			else
				_nMin_ = 1
				_nMax_ = :Last
			ok
	
			_anResult_ = [ _nMin_, _nMax_ ]
		ok

		return _anResult_

		#NOTE
		# A small but important detail: in WXT() you can bound
		# the conditional code by { and }, but in the normal W()
		# form, you can't. The rationale behind this is always
		# the same: expressiveness against performance.


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

		_o1_ = new stzCCode('{ @CurrentItem = This[ @i + 3 ] }')
		? _o1_.ExecutableSection()
		#--> [ 1, -4 ]

		*/

		#NOTE # The fellowing line is the sole difference between
		# ExectuableSection() and ExecutablesSectionXT() alternatives.

		# Transpiling the conditional code provided to turn any
		# sophisticaed keyword (like @CurrentItem, @NextItem, etc)
		# to their basic alternatives (This[@i], This[@+i], etc)

		_oCode_ = new stzString( This.Transpiled() )
	
		# Doing the job to get the borners of the executable section

		if NOT _oCode_.Copy().RemoveSpacesQ().ContainsOneOfTheseCS([ "@i", "This[@i]" ], 0)
			StzRaise("Can't proceed! The conditional code provided does not contain @i or This[@i] keywords.")
		ok

		_acSubStr_ = _oCode_.SubStringsBoundedBy([ "[","]" ])

		# Getting the indexs after the @i

		_rx_ = new stzRegex("(?<=@i)([+-]\d+)")
		_rx_.Match(Join(_acSubStr_))

		_acNumbersAfter_ = _rx_.Matches()
		_nLenAfter_ = len(_acNumbersAfter_)

		if _nLenAfter_ = 0
			return [ 1, :Last ]
		ok

		_anNumbers_ = []
		for i = 1 to _nLenAfter_
			_anNumbers_ + (0+ _acNumbersAfter_[i])
		next

		_oNumbers_ = new stzList(_anNumbers_)

		_anResult_ = [ 1, :Last ]

		if _nLenAfter_ = 1
			_n_ =  _anNumbers_[1]

			if _n_ > 0
				_anResult_ = [ 1, -_n_ ]

			but _n_ < 0
				_anResult_ = [ Abs(_n_) + 1, :Last ]

			ok
		else
			_nMin_ = 0+ _oNumbers_.Smallest()
			_nMax_ = 0+ _oNumbers_.Greatest()
	
			if BothAreNegative( _nMin_, _nMax_ )
				_nMin_ = Abs( _nMin_ )
				_nMax_ = :Last
	
			but BothArePositive( _nMin_, _nMax_ )
				_nMin_ = 1
				_nMax_ = - _nMax_

			but _nMin_ < 0 and _nMax_ > 0
				_nMin_ = Abs(_nMin_) + 1
				_nMax_ = - _nMax_
	
			else
				_nMin_ = 1
				_nMax_ = :Last
			ok
	
			_anResult_ = [ _nMin_, _nMax_ ]
		ok

		return _anResult_
