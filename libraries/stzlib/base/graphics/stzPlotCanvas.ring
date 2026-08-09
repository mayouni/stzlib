#---------------------------------------------------------------------------#
#  STZPLOTCANVAS -- the convergence: a plot's data, drawn as PIXELS.        #
#---------------------------------------------------------------------------#
#
# The library has always been able to plot -- into a codepoint canvas, for
# a terminal. This renders the SAME PLOT MODEL (the values, the labels, and
# the semantic options: show the values? mark the average?) onto an
# stzCanvas, which then answers ToSVG() with no GPU and ToPNG() through one.
#
#     oPlot = StzPlotQ(:VBar, [ 12, 30, 21, 44 ])
#     oPlot.Show()                          # the terminal picture, as ever
#     oPlot.ToPNG("sales.png", [ :Font = oFont ])
#     oPlot.ToSVG([ :Font = oFont ])
#
# or directly, for data that is not wearing a plot object yet:
#
#     oC = StzPlotCanvasQ(:VBar, aValues, aLabels, [ :Font = oFont ])
#
# WHY THIS IS NOT DUPLICATION of the terminal renderer: the two share the
# MODEL, not the layout. A character grid and a pixel canvas do not have a
# common layout to share -- tick spacing in rows is not tick spacing in
# pixels, and a bar 3 characters wide is not a bar 34 pixels wide. What
# must never diverge is the MEANING (which values, which labels, whether
# the average is marked), and that is read from the plot object, once.
#
# Options, all optional: [ :Width, :Height, :Title, :Font, :Color,
#   :Background, :Grid, :ShowValues, :ShowAverage, :Min, :Max ]
# Kinds: :VBar  :HBar  :Line  :Scatter
#
# Text needs a font: pass :Font = an stzFont. Without one the plot still
# draws -- bars, axes, gridlines -- and simply carries no labels, which is
# a legible chart rather than a refusal.

func StzPlotCanvasQ(pcKind, paValues, paLabels, paOptions)
	return _StzPlotRender(pcKind, paValues, paLabels, paOptions)

func _StzPlotOpt(paOptions, pcName, pDefault)
	if NOT isList(paOptions)
		return pDefault
	ok
	_v_ = _BindingValue(paOptions, lower(pcName))
	if isNull(_v_)
		return pDefault
	ok
	return _v_

# A short, human number for an axis tick: no trailing ".0" on integers.
func _StzPlotNum(pnV)
	if pnV = floor(pnV)
		return "" + floor(pnV)
	ok
	return "" + (floor(pnV * 100 + 0.5) / 100)

