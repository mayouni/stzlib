

func StzList2D(paList)
	return new stzList2D(paList)

	func StzList2DQ(paList)
		return new stzList2D(paList)

	func Stz2DList(paList)
		return new stzList2D(paList)

	func Stz2DListQ(paList)
		return new stzList2D(paList)

func IsList2D(paList)
	if NOT (isList(paList) and IsListOfLists(paList))
		StzRaise("Incorrect param type! paList must be a list of lists.")
	ok

	_nLen_ = len(paList)
	_nLen1_ = len(paList[1])

	for i = 2 to _nLen_
		if len(paList[i]) != _nLen1_
			return 0
		ok
	next

	return 1

	func @IsList2D(paList)
		return IsList2D(paList)

	func Is2DList(paList)
		return IsList2D(paList)

	func @Is2DList(paList)
		return IsList2D(paList)

func Transpose(aList2D)

	if NOT isList(aList2D)
		StzRaise("Incorrect param type! aList2D must be a list.")
	ok

    # Handle edge cases
    _nRows_ = len(aList2D)
    if _nRows_ = 0
        StzRaise("Can't transpose an empty list!")
    ok

	if NOT isList(aList2D[1])
		StzRaise("Can't transpose the list! Incorrect format.")
	ok

    _nCols_ = len(aList2D[1])

    # Verify all sublists have the same length

	for i = 1 to _nRows_
        if not (isList(aList2D[i]) and len(aList2D[i]) = _nCols_)
           StzRaise("Can't transpose the list! Incorrect format.")
        ok
    next

    # Initialize the transposed matrix: nCols rows, each with nRows elements
    _aTransposed_ = []
    for i = 1 to _nCols_
        _aNewRow_ = []
        for j = 1 to _nRows_
            _aNewRow_ + aList2D[j][i]
        next
        _aTransposed_ + _aNewRow_
    next

    return _aTransposed_

	#< @FunctionAlternativeForms

	func SwapColsAndRows(aList2D)
		return Transpose(aList2D)

	func SwitchColsAndRows(aList2D)
		return Transpose(aList2D)

	func @Transpose(aList2D)
		return Transpose(aList2D)

	func @SwapColsAndRows(aList2D)
		return Transpose(aList2D)

	func @SwitchColsAndRows(aList2D)
		return Transpose(aList2D)

	#>

class stz2DList from stzList2D

# Holds a rectangular list of lists, every row the same length, and turns its rows into columns and back.
#
# The rectangle is checked when the object is built: a ragged list raises an error then. It is a
# stzListOfLists, so the list-of-lists methods are inherited; this class adds the transposition
# under its many names (Transpose, Turn, SwapColsAndRows, SwitchRowsAndCols ...), which all do the
# same in-place turn, and Transposed for a copy. Build one with new stzList2D(aList),
# StzList2D(aList) or Stz2DList(aList); the global Transpose(aList) works on a bare list. Items can
# be of any kind, Hebrew, Arabic and emoji texts included.
#
#   receiver   o1 = new stzList2D([ [ 1, 2, 3 ], [ 4, 5, 6 ] ])
#   example    ? @@( o1.Transposed() )
#              #--> [ [ 1, 4 ], [ 2, 5 ], [ 3, 6 ] ]
#              o1.Transpose()
#              ? @@( o1.Content() )
#              #--> [ [ 1, 4 ], [ 2, 5 ], [ 3, 6 ] ]
#   see        stzListOfLists, stzList
class stzList2D from stzListOfLists

	# Builds a 2D list from a list of lists that all have the same length, raising an error when they do not.
	#
	#   paList     the rows, a list of lists of equal length
	#   returns    nothing; the object is built
	#   warning    a ragged list such as [ [1,2], [3] ] raises "Can't create the stzList2D object!
	#              You must provide a well-formatted 2D list."
	#   see        List2D, Transposed
	def init(paList)

		if CheckParams()
			if NOT @IsList2D(paList)
				StzRaise("Can't create the stzList2D object! You must provide a well-formatted 2D list.")
			ok
		ok

		This.@aContent = paList

		# Returns the rows of the 2D list as a plain list of lists.
		#
		#   returns    a list of lists, the same as Content
		#   see        Transposed
		def List2D()
			return super.Content()

	# Turns rows into columns in place, so a list of 2 rows of 3 becomes 3 rows of 2.
	#
	#   returns    nothing; the object now holds the transposed rows, and use TransposeQ to chain
	#   note       calling it twice gives back the original; Transposed leaves the object alone
	#   see        Transposed, Turn
	#@ aka  Swappingg columns and rows
	def Transpose()
	    This.UpdateWith(@Transpose(This.Content()))

		def TransposeQ()
			This.Transpose()
			return This

		# Turns rows into columns in place, exactly as Transpose does.
		#
		#   returns    nothing; use TurnQ to chain
		#   see        Transpose
		def Turn()
			This.Transpose()

			def TurnQ()
				return This.TransposeQ()

		# Turns rows into columns in place, exactly as Transpose does.
		#
		#   returns    nothing; use SwapColsAndRowsQ to chain
		#   see        Transpose
		def SwapColsAndRows()
			This.Transpose()

			def SwapColsAndRowsQ()
				return This.TransposeQ()

		# Turns rows into columns in place, exactly as Transpose does.
		#
		#   returns    nothing; use SwapRowsAndColsQ to chain
		#   see        Transpose
		def SwapRowsAndCols()
			This.Transpose()

			def SwapRowsAndColsQ()
				return This.TransposeQ()
		

		# Turns rows into columns in place, exactly as Transpose does.
		#
		#   returns    nothing; use SwitchColsAndRowsQ to chain
		#   see        Transpose
		def SwitchColsAndRows()
			This.Transpose()

			def SwitchColsAndRowsQ()
				return This.TransposeQ()

		# Turns rows into columns in place, exactly as Transpose does.
		#
		#   returns    nothing; use SwitchRowsAndColsQ to chain
		#   see        Transpose
		def SwitchRowsAndCols()
			This.Transpose()

			def SwitchRowsAndColsQ()
				return This.TransposeQ()

	# Returns a transposed copy, rows turned into columns, and leaves the object unchanged.
	#
	#   returns    a list of lists
	#   see        Transpose
	def Transposed()
		return @Transpose(This.Content())

		def ColsAndRowsSwapped()
			return This.Transposed()

		def RowsAndColsSwapped()
			return This.Transposed()

		def ColsAndRowsSwitched()
			return This.Transposed()

		def RowsAndColsSwitched()
			return This.Transposed()
