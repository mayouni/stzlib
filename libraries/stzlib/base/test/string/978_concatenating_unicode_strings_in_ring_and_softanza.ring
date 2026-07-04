load "../../stzBase.ring"
load "../_narrated.ring"

# Ring's += is fine on latin (seconds) but degrades badly on
# multibyte content -- the archive clocks the arabic loop at ~45s,
# which is why it stays commented and Concatenate() exists.
# Asserted functionally on the latin half. Archive block #978.

Scenario("A million latin concatenations")
	cStr = ""
	for i = 1 to 1000000
		cStr += "any text"
	next
	Then("eight million chars", StzLen(cStr), 8000000)
EndScenario()

Summary()
