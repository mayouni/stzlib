load "../../stzBase.ring"
load "../_narrated.ring"

# Script identifiers: name, abbreviation, code. Archive block #665.

Scenario("Recognizing script identifiers")
	Then("arabic is a script", StzStringQ(:Arabic).IsScript(), TRUE)
	Then("... and a script name", StzStringQ(:Arabic).IsScriptName(), TRUE)
	Then("Arab is its abbreviation", StzStringQ(:Arab).IsScriptAbbreviation(), TRUE)
	Then("1 is a script code", StzStringQ("1").IsScriptCode(), TRUE)
EndScenario()

Summary()
