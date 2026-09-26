#=====================================================================#
#  STZMATHMOTION -- M2: motion is real -- a declared parameter that    #
#  re-solves a figure, played by the window loop                       #
#=====================================================================#
/*
	LAW 5 of the charter: motion is real. A motion is not a film of a
	figure; it is the figure itself, moved. A PARAMETER is a slider: a
	name, a range and a value, written into the figure's declaration
	where the author wrote {name}. Moving it does two things at two
	speeds, which is the split decision 8 ruled:

	    THE COMPUTED HALF AT FRAME RATE. The curve of y = a sin(b x) is
	    data the engine's tape computes; the motion compiles the family
	    ONCE with the parameters as variables (x, a, b) and re-samples it
	    every frame into an OVERLAY canvas the window draws over the
	    settled picture -- no recompile, no re-solve, no rebuild.

	    THE SOLVED HALF ON RELEASE. The marks, the notes and the window's
	    ticks are the figure's, solved; they are rebuilt and re-solved
	    when the parameter SETTLES (the key is released), and the time
	    that takes is a number the motion keeps and the gate prints
	    against the graph plane's 100 ms drag budget.

	    oM = StzMathMotionQ(:Function, [ :f = "{a} * sin({b} * x)", :on = [ -6.3, 6.3 ],
	                                     :mark = [ :extrema ], :curve = :live ])
	    oM.Param("a", 0.5, 3, 1)
	    oM.Param("b", 0.5, 3, 1)
	    oM.Play(oWindow)            # left/right move a, up/down move b, Escape closes

	The figure is asked to draw everything BUT its curve (:curve = :live),
	because the motion draws the curve where the parameters are now; the
	figure's own marks and notes are where the parameters last settled.

	OFFSCREEN, THE SAME: Frame() answers a canvas with the settled picture
	and the live curve composed, for a gate or an export, through the
	same calls the window path makes -- the same renderer pointed at
	another target. Declared STATES, the storyboard and the narration are
	M2b; this slice is the slider.
*/

func StzMathMotionQ(pcKind, paSpec)
	return new stzMathMotion(pcKind, paSpec)

