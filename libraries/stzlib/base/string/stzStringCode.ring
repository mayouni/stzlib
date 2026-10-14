#--------------------------------------------------------------#
#         SOFTANZA LIBRARY (V0.9) - STZSTRINGCODE              #
#   An accelerative library for Ring applications, and more!   #
#--------------------------------------------------------------#
#                                                              #
#   Description  : String code -- Wraps stzString via          #
#                  composition. Detecting and working with     #
#                  code snippets in strings (Ring code,        #
#                  functions, classes).                        #
#   Version      : V0.9 (2026)                                 #
#   Author       : Mansour Ayouni (kalidianow@gmail.com)       #
#                                                              #
#--------------------------------------------------------------#


# Inspects a text holding Ring source: spots functions and classes, lists their names, counts lines of code, and can run it.
#
# Build one with new stzStringCode(cSource). The inspection works line by line on the text and never
# changes it: FunctionNames, ClassNames, NumberOfFunctions, NumberOfClasses, ContainsFunctions,
# ContainsClasses, LinesOfCode, IsComment and IsBlankLine. IsRingCode is a guess by keyword
# substring and gives false positives on prose. Execute and ExecuteAndReturn run the text with eval:
# only give them code you trust, and note that a variable assigned by Execute stays inside the call.
#
#   receiver   o1 = new stzStringCode("func Add(a, b)" + char(10) + " return a + b" + char(10) + "#
#              note" + char(10) + "class Pt")
#   example    ? @@( o1.FunctionNames() )
#              #--> [ "Add" ]
#              ? @@( o1.ClassNames() )
#              #--> [ "Pt" ]
#              ? o1.LinesOfCode()
#              #--> 3
#              ? o1.ContainsComments()
#              #--> 1
#              o2 = new stzStringCode("(2 + 3) * 4")
#              ? o2.ExecuteAndReturn()
#              #--> 20
#   see        stzString, stzStringFinder
class stzStringCode from stzObject

	@oString

	# Builds a code helper over a text or over a stzString object holding Ring source.
	#
	#   pStrOrStzStrObj   a text, or a stzString object, holding the code
	#   returns           nothing; the object is built
	#   note              the methods read the text and never change it, so a stzString passed in is
	#                     safe
	#   warning           any other kind of value raises "Can't create stzStringCode! Parameter must
	#                     be a string or stzString object."
	#   see               IsRingCode, FunctionNames
	def init(pStrOrStzStrObj)
		if isString(pStrOrStzStrObj)
			@oString = new stzString(pStrOrStzStrObj)
		but isObject(pStrOrStzStrObj)
			@oString = pStrOrStzStrObj
		else
			StzRaise("Can't create stzStringCode! Parameter must be a string or stzString object.")
		ok

	# Returns the text the helper holds.
	#
	#   returns    a text
	#   see        NumberOfChars
	def Content()
		return @oString.Content()

	# Returns how many characters the text holds, counting letters and not bytes.
	#
	#   returns    a number
	#   see        Content
	def NumberOfChars()
		return @oString.NumberOfChars()

	# TRUE if the text is empty.
	#
	#   returns    TRUE or FALSE
	#   see        NumberOfChars
	def IsEmpty()
		return @oString.IsEmpty()

	  #===============================#
	 #     RING CODE DETECTION       #
	#===============================#

	# TRUE if the text contains a Ring keyword such as func, class, if, for, return or new, in any case.
	#
	#   returns    TRUE or FALSE
	#   note       do not use it to tell prose from code
	#   warning    A guess by substring, not a parse: ordinary words that contain a keyword answer
	#              TRUE, such as "a gift" (if), "Brendan" (end) and "Seeing it" (see); "good
	#              morning" and the Hebrew "שלום עולם" answer FALSE
	#   see        IsRingFunction, IsRingClass
	def IsRingCode()
		_cContent_ = StzCaseFold(@oString.Content())
		_acKeywords_ = [
			"func", "class", "def", "if", "but", "else", "ok",
			"for", "next", "while", "end", "switch", "off",
			"return", "load", "see", "give", "new", "try",
			"catch", "done"
		]

		_nLen_ = len(_acKeywords_)
		for i = 1 to _nLen_
			_oFinder_ = new stzStringFinder(_cContent_)
			if _oFinder_.Contains(_acKeywords_[i])
				return 1
			ok
		next
		return 0

	# TRUE if the text, ignoring leading spaces, begins with "func " in any case.
	#
	#   returns    TRUE or FALSE
	#   note       "funcs are fun" is FALSE
	#   see        IsRingClass, FunctionNames
	def IsRingFunction()
		_cTrimmed_ = trim(@oString.Content())
		return StzLeft(StzCaseFold(_cTrimmed_), 5) = "func "

	# TRUE if the text, ignoring leading spaces, begins with "class " in any case.
	#
	#   returns    TRUE or FALSE
	#   see        IsRingFunction, ClassNames
	def IsRingClass()
		_cTrimmed_ = trim(@oString.Content())
		return StzLeft(StzCaseFold(_cTrimmed_), 6) = "class "

	  #===============================#
	 #     CODE EXECUTION            #
	#===============================#

	# Runs the text as Ring code and returns nothing.
	#
	#   returns    nothing
	#   note       the code runs inside the method, so a variable it assigns, such as x = 1 + 2, is
	#              not visible to the caller afterwards; only run code you trust
	#   see        ExecuteAndReturn
	def Execute()
		eval(@oString.Content())

	# Evaluates the text as a Ring expression and returns its value.
	#
	#   returns    the value of the expression
	#   note       "(2 + 3) * 4" answers 20; the text must be an expression, and only code you trust
	#              should be run
	#   see        Execute
	def ExecuteAndReturn()
		_cCode_ = "_result_ = " + @oString.Content()
		eval(_cCode_)
		return _result_

	  #===============================#
	 #     CODE STRUCTURE            #
	#===============================#

	# TRUE if the text has a "func " anywhere, in any case.
	#
	#   returns    TRUE or FALSE
	#   see        NumberOfFunctions, FunctionNames
	def ContainsFunctions()
		_oFinder_ = new stzStringFinder(StzCaseFold(@oString.Content()))
		return _oFinder_.Contains("func ")

	# TRUE if the text has a "class " anywhere, in any case.
	#
	#   returns    TRUE or FALSE
	#   see        NumberOfClasses, ClassNames
	def ContainsClasses()
		_oFinder_ = new stzStringFinder(StzCaseFold(@oString.Content()))
		return _oFinder_.Contains("class ")

	# Returns how many lines of the text begin with "func ".
	#
	#   returns    a number
	#   note       a line is counted after its leading spaces are removed
	#   see        FunctionNames
	def NumberOfFunctions()
		_cContent_ = StzCaseFold(@oString.Content())
		_acLines_ = split(_cContent_, nl)
		_nCount_ = 0
		_nLen_ = len(_acLines_)

		for i = 1 to _nLen_
			_cLine_ = trim(_acLines_[i])
			if StzLeft(_cLine_, 5) = "func "
				_nCount_++
			ok
		next

		return _nCount_

	# Returns how many lines of the text begin with "class ".
	#
	#   returns    a number
	#   see        ClassNames
	def NumberOfClasses()
		_cContent_ = StzCaseFold(@oString.Content())
		_acLines_ = split(_cContent_, nl)
		_nCount_ = 0
		_nLen_ = len(_acLines_)

		for i = 1 to _nLen_
			_cLine_ = trim(_acLines_[i])
			if StzLeft(_cLine_, 6) = "class "
				_nCount_++
			ok
		next

		return _nCount_

	# Returns the names of the functions declared in the text, in order, the first word after "func " up to a space or an opening bracket.
	#
	#   returns    a list of texts
	#   note       keeps the case of the source: "func Add(a, b)" gives Add
	#   see        NumberOfFunctions, ClassNames
	def FunctionNames()
		_cContent_ = @oString.Content()
		_acLines_ = split(_cContent_, nl)
		_acNames_ = []
		_nLen_ = len(_acLines_)

		for i = 1 to _nLen_
			_cLine_ = trim(_acLines_[i])
			_cLineLow_ = StzCaseFold(_cLine_)
			if StzLeft(_cLineLow_, 5) = "func "
				_oLine_ = new stzString(_cLine_)
				_cRest_ = _oLine_.Section(6, StzLen(_cLine_))
				_cRest_ = trim(_cRest_)
				# Extract the function name (first word)
				_cName_ = ""
				_oRest_ = new stzString(_cRest_)
				_acRestChars_ = _oRest_.Chars()
				_nRestLen_ = len(_acRestChars_)
				for j = 1 to _nRestLen_
					_c_ = _acRestChars_[j]
					if _c_ = " " or _c_ = "(" or _c_ = nl
						exit
					ok
					_cName_ += _c_
				next
				if StzLen(_cName_) > 0
					_acNames_ + _cName_
				ok
			ok
		next

		return _acNames_

	# Returns the names of the classes declared in the text, in order, the first word after "class ".
	#
	#   returns    a list of texts
	#   note       "Class Foo from Bar" gives Foo
	#   see        NumberOfClasses, FunctionNames
	def ClassNames()
		_cContent_ = @oString.Content()
		_acLines_ = split(_cContent_, nl)
		_acNames_ = []
		_nLen_ = len(_acLines_)

		for i = 1 to _nLen_
			_cLine_ = trim(_acLines_[i])
			_cLineLow_ = StzCaseFold(_cLine_)
			if StzLeft(_cLineLow_, 6) = "class "
				_oLine_ = new stzString(_cLine_)
				_cRest_ = _oLine_.Section(7, StzLen(_cLine_))
				_cRest_ = trim(_cRest_)
				# Extract the class name (first word)
				_cName_ = ""
				_oRest_ = new stzString(_cRest_)
				_acRestChars_ = _oRest_.Chars()
				_nRestLen_ = len(_acRestChars_)
				for j = 1 to _nRestLen_
					_c_ = _acRestChars_[j]
					if _c_ = " " or _c_ = nl
						exit
					ok
					_cName_ += _c_
				next
				if StzLen(_cName_) > 0
					_acNames_ + _cName_
				ok
			ok
		next

		return _acNames_

	  #===============================#
	 #     LINE ANALYSIS             #
	#===============================#

	# TRUE if the text, ignoring leading spaces, starts with # or //.
	#
	#   returns    TRUE or FALSE
	#   note       meant for a single line; on a longer text it only looks at the start
	#   see        ContainsComments, IsBlankLine
	def IsComment()
		_cTrimmed_ = trim(@oString.Content())
		if StzLeft(_cTrimmed_, 1) = "#"
			return 1
		ok
		if StzLeft(_cTrimmed_, 2) = "//"
			return 1
		ok
		return 0

	# TRUE if the text holds nothing but spaces.
	#
	#   returns    TRUE or FALSE
	#   see        IsComment
	def IsBlankLine()
		_cTrimmed_ = trim(@oString.Content())
		return StzLen(_cTrimmed_) = 0

	# TRUE if the text has a # or a // anywhere, comment or not.
	#
	#   returns    TRUE or FALSE
	#   note       a # inside a quoted text counts too
	#   see        IsComment, LinesOfCode
	def ContainsComments()
		_oFinder_ = new stzStringFinder(@oString)
		if _oFinder_.Contains("#")
			return 1
		ok
		if _oFinder_.Contains("//")
			return 1
		ok
		return 0

	# Returns how many lines are neither blank nor comments.
	#
	#   returns    a number
	#   note       the lines are those of the text; a line with code and a trailing comment counts
	#   see        ContainsComments
	def LinesOfCode()
		_cContent_ = @oString.Content()
		_acLines_ = split(_cContent_, nl)
		_nCount_ = 0
		_nLen_ = len(_acLines_)

		for i = 1 to _nLen_
			_cLine_ = trim(_acLines_[i])
			# Skip blank lines
			if StzLen(_cLine_) = 0
				loop
			ok
			# Skip comment lines
			if StzLeft(_cLine_, 1) = "#"
				loop
			ok
			if StzLeft(_cLine_, 2) = "//"
				loop
			ok
			_nCount_++
		next

		return _nCount_
