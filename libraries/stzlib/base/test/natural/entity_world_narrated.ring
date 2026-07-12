# Narrative
# --------
# THE WORLD (NATURAL_VISION step 3): one shared entity registry,
# $oWorldEntities, fed by everything that NAMES a thing and queried by
# everything that WONDERS about one.
#
#   - StzKnow(name, type)          teach the world a fact, idempotently
#   - Naturally() named objects    "call it basket" -> basket:list, automatic
#   - stzText NER                  RegisterNamedEntities(), explicit
#   - WhatIs(name)                 -> the list of TYPES the world knows
#
# This realizes the Semantic Model pillar of the oldest Softanza vision
# (stz-bridging-minds-and-code.md): WhatIs("apple") -> [ "fruit", "company" ].

load "../../stzBase.ring"
load "../_narrated.ring"

Scenario("An empty world answers honestly")
	Then("an unknown name yields the empty list", @@( WhatIs("zorglub") ), "[ ]")
	Given("the world lives in stzListOfEntities, shared by all surfaces")
	Then("the world object is reachable", isObject(WorldEntities()), TRUE)
EndScenario()

Scenario("Teaching facts: StzKnow is idempotent and case-blind")
	nBase = WorldEntities().NumberOfEntities()

	Then("teaching a NEW fact returns 1", StzKnow("Apple", "Fruit"), 1)
	Then("a second meaning of the same name is a new fact",
		StzKnow("apple", "company"), 1)
	Then("re-teaching a known fact returns 0 (silent, never raises)",
		StzKnow("APPLE", "fruit"), 0)

	Then("WhatIs gathers ALL the meanings, lowered",
		@@( WhatIs("apple") ), '[ "fruit", "company" ]')
	Then("exactly two entities were added",
		WorldEntities().NumberOfEntities() - nBase, 2)
EndScenario()

Scenario("Naturally() names feed the world automatically")
	o1 = Naturally("Create a list with [ 1, 2 ] called basket")
	Then("'called basket' -> the world knows basket is a list",
		@@( WhatIs("basket") ), '[ "list" ]')

	o2 = Naturally("Create a string with 'hi' and call it label")
	Then("'call it label' works too (call = NAME_INDICATOR)",
		@@( WhatIs("label") ), '[ "string" ]')

	# regeneration safety: asking for the code again re-runs the whole
	# semantic pipeline -- the idempotent StzKnow must not duplicate
	nBefore = WorldEntities().NumberOfEntities()
	cCode = o1.Code()
	Then("code regeneration adds NO duplicate entities",
		WorldEntities().NumberOfEntities(), nBefore)
EndScenario()

Scenario("stzText NER feeds the world EXPLICITLY")
	oT = new stzText("John Smith works at Microsoft in Paris")
	Then("rule NER sees person / organization / location",
		@@( oT.NamedEntities() ),
		'[ [ "John Smith", "PERSON" ], [ "Microsoft", "ORGANIZATION" ], [ "Paris", "LOCATION" ] ]')

	Then("registering returns how many were NEW", oT.RegisterNamedEntities(), 3)
	Then("the world now knows who John Smith is",
		@@( WhatIs("john smith") ), '[ "person" ]')
	Then("and what Microsoft is", @@( WhatIs("microsoft") ), '[ "organization" ]')
	Then("re-registering the same text adds nothing",
		oT.RegisterNamedEntities(), 0)
EndScenario()

Scenario("One world, many feeders -- the convergence itself")
	# the same name can be known from DIFFERENT sources with different types
	StzKnow("paris", "city")
	Then("NER's location and the taught city coexist on one name",
		@@( WhatIs("paris") ), '[ "location", "city" ]')

	# entity queries work through the standard stzListOfEntities surface
	Then("the world lists its person entities by type",
		@@( WorldEntities().FindEntitiesByType("person") ) != "[ ]", TRUE)
EndScenario()

Scenario("The hypothetical frontier: suppose -> ask -> commit or forget")
	Given("an assumption is an OVERLAY on the world, never a commitment -- the agent reasons 'as if', then concludes or discards; the world stays clean throughout")

	Then("an unsupposed name is unknown", @@( WhatIs("tomato") ), "[ ]")

	SupposeQ("tomato").IsAQ(:Fruit).AndQ().IsAQ(:Vegetable)
	Then("'Suppose tomato is a fruit and is a vegetable' -- visible while supposed",
		@@( WhatIs("tomato") ), '[ "fruit", "vegetable" ]')
	Then("the suppositions are inspectable",
		@@( SuppositionsSoFar() ),
		'[ [ "tomato", "fruit" ], [ "tomato", "vegetable" ] ]')

	ForgetSuppositions()
	Then("FORGET discards -- the world was never touched",
		@@( WhatIs("tomato") ), "[ ]")

	SupposeQ("tomato").IsAQ(:Fruit)
	Then("COMMIT concludes: the supposition becomes knowledge",
		CommitSuppositions(), 1)
	Then("...now the world knows it", @@( WhatIs("tomato") ), '[ "fruit" ]')
	Then("...and the overlay is empty", @@( SuppositionsSoFar() ), "[ ]")
EndScenario()

Scenario("WhatIs through Ask -- one interrogative family, ONE door")
	Given("the two knowledge sources now meet: Ask() consults the ENTITY WORLD on a 'what is X / who is X' question (a '(world)' entry, kind-consistent with recipes), and WhatIs() falls back to the LIBRARY through the same retrieval pipeline when the world is silent")

	StzKnow("zorglang", "language")
	aAns = StzLibDoc([]).Ask("what is zorglang ?")
	Then("the world answers FIRST through Ask", aAns[1][1], "(world)")
	Then("...as a plain sentence", aAns[1][4], "zorglang is a language")

	oT = new stzText("hello")
	aAns = oT.Ask("what is zorglang")
	Then("the same door opens from any OBJECT's Ask",
		aAns[1][3], "zorglang is a language")

	aAns = oT.Ask("make the text uppercase")
	Then("a non-world question stays pure method retrieval",
		aAns[1][1] != "(world)", TRUE)

	aW = WhatIs("uppercase")
	Then("WhatIs, silent in the world, answers from the LIBRARY -- EVERY defining class named, grouped per voice-sibling form",
		StzFindFirst(aW[1], "- the method Uppercase (on stzString, stzStringChar, stzStringText)"), 1)
	Then("...", StzFindFirst(aW[2],
		"- the method Uppercased (on stzString, stzList, stzStringChar, stzStringList)"), 1)

	aW = WhatIs(:Remove)
	Then("...and a widely-implemented method reports ALL its owners",
		StzFindFirst(aW[1], "- the method Remove (on stzString, stzList)"), 1)

	SupposeQ("blorp").IsAQ("gadget")
	aAns = StzLibDoc([]).Ask("who is blorp")
	Then("a supposition answers through the door, while it stands",
		aAns[1][4], "blorp is a gadget")
	ForgetSuppositions()
	Then("...and is honestly gone once forgotten",
		StzLibDoc([]).Ask("who is blorp")[1][1] != "(world)", TRUE)

	Then("unknown everywhere stays honestly empty",
		@@( WhatIs("zorgle") ), "[ ]")
EndScenario()

Summary()
