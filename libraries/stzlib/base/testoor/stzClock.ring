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
#                    seeded generator picks one, 1 to 6, so the same seed
#                    kills at the same tick); :skew with [ ms ] -- the stepped
#                    clock jumps. WeatherKill(supervisor, fired) applies the
#                    child_killed weather to the platform's OWN
#                    stzNodeSupervisor.KillChild: no mock stands in for it.
#
# The stepped clock is in Ring for now; the engine owns counting, seeds and
# the scheduler hook (ruling 12) and the clock moves there when a second
# consumer needs it. A weather a tour did not declare cannot be seen from here
# -- it is found from outside: the runner walks a tour twice with one seed and
# calls it flaky when the verdicts differ (stzTraveller.ring, Repeat).
#
# State lives in ONE global hash-list, read and written with the `$` prefix
# everywhere (Rule A): a returned object would be copied by Ring and a
# mutation through the copy would be lost.

$aTestoorWorld = [ :seed = -1, :mode = "live", :ms = 0, :step = 0, :tick = 0, :weather = [] ]

# forget everything a tour declared; the wall clock is thawed too
func TestoorReset()
	$aTestoorWorld = [ :seed = -1, :mode = "live", :ms = 0, :step = 0, :tick = 0, :weather = [] ]
	StzUnfreezeClock()
	return 1

#--- Seed --------------------------------------------------------------------

func Seed(pxSeed)
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

#--- Clock -------------------------------------------------------------------

func ClockTo(pcMode, pxArg)
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

func ClockMode()
	return $aTestoorWorld[:mode]

# the logical milliseconds of the stepped clock; on any other clock the
# engine's own wall milliseconds
func ClockNow()
	if $aTestoorWorld[:mode] = "stepped"
		return $aTestoorWorld[:ms]
	ok
	return StzEngineTimeNowMs()

func ClockAdvance(pnMs)
	if $aTestoorWorld[:mode] != "stepped"
		StzRaise("ClockAdvance wants ClockTo(:stepped, [ startMs, stepMs ]) first.")
	ok
	$aTestoorWorld[:ms] += pnMs
	return $aTestoorWorld[:ms]

func ClockTicks()
	return $aTestoorWorld[:tick]

# ONE step of the stepped clock, and the weather that falls due at it:
# [ [ name, spec ] ... ], each printed once as "[testoor weather fired n@t]"
func ClockTick()
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

#--- Weather -----------------------------------------------------------------

# declares a fault and answers the tick it will fall due at (0 = at once)
func Weather(pcName, paSpec)
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
			# the seeded generator picks the tick: the same seed kills at the same tick
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

# the names of the weather declared so far, in order
func WeatherDeclared()
	_acOut_ = []
	_n_ = len($aTestoorWorld[:weather])
	for _i_ = 1 to _n_
		_acOut_ + $aTestoorWorld[:weather][_i_][1]
	next
	return _acOut_

# [ [ name, tick ] ... ] of what is declared and has not fallen due
func WeatherPlan()
	_aOut_ = []
	_n_ = len($aTestoorWorld[:weather])
	for _i_ = 1 to _n_
		_w_ = $aTestoorWorld[:weather][_i_]
		if _w_[4] = 0  _aOut_ + [ _w_[1], _w_[3] ]  ok
	next
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

# a restarted stepped clock keeps no weather that already fell due
func _TestoorUnfired(paWeather, pnKeep)
	_aOut_ = []
	_n_ = len(paWeather)
	for _i_ = 1 to _n_
		if paWeather[_i_][4] = 0  _aOut_ + paWeather[_i_]  ok
	next
	return _aOut_
