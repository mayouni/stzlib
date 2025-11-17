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
$cDefaultNodeColor = :blue

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
	
	# Add base colors
	for cKey in keys($acColors)
		cHex = $acColors[cKey]
		aPalette[cKey] = cHex
	end
	
	# Add all intensity variations
	for cKey in keys($acColors)
		cHex = $acColors[cKey]
		cColorName = "" + cKey
		aIntensities = GenerateColorIntensities(cColorName, cHex)
		
		for cIntensityKey in keys(aIntensities)
			aPalette[cIntensityKey] = aIntensities[cIntensityKey]
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
		cBaseKey = left(cColorKey, len(cColorKey) - 2)
	but right(cColorKey, 1) = "+" or right(cColorKey, 1) = "-"
		cIntensity = right(cColorKey, 1)
		cBaseKey = left(cColorKey, len(cColorKey) - 1)
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

func ResolveNodeType(pType)
	cTypeKey = lower("" + pType)
	
	# DOT shapes pass through unchanged
	aDotShapes = ["box", "ellipse", "circle", "diamond", "parallelogram", 
	              "hexagon", "octagon", "cylinder", "pentagon", "septagon",
	              "trapezium", "invtrapezium", "triangle", "house", "invtriangle",
	              "doublecircle", "tripleoctagon"]
	
	if ring_find(aDotShapes, cTypeKey) > 0
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
	@aAnnotations = []
	@aTemplates = []

	@cEdgeColor = ResolveColor(@cDefaultEdgeColor)
	@cNodeStrokeColor = ""

	@aPalette = $aPalette
	@aFontColors = $aFontColors

	@cEdgeStyle = $cDefaultEdgeStyle

	@cFont = $cDefaultFont
	@nFontSize = $cDefaultFontSize

	@aVisualRules = []
	@aMetadataKeys = []

	@aNodeMetadata = []
	@aNodeTags = []
	@aNodeEnhancements = []
	
	@aEdgeMetadata = []
	@aEdgeTags = []
	@aEdgeEnhancements = []

	# Validation state
	@cLastValidator = ""
	@aLastValidationResult = []
	
	def init(pTitle)
		super.init(pTitle)

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
	
	def VisualRules()
		return @aVisualRules
	
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

	#------------------------------------------
	#  DIAGRAM-SPECIFIC NODE OPERATIONS
	#------------------------------------------

	def AddNode(pNodeId, pLabel)
		This.AddNodeXT(pNodeId, pLabel, $cDefaultNodeType, $cDefaultNodeColor)

	def AddNodeXT(pNodeId, pLabel, pType, pColor)
		cResolvedType = ResolveNodeType(pType)
		# Store color name, not hex - resolve later during visualization
		cResolvedColor = pColor
		if substr(pColor, "#")
			cResolvedColor = pColor  # Already hex, keep it
		ok
		
		super.AddNodeXTT(pNodeId, pLabel, [
			:type = cResolvedType,
			:color = cResolvedColor  # Store as-is
		])

	def Connect(pFromId, pToId)
		This.ConnectXT(pFromId, pToId, "")

	def ConnectXT(pFromId, pToId, pLabel)
		This.AddEdgeXT(pFromId, pToId, pLabel)

	def ConnectXTT(pFromId, pToId, pLabel, pStyle)
		cResolvedStyle = ResolveEdgeStyle(pStyle)
		This.AddEdgeXTT(pFromId, pToId, pLabel, [:style = cResolvedStyle])

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
		@aAnnotations + oAnnotation

	def AnnotationsByType(pType)
		aFiltered = []

		for oAnn in @aAnnotations
			if oAnn.Type() = pType
				aFiltered + oAnn
			ok
		end
		return aFiltered

	def Annotations()
		return @aAnnotations

	#------------------------------------------
	#  TEMPLATE OPERATIONS
	#------------------------------------------

	def AddTemplate(oTemplate)
		@aTemplates + oTemplate

	def ApplyTemplates()
		for oTemplate in @aTemplates
			oTemplate.Apply(This)
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
		aStartNodes = This.NodesByType("start")
		aEndpointNodes = This.NodesByType("endpoint")
		aIssues = []
	
		for cEndpoint in aEndpointNodes
			bReachable = FALSE
			for cStart in aStartNodes
				if This.PathExists(cStart, cEndpoint)
					bReachable = TRUE
					exit
				ok
			end
			if NOT bReachable
				aIssues + "Endpoint unreachable: " + cEndpoint
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
		aDecisions = This.NodesByType("decision")
	
		for cNodeId in aDecisions
			if len(This.Neighbors(cNodeId)) < 2
				aIssues + "Decision node has fewer than 2 paths: " + cNodeId
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
	
	def ValidationStatus()
		if len(@aLastValidationResult) = 0
			return ""
		ok
		return @aLastValidationResult["status"]
	
	def ValidationDomain()
		if len(@aLastValidationResult) = 0
			return ""
		ok
		return @aLastValidationResult["domain"]
	
	def ValidationIssueCount()
		if len(@aLastValidationResult) = 0
			return 0
		ok
		return @aLastValidationResult["issueCount"]
	
	def ValidationIssues()
		if len(@aLastValidationResult) = 0
			return []
		ok
		return @aLastValidationResult["issues"]
	
	def HasValidationIssues()
		return This.ValidationIssueCount() > 0

	#------------------------------------------
	#  METRICS
	#------------------------------------------

	def ComputeMetrics()
		aMetrics = []
		aAllPaths = []

		for aNode in This.Nodes()
			aReachable = This.ReachableFrom(aNode["id"])
			if len(aReachable) > 1
				aAllPaths + (len(aReachable) - 1)
			ok
		end

		nAvg = 0
		if len(aAllPaths) > 0
			nSum = 0
			for nLen in aAllPaths
				nSum += nLen
			end
			nAvg = nSum / len(aAllPaths)
		ok

		nMax = 0
		for nLen in aAllPaths
			if nLen > nMax
				nMax = nLen
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
		aBase["annotations"] = @aAnnotations
		aBase["templates"] = @aTemplates
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
		@aVisualRules + oRule

	
	def AddNodeWithMetaData(pNodeId, pLabel, pType, pColor, aMetadata, aTags)
		This.AddNodeXT(pNodeId, pLabel, pType, pColor)
		
		if NOT isList(aMetadata)
			aMetadata = []
		ok
		
		@aNodeMetadata[pNodeId] = aMetadata
		@aNodeTags[pNodeId] = aTags
		
		if @IsHashList(aMetadata)
			@aMetadataKeys = @Keys(aMetadata)
		ok

	def AddEdgeWithMetaData(pFromId, pToId, pLabel, aMetadata, aTags)
		This.ConnectXT(pFromId, pToId, pLabel)
		
		if NOT isList(aMetadata)
			aMetadata = []
		ok
		
		if NOT isList(aTags)
			aTags = []
		ok
		
		cEdgeKey = pFromId + "->" + pToId
		@aEdgeMetadata[cEdgeKey] = aMetadata
		@aEdgeTags[cEdgeKey] = aTags
	

	def ApplyVisualRules()
		# Process nodes
		aNodes = This.Nodes()
		
		for i = 1 to len(aNodes)
			aNode = aNodes[i]
			cNodeId = aNode["id"]
			
			# Restore metadata/tags from storage
			aNode["metadata"] = This.GetNodeMetadata(cNodeId)
			
			if HasKey(@aNodeTags, cNodeId)
				aNode["tags"] = @aNodeTags[cNodeId]
			else
				aNode["tags"] = []
			ok
			
			if NOT HasKey(aNode, "properties")
				aNode["properties"] = []
			ok
	   
			# Apply matching rules
			for oRule in @aVisualRules
				if oRule.Matches(aNode)
					aEffects = oRule.Effects()
					for aEffect in aEffects
						cAspect = aEffect[1]
						pValue = aEffect[2]
						aNode["properties"][cAspect] = pValue
					end
				ok
			end
			
			# Store computed enhancements
			@aNodeEnhancements[cNodeId] = aNode["properties"]
		end
		
		# Process edges
		aEdges = This.Edges()
		
		for i = 1 to len(aEdges)
			aEdge = aEdges[i]
			cEdgeKey = aEdge["from"] + "->" + aEdge["to"]
			
			# Restore metadata/tags from storage
			aEdge["metadata"] = This.GetEdgeMetadata(aEdge["from"], aEdge["to"])
			
			if HasKey(@aEdgeTags, cEdgeKey)
				aEdge["tags"] = @aEdgeTags[cEdgeKey]
			else
				aEdge["tags"] = []
			ok
			
			if NOT HasKey(aEdge, "properties")
				aEdge["properties"] = []
			ok
			
			# Apply matching rules
			for oRule in @aVisualRules
				if oRule.Matches(aEdge)
					aEffects = oRule.Effects()
					for aEffect in aEffects
						cAspect = aEffect[1]
						pValue = aEffect[2]
						aEdge["properties"][cAspect] = pValue
					end
				ok
			end
			
			# Store computed enhancements
			@aEdgeEnhancements[cEdgeKey] = aEdge["properties"]
		end
		
	def MetadataLegend()
		# Generate legend showing metadata-to-visual mappings
		aLegend = []
		
		aLegend + "=== METADATA LEGEND ==="
		aLegend + ""
		
		for oRule in @aVisualRules
			cDesc = "When: " + oRule.@cConditionType
			aLegend + cDesc
			
			aEffects = oRule.Effects()
			for aEffect in aEffects
				aLegend + "  → " + aEffect[1] + ": " + aEffect[2]
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
		aLines = @split(cDiagString, NL)
		bInNodesSection = FALSE
		
		for cLine in aLines
			cLine = trim(cLine)
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
		
		aNodes = oTemp.Nodes()
		aEdges = oTemp.Edges()
		
		# Add all nodes EXCEPT the parent (which already exists)
		for aNode in aNodes
			if aNode["id"] != cParentNodeId
				This.AddNodeXT(aNode["id"], aNode["label"], 
					aNode["properties"]["type"], 
					aNode["properties"]["color"])
			ok
		end
		
		# Add all edges
		for aEdge in aEdges
			cFrom = aEdge["from"]
			cTo = aEdge["to"]
			
			# All edges are added normally since parent node exists
			This.Connect(cFrom, cTo)
		end
	
	def ParseAndImport(cDiagString)
		aLines = split(cDiagString, NL)
		cCurrentSection = ""
		cCurrentNode = ""
		cLabel = ""
		cType = ""
		cColor = ""
		aEdgesToAdd = []  # Store edges for later
		
		for cLine in aLines
			cLineTrimmed = trim(cLine)
			if cLineTrimmed = "" or left(cLineTrimmed, 1) = "#"
				loop
			ok
			cLine = cLineTrimmed
			
			if substr(cLine, "diagram ")
				cTitle = trim(@substr(cLine, 10, len(cLine)-1))			
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
					cLabel = @substr(cLine, 8, len(cLine))
					cLabel = This.UnescapeString(cLabel)
				but substr(cLine, "type:")
					cType = trim(@substr(cLine, 7, len(cLine)))
				but substr(cLine, "color:")
					cColor = trim(@substr(cLine, 8, len(cLine)))
				ok
				
			but cCurrentSection = "edges" and substr(cLine, "->")
				aEdgeParts = split(cLine, "->")
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
		for aEdge in aEdgesToAdd
			This.Connect(aEdge[1], aEdge[2])
		end
	

