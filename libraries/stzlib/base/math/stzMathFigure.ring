#=====================================================================#
#  STZMATHFIGURE -- the entry object of base/math/: a figure is a      #
#  KIND, a DECLARATION, and the picture the diagram engine solves      #
#=====================================================================#
/*
	LAW 1 of the intelligence architecture: a domain is a folder, an
	entry object and a format. The folder is base/math/; this is the
	entry object; the format, .zfig, comes with the first figure that is
	saved. A figure is DECLARED (a kind and its keys), COMPUTED (the
	engine samples it), then SOLVED (the diagram engine places every
	name), and it answers for itself: Why(), IsSolved(), Violations(),
	Fact(), the renditions every mathematical diagram carries.

	    oF = StzMathFigureQ(:Function, [ :f = "sin(x) / x", :on = [ -12, 12 ],
	                                     :mark = [ :zeros, :extrema ] ])
	    ? oF.Why()
	    cSvg = oF.ToSVG()          # no device needed
	    oF.ToPNG("sinc.png")       # a device needed

	ONE KIND SHIPS WITH M1a, :Function, whose parametric and polar forms
	are keys of the same declaration (stzFunctionFigure.ring). The kinds
	the charter plans -- :Surface, :ComplexPlane, :BoxPlot, :NumberLine,
	:Fraction, :Matrix -- enter this list as their files land, and a kind
	not on the list is refused by name with the list.

	THE FONT: a figure measures its names to place them, so it wants a
	font; the house one is found on the machine once per process, and a
	figure without any font still solves its geometry and draws no text,
	which is the diagram engine's own rule.
*/

$oStzMathFigureFont = NULL
$bStzMathFigureFontLooked = FALSE

# the font every figure measures and draws with, found once; NULL when
# the machine has none of the candidates, and then no text is drawn
func StzMathFigureFont()
	if $bStzMathFigureFontLooked  return $oStzMathFigureFont  ok
	$bStzMathFigureFontLooked = TRUE
	_ac_ = [ "C:/Windows/Fonts/segoeui.ttf", "C:/Windows/Fonts/arial.ttf",
	         "/usr/share/fonts/truetype/dejavu/DejaVuSans.ttf" ]
	for _i_ = 1 to len(_ac_)
		if fexists(_ac_[_i_])
			$oStzMathFigureFont = new stzFont(_ac_[_i_])
			return $oStzMathFigureFont
		ok
	next
	return NULL

func StzMathFigureKinds()
	return [ "function", "numberline", "fraction", "matrix", "complexplane" ]

func StzMathFigureQ(pcKind, paSpec)
	return new stzMathFigure(pcKind, paSpec)

