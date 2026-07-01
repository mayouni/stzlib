load "../../stzBase.ring"
load "../_narrated.ring"

# ShortenedUsing(ellipsis) shortens with the default 3-per-side using a custom
# ellipsis; ShortenedNUsing(n, ellipsis) sets both. Archive block #119.

Scenario("Shortening with a custom ellipsis")
	Then("ShortenedUsing(' {...} ') keeps 3 each side",
		Q("1234567890987654321").ShortenedUsing(" {...} "), "123 {...} 321")
	Then("ShortenedNUsing(5, ' {...} ') keeps 5 each side",
		Q("1234567890987654321").ShortenedNUsing(5, " {...} "), "12345 {...} 54321")
EndScenario()

Summary()
