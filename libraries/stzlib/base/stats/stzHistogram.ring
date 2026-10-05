
#-------------------------#
#  HISTOGRAM CHART CLASS  #
#-------------------------#

# Bins a list of numbers into equal-width classes and draws the counts, or another aggregate, as touching bars.
#
# Built from raw measurements, it cuts the range into 5 or more bins by Sturges' rule, or into the
# number SetBinCount gives, and each bar shows how many values fall in its bin; UseSum, UseAverage,
# UseMin and UseMax make it show another aggregate. ToString draws the text picture (bin edges in
# two rows under the bars), ToSVG and ToPNG the pixel picture; Mean, StandardDeviation, Median, Mode
# and DataCount describe the data. The text picture is drawn by the engine, except when statistics
# are on or the horizontal axis is off, when the slower Ring renderer takes over and obeys
# SetHeight, SetMaxWidth and AddValues, which the engine route ignores. SetBinRange gives the wrong
# number of bins, SetAggregation with an unknown name leaves the histogram unusable, and the X and Y
# axis names are the reverse of the usual ones; see the warnings. Gallery:
# doc/gallery/stzHistogram/normal.png (200 values, 9 bins), bins20.png (20 bins) and sums.png
# (UseSum), each with its script, seen right by stzlib-docs visual pass (a model reading the PNG),
# 2026-10-05, not a person; terminal.txt is the text picture, read as text and judged right.
#
#   receiver   o1 = new stzHistogram([ 12, 15, 18, 22, 23, 25, 26, 27, 28, 30, 31, 33, 35, 38, 41,
#              45, 52, 58, 61, 70 ])
#   example    ? o1.DataCount()
#              #--> 20
#              ? @@( o1.Mode() )
#              #--> [ 21.67, 31.33 ]
#   see        stzBarPlot, stzDataSet, stzListOfNumbers
class stzHistogram from stzObject

	@bShowVAxis = 1      # Vertical axis (was Y-axis)
	@bShowHAxis = 1      # Horizontal axis (was X-axis)
	@bShowLabels = 1
	@bShowFrequency = 0
	@bShowPercent = 0
	@bShowStats = 0  # Show mean, std dev, etc.

	@nBinCount = 0       # Number of bins (0 = auto-calculate)
	@nBinRange = 0       # Width of each bin (0 = auto-calculate)
	@nBarWidth = 2
	@nMaxWidth = 132
	@nMaxLabelWidth = 12
	@nBarInterSpace = 1
	@nLabelInterSpace = 1

	@cBarChar = char(226) + char(150) + char(136)
	@cFinalBarChar = ""

	# Histogram-specific data
	@aBinRanges = []     # [min, max] for each bin
	@aBinCounts = []     # Frequency count for each bin
	@aBinLabels = []     # Label for each bin (e.g., "20-30")
	@anRawData  = []      # Original data before binning
	@anValues   = []       # Processed values for display
	@acLabels   = []       # Processed labels for display

	# Display canvas and dimensions
	@acCanvas = []
	@nWidth = 0
	@nHeight = 10
	@nMinValue = 0
	@nMaxValue = 0

	# Layout constants
	@nVAxisWidth = 1     # Vertical axis width (was Y-axis)
	@nAxisPadding = 1
	@nLabelPadding = 1

	# Axis characters
	@cVAxisChar = char(226) + char(148) + char(130)
	@cHAxisChar = char(226) + char(148) + char(128)
	@cVArrowChar = char(226) + char(150) + char(178)
	@cHArrowChar = char(226) + char(150) + char(186)
	@cOriginChar = char(226) + char(149) + char(176)
	@cAverageChar = "-"

	# Histogram aggregation types
	@cAggregationType = "frequency"  # frequency, sum, average, min, max
	@bShowValues = 0 # General flag to control value display for any aggregation

	# Bins a list of numbers into equal-width classes, 5 or more by Sturges' rule, and prepares them to be drawn as bars.
	#
	#   paData     The raw measurements, a list of numbers
	#   returns    nothing; the histogram is built
	#   note       text or a non-list raises "paData must be a list of numbers"
	#   warning    An empty list raises "paData must contain only numbers", which does not say it is
	#              empty, and a list of equal numbers gives a last bin whose upper edge is below its
	#              lower edge
	#   see        SetBinCount, DataCount
	def init(paData)
		
		# For histogram, we expect a simple list of numbers (raw data)
		if CheckParams()
			if NOT isList(paData)
				StzRaise("Can't create stzHistogram! paData must be a list of numbers.")
			ok

			if NOT IsListOfNumbers(paData)
				StzRaise("Can't create stzHistogram! paData must contain only numbers.")
			ok
		ok

		@anRawData = paData
		_calculateBins()
		_processBinnedData()

	# Draws the bin counts and the bin labels as touching bars on a new canvas and answers it, so the histogram can become SVG or PNG.
	#
	#   paOptions   A list of options [ :Width = , :Height = , :Title = , :Font = an stzFont, :Color
	#               = , :Background = , :Grid = , :ShowValues = , :Min = , :Max = ]
	#   returns     an stzCanvas holding the picture
	#   note        the count above each bar is written unless :ShowValues = 0
	#   warning     The bins, the aggregation and the labels carry over, while percentages, axis
	#               switches, characters and spacing do not
	#   see         ToSVG, ToPNG
	#@ aka  THE ONE PLACE A BIN EDGE BECOMES TEXT.
	def ToCanvasQ(paOptions)
		return StzPlotCanvasQ(:Histogram, @aBinCounts, @aBinLabels, paOptions)

	# Returns the histogram as SVG text, with no graphics device needed.
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

	# Draws the histogram on the graphics device and returns the PNG bytes, writing them to a file when a path is given.
	#
	#   pcPath      The file to write, or an empty text to write none
	#   paOptions   A list of options [ :Width = , :Height = , :Title = , :Font = an stzFont, ... ],
	#               as for ToCanvasQ
	#   returns     the PNG bytes as a string, empty when no device is available
	#   see         ToSVG, ToCanvasQ
	def ToPNG(pcPath, paOptions)
		# the canvas is TRANSIENT: its engine scene (a target texture on the GPU
		# tier, vertex buffers, the command list) is freed once the answer is taken --
		# a picture per call used to leave a texture live per call (found 2026-09-11)
		_oCv_ = This.ToCanvasQ(paOptions)
		_cOut_ = _oCv_.ToPNG(pcPath)
		_oCv_.Free()
		return _cOut_

	# Whatever this returns is what is measured AND what is drawn, so the two
	# cannot drift apart again.
	def _BinLabelFor(nEdge)
		return StzNumberQ(RoundN(nEdge, 1)).CompactForm()

	def _calculateBins()
		
		if len(@anRawData) = 0
			return
		ok

		@nMinValue = min(@anRawData)
		@nMaxValue = max(@anRawData)
		
		# Auto-calculate bin count using Sturges' rule if not set
		if @nBinCount = 0
			@nBinCount = max([5, ceil(1 + log(len(@anRawData)) / log(2))])
		ok
		
		# Calculate bin width
		_nRange_ = @nMaxValue - @nMinValue
		if _nRange_ = 0
			@nBinRange = 1
		else
			@nBinRange = _nRange_ / @nBinCount
		ok

		# Create bin ranges
		@aBinRanges = []
		@aBinLabels = []
		
		for i = 1 to @nBinCount
			_nBinMin_ = @nMinValue + (i-1) * @nBinRange
			_nBinMax_ = @nMinValue + i * @nBinRange
			
			# Last bin includes the maximum value
			if i = @nBinCount
				_nBinMax_ = @nMaxValue
			ok
			
			@aBinRanges + [_nBinMin_, _nBinMax_]
			
			# Create labels
			_cLabel_ = This._BinLabelFor(_nBinMin_) + "-" + This._BinLabelFor(_nBinMax_)
			@aBinLabels + _cLabel_
		next

	def _findBinIndex(nValue)
		_nLen_ = len(@aBinRanges)
		for i = 1 to _nLen_
			_nMin_ = @aBinRanges[i][1]
			_nMax_ = @aBinRanges[i][2]
			
			# Last bin includes maximum value
			if i = _nLen_
				if nValue >= _nMin_ and nValue <= _nMax_
					return i
				ok
			else
				if nValue >= _nMin_ and nValue < _nMax_
					return i
				ok
			ok
		next
		
		return 0  # Should not happen with valid data

	# Splits the data into n equal-width bins again; a value of 0 or less is ignored.
	#
	#   n          The number of bins
	#   returns    nothing; the bins and the picture change
	#   note       the default is 5 or more by Sturges' rule
	#   warning    A count that is not a whole number drops the largest values, because the last bin
	#              then ends before the maximum
	#   see        SetBinRange, SetBarCount
	#@ aka  Configuration methods
	def SetBinCount(n)
		if n > 0
			@nBinCount = n
			_calculateBins()
			_processBinnedData()
		ok

		# Splits the data into n equal-width bins, under the bar name.
		#
		#   n          The number of bins, ignored when 0 or less
		#   returns    nothing; the bins and the picture change
		#   see        SetBinCount
		def SetBarCount(n)
			This.SetBinCount(n)

		# Splits the data into n equal-width bins, under the class name of statistics.
		#
		#   n          The number of bins, ignored when 0 or less
		#   returns    nothing; the bins and the picture change
		#   see        SetBinCount
		def SetClassCount(n)
			This.SetBinCount(n)

		# Splits the data into n equal-width bins, worded as a division into classes.
		#
		#   n          The number of bins, ignored when 0 or less
		#   returns    nothing; the bins and the picture change
		#   see        SetBinCount
		def DivideToNClasses(n)
			This.SetBinCount(n)

		# Splits the data into n equal-width bins, worded as a division into groups.
		#
		#   n          The number of bins, ignored when 0 or less
		#   returns    nothing; the bins and the picture change
		#   see        SetBinCount
		def DivideToNGroups(n)
			This.SetBinCount(n)

	# Cuts the data into ceil((largest count - smallest count) / n) bins, usually one, instead of bins n wide.
	#
	#   n          The wanted width of a bin, ignored when 0 or less
	#   returns    nothing; the bins change, wrongly
	#   note       use SetBinCount for a number of bins
	#   warning    The bin count is worked out from the range of the bar heights, not of the data,
	#              so SetBinRange(10) on values from 12 to 70 gives one bin and SetBinRange(3) gives
	#              two
	#   see        SetBinCount
	def SetBinRange(n)
		if n > 0
			@nBinRange = n
			@nBinCount = ceil((@nMaxValue - @nMinValue) / n)
			_calculateBins()
			_processBinnedData()
		ok

		# Cuts the data into the same wrong number of classes as SetBinRange does, usually one, instead of classes n wide.
		#
		#   n          The wanted width of a class, ignored when 0 or less
		#   returns    nothing; the bins change, wrongly
		#   warning    Same cause: the count comes from the bar heights, so the result is one or two
		#              bins
		#   see        SetBinRange
		def SetClassRange(n)
			This.SetBinRange(n)

	# Sets the height the Ring renderer draws, which the engine renderer fixes at 10 rows and so ignores.
	#
	#   n          The height in rows
	#   returns    nothing; only the Ring renderer changes
	#   note       the default is 10
	#   warning    The usual ToString ignores it, and obeys it only when statistics are on or the
	#              horizontal axis is off, since those use the Ring renderer
	#   see        ToStringInRing
	def SetHeight(n) #TODO //n should be the number of positions in the bar
		@nHeight = n

	# Shows or hides the count above each bar, but only the Ring renderer draws it.
	#
	#   bShow      1 to write the counts, 0 to stop
	#   returns    nothing; only the Ring renderer changes
	#   note       the counts appear when statistics are on or the horizontal axis is off
	#   warning    ToString never draws the counts because the engine renderer reads a flag nothing
	#              sets, so use AddPercent or ToStringInRing
	#   see        AddValues, SetPercent
	def SetValues(bShow)
		@bShowValues = bShow
	
		# Turns the count above each bar on, but only the Ring renderer draws it.
		#
		#   returns    nothing; only the Ring renderer changes
		#   warning    ToString never draws the counts
		#   see        SetValues
		def IncludeValues()
			@bShowValues = 1

		# Turns the count above each bar on, but only the Ring renderer draws it.
		#
		#   returns    nothing; only the Ring renderer changes
		#   warning    ToString never draws the counts
		#   see        SetValues
		def AddValues()
			@bShowValues = 1

		# Turns the count above each bar off.
		#
		#   returns    nothing; the flag changes
		#   see        SetValues
		def WithoutValues()
			@bShowValues = 0

	# Chooses what each bar shows: the count of values in the bin or their sum, mean, smallest or largest.
	#
	#   cType      The aggregation, in lower case: "frequency", "sum", "average", "min" or "max"
	#   returns    nothing; the bars change
	#   note       an empty bin shows 0
	#   warning    Any other text, "SUM" with capitals included, raises R2 from max() and leaves the
	#              histogram empty, so ToString then raises too
	#   see        AggregationTypes, AggregationType
	def SetAggregation(cType)
		@cAggregationType = cType
		_processBinnedData()

	# Returns which aggregation the bars show now.
	#
	#   returns    the text "frequency", "sum", "average", "min" or "max"
	#   note       the default is "frequency"
	#   see        SetAggregation, AggregationTypes
	def AggregationType()
		return @cAggregationType

		# Returns which aggregation the bars show now, under a shorter name.
		#
		#   returns    the text "frequency", "sum", "average", "min" or "max"
		#   see        AggregationType
		def Aggregation()
			return @cAggregationType

	# Returns the five aggregations a histogram accepts.
	#
	#   returns    a list of text [ "frequency", "sum", "average", "min", "max" ]
	#   see        SetAggregation
	def AggregationTypes()
		return [ "frequency", "sum", "average", "min", "max" ]

	# Makes each bar show how many values fall in its bin.
	#
	#   returns    nothing; the bars change
	#   note       this is the default
	#   see        SetAggregation, UseSum
	def UseFrequency()
		@cAggregationType = "frequency"
		_processBinnedData()

		# Makes each bar show how many values fall in its bin, under a shorter name.
		#
		#   returns    nothing; the bars change
		#   see        UseFrequency
		def UseFreq()
			This.UseFrequency()

	# Makes each bar show the sum of the values in its bin.
	#
	#   returns    nothing; the bars change
	#   note       Mode then names the bin with the largest sum
	#   see        SetAggregation, UseFrequency
	def UseSum()
		@cAggregationType = "sum"
		_processBinnedData()

	# Makes each bar show the mean of the values in its bin, 0 for an empty bin.
	#
	#   returns    nothing; the bars change
	#   see        SetAggregation, UseSum
	def UseAverage()
		@cAggregationType = "average"
		_processBinnedData()

	# Makes each bar show the smallest value in its bin, 0 for an empty bin.
	#
	#   returns    nothing; the bars change
	#   see        SetAggregation, UseMax
	def UseMin()
		@cAggregationType = "min"
		_processBinnedData()

	# Makes each bar show the largest value in its bin, 0 for an empty bin.
	#
	#   returns    nothing; the bars change
	#   see        SetAggregation, UseMin
	def UseMax()
		@cAggregationType = "max"
		_processBinnedData()

	# Shows or hides four lines under the picture giving the mean, standard deviation, median and count of the data.
	#
	#   bShow      1 to add the lines, 0 to remove them
	#   returns    nothing; the picture changes
	#   note       it switches the drawing to the Ring renderer, which obeys SetHeight and SetValues
	#   see        AddStats, Mean
	def SetStats(bShow) # Displays a recap of stats line at the bottom
		@bShowStats = bShow

		# Adds four lines under the picture giving the mean, standard deviation, median and count of the data.
		#
		#   returns    nothing; the picture changes
		#   see        SetStats
		def AddStats()
			@bShowStats = 1

		# Adds the statistics lines under the picture, under the Include name.
		#
		#   returns    nothing; the picture changes
		#   see        SetStats
		def IncludeStats()
			@bShowStats = 1

	# Shows or hides the vertical axis with its arrow, the one that runs up beside the bars.
	#
	#   bShow      1 to show it, 0 to hide it
	#   returns    nothing; the picture changes
	#   note       the bars and labels keep their place
	#   see        AddVAxis, WithoutVAxis, SetHAxis
	#@ aka  Vertical axis methods (with X aliases for compatibility)
	def SetVAxis(bShow)
		@bShowVAxis = bShow

		# Shows the vertical axis with its arrow.
		#
		#   returns    nothing; the picture changes
		#   see        SetVAxis
		def AddVAxis()
			@bShowVAxis = 1

		# Shows the vertical axis with its arrow, under the Include name.
		#
		#   returns    nothing; the picture changes
		#   see        SetVAxis
		def IncludeVAxis()
			@bShowVAxis = 1

		# Hides the vertical axis and its arrow.
		#
		#   returns    nothing; the picture changes
		#   see        SetVAxis
		def WithoutVAxis()
			@bShowVAxis = 0

		# Shows or hides the VERTICAL axis, under the X name kept for old code.
		#
		#   bShow      1 to show it, 0 to hide it
		#   returns    nothing; the picture changes
		#   note       SetYAxis is the horizontal one
		#   warning    The X name here means the vertical axis, the reverse of the usual X for the
		#              horizontal axis
		#   see        SetVAxis
		#@ aka  X-axis aliases for backward compatibility
		def SetXAxis(bShow)
			This.SetVAxis(bShow)

		# Shows the VERTICAL axis, under the X name kept for old code.
		#
		#   returns    nothing; the picture changes
		#   warning    The X name here means the vertical axis
		#   see        SetXAxis
		def AddXAxis()
			This.AddVAxis()

		# Shows the VERTICAL axis, under the X name and the Include name.
		#
		#   returns    nothing; the picture changes
		#   warning    The X name here means the vertical axis
		#   see        SetXAxis
		def IncludeXAxis()
			This.IncludeVAxis()

		# Hides the VERTICAL axis, under the X name kept for old code.
		#
		#   returns    nothing; the picture changes
		#   warning    The X name here means the vertical axis
		#   see        SetXAxis
		def WithoutXAxis()
			This.WithoutVAxis()

	# Shows or hides the horizontal axis line under the bars, with its arrow and the origin mark.
	#
	#   bShow      1 to show it, 0 to hide it
	#   returns    nothing; the picture changes
	#   note       hiding it switches the drawing to the Ring renderer and keeps the bin labels
	#   see        AddHAxis, WithoutHAxis, SetVAxis
	#@ aka  Horizontal axis methods (with Y aliases for compatibility)
	def SetHAxis(bShow)
		@bShowHAxis = bShow

		# Shows the horizontal axis line under the bars.
		#
		#   returns    nothing; the picture changes
		#   see        SetHAxis
		def AddHAxis()
			@bShowHAxis = 1

		# Shows the horizontal axis line under the bars, under the Include name.
		#
		#   returns    nothing; the picture changes
		#   see        SetHAxis
		def IncludeHAxis()
			@bShowHAxis = 1

		# Hides the horizontal axis line, its arrow and its origin mark.
		#
		#   returns    nothing; the picture changes
		#   see        SetHAxis
		def WithoutHAxis()
			@bShowHAxis = 0

		# Shows or hides the HORIZONTAL axis, under the Y name kept for old code.
		#
		#   bShow      1 to show it, 0 to hide it
		#   returns    nothing; the picture changes
		#   note       SetXAxis is the vertical one
		#   warning    The Y name here means the horizontal axis, the reverse of the usual Y for the
		#              vertical axis
		#   see        SetHAxis
		#@ aka  Y-axis aliases for backward compatibility
		def SetYAxis(bShow)
			This.SetHAxis(bShow)

		# Shows the HORIZONTAL axis, under the Y name kept for old code.
		#
		#   returns    nothing; the picture changes
		#   warning    The Y name here means the horizontal axis
		#   see        SetYAxis
		def AddYAxis()
			This.AddHAxis()

		# Shows the HORIZONTAL axis, under the Y name and the Include name.
		#
		#   returns    nothing; the picture changes
		#   warning    The Y name here means the horizontal axis
		#   see        SetYAxis
		def IncludeYAxis()
			This.IncludeHAxis()

		# Hides the HORIZONTAL axis, under the Y name kept for old code.
		#
		#   returns    nothing; the picture changes
		#   warning    The Y name here means the horizontal axis
		#   see        SetYAxis
		def WithoutYAxis()
			This.WithoutHAxis()

	# Shows or hides the two rows of bin labels under the bars, each giving a bin's lower and upper edge.
	#
	#   bShow      1 to show the labels, 0 to hide them
	#   returns    nothing; the picture changes
	#   note       an edge is rounded to one decimal
	#   see        AddLabels, WithoutLabels
	def SetLabels(bShow)
		@bShowLabels = bShow

		# Shows the two rows of bin labels under the bars.
		#
		#   returns    nothing; the picture changes
		#   see        SetLabels
		def AddLabels()
			@bShowLabels = 1

		# Shows the two rows of bin labels under the bars, under the Include name.
		#
		#   returns    nothing; the picture changes
		#   see        SetLabels
		def IncludeLabels()
			@bShowLabels = 1

		# Hides the two rows of bin labels under the bars.
		#
		#   returns    nothing; the picture changes
		#   see        SetLabels
		def WithoutLabels()
			@bShowLabels = 0

	# Shows or hides each bar's share of all the data above it, such as 40%.
	#
	#   bShow      1 to write the percentages, 0 to stop
	#   returns    nothing; the picture changes
	#   note       the share is of the total of all the bars, so after UseSum it is each bin's share
	#              of the overall sum
	#   see        AddPercent, SetValues
	def SetPercent(bShow)
		@bShowPercent = bShow

		# Writes each bar's share of all the data above it.
		#
		#   returns    nothing; the picture changes
		#   see        SetPercent
		def AddPercent()
			@bShowPercent = 1

		# Writes each bar's share of all the data above it, under the Include name.
		#
		#   returns    nothing; the picture changes
		#   see        SetPercent
		def IncludePercent()
			@bShowPercent = 1

	# Sets how many characters wide each bar is drawn.
	#
	#   nWidth     The width of a bar in characters, raised to 1 when smaller
	#   returns    nothing; the picture changes
	#   note       the default is 2
	#   see        SetBarInterSpace
	def SetBarWidth(nWidth)
		@nBarWidth = max([1, nWidth])

	# Sets the widest picture the Ring renderer accepts, which the engine renderer does not check.
	#
	#   nWidth     The largest total width in characters
	#   returns    nothing; the limit changes
	#   note       the default is 132
	#   warning    The usual ToString ignores it, while a wider Ring-rendered picture (statistics
	#              on, or no horizontal axis) raises "Histogram width (n) exceeds maximum (m)"
	#   see        SetStats
	def SetMaxWidth(nWidth)
		@nMaxWidth = nWidth

	# Sets the blank columns between neighbouring bars, which add to the label spacing.
	#
	#   n          The number of blank columns
	#   returns    nothing; the picture changes
	#   note       the default is 1
	#   see        SetLabelInterSpace, SetBarWidth
	def SetBarInterSpace(n)
		@nBarInterSpace = n  # 0 = auto-calculate, >0 = fixed spacing

	# Sets the character the bars are drawn with; a text of more than one character raises an error.
	#
	#   c          The single character to draw bars with
	#   returns    nothing; the picture changes
	#   note       the default is a full block
	#   warning    Raises "Incorrect param type! c must be a char." for a longer text
	#   see        SetFinalBarChar
	def SetBarChar(c)
		if CheckParams()
			if not IsChar(c)
				StzRaise("Incorrect param type! c must be a char.")
			ok
		ok
		@cBarChar = c

	# Sets the character that draws the top row of each bar; a text of more than one character raises an error.
	#
	#   c          The single character for the top row
	#   returns    nothing; the picture changes
	#   note       an empty top character, the default, uses the bar character
	#   warning    Raises "Incorrect param type! c must be a char." for a longer text
	#   see        SetBarChar, SetTopBarChar
	def SetFinalBarChar(c)
		if CheckParams()
			if not IsChar(c)
				StzRaise("Incorrect param type! c must be a char.")
			ok
		ok
		@cFinalBarChar = c

		# Sets the character that draws the top row of each bar, under the Top name.
		#
		#   c          The single character for the top row
		#   returns    nothing; the picture changes
		#   see        SetFinalBarChar
		def SetTopBarChar(c)
			This.SetFinalBarChar(c)

	# Sets the extra blank columns kept between neighbouring bin labels, which add to the bar spacing.
	#
	#   n          The number of blank columns
	#   returns    nothing; the picture changes
	#   note       the default is 1
	#   see        SetBarInterSpace
	def SetLabelInterSpace(n)
	    @nLabelInterSpace = n

	# Returns the arithmetic mean of the raw data.
	#
	#   returns    a number
	#   see        StandardDeviation, Median
	#@ aka  Statistical methods for histogram
	def Mean()
		_nLen_ = len(@anRawData)

		if _nLen_ = 0
			return 0
		ok

		_nSum_ = 0

		for i = 1 to _nLen_
			_nSum_ += @anRawData[i]
		next

		return _nSum_ / _nLen_

	# Returns the sample standard deviation of the raw data, dividing by n minus 1.
	#
	#   returns    a number
	#   note       0 for one value or none
	#   see        Mean, Median
	def StandardDeviation()
		_nLen_ = len(@anRawData)

		if _nLen_ <= 1
			return 0
		ok
		
		_nMean_ = This.Mean()
		_nSumSquares_ = 0
		
		for i = 1 to _nLen_
			_nSumSquares_ += pow(@anRawData[i] - _nMean_, 2)
		next
		
		return sqrt(_nSumSquares_ / (_nLen_ - 1))

	# Returns the middle value of the raw data, or the mean of the two middle ones.
	#
	#   returns    a number
	#   see        Mean, Mode
	def Median()
		_nLen_ = len(@anRawData)
		if _nLen_ = 0
			return 0
		ok
		
		_aSorted_ = sort(@anRawData)
		
		if _nLen_ % 2 = 1
			return _aSorted_[ceil(_nLen_/2)]

		else
			_nMid1_ = _aSorted_[_nLen_/2]
			_nMid2_ = _aSorted_[_nLen_/2 + 1]
			return (_nMid1_ + _nMid2_) / 2
		ok

	# Returns the lower and upper edge of the bin with the largest bar, the first one when several tie.
	#
	#   returns    a list of two numbers [ low, high ]
	#   note       it reads the bar heights, so after UseSum it names the bin with the largest sum
	#   see        Median, UseFrequency
	def Mode()
		# Find the bin with highest frequency
		_nMaxFreq_ = max(@aBinCounts)
		_nModeIndex_ = StzFindFirst(_nMaxFreq_, @aBinCounts)
		
		if _nModeIndex_ > 0
			return @aBinRanges[_nModeIndex_]
		else
			return [0, 0]
		ok

	# Returns how many values the histogram was built from.
	#
	#   returns    a number
	#   see        Mean
	def DataCount()
		return len(@anRawData)

		def DataSize()
			return This.DataCount()

		def Count()
			return This.DataCount()

	def _processBinnedData()

		# Initialize bin data based on aggregation type
		@aBinCounts = []
		
		for i = 1 to @nBinCount

			switch @cAggregationType
			on "frequency"
				@aBinCounts + 0

			on "sum"
				@aBinCounts + 0

			on "average"
				@aBinCounts + 0

			on "min"
				@aBinCounts + 0

			on "max"
				@aBinCounts + 0

			off
		next

		# Process each data point
		_nLen_ = len(@anRawData)
		for i = 1 to _nLen_

			_nBinIndex_ = _findBinIndex(@anRawData[i])

			if _nBinIndex_ > 0

				switch @cAggregationType
				on "frequency"
					@aBinCounts[_nBinIndex_]++

				on "sum"
					@aBinCounts[_nBinIndex_] += @anRawData[i]

				on "average"
					# Store sum first, calculate average later
					@aBinCounts[_nBinIndex_] += @anRawData[i]

				on "min"
					if @aBinCounts[_nBinIndex_] = 0
						@aBinCounts[_nBinIndex_] = @anRawData[i]

					else
						@aBinCounts[_nBinIndex_] = min([@aBinCounts[_nBinIndex_], @anRawData[i]])
					ok

				on "max"
					@aBinCounts[_nBinIndex_] = max([@aBinCounts[_nBinIndex_], @anRawData[i]])

				off
			ok
		next
		
		# Post-process for average
		if @cAggregationType = "average"
			for i = 1 to @nBinCount
				_nCount_ = _getFrequencyForBin(i)
				if _nCount_ > 0
					@aBinCounts[i] = @aBinCounts[i] / _nCount_
				else
					@aBinCounts[i] = 0
				ok
			next
		ok
		
		# Set up processed data
		@anValues = @aBinCounts
		@acLabels = @aBinLabels
		@nMaxValue = max(@aBinCounts)
		@nMinValue = min(@aBinCounts)
	
	# Helper method to get frequency count for a bin (needed for average calculation)
	def _getFrequencyForBin(_nBinIndex_)

		_nCount_ = 0
		_nLen_ = len(@anRawData)

		for i = 1 to _nLen_
			if _findBinIndex(@anRawData[i]) = _nBinIndex_
				_nCount_++
			ok
		next

		return _nCount_

	# Canvas management methods
	def _initCanvas()
		@acCanvas = []
		for i = 1 to @nHeight
			_aRow_ = []
			for j = 1 to @nWidth
				_aRow_ + " "
			next
			@acCanvas + _aRow_
		next

	def _finalizeCanvas()
		_cResult_ = ""
		_nLen_ = len(@acCanvas)
		for i = 1 to _nLen_
			_cLine_ = ""
			_nLenCurrent_ = len(@acCanvas[i])
			for j = 1 to _nLenCurrent_
				_cLine_ += @acCanvas[i][j]
			next
			# Trim trailing spaces
			while StzLen(_cLine_) > 0 and StzRight(_cLine_, 1) = " "
				_cLine_ = StzLeft(_cLine_, StzLen(_cLine_) - 1)
			end
			_cResult_ += _cLine_ + char(10)
		next
		
		# Remove final newline
		if StzLen(_cResult_) > 0 and StzRight(_cResult_, 1) = char(10)
			_cResult_ = StzLeft(_cResult_, StzLen(_cResult_) - 1)
		ok
		
		return _cResult_
	
	# Prints the histogram as text on the console.
	#
	#   returns    nothing; the histogram is printed
	#   see        ToString
	#--- DISPLAY
	def Show()
		? This.ToString()

	# Returns the histogram as text, with bars that follow the bins, a vertical axis, and the bin edges written in two rows.
	#
	#   returns    a multi-line string
	#   note       it hands over to the Ring renderer when statistics are on or the horizontal axis
	#              is off
	#   warning    Raises an error when the engine cannot render the histogram
	#   see        Show, ToStringInRing, ToSVG
	#@ aka  THE PICTURE, rendered by the engine.
	def ToString()
		This._EnsureBins()
		_nB_ = len(@aBinRanges)
		if _nB_ = 0
			return ""
		ok

		# TWO CONFIGURATIONS THE ENGINE RENDERER DOES NOT COVER YET, and it says so
		# rather than drawing them differently.
		#
		# ShowStats appends mean/stddev/median/count, which are computed from the RAW
		# DATA -- and the engine renderer is handed bins, not samples, so it cannot
		# produce them without a wider signature. Hiding the horizontal axis triggers
		# a post-processing step in the Ring renderer that strips a leading line.
		#
		# Falling back keeps the picture right. A renderer that quietly drew something
		# close would be the worst outcome, because a wrong plot raises nothing.
		if @bShowStats or (NOT @bShowHAxis)
			return This.ToStringInRing()
		ok

		_aEdges_ = []
		for _i_ = 1 to _nB_
			_aEdges_ + @aBinRanges[_i_][1]
		next
		_aEdges_ + @aBinRanges[_nB_][2]

		_aOpts_ = [
			@nBarWidth, 10, @nMaxLabelWidth,
			@nBarInterSpace, @nLabelInterSpace, @nAxisPadding, @nVAxisWidth,
			iff(@bShowHAxis, 1, 0), iff(@bShowVAxis, 1, 0),
			iff(@bShowLabels, 1, 0),
			iff(@bShowFrequency, 1, 0), iff(@bShowPercent, 1, 0),
		# THE CHARACTERS THE CALLER CHOSE, as codepoints on the end of the options.
		# They were dropped when this renderer moved to the engine: SetBarChar and
		# its siblings went on setting an attribute nothing read any more, so they
		# silently did nothing. The Ring renderer below still honoured them, which
		# is how the parity guard would have caught it -- had any case set one.
			StzCharCode(@cBarChar), StzCharCode(@cFinalBarChar)
		]

		_cOut_ = StzEnginePlotHistogram(@anValues, _aEdges_, _aOpts_)
		if NOT isString(_cOut_) or _cOut_ = ""
			StzRaise("stzHistogram: the engine could not render this histogram.")
		ok
		return _cOut_

	# Returns the histogram as text drawn by the Ring code the engine renderer was ported from.
	#
	#   returns    a multi-line string
	#   note       it honours SetHeight, SetValues and SetStats, which ToString only does by falling
	#              back to it
	#   see        ToString
	#@ aka  THE RING RENDERER THIS WAS PORTED FROM, verbatim, so the guard can prove the two agree character for character.
	def ToStringInRing()
		
		# Use the same layout logic as bar chart
		_oLayout_ = _calculateLayout()
		
		@nWidth = _oLayout_[:total_width]
		@nHeight = _oLayout_[:chart_height]
		_initCanvas()
		
		# Draw components
		if @bShowVAxis
			_drawVAxis(_oLayout_)
		ok
		
		if @bShowHAxis  
			_drawHAxis(_oLayout_)
		ok
		
		_drawBars(_oLayout_)
	
		if @bShowValues
			_drawValues(_oLayout_)
		but @bShowPercent
			_drawPercent(_oLayout_)
		ok
		
		if @bShowLabels
			_drawLabels(_oLayout_)
		ok
		
		_cResult_ = _finalizeCanvas()

		# A hack to remove an unnecessary empty line from the top
		if @bShowHAxis = 0

			_oStrTemp_ = new stzString(_cResult_)
			_nPos_ = _oStrTemp_.FindFirst(char(10))
			_oStrTemp_.RemoveSection(1, _nPos_)
			_cResult_ = _oStrTemp_.Content()
		ok

		# A hack to add an empty at the top of the H Axis

		if ring_substr1(_cResult_, @cVArrowChar) > 0

			_oStrTemp_ = new stzString(_cResult_)
			_nPos_ = _oStrTemp_.FindNth(1, char(10))
			_bFirstLineIsEmpty_ = @trim(_oStrTemp_.Section(4, _nPos_-1)) = ""

			if NOT _bFirstLineIsEmpty_ # then add an empty line
				_cResult_ = StzReplace(_cResult_, @cVArrowChar, @cVAxisChar)
				_cResult_ = @cVArrowChar + char(10) + _cResult_
			ok

		ok

		# Add statistics if requested
		if @bShowStats

			_cStats_ = char(10) + char(10) +
				"Mean:   " + RoundN(This.Mean(), 2) + char(10) +
			    "StdDev: " + RoundN(This.StandardDeviation(), 2) + char(10) +
			    "Median: " + RoundN(This.Median(), 2) + char(10) +
			    "Count:  " + This.DataCount()

			_cResult_ += _cStats_
		ok
	
		return _cResult_

	# Bins are computed once, lazily -- the engine can also do this on its own via
	# StzEngineBinValues, which is what a host that only wants the distribution
	# calls.
	def _EnsureBins()
		if len(@aBinRanges) = 0
			_calculateBins()
		ok

	def _calculateLayout()
		# Calculate layout for histogram display
		_nBars_ = len(@anValues)
		_oLayout_ = new stzHashList([])
		
		# First calculate all element widths
		_aElementWidths_ = []
		_nSum_ = This.DataCount()  # Total data points for percentage
		
		for i = 1 to _nBars_
		    _nBarWidth_ = @nBarWidth
		    _nLabelWidth_ = 0
		    _nValueWidth_ = 0
		    
		    if @bShowLabels and i <= len(@acLabels)
		        # Calculate width for two-line labels (use the longer of the two values)
		        # measured with the SAME formatter the drawer uses, so the space
		        # reserved is the space needed
		        _cLabel1_ = This._BinLabelFor(@aBinRanges[i][1])
		        _cLabel2_ = This._BinLabelFor(@aBinRanges[i][2])
		        _nLabelWidth_ = max([StzLen(_cLabel1_), StzLen(_cLabel2_)])
		        if _nLabelWidth_ > @nMaxLabelWidth
		            _nLabelWidth_ = @nMaxLabelWidth
		        ok
		    ok
		    
		    if @bShowFrequency
		        _nValueWidth_ = StzLen("" + @anValues[i])
		    but @bShowPercent
		        _cPercent_ = RoundN((@anValues[i]/_nSum_)*100, 1)
		        _nValueWidth_ = StzLen("" + _cPercent_ + '%')
		    ok
		    
		    # Use bar width as minimum, but allow labels to determine spacing
		    _nElementWidth_ = max([_nBarWidth_, _nLabelWidth_, _nValueWidth_])
		    _aElementWidths_ + _nElementWidth_
		next
		
		# Then calculate bar spacing using the calculated element widths
		_aBarSpacing_ = []
		for i = 1 to _nBars_ - 1
		    _aBarSpacing_ + (@nBarInterSpace + @nLabelInterSpace)
		next
		
		_nBarsAreaWidth_ = 0
		_nLen_ = len(_aElementWidths_)
		for i = 1 to _nLen_
			_nBarsAreaWidth_ += _aElementWidths_[i]
		next

		_nLen_ = len(_aBarSpacing_)
		for i = 1 to _nLen_
			_nBarsAreaWidth_ += _aBarSpacing_[i]
		next
		
		_nVAxisStart_ = 1
		_nVAxisEnd_ = _nVAxisStart_ + @nVAxisWidth - 1
		
		_nBarsStart_ = _nVAxisEnd_ + 1
		if @bShowVAxis
			_nBarsStart_ += @nAxisPadding
		ok
		
		_nBarsEnd_ = _nBarsStart_ + _nBarsAreaWidth_ - 1
		_nHAxisStart_ = _nVAxisStart_
		if @bShowVAxis
			_nHAxisStart_ = _nVAxisEnd_ + @nAxisPadding
		ok
		_nHAxisEnd_ = _nBarsEnd_ + @nAxisPadding
		_nTotalWidth_ = _nHAxisEnd_ + 1
		
		if _nTotalWidth_ > @nMaxWidth
			StzRaise("Histogram width (" + _nTotalWidth_ + ") exceeds maximum (" + @nMaxWidth + ")")
		ok
		
		# Estimate initial height for calculation
		_nEstimatedHeight_ = @nHeight
		if _nEstimatedHeight_ = 0
			_nEstimatedHeight_ = 20  # Default estimate
		ok
		
		# Calculate chart height based on requirements
		if @bShowLabels
			_nChartHeight_ = _nEstimatedHeight_ + 1  # Add one more row for two-line labels
			_nHAxisRow_ = _nEstimatedHeight_ - 1
			_nLabelsRow_ = _nEstimatedHeight_ + 1
		else
			_nChartHeight_ = _nEstimatedHeight_
			_nHAxisRow_ = _nEstimatedHeight_ - 1  
			_nLabelsRow_ = _nEstimatedHeight_
		ok
		
		# Calculate bars area height
		_nBarsAreaHeight_ = _nHAxisRow_ - 1
		if @bShowValues or @bShowPercent
			_nBarsAreaHeight_ = _nHAxisRow_ - 2
		ok
		
		# Now calculate required height based on actual bar heights
		_nRequiredHeight_ = This._getRequiredHeight(_nBarsAreaHeight_)
		
		# Recalculate final positions with correct height
		if @bShowLabels
			_nChartHeight_ = _nRequiredHeight_ + 1
			_nHAxisRow_ = _nRequiredHeight_ - 1
			_nLabelsRow_ = _nRequiredHeight_ + 1
		else
			_nChartHeight_ = _nRequiredHeight_
			_nHAxisRow_ = _nRequiredHeight_ - 1
			_nLabelsRow_ = _nRequiredHeight_
		ok
		
		# Update @nHeight to match calculated height
		@nHeight = _nChartHeight_
		
		# Recalculate bars area height with final positions
		_nBarsAreaHeight_ = _nHAxisRow_ - 1
		if @bShowValues or @bShowPercent
			_nBarsAreaHeight_ = _nHAxisRow_ - 2
		ok
		
		_oLayout_.AddPair([:v_axis_col, _nVAxisStart_])
		_oLayout_.AddPair([:bars_start_col, _nBarsStart_]) 
		_oLayout_.AddPair([:bars_end_col, _nBarsEnd_])
		_oLayout_.AddPair([:h_axis_start_col, _nHAxisStart_])
		_oLayout_.AddPair([:h_axis_end_col, _nHAxisEnd_])
		_oLayout_.AddPair([:h_axis_row, _nHAxisRow_])
		_oLayout_.AddPair([:labels_row, _nLabelsRow_])
		_oLayout_.AddPair([:chart_height, _nChartHeight_])
		_oLayout_.AddPair([:bars_area_height, _nBarsAreaHeight_])
		_oLayout_.AddPair([:total_width, _nTotalWidth_])
		_oLayout_.AddPair([:element_widths, _aElementWidths_])
		_oLayout_.AddPair([:bar_spacing, _aBarSpacing_])
		
		return _oLayout_

	def _drawVAxis(_oLayout_)
		_nAxisCol_ = _oLayout_[:v_axis_col]
		_nAxisRow_ = _oLayout_[:h_axis_row]
		
		# Draw axis from row 2 to avoid overwriting arrow
		for i = 2 to _nAxisRow_ - 1
			@acCanvas[i][_nAxisCol_] = @cVAxisChar
		next
		
		# Place arrow at the top (row 1)
		@acCanvas[1][_nAxisCol_] = @cVArrowChar

	def _drawHAxis(_oLayout_)
		_nAxisRow_ = _oLayout_[:h_axis_row]
		_nStartCol_ = _oLayout_[:h_axis_start_col]
		_nEndCol_ = _oLayout_[:h_axis_end_col]
		_nVAxisCol_ = _oLayout_[:v_axis_col]
		
		for i = _nStartCol_ to _nEndCol_
			@acCanvas[_nAxisRow_][i] = @cHAxisChar
		next
		
		if @bShowVAxis
			@acCanvas[_nAxisRow_][_nVAxisCol_] = @cOriginChar
		ok
		
		@acCanvas[_nAxisRow_][_nEndCol_] = @cHArrowChar

	def _drawBars(_oLayout_)
		# Same logic as bar chart but with improved height calculation for histograms
		_nBars_ = len(@anValues)
		_nBarsStartCol_ = _oLayout_[:bars_start_col] 
		_nAxisRow_ = _oLayout_[:h_axis_row]
		_nBarsAreaHeight_ = _oLayout_[:bars_area_height]
		_aElementWidths_ = _oLayout_[:element_widths]
		_aBarSpacing_ = _oLayout_[:bar_spacing]
		
		_nCurrentX_ = _nBarsStartCol_
		
		for i = 1 to _nBars_
			_nElementWidth_ = _aElementWidths_[i]
			_nVal_ = @anValues[i]  # This is frequency count
			
			# Improved height calculation for histograms
			if _nVal_ = 0
				_nBarHeight_ = 0
			else
				# Use 1:1 mapping if frequencies fit within available height
				if @nMaxValue <= _nBarsAreaHeight_
					_nBarHeight_ = _nVal_  # Direct mapping: frequency 2 = height 2
				else
					# Only use proportional scaling when frequencies exceed available space
					_nBarHeight_ = max([1, ceil(_nBarsAreaHeight_ * _nVal_ / @nMaxValue)])
				ok
			ok
			
			_nBarStartX_ = _nCurrentX_ + floor((_nElementWidth_ - @nBarWidth) / 2)

			if _nBarHeight_ > 0
				for j = 1 to _nBarHeight_
					for k = 1 to @nBarWidth
						_nCol_ = _nBarStartX_ + k - 1
						_nRow_ = _nAxisRow_ - j
						if _nCol_ <= @nWidth and _nRow_ >= 1
							if j = _nBarHeight_ and @cFinalBarChar != ""
								@acCanvas[_nRow_][_nCol_] = @cFinalBarChar
							else
								@acCanvas[_nRow_][_nCol_] = @cBarChar
							ok
						ok
					next
				next
			ok

			if i < _nBars_
				_nCurrentX_ += _nElementWidth_ + _aBarSpacing_[i]
			ok
		next

	# Helper method to calculate actual required height
	def _getRequiredHeight(_nBarsAreaHeight_)
		_nMaxBarHeight_ = 0
		_nLen_ = len(@anValues)
		for i = 1 to _nLen_
			_nVal_ = @anValues[i]
			if _nVal_ > 0
				if @nMaxValue <= _nBarsAreaHeight_
					_nBarHeight_ = _nVal_
				else
					_nBarHeight_ = max([1, ceil(_nBarsAreaHeight_ * _nVal_ / @nMaxValue)])
				ok
				_nMaxBarHeight_ = max([_nMaxBarHeight_, _nBarHeight_])
			ok
		next
		
		# Add space for values above bars + axis + labels
		_nRequiredHeight_ = _nMaxBarHeight_ + 2  # +1 for values above, +1 for axis
		if @bShowLabels
			_nRequiredHeight_ += 2  # +2 for two-line labels
		ok
		
		return _nRequiredHeight_

	def _drawValues(_oLayout_)
		_nBars_ = len(@anValues)
		_nBarsStartCol_ = _oLayout_[:bars_start_col]
		_nAxisRow_ = _oLayout_[:h_axis_row] 
		_nBarsAreaHeight_ = _oLayout_[:bars_area_height]
		_aElementWidths_ = _oLayout_[:element_widths]
		_aBarSpacing_ = _oLayout_[:bar_spacing]
		
		_nCurrentX_ = _nBarsStartCol_
		
		for i = 1 to _nBars_
			_nElementWidth_ = _aElementWidths_[i]
			_nVal_ = @anValues[i]
			
			# Use same height calculation as bars
			if _nVal_ = 0
				_nBarHeight_ = 0
			else
				if @nMaxValue <= _nBarsAreaHeight_
					_nBarHeight_ = _nVal_
				else
					_nBarHeight_ = max([1, ceil(_nBarsAreaHeight_ * _nVal_ / @nMaxValue)])
				ok
			ok
			
			# Position value above the bar (one row above)
			_nValueRow_ = _nAxisRow_ - _nBarHeight_ - 1
			if _nValueRow_ < 1
				_nValueRow_ = 1
			ok
			
			# Format value based on aggregation type
			switch @cAggregationType
			on "frequency"
			    _cValue_ = "" + _nVal_
			on "sum"
			    _nRounded_ = 0+ RoundN(_nVal_, 1)
			    _cValue_ = iff(_nRounded_ = floor(_nRounded_), ('' + floor(_nRounded_)), ("" + _nRounded_))
			on "average"
			    _nRounded_ = 0+ RoundN(_nVal_, 2)
			    _cValue_ = iff(_nRounded_ = floor(_nRounded_), ('' + floor(_nRounded_)), ("" + _nRounded_))
			on "min"
			    _nRounded_ = 0+ RoundN(_nVal_, 1)
			    _cValue_ = iff(_nRounded_ = floor(_nRounded_), ('' + floor(_nRounded_)), ("" + _nRounded_))
			on "max"
			    _nRounded_ = 0+ RoundN(_nVal_, 1)
			    _cValue_ = iff(_nRounded_ = floor(_nRounded_), ('' + floor(_nRounded_)), ("" + _nRounded_))
			off
			
			_nValueLen_ = StzLen(_cValue_)
			_nValueStartX_ = _nCurrentX_ + floor((_nElementWidth_ - _nValueLen_) / 2)
			
			for k = 1 to _nValueLen_
				_nCol_ = _nValueStartX_ + k - 1
				if _nCol_ <= @nWidth and _nCol_ >= 1 and _nValueRow_ >= 1
					@acCanvas[_nValueRow_][_nCol_] = _cValue_[k]
				ok
			next
			
			if i < _nBars_
				_nCurrentX_ += _nElementWidth_ + _aBarSpacing_[i]
			ok
		next

	def _drawPercent(_oLayout_)
		_nBars_ = len(@anValues)
		_nBarsStartCol_ = _oLayout_[:bars_start_col]
		_nAxisRow_ = _oLayout_[:h_axis_row] 
		_nBarsAreaHeight_ = _oLayout_[:bars_area_height]
		_aElementWidths_ = _oLayout_[:element_widths]
		_aBarSpacing_ = _oLayout_[:bar_spacing]
		
		_nTotalCount_ = This.DataCount()
		_nCurrentX_ = _nBarsStartCol_
		
		for i = 1 to _nBars_
			_nElementWidth_ = _aElementWidths_[i]
			_nVal_ = @anValues[i]
			
			# Use same height calculation as bars
			if _nVal_ = 0
				_nBarHeight_ = 0
			else
				if @nMaxValue <= _nBarsAreaHeight_
					_nBarHeight_ = _nVal_
				else
					_nBarHeight_ = max([1, ceil(_nBarsAreaHeight_ * _nVal_ / @nMaxValue)])
				ok
			ok
			
			# Position percentage above the bar (one row above)
			_nValueRow_ = _nAxisRow_ - _nBarHeight_ - 1
			if _nValueRow_ < 1
				_nValueRow_ = 1
			ok
			
			# Calculate percentage based on frequency, not scaled bar height
			_nPercent_ = 0+ RoundN((_nVal_/_nTotalCount_)*100, 1)
			if _nPercent_ = floor(_nPercent_)
			    _cValue_ = "" + floor(_nPercent_) + '%'
			else
			    _cValue_ = "" + _nPercent_ + '%'
			ok
			
			_nValueLen_ = StzLen(_cValue_)
			_nValueStartX_ = _nCurrentX_ + floor((_nElementWidth_ - _nValueLen_) / 2)
			
			for k = 1 to _nValueLen_
				_nCol_ = _nValueStartX_ + k - 1
				if _nCol_ <= @nWidth and _nCol_ >= 1 and _nValueRow_ >= 1
					@acCanvas[_nValueRow_][_nCol_] = _cValue_[k]
				ok
			next
			
			if i < _nBars_
				_nCurrentX_ += _nElementWidth_ + _aBarSpacing_[i]
			ok
		next


	def _drawLabels(_oLayout_)
		# Draw bin range labels in two rows
		_nBars_ = len(@anValues)
		_nBarsStartCol_ = _oLayout_[:bars_start_col]
		_nLabelsRow_ = _oLayout_[:labels_row]
		_aElementWidths_ = _oLayout_[:element_widths]
		_aBarSpacing_ = _oLayout_[:bar_spacing]
	
		_nCurrentX_ = _nBarsStartCol_
		_nLenCanvas_ = len(@acCanvas)
	
		for i = 1 to _nBars_
			if i <= len(@aBinRanges)
				_nElementWidth_ = _aElementWidths_[i]
				
				# First row: start values
				_cLabel1_ = This._BinLabelFor(@aBinRanges[i][1])
				_nLenLabel1_ = StzLen(_cLabel1_)
				_nLabelStartX1_ = _nCurrentX_ + floor((_nElementWidth_ - _nLenLabel1_) / 2)
	
				for j = 1 to _nLenLabel1_
					_nCol_ = _nLabelStartX1_ + j - 1
					if _nCol_ <= @nWidth and (_nLabelsRow_ - 1) <= _nLenCanvas_
						@acCanvas[_nLabelsRow_ - 1][_nCol_] = _cLabel1_[j]
					ok
				next
	
				# Second row: end values  
				_cLabel2_ = This._BinLabelFor(@aBinRanges[i][2])
				_nLenLabel2_ = StzLen(_cLabel2_)
				_nLabelStartX2_ = _nCurrentX_ + floor((_nElementWidth_ - _nLenLabel2_) / 2)
	
				for j = 1 to _nLenLabel2_
					_nCol_ = _nLabelStartX2_ + j - 1
					if _nCol_ <= @nWidth and _nLabelsRow_ <= _nLenCanvas_
						@acCanvas[_nLabelsRow_][_nCol_] = _cLabel2_[j]
					ok
				next
			ok
	
			if i < _nBars_
				_nCurrentX_ += _aElementWidths_[i] + _aBarSpacing_[i]
			ok
		next


	def _formatNumber(nNumber)
	    if nNumber >= 1000
	        return '' + RoundN(nNumber/1000, 1) + "K"
	    else
	        return "" + RoundN(nNumber, 0)
	    ok
