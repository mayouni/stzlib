

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

# Same as pf() but without STOP(): it prints the elapsed time and returns.
# A guard ends on pfq() then shutdown(<fail count>), so its exit code is its
# verdict; pf() raises, and nothing after it runs (2026-11-06).
func pfq()

	_cElapsed_ = "" + (clock() - $nTime0) / clockspersecond()
	if 0+ _cElapsed_ = 0
		_cElapsed_ = "almost 0"
	ok

	? char(10) + "Executed in " + _cElapsed_ + " second(s) in Ring " + ring_version()
	$nTime0 = 0

func STOP()
	raise( char(10) + 
	    "----------------" + char(10) +
	    "    STOPPED!    " + char(10) +
	    "----------------"
	)
