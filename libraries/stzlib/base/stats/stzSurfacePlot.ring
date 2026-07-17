
#---------------------------------------#
#  SURFACE COMPOSITION-ORIENTED CHART   #
#---------------------------------------#

class stzSurfaceChart from stzSurfacePlot
class stzSquareChart from stzSurfacePlot
class stzSquarePlot from stzSurfacePlot

class stzSurfacePlot from stzObject

	@bShowPercent = FALSE
	@bShowBorders = TRUE
	@bShowLabels = TRUE
	@bShowValues = FALSE

	@nMinWidth = 40
	@nMinHeight = 12
	@nMaxWidth = 120
	@nMaxHeight = 30
	
	@nWidth = 40
	@nHeight = 12
	@nMinLabelWidth = 3  # Minimum characters to show from label

	# Border characters
	@cTopLeft = char(226) + char(149) + char(173)
	@cTopRight = char(226) + char(149) + char(174)
	@cBottomLeft = char(226) + char(149) + char(176)
	@cBottomRight = char(226) + char(149) + char(175)
	@cHorizontal = char(226) + char(148) + char(128)
	@cVertical = char(226) + char(148) + char(130)
	@cTeeDown = char(226) + char(148) + char(172)
	@cTeeUp = char(226) + char(148) + char(180)
	@cTeeRight = char(226) + char(148) + char(156)
	@cTeeLeft = char(226) + char(148) + char(164)
	@cCross = char(226) + char(148) + char(188)

	@aRectangles = []
	@nSum = 0
	@anValues = []
	@acLabels = []
	@acCanvas = []
	@bShowLegend = FALSE
	@aLegend = []

