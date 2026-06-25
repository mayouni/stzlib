load "../../stzBase.ring"
load "../_narrated.ring"

# ContainsEither(a, :Or = b) -- TRUE if the string contains a OR b (INCLUSIVE:
# at least one; containing BOTH still satisfies it). The exclusive "exactly one"
# form is ContainsOnlyOneOfThese (see 13). Correctness note: the original print
# test claimed FALSE for the both-present case -- that was a stale/wrong #-->;
# the implementation is an inclusive or, so it is TRUE.

Scenario("ContainsEither is an inclusive or")
	Given('"me you all the others" (both words) and "me and all the others" (only me)')
	Then("both words present is still TRUE (inclusive)",
		Q("me you all the others").ContainsEither("me", :Or = "you"), TRUE)
	Then("only one word present is TRUE",
		Q("me and all the others").ContainsEither("me", :Or = "you"), TRUE)
EndScenario()

Summary()
