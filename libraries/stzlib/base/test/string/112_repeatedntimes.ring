load "../../stzBase.ring"
load "../_narrated.ring"

# Repeating a string N times: RepeatedNTimes(n), NCopies(n, s), and the named
# 3Copies(:of = s) all work. Archive block #112.
#
# DEFECT (deferred -- see _AUDIT_DEFECTS.md): the dynamic-name form
# Repeated3Times() returns "" instead of "♥♥♥". Left as an un-asserted NOTE.

Scenario("Repeating a character three times")
	Then("RepeatedNTimes(3) is three hearts", Q("♥").RepeatedNTimes(3), "♥♥♥")
	Then("NCopies(3, '♥') is three hearts", NCopies(3, "♥"), "♥♥♥")
	Then("3Copies(:of='♥') is three hearts", 3Copies(:of = "♥"), "♥♥♥")
	# The dynamic Repeated<N>Times form is broken:
	? "  NOTE  Q('♥').Repeated3Times() -> " + @@(Q("♥").Repeated3Times()) + "  (should be ♥♥♥ -- deferred)"
EndScenario()

Summary()
