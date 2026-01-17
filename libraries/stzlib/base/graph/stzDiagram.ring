#--------------------------------------------------#
#  stzDiagram - DOMAIN SPECIALIZATION OF stzGraph  #
#  Workflows, org charts, semantic diagrams        #
#==================================================#

# NOTE : there some rules related to stzDiagram that are registred in
# stzGraphRule file, like "dag", "sox", and "gdpr" rules.

$acDiagramDefaultValidators = ["sox", "gdpr", "banking"]

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
		cClass = lower(classname(pObj))
		if cClass = "stzdiagram"
			return TRUE
		ok
	ok
	return FALSE

# STYLE RESOLUTION

func ResolveEdgeStyle(pStyle)
	cStyleKey = lower("" + pStyle)
	
	if HasKey($acEdgeStyles, cStyleKey)
		return $acEdgeStyles[cStyleKey]
	ok
	
	if ring_find(["solid", "dashed", "dotted", "bold"], cStyleKey)
		return cStyleKey
	ok
	
	return $cDefaultEdgeStyle

func ResolveNodeType(pcType)
	cTypeKey = lower("" + pcType)

	if ring_find($acDotShapes, cTypeKey) > 0
		return cTypeKey
	ok
	
	# Semantic types
	if ring_find($acNodeTypes, cTypeKey)
		return cTypeKey
	ok
	
	# Fallback mapping #TODO Shoud it be gloabal?
	aVisualMap = [
		:box = "process",
		:diamond = "decision",
		:ellipse = "start",
		:circle = "state",
		:cylinder = "storage",
		:doublecircle = "endpoint"
	]
	
	if HasKey(aVisualMap, cTypeKey)
		return aVisualMap[cTypeKey]
	ok

	# Map unsupported to supported shapes #TODO Shoud it be gloable?
	aShapeMap = [
		:square = "box",
		:rect = "box",
		:egg = "ellipse",
		:tab = "box",
		:folder = "box",
		:component = "box",
		:note = "box",
		:ellpise = "ellipse"
	]
	
	if HasKey(aShapeMap, cTypeKey)
		return aShapeMap[cTypeKey]
	ok
	
	return $cDefaultNodeType

# NODE TYPE FUNCTIONS

func DefaultNodeType()
	return $cDefaultNodeType

func NodeTypes()
	return $acNodeTypes

func IsValidNodeType(pcType)
	return ring_find($acNodeTypes, pcType) > 0

# EDGE STYLE FUNCTIONS

func IsValidEdgeStyle(pcStyle)
	return HasKey($acEdgeStyles, pcStyle)

func EdgeStyles()
	return $acEdgeStyles

func DefaultEdgeStyle()
	return $cDefaultEdgeStyle

