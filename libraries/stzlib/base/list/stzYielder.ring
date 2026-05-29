# Softanza -- stzYielder
#
# Functional pipeline class: map/filter/reduce operations on lists.
# All operations are engine-backed via the stz_yielder Zig module.
#
# Usage:
#   oYielder = new stzYielder([1, -2, 3, -4, 5])
#   ? oYielder.Map(:Abs)          # => [1, 2, 3, 4, 5]
#   ? oYielder.Filter(:IsPositive) # => [1, 3, 5]
#   ? oYielder.Reduce(:Sum)       # => 3
#   ? oYielder.MapFiltered(:IsPositive, :Square) # => [1, 9, 25]

class stzYielder

	@aContent = []

	def init(paList)
		if isList(paList)
			@aContent = paList
		ok

	def Content()
		return @aContent

	def SetContent(paList)
		if isList(paList)
			@aContent = paList
		ok

	def NumberOfItems()
		return len(@aContent)

	  #-----------#
	 #   MAP     #
	#-----------#

	def Map(pcOp)
		_nMapOp_ = _TransformOpCode(pcOp)
		if _nMapOp_ = -1 return @aContent ok

		# NOTE: engine fast-path disabled because yielder lives in a
		# separate DLL and cannot resolve list-DLL handles (cross-DLL
		# handle-table bug). Re-enable once a direct-marshal bridge
		# variant (StzEngineYielderMapDirect) lands.
		return _RingMap_(@aContent, _nMapOp_)

	def MapQ(pcOp)
		@aContent = This.Map(pcOp)
		return This

	def MapIndexed(pcOp)
		_nMiOp_ = _TransformOpCode(pcOp)
		if _nMiOp_ = -1 return @aContent ok
		return _RingMap_(@aContent, _nMiOp_)

	def MapIndexedQ(pcOp)
		@aContent = This.MapIndexed(pcOp)
		return This

	  #--------------#
	 #   FILTER     #
	#--------------#

	def Filter(pcOp)
		_nFltOp_ = _FilterOpCode(pcOp)
		if _nFltOp_ = -1 return @aContent ok
		return _RingFilter_(@aContent, _nFltOp_)

	def FilterQ(pcOp)
		@aContent = This.Filter(pcOp)
		return This

	  #--------------#
	 #   REDUCE     #
	#--------------#

	def Reduce(pcOp)
		_nRedOp_ = _ReduceOpCode(pcOp)
		if _nRedOp_ = -1 return 0 ok
		return _RingReduce_(@aContent, _nRedOp_)

	def ReduceConcat(pcSep)
		_cRcResult_ = ""
		_nRcLen_ = len(@aContent)
		for _iRc_ = 1 to _nRcLen_
			if _iRc_ > 1 _cRcResult_ += pcSep ok
			_cRcResult_ += "" + @aContent[_iRc_]
		next
		return _cRcResult_

	  #-------------------#
	 #   FILTER + MAP    #
	#-------------------#

	def MapFiltered(pcFilterOp, pcTransformOp)
		_nFmFiltOp_ = _FilterOpCode(pcFilterOp)
		_nFmTransOp_ = _TransformOpCode(pcTransformOp)
		if _nFmFiltOp_ = -1 or _nFmTransOp_ = -1 return @aContent ok
		_aFmFilt_ = _RingFilter_(@aContent, _nFmFiltOp_)
		return _RingMap_(_aFmFilt_, _nFmTransOp_)

	def MapFilteredQ(pcFilterOp, pcTransformOp)
		@aContent = This.MapFiltered(pcFilterOp, pcTransformOp)
		return This

	  #------------------#
	 #   COUNT WHERE    #
	#------------------#

	def CountWhere(pcOp)
		_nCwOp_ = _FilterOpCode(pcOp)
		if _nCwOp_ = -1 return 0 ok
		return len(_RingFilter_(@aContent, _nCwOp_))

	  #---------------------#
	 #  CONVENIENCE NAMES  #
	#---------------------#

	# Map shortcuts
	def Abs()
		return This.Map(:Abs)

	def Negate()
		return This.Map(:Negate)

	def DoubleValues()
		return This.Map(:Double)

	def Square()
		return This.Map(:Square)

	def TypeNames()
		return This.Map(:TypeName)

	def StringLengths()
		return This.Map(:StrLen)

	def Uppercase()
		return This.Map(:StrUpper)

	def Lowercase()
		return This.Map(:StrLower)

	def Trimmed()
		return This.Map(:StrTrim)

	def Reversed()
		return This.Map(:StrReverse)

	def Signs()
		return This.Map(:Sign)

	# Filter shortcuts
	def Strings()
		return This.Filter(:IsString)

	def Numbers()
		return This.Filter(:IsNumber)

	def Positives()
		return This.Filter(:IsPositive)

	def Negatives()
		return This.Filter(:IsNegative)

	def Evens()
		return This.Filter(:IsEven)

	def Odds()
		return This.Filter(:IsOdd)

	def NonEmpty()
		return This.Filter(:IsNotEmpty)

	# Reduce shortcuts
	def Sum()
		return This.Reduce(:Sum)

	def Product()
		return This.Reduce(:Product)

	def MinValue()
		return This.Reduce(:Min)

	def MaxValue()
		return This.Reduce(:Max)

	def CountItems()
		return This.Reduce(:Count)

	def CountStrings()
		return This.Reduce(:CountStrings)

	def CountNumbers()
		return This.Reduce(:CountNumbers)

	def Concat(pcSep)
		return This.ReduceConcat(pcSep)

	def AnyTrue()
		return This.Reduce(:AnyTrue)

	def AllTrue()
		return This.Reduce(:AllTrue)

	  #----------------------------#
	 #  PRIVATE OP CODE LOOKUPS   #
	#----------------------------#

	private

	def _TransformOpCode(pcName)
		if isNumber(pcName) return pcName ok
		if not isString(pcName) return -1 ok
		pcName = lower(pcName)

		switch pcName
		on "typename"   return 0
		on "abs"        return 1
		on "negate"     return 2
		on "double"     return 3
		on "square"     return 4
		on "tostring"   return 5
		on "toint"      return 6
		on "tofloat"    return 7
		on "strlen"     return 8
		on "strupper"   return 9
		on "strlower"   return 10
		on "strtrim"    return 11
		on "strreverse" return 12
		on "increment"  return 13
		on "decrement"  return 14
		on "iseven"     return 15
		on "sign"       return 16
		other           return -1
		off

	def _FilterOpCode(pcName)
		if isNumber(pcName) return pcName ok
		if not isString(pcName) return -1 ok
		pcName = lower(pcName)

		switch pcName
		on "isstring"   return 0
		on "isnumber"   return 1
		on "isint"      return 2
		on "isfloat"    return 3
		on "isbool"     return 4
		on "isnull"     return 5
		on "islist"     return 6
		on "ispositive" return 7
		on "isnegative" return 8
		on "iszero"     return 9
		on "isnonzero"  return 10
		on "isempty"    return 11
		on "isnotempty" return 12
		on "iseven"     return 13
		on "isodd"      return 14
		on "istrue"     return 15
		on "isfalse"    return 16
		other           return -1
		off

	def _ReduceOpCode(pcName)
		if isNumber(pcName) return pcName ok
		if not isString(pcName) return -1 ok
		pcName = lower(pcName)

		switch pcName
		on "sum"          return 0
		on "product"      return 1
		on "min"          return 2
		on "max"          return 3
		on "count"        return 4
		on "countstrings" return 5
		on "countnumbers" return 6
		on "concat"       return 7
		on "anytrue"      return 8
		on "alltrue"      return 9
		other             return -1
		off

