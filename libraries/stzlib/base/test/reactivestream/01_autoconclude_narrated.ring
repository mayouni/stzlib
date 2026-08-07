load "../../stzBase.ring"
load "../_narrated.ring"

# stzReactiveStream -- THE AUTO-CONCLUDE SETTERS.
#
# An earlier pass audited the overflow strategies. This is the other cluster:
# SetAutoConclude, SetAutoConcludeDelay, SetAutoConcludeXT, and the timer they
# drive. Every one of the three was broken, in a different way.
#
#   SetAutoConclude(FALSE)  raised R14. It cancelled through
#                           @oEngine.TimerManager(), a method that exists
#                           nowhere in the library -- the engine holds
#                           @timerManager as an ATTRIBUTE, which is how
#                           ScheduleAutoConclude twelve lines below reached it.
#                           So turning the feature OFF crashed exactly when it
#                           had a timer to cancel, and passed quietly when it
#                           had nothing to do.
#
#   the timer callback      raised R24 "Using uninitialized variable:
#                           @pendingdatacount". It was written as
#                           `func() { if @pendingDataCount = 0 ... }`, and a
#                           Ring lambda has its own scope. stzRingTimer stores
#                           the object it is handed and then invokes
#                           `call @callback()` with no arguments, so the object
#                           was kept and never passed. Auto-conclude never
#                           concluded anything, and the raise happened inside
#                           the timer runner where nothing reported it.
#
#   SetAutoConcludeDelay    took anything. -500 and "not a number" both went
#                           straight through to a timer deadline.

pr()

Scenario("Auto-conclude concludes")

	# The fix routes through the DETACHED timer helpers, which were already in
	# this module: F5 added them for the settle watchers for exactly this reason
	# -- StzReaxisTickDetached passes the argument list through to the callback,
	# so the callback is HANDED what it needs instead of reaching for it. The
	# same RunLoop drives them, so nothing changed about when timers run.

	Given("a stream set to conclude itself once the data stops")
	oRs = new stzReactiveSystem()
	oS = oRs.CreateStream("s1")
	nDone = 0
	oS.OnNoMore(func { nDone++ })
	oS.SetAutoConclude(TRUE)
	oS.SetAutoConcludeDelay(1)
	oS.Receive(1)

	Then("a conclusion is scheduled", oS.@autoConcludeTimer != "", TRUE)

	When("the delay passes and the loop ticks")
	FireDetached()

	Then("the conclude handler runs", nDone, 1)

	# ...AND WHAT STILL DOES NOT WORK, pinned rather than glossed.
	#
	# Ring copies an object placed in a LIST -- proven directly: mutate through
	# a list and the original is untouched; pass the same object as a call
	# ARGUMENT and it is not. The timer's argument list therefore holds a COPY
	# of the stream, so the callback's own bookkeeping lands on the copy. The
	# handler fires because calling it reaches outward; @isConcluded does not
	# change because setting it reaches inward.
	#
	# It goes deeper than this setter: CreateStreamXT does AddStream(_stream_)
	# and then `return _stream_`, so the caller's stream and the engine's are
	# already two objects. Nothing here can fix that.
	#
	# It is not observable through the public surface today -- the class has no
	# IsConcluded() reader. These two assertions exist so that adding one has to
	# reckon with this rather than inherit a flag that quietly lies.
	Then("the caller's own concluded flag does NOT update (copy, documented)", oS.@isConcluded, FALSE)
	Then("...nor does its timer id clear", oS.@autoConcludeTimer != "", TRUE)

	# THE NEGATIVE SIBLING: a stream that was never told to auto-conclude must
	# not, or the assertion above would hold for a handler that simply fires on
	# every tick there is.
	Given("a stream left on its own")
	oOff = oRs.CreateStream("s2")
	nOff = 0
	oOff.OnNoMore(func { nOff++ })
	oOff.SetAutoConclude(FALSE)
	oOff.SetAutoConcludeDelay(1)
	oOff.Receive(1)
	FireDetached()
	Then("nothing concludes it", nOff, 0)
	Then("...and nothing was scheduled", oOff.@autoConcludeTimer, "")
