load "../../stzBase.ring"
load "../_narrated.ring"

# ShortenedN(n) keeps n chars each side around "..."; ShortenedXT(left, right, ell)
# controls each side and the ellipsis (0 left mirrors the right count). Archive #116.

Scenario("Shortening with N chars per side")
	Then("ShortenedN(2) keeps 2 each side", Q("1234567890987654321").ShortenedN(2), "12...21")
	Then("ShortenedXT(0,2,' {...} ') mirrors and uses the ellipsis",
		Q("1234567890987654321").ShortenedXT(0, 2, " {...} "), "12 {...} 21")
EndScenario()

Summary()