class stzMathMotion from stzObject

	@cKind = ""
	@aTemplate = []      # the declaration with {name} placeholders
	@aParams = []        # [ [ cName, nFrom, nTo, nValue ] ]
	@oFigure = NULL      # the settled figure, or NULL before the first Settle
	@bDirty = TRUE       # a parameter moved since the last Settle
	@nSettleMs = 0       # what the last Settle cost
	@nFrameMs = 0        # what the last live frame cost, overlay only
	@oLive = NULL        # the family compiled once, x and the parameters as variables
	@acLiveVars = []
	@nSamples = 240      # per live frame: 3.3 px a segment on a 780 px window, and 240 tape calls
	@nInk = 0            # the curve's colour, resolved ONCE at Settle -- 0.77 ms a call, never per frame
	@nSettles = 0        # call counts, for a gate that asserts the frame's STRUCTURE
	@nTapeCalls = 0
	@nFlushes = 0

	def init(pcKind, paSpec)
		_k_ = StzLower(ring_trim("" + pcKind))
		if _k_ != "function"
			stzraise("stzMathMotion: a motion moves a :Function figure in this slice -- '" +
				pcKind + "' is not one.")
		ok
		if NOT isList(paSpec) or ring_len(paSpec) = 0
			stzraise("stzMathMotion: a motion is declared like a figure, with {name} where a " +
				"parameter goes: [ :f = '{a} * sin(x)', :on = [ -6, 6 ] ].")
		ok
		@cKind = _k_
		@aTemplate = paSpec
		# THE LIVE CURVE SAMPLES FEWER POINTS THAN THE SETTLED ONE: each is
		# one crossing into the engine per frame, and 400 of them measured
		# 10 to 17 ms under this machine's ambient load against a 16.7 ms
		# frame; 240 keep the segments under 4 px. A batch evaluation on the
		# tape would remove the crossings and is a request to the engine.
		_n_ = _FfGet(paSpec, "livesamples", 240)
		if isNumber(_n_) and _n_ >= 16 and _n_ <= 4000  @nSamples = _n_  ok

	#-- the parameters ----------------------------------------------------------

	# a slider: a name the declaration mentions as {name}, its range, and
	# where it stands now (the range's start when not said)
	def Param(pcName, pnFrom, pnTo, pnValue)
		_c_ = ring_trim("" + pcName)
		if _c_ = "" or NOT _MtIsName(_c_)
			stzraise("stzMathMotion.Param: a parameter's name is letters, like 'a' or 'k'.")
		ok
		if NOT isNumber(pnFrom) or NOT isNumber(pnTo) or pnTo <= pnFrom
			stzraise("stzMathMotion.Param: the range of '" + _c_ + "' is [ from, to ] with from < to.")
		ok
		if NOT _MtTemplateMentions(@aTemplate, _c_)
			stzraise("stzMathMotion.Param: the declaration never writes {" + _c_ + "} -- a parameter " +
				"moves what mentions it.")
		ok
		_v_ = pnValue
		if NOT isNumber(_v_)  _v_ = pnFrom  ok
		if _v_ < pnFrom  _v_ = pnFrom  ok
		if _v_ > pnTo  _v_ = pnTo  ok
		_i_ = This._ParamIndex(_c_)
		if _i_ > 0
			@aParams[_i_] = [ _c_, pnFrom, pnTo, _v_ ]
		else
			@aParams + [ _c_, pnFrom, pnTo, _v_ ]
		ok
		@bDirty = TRUE
		@oLive = NULL
		return This

		def ParamQ(pcName, pnFrom, pnTo, pnValue)
			return This.Param(pcName, pnFrom, pnTo, pnValue)

	def Params()
		return @aParams

	def Value(pcName)
		_i_ = This._ParamIndex(pcName)
		if _i_ = 0
			stzraise("stzMathMotion.Value: '" + pcName + "' is not a parameter of this motion.")
		ok
		return @aParams[_i_][4]

	# MOVE A SLIDER: clamped to its range; the computed half follows on the
	# next frame, the solved half on the next Settle
	def Set(pcName, pnValue)
		_i_ = This._ParamIndex(pcName)
		if _i_ = 0
			stzraise("stzMathMotion.Set: '" + pcName + "' is not a parameter of this motion.")
		ok
		if NOT isNumber(pnValue)
			stzraise("stzMathMotion.Set: a parameter takes a number.")
		ok
		_v_ = pnValue
		if _v_ < @aParams[_i_][2]  _v_ = @aParams[_i_][2]  ok
		if _v_ > @aParams[_i_][3]  _v_ = @aParams[_i_][3]  ok
		if _v_ != @aParams[_i_][4]
			@aParams[_i_][4] = _v_
			@bDirty = TRUE
		ok
		return This

		def SetQ(pcName, pnValue)
			return This.Set(pcName, pnValue)

	def IsDirty()
		return @bDirty

	def _ParamIndex(pcName)
		_c_ = StzLower(ring_trim("" + pcName))
		_n_ = ring_len(@aParams)
		for _i_ = 1 to _n_
			if StzLower(@aParams[_i_][1]) = _c_  return _i_  ok
		next
		return 0

	#-- the solved half: the figure where the parameters last settled ----------

	# the declaration with every {name} replaced by its value
	def Resolved()
		return _MtResolve(@aTemplate, @aParams)

	# REBUILD AND RE-SOLVE the figure for the parameters as they stand now,
	# and keep what it cost -- the solved half's number
	def Settle()
		_nT0_ = StzEngineWatchTimestampMs()
		@oFigure = StzMathFigureQ(@cKind, This.Resolved())
		@oFigure.Layout()
		# the colour system's law: resolve colour at load, never per frame
		@nInk = StzColorToNumber(:Primary)
		@nSettleMs = StzEngineWatchTimestampMs() - _nT0_
		@nSettles++
		@bDirty = FALSE
		return This

		def SettleQ()
			return This.Settle()

	def SettleMs()
		return @nSettleMs

	# the settled figure -- settled first if it never was
	def Figure()
		if NOT isObject(@oFigure)  This.Settle()  ok
		return @oFigure

	#-- the computed half: the curve where the parameters are now --------------

	# the family compiled ONCE, with x and every parameter as a variable:
	# the template's braces removed IS that expression
	def _Live()
		if isObject(@oLive)  return @oLive  ok
		_cF_ = _FfGet(@aTemplate, "f", "")
		if NOT isString(_cF_) or _cF_ = ""
			stzraise("stzMathMotion: this slice moves y = f(x) figures -- the declaration needs :f.")
		ok
		_cExpr_ = StzReplace(StzReplace(_cF_, "{", ""), "}", "")
		@acLiveVars = [ "x" ]
		_n_ = ring_len(@aParams)
		for _i_ = 1 to _n_  @acLiveVars + @aParams[_i_][1]  next
		@oLive = new stzMathFunction(_cExpr_, @acLiveVars)
		return @oLive

	# the live samples of the curve on the settled figure's window, as
	# pixel pieces: [ [ x1, y1, x2, y2, ... ], ... ], broken where the
	# function leaves the window or is not finite
	def LiveCurve()
		_oF_ = This.Figure()
		_oL_ = This._Live()
		_aW_ = _oF_.Window()
		_oS_ = _oF_.Substance()
		_nX0_ = _oS_.DataOf("fr", "x0")  _nY0_ = _oS_.DataOf("fr", "y0")
		_nX1_ = _oS_.DataOf("fr", "x1")  _nY1_ = _oS_.DataOf("fr", "y1")
		_nKx_ = (_nX1_ - _nX0_) / (_aW_[2] - _aW_[1])
		_nKy_ = (_nY1_ - _nY0_) / (_aW_[4] - _aW_[3])
		_aPt_ = [ 0 ]
		_n_ = ring_len(@aParams)
		for _i_ = 1 to _n_  _aPt_ + @aParams[_i_][4]  next
		_aPieces_ = []
		_aCur_ = []
		@nTapeCalls += @nSamples
		for _i_ = 0 to @nSamples - 1
			_x_ = _aW_[1] + (_aW_[2] - _aW_[1]) * _i_ / (@nSamples - 1)
			_aPt_[1] = _x_
			_y_ = _oL_.ValueAt(_aPt_)
			if _FfFinite(_y_) and _y_ >= _aW_[3] and _y_ <= _aW_[4]
				_aCur_ + (_nX0_ + (_x_ - _aW_[1]) * _nKx_)
				_aCur_ + (_nY0_ + (_aW_[4] - _y_) * _nKy_)
			else
				if ring_len(_aCur_) >= 4  _aPieces_ + _aCur_  ok
				_aCur_ = []
			ok
		next
		if ring_len(_aCur_) >= 4  _aPieces_ + _aCur_  ok
		return _aPieces_

	# the live samples in the author's units, for a check: [ [ x, y ], ... ]
	def LiveSamples()
		_oF_ = This.Figure()
		_oL_ = This._Live()
		_aW_ = _oF_.Window()
		_aPt_ = [ 0 ]
		_n_ = ring_len(@aParams)
		for _i_ = 1 to _n_  _aPt_ + @aParams[_i_][4]  next
		_a_ = []
		@nTapeCalls += @nSamples
		for _i_ = 0 to @nSamples - 1
			_x_ = _aW_[1] + (_aW_[2] - _aW_[1]) * _i_ / (@nSamples - 1)
			_aPt_[1] = _x_
			_a_ + [ _x_, _oL_.ValueAt(_aPt_) ]
		next
		return _a_

	# THE LIVE CURVE DRAWN INTO A CANVAS, cleared first: the overlay the
	# window draws over the settled picture. Keeps what it cost.
	def DrawLiveOn(poCanvas)
		_nT0_ = StzEngineWatchTimestampMs()
		poCanvas.Clear()
		_aP_ = This.LiveCurve()
		_n_ = ring_len(_aP_)
		for _i_ = 1 to _n_
			poCanvas.AddPolyline(_aP_[_i_])
			poCanvas.Stroke(@nInk, 2.5)
		next
		poCanvas.Flush()
		@nFlushes++
		@nFrameMs = StzEngineWatchTimestampMs() - _nT0_
		return This

	# the counts a gate asserts the frame's structure by: settles, tape
	# calls and flushes since the motion was made
	def Counts()
		return [ :settles = @nSettles, :tapecalls = @nTapeCalls, :flushes = @nFlushes ]

	def FrameMs()
		return @nFrameMs

	def LiveSampleCount()
		return @nSamples

	#-- a frame, offscreen: the same composition the window shows --------------

	# a fresh canvas with the settled picture and the live curve on it; the
	# caller frees it. The overlay path of the window draws the two as
	# separate layers; here they are one canvas, since a saved frame is one
	# picture.
	def Frame()
		_oC_ = This.Figure().Diagram().ToCanvas()
		_aP_ = This.LiveCurve()
		_n_ = ring_len(_aP_)
		for _i_ = 1 to _n_
			_oC_.AddPolyline(_aP_[_i_])
			_oC_.Stroke(@nInk, 2.5)
		next
		_oC_.Flush()
		return _oC_

	def FrameSVG()
		_oC_ = This.Frame()
		_c_ = _oC_.ToSVG()
		_oC_.Free()
		return _c_

	def FramePNG(pcPath)
		_oC_ = This.Frame()
		_c_ = _oC_.ToPNG(pcPath)
		_oC_.Free()
		return _c_

	#-- the window loop ----------------------------------------------------------

	# THE PLAYER: the settled picture retained in one canvas, the live curve
	# redrawn each frame in an overlay; the first parameter on left/right,
	# the second on up/down, a hundredth of its range per frame held; the
	# picture settles when no key is held and something moved. Escape closes.
	def Play(poWindow)
		if NOT isObject(poWindow)
			stzraise("stzMathMotion.Play: give an stzWindow.")
		ok
		This.Figure()
		_oStatic_ = @oFigure.Diagram().ToCanvas()
		_oOver_ = new stzCanvas(_oStatic_.Width(), _oStatic_.Height())
		_bMoved_ = FALSE
		while poWindow.IsOpen()
			poWindow.Poll()
			if poWindow.KeyPressed(:Escape)
				poWindow.Close()
				loop
			ok
			_bHeld_ = FALSE
			_n_ = ring_len(@aParams)
			if _n_ >= 1
				_nStep_ = (@aParams[1][3] - @aParams[1][2]) / 100
				if poWindow.KeyDown(:Right)  This.Set(@aParams[1][1], @aParams[1][4] + _nStep_)  _bHeld_ = TRUE  ok
				if poWindow.KeyDown(:Left)   This.Set(@aParams[1][1], @aParams[1][4] - _nStep_)  _bHeld_ = TRUE  ok
			ok
			if _n_ >= 2
				_nStep_ = (@aParams[2][3] - @aParams[2][2]) / 100
				if poWindow.KeyDown(:Up)    This.Set(@aParams[2][1], @aParams[2][4] + _nStep_)  _bHeld_ = TRUE  ok
				if poWindow.KeyDown(:Down)  This.Set(@aParams[2][1], @aParams[2][4] - _nStep_)  _bHeld_ = TRUE  ok
			ok
			if _bHeld_  _bMoved_ = TRUE  ok
			if NOT _bHeld_ and _bMoved_ and @bDirty
				# THE RELEASE: the solved half catches up, once
				This.Settle()
				_oStatic_.Free()
				_oStatic_ = @oFigure.Diagram().ToCanvas()
				_bMoved_ = FALSE
			ok
			This.DrawLiveOn(_oOver_)
			poWindow.DrawXT(_oStatic_, _oOver_)
		end
		_oOver_.Free()
		_oStatic_.Free()
		return This

	def Why()
		_c_ = "a motion over a " + @cKind + " figure with " + ring_len(@aParams) + " parameter(s):"
		_n_ = ring_len(@aParams)
		for _i_ = 1 to _n_
			_c_ += " " + @aParams[_i_][1] + " = " + _FfNum(@aParams[_i_][4], 4) + " in [" +
				_FfNum(@aParams[_i_][2], 4) + ", " + _FfNum(@aParams[_i_][3], 4) + "]"
		next
		if @bDirty  _c_ += "; moved since it settled"  else  _c_ += "; settled in " + _FfNum(@nSettleMs, 1) + " ms"  ok
		return _c_

#-- helpers ------------------------------------------------------------------

func _MtIsName(pc)
	for _i_ = 1 to len(pc)
		if NOT _NtIsAlpha(pc[_i_])  return FALSE  ok
	next
	return TRUE

# does any string value of the declaration write {name}?
func _MtTemplateMentions(paSpec, pcName)
	for _i_ = 1 to len(paSpec)
		_v_ = paSpec[_i_][2]
		if isString(_v_) and StzFindFirst("{" + pcName + "}", _v_) > 0  return TRUE  ok
	next
	return FALSE

# the declaration with every {name} replaced by the parameter's value
func _MtResolve(paSpec, paParams)
	_a_ = []
	for _i_ = 1 to len(paSpec)
		_k_ = paSpec[_i_][1]
		_v_ = paSpec[_i_][2]
		if isString(_v_)
			for _p_ = 1 to len(paParams)
				_v_ = StzReplace(_v_, "{" + paParams[_p_][1] + "}", "(" + _FfNum(paParams[_p_][4], 6) + ")")
			next
		ok
		_a_ + [ _k_, _v_ ]
	next
	return _a_