class stzMathFigure from stzObject

	@cKind = ""
	@aSpec = []
	@oDiagram = NULL
	@oFont = NULL

	def init(pcKind, paSpec)
		_k_ = StzLower(ring_trim("" + pcKind))
		if NOT _FfIn(StzMathFigureKinds(), _k_)
			stzraise("stzMathFigure: '" + pcKind + "' is not a figure kind this plane draws -- " +
				"the kinds are " + @@(StzMathFigureKinds()) + ".")
		ok
		if NOT isList(paSpec) or ring_len(paSpec) = 0
			stzraise("stzMathFigure: a figure is declared as keys, like " +
				"[ :f = 'sin(x)', :on = [ -6, 6 ] ].")
		ok
		@cKind = _k_
		@aSpec = paSpec
		@oFont = StzMathFigureFont()
		This._Build()

	def _Build()
		if @cKind = "function"
			@oDiagram = StzFunctionFigureBuildXT(@oFont, @aSpec)
		but @cKind = "numberline"
			@oDiagram = StzNumberLineFigureBuildXT(@oFont, @aSpec)
		but @cKind = "fraction"
			@oDiagram = StzFractionFigureBuildXT(@oFont, @aSpec)
		but @cKind = "matrix"
			@oDiagram = StzMatrixFigureBuildXT(@oFont, @aSpec)
		but @cKind = "complexplane"
			@oDiagram = StzComplexPlaneFigureBuildXT(@oFont, @aSpec)
		ok

	#-- what it is ------------------------------------------------------------

	def Kind()
		return @cKind

	def Spec()
		return @aSpec

	# the solved picture itself: an stzMathDiagram, with everything one
	# can answer -- ShapeOf, Fact, Violations, the renditions
	def Diagram()
		return @oDiagram

	def Substance()
		return @oDiagram.Substance()

	def SetFont(poFont, pnSize)
		@oFont = poFont
		@oDiagram.SetFont(poFont, pnSize)
		return This

		def SetFontQ(poFont, pnSize)
			return This.SetFont(poFont, pnSize)

	#-- the solve ------------------------------------------------------------

	def Layout()
		@oDiagram.Layout()
		return This

		def LayoutQ()
			return This.Layout()

	def IsSolved()
		return @oDiagram.IsFeasible()

	def Violations()
		return @oDiagram.Violations()

	def LayoutMs()
		return @oDiagram.LayoutMs()

	# what was computed and what was solved, in one sentence each: the
	# computed half is the domain file's sentence, the solved half the
	# diagram's own
	def Why()
		_oS_ = @oDiagram.Substance()
		if @cKind = "numberline"
			return StzNumberLineFigureWhy(_oS_) + "; " + @oDiagram.Why()
		but @cKind = "fraction"
			return StzFractionFigureWhy(_oS_) + "; " + @oDiagram.Why()
		but @cKind = "matrix"
			return StzMatrixFigureWhy(_oS_) + "; " + @oDiagram.Why()
		but @cKind = "complexplane"
			return StzComplexPlaneFigureWhy(_oS_) + "; " + @oDiagram.Why()
		ok
		_c_ = "a " + @cKind + " figure: " + _oS_.DataOf("fr", "samples") + " samples in " +
			_oS_.DataOf("fr", "pieces") + " piece(s), " + _oS_.DataOf("fr", "marks") + " mark(s)"
		if _oS_.DataOf("fr", "marksleft") > 0
			_c_ += " (" + _oS_.DataOf("fr", "marksleft") + " more not named, past :maxmarks)"
		ok
		if _oS_.DataOf("fr", "poles") > 0
			_c_ += ", " + _oS_.DataOf("fr", "poles") + " place(s) not finite"
		ok
		if _oS_.DataOf("fr", "clipped") = 1
			_c_ += ", clipped to the window"
		ok
		return _c_ + "; " + @oDiagram.Why()

	#-- the computed half, read back ------------------------------------------

	# the readers below are the :Function figure's; another kind is told so
	def _RequireKind(pcKind, pcWhat)
		if @cKind != pcKind
			stzraise("stzMathFigure." + pcWhat + ": a " + @cKind + " figure has no " + pcWhat +
				" -- that is a " + pcKind + " figure's question.")
		ok

	def SampleCount()
		This._RequireKind("function", "SampleCount")
		return @oDiagram.Substance().DataOf("fr", "samples")

	def PieceCount()
		This._RequireKind("function", "PieceCount")
		return @oDiagram.Substance().DataOf("fr", "pieces")

	# the polylines drawn: a piece longer than 64 samples is several runs
	def RunCount()
		This._RequireKind("function", "RunCount")
		return @oDiagram.Substance().DataOf("fr", "runs")

	# the window in the author's units: [ xmin, xmax, ymin, ymax ]
	def Window()
		This._RequireKind("function", "Window")
		_oS_ = @oDiagram.Substance()
		return [ _oS_.DataOf("fr", "xmin"), _oS_.DataOf("fr", "xmax"),
		         _oS_.DataOf("fr", "ymin"), _oS_.DataOf("fr", "ymax") ]

	# every mark as [ kind, x, y ] -- "zero", "extremum" or "given"
	def Marks()
		This._RequireKind("function", "Marks")
		_oS_ = @oDiagram.Substance()
		_a_ = []
		_ac_ = _oS_.ObjectsOfType("Mark")
		_n_ = ring_len(_ac_)
		for _i_ = 1 to _n_
			_k_ = "given"
			if _oS_.Holds("Zero", [ _ac_[_i_] ])
				_k_ = "zero"
			but _oS_.Holds("Extremum", [ _ac_[_i_] ])
				_k_ = "extremum"
			ok
			_a_ + [ _k_, _oS_.DataOf(_ac_[_i_], "x"), _oS_.DataOf(_ac_[_i_], "y") ]
		next
		return _a_

	def Zeros()
		return This._MarksOf("zero")

	def Extrema()
		return This._MarksOf("extremum")

	def _MarksOf(pcKind)
		_a_ = []
		_aM_ = This.Marks()
		_n_ = ring_len(_aM_)
		for _i_ = 1 to _n_
			if _aM_[_i_][1] = pcKind  _a_ + [ _aM_[_i_][2], _aM_[_i_][3] ]  ok
		next
		return _a_

	#-- the live figure, and a datum changed in place -------------------------

	# RING HANDS BACK A COPY when a method returns an object, so anything
	# that must change THIS figure's picture goes through here, never
	# through Diagram() -- a witness that tampered a copy found nothing.
	def SetDatum(pcObject, pcKey, pnValue)
		@oDiagram.SetSubstanceData(pcObject, pcKey, pnValue)
		return This

	# a shape whose centre a rule left free is pinned or dragged by the
	# diagram's own gesture; a NOTE is not such a shape -- see MoveNoteTo
	def Pin(pcPath)
		@oDiagram.Pin(pcPath)
		return This

	def Unpin(pcPath)
		@oDiagram.Unpin(pcPath)
		return This

	def DragTo(pcPath, pnX, pnY)
		@oDiagram.DragTo(pcPath, pnX, pnY)
		return This

	# A NOTE IS MOVED BY ITS OFFSETS. Its place is derived from its mark
	# plus two unknowns, n.ox and n.oy (the free side is the mark's datum),
	# which is what lets every note start inside its leash; a drag by shape
	# (DragTo) wants a free centre and refuses it. This writes the two
	# slots, holds them, and re-solves the rest of the figure around them.
	def MoveNoteTo(pcNote, pnX, pnY)
		This.Layout()
		_cN_ = ring_trim("" + pcNote)
		_oS_ = @oDiagram.Substance()
		_cM_ = ""
		_aD_ = _oS_.Definitions()
		_n_ = ring_len(_aD_)
		for _i_ = 1 to _n_
			if _aD_[_i_][1] = _cN_ and _aD_[_i_][2] = "Note"  _cM_ = "" + _aD_[_i_][3][1]  ok
		next
		if _cM_ = ""
			stzraise("stzMathFigure.MoveNoteTo: '" + _cN_ + "' is not a note of this figure.")
		ok
		_ix_ = @oDiagram._UnknownIndex(_cN_ + ".ox")
		_iy_ = @oDiagram._UnknownIndex(_cN_ + ".oy")
		if _ix_ = 0 or _iy_ = 0
			stzraise("stzMathFigure.MoveNoteTo: '" + _cN_ + "' has no offsets the solver owns.")
		ok
		_nSide_ = _oS_.DataOf(_cM_, "side")
		@oDiagram.@aValue[_ix_] = pnX - _oS_.DataOf(_cM_, "px")
		@oDiagram.@aValue[_iy_] = (pnY - _oS_.DataOf(_cM_, "py")) / _nSide_
		@oDiagram.@aPinned[_ix_] = 1
		@oDiagram.@aPinned[_iy_] = 1
		@oDiagram.Relayout()
		return This

	def ReleaseNote(pcNote)
		_cN_ = ring_trim("" + pcNote)
		_ix_ = @oDiagram._UnknownIndex(_cN_ + ".ox")
		_iy_ = @oDiagram._UnknownIndex(_cN_ + ".oy")
		if _ix_ > 0  @oDiagram.@aPinned[_ix_] = 0  ok
		if _iy_ > 0  @oDiagram.@aPinned[_iy_] = 0  ok
		return This

	def Relayout()
		@oDiagram.Relayout()
		return This

	#-- the renditions ----------------------------------------------------------

	def ToSVG()
		return @oDiagram.ToSVG()

	def ToPNG(pcPath)
		return @oDiagram.ToPNG(pcPath)

	def Rendition()
		return @oDiagram.Rendition()

	def RenditionAs(pcKind)
		return @oDiagram.RenditionAs(pcKind)

	def Fact(pcKind, paArgs)
		return @oDiagram.Fact(pcKind, paArgs)

	def ShapeOf(pcPath)
		return @oDiagram.ShapeOf(pcPath)

	def Show()
		? This.Why()
		return This
