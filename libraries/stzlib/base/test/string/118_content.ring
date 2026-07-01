load "../../stzBase.ring"
load "../_narrated.ring"

# Shorten() / ShortenN(n) are the mutating (active) forms of Shortened/ShortenedN.
# Archive block #118.

Scenario("Shortening in place")
	Given('"1234567890987654321"')
	o1 = new stzString("1234567890987654321")
	o1.Shorten()
	Then("Shorten() mutates to 3-per-side", o1.Content(), "123...321")

	o2 = new stzString("1234567890987654321")
	o2.ShortenN(5)
	Then("ShortenN(5) mutates to 5-per-side", o2.Content(), "12345...54321")
EndScenario()

Summary()
