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
	on "line"
		_StzPlotLine(_oCanvas_, paValues, _cCol_, _nL_, _nR_, _nT_, _nB_, _nMin_, _nMax_, TRUE)
	on "scatter"
		_StzPlotLine(_oCanvas_, paValues, _cCol_, _nL_, _nR_, _nT_, _nB_, _nMin_, _nMax_, FALSE)
	other
		StzRaise("stzPlotCanvas: unknown kind '" + _cKind_ +
			"' -- use :VBar, :HBar, :Line or :Scatter.")
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
