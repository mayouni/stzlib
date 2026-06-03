# Narrative
# --------
# ADVANCED OPERATIONS AND CHAINING
#
# Extracted from stzHtmlTest.ring, block #9.

load "../../stzBase.ring"


pr()

oHtml = HtmlQ(cSampleHtml)

oHtml.FindFirstQ("p").SetAttrQ("style", "color:red").RemoveAttr("class")
? oHtml.FindFirst("p").Html()  #--> <p style="color:red">This is a test paragraph.</p>

oNewNode = new stzHtmlNode( oHtml.@oHtml.createNode("div") )
oNewNode.SetAttr("id", "container")
oBody = oHtml.Body()
oBody.InsertBefore(oNewNode)

? oHtml.Html()               # Shows updated HTML with new div

pf()
# Executed in 0.01 second(s) in Ring 1.22
