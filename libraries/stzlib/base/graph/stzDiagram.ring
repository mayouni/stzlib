#--------------------------------------------------#
#  stzDiagram - DOMAIN SPECIALIZATION OF stzGraph  #
#  Workflows, org charts, semantic diagrams        #
#--------------------------------------------------#
#  Part of GRAPH MODULE in StzLib (V0.9)           #
#  By: Mansour Ayouni (kalidianow@gamil.com)       #
#==================================================#

# Edge styles
$acEdgeStyles = [
	:Normal = "solid",
	:Conditional = "dashed",
	:ErrorFlow = "dotted",
	:MessageFlow = "bold"
]

$cDefaultEdgeStyle = "normal"
$cDefaultEdgeColor = "black"
#TODO Add $cDefaultEdgeSpline = "spline" or "ortho" ...

$cDefaultOrgChartEdgeStyle = "normal"
$cDefaultOrgChartEdgeSpline = "spline"
$cDefaultOrgChartEdgeColor = "gray"

# LAYOUT
# THE TWO HORIZONTAL DIRECTIONS USED TO HAVE ONE SPELLING EACH while the
# vertical pair had seven, and the asymmetry was not a decision -- it was an
# oversight that silently ignored callers. `SetLayout(:LeftToRight)` stored
# a string matching nothing, `_NativeRankDir` fell through to its "TB"
# default, and the picture came out top-down with no complaint. Every
# caller in this library that asked for a horizontal layout -- :LeftRight,
# :LeftToRight, :RightLeft, "leftright" -- was quietly getting the opposite
# axis, and a rendered diagram cannot be told from a correct one unless you
# know which way you asked for.
$acLayouts = [
	:TopDown = [ "tb", "td", "topbottom", "ud", "updown", "ub", "upbottom",
	             "topdown", "toptobottom", "vertical" ],
	:BottomUp = [ "bt", "dt", "bottomtop", "du", "downup", "bu", "bottomup",
	              "bottomtotop" ],
	:LeftRight = [ "lr", "leftright", "lefttoright", "horizontal" ],
	:RightLeft = [ "rl", "rightleft", "righttoleft" ]
]

# The graphviz ENGINE names. A different axis from rank direction entirely,
# but they arrive through the same setter and have always been accepted, so
# they are named here rather than left to be refused by a check that cannot
# tell them from a typo.
$acLayoutEngines = [ "dot", "neato", "fdp", "sfdp", "circo", "twopi", "osage" ]

$cDefaultLayout = "topdown"

# LAYOUT ENGINE OPTIONS
$acSplineTypes = ["ortho", "spline", "polyline", "curved", "line", "none"]
$cDefaultSplineType = "spline"

$anNodeSeparations = [0.3, 0.5, 0.6, 0.8, 1.0, 1.2, 1.5]
$nDefaultNodeSep = 0.6

$anRankSeparations = [0.5, 0.8, 1.0, 1.2, 1.5, 2.0]
$nDefaultRankSep = 0.8

$acConcentrate = ["true", "false"]
$cDefaultConcentrate = "false"

# FONTS
$acFonts = [
	"helvetica",
	"arial",
	"times",
	"courier",
	"verdana",
	"georgia",
	"palatino",
	"garamond",
	"comic sans ms",
	"trebuchet ms",
	"impact"
]

$cDefaultFont = "helvetica"
$cDefaultFontSize = 12

# Theme-specific font settings
$aThemeFonts = [
	:light = [:font = "helvetica", :size = 12],
	:dark = [:font = "helvetica", :size = 12],
	:vibrant = [:font = "helvetica", :size = 12],
	:pro = [:font = "helvetica", :size = 12],
	:access = [:font = "arial", :size = 16],
	:print = [:font = "times", :size = 11],
	:gray = [:font = "helvetica", :size = 12]
]

#-- Visual focus color

$cDefaultFocusColor = "magenta+"

#  VISUAL MAPPINGS
#------------------

# Shape modifiers for properties attributes
$aShapeModifiers = [
	:critical = [:penwidth = 3, :style = "bold,filled"],
	:optional = [:style = "dashed,filled"],
	:automated = [:style = "rounded,filled", :peripheries = 2],
	:manual = [:style = "rounded,filled"],
	:deprecated = [:style = "dotted,filled", :fontcolor = "gray"]
]

# Edge decorations for relationship types
$aEdgeDecorations = [
	:requires = [:arrowhead = "normal", :style = "bold"],
	:optional = [:arrowhead = "empty", :style = "dashed"],
	:async = [:arrowhead = "normal", :style = "dashed"],
	:sync = [:arrowhead = "normal", :style = "solid"],
	:triggers = [:arrowhead = "vee", :style = "bold"],
	:data_flow = [:arrowhead = "normal", :style = "solid"]
]

# Pen and arrow styles
$acNodePenStyles = ["solid", "dashed", "dotted", "bold", "invis"]
$acEdgePenStyles = ["solid", "dashed", "dotted", "bold", "invis"]

$acArrowStyles = [
	"normal", "vee", "diamond", "dot", "inv", "curve", 
	"box", "crow", "tee", "none"
]

$acDotShapes = [
	"box", "ellipse", "circle", "diamond", "parallelogram", 
	"hexagon", "octagon", "cylinder", "rect", "square", 
	"doublecircle", "tripleoctagon", "invtriangle", "house",
	"pentagon", "septagon", "trapezium", "invtrapezium",
	"triangle", "egg", "tab", "folder", "component", "note"
]

$aPolygonShapes = [
	"hexagon", "octagon", "parallelogram", "pentagon", 
	"septagon", "trapezium", "invtrapezium", "triangle",
	"house", "invtriangle", "diamond"
]


#--------------------#
#  GLOBAL FUNCTIONS  #
#--------------------#

func IsStzDiagram(pObj)
	if isObject(pObj)
		_cClass_ = StzLower(classname(pObj))
		if _cClass_ = "stzdiagram"
			return 1
		ok
	ok
	return 0

# STYLE RESOLUTION

func StzResolveEdgeStyle(pStyle)
	_cStyleKey_ = StzLower("" + pStyle)

	if HasKey($acEdgeStyles, _cStyleKey_)
		return $acEdgeStyles[_cStyleKey_]
	ok

	if StzFindFirst(_cStyleKey_, ["solid", "dashed", "dotted", "bold"])
		return _cStyleKey_
	ok

	return $cDefaultEdgeStyle

	func ResolveEdgeStyle(pStyle)
		return StzResolveEdgeStyle(pStyle)

func StzResolveNodeType(pcType)
	_cTypeKey_ = StzLower("" + pcType)

	if StzFindFirst(_cTypeKey_, $acDotShapes) > 0
		return _cTypeKey_
	ok

	if StzFindFirst(_cTypeKey_, $acNodeTypes)
		return _cTypeKey_
	ok

	_aVisualMap_ = [
		:box = "process",
		:diamond = "decision",
		:ellipse = "start",
		:circle = "state",
		:cylinder = "storage",
		:doublecircle = "endpoint"
	]

	if HasKey(_aVisualMap_, _cTypeKey_)
		return _aVisualMap_[_cTypeKey_]
	ok

	_aShapeMap_ = [
		:square = "box",
		:rect = "box",
		:egg = "ellipse",
		:tab = "box",
		:folder = "box",
		:component = "box",
		:note = "box",
		:ellpise = "ellipse"
	]

	if HasKey(_aShapeMap_, _cTypeKey_)
		return _aShapeMap_[_cTypeKey_]
	ok

	return $cDefaultNodeType

	func ResolveNodeType(pcType)
		return StzResolveNodeType(pcType)

func StzDefaultNodeType()
	return $cDefaultNodeType

	func DefaultNodeType()
		return StzDefaultNodeType()

func StzNodeTypes()
	return $acNodeTypes

	func NodeTypes()
		return StzNodeTypes()

func StzIsValidNodeType(pcType)
	return StzFindFirst(pcType, $acNodeTypes) > 0

	func IsValidNodeType(pcType)
		return StzIsValidNodeType(pcType)

func StzIsValidEdgeStyle(pcStyle)
	return HasKey($acEdgeStyles, pcStyle)

	func IsValidEdgeStyle(pcStyle)
		return StzIsValidEdgeStyle(pcStyle)

func StzEdgeStyles()
	return $acEdgeStyles

	func EdgeStyles()
		return StzEdgeStyles()

func StzDefaultEdgeStyle()
	return $cDefaultEdgeStyle

	func DefaultEdgeStyle()
		return StzDefaultEdgeStyle()

func StzStyleForEdgeType(pcType)
	if HasKey($acEdgeStyles, pcType)
		return $acEdgeStyles[pcType]
	ok
	return $cDefaultEdgeStyle

	func StyleForEdgeType(pcType)
		return StzStyleForEdgeType(pcType)

#--------------------------------------------------#
#  stzDiagram Class - Main Diagram Implementation  #
#--------------------------------------------------#

# THE SEMANTIC VOCABULARY TRANSLATED TO THE GEOMETRIC ONE, in one place.
#
# `start`, `process`, `decision`, `storage`, `endpoint` say what a node
# MEANS; `ellipse`, `box`, `diamond`, `cylinder`, `doublecircle` say what
# it looks like. Every renderer needs the mapping between them, and it
# lived as a private method on the DOT exporter -- so ToDot drew a
# decision as a diamond and the native tier, unable to reach it, drew a
# rounded box for every type there is. Two renderers of one model
# disagreeing, with the right answer already written down.
#
# A translation used by more than one face is not a detail of either.
func StzNodeShapeForType(pcType)
	_t_ = StzLower(StzTrim("" + pcType))
	if _t_ = ""  return ""  ok
	# an explicit geometric name passes straight through
	if StzIsNodeShape(_t_)  return _t_  ok
	switch _t_
	on "process"   return "box"
	on "task"      return "box"
	on "data"      return "box"
	on "decision"  return "diamond"
	on "start"     return "ellipse"
	on "event"     return "ellipse"
	on "end"       return "doublecircle"
	on "endpoint"  return "doublecircle"
	on "state"     return "circle"
	on "storage"   return "cylinder"
	on "database"  return "cylinder"
	off
	return ""

