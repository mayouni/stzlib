
class stzHBarChart from stzHBarPlot

class stzHBarPlot from stzBarPlot

	# Data properties (inherited from stzBarChart)
	# @anValues = []
	# @acLabels = []
	# @acCanvas = []

	# Display options (inherited)
	# @bShowHAxis = True
	# @bShowVAxis = True
	# @bShowLabels = True
	# @bShowAxisLabels = True
	# @bShowAverage = False
	# @bShowValues = False
	# @bShowPercent = False

	# Horizontal-specific dimensions
	@nWidth = 18        # Default horizontal width for bars
	@nHeight = 12       # Height to accommodate multiple bars vertically
	@nBarHeight = 1     # Height of each horizontal bar
	@nMaxHeight = 30    # Maximum chart height  
	@nMaxLabelWidth = 12
	@nBarInterSpace = 0 # No space between bars - compact layout

	# Override characters for horizontal layout
	@cBarChar = char(226) + char(150) + char(135)
	@cTopChar = char(226) + char(150) + char(135)
	@cVAxisChar = char(226) + char(148) + char(130)
	@cHAxisChar = char(226) + char(148) + char(128)
	@cVArrowChar = "^"
	@cHArrowChar = ">"
	@cVArrowChar = char(226) + char(150) + char(178)
	@cHArrowChar = char(226) + char(150) + char(186)
	@cOriginChar = char(226) + char(149) + char(176)
	@cAverageChar = "|"
	@cLabelChar = "X"

	# Horizontal-specific layout constants
	@nHAxisHeight = 1
	@nAxisPadding = 1

	# Override configuration methods for horizontal orientation

	# The pixel backends (GR6) are inherited whole; only the ORIENTATION
	# differs, and saying so here is the entire override. Placed AFTER the
	# attribute block on purpose: in Ring, a class's attributes must all
	# precede its first method, and putting this at the top of the class
	# quietly turned every declaration below it into dead code.
	def PlotKind()
		return :HBar

	def SetSize(nWidth, nHeight)
		@nWidth = max([20, nWidth])
		@nHeight = max([4, nHeight])

	def Size()
		return [@nHeight, @nWidth]

		def SizeHV()
			return [@nWidth, @nHeight]

		def SizeVH()
			return [@nHeight, @nWidth]

	def SetBarHeight(nHeight)
		@nBarHeight = max([1, nHeight])

	def SetBarInterSpace(n)
		@nBarInterSpace = max([0, n])

		def SetBarSpace(n)
			This.SetBarInterSpace(n)

		def SetInterBarSpace(n)
			This.SetBarInterSpace(n)

	def SetWidth(n)
		@nWidth = max([10, n])

	def SetHVAxis(bHShow, bVShow)
		@bShowHAxis = bHShow

		@bShowVAxis = bVShow
		@bShowAxisLabels = bVShow

	def Width()
		return @nWidth

	def SetHeight(n)  
		@nHeight = max([4, n])

	def Height()
		return @nHeight

	def SetMaxHeight(n)
		@nMaxHeight = max([3, n])

	def MaxHeight()
		return @nMaxHeight

	def SetVAxisLabels(bShow)
		This.SetAxisLabels(bShow)

		def AddVAxisLabels(bShow)
			This.SetAxisLabels(bShow)

		def WithoutAxisLabels()
			This.SetAxisLabels(0)

		def WithoutVAxisLabels()
			This.SetAxisLabels(0)

	# --- Horizontal Layout Calculation ---

	# THE HORIZONTAL PICTURE, rendered by the engine.
	#
	# THIS OVERRIDE IS LOAD-BEARING. stzHBarPlot inherits from stzBarPlot, and when
	# the vertical ToString() moved to the engine this class silently inherited it --
	# so horizontal plots rendered as VERTICAL ones. Nothing errored: the examples
	# only check for errors and the subclass guard did not compare pictures, so a
	# wrong plot sailed through. A horizontal plot is not the vertical one transposed
	# -- different bar glyph, labels down the left, one row per bar, different axis
	# columns -- which is why this class overrode nearly every drawing routine in the
	# first place.
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
			@nWidth, @nBarHeight, @nMaxHeight, @nMaxLabelWidth,
			@nBarInterSpace, @nAxisPadding,
			iff(@bShowHAxis, 1, 0), iff(@bShowVAxis, 1, 0),
			iff(@bShowLabels, 1, 0), iff(@bShowAxisLabels, 1, 0),
			iff(@bShowValues, 1, 0), iff(@bShowPercent, 1, 0),
		# THE CHARACTERS THE CALLER CHOSE, as codepoints on the end of the options.
		# They were dropped when this renderer moved to the engine: SetBarChar and
		# its siblings went on setting an attribute nothing read any more, so they
		# silently did nothing. The Ring renderer below still honoured them, which
		# is how the parity guard would have caught it -- had any case set one.
			StzCharCode(@cBarChar),
			StzCharCode(@cHAxisChar), StzCharCode(@cVAxisChar)
		]

		_cOut_ = StzEnginePlotHBar(@anValues, _cLabels_, _aOpts_)
		if NOT isString(_cOut_) or _cOut_ = ""
			StzRaise("stzHBarPlot: the engine could not render this plot.")
		ok
		return _cOut_

	# The Ring renderer this was ported from, kept so the guard can prove the two
	# agree character for character.
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

	def _calculateLayout()
	    _nBars_ = len(@anValues)
	    
	    # Cap the number of bars to @nMaxHeight
	    _nBarsToShow_ = min([_nBars_, @nMaxHeight])  # e.g., 3 bars if @nMaxHeight = 3
	    _nBarsHeight_ = _nBarsToShow_ * @nBarHeight  # Total height for bars
	    
	    # Calculate maximum label width
	    _nMaxLabelWidth_ = 0
	    if @bShowLabels and @bShowAxisLabels
	        for i = 1 to _nBarsToShow_  # Only consider shown bars
	            if i <= len(@acLabels)
	                _nLabelWidth_ = min([len(@acLabels[i]), @nMaxLabelWidth])
	                _nMaxLabelWidth_ = max([_nMaxLabelWidth_, _nLabelWidth_])
	            ok
	        next
	    ok
	    
	    # Layout dimensions
	    _nCurrentCol_ = 1
	    
	    # Labels column
	    _nLabelsCol_ = 0
	    if @bShowLabels and @bShowAxisLabels and _nMaxLabelWidth_ > 0
	        _nLabelsCol_ = _nCurrentCol_
	        _nCurrentCol_ += _nMaxLabelWidth_ + @nAxisPadding
	    ok
	    
	    # Vertical axis column
	    _nVAxisCol_ = 0
	    if @bShowVAxis
	        _nVAxisCol_ = _nCurrentCol_
	        _nCurrentCol_ += 1 + @nAxisPadding
	    ok
	    
	    # Bars area
	    _nBarsStart_ = _nCurrentCol_
	    _nBarsEnd_ = _nCurrentCol_ + @nWidth - 1
	    _nCurrentCol_ = _nBarsEnd_ + 1
	    
	    # Values column
	    _nValuesCol_ = 0
	    if @bShowValues or @bShowPercent
	        _nValuesCol_ = _nCurrentCol_ + 1
	        _nMaxValueWidth_ = 0
	        for i = 1 to _nBarsToShow_
	            _nValue_ = @anValues[i]
	            if @bShowValues
	                _nValueWidth_ = len("" + _nValue_)
	            but @bShowPercent and @nSum > 0
	                _nPercent_ = (@anValues[i] * 100) / @nSum
	                _nValueWidth_ = len('' + RoundN(_nPercent_, 1) + "%")
	            ok
	            _nMaxValueWidth_ = max([_nMaxValueWidth_, _nValueWidth_])
	        next
	        _nCurrentCol_ += _nMaxValueWidth_ + 1
	    ok
	    
	    # Total width
	    _nTotalWidth_ = _nCurrentCol_ - 1
	    if @bShowAverage
	        _nTotalWidth_ = max([_nTotalWidth_, _nBarsEnd_ + 10])
	    ok
	    
	    # Row positions
	    _nCurrentRow_ = 1
	    if @bShowVAxis
	        _nCurrentRow_ = 2  # Arrow in row 1
	    ok
	    
	    # Bars area
	    _nBarsStartRow_ = _nCurrentRow_
	    _nBarsEndRow_ = _nCurrentRow_ + _nBarsHeight_ - 1
	    _nCurrentRow_ = _nBarsEndRow_ + 1
	    
	    # Horizontal axis row
	    _nHAxisRow_ = 0
	    if @bShowHAxis
	        _nHAxisRow_ = _nCurrentRow_
	        _nCurrentRow_ += 1
	    ok
	    
	    # Annotation row for average
	    _nAnnotationRow_ = 0
	    if @bShowAverage
	        _nAnnotationRow_ = _nCurrentRow_
	        _nCurrentRow_ += 1
	    ok
	    
	    _nTotalHeight_ = _nCurrentRow_ - 1
	    
	    return [
	        :total_width = _nTotalWidth_,
	        :total_height = _nTotalHeight_,
	        :bars_start = _nBarsStart_,
	        :bars_end = _nBarsEnd_,
	        :bars_start_row = _nBarsStartRow_,
	        :bars_end_row = _nBarsEndRow_,
	        :h_axis_row = _nHAxisRow_,
	        :labels_col = _nLabelsCol_,
	        :values_col = _nValuesCol_,
	        :v_axis_col = _nVAxisCol_,
	        :bars_height = _nBarsHeight_,
	        :max_label_width = _nMaxLabelWidth_,
	        :bars_to_show = _nBarsToShow_,
	        :annotation_row = _nAnnotationRow_
	    ]
	
	# --- Horizontal Drawing Methods ---

	def _drawVAxis(oLayout)
		if not @bShowVAxis or oLayout[:v_axis_col] = 0
			return
		ok
		
		_nCol_ = oLayout[:v_axis_col]
		_nStartRow_ = 2  # Start after arrow
		_nEndRow_ = iff(oLayout[:h_axis_row] > 0, oLayout[:h_axis_row], oLayout[:bars_end_row])
		
		# Draw arrow at top
		_setChar(1, _nCol_, @cVArrowChar)
		
		# Draw vertical line
		for i = _nStartRow_ to _nEndRow_
			_setChar(i, _nCol_, @cVAxisChar)
		next


	def _drawHAxis(oLayout)
	    if not @bShowHAxis or oLayout[:h_axis_row] = 0
	        return
	    ok
	    _nRow_ = oLayout[:h_axis_row]
	    _nStart_ = iff(@bShowVAxis, oLayout[:v_axis_col], oLayout[:bars_start])  # e.g., 3
	    _nEnd_ = oLayout[:total_width]     

	    if @bShowVAxis
	        _setChar(_nRow_, _nStart_, @cOriginChar)
	    else
			if @bShowHAxis
				 _setChar(_nRow_, _nStart_, @cHAxisChar)
			ok
		ok

	    for i = _nStart_ + 1 to _nEnd_ - 1
	        _setChar(_nRow_, i, @cHAxisChar)
	    next
	    _setChar(_nRow_, _nEnd_, @cHArrowChar)


	def _drawBars(oLayout)
	    _nBarsToShow_ = oLayout[:bars_to_show]
	    _nBarsStartRow_ = oLayout[:bars_start_row]
	    _nBarsStart_ = oLayout[:bars_start]
	    _nBarsWidth_ = oLayout[:bars_end] - oLayout[:bars_start] + 1
	    
	    _nCurrentRow_ = _nBarsStartRow_
	    
	    for i = 1 to _nBarsToShow_
	        _nValue_ = @anValues[i]
	        
	        _nBarWidth_ = 0
	        if @nMaxValue > 0 and _nValue_ > 0
	            _nBarWidth_ = max([1, ceil(_nBarsWidth_ * _nValue_ / @nMaxValue)])
	        ok
	        
	        for k = 1 to _nBarWidth_
	            _nCol_ = _nBarsStart_ + k - 1
	            _setChar(_nCurrentRow_, _nCol_, @cBarChar)
	        next
	        
	        _nCurrentRow_ += 1
	    next


	def _drawLabels(oLayout)
	    if not @bShowLabels or not @bShowAxisLabels or oLayout[:labels_col] = 0
	        return
	    ok
	    
	    _nBarsToShow_ = oLayout[:bars_to_show]
	    _nLabelsCol_ = oLayout[:labels_col]
	    _nCurrentRow_ = oLayout[:bars_start_row]
	    
	    for i = 1 to _nBarsToShow_
	        if i <= len(@acLabels)
	            _cLabel_ = @acLabels[i]
	            
	            if len(_cLabel_) > @nMaxLabelWidth
	                _cLabel_ = Left(_cLabel_, @nMaxLabelWidth - 2) + ".."
	            ok
	            
	            _nLabelStart_ = _nLabelsCol_ + oLayout[:max_label_width] - len(_cLabel_)
	            _nLen_ = len(_cLabel_)
	            for j = 1 to _nLen_
	                _setChar(_nCurrentRow_, _nLabelStart_ + j - 1, _cLabel_[j])
	            next
	        ok
	        _nCurrentRow_ += 1
	    next
	

	def _drawValues(oLayout)
	    if not (@bShowValues or @bShowPercent)
	        return
	    ok
	    
	    _nBarsToShow_ = oLayout[:bars_to_show]
	    _nBarsStart_ = oLayout[:bars_start]
	    _nBarsStartRow_ = oLayout[:bars_start_row]
	    _nBarsWidth_ = oLayout[:bars_end] - oLayout[:bars_start] + 1
	    
	    for i = 1 to _nBarsToShow_
	        _nValue_ = @anValues[i]
	        
	        _nBarWidth_ = 0
	        if @nMaxValue > 0 and _nValue_ > 0
	            _nBarWidth_ = max([1, ceil(_nBarsWidth_ * _nValue_ / @nMaxValue)])
	        ok
	        
	        _nValueStartCol_ = _nBarsStart_ + _nBarWidth_ + 1
	        
	        _cValue_ = ""
	        if @bShowValues
	            if IsInteger(_nValue_)
	                _cValue_ = "" + _nValue_
	            else
	                _cValue_ = "" + RoundN(_nValue_, 1)
	            ok
	        but @bShowPercent and @nSum > 0
	            _nPercent_ = RoundN((_nValue_ * 100) / @nSum, 1)
	            _cValue_ = "" + _nPercent_ + "%"
				_cValue_ = StzReplace(_cValue_, ".0%", "%")
	        ok
	        
	        _nRow_ = _nBarsStartRow_ + (i - 1)
	        _nLen_ = len(_cValue_)
	        for j = 1 to _nLen_
	            _setChar(_nRow_, _nValueStartCol_ + j - 1, _cValue_[j])
	        next
	    next


	def _drawAverage(oLayout)
	    if not @bShowAverage
	        return
	    ok
	    
	    _nBarsToShow_ = oLayout[:bars_to_show]
	    _nBarsStart_ = oLayout[:bars_start]
	    _nBarsWidth_ = oLayout[:bars_end] - oLayout[:bars_start] + 1
	    _nBarsStartRow_ = oLayout[:bars_start_row]
	    _nBarsEndRow_ = _nBarsStartRow_ + _nBarsToShow_ - 1
	    
	    _nAvgCol_ = _nBarsStart_
	    if @nMaxValue > 0
	        _nAvgWidth_ = ceil(_nBarsWidth_ * @nAverage / @nMaxValue)
	        _nAvgCol_ = _nBarsStart_ + _nAvgWidth_ - 1
	    ok
	    
	    for i = _nBarsStartRow_ to _nBarsEndRow_
	        if @acCanvas[i][_nAvgCol_] = " "
	            _setChar(i, _nAvgCol_, "|")
	        ok
	    next
	    
	    if oLayout[:annotation_row] > 0
	        _cAvgValue_ = "avg: " + RoundN(@nAverage, 1)
	        _nAvgValueStartCol_ = _nAvgCol_ + 2
	        _nLen_ = len(_cAvgValue_)
	        for j = 1 to _nLen_
	            _setChar(oLayout[:annotation_row], _nAvgValueStartCol_ + j - 1, _cAvgValue_[j])
	        next
	    ok
