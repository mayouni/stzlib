# An Atelier notebook: 4 cell(s). The edition of this file is built by edition.ring (B4).
# Each cell is a Scenario; each ? line with its #--> promise, and each Then(...), is a claim.
# Run it from a folder of base/test, or open it again in the Atelier.

load "../../stzBase.ring"
load "../_narrated.ring"

Scenario("A scene: the object after each line")
o1 = new stzList([ "tea", "rice", "tea", "fish", "rice", "tea" ])
o1 {
    ? NumberOfDuplicates()
    #--> 3

    ? @@( DuplicatesRemoved() )
    #--> [ "tea", "rice", "fish" ]

    RemoveDuplicates()
    ? @@( Content() )
    #--> [ "tea", "rice", "fish" ]
}

Scenario("A chain, unfolded")
? Q("softanza").UppercaseQ().Spacified()
#--> S O F T A N Z A

Scenario("The cells above, read from here")
Then("the scene left three items", o1.NumberOfItems(), 3)
Then("twice that, by a helper of this cell", Twice(o1.NumberOfItems()), 6)


Scenario("A drawing")
? new stzBarPlot([ :Tea = 3, :Rice = 2, :Fish = 1 ])

Summary()

# definitions of cell 3
func Twice n
	return 2 * n
