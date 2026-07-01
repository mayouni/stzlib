load "../../stzBase.ring"
load "../_narrated.ring"

# Shortened() defaults to 3 chars per side around "..."; ShortenedN(n) sets the
# count; ShortenedXT(left, right, ellipsis) is the full form. Archive block #117.

Scenario("Shortening a long string")
	Then("Shortened() keeps 3 each side", Q("1234567890987654321").Shortened(), "123...321")
	Then("ShortenedN(5) keeps 5 each side", Q("1234567890987654321").ShortenedN(5), "12345...54321")
	Then("ShortenedXT(0,3,' ... ') mirrors with a custom ellipsis",
		Q("1234567890987654321").ShortenedXT(0, 3, " ... "), "123 ... 321")
EndScenario()

Summary()