#=====================================================
#  stzDiagramAnnotator - METADATA OVERLAY
#=====================================================

class stzDiagramAnnotator

	@cType = ""
	@aNodeData = []

	def init(pType)
		@cType = pType

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
		aFinancialNodes = oDiag.NodesByProperty("domain", "financial")
		for cNodeId in aFinancialNodes
			aAnnPerf = oDiag.AnnotationsByType("performance")
			bHasAudit = 0

			for aAnnot in aAnnPerf
				aData = aAnnot.NodeData(cNodeId)
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
		aDec = oDiag.NodesByType("decision")
		for cNodeId in aDec
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

		@aValidationResult = [
			:status = iif(len(aIssues) = 0, "pass", "fail"),
			:domain = "sox",
			:issueCount = len(aIssues),
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

		@aValidationResult = [
			:status = iif(len(aIssues) = 0, "pass", "fail"),
			:domain = "gdpr",
			:issueCount = len(aIssues),
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

		@aValidationResult = [
			:status = iif(len(aIssues) = 0, "pass", "fail"),
			:domain = "banking",
			:issueCount = len(aIssues),
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
			cResult = Left(cResult, len(cResult) - 2)
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
			cResult = Left(cResult, len(cResult) - 2)
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
		if len(@oDiagram.@aVisualRules) > 0
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
		
		cResult =  '    graph [rankdir=' + cRankDir +
			   ', bgcolor=white, fontname="' +
			   cFont + '", fontsize=' + nFontSize + ']' + NL

		return cResult

	def _GenerateNodeAttributes(cTheme)
		cFont = This._GetFont()
		nFontSize = This._GetFontSize()
		
		cResult = '    node [fontname="' + cFont + '", fontsize=' +
			  nFontSize + ']' + NL
	
		return cResult

	def _GenerateEdgeAttributes(cTheme)
		cFont = This._GetFont()
		nFontSize = This._GetFontSize()
		cEdgeColor = This._GetEdgeColor(cTheme)
		cEdgeStyle = This._GetEdgeStyle()
		
		cResult = '    edge [fontname="' + cFont + '", fontsize=' +
			  nFontSize + ', color="' + cEdgeColor + '", style=' +
			  cEdgeStyle + ']' + NL

		return cResult
	
	def _GetRankDir()
		cLayout = lower(@oDiagram.@cLayout)
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
		cEdgeColor = ResolveColor(@oDiagram.@cEdgeColor)
		
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
			return @substr(cNodeId, 2, len(cNodeId))
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
		aDotShapes = ["box", "ellipse", "circle", "diamond", "parallelogram", 
		              "hexagon", "octagon", "cylinder", "rect", "square", 
		              "doublecircle", "tripleoctagon", "invtriangle", "house",
		              "pentagon", "septagon", "trapezium", "invtrapezium",
		              "triangle", "egg", "tab", "folder", "component", "note"]
		
		if ring_find(aDotShapes, cType) > 0
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
		
		# Polygon shapes don't support rounded
		aPolygonShapes = ["hexagon", "octagon", "parallelogram", "pentagon", 
		                  "septagon", "trapezium", "invtrapezium", "triangle",
		                  "house", "invtriangle", "diamond"]
		
		if ring_find(aPolygonShapes, cShape) > 0
			return "filled"
		ok
		
		# Default: rounded for box-like shapes
		return "rounded,filled"
	
	def _GetNodeFillColor(aNode, aEnhancements, cTheme)
		cColor = ""
		
		# Check enhancements first
		if HasKey(aEnhancements, "color")
			cColor = aEnhancements["color"]
		ok
		
		# Then node properties
		if cColor = "" or cColor = NULL
			if HasKey(aNode, "properties") and aNode["properties"] != NULL and 
			   HasKey(aNode["properties"], "color") and aNode["properties"]["color"] != NULL
				cColor = aNode["properties"]["color"]
			ok
		ok
		
		# Default
		if cColor = "" or cColor = NULL
			cColor = $cDefaultNodeColor
		ok
		
		# If already hex, skip theme mapping
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
			
			# Direct palette key match
			if HasKey(aThemePalette, cLowerColor)
				cColor = ResolveColor(aThemePalette[cLowerColor])
			ok
		ok
		
		# Fallback: resolve normally
		if NOT substr(cColor, "#")
			cColor = ResolveColor(cColor)
		ok
		
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
		
		for aEdge in @oDiagram.Edges()
			cOutput += This._GenerateEdge(aEdge, cTheme)
		end
		
		return cOutput
	
	def _GenerateEdge(aEdge, cTheme)
		cFrom = This._SanitizeNodeId(aEdge["from"])
		cTo = This._SanitizeNodeId(aEdge["to"])
		cEdgeKey = aEdge["from"] + "->" + aEdge["to"]
		
		cOutput = '    ' + cFrom + ' -> ' + cTo
		
		# Get enhancements
		aEnhancements = []
		if HasKey(@oDiagram.@aEdgeEnhancements, cEdgeKey)
			aEnhancements = @oDiagram.@aEdgeEnhancements[cEdgeKey]
		ok
		
		# Build attributes
		aAttrs = []
		
		# Label
		if HasKey(aEdge, "label") and aEdge["label"] != "" and aEdge["label"] != NULL
			aAttrs + ('label=" ' + aEdge["label"] + '"')
		ok
		
		# Style
		if HasKey(aEnhancements, "style")
			aAttrs + ('style="' + aEnhancements["style"] + '"')
		ok
		
		# Color
		if HasKey(aEnhancements, "color")
			cColor = ResolveColor(aEnhancements["color"])
			aAttrs + ('color="' + cColor + '"')
		ok
		
		# Pen width
		if HasKey(aEnhancements, "penwidth")
			aAttrs + ('penwidth=' + aEnhancements["penwidth"])
		ok
		
		# Arrow head
		if HasKey(aEnhancements, "arrowhead")
			aAttrs + ('arrowhead=' + aEnhancements["arrowhead"])
		ok
		
		# Add attributes
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
				This.WhenMetadataInRange(pcKey, pValue[1], pValue[2])
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
			return FALSE
		
		on :metadata_equals
			cKey = @aConditionParams[1]
			pValue = @aConditionParams[2]
			if HasKey(aNodeOrEdge, "metadata") and HasKey(aNodeOrEdge["metadata"], cKey)
				return aNodeOrEdge["metadata"][cKey] = pValue
			ok
			return FALSE
		
		on :metadata_range
			cKey = @aConditionParams[1]
			nMin = @aConditionParams[2]
			nMax = @aConditionParams[3]
			if HasKey(aNodeOrEdge, "metadata") and HasKey(aNodeOrEdge["metadata"], cKey)
				nValue = aNodeOrEdge["metadata"][cKey]
				return nValue >= nMin and nValue <= nMax
			ok
			return FALSE
		
		on :tag_exists
			cTag = @aConditionParams[1]

			if HasKey(aNodeOrEdge, "tags")
				return ring_find(aNodeOrEdge["tags"], cTag) > 0
			ok
			return FALSE
		off
		
		return FALSE
	
	def Effects()
		return @aVisualEffects


	def RemoveAllNodes()
		super.RemoveAllNodes()
		@aNodeMetadata = []
		@aNodeTags = []
		@aNodeEnhancements = []
		@aEdgeMetadata = []
		@aEdgeTags = []
		@aEdgeEnhancements = []


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
