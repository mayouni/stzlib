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
	another target.

	DECLARED STATES (M2b). The second subject of a motion is any solved
	stzMathDiagram, and the second kind of motion is a SEQUENCE OF STATES:
	each a caption and the acts that reach it from the state before -- a
	drag of a free shape, a datum written into the substance, a theme, or
	a parameter set. The same declaration is played three ways and the
	gate holds them to be one picture:

	    oM = StzMathMotionOverQ(oByrne)
	    oM.State("Drag A: a^2 + b^2 - c^2 = {gap} px^2", [ [ :DragBy, "A.icon", 60, -30 ] ])
	    oM.StateFact("gap", :expr, [ "dist(A.icon,B.icon)^2 + dist(A.icon,C.icon)^2 - dist(B.icon,C.icon)^2", "px^2" ])
	    oM.Apply(1)                       # the live pass, on the motion's own picture
	    oM.PlayStates(oWindow, 2000)      # the window, each state held two seconds
	    oS = oM.ExportTo("folio", "pythagoras")   # the storyboard: frames, facts, narration

	The export is an stzStoryboard driven by the SAME acts, so every
	exported frame is the picture at that state and never a stored image,
	every number in a caption is a fact read from that frame, and the
	narration beside the frames names the frames as cells. The storyboard
	works on its own copy of the picture from where the picture stands
	when the export is asked, so an export leaves the motion where it was.
	The gate compares the exported bytes with the bytes of the picture
	walked by hand: the frames are the live picture, proven, not claimed.
*/

func StzMathMotionQ(pcKind, paSpec)
	return new stzMathMotion(pcKind, paSpec)

# a motion of declared states over a picture the author already built --
# any stzMathDiagram; it is laid out here if it was not, BEFORE the motion
# takes its copy, because a copy of an unsolved picture solves itself again
func StzMathMotionOverQ(poPicture)
	return new stzMathMotion(:Diagram, poPicture)

