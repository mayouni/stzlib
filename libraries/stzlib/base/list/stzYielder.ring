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
		# Engine direct-marshal path (yielder DLL takes the Ring list,
		# marshals it locally, runs the op, returns a Ring list).
		# Sidesteps the cross-DLL handle-table problem.
		return StzEngineYielderMapDirect(@aContent, _nMapOp_)

	def MapQ(pcOp)
		@aContent = This.Map(pcOp)
		return This

	def MapIndexed(pcOp)
		_nMiOp_ = _TransformOpCode(pcOp)
		if _nMiOp_ = -1 return @aContent ok
		return StzEngineYielderMapIndexedDirect(@aContent, _nMiOp_)

	def MapIndexedQ(pcOp)
		@aContent = This.MapIndexed(pcOp)
		return This

	  #--------------#
	 #   FILTER     #
	#--------------#

	def Filter(pcOp)
		_nFltOp_ = _FilterOpCode(pcOp)
		if _nFltOp_ = -1 return @aContent ok
		return StzEngineYielderFilterDirect(@aContent, _nFltOp_)

	def FilterQ(pcOp)
		@aContent = This.Filter(pcOp)
		return This

	  #--------------#
	 #   REDUCE     #
	#--------------#

	def Reduce(pcOp)
		_nRedOp_ = _ReduceOpCode(pcOp)
		if _nRedOp_ = -1 return 0 ok
		return StzEngineYielderReduceDirect(@aContent, _nRedOp_)

	def ReduceConcat(pcSep)
		return StzEngineYielderReduceConcatDirect(@aContent, pcSep)

	  #-------------------#
	 #   FILTER + MAP    #
	#-------------------#

	def MapFiltered(pcFilterOp, pcTransformOp)
		_nFmFiltOp_ = _FilterOpCode(pcFilterOp)
		_nFmTransOp_ = _TransformOpCode(pcTransformOp)
		if _nFmFiltOp_ = -1 or _nFmTransOp_ = -1 return @aContent ok
		return StzEngineYielderFilterMapDirect(@aContent, _nFmFiltOp_, _nFmTransOp_)

	def MapFilteredQ(pcFilterOp, pcTransformOp)
		@aContent = This.MapFiltered(pcFilterOp, pcTransformOp)
		return This

	  #------------------#
	 #   COUNT WHERE    #
	#------------------#

	def CountWhere(pcOp)
		_nCwOp_ = _FilterOpCode(pcOp)
		if _nCwOp_ = -1 return 0 ok
		return StzEngineYielderCountWhereDirect(@aContent, _nCwOp_)

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

# Yielder helpers ring_Map/ring_Filter/ring_Reduce removed --
# the engine direct-marshal bridge (StzEngineYielderMapDirect /
# FilterDirect / ReduceDirect / FilterMapDirect / CountWhereDirect /
# ReduceConcatDirect / MapIndexedDirect) now handles every Map/
# Filter/Reduce path natively.
