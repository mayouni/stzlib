# Narrative
# --------
# ExtendXT is the eXtended (XT) variant of Extend: the first argument
# selects the extension mode (:List here, meaning "append the items of
# the given list one by one"), and :With supplies the source list. So
# [ "A", "B", "C" ] extended with [ "D", "E" ] grows in place to the flat
# five-item list [ "A", "B", "C", "D", "E" ] rather than nesting the second
# list as a single element. The named arguments make the intent
# self-documenting at the call site.
#
# Extracted from stzlisttest.ring, block #157 (Scenario form).

load "../../stzBase.ring"
load "../_narrated.ring"

Scenario("ExtendXT( :List, :With = ... ) appends the items of another list flatly")
	o1 = new stzList([ "A", "B", "C" ])
	o1.ExtendXT( :List, :With = ["D", "E"])
	Then("the two items are appended one by one, not nested",
		@@( o1.Content() ), @@([ "A", "B", "C", "D", "E" ]))
EndScenario()

Summary()
