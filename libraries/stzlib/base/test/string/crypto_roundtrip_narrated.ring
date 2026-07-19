# stzStringCrypto ROUND-TRIPS -- every encode must have a decode that undoes it.
#
# This exists because the XOR cipher could not round-trip at all, and one
# ad-hoc diagnostic was the only thing in the tree that touched crypto -- and
# it had been unrunnable for six weeks. A whole cipher surface with one test
# on it.
#
# The defect class worth remembering: XOR output is BINARY, and every other
# cipher here (ROT13, Caesar, Vigenere, Atbash) permutes letters and stays in
# the text domain. The engine's string type validates UTF-8, correctly, so
# binary could not be handed back across the bridge for decryption. ASCII
# input hid it -- "Secret" against "key" produces only ASCII-range bytes and
# survived; two Arabic letters produce B5 D0 A1 E0, invalid UTF-8, and came
# back empty. So the multibyte cases below are the point of this file, not
# decoration.
#
# All non-ASCII text is built from RAW CODEPOINTS via a UTF-8 encoder.
#
# Ring traps avoided: main code before the first func (only the code above it
# runs); no local named oR / nL / Try / Show.

load "../../stzBase.ring"

nPass = 0
nFail = 0

pr()

cAr  = MkW([ 0x0639, 0x0645 ])                  # Arabic
cCJK = MkW([ 0x6771, 0x4EAC ])                  # CJK
cHeb = MkW([ 0x05E9, 0x05DC ])                  # Hebrew
cEmo = MkW([ 0x1F600 ])                         # 4-byte codepoint

? "-- Scene 1: the case that was broken --"
oX = new stzStringCrypto("Secret")
cX = oX.XorEncrypt("key")
oXb = new stzStringCrypto(cX)
chk("XorEncrypt then XorDecrypt returns the original", oXb.XorDecrypt("key") = "Secret")

# The plaintext and key share letters at positions 2 and 5, so the raw cipher
# contains two NUL bytes. That is exactly the shape that dies if anything on
# the path treats the payload as NUL-terminated.
chk("the cipher is text-safe (base64), so NULs cannot truncate it",
	StzFindFirst(char(0), cX) = 0)
chk("...and it is not just the plaintext back", cX != "Secret")

oW = new stzStringCrypto("Secret")
cW = oW.XorEncrypt("key")
oWb = new stzStringCrypto(cW)
chk("a WRONG key does not decrypt", oWb.XorDecrypt("KEY") != "Secret")

? ""
? "-- Scene 2: multibyte -- the half that used to vanish --"
aTexts = [ cAr, cCJK, cHeb, cEmo, cAr + cCJK + cHeb + cEmo,
	   cAr + " mixed with latin " + cCJK ]
aKeys  = [ "mixed", "k", "longerkeythantheactualtext", "p", "pass", cAr ]

nMb = 0
nMbLen = len(aTexts)
for iMb = 1 to nMbLen
	oE = new stzStringCrypto(aTexts[iMb])
	cC = oE.XorEncrypt(aKeys[iMb])
	oD = new stzStringCrypto(cC)
	if oD.XorDecrypt(aKeys[iMb]) = aTexts[iMb]
		nMb++
	ok
next
chk("every multibyte text round-trips byte-exact (" + nMb + "/" + nMbLen + ")", nMb = nMbLen)

# A multibyte KEY has to work too -- the key is used byte-wise, so a 4-byte
# Arabic key is just a 4-byte key.
oK = new stzStringCrypto("plain ascii text")
cK = oK.XorEncrypt(cAr)
oKb = new stzStringCrypto(cK)
chk("a MULTIBYTE key works", oKb.XorDecrypt(cAr) = "plain ascii text")

? ""
? "-- Scene 3: key and text of awkward relative sizes --"
oS1 = new stzStringCrypto("a")
cS1 = oS1.XorEncrypt("averylongpassphrase")
oS1b = new stzStringCrypto(cS1)
chk("key far longer than the text", oS1b.XorDecrypt("averylongpassphrase") = "a")

cLong = ""
for iL = 1 to 500
	cLong += "block" + iL + " "
next
oS2 = new stzStringCrypto(cLong)
cS2 = oS2.XorEncrypt("k")
oS2b = new stzStringCrypto(cS2)
chk("single-byte key over a " + len(cLong) + "-byte text", oS2b.XorDecrypt("k") = cLong)

oS3 = new stzStringCrypto("")
chk("empty text is handled", oS3.XorEncrypt("key") = "")

? ""
? "-- Scene 4: Obfuscate has an inverse now --"
# It did not. Obfuscate() reverses then XORs; undoing that is XOR then
# reverse, which is a different operation, so there was no way back.
oO = new stzStringCrypto("Hello World")
cO = oO.Obfuscated()
chk("Obfuscated() changes the text", cO != "Hello World")
oOb = new stzStringCrypto(cO)
chk("Deobfuscated() undoes it", oOb.Deobfuscated() = "Hello World")

oO2 = new stzStringCrypto(cAr + " and " + cCJK)
cO2 = oO2.Obfuscated()
oO2b = new stzStringCrypto(cO2)
chk("...on multibyte too", oO2b.Deobfuscated() = cAr + " and " + cCJK)

oM = new stzStringCrypto("Hello World")
oM.Obfuscate()
oM.Deobfuscate()
chk("the MUTATING pair agrees with the copy pair", oM.Content() = "Hello World")

? ""
? "-- Scene 5: the other ciphers still round-trip --"
oR1 = new stzStringCrypto("Attack at dawn")
cR1 = oR1.ROT13ed()
oR1b = new stzStringCrypto(cR1)
chk("ROT13 is its own inverse", oR1b.ROT13ed() = "Attack at dawn")

oC1 = new stzStringCrypto("Attack at dawn")
cC1 = oC1.CaesarEncrypted(5)
oC1b = new stzStringCrypto(cC1)
chk("Caesar +5 then -5", oC1b.CaesarEncrypted(-5) = "Attack at dawn")

oB1 = new stzStringCrypto(cAr + cCJK)
cB1 = oB1.Base64Encoded()
oB1b = new stzStringCrypto(cB1)
chk("Base64 round-trips multibyte", oB1b.Base64Decoded() = cAr + cCJK)

oA1 = new stzStringCrypto("attack")
cA1 = oA1.Atbashed()
oA1b = new stzStringCrypto(cA1)
chk("Atbash is its own inverse", oA1b.Atbashed() = "attack")

? ""
? "=========================================="
? "TOTAL: " + (nPass + nFail) + " assertions, " + nPass + " pass, " + nFail + " fail"
? "=========================================="

pf()

func chk cLabel, bCond
	if bCond
		nPass++
		? "  [OK] " + cLabel
	else
		nFail++
		? "  [FAIL] " + cLabel
	ok

# codepoint -> UTF-8 bytes, by arithmetic (no literals -> no mojibake risk)
func EncCp c
	if c < 128
		return char(c)
	but c < 2048
		return char(192 + floor(c/64)) + char(128 + (c % 64))
	but c < 65536
		return char(224 + floor(c/4096)) + char(128 + floor((c%4096)/64)) + char(128 + (c%64))
	else
		return char(240 + floor(c/262144)) + char(128 + floor((c%262144)/4096)) +
		       char(128 + floor((c%4096)/64)) + char(128 + (c%64))
	ok

func MkW aCp
	cW = ""
	_nCount_ = len(aCp)
	for _k_ = 1 to _nCount_
		cW += EncCp(aCp[_k_])
	next
	return cW
