# Narrative
# --------
# HANDLING XML (uniform treatment)
#
# Extracted from stzHtmlTest.ring, block #8.

load "../../../stzBase.ring"


pr()

cSampleXml = `
<books>
	<book id="1"><title>Book1</title></book>
	<book id="2"><title>Book2</title></book>
</books>
`

oXml = HtmlQ(cSampleXml)     # Treated as HTML/XML

? oXml.IsValid()             #--> TRUE
aBooks = oXml.Find("book")
? len(aBooks)                #--> 2
? aBooks[1].Attr("id")       #--> "1"
? aBooks[1].FindFirst("title").Text()  #--> "Book1"

? oXml.ToXml()               #--> The original XML

pf()
# Executed in almost 0 second(s) in Ring 1.22
