#=====================================================
#  stzDiagram - DOMAIN SPECIALIZATION OF stzGraph
#  Workflows, org charts, semantic diagrams
#=====================================================

#  GLOBAL REGISTRY
#==================

$aDiagramValidators = [
	:SOX,
	:GDPR,
	:Banking
]

# ============================================
#  UNIFIED COLOR SYSTEM
# ============================================

# Base color definitions (single source of truth)
$acColors = [
	# Grayscale
	:white = "#FFFFFF",
	:black = "#000000",
	:gray = "#808080",
	
	# Primary colors
	:red = "#FF0000",
	:green = "#008000",
	:blue = "#0000FF",
	:yellow = "#FFFF00",
	:orange = "#FFA500",
	:purple = "#800080",
	:cyan = "#00FFFF",
	:magenta = "#FF00FF",
	
	# Extended palette
	:brown = "#A52A2A",
	:pink = "#FFC0CB",
	:navy = "#000080",
	:teal = "#008080",
	:olive = "#808000",
	:maroon = "#800000",
	:lime = "#00FF00",
	:aqua = "#00FFFF",
	:silver = "#C0C0C0",
	:gold = "#FFD700",
	:coral = "#FF7F50",
	:salmon = "#FA8072",
	:lavender = "#E6E6FA",
	:steelblue = "#4682B4"
]

# Semantic color meanings (abstraction layer)
$acColorsBySemanticMeaning = [
	:Success = "green",
	:Warning = "yellow",
	:Danger = "red",
	:Info = "blue",
	:Primary = "blue",
	:Neutral = "gray"
]

# Node type color mappings
$acColorsByNodeType = [
	:Start = "green",
	:Process = "blue",
	:Decision = "yellow",
	:Endpoint = "coral",
	:State = "cyan",
	:Storage = "gray",
	:Data = "lavender",
	:Event = "pink",
	:Gateway = "yellow",
	:Subprocess = "steelblue",
	:Timer = "salmon",
	:Error = "coral",
	:Compensation = "gold"
]

# Global node type definitions
$acNodeTypes = [
	:Start,
	:Process,
	:Decision,
	:Endpoint,
	:State,
	:Storage,
	:Data,
	:Event,
	:Gateway,
	:Subprocess,
	:Timer,
	:Error,
	:Compensation
]

# Default node type and color
$cDefaultNodeType = "process"
$cDefaultNodeColor = :white

# Edge styles
$acEdgeStyles = [
	:Normal = "solid",
	:Conditional = "dashed",
	:ErrorFlow = "dotted",
	:MessageFlow = "bold"
]

$cDefaultEdgeStyle = "normal"
$cDefaultEdgeColor = "black"

#---

# Global color palette - lazy initialization
$acFullColorPalette = []

# Initialize theme palettes after ResolveColor is defined
$aPalette = [
	:light = [
		:primary = "blue+",
		:success = "green+",
		:warning = "yellow+",
		:danger = "coral",
		:info = "cyan+",
		:neutral = "gray+",
		:background = "white"
	],
	:dark = [
		:primary = "blue--",
		:success = "green",
		:warning = "orange",
		:danger = "red",
		:info = "blue",
		:neutral = "gray-",
		:background = "gray++"
	],
	:vibrant = [
		:primary = "blue",
		:success = "green",
		:warning = "orange",
		:danger = "red",
		:info = "blue",
		:neutral = "gray--",
		:background = "white"
	],
	:pro = [
		:primary = "blue+",
		:success = "green-",
		:warning = "orange-",
		:danger = "red-",
		:info = "blue",
		:neutral = "gray",
		:background = "white"
	],
	:access = [
		:primary = "blue",
		:success = "green-",
		:warning = "yellow+",
		:danger = "red-",
		:info = "blue",
		:neutral = "gray-",
		:background = "#FFFEF7"
	],
	:print = [
		:primary = "white",
		:success = "white",
		:warning = "white",
		:danger = "white",
		:info = "white",
		:neutral = "white",
		:background = "white"
	],
	:lightgray = [
		:primary = "gray++",
		:success = "gray+",
		:warning = "gray++",
		:danger = "gray+",
		:info = "gray++",
		:neutral = "gray+",
		:background = "#F9F9F9"
	],
	:gray = [
		:primary = "gray+",
		:success = "gray",
		:warning = "gray+",
		:danger = "gray-",
		:info = "gray",
		:neutral = "gray",
		:background = "white"
	],
	:darkgray = [
		:primary = "gray-",
		:success = "gray-",
		:warning = "gray-",
		:danger = "gray--",
		:info = "gray-",
		:neutral = "gray--",
		:background = "gray--"
	]
]

# THEMES

$acThemes = [
	"light",
	"dark",
	"vibrant",
	"pro",
	"access",
	"print",
	"gray",
	"lightgray",
	"darkgray"
]

$cDefaultTheme = "light"

# LAYOUT
$acLayouts = [
	:TopDown = [ "tb", "td", "topbottom", "ud", "updown", "ub", "upbottom" ],
	:BottomUp = [ "bt", "dt", "bottomtop", "du", "downup", "bu", "bottomup" ],
	:LeftRight = [ "lr" ],
	:RightLeft = [ "rl" ]
]

$cDefaultLayout = "topdown"

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

$aFontColors = [
	:light = [
		:primary = "black",
		:success = "black",
		:warning = "black",
		:danger = "black",
		:info = "black",
		:neutral = "black"
	],
	:dark = [
		:primary = "white",
		:success = "white",
		:warning = "black",
		:danger = "white",
		:info = "white",
		:neutral = "white"
	],
	:vibrant = [
		:primary = "white",
		:success = "white",
		:warning = "black",
		:danger = "white",
		:info = "white",
		:neutral = "white"
	],
	:pro = [
		:primary = "black",
		:success = "white",
		:warning = "black",
		:danger = "white",
		:info = "white",
		:neutral = "white"
	]
]

#------------------
#  VISUAL MAPPINGS
#------------------

# Shape modifiers for metadata attributes
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

