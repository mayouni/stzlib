load "../../stzBase.ring"
load "../_narrated.ring"

# DistanceTo with direction: :Next / :NextNth = [n, char] search forward,
# :Previous / :PreviousNth search backward from :StartingAt. The plain form
# is the exclusive gap; the STXT form counts the two bounding positions
# (inclusive). Positions are codepoint-based (the bullets are multibyte).
# Extracted from stzlisttest.ring, block #309.

Scenario("Directional distances in a bracketed bullet string")
	Given('"[••[•[••]•[•]]••[••]]"')
	o1 = new stzString("[••[•[••]•[•]]••[••]]")
	Then("plain forward distance", o1.DistanceTo("[", :StartingAt = 1), 2)
	Then(":Next spelling", o1.DistanceTo( :Next = "[", :StartingAt = 1 ), 2)
	Then(":NextNth = [2, char]", o1.DistanceTo( :NextNth = [ 2, "[" ], :StartingAt = 1 ), 4)
	Then("STXT counts the bounds", o1.DistanceToSTXT("[", :StartingAt = 1), 4)
	Then("STXT :Next", o1.DistanceToSTXT( :Next = "[", :StartingAt = 1 ), 4)
	Then("STXT :NextNth", o1.DistanceToSTXT( :NextNth = [2, "["], :StartingAt = 1 ), 6)
	Then("STXT :Previous", o1.DistanceToSTXT( :Previous = "[", :StartingAt = 9 ), 4)
	Then("STXT :PreviousNth", o1.DistanceToSTXT( :PreviousNth = [2, "["], :StartingAt = 9 ), 6)
	Then("plain :Previous", o1.DistanceTo( :Previous = "[", :StartingAt = 9 ), 2)
	Then("plain :PreviousNth", o1.DistanceTo( :PreviousNth = [2, "["], :StartingAt = 9 ), 4)
EndScenario()

Summary()
