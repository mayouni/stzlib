load "../../stzBase.ring"
load "../_narrated.ring"

# M-S2 narrated regression suite for stzHtml -- parse HTML and query it by
# CSS-ish tag/class selectors. Deterministic. (The classic IsValid/HasBody/
# TagsUsed methods are gone; the live surface is CountByTag/Find/FindFirst
# + element Text/Klass/HasClass.)

Scenario("Count elements by tag")
    Given("a small document with one h1 and one p")
    h = Html(`<html><head><title>Test</title></head><body><h1>Hi</h1><p class="intro">para</p></body></html>`)
    Then("CountByTag('h1') is 1", h.CountByTag("h1"), 1)
    Then("CountByTag('p') is 1", h.CountByTag("p"), 1)
    Then("CountByTag('div') is 0", h.CountByTag("div"), 0)
EndScenario()

Scenario("Find elements and read their text")
    Given("the same document")
    h = Html(`<html><head><title>Test</title></head><body><h1>Hello World</h1><p class="intro">para text</p></body></html>`)
    aH = h.Find("h1")
    Then("Find('h1') returns 1 element", len(aH), 1)
    Then("the h1 text is 'Hello World'", aH[1].Text(), "Hello World")
    Then("FindFirst('title') text is 'Test'", h.FindFirst("title").Text(), "Test")
    Then("FindFirst('p') text is 'para text'", h.FindFirst("p").Text(), "para text")
EndScenario()

Scenario("Element class queries")
    Given("a paragraph with class 'intro'")
    h = Html(`<html><body><p class="intro">x</p></body></html>`)
    p = h.FindFirst("p")
    Then("Klass() is 'intro'", p.Klass(), "intro")
    Then("HasClass('intro') is TRUE", p.HasClass("intro"), TRUE)
    Then("HasClass('outro') is FALSE", p.HasClass("outro"), FALSE)
EndScenario()

Summary()

func Html cStr
    return new stzHtml(cStr)
