# A BUFFER OF ANY SIZE TURNS INTO TEXT -- narrated
#
# stz_bytes turned a buffer into text through fixed stack buffers: 4 KB for
# Left, Right, Mid, ToLower, ToUpper and 8 KB for ToBase64, ToHex,
# ToPercent. Past them the answer was "" with no error -- found when an
# image's base64 came back empty (2026-11-02, STZBYTES-BASE64-CAP-01). A
# negative count stopped the process with a panic. Every answer is now
# sized from the buffer, and a negative count gives an empty text.
#
#   Scene 1  small buffers answer as before
#   Scene 2  large buffers: every text, and the round trips back
#   Scene 3  negative counts: an empty text, the process alive

load "../../stzBase.ring"

$nPass = 0
$nFail = 0

pr()

? "-- Scene 1: small buffers answer as before --"

pH = StzEngineBytesFrom("Hello")
chk("Hello in base64 is SGVsbG8=", StzEngineBytesToBase64(pH) = "SGVsbG8=")
chk("...in hex 48656c6c6f", StzEngineBytesToHex(pH) = "48656c6c6f")
chk("Mid(2, 3) is ell, Left(2) He, Right(2) lo", StzEngineBytesMid(pH, 2, 3) = "ell" and
	StzEngineBytesLeft(pH, 2) = "He" and StzEngineBytesRight(pH, 2) = "lo")
pE = StzEngineBytesNew()
chk("an empty buffer gives an empty base64", StzEngineBytesToBase64(pE) = "")

? ""
? "-- Scene 2: large buffers --"

# 30,000 bytes covering every byte value, NULs included
cBig = ""
for i = 0 to 29999
	cBig += char(i % 256)
next
pL = StzEngineBytesFrom(cBig)
c64 = StzEngineBytesToBase64(pL)
chk("30,000 bytes give 40,000 base64 characters (the cap was 8,192)", len(c64) = 40000)
pBack = StzEngineBytesNew()
StzEngineBytesFromBase64(pBack, c64)
chk("...and they decode back to the same 30,000 bytes", StzEngineBytesData(pBack) = cBig)
chk("the library's stzBytes (stzListOfBytes) gives the same base64", new stzBytes(cBig).ToBase64() = c64)
cHex = StzEngineBytesToHex(pL)
chk("60,000 hex characters, the first ones 000102", len(cHex) = 60000 and left(cHex, 6) = "000102")
cPct = StzEngineBytesToPercent(pL)
chk("percent-encoding grows past 8 KB too (" + len(cPct) + " characters)", len(cPct) > 60000)
pBack2 = StzEngineBytesNew()
StzEngineBytesFromPercent(pBack2, cPct)
chk("...and decodes back", StzEngineBytesData(pBack2) = cBig)
chk("Left(10000), Right(10000) and Mid(5001, 10000) are 10,000 bytes each (the cap was 4,096)",
	len(StzEngineBytesLeft(pL, 10000)) = 10000 and len(StzEngineBytesRight(pL, 10000)) = 10000 and
	StzEngineBytesMid(pL, 5001, 10000) = right(left(cBig, 15000), 10000))
pT = StzEngineBytesFrom(copy("Softanza ", 2000))
chk("ToUpper on 18,000 bytes", StzEngineBytesToUpper(pT) = copy("SOFTANZA ", 2000))
chk("ToLower on 18,000 bytes", StzEngineBytesToLower(pT) = copy("softanza ", 2000))

? ""
? "-- Scene 3: negative counts --"

chk("Left(-1), Right(-1) and Mid(2, -1) give an empty text, and the process goes on",
	StzEngineBytesLeft(pH, -1) = "" and StzEngineBytesRight(pH, -1) = "" and StzEngineBytesMid(pH, 2, -1) = "")

aH = [ pH, pE, pL, pBack, pBack2, pT ]
for i = 1 to len(aH)
	StzEngineBytesFree(aH[i])
next

? ""
? "=========================================="
? "TOTAL: " + ($nPass + $nFail) + " assertions, " + $nPass + " pass, " + $nFail + " fail"
? "=========================================="

pfq()
shutdown($nFail)

func chk(cWhat, bCond)
	if bCond = 1
		$nPass++
		? "  [OK] " + cWhat
	else
		$nFail++
		? "  [FAIL] " + cWhat
	ok
