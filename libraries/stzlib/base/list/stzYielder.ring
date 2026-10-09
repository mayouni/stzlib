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

# Runs map, filter and reduce steps over a list, each chosen by the name of an operation, with the work done in the engine.
#
# Reach for it to transform, select or fold a list without writing a loop: Map applies one named
# operation to every item, Filter keeps the items that pass a named test, Reduce folds the list to
# one value. The result of Map and Filter is a new list and the held list is unchanged, unless the Q
# form (MapQ, FilterQ) is used, which keeps the result and returns the object for chaining. A name
# that is not known does nothing and raises no error. MapIndexed is broken today (it answers the
# text <list> for each item).
#
#   receiver   o1 = new stzYielder([1, -2, 3, -4, 5])
#   example    ? @@( o1.Map(:Abs) )
#              #--> [ 1, 2, 3, 4, 5 ]
#              ? @@( o1.Filter(:IsPositive) )
#              #--> [ 1, 3, 5 ]
#              ? o1.Reduce(:Sum)
#              #--> 3
#              ? @@( o1.MapFiltered(:IsPositive, :Square) )
#              #--> [ 1, 9, 25 ]
#   see        stzList, stzListOfNumbers
class stzYielder from stzObject

	@aContent = []

	# Builds a pipeline over a list; any value that is not a list is ignored and the content stays empty.
	#
	#   paList     the list to run the pipeline over
	#   returns    nothing; the object is built
	#   note       a list argument is stored as given; the operations never change it
	#   see        SetContent, Content
	def init(paList)
		if isList(paList)
			@aContent = paList
		ok

	# Returns the list the pipeline holds now.
	#
	#   returns    a list
	#   note       it shows the effect of the Q forms (MapQ, FilterQ), which replace the content
	#   see        SetContent, NumberOfItems
	def Content()
		return @aContent

	# Replaces the held list; a value that is not a list is ignored and the old content stays.
	#
	#   paList     the new list
	#   returns    nothing
	#   see        Content, NumberOfItems
	def SetContent(paList)
		if isList(paList)
			@aContent = paList
		ok

	# Returns how many items the held list has.
	#
	#   returns    a number
	#   see        Content, CountItems
	def NumberOfItems()
		return len(@aContent)

	  #-----------#
	 #   MAP     #
	#-----------#

	# Returns a new list with one named operation applied to every item; the held list is not changed.
	#
	#   pcOp       the operation: :Abs, :Negate, :Double, :Square, :TypeName, :ToString, :ToInt,
	#              :ToFloat, :StrLen, :StrUpper, :StrLower, :StrTrim, :StrReverse, :Increment,
	#              :Decrement, :IsEven, :Sign (or its code 0-16)
	#   returns    a list of the same length; the content unchanged when the operation name is
	#              unknown
	#   note       an operation that does not suit an item (:Abs on text) leaves the item as it is,
	#              and an unknown name returns the content without any message
	#   see        MapQ, MapIndexed, Filter
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

	# Returns the text <list> for every item today, instead of applying an operation together with each item position.
	#
	#   pcOp       the operation name, as for Map
	#   returns    a list of texts, each the text <list>
	#   note       do not rely on it until it answers real values
	#   warning    defect: the result holds the text "<list>" in place of the values, for every
	#              operation tried (:Square, :Abs, :Negate, :Increment) and every input; the engine
	#              call returns its items in a form the Ring side shows only as that text
	#   see        Map, MapIndexedQ
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

	# Returns a new list of the items for which a named test is true; the held list is not changed.
	#
	#   pcOp       the test: :IsString, :IsNumber, :IsInt, :IsFloat, :IsBool, :IsNull, :IsList,
	#              :IsPositive, :IsNegative, :IsZero, :IsNonZero, :IsEmpty, :IsNotEmpty, :IsEven,
	#              :IsOdd, :IsTrue, :IsFalse (or its code 0-16)
	#   returns    a list, shorter or equal; the whole list when the test name is unknown
	#   note       an unknown name returns the content unchanged, without a message; the empty text
	#              counts as a string and as empty
	#   see        FilterQ, CountWhere, MapFiltered
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

	# Folds the whole list to one value with a named operation.
	#
	#   pcOp       the operation: :Sum, :Product, :Min, :Max, :Count, :CountStrings, :CountNumbers,
	#              :Concat, :AnyTrue, :AllTrue (or its code 0-9)
	#   returns    a number, or 0 when the list is empty or the name is unknown
	#   note       an empty list answers 0 for every operation, including Product, Min and Max
	#   see        ReduceConcat, Sum, MaxValue
	def Reduce(pcOp)
		_nRedOp_ = _ReduceOpCode(pcOp)
		if _nRedOp_ = -1 return 0 ok
		return StzEngineYielderReduceDirect(@aContent, _nRedOp_)

	# Joins every item, written as text, into one text with the separator between them.
	#
	#   pcSep      the text put between two items
	#   returns    a text
	#   note       numbers are written as text; an empty list gives the empty text
	#   see        Concat, Reduce
	def ReduceConcat(pcSep)
		return StzEngineYielderReduceConcatDirect(@aContent, pcSep)

	  #-------------------#
	 #   FILTER + MAP    #
	#-------------------#

	# Returns the items that pass a test, each transformed, in one pass; the held list is not changed.
	#
	#   pcFilterOp      the test, as for Filter
	#   pcTransformOp   the operation applied to the survivors, as for Map
	#   returns         a list; the content unchanged when either name is unknown
	#   note            the test runs first: [1,-2,3,-4,5] with :IsPositive and :Square gives [1, 9,
	#                   25]
	#   see             Filter, Map, MapFilteredQ
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

	# Returns how many items pass a named test.
	#
	#   pcOp       the test, as for Filter
	#   returns    a number; 0 when the test name is unknown
	#   see        Filter, CountItems
	def CountWhere(pcOp)
		_nCwOp_ = _FilterOpCode(pcOp)
		if _nCwOp_ = -1 return 0 ok
		return StzEngineYielderCountWhereDirect(@aContent, _nCwOp_)

	  #---------------------#
	 #  CONVENIENCE NAMES  #
	#---------------------#

	# Returns the list with every number replaced by its absolute value; the held list is not changed.
	#
	#   returns    a list of the same length
	#   note       text items stay as they are
	#   see        Map, Negate
	#@ aka  Map shortcuts
	def Abs()
		return This.Map(:Abs)

	# Returns the list with every number given the opposite sign; the held list is not changed.
	#
	#   returns    a list of the same length
	#   see        Abs, Map
	def Negate()
		return This.Map(:Negate)

	# Returns the list with every number multiplied by two; the held list is not changed.
	#
	#   returns    a list of the same length
	#   see        Square, Map
	def DoubleValues()
		return This.Map(:Double)

	# Returns the list with every number multiplied by itself; the held list is not changed.
	#
	#   returns    a list of the same length
	#   see        DoubleValues, Map
	def Square()
		return This.Map(:Square)

	# Returns the type of every item as a word: int, float, string or list.
	#
	#   returns    a list of texts, same length
	#   see        Map, Strings
	def TypeNames()
		return This.Map(:TypeName)

	# Returns the length of every text item; a number item answers 0.
	#
	#   returns    a list of numbers, same length
	#   see        Map, Uppercase
	def StringLengths()
		return This.Map(:StrLen)

	# Returns the list with every text item in capitals; numbers stay as they are.
	#
	#   returns    a list of the same length
	#   note       it works on bytes, so a letter outside ASCII is not changed
	#   see        Lowercase, Map
	def Uppercase()
		return This.Map(:StrUpper)

	# Returns the list with every text item in small letters; numbers stay as they are.
	#
	#   returns    a list of the same length
	#   note       it works on bytes, so a letter outside ASCII is not changed
	#   see        Uppercase, Map
	def Lowercase()
		return This.Map(:StrLower)

	# Returns the list with the spaces cut from both ends of every text item.
	#
	#   returns    a list of the same length
	#   see        Map, Reversed
	def Trimmed()
		return This.Map(:StrTrim)

	# Returns the list with the characters of every text item in reverse order; the order of the items is not changed.
	#
	#   returns    a list of the same length
	#   note       it reverses each item, not the list: " Hello" becomes "olleH "
	#   see        Map, Trimmed
	def Reversed()
		return This.Map(:StrReverse)

	# Returns the sign of every number: 1, -1 or 0.
	#
	#   returns    a list of numbers, same length
	#   see        Map, Abs
	def Signs()
		return This.Map(:Sign)

	# Returns only the text items, the empty text included.
	#
	#   returns    a list
	#   see        Numbers, Filter
	#@ aka  Filter shortcuts
	def Strings()
		return This.Filter(:IsString)

	# Returns only the number items.
	#
	#   returns    a list
	#   see        Strings, Filter
	def Numbers()
		return This.Filter(:IsNumber)

	# Returns only the numbers above zero.
	#
	#   returns    a list
	#   see        Negatives, Filter
	def Positives()
		return This.Filter(:IsPositive)

	# Returns only the numbers below zero.
	#
	#   returns    a list
	#   see        Positives, Filter
	def Negatives()
		return This.Filter(:IsNegative)

	# Returns only the even numbers; zero counts as even.
	#
	#   returns    a list
	#   see        Odds, Filter
	def Evens()
		return This.Filter(:IsEven)

	# Returns only the odd numbers.
	#
	#   returns    a list
	#   see        Evens, Filter
	def Odds()
		return This.Filter(:IsOdd)

	# Returns the items that are not empty, so the empty text is dropped and every number stays.
	#
	#   returns    a list
	#   see        Filter, Strings
	def NonEmpty()
		return This.Filter(:IsNotEmpty)

	# Returns the sum of the numbers in the list.
	#
	#   returns    a number; 0 for an empty list
	#   see        Product, Reduce
	#@ aka  Reduce shortcuts
	def Sum()
		return This.Reduce(:Sum)

	# Returns the product of the numbers in the list.
	#
	#   returns    a number; 0 for an empty list
	#   see        Sum, Reduce
	def Product()
		return This.Reduce(:Product)

	# Returns the smallest number in the list.
	#
	#   returns    a number; 0 for an empty list
	#   see        MaxValue, Reduce
	def MinValue()
		return This.Reduce(:Min)

	# Returns the largest number in the list.
	#
	#   returns    a number; 0 for an empty list
	#   see        MinValue, Reduce
	def MaxValue()
		return This.Reduce(:Max)

	# Returns how many items the list has, by the engine count.
	#
	#   returns    a number
	#   see        NumberOfItems, Reduce
	def CountItems()
		return This.Reduce(:Count)

	# Returns how many items are text.
	#
	#   returns    a number
	#   see        CountNumbers, Strings
	def CountStrings()
		return This.Reduce(:CountStrings)

	# Returns how many items are numbers.
	#
	#   returns    a number
	#   see        CountStrings, Numbers
	def CountNumbers()
		return This.Reduce(:CountNumbers)

	def Concat(pcSep)
		return This.ReduceConcat(pcSep)

	# Returns 1 if at least one item is non-zero, else 0.
	#
	#   returns    1 or 0
	#   note       the answer is a number, not TRUE or FALSE
	#   see        AllTrue, Reduce
	def AnyTrue()
		return This.Reduce(:AnyTrue)

	# Returns 1 if every item is non-zero, else 0.
	#
	#   returns    1 or 0
	#   note       the answer is a number, not TRUE or FALSE
	#   see        AnyTrue, Reduce
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
