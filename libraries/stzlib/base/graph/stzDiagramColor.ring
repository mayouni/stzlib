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


func StzColorThemes()
	return $acColorThemes

	func ColorThemes()
		return StzColorThemes()

# Generate color intensities: color--, color-, color, color+, color++
func StzGenerateColorIntensities(_cColorName_, cHexValue)
	_aIntensities_ = []

	_aRGB_ = StzHexToRGB(cHexValue)
	_nR_ = _aRGB_[1]
	_nG_ = _aRGB_[2]
	_nB_ = _aRGB_[3]
	
	_nLum_ = 0.299 * _nR_ + 0.587 * _nG_ + 0.114 * _nB_
	
	if _nLum_ < 128  # Dark color
		# Base is original
		_aIntensities_[_cColorName_] = cHexValue
		
		# - : lighter (add ~64% white)
		_aIntensities_[_cColorName_ + "-"] = RGBToHex(
			min([255, _nR_ + floor((255 - _nR_) * 0.64)]),
			min([255, _nG_ + floor((255 - _nG_) * 0.64)]),
			min([255, _nB_ + floor((255 - _nB_) * 0.64)])
		)
		
		# -- : much lighter (add ~88% white)
		_aIntensities_[_cColorName_ + "--"] = RGBToHex(
			min([255, _nR_ + floor((255 - _nR_) * 0.88)]),
			min([255, _nG_ + floor((255 - _nG_) * 0.88)]),
			min([255, _nB_ + floor((255 - _nB_) * 0.88)])
		)
		
		# + : darker - for pure colors add 77 to zero channels, scale primary to 79%
		_nRedPlus_ = floor(_nR_ * 0.79)
		_nGreenPlus_ = floor(_nG_ * 0.79)
		_nBluePlus_ = floor(_nB_ * 0.79)
		
		if _nR_ = 0 and (_nG_ > 0 or _nB_ > 0)
			_nRedPlus_ = 77
		ok
		if _nG_ = 0 and (_nR_ > 0 or _nB_ > 0)
			_nGreenPlus_ = 77
		ok
		if _nB_ = 0 and (_nR_ > 0 or _nG_ > 0)
			_nBluePlus_ = 77
		ok
		
		_aIntensities_[_cColorName_ + "+"] = RGBToHex(
			max([0, _nRedPlus_]),
			max([0, _nGreenPlus_]),
			max([0, _nBluePlus_])
		)
		
		# ++ : much darker (scale to 40%)
		_aIntensities_[_cColorName_ + "++"] = RGBToHex(
			max([0, floor(_nR_ * 0.4)]),
			max([0, floor(_nG_ * 0.4)]),
			max([0, floor(_nB_ * 0.4)])
		)
		
	else  # Light color
		# Base is original
		_aIntensities_[_cColorName_] = cHexValue
		
		# - : lighter (64% to white)
		_aIntensities_[_cColorName_ + "-"] = RGBToHex(
			min([255, _nR_ + floor((255 - _nR_) * 0.64)]),
			min([255, _nG_ + floor((255 - _nG_) * 0.64)]),
			min([255, _nB_ + floor((255 - _nB_) * 0.64)])
		)
		
		# -- : much lighter (88% to white)
		_aIntensities_[_cColorName_ + "--"] = RGBToHex(
			min([255, _nR_ + floor((255 - _nR_) * 0.88)]),
			min([255, _nG_ + floor((255 - _nG_) * 0.88)]),
			min([255, _nB_ + floor((255 - _nB_) * 0.88)])
		)
		
		# + : darker (20% of original)
		_aIntensities_[_cColorName_ + "+"] = RGBToHex(
			max([0, floor(_nR_ * 0.2)]),
			max([0, floor(_nG_ * 0.2)]),
			max([0, floor(_nB_ * 0.2)])
		)
		
		# ++ : much darker (5% of original)
		_aIntensities_[_cColorName_ + "++"] = RGBToHex(
			max([0, floor(_nR_ * 0.05)]),
			max([0, floor(_nG_ * 0.05)]),
			max([0, floor(_nB_ * 0.05)])
		)
	ok
	
	return _aIntensities_

	func GenerateColorIntensities(_cColorName_, cHexValue)
		return StzGenerateColorIntensities(_cColorName_, cHexValue)

