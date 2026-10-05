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

# Holds a 2D picture described once, as shapes and text, and gives it back as vector SVG or as pixels drawn on the graphics device.
#
# The Add methods remember the shape instead of posting it, so Fill, Stroke, Color and SetFont can
# still reach the last shape added; the shape is posted when the next one arrives or an output is
# asked for. Fill and Stroke called before any shape set the default for every shape added after.
# The plain form of a method acts and answers nothing, and its Q twin answers the canvas so calls
# can be chained; only the pick, identity and region setters answer the canvas without the Q. Text
# needs a font from SetFont. ToSVG needs no device and is the floor of the tier ladder; ToPNG and
# ToPixels go through the GPU and answer an empty string when none is available. Coordinates are
# pixels from the top-left corner, sizes run from 1 to 16384, and the SVG output draws circles,
# rounded rectangles, ellipses and strokes as polygons and polylines.
#
#   receiver   o1 = new stzCanvas(100, 80); o1.AddRect(10, 10, 30, 20); o1.Fill("red")
#   example    ? o1.ShapeCount()
#              #--> 1
#   see        stzFont, stzDiagram, stzObject
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

	# Builds an empty canvas of a width and a height in pixels; raises an error for a non-number or a size outside 1 to 16384.
	#
	#   pnW        The width of the canvas, in pixels
	#   pnH        The height of the canvas, in pixels
	#   returns    nothing; the canvas is built
	#   note       the background is white until SetBackground says otherwise
	#   see        Width, Height, Resize
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

	# Returns the engine's number for the scene behind the canvas, 0 once it has been released.
	#
	#   returns    a number
	#   see        Free
	#@ aka  -- identity ------------------------------------------------------------
	def Id_()
		return @nId

	# Returns how many pixels wide the canvas is, as last set by the constructor or Resize.
	#
	#   returns    a number
	#   see        Height, Resize
	def Width()
		return @nW

	# Returns how many pixels tall the canvas is, as last set by the constructor or Resize.
	#
	#   returns    a number
	#   see        Width, Resize
	def Height()
		return @nH

	# Returns how many shapes the canvas holds, after posting the pending one; the background does not count.
	#
	#   returns    a number
	#   see        Stats, Flush
	def ShapeCount()
		This._Flush()
		return StzEngineGpuSceneCommandCount(@nId)

	# Returns the engine's counters for the canvas, after posting the pending shape.
	#
	#   returns    a list of ten numbers, the first five being [ shapes, shapeVertices,
	#              textVertices, drawSegments, builds ]
	#   note       the source comment names five counters; five more follow, which the source does
	#              not describe
	#   see        ShapeCount
	#@ aka  [ shapes, shapeVertices, textVertices, drawSegments, builds ]
	def Stats()
		This._Flush()
		return StzEngineGpuSceneStats(@nId)

	# Paints the whole canvas with one colour, under every shape; it stays after Clear.
	#
	#   pColor     The background colour: a name such as "red", a #rrggbb code or another colour
	#              expression
	#   returns    nothing; the canvas changes
	#   note       the SVG output starts with a full-size rectangle of that colour, and has none
	#              while the white default is untouched
	#   see        SetBackgroundQ, Clear
	#@ aka  -- canvas-wide state ---------------------------------------------------
	def SetBackground(pColor)
		StzEngineGpuSceneClear(@nId, StzColorToNumber(pColor))

	def SetBackgroundQ(pColor)
		This.SetBackground(pColor)
		return This

	# Chooses the font and size for the text added next; a text still pending takes them at once.
	#
	#   poFont     The stzFont to draw with, which raises an error when it is not an object
	#   pnSize     The font size, in pixels
	#   returns    nothing; the canvas changes
	#   note       the size stays at 16 until set
	#   see        AddText, SetFontQ
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


	# Adds a rectangle given by its top-left corner and size; Fill, Stroke and Color then reach it until the next shape is added.
	#
	#   pnX        The x position of the left edge, in pixels
	#   pnY        The y position of the top edge, in pixels
	#   pnW        The width, in pixels
	#   pnH        The height, in pixels
	#   returns    nothing; the shape is pending
	#   note       it is white unless a fill was set earlier; it is posted when the next shape is
	#              added or output is asked for
	#   see        AddRectQ, Fill, Stroke
	#@ aka  -- adding shapes -------------------------------------------------------
	def AddRect(pnX, pnY, pnW, pnH)
		This._Flush()
		@aPending = [ :rect, pnX, pnY, pnW, pnH, @nFill, @nStroke, @nStrokeW, @bFillNamed ]

	def AddRectQ(pnX, pnY, pnW, pnH)
		This.AddRect(pnX, pnY, pnW, pnH)
		return This

	# Adds a rectangle whose fill runs from one colour to another; it is posted at once, so Fill and Stroke do not reach it.
	#
	#   pnX          The x position of the left edge, in pixels
	#   pnY          The y position of the top edge, in pixels
	#   pnW          The width, in pixels
	#   pnH          The height, in pixels
	#   pFrom        The colour at the start of the gradient
	#   pTo          The colour at the end of the gradient
	#   pbVertical   1 for a gradient running top to bottom, 0 for left to right
	#   returns      nothing; the shape is posted
	#   note         the SVG output holds a linear gradient definition and a rectangle filled with
	#                it
	#   see          AddRect
	#@ aka  A rectangle whose fill runs from one colour to another; bVertical picks the axis.
	def AddGradientRect(pnX, pnY, pnW, pnH, pFrom, pTo, pbVertical)
		This._Flush()
		StzEngineGpuSceneRectGradient(@nId, pnX, pnY, pnW, pnH,
			StzColorToNumber(pFrom), StzColorToNumber(pTo), pbVertical)

	def AddGradientRectQ(pnX, pnY, pnW, pnH, pFrom, pTo, pbVertical)
		This.AddGradientRect(pnX, pnY, pnW, pnH, pFrom, pTo, pbVertical)
		return This

	# Adds a circle given by its centre and radius; Fill and Stroke then reach it until the next shape is added.
	#
	#   pnCX       The x position of the centre, in pixels
	#   pnCY       The y position of the centre, in pixels
	#   pnR        The radius, in pixels
	#   returns    nothing; the shape is pending
	#   note       the SVG output draws a stroke as a separate polyline, not as a stroke attribute
	#   see        AddCircleQ, AddEllipse
	def AddCircle(pnCX, pnCY, pnR)
		This._Flush()
		@aPending = [ :circle, pnCX, pnCY, pnR, 0, @nFill, @nStroke, @nStrokeW, @bFillNamed ]

	def AddCircleQ(pnCX, pnCY, pnR)
		This.AddCircle(pnCX, pnCY, pnR)
		return This

	# Adds a rectangle with rounded corners; Fill and Stroke then reach it until the next shape is added.
	#
	#   pnX        The x position of the left edge, in pixels
	#   pnY        The y position of the top edge, in pixels
	#   pnW        The width, in pixels
	#   pnH        The height, in pixels
	#   pnR        The radius of the corners, in pixels
	#   returns    nothing; the shape is pending
	#   note       the SVG output holds it as a polygon of points
	#   see        AddRect
	#@ aka  A ROUNDED rectangle -- the visual signature of every diagram graphviz draws with style=rounded, which is what an org chart looks like.
	def AddRoundRect(pnX, pnY, pnW, pnH, pnR)
		This._Flush()
		@aPending = [ :roundrect, pnX, pnY, pnW, pnH, @nFill, @nStroke,
			@nStrokeW, @bFillNamed, pnR ]

	def AddRoundRectQ(pnX, pnY, pnW, pnH, pnR)
		This.AddRoundRect(pnX, pnY, pnW, pnH, pnR)
		return This

	# Adds an ellipse given by its centre and its two radii; Fill and Stroke then reach it until the next shape is added.
	#
	#   pnCX       The x position of the centre, in pixels
	#   pnCY       The y position of the centre, in pixels
	#   pnRX       The horizontal radius, in pixels
	#   pnRY       The vertical radius, in pixels
	#   returns    nothing; the shape is pending
	#   note       the SVG output holds it as a polygon of points
	#   see        AddCircle
	#@ aka  The primitive the DIAGRAM layer was missing. Of graphviz's 24 node shapes, twenty are a circle, a rect or a polygon -- all already here -- and the remaining four (ellipse, egg, cylinder, doublecircle) all need this one. Tessellated engine-side, on the same segment bound as the circle, so a stroked ellipse traces exactly the filled one.
	def AddEllipse(pnCX, pnCY, pnRX, pnRY)
		This._Flush()
		@aPending = [ :ellipse, pnCX, pnCY, pnRX, pnRY, @nFill, @nStroke, @nStrokeW, @bFillNamed ]

	def AddEllipseQ(pnCX, pnCY, pnRX, pnRY)
		This.AddEllipse(pnCX, pnCY, pnRX, pnRY)
		return This

	# Draws a field of RGBA samples stretched over a box in one operation; raises an error when the buffer is not width x height x 4 bytes.
	#
	#   pnX        The x position of the left edge of the box, in pixels
	#   pnY        The y position of the top edge of the box, in pixels
	#   pnW        The width of the box, in pixels
	#   pnH        The height of the box, in pixels
	#   pnImgW     The number of sample columns in the buffer
	#   pnImgH     The number of sample rows in the buffer
	#   pcRgba     The samples as bytes, 4 per sample (red, green, blue, alpha), row by row
	#   returns    nothing; the shape is posted
	#   note       the buffer is copied; the SVG output embeds it as a base64 PNG, so the file needs
	#              no device
	#   see        AddImageQ, AddImageXT
	#@ aka  A FIELD OF SAMPLES, drawn in ONE operation.
	def AddImage(pnX, pnY, pnW, pnH, pnImgW, pnImgH, pcRgba)
		This._Flush()
		_n_ = StzEngineGpuSceneImage(@nId, pnX, pnY, pnW, pnH,
			pnImgW, pnImgH, pcRgba, StzColorToNumber(:White))
		if _n_ != 0
			StzRaise("stzCanvas.AddImage: refused -- the box needs area, " +
				"and the pixel buffer must hold " + pnImgW + "x" + pnImgH +
				"x4 = " + (pnImgW * pnImgH * 4) + " bytes (got " +
				len(pcRgba) + ").")
		ok

	def AddImageQ(pnX, pnY, pnW, pnH, pnImgW, pnImgH, pcRgba)
		This.AddImage(pnX, pnY, pnW, pnH, pnImgW, pnImgH, pcRgba)
		return This

	# The same, TINTED: every sample multiplied by a colour expression. A
	# white tint leaves the image untouched.
	def AddImageXT(pnX, pnY, pnW, pnH, pnImgW, pnImgH, pcRgba, pTint)
		This._Flush()
		_n_ = StzEngineGpuSceneImage(@nId, pnX, pnY, pnW, pnH,
			pnImgW, pnImgH, pcRgba, StzColorToNumber(pTint))
		if _n_ != 0
			StzRaise("stzCanvas.AddImageXT: refused -- check the box has " +
				"area and the buffer is " + pnImgW + "x" + pnImgH + "x4.")
		ok

	# Adds ready-made triangles with a colour for each vertex; raises an error when the lists do not describe at least one whole triangle.
	#
	#   paVerts     A flat list of numbers, six per vertex: x, y, red, green, blue, alpha, with
	#               channels from 0 to 255
	#   paIndices   A flat list of 0-based vertex numbers, three per triangle
	#   returns     nothing; the shape is posted
	#   note        the SVG output draws one polygon per triangle, filled with a single colour, so a
	#               gradient mesh is only approximated there
	#   see         AddMeshQ, AddPolygon
	#@ aka  ALREADY-TESSELLATED triangles, with a colour PER VERTEX.
	def AddMesh(paVerts, paIndices)
		This._Flush()
		_n_ = StzEngineGpuSceneMesh(@nId, paVerts, paIndices)
		if _n_ != 0
			StzRaise("stzCanvas.AddMesh: refused -- give at least one " +
				"triangle as 6 numbers per vertex (x, y, r, g, b, a) and a " +
				"multiple of 3 indices, every one of them inside the " +
				"vertex list.")
		ok

	def AddMeshQ(paVerts, paIndices)
		This.AddMesh(paVerts, paIndices)
		return This

	# Adds a straight line between two points; Fill or Stroke then sets its colour, and Stroke its width.
	#
	#   pnX1       The x position of the start, in pixels
	#   pnY1       The y position of the start, in pixels
	#   pnX2       The x position of the end, in pixels
	#   pnY2       The y position of the end, in pixels
	#   returns    nothing; the shape is pending
	#   note       the line is 1 pixel wide and in the fill colour unless a stroke was given
	#   see        AddLineQ, AddPolyline
	def AddLine(pnX1, pnY1, pnX2, pnY2)
		This._Flush()
		@aPending = [ :line, pnX1, pnY1, pnX2, pnY2, @nFill, @nStroke, @nStrokeW, @bFillNamed ]

	def AddLineQ(pnX1, pnY1, pnX2, pnY2)
		This.AddLine(pnX1, pnY1, pnX2, pnY2)
		return This

	# Adds an open line through a list of points; Fill or Stroke then sets its colour, and Stroke its width.
	#
	#   paPoints   A flat list of coordinates, [ x1, y1, x2, y2, ... ], in pixels
	#   returns    nothing; the shape is pending
	#   note       the line is 1 pixel wide and in the fill colour unless a stroke was given
	#   see        AddPolygon, AddLine
	#@ aka  paPoints is flat: [ x1,y1, x2,y2, ... ]
	def AddPolyline(paPoints)
		This._Flush()
		@aPending = [ :polyline, paPoints, 0, 0, 0, @nFill, @nStroke, @nStrokeW, @bFillNamed ]

	def AddPolylineQ(paPoints)
		This.AddPolyline(paPoints)
		return This

	# Adds a closed filled shape through a list of points; Fill and Stroke then reach it until the next shape is added.
	#
	#   paPoints   A flat list of coordinates, [ x1, y1, x2, y2, ... ], in pixels
	#   returns    nothing; the shape is pending
	#   note       a stroke closes the outline back to the first point
	#   see        AddPolyline, AddMesh
	def AddPolygon(paPoints)
		This._Flush()
		@aPending = [ :polygon, paPoints, 0, 0, 0, @nFill, @nStroke, @nStrokeW, @bFillNamed ]

	def AddPolygonQ(paPoints)
		This.AddPolygon(paPoints)
		return This

	# Adds a text whose baseline starts at a point, drawn with the font set earlier; Fill or Color then colours it.
	#
	#   pcText     The text to draw
	#   pnX        The x position where the text starts, in pixels
	#   pnY        The y position of the baseline, not of the top of the text, in pixels
	#   returns    nothing; the text is pending
	#   note       the SVG output holds the glyphs as an outline path
	#   warning    the error for a canvas with no font is raised when the text is posted, by the
	#              next shape or output call, not by this call
	#   see        SetFont, AddTextQ, AddVerticalText
	#@ aka  (pnX, pnY) is the BASELINE origin -- where the text sits, not its box.
	def AddText(pcText, pnX, pnY)
		This._Flush()
		@aPending = [ :text, pcText, pnX, pnY, @nFill, @oFont, @nFontSize, 0 ]

	# Adds a text written down a column, the writing mode of Japanese and Chinese, using the font's vertical forms.
	#
	#   pcText     The text to draw
	#   pnX        The x position of the column, in pixels
	#   pnY        The y position where the column starts, in pixels
	#   returns    nothing; the text is pending
	#   note       a Latin word in a column stands upright, one letter under the next
	#   see        AddText, SetFont
	#@ aka  ...AND DOWN A COLUMN (GR2d). Vertical is the writing mode of Japanese and Chinese, not a rotated line: the shaper picks the font's vertical metrics and its vertical FORMS, so a comma sits in the corner a vertical reader expects and a bracket takes its upright shape. The same call serves both tiers.
	def AddVerticalText(pcText, pnX, pnY)
		This._Flush()
		@aPending = [ :text, pcText, pnX, pnY, @nFill, @oFont, @nFontSize, 1 ]

		def AddVerticalTextQ(pcText, pnX, pnY)
			This.AddVerticalText(pcText, pnX, pnY)
			return This

	# Adds a line stretched to fill a width: Arabic is lengthened inside its words by kashida, other scripts between the words.
	#
	#   pcText     The text to draw
	#   pnX        The x position where the line starts, in pixels
	#   pnY        The y position of the baseline, in pixels
	#   pnWidth    The width the line must fill, in pixels
	#   returns    nothing; the text is pending
	#   note       a width no greater than the text's own leaves the text alone, because it never
	#              compresses
	#   see        AddText, SetFont
	#@ aka  A LINE THAT FILLS A WIDTH, and in Arabic that is not a line with wider spaces in it. Latin justifies BETWEEN the words; Arabic justifies INSIDE them, by elongating the stroke that joins two letters -- the kashida. A column of Arabic stretched on its spaces alone has rivers of white running down it and reads as a page set by somebody who did not know the script.
	def AddJustifiedText(pcText, pnX, pnY, pnWidth)
		This._Flush()
		@aPending = [ :text, pcText, pnX, pnY, @nFill, @oFont, @nFontSize, 0, pnWidth ]

		def AddJustifiedTextQ(pcText, pnX, pnY, pnWidth)
			This.AddJustifiedText(pcText, pnX, pnY, pnWidth)
			return This

	def AddTextQ(pcText, pnX, pnY)
		This.AddText(pcText, pnX, pnY)
		return This

	# Paints the pending shape with a colour; with none pending it sets the colour of every shape added afterwards.
	#
	#   pColor     The fill colour: a name such as "red", a #rrggbb code or another colour
	#              expression
	#   returns    nothing; the canvas changes
	#   note       a shape given a stroke and no named fill is drawn as an outline only
	#   see        Color, Stroke, FillQ
	#@ aka  -- styling the last shape added ---------------------------------------
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

	# Colours the pending shape or text; the same act as the fill call, named for text.
	#
	#   pColor     The colour: a name such as "red", a #rrggbb code or another colour expression
	#   returns    nothing; the canvas changes
	#   see        Fill, ColorQ
	#@ aka  Text reads better as Color(); same act.
	def Color(pColor)
		This.Fill(pColor)

	def ColorQ(pColor)
		This.Fill(pColor)
		return This

	# Gives the pending shape an outline of a colour and a width, drawn over the fill; with none pending it sets the outline of later shapes.
	#
	#   pColor     The outline colour: a name such as "red", a #rrggbb code or another colour
	#              expression
	#   pnWidth    The outline width, in pixels
	#   returns    nothing; the canvas changes
	#   note       a text has no outline, so the call does nothing for it
	#   see        Fill, StrokeQ
	#@ aka  An outline in its own colour and width. On a filled shape it is drawn ON TOP of the fill, so the two agree on the silhouette.
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

	# Sets the tag that the shapes added next carry, so a click can be traced back to what was drawn; 0 means no identity.
	#
	#   pnTag      A number naming what the next shapes are
	#   returns    the canvas, so calls can be chained
	#   note       one tag spans a fill, a stroke and a label, which are one thing to a reader
	#   see        Pick, PickXT, SetSvgIdent
	#@ aka  -- output: the two tiers of ONE model ---------------------------------
	def SetPickTag(pnTag)
		This._Flush()
		StzEngineGpuSceneSetPickTag(@nId, pnTag)
		return This

	# Gives the shapes added next one element id and classes, for a reader of the SVG file; both texts empty clears them.
	#
	#   pcName      The element's id, which must be an XML name: a letter or underscore, then
	#               letters, digits, underscore, hyphen or dot
	#   pcClasses   The element's classes, as names separated by spaces
	#   returns     the canvas, so calls can be chained
	#   note        the next shapes come out of ToSVG wrapped in one group carrying that id and
	#               those classes; a name that is not an XML name raises an error instead of being
	#               escaped
	#   see         ClearSvgIdent, SetPickTag, ToSVG
	#@ aka  WHAT THE NEXT SHAPES ARE CALLED, to a reader of the FILE.
	def SetSvgIdent(pcName, pcClasses)
		This._Flush()
		_cN_ = pcName
		_cC_ = pcClasses
		if NOT isString(_cN_)  _cN_ = ""  ok
		if NOT isString(_cC_)  _cC_ = ""  ok
		# ZERO IS OK HERE, as everywhere in this engine -- see AddImage.
		# The first version read it the other way and refused every valid
		# name, which at least fails loudly; the inverse would have
		# accepted every invalid one in silence.
		if StzEngineGpuSceneSetSvgIdent(@nId, _cN_, _cC_) != 0
			StzRaise("stzCanvas.SetSvgIdent: refused -- a name must be an " +
				"XML name (a letter or underscore, then letters, digits, " +
				"'_', '-' or '.'), and classes the same with spaces " +
				"between them. Got name '" + _cN_ + "', classes '" +
				_cC_ + "'.")
		ok
		return This

	# Ends the current named element, so the shapes added next belong to none.
	#
	#   returns    the canvas, so calls can be chained
	#   see        SetSvgIdent
	#@ aka  Back to no identity -- the next shapes belong to no element.
	def ClearSvgIdent()
		return This.SetSvgIdent("", "")

	# Returns the tag of the topmost tagged shape under a point, looking up to 3 pixels around it, or 0 for bare paper.
	#
	#   pnX        The x position of the point, in pixels
	#   pnY        The y position of the point, in pixels
	#   returns    a number
	#   see        PickXT, SetPickTag
	#@ aka  The tag of the TOPMOST tagged shape under a point, or 0 for bare paper. Read straight from the retained display list: the data is already engine-side, so a click costs one crossing and no copy.
	def Pick(pnX, pnY)
		return This.PickXT(pnX, pnY, 3)

	# ...with a tolerance, because a one-pixel edge cannot be hit
	# exactly and a reader aiming at a line means the line.
	def PickXT(pnX, pnY, pnTol)
		This._Flush()
		return StzEngineGpuScenePick(@nId, pnX, pnY, pnTol)

	# Selects one rectangle of the canvas to render into an image of that size, so a picture larger than its medium can be drawn tile by tile.
	#
	#   pnX        The x position of the region's left edge, in pixels
	#   pnY        The y position of the region's top edge, in pixels
	#   pnW        The width of the region, in pixels
	#   pnH        The height of the region, in pixels
	#   returns    the canvas, so calls can be chained
	#   note       the pixel outputs answer the region; the SVG output still draws the whole canvas
	#   see        ClearRegion, ToPNG, ToPixels
	#@ aka  RENDER-REGION: draw one rectangle of this canvas, into an image of that size. Every output method below then answers the REGION -- ToPNG writes a page-sized PNG, ToPixels reads page-sized bytes.
	def SetRegion(pnX, pnY, pnW, pnH)
		StzEngineGpuSceneSetView(@nId, pnX, pnY, pnW, pnH)
		return This

	# Goes back to rendering the whole picture.
	#
	#   returns    the canvas, so calls can be chained
	#   see        SetRegion
	#@ aka  Back to the whole picture.
	def ClearRegion()
		StzEngineGpuSceneSetView(@nId, 0, 0, 0, 0)
		return This

	# Returns the picture as SVG text, the vector tier, which needs no graphics device.
	#
	#   returns    text, a complete SVG document
	#   see        ToPNG, Content
	#@ aka  Vector. Needs NO device -- always available, everywhere.
	def ToSVG()
		This._Flush()
		return StzEngineGpuSceneToSvg(@nId)

	# Renders the picture on the graphics device and returns the PNG bytes; a path also writes the file.
	#
	#   pcPath     Where to write the PNG file too
	#   returns    the PNG bytes as a string; "" when no device is available
	#   note       the compression level is 4, the measured knee; ToPNGXT takes the level, 1 to 9
	#   see        ToPNGHiRes, ToSVG, CanDrawPixels
	#@ aka  Pixels, through the GPU. Returns the PNG bytes; pass a path to also write the file. Answers "" when there is no device, and the refusal is COUNTED engine-side -- so a caller can fall back to ToSVG() knowing why. THE COMPRESSION LEVEL IS A MEASURED DEFAULT, NOT A CONSTANT.
	def ToPNG(pcPath)
		return This.ToPNGXT(pcPath, 4)

	def ToPNGXT(pcPath, pnLevel)
		return This._ToPNGSS(pcPath, pnLevel, 1)

	# Renders the picture at twice the size and averages it back down, which makes thin diagonal lines even; returns the PNG bytes.
	#
	#   pcPath     Where to write the PNG file too
	#   returns    the PNG bytes as a string; "" when no device is available
	#   note       the image has the canvas's own size; ToPNGHiResXT takes the level and the scale,
	#              1 to 4
	#   see        ToPNG, ToPixelsHiRes
	#@ aka  THE SAME PICTURE, SUPERSAMPLED -- rendered at pnScale times the size each way and box-averaged down, which is what turns a professional figure crisp.
	def ToPNGHiRes(pcPath)
		return This._ToPNGSS(pcPath, 4, 2)

	def ToPNGHiResXT(pcPath, pnLevel, pnScale)
		return This._ToPNGSS(pcPath, pnLevel, pnScale)

	def _ToPNGSS(pcPath, pnLevel, pnScale)
		_nLv_ = pnLevel
		if NOT isNumber(_nLv_)  _nLv_ = 4  ok
		if _nLv_ < 1 or _nLv_ > 9  _nLv_ = 4  ok
		_nSs_ = pnScale
		if NOT isNumber(_nSs_)  _nSs_ = 1  ok
		if _nSs_ < 1  _nSs_ = 1  ok
		if _nSs_ > 4  _nSs_ = 4  ok
		This._Flush()
		StzGraphicsDevice()
		_c_ = StzEngineGpuSceneToPngSS(@nId, _nLv_, _nSs_)
		if _c_ != "" and isString(pcPath) and pcPath != ""
			write(pcPath, _c_)
		ok
		return _c_

	# Renders the picture on the graphics device and returns the raw pixels, 4 bytes (red, green, blue, alpha) for each.
	#
	#   returns    a string of width x height x 4 bytes; of the region's size when a region is set
	#   see        ToPNG, SetRegion, CanDrawPixels
	#@ aka  Raw RGBA8 bytes of the GPU tier, for a caller that wants the pixels themselves (comparisons, compositing, tests).
	def ToPixels()
		This._Flush()
		StzGraphicsDevice()
		return StzEngineGpuSceneToPixels(@nId)

	# Returns the pixels of a supersampled render, averaged down to the canvas's own size, the data behind the hi-res PNG.
	#
	#   pnScale    The supersampling factor, 2 by default and for a non-number
	#   returns    a string of width x height x 4 bytes
	#   see        ToPixels, ToPNGHiRes
	#@ aka  ...and the supersampled pixels, box-averaged down: what ToPNGHiRes writes, for a caller that wants the bytes rather than a file.
	def ToPixelsHiRes(pnScale)
		_s_ = pnScale
		if NOT isNumber(_s_)  _s_ = 2  ok
		This._Flush()
		StzGraphicsDevice()
		return StzEngineGpuSceneToPixelsSS(@nId, _s_)

	# TRUE if a graphics device is available for the pixel outputs; it is probed once per process.
	#
	#   returns    TRUE or FALSE
	#   see        ToPNG, ToSVG
	def CanDrawPixels()
		return StzGraphicsDevice()

	# The canvas as its most portable content: the SVG text.
	def Content()
		return This.ToSVG()

	# Posts the pending shape to the engine, which closes the group of shapes that Fill, Stroke and SetFont may still change.
	#
	#   returns    nothing
	#   note       every Add call and every output call already flushes; call it to stop a later
	#              caption from restyling the last shape of a group
	#   see        FlushQ, ShapeCount
	#@ aka  Post the pending shape by hand. Only a caller driving its own frame loop needs this (stzWindow.Draw does it); every Add* and every output method already calls it.
	def Flush()
		This._Flush()

	def FlushQ()
		This._Flush()
		return This

	# Changes the canvas to a new width and height; raises an error for a non-number or a size below 1, and refuses a size the engine cannot hold.
	#
	#   pnW        The new width, in pixels
	#   pnH        The new height, in pixels
	#   returns    TRUE if the engine resized; FALSE if it refused, as for 99999, leaving the size
	#              as it was
	#   see        ResizeQ, Width, Height
	#@ aka  Empty the display list, keeping the background and the GPU buffers. What an ANIMATED canvas calls at the top of each frame -- without it the list grows by a frame's worth of shapes forever. Change the canvas's extents. The engine scene and this face are resized by the SAME call, so Width()/Height() cannot drift from what is actually being drawn -- which they did, silently, the first time a window 
	def Resize(pnW, pnH)
		if NOT (isNumber(pnW) and isNumber(pnH))
			StzRaise("stzCanvas.Resize: give a width and a height in pixels.")
		ok
		if pnW < 1 or pnH < 1
			StzRaise("stzCanvas.Resize: a canvas needs a positive size.")
		ok
		if StzEngineGpuSceneResize(@nId, pnW, pnH) != 0
			return FALSE
		ok
		@nW = pnW
		@nH = pnH
		return TRUE

	def ResizeQ(pnW, pnH)
		This.Resize(pnW, pnH)
		return This

	# Empties the display list and drops the pending shape, keeping the background and the fill and stroke settings.
	#
	#   returns    nothing
	#   note       meant for the top of each frame of an animation, so the list does not grow
	#              forever
	#   see        ClearQ, SetBackground
	def Clear()
		@aPending = []
		StzEngineGpuSceneReset(@nId)

	def ClearQ()
		This.Clear()
		return This

	# Puts the picture in front of a person: in a window when there is one, else by writing a PNG or SVG file and asking the OS to open it.
	#
	#   returns    the frame count when a window opened; the file path when it fell back
	#   note       not run here, as it opens a window or an external viewer; read from the body
	#   see        ToPNG, ToSVG
	#@ aka  Put the picture in front of a person. A real WINDOW when this machine has one (GR5) -- Escape or the X button closes it, and the picture never touches the disk. Otherwise the old path: write a PNG (or an SVG with no device) and ask the OS to open it, which is what a headless box or a machine without stz_window.dll still deserves. Returns the frame count when it opened a window, the file path when 
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

	# Releases the engine scene behind the canvas and sets its id to 0.
	#
	#   returns    nothing
	#   see        Id_
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
				# The ENGINE generates the outline. This used to build
				# circleSegments(r) points in a Ring loop and marshal them
				# back -- 2,000 stroked circles cost 168 ms against 67 ms
				# for the same circles filled, and the whole difference was
				# Ring computing points the engine already knows.
				StzEngineGpuSceneCircleStroke(@nId, _a_[2], _a_[3], _a_[4],
					_a_[8], _a_[7])
			ok
		on "roundrect"
			StzEngineGpuSceneRoundRect(@nId, _a_[2], _a_[3], _a_[4], _a_[5],
				_a_[10], _a_[6])
			if _a_[8] > 0
				StzEngineGpuSceneRoundRectStroke(@nId, _a_[2], _a_[3], _a_[4],
					_a_[5], _a_[10], _a_[8], _a_[7])
			ok
		on "ellipse"
			StzEngineGpuSceneEllipse(@nId, _a_[2], _a_[3], _a_[4], _a_[5], _a_[6])
			if _a_[8] > 0
				StzEngineGpuSceneEllipseStroke(@nId, _a_[2], _a_[3], _a_[4],
					_a_[5], _a_[8], _a_[7])
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
			# the 8th slot is the writing mode and the 9th the width a
			# justified line must fill; a pending shape written before
			# either existed reads as horizontal and unjustified, which
			# is what it was
			_v_ = 0
			if len(_a_) >= 8  _v_ = _a_[8]  ok
			_jw_ = 0
			if len(_a_) >= 9  _jw_ = _a_[9]  ok
			if _jw_ > 0
				StzEngineGpuSceneTextJustified(@nId, _a_[6].Id_(), _a_[2], _a_[3], _a_[4],
					_a_[7], _a_[5], _jw_)
			else
				StzEngineGpuSceneTextXT(@nId, _a_[6].Id_(), _a_[2], _a_[3], _a_[4],
					_a_[7], _a_[5], _v_)
			ok
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
