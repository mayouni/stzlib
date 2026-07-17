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
$acLayouts = [
	:TopDown = [ "tb", "td", "topbottom", "ud", "updown", "ub", "upbottom" ],
	:BottomUp = [ "bt", "dt", "bottomtop", "du", "downup", "bu", "bottomup" ],
	:LeftRight = [ "lr" ],
	:RightLeft = [ "rl" ]
]

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
			return TRUE
		ok
	ok
	return FALSE

# STYLE RESOLUTION

func StzResolveEdgeStyle(pStyle)
	_cStyleKey_ = StzLower("" + pStyle)

	if HasKey($acEdgeStyles, _cStyleKey_)
		return $acEdgeStyles[_cStyleKey_]
	ok

	if StzFindFirst(["solid", "dashed", "dotted", "bold"], _cStyleKey_)
		return _cStyleKey_
	ok

	return $cDefaultEdgeStyle

	func ResolveEdgeStyle(pStyle)
		return StzResolveEdgeStyle(pStyle)

func StzResolveNodeType(pcType)
	_cTypeKey_ = StzLower("" + pcType)

	if StzFindFirst($acDotShapes, _cTypeKey_) > 0
		return _cTypeKey_
	ok

	if StzFindFirst($acNodeTypes, _cTypeKey_)
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
	return StzFindFirst($acNodeTypes, pcType) > 0

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

