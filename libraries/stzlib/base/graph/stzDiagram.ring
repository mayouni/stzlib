#--------------------------------------------------#
#  stzDiagram - DOMAIN SPECIALIZATION OF stzGraph  #
#  Workflows, org charts, semantic diagrams        #
#==================================================#

#  GLOBAL REGISTRY

$aDiagramValidators = [
	:SOX,
	:GDPR,
	:Banking
]

#  UNIFIED COLOR SYSTEM	#TODO Abstract it in a stzColor class -> Visual Module
#-----------------------

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
		:primary = "white",
		:success = "gray--",
		:warning = "gray-",
		:danger = "gray++",
		:info = "gray+",
		:neutral = "white",
		:background = "white"
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
$cDefaultNodeColor = "white"
$cDefaultNodeStrokeColor = "gray"  # Can be "" or 'invisible' to hide

$cDefaultClusterColor = "blue--"

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

# LAYOUT ENGINE OPTIONS
$acSplineTypes = ["ortho", "spline", "polyline", "curved", "line", "none"]
$cDefaultSplineType = "ortho"

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

#-- Output file

$cDefaultOutputFormat = "svg" #TODO Implement it

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

#---

$bTitleVisibility = FALSE

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

func AttenuateColor(cColor)
    # Remove all intensity modifiers
    cBase = replace(cColor, "++", "")
    cBase = replace(cBase, "+", "")
    cBase = replace(cBase, "--", "")
    cBase = replace(cBase, "-", "")
    
    # Apply maximum attenuation
    return cBase + "--"

func IntensifyColor(cColor)
    # Remove all intensity modifiers
    cBase = replace(cColor, "++", "")
    cBase = replace(cBase, "+", "")
    cBase = replace(cBase, "--", "")
    cBase = replace(cBase, "-", "")
    
    # Apply maximum intensification
    return cBase + "++"

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

	# Map unsupported to supported shapes
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

#--------------------------------------------------#
#  stzDiagram Class - Main Diagram Implementation  #
#--------------------------------------------------#

