load "../stzlib.ring"

//? Assemble("x1","x2","z1")[:meta][:duration] + NL
? Assemble("Tunis","Cairo","Nimaey")[:result]
//? Assemble("x1","x2","z1")[:meta]
//? Assemble("x1","y1","z1")[:meta][:vars]

func Assemble(pcPart1, pcPart2, pcPart3)
	# <MetaCode> : The function becomes aware of the names of its parameters
		_aMeta_ = [ :params = [:pcPart1, :pcPart2, :pcPart3] ]
	# <MetaCode/>

	# <Perf> : Set Performance counter ON
		_t0_ = clock()
	# <Perf/>

	# <Code>
		_cSep_ = "."
		_cResult_ = pcPart1 + _cSep_ + pcPart2 + _cSep_ + pcPart3
		for i = 1 to 100_000
			i*i
		next i
	# <Code/>

	# <Perf> : Yield code performance
		_t1_ = clock()
		_nClocks_ = _t1_ - _t0_
		_nSeconds_ = _nClocks_ / clocksPerSecond()

	# <Perf/>

	# <MetaCode> : The function becomes aware of its local variables names, types, and values
		_aLocals_ = locals()
		_aVars_ = []
		_nLocalsLen_ = len(_aLocals_)
		for v = len(_aMeta_[:params])+3 to _nLocalsLen_-4
			_cCode_ = "aVars + [ aLocals[v], [ :type = ring_type(" + _aLocals_[v] + "), :value = " + _aLocals_[v] + " ] ]"
			eval(_cCode_)
		next

		_aMeta_ + :vars = _aVars_
	# <MetaCode/>

	# <MetaCode> : The function becomes aware of its execution time
		_aMeta_ + :duration = _nSeconds_
	# <MetaCode/>

	# <MetaCode> : The function stores its activity in the cache
		CacheFunc(:Assemble, [ pcPart1, pcPart2, pcPart3 ], _cResult_, _nSeconds_ )
	# <MetaCode/>

	// Returning the function result along with its meta information
	return [ :result = _cResult_, :meta = _aMeta_ ]

func CacheFunc(cFunc, aParams, pResult, _nSeconds_)
	_cCacheLine_  = "[ "
	_cCacheLine_ +=  '"' + stzTimeStamp() + '" , '
	_cCacheLine_ += "[ "
	_n_ = 0
	_nParams1Len_ = len(aParams)
	for _iLoopParams1_ = 1 to _nParams1Len_
		_value_ = aParams[_iLoopParams1_]
		_n_++
		switch ring_type(_value_)
		on "NUMBER"
			_cCacheLine_ += _value_
		on "STRING"
			_cCacheLine_ += '"' + _value_ + '"'
		on "LIST"
			_cCacheLine_ += list2str(_value_) # enhance it!
		on "OBJECT"
			// TODO
		off
		
		if _n_ < len(aParams)
			_cCacheLine_ += " , "
		ok
	next
	_cCacheLine_ += " ]" + " , "
	
	switch ring_type(pResult)
	on "NUMBER"
		_cCacheLine_ += pResult
	on "STRING"
		_cCacheLine_ += '"' + pResult + '"'
	on "LIST"
		_cCacheLine_ += list2str(pResult) # Enhance it!
	on "OBJECT"
		// TODO
	off
	
	_cCacheLine_ += ", " + _nSeconds_ + " ]"

	TextFileAddLine("stzCacheFunc.ring", _cCacheLine_ + NL)

func stzTimeStamp()
	return date() + " " + time()