def init(paData)
	if NOT isList(paData)
		raise("Can't create the stzSquareChart object! paData must be a list.")
	ok

	if NOT (IsListOfNumbers(paData) or IsHashList(paData))
		raise("Can't create the stzSquareChart object! paData must be a list of numbers or a hashlist.")
	ok

	# In case a list of numbers is provided (the dataset
	# contains no labels ~> Added automatically as :1, :2, etc.
	if IsListOfNumbers(paData)
		_aTemp_ = []
		_nLen_ = len(paData)

		for i = 1 to _nLen_
			_aTemp_ + [ ""+i, paData[i] ]
		next

		paData = _aTemp_
	ok

	# Forming the object container attributes from the hashlist
	_oHash_ = new stzHashList(paData)
	@anValues = _oHash_.Values()
	@acLabels = _oHash_.Keys()

	if NOT IsListOfPositiveNumbers(@anValues)
		raise("Incorrect param value! You must provide only positive numbers.")
	ok

	@nSum = Sum(@anValues)	
	_calculateSquaremap()

	def Sum(anNumbers)
		_nResult_ = 0
		_nAnNumbers1Len_ = len(anNumbers)
		for _iLoopAnNumbers1_ = 1 to _nAnNumbers1Len_
			_n_ = anNumbers[_iLoopAnNumbers1_]
			_nResult_ += _n_
		next
		return _nResult_

	def IsListOfNumbers(aList)
		_nList3Len_ = len(aList)
		for _iLoopList3_ = 1 to _nList3Len_
			_item_ = aList[_iLoopList3_]
			if NOT isNumber(_item_)
				return FALSE
			ok
		next
		return TRUE

	def IsListOfPositiveNumbers(aList)
		_nList2Len_ = len(aList)
		for _iLoopList2_ = 1 to _nList2Len_
			_item_ = aList[_iLoopList2_]
			if NOT (isNumber(_item_) and _item_ > 0)
				return FALSE
			ok
		next
		return TRUE

	def IsHashList(aList)
		if len(aList) = 0
			return FALSE
		ok
		_nList1Len_ = len(aList)
		for _iLoopList1_ = 1 to _nList1Len_
			_item_ = aList[_iLoopList1_]
			if NOT (isList(_item_) and len(_item_) = 2)
				return FALSE
			ok
		next
		return TRUE

	def AddPercent()
		@bShowPercent = TRUE
		return This

		def SetPercent(bShow)
			@bShowPercent = bShow
			return This

		def IncludePercent()
			@bShowPercent = TRUE
			return This

	def AddValues()
		@bShowValues = TRUE
		return This

		def SetValues(bShow)
			@bShowValues = bShow
			return This

		def IncludeValues()
			@bShowValues = TRUE
			return This

	def WithoutBorders()
		@bShowBorders = FALSE
		return This

	def SetBorders(bShow)
		@bShowBorders = bShow
		return This

	def WithoutLabels()
		@bShowLabels = FALSE
		return This

	def SetLabels(bShow)
		@bShowLabels = bShow
		return This

	def AddLegend()
		@bShowLegend = TRUE
		return This

	def SetLegend(bShow)
		@bShowLegend = bShow
		return This

	def IncludeLegend()
		@bShowLegend = TRUE
		return This

	def SetWidth(nWidth)
		if NOT isNumber(nWidth)
			raise("Incorrect param type! nWidth must be a number.")
		ok

		@nWidth = max([@nMinWidth, nWidth])

		if @nWidth > @nMaxWidth
			@nWidth = @nMaxWidth
		ok

		_calculateSquaremap()
		return This

	def SetHeight(nHeight)
		if NOT isNumber(nHeight)
			raise("Incorrect param type! nHeight must be a number.")
		ok

		@nHeight = max([@nMinHeight, nHeight])
		
		if @nHeight > @nMaxHeight
			@nHeight = @nMaxHeight
		ok

		_calculateSquaremap()
		return This

	def SetSize(nWidth, nHeight)
		if NOT (isNumber(nWidth) and isNumber(nHeight))
			raise("Incorrect param type! nWidth and nHeight must be both numbers.")
		ok

		@nWidth = max([@nMinWidth, nWidth])
		@nHeight = max([@nMinHeight, nHeight])

		if @nWidth > @nMaxWidth
			@nWidth = @nMaxWidth
		ok
		
		if @nHeight > @nMaxHeight
			@nHeight = @nMaxHeight
		ok

		_calculateSquaremap()
		return This

		def SetDimensions(nWidth, nHeight)
			return This.SetSize(nWidth, nHeight)

	def Show()
		? This.ToString()

	def ToString()
		_autoResize()  # Auto-resize based on content needs
		_calculateSquaremap()
		_initCanvas()
		
		if @bShowBorders
			_drawBorders()
			_connectBordersToOuter()
		ok
		
		_drawContent()
		
		return _finalizeCanvas()

	def _autoResize()
		# Calculate minimum size needed for labels
		_nMaxLabelLen_ = 0
		_nLen_ = len(@acLabels)
		for i = 1 to _nLen_
			_nLenLabel_ = StzLen(@acLabels[i])
			if _nLenLabel_ > _nMaxLabelLen_
				_nMaxLabelLen_ = _nLenLabel_
			ok
		next
		
		# Calculate minimum width needed
		_nMinNeededWidth_ = max([@nMinWidth, _nMaxLabelLen_ + 4])  # +4 for borders and spacing
		if @nWidth < _nMinNeededWidth_
			@nWidth = min([_nMinNeededWidth_, @nMaxWidth])
		ok
		
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
		for i = 1 to @nHeight
			for j = 1 to @nWidth
				_cResult_ += @acCanvas[i][j]
			next
			if i < @nHeight
				_cResult_ += nl
			ok
		next
		return _cResult_

	def _calculateSquaremap()
		@aRectangles = []
		_nValues_ = len(@anValues)
		
		if _nValues_ = 0
			return
		ok
		
		# Sort values by size (descending) for better layout
		_aSorted_ = []
		for i = 1 to _nValues_
			_aSorted_ + [@anValues[i], @acLabels[i], i]
		next
		
		# Simple bubble sort (descending)
		_nLenSorted_ = len(_aSorted_)
		for i = 1 to _nLenSorted_ - 1
			for j = i + 1 to _nLenSorted_
				if _aSorted_[i][1] < _aSorted_[j][1]
					_temp_ = _aSorted_[i]
					_aSorted_[i] = _aSorted_[j]
					_aSorted_[j] = _temp_
				ok
			next
		next
		
		# Calculate available area (excluding borders if shown)
		_nAvailWidth_ = @nWidth
		_nAvailHeight_ = @nHeight
		
		if @bShowBorders
			_nAvailWidth_ -= 2
			_nAvailHeight_ -= 2
		ok
		
		_nTotalArea_ = _nAvailWidth_ * _nAvailHeight_
		
		# Calculate rectangles using squarified treemap algorithm (simplified)
		_squarifyLayout(_aSorted_, 1, 1, _nAvailWidth_, _nAvailHeight_, _nTotalArea_)

	def _squarifyLayout(_aSorted_, _nH_, _nV_, nWidth, nHeight, _nTotalArea_)
		
		_nLen_ = len(_aSorted_)
		if _nLen_ = 0
			return
		ok
		
		if _nLen_ = 1
			# Single rectangle fills the space
			_nValue_ = _aSorted_[1][1]
			_cLabel_ = _aSorted_[1][2]
			_nIndex_ = _aSorted_[1][3]
			
			@aRectangles + [_nH_, _nV_, nWidth, nHeight, _nValue_, _cLabel_, _nIndex_]
			return
		ok
		
		# Improved treemap layout - better space utilization
		if _nLen_ <= 4
			# Small number of rectangles - create a 2x2 or similar grid
			_createGridLayout(_aSorted_, _nH_, _nV_, nWidth, nHeight)
		else
			# Larger number - use recursive division
			_recursiveDivision(_aSorted_, _nH_, _nV_, nWidth, nHeight)
		ok

	def _createGridLayout(_aSorted_, _nH_, _nV_, nWidth, nHeight)
		_nLen_ = len(_aSorted_)
		
		if _nLen_ = 2
			# Two rectangles - divide by larger dimension
			if nWidth > nHeight
				# Split horizontally
				_nValue1_ = _aSorted_[1][1]
				_nValue2_ = _aSorted_[2][1]
				_nTotal_ = _nValue1_ + _nValue2_
				_nWidth1_ = max([1, floor((_nValue1_ / _nTotal_) * nWidth)])
				_nWidth2_ = nWidth - _nWidth1_
				
				@aRectangles + [_nH_, _nV_, _nWidth1_, nHeight, _nValue1_, _aSorted_[1][2], _aSorted_[1][3]]
				@aRectangles + [_nH_ + _nWidth1_, _nV_, _nWidth2_, nHeight, _nValue2_, _aSorted_[2][2], _aSorted_[2][3]]
			else
				# Split vertically
				_nValue1_ = _aSorted_[1][1]
				_nValue2_ = _aSorted_[2][1]
				_nTotal_ = _nValue1_ + _nValue2_
				_nHeight1_ = max([1, floor((_nValue1_ / _nTotal_) * nHeight)])
				_nHeight2_ = nHeight - _nHeight1_
				
				@aRectangles + [_nH_, _nV_, nWidth, _nHeight1_, _nValue1_, _aSorted_[1][2], _aSorted_[1][3]]
				@aRectangles + [_nH_, _nV_ + _nHeight1_, nWidth, _nHeight2_, _nValue2_, _aSorted_[2][2], _aSorted_[2][3]]
			ok
			
		but _nLen_ = 3
			# Three rectangles - one large, two smaller
			_nLargest_ = _aSorted_[1][1]
			_nSecond_ = _aSorted_[2][1]
			_nThird_ = _aSorted_[3][1]
			_nTotal_ = _nLargest_ + _nSecond_ + _nThird_
			
			if nWidth > nHeight
				# Horizontal layout: largest left, two on right
				_nWidth1_ = max([1, floor((_nLargest_ / _nTotal_) * nWidth)])
				_nWidth2_ = nWidth - _nWidth1_
				
				# Largest rectangle on left
				@aRectangles + [_nH_, _nV_, _nWidth1_, nHeight, _nLargest_, _aSorted_[1][2], _aSorted_[1][3]]
				
				# Two smaller on right, split vertically
				_nSubTotal_ = _nSecond_ + _nThird_
				_nHeight1_ = max([1, floor((_nSecond_ / _nSubTotal_) * nHeight)])
				_nHeight2_ = nHeight - _nHeight1_
				
				@aRectangles + [_nH_ + _nWidth1_, _nV_, _nWidth2_, _nHeight1_, _nSecond_, _aSorted_[2][2], _aSorted_[2][3]]
				@aRectangles + [_nH_ + _nWidth1_, _nV_ + _nHeight1_, _nWidth2_, _nHeight2_, _nThird_, _aSorted_[3][2], _aSorted_[3][3]]
			else
				# Vertical layout: largest top, two below
				_nHeight1_ = max([1, floor((_nLargest_ / _nTotal_) * nHeight)])
				_nHeight2_ = nHeight - _nHeight1_
				
				# Largest rectangle on top
				@aRectangles + [_nH_, _nV_, nWidth, _nHeight1_, _nLargest_, _aSorted_[1][2], _aSorted_[1][3]]
				
				# Two smaller below, split horizontally
				_nSubTotal_ = _nSecond_ + _nThird_
				_nWidth1_ = max([1, floor((_nSecond_ / _nSubTotal_) * nWidth)])
				_nWidth2_ = nWidth - _nWidth1_
				
				@aRectangles + [_nH_, _nV_ + _nHeight1_, _nWidth1_, _nHeight2_, _nSecond_, _aSorted_[2][2], _aSorted_[2][3]]
				@aRectangles + [_nH_ + _nWidth1_, _nV_ + _nHeight1_, _nWidth2_, _nHeight2_, _nThird_, _aSorted_[3][2], _aSorted_[3][3]]
			ok
			
		else # nLen = 4
			# Four rectangles - 2x2 grid
			_nSum1_ = _aSorted_[1][1] + _aSorted_[2][1]
			_nSum2_ = _aSorted_[3][1] + _aSorted_[4][1]
			_nTotal_ = _nSum1_ + _nSum2_
			
			if nWidth >= nHeight
				# Split horizontally first
				_nWidth1_ = max([1, floor((_nSum1_ / _nTotal_) * nWidth)])
				_nWidth2_ = nWidth - _nWidth1_
				
				# Left column
				_nSubTotal1_ = _aSorted_[1][1] + _aSorted_[2][1]
				_nHeight1_ = max([1, floor((_aSorted_[1][1] / _nSubTotal1_) * nHeight)])
				_nHeight2_ = nHeight - _nHeight1_
				
				@aRectangles + [_nH_, _nV_, _nWidth1_, _nHeight1_, _aSorted_[1][1], _aSorted_[1][2], _aSorted_[1][3]]
				@aRectangles + [_nH_, _nV_ + _nHeight1_, _nWidth1_, _nHeight2_, _aSorted_[2][1], _aSorted_[2][2], _aSorted_[2][3]]
				
				# Right column
				_nSubTotal2_ = _aSorted_[3][1] + _aSorted_[4][1]
				_nHeight3_ = max([1, floor((_aSorted_[3][1] / _nSubTotal2_) * nHeight)])
				_nHeight4_ = nHeight - _nHeight3_
				
				@aRectangles + [_nH_ + _nWidth1_, _nV_, _nWidth2_, _nHeight3_, _aSorted_[3][1], _aSorted_[3][2], _aSorted_[3][3]]
				@aRectangles + [_nH_ + _nWidth1_, _nV_ + _nHeight3_, _nWidth2_, _nHeight4_, _aSorted_[4][1], _aSorted_[4][2], _aSorted_[4][3]]
			else
				# Split vertically first
				_nHeight1_ = max([1, floor((_nSum1_ / _nTotal_) * nHeight)])
				_nHeight2_ = nHeight - _nHeight1_
				
				# Top row
				_nSubTotal1_ = _aSorted_[1][1] + _aSorted_[2][1]
				_nWidth1_ = max([1, floor((_aSorted_[1][1] / _nSubTotal1_) * nWidth)])
				_nWidth2_ = nWidth - _nWidth1_
				
				@aRectangles + [_nH_, _nV_, _nWidth1_, _nHeight1_, _aSorted_[1][1], _aSorted_[1][2], _aSorted_[1][3]]
				@aRectangles + [_nH_ + _nWidth1_, _nV_, _nWidth2_, _nHeight1_, _aSorted_[2][1], _aSorted_[2][2], _aSorted_[2][3]]
				
				# Bottom row
				_nSubTotal2_ = _aSorted_[3][1] + _aSorted_[4][1]
				_nWidth3_ = max([1, floor((_aSorted_[3][1] / _nSubTotal2_) * nWidth)])
				_nWidth4_ = nWidth - _nWidth3_
				
				@aRectangles + [_nH_, _nV_ + _nHeight1_, _nWidth3_, _nHeight2_, _aSorted_[3][1], _aSorted_[3][2], _aSorted_[3][3]]
				@aRectangles + [_nH_ + _nWidth3_, _nV_ + _nHeight1_, _nWidth4_, _nHeight2_, _aSorted_[4][1], _aSorted_[4][2], _aSorted_[4][3]]
			ok
		ok

	def _recursiveDivision(_aSorted_, _nH_, _nV_, nWidth, nHeight)
		# For larger numbers, use simple recursive division
		_nLen_ = len(_aSorted_)
		_nMid_ = floor(_nLen_ / 2)
		
		# Calculate sum for first half
		_nSum1_ = 0
		for i = 1 to _nMid_
			_nSum1_ += _aSorted_[i][1]
		next
		
		# Calculate sum for second half
		_nSum2_ = 0
		for i = _nMid_ + 1 to _nLen_
			_nSum2_ += _aSorted_[i][1]
		next
		
		_nTotal_ = _nSum1_ + _nSum2_
		
		if nWidth >= nHeight
			# Divide horizontally
			_nWidth1_ = max([1, floor((_nSum1_ / _nTotal_) * nWidth)])
			_nWidth2_ = nWidth - _nWidth1_
			
			# First half
			_aFirst_ = []
			for i = 1 to _nMid_
				_aFirst_ + _aSorted_[i]
			next
			_squarifyLayout(_aFirst_, _nH_, _nV_, _nWidth1_, nHeight, _nWidth1_ * nHeight)
			
			# Second half
			_aSecond_ = []
			for i = _nMid_ + 1 to _nLen_
				_aSecond_ + _aSorted_[i]
			next
			_squarifyLayout(_aSecond_, _nH_ + _nWidth1_, _nV_, _nWidth2_, nHeight, _nWidth2_ * nHeight)
		else
			# Divide vertically
			_nHeight1_ = max([1, floor((_nSum1_ / _nTotal_) * nHeight)])
			_nHeight2_ = nHeight - _nHeight1_
			
			# First half
			_aFirst_ = []
			for i = 1 to _nMid_
				_aFirst_ + _aSorted_[i]
			next
			_squarifyLayout(_aFirst_, _nH_, _nV_, nWidth, _nHeight1_, nWidth * _nHeight1_)
			
			# Second half
			_aSecond_ = []
			for i = _nMid_ + 1 to _nLen_
				_aSecond_ + _aSorted_[i]
			next
			_squarifyLayout(_aSecond_, _nH_, _nV_ + _nHeight1_, nWidth, _nHeight2_, nWidth * _nHeight2_)
		ok

	def _drawBorders()
		
		# Draw outer border
		# Top border
		@acCanvas[1][1] = @cTopLeft
		@acCanvas[1][@nWidth] = @cTopRight
		for i = 2 to @nWidth - 1
			@acCanvas[1][i] = @cHorizontal
		next
		
		# Bottom border
		@acCanvas[@nHeight][1] = @cBottomLeft
		@acCanvas[@nHeight][@nWidth] = @cBottomRight
		for i = 2 to @nWidth - 1
			@acCanvas[@nHeight][i] = @cHorizontal
		next
		
		# Side borders
		for i = 2 to @nHeight - 1
			@acCanvas[i][1] = @cVertical
			@acCanvas[i][@nWidth] = @cVertical
		next
		
		# Draw internal borders between rectangles
		_drawInternalBorders()

	def _connectBordersToOuter()
	    # Check each position on outer border for connections
	    
	    # Top border connections
	    for j = 2 to @nWidth - 1
	        if @acCanvas[2][j] = @cVertical  # Internal border connects from below
	            @acCanvas[1][j] = @cTeeDown
	        ok
	    next
	    
	    # Bottom border connections  
	    for j = 2 to @nWidth - 1
	        if @acCanvas[@nHeight-1][j] = @cVertical  # Internal border connects from above
	            @acCanvas[@nHeight][j] = @cTeeUp
	        ok
	    next
	    
	    # Left border connections
	    for i = 2 to @nHeight - 1
	        if @acCanvas[i][2] = @cHorizontal  # Internal border connects from right
	            @acCanvas[i][1] = @cTeeRight
	        ok
	    next
	    
	    # Right border connections
	    for i = 2 to @nHeight - 1
	        if @acCanvas[i][@nWidth-1] = @cHorizontal  # Internal border connects from left
	            @acCanvas[i][@nWidth] = @cTeeLeft
	        ok
	    next

	def _drawInternalBorders()
	    
	    _nLen_ = len(@aRectangles)
	    
	    # First pass: draw all borders without intersections
	    for i = 1 to _nLen_
	        _aRect_ = @aRectangles[i]
	        _nH_ = _aRect_[1]
	        _nV_ = _aRect_[2] 
	        _nW_ = _aRect_[3]
	        _nHt_ = _aRect_[4]
	        
	        # Adjust for outer border offset
	        if @bShowBorders
	            _nH_++
	            _nV_++
	        ok
	        
	        # Draw right border if not at edge
	        if _nH_ + _nW_ < @nWidth
	            for j = _nV_ to _nV_ + _nHt_ - 1
	                if j >= 1 and j <= @nHeight
	                    if @acCanvas[j][_nH_ + _nW_] = " "
	                        @acCanvas[j][_nH_ + _nW_] = @cVertical
	                    ok
	                ok
	            next
	        ok
	        
	        # Draw bottom border if not at edge
	        if _nV_ + _nHt_ < @nHeight and _nV_ + _nHt_ > 1
	            for j = _nH_ to _nH_ + _nW_ - 1
	                if j >= 1 and j <= @nWidth
	                    if @acCanvas[_nV_ + _nHt_][j] = " "
	                        @acCanvas[_nV_ + _nHt_][j] = @cHorizontal
	                    ok
	                ok
	            next
	        ok
	    next
	    
	    # Second pass: fix all intersections
	    _fixBorderIntersections()

	def _fixBorderIntersections()
		
		for i = 1 to @nHeight
			for j = 1 to @nWidth
				
				_cCurrent_ = @acCanvas[i][j]
				
				# Only process positions that have border characters
				if _cCurrent_ = @cVertical or _cCurrent_ = @cHorizontal
				
					# Check all four directions for connections
					_bUp_ = FALSE
					_bDown_ = FALSE
					_bLeft_ = FALSE
					_bRight_ = FALSE
					
					# Check up
					if i > 1
						_cUp_ = @acCanvas[i-1][j]
						_bUp_ = (_cUp_ = @cVertical or _cUp_ = @cTeeDown or _cUp_ = @cTeeUp or _cUp_ = @cCross or _cUp_ = @cTeeLeft or _cUp_ = @cTeeRight)
					ok
					
					# Check down
					if i < @nHeight
						_cDown_ = @acCanvas[i+1][j]
						_bDown_ = (_cDown_ = @cVertical or _cDown_ = @cTeeDown or _cDown_ = @cTeeUp or _cDown_ = @cCross or _cDown_ = @cTeeLeft or _cDown_ = @cTeeRight)
					ok
					
					# Check left
					if j > 1
						_cLeft_ = @acCanvas[i][j-1]
						_bLeft_ = (_cLeft_ = @cHorizontal or _cLeft_ = @cTeeLeft or _cLeft_ = @cTeeRight or _cLeft_ = @cCross or _cLeft_ = @cTeeDown or _cLeft_ = @cTeeUp)
					ok
					
					# Check right
					if j < @nWidth
						_cRight_ = @acCanvas[i][j+1]
						_bRight_ = (_cRight_ = @cHorizontal or _cRight_ = @cTeeLeft or _cRight_ = @cTeeRight or _cRight_ = @cCross or _cRight_ = @cTeeDown or _cRight_ = @cTeeUp)
					ok
					
					# Determine proper intersection character
					_nConnections_ = 0
					if _bUp_: _nConnections_++ ok
					if _bDown_: _nConnections_++ ok
					if _bLeft_: _nConnections_++ ok
					if _bRight_: _nConnections_++ ok
					
					# Apply appropriate intersection character
					if _nConnections_ >= 2
						if _bUp_ and _bDown_ and _bLeft_ and _bRight_
							@acCanvas[i][j] = @cCross
						but _bUp_ and _bDown_ and _bRight_ and not _bLeft_
							@acCanvas[i][j] = @cTeeRight
						but _bUp_ and _bDown_ and _bLeft_ and not _bRight_
							@acCanvas[i][j] = @cTeeLeft
						but _bLeft_ and _bRight_ and _bDown_ and not _bUp_
							@acCanvas[i][j] = @cTeeDown
						but _bLeft_ and _bRight_ and _bUp_ and not _bDown_
							@acCanvas[i][j] = @cTeeUp
						but _bUp_ and _bRight_ and not _bDown_ and not _bLeft_
							@acCanvas[i][j] = @cBottomLeft
						but _bUp_ and _bLeft_ and not _bDown_ and not _bRight_
							@acCanvas[i][j] = @cBottomRight
						but _bDown_ and _bRight_ and not _bUp_ and not _bLeft_
							@acCanvas[i][j] = @cTopLeft
						but _bDown_ and _bLeft_ and not _bUp_ and not _bRight_
							@acCanvas[i][j] = @cTopRight
						ok
					ok
				ok
			next
		next

	def _truncateLabel(_cLabel_, nMaxWidth)
		if StzLen(_cLabel_) <= nMaxWidth
			return _cLabel_
		ok

		if nMaxWidth <= @nMinLabelWidth
			return StzLeft(_cLabel_, max([1, nMaxWidth - 1])) + "."
		ok

		return StzLeft(_cLabel_, nMaxWidth - 1) + "."

	def _drawContent()
	    
	    _nLen_ = len(@aRectangles)
	    
	    for i = 1 to _nLen_
	        _aRect_ = @aRectangles[i]
	        _nH_ = _aRect_[1]
	        _nV_ = _aRect_[2]
	        _nW_ = _aRect_[3]
	        _nHt_ = _aRect_[4]
	        _nValue_ = _aRect_[5]
	        _cLabel_ = Capitalise(_aRect_[6])
	        _nOrigIndex_ = _aRect_[7]
	        
	        # Adjust for border offset
	        if @bShowBorders
	            _nH_++
	            _nV_++
	        ok
	        
	        # Calculate usable content area (avoiding borders)
	        _nContentH_ = _nH_
	        _nContentV_ = _nV_
	        _nContentW_ = _nW_
	        _nContentHt_ = _nHt_

	        if @bShowBorders
	            # Shrink content area to avoid internal borders
	            if _nH_ + _nW_ < @nWidth
	                _nContentW_ -= 1  # Avoid right border
	            ok
	            if _nV_ + _nHt_ < @nHeight
	                _nContentHt_ -= 1  # Avoid bottom border
	            ok
	        ok

	        # Only proceed if we have reasonable space
	        if _nContentW_ < 3 or _nContentHt_ < 1
	            loop  # Skip this rectangle - too small for meaningful content
	        ok

	        # Build content lines
	        _aContentLines_ = []

	        # Prepare label and value content
	        _cMainContent_ = ""
	        _cSubContent_ = ""

	        if @bShowLabels and StzLen(_cLabel_) > 0
	            _cMainContent_ = _truncateLabel(_cLabel_, _nContentW_)
	        ok

	        # Build value/percent string
	        _cValueStr_ = ""
	        if @bShowValues
	            _cValueStr_ = ""+ RoundN(_nValue_, 1)
				_cValueStr_ = StzReplace(_cValueStr_, ".0", "")
	        ok

	        if @bShowPercent
	            _cPercentStr_ = ""+ RoundN((_nValue_ / @nSum) * 100, 1)
				_cPercentStr_ = StzReplace(_cPercentStr_, ".0", "")
	            _cPercentStr_ += "%"

	            if StzLen(_cValueStr_) > 0
	                _cSubContent_ = _cValueStr_ + " (" + _cPercentStr_ + ")"
	            else
	                _cSubContent_ = _cPercentStr_
	            ok
	        but StzLen(_cValueStr_) > 0
	            _cSubContent_ = _cValueStr_
	        ok

	        # Ensure sub-content fits
	        if StzLen(_cSubContent_) > _nContentW_
	            if _nContentW_ > 3
	                _cSubContent_ = StzLeft(_cSubContent_, _nContentW_ - 1) + "."
	            else
	                _cSubContent_ = StzLeft(_cSubContent_, _nContentW_)
	            ok
	        ok

	        # Determine layout - prioritize compact, clean display
	        _bShowMain_ = (StzLen(_cMainContent_) > 0 and StzLen(_cMainContent_) <= _nContentW_)
	        _bShowSub_ = (StzLen(_cSubContent_) > 0 and StzLen(_cSubContent_) <= _nContentW_)
	        
	        if _bShowMain_ and _bShowSub_
	            if _nContentHt_ >= 2
	                # Multi-line: label on top, value below
	                _aContentLines_ + _cMainContent_
	                _aContentLines_ + _cSubContent_
	            but _nContentW_ >= (StzLen(_cMainContent_) + StzLen(_cSubContent_) + 1)
	                # Single line if they fit together
	                _aContentLines_ + _cMainContent_ + " " + _cSubContent_
	            else
	                # Prioritize more important content
	                if @bShowPercent or @bShowValues
	                    _aContentLines_ + _cSubContent_  # Values/percentages more important in compact view
	                else
	                    _aContentLines_ + _cMainContent_
	                ok
	            ok
	        but _bShowMain_
	            _aContentLines_ + _cMainContent_
	        but _bShowSub_
	            _aContentLines_ + _cSubContent_
	        ok
	        
			# Draw content lines centered in available space
			_nLenLines_ = len(_aContentLines_)
	        if _nLenLines_ > 0
	            # Vertical centering
	            _nStartV_ = _nContentV_ + max([0, floor((_nContentHt_ - len(_aContentLines_)) / 2)])
	
	            for k = 1 to _nLenLines_
	                _cLine_ = _aContentLines_[k]
	                _nLineLen_ = StzLen(_cLine_)
	                _nCurrentV_ = _nStartV_ + k - 1
	
	                # Horizontal centering
	                _nCenterH_ = _nContentH_ + max([0, floor((_nContentW_ - _nLineLen_) / 2)])
	
	                # Draw the line
	                if _nCurrentV_ >= _nContentV_ and _nCurrentV_ < _nContentV_ + _nContentHt_ and _nCurrentV_ >= 1 and _nCurrentV_ <= @nHeight
	                    for j = 1 to _nLineLen_
	                        _nCol_ = _nCenterH_ + j - 1
	                        if _nCol_ >= _nContentH_ and _nCol_ < _nContentH_ + _nContentW_ and _nCol_ >= 1 and _nCol_ <= @nWidth
	                            if @acCanvas[_nCurrentV_][_nCol_] = " "
	                                @acCanvas[_nCurrentV_][_nCol_] = _cLine_[j]
	                            ok
	                        ok
	                    next
	                ok
	            next
	        ok
    	next
