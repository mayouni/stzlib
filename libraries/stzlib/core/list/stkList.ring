

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

	def At(_n_)
		return @content[_n_]

		def ItemAt(_n_)
			return @content[_n_]

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
		_n_ = ring_find( reverse(@content), item )
		_nResult_ = len(@content) - _n_ + 1

		return _nResult_

	#--

	def Find(item)

		_anResult_ = []
		_nLen_ = len(@content)

		for i = 1 to _nLen_
			if @content[i] = item
				_anResult_ + i
			ok
		next

		return _anResult_

		func FindAll(item)
			return This.Find(item)

	#--

	def FindNth(_n_, item)

		_nResult_ = 0
		_nLen_ = len(@content)
		_nTimes_ = 0

		for i = 1 to _nLen_
			if @content[i] = item
				_nTimes_++
				if _nTimes_ = _n_
					_nResult_ = i
					exit
				ok
			ok
		next

		return _nResult_
	
	#-- INSERTING

	def InsertAt(_n_, item)
		ring_insert(@content, _n_, item)

	#-- REPLACING

	def Replace(item1, item2)
		_anPos_ = This.FindAll(item1)
		_nLen_ = len(_anPos_)

		for i = 1 to _nLen_
			@content[_anPos_[i]] = item2
		next

	def ReplaceSection(_n1_, _n2_, item)
		if NOT (isNumber(_n1_) and isNumber(_n2_))
			raise( "ERR-" + StkError(:IncorrectParamType) )
		ok

		if _n1_ > _n2_
			_nTemp_ = _n1_
			_n1_ = _n2_
			_n2_ = _nTemp_
		ok

		_aResult_ = []

		for i = _n1_ to _n2_
			@content[i] = item
		next

	#-- REMOVING

	def RemoveAt(_n_)
		ring_remove(@content, _n_)

		def RemoveItemAt(_n_)
			ring_remove(@content, _n_)

		def RemoveNth(_n_)
			ring_remove(@content, _n_)

		def RemoveNthItem(_n_)
			ring_remove(@content, _n_)

	def Remove(item)
		_anPos_ = This.FindAll(item)
		_nLen_ = len(_anPos_)

		if _nLen_ > 0
			for i = _nLen_ to 1 step -1
				ring_remove(@content, _anPos_[i])
			next
		ok

		def RemoveItem(item)
			This.Remove(item)

	def RemoveSection(_n1_, _n2_)
		if NOT (isNumber(_n1_) and isNumber(_n2_))
			raise( "ERR-" + StkError(:IncorrectParamType) )
		ok

		if _n1_ > _n2_
			_nTemp_ = _n1_
			_n1_ = _n2_
			_n2_ = _nTemp_
		ok

		_aResult_ = []

		for i = _n2_ to _n1_ step -1
			ring_remove(@content, i)
		next

	#--

	def Section(_n1_, _n2_)
		if NOT (isNumber(_n1_) and isNumber(_n2_))
			raise( "ERR-" + StkError(:IncorrectParamType) )
		ok

		if _n1_ > _n2_
			_nTemp_ = _n1_
			_n1_ = _n2_
			_n2_ = _nTemp_
		ok

		_aResult_ = []

		for i = _n1_ to _n2_
			_aResult_ + @content[i]
		next

		return _aResult_

	#--

	def Contains(item)
		if ring_find(@content, item) > 0
			return TRUE
		else
			return FALSE
		ok

	#==

	def StartsWith(item)
		if @content[1] = item
			return TRUE
		else
			return FALSE
		ok

	#--

	def EndsWith(item)
		if @content[ len(@content) ] = item
			return TRUE
		else
			return FALSE
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
