# Narrative
# --------
# pr()
#
# Extracted from stzlisttest.ring, block #2.

load "../../stzBase.ring"


# Test case
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

# These should return TRUE
? HasPath(aHash, [:user])
? HasPath(aHash, [:user, :profile])
? HasPath(aHash, [:user, :profile, :settings])

# These should return FALSE
? HasPath(aHash, [:user, :profile, :settings, :nonexistent])
? HasPath(aHash, [:user, :missing])
? HasPath(aHash, [:nothere])

pf()
# Executed in almost 0 second(s) in Ring 1.24