func _StzPlotRender(pcKind, paValues, paLabels, paOptions)
	_cKind_ = lower("" + pcKind)
	if NOT isList(paValues) or len(paValues) = 0
		StzRaise("stzPlotCanvas: there are no values to plot.")
	ok

	_nW_    = _StzPlotOpt(paOptions, "width", 900)
	_nH_    = _StzPlotOpt(paOptions, "height", 500)
	_cTitle_= _StzPlotOpt(paOptions, "title", "")
	_oFont_ = _StzPlotOpt(paOptions, "font", NULL)
	_cCol_  = _StzPlotOpt(paOptions, "color", "#5a9ee6")
	_cBg_   = _StzPlotOpt(paOptions, "background", "#0e1016")
	_bGrid_ = _StzPlotOpt(paOptions, "grid", TRUE)
	_bVals_ = _StzPlotOpt(paOptions, "showvalues", TRUE)
	_bAvg_  = _StzPlotOpt(paOptions, "showaverage", FALSE)

	_cInk_   = "#e6ebf5"
	_cMuted_ = "#8592ac"
	_cGrid_  = "#2b3242"
	_cAxis_  = "#5c6880"

	_oCanvas_ = new stzCanvas(_nW_, _nH_)
	_oCanvas_.SetBackground(_cBg_)

	# --- the numbers this plot spans
	_aFlat_ = _StzPlotFlatten(_cKind_, paValues)
	# A multi-series plot can arrive with series that carry no values at
	# all: the outer list is not empty, so the earlier check passes, and
	# the scale then has nothing to be computed from. Same refusal as an
	# empty plot, because it IS one.
	if len(_aFlat_) = 0
		StzRaise("stzPlotCanvas: there are no values to plot -- the data " +
			"has rows, but none of them carry numbers.")
	ok
	_nMin_ = _StzPlotOpt(paOptions, "min", NULL)
	_nMax_ = _StzPlotOpt(paOptions, "max", NULL)
	if isNull(_nMax_)  _nMax_ = _StzPlotMax(_aFlat_)  ok
	if isNull(_nMin_)
		_nMin_ = _StzPlotMin(_aFlat_)
		if _nMin_ > 0  _nMin_ = 0  ok      # bars are read from zero
	ok
	if _nMax_ = _nMin_  _nMax_ = _nMin_ + 1  ok
	# Round the top of the scale to a NICE number, so the ticks read 0/20/
	# 40/60/80 rather than 0/17.6/35.2/52.8. An axis a reader has to decode
	# is an axis that failed.
	if isNull(_StzPlotOpt(paOptions, "max", NULL))
		_nMax_ = _StzPlotNiceTop(_nMax_, 5)
	ok

	# --- the frame
	_nL_ = 78   _nR_ = _nW_ - 34
	_nT_ = 40   _nB_ = _nH_ - 62
	if _cTitle_ != ""  _nT_ = 84  ok
	if _cKind_ = "hbar"  _nL_ = 132  ok

	if _cTitle_ != "" and isObject(_oFont_)
		_oCanvas_.SetFont(_oFont_, 27)
		_oCanvas_.AddTextQ(_cTitle_, _nL_ - 8, 50).ColorQ(_cInk_)
	ok

	# --- a treemap has no axes to draw: it IS its own frame
	if _cKind_ = "treemap"
		_StzPlotTreemap(_oCanvas_, paValues, paLabels, _oFont_, _cInk_,
			_nL_, _nR_, _nT_, _nB_, _bVals_)
		return _oCanvas_
	ok

	# --- gridlines and their tick labels
	_nTicks_ = 5
	for _i_ = 0 to _nTicks_
		_nV_ = _nMin_ + (_nMax_ - _nMin_) * _i_ / _nTicks_
		if _cKind_ = "hbar"
			_nX_ = _nL_ + (_nR_ - _nL_) * _i_ / _nTicks_
			if _bGrid_
				_oCanvas_.AddRectQ(_nX_, _nT_, 1, _nB_ - _nT_).FillQ(_cGrid_)
			ok
			if isObject(_oFont_)
				_oCanvas_.SetFont(_oFont_, 14)
				_cT_ = _StzPlotNum(_nV_)
				_oCanvas_.AddTextQ(_cT_, _nX_ - _oFont_.WidthOf(_cT_, 14) / 2, _nB_ + 22).
				   ColorQ(_cMuted_)
			ok
		else
			_nY_ = _nB_ - (_nB_ - _nT_) * _i_ / _nTicks_
			if _bGrid_
				_oCanvas_.AddRectQ(_nL_, _nY_, _nR_ - _nL_, 1).FillQ(_cGrid_)
			ok
			if isObject(_oFont_)
				_oCanvas_.SetFont(_oFont_, 14)
				_cT_ = _StzPlotNum(_nV_)
				_oCanvas_.AddTextQ(_cT_, _nL_ - 12 - _oFont_.WidthOf(_cT_, 14), _nY_ + 5).
				   ColorQ(_cMuted_)
			ok
		ok
	next

	# --- the data
	switch _cKind_
	on "vbar"
		_StzPlotVBars(_oCanvas_, paValues, paLabels, _oFont_, _cCol_, _cInk_, _cMuted_,
			_nL_, _nR_, _nT_, _nB_, _nMin_, _nMax_, _bVals_)
	on "hbar"
		_StzPlotHBars(_oCanvas_, paValues, paLabels, _oFont_, _cCol_, _cInk_, _cMuted_,
			_nL_, _nR_, _nT_, _nB_, _nMin_, _nMax_, _bVals_)
	on "histogram"
		# a histogram's bars TOUCH: the bins are contiguous, and a gap
		# between them would draw a distribution that is not there
		_StzPlotBins(_oCanvas_, paValues, paLabels, _oFont_, _cCol_, _cInk_,
			_cMuted_, _nL_, _nR_, _nT_, _nB_, _nMin_, _nMax_, _bVals_)
	on "multibar"
		_StzPlotMulti(_oCanvas_, paValues, paLabels, _oFont_, _cInk_, _cMuted_,
			_nL_, _nR_, _nT_, _nB_, _nMin_, _nMax_)
	on "line"
		_StzPlotLine(_oCanvas_, paValues, _cCol_, _nL_, _nR_, _nT_, _nB_, _nMin_, _nMax_, TRUE)
	on "scatter"
		_StzPlotLine(_oCanvas_, paValues, _cCol_, _nL_, _nR_, _nT_, _nB_, _nMin_, _nMax_, FALSE)
	other
		StzRaise("stzPlotCanvas: unknown kind '" + _cKind_ + "' -- use " +
			":VBar, :HBar, :Histogram, :MultiBar, :Line, :Scatter or :Treemap.")
	off

	# --- the average, marked where the model asked for it
	if _bAvg_
		_nAvg_ = 0
		_nNf_ = len(_aFlat_)
		for _i_ = 1 to _nNf_  _nAvg_ += _aFlat_[_i_]  next
		_nAvg_ = _nAvg_ / _nNf_
		if _cKind_ = "hbar"
			_nX_ = _nL_ + (_nR_ - _nL_) * (_nAvg_ - _nMin_) / (_nMax_ - _nMin_)
			_oCanvas_.AddRectQ(_nX_, _nT_, 2, _nB_ - _nT_).FillQ("#e0a030")
		else
			_nY_ = _nB_ - (_nB_ - _nT_) * (_nAvg_ - _nMin_) / (_nMax_ - _nMin_)
			_oCanvas_.AddRectQ(_nL_, _nY_, _nR_ - _nL_, 2).FillQ("#e0a030")
		ok
		if isObject(_oFont_)
			# INSIDE the frame: at _nR_ the label ran off the canvas, which
			# is the kind of thing only a rendered picture shows you
			_oCanvas_.SetFont(_oFont_, 13)
			_cAvgT_ = "avg " + _StzPlotNum(_nAvg_)
			if _cKind_ = "hbar"
				_oCanvas_.AddTextQ(_cAvgT_, _nX_ + 6, _nT_ + 14).ColorQ("#e0a030")
			else
				_oCanvas_.AddTextQ(_cAvgT_,
					_nR_ - _oFont_.WidthOf(_cAvgT_, 13) - 6, _nY_ - 7).
					ColorQ("#e0a030")
			ok
		ok
	ok

	# --- the axes, drawn last so nothing covers them
	_oCanvas_.AddRectQ(_nL_, _nT_, 2, _nB_ - _nT_ + 2).FillQ(_cAxis_)
	_oCanvas_.AddRectQ(_nL_, _nB_, _nR_ - _nL_, 2).FillQ(_cAxis_)
	return _oCanvas_

