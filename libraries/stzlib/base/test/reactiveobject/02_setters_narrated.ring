load "../../stzBase.ring"
load "../_narrated.ring"

# stzReactiveObject -- THE CONFIGURATION SURFACE.
#
# Watch, Computed, BindTo, SetAsync, SetAttribute. A companion suite covered
# what the class does with an error it CATCHES; this one covers what it does
# with a configuration it is GIVEN.
#
# SetAsync had never run. It built its task with three arguments where
# stzReactiveTask.init takes four, so every call raised R19 "Calling function
# with less number of parameters" on the construction itself. Behind that sat
# two more failures that only became visible once it got past the first: the
# task function `func { return _newValue_ }` raised R24 reading a caller's
# local, and the Then_ handler called a bare SetAttribute(...), which inside a
# lambda's own scope is a global-function lookup rather than this object's
# method. Three lambda-scope mistakes stacked in one method.

pr()

Scenario("SetAsync sets")

	Given("a reactive object holding a known value")
	oRs = new stzReactiveSystem()
	oA = oRs.ReactivateObject(new persr)
	oA.OnError(func(w, m) { })
	oA.SetAttribute(:name, "before")
	Then("it starts where we put it", oA.GetAttribute(:name), "before")

	When("the value is set through SetAsync")
	gGot = "(never)"
	oT = oA.SetAsync(:name, "after", func v { gGot = "" + v }, NULL)

	# The attribute is the mechanism. A task status could be set without the
	# store ever changing, and the callback could fire without either.
	Then("the attribute actually changed", oA.GetAttribute(:name), "after")
	Then("...the success handler was called with the value", gGot, "after")
	Then("...and the task says it completed", oT.Status(), TASK_COMPLETED)
	Then("...carrying the same value", oT.Result(), "after")
	Then("...with nothing recorded against the object", oA.HasErrors(), FALSE)
EndScenario()

Scenario("Every setter answers the object, so a configuration can be a chain")

	# Watch and Computed already did. SetAttribute and BindTo did not -- and
	# SetAttribute is the call most likely to be in the middle of a chain.

	Given("a reactive object")
	oRs2 = new stzReactiveSystem()
	oC = oRs2.ReactivateObject(new persr)
	oC.OnError(func(w, m) { })

	Then("Watch answers the object", isObject(oC.Watch(:name, func(s, a, o, n) { })), TRUE)
	Then("Computed does too", isObject(oC.Computed(:c, func obj { return 1 }, [ :name ])), TRUE)
	Then("...and SetAttribute", isObject(oC.SetAttribute(:name, "x")), TRUE)
	Then("...and BindTo", isObject(oC.BindTo(oRs2.ReactivateObject(new persr), :name, :name)), TRUE)

	When("they are strung together")
	nSeen = 0
	oD = oRs2.ReactivateObject(new persr)
	oD.OnError(func(w, m) { }).Watch(:name, func(s, a, o, n) { nSeen++ }).SetAttribute(:name, "chained")

	Then("the chain reached the end", oD.GetAttribute(:name), "chained")
	Then("...and the watcher registered mid-chain fired", nSeen, 1)
EndScenario()

Scenario("A configuration that cannot work is refused where it was made")

	# Each of these used to fail somewhere else entirely. A non-function watcher
	# was stored and only broke on the next change. Non-list dependencies broke
	# in find(), from UpdateDependentComputedAttributes, on some later and
	# unrelated set. A non-object bind target raised R14 out of BindTo itself.
	#
	# isFunction is the test that works here: a Ring lambda IS a string
	# ("_ring_anonymous_func_NNN"), so isString cannot tell one from the literal
	# text "not a function", and isFunction can.

	Given("a reactive object given a watcher that is not a function")
	oRs3 = new stzReactiveSystem()
	oW = oRs3.ReactivateObject(new persr)
	oW.OnError(func(w, m) { })
	oW.Watch(:name, "not a function")

	Then("it is refused at registration", oW.HasErrors(), TRUE)
	Then("...named for the call that was wrong, not the later change",
	     oW.LastErrorWhere(), "Watch:name")
	Then("...saying what was expected", StzFindFirst("not a function", oW.LastError()) > 0, TRUE)

	# ...and the refusal must not have registered it anyway.
	When("the attribute it would have watched changes")
	nBefore = oW.ErrorCount()
	oW.SetAttribute(:name, "moved")
	Then("nothing further is recorded", oW.ErrorCount(), nBefore)

	Given("dependencies that are not a list")
	oCd = oRs3.ReactivateObject(new persr)
	oCd.OnError(func(w, m) { })
	oCd.Computed(:c, func obj { return 1 }, "not a list")
	Then("that is refused too", oCd.LastErrorWhere(), "Computed:c")
	Then("...saying a list was expected", StzFindFirst("must be a list", oCd.LastError()) > 0, TRUE)

	# THE POINT of refusing at registration: an unrelated set later must not
	# blow up. This used to raise "Bad parameter type!" out of find().
	When("some other attribute changes afterwards")
	bRaised = TRUE
	try
		oCd.SetAttribute(:age, 42)
		bRaised = FALSE
	catch
		bRaised = TRUE
	done
	Then("the later, unrelated set does not raise", bRaised, FALSE)
	Then("...and it worked", oCd.GetAttribute(:age), 42)

	Given("a computer that is not a function")
	oCf = oRs3.ReactivateObject(new persr)
	oCf.OnError(func(w, m) { })
	oCf.Computed(:c, "not a function", [ :name ])
	Then("that is refused", StzFindFirst("not a function", oCf.LastError()) > 0, TRUE)

	Given("a bind target that is not an object at all")
	oBt = oRs3.ReactivateObject(new persr)
	oBt.OnError(func(w, m) { })
	oBt.BindTo("not an object", :name, :name)
	Then("it is refused rather than raised", oBt.LastErrorWhere(), "BindTo:name")
	Then("...saying what a target has to be", StzFindFirst("must be a reactive object", oBt.LastError()) > 0, TRUE)
EndScenario()

Scenario("The valid forms are not refused")

	# THE NEGATIVE SIBLINGS for the whole scenario above. A validator that
	# refused everything would satisfy every assertion in it.

	Given("a reactive object configured correctly in every way")
	oRs4 = new stzReactiveSystem()
	oOk = oRs4.ReactivateObject(new persr)
	oOk.OnError(func(w, m) { })

	nFires = 0
	oOk.Watch(:name, func(s, a, o, n) { nFires++ })
	oOk.Computed(:c, func obj { return "c:" + obj.GetAttribute(:name) }, [ :name ])
	oOk.BindTo(oRs4.ReactivateObject(new persr), :age, :age)

	When("an attribute changes")
	oOk.SetAttribute(:name, "valid")

	Then("nothing was refused", oOk.HasErrors(), FALSE)
	Then("...the watcher fired", nFires, 1)
	Then("...and the computed attribute recomputed", oOk.GetAttribute(:c), "c:valid")

	# A named global function is a legitimate callback too, not only a lambda.
	oNamed = oRs4.ReactivateObject(new persr)
	oNamed.OnError(func(w, m) { })
	oNamed.Watch(:name, "AWatcher")
	Then("a named function is accepted", oNamed.HasErrors(), FALSE)
EndScenario()

Summary()

pf()

#-- helpers --------------------------------------------------------------------

func AWatcher(oSelf, cAttr, oldV, newV)
	return TRUE

class persr
	name = ""
	age = 0
	c = ""
