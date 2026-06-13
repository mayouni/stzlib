load "../../stzBase.ring"
load "../_narrated.ring"

# Engine-backed HTML DOM smoke test (M-DEP2 slice 1).
# The Zig parser at libraries/stzlib/engine/src/html_dom.zig produces
# a flat element index suitable for stzHtml's find-by-tag / text /
# attribute use cases. CSS selectors and DOM mutation are NOT
# implemented yet; those come in later slices.

Scenario("Engine parser counts paragraphs in well-formed HTML")
    Given("a small document with two p elements")
    cHtml = "<html><body><p>alpha</p><p>beta</p></body></html>"
    pDoc = StzEngineHtmlParse(cHtml)
    Then("the parse handle is non-zero", isPointer(pDoc), TRUE)
    Then("element count is 4 (html + body + 2 p)",
        StzEngineHtmlCount(pDoc), 4)
    Then("two p elements found", StzEngineHtmlCountByTag(pDoc, "p"), 2)
    Then("one body found",       StzEngineHtmlCountByTag(pDoc, "body"), 1)
    Then("case-insensitive lookup",
        StzEngineHtmlCountByTag(pDoc, "BODY"), 1)
    Then("unknown tag returns 0",
        StzEngineHtmlCountByTag(pDoc, "span"), 0)
    StzEngineHtmlFree(pDoc)
EndScenario()

Scenario("Engine parser extracts inner text per occurrence")
    Given("two p elements with distinct text")
    cHtml = "<p>alpha</p><p>beta</p>"
    pDoc = StzEngineHtmlParse(cHtml)
    Then("first p text", StzEngineHtmlTextOfTag(pDoc, "p", 1), "alpha")
    Then("second p text", StzEngineHtmlTextOfTag(pDoc, "p", 2), "beta")
    StzEngineHtmlFree(pDoc)
EndScenario()

Scenario("Engine parser reads attributes per occurrence")
    Given("two anchors with different href")
    cHtml = '<a href="x">one</a><a href="y">two</a>'
    pDoc = StzEngineHtmlParse(cHtml)
    Then("first href",  StzEngineHtmlAttrOfTag(pDoc, "a", 1, "href"), "x")
    Then("second href", StzEngineHtmlAttrOfTag(pDoc, "a", 2, "href"), "y")
    StzEngineHtmlFree(pDoc)
EndScenario()

Scenario("Engine all-text strips tags + skips script bodies")
    Given("a document containing visible text and a script")
    cHtml = "<p>top</p><script>var x = 1;</script><p>bottom</p>"
    pDoc = StzEngineHtmlParse(cHtml)
    Then("only visible text remains",
        StzEngineHtmlAllText(pDoc), "topbottom")
    StzEngineHtmlFree(pDoc)
EndScenario()

Scenario("Self-closing and void tags do not break the index")
    Given("a document with a self-closing br and a void img")
    cHtml = "<p>x</p><br/><img src='a.png'><p>y</p>"
    pDoc = StzEngineHtmlParse(cHtml)
    Then("two p elements still counted",
        StzEngineHtmlCountByTag(pDoc, "p"), 2)
    Then("br counted",  StzEngineHtmlCountByTag(pDoc, "br"),  1)
    Then("img counted", StzEngineHtmlCountByTag(pDoc, "img"), 1)
    Then("img src attribute",
        StzEngineHtmlAttrOfTag(pDoc, "img", 1, "src"), "a.png")
    StzEngineHtmlFree(pDoc)
EndScenario()

Summary()