class stzDiagram from stzGraph

	@cTheme = $cDefaultColorTheme
	@cLayout = $cDefaultLayout
	@aClusters = []
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
	@bFontCustomized = FALSE

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
	@bConcentrate = FALSE

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
	
	def SetLayout(pLayout)
		
		@cLayout = StzLower(pLayout)

	def SetEdgeStyle(pStyle)
		@cEdgeStyle = StzLower(pStyle)

	def SetEdgeColor(pColor)
		@cEdgeColor = ResolveColor(pColor)

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
		@bFontCustomized = TRUE

	def SetFontSize(pSize)
	    @nFontSize = pSize
	    @bFontCustomized = TRUE
	

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

	    _cType_ = StzLower(pcType)
	    if StzFindFirst($acSplineTypes, _cType_) > 0
	        @cSplineType = _cType_
	    else
		@cSplineType = $cDefaultSplineType
	    ok

	    def SetEdgeLineStyle(pcType)
		This.SetSplines(pcType)

	    def SetEdgeLineType(pcType)
		This.SetSplines(pcType)

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
	        This.SetConcentrate(FALSE)
	        
	    on "orgchart_compact"
	        This.SetSplines("spline")
	        This.SetNodeSeparation(0.6)
	        This.SetRankSeparation(0.8)
	        This.SetConcentrate(FALSE)
	        
	    on "compact"
	        This.SetSplines("spline")
	        This.SetNodeSeparation(0.3)
	        This.SetRankSeparation(0.5)
	        This.SetConcentrate(TRUE)
	        
	    on "spacious"
	        This.SetSplines("ortho")
	        This.SetNodeSeparation(1.2)
	        This.SetRankSeparation(1.5)
	        This.SetConcentrate(FALSE)
	        
	    on "flowchart"
	        This.SetSplines("polyline")
	        This.SetNodeSeparation(0.8)
	        This.SetRankSeparation(1.0)
	        This.SetConcentrate(FALSE)
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
		
		return FALSE
	
	def _MatchRange(_aContext_, _aParams_)
		if NOT HasKey(_aContext_, :properties)
			return FALSE
		ok
		
		_cKey_ = _aParams_[1]
		_nMin_ = _aParams_[2]
		_nMax_ = _aParams_[3]
		
		if NOT HasKey(_aContext_[:properties], _cKey_)
			return FALSE
		ok
		
		pValue = _aContext_[:properties][_cKey_]
		if NOT isNumber(pValue)
			return FALSE
		ok
		
		return (pValue >= _nMin_ and pValue <= _nMax_)
	
	def _MatchEquals(_aContext_, _aParams_)
		if NOT HasKey(_aContext_, :properties)
			return FALSE
		ok
		
		_cKey_ = _aParams_[1]
		pExpected = _aParams_[2]
		
		if NOT HasKey(_aContext_[:properties], _cKey_)
			return FALSE
		ok
		
		return (_aContext_[:properties][_cKey_] = pExpected)
	
	def _MatchExists(_aContext_, _aParams_)
		if NOT HasKey(_aContext_, :properties)
			return FALSE
		ok
		
		_cKey_ = _aParams_[1]
		return HasKey(_aContext_[:properties], _cKey_)
	
	def _MatchTag(_aContext_, _aParams_)
		if NOT HasKey(_aContext_, :tags)
			return FALSE
		ok
		
		_cTag_ = _aParams_[1]
		return StzFindFirst(_aContext_[:tags], _cTag_) > 0
	
	def _BuildRuleContext(aElement)
		_aContext_ = aElement
		
		if HasKey(aElement, :properties) and aElement[:properties] != NULL
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
			   StzFindFirst(_aNode_[:properties][:tags], pcTag) > 0
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

	def View()

		# Generate DOT code
		_cDotCode_ = This.Dot()

		# Create stzDotCode instance and execute
		_oDotExec_ = new stzDotCode()
		_oDotExec_.SetCode(_cDotCode_)
		_oDotExec_.SetOutputFormat(@cOutputFormat)
		_oDotExec_.ExecuteAndView()
		
		def Display()
			This.View()

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
		_acLines_ = @split(cDiagString, NL)
		_nLen_ = len(_acLines_)
		_bInNodesSection_ = FALSE

		for i = 1 to _nLen_
			_cLine_ = trim(_acLines_[i])
			if _cLine_ = "nodes"
				_bInNodesSection_ = TRUE
				loop
			ok
			
			if _bInNodesSection_ and _cLine_ != "" and
			   NOT StzFindFirst(_cLine_, "label:") and
			   NOT StzFindFirst(_cLine_, "type:") and
			   NOT StzFindFirst(_cLine_, "color:")
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
		_acLines_ = @split(cDiagString, NL)
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
			
			if StzFindFirst(_cLine_, "diagram ")
				_cTitle_ = trim(StzMid(_cLine_, 10, stzlen(_cLine_) - 10))
				@cId = _cTitle_

			but _cLine_ = "properties"
				_cCurrentSection_ = "properties"

			but _cLine_ = "nodes"
				_cCurrentSection_ = "nodes"

			but _cLine_ = "edges"
				_cCurrentSection_ = "edges"

			but _cCurrentSection_ = "properties" and StzFindFirst(_cLine_, ":")
				_aParts_ = @split(_cLine_, ":")
				_cKey_ = trim(_aParts_[1])
				_cValue_ = trim(_aParts_[2])

				if _cKey_ = "theme"
					This.SetTheme(_cValue_)
				but _cKey_ = "layout"
					This.SetLayout(_cValue_)
				ok

			but _cCurrentSection_ = "nodes"
				if NOT StzFindFirst(_cLine_, "label:") and NOT StzFindFirst(_cLine_, "type:") and NOT StzFindFirst(_cLine_, "color:")
					if _cCurrentNode_ != "" and _cLabel_ != ""
						if _cType_ = "" _cType_ = $cDefaultNodeType ok
						if _cColor_ = "" _cColor_ = $cDefaultNodeColor ok
						This.AddNodeXTT(_cCurrentNode_, _cLabel_, [ :type = _cType_, :color = _cColor_ ])
					ok
					_cCurrentNode_ = _cLine_
					_cLabel_ = ""
					_cType_ = ""
					_cColor_ = ""

				but StzFindFirst(_cLine_, "label:")
					_cLabel_ = StzMid(_cLine_, 9, stzlen(_cLine_) - 9)

				but StzFindFirst(_cLine_, "type:")
					_cType_ = trim(StzMid(_cLine_, 7, stzlen(_cLine_) - 6))

				but StzFindFirst(_cLine_, "color:")
					_cColor_ = trim(StzMid(_cLine_, 8, stzlen(_cLine_) - 7))
				ok

			but _cCurrentSection_ = "edges" and StzFindFirst(_cLine_, "->")
				_aEdgeParts_ = @split(_cLine_, "->")
				_cFrom_ = trim(_aEdgeParts_[1])
				_cTo_ = trim(_aEdgeParts_[2])
				_aEdgesToAdd_ + [_cFrom_, _cTo_]  # Store for later
			ok
		end

		# Add last node
		if _cCurrentNode_ != "" and _cLabel_ != ""
			if _cType_ = "" _cType_ = $cDefaultNodeType ok
			if _cColor_ = "" _cColor_ = $cDefaultNodeColor ok
			This.AddNodeXTT(_cCurrentNode_, _cLabel_, [ :type = _cType_, :color = _cColor_ ])
		ok

		# Now add all edges
		_nLen_ = len(_aEdgesToAdd_)
		for i = 1 to _nLen_
			This.Connect(_aEdgesToAdd_[i][1], _aEdgesToAdd_[i][2])
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
		
		# Apply colors
		if HasKey(_aStyle_, :colors) and len(_aStyle_[:colors]) > 0
			_nLen_ = len(_aStyle_[:colors])
			for i = 1 to _nLen_ step 2
				_cKey_ = _aStyle_[:colors][i]
				_cValue_ = _aStyle_[:colors][i + 1]
				
				# Update color palette
				if HasKey(@aPalette[@cTheme], _cKey_)
					@aPalette[@cTheme][_cKey_] = _cValue_
				ok
			end
		ok
		
		# Apply fonts
		if HasKey(_aStyle_, :fonts) and len(_aStyle_[:fonts]) > 0
			_nLen_ = len(_aStyle_[:fonts])
			for i = 1 to _nLen_ step 2
				_cKey_ = _aStyle_[:fonts][i]
				pValue = _aStyle_[:fonts][i + 1]
				
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
			for i = 1 to _nLen_ step 2
				_cKey_ = _aStyle_[:edges][i]
				pValue = _aStyle_[:edges][i + 1]
				
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
			for i = 1 to _nLen_ step 2
				_cKey_ = _aStyle_[:nodes][i]
				pValue = _aStyle_[:nodes][i + 1]
				
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
			for i = 1 to _nLen_ step 2
				_cKey_ = _aStyle_[:focus][i]
				pValue = _aStyle_[:focus][i + 1]
				
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
		_cStyl_ = 'style "' + @cId + '_style"' + NL
		_cStyl_ += '    theme: ' + @cTheme + NL
		_cStyl_ += '    layout: ' + @cLayout + NL + NL
		
		_cStyl_ += 'colors' + NL
		if HasKey(@aPalette, @cTheme)
			_acKeys_ = keys(@aPalette[@cTheme])
			_nAcKeys1Len_ = len(_acKeys_)
			for _iLoopAcKeys1_ = 1 to _nAcKeys1Len_
				_cKey_ = _acKeys_[_iLoopAcKeys1_]
				_cStyl_ += '    ' + _cKey_ + ': ' + @aPalette[@cTheme][_cKey_] + NL
			end
		ok
		_cStyl_ += NL
		
		_cStyl_ += 'fonts' + NL
		_cStyl_ += '    default: ' + @cFont + NL
		_cStyl_ += '    size: ' + @nFontSize + NL + NL
		
		_cStyl_ += 'edges' + NL
		_cStyl_ += '    style: ' + @cEdgeStyle + NL
		_cStyl_ += '    color: ' + @cEdgeColor + NL
		_cStyl_ += '    spline: ' + @cSplineType + NL
		_cStyl_ += '    penwidth: ' + @nEdgePenWidth + NL + NL
		
		_cStyl_ += 'nodes' + NL
		_cStyl_ += '    penwidth: ' + @nNodePenWidth + NL
		_cStyl_ += '    penstyle: ' + @cNodePenStyle + NL
		_cStyl_ += '    color: ' + @cNodeColor + NL
		if @cNodeStrokeColor != ""
			_cStyl_ += '    strokecolor: ' + @cNodeStrokeColor + NL
		ok
		_cStyl_ += NL
		
		_cStyl_ += 'focus' + NL
		_cStyl_ += '    color: ' + @cFocusColor + NL
		
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
			   @oDiagram.Id() + '"' + NL + NL

		_cOutput_ += "properties" + NL
		_cOutput_ += "    theme: " + Lower(@oDiagram.@cTheme) + NL
		_cOutput_ += "    layout: " + Lower(@oDiagram.@cLayout) + NL + NL

		# Generating the diagram title

		if @oDiagram.Title() != ""
		    _cTitle_ = @oDiagram.Title()
		    _cSubtitle_ = @oDiagram.Subtitle()
		    if trim(_cSubtitle_) != ""
			_cTitle_ += " : " + _cSubtitle_
		    ok

		    _cOutput_ += '    labelloc="t";' + NL

		    _cOutput_ += '    label="' + _cTitle_
		    _cOutput_ += '";'
		    _cOutput_ += '    fontsize=16;'
		ok

		# Generating nodes

		_cOutput_ += "nodes" + NL
		_aNodes_ = @oDiagram.Nodes()
		_nLen_ = len(_aNodes_)

		for i = 1 to _nLen_
			_aNode_ = _aNodes_[i]
			_cOutput_ += "    " + _aNode_["id"] + NL
			_cOutput_ += "        label: " + This.EscapeString(_aNode_["label"]) + NL

			if _aNode_["properties"]["type"] != ""
				_cOutput_ += "        type: " + Lower(_aNode_["properties"]["type"]) + NL
			ok

			if _aNode_["properties"]["color"] != ""
				_cOutput_ += "        color: " + _aNode_["properties"]["color"] + NL
			ok

			_cOutput_ += NL
		end

		# Generating edges

		_aEdges_ = @oDiagram.Edges()
		_nLen_ = len(_aEdges_)

		if _nLen_ > 0
			_cOutput_ += "edges" + NL
			for i = 1 to _nLen_
				_aEdge_ = _aEdges_[i]
				_cOutput_ += "    " + _aEdge_["from"] + " -> " + _aEdge_["to"] + NL

				_cLabel_ = _aEdge_["label"]
				if _cLabel_ != ""
					_cOutput_ += "        label: " + This.EscapeString(_cLabel_) + NL
				ok

				_cOutput_ += NL
			end

		ok

		# Generating clusters

		_aClusters_ = @oDiagram.Clusters()
		_nLen_ = len(_aClusters_)
		if _nLen_ > 0
			_cOutput_ += "clusters" + NL

			for i = 1 to _nLen_
				_aCluster_ = _aClusters_[i]
				_cOutput_ += "    " + _aCluster_["id"] + NL
				_cOutput_ += "        label: " + This.EscapeString(_aCluster_["label"]) + NL
				_cNodeList_ = This.NodeListToString(_aCluster_["nodes"])
				_cOutput_ += "        nodes: [" + _cNodeList_ + "]" + NL
				_cOutput_ += "        color: " + _aCluster_["color"] + NL
				_cOutput_ += NL
			end
		ok

		# Generating annotations

		_aAnnotations_ = @oDiagram.AnnotationsQ()
		_nLen_ = len(_aAnnotations_)

		if _nLen_ > 0
			_cOutput_ += "annotations" + NL
			for i = 1 to _nLen_
				_aAnnot_ = _aAnnotations_[i]
				_cOutput_ += "    " + Lower(_aAnnot_.Type()) + NL

				_aAnnotData_ = _aAnnot_.NodesData()

				_acKeys_ = Keys(_aAnnotData_)
				_nLenK_ = len(_acKeys_)

				for j = 1 to _nLenK_
					_cNodeId_ = _acKeys_[j] 
					_cData_ = _aAnnotData_[_cNodeId_]
					_cOutput_ += "        " + String(_cNodeId_) + ": "
					_cOutput_ += This.DataToString(_cData_) + NL
				end
				_cOutput_ += NL
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
		return TRUE

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
		_cOutput_ += 'digraph "' + @oDiagram.Id() + '" {' + NL
		
		# Graph attributes
		_cOutput_ += This._GenerateGraphAttributes(_cTheme_)
		
		# Add title/subtitle if present
		if @oDiagram.Title() != ""
		    _cOutput_ += '    labelloc="t";' + NL
		    _cTitle_ = NL + @oDiagram.Title()
		    if @oDiagram.Subtitle() != ""
		        _cTitle_ += NL + @oDiagram.Subtitle() + NL
		    ok
		    _cTitle_ += NL + NL
		    _cOutput_ += '    label="' + _cTitle_ + '";' + NL
		    _cOutput_ += '    fontsize=16;' + NL + NL
		ok
	
		# Node attributes  
		_cOutput_ += This._GenerateNodeAttributes(_cTheme_)
		
		# Edge attributes
		_cOutput_ += This._GenerateEdgeAttributes(_cTheme_)
		
		_cOutput_ += NL
		
		# Generate nodes
		_cOutput_ += This._GenerateNodes(_cTheme_)
		_cOutput_ += NL
		
		# Generate clusters (subgraphs)
		if len(@oDiagram.Clusters()) > 0
			_cOutput_ += NL
			
			_aDiagramClusters1_ = @oDiagram.Clusters()
			_nDiagramClusters1Len_ = len(_aDiagramClusters1_)
			for _iLoopDiagramClusters1_ = 1 to _nDiagramClusters1Len_
				_aCluster_ = _aDiagramClusters1_[_iLoopDiagramClusters1_]
				_cClusterId_ = "cluster_" + _aCluster_["id"]
				_cLabel_ = _aCluster_["label"]
				_cColor_ = _aCluster_["color"]
				
				_cOutput_ += '    subgraph ' + _cClusterId_ + ' {' + NL
				_cOutput_ += '        label="' + _cLabel_ + '";' + NL
				_cOutput_ += '        style=filled;' + NL
				_cOutput_ += '        color="' + _cColor_ + '";' + NL
				_cOutput_ += '        fillcolor="' + _cColor_ + '20";' + NL  # 20 = transparency
				
				# List nodes in cluster
				_aClusternodes1_ = _aCluster_["nodes"]
				_nClusternodes1Len_ = len(_aClusternodes1_)
				for _iLoopClusternodes1_ = 1 to _nClusternodes1Len_
					_cNodeId_ = _aClusternodes1_[_iLoopClusternodes1_]
					_cOutput_ += '        ' + This._SanitizeNodeId(_cNodeId_) + ';' + NL
				end
				
				_cOutput_ += '    }' + NL
			end
		ok
	
		# Generate edges
		_cOutput_ += This._GenerateEdges(_cTheme_)
		
		_cOutput_ += NL + "}"
		
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
	    
	    _cResult_ += ']' + NL
	    return _cResult_

	def _GenerateNodeAttributes(_cTheme_)
		_cFont_ = This._GetFont()
		_nFontSize_ = This._GetFontSize()
		
		_cResult_ = '    node [fontname="' + _cFont_ + '", fontsize=' + _nFontSize_ + ']' + NL
	
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
		          ', arrowtail=' + @oDiagram.@cArrowTail + ']' + NL

		return _cResult_
	
	def _GetRankDir()
		_cLayout_ = StzLower(@oDiagram.@cLayout)
		
		# Handle empty/null layout
		if _cLayout_ = ""
			_cLayout_ = $cDefaultLayout
		ok
		
		_cRankDir_ = "TB"

		if _cLayout_ = "topdown" or StzFindFirst($acLayouts[:TopDown], _cLayout_)
			_cRankDir_ = "TB"
	
		but _cLayout_ = "bottomup" or StzFindFirst($acLayouts[:BottomUp], _cLayout_)
			_cRankDir_ = "BT"
	
		but _cLayout_ = "leftright" or StzFindFirst($acLayouts[:LeftRight], _cLayout_)
			_cRankDir_ = "LR"
	
		but _cLayout_ = "rightleft" or StzFindFirst($acLayouts[:RightLeft], _cLayout_)
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
	
	def _GetEdgeStyle()
		_cEdgeStyle_ = "solid"

		if @oDiagram.@cEdgeStyle != "" and @oDiagram.@cEdgeStyle != NULL
			_cEdgeStyle_ = StzResolveEdgeStyle(@oDiagram.@cEdgeStyle)
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
	    if HasKey(_aNode_, "properties") and HasKey(_aNode_["properties"], "ishelper") and _aNode_["properties"]["ishelper"] = TRUE
	        _cOutput_ = '    ' + _cNodeId_ + ' [shape=point, width=0.01, height=0.01, style=invis, fixedsize=true, label=""]' + NL
	        return _cOutput_
	    ok
	    
	    if StzLeft(_cNodeId_, 8) = "_helper_"
	        _cOutput_ = '    ' + _cNodeId_ + ' [shape=point, width=0.01, height=0.01, style=invis, fixedsize=true, label=""]' + NL
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
	    if NOT StzFindFirst(_cStyle_, "filled")
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
	    
	    _cOutput_ += ']' + NL
	    
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
		if HasKey(_aNode_, "properties") and _aNode_["properties"] != NULL and 
		   HasKey(_aNode_["properties"], "shape") and _aNode_["properties"]["shape"] != NULL
			return _aNode_["properties"]["shape"]
		ok
		
		# Get type for semantic mapping
		_cType_ = ""
		if HasKey(_aNode_, "properties") and _aNode_["properties"] != NULL and 
		   HasKey(_aNode_["properties"], "type") and _aNode_["properties"]["type"] != NULL
			_cType_ = StzLower("" + _aNode_["properties"]["type"])
		ok
		
		# Direct DOT shape (bypasses semantic mapping)
		if StzFindFirst($acDotShapes, _cType_) > 0
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
			if NOT StzFindFirst(_cRuleStyle_, "filled")
				_cRuleStyle_ += ",filled"
			ok
			if _cShape_ = "box" and NOT StzFindFirst(_cRuleStyle_, "rounded")
				_cRuleStyle_ = "rounded," + _cRuleStyle_
			ok
			return _cRuleStyle_
		ok
		
		# Polygon shapes don't support rounded
		
		if StzFindFirst($aPolygonShapes, _cShape_) > 0
			# Add filled if not already there
			if NOT StzFindFirst(_cBaseStyle_, "filled")
				return _cBaseStyle_ + ",filled"
			ok
			return _cBaseStyle_
		ok

		# For box-like shapes, add rounded and filled
		if NOT StzFindFirst(_cBaseStyle_, "filled")
			_cBaseStyle_ += ",filled"
		ok
		if NOT StzFindFirst(_cBaseStyle_, "rounded") and _cShape_ = "box"
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
	    if StzFindFirst(_cColor_, "#")
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
		if @oDiagram.@cNodeStrokeColor != "" and @oDiagram.@cNodeStrokeColor != NULL
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
				_cOutput_ += '    ' + _cFrom_ + ' -> ' + _cTo_ + ' [style=invis]' + NL
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
	    if HasKey(_aEdge_, "label") and _aEdge_["label"] != "" and _aEdge_["label"] != NULL
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
	    
	    _cOutput_ += NL
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
		return TRUE

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
		_cOutput_ = "graph TD" + NL
		
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
			if StzFindFirst(_aReservedWords_, StzLower(_cNodeId_)) > 0
				_cSafeNodeId_ = "node_" + _cNodeId_
			ok
	
			_cType_ = _aNode_["properties"]["type"]
			if _cType_ = "start"
				_cOutput_ += '    ' + _cSafeNodeId_ + '(["' + _cLabel_ + '"])' + NL
	
			but _cType_ = "endpoint"
				_cOutput_ += '    ' + _cSafeNodeId_ + '(["' + _cLabel_ + '"])' + NL
	
			but _cType_ = "decision"
				_cOutput_ += '    ' + _cSafeNodeId_ + '{{"' + _cLabel_ + '"}}' + NL
	
			but _cType_ = "process"
				_cOutput_ += '    ' + _cSafeNodeId_ + '["' + _cLabel_ + '"]' + NL
	
			else
				_cOutput_ += '    ' + _cSafeNodeId_ + '["' + _cLabel_ + '"]' + NL
			ok
		end
	
		_cOutput_ += NL
	
		_aEdges_ =  @oDiagram.Edges()
		_nLen_ = len(_aEdges_)

		for i = 1 to _nLen_
			_aEdge_ = _aEdges_[i]
			_cFromId_ = _aEdge_["from"]
			_cToId_ = _aEdge_["to"]
			
			# Escape reserved keywords in edges
			if StzFindFirst(_aReservedWords_, StzLower(_cFromId_)) > 0
				_cFromId_ = "node_" + _cFromId_
			ok
			if StzFindFirst(_aReservedWords_, StzLower(_cToId_)) > 0
				_cToId_ = "node_" + _cToId_
			ok
			
			if _aEdge_["label"] != "" and _aEdge_["label"] != NULL
				_cOutput_ += '    ' + _cFromId_ + ' -->|' + _aEdge_["label"] + '| ' + _cToId_ + NL
			else
				_cOutput_ += '    ' + _cFromId_ + ' --> ' + _cToId_ + NL
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
		return TRUE

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
		return TRUE

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
	
	def ContrastingTextColor(_cColor_)
		# Convert color to RGB
		_aRGB_ = This.ColorToRGB(_cColor_)
		_nR_ = _aRGB_[1]
		_nG_ = _aRGB_[2]
		_nB_ = _aRGB_[3]
		
		# Simple perceptual brightness formula (ITU BT.709)
		_nBrightness_ = (0.299 * _nR_ + 0.587 * _nG_ + 0.114 * _nB_)
		
		# Threshold at 150 for better contrast
		if _nBrightness_ < 150
			return "white"
		else
			return "black"
		ok
	
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

		if isString(pcColor) and StzFindFirst(pcColor, "#")
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
		
		return pacPalette[:blue]

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
		
		_acLines_ = split(pcContent, NL)
		_cSection_ = ""
		
		_nAcLines1Len_ = len(_acLines_)
		for _iLoopAcLines1_ = 1 to _nAcLines1Len_
			_cLine_ = _acLines_[_iLoopAcLines1_]
			_cLine_ = trim(_cLine_)
			
			if _cLine_ = "" or StzLeft(_cLine_, 1) = "#"
				loop
			ok

			# Style header
			if StzFindFirst(_cLine_, "style ")
				_aStyle_[:name] = This._ExtractQuoted(_cLine_)

			but StzFindFirst(_cLine_, "theme:")
				_aStyle_[:theme] = This._ExtractValue(_cLine_)

			but StzFindFirst(_cLine_, "layout:")
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
			but _cSection_ != "" and StzFindFirst(_cLine_, ":")
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
		_nPos_ = StzFindFirst(_cLine_, ":")
		if _nPos_ = 0 return "" ok
		_cValue_ = trim(StzMid(_cLine_, _nPos_ + 1, StzLen(_cLine_) - _nPos_))
		return This._ParseValue(_cValue_)

	def _ExtractQuoted(_cLine_)
		_nStart_ = StzFindFirst(_cLine_, '"')
		if _nStart_ = 0 return "" ok
		_nEnd_ = StzMid(_cLine_, _nStart_ + 1, StzLen(_cLine_) - _nStart_)
		_nEnd_ = StzFindFirst(_nEnd_, '"')
		return StzMid(_cLine_, _nStart_ + 1, _nEnd_ - 1)
