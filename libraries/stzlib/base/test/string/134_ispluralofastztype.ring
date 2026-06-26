load "../../stzBase.ring"
load "../_narrated.ring"

# IsPluralOfAStzType() -- whether a symbol names the plural of a Softanza type
# (e.g. :stzListsOfStrings is the plural family form). Archive block #134.

Scenario("Recognising a plural Softanza type name")
	Then(":stzListsOfStrings is a plural stz type", Q(:stzListsOfStrings).IsPluralOfAStzType(), TRUE)
EndScenario()

Summary()
