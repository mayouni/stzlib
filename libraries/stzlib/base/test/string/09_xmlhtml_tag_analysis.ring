load "../../stzBase.ring"
load "../_narrated.ring"

# Illustrative: using SubStringsBoundedBy("<",">") + ItemsAndTheirNumberOfOccurrence
# to spot a malformed XML tag. The snippet has <name> opened twice (the second
# should be </name>), which shows up as "name" occurring 2 times. Archive block #9.

Scenario("XML tag-occurrence analysis flags a duplicated tag")
	Given('the snippet <product><name>Phone<name></name><price>599</price></product>')
	Then("each tag and its occurrence count -- note name appears twice",
		@@( Q( (new stzString("<product><name>Phone<name></name><price>599</price></product>")).SubStringsBoundedBy([ "<", ">" ]) ).ItemsAndTheirNumberOfOccurrence() ),
		@@([ [ "product", 1 ], [ "name", 2 ], [ "/name", 1 ], [ "price", 1 ], [ "/price", 1 ], [ "/product", 1 ] ]))
EndScenario()

Summary()