#--- Pure-Ring helpers (yielder engine bridge unavailable cross-DLL).

func _RingMap_(aIn, nOp)
	aOut = []
	nLen = len(aIn)
	for i = 1 to nLen
		item = aIn[i]
		switch nOp
		on 0  # typename
			aOut + type(item)
		on 1  # abs
			if isNumber(item) aOut + fabs(item) else aOut + item ok
		on 2  # negate
			if isNumber(item) aOut + (-item) else aOut + item ok
		on 3  # double
			if isNumber(item) aOut + (item * 2) else aOut + item ok
		on 4  # square
			if isNumber(item) aOut + (item * item) else aOut + item ok
		on 5  # tostring
			aOut + ("" + item)
		on 6  # toint
			if isString(item) aOut + 0 + item else aOut + floor(item) ok
		on 7  # tofloat
			if isString(item) aOut + 0.0 + item else aOut + (item + 0.0) ok
		on 8  # strlen
			if isString(item) aOut + len(item) else aOut + 0 ok
		on 9  # strupper
			if isString(item) aOut + upper(item) else aOut + item ok
		on 10 # strlower
			if isString(item) aOut + lower(item) else aOut + item ok
		on 11 # strtrim
			if isString(item) aOut + trim(item) else aOut + item ok
		on 12 # strreverse
			if isString(item)
				rev = ""
				for j = len(item) to 1 step -1 rev += item[j] next
				aOut + rev
			else aOut + item ok
		on 13 # increment
			if isNumber(item) aOut + (item + 1) else aOut + item ok
		on 14 # decrement
			if isNumber(item) aOut + (item - 1) else aOut + item ok
		on 15 # iseven
			if isNumber(item) and (item % 2 = 0) aOut + 1 else aOut + 0 ok
		on 16 # sign
			if isNumber(item)
				if item > 0 aOut + 1
				but item < 0 aOut + (-1)
				else aOut + 0 ok
			else aOut + 0 ok
		other
			aOut + item
		off
	next
	return aOut

