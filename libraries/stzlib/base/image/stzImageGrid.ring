#=====================================================================#
#  STZIMAGEGRID -- what an image analysis RETURNS: numbers, never a   #
#  picture (SOFTANZA_VISION_PLAN.md section 3)                        #
#=====================================================================#
/*
	The image plane's counterpart of stzSoundGrid: rows x columns of
	numbers in the engine, behind a gen-keyed handle, with what a row and
	a column MEAN. A histogram is 1 row of 256 levels; ToGrid() of an
	image is Height() rows of Width() pixels, and ToImage() turns it back
	without loss. "The disk's pixels are below the Otsu level" is a claim
	a guard can check; "the picture looks right" is a claim about nothing.
*/

# Holds the numbers an image analysis returns: rows by columns, with what a row and a column mean.
#
# Rows and columns are 1-based. RowMeaning and ColumnMeaning say what they count ("y" and "x" for
# pixels, "level" for a histogram's columns). ToImage turns a grid back into a one-channel image,
# each value rounded and clamped to 0..255, so a grid of pixels makes the image again exactly.
# Release frees the numbers.
#
#   receiver   o1 = StzImageNew(4, 2, 1, 40) o2 = o1.Histogram()
#   example    ? o2.Columns()
#              #--> 256
#              ? o2.At(1, 41)
#              #--> 8
#              ? o2.Sum()
#              #--> 8
#   see        stzImage, stzSoundGrid
class stzImageGrid from stzObject

	@nId = 0
	@cRows = ""
	@cCols = ""

	# Wraps an engine grid handle, with what its rows and columns mean.
	def init(pnGridId, pcRowMeaning, pcColumnMeaning)
		@nId = pnGridId
		@cRows = "" + pcRowMeaning
		@cCols = "" + pcColumnMeaning

	# Returns the number of the engine handle that holds the grid's numbers, 0 once the grid is released.
	#
	#   returns    a number
	#   see        Release
	def GridId()
		return @nId

	# Frees the numbers the grid holds in the engine and clears the grid's handle.
	#
	#   returns    what the engine's free call answers
	#   see        GridId
	def Release()
		_n_ = StzEngineImageGridFree(@nId)
		@nId = 0
		return _n_

	# TRUE if the grid has no rows.
	#
	#   returns    1 or 0
	#   see        Rows, Columns
	def IsEmpty()
		return StzEngineImageGridRows(@nId) = 0

	# Returns the number of rows the grid has.
	#
	#   returns    a number; rows are 1-based
	#   see        Columns, RowMeaning
	def Rows()
		return StzEngineImageGridRows(@nId)

	# Returns the number of columns the grid has.
	#
	#   returns    a number; columns are 1-based
	#   see        Rows, ColumnMeaning
	def Columns()
		return StzEngineImageGridCols(@nId)

	# Returns what a row counts, such as y for the rows of an image's pixels.
	#
	#   returns    a text given when the grid was made
	#   see        ColumnMeaning, Rows
	def RowMeaning()
		return @cRows

	# Returns what a column counts, such as x for pixels or level for a histogram.
	#
	#   returns    a text given when the grid was made
	#   see        RowMeaning, Columns
	def ColumnMeaning()
		return @cCols

	# Returns the number at a row and a column, 1-based; 0 outside the grid.
	def At(pnRow, pnColumn)
		return StzEngineImageGridAt(@nId, pnRow, pnColumn)

	# Returns the largest value in the grid.
	#
	#   returns    a number
	#   see        Min, Peak
	def Max()
		return StzEngineImageGridMax(@nId)

	# Returns the smallest value in the grid.
	#
	#   returns    a number
	#   see        Max
	def Min()
		return StzEngineImageGridMin(@nId)

	# Returns the sum of every value in the grid.
	#
	#   returns    a number
	#   see        Max, Min
	def Sum()
		return StzEngineImageGridSum(@nId)

	# Returns one row as a list of numbers.
	def ToList(pnRow)
		_a_ = []
		_n_ = This.Columns()
		for _i_ = 1 to _n_
			_a_ + StzEngineImageGridAt(@nId, pnRow, _i_)
		next
		return _a_

	# Returns the column of the largest value in a row (the first on a tie).
	def PeakColumnOfRow(pnRow)
		_n_ = This.Columns()
		_nBest_ = 1
		_vBest_ = StzEngineImageGridAt(@nId, pnRow, 1)
		for _i_ = 2 to _n_
			_v_ = StzEngineImageGridAt(@nId, pnRow, _i_)
			if _v_ > _vBest_
				_vBest_ = _v_
				_nBest_ = _i_
			ok
		next
		return _nBest_

	# Returns [ row, column, value ] of the largest value, 1-based; the first on a tie.
	def Peak()
		return StzEngineImageGridArgMax(@nId)

	# Returns a one-channel image of the grid, each value rounded and clamped to 0..255.
	def ToImage()
		return new stzImage(_StzImageMust(StzEngineImageFromGrid(@nId)))

	# Returns a one-channel image of the grid with its values mapped from Min()..Max() onto 0..255.
	#
	#   note       how a spectrum, a derivative or a depth map is made visible; a flat grid gives
	#              mid-gray
	def ToImageScaled()
		return new stzImage(_StzImageMust(StzEngineImageFromGridScaled(@nId)))