# Color gradients for numeric metadata (0-100 scale)
$aMetricColorGradients = [
	:performance = [
		[0, 50] = "#FF4444",
		[51, 75] = "#FFA500",
		[76, 100] = "#44FF44"
	],
	:risk = [
		[0, 33] = "#44FF44",
		[34, 66] = "#FFA500",
		[67, 100] = "#FF4444"
	],
	:priority = [
		[0, 33] = "#CCCCCC",
		[34, 66] = "#4488FF",
		[67, 100] = "#FF4444"
	]
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

# ============================================
#  COLOR INTENSITY GENERATION & RESOLUTION
# ============================================

# Generate color intensities: color--, color-, color, color+, color++
func GenerateColorIntensities(cColorName, cHexValue)
	aIntensities = []
	
	aRGB = HexToRGB(cHexValue)
	nR = aRGB[1]
	nG = aRGB[2]
	nB = aRGB[3]
	
	nLum = 0.299 * nR + 0.587 * nG + 0.114 * nB
	
	if nLum < 128  # Dark color
		# Base is original
		aIntensities[cColorName] = cHexValue
		
		# - : lighter (add ~64% white)
		aIntensities[cColorName + "-"] = RGBToHex(
			min([255, nR + floor((255 - nR) * 0.64)]),
			min([255, nG + floor((255 - nG) * 0.64)]),
			min([255, nB + floor((255 - nB) * 0.64)])
		)
		
		# -- : much lighter (add ~88% white)
		aIntensities[cColorName + "--"] = RGBToHex(
			min([255, nR + floor((255 - nR) * 0.88)]),
			min([255, nG + floor((255 - nG) * 0.88)]),
			min([255, nB + floor((255 - nB) * 0.88)])
		)
		
		# + : darker - for pure colors add 77 to zero channels, scale primary to 79%
		nRedPlus = floor(nR * 0.79)
		nGreenPlus = floor(nG * 0.79)
		nBluePlus = floor(nB * 0.79)
		
		if nR = 0 and (nG > 0 or nB > 0)
			nRedPlus = 77
		ok
		if nG = 0 and (nR > 0 or nB > 0)
			nGreenPlus = 77
		ok
		if nB = 0 and (nR > 0 or nG > 0)
			nBluePlus = 77
		ok
		
		aIntensities[cColorName + "+"] = RGBToHex(
			max([0, nRedPlus]),
			max([0, nGreenPlus]),
			max([0, nBluePlus])
		)
		
		# ++ : much darker (scale to 40%)
		aIntensities[cColorName + "++"] = RGBToHex(
			max([0, floor(nR * 0.4)]),
			max([0, floor(nG * 0.4)]),
			max([0, floor(nB * 0.4)])
		)
		
	else  # Light color
		# Base is original
		aIntensities[cColorName] = cHexValue
		
		# - : lighter (64% to white)
		aIntensities[cColorName + "-"] = RGBToHex(
			min([255, nR + floor((255 - nR) * 0.64)]),
			min([255, nG + floor((255 - nG) * 0.64)]),
			min([255, nB + floor((255 - nB) * 0.64)])
		)
		
		# -- : much lighter (88% to white)
		aIntensities[cColorName + "--"] = RGBToHex(
			min([255, nR + floor((255 - nR) * 0.88)]),
			min([255, nG + floor((255 - nG) * 0.88)]),
			min([255, nB + floor((255 - nB) * 0.88)])
		)
		
		# + : darker (20% of original)
		aIntensities[cColorName + "+"] = RGBToHex(
			max([0, floor(nR * 0.2)]),
			max([0, floor(nG * 0.2)]),
			max([0, floor(nB * 0.2)])
		)
		
		# ++ : much darker (5% of original)
		aIntensities[cColorName + "++"] = RGBToHex(
			max([0, floor(nR * 0.05)]),
			max([0, floor(nG * 0.05)]),
			max([0, floor(nB * 0.05)])
		)
	ok
	
	return aIntensities

# Build complete color palette with all intensities
func BuildColorPalette()
	aPalette = []
	acKeys = keys($acColors)
	nLen = len(acKeys)

	# Add base colors

	for i = 1 to nLen
		cHex = $acColors[acKeys[i]]
		aPalette[acKeys[i]] = cHex
	end
	
	# Add all intensity variations

	for i = 1 to nLen
		cHex = $acColors[acKeys[i]]
		cColorName = "" + acKeys[i]
		aIntensities = GenerateColorIntensities(cColorName, cHex)
		acKeysInt = keys(aIntensities)
		nLenInt = len(acKeysInt)

		for j = 1 to nLenInt
			aPalette[acKeysInt[j]] = aIntensities[acKeysInt[j]]
		end
	end
	
	return aPalette


# Global color resolution function
func ResolveColor(pColor)
	if len($acFullColorPalette) = 0
		$acFullColorPalette = BuildColorPalette()
	ok
	
	if isString(pColor) and substr(pColor, "#")
		return pColor
	ok
	
	cColorKey = lower("" + pColor)
	
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
	if HasKey($acFullColorPalette, cColorKey)
		return $acFullColorPalette[cColorKey]
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
	
	# Legacy map
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
	
	return $acFullColorPalette[:blue]

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
	
	# Fallback mapping
	aVisualMap = [
		:box = :process,
		:diamond = :decision,
		:ellipse = :start,
		:circle = :state,
		:cylinder = :storage,
		:doublecircle = :endpoint
	]
	
	if HasKey(aVisualMap, cTypeKey)
		return aVisualMap[cTypeKey]
	ok

	# Map unsupported to supported shapes
	aShapeMap = [
		:square = :box,
		:rect = :box,
		:egg = :ellipse,
		:tab = :box,
		:folder = :box,
		:component = :box,
		:note = :box,
		:ellpise = :ellipse  # typo fix
	]
	
	if HasKey(aShapeMap, cTypeKey)
		return aShapeMap[cTypeKey]
	ok
	
	return $cDefaultNodeType

# Helper: Hex to RGB
func HexToRGB(cHex)
	# Remove # if present
	if substr(cHex, "#")
		cHex = @substr(cHex, 2, len(cHex))
	ok
	
	if len(cHex) != 6
		return [128, 128, 128] # Gray fallback
	ok
	
	cR = @substr(cHex, 1, 2)
	cG = @substr(cHex, 3, 4)
	cB = @substr(cHex, 5, 6)
	
	nR = HexToDec(cR)
	nG = HexToDec(cG)
	nB = HexToDec(cB)
	
	return [nR, nG, nB]

# Helper: RGB to Hex
func RGBToHex(nR, nG, nB)
	# Clamp values to 0-255
	nR = max([ 0, min([ 255, nR ]) ])
	nG = max([ 0, min([ 255, nG ]) ])
	nB = max([ 0, min([ 255, nB ]) ])
	
	cR = DecToHex(nR)
	cG = DecToHex(nG)
	cB = DecToHex(nB)
	
	# Pad to 2 digits
	if len(cR) = 1 cR = "0" + cR ok
	if len(cG) = 1 cG = "0" + cG ok
	if len(cB) = 1 cB = "0" + cB ok
	
	return "#" + upper(cR) + upper(cG) + upper(cB)


func Palette()
	return $aPalette

func FontColors()
	return $aFontColors

# NODE TYPE FUNCTIONS

func DefaultNodeType()
	return $cDefaultNodeType

func NodeTypes()
	return $acNodeTypes

func IsValidNodeType(pcType)
	return ring_find($acNodeTypes, pcType) > 0

func DefaultNodeColor()
	return ResolveColor($cDefaultNodeColor)

func ColorForNodeType(pcType)
	if HasKey($acColorsByNodeType, pcType)
		return ResolveColor($acColorsByNodeType[pcType])
	ok
	return ResolveColor($cDefaultNodeColor)

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

# VALIDATOR FUNCTION

func DiagramValidators()
	return $acDiagramValidators

# =====================================================
#  stzDiagram Class - Main Diagram Implementation
# =====================================================

class stzDiagram from stzGraph

	@cTheme = $cDefaultTheme
	@cLayout = $cDefaultLayout
	@aClusters = []
	@aoAnnotations = []
	@aoTemplates = []

	@cEdgeColor = ""
	@cNodeStrokeColor = ""

	@aPalette = $aPalette
	@aFontColors = $aFontColors

	@cEdgeStyle = $cDefaultEdgeStyle

	@cFont = $cDefaultFont
	@nFontSize = $cDefaultFontSize

	@aoVisualRules = []
	@aMetadataKeys = []

	@aNodeEnhancements = []
	@aEdgeEnhancements = []

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


	def init(pTitle)
		super.init(pTitle)
		@cEdgeColor = ResolveColor($cDefaultEdgeColor)

	def SetTheme(pTheme)
	
		cThemeKey = lower(pTheme)
		
		if HasKey($aPalette, cThemeKey)
			@cTheme = cThemeKey
			
			if HasKey($aThemeFonts, cThemeKey)
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

	def SetNodeStrokeColor(pColor)
		@cNodeStrokeColor = ResolveColor(pColor)

	def SetFont(pFont)
		@cFont = lower(pFont)
	
	def SetFontSize(pSize)
		@nFontSize = pSize
	

	def SetPenWidth(pnWidth)
		@nNodePenWidth = pnWidth

	# Setters
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

	def VisualRules()
		return @aoVisualRules
	
	def NodeEnhancements()
		return @aNodeEnhancements
	
	def EdgeEnhancements()
		return @aEdgeEnhancements

	#------------------------------------------
	#  COLOR RESOLUTION
	#------------------------------------------

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

	#-------------------------------------
	#  ADDING SPECIFIC FORMS OF NODES (ALL SUPPORTED FORMS IN GRAPHVIZ DOT LANGAUGE)
	#--------------------------------------

	#NOTE // We can add nodes using paren stzGraph methods AddNode(), AddNodeXT() and AddNodeXTT()

	# Rounded/Elliptical Shapes
	def AddCircle(pcId, pcLabel)
		This.AddNodeXTT(pcId, pcLabel, [:type = :circle, :color = :white])
	
	def AddCircleXT(pcId, pcLabel, pcColor)
		This.AddNodeXTT(pcId, pcLabel, [:type = :circle, :color = pcColor])
	
	def AddCircleXTT(pcId, pcLabel, paProps)
		if NOT HasKey(paProps, :type) paProps[:type] = :circle ok
		This.AddNodeXTT(pcId, pcLabel, paProps)
	
	def AddDoubleCircle(pcId, pcLabel)
		This.AddNodeXTT(pcId, pcLabel, [:type = :doublecircle, :color = :white])
	
	def AddDoubleCircleXT(pcId, pcLabel, pcColor)
		This.AddNodeXTT(pcId, pcLabel, [:type = :doublecircle, :color = pcColor])
	
	def AddDoubleCircleXTT(pcId, pcLabel, paProps)
		if NOT HasKey(paProps, :type) paProps[:type] = :doublecircle ok
		This.AddNodeXTT(pcId, pcLabel, paProps)
	
	def AddEllipse(pcId, pcLabel)
		This.AddNodeXTT(pcId, pcLabel, [:type = :ellipse, :color = :white])
	
	def AddEllipseXT(pcId, pcLabel, pcColor)
		This.AddNodeXTT(pcId, pcLabel, [:type = :ellipse, :color = pcColor])
	
	def AddEllipseXTT(pcId, pcLabel, paProps)
		if NOT HasKey(paProps, :type) paProps[:type] = :ellipse ok
		This.AddNodeXTT(pcId, pcLabel, paProps)
	
	def AddEgg(pcId, pcLabel)
		This.AddNodeXTT(pcId, pcLabel, [:type = :egg, :color = :white])
	
	def AddEggXT(pcId, pcLabel, pcColor)
		This.AddNodeXTT(pcId, pcLabel, [:type = :egg, :color = pcColor])
	
	def AddEggXTT(pcId, pcLabel, paProps)
		if NOT HasKey(paProps, :type) paProps[:type] = :egg ok
		This.AddNodeXTT(pcId, pcLabel, paProps)
	
	# Quadrilateral Shapes
	def AddSquare(pcId, pcLabel)
		This.AddNodeXTT(pcId, pcLabel, [:type = :square, :color = :white])
	
	def AddSquareXT(pcId, pcLabel, pcColor)
		This.AddNodeXTT(pcId, pcLabel, [:type = :square, :color = pcColor])
	
	def AddSquareXTT(pcId, pcLabel, paProps)
		if NOT HasKey(paProps, :type) paProps[:type] = :square ok
		This.AddNodeXTT(pcId, pcLabel, paProps)
	
	def AddRect(pcId, pcLabel)
		This.AddNodeXTT(pcId, pcLabel, [:type = :rect, :color = :white])
	
	def AddRectXT(pcId, pcLabel, pcColor)
		This.AddNodeXTT(pcId, pcLabel, [:type = :rect, :color = pcColor])
	
	def AddRectXTT(pcId, pcLabel, paProps)
		if NOT HasKey(paProps, :type) paProps[:type] = :rect ok
		This.AddNodeXTT(pcId, pcLabel, paProps)
	
	def AddBox(pcId, pcLabel)
		This.AddNodeXTT(pcId, pcLabel, [:type = :box, :color = :white])
	
	def AddBoxXT(pcId, pcLabel, pcColor)
		This.AddNodeXTT(pcId, pcLabel, [:type = :box, :color = pcColor])
	
	def AddBoxXTT(pcId, pcLabel, paProps)
		if NOT HasKey(paProps, :type) paProps[:type] = :box ok
		This.AddNodeXTT(pcId, pcLabel, paProps)
	
	def AddParallelogram(pcId, pcLabel)
		This.AddNodeXTT(pcId, pcLabel, [:type = :parallelogram, :color = :white])
	
	def AddParallelogramXT(pcId, pcLabel, pcColor)
		This.AddNodeXTT(pcId, pcLabel, [:type = :parallelogram, :color = pcColor])
	
	def AddParallelogramXTT(pcId, pcLabel, paProps)
		if NOT HasKey(paProps, :type) paProps[:type] = :parallelogram ok
		This.AddNodeXTT(pcId, pcLabel, paProps)
	
	def AddTrapezium(pcId, pcLabel)
		This.AddNodeXTT(pcId, pcLabel, [:type = :trapezium, :color = :white])
	
	def AddTrapeziumXT(pcId, pcLabel, pcColor)
		This.AddNodeXTT(pcId, pcLabel, [:type = :trapezium, :color = pcColor])
	
	def AddTrapeziumXTT(pcId, pcLabel, paProps)
		if NOT HasKey(paProps, :type) paProps[:type] = :trapezium ok
		This.AddNodeXTT(pcId, pcLabel, paProps)
	
	def AddInvTrapezium(pcId, pcLabel)
		This.AddNodeXTT(pcId, pcLabel, [:type = :invtrapezium, :color = :white])
	
	def AddInvTrapeziumXT(pcId, pcLabel, pcColor)
		This.AddNodeXTT(pcId, pcLabel, [:type = :invtrapezium, :color = pcColor])
	
	def AddInvTrapeziumXTT(pcId, pcLabel, paProps)
		if NOT HasKey(paProps, :type) paProps[:type] = :invtrapezium ok
		This.AddNodeXTT(pcId, pcLabel, paProps)
	
	def AddDiamond(pcId, pcLabel)
		This.AddNodeXTT(pcId, pcLabel, [:type = :diamond, :color = :white])
	
	def AddDiamondXT(pcId, pcLabel, pcColor)
		This.AddNodeXTT(pcId, pcLabel, [:type = :diamond, :color = pcColor])
	
	def AddDiamondXTT(pcId, pcLabel, paProps)
		if NOT HasKey(paProps, :type) paProps[:type] = :diamond ok
		This.AddNodeXTT(pcId, pcLabel, paProps)
	
	# Polygon Shapes
	def AddTriangle(pcId, pcLabel)
		This.AddNodeXTT(pcId, pcLabel, [:type = :triangle, :color = :white])
	
	def AddTriangleXT(pcId, pcLabel, pcColor)
		This.AddNodeXTT(pcId, pcLabel, [:type = :triangle, :color = pcColor])
	
	def AddTriangleXTT(pcId, pcLabel, paProps)
		if NOT HasKey(paProps, :type) paProps[:type] = :triangle ok
		This.AddNodeXTT(pcId, pcLabel, paProps)
	
	def AddInvTriangle(pcId, pcLabel)
		This.AddNodeXTT(pcId, pcLabel, [:type = :invtriangle, :color = :white])
	
	def AddInvTriangleXT(pcId, pcLabel, pcColor)
		This.AddNodeXTT(pcId, pcLabel, [:type = :invtriangle, :color = pcColor])
	
	def AddInvTriangleXTT(pcId, pcLabel, paProps)
		if NOT HasKey(paProps, :type) paProps[:type] = :invtriangle ok
		This.AddNodeXTT(pcId, pcLabel, paProps)
	
	def AddPentagon(pcId, pcLabel)
		This.AddNodeXTT(pcId, pcLabel, [:type = :pentagon, :color = :white])
	
	def AddPentagonXT(pcId, pcLabel, pcColor)
		This.AddNodeXTT(pcId, pcLabel, [:type = :pentagon, :color = pcColor])
	
	def AddPentagonXTT(pcId, pcLabel, paProps)
		if NOT HasKey(paProps, :type) paProps[:type] = :pentagon ok
		This.AddNodeXTT(pcId, pcLabel, paProps)
	
	def AddHexagon(pcId, pcLabel)
		This.AddNodeXTT(pcId, pcLabel, [:type = :hexagon, :color = :white])
	
	def AddHexagonXT(pcId, pcLabel, pcColor)
		This.AddNodeXTT(pcId, pcLabel, [:type = :hexagon, :color = pcColor])
	
	def AddHexagonXTT(pcId, pcLabel, paProps)
		if NOT HasKey(paProps, :type) paProps[:type] = :hexagon ok
		This.AddNodeXTT(pcId, pcLabel, paProps)
	
	def AddSeptagon(pcId, pcLabel)
		This.AddNodeXTT(pcId, pcLabel, [:type = :septagon, :color = :white])
	
	def AddSeptagonXT(pcId, pcLabel, pcColor)
		This.AddNodeXTT(pcId, pcLabel, [:type = :septagon, :color = pcColor])
	
	def AddSeptagonXTT(pcId, pcLabel, paProps)
		if NOT HasKey(paProps, :type) paProps[:type] = :septagon ok
		This.AddNodeXTT(pcId, pcLabel, paProps)
	
	def AddOctagon(pcId, pcLabel)
		This.AddNodeXTT(pcId, pcLabel, [:type = :octagon, :color = :white])
	
	def AddOctagonXT(pcId, pcLabel, pcColor)
		This.AddNodeXTT(pcId, pcLabel, [:type = :octagon, :color = pcColor])
	
	def AddOctagonXTT(pcId, pcLabel, paProps)
		if NOT HasKey(paProps, :type) paProps[:type] = :octagon ok
		This.AddNodeXTT(pcId, pcLabel, paProps)
	
	def AddTripleOctagon(pcId, pcLabel)
		This.AddNodeXTT(pcId, pcLabel, [:type = :tripleoctagon, :color = :white])
	
	def AddTripleOctagonXT(pcId, pcLabel, pcColor)
		This.AddNodeXTT(pcId, pcLabel, [:type = :tripleoctagon, :color = pcColor])
	
	def AddTripleOctagonXTT(pcId, pcLabel, paProps)
		if NOT HasKey(paProps, :type) paProps[:type] = :tripleoctagon ok
		This.AddNodeXTT(pcId, pcLabel, paProps)
	
	# Non-geometric/Conceptual Shapes
	def AddCylinder(pcId, pcLabel)
		This.AddNodeXTT(pcId, pcLabel, [:type = :cylinder, :color = :white])
	
	def AddCylinderXT(pcId, pcLabel, pcColor)
		This.AddNodeXTT(pcId, pcLabel, [:type = :cylinder, :color = pcColor])
	
	def AddCylinderXTT(pcId, pcLabel, paProps)
		if NOT HasKey(paProps, :type) paProps[:type] = :cylinder ok
		This.AddNodeXTT(pcId, pcLabel, paProps)
	
	def AddHouse(pcId, pcLabel)
		This.AddNodeXTT(pcId, pcLabel, [:type = :house, :color = :white])
	
	def AddHouseXT(pcId, pcLabel, pcColor)
		This.AddNodeXTT(pcId, pcLabel, [:type = :house, :color = pcColor])
	
	def AddHouseXTT(pcId, pcLabel, paProps)
		if NOT HasKey(paProps, :type) paProps[:type] = :house ok
		This.AddNodeXTT(pcId, pcLabel, paProps)
	
	def AddTab(pcId, pcLabel)
		This.AddNodeXTT(pcId, pcLabel, [:type = :tab, :color = :white])
	
	def AddTabXT(pcId, pcLabel, pcColor)
		This.AddNodeXTT(pcId, pcLabel, [:type = :tab, :color = pcColor])
	
	def AddTabXTT(pcId, pcLabel, paProps)
		if NOT HasKey(paProps, :type) paProps[:type] = :tab ok
		This.AddNodeXTT(pcId, pcLabel, paProps)
	
	def AddFolder(pcId, pcLabel)
		This.AddNodeXTT(pcId, pcLabel, [:type = :folder, :color = :white])
	
	def AddFolderXT(pcId, pcLabel, pcColor)
		This.AddNodeXTT(pcId, pcLabel, [:type = :folder, :color = pcColor])
	
	def AddFolderXTT(pcId, pcLabel, paProps)
		if NOT HasKey(paProps, :type) paProps[:type] = :folder ok
		This.AddNodeXTT(pcId, pcLabel, paProps)
	
	def AddComponent(pcId, pcLabel)
		This.AddNodeXTT(pcId, pcLabel, [:type = :component, :color = :white])
	
	def AddComponentXT(pcId, pcLabel, pcColor)
		This.AddNodeXTT(pcId, pcLabel, [:type = :component, :color = pcColor])
	
	def AddComponentXTT(pcId, pcLabel, paProps)
		if NOT HasKey(paProps, :type) paProps[:type] = :component ok
		This.AddNodeXTT(pcId, pcLabel, paProps)
	
	def AddNote(pcId, pcLabel)
		This.AddNodeXTT(pcId, pcLabel, [:type = :note, :color = :yellow])
	
	def AddNoteXT(pcId, pcLabel, pcColor)
		This.AddNodeXTT(pcId, pcLabel, [:type = :note, :color = pcColor])
	
	def AddNoteXTT(pcId, pcLabel, paProps)
		if NOT HasKey(paProps, :type) paProps[:type] = :note ok
		This.AddNodeXTT(pcId, pcLabel, paProps)

	#------------------------------------------
	#  CLUSTER OPERATIONS
	#------------------------------------------

	def AddCluster(pClusterId, pLabel, aNodeIds, pColor)
		oCluster = [
			:id = pClusterId,
			:label = pLabel,
			:nodes = aNodeIds,
			:color = ResolveColor(pColor)
		]
		@aClusters + oCluster

	def Clusters()
		return @aClusters

	#------------------------------------------
	#  ANNOTATION OPERATIONS
	#------------------------------------------

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

	#------------------------------------------
	#  TEMPLATE OPERATIONS
	#------------------------------------------

	def AddTemplate(oTemplate)
		@aoTemplates + oTemplate

	def ApplyTemplates()
		nLen = len(@aoTemplates)
		for i = 1 to nLen
			@aoTemplates[i].Apply(This)
		end

	#------------------------------------------
	#  VALIDATION
	#------------------------------------------

	def Validate(pcValidator)
		@cLastValidator = lower(pcValidator)
		
		switch @cLastValidator
		on "sox"
			oValidator = new stzDiagramSoxValidator()
			oValidator.Validate(This)
			@aLastValidationResult = oValidator.Result()
			
		on "gdpr"
			oValidator = new stzDiagramGdprValidator()
			oValidator.Validate(This)
			@aLastValidationResult = oValidator.Result()
			
		on "banking"
			oValidator = new stzDiagramBankingValidator()
			oValidator.Validate(This)
			@aLastValidationResult = oValidator.Result()
			
		on "dag"
			@aLastValidationResult = This._ValidateDAG()
			
		on "reachability"
			@aLastValidationResult = This._ValidateReachability()
			
		on "completeness"
			@aLastValidationResult = This._ValidateCompleteness()
			
		other
			stzraise("Unsupported validator: " + pcValidator)
		off
		
		return This.IsValid(@cLastValidator)
	
	def IsValid(pcValidator)
		if pcValidator != NULL and pcValidator != ""
			if lower(pcValidator) != @cLastValidator
				This.Validate(pcValidator)
			ok
		ok
		return This.ValidationStatus() = "pass"

	def _ValidateDAG()
		bIsDAG = NOT This.CyclicDependencies()
		return [
			:status = iif(bIsDAG, "pass", "fail"),
			:domain = "dag",
			:issueCount = iif(bIsDAG, 0, 1),
			:issues = iif(bIsDAG, [], ["Graph contains cycles"])
		]
	
	def _ValidateReachability()
		acStartNodes = This.NodesByType("start")
		nLenStartNodes = len(acStartNodes)

		acEndpointNodes = This.NodesByType("endpoint")
		nLenEndPointNodes = len(acEndpointNodes)

		aIssues = []
	
		for i = 1 to nLenEndPointNodes
			bReachable = FALSE

			for j = 1 to nLenStartNodes
				if This.PathExists(acStartNodes[j], acEndpointNodes[i])
					bReachable = TRUE
					exit
				ok
			end
			if NOT bReachable
				aIssues + "Endpoint unreachable: " + acEndpointNodes[i]
			ok
		end
	
		return [
			:status = iif(len(aIssues) = 0, "pass", "fail"),
			:domain = "reachability",
			:issueCount = len(aIssues),
			:issues = aIssues
		]
	
	def _ValidateCompleteness()
		aIssues = []
		acDecisions = This.NodesByType("decision")
		nLen = len(acDecisions)

		for i = 1 to nLen
			if len(This.Neighbors(acDecisions[i])) < 2
				aIssues + "Decision node has fewer than 2 paths: " + acDecisions[i]
			ok
		end
	
		return [
			:status = iif(len(aIssues) = 0, "pass", "fail"),
			:domain = "completeness",
			:issueCount = len(aIssues),
			:issues = aIssues
		]

	def ValidationResult()
		return @aLastValidationResult
	
		def Result()

	def ValidationStatus()
		if len(@aLastValidationResult) = 0
			return ""
		ok
		return @aLastValidationResult["status"]
	
		def Status()
			return This.ValidationStatus()

	def ValidationDomain()
		if len(@aLastValidationResult) = 0
			return ""
		ok
		return @aLastValidationResult["domain"]
	
		def Domain()
			return This.Validationdomain()

	def ValidationIssueCount()
		if len(@aLastValidationResult) = 0
			return 0
		ok
		return @aLastValidationResult["issueCount"]
	
		def IssueCount()
			return This.ValidationIssueCount()

	def ValidationIssues()
		if len(@aLastValidationResult) = 0
			return []
		ok
		return @aLastValidationResult["issues"]
	
		def Issues()
			return This.ValidationIssues()

	def HasValidationIssues()
		return This.ValidationIssueCount() > 0

		def HasIssues()
			return This.HasValidationIssues()

	#------------------------------------------
	#  METRICS
	#------------------------------------------

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

	#------------------------------------------
	#  VISUALIZATION
	#------------------------------------------

	def View()

		# Generate DOT code
		cDotCode = This.Dot()
		
		# Create stzDotCode instance and execute
		oDotExec = new stzDotCode()
		oDotExec.SetCode(cDotCode)
		oDotExec.SetOutputFormat("svg")
		oDotExec.ExecuteAndView()
		
		def Display()
			This.View()


	#------------------------------------------
	#  EXPORT
	#------------------------------------------

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
		return oConv.Code()

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

	#------------------
	#  WRITE TO FILE
	#------------------

	def WriteToFile(pcFileName)
		if right(pcFileName, 7) = "stzdiag"
			return This.WriteToStzDiagFile(pcFileName)

		but right(pcFileName, 3) = "dot"
			return This.WriteToDotFile(pcFileName)

		but right(pcFileName, 4) = "json"
			return This.WriteToJsonFile(pcFileName)

		but right(pcFileName, 3) = "mmd"
			return This.WriteToMermaidFile(pcFileName)

		else
			return 0
		ok

	def WriteToDiagFile(pcFileName)
		oConv = new stzDiagramToStzDiag(This)
		bSuccess = oConv.WriteToFile(pcFileName)
		return bSuccess

		def WriteToStzDiagFile(pcFileName)
			return This.WriteToDiagFile(pcFileName)

	def WriteToDotFile(pcFileName)
		oConv = new stzDiagramToDot(This)
		bSuccess = oConv.WriteToFile(pcFileName)
		return bSuccess

	def WriteToMermaidFile(pcFileName)
		oConv = new stzDiagramToMermaid(This)
		bSuccess = oConv.WriteToFile(pcFileName)
		return bSuccess

	def WriteToJsonFile(pcFileName)
		oConv = new stzDiagramToJson(This)
		bSuccess = oConv.WriteToFile(pcFileName)
		return bSuccess

	#---------------
	#  VISUAL RULES AND SEMANTICS
	#------------------


	def AddVisualRule(oRule)
		@aoVisualRules + oRule
	

	def ApplyVisualRules()
	    aNodes = This.Nodes()
	    nLen = len(aNodes)
	
	    for i = 1 to nLen
	        aNode = aNodes[i]
	        cNodeId = aNode["id"]
	        
	        # Build context from all properties (metadata is IN properties, not separate)
	        aContext = aNode
	        if HasKey(aNode, "properties") and aNode["properties"] != NULL
	            aContext["metadata"] = aNode["properties"]
	            aContext["tags"] = []
	            if HasKey(aNode["properties"], "tags")
	                aContext["tags"] = aNode["properties"]["tags"]
	            ok
	        ok
	        
	        # Apply matching rules
	        nLenRules = len(@aoVisualRules)
	        for j = 1 to nLenRules
	            if @aoVisualRules[j].Matches(aContext)
	                aEffects = @aoVisualRules[j].Effects()
	                nLenEffects = len(aEffects)
	
	                for k = 1 to nLenEffects
	                    cAspect = aEffects[k][1]
	                    pValue = aEffects[k][2]
	                    This.SetNodeProperty(cNodeId, cAspect, pValue)
	                end
	            ok
	        end
	        
	        if HasKey(aNode, "properties")
	            @aNodeEnhancements[cNodeId] = aNode["properties"]
	        ok
	    end
	    
	    # Process edges
	    aEdges = This.Edges()
	    nLen = len(aEdges)
	
	    for i = 1 to nLen
	        aEdge = aEdges[i]
	        cEdgeKey = aEdge["from"] + "->" + aEdge["to"]
	        
	        # Build context
	        aContext = aEdge
	        if HasKey(aEdge, "properties") and aEdge["properties"] != NULL
	            aContext["metadata"] = aEdge["properties"]
	            aContext["tags"] = []
	            if HasKey(aEdge["properties"], "tags")
	                aContext["tags"] = aEdge["properties"]["tags"]
	            ok
	        ok
	        
	        # Apply matching rules
	        nLenRules = len(@aoVisualRules)
	        for j = 1 to nLenRules
	            if @aoVisualRules[j].Matches(aContext)
	                aEffects = @aoVisualRules[j].Effects()
	                nLenEffects = len(aEffects)
	
	                for k = 1 to nLenEffects
	                    cAspect = aEffects[k][1]
	                    pValue = aEffects[k][2]
	                    This.SetEdgeProperty(aEdge["from"], aEdge["to"], cAspect, pValue)
	                end
	            ok
	        end
	        
	        if HasKey(aEdge, "properties")
	            @aEdgeEnhancements[cEdgeKey] = aEdge["properties"]
	        ok
	    end
		
	def MetadataLegend()
		# Generate legend showing metadata-to-visual mappings
		aLegend = []
		
		aLegend + "=== METADATA LEGEND ==="
		aLegend + ""
		
		nLenRules = len(@aoVisualRules)
		for i = 1 to nLenRules
			cDesc = "When: " + @aoVisualRules[i].@cConditionType
			aLegend + cDesc
			
			aEffects = @aoVisualRules[i].Effects()
			nLenEff = len(aEffects)

			for j = 1 to nLenEff
				aLegend + "  → " + aEffects[j][1] + ": " + aEffects[j][2]
			end
			aLegend + ""
		end
		
		return aLegend

	#------------------------------------------
	#  IMPORT WITH SUBDIAGRAM SUPPORT
	#------------------------------------------
	
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
					"Either add node '" + cFirstNodeId + "' first, or clear the diagram with RemoveAllNodes()")
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
				This.AddNodeXT(acNodes[i]["id"], acNodes[i]["label"], 
					acNodes[i]["properties"]["type"], 
					acNodes[i]["properties"]["color"])
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
				
			but cLine = "metadata"
				cCurrentSection = "metadata"
				
			but cLine = "nodes"
				cCurrentSection = "nodes"
				
			but cLine = "edges"
				cCurrentSection = "edges"
				
			but cCurrentSection = "metadata" and substr(cLine, ":")
				aParts = split(cLine, ":")
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
						This.AddNodeXT(cCurrentNode, cLabel, cType, cColor)
					ok
					cCurrentNode = cLine
					cLabel = ""
					cType = ""
					cColor = ""

				but substr(cLine, "label:")
					cLabel = @substr(cLine, 8, stzlen(cLine))
					cLabel = This.UnescapeString(cLabel)

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
			This.AddNodeXT(cCurrentNode, cLabel, cType, cColor)
		ok

		# Now add all edges
		nLen = len(aEdgesToAdd)
		for i = 1 to nLen
			This.Connect(aEdgesToAdd[i][1], aEdgesToAdd[i][2])
		end
	

