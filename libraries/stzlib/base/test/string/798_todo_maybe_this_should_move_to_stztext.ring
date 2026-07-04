load "../../stzBase.ring"
load "../_narrated.ring"

# Orientation of mixed-script strings -- the settled compact ltr/rtl
# vocabulary (the archive's :LeftToRight was Qt-era), decided by the
# FIRST char; ContainsHybridOrientation flags the mix.
# Archive block #798.

Scenario("Two sentences, two leading directions")
	o1 = new stzString("ring language isسلام  a nice language")
	Then("latin head: ltr", o1.Orientation(), "ltr")
	Then("but hybrid inside", o1.ContainsHybridOrientation(), TRUE)
	o2 = new stzString("سلام عليكم ياأهل مصر hello الكرام")
	Then("arabic head: rtl", o2.Orientation(), "rtl")
	Then("hybrid too", o2.ContainsHybridOrientation(), TRUE)
EndScenario()

Summary()
