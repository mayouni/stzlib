#----------------------------------------------------------#
#  stzDiagramColor - UNIFIED COLOR SYSTEM                  #
#  Used currently by stzDiagram visual themes              #
#  #TODO Abstract it in a stzColor class -> Visual Module  #
#----------------------------------------------------------#
#  Part of GRAPH MODULE in StzLib (V0.9)                   #
#  By: Mansour Ayouni (kalidianow@gamil.com)               #
#==========================================================#

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

# THEMES

$acColorThemes = [
	"neutral",
	"light", 	# Use it in sunlight
	"dark", 	# Use it for night-dark mode
	"vibrant",
	"pro",
	"access",	# better accessibility
	"print",	# for better

	# Thre levels of gray
	"gray",
	"lightgray",
	"darkgray"
]

$cDefaultColorTheme = "neutral"
$cNeutralNodeColor = "white"

# Initialize theme palettes after ResolveColor is defined
$aPalette = [
	:neutral = [
		:primary = $cNeutralNodeColor,
		:success = "green",
		:warning = "orange",
		:danger = "red",
		:info = $cNeutralNodeColor,
		:neutral = $cNeutralNodeColor,
		:background = $cNeutralNodeColor
	],

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


func ColorThemes()
	return $acColorThemes

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
	
      oResolver = new stzColorResolver()
      return oResolver.ResolveWithPalette(pColor, $acFullColorPalette)

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

func DefaultNodeColor()
	return ResolveColor($cDefaultNodeColor)

func ColorForNodeType(pcType)
	if HasKey($acColorsByNodeType, pcType)
		return ResolveColor($acColorsByNodeType[pcType])
	ok
	return ResolveColor($cDefaultNodeColor)