#=====================================================
#  stzDiagramAnnotator - METADATA OVERLAY
#=====================================================

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

#=====================================================
#  stzDiagramValidators - PLUGGABLE VALIDATORS
#=====================================================

class stzDiagramValidator

	def init()
		@aValidators = []

	def ValidateDiagram(oDiagram, pcDomain)
		if HasKey($acDiagramValidators, pcDomain)
			oValidator = nex stzDiagramValidatorXT(pcDomain)
			return oValidator.Validate(oDiagram)
		else
			return [
				:status = "error",
				:message = "No validator registered for domain: " + pcDomain
			]
		ok

	def Validators()
		return $acDiagramValidators


#=====================================================
#  stzDiagramSoxValidator - SARBANES-OXLEY
#=====================================================

class stzDiagramSoxValidator from stzDiagramValidator
	@aValidationResult = []

	def init()

	def Validate(oDiag)
		aIssues = []

		# Rule 1: Financial processes must have audit trail
		acFinancialNodes = oDiag.NodesByProperty("domain", "financial")
		nLenFin = len(acFinancialNodes)

		for i = 1 to nLenFin
			cNodeId = acFinancialNodes[i]
			aoAnnPerf = oDiag.AnnotationsByType("performance")
			bHasAudit = 0

			nLenAnn = len(aoAnnPerf)
			for j = 1 to nLenAnn
				aData = aoAnnPerf[j].NodeData(cNodeId)
				if HasKey(aData, "audittrail")
					bHasAudit = 1
					exit
				ok
			end

			if NOT bHasAudit
				aIssues + "SOX-001: Financial process missing audit trail: " + cNodeId
			ok
		end

		# Rule 2: Payment/approval decisions must require approval
		acDec = oDiag.NodesByType("decision")
		nLen = len(acDec)

		for i = 1 to nLen
			cNodeId = acDec[i]
			aNode = oDiag.Node(cNodeId)
			bHasApprovalReq = 0

			if aNode["properties"]["requiresApproval"] = 1
				bHasApprovalReq = 1
			ok

			if NOT bHasApprovalReq
				aIssues + "SOX-002: Decision node lacks approval requirement: " + cNodeId
			ok
		end

		# Rule 5: No cycles in financial workflow
		if oDiag.CyclicDependencies()
			aIssues + "SOX-005: Cyclic dependency detected in workflow"
		ok

		nLen = len(aIssues)
		@aValidationResult = [
			:status = iif(nLen = 0, "pass", "fail"),
			:domain = "sox",
			:issueCount = nLen,
			:issues = aIssues
		]

	def Result()
		return @aValidationResult

