# Integration regression suite for stzDiagramColor utilities.
# Color-table lookups, hex<->RGB conversions, attenuate/intensify.
#
# Run from base/graph/test/.
#ERR Error (C22) : Function redefinition, function is already defined!

load "../../stzBase.ring"

nPsd = 0
nFld = 0
nTtl = 0

? "=== stzDiagramColor integration regression ==="

# ------------------------------------------------------------
# HexToRGB / RGBToHex
# ------------------------------------------------------------
? ""
? "--- Hex <-> RGB ---"

aR = StzHexToRGB("#FF0000")
chk("StzHexToRGB('#FF0000') = [255,0,0]", aR[1] = 255 and aR[2] = 0 and aR[3] = 0)

aG = StzHexToRGB("00FF00")  # no leading #
chk("StzHexToRGB('00FF00') = [0,255,0]",  aG[1] = 0 and aG[2] = 255 and aG[3] = 0)

# Invalid length -> sentinel
aBad = StzHexToRGB("12345")
chk("Invalid hex returns [128,128,128]",  aBad[1] = 128 and aBad[2] = 128 and aBad[3] = 128)

cHx = StzRGBToHex(255, 0, 0)
chk("StzRGBToHex(255,0,0) = '#FF0000'",   cHx = "#FF0000")

cHg = StzRGBToHex(0, 0, 0)
chk("StzRGBToHex(0,0,0) = '#000000'",     cHg = "#000000")

cHwhite = StzRGBToHex(255, 255, 255)
chk("StzRGBToHex(255,255,255) = '#FFFFFF'", cHwhite = "#FFFFFF")

# Clamping at boundaries
cClamp = StzRGBToHex(300, -50, 128)
chk("RGBToHex clamps 300 -> 255",         left(cClamp, 3) = "#FF")

# Aliases
chk("HexToRGB alias",                     HexToRGB("#FF0000")[1] = 255)
chk("RGBToHex alias",                     RGBToHex(255, 0, 0) = "#FF0000")

# ------------------------------------------------------------
# Round-trip
# ------------------------------------------------------------
? ""
? "--- Round-trip ---"

aMid = StzHexToRGB("#808080")
chk("#808080 -> [128,128,128]",           aMid[1] = 128)
cBack = StzRGBToHex(aMid[1], aMid[2], aMid[3])
chk("Round-trip preserves #808080",       cBack = "#808080")

# ------------------------------------------------------------
# StzPalette / StzColorThemes
# ------------------------------------------------------------
? ""
? "--- Palette ---"

aP = StzPalette()
chk("StzPalette returns",                 isList(aP) or isString(aP))

aT = StzColorThemes()
chk("StzColorThemes returns",             aT != NULL)

# Palette alias
aP2 = Palette()
chk("Palette alias works",                aP2 != NULL)

# ------------------------------------------------------------
# Summary
# ------------------------------------------------------------
? ""
? "=========================="
? "Total:  " + nTtl
? "Passed: " + nPsd
? "Failed: " + nFld
if nFld = 0
	? "ALL stzDiagramColor CHECKS PASSED!"
else
	? "SOME stzDiagramColor CHECKS FAILED!"
ok

func chk(cLabel, bCond)
	nTtl++
	if bCond
		nPsd++
	else
		nFld++
		? "  FAIL: " + cLabel
	ok