class stzDiagram from stzGraph

	@cTheme = $cDefaultTheme
	@cLayout = $cDefaultLayout
	@aClusters = []
	@aoAnnotations = []
	@aoTemplates = []

	@cEdgeColor = $cDefaultEdgeColor
	@cNodeColor = $cDefaultNodeColor
	@cNodeStrokeColor = $cDefaultNodeStrokeColor

	@aPalette = $aPalette
	@aFontColors = $aFontColors

	@cEdgeStyle = $cDefaultEdgeStyle

	@cFont = $cDefaultFont
	@nFontSize = $cDefaultFontSize

	@aMetadataKeys = []

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

	@aVisualRules = []

	@cSplineType = $cDefaultSplineType
	@nNodeSep = $nDefaultNodeSep
	@nRankSep = $nDefaultRankSep
	@bConcentrate = FALSE

	@cTitle = ""
	@cSubtitle = ""
	@bTitleVisibility = $bTitleVisibility

	def init(pTitle)
		super.init(pTitle)
		@cTitle = pTitle
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
	
	def SetFontSize(pSize)
		@nFontSize = pSize
	
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
	    ok

	    def SetEdgeLineStyle(pcType)
		This.SetSplines(pcType)
	
	    def SetEdgeLineType(pcType)
		This.SetSplines(pcType)
	
	def SetNodeSeparation(pnValue)
	    if isNumber(pnValue) and pnValue > 0
	        @nNodeSep = pnValue
	    ok
	
	def SetRankSeparation(pnValue)
	    if isNumber(pnValue) and pnValue > 0
	        @nRankSep = pnValue
	    ok
	
	def SetConcentrate(pbValue)
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

	def SetTitleVisibility(b)
		if NOT (isNumber(b) and (b = 1 or b = 0) )
			stzraise("Incorrect param type! b must be a boolean.")
		ok

		@bTitleVisibility = b

	def SetTitle(pcTitle)
	    @cTitle = pcTitle
	
	def SetSubtitle(pcSubtitle)
	    @cSubtitle = pcSubtitle

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

	def TitleVisibility()
		return 	@bTitleVisibility

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

	def AddCluster(pClusterId, aNodeIds)
		This.AddClusterXT(pClusterId, pClusterId, aNodeIds)

	def AddClusterXT(pClusterId, pLabel, aNodeIds)
		This.AddClusterXTT(pClusterId, pLabel, aNodeIds, $cDefaultClusterColor)

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
		oDotExec.SetOutputFormat("svg")
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
	#  WRITE TO FILE  #
	#-----------------#

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

	#===========================#
	#  VISUAL RULES MANAGEMENT  #
	#===========================#
	
	def SetVisualRule(p)
		This.SetRule(p)
	
		def SetVisualRuleObject(oVisualRule)
			This.SetVisualRule(oVisualRule)
	
	def ApplyVisualRules()
		This.ApplyRulesByType("visual")
	
	def VisualRule(pcRuleId)
		return This.Rule(pcRuleId)
	
	def VisualRules()
		return This.RulesByType("visual")
	
	def VisualRuleObjects()
		return This.RulesObjectsByType("visual")
	
	def RemoveVisualRule(p)
		if isString(p)
			@aVisualRules[p] = NULL
			This.RemoveRule(p)
		but isObject(p)
			@aVisualRules[p.@cRuleId] = NULL
			This.RemoveRule(p)
		ok
	


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
		
		nNodesAffected = len(@aNodeEnhancements)
		nEdgesAffected = len(@aEdgeEnhancements)
		
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

	#------------------------------#
	#  1. BASIC AFFECTED ELEMENTS  #
	#------------------------------#

	# Get all nodes affected by any rule
	def NodesAffectedByVisualRules()
		return keys(@aNodeEnhancements)
	
		def NodesAffectedByVRules()
			return This.NodesAffectedByVisualRules()

	# Get all edges affected by any rule
	def EdgesAffectedByVisualRules()
		return keys(@aEdgeEnhancements)
	
		def EdgesAffectedByVRules()
			return This.EdgesAffectedByVisualRules()
	
	# Get both nodes and edges affected
	def ElementsAffectedByVisualRules()
		return [
			:nodes = This.NodesAffectedByRules(),
			:edges = This.EdgesAffectedByRules()
		]
	
		def ElementsAffectedByVRules()
			return This.ElementsAffectedByVisualRules()
	
		def VisualRulesImpact()
			return This.ElementsAffectedByVisualRules()

		def VRulesImpact()
			return This.ElementsAffectedByVisualRules()

		def ImpactOfVisualRules()
			return This.ElementsAffectedByVisualRules()

		def ImpactOfVRules()
			return This.ElementsAffectedByVisualRules()

	#--------------------------#
	#  2. UNAFFECTED ELEMENTS  #
	#--------------------------#
	
	# Get nodes NOT affected by any rule
	def NodesNotAffectedByVisualRules()
		acAllNodes = []
		aNodes = This.Nodes()
		nLen = len(aNodes)
		for i = 1 to nLen
			acAllNodes + aNodes[i]["id"]
		end
		
		acAffected = keys(@aNodeEnhancements)
		acNotAffected = []
		
		nLen = len(acAllNodes)
		for i = 1 to nLen
			if find(acAffected, acAllNodes[i]) = 0
				acNotAffected + acAllNodes[i]
			ok
		end
		
		return acNotAffected
	
		def NodesNotAffectedByVRules()
			return This.NodesNotAffectedByVisualRules()

	
	# Get edges NOT affected by any rule
	def EdgesNotAffectedByVisualRules()
		acAllEdges = []
		aEdges = This.Edges()
		nLen = len(aEdges)
		for i = 1 to nLen
			acAllEdges + (aEdges[i]["from"] + "->" + aEdges[i]["to"])
		end
		
		acAffected = keys(@aEdgeEnhancements)
		acNotAffected = []
		
		nLen = len(acAllEdges)
		for i = 1 to nLen
			if find(acAffected, acAllEdges[i]) = 0
				acNotAffected + acAllEdges[i]
			ok
		end
		
		return acNotAffected
	
		def EdgesNotAffectedByVRules()
			return This.EdgesNotAffectedByVisualRules()
	
	# Get both unaffected nodes and edges
	def ElementsNotAffectedByVisualRules()
		return [
			:nodes = This.NodesNotAffectedByVisualRules(),
			:edges = This.EdgesNotAffectedByVisualRules()
		]
	
		def ElementsNotAffectedByVRules()
			return This.ElementsNotAffectedByVisualRules()
	
	#-----------------------------------#
	#  3. AFFECTED BY SPECIFIC RULE(S)  #
	#-----------------------------------#
	
	# Get nodes affected by a specific rule
	def NodesAffectedByVisualRule(poRule)
		acAffected = []
		acNodeIds = keys(@aNodeEnhancements)
		nLen = len(acNodeIds)
		
		for i = 1 to nLen
			aNode = This.Node(acNodeIds[i])
			aContext = This._BuildRuleContext(aNode)
			if poRule.Matches(aContext)
				acAffected + acNodeIds[i]
			ok
		end
		
		return acAffected
	
		def NodesAffectedByVRule(poRule)
			return This.NodesAffectedByVisualRule(poRule)
	
	# Get edges affected by a specific rule
	def EdgesAffectedByVisualRule(poRule)
		acAffected = []
		acEdgeKeys = keys(@aEdgeEnhancements)
		nLen = len(acEdgeKeys)
		
		for i = 1 to nLen
			acParts = split(acEdgeKeys[i], "->")
			aEdge = This.Edge(acParts[1], acParts[2])
			aContext = This._BuildRuleContext(aEdge)
			if poRule.Matches(aContext)
				acAffected + acEdgeKeys[i]
			ok
		end
		
		return acAffected
	
		def EdgesAffectedByVRule(poRule)
			return This.EdgesAffectedByVisualRule(poRule)
	
	# Get nodes affected by any of the given rules
	def NodesAffectedByTheseVisualRules(paoRules)
		acAffected = []
		acNodeIds = keys(@aNodeEnhancements)
		nNodeLen = len(acNodeIds)
		
		for i = 1 to nNodeLen
			aNode = This.Node(acNodeIds[i])
			aContext = This._BuildRuleContext(aNode)
			
			nRuleLen = len(paoRules)
			for j = 1 to nRuleLen
				if paoRules[j].Matches(aContext)
					if find(acAffected, acNodeIds[i]) = 0
						acAffected + acNodeIds[i]
					ok
					exit
				ok
			end
		end
		
		return acAffected
	
		def NodesAffectedByTheseVRules(paoRules)
			return This.NodesAffectedByTheseVisualRules(paoRules)
	
	# Get edges affected by any of the given rules
	def EdgesAffectedByTheseVisualRules(paoRules)
		acAffected = []
		acEdgeKeys = keys(@aEdgeEnhancements)
		nEdgeLen = len(acEdgeKeys)
		
		for i = 1 to nEdgeLen
			acParts = split(acEdgeKeys[i], "->")
			aEdge = This.Edge(acParts[1], acParts[2])
			aContext = This._BuildRuleContext(aEdge)
			
			nRuleLen = len(paoRules)
			for j = 1 to nRuleLen
				if paoRules[j].Matches(aContext)
					if find(acAffected, acEdgeKeys[i]) = 0
						acAffected + acEdgeKeys[i]
					ok
					exit
				ok
			end
		end
		
		return acAffected
	
		def EdgesAffectedByTheseVRules(paoRules)
			return This.EdgesAffectedByTheseVisualRules(paoRules)
	
	#-------------------------------------------#
	#  4. ELEMENTS WITH THEIR RULES (DETAILED)  #
	#-------------------------------------------#
	
	# Get nodes paired with their affecting rules
	# Returns: [ ["node1", [oRule1, oRule2]], ["node2", [oRule3]], ... ]
	def NodesAndTheirVisualRulesObjects()
		aResult = []
		acNodeIds = keys(@aNodeEnhancements)
		nLen = len(acNodeIds)
		
		for i = 1 to nLen
			cNodeId = acNodeIds[i]
			aNode = This.Node(cNodeId)
			aContext = This._BuildRuleContext(aNode)
			
			aoMatchingRules = []
			nRuleLen = len(@aoVisualRules)
			for j = 1 to nRuleLen
				if @aoVisualRules[j].Matches(aContext)
					aoMatchingRules + @aoVisualRules[j]
				ok
			end
			
			if len(aoMatchingRules) > 0
				aResult + [cNodeId, aoMatchingRules]
			ok
		end
		
		return aResult
	
		def NodesAndTheirVRulesObjects()
			return This.NodesAndTheirVisualRulesObjects()
	
	# Get edges paired with their affecting rules
	# Returns: [ ["node1->node2", [oRule1]], ["node2->node3", [oRule2, oRule3]], ... ]
	def EdgesAndTheirVisualRulesObjects()
		aResult = []
		acEdgeKeys = keys(@aEdgeEnhancements)
		nLen = len(acEdgeKeys)
		
		for i = 1 to nLen
			cEdgeKey = acEdgeKeys[i]
			acParts = split(cEdgeKey, "->")
			aEdge = This.Edge(acParts[1], acParts[2])
			aContext = This._BuildRuleContext(aEdge)
			
			aoMatchingRules = []
			nRuleLen = len(@aoVisualRules)
			for j = 1 to nRuleLen
				if @aoVisualRules[j].Matches(aContext)
					aoMatchingRules + @aoVisualRules[j]
				ok
			end
			
			if len(aoMatchingRules) > 0
				aResult + [cEdgeKey, aoMatchingRules]
			ok
		end
		
		return aResult
	
		def EdgesAndTheirVRulesObjects()
			return This.EdgesAndTheirVisualRulesObjects()
	
	# Get both nodes and edges with their rules
	def ElementsAndTheirVisualRulesObjects()
		return [
			:nodes = This.ElementsAndTheirVisualRulesObjects(),
			:edges = This.ElementsAndTheirVisualRulesObjects()
		]
	
		def ElementsAndTheirVRulesObjects()
			return This.ElementsAndTheirVisualRulesObjects()
	
	#--------------------------------------------#
	#  5. ELEMENTS WITH RULE IDS (STRING-FRIST)  #
	#--------------------------------------------#
	
	# Get nodes paired with rule IDs (not objects)
	# Returns: [ ["node1", ["cheap", "prod"]], ["node2", ["expensive"]], ... ]
	def NodesAndTheirVisualRules()
		aResult = []
		acNodeIds = keys(@aNodeEnhancements)
		nLen = len(acNodeIds)
		
		for i = 1 to nLen
			cNodeId = acNodeIds[i]
			aNode = This.Node(cNodeId)
			aContext = This._BuildRuleContext(aNode)
			
			acRuleIds = []
			nRuleLen = len(@aoVisualRules)
			for j = 1 to nRuleLen
				if @aoVisualRules[j].Matches(aContext)
					acRuleIds + @aoVisualRules[j].@cRuleId
				ok
			end
			
			if len(acRuleIds) > 0
				aResult + [cNodeId, acRuleIds]
			ok
		end
		
		return aResult
	
		def NodesAndTheirVRules()
			return This.NodesAndTheirVisualRules()
	
	# Get edges paired with rule IDs
	def EdgesAndThirVisualRules()
		aResult = []
		acEdgeKeys = keys(@aEdgeEnhancements)
		nLen = len(acEdgeKeys)
		
		for i = 1 to nLen
			cEdgeKey = acEdgeKeys[i]
			acParts = split(cEdgeKey, "->")
			aEdge = This.Edge(acParts[1], acParts[2])
			aContext = This._BuildRuleContext(aEdge)
			
			acRuleIds = []
			nRuleLen = len(@aoVisualRules)
			for j = 1 to nRuleLen
				if @aoVisualRules[j].Matches(aContext)
					acRuleIds + @aoVisualRules[j].@cRuleId
				ok
			end
			
			if len(acRuleIds) > 0
				aResult + [cEdgeKey, acRuleIds]
			ok
		end
		
		return aResult
	
		def EdgesAndThirVRules()
			return This.EdgesAndThirVisualRules()
	
	# Get both with rule IDs
	def ElementsAndTheirVisualRules()
		return [
			:nodes = This.NodesAndTheirVisualRules(),
			:edges = This.EdgesAndTheirvisualRules()
		]
	
		def ElementsAndTheirVRules()
			return This.ElementsAndTheirVisualRules()
	
	#------------------------------------------#
	#  6. RULES WITH THEIR ELEMENTS (INVERSE)  #
	#------------------------------------------#
	
	# Get each rule with the elements it affected
	# Returns: [ [oRule1, [:nodes = [...], :edges = [...]]], [oRule2, ...], ... ]
	def VisualRulesObjectsAndTheirElements()
		aResult = []
		nRuleLen = len(@aoVisualRules)
		
		for i = 1 to nRuleLen
			oRule = @aoVisualRules[i]
			
			acAffectedNodes = This.NodesAffectedByVisualRule(oRule)
			acAffectedEdges = This.EdgesAffectedByVisualRule(oRule)
			
			if len(acAffectedNodes) > 0 or len(acAffectedEdges) > 0
				aResult + [
					oRule,
					[:nodes = acAffectedNodes, :edges = acAffectedEdges]
				]
			ok
		end
		
		return aResult
	
		def VRulesObjectsAndTheirElements()
			return This.VisualRulesObjectsAndTheirElements()
	
	# Get rule IDs with their elements
	def VisualRulesAndTheirElements()
		aResult = []
		nRuleLen = len(@aoVisualRules)
		
		for i = 1 to nRuleLen
			oRule = @aoVisualRules[i]
			
			acAffectedNodes = This.NodesAffectedByVisualRule(oRule)
			acAffectedEdges = This.EdgesAffectedByVisualRule(oRule)
			
			if len(acAffectedNodes) > 0 or len(acAffectedEdges) > 0
				aResult + [
					oRule.@cRuleId,
					[:nodes = acAffectedNodes, :edges = acAffectedEdges]
				]
			ok
		end
		
		return aResult
	
		def VRulesAndTheirElements()
			return This.VisualRulesAndTheirElements()
	
	# Get complete analysis of rules and their impact
	def VisualRulesApplied()
		aResult = [
			:hasEffects = FALSE,
			:summary = "",
			:rules = []
		]
		
		bHasEffects = (len(@aNodeEnhancements) > 0 or len(@aEdgeEnhancements) > 0)
		aResult[:hasEffects] = bHasEffects
		
		if NOT bHasEffects
			aResult[:summary] = "No rules matched any elements."
			return aResult
		ok
		
		aResult[:summary] = ""+ len(@aoVisualRules) +
				    " rule(s) defined, " + 
		                     (len(@aNodeEnhancements) + len(@aEdgeEnhancements)) + " element(s) affected"
		
		nLenRules = len(@aoVisualRules)
		for i = 1 to nLenRules
			oRule = @aoVisualRules[i]
			
			acAffectedNodes = This.NodesAffectedByVisualRule(oRule)
			acAffectedEdges = This.EdgesAffectedByVisualRule(oRule)
			
			bRuleMatched = (len(acAffectedNodes) > 0 or len(acAffectedEdges) > 0)
			
			if bRuleMatched
				aRuleInfo = [
					:id = oRule.@cRuleId,
					:condition = oRule.@cConditionType,
					:conditionParams = oRule.@aConditionParams,
					:effects = oRule.Effects(),
					:affectedNodes = acAffectedNodes,
					:affectedEdges = acAffectedEdges,
					:matchCount = len(acAffectedNodes) + len(acAffectedEdges)
				]
				aResult[:rules] + aRuleInfo
			ok
		end
		
		return aResult
	
		def VRulesApplied()
			return This.VisualRulesApplied()

	#---------------------------------------#
	#  HELPER: Build rule matching context  #
	#---------------------------------------#
	
	def _BuildRuleContext(aNodeOrEdge)
		aContext = aNodeOrEdge
		
		if HasKey(aNodeOrEdge, "properties") and aNodeOrEdge["properties"] != NULL
			aContext["metadata"] = aNodeOrEdge["properties"]
			aContext["tags"] = []
			if HasKey(aNodeOrEdge["properties"], "tags")
				aContext["tags"] = aNodeOrEdge["properties"]["tags"]
			ok
		ok
		
		return aContext

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
	

