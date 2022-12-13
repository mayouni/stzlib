

  #----------------------#
 #    EXECUTION TIME    #
#----------------------#

func ExecutionTime(pcCode, pcUnit)
	switch pcUnit
	on :InSeconds
		return ExecutionTimeInSeconds(pcCode)
	on :InClocks
		return ExecutionTimeInClocks(pcCode)
	on :InSecondsAndClocks
		return ExecutionTimeInSecondsAndClocks(pcCode)
	on :InClocksAndSeconds 
		return ExecutionTimeInClocksAndSeconds(pcCode)
	other
		StzRaise("Syntax error in the value of pcUnit parameter!")
	off

func ExecutionTimeInSeconds(pcCode)
	t0 = clock()
	eval(pcCode)
	t1 = clock()

	nClocks = t1 - t0
	nSeconds = nClocks / clocksPerSecond()
	return nSeconds

func ExecutionTimeInClocks(pcCode)
	t0 = clock()
	eval(pcCode)
	t1 = clock()

	return t1 - t0

func ExecutionTimeInClocksAndSeconds(pcCode)
	t0 = clock()
	eval(pcCode)
	t1 = clock()

	nClocks = t1 - t0
	nSeconds = nClocks / clocksPerSecond()
	return [ nClocks, nSeconds ]

func ExecutionTimeInSecondsAndClocks(pcCode)
	t0 = clock()
	eval(pcCode)
	t1 = clock()

	nClocks = t1 - t0
	nSeconds = nClocks / clocksPerSecond()
	return [ nSeconds, nClocks ]

func WaitForNSeconds(n)
	//? "Waiting for " + n + " seconds..."
	while clock() / clockspersecond() < n
		// Wait
	end
	//? "Done"

func WaitForNMinutes(n)
	//? "Waiting for " + n + " minutes..."
	while clock() / clockspersecond() < n * 60
		// Wait
	end
	//? "Done"
