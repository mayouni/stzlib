load "../../stzBase.ring"
load "../_narrated.ring"

# A cleanup pipeline: drop the digit chars (the W form -- the archive's
# RemoveCharsWXTQ spelling is retired; RemoveCharsWQ is its eval-free
# replacement, and IsNumberInString lowers to the engine's isDigit),
# drop the spaces, then dedup. Archive block #460.

Scenario("Boiling a tuple down to its punctuation")
	Then("(9, 7, 8) reduces to (,)",
		Q("(9, 7, 8)").
			RemoveCharsWQ('Q(@Char).IsNumberInString()').	# becomes (, , )
			RemoveSpacesQ().				# becomes (,,)
			RemoveDuplicatedCharsQ().			# becomes (,)
			Content(), "(,)")
EndScenario()

Summary()