#==========================================#
#  stzDiagramAnnotator - METADATA OVERLAY  #
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

#===============================================#
#  stzDiagramValidators - PLUGGABLE VALIDATORS  #
#===============================================#

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


#===========================================#
#  stzDiagramSoxValidator - SARBANES-OXLEY  #
#===========================================#

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

#==================================#
#  stzDiagramGdprValidator - GDPR  #
#==================================#

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

#===============================================#
#  stzDiagramBankingValidator - CUSTOM BANKING  #
#===============================================#

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

		cOutput += "metadata" + NL
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
		if len(@oDiagram.@aVisualRules) > 0
			@oDiagram.ApplyVisualRules()
		ok
		
		# Get theme
		cTheme = This._GetTheme()
		
		# Start digraph
		cOutput += 'digraph "' + @oDiagram.Id() + '" {' + NL
		
		# Graph attributes
		cOutput += This._GenerateGraphAttributes(cTheme)
		
		# Add title/subtitle if present

		if @oDiagram.@bTitleVisibility = TRUE
		    if @oDiagram.Title() != ""
		        cOutput += '    labelloc="t";'
		        cTitle =NL +  @oDiagram.Title()
		        if @oDiagram.Subtitle() != ""
		            cTitle += NL + @oDiagram.Subtitle() + NL
		        ok
			cTitle += NL + NL
		        cOutput += '    label="' + cTitle + '";' + NL
		        cOutput += '    fontsize=16;' + NL + NL
		    ok
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
		if cTheme = "" or cTheme = NULL
			cTheme = "light"
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
	               ', ordering=out'  # Preserve edge order
	    
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
	    
	    aAppliedRules = []
	    if HasKey(@oDiagram.@aNodesAffectedByRules, aNode["id"])
	        aAppliedRules = @oDiagram.@aNodesAffectedByRules[aNode["id"]]
	    ok
	    
	    cShape = This._GetNodeShape(aNode, aAppliedRules)
	    cStyle = This._GetNodeStyle(aNode, aAppliedRules)
	    
	    cOutput = '    ' + cNodeId + ' [label="' + cLabel + '"'
	    cOutput += ', shape=' + cShape
	    cOutput += ', style="' + cStyle + '"'
	    
	    # ORG CHART POSITION NODES
	if HasKey(aNode["properties"], "positiontype") and 
	   aNode["properties"]["positiontype"] = "position"
	    
	    cFillColor = ResolveColor(aNode["properties"]["color"])
	    cOutput += ', style="rounded,solid,filled"'
	    cOutput += ', fillcolor="' + cFillColor + '"'
	    cOutput += ', fontcolor="' + @oDiagram.ResolveFontColor(cFillColor) + '"'
	    
	    # Use diagram's stroke color setting
	    cStrokeColor = @oDiagram.@cNodeStrokeColor
	    if cStrokeColor = '' or cStrokeColor = "invisible"
	        cStrokeColor = cFillColor
	    ok
	    cOutput += ', color="' + ResolveColor(cStrokeColor) + '"'
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
		
		# Check node properties FIRST (where rules write to)
		if HasKey(aNode, "properties") and aNode["properties"] != NULL and 
		   HasKey(aNode["properties"], "color") and aNode["properties"]["color"] != NULL
			cColor = aNode["properties"]["color"]
		ok

		if cColor = '' and HasKey(@oDiagram.@aNodesAffectedByRules, "color")
			cColor = @oDiagram.@aNodesAffectedByRules["color"]
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
	    cEdgeKey = aEdge["from"] + "->" + aEdge["to"]
	    
	    cOutput = '    ' + cFrom + ' -> ' + cTo
	    aAttrs = []
	    
	    # Check if this is a supervisor→helper edge
	    if left(cTo, 8) = "_helper_"
	        aAttrs + 'arrowhead=none'
	        aAttrs + 'weight=10'
	    ok
	    
	    if HasKey(aEdge, "label") and aEdge["label"] != "" and aEdge["label"] != NULL
	        aAttrs + ('label="' + aEdge["label"] + '"')
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


