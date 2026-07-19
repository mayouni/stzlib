# stzHtml / HTML entity STRESS -- parsing, selecting, and the encode/decode
# round trip.
#
# Three places an HTML layer breaks, and this goes at all three:
#
#   1. THE ENCODE/DECODE ROUND TRIP. encode then decode must return the
#      original -- INCLUDING when the source already contained an entity. A
#      decoder that expands &amp; first and then scans again turns "&amp;lt;"
#      into "<" instead of leaving "&lt;", so anything double-encoded comes
#      back single-decoded. That is the defect this file was written for.
#   2. BUFFER LIMITS. A fixed output buffer silently drops everything past
#      its size. Encoding a document larger than the buffer must not return
#      an empty string.
#   3. MULTIBYTE. Parsing, .Text(), and the entity round trip all have to
#      carry Arabic / CJK / Hebrew through byte-for-byte, and CountByTag has
#      to agree with the length of what Find returns.
#
# All non-ASCII text is built from RAW CODEPOINTS via a UTF-8 encoder.
#
# Ring traps avoided: main code before the first func; no local oR / nL / Try
# / Show; no inline `new X().M()`; double-quote built via char(34) so the
# lexer cannot mis-see a literal.

load "../../stzBase.ring"

nPass = 0
nFail = 0

pr()

cQ    = char(34)                                        # a double quote
cAr   = MkW([ 0x0639, 0x0631, 0x0628, 0x064A ])         # Arabic
cCJK  = MkW([ 0x6771, 0x4EAC ])                         # CJK
cHeb  = MkW([ 0x05E9, 0x05DC ])                         # Hebrew

? "-- Scene 1: the encode/decode round trip, entities included --"
# The clean cases first -- these passed even against the broken decoder.
aClean = [ "<a>", "a & b", "x < y > z", "quote:" + cQ, "apostrophe:'", "plain" ]
nClean = 0
nCl = len(aClean)
for i = 1 to nCl
	oE = new stzString(aClean[i])
	cEnc = oE.HtmlEncoded()
	oD = new stzString(cEnc)
	if oD.HtmlDecoded() = aClean[i]
		nClean++
	ok
next
chk("clean text round-trips through encode/decode (" + nClean + "/" + nCl + ")", nClean = nCl)

# The double-encoded cases -- the ones the old decoder got wrong. "&amp;lt;"
# must decode to "&lt;", not "<": decoding &amp; yields a '&' that must NOT
# be allowed to start a fresh entity.
oDD = new stzString("&amp;lt;")
chk("&amp;lt; decodes to &lt;, NOT < (no re-trigger)", oDD.HtmlDecoded() = "&lt;")
oDD2 = new stzString("&amp;gt;")
chk("&amp;gt; decodes to &gt;", oDD2.HtmlDecoded() = "&gt;")
oDD3 = new stzString("&amp;amp;")
chk("&amp;amp; decodes to &amp;", oDD3.HtmlDecoded() = "&amp;")
oDD4 = new stzString("a &amp;lt; b &amp;gt; c")
chk("...and in the middle of real text", oDD4.HtmlDecoded() = "a &lt; b &gt; c")

# The true test: encode something that already has an entity, then decode.
cSrc = "already &lt;encoded&gt; and < raw >"
oRT = new stzString(cSrc)
cE = oRT.HtmlEncoded()
oRT2 = new stzString(cE)
chk("text with pre-existing entities survives a full round trip",
	oRT2.HtmlDecoded() = cSrc)

? ""
? "-- Scene 2: the buffer must not swallow a large document --"
# A fixed 64 KB buffer returned -1 on overflow, which the bridge turned into
# "". Encoding an 80 KB string produced EMPTY -- a whole document gone with
# no error.
cBig = ""
for i = 1 to 20000
	cBig += "a<b "
next
oBig = new stzString(cBig)
cBigEnc = oBig.HtmlEncoded()
? "  input " + len(cBig) + " bytes -> encoded " + len(cBigEnc) + " bytes"
chk("encoding an 80KB string does NOT return empty", len(cBigEnc) > 0)
chk("...it grew, because every < became &lt;", len(cBigEnc) > len(cBig))
oBigD = new stzString(cBigEnc)
chk("...and it decodes back to the exact original", oBigD.HtmlDecoded() = cBig)

? ""
? "-- Scene 3: widened coverage the old five-replace version lacked --"
# &apos; &nbsp; and numeric entities were left intact before; now decoded.
oW1 = new stzString("&apos;")
chk("&apos; decodes to an apostrophe", oW1.HtmlDecoded() = "'")
oW2 = new stzString("&#65;&#66;&#67;")
chk("numeric entities decode (&#65; -> A)", oW2.HtmlDecoded() = "ABC")
oW3 = new stzString("x&nbsp;y")
chk("&nbsp; decodes to a space", oW3.HtmlDecoded() = "x y")

