# Testoor -- the clock that runs backwards, and the weather. TR4 of
# SOFTANZA_TESTOOR_PLAN.md. The tour's side of the bargain: a failing tour
# PRINTS ITS SEED, and the same seed walks the same path.
#
# THE NAME comes from Testour, the Andalusian village in Beja whose Great
# Mosque clock runs counter-clockwise and tells the right time. A tour that
# can be re-walked is a defect that can be caught twice.
#
# WHAT IS NEW AND WHAT IS NOT. The engine already owns the seeded generator
# (StzEngineRandomSeed, reached through SeedRandom, which seeds the engine's
# and Ring's together) and Ring-side the frozen wall clock (StzFreezeClock).
# This file adds the three words a TOUR says. ONE OF THEM IS SPELLED ClockTo,
# NOT Clock, and the reason is a local fact: Ring is case-insensitive and
# clock() is a builtin the library calls hundreds of times, so a global
# function named Clock shadows it and the library stops loading (measured
# 2026-11-03: R19 in stzProfilingTimer on the first load). Seed and Weather
# collide with nothing and keep their names.
#
#   Seed(n)          seed every generator and PRINT "[testoor seed n]" -- the
#                    line the traveller reads into the logbook. Seed(:run)
#                    adopts the seed the RUNNER passed (--testoor-seed), or,
#                    run by hand, draws one from the clock and reports it, so
#                    a failure found by hand can still be walked again.
#   ClockTo(mode, x) :frozen with a timestamp (the existing StzFreezeClock),
#                    :stepped with [ startMs, stepMs ] (a logical clock that
#                    moves ONLY when the tour moves it), :live with "" (undo).
#                    ClockNow(), ClockTick(), ClockAdvance(ms) drive the
#                    stepped clock: ClockTick() is the scheduler hook -- the
#                    tour is the loop, and each tick it asks the clock which
#                    declared weather is due and applies it.
#   Weather(name, spec)  a declared fault, never ambient. :child_killed with
#                    [ child ] or [ child, tick ] -- on the distribution plane
#                    a supervised child dies at that tick (without a tick the
#                    seed picks one, 1 to 6, so the same seed kills at the same
#                    tick); :skew with [ ms ] -- the stepped clock jumps.
#                    WeatherKill(supervisor, fired) applies the child_killed
#                    weather to the platform's OWN stzNodeSupervisor.KillChild:
#                    no mock stands in for it.
#
# WHO OWNS WHAT (P3.2, TESTOOR_ZIG_CORE.md). The world of a tour -- its seed, its stepped clock,
# the weather it declared and the tick each falls due at -- is owned by the Zig core
# (engine/src/testoor_clock.zig) when the stz_testoor library is loaded. The ENGINE keeps that
# state, never a Ring object: Ring copies an object it stores and the copy would fork. What stays
# here is what only Ring can hold or do: each weather's payload (the spec the tour wrote, by
# ordinal), the `[testoor ...]` lines the traveller reads, the frozen wall clock, SeedRandom, and
# the platform's own KillChild. The REFERENCE bodies below (the `...Ring` functions) are what the
# core was written from; they run when the library is absent or TestoorCore("ring") or
# TESTOOR_CORE=ring says so. Choosing who judges resets the world: its state sits in one place.
#
# DIFFERENCES FROM THE REFERENCE, all deliberate and all pinned in testoor_core_narrated.ring:
#   * a weather declared without a tick gets one from the SEED (splitmix64 over the seed and the
#     number of picks since it was set), not from Ring's own generator. Ring's is the C runtime's
#     rand(): the same seed picked another tick on each OS and VM. The core's pick is the same
#     everywhere, and the tour's other draws no longer move it.
#   * ClockTo(:stepped, [ s, d ]), Weather(:child_killed, [ c, t ]) and Weather(:skew, [ ms ])
#     want NUMBERS. The reference took a numeric string and stored it unconverted.
#   * a --testoor-seed that is not a number is no seed (a draw, reported); the reference raised R41.
#
# State of the REFERENCE lives in ONE global hash-list, read and written with the `$` prefix
# everywhere (Rule A): a returned object would be copied by Ring and a mutation through the copy
# would be lost.

