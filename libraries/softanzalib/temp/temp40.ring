load "stzlib.ring"
/*
o1 = new stzFunction("Assemble('Hello', 'my', 'freind')")
? o1.name() + NL
? o1.params()
? o1.run()
*/

oCacheFunc = CacheCreateIfInexistant("cachefunc",:InFile)
oCacheFunc.Activate()

? Assemble("x1","x2","z1")[:result]
? Assemble("tunis","Cairo","Nimaey")[:result]
//? Assemble("x1","x2","z1")[:meta]
//? Assemble("x1","y1","z1")[:meta][:vars]
/*
CacheFindEntry("mycache", "Assemble|['tunis','Cairo','Nimaey']")
? "---"
CacheGetCachedResult("mycache", "Assemble|['tunis','Cairo','Nimaey']")
*/
oCacheFunc.Deactivate()


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
			nTemp = 500 * 100
		next

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
		//aMeta + :ExecTime = nSeconds
	# <MetaCode/>

	# <MetaCode> : The function stores its activity in the cache
		if oCacheFunc.IsActivated()
			cCacheEntry = oCacheFunc.ComposeLine([ :TimeStamp, :Assemble, [ pcPart1, pcPart2, pcPart3 ], cResult, nSeconds ])
			oCacheFunc.AddLine(cCacheEntry)
		ok
	# <MetaCode/>

	// Returning the function result along with its meta information
	return [ :result = cResult, :meta = aMeta ]
