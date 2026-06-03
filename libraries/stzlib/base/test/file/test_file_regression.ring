# Integration regression suite for the stzFile / stzFileInfo family.
# Covers stzFileInfo (metadata without opening), stzFile (read/write),
# and the stzFileXT intent-based dispatcher.
#
# Run from base/file/test/.

load "../../stzBase.ring"

nPsd = 0
nFld = 0
nTtl = 0

? "=== stzFile family integration regression ==="

# Create a temp file for testing
cTmpFile = currentdir() + "/_test_stzfile_tmp.txt"
write(cTmpFile, "Hello Softanza!")

# ------------------------------------------------------------
# stzFileInfo: metadata-only (no open)
# ------------------------------------------------------------
? ""
? "--- stzFileInfo ---"

oFi = new stzFileInfo(cTmpFile)
chk("stzFileInfo constructs",        isObject(oFi))
chk("Exists() = TRUE",               oFi.Exists() = TRUE or oFi.Exists() = 1)
chk("Size() > 0",                    oFi.Size() > 0)
chk("IsReadable() = TRUE",           oFi.IsReadable() = TRUE or oFi.IsReadable() = 1)

# ------------------------------------------------------------
# stzFileXT dispatcher: "info" intent
# ------------------------------------------------------------
? ""
? "--- stzFileXT(info) ---"

bRaised = 0
try
	oXi = new stzFileXT(cTmpFile, "info")
catch
	bRaised = 1
done
chk("stzFileXT('info') doesn't raise", bRaised = 0)

# ------------------------------------------------------------
# stzFileXT bad intent
# ------------------------------------------------------------
? ""
? "--- stzFileXT bad intent ---"

bRaisedBad = 0
try
	oXBad = new stzFileXT(cTmpFile, "garbage")
catch
	bRaisedBad = 1
done
chk("Bad intent raises",             bRaisedBad = 1)

# Path helpers (_FileName / _FileDirPath / _FileExtension /
# _FileCompleteBaseName) are defined after the first class in
# stzFile.ring -- Ring parses them as methods of stzFileXT rather
# than global functions, so they're unreachable from outside the
# class. Tracked as a separate fix (move definitions above class).

# ------------------------------------------------------------
# Cleanup
# ------------------------------------------------------------
try
	remove(cTmpFile)
catch
done

# ------------------------------------------------------------
# Summary
# ------------------------------------------------------------
? ""
? "=========================="
? "Total:  " + nTtl
? "Passed: " + nPsd
? "Failed: " + nFld
if nFld = 0
	? "ALL stzFile CHECKS PASSED!"
else
	? "SOME stzFile CHECKS FAILED!"
ok

func chk(cLabel, bCond)
	nTtl++
	if bCond
		nPsd++
	else
		nFld++
		? "  FAIL: " + cLabel
	ok
