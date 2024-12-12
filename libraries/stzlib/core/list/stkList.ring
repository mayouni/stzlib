

#~~~~~~~~~~~~~~~~~#
#  STZ CORE LIST  #
#~~~~~~~~~~~~~~~~~#

class stzCoreList from stkList

class stkList from stkObject
	@content = []

	def init(paList)
		if NOT isList(paList)
			return raise( "ERR-"+ StkError(:IncorrectParamType) )
		ok

		@content = paList

	#--

	def Content()
		return @content

	#--

	def Size()
		return len(@content)

		def Count()
			return len(@content)

		def NumberOfItems()
			return len(@content)

	#--

	def At(n)
		return @content[n]

		def ItemAt(n)
			return @content[n]

	#-- APPENDING

	def Append(item)
		@content + item

		def Add(item)
			@content + item

	#-- FINDING

	def FindFirst(item)
		return ring_find(@content, item)

	#--

	def FindLast(item)
		n = ring_find( reverse(@content), item )
		nResult = len(@content) - n + 1

		return nResult

	#--

	def Find(item)

		anResult = []
		nLen = len(@content)

		for i = 1 to nLen
			if @content[i] = item
				anResult + i
			ok
		next

		return anResult

		func FindAll(item)
			return This.Find(item)

	#--

	def FindNth(n, item)

		nResult = 0
		nLen = len(@content)
		nTimes = 0

		for i = 1 to nLen
			if @content[i] = item
				nTimes++
				if nTimes = n
					nResult = i
					exit
				ok
			ok
		next

		return nResult
	
	#-- INSERTING

	def InsertAt(n, item)
		ring_insert(@content, n, item)

	#-- REPLACING

	def Replace(item1, item2)
		anPos = This.FindAll(item1)
		nLen = len(anPos)

		for i = 1 to nLen
			@content[anPos[i]] = item2
		next

	def ReplaceSection(n1, n2, item)
		if NOT (isNumber(n1) and isNumber(n2))
			raise( "ERR-" + StkError(:IncorrectParamType) )
		ok

		if n1 > n2
			nTemp = n1
			n1 = n2
			n2 = nTemp
		ok

		aResult = []

		for i = n1 to n2
			@content[i] = item
		next

	#-- REMOVING

	def RemoveAt(n)
		ring_remove(@content, n)

		def RemoveItemAt(n)
			ring_remove(@content, n)

		def RemoveNth(n)
			ring_remove(@content, n)

		def RemoveNthItem(n)
			ring_remove(@content, n)

	def Remove(item)
		anPos = This.FindAll(item)
		nLen = len(anPos)

		if nLen > 0
			for i = nLen to 1 step -1
				ring_remove(@content, anPos[i])
			next
		ok

		def RemoveItem(item)
			This.Remove(item)

	def RemoveSection(n1, n2)
		if NOT (isNumber(n1) and isNumber(n2))
			raise( "ERR-" + StkError(:IncorrectParamType) )
		ok

		if n1 > n2
			nTemp = n1
			n1 = n2
			n2 = nTemp
		ok

		aResult = []

		for i = n2 to n1 step -1
			ring_remove(@content, i)
		next

	#--

	def Section(n1, n2)
		if NOT (isNumber(n1) and isNumber(n2))
			raise( "ERR-" + StkError(:IncorrectParamType) )
		ok

		if n1 > n2
			nTemp = n1
			n1 = n2
			n2 = nTemp
		ok

		aResult = []

		for i = n1 to n2
			aResult + @content[i]
		next

		return aResult

	#--

	def Contains(item)
		if ring_find(@content, item) > 0
			return _TRUE_
		else
			return _FALSE_
		ok

	#==

	def StartsWith(item)
		if @content[1] = item
			return _TRUE_
		else
			return _FALSE_
		ok

	#--

	def EndsWith(item)
		if @content[ len(@content) ] = item
			return _TRUE_
		else
			return _FALSE_
		ok


	#==

	def Operator(op, value)
		if op = "+"
			@content + value

		but op = "[]"
			return @content[value]

		else
			raise( 'ERR-' + StkError(:UnsupportedOperator) )
		ok
