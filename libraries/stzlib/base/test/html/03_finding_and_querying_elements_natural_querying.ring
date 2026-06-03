# Narrative
# --------
# FINDING AND QUERYING ELEMENTS (natural querying)
#
# Extracted from stzHtmlTest.ring, block #3.

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
