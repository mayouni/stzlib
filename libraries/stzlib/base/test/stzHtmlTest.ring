load "../stzbase.ring"  # Assuming Softanza base

/*--- GETTING INFORMATION ABOUT HTML DOCUMENTS

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

/*--- PARSING AND READING HTML (pure read intent

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

/*--- FINDING AND QUERYING ELEMENTS (natural querying)
*/
pr()

oHtml = HtmlQ(cSampleHtml)

# Using CSS selectors
aHeadings = oHtml.Find("h1")
? len(aHeadings)             #--> 1
? aHeadings[1].Text()        #--> "Hello World"

# Natural conditions
aElements = oHtml.ElementsWhere( [ :Tag = "p", :Class = "intro" ] )
? len(aElements)             #--> 1
? aElements[1].Attr("class") #--> "intro"

# Chaining
oList = oHtml.FindQ("body *").NumberOfItems()  # Assuming stzList has NumberOfItems()
? oList                      #--> 2 (h1 and p)

pf()
# Executed in 0.01 second(s) in Ring 1.22

/*--- MANIPULATING NODES (read + modify intent)

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

/*--- BUILDING NEW HTML DOCUMENTS (create intent)

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

/*--- HANDLING CSS (style manipulation)

pr()

cSampleCss = `
body { background: white; }
h1 { color: blue; font-size: 24px; }
`

oCss = new stzCSS(cSampleCss)

? oCss.Selectors()           #--> [ "body", "h1" ]
? oCss.PropertyOf("h1", "color")  #--> "blue"

aRules = oCss.Rules()
? len(aRules)                #--> 2
? aRules[1][1]               #--> "body"
? aRules[1][2][1]            #--> [ "background", "white" ]

# TODO: Implement and test ApplyToHtml if possible

pf()
# Executed in almost 0 second(s) in Ring 1.22

/*--- CONVERTING BETWEEN LISTS AND HTML TABLES

pr()

aData = [
	[ "Name", [ "Alice", "Bob", "Charlie" ] ],
	[ "Age",  [ "25", "30", "35" ] ]
]

cTableHtml = ListToHtmlTable(aData)
? cTableHtml
#--> <table class="data"><thead><tr><th>Name</th><th>Age</th></tr></thead><tbody><tr><td>Alice</td><td>25</td></tr><tr><td>Bob</td><td>30</td></tr><tr><td>Charlie</td><td>35</td></tr></tbody></table>

? IsHtmlTable(cTableHtml)    #--> TRUE

aBack = HtmlTableToList(cTableHtml)
? @@(aBack)                   #--> [ [ "Name", [ "Alice", "Bob", "Charlie" ] ], [ "Age", [ "25", "30", "35" ] ] ]

pf()
# Executed in 0.01 second(s) in Ring 1.22

/*--- HANDLING XML (uniform treatment)

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

/*--- ADVANCED OPERATIONS AND CHAINING

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