#=====================================================
#  stzDiagramGdprValidator - GDPR
#=====================================================

class stzDiagramGdprValidator from stzDiagramValidator
	@aValidationResult = []

	def init()

	def Validate(oDiag)
		aIssues = []

		# Rule 1: Personal data processing requires consent
		aDataNodes = oDiag.NodesByProperty("dataType", "personal")
		for cNodeId in aDataNodes
			aNode = oDiag.Node(cNodeId)
			bHasConsent = 0

			if aNode["properties"]["requiresConsent"] = 1
				bHasConsent = 1
			ok

			if NOT bHasConsent
				aIssues + "GDPR-001: Personal data processing missing consent: " + cNodeId
			ok
		end

		# Rule 2: Data retention policy must be defined
		for cNodeId in aDataNodes
			aNode = oDiag.Node(cNodeId)
			bHasRetention = 0

			if aNode["properties"]["retentionPolicy"] != ""
				bHasRetention = 1
			ok

			if NOT bHasRetention
				aIssues + "GDPR-002: Data node missing retention policy: " + cNodeId
			ok
		end

		nLen = len(aIssues)
		@aValidationResult = [
			:status = iif(nLen = 0, "pass", "fail"),
			:domain = "gdpr",
			:issueCount = nLen,
			:issues = aIssues
		]

	def Result()
		return @aValidationResult