func _RingFilter_(aIn, nOp)
	aOut = []
	nLen = len(aIn)
	for i = 1 to nLen
		item = aIn[i]
		bKeep = 0
		switch nOp
		on 0  bKeep = isString(item)
		on 1  bKeep = isNumber(item)
		on 2  if isNumber(item) bKeep = (floor(item) = item) ok
		on 3  if isNumber(item) bKeep = (floor(item) != item) ok
		on 4  bKeep = (item = 0 or item = 1)
		on 5  bKeep = isNull(item)
		on 6  bKeep = isList(item)
		on 7  if isNumber(item) bKeep = (item > 0) ok
		on 8  if isNumber(item) bKeep = (item < 0) ok
		on 9  if isNumber(item) bKeep = (item = 0) ok
		on 10 if isNumber(item) bKeep = (item != 0) ok
		on 11 if isString(item) bKeep = (item = "") but isList(item) bKeep = (len(item) = 0) ok
		on 12 if isString(item) bKeep = (item != "") but isList(item) bKeep = (len(item) > 0) ok
		on 13 if isNumber(item) bKeep = (item % 2 = 0) ok
		on 14 if isNumber(item) bKeep = (item % 2 != 0) ok
		on 15 bKeep = (item = 1)
		on 16 bKeep = (item = 0)
		off
		if bKeep aOut + item ok
	next
	return aOut

func _RingReduce_(aIn, nOp)
	nLen = len(aIn)
	# Match engine convention: empty input -> 0 for every reduce op.
	if nLen = 0 return 0 ok
	switch nOp
	on 0  # sum
		acc = 0
		for i = 1 to nLen if isNumber(aIn[i]) acc += aIn[i] ok next
		return acc
	on 1  # product
		acc = 1
		for i = 1 to nLen if isNumber(aIn[i]) acc *= aIn[i] ok next
		return acc
	on 2  # min
		if nLen = 0 return 0 ok
		mn = aIn[1]
		for i = 2 to nLen if isNumber(aIn[i]) and aIn[i] < mn mn = aIn[i] ok next
		return mn
	on 3  # max
		if nLen = 0 return 0 ok
		mx = aIn[1]
		for i = 2 to nLen if isNumber(aIn[i]) and aIn[i] > mx mx = aIn[i] ok next
		return mx
	on 4  return nLen
	on 5  # countstrings
		c = 0
		for i = 1 to nLen if isString(aIn[i]) c++ ok next
		return c
	on 6  # countnumbers
		c = 0
		for i = 1 to nLen if isNumber(aIn[i]) c++ ok next
		return c
	on 7  # concat
		s = ""
		for i = 1 to nLen s += "" + aIn[i] next
		return s
	on 8  # anytrue
		for i = 1 to nLen if aIn[i] = 1 return 1 ok next
		return 0
	on 9  # alltrue
		for i = 1 to nLen if aIn[i] != 1 return 0 ok next
		return 1
	off
	return 0
