load "../../stzBase.ring"
load "../_narrated.ring"

# Integration test for the engine-rewired stzHtml (M-DEP2 slice 2).
# stzHtml.ring now talks to libraries/stzlib/engine/src/html_dom.zig
# instead of the external html.ring extension.

Scenario("HtmlQ constructs an engine-backed document")
    Given("a small HTML string")
    o = HtmlQ("<html><body><p>hello</p></body></html>")
    Then("Content() round-trips the source",
        o.Content(), "<html><body><p>hello</p></body></html>")
    Then("NumberOfElements counts html + body + p",
        o.NumberOfElements(), 3)
    Then("CountByTag finds the p",
        o.CountByTag("p"), 1)
EndScenario()

Scenario("Text() extracts document text")
    Given("a document with multiple visible text fragments")
    o = HtmlQ("<p>hello</p><p>world</p>")
    Then("Text returns the concatenated visible content",
        o.Text(), "helloworld")
EndScenario()

Scenario("Text() suppresses scripts and styles")
    Given("a document with inline script and style")
    o = HtmlQ("<style>p { color: red; }</style><p>visible</p><script>x=1</script>")
    Then("Text drops both blocks",
        o.Text(), "visible")
EndScenario()

Scenario("Find by tag returns wrapper nodes")
    Given("two paragraphs")
    o = HtmlQ("<p>one</p><p>two</p>")
    aN = o.Find("p")
    Then("two nodes returned", len(aN), 2)
    Then("first node text",  aN[1].Text(), "one")
    Then("second node text", aN[2].Text(), "two")
EndScenario()

Scenario("Find by #id selector hits a single element")
    Given("two divs with distinct ids")
    o = HtmlQ('<div id="a">A</div><div id="b">B</div>')
    aN = o.Find("#b")
    Then("one match",     len(aN), 1)
    Then("right text",    aN[1].Text(), "B")
EndScenario()

Scenario("Find by .class selector returns all matches")
    Given("paragraphs with shared and unique classes")
    o = HtmlQ('<p class="foo">one</p><p class="foo bar">two</p><p>three</p>')
    aFoo = o.Find(".foo")
    Then("two .foo matches",   len(aFoo), 2)
    aBar = o.Find(".bar")
    Then("one .bar match",     len(aBar), 1)
    Then(".bar matches second p", aBar[1].Text(), "two")
EndScenario()

Scenario("Node carries id, class, attribute accessors")
    Given("a single anchor with id, class, and href")
    o = HtmlQ('<a id="link1" class="primary external" href="/about">about</a>')
    n = o.FindFirst("a")
    Then("Tag() lowercases the name",  n.Tag(),   "a")
    Then("Id() returns the id",        n.Id(),    "link1")
    Then("Attr(href)",                 n.Attr("href"), "/about")
    Then("HasAttr is TRUE for href",   n.HasAttr("href"), TRUE)
    Then("HasAttr is FALSE for title", n.HasAttr("title"), FALSE)
    Then("HasKlass primary",           n.HasKlass("primary"),  TRUE)
    Then("HasKlass external",          n.HasKlass("external"), TRUE)
    Then("HasKlass missing",           n.HasKlass("missing"),  FALSE)
EndScenario()

Summary()
