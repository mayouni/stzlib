#~~~~~~~~~~~~~~~~~~#
#  PROFILING TIME  #
#~~~~~~~~~~~~~~~~~~#

func StartTimer()
	_time0 = clock()

func ResetTimer()
	_time0 = clock()

	func ResetProfiler()
		_time0 = clock()

func ElapsedTime()
	return ElapsedTimeXT(:In = :Seconds)

	func ElpasedTime()
		return ElapsedTime()
		#NOTE
		# This function name alternative contains a spelling error.
		# Despite that, I'll take it. Because I always make this
		#ERRor and don't want to be blocked for that.

func ElapsedTimeXT(pIn)

	if isList(pIn) and Q(pIn).IsInNamedParam()
		pIn = pIn[2]
	ok

	if NOT isString(pIn)
		StzRaise("Incorrect param type! pIn must be a string.")
	ok

	if NOT ring_find([ :Clocks, :Seconds, :Minutes, :Hours ], pIn)
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
	
	func ElpasedTimeXT(pIn)
		return ElapsedTimeXT(pIn)

func StartProfiler()
	pr() # From Softanza CORE layer

	func ProfilerOn()
		_time0 = clock()

	func pron()
		_time0 = clock()

	func profon()
		_time0 = clock()


func EndProfiler()
	pf() # From Softanza CORE layer

	func Profoff()
		pf()

	func StopProfiler()
		pf()

	func ProfilerOff()
		pf()

	func prff()
		pf()

	func Proff()
		pf()

	func prf()
		Proff()
