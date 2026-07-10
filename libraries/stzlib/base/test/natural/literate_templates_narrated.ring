# Narrative
# --------
# THE TWO MARKUP SEEDS (NATURAL_VISION step 5). stzNaturalMarkup is retired,
# but two of its ideas graduate in modern form, as thin doors into the real
# engine:
#
#   1. LITERATE BLOCKS -- the #< ... #> fence survives as a fence only:
#      natural programs embedded in any document, extracted and RUN.
#      Executable documentation for the educator/researcher audience of
#      stz-bridging-minds-and-code.md.
#   2. NATURAL TEMPLATES -- the {#n} parameter slots survive as fill-in
#      holes: one narration, many instantiations. Unfilled holes REFUSE
#      loudly; a template is a contract, not a suggestion.

load "../../stzBase.ring"
load "../_narrated.ring"

Scenario("A document's natural blocks execute -- prose stays prose")
	cDoc = "This tutorial explains deduplication." + nl +
	"#<" + nl +
	"Create a list with [ 3, 1, 3 ] and remove its duplicates" + nl +
	"#>" + nl +
	"Now let us ask a question:" + nl +
	"#<" + nl +
	"Create a string with 'ring' Is it lowercase ?" + nl +
	"#>" + nl +
	"The end."

	Then("both fenced blocks are found, prose is ignored",
		len( StzNaturalBlocks(cDoc) ), 2)

	aEngines = NaturallyFromDoc(cDoc)
	Then("each block runs as its own program",
		@@( aEngines[1].Result() ), "[ 3, 1 ]")
	Then("an interrogative block records its answers",
		@@( aEngines[2].Answers() ), "[ 1 ]")
	Then("and each block can paraphrase itself back",
		aEngines[1].Understood(),
		"create a list with [ 3, 1, 3 ] -> remove duplicates")
EndScenario()

Scenario("A document with no fences is just prose")
	Then("no blocks, no programs",
		len( NaturallyFromDoc("Nothing to run here.") ), 0)
EndScenario()

Scenario("Natural templates: one narration, many instantiations")
	cTmpl = "Create a list with {#1} and remove its duplicates"

	o1 = NaturallyWith(cTmpl, [ [ 5, 3, 5 ] ])
	Then("a list value fills the hole", @@( o1.Result() ), "[ 5, 3 ]")

	o2 = NaturallyWith(cTmpl, [ [ 9, 9, 4 ] ])
	Then("the SAME template re-instantiates", @@( o2.Result() ), "[ 9, 4 ]")

	o3 = NaturallyWith("Create a string with {#1} and uppercase it",
		[ "it's here" ])
	Then("strings render double-quoted, so apostrophes survive",
		o3.Result(), "IT'S HERE")

	o4 = NaturallyWith("Create a list with {#1} called {#2}",
		[ [ 1, 2 ], "tbasket" ])
	Then("a template's named object reaches the world too",
		@@( WhatIs("tbasket") ), '[ "list" ]')
EndScenario()

Scenario("An unfilled hole refuses loudly")
	bRefused = FALSE
	try
		NaturallyWith("Create a string with {#1} and {#2} it", [ "x" ])
	catch
		bRefused = TRUE
	done
	Then("a template is a contract, not a suggestion", bRefused, TRUE)
EndScenario()

Summary()
