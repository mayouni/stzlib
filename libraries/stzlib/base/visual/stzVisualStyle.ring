
#=====================================================
#  Helper Functions
#=====================================================

func StzColorQ(pColor)
	return new stzColor(pColor)

func StzPaletteQ(pcName, paColors)
	return new stzPalette(pcName, paColors)

func StzColorSchemeQ(pcName)
	return new stzColorScheme(pcName)

func StzThemeQ(pcName)
	return new stzTheme(pcName)

func StzLayoutQ(pcOrientation)
	return new stzLayout(pcOrientation)

func StzTypographyQ(pcFamily, pnSize)
	return new stzTypography(pcFamily, pnSize)

func StzVisualStyleQ(pcTheme, pcLayout)
	return new stzVisualStyle(pcTheme, pcLayout)

func StzSemanticColorQ(pColor)
	return new stzSemanticColor(pColor)

func StzColorFilterQ()
	return new stzColorFilter()

func IntensityColors()
	return $aIntensityColors

func EmotionalColors()
	return $aEmotionalColors

func BusinessColors()
	return $aBusinessColors

func AllSemanticColors()
	aAll = []
	for cKey in Keys($aIntensityColors)
		aAll[cKey] = $aIntensityColors[cKey]
	end
	for cKey in Keys($aEmotionalColors)
		aAll[cKey] = $aEmotionalColors[cKey]
	end
	for cKey in Keys($aBusinessColors)
		aAll[cKey] = $aBusinessColors[cKey]
	end
	return aAllNodes

#=====================================================
#  stzColor - Individual Color Management
#=====================================================

class stzColor

	@cValue = "black"
	@aRGB = [0, 0, 0]
	@nLuminance = 0

	def init(pColor)
		This.SetValue(pColor)

	def SetValue(pColor)
		@cValue = This.NormalizeColor(pColor)
		@aRGB = This.ToRGB(@cValue)
		@nLuminance = This.CalculateLuminance(@aRGB)

	def Value()
		return @cValue

	def RGB()
		return @aRGB

	def R()
		return @aRGB[1]

	def G()
		return @aRGB[2]

	def B()
		return @aRGB[3]

	def Luminance()
		return @nLuminance

	def IsLight()
		return @nLuminance >= 0.5

	def IsDark()
		return @nLuminance < 0.5

	def ContrastColor()
		if This.IsDark()
			return "white"
		else
			return "black"
		ok

	def ToHex()
		if substr(@cValue, "#")
			return @cValue
		ok
		cR = dec2hex(@aRGB[1])
		cG = dec2hex(@aRGB[2])
		cB = dec2hex(@aRGB[3])
		return "#" + cR + cG + cB

	#-- Private Methods --

	def NormalizeColor(pColor)
		if NOT isString(pColor)
			pColor = "" + pColor
		ok
		return lower(pColor)

	def ToRGB(cColor)
		# Hex colors
		if substr(cColor, "#")
			return This.HexToRGB(cColor)
		ok

		# Named colors
		aMap = [
			:white = [255, 255, 255],
			:black = [0, 0, 0],
			:red = [255, 0, 0],
			:green = [0, 128, 0],
			:darkgreen = [0, 100, 0],
			:blue = [0, 0, 255],
			:yellow = [255, 255, 0],
			:lightblue = [173, 216, 230],
			:lightgreen = [144, 238, 144],
			:lightyellow = [255, 255, 224],
			:lightcoral = [240, 128, 128],
			:lightgray = [211, 211, 211],
			:lightcyan = [224, 255, 255],
			:lavender = [230, 230, 250],
			:lightpink = [255, 182, 193],
			:gray = [128, 128, 128],
			:darkgray = [64, 64, 64]
		]

		if HasKey(aMap, cColor)
			return aMap[cColor]
		ok

		return [128, 128, 128]

	def HexToRGB(cHex)
		cHex = substr(cHex, 2)
		if len(cHex) = 6
			nR = hex2dec(substr(cHex, 1, 2))
			nG = hex2dec(substr(cHex, 3, 2))
			nB = hex2dec(substr(cHex, 5, 2))
			return [nR, nG, nB]
		ok
		return [128, 128, 128]

	def CalculateLuminance(aRGB)
		nR = aRGB[1]
		nG = aRGB[2]
		nB = aRGB[3]
		return (0.2126 * nR + 0.7152 * nG + 0.0722 * nB) / 255