$aTestoorWorld = [ :seed = -1, :mode = "live", :ms = 0, :step = 0, :tick = 0, :weather = [] ]

# the core's world: what each weather IS, by ordinal -- [ [ name, spec ] ... ]. Its timing is in the engine.
$aTestoorSpecs = []

# -1 not yet decided, 1 the engine owns the world, 0 the reference does
$nTestoorWorldEngine = -1

#--- who owns the world --------------------------------------------------------

# Does the core own the world of this tour? Decided once, on first use, and again after a reset.
# The probe is a read-only call, so a library built before this call existed falls back, not breaks.
func _TestoorWorldIsEngine()
	if $nTestoorWorldEngine < 0
		$nTestoorWorldEngine = 0
		if TestoorCoreIs() = "engine"
			try
				StzEngineTestoorWorld("mode", "", 0, 0)
				$nTestoorWorldEngine = 1
			catch
				$nTestoorWorldEngine = 0
			done
		ok
	ok
	return ($nTestoorWorldEngine = 1)

func _TestoorWorldCall(pcOp, pcText, pnA, pnB)
	return StzEngineTestoorWorld(pcOp, pcText, pnA, pnB)

# forget what a tour declared, in BOTH places; the wall clock is not touched
func _TestoorWorldForget()
	$aTestoorWorld = [ :seed = -1, :mode = "live", :ms = 0, :step = 0, :tick = 0, :weather = [] ]
	$aTestoorSpecs = []
	$nTestoorWorldEngine = -1
	if $bStzTestoorCore
		try
			StzEngineTestoorWorld("reset", "", 0, 0)
		catch
			$nTestoorWorldEngine = -1
		done
	ok
	return 1

# forget everything a tour declared; the wall clock is thawed too
func TestoorReset()
	_TestoorWorldForget()
	StzUnfreezeClock()
	return 1

#--- Seed --------------------------------------------------------------------

func Seed(pxSeed)
	if NOT _TestoorWorldIsEngine()
		return _SeedRing(pxSeed)
	ok
	_n_ = -1
	if isNumber(pxSeed)
		_n_ = 0 + _TestoorWorldCall("seedset", "", pxSeed, 0)
	else
		_n_ = 0 + _TestoorWorldCall("seedrun", _TestoorArgSeedText(), _TestoorEntropyMs(), 0)
	ok
	SeedRandom(_n_)
	? "[testoor seed " + _n_ + "]"
	return _n_

# a seed from the clock, 1 to 90000: ONE formula, in the core when it is there (the runner draws
# its own seed the same way)
func TestoorDrawSeed()
	if _TestoorWorldIsEngine()
		return 0 + _TestoorWorldCall("draw", "", _TestoorEntropyMs(), 0)
	ok
	return 1 + (floor(clock() * 1000 / clockspersecond()) % 90000)

func _TestoorEntropyMs()
	return clock() * 1000 / clockspersecond()

# the seed the runner passed on the command line, as text; "" when it passed none
func _TestoorArgSeedText()
	_nA_ = len(sysargv)
	for _i_ = 1 to _nA_ - 1
		if sysargv[_i_] = "--testoor-seed"
			return "" + sysargv[_i_ + 1]
		ok
	next
	return ""

#--- Clock -------------------------------------------------------------------

func ClockTo(pcMode, pxArg)
	if NOT _TestoorWorldIsEngine()
		return _ClockToRing(pcMode, pxArg)
	ok
	_m_ = lower("" + pcMode)
	_nStart_ = 0
	_nStep_ = 0
	if _m_ = "frozen"
		StzFreezeClock("" + pxArg)
	but _m_ = "stepped"
		if NOT (isList(pxArg) and len(pxArg) >= 2)
			StzRaise("ClockTo(:stepped, [ startMs, stepMs ]) wants a start and a step.")
		ok
		if NOT (isNumber(pxArg[1]) and isNumber(pxArg[2]))
			StzRaise("ClockTo(:stepped, [ startMs, stepMs ]) wants a start and a step that are numbers.")
		ok
		_nStart_ = pxArg[1]
		_nStep_ = pxArg[2]
	but _m_ = "live"
		StzUnfreezeClock()
	ok
	_cMode_ = _TestoorWorldCall("clockto", _m_, _nStart_, _nStep_)
	if left(_cMode_, 1) = "!"
		StzRaise("ClockTo: unknown mode " + pcMode + " (frozen, stepped, live).")
	ok
	? "[testoor clock " + _cMode_ + "]"
	return _cMode_