class stzDiagramRule from stzVisualRule
class stzVisualRule from stzGraphRule
	
	def init(pcRuleId)
		super.init(pcRuleId)
		@cRuleType = "visual"
	
	#------------------#
	#  VISUAL EFFECTS  #
	#------------------#
	
	def ApplyColor(pColor)
		This.Apply("color", pColor)
	
	def ApplyShape(pcShape)
		This.Apply("shape", pcShape)
	
	def ApplyStyle(pcStyle)
		This.Apply("style", pcStyle)
	
	def ApplyPenWidth(nWidth)
		This.Apply("penwidth", nWidth)
	
	def ApplyFillColor(pColor)
		This.Apply("fillcolor", pColor)
	
	def ApplyStrokeColor(pColor)
		This.Apply("strokecolor", pColor)
	
	def ApplyFontColor(pColor)
		This.Apply("fontcolor", pColor)
	
	def ApplyFontSize(nSize)
		This.Apply("fontsize", nSize)
	
	def ApplyArrowHead(pcStyle)
		This.Apply("arrowhead", pcStyle)
	
	def ApplyArrowTail(pcStyle)
		This.Apply("arrowtail", pcStyle)
	
	def ApplyLabel(pcLabel)
		This.Apply("label", pcLabel)
	
	def ApplyTooltip(pcTooltip)
		This.Apply("tooltip", pcTooltip)

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