# Raise a maximum to the next multiple of a "nice" step (1, 2, 2.5 or 5
# times a power of ten) so that nTicks divisions land on readable numbers.
func _StzPlotNiceTop(pnMax, pnTicks)
	if pnMax <= 0  return pnMax  ok
	_nRaw_ = pnMax / pnTicks
	_nMag_ = pow(10, floor(log10(_nRaw_)))
	_nNorm_ = _nRaw_ / _nMag_
	if _nNorm_ <= 1
		_nStep_ = 1 * _nMag_
	but _nNorm_ <= 2
		_nStep_ = 2 * _nMag_
	but _nNorm_ <= 2.5
		_nStep_ = 2.5 * _nMag_
	but _nNorm_ <= 5
		_nStep_ = 5 * _nMag_
	else
		_nStep_ = 10 * _nMag_
	ok
	return ceil(pnMax / _nStep_) * _nStep_

func _StzPlotFlatten(pcKind, paValues)
	_a_ = []
	_nL_ = len(paValues)
	# a multi-bar's values arrive as [ seriesName, [v1, v2, ...] ] rows, so
	# the scale must span every series, not the first one
	if pcKind = "multibar"
		for _i_ = 1 to _nL_
			if isList(paValues[_i_]) and len(paValues[_i_]) >= 2 and isList(paValues[_i_][2])
				_aV_ = paValues[_i_][2]
				for _j_ = 1 to len(_aV_)
					_a_ + _aV_[_j_]
				next
			ok
		next
		return _a_
	ok
	for _i_ = 1 to _nL_
		if isList(paValues[_i_])
			if len(paValues[_i_]) >= 2
				_a_ + paValues[_i_][2]
			ok
		else
			_a_ + paValues[_i_]
		ok
	next
	return _a_