func StyleForEdgeType(pcType)
	if HasKey($acEdgeStyles, pcType)
		return $acEdgeStyles[pcType]
	ok
	return $cDefaultEdgeStyle

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

	@acValidators = $acDiagramDefaultValidators

	@aLoadedStyles = []

	@cFocusColor = $cDefaultFocusColor
	@cOutputFormat = $cDefaultDiagramOutputFormat

	@acDiagramValidators = []  # Diagram-specific validators
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

		# Set diagram-specific default validators
		@acDiagramValidators = $acDiagramDefaultValidators  # ["sox", "gdpr", "banking"]
		@acValidators = @acDiagramValidators  # Override graph defaults

	def Name()
		return super.Id()

	def SetTheme(pTheme)
	    cThemeKey = lower(pTheme)
	    
	    if HasKey($aPalette, cThemeKey)
	        @cTheme = cThemeKey
	        
	        # Only apply theme fonts if not customized by user
	        if NOT @bFontCustomized and HasKey($aThemeFonts, cThemeKey)
	            @cFont = $aThemeFonts[cThemeKey][:font]
	            @nFontSize = $aThemeFonts[cThemeKey][:size]
	        ok
	    ok
	
	def SetLayout(pLayout)
		
		@cLayout = lower(pLayout)

	def SetEdgeStyle(pStyle)
		@cEdgeStyle = lower(pStyle)

	def SetEdgeColor(pColor)
		@cEdgeColor = ResolveColor(pColor)

	def SetNodeColor(pColor)
		@cNodeColor = ResolveColor(pColor)

	def SetNodeStrokeColor(pColor)
	    if pColor = "" or lower(pColor) = 'invisible'
	        @cNodeStrokeColor = ""
	    else
	        @cNodeStrokeColor = ResolveColor(pColor)
	    ok

	    def SetStrokeColor(pColor)
		This.SetNodeStrokeColor(pColor)

	def SetFont(pFont)
		@cFont = lower(pFont)
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
		cStyle = lower(pcStyle)
		# Replace + with ,
		cStyle = substr(cStyle, "+", ",")
		return cStyle
	
	def SetArrowHead(pcStyle)
		@cArrowHead = lower(pcStyle)
	
	def SetArrowTail(pcStyle)
		@cArrowTail = lower(pcStyle)
	
	def SetSplines(pcType)

	    cType = lower(pcType)
	    if ring_find($acSplineTypes, cType) > 0
	        @cSplineType = cType
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
	    switch lower(pcPreset)
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
		@cOutputFormat = lower(cFormat)

		def SetOutput(cFormat)
			@cOutputFormat = lower(cFormat)

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
		oResolver = new stzColorResolver()
		cResult = oResolver.ResolveFontColor(pBgColor)
		return cResult
	
	def ContrastingTextColor(cColor)
		oResolver = new stzColorResolver()
		cResult = oResolver.ContrastingTextColor(cColor)
		return cResult
	
	def ColorToRGB(cColor)
		oResolver = new stzColorResolver()
		cResult = oResolver.ColorToRGB(cColor)
		return cResult

	def NodeStrokeColorForTheme(cTheme)
		oResolver = new stzColorResolver()
		cResult = oResolver.NodeStrokeColorForTheme(cTheme)
		return cResult

	def ConvertColorTogray(cColor)
		oResolver = new stzColorResolver()
		cResult = oResolver.ConvertColorTogray(cColor)
		return cResult

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
		oCluster = [
			:id = pClusterId,
			:label = pLabel,
			:nodes = aNodeIds,
			:color = ResolveColor(pColor)
		]
		@aClusters + oCluster

	def Clusters()
		return @aClusters

	#-------------------------#
	#  ANNOTATION OPERATIONS  #
	#-------------------------#

	def AddAnnotation(oAnnotation)
		@aoAnnotations + oAnnotation

	def AnnotationsByType(pcType)
		aoFiltered = []
		nLen = len(@aoAnnotations)

		for i = 1 to nLen
			if @aoAnnotations[i].Type() = pcType
				aoFiltered + @aoAnnotations[i]
			ok
		end
		return aoFiltered

	def Annotations()
		return @aoAnnotations

	#-----------------------#
	#  TEMPLATE OPERATIONS  #
	#-----------------------#

	def AddTemplate(oTemplate) #TODO // #TODO Test this
		@aoTemplates + oTemplate

	def ApplyTemplates()
		nLen = len(@aoTemplates)
		for i = 1 to nLen
			@aoTemplates[i].Apply(This)
		end

	#--------------#
	#  VALIDATION  #
	#--------------#

	# Override parent to use diagram validators by default
	def Validate()
		return This.ValidateXT(@acValidators)
	
	# Single or multiple validators
	def ValidateXT(pValidators)
		if isString(pValidators)
			pValidators = lower(pValidators)
			return This._ValidateSingle(pValidators)
		but isList(pValidators)
			return This._ValidateMultiple(pValidators)
		ok
	
	def _ValidateSingle(pcValidator)
	    cValidator = lower(pcValidator)
	    
	    # CRITICAL: Clear previous rules before loading new ones
	    @aRules = []
	    
	    This.UseRulesFrom(cValidator)
	    
	    aResult = super.Validate()
	    
	    if NOT aResult[1]
	        aViolations = aResult[2]
	        acIssues = This._FlattenViolations(aViolations)
	        acAffected = This._ExtractAffectedNodes(aViolations)
	        
	        return [
	            :status = "fail",
	            :domain = cValidator,
	            :issueCount = len(aViolations),
	            :issues = acIssues,
	            :affectedNodes = acAffected
	        ]
	    ok
	    
	    return [
	        :status = "pass",
	        :domain = cValidator,
	        :issueCount = 0,
	        :issues = [],
	        :affectedNodes = []
	    ]
		
	def _ValidateMultiple(pacValidators)
		aResults = []
		nFailed = 0
		nTotal = 0
			
		for cValidator in pacValidators
			aResult = This._ValidateSingle(cValidator)
			aResults + aResult
				
			if aResult[:status] = "fail"
				nFailed++
			ok
			nTotal += aResult[:issueCount]
		end
			
		return [
			:status = iif(nFailed > 0, "fail", "pass"),
			:validatorsRun = len(pacValidators),
			:validatorsFailed = nFailed,
			:totalIssues = nTotal,
			:results = aResults,
			:affectedNodes = This._MergeAffectedNodes(aResults)
		]
		
	def _FlattenViolations(aViolations)
	    acIssues = []
	    for aViolation in aViolations
	        if HasKey(aViolation, :message)
	            pMsg = aViolation[:message]
	            
	            # Handle array of violation messages
	            if isList(pMsg)
	                for aSubViolation in pMsg
	                    if isList(aSubViolation) and HasKey(aSubViolation, :message)
	                        acIssues + aSubViolation[:message]
	                    but isString(aSubViolation)
	                        acIssues + aSubViolation
	                    ok
	                next
	            but isString(pMsg)
	                acIssues + pMsg
	            ok
	        ok
	    end
	    return acIssues
	
	def _ExtractAffectedNodes(aViolations)
	    acNodes = []
	    for aViolation in aViolations
	        if HasKey(aViolation, :message)
	            pMsg = aViolation[:message]
	            
	            # Handle array of nested violations
	            if isList(pMsg)
	                for aSubViolation in pMsg
	                    if isList(aSubViolation) and 
	                       HasKey(aSubViolation, :params) and 
	                       HasKey(aSubViolation[:params], :node)
	                        cNode = aSubViolation[:params][:node]
	                        if ring_find(acNodes, cNode) = 0
	                            acNodes + cNode
	                        ok
	                    ok
	                next
	            ok
	            
	            # Also handle direct violations (non-nested)
	            if HasKey(aViolation, :params) and 
	               HasKey(aViolation[:params], :node)
	                cNode = aViolation[:params][:node]
	                if ring_find(acNodes, cNode) = 0
	                    acNodes + cNode
	                ok
	            ok
	        ok
	    end
	    return acNodes
		
		def _MergeAffectedNodes(aResults)
			acAll = []
			for aResult in aResults
				if HasKey(aResult, :affectedNodes)
					for cNode in aResult[:affectedNodes]
						if ring_find(acAll, cNode) = 0
							acAll + cNode
						ok
					end
				ok
			end
			return acAll
	
	def Validators()
		return @acValidators
	
	def SetValidators(pacValidators)
		@acValidators = pacValidators
	
	def IsValid()
		return This.Validate()[:status] = "pass"
	
	def IsValidXT(pValidator)
		return This.ValidateXT(pValidator)[:status] = "pass"

	def NodesAffectedByVisualRules()
	    acResult = []
	    acKeys = keys(@aNodeRulesEffects)
	    for cKey in acKeys
	        acResult + cKey
	    next
	    return acResult
	
	def VisualRulesApplied()
	    aResult = []
	    for aRule in @aoVisualRules
	        aResult + [
	            :name = aRule[:name],
	            :conditionType = aRule[:conditionType],
	            :effectsCount = len(aRule[:effects])
	        ]
	    next
	    return aResult

	#----------------#
	#  VISUAL RULES  #
	#----------------#

	# This section manages visual styling rules that change
	# diagram appearance based on node/edge properties.

	def RegisterVisualRule(pcRuleName, paDefinition)
		# Store visual rule as data structure
		aRule = [
			:name = pcRuleName,
			:conditionType = paDefinition[:conditionType],
			:conditionParams = paDefinition[:conditionParams],
			:effects = paDefinition[:effects]
		]
		@aoVisualRules + aRule
	
	def ApplyVisualRules()
		@aNodeRulesEffects = []
		@aEdgesRulesEffects = []
		
		# Apply to nodes
		aNodes = This.Nodes()
		for aNode in aNodes
			aEnhancements = This._ApplyRulesToElement(aNode, "node")
			if len(aEnhancements) > 0
				@aNodeRulesEffects[aNode[:id]] = aEnhancements
			ok
		end
		
		# Apply to edges
		aEdges = This.Edges()
		for aEdge in aEdges
			aEnhancements = This._ApplyRulesToElement(aEdge, "edge")
			cKey = aEdge[:from] + "->" + aEdge[:to]
			if len(aEnhancements) > 0
				@aEdgesRulesEffects[cKey] = aEnhancements
			ok
		end
	
	def _ApplyRulesToElement(aElement, cType)
	    aEnhancements = []
	    
	    for aRule in @aoVisualRules
	        aContext = This._BuildRuleContext(aElement)
	        
	        if This._RuleMatches(aRule, aContext)
	            # DEBUG
	            # ? "Rule '" + aRule[:name] + "' matched node: " + aElement[:id]
	            # ? "  Effects: " + @@(aRule[:effects])
	            
	            aEffects = aRule[:effects]
	            
	            # Merge effects
	            for aEffect in aEffects
	                aEnhancements[aEffect[1]] = aEffect[2]
	            end
	        ok
	    end
	    
	    # DEBUG
	    # if len(aEnhancements) > 0
	    #     ? "Final enhancements for " + aElement[:id] + ": " + @@(aEnhancements)
	    # ok
	    
	    return aEnhancements

	
	def _RuleMatches(aRule, aContext)
		cType = aRule[:conditionType]
		aParams = aRule[:conditionParams]
		
		switch cType
		on "property_range"
			return This._MatchRange(aContext, aParams)
		on "property_equals"
			return This._MatchEquals(aContext, aParams)
		on "property_exists"
			return This._MatchExists(aContext, aParams)
		on "tag_exists"
			return This._MatchTag(aContext, aParams)
		off
		
		return FALSE
	
	def _MatchRange(aContext, aParams)
		if NOT HasKey(aContext, :properties)
			return FALSE
		ok
		
		cKey = aParams[1]
		nMin = aParams[2]
		nMax = aParams[3]
		
		if NOT HasKey(aContext[:properties], cKey)
			return FALSE
		ok
		
		pValue = aContext[:properties][cKey]
		if NOT isNumber(pValue)
			return FALSE
		ok
		
		return (pValue >= nMin and pValue <= nMax)
	
	def _MatchEquals(aContext, aParams)
		if NOT HasKey(aContext, :properties)
			return FALSE
		ok
		
		cKey = aParams[1]
		pExpected = aParams[2]
		
		if NOT HasKey(aContext[:properties], cKey)
			return FALSE
		ok
		
		return (aContext[:properties][cKey] = pExpected)
	
	def _MatchExists(aContext, aParams)
		if NOT HasKey(aContext, :properties)
			return FALSE
		ok
		
		cKey = aParams[1]
		return HasKey(aContext[:properties], cKey)
	
	def _MatchTag(aContext, aParams)
		if NOT HasKey(aContext, :tags)
			return FALSE
		ok
		
		cTag = aParams[1]
		return ring_find(aContext[:tags], cTag) > 0
	
	def _BuildRuleContext(aElement)
		aContext = aElement
		
		if HasKey(aElement, :properties) and aElement[:properties] != NULL
			aContext[:properties] = aElement[:properties]
			aContext[:tags] = []
			if HasKey(aElement[:properties], :tags)
				aContext[:tags] = aElement[:properties][:tags]
			ok
		ok
		
		return aContext
	
	#-----------------#
	#  QUERY METHODS  #
	#-----------------#
	
	# properties-based queries
	def NodesWithProperty(pcProp)
		acResult = []
		aNodes = This.Nodes()
		
		for aNode in aNodes
			if HasKey(aNode, :properties) and 
			   HasKey(aNode[:properties], pcProp)
				acResult + aNode[:id]
			ok
		end
		
		return acResult
	
	def NodesWith(pcProp, pcOp, pValue)
		# Reuse graph query system
		oQuery = new stzGraphQuery(This, "nodes")
		oQuery.Where(pcProp, pcOp, pValue)
		return oQuery.Run()
	
	def NodesWithTag(pcTag)
		acResult = []
		aNodes = This.Nodes()
		
		for aNode in aNodes
			if HasKey(aNode, :properties) and 
			   HasKey(aNode[:properties], :tags) and
			   ring_find(aNode[:properties][:tags], pcTag) > 0
				acResult + aNode[:id]
			ok
		end
		
		return acResult
	
	def EdgesWithProperty(pcProp)
		acResult = []
		aEdges = This.Edges()
		
		for aEdge in aEdges
			if HasKey(aEdge, :properties) and 
			   HasKey(aEdge[:properties], pcProp)
				acResult + (aEdge[:from] + "->" + aEdge[:to])
			ok
		end
		
		return acResult
	
	def EdgesWithPropertyValue(pcProp, pValue)
		acResult = []
		aEdges = This.Edges()
		
		for aEdge in aEdges
			if HasKey(aEdge, :properties) and 
			   HasKey(aEdge[:properties], pcProp) and
			   aEdge[:properties][pcProp] = pValue
				acResult + (aEdge[:from] + "->" + aEdge[:to])
			ok
		end
		
		return acResult
	
	#-------------------#
	#  properties LEGEND  #
	#-------------------#
	
	def propertiesLegend()
		acLegend = ["=== properties LEGEND ===", ""]
		
		for oRule in @aoVisualRules
			cCondition = oRule.@cConditionType
			aParams = oRule.@aConditionParams
			aEffects = oRule.Effects()
			
			acLegend + "When: " + cCondition
			if len(aParams) > 0
				acLegend + "  Params: " + @@(aParams)
			ok
			
			for aEffect in aEffects
				acLegend + "  Ã¢â€ â€™ " + aEffect[1] + ": " + aEffect[2]
			next
			
			acLegend + ""
		end
		
		return acLegend

	#-----------#
	#  METRICS  #
	#-----------#

	def ComputeMetrics()
		aMetrics = []
		anAllPaths = []
		aNodes = This.Nodes()
		nLenNodes = len(aNodes)

		for i = 1 to nLenNodes
			aReachable = This.ReachableFrom(aNodes[i]["id"])
			nLen = len(aReachable)
			if nLen > 1
				anAllPaths + (nLen - 1)
			ok
		end

		nAvg = 0
		nLen = len(anAllPaths)

		nSum = 0
		for i = 1 to nLen
			nSum += anAllPaths[i]
		end
		nAvg = nSum / nLen

		nMax = 0
		for i = 1 to nLen
			if anAllPaths[i] > nMax
				nMax = anAllPaths[i]
			ok
		end

		aMetrics[:avgPathLength] = nAvg
		aMetrics[:maxPathLength] = nMax
		aMetrics[:bottlenecks] = This.BottleneckNodes()
		aMetrics[:density] = This.NodeDensity()
		aMetrics[:nodeCount] = This.NodeCount()
		aMetrics[:edgeCount] = This.EdgeCount()

		return aMetrics

	#-----------------#
	#  VISUALIZATION  #
	#-----------------#

	def View()

		# Generate DOT code
		cDotCode = This.Dot()

		# Create stzDotCode instance and execute
		oDotExec = new stzDotCode()
		oDotExec.SetCode(cDotCode)
		oDotExec.SetOutputFormat(@cOutputFormat)
		oDotExec.ExecuteAndView()
		
		def Display()
			This.View()

	#----------#
	#  EXPORT  #
	#----------#

	def ToHashlist()
		aBase = super.ToHashlist()
		aBase["theme"] = @cTheme
		aBase["layout"] = @cLayout
		aBase["clusters"] = @aClusters
		aBase["annotations"] = @aoAnnotations
		aBase["templates"] = @aoTemplates
		return aBase

	def stzdiag()
		oConv = new stzDiagramToStzDiag(This)
		return oConv.stzdiag()

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
		oConv = new stzDiagramToDot(This)
		cResult = oConv.Code()
		return cResult

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
		oConv = new stzDiagramToJson(This)
		return oConv.Code()

		def ToJson()
			return This.Json()

	def Mermaid()
		oConv = new stzDiagramToMermaid(This)
		return oConv.Code()

		def ToMermaid()
			return This.Mermaid()

	#-----------------#
	#  WRITE TO FILE  # #TODO Shoulmd move to stzGraph level
	#-----------------#

	def WriteToFile()
		oConv = new stzDiagramToStzDiag(This)
		bSuccess = oConv.WriteToFile(This.Name() + ".stzdiag")
		return bSuccess

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

		pcFolder = substr(pcFolder, "/", "")
		pcFolder = substr(pcFolder, "\", "")

		oConv = new stzDiagramToStzDiag(This)
		bSuccess = oConv.WriteToFile(pcFolder + "/" + This.Name() + ".stzdiag")
		return bSuccess

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
		oConv = new stzDiagramToDot(This)
		bSuccess = oConv.WriteToFile(This.Name() + ".dot")
		return bSuccess

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

		pcFolder = substr(pcFolder, "/", "")
		pcFolder = substr(pcFolder, "\", "")

		oConv = new stzDiagramToDot(This)
		bSuccess = oConv.WriteToFile(pcFolder + "/" + This.Name() + ".dot")
		return bSuccess

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
		oConv = new stzDiagramToMermaid(This)
		bSuccess = oConv.WriteToFile(This.Name() + ".mmd")
		return bSuccess

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

		pcFolder = substr(pcFolder, "/", "")
		pcFolder = substr(pcFolder, "\", "")

		oConv = new stzDiagramToMermaid(This)
		bSuccess = oConv.WriteToFile(pcFolder + "/" + This.Name() + ".mmd")
		return bSuccess


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
		oConv = new stzDiagramToJson(This)
		bSuccess = oConv.WriteToFile(This.Name() + ".json")
		return bSuccess

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

		pcFolder = substr(pcFolder, "/", "")
		pcFolder = substr(pcFolder, "\", "")

		oConv = new stzDiagramToJson(This)
		bSuccess = oConv.WriteToFile(pcFolder + "/" + This.Name() + ".json")
		return bSuccess


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
		aExplanation = [
			:diagram = @cId,
			:structure = "",
			:rules = "",
			:effects = ""
		]
		
		nNodes = This.NodeCount()
		nEdges = This.EdgeCount()
		aExplanation[:structure] = "Diagram '" + @cId + "' contains " + nNodes + " nodes and " + nEdges + " edges."
		
		nRules = len(@aoVisualRules)
		if nRules = 0
			aExplanation[:rules] = "No visual rules defined."
		else
			cRules = "Applied " + nRules + " visual rule(s): "
			for i = 1 to nRules
				cRules += @aoVisualRules[i].@cRuleId
				if i < nRules
					cRules += ", "
				ok
			end
			aExplanation[:rules] = cRules
		ok
		
		nNodesAffected = len(@aNodeRulesEffects)
		nEdgesAffected = len(@aEdgesRulesEffects)
		
		if nNodesAffected = 0 and nEdgesAffected = 0
			aExplanation[:effects] = "No rules matched any elements."
		else
			cEffects = ""
			if nNodesAffected > 0
				cEffects += ""+ nNodesAffected + " node(s) enhanced"
			ok
			if nEdgesAffected > 0
				if cEffects != ""
					cEffects += ", "
				ok
				cEffects += ""+ nEdgesAffected + " edge(s) enhanced"
			ok
			aExplanation[:effects] = cEffects + "."
		ok
		
		return aExplanation

	#----------------------------------#
	#  IMPORT WITH SUBDIAGRAM SUPPORT  #
	#----------------------------------#

	def ImportDiag(cDiagString)
		# Parse first node of imported diagram
		cFirstNodeId = This.ExtractFirstNodeId(cDiagString)
		
		if cFirstNodeId = ""
			StzRaise("Cannot parse imported diagram - no nodes found")
		ok
		
		# Check if current diagram has nodes
		if This.NodeCount() > 0
			# Check if first node exists in current diagram
			if This.HasNode(cFirstNodeId)
				# Import as subdiagram under this node
				This.ImportAsSubdiagram(cDiagString, cFirstNodeId)
			else
				StzRaise("Import failed: First node '" + cFirstNodeId + "' not found in current diagram. " +
					"Either add node '" + cFirstNodeId + "', or clear the diagram with RemoveAllNodes()")
			ok
		else
			# Empty diagram - do normal import
			This.ParseAndImport(cDiagString)
		ok

	def ExtractFirstNodeId(cDiagString)
		acLines = @split(cDiagString, NL)
		nLen = len(acLines)
		bInNodesSection = FALSE

		for i = 1 to nLen
			cLine = trim(acLines[i])
			if cLine = "nodes"
				bInNodesSection = TRUE
				loop
			ok
			
			if bInNodesSection and cLine != "" and 
			   NOT substr(cLine, "label:") and 
			   NOT substr(cLine, "type:") and 
			   NOT substr(cLine, "color:")
				return cLine
			ok
			
			if bInNodesSection and (cLine = "edges" or cLine = "clusters")
				exit
			ok
		end
	
	def ImportAsSubdiagram(cDiagString, cParentNodeId)
		oTemp = new stzDiagram("temp")
		oTemp.ParseAndImport(cDiagString)
		
		acNodes = oTemp.Nodes()
		nLenNodes = len(acNodes)

		acEdges = oTemp.Edges()
		nLenEdges = len(acEdges)
		
		# Add all nodes EXCEPT the parent (which already exists)

		for i = 1 to nLenNodes
			if acNodes[i]["id"] != cParentNodeId
				This.AddNodeXTT(acNodes[i]["id"], acNodes[i]["label"], [
					:type = acNodes[i]["properties"]["type"], 
					:color = acNodes[i]["properties"]["color"]
				])
			ok
		end

		# Add all edges
		for i = 1 to nLenEdges
			cFrom = acEdges[i]["from"]
			cTo = acEdges[i]["to"]
			
			# All edges are added normally since parent node exists
			This.Connect(cFrom, cTo)
		end

	def ParseAndImport(cDiagString)
		acLines = @split(cDiagString, NL)
		cCurrentSection = ""
		cCurrentNode = ""
		cLabel = ""
		cType = ""
		cColor = ""
		aEdgesToAdd = []  # Store edges for later

		nLen = len(acLines)
		for i = 1 to nLen
			cLine = trim(acLines[i])
			if cLine = "" or
			   left(cLine, 1) = "#"
				loop
			ok
			
			if substr(cLine, "diagram ")
				cTitle = trim(@substr(cLine, 10, stzlen(cLine)-1))			
				@cId = cTitle
				
			but cLine = "properties"
				cCurrentSection = "properties"
				
			but cLine = "nodes"
				cCurrentSection = "nodes"
				
			but cLine = "edges"
				cCurrentSection = "edges"
				
			but cCurrentSection = "properties" and substr(cLine, ":")
				aParts = @split(cLine, ":")
				cKey = trim(aParts[1])
				cValue = trim(aParts[2])
				
				if cKey = "theme"
					This.SetTheme(cValue)
				but cKey = "layout"
					This.SetLayout(cValue)
				ok
				
			but cCurrentSection = "nodes"
				if NOT substr(cLine, "label:") and NOT substr(cLine, "type:") and NOT substr(cLine, "color:")
					if cCurrentNode != "" and cLabel != ""
						if cType = "" cType = $cDefaultNodeType ok
						if cColor = "" cColor = $cDefaultNodeColor ok
						This.AddNodeXTT(cCurrentNode, cLabel, [ :type = cType, :color = cColor ])
					ok
					cCurrentNode = cLine
					cLabel = ""
					cType = ""
					cColor = ""

				but substr(cLine, "label:")
					cLabel = @substr(cLine, 9, stzlen(cLine)-1)

				but substr(cLine, "type:")
					cType = trim(@substr(cLine, 7, stzlen(cLine)))

				but substr(cLine, "color:")
					cColor = trim(@substr(cLine, 8, stzlen(cLine)))
				ok
				
			but cCurrentSection = "edges" and substr(cLine, "->")
				aEdgeParts = @split(cLine, "->")
				cFrom = trim(aEdgeParts[1])
				cTo = trim(aEdgeParts[2])
				aEdgesToAdd + [cFrom, cTo]  # Store for later
			ok
		end

		# Add last node
		if cCurrentNode != "" and cLabel != ""
			if cType = "" cType = $cDefaultNodeType ok
			if cColor = "" cColor = $cDefaultNodeColor ok
			This.AddNodeXTT(cCurrentNode, cLabel, [ :type = cType, :color = cColor ])
		ok

		# Now add all edges
		nLen = len(aEdgesToAdd)
		for i = 1 to nLen
			This.Connect(aEdgesToAdd[i][1], aEdgesToAdd[i][2])
		end
	
	#--------------------#
	#  FOCUS MANAGEMENT  #
	#--------------------#

	def ApplyFocusTo(acNodeIds)
	    # Reset all first
	    This.ResetAllNodeColors()
	    
	    # Apply focus to specified nodes
	    nLen = len(acNodeIds)
	    for i = 1 to nLen
	        This.SetNodeProperty(acNodeIds[i], "color", @cFocusColor)
	    end
	
	def ResetAllNodeColors()
	    aNodes = This.Nodes()
	    nLen = len(aNodes)
	    for i = 1 to nLen
	        cNodeId = aNodes[i]["id"]
	        This.SetNodeProperty(cNodeId, "color", @cNodeColor)
	    end

	#-------------------------#
	#  STYLE FILE MANAGEMENT  #
	#-------------------------#

	def LoadStyle(pSource)
		if isString(pSource)
			if right(pSource, 8) = ".stzstyl"
				oParser = new stzStylParser()
				aStyle = oParser.ParseFile(pSource)
			else
				oParser = new stzStylParser()
				aStyle = oParser.Parse(pSource)
			ok
			
			This._ApplyStyle(aStyle)
			@aLoadedStyles + aStyle[:name]
		ok
	
	def _ApplyStyle(aStyle)
		# Apply theme
		if HasKey(aStyle, :theme) and aStyle[:theme] != ""
			This.SetTheme(aStyle[:theme])
		ok
		
		# Apply layout
		if HasKey(aStyle, :layout) and aStyle[:layout] != ""
			This.SetLayout(aStyle[:layout])
		ok
		
		# Apply colors
		if HasKey(aStyle, :colors) and len(aStyle[:colors]) > 0
			nLen = len(aStyle[:colors])
			for i = 1 to nLen step 2
				cKey = aStyle[:colors][i]
				cValue = aStyle[:colors][i + 1]
				
				# Update color palette
				if HasKey(@aPalette[@cTheme], cKey)
					@aPalette[@cTheme][cKey] = cValue
				ok
			end
		ok
		
		# Apply fonts
		if HasKey(aStyle, :fonts) and len(aStyle[:fonts]) > 0
			nLen = len(aStyle[:fonts])
			for i = 1 to nLen step 2
				cKey = aStyle[:fonts][i]
				pValue = aStyle[:fonts][i + 1]
				
				if cKey = "default"
					This.SetFont(pValue)
				but cKey = "size"
					This.SetFontSize(pValue)
				ok
			end
		ok
		
		# Apply edge settings
		if HasKey(aStyle, :edges) and len(aStyle[:edges]) > 0
			nLen = len(aStyle[:edges])
			for i = 1 to nLen step 2
				cKey = aStyle[:edges][i]
				pValue = aStyle[:edges][i + 1]
				
				if cKey = "style"
					This.SetEdgeStyle(pValue)
				but cKey = "color"
					This.SetEdgeColor(pValue)
				but cKey = "spline"
					This.SetSplines(pValue)
				but cKey = "penwidth"
					This.SetEdgePenWidth(pValue)
				ok
			end
		ok
		
		# Apply node settings
		if HasKey(aStyle, :nodes) and len(aStyle[:nodes]) > 0
			nLen = len(aStyle[:nodes])
			for i = 1 to nLen step 2
				cKey = aStyle[:nodes][i]
				pValue = aStyle[:nodes][i + 1]
				
				if cKey = "penwidth"
					This.SetNodePenWidth(pValue)
				but cKey = "penstyle"
					This.SetNodePenStyle(pValue)
				but cKey = "color"
					This.SetNodeColor(pValue)
				but cKey = "strokecolor"
					This.SetStrokeColor(pValue)
				ok
			end
		ok
		
		# Apply focus settings
		if HasKey(aStyle, :focus) and len(aStyle[:focus]) > 0
			nLen = len(aStyle[:focus])
			for i = 1 to nLen step 2
				cKey = aStyle[:focus][i]
				pValue = aStyle[:focus][i + 1]
				
				if cKey = "color"
					This.SetFocusColor(pValue)
				but cKey = "penwidth"
					@nFocusPenWidth = pValue
				ok
			end
		ok
	
	def LoadedStyles()
		return @aLoadedStyles
	
	def ExportToStyl()
		cStyl = 'style "' + @cId + '_style"' + NL
		cStyl += '    theme: ' + @cTheme + NL
		cStyl += '    layout: ' + @cLayout + NL + NL
		
		cStyl += 'colors' + NL
		if HasKey(@aPalette, @cTheme)
			acKeys = keys(@aPalette[@cTheme])
			for cKey in acKeys
				cStyl += '    ' + cKey + ': ' + @aPalette[@cTheme][cKey] + NL
			end
		ok
		cStyl += NL
		
		cStyl += 'fonts' + NL
		cStyl += '    default: ' + @cFont + NL
		cStyl += '    size: ' + @nFontSize + NL + NL
		
		cStyl += 'edges' + NL
		cStyl += '    style: ' + @cEdgeStyle + NL
		cStyl += '    color: ' + @cEdgeColor + NL
		cStyl += '    spline: ' + @cSplineType + NL
		cStyl += '    penwidth: ' + @nEdgePenWidth + NL + NL
		
		cStyl += 'nodes' + NL
		cStyl += '    penwidth: ' + @nNodePenWidth + NL
		cStyl += '    penstyle: ' + @cNodePenStyle + NL
		cStyl += '    color: ' + @cNodeColor + NL
		if @cNodeStrokeColor != ""
			cStyl += '    strokecolor: ' + @cNodeStrokeColor + NL
		ok
		cStyl += NL
		
		cStyl += 'focus' + NL
		cStyl += '    color: ' + @cFocusColor + NL
		
		return cStyl
	
	def WriteToStylFile(pcFilename)
		if NOT right(pcFileName, 8) = ".stzstyl"
			pcFileName += ".stzstyl"
		ok
		write(pcFilename, This.ExportToStyl())

		def WriteStyl(pcFileName)
			This.WriteToStylFile(pcFilename)

#==========================================#
#  stzDiagramAnnotator - properties OVERLAY  #
#==========================================#

class stzDiagramAnnotator

	@cType = ""
	@aNodeData = []

	def init(pcType)
		@cType = pcType

	def Type()
		return @cType

	def Annotate(pNodeId, aData)
		if CheckParams()
			if isList(aData) and StzListQ(aData).IsWithNamedParam()
				aData = aData[2]
			ok
		ok

		@aNodeData[pNodeId] = aData

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

class stzDiagramToStzDiag

	@oDiagram
	@cStzDiagCode

	def init(poDiagram)
		if NOT ( isObject(poDiagram) and ring_classname(poDiagram) = "stzdiagram")
			StzRaise("Incorrect param type! poDiagram must be a stzDiagram object.")
		ok

		@oDiagram = poDiagram
		This._Generate()

	def _Generate()
		cOutput = ""

		# Generating diagram attributes

		cOutput += 'diagram "' +
			   @oDiagram.Id() + '"' + NL + NL

		cOutput += "properties" + NL
		cOutput += "    theme: " + Lower(@oDiagram.@cTheme) + NL
		cOutput += "    layout: " + Lower(@oDiagram.@cLayout) + NL + NL

		# Generating the diagram title

		if @oDiagram.Title() != ""
		    cTitle = @oDiagram.Title()
		    cSubtitle = @oDiagram.Subtitle()
		    if trim(cSubtitle) != ""
			cTitle += " : " + cSubTitle
		    ok

		    cOutput += '    labelloc="t";' + NL

		    cOutput += '    label="' + cTitle
		    cOutput += '";'
		    cOutput += '    fontsize=16;'
		ok

		# Generating nodes

		cOutput += "nodes" + NL
		aNodes = @oDiagram.Nodes()
		nLen = len(aNodes)

		for i = 1 to nLen
			aNode = aNodes[i]
			cOutput += "    " + aNode["id"] + NL
			cOutput += "        label: " + This.EscapeString(aNode["label"]) + NL

			if aNode["properties"]["type"] != ""
				cOutput += "        type: " + Lower(aNode["properties"]["type"]) + NL
			ok

			if aNode["properties"]["color"] != ""
				cOutput += "        color: " + aNode["properties"]["color"] + NL
			ok

			cOutput += NL
		end

		# Generating edges

		aEdges = @oDiagram.Edges()
		nLen = len(aEdges)

		if nLen > 0
			cOutput += "edges" + NL
			for i = 1 to nLen
				aEdge = aEdges[i]
				cOutput += "    " + aEdge["from"] + " -> " + aEdge["to"] + NL

				cLabel = aEdge["label"]
				if cLabel != ""
					cOutput += "        label: " + This.EscapeString(cLabel) + NL
				ok

				cOutput += NL
			end

		ok

		# Generating clusters

		aClusters = @oDiagram.Clusters()
		nLen = len(aClusters)
		if nLen > 0
			cOutput += "clusters" + NL

			for i = 1 to nLen
				aCluster = aClusters[i]
				cOutput += "    " + aCluster["id"] + NL
				cOutput += "        label: " + This.EscapeString(aCluster["label"]) + NL
				cNodeList = This.NodeListToString(aCluster["nodes"])
				cOutput += "        nodes: [" + cNodeList + "]" + NL
				cOutput += "        color: " + aCluster["color"] + NL
				cOutput += NL
			end
		ok

		# Generating annotations

		aAnnotations = @oDiagram.Annotations()
		nLen = len(aAnnotations)

		if nLen > 0
			cOutput += "annotations" + NL
			for i = 1 to nLen
				aAnnot = aAnnotations[i]
				cOutput += "    " + Lower(aAnnot.Type()) + NL

				aAnnotData = aAnnot.NodesData()

				acKeys = Keys(aAnnotData)
				nLenK = len(acKeys)

				for j = 1 to nLenK
					cNodeId = acKeys[j] 
					cData = aAnnotData[cNodeId]
					cOutput += "        " + String(cNodeId) + ": "
					cOutput += This.DataToString(cData) + NL
				end
				cOutput += NL
			end
		ok

		# Setting the DOT code

		@cStzDiagCode = cOutput

	def stzdiag()
		return @cStzDiagCode

		def stzdiagCode()
			return @cStzDiagCode

		def Content()
			return @cStzDiagCode

	def WriteToFile(pFilename)
		oFile = fopen(pFilename, "w")
		fwrite(oFile, This.stzdiag())
		fclose(oFile)
		return TRUE

	def EscapeString(pStr)
		return '"' +
			Replace(pStr, '"', '\"') + '"'

	def NodeListToString(aNodes)
		cResult = ""
		for cNode in aNodes
			cResult += cNode + ", "
		end
		if cResult != ""
			cResult = Left(cResult, stzlen(cResult) - 2)
		ok
		return cResult

	def DataToString(aData)
		if NOT @IsHashList(aData)
			return "null"
		ok

		cResult = "{"
		for cKey in Keys(aData)
			cValue = aData[cKey]
			if isString(cValue)
				cResult += cKey + ": " + This.EscapeString(cValue) + ", "
			else
				cResult += cKey + ": " + String(cValue) + ", "
			ok
		end
		if cResult != "{"
			cResult = Left(cResult, stzlen(cResult) - 2)
		ok
		cResult += "}"
		return cResult


#==================================#
#  stzDiagramToDot - GRAPHVIZ DOT  #
#==================================#

class stzDiagramToDot

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
	
		cOutput = ""
		
		# Apply visual rules if any
		if len(@oDiagram.@aoVisualRules) > 0
			@oDiagram.ApplyVisualRules()
		ok
		
		# Get theme
		cTheme = This._GetTheme()
		
		# Start digraph
		cOutput += 'digraph "' + @oDiagram.Id() + '" {' + NL
		
		# Graph attributes
		cOutput += This._GenerateGraphAttributes(cTheme)
		
		# Add title/subtitle if present
		if @oDiagram.Title() != ""
		    cOutput += '    labelloc="t";' + NL
		    cTitle = NL + @oDiagram.Title()
		    if @oDiagram.Subtitle() != ""
		        cTitle += NL + @oDiagram.Subtitle() + NL
		    ok
		    cTitle += NL + NL
		    cOutput += '    label="' + cTitle + '";' + NL
		    cOutput += '    fontsize=16;' + NL + NL
		ok
	
		# Node attributes  
		cOutput += This._GenerateNodeAttributes(cTheme)
		
		# Edge attributes
		cOutput += This._GenerateEdgeAttributes(cTheme)
		
		cOutput += NL
		
		# Generate nodes
		cOutput += This._GenerateNodes(cTheme)
		cOutput += NL
		
		# Generate clusters (subgraphs)
		if len(@oDiagram.Clusters()) > 0
			cOutput += NL
			
			for aCluster in @oDiagram.Clusters()
				cClusterId = "cluster_" + aCluster["id"]
				cLabel = aCluster["label"]
				cColor = aCluster["color"]
				
				cOutput += '    subgraph ' + cClusterId + ' {' + NL
				cOutput += '        label="' + cLabel + '";' + NL
				cOutput += '        style=filled;' + NL
				cOutput += '        color="' + cColor + '";' + NL
				cOutput += '        fillcolor="' + cColor + '20";' + NL  # 20 = transparency
				
				# List nodes in cluster
				for cNodeId in aCluster["nodes"]
					cOutput += '        ' + This._SanitizeNodeId(cNodeId) + ';' + NL
				end
				
				cOutput += '    }' + NL
			end
		ok
	
		# Generate edges
		cOutput += This._GenerateEdges(cTheme)
		
		cOutput += NL + "}"
		
		@cDotCode = cOutput
	
	def _GetTheme()
		cTheme = lower(@oDiagram.@cTheme)
		if cTheme = ""
			cTheme = $cDefaultColorTheme
		ok
		return cTheme

	def _GenerateGraphAttributes(cTheme)
	    cRankDir = This._GetRankDir()
	    cFont = This._GetFont()
	    nFontSize = This._GetFontSize()
	    
	    cResult = '    graph [rankdir=' + cRankDir + 
	               ', bgcolor=white' +
	               ', fontname="' + cFont + '"' +
	               ', fontsize=' + nFontSize +
	               ', splines=' + @oDiagram.@cSplineType +
	               ', nodesep=' + @oDiagram.@nNodeSep +
	               ', ranksep=' + @oDiagram.@nRankSep +
	               ', ordering=out' +
	               ', tooltip=" "'  #TODO // Has no effect
	    
	    if @oDiagram.@bConcentrate
	        cResult += ', concentrate=true'
	    ok
	    
	    cResult += ']' + NL
	    return cResult

	def _GenerateNodeAttributes(cTheme)
		cFont = This._GetFont()
		nFontSize = This._GetFontSize()
		
		cResult = '    node [fontname="' + cFont + '", fontsize=' + nFontSize + ']' + NL
	
		return cResult

	def _GenerateEdgeAttributes(cTheme)
		cFont = This._GetFont()
		nFontSize = This._GetFontSize()
		cEdgeColor = This._GetEdgeColor(cTheme)
		cEdgeStyle = This._GetEdgeStyle()

		cResult = '    edge [fontname="' + cFont + '", fontsize=' + nFontSize + 
		          ', color="' + cEdgeColor + '", style=' + cEdgeStyle +
		          ', penwidth=' + @oDiagram.@nEdgePenWidth + 
		          ', arrowhead=' + @oDiagram.@cArrowHead + 
		          ', arrowtail=' + @oDiagram.@cArrowTail + ']' + NL

		return cResult
	
	def _GetRankDir()
		cLayout = lower(@oDiagram.@cLayout)
		
		# Handle empty/null layout
		if cLayout = ""
			cLayout = $cDefaultLayout
		ok
		
		cRankDir = "TB"

		if cLayout = "topdown" or ring_find($acLayouts[:TopDown], cLayout)
			cRankDir = "TB"
	
		but cLayout = "bottomup" or ring_find($acLayouts[:BottomUp], cLayout)
			cRankDir = "BT"
	
		but cLayout = "leftright" or ring_find($acLayouts[:LeftRight], cLayout)
			cRankDir = "LR"
	
		but cLayout = "rightleft" or ring_find($acLayouts[:RightLeft], cLayout)
			cRankDir = "RL"
		ok
	
		return cRankDir
	
	def _GetFont()
		cFont = @oDiagram.@cFont
		if cFont = ""
			cFont = $cDefaultFont
		ok

		return cFont
	
	def _GetFontSize()
		nFontSize = @oDiagram.@nFontSize
		if nFontSize = 0 or nFontSize = ""
			nFontSize = $cDefaultFontSize
		ok

		return nFontSize
	
	def _GetEdgeColor(cTheme)
		# Use resolved color from diagram, default to black
		cEdgeColor = @oDiagram.@cEdgeColor
		
		if cEdgeColor = ""
			cEdgeColor = ResolveColor("black")  # Changed from using @cDefaultEdgeColor
		else
			cEdgeColor = ResolveColor(cEdgeColor)
		ok
		
		# Theme-specific edge colors
		if cTheme = "print"
			cEdgeColor = ResolveColor(:black)
		but cTheme = "gray" or cTheme = "lightgray" or cTheme = "darkgray"
			cEdgeColor = ResolveColor(:black)
		but cTheme = "dark"
			cEdgeColor = ResolveColor("gray-")
		ok
		
		return cEdgeColor
	
	def _GetEdgeStyle()
		cEdgeStyle = "solid"

		if @oDiagram.@cEdgeStyle != "" and @oDiagram.@cEdgeStyle != NULL
			cEdgeStyle = ResolveEdgeStyle(@oDiagram.@cEdgeStyle)
		ok

		return cEdgeStyle
	
	def _GenerateNodes(cTheme)
		cOutput = ""
		
		for aNode in @oDiagram.Nodes()
			cOutput += This._GenerateNode(aNode, cTheme)
		end
		
		return cOutput
	
	def _GenerateNode(aNode, cTheme)
	    cNodeId = This._SanitizeNodeId(aNode["id"])
	    
	    # Handle helper nodes
	    if HasKey(aNode, "properties") and HasKey(aNode["properties"], "ishelper") and aNode["properties"]["ishelper"] = TRUE
	        cOutput = '    ' + cNodeId + ' [shape=point, width=0.01, height=0.01, style=invis, fixedsize=true, label=""]' + NL
	        return cOutput
	    ok
	    
	    if left(cNodeId, 8) = "_helper_"
	        cOutput = '    ' + cNodeId + ' [shape=point, width=0.01, height=0.01, style=invis, fixedsize=true, label=""]' + NL
	        return cOutput
	    ok
	    
	    cLabel = aNode["label"]
	    
	    # Get visual rule effects FIRST
	    aAppliedRules = []
	    if HasKey(@oDiagram.@aNodeRulesEffects, aNode["id"])
	        aAppliedRules = @oDiagram.@aNodeRulesEffects[aNode["id"]]
	    ok
	    
	    # Apply effects to override defaults
	    cShape = This._GetNodeShape(aNode, aAppliedRules)
	    cStyle = This._GetNodeStyle(aNode, aAppliedRules)
	    cFillColor = This._GetNodeFillColor(aNode, aAppliedRules, cTheme)
	    
	    # Check if visual rules set penwidth
	    nPenWidth = @oDiagram.@nNodePenWidth
	    if HasKey(aAppliedRules, "penwidth")
	        nPenWidth = aAppliedRules["penwidth"]
	    ok
	    
	    # Check if visual rules set style
	    if HasKey(aAppliedRules, "style")
	        cStyle = aAppliedRules["style"] + ",filled"
	    ok
	    
	    cOutput = '    ' + cNodeId + ' [label="' + cLabel + '"'
	    cOutput += ', shape=' + cShape
	    cOutput += ', style="' + cStyle + '"'
	    cOutput += ', fillcolor="' + cFillColor + '"'
	    cOutput += ', penwidth=' + nPenWidth
	    
	    # Add contrasting font color
	    cFontColor = @oDiagram.ResolveFontColor(cFillColor)
	    cOutput += ', fontcolor="' + cFontColor + '"'
	    
	    # ORG CHART POSITION NODES
	    if HasKey(aNode["properties"], "positiontype") and 
	        aNode["properties"]["positiontype"] = "position"
	        
	        cFillColor = ResolveColor(aNode["properties"]["color"])
	        cOutput += ', fillcolor="' + cFillColor + '"'
	        cOutput += ', fontcolor="' + @oDiagram.ResolveFontColor(cFillColor) + '"'
	        
	        # Use diagram's stroke color setting
	        cStrokeColor = @oDiagram.@cNodeStrokeColor
	        if cStrokeColor = '' or cStrokeColor = "invisible"
	            cStrokeColor = cFillColor
	        ok
	        cOutput += ', color="' + ResolveColor(cStrokeColor) + '"'
	    ok
	    
	    # Generate tooltip
	    cTooltip = This._GenerateTooltip(aNode)
	    if cTooltip != ""
	    	cOutput += ', tooltip="' + This._EscapeTooltip(cTooltip) + '"'
	    else
	    	# Explicitly disable default tooltip
	  	  cOutput += ', tooltip=" "'
	    ok
	    
	    cOutput += ']' + NL
	    
	    return cOutput

	def _SanitizeNodeId(cNodeId)
		if left(cNodeId, 1) = "@"
			return @substr(cNodeId, 2, stzlen(cNodeId))
		ok

		return cNodeId
	
	def _GetNodeShape(aNode, aEnhancements)
		# Check enhancements FIRST (from visual rules)
		if HasKey(aEnhancements, "shape")
			return aEnhancements["shape"]
		ok
		
		# Check node properties for explicit shape
		if HasKey(aNode, "properties") and aNode["properties"] != NULL and 
		   HasKey(aNode["properties"], "shape") and aNode["properties"]["shape"] != NULL
			return aNode["properties"]["shape"]
		ok
		
		# Get type for semantic mapping
		cType = ""
		if HasKey(aNode, "properties") and aNode["properties"] != NULL and 
		   HasKey(aNode["properties"], "type") and aNode["properties"]["type"] != NULL
			cType = lower("" + aNode["properties"]["type"])
		ok
		
		# Direct DOT shape (bypasses semantic mapping)
		if ring_find($acDotShapes, cType) > 0
			return cType
		ok
		
		# Semantic to shape mapping
		switch cType
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
	
	def _GetNodeStyle(aNode, aEnhancements)
		if HasKey(aEnhancements, "style")
			return aEnhancements["style"]
		ok
		
		# Get the actual shape that will be rendered
		cShape = This._GetNodeShape(aNode, aEnhancements)
		
		# Start with global node pen style
		cBaseStyle = @oDiagram.@cNodePenStyle
		
		# Polygon shapes don't support rounded
		
		if ring_find($aPolygonShapes, cShape) > 0
			# Add filled if not already there
			if NOT substr(cBaseStyle, "filled")
				return cBaseStyle + ",filled"
			ok
			return cBaseStyle
		ok
		
		# For box-like shapes, add rounded and filled
		if NOT substr(cBaseStyle, "filled")
			cBaseStyle += ",filled"
		ok
		if NOT substr(cBaseStyle, "rounded") and cShape = "box"
			cBaseStyle = "rounded," + cBaseStyle
		ok
		
		return cBaseStyle
	
	def _GetNodeFillColor(aNode, aEnhancements, cTheme)
	    cColor = ""
	    
	    if HasKey(aEnhancements, "color")
	        cColor = aEnhancements["color"]
	    ok
	    
	    if cColor = "" and HasKey(aNode, "properties") and 
	       HasKey(aNode["properties"], "color")
	        cColor = aNode["properties"]["color"]
	    ok
	    
	    # Use theme's primary color when no color specified
	    if cColor = ''
	        if HasKey($aPalette, cTheme)
	            cColor = $aPalette[cTheme]["primary"]
	        else
	            cColor = $cDefaultNodeColor
	        ok
	    ok
	    
	    # If already hex, return after theme transforms
	    if substr(cColor, "#")
	        if cTheme = "gray"
	            return @oDiagram.ConvertColorTogray(cColor)
	        but cTheme = "print"
	            return ResolveColor(:white)
	        ok
	        return cColor
	    ok
	    
	    # Resolve through theme palette for semantic colors
	    cLowerColor = lower(cColor)
	    if HasKey($aPalette, cTheme) and HasKey($aPalette[cTheme], cLowerColor)
	        cColor = $aPalette[cTheme][cLowerColor]
	    ok
	    
	    # Resolve to hex
	    cColor = ResolveColor(cColor)
	    
	    # Final theme transforms
	    if cTheme = "gray"
	        cColor = @oDiagram.ConvertColorTogray(cColor)
	    but cTheme = "print"
	        cColor = ResolveColor(:white)
	    ok
	    
	    return cColor
	
	def _GetNodeStrokeColor(cTheme)
		if @oDiagram.@cNodeStrokeColor != "" and @oDiagram.@cNodeStrokeColor != NULL
			return @oDiagram.@cNodeStrokeColor
		ok
		
		if cTheme = "print" or cTheme = "gray"
			return "black"
		ok
		
		return ""
	
	def _GenerateEdges(cTheme)
		cOutput = ""
		
		# Add invisible edges to force vertical layout when no real edges exist
		if len(@oDiagram.Edges()) = 0
			acNodes = @oDiagram.Nodes()
			nLen = len(acNodes)
			for i = 1 to nLen - 1
				cFrom = This._SanitizeNodeId(acNodes[i]["id"])
				cTo = This._SanitizeNodeId(acNodes[i+1]["id"])
				cOutput += '    ' + cFrom + ' -> ' + cTo + ' [style=invis]' + NL
			end
		ok
		
		for aEdge in @oDiagram.Edges()
			cOutput += This._GenerateEdge(aEdge, cTheme)
		end
		
		return cOutput

	def _GenerateEdge(aEdge, cTheme)
	    cFrom = This._SanitizeNodeId(aEdge["from"])
	    cTo = This._SanitizeNodeId(aEdge["to"])
	    cEdgeKey = aEdge["from"] + "->" + aEdge["to"]
	    
	    cOutput = '    ' + cFrom + ' -> ' + cTo
	    aAttrs = []
	    
	    # Check if this is a supervisorÃ¢â€ â€™helper edge
	    if left(cTo, 8) = "_helper_"
	        aAttrs + 'arrowhead=none'
	        aAttrs + 'weight=10'
	    ok
	    
	    # Handle edge label with spacing fix for TB layout
	    if HasKey(aEdge, "label") and aEdge["label"] != "" and aEdge["label"] != NULL
	        cLabel = aEdge["label"]
	        cRankDir = This._GetRankDir()
	        
	        # Add leading space for TB/BT layouts to prevent label collapse
	        if cRankDir = "TB" or cRankDir = "BT"
	            cLabel = " " + cLabel
	        ok
	        
	        aAttrs + ('label="' + cLabel + '"')
	    ok
	    
	    # Check edge properties
	    if HasKey(aEdge, "properties")
	        if HasKey(aEdge["properties"], "arrowhead")
	            aAttrs + ('arrowhead=' + aEdge["properties"]["arrowhead"])
	        ok
	        if HasKey(aEdge["properties"], "weight")
	            aAttrs + ('weight=' + aEdge["properties"]["weight"])
	        ok
	    ok
	    
	    # Check rule effects from parent
	    if HasKey(@oDiagram.@aEdgesAffectedByRules, cEdgeKey)
	        aAppliedRules = @oDiagram.@aEdgesAffectedByRules[cEdgeKey]
	        
	        if HasKey(aAppliedRules, "style")
	            aAttrs + ('style="' + aAppliedRules["style"] + '"')
	        ok
	        
	        if HasKey(aAppliedRules, "color")
	            cColor = ResolveColor(aAppliedRules["color"])
	            aAttrs + ('color="' + cColor + '"')
	        ok
	        
	        if HasKey(aAppliedRules, "penwidth")
	            aAttrs + ('penwidth=' + aAppliedRules["penwidth"])
	        ok
	    ok
	    
	    if len(aAttrs) > 0
	        cOutput += ' [' + This._JoinAttributes(aAttrs) + ']'
	    ok
	    
	    cOutput += NL
	    return cOutput
	
	def _GenerateTooltip(aNode)
	    aConfig = @oDiagram.@aTooltipConfig
	    
	    if len(aConfig) = 0
	        return ""  # Explicitly no tooltip
	    ok
	    
	    cTooltip = ""
	    
	    for item in aConfig
	        cKey = lower("" + item)
	        
	        if cKey = "nodeid"
	            cTooltip += "ID: " + aNode["id"] + "\n"
	            
	        but cKey = "label"
	            cTooltip += "Label: " + aNode["label"] + "\n"
	            
	        but cKey = "type"
	            if HasKey(aNode["properties"], "type")
	                cTooltip += "Type: " + aNode["properties"]["type"] + "\n"
	            ok
	            
	        but cKey = "color"
	            if HasKey(aNode["properties"], "color")
	                cTooltip += "Color: " + aNode["properties"]["color"] + "\n"
	            ok
	            
	        else
	            # Custom property
	            if HasKey(aNode["properties"], cKey)
	                cValue = aNode["properties"][cKey]
	                cTooltip += cKey + ": " + cValue + "\n"
	            ok
	        ok
	    end
	    
	    return cTooltip
	
	def _EscapeTooltip(cText)
	    cText = substr(cText, '"', '\"')
	    cText = substr(cText, "\n", "&#10;")  # HTML entity for newline
	    return cText

	def _JoinAttributes(aAttrs)
		cResult = ""
		nLen = len(aAttrs)

		for i = 1 to nLen
			cResult += aAttrs[i]
			if i < nLen
				cResult += ', '
			ok
		end

		return cResult

	def DotCode()
		return @cDotCode

		def Code()
			return @cDotCode

		def Content()
			return @cDotCode


	def WriteToFile(pFilename)
		oFile = fopen(pFilename, "w")
		fwrite(oFile, This.DotCode())
		fclose(oFile)
		return TRUE

#====================================#
#  stzDiagramToMermaid - MERMAID.JS  #
#====================================#

class stzDiagramToMermaid

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
		cOutput = "graph TD" + NL
		
		# Mermaid reserved keywords
		aReservedWords = ["end", "start", "subgraph", "graph", "style", "class", 
		                  "click", "call", "direction", "flowchart", "stateDiagram",
		                  "state", "note", "default", "loop", "alt", "par", "and"]
	
		aNodes = @oDiagram.Nodes()
		nLen = len(aNodes)
		for i = 1 to nLen
			aNode = aNodes[i]
			cNodeId = aNode["id"]
			cLabel = aNode["label"]
	
			# Escape reserved keywords
			cSafeNodeId = cNodeId
			if ring_find(aReservedWords, lower(cNodeId)) > 0
				cSafeNodeId = "node_" + cNodeId
			ok
	
			cType = aNode["properties"]["type"]
			if cType = "start"
				cOutput += '    ' + cSafeNodeId + '(["' + cLabel + '"])' + NL
	
			but cType = "endpoint"
				cOutput += '    ' + cSafeNodeId + '(["' + cLabel + '"])' + NL
	
			but cType = "decision"
				cOutput += '    ' + cSafeNodeId + '{{"' + cLabel + '"}}' + NL
	
			but cType = "process"
				cOutput += '    ' + cSafeNodeId + '["' + cLabel + '"]' + NL
	
			else
				cOutput += '    ' + cSafeNodeId + '["' + cLabel + '"]' + NL
			ok
		end
	
		cOutput += NL
	
		aEdges =  @oDiagram.Edges()
		nLen = len(aEdges)

		for i = 1 to nLen
			aEdge = aEdges[i]
			cFromId = aEdge["from"]
			cToId = aEdge["to"]
			
			# Escape reserved keywords in edges
			if ring_find(aReservedWords, lower(cFromId)) > 0
				cFromId = "node_" + cFromId
			ok
			if ring_find(aReservedWords, lower(cToId)) > 0
				cToId = "node_" + cToId
			ok
			
			if aEdge["label"] != "" and aEdge["label"] != NULL
				cOutput += '    ' + cFromId + ' -->|' + aEdge["label"] + '| ' + cToId + NL
			else
				cOutput += '    ' + cFromId + ' --> ' + cToId + NL
			ok
		end
	
		@cMermaidCode = cOutput
	
	def Code()
		return @cMermaidCode

		def MermaidCode()
			return @cMermaidCode

		def Content()
			return @cMermaidCode

	def WriteToFile(pFilename)
		oFile = fopen(pFilename, "w")
		fwrite(oFile, This.Code())
		fclose(oFile)
		return TRUE

#==================================#
#  stzDiagramToJSON - JSON FORMAT  #
#==================================#

class stzDiagramToJSON

	@oDiagram
	@cJsonCode

	def init(poDiagram)
		if NOT ( isObject(poDiagram) and ring_classname(poDiagram) = "stzdiagram" )
			StzRaise("Incorrect param type! poDiagram must be a stzDiagram object.")
		ok
		@oDiagram = poDiagram
		This._Generate()

	def _Generate()
		aData = @oDiagram.ToHashlist()
		@cJsonCode = ToJSONXT(aData)

	def Json()
		return @cJsonCode

		def JsonCode()
			return @cJsonCode

		def Code()
			return @cJsonCode

		def Content()
			return @cJsonCode

	def WriteToFile(pFilename)
		oFile = fopen(pFilename, "w")
		fwrite(oFile, This.JsonCode())
		fclose(oFile)
		return TRUE

#========================#
#  COLOR RESOLVER CLASS  #
#========================#

class stzColorResolver

	def init()

	def ResolveFontColor(pBgColor)
		# Get actual resolved background color
		cBgColor = ResolveColor(pBgColor)
		
		# Always use luminance calculation for consistent contrast
		return This.ContrastingTextColor(cBgColor)
	
	def ContrastingTextColor(cColor)
		# Convert color to RGB
		aRGB = This.ColorToRGB(cColor)
		nR = aRGB[1]
		nG = aRGB[2]
		nB = aRGB[3]
		
		# Simple perceptual brightness formula (ITU BT.709)
		nBrightness = (0.299 * nR + 0.587 * nG + 0.114 * nB)
		
		# Threshold at 150 for better contrast
		if nBrightness < 150
			return "white"
		else
			return "black"
		ok
	
	def ColorToRGB(cColor)
		# First resolve to hex, then convert
		cHex = ResolveColor(cColor)
		return HexToRGB(cHex)

	def NodeStrokeColorForTheme(cTheme)
		if cTheme = "print" or cTheme = "gray"
			return "black"
		ok
		return ""

	def ConvertColorToGray(cColor)
		aRGB = This.ColorToRGB(cColor)
		nR = aRGB[1]
		nG = aRGB[2]
		nB = aRGB[3]
		
		# Use perceptual brightness formula
		nGray = floor(0.299 * nR + 0.587 * nG + 0.114 * nB)
		
		# Use global helper
		return RGBToHex(nGray, nGray, nGray)

	def ResolveWithPalette(pcColor, pacPalette)

		if isString(pcColor) and substr(pcColor, "#")
			return pcColor
		ok
		
		cColorKey = lower("" + pcColor)
		
		# Extract intensity modifier (++, +, --, -)
		cIntensity = ""
		cBaseKey = cColorKey
		
		if right(cColorKey, 2) = "++" or right(cColorKey, 2) = "--"
			cIntensity = right(cColorKey, 2)
			cBaseKey = left(cColorKey, stzlen(cColorKey) - 2)
	
		but right(cColorKey, 1) = "+" or right(cColorKey, 1) = "-"
			cIntensity = right(cColorKey, 1)
			cBaseKey = left(cColorKey, stzlen(cColorKey) - 1)
		ok
		
		# Try direct palette lookup
		if HasKey(pacPalette, cColorKey)
			return pacPalette[cColorKey]
		ok
		
		# Try semantic meaning
		if HasKey($acColorsBySemanticMeaning, cBaseKey)
			cBaseColor = "" + $acColorsBySemanticMeaning[cBaseKey]
			return ResolveColor(cBaseColor + cIntensity)
		ok
		
		# Try node type
		if HasKey($acColorsByNodeType, cBaseKey)
			cBaseColor = "" + $acColorsByNodeType[cBaseKey]
			return ResolveColor(cBaseColor + cIntensity)
		ok
		
		# Legacy map #TODO Shoud it be global?
		aLegacyMap = [
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
		
		if HasKey(aLegacyMap, cColorKey)
			return ResolveColor(aLegacyMap[cColorKey])
		ok
		
		return pacPalette[:blue]

#============================================#
#  stzStylParser - *.stzstyl Format Parser   #
#  Visual theme and styling definitions      #
#============================================#

class stzStylParser
	
	def init()

	def ParseFile(pcFilename)
		cContent = read(pcFilename)
		return This.Parse(cContent)
	
	def Parse(pcContent)
		aStyle = [
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
		
		acLines = split(pcContent, NL)
		cSection = ""
		
		for cLine in acLines
			cLine = trim(cLine)
			
			if cLine = "" or left(cLine, 1) = "#"
				loop
			ok
			
			# Style header
			if substr(cLine, "style ")
				aStyle[:name] = This._ExtractQuoted(cLine)
				
			but substr(cLine, "theme:")
				aStyle[:theme] = This._ExtractValue(cLine)
				
			but substr(cLine, "layout:")
				aStyle[:layout] = This._ExtractValue(cLine)
			
			# Sections
			but cLine = "colors"
				cSection = "colors"
				
			but cLine = "fonts"
				cSection = "fonts"
				
			but cLine = "edges"
				cSection = "edges"
				
			but cLine = "nodes"
				cSection = "nodes"
				
			but cLine = "focus"
				cSection = "focus"
				
			but cLine = "custom"
				cSection = "custom"
			
			# Parse section content
			but cSection != "" and substr(cLine, ":")
				aParts = split(cLine, ":")
				cKey = trim(aParts[1])
				cValue = trim(aParts[2])
				
				aStyle[cSection] + [cKey, This._ParseValue(cValue)]
			ok
		end
		

		return aStyle
	
	def _ParseValue(cValue)
		# Try number
		if isdigit(cValue)
			return 0 + cValue
		ok
		
		# Remove quotes
		if left(cValue, 1) = '"' and right(cValue, 1) = '"'
			return @substr(cValue, 2, len(cValue) - 1)
		ok
		
		return cValue
	
	def _ExtractValue(cLine)
		nPos = substr(cLine, ":")
		if nPos = 0 return "" ok
		cValue = trim(@substr(cLine, nPos + 1, len(cLine)))
		return This._ParseValue(cValue)
	
	def _ExtractQuoted(cLine)
		nStart = substr(cLine, '"')
		if nStart = 0 return "" ok
		nEnd = @substr(cLine, nStart + 1, len(cLine))
		nEnd = substr(nEnd, '"')
		return @substr(cLine, nStart + 1, nStart + nEnd - 1)
