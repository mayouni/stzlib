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

pr()

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
? HasPath(aHash, [:user])
#--> TRUE
? HasPath(aHash, [:user, :profile])
#--> TRUE
? HasPath(aHash, [:user, :profile, :settings])
#--> TRUE

# Missing / overrun paths -> FALSE
? HasPath(aHash, [:user, :profile, :settings, :nonexistent])
#--> FALSE
? HasPath(aHash, [:user, :missing])
#--> FALSE
? HasPath(aHash, [:nothere])
#--> FALSE

pf()
# Executed in almost 0 second(s)
