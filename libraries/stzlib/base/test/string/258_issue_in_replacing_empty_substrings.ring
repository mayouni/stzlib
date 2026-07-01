load "../../stzBase.ring"
load "../_narrated.ring"

# The Ring builtin substr(str, old, new) replaces a substring, but substr(str,
# "", new) RAISES "Bad parameter value!". Softanza's Replace avoids that issue --
# an empty old is a safe no-op. Archive block #258.

Scenario("Replacing an empty substring is safe in Softanza")
	Given('"Ring language"')
	Then("Ring's substr replaces a non-empty substring", substr("Ring language", "ing", "uby"), "Ruby language")

	# Where Ring's substr(str, "", ..) would raise, Softanza's Replace no-ops:
	o1 = new stzString("Ring Language")
	o1.Replace("", "any")
	Then("Softanza Replace('', 'any') is a safe no-op", o1.Content(), "Ring Language")
EndScenario()

Summary()