class stzDiagram from stzGraph

	@cTheme = $cDefaultColorTheme
	@cLayout = $cDefaultLayout
	@aClusters = []
	@nEdgeCornerRad = 10

	# The cluster rectangles OF THE CURRENT RENDER, with their member ids:
	# [ [ x, y, w, h, [ ids... ] ], ... ]. Render-scoped state, refilled by
	# every ToCanvasXT -- it exists because the edge drawers need to know
	# what a channel would traverse, and threading it through five
	# signatures buys nothing over reading it off the object that owns
	# both the clusters and the render.
	@aRenderClusRects = []
	@aoAnnotations = []
	@aoTemplates = []

	@cEdgeColor = $cDefaultEdgeColor
	@cNodeColor = $cDefaultNodeColor
	@cNodeStrokeColor = $cDefaultNodeStrokeColor
	@cClusterColor = $cDefaultClusterColor

	@aPalette = $aPalette
	@aFontColors = $aFontColors

	@cEdgeStyle = $cDefaultEdgeStyle

	@cFont = $cDefaultFont
	@nFontSize = $cDefaultFontSize
	@bFontCustomized = 0

	@apropertiesKeys = []

	# Validation state
	@cLastValidator = ""
	@aLastValidationResult = []
	
	# Pen attributes

	@nNodePenWidth = 1
	@nEdgePenWidth = 1

	# Pen styles : solid, dashed, dotted, bold, invis
	# Can be combine: "bold,dashed" or "dashed,rounded" for nodes.

	@cNodePenStyle = "solid"
	@cEdgePenStyle = "solid"

	# Arrow styles: normal, vee, diamond, dot, inv, curve, box, crow, tee, none.
	@cArrowHead = "normal"
	@cArrowTail = "none"

	@cSplineType = $cDefaultSplineType
	@nNodeSep = $nDefaultNodeSep
	@nRankSep = $nDefaultRankSep
	@bConcentrate = 0

	@cTitle = ""
	@cSubtitle = ""

	@aLoadedStyles = []

	@cFocusColor = $cDefaultFocusColor
	@cOutputFormat = $cDefaultDiagramOutputFormat

	@aoVisualRules = []
	@aNodesAffectedByRules = []
	@aEdgesAffectedByRules = []
	@aNodeRulesEffects = []    # Track visual rule effects
	@aEdgesRulesEffects = []

	@aTooltipConfig = []

	def init(pcName)

		super.init(pcName)

		@cEdgeColor = ResolveColor($cDefaultEdgeColor)
		@cFocusColor = ResolveColor($cDefaultFocusColor)
		@cSplineType = $cDefaultSplineType

	def Name()
		return super.Id()

	def SetTheme(pTheme)
	    _cThemeKey_ = StzLower(pTheme)
	    
	    if HasKey($aPalette, _cThemeKey_)
	        @cTheme = _cThemeKey_
	        
	        # Only apply theme fonts if not customized by user
	        if NOT @bFontCustomized and HasKey($aThemeFonts, _cThemeKey_)
	            @cFont = $aThemeFonts[_cThemeKey_][:font]
	            @nFontSize = $aThemeFonts[_cThemeKey_][:size]
	        ok
	    ok
	
	# A LAYOUT NAME THIS DOES NOT KNOW IS REFUSED, not stored. It used to
	# take anything, and an unrecognised name became top-down in silence --
	# so `SetLayout(:LeftToRight)` drew a top-down picture and there was
	# nothing anywhere to say the instruction had been dropped. A setter
	# that accepts a value it will not honour is worse than one that
	# refuses: the caller has evidence of neither.
	def SetLayout(pLayout)
		_c_ = StzLower("" + pLayout)
		if _c_ = ""
			StzRaise("stzDiagram.SetLayout: name a direction (:TopDown, " +
				":BottomUp, :LeftRight, :RightLeft) or a graphviz engine.")
		ok
		_bOk_ = 0
		for _k_ in [ :TopDown, :BottomUp, :LeftRight, :RightLeft ]
			if _c_ = StzLower("" + _k_) or StzFindFirst(_c_, $acLayouts[_k_]) > 0
				_bOk_ = 1
				exit
			ok
		next
		if _bOk_ = 0 and StzFindFirst(_c_, $acLayoutEngines) > 0  _bOk_ = 1  ok
		if _bOk_ = 0
			StzRaise("stzDiagram.SetLayout: '" + pLayout + "' is not a " +
				"layout I know. Directions are :TopDown, :BottomUp, " +
				":LeftRight and :RightLeft (or tb/bt/lr/rl); engines are " +
				StzJoinWith($acLayoutEngines, ", ") + ".")
		ok
		@cLayout = _c_

	def SetEdgeStyle(pStyle)
		@cEdgeStyle = StzLower(pStyle)

	def SetEdgeColor(pColor)
		@cEdgeColor = ResolveColor(pColor)

	# The focus colour's setter, missing until now. ExportToStyl() has always
	# WRITTEN a focus section (color + penwidth), and _ApplyStyle() has always
	# called This.SetFocusColor() to read it back -- a method nobody had
	# written, so loading any exported .stzstyl died on R14. Same shape as its
	# siblings: resolve the name, keep the resolved value.
	def SetFocusColor(pColor)
		@cFocusColor = ResolveColor(pColor)

	def FocusColor()
		return @cFocusColor

	def SetNodeColor(pColor)
		@cNodeColor = ResolveColor(pColor)

	def SetNodeStrokeColor(pColor)
	    if pColor = "" or StzLower(pColor) = 'invisible'
	        @cNodeStrokeColor = ""
	    else
	        @cNodeStrokeColor = ResolveColor(pColor)
	    ok

	    def SetStrokeColor(pColor)
		This.SetNodeStrokeColor(pColor)

	def SetFont(pFont)
		@cFont = StzLower(pFont)
		@bFontCustomized = 1

	def SetFontSize(pSize)
	    @nFontSize = pSize
	    @bFontCustomized = 1
	

	def SetPenWidth(pnWidth)
		@nNodePenWidth = pnWidth

	def SetNodePenWidth(pnWidth)
		@nNodePenWidth = pnWidth
		@nEdgePenWidth = pnWidth

	def SetEdgePenWidth(pnWidth)
		@nEdgePenWidth = pnWidth
	
	def SetNodePenStyle(pcStyle)
		# Parse + and , as separators
		@cNodePenStyle = This._NormalizeStyle(pcStyle)
	
	def SetEdgePenStyle(pcStyle)
		@cEdgePenStyle = This._NormalizeStyle(pcStyle)
	
	def _NormalizeStyle(pcStyle)
		_cStyle_ = StzLower(pcStyle)
		# Replace + with ,
		_cStyle_ = StzReplace(_cStyle_, "+", ",")
		return _cStyle_
	
	def SetArrowHead(pcStyle)
		@cArrowHead = StzLower(pcStyle)

	def SetArrowTail(pcStyle)
		@cArrowTail = StzLower(pcStyle)

	def SetSplines(pcType)

	    # A VALUE THIS DOES NOT RECOGNISE USED TO RESET THE SPLINE TO THE DEFAULT,
	    # so SetSplines("ortho") followed by SetSplines("dashed") left you with
	    # "spline" -- not the ortho you asked for and not the dashed you asked for
	    # either. A rejected value now leaves the knob alone, which is what every
	    # other validating setter here does (SetTheme, SetLayoutPreset).
	    _cType_ = StzLower(pcType)
	    if StzFindFirst(_cType_, $acSplineTypes) > 0
	        @cSplineType = _cType_
	    ok

	    # THESE TWO ARE NAMED FOR A DIFFERENT GRAPHVIZ ATTRIBUTE than the one they
	    # reach. A spline is the ROUTE an edge takes (ortho, curved, polyline); a
	    # line style is how it is DRAWN (dashed, dotted, bold). Both names read as
	    # the second and both delegated to the first, so SetEdgeLineStyle("dashed")
	    # -- the obvious call -- was swallowed.
	    #
	    # Routing on the value keeps every call that works today working: a spline
	    # name still sets the spline, and a pen style now sets the pen style
	    # instead of vanishing.
	    def SetEdgeLineStyle(pcType)
		This._SetEdgeLine(pcType)

	    def SetEdgeLineType(pcType)
		This._SetEdgeLine(pcType)

	    def _SetEdgeLine(pcType)
		_cWanted_ = StzLower(pcType)
		if StzFindFirst(_cWanted_, $acSplineTypes) > 0
			This.SetSplines(_cWanted_)
		but StzFindFirst(_cWanted_, $acEdgePenStyles) > 0
			This.SetEdgePenStyle(_cWanted_)
		ok

	    def SetEdgeSpline(pcType)
		This.SetSplines(pcType)

	def SetNodeSeparation(pnValue)
	    if isNumber(pnValue) and pnValue > 0
	        @nNodeSep = pnValue
	    ok
	
	def SetRankSeparation(pnValue)
	    if isNumber(pnValue) and pnValue > 0
	        @nRankSep = pnValue
	    ok
	
	def SetConcentrate(pbValue) #TODO // Check this
	    @bConcentrate = pbValue

	def SetLayoutPreset(pcPreset)
	    switch StzLower(pcPreset)
	    on "orgchart"
		This.SetEdgeColor($cDefaultOrgChartEdgeColor)
	        This.SetSplines($cDefaultOrgChartEdgeSpline)
	        This.SetNodeSeparation(1.0)   # Increased for side-by-side
	        This.SetRankSeparation(1.0)   # Increased for vertical clarity
	        This.SetConcentrate(0)
	        
	    on "orgchart_compact"
	        This.SetSplines("spline")
	        This.SetNodeSeparation(0.6)
	        This.SetRankSeparation(0.8)
	        This.SetConcentrate(0)
	        
	    on "compact"
	        This.SetSplines("spline")
	        This.SetNodeSeparation(0.3)
	        This.SetRankSeparation(0.5)
	        This.SetConcentrate(1)
	        
	    on "spacious"
	        This.SetSplines("ortho")
	        This.SetNodeSeparation(1.2)
	        This.SetRankSeparation(1.5)
	        This.SetConcentrate(0)
	        
	    on "flowchart"
	        This.SetSplines("polyline")
	        This.SetNodeSeparation(0.8)
	        This.SetRankSeparation(1.0)
	        This.SetConcentrate(0)
	    off

	def SetTitle(pcTitle)
	    @cTitle = pcTitle
	
	def SetSubtitle(pcSubtitle)
	    @cSubtitle = pcSubtitle

	def SetOutputFormat(cFormat)
		@cOutputFormat = StzLower(cFormat)

		def SetOutput(cFormat)
			@cOutputFormat = StzLower(cFormat)

	def SetTooltip(paConfig)
	    @aTooltipConfig = paConfig

	def DisableTooltip()
		@aTooltipConfig = []

	# Getters
	def NodePenWidth()
		if @nNodePenWidth = @nEdgePenWidth
			return @nNodePenWidth
		else
			return [ @nNodePenWidth, @nNodePenWidth ]
		ok
	
	def EdgePenWidth()
		return @nEdgePenWidth
	
	def NodePenStyle()
		return @cNodePenStyle
	
	def EdgePenStyle()
		return @cEdgePenStyle
	
	def ArrowHead()
		return @cArrowHead
	
	def ArrowTail()
		return @cArrowTail

	def Splines()
	    return @cSplineType
	
	def NodeSeparation()
	    return @nNodeSep
	
	def RankSeparation()
	    return @nRankSep
	
	def Concentrate()
	    return @bConcentrate

	#---

	def Theme()
		return @cTheme
	
	def Layout()
		return @cLayout
	
	def EdgeColor()
		return @cEdgeColor

	def NodeStrokeColor()
		return @cNodeStrokeColor
	
	def EdgeStyle()
		return @cEdgeStyle
	
	def Font()
		return @cFont
	
	def FontSize()
		return @nFontSize
	
	def PenWidth()
		return @nPenWidth

	def EdgeSplines()
		return @cSplineType

		def SplineType()
			return @cSplineType

		def EdgeLineStyle()
			return @cSplineType

		def EdgeLineType()
			return @cSplineType

	def Title()
	    return @cTitle
	
	def Subtitle()
	    return @cSubtitle

	def OutputFormat()
		return @cOutputFormat

	
	def TooltipConfig()
	    return @aTooltipConfig

	#--------------------#
	#  COLOR RESOLUTION  #
	#--------------------#

	def ResolveFontColor(pBgColor)
		_oResolver_ = new stzColorResolver()
		_cResult_ = _oResolver_.ResolveFontColor(pBgColor)
		return _cResult_
	
	def ContrastingTextColor(_cColor_)
		_oResolver_ = new stzColorResolver()
		_cResult_ = _oResolver_.ContrastingTextColor(_cColor_)
		return _cResult_
	
	def ColorToRGB(_cColor_)
		_oResolver_ = new stzColorResolver()
		_cResult_ = _oResolver_.ColorToRGB(_cColor_)
		return _cResult_

	def NodeStrokeColorForTheme(_cTheme_)
		_oResolver_ = new stzColorResolver()
		_cResult_ = _oResolver_.NodeStrokeColorForTheme(_cTheme_)
		return _cResult_

	def ConvertColorTogray(_cColor_)
		_oResolver_ = new stzColorResolver()
		_cResult_ = _oResolver_.ConvertColorTogray(_cColor_)
		return _cResult_

	#--------------------------------------------------------------------------------#
	# ADDING SPECIFIC FORMS OF NODES (ALL SUPPORTED FORMS IN GRAPHVIZ DOT LANGAUGE)  #
	#--------------------------------------------------------------------------------#
	
	#NOTE // We can add nodes using parent stzGraph methods AddNode(), AddNodeXT() and AddNodeXTT()
	
	# Rounded/Elliptical Shapes
	
	def AddCircle(pcId)
		This.AddNodeXTT(pcId, pcId, [:type = "circle", :color = $cDefaultNodeColor])
	
	def AddCircleXT(pcId, pcLabel)
		This.AddNodeXTT(pcId, pcLabel, [:type = "circle", :color = $cDefaultNodeColor])
	
	def AddCircleXTT(pcId, pcLabel, paProps)
		if NOT HasKey(paProps, "type")
			paProps + ["type", "circle" ]
		ok
		This.AddNodeXTT(pcId, pcLabel, paProps)
	
	#--
	
	def AddDoubleCircle(pcId)
		This.AddNodeXTT(pcId, pcId, [:type = "doublecircle", :color = $cDefaultNodeColor])
	
	def AddDoubleCircleXT(pcId, pcLabel)
		This.AddNodeXTT(pcId, pcLabel, [:type = "doublecircle", :color = $cDefaultNodeColor])
	
	def AddDoubleCircleXTT(pcId, pcLabel, paProps)
		if NOT HasKey(paProps, "type")
			paProps + ["type", "doublecircle"]
		ok
		This.AddNodeXTT(pcId, pcLabel, paProps)
	
	#--
	
	def AddEllipse(pcId)
		This.AddNodeXTT(pcId, pcId, [:type = "ellipse", :color = $cDefaultNodeColor])
	
	def AddEllipseXT(pcId, pcLabel)
		This.AddNodeXTT(pcId, pcLabel, [:type = "ellipse", :color = $cDefaultNodeColor])
	
	def AddEllipseXTT(pcId, pcLabel, paProps)
		if NOT HasKey(paProps, "type")
			paProps + ["type", "ellipse"]
		ok
		This.AddNodeXTT(pcId, pcLabel, paProps)
	
	#--
	
	def AddEgg(pcId)
		This.AddNodeXTT(pcId, pcId, [:type = "egg", :color = $cDefaultNodeColor])
	
	def AddEggXT(pcId, pcLabel)
		This.AddNodeXTT(pcId, pcLabel, [:type = "egg", :color = $cDefaultNodeColor])
	
	def AddEggXTT(pcId, pcLabel, paProps)
		if NOT HasKey(paProps, "type")
			paProps + ["type", "egg"]
		ok
		This.AddNodeXTT(pcId, pcLabel, paProps)
	
	# Quadrilateral Shapes
	
	def AddSquare(pcId)
		This.AddNodeXTT(pcId, pcId, [:type = "square", :color = $cDefaultNodeColor])
	
	def AddSquareXT(pcId, pcLabel)
		This.AddNodeXTT(pcId, pcLabel, [:type = "square", :color = $cDefaultNodeColor])
	
	def AddSquareXTT(pcId, pcLabel, paProps)
		if NOT HasKey(paProps, "type")
			paProps + ["type", "square"]
		ok
		This.AddNodeXTT(pcId, pcLabel, paProps)
	
	#--
	
	def AddRect(pcId)
		This.AddNodeXTT(pcId, pcId, [:type = "rect", :color = $cDefaultNodeColor])
	
	def AddRectXT(pcId, pcLabel)
		This.AddNodeXTT(pcId, pcLabel, [:type = "rect", :color = $cDefaultNodeColor])
	
	def AddRectXTT(pcId, pcLabel, paProps)
		if NOT HasKey(paProps, "type")
			paProps + ["type", "rect"]
		ok
		This.AddNodeXTT(pcId, pcLabel, paProps)
	
	#--
	
	def AddBox(pcId)
		This.AddNodeXTT(pcId, pcId, [:type = "box", :color = $cDefaultNodeColor])
	
	def AddBoxXT(pcId, pcLabel)
		This.AddNodeXTT(pcId, pcLabel, [:type = "box", :color = $cDefaultNodeColor])
	
	def AddBoxXTT(pcId, pcLabel, paProps)
		if NOT HasKey(paProps, "type")
			paProps + ["type", "box"]
		ok
		This.AddNodeXTT(pcId, pcLabel, paProps)
	
	#--
	
	def AddParallelogram(pcId)
		This.AddNodeXTT(pcId, pcId, [:type = "parallelogram", :color = $cDefaultNodeColor])
	
	def AddParallelogramXT(pcId, pcLabel)
		This.AddNodeXTT(pcId, pcLabel, [:type = "parallelogram", :color = $cDefaultNodeColor])
	
	def AddParallelogramXTT(pcId, pcLabel, paProps)
		if NOT HasKey(paProps, "type")
			paProps + ["type", "parallelogram"]
		ok
		This.AddNodeXTT(pcId, pcLabel, paProps)
	
	#--
	
	def AddTrapezium(pcId)
		This.AddNodeXTT(pcId, pcId, [:type = "trapezium", :color = $cDefaultNodeColor])
	
	def AddTrapeziumXT(pcId, pcLabel)
		This.AddNodeXTT(pcId, pcLabel, [:type = "trapezium", :color = $cDefaultNodeColor])
	
	def AddTrapeziumXTT(pcId, pcLabel, paProps)
		if NOT HasKey(paProps, "type")
			paProps + ["type", "trapezium"]
		ok
		This.AddNodeXTT(pcId, pcLabel, paProps)
	
	#--
	
	def AddInvTrapezium(pcId)
		This.AddNodeXTT(pcId, pcId, [:type = "invtrapezium", :color = $cDefaultNodeColor])
	
	def AddInvTrapeziumXT(pcId, pcLabel)
		This.AddNodeXTT(pcId, pcLabel, [:type = "invtrapezium", :color = $cDefaultNodeColor])
	
	def AddInvTrapeziumXTT(pcId, pcLabel, paProps)
		if NOT HasKey(paProps, "type")
			paProps + ["type", "invtrapezium"]
		ok
		This.AddNodeXTT(pcId, pcLabel, paProps)
	
	#--
	
	def AddDiamond(pcId)
		This.AddNodeXTT(pcId, pcId, [:type = "diamond", :color = $cDefaultNodeColor])
	
	def AddDiamondXT(pcId, pcLabel)
		This.AddNodeXTT(pcId, pcLabel, [:type = "diamond", :color = $cDefaultNodeColor])
	
	def AddDiamondXTT(pcId, pcLabel, paProps)
		if NOT HasKey(paProps, "type")
			paProps + ["type", "diamond"]
		ok
		This.AddNodeXTT(pcId, pcLabel, paProps)
	
	# Polygon Shapes
	
	def AddTriangle(pcId)
		This.AddNodeXTT(pcId, pcId, [:type = "triangle", :color = $cDefaultNodeColor])
	
	def AddTriangleXT(pcId, pcLabel)
		This.AddNodeXTT(pcId, pcLabel, [:type = "triangle", :color = $cDefaultNodeColor])
	
	def AddTriangleXTT(pcId, pcLabel, paProps)
		if NOT HasKey(paProps, "type")
			paProps + ["type", "triangle"]
		ok
		This.AddNodeXTT(pcId, pcLabel, paProps)
	
	#--
	
	def AddInvTriangle(pcId)
		This.AddNodeXTT(pcId, pcId, [:type = "invtriangle", :color = $cDefaultNodeColor])
	
	def AddInvTriangleXT(pcId, pcLabel)
		This.AddNodeXTT(pcId, pcLabel, [:type = "invtriangle", :color = $cDefaultNodeColor])
	
	def AddInvTriangleXTT(pcId, pcLabel, paProps)
		if NOT HasKey(paProps, "type")
			paProps + ["type", "invtriangle"]
		ok
		This.AddNodeXTT(pcId, pcLabel, paProps)
	
	#--
	
	def AddPentagon(pcId)
		This.AddNodeXTT(pcId, pcId, [:type = "pentagon", :color = $cDefaultNodeColor])
	
	def AddPentagonXT(pcId, pcLabel)
		This.AddNodeXTT(pcId, pcLabel, [:type = "pentagon", :color = $cDefaultNodeColor])
	
	def AddPentagonXTT(pcId, pcLabel, paProps)
		if NOT HasKey(paProps, "type")
			paProps + ["type", "pentagon"]
		ok
		This.AddNodeXTT(pcId, pcLabel, paProps)
	
	#--
	
	def AddHexagon(pcId)
		This.AddNodeXTT(pcId, pcId, [:type = "hexagon", :color = $cDefaultNodeColor])
	
	def AddHexagonXT(pcId, pcLabel)
		This.AddNodeXTT(pcId, pcLabel, [:type = "hexagon", :color = $cDefaultNodeColor])
	
	def AddHexagonXTT(pcId, pcLabel, paProps)
		if NOT HasKey(paProps, "type")
			paProps + ["type", "hexagon"]
		ok
		This.AddNodeXTT(pcId, pcLabel, paProps)
	
	#--
	
	def AddSeptagon(pcId)
		This.AddNodeXTT(pcId, pcId, [:type = "septagon", :color = $cDefaultNodeColor])
	
	def AddSeptagonXT(pcId, pcLabel)
		This.AddNodeXTT(pcId, pcLabel, [:type = "septagon", :color = $cDefaultNodeColor])
	
	def AddSeptagonXTT(pcId, pcLabel, paProps)
		if NOT HasKey(paProps, "type")
			paProps + ["type", "septagon"]
		ok
		This.AddNodeXTT(pcId, pcLabel, paProps)
	
	#--
	
	def AddOctagon(pcId)
		This.AddNodeXTT(pcId, pcId, [:type = "octagon", :color = $cDefaultNodeColor])
	
	def AddOctagonXT(pcId, pcLabel)
		This.AddNodeXTT(pcId, pcLabel, [:type = "octagon", :color = $cDefaultNodeColor])
	
	def AddOctagonXTT(pcId, pcLabel, paProps)
		if NOT HasKey(paProps, "type")
			paProps + ["type", "octagon"]
		ok
		This.AddNodeXTT(pcId, pcLabel, paProps)
	
	#--
	
	def AddTripleOctagon(pcId)
		This.AddNodeXTT(pcId, pcId, [:type = "tripleoctagon", :color = $cDefaultNodeColor])
	
	def AddTripleOctagonXT(pcId, pcLabel)
		This.AddNodeXTT(pcId, pcLabel, [:type = "tripleoctagon", :color = $cDefaultNodeColor])
	
	def AddTripleOctagonXTT(pcId, pcLabel, paProps)
		if NOT HasKey(paProps, "type")
			paProps + ["type", "tripleoctagon"]
		ok
		This.AddNodeXTT(pcId, pcLabel, paProps)
	
	# Non-geometric/Conceptual Shapes
	
	def AddCylinder(pcId)
		This.AddNodeXTT(pcId, pcId, [:type = "cylinder", :color = $cDefaultNodeColor])
	
	def AddCylinderXT(pcId, pcLabel)
		This.AddNodeXTT(pcId, pcLabel, [:type = "cylinder", :color = $cDefaultNodeColor])
	
	def AddCylinderXTT(pcId, pcLabel, paProps)
		if NOT HasKey(paProps, "type")
			paProps + ["type", "cylinder"]
		ok
		This.AddNodeXTT(pcId, pcLabel, paProps)
	
	#--
	
	def AddHouse(pcId)
		This.AddNodeXTT(pcId, pcId, [:type = "house", :color = $cDefaultNodeColor])
	
	def AddHouseXT(pcId, pcLabel)
		This.AddNodeXTT(pcId, pcLabel, [:type = "house", :color = $cDefaultNodeColor])
	
	def AddHouseXTT(pcId, pcLabel, paProps)
		if NOT HasKey(paProps, "type")
			paProps + ["type", "house"]
		ok
		This.AddNodeXTT(pcId, pcLabel, paProps)
	
	#--
	
	def AddTab(pcId)
		This.AddNodeXTT(pcId, pcId, [:type = "tab", :color = $cDefaultNodeColor])
	
	def AddTabXT(pcId, pcLabel)
		This.AddNodeXTT(pcId, pcLabel, [:type = "tab", :color = $cDefaultNodeColor])
	
	def AddTabXTT(pcId, pcLabel, paProps)
		if NOT HasKey(paProps, "type")
			paProps + ["type", "tab"]
		ok
		This.AddNodeXTT(pcId, pcLabel, paProps)
	
	#--
	
	def AddFolder(pcId)
		This.AddNodeXTT(pcId, pcId, [:type = "folder", :color = $cDefaultNodeColor])
	
	def AddFolderXT(pcId, pcLabel)
		This.AddNodeXTT(pcId, pcLabel, [:type = "folder", :color = $cDefaultNodeColor])
	
	def AddFolderXTT(pcId, pcLabel, paProps)
		if NOT HasKey(paProps, "type")
			paProps + [ "type", "folder" ]
		ok
		This.AddNodeXTT(pcId, pcLabel, paProps)
	
	#--
	
	def AddComponent(pcId)
		This.AddNodeXTT(pcId, pcId, [:type = "component", :color = $cDefaultNodeColor])
	
	def AddComponentXT(pcId, pcLabel)
		This.AddNodeXTT(pcId, pcLabel, [:type = "component", :color = $cDefaultNodeColor])
	
	def AddComponentXTT(pcId, pcLabel, paProps)
		if NOT HasKey(paProps, "type")
			paProps + ["type", "component"]
		ok
		This.AddNodeXTT(pcId, pcLabel, paProps)
	
	#--
	
	def AddNote(pcId)
		This.AddNodeXTT(pcId, pcId, [:type = "note", :color = $cDefaultNodeColor])
	
	def AddNoteXT(pcId, pcLabel)
		This.AddNodeXTT(pcId, pcLabel, [:type = "note", :color = $cDefaultNodeColor])
	
	def AddNoteXTT(pcId, pcLabel, paProps)
		if NOT HasKey(paProps, "type")
			paProps + ["type", "note"]
		ok
		This.AddNodeXTT(pcId, pcLabel, paProps)

	#----------------------#
	#  CLUSTER OPERATIONS  #
	#----------------------#

	def SetClusterColor(pcColor)
		@cClusterColor = ResolveColor(pcColor)

	def AddCluster(pClusterId, aNodeIds)
		This.AddClusterXT(pClusterId, pClusterId, aNodeIds)

	def AddClusterXT(pClusterId, pLabel, aNodeIds)
		This.AddClusterXTT(pClusterId, pLabel, aNodeIds, @cClusterColor)

	def AddClusterXTT(pClusterId, pLabel, aNodeIds, pColor)
		_aCluster_ = [
			:id = pClusterId,
			:label = pLabel,
			:nodes = aNodeIds,
			:color = ResolveColor(pColor)
		]
		@aClusters + _aCluster_

	def Clusters()
		return @aClusters

	#-------------------------#
	#  ANNOTATION OPERATIONS  #
	#-------------------------#

	def AddAnnotation(oAnnotation)
		@aoAnnotations + oAnnotation

	def AnnotationsByType(pcType)
		_aoFiltered_ = []
		_nLen_ = len(@aoAnnotations)

		for i = 1 to _nLen_
			if @aoAnnotations[i].Type() = pcType
				_aoFiltered_ + @aoAnnotations[i]
			ok
		end
		return _aoFiltered_

	# The annotators overlaying this diagram -- OBJECTS, hence Q.
	def AnnotationsQ()
		return @aoAnnotations

	# ... and what they are, as data: the type each one annotates.
	def Annotations()
		_acTypes_ = []
		_nLen_ = len(@aoAnnotations)
		for i = 1 to _nLen_
			_acTypes_ + @aoAnnotations[i].Type()
		end
		return _acTypes_

	#-----------------------#
	#  TEMPLATE OPERATIONS  #
	#-----------------------#

	def AddTemplate(oTemplate) #TODO // #TODO Test this
		@aoTemplates + oTemplate

	def ApplyTemplates()
		_nLen_ = len(@aoTemplates)
		for i = 1 to _nLen_
			@aoTemplates[i].Apply(This)
		end

	#----------------#
	#  VISUAL RULES  #
	#----------------#

	# This section manages visual styling rules that change
	# diagram appearance based on node/edge properties.

	def RegisterVisualRule(pcRuleName, paDefinition)
		# Store visual rule as data structure
		_aRule_ = [
			:name = pcRuleName,
			:conditionType = paDefinition[:conditionType],
			:conditionParams = paDefinition[:conditionParams],
			:effects = paDefinition[:effects]
		]
		@aoVisualRules + _aRule_
	
	def ApplyVisualRules()
		@aNodeRulesEffects = []
		@aEdgesRulesEffects = []
		
		# Apply to nodes
		_aNodes_ = This.Nodes()
		_nNodes4Len_ = len(_aNodes_)
		for _iLoopNodes4_ = 1 to _nNodes4Len_
			_aNode_ = _aNodes_[_iLoopNodes4_]
			_aEnhancements_ = This._ApplyRulesToElement(_aNode_, "node")
			if len(_aEnhancements_) > 0
				@aNodeRulesEffects[_aNode_[:id]] = _aEnhancements_
			ok
		end
		
		# Apply to edges
		_aEdges_ = This.Edges()
		_nEdges3Len_ = len(_aEdges_)
		for _iLoopEdges3_ = 1 to _nEdges3Len_
			_aEdge_ = _aEdges_[_iLoopEdges3_]
			_aEnhancements_ = This._ApplyRulesToElement(_aEdge_, "edge")
			_cKey_ = _aEdge_[:from] + "->" + _aEdge_[:to]
			if len(_aEnhancements_) > 0
				@aEdgesRulesEffects[_cKey_] = _aEnhancements_
			ok
		end
	
	def _ApplyRulesToElement(aElement, _cType_)
	    _aEnhancements_ = []
	    
	    _nAoVisualRules3Len_ = len(@aoVisualRules)
	    for _iLoopAoVisualRules3_ = 1 to _nAoVisualRules3Len_
	    	_aRule_ = @aoVisualRules[_iLoopAoVisualRules3_]
	        _aContext_ = This._BuildRuleContext(aElement)
	        
	        if This._RuleMatches(_aRule_, _aContext_)
	            # DEBUG
	            # ? "Rule '" + aRule[:name] + "' matched node: " + aElement[:id]
	            # ? "  Effects: " + @@(aRule[:effects])
	            
	            _aEffects_ = _aRule_[:effects]
	            
	            # Merge effects
	            _nEffects2Len_ = len(_aEffects_)
	            for _iLoopEffects2_ = 1 to _nEffects2Len_
	            	_aEffect_ = _aEffects_[_iLoopEffects2_]
	                _aEnhancements_[_aEffect_[1]] = _aEffect_[2]
	            end
	        ok
	    end
	    
	    # DEBUG
	    # if len(aEnhancements) > 0
	    #     ? "Final enhancements for " + aElement[:id] + ": " + @@(aEnhancements)
	    # ok
	    
	    return _aEnhancements_

	
	def _RuleMatches(_aRule_, _aContext_)
		_cType_ = _aRule_[:conditionType]
		_aParams_ = _aRule_[:conditionParams]
		
		switch _cType_
		on "property_range"
			return This._MatchRange(_aContext_, _aParams_)
		on "property_equals"
			return This._MatchEquals(_aContext_, _aParams_)
		on "property_exists"
			return This._MatchExists(_aContext_, _aParams_)
		on "tag_exists"
			return This._MatchTag(_aContext_, _aParams_)
		off
		
		return 0
	
	def _MatchRange(_aContext_, _aParams_)
		if NOT HasKey(_aContext_, :properties)
			return 0
		ok
		
		_cKey_ = _aParams_[1]
		_nMin_ = _aParams_[2]
		_nMax_ = _aParams_[3]
		
		if NOT HasKey(_aContext_[:properties], _cKey_)
			return 0
		ok
		
		pValue = _aContext_[:properties][_cKey_]
		if NOT isNumber(pValue)
			return 0
		ok
		
		return (pValue >= _nMin_ and pValue <= _nMax_)
	
	def _MatchEquals(_aContext_, _aParams_)
		if NOT HasKey(_aContext_, :properties)
			return 0
		ok
		
		_cKey_ = _aParams_[1]
		pExpected = _aParams_[2]
		
		if NOT HasKey(_aContext_[:properties], _cKey_)
			return 0
		ok
		
		return (_aContext_[:properties][_cKey_] = pExpected)
	
	def _MatchExists(_aContext_, _aParams_)
		if NOT HasKey(_aContext_, :properties)
			return 0
		ok
		
		_cKey_ = _aParams_[1]
		return HasKey(_aContext_[:properties], _cKey_)
	
	def _MatchTag(_aContext_, _aParams_)
		if NOT HasKey(_aContext_, :tags)
			return 0
		ok
		
		_cTag_ = _aParams_[1]
		return StzFindFirst(_cTag_, _aContext_[:tags]) > 0
	
	def _BuildRuleContext(aElement)
		_aContext_ = aElement
		
		if HasKey(aElement, :properties) and aElement[:properties] != ""
			_aContext_[:properties] = aElement[:properties]
			_aContext_[:tags] = []
			if HasKey(aElement[:properties], :tags)
				_aContext_[:tags] = aElement[:properties][:tags]
			ok
		ok
		
		return _aContext_
	

	def NodesAffectedByVisualRules()
	    _acResult_ = []
	    _acKeys_ = keys(@aNodeRulesEffects)
	    _nAcKeys2Len_ = len(_acKeys_)
	    for _iLoopAcKeys2_ = 1 to _nAcKeys2Len_
	    	_cKey_ = _acKeys_[_iLoopAcKeys2_]
	        _acResult_ + _cKey_
	    next
	    return _acResult_
	
	def VisualRulesApplied()
	    _aResult_ = []
	    _nAoVisualRules2Len_ = len(@aoVisualRules)
	    for _iLoopAoVisualRules2_ = 1 to _nAoVisualRules2Len_
	    	_aRule_ = @aoVisualRules[_iLoopAoVisualRules2_]
	        _aResult_ + [
	            :name = _aRule_[:name],
	            :conditionType = _aRule_[:conditionType],
	            :effectsCount = len(_aRule_[:effects])
	        ]
	    next
	    return _aResult_

	#-----------------#
	#  QUERY METHODS  #
	#-----------------#
	
	# properties-based queries
	def NodesWithProperty(pcProp)
		_acResult_ = []
		_aNodes_ = This.Nodes()
		
		_nNodes3Len_ = len(_aNodes_)
		for _iLoopNodes3_ = 1 to _nNodes3Len_
			_aNode_ = _aNodes_[_iLoopNodes3_]
			if HasKey(_aNode_, :properties) and 
			   HasKey(_aNode_[:properties], pcProp)
				_acResult_ + _aNode_[:id]
			ok
		end
		
		return _acResult_
	
	def NodesWith(pcProp, pcOp, pValue)
		# Reuse graph query system
		_oQuery_ = new stzGraphQuery(This, "nodes")
		_oQuery_.Where(pcProp, pcOp, pValue)
		return _oQuery_.Run()
	
	def NodesWithTag(pcTag)
		_acResult_ = []
		_aNodes_ = This.Nodes()
		
		_nNodes2Len_ = len(_aNodes_)
		for _iLoopNodes2_ = 1 to _nNodes2Len_
			_aNode_ = _aNodes_[_iLoopNodes2_]
			if HasKey(_aNode_, :properties) and 
			   HasKey(_aNode_[:properties], :tags) and
			   StzFindFirst(pcTag, _aNode_[:properties][:tags]) > 0
				_acResult_ + _aNode_[:id]
			ok
		end
		
		return _acResult_
	
	def EdgesWithProperty(pcProp)
		_acResult_ = []
		_aEdges_ = This.Edges()
		
		_nEdges2Len_ = len(_aEdges_)
		for _iLoopEdges2_ = 1 to _nEdges2Len_
			_aEdge_ = _aEdges_[_iLoopEdges2_]
			if HasKey(_aEdge_, :properties) and 
			   HasKey(_aEdge_[:properties], pcProp)
				_acResult_ + (_aEdge_[:from] + "->" + _aEdge_[:to])
			ok
		end
		
		return _acResult_
	
	def EdgesWithPropertyValue(pcProp, pValue)
		_acResult_ = []
		_aEdges_ = This.Edges()
		
		_nEdges1Len_ = len(_aEdges_)
		for _iLoopEdges1_ = 1 to _nEdges1Len_
			_aEdge_ = _aEdges_[_iLoopEdges1_]
			if HasKey(_aEdge_, :properties) and 
			   HasKey(_aEdge_[:properties], pcProp) and
			   _aEdge_[:properties][pcProp] = pValue
				_acResult_ + (_aEdge_[:from] + "->" + _aEdge_[:to])
			ok
		end
		
		return _acResult_
	
	#---------------------#
	#  properties LEGEND  # #TODO Should be abstarcted in stzGraph!!
	#---------------------#
	
	def propertiesLegend()
		_acLegend_ = ["=== properties LEGEND ===", ""]
		
		_nAoVisualRules1Len_ = len(@aoVisualRules)
		for _iLoopAoVisualRules1_ = 1 to _nAoVisualRules1Len_
			_oRule_ = @aoVisualRules[_iLoopAoVisualRules1_]
			_cCondition_ = _oRule_.@cConditionType
			_aParams_ = _oRule_.@aConditionParams
			_aEffects_ = _oRule_.Effects()
			
			_acLegend_ + "When: " + _cCondition_
			if len(_aParams_) > 0
				_acLegend_ + "  Params: " + @@(_aParams_)
			ok
			
			_nEffects1Len_ = len(_aEffects_)
			for _iLoopEffects1_ = 1 to _nEffects1Len_
				_aEffect_ = _aEffects_[_iLoopEffects1_]
				# NOTE: this marker was corrupted beyond recovery -- the bytes were
				# SUBSTITUTED, not merely re-encoded, so the original glyph cannot
				# be derived (no candidate reproduces the run under any number of
				# corruption passes, and it predates the variable's current name).
				# ASCII "->" matches its sibling lines ("When: ", "  Params: ").
				_acLegend_ + "  -> " + _aEffect_[1] + ": " + _aEffect_[2]
			next
			
			_acLegend_ + ""
		end
		
		return _acLegend_

	#-----------#
	#  METRICS  # #TODO Should be abstracted in stzGraph!
	#-----------#

	def ComputeMetrics()
		_aMetrics_ = []
		_anAllPaths_ = []
		_aNodes_ = This.Nodes()
		_nLenNodes_ = len(_aNodes_)

		for i = 1 to _nLenNodes_
			_aReachable_ = This.ReachableFrom(_aNodes_[i]["id"])
			_nLen_ = len(_aReachable_)
			if _nLen_ > 1
				_anAllPaths_ + (_nLen_ - 1)
			ok
		end

		_nAvg_ = 0
		_nLen_ = len(_anAllPaths_)

		_nSum_ = 0
		for i = 1 to _nLen_
			_nSum_ += _anAllPaths_[i]
		end
		_nAvg_ = _nSum_ / _nLen_

		_nMax_ = 0
		for i = 1 to _nLen_
			if _anAllPaths_[i] > _nMax_
				_nMax_ = _anAllPaths_[i]
			ok
		end

		_aMetrics_[:avgPathLength] = _nAvg_
		_aMetrics_[:maxPathLength] = _nMax_
		_aMetrics_[:bottlenecks] = This.BottleneckNodes()
		_aMetrics_[:density] = This.NodeDensity()
		_aMetrics_[:nodeCount] = This.NodeCount()
		_aMetrics_[:edgeCount] = This.EdgeCount()

		return _aMetrics_

	#-----------------#
	#  VISUALIZATION  #
	#-----------------#

	#-----------------------------------------------------------------#
	#  THE NATIVE TIER -- a diagram drawn WITHOUT dot.exe             #
	#-----------------------------------------------------------------#
	#
	#     oD.ToSVG()               # vector, needs no GPU and no graphviz
	#     oD.ToPNG("d.png")        # pixels, through the GPU
	#     oD.ToCanvas()            # the stzCanvas, to compose further
	#
	# ToDot() and Display() are untouched: emitting the dot LANGUAGE is a
	# legitimate export, and a caller with graphviz installed may still
	# want its renderer. What changes is that neither is REQUIRED any more.
	#
	# LAYOUT IS BORROWED, DRAWING IS NOT. Positions come from
	# stzGraphCanvas -- the engine-side layout GG1 built, measured and
	# guarded -- because layout is the expensive, correctness-critical part
	# and a second implementation of it would diverge. The DRAWING is here,
	# because a diagram is a different picture from a graph: boxes with
	# labels inside, twenty-four shapes, clusters behind. That is the same
	# split stzOrgChart already made.
	#
	# KILL CRITERION, written before the code: dot still wins on two things
	# this route does not attempt -- SPLINE edges routed around nodes, and
	# nested clusters. If a diagram needs those, ToDot() remains the honest
	# answer and this tier is a convenience, not a replacement. What it must
	# do is draw every shape in the vocabulary, keep cluster members inside
	# their cluster, and never need an external binary.

	def ToCanvas()
		return This.ToCanvasXT([])

	def ToCanvasXT(paOptions)
		if NOT isList(paOptions)  paOptions = []  ok

		_aNodes_ = This.Nodes()
		_nN_ = len(_aNodes_)
		if _nN_ = 0
			StzRaise("stzDiagram.ToCanvas: this diagram has no nodes to draw.")
		ok

		_nW_    = This._DiagOpt(paOptions, "width", 1000)
		_nH_    = This._DiagOpt(paOptions, "height", 700)
		_nBoxW_ = This._DiagOpt(paOptions, "nodewidth", 150)
		_nBoxH_ = This._DiagOpt(paOptions, "nodeheight", 56)
		_oFont_ = This._DiagOpt(paOptions, "font", "")
		_nFsz_  = This._DiagOpt(paOptions, "fontsize", 14)
		_cBg_   = This._DiagOpt(paOptions, "background", "#FFFFFF")
		_cEdge_ = This._DiagOpt(paOptions, "edgecolor", "#8A8A8A")
		_nEdgeW_= This._DiagOpt(paOptions, "edgewidth", 2)
		_nRad_  = This._DiagOpt(paOptions, "corner", 10)

		# :SCALE IS RESOLUTION, NOT ZOOM. A raster is only as sharp as the
		# pixels it was drawn with: enlarging a finished PNG enlarges its
		# blur, and a 12px label in a 3000px picture is unreadable at 100%
		# and worse magnified. Scaling every INPUT -- boxes, font,
		# separations, stroke, corners -- redraws the same diagram with
		# more pixels, so the glyphs are rasterised at their new size and
		# the edges are re-antialiased at it. :Scale = 2 gives text a
		# reader can actually magnify; 3 is print.
		#
		# Everything here is proportional, so ONE multiplier is enough and
		# the picture cannot come out subtly different -- which is what
		# scaling only some of these would give.
		_nScl_ = This._DiagOpt(paOptions, "scale", 1)
		if NOT isNumber(_nScl_)  _nScl_ = 1  ok
		if _nScl_ < 1  _nScl_ = 1  ok
		if _nScl_ > 1
			_nBoxW_ = _nBoxW_ * _nScl_
			_nBoxH_ = _nBoxH_ * _nScl_
			_nFsz_  = _nFsz_ * _nScl_
			_nEdgeW_= _nEdgeW_ * _nScl_
			_nRad_  = _nRad_ * _nScl_
			if This._HasOpt(paOptions, "width")   _nW_ = _nW_ * _nScl_  ok
			if This._HasOpt(paOptions, "height")  _nH_ = _nH_ * _nScl_  ok
		ok

		# THE DIAGRAM'S OWN SETTINGS ARE READ, not re-asked for. SetLayout and
		# SetSplines already exist and already drive the dot output; a native
		# tier that ignored them would be a second diagram over the same data.
		_cRank_ = This._NativeRankDir()
		_cSpl_  = StzLower("" + This.Splines())
		if _cSpl_ = ""  _cSpl_ = "spline"  ok

		# Layout in a space inset by half a box, so a node on the border is not
		# half off-canvas -- and TRANSPOSED afterwards for LR/RL/BT, because
		# rankdir is a property of the picture, not of the graph.
		_mx_ = _nBoxW_ / 2 + 14 * _nScl_
		_my_ = _nBoxH_ / 2 + 14 * _nScl_
		_bSwap_ = 0
		if _cRank_ = "LR" or _cRank_ = "RL"  _bSwap_ = 1  ok

		# SPACING IS THE CONTRACT; THE SIZE IS DERIVED. That is dot's model,
		# and this tier had it inverted: the caller fixed a canvas and the
		# layout was stretched to fill it, so the minimum gap between two
		# nodes was whatever the stretch left over -- 2px in a crowded rank,
		# 20px in a loose one, in the same picture. Meanwhile the diagram
		# already OWNED the contract: SetNodeSeparation and SetRankSeparation
		# exist, in dot's own units, and only the DOT WRITER read them. The
		# knob the caller sends and the knob the face reads have to be the
		# same knob.
		#
		# So: when the caller does not name a size, the picture takes its
		# size from its content -- every gap exactly nodesep, every rank
		# exactly ranksep apart, like dot. Naming :Width/:Height keeps the
		# old fill-the-canvas behaviour, with :FitBoxes as the safety net.
		# Separations arrive in dot's inches (96dpi), overridable in pixels
		# via :NodeSep / :RankSep.
		_aRoute_ = []
		_cLM_ = StzLower("" + This._DiagOpt(paOptions, "layoutmode", :Hierarchical))
		_bNat_ = 0
		if _cLM_ = "hierarchical" and
		   NOT (This._HasOpt(paOptions, "width") or This._HasOpt(paOptions, "height"))
			_bNat_ = 1
		ok
		_nSepN_ = This._DiagOpt(paOptions, "nodesep",
			floor(This.NodeSeparation() * 96)) * _nScl_
		_nSepR_ = This._DiagOpt(paOptions, "ranksep",
			floor(This.RankSeparation() * 96)) * _nScl_

		# A LABELLED EDGE NEEDS THE GAP IT IS WRITTEN IN. dot reserves this
		# by giving the label its own virtual rank; the same effect, at this
		# scale, is that the rank gap must be at least tall enough to hold a
		# line of text with air around it. Without the reservation a label
		# is drawn into whatever space the ranks happened to leave, which is
		# how labels come to sit on top of each other and on the arrowheads.
		#
		# Only when a label EXISTS -- an unlabelled diagram keeps exactly the
		# separation its author asked for.
		_bELab_ = 0
		for _e0_ in This.Edges()
			if StzTrim("" + _e0_[:label]) != ""  _bELab_ = 1  exit  ok
		next
		if _bELab_
			_nSepR_ = max([ _nSepR_, _nFsz_ * 2 + 34 ])
		ok

		if _bNat_
			# any provisional size -- only the FRACTIONS of it are read back
			# LABELS STEER THE LAYOUT. Reserving gap HEIGHT gave a label
			# somewhere to be written; it did nothing about width, so two
			# edges running close together still fought over the same
			# horizontal space and the loser was nudged onto something
			# else. Nudging moves the label; only the layout can make
			# ROOM. A node whose incoming edge carries a label wider than
			# the node itself asks for the difference, and its whole rank
			# spreads to give it.
			_slot0_ = _nBoxW_
			if _bSwap_  _slot0_ = _nBoxH_  ok
			_slot0_ += _nSepN_
			_aXtra_ = This._LabelDemand(_oFont_, _nFsz_, _nBoxW_, _slot0_,
				_bSwap_)

			_oGC_ = new stzGraphCanvas(This, [
				:Layout = :Hierarchical,
				:Width = 1000, :Height = 700, :Margin = 0,
				:Clusters = This._ClusterPairs(),
				:NodeExtra = _aXtra_
			])
			# slot and pitch along the LAYOUT axes; the boxes do not rotate
			# with the rank direction, so the box dimension that matters
			# swaps when the picture does
			_slotB_ = _nBoxW_
			_pitchB_ = _nBoxH_
			if _bSwap_
				_slotB_ = _nBoxH_
				_pitchB_ = _nBoxW_
			ok
			_slot_ = _slotB_ + _nSepN_
			_pitch_ = _pitchB_ + _nSepR_
			# unit-true x: 1.0 = one minimum separation, so span * slot IS
			# the content width. The ordinal fallback (a diagram with no
			# edges) is one even layer: n slots.
			if _oGC_.IsUnitX()
				_inX_ = _oGC_.RawSpanX() * _slot_
			else
				_inX_ = max([ 0, _nN_ - 1 ]) * _slot_
			ok
			# A RANK GAP MUST ANSWER TO THE SPAN IT IS CROSSED BY.
			#
			# An edge running far sideways over a shallow gap is nearly
			# HORIZONTAL, and a nearly horizontal edge in a layered
			# drawing travels along its target's rank -- grazing, and
			# often crossing, every node between. A broker fanning to
			# fourteen workers put fourteen near-flat lines across the
			# row: the attachment sides were right, the curve was right,
			# and the picture was still unreadable because 130px of gap
			# cannot absorb 4000px of fan.
			#
			# So the widest edge in the picture sets a floor under the
			# pitch. A tenth of the longest horizontal run is enough to
			# give every edge a visible descent; diagrams whose edges are
			# all short never reach the floor and keep exactly the
			# separation their author asked for.
			# PER RANK CROSSED, not per edge. Using an edge's whole
			# horizontal run made one long multi-rank edge inflate EVERY
			# gap in the picture -- a diagram with a single edge from top
			# to bottom grew until the guard scanning its pixels stopped
			# finishing. What decides whether an edge reads as flat is
			# its run divided by the number of gaps it descends through,
			# because that is the slope of each leg.
			_maxdx_ = 0
			_nlay_ = _oGC_.LayerCount()
			for _e2_ in This.Edges()
				_pa_ = 0  _pb_ = 0  _ya_ = 0  _yb_ = 0
				_bfa_ = 0  _bfb_ = 0
				for _p2_ in _oGC_.Positions()
					if StzLower("" + _p2_[1]) = StzLower("" + _e2_[:from])
						_pa_ = _p2_[2]  _ya_ = _p2_[3]  _bfa_ = 1
					but StzLower("" + _p2_[1]) = StzLower("" + _e2_[:to])
						_pb_ = _p2_[2]  _yb_ = _p2_[3]  _bfb_ = 1
					ok
				next
				if _bfa_ and _bfb_
					_gaps2_ = fabs(_ya_ - _yb_) / 700 * max([ _nlay_ - 1, 1 ])
					if _gaps2_ < 1  _gaps2_ = 1  ok
					_dxe_ = fabs(_pa_ - _pb_) / 1000 * _inX_ / _gaps2_
					if _dxe_ > _maxdx_  _maxdx_ = _dxe_  ok
				ok
			next
			if _maxdx_ * 0.20 > _pitch_  _pitch_ = _maxdx_ * 0.20  ok

			_inY_ = (_oGC_.LayerCount() - 1) * _pitch_
			if _bSwap_
				_nW_ = ceil(_inY_ + 2 * _mx_)
				_nH_ = ceil(_inX_ + 2 * _my_)
			else
				_nW_ = ceil(_inX_ + 2 * _mx_)
				_nH_ = ceil(_inY_ + 2 * _my_)
			ok
			_aXY_ = []
			for _p_ in _oGC_.Positions()
				_px_ = _p_[2] / 1000 * _inX_
				_py_ = _p_[3] / 700 * _inY_
				if _bSwap_
					_t_ = _px_
					_px_ = _py_
					_py_ = _t_
				ok
				if _cRank_ = "RL"  _px_ = _inY_ - _px_  ok
				if _cRank_ = "BT"  _py_ = _inY_ - _py_  ok
				_aXY_ + [ StzLower("" + _p_[1]), _px_ + _mx_, _py_ + _my_ ]
			next
			# the long edges' routes ride the SAME transform as the nodes --
			# one rule, so a route can never land in a different frame from
			# the boxes it joins
			for _r_ in _oGC_.EdgeRoutes()
				_rp_ = []
				for _bp_ in _r_[3]
					_px_ = _bp_[1] / 1000 * _inX_
					_py_ = _bp_[2] / 700 * _inY_
					if _bSwap_
						_t_ = _px_
						_px_ = _py_
						_py_ = _t_
					ok
					if _cRank_ = "RL"  _px_ = _inY_ - _px_  ok
					if _cRank_ = "BT"  _py_ = _inY_ - _py_  ok
					_rp_ + [ _px_ + _mx_, _py_ + _my_ ]
				next
				_aRoute_ + [ StzLower("" + _r_[1]), StzLower("" + _r_[2]), _rp_ ]
			next

			# A CLUSTER IS BIGGER THAN ITS MEMBERS. Its box is padded and
			# carries a label ABOVE the topmost member, and the derived size
			# was computed from node centres alone -- so the "Data" box ran
			# off the bottom of its own picture, drawn correctly into space
			# that was never reserved. Deriving a size from content means
			# ALL the content, chrome included.
			_bChrome_ = len(@aClusters) > 0
			for _e0_ in This.Edges()
				if StzLower("" + _e0_[:from]) = StzLower("" + _e0_[:to])
					_bChrome_ = 1
					exit
				ok
			next
			if _bChrome_
				_ex0_ = 0  _ey0_ = 0  _ex1_ = _nW_  _ey1_ = _nH_

				# a self-loop reaches beyond its node, on the side the
				# drawing puts it
				_slr_ = This._SelfLoopReach(_nBoxW_, _nBoxH_) + 6
				for _e0_ in This.Edges()
					if StzLower("" + _e0_[:from]) != StzLower("" + _e0_[:to])
						loop
					ok
					_at_ = This._XYOf(_aXY_, "" + _e0_[:from])
					if len(_at_) != 2  loop  ok
					# ...and its LABEL sits BEYOND the loop, so the reach is
					# not the whole reservation. Reserving only the loop
					# clipped "retry" against the top edge of the picture --
					# the same shape as the loop bug itself, one layer out.
					_slx_ = _slr_
					if StzTrim("" + _e0_[:label]) != "" and isObject(_oFont_)
						_slx_ += _nFsz_ * 2
					ok
					if _bSwap_
						if _at_[2] - _nBoxH_ / 2 - _slx_ < _ey0_
							_ey0_ = _at_[2] - _nBoxH_ / 2 - _slx_
						ok
					else
						_slw_ = 0
						if StzTrim("" + _e0_[:label]) != "" and isObject(_oFont_)
							_slw_ = _oFont_.WidthOf("" + _e0_[:label], _nFsz_) + 10
						ok
						if _at_[1] + _nBoxW_ / 2 + _slr_ + _slw_ > _ex1_
							_ex1_ = _at_[1] + _nBoxW_ / 2 + _slr_ + _slw_
						ok
					ok
				next

				for _cl_ in @aClusters
					_cb_ = This._ClusterBox(_cl_, _aXY_, _nBoxW_, _nBoxH_)
					if len(_cb_) != 4  loop  ok
					# the label sits 24px above the box, matching the draw
					if _cb_[1] < _ex0_  _ex0_ = _cb_[1]  ok
					if _cb_[2] - _nFsz_ * 1.9 < _ey0_
						_ey0_ = _cb_[2] - _nFsz_ * 1.9
					ok
					if _cb_[1] + _cb_[3] > _ex1_  _ex1_ = _cb_[1] + _cb_[3]  ok
					if _cb_[2] + _cb_[4] > _ey1_  _ey1_ = _cb_[2] + _cb_[4]  ok
				next
				_dx_ = 0  _dy_ = 0
				if _ex0_ < 0  _dx_ = 0 - _ex0_ + 8  ok
				if _ey0_ < 0  _dy_ = 0 - _ey0_ + 8  ok
				if _dx_ != 0 or _dy_ != 0
					_moved_ = []
					for _p2_ in _aXY_
						_moved_ + [ _p2_[1], _p2_[2] + _dx_, _p2_[3] + _dy_ ]
					next
					_aXY_ = _moved_
					_movedR_ = []
					for _r2_ in _aRoute_
						_rp2_ = []
						for _bp2_ in _r2_[3]
							_rp2_ + [ _bp2_[1] + _dx_, _bp2_[2] + _dy_ ]
						next
						_movedR_ + [ _r2_[1], _r2_[2], _rp2_ ]
					next
					_aRoute_ = _movedR_
				ok
				_nW_ = ceil(max([ _nW_, _ex1_ + _dx_ + 8 ]))
				_nH_ = ceil(max([ _nH_, _ey1_ + _dy_ + 8 ]))
			ok
		else
			_lw_ = _nW_ - 2 * _mx_
			_lh_ = _nH_ - 2 * _my_
			if _bSwap_
				_lw_ = _nH_ - 2 * _my_
				_lh_ = _nW_ - 2 * _mx_
			ok

			_oGC_ = new stzGraphCanvas(This, [
				:Layout = This._DiagOpt(paOptions, "layoutmode", :Hierarchical),
				:Width  = max([ _lw_, 60 ]),
				:Height = max([ _lh_, 60 ]),
				:Clusters = This._ClusterPairs()
			])

			_aXY_ = []
			for _p_ in _oGC_.Positions()
				_px_ = _p_[2]
				_py_ = _p_[3]
				if _bSwap_
					_t_ = _px_
					_px_ = _py_
					_py_ = _t_
				ok
				if _cRank_ = "RL"  _px_ = _lh_ - _px_  ok
				if _cRank_ = "BT"  _py_ = _lh_ - _py_  ok
				_aXY_ + [ StzLower("" + _p_[1]), _px_ + _mx_, _py_ + _my_ ]
			next
			for _r_ in _oGC_.EdgeRoutes()
				_rp_ = []
				for _bp_ in _r_[3]
					_px_ = _bp_[1]
					_py_ = _bp_[2]
					if _bSwap_
						_t_ = _px_
						_px_ = _py_
						_py_ = _t_
					ok
					if _cRank_ = "RL"  _px_ = _lh_ - _px_  ok
					if _cRank_ = "BT"  _py_ = _lh_ - _py_  ok
					_rp_ + [ _px_ + _mx_, _py_ + _my_ ]
				next
				_aRoute_ + [ StzLower("" + _r_[1]), StzLower("" + _r_[2]), _rp_ ]
			next
		ok

		# THE BOXES MUST FIT THE RANK THEY LANDED IN. The layout spreads a rank
		# evenly across the available width and knows nothing about how wide a
		# node is drawn; the caller sets the box size and knows nothing about
		# how many nodes will share a rank. Neither side could see the
		# collision, so nothing prevented it: sixteen 96px nodes were placed
		# 82px apart in a 1400px picture and drawn ON TOP of one another --
		# found by rendering a 40-node tree and LOOKING at row five.
		#
		# dot solves this by growing the canvas. Ours is given, so the box
		# shrinks instead -- uniformly in both axes, because the node shapes are
		# drawn inside the box and squashing one axis alone deforms them (a
		# cylinder's cap stops being an ellipse in perspective). A caller who
		# genuinely wants the exact size it asked for, overlap included, passes
		# :FitBoxes = FALSE.
		if This._DiagOpt(paOptions, "fitboxes", 1)
			_nSc_ = This._RankFitScale(_aXY_, _nBoxW_, _nBoxH_)
			if _nSc_ < 1
				_nBoxW_ = max([ floor(_nBoxW_ * _nSc_), 6 ])
				_nBoxH_ = max([ floor(_nBoxH_ * _nSc_), 6 ])
				_nFsz_  = max([ floor(_nFsz_ * _nSc_), 5 ])
				_nRad_  = floor(_nRad_ * _nSc_)
			ok
		ok

		# A GPU TEXTURE HAS A MAXIMUM DIMENSION, and past it there is no
		# picture at all. wgpu's floor is 8192; a canvas wider than that
		# fails to allocate, the view is invalid, and the failure arrives
		# as a Rust panic from inside the driver -- no line of this
		# library in the trace and nothing naming the size that caused it.
		#
		# It is reachable by accident precisely because :Scale multiplies
		# a size the caller never typed: a 4064px diagram is fine and the
		# same diagram at :Scale = 3 is 12192 and cannot be drawn. So the
		# limit is checked HERE, where both numbers are known and can be
		# quoted back.
		if _nW_ > 8192 or _nH_ > 8192
			StzRaise("stzDiagram: this picture is " + _nW_ + "x" + _nH_ +
				", and a GPU texture cannot exceed 8192 in either axis. " +
				"At :Scale = " + _nScl_ + " the diagram's natural " +
				floor(_nW_ / _nScl_) + "x" + floor(_nH_ / _nScl_) +
				" is multiplied past that. Use a smaller :Scale, give " +
				"explicit :Width/:Height, or answer ToSVG() -- which has " +
				"no such limit and stays sharp at every zoom.")
		ok

		# the edge geometry aims under the outline that is drawn, so it
		# needs the radius this render settled on -- after any fit scaling
		@nEdgeCornerRad = _nRad_

		_oC_ = new stzCanvas(_nW_, _nH_)
		_oC_.SetBackground(_cBg_)

		# 1. CLUSTERS behind everything, each with its LABEL -- the box without
		#    the label is not what dot draws.
		#
		#    OUTERMOST FIRST, because each box is FILLED. In declaration
		#    order an outer cluster declared second painted its fill over
		#    the inner box that was already there, and the inner cluster
		#    vanished into it -- correct geometry, invisible result.
		#    _ClusterDepths sorts outermost first for exactly this.
		@aRenderClusRects = []
		# hoisted above the loop: the rect capture below reads it, and in
		# Ring a method local read before its assigning statement is not
		# an error but a stale or empty value
		_clstrip_ = _nFsz_ * 1.9
		for _cd_ in This._ClusterDepths()
			_cl_ = This._ClusterById(_cd_[1])
			if len(_cl_) = 0  loop  ok
			_aBox_ = This._ClusterBox(_cl_, _aXY_, _nBoxW_, _nBoxH_)
			if len(_aBox_) != 4  loop  ok
			_clids_ = []
			for _cm_ in _cl_[:nodes]  _clids_ + StzLower("" + _cm_)  next
			# the strip above the box belongs to the frame too -- the label
			# lives there, so a channel through it crosses the SURFACE
			@aRenderClusRects + [ _aBox_[1], _aBox_[2] - _clstrip_,
				_aBox_[3], _aBox_[4] + _clstrip_, _clids_ ]
			_oC_.Flush()
			# THE LABEL STRIP IS MEASURED FROM THE FONT, not a constant
			# (hoisted above the loop; history in the commit that sized it)
			_oC_.FillQ("#FFF8FE").StrokeQ(_cl_[:color], 2).
				AddRect(_aBox_[1], _aBox_[2] - _clstrip_, _aBox_[3],
					_aBox_[4] + _clstrip_)
			if isObject(_oFont_)
				# INSET FROM THE CORNER. At +10/-8 the label sat in the
				# angle of the frame with its ascenders touching the top
				# rule and its left edge on the side rule -- legible, and
				# visibly crammed. The inset scales with the font so it
				# stays proportional at any :Scale.
				_oC_.Flush()
				_oC_.AddTextQ("" + _cl_[:label],
					_aBox_[1] + _nFsz_ * 0.8,
					_aBox_[2] - _nFsz_ * 0.6).
					SetFontQ(_oFont_, _nFsz_ - 1).Color("#555555")
			ok
		next

		# 2. EDGES: clipped at the node boundary, routed in the requested
		#    spline style, and finished with an ARROWHEAD.
		#
		#    ROUTED, NOT JUST DRAWN. Every edge used to leave its node from
		#    the centre-line and cross the rank gap at the same middle
		#    height, so a parent's edges left as ONE line and split late,
		#    and two neighbouring parents' horizontal runs shared a channel
		#    and read as a crossing. Two disciplines fix both:
		#    - PORTS: a node's edges fan out from distinct points on its
		#      border, ordered by where they are going, so they never cross
		#      each other at birth.
		#    - LANES: each parent's orthogonal trunk crosses the rank gap at
		#      its own height, cycled among four, so neighbouring trunks do
		#      not overlap.
		_aE_ = This.Edges()
		_nEc_ = len(_aE_)
		_aPort_ = This._EdgePorts(_aE_, _aXY_, _nBoxW_, _nBoxH_, _cRank_, _aRoute_)
		for _ei_ = 1 to _nEc_
			_a_ = This._XYOf(_aXY_, "" + _aE_[_ei_][:from])
			_b_ = This._XYOf(_aXY_, "" + _aE_[_ei_][:to])
			if len(_a_) != 2 or len(_b_) != 2  loop  ok

			# A SELF-LOOP IS A LOOP, not a line of length zero. Both ends
			# clip to the same point, so the generic path drew nothing at
			# all and a state machine's "stay here" arrow was simply absent
			# from the picture -- the most complete kind of rendering bug,
			# because there is nothing wrong to notice.
			if StzLower("" + _aE_[_ei_][:from]) = StzLower("" + _aE_[_ei_][:to])
				This._DrawSelfLoop(_oC_, _a_, _nBoxW_, _nBoxH_, _cEdge_,
					_nEdgeW_, _cRank_, _cSpl_)
				loop
			ok

			# THE PORT IS APPLIED AT THE BOUNDARY, not to the centre.
			# It used to shift the node's CENTRE and then clip a box
			# around the shifted point -- a box that is not where the node
			# is. For a near-vertical edge that happened to land on the
			# real bottom edge and looked fine; for anything more sideways
			# the exit point sat off the node entirely, which is the
			# "edges leaving from nowhere" in a wide fan-out. _PortPoint
			# puts it on the real boundary, on the side the rank runs.
			_aBend_ = This._RouteOf(_aRoute_, "" + _aE_[_ei_][:from],
				"" + _aE_[_ei_][:to])
			if len(_aBend_) > 0
				This._DrawRoutedEdge(_oC_, _a_, _b_, _aBend_, _nBoxW_,
					_nBoxH_, _cEdge_, _nEdgeW_, _cSpl_, _cRank_,
					_aPort_[_ei_][1], _aPort_[_ei_][2], _aPort_[_ei_][5],
					"" + _aE_[_ei_][:from], "" + _aE_[_ei_][:to])
			else
				This._DrawEdgeXT(_oC_, _a_, _b_, _nBoxW_, _nBoxH_, _cEdge_,
					_nEdgeW_, _cSpl_, _cRank_, _aPort_[_ei_][3],
					_aPort_[_ei_][1], _aPort_[_ei_][2], _aPort_[_ei_][5],
					"" + _aE_[_ei_][:from], "" + _aE_[_ei_][:to])
			ok
		next

		# 2b. EDGE LABELS, drawn LAST of the edge work and on a plate of the
		#     background colour.
		#
		#     They were in the model, they reached the dot writer, and this
		#     tier simply never drew them -- an edge that said "fails check"
		#     in the data was an anonymous arrow in the picture, which is
		#     the difference between a diagram and a decoration.
		#
		#     The plate is not decoration either: a label sits ON its own
		#     edge, and dark text crossed by a grey line at x-height is
		#     genuinely hard to read. dot draws labels over a filled box for
		#     the same reason.
		if isObject(_oFont_) and _bELab_
			_aLabAt_ = []
			for _ei_ = 1 to _nEc_
				_cLab_ = StzTrim("" + _aE_[_ei_][:label])
				if _cLab_ = ""  loop  ok
				_a_ = This._XYOf(_aXY_, "" + _aE_[_ei_][:from])
				_b_ = This._XYOf(_aXY_, "" + _aE_[_ei_][:to])
				if len(_a_) != 2 or len(_b_) != 2  loop  ok

				_bSelf_ = 0
				if StzLower("" + _aE_[_ei_][:from]) =
				   StzLower("" + _aE_[_ei_][:to])  _bSelf_ = 1  ok

				if _bSelf_
					# BESIDE the loop, and CLEAR of it. The anchor is the
					# label's centre, so placing it a few pixels past the
					# loop's outer edge put half the plate ON the loop --
					# which, being background-coloured, erased the segment
					# it covered. Under ortho that was the whole right side
					# of the rectangle, so the loop read as two stray
					# horizontal lines. Offset by half the label's own
					# width, which is the only number that clears it.
					_lr_ = This._SelfLoopReach(_nBoxW_, _nBoxH_)
					_slw2_ = _oFont_.WidthOf(_cLab_, _nFsz_) + 8
					if _bSwap_
						_lax_ = _a_[1]
						_lay_ = _a_[2] - _nBoxH_ / 2 - _lr_ - _nFsz_
					else
						_lax_ = _a_[1] + _nBoxW_ / 2 + _lr_ +
							_slw2_ / 2 + 6
						_lay_ = _a_[2]
					ok
				else
					_aBend_ = This._RouteOf(_aRoute_, "" + _aE_[_ei_][:from],
						"" + _aE_[_ei_][:to])
					if len(_aBend_) > 0
						# a routed edge is labelled where it actually runs,
						# not on the straight line it never takes
						_mid_ = _aBend_[ ceil(len(_aBend_) / 2) ]
						_lax_ = _mid_[1]
						_lay_ = _mid_[2]
					else
						# BIASED TOWARDS THE TARGET, not the midpoint.
						# Widening a rank spreads the CHILDREN; the
						# midpoints of a fan-out stay bunched near the
						# parent however far apart the children get, so
						# labels placed at 0.5 crowded exactly where the
						# extra room was not. At the shared bias they
						# inherit the spread the layout just paid for.
						#
						# ON the real path, CENTRED, on its plate. A
						# beside-the-line placement was tried for dot
						# parity and reverted the same day: shifted half
						# its width toward the target, a label on a
						# rightward edge reached the NEXT edge's arrowhead
						# -- it traded a plate over its own stroke for ink
						# over somebody else's. The plate erases a few
						# pixels of the line it names, which is the
						# cheaper of the two collisions and the one dot's
						# own label boxes accept too.
						_lat_ = This._EdgePathAt(_a_, _b_, _nBoxW_,
							_nBoxH_, _cRank_, This._EdgeLabelBias(),
							_aPort_[_ei_][1], _aPort_[_ei_][2],
							_aPort_[_ei_][5])
						_lax_ = _lat_[1]
						_lay_ = _lat_[2]
					ok
				ok
				_aLabAt_ + [ _cLab_, _lax_, _lay_ ]
			next

			# NUDGE APART, because reserving the gap does not stop two
			# labels landing in the SAME part of it -- two edges leaving one
			# node into the same rank cross the gap side by side, and their
			# midpoints can be a few pixels apart. Each label that would
			# overlap one already placed is pushed along the rank axis into
			# the next free band.
			_aDone_ = []
			for _li_ = 1 to len(_aLabAt_)
				_cLab_ = _aLabAt_[_li_][1]
				_lw_ = _oFont_.WidthOf(_cLab_, _nFsz_) + 8
				_lh_ = _nFsz_ + 6
				_lx_ = _aLabAt_[_li_][2]
				_ly_ = _aLabAt_[_li_][3]
				for _try_ = 1 to 6
					_bHit_ = 0
					for _d_ in _aDone_
						if fabs(_lx_ - _d_[1]) < (_lw_ + _d_[3]) / 2 and
						   fabs(_ly_ - _d_[2]) < (_lh_ + _d_[4]) / 2
							_bHit_ = 1
							exit
						ok
					next
					if _bHit_ = 0  exit  ok
					if _bSwap_
						_lx_ += _lw_ * 0.55
					else
						_ly_ += _lh_ * 1.15
					ok
				next
				_aDone_ + [ _lx_, _ly_, _lw_, _lh_ ]

				_oC_.Flush()
				_oC_.FillQ(_cBg_).StrokeQ(_cBg_, 1).
					AddRect(_lx_ - _lw_ / 2, _ly_ - _lh_ / 2, _lw_, _lh_)
				_oC_.Flush()
				_oC_.AddTextQ(_cLab_, _lx_ - (_lw_ - 8) / 2,
					_ly_ + _nFsz_ / 3).
					SetFontQ(_oFont_, _nFsz_).
					Color(This.ContrastingTextColor(_cBg_))
			next
		ok

		# 3. NODES
		for _i_ = 1 to _nN_
			_cId_ = "" + _aNodes_[_i_][:id]
			_a_ = This._XYOf(_aXY_, _cId_)
			if len(_a_) != 2  loop  ok
			_cShape_ = This._NativeShapeOf(_aNodes_[_i_])
			_cFill_ = This._NativeFillOf(_aNodes_[_i_])
			_x0_ = _a_[1] - _nBoxW_ / 2
			_y0_ = _a_[2] - _nBoxH_ / 2
			_cStroke_ = This._DiagOpt(paOptions, "strokecolor", "#3A3A3A")

			# ROUNDED is the default look of these charts. A node that named a
			# real shape keeps it; a plain box becomes a rounded box.
			if StzLower("" + _cShape_) = "box"
				_oC_.Flush()
				_oC_.FillQ(_cFill_).StrokeQ(_cStroke_, 2).
					AddRoundRect(_x0_, _y0_, _nBoxW_, _nBoxH_, _nRad_)
			else
				StzDrawNodeShapeXT(_oC_, _cShape_, _x0_, _y0_,
					_nBoxW_, _nBoxH_, _cFill_, _cStroke_, 2)
			ok
		next

		# 4. LABELS INSIDE the node, in a colour that CONTRASTS with the fill.
		#    White text on a gold box is the failure this avoids, and
		#    stzDiagram already knows how to pick: ContrastingTextColor.
		if isObject(_oFont_)
			for _i_ = 1 to _nN_
				_cId_ = "" + _aNodes_[_i_][:id]
				_a_ = This._XYOf(_aXY_, _cId_)
				if len(_a_) != 2  loop  ok
				_cLb_ = "" + _aNodes_[_i_][:label]
				if _cLb_ = ""  _cLb_ = _cId_  ok
				_cLb_ = This._FitLabel(_cLb_, _oFont_, _nFsz_, _nBoxW_ - 18)
				_nTw_ = _oFont_.WidthOf(_cLb_, _nFsz_)
				_oC_.Flush()
				# THE SIZE DECIDES THE INK, and whether the ink needs
				# weight. White is the right colour on a saturated fill --
				# dark ink on a dark-ish saturated field reads muddy
				# whatever the ratio says -- but white on those fills sits
				# between WCAG's normal-text minimum and its LARGE-text
				# one, so at a small size it is not wrong, it is text that
				# must be bolder. StzReadableTextOn says which and says
				# when; this draws the emphasis rather than quietly
				# swapping to a colour nobody can read either.
				_aInk_ = StzReadableTextOn(
					This._NativeFillOf(_aNodes_[_i_]), _nFsz_, 0)
				_oC_.AddTextQ(_cLb_, _a_[1] - _nTw_ / 2, _a_[2] + _nFsz_ / 3).
					SetFontQ(_oFont_, _nFsz_).Color(_aInk_[1])
				if _aInk_[3]
					# FAUX BOLD: the same glyphs a fraction of a pixel
					# over, twice. A real bold face would be better and
					# needs a second font file the caller has not given
					# us; thickening the stem is what makes 3.4:1 legible
					# at 12px, and it is what the large-text rule is
					# actually asking for.
					_oC_.Flush()
					_oC_.AddTextQ(_cLb_, _a_[1] - _nTw_ / 2 + 0.6,
						_a_[2] + _nFsz_ / 3).
						SetFontQ(_oFont_, _nFsz_).Color(_aInk_[1])
					_oC_.Flush()
					_oC_.AddTextQ(_cLb_, _a_[1] - _nTw_ / 2 + 0.3,
						_a_[2] + _nFsz_ / 3 + 0.3).
						SetFontQ(_oFont_, _nFsz_).Color(_aInk_[1])
				ok
			next
		ok

		return _oC_

	def ToSVG()
		return This.ToCanvas().ToSVG()

	def ToSVGXT(paOptions)
		return This.ToCanvasXT(paOptions).ToSVG()

	def ToPNG(pcPath)
		return This.ToCanvas().ToPNG(pcPath)

	def ToPNGXT(pcPath, paOptions)
		return This.ToCanvasXT(paOptions).ToPNG(pcPath)

	#-- native-tier internals ------------------------------------------

	# How much the box must shrink for no two nodes to overlap: 1 when the
	# picture already fits, less when it does not.
	#
	# NOT the O(n^2) all-pairs distance it looks like. Nodes are bucketed into
	# ranks by y and the list is sorted ONCE on a composite key, so the closest
	# horizontal neighbour is the previous entry in the same bucket -- one pass
	# after a builtin sort, which keeps a 10,000-node picture out of a
	# 50-million-comparison loop written in Ring.
	def _RankFitScale(paXY, pnBoxW, pnBoxH)
		_rfN_ = len(paXY)
		if _rfN_ < 2  return 1  ok

		# 4px of tolerance: a rank is "the same y", not "the identical float"
		_rfA_ = []
		for _rfI_ = 1 to _rfN_
			_rfB_ = floor(paXY[_rfI_][3] / 4)
			_rfA_ + [ _rfB_ * 1000000 + paXY[_rfI_][2], _rfB_,
			          paXY[_rfI_][2], paXY[_rfI_][3] ]
		next
		_rfA_ = sort(_rfA_, 1)

		_rfMinX_ = -1
		_rfMinY_ = -1
		for _rfI_ = 2 to _rfN_
			if _rfA_[_rfI_][2] = _rfA_[_rfI_ - 1][2]
				# same rank -> a horizontal neighbour
				_rfD_ = _rfA_[_rfI_][3] - _rfA_[_rfI_ - 1][3]
				if _rfD_ > 0 and (_rfMinX_ < 0 or _rfD_ < _rfMinX_)
					_rfMinX_ = _rfD_
				ok
			else
				# a new rank -> the gap between two ranks
				_rfD_ = _rfA_[_rfI_][4] - _rfA_[_rfI_ - 1][4]
				if _rfD_ < 0  _rfD_ = -_rfD_  ok
				if _rfD_ > 0 and (_rfMinY_ < 0 or _rfD_ < _rfMinY_)
					_rfMinY_ = _rfD_
				ok
			ok
		next

		# 6px of air, so adjacent boxes read as two boxes and not as one wall
		_rfS_ = 1
		if _rfMinX_ > 0 and pnBoxW > 0
			_rfS_ = min([ _rfS_, _rfMinX_ / (pnBoxW + 6) ])
		ok
		if _rfMinY_ > 0 and pnBoxH > 0
			_rfS_ = min([ _rfS_, _rfMinY_ / (pnBoxH + 6) ])
		ok
		return _rfS_

	# rankdir, from the diagram's OWN SetLayout -- TB / BT / LR / RL.
	def _NativeRankDir()
		_c_ = StzLower("" + @cLayout)
		if _c_ = ""  _c_ = $cDefaultLayout  ok
		if _c_ = "topdown" or StzFindFirst(_c_, $acLayouts[:TopDown]) > 0
			return "TB"
		but _c_ = "bottomup" or StzFindFirst(_c_, $acLayouts[:BottomUp]) > 0
			return "BT"
		but _c_ = "leftright" or StzFindFirst(_c_, $acLayouts[:LeftRight]) > 0
			return "LR"
		but _c_ = "rightleft" or StzFindFirst(_c_, $acLayouts[:RightLeft]) > 0
			return "RL"
		ok
		return "TB"

	# One edge: clipped to both node boxes, routed in the requested spline
	# style, finished with an arrowhead. A centre-to-centre line that runs
	# UNDER the node is what a hand-rolled renderer draws; dot clips, so this
	# clips.
	# For each edge: [ portFrom, portTo, laneFrac ]. Ports are offsets along
	# the slot axis; the lane is where an ortho trunk crosses the rank gap.
	#
	# Ports are ORDERED BY DESTINATION: a parent's leftmost edge leaves from
	# its leftmost port. Assigned by rank order instead, two edges swap
	# within the box's own width and cross a pixel after leaving it.
	def _EdgePorts(paEdges, paXY, nBoxW, nBoxH, cRank, paRoutes)
		_epN_ = len(paEdges)
		_epRes_ = []
		for _epI_ = 1 to _epN_  _epRes_ + [ 0, 0, 0.5, 0, 0 ]  next
		_bV_ = 0
		if cRank = "LR" or cRank = "RL"  _bV_ = 1  ok    # slot axis = y
		_epBox_ = nBoxW
		if _bV_  _epBox_ = nBoxH  ok

		# fan OUT of each from-node, fan IN to each to-node
		for _epSide_ = 1 to 2
			_epKeys_ = []
			for _epI_ = 1 to _epN_
				_epId_ = StzLower("" + paEdges[_epI_][ iif(_epSide_ = 1, :from, :to) ])
				_epFound_ = 0
				for _epK_ = 1 to len(_epKeys_)
					if _epKeys_[_epK_][1] = _epId_
						_epKeys_[_epK_][2] + _epI_
						_epFound_ = 1
						exit
					ok
				next
				if NOT _epFound_
					_epKeys_ + [ _epId_, [ _epI_ ] ]
				ok
			next
			for _epK_ = 1 to len(_epKeys_)
				_epGrp_ = _epKeys_[_epK_][2]
				_epGn_ = len(_epGrp_)
				if _epGn_ < 2  loop  ok
				# order the group by where its OTHER end sits on the slot axis
				_epSort_ = []
				for _epJ_ = 1 to _epGn_
					_epE_ = paEdges[_epGrp_[_epJ_]]
					# ORDERED BY WHERE THE EDGE ACTUALLY COMES FROM, which
					# for a ROUTED edge is its nearest bend and not its
					# far-off source node. Sorting arrivals by the source's
					# position put the edge approaching from the left onto
					# the right-hand port whenever its route had carried it
					# around -- so the two crossed in the last few pixels
					# before the node, which is the one place a reader is
					# certain of what they are looking at.
					_epRt_ = This._RouteOf(paRoutes, "" + _epE_[:from],
						"" + _epE_[:to])
					_epC_ = 0
					_epGot_ = 0
					if len(_epRt_) > 0
						if _epSide_ = 1
							_epB_ = _epRt_[1]
						else
							_epB_ = _epRt_[ len(_epRt_) ]
						ok
						_epC_ = _epB_[ iif(_bV_, 2, 1) ]
						_epGot_ = 1
					ok
					if _epGot_ = 0
						_epOth_ = This._XYOf(paXY,
							"" + _epE_[ iif(_epSide_ = 1, :to, :from) ])
						if len(_epOth_) = 2
							_epC_ = _epOth_[ iif(_bV_, 2, 1) ]
						ok
					ok
					_epSort_ + [ _epC_, _epGrp_[_epJ_] ]
				next
				_epSort_ = sort(_epSort_, 1)
				# PROPORTIONAL TO THE BORDER, not a flat 14px per edge.
				# Two arrows arriving at one node were placed 14px apart
				# -- narrower than the arrowheads themselves, so they
				# overlapped and read as one thick arrow. The border a
				# node offers is what there is to share; 26px per edge
				# uses it and still caps at the border's width, so a
				# heavily-fanned node degrades to evenly packed rather
				# than to overlapping.
				# A FRACTION OF THE BORDER, never a count of pixels. Both
				# earlier versions were literals -- 14px per edge, then
				# 26px -- and a literal cannot know how wide the node is
				# or that :Scale has just doubled everything, so two
				# arrivals at a 200px box were placed 26px apart and read
				# as one arrow with a thick head. The border is the
				# resource being shared, so the share is expressed in it:
				# a third of it for two edges, all of it from four up.
				# THE ALIGNED EDGE OWNS THE CENTRE, and the others spread
				# AROUND it. The alignment pass moves a cell exactly onto
				# its counterpart so the edge between them can be a
				# straight column -- and an even port spread then handed
				# that same edge an offset, leaning it between two
				# perfectly aligned cells. Two fixes fighting: the layout
				# buying a spine and the ports spending it. So any member
				# of the fan whose far end sits exactly on this node's
				# own cross-position is pinned to port ZERO, and the rest
				# take successive steps to its left and right in their
				# sorted order. No aligned member: the even spread as
				# before.
				_epAt2_ = This._XYOf(paXY, _epKeys_[_epK_][1])
				_epAl_ = 0
				if len(_epAt2_) = 2
					_epNC_ = _epAt2_[ iif(_bV_, 2, 1) ]
					for _epJ_ = 1 to _epGn_
						if fabs(_epSort_[_epJ_][1] - _epNC_) < 1
							_epAl_ = _epJ_
							exit
						ok
					next
				ok
				_epSpread_ = (_epBox_ - 16) *
					min([ 1, (_epGn_ - 1) / 3 ])
				if _epSpread_ < 0  _epSpread_ = 0  ok
				_epStep_ = _epSpread_ / (_epGn_ - 1)
				for _epJ_ = 1 to _epGn_
					if _epAl_ > 0
						_epOff_ = _epStep_ * (_epJ_ - _epAl_)
					else
						_epOff_ = 0 - (_epSpread_ / 2) +
							(_epSpread_ * (_epJ_ - 1) / (_epGn_ - 1))
					ok
					_epRes_[ _epSort_[_epJ_][2] ][_epSide_] = _epOff_
				next
			next
		next

		# THE CORRIDOR VETO. A side entry is only honest when the run into
		# that border is EMPTY: an edge flattening along a rank to reach a
		# far cell passes over every same-rank cell between -- and a line
		# grazing a box reads as a link to it, which is exactly the
		# erroneous information the Principal named on the fan. So a side
		# landing is refused whenever any same-rank node stands strictly
		# between the target and the point the edge approaches from; the
		# aspect rule in _AttachPoint then keeps such an edge on the
		# rank-facing border, descending into its cell from above instead
		# of sliding in along the row.
		for _epI_ = 1 to _epN_
			_epTo_ = This._XYOf(paXY, "" + paEdges[_epI_][:to])
			if len(_epTo_) != 2  loop  ok
			_epRt2_ = This._RouteOf(paRoutes, "" + paEdges[_epI_][:from],
				"" + paEdges[_epI_][:to])
			if len(_epRt2_) > 0
				_epAp_ = _epRt2_[ len(_epRt2_) ]
			else
				_epAp_ = This._XYOf(paXY, "" + paEdges[_epI_][:from])
			ok
			if len(_epAp_) != 2  loop  ok
			_epLoT_ = min([ _epTo_[ iif(_bV_, 2, 1) ], _epAp_[ iif(_bV_, 2, 1) ] ])
			_epHiT_ = max([ _epTo_[ iif(_bV_, 2, 1) ], _epAp_[ iif(_bV_, 2, 1) ] ])
			_epRkT_ = _epTo_[ iif(_bV_, 1, 2) ]
			for _epP2_ in paXY
				if StzLower("" + _epP2_[1]) = StzLower("" + paEdges[_epI_][:to])
					loop
				ok
				if StzLower("" + _epP2_[1]) = StzLower("" + paEdges[_epI_][:from])
					loop
				ok
				# paXY rows are [ id, x, y ] -- one wider than the [ x, y ]
				# _XYOf answers, so the axis indices shift by one here
				_epC2_ = _epP2_[ iif(_bV_, 3, 2) ]
				_epR2_ = _epP2_[ iif(_bV_, 2, 3) ]
				if fabs(_epR2_ - _epRkT_) < nBoxH * 1.2 and
				   _epC2_ > _epLoT_ + 2 and _epC2_ < _epHiT_ - 2
					_epRes_[_epI_][5] = 1
					exit
				ok
			next
		next

		# ortho LANES: parents in one rank take successive channel heights,
		# cycled among four, so neighbouring trunks never share one
		_epP_ = []
		for _epI_ = 1 to _epN_
			_epId_ = StzLower("" + paEdges[_epI_][:from])
			_epAt_ = This._XYOf(paXY, _epId_)
			if len(_epAt_) != 2  loop  ok
			_epRk_ = floor(_epAt_[ iif(_bV_, 1, 2) ] / 4)
			_epSl_ = _epAt_[ iif(_bV_, 2, 1) ]
			_epSeen_ = 0
			for _epK_ = 1 to len(_epP_)
				if _epP_[_epK_][3] = _epId_  _epSeen_ = 1  exit  ok
			next
			if NOT _epSeen_
				_epP_ + [ (_epRk_ * 1000000) + _epSl_, _epRk_, _epId_ ]
			ok
		next
		_epP_ = sort(_epP_, 1)
		_epLanes_ = []
		_epPrevRk_ = -1
		_epC_ = 0
		for _epK_ = 1 to len(_epP_)
			if _epP_[_epK_][2] != _epPrevRk_
				_epPrevRk_ = _epP_[_epK_][2]
				_epC_ = 0
			ok
			_epLanes_ + [ _epP_[_epK_][3], 0.30 + (0.40 * (_epC_ % 4) / 3) ]
			_epC_++
		next
		for _epI_ = 1 to _epN_
			_epId_ = StzLower("" + paEdges[_epI_][:from])
			for _epK_ = 1 to len(_epLanes_)
				if _epLanes_[_epK_][1] = _epId_
					_epRes_[_epI_][3] = _epLanes_[_epK_][2]
					exit
				ok
			next
		next
		return _epRes_

	# [ [ clusterId, [ nodeIds ] ], ... ] -- the shape stzGraphCanvas asks
	# for. Passed as an OPTION rather than read off the object, so the
	# canvas stays a graph renderer and does not have to know what an
	# stzDiagram is.
	def _ClusterPairs()
		_cp_ = []
		for _cd_ in This._ClusterDepths()
			_cp_ + [ _cd_[1], _cd_[2], _cd_[3] ]
		next
		return _cp_

	# [ [ id, nodes, depth ], ... ] with depth 1 = outermost, sorted
	# outermost first.
	#
	# NESTING IS INFERRED, NOT DECLARED, and that is the design decision
	# here. A cluster whose node set is a SUBSET of another's IS inside it
	# -- the data already says so, and asking the author to repeat it in a
	# parent link would be a second statement of one fact, free to
	# disagree with the first. It also costs no API change: every existing
	# caller keeps working and gains nesting the moment its sets nest.
	#
	# PARTIAL OVERLAP IS REFUSED. Two clusters that share a node while
	# neither contains the other cannot both be drawn as boxes -- there is
	# no arrangement of two rectangles where each holds all its own members
	# and neither holds a stranger. Silently picking one to break would
	# produce a picture that lies about membership, so it is named instead.
	def _ClusterDepths()
		_n_ = len(@aClusters)
		_res_ = []
		for _i_ = 1 to _n_
			_ai_ = This._ClusterNodeSet(@aClusters[_i_])
			_d_ = 1
			for _j_ = 1 to _n_
				if _j_ = _i_  loop  ok
				_aj_ = This._ClusterNodeSet(@aClusters[_j_])
				if This._SetInside(_ai_, _aj_)
					# j contains i; if they are IDENTICAL only one can be
					# the outer, and the earlier declaration wins so the
					# result does not depend on list order twice over
					if This._SetInside(_aj_, _ai_)
						if _j_ < _i_  _d_++  ok
					else
						_d_++
					ok
				but This._SetsOverlap(_ai_, _aj_) and
				    NOT This._SetInside(_aj_, _ai_)
					# BOTH directions, not one. Checking only "is i inside
					# j" made every legitimate OUTER cluster refuse its own
					# child: Backend is not inside Data, they share nodes,
					# and the overlap branch fired -- so declaring a nesting
					# raised the error written to forbid a non-nesting.
					StzRaise("stzDiagram: clusters '" + @aClusters[_i_][:id] +
						"' and '" + @aClusters[_j_][:id] + "' share nodes " +
						"but neither contains the other. Two boxes cannot " +
						"both hold all their own members without one " +
						"holding a stranger -- nest one inside the other " +
						"(make its nodes a subset), or keep them disjoint.")
				ok
			next
			_res_ + [ "" + @aClusters[_i_][:id], @aClusters[_i_][:nodes], _d_ ]
		next
		# outermost first: the layout compacts inner groups before outer
		# ones, and the drawing paints outer boxes behind inner ones
		_ord_ = []
		for _i_ = 1 to len(_res_)
			_ord_ + [ _res_[_i_][3] * 100000 + _i_, _i_ ]
		next
		_ord_ = sort(_ord_, 1)
		_out_ = []
		for _o_ in _ord_  _out_ + _res_[ _o_[2] ]  next
		return _out_

	# WHERE ALONG ITS EDGE A LABEL SITS, as a fraction from source to
	# target. Named once because TWO places must agree about it: the
	# drawing, which puts the label there, and the demand below, which buys
	# the room. They are the same number seen from two sides -- a label
	# placed at 0.72 of the way to its target inherits 0.72 of the spread
	# between two targets, so the room needed between them is the label's
	# width DIVIDED by this. Get the two out of step and the layout pays
	# for space the label is not standing in.
	# The corner radius the nodes are drawn with, so the edge geometry can
	# aim under the outline rather than at the rectangle behind it.
	def _EdgeCorner()
		return @nEdgeCornerRad

	def _EdgeLabelBias()
		# THE MIDPOINT, because the arrowhead lives at the end. Biasing
		# toward the target was meant to let labels inherit a fan's
		# spread, and it did -- straight onto the arrowheads, where the
		# label's own background plate then erased the head it was
		# standing on. A label that hides the thing it describes is worse
		# than a label that crowds its neighbour, and crowding already
		# has an answer: the nudge below moves overlapping labels into
		# the next band, and the demand that widens the rank is computed
		# from THIS number, so both stay consistent with wherever it sits.
		return 0.5

	# Per-node extra half-width demand, in SLOT units, from the edge labels
	# arriving at each node.
	#
	# CHARGED TO THE TARGET, not to the edge. A label sits between two
	# ranks and no node owns it, so something has to; the target is the
	# right payer because a fan-out's labels spread the way its children
	# do -- widening the children is exactly what stops their labels
	# meeting. Charging the source instead would widen one rank too early
	# and leave the labels as crowded as before.
	#
	# Zero when the label is no wider than the node it points at, so an
	# ordinary diagram of short labels is laid out exactly as before.
	def _LabelDemand(oFont, nFsz, nBoxW, nSlot, bSwap)
		_ids_ = This.NodesIds()
		_nn_ = len(_ids_)
		_dem_ = []
		for _i_ = 1 to _nn_  _dem_ + 0  next
		if NOT isObject(oFont)  return _dem_  ok
		if nSlot <= 0  return _dem_  ok

		_pos_ = []
		for _i_ = 1 to _nn_  _pos_ + [ StzLower("" + _ids_[_i_]), _i_ ]  next

		for _e_ in This.Edges()
			_cl_ = StzTrim("" + _e_[:label])
			if _cl_ = ""  loop  ok
			# a self-loop's label is drawn beside the node, not between
			# ranks, and the derived-size pass already reserves for it
			if StzLower("" + _e_[:from]) = StzLower("" + _e_[:to])  loop  ok
			_at_ = 0
			for _p_ in _pos_
				if _p_[1] = StzLower("" + _e_[:to])  _at_ = _p_[2]  exit  ok
			next
			if _at_ = 0  loop  ok
			_w_ = oFont.WidthOf(_cl_, nFsz) + 10
			if bSwap
				# ranks run horizontally, so the label's HEIGHT is what
				# competes along the slot axis
				_w_ = nFsz + 8
			ok
			_need_ = (_w_ / This._EdgeLabelBias() - nBoxW) / 2
			if _need_ <= 0  loop  ok
			_d_ = _need_ / nSlot
			if _d_ > _dem_[_at_]  _dem_[_at_] = _d_  ok
		next
		return _dem_

	def _ClusterById(pcId)
		_c_ = StzLower("" + pcId)
		for _cl_ in @aClusters
			if StzLower("" + _cl_[:id]) = _c_  return _cl_  ok
		next
		return []

	def _ClusterNodeSet(aCluster)
		_s_ = []
		for _id_ in aCluster[:nodes]  _s_ + StzLower("" + _id_)  next
		return _s_

	def _SetInside(paA, paB)
		for _x_ in paA
			if StzFindFirst(_x_, paB) = 0  return 0  ok
		next
		return 1

	def _SetsOverlap(paA, paB)
		for _x_ in paA
			if StzFindFirst(_x_, paB) > 0  return 1  ok
		next
		return 0

	# How far a self-loop reaches beyond the node box. Named once because
	# TWO places need the same number: the drawing, and the derived-size
	# pass that has to reserve room for it -- a loop drawn into space the
	# canvas does not own is clipped away, which looks exactly like the
	# bug it replaced.
	def _SelfLoopReach(nBoxW, nBoxH)
		return max([ 22, min([ nBoxH * 0.95, 44 ]) ])

	# A loop leaving the node's side and returning to it, as dot draws one:
	# off the RIGHT for a top-down picture, off the TOP when the ranks run
	# left-to-right, so it never points back along the rank axis and gets
	# confused with an ordinary edge.
	def _DrawSelfLoop(oC, aAt, nBoxW, nBoxH, cColor, nWidth, cRank, cSpline)
		_R_ = This._SelfLoopReach(nBoxW, nBoxH)

		# ORTHO MEANS ORTHO, INCLUDING THIS ONE. The loop ignored the spline
		# setting and was always a curve, so a picture asked for
		# splines=ortho came back with every edge right-angled EXCEPT its
		# self-loops -- one rounded shape among the corners, which reads as
		# a mistake rather than a style. A rectangular loop is three
		# segments out of the same side the curve leaves from.
		if cSpline = "ortho"
			if cRank = "LR" or cRank = "RL"
				_od_ = nBoxW * 0.22
				_oy_ = aAt[2] - nBoxH / 2
				_pts_ = [ aAt[1] - _od_, _oy_,
				          aAt[1] - _od_, _oy_ - _R_,
				          aAt[1] + _od_, _oy_ - _R_,
				          aAt[1] + _od_, _oy_ ]
				_oend_ = [ aAt[1] + _od_, _oy_ ]
				_oprev_ = [ aAt[1] + _od_, _oy_ - _R_ ]
			else
				# UPWARD, not downward. A loop that leaves high and
				# returns low points its arrow DOWN -- the same direction
				# as every ordinary edge in a top-down picture -- so a
				# self-transition read as flow continuing rather than
				# returning. Leaving low and coming back high makes the
				# arrow oppose the rank direction, which is what says
				# "back to where you were" at a glance.
				_od_ = nBoxH * 0.22
				_ox_ = aAt[1] + nBoxW / 2
				_pts_ = [ _ox_, aAt[2] + _od_,
				          _ox_ + _R_, aAt[2] + _od_,
				          _ox_ + _R_, aAt[2] - _od_,
				          _ox_, aAt[2] - _od_ ]
				_oend_ = [ _ox_, aAt[2] - _od_ ]
				_oprev_ = [ _ox_ + _R_, aAt[2] - _od_ ]
			ok
			oC.Flush()
			oC.AddPolylineQ(_pts_).Stroke(cColor, nWidth)
			This._DrawArrow(oC, _oprev_, _oend_, cColor, nWidth, "line", cRank)
			return
		ok

		if cRank = "LR" or cRank = "RL"
			# leaves and re-enters the TOP edge
			_d_ = nBoxW * 0.22
			_p0_ = [ aAt[1] - _d_, aAt[2] - nBoxH / 2 ]
			_c1_ = [ aAt[1] - _d_ - _R_ * 0.4, aAt[2] - nBoxH / 2 - _R_ ]
			_c2_ = [ aAt[1] + _d_ + _R_ * 0.4, aAt[2] - nBoxH / 2 - _R_ ]
			_p3_ = [ aAt[1] + _d_, aAt[2] - nBoxH / 2 ]
		else
			# leaves LOW and re-enters HIGH on the right edge, so the
			# arrowhead opposes the rank direction and reads as a return
			_d_ = nBoxH * 0.22
			_p0_ = [ aAt[1] + nBoxW / 2, aAt[2] + _d_ ]
			_c1_ = [ aAt[1] + nBoxW / 2 + _R_, aAt[2] + _d_ + _R_ * 0.4 ]
			_c2_ = [ aAt[1] + nBoxW / 2 + _R_, aAt[2] - _d_ - _R_ * 0.4 ]
			_p3_ = [ aAt[1] + nBoxW / 2, aAt[2] - _d_ ]
		ok

		_pts_ = []
		for _si_ = 0 to 24
			_t_ = _si_ / 24
			_u_ = 1 - _t_
			_pts_ + (_u_*_u_*_u_ * _p0_[1] + 3*_u_*_u_*_t_ * _c1_[1] +
				3*_u_*_t_*_t_ * _c2_[1] + _t_*_t_*_t_ * _p3_[1])
			_pts_ + (_u_*_u_*_u_ * _p0_[2] + 3*_u_*_u_*_t_ * _c1_[2] +
				3*_u_*_t_*_t_ * _c2_[2] + _t_*_t_*_t_ * _p3_[2])
		next
		oC.Flush()
		oC.AddPolylineQ(_pts_).Stroke(cColor, nWidth)

		_n_ = len(_pts_)
		This._DrawArrow(oC, [ _pts_[_n_ - 3], _pts_[_n_ - 2] ], _p3_,
			cColor, nWidth, "line", cRank)

	def _RouteOf(paRoutes, cFrom, cTo)
		_rf_ = StzLower("" + cFrom)
		_rt_ = StzLower("" + cTo)
		for _r_ in paRoutes
			if _r_[1] = _rf_ and _r_[2] = _rt_  return _r_[3]  ok
		next
		return []

	# An edge that spans more than one rank, drawn THROUGH the bend points
	# the layout reserved for it.
	#
	# Without this an edge from rank 1 to rank 9 was a straight line and
	# crossed every box between them -- and no routing rule could have
	# saved it, because the edge had no presence in those ranks for
	# anything to route around. The dummy chain is what gives it one.
	#
	# CATMULL-ROM through the bends rather than a polyline: the bends are
	# where the edge must BE, not where it must turn a corner, and a curve
	# reading smoothly past a box is what distinguishes a routed edge from
	# a dog-leg. Ortho keeps its corners -- that is the point of ortho.
	def RenderClusterRects()
		return @aRenderClusRects

	# THE MINIMUM DISTANCE BETWEEN AN EDGE LINE AND ANY PARALLEL LINE -- a
	# frame rule, another channel. Named because it is a LEGIBILITY
	# quantity, not a geometric one: two lines a few pixels apart are
	# distinct on a good screen at 100% and one thick line to tired eyes
	# or in a thumbnail. Derived from the corner radius because that is
	# already scaled by :Scale, so the clearance grows with the render
	# instead of collapsing relative to it -- the fate of every literal
	# distance this file has shipped.
	def _LineClearance()
		return max([ 14, @nEdgeCornerRad * 2 + 4 ])

	# A horizontal channel at nY spanning [nX1, nX2], pushed OUT of every
	# cluster whose surface it would traverse and to which the edge is
	# FOREIGN -- neither endpoint a member. A member's edge may exit
	# through its own frame; a stranger's channel through it draws a
	# relationship with the cluster that does not exist. Pushed to
	# whichever free side is nearer the channel's own height.
	def _ForeignFreeChannel(nY, nX1, nX2, cFrom, cTo, bVert)
		_ffLo_ = min([ nX1, nX2 ])
		_ffHi_ = max([ nX1, nX2 ])
		_ffF_ = StzLower("" + cFrom)
		_ffT_ = StzLower("" + cTo)
		for _ffPass_ = 1 to 3
			_ffMoved_ = 0
			for _ffR_ in @aRenderClusRects
				if StzFindFirst(_ffF_, _ffR_[5]) > 0  loop  ok
				if StzFindFirst(_ffT_, _ffR_[5]) > 0  loop  ok
				if bVert
					_ffA_ = _ffR_[2]
					_ffB_ = _ffR_[2] + _ffR_[4]
					_ffC_ = _ffR_[1]
					_ffD_ = _ffR_[1] + _ffR_[3]
				else
					_ffA_ = _ffR_[1]
					_ffB_ = _ffR_[1] + _ffR_[3]
					_ffC_ = _ffR_[2]
					_ffD_ = _ffR_[2] + _ffR_[4]
				ok
				# does the run overlap the rect along its span, at a height
				# inside the rect?
				if _ffHi_ > _ffA_ and _ffLo_ < _ffB_ and
				   nY > _ffC_ and nY < _ffD_
					if nY - _ffC_ < _ffD_ - nY
						nY = _ffC_ - This._LineClearance()
					else
						nY = _ffD_ + This._LineClearance()
					ok
					_ffMoved_ = 1
				ok
			next
			if _ffMoved_ = 0  exit  ok
		next
		return nY

	def _DrawRoutedEdge(oC, aFrom, aTo, paBend, nBoxW, nBoxH, cColor, nWidth, cSpline, cRank, nPortA, nPortB, pBlockSide, cFromId, cToId)
		_pts_ = []
		_pts_ + [ aFrom[1], aFrom[2] ]
		for _b_ in paBend  _pts_ + [ _b_[1], _b_[2] ]  next
		_pts_ + [ aTo[1], aTo[2] ]

		# THE SAME ATTACHMENT AS EVERY OTHER EDGE. This clipped toward the
		# first bend instead, which is aim-directed clipping under another
		# name -- so a ROUTED edge left whichever border faced its first
		# bend, took no port, and arrived unported too. Every fault just
		# fixed for single-hop edges was still live here: an edge leaving
		# the SIDE of its node with a gap at the corner, and two routed
		# arrivals landing on the same point.
		#
		# It survived because the fix was verified on a picture whose
		# edges all span ONE rank. Two paths draw edges in this file and
		# only one of them was corrected -- the other kept the old rule
		# and the old faults, and looked fine wherever it was not used.
		# under ORTHO the arrival must be on the rank-facing border -- the
		# staircase below ends with a vertical drop, and a vertical drop
		# into a side border is a contradiction
		_qveto_ = pBlockSide
		if cSpline = "ortho"  _qveto_ = 1  ok
		_p_ = This._AttachPoint(aFrom, _pts_[2], nBoxW, nBoxH, nPortA,
			This._EdgeCorner(), cRank, 1, 0)
		_q_ = This._AttachPoint(aTo, _pts_[ len(_pts_) - 1 ], nBoxW, nBoxH,
			nPortB, This._EdgeCorner(), cRank, 0, _qveto_)
		_pts_[1] = _p_
		_pts_[ len(_pts_) ] = _q_

		_flat_ = []
		if cSpline = "ortho"
			# NO OBLIQUE LINES -- and NO CHANNELS AT ROW HEIGHT. The first
			# staircase folded each leg at the bend's own coordinates, and
			# the router places bends AT node rows, so the horizontal runs
			# lay exactly along the ranks: the Web-to-Logger run passed
			# through the API row and read as an API-to-API link -- the
			# false-link sin in orthogonal form. The rank GAPS are node-free
			# by construction, so that is where every horizontal belongs.
			# Five segments, the classic ortho long edge and the Principal's
			# red path: drop into the first gap, run to the free column the
			# router found, descend it, run to the target's column in the
			# last gap, drop in.
			_ob1_ = _pts_[2]
			_obl_ = _pts_[ len(_pts_) - 1 ]
			_flat_ = []
			if cRank = "LR" or cRank = "RL"
				_oc1_ = (_p_[1] + _ob1_[1]) / 2
				_oc2_ = (_obl_[1] + _q_[1]) / 2
				_ofy_ = _obl_[2]
				_oc1_ = This._ForeignFreeChannel(_oc1_, _p_[2], _ofy_,
					cFromId, cToId, 1)
				_oc2_ = This._ForeignFreeChannel(_oc2_, _ofy_, _q_[2],
					cFromId, cToId, 1)
				_flat_ + _p_[1]   _flat_ + _p_[2]
				_flat_ + _oc1_    _flat_ + _p_[2]
				_flat_ + _oc1_    _flat_ + _ofy_
				_flat_ + _oc2_    _flat_ + _ofy_
				_flat_ + _oc2_    _flat_ + _q_[2]
				_flat_ + _q_[1]   _flat_ + _q_[2]
			else
				_oc1_ = (_p_[2] + _ob1_[2]) / 2
				_oc2_ = (_obl_[2] + _q_[2]) / 2
				_ofx_ = _obl_[1]
				_oc1_ = This._ForeignFreeChannel(_oc1_, _p_[1], _ofx_,
					cFromId, cToId, 0)
				_oc2_ = This._ForeignFreeChannel(_oc2_, _ofx_, _q_[1],
					cFromId, cToId, 0)
				_flat_ + _p_[1]   _flat_ + _p_[2]
				_flat_ + _p_[1]   _flat_ + _oc1_
				_flat_ + _ofx_    _flat_ + _oc1_
				_flat_ + _ofx_    _flat_ + _oc2_
				_flat_ + _q_[1]   _flat_ + _oc2_
				_flat_ + _q_[1]   _flat_ + _q_[2]
			ok
		but cSpline = "line" or cSpline = "polyline"
			for _pt_ in _pts_  _flat_ + _pt_[1]  _flat_ + _pt_[2]  next
		else
			_flat_ = This._SmoothThrough(_pts_)
		ok
		# the same cut-for-the-head contract as a single-hop edge: the
		# stroke stops where the arrow begins, so the head is whole at any
		# arrival angle
		_cut_ = This._ArrowCut(_flat_, 9 + nWidth * 2)
		oC.Flush()
		oC.AddPolylineQ(_cut_[1]).Stroke(cColor, nWidth)
		This._DrawArrowHead(oC, _cut_[2], _cut_[3], cColor)

	# Catmull-Rom through every point, sampled. Passes THROUGH its control points,
	# unlike the quadratic used for a single hop, which is what a route needs:
	# the bends are reserved space, not suggestions.
	def _SmoothThrough(paPts)
		_n_ = len(paPts)
		if _n_ < 3
			_o_ = []
			for _pt_ in paPts  _o_ + _pt_[1]  _o_ + _pt_[2]  next
			return _o_
		ok
		_o_ = []
		for _i_ = 1 to _n_ - 1
			_p0_ = paPts[ max([ 1, _i_ - 1 ]) ]
			_p1_ = paPts[_i_]
			_p2_ = paPts[_i_ + 1]
			_p3_ = paPts[ min([ _n_, _i_ + 2 ]) ]
			for _s_ = 0 to 7
				_t_ = _s_ / 8
				_t2_ = _t_ * _t_
				_t3_ = _t2_ * _t_
				_o_ + (0.5 * ((2 * _p1_[1]) +
					(0 - _p0_[1] + _p2_[1]) * _t_ +
					(2 * _p0_[1] - 5 * _p1_[1] + 4 * _p2_[1] - _p3_[1]) * _t2_ +
					(0 - _p0_[1] + 3 * _p1_[1] - 3 * _p2_[1] + _p3_[1]) * _t3_))
				_o_ + (0.5 * ((2 * _p1_[2]) +
					(0 - _p0_[2] + _p2_[2]) * _t_ +
					(2 * _p0_[2] - 5 * _p1_[2] + 4 * _p2_[2] - _p3_[2]) * _t2_ +
					(0 - _p0_[2] + 3 * _p1_[2] - 3 * _p2_[2] + _p3_[2]) * _t3_))
			next
		next
		_o_ + paPts[_n_][1]
		_o_ + paPts[_n_][2]
		return _o_

	# WHERE an edge meets a node: a point ON THE BOUNDARY, on the side the
	# rank direction says edges leave and arrive from.
	#
	# This replaces clipping a ray against the box. Clipping is the right
	# tool when an edge may come from any direction; in a LAYERED drawing
	# it never does -- everything leaves the bottom and arrives at the top
	# (or the sides, turned) -- and clipping a ray that had been aimed
	# through a PORT-SHIFTED centre put the exit point on a box that was
	# not where the node is.
	def _PortPoint(aCentre, nPort, nBoxW, nBoxH, cRank, bOut)
		_hw_ = nBoxW / 2
		_hh_ = nBoxH / 2
		if cRank = "LR"
			if bOut  return [ aCentre[1] + _hw_, aCentre[2] + nPort ]  ok
			return [ aCentre[1] - _hw_, aCentre[2] + nPort ]
		but cRank = "RL"
			if bOut  return [ aCentre[1] - _hw_, aCentre[2] + nPort ]  ok
			return [ aCentre[1] + _hw_, aCentre[2] + nPort ]
		but cRank = "BT"
			if bOut  return [ aCentre[1] + nPort, aCentre[2] - _hh_ ]  ok
			return [ aCentre[1] + nPort, aCentre[2] + _hh_ ]
		ok
		if bOut  return [ aCentre[1] + nPort, aCentre[2] + _hh_ ]  ok
		return [ aCentre[1] + nPort, aCentre[2] - _hh_ ]

	# THE EDGE GRAMMAR, learned by rendering the same diagrams through
	# dot.exe and putting the pictures side by side. Three rules, and the
	# previous model broke all three:
	#
	# 1. AN EDGE IS AIMED AT ITS TARGET. The exit point sits on the source
	#    border in the target's direction and the path runs essentially
	#    straight -- the angles separate a fan by themselves, which is why
	#    dot needs no port spreading. The old model forced a vertical
	#    tangent at BOTH ends (ELK's style, not dot's): every lateral edge
	#    became an S, and an S bows inward somewhere, which is exactly the
	#    "not an outer arc" a reader notices.
	#
	# 2. THE DEPARTURE IS SOFT, THE ARRIVAL IS STRAIGHT. The curve leaves
	#    leaning along the rank axis and straightens into the aim line --
	#    one bend, always outward. The arrival tangent IS the aim, so the
	#    arrowhead points the way the line actually travels.
	#
	# 3. THE LINE IS CUT FOR THE ARROW. dot shortens the spline by the
	#    head's length and sets the tip exactly on the border. Drawing the
	#    full line and stamping a head over it leaves the line poking past
	#    the head at any angle the stamp did not cover -- the "arrows not
	#    always visible" of every hand-rolled renderer.
	#
	# One geometry, read three times: the stroke, the arrowhead, and the
	# label all sample THIS path.

	# The path between two BORDER points: a cubic that departs along the
	# rank axis and arrives along the straight aim. Flat [x,y,...] samples.
	# THE EDGE GRAMMAR, v3 -- from the Principal's own reference sketch,
	# which settled a question two earlier grammars got wrong in opposite
	# ways. v1 forced BOTH tangents vertical: every lateral edge ballooned
	# into an S. v2 (dot-derived) departed vertical and arrived along the
	# aim: arrivals grazed their borders, and a fan BRAIDED -- the control
	# scales with length, so a far edge stayed vertical longest, descended
	# deepest, then cut flat across every nearer arc. The reference shows
	# the mirror: DEPART ALONG THE AIM, so the fan spreads immediately and
	# a farther target means a flatter leave that stays HIGHER -- arcs
	# nested like onion layers, unable to cross -- and ARRIVE PERPENDICULAR
	# to the landed border, so every head meets its surface square.
	#
	# An aligned pair keeps its straight spine: aim and perpendicular
	# coincide, both controls sit on the centre line.
	#
	# pQSide: which border the arrival landed on (from _AttachPoint) --
	# perpendicular means the RANK axis into a rank-facing border and the
	# SLOT axis into a side border.
	def _EdgePathFlat(aP, aQ, cRank, pQSide)
		_gdx_ = aQ[1] - aP[1]
		_gdy_ = aQ[2] - aP[2]
		_glen_ = sqrt(_gdx_ * _gdx_ + _gdy_ * _gdy_)
		if _glen_ < 0.001
			return [ aP[1], aP[2], aQ[1], aQ[2] ]
		ok
		# departure control: along the aim -- the fan opens at once
		_gk_ = _glen_ * 0.35
		_c1_ = [ aP[1] + _gdx_ / _glen_ * _gk_, aP[2] + _gdy_ / _glen_ * _gk_ ]
		# arrival control: back along the landed border's own normal, its
		# reach bounded by the travel available on that axis so a shallow
		# edge turns inside the gap instead of hooking past its target
		_bH_ = 0
		if cRank = "LR" or cRank = "RL"  _bH_ = 1  ok
		if (pQSide and NOT _bH_) or (NOT pQSide and _bH_)
			# normal is the X axis
			_gax_ = fabs(_gdx_)
			_gk2_ = min([ _gk_, _gax_ * 0.9 ])
			_gsx_ = 1
			if _gdx_ < 0  _gsx_ = -1  ok
			_c2_ = [ aQ[1] - _gsx_ * _gk2_, aQ[2] ]
		else
			# normal is the Y axis
			_gax_ = fabs(_gdy_)
			_gk2_ = min([ _gk_, _gax_ * 0.9 ])
			_gsy_ = 1
			if _gdy_ < 0  _gsy_ = -1  ok
			_c2_ = [ aQ[1], aQ[2] - _gsy_ * _gk2_ ]
		ok
		_ga_ = []
		for _gi_ = 0 to 24
			_gt_ = _gi_ / 24
			_gu_ = 1 - _gt_
			_ga_ + (_gu_*_gu_*_gu_ * aP[1] + 3*_gu_*_gu_*_gt_ * _c1_[1] +
				3*_gu_*_gt_*_gt_ * _c2_[1] + _gt_*_gt_*_gt_ * aQ[1])
			_ga_ + (_gu_*_gu_*_gu_ * aP[2] + 3*_gu_*_gu_*_gt_ * _c1_[2] +
				3*_gu_*_gt_*_gt_ * _c2_[2] + _gt_*_gt_*_gt_ * aQ[2])
		next
		return _ga_

	# Walk back from the end of a flat polyline and CUT it nLen before its
	# tip: [ aShortenedFlat, aBase, aTip ]. The stroke is drawn to the cut,
	# the head owns the rest.
	def _ArrowCut(paFlat, nLen)
		_an_ = len(paFlat)
		if _an_ < 4  return [ paFlat, [ 0, 0 ], [ 0, 0 ] ]  ok
		_atx_ = paFlat[_an_ - 1]
		_aty_ = paFlat[_an_]
		_arem_ = nLen
		_ai_ = _an_ - 2
		while _ai_ >= 2
			_ax1_ = paFlat[_ai_ - 1]
			_ay1_ = paFlat[_ai_]
			_ax2_ = paFlat[_ai_ + 1]
			_ay2_ = paFlat[_ai_ + 2]
			_aseg_ = sqrt((_ax2_ - _ax1_) * (_ax2_ - _ax1_) +
				(_ay2_ - _ay1_) * (_ay2_ - _ay1_))
			if _aseg_ >= _arem_ and _aseg_ > 0.0001
				_af_ = (_aseg_ - _arem_) / _aseg_
				_abx_ = _ax1_ + (_ax2_ - _ax1_) * _af_
				_aby_ = _ay1_ + (_ay2_ - _ay1_) * _af_
				_aout_ = []
				for _aj_ = 1 to _ai_
					_aout_ + paFlat[_aj_]
				next
				_aout_ + _abx_
				_aout_ + _aby_
				return [ _aout_, [ _abx_, _aby_ ], [ _atx_, _aty_ ] ]
			ok
			_arem_ -= _aseg_
			_ai_ -= 2
		end
		return [ paFlat, [ paFlat[1], paFlat[2] ], [ _atx_, _aty_ ] ]

	# The solid head: base to tip, wings perpendicular. It owns the whole
	# stretch the cut released, so nothing shows through it.
	def _DrawArrowHead(oC, aBase, aTip, cColor)
		_hdx_ = aTip[1] - aBase[1]
		_hdy_ = aTip[2] - aBase[2]
		_hl_ = sqrt(_hdx_ * _hdx_ + _hdy_ * _hdy_)
		if _hl_ < 0.001  return  ok
		_hdx_ = _hdx_ / _hl_
		_hdy_ = _hdy_ / _hl_
		_hw_ = _hl_ * 0.40
		_hpx_ = 0 - _hdy_
		_hpy_ = _hdx_
		oC.Flush()
		oC.FillQ(cColor).StrokeQ(cColor, 0).
			AddPolygon([ aTip[1], aTip[2],
				aBase[1] + _hpx_ * _hw_, aBase[2] + _hpy_ * _hw_,
				aBase[1] - _hpx_ * _hw_, aBase[2] - _hpy_ * _hw_ ])

	# Clip EXACTLY on the border -- no air. _ClipToBox pads by 2px, which
	# was right when the stroke ran all the way to the node and must not
	# overdraw its border; the head's TIP has to touch the border, as
	# dot's does, and 2px short reads as an arrow shying away from its
	# target.
	def _ClipExact(aCentre, aOther, nBoxW, nBoxH)
		_cdx_ = aOther[1] - aCentre[1]
		_cdy_ = aOther[2] - aCentre[2]
		if _cdx_ = 0 and _cdy_ = 0  return [ aCentre[1], aCentre[2] ]  ok
		_ctx_ = 1000000
		_cty_ = 1000000
		if _cdx_ != 0  _ctx_ = fabs(nBoxW / 2 / _cdx_)  ok
		if _cdy_ != 0  _cty_ = fabs(nBoxH / 2 / _cdy_)  ok
		_ct_ = min([ _ctx_, _cty_ ])
		return [ aCentre[1] + _cdx_ * _ct_, aCentre[2] + _cdy_ * _ct_ ]

	# The whole geometry for one single-hop edge, from CENTRES: clip both
	# ends toward the other, path, cut. [ aFlat, aBase, aTip ].
	# THE ATTACHMENT POINT: aimed at the other end, slid ALONG the border by
	# this edge's port, and pulled under the rounded outline at a corner.
	#
	# TWO FAULTS FIXED IN ONE PLACE, because they are both about where a
	# line meets a box.
	#
	# PORTS CAME BACK. Adopting dot's grammar, I dropped port spreading on
	# the reasoning that "the angles separate a fan by themselves". That
	# holds only when the targets are angularly apart. A broker fanning to
	# fourteen workers strung out sideways aims almost the same direction
	# at all of them, so every edge left the same point and ran parallel --
	# fourteen lines on top of each other, and any labels on them in the
	# same place. The aim still decides the DIRECTION; the port decides
	# where along the border it starts, which is what separates them.
	#
	# AND THE BOX IS ROUND. Clipping to a rectangle puts the endpoint
	# outside the drawn shape wherever the corner is rounded, so the line
	# stopped short of the node with a visible gap -- always at a corner,
	# never on a flat edge, which is exactly the pattern the Principal
	# circled. The point is pulled toward the centre by how far into the
	# corner region it fell, so it lands under the outline that is
	# actually drawn.
	def _AttachPoint(aCentre, aOther, nBoxW, nBoxH, nPort, nRad, cRank, bOut, pBlockSide)
		_ahw_ = nBoxW / 2
		_ahh_ = nBoxH / 2

		# THE SIDE IS THE RANK'S, NOT THE AIM'S -- and getting that wrong
		# is what put edges THROUGH other nodes. Clipping in the target's
		# direction attaches an edge to whichever border faces it, so an
		# edge to a distant sibling left the SIDE of its parent and
		# arrived at the SIDE of its child -- travelling along the child
		# row and crossing every node in between. A broker fanning to
		# fourteen workers drew fourteen lines through the workers.
		#
		# In a layered drawing every edge crosses the same gap: out of the
		# rank-facing border, into the one opposite. That is what keeps a
		# fan above its row instead of inside it. The tangent grammar is
		# unchanged -- it is the ATTACHMENT that is decided by rank, and
		# the aim still shapes the curve between the two points.
		# THE BORDER MUST FACE THE APPROACH -- for ARRIVALS. A shallow
		# approach pierces the rank-facing border at a grazing angle: the
		# head lies almost parallel to the surface it enters, which is
		# the wrongness the Principal circled. dot decides by clipping
		# along the aim, and the geometry of that clip is one comparison:
		# an aim shallower than the box's own aspect hits the SIDE first,
		# where it lands near-perpendicular. The 1.4 bias prefers the
		# side on borderline aims -- a clearly-sideways landing over an
		# ambiguous top graze. DEPARTURES stay rank-facing always: that
		# is guard 24's subject, and a fan must leave its parent
		# downward however lateral its targets.
		_adx2_ = fabs(aOther[1] - aCentre[1])
		_ady2_ = fabs(aOther[2] - aCentre[2])
		# pBlockSide is the CORRIDOR VETO, computed where the whole rank is
		# visible (in _EdgePorts): a side entry whose horizontal corridor
		# passes other same-rank nodes is refused there, because an edge
		# running the row into its target reads as a link with every cell
		# it grazes -- the erroneous info the Principal named.
		_bSide_ = 0
		if NOT bOut and NOT pBlockSide
			if cRank = "LR" or cRank = "RL"
				if _ady2_ > 0.001 and _adx2_ / _ady2_ < (nBoxW / nBoxH) * 1.4
					_bSide_ = 1
				ok
			else
				if _adx2_ > 0.001 and _ady2_ / _adx2_ < (nBoxH / nBoxW) * 1.4
					_bSide_ = 1
				ok
			ok
		ok

		_asx_ = 0
		_asy_ = 0
		if _bSide_
			if cRank = "LR" or cRank = "RL"
				# ranks run horizontally: the off-axis border is top/bottom
				if aOther[2] < aCentre[2]  _asy_ = 0 - _ahh_  else  _asy_ = _ahh_  ok
			else
				if aOther[1] < aCentre[1]  _asx_ = 0 - _ahw_  else  _asx_ = _ahw_  ok
			ok
		but cRank = "LR"
			if bOut  _asx_ = _ahw_  else  _asx_ = 0 - _ahw_  ok
		but cRank = "RL"
			if bOut  _asx_ = 0 - _ahw_  else  _asx_ = _ahw_  ok
		but cRank = "BT"
			if bOut  _asy_ = 0 - _ahh_  else  _asy_ = _ahh_  ok
		else
			if bOut  _asy_ = _ahh_  else  _asy_ = 0 - _ahh_  ok
		ok

		# the port spreads the attachment ALONG that border, which is what
		# separates the members of a fan from each other
		# A SIDE LANDING TAKES THE BORDER'S CENTRE, not the group port.
		# Ports are shares of ONE border, allocated before anyone knew
		# which border each edge would land on -- so a side-lander
		# arriving with a port meant for the TOP border was pushed to the
		# very corner of the side (34px of border, a 30px port: 2px from
		# the corner). The centre of the side border is "a bit down" from
		# the corner by construction, which is the red path the Principal
		# drew. Two edges landing on the SAME side border will overlap at
		# its centre -- accepted until a real diagram produces the case.
		if _bSide_  nPort = 0  ok

		_apx_ = aCentre[1] + _asx_
		_apy_ = aCentre[2] + _asy_
		if _asx_ = 0
			_apx_ += nPort
			_alim_ = _ahw_ - 2
			if _apx_ - aCentre[1] > _alim_      _apx_ = aCentre[1] + _alim_  ok
			if _apx_ - aCentre[1] < 0 - _alim_  _apx_ = aCentre[1] - _alim_  ok
		else
			_apy_ += nPort
			_alim_ = _ahh_ - 2
			if _apy_ - aCentre[2] > _alim_      _apy_ = aCentre[2] + _alim_  ok
			if _apy_ - aCentre[2] < 0 - _alim_  _apy_ = aCentre[2] - _alim_  ok
		ok

		# AND THE BOX IS ROUND. A point on the rectangle lies outside the
		# drawn outline wherever the corner is rounded, so the line
		# stopped short with a visible gap -- always at a corner, never on
		# a flat edge, which is exactly the pattern the Principal circled.
		if nRad > 0
			_aox_ = fabs(_apx_ - aCentre[1]) - (_ahw_ - nRad)
			_aoy_ = fabs(_apy_ - aCentre[2]) - (_ahh_ - nRad)
			if _aox_ > 0 and _aoy_ > 0
				_avx_ = aCentre[1] - _apx_
				_avy_ = aCentre[2] - _apy_
				_avl_ = sqrt(_avx_ * _avx_ + _avy_ * _avy_)
				if _avl_ > 0.001
					_ain_ = min([ nRad * 0.9, _avl_ * 0.5 ])
					_apx_ += _avx_ / _avl_ * _ain_
					_apy_ += _avy_ / _avl_ * _ain_
				ok
			ok
		ok
		# THE SOURCE END STARTS INSIDE THE NODE. Measured, the attachment
		# is exactly on the border -- and a long edge leaves it and sweeps
		# away immediately, so at a rounded corner the stroke and the
		# outline part company within a pixel or two and read as detached.
		# Nodes are painted AFTER edges, so an overlap costs nothing and
		# no rounding, antialiasing or curvature can open a gap the node
		# does not cover. The TARGET end is never overlapped: the arrow
		# tip belongs on the border, and burying it would hide the head.
		if bOut
			_avx2_ = aCentre[1] - _apx_
			_avy2_ = aCentre[2] - _apy_
			_avl2_ = sqrt(_avx2_ * _avx2_ + _avy2_ * _avy2_)
			if _avl2_ > 0.001
				_aov_ = min([ nBoxH * 0.25, nBoxW * 0.25, _avl2_ * 0.5 ])
				_apx_ += _avx2_ / _avl2_ * _aov_
				_apy_ += _avy2_ / _avl2_ * _aov_
			ok
		ok
		return [ _apx_, _apy_, _bSide_ ]

	def _EdgeGeometry(aFrom, aTo, nBoxW, nBoxH, cRank, nWidth, nPortA, nPortB, nRad, pBlockSide)
		_ep_ = This._AttachPoint(aFrom, aTo, nBoxW, nBoxH, nPortA, nRad, cRank, 1, 0)
		_eq_ = This._AttachPoint(aTo, aFrom, nBoxW, nBoxH, nPortB, nRad, cRank, 0, pBlockSide)
		_eqs_ = 0
		if len(_eq_) >= 3  _eqs_ = _eq_[3]  ok
		_efl_ = This._EdgePathFlat(_ep_, _eq_, cRank, _eqs_)
		return This._ArrowCut(_efl_, 9 + nWidth * 2)

	# The point at fraction t along that same path -- the label's anchor,
	# so a label sits ON the curve it names.
	def _EdgePathAt(aFrom, aTo, nBoxW, nBoxH, cRank, nT, nPortA, nPortB, pBlockSide)
		_ep_ = This._AttachPoint(aFrom, aTo, nBoxW, nBoxH, nPortA, This._EdgeCorner(), cRank, 1, 0)
		_eq_ = This._AttachPoint(aTo, aFrom, nBoxW, nBoxH, nPortB, This._EdgeCorner(), cRank, 0, pBlockSide)
		_eqs_ = 0
		if len(_eq_) >= 3  _eqs_ = _eq_[3]  ok
		_efl_ = This._EdgePathFlat(_ep_, _eq_, cRank, _eqs_)
		_en_ = len(_efl_) / 2
		_ek_ = floor(nT * (_en_ - 1)) + 1
		if _ek_ < 1  _ek_ = 1  ok
		if _ek_ > _en_  _ek_ = _en_  ok
		return [ _efl_[_ek_ * 2 - 1], _efl_[_ek_ * 2] ]

	def _DrawEdgeXT(oC, aFrom, aTo, nBoxW, nBoxH, cColor, nWidth, cSpline, cRank, nLane, nPortA, nPortB, pBlockSide, cFromId, cToId)
		if cSpline = "ortho"
			This._DrawEdge(oC, aFrom, aTo, nBoxW, nBoxH, cColor, nWidth,
				cSpline, cRank, nLane, cFromId, cToId)
			return
		ok
		_dg_ = This._EdgeGeometry(aFrom, aTo, nBoxW, nBoxH, cRank, nWidth, nPortA, nPortB, This._EdgeCorner(), pBlockSide)
		if cSpline = "line" or cSpline = "polyline"
			_dp_ = This._AttachPoint(aFrom, aTo, nBoxW, nBoxH, nPortA, This._EdgeCorner(), cRank, 1, 0)
			_dq_ = This._AttachPoint(aTo, aFrom, nBoxW, nBoxH, nPortB, This._EdgeCorner(), cRank, 0, pBlockSide)
			_dg_ = This._ArrowCut([ _dp_[1], _dp_[2], _dq_[1], _dq_[2] ],
				9 + nWidth * 2)
		ok
		oC.Flush()
		oC.AddPolylineQ(_dg_[1]).Stroke(cColor, nWidth)
		This._DrawArrowHead(oC, _dg_[2], _dg_[3], cColor)

	def _DrawEdge(oC, aFrom, aTo, nBoxW, nBoxH, cColor, nWidth, cSpline, cRank, nLane, cFromId, cToId)
		_p_ = This._ClipToBox(aFrom, aTo, nBoxW, nBoxH)
		_q_ = This._ClipToBox(aTo, aFrom, nBoxW, nBoxH)

		switch cSpline
		on "ortho"
			# TRUNK AND CHANNEL, the way dot draws a tree: one stem leaves
			# the parent's border, runs along the parent's own channel
			# height, and drops into the child. A parent's edges overlap on
			# the trunk deliberately -- they ARE one stem until they split.
			# The old form crossed at the gap's midpoint for every edge, so
			# every parent in a rank shared one channel and neighbouring
			# families read as crossings.
			if cRank = "LR" or cRank = "RL"
				_sgn_ = 1
				if aTo[1] < aFrom[1]  _sgn_ = -1  ok
				_pe_ = aFrom[1] + _sgn_ * nBoxW / 2
				_qe_ = aTo[1] - _sgn_ * nBoxW / 2
				_chan_ = _pe_ + (_qe_ - _pe_) * nLane
				_chan_ = This._ForeignFreeChannel(_chan_, aFrom[2], aTo[2],
					cFromId, cToId, 1)
				oC.Flush()
				oC.AddPolylineQ([ _pe_, aFrom[2], _chan_, aFrom[2],
					_chan_, aTo[2], _qe_, aTo[2] ]).Stroke(cColor, nWidth)
				_p_ = [ _chan_, aTo[2] ]
				_q_ = [ _qe_, aTo[2] ]
			else
				_sgn_ = 1
				if aTo[2] < aFrom[2]  _sgn_ = -1  ok
				_pe_ = aFrom[2] + _sgn_ * nBoxH / 2
				_qe_ = aTo[2] - _sgn_ * nBoxH / 2
				_chan_ = _pe_ + (_qe_ - _pe_) * nLane
				_chan_ = This._ForeignFreeChannel(_chan_, aFrom[1], aTo[1],
					cFromId, cToId, 0)
				oC.Flush()
				oC.AddPolylineQ([ aFrom[1], _pe_, aFrom[1], _chan_,
					aTo[1], _chan_, aTo[1], _qe_ ]).Stroke(cColor, nWidth)
				_p_ = [ aTo[1], _chan_ ]
				_q_ = [ aTo[1], _qe_ ]
			ok
		on "line"
			oC.Flush()
			oC.AddLineQ(_p_[1], _p_[2], _q_[1], _q_[2]).Stroke(cColor, nWidth)
		on "polyline"
			oC.Flush()
			oC.AddLineQ(_p_[1], _p_[2], _q_[1], _q_[2]).Stroke(cColor, nWidth)
		other
			oC.Flush()
			oC.AddPolylineQ(This._CurvePoints(_p_, _q_, cRank)).Stroke(cColor, nWidth)
		off

		This._DrawArrow(oC, _p_, _q_, cColor, nWidth, cSpline, cRank)

	# A quadratic bend, sampled. The control point leans along the RANK axis,
	# which is what makes dot's splines read as flowing down the hierarchy
	# rather than as an arbitrary arc.
	def _CurvePoints(aP, aQ, cRank)
		if cRank = "LR" or cRank = "RL"
			_cx_ = aP[1] + (aQ[1] - aP[1]) * 0.55
			_cy_ = aP[2]
		else
			_cy_ = aP[2] + (aQ[2] - aP[2]) * 0.55
			_cx_ = aP[1]
		ok
		_a_ = []
		for _i_ = 0 to 18
			_t_ = _i_ / 18
			_u_ = 1 - _t_
			_a_ + (_u_ * _u_ * aP[1] + 2 * _u_ * _t_ * _cx_ + _t_ * _t_ * aQ[1])
			_a_ + (_u_ * _u_ * aP[2] + 2 * _u_ * _t_ * _cy_ + _t_ * _t_ * aQ[2])
		next
		return _a_

	# The arrowhead points the way the edge ARRIVES. On a curve that is the
	# tangent at the end, which is NOT the straight line between centres --
	# an arrow pointing the wrong way is worse than no arrow.
	def _DrawArrow(oC, aP, aQ, cColor, nWidth, cSpline, cRank)
		_bx_ = aP[1]
		_by_ = aP[2]
		if cSpline = "ortho"
			if cRank = "LR" or cRank = "RL"
				_bx_ = aQ[1] - 10
				_by_ = aQ[2]
			else
				_bx_ = aQ[1]
				_by_ = aQ[2] - 10
			ok
		but cSpline != "line" and cSpline != "polyline"
			_a_ = This._CurvePoints(aP, aQ, cRank)
			_n_ = len(_a_)
			if _n_ >= 4
				_bx_ = _a_[_n_ - 3]
				_by_ = _a_[_n_ - 2]
			ok
		ok
		_dx_ = aQ[1] - _bx_
		_dy_ = aQ[2] - _by_
		_L_ = sqrt(_dx_ * _dx_ + _dy_ * _dy_)
		if _L_ < 0.001  return  ok
		_dx_ = _dx_ / _L_
		_dy_ = _dy_ / _L_
		_sz_ = 6 + nWidth * 2
		_px_ = 0 - _dy_
		_py_ = _dx_
		# STROKE WIDTH 0, explicitly. An arrowhead is a solid triangle, and
		# without this it inherits whatever outline the canvas last had --
		# which, after a cluster border, drew grey arrows outlined in
		# magenta. Setting only the fill leaves the other half of the style
		# to whoever ran before.
		oC.Flush()
		oC.Stroke(cColor, 0)
		oC.FillQ(cColor).AddPolygon([
			aQ[1], aQ[2],
			aQ[1] - _dx_ * _sz_ + _px_ * _sz_ * 0.45,
			aQ[2] - _dy_ * _sz_ + _py_ * _sz_ * 0.45,
			aQ[1] - _dx_ * _sz_ - _px_ * _sz_ * 0.45,
			aQ[2] - _dy_ * _sz_ - _py_ * _sz_ * 0.45 ])
		oC.Flush()

	# Where the segment from aCentre towards aOther leaves aCentre's box.
	def _ClipToBox(aCentre, aOther, nBoxW, nBoxH)
		_dx_ = aOther[1] - aCentre[1]
		_dy_ = aOther[2] - aCentre[2]
		if _dx_ = 0 and _dy_ = 0  return [ aCentre[1], aCentre[2] ]  ok
		_hw_ = nBoxW / 2 + 2
		_hh_ = nBoxH / 2 + 2
		_tx_ = 1000000
		_ty_ = 1000000
		if _dx_ != 0  _tx_ = fabs(_hw_ / _dx_)  ok
		if _dy_ != 0  _ty_ = fabs(_hh_ / _dy_)  ok
		_t_ = min([ _tx_, _ty_ ])
		return [ aCentre[1] + _dx_ * _t_, aCentre[2] + _dy_ * _t_ ]

	# Trim a label to the node width with an ellipsis, so a long title never
	# spills outside the shape it belongs to.
	def _FitLabel(cText, oFont, nSize, nMaxW)
		if NOT isObject(oFont)  return cText  ok
		if oFont.WidthOf(cText, nSize) <= nMaxW  return cText  ok
		_c_ = cText
		while len(_c_) > 1 and oFont.WidthOf(_c_ + "...", nSize) > nMaxW
			_c_ = StzSubStr(_c_, 1, len(_c_) - 1)
		end
		return _c_ + "..."

	# Whether the caller NAMED this option at all -- _DiagOpt cannot tell
	# "absent" from "given the default", and natural sizing turns on
	# exactly when a size was not named.
	def _HasOpt(paOptions, cKey)
		if NOT isList(paOptions)  return 0  ok
		for _ho_ in paOptions
			if isList(_ho_) and len(_ho_) = 2
				if StzLower("" + _ho_[1]) = StzLower("" + cKey)  return 1  ok
			ok
		next
		return 0

	def _DiagOpt(paOptions, cKey, xDefault)
		if NOT isList(paOptions)  return xDefault  ok
		for _p_ in paOptions
			if isList(_p_) and len(_p_) = 2
				if StzLower("" + _p_[1]) = StzLower("" + cKey)
					return _p_[2]
				ok
			ok
		next
		return xDefault

	def _XYOf(aXY, cId)
		_c_ = StzLower(cId)
		for _r_ in aXY
			if _r_[1] = _c_  return [ _r_[2], _r_[3] ]  ok
		next
		return []

	# The shape a node asked for, mapped into the drawable vocabulary. An
	# unknown name becomes a box rather than a refusal: a diagram that
	# would not draw at all because one node named a shape graphviz has and
	# this does not is a worse outcome than a box.
	# THE SAME TRANSLATION THE DOT WRITER USES, not a second one.
	#
	# This read the node's `type` and asked StzIsNodeShape whether it was a
	# shape. It never is: `start`, `process`, `decision`, `storage` are the
	# SEMANTIC vocabulary and `ellipse`, `box`, `diamond`, `cylinder` are
	# the geometric one, and translating between them is exactly what
	# _GetNodeShape was already written to do for ToDot. So every diagram
	# that named a type got the fallback -- a rounded box for a decision, a
	# rounded box for a database, a rounded box for everything -- while the
	# SAME diagram exported to dot came out with the right shapes. Two
	# renderers of one model disagreeing, with the correct answer already
	# in the file.
	#
	# Found by rendering the node types side by side and looking at them;
	# no assertion here had ever named a shape a TYPE should produce.
	def _NativeShapeOf(aNode)
		_c_ = ""
		if HasKey(aNode, "properties") and isList(aNode["properties"])
			if HasKey(aNode["properties"], "shape")
				_c_ = "" + aNode["properties"]["shape"]
			but HasKey(aNode["properties"], "type")
				_c_ = "" + aNode["properties"]["type"]
			ok
		ok
		_c_ = StzNodeShapeForType(_c_)
		if _c_ != "" and StzIsNodeShape(_c_)  return _c_  ok
		return :Box

	def _NativeFillOf(aNode)
		if HasKey(aNode, "properties") and isList(aNode["properties"])
			if HasKey(aNode["properties"], "color")
				return ResolveColor("" + aNode["properties"]["color"])
			but HasKey(aNode["properties"], "fillcolor")
				return ResolveColor("" + aNode["properties"]["fillcolor"])
			ok
		ok
		return "#2E4970"

	# The box that contains every member of a cluster, padded. Returns []
	# when no member has a position, so a cluster naming nodes that are not
	# in the diagram draws nothing instead of a rectangle at the origin.
	def _ClusterBox(aCluster, aXY, nBoxW, nBoxH)
		_bAny_ = 0
		_x0_ = 0  _y0_ = 0  _x1_ = 0  _y1_ = 0
		for _id_ in aCluster[:nodes]
			_a_ = This._XYOf(aXY, "" + _id_)
			if len(_a_) != 2  loop  ok
			_lx_ = _a_[1] - nBoxW / 2  _rx_ = _a_[1] + nBoxW / 2
			_ty_ = _a_[2] - nBoxH / 2  _by_ = _a_[2] + nBoxH / 2
			if NOT _bAny_
				_x0_ = _lx_  _x1_ = _rx_  _y0_ = _ty_  _y1_ = _by_
				_bAny_ = 1
			else
				if _lx_ < _x0_  _x0_ = _lx_  ok
				if _rx_ > _x1_  _x1_ = _rx_  ok
				if _ty_ < _y0_  _y0_ = _ty_  ok
				if _by_ > _y1_  _y1_ = _by_  ok
			ok
		next
		if NOT _bAny_  return []  ok
		# PADDING GROWS WITH WHAT IS NESTED INSIDE. A fixed 16 was right
		# while every cluster was a leaf; once one can contain another, the
		# outer box has to clear not just the inner box but the inner
		# LABEL, which is drawn 24px above it. At a fixed pad the two
		# borders landed within a few pixels of each other and the inner
		# label was written across the outer one.
		_pad_ = 16 + 34 * This._ClusterLevelsBelow(aCluster)
		return [ _x0_ - _pad_, _y0_ - _pad_,
			(_x1_ - _x0_) + 2 * _pad_, (_y1_ - _y0_) + 2 * _pad_ ]

	# How many nesting levels sit INSIDE this cluster: 0 for a leaf.
	def _ClusterLevelsBelow(aCluster)
		_mine_ = This._ClusterNodeSet(aCluster)
		_deep_ = 0
		for _o_ in @aClusters
			if StzLower("" + _o_[:id]) = StzLower("" + aCluster[:id])  loop  ok
			_os_ = This._ClusterNodeSet(_o_)
			# strictly inside: a subset that is not the whole thing
			if This._SetInside(_os_, _mine_) and NOT This._SetInside(_mine_, _os_)
				_d_ = 1 + This._ClusterLevelsBelow(_o_)
				if _d_ > _deep_  _deep_ = _d_  ok
			ok
		next
		return _deep_

	# DISPLAY, not View. In this very module `View` is already a NOUN for a
	# data projection -- stzGraphView, stzGraphQuery.ToView(), IsView() --
	# so one word carried two meanings in one namespace: "a filtered
	# projection of the graph" and "open a window on the picture".
	# Display() says only the second thing.
	#
	# View() stays as an alternative form because callers exist (the
	# diagram suite among them), and breaking working code over a naming
	# improvement is a worse trade than carrying an alias.
	def Display()

		# Generate DOT code
		_cDotCode_ = This.Dot()

		# Create stzDotCode instance and execute
		_oDotExec_ = new stzDotCode()
		_oDotExec_.SetCode(_cDotCode_)
		_oDotExec_.SetOutputFormat(@cOutputFormat)
		_oDotExec_.ExecuteAndView()

		#< @FunctionAlternativeForm

		def View()
			This.Display()

		#>

	#----------#
	#  EXPORT  #
	#----------#

	def ToHashlist()
		_aBase_ = super.ToHashlist()
		_aBase_["theme"] = @cTheme
		_aBase_["layout"] = @cLayout
		_aBase_["clusters"] = @aClusters
		_aBase_["annotations"] = @aoAnnotations
		_aBase_["templates"] = @aoTemplates
		return _aBase_

	def stzdiag()
		_oConv_ = new stzDiagramToStzDiag(This)
		return _oConv_.stzdiag()

		def ToStzDiag()
			return This.stzdiag()

		def ToStzDiagString()
			return This.stzdiag()
		
		def ToStzDiagFormat()
			return This.stzdiag()

		def StzDiagFormat()
			return This.stzdiag()

		def StzDiagString()
			return This.stzdiag()
		
		def DiagFormat()
			return This.stzdiag()

	def Dot()
		_oConv_ = new stzDiagramToDot(This)
		_cResult_ = _oConv_.Code()
		return _cResult_

		def ToDot()
			return This.Dot()

		def GraphvizDot()
			return This.Dot()

		def ToGraphvizDot()
			return This.Dot()

		def DotCode()
			return This.Dot()

		def Code()
			return This.Dot()

	def Json()
		_oConv_ = new stzDiagramToJson(This)
		return _oConv_.Code()

		def ToJson()
			return This.Json()

	def Mermaid()
		_oConv_ = new stzDiagramToMermaid(This)
		return _oConv_.Code()

		def ToMermaid()
			return This.Mermaid()

	#-----------------#
	#  WRITE TO FILE  # #TODO Shoulmd move to stzGraph level
	#-----------------#

	def WriteToFile()
		_oConv_ = new stzDiagramToStzDiag(This)
		_bSuccess_ = _oConv_.WriteToFile(This.Name() + ".stzdiag")
		return _bSuccess_

		def SaveToFile()
			return This.WritetoFile()

		def SaveFile()
			return This.WritetoFile()

		def SaveInFile()
			return This.WritetoFile()

		#--

		def WriteToStzDiagFile()
			return This.WriteToDiagFile()

		def WriteStzDiag()
			return This.WriteToDiagFile()

		#--

		def SaveToDiagFile()
			return This.WriteToDiagFile()

		def SaveToStzDiagFile()
			return This.WriteToDiagFile()

		def SaveToStzDiag()
			return This.WriteToDiagFile()

		#--

		def SaveInDiagFile()
			return This.WriteToDiagFile()

		def SaveInStzDiagFile()
			return This.WriteToDiagFile()

		def SaveInStzDiag()
			return This.WriteToDiagFile()

		#--

		def SaveDiagFile()
			return This.WriteToDiagFile()

		def SaveStzDiagFile()
			return This.WriteToDiagFile()

		def SaveStzDiag()
			return This.WriteToDiagFile()

	def WriteToFileXT(pcFolder)
		if not isstring(pcFolder)
			stzraise("Incorrect param type! pcFolder must be a string.")
		ok

		if NOT isValidFolder(pcFolder)
			stzraise("Incorrect folder name!")
		ok

		pcFolder = StzReplace(pcFolder, "/", "")
		pcFolder = StzReplace(pcFolder, "\", "")

		_oConv_ = new stzDiagramToStzDiag(This)
		_bSuccess_ = _oConv_.WriteToFile(pcFolder + "/" + This.Name() + ".stzdiag")
		return _bSuccess_

		#< @FunctionAlternativeForms

		def SaveInFolder(pcFolder)
			return This.WritetoFileXT(pcFolder)

		def SaveToFileXT(pcFolder)
			return This.WritetoFileXT(pcFolder)

		def SaveFileXT(pcFolder)
			return This.WritetoFileXT(pcFolder)

		def SaveInFileXT(pcFolder)
			return This.WritetoFileXT(pcFolder)

		#--

		def WriteToStzDiagFileXT(pcFolder)
			return This.WriteToDiagFileXT(pcFolder)

		def WriteStzDiagXT(pcFolder)
			return This.WriteToDiagFileXT(pcFolder)

		#--

		def SaveToDiagFileXT(pcFolder)
			return This.WriteToDiagFileXT(pcFolder)

		def SaveToStzDiagFileXT(pcFolder)
			return This.WriteToDiagFile(pcFolder)

		def SaveToStzDiagXT()
			return This.WriteToDiagFileXT(pcFolder)

		#--

		def SaveInDiagFileXT(pcFolder)
			return This.WriteToDiagFileXT(pcFolder)

		def SaveInStzDiagFileXT(pcFolder)
			return This.WriteToDiagFileXT(pcFolder)

		def SaveInStzDiagXT(pcFolder)
			return This.WriteToDiagFileXT(pcFolder)

		#--

		def SaveDiagFileXT(pcFolder)
			return This.WriteToDiagFileXT(pcFolder)

		def SaveStzDiagFileXT(pcFolder)
			return This.WriteToDiagFileXT(pcFolder)

		def SaveStzDiagXT(pcFolder)
			return This.WriteToDiagFileXT(pcFolder)

		#===

		def SaveToFileInFolder(pcFolder)
			return This.WritetoFileXT(pcFolder)

		def SaveFileInFolder(pcFolder)
			return This.WritetoFileXT(pcFolder)

		def SaveInFileInFolder(pcFolder)
			return This.WritetoFileXT(pcFolder)

		#--

		def WriteToStzDiagFileInFolder(pcFolder)
			return This.WriteToDiagFileXT(pcFolder)

		def WriteStzDiagInFolder(pcFolder)
			return This.WriteToDiagFileXT(pcFolder)

		#--

		def SaveToDiagFileInFolder(pcFolder)
			return This.WriteToDiagFileXT(pcFolder)

		def SaveToStzDiagFileInFolder(pcFolder)
			return This.WriteToDiagFile(pcFolder)

		def SaveToStzDiagInFolder()
			return This.WriteToDiagFileXT(pcFolder)

		#--

		def SaveInDiagFileInFolder(pcFolder)
			return This.WriteToDiagFileXT(pcFolder)

		def SaveInStzDiagFileInFolder(pcFolder)
			return This.WriteToDiagFileXT(pcFolder)

		def SaveInStzDiagInFolder(pcFolder)
			return This.WriteToDiagFileXT(pcFolder)

		#--

		def SaveDiagFileInFolder(pcFolder)
			return This.WriteToDiagFileXT(pcFolder)

		def SaveStzDiagFileInFolder(pcFolder)
			return This.WriteToDiagFileXT(pcFolder)

		def SaveStzDiagInFolder(pcFolder)
			return This.WriteToDiagFileXT(pcFolder)

		#>
	#---

	def WriteToDotFile()
		_oConv_ = new stzDiagramToDot(This)
		_bSuccess_ = _oConv_.WriteToFile(This.Name() + ".dot")
		return _bSuccess_

		def WriteInDotFile()
			return This.WriteToDotFile()

		def SaveDotFile()
			return This.WriteToDotFile()

		def SaveInDotFile()
			return This.WriteToDotFile()

	def WriteToDotFileXT(pcFolder)
		if not isstring(pcFolder)
			stzraise("Incorrect param type! pcFolder must be a string.")
		ok

		if NOT isValidFolder(pcFolder)
			stzraise("Incorrect folder name!")
		ok

		pcFolder = StzReplace(pcFolder, "/", "")
		pcFolder = StzReplace(pcFolder, "\", "")

		_oConv_ = new stzDiagramToDot(This)
		_bSuccess_ = _oConv_.WriteToFile(pcFolder + "/" + This.Name() + ".dot")
		return _bSuccess_

		#< @FunctionAlternativeForms

		def WriteInDotFileXT(pcFolder)
			return This.WriteToDotFileXT(pcFolder)

		def WriteToDotFileInFolder(pcFolder)
			return This.WriteToDotFileXT(pcFolder)

		def WriteDotFileInFolder(pcFolder)
			return This.WriteToDotFileXT(pcFolder)

		def WriteDotInFolder(pcFolder)
			return This.WriteToDotFileXT(pcFolder)

		def WriteToDotInFolder(pcFolder)
			return This.WriteToDotFileXT(pcFolder)

		#--

		def SaveToDotFileXT(pcFolder)
			return This.WriteToDotFileXT(pcFolder)

		def SaveInDotFileXT(pcFolder)
			return This.WriteToDotFileXT(pcFolder)

		def SaveToDotFileInFolder(pcFolder)
			return This.WriteToDotFileXT(pcFolder)

		def SaveDotFileInFolder(pcFolder)
			return This.WriteToDotFileXT(pcFolder)

		def SaveDotInFolder(pcFolder)
			return This.WriteToDotFileXT(pcFolder)

		def SaveToDotInFolder(pcFolder)
			return This.WriteToDotFileXT(pcFolder)

		#>

	#---

	def WriteToMermaidFile()
		_oConv_ = new stzDiagramToMermaid(This)
		_bSuccess_ = _oConv_.WriteToFile(This.Name() + ".mmd")
		return _bSuccess_

		def WriteInMermaidFile()
			return This.WriteToMermaidFile()

		def SaveMermaidFile()
			return This.WriteToMermaidFile()

		def SaveInMermaidFile()
			return This.WriteToMermaidFile()

	def WriteToMermaidFileXT(pcFolder)
		if not isstring(pcFolder)
			stzraise("Incorrect param type! pcFolder must be a string.")
		ok

		if NOT isValidFolder(pcFolder)
			stzraise("Incorrect folder name!")
		ok

		pcFolder = StzReplace(pcFolder, "/", "")
		pcFolder = StzReplace(pcFolder, "\", "")

		_oConv_ = new stzDiagramToMermaid(This)
		_bSuccess_ = _oConv_.WriteToFile(pcFolder + "/" + This.Name() + ".mmd")
		return _bSuccess_


		#< @FunctionAlternativeForms

		def WriteInMermaidFileXT(pcFolder)
			return This.WriteToMermaidFileXT(pcFolder)

		def WriteToMermaidFileInFolder(pcFolder)
			return This.WriteToMermaidFileXT(pcFolder)

		def WriteMermaidFileInFolder(pcFolder)
			return This.WriteToMermaidFileXT(pcFolder)

		def WriteMermaidInFolder(pcFolder)
			return This.WriteToMermaidFileXT(pcFolder)

		def WriteToMermaidInFolder(pcFolder)
			return This.WriteToMermaidFileXT(pcFolder)

		#--

		def SaveToMermaidFileXT(pcFolder)
			return This.WriteToMermaidFileXT(pcFolder)

		def SaveInMermaidFileXT(pcFolder)
			return This.WriteToMermaidFileXT(pcFolder)

		def SaveToMermaidFileInFolder(pcFolder)
			return This.WriteToMermaidFileXT(pcFolder)

		def SaveMermaidFileInFolder(pcFolder)
			return This.WriteToMermaidFileXT(pcFolder)

		def SaveMermaidInFolder(pcFolder)
			return This.WriteToMermaidFileXT(pcFolder)

		def SaveToMermaidInFolder(pcFolder)
			return This.WriteToMermaidFileXT(pcFolder)

		#>

	#--

	def WriteToJsonFile(pcFileName)
		_oConv_ = new stzDiagramToJson(This)
		_bSuccess_ = _oConv_.WriteToFile(This.Name() + ".json")
		return _bSuccess_

		def WriteInJsonFile()
			return This.WriteToJsonFile()

		def SaveJsonFile()
			return This.WriteToJsonFile()

		def SaveInJsonFile()
			return This.WriteToJsonFile()

	def WriteToJsonFileXT(pcFolder)
		if not isstring(pcFolder)
			stzraise("Incorrect param type! pcFolder must be a string.")
		ok

		if NOT isValidFolder(pcFolder)
			stzraise("Incorrect folder name!")
		ok

		pcFolder = StzReplace(pcFolder, "/", "")
		pcFolder = StzReplace(pcFolder, "\", "")

		_oConv_ = new stzDiagramToJson(This)
		_bSuccess_ = _oConv_.WriteToFile(pcFolder + "/" + This.Name() + ".json")
		return _bSuccess_


		#< @FunctionAlternativeForms

		def WriteInJsonFileXT(pcFolder)
			return This.WriteToJsonFileXT(pcFolder)

		def WriteToJsonFileInFolder(pcFolder)
			return This.WriteToJsonFileXT(pcFolder)

		def WriteJsonFileInFolder(pcFolder)
			return This.WriteToJsonFileXT(pcFolder)

		def WriteJsonInFolder(pcFolder)
			return This.WriteToJsonFileXT(pcFolder)

		def WriteToJsonInFolder(pcFolder)
			return This.WriteToJsonFileXT(pcFolder)

		#--

		def SaveToJsonFileXT(pcFolder)
			return This.WriteToJsonFileXT(pcFolder)

		def SaveInJsonFileXT(pcFolder)
			return This.WriteToJsonFileXT(pcFolder)

		def SaveToJsonFileInFolder(pcFolder)
			return This.WriteToJsonFileXT(pcFolder)

		def SaveJsonFileInFolder(pcFolder)
			return This.WriteToJsonFileXT(pcFolder)

		def SaveJsonInFolder(pcFolder)
			return This.WriteToJsonFileXT(pcFolder)

		def SaveToJsonInFolder(pcFolder)
			return This.WriteToJsonFileXT(pcFolder)

		#>

	#-----------------------------------------#
	# Get diagram overview with rules context #
	#-----------------------------------------#

	#NOTE // There also is an Explain() at the parent stzGraph level

	def Explain()
		_aExplanation_ = [
			:diagram = @cId,
			:structure = "",
			:rules = "",
			:effects = ""
		]
		
		_nNodes_ = This.NodeCount()
		_nEdges_ = This.EdgeCount()
		_aExplanation_[:structure] = "Diagram '" + @cId + "' contains " + _nNodes_ + " nodes and " + _nEdges_ + " edges."
		
		_nRules_ = len(@aoVisualRules)
		if _nRules_ = 0
			_aExplanation_[:rules] = "No visual rules defined."
		else
			_cRules_ = "Applied " + _nRules_ + " visual rule(s): "
			for i = 1 to _nRules_
				_cRules_ += @aoVisualRules[i].@cRuleId
				if i < _nRules_
					_cRules_ += ", "
				ok
			end
			_aExplanation_[:rules] = _cRules_
		ok
		
		_nNodesAffected_ = len(@aNodeRulesEffects)
		_nEdgesAffected_ = len(@aEdgesRulesEffects)
		
		if _nNodesAffected_ = 0 and _nEdgesAffected_ = 0
			_aExplanation_[:effects] = "No rules matched any elements."
		else
			_cEffects_ = ""
			if _nNodesAffected_ > 0
				_cEffects_ += ""+ _nNodesAffected_ + " node(s) enhanced"
			ok
			if _nEdgesAffected_ > 0
				if _cEffects_ != ""
					_cEffects_ += ", "
				ok
				_cEffects_ += ""+ _nEdgesAffected_ + " edge(s) enhanced"
			ok
			_aExplanation_[:effects] = _cEffects_ + "."
		ok
		
		return _aExplanation_

	#----------------------------------#
	#  IMPORT WITH SUBDIAGRAM SUPPORT  #
	#----------------------------------#

	def ImportDiag(cDiagString)
		# Parse first node of imported diagram
		_cFirstNodeId_ = This.ExtractFirstNodeId(cDiagString)
		
		if _cFirstNodeId_ = ""
			StzRaise("Cannot parse imported diagram - no nodes found")
		ok
		
		# Check if current diagram has nodes
		if This.NodeCount() > 0
			# Check if first node exists in current diagram
			if This.HasNode(_cFirstNodeId_)
				# Import as subdiagram under this node
				This.ImportAsSubdiagram(cDiagString, _cFirstNodeId_)
			else
				StzRaise("Import failed: First node '" + _cFirstNodeId_ + "' not found in current diagram. " +
					"Either add node '" + _cFirstNodeId_ + "', or clear the diagram with RemoveAllNodes()")
			ok
		else
			# Empty diagram - do normal import
			This.ParseAndImport(cDiagString)
		ok

	def ExtractFirstNodeId(cDiagString)
		_acLines_ = @split(cDiagString, char(10))
		_nLen_ = len(_acLines_)
		_bInNodesSection_ = 0

		for i = 1 to _nLen_
			_cLine_ = trim(_acLines_[i])
			if _cLine_ = "nodes"
				_bInNodesSection_ = 1
				loop
			ok
			
			if _bInNodesSection_ and _cLine_ != "" and
			   NOT StzFindFirst("label:", _cLine_) and
			   NOT StzFindFirst("type:", _cLine_) and
			   NOT StzFindFirst("color:", _cLine_)
				return _cLine_
			ok
			
			if _bInNodesSection_ and (_cLine_ = "edges" or _cLine_ = "clusters")
				exit
			ok
		end
	
	def ImportAsSubdiagram(cDiagString, cParentNodeId)
		_oTemp_ = new stzDiagram("temp")
		_oTemp_.ParseAndImport(cDiagString)
		
		_acNodes_ = _oTemp_.Nodes()
		_nLenNodes_ = len(_acNodes_)

		_acEdges_ = _oTemp_.Edges()
		_nLenEdges_ = len(_acEdges_)
		
		# Add all nodes EXCEPT the parent (which already exists)

		for i = 1 to _nLenNodes_
			if _acNodes_[i]["id"] != cParentNodeId
				This.AddNodeXTT(_acNodes_[i]["id"], _acNodes_[i]["label"], [
					:type = _acNodes_[i]["properties"]["type"], 
					:color = _acNodes_[i]["properties"]["color"]
				])
			ok
		end

		# Add all edges
		for i = 1 to _nLenEdges_
			_cFrom_ = _acEdges_[i]["from"]
			_cTo_ = _acEdges_[i]["to"]
			
			# All edges are added normally since parent node exists
			This.Connect(_cFrom_, _cTo_)
		end

	def ParseAndImport(cDiagString)
		_acLines_ = @split(cDiagString, char(10))
		_cCurrentSection_ = ""
		_cCurrentNode_ = ""
		_cLabel_ = ""
		_cType_ = ""
		_cColor_ = ""
		_aEdgesToAdd_ = []  # Store edges for later

		_nLen_ = len(_acLines_)
		for i = 1 to _nLen_
			_cLine_ = trim(_acLines_[i])
			if _cLine_ = "" or
			   StzLeft(_cLine_, 1) = "#"
				loop
			ok
			
			if StzFindFirst("diagram ", _cLine_)
				_cTitle_ = trim(StzMid(_cLine_, 10, stzlen(_cLine_) - 10))
				@cId = _cTitle_

			but _cLine_ = "properties"
				_cCurrentSection_ = "properties"

			but _cLine_ = "nodes"
				_cCurrentSection_ = "nodes"

			but _cLine_ = "edges"
				_cCurrentSection_ = "edges"

			but _cCurrentSection_ = "properties" and StzFindFirst(":", _cLine_)
				_aParts_ = @split(_cLine_, ":")
				_cKey_ = trim(_aParts_[1])
				_cValue_ = trim(_aParts_[2])

				if _cKey_ = "theme"
					This.SetTheme(_cValue_)
				but _cKey_ = "layout"
					This.SetLayout(_cValue_)
				ok

			but _cCurrentSection_ = "nodes"
				if NOT StzFindFirst("label:", _cLine_) and NOT StzFindFirst("type:", _cLine_) and NOT StzFindFirst("color:", _cLine_)
					if _cCurrentNode_ != "" and _cLabel_ != ""
						if _cType_ = "" _cType_ = $cDefaultNodeType ok
						if _cColor_ = "" _cColor_ = $cDefaultNodeColor ok
						This.AddNodeXTT(_cCurrentNode_, _cLabel_, [ :type = _cType_, :color = _cColor_ ])
					ok
					_cCurrentNode_ = _cLine_
					_cLabel_ = ""
					_cType_ = ""
					_cColor_ = ""

				but StzFindFirst("label:", _cLine_)
					_cLabel_ = StzMid(_cLine_, 9, stzlen(_cLine_) - 9)

				but StzFindFirst("type:", _cLine_)
					_cType_ = trim(StzMid(_cLine_, 7, stzlen(_cLine_) - 6))

				but StzFindFirst("color:", _cLine_)
					_cColor_ = trim(StzMid(_cLine_, 8, stzlen(_cLine_) - 7))
				ok

			but _cCurrentSection_ = "edges"

				# An edge is TWO lines: the arrow, then its label beneath it --
				#     a -> b
				#         label: "next"
				# This branch only ever matched the arrow line, so the label
				# was read by nobody and every imported edge came back
				# UNLABELLED. The writer has always emitted it.

				if StzFindFirst("->", _cLine_)
					_aEdgeParts_ = @split(_cLine_, "->")
					_cFrom_ = trim(_aEdgeParts_[1])
					_cTo_ = trim(_aEdgeParts_[2])
					_aEdgesToAdd_ + [_cFrom_, _cTo_, ""]  # Store for later

				but StzFindFirst("label:", _cLine_) and len(_aEdgesToAdd_) > 0
					# ... and it belongs to the arrow just read. Same
					# arithmetic the node labels use above.
					_aEdgesToAdd_[len(_aEdgesToAdd_)][3] =
						StzMid(_cLine_, 9, stzlen(_cLine_) - 9)
				ok
			ok
		end

		# Add last node
		if _cCurrentNode_ != "" and _cLabel_ != ""
			if _cType_ = "" _cType_ = $cDefaultNodeType ok
			if _cColor_ = "" _cColor_ = $cDefaultNodeColor ok
			This.AddNodeXTT(_cCurrentNode_, _cLabel_, [ :type = _cType_, :color = _cColor_ ])
		ok

		# Now add all edges -- with the label the file carried, when it had one
		_nLen_ = len(_aEdgesToAdd_)
		for i = 1 to _nLen_
			if _aEdgesToAdd_[i][3] != ""
				This.AddEdgeXT(_aEdgesToAdd_[i][1], _aEdgesToAdd_[i][2], _aEdgesToAdd_[i][3])
			else
				This.Connect(_aEdgesToAdd_[i][1], _aEdgesToAdd_[i][2])
			ok
		end
	
	#--------------------#
	#  FOCUS MANAGEMENT  #
	#--------------------#

	def ApplyFocusTo(acNodeIds)
	    # Reset all first
	    This.ResetAllNodeColors()
	    
	    # Apply focus to specified nodes
	    _nLen_ = len(acNodeIds)
	    for i = 1 to _nLen_
	        This.SetNodeProperty(acNodeIds[i], "color", @cFocusColor)
	    end
	
	def ResetAllNodeColors()
	    _aNodes_ = This.Nodes()
	    _nLen_ = len(_aNodes_)
	    for i = 1 to _nLen_
	        _cNodeId_ = _aNodes_[i]["id"]
	        This.SetNodeProperty(_cNodeId_, "color", @cNodeColor)
	    end

	#-------------------------#
	#  STYLE FILE MANAGEMENT  #
	#-------------------------#

	def LoadStyle(pSource)
		if isString(pSource)
			if StzRight(pSource, 8) = ".stzstyl"
				_oParser_ = new stzStylParser()
				_aStyle_ = _oParser_.ParseFile(pSource)
			else
				_oParser_ = new stzStylParser()
				_aStyle_ = _oParser_.Parse(pSource)
			ok
			
			This._ApplyStyle(_aStyle_)
			@aLoadedStyles + _aStyle_[:name]
		ok
	
	def _ApplyStyle(_aStyle_)
		# Apply theme
		if HasKey(_aStyle_, :theme) and _aStyle_[:theme] != ""
			This.SetTheme(_aStyle_[:theme])
		ok
		
		# Apply layout
		if HasKey(_aStyle_, :layout) and _aStyle_[:layout] != ""
			This.SetLayout(_aStyle_[:layout])
		ok
		
		# stzStylParser builds each section as a list of PAIRS --
		#     _aStyle_[section] + [ key, value ]
		# and Ring's + appends that pair as ONE element. Every section here
		# walked it as a flat [k,v,k,v] run and fell off the end (R2 on the
		# last pair), so LoadStyle() died on any .stzstyl file -- including the
		# one ExportToStyl() had just written. Same fault, same era, as the
		# .stzflow parser's _AddStep/_AddActor.
		# Apply colors
		if HasKey(_aStyle_, :colors) and len(_aStyle_[:colors]) > 0
			_nLen_ = len(_aStyle_[:colors])
			for i = 1 to _nLen_
				_cKey_ = _aStyle_[:colors][i][1]
				_cValue_ = _aStyle_[:colors][i][2]
				
				# Update color palette
				if HasKey(@aPalette[@cTheme], _cKey_)
					@aPalette[@cTheme][_cKey_] = _cValue_
				ok
			end
		ok
		
		# Apply fonts
		if HasKey(_aStyle_, :fonts) and len(_aStyle_[:fonts]) > 0
			_nLen_ = len(_aStyle_[:fonts])
			for i = 1 to _nLen_
				_cKey_ = _aStyle_[:fonts][i][1]
				pValue = _aStyle_[:fonts][i][2]
				
				if _cKey_ = "default"
					This.SetFont(pValue)
				but _cKey_ = "size"
					This.SetFontSize(pValue)
				ok
			end
		ok
		
		# Apply edge settings
		if HasKey(_aStyle_, :edges) and len(_aStyle_[:edges]) > 0
			_nLen_ = len(_aStyle_[:edges])
			for i = 1 to _nLen_
				_cKey_ = _aStyle_[:edges][i][1]
				pValue = _aStyle_[:edges][i][2]
				
				if _cKey_ = "style"
					This.SetEdgeStyle(pValue)
				but _cKey_ = "color"
					This.SetEdgeColor(pValue)
				but _cKey_ = "spline"
					This.SetSplines(pValue)
				but _cKey_ = "penwidth"
					This.SetEdgePenWidth(pValue)
				ok
			end
		ok
		
		# Apply node settings
		if HasKey(_aStyle_, :nodes) and len(_aStyle_[:nodes]) > 0
			_nLen_ = len(_aStyle_[:nodes])
			for i = 1 to _nLen_
				_cKey_ = _aStyle_[:nodes][i][1]
				pValue = _aStyle_[:nodes][i][2]
				
				if _cKey_ = "penwidth"
					This.SetNodePenWidth(pValue)
				but _cKey_ = "penstyle"
					This.SetNodePenStyle(pValue)
				but _cKey_ = "color"
					This.SetNodeColor(pValue)
				but _cKey_ = "strokecolor"
					This.SetStrokeColor(pValue)
				ok
			end
		ok
		
		# Apply focus settings
		if HasKey(_aStyle_, :focus) and len(_aStyle_[:focus]) > 0
			_nLen_ = len(_aStyle_[:focus])
			for i = 1 to _nLen_
				_cKey_ = _aStyle_[:focus][i][1]
				pValue = _aStyle_[:focus][i][2]
				
				if _cKey_ = "color"
					This.SetFocusColor(pValue)
				but _cKey_ = "penwidth"
					@nFocusPenWidth = pValue
				ok
			end
		ok
	
	def LoadedStyles()
		return @aLoadedStyles
	
	def ExportToStyl()
		_cStyl_ = 'style "' + @cId + '_style"' + char(10)
		_cStyl_ += '    theme: ' + @cTheme + char(10)
		_cStyl_ += '    layout: ' + @cLayout + char(10) + char(10)
		
		_cStyl_ += 'colors' + char(10)
		if HasKey(@aPalette, @cTheme)
			_acKeys_ = keys(@aPalette[@cTheme])
			_nAcKeys1Len_ = len(_acKeys_)
			for _iLoopAcKeys1_ = 1 to _nAcKeys1Len_
				_cKey_ = _acKeys_[_iLoopAcKeys1_]
				_cStyl_ += '    ' + _cKey_ + ': ' + @aPalette[@cTheme][_cKey_] + char(10)
			end
		ok
		_cStyl_ += char(10)
		
		_cStyl_ += 'fonts' + char(10)
		_cStyl_ += '    default: ' + @cFont + char(10)
		_cStyl_ += '    size: ' + @nFontSize + char(10) + char(10)
		
		_cStyl_ += 'edges' + char(10)
		_cStyl_ += '    style: ' + @cEdgeStyle + char(10)
		_cStyl_ += '    color: ' + @cEdgeColor + char(10)
		_cStyl_ += '    spline: ' + @cSplineType + char(10)
		_cStyl_ += '    penwidth: ' + @nEdgePenWidth + char(10)
		# the nodes block below has carried its penstyle all along; the edges
		# block did not, so a stylesheet could not round-trip one
		_cStyl_ += '    penstyle: ' + @cEdgePenStyle + char(10) + char(10)
		
		_cStyl_ += 'nodes' + char(10)
		_cStyl_ += '    penwidth: ' + @nNodePenWidth + char(10)
		_cStyl_ += '    penstyle: ' + @cNodePenStyle + char(10)
		_cStyl_ += '    color: ' + @cNodeColor + char(10)
		if @cNodeStrokeColor != ""
			_cStyl_ += '    strokecolor: ' + @cNodeStrokeColor + char(10)
		ok
		_cStyl_ += char(10)
		
		_cStyl_ += 'focus' + char(10)
		_cStyl_ += '    color: ' + @cFocusColor + char(10)
		
		return _cStyl_
	
	def WriteToStylFile(pcFilename)
		if NOT StzRight(pcFileName, 8) = ".stzstyl"
			pcFileName += ".stzstyl"
		ok
		write(pcFilename, This.ExportToStyl())

		def WriteStyl(pcFileName)
			This.WriteToStylFile(pcFilename)

#==========================================#
#  stzDiagramAnnotator - properties OVERLAY  #
#==========================================#

class stzDiagramAnnotator from stzObject

	@cType = ""
	@aNodeData = []

	def init(pcType)
		@cType = pcType

	def Type()
		return @cType

	def Annotate(pNodeId, _aData_)
		if CheckParams()
			if isList(_aData_) and IsWithNamedParamList(_aData_)
				_aData_ = _aData_[2]
			ok
		ok

		@aNodeData[pNodeId] = _aData_

	def NodeData(pNodeId)
		if HasKey(@aNodeData, pNodeId)
			return @aNodeData[pNodeId]
		ok

	def NodesData()
		return @aNodeData

	def ToHashlist()
		return [
			:type = @cType,
			:nodeData = @aNodeData
		]


#=======================================#
#  stzDiagramToStzDiag - NATIVE FORMAT  #
#=======================================#

class stzDiagramToStzDiag from stzObject

	@oDiagram
	@cStzDiagCode

	def init(poDiagram)
		if NOT ( isObject(poDiagram) and ring_classname(poDiagram) = "stzdiagram")
			StzRaise("Incorrect param type! poDiagram must be a stzDiagram object.")
		ok

		@oDiagram = poDiagram
		This._Generate()

	def _Generate()
		_cOutput_ = ""

		# Generating diagram attributes

		_cOutput_ += 'diagram "' +
			   @oDiagram.Id() + '"' + char(10) + char(10)

		_cOutput_ += "properties" + char(10)
		_cOutput_ += "    theme: " + Lower(@oDiagram.@cTheme) + char(10)
		_cOutput_ += "    layout: " + Lower(@oDiagram.@cLayout) + char(10) + char(10)

		# Generating the diagram title

		if @oDiagram.Title() != "" or trim(@oDiagram.Subtitle()) != ""
		    _cTitle_ = @oDiagram.Title()
		    _cSubtitle_ = @oDiagram.Subtitle()
		    if trim(_cSubtitle_) != ""
			_cTitle_ += " : " + _cSubtitle_
		    ok

		    _cOutput_ += '    labelloc="t";' + char(10)

		    _cOutput_ += '    label="' + _cTitle_
		    _cOutput_ += '";'
		    _cOutput_ += '    fontsize=16;'
		ok

		# Generating nodes

		_cOutput_ += "nodes" + char(10)
		_aNodes_ = @oDiagram.Nodes()
		_nLen_ = len(_aNodes_)

		for i = 1 to _nLen_
			_aNode_ = _aNodes_[i]
			_cOutput_ += "    " + _aNode_["id"] + char(10)
			_cOutput_ += "        label: " + This.EscapeString(_aNode_["label"]) + char(10)

			if _aNode_["properties"]["type"] != ""
				_cOutput_ += "        type: " + Lower(_aNode_["properties"]["type"]) + char(10)
			ok

			if _aNode_["properties"]["color"] != ""
				_cOutput_ += "        color: " + _aNode_["properties"]["color"] + char(10)
			ok

			_cOutput_ += char(10)
		end

		# Generating edges

		_aEdges_ = @oDiagram.Edges()
		_nLen_ = len(_aEdges_)

		if _nLen_ > 0
			_cOutput_ += "edges" + char(10)
			for i = 1 to _nLen_
				_aEdge_ = _aEdges_[i]
				_cOutput_ += "    " + _aEdge_["from"] + " -> " + _aEdge_["to"] + char(10)

				_cLabel_ = _aEdge_["label"]
				if _cLabel_ != ""
					_cOutput_ += "        label: " + This.EscapeString(_cLabel_) + char(10)
				ok

				_cOutput_ += char(10)
			end

		ok

		# Generating clusters

		_aClusters_ = @oDiagram.Clusters()
		_nLen_ = len(_aClusters_)
		if _nLen_ > 0
			_cOutput_ += "clusters" + char(10)

			for i = 1 to _nLen_
				_aCluster_ = _aClusters_[i]
				_cOutput_ += "    " + _aCluster_["id"] + char(10)
				_cOutput_ += "        label: " + This.EscapeString(_aCluster_["label"]) + char(10)
				_cNodeList_ = This.NodeListToString(_aCluster_["nodes"])
				_cOutput_ += "        nodes: [" + _cNodeList_ + "]" + char(10)
				_cOutput_ += "        color: " + _aCluster_["color"] + char(10)
				_cOutput_ += char(10)
			end
		ok

		# Generating annotations

		_aAnnotations_ = @oDiagram.AnnotationsQ()
		_nLen_ = len(_aAnnotations_)

		if _nLen_ > 0
			_cOutput_ += "annotations" + char(10)
			for i = 1 to _nLen_
				_aAnnot_ = _aAnnotations_[i]
				_cOutput_ += "    " + Lower(_aAnnot_.Type()) + char(10)

				_aAnnotData_ = _aAnnot_.NodesData()

				_acKeys_ = Keys(_aAnnotData_)
				_nLenK_ = len(_acKeys_)

				for j = 1 to _nLenK_
					_cNodeId_ = _acKeys_[j] 
					_cData_ = _aAnnotData_[_cNodeId_]
					_cOutput_ += "        " + String(_cNodeId_) + ": "
					_cOutput_ += This.DataToString(_cData_) + char(10)
				end
				_cOutput_ += char(10)
			end
		ok

		# Setting the DOT code

		@cStzDiagCode = _cOutput_

	def stzdiag()
		return @cStzDiagCode

		def stzdiagCode()
			return @cStzDiagCode

		def Content()
			return @cStzDiagCode

	def WriteToFile(pFilename)
		_oFile_ = fopen(pFilename, "w")
		fwrite(_oFile_, This.stzdiag())
		fclose(_oFile_)
		return 1

	def EscapeString(pStr)
		return '"' +
			Replace(pStr, '"', '\"') + '"'

	def NodeListToString(_aNodes_)
		_cResult_ = ""
		_nNodes1Len_ = len(_aNodes_)
		for _iLoopNodes1_ = 1 to _nNodes1Len_
			_cNode_ = _aNodes_[_iLoopNodes1_]
			_cResult_ += _cNode_ + ", "
		end
		if _cResult_ != ""
			_cResult_ = Left(_cResult_, stzlen(_cResult_) - 2)
		ok
		return _cResult_

	def DataToString(_aData_)
		if NOT @IsHashList(_aData_)
			return "null"
		ok

		_cResult_ = "{"
		_aKeysaData1_ = Keys(_aData_)
		_nKeysaData1Len_ = len(_aKeysaData1_)
		for _iLoopKeysaData1_ = 1 to _nKeysaData1Len_
			_cKey_ = _aKeysaData1_[_iLoopKeysaData1_]
			_cValue_ = _aData_[_cKey_]
			if isString(_cValue_)
				_cResult_ += _cKey_ + ": " + This.EscapeString(_cValue_) + ", "
			else
				_cResult_ += _cKey_ + ": " + String(_cValue_) + ", "
			ok
		end
		if _cResult_ != "{"
			_cResult_ = Left(_cResult_, stzlen(_cResult_) - 2)
		ok
		_cResult_ += "}"
		return _cResult_


#==================================#
#  stzDiagramToDot - GRAPHVIZ DOT  #
#==================================#

class stzDiagramToDot from stzObject

	@oDiagram
	@cDotCode

	def init(poDiagram)
		if NOT ( isObject(poDiagram) and

			find([ "stzdiagram", "stzorgchart", "stzworkflow" ],
				ring_classname(poDiagram)) )

			StzRaise("Incorrect param type! poDiagram must be a stzDiagram object.")
		ok

		@oDiagram = poDiagram
		This._Generate()


	def _Generate()
	
		_cOutput_ = ""
		
		# Apply visual rules if any
		if len(@oDiagram.@aoVisualRules) > 0
			@oDiagram.ApplyVisualRules()
		ok
		
		# Get theme
		_cTheme_ = This._GetTheme()
		
		# Start digraph
		_cOutput_ += 'digraph "' + @oDiagram.Id() + '" {' + char(10)
		
		# Graph attributes
		_cOutput_ += This._GenerateGraphAttributes(_cTheme_)
		
		# Add title/subtitle if present -- EITHER of them is enough, a subtitle on
		# its own used to be dropped here without a word
		if @oDiagram.Title() != "" or @oDiagram.Subtitle() != ""
		    _cOutput_ += '    labelloc="t";' + char(10)
		    _cTitle_ = char(10) + @oDiagram.Title()
		    if @oDiagram.Subtitle() != ""
		        _cTitle_ += char(10) + @oDiagram.Subtitle() + char(10)
		    ok
		    _cTitle_ += char(10) + char(10)
		    _cOutput_ += '    label="' + _cTitle_ + '";' + char(10)
		    _cOutput_ += '    fontsize=16;' + char(10) + char(10)
		ok
	
		# Node attributes  
		_cOutput_ += This._GenerateNodeAttributes(_cTheme_)
		
		# Edge attributes
		_cOutput_ += This._GenerateEdgeAttributes(_cTheme_)
		
		_cOutput_ += char(10)
		
		# Generate nodes
		_cOutput_ += This._GenerateNodes(_cTheme_)
		_cOutput_ += char(10)
		
		# Generate clusters (subgraphs)
		if len(@oDiagram.Clusters()) > 0
			_cOutput_ += char(10)
			
			_aDiagramClusters1_ = @oDiagram.Clusters()
			_nDiagramClusters1Len_ = len(_aDiagramClusters1_)
			for _iLoopDiagramClusters1_ = 1 to _nDiagramClusters1Len_
				_aCluster_ = _aDiagramClusters1_[_iLoopDiagramClusters1_]
				_cClusterId_ = "cluster_" + _aCluster_["id"]
				_cLabel_ = _aCluster_["label"]
				_cColor_ = _aCluster_["color"]
				
				_cOutput_ += '    subgraph ' + _cClusterId_ + ' {' + char(10)
				_cOutput_ += '        label="' + _cLabel_ + '";' + char(10)
				_cOutput_ += '        style=filled;' + char(10)
				_cOutput_ += '        color="' + _cColor_ + '";' + char(10)
				_cOutput_ += '        fillcolor="' + _cColor_ + '20";' + char(10)  # 20 = transparency
				
				# List nodes in cluster
				_aClusternodes1_ = _aCluster_["nodes"]
				_nClusternodes1Len_ = len(_aClusternodes1_)
				for _iLoopClusternodes1_ = 1 to _nClusternodes1Len_
					_cNodeId_ = _aClusternodes1_[_iLoopClusternodes1_]
					_cOutput_ += '        ' + This._SanitizeNodeId(_cNodeId_) + ';' + char(10)
				end
				
				_cOutput_ += '    }' + char(10)
			end
		ok
	
		# Generate edges
		_cOutput_ += This._GenerateEdges(_cTheme_)
		
		_cOutput_ += char(10) + "}"
		
		@cDotCode = _cOutput_
	
	def _GetTheme()
		_cTheme_ = StzLower(@oDiagram.@cTheme)
		if _cTheme_ = ""
			_cTheme_ = $cDefaultColorTheme
		ok
		return _cTheme_

	def _GenerateGraphAttributes(_cTheme_)
	    _cRankDir_ = This._GetRankDir()
	    _cFont_ = This._GetFont()
	    _nFontSize_ = This._GetFontSize()
	    
	    _cResult_ = '    graph [rankdir=' + _cRankDir_ + 
	               ', bgcolor=white' +
	               ', fontname="' + _cFont_ + '"' +
	               ', fontsize=' + _nFontSize_ +
	               ', splines=' + @oDiagram.@cSplineType +
	               ', nodesep=' + @oDiagram.@nNodeSep +
	               ', ranksep=' + @oDiagram.@nRankSep +
	               ', ordering=out' +
	               ', tooltip=" "'  #TODO // Has no effect
	    
	    if @oDiagram.@bConcentrate
	        _cResult_ += ', concentrate=true'
	    ok
	    
	    _cResult_ += ']' + char(10)
	    return _cResult_

	def _GenerateNodeAttributes(_cTheme_)
		_cFont_ = This._GetFont()
		_nFontSize_ = This._GetFontSize()
		
		_cResult_ = '    node [fontname="' + _cFont_ + '", fontsize=' + _nFontSize_ + ']' + char(10)
	
		return _cResult_

	def _GenerateEdgeAttributes(_cTheme_)
		_cFont_ = This._GetFont()
		_nFontSize_ = This._GetFontSize()
		_cEdgeColor_ = This._GetEdgeColor(_cTheme_)
		_cEdgeStyle_ = This._GetEdgeStyle()

		_cResult_ = '    edge [fontname="' + _cFont_ + '", fontsize=' + _nFontSize_ + 
		          ', color="' + _cEdgeColor_ + '", style=' + _cEdgeStyle_ +
		          ', penwidth=' + @oDiagram.@nEdgePenWidth + 
		          ', arrowhead=' + @oDiagram.@cArrowHead + 
		          ', arrowtail=' + @oDiagram.@cArrowTail + ']' + char(10)

		return _cResult_
	
	def _GetRankDir()
		_cLayout_ = StzLower(@oDiagram.@cLayout)
		
		# Handle empty/null layout
		if _cLayout_ = ""
			_cLayout_ = $cDefaultLayout
		ok
		
		_cRankDir_ = "TB"

		if _cLayout_ = "topdown" or StzFindFirst(_cLayout_, $acLayouts[:TopDown])
			_cRankDir_ = "TB"
	
		but _cLayout_ = "bottomup" or StzFindFirst(_cLayout_, $acLayouts[:BottomUp])
			_cRankDir_ = "BT"
	
		but _cLayout_ = "leftright" or StzFindFirst(_cLayout_, $acLayouts[:LeftRight])
			_cRankDir_ = "LR"
	
		but _cLayout_ = "rightleft" or StzFindFirst(_cLayout_, $acLayouts[:RightLeft])
			_cRankDir_ = "RL"
		ok
	
		return _cRankDir_
	
	def _GetFont()
		_cFont_ = @oDiagram.@cFont
		if _cFont_ = ""
			_cFont_ = $cDefaultFont
		ok

		return _cFont_
	
	def _GetFontSize()
		_nFontSize_ = @oDiagram.@nFontSize
		if _nFontSize_ = 0 or _nFontSize_ = ""
			_nFontSize_ = $cDefaultFontSize
		ok

		return _nFontSize_
	
	def _GetEdgeColor(_cTheme_)
		# Use resolved color from diagram, default to black
		_cEdgeColor_ = @oDiagram.@cEdgeColor
		
		if _cEdgeColor_ = ""
			_cEdgeColor_ = ResolveColor("black")  # Changed from using @cDefaultEdgeColor
		else
			_cEdgeColor_ = ResolveColor(_cEdgeColor_)
		ok
		
		# Theme-specific edge colors
		if _cTheme_ = "print"
			_cEdgeColor_ = ResolveColor(:black)
		but _cTheme_ = "gray" or _cTheme_ = "lightgray" or _cTheme_ = "darkgray"
			_cEdgeColor_ = ResolveColor(:black)
		but _cTheme_ = "dark"
			_cEdgeColor_ = ResolveColor("gray-")
		ok
		
		return _cEdgeColor_
	
	# THE EDGE STYLE COMES FROM TWO SETTERS, and both have to reach the DOT.
	#
	# SetEdgePenStyle takes the Graphviz vocabulary -- solid, dashed, dotted, bold,
	# invis -- and is the exact counterpart of SetNodePenStyle, which does reach it
	# (there is no SetNodeStyle; the node side has only the pen style). SetEdgeStyle
	# takes SEMANTIC values instead, where :Conditional resolves to dashed, so the
	# two are different layers over one attribute rather than aliases.
	#
	# Only the semantic one was ever read here. SetEdgePenStyle set an attribute
	# that nothing emitted: it drew nothing and raised nothing, and its accessor
	# went on reporting the value back, which is what kept it looking alive.
	#
	# The pen style is the base; a semantic style set on top of it wins.
	#
	# "Set on top of it" has to mean CHANGED FROM ITS DEFAULT. @cEdgeStyle is born
	# holding $cDefaultEdgeStyle, so a test for "not empty" is true on every diagram
	# ever made -- which is precisely what shadowed the pen style, and why wiring it
	# in underneath was not enough on its own.
	def _GetEdgeStyle()
		_cEdgeStyle_ = "solid"

		if @oDiagram.@cEdgePenStyle != "" and @oDiagram.@cEdgePenStyle != ""
			_cEdgeStyle_ = @oDiagram.@cEdgePenStyle
		ok

		_bSemanticSet_ = @oDiagram.@cEdgeStyle != "" and @oDiagram.@cEdgeStyle != "" and
		                 StzLower("" + @oDiagram.@cEdgeStyle) != StzLower("" + $cDefaultEdgeStyle)

		if _bSemanticSet_ or @oDiagram.@cEdgePenStyle = "" or @oDiagram.@cEdgePenStyle = "solid"
			if @oDiagram.@cEdgeStyle != "" and @oDiagram.@cEdgeStyle != ""
				_cEdgeStyle_ = StzResolveEdgeStyle(@oDiagram.@cEdgeStyle)
			ok
		ok

		return _cEdgeStyle_
	
	def _GenerateNodes(_cTheme_)
		_cOutput_ = ""
		
		_aDiagramNodes1_ = @oDiagram.Nodes()
		_nDiagramNodes1Len_ = len(_aDiagramNodes1_)
		for _iLoopDiagramNodes1_ = 1 to _nDiagramNodes1Len_
			_aNode_ = _aDiagramNodes1_[_iLoopDiagramNodes1_]
			_cOutput_ += This._GenerateNode(_aNode_, _cTheme_)
		end
		
		return _cOutput_
	
	def _GenerateNode(_aNode_, _cTheme_)
	    _cNodeId_ = This._SanitizeNodeId(_aNode_["id"])
	    
	    # Handle helper nodes
	    if HasKey(_aNode_, "properties") and HasKey(_aNode_["properties"], "ishelper") and _aNode_["properties"]["ishelper"] = 1
	        _cOutput_ = '    ' + _cNodeId_ + ' [shape=point, width=0.01, height=0.01, style=invis, fixedsize=true, label=""]' + char(10)
	        return _cOutput_
	    ok
	    
	    if StzLeft(_cNodeId_, 8) = "_helper_"
	        _cOutput_ = '    ' + _cNodeId_ + ' [shape=point, width=0.01, height=0.01, style=invis, fixedsize=true, label=""]' + char(10)
	        return _cOutput_
	    ok
	    
	    _cLabel_ = _aNode_["label"]
	    
	    # Get visual rule effects FIRST
	    _aAppliedRules_ = []
	    if HasKey(@oDiagram.@aNodeRulesEffects, _aNode_["id"])
	        _aAppliedRules_ = @oDiagram.@aNodeRulesEffects[_aNode_["id"]]
	    ok
	    
	    # Apply effects to override defaults
	    _cShape_ = This._GetNodeShape(_aNode_, _aAppliedRules_)
	    _cStyle_ = This._GetNodeStyle(_aNode_, _aAppliedRules_)
	    _cFillColor_ = This._GetNodeFillColor(_aNode_, _aAppliedRules_, _cTheme_)
	    
	    # Check if visual rules set penwidth
	    _nPenWidth_ = @oDiagram.@nNodePenWidth
	    if HasKey(_aAppliedRules_, "penwidth")
	        _nPenWidth_ = _aAppliedRules_["penwidth"]
	    ok
	    
	    # Ensure filled is always present (visual rules already merged in _GetNodeStyle)
	    if NOT StzFindFirst("filled", _cStyle_)
	        if _cStyle_ = ""
	            _cStyle_ = "filled"
	        else
	            _cStyle_ += ",filled"
	        ok
	    ok
	    
	    _cOutput_ = '    ' + _cNodeId_ + ' [label="' + _cLabel_ + '"'
	    _cOutput_ += ', shape=' + _cShape_
	    _cOutput_ += ', style="' + _cStyle_ + '"'
	    _cOutput_ += ', fillcolor="' + _cFillColor_ + '"'
	    _cOutput_ += ', penwidth=' + _nPenWidth_
	    
	    # Add contrasting font color
	    _cFontColor_ = @oDiagram.ResolveFontColor(_cFillColor_)
	    _cOutput_ += ', fontcolor="' + _cFontColor_ + '"'
	    
	    # ORG CHART POSITION NODES
	    if HasKey(_aNode_["properties"], "positiontype") and 
	        _aNode_["properties"]["positiontype"] = "position"
	        
	        _cFillColor_ = ResolveColor(_aNode_["properties"]["color"])
	        _cOutput_ += ', fillcolor="' + _cFillColor_ + '"'
	        _cOutput_ += ', fontcolor="' + @oDiagram.ResolveFontColor(_cFillColor_) + '"'
	        
	        # Use diagram's stroke color setting
	        _cStrokeColor_ = @oDiagram.@cNodeStrokeColor
	        if _cStrokeColor_ = '' or _cStrokeColor_ = "invisible"
	            _cStrokeColor_ = _cFillColor_
	        ok
	        _cOutput_ += ', color="' + ResolveColor(_cStrokeColor_) + '"'
	    ok
	    
	    # Generate tooltip
	    _cTooltip_ = This._GenerateTooltip(_aNode_)
	    if _cTooltip_ != ""
	        _cOutput_ += ', tooltip="' + This._EscapeTooltip(_cTooltip_) + '"'
	    else
	        # Explicitly disable default tooltip
	        _cOutput_ += ', tooltip=" "'
	    ok
	    
	    _cOutput_ += ']' + char(10)
	    
	    return _cOutput_

	def _SanitizeNodeId(_cNodeId_)
		if StzLeft(_cNodeId_, 1) = "@"
			return StzMid(_cNodeId_, 2, stzlen(_cNodeId_) - 1)
		ok

		return _cNodeId_
	
	def _GetNodeShape(_aNode_, _aEnhancements_)
		# Check enhancements FIRST (from visual rules)
		if HasKey(_aEnhancements_, "shape")
			return _aEnhancements_["shape"]
		ok
		
		# Check node properties for explicit shape
		if HasKey(_aNode_, "properties") and _aNode_["properties"] != "" and 
		   HasKey(_aNode_["properties"], "shape") and _aNode_["properties"]["shape"] != ""
			return _aNode_["properties"]["shape"]
		ok
		
		# Get type for semantic mapping
		_cType_ = ""
		if HasKey(_aNode_, "properties") and _aNode_["properties"] != "" and 
		   HasKey(_aNode_["properties"], "type") and _aNode_["properties"]["type"] != ""
			_cType_ = StzLower("" + _aNode_["properties"]["type"])
		ok
		
		# Direct DOT shape (bypasses semantic mapping)
		if StzFindFirst(_cType_, $acDotShapes) > 0
			return _cType_
		ok
		
		# Semantic to shape mapping
		switch _cType_
		on "process"
			return "box"

		on "decision"
			return "diamond"

		on "start"
			return "ellipse"

		on "endpoint"
			return "doublecircle"

		on "state"
			return "circle"

		on "storage"
			return "cylinder"

		on "data"
			return "box"

		on "event"
			return "ellipse"

		other
			return "box"
		off
	
	def _GetNodeStyle(_aNode_, _aEnhancements_)
		# Get the actual shape that will be rendered
		_cShape_ = This._GetNodeShape(_aNode_, _aEnhancements_)
		
		# Start with global node pen style
		_cBaseStyle_ = @oDiagram.@cNodePenStyle
		
		# If visual rule sets style, merge with base
		if HasKey(_aEnhancements_, "style")
			_cRuleStyle_ = _aEnhancements_["style"]
			# Merge: ensure filled + rounded (for boxes) + rule style
			if NOT StzFindFirst("filled", _cRuleStyle_)
				_cRuleStyle_ += ",filled"
			ok
			if _cShape_ = "box" and NOT StzFindFirst("rounded", _cRuleStyle_)
				_cRuleStyle_ = "rounded," + _cRuleStyle_
			ok
			return _cRuleStyle_
		ok
		
		# Polygon shapes don't support rounded
		
		if StzFindFirst(_cShape_, $aPolygonShapes) > 0
			# Add filled if not already there
			if NOT StzFindFirst("filled", _cBaseStyle_)
				return _cBaseStyle_ + ",filled"
			ok
			return _cBaseStyle_
		ok

		# For box-like shapes, add rounded and filled
		if NOT StzFindFirst("filled", _cBaseStyle_)
			_cBaseStyle_ += ",filled"
		ok
		if NOT StzFindFirst("rounded", _cBaseStyle_) and _cShape_ = "box"
			_cBaseStyle_ = "rounded," + _cBaseStyle_
		ok
		
		return _cBaseStyle_
	
	def _GetNodeFillColor(_aNode_, _aEnhancements_, _cTheme_)
	    _cColor_ = ""
	    
	    if HasKey(_aEnhancements_, "color")
	        _cColor_ = _aEnhancements_["color"]
	    ok
	    
	    if _cColor_ = "" and HasKey(_aNode_, "properties") and 
	       HasKey(_aNode_["properties"], "color")
	        _cColor_ = _aNode_["properties"]["color"]
	    ok
	    
	    # Use theme's primary color when no color specified
	    if _cColor_ = ''
	        if HasKey($aPalette, _cTheme_)
	            _cColor_ = $aPalette[_cTheme_]["primary"]
	        else
	            _cColor_ = $cDefaultNodeColor
	        ok
	    ok
	    
	    # If already hex, return after theme transforms
	    if StzFindFirst("#", _cColor_)
	        if _cTheme_ = "gray"
	            return @oDiagram.ConvertColorTogray(_cColor_)
	        but _cTheme_ = "print"
	            return ResolveColor(:white)
	        ok
	        return _cColor_
	    ok
	    
	    # Resolve through theme palette for semantic colors
	    _cLowerColor_ = StzLower(_cColor_)
	    if HasKey($aPalette, _cTheme_) and HasKey($aPalette[_cTheme_], _cLowerColor_)
	        _cColor_ = $aPalette[_cTheme_][_cLowerColor_]
	    ok
	    
	    # Resolve to hex
	    _cColor_ = ResolveColor(_cColor_)
	    
	    # Final theme transforms
	    if _cTheme_ = "gray"
	        _cColor_ = @oDiagram.ConvertColorTogray(_cColor_)
	    but _cTheme_ = "print"
	        _cColor_ = ResolveColor(:white)
	    ok
	    
	    return _cColor_
	
	def _GetNodeStrokeColor(_cTheme_)
		if @oDiagram.@cNodeStrokeColor != "" and @oDiagram.@cNodeStrokeColor != ""
			return @oDiagram.@cNodeStrokeColor
		ok
		
		if _cTheme_ = "print" or _cTheme_ = "gray"
			return "black"
		ok
		
		return ""
	
	def _GenerateEdges(_cTheme_)
		_cOutput_ = ""
		
		# Add invisible edges to force vertical layout when no real edges exist
		if len(@oDiagram.Edges()) = 0
			_acNodes_ = @oDiagram.Nodes()
			_nLen_ = len(_acNodes_)
			for i = 1 to _nLen_ - 1
				_cFrom_ = This._SanitizeNodeId(_acNodes_[i]["id"])
				_cTo_ = This._SanitizeNodeId(_acNodes_[i+1]["id"])
				_cOutput_ += '    ' + _cFrom_ + ' -> ' + _cTo_ + ' [style=invis]' + char(10)
			end
		ok
		
		_aDiagramEdges1_ = @oDiagram.Edges()
		_nDiagramEdges1Len_ = len(_aDiagramEdges1_)
		for _iLoopDiagramEdges1_ = 1 to _nDiagramEdges1Len_
			_aEdge_ = _aDiagramEdges1_[_iLoopDiagramEdges1_]
			_cOutput_ += This._GenerateEdge(_aEdge_, _cTheme_)
		end
		
		return _cOutput_

	def _GenerateEdge(_aEdge_, _cTheme_)
	    _cFrom_ = This._SanitizeNodeId(_aEdge_["from"])
	    _cTo_ = This._SanitizeNodeId(_aEdge_["to"])
	    _cEdgeKey_ = _aEdge_["from"] + "->" + _aEdge_["to"]
	    
	    _cOutput_ = '    ' + _cFrom_ + ' -> ' + _cTo_
	    _aAttrs_ = []
	    
	    # Check if this is a supervisor -> helper edge
	    if StzLeft(_cTo_, 8) = "_helper_"
	        _aAttrs_ + 'arrowhead=none'
	        _aAttrs_ + 'weight=10'
	    ok
	    
	    # Handle edge label with spacing fix for TB layout
	    if HasKey(_aEdge_, "label") and _aEdge_["label"] != "" and _aEdge_["label"] != ""
	        _cLabel_ = _aEdge_["label"]
	        _cRankDir_ = This._GetRankDir()
	        
	        # Add leading space for TB/BT layouts to prevent label collapse
	        if _cRankDir_ = "TB" or _cRankDir_ = "BT"
	            _cLabel_ = " " + _cLabel_
	        ok
	        
	        _aAttrs_ + ('label="' + _cLabel_ + '"')
	    ok
	    
	    # Check edge properties
	    if HasKey(_aEdge_, "properties")
	        if HasKey(_aEdge_["properties"], "arrowhead")
	            _aAttrs_ + ('arrowhead=' + _aEdge_["properties"]["arrowhead"])
	        ok
	        if HasKey(_aEdge_["properties"], "weight")
	            _aAttrs_ + ('weight=' + _aEdge_["properties"]["weight"])
	        ok
	    ok
	    
	    # Check rule effects from parent
	    if HasKey(@oDiagram.@aEdgesAffectedByRules, _cEdgeKey_)
	        _aAppliedRules_ = @oDiagram.@aEdgesAffectedByRules[_cEdgeKey_]
	        
	        if HasKey(_aAppliedRules_, "style")
	            _aAttrs_ + ('style="' + _aAppliedRules_["style"] + '"')
	        ok
	        
	        if HasKey(_aAppliedRules_, "color")
	            _cColor_ = ResolveColor(_aAppliedRules_["color"])
	            _aAttrs_ + ('color="' + _cColor_ + '"')
	        ok
	        
	        if HasKey(_aAppliedRules_, "penwidth")
	            _aAttrs_ + ('penwidth=' + _aAppliedRules_["penwidth"])
	        ok
	    ok
	    
	    if len(_aAttrs_) > 0
	        _cOutput_ += ' [' + This._JoinAttributes(_aAttrs_) + ']'
	    ok
	    
	    _cOutput_ += char(10)
	    return _cOutput_
	
	def _GenerateTooltip(_aNode_)
	    _aConfig_ = @oDiagram.@aTooltipConfig
	    
	    if len(_aConfig_) = 0
	        return ""  # Explicitly no tooltip
	    ok
	    
	    _cTooltip_ = ""
	    
	    _nConfig1Len_ = len(_aConfig_)
	    for _iLoopConfig1_ = 1 to _nConfig1Len_
	    	_item_ = _aConfig_[_iLoopConfig1_]
	        _cKey_ = StzLower("" + _item_)
	        
	        if _cKey_ = "nodeid"
	            _cTooltip_ += "ID: " + _aNode_["id"] + "\n"
	            
	        but _cKey_ = "label"
	            _cTooltip_ += "Label: " + _aNode_["label"] + "\n"
	            
	        but _cKey_ = "type"
	            if HasKey(_aNode_["properties"], "type")
	                _cTooltip_ += "Type: " + _aNode_["properties"]["type"] + "\n"
	            ok
	            
	        but _cKey_ = "color"
	            if HasKey(_aNode_["properties"], "color")
	                _cTooltip_ += "Color: " + _aNode_["properties"]["color"] + "\n"
	            ok
	            
	        else
	            # Custom property
	            if HasKey(_aNode_["properties"], _cKey_)
	                _cValue_ = _aNode_["properties"][_cKey_]
	                _cTooltip_ += _cKey_ + ": " + _cValue_ + "\n"
	            ok
	        ok
	    end
	    
	    return _cTooltip_
	
	def _EscapeTooltip(_cText_)
	    _cText_ = StzReplace(_cText_, '"', '\"')
	    _cText_ = StzReplace(_cText_, "\n", "&#10;")  # HTML entity for newline
	    return _cText_

	def _JoinAttributes(_aAttrs_)
		_cResult_ = ""
		_nLen_ = len(_aAttrs_)

		for i = 1 to _nLen_
			_cResult_ += _aAttrs_[i]
			if i < _nLen_
				_cResult_ += ', '
			ok
		end

		return _cResult_

	def DotCode()
		return @cDotCode

		def Code()
			return @cDotCode

		def Content()
			return @cDotCode


	def WriteToFile(pFilename)
		_oFile_ = fopen(pFilename, "w")
		fwrite(_oFile_, This.DotCode())
		fclose(_oFile_)
		return 1

#====================================#
#  stzDiagramToMermaid - MERMAID.JS  #
#====================================#

class stzDiagramToMermaid from stzObject

	@oDiagram
	@cMermaidCode

	def init(poDiagram)

		if NOT ( isObject(poDiagram) and ( ring_classname(poDiagram) = "stzdiagram" or
				ring_classname(poDiagram) = "stzorgchart"
				)
			)

			StzRaise("Incorrect param type! poDiagram must be a stzDiagram object.")
		ok
		@oDiagram = poDiagram
		This._Generate()

	def _Generate()
		_cOutput_ = "graph TD" + char(10)
		
		# Mermaid reserved keywords
		_aReservedWords_ = ["end", "start", "subgraph", "graph", "style", "class", 
		                  "click", "call", "direction", "flowchart", "stateDiagram",
		                  "state", "note", "default", "loop", "alt", "par", "and"]
	
		_aNodes_ = @oDiagram.Nodes()
		_nLen_ = len(_aNodes_)
		for i = 1 to _nLen_
			_aNode_ = _aNodes_[i]
			_cNodeId_ = _aNode_["id"]
			_cLabel_ = _aNode_["label"]
	
			# Escape reserved keywords
			_cSafeNodeId_ = _cNodeId_
			if StzFindFirst(StzLower(_cNodeId_), _aReservedWords_) > 0
				_cSafeNodeId_ = "node_" + _cNodeId_
			ok
	
			_cType_ = _aNode_["properties"]["type"]
			if _cType_ = "start"
				_cOutput_ += '    ' + _cSafeNodeId_ + '(["' + _cLabel_ + '"])' + char(10)
	
			but _cType_ = "endpoint"
				_cOutput_ += '    ' + _cSafeNodeId_ + '(["' + _cLabel_ + '"])' + char(10)
	
			but _cType_ = "decision"
				_cOutput_ += '    ' + _cSafeNodeId_ + '{{"' + _cLabel_ + '"}}' + char(10)
	
			but _cType_ = "process"
				_cOutput_ += '    ' + _cSafeNodeId_ + '["' + _cLabel_ + '"]' + char(10)
	
			else
				_cOutput_ += '    ' + _cSafeNodeId_ + '["' + _cLabel_ + '"]' + char(10)
			ok
		end
	
		_cOutput_ += char(10)
	
		_aEdges_ =  @oDiagram.Edges()
		_nLen_ = len(_aEdges_)

		for i = 1 to _nLen_
			_aEdge_ = _aEdges_[i]
			_cFromId_ = _aEdge_["from"]
			_cToId_ = _aEdge_["to"]
			
			# Escape reserved keywords in edges
			if StzFindFirst(StzLower(_cFromId_), _aReservedWords_) > 0
				_cFromId_ = "node_" + _cFromId_
			ok
			if StzFindFirst(StzLower(_cToId_), _aReservedWords_) > 0
				_cToId_ = "node_" + _cToId_
			ok
			
			if _aEdge_["label"] != "" and _aEdge_["label"] != ""
				_cOutput_ += '    ' + _cFromId_ + ' -->|' + _aEdge_["label"] + '| ' + _cToId_ + char(10)
			else
				_cOutput_ += '    ' + _cFromId_ + ' --> ' + _cToId_ + char(10)
			ok
		end
	
		@cMermaidCode = _cOutput_
	
	def Code()
		return @cMermaidCode

		def MermaidCode()
			return @cMermaidCode

		def Content()
			return @cMermaidCode

	def WriteToFile(pFilename)
		_oFile_ = fopen(pFilename, "w")
		fwrite(_oFile_, This.Code())
		fclose(_oFile_)
		return 1

#==================================#
#  stzDiagramToJSON - JSON FORMAT  #
#==================================#

class stzDiagramToJSON from stzObject

	@oDiagram
	@cJsonCode

	def init(poDiagram)
		if NOT ( isObject(poDiagram) and ring_classname(poDiagram) = "stzdiagram" )
			StzRaise("Incorrect param type! poDiagram must be a stzDiagram object.")
		ok
		@oDiagram = poDiagram
		This._Generate()

	def _Generate()
		_aData_ = @oDiagram.ToHashlist()
		@cJsonCode = ToJSONXT(_aData_)

	def Json()
		return @cJsonCode

		def JsonCode()
			return @cJsonCode

		def Code()
			return @cJsonCode

		def Content()
			return @cJsonCode

	def WriteToFile(pFilename)
		_oFile_ = fopen(pFilename, "w")
		fwrite(_oFile_, This.JsonCode())
		fclose(_oFile_)
		return 1

#========================#
#  COLOR RESOLVER CLASS  #
#========================#

class stzColorResolver from stzObject

	def init()

	def ResolveFontColor(pBgColor)
		# Get actual resolved background color
		_cBgColor_ = ResolveColor(pBgColor)
		
		# Always use luminance calculation for consistent contrast
		return This.ContrastingTextColor(_cBgColor_)
	
	# DELEGATES to the universal StzContrastingText. This carried its own
	# copy of the BT.709 rule, so a plot or a canvas wanting the same
	# answer had to instantiate a diagram to borrow it. One rule, one
	# place -- the two colour TABLES already showed what happens when
	# that slips.
	def ContrastingTextColor(_cColor_)
		return StzContrastingText(_cColor_)
	
	def ColorToRGB(_cColor_)
		# First resolve to hex, then convert
		_cHex_ = ResolveColor(_cColor_)
		return HexToRGB(_cHex_)

	def NodeStrokeColorForTheme(_cTheme_)
		if _cTheme_ = "print" or _cTheme_ = "gray"
			return "black"
		ok
		return ""

	def ConvertColorToGray(_cColor_)
		_aRGB_ = This.ColorToRGB(_cColor_)
		_nR_ = _aRGB_[1]
		_nG_ = _aRGB_[2]
		_nB_ = _aRGB_[3]
		
		# Use perceptual brightness formula
		_nGray_ = floor(0.299 * _nR_ + 0.587 * _nG_ + 0.114 * _nB_)
		
		# Use global helper
		return RGBToHex(_nGray_, _nGray_, _nGray_)

	def ResolveWithPalette(pcColor, pacPalette)

		if isString(pcColor) and StzFindFirst("#", pcColor)
			return pcColor
		ok

		_cColorKey_ = StzLower("" + pcColor)

		# Extract intensity modifier (++, +, --, -)
		_cIntensity_ = ""
		_cBaseKey_ = _cColorKey_

		if StzRight(_cColorKey_, 2) = "++" or StzRight(_cColorKey_, 2) = "--"
			_cIntensity_ = StzRight(_cColorKey_, 2)
			_cBaseKey_ = StzLeft(_cColorKey_, stzlen(_cColorKey_) - 2)

		but StzRight(_cColorKey_, 1) = "+" or StzRight(_cColorKey_, 1) = "-"
			_cIntensity_ = StzRight(_cColorKey_, 1)
			_cBaseKey_ = StzLeft(_cColorKey_, stzlen(_cColorKey_) - 1)
		ok
		
		# Try direct palette lookup
		if HasKey(pacPalette, _cColorKey_)
			return pacPalette[_cColorKey_]
		ok
		
		# Try semantic meaning
		if HasKey($acColorsBySemanticMeaning, _cBaseKey_)
			_cBaseColor_ = "" + $acColorsBySemanticMeaning[_cBaseKey_]
			return ResolveColor(_cBaseColor_ + _cIntensity_)
		ok
		
		# Try node type
		if HasKey($acColorsByNodeType, _cBaseKey_)
			_cBaseColor_ = "" + $acColorsByNodeType[_cBaseKey_]
			return ResolveColor(_cBaseColor_ + _cIntensity_)
		ok
		
		# Legacy map #TODO Shoud it be global?
		_aLegacyMap_ = [
			:lightblue = "blue+",
			:lightgreen = "green+",
			:lightyellow = "yellow+",
			:lightcoral = "coral",
			:lightgray = "gray+",
			:lightcyan = "cyan+",
			:lightpink = "pink+",
			:darkgreen = "green-",
			:darkblue = "blue-",
			:darkred = "red-"
		]
		
		if HasKey(_aLegacyMap_, _cColorKey_)
			return ResolveColor(_aLegacyMap_[_cColorKey_])
		ok

		# UNKNOWN. This used to `return pacPalette[:blue]`, so every typo in
		# a colour name silently became BLUE -- and so did the empty string.
		# A picture drawn from a misspelt palette looked deliberate.
		#
		# It answers "" now, which is the only honest thing a lookup can say
		# about a name it does not have. The DECISION of what to do about
		# that belongs to the caller and is made in exactly one place:
		# StzResolveColor applies the documented fallback,
		# StzTryResolveColor hands the "" straight back so a face can refuse.
		return ""

#============================================#
#  stzStylParser - *.stzstyl Format Parser   #
#  Visual theme and styling definitions      #
#============================================#

class stzStylParser from stzObject
	
	def init()

	def ParseFile(pcFilename)
		_cContent_ = read(pcFilename)
		return This.Parse(_cContent_)
	
	def Parse(pcContent)
		_aStyle_ = [
			:name = "",
			:theme = $cDefaultColorTheme,
			:layout = $cDefaultLayout,
			:colors = [],
			:fonts = [],
			:edges = [],
			:nodes = [],
			:focus = [],
			:custom = []
		]
		
		_acLines_ = split(pcContent, char(10))
		_cSection_ = ""
		
		_nAcLines1Len_ = len(_acLines_)
		for _iLoopAcLines1_ = 1 to _nAcLines1Len_
			_cLine_ = _acLines_[_iLoopAcLines1_]
			_cLine_ = trim(_cLine_)
			
			if _cLine_ = "" or StzLeft(_cLine_, 1) = "#"
				loop
			ok

			# Style header
			if StzFindFirst("style ", _cLine_)
				_aStyle_[:name] = This._ExtractQuoted(_cLine_)

			but StzFindFirst("theme:", _cLine_)
				_aStyle_[:theme] = This._ExtractValue(_cLine_)

			but StzFindFirst("layout:", _cLine_)
				_aStyle_[:layout] = This._ExtractValue(_cLine_)

			# Sections
			but _cLine_ = "colors"
				_cSection_ = "colors"

			but _cLine_ = "fonts"
				_cSection_ = "fonts"

			but _cLine_ = "edges"
				_cSection_ = "edges"

			but _cLine_ = "nodes"
				_cSection_ = "nodes"

			but _cLine_ = "focus"
				_cSection_ = "focus"

			but _cLine_ = "custom"
				_cSection_ = "custom"

			# Parse section content
			but _cSection_ != "" and StzFindFirst(":", _cLine_)
				_aParts_ = split(_cLine_, ":")
				_cKey_ = trim(_aParts_[1])
				_cValue_ = trim(_aParts_[2])
				
				_aStyle_[_cSection_] + [_cKey_, This._ParseValue(_cValue_)]
			ok
		end
		

		return _aStyle_
	
	def _ParseValue(_cValue_)
		# Try number
		if isdigit(_cValue_)
			return 0 + _cValue_
		ok
		
		# Remove quotes
		if StzLeft(_cValue_, 1) = '"' and StzRight(_cValue_, 1) = '"'
			return StzMid(_cValue_, 2, StzLen(_cValue_) - 2)
		ok

		return _cValue_

	def _ExtractValue(_cLine_)
		_nPos_ = StzFindFirst(":", _cLine_)
		if _nPos_ = 0 return "" ok
		_cValue_ = trim(StzMid(_cLine_, _nPos_ + 1, StzLen(_cLine_) - _nPos_))
		return This._ParseValue(_cValue_)

	def _ExtractQuoted(_cLine_)
		_nStart_ = StzFindFirst('"', _cLine_)
		if _nStart_ = 0 return "" ok
		_nEnd_ = StzMid(_cLine_, _nStart_ + 1, StzLen(_cLine_) - _nStart_)
		_nEnd_ = StzFindFirst('"', _nEnd_)
		return StzMid(_cLine_, _nStart_ + 1, _nEnd_ - 1)
