#=====================================================
#  stzDiagram - DOMAIN SPECIALIZATION OF stzGraph
#  Workflows, org charts, semantic diagrams
#=====================================================

#  GLOBAL REGISTRY
#==================

$aDiagramValidators = [
	:SOX = new stzDiagramSoxValidator(),
	:GDPR = new stzDiagramGdprValidator(),
	:Banking = new stzDiagramBankingValidator()
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
@cDefaultNodeType = "process"
@cDefaultNodeColor = :blue

# Edge styles
$acEdgeStyles = [
	:Normal = "solid",
	:Conditional = "dashed",
	:ErrorFlow = "dotted",
	:MessageFlow = "bold"
]

@cDefaultEdgeStyle = "normal"
@cDefaultEdgeColor = "black"

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

@cDefaultTheme = "light"

# LAYOUT
$acLayouts = [
	:TopDown = [ "tb", "td", "topbottom", "ud", "updown", "ub", "upbottom" ],
	:BottomUp = [ "bt", "dt", "bottomtop", "du", "downup", "bu", "bottomup" ],
	:LeftRight = [ "lr" ],
	:RightLeft = [ "rl" ]
]

@cDefaultLayout = "topdown"

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

@cDefaultFont = "helvetica"
@cDefaultFontSize = 12

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

# PALETTE AND FONT COLORS (will be populated after ResolveColor is defined)

$aPalette = []

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
	
	if HasKey($acFullColorPalette, cColorKey)
		return $acFullColorPalette[cColorKey]
	ok
	
	if HasKey($acColorsBySemanticMeaning, cColorKey)
		cBaseColor = "" + $acColorsBySemanticMeaning[cColorKey]
		return ResolveColor(cBaseColor)
	ok
	
	if HasKey($acColorsByNodeType, cColorKey)
		cBaseColor = "" + $acColorsByNodeType[cColorKey]
		return ResolveColor(cBaseColor)
	ok
	
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
	
	return @cDefaultEdgeStyle

func ResolveNodeType(pType)
	cTypeKey = lower("" + pType)
	
	if ring_find($acNodeTypes, cTypeKey)
		return cTypeKey
	ok
	
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
	
	return @cDefaultNodeType

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
	return @cDefaultNodeType

func NodeTypes()
	return $acNodeTypes

func IsValidNodeType(pcType)
	return ring_find($acNodeTypes, pcType) > 0

func DefaultNodeColor()
	return ResolveColor(@cDefaultNodeColor)

func ColorForNodeType(pcType)
	if HasKey($acColorsByNodeType, pcType)
		return ResolveColor($acColorsByNodeType[pcType])
	ok
	return ResolveColor(@cDefaultNodeColor)

# EDGE STYLE FUNCTIONS

func IsValidEdgeStyle(pcStyle)
	return HasKey($acEdgeStyles, pcStyle)

func EdgeStyles()
	return $acEdgeStyles

func DefaultEdgeStyle()
	return @cDefaultEdgeStyle

func StyleForEdgeType(pcType)
	if HasKey($acEdgeStyles, pcType)
		return $acEdgeStyles[pcType]
	ok
	return @cDefaultEdgeStyle

# VALIDATOR FUNCTION

func DiagramValidators()
	return $aDiagramValidators

# =====================================================
#  stzDiagram Class - Main Diagram Implementation
# =====================================================

class stzDiagram from stzGraph

	@cTheme = @cDefaultTheme
	@cLayout = @cDefaultLayout
	@aClusters = []
	@aAnnotations = []
	@aTemplates = []

	@cEdgeColor = ResolveColor(@cDefaultEdgeColor)
	@cNodeStrokeColor = ""

	@aPalette = $aPalette
	@aFontColors = $aFontColors

	@cEdgeStyle = @cDefaultEdgeStyle

	@cFont = @cDefaultFont
	@nFontSize = @cDefaultFontSize

	@aVisualRules = []
	@aMetadataKeys = []

	@aNodeMetadata = []
	@aNodeTags = []
	@aNodeEnhancements = []
	
	@aEdgeMetadata = []
	@aEdgeTags = []
	@aEdgeEnhancements = []

	def init(pTitle)
		super.init(pTitle)

	def SetTheme(pTheme)
		cThemeKey = lower(pTheme)
		
		if cThemeKey = "professional"
			cThemeKey = "pro"
		ok
		
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
	
	#------------------------------------------
	#  COLOR RESOLUTION
	#------------------------------------------

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

	def GetNodeStrokeColor(cTheme)
		if cTheme = "print" or cTheme = "gray"
			return "black"
		ok
		return ""

	def ConvertColorTogray(cColor)
		aRGB = This.ColorToRGB(cColor)
		nR = aRGB[1]
		nG = aRGB[2]
		nB = aRGB[3]
		
		# Use perceptual brightness formula
		nGray = floor(0.299 * nR + 0.587 * nG + 0.114 * nB)
		
		# Use global helper
		return RGBToHex(nGray, nGray, nGray)

	#------------------------------------------
	#  DIAGRAM-SPECIFIC NODE OPERATIONS
	#------------------------------------------

	def AddNode(pNodeId, pLabel)
		This.AddNodeXT(pNodeId, pLabel, @cDefaultNodeType, @cDefaultNodeColor)

	def AddNodeXT(pNodeId, pLabel, pType, pColor)
		cResolvedType = ResolveNodeType(pType)
		# Store color as-is if it's already hex, otherwise resolve
		cResolvedColor = pColor
		if NOT substr(pColor, "#")
			cResolvedColor = ResolveColor(pColor)
		ok
		
		super.AddNodeXTT(pNodeId, pLabel, [
			:type = cResolvedType,
			:color = cResolvedColor
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

	def ValidateDAG()
		return NOT This.CyclicDependencies()

	def ValidateReachability()
		aStartNodes = []
		aEndpointNodes = []

		for aNode in This.Nodes()
			if aNode["properties"]["type"] = :Start
				aStartNodes + aNode["id"]
			ok
			if aNode["properties"]["type"] = :Endpoint
				aEndpointNodes + aNode["id"]
			ok
		end

		for cEndpoint in aEndpointNodes
			bReachable = 0
			for cStart in aStartNodes
				if This.PathExists(cStart, cEndpoint)
					bReachable = 1
					exit
				ok
			end
			if NOT bReachable
				return [
					:status = "fail",
					:issue = "Endpoint unreachable: " + cEndpoint
				]
			ok
		end

		return [ :status = "pass" ]

	def ValidateCompleteness()
		aIssues = []

		for aNode in This.Nodes()
			if aNode["properties"]["type"] = "decision"
				aNeighbors = This.Neighbors(aNode["id"])
				if len(aNeighbors) < 2
					aIssues + "Decision node has fewer than 2 paths: " + aNode["id"]
				ok
			ok
		end

		return [
			:status = iif(len(aIssues) = 0, "pass", "fail"),
			:issues = aIssues
		]

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
			This.Show()
		
		def Visualize()
			This.Show()

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
			if HasKey(@aNodeMetadata, cNodeId)
				aNode["metadata"] = @aNodeMetadata[cNodeId]
			else
				aNode["metadata"] = []
			ok
			
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
			if HasKey(@aEdgeMetadata, cEdgeKey)
				aEdge["metadata"] = @aEdgeMetadata[cEdgeKey]
			else
				aEdge["metadata"] = []
			ok
			
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
					if cType = "" cType = @cDefaultNodeType ok
					if cColor = "" cColor = @cDefaultNodeColor ok
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
		if cType = "" cType = @cDefaultNodeType ok
		if cColor = "" cColor = @cDefaultNodeColor ok
		This.AddNodeXT(cCurrentNode, cLabel, cType, cColor)
	ok
	
	# Now add all edges
	for aEdge in aEdgesToAdd
		This.Connect(aEdge[1], aEdge[2])
	end
	
	def UnescapeString(cStr)

		cStr = trim(cStr)
		if left(cStr, 1) = '"' and right(cStr, 1) = '"'
			cStr = @substr(cStr, 2, len(cStr) - 1)
		ok
		cStr = substr(cStr, '\"', '"')
		return cStr
	

	#------------------------------------------
	#  METADATA OPERATIONS
	#------------------------------------------
	
	def SetNodeMetadata(pNodeId, aMetadata)
		@aNodeMetadata[pNodeId] = aMetadata
	
	def GetNodeMetadata(pNodeId)
		if HasKey(@aNodeMetadata, pNodeId)
			return @aNodeMetadata[pNodeId]
		ok
		return []
	
	def RemoveNodeMetadata(pNodeId)
		if HasKey(@aNodeMetadata, pNodeId)
			@aNodeMetadata[pNodeId] = NULL
		ok
	
	def UpdateNodeMetadata(pNodeId, cKey, pValue)
		if NOT HasKey(@aNodeMetadata, pNodeId)
			@aNodeMetadata[pNodeId] = []
		ok
		@aNodeMetadata[pNodeId][cKey] = pValue
	
	def SetEdgeMetadata(pFromId, pToId, aMetadata)
		cEdgeKey = pFromId + "->" + pToId
		@aEdgeMetadata[cEdgeKey] = aMetadata
	
	def GetEdgeMetadata(pFromId, pToId)
		cEdgeKey = pFromId + "->" + pToId
		if HasKey(@aEdgeMetadata, cEdgeKey)
			return @aEdgeMetadata[cEdgeKey]
		ok
		return []
	
	def RemoveEdgeMetadata(pFromId, pToId)
		cEdgeKey = pFromId + "->" + pToId
		if HasKey(@aEdgeMetadata, cEdgeKey)
			@aEdgeMetadata[cEdgeKey] = NULL
		ok
	
	def UpdateEdgeMetadata(pFromId, pToId, cKey, pValue)
		cEdgeKey = pFromId + "->" + pToId
		if NOT HasKey(@aEdgeMetadata, cEdgeKey)
			@aEdgeMetadata[cEdgeKey] = []
		ok
		@aEdgeMetadata[cEdgeKey][cKey] = pValue
	
	def RemoveAllMetadata()
		@aNodeMetadata = []
		@aEdgeMetadata = []
		@aNodeTags = []
		@aEdgeTags = []

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
		if HasKey($aDiagramValidators, pcDomain)
			oValidator = $aDiagramValidators[pcDomain]
			return oValidator.Validate(oDiagram)
		else
			return [
				:status = "error",
				:message = "No validator registered for domain: " + pcDomain
			]
		ok

	def Validators()
		return $aDiagramValidators


#=====================================================
#  stzDiagramSoxValidator - SARBANES-OXLEY
#=====================================================

class stzDiagramSoxValidator from stzDiagramValidator

	def Validate(oDiag)
		aIssues = []

		# Rule 1: Financial processes must have audit trail
		aFinancialNodes = This.NodesByProperty(oDiag, "domain", "financial")
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
		aDec = This.NodesByType(oDiag, "decision")
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

		return [
			:status = iif(len(aIssues) = 0, "pass", "fail"),
			:domain = "sox",
			:issueCount = len(aIssues),
			:issues = aIssues
		]

	def NodesByType(pDiag, pType)
		aFound = []
		for aNode in pDiag.Nodes()
			if aNode["properties"]["type"] = pType
				aFound + aNode["id"]
			ok
		end
		return aFound

	def NodesByProperty(pDiag, pProperty, pValue)
		aFound = []
		for aNode in pDiag.Nodes()
			if HasKey(aNode, "properties") and HasKey(aNode["properties"], pProperty) and
			   aNode["properties"][pProperty] = pValue
				aFound + aNode["id"]
			ok
		end
		return aFound

#=====================================================
#  stzDiagramGdprValidator - GDPR
#=====================================================

class stzDiagramGdprValidator from stzDiagramValidator

	def Validate(oDiag)
		aIssues = []

		# Rule 1: Personal data processing requires consent
		aDataNodes = This.NodesByProperty(oDiag, "dataType", "personal")
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

		return [
			:status = iif(len(aIssues) = 0, "pass", "fail"),
			:domain = "gdpr",
			:issueCount = len(aIssues),
			:issues = aIssues
		]

	def NodesByProperty(pDiag, pProperty, pValue)
		aFound = []
		for aNode in pDiag.Nodes()
			if HasKey(aNode, "properties") and HasKey(aNode["properties"], pProperty) and
			   aNode["properties"][pProperty] = pValue
				aFound + aNode["id"]
			ok
		end
		return aFound

#=====================================================
#  stzDiagramBankingValidator - CUSTOM BANKING
#=====================================================

class stzDiagramBankingValidator from stzDiagramValidator

	def Validate(oDiag)
		aIssues = []

		# Rule 1: Large transactions require multi-level approval
		aLargeTransactions = This.NodesByProperty(oDiag, "transactionType", "large")
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
		aPaymentNodes = This.NodesByProperty(oDiag, "operation", "payment")
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

		return [
			:status = iif(len(aIssues) = 0, "pass", "fail"),
			:domain = "banking",
			:issueCount = len(aIssues),
			:issues = aIssues
		]

	def NodesByProperty(pDiag, pProperty, pValue)
		aFound = []
		for aNode in pDiag.Nodes()
			if HasKey(aNode, "properties") and HasKey(aNode["properties"], pProperty) and
			   aNode["properties"][pProperty] = pValue
				aFound + aNode["id"]
			ok
		end
		return aFound

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
		cTheme = ""
		if @oDiagram.@cTheme != NULL and @oDiagram.@cTheme != ""
			cTheme = lower(@oDiagram.@cTheme)
		else
			cTheme = "light"
		ok
		
		if len(@oDiagram.@aVisualRules) > 0
			@oDiagram.ApplyVisualRules()
		ok
		
		cOutput += 'digraph "' + @oDiagram.Id() + '" {' + NL
		
		cRankDir = "TB"
		cLayout = lower(@oDiagram.@cLayout)
	
		if cLayout = "topdown" or ring_find($acLayouts[:TopDown], cLayout)
			cRankDir = "TB"
		but cLayout = "bottomup" or ring_find($acLayouts[:BottomUp], cLayout)
			cRankDir = "BT"
		but cLayout = "leftright" or ring_find($acLayouts[:LeftRight], cLayout)
			cRankDir = "LR"
		but cLayout = "rightleft" or ring_find($acLayouts[:RightLeft], cLayout)
			cRankDir = "RL"
		ok
		
		cFont = @oDiagram.@cFont
		if cFont = "" or cFont = NULL
			cFont = @cDefaultFont
		ok
	
		nFontSize = @oDiagram.@nFontSize
		if nFontSize = 0 or nFontSize = NULL
			nFontSize = @cDefaultFontSize
		ok
		
		cOutput += "    graph [rankdir=" + cRankDir + ", bgcolor=white, fontname=" + cFont + ", fontsize=" + nFontSize + "]" + NL
		cOutput += "    node [fontname=" + cFont + ", fontsize=" + nFontSize + "]" + NL
		
		cEdgeColor = ResolveColor(@oDiagram.@cEdgeColor)
		
		if cTheme = "print" or cTheme = "gray"
			cEdgeColor = ResolveColor(:black)
		ok
		
		# Remove # from hex colors
		if substr(cEdgeColor, "#")
			cEdgeColor = @substr(cEdgeColor, 2, len(cEdgeColor))
		ok
	
		cEdgeStyle = "solid"
		if @oDiagram.@cEdgeStyle != "" 
			cEdgeStyle = ResolveEdgeStyle(@oDiagram.@cEdgeStyle)
		ok
	
		cOutput += "    edge [fontname=" + cFont + ", fontsize=" + nFontSize + ", color=" + cEdgeColor + ", style=" + cEdgeStyle + "]" + NL + NL
	
		# Generate nodes
		for aNode in @oDiagram.Nodes()
			cNodeId = aNode["id"]
			cLabel = aNode["label"]
			
			aEnhancements = []
			if HasKey(@oDiagram.@aNodeEnhancements, cNodeId)
				aEnhancements = @oDiagram.@aNodeEnhancements[cNodeId]
			ok
			
			cShape = "box"
			cStyle = "rounded,filled"
			
			# FIX: Check if properties exists and has type
			cType = ""
			if HasKey(aNode, "properties") and aNode["properties"] != NULL and 
			   HasKey(aNode["properties"], "type") and aNode["properties"]["type"] != NULL
				cType = lower("" + aNode["properties"]["type"])
			ok
	
			if cType != ""
				if cType = "process"
					cShape = "box"
					cStyle = "rounded,filled"
				but cType = "decision"
					cShape = "diamond"
					cStyle = "filled"
				but cType = "start"
					cShape = "ellipse"
					cStyle = "filled"
				but cType = "endpoint"
					cShape = "doublecircle"
					cStyle = "filled"
				but cType = "state"
					cShape = "circle"
					cStyle = "filled"
				but cType = "storage"
					cShape = "cylinder"
					cStyle = "filled"
				but cType = "data"
					cShape = "box"
					cStyle = "rounded,filled"
				but cType = "event"
					cShape = "ellipse"
					cStyle = "filled"
				ok
			ok
	
			if HasKey(aEnhancements, "shape")
				cShape = aEnhancements["shape"]
			ok
			
			if HasKey(aEnhancements, "style")
				cStyle = aEnhancements["style"]
			ok
			
			# FIX: Get color safely
			cOrigColor = ""
			if HasKey(aNode, "properties") and aNode["properties"] != NULL and 
			   HasKey(aNode["properties"], "color") and aNode["properties"]["color"] != NULL
				cOrigColor = aNode["properties"]["color"]
			ok
			
			if cOrigColor = "" or cOrigColor = NULL
				cOrigColor = @cDefaultNodeColor
			ok
			
			if HasKey(aEnhancements, "color")
				cOrigColor = aEnhancements["color"]
			ok
			
			# Don't resolve if already hex
			if substr(cOrigColor, "#")
				cFillColor = cOrigColor
			else
				cFillColor = ResolveColor(cOrigColor)
			ok
			
			if cTheme = "gray"
				cFillColor = @oDiagram.ConvertColorTogray(cFillColor)
			ok
			if cTheme = "print"
				cFillColor = ResolveColor(:white)
			ok
			
			# Calculate font color
			cFontColor = @oDiagram.ResolveFontColor(cFillColor)
	
			cOutput += '    ' + cNodeId + ' [label="' + cLabel + '", '
			cOutput += 'shape=' + cShape + ', style="' + cStyle + '", '
			cOutput += 'fillcolor="' + cFillColor + '"'
			
			if HasKey(aEnhancements, "penwidth")
				cOutput += ', penwidth=' + aEnhancements["penwidth"]
			ok
			
			cStrokeColor = ""
			if @oDiagram.@cNodeStrokeColor != ""
				cStrokeColorHex = @oDiagram.@cNodeStrokeColor
				if substr(cStrokeColorHex, "#")
					cStrokeColorHex = @substr(cStrokeColorHex, 2, len(cStrokeColorHex))
				ok
				cStrokeColor = ', color="' + cStrokeColorHex + '"'
			but cTheme = "print" or cTheme = "gray"
				cStrokeColor = ', color="black", penwidth=2'
			ok
			cOutput += cStrokeColor
			
			cOutput += ', fontcolor="' + cFontColor + '"'
			
			cOutput += ']' + NL
		end
	
		cOutput += NL
	
		# Generate edges with enhancements
		for aEdge in @oDiagram.Edges()
			cFrom = aEdge["from"]
			cTo = aEdge["to"]
			cEdgeKey = cFrom + "->" + cTo
			
			cOutput += '    ' + cFrom + ' -> ' + cTo
			
			aAttrs = []
			
			# Add label
			if HasKey(aEdge, "label")
				cLabel = aEdge["label"]
				if cLabel != "" and cLabel != NULL
					cLabelText = iff(cRankDir = "TB", " ", "") + cLabel
					aAttrs + ('label="' + cLabelText + '"')
				ok
			ok
			
			# Get edge enhancements
			aEdgeEnhancements = []
			if HasKey(@oDiagram.@aEdgeEnhancements, cEdgeKey)
				aEdgeEnhancements = @oDiagram.@aEdgeEnhancements[cEdgeKey]
			ok
			
			# Apply enhancements
			if HasKey(aEdgeEnhancements, "style")
				aAttrs + ('style="' + aEdgeEnhancements["style"] + '"')
			ok
			if HasKey(aEdgeEnhancements, "color")
				cResolvedColor = ResolveColor(aEdgeEnhancements["color"])
				# Strip # from hex
				if substr(cResolvedColor, "#")
					cResolvedColor = @substr(cResolvedColor, 2, len(cResolvedColor))
				ok
				aAttrs + ('color="' + cResolvedColor + '"')
			ok
			if HasKey(aEdgeEnhancements, "penwidth")
				aAttrs + ('penwidth=' + aEdgeEnhancements["penwidth"])
			ok
			if HasKey(aEdgeEnhancements, "arrowhead")
				aAttrs + ('arrowhead=' + aEdgeEnhancements["arrowhead"])
			ok
			
			# Build attributes string
			if len(aAttrs) > 0
				cOutput += ' ['
				for i = 1 to len(aAttrs)
					cOutput += aAttrs[i]
					if i < len(aAttrs)
						cOutput += ', '
					ok
				end
				cOutput += ']'
			ok
			
			cOutput += NL
		end
	
		cOutput += NL + "}"
	
		@cDotCode = cOutput

	
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

		for aNode in @oDiagram.Nodes()
			cNodeId = aNode["id"]
			cLabel = aNode["label"]

			# Escape reserved Mermaid keywords
			cSafeNodeId = cNodeId
			if cNodeId = "end" or cNodeId = "start" or cNodeId = "subgraph"
				cSafeNodeId = "node_" + cNodeId
			ok

			cType = aNode["properties"]["type"]
			if cType = :start
				cOutput += '    ' + cSafeNodeId + '(["' +
					   cLabel + '"])' + NL

			but cType = :endpoint
				cOutput += '    ' + cSafeNodeId + '(["' +
					   cLabel + '"])' + NL

			but cType = :decision
				cOutput += '    ' + cSafeNodeId + '{{"' +
					   cLabel + '"}}' + NL

			but cType = :process
				cOutput += '    ' + cSafeNodeId + '["' +
					   cLabel + '"]' + NL

			else
				cOutput += '    ' + cSafeNodeId + '["' + cLabel + '"]' + NL
			ok
		end

		cOutput += NL

		for aEdge in @oDiagram.Edges()
			cFromId = aEdge["from"]
			cToId = aEdge["to"]
			
			# Apply same escaping to edge references
			if cFromId = "end" or cFromId = "start" or cFromId = "subgraph"
				cFromId = "node_" + cFromId
			ok
			if cToId = "end" or cToId = "start" or cToId = "subgraph"
				cToId = "node_" + cToId
			ok
			
			cOutput += '    ' + cFromId + ' --> ' + cToId
			if aEdge["label"] != ""
				cOutput += ' |' + aEdge["label"] + '|'
			ok
			cOutput += NL
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
		@cJsonCode = ToJSON(aData)

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

			but oVal.IsInRangeParam()
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