? ""
? "-- Scene 4: parsing, and CountByTag agreeing with Find --"
cDoc = "<html><head><title>T</title></head><body>" +
       "<div id=" + cQ + "main" + cQ + " class=" + cQ + "box" + cQ + ">" +
       "<p class=" + cQ + "lead" + cQ + ">one</p><p>two</p></div>" +
       "<div class=" + cQ + "box" + cQ + "><span>three</span></div>" +
       "</body></html>"
oH = new stzHtml(cDoc)
chk("the document is valid", oH.IsValid())
chk("CountByTag('p') = 2", oH.CountByTag("p") = 2)
chk("CountByTag('p') AGREES with len(Find('p'))", oH.CountByTag("p") = len(oH.Find("p")))
chk("CountByTag('div') AGREES with len(Find('div'))", oH.CountByTag("div") = len(oH.Find("div")))
chk("class selector .box finds both boxes", len(oH.Find(".box")) = 2)
chk("id selector #main finds exactly one", len(oH.Find("#main")) = 1)

oMain = oH.FindFirst("#main")
chk("#main is a div", oMain.Tag() = "div")
chk("#main carries its id", oMain.Id() = "main")
chk("#main carries its class", oMain.HasKlass("box"))
chk("a missing selector finds nothing", len(oH.Find(".nope")) = 0)
chk("FindFirst on a miss is NULL", oH.FindFirst("#ghost") = NULL)

? ""
? "-- Scene 5: multibyte through parse and .Text() --"
cML = "<html><body>" +
      "<h1 id=" + cQ + "t" + cQ + ">" + cAr + "</h1>" +
      "<p class=" + cQ + "c" + cQ + ">" + cCJK + "</p>" +
      "<span>" + cHeb + "</span>" +
      "</body></html>"
oM = new stzHtml(cML)
oH1 = oM.FindFirst("#t")
chk("an Arabic heading reads back byte-identical", oH1.Text() = cAr)
oP = oM.FindFirst(".c")
chk("a CJK paragraph reads back byte-identical", oP.Text() = cCJK)
chk("whole-document Text() concatenates all scripts",
	oM.Text() = cAr + cCJK + cHeb)

# Multibyte through the entity round trip too.
oME = new stzString(cAr + " <x> " + cCJK)
cMEnc = oME.HtmlEncoded()
oMD = new stzString(cMEnc)
chk("multibyte text with a tag round-trips through encode/decode",
	oMD.HtmlDecoded() = cAr + " <x> " + cCJK)

? ""
? "-- Scene 6: scale, and CountByTag holding at size --"
cScale = "<html><body>"
for i = 1 to 800
	cScale += "<div class=" + cQ + "row" + cQ + ">item " + i + " " + cAr + "</div>"
next
cScale += "</body></html>"
? "  document is " + len(cScale) + " bytes"

t0 = clock()
oS = new stzHtml(cScale)
nEl = oS.NumberOfElements()
tParse = (clock() - t0) / clockspersecond()
? "  parse + count: " + tParse + "s, " + nEl + " elements"
chk("parsing 800 rows is fast (< 5s)", tParse < 5)
chk("it counted all of them (802 = 800 rows + html + body)", nEl = 802)

t0 = clock()
nRows = len(oS.Find(".row"))
tFind = (clock() - t0) / clockspersecond()
? "  Find('.row'): " + tFind + "s -> " + nRows + " nodes"
chk("class search at scale is now LINEAR, not quadratic (< 1s)", tFind < 1)
chk("CountByTag('div') AGREES with the class search", oS.CountByTag("div") = nRows)

? ""
? "-- Scene 7: malformed and empty inputs answer, not crash --"
oEmpty = new stzString("")
chk("encoding the empty string is empty, not a crash", oEmpty.HtmlEncoded() = "")
chk("decoding the empty string is empty", oEmpty.HtmlDecoded() = "")
oLone = new stzString("a & b < c")
chk("a bare & and < without a full entity round-trip",
	(new stzString(oLone.HtmlEncoded())).HtmlDecoded() = "a & b < c")
oUnclosed = new stzHtml("<html><body><div><p>hi</body></html>")
chk("an unclosed document still yields its text", oUnclosed.Text() = "hi")
oNotEntity = new stzString("100% & more")
chk("a & that is not an entity is left alone by decode", oNotEntity.HtmlDecoded() = "100% & more")

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
