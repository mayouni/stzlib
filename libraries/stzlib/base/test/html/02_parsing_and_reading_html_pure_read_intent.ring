# Narrative
# --------
# PARSING AND READING HTML (pure read intent
#
# Extracted from stzHtmlTest.ring, block #2.
#ERR Error (R14) : Calling Method without definition: text

load "../../stzBase.ring"


pr()

cSampleHtml = `
<html>
<head><title>Test</title></head>
<body>
<h1>Hello World</h1>
<p class="intro">This is a test paragraph.</p>
</body>
</html>
`

oHtml = HtmlQ(cSampleHtml)

? oHtml.IsValid()            #--> TRUE
? oHtml.Text()               #--> "TestHello WorldThis is a test paragraph."
? oHtml.NumberOfElements()   #--> ~5 (depending on parser)

aParagraphs = oHtml.Find("p")
? len(aParagraphs)           #--> 1
? aParagraphs[1].Text()      #--> "This is a test paragraph."
? aParagraphs[1].HasKlass("intro")  #--> TRUE

pf()
# Executed in almost 0 second(s) in Ring 1.22
