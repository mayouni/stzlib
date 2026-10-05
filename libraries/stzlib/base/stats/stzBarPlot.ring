
# Simple rounding that avoids heavy stzNumber dependency
func _PlotRound(nNumber, nDecimals)
	_nPrFactor_ = 1
	for _iPr_ = 1 to nDecimals
		_nPrFactor_ = _nPrFactor_ * 10
	next
	_nPrResult_ = floor(nNumber * _nPrFactor_ + 0.5) / _nPrFactor_
	# Format with correct decimal places
	_cPrResult_ = "" + _nPrResult_
	_nPrDot_ = StzFindFirst(".", _cPrResult_)
	if _nPrDot_ = 0
		_cPrResult_ = _cPrResult_ + "."
		for _iPr_ = 1 to nDecimals
			_cPrResult_ = _cPrResult_ + "0"
		next
	else
		_nPrHave_ = StzLen(_cPrResult_) - _nPrDot_
		if _nPrHave_ < nDecimals
			for _iPr_ = 1 to (nDecimals - _nPrHave_)
				_cPrResult_ = _cPrResult_ + "0"
			next
		ok
	ok
	return _cPrResult_

func StzPlotQ(pcChartType, paDataSet)
	if CheckParams()
		if NOT isString(pcChartType)
			StzRaise("Incorrect param type! pcChartType must be a string.")
		ok
	ok

	switch StzLower(pcChartType)
	on :VBar
		return new stzVBarChart(paDataSet)

	on :HBar
		return new stzHBarChart(paDataSet)

	on :Histogram
		return new stzHistogram(paDataSet)

	on :MBar
		return new stzMBarPlot(paDataSet)
	on :MultiBar
		return new stzMBarPlot(paDataSet)

	on :Scatter
		return new stzScatterPlot(paDataSet)

	on :Surface
		return new stzSurfacePlot(paDataSet)

	on :Square
		return new stzSquarePlot(paDataSet)

	other
		StzRaise("Insupported chart type!")
	off

	func StzChartQ(pcChartType, paDataSet)
		return StzPlotQ(pcChartType, paDataSet)


class stzVBarChart from stzBarPlot
class stzBarChart from stzBarPlot
class stzVBarPlot from stzBarPlot

