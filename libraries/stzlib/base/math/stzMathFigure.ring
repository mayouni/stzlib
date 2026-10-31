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
	return [ "function", "numberline", "fraction", "matrix", "complexplane", "boxplot", "surface", "stemplot", "residualplot", "codedtable" ]

func StzMathFigureQ(pcKind, paSpec)
	return new stzMathFigure(pcKind, paSpec)

# Declares a mathematical figure by its kind and keys, solves its picture, and answers for it: its sentence, its facts, its SVG and PNG.
#
# A figure is declared (a kind such as function, numberline, fraction, matrix, complexplane,
# boxplot, surface, stemplot, residualplot or codedtable, and its keys), computed (the engine
# samples or tabulates it), then solved (the diagram engine places every name). It is already solved
# when built. Ring hands back a copy of any object a method returns, so Diagram and Substance are
# copies: change the figure through SetTheme and SetDatum, never through them. The readers for
# samples, pieces, window and marks belong to the function kind only.
#
#   receiver   o1 = new stzMathFigure(:Function, [ :f = "x * x", :on = [ -2, 2 ] ])
#   example    ? o1.SampleCount()
#              #--> 400
#   see        stzMathDiagram, stzMathSubstance, stzDiagram
class stzMathFigure from stzObject

	@cKind = ""
	@aSpec = []
	@oDiagram = NULL
	@oFont = NULL

	# Builds and solves a figure from its kind and its declaration; an unknown kind, or an empty or non-list declaration, raises an error.
	#
	#   pcKind     The figure kind, as text, case ignored: function, numberline, fraction, matrix,
	#              complexplane, boxplot, surface, stemplot, residualplot or codedtable
	#   paSpec     The declaration, a list of key = value pairs whose keys depend on the kind, such
	#              as [ :f = "sin(x)", :on = [ -6, 6 ] ]
	#   returns    nothing; the figure is built
	#   note       StzMathFigureQ(kind, spec) builds the same object
	#   warning    the figure is already solved when init returns
	#   see        Kind, Spec, Layout
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
		but @cKind = "boxplot"
			@oDiagram = StzBoxPlotFigureBuildXT(@oFont, @aSpec)
		but @cKind = "surface"
			@oDiagram = StzSurfaceFigureBuildXT(@oFont, @aSpec)
		but @cKind = "stemplot"
			@oDiagram = StzStemPlotFigureBuildXT(@oFont, @aSpec)
		but @cKind = "residualplot"
			@oDiagram = StzResidualPlotFigureBuildXT(@oFont, @aSpec)
		but @cKind = "codedtable"
			@oDiagram = StzCodedTableFigureBuildXT(@oFont, @aSpec)
		ok

	# Returns the figure kind in lowercase, such as function or boxplot.
	#
	#   returns    text
	#   see        Spec, init
	#@ aka  -- what it is ------------------------------------------------------------
	def Kind()
		return @cKind

	# Returns the declaration the figure was built from, exactly as given.
	#
	#   returns    a list of key = value pairs
	#   see        Kind, SetDatum
	def Spec()
		return @aSpec

	# Returns the solved picture, a stzMathDiagram, as a copy.
	#
	#   returns    a stzMathDiagram
	#   warning    the copy is detached: a theme or a datum set on it never reaches the figure, so
	#              change the figure itself through SetTheme and SetDatum
	#   see        Substance, SetTheme, SetDatum
	#@ aka  the solved picture itself: an stzMathDiagram, with everything one can answer -- ShapeOf, Fact, Violations, the renditions. IT IS A COPY: Ring copies an object a method returns, so a theme or a datum set on it never reaches the figure's own picture. Set the theme and the data THROUGH the figure (SetTheme, SetDatum); found 2026-09-26 when 32 catalogue pictures rendered "dark" came out byte-identical
	def Diagram()
		return @oDiagram

	# Chooses the colour theme the figure is drawn in, with no second solve; the figure is returned so calls can be chained.
	#
	#   pcTheme    A theme name, as text, such as light, dark, vibrant, pro, access, print or gray
	#   returns    the figure itself
	#   note       SetThemeQ is the same call
	#   warning    the name is stored lowercased without a check: an unknown name raises a stzColor
	#              error when the figure is next drawn, and the figure stays on it until a valid
	#              theme is set
	#   see        Diagram, ToSVG
	#@ aka  the theme, on the figure's OWN picture: no second solve, a theme changes only what every role resolves to
	def SetTheme(pcTheme)
		@oDiagram.SetPictureTheme(pcTheme)
		return This

		def SetThemeQ(pcTheme)
			return This.SetTheme(pcTheme)

	# Returns the content behind the picture, a stzMathSubstance, as a copy: its objects, data and definitions.
	#
	#   returns    a stzMathSubstance
	#   see        Diagram, Fact
	def Substance()
		return @oDiagram.Substance()

	# Gives the figure a font and size to measure and draw its names with, so the next solve places them again; the figure is returned.
	#
	#   poFont     The stzFont to measure and draw names with
	#   pnSize     The font size, as a number
	#   returns    the figure itself
	#   note       SetFontQ is the same call
	#   warning    without a font the geometry is solved and no text is drawn
	#   see        Layout, ToSVG
	def SetFont(poFont, pnSize)
		@oFont = poFont
		@oDiagram.SetFont(poFont, pnSize)
		return This

		def SetFontQ(poFont, pnSize)
			return This.SetFont(poFont, pnSize)

	# Solves the figure if it is not solved yet, then returns the figure; a figure is already solved when built.
	#
	#   returns    the figure itself
	#   warning    LayoutQ is the same call
	#   see        Relayout, IsSolved
	#@ aka  -- the solve ------------------------------------------------------------
	def Layout()
		@oDiagram.Layout()
		return This

		def LayoutQ()
			return This.Layout()

	# TRUE if every constraint of the figure holds after the solve.
	#
	#   returns    TRUE or FALSE (1 or 0)
	#   see        Violations, Why
	def IsSolved()
		return @oDiagram.IsFeasible()

	# Returns the constraints the solve could not satisfy, each with the rule and a message; [ ] when the figure is lawful.
	#
	#   returns    a list of hash lists [ :rule, :message ]; [ ] when none
	#   see        IsSolved, Why
	def Violations()
		return @oDiagram.Violations()

	# Returns how long the last solve took, in milliseconds.
	#
	#   returns    a number
	#   see        Layout, Relayout
	def LayoutMs()
		return @oDiagram.LayoutMs()

	# Returns one sentence saying what was computed (samples, marks, quartiles...) and one saying how the solve went.
	#
	#   returns    text
	#   warning    the first half is written by the figure kind, the second by the diagram
	#   see        Violations, Show
	#@ aka  what was computed and what was solved, in one sentence each: the computed half is the domain file's sentence, the solved half the diagram's own
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
		but @cKind = "boxplot"
			return StzBoxPlotFigureWhy(_oS_) + "; " + @oDiagram.Why()
		but @cKind = "surface"
			return StzSurfaceFigureWhy(_oS_) + "; " + @oDiagram.Why()
		but @cKind = "stemplot"
			return StzStemPlotFigureWhy(_oS_) + "; " + @oDiagram.Why()
		but @cKind = "residualplot"
			return StzResidualPlotFigureWhy(_oS_) + "; " + @oDiagram.Why()
		but @cKind = "codedtable"
			return StzCodedTableFigureWhy(_oS_) + "; " + @oDiagram.Why()
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

	# Returns how many points were sampled from the function; raises an error on any other figure kind.
	#
	#   returns    a number
	#   warning    a function figure only: the other kinds raise an error naming the question
	#   see        PieceCount, RunCount
	def SampleCount()
		This._RequireKind("function", "SampleCount")
		return @oDiagram.Substance().DataOf("fr", "samples")

	# Returns into how many unbroken pieces the curve falls, cut where it is not finite or leaves the window; raises an error on any other kind.
	#
	#   returns    a number
	#   warning    a function figure only; a piece of a single sample is dropped
	#   see        SampleCount, RunCount
	def PieceCount()
		This._RequireKind("function", "PieceCount")
		return @oDiagram.Substance().DataOf("fr", "pieces")

	# Returns how many polylines draw the curve, since a piece of more than 64 samples is several runs; raises an error on any other kind.
	#
	#   returns    a number
	#   warning    a function figure only; a figure under a live motion draws no curve and answers 0
	#   see        PieceCount, SampleCount
	#@ aka  the polylines drawn: a piece longer than 64 samples is several runs
	def RunCount()
		This._RequireKind("function", "RunCount")
		return @oDiagram.Substance().DataOf("fr", "runs")

	# Returns the visible window in the author's own units; raises an error on any other figure kind.
	#
	#   returns    a list [ xmin, xmax, ymin, ymax ]
	#   warning    a function figure only
	#   see        Marks, SampleCount
	#@ aka  the window in the author's units: [ xmin, xmax, ymin, ymax ]
	def Window()
		This._RequireKind("function", "Window")
		_oS_ = @oDiagram.Substance()
		return [ _oS_.DataOf("fr", "xmin"), _oS_.DataOf("fr", "xmax"),
		         _oS_.DataOf("fr", "ymin"), _oS_.DataOf("fr", "ymax") ]

	# Returns every named mark of a function figure, each as [ kind, x, y ], where kind is zero, extremum or given.
	#
	#   returns    a list of [ kind, x, y ] triples
	#   warning    a function figure only; marks past the maxmarks limit are counted by Why but not
	#              listed
	#   see        Zeros, Extrema
	#@ aka  every mark as [ kind, x, y ] -- "zero", "extremum" or "given"
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

	# Returns the [ x, y ] position of every zero of the function that was marked.
	#
	#   returns    a list of [ x, y ] pairs
	#   warning    a function figure only, and only when the declaration asks for :zeros in :mark
	#   see        Marks, Extrema
	def Zeros()
		return This._MarksOf("zero")

	# Returns the [ x, y ] position of every extremum of the function that was marked.
	#
	#   returns    a list of [ x, y ] pairs
	#   warning    a function figure only, and only when the declaration asks for :extrema in :mark
	#   see        Marks, Zeros
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

	# Changes one number held by the content, such as a frame limit, then marks the figure to be solved again; the figure is returned.
	#
	#   pcObject   The name of a content object, such as fr for the frame
	#   pcKey      The datum to change, as text
	#   pnValue    The new value, as a number
	#   returns    the figure itself
	#   note       the number read back by Fact with :datum
	#   warning    the object and key are not checked; only the solved half is redone, so the
	#              sampled curve is not recomputed
	#   see        Fact, Spec
	#@ aka  -- the live figure, and a datum changed in place -------------------------
	def SetDatum(pcObject, pcKey, pnValue)
		@oDiagram.SetSubstanceData(pcObject, pcKey, pnValue)
		return This

	# Holds a note where it is during later solves; a shape is already held by the rules, so it is left as it is.
	#
	#   pcPath     The name of a note, such as n1, or the path of a shape, such as fr.box
	#   returns    the figure itself
	#   note       a note named by the path of its text, such as n1.text, is held the same way
	#   warning    a path that names neither a note nor a shape raises an error listing the first ten
	#              valid paths; the text is only looked up, never evaluated
	#   see        Unpin, DragTo, MoveNoteTo
	#@ aka  WHAT A MATH FIGURE CAN HOLD. Every shape of a figure is placed by the figure's own rules -- the axes, the curve, the bars -- so there is no free position to hold, and holding one in a different place would falsify the mathematics (swept on one figure of each of the ten kinds: not one shape has a free value). A shape is therefore already held, and this leaves it alone. What the solver does own, on a function, number line, complex plane or box plot figure, is a NOTE's two offsets from its mark, n.ox and n.oy: this holds them at their present values, the way MoveNoteTo does after it moves a note. A note a rule places outright (a fraction or residual plot figure) has no offsets and is held already, so it is left alone too.
	def Pin(pcPath)
		_c_ = This._PathText("Pin", pcPath)
		_cNote_ = This._NoteOfPath(_c_)
		if _cNote_ != ""
			This._HoldNote(_cNote_)
		but NOT This._IsShapePath(_c_)
			This._RaiseUnknownPath("Pin", _c_)
		ok
		return This

	# Lets a note held by Pin or MoveNoteTo move again in later solves; a shape or an unknown path is ignored.
	#
	#   pcPath     The name of a note, such as n1, or the path of a shape
	#   returns    the figure itself
	#   note       it is ReleaseNote for a note named by its text path too, such as n1.text
	#   warning    the note stays where it was until Relayout runs; a shape is never held by a pin, so
	#              it changes nothing
	#   see        Pin, ReleaseNote, IsPinned
	def Unpin(pcPath)
		_c_ = ""
		if isString(pcPath)
			_c_ = ring_trim(pcPath)
		ok
		_cNote_ = This._NoteOfPath(_c_)
		if _cNote_ != ""
			This.ReleaseNote(_cNote_)
		ok
		return This

	# TRUE if the path names a note held in place by a pin or by MoveNoteTo, FALSE for a free note, a shape or an unknown path.
	#
	#   pcPath     The name of a note, such as n1, or the path of a shape
	#   returns    TRUE or FALSE (1 or 0)
	#   warning    a shape is held by the rules of the figure, not by a pin, so the answer is FALSE
	#   see        Pin, Unpin, MoveNoteTo
	def IsPinned(pcPath)
		_c_ = ""
		if isString(pcPath)
			_c_ = ring_trim(pcPath)
		ok
		_cNote_ = This._NoteOfPath(_c_)
		if _cNote_ = ""
			return FALSE
		ok
		_ix_ = @oDiagram._UnknownIndex(_cNote_ + ".ox")
		_iy_ = @oDiagram._UnknownIndex(_cNote_ + ".oy")
		if _ix_ = 0 or _iy_ = 0
			return FALSE
		ok
		if @oDiagram.@aPinned[_ix_] = 1 and @oDiagram.@aPinned[_iy_] = 1
			return TRUE
		ok
		return FALSE

	# Moves a note's centre to a pixel position and re-solves around it; a shape raises an error, since the rules fix it.
	#
	#   pcPath     The name of a note, such as n1, or the path of a shape
	#   pnX        The new x of the note's centre, in pixels
	#   pnY        The new y of the note's centre, in pixels
	#   returns    the figure itself
	#   note       a note is moved exactly as MoveNoteTo moves it, and held there until ReleaseNote
	#   warning    a shape raises an error saying the rules fix it, since a drag would falsify the
	#              figure; a path that is neither a note nor a shape raises an error listing the first
	#              ten valid paths
	#   see        MoveNoteTo, Pin
	#@ aka  A DRAG NEEDS A FREE CENTRE, and no shape of a math figure has one: its place is the figure's own rule (a sine curve passes through its samples, a bar ends where its fraction does). So a shape is refused by name, with the way out; a NOTE is the one thing a drag can move, and this is MoveNoteTo under the name a pointer gesture uses.
	def DragTo(pcPath, pnX, pnY)
		_c_ = This._PathText("DragTo", pcPath)
		_cNote_ = This._NoteOfPath(_c_)
		if _cNote_ != "" and This._NoteIsFree(_cNote_)
			if NOT isNumber(pnX) or NOT isNumber(pnY)
				stzraise("stzMathFigure.DragTo: the new position of '" + _c_ + "' is two numbers, x and y.")
			ok
			This.MoveNoteTo(_cNote_, pnX, pnY)
		but _cNote_ != ""
			stzraise("stzMathFigure.DragTo: the rules of this " + @cKind + " figure fix the note '" + _cNote_ +
				"' -- it has no offsets to move, so it stays where they place it.")
		but This._IsShapePath(_c_)
			stzraise("stzMathFigure.DragTo: the rules of this " + @cKind + " figure fix '" + _c_ +
				"', so it cannot be dragged without falsifying the figure -- a note can be moved with MoveNoteTo.")
		else
			This._RaiseUnknownPath("DragTo", _c_)
		ok
		return This

	# the path as trimmed text; anything but text is refused by name
	def _PathText(pcWho, pPath)
		if NOT isString(pPath)
			stzraise("stzMathFigure." + pcWho + ": a path is text, such as 'n1' or 'fr.box'.")
		ok
		return ring_trim(pPath)

	# the name of the note a path stands for -- the note itself, or one of its shapes such as n1.text -- or "" when it stands for none
	def _NoteOfPath(pcPath)
		This.Layout()
		_cL_ = StzLower(pcPath)
		_aD_ = @oDiagram.Substance().Definitions()
		_n_ = ring_len(_aD_)
		for _i_ = 1 to _n_
			if _aD_[_i_][2] = "Note"
				_cN_ = StzLower("" + _aD_[_i_][1])
				if _cL_ = _cN_
					return "" + _aD_[_i_][1]
				ok
				if left(_cL_, ring_len(_cN_) + 1) = (_cN_ + ".") and @oDiagram._ShapeIndex(pcPath) > 0
					return "" + _aD_[_i_][1]
				ok
			ok
		next
		return ""

	def _IsShapePath(pcPath)
		return @oDiagram._ShapeIndex(pcPath) > 0

	# does the solver own this note's two offsets? A note placed outright by a rule has none
	def _NoteIsFree(pcNote)
		return @oDiagram._UnknownIndex(pcNote + ".ox") > 0 and @oDiagram._UnknownIndex(pcNote + ".oy") > 0

	# holds a note's two offsets where they are; a note with none is held by its rule already
	def _HoldNote(pcNote)
		if This._NoteIsFree(pcNote)
			@oDiagram.@aPinned[@oDiagram._UnknownIndex(pcNote + ".ox")] = 1
			@oDiagram.@aPinned[@oDiagram._UnknownIndex(pcNote + ".oy")] = 1
		ok

	# puts a note's centre at a pixel position when its mark carries no px, py and side: the offsets are
	# moved by how far the centre is from the position, and the vertical sign is read off by a trial
	def _SetNoteOffsets(pcNote, pix, piy, pnX, pnY)
		_cT_ = pcNote + ".text"
		_nOx_ = @oDiagram.ValueOf(pcNote + ".ox")
		_nOy_ = @oDiagram.ValueOf(pcNote + ".oy")
		_nCx_ = @oDiagram.ValueOf(_cT_ + ".cx")
		_nCy_ = @oDiagram.ValueOf(_cT_ + ".cy")
		@oDiagram.@aValue[piy] = _nOy_ + 1
		@oDiagram.Touch()
		_nStep_ = @oDiagram.ValueOf(_cT_ + ".cy") - _nCy_
		@oDiagram.@aValue[piy] = _nOy_
		@oDiagram.Touch()
		if _nStep_ = 0
			stzraise("stzMathFigure.MoveNoteTo: '" + pcNote + "' does not answer to its offsets.")
		ok
		@oDiagram.@aValue[pix] = _nOx_ + (pnX - _nCx_)
		@oDiagram.@aValue[piy] = _nOy_ + (pnY - _nCy_) / _nStep_

	# the notes first, then the shapes, the first ten of them, in the error of a path the figure does not know
	def _RaiseUnknownPath(pcWho, pcPath)
		_ac_ = []
		_aD_ = @oDiagram.Substance().Definitions()
		_n_ = ring_len(_aD_)
		for _i_ = 1 to _n_
			if _aD_[_i_][2] = "Note"  _ac_ + ("" + _aD_[_i_][1])  ok
		next
		_acS_ = @oDiagram.Shapes()
		_n_ = ring_len(_acS_)
		for _i_ = 1 to _n_
			_ac_ + _acS_[_i_]
		next
		_nAll_ = ring_len(_ac_)
		_nShow_ = _nAll_
		if _nShow_ > 10  _nShow_ = 10  ok
		_cList_ = ""
		for _i_ = 1 to _nShow_
			if _i_ > 1  _cList_ += ", "  ok
			_cList_ += _ac_[_i_]
		next
		_cHow_ = "the valid paths are "
		if _nAll_ > _nShow_
			_cHow_ = "there are " + _nAll_ + " valid paths, the first " + _nShow_ + " are "
		ok
		stzraise("stzMathFigure." + pcWho + ": '" + pcPath + "' is neither a note nor a shape of this " +
			@cKind + " figure -- " + _cHow_ + _cList_ + ".")

	# Puts a note's centre at a pixel position, holds it there, and re-solves the rest of the figure around it; the figure is returned.
	#
	#   pcNote     The name of a note of the figure, such as n1
	#   pnX        The x of the note's centre, in pixels
	#   pnY        The y of the note's centre, in pixels
	#   returns    the figure itself
	#   note       the hold lasts until ReleaseNote
	#   warning    an unknown note raises an error, and so does a note a rule places outright, such as
	#              those of a fraction or residual plot figure; the figure is solved first
	#   see        ReleaseNote, Relayout
	#@ aka  A NOTE IS MOVED BY ITS OFFSETS. Its place is derived from its mark plus two unknowns, n.ox and n.oy (the free side is the mark's datum), which is what lets every note start inside its leash; a drag by shape wants a free centre and no shape has one, so DragTo on a note comes here and on a shape is refused. This writes the two slots, holds them, and re-solves the rest of the figure around them.
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
		if _oS_.HasData(_cM_, "px") and _oS_.HasData(_cM_, "py") and _oS_.HasData(_cM_, "side")
			_nSide_ = _oS_.DataOf(_cM_, "side")
			@oDiagram.@aValue[_ix_] = pnX - _oS_.DataOf(_cM_, "px")
			@oDiagram.@aValue[_iy_] = (pnY - _oS_.DataOf(_cM_, "py")) / _nSide_
		else
			This._SetNoteOffsets(_cN_, _ix_, _iy_, pnX, pnY)
		ok
		@oDiagram.@aPinned[_ix_] = 1
		@oDiagram.@aPinned[_iy_] = 1
		@oDiagram.Relayout()
		return This

	# Lets go of a note held by MoveNoteTo, so the next solve may place it again; the figure is returned.
	#
	#   pcNote     The name of a note of the figure, such as n1
	#   returns    the figure itself
	#   warning    the note stays where it was put until Relayout runs; an unknown note is ignored
	#   see        MoveNoteTo, Relayout
	def ReleaseNote(pcNote)
		_cN_ = ring_trim("" + pcNote)
		_ix_ = @oDiagram._UnknownIndex(_cN_ + ".ox")
		_iy_ = @oDiagram._UnknownIndex(_cN_ + ".oy")
		if _ix_ > 0  @oDiagram.@aPinned[_ix_] = 0  ok
		if _iy_ > 0  @oDiagram.@aPinned[_iy_] = 0  ok
		return This

	# Solves the figure again from where it stands, so a datum or a held note takes effect, and returns the figure.
	#
	#   returns    the figure itself
	#   warning    LayoutMs then reports this solve
	#   see        Layout, LayoutMs
	def Relayout()
		@oDiagram.Relayout()
		return This

	# Returns the figure as text for a terminal or a log: the five numbers and box of a box plot, the rows of a stem plot, or a coded table.
	#
	#   returns    text, several lines
	#   warning    any other kind raises an error saying which kinds have a text rendition
	#   see        ToSVG, Rendition
	#@ aka  THE TEXT RENDITION a box plot carries (the Tukey plan's TK3): the five numbers and the box in characters, for a terminal or a test log
	def Text()
		if @cKind = "boxplot"
			return StzBoxPlotFigureText(@oDiagram.Substance())
		ok
		if @cKind = "stemplot"
			return StzStemPlotFigureText(@oDiagram.Substance())
		ok
		if @cKind = "codedtable"
			return StzCodedTableFigureText(@oDiagram.Substance())
		ok
		stzraise("stzMathFigure.Text: a " + @cKind + " figure has no text rendition -- a box plot, a stem-and-leaf and a coded table have.")

	# Returns the figure as SVG text, which needs no display device.
	#
	#   returns    text, an <svg> document
	#   see        ToPNG, Rendition
	#@ aka  -- the renditions ----------------------------------------------------------
	def ToSVG()
		return @oDiagram.ToSVG()

	# Draws the figure to a PNG file at a path and returns the PNG bytes as text.
	#
	#   pcPath     The file to write, as text
	#   returns    the PNG content, as a string of bytes
	#   warning    the file is written where the path says; a relative path means the current folder
	#   see        ToSVG, RenditionAs
	def ToPNG(pcPath)
		return @oDiagram.ToPNG(pcPath)

	# Returns the figure's natural rendition, its vector drawing, as a hash list carrying the SVG.
	#
	#   returns    a hash list [ :kind, :mime, :content, :locator, :title ]
	#   warning    the kind is vector and the mime image/svg+xml
	#   see        RenditionAs, ToSVG
	def Rendition()
		return @oDiagram.Rendition()

	# Returns the figure as the kind of rendition asked: vector, image, graph or text.
	#
	#   pcKind     vector for SVG, image for a PNG file, graph for the content as Graphviz text,
	#              text for the solve's sentence
	#   returns    a hash list [ :kind, :mime, :content, :locator, :title ]
	#   warning    image writes rendition_<kind>.png in the current folder and gives that name as
	#              :locator, so prefer ToPNG with a path; another word raises an error
	#   see        Rendition, ToPNG
	def RenditionAs(pcKind)
		return @oDiagram.RenditionAs(pcKind)

	# Answers a question about the figure with a fact: a datum, a value, a distance, an angle, a position, a count or a verdict.
	#
	#   pcKind     The fact asked: expr, value, distance, angle, datum, position, count, tapenodes,
	#              arg, term or verdict
	#   paArgs     The arguments of that kind, as a list, such as [ "fr", "samples" ] for datum
	#   returns    a hash list [ :kind, :subject, :value, :unit, :where, :message ]
	#   note       the same fact object a narration quotes
	#   warning    a name or shape the figure does not hold raises an error; the unit is px for
	#              geometry and none for a datum
	#   see        ShapeOf, Substance
	def Fact(pcKind, paArgs)
		return @oDiagram.Fact(pcKind, paArgs)

	# Returns the solved geometry of one shape of the picture; [ ] when the path names no shape.
	#
	#   pcPath     The path of a shape, such as ax.icon
	#   returns    a hash list such as [ :kind, :cx, :cy, :r ] or [ :kind, :x1, :y1, :x2, :y2 ]
	#   warning    the keys depend on the shape kind: circle, ellipse, line, rect or text
	#   see        Fact, Diagram
	def ShapeOf(pcPath)
		return @oDiagram.ShapeOf(pcPath)

	# Prints the figure's explanation sentence and returns the figure; it draws nothing.
	#
	#   returns    the figure itself
	#   see        Why, ToSVG
	def Show()
		? This.Why()
		return This