#=====================================================
#  stzDiagramBankingValidator - CUSTOM BANKING
#=====================================================

class stzDiagramBankingValidator from stzDiagramValidator
	@aValidationResult = []

	def init()

	def Validate(oDiag)
		aIssues = []

		# Rule 1: Large transactions require multi-level approval
		aLargeTransactions = oDiag.NodesByProperty("transactionType", "large")
		for cNodeId in aLargeTransactions
			aIncoming = oDiag.Incoming(cNodeId)
			nApprovals = 0

			for cPrev in aIncoming
				oPrev = oDiag.Node(cPrev)
				if oPrev["properties"]["role"] = "approver"
					nApprovals += 1
				ok
			end

			if nApprovals < 2
				aIssues + "BANK-001: Large transaction requires 2+ approvals: " + cNodeId
			ok
		end

		# Rule 2: Fraud detection before payment
		aPaymentNodes = oDiag.NodesByProperty("operation", "payment")
		for cNodeId in aPaymentNodes
			aIncoming = oDiag.Incoming(cNodeId)
			bHasFraudCheck = 0

			for cPrev in aIncoming
				aPrev = oDiag.Node(cPrev)
				if aPrev["properties"]["operation"] = "fraud_check"
					bHasFraudCheck = 1
					exit
				ok
			end

			if NOT bHasFraudCheck
				aIssues + "BANK-002: Payment missing fraud detection: " + cNodeId
			ok
		end

		nLen = len(aIssues)
		@aValidationResult = [
			:status = iif(nLen = 0, "pass", "fail"),
			:domain = "banking",
			:issueCount = nLen,
			:issues = aIssues
		]

	def Result()
		return @aValidationResult


