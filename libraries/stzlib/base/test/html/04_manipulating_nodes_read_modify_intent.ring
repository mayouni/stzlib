# Narrative
# --------
# MANIPULATING NODES (read + modify intent)
#
# Extracted from stzHtmlTest.ring, block #4.

load "../../stzBase.ring"


pr()

oHtml = HtmlQ(cSampleHtml)

oBody = oHtml.Body()
oBody.AddKlass("main")       
? oBody.Klass()              #--> "main"

oPara = oBody.FindFirst("p")
oPara.SetAttr("id", "first")
? oPara.Id()                 #--> "first"
? oPara.HasAttr("id")        #--> TRUE

oPara.SetText("Updated text")
? oPara.Text()               #--> "Updated text"

oPara.RemoveKlass("intro")
? oPara.Klass()              #--> NULL or ""

# Navigation
oH1 = oBody.FirstChild()
? oH1.Tag()                  #--> "h1"
? oH1.NextSibling().Tag()    #--> "p"

pf()
# Executed in almost 0 second(s) in Ring 1.22
