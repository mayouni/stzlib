# Class-level regression suite for stzNumber.
# Covers the most-used surface: construction, content/conversion,
# arithmetic, comparison, predicates, mutation, edges. Catches
# class-level regressions that the engine-direct test wouldn't.
#
# Run from base/number/test/.

load "../../stzBase.ring"

nPsd = 0
nFld = 0
nTtl = 0

? "=== stzNumber regression suite ==="

# ------------------------------------------------------------
# Construction + Content
# ------------------------------------------------------------
? ""
? "--- Construction + Content ---"

oN1 = new stzNumber(42)
chk("init(42).Content() = 42",            oN1.Content() = 42)
chk("init(42).Number() = 42",             oN1.Number() = 42)

oN2 = new stzNumber("3.14")
chk("init('3.14').NumericValue near pi",  oN2.NumericValue() > 3.13 and oN2.NumericValue() < 3.15)

oN3 = new stzNumber(-7)
chk("init(-7).Content() = -7",            oN3.Content() = -7)

oN0 = new stzNumber(0)
chk("init(0).Content() = 0",              oN0.Content() = 0)
chk("init(0).IsZero() = 1",               oN0.IsZero() = 1)

# ------------------------------------------------------------
# Conversions
# ------------------------------------------------------------
? ""
? "--- Conversions ---"

oNs = new stzNumber(42)
chk("StringValue of 42 = '42'",           oNs.StringValue() = "42")

oNf = new stzNumber(3.14)
sv = oNf.StringValue()
chk("StringValue of 3.14 starts '3.14'",  isString(sv) and left(sv,4) = "3.14")

# Sign
oNp = new stzNumber(5)
chk("NumberWithSign(5) starts '+'",       left(oNp.NumberWithSign(),1) = "+")
oNn = new stzNumber(-5)
chk("NumberWithSign(-5) starts '-'",      left(oNn.NumberWithSign(),1) = "-")

# ------------------------------------------------------------
# Predicates: parity, sign, integer/real
# ------------------------------------------------------------
? ""
? "--- Predicates ---"

oN4 = new stzNumber(4)
chk("IsInteger(4) = 1",                   oN4.IsInteger() = 1)
chk("IsOdd(4) = 0",                       oN4.IsOdd() = 0)
chk("IsEven(4) = 1",                      oN4.IsEven() = 1)
chk("IsPositive(4) = 1",                  oN4.IsPositive() = 1)

oN5 = new stzNumber(7)
chk("IsOdd(7) = 1",                       oN5.IsOdd() = 1)
chk("IsEven(7) = 0",                      oN5.IsEven() = 0)

oNr = new stzNumber(3.14)
chk("IsReal(3.14) = 1",                   oNr.IsReal() = 1)
chk("IsInteger(3.14) = 0",                oNr.IsInteger() = 0)

oNneg = new stzNumber(-3)
chk("IsNegative(-3) = 1",                 oNneg.IsNegative() = 1)
chk("IsPositive(-3) = 0",                 oNneg.IsPositive() = 0)

# Multiple-of family
oN12 = new stzNumber(12)
chk("12.IsMultipleOf(3) = 1",             oN12.IsMultipleOf(3) = 1)
chk("12.IsMultipleOf(5) = 0",             oN12.IsMultipleOf(5) = 0)
chk("12.IsDoubleOf(6) = 1",               oN12.IsDoubleOf(6) = 1)
chk("12.IsTripleOf(4) = 1",               oN12.IsTripleOf(4) = 1)
chk("12.IsQuadrupleOf(3) = 1",            oN12.IsQuadrupleOf(3) = 1)

# Bounds
oN8 = new stzNumber(8)
chk("8.IsBoundedBy(5,10) = 1",            oN8.IsBoundedBy(5, 10) = 1)
chk("8.IsBoundedBy(10,15) = 0",           oN8.IsBoundedBy(10, 15) = 0)

# ------------------------------------------------------------
# Update / mutation
# ------------------------------------------------------------
? ""
? "--- Update ---"

oU = new stzNumber(10)
oU.Update(99)
chk("Update(99) mutates content",         oU.Content() = 99)

oU2 = new stzNumber(5)
oU2.UpdateWith(50)
chk("UpdateWith(50) mutates",             oU2.Content() = 50)

oU3 = new stzNumber(7)
ret = oU3.UpdateQ(70)
chk("UpdateQ returns This",               isObject(ret))
chk("UpdateQ also mutates",               oU3.Content() = 70)

# ------------------------------------------------------------
# Digit / Unicode
# ------------------------------------------------------------
? ""
? "--- Digit / Unicode ---"

oNd = new stzNumber(7)
chk("IsADigit(7) = 1",                    oNd.IsADigit() = 1)
chk("IsOneDigit(7) = 1",                  oNd.IsOneDigit() = 1)

oN99 = new stzNumber(99)
chk("IsOneDigit(99) = 0",                 oN99.IsOneDigit() = 0)

# ------------------------------------------------------------
# Edge values
# ------------------------------------------------------------
? ""
? "--- Edges ---"

oNbig = new stzNumber(1234567890)
chk("big int Content",                    oNbig.Content() = 1234567890)
chk("big int IsInteger",                  oNbig.IsInteger() = 1)

oNtiny = new stzNumber(0.001)
chk("tiny float IsReal",                  oNtiny.IsReal() = 1)
chk("tiny float IsPositive",              oNtiny.IsPositive() = 1)

# One-percent helpers (global funcs)
chk("OnePercentOf(200) = 2",              OnePercentOf(200) = 2)
chk("OnePercent(50) = 0.5",               OnePercent(50) = 0.5)

# ------------------------------------------------------------
# Summary
# ------------------------------------------------------------
? ""
? "=========================="
? "Total:  " + nTtl
? "Passed: " + nPsd
? "Failed: " + nFld
if nFld = 0
	? "ALL stzNumber CHECKS PASSED!"
else
	? "SOME stzNumber CHECKS FAILED!"
ok

func chk(cLabel, bCond)
	nTtl++
	if bCond
		nPsd++
	else
		nFld++
		? "  FAIL: " + cLabel
	ok
