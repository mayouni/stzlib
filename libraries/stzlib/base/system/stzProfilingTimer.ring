#~~~~~~~~~~~~~~~~~~#
#  PROFILING TIME  #
#~~~~~~~~~~~~~~~~~~#

# Module-level default so ElapsedTime() works without a prior
# StartTimer() call (tests that just want a duration but didn't
# bootstrap the timer trigger an R24 otherwise).
_time0 = clock()

# Concat(aList): join string items into one string. Common helper
# used by perf-narration tests; not living in a more specific file.
func Concat(aList)
	if NOT isList(aList) return "" + aList ok
	_nL_ = ring_len(aList)
	_c_ = ""
	for _i_ = 1 to _nL_
		if isString(aList[_i_]) _c_ += aList[_i_] ok
	next
	return _c_

func StzStartTimer()
	_time0 = clock()

	func StartTimer()
		StzStartTimer()

func StzResetTimer()
	_time0 = clock()

	func ResetTimer()
		StzResetTimer()

	func ResetProfiler()
		StzResetTimer()

func StzElapsedTime()
	return StzElapsedTimeXT(:In = :Seconds)

	func ElapsedTime()
		return StzElapsedTime()

	func ElpasedTime()
		return StzElapsedTime()

func StzElapsedTimeXT(pIn)

	if isList(pIn) and Q(pIn).IsInNamedParam()
		pIn = pIn[2]
	ok

	if NOT isString(pIn)
		StzRaise("Incorrect param type! pIn must be a string.")
	ok

	if NOT StzFind([ :Clocks, :Seconds, :Minutes, :Hours ], pIn)
		#TODO // Future: Add days, weeks, months, years...

		StzRaise("Incorrect value of pIn param! Allowed values are: " +
		":Clocks, :Seconds, :Minutes and :Hours.")
	ok

	switch pIn
	on :Clocks
		return clock() - _time0 + " clocks"

	on :Seconds
		nTime = ( clock() - _time0 ) / clockspersecond()
		cTime = "" + nTime
		return cTime + " second(s)"

	on :Minutes
		nTime = ( clock() - _time0 ) / clockspersecond() / 60
		cTime = "" + nTime
		return cTime + " minute(s)"

	on :Hours
		nTime = ( clock() - _time0 ) / clockspersecond() / 3600
		cTime = "" + nTime
		return cTime + " hour(s)"

	off
	
	func ElapsedTimeXT(pIn)
		return StzElapsedTimeXT(pIn)

	func ElpasedTimeXT(pIn)
		return StzElapsedTimeXT(pIn)

func StzStartProfiler()
	pr() # From Softanza CORE layer

	func StartProfiler()
		StzStartProfiler()

	func ProfilerOn()
		StzStartProfiler()

	func pron()
		StzStartProfiler()

	func profon()
		StzStartProfiler()


func StzEndProfiler()
	pf() # From Softanza CORE layer

	func EndProfiler()
		StzEndProfiler()

	func Profoff()
		StzEndProfiler()

	func StopProfiler()
		StzEndProfiler()

	func ProfilerOff()
		StzEndProfiler()

	func prff()
		StzEndProfiler()

	func Proff()
		StzEndProfiler()

	func prf()
		StzEndProfiler()
