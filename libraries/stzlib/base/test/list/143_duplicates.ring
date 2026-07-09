# Narrative
# --------
# #NLP
#
# Extracted from stzlisttest.ring, block #143.

load "../../stzBase.ring"
load "../_narrated.ring"

Scenario("#NLP")

	# Word frequency analysis
	aWords = [
	    "the", "cat", "sat", "on", "the", "mat",
	    "the", "cat", "sat", "there"
	]

	oWords = new stzList(aWords)

	# Find all duplicate words

	Then("duplicates example 1", @@( oWords.Duplicates() ), @@( ["the", "cat", "sat"] ))

	# Get word positions with context

	Then("duplicates example 2", @@( oWords.DuplicatesZ() ), @@( [ [ "the", [ 5, 7 ] ], [ "cat", [ 8 ] ], [ "sat", [ 9 ] ] ] ))
EndScenario()

Summary()
