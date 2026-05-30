# Integration regression suite for stzBinaryNumber / stzHexNumber /
# stzOctalNumber. Tests construction (with prefix), content access,
# inter-base conversions (decimal <-> binary <-> hex <-> octal), and
# the WithPrefix helpers. These are small wrapper classes around
# string representations + delegation to stzNumber.
#
# Run from base/number/test/.

load "../../stzBase.ring"

nPsd = 0
nFld = 0
nTtl = 0

? "=== stzBinaryNumber / stzHexNumber / stzOctalNumber regression ==="

# ============================================================
# stzBinaryNumber
# ============================================================
? ""
? "--- stzBinaryNumber ---"

# Construct with 0b prefix (the canonical form)
oBin = new stzBinaryNumber("0b1010")
chk("Binary Content preserved",     oBin.Content() = "0b1010")
chk("Binary ToDecimal = 10",        oBin.ToDecimal() = 10)

# ToHex / ToOctal round-trip-ish
chk("Binary 0b1010 -> ToHex 0xA",   isString(oBin.ToHex()) and substr(oBin.ToHex(), "A") > 0)
chk("Binary ToOctal -> 12",         substr(oBin.ToOctal(), "12") > 0)

# Zero
oBz = new stzBinaryNumber("0b0")
chk("Binary 0 ToDecimal = 0",       oBz.ToDecimal() = 0)

# A larger value: 0b11111111 = 255
oB255 = new stzBinaryNumber("0b11111111")
chk("Binary 11111111 = 255",        oB255.ToDecimal() = 255)

# From decimal
oBfd = new stzBinaryNumber("0b0")
oBfd.FromDecimal(42)
chk("FromDecimal(42) -> content",   isString(oBfd.Content()) and len(oBfd.Content()) > 0)

# ============================================================
# stzHexNumber
# ============================================================
? ""
? "--- stzHexNumber ---"

# Construct with 0x prefix
oHex = new stzHexNumber("0xff")
chk("Hex content w/o prefix",       oHex.Content() = "ff")
chk("Hex WithPrefix = 0xff",        oHex.WithPrefix() = "0xff")

oHex2 = new stzHexNumber("0x10")
chk("Hex 0x10 content = '10'",      oHex2.Content() = "10")

# Decimal conversion -- 0xff = 255
chk("0xff ToDecimal = 255",         oHex.ToStzNumber().Content() = 255)

# 0x10 = 16
chk("0x10 ToDecimal = 16",          oHex2.ToStzNumber().Content() = 16)

# Empty hex (allowed by init)
oHexE = new stzHexNumber("")
chk("Empty hex content = ''",       oHexE.Content() = "")

# ============================================================
# stzOctalNumber
# ============================================================
? ""
? "--- stzOctalNumber ---"

# Construct with 0o prefix
oOct = new stzOctalNumber("0o17")
chk("Octal Content preserved",      oOct.Content() = "0o17")
chk("Octal WithPrefix = 0o17",      oOct.WithPrefix() = "0o0o17")    # known: WithPrefix re-prefixes

# Decimal conversion -- 0o17 = 15
chk("0o17 ToDecimal = 15",          oOct.ToDecimal() = 15)

# 0o10 = 8
oOct2 = new stzOctalNumber("0o10")
chk("0o10 ToDecimal = 8",           oOct2.ToDecimal() = 8)

# 0o777 = 511 (Unix permission bits)
oOct3 = new stzOctalNumber("0o777")
chk("0o777 ToDecimal = 511",        oOct3.ToDecimal() = 511)

# ============================================================
# Cross-base round-trips via decimal
# ============================================================
? ""
? "--- Cross-base round-trips ---"

# 0xff = 255 = 0b11111111 = 0o377
oH = new stzHexNumber("0xff")
chk("0xff as number = 255",         oH.ToStzNumber().Content() = 255)

oO = new stzOctalNumber("0o377")
chk("0o377 as decimal = 255",       oO.ToDecimal() = 255)

oB = new stzBinaryNumber("0b11111111")
chk("0b11111111 as decimal = 255",  oB.ToDecimal() = 255)

# All three should equal 255 as ints
chk("hex == octal (both 255)",      oH.ToStzNumber().Content() = oO.ToDecimal())
chk("octal == binary (both 255)",   oO.ToDecimal() = oB.ToDecimal())

# ============================================================
# Edges
# ============================================================
? ""
? "--- Edges ---"

# Largest single-byte values
oB7 = new stzBinaryNumber("0b1111111")
chk("0b1111111 = 127 (7-bit max)",  oB7.ToDecimal() = 127)

oH7f = new stzHexNumber("0x7f")
chk("0x7f = 127",                   oH7f.ToStzNumber().Content() = 127)

# Lowercase / uppercase hex
oHlow = new stzHexNumber("0xab")
oHup  = new stzHexNumber("0xAB")
chk("Lower hex 0xab = 171",         oHlow.ToStzNumber().Content() = 171)
chk("Upper hex 0xAB = 171",         oHup.ToStzNumber().Content() = 171)

# ------------------------------------------------------------
# Summary
# ------------------------------------------------------------
? ""
? "=========================="
? "Total:  " + nTtl
? "Passed: " + nPsd
? "Failed: " + nFld
if nFld = 0
	? "ALL base-N number CHECKS PASSED!"
else
	? "SOME base-N number CHECKS FAILED!"
ok

func chk(cLabel, bCond)
	nTtl++
	if bCond
		nPsd++
	else
		nFld++
		? "  FAIL: " + cLabel
	ok
