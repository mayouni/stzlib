# Narrative
# --------
# #TODO Write a small narration about HasKey(), HasKeys(),
#
# Extracted from stzhashlisttest.ring, block #1.
#ERR Error (C22) : Function redefinition, function is already defined!

load "../../stzBase.ring"

# HasKeysXT(), and HasPath() and how they help make safe access
# hashlists and deeplists by keys, and help avoid Ring issue
# discribed in the example next this one

pr()

aHash = [
	:name = "Alice",
	:email = "alice@example.com",
	:age = 30
]

? HasKey(aHash, "email")
#--> TRUE

? HasKey(aHash, "none")
#--> FALSE

? HasKeys(aHash, [ "name", "age" ])
#--> TRUE

? HasKeys(aHash, [ "name", "none", "age" ])
#--> FALSE

? @@( HasKeysXT(aHash, [ "name", "none", "age" ]) ) + NL
#--> [ TRUE, FALSE, TRUE ]

#--

aDeepHash = [
	:name = "TechCorp",
	:departments = [
		:name = "Engineering",
		:teams = [
			:name = "Backend",
			:members = [
				:name = "Alice",
				:role = "Senior Developer"
			]
		]
	]
]

? HasPath(aDeepHash, ["departments", "teams", "members"])
#--> TRUE

pf()
# Executed in almost 0 second(s) in Ring 1.24
