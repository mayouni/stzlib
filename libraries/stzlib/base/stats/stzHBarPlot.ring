
class stzHBarChart from stzHBarPlot

# Draws a list of numbers, or labelled numbers, as horizontal bars with their labels at the left.
#
# It is stzBarPlot turned on its side: one row per bar, the longest bar as long as the width, the
# labels in a column at the left. It inherits the data, the value, percentage and character
# settings, ToSVG and ToPNG from stzBarPlot and overrides only the size and layout settings and
# ToString. The average line is not drawn in the text picture, SetBarHeight spaces the bars out
# instead of thickening them, and SetBarInterSpace and SetHeight change nothing; see their warnings.
# In the pixel pictures the label column has a fixed width, so a long label is clipped at the left
# edge. Gallery: doc/gallery/stzHBarPlot/ranked.png (six bars with values), seen right by stzlib-
# docs visual pass (a model reading the PNG), 2026-10-05, not a person; longlabels.png (long labels
# clipped at the left edge), seen wrong by the same pass; terminal.txt is the text picture, read as
# text and judged right.
#
#   receiver   o1 = new stzHBarPlot([ :Jan = 34, :Feb = 58, :Mar = 47 ])
#   example    ? @@( o1.Size() )
#              #--> [ 12, 18 ]
#              ? o1.PlotKind()
#              #--> hbar
#   see        stzBarPlot, stzMBarPlot
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

	# Returns the kind of plot, which the pixel output uses to lay its bars out sideways.
	#
	#   returns    the symbol :HBar, as the text "hbar"
	#   note       the vertical plot answers :VBar
	#   see        ToCanvasQ
	#@ aka  Override configuration methods for horizontal orientation
	def PlotKind()
		return :HBar

	# Sets how wide the longest bar may be and how tall the plot is asked to be; only the width changes the picture.
	#
	#   nWidth     The length of the longest bar in characters, raised to 20 when smaller
	#   nHeight    The height in rows, raised to 4 when smaller
	#   returns    nothing; the plot changes
	#   note       the plot is as tall as its bars need
	#   warning    The height is stored but the picture has one row per bar whatever it says
	#   see        Size, SetWidth, SetHeight
	def SetSize(nWidth, nHeight)
		@nWidth = max([20, nWidth])
		@nHeight = max([4, nHeight])

	# Returns the height and the width the plot is set to, in that order.
	#
	#   returns    a list of two numbers [ height, width ]
	#   note       the defaults are [ 12, 18 ]
	#   see        SizeHV, SizeVH, SetSize
	def Size()
		return [@nHeight, @nWidth]

		# Returns the width and the height the plot is set to, in that order.
		#
		#   returns    a list of two numbers [ width, height ]
		#   note       the defaults are [ 18, 12 ]
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

	# Sets how many rows each bar takes; the bar itself stays one row high and the extra rows are left blank under it.
	#
	#   nHeight    The rows given to each bar, raised to 1 when smaller
	#   returns    nothing; the plot changes
	#   note       the default is 1
	#   warning    The bar is not drawn thicker: SetBarHeight(2) spaces the bars out, and the Ring
	#              renderer ToStringInRing puts the blank rows after the last bar instead
	#   see        SetMaxHeight
	def SetBarHeight(nHeight)
		@nBarHeight = max([1, nHeight])

	# Stores the gap between two bars, which the horizontal picture never reads, so it changes nothing today.
	#
	#   n          The gap in rows, raised to 0 when negative
	#   returns    nothing; the value is only remembered
	#   note       use SetBarHeight to space the bars out
	#   warning    The engine renderer and the Ring renderer both ignore it for horizontal bars
	#   see        SetBarHeight
	def SetBarInterSpace(n)
		@nBarInterSpace = max([0, n])

		# Stores the gap between two bars, under another name, which changes nothing today.
		#
		#   n          The gap in rows, raised to 0 when negative
		#   returns    nothing; the value is only remembered
		#   warning    The horizontal picture never reads it
		#   see        SetBarInterSpace
		def SetBarSpace(n)
			This.SetBarInterSpace(n)

		# Stores the gap between two bars, in the other word order, which changes nothing today.
		#
		#   n          The gap in rows, raised to 0 when negative
		#   returns    nothing; the value is only remembered
		#   warning    The horizontal picture never reads it
		#   see        SetBarInterSpace
		def SetInterBarSpace(n)
			This.SetBarInterSpace(n)

	# Sets the length of the longest bar in characters; the other bars are drawn in proportion to it.
	#
	#   n          The length of the longest bar, raised to 10 when smaller
	#   returns    nothing; the plot changes
	#   note       the default is 18
	#   see        Width, SetSize
	def SetWidth(n)
		@nWidth = max([10, n])

	# Shows or hides the horizontal axis and the vertical axis, and shows the bar labels only while the vertical axis is shown.
	#
	#   bHShow     1 to show the horizontal axis at the bottom, 0 to hide it
	#   bVShow     1 to show the vertical axis and the labels, 0 to hide both
	#   returns    nothing; the plot changes
	#   note       with 0, 0 only the bars remain
	#   see        SetVAxisLabels, SetHAxis
	def SetHVAxis(bHShow, bVShow)
		@bShowHAxis = bHShow

		@bShowVAxis = bVShow
		@bShowAxisLabels = bVShow

	# Returns how long the longest bar is set to be, in characters.
	#
	#   returns    a number
	#   note       the default is 18
	#   see        SetWidth, SetSize
	def Width()
		return @nWidth

	# Stores a height that the horizontal picture never reads, so it changes nothing today.
	#
	#   n          The height in rows, raised to 4 when smaller
	#   returns    nothing; only Height answers differently
	#   note       Height() answers the number set here
	#   warning    The picture has one row per bar, plus the axis rows, whatever this says
	#   see        Height, SetBarHeight
	def SetHeight(n)  
		@nHeight = max([4, n])

	# Returns the height the plot is set to, which the picture does not use.
	#
	#   returns    a number
	#   note       the default is 12
	#   see        SetHeight, SetSize
	def Height()
		return @nHeight

	# Limits how many bars are drawn; the bars after the limit are left out without a message.
	#
	#   n          The most bars to draw, raised to 3 when smaller
	#   returns    nothing; the plot changes
	#   note       the default is 30
	#   warning    The omitted bars are lost silently, although the largest value still sets the
	#              scale
	#   see        MaxHeight, SetBarHeight
	def SetMaxHeight(n)
		@nMaxHeight = max([3, n])

	# Returns the most bars the plot draws.
	#
	#   returns    a number
	#   note       the default is 30
	#   see        SetMaxHeight
	def MaxHeight()
		return @nMaxHeight

	# Shows or hides the labels at the left of the bars.
	#
	#   bShow      1 to show the labels, 0 to hide them
	#   returns    nothing; the plot changes
	#   note       the vertical axis stays when the labels are hidden
	#   see        AddVAxisLabels, SetHVAxis
	def SetVAxisLabels(bShow)
		This.SetAxisLabels(bShow)

		# Shows or hides the labels at the left of the bars, although the name says Add.
		#
		#   bShow      1 to show the labels, 0 to hide them
		#   returns    nothing; the plot changes
		#   note       it takes a flag, so AddVAxisLabels(0) hides them
		#   see        SetVAxisLabels
		def AddVAxisLabels(bShow)
			This.SetAxisLabels(bShow)

		# Hides the labels at the left of the bars.
		#
		#   returns    nothing; the plot changes
		#   see        SetVAxisLabels
		def WithoutAxisLabels()
			This.SetAxisLabels(0)

		# Hides the labels at the left of the bars, under the V name.
		#
		#   returns    nothing; the plot changes
		#   see        WithoutAxisLabels
		def WithoutVAxisLabels()
			This.SetAxisLabels(0)

	# Returns the plot as text with one row of block characters per bar, the labels at the left and an arrowed axis below.
	#
	#   returns    a multi-line string
	#   note       the longest bar fills the width and a label longer than the room is cut and ended
	#              with two dots
	#   warning    Raises an error when the engine cannot render the plot
	#   see        Show, ToStringInRing, ToSVG
	# --- Horizontal Layout Calculation ---
	#@ aka  THE HORIZONTAL PICTURE, rendered by the engine.
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

	# Returns the horizontal text picture drawn by the Ring code the engine renderer was ported from.
	#
	#   returns    a multi-line string
	#   note       slower than ToString and kept for the parity guard
	#   warning    The two renderers differ once SetBarHeight is above 1
	#   see        ToString
	#@ aka  The Ring renderer this was ported from, kept so the guard can prove the two agree character for character.
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
