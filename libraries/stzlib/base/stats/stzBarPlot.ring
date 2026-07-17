
# Simple rounding that avoids heavy stzNumber dependency
func _PlotRound(nNumber, nDecimals)
	_nPrFactor_ = 1
	for _iPr_ = 1 to nDecimals
		_nPrFactor_ = _nPrFactor_ * 10
	next
	_nPrResult_ = floor(nNumber * _nPrFactor_ + 0.5) / _nPrFactor_
	# Format with correct decimal places
	_cPrResult_ = "" + _nPrResult_
	_nPrDot_ = StzFindFirst(_cPrResult_, ".")
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

class stzBarPlot from stzObject

	# Data properties
	@anValues = []
	@acLabels = []
	@acCanvas = []

	# Display options
	@bShowHAxis = True
	@bShowVAxis = True
	@bShowLabels = True
	@bShowAxisLabels = True

	@bShowAverage = False
	@bShowValues = False
	@bShowPercent = False

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

	# --- Configuration Methods ---

	def SetSize(nWidth, nHeight)
		@nWidth = max([20, nWidth])
		@nHeight = max([6, nHeight])

	def Size()
		return [@nHeight, @nWidth]

		def SizeHV()
			return [@nWidth, @nHeight]

		def SizeVH()
			return [@nHeight, @nWidth]

	def Width()
		return @nWidth

	def Height()
		return @nHeight

	def MaxWidth()
		return @nMaxWidth

	def SetBarWidth(nWidth)
		@nBarWidth = max([1, nWidth])

	def SetBarInterSpace(nSpacing)
		@nBarInterSpace = max([0, nSpacing])

		def SetBarSpace(nSpacing)
			This.SetBarInterSpace(nSpacing)

		def SetInterBarSpace(nSpacing)
			This.SetBarInterSpace(nSpacing)

	def SetMaxLabelWidth(nWidth)
		@nMaxLabelWidth = max([3, nWidth])

	def SetHeight(n)
		@nHeight = max([2, n]) # Minimum 2 for visibility

	def SetWidth(n)
		@nWidth = n

	def SetMaxWidth(n)
		@nMaxWidth = n

	# Display options with H/V naming and XY aliases
	def SetHAxis(bShow)
		@bShowHAxis = bShow

		def WithoutHAxis()
			@bShowHAxis = FALSE

		# XY Aliases
		def SetXAxis(bShow)
			This.SetHAxis(bShow)

		def WithoutXAxis()
			This.WithoutHAxis()

	def SetVAxis(bShow)
		@bShowVAxis = bShow

		def WithoutVAxis()
			@bShowVAxis = FALSE

		# XY Aliases
		def SetYAxis(bShow)
			This.SetVAxis(bShow)

		def WithoutYAxis()
			This.WithoutVAxis()

	def SetHVAxis(bHShow, bVShow)
		@bShowHAxis = bHShow
		@bShowVAxis = bVShow

		def SetHVAxies(bHShow, bVShow)
			This.SetHVAxis(bHShow, bVShow)

		def WithoutHVAxis()
			This.SetHVAxis(FALSE, FALSE)

		def WithoutHVAxies()
			This.SetHVAxis(FALSE, FALSE)

		def WithoutAxis()
			This.SetHVAxis(FALSE, FALSE)

		def WithoutAxies()
			This.SetHVAxis(FALSE, FALSE)

		# XY Aliases
		def SetXYAxis(bHShow, bVShow)
			This.SetHVAxis(bHShow, bVShow)

		def SetXYAxies(bHShow, bVShow)
			This.SetHVAxis(bHShow, bVShow)

		def WithoutXYAxis()
			This.SetHVAxis(FALSE, FALSE)

		def WithoutXYAxies()
			This.SetHVAxis(FALSE, FALSE)

	def SetLabels(bShow)
		@bShowLabels = bShow
	
		def AddLabels()
			@bShowLabels = TRUE

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

	def SetAverage(bShow)
		@bShowAverage = bShow

		def AddAverage()
			@bShowAverage = TRUE

	def SetValues(bShow)
		@bShowValues = bShow
		if bShow
			@bShowPercent = False
		ok

		def AddValues()
			This.SetValues(TRUE)

	def SetPercent(bShow)
		@bShowPercent = bShow
		if bShow
			@bShowValues = False
		ok

		def AddPercent()
			This.SetPercent(TRUE)

	def SetAxisLabels(bShow)
		@bShowAxisLabels = bShow

		def SetHAxisLabels(bShow)
			This.SetAxisLabels(bShow)

		def AddHAxisLabels(bShow)
			This.SetAxisLabels(bShow)

		def WithoutAxisLabels()
			This.SetAxisLabels(FALSE)

		def WithoutHAxisLabels()
			This.SetAxisLabels(FALSE)

	# Character customization with H/V naming
	def SetBarChar(_cChar_)
		if IsChar(_cChar_)
			@cBarChar = _cChar_
			if @cTopChar != _cChar_
				@cTopChar = _cChar_
			ok
		ok

	def SetTopChar(_cChar_)
		if IsChar(_cChar_)
			@cTopChar = _cChar_
		ok

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

	# --- Main Methods ---

	def ToString()
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

	def Show()
		? ToString()

	# --- Accessors ---

	def Values()
		return @anValues

	def Labels()
		return @acLabels

	def Sum()
		return @nSum

	def Average()
		return @nAverage

	def MaxValue()
		return @nMaxValue