#=====================================================
#  stzPalette - Color Collection
#=====================================================

class stzPalette

	@cName = "default"
	@aColors = []

	def init(pcName, paColors)
		@cName = pcName
		if paColors != NULL
			@aColors = paColors
		ok

	def Name()
		return @cName

	def Colors()
		return @aColors

	def Color(pKey)
		cKey = lower("" + pKey)
		if HasKey(@aColors, cKey)
			return @aColors[cKey]
		ok
		return NULL

	def HasColor(pKey)
		cKey = lower("" + pKey)
		return HasKey(@aColors, cKey)

	def AddColor(pKey, pValue)
		cKey = lower("" + pKey)
		@aColors[cKey] = pValue

	def RemoveColor(pKey)
		cKey = lower("" + pKey)
		if HasKey(@aColors, cKey)
			del(@aColors, cKey)
		ok

	def Keys()
		return Keys(@aColors)

	def Count()
		return len(@aColors)

#=====================================================
#  stzColorScheme - Semantic Color Mapping
#=====================================================

class stzColorScheme

	@cName = "default"
	@aPalette = NULL
	@aFontColors = []

	def init(pcName)
		@cName = lower(pcName)
		This.LoadDefaults()

	def LoadDefaults()
		# Load from global definitions
		aSchemes = [
			:light = [
				:palette = [
					:primary = "lightblue",
					:success = "lightgreen",
					:warning = "lightyellow",
					:danger = "lightcoral",
					:info = "lightcyan",
					:neutral = "lightgray",
					:background = "white"
				],
				:fontcolors = [
					:primary = "black",
					:success = "black",
					:warning = "black",
					:danger = "black",
					:info = "black",
					:neutral = "black"
				]
			],
			:dark = [
				:palette = [
					:primary = "#003366",
					:success = "#4CAF50",
					:warning = "#FF9800",
					:danger = "#F44336",
					:info = "#2196F3",
					:neutral = "#757575",
					:background = "#F5F5F5"
				],
				:fontcolors = [
					:primary = "white",
					:success = "white",
					:warning = "black",
					:danger = "white",
					:info = "white",
					:neutral = "white"
				]
			],
			:vibrant = [
				:palette = [
					:primary = "#0288D1",
					:success = "#43A047",
					:warning = "#FB8C00",
					:danger = "#E53935",
					:info = "#1E88E5",
					:neutral = "#424242",
					:background = "white"
				],
				:fontcolors = [
					:primary = "white",
					:success = "white",
					:warning = "black",
					:danger = "white",
					:info = "white",
					:neutral = "white"
				]
			],
			:professional = [
				:palette = [
					:primary = "lightblue",
					:success = "#006633",
					:warning = "#CC6600",
					:danger = "#CC0000",
					:info = "#0066CC",
					:neutral = "#666666",
					:background = "white"
				],
				:fontcolors = [
					:primary = "black",
					:success = "white",
					:warning = "black",
					:danger = "white",
					:info = "white",
					:neutral = "white"
				]
			]
		]

		if HasKey(aSchemes, @cName)
			@aPalette = new stzPalette(@cName, aSchemes[@cName][:palette])
			@aFontColors = aSchemes[@cName][:fontcolors]
		else
			@aPalette = new stzPalette("default", aSchemes[:professional][:palette])
			@aFontColors = aSchemes[:professional][:fontcolors]
		ok

	def Name()
		return @cName

	def Palette()
		return @aPalette

	def Color(pKey)
		return @aPalette.Color(pKey)

	def FontColor(pKey)
		cKey = lower("" + pKey)
		if HasKey(@aFontColors, cKey)
			return @aFontColors[cKey]
		ok
		return NULL

#=====================================================
#  stzColorResolver - Color Resolution Engine
#=====================================================

