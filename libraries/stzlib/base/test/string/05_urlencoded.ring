load "../../stzBase.ring"
load "../_narrated.ring"

# UrlEncoded / UrlDecoded / HtmlEscaped. Verified against archive block #5.

Scenario("URL and HTML encoding")
	Given("a phrase, an encoded phrase, and an HTML snippet")
	Then("UrlEncoded", Q("ring programming languge").UrlEncoded(), "ring%20programming%20languge")
	Then("UrlDecoded", Q("ring%20programming%20language").UrlDecoded(), "ring programming language")
	Then("HtmlEscaped",
		Q('<div class = "article">This is an article</div>').HtmlEscaped(),
		'&lt;div class = &quot;article&quot;&gt;This is an article&lt;/div&gt;')
EndScenario()

Summary()
