# Integration regression suite for stzListOfBytes.
# Covers construction (string-based), Content / Bytes / ToString,
# NumberOfBytes, NLeftBytes / NRightBytes, Section / Range,
# InsertNBytesOfSubstringAt, RemoveNBytesStartingAt /
# RemoveNBytesFromEnd, UnicodeOfNthByte, Clear, IsEmpty, edges.
#
# Run from base/number/test/.

load "../../stzBase.ring"

nPsd = 0
nFld = 0
nTtl = 0

? "=== stzListOfBytes integration regression ==="

# ------------------------------------------------------------
# Construction + accessors
# ------------------------------------------------------------
? ""
? "--- Construction ---"

oLb = new stzListOfBytes("Hello, World!")
chk("NumberOfBytes = 13",           oLb.NumberOfBytes() = 13)
chk("ToString preserves data",      oLb.ToString() = "Hello, World!")
chk("IsEmpty = 0",                  oLb.IsEmpty() = 0)

# ------------------------------------------------------------
# Left / Right N bytes
# ------------------------------------------------------------
? ""
? "--- Left / Right slicing ---"

chk("NLeftBytes(5) = 'Hello'",      oLb.NLeftBytes(5) = "Hello")
chk("LeftNBytes alias",             oLb.LeftNBytes(5) = "Hello")
chk("NRightBytes(6) = 'World!'",    oLb.NRightBytes(6) = "World!")
chk("RightNBytes alias",            oLb.RightNBytes(6) = "World!")

# ------------------------------------------------------------
# Section / Range
# ------------------------------------------------------------
? ""
? "--- Section / Range ---"

# "Hello, World!" : positions 1..5 = "Hello", 8..12 = "World"
chk("Section(1, 5) = 'Hello'",      oLb.Section(1, 5) = "Hello")
chk("Section(8, 12) = 'World'",     oLb.Section(8, 12) = "World")

chk("Range(1, 5) = 'Hello'",        oLb.Range(1, 5) = "Hello")
chk("Range(8, 5) = 'World'",        oLb.Range(8, 5) = "World")

# ------------------------------------------------------------
# UnicodeOfNthByte (ASCII codes)
# ------------------------------------------------------------
? ""
? "--- UnicodeOfNthByte ---"

chk("UnicodeOfNthByte(1) = 72 (H)", oLb.UnicodeOfNthByte(1) = 72)
chk("UnicodeOfNthByte(13) = 33 (!)", oLb.UnicodeOfNthByte(13) = 33)

# Out-of-range -> -1 sentinel
chk("UnicodeOfNthByte(0) = -1",     oLb.UnicodeOfNthByte(0) = -1)
chk("UnicodeOfNthByte(100) = -1",   oLb.UnicodeOfNthByte(100) = -1)

# ------------------------------------------------------------
# Insert / Remove / Replace
# ------------------------------------------------------------
? ""
? "--- Insert / Remove ---"

oIns = new stzListOfBytes("HelloWorld")
oIns.InsertNBytesOfSubstringAt(6, 2, ", ")
chk("Insert produces 'Hello, World'", oIns.ToString() = "Hello, World")

oRm = new stzListOfBytes("Hello, World!")
oRm.RemoveNBytesStartingAt(6, 2)  # remove ", "
chk("Remove 2 bytes at pos 6",       oRm.ToString() = "HelloWorld!")

oRme = new stzListOfBytes("Hello!")
oRme.RemoveNBytesFromEnd(1)
chk("RemoveNBytesFromEnd(1)",        oRme.ToString() = "Hello")

# Replace: replace 5 bytes starting at position 1 with first 5 bytes of "HELLO"
oRp = new stzListOfBytes("Hello, World!")
oRp.ReplaceNBytes(5, 1, 5, "HELLO")
chk("ReplaceNBytes upper",           oRp.ToString() = "HELLO, World!")

# ------------------------------------------------------------
# Clear
# ------------------------------------------------------------
? ""
? "--- Clear ---"

oCl = new stzListOfBytes("data")
oCl.Clear()
chk("After Clear: empty",            oCl.IsEmpty() = 1)
chk("After Clear: NumberOfBytes = 0", oCl.NumberOfBytes() = 0)

# ------------------------------------------------------------
# Edges
# ------------------------------------------------------------
? ""
? "--- Edges ---"

# Empty
oEm = new stzListOfBytes("")
chk("Empty NumberOfBytes = 0",      oEm.NumberOfBytes() = 0)
chk("Empty IsEmpty = 1",            oEm.IsEmpty() = 1)
chk("Empty ToString = ''",          oEm.ToString() = "")

# Single byte
oOne = new stzListOfBytes("A")
chk("Single NumberOfBytes = 1",     oOne.NumberOfBytes() = 1)
chk("Single Section(1,1) = 'A'",    oOne.Section(1, 1) = "A")
chk("Single UnicodeOfNthByte = 65", oOne.UnicodeOfNthByte(1) = 65)

# Construction from another stzListOfBytes
oSrc = new stzListOfBytes("source")
oCopy = new stzListOfBytes(oSrc)
chk("Copy ctor preserves data",     oCopy.ToString() = "source")
chk("Copy ctor preserves length",   oCopy.NumberOfBytes() = 6)

# ------------------------------------------------------------
# Summary
# ------------------------------------------------------------
? ""
? "=========================="
? "Total:  " + nTtl
? "Passed: " + nPsd
? "Failed: " + nFld
if nFld = 0
	? "ALL stzListOfBytes CHECKS PASSED!"
else
	? "SOME stzListOfBytes CHECKS FAILED!"
ok

func chk(cLabel, bCond)
	nTtl++
	if bCond
		nPsd++
	else
		nFld++
		? "  FAIL: " + cLabel
	ok
