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

	# THROUGH StzTryResolveColor, not straight to the palette. The lenient
	# and strict paths must run the SAME lookup or they answer differently
	# -- which is exactly what happened the moment role steps were added:
	# the strict path learned `danger.surface`, this one did not, and every
	# step silently became the neutral fallback (#FFFFFF). The guard read
	# five identical whites while the RENDERED steps were visibly
	# different, because the canvas takes the strict path.
	#
	# One lookup, two policies. The policy is the only thing that differs.
	_r_ = StzTryResolveColor(pColor)

	# The lookup answers "" when it does not know the name. THIS is the one
	# place that decides what to do about it, and it decides visibly: the
	# neutral node colour, not blue. Callers that would rather refuse than
	# be given a substitute use StzTryResolveColor.
	if _r_ = ""
		return $acFullColorPalette[ StzLower($cNeutralNodeColor) ]
	ok
	return _r_

	func ResolveColor(pColor)
		return StzResolveColor(pColor)

# The same lookup, WITHOUT the substitution: "" means "I do not know this".
# A face that paints something the author did not ask for is worse than a
# face that says so.
# ROLE STEPS (C2 of SOFTANZA_COLOR_SYSTEM.md).
#
# A shade says HOW LIGHT. It never says WHAT FOR, so every face invented
# its own convention for which shade is a border and which is a fill, and
# they drifted. Radix's insight is that a step should be a ROLE:
#
#     :Danger.Surface   a tinted container background
#     :Danger.Border    a border that reads against Surface
#     :Danger.Solid     the filled control            (same as :Danger)
#     :Danger.Text      text on the app background
#     :OnDanger         what can be READ on the solid (the Material pair)
#
# Four steps rather than Radix's twelve -- the ones this library actually
# draws -- plus the pair. Generated from the OKLCH ramp, so they are
# monotonic and evenly spaced by construction (C1), and hue-stable, which
# is what stops :Danger.Surface being a different colour from :Danger.
# A FUNCTION, not a global. A global assigned after a func definition in
# this file becomes part of that func's body and never executes -- the trap
# stzColor.ring already carries a note about. It cost one R5 here.
func StzRoleStepL(pcStep)
	switch StzLower("" + pcStep)
	on "surface"  return 0.95
	on "border"   return 0.80
	on "solid"    return 0.62
	on "text"     return 0.42
	off
	return -1

func StzRoleStepNames()
	return [ :Surface, :Border, :Solid, :Text ]

# "danger.surface" -> [ "danger", "surface" ], anything else -> []
func _StzSplitRoleStep(pcExpr)
	_c_ = StzLower(ring_trim("" + pcExpr))
	_n_ = StzFindFirst(".", _c_)
	if _n_ < 2 or _n_ >= len(_c_)  return []  ok
	_base_ = StzSubStr(_c_, 1, _n_ - 1)
	_step_ = StzSubStr(_c_, _n_ + 1, len(_c_) - _n_)
	for _k_ in StzRoleStepNames()
		if StzLower("" + _k_) = _step_  return [ _base_, _step_ ]  ok
	next
	return []

func StzTryResolveColor(pColor)
	if len($acFullColorPalette) = 0
		$acFullColorPalette = StzBuildColorPalette()
	ok

	_c_ = StzLower(ring_trim("" + pColor))

	# :OnDanger -- the foreground DECLARED for a fill, rather than a
	# contrast computed afresh at every call site. Resolved before the
	# palette lookup because "on..." is not a colour name.
	if len(_c_) > 2 and StzSubStr(_c_, 1, 2) = "on"
		_rest_ = StzSubStr(_c_, 3, len(_c_) - 2)
		if _rest_ != "" and StzIsKnownColorBase(_rest_)
			return StzResolveColor(StzContrastingText(_rest_))
		ok
	ok

	# base.step
	_aRS_ = _StzSplitRoleStep(_c_)
	if len(_aRS_) = 2
		_o1_ = new stzColorResolver()
		_seed_ = _o1_.ResolveWithPalette(_aRS_[1], $acFullColorPalette)
		if _seed_ = ""  return ""  ok
		return StzColorAtLightness(_seed_, StzRoleStepL(_aRS_[2]))
	ok

	_o_ = new stzColorResolver()
	return _o_.ResolveWithPalette(pColor, $acFullColorPalette)

# Does this name resolve WITHOUT going through the step machinery? Used by
# the :On... path so that "online" is not mistaken for "on" + "line".
func StzIsKnownColorBase(pColor)
	if len($acFullColorPalette) = 0
		$acFullColorPalette = StzBuildColorPalette()
	ok
	_o_ = new stzColorResolver()
	return _o_.ResolveWithPalette(pColor, $acFullColorPalette) != ""

# Any colour, re-lit to a perceptual lightness, through the ENGINE's OKLCH
# ramp. This is the one place a role step is turned into a colour, so the
# four steps cannot drift apart from each other.
func StzColorAtLightness(pColor, pnL)
	_hex_ = StzResolveColor(pColor)
	_a_ = StzHexToRGB(_hex_)
	_v_ = StzEngineColorRampStep(_a_[1] * 65536 + _a_[2] * 256 + _a_[3], pnL)
	_r_ = floor(_v_ / 65536)
	_g_ = floor((_v_ - _r_ * 65536) / 256)
	_b_ = _v_ - _r_ * 65536 - _g_ * 256
	return StzRGBToHex(_r_, _g_, _b_)

func StzIsKnownColor(pColor)
	return StzTryResolveColor(pColor) != ""

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
	if StzFindFirst("#", _cHex_)
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