EndScenario()

Scenario("Turning it off is what used to break")

	# The setter raised R14 whenever there was a timer to cancel -- which is the
	# only time it had anything to do. Both halves matter: it must not raise,
	# and the conclusion must actually not happen.

	Given("a stream with a conclusion already scheduled")
	oRs2 = new stzReactiveSystem()
	oC = oRs2.CreateStream("c1")
	nC = 0
	oC.OnNoMore(func { nC++ })
	oC.SetAutoConclude(TRUE)
	oC.SetAutoConcludeDelay(1)
	oC.Receive(1)
	Then("it is scheduled", oC.@autoConcludeTimer != "", TRUE)

	When("auto-conclude is switched off")
	bRaised = TRUE
	try
		oC.SetAutoConclude(FALSE)
		bRaised = FALSE
	catch
		bRaised = TRUE
	done

	Then("the setter does not raise", bRaised, FALSE)
	Then("...and the pending timer is let go", oC.@autoConcludeTimer, "")

	When("the delay passes anyway")
	FireDetached()
	Then("the cancelled conclusion does not happen", nC, 0)
EndScenario()

Scenario("A delay the timer cannot use is refused, and the good one survives")

	Given("a stream given a workable delay")
	oRs3 = new stzReactiveSystem()
	oV = oRs3.CreateStream("v1")
	oV.SetAutoConcludeDelay(750)
	Then("it takes it", oV.@autoConcludeDelay, 750)

	# A REFUSED VALUE MUST NOT DESTROY A GOOD ONE. That is a house rule with its
	# own code rule (setter-resets-on-reject); the point of checking it here is
	# that the delay a caller chose has to still be there afterwards.
	When("it is handed a negative delay")
	oV.SetAutoConcludeDelay(-500)
	Then("the refusal keeps the old value", oV.@autoConcludeDelay, 750)

	When("it is handed something that is not a number at all")
	oV.SetAutoConcludeDelay("not a number")
	Then("the refusal keeps the old value", oV.@autoConcludeDelay, 750)

	# THE NEGATIVE SIBLING: refusing must not mean refusing everything. Zero is
	# a legitimate delay -- conclude as soon as the loop next comes round.
	When("it is handed zero")
	oV.SetAutoConcludeDelay(0)
	Then("zero is accepted", oV.@autoConcludeDelay, 0)
EndScenario()

Scenario("The XT form sets both halves, and the alias is the same setter")

	Given("a stream configured in one call")
	oRs4 = new stzReactiveSystem()
	oX = oRs4.CreateStream("x1")
	oX.SetAutoConcludeXT(TRUE, 250)

	Then("the switch is on", oX.@autoConcludeEnabled, TRUE)
	Then("...and the delay came with it", oX.@autoConcludeDelay, 250)

	# The XT form delegates to the two single setters, so a value the delay
	# setter refuses must be refused here too -- otherwise the validation would
	# be reachable one way and not the other.
	When("the XT form is given a delay that cannot work")
	oX.SetAutoConcludeXT(TRUE, -9)
	Then("the refusal reaches through the XT form", oX.@autoConcludeDelay, 250)

	Given("the same thing spelled SetAutoComplete")
	oA = oRs4.CreateStream("a1")
	oA.SetAutoComplete(TRUE)
	Then("the alias drives the same attribute", oA.@autoConcludeEnabled, TRUE)
EndScenario()

Summary()

pf()

#-- helpers --------------------------------------------------------------------

# Let a 1ms deadline pass, then drive the detached table once, the way a
# RunLoop iteration does.
func FireDetached()
	_nT_ = StzEngineTimeNowMs()
	while StzEngineTimeNowMs() - _nT_ < 25
	end
	StzReaxisTickDetached()
