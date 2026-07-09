# Narrative
# --------
# HasPath: does a nested hashlist contain a given key PATH?
#
# Given a tree of nested hashlists, HasPath walks the list of keys step by
# step and reports whether the whole path exists. A path that runs off the
# end (or names a missing key at any level) returns FALSE. Handy for safely
# probing deep config/JSON-like structures before reading them.
#
# Extracted from stzlisttest.ring, block #2.

load "../../stzBase.ring"
load "../_narrated.ring"

Scenario("HasPath: does a nested hashlist contain a given key PATH? Given a tree of nested hashlists")

	aHash = [
		:user = [
			:profile = [
				:settings = [
					:theme = "dark",
					:language = "en"
				]
			],
			:name = "John"
		],
		:config = "value"
	]

	# Present paths -> TRUE
	Then("haspath example 1", @@( HasPath(aHash, [:user]) ), @@( TRUE ))
	Then("haspath example 2", @@( HasPath(aHash, [:user, :profile]) ), @@( TRUE ))
	Then("haspath example 3", @@( HasPath(aHash, [:user, :profile, :settings]) ), @@( TRUE ))

	# Missing / overrun paths -> FALSE
	Then("haspath example 4", @@( HasPath(aHash, [:user, :profile, :settings, :nonexistent]) ), @@( FALSE ))
	Then("haspath example 5", @@( HasPath(aHash, [:user, :missing]) ), @@( FALSE ))
	Then("haspath example 6", @@( HasPath(aHash, [:nothere]) ), @@( FALSE ))
EndScenario()

Summary()