func ClockMode()
	if _TestoorWorldIsEngine()
		return _TestoorWorldCall("mode", "", 0, 0)
	ok
	return $aTestoorWorld[:mode]

# the logical milliseconds of the stepped clock; on any other clock the
# engine's own wall milliseconds
func ClockNow()
	if _TestoorWorldIsEngine()
		_c_ = _TestoorWorldCall("now", "", 0, 0)
		if _c_ != ""  return 0 + _c_  ok
		return StzEngineTimeNowMs()
	ok
	return _ClockNowRing()

func ClockAdvance(pnMs)
	if NOT _TestoorWorldIsEngine()
		return _ClockAdvanceRing(pnMs)
	ok
	_c_ = _TestoorWorldCall("advance", "", 0 + pnMs, 0)
	if left(_c_, 1) = "!"
		StzRaise("ClockAdvance wants ClockTo(:stepped, [ startMs, stepMs ]) first.")
	ok
	return 0 + _c_

func ClockTicks()
	if _TestoorWorldIsEngine()
		return 0 + _TestoorWorldCall("ticks", "", 0, 0)
	ok
	return $aTestoorWorld[:tick]

# ONE step of the stepped clock, and the weather that falls due at it:
# [ [ name, spec ] ... ], each printed once as "[testoor weather fired n@t]"
func ClockTick()
	if NOT _TestoorWorldIsEngine()
		return _ClockTickRing()
	ok
	_c_ = _TestoorWorldCall("tick", "", 0, 0)
	if left(_c_, 1) = "!"
		StzRaise("ClockTick wants ClockTo(:stepped, [ startMs, stepMs ]) first.")
	ok
	_aFired_ = []
	if _c_ != ""
		_nTick_ = 0 + _TestoorWorldCall("ticks", "", 0, 0)
		_acO_ = str2list(_c_)
		_nO_ = len(_acO_)
		for _i_ = 1 to _nO_
			_aW_ = $aTestoorSpecs[0 + _acO_[_i_]]
			_aFired_ + [ _aW_[1], _aW_[2] ]
			? "[testoor weather fired " + _aW_[1] + "@" + _nTick_ + "]"
		next
	ok
	return _aFired_

#--- Weather -----------------------------------------------------------------

# declares a fault and answers the tick it will fall due at (0 = at once)
func Weather(pcName, paSpec)
	if NOT _TestoorWorldIsEngine()
		return _WeatherRing(pcName, paSpec)
	ok
	if 0 + _TestoorWorldCall("seed", "", 0, 0) < 0
		Seed(:run)
	ok
	_cN_ = lower("" + pcName)
	_c_ = ""
	if _cN_ = "child_killed"
		if NOT (isList(paSpec) and len(paSpec) >= 1)
			StzRaise("Weather(:child_killed, [ child ] or [ child, tick ]).")
		ok
		if len(paSpec) >= 2
			if NOT isNumber(paSpec[2])
				StzRaise("Weather(:child_killed, [ child, tick ]) wants a tick that is a number.")
			ok
			_c_ = _TestoorWorldCall("declarekill", "", paSpec[2], 0)
		else
			# the seed picks the tick: the same seed kills at the same tick, on any machine
			_c_ = _TestoorWorldCall("declarepick", "", 0, 0)
		ok
	but _cN_ = "skew"
		if NOT (isList(paSpec) and len(paSpec) >= 1)
			StzRaise("Weather(:skew, [ ms ]).")
		ok
		if NOT isNumber(paSpec[1])
			StzRaise("Weather(:skew, [ ms ]) wants milliseconds that are a number.")
		ok
		_c_ = _TestoorWorldCall("declareskew", "", paSpec[1], 0)
		if left(_c_, 1) = "!"
			StzRaise("Weather(:skew, ...) wants ClockTo(:stepped, [ startMs, stepMs ]) first.")
		ok
	else
		StzRaise("Weather: unknown weather " + pcName + " (child_killed, skew).")
	ok
	# the core answers the ordinal it gave the weather and its tick, a line each
	_acA_ = str2list(_c_)
	$aTestoorSpecs + [ _cN_, paSpec ]
	_nTick_ = 0 + _acA_[2]
	? "[testoor weather " + _cN_ + "@" + _nTick_ + "]"
	return _nTick_

