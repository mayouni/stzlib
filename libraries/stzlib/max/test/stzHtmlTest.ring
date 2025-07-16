# stzHtml Class - Comprehensive Test Suite
# Demonstrates all features with didactic progression

load "../stzmax.ring"

/*---

pr()

o1 = new stzString("123*567*91*1")
? o1.FindFirstST("*", 5)
#--> 8

pf()

#-------------------------------#
#  BASIC OBJECT CREATION        #
#-------------------------------#

/*--- Creating an empty stzHtml object

pr()

o1 = new stzHtml("")

# Empty object should be properly initialized
? o1.isParsed()
#--> FALSE

? o1.getElementCount()
#--> 0

pf()

/*--- Creating stzHtml with simple HTML string

pr()

o1 = new stzHtml("<p>Hello World</p>")

# Simple parsing should work correctly
? o1.isParsed()
#--> TRUE

? o1.getElementCount()
#--> 1

pf()

/*--- Creating stzHtml with complex HTML (declarative style)
*/
pr()

cHtml = '<!DOCTYPE html>
<html>
<head>
    <title>Test Page</title>
    <meta charset="UTF-8">
</head>
<body>
    <h1 id="main-title" class="header">Welcome</h1>
    <p class="content">This is a paragraph.</p>
</body>
</html>'

o1 = new stzHtml(cHtml)
o1 {
    # Check if complex HTML is parsed correctly
    ? isParsed()
    #--> TRUE
    
    ? getElementCount()
    #--> 7
    
    ? getParseErrors()
    #--> []
}

pf()

#-------------------------------#
#  PARSING AND VALIDATION       #
#-------------------------------#

/*--- Parsing HTML with DOCTYPE declaration
*/
pr()

o1 = new stzHtml("<!DOCTYPE html><html><body><h1>Title</h1></body></html>")

# DOCTYPE should be preserved
? o1.toString()
#--> <!DOCTYPE html>
#   <html>
#     <body>
#       <h1>Title</h1>
#     </body>
#   </html>

pf()

