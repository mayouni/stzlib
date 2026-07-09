
#-------------------------#
#  HISTOGRAM CHART CLASS  #
#-------------------------#

class stzHistogram from stzObject

	@bShowVAxis = True      # Vertical axis (was Y-axis)
	@bShowHAxis = True      # Horizontal axis (was X-axis)
	@bShowLabels = True
	@bShowFrequency = False
	@bShowPercent = False
	@bShowStats = False  # Show mean, std dev, etc.

	@nBinCount = 0       # Number of bins (0 = auto-calculate)
	@nBinRange = 0       # Width of each bin (0 = auto-calculate)
	@nBarWidth = 2
	@nMaxWidth = 132
	@nMaxLabelWidth = 12
	@nBarInterSpace = 1
	@nLabelInterSpace = 1

	@cBarChar = "â–ˆ"
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
	@cVAxisChar = "â”‚"
	@cHAxisChar = "â”€"
	@cVArrowChar = "â–²"
	@cHArrowChar = "â–º"
	@cOriginChar = "â•°"
	@cAverageChar = "-"

	# Histogram aggregation types
	@cAggregationType = "frequency"  # frequency, sum, average, min, max
	@bShowValues = FALSE # General flag to control value display for any aggregation

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
			_cLabel_ = _formatNumber(_nBinMin_) + "-" + _formatNumber(_nBinMax_)
			_cLabel_ = StzNumberQ(_nBinMin_).CompactForm() + "-" + StzNumberQ(_nBinMax_).ToCompactForm()
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

	# Configuration methods
	def SetBinCount(n)
		if n > 0
			@nBinCount = n
			_calculateBins()
			_processBinnedData()
		ok

		def SetBarCount(n)
			This.SetBinCount(n)

		def SetClassCount(n)
			This.SetBinCount(n)

		def DivideToNClasses(n)
			This.SetBinCount(n)

		def DivideToNGroups(n)
			This.SetBinCount(n)

	def SetBinRange(n)
		if n > 0
			@nBinRange = n
			@nBinCount = ceil((@nMaxValue - @nMinValue) / n)
			_calculateBins()
			_processBinnedData()
		ok

		def SetClassRange(n)
			This.SetBinRange(n)

	def SetHeight(n) #TODO //n should be the number of positions in the bar
		@nHeight = n

	def SetValues(bShow)
		@bShowValues = bShow
	
		def IncludeValues()
			@bShowValues = TRUE

		def AddValues()
			@bShowValues = TRUE

		def WithoutValues()
			@bShowValues = FALSE

	def SetAggregation(cType)
		@cAggregationType = cType
		_processBinnedData()

	def AggregationType()
		return @cAggregationType

		def Aggregation()
			return @cAggregationType

	def AggregationTypes()
		return [ "frequency", "sum", "average", "min", "max" ]

	def UseFrequency()
		@cAggregationType = "frequency"
		_processBinnedData()

		def UseFreq()
			This.UseFrequency()

	def UseSum()
		@cAggregationType = "sum"
		_processBinnedData()

	def UseAverage()
		@cAggregationType = "average"
		_processBinnedData()

	def UseMin()
		@cAggregationType = "min"
		_processBinnedData()

	def UseMax()
		@cAggregationType = "max"
		_processBinnedData()

	def SetStats(bShow) # Displays a recap of stats line at the bottom
		@bShowStats = bShow

		def AddStats()
			@bShowStats = TRUE

		def IncludeStats()
			@bShowStats = TRUE

	# Vertical axis methods (with X aliases for compatibility)
	def SetVAxis(bShow)
		@bShowVAxis = bShow

		def AddVAxis()
			@bShowVAxis = TRUE

		def IncludeVAxis()
			@bShowVAxis = TRUE

		def WithoutVAxis()
			@bShowVAxis = FALSE

		# X-axis aliases for backward compatibility
		def SetXAxis(bShow)
			This.SetVAxis(bShow)

		def AddXAxis()
			This.AddVAxis()

		def IncludeXAxis()
			This.IncludeVAxis()

		def WithoutXAxis()
			This.WithoutVAxis()

	# Horizontal axis methods (with Y aliases for compatibility)
	def SetHAxis(bShow)
		@bShowHAxis = bShow

		def AddHAxis()
			@bShowHAxis = TRUE

		def IncludeHAxis()
			@bShowHAxis = TRUE

		def WithoutHAxis()
			@bShowHAxis = FALSE

		# Y-axis aliases for backward compatibility
		def SetYAxis(bShow)
			This.SetHAxis(bShow)

		def AddYAxis()
			This.AddHAxis()

		def IncludeYAxis()
			This.IncludeHAxis()

		def WithoutYAxis()
			This.WithoutHAxis()

	def SetLabels(bShow)
		@bShowLabels = bShow

		def AddLabels()
			@bShowLabels = TRUE

		def IncludeLabels()
			@bShowLabels = TRUE

		def WithoutLabels()
			@bShowLabels = FALSE

	def SetPercent(bShow)
		@bShowPercent = bShow

		def AddPercent()
			@bShowPercent = TRUE

		def IncludePercent()
			@bShowPercent = TRUE

	def SetBarWidth(nWidth)
		@nBarWidth = max([1, nWidth])

	def SetMaxWidth(nWidth)
		@nMaxWidth = nWidth

	def SetBarInterSpace(n)
		@nBarInterSpace = n  # 0 = auto-calculate, >0 = fixed spacing

	def SetBarChar(c)
		if CheckParams()
			if not IsChar(c)
				StzRaise("Incorrect param type! c must be a char.")
			ok
		ok
		@cBarChar = c

	def SetFinalBarChar(c)
		if CheckParams()
			if not IsChar(c)
				StzRaise("Incorrect param type! c must be a char.")
			ok
		ok
		@cFinalBarChar = c

		def SetTopBarChar(c)
			This.SetFinalBarChar(c)

	def SetLabelInterSpace(n)
	    @nLabelInterSpace = n

	# Statistical methods for histogram
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

	def Mode()
		# Find the bin with highest frequency
		_nMaxFreq_ = max(@aBinCounts)
		_nModeIndex_ = StzFindFirst(@aBinCounts, _nMaxFreq_)
		
		if _nModeIndex_ > 0
			return @aBinRanges[_nModeIndex_]
		else
			return [0, 0]
		ok

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
			_cResult_ += _cLine_ + NL
		next
		
		# Remove final newline
		if StzLen(_cResult_) > 0 and StzRight(_cResult_, 1) = NL
			_cResult_ = StzLeft(_cResult_, StzLen(_cResult_) - 1)
		ok
		
		return _cResult_
	
	#--- DISPLAY

	def Show()
		? This.ToString()

	def ToString()
		
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
		if @bShowHAxis = FALSE

			_oStrTemp_ = new stzString(_cResult_)
			_nPos_ = _oStrTemp_.FindFirst(NL)
			_oStrTemp_.RemoveSection(1, _nPos_)
			_cResult_ = _oStrTemp_.Content()
		ok

		# A hack to add an empty at the top of the H Axis

		if ring_substr1(_cResult_, @cVArrowChar) > 0

			_oStrTemp_ = new stzString(_cResult_)
			_nPos_ = _oStrTemp_.FindNth(1, NL)
			_bFirstLineIsEmpty_ = @trim(_oStrTemp_.Section(4, _nPos_-1)) = ""

			if NOT _bFirstLineIsEmpty_ # then add an empty line
				_cResult_ = StzReplace(_cResult_, @cVArrowChar, @cVAxisChar)
				_cResult_ = @cVArrowChar + NL + _cResult_
			ok

		ok

		# Add statistics if requested
		if @bShowStats

			_cStats_ = NL + NL +
				"Mean:   " + RoundN(This.Mean(), 2) + NL +
			    "StdDev: " + RoundN(This.StandardDeviation(), 2) + NL +
			    "Median: " + RoundN(This.Median(), 2) + NL +
			    "Count:  " + This.DataCount()

			_cResult_ += _cStats_
		ok
	
		return _cResult_

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
		        _cLabel1_ = "" + RoundN(@aBinRanges[i][1], 1)
		        _cLabel2_ = "" + RoundN(@aBinRanges[i][2], 1)
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
				//cLabel1 = "" + RoundN(@aBinRanges[i][1], 1)
				_cLabel1_ = _formatNumber(@aBinRanges[i][1])
				_cLabel1_ = StzNumberQ(@aBinRanges[i][1]).ToCompactForm()
				_nLenLabel1_ = StzLen(_cLabel1_)
				_nLabelStartX1_ = _nCurrentX_ + floor((_nElementWidth_ - _nLenLabel1_) / 2)
	
				for j = 1 to _nLenLabel1_
					_nCol_ = _nLabelStartX1_ + j - 1
					if _nCol_ <= @nWidth and (_nLabelsRow_ - 1) <= _nLenCanvas_
						@acCanvas[_nLabelsRow_ - 1][_nCol_] = _cLabel1_[j]
					ok
				next
	
				# Second row: end values  
				//cLabel2 = "" + RoundN(@aBinRanges[i][2], 1)
				_cLabel2_ = _formatNumber(@aBinRanges[i][2])
				_cLabel2_ = StzNumberQ(@aBinRanges[i][2]).CompactForm()
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
