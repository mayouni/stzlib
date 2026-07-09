

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
			return FALSE
		ok
	next

	return TRUE

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

class stzList2D from stzListOfLists

	def init(paList)

		if CheckParams()
			if NOT @IsList2D(paList)
				StzRaise("Can't create the stzList2D object! You must provide a well-formatted 2D list.")
			ok
		ok

		This.@aContent = paList

		def List2D()
			return super.Content()

	# Swappingg columns and rows

	def Transpose()
	    This.UpdateWith(@Transpose(This.Content()))

		def TransposeQ()
			This.Transpose()
			return This

		def Turn()
			This.Transpose()

			def TurnQ()
				return This.TransposeQ()

		def SwapColsAndRows()
			This.Transpose()

			def SwapColsAndRowsQ()
				return This.TransposeQ()

		def SwapRowsAndCols()
			This.Transpose()

			def SwapRowsAndColsQ()
				return This.TransposeQ()
		

		def SwitchColsAndRows()
			This.Transpose()

			def SwitchColsAndRowsQ()
				return This.TransposeQ()

		def SwitchRowsAndCols()
			This.Transpose()

			def SwitchRowsAndColsQ()
				return This.TransposeQ()

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
