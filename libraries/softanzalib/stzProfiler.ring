load "stzlib.ring"

//? Assemble("x1","x2","z1")[:meta][:duration] + NL
? Assemble("Tunis","Cairo","Nimaey")[:result]
//? Assemble("x1","x2","z1")[:meta]
//? Assemble("x1","y1","z1")[:meta][:vars]

func Assemble(pcPart1, pcPart2, pcPart3)
	# <MetaCode> : The function becomes aware of the names of its parameters
		aMeta = [ :params = [:pcPart1, :pcPart2, :pcPart3] ]
	# <MetaCode/>

	# <Perf> : Set Performance counter ON
		t0 = clock()
	# <Perf/>

	# <Code>
		cSep = "."
		cResult = pcPart1 + cSep + pcPart2 + cSep + pcPart3
		for i = 1 to 100_000
			i*i
		next i
	# <Code/>

	# <Perf> : Yield code performance
		t1 = clock()
		nClocks = t1 - t0
		nSeconds = nClocks / clocksPerSecond()

	# <Perf/>

	# <MetaCode> : The function becomes aware of its local variables names, types, and values
		aLocals = locals()
		aVars = []
		for v= len(aMeta[:params])+3 to len(aLocals)-4
			cCode = "aVars + [ aLocals[v], [ :type = type(" + aLocals[v] + "), :value = " + aLocals[v] + " ] ]"
			eval(cCode)
		next

		aMeta + :vars = aVars
	# <MetaCode/>

	# <MetaCode> : The function becomes aware of its execution time
		aMeta + :duration = nSeconds
	# <MetaCode/>

	# <MetaCode> : The function stores its activity in the cache
		CacheFunc(:Assemble, [ pcPart1, pcPart2, pcPart3 ], cResult, nSeconds )
	# <MetaCode/>

	// Returning the function result along with its meta information
	return [ :result = cResult, :meta = aMeta ]

func CacheFunc(cFunc, aParams, pResult, nSeconds)
	cCacheLine  = "[ "
	cCacheLine +=  '"' + stzTimeStamp() + '" , '
	cCacheLine += "[ "
	n = 0
	for value in aParams
		n++
		switch type(value)
		on "NUMBER"
			cCacheLine += value
		on "STRING"
			cCacheLine += '"' + value + '"'
		on "LIST"
			cCacheLine += list2str(value) # enhance it!
		on "OBJECT"
			// TODO
		off
		
		if n < len(aParams)
			cCacheLine += " , "
		ok
	next
	cCacheLine += " ]" + " , "
	
	switch type(pResult)
	on "NUMBER"
		cCacheLine += pResult
	on "STRING"
		cCacheLine += '"' + pResult + '"'
	on "LIST"
		cCacheLine += list2str(pResult) # Enhance it!
	on "OBJECT"
		// TODO
	off
	
	cCacheLine += ", " + nSeconds + " ]"

	TextFileAddLine("stzCacheFunc.ring", cCacheLine + NL)

func stzTimeStamp()
	return date() + " " + time()
