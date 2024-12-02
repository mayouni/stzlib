load "LightGuiLib.ring"

#~~~~~~~~~~~~~~~~~~~#
#  STZ CORE STRING  #
#~~~~~~~~~~~~~~~~~~~#

# Split function (to use instead of the one provided by the standard library)

func StkSplitCS(cStr, cSubStr, bCaseSensitive)
	oQStr = new QString2()
	oQStr.append(cStr)
	
	oQStrList = oQStr.split(cSubStr, 0, bCaseSensitive)
	
	acResult = []
	for i = 0 to oQStrList.size()-1
		acResult + oQStrList.at(i)	
	next

	return acResult

func StkSplit(cStr, cSubStr)
	return StkSplitCS(cStr, cSubStr, 0)

# Trim function (to use instead of the one provided by the standard library)

func StkTrim(cStr)
	oQStr = new QString2()
	oQStr.append(cStr)

	cResult = oQStr.trimmed()
	return cResult


class stkString from stzCoreString

class stzCoreString from stzCoreObject
	@content // A QString object from Qt

	def init(str)
		if NOT isString(str)
			return StkError(:IncorrectPramType)
		ok

		@content = new QString2()
		@content.append(str)

	#--

	def Content()
		return @content.mid(0, @content.count())

	#--

	def Size()
		return @content.count()

		def Count()
			return @content.count()

		def NumberOfChars()
			return @content.count()

	#--

	def At(n)
		return @content.mid(n-1, 1)

		def CharAt(n)
			return @content.mid(n-1, 1)

	#-- APPENDING

	def Append(substr)
		if substr != ""
			@content.append(substr)
		ok

		def Add(substr)
			if substr != ""
				@content.append(substr)
			ok

	def AppendQChar(q)
		@content.append_2(q)

	#-- FINDING

	def FindFirstCS(substr, bCase)
		if substr = ""
			return 0
		ok
		return @content.indexOf(substr, 0, bCase) + 1

	def FindFirst(substr)
		if substr = ""
			return 0
		ok
		return @content.indexOf(substr, 0, true) + 1

	#--

	def FindLastCS(substr, bCase)
		if substr = ""
			return 0
		ok
		return @content.lastIndexOf(substr, @content.count()-1, bCase) + 1

	def FindLast(substr)
		if substr = ""
			return 0
		ok
		return @content.lastIndexOf(substr, @content.count()-1, true) + 1

	#--

	def FindCS(substr, bCase)
		if substr = ""
			return [0]
		ok

		@TempQStr = new QString2()
		@TempQStr.append(substr)
		nSize = @TempQStr.count()

		anResult = []
		bContinue = TRUE
	
		nPos = 0  # Start from index 0
	
	   	while bContinue
			nPos = @content.indexOf(substr, nPos, bCase)
			if nPos = -1
				bContinue = FALSE
			else
				anResult + (nPos + 1)  	# Add 1 to convert to 1-based index
				nPos = nPos + nSize  	# Move to the next position after the found substring
			ok
		end
	
		return anResult


		def FindAllCS(substr, bCase)
			return This.FindCS(substr, bCase)

	def Find(substr)
		return This.FindCS(substr, true)

		def FindAll(substr)
			return This.Find(substr)

	#--

	def FindNthCS(n, substr, bCase)
		if n < 0 or substr = ""
			return 0
		ok

		@TempQStr = new QString2()
		@TempQStr.append(substr)
		nSize = @TempQStr.count()

		nResult = 0
		bContinue = TRUE
	
		nPos = 0  # Start from index 0
		nTimes = 0

	   	while bContinue
			nPos = @content.indexOf(substr, nPos, bCase)
			if nPos = -1
				bContinue = FALSE
			else
				nTimes++ 
				if nTimes = n
					nResult = nPos + 1
					exit
				ok

				nPos = nPos + nSize  	# Move to the next position after the found substring
			ok
		end
	
		return nResult

	def FindNth(n, substr)
		return This.FindNthCS(n, substr, true)
	
	#-- INSERTING

	def InsertAt(n, substr)
		if n > 0 and substr != ""
			@content.insert(n-1, substr)
		ok

	#== REPLACING

	def ReplaceCS(substr1, substr2, bCase)
		if substr1 != ""
			@content.replace_2(substr1, substr2, bCase)
		ok

	def Replace(substr1, substr2)
		if substr1 != ""
			@content.replace_2(substr1, substr2, true)
		ok
	#--

	def ReplaceSection(n1, n2, substr)
		if n1 > 0 and n2 >= n1 and substr != ""
			@content.replace( n1 - 1, n2 - n1 + 1, substr)
		ok

	#== REMOVING

	def RemoveCS(substr, bCase)
		if substr != ""
			@content.replace_2(substr, "", bCase)
		ok

	def Remove(substr)
		if substr != ""
			@content.replace_2(substr, "", true)
		ok

	#--

	def RemoveSection(n1, n2)
		if n1 > 0 and n2 >= n1
			@content.replace(n1 - 1, n2 - n1 + 1, "")
		ok

	#== SPLITTING

	def SplitCS(substr, bCase)
		if substr = ""
			return []
		ok

		oQStrList = This.QStringObject().split(substr, 0, bCase)

		acResult = []
		for i = 0 to oQStrList.size()-1
			acResult + oQStrList.at(i)	
		next
	
		return acResult

	def Split(substr)
		return This.SplitCS(substr, true)

	#--

	def Section(n1, n2)
		if n1 > 0 and n2 >= n1
			return @content.mid(n1-1, n2 - n1 + 1)
		else
			raise( 'ERR-' + StkError(:IncorrectParamType) )
		ok

	#--

	def ContainsCS(substr, bCase)
		if substr = ""
			return FALSE
		ok

		return @content.contains(substr, bCase)

	def Contains(substr)
		if substr = ""
			return FALSE
		ok

		return @content.contains(substr, true)

	#==

	def StartsWithCS(substr, bCase)
		if substr = ""
			return FALSE
		ok

		return @content.startsWith(substr, bCase)

	def StartsWith(substr)
		if substr = ""
			return FALSE
		ok

		return @content.startsWith(substr, true)

	#--

	def EndsWithCS(substr, bCase)
		if substr = ""
			return FALSE
		ok

		return @content.endsWith(substr, bCase)

	def EndsWith(substr)
		if substr = ""
			return FALSE
		ok

		return @content.endsWith(substr, true)

	#--

	def IsRightToLeft()
		return @content.IsRighttoLeft()

	#--

	def Simplify()
		if This.Content() != ""
			cSimplified = @content.simplified()
			oTempQStr = new QString2()
			oTempQStr.append(cSimplified)
	
			@content = oTempQStr
		ok
	#==

	def UnicodeAt(n)
		if @content = ""
			raise( "Can't proceed! Because the string is empty." )
		ok

		if n <= 0
			raise( 'ERR-' + StkError(:IncorrectParamType) )
		ok

		oTempQStr = new QString2()
		oTempQStr.append(This.CharAt(n))
		nResult = oTempQStr.unicode().unicode()
		return nResult

		def UnicodeOfCharAt(n)
			return This.UnicodeOfChar(n)

	def Unicode()
		nLen = This.Size()
		if nLen = 0
			raise( "Can't proceed! Because the string is empty." )

		ok

		if nLen = 1
			return This.UnicodeAt(1)
		else
			return This.Unicodes()
		ok

	def Unicodes()
		nLen = This.Size()
		if nLen = 0
			raise( "Can't proceed! Because the string is empty." )

		ok

		anResult = []

		for i = 1 to nLen
			anResult + This.UnicodeAt(i)
		next

		return anResult

	def Chars()
		nLen = This.Size()
		if nLen = 0
			raise( "Can't proceed! Because the string is empty." )

		ok

		acResult = []

		for i = 1 to nLen
			acResult + This.CharAt(i)
		next

		return acResult

	#==

	def QStringObject()
		return @content

		def Qt()
			return @content

	def ToQCharObject(n)
		return new QChar(This.UnicodeAt(n))

		def ToQChar(n)
			return new QChar(This.UnicodeAt(n))

		def QCharObject(n)
			return new QChar(This.UnicodeAt(n))

		def QChar(n)
			return new QChar(This.UnicodeAt(n))

	#==

	def Operator(op, value)
		if op = "+"
			if value != ""
				@content.append(value)
			ok

		but op = "[]"
			return This.At(value)

		else
			raise( 'ERR-' + StkError(:UnsupportedOperator) )
		ok