# A small, distinguishable series palette. Kept here rather than asked of
# the caller so a multi-series chart is legible by default.
func _StzPlotSeriesColor(pnIndex)
	_a_ = [ "#5a9ee6", "#e0a030", "#68c8a0", "#c878d0", "#e07070",
	        "#7ad8c8", "#b0a0e0", "#d8b060" ]
	return _a_[ ((pnIndex - 1) % len(_a_)) + 1 ]

func _StzPlotMax(paV)
	_m_ = paV[1]
	_nL_ = len(paV)
	for _i_ = 2 to _nL_
		if paV[_i_] > _m_  _m_ = paV[_i_]  ok
	next
	return _m_

func _StzPlotMin(paV)
	_m_ = paV[1]
	_nL_ = len(paV)
	for _i_ = 2 to _nL_
		if paV[_i_] < _m_  _m_ = paV[_i_]  ok
	next
	return _m_

# NOTE: a function SIGNATURE must sit on ONE line -- Ring's parser does not
# continue it, and splitting one here made stzBase.ring die at load with no
# message at all.
func _StzPlotVBars(_oCanvas_, paValues, paLabels, oFont, cCol, cInk, cMuted, nL, nR, nT, nB, nMin, nMax, bVals)
	_nN_ = len(paValues)
	_nSlot_ = (nR - nL) / _nN_
	_nBW_ = _nSlot_ * 0.62
	for _i_ = 1 to _nN_
		_nV_ = paValues[_i_]
		_nHt_ = (nB - nT) * (_nV_ - nMin) / (nMax - nMin)
		_nX_ = nL + (_i_ - 1) * _nSlot_ + (_nSlot_ - _nBW_) / 2
		_nY_ = nB - _nHt_
		if _nHt_ > 0
			_oCanvas_.AddGradientRectQ(_nX_, _nY_, _nBW_, _nHt_, cCol, "#9a5ad0", TRUE)
		ok
		if isObject(oFont)
			if bVals
				_oCanvas_.SetFont(oFont, 14)
				_cT_ = _StzPlotNum(_nV_)
				_oCanvas_.AddTextQ(_cT_, _nX_ + (_nBW_ - oFont.WidthOf(_cT_, 14)) / 2,
					_nY_ - 9).ColorQ(cInk)
			ok
			if isList(paLabels) and len(paLabels) >= _i_
				_oCanvas_.SetFont(oFont, 15)
				_cLb_ = "" + paLabels[_i_]
				_oCanvas_.AddTextQ(_cLb_, _nX_ + (_nBW_ - oFont.WidthOf(_cLb_, 15)) / 2,
					nB + 26).ColorQ(cMuted)
			ok
		ok
	next

func _StzPlotHBars(_oCanvas_, paValues, paLabels, oFont, cCol, cInk, cMuted, nL, nR, nT, nB, nMin, nMax, bVals)
	_nN_ = len(paValues)
	_nSlot_ = (nB - nT) / _nN_
	_nBH_ = _nSlot_ * 0.62
	for _i_ = 1 to _nN_
		_nV_ = paValues[_i_]
		_nWd_ = (nR - nL) * (_nV_ - nMin) / (nMax - nMin)
		_nY_ = nT + (_i_ - 1) * _nSlot_ + (_nSlot_ - _nBH_) / 2
		if _nWd_ > 0
			_oCanvas_.AddGradientRectQ(nL, _nY_, _nWd_, _nBH_, cCol, "#9a5ad0", FALSE)
		ok
		if isObject(oFont)
			if bVals
				_oCanvas_.SetFont(oFont, 14)
				_oCanvas_.AddTextQ(_StzPlotNum(_nV_), nL + _nWd_ + 8,
					_nY_ + _nBH_ / 2 + 5).ColorQ(cInk)
			ok
			if isList(paLabels) and len(paLabels) >= _i_
				_oCanvas_.SetFont(oFont, 15)
				_cLb_ = "" + paLabels[_i_]
				_oCanvas_.AddTextQ(_cLb_, nL - 12 - oFont.WidthOf(_cLb_, 15),
					_nY_ + _nBH_ / 2 + 5).ColorQ(cMuted)
			ok
		ok
	next