# Draws a list of numbers, or labelled numbers, as vertical bars: as text for a terminal, as SVG, or as a PNG picture.
#
# One plot object answers three ways. ToString (and Show) draws block characters, axes and labels in
# text; ToSVG needs no graphics device; ToPNG draws on the GPU. The setters (height, bar width and
# spacing, axes, labels, values, percentages, average line, characters) shape the text picture only:
# the SVG and PNG carry the values, the labels, AddValues and AddAverage and nothing else, and print
# no text unless a :Font option is given. Bars are scaled so the largest value fills the height.
# Setters answer nothing, so they cannot be chained. stzHBarPlot (sideways bars) and stzMBarPlot
# (grouped bars) inherit from it. Several settings store a value no picture reads today (SetWidth,
# SetMaxWidth and the width of SetSize), SetMaxLabelWidth does not truncate, and SetLabelChar
# renames labels taken from the keys; see their warnings. Gallery: doc/gallery/stzBarPlot/basic.png
# (average line), values.png (values above twelve bars) and nofont.png (no font: bars and gridlines
# only), each with its .ring script, seen right by stzlib-docs visual pass (a model reading the
# PNG), 2026-10-05, not a person; terminal.txt is the text picture, read as text and judged right.
#
#   receiver   o1 = new stzBarPlot([ :Jan = 34, :Feb = 58, :Mar = 47 ])
#   example    ? @@( o1.Values() )
#              #--> [ 34, 58, 47 ]
#              ? @@( o1.Labels() )
#              #--> [ "Jan", "Feb", "Mar" ]
#   see        stzHBarPlot, stzMBarPlot, stzHistogram, stzCanvas
class stzBarPlot from stzObject

	# Data properties
	@anValues = []
	@acLabels = []
	@acCanvas = []

	# Display options
	@bShowHAxis = 1
	@bShowVAxis = 1
	@bShowLabels = 1
	@bShowAxisLabels = 1

	@bShowAverage = 0
	@bShowValues = 0
	@bShowPercent = 0

	# Dimensions
	@nWidth = 60
	@nHeight = 7
	@nBarWidth = 2
	@nMaxWidth = 120
	@nMaxLabelWidth = 12
	@nBarInterSpace = 1

	# Characters
	@cBarChar = "█"
	@cTopChar = "█"
	@cVAxisChar = "│"
	@cHAxisChar = "─"
	@cVArrowChar = "↑"
	@cHArrowChar = ">"
	@cVArrowChar = "▲"
	@cHArrowChar = "►"
	@cOriginChar = "╰"
	@cAverageChar = "-"
	@cLabelChar = "X"

	# Layout constants
	@nVAxisWidth = 1
	@nAxisPadding = 1

	# Calculated values
	@nMaxValue = 0
	@nSum = 0
	@nAverage = 0

	# Builds a vertical bar plot from a list of numbers or from a hash list of label = number pairs; raises an error for any other data.
	#
	#   paDataSet   The values to draw: a list of numbers (labelled X1, X2 ...), or pairs such as [
	#               :Jan = 34, :Feb = 58 ] whose keys become the labels
	#   returns     nothing; the plot is built
	#   note        negative numbers raise "All values must be positive numbers" and zero is
	#               accepted
	#   warning     An empty list raises R14 (Capitalised called on the keys) and a hash list
	#               holding a non-number raises R2 instead of the intended messages
	#   see         Values, Labels
	def init(paDataSet)
		if not isList(paDataSet)
			StzRaise("Dataset must be a list")
		ok

		_processDataSet(paDataSet)
		_calculateMetrics()

	# --- Data Processing ---

	def _processDataSet(paDataSet)
		if IsListOfNumbers(paDataSet)
			# Convert simple number list to labeled data
			@anValues = paDataSet
			@acLabels = []
			_nLen_ = len(paDataSet)

			for i = 1 to _nLen_
				@acLabels + (@cLabelChar + i)
			next

		but IsHashListOfNumbers(paDataSet)
			# Extract keys and values from hashlist
			_oHash_ = new stzHashList(paDataSet)
			@anValues = _oHash_.Values()
			@acLabels = _oHash_.KeysQ().Capitalised()

		but IsHashList(paDataSet)
			_oHash_ = new stzHashList(paDataSet)
			_aValues_ = _oHash_.Values()

			if IsListOfNumbers(_aValues_)
				@anValues = _aValues_
				_aBpKeys_ = _oHash_.Keys()
				@acLabels = []
				_n_aBpKeysLen_ = len(_aBpKeys_)
				for _iBpK_ = 1 to _n_aBpKeysLen_
					@acLabels + StzCapitalize(_aBpKeys_[_iBpK_])
				next
			ok
			
		else
			StzRaise("Dataset must be a list of numbers or hashlist with numeric values")
		ok

		# Validate positive numbers
		_nAnValues1Len_ = len(@anValues)
		for _iLoopAnValues1_ = 1 to _nAnValues1Len_
			_nVal_ = @anValues[_iLoopAnValues1_]
			if _nVal_ < 0
				StzRaise("All values must be positive numbers")
			ok
		next

	def _calculateMetrics()
		@nMaxValue = max(@anValues)
		@nSum = @sum(@anValues)
		@nAverage = @nSum / len(@anValues)

	# Sets how many rows and columns the plot is asked to use; the height is drawn, the width is only remembered.
	#
	#   nWidth     The width in characters, raised to 20 when smaller
	#   nHeight    The height of the bar area in rows, raised to 6 when smaller
	#   returns    nothing; the plot changes
	#   note       the picture is as wide as its bars and labels need
	#   warning    The width is stored but neither ToString nor the pixel output reads it, so only
	#              nHeight changes the picture
	#   see        Size, SetHeight, SetWidth
	# --- Configuration Methods ---
	def SetSize(nWidth, nHeight)
		@nWidth = max([20, nWidth])
		@nHeight = max([6, nHeight])

	# Returns the height and the width the plot is set to, in that order.
	#
	#   returns    a list of two numbers [ height, width ]
	#   note       the defaults are [ 7, 60 ]
	#   see        SizeHV, SizeVH, SetSize
	def Size()
		return [@nHeight, @nWidth]

		# Returns the width and the height the plot is set to, in that order.
		#
		#   returns    a list of two numbers [ width, height ]
		#   note       the defaults are [ 60, 7 ]
		#   see        Size, SizeVH
		def SizeHV()
			return [@nWidth, @nHeight]

		# Returns the height and the width the plot is set to, in that order.
		#
		#   returns    a list of two numbers [ height, width ]
		#   note       the same answer as Size
		#   see        Size, SizeHV
		def SizeVH()
			return [@nHeight, @nWidth]

	# Returns the width the plot is set to, in characters, which the picture does not use.
	#
	#   returns    a number
	#   note       the default is 60
	#   see        SetWidth, SetSize
	def Width()
		return @nWidth

	# Returns how many rows the bar area is set to use.
	#
	#   returns    a number
	#   note       the default is 7
	#   see        SetHeight, SetSize
	def Height()
		return @nHeight

	# Returns the widest the plot may become, in characters, which the picture does not use.
	#
	#   returns    a number
	#   note       the default is 120
	#   see        SetMaxWidth
	def MaxWidth()
		return @nMaxWidth

	# Sets how many characters wide each bar is drawn; the bar character is repeated that many times.
	#
	#   nWidth     The width of a bar in characters, raised to 1 when smaller
	#   returns    nothing; the plot changes
	#   note       the default is 2
	#   see        SetBarInterSpace, SetBarChar
	def SetBarWidth(nWidth)
		@nBarWidth = max([1, nWidth])

	# Sets how many blank columns separate two neighbouring bars.
	#
	#   nSpacing   The number of blank columns, raised to 0 when negative
	#   returns    nothing; the plot changes
	#   note       the default is 1
	#   see        SetBarWidth
	def SetBarInterSpace(nSpacing)
		@nBarInterSpace = max([0, nSpacing])

		# Sets how many blank columns separate two neighbouring bars, under another name.
		#
		#   nSpacing   The number of blank columns, raised to 0 when negative
		#   returns    nothing; the plot changes
		#   see        SetBarInterSpace
		def SetBarSpace(nSpacing)
			This.SetBarInterSpace(nSpacing)

		# Sets how many blank columns separate two neighbouring bars, in the other word order.
		#
		#   nSpacing   The number of blank columns, raised to 0 when negative
		#   returns    nothing; the plot changes
		#   see        SetBarInterSpace
		def SetInterBarSpace(nSpacing)
			This.SetBarInterSpace(nSpacing)

	# Sets the room each label may take under its bar; a longer label is not cut but spills over the next one.
	#
	#   nWidth     The label room in characters, raised to 3 when smaller
	#   returns    nothing; the plot changes
	#   note       the default is 12
	#   warning    A label longer than the room is still drawn whole and is overwritten by its
	#              neighbour
	#   see        SetLabels
	def SetMaxLabelWidth(nWidth)
		@nMaxLabelWidth = max([3, nWidth])

	# Sets how many rows tall the bar area is drawn.
	#
	#   n          The height in rows, raised to 2 when smaller
	#   returns    nothing; the plot changes
	#   note       a taller bar area shows finer differences between the bars
	#   see        Height, SetSize
	def SetHeight(n)
		@nHeight = max([2, n]) # Minimum 2 for visibility

	# Stores a width that neither the terminal picture nor the pixel output reads, so it changes nothing today.
	#
	#   n          The width in characters, kept as given
	#   returns    nothing; only Width answers differently
	#   note       Width() answers the number set here
	#   warning    The picture is laid out from the bars and labels, so this value is never used
	#   see        Width, SetSize
	def SetWidth(n)
		@nWidth = n

	# Stores a largest width that neither the terminal picture nor the pixel output reads, so it changes nothing today.
	#
	#   n          The largest width in characters, kept as given
	#   returns    nothing; only MaxWidth answers differently
	#   warning    The value is never consulted when the picture is laid out
	#   see        MaxWidth
	def SetMaxWidth(n)
		@nMaxWidth = n

	# Shows or hides the horizontal axis: its line, its origin mark and its arrow.
	#
	#   bShow      1 to show the axis, 0 to hide it
	#   returns    nothing; the plot changes
	#   note       the labels stay under the bars when it is hidden
	#   see        WithoutHAxis, SetVAxis, SetHVAxis
	#@ aka  Display options with H/V naming and XY aliases
	def SetHAxis(bShow)
		@bShowHAxis = bShow

		# Hides the horizontal axis line, its origin mark and its arrow.
		#
		#   returns    nothing; the plot changes
		#   see        SetHAxis, WithoutVAxis
		def WithoutHAxis()
			@bShowHAxis = 0

		# Shows or hides the horizontal axis, under the X name.
		#
		#   bShow      1 to show the axis, 0 to hide it
		#   returns    nothing; the plot changes
		#   note       X is the horizontal axis here
		#   see        SetHAxis
		#@ aka  XY Aliases
		def SetXAxis(bShow)
			This.SetHAxis(bShow)

		# Hides the horizontal axis, under the X name.
		#
		#   returns    nothing; the plot changes
		#   see        WithoutHAxis
		def WithoutXAxis()
			This.WithoutHAxis()

	# Shows or hides the vertical axis: its line, its arrow and the origin mark.
	#
	#   bShow      1 to show the axis, 0 to hide it
	#   returns    nothing; the plot changes
	#   note       the bars and labels keep their place
	#   see        WithoutVAxis, SetHAxis, SetHVAxis
	def SetVAxis(bShow)
		@bShowVAxis = bShow

		# Hides the vertical axis line and its arrow.
		#
		#   returns    nothing; the plot changes
		#   see        SetVAxis, WithoutHAxis
		def WithoutVAxis()
			@bShowVAxis = 0

		# Shows or hides the vertical axis, under the Y name.
		#
		#   bShow      1 to show the axis, 0 to hide it
		#   returns    nothing; the plot changes
		#   note       Y is the vertical axis here
		#   see        SetVAxis
		#@ aka  XY Aliases
		def SetYAxis(bShow)
			This.SetVAxis(bShow)

		# Hides the vertical axis, under the Y name.
		#
		#   returns    nothing; the plot changes
		#   see        WithoutVAxis
		def WithoutYAxis()
			This.WithoutVAxis()

	# Shows or hides the horizontal and the vertical axis, each on its own.
	#
	#   bHShow     1 to show the horizontal axis, 0 to hide it
	#   bVShow     1 to show the vertical axis, 0 to hide it
	#   returns    nothing; the plot changes
	#   see        SetHAxis, SetVAxis, WithoutHVAxis
	def SetHVAxis(bHShow, bVShow)
		@bShowHAxis = bHShow
		@bShowVAxis = bVShow

		# Shows or hides the horizontal and the vertical axis, under the Axies spelling.
		#
		#   bHShow     1 to show the horizontal axis, 0 to hide it
		#   bVShow     1 to show the vertical axis, 0 to hide it
		#   returns    nothing; the plot changes
		#   see        SetHVAxis
		def SetHVAxies(bHShow, bVShow)
			This.SetHVAxis(bHShow, bVShow)

		# Hides both axes, leaving only the bars and their labels.
		#
		#   returns    nothing; the plot changes
		#   see        SetHVAxis, WithoutAxis
		def WithoutHVAxis()
			This.SetHVAxis(0, 0)

		# Hides both axes, under the Axies spelling.
		#
		#   returns    nothing; the plot changes
		#   see        WithoutHVAxis
		def WithoutHVAxies()
			This.SetHVAxis(0, 0)

		# Hides both axes, leaving only the bars and their labels.
		#
		#   returns    nothing; the plot changes
		#   see        WithoutHVAxis
		def WithoutAxis()
			This.SetHVAxis(0, 0)

		# Hides both axes, under the Axies spelling.
		#
		#   returns    nothing; the plot changes
		#   see        WithoutAxis
		def WithoutAxies()
			This.SetHVAxis(0, 0)

		# Shows or hides the horizontal and the vertical axis, under the X and Y names.
		#
		#   bHShow     1 to show the horizontal axis (X), 0 to hide it
		#   bVShow     1 to show the vertical axis (Y), 0 to hide it
		#   returns    nothing; the plot changes
		#   see        SetHVAxis
		#@ aka  XY Aliases
		def SetXYAxis(bHShow, bVShow)
			This.SetHVAxis(bHShow, bVShow)

		# Shows or hides the horizontal and the vertical axis, under the X and Y names and the Axies spelling.
		#
		#   bHShow     1 to show the horizontal axis (X), 0 to hide it
		#   bVShow     1 to show the vertical axis (Y), 0 to hide it
		#   returns    nothing; the plot changes
		#   see        SetXYAxis
		def SetXYAxies(bHShow, bVShow)
			This.SetHVAxis(bHShow, bVShow)

		# Hides both axes, under the X and Y names.
		#
		#   returns    nothing; the plot changes
		#   see        WithoutHVAxis
		def WithoutXYAxis()
			This.SetHVAxis(0, 0)

		# Hides both axes, under the X and Y names and the Axies spelling.
		#
		#   returns    nothing; the plot changes
		#   see        WithoutXYAxis
		def WithoutXYAxies()
			This.SetHVAxis(0, 0)

	# Shows or hides the row of labels under the bars.
	#
	#   bShow      1 to show the labels, 0 to hide them
	#   returns    nothing; the plot changes
	#   note       the row only appears when SetAxisLabels is on too
	#   see        AddLabels, SetAxisLabels
	def SetLabels(bShow)
		@bShowLabels = bShow
	
		# Shows the row of labels under the bars.
		#
		#   returns    nothing; the plot changes
		#   see        SetLabels
		def AddLabels()
			@bShowLabels = 1

	# Renames every label to a character followed by its position, replacing any label the data gave.
	#
	#   _c_        The character put before the position: a single char, 0 for no prefix, or
	#              anything else for X
	#   returns    nothing; the labels change
	#   note       SetLabelChar("Q") gives Q1, Q2, Q3 and a text of more than one character gives
	#              X1, X2, X3
	#   warning    The new names replace even labels taken from the keys, so a plot of months turns
	#              into Q1, Q2, ...
	#   see        Labels, SetLabels
	def SetLabelChar(_c_)

		if isNumber(_c_)

			if _c_ = 0
				_c_ = ""
			else
				_c_ = "X"
			ok

		but NOT (IsChar(_c_) or isNull(_c_))
			_c_ = "X"
		ok

		_nLen_ = len(@acLabels)
		for i = 1 to _nLen_
			@acLabels[i] = (_c_ + i)
		next

	# Shows or hides a dashed line at the mean of the values, with the mean written at its right end.
	#
	#   bShow      1 to draw the line, 0 to hide it
	#   returns    nothing; the plot changes
	#   note       the text picture writes the mean with one decimal and draws the bars over the
	#              line, the pixel picture writes two decimals
	#   see        AddAverage, Average
	def SetAverage(bShow)
		@bShowAverage = bShow

		# Draws a dashed line at the mean of the values, with the mean written at its right end.
		#
		#   returns    nothing; the plot changes
		#   note       the text picture writes the mean with one decimal, the pixel picture with two
		#   see        SetAverage, Average
		def AddAverage()
			@bShowAverage = 1

	# Shows or hides each bar's value above it; showing the values turns the percentages off.
	#
	#   bShow      1 to write the values, 0 to stop
	#   returns    nothing; the plot changes
	#   note       hiding them does not bring a percentage back
	#   see        AddValues, SetPercent
	def SetValues(bShow)
		@bShowValues = bShow
		if bShow
			@bShowPercent = 0
		ok

		# Writes each bar's value above it and turns the percentages off.
		#
		#   returns    nothing; the plot changes
		#   note       the pixel output reads this choice too
		#   see        SetValues, AddPercent
		def AddValues()
			This.SetValues(1)

	# Shows or hides each bar's share of the total above it, such as 41.7%; showing the percentages turns the values off.
	#
	#   bShow      1 to write the percentages, 0 to stop
	#   returns    nothing; the plot changes
	#   note       hiding them does not bring the values back and the pixel output ignores them
	#   see        AddPercent, SetValues
	def SetPercent(bShow)
		@bShowPercent = bShow
		if bShow
			@bShowValues = 0
		ok

		# Writes each bar's share of the total above it, with one decimal, and turns the values off.
		#
		#   returns    nothing; the plot changes
		#   note       the pixel output ignores this choice
		#   see        SetPercent, AddValues
		def AddPercent()
			This.SetPercent(1)

	# Shows or hides the labels under the horizontal axis, whatever SetLabels says.
	#
	#   bShow      1 to show them, 0 to hide them
	#   returns    nothing; the plot changes
	#   note       both this and SetLabels must be on for the label row to appear
	#   see        SetLabels, WithoutAxisLabels
	def SetAxisLabels(bShow)
		@bShowAxisLabels = bShow

		# Shows or hides the labels under the horizontal axis, under the H name.
		#
		#   bShow      1 to show them, 0 to hide them
		#   returns    nothing; the plot changes
		#   see        SetAxisLabels
		def SetHAxisLabels(bShow)
			This.SetAxisLabels(bShow)

		# Shows or hides the labels under the horizontal axis, although the name says Add.
		#
		#   bShow      1 to show them, 0 to hide them
		#   returns    nothing; the plot changes
		#   note       it takes a flag, so AddHAxisLabels(0) hides them
		#   see        SetAxisLabels
		def AddHAxisLabels(bShow)
			This.SetAxisLabels(bShow)

		# Hides the labels under the horizontal axis.
		#
		#   returns    nothing; the plot changes
		#   see        SetAxisLabels
		def WithoutAxisLabels()
			This.SetAxisLabels(0)

		# Hides the labels under the horizontal axis, under the H name.
		#
		#   returns    nothing; the plot changes
		#   see        WithoutAxisLabels
		def WithoutHAxisLabels()
			This.SetAxisLabels(0)

	# Sets the character the bars are drawn with, top row included; a text of more than one character is ignored.
	#
	#   _cChar_    The single character to draw bars with
	#   returns    nothing; the plot changes
	#   note       call SetTopChar afterwards for a different top row
	#   see        SetTopChar, SetBarWidth
	#@ aka  Character customization with H/V naming
	def SetBarChar(_cChar_)
		if IsChar(_cChar_)
			@cBarChar = _cChar_
			if @cTopChar != _cChar_
				@cTopChar = _cChar_
			ok
		ok

	# Sets the character that draws the top row of each bar; a text of more than one character is ignored.
	#
	#   _cChar_    The single character for the top row
	#   returns    nothing; the plot changes
	#   see        SetBarChar
	def SetTopChar(_cChar_)
		if IsChar(_cChar_)
			@cTopChar = _cChar_
		ok

	# Sets the characters that draw the horizontal and the vertical axis lines; an argument that is not a single character is skipped.
	#
	#   cH         The single character for the horizontal axis line
	#   cV         The single character for the vertical axis line
	#   returns    nothing; the plot changes
	#   note       the arrows and the origin mark keep their own characters
	#   see        SetBarChar
	def SetAxisChars(cH, cV)
		if IsChar(cH)
			@cHAxisChar = cH
		ok
		if IsChar(cV)
			@cVAxisChar = cV
		ok

	# --- Layout Calculation ---

	def _calculateLayout()
		_nBars_ = len(@anValues)
		
		# Calculate element widths (max of bar, label, value widths)
		_aElementWidths_ = []
		for i = 1 to _nBars_
			_nMaxWidth_ = @nBarWidth
			
			# Check label width (only if labels will actually be displayed)
			if @bShowLabels and @bShowAxisLabels and i <= len(@acLabels)
				_nLabelWidth_ = min([len(@acLabels[i]), @nMaxLabelWidth])
				_nMaxWidth_ = max([_nMaxWidth_, _nLabelWidth_])
			ok
			
			# Check value/percent width
			if @bShowValues
				_nValueWidth_ = len("" + @anValues[i])
				_nMaxWidth_ = max([_nMaxWidth_, _nValueWidth_])
			but @bShowPercent and @nSum > 0
				_nPercent_ = (@anValues[i] * 100) / @nSum
				_nValueWidth_ = len('' + _PlotRound(_nPercent_, 1) + "%")
				_nMaxWidth_ = max([_nMaxWidth_, _nValueWidth_])
			ok
			
			_aElementWidths_ + _nMaxWidth_
		next
		
		# Calculate total width needed
		_nBarsWidth_ = @sum(_aElementWidths_) + (_nBars_ - 1) * @nBarInterSpace
		_nBaseWidth_ = _nBarsWidth_ + iff(@bShowVAxis, @nVAxisWidth + @nAxisPadding, 0) + 2
		
		# Add space for average value if shown
		if @bShowAverage
		    _nAvgValueWidth_ = len("" + _PlotRound(@nAverage, 1))
		    _nTotalWidth_ = _nBaseWidth_ + 2 + _nAvgValueWidth_
		else
		    _nTotalWidth_ = _nBaseWidth_
		ok
		
		# Calculate layout dimensions - only allocate rows for visible components
		_nBarsHeight_ = @nHeight
		_nCurrentRow_ = 1
		
		# V-axis arrow row (only if V-axis shown)
		if @bShowVAxis
			_nCurrentRow_ = 2  # Arrow goes in row 1, content starts at row 2
		ok
		
		# Values row (only if shown)
		_nValuesRow_ = 0
		if @bShowValues or @bShowPercent
			_nValuesRow_ = _nCurrentRow_
			_nCurrentRow_ += 1
		ok
		
		# V-axis starts after arrow and values (only if V-axis shown)
		_nVAxisStart_ = iff(@bShowVAxis, 2, 1)
		
		# Bars area
		_nBarsStartRow_ = _nCurrentRow_
		_nBarsEndRow_ = _nCurrentRow_ + _nBarsHeight_ - 1
		_nCurrentRow_ = _nBarsEndRow_ + 1
		
		# H-axis row (only if shown)
		_nHAxisRow_ = 0
		if @bShowHAxis
			_nHAxisRow_ = _nCurrentRow_
			_nCurrentRow_ += 1
		ok
		
		# Labels row (only if shown AND axis labels enabled)
		_nLabelsRow_ = 0
		if @bShowLabels and @bShowAxisLabels
			_nLabelsRow_ = _nCurrentRow_
			_nCurrentRow_ += 1
		ok
		
		# Total height is the last used row
		_nTotalHeight_ = _nCurrentRow_ - 1
		
		# Column positions
		_nVAxisCol_ = 1
		_nBarsStart_ = iff(@bShowVAxis, @nVAxisWidth + @nAxisPadding + 1, 1)
		
		return [
			:total_width = _nTotalWidth_,
			:total_height = _nTotalHeight_,
			:bars_start = _nBarsStart_,
			:bars_start_row = _nBarsStartRow_,
			:bars_end_row = _nBarsEndRow_,
			:h_axis_row = _nHAxisRow_,
			:values_row = _nValuesRow_,
			:labels_row = _nLabelsRow_,
			:v_axis_col = _nVAxisCol_,
			:v_axis_start = _nVAxisStart_,
			:bars_height = _nBarsHeight_,
			:element_widths = _aElementWidths_
		]

	# --- Canvas Operations ---

	def _initCanvas(nWidth, nHeight)
		@acCanvas = []
		for i = 1 to nHeight
			_aRow_ = []
			for j = 1 to nWidth
				_aRow_ + " "
			next
			@acCanvas + _aRow_
		next

	def _setChar(_nRow_, _nCol_, _cChar_)
		if _nRow_ >= 1 and _nRow_ <= len(@acCanvas) and
		   _nCol_ >= 1 and _nCol_ <= len(@acCanvas[1])
			@acCanvas[_nRow_][_nCol_] = _cChar_
		ok

	# --- Drawing Methods ---

	def _drawVAxis(_oLayout_)
		if not @bShowVAxis
			return
		ok
		
		_nCol_ = _oLayout_[:v_axis_col]
		_nStartRow_ = _oLayout_[:v_axis_start]
		_nEndRow_ = iff(_oLayout_[:h_axis_row] > 0, _oLayout_[:h_axis_row], _oLayout_[:bars_end_row] + 1)
		
		# Draw arrow at top (always in row 1)
		_setChar(1, _nCol_, @cVArrowChar)
		
		# Draw vertical line
		for i = _nStartRow_ to _nEndRow_
			_setChar(i, _nCol_, @cVAxisChar)
		next

	def _drawHAxis(_oLayout_)
		if not @bShowHAxis or _oLayout_[:h_axis_row] = 0
			return
		ok
		
		_nRow_ = _oLayout_[:h_axis_row]
		_nStart_ = iff(@bShowVAxis, _oLayout_[:v_axis_col], _oLayout_[:bars_start])
		_nEnd_ = _oLayout_[:total_width] - iff(@bShowAverage, len("" + _PlotRound(@nAverage, 1)) + 2, 0) - 1
		
		# Draw horizontal line
		for i = _nStart_ to _nEnd_
			_setChar(_nRow_, i, @cHAxisChar)
		next
		
		# Draw origin and arrow
		if @bShowVAxis
			_setChar(_nRow_, _oLayout_[:v_axis_col], @cOriginChar)
		ok
		_setChar(_nRow_, _nEnd_ + 1, @cHArrowChar)

	def _drawBars(_oLayout_)
		_nBars_ = len(@anValues)
		_nCurrentH_ = _oLayout_[:bars_start]
		_nBarsStartRow_ = _oLayout_[:bars_start_row]
		_nBarsEndRow_ = _oLayout_[:bars_end_row]
		_nBarsHeight_ = _oLayout_[:bars_height]
		_aElementWidths_ = _oLayout_[:element_widths]
		
		for i = 1 to _nBars_
			_nValue_ = @anValues[i]
			_nElementWidth_ = _aElementWidths_[i]
			
			# Calculate bar height
			_nBarHeight_ = 0
			if @nMaxValue > 0 and _nValue_ > 0
				_nBarHeight_ = max([1, ceil(_nBarsHeight_ * _nValue_ / @nMaxValue)])
			ok
			
			# Calculate bar position (centered in element)
			_nBarStart_ = _nCurrentH_ + floor((_nElementWidth_ - @nBarWidth) / 2)
			
			# Draw bar from bottom up
			for j = 1 to _nBarHeight_
				for k = 1 to @nBarWidth
					_nCol_ = _nBarStart_ + k - 1
					_nRow_ = _nBarsEndRow_ - j + 1  # Draw from bottom up
					
					_cChar_ = @cBarChar
					if j = _nBarHeight_ and @cTopChar != ""
						_cChar_ = @cTopChar
					ok
					
					_setChar(_nRow_, _nCol_, _cChar_)
				next
			next
			
			# Move to next position
			if i < _nBars_
				_nCurrentH_ += _nElementWidth_ + @nBarInterSpace
			ok
		next

	def _drawValues(_oLayout_)
		if not (@bShowValues or @bShowPercent) or _oLayout_[:values_row] = 0
			return
		ok
		
		_nBars_ = len(@anValues)
		_nCurrentH_ = _oLayout_[:bars_start]
		_nBarsStartRow_ = _oLayout_[:bars_start_row]
		_nBarsHeight_ = _oLayout_[:bars_height]
		_aElementWidths_ = _oLayout_[:element_widths]
		
		for i = 1 to _nBars_
			_nValue_ = @anValues[i]
			_nElementWidth_ = _aElementWidths_[i]
			
			# Format value
			_cValue_ = ""
			if @bShowValues
				if IsInteger(_nValue_)
					_cValue_ = "" + _nValue_
				else
					_cValue_ = "" + _PlotRound(_nValue_, 1)
				ok
			but @bShowPercent and @nSum > 0
				_nPercent_ = _PlotRound((_nValue_ * 100) / @nSum, 1)
				_cValue_ = '' + _nPercent_ + "%"
			ok
			
			# Calculate bar height to position value above it
			_nBarHeight_ = 0
			if @nMaxValue > 0 and _nValue_ > 0
				_nBarHeight_ = max([1, ceil(_nBarsHeight_ * _nValue_ / @nMaxValue)])
			ok
			
			# Position value just above the bar top
			_nValueRow_ = _nBarsStartRow_ + _nBarsHeight_ - _nBarHeight_ - 1
			if _nValueRow_ < 1
				_nValueRow_ = 1  # Ensure it's within canvas bounds
			ok
			
			# Center value horizontally
			_nValueStart_ = _nCurrentH_ + floor((_nElementWidth_ - len(_cValue_)) / 2)
			
			# Draw value
			_nLen_ = len(_cValue_)
			for j = 1 to _nLen_
				if _nValueStart_ + j - 1 <= _oLayout_[:total_width]
					_setChar(_nValueRow_, _nValueStart_ + j - 1, _cValue_[j])
				ok
			next
			
			# Move to next position
			if i < _nBars_
				_nCurrentH_ += _nElementWidth_ + @nBarInterSpace
			ok
		next

	def _drawLabels(_oLayout_)
		if not @bShowLabels or not @bShowAxisLabels or _oLayout_[:labels_row] = 0
			return
		ok
		
		_nBars_ = len(@anValues)
		_nCurrentH_ = _oLayout_[:bars_start]
		_nLabelsRow_ = _oLayout_[:labels_row]
		_aElementWidths_ = _oLayout_[:element_widths]
		
		for i = 1 to _nBars_
			if i <= len(@acLabels)
				_cLabel_ = @acLabels[i]
				_nElementWidth_ = _aElementWidths_[i]
				
				# Truncate if needed
				if len(_cLabel_) > @nMaxLabelWidth
					_cLabel_ = Left(_cLabel_, @nMaxLabelWidth - 2) + ".."
				ok
				
				# Center label
				_nLabelStart_ = _nCurrentH_ + floor((_nElementWidth_ - len(_cLabel_)) / 2)
				
				# Draw label
				_nLen_ = len(_cLabel_)
				for j = 1 to _nLen_
					_setChar(_nLabelsRow_, _nLabelStart_ + j - 1, _cLabel_[j])
				next
			ok
			
			# Move to next position
			if i < _nBars_
				_nCurrentH_ += _aElementWidths_[i] + @nBarInterSpace
			ok
		next

	def _drawAverage(_oLayout_)
		if not @bShowAverage
			return
		ok
		
		_nBarsStartRow_ = _oLayout_[:bars_start_row]
		_nBarsHeight_ = _oLayout_[:bars_height]
		_nStart_ = iff(@bShowVAxis, _oLayout_[:v_axis_col] + 1, _oLayout_[:bars_start])
		_nEnd_ = _oLayout_[:total_width] - iff(@bShowAverage, len("" + _PlotRound(@nAverage, 1)) + 2, 0)
		
		# Calculate average line position
		_nAvgRow_ = _nBarsStartRow_ + _nBarsHeight_ - 1
		if @nMaxValue > 0
			_nAvgHeight_ = ceil(_nBarsHeight_ * @nAverage / @nMaxValue)
			_nAvgRow_ = _nBarsStartRow_ + _nBarsHeight_ - _nAvgHeight_
		ok
		
		# Draw average line
		for i = _nStart_ to _nEnd_
			if _nAvgRow_ >= 1 and _nAvgRow_ <= len(@acCanvas) and
			   i <= len(@acCanvas[1]) and @acCanvas[_nAvgRow_][i] = " "
				_setChar(_nAvgRow_, i, @cAverageChar)
			ok
		next
		
		# Draw average value at the end of the line
		if NOT @bShowValues
			return
		ok

		_cAvgValue_ = "" + _PlotRound(@nAverage, 1)
		_nValueStart_ = _nEnd_ + 2
		_nLen_ = len(_cAvgValue_)
		for j = 1 to _nLen_
		    _nCol_ = _nValueStart_ + j - 1
		    if _nCol_ <= len(@acCanvas[1])  # Check if within canvas bounds
		        _setChar(_nAvgRow_, _nCol_, _cAvgValue_[j])
		    ok
		next

	# Returns the plot as text, drawn from bars, axes and labels, ready to print.
	#
	#   returns    a multi-line string
	#   note       the picture is made by the engine
	#   warning    Raises an error when the engine cannot render the plot
	#   see        Show, ToStringInRing, ToSVG
	# --- Main Methods ---
	#@ aka  THE PICTURE IS RENDERED BY THE ENGINE, in one crossing.
	def ToString()
		_cLabels_ = ""
		_nL_ = len(@acLabels)
		for _i_ = 1 to _nL_
			if _i_ > 1
				_cLabels_ += nl
			ok
			_cLabels_ += @acLabels[_i_]
		next

		_aOpts_ = [
			@nHeight, @nBarWidth, @nBarInterSpace, @nVAxisWidth, @nAxisPadding,
			@nMaxLabelWidth,
			iff(@bShowHAxis, 1, 0), iff(@bShowVAxis, 1, 0),
			iff(@bShowLabels, 1, 0), iff(@bShowAxisLabels, 1, 0),
			iff(@bShowValues, 1, 0), iff(@bShowPercent, 1, 0),
			iff(@bShowAverage, 1, 0),
		# THE CHARACTERS THE CALLER CHOSE, as codepoints on the end of the options.
		# They were dropped when this renderer moved to the engine: SetBarChar and
		# its siblings went on setting an attribute nothing read any more, so they
		# silently did nothing. The Ring renderer below still honoured them, which
		# is how the parity guard would have caught it -- had any case set one.
			StzCharCode(@cBarChar), StzCharCode(@cTopChar),
			StzCharCode(@cHAxisChar), StzCharCode(@cVAxisChar)
		]

		_cOut_ = StzEnginePlotBar(@anValues, _cLabels_, _aOpts_)
		if NOT isString(_cOut_) or _cOut_ = ""
			StzRaise("stzBarPlot: the engine could not render this plot.")
		ok

		# the one host-side special case the renderer does not carry: a bar CHART
		# with a v-axis and no h-axis drops the last │
		if ring_classname(This) = "stzbarchart"
			if @bShowVAxis and not @bShowHAxis
				_oTempStr_ = new stzString(_cOut_)
				_nPos_ = _oTempStr_.FindLast(@cVAxisChar)
				_oTempStr_.ReplacecharAt(_nPos_, " ")
				_cOut_ = _oTempStr_.Content()
			ok
		ok
		return _cOut_

	# Returns the same text picture as ToString, drawn by the Ring code the engine renderer was ported from.
	#
	#   returns    a multi-line string
	#   note       it is slower and kept so a guard can prove the two agree
	#   see        ToString
	#@ aka  The Ring renderer the engine one was ported from. Kept so the guard can prove the two agree character for character on the same input.
	def ToStringInRing()
		_oLayout_ = _calculateLayout()
		_initCanvas(_oLayout_[:total_width], _oLayout_[:total_height])

		_drawVAxis(_oLayout_)
		_drawHAxis(_oLayout_)
		_drawBars(_oLayout_)
		_drawValues(_oLayout_)
		_drawLabels(_oLayout_)
		_drawAverage(_oLayout_)

		return _canvasToString()

	def _canvasToString()
		_cResult_ = ""
		_nRows_ = len(@acCanvas)
		
		for i = 1 to _nRows_
			_cLine_ = ""
			_nLen_ = len(@acCanvas[i])
			for j = 1 to _nLen_
				_cLine_ += @acCanvas[i][j]
			next
			
			if i < _nRows_
				_cResult_ += _cLine_ + nl
			else
				_cResult_ += _cLine_
			ok
		next


		# A hack for removing the │ from a last lin in:
		# ^
		# │    ██    
		# │ ██ ██ ██  
		# │ ██ ██ ██  
		# │ A  B  C   

		# ring_classname(), not classname(): inside a class body the bare
		# name resolves to the ClassName() METHOD inherited from stzObject
		# (0 params, called here with 1) -> R20, which took Show() down for
		# every bar plot. This.ClassName() is not the answer either -- it
		# returns the literal "stzobject" unless a class overrides it.
		if ring_classname(This) = "stzbarchart"
			if @bShowVAxis and not @bShowHAxis
				_oTempStr_ = new stzString(_cResult_)
				_nPos_ = _oTempStr_.FindLast(@cVAxisChar)
				_oTempStr_.ReplacecharAt(_nPos_, " ")
				_cResult_ = _oTempStr_.Content()
			ok
		ok

		return _cResult_

	# Prints the plot as text on the console.
	#
	#   returns    nothing; the plot is printed
	#   see        ToString
	def Show()
		? ToString()

	# Returns the kind of plot, which the pixel output uses to pick its layout.
	#
	#   returns    the symbol :VBar, as the text "vbar"
	#   see        ToCanvasQ
	# --- The pixel backends (GR6, SOFTANZA_GRAPHICS_PLAN.md) ---
	#@ aka  The SAME plot model -- these values, these labels, and the semantic options below -- rendered onto an stzCanvas instead of a codepoint canvas. ToSVG() needs no GPU; ToPNG() draws through one. The terminal picture is untouched: Show() still does exactly what it always did.
	def PlotKind()
		return :VBar

	# Draws the values and labels on a new canvas and answers it, so the same plot can become SVG or PNG.
	#
	#   paOptions   A list of options [ :Width = , :Height = , :Title = , :Font = an stzFont, :Color
	#               = , :Background = , :Grid = , :ShowValues = , :ShowAverage = , :Min = , :Max = ]
	#   returns     an stzCanvas holding the picture
	#   note        without a Font option the picture has no text
	#   warning     Only the values, the labels, AddValues and AddAverage carry over to pixels,
	#               while percentages, axis switches, characters and sizes do not
	#   see         ToSVG, ToPNG, PlotKind
	def ToCanvasQ(paOptions)
		_a_ = paOptions
		if NOT isList(_a_)  _a_ = []  ok
		# the model's own display intent travels with it, unless overridden
		if isNull(_BindingValue(_a_, "showvalues"))
			_a_ + [ :ShowValues, @bShowValues ]
		ok
		if isNull(_BindingValue(_a_, "showaverage"))
			_a_ + [ :ShowAverage, @bShowAverage ]
		ok
		return StzPlotCanvasQ(This.PlotKind(), @anValues, @acLabels, _a_)

	# Returns the plot as SVG text, with no graphics device needed.
	#
	#   paOptions   A list of options [ :Width = , :Height = , :Title = , :Font = an stzFont, ... ],
	#               as for ToCanvasQ
	#   returns     the SVG document as a string
	#   note        the default size is 900 by 500 and text needs a Font
	#   see         ToCanvasQ, ToPNG
	def ToSVG(paOptions)
		# the canvas is TRANSIENT: its engine scene (a target texture on the GPU
		# tier, vertex buffers, the command list) is freed once the answer is taken --
		# a picture per call used to leave a texture live per call (found 2026-09-11)
		_oCv_ = This.ToCanvasQ(paOptions)
		_cOut_ = _oCv_.ToSVG()
		_oCv_.Free()
		return _cOut_

	# Draws the plot on the graphics device and returns the PNG bytes, writing them to a file when a path is given.
	#
	#   pcPath      The file to write, or an empty text to write none
	#   paOptions   A list of options [ :Width = , :Height = , :Title = , :Font = an stzFont, ... ],
	#               as for ToCanvasQ
	#   returns     the PNG bytes as a string, empty when no device is available
	#   note        the default size is 900 by 500
	#   see         ToSVG, ToCanvasQ
	def ToPNG(pcPath, paOptions)
		# the canvas is TRANSIENT: its engine scene (a target texture on the GPU
		# tier, vertex buffers, the command list) is freed once the answer is taken --
		# a picture per call used to leave a texture live per call (found 2026-09-11)
		_oCv_ = This.ToCanvasQ(paOptions)
		_cOut_ = _oCv_.ToPNG(pcPath)
		_oCv_.Free()
		return _cOut_

	# Returns the numbers the bars show, in order.
	#
	#   returns    a list of numbers
	#   see        Labels, Sum
	# --- Accessors ---
	def Values()
		return @anValues

	# Returns the label of each bar, in order, as the picture writes them.
	#
	#   returns    a list of text
	#   note       labels taken from keys are capitalised
	#   see        Values, SetLabelChar
	def Labels()
		return @acLabels

	# Returns the total of all the values.
	#
	#   returns    a number
	#   see        Average, MaxValue
	def Sum()
		return @nSum

	# Returns the mean of the values.
	#
	#   returns    a number
	#   see        Sum, AddAverage
	def Average()
		return @nAverage

	# Returns the largest of the values.
	#
	#   returns    a number
	#   see        Values, Sum
	def MaxValue()
		return @nMaxValue