#=====================================================
#  stzDiagramToStzDiag - NATIVE FORMAT
#=====================================================

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

		cOutput += 'diagram "' +
			   @oDiagram.Id() + '"' + NL + NL

		cOutput += "metadata" + NL
		cOutput += "    theme: " + Lower(@oDiagram.@cTheme) + NL
		cOutput += "    layout: " + Lower(@oDiagram.@cLayout) + NL + NL

		cOutput += "nodes" + NL
		for aNode in @oDiagram.Nodes()

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

		if len(@oDiagram.Edges()) > 0
			cOutput += "edges" + NL

			for aEdge in @oDiagram.Edges()
				cOutput += "    " + aEdge["from"] + " -> " + aEdge["to"] + NL

				if aEdge["label"] != ""
					cOutput += "        label: " + This.EscapeString(aEdge["label"]) + NL
				ok

				cOutput += NL
			end

		ok

		if len(@oDiagram.Clusters()) > 0
			cOutput += "clusters" + NL

			for aCluster in @oDiagram.Clusters()
				cOutput += "    " + aCluster["id"] + NL
				cOutput += "        label: " + This.EscapeString(aCluster["label"]) + NL
				cNodeList = This.NodeListToString(aCluster["nodes"])
				cOutput += "        nodes: [" + cNodeList + "]" + NL
				cOutput += "        color: " + aCluster["color"] + NL
				cOutput += NL
			end
		ok

		if len(@oDiagram.Annotations()) > 0
			cOutput += "annotations" + NL
			for oAnnot in @oDiagram.Annotations()
				cOutput += "    " + Lower(oAnnot.Type()) + NL

				aAnnotData = oAnnot.NodesData()

				for cNodeId in Keys(aAnnotData)
					cData = aAnnotData[cNodeId]
					cOutput += "        " + String(cNodeId) + ": "
					cOutput += This.DataToString(cData) + NL
				end
				cOutput += NL
			end
		ok

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