class stzColorResolver

	def Resolve(pColor, poScheme)
		# Already concrete
		if This.IsConcrete(pColor)
			return pColor
		ok

		# Try scheme
		if poScheme != NULL
			cResolved = poScheme.Color(pColor)
			if cResolved != NULL
				return cResolved
			ok
		ok

		return "lightblue"

	def ResolveFont(pBgColor, poScheme)
		# Try scheme mapping
		if poScheme != NULL
			cFont = poScheme.FontColor(pBgColor)
			if cFont != NULL
				return cFont
			ok
		ok

		# Calculate from luminance
		cActual = This.Resolve(pBgColor, poScheme)
		oColor = new stzColor(cActual)
		return oColor.ContrastColor()

	def IsConcrete(pColor)
		if NOT isString(pColor)
			return FALSE
		ok

		cColor = lower(pColor)

		if substr(cColor, "#")
			return TRUE
		ok

		aNames = ["white", "black", "red", "blue", "green", "yellow",
		          "lightblue", "lightgreen", "lightyellow", "lightcoral",
		          "lightgray", "lightcyan", "lavender", "lightpink",
		          "gray", "darkgray", "darkgreen"]

		return ring_find(aNames, cColor) > 0

#=====================================================
#  stzTheme - Complete Theme Management
#=====================================================

class stzTheme

	@oScheme = NULL
	@oResolver = NULL

	def init(pcScheme)
		if pcScheme = NULL
			pcScheme = "professional"
		ok
		@oScheme = new stzColorScheme(pcScheme)
		@oResolver = new stzColorResolver()

	def Scheme()
		return @oScheme

	def Name()
		return @oScheme.Name()

	def SetScheme(pcName)
		@oScheme = new stzColorScheme(pcName)

	def Palette()
		return @oScheme.Palette()

	def Color(pKey)
		return @oScheme.Color(pKey)

	def ResolveColor(pColor)
		return @oResolver.Resolve(pColor, @oScheme)

	def ResolveFontColor(pBgColor)
		return @oResolver.ResolveFont(pBgColor, @oScheme)

#=====================================================
#  stzLayout - Layout Configuration
#=====================================================

class stzLayout

	@cOrientation = "topdown"
	@nNodeSpacing = 50
	@nRankSpacing = 100
	@bCompact = FALSE

	def init(pcOrientation)
		if pcOrientation != NULL
			This.SetOrientation(pcOrientation)
		ok

	def SetOrientation(pcOrientation)
		cOrient = lower(pcOrientation)
		aValid = ["topdown", "bottomup", "leftright", "rightleft"]

		if ring_find(aValid, cOrient) > 0
			@cOrientation = cOrient
		ok

	def Orientation()
		return @cOrientation

	def ToDotRankdir()
		switch @cOrientation
		on "topdown"
			return "TB"
		on "bottomup"
			return "BT"
		on "leftright"
			return "LR"
		on "rightleft"
			return "RL"
		other
			return "TB"
		off

	def SetNodeSpacing(n)
		@nNodeSpacing = n

	def NodeSpacing()
		return @nNodeSpacing

	def SetRankSpacing(n)
		@nRankSpacing = n

	def RankSpacing()
		return @nRankSpacing

	def SetCompact(b)
		@bCompact = b

	def IsCompact()
		return @bCompact

	def ToDotAttributes()
		aAttrs = []
		aAttrs + 'rankdir=' + This.ToDotRankdir()
		aAttrs + 'nodesep=' + String(@nNodeSpacing / 72.0)
		aAttrs + 'ranksep=' + String(@nRankSpacing / 72.0)

		if @bCompact
			aAttrs + 'concentrate=true'
		ok

		return aAttrs

#=====================================================
#  stzTypography - Font Configuration
#=====================================================

