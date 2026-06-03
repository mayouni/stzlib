# Narrative
# --------
# GETTING INFORMATION ABOUT HTML DOCUMENTS
#
# Extracted from stzHtmlTest.ring, block #1.

load "../../stzBase.ring"


pr()

oHtml = new stzHtml("<html><body>Hello</body></html>")

? oHtml.IsValid()
#--> TRUE

? oHtml.NumberOfElements()
#--> 3 (html, body, text node?)

? oHtml.Elements()

? oHtml.HasBody()
#--> TRUE

? oHtml.TagsUsed()
#--> [ "html", "body" ]

pf()
# Executed in 0.02 second(s) in Ring 1.22
