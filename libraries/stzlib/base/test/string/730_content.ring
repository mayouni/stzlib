load "../../stzBase.ring"
load "../_narrated.ring"

# Hash mutates the content into its hex digest -- engine-backed MD5
# (and SHA256; the other SHAs are on the engine backlog).
# Archive block #730.

Scenario("Hashing a string in place")
	o1 = new stzString("original text before hashing")
	o1.Hash(:MD5)
	Then("the md5 hex digest",
		o1.Content(), "8ffad81de2e13a7b68c7858e4d60e263")
EndScenario()

Summary()