class stzTypography

	@cFamily = "Helvetica"
	@nSize = 12
	@bBold = FALSE
	@bItalic = FALSE

	def init(pcFamily, pnSize)
		if pcFamily != NULL
			@cFamily = pcFamily
		ok
		if pnSize != NULL
			@nSize = pnSize
		ok

	def Family()
		return @cFamily

	def SetFamily(pc)
		@cFamily = pc

	def Size()
		return @nSize

	def SetSize(n)
		@nSize = n

	def Bold()
		return @bBold

	def SetBold(b)
		@bBold = b

	def Italic()
		return @bItalic

	def SetItalic(b)
		@bItalic = b

	def ToDotFontname()
		cName = @cFamily
		if @bBold and @bItalic
			cName += "-BoldItalic"
		but @bBold
			cName += "-Bold"
		but @bItalic
			cName += "-Italic"
		ok
		return cName

#=====================================================
#  stzVisualStyle - Complete Visual Configuration
#=====================================================

class stzVisualStyle

	@oTheme = NULL
	@oLayout = NULL
	@oTypography = NULL

	def init(pcTheme, pcLayout)
		if pcTheme = NULL
			pcTheme = "professional"
		ok
		if pcLayout = NULL
			pcLayout = "topdown"
		ok

		@oTheme = new stzTheme(pcTheme)
		@oLayout = new stzLayout(pcLayout)
		@oTypography = new stzTypography("Helvetica", 12)

	def Theme()
		return @oTheme

	def Layout()
		return @oLayout

	def Typography()
		return @oTypography

	def SetTheme(pcName)
		@oTheme.SetScheme(pcName)

	def SetLayout(pcOrientation)
		@oLayout.SetOrientation(pcOrientation)

	def SetFont(pcFamily, pnSize)
		if pcFamily != NULL
			@oTypography.SetFamily(pcFamily)
		ok
		if pnSize != NULL
			@oTypography.SetSize(pnSize)
		ok

	def ResolveColor(pColor)
		return @oTheme.ResolveColor(pColor)

	def ResolveFontColor(pBgColor)
		return @oTheme.ResolveFontColor(pBgColor)


#=====================================================
#  Semantic Color System - Meaningful Color Names
#=====================================================

# Intensity-based semantics
$aIntensityColors = [
	# Temperature
	:Cool = "#B3E5FC",
	:Cooler = "#81D4FA",
	:Coolest = "#4FC3F7",
	:Cold = "#29B6F6",
	:Colder = "#03A9F4",
	:Coldest = "#0288D1",
	:Frozen = "#01579B",
	
	:Warm = "#FFECB3",
	:Warmer = "#FFE082",
	:Warmest = "#FFD54F",
	:Hot = "#FFCA28",
	:Hotter = "#FFC107",
	:Hottest = "#FFA000",
	:Burning = "#FF6F00",
	
	# Strength/Weight
	:Light = "#F5F5F5",
	:Lighter = "#E0E0E0",
	:Lightest = "#BDBDBD",
	
	:Heavy = "#757575",
	:Heavier = "#616161",
	:Heaviest = "#424242",
	
	:Weak = "#E8F5E9",
	:Weaker = "#C8E6C9",
	:Weakest = "#A5D6A7",
	
	:Strong = "#388E3C",
	:Stronger = "#2E7D32",
	:Strongest = "#1B5E20",
	
	# Energy/Activity
	:Calm = "#E1F5FE",
	:Calmer = "#B3E5FC",
	:Calmest = "#81D4FA",
	
	:Active = "#FFF9C4",
	:MoreActive = "#FFF59D",
	:MostActive = "#FFF176",
	:Energetic = "#FFEB3B",
	:MoreEnergetic = "#FDD835",
	:MostEnergetic = "#F9A825",
	
	# Safety/Risk
	:Safe = "#C8E6C9",
	:Safer = "#A5D6A7",
	:Safest = "#81C784",
	
	:Risky = "#FFCCBC",
	:Riskier = "#FFAB91",
	:Riskiest = "#FF8A65",
	:Dangerous = "#FF5722",
	:MoreDangerous = "#F4511E",
	:MostDangerous = "#E64A19",
	:Critical = "#D84315",
	
	# Speed
	:Slow = "#E0F2F1",
	:Slower = "#B2DFDB",
	:Slowest = "#80CBC4",
	
	:Fast = "#FFE0B2",
	:Faster = "#FFCC80",
	:Fastest = "#FFB74D",
	:Instant = "#FFA726",
	
	# Priority
	:Low = "#F3E5F5",
	:Lower = "#E1BEE7",
	:Lowest = "#CE93D8",
	
	:High = "#BA68C8",
	:Higher = "#AB47BC",
	:Highest = "#9C27B0",
	:Urgent = "#8E24AA",
	:MoreUrgent = "#7B1FA2",
	:MostUrgent = "#6A1B9A"
]

