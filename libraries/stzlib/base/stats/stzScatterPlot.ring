
#-----------------------#
#  SCATTER CHART CLASS  #
#-----------------------#

class stzScatterChart from stzScatterPlot

class stzScatterPlot from stzObject

	@anHValues = []
	@anVValues = []
	@acPointLabels = []

	@bShowHAxis = True
	@bShowVAxis = True
	@bShowGrid = False
	@bShowLabels = false

	# V and H letters at the end of the axes
	@bShowHLetter = FALSE
	@bShowVLetter = FALSE

	# Console defaults
	@nMaxWidth = 42 
	@nMaxHeight = 12 
	@nHAxisHeight = 2

	@cPointChar = "●"
	@cVerticalGridChar = "⁞"
	@cHorizontalGridChar = "-"

	@cHTickChar = "┬"
	@cHTickChar2 = "┼"
	@cVTickChar = "┤"

	# Axis and drawing characters
	@cHAxisChar = "─"
	@cVAxisChar = "│"
	@cOriginChar = "╰"
	@cHArrowChar = "►"
	@cVArrowChar = "▲"

	@nHMin = 0
	@nHMax = 0
	@nVMin = 0
	@nVMax = 0

	@nWidth = 0
	@nHeight = 0
	@acCanvas = []

	def init(paDataSet)
		if NOT isList(paDataSet)
			StzRaise("Can't create stzScatterChart! paDataSet must be a list.")
		ok

		if IsListOfPairs(paDataSet) and len(paDataSet) > 0 and IsListOfNumbers(paDataSet[1])
			@anHValues = []
			@anVValues = []
			@acPointLabels = []

			_nDataSetLen_ = len(paDataSet)
			for i = 1 to _nDataSetLen_
				if len(paDataSet[i]) >= 2
					@anHValues + paDataSet[i][1]
					@anVValues + paDataSet[i][2]
					@acPointLabels + ("P" + i)
				ok
			next

		but IsHashList(paDataSet)
			_oHash_ = new stzHashList(paDataSet)
			_aKeys_ = _oHash_.Keys()

			if len(_aKeys_) = 2 and (_aKeys_[1] = "H" or _aKeys_[1] = :H or _aKeys_[1] = "X" or _aKeys_[1] = :X) and 
			   (_aKeys_[2] = "V" or _aKeys_[2] = :V or _aKeys_[2] = "Y" or _aKeys_[2] = :Y)
				
				if _aKeys_[1] = "H" or _aKeys_[1] = :H
					@anHValues = paDataSet[:H]
				else
					@anHValues = paDataSet[:X]
				ok
				
				if _aKeys_[2] = "V" or _aKeys_[2] = :V
					@anVValues = paDataSet[:V]
				else
					@anVValues = paDataSet[:Y]
				ok

				if len(@anHValues) != len(@anVValues)
					StzRaise("H and V value arrays must have same length!")
				ok

				@acPointLabels = []
				_nHValuesLen_3 = len(@anHValues)
				for i = 1 to _nHValuesLen_3
					@acPointLabels + ("P" + i)
				next

			else
				@anHValues = []
				@anVValues = []
				@acPointLabels = _oHash_.Keys()

				_aValues_ = _oHash_.Values()
				_nValuesLen_ = len(_aValues_)
				for i = 1 to _nValuesLen_
					if isList(_aValues_[i]) and len(_aValues_[i]) >= 2
						@anHValues + _aValues_[i][1]
						@anVValues + _aValues_[i][2]
					ok
				next
			ok

		else
			StzRaise("Invalid data format! Use [[h1,v1], [h2,v2]] or hashlist format.")
		ok

		if NOT (IsListOfNumbers(@anHValues) and IsListOfNumbers(@anVValues))
			StzRaise("H and V values must all be numbers!")
		ok

		_calculateRanges()

		@bShowHLetter = TRUE
		@bShowVLetter = TRUE

	# Primary methods with V/H semantics
	def HValues()
		return @anHValues
		
		def XValues()  # Alias
			return This.HValues()

	def VValues()
		return @anVValues
		
		def YValues()  # Alias
			return This.VValues()

	def PointLabels()
		return @acPointLabels

	def SetHAxis(bShow)
		@bShowHAxis = bShow
		
		def SetXAxis(bShow)  # Alias
			This.SetHAxis(bShow)

		def WithoutHAxis()
			@bShowHAxis = FALSE
			
		def WithoutXAxis()  # Alias
			This.WithoutHAxis()

	def SetVAxis(bShow)
		@bShowVAxis = bShow
		
		def SetYAxis(bShow)  # Alias
			This.SetVAxis(bShow)

		def WithoutVAxis()
			@bShowVAxis = FALSE
			
		def WithoutYAxis()  # Alias
			This.WithoutVAxis()

	def SetHVAxis(bShow)
		@bShowHAxis = bShow
		@bShowVAxis = bShow

		def SetVHAxis(bShow)
			This.SetHVAxis(bShow)

		def SetHVAxes(bShow)
			This.SetHVAxis(bShow)

		def SetVHAxes(bShow)
			This.SetHVAxis(bShow)
			
		# X/Y aliases
		def SetXYAxis(bShow)
			This.SetHVAxis(bShow)
			
		def SetYXAxis(bShow)
			This.SetHVAxis(bShow)
			
		def SetXYAxes(bShow)
			This.SetHVAxis(bShow)
			
		def SetYXAxes(bShow)
			This.SetHVAxis(bShow)

		def WithoutHVAxis()
			This.SetHVAxis(FALSE)

		def WithoutVHAxis()
			This.SetHVAxis(FALSE)
			
		def WithoutXYAxis()  # Alias
			This.SetHVAxis(FALSE)

		def WithoutYXAxis()  # Alias
			This.SetHVAxis(FALSE)

	def SetHVLetters(bShow)
		@bShowHLetter = bShow
		@bShowVLetter = bShow

		def SetVH(bShow)
			This.SetHVLetters(bShow)
			
		def SetXYLetters(bShow)  # Alias
			This.SetHVLetters(bShow)

		def SetXY(bShow)  # Alias
			This.SetHVLetters(bShow)

		def WithoutHV()
			This.SetHVLetters(FALSE)
			
		def WithoutXY()  # Alias
			This.SetHVLetters(FALSE)

		def WithoutHVLetters()
			This.SetHVLetters(FALSE)
			
		def WithoutXYLetters()  # Alias
			This.SetHVLetters(FALSE)

	def SetHLetter(bShow)
		@bShowHLetter = bShow

		def SetH(bShow)
			@bShowHLetter = bShow
			
		def SetXLetter(bShow)  # Alias
			@bShowHLetter = bShow

		def SetX(bShow)  # Alias
			@bShowHLetter = bShow

		def WithoutH()
			@bShowHLetter = FALSE
			
		def WithoutX()  # Alias
			@bShowHLetter = FALSE

		def WithoutHLetter()
			@bShowHLetter = FALSE
			
		def WithoutXLetter()  # Alias
			@bShowHLetter = FALSE

	def SetVLetter(bShow)
		@bShowVLetter = bShow

		def SetV(bShow)
			@bShowVLetter = bShow
			
		def SetYLetter(bShow)  # Alias
			@bShowVLetter = bShow

		def SetY(bShow)  # Alias
			@bShowVLetter = bShow

		def WithoutV()
			@bShowVLetter = FALSE
			
		def WithoutY()  # Alias
			@bShowVLetter = FALSE

		def WithoutVLetter()
			@bShowVLetter = FALSE
			
		def WithoutYLetter()  # Alias
			@bShowVLetter = FALSE

	def SetGrid(bShow)
		@bShowGrid = bShow

		def AddGrid()
			@bShowGrid = TRUE

		def WithoutGrid()
			@bShowGrid = FALSE

	def SetLabels(bShow)
		@bShowLabels = bShow

		def AddLabels()
			@bShowLabels = TRUE

		def WithoutLabels()
			@bShowLabels = FALSE

	def SetPointChar(c)
		if NOT (isString(c) and IsChar(c))
			StzRaise("c must be a char.")
		ok
		@cPointChar = c

		def PointChar()
			return @cPointChar

	def SetMaxSize(nWidth, nHeight)
		if NOT (isNumber(nWidth) and isNumber(nHeight))
			StzRaise("nWidth and nHeight must be numbers.")
		ok
		@nMaxWidth = max([40, nWidth])
		@nMaxHeight = max([10, nHeight])

	def SetWidth(nWidth)
		if NOT isNumber(nWidth)
			StzRaise("nWidth must be a number.")
		ok
		@nMaxWidth = max([50, nWidth])

	def SetHeight(nHeight)
		if NOT isNumber(nHeight)
			StzRaise("nHeight must be a number.")
		ok
		@nMaxHeight = max([10, nHeight])

	def Show()
		? This.ToString()

	def ToString()
		_oLayout_ = _calculateLayout()
		_initCanvas()

		if @bShowGrid
			_drawCoordinateGrid(_oLayout_)
		ok

		if @bShowVAxis
			_drawVAxis(_oLayout_)
		ok

		if @bShowHAxis
			_drawHAxis(_oLayout_)
		ok

		_drawPoints(_oLayout_)

		if @bShowLabels
			_drawPointLabels(_oLayout_)
		ok

		return _finalizeCanvas()

	def _calculateRanges()
		if len(@anHValues) = 0 or len(@anVValues) = 0
			@nHMin = 0
			@nHMax = 10
			@nVMin = 0
			@nVMax = 10
			return
		ok

		@nHMin = min(@anHValues)
		@nHMax = max(@anHValues)
		@nVMin = min(@anVValues)
		@nVMax = max(@anVValues)

		if _areAllIntegers(@anHValues)
			@nHMin = floor(@nHMin)
			@nHMax = ceil(@nHMax)
		ok
		if _areAllIntegers(@anVValues)
			@nVMin = floor(@nVMin)
			@nVMax = ceil(@nVMax)
		ok

	def _areAllIntegers(anList)
		_nAnList1Len_ = len(anList)
		for _iLoopAnList1_ = 1 to _nAnList1Len_
			_n_ = anList[_iLoopAnList1_]
			if NOT isNumber(_n_) or floor(_n_) != _n_
				return FALSE
			ok
		next
		return TRUE

	def _calculateLayout()
		# Calculate dynamic V-axis width based on actual labels
		_nDynamicVAxisWidth_ = 0
		if @bShowVAxis
			_aUniqueV_ = U(@anVValues)
			_aUniqueV_ = new stzList(_aUniqueV_).Sorted()
			_nMaxVLabelLen_ = 0
			_nUniqueV2Len_ = len(_aUniqueV_)
			for _iLoopUniqueV2_ = 1 to _nUniqueV2Len_
				_nV_ = _aUniqueV_[_iLoopUniqueV2_]
				_cLabel_ = _formatValue(_nV_)
				_cLabel_ = Trim(_cLabel_)
				if len(_cLabel_) > _nMaxVLabelLen_
					_nMaxVLabelLen_ = len(_cLabel_)
				ok
			next
			# V-axis width = max label length + space + tick mark + small buffer
			_nDynamicVAxisWidth_ = _nMaxVLabelLen_ + 3
			# Ensure minimum width for readability
			_nDynamicVAxisWidth_ = max([4, _nDynamicVAxisWidth_])
		ok

		# Calculate available space for the plot area
		_nVAxisSpace_ = _nDynamicVAxisWidth_
		_nHAxisSpace_ = iff(@bShowHAxis, @nHAxisHeight, 0)
		
		# Reserve space for arrow character
		_nTopMargin_ = 1    # For vertical arrow
		
		# Calculate right margin based on longest label
		_nLenPointLabels_ = len(@acPointLabels)
		_nRightMargin_ = 2  # Default minimum
		if @bShowLabels
		    _nMaxLabelLen_ = 0
		    for i = 1 to _nLenPointLabels_
				_nLenLabel_ = len(@acPointLabels[i])
		        if _nLenLabel_ > _nMaxLabelLen_
		            _nMaxLabelLen_ = _nLenLabel_
		        ok
		    next
		    _nRightMargin_ = _nMaxLabelLen_ + 3  # Label length + spacing + buffer
		ok

		# Calculate plot dimensions with proper margins
		_nPlotWidth_ = @nMaxWidth - _nVAxisSpace_ - _nRightMargin_
		_nPlotHeight_ = @nMaxHeight - _nHAxisSpace_ - _nTopMargin_
		
		# Ensure minimum plot area
		_nPlotWidth_ = max([20, _nPlotWidth_])
		_nPlotHeight_ = max([8, _nPlotHeight_])
		
		# Calculate positions
		_nVAxisCol_ = _nVAxisSpace_
		_nPlotStartCol_ = _nVAxisCol_ + 1
		_nPlotEndCol_ = _nPlotStartCol_ + _nPlotWidth_ - 1
		
		_nPlotStartRow_ = _nTopMargin_ + 1
		_nHAxisRow_ = _nPlotStartRow_ + _nPlotHeight_
		_nPlotEndRow_ = _nHAxisRow_ - 1
		
		# Total canvas dimensions
		_nTotalWidth_ = _nPlotEndCol_ + _nRightMargin_
		_nTotalHeight_ = _nHAxisRow_ + _nHAxisSpace_
		
		# Set instance variables
		@nWidth = _nTotalWidth_
		@nHeight = _nTotalHeight_

		_oLayout_ = new stzHashList([])
		_oLayout_.AddPair([:plot_start_col, _nPlotStartCol_])
		_oLayout_.AddPair([:plot_end_col, _nPlotEndCol_])
		_oLayout_.AddPair([:plot_start_row, _nPlotStartRow_])
		_oLayout_.AddPair([:plot_end_row, _nPlotEndRow_])
		_oLayout_.AddPair([:plot_width, _nPlotWidth_])
		_oLayout_.AddPair([:plot_height, _nPlotHeight_])
		_oLayout_.AddPair([:v_axis_col, _nVAxisCol_])
		_oLayout_.AddPair([:h_axis_row, _nHAxisRow_])
		_oLayout_.AddPair([:total_width, _nTotalWidth_])
		_oLayout_.AddPair([:total_height, _nTotalHeight_])

		return _oLayout_

	def _drawCoordinateGrid(_oLayout_)
		_nStartCol_ = _oLayout_[:plot_start_col]
		_nEndCol_ = _oLayout_[:plot_end_col]
		_nStartRow_ = _oLayout_[:plot_start_row]
		_nEndRow_ = _oLayout_[:plot_end_row]
		_nPlotWidth_ = _oLayout_[:plot_width]
		_nPlotHeight_ = _oLayout_[:plot_height]

		# Draw grid lines only from axis to each data point
		_nHValuesLen_2 = len(@anHValues)
		for i = 1 to _nHValuesLen_2
			_nH_ = @anHValues[i]
			_nV_ = @anVValues[i]
			
			# Calculate point position
			_nCol_ = _nStartCol_ + floor((_nH_ - @nHMin) * (_nPlotWidth_ - 1) / (@nHMax - @nHMin))
			_nRow_ = _nEndRow_ - floor((_nV_ - @nVMin) * (_nPlotHeight_ - 1) / (@nVMax - @nVMin))
			
			# Draw horizontal line from V-axis to point
			for j = _nStartCol_ to _nCol_
				if @acCanvas[_nRow_][j] = " "
					@acCanvas[_nRow_][j] = @cHorizontalGridChar
				ok
			next
			
			# Draw vertical line from H-axis to point
			for j = _nRow_ to _nEndRow_
				if @acCanvas[j][_nCol_] = " "
					@acCanvas[j][_nCol_] = @cVerticalGridChar
				ok
			next
		next

	def _drawVAxis(_oLayout_)
		if NOT @bShowVAxis
			return
		ok
		
		_nAxisCol_ = _oLayout_[:v_axis_col]
		_nStartRow_ = _oLayout_[:plot_start_row]
		_nEndRow_ = _oLayout_[:plot_end_row]
		_nHAxisRow_ = _oLayout_[:h_axis_row]
		_nPlotHeight_ = _oLayout_[:plot_height]

		# Draw vertical line
		for i = _nStartRow_ to _nEndRow_
			if i >= 1 and i <= len(@acCanvas) and _nAxisCol_ >= 1 and _nAxisCol_ <= len(@acCanvas[i])
				@acCanvas[i][_nAxisCol_] = @cVAxisChar
			ok
		next

		# Draw arrow at top
		if _nStartRow_ - 1 >= 1 and _nStartRow_ - 1 <= len(@acCanvas) and _nAxisCol_ >= 1 and _nAxisCol_ <= len(@acCanvas[_nStartRow_ - 1])
			@acCanvas[_nStartRow_ - 1][_nAxisCol_] = @cVArrowChar
		ok

		# Draw origin (only if H-axis is also visible)
		if @bShowHAxis and _nHAxisRow_ >= 1 and _nHAxisRow_ <= len(@acCanvas) and _nAxisCol_ >= 1 and _nAxisCol_ <= len(@acCanvas[_nHAxisRow_])
			@acCanvas[_nHAxisRow_][_nAxisCol_] = @cOriginChar
		ok

		# Always draw V-axis labels when V-axis is visible
		_aUniqueV_ = U(@anVValues)
		_aUniqueV_ = new stzList(_aUniqueV_).Sorted()
		_nUniqueV1Len_ = len(_aUniqueV_)
		for _iLoopUniqueV1_ = 1 to _nUniqueV1Len_
			_nV_ = _aUniqueV_[_iLoopUniqueV1_]
			_nRow_ = _nEndRow_ - floor((_nV_ - @nVMin) * (_nPlotHeight_ - 1) / (@nVMax - @nVMin))
			if _nRow_ >= _nStartRow_ and _nRow_ <= _nEndRow_
				_cLabel_ = _formatValue(_nV_)
				_cLabel_ = Trim(_cLabel_)
				_nLabelLen_ = len(_cLabel_)
				_nLabelStart_ = _nAxisCol_ - _nLabelLen_ - 1  # Add space before tick mark
				if _nLabelStart_ >= 1
					for j = 1 to _nLabelLen_
						@acCanvas[_nRow_][_nLabelStart_ + j - 1] = _cLabel_[j]
					next
					@acCanvas[_nRow_][_nAxisCol_] = @cVTickChar
				ok
			ok
		next

	def _drawHAxis(_oLayout_)
		if NOT @bShowHAxis
			return
		ok
		
		_nAxisRow_ = _oLayout_[:h_axis_row]
		_nStartCol_ = _oLayout_[:plot_start_col]
		_nEndCol_ = _oLayout_[:plot_end_col]
		_nVAxisCol_ = _oLayout_[:v_axis_col]
		_nPlotWidth_ = _oLayout_[:plot_width]
		_nTotalWidth_ = _oLayout_[:total_width]

		# Draw horizontal line
		if _nAxisRow_ >= 1 and _nAxisRow_ <= len(@acCanvas)
			for i = _nStartCol_ to _nEndCol_
				if i >= 1 and i <= _nTotalWidth_
					@acCanvas[_nAxisRow_][i] = @cHAxisChar
				ok
			next
		ok

		# Draw arrow at end
		if _nAxisRow_ >= 1 and _nAxisRow_ <= len(@acCanvas) and _nEndCol_ + 1 >= 1 and _nEndCol_ + 1 <= _nTotalWidth_
			@acCanvas[_nAxisRow_][_nEndCol_ + 1] = @cHArrowChar
		ok

		# Draw origin
		if @bShowVAxis and _nAxisRow_ >= 1 and _nAxisRow_ <= len(@acCanvas) and _nVAxisCol_ >= 1 and _nVAxisCol_ <= _nTotalWidth_
			@acCanvas[_nAxisRow_][_nVAxisCol_] = @cOriginChar
		ok

		# Always draw H-axis labels when H-axis is visible
		_aUniqueH_ = U(@anHValues)
		_aUniqueH_ = new stzList(_aUniqueH_).Sorted()
		_nUniqueH1Len_ = len(_aUniqueH_)
		for _iLoopUniqueH1_ = 1 to _nUniqueH1Len_
			_nH_ = _aUniqueH_[_iLoopUniqueH1_]
			_nCol_ = _nStartCol_ + floor((_nH_ - @nHMin) * (_nPlotWidth_ - 1) / (@nHMax - @nHMin))
			if _nCol_ >= _nStartCol_ and _nCol_ <= _nEndCol_
				_cLabel_ = _formatValue(_nH_)
				_nLabelLen_ = len(_cLabel_)
				_nLabelStart_ = _nCol_ - floor(_nLabelLen_ / 2)
				
				# Draw tick mark
				if _nCol_ >= 1 and _nCol_ <= _nTotalWidth_
					@acCanvas[_nAxisRow_][_nCol_] = @cHTickChar
				ok
				
				# Draw label below axis (always when axis is visible)
				if _nAxisRow_ + 1 >= 1 and _nAxisRow_ + 1 <= len(@acCanvas) and
				   _nLabelStart_ >= 1 and _nLabelStart_ + _nLabelLen_ - 1 <= _nTotalWidth_
					for j = 1 to _nLabelLen_
						@acCanvas[_nAxisRow_ + 1][_nLabelStart_ + j - 1] = _cLabel_[j]
					next
				ok
			ok
		next

	def _formatValue(nValue)
		if _areAllIntegers(@anHValues) and _areAllIntegers(@anVValues)
			return "" + floor(nValue)
		else
			return "" + RoundN(nValue, 1)
		ok

	def _drawPoints(_oLayout_)
		_nStartCol_ = _oLayout_[:plot_start_col]
		_nEndCol_ = _oLayout_[:plot_end_col]
		_nStartRow_ = _oLayout_[:plot_start_row]
		_nEndRow_ = _oLayout_[:plot_end_row]
		_nPlotWidth_ = _oLayout_[:plot_width]
		_nPlotHeight_ = _oLayout_[:plot_height]

		_nHValuesLen_ = len(@anHValues)
		for i = 1 to _nHValuesLen_
			_nH_ = @anHValues[i]
			_nV_ = @anVValues[i]

			# Calculate point position
			if @nHMax = @nHMin
				_nCol_ = _nStartCol_ + floor(_nPlotWidth_ / 2)
			else
				_nCol_ = _nStartCol_ + floor((_nH_ - @nHMin) * (_nPlotWidth_ - 1) / (@nHMax - @nHMin))
			ok
			
			if @nVMax = @nVMin
				_nRow_ = _nStartRow_ + floor(_nPlotHeight_ / 2)
			else
				_nRow_ = _nEndRow_ - floor((_nV_ - @nVMin) * (_nPlotHeight_ - 1) / (@nVMax - @nVMin))
			ok
			
			# Ensure point is within bounds
			_nCol_ = max([_nStartCol_, min([_nEndCol_, _nCol_])])
			_nRow_ = max([_nStartRow_, min([_nEndRow_, _nRow_])])
			
			# Draw the point
			if _nRow_ >= 1 and _nRow_ <= len(@acCanvas) and _nCol_ >= 1 and _nCol_ <= len(@acCanvas[_nRow_])
				@acCanvas[_nRow_][_nCol_] = @cPointChar
			ok
		next

	def _drawPointLabels(_oLayout_)
		_nStartCol_ = _oLayout_[:plot_start_col]
		_nEndCol_ = _oLayout_[:plot_end_col]
		_nStartRow_ = _oLayout_[:plot_start_row]
		_nEndRow_ = _oLayout_[:plot_end_row]
		_nPlotWidth_ = _oLayout_[:plot_width]
		_nPlotHeight_ = _oLayout_[:plot_height]

		_nLenHVal_ = len(@anHValues)
		_nLenLabels_ = len(@acPointLabels)

		for i = 1 to _nLenHVal_
			if i <= _nLenLabels_
				_nH_ = @anHValues[i]
				_nV_ = @anVValues[i]
				_cLabel_ = " " + Capitalise(@acPointLabels[i])

				# Calculate point position (same as in _drawPoints)
				if @nHMax = @nHMin
					_nCol_ = _nStartCol_ + floor(_nPlotWidth_ / 2)
				else
					_nCol_ = _nStartCol_ + floor((_nH_ - @nHMin) * (_nPlotWidth_ - 1) / (@nHMax - @nHMin))
				ok
				
				if @nVMax = @nVMin
					_nRow_ = _nStartRow_ + floor(_nPlotHeight_ / 2)
				else
					_nRow_ = _nEndRow_ - floor((_nV_ - @nVMin) * (_nPlotHeight_ - 1) / (@nVMax - @nVMin))
				ok

				# Position label right next to the point (1 space to the right)
				_nLabelCol_ = _nCol_ + 1
				_nLabelRow_ = _nRow_

				# Check bounds and draw label
				_nLenLabel_ = len(_cLabel_)

				if _nLabelRow_ >= 1 and _nLabelRow_ <= @nHeight and 
				   _nLabelCol_ >= 1 and _nLabelCol_ + _nLenLabel_ - 1 <= @nWidth
					for j = 1 to _nLenLabel_
						if _nLabelCol_ + j - 1 <= @nWidth
							@acCanvas[_nLabelRow_][_nLabelCol_ + j - 1] = _cLabel_[j]
						ok
					next
				ok
			ok
		next

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
		_nLenCanvas_ = len(@acCanvas)
		for i = 1 to _nLenCanvas_
			_cLine_ = ""
			_nLenCurrent_ = len(@acCanvas[i])
			for j = 1 to _nLenCurrent_
				_cLine_ += @acCanvas[i][j]
			next
			_cResult_ += _cLine_ + nl
		next

		# Remove unnecessary empty lines
		_oTempStr_ = new stzString(_cResult_)
		if @bShowVAxis = FALSE
			_nPos_ = _oTempStr_.FindFirst(NL)
			_oTempStr_.RemoveSection(1, _nPos_)
		ok

		_anPos_ = _oTempStr_.FindAll(NL)
		if len(_anPos_) > 0
			_nPos_ = _anPos_[len(_anPos_)-1]
			_oTempStr_.RemoveSection(_nPos_, _oTempStr_.NumberOfChars())
		ok

		# Adjust markers when grid is active
		if @bShowGrid
			_oTempStr_.ReplaceMany([@cHTickChar, @cVTickChar], @cHTickChar2)
		ok

		# Add H and V letters if required (showing as X/Y for backward compatibility)

		if @bShowHLetter and @bShowHAxis
			# Place X letter at the end of horizontal axis
			_cResult_ = _oTempStr_.Content()
			_acLines_ = split(_cResult_, nl)
			
			# Find the line with horizontal axis and add X at the end
			_nLinesLen_5 = len(_acLines_)
			for i = 1 to _nLinesLen_5
				if ring_substr1(_acLines_[i], @cHArrowChar)  > 0
					_acLines_[i] += " Y"  # Horizontal axis gets Y label
					exit
				ok
			next
			
			_cResult_ = ""
			_nLinesLen_4 = len(_acLines_)
			for i = 1 to _nLinesLen_4
				_cResult_ += _acLines_[i]
				if i < len(_acLines_)
					_cResult_ += nl
				ok
			next
			_oTempStr_ = new stzString(_cResult_)
			# Place Y letter at the end of horizontal axis
			_oTempStr_.Replace(@cHArrowChar, @cHAxisChar + @cHAxisChar + @cHArrowChar + " Y")
		ok

		if @bShowVLetter and @bShowVAxis
			# Place X letter at the top of vertical axis
			_cResult_ = _oTempStr_.Content()
			_acLines_ = split(_cResult_, nl)
			
			# Find the line with vertical arrow and add X above it
			_nLinesLen_3 = len(_acLines_)
			for i = 1 to _nLinesLen_3
				if ring_substr1(_acLines_[i], @cVArrowChar) > 0
					_nArrowPos_ = ring_substr1(_acLines_[i], @cVArrowChar)
					if _nArrowPos_ > 0
						# Create X line above the arrow
						_cXLine_ = RepeatChar(" ", _nArrowPos_-1) + "X"
						# Insert at the beginning
						_acNewLines_ = [_cXLine_]
						_nLinesLen_2 = len(_acLines_)
						for j = 1 to _nLinesLen_2
							_acNewLines_ + _acLines_[j]
						next
						_acLines_ = _acNewLines_
					ok
					exit
				ok
			next
			
			_cResult_ = ""
			_nLinesLen_ = len(_acLines_)
			for i = 1 to _nLinesLen_
				_cResult_ += _acLines_[i]
				if i < len(_acLines_)
					_cResult_ += nl
				ok
			next
			_oTempStr_ = new stzString(_cResult_)
			# Place X letter at the end of vertical axis
			_nPos_ = _oTempStr_.FindFirst(@cVArrowChar)
			_oTempStr_.InsertAt(1, RepeatChar(" ", _nPos_-1) + "X" + NL)

			_oTempStr_.Replace(@cVArrowChar, @cVArrowChar + NL + RepeatChar(" ", _nPos_-1) + @cVAxisChar)
		ok


		_cResult_ = _oTempStr_.Content()
		return _cResult_
