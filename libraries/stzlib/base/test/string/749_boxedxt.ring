load "../../stzBase.ring"
load "../_narrated.ring"

# BoxedXT with mixed corners -- the :Corners list reads CLOCKWISE:
# [TopLeft, TopRight, BottomRight, BottomLeft]. Archive block #749.

Scenario("A box with alternating corners")
	cExp = "╭─────────────────────┐" + NL +
	       "│ SOFTANZA IS AWSOME! │" + NL +
	       "└─────────────────────╯"
	Then("round-rect-round-rect, clockwise",
		StzStringQ("SOFTANZA IS AWSOME!").BoxedXT([
			:Line = :Solid,
			:AllCorners = :Round,
			:Corners = [ :Round, :Rectangular, :Round, :Rectangular ],
			:TextAdjustedTo = :Center
		]), cExp)
EndScenario()

Summary()