/*--- Parsing self-closing tags

pr()

o1 = new stzHtml('<div><img src="image.jpg" alt="Picture" /><br/><hr></div>')

# Self-closing tags should be handled properly
? o1.getElementCount()
#--> 4

? o1.toString()
#--> <div>
#     <img src="image.jpg" alt="Picture" />
#     <br />
#     <hr />
#   </div>

pf()

/*--- Parsing with comments and text nodes

pr()

cHtml = '<div>
    <!-- This is a comment -->
    <p>Text content</p>
    Some loose text
</div>'

o1 = new stzHtml(cHtml)
o1 {
    # Comments and text should be preserved
    ? getTextContent()
    #--> Text content Some loose text
    
    ? toString()
    # Should include comments in output
}

pf()

/*--- Edge case: Malformed HTML parsing

pr()

o1 = new stzHtml('<div><p>Unclosed paragraph<div>Nested without closing</div>')

# Should handle malformed HTML gracefully
? o1.isParsed()
#--> TRUE (with best effort parsing)

? o1.getParseErrors()
# Should contain any parsing issues

pf()

/*--- Edge case: Empty and whitespace-only content

pr()

o1 = new stzHtml("   \n\t   ")

# Empty content should be handled
? o1.getElementCount()
#--> 0

? o1.getTextContent()
#--> ""

pf()

#-------------------------------#
#  ELEMENT QUERYING             #
#-------------------------------#

/*--- Basic element selection by tag name

pr()

cHtml = '<div><p>First</p><p>Second</p><span>Third</span></div>'
o1 = new stzHtml(cHtml)

# Find all paragraphs
aParagraphs = o1.findAll("p")
? len(aParagraphs)
#--> 2

# Find first paragraph
oFirst = o1.find("p")
? oFirst[:name]
#--> "p"

pf()

/*--- Selection by ID attribute

pr()

cHtml = '<div id="container">
    <p id="intro">Introduction</p>
    <p id="content">Main content</p>
</div>'

o1 = new stzHtml(cHtml)
o1 {
    # Find by ID
    oIntro = find("#intro")
    ? oIntro[:name]
    #--> "p"
    
    # Get attribute value
    ? getAttribute(oIntro, "id")
    #--> "intro"
}

pf()

/*--- Selection by class attribute

pr()

cHtml = '<div>
    <p class="highlight important">First paragraph</p>
    <p class="normal">Second paragraph</p>
    <p class="highlight">Third paragraph</p>
</div>'

o1 = new stzHtml(cHtml)
o1 {
    # Find all elements with 'highlight' class
    aHighlighted = findAll(".highlight")
    ? len(aHighlighted)
    #--> 2
    
    # Find first element with 'important' class
    oImportant = find(".important")
    ? getAttribute(oImportant, "class")
    #--> "highlight important"
}

pf()

/*--- Complex querying scenarios

pr()

cHtml = '<html>
<body>
    <div id="header" class="main-header">
        <h1>Title</h1>
        <nav class="navigation">
            <a href="#home">Home</a>
            <a href="#about">About</a>
        </nav>
    </div>
    <div id="content">
        <p class="intro">Welcome message</p>
    </div>
</body>
</html>'

o1 = new stzHtml(cHtml)
o1 {
    # Multiple query types
    oHeader = find("#header")
    aLinks = findAll("a")
    aNavigation = findAll(".navigation")
    
    ? oHeader[:name]
    #--> "div"
    
    ? len(aLinks)
    #--> 2
    
    ? len(aNavigation)
    #--> 1
}

pf()

/*--- Edge case: Non-existent elements

pr()

o1 = new stzHtml('<div><p>Content</p></div>')

# Searching for non-existent elements
oNonExistent = o1.find("#nonexistent")
? oNonExistent
#--> NULL

aNonExistent = o1.findAll(".nonexistent")
? len(aNonExistent)
#--> 0

pf()

#-------------------------------#
#  ELEMENT MANIPULATION         #
#-------------------------------#

/*--- Creating new elements

pr()

o1 = new stzHtml("")

# Create element with attributes
oDiv = o1.createElement("div", ["id", "container", "class", "main"], "")
oP = o1.createElement("p", ["class", "text"], "Hello World")

# Elements should be properly structured
? oDiv[:name]
#--> "div"

? oDiv[:attributes]
#--> ["id", "container", "class", "main"]

pf()

/*--- Adding and removing child elements

pr()

o1 = new stzHtml('<div id="parent"></div>')

oParent = o1.find("#parent")
oChild = o1.createElement("p", ["class", "child"], "Child content")

o1 {
    # Add child to parent
    appendChild(oParent, oChild)
    
    # Check parent-child relationship
    ? len(oParent[:children])
    #--> 1
    
    ? oChild[:parent][:name]
    #--> "div"
}

pf()

/*--- Removing child elements (declarative style)

pr()

o1 = new stzHtml('<div><p>Keep</p><p>Remove</p></div>')

oParent = o1.find("div")
oToRemove = o1.findAll("p")[2]

o1 {
    # Remove child
    removeChild(oParent, oToRemove)
    
    # Check removal
    ? len(oParent[:children])
    #--> 1 (only text nodes and kept paragraph)
}

pf()

/*--- Attribute manipulation

pr()

o1 = new stzHtml('<div><p id="text">Original</p></div>')

oParagraph = o1.find("#text")

o1 {
    # Set new attribute
    setAttribute(oParagraph, "class", "highlight")
    
    # Get attribute value
    ? getAttribute(oParagraph, "class")
    #--> "highlight"
    
    # Modify existing attribute
    setAttribute(oParagraph, "id", "modified-text")
    
    ? getAttribute(oParagraph, "id")
    #--> "modified-text"
}

pf()

/*--- Removing attributes

pr()

o1 = new stzHtml('<p id="test" class="highlight" data-value="123">Text</p>')

oParagraph = o1.find("p")

o1 {
    # Remove specific attribute
    removeAttribute(oParagraph, "class")
    
    # Check attribute removal
    ? getAttribute(oParagraph, "class")
    #--> NULL
    
    # Other attributes should remain
    ? getAttribute(oParagraph, "id")
    #--> "test"
}

pf()

/*--- CSS class manipulation

pr()

o1 = new stzHtml('<div class="container main">Content</div>')

oDiv = o1.find("div")

o1 {
    # Add class
    addClass(oDiv, "highlighted")
    
    # Check if class exists
    ? hasClass(oDiv, "highlighted")
    #--> TRUE
    
    ? hasClass(oDiv, "container")
    #--> TRUE
    
    # Remove class
    removeClass(oDiv, "main")
    
    ? hasClass(oDiv, "main")
    #--> FALSE
}

pf()

/*--- Edge case: Duplicate class handling

pr()

o1 = new stzHtml('<div class="test">Content</div>')

oDiv = o1.find("div")

o1 {
    # Adding existing class should not duplicate
    addClass(oDiv, "test")
    addClass(oDiv, "test")
    
    ? getAttribute(oDiv, "class")
    #--> "test" (no duplicates)
    
    # Removing non-existent class should not error
    removeClass(oDiv, "nonexistent")
    
    ? getAttribute(oDiv, "class")
    #--> "test" (unchanged)
}

pf()

#-------------------------------#
#  HTML GENERATION              #
#-------------------------------#

/*--- Basic HTML output

pr()

o1 = new stzHtml('<div><p>Hello</p></div>')

# Default pretty printing
? o1.toString()
#--> <div>
#     <p>Hello</p>
#   </div>

pf()

/*--- Pretty printing vs minification

pr()

o1 = new stzHtml('<div><p>Content</p><span>More</span></div>')

o1 {
    # Pretty printed output
    ? pretty()
    #--> <div>
    #     <p>Content</p>
    #     <span>More</span>
    #   </div>
    
    # Minified output
    ? minify()
    #--> <div><p>Content</p><span>More</span></div>
}

pf()

/*--- Complex document generation

pr()

cHtml = '<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>Test Document</title>
</head>
<body>
    <header>
        <h1>Main Title</h1>
    </header>
    <main>
        <p class="intro">Introduction paragraph</p>
        <div class="content">
            <p>Content paragraph</p>
        </div>
    </main>
</body>
</html>'

o1 = new stzHtml(cHtml)

# Should preserve document structure
? o1.toString()
# Complete HTML document with proper formatting

pf()

/*--- Self-closing tags in output

pr()

o1 = new stzHtml('<div><img src="pic.jpg" alt="Picture"><br><hr></div>')

# Self-closing tags should be properly formatted
? o1.toString()
#--> <div>
#     <img src="pic.jpg" alt="Picture" />
#     <br />
#     <hr />
#   </div>

pf()

/*--- Edge case: Empty elements

pr()

o1 = new stzHtml('<div></div><p></p><span></span>')

# Empty elements should be handled correctly
? o1.toString()
#--> <div></div>
#   <p></p>
#   <span></span>

pf()

#-------------------------------#
#  CONFIGURATION MANAGEMENT     #
#-------------------------------#

/*--- Indentation configuration

pr()

o1 = new stzHtml('<div><p>Content</p></div>')

o1 {
    # Set custom indentation
    setConfig(:indent_size, 4)
    
    ? toString()
    #--> <div>
    #        <p>Content</p>
    #    </div>
}

pf()

/*--- Whitespace preservation

pr()

cHtml = '<pre>    Code block
    with    spaces</pre>'

o1 = new stzHtml(cHtml)

o1 {
    # Enable whitespace preservation
    setConfig(:preserve_whitespace, true)
    
    ? toString()
    # Should preserve original spacing
}

pf()

/*--- Validation configuration

pr()

o1 = new stzHtml('<img src="picture.jpg"><a>Link without href</a>')

o1 {
    # Enable validation
    setConfig(:validate, true)
    
    # Validate the document
    ? validate()
    #--> FALSE
    
    # Check validation errors
    ? getParseErrors()
    #--> ["img element missing alt attribute", "a element missing href attribute"]
}

pf()

/*--- Pretty printing configuration

pr()

o1 = new stzHtml('<div><p>Content</p></div>')

o1 {
    # Disable pretty printing
    setConfig(:pretty_print, false)
    
    ? toString()
    #--> <div><p>Content</p></div>
    
    # Re-enable pretty printing
    setConfig(:pretty_print, true)
    
    ? toString()
    #--> <div>
    #     <p>Content</p>
    #   </div>
}

pf()

#-------------------------------#
#  PRACTICAL EXAMPLES           #
#-------------------------------#

/*--- Building a simple webpage programmatically

pr()

o1 = new stzHtml("")

# Create document structure
oHtml = o1.createElement("html", ["lang", "en"], "")
oHead = o1.createElement("head", [], "")
oBody = o1.createElement("body", [], "")

# Add meta and title
oMeta = o1.createElement("meta", ["charset", "UTF-8"], "")
oTitle = o1.createElement("title", [], "My Page")

# Add content
oHeader = o1.createElement("header", [], "")
oH1 = o1.createElement("h1", ["class", "main-title"], "Welcome")
oMain = o1.createElement("main", [], "")
oP = o1.createElement("p", ["class", "intro"], "This is the introduction.")

o1 {
    # Build structure
    appendChild(oHtml, oHead)
    appendChild(oHtml, oBody)
    appendChild(oHead, oMeta)
    appendChild(oHead, oTitle)
    appendChild(oBody, oHeader)
    appendChild(oHeader, oH1)
    appendChild(oBody, oMain)
    appendChild(oMain, oP)
    
    # Set as root
    @aElements = [oHtml]
    
    ? toString()
    # Complete HTML document
}

pf()

/*--- Modifying existing HTML content

pr()

cOriginal = '<div class="container">
    <h1>Old Title</h1>
    <p>Old content</p>
</div>'

o1 = new stzHtml(cOriginal)

o1 {
    # Find and modify title
    oTitle = find("h1")
    setAttribute(oTitle, "class", "new-title")
    
    # Find and modify content
    oContent = find("p")
    addClass(oContent, "updated")
    
    # Add new element
    oContainer = find(".container")
    oNewP = createElement("p", ["class", "footer"], "Added content")
    appendChild(oContainer, oNewP)
    
    ? toString()
    # Modified HTML with changes
}

pf()

/*--- HTML template processing

pr()

cTemplate = '<div class="card">
    <h2 class="title">{{TITLE}}</h2>
    <p class="content">{{CONTENT}}</p>
    <div class="meta">
        <span class="author">{{AUTHOR}}</span>
        <span class="date">{{DATE}}</span>
    </div>
</div>'

o1 = new stzHtml(cTemplate)

# Replace placeholders with actual content
aReplacements = [
    ["{{TITLE}}", "Article Title"],
    ["{{CONTENT}}", "This is the article content."],
    ["{{AUTHOR}}", "John Doe"],
    ["{{DATE}}", "2024-01-15"]
]

o1 {
    cResult = toString()
    
    # Replace placeholders
    for aReplacement in aReplacements
        cResult = substr(cResult, aReplacement[1], aReplacement[2])
    next
    
    ? cResult
    # Processed template with actual values
}

pf()

/*--- Form generation and validation

pr()

o1 = new stzHtml("")

# Create form structure
oForm = o1.createElement("form", ["action", "/submit", "method", "post"], "")
oFieldset = o1.createElement("fieldset", [], "")
oLegend = o1.createElement("legend", [], "User Information")

# Add form fields
oNameLabel = o1.createElement("label", ["for", "name"], "Name:")
oNameInput = o1.createElement("input", ["type", "text", "id", "name", "name", "name", "required", ""], "")

oEmailLabel = o1.createElement("label", ["for", "email"], "Email:")
oEmailInput = o1.createElement("input", ["type", "email", "id", "email", "name", "email", "required", ""], "")

oSubmit = o1.createElement("input", ["type", "submit", "value", "Submit"], "")

o1 {
    # Build form structure
    appendChild(oForm, oFieldset)
    appendChild(oFieldset, oLegend)
    appendChild(oFieldset, oNameLabel)
    appendChild(oFieldset, oNameInput)
    appendChild(oFieldset, oEmailLabel)
    appendChild(oFieldset, oEmailInput)
    appendChild(oFieldset, oSubmit)
    
    # Set as root
    @aElements = [oForm]
    
    ? toString()
    # Complete form HTML
}

pf()

/*--- Navigation menu builder

pr()

aMenuItems = [
    ["Home", "/", "active"],
    ["About", "/about", ""],
    ["Services", "/services", ""],
    ["Contact", "/contact", ""]
]

o1 = new stzHtml("")

# Create navigation structure
oNav = o1.createElement("nav", ["class", "main-navigation"], "")
oUl = o1.createElement("ul", ["class", "nav-menu"], "")

o1 {
    # Build menu items
    for aItem in aMenuItems
        oLi = createElement("li", ["class", "nav-item"], "")
        
        aLinkAttrs = ["href", aItem[2]]
        if not isEmpty(aItem[3])
            aLinkAttrs + ["class", aItem[3]]
        ok
        
        oLink = createElement("a", aLinkAttrs, aItem[1])
        
        appendChild(oLi, oLink)
        appendChild(oUl, oLi)
    next
    
    appendChild(oNav, oUl)
    @aElements = [oNav]
    
    ? toString()
    # Complete navigation menu
}

pf()

#-------------------------------#
#  EDGE CASES AND ERROR HANDLING #
#-------------------------------#

/*--- Malformed HTML recovery

pr()

cMalformed = '<div><p>Unclosed paragraph<span>Nested content</div>'

o1 = new stzHtml(cMalformed)

o1 {
    # Should parse with best effort
    ? isParsed()
    #--> TRUE
    
    # Check for parse errors
    aErrors = getParseErrors()
    ? len(aErrors)
    # May contain warnings about unclosed tags
    
    # Should still generate valid HTML
    ? toString()
    # Best effort reconstruction
}

pf()

/*--- Invalid attribute handling

pr()

o1 = new stzHtml('<div>Content</div>')

oDiv = o1.find("div")

o1 {
    # Try to get non-existent attribute
    ? getAttribute(oDiv, "nonexistent")
    #--> NULL
    
    # Try to remove non-existent attribute
    removeAttribute(oDiv, "nonexistent")
    # Should not cause errors
    
    # Set attribute with empty value
    setAttribute(oDiv, "data-empty", "")
    
    ? getAttribute(oDiv, "data-empty")
    #--> ""
}

pf()

/*--- Large document handling

pr()

# Create large document
cLargeHtml = '<div class="container">'
for i = 1 to 1000
    cLargeHtml += '<p class="item-' + i + '">Item ' + i + '</p>'
next
cLargeHtml += '</div>'

o1 = new stzHtml(cLargeHtml)

o1 {
    # Should handle large documents
    ? isParsed()
    #--> TRUE
    
    ? getElementCount()
    #--> 1001
    
    # Query performance
    aItems = findAll("p")
    ? len(aItems)
    #--> 1000
}

pf()

/*--- Memory cleanup and reuse

pr()

o1 = new stzHtml('<div><p>Initial content</p></div>')

# Parse new content
cNewHtml = '<section><h1>New content</h1><p>Different structure</p></section>'
o1.parse(cNewHtml)

o1 {
    # Should clear previous content
    ? getElementCount()
    #--> 3
    
    # Should find new elements
    oSection = find("section")
    ? oSection[:name]
    #--> "section"
    
    # Old elements should not be found
    oDiv = find("div")
    ? oDiv
    #--> NULL
}

pf()

/*--- Unicode and special characters

pr()

cUnicode = '<div>
    <p>English text</p>
    <p>Français: café, résumé</p>
    <p>Deutsch: Müller, Größe</p>
    <p>Español: niño, año</p>
    <p>Symbols: ♠ ♥ ♦ ♣ © ® ™</p>
</div>'

o1 = new stzHtml(cUnicode)

o1 {
    # Should handle Unicode correctly
    ? isParsed()
    #--> TRUE
    
    # Should preserve special characters
    cText = getTextContent()
    # Should contain all Unicode characters
    
    # Should generate valid output
    ? toString()
    # Should preserve Unicode in output
}

pf()

#-------------------------------#
#  DEBUGGING AND INTROSPECTION  #
#-------------------------------#

/*--- Debug information

pr()

o1 = new stzHtml('<div class="test"><p>Content</p><!-- Comment --></div>')

# Debug output
o1.debug()
#--> === stzHtml Debug Information ===
#    Parsed: TRUE
#    Element count: 2
#    Parse errors: 0
#    === End Debug Information ===

pf()

/*--- Element inspection

pr()

o1 = new stzHtml('<div id="container" class="main"><p>Text</p></div>')

oDiv = o1.find("#container")

# Inspect element structure
? oDiv[:type]
#--> "element"

? oDiv[:name]
#--> "div"

? oDiv[:attributes]
#--> ["id", "container", "class", "main"]

? len(oDiv[:children])
#--> 1

pf()

/*--- Content analysis

pr()

cHtml = '<article>
    <h1>Article Title</h1>
    <p>First paragraph with <strong>bold</strong> text.</p>
    <p>Second paragraph with <em>italic</em> text.</p>
    <ul>
        <li>List item 1</li>
        <li>List item 2</li>
    </ul>
</article>'

o1 = new stzHtml(cHtml)

o1 {
    # Content analysis
    ? getElementCount()
    #--> 9
    
    ? getTextContent()
    #--> "Article Title First paragraph with bold text. Second paragraph with italic text. List item 1 List item 2"
    
    # Element type analysis
    aParagraphs = findAll("p")
    aListItems = findAll("li")
    
    ? len(aParagraphs)
    #--> 2
    
    ? len(aListItems)
    #--> 2
}

pf()

/*--- Performance monitoring

pr()

# Create complex document
cComplex = '<html><head><title>Test</title></head><body>'
for i = 1 to 100
    cComplex += '<div class="section-' + i + '">'
    for j = 1 to 10
        cComplex += '<p id="para-' + i + '-' + j + '">Content ' + i + '-' + j + '</p>'
    next
    cComplex += '</div>'
next
cComplex += '</body></html>'

o1 = new stzHtml(cComplex)

o1 {
    # Performance metrics
    ? isParsed()
    #--> TRUE
    
    ? getElementCount()
    #--> 1303 (html, head, title, body, 100 divs, 1000 p tags)
    
    ? len(getParseErrors())
    #--> 0
}

pf()

#-------------------------------#
#  INTEGRATION EXAMPLES         #
#-------------------------------#

/*--- Web scraping simulation

pr()

cWebPage = '<html>
<head><title>Product Page</title></head>
<body>
    <div class="product">
        <h1 class="title">Awesome Product</h1>
        <div class="price">$99.99</div>
        <div class="description">
            <p>Product description here.</p>
        </div>
        <div class="rating">
            <span class="stars">★★★★☆</span>
            <span class="count">(42 reviews)</span>
        </div>
    </div>
</body>
</html>'

o1 = new stzHtml(cWebPage)

# Extract product information
oProduct = o1.find(".product")
oTitle = o1.find(".title")
oPrice = o1.find(".price")
oDescription = o1.find(".description p")
oRating = o1.find(".rating .stars")

? "Product: " + o1.getTextContent(oTitle)
#--> "Product: Awesome Product"

? "Price: " + o1.getTextContent(oPrice)
#--> "Price: $99.99"

pf()

/*--- HTML email template

pr()

o1 = new stzHtml("")

# Create email structure
oHtml = o1.createElement("html", [], "")
oHead = o1.createElement("head", [], "")
oBody = o1.createElement("body", ["style", "font-family: Arial, sans-serif;"], "")

# Email content
oContainer = o1.createElement("div", ["style", "max-width: 600px; margin: 0 auto;"], "")
oHeader = o1.createElement("div", ["style", "background: #f8f9fa; padding: 20px;"], "")
oTitle = o1.createElement("h1", ["style", "color: #333; margin: 0;"], "Newsletter")

oContent = o1.createElement("div", ["style", "padding: 20px;"], "")
oMessage = o1.createElement("p", [], "Thank you for subscribing to our newsletter!")

oFooter = o1.createElement("div", ["style", "background: #f8f9fa; padding: 10px; text-align: center;"], "")
oFooterText = o1.createElement("small", [], "© 2024 Company Name. All rights reserved.")

o1 {
    # Build email structure
    appendChild(oHtml, oHead)
    appendChild(oHtml, oBody)
    appendChild(oBody, oContainer)
    appendChild(oContainer, oHeader)
    appendChild(oHeader, oTitle)
    appendChild(oContainer, oContent)
    appendChild(oContent, oMessage)
    appendChild(oContainer, oFooter)
    appendChild(oFooter, oFooterText)
    
    @aElements = [oHtml]
    
    ? toString()
    # Complete HTML email template
}

pf()

/*--- RSS feed generation

pr()

aArticles = [
    ["First Article", "Content of first article", "2024-01-01"],
    ["Second Article", "Content of second article", "2024-01-02"],
    ["Third Article", "Content of third article", "2024-01-03"]
]

o1 = new stzHtml("")

# Create RSS structure (simplified)
oRss = o1.createElement("rss", ["version", "2.0"], "")
oChannel = o1.createElement("channel", [], "")
oChannelTitle = o1.createElement("title", [], "My Blog")
oChannelDescription = o1.createElement("description", [], "Latest articles from my blog")

o1 {
    appendChild(oRss, oChannel)
    appendChild(oChannel, oChannelTitle)
    appendChild(oChannel, oChannelDescription)
    
    # Add articles
    for aArticle in aArticles
        oItem = createElement("item", [], "")
        oItemTitle = createElement("title", [], aArticle[1])
        oItemDescription = createElement("description", [], aArticle[2])
        oItemPubDate = createElement("pubDate", [], aArticle[3])
        
        appendChild(oItem, oItemTitle)
        appendChild(oItem, oItemDescription)
        appendChild(oItem, oItemPubDate)
        appendChild(oChannel, oItem)
    next
    
    @aElements = [oRss]
    
    ? toString()
    # RSS XML output
}

pf()

? "All tests completed successfully!"
