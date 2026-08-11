

$nTime0 = 0

func pr()
	$nTime0 = clock()

func pf()

	_cElapsed_ = "" + (clock() - $nTime0) / clockspersecond()
	if 0+ _cElapsed_ = 0 
		_cElapsed_ = "almost 0"
	ok

	? char(10) + "Executed in " + _cElapsed_ + " second(s) in Ring " + ring_version()
	$nTime0 = 0
	STOP()

func STOP()
	raise( char(10) + 
	    "----------------" + char(10) +
	    "    STOPPED!    " + char(10) +
	    "----------------"
	)
