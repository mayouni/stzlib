#---------------------------------------------------------------------------#
#  STZCANVAS -- describe a 2D picture once; get it as vector OR as pixels.  #
#---------------------------------------------------------------------------#
#
#     oC = new stzCanvas(800, 600)
#     oC.SetBackground("#101418")
#     oC.AddCircle(400, 300, 120)
#     oC.Fill("#e0a030")                 # applies to the last shape added
#
#     # the same, fluent -- every Q returns the CANVAS, never a sub-object
#     oC.AddCircleQ(400, 300, 120).FillQ("#e0a030").StrokeQ("#ffffff", 2)
#     oC.AddTextQ("Softanza", 330, 310).SetFontQ(oFont, 24).ColorQ("#ffffff")
#
#     ? oC.ToSVG()                       # tier 1 -- vector, NO device needed
#     oC.ToPNG("out.png")                # tier 2 -- the GPU draws it
#
# THE LAW THIS CLASS FOLLOWS (house naming, restated because every method
# here obeys it):
#   - a method is an explicit VERB acting on the canvas: AddCircle, Fill,
#     SetBackground -- never a bare noun;
#   - the plain form ACTS and returns nothing;
#   - the ...Q twin does the same act and returns THE CANVAS, so a chain
#     never leaves the main object for a shape object to be held or lost;
#   - To...() keeps its name and returns DATA.
#
# WHY "the last shape added" works: an Add* remembers the shape instead of
# posting it immediately, so Fill/Stroke/Color/SetFont can still reach it.
# The shape is posted when the next Add* arrives or when output is asked
# for. Nothing is lost if you never call Fill -- the canvas's current fill
# is used, and Fill BEFORE any Add sets that default.
#
# The two outputs are twins of ONE display list, so they cannot disagree
# about where anything sits. ToSVG() works with no GPU at all -- that is
# the tier ladder's floor, and it is why a CI machine can still draw.

func StzCanvasQ(pnW, pnH)
	return new stzCanvas(pnW, pnH)

# The pixel tiers need a device; the vector tier never does. Rather than
# make every caller remember to open one, the faces ask for it the first
# time pixels are actually wanted -- and a machine without a GPU simply
# keeps answering through SVG. Tried ONCE per process: a machine with no
# runtime must not pay the probe on every call. (The flag itself is set in
# stzColor.ring, which loads first -- a global assigned AFTER a func in a
# file becomes part of that func's body and never runs.)
func StzGraphicsDevice()
	if StzEngineGpuIsAvailable() = 1
		return TRUE
	ok
	if $bStzGraphicsDeviceTried
		return FALSE
	ok
	$bStzGraphicsDeviceTried = TRUE
	StzEngineGpuInit($cStzGpuRuntime)
	return StzEngineGpuIsAvailable() = 1