func StzBuildColorPalette()
	_aPalette_ = []
	_acKeys_ = keys($acColors)
	_nLen_ = len(_acKeys_)

	# Add base colors

	for i = 1 to _nLen_
		_cHex_ = $acColors[_acKeys_[i]]
		_aPalette_[_acKeys_[i]] = _cHex_
	end
	
	# Add all intensity variations

	for i = 1 to _nLen_
		_cHex_ = $acColors[_acKeys_[i]]
		_cColorName_ = "" + _acKeys_[i]
		_aIntensities_ = StzGenerateColorIntensities(_cColorName_, _cHex_)
		_acKeysInt_ = keys(_aIntensities_)
		_nLenInt_ = len(_acKeysInt_)

		for j = 1 to _nLenInt_
			_aPalette_[_acKeysInt_[j]] = _aIntensities_[_acKeysInt_[j]]
		end
	end

	return _aPalette_

	func BuildColorPalette()
		return StzBuildColorPalette()

func StzResolveColor(pColor)
	if len($acFullColorPalette) = 0
		$acFullColorPalette = StzBuildColorPalette()
	ok

	_oResolver_ = new stzColorResolver()
	return _oResolver_.ResolveWithPalette(pColor, $acFullColorPalette)

	func ResolveColor(pColor)
		return StzResolveColor(pColor)

func StzAttenuateColor(cColor)
    # Remove all intensity modifiers
    _cBase_ = replace(cColor, "++", "")
    _cBase_ = replace(_cBase_, "+", "")
    _cBase_ = replace(_cBase_, "--", "")
    _cBase_ = replace(_cBase_, "-", "")
    
    # Apply maximum attenuation
    return _cBase_ + "--"

	func AttenuateColor(cColor)
		return StzAttenuateColor(cColor)

func StzIntensifyColor(cColor)
    _cBase_ = replace(cColor, "++", "")
    _cBase_ = replace(_cBase_, "+", "")
    _cBase_ = replace(_cBase_, "--", "")
    _cBase_ = replace(_cBase_, "-", "")
    return _cBase_ + "++"

	func IntensifyColor(cColor)
		return StzIntensifyColor(cColor)

func StzHexToRGB(_cHex_)
	if StzFindFirst(_cHex_, "#")
		_cHex_ = StzMid(_cHex_, 2, StzLen(_cHex_) - 1)
	ok

	if StzLen(_cHex_) != 6
		return [128, 128, 128]
	ok

	_cR_ = StzMid(_cHex_, 1, 2)
	_cG_ = StzMid(_cHex_, 3, 2)
	_cB_ = StzMid(_cHex_, 5, 2)

	_nR_ = HexToDec(_cR_)
	_nG_ = HexToDec(_cG_)
	_nB_ = HexToDec(_cB_)

	return [_nR_, _nG_, _nB_]

	func HexToRGB(_cHex_)
		return StzHexToRGB(_cHex_)

func StzRGBToHex(_nR_, _nG_, _nB_)
	_nR_ = max([ 0, min([ 255, _nR_ ]) ])
	_nG_ = max([ 0, min([ 255, _nG_ ]) ])
	_nB_ = max([ 0, min([ 255, _nB_ ]) ])

	_cR_ = DecToHex(_nR_)
	_cG_ = DecToHex(_nG_)
	_cB_ = DecToHex(_nB_)

	if len(_cR_) = 1 _cR_ = "0" + _cR_ ok
	if len(_cG_) = 1 _cG_ = "0" + _cG_ ok
	if len(_cB_) = 1 _cB_ = "0" + _cB_ ok

	return "#" + StzUpper(_cR_) + StzUpper(_cG_) + StzUpper(_cB_)

	func RGBToHex(_nR_, _nG_, _nB_)
		return StzRGBToHex(_nR_, _nG_, _nB_)

func StzPalette()
	return $aPalette

	func Palette()
		return StzPalette()

func StzFontColors()
	return $aFontColors

	func FontColors()
		return StzFontColors()

func StzDefaultNodeColor()
	return StzResolveColor($cDefaultNodeColor)

	func DefaultNodeColor()
		return StzDefaultNodeColor()

func StzColorForNodeType(pcType)
	if HasKey($acColorsByNodeType, pcType)
		return StzResolveColor($acColorsByNodeType[pcType])
	ok
	return StzResolveColor($cDefaultNodeColor)

	func ColorForNodeType(pcType)
		return StzColorForNodeType(pcType)