# Emotional/State semantics
$aEmotionalColors = [
	:Happy = "#FFF59D",
	:Sad = "#90CAF9",
	:Angry = "#EF5350",
	:Peaceful = "#A5D6A7",
	:Anxious = "#FFB74D",
	:Confident = "#42A5F5",
	:Uncertain = "#BCAAA4",
	:Excited = "#FF7043",
	:Bored = "#B0BEC5",
	:Hopeful = "#AED581",
	:Fearful = "#8D6E63"
]

# Business/Domain semantics
$aBusinessColors = [
	:Profit = "#4CAF50",
	:Loss = "#F44336",
	:Pending = "#FFC107",
	:Approved = "#66BB6A",
	:Rejected = "#EF5350",
	:Draft = "#E0E0E0",
	:Final = "#1976D2",
	:Archived = "#9E9E9E",
	:New = "#00BCD4",
	:Updated = "#FF9800",
	:Deleted = "#D32F2F",
	:Locked = "#795548",
	:Unlocked = "#8BC34A"
]

# Opposite pairs for mode toggling
$aColorOpposites = [
	:Light = :Dark,
	:Dark = :Light,
	:Cool = :Hot,
	:Hot = :Cool,
	:Calm = :Energetic,
	:Energetic = :Calm,
	:Safe = :Dangerous,
	:Dangerous = :Safe,
	:Slow = :Fast,
	:Fast = :Slow,
	:Low = :High,
	:High = :Low,
	:Weak = :Strong,
	:Strong = :Weak
]

#=====================================================
#  stzSemanticColor - Enhanced Color with Meaning
#=====================================================