# the names of the weather declared so far, in order
func WeatherDeclared()
	if NOT _TestoorWorldIsEngine()
		return _WeatherDeclaredRing()
	ok
	_acOut_ = []
	_c_ = _TestoorWorldCall("declared", "", 0, 0)
	if _c_ != ""
		_acO_ = str2list(_c_)
		_nO_ = len(_acO_)
		for _i_ = 1 to _nO_
			_acOut_ + $aTestoorSpecs[0 + _acO_[_i_]][1]
		next
	ok
	return _acOut_

# [ [ name, tick ] ... ] of what is declared and has not fallen due
func WeatherPlan()
	if NOT _TestoorWorldIsEngine()
		return _WeatherPlanRing()
	ok
	_aOut_ = []
	_c_ = _TestoorWorldCall("planned", "", 0, 0)
	if _c_ != ""
		_acO_ = str2list(_c_)
		_nO_ = len(_acO_)
		for _i_ = 1 to _nO_ step 2
			_aOut_ + [ $aTestoorSpecs[0 + _acO_[_i_]][1], 0 + _acO_[_i_ + 1] ]
		next
	ok
	return _aOut_

# applies the fired child_killed weather to a REAL stzNodeSupervisor and
# answers how many children it killed
func WeatherKill(poSupervisor, paFired)
	_nKilled_ = 0
	_n_ = len(paFired)
	for _i_ = 1 to _n_
		if paFired[_i_][1] = "child_killed"
			poSupervisor.KillChild("" + paFired[_i_][2][1])
			_nKilled_++
		ok
	next
	return _nKilled_

#=== THE REFERENCE ================================================================
# What the core was written from, unchanged in behaviour: it runs when the core does not own the
# world. Kept so the two can be walked side by side in one process (testoor_core_narrated.ring).

func _SeedRing(pxSeed)
	_n_ = -1
	if isNumber(pxSeed)
		_n_ = pxSeed
	else
		_n_ = _TestoorArgSeed()
		if _n_ < 0
			# run by hand, no runner: a seed from the clock, REPORTED so the
			# run can be walked again with --seed
			_n_ = 1 + (floor(clock() * 1000 / clockspersecond()) % 90000)
		ok
	ok
	SeedRandom(_n_)
	$aTestoorWorld[:seed] = _n_
	? "[testoor seed " + _n_ + "]"
	return _n_

# the seed the runner passed on the command line, or -1
func _TestoorArgSeed()
	_nA_ = len(sysargv)
	for _i_ = 1 to _nA_ - 1
		if sysargv[_i_] = "--testoor-seed"
			return 0 + sysargv[_i_ + 1]
		ok
	next
	return -1

func _ClockToRing(pcMode, pxArg)
	_m_ = lower("" + pcMode)
	if _m_ = "frozen"
		StzFreezeClock("" + pxArg)
		$aTestoorWorld[:mode] = "frozen"
	but _m_ = "stepped"
		if NOT (isList(pxArg) and len(pxArg) >= 2)
			StzRaise("ClockTo(:stepped, [ startMs, stepMs ]) wants a start and a step.")
		ok
		$aTestoorWorld[:mode] = "stepped"
		$aTestoorWorld[:ms] = pxArg[1]
		$aTestoorWorld[:step] = pxArg[2]
		$aTestoorWorld[:tick] = 0
		$aTestoorWorld[:weather] = _TestoorUnfired($aTestoorWorld[:weather], -1)
	but _m_ = "live"
		StzUnfreezeClock()
		$aTestoorWorld[:mode] = "live"
	else
		StzRaise("ClockTo: unknown mode " + pcMode + " (frozen, stepped, live).")
	ok
	? "[testoor clock " + $aTestoorWorld[:mode] + "]"
	return $aTestoorWorld[:mode]