# A histogram: contiguous bins, so the bars touch. Only every other bin
# label is drawn when they would collide -- a row of overlapping labels
# tells a reader less than a sparse one.
func _StzPlotBins(oC, paValues, paLabels, oFont, cCol, cInk, cMuted, nL, nR, nT, nB, nMin, nMax, bVals)
	_nN_ = len(paValues)
	_nBW_ = (nR - nL) / _nN_
	_nEvery_ = 1
	if isObject(oFont) and isList(paLabels) and len(paLabels) >= _nN_
		_nWide_ = 0
		for _i_ = 1 to _nN_
			_nWi_ = oFont.WidthOf("" + paLabels[_i_], 13)
			if _nWi_ > _nWide_  _nWide_ = _nWi_  ok
		next
		if _nWide_ + 6 > _nBW_
			_nEvery_ = ceil((_nWide_ + 6) / _nBW_)
		ok
	ok
	for _i_ = 1 to _nN_
		_nV_ = paValues[_i_]
		_nHt_ = (nB - nT) * (_nV_ - nMin) / (nMax - nMin)
		_nX_ = nL + (_i_ - 1) * _nBW_
		_nY_ = nB - _nHt_
		if _nHt_ > 0
			# a 1px inset keeps the bins visually separable without lying
			# about them being adjacent
			oC.AddRectQ(_nX_ + 1, _nY_, _nBW_ - 1, _nHt_).FillQ(cCol)
		ok
		if isObject(oFont)
			if bVals and _nV_ > 0
				oC.SetFont(oFont, 12)
				_cT_ = _StzPlotNum(_nV_)
				oC.AddTextQ(_cT_, _nX_ + (_nBW_ - oFont.WidthOf(_cT_, 12)) / 2,
					_nY_ - 6).ColorQ(cInk)
			ok
			if isList(paLabels) and len(paLabels) >= _i_ and (_i_ - 1) % _nEvery_ = 0
				oC.SetFont(oFont, 13)
				_cLb_ = "" + paLabels[_i_]
				oC.AddTextQ(_cLb_, _nX_ + (_nBW_ - oFont.WidthOf(_cLb_, 13)) / 2,
					nB + 24).ColorQ(cMuted)
			ok
		ok
	next

# Grouped bars: one cluster per category, one bar per series, plus the
# legend without which a multi-series chart cannot be read.
func _StzPlotMulti(oC, paSeries, paCategories, oFont, cInk, cMuted, nL, nR, nT, nB, nMin, nMax)
	_nS_ = len(paSeries)
	if _nS_ = 0  return  ok
	_nCat_ = 0
	for _i_ = 1 to _nS_
		if isList(paSeries[_i_]) and len(paSeries[_i_]) >= 2 and isList(paSeries[_i_][2])
			if len(paSeries[_i_][2]) > _nCat_  _nCat_ = len(paSeries[_i_][2])  ok
		ok
	next
	if _nCat_ = 0  return  ok

	_nSlot_ = (nR - nL) / _nCat_
	_nGroupW_ = _nSlot_ * 0.74
	_nBarW_ = _nGroupW_ / _nS_
	for _c_ = 1 to _nCat_
		_nGx_ = nL + (_c_ - 1) * _nSlot_ + (_nSlot_ - _nGroupW_) / 2
		for _s_ = 1 to _nS_
			_aV_ = paSeries[_s_][2]
			if len(_aV_) < _c_  loop  ok
			_nV_ = _aV_[_c_]
			_nHt_ = (nB - nT) * (_nV_ - nMin) / (nMax - nMin)
			if _nHt_ <= 0  loop  ok
			oC.AddRectQ(_nGx_ + (_s_ - 1) * _nBarW_, nB - _nHt_,
				_nBarW_ - 1, _nHt_).FillQ(_StzPlotSeriesColor(_s_))
		next
		if isObject(oFont) and isList(paCategories) and len(paCategories) >= _c_
			oC.SetFont(oFont, 14)
			_cLb_ = "" + paCategories[_c_]
			oC.AddTextQ(_cLb_, _nGx_ + (_nGroupW_ - oFont.WidthOf(_cLb_, 14)) / 2,
				nB + 24).ColorQ(cMuted)
		ok
	next

	# the legend, top-right inside the frame
	if isObject(oFont)
		_nLy_ = nT + 6
		for _s_ = 1 to _nS_
			_cNm_ = "" + paSeries[_s_][1]
			oC.SetFont(oFont, 13)
			_nTw_ = oFont.WidthOf(_cNm_, 13)
			_nLx_ = nR - _nTw_ - 20
			oC.AddRectQ(_nLx_, _nLy_ - 9, 12, 12).FillQ(_StzPlotSeriesColor(_s_))
			oC.AddTextQ(_cNm_, _nLx_ + 18, _nLy_ + 1).ColorQ(cInk)
			_nLy_ += 20
		next
	ok