class stzSemanticColor from stzColor

	@cSemantic = ""
	@aCategories = []
	@nIntensity = 0

	def init(pColor)
		if isString(pColor)
			@cSemantic = pColor
			cActual = This.ResolveSemanticColor(pColor)
			super.init(cActual)
			This.DetectProperties()
		else
			super.init(pColor)
		ok

	def Semantic()
		return @cSemantic

	def Categories()
		return @aCategories

	def Intensity()
		return @nIntensity

	def HasCategory(pcCategory)
		return ring_find(@aCategories, pcCategory) > 0

	def Opposite()
		cSemKey = lower(@cSemantic)
		if HasKey($aColorOpposites, cSemKey)
			return new stzSemanticColor($aColorOpposites[cSemKey])
		ok
		return This

	def Invert()
		return This.Opposite()

	#-- Private --

	def ResolveSemanticColor(pSemantic)
		cKey = lower("" + pSemantic)
		
		if HasKey($aIntensityColors, cKey)
			return $aIntensityColors[cKey]
		ok
		if HasKey($aEmotionalColors, cKey)
			return $aEmotionalColors[cKey]
		ok
		if HasKey($aBusinessColors, cKey)
			return $aBusinessColors[cKey]
		ok
		
		return pSemantic

	def DetectProperties()
		cSemKey = lower(@cSemantic)
		
		# Detect categories
		if HasKey($aIntensityColors, cSemKey)
			@aCategories + "intensity"
			This.DetectIntensityLevel()
		ok
		if HasKey($aEmotionalColors, cSemKey)
			@aCategories + "emotional"
		ok
		if HasKey($aBusinessColors, cSemKey)
			@aCategories + "business"
		ok

	def DetectIntensityLevel()
		cSem = lower(@cSemantic)
		
		# Temperature
		if substr(cSem, "cold")
			@aCategories + "temperature"
			if substr(cSem, "coldest")
				@nIntensity = 6
			but substr(cSem, "colder")
				@nIntensity = 5
			else
				@nIntensity = 4
			ok
		but substr(cSem, "cool")
			@aCategories + "temperature"
			if substr(cSem, "coolest")
				@nIntensity = 3
			but substr(cSem, "cooler")
				@nIntensity = 2
			else
				@nIntensity = 1
			ok
		but substr(cSem, "hot") or substr(cSem, "warm") or substr(cSem, "burn")
			@aCategories + "temperature"
			if substr(cSem, "burning")
				@nIntensity = 7
			but substr(cSem, "hottest") or substr(cSem, "warmest")
				@nIntensity = 6
			but substr(cSem, "hotter") or substr(cSem, "warmer")
				@nIntensity = 5
			else
				@nIntensity = 4
			ok
		ok
		
		# Strength
		if substr(cSem, "strong")
			@aCategories + "strength"
			if substr(cSem, "strongest")
				@nIntensity = 6
			but substr(cSem, "stronger")
				@nIntensity = 5
			else
				@nIntensity = 4
			ok
		but substr(cSem, "weak")
			@aCategories + "strength"
			if substr(cSem, "weakest")
				@nIntensity = 3
			but substr(cSem, "weaker")
				@nIntensity = 2
			else
				@nIntensity = 1
			ok
		ok
		
		# Priority
		if substr(cSem, "urgent")
			@aCategories + "priority"
			if substr(cSem, "mosturgent")
				@nIntensity = 9
			but substr(cSem, "moreurgent")
				@nIntensity = 8
			else
				@nIntensity = 7
			ok
		but substr(cSem, "high")
			@aCategories + "priority"
			if substr(cSem, "highest")
				@nIntensity = 6
			but substr(cSem, "higher")
				@nIntensity = 5
			else
				@nIntensity = 4
			ok
		but substr(cSem, "low")
			@aCategories + "priority"
			if substr(cSem, "lowest")
				@nIntensity = 3
			but substr(cSem, "lower")
				@nIntensity = 2
			else
				@nIntensity = 1
			ok
		ok

#=====================================================
#  stzColorFilter - Filter Nodes by Color Semantics
#=====================================================

class stzColorFilter

	def NodesWithCategory(oDiagram, pcCategory)
		aResult = []
		for aNode in oDiagram.Nodes()
			oColor = new stzSemanticColor(aNode["properties"]["color"])
			if oColor.HasCategory(pcCategory)
				aResult + aNode["id"]
			ok
		end
		return aResult

	def NodesWithIntensity(oDiagram, nMin, nMax)
		aResult = []
		for aNode in oDiagram.Nodes()
			oColor = new stzSemanticColor(aNode["properties"]["color"])
			nIntensity = oColor.Intensity()
			if nIntensity >= nMin and nIntensity <= nMax
				aResult + aNode["id"]
			ok
		end
		return aResult

	def NodesWithSemantic(oDiagram, pcSemantic)
		aResult = []
		cSearchKey = lower(pcSemantic)
		for aNode in oDiagram.Nodes()
			cNodeColor = lower(aNode["properties"]["color"])
			if cNodeColor = cSearchKey
				aResult + aNode["id"]
			ok
		end
		return aResult

	def HighPriorityNodes(oDiagram)
		return This.NodesWithCategory(oDiagram, "priority")

	def EmotionalNodes(oDiagram)
		return This.NodesWithCategory(oDiagram, "emotional")

	def HotNodes(oDiagram)
		return This.NodesWithIntensity(oDiagram, 4, 10)

	def CoolNodes(oDiagram)
		return This.NodesWithIntensity(oDiagram, 1, 3)

#=====================================================
#  stzDarkLightMode - Toggle Between Modes
#=====================================================

class stzDarkLightMode

	def ToggleDiagram(oDiagram)
		for aNode in oDiagram.Nodes()
			cColor = aNode["properties"]["color"]
			oColor = new stzSemanticColor(cColor)
			oOpposite = oColor.Opposite()
			aNode["properties"]["color"] = oOpposite.Semantic()
		end

	def InvertColors(oDiagram)
		This.ToggleDiagram(oDiagram)