func _ClockNowRing()
	if $aTestoorWorld[:mode] = "stepped"
		return $aTestoorWorld[:ms]
	ok
	return StzEngineTimeNowMs()

func _ClockAdvanceRing(pnMs)
	if $aTestoorWorld[:mode] != "stepped"
		StzRaise("ClockAdvance wants ClockTo(:stepped, [ startMs, stepMs ]) first.")
	ok
	$aTestoorWorld[:ms] += pnMs
	return $aTestoorWorld[:ms]

func _ClockTickRing()
	if $aTestoorWorld[:mode] != "stepped"
		StzRaise("ClockTick wants ClockTo(:stepped, [ startMs, stepMs ]) first.")
	ok
	$aTestoorWorld[:tick]++
	$aTestoorWorld[:ms] += $aTestoorWorld[:step]
	_aFired_ = []
	_nW_ = len($aTestoorWorld[:weather])
	for _i_ = 1 to _nW_
		_w_ = $aTestoorWorld[:weather][_i_]
		if _w_[3] = $aTestoorWorld[:tick] and _w_[4] = 0
			$aTestoorWorld[:weather][_i_][4] = 1
			_aFired_ + [ _w_[1], _w_[2] ]
			? "[testoor weather fired " + _w_[1] + "@" + _w_[3] + "]"
		ok
	next
	return _aFired_

func _WeatherRing(pcName, paSpec)
	if $aTestoorWorld[:seed] < 0
		Seed(:run)
	ok
	_cN_ = lower("" + pcName)
	_nTick_ = 0
	if _cN_ = "child_killed"
		if NOT (isList(paSpec) and len(paSpec) >= 1)
			StzRaise("Weather(:child_killed, [ child ] or [ child, tick ]).")
		ok
		if len(paSpec) >= 2
			_nTick_ = paSpec[2]
		else
			# Ring's own generator picks the tick: the same seed kills at the same tick, on this VM
			_nTick_ = 1 + random(5)
		ok
	but _cN_ = "skew"
		if NOT (isList(paSpec) and len(paSpec) >= 1)
			StzRaise("Weather(:skew, [ ms ]).")
		ok
		if $aTestoorWorld[:mode] != "stepped"
			StzRaise("Weather(:skew, ...) wants ClockTo(:stepped, [ startMs, stepMs ]) first.")
		ok
		$aTestoorWorld[:ms] += paSpec[1]
	else
		StzRaise("Weather: unknown weather " + pcName + " (child_killed, skew).")
	ok
	$aTestoorWorld[:weather] + [ _cN_, paSpec, _nTick_, 0 ]
	? "[testoor weather " + _cN_ + "@" + _nTick_ + "]"
	return _nTick_

func _WeatherDeclaredRing()
	_acOut_ = []
	_n_ = len($aTestoorWorld[:weather])
	for _i_ = 1 to _n_
		_acOut_ + $aTestoorWorld[:weather][_i_][1]
	next
	return _acOut_

func _WeatherPlanRing()
	_aOut_ = []
	_n_ = len($aTestoorWorld[:weather])
	for _i_ = 1 to _n_
		_w_ = $aTestoorWorld[:weather][_i_]
		if _w_[4] = 0  _aOut_ + [ _w_[1], _w_[3] ]  ok
	next
	return _aOut_

# a restarted stepped clock keeps no weather that already fell due
func _TestoorUnfired(paWeather, pnKeep)
	_aOut_ = []
	_n_ = len(paWeather)
	for _i_ = 1 to _n_
		if paWeather[_i_][4] = 0  _aOut_ + paWeather[_i_]  ok
	next
	return _aOut_