# A treemap: area is the value, so the picture IS the composition.
# Slice-and-dice with an alternating split direction -- areas are exact,
# and for the handful of parts a composition chart carries the aspect
# ratios stay readable. (Squarified packing is the upgrade if a caller
# ever brings dozens of slices.)
func _StzPlotTreemap(oC, paValues, paLabels, oFont, cInk, nL, nR, nT, nB, bVals)
	_nN_ = len(paValues)
	_nTotal_ = 0
	for _i_ = 1 to _nN_  _nTotal_ += paValues[_i_]  next
	if _nTotal_ <= 0
		StzRaise("stzPlotCanvas: a treemap needs values that sum above zero.")
	ok
	_nX_ = nL   _nY_ = nT
	_nW_ = nR - nL   _nH_ = nB - nT
	_nRem_ = _nTotal_
	for _i_ = 1 to _nN_
		_nV_ = paValues[_i_]
		if _i_ = _nN_
			_nRw_ = _nW_   _nRh_ = _nH_        # the last slice takes the rest
		but _nW_ >= _nH_
			_nRw_ = _nW_ * _nV_ / _nRem_   _nRh_ = _nH_
		else
			_nRw_ = _nW_   _nRh_ = _nH_ * _nV_ / _nRem_
		ok
		oC.AddRectQ(_nX_, _nY_, _nRw_ - 2, _nRh_ - 2).
		   FillQ(_StzPlotSeriesColor(_i_))
		if isObject(oFont) and _nRw_ > 46 and _nRh_ > 26
			oC.SetFont(oFont, 15)
			_cLb_ = "" + _i_
			if isList(paLabels) and len(paLabels) >= _i_
				_cLb_ = "" + paLabels[_i_]
			ok
			if bVals
				_cLb_ += "  " + _StzPlotNum(100 * _nV_ / _nTotal_) + "%"
			ok
			_cLb_ = _StzTreeFit(_cLb_, oFont, 15, _nRw_ - 16)
			oC.AddTextQ(_cLb_, _nX_ + 10, _nY_ + 24).ColorQ("#12161f")
		ok
		if _nW_ >= _nH_ and _i_ < _nN_
			_nX_ += _nRw_   _nW_ -= _nRw_
		but _i_ < _nN_
			_nY_ += _nRh_   _nH_ -= _nRh_
		ok
		_nRem_ -= _nV_
	next

# Points as [x, y] pairs, or bare values taken as y against their index.
# bLine draws the connecting polyline as well as the points.
func _StzPlotLine(_oCanvas_, paValues, cCol, nL, nR, nT, nB, nMin, nMax, bLine)
	_nN_ = len(paValues)
	_aXs_ = []
	_aYs_ = []
	_nXMin_ = 0
	_nXMax_ = _nN_ - 1
	if _nN_ > 0 and isList(paValues[1]) and len(paValues[1]) >= 2
		_aTmp_ = []
		for _i_ = 1 to _nN_  _aTmp_ + paValues[_i_][1]  next
		_nXMin_ = _StzPlotMin(_aTmp_)
		_nXMax_ = _StzPlotMax(_aTmp_)
		if _nXMax_ = _nXMin_  _nXMax_ = _nXMin_ + 1  ok
	ok
	for _i_ = 1 to _nN_
		if isList(paValues[_i_])
			_nXv_ = paValues[_i_][1]
			_nYv_ = paValues[_i_][2]
		else
			_nXv_ = _i_ - 1
			_nYv_ = paValues[_i_]
		ok
		_aXs_ + (nL + (nR - nL) * (_nXv_ - _nXMin_) / (_nXMax_ - _nXMin_))
		_aYs_ + (nB - (nB - nT) * (_nYv_ - nMin) / (nMax - nMin))
	next
	if bLine and _nN_ > 1
		_aPts_ = []
		for _i_ = 1 to _nN_
			_aPts_ + _aXs_[_i_]
			_aPts_ + _aYs_[_i_]
		next
		_oCanvas_.AddPolylineQ(_aPts_).StrokeQ(cCol, 3)
	ok
	for _i_ = 1 to _nN_
		_oCanvas_.AddCircleQ(_aXs_[_i_], _aYs_[_i_], 5).FillQ(cCol)
	next
