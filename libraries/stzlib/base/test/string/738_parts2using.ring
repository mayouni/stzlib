load "../../stzBase.ring"
load "../_narrated.ring"

# Parts2Using with the bare CharQ(@i) spelling, over four different
# partitioners. (Orientation speaks the settled compact ltr/rtl
# vocabulary; the archive's :LeftToRight was the verbose Qt-era name.)
# Archive block #738.

Scenario("One string, four partitions")
	o1 = new stzString("Abc285XY&من")
	Then("by letterhood",
		ListEq( o1.Parts2Using( 'CharQ(@i).IsLetter()' ),
			[ [ "Abc", TRUE ], [ "285", FALSE ], [ "XY", TRUE ],
			  [ "&", FALSE ], [ "من", TRUE ] ] ), TRUE)
	Then("by orientation",
		ListEq( o1.Parts2Using( 'CharQ(@i).Orientation()' ),
			[ [ "Abc285XY&", "ltr" ], [ "من", "rtl" ] ] ), TRUE)
	Then("by uppercaseness",
		ListEq( o1.Parts2Using( 'CharQ(@i).IsUppercase()' ),
			[ [ "A", TRUE ], [ "bc285", FALSE ], [ "XY", TRUE ],
			  [ "&من", FALSE ] ] ), TRUE)
	Then("by char case",
		ListEq( o1.Parts2Using( 'CharQ(@i).CharCase()' ),
			[ [ "A", :Uppercase ], [ "bc", :Lowercase ], [ "285", "" ],
			  [ "XY", :Uppercase ], [ "&من", "" ] ] ), TRUE)
EndScenario()

Summary()

func ListEq aA, aE
	if len(aA) != len(aE) return FALSE ok
	nLen = len(aA)
	for i = 1 to nLen
		if isList(aA[i]) and isList(aE[i])
			if NOT ListEq(aA[i], aE[i]) return FALSE ok
		else
			if aA[i] != aE[i] return FALSE ok
		ok
	next
	return TRUE