# Moves a math figure for real: a declared parameter re-draws its curve every frame, and declared states walk a diagram one caption at a time.
#
# A motion is the figure itself, moved, not a film of it. Over a :Function figure it holds sliders,
# written {name} in the declaration; the curve is recompiled once and re-sampled at frame rate into
# an overlay, while the figure's marks and notes are solved again only when the slider settles. Over
# a :Diagram it holds declared states, each a caption and the acts that reach it (a drag, a datum, a
# theme or a parameter). The same declaration is played in a window (Play, PlayStates), offscreen
# (Frame, FrameSVG, FramePNG, Apply) or exported as a storyboard of PNG frames and a narration
# (ExportTo). Moving a parameter marks the motion dirty and Settle takes about a second for a figure
# with marks. Play and PlayStates need a window and block until Escape.
#
#   receiver   o1 = StzMathMotionQ(:Function, [ :f = "{a} * sin(x)", :on = [ -6.3, 6.3 ], :mark = [
#              :extrema ] ])
#   example    o1.Param("a", 0.5, 3, 1)
#              ? o1.Value("a")
#              #--> 1
#              o1.Set("a", 2)
#              ? @@( o1.Resolved()[1] )
#              #--> [ "f", "(2) * sin(x)" ]
#              ? o1.IsDirty()
#              #--> 1
#              o1.Settle()
#              ? o1.IsDirty()
#              #--> 0
#              ? o1.LiveSampleCount()
#              #--> 240
#              ? len( o1.LiveSamples() )
#              #--> 240
#              o1.State("a is two", [ [ :Set, "a", 2 ] ])
#              ? o1.NumberOfStates()
#              #--> 1
#              o1.Apply(1)
#              ? o1.Applied()
#              #--> 1
#   see        stzMathFigure, stzMathDiagram, stzStoryboard, stzWindow
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

	@oPicture = NULL     # the :Diagram subject -- the motion's own copy, laid out
	@aStates = []        # [ [ cCaption, aActs, aFacts ] ]; an act is [ verb, ... ], a fact [ hole, kind, args ]
	@nApplied = 0        # the state the picture stands in, 0 before any Apply
	@nApplyMs = 0        # what the last Apply cost -- the drag budget is 100 ms
	@oStory = NULL       # the last export

	# Builds a motion over a function figure with named parameters, or over a solved diagram that declared states will move.
	#
	#   pcKind     Function or Diagram, in any case
	#   paSpec     for Function a declaration like a figure's, with {name} where a parameter goes,
	#              such as [ :f = "{a} * sin(x)", :on = [ -6, 6 ] ], and optionally :livesamples
	#              between 16 and 4000
	#   returns    nothing; the object is built
	#   note       the motion over a diagram takes its own copy of the picture
	#   warning    Raises an error for any other kind, for an empty or missing declaration, and for
	#              a Diagram given something that is not a stzMathDiagram
	#   see        Param, State, StzMathMotionQ, StzMathMotionOverQ
	def init(pcKind, paSpec)
		_k_ = StzLower(ring_trim("" + pcKind))
		if _k_ = "diagram"
			if NOT _MtIsMathDiagram(paSpec)
				stzraise("stzMathMotion: a motion over a :Diagram takes an stzMathDiagram -- " +
					"the picture the states move.")
			ok
			paSpec.Layout()
			@cKind = _k_
			@oPicture = paSpec
			return
		ok
		if _k_ != "function"
			stzraise("stzMathMotion: a motion moves a :Function figure or a :Diagram -- '" +
				pcKind + "' is neither.")
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

	# Declares a slider: a name the declaration writes as {name}, its range and its starting value.
	#
	#   pcName     the parameter's name, letters only such as a
	#   pnFrom     the lowest value
	#   pnTo       the highest value, above pnFrom
	#   pnValue    the starting value, clamped into the range, and the range's start when it is not
	#              a number
	#   returns    the motion itself, so calls chain
	#   note       it marks the motion as moved, so the next frame settles
	#   warning    raises an error for a name with digits, a range that is not from below to, and a
	#              name that the declaration never writes as {name}; declaring the same name again
	#              replaces it
	#   see        Set, Value, Params
	#@ aka  -- the parameters ----------------------------------------------------------
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

	# Returns the declared sliders, each with its name, range and current value.
	#
	#   returns    a list of [ name, from, to, value ]
	#   see        Param, Value
	def Params()
		return @aParams

	# Returns the current value of a slider.
	#
	#   pcName     the parameter's name, in any case
	#   returns    a number
	#   warning    raises an error naming a parameter that was not declared
	#   see        Set, Params
	def Value(pcName)
		_i_ = This._ParamIndex(pcName)
		if _i_ = 0
			stzraise("stzMathMotion.Value: '" + pcName + "' is not a parameter of this motion.")
		ok
		return @aParams[_i_][4]

	# Moves a slider to a value, clamped to its range, the curve following on the next frame and the solved figure at the next Settle.
	#
	#   pcName     the parameter's name, in any case
	#   pnValue    the new value, a number
	#   returns    the motion itself, so calls chain
	#   warning    raises an error for a parameter that was not declared and for a value that is not
	#              a number
	#   see        Value, Settle, IsDirty
	#@ aka  MOVE A SLIDER: clamped to its range; the computed half follows on the next frame, the solved half on the next Settle
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

	# TRUE if a parameter moved since the figure was last settled, which is also the state of a new motion.
	#
	#   returns    1 or 0
	#   see        Settle, Set
	def IsDirty()
		return @bDirty

	def _ParamIndex(pcName)
		_c_ = StzLower(ring_trim("" + pcName))
		_n_ = ring_len(@aParams)
		for _i_ = 1 to _n_
			if StzLower(@aParams[_i_][1]) = _c_  return _i_  ok
		next
		return 0

	# Returns the declaration with every {name} replaced by the slider's current value in brackets.
	#
	#   returns    a list of key and value pairs such as [ "f", "(2) * sin(x)" ]
	#   see        Settle, Param
	#@ aka  -- the solved half: the figure where the parameters last settled ----------
	def Resolved()
		return _MtResolve(@aTemplate, @aParams)

	# Rebuilds the figure and solves it for the parameters as they stand, and keeps what that cost.
	#
	#   returns    the motion itself, so calls chain
	#   note       it takes about a second for a figure with marks, which is why it waits for a
	#              release rather than running every frame
	#   see        SettleMs, IsDirty, Figure
	#@ aka  REBUILD AND RE-SOLVE the figure for the parameters as they stand now, and keep what it cost -- the solved half's number
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

	# Returns how many milliseconds the last Settle took.
	#
	#   returns    a number; 0 before the first Settle
	#   see        Settle
	def SettleMs()
		return @nSettleMs

	# Returns the settled figure, settling first if it never was.
	#
	#   returns    the figure object, a stzMathFigure
	#   see        Settle, Picture
	#@ aka  the settled figure -- settled first if it never was
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

	# Samples the curve at the current slider values as pieces of pixel coordinates, broken where it leaves the window.
	#
	#   returns    a list of pieces, each a flat list of x, y, x, y ...
	#   note       it settles the figure first if needed; each call adds the sample count to the
	#              tape calls of Counts
	#   see        LiveSamples, DrawLiveOn
	#@ aka  the live samples of the curve on the settled figure's window, as pixel pieces: [ [ x1, y1, x2, y2, ... ], ... ], broken where the function leaves the window or is not finite
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

	# Samples the curve at the current slider values in the author's own units.
	#
	#   returns    a list of pairs [ x, y ], 240 of them by default
	#   see        LiveCurve, LiveSampleCount
	#@ aka  the live samples in the author's units, for a check: [ [ x, y ], ... ]
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

	# Clears a canvas and draws the live curve on it, the overlay a window shows over the settled picture, and keeps what it cost.
	#
	#   poCanvas   the stzCanvas that becomes the overlay, which is cleared first
	#   returns    the motion itself, so calls chain
	#   see        FrameMs, Frame, Play
	#@ aka  THE LIVE CURVE DRAWN INTO A CANVAS, cleared first: the overlay the window draws over the settled picture. Keeps what it cost.
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

	# Returns how many settles, tape calls and canvas flushes the motion has made, so a test can assert the structure of a frame.
	#
	#   returns    a hash-list with settles, tapecalls and flushes
	#   see        FrameMs
	#@ aka  the counts a gate asserts the frame's structure by: settles, tape calls and flushes since the motion was made
	def Counts()
		return [ :settles = @nSettles, :tapecalls = @nTapeCalls, :flushes = @nFlushes ]

	# Returns how many milliseconds the last live frame took, overlay only.
	#
	#   returns    a number; 0 before any live frame
	#   see        DrawLiveOn, Counts
	def FrameMs()
		return @nFrameMs

	# Returns how many points each live frame samples.
	#
	#   returns    a number; 240 by default
	#   see        LiveSamples
	def LiveSampleCount()
		return @nSamples

	# Composes the settled picture and the live curve into one new canvas, the offscreen twin of what the window shows.
	#
	#   returns    a stzCanvas that the caller must free
	#   see        FrameSVG, FramePNG
	#@ aka  -- a frame, offscreen: the same composition the window shows --------------
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

	# Returns the composed frame as SVG text, without needing a window.
	#
	#   returns    a text starting with the svg tag
	#   see        Frame, FramePNG
	def FrameSVG()
		_oC_ = This.Frame()
		_c_ = _oC_.ToSVG()
		_oC_.Free()
		return _c_

	# Writes the composed frame to a PNG file and returns the PNG bytes.
	#
	#   pcPath     the file to write
	#   returns    the PNG as a binary text; empty when this machine has no graphics device
	#   warning    the returned text is the picture itself, so do not print it
	#   see        Frame, FrameSVG
	def FramePNG(pcPath)
		_oC_ = This.Frame()
		_c_ = _oC_.ToPNG(pcPath)
		_oC_.Free()
		return _c_

	# Runs the live window loop, moving the first parameter on left and right and the second on up and down, until Escape.
	#
	#   poWindow   an open stzWindow to draw in
	#   returns    the motion itself
	#   note       blocks until Escape or the window is closed
	#   warning    raises an error when the argument is not an object
	#   see        PlayStates, DrawLiveOn
	#@ aka  -- the window loop ----------------------------------------------------------
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

	# Declares a state: a caption and the acts that bring the picture to it from the previous state.
	#
	#   pcCaption   what the reader is told, which may write {hole} for a fact
	#   paActs      a list of acts, each a list led by its verb: DragTo, DragBy, SetData, SetTheme
	#               (for a diagram) or Set (for a function motion)
	#   returns     the motion itself, so calls chain
	#   note        a state with no act is the picture as it stands
	#   warning     raises an error for an empty caption, an unknown verb, a verb that does not fit
	#               the kind of motion, a drag of a shape with no free centre, and a missing
	#               parameter; a single act not wrapped in a list raises an operator error today
	#               instead of being accepted (confirmed with two different acts)
	#   see         StateFact, Apply, ExportTo
	#@ aka  -- declared STATES ----------------------------------------------------------
	def State(pcCaption, paActs)
		_c_ = "" + pcCaption
		if ring_trim(_c_) = ""
			stzraise("stzMathMotion.State: a state needs a caption -- what the reader is told.")
		ok
		_a_ = paActs
		if NOT isList(_a_)  _a_ = []  ok
		if ring_len(_a_) > 0 and NOT isList(_a_[1])  _a_ = [ _a_ ]  ok
		_aActs_ = []
		_n_ = ring_len(_a_)
		for _i_ = 1 to _n_
			_aActs_ + This._CheckedAct(_a_[_i_])
		next
		@aStates + [ _c_, _aActs_, [] ]
		return This

		def StateQ(pcCaption, paActs)
			return This.State(pcCaption, paActs)

	# Binds a fact that the caption of the last declared state shows as {hole}, computed on the picture at that state.
	#
	#   pcHole     the name written as {name} in the caption
	#   pcKind     the kind of fact, such as expr, angle, value or datum
	#   paArgs     the arguments of that fact, such as [ expression, unit ]
	#   returns    the motion itself, so calls chain
	#   warning    raises an error when no state is declared or when the caption never writes the
	#              hole
	#   see        State, FactsOf
	#@ aka  a fact the caption of the LAST declared state shows as {hole}: bound now, computed when the frame is closed, on the picture at that state
	def StateFact(pcHole, pcKind, paArgs)
		_n_ = ring_len(@aStates)
		if _n_ = 0
			stzraise("stzMathMotion.StateFact: declare a state first -- a fact belongs to the " +
				"state whose caption shows it.")
		ok
		_h_ = ring_trim("" + pcHole)
		if NOT _MtIsHole(_h_)
			stzraise("stzMathMotion.StateFact: a hole is a name -- letters, then letters or digits -- written {name} in the caption.")
		ok
		if StzFindFirst("{" + _h_, @aStates[_n_][1]) = 0
			stzraise("stzMathMotion.StateFact: the caption of state " + _n_ + " never writes {" + _h_ +
				"} -- a fact is bound in order to be shown.")
		ok
		@aStates[_n_][3] + [ _h_, "" + pcKind, paArgs ]
		return This

		def StateFactQ(pcHole, pcKind, paArgs)
			return This.StateFact(pcHole, pcKind, paArgs)

	# Returns every declared state as its caption, its acts and its facts.
	#
	#   returns    a list of [ caption, acts, facts ]
	#   see        NumberOfStates, CaptionOf
	def States()
		return @aStates

	# Returns how many states are declared.
	#
	#   returns    a number
	#   see        States
	def NumberOfStates()
		return ring_len(@aStates)

	# Returns the caption of one state.
	#
	#   pnState    the position of the state, from 1
	#   returns    a text
	#   warning    raises an error naming the count when the state is not declared
	#   see        ActsOf, States
	def CaptionOf(pnState)
		This._RequireState("CaptionOf", pnState)
		return @aStates[pnState][1]

	# Returns the acts of one state, each led by its verb in lowercase.
	#
	#   pnState    the position of the state, from 1
	#   returns    a list of acts such as [ "dragby", "A.icon", 60, -30 ]
	#   warning    raises an error when the state is not declared
	#   see        CaptionOf
	def ActsOf(pnState)
		This._RequireState("ActsOf", pnState)
		return @aStates[pnState][2]

	# Returns the facts bound to one state, each as hole, kind and arguments.
	#
	#   pnState    the position of the state, from 1
	#   returns    a list of [ hole, kind, args ]
	#   warning    raises an error when the state is not declared
	#   see        StateFact
	def FactsOf(pnState)
		This._RequireState("FactsOf", pnState)
		return @aStates[pnState][3]

	# Returns the number of the state the picture stands in.
	#
	#   returns    a number; 0 before any Apply
	#   see        Apply, ApplyAll
	def Applied()
		return @nApplied

	# Returns how many milliseconds the last Apply took.
	#
	#   returns    a number; 0 before any Apply
	#   note       the graph plane's drag budget is 100 ms
	#   see        Apply
	def ApplyMs()
		return @nApplyMs

	# Returns the storyboard made by the last export.
	#
	#   returns    the stzStoryboard; empty text before any export
	#   see        ExportTo
	def Story()
		return @oStory

	# Returns the picture as it stands: the motion's own copy for a diagram, the settled figure's diagram for a function.
	#
	#   returns    the diagram object
	#   see        Apply, Figure
	#@ aka  the picture as it stands: the motion's own copy for a :Diagram, the settled figure's diagram for a :Function -- a copy, for reading
	def Picture()
		if @cKind = "function"
			return This.Figure().Diagram()
		ok
		return @oPicture

	# Performs the acts of one state on the motion's own picture, so the picture then stands in that state.
	#
	#   pnState    the position of the state, from 1
	#   returns    the motion itself, so calls chain
	#   note       the acts are applied from wherever the picture stands, so jumping over states
	#              skips their acts
	#   warning    raises an error when the state is not declared
	#   see        ApplyAll, Applied, ApplyMs
	#@ aka  THE LIVE PASS: the acts of one state, on the motion's own picture. States are steps, so state n is reached from state n-1; a caller that jumps is asking for the acts of n from wherever the picture stands, which is what it gets and what Applied() then says.
	def Apply(pnState)
		This._RequireState("Apply", pnState)
		_nT0_ = StzEngineWatchTimestampMs()
		_a_ = @aStates[pnState][2]
		_n_ = ring_len(_a_)
		for _i_ = 1 to _n_
			This._Perform(_a_[_i_], NULL)
		next
		if @cKind = "function" and @bDirty  This.Settle()  ok
		@nApplyMs = StzEngineWatchTimestampMs() - _nT0_
		@nApplied = pnState
		return This

		def ApplyQ(pnState)
			return This.Apply(pnState)

	# Applies every declared state in order.
	#
	#   returns    the motion itself, so calls chain
	#   see        Apply
	def ApplyAll()
		_n_ = ring_len(@aStates)
		for _i_ = 1 to _n_
			This.Apply(_i_)
		next
		return This

	# one act on the picture: through the storyboard when one is open, so its
	# frame SEES the act; on the motion's own picture otherwise
	def _Perform(paAct, poStory)
		_v_ = paAct[1]
		_bStory_ = isObject(poStory)
		if _v_ = "dragto" or _v_ = "dragby"
			_x_ = paAct[3]
			_y_ = paAct[4]
			if _v_ = "dragby"
				if _bStory_
					_x_ += poStory.Fact(:value, [ paAct[2] + ".cx" ])[:value]
					_y_ += poStory.Fact(:value, [ paAct[2] + ".cy" ])[:value]
				else
					_x_ += @oPicture.ValueOf(paAct[2] + ".cx")
					_y_ += @oPicture.ValueOf(paAct[2] + ".cy")
				ok
			ok
			if _bStory_
				poStory.Act(:DragTo, [ paAct[2], _x_, _y_ ])
			else
				@oPicture.DragTo(paAct[2], _x_, _y_)
			ok
		but _v_ = "setdata"
			if _bStory_
				poStory.Act(:SetData, [ paAct[2], paAct[3], paAct[4] ])
			else
				@oPicture.SetSubstanceData(paAct[2], paAct[3], paAct[4])
			ok
		but _v_ = "settheme"
			if _bStory_
				poStory.Act(:SetTheme, [ paAct[2] ])
			else
				@oPicture.SetPictureTheme(paAct[2])
			ok
		but _v_ = "set"
			This.Set(paAct[2], paAct[3])
		ok

	def _CheckedAct(paAct)
		if NOT isList(paAct) or ring_len(paAct) = 0
			stzraise("stzMathMotion.State: an act is a list led by its verb -- " +
				"[ :DragTo, 'A.icon', x, y ], [ :SetData, 'fr', 'ymax', 2 ], [ :Set, 'a', 2 ].")
		ok
		_v_ = StzLower(ring_trim("" + paAct[1]))
		_n_ = ring_len(paAct)
		if _v_ = "dragto" or _v_ = "dragby"
			This._RequireDiagram("State", _v_)
			if _n_ < 4 or NOT isString(paAct[2]) or NOT isNumber(paAct[3]) or NOT isNumber(paAct[4])
				stzraise("stzMathMotion.State: " + _v_ + " takes a shape path and two numbers -- " +
					"[ :DragBy, 'A.icon', 60, -30 ].")
			ok
			_c_ = ring_trim(paAct[2])
			if @oPicture._UnknownIndex(_c_ + ".cx") = 0 or @oPicture._UnknownIndex(_c_ + ".cy") = 0
				stzraise("stzMathMotion.State: '" + _c_ + "' has no free centre -- a drag moves a " +
					"shape whose position a rule left to the solver.")
			ok
			return [ _v_, _c_, paAct[3], paAct[4] ]
		but _v_ = "setdata"
			This._RequireDiagram("State", _v_)
			if _n_ < 4 or NOT isString(paAct[2]) or NOT isString(paAct[3]) or NOT isNumber(paAct[4])
				stzraise("stzMathMotion.State: SetData takes an object, a key and a number -- " +
					"[ :SetData, 'fr', 'ymax', 2 ].")
			ok
			return [ "setdata", ring_trim(paAct[2]), ring_trim(paAct[3]), paAct[4] ]
		but _v_ = "settheme"
			This._RequireDiagram("State", _v_)
			if _n_ < 2 or NOT isString(paAct[2])
				stzraise("stzMathMotion.State: SetTheme takes a theme name -- [ :SetTheme, 'dark' ].")
			ok
			return [ "settheme", ring_trim(paAct[2]) ]
		but _v_ = "set"
			if @cKind != "function"
				stzraise("stzMathMotion.State: Set moves a parameter, and a motion over a " +
					":Diagram has none -- drag a shape or write a datum.")
			ok
			if _n_ < 3 or NOT isString(paAct[2]) or NOT isNumber(paAct[3])
				stzraise("stzMathMotion.State: Set takes a parameter name and a number -- [ :Set, 'a', 2 ].")
			ok
			if This._ParamIndex(ring_trim(paAct[2])) = 0
				stzraise("stzMathMotion.State: '" + paAct[2] + "' is not a parameter of this motion -- " +
					"declare it with Param first.")
			ok
			return [ "set", ring_trim(paAct[2]), paAct[3] ]
		else
			stzraise("stzMathMotion.State: '" + _v_ + "' is not an act a state takes -- " +
				"DragTo, DragBy, SetData, SetTheme or Set.")
		ok

	def _RequireDiagram(pcWhat, pcVerb)
		if @cKind != "diagram"
			stzraise("stzMathMotion." + pcWhat + ": " + pcVerb + " acts on a picture, and this " +
				"motion is over a :Function figure -- its states Set parameters.")
		ok

	def _RequireState(pcWhat, pnState)
		_n_ = ring_len(@aStates)
		if NOT isNumber(pnState) or pnState < 1 or pnState > _n_
			stzraise("stzMathMotion." + pcWhat + ": state " + pnState + " is not declared -- " +
				_n_ + " state(s) are.")
		ok

	# Writes every state as a PNG frame in a folder with its facts computed, plus a narration file, through a storyboard.
	#
	#   pcFolio    the folder to write into, current folder when empty
	#   pcName     the name of the storyboard, which prefixes name_01.png, name_02.png and so on
	#   returns    the stzStoryboard of the export
	#   note       the folder must exist
	#   warning    raises an error when no state is declared, when the name is empty, when a
	#              function motion draws its curve live, and when the machine has no graphics
	#              device; the parameters of a function motion are put back afterwards
	#   see        Story, Apply, PlayStates
	#@ aka  -- the export: a storyboard driven by the same acts ------------------------
	def ExportTo(pcFolio, pcName)
		_nS_ = ring_len(@aStates)
		if _nS_ = 0
			stzraise("stzMathMotion.ExportTo: declare a state first -- a storyboard is its states, told.")
		ok
		_cF_ = ring_trim("" + pcFolio)
		if _cF_ = ""  _cF_ = "."  ok
		_cN_ = ring_trim("" + pcName)
		if _cN_ = ""
			stzraise("stzMathMotion.ExportTo: a storyboard needs a name -- its frames are name_01.png, name_02.png ...")
		ok
		if @cKind = "function"
			if StzLower("" + _FfGet(@aTemplate, "curve", "")) = "live"
				stzraise("stzMathMotion.ExportTo: a storyboard frame is the settled picture, and this " +
					"motion draws its curve live -- declare it without :curve = :live to export it.")
			ok
			_aWas_ = []
			_nP_ = ring_len(@aParams)
			for _i_ = 1 to _nP_
				_aWas_ + @aParams[_i_][4]
			next
			_oS_ = new stzStoryboard(_cN_, This.Figure().Diagram(), _cF_)
		else
			_oS_ = new stzStoryboard(_cN_, @oPicture, _cF_)
		ok
		for _i_ = 1 to _nS_
			_a_ = @aStates[_i_][2]
			_n_ = ring_len(_a_)
			if @cKind = "function"
				for _k_ = 1 to _n_
					This._Perform(_a_[_k_], NULL)
				next
				if @bDirty  This.Settle()  ok
				_oS_.FrameOf(This.Figure().Diagram(), @aStates[_i_][1])
			else
				_oS_.Frame(@aStates[_i_][1])
				for _k_ = 1 to _n_
					This._Perform(_a_[_k_], _oS_)
				next
			ok
			_aF_ = @aStates[_i_][3]
			_nF_ = ring_len(_aF_)
			for _k_ = 1 to _nF_
				_oS_.Bind(_aF_[_k_][1], _aF_[_k_][2], _aF_[_k_][3])
			next
			if _i_ = 1
				# THE DEVICE, NAMED: a frame is a PNG, and without a graphics
				# device ToPNG writes nothing and says so by an empty answer
				_cFirst_ = _oS_.FileOf(1)
				if NOT fexists(_cF_ + "/" + _cFirst_)
					stzraise("stzMathMotion.ExportTo: no graphics device -- a storyboard frame is a " +
						"PNG and this machine cannot draw one. Apply() and Picture().ToSVG() " +
						"give the same states offscreen without a device.")
				ok
			ok
		next
		_oS_.ToNarration(_cF_ + "/" + _cN_ + ".narration")
		if @cKind = "function"
			for _i_ = 1 to _nP_
				@aParams[_i_][4] = _aWas_[_i_]
			next
			@bDirty = TRUE
		ok
		@oStory = _oS_
		return _oS_

	# Shows each state on a window in turn, holding each for a time; Right or Space advance early, Escape closes, and the last state holds.
	#
	#   poWindow    an open stzWindow to draw in
	#   pnDwellMs   how long to hold each state in milliseconds, 2000 when not a number
	#   returns     the motion itself
	#   note        blocks until Escape or the window is closed
	#   warning     raises an error when the argument is not an object or no state is declared
	#   see         Play, Apply
	#@ aka  -- the player of states ------------------------------------------------------
	def PlayStates(poWindow, pnDwellMs)
		if NOT isObject(poWindow)
			stzraise("stzMathMotion.PlayStates: give an stzWindow.")
		ok
		_nS_ = ring_len(@aStates)
		if _nS_ = 0
			stzraise("stzMathMotion.PlayStates: declare a state first.")
		ok
		_nDwell_ = pnDwellMs
		if NOT isNumber(_nDwell_) or _nDwell_ < 0  _nDwell_ = 2000  ok
		_bLive_ = (@cKind = "function" and StzLower("" + _FfGet(@aTemplate, "curve", "")) = "live")
		_i_ = 0
		_oC_ = NULL
		_nUntil_ = 0
		while poWindow.IsOpen()
			poWindow.Poll()
			if poWindow.KeyPressed(:Escape)
				poWindow.Close()
				loop
			ok
			_bNext_ = (_i_ = 0)
			if _i_ > 0 and _i_ < _nS_
				if StzEngineWatchTimestampMs() >= _nUntil_ or poWindow.KeyPressed(:Right) or
				   poWindow.KeyPressed(:Space)
					_bNext_ = TRUE
				ok
			ok
			if _bNext_
				_i_++
				This.Apply(_i_)
				if isObject(_oC_)  _oC_.Free()  ok
				if _bLive_
					_oC_ = This.Frame()
				else
					_oC_ = This.Picture().ToCanvas()
				ok
				_nUntil_ = StzEngineWatchTimestampMs() + _nDwell_
			ok
			if isObject(_oC_)  poWindow.Draw(_oC_)  ok
		end
		if isObject(_oC_)  _oC_.Free()  ok
		return This

	# Describes the motion in one sentence: its kind, its parameters and where they stand, whether it is settled, and its states.
	#
	#   returns    a text
	#   see        Settle, Apply
	def Why()
		if @cKind = "diagram"
			_c_ = "a motion of " + ring_len(@aStates) + " declared state(s) over a picture"
			if @nApplied > 0
				_c_ += "; standing in state " + @nApplied + ", reached in " + _FfNum(@nApplyMs, 1) + " ms"
			else
				_c_ += "; standing as declared"
			ok
			return _c_
		ok
		_c_ = "a motion over a " + @cKind + " figure with " + ring_len(@aParams) + " parameter(s):"
		_n_ = ring_len(@aParams)
		for _i_ = 1 to _n_
			_c_ += " " + @aParams[_i_][1] + " = " + _FfNum(@aParams[_i_][4], 4) + " in [" +
				_FfNum(@aParams[_i_][2], 4) + ", " + _FfNum(@aParams[_i_][3], 4) + "]"
		next
		if @bDirty  _c_ += "; moved since it settled"  else  _c_ += "; settled in " + _FfNum(@nSettleMs, 1) + " ms"  ok
		if ring_len(@aStates) > 0
			_c_ += "; " + ring_len(@aStates) + " declared state(s)"
		ok
		return _c_

#-- helpers ------------------------------------------------------------------

# a free function on purpose: inside a class, classname() resolves to the
# class's own ClassName() method and refuses the argument
func _MtIsMathDiagram(p)
	if NOT isObject(p)  return FALSE  ok
	return StzLower(ring_classname(p)) = "stzmathdiagram"

# a hole: a letter, then letters or digits -- {a2}, {gap}
func _MtIsHole(pc)
	if len(pc) = 0 or NOT _NtIsAlpha(pc[1])  return FALSE  ok
	for _i_ = 2 to len(pc)
		if NOT _NtIsAlpha(pc[_i_]) and NOT isdigit(pc[_i_])  return FALSE  ok
	next
	return TRUE

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