#=====================================================
#  stzDiagramToDot - GRAPHVIZ DOT (UPDATED)
#=====================================================

class stzDiagramToDot

	@oDiagram
	@cDotCode

	def init(poDiagram)
		if NOT ( isObject(poDiagram) and ring_classname(poDiagram) = "stzdiagram")
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
		if cTheme = "" or cTheme = NULL
			cTheme = "light"
		ok
		return cTheme
	
	def _GenerateGraphAttributes(cTheme)
		cRankDir = This._GetRankDir()
		cFont = This._GetFont()
		nFontSize = This._GetFontSize()
		
		# Ensure rankdir is always set, even with no edges
		cResult = '    graph [rankdir=' + cRankDir + 
			   ', bgcolor=white, fontname="' + 
			   cFont + '", fontsize=' + nFontSize + ']' + NL
	
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
		          ', color="' + cEdgeColor + '", style=' + @oDiagram.@cEdgePenStyle + 
		          ', penwidth=' + @oDiagram.@nEdgePenWidth + 
		          ', arrowhead=' + @oDiagram.@cArrowHead + 
		          ', arrowtail=' + @oDiagram.@cArrowTail + ']' + NL
	
		return cResult
	
	def _GetRankDir()
		cLayout = lower(@oDiagram.@cLayout)
		
		# Handle empty/null layout
		if cLayout = "" or cLayout = NULL
			cLayout = "topdown"
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
		if cFont = "" or cFont = NULL
			cFont = $cDefaultFont
		ok

		return cFont
	
	def _GetFontSize()
		nFontSize = @oDiagram.@nFontSize
		if nFontSize = 0 or nFontSize = NULL
			nFontSize = $cDefaultFontSize
		ok

		return nFontSize
	
	def _GetEdgeColor(cTheme)
		# Use resolved color from diagram, default to black
		cEdgeColor = @oDiagram.@cEdgeColor
		
		if cEdgeColor = "" or cEdgeColor = NULL
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
		cLabel = aNode["label"]
		
		# Get enhancements
		aEnhancements = []
		if HasKey(@oDiagram.@aNodeEnhancements, aNode["id"])
			aEnhancements = @oDiagram.@aNodeEnhancements[aNode["id"]]
		ok
		
		# Get shape and style
		cShape = This._GetNodeShape(aNode, aEnhancements)
		cStyle = This._GetNodeStyle(aNode, aEnhancements)
		
		# Get colors
		cFillColor = This._GetNodeFillColor(aNode, aEnhancements, cTheme)
		cFontColor = @oDiagram.ResolveFontColor(cFillColor)
		cStrokeColor = This._GetNodeStrokeColor(cTheme)
		
		# Build node line
		cOutput = '    ' + cNodeId + ' [label="' + cLabel + '"'
		cOutput += ', shape=' + cShape
		cOutput += ', style="' + cStyle + '"'
		cOutput += ', fillcolor="' + cFillColor + '"'
		cOutput += ', fontcolor="' + cFontColor + '"'
		
		# Add pen width if enhanced
		if HasKey(aEnhancements, "penwidth")
			cOutput += ', penwidth=' + aEnhancements["penwidth"]
		ok
		
		# Add stroke color
		if cStrokeColor != ""
			cOutput += ', color="' + cStrokeColor + '", penwidth=2'
		ok
		
		cOutput += ']' + NL
		
		return cOutput
	
	def _SanitizeNodeId(cNodeId)
		if left(cNodeId, 1) = "@"
			return @substr(cNodeId, 2, stzlen(cNodeId))
		ok

		return cNodeId
	
	def _GetNodeShape(aNode, aEnhancements)
		if HasKey(aEnhancements, "shape")
			return aEnhancements["shape"]
		ok
		
		cType = ""
		if HasKey(aNode, "properties") and aNode["properties"] != NULL and 
		   HasKey(aNode["properties"], "type") and aNode["properties"]["type"] != NULL
			cType = lower("" + aNode["properties"]["type"])
		ok
		
		# Direct DOT shape (bypasses semantic mapping)
		
		if ring_find($acDotShapes, cType) > 0
			return cType
		ok
		
		# Semantic to shape mapping #TODO store them globally
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
		aPolygonShapes = ["hexagon", "octagon", "parallelogram", "pentagon", 
		                  "septagon", "trapezium", "invtrapezium", "triangle",
		                  "house", "invtriangle", "diamond"]
		
		if ring_find(aPolygonShapes, cShape) > 0
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
		
		# Check node properties FIRST (where rules write to)
		if HasKey(aNode, "properties") and aNode["properties"] != NULL and 
		   HasKey(aNode["properties"], "color") and aNode["properties"]["color"] != NULL
			cColor = aNode["properties"]["color"]
		ok
		
		# Then check enhancements
		if (cColor = "" or cColor = NULL) and HasKey(aEnhancements, "color")
			cColor = aEnhancements["color"]
		ok
		
		# Default
		if cColor = "" or cColor = NULL
			cColor = $cDefaultNodeColor
		ok
		
		# If already hex, apply theme transforms
		if substr(cColor, "#")
			if cTheme = "gray"
				return @oDiagram.ConvertColorTogray(cColor)
			but cTheme = "print"
				return ResolveColor(:white)
			ok
			return cColor
		ok
		
		# Apply theme palette for semantic colors
		cLowerColor = lower(cColor)
		if HasKey($aPalette, cTheme)
			aThemePalette = $aPalette[cTheme]
			if HasKey(aThemePalette, cLowerColor)
				cColor = aThemePalette[cLowerColor]
			ok
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
		
		cOutput = '    ' + cFrom + ' -> ' + cTo
		
		aAttrs = []
		
		# Label
		if HasKey(aEdge, "label") and aEdge["label"] != "" and aEdge["label"] != NULL
			aAttrs + ('label=" ' + aEdge["label"] + '"')
		ok
		
		# Style from properties
		if HasKey(aEdge, "properties") and HasKey(aEdge["properties"], "style")
			aAttrs + ('style="' + aEdge["properties"]["style"] + '"')
		ok
		
		# Color from properties
		if HasKey(aEdge, "properties") and HasKey(aEdge["properties"], "color")
			cColor = ResolveColor(aEdge["properties"]["color"])
			aAttrs + ('color="' + cColor + '"')
		ok
		
		# Pen width from properties
		if HasKey(aEdge, "properties") and HasKey(aEdge["properties"], "penwidth")
			aAttrs + ('penwidth=' + aEdge["properties"]["penwidth"])
		ok
		
		if len(aAttrs) > 0
			cOutput += ' [' + This._JoinAttributes(aAttrs) + ']'
		ok
		
		cOutput += NL
		
		return cOutput
	
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

