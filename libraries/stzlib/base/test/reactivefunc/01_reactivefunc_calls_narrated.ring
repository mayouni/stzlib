load "../../stzBase.ring"
load "../_narrated.ring"

# stzReactiveFunc -- MAKING A FUNCTION REACTIVE MEANS IT STILL GETS CALLED.
#
# The class is thin: a wrapped function, an engine, and two ways in -- Call_ for
# the synchronous form and CallAsync for the callback form. Its whole
# configuration surface is what you hand those, so this suite drives them rather
# than reading attributes back.
#
# Call_ built a task, handed it to AddTask, and returned it UNEXECUTED. Its
# async sibling calls Execute() on the local task; this one relied on the engine
# to run it later, and the engine never saw it -- @oEngine is an attribute, so
# AddTask appends to a COPY of the reactive system. Measured: the real engine's
# task list stayed at zero and, after Start(), the wrapped function had run zero
# times. The synchronous entry point of a class whose purpose is calling
# functions did not call the function.

pr()

Scenario("Call_ calls")

	Given("a doubling function made reactive, and a counter to prove it ran")
	oRs = new stzReactiveSystem()
	gRuns = 0
	oF = new stzReactiveFunc(func x { gRuns++  return x * 2 }, oRs)

	When("it is called synchronously")
	oT = oF.Call_([ 21 ])

	# The counter is the mechanism. A status and a result could both come from
	# somewhere else; the function body running could not.
	Then("the wrapped function actually ran", gRuns, 1)
	Then("...the task says it completed", oT.Status(), TASK_COMPLETED)
	Then("...and carries the answer", oT.Result(), 42)
	Then("...with no error", oT.Error(), "")

	# THE NEGATIVE SIBLING: a call that fails must not report completion, or
	# "completed" would be a state the class hands out regardless.
	Given("a function that divides by zero")
	oBad = new stzReactiveFunc(func x { return x / 0 }, oRs)
	oTb = oBad.Call_([ 1 ])
	Then("the failure is reported", oTb.HasFailed(), TRUE)
	Then("...with Ring's real reason", StzFindFirst("divide by zero", oTb.Error()) > 0, TRUE)
	Then("...and it does not claim to have succeeded", oTb.Succeeded(), FALSE)
EndScenario()

Scenario("The two ways in agree")

	# Call_ and CallAsync differ in how the answer reaches you, not in what the
	# answer is. Before this, one of them did not produce one at all.

	Given("the same function reached both ways")
	oRs2 = new stzReactiveSystem()
	oG = new stzReactiveFunc(func x { return x + 100 }, oRs2)

	gDelivered = "(never)"
	oSync = oG.Call_([ 5 ])
	oAsync = oG.CallAsync([ 5 ], func r { gDelivered = "" + r }, NULL)

	Then("the synchronous form has the answer", oSync.Result(), 105)
	Then("...and the async form the same one", oAsync.Result(), 105)
	Then("...delivered to the handler", gDelivered, "105")
	Then("...and the two agree exactly", oSync.Result(), oAsync.Result())
EndScenario()

Scenario("A call shape that cannot work is refused in the caller's terms")

	# The param switch handles one to ten arguments and used to end in an
	# `other` arm that called the function with NONE. So passing eleven arrived
	# as R19 "Calling function with LESS number of parameters" -- the opposite
	# of what the caller did. Anything that was not a list reached len() and
	# came back as "Bad parameter type!".

	Given("a function of eleven parameters")
	oRs3 = new stzReactiveSystem()
	oBig = new stzReactiveFunc(func(a,b,c,d,e,f,g,h,i,j,k) { return a + k }, oRs3)

	When("eleven are passed")
	oT11 = oBig.Call_([1,2,3,4,5,6,7,8,9,10,11])

	Then("it is refused", oT11.HasFailed(), TRUE)
	Then("...saying there were too many", StzFindFirst("too many params", oT11.Error()) > 0, TRUE)
	Then("...naming the count the caller passed", StzFindFirst("11", oT11.Error()) > 0, TRUE)
	Then("...and the limit", StzFindFirst("limit is 10", oT11.Error()) > 0, TRUE)
	Then("...and NOT the opposite complaint", StzFindFirst("less number", oT11.Error()), 0)

	Given("params that are not a list at all")
	oT0 = oBig.Call_(21)
	Then("that is refused too", oT0.HasFailed(), TRUE)
	Then("...saying what was expected", StzFindFirst("must be a list", oT0.Error()) > 0, TRUE)

	# THE NEGATIVE SIBLINGS, and the boundary that matters: ten is the limit, so
	# ten must still work. A refusal that swallowed the legal maximum would be a
	# worse bug than the one being fixed.
	Given("the legal shapes")
	oTen = new stzReactiveFunc(func(a,b,c,d,e,f,g,h,i,j) { return a + j }, oRs3)
	Then("exactly ten is accepted", oTen.Call_([1,2,3,4,5,6,7,8,9,10]).Result(), 11)

	oOne = new stzReactiveFunc(func x { return x * 3 }, oRs3)
	Then("one is accepted", oOne.Call_([ 7 ]).Result(), 21)

	oNone = new stzReactiveFunc(func { return 99 }, oRs3)
	Then("none is accepted", oNone.Call_([]).Result(), 99)
EndScenario()

Scenario("What is still not connected, pinned rather than glossed")

	# AddTask appends to a COPY of the reactive system, because @oEngine is an
	# attribute and Ring copies an object on assignment. Both entry points do
	# it, so this is the engine-identity problem rather than either method's,
	# and it is left visible instead of quietly dropped.
	#
	# It no longer costs anything: the answer comes from Execute() on the LOCAL
	# task, which is how CallAsync has always worked. The assertion exists so
	# that anyone who fixes engine identity finds this waiting.

	Given("a reactive function whose engine tasks are counted")
	oRs4 = new stzReactiveSystem()
	oQ = new stzReactiveFunc(func x { return x }, oRs4)
	Then("the engine starts with no tasks", len(oRs4.@tasks), 0)

	When("a call is made")
	oTq = oQ.Call_([ 1 ])

	Then("the engine STILL has none -- AddTask reached a copy", len(oRs4.@tasks), 0)
	Then("...yet the caller's task ran anyway", oTq.Status(), TASK_COMPLETED)
EndScenario()

Summary()

pf()
