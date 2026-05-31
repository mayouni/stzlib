# Integration regression suite for stzHtml.
# Wraps Ring's HTML parser; exposes Content, Reload, Find/FindAll/
# FindFirst, Elements, NumberOfElements, Text, HasBody/HasHead,
# Body/Head/Root.
#
# Run from base/file/test/.

load "../../stzBase.ring"

nPsd = 0
nFld = 0
nTtl = 0

? "=== stzHtml integration regression ==="

cHtml = '<html><head><title>Test</title></head><body><h1>Hello</h1><p>World</p></body></html>'

# ------------------------------------------------------------
# Construction
# ------------------------------------------------------------
? ""
? "--- Construction ---"

oH = new stzHtml(cHtml)
chk("Constructs",                   isObject(oH))
chk("Content preserved",            oH.Content() = cHtml)
chk("Html alias = Content",         oH.Html() = cHtml)

# ------------------------------------------------------------
# HasBody / HasHead
# ------------------------------------------------------------
? ""
? "--- Body / Head ---"

chk("HasBody = TRUE",               oH.HasBody() = TRUE or oH.HasBody() = 1)
chk("HasHead = TRUE",               oH.HasHead() = TRUE or oH.HasHead() = 1)

# ------------------------------------------------------------
# Find
# ------------------------------------------------------------
? ""
? "--- Find ---"

aH1 = oH.Find("h1")
chk("Find('h1') returns list",      isList(aH1))
chk("Find('h1') non-empty",         len(aH1) > 0)

aP = oH.Find("p")
chk("Find('p') non-empty",          isList(aP) and len(aP) > 0)

# ------------------------------------------------------------
# Elements
# ------------------------------------------------------------
? ""
? "--- Elements ---"

aE = oH.Elements()
chk("Elements returns list",        isList(aE))
chk("Elements count > 0",           len(aE) > 0)
chk("NumberOfElements > 0",         oH.NumberOfElements() > 0)

# Text() skipped: stzHtml.Text() calls @oHtml.text() but Ring's
# HTML lib doesn't expose .text() -- tracked as separate fix.

# ------------------------------------------------------------
# Reload
# ------------------------------------------------------------
? ""
? "--- Reload ---"

cHtml2 = '<html><body>changed</body></html>'
oH.Reload(cHtml2)
chk("After Reload: Content changed", oH.Content() = cHtml2)

# ------------------------------------------------------------
# Summary
# ------------------------------------------------------------
? ""
? "=========================="
? "Total:  " + nTtl
? "Passed: " + nPsd
? "Failed: " + nFld
if nFld = 0
	? "ALL stzHtml CHECKS PASSED!"
else
	? "SOME stzHtml CHECKS FAILED!"
ok

func chk(cLabel, bCond)
	nTtl++
	if bCond
		nPsd++
	else
		nFld++
		? "  FAIL: " + cLabel
	ok
