# Narrative
# --------
# BUILDING NEW HTML DOCUMENTS (create intent)
#
# Extracted from stzHtmlTest.ring, block #5.

load "../../../stzBase.ring"


pr()

oBuilder = new stzHtmlBuilder()

oHead = oBuilder.CreateNode("head")
oTitle = oBuilder.CreateNode("title")
oTitle.SetText("New Document")
oBuilder.AppendToCurrentQ(oHead).AppendToCurrentQ(oTitle)

oBody = oBuilder.CreateNode("body")
oBuilder.AppendToCurrent(oBody)

oBuilder.SetCurrent(oBody)
oH1 = oBuilder.CreateNode("h1")
oH1.SetText("Welcome")
oBuilder.AppendToCurrent(oH1)

? oBuilder.Build()
#--> <html><head><title>New Document</title></head><body><h1>Welcome</h1></body></html>

oBuilder.BuildToFile("new.html")

pf()
# Executed in 0.01 second(s) in Ring 1.22