class stzCanvas from stzObject

	@nId = 0
	@nW = 0
	@nH = 0
	@nFill = 0
	@bFillNamed = FALSE
	@nStroke = 0
	@nStrokeW = 0
	@oFont = NULL
	@nFontSize = 16
	@aPending = []

	def init(pnW, pnH)
		if NOT (isNumber(pnW) and isNumber(pnH))
			StzRaise("stzCanvas: give a width and a height in pixels.")
		ok
		@nId = StzEngineGpuSceneNew(pnW, pnH)
		if @nId = 0
			StzRaise("stzCanvas: refused a " + pnW + "x" + pnH + " canvas " +
				"(sizes run from 1 to 16384).")
		ok
		@nW = pnW
		@nH = pnH
		@nFill = StzColorToNumber(:White)

	#-- identity ------------------------------------------------------------

	def Id_()
		return @nId

	def Width()
		return @nW

	def Height()
		return @nH

	def ShapeCount()
		This._Flush()
		return StzEngineGpuSceneCommandCount(@nId)

	# [ shapes, shapeVertices, textVertices, drawSegments, builds ]
	def Stats()
		This._Flush()
		return StzEngineGpuSceneStats(@nId)

	#-- canvas-wide state ---------------------------------------------------

	def SetBackground(pColor)
		StzEngineGpuSceneClear(@nId, StzColorToNumber(pColor))

	def SetBackgroundQ(pColor)
		This.SetBackground(pColor)
		return This

	def SetFont(poFont, pnSize)
		if NOT isObject(poFont)
			StzRaise("stzCanvas.SetFont: give an stzFont object.")
		ok
		if len(@aPending) > 0 and @aPending[1] = :text
			@aPending[6] = poFont
			@aPending[7] = pnSize
		else
			@oFont = poFont
			@nFontSize = pnSize
		ok

	def SetFontQ(poFont, pnSize)
		This.SetFont(poFont, pnSize)
		return This

	#-- adding shapes -------------------------------------------------------

	def AddRect(pnX, pnY, pnW, pnH)
		This._Flush()
		@aPending = [ :rect, pnX, pnY, pnW, pnH, @nFill, @nStroke, @nStrokeW, @bFillNamed ]

	def AddRectQ(pnX, pnY, pnW, pnH)
		This.AddRect(pnX, pnY, pnW, pnH)
		return This

	# A rectangle whose fill runs from one colour to another; bVertical
	# picks the axis.
	def AddGradientRect(pnX, pnY, pnW, pnH, pFrom, pTo, pbVertical)
		This._Flush()
		StzEngineGpuSceneRectGradient(@nId, pnX, pnY, pnW, pnH,
			StzColorToNumber(pFrom), StzColorToNumber(pTo), pbVertical)

	def AddGradientRectQ(pnX, pnY, pnW, pnH, pFrom, pTo, pbVertical)
		This.AddGradientRect(pnX, pnY, pnW, pnH, pFrom, pTo, pbVertical)
		return This

	def AddCircle(pnCX, pnCY, pnR)
		This._Flush()
		@aPending = [ :circle, pnCX, pnCY, pnR, 0, @nFill, @nStroke, @nStrokeW, @bFillNamed ]

	def AddCircleQ(pnCX, pnCY, pnR)
		This.AddCircle(pnCX, pnCY, pnR)
		return This

	def AddLine(pnX1, pnY1, pnX2, pnY2)
		This._Flush()
		@aPending = [ :line, pnX1, pnY1, pnX2, pnY2, @nFill, @nStroke, @nStrokeW, @bFillNamed ]

	def AddLineQ(pnX1, pnY1, pnX2, pnY2)
		This.AddLine(pnX1, pnY1, pnX2, pnY2)
		return This

	# paPoints is flat: [ x1,y1, x2,y2, ... ]
	def AddPolyline(paPoints)
		This._Flush()
		@aPending = [ :polyline, paPoints, 0, 0, 0, @nFill, @nStroke, @nStrokeW, @bFillNamed ]

	def AddPolylineQ(paPoints)
		This.AddPolyline(paPoints)
		return This

	def AddPolygon(paPoints)
		This._Flush()
		@aPending = [ :polygon, paPoints, 0, 0, 0, @nFill, @nStroke, @nStrokeW, @bFillNamed ]

	def AddPolygonQ(paPoints)
		This.AddPolygon(paPoints)
		return This

	# (pnX, pnY) is the BASELINE origin -- where the text sits, not its box.
	def AddText(pcText, pnX, pnY)
		This._Flush()
		@aPending = [ :text, pcText, pnX, pnY, @nFill, @oFont, @nFontSize ]

	def AddTextQ(pcText, pnX, pnY)
		This.AddText(pcText, pnX, pnY)
		return This

	#-- styling the last shape added ---------------------------------------

	# With a shape pending, Fill colours THAT shape. With none, it sets the
	# canvas's fill for everything added afterwards.
	#
	# Either way it NAMES the fill, and that flag is what lets a stroke-only
	# shape exist: see _Flush. A shape whose fill was never named and which
	# WAS given a stroke is an outline, not a white blob.
	def Fill(pColor)
		_n_ = StzColorToNumber(pColor)
		if len(@aPending) = 0
			@nFill = _n_
			@bFillNamed = TRUE
			return
		ok
		if @aPending[1] = :text
			@aPending[5] = _n_
		else
			@aPending[6] = _n_
			@aPending[9] = TRUE
		ok

	def FillQ(pColor)
		This.Fill(pColor)
		return This

	# Text reads better as Color(); same act.
	def Color(pColor)
		This.Fill(pColor)

	def ColorQ(pColor)
		This.Fill(pColor)
		return This

	# An outline in its own colour and width. On a filled shape it is drawn
	# ON TOP of the fill, so the two agree on the silhouette.
	def Stroke(pColor, pnWidth)
		_n_ = StzColorToNumber(pColor)
		if len(@aPending) = 0
			@nStroke = _n_
			@nStrokeW = pnWidth
			return
		ok
		if @aPending[1] = :text
			return   # text has no outline in this phase
		ok
		@aPending[7] = _n_
		@aPending[8] = pnWidth

	def StrokeQ(pColor, pnWidth)
		This.Stroke(pColor, pnWidth)
		return This

	#-- output: the two tiers of ONE model ---------------------------------

	# Vector. Needs NO device -- always available, everywhere.
	def ToSVG()
		This._Flush()
		return StzEngineGpuSceneToSvg(@nId)

	# Pixels, through the GPU. Returns the PNG bytes; pass a path to also
	# write the file. Answers "" when there is no device, and the refusal
	# is COUNTED engine-side -- so a caller can fall back to ToSVG()
	# knowing why.
	def ToPNG(pcPath)
		This._Flush()
		StzGraphicsDevice()
		_c_ = StzEngineGpuSceneToPng(@nId, 1)
		if _c_ != "" and isString(pcPath) and pcPath != ""
			write(pcPath, _c_)
		ok
		return _c_

	# Raw RGBA8 bytes of the GPU tier, for a caller that wants the pixels
	# themselves (comparisons, compositing, tests).
	def ToPixels()
		This._Flush()
		StzGraphicsDevice()
		return StzEngineGpuSceneToPixels(@nId)

	def CanDrawPixels()
		return StzGraphicsDevice()

	# The canvas as its most portable content: the SVG text.
	def Content()
		return This.ToSVG()

	# Post the pending shape by hand. Only a caller driving its own frame
	# loop needs this (stzWindow.Draw does it); every Add* and every output
	# method already calls it.
	def Flush()
		This._Flush()

	def FlushQ()
		This._Flush()
		return This

	# Empty the display list, keeping the background and the GPU buffers.
	# What an ANIMATED canvas calls at the top of each frame -- without it
	# the list grows by a frame's worth of shapes forever.
	def Clear()
		@aPending = []
		StzEngineGpuSceneReset(@nId)

	def ClearQ()
		This.Clear()
		return This

	# Put the picture in front of a person. A real WINDOW when this machine
	# has one (GR5) -- Escape or the X button closes it, and the picture
	# never touches the disk. Otherwise the old path: write a PNG (or an
	# SVG with no device) and ask the OS to open it, which is what a
	# headless box or a machine without stz_window.dll still deserves.
	# Returns the frame count when it opened a window, the file path when
	# it fell back -- so a caller can always tell which happened.
	def Show()
		This._Flush()
		if StzWindowingAvailable() and StzGraphicsDevice()
			_oW_ = new stzWindow(This.Width(), This.Height(), "Softanza Canvas")
			if _oW_.CanDraw()
				_n_ = _oW_.Show(This)
				_oW_.Free()
				return _n_
			ok
			_oW_.Free()
		ok

		_cPath_ = "stzcanvas_show.png"
		_c_ = This.ToPNG(_cPath_)
		if _c_ = ""
			_cPath_ = "stzcanvas_show.svg"
			write(_cPath_, This.ToSVG())
		ok
		if isWindows()
			system('start "" "' + _cPath_ + '"')
		but isMacOS()
			system('open "' + _cPath_ + '"')
		else
			system('xdg-open "' + _cPath_ + '" >/dev/null 2>&1 &')
		ok
		return _cPath_

	def Free()
		if @nId > 0
			StzEngineGpuSceneFree(@nId)
			@nId = 0
		ok

	#-- the pending shape ---------------------------------------------------

	# Post the remembered shape to the engine's display list. Called by the
	# next Add* and by every output method, so a caller never has to think
	# about it.
	def _Flush()
		if len(@aPending) = 0
			return
		ok
		_a_ = @aPending
		@aPending = []     # cleared FIRST: a raise below must not re-post

		# STROKE-ONLY IS A SHAPE. A caller who names a stroke and never names
		# a fill means an outline -- so the canvas's implicit starting fill
		# (white) does not get painted underneath it. Without this, every
		# `.Stroke(c, w)` chain drew a white blob with a coloured edge, which
		# is what a whole scene of concentric outlines looked like the first
		# time one was drawn.
		#
		# A fill NAMED anywhere -- on this shape, or as the canvas default --
		# still wins: `.Fill(a).Stroke(b, w)` is filled AND outlined, and
		# setting a canvas fill then stroking still fills. Only the fill
		# nobody asked for steps aside.
		if len(_a_) >= 9 and _a_[9] = FALSE and _a_[8] > 0
			_a_[6] = 0        # transparent
		ok

		switch "" + _a_[1]
		on "rect"
			StzEngineGpuSceneRect(@nId, _a_[2], _a_[3], _a_[4], _a_[5], _a_[6])
			if _a_[8] > 0
				This._StrokePolygon([ _a_[2], _a_[3],
					_a_[2]+_a_[4], _a_[3],
					_a_[2]+_a_[4], _a_[3]+_a_[5],
					_a_[2], _a_[3]+_a_[5] ], _a_[7], _a_[8])
			ok
		on "circle"
			StzEngineGpuSceneCircle(@nId, _a_[2], _a_[3], _a_[4], _a_[6])
			if _a_[8] > 0
				This._StrokePolygon(This._CirclePoints(_a_[2], _a_[3], _a_[4]),
					_a_[7], _a_[8])
			ok
		on "line"
			_nCol_ = _a_[6]
			_nWid_ = 1
			if _a_[8] > 0
				_nCol_ = _a_[7]
				_nWid_ = _a_[8]
			ok
			StzEngineGpuSceneLine(@nId, _a_[2], _a_[3], _a_[4], _a_[5], _nWid_, _nCol_)
		on "polyline"
			_nCol_ = _a_[6]
			_nWid_ = 1
			if _a_[8] > 0
				_nCol_ = _a_[7]
				_nWid_ = _a_[8]
			ok
			StzEngineGpuScenePolyline(@nId, _a_[2], _nWid_, _nCol_)
		on "polygon"
			StzEngineGpuScenePolygon(@nId, _a_[2], _a_[6])
			if _a_[8] > 0
				This._StrokePolygon(_a_[2], _a_[7], _a_[8])
			ok
		on "text"
			if NOT isObject(_a_[6])
				StzRaise("stzCanvas: AddText needs a font -- call " +
					"SetFont(oFont, nSize) first, or SetFontQ() in the chain.")
			ok
			StzEngineGpuSceneText(@nId, _a_[6].Id_(), _a_[2], _a_[3], _a_[4],
				_a_[7], _a_[5])
		off

	# Close a point ring and stroke it, so an outline meets its own start.
	def _StrokePolygon(paPoints, pnColor, pnWidth)
		_a_ = paPoints
		_n_ = len(_a_)
		if _n_ < 4
			return
		ok
		_a_ + _a_[1]
		_a_ + _a_[2]
		StzEngineGpuScenePolyline(@nId, _a_, pnWidth, pnColor)

	# The SAME segment count the engine's tessellator uses, so a stroked
	# circle traces exactly the filled one rather than almost tracing it.
	def _CirclePoints(pnCX, pnCY, pnR)
		_nSeg_ = StzEngineGpuCircleSegments(pnR)
		_a_ = []
		for _i_ = 0 to _nSeg_ - 1
			_t_ = 2 * 3.141592653589793 * _i_ / _nSeg_
			_a_ + (pnCX + pnR * cos(_t_))
			_a_ + (pnCY + pnR * sin(_t_))
		next
		return _a_