#=====================================================
#  stzDiagramToMermaid - MERMAID.JS
#=====================================================

class stzDiagramToMermaid

	@oDiagram
	@cMermaidCode

	def init(poDiagram)
		if NOT ( isObject(poDiagram) and ring_classname(poDiagram) = "stzdiagram" )
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
	
		for aNode in @oDiagram.Nodes()
			cNodeId = aNode["id"]
			cLabel = aNode["label"]
	
			# Escape reserved keywords
			cSafeNodeId = cNodeId
			if ring_find(aReservedWords, lower(cNodeId)) > 0
				cSafeNodeId = "node_" + cNodeId
			ok
	
			cType = aNode["properties"]["type"]
			if cType = :start or cType = "start"
				cOutput += '    ' + cSafeNodeId + '(["' + cLabel + '"])' + NL
	
			but cType = :endpoint or cType = "endpoint"
				cOutput += '    ' + cSafeNodeId + '(["' + cLabel + '"])' + NL
	
			but cType = :decision or cType = "decision"
				cOutput += '    ' + cSafeNodeId + '{{"' + cLabel + '"}}' + NL
	
			but cType = :process or cType = "process"
				cOutput += '    ' + cSafeNodeId + '["' + cLabel + '"]' + NL
	
			else
				cOutput += '    ' + cSafeNodeId + '["' + cLabel + '"]' + NL
			ok
		end
	
		cOutput += NL
	
		for aEdge in @oDiagram.Edges()
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

#=====================================================
#  stzDiagramToJSON - JSON FORMAT
#=====================================================

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


#------------------
#  VISUAL RULES
#------------------

class stzVisualRule
	@cRuleId
	@cConditionType  # :metadata_exists, :metadata_equals, :metadata_range, :tag_exists
	@aConditionParams
	@aVisualEffects  # List of [aspect, value] pairs
	
	def init(pcRuleId)
		@cRuleId = pcRuleId
		@aVisualEffects = []
	
	def WhenMetadataExists(pcKey)
		@cConditionType = :metadata_exists
		@aConditionParams = [pcKey]

	def When(pcKey, pValue)
		if isList(pValue)
			oVal = StzListQ(pValue)
			if oVal.IsEqualsNamedParam()
				This.WhenMetaDataEquals(pcKey, pValue[2])
				return

			but oVal.IsInRangeNamedParam()
				This.WhenMetadataInRange(pcKey, pValue[2][1], pValue[2][2])
				return
			ok

		but isString(pValue)
			if pValue = "exists"
				This.WhenMetadataExists(pcKey)
				This.WhenTagExists(pcKey)
				return
			ok
		ok

		StzRaise("Unsupported syntax!")

	
	def WhenMetaDataEquals(pcKey, pValue)
		@cConditionType = :metadata_equals
		@aConditionParams = [pcKey, pValue]

	def WhenMetadataInRange(pcKey, nMin, nMax)
		@cConditionType = :metadata_range
		@aConditionParams = [pcKey, nMin, nMax]
	
	def WhenTagExists(pcTag)
		@cConditionType = :tag_exists
		@aConditionParams = [pcTag]
	
	def ApplyColor(pColor)
		cResolvedColor = ResolveColor(pColor)
		@aVisualEffects + [:color, cResolvedColor]
	
		def UseColor(pColor)
			This.ApplyColor(pColor)

	def ApplyShape(pcShape)
		@aVisualEffects + [:shape, pcShape]
	
		def UseShape(pcShape)
			This.ApplyShape(pcShape)

	def ApplyStyle(pcStyle)
		@aVisualEffects + [:style, pcStyle]
	
		def UseStyle(pcStyle)
			This.ApplyStyle(pcStyle)

	def ApplyPenWidth(nWidth)
		@aVisualEffects + [:penwidth, nWidth]
	
		def UsePenWidth(nWidth)
			This.ApplyPenWidth(nWidth)

		def SetPenWidth(nWidth)
			This.ApplyPenWidth(nWidth)

	def Matches(aNodeOrEdge)
	    switch @cConditionType
	    on :metadata_exists
	        cKey = @aConditionParams[1]
	        if HasKey(aNodeOrEdge, "metadata")
	            return HasKey(aNodeOrEdge["metadata"], cKey)
	        ok
	        if HasKey(aNodeOrEdge, "properties")
	            return HasKey(aNodeOrEdge["properties"], cKey)
	        ok
	        return FALSE
	    
	    on :metadata_equals
	        cKey = @aConditionParams[1]
	        pValue = @aConditionParams[2]
	        
	        # Check metadata sub-hash
	        if HasKey(aNodeOrEdge, "metadata") and HasKey(aNodeOrEdge["metadata"], cKey)
	            return aNodeOrEdge["metadata"][cKey] = pValue
	        ok
	        
	        # Check properties directly
	        if HasKey(aNodeOrEdge, "properties") and HasKey(aNodeOrEdge["properties"], cKey)
	            return aNodeOrEdge["properties"][cKey] = pValue
	        ok
	        
	        return FALSE
	    
	    on :metadata_range
	        cKey = @aConditionParams[1]
	        nMin = @aConditionParams[2]
	        nMax = @aConditionParams[3]
	        
	        nValue = NULL
	        if HasKey(aNodeOrEdge, "metadata") and HasKey(aNodeOrEdge["metadata"], cKey)
	            nValue = aNodeOrEdge["metadata"][cKey]
	        but HasKey(aNodeOrEdge, "properties") and HasKey(aNodeOrEdge["properties"], cKey)
	            nValue = aNodeOrEdge["properties"][cKey]
	        ok
	        
	        if nValue != NULL
	            return nValue >= nMin and nValue <= nMax
	        ok
	        return FALSE
	    
	    on :tag_exists
	        cTag = @aConditionParams[1]
	        if HasKey(aNodeOrEdge, "tags")
	            return ring_find(aNodeOrEdge["tags"], cTag) > 0
	        ok
	        if HasKey(aNodeOrEdge, "properties") and HasKey(aNodeOrEdge["properties"], "tags")
	            return ring_find(aNodeOrEdge["properties"]["tags"], cTag) > 0
	        ok
	        return FALSE
	    off
	    
	    return FALSE
	
	def Effects()
		return @aVisualEffects


	def RemoveNodes()
	    super.RemoveNodes()
	    @aNodeEnhancements = []
	    @aEdgeEnhancements = []

	    def RemoveAllNodes()
		This.RemoveNodes()

	    def Clear()
		This.RemoveNodes()

#------------------------#
#  COLOR RESOLVER CLASS  #
#------------------------#

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
